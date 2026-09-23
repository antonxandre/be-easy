import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/qr_code_card.dart';
import '../mobile_session_viewmodel.dart';

class MobilePaymentView extends StatelessWidget {
  const MobilePaymentView({super.key});

  void _copyPixCode(BuildContext context, String pixPayload) {
    Clipboard.setData(ClipboardData(text: pixPayload));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código PIX Copia e Cola copiado com sucesso!'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MobileSessionViewModel>();
    final job = vm.currentJob;

    final totalPrice = job?.totalPrice ?? 30.0;
    final pixPayload = job?.pixPayload ?? '00020101021126360014br.gov.bcb.pix011465717703000180520400005303986540530.005802BR5913BE EASY PRINT6009SAO PAULO62070503***63047665';

    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final formattedTotal = currencyFormat.format(totalPrice);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Stepper
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Etapa 3 de 3 • PIX',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Pague via PIX',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Copie o código ou aponte a câmera para efetuar o pagamento instantâneo.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // QR Code
                    QrCodeCard(
                      data: pixPayload,
                      size: 170,
                      centerIcon: Icons.pix_rounded,
                    ),
                    const SizedBox(height: 12),

                    // Timer Regressivo
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Icon(Icons.schedule_rounded, size: 16, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        const Text(
                          'Expira em: ',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        Text(
                          vm.formattedTimer,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.secondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Valor em Destaque
                    const Text(
                      'Valor Total a Pagar',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    Text(
                      formattedTotal,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Copia e Cola
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.dropzoneTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              pixPayload,
                              style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surface,
                              foregroundColor: AppColors.secondary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => _copyPixCode(context, pixPayload),
                            icon: const Icon(Icons.copy_rounded, size: 16),
                            label: const Text('Copiar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Aviso Reafirmador
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderTanLight.withValues(alpha: 0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Pagamento instantâneo. Suas folhas já estão sendo impressas e disponíveis na impressora para retirada!',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botão Finalizar
              AppButton(
                label: 'Já Paguei / Finalizar',
                icon: Icons.check_circle_rounded,
                height: 56,
                type: AppButtonType.primary,
                onPressed: () => vm.resetSession(),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => vm.goToStep(1),
                child: const Text('Voltar para o resumo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
