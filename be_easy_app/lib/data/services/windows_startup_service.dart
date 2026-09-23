import 'dart:io';
import 'package:flutter/foundation.dart';

/// Serviço utilitário para gerenciamento de inicialização automática no Windows
class WindowsStartupService {
  static const String _registryKey =
      r'HKCU\Software\Microsoft\Windows\CurrentVersion\Run';
  static const String _appName = 'BeEasyPrint';

  /// Retorna se a aplicação está configurada para iniciar com o Windows
  static Future<bool> isAutoStartEnabled() async {
    if (kIsWeb || !Platform.isWindows) return false;

    try {
      final result = await Process.run(
        'reg',
        ['query', _registryKey, '/v', _appName],
        runInShell: true,
      );
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Ativa ou desativa a inicialização automática com o Windows
  static Future<bool> setAutoStart(bool enable) async {
    if (kIsWeb || !Platform.isWindows) return false;

    try {
      if (enable) {
        final exePath = Platform.resolvedExecutable;
        final result = await Process.run(
          'reg',
          [
            'add',
            _registryKey,
            '/v',
            _appName,
            '/t',
            'REG_SZ',
            '/d',
            '"$exePath"',
            '/f',
          ],
          runInShell: true,
        );
        return result.exitCode == 0;
      } else {
        final result = await Process.run(
          'reg',
          ['delete', _registryKey, '/v', _appName, '/f'],
          runInShell: true,
        );
        return result.exitCode == 0;
      }
    } catch (_) {
      return false;
    }
  }
}
