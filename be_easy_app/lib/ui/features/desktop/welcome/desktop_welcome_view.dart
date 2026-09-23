import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../desktop_session_viewmodel.dart';

class DesktopWelcomeView extends StatelessWidget {
  const DesktopWelcomeView({super.key});

  void _showHelpDialog(BuildContext context, String unitPriceFormatted) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            Icon(Icons.help_outline_rounded,
                color: AppColors.secondary, size: 28),
            SizedBox(width: 12),
            Text(
              'Precisa de Ajuda?',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Para imprimir do celular: clique em Começar e aponte a câmera para o QR Code.\n\n'
              '2. Para usar pendrive: conecte o dispositivo na porta USB deste notebook e selecione o PDF.\n\n'
              '3. O valor é de $unitPriceFormatted por página, pago via PIX com liberação imediata da impressão.',
              style: const TextStyle(
                  fontSize: 15, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Entendi',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<DesktopSessionViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              // Header & Status do Terminal
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Ativo • Pronto para uso',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(color: AppColors.secondary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    onPressed: () =>
                        _showHelpDialog(context, vm.unitPriceFormatted),
                    icon: const Icon(Icons.help_outline, size: 20),
                    label: const Text('Ajuda & Dúvidas'),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Logo com Halo Suave
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.print_rounded,
                        size: 54,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Título Principal
              const Text(
                'Impressão de Autoatendimento',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Subtítulo
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: const Text(
                  'Imprima seus documentos na hora, direto do celular, arquivos baixados neste computador ou pendrive.',
                  style: TextStyle(
                    fontSize: 17,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 36),

              // Botão Principal "Começar"
              AppButton(
                label: 'Começar',
                icon: Icons.arrow_forward_rounded,
                height: 64,
                width: 280,
                type: AppButtonType.secondary,
                onPressed: () => vm.nextStep(),
              ),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app_rounded,
                      size: 16, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Clique para iniciar sua sessão',
                    style:
                        TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // 3 Cartões de Destaque Interativos
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  final cards = [
                    _FeatureCard(
                      icon: Icons.qr_code_scanner_rounded,
                      iconColor: AppColors.primary,
                      title: 'Do Celular (QR Code)',
                      subtitle:
                          'Aponte a câmera, envie fotos ou PDFs via navegador.',
                      onTap: () => vm.goToStep(1),
                    ),
                    _FeatureCard(
                      icon: Icons.usb_rounded,
                      iconColor: AppColors.tertiary,
                      title: 'Pendrive USB',
                      subtitle:
                          'Conecte sua unidade de memória na porta lateral deste notebook.',
                      onTap: () => vm.goToStep(2),
                    ),
                    _FeatureCard(
                      icon: Icons.folder_open_rounded,
                      iconColor: AppColors.secondary,
                      title: 'Arquivos Locais',
                      subtitle:
                          'Acesse comprovantes e documentos já salvos neste computador.',
                      onTap: () => vm.goToStep(2),
                    ),
                  ];

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: cards
                          .map((c) => Expanded(
                              child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: c)))
                          .toList(),
                    );
                  }
                  return Column(
                    children: cards
                        .map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: c))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 40),

              // Barra de Segurança Inferior
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.borderTanLight.withValues(alpha: 0.5)),
                ),
                child: const Wrap(
                  alignment: WrapAlignment.spaceAround,
                  spacing: 24,
                  runSpacing: 12,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.qr_code_2_rounded,
                            color: AppColors.primary, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Pagamento via PIX',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.verified_user_rounded,
                            color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Arquivos deletados após a impressão',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
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

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        child: AppCard(
          onTap: widget.onTap,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          border: Border.all(
            color: _isHovered
                ? widget.iconColor.withValues(alpha: 0.5)
                : AppColors.borderTanLight.withValues(alpha: 0.4),
            width: _isHovered ? 1.5 : 1,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: _isHovered
                      ? widget.iconColor.withValues(alpha: 0.15)
                      : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 30),
              ),
              const SizedBox(height: 14),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                widget.subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
