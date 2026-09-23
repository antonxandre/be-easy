import '../../../../data/services/network_helper.dart';
import 'package:flutter/foundation.dart';
import '../../../../data/models/admin_config_dto.dart';
import '../../../../data/services/api_service.dart';
import '../../../../data/services/windows_startup_service.dart';

class AdminViewModel extends ChangeNotifier {
  final ApiService apiService;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSearchingPrinters = false;
  bool _isTestingPrint = false;

  String? _statusMessage;
  bool _isSuccessMessage = true;

  AdminConfigDto? _config;
  List<PrinterInfoDto> _printers = [];

  // Campos do formulário
  double _unitPrice = 2.0;
  String _wifiSsid = 'BE EASY - TEFNet_5g';
  String _wifiPassword = 'clientebeeasy7789@';
  String _ipMode = 'auto'; // 'auto' | 'manual'
  String _customIp = '';
  String _detectedIp = '127.0.0.1';
  int _serverPort = 8080;
  String _selectedPrinter = '';
  bool _useMockPrinter = true;
  String _pixKey = '65717703000180';
  String _merchantName = 'BE EASY PRINT';
  String _merchantCity = 'SAO PAULO';
  bool _isWindowsAutoStart = false;

  AdminViewModel({required this.apiService}) {
    loadData();
  }

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isSearchingPrinters => _isSearchingPrinters;
  bool get isTestingPrint => _isTestingPrint;

  String? get statusMessage => _statusMessage;
  bool get isSuccessMessage => _isSuccessMessage;

  AdminConfigDto? get config => _config;
  List<PrinterInfoDto> get printers => _printers;

  double get unitPrice => _unitPrice;
  String get wifiSsid => _wifiSsid;
  String get wifiPassword => _wifiPassword;
  String get ipMode => _ipMode;
  String get customIp => _customIp;
  String get detectedIp => _detectedIp;
  int get serverPort => _serverPort;
  String get selectedPrinter => _selectedPrinter;
  bool get useMockPrinter => _useMockPrinter;
  String get pixKey => _pixKey;
  String get merchantName => _merchantName;
  String get merchantCity => _merchantCity;
  bool get isWindowsAutoStart => _isWindowsAutoStart;

  String get activeIp => _ipMode == 'manual' && _customIp.isNotEmpty ? _customIp : _detectedIp;
  String get clientWebUrl => 'http://$activeIp:$_serverPort/app';

  /// Gera o payload padrão de Wi-Fi para QR Code (WIFI:S:...;T:WPA;P:...;;)
  String get wifiQrData =>
      'WIFI:S:${_escapeWifiString(_wifiSsid)};T:WPA;P:${_escapeWifiString(_wifiPassword)};;';

  static String _escapeWifiString(String text) {
    return text
        .replaceAll(r'\', r'\\')
        .replaceAll(';', r'\;')
        .replaceAll(':', r'\:')
        .replaceAll(',', r'\,');
  }

  void setUnitPrice(double value) {
    if (value > 0) {
      _unitPrice = double.parse(value.toStringAsFixed(2));
      notifyListeners();
    }
  }

  void adjustUnitPrice(double delta) {
    final next = _unitPrice + delta;
    if (next >= 0.1) {
      setUnitPrice(next);
    }
  }

  void setWifiSsid(String value) {
    _wifiSsid = value;
    notifyListeners();
  }

  void setWifiPassword(String value) {
    _wifiPassword = value;
    notifyListeners();
  }

  void setIpMode(String mode) {
    _ipMode = mode;
    notifyListeners();
  }

  void setCustomIp(String value) {
    _customIp = value;
    notifyListeners();
  }

  void setServerPort(int port) {
    _serverPort = port;
    notifyListeners();
  }

  void setPixKey(String value) {
    _pixKey = value;
    notifyListeners();
  }

  void setMerchantName(String value) {
    _merchantName = value;
    notifyListeners();
  }

  void setMerchantCity(String value) {
    _merchantCity = value;
    notifyListeners();
  }

  void selectPrinter(PrinterInfoDto printer) {
    _selectedPrinter = printer.name;
    _useMockPrinter = printer.isMock;
    notifyListeners();
  }

  void clearStatusMessage() {
    _statusMessage = null;
    notifyListeners();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _statusMessage = null;
    notifyListeners();

    try {
      // 1. Detecta IP das interfaces do SO com NetworkHelper
      if (!kIsWeb) {
        try {
          _detectedIp = await NetworkHelper.findLocalIp();
        } catch (_) {}
      }

      // 2. Carrega configurações do servidor
      final cfg = await apiService.getConfig();
      _config = cfg;
      _unitPrice = cfg.unitPrice;
      _wifiSsid = cfg.wifiSsid;
      _wifiPassword = cfg.wifiPassword;
      _customIp = cfg.customIp;
      _serverPort = cfg.serverPort;
      _selectedPrinter = cfg.selectedPrinter;
      _useMockPrinter = cfg.useMockPrinter;
      _pixKey = cfg.pixKey;
      _merchantName = cfg.merchantName;
      _merchantCity = cfg.merchantCity;

      if (_customIp.isNotEmpty) {
        _ipMode = 'manual';
      } else {
        _ipMode = 'auto';
      }

      // 3. Carrega lista de impressoras
      await searchPrinters(silent: true);

      // 4. Verifica status de inicialização automática no Windows
      _isWindowsAutoStart = await WindowsStartupService.isAutoStartEnabled();
    } catch (e) {
      _statusMessage = 'Erro ao carregar dados do servidor: $e';
      _isSuccessMessage = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchPrinters({bool silent = false}) async {
    _isSearchingPrinters = true;
    if (!silent) notifyListeners();

    try {
      final list = await apiService.getPrinters();
      _printers = list;

      // Se nenhuma impressora estiver explicitamente selecionada, seleciona a padrão ou mock
      if (_selectedPrinter.isEmpty && _printers.isNotEmpty) {
        final def = _printers.firstWhere((p) => p.isDefault, orElse: () => _printers.first);
        _selectedPrinter = def.name;
        _useMockPrinter = def.isMock;
      }
    } catch (_) {
      // Mantém lista mínima
    } finally {
      _isSearchingPrinters = false;
      notifyListeners();
    }
  }

  Future<bool> testPrint() async {
    _isTestingPrint = true;
    _statusMessage = null;
    notifyListeners();

    try {
      final success = await apiService.printTestPage(
        printerName: _selectedPrinter,
        isMock: _useMockPrinter,
      );

      _isTestingPrint = false;
      if (success) {
        _statusMessage = _useMockPrinter
            ? 'Teste do Simulador Virtual concluído com sucesso!'
            : 'Página de teste enviada para "$_selectedPrinter"!';
        _isSuccessMessage = true;
      } else {
        _statusMessage = 'Falha ao despachar impressão de teste.';
        _isSuccessMessage = false;
      }
      notifyListeners();
      return success;
    } catch (e) {
      _isTestingPrint = false;
      _statusMessage = 'Erro na impressão de teste: $e';
      _isSuccessMessage = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveConfig() async {
    _isSaving = true;
    _statusMessage = null;
    notifyListeners();

    try {
      final updated = AdminConfigDto(
        pixKey: _pixKey.trim(),
        merchantName: _merchantName.trim(),
        merchantCity: _merchantCity.trim(),
        unitPrice: _unitPrice,
        wifiSsid: _wifiSsid.trim(),
        wifiPassword: _wifiPassword.trim(),
        customIp: _ipMode == 'manual' ? _customIp.trim() : '',
        serverPort: _serverPort,
        selectedPrinter: _selectedPrinter,
        useMockPrinter: _useMockPrinter,
      );

      final success = await apiService.saveConfig(updated);
      _isSaving = false;

      if (success) {
        _config = updated;
        _statusMessage = 'Configurações do terminal salvas com sucesso!';
        _isSuccessMessage = true;
      } else {
        _statusMessage = 'Falha ao salvar configurações no servidor.';
        _isSuccessMessage = false;
      }
      notifyListeners();
      return success;
    } catch (e) {
      _isSaving = false;
      _statusMessage = 'Erro ao salvar: $e';
      _isSuccessMessage = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleWindowsAutoStart(bool enable) async {
    final success = await WindowsStartupService.setAutoStart(enable);
    if (success) {
      _isWindowsAutoStart = enable;
      _statusMessage = enable
          ? 'Inicialização automática com o Windows ativada!'
          : 'Inicialização automática com o Windows desativada.';
      _isSuccessMessage = true;
    } else {
      _statusMessage = 'Não foi possível alterar a inicialização com o Windows.';
      _isSuccessMessage = false;
    }
    notifyListeners();
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final success = await apiService.changeAdminPassword(currentPassword, newPassword);
      if (success) {
        _statusMessage = 'Senha administrativa alterada com sucesso!';
        _isSuccessMessage = true;
      } else {
        _statusMessage = 'Senha atual incorreta ou inválida.';
        _isSuccessMessage = false;
      }
      notifyListeners();
      return success;
    } catch (e) {
      _statusMessage = 'Erro ao alterar senha: $e';
      _isSuccessMessage = false;
      notifyListeners();
      return false;
    }
  }
}
