import 'dart:async';
import 'dart:io';
import '../../../../data/services/network_helper.dart';
import 'package:flutter/foundation.dart';
import '../../../../data/models/print_job_dto.dart';
import '../../../../data/services/api_service.dart';

class DesktopSessionViewModel extends ChangeNotifier {
  final ApiService apiService;

  int _currentStep = 0; // 0: Boas-vindas, 1: Wi-Fi, 2: Upload, 3: Resumo, 4: Pagamento/Impressão
  PrintJobDto? _currentJob;
  String _localIp = '127.0.0.1';
  String _customIp = '';
  bool _isLoading = false;
  String? _errorMessage;

  // Status de impressão em tempo real
  double _printProgress = 0.0;
  int _pagesPrinted = 0;
  String _printStatusText = 'Aguardando confirmação...';
  bool _isPrintingCompleted = false;
  Timer? _mockProgressTimer;
  Timer? _networkMonitorTimer;

  DesktopSessionViewModel({required this.apiService}) {
    _initNetworkInfo();
  }

  int get currentStep => _currentStep;
  PrintJobDto? get currentJob => _currentJob;
  String get localIp => _localIp;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get printProgress => _printProgress;
  int get pagesPrinted => _pagesPrinted;
  String get printStatusText => _printStatusText;
  bool get isPrintingCompleted => _isPrintingCompleted;

  bool _isNetworkDetected = false;
  bool get isNetworkDetected => _isNetworkDetected;

  String _wifiSsid = 'BE EASY - TEFNet_5g';
  String _wifiPassword = 'clientebeeasy7789@';
  double _unitPrice = 2.0;

  String get wifiSsid => _wifiSsid;
  String get wifiPassword => _wifiPassword;
  double get unitPrice => _unitPrice;
  String get unitPriceFormatted => 'R\$ ${_unitPrice.toStringAsFixed(2).replaceAll('.', ',')}';
  String get webAppUrl => 'http://$_localIp:8080/app';

  /// Gera a string padronizada do QR Code Wi-Fi (WIFI:S:...;T:WPA;P:...;;)
  String get wifiQrData =>
      'WIFI:S:${_escapeWifiString(_wifiSsid)};T:WPA;P:${_escapeWifiString(_wifiPassword)};;';

  static String _escapeWifiString(String text) {
    return text
        .replaceAll(r'\', r'\\')
        .replaceAll(';', r'\;')
        .replaceAll(':', r'\:')
        .replaceAll(',', r'\,');
  }

  Future<void> _initNetworkInfo() async {
    await _checkAndUpdateIp();
    await refreshConfig();

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }

    // Se no boot da máquina o DHCP ainda não entregou o IP, tenta periodicamente
    if (_localIp == '127.0.0.1') {
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(seconds: 2));
        await _checkAndUpdateIp();
        if (_localIp != '127.0.0.1') break;
      }
    }

    // Monitoramento periódico contínuo de IP (heartbeat para alterações de DHCP)
    _networkMonitorTimer?.cancel();
    _networkMonitorTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      await _checkAndUpdateIp();
    });
  }

  /// Verifica e atualiza o IP se houver mudança de rede ou DHCP
  Future<void> _checkAndUpdateIp() async {
    if (_customIp.isNotEmpty) return;

    String candidateIp = '127.0.0.1';
    if (!kIsWeb) {
      try {
        candidateIp = await NetworkHelper.findLocalIp();
      } catch (_) {}
    }

    if (candidateIp == '127.0.0.1') {
      try {
        final ipFromServer = await apiService.getLocalIp();
        if (ipFromServer != '127.0.0.1') {
          candidateIp = ipFromServer;
        }
      } catch (_) {}
    }

    if (candidateIp != '127.0.0.1' && candidateIp != _localIp) {
      _localIp = candidateIp;
      _isNetworkDetected = true;
      notifyListeners();
    }
  }

  /// Recarrega as configurações salvas pelo painel administrativo
  Future<void> refreshConfig() async {
    try {
      final config = await apiService.getConfig();
      _wifiSsid = config.wifiSsid;
      _wifiPassword = config.wifiPassword;
      _unitPrice = config.unitPrice;
      _customIp = config.customIp;
      if (_customIp.isNotEmpty) {
        _localIp = _customIp;
        _isNetworkDetected = true;
      } else {
        await _checkAndUpdateIp();
      }
      notifyListeners();
    } catch (_) {}
  }

  void goToStep(int step) {
    _currentStep = step;
    _errorMessage = null;
    notifyListeners();
  }

  void nextStep() {
    _currentStep++;
    notifyListeners();
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  /// Processa arquivo inserido via pendrive ou arrastado para a tela
  Future<void> handleFileUpload(String filePath, String fileName, Uint8List? rawBytes) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Uint8List bytes;
      if (rawBytes != null && rawBytes.isNotEmpty) {
        bytes = rawBytes;
      } else if (!kIsWeb && filePath.isNotEmpty) {
        bytes = await File(filePath).readAsBytes();
      } else {
        throw Exception('Não foi possível ler os dados do arquivo.');
      }

      final job = await apiService.uploadPdf(
        fileName: fileName,
        bytes: bytes,
        source: 'desktop_usb',
      );

      _currentJob = job;
      _currentStep = 3; // Avança para Tela 4: Confirmação do Pedido
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Confirma e despacha a impressão simultaneamente ao pagamento PIX
  Future<void> confirmAndStartPrinting() async {
    if (_currentJob == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await apiService.confirmJob(_currentJob!.id);
      _currentStep = 4; // Avança para Tela 5: Pagamento e Impressão
      _startSimulatedPrintProgress();
    } catch (e) {
      _errorMessage = 'Falha ao iniciar impressão: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startSimulatedPrintProgress() {
    final total = _currentJob?.pageCount ?? 15;
    _printProgress = 0.05;
    _pagesPrinted = 0;
    _printStatusText = 'Aquecendo impressora e alimentando folhas...';
    _isPrintingCompleted = false;
    notifyListeners();

    _mockProgressTimer?.cancel();
    _mockProgressTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (_pagesPrinted < total) {
        _pagesPrinted++;
        _printProgress = _pagesPrinted / total;
        _printStatusText = 'Imprimindo página $_pagesPrinted de $total...';
        notifyListeners();
      } else {
        _printProgress = 1.0;
        _printStatusText = 'Todas as $total páginas impressas com sucesso!';
        _isPrintingCompleted = true;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  void resetSession() {
    _mockProgressTimer?.cancel();
    _currentStep = 0;
    _currentJob = null;
    _printProgress = 0.0;
    _pagesPrinted = 0;
    _printStatusText = 'Aguardando';
    _isPrintingCompleted = false;
    _errorMessage = null;
    notifyListeners();
  }

  @visibleForTesting
  void setPrintProgressForTesting({
    required double progress,
    bool isCompleted = false,
    String? statusText,
    int? pagesPrinted,
  }) {
    _printProgress = progress;
    _isPrintingCompleted = isCompleted;
    if (statusText != null) _printStatusText = statusText;
    if (pagesPrinted != null) _pagesPrinted = pagesPrinted;
    notifyListeners();
  }

  @visibleForTesting
  void setCurrentJobForTesting(PrintJobDto? job) {
    _currentJob = job;
    notifyListeners();
  }

  @override
  void dispose() {
    _mockProgressTimer?.cancel();
    _networkMonitorTimer?.cancel();
    super.dispose();
  }
}
