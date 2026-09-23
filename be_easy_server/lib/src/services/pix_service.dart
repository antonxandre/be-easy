/// Gerador de Payload PIX (BR Code / EMVCo) para pagamentos instantâneos.
/// Opera 100% offline calculando as tags TLV e o checksum CRC16-CCITT.
class PixService {
  String pixKey;
  String merchantName;
  String merchantCity;

  PixService({
    String pixKey = '65717703000180',
    this.merchantName = 'BE EASY PRINT',
    this.merchantCity = 'SAO PAULO',
  }) : pixKey = sanitizePixKey(pixKey);

  /// Normaliza chaves PIX (em particular CPF e CNPJ com pontuação/máscara).
  /// Bacen exige que CPF (11 dígitos) e CNPJ (14 dígitos) sejam apenas dígitos numéricos no BR Code.
  static String sanitizePixKey(String rawKey) {
    final trimmed = rawKey.trim();
    final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if ((digitsOnly.length == 11 || digitsOnly.length == 14) &&
        RegExp(r'^[0-9.\-\/]+$').hasMatch(trimmed)) {
      return digitsOnly;
    }
    return trimmed;
  }

  void updateConfig({String? key, String? name, String? city}) {
    if (key != null && key.trim().isNotEmpty) pixKey = sanitizePixKey(key);
    if (name != null && name.trim().isNotEmpty) merchantName = name.trim();
    if (city != null && city.trim().isNotEmpty) merchantCity = city.trim();
  }

  /// Formata uma Tag TLV (Tag-Length-Value).
  /// [id] é o código da tag com 2 dígitos.
  /// [value] é o valor da tag.
  static String formatTlv(String id, String value) {
    final len = value.length.toString().padLeft(2, '0');
    return '$id$len$value';
  }

  /// Remove caracteres especiais e acentos para conformidade com a norma EMVCo.
  static String normalizeAscii(String input) {
    const withAccents = 'ÀÁÂÃÄÅàáâãäåÈÉÊËèéêëÌÍÎÏìíîïÒÓÔÕÖØòóôõöøÙÚÛÜùúûüÇçÑñÝý';
    const withoutAccents = 'AAAAAAaaaaaaEEEEeeeeIIIIiiiiOOOOOOooooooUUUUuuuuCcNnYy';
    var output = input;
    for (var i = 0; i < withAccents.length; i++) {
      output = output.replaceAll(withAccents[i], withoutAccents[i]);
    }
    // Remove qualquer outro caractere fora do padrão ASCII imprimível
    return output.replaceAll(RegExp(r'[^\x20-\x7E]'), '');
  }

  /// Gera a string completa de payload PIX Copia e Cola (BR Code EMVCo Estático).
  String generatePayload({
    required double amount,
    String? txId,
    String? description,
  }) {
    // Para QR Code Estático, quando não há um identificador gerado pelo PSP/banco,
    // o padrão oficial do Banco Central do Brasil para o txid é '***'
    final cleanTxId = (txId ?? '').replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final finalTxId = cleanTxId.isEmpty ? '***' : (cleanTxId.length > 25 ? cleanTxId.substring(0, 25) : cleanTxId);

    // Subcampos do Merchant Account Information (Tag 26)
    final gui = formatTlv('00', 'br.gov.bcb.pix');
    final key = formatTlv('01', sanitizePixKey(pixKey));
    final desc = description != null && description.isNotEmpty
        ? formatTlv('02', normalizeAscii(description))
        : '';
    final tag26Value = '$gui$key$desc';

    // Subcampo da Tag 62 (Additional Data Field Template - Reference Label / TxID)
    final refLabel = formatTlv('05', finalTxId);
    final tag62Value = refLabel;

    final normName = normalizeAscii(merchantName).toUpperCase();
    final cleanName = normName.length > 25 ? normName.substring(0, 25) : (normName.isEmpty ? 'BE EASY PRINT' : normName);

    final normCity = normalizeAscii(merchantCity).toUpperCase();
    final cleanCity = normCity.length > 15 ? normCity.substring(0, 15) : (normCity.isEmpty ? 'SAO PAULO' : normCity);

    final amountStr = amount.toStringAsFixed(2);

    final buffer = StringBuffer()
      ..write(formatTlv('00', '01')) // Payload Format Indicator
      ..write(formatTlv('01', '11')) // Point of Initiation: 11 = QR Code Estático (Bacen exige 11; 12 é dinâmico com URL de PSP)
      ..write(formatTlv('26', tag26Value))
      ..write(formatTlv('52', '0000')) // Merchant Category Code
      ..write(formatTlv('53', '986')) // Currency BRL
      ..write(formatTlv('54', amountStr)) // Amount
      ..write(formatTlv('58', 'BR')) // Country Code
      ..write(formatTlv('59', cleanName)) // Merchant Name
      ..write(formatTlv('60', cleanCity)) // Merchant City
      ..write(formatTlv('62', tag62Value)) // Additional Data (TxID)
      ..write('6304'); // CRC16 Tag + Length placeholder

    final payloadWithoutCrc = buffer.toString();
    final crc = calculateCrc16(payloadWithoutCrc);
    return '$payloadWithoutCrc$crc';
  }

  /// Calcula o checksum CRC16-CCITT (Polinômio 0x1021, Inicial 0xFFFF).
  static String calculateCrc16(String input) {
    var crc = 0xFFFF;
    const polynomial = 0x1021;
    final bytes = input.codeUnits;

    for (final b in bytes) {
      for (var i = 0; i < 8; i++) {
        final bit = ((b >> (7 - i)) & 1) == 1;
        final c15 = ((crc >> 15) & 1) == 1;
        crc = (crc << 1) & 0xFFFF;
        if (c15 ^ bit) {
          crc ^= polynomial;
        }
      }
    }

    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }
}
