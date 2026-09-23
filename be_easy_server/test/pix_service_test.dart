import 'package:be_easy_server/src/services/pix_service.dart';
import 'package:test/test.dart';

void main() {
  group('PixService', () {
    late PixService pixService;

    setUp(() {
      pixService = PixService(
        pixKey: '12345678900',
        merchantName: 'BE EASY PRINT',
        merchantCity: 'SAO PAULO',
      );
    });

    test('deve formatar tags TLV corretamente', () {
      expect(PixService.formatTlv('00', '01'), '000201');
      expect(PixService.formatTlv('53', '986'), '5303986');
      expect(PixService.formatTlv('58', 'BR'), '5802BR');
    });

    test('deve normalizar caracteres acentuados para ASCII', () {
      expect(PixService.normalizeAscii('São Paulo'), 'Sao Paulo');
      expect(PixService.normalizeAscii('Mercearia & Açaí'), 'Mercearia & Acai');
    });

    test('deve calcular CRC16-CCITT de forma determinística', () {
      // Valor de teste padrão EMVCo
      final payload = '00020126360014br.gov.bcb.pix0114+551199999999952040000530398654041.005802BR5909TESTE PIX6009SAO PAULO62070503***6304';
      final crc = PixService.calculateCrc16(payload);
      expect(crc.length, 4);
      expect(RegExp(r'^[0-9A-F]{4}$').hasMatch(crc), isTrue);
    });

    test('deve gerar payload PIX com chave CNPJ padrão (65717703000180)', () {
      final defaultService = PixService();
      expect(defaultService.pixKey, '65717703000180');

      final payload = defaultService.generatePayload(
        amount: 30.00,
        txId: '***',
        description: 'Impressao 15 pags',
      );

      expect(payload.startsWith('000201'), isTrue);
      // Tag 26 deve conter a chave CNPJ: subtag 01 com tamanho 14 e o CNPJ
      expect(payload.contains('011465717703000180'), isTrue);
      expect(payload.contains('540530.00'), isTrue);
      expect(payload.contains('6304'), isTrue);
      expect(payload.length, greaterThan(70));
    });

    test('deve sanitizar chave CNPJ formatada com pontuação', () {
      final cnpjService = PixService(pixKey: '65.717.703/0001-80');
      expect(cnpjService.pixKey, '65717703000180');

      final payload = cnpjService.generatePayload(amount: 10.00);
      expect(payload.contains('011465717703000180'), isTrue);
    });

    test('deve gerar payload PIX completo com as tags obrigatórias', () {
      final payload = pixService.generatePayload(
        amount: 30.00,
        txId: 'TX12345678',
        description: 'Impressao 15 pags',
      );

      expect(payload.startsWith('000201'), isTrue);
      expect(payload.contains('010211'), isTrue); // QR Code Estático
      expect(payload.contains('br.gov.bcb.pix'), isTrue);
      expect(payload.contains('12345678900'), isTrue);
      expect(payload.contains('540530.00'), isTrue); // Valor R$ 30,00
      expect(payload.contains('5802BR'), isTrue);
      expect(payload.contains('5913BE EASY PRINT'), isTrue);
      expect(payload.contains('6009SAO PAULO'), isTrue);
      expect(payload.contains('6304'), isTrue); // Tag do CRC16
    });
  });
}
