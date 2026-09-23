import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../mobile_session_viewmodel.dart';

class MobileUploadView extends StatelessWidget {
  const MobileUploadView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MobileSessionViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Stepper Pill
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
                        'Etapa 1 de 3 • PDF',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Enviar documento pelo celular',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Toque abaixo para carregar seu arquivo da galeria, downloads ou WhatsApp para a impressora.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.35),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              if (vm.errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.secondary),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          vm.errorMessage!,
                          style: const TextStyle(fontSize: 13, color: AppColors.secondary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

              // Área de Toque para Seleção do Arquivo
              AppCard(
                padding: const EdgeInsets.all(24),
                child: InkWell(
                  onTap: vm.isUploading ? null : () => vm.pickAndUploadFile(),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.dropzoneTint,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10),
                            ],
                          ),
                          child: const Icon(Icons.upload_file_rounded, color: AppColors.primary, size: 34),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Toque para escolher o PDF',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Suporta documentos de até 50 MB',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (vm.isUploading) ...[
                const SizedBox(height: 20),
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Enviando para o computador...', style: TextStyle(fontWeight: FontWeight.w600)),
                          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: vm.uploadProgress,
                          minHeight: 8,
                          backgroundColor: AppColors.surfaceContainer,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Botão Principal
              AppButton(
                label: 'Selecionar PDF no Celular',
                icon: Icons.attach_file_rounded,
                height: 56,
                type: AppButtonType.primary,
                isLoading: vm.isUploading,
                onPressed: () => vm.pickAndUploadFile(),
              ),
              const SizedBox(height: 24),

              // Badge de Segurança
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user_rounded, color: AppColors.tertiary, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Ambiente seguro be EASY: Seus arquivos são criptografados temporariamente e excluídos logo após a impressão.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
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
