import 'dart:typed_data';
import 'package:be_easy_server/src/services/pdf_service.dart';
import 'package:test/test.dart';

void main() {
  group('PdfService', () {
    late PdfService pdfService;

    setUp(() {
      pdfService = PdfService();
    });

    test('deve validar magic bytes %PDF- como autênticos', () {
      final validPdfBytes = Uint8List.fromList([
        0x25, 0x50, 0x44, 0x46, 0x2D, // %PDF-
        0x31, 0x2E, 0x34, 0x0A,
      ]);

      expect(pdfService.isValidPdfBytes(validPdfBytes), isTrue);
    });

    test('deve rejeitar arquivos que não iniciam com %PDF-', () {
      final invalidBytes = Uint8List.fromList([
        0x4D, 0x5A, 0x90, 0x00, // Executável Windows (MZ)
        0x03, 0x00, 0x00, 0x00,
      ]);

      expect(pdfService.isValidPdfBytes(invalidBytes), isFalse);
      expect(
        () => pdfService.countPages(invalidBytes),
        throwsA(isA<InvalidPdfException>()),
      );
    });

    test('deve extrair contagem de páginas via /Count em /Pages', () {
      final samplePdf = '''
%PDF-1.4
1 0 obj
<<
  /Type /Pages
  /Count 15
  /Kids [ 3 0 R 4 0 R ]
>>
endobj
%%EOF
''';
      final bytes = Uint8List.fromList(samplePdf.codeUnits);
      expect(pdfService.countPages(bytes), 15);
    });

    test('deve extrair contagem de páginas via contagem de objetos /Type /Page', () {
      final samplePdf = '''
%PDF-1.4
1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj
3 0 obj << /Type /Page /Parent 2 0 R >> endobj
4 0 obj << /Type /Page /Parent 2 0 R >> endobj
5 0 obj << /Type /Page /Parent 2 0 R >> endobj
%%EOF
''';
      final bytes = Uint8List.fromList(samplePdf.codeUnits);
      expect(pdfService.countPages(bytes), 3);
    });
  });
}
