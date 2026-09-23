import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/print_job_dto.dart';
import '../../../data/services/api_service.dart';

class MobileSessionViewModel extends ChangeNotifier {
  final ApiService apiService;

  int _currentStep = 0; // 0: Upload, 1: Resumo, 2: Pagamento PIX
  PrintJobDto? _currentJob;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;

  // Timer regressivo PIX (10 minutos)
  int _secondsRemaining = 600;
  Timer? _countdownTimer;

  MobileSessionViewModel({required this.apiService});

  int get currentStep => _currentStep;
  PrintJobDto? get currentJob => _currentJob;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;
  int get secondsRemaining => _secondsRemaining;

  String get formattedTimer {
    final m = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void goToStep(int step) {
    _currentStep = step;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> pickAndUploadFile() async {
    _errorMessage = null;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      _errorMessage = 'Arquivo vazio ou ilegível.';
      notifyListeners();
      return;
    }

    _isUploading = true;
    _uploadProgress = 0.2;
    notifyListeners();

    try {
      _uploadProgress = 0.6;
      notifyListeners();

      final job = await apiService.uploadPdf(
        fileName: file.name,
        bytes: bytes,
        source: 'mobile_web',
      );

      _uploadProgress = 1.0;
      _currentJob = job;
      _isUploading = false;
      _currentStep = 1; // Avança para Tela 7: Confirmação do Pedido
      notifyListeners();
    } catch (e) {
      _isUploading = false;
      _uploadProgress = 0.0;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> confirmJob() async {
    if (_currentJob == null) return;

    try {
      await apiService.confirmJob(_currentJob!.id);
      _currentStep = 2; // Avança para Tela 8: Pagamento PIX
      _startCountdown();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Falha ao confirmar impressão: $e';
      notifyListeners();
    }
  }

  void _startCountdown() {
    _secondsRemaining = 600;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  void resetSession() {
    _countdownTimer?.cancel();
    _currentStep = 0;
    _currentJob = null;
    _isUploading = false;
    _uploadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
