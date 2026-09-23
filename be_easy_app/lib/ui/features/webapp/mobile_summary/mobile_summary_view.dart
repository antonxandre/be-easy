import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/printer_check_notice.dart';
import '../mobile_session_viewmodel.dart';

class MobileSummaryView extends StatelessWidget {
  const MobileSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MobileSessionViewModel>();
    final job = vm.currentJob;

    final fileName = job?.fileName ?? 'documento.pdf';
    final pageCount = job?.pageCount ?? 1;
    final totalPrice = job?.totalPrice ?? 2.0;
    final unitPrice = job?.unitPrice ?? 2.0;

    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final formattedTotal = currencyFormat.format(totalPrice);
    final formattedUnit = currencyFormat.format(unitPrice);

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                        'Etapa 2 de 3 • Resumo',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Confirmação do Pedido',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Confira as especificações antes de prosseguir com o pagamento PIX.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Dados do Documento
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.dropzoneTint,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.picture_as_pdf_rounded,
                              color: AppColors.secondary, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileName,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '$pageCount páginas • Preto & Branco (A4)',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28),

                    // Caixa de Preço
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.dropzoneTint,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Valor Total a Pagar',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.tertiary,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '$pageCount cópias PB • $formattedUnit/un',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formattedTotal,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Observação para certificar se a impressora está ligada
              const PrinterCheckNotice(),
              const SizedBox(height: 16),

              // Botões de Ação
              AppButton(
                label: 'Confirmar e Ir para Pagamento',
                icon: Icons.arrow_forward_rounded,
                height: 56,
                type: AppButtonType.secondary,
                onPressed: () => vm.confirmJob(),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  side: const BorderSide(color: AppColors.borderTanLight),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => vm.goToStep(0),
                icon: const Icon(Icons.replay_rounded, size: 18),
                label: const Text('Trocar arquivo ou cancelar'),
              ),
              const SizedBox(height: 24),

              // Dica
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.borderTanLight.withValues(alpha: 0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.laptop_mac_rounded,
                        color: AppColors.primary, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Acompanhe também na tela do computador da loja. A impressão inicia imediatamente!',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
