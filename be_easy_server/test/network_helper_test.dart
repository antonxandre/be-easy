import 'package:be_easy_server/be_easy_server.dart';
import 'package:test/test.dart';

void main() {
  group('NetworkHelper Tests', () {
    test('findLocalIp returns a valid non-empty IPv4 address', () async {
      final ip = await NetworkHelper.findLocalIp();
      expect(ip, isNotEmpty);

      // Deve ser 4 octetos numéricos separados por pontos
      final parts = ip.split('.');
      expect(parts.length, equals(4));
      for (final part in parts) {
        final numVal = int.tryParse(part);
        expect(numVal, isNotNull);
        expect(numVal! >= 0 && numVal <= 255, isTrue);
      }
    });

    test('findLocalIp never returns APIPA (169.254.x.x)', () async {
      final ip = await NetworkHelper.findLocalIp();
      expect(ip.startsWith('169.254.'), isFalse);
    });
  });
}
