import 'dart:async';
import 'dart:io';

/// Evento emitido durante o ciclo de vida da impressão
class PrintProgressEvent {
  final String jobId;
  final int currentPage;
  final int totalPages;
  final double progress; // 0.0 a 1.0
  final String statusText;
  final bool isCompleted;
  final bool isError;
  final String? errorMessage;

  PrintProgressEvent({
    required this.jobId,
    required this.currentPage,
    required this.totalPages,
    required this.progress,
    required this.statusText,
    this.isCompleted = false,
    this.isError = false,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
    'jobId': jobId,
    'currentPage': currentPage,
    'totalPages': totalPages,
    'progress': progress,
    'statusText': statusText,
    'isCompleted': isCompleted,
    'isError': isError,
    if (errorMessage != null) 'errorMessage': errorMessage,
  };
}

/// Interface abstrata para o Spooler de Impressão do Sistema
abstract class PrintSpoolerService {
  Stream<PrintProgressEvent> get progressStream;

  Future<bool> printDocument({
    required String jobId,
    required String filePath,
    required int totalPages,
    int copies = 1,
  });
}

/// Spooler Virtual/Mock para demonstração realista sem impressora física conectada.
/// Simula o progresso folha a folha correspondente ao protótipo Stitch (Tela 5).
class MockPrintSpoolerService implements PrintSpoolerService {
  final _controller = StreamController<PrintProgressEvent>.broadcast();
  final Duration pageDelay;

  MockPrintSpoolerService({
    this.pageDelay = const Duration(milliseconds: 600),
  });

  @override
  Stream<PrintProgressEvent> get progressStream => _controller.stream;

  @override
  Future<bool> printDocument({
    required String jobId,
    required String filePath,
    required int totalPages,
    int copies = 1,
  }) async {
    final pagesToPrint = totalPages <= 0 ? 1 : totalPages;

    _controller.add(PrintProgressEvent(
      jobId: jobId,
      currentPage: 0,
      totalPages: pagesToPrint,
      progress: 0.0,
      statusText: 'Iniciando spooler e aquecendo impressora...',
    ));

    await Future.delayed(const Duration(milliseconds: 800));

    for (var page = 1; page <= pagesToPrint; page++) {
      final progress = page / pagesToPrint;
      _controller.add(PrintProgressEvent(
        jobId: jobId,
        currentPage: page,
        totalPages: pagesToPrint,
        progress: progress,
        statusText: 'Imprimindo página $page de $pagesToPrint...',
      ));
      await Future.delayed(pageDelay);
    }

    _controller.add(PrintProgressEvent(
      jobId: jobId,
      currentPage: pagesToPrint,
      totalPages: pagesToPrint,
      progress: 1.0,
      statusText: 'Todas as $pagesToPrint páginas impressas com sucesso!',
      isCompleted: true,
    ));

    return true;
  }
}

/// Spooler Nativo do Sistema Operacional (macOS/Linux via `lpr`/`lp` e Windows via Spooler CLI)
class SystemPrintSpoolerService implements PrintSpoolerService {
  final _controller = StreamController<PrintProgressEvent>.broadcast();
  String? printerName;

  SystemPrintSpoolerService({this.printerName});

  @override
  Stream<PrintProgressEvent> get progressStream => _controller.stream;

  @override
  Future<bool> printDocument({
    required String jobId,
    required String filePath,
    required int totalPages,
    int copies = 1,
  }) async {
    _controller.add(PrintProgressEvent(
      jobId: jobId,
      currentPage: 0,
      totalPages: totalPages,
      progress: 0.1,
      statusText: 'Enviando documento para a fila do sistema...',
    ));

    try {
      ProcessResult result;
      if (Platform.isMacOS || Platform.isLinux) {
        final args = <String>[];
        if (printerName != null && printerName!.isNotEmpty) {
          args.addAll(['-P', printerName!]);
        }
        args.addAll([
          '-#', '$copies',
          '-o', 'fit-to-page',
          filePath,
        ]);
        result = await Process.run('lpr', args);
      } else if (Platform.isWindows) {
        final printerArg = (printerName != null && printerName!.isNotEmpty)
            ? ' -ArgumentList "$printerName"'
            : '';
        result = await Process.run('powershell', [
          '-Command',
          'Start-Process -FilePath "$filePath" -Verb PrintTo$printerArg',
        ]);
      } else {
        throw UnsupportedError('Plataforma não suportada para impressão direta.');
      }

      if (result.exitCode == 0) {
        _controller.add(PrintProgressEvent(
          jobId: jobId,
          currentPage: totalPages,
          totalPages: totalPages,
          progress: 1.0,
          statusText: 'Enviado para a impressora física com sucesso!',
          isCompleted: true,
        ));
        return true;
      } else {
        final err = result.stderr.toString();
        _controller.add(PrintProgressEvent(
          jobId: jobId,
          currentPage: 0,
          totalPages: totalPages,
          progress: 0.0,
          statusText: 'Erro ao despachar impressão no sistema',
          isError: true,
          errorMessage: err.isNotEmpty ? err : 'Falha no comando lpr',
        ));
        return false;
      }
    } catch (e) {
      _controller.add(PrintProgressEvent(
        jobId: jobId,
        currentPage: 0,
        totalPages: totalPages,
        progress: 0.0,
        statusText: 'Exceção de I/O na impressora: $e',
        isError: true,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }
}
