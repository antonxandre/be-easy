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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              // Top Bar de Navegação & Stepper
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(color: AppColors.borderTanLight),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                    ),
                    onPressed: () => vm.previousStep(),
                    icon: const Icon(Icons.arrow_back_rounded, size: 15),
                    label: const Text('Voltar', style: TextStyle(fontSize: 12)),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Etapa 3 de 4 • Confirmação & Cálculo',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.dropzoneTint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user_rounded,
                            size: 13, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'Ambiente Seguro',
                          style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Card de Resumo
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    // Header horizontal do Resumo
                    Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.dropzoneTint,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.description_rounded,
                                size: 24,
                                color: AppColors.secondary,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text(
                                  'PDF',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Resumo da Impressão',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                'Confira os detalhes e valores antes de emitir a impressão',
                                style: TextStyle(
                                    fontSize: 11.5, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Painel com Especificações do Arquivo
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Linha do Arquivo
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.attach_file_rounded,
                                    color: AppColors.secondary, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Arquivo carregado',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary),
                                    ),
                                    Text(
                                      fileName,
                                      style: const TextStyle(
                                          fontSize: 13,
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
                          const Divider(height: 12),

                          // Métricas (Páginas e Preço)
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.layers_rounded,
                                          color: AppColors.primary, size: 16),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text('Total de páginas',
                                                style: TextStyle(
                                                    fontSize: 9.5,
                                                    color:
                                                        AppColors.textSecondary)),
                                            Text('$pageCount Páginas',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.sell_rounded,
                                          color: AppColors.primary, size: 16),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text('Preço unitário',
                                                style: TextStyle(
                                                    fontSize: 9.5,
                                                    color:
                                                        AppColors.textSecondary)),
                                            Text(
                                                'R\$ ${unitPrice.toStringAsFixed(2)} / pág',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Chips de Configuração
                          const Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _ConfigChip(icon: Icons.contrast_rounded, label: 'Preto & Branco'),
                              _ConfigChip(icon: Icons.crop_portrait_rounded, label: 'Formato A4'),
                              _ConfigChip(icon: Icons.menu_book_rounded, label: 'Frente (Simples)'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Banner com Valor Total
                    PriceBanner(
                      totalPrice: totalPrice,
                      pageCount: pageCount,
                      unitPrice: unitPrice,
                    ),
                    const SizedBox(height: 6),

                    // Observação para certificar se a impressora está ligada
                    const PrinterCheckNotice(),
                    const SizedBox(height: 8),

                    // Botão Principal de Confirmação
                    AppButton(
                      label: 'Confirmar e Imprimir',
                      icon: Icons.print_rounded,
                      height: 44,
                      width: double.infinity,
                      type: AppButtonType.primary,
                      isLoading: vm.isLoading,
                      onPressed: () => vm.confirmAndStartPrinting(),
                    ),
                    const SizedBox(height: 2),
                    TextButton(
                      onPressed: () => vm.goToStep(2),
                      child: const Text(
                        'Trocar arquivo ou cancelar',
                        style: TextStyle(
                            fontSize: 11.5,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderTanLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
