import 'dart:convert';
import 'dart:io';
import 'package:be_easy_server/src/database/database.dart';
import 'package:be_easy_server/src/server.dart';
import 'package:be_easy_server/src/services/pdf_service.dart';
import 'package:be_easy_server/src/services/pix_service.dart';
import 'package:be_easy_server/src/services/print_queue_service.dart';
import 'package:be_easy_server/src/services/print_spooler_service.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

Future<Map<String, dynamic>> _httpGet(String url) async {
  final client = HttpClient();
  final req = await client.getUrl(Uri.parse(url));
  final res = await req.close();
  final body = await utf8.decodeStream(res);
  client.close();
  return {'statusCode': res.statusCode, 'body': body};
}

Future<Map<String, dynamic>> _httpPost(String url, Map<String, dynamic> data) async {
  final client = HttpClient();
  final req = await client.postUrl(Uri.parse(url));
  req.headers.contentType = ContentType.json;
  req.write(jsonEncode(data));
  final res = await req.close();
  final body = await utf8.decodeStream(res);
  client.close();
  return {'statusCode': res.statusCode, 'body': body};
}

void main() {
  group('BeEasyServer Admin & Config API', () {
    late AppDatabase database;
    late BeEasyServer server;
    const testPort = 8089;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      final spooler = MockPrintSpoolerService();
      final printQueue = PrintQueueService(database: database, spooler: spooler);
      final pdfService = PdfService();
      final pixService = PixService(
        pixKey: '65717703000180',
        merchantName: 'BE EASY PRINT',
        merchantCity: 'SAO PAULO',
      );

      server = BeEasyServer(
        port: testPort,
        database: database,
        pdfService: pdfService,
        pixService: pixService,
        printQueue: printQueue,
        defaultUnitPrice: 2.0,
        adminPassword: 'BeEasy@2026',
        wifiSsid: 'beEASY_Loja',
        wifiPassword: 'senha1234',
        uploadsDir: 'uploads_test',
      );

      await server.start();
    });

    tearDown(() async {
      await server.stop();
      await database.close();
    });

    test('GET /api/config deve retornar configuração atual com preço e Wi-Fi', () async {
      final res = await _httpGet('http://127.0.0.1:$testPort/api/config');
      expect(res['statusCode'], 200);

      final json = jsonDecode(res['body'] as String) as Map<String, dynamic>;
      expect(json['unitPrice'], 2.0);
      expect(json['wifiSsid'], 'beEASY_Loja');
      expect(json['wifiPassword'], 'senha1234');
      expect(json['hasAdminPassword'], isTrue);
    });

    test('POST /api/admin/verify deve validar senha correta e rejeitar incorreta', () async {
      final okRes = await _httpPost(
        'http://127.0.0.1:$testPort/api/admin/verify',
        {'password': 'BeEasy@2026'},
      );
      expect(okRes['statusCode'], 200);
      expect(jsonDecode(okRes['body'] as String)['success'], isTrue);

      final failRes = await _httpPost(
        'http://127.0.0.1:$testPort/api/admin/verify',
        {'password': 'senha_errada'},
      );
      expect(failRes['statusCode'], 200);
      expect(jsonDecode(failRes['body'] as String)['success'], isFalse);
    });

    test('POST /api/config deve atualizar valor por página e rede em tempo real', () async {
      final updateRes = await _httpPost(
        'http://127.0.0.1:$testPort/api/config',
        {
          'unitPrice': 3.50,
          'wifiSsid': 'NovaRede_Loja',
          'wifiPassword': 'novasenha888',
        },
      );
      expect(updateRes['statusCode'], 200);

      final getRes = await _httpGet('http://127.0.0.1:$testPort/api/config');
      final json = jsonDecode(getRes['body'] as String) as Map<String, dynamic>;
      expect(json['unitPrice'], 3.50);
      expect(json['wifiSsid'], 'NovaRede_Loja');
      expect(json['wifiPassword'], 'novasenha888');
    });

    test('POST /api/admin/change-password deve alterar a senha administrativa', () async {
      final changeRes = await _httpPost(
        'http://127.0.0.1:$testPort/api/admin/change-password',
        {
          'currentPassword': 'BeEasy@2026',
          'newPassword': 'NovaSenha@999',
        },
      );
      expect(changeRes['statusCode'], 200);
      expect(jsonDecode(changeRes['body'] as String)['success'], isTrue);

      // Valida com a nova senha
      final verifyRes = await _httpPost(
        'http://127.0.0.1:$testPort/api/admin/verify',
        {'password': 'NovaSenha@999'},
      );
      expect(jsonDecode(verifyRes['body'] as String)['success'], isTrue);
    });

    test('GET /api/printers deve listar impressoras', () async {
      final res = await _httpGet('http://127.0.0.1:$testPort/api/printers');
      expect(res['statusCode'], 200);
      final list = jsonDecode(res['body'] as String) as List<dynamic>;
      expect(list.isNotEmpty, isTrue);
    });

    test('POST /api/printers/test deve despachar página de teste com sucesso no mock', () async {
      final res = await _httpPost(
        'http://127.0.0.1:$testPort/api/printers/test',
        {
          'printerName': 'Simulador Virtual',
          'isMock': true,
        },
      );
      expect(res['statusCode'], 200);
      expect(jsonDecode(res['body'] as String)['success'], isTrue);
    });
  });
}
