import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

/// Representação das informações de uma impressora instalada ou virtual
class PrinterInfo {
  final String name;
  final bool isDefault;
  final bool isMock;
  final String status;

  PrinterInfo({
    required this.name,
    this.isDefault = false,
    this.isMock = false,
    this.status = 'Pronta',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'isDefault': isDefault,
    'isMock': isMock,
    'status': status,
  };

  factory PrinterInfo.fromJson(Map<String, dynamic> json) => PrinterInfo(
    name: json['name'] as String? ?? 'Desconhecida',
    isDefault: json['isDefault'] as bool? ?? false,
    isMock: json['isMock'] as bool? ?? false,
    status: json['status'] as String? ?? 'Pronta',
  );
}

/// Serviço de varredura e teste de impressoras do sistema operacional
class PrinterService {
  /// Retorna lista de impressoras detectadas no SO + Opção de Mock Spooler
  Future<List<PrinterInfo>> getAvailablePrinters() async {
    final printers = <PrinterInfo>[];

    // Sempre adiciona a opção de Simulador Virtual para testes e desenvolvimento
    printers.add(
      PrinterInfo(
        name: 'Simulador Virtual (Sem impressora física)',
        isDefault: false,
        isMock: true,
        status: 'Ativo (Spooler Mock)',
      ),
    );

    try {
      if (Platform.isMacOS || Platform.isLinux) {
        // macOS / Linux CUPS spooler
        String? defaultDest;
        try {
          final defResult = await Process.run('lpstat', ['-d']).timeout(const Duration(seconds: 3));
          if (defResult.exitCode == 0) {
            final output = defResult.stdout.toString();
            // ex: "system default destination: HP_LaserJet_Pro"
            final match = RegExp(r':\s*([^\s]+)').firstMatch(output);
            if (match != null) {
              defaultDest = match.group(1)?.trim();
            }
          }
        } catch (_) {}

        // Lista de destinos disponíveis
        final destResult = await Process.run('lpstat', ['-e']).timeout(const Duration(seconds: 4));
        if (destResult.exitCode == 0) {
          final lines = destResult.stdout.toString().split('\n');
          for (final rawLine in lines) {
            final line = rawLine.trim();
            if (line.isNotEmpty) {
              final isDef = line == defaultDest;
              printers.add(
                PrinterInfo(
                  name: line,
                  isDefault: isDef,
                  isMock: false,
                  status: isDef ? 'Padrão do Sistema' : 'Disponível',
                ),
              );
            }
          }
        } else {
          // Fallback para lpstat -p
          final pResult = await Process.run('lpstat', ['-p']).timeout(const Duration(seconds: 4));
          if (pResult.exitCode == 0) {
            final lines = pResult.stdout.toString().split('\n');
            for (final line in lines) {
              // ex: "printer HP_LaserJet_Pro is idle. enabled since..."
              final match = RegExp(r'printer\s+([^\s]+)\s+(is\s+[^\.]+)', caseSensitive: false).firstMatch(line);
              if (match != null) {
                final name = match.group(1)!;
                final status = match.group(2) ?? 'Disponível';
                printers.add(
                  PrinterInfo(
                    name: name,
                    isDefault: name == defaultDest,
                    isMock: false,
                    status: status,
                  ),
                );
              }
            }
          }
        }
      } else if (Platform.isWindows) {
        // Windows via PowerShell Get-CimInstance Win32_Printer
        final psResult = await Process.run('powershell', [
          '-NoProfile',
          '-Command',
          'Get-CimInstance Win32_Printer | Select-Object -Property Name, Default | ConvertTo-Json',
        ]).timeout(const Duration(seconds: 5));

        if (psResult.exitCode == 0) {
          final out = psResult.stdout.toString().trim();
          if (out.isNotEmpty) {
            // Pode retornar um objeto ou array de objetos
            // Processamento simplificado por linhas/regex
            final nameMatches = RegExp(r'"Name":\s*"([^"]+)"').allMatches(out);
            for (final m in nameMatches) {
              final name = m.group(1);
              if (name != null && name.isNotEmpty) {
                printers.add(
                  PrinterInfo(
                    name: name,
                    isDefault: false,
                    isMock: false,
                    status: 'Disponível',
                  ),
                );
              }
            }
          }
        }
      }
    } catch (e) {
      // Ignora falha de descoberta no ambiente sandboxed / sem CUPS
    }

    // Se nenhuma física for encontrada, marca o mock como padrão
    if (printers.length == 1) {
      printers[0] = PrinterInfo(
        name: printers[0].name,
        isDefault: true,
        isMock: true,
        status: printers[0].status,
      );
    }

    return printers;
  }

  /// Gera um documento PDF de teste de 1 página
  Uint8List generateTestPagePdf({required String printerName}) {
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    final content = '''%PDF-1.4
1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj
2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj
3 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >> endobj
4 0 obj << /Length 320 >> stream
BT
/F1 22 Tf
50 780 Td
(be EASY Print - Pagina de Teste do Terminal) Tj
/F1 12 Tf
0 -40 Td
(Impressora Selecionada: $printerName) Tj
0 -25 Td
(Data e Hora do Teste: $dateStr) Tj
0 -25 Td
(Status do Spooler: Operacional e Conectado) Tj
0 -35 Td
(Este documento confirma que o totem be EASY Print esta configurado) Tj
0 -20 Td
(e pronto para despachar trabalhos de impressao dos clientes.) Tj
ET
endstream
endobj
5 0 obj << /Type /Font /Subtype /Type1 /BaseFont /Helvetica >> endobj
xref
0 6
0000000000 65535 f 
0000000009 00000 n 
0000000058 00000 n 
0000000115 00000 n 
0000000244 00000 n 
0000000617 00000 n 
trailer << /Size 6 /Root 1 0 R >>
startxref
694
%%EOF
''';
    return Uint8List.fromList(content.codeUnits);
  }

  /// Envia a página de teste para a impressora física via SO
  Future<bool> printTestPage({
    required String printerName,
    required bool isMock,
  }) async {
    if (isMock) {
      // Simulação rápida
      await Future.delayed(const Duration(milliseconds: 600));
      return true;
    }

    try {
      final testPdf = generateTestPagePdf(printerName: printerName);
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/be_easy_test_print.pdf');
      await tempFile.writeAsBytes(testPdf);

      ProcessResult result;
      if (Platform.isMacOS || Platform.isLinux) {
        final args = <String>[];
        if (printerName.isNotEmpty) {
          args.addAll(['-P', printerName]);
        }
        args.addAll(['-o', 'fit-to-page', tempFile.path]);
        result = await Process.run('lpr', args).timeout(const Duration(seconds: 6));
      } else if (Platform.isWindows) {
        result = await Process.run('powershell', [
          '-NoProfile',
          '-Command',
          'Start-Process -FilePath "${tempFile.path}" -Verb PrintTo -ArgumentList "$printerName"',
        ]).timeout(const Duration(seconds: 6));
      } else {
        return false;
      }

      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}
