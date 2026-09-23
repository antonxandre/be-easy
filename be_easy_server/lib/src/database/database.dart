import 'dart:ffi';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/open.dart';

part 'database.g.dart';

/// Configura o carregamento da biblioteca nativa SQLite no Windows
/// para garantir o uso da sqlite3.dll atualizada e evitar erro code 127 (sqlite3_stmt_isexplain).
void setupSqliteLibrary() {
  if (!Platform.isWindows) return;

  open.overrideFor(OperatingSystem.windows, () {
    final exeDir = p.dirname(Platform.resolvedExecutable);
    String? scriptDir;
    try {
      if (Platform.script.isScheme('file')) {
        scriptDir = p.dirname(Platform.script.toFilePath());
      }
    } catch (_) {}

    final possibleLocations = [
      p.join(Directory.current.path, 'sqlite3.dll'),
      p.join(exeDir, 'sqlite3.dll'),
      if (scriptDir != null) ...[
        p.join(scriptDir, 'sqlite3.dll'),
        p.join(scriptDir, '..', 'sqlite3.dll'),
      ],
      p.join(Directory.current.path, 'be_easy_server', 'sqlite3.dll'),
      p.join(Directory.current.parent.path, 'be_easy_server', 'sqlite3.dll'),
      p.join(Directory.current.path, 'be_easy_app', 'sqlite3.dll'),
      p.join(exeDir, 'data', 'flutter_assets', 'sqlite3.dll'),
    ];

    for (final loc in possibleLocations) {
      final f = File(loc);
      if (f.existsSync()) {
        try {
          return DynamicLibrary.open(f.path);
        } catch (_) {}
      }
    }

    try {
      return DynamicLibrary.open('sqlite3.dll');
    } catch (_) {
      return DynamicLibrary.open('winsqlite3.dll');
    }
  });
}

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
    setupSqliteLibrary();
    return LazyDatabase(() async {
      final dbFolder = Directory(p.join(Directory.current.path, 'data'));
      if (!await dbFolder.exists()) {
        await dbFolder.create(recursive: true);
      }
      final file = File(p.join(dbFolder.path, 'be_easy_print.sqlite'));
      return NativeDatabase.createInBackground(
        file,
        isolateSetup: setupSqliteLibrary,
      );
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
