import 'package:be_easy_app/data/services/api_service.dart';
import 'package:be_easy_app/main.dart';
import 'package:be_easy_app/ui/features/desktop/desktop_session_viewmodel.dart';
import 'package:be_easy_app/ui/features/webapp/mobile_session_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BeEasyApp carrega corretamente e exibe título e botão Começar', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const BeEasyApp());
    await tester.pumpAndSettle();

    expect(find.text('Impressão de Autoatendimento'), findsOneWidget);
    expect(find.text('Começar'), findsOneWidget);
    expect(find.text('Do Celular (QR Code)'), findsOneWidget);
    expect(find.text('Pendrive USB'), findsOneWidget);
    expect(find.text('Arquivos Locais'), findsOneWidget);
  });

  testWidgets('cards na tela inicial são tocáveis e navegam para os passos esperados', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const BeEasyApp());
    await tester.pumpAndSettle();

    // 1. Card "Do Celular (QR Code)" leva à Etapa 1 (Wi-Fi)
    await tester.tap(find.text('Do Celular (QR Code)'));
    await tester.pumpAndSettle();
    expect(find.text('Conecte seu celular para imprimir'), findsOneWidget);

    // Reinicia a sessão para voltar à tela inicial
    await tester.tap(find.text('Reiniciar'));
    await tester.pumpAndSettle();
    expect(find.text('Impressão de Autoatendimento'), findsOneWidget);

    // 2. Card "Pendrive USB" leva à Etapa 2 (Envio de Arquivos)
    await tester.tap(find.text('Pendrive USB'));
    await tester.pumpAndSettle();
    expect(find.text('Como você prefere enviar seu documento?'), findsOneWidget);

    // Reinicia a sessão para voltar à tela inicial
    await tester.tap(find.text('Reiniciar'));
    await tester.pumpAndSettle();
    expect(find.text('Impressão de Autoatendimento'), findsOneWidget);

    // 3. Card "Arquivos Locais" também leva à mesma tela (Etapa 2 - Envio de Arquivos)
    await tester.tap(find.text('Arquivos Locais'));
    await tester.pumpAndSettle();
    expect(find.text('Como você prefere enviar seu documento?'), findsOneWidget);
  });

  group('DesktopSessionViewModel', () {
    test('inicia na etapa 0 e avança corretamente', () {
      final vm = DesktopSessionViewModel(apiService: ApiService());
      expect(vm.currentStep, 0);

      vm.nextStep();
      expect(vm.currentStep, 1);

      vm.goToStep(3);
      expect(vm.currentStep, 3);

      vm.previousStep();
      expect(vm.currentStep, 2);

      vm.resetSession();
      expect(vm.currentStep, 0);
    });
  });

  group('MobileSessionViewModel', () {
    test('inicia na etapa 0 e formata timer', () {
      final vm = MobileSessionViewModel(apiService: ApiService());
      expect(vm.currentStep, 0);
      expect(vm.formattedTimer, '10:00');

      vm.goToStep(1);
      expect(vm.currentStep, 1);

      vm.resetSession();
      expect(vm.currentStep, 0);
    });
  });
}
