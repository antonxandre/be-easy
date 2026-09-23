import 'dart:async';
import 'dart:io';

/// Implementação IO de NetworkHelper para plataformas nativas (Windows, macOS, Linux)
class NetworkHelper {
  static final _ignoredInterfacePatterns = [
    'loopback',
    'vethernet',
    'wsl',
    'virtualbox',
    'vbox',
    'vmware',
    'docker',
    'bluetooth',
    'teredo',
    'isatap',
    'wireguard',
    'tailscale',
    'zerotier',
    'dummy',
    'tap',
    'tun',
  ];

  static Future<String> findLocalIp() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return '127.0.0.1';
    }

    try {
      final socket = await RawSocket.connect(
        InternetAddress('8.8.8.8'),
        53,
        timeout: const Duration(seconds: 1),
      );
      final ip = socket.address.address;
      socket.close();
      if (_isValidLanIp(ip)) {
        return ip;
      }
    } catch (_) {}

    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      for (final iface in interfaces) {
        if (_isIgnoredInterface(iface.name)) continue;

        final isLikelyPhysical = _isLikelyPhysicalInterface(iface.name);
        if (isLikelyPhysical) {
          for (final addr in iface.addresses) {
            if (_isValidLanIp(addr.address)) {
              return addr.address;
            }
          }
        }
      }

      for (final iface in interfaces) {
        if (_isIgnoredInterface(iface.name)) continue;

        for (final addr in iface.addresses) {
          if (_isValidLanIp(addr.address)) {
            return addr.address;
          }
        }
      }
    } catch (_) {}

    return '127.0.0.1';
  }

  static bool _isIgnoredInterface(String name) {
    final lower = name.toLowerCase();
    for (final pattern in _ignoredInterfacePatterns) {
      if (lower.contains(pattern)) return true;
    }
    return false;
  }

  static bool _isLikelyPhysicalInterface(String name) {
    final lower = name.toLowerCase();
    return lower.contains('wi-fi') ||
        lower.contains('wifi') ||
        lower.contains('wireless') ||
        lower.contains('ethernet') ||
        lower.contains('wlan') ||
        lower.startsWith('en') ||
        lower.startsWith('eth');
  }

  static bool _isValidLanIp(String ip) {
    if (ip.isEmpty) return false;
    if (ip == '127.0.0.1' || ip == '0.0.0.0') return false;
    if (ip.startsWith('169.254.')) return false;
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    return true;
  }
}
