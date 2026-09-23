import 'package:be_easy_app/data/services/api_service.dart';
import 'package:be_easy_app/ui/core/theme.dart';
import 'package:be_easy_app/ui/features/webapp/mobile_main_screen.dart';
import 'package:be_easy_app/ui/features/webapp/mobile_session_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Fluxo Mobile: Exibe tela de upload e avança para resumo e PIX', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final vm = MobileSessionViewModel(apiService: ApiService());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MobileSessionViewModel>.value(value: vm),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MobileMainScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tela 6: Upload Mobile
    expect(find.text('Enviar documento pelo celular'), findsOneWidget);
    expect(find.text('Selecionar PDF no Celular'), findsOneWidget);

    // Simula transição para Tela 7 (Resumo)
    vm.goToStep(1);
    await tester.pumpAndSettle();
    expect(find.text('Confirmação do Pedido'), findsOneWidget);
    expect(find.text('Observação importante'), findsOneWidget);
    expect(find.textContaining('Certifique-se de que a impressora está ligada'), findsOneWidget);
    expect(find.text('Confirmar e Ir para Pagamento'), findsOneWidget);

    // Simula transição para Tela 8 (Pagamento PIX)
    vm.goToStep(2);
    await tester.pumpAndSettle();
    expect(find.text('Pague via PIX'), findsOneWidget);
    expect(find.text('Já Paguei / Finalizar'), findsOneWidget);
  });
}
