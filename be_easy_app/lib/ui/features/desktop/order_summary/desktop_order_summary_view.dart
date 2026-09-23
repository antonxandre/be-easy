import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/price_banner.dart';
import '../../../core/widgets/printer_check_notice.dart';
import '../desktop_session_viewmodel.dart';

class DesktopOrderSummaryView extends StatelessWidget {
  const DesktopOrderSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DesktopSessionViewModel>();
    final job = vm.currentJob;

    final fileName = job?.fileName ?? 'documento.pdf';
    final pageCount = job?.pageCount ?? 1;
    final totalPrice = job?.totalPrice ?? 2.0;
    final unitPrice = job?.unitPrice ?? 2.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              // Top Bar de Navegação & Stepper
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(color: AppColors.borderTanLight),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => vm.previousStep(),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Voltar'),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                          'Etapa 3 de 4 • Confirmação & Cálculo',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.dropzoneTint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user_rounded,
                            size: 16, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          'Ambiente Seguro',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Card de Resumo
              AppCard(
                padding: const EdgeInsets.all(36),
                child: Column(
                  children: [
                    // Ícone com Badge PDF
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.dropzoneTint,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.description_rounded,
                            size: 50,
                            color: AppColors.secondary,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'PDF',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Resumo da Impressão',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Confira os detalhes e valores antes de emitir a impressão',
                      style: TextStyle(
                          fontSize: 15, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Painel com Especificações do Arquivo
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          // Linha do Arquivo
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.attach_file_rounded,
                                    color: AppColors.secondary, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Arquivo carregado',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary),
                                    ),
                                    Text(
                                      fileName,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 28),

                          // Métricas (Páginas e Preço)
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.layers_rounded,
                                          color: AppColors.primary, size: 24),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Total de páginas',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color:
                                                      AppColors.textSecondary)),
                                          Text('$pageCount Páginas',
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.sell_rounded,
                                          color: AppColors.primary, size: 24),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Preço unitário',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color:
                                                      AppColors.textSecondary)),
                                          Text(
                                              'R\$ ${unitPrice.toStringAsFixed(2)} / pág',
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Chips de Configuração
                          const Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _ConfigChip(icon: Icons.contrast_rounded, label: 'Preto & Branco'),
                              _ConfigChip(icon: Icons.crop_portrait_rounded, label: 'Formato A4'),
                              _ConfigChip(icon: Icons.menu_book_rounded, label: 'Frente (Simples)'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Banner com Valor Total
                    PriceBanner(
                      totalPrice: totalPrice,
                      pageCount: pageCount,
                      unitPrice: unitPrice,
                    ),
                    const SizedBox(height: 20),

                    // Observação para certificar se a impressora está ligada
                    const PrinterCheckNotice(),
                    const SizedBox(height: 24),

                    // Botão Principal de Confirmação
                    AppButton(
                      label: 'Confirmar e Imprimir',
                      icon: Icons.print_rounded,
                      height: 64,
                      width: double.infinity,
                      type: AppButtonType.primary,
                      isLoading: vm.isLoading,
                      onPressed: () => vm.confirmAndStartPrinting(),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => vm.goToStep(2),
                      child: const Text(
                        'Trocar arquivo ou cancelar',
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600),
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

class _ConfigChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ConfigChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderTanLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
