import 'dart:async';
import 'dart:collection';
import '../database/database.dart';
import 'print_spooler_service.dart';

/// Gerenciador de fila FIFO assíncrona para garantir que a impressora física
/// nunca receba comandos concorrentes.
class PrintQueueService {
  final AppDatabase database;
  final PrintSpoolerService spooler;

  final Queue<PrintJob> _queue = Queue<PrintJob>();
  bool _isProcessing = false;

  final StreamController<PrintProgressEvent> _eventController =
      StreamController<PrintProgressEvent>.broadcast();

  PrintQueueService({
    required this.database,
    required this.spooler,
  }) {
    // Repassa eventos do spooler para o stream global da fila
    spooler.progressStream.listen(_eventController.add);
  }

  /// Stream para acompanhamento em tempo real da impressão
  Stream<PrintProgressEvent> get progressStream => _eventController.stream;

  /// Retorna o número de trabalhos aguardando na fila
  int get queueLength => _queue.length;

  /// Retorna se há um trabalho sendo impresso agora
  bool get isPrinting => _isProcessing;

  /// Adiciona um trabalho à fila FIFO e inicia o processamento se estiver ociosa
  Future<void> enqueue(PrintJob job) async {
    _queue.add(job);
    await database.updateJobStatus(job.id, 'queued');
    await database.logEvent(
      'JOB_ENQUEUED',
      'Trabalho ${job.id} (${job.fileName} - ${job.pageCount} págs) adicionado à fila FIFO. Posição: ${_queue.length}',
    );

    _eventController.add(PrintProgressEvent(
      jobId: job.id,
      currentPage: 0,
      totalPages: job.pageCount,
      progress: 0.0,
      statusText: 'Na fila de impressão (Posição ${_queue.length})',
    ));

    _processNext();
  }

  /// Processa o próximo trabalho da fila sequencialmente
  Future<void> _processNext() async {
    if (_isProcessing || _queue.isEmpty) return;

    _isProcessing = true;
    final currentJob = _queue.removeFirst();

    try {
      await database.updateJobStatus(currentJob.id, 'printing');
      await database.logEvent(
        'JOB_PRINT_START',
        'Iniciando impressão de ${currentJob.fileName} (${currentJob.id})',
      );

      final success = await spooler.printDocument(
        jobId: currentJob.id,
        filePath: currentJob.filePath,
        totalPages: currentJob.pageCount,
      );

      if (success) {
        final now = DateTime.now();
        await database.updateJobStatus(currentJob.id, 'completed', printedAt: now);
        await database.logEvent(
          'JOB_PRINT_SUCCESS',
          'Impressão concluída com sucesso para o trabalho ${currentJob.id}',
        );
      } else {
        await database.updateJobStatus(currentJob.id, 'failed');
        await database.logEvent(
          'JOB_PRINT_FAILED',
          'Falha no envio do trabalho ${currentJob.id} ao spooler',
        );
      }
    } catch (e, stack) {
      await database.updateJobStatus(currentJob.id, 'failed');
      await database.logEvent(
        'JOB_PRINT_EXCEPTION',
        'Exceção ao imprimir ${currentJob.id}: $e\n$stack',
      );
      _eventController.add(PrintProgressEvent(
        jobId: currentJob.id,
        currentPage: 0,
        totalPages: currentJob.pageCount,
        progress: 0.0,
        statusText: 'Erro ao processar impressão: $e',
        isError: true,
        errorMessage: e.toString(),
      ));
    } finally {
      _isProcessing = false;
      // Processa o próximo item se houver
      if (_queue.isNotEmpty) {
        _processNext();
      }
    }
  }

  void dispose() {
    _eventController.close();
  }
}
