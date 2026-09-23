import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/admin_config_dto.dart';
import '../models/print_job_dto.dart';

class ApiService {
  final String _baseUrl;

  ApiService({String? baseUrl})
      : _baseUrl = baseUrl ?? _resolveBaseUrl();

  static String _resolveBaseUrl() {
    if (kIsWeb) {
      final scheme = Uri.base.scheme.isNotEmpty ? Uri.base.scheme : 'http';
      final host = Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost';
      final port = Uri.base.port != 0 ? Uri.base.port : 8080;
      return '$scheme://$host:$port';
    }
    return 'http://127.0.0.1:8080';
  }

  String get baseUrl => _baseUrl;

  /// Consulta o status e saúde do servidor
  Future<Map<String, dynamic>> getStatus() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/status');
      final response = await http.get(uri).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {'status': 'offline'};
  }

  /// Faz upload de um PDF via multipart/form-data
  Future<PrintJobDto> uploadPdf({
    required String fileName,
    required Uint8List bytes,
    String source = 'desktop_usb',
  }) async {
    final uri = Uri.parse('$_baseUrl/api/upload');
    final request = http.MultipartRequest('POST', uri);

    request.fields['source'] = source;
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
        contentType: MediaType('application', 'pdf'),
      ),
    );

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200) {
      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      return PrintJobDto.fromJson(json);
    } else {
      Map<String, dynamic>? errorJson;
      try {
        errorJson = jsonDecode(responseBody) as Map<String, dynamic>;
      } catch (_) {}
      final message = errorJson?['error'] ?? 'Erro no upload (${streamedResponse.statusCode})';
      throw Exception(message);
    }
  }

  /// Consulta um trabalho pelo ID
  Future<PrintJobDto> getJob(String id) async {
    final uri = Uri.parse('$_baseUrl/api/jobs/$id');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PrintJobDto.fromJson(json);
    } else {
      throw Exception('Trabalho $id não encontrado.');
    }
  }

  /// Confirma o pagamento e inicia a impressão
  Future<void> confirmJob(String id) async {
    final uri = Uri.parse('$_baseUrl/api/jobs/$id/confirm');
    final response = await http.post(uri);

    if (response.statusCode != 200) {
      throw Exception('Falha ao confirmar impressão.');
    }
  }

  /// Consulta o IP local do servidor
  Future<String> getLocalIp() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/network/ip');
      final response = await http.get(uri).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return json['ip'] as String? ?? '127.0.0.1';
      }
    } catch (_) {}
    return '127.0.0.1';
  }

  /// Obtém a configuração administrativa completa do terminal
  Future<AdminConfigDto> getConfig() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/config');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return AdminConfigDto.fromJson(json);
      }
    } catch (_) {}
    return AdminConfigDto(
      pixKey: '65717703000180',
      merchantName: 'BE EASY PRINT',
      merchantCity: 'SAO PAULO',
      unitPrice: 2.0,
      wifiSsid: 'BE EASY - TEFNet_5g',
      wifiPassword: 'clientebeeasy7789@',
      customIp: '',
      serverPort: 8080,
      selectedPrinter: '',
      useMockPrinter: true,
    );
  }

  /// Salva a configuração administrativa atualizada
  Future<bool> saveConfig(AdminConfigDto config) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/config');
      final response = await http
          .post(
            uri,
            headers: {'content-type': 'application/json'},
            body: jsonEncode(config.toJson()),
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Valida a senha do administrador
  Future<bool> verifyAdminPassword(String password) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/admin/verify');
      final response = await http
          .post(
            uri,
            headers: {'content-type': 'application/json'},
            body: jsonEncode({'password': password}),
          )
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return json['success'] as bool? ?? false;
      }
    } catch (_) {}
    return false;
  }

  /// Altera a senha do administrador
  Future<bool> changeAdminPassword(String currentPassword, String newPassword) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/admin/change-password');
      final response = await http
          .post(
            uri,
            headers: {'content-type': 'application/json'},
            body: jsonEncode({
              'currentPassword': currentPassword,
              'newPassword': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Lista todas as impressoras detectadas no computador
  Future<List<PrinterInfoDto>> getPrinters() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/printers');
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list.map((item) => PrinterInfoDto.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [
      PrinterInfoDto(
        name: 'Simulador Virtual (Sem impressora física)',
        isDefault: true,
        isMock: true,
        status: 'Ativo (Spooler Mock)',
      ),
    ];
  }

  /// Dispara a impressão de uma página de teste
  Future<bool> printTestPage({required String printerName, required bool isMock}) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/printers/test');
      final response = await http
          .post(
            uri,
            headers: {'content-type': 'application/json'},
            body: jsonEncode({
              'printerName': printerName,
              'isMock': isMock,
            }),
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return json['success'] as bool? ?? false;
      }
    } catch (_) {}
    return false;
  }
}
