import 'package:be_easy_app/data/services/api_service.dart';
import 'package:be_easy_app/ui/core/theme.dart';
import 'package:be_easy_app/ui/features/desktop/desktop_session_viewmodel.dart';
import 'package:be_easy_app/ui/features/desktop/payment_print/desktop_payment_print_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('DesktopPaymentPrintView exibe progresso e ao atingir 100% transiciona para seção de sucesso', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final vm = DesktopSessionViewModel(apiService: ApiService());
    vm.goToStep(4);
    vm.setPrintProgressForTesting(
      progress: 0.35,
      isCompleted: false,
      statusText: 'Imprimindo página 3 de 10...',
      pagesPrinted: 3,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<DesktopSessionViewModel>.value(value: vm),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: DesktopPaymentPrintView()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Antes de 100%: Exibe status da impressão em andamento
    expect(find.text('Sua impressão já começou!'), findsOneWidget);
    expect(find.text('IMPRIMINDO AGORA'), findsOneWidget);
    expect(find.text('Progresso da impressão'), findsOneWidget);
    expect(find.text('35%'), findsOneWidget);
    expect(find.text('Pague via PIX'), findsOneWidget);

    // Sucesso ainda NÃO deve estar visível
    expect(find.text('Pronto! Suas folhas já foram impressas.'), findsNothing);
    expect(find.text('IMPRESSÃO 100% CONCLUÍDA'), findsNothing);
    expect(find.text('Pode retirar na bandeja!'), findsNothing);

    // 2. Atinge 100% de impressão
    vm.setPrintProgressForTesting(
      progress: 1.0,
      isCompleted: true,
      statusText: 'Todas as 10 páginas impressas com sucesso!',
      pagesPrinted: 10,
    );

    // Anima a transição de fade do AnimatedSwitcher
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // 3. Após 100%: Seção de sucesso substitui a seção anterior
    expect(find.text('Pronto! Suas folhas já foram impressas.'), findsOneWidget);
    expect(find.text('CONCLUÍDO'), findsOneWidget);
    expect(find.text('Pode retirar na bandeja!'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Pague via PIX'), findsOneWidget);
  });
}
