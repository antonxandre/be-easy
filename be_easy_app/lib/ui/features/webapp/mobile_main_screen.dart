import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import 'mobile_payment/mobile_payment_view.dart';
import 'mobile_session_viewmodel.dart';
import 'mobile_summary/mobile_summary_view.dart';
import 'mobile_upload/mobile_upload_view.dart';

class MobileMainScreen extends StatelessWidget {
  const MobileMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MobileSessionViewModel>();

    Widget currentView;
    switch (vm.currentStep) {
      case 0:
        currentView = const MobileUploadView();
        break;
      case 1:
        currentView = const MobileSummaryView();
        break;
      case 2:
        currentView = const MobilePaymentView();
        break;
      default:
        currentView = const MobileUploadView();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.04),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.print_rounded, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text(
              'be EASY Print',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        titleSpacing: 12,
        actions: [
          if (vm.currentStep > 0)
            TextButton(
              onPressed: () => vm.resetSession(),
              child: const Text('Reiniciar', style: TextStyle(color: AppColors.secondary, fontSize: 13)),
            ),
          const SizedBox(width: 8),
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
