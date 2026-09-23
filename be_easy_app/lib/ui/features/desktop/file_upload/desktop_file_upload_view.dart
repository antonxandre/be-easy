import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/dropzone_widget.dart';
import '../../../core/widgets/qr_code_card.dart';
import '../desktop_session_viewmodel.dart';

class DesktopFileUploadView extends StatelessWidget {
  const DesktopFileUploadView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DesktopSessionViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: Column(
            children: [
              // Top Bar de Navegação & Stepper
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          'Etapa 2 de 3 • Envio de Arquivos',
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
              const SizedBox(height: 24),

              // Título
              const Text(
                'Como você prefere enviar seu documento?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecione uma das opções abaixo para carregar seu arquivo na impressora.',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),

              if (vm.errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.secondary),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.secondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          vm.errorMessage!,
                          style: const TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

              // Split Screen com Lado Esquerdo (Celular) e Lado Direito (Pendrive)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 750;

                  final mobileCard = AppCard(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.dropzoneTint,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.smartphone_rounded,
                                  color: AppColors.primary, size: 26),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Use seu Celular',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.secondary),
                                  ),
                                  Text(
                                    'Rápido, sem fios e direto da galeria',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Sem instalar app',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        QrCodeCard(
                          data: vm.webAppUrl,
                          size: 180,
                          title: 'Aponte a câmera para enviar',
                          subtitle: 'Carregue do WhatsApp ou galeria',
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Acesse também digitando no navegador do celular:\n${vm.webAppUrl}',
                                style: const TextStyle(
                                    fontSize: 9,
                                    color: AppColors.textSecondary,
                                    fontFamily: 'monospace'),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );

                  final pendriveCard = AppCard(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.dropzoneTint,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.usb_rounded,
                                  color: AppColors.primary, size: 26),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Use um Pendrive/Arquivo',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.secondary),
                                  ),
                                  Text(
                                    'Conecte o USB ou selecione deste computador',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Impressão Direta',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.tertiary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        DropzoneWidget(
                          isProcessing: vm.isLoading,
                          onFileSelected: (path, name, bytes) {
                            vm.handleFileUpload(path, name, bytes);
                          },
                        ),
                        if (vm.isLoading) ...[
                          const SizedBox(height: 16),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text('Validando PDF e calculando páginas...'),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: mobileCard),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 120),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.surface,
                            child: Text(
                              'OU',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                        Expanded(child: pendriveCard),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      mobileCard,
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          '— OU —',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary),
                        ),
                      ),
                      pendriveCard,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
