import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:drift/drift.dart' show Value;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:uuid/uuid.dart';

import 'database/database.dart';
import 'services/pdf_service.dart';
import 'services/pix_service.dart';
import 'services/print_queue_service.dart';
import 'services/printer_service.dart';
import 'utils/network_helper.dart';

/// Servidor HTTP Shelf para o ambiente local do computador da loja.
class BeEasyServer {
  final int port;
  final AppDatabase database;
  final PdfService pdfService;
  final PixService pixService;
  final PrintQueueService printQueue;
  final PrinterService printerService;
  final String uploadsDir;
  final String? webAssetsPath;

  double unitPrice;
  String adminPassword;
  String wifiSsid;
  String wifiPassword;
  String customIp;
  String selectedPrinter;
  bool useMockPrinter;

  HttpServer? _server;

  BeEasyServer({
    this.port = 8080,
    required this.database,
    required this.pdfService,
    required this.pixService,
    required this.printQueue,
    PrinterService? printerService,
    double defaultUnitPrice = 2.0,
    String adminPassword = 'BeEasy@2026',
    String wifiSsid = 'BE EASY - TEFNet_5g',
    String wifiPassword = 'clientebeeasy7789@',
    String customIp = '',
    String selectedPrinter = '',
    bool useMockPrinter = true,
    this.uploadsDir = 'uploads',
    this.webAssetsPath,
  })  : printerService = printerService ?? PrinterService(),
        unitPrice = defaultUnitPrice,
        adminPassword = adminPassword,
        wifiSsid = wifiSsid,
        wifiPassword = wifiPassword,
        customIp = customIp,
        selectedPrinter = selectedPrinter,
        useMockPrinter = useMockPrinter;

  /// Inicializa o servidor localmente
  Future<void> start() async {
    final uploadFolder = Directory(p.join(Directory.current.path, uploadsDir));
    if (!await uploadFolder.exists()) {
      await uploadFolder.create(recursive: true);
    }

    final router = Router();

    // Endpoints da API REST
    router.get('/api/status', _handleStatus);
    router.get('/api/network/ip', _handleGetLocalIp);
    router.get('/api/config', _handleGetConfig);
    router.post('/api/config', _handleUpdateConfig);
    router.post('/api/admin/verify', _handleVerifyAdminPassword);
    router.post('/api/admin/change-password', _handleChangeAdminPassword);
    router.get('/api/printers', _handleGetPrinters);
    router.post('/api/printers/test', _handleTestPrinter);
    router.post('/api/upload', _handleUpload);
    router.get('/api/jobs/<id>', _handleGetJob);
    router.post('/api/jobs/<id>/confirm', _handleConfirmJob);
    router.get('/api/jobs/<id>/stream', _handleJobStream);
    router.get('/api/jobs', _handleGetAllJobs);

    // Procura o diretório de build web em múltiplos caminhos candidatos
    final exeDir = p.dirname(Platform.resolvedExecutable);
    final candidatePaths = [
      if (webAssetsPath != null) webAssetsPath!,
      p.join(exeDir, 'web'),
      p.join(exeDir, 'data', 'flutter_assets', 'web'),
      p.join(Directory.current.path, 'web'),
      p.join(Directory.current.path, 'be_easy_server', 'web'),
      p.join(Directory.current.path, 'be_easy_app', 'build', 'web'),
      p.join(Directory.current.path, 'build', 'web'),
      p.join(Directory.current.parent.path, 'be_easy_server', 'web'),
      p.join(Directory.current.parent.path, 'be_easy_app', 'build', 'web'),
    ];

    Directory? webDir;
    for (final path in candidatePaths) {
      final dir = Directory(path);
      if (await dir.exists() && await File(p.join(dir.path, 'index.html')).exists()) {
        webDir = dir;
        break;
      }
    }

    Handler staticHandler;
    if (webDir != null) {
      print('Servindo Web App a partir de: ${webDir.path}');
      final fileHandler = createStaticHandler(
        webDir.path,
        defaultDocument: 'index.html',
      );
      final indexHtmlFile = File(p.join(webDir.path, 'index.html'));

      staticHandler = (Request req) async {
        // Ignora requisições de API para não mascarar endpoints
        if (req.url.path.startsWith('api/')) {
          return Response.notFound('Endpoint API não encontrado.');
        }

        // Tenta servir o arquivo estático diretamente (ex: /flutter.js, /main.dart.js, /assets/...)
        final response = await fileHandler(req);
        if (response.statusCode != 404) {
          return response;
        }

        // SPA Fallback: Rotas do client web (ex: /app, /mobile, /desktop) recebem o index.html
        if (await indexHtmlFile.exists()) {
          return Response.ok(
            indexHtmlFile.openRead(),
            headers: {
              'content-type': 'text/html; charset=utf-8',
              'cache-control': 'no-cache',
            },
          );
        }

        return response;
      };
    } else {
      staticHandler = (Request req) {
        return Response.ok(
          '<!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">'
          '<title>be EASY Print</title>'
          '<style>body{font-family:sans-serif;padding:24px;text-align:center;color:#2C2C2C;background:#FAFAFA}'
          '.box{max-width:440px;margin:40px auto;padding:24px;background:#FFF;border-radius:16px;box-shadow:0 4px 12px rgba(0,0,0,0.08)}'
          'h1{color:#709A28;font-size:22px}p{font-size:14px;color:#666;line-height:1.5}</style></head>'
          '<body><div class="box"><h1>be EASY Print</h1><p>Conectado ao computador da loja com sucesso!</p>'
          '<p>Aguardando disponibilização dos arquivos web compilados.</p></div></body></html>',
          headers: {'content-type': 'text/html; charset=utf-8'},
        );
      };
    }

    // Pipeline com CORS habilitado para requisições do celular na rede local
    final cascade = Cascade().add(router.call).add(staticHandler);

    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(corsHeaders(
          headers: {
            ACCESS_CONTROL_ALLOW_ORIGIN: '*',
            ACCESS_CONTROL_ALLOW_METHODS: 'GET, POST, OPTIONS',
            ACCESS_CONTROL_ALLOW_HEADERS: 'Origin, Content-Type, Accept, Authorization',
          },
        ))
        .addHandler(cascade.handler);

    _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
    print('Servidor be EASY Print rodando em: http://${_server!.address.host}:${_server!.port}');
  }

  Future<void> stop() async {
    await _server?.close(force: true);
  }

  // --- Handlers ---

  Future<Response> _handleStatus(Request request) async {
    final localIp = await getLocalIp();
    return Response.ok(
      jsonEncode({
        'status': 'online',
        'service': 'be_easy_server',
        'version': '1.0.0',
        'localIp': localIp,
        'port': port,
        'queueLength': printQueue.queueLength,
        'isPrinting': printQueue.isPrinting,
      }),
      headers: {'content-type': 'application/json'},
    );
  }

  Future<Response> _handleGetLocalIp(Request request) async {
    final ipToUse = customIp.isNotEmpty ? customIp : await getLocalIp();
    return Response.ok(
      jsonEncode({
        'ip': ipToUse,
        'port': port,
        'webUrl': 'http://$ipToUse:$port/app',
      }),
      headers: {'content-type': 'application/json'},
    );
  }

  File? _findConfigFile() {
    final candidatePaths = [
      'config.json',
      'be_easy_server/config.json',
      '../config.json',
      p.join(Directory.current.path, 'config.json'),
      p.join(Directory.current.path, 'be_easy_server', 'config.json'),
      p.join(Directory.current.parent.path, 'config.json'),
    ];
    for (final path in candidatePaths) {
      final f = File(path);
      if (f.existsSync()) return f;
    }
    return File('config.json');
  }

  void _saveConfig() {
    try {
      final file = _findConfigFile();
      Map<String, dynamic> current = {};
      if (file != null && file.existsSync()) {
        try {
          current = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        } catch (_) {}
      }
      current['pixKey'] = pixService.pixKey;
      current['merchantName'] = pixService.merchantName;
      current['merchantCity'] = pixService.merchantCity;
      current['unitPrice'] = unitPrice;
      current['adminPassword'] = adminPassword;
      current['wifiSsid'] = wifiSsid;
      current['wifiPassword'] = wifiPassword;
      current['customIp'] = customIp;
      current['serverPort'] = port;
      current['selectedPrinter'] = selectedPrinter;
      current['useMockPrinter'] = useMockPrinter;

      final updatedJson = const JsonEncoder.withIndent('  ').convert(current);
      file?.writeAsStringSync(updatedJson);

      final otherCandidatePaths = [
        'config.json',
        'be_easy_server/config.json',
        '../config.json',
        'be_easy_app/config.json',
        '../be_easy_app/config.json',
      ];
      for (final pth in otherCandidatePaths) {
        final f = File(pth);
        if (f.existsSync() && f.path != file?.path) {
          try {
            f.writeAsStringSync(updatedJson);
          } catch (_) {}
        }
      }
    } catch (e) {
      print('Aviso: falha ao salvar config.json: $e');
    }
  }

  Future<Response> _handleGetConfig(Request request) async {
    return Response.ok(
      jsonEncode({
        'pixKey': pixService.pixKey,
        'merchantName': pixService.merchantName,
        'merchantCity': pixService.merchantCity,
        'unitPrice': unitPrice,
        'wifiSsid': wifiSsid,
        'wifiPassword': wifiPassword,
        'customIp': customIp,
        'serverPort': port,
        'selectedPrinter': selectedPrinter,
        'useMockPrinter': useMockPrinter,
        'hasAdminPassword': adminPassword.isNotEmpty,
      }),
      headers: {'content-type': 'application/json'},
    );
  }

  Future<Response> _handleUpdateConfig(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      if (json['pixKey'] != null || json['merchantName'] != null || json['merchantCity'] != null) {
        pixService.updateConfig(
          key: json['pixKey'] as String?,
          name: json['merchantName'] as String?,
          city: json['merchantCity'] as String?,
        );
      }
      if (json['unitPrice'] != null) {
        unitPrice = (json['unitPrice'] as num).toDouble();
      }
      if (json['wifiSsid'] != null) {
        wifiSsid = json['wifiSsid'] as String;
      }
      if (json['wifiPassword'] != null) {
        wifiPassword = json['wifiPassword'] as String;
      }
      if (json.containsKey('customIp')) {
        customIp = json['customIp'] as String? ?? '';
      }
      if (json.containsKey('selectedPrinter')) {
        selectedPrinter = json['selectedPrinter'] as String? ?? '';
      }
      if (json.containsKey('useMockPrinter')) {
        useMockPrinter = json['useMockPrinter'] as bool? ?? true;
      }

      _saveConfig();

      return Response.ok(
        jsonEncode({
          'success': true,
          'pixKey': pixService.pixKey,
          'merchantName': pixService.merchantName,
          'merchantCity': pixService.merchantCity,
          'unitPrice': unitPrice,
          'wifiSsid': wifiSsid,
          'wifiPassword': wifiPassword,
          'customIp': customIp,
          'serverPort': port,
          'selectedPrinter': selectedPrinter,
          'useMockPrinter': useMockPrinter,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Erro ao atualizar configuração: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _handleVerifyAdminPassword(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final password = json['password'] as String? ?? '';

      final isValid = password == adminPassword;
      return Response.ok(
        jsonEncode({
          'success': isValid,
          if (!isValid) 'error': 'Senha incorreta.',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({'success': false, 'error': 'Requisição inválida: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _handleChangeAdminPassword(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final currentPass = json['currentPassword'] as String? ?? '';
      final newPass = json['newPassword'] as String? ?? '';

      if (currentPass != adminPassword) {
        return Response(
          403,
          body: jsonEncode({'success': false, 'error': 'A senha atual está incorreta.'}),
          headers: {'content-type': 'application/json'},
        );
      }

      if (newPass.length < 4) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'error': 'A nova senha deve ter pelo menos 4 caracteres.'}),
          headers: {'content-type': 'application/json'},
        );
      }

      adminPassword = newPass;
      _saveConfig();

      return Response.ok(
        jsonEncode({'success': true, 'message': 'Senha de administrador alterada com sucesso.'}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({'success': false, 'error': 'Erro ao alterar senha: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _handleGetPrinters(Request request) async {
    try {
      final printers = await printerService.getAvailablePrinters();
      final list = printers.map((p) => p.toJson()).toList();
      return Response.ok(
        jsonEncode(list),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erro ao buscar impressoras: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _handleTestPrinter(Request request) async {
    try {
      final body = await request.readAsString();
      final json = body.isNotEmpty ? jsonDecode(body) as Map<String, dynamic> : <String, dynamic>{};

      final targetPrinter = json['printerName'] as String? ?? selectedPrinter;
      final isMock = json['isMock'] as bool? ?? (targetPrinter.isEmpty || useMockPrinter);

      final success = await printerService.printTestPage(
        printerName: targetPrinter,
        isMock: isMock,
      );

      return Response.ok(
        jsonEncode({
          'success': success,
          'printerName': targetPrinter,
          'isMock': isMock,
          'message': success
              ? 'Página de teste enviada com sucesso!'
              : 'Falha ao enviar página de teste para a impressora.',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erro ao disparar impressão de teste: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _handleUpload(Request request) async {
    final contentType = request.headers['content-type'];
    if (contentType == null || !contentType.contains('multipart/form-data')) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Requisição deve ser multipart/form-data.'}),
        headers: {'content-type': 'application/json'},
      );
    }

    try {
      final mediaType = MediaType.parse(contentType);
      final boundary = mediaType.parameters['boundary'];
      if (boundary == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Boundary multipart não especificado.'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final transformer = MimeMultipartTransformer(boundary);
      final parts = transformer.bind(request.read());

      String? originalFileName;
      Uint8List? fileBytes;
      String source = 'mobile_web';

      await for (final part in parts) {
        final contentDisposition = part.headers['content-disposition'];
        if (contentDisposition != null) {
          final cdParams = HeaderValue.parse(contentDisposition);
          final fieldName = cdParams.parameters['name'];

          if (fieldName == 'file') {
            originalFileName = cdParams.parameters['filename'] ?? 'documento.pdf';
            final chunks = await part.fold<List<int>>([], (prev, chunk) => prev..addAll(chunk));
            fileBytes = Uint8List.fromList(chunks);
          } else if (fieldName == 'source') {
            final text = await utf8.decodeStream(part);
            source = text.trim();
          }
        }
      }

      if (fileBytes == null || fileBytes.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Nenhum arquivo enviado no campo "file".'}),
          headers: {'content-type': 'application/json'},
        );
      }

      // Validação de segurança: Magic Bytes %PDF-
      if (!pdfService.isValidPdfBytes(fileBytes)) {
        return Response(
          422,
          body: jsonEncode({
            'error': 'Arquivo inválido. O documento enviado não possui assinatura binária de PDF genuíno (%PDF-).'
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      // Cálculo de páginas
      final pageCount = pdfService.countPages(fileBytes);
      final totalPrice = pageCount * unitPrice;

      // Salvamento seguro no diretório de uploads do computador
      final jobId = const Uuid().v4();
      final safeFileName = originalFileName ?? 'documento_$jobId.pdf';
      final diskFile = File(p.join(Directory.current.path, uploadsDir, '$jobId.pdf'));
      await diskFile.writeAsBytes(fileBytes);

      // Geração do Payload PIX EMVCo com TxID único
      final txId = jobId.substring(0, 16).replaceAll('-', '');
      final pixPayload = pixService.generatePayload(
        amount: totalPrice,
        txId: '***',
        description: 'Impressao $pageCount pags',
      );

      // Persistência com Drift
      final now = DateTime.now();
      await database.insertJob(PrintJobsCompanion.insert(
        id: jobId,
        fileName: safeFileName,
        filePath: diskFile.path,
        pageCount: pageCount,
        unitPrice: Value(unitPrice),
        totalPrice: totalPrice,
        status: 'pending_payment',
        source: source,
        pixTxid: txId,
        createdAt: now,
      ));

      await database.logEvent(
        'JOB_CREATED',
        'Trabalho $jobId criado para $safeFileName ($pageCount págs, R\$ $totalPrice, origem: $source)',
      );

      return Response.ok(
        jsonEncode({
          'id': jobId,
          'fileName': safeFileName,
          'pageCount': pageCount,
          'unitPrice': unitPrice,
          'totalPrice': totalPrice,
          'status': 'pending_payment',
          'source': source,
          'pixPayload': pixPayload,
          'pixTxid': txId,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e, stack) {
      print('Erro ao processar upload: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erro interno ao processar o arquivo: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _handleGetJob(Request request, String id) async {
    final job = await database.getJobById(id);
    if (job == null) {
      return Response.notFound(
        jsonEncode({'error': 'Trabalho de impressão não encontrado.'}),
        headers: {'content-type': 'application/json'},
      );
    }

    final pixPayload = pixService.generatePayload(
      amount: job.totalPrice,
      txId: '***',
      description: 'Impressao ${job.pageCount} pags',
    );

    return Response.ok(
      jsonEncode({
        'id': job.id,
        'fileName': job.fileName,
        'pageCount': job.pageCount,
        'unitPrice': job.unitPrice,
        'totalPrice': job.totalPrice,
        'status': job.status,
        'source': job.source,
        'pixPayload': pixPayload,
        'pixTxid': job.pixTxid,
        'createdAt': job.createdAt.toIso8601String(),
        'printedAt': job.printedAt?.toIso8601String(),
      }),
      headers: {'content-type': 'application/json'},
    );
  }

  Future<Response> _handleConfirmJob(Request request, String id) async {
    final job = await database.getJobById(id);
    if (job == null) {
      return Response.notFound(
        jsonEncode({'error': 'Trabalho não encontrado.'}),
        headers: {'content-type': 'application/json'},
      );
    }

    // Enfileira o trabalho para a impressora física / spooler
    await printQueue.enqueue(job);

    return Response.ok(
      jsonEncode({
        'success': true,
        'message': 'Pagamento confirmado. Documento enviado para a fila de impressão.',
        'jobId': job.id,
        'status': 'queued',
      }),
      headers: {'content-type': 'application/json'},
    );
  }

  Future<Response> _handleJobStream(Request request, String id) async {
    final controller = StreamController<List<int>>();

    // Envia o status inicial
    final job = await database.getJobById(id);
    if (job != null) {
      final initialData = jsonEncode({
        'jobId': job.id,
        'status': job.status,
        'progress': job.status == 'completed' ? 1.0 : 0.0,
        'currentPage': job.status == 'completed' ? job.pageCount : 0,
        'totalPages': job.pageCount,
        'statusText': job.status == 'completed' ? 'Impressão Concluída' : 'Aguardando',
      });
      controller.add(utf8.encode('data: $initialData\n\n'));
    }

    // Escuta eventos em tempo real da fila
    final subscription = printQueue.progressStream
        .where((event) => event.jobId == id)
        .listen(
      (event) {
        controller.add(utf8.encode('data: ${jsonEncode(event.toJson())}\n\n'));
        if (event.isCompleted || event.isError) {
          controller.close();
        }
      },
      onError: (err) {
        controller.add(utf8.encode('data: ${jsonEncode({'error': err.toString()})}\n\n'));
        controller.close();
      },
    );

    controller.onCancel = () {
      subscription.cancel();
    };

    return Response.ok(
      controller.stream,
      headers: {
        'content-type': 'text/event-stream; charset=utf-8',
        'cache-control': 'no-cache',
        'connection': 'keep-alive',
      },
    );
  }

  Future<Response> _handleGetAllJobs(Request request) async {
    final jobs = await database.getAllJobs();
    final list = jobs.map((j) => {
      'id': j.id,
      'fileName': j.fileName,
      'pageCount': j.pageCount,
      'totalPrice': j.totalPrice,
      'status': j.status,
      'source': j.source,
      'createdAt': j.createdAt.toIso8601String(),
    }).toList();

    return Response.ok(
      jsonEncode(list),
      headers: {'content-type': 'application/json'},
    );
  }

  /// Descobre o melhor endereço IPv4 na rede local (ex: Wi-Fi do condomínio)
  static Future<String> getLocalIp() async {
    return NetworkHelper.findLocalIp();
  }
}
