import 'package:be_easy_server/src/database/database.dart';
import 'package:be_easy_server/src/services/print_queue_service.dart';
import 'package:be_easy_server/src/services/print_spooler_service.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  group('PrintQueueService', () {
    late AppDatabase database;
    late MockPrintSpoolerService spooler;
    late PrintQueueService queueService;

    setUp(() {
      // Base de dados SQLite in-memory para testes rápidos e isolados
      database = AppDatabase(NativeDatabase.memory());
      spooler = MockPrintSpoolerService(
        pageDelay: const Duration(milliseconds: 10), // Rápido para testes
      );
      queueService = PrintQueueService(
        database: database,
        spooler: spooler,
      );
    });

    tearDown(() async {
      queueService.dispose();
      await database.close();
    });

    test('deve enfileirar e processar trabalho com atualização de status', () async {
      final job = PrintJob(
        id: 'job-test-01',
        fileName: 'arquivo_teste.pdf',
        filePath: '/tmp/arquivo_teste.pdf',
        pageCount: 3,
        unitPrice: 2.0,
        totalPrice: 6.0,
        status: 'pending_payment',
        source: 'desktop_usb',
        pixTxid: 'TXTEST01',
        createdAt: DateTime.now(),
      );

      await database.insertJob(PrintJobsCompanion.insert(
        id: job.id,
        fileName: job.fileName,
        filePath: job.filePath,
        pageCount: job.pageCount,
        totalPrice: job.totalPrice,
        status: job.status,
        source: job.source,
        pixTxid: job.pixTxid,
        createdAt: job.createdAt,
      ));

      final events = <PrintProgressEvent>[];
      final subscription = queueService.progressStream.listen(events.add);

      await queueService.enqueue(job);

      // Aguarda a simulação rápida das 3 páginas
      await Future.delayed(const Duration(milliseconds: 1200));

      final updated = await database.getJobById(job.id);
      expect(updated?.status, 'completed');
      expect(updated?.printedAt, isNotNull);

      // Verifica se os eventos de progresso foram emitidos
      expect(events.isNotEmpty, isTrue);
      expect(events.any((e) => e.isCompleted), isTrue);

      await subscription.cancel();
    });
  });
}
