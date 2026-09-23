import 'package:be_easy_app/data/services/api_service.dart';
import 'package:be_easy_app/ui/core/theme.dart';
import 'package:be_easy_app/ui/features/desktop/desktop_main_screen.dart';
import 'package:be_easy_app/ui/features/desktop/desktop_session_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Fluxo do Computador da Loja: Navega de Boas-Vindas até Wi-Fi e Seleção', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final vm = DesktopSessionViewModel(apiService: ApiService());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<DesktopSessionViewModel>.value(value: vm),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DesktopMainScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tela 1: Boas-vindas
    expect(find.text('Impressão de Autoatendimento'), findsOneWidget);
    expect(find.text('Começar'), findsOneWidget);

    // Clica em Começar
    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();

    // Tela 2: Conexão Wi-Fi
    expect(find.text('Conecte seu celular para imprimir'), findsOneWidget);
    expect(find.text('BE EASY - TEFNet_5g'), findsOneWidget);
    expect(find.text('Já estou conectado no Wi-Fi'), findsOneWidget);

    // Clica em "Já estou conectado no Wi-Fi"
    final wifiBtn = find.text('Já estou conectado no Wi-Fi');
    await tester.ensureVisible(wifiBtn);
    await tester.pumpAndSettle();
    await tester.tap(wifiBtn);
    await tester.pumpAndSettle();

    // Tela 3: Envio de Arquivos
    expect(find.text('Como você prefere enviar seu documento?'), findsOneWidget);
    expect(find.text('Use seu Celular'), findsOneWidget);
    expect(find.text('Use um Pendrive/Arquivo'), findsOneWidget);

    // Simula transição para Tela de Resumo (Etapa 3)
    vm.goToStep(3);
    await tester.pumpAndSettle();
    expect(find.text('Resumo da Impressão'), findsOneWidget);
    expect(find.text('Observação importante'), findsOneWidget);
    expect(find.textContaining('Certifique-se de que a impressora está ligada'), findsOneWidget);
    expect(find.text('Confirmar e Imprimir'), findsOneWidget);
  });
}
