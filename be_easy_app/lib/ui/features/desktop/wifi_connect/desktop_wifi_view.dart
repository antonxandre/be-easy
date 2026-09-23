import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/qr_code_card.dart';
import '../desktop_session_viewmodel.dart';

class DesktopWifiView extends StatelessWidget {
  const DesktopWifiView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DesktopSessionViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
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
                          'Etapa 1 de 3 • Conexão sem Fio',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 80),
                ],
              ),
              const SizedBox(height: 24),

              // Título
              const Text(
                'Conecte seu celular para imprimir',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: const Text(
                  'Para enviar fotos e documentos do seu smartphone diretamente para este computador, conecte-se à nossa rede dedicada.',
                  style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 36),

              // Card Principal L1
              AppCard(
                padding: const EdgeInsets.all(32),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 650;
                    final leftCol = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.wifi_rounded,
                                  color: AppColors.primary, size: 30),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ponto de Acesso',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary),
                                  ),
                                  Text(
                                    'Conexão Direta',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline_rounded,
                                  color: AppColors.primary, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Computador online na rede Wi-Fi (IP: ${vm.localIp}). Se o seu celular já estiver conectado na mesma rede Wi-Fi, você já pode avançar!',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Text(
                          'Abra o Wi-Fi no seu aparelho ou aponte a câmera para o QR Code ao lado:',
                          style: TextStyle(
                              fontSize: 14, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),

                        // Credenciais Wi-Fi
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.dropzoneTint,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              // Linha SSID
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'REDE WI-FI (SSID)',
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textSecondary),
                                        ),
                                        Text(
                                          vm.wifiSsid,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.secondary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Linha Senha
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'SENHA DA REDE',
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textSecondary),
                                        ),
                                        Text(
                                          vm.wifiPassword,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'monospace',
                                              color: AppColors.textPrimary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );

                    final rightCol = Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          QrCodeCard(
                            data: vm.wifiQrData,
                            size: 190,
                            title: 'Conexão via QrCode',
                            subtitle: 'Conecte-se ao wi-fi sem digitar senhas.',
                          ),
                        ],
                      ),
                    );

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: leftCol),
                          const SizedBox(width: 32),
                          Expanded(flex: 2, child: rightCol),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        leftCol,
                        const SizedBox(height: 24),
                        rightCol,
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 36),

              // Botões de Ação
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Já estou conectado no Wi-Fi',
                      icon: Icons.arrow_forward_rounded,
                      height: 64,
                      type: AppButtonType.secondary,
                      onPressed: () => vm.nextStep(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      label: 'Vou usar um Pendrive/Arquivos neste PC',
                      icon: Icons.usb_rounded,
                      height: 64,
                      type: AppButtonType.outline,
                      onPressed: () => vm.nextStep(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Dúvidas ou dificuldades? Toque no botão Ajuda no menu superior.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
