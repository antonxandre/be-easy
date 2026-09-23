import 'dart:convert';
import 'dart:io';
import 'package:be_easy_server/be_easy_server.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'server_manager_stub.dart';

class ServerManagerIo implements ServerManager {
  BeEasyServer? _server;
  bool _isRunning = false;

  @override
  bool get isRunning => _isRunning;

  @override
  Future<void> startServer() async {
    if (_isRunning) return;

    try {
      final database = AppDatabase();
      final pdfService = PdfService();

      String pixKey = '65717703000180';
      String merchantName = 'BE EASY PRINT';
      String merchantCity = 'SAO PAULO';
      double unitPrice = 2.0;
      String adminPassword = 'BeEasy@2026';
      String wifiSsid = 'BE EASY - TEFNet_5g';
      String wifiPassword = 'clientebeeasy7789@';
      String customIp = '';
      String selectedPrinter = '';
      bool useMockPrinter = true;

      final exeDir = p.dirname(Platform.resolvedExecutable);
      final configCandidates = [
        File(p.join(exeDir, 'config.json')),
        File('config.json'),
        File('../config.json'),
        File('be_easy_server/config.json'),
      ];
      for (final cf in configCandidates) {
        if (cf.existsSync()) {
          try {
            final content = jsonDecode(cf.readAsStringSync()) as Map<String, dynamic>;
            if (content['pixKey'] != null) pixKey = content['pixKey'] as String;
            if (content['merchantName'] != null) merchantName = content['merchantName'] as String;
            if (content['merchantCity'] != null) merchantCity = content['merchantCity'] as String;
            if (content['unitPrice'] != null) unitPrice = (content['unitPrice'] as num).toDouble();
            if (content['adminPassword'] != null) adminPassword = content['adminPassword'] as String;
            if (content['wifiSsid'] != null) wifiSsid = content['wifiSsid'] as String;
            if (content['wifiPassword'] != null) wifiPassword = content['wifiPassword'] as String;
            if (content['customIp'] != null) customIp = content['customIp'] as String;
            if (content['selectedPrinter'] != null) selectedPrinter = content['selectedPrinter'] as String;
            if (content['useMockPrinter'] != null) useMockPrinter = content['useMockPrinter'] as bool;
            break;
          } catch (_) {}
        }
      }

      final pixService = PixService(
        pixKey: pixKey,
        merchantName: merchantName,
        merchantCity: merchantCity,
      );

      final PrintSpoolerService spooler = useMockPrinter
          ? MockPrintSpoolerService()
          : SystemPrintSpoolerService(printerName: selectedPrinter.isNotEmpty ? selectedPrinter : null);

      final printQueue = PrintQueueService(
        database: database,
        spooler: spooler,
      );

      String? webAssetsPath;
      final potentialWebDirs = [
        p.join(exeDir, 'web'),
        p.join(exeDir, 'data', 'flutter_assets', 'web'),
        p.join(Directory.current.path, 'web'),
        p.join(Directory.current.path, 'be_easy_server', 'web'),
        p.join(Directory.current.path, 'be_easy_app', 'build', 'web'),
        p.join(Directory.current.parent.path, 'be_easy_server', 'web'),
        p.join(Directory.current.parent.path, 'be_easy_app', 'build', 'web'),
      ];
      for (final pwd in potentialWebDirs) {
        if (Directory(pwd).existsSync() && File(p.join(pwd, 'index.html')).existsSync()) {
          webAssetsPath = pwd;
          break;
        }
      }

      _server = BeEasyServer(
        port: 8080,
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
        webAssetsPath: webAssetsPath,
      );

      await _server!.start();
      _isRunning = true;
      debugPrint('Servidor local be_easy_server iniciado com sucesso em background na porta 8080.');
    } catch (e) {
      debugPrint('Aviso: Não foi possível iniciar servidor embutido: $e');
    }
  }

  @override
  Future<void> stopServer() async {
    await _server?.stop();
    _isRunning = false;
  }
}

ServerManager getServerManager() => ServerManagerIo();
