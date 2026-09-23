import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/services/api_service.dart';
import '../../core/colors.dart';
import 'admin/admin_auth_dialog.dart';
import 'desktop_session_viewmodel.dart';
import 'file_upload/desktop_file_upload_view.dart';
import 'order_summary/desktop_order_summary_view.dart';
import 'payment_print/desktop_payment_print_view.dart';
import 'welcome/desktop_welcome_view.dart';
import 'wifi_connect/desktop_wifi_view.dart';

class DesktopMainScreen extends StatelessWidget {
  const DesktopMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DesktopSessionViewModel>();

    Widget currentView;
    switch (vm.currentStep) {
      case 0:
        currentView = const DesktopWelcomeView();
        break;
      case 1:
        currentView = const DesktopWifiView();
        break;
      case 2:
        currentView = const DesktopFileUploadView();
        break;
      case 3:
        currentView = const DesktopOrderSummaryView();
        break;
      case 4:
        currentView = const DesktopPaymentPrintView();
        break;
      default:
        currentView = const DesktopWelcomeView();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.print_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 18, color: AppColors.textPrimary, fontFamily: 'Nunito Sans'),
                children: [
                  TextSpan(text: 'be EASY '),
                  TextSpan(
                    text: 'Print',
                    style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'COMPUTADOR DA LOJA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (vm.currentStep > 0)
            TextButton.icon(
              onPressed: () => vm.resetSession(),
              icon: const Icon(Icons.restart_alt_rounded, size: 18, color: AppColors.secondary),
              label: const Text('Reiniciar', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700)),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.secondary, size: 22),
            tooltip: 'Configurações (Admin)',
            onPressed: () async {
              final apiService = context.read<ApiService>();
              final authenticated = await AdminAuthDialog.show(context, apiService);
              if (authenticated && context.mounted) {
                context.push('/admin');
              }
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: currentView,
        ),
      ),
    );
  }
}
