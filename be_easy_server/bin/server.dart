import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:be_easy_server/src/database/database.dart';
import 'package:be_easy_server/src/server.dart';
import 'package:be_easy_server/src/services/pdf_service.dart';
import 'package:be_easy_server/src/services/pix_service.dart';
import 'package:be_easy_server/src/services/print_queue_service.dart';
import 'package:be_easy_server/src/services/print_spooler_service.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Mostra esta mensagem de ajuda')
    ..addOption('port', abbr: 'p', defaultsTo: '8080', help: 'Porta HTTP do servidor')
    ..addOption('unit-price', defaultsTo: '2.0', help: r'Preço padrão por página em R$')
    ..addFlag('mock-printer', defaultsTo: true, help: 'Usar spooler simulado para testes offline (ou --no-mock-printer)')
    ..addOption('pix-key', defaultsTo: '65717703000180', help: 'Chave PIX da loja (CNPJ, CPF, e-mail, telefone ou chave aleatória)')
    ..addOption('merchant-name', defaultsTo: 'BE EASY PRINT', help: 'Nome do recebedor PIX')
    ..addOption('merchant-city', defaultsTo: 'SAO PAULO', help: 'Cidade do recebedor PIX');

  // Normaliza argumentos booleanos passados como --flag=true ou --flag=false
  final normalizedArgs = arguments.map((arg) {
    if (arg == '--mock-printer=true' || arg == '--mock-printer=1') {
      return '--mock-printer';
    }
    if (arg == '--mock-printer=false' || arg == '--mock-printer=0') {
      return '--no-mock-printer';
    }
    return arg;
  }).toList();

  ArgResults results;
  try {
    results = parser.parse(normalizedArgs);
  } on FormatException catch (e) {
    stderr.writeln('Erro de argumento: ${e.message}\n');
    stderr.writeln('Uso:\n${parser.usage}');
    exitCode = 64;
    return;
  }

  if (results.flag('help')) {
    stdout.writeln('=== be EASY Print - Servidor Local ===');
    stdout.writeln(parser.usage);
    return;
  }

  final port = int.tryParse(results.option('port') ?? '') ?? 8080;
  final useMock = results.flag('mock-printer');

  var unitPrice = double.tryParse(results.option('unit-price') ?? '') ?? 2.0;
  var pixKey = results.option('pix-key') ?? '65717703000180';
  var merchantName = results.option('merchant-name') ?? 'BE EASY PRINT';
  var merchantCity = results.option('merchant-city') ?? 'SAO PAULO';

  var adminPassword = 'BeEasy@2026';
  var wifiSsid = 'BE EASY - TEFNet_5g';
  var wifiPassword = 'clientebeeasy7789@';
  var customIp = '';
  var selectedPrinter = '';
  var useMockPrinter = useMock;

  // Carrega config.json se disponível
  final configCandidates = [
    File(p.join(p.dirname(Platform.resolvedExecutable), 'config.json')),
    File('config.json'),
    File('be_easy_server/config.json'),
    File('../config.json'),
  ];
  for (final cf in configCandidates) {
    if (cf.existsSync()) {
      try {
        final content = jsonDecode(cf.readAsStringSync()) as Map<String, dynamic>;
        if (content['pixKey'] != null && results.wasParsed('pix-key') == false) {
          pixKey = content['pixKey'] as String;
        }
        if (content['merchantName'] != null && results.wasParsed('merchant-name') == false) {
          merchantName = content['merchantName'] as String;
        }
        if (content['merchantCity'] != null && results.wasParsed('merchant-city') == false) {
          merchantCity = content['merchantCity'] as String;
        }
        if (content['unitPrice'] != null && results.wasParsed('unit-price') == false) {
          unitPrice = (content['unitPrice'] as num).toDouble();
        }
        if (content['adminPassword'] != null) adminPassword = content['adminPassword'] as String;
        if (content['wifiSsid'] != null) wifiSsid = content['wifiSsid'] as String;
        if (content['wifiPassword'] != null) wifiPassword = content['wifiPassword'] as String;
        if (content['customIp'] != null) customIp = content['customIp'] as String;
        if (content['selectedPrinter'] != null) selectedPrinter = content['selectedPrinter'] as String;
        if (content['useMockPrinter'] != null) useMockPrinter = content['useMockPrinter'] as bool;
        print('Configuração carregada de: ${cf.path}');
        break;
      } catch (_) {}
    }
  }

  print('=== be EASY Print - Servidor Local ===');
  print('Chave PIX configurada: $pixKey ($merchantName - $merchantCity)');
  print('Inicializando banco de dados local Drift (SQLite)...');
  final database = AppDatabase();

  final pdfService = PdfService();
  final pixService = PixService(
    pixKey: pixKey,
    merchantName: merchantName,
    merchantCity: merchantCity,
  );

  final PrintSpoolerService spooler = useMockPrinter
      ? MockPrintSpoolerService()
      : SystemPrintSpoolerService(printerName: selectedPrinter.isNotEmpty ? selectedPrinter : null);

  print('Spooler configurado: ${spooler.runtimeType}');

  final printQueue = PrintQueueService(
    database: database,
    spooler: spooler,
  );

  final server = BeEasyServer(
    port: port,
    database: database,
    pdfService: pdfService,
    pixService: pixService,
    printQueue: printQueue,
    defaultUnitPrice: unitPrice,
    adminPassword: adminPassword,
    wifiSsid: wifiSsid,
    wifiPassword: wifiPassword,
    customIp: customIp,
    selectedPrinter: selectedPrinter,
    useMockPrinter: useMockPrinter,
  );

  await server.start();

  ProcessSignal.sigint.watch().listen((_) async {
    print('\nEncerrando servidor be EASY Print...');
    await server.stop();
    printQueue.dispose();
    await database.close();
    exit(0);
  });
}
