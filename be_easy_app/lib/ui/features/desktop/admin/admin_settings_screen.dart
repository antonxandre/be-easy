import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../data/services/api_service.dart';
import '../../../core/colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/qr_code_card.dart';
import '../desktop_session_viewmodel.dart';
import 'admin_viewmodel.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = context.read<ApiService>();

    return ChangeNotifierProvider(
      create: (_) => AdminViewModel(apiService: apiService),
      child: const _AdminSettingsContent(),
    );
  }
}

class _AdminSettingsContent extends StatefulWidget {
  const _AdminSettingsContent();

  @override
  State<_AdminSettingsContent> createState() => _AdminSettingsContentState();
}

class _AdminSettingsContentState extends State<_AdminSettingsContent> {
  final _customIpController = TextEditingController();
  final _wifiSsidController = TextEditingController();
  final _wifiPasswordController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _pixKeyController = TextEditingController();
  final _merchantNameController = TextEditingController();
  final _merchantCityController = TextEditingController();

  bool _initialized = false;
  bool _obscureWifiPassword = true;

  @override
  void dispose() {
    _customIpController.dispose();
    _wifiSsidController.dispose();
    _wifiPasswordController.dispose();
    _unitPriceController.dispose();
    _pixKeyController.dispose();
    _merchantNameController.dispose();
    _merchantCityController.dispose();
    super.dispose();
  }

  void _syncControllers(AdminViewModel vm) {
    if (!_initialized && !vm.isLoading) {
      _customIpController.text = vm.customIp;
      _wifiSsidController.text = vm.wifiSsid;
      _wifiPasswordController.text = vm.wifiPassword;
      _unitPriceController.text = vm.unitPrice.toStringAsFixed(2);
      _pixKeyController.text = vm.pixKey;
      _merchantNameController.text = vm.merchantName;
      _merchantCityController.text = vm.merchantCity;
      _initialized = true;
    }
  }

  void _showChangePasswordDialog(BuildContext context, AdminViewModel vm) {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    String? dialogError;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppColors.surface,
          title: const Row(
            children: [
              Icon(Icons.lock_reset_rounded, color: AppColors.secondary, size: 26),
              SizedBox(width: 10),
              Text('Alterar Senha Admin', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPassCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha Atual',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPassCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Nova Senha',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPassCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Nova Senha',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                if (dialogError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    dialogError!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (newPassCtrl.text != confirmPassCtrl.text) {
                        setDialogState(() => dialogError = 'A nova senha e a confirmação não conferem.');
                        return;
                      }
                      if (newPassCtrl.text.length < 4) {
                        setDialogState(() => dialogError = 'A nova senha deve ter no mínimo 4 caracteres.');
                        return;
                      }

                      setDialogState(() {
                        isSubmitting = true;
                        dialogError = null;
                      });

                      final success = await vm.changePassword(
                        currentPassCtrl.text.trim(),
                        newPassCtrl.text.trim(),
                      );

                      if (success) {
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      } else {
                        setDialogState(() {
                          isSubmitting = false;
                          dialogError = 'Senha atual incorreta.';
                        });
                      }
                    },
              child: const Text('Salvar Nova Senha'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    _syncControllers(vm);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.secondary),
          tooltip: 'Voltar ao Terminal',
          onPressed: () {
            // Atualiza ViewModel da sessão antes de sair
            try {
              context.read<DesktopSessionViewModel>().refreshConfig();
            } catch (_) {}
            context.go('/');
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.secondary, size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'Configurações do Terminal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
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
                  const SizedBox(width: 6),
                  Text(
                    'Porta ${vm.serverPort} • Online',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.secondary,
              side: const BorderSide(color: AppColors.borderTanLight),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            onPressed: () {
              try {
                context.read<DesktopSessionViewModel>().refreshConfig();
              } catch (_) {}
              context.go('/');
            },
            icon: const Icon(Icons.store_rounded, size: 18),
            label: const Text('Voltar ao Atendimento', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Feedback Status Banner
                        if (vm.statusMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: vm.isSuccessMessage
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: vm.isSuccessMessage
                                    ? AppColors.primary.withValues(alpha: 0.4)
                                    : AppColors.error.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  vm.isSuccessMessage ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                                  color: vm.isSuccessMessage ? AppColors.primary : AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    vm.statusMessage!,
                                    style: TextStyle(
                                      color: vm.isSuccessMessage ? AppColors.secondary : AppColors.error,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  onPressed: () => vm.clearStatusMessage(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Seção 1: Rede e IP
                        _buildNetworkCard(context, vm),
                        const SizedBox(height: 16),

                        // Seção 2: Impressora e Spooler
                        _buildPrinterCard(context, vm),
                        const SizedBox(height: 16),

                        // Seção 3: Valor por Página e PIX
                        _buildPricingCard(context, vm),
                        const SizedBox(height: 16),

                        // Seção 4: Segurança do Painel
                        _buildSecurityCard(context, vm),
                        const SizedBox(height: 16),

                        // Seção 5: Inicialização do Totem (Startup)
                        _buildStartupCard(context, vm),
                        const SizedBox(height: 24),

                        // Botão Flutuante de Salvar
                        Center(
                          child: AppButton(
                            label: 'Salvar Configurações',
                            icon: Icons.check_circle_outline_rounded,
                            height: 48,
                            width: 280,
                            isLoading: vm.isSaving,
                            type: AppButtonType.secondary,
                            onPressed: () async {
                              final ok = await vm.saveConfig();
                              if (ok && context.mounted) {
                                try {
                                  context.read<DesktopSessionViewModel>().refreshConfig();
                                } catch (_) {}
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'As alterações serão salvas imediatamente em disco e aplicadas ao terminal.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildNetworkCard(BuildContext context, AdminViewModel vm) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.wifi_tethering_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configurações de Rede & IP',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Defina o endereço de acesso dos smartphones e o Wi-Fi da loja.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 12),

          // Seletor de Modo de IP
          const Text('Modo de Identificação de IP:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Automático (DHCP / Placa de Rede)'),
                selected: vm.ipMode == 'auto',
                onSelected: (sel) {
                  if (sel) vm.setIpMode('auto');
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: vm.ipMode == 'auto' ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('IP Manual / Fixo'),
                selected: vm.ipMode == 'manual',
                onSelected: (sel) {
                  if (sel) vm.setIpMode('manual');
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: vm.ipMode == 'manual' ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (vm.ipMode == 'manual') ...[
            TextField(
              controller: _customIpController,
              decoration: InputDecoration(
                labelText: 'IP Manual ou Hostname do Totem',
                hintText: 'ex: 192.168.1.150 ou totem.local',
                prefixIcon: const Icon(Icons.dns_rounded, color: AppColors.secondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => vm.setCustomIp(val),
            ),
            const SizedBox(height: 10),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderTanLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.router_rounded, color: AppColors.secondary, size: 18),
                      const SizedBox(width: 8),
                      Text('IP Detectado no Sistema: ${vm.detectedIp}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => vm.loadData(),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Redetectar', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Link gerado para os clientes
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.link_rounded, color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'URL de Acesso dos Clientes (QR Code Mobile):',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      SelectableText(
                        vm.clientWebUrl,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, color: AppColors.primary, size: 20),
                  tooltip: 'Copiar Link',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: vm.clientWebUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('URL copiada para a área de transferência!')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Wi-Fi da Loja (SSID e Senha)
          const Text('Wi-Fi da Loja (Exibido no QR Code de Conexão):',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _wifiSsidController,
                  decoration: InputDecoration(
                    labelText: 'Nome da Rede (SSID)',
                    prefixIcon: const Icon(Icons.wifi_rounded, color: AppColors.secondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) => vm.setWifiSsid(val),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: _wifiPasswordController,
                  obscureText: _obscureWifiPassword,
                  decoration: InputDecoration(
                    labelText: 'Senha do Wi-Fi',
                    prefixIcon: const Icon(Icons.key_rounded, color: AppColors.secondary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureWifiPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscureWifiPassword = !_obscureWifiPassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) => vm.setWifiPassword(val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Prévia do QR Code de Conexão Wi-Fi
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderTanLight),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                QrCodeCard(
                  data: vm.wifiQrData,
                  size: 95,
                  title: '',
                  subtitle: '',
                  centerIcon: Icons.wifi_rounded,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'QR Code de Conexão Automática do Wi-Fi',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Rede: ${vm.wifiSsid}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.secondary),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Clientes com Android e iPhone conectam automaticamente apontando a câmera para este QR Code.',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrinterCard(BuildContext context, AdminViewModel vm) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.print_rounded, color: AppColors.tertiary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Busca e Seleção da Impressora',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          Text(
                            'Varredura das impressoras conectadas no computador ou Spooler Virtual.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerHigh,
                  foregroundColor: AppColors.secondary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: vm.isSearchingPrinters ? null : () => vm.searchPrinters(),
                icon: vm.isSearchingPrinters
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary),
                      )
                    : const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Buscar Impressoras', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 12),

          // Lista de Impressoras Encontradas
          const Text('Impressora Ativa no Terminal:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 8),

          if (vm.printers.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Nenhuma impressora encontrada. Clique em Buscar Impressoras.', style: TextStyle(fontSize: 13)),
            )
          else
            Column(
              children: vm.printers.map((printer) {
                final isSelected = vm.selectedPrinter == printer.name;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Material(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.borderTanLight,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    leading: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.borderTanLight,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : null,
                    ),
                    title: Row(
                      children: [
                        Text(
                          printer.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (printer.isMock)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.tertiary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'TESTES / SIMULAÇÃO',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.tertiary),
                            ),
                          )
                        else if (printer.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'PADRÃO DO SISTEMA',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.primary),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text('Status: ${printer.status}', style: const TextStyle(fontSize: 11)),
                    onTap: () => vm.selectPrinter(printer),
                  ),
                ),
              );
            }).toList(),
            ),

          const SizedBox(height: 12),

          // Botão Imprimir Página de Teste
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  side: const BorderSide(color: AppColors.secondary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onPressed: vm.isTestingPrint ? null : () => vm.testPrint(),
                icon: vm.isTestingPrint
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary),
                      )
                    : const Icon(Icons.print_outlined, size: 16),
                label: const Text('Imprimir Página de Teste', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(BuildContext context, AdminViewModel vm) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.payments_outlined, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Valor por Página & Pagamento PIX',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Configure a cobrança por folha impressa e os dados de recebimento bancário.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 12),

          // Preço por Página com botões rápidos
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Preço cobrado por página:',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('R\$',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                          const SizedBox(width: 6),
                          Text(
                            vm.unitPrice.toStringAsFixed(2),
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                          const SizedBox(width: 6),
                          const Text('/ pág',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ajuste Rápido:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          onPressed: () => vm.adjustUnitPrice(-0.50),
                          child: const Text('- R\$ 0,50', style: TextStyle(fontSize: 12)),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          onPressed: () => vm.adjustUnitPrice(0.50),
                          child: const Text('+ R\$ 0,50', style: TextStyle(fontSize: 12)),
                        ),
                        ActionChip(
                          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                          label: const Text('R\$ 1,50', style: TextStyle(fontSize: 12)),
                          onPressed: () => vm.setUnitPrice(1.50),
                        ),
                        ActionChip(
                          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                          label: const Text('R\$ 2,00', style: TextStyle(fontSize: 12)),
                          onPressed: () => vm.setUnitPrice(2.00),
                        ),
                        ActionChip(
                          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                          label: const Text('R\$ 2,50', style: TextStyle(fontSize: 12)),
                          onPressed: () => vm.setUnitPrice(2.50),
                        ),
                        ActionChip(
                          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                          label: const Text('R\$ 3,00', style: TextStyle(fontSize: 12)),
                          onPressed: () => vm.setUnitPrice(3.00),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dados do PIX
          const Text('Dados do PIX (Recebedor):', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _pixKeyController,
                  decoration: InputDecoration(
                    labelText: 'Chave PIX (CNPJ, CPF ou Chave)',
                    prefixIcon: const Icon(Icons.qr_code_2_rounded, color: AppColors.secondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) => vm.setPixKey(val),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _merchantNameController,
                  decoration: InputDecoration(
                    labelText: 'Nome do Recebedor',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) => vm.setMerchantName(val),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _merchantCityController,
                  decoration: InputDecoration(
                    labelText: 'Cidade',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) => vm.setMerchantCity(val),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context, AdminViewModel vm) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.security_rounded, color: AppColors.secondary, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Segurança do Terminal',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Altere a senha de acesso a este painel administrativo.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.secondary,
              side: const BorderSide(color: AppColors.borderTanLight),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: () => _showChangePasswordDialog(context, vm),
            icon: const Icon(Icons.key_rounded, size: 16),
            label: const Text('Alterar Senha Admin', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildStartupCard(BuildContext context, AdminViewModel vm) {
    final isWindows = !kIsWeb && Platform.isWindows;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.power_settings_new_rounded, color: AppColors.secondary, size: 22),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inicialização do Sistema (Modo Totem)',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                  ),
                  Text(
                    'Configurar inicialização automática junto ao ligar o computador',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Iniciar automaticamente com o Windows',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
            ),
            subtitle: Text(
              isWindows
                  ? 'Inicia o totem de autoatendimento e o servidor local no boot do Windows.'
                  : 'Funcionalidade ativa no ambiente Windows (configuração automática do Registro do Sistema).',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            value: vm.isWindowsAutoStart,
            activeTrackColor: AppColors.primary,
            activeThumbColor: Colors.white,
            onChanged: isWindows ? (val) => vm.toggleWindowsAutoStart(val) : null,
          ),
        ],
      ),
    );
  }
}
