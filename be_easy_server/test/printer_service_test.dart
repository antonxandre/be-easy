import 'package:be_easy_server/src/services/pdf_service.dart';
import 'package:be_easy_server/src/services/printer_service.dart';
import 'package:test/test.dart';

void main() {
  group('PrinterService', () {
    late PrinterService printerService;
    late PdfService pdfService;

    setUp(() {
      printerService = PrinterService();
      pdfService = PdfService();
    });

    test('deve listar impressoras contendo sempre o Simulador Virtual', () async {
      final printers = await printerService.getAvailablePrinters();
      expect(printers.isNotEmpty, isTrue);
      expect(printers.any((p) => p.isMock), isTrue);
    });

    test('deve gerar PDF de página de teste válido', () {
      final bytes = printerService.generateTestPagePdf(printerName: 'Impressora Teste');
      expect(bytes.isNotEmpty, isTrue);
      expect(pdfService.isValidPdfBytes(bytes), isTrue);
      expect(pdfService.countPages(bytes), 1);
    });

    test('deve executar teste de impressão em modo simulado com sucesso', () async {
      final success = await printerService.printTestPage(
        printerName: 'Simulador Virtual',
        isMock: true,
      );
      expect(success, isTrue);
    });
  });
}
