import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

/// Tabela de histórico de impressões e controle de fila
class PrintJobs extends Table {
  TextColumn get id => text()();
  TextColumn get fileName => text()();
  TextColumn get filePath => text()();
  IntColumn get pageCount => integer()();
  RealColumn get unitPrice => real().withDefault(const Constant(2.0))();
  RealColumn get totalPrice => real()();
  TextColumn get status => text()(); // received, pending_payment, queued, printing, completed, failed
  TextColumn get source => text()(); // desktop_usb, mobile_web
  TextColumn get pixTxid => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get printedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabela de logs de auditoria e conferência diária do honest market
class AuditLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get event => text()();
  TextColumn get details => text()();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [PrintJobs, AuditLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = Directory(p.join(Directory.current.path, 'data'));
      if (!await dbFolder.exists()) {
        await dbFolder.create(recursive: true);
      }
      final file = File(p.join(dbFolder.path, 'be_easy_print.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }

  // Consultas utilitárias para PrintJobs
  Future<List<PrintJob>> getAllJobs() => select(printJobs).get();

  Future<PrintJob?> getJobById(String id) =>
      (select(printJobs)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertJob(PrintJobsCompanion job) => into(printJobs).insert(job);

  Future<bool> updateJobStatus(String id, String status, {DateTime? printedAt}) async {
    final query = update(printJobs)..where((t) => t.id.equals(id));
    final count = await query.write(PrintJobsCompanion(
      status: Value(status),
      printedAt: Value(printedAt),
    ));
    return count > 0;
  }

  // Logs de auditoria
  Future<void> logEvent(String event, String details) async {
    await into(auditLogs).insert(AuditLogsCompanion.insert(
      event: event,
      details: details,
      createdAt: DateTime.now(),
    ));
  }
}
