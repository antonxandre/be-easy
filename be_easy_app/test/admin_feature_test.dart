import 'package:be_easy_app/data/models/admin_config_dto.dart';
import 'package:be_easy_app/data/services/api_service.dart';
import 'package:be_easy_app/ui/features/desktop/admin/admin_auth_dialog.dart';
import 'package:be_easy_app/ui/features/desktop/admin/admin_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockApiService extends ApiService {
  AdminConfigDto mockConfig = AdminConfigDto(
    pixKey: '12345678000199',
    merchantName: 'TEST MERCHANT',
    merchantCity: 'TEST CITY',
    unitPrice: 2.50,
    wifiSsid: 'Rede_Teste',
    wifiPassword: 'senha_teste',
    customIp: '192.168.0.50',
    serverPort: 8080,
    selectedPrinter: 'MockPrinter',
    useMockPrinter: true,
  );

  @override
  Future<AdminConfigDto> getConfig() async => mockConfig;

  @override
  Future<bool> saveConfig(AdminConfigDto config) async {
    mockConfig = config;
    return true;
  }

  @override
  Future<bool> verifyAdminPassword(String password) async {
    return password == 'BeEasy@2026';
  }

  @override
  Future<List<PrinterInfoDto>> getPrinters() async {
    return [
      PrinterInfoDto(name: 'Simulador Virtual', isMock: true, isDefault: true),
      PrinterInfoDto(name: 'HP LaserJet USB', isMock: false, isDefault: false),
    ];
  }

  @override
  Future<bool> printTestPage({required String printerName, required bool isMock}) async {
    return true;
  }
}

void main() {
  group('Admin Feature Tests', () {
    late MockApiService mockApi;

    setUp(() {
      mockApi = MockApiService();
    });

    test('AdminViewModel deve carregar configurações e alterar preço e rede', () async {
      final vm = AdminViewModel(apiService: mockApi);
      await vm.loadData();

      expect(vm.unitPrice, 2.50);
      expect(vm.wifiSsid, 'Rede_Teste');
      expect(vm.customIp, '192.168.0.50');
      expect(vm.printers.length, 2);

      // Altera preço
      vm.setUnitPrice(3.00);
      expect(vm.unitPrice, 3.00);

      // Altera rede
      vm.setWifiSsid('Novo_SSID');
      expect(vm.wifiSsid, 'Novo_SSID');

      // Salva
      final saved = await vm.saveConfig();
      expect(saved, isTrue);
      expect(mockApi.mockConfig.unitPrice, 3.00);
      expect(mockApi.mockConfig.wifiSsid, 'Novo_SSID');
    });

    testWidgets('AdminAuthDialog valida senha e fecha com true em sucesso', (WidgetTester tester) async {
      bool? authResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  authResult = await AdminAuthDialog.show(context, mockApi);
                },
                child: const Text('Abrir Admin'),
              ),
            ),
          ),
        ),
      );

      // Clica para abrir o modal de autenticação
      await tester.tap(find.text('Abrir Admin'));
      await tester.pumpAndSettle();

      expect(find.text('Acesso Administrativo'), findsOneWidget);

      // Digita senha incorreta
      await tester.enterText(find.byType(TextField), 'senha_errada');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Senha incorreta. Tente novamente.'), findsOneWidget);
      expect(authResult, isNull);

      // Digita senha correta
      await tester.enterText(find.byType(TextField), 'BeEasy@2026');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Modal deve ter sido fechado
      expect(find.text('Acesso Administrativo'), findsNothing);
      expect(authResult, isTrue);
    });
  });
}
