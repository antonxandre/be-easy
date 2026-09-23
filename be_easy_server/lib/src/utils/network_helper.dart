import 'dart:async';
import 'dart:io';

/// Utilitário para detecção robusta e dinâmica do endereço IPv4 local da máquina (Windows / Linux / macOS).
class NetworkHelper {
  /// Lista de padrões de nomes de interfaces virtuais ou irrelevantes que devem ser ignoradas no Windows/Linux/macOS
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
    'hyper-v',
    'host-only',
  ];

  /// Descobre o melhor endereço IPv4 na rede local (Wi-Fi da loja / Ethernet)
  ///
  /// Inspeciona as interfaces de rede locais ativas (NetworkInterface.list),
  /// descartando adaptadores virtuais e priorizando endereços privados (RFC 1918)
  /// em interfaces físicas de Wi-Fi ou Ethernet.
  static Future<String> findLocalIp() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return '127.0.0.1';
    }

    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      final List<String> physicalRfc1918 = [];
      final List<String> otherRfc1918 = [];
      final List<String> anyValidLan = [];

      for (final iface in interfaces) {
        if (_isIgnoredInterface(iface.name)) continue;
        final isPhysical = _isLikelyPhysicalInterface(iface.name);

        for (final addr in iface.addresses) {
          final ip = addr.address;
          if (_isPrivateRfc1918Ip(ip)) {
            if (isPhysical) {
              physicalRfc1918.add(ip);
            } else {
              otherRfc1918.add(ip);
            }
          } else if (_isValidLanIp(ip)) {
            anyValidLan.add(ip);
          }
        }
      }

      // Prioridade 1: Interface física com IP 192.168.* (padrão absoluto de roteadores Wi-Fi locais)
      final wifi192 = physicalRfc1918.where((ip) => ip.startsWith('192.168.')).toList();
      if (wifi192.isNotEmpty) return wifi192.first;

      // Prioridade 2: Qualquer outra faixa física privada (10.* ou 172.16-31.*)
      if (physicalRfc1918.isNotEmpty) return physicalRfc1918.first;

      // Prioridade 3: Outra interface não ignorada com IP 192.168.*
      final other192 = otherRfc1918.where((ip) => ip.startsWith('192.168.')).toList();
      if (other192.isNotEmpty) return other192.first;

      // Prioridade 4: Qualquer interface não ignorada com IP privado
      if (otherRfc1918.isNotEmpty) return otherRfc1918.first;

      // Prioridade 5: Qualquer IPv4 válido não-loopback
      if (anyValidLan.isNotEmpty) return anyValidLan.first;
    } catch (_) {}

    return '127.0.0.1';
  }

  /// Verifica se o nome da interface deve ser ignorado
  static bool _isIgnoredInterface(String name) {
    final lower = name.toLowerCase();
    for (final pattern in _ignoredInterfacePatterns) {
      if (lower.contains(pattern)) return true;
    }
    return false;
  }

  /// Verifica se o nome é característico de interface física principal (em inglês ou português no Windows)
  static bool _isLikelyPhysicalInterface(String name) {
    final lower = name.toLowerCase();
    return lower.contains('wi-fi') ||
        lower.contains('wifi') ||
        lower.contains('wireless') ||
        lower.contains('sem fio') ||
        lower.contains('ethernet') ||
        lower.contains('wlan') ||
        lower.contains('lan') ||
        lower.contains('rede') ||
        lower.contains('conex') ||
        lower.startsWith('en') ||
        lower.startsWith('eth');
  }

  /// Identifica faixas de IP privadas padronizadas pela RFC 1918
  static bool _isPrivateRfc1918Ip(String ip) {
    if (ip.isEmpty) return false;
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    final p0 = int.tryParse(parts[0]);
    final p1 = int.tryParse(parts[1]);
    if (p0 == null || p1 == null) return false;

    // 10.0.0.0/8
    if (p0 == 10) return true;
    // 172.16.0.0/12 (172.16.0.0 – 172.31.255.255)
    if (p0 == 172 && p1 >= 16 && p1 <= 31) return true;
    // 192.168.0.0/16
    if (p0 == 192 && p1 == 168) return true;

    return false;
  }

  /// Valida se o IPv4 é um endereço utilizável de rede local (não loopback, não APIPA, não multicast, não DNS público)
  static bool _isValidLanIp(String ip) {
    if (ip.isEmpty) return false;
    if (ip == '127.0.0.1' || ip == '0.0.0.0') return false;
    if (ip.startsWith('169.254.')) return false; // APIPA sem DHCP
    if (ip.startsWith('127.')) return false; // Loopback
    if (ip.startsWith('224.') || ip.startsWith('239.')) return false; // Multicast
    if (ip == '8.8.8.8' || ip == '8.8.4.4' || ip == '1.1.1.1') return false; // DNS públicos externos
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    for (final p in parts) {
      final n = int.tryParse(p);
      if (n == null || n < 0 || n > 255) return false;
    }
    return true;
  }
}
