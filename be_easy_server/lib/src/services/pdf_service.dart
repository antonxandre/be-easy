import 'dart:io';
import 'dart:typed_data';

/// Exceção lançada quando o arquivo não é um PDF válido ou seguro.
class InvalidPdfException implements Exception {
  final String message;
  InvalidPdfException(this.message);

  @override
  String toString() => 'InvalidPdfException: $message';
}

/// Serviço de validação e extração de metadados de arquivos PDF.
class PdfService {
  /// Assinatura binária mágica de cabeçalho PDF (%PDF-)
  static const List<int> pdfMagicBytes = [0x25, 0x50, 0x44, 0x46, 0x2D];

  /// Valida se os bytes fornecidos possuem a assinatura binária de um PDF genuíno.
  bool isValidPdfBytes(Uint8List bytes) {
    if (bytes.length < 5) return false;
    for (var i = 0; i < pdfMagicBytes.length; i++) {
      if (bytes[i] != pdfMagicBytes[i]) {
        return false;
      }
    }
    return true;
  }

  /// Valida se um arquivo no disco é um PDF autêntico.
  Future<bool> isValidPdfFile(File file) async {
    if (!await file.exists()) return false;
    final stream = file.openRead(0, 5);
    final chunks = await stream.toList();
    if (chunks.isEmpty) return false;
    final bytes = chunks.first;
    return isValidPdfBytes(Uint8List.fromList(bytes));
  }

  /// Calcula o número de páginas do PDF através de análise de metadados binários.
  /// Lança [InvalidPdfException] caso o arquivo não seja um PDF válido.
  int countPages(Uint8List bytes) {
    if (!isValidPdfBytes(bytes)) {
      throw InvalidPdfException('O arquivo enviado não possui assinatura binária de PDF válida.');
    }

    // Decodifica os bytes como latin1 para garantir 1-to-1 byte mapping sem crash de UTF-8
    final content = String.fromCharCodes(bytes);

    // Método 1: Busca pelo nó raiz /Pages com /Count N
    // Ex: /Type /Pages /Count 15 ou /Count 15 /Type /Pages
    final countRegex = RegExp(r'/Type\s*/Pages.*?/Count\s+(\d+)', dotAll: true);
    final countMatch = countRegex.firstMatch(content);
    if (countMatch != null) {
      final countStr = countMatch.group(1);
      final count = int.tryParse(countStr ?? '');
      if (count != null && count > 0) {
        return count;
      }
    }

    // Método 1b: /Count N em qualquer dicionário /Pages
    final countAltRegex = RegExp(r'/Count\s+(\d+).*?/Type\s*/Pages', dotAll: true);
    final countAltMatch = countAltRegex.firstMatch(content);
    if (countAltMatch != null) {
      final countStr = countAltMatch.group(1);
      final count = int.tryParse(countStr ?? '');
      if (count != null && count > 0) {
        return count;
      }
    }

    // Método 2: Contagem de objetos individuais /Type /Page (sem o s final de /Pages)
    final pageRegex = RegExp(r'/Type\s*/Page\b(?!\s*s)');
    final matches = pageRegex.allMatches(content).length;

    if (matches > 0) {
      return matches;
    }

    // Se for um PDF válido mas sem tags estruturadas explícitas, considera no mínimo 1 página
    return 1;
  }

  /// Extrai o número de páginas diretamente de um arquivo no disco.
  Future<int> countPagesFromFile(File file) async {
    final bytes = await file.readAsBytes();
    return countPages(bytes);
  }
}
