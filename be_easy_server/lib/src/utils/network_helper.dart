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
  ];

  /// Descobre o melhor endereço IPv4 na rede local (Wi-Fi da loja / Ethernet)
  ///
  /// Utiliza duas abordagens complementares:
  /// 1. Tenta abrir um socket de roteamento para identificar a interface de saída ativa.
  /// 2. Filtra NetworkInterface.list() descartando adaptadores virtuais do Windows/macOS.
  static Future<String> findLocalIp() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return '127.0.0.1';
    }

    // 1. Abordagem rápida: Socket UDP de roteamento
    // Conectar um socket UDP para um IP externo (mesmo sem tráfego real)
    // faz a tabela de roteamento do sistema operacional (Windows/Linux/macOS)
    // selecionar a interface local padrão com acesso à rede/gateway.
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
    } catch (_) {
      // Se não houver internet externa, continua para inspeção das interfaces locais
    }

    // 2. Abordagem por inspeção e filtragem de NetworkInterface
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      // Prioridade 1: Interfaces físicas típicas de Wi-Fi ou Ethernet (ex: Wi-Fi, Ethernet, eth, wlan, en)
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

      // Prioridade 2: Qualquer outra interface não virtual que tenha um IPv4 válido
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

  /// Verifica se o nome da interface deve ser ignorado
  static bool _isIgnoredInterface(String name) {
    final lower = name.toLowerCase();
    for (final pattern in _ignoredInterfacePatterns) {
      if (lower.contains(pattern)) return true;
    }
    return false;
  }

  /// Verifica se o nome é característico de interface física principal
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

  /// Valida se o IPv4 é um endereço utilizável de rede local (não loopback e não APIPA)
  static bool _isValidLanIp(String ip) {
    if (ip.isEmpty) return false;
    if (ip == '127.0.0.1' || ip == '0.0.0.0') return false;
    // Descarta endereços de autoconfiguração sem DHCP (APIPA 169.254.x.x)
    if (ip.startsWith('169.254.')) return false;

    // Prefere faixas privadas RFC 1918:
    // 192.168.0.0 - 192.168.255.255
    // 10.0.0.0 - 10.255.255.255
    // 172.16.0.0 - 172.31.255.255
    final parts = ip.split('.');
    if (parts.length != 4) return false;

    return true;
  }
}
