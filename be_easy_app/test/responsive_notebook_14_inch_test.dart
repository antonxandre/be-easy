import 'package:be_easy_app/data/models/print_job_dto.dart';
import 'package:be_easy_app/data/services/api_service.dart';
import 'package:be_easy_app/ui/core/theme.dart';
import 'package:be_easy_app/ui/features/desktop/admin/admin_settings_screen.dart';
import 'package:be_easy_app/ui/features/desktop/desktop_main_screen.dart';
import 'package:be_easy_app/ui/features/desktop/desktop_session_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('Responsividade - Tela de Notebook de 14 polegadas (1366x768 e 1280x640)', () {
    const notebookSizes = [
      Size(1366, 768), // Resolução nativa padrão 14"
      Size(1366, 620), // 14" com barra de tarefas do Windows e barra de título
      Size(1280, 600), // 14" FHD com escala 150% (viewport efetivo 1280x600)
    ];

    for (final size in notebookSizes) {
      testWidgets('Etapas 0 a 4 cabem na tela de notebook $size sem overflow e com botões principais visíveis', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final vm = DesktopSessionViewModel(apiService: ApiService());

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<ApiService>(create: (_) => ApiService()),
              ChangeNotifierProvider<DesktopSessionViewModel>.value(value: vm),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const DesktopMainScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Etapa 0: Boas-Vindas
        expect(tester.takeException(), isNull, reason: 'Sem overflow na Etapa 0 para $size');
        final startBtn = find.text('Começar');
        expect(startBtn, findsOneWidget);
        // Verifica se o botão "Começar" está visível na tela sem rolagem
        final startBtnBox = tester.getRect(startBtn);
        expect(startBtnBox.bottom, lessThanOrEqualTo(size.height),
            reason: 'Botão "Começar" deve estar visível sem scroll no tamanho $size');

        // 2. Etapa 1: Conexão Wi-Fi
        vm.goToStep(1);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Sem overflow na Etapa 1 para $size');
        final wifiBtn = find.text('Já estou conectado no Wi-Fi');
        expect(wifiBtn, findsOneWidget);
        final wifiBtnBox = tester.getRect(wifiBtn);
        expect(wifiBtnBox.bottom, lessThanOrEqualTo(size.height),
            reason: 'Botão "Já estou conectado no Wi-Fi" deve estar visível sem scroll no tamanho $size');

        // 3. Etapa 2: Envio de Arquivos
        vm.goToStep(2);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Sem overflow na Etapa 2 para $size');
        expect(find.text('Como você prefere enviar seu documento?'), findsOneWidget);
        expect(find.text('Use seu Celular'), findsOneWidget);
        expect(find.text('Use um Pendrive/Arquivo'), findsOneWidget);

        // 4. Etapa 3: Resumo do Pedido
        vm.setCurrentJobForTesting(PrintJobDto(
          id: 'test-job-1',
          fileName: 'apostila_estudos.pdf',
          pageCount: 12,
          unitPrice: 2.0,
          totalPrice: 24.0,
          status: 'aguardando_confirmacao',
          source: 'desktop_usb',
          pixPayload: '00020126580014br.gov.bcb.pix...',
          pixTxid: 'TX123456789',
        ));
        vm.goToStep(3);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Sem overflow na Etapa 3 para $size');
        final confirmBtn = find.text('Confirmar e Imprimir');
        expect(confirmBtn, findsOneWidget);
        final confirmBtnBox = tester.getRect(confirmBtn);
        expect(confirmBtnBox.bottom, lessThanOrEqualTo(size.height),
            reason: 'Botão "Confirmar e Imprimir" deve estar visível sem scroll no tamanho $size');

        // 5. Etapa 4: Pagamento e Impressão
        vm.goToStep(4);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Sem overflow na Etapa 4 para $size');
        final finishBtn = find.text('Já Paguei / Finalizar Sessão');
        expect(finishBtn, findsOneWidget);
      });
    }

    testWidgets('AdminSettingsScreen carrega sem overflow em tela 1366x768', (tester) async {
      tester.view.physicalSize = const Size(1366, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ApiService>(create: (_) => ApiService()),
            ChangeNotifierProvider<DesktopSessionViewModel>(
              create: (_) => DesktopSessionViewModel(apiService: ApiService()),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AdminSettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Configurações do Terminal'), findsOneWidget);
      expect(find.text('Configurações de Rede & IP'), findsOneWidget);
      expect(find.text('Busca e Seleção da Impressora'), findsOneWidget);
    });
  });
}
