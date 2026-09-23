// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PrintJobsTable extends PrintJobs
    with TableInfo<$PrintJobsTable, PrintJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrintJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileNameMeta =
      const VerificationMeta('fileName');
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
      'file_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pageCountMeta =
      const VerificationMeta('pageCount');
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
      'page_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unitPriceMeta =
      const VerificationMeta('unitPrice');
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
      'unit_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(2.0));
  static const VerificationMeta _totalPriceMeta =
      const VerificationMeta('totalPrice');
  @override
  late final GeneratedColumn<double> totalPrice = GeneratedColumn<double>(
      'total_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pixTxidMeta =
      const VerificationMeta('pixTxid');
  @override
  late final GeneratedColumn<String> pixTxid = GeneratedColumn<String>(
      'pix_txid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _printedAtMeta =
      const VerificationMeta('printedAt');
  @override
  late final GeneratedColumn<DateTime> printedAt = GeneratedColumn<DateTime>(
      'printed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        fileName,
        filePath,
        pageCount,
        unitPrice,
        totalPrice,
        status,
        source,
        pixTxid,
        createdAt,
        printedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'print_jobs';
  @override
  VerificationContext validateIntegrity(Insertable<PrintJob> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(_fileNameMeta,
          fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta));
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('page_count')) {
      context.handle(_pageCountMeta,
          pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta));
    } else if (isInserting) {
      context.missing(_pageCountMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(_unitPriceMeta,
          unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta));
    }
    if (data.containsKey('total_price')) {
      context.handle(
          _totalPriceMeta,
          totalPrice.isAcceptableOrUnknown(
              data['total_price']!, _totalPriceMeta));
    } else if (isInserting) {
      context.missing(_totalPriceMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('pix_txid')) {
      context.handle(_pixTxidMeta,
          pixTxid.isAcceptableOrUnknown(data['pix_txid']!, _pixTxidMeta));
    } else if (isInserting) {
      context.missing(_pixTxidMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('printed_at')) {
      context.handle(_printedAtMeta,
          printedAt.isAcceptableOrUnknown(data['printed_at']!, _printedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PrintJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrintJob(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fileName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_name'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      pageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_count'])!,
      unitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_price'])!,
      totalPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_price'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      pixTxid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pix_txid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      printedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}printed_at']),
    );
  }

  @override
  $PrintJobsTable createAlias(String alias) {
    return $PrintJobsTable(attachedDatabase, alias);
  }
}

class PrintJob extends DataClass implements Insertable<PrintJob> {
  final String id;
  final String fileName;
  final String filePath;
  final int pageCount;
  final double unitPrice;
  final double totalPrice;
  final String status;
  final String source;
  final String pixTxid;
  final DateTime createdAt;
  final DateTime? printedAt;
  const PrintJob(
      {required this.id,
      required this.fileName,
      required this.filePath,
      required this.pageCount,
      required this.unitPrice,
      required this.totalPrice,
      required this.status,
      required this.source,
      required this.pixTxid,
      required this.createdAt,
      this.printedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['file_name'] = Variable<String>(fileName);
    map['file_path'] = Variable<String>(filePath);
    map['page_count'] = Variable<int>(pageCount);
    map['unit_price'] = Variable<double>(unitPrice);
    map['total_price'] = Variable<double>(totalPrice);
    map['status'] = Variable<String>(status);
    map['source'] = Variable<String>(source);
    map['pix_txid'] = Variable<String>(pixTxid);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || printedAt != null) {
      map['printed_at'] = Variable<DateTime>(printedAt);
    }
    return map;
  }

  PrintJobsCompanion toCompanion(bool nullToAbsent) {
    return PrintJobsCompanion(
      id: Value(id),
      fileName: Value(fileName),
      filePath: Value(filePath),
      pageCount: Value(pageCount),
      unitPrice: Value(unitPrice),
      totalPrice: Value(totalPrice),
      status: Value(status),
      source: Value(source),
      pixTxid: Value(pixTxid),
      createdAt: Value(createdAt),
      printedAt: printedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(printedAt),
    );
  }

  factory PrintJob.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrintJob(
      id: serializer.fromJson<String>(json['id']),
      fileName: serializer.fromJson<String>(json['fileName']),
      filePath: serializer.fromJson<String>(json['filePath']),
      pageCount: serializer.fromJson<int>(json['pageCount']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      totalPrice: serializer.fromJson<double>(json['totalPrice']),
      status: serializer.fromJson<String>(json['status']),
      source: serializer.fromJson<String>(json['source']),
      pixTxid: serializer.fromJson<String>(json['pixTxid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      printedAt: serializer.fromJson<DateTime?>(json['printedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fileName': serializer.toJson<String>(fileName),
      'filePath': serializer.toJson<String>(filePath),
      'pageCount': serializer.toJson<int>(pageCount),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'totalPrice': serializer.toJson<double>(totalPrice),
      'status': serializer.toJson<String>(status),
      'source': serializer.toJson<String>(source),
      'pixTxid': serializer.toJson<String>(pixTxid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'printedAt': serializer.toJson<DateTime?>(printedAt),
    };
  }

  PrintJob copyWith(
          {String? id,
          String? fileName,
          String? filePath,
          int? pageCount,
          double? unitPrice,
          double? totalPrice,
          String? status,
          String? source,
          String? pixTxid,
          DateTime? createdAt,
          Value<DateTime?> printedAt = const Value.absent()}) =>
      PrintJob(
        id: id ?? this.id,
        fileName: fileName ?? this.fileName,
        filePath: filePath ?? this.filePath,
        pageCount: pageCount ?? this.pageCount,
        unitPrice: unitPrice ?? this.unitPrice,
        totalPrice: totalPrice ?? this.totalPrice,
        status: status ?? this.status,
        source: source ?? this.source,
        pixTxid: pixTxid ?? this.pixTxid,
        createdAt: createdAt ?? this.createdAt,
        printedAt: printedAt.present ? printedAt.value : this.printedAt,
      );
  PrintJob copyWithCompanion(PrintJobsCompanion data) {
    return PrintJob(
      id: data.id.present ? data.id.value : this.id,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      totalPrice:
          data.totalPrice.present ? data.totalPrice.value : this.totalPrice,
      status: data.status.present ? data.status.value : this.status,
      source: data.source.present ? data.source.value : this.source,
      pixTxid: data.pixTxid.present ? data.pixTxid.value : this.pixTxid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      printedAt: data.printedAt.present ? data.printedAt.value : this.printedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrintJob(')
          ..write('id: $id, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('pageCount: $pageCount, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('status: $status, ')
          ..write('source: $source, ')
          ..write('pixTxid: $pixTxid, ')
          ..write('createdAt: $createdAt, ')
          ..write('printedAt: $printedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fileName, filePath, pageCount, unitPrice,
      totalPrice, status, source, pixTxid, createdAt, printedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrintJob &&
          other.id == this.id &&
          other.fileName == this.fileName &&
          other.filePath == this.filePath &&
          other.pageCount == this.pageCount &&
          other.unitPrice == this.unitPrice &&
          other.totalPrice == this.totalPrice &&
          other.status == this.status &&
          other.source == this.source &&
          other.pixTxid == this.pixTxid &&
          other.createdAt == this.createdAt &&
          other.printedAt == this.printedAt);
}

class PrintJobsCompanion extends UpdateCompanion<PrintJob> {
  final Value<String> id;
  final Value<String> fileName;
  final Value<String> filePath;
  final Value<int> pageCount;
  final Value<double> unitPrice;
  final Value<double> totalPrice;
  final Value<String> status;
  final Value<String> source;
  final Value<String> pixTxid;
  final Value<DateTime> createdAt;
  final Value<DateTime?> printedAt;
  final Value<int> rowid;
  const PrintJobsCompanion({
    this.id = const Value.absent(),
    this.fileName = const Value.absent(),
    this.filePath = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.totalPrice = const Value.absent(),
    this.status = const Value.absent(),
    this.source = const Value.absent(),
    this.pixTxid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.printedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrintJobsCompanion.insert({
    required String id,
    required String fileName,
    required String filePath,
    required int pageCount,
    this.unitPrice = const Value.absent(),
    required double totalPrice,
    required String status,
    required String source,
    required String pixTxid,
    required DateTime createdAt,
    this.printedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fileName = Value(fileName),
        filePath = Value(filePath),
        pageCount = Value(pageCount),
        totalPrice = Value(totalPrice),
        status = Value(status),
        source = Value(source),
        pixTxid = Value(pixTxid),
        createdAt = Value(createdAt);
  static Insertable<PrintJob> custom({
    Expression<String>? id,
    Expression<String>? fileName,
    Expression<String>? filePath,
    Expression<int>? pageCount,
    Expression<double>? unitPrice,
    Expression<double>? totalPrice,
    Expression<String>? status,
    Expression<String>? source,
    Expression<String>? pixTxid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? printedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fileName != null) 'file_name': fileName,
      if (filePath != null) 'file_path': filePath,
      if (pageCount != null) 'page_count': pageCount,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (totalPrice != null) 'total_price': totalPrice,
      if (status != null) 'status': status,
      if (source != null) 'source': source,
      if (pixTxid != null) 'pix_txid': pixTxid,
      if (createdAt != null) 'created_at': createdAt,
      if (printedAt != null) 'printed_at': printedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrintJobsCompanion copyWith(
      {Value<String>? id,
      Value<String>? fileName,
      Value<String>? filePath,
      Value<int>? pageCount,
      Value<double>? unitPrice,
      Value<double>? totalPrice,
      Value<String>? status,
      Value<String>? source,
      Value<String>? pixTxid,
      Value<DateTime>? createdAt,
      Value<DateTime?>? printedAt,
      Value<int>? rowid}) {
    return PrintJobsCompanion(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      pageCount: pageCount ?? this.pageCount,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      source: source ?? this.source,
      pixTxid: pixTxid ?? this.pixTxid,
      createdAt: createdAt ?? this.createdAt,
      printedAt: printedAt ?? this.printedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (totalPrice.present) {
      map['total_price'] = Variable<double>(totalPrice.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (pixTxid.present) {
      map['pix_txid'] = Variable<String>(pixTxid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (printedAt.present) {
      map['printed_at'] = Variable<DateTime>(printedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrintJobsCompanion(')
          ..write('id: $id, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('pageCount: $pageCount, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('status: $status, ')
          ..write('source: $source, ')
          ..write('pixTxid: $pixTxid, ')
          ..write('createdAt: $createdAt, ')
          ..write('printedAt: $printedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _eventMeta = const VerificationMeta('event');
  @override
  late final GeneratedColumn<String> event = GeneratedColumn<String>(
      'event', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _detailsMeta =
      const VerificationMeta('details');
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
      'details', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, event, details, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(Insertable<AuditLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event')) {
      context.handle(
          _eventMeta, event.isAcceptableOrUnknown(data['event']!, _eventMeta));
    } else if (isInserting) {
      context.missing(_eventMeta);
    }
    if (data.containsKey('details')) {
      context.handle(_detailsMeta,
          details.isAcceptableOrUnknown(data['details']!, _detailsMeta));
    } else if (isInserting) {
      context.missing(_detailsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      event: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event'])!,
      details: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}details'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final int id;
  final String event;
  final String details;
  final DateTime createdAt;
  const AuditLog(
      {required this.id,
      required this.event,
      required this.details,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['event'] = Variable<String>(event);
    map['details'] = Variable<String>(details);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      event: Value(event),
      details: Value(details),
      createdAt: Value(createdAt),
    );
  }

  factory AuditLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      id: serializer.fromJson<int>(json['id']),
      event: serializer.fromJson<String>(json['event']),
      details: serializer.fromJson<String>(json['details']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'event': serializer.toJson<String>(event),
      'details': serializer.toJson<String>(details),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AuditLog copyWith(
          {int? id, String? event, String? details, DateTime? createdAt}) =>
      AuditLog(
        id: id ?? this.id,
        event: event ?? this.event,
        details: details ?? this.details,
        createdAt: createdAt ?? this.createdAt,
      );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      id: data.id.present ? data.id.value : this.id,
      event: data.event.present ? data.event.value : this.event,
      details: data.details.present ? data.details.value : this.details,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('id: $id, ')
          ..write('event: $event, ')
          ..write('details: $details, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, event, details, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.id == this.id &&
          other.event == this.event &&
          other.details == this.details &&
          other.createdAt == this.createdAt);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<int> id;
  final Value<String> event;
  final Value<String> details;
  final Value<DateTime> createdAt;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.event = const Value.absent(),
    this.details = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    this.id = const Value.absent(),
    required String event,
    required String details,
    required DateTime createdAt,
  })  : event = Value(event),
        details = Value(details),
        createdAt = Value(createdAt);
  static Insertable<AuditLog> custom({
    Expression<int>? id,
    Expression<String>? event,
    Expression<String>? details,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (event != null) 'event': event,
      if (details != null) 'details': details,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AuditLogsCompanion copyWith(
      {Value<int>? id,
      Value<String>? event,
      Value<String>? details,
      Value<DateTime>? createdAt}) {
    return AuditLogsCompanion(
      id: id ?? this.id,
      event: event ?? this.event,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (event.present) {
      map['event'] = Variable<String>(event.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('event: $event, ')
          ..write('details: $details, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PrintJobsTable printJobs = $PrintJobsTable(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [printJobs, auditLogs];
}

typedef $$PrintJobsTableCreateCompanionBuilder = PrintJobsCompanion Function({
  required String id,
  required String fileName,
  required String filePath,
  required int pageCount,
  Value<double> unitPrice,
  required double totalPrice,
  required String status,
  required String source,
  required String pixTxid,
  required DateTime createdAt,
  Value<DateTime?> printedAt,
  Value<int> rowid,
});
typedef $$PrintJobsTableUpdateCompanionBuilder = PrintJobsCompanion Function({
  Value<String> id,
  Value<String> fileName,
  Value<String> filePath,
  Value<int> pageCount,
  Value<double> unitPrice,
  Value<double> totalPrice,
  Value<String> status,
  Value<String> source,
  Value<String> pixTxid,
  Value<DateTime> createdAt,
  Value<DateTime?> printedAt,
  Value<int> rowid,
});

class $$PrintJobsTableFilterComposer
    extends Composer<_$AppDatabase, $PrintJobsTable> {
  $$PrintJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageCount => $composableBuilder(
      column: $table.pageCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pixTxid => $composableBuilder(
      column: $table.pixTxid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get printedAt => $composableBuilder(
      column: $table.printedAt, builder: (column) => ColumnFilters(column));
}

class $$PrintJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrintJobsTable> {
  $$PrintJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageCount => $composableBuilder(
      column: $table.pageCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pixTxid => $composableBuilder(
      column: $table.pixTxid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get printedAt => $composableBuilder(
      column: $table.printedAt, builder: (column) => ColumnOrderings(column));
}

class $$PrintJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrintJobsTable> {
  $$PrintJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get pixTxid =>
      $composableBuilder(column: $table.pixTxid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get printedAt =>
      $composableBuilder(column: $table.printedAt, builder: (column) => column);
}

class $$PrintJobsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PrintJobsTable,
    PrintJob,
    $$PrintJobsTableFilterComposer,
    $$PrintJobsTableOrderingComposer,
    $$PrintJobsTableAnnotationComposer,
    $$PrintJobsTableCreateCompanionBuilder,
    $$PrintJobsTableUpdateCompanionBuilder,
    (PrintJob, BaseReferences<_$AppDatabase, $PrintJobsTable, PrintJob>),
    PrintJob,
    PrefetchHooks Function()> {
  $$PrintJobsTableTableManager(_$AppDatabase db, $PrintJobsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrintJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrintJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrintJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> fileName = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<int> pageCount = const Value.absent(),
            Value<double> unitPrice = const Value.absent(),
            Value<double> totalPrice = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String> pixTxid = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> printedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PrintJobsCompanion(
            id: id,
            fileName: fileName,
            filePath: filePath,
            pageCount: pageCount,
            unitPrice: unitPrice,
            totalPrice: totalPrice,
            status: status,
            source: source,
            pixTxid: pixTxid,
            createdAt: createdAt,
            printedAt: printedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String fileName,
            required String filePath,
            required int pageCount,
            Value<double> unitPrice = const Value.absent(),
            required double totalPrice,
            required String status,
            required String source,
            required String pixTxid,
            required DateTime createdAt,
            Value<DateTime?> printedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PrintJobsCompanion.insert(
            id: id,
            fileName: fileName,
            filePath: filePath,
            pageCount: pageCount,
            unitPrice: unitPrice,
            totalPrice: totalPrice,
            status: status,
            source: source,
            pixTxid: pixTxid,
            createdAt: createdAt,
            printedAt: printedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PrintJobsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PrintJobsTable,
    PrintJob,
    $$PrintJobsTableFilterComposer,
    $$PrintJobsTableOrderingComposer,
    $$PrintJobsTableAnnotationComposer,
    $$PrintJobsTableCreateCompanionBuilder,
    $$PrintJobsTableUpdateCompanionBuilder,
    (PrintJob, BaseReferences<_$AppDatabase, $PrintJobsTable, PrintJob>),
    PrintJob,
    PrefetchHooks Function()>;
typedef $$AuditLogsTableCreateCompanionBuilder = AuditLogsCompanion Function({
  Value<int> id,
  required String event,
  required String details,
  required DateTime createdAt,
});
typedef $$AuditLogsTableUpdateCompanionBuilder = AuditLogsCompanion Function({
  Value<int> id,
  Value<String> event,
  Value<String> details,
  Value<DateTime> createdAt,
});

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get event => $composableBuilder(
      column: $table.event, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get details => $composableBuilder(
      column: $table.details, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get event => $composableBuilder(
      column: $table.event, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get details => $composableBuilder(
      column: $table.details, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get event =>
      $composableBuilder(column: $table.event, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AuditLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AuditLogsTable,
    AuditLog,
    $$AuditLogsTableFilterComposer,
    $$AuditLogsTableOrderingComposer,
    $$AuditLogsTableAnnotationComposer,
    $$AuditLogsTableCreateCompanionBuilder,
    $$AuditLogsTableUpdateCompanionBuilder,
    (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
    AuditLog,
    PrefetchHooks Function()> {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> event = const Value.absent(),
            Value<String> details = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              AuditLogsCompanion(
            id: id,
            event: event,
            details: details,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String event,
            required String details,
            required DateTime createdAt,
          }) =>
              AuditLogsCompanion.insert(
            id: id,
            event: event,
            details: details,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AuditLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AuditLogsTable,
    AuditLog,
    $$AuditLogsTableFilterComposer,
    $$AuditLogsTableOrderingComposer,
    $$AuditLogsTableAnnotationComposer,
    $$AuditLogsTableCreateCompanionBuilder,
    $$AuditLogsTableUpdateCompanionBuilder,
    (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
    AuditLog,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PrintJobsTableTableManager get printJobs =>
      $$PrintJobsTableTableManager(_db, _db.printJobs);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
}
