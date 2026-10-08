import 'package:local_auth/local_auth.dart';
import '../providers/planning_provider.dart';
import '../providers/transactions_provider.dart';
import '../providers/targets_provider.dart';
import '../widgets/glassmorphism_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../services/backup_service.dart';
import '../utils/formatters.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configurações',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surface.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Security Section ───
          _SectionHeader(title: 'Segurança', icon: Icons.lock_rounded),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SwitchListTile(
              title: Text(
                'Exigir Biometria / PIN',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              subtitle: Text(
                'Ao abrir o aplicativo',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppTheme.textTertiary,
                ),
              ),
              value: settings.useBiometrics,
              activeThumbColor: AppTheme.primary,
              onChanged: (val) async {
                try {
                  final auth = LocalAuthentication();
                  if (!await auth.isDeviceSupported()) {
                    if (context.mounted) {
                      SnackBarUtils.showError(
                        context,
                        'Configure um bloqueio de tela no dispositivo.',
                      );
                    }
                    return;
                  }
                  final ok = await auth.authenticate(
                    localizedReason:
                        'Confirme a alteração da proteção do aplicativo',
                  );
                  if (ok) {
                    await ref
                        .read(settingsProvider.notifier)
                        .toggleBiometrics(val);
                  }
                } catch (_) {
                  if (context.mounted) {
                    SnackBarUtils.showError(
                      context,
                      'Não foi possível autenticar neste dispositivo.',
                    );
                  }
                }
              },
            ),
          ),

          const SizedBox(height: 28),

          // ─── Data Section ───
          _SectionHeader(title: 'Dados e Backup', icon: Icons.cloud_rounded),
          const SizedBox(height: 12),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.upload_file_rounded,
                  iconColor: AppTheme.success,
                  title: 'Exportar Backup',
                  subtitle: 'Salvar dados em JSON',
                  onTap: () async {
                    try {
                      final path = await BackupService.exportBackup();
                      if (context.mounted && path != null) {
                        SnackBarUtils.showSuccess(
                          context,
                          'Backup salvo em: $path',
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        SnackBarUtils.showError(
                          context,
                          'Erro ao exportar backup',
                        );
                      }
                    }
                  },
                ),
                Divider(
                  height: 1,
                  indent: 56,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
                _SettingsTile(
                  icon: Icons.download_rounded,
                  iconColor: AppTheme.primary,
                  title: 'Importar Backup',
                  subtitle: 'Restaurar dados a partir de um JSON',
                  onTap: () async {
                    try {
                      final data = await BackupService.pickBackup();
                      if (data == null || !context.mounted) return;
                      final confirmed = await GlassmorphismModal.show(
                        context: context,
                        title: 'Restaurar backup?',
                        content:
                            '${(data['transactions'] as List).length} lançamentos e ${(data['planItems'] as List).length} itens de planejamento substituirão os dados atuais. Uma cópia de recuperação será preservada neste dispositivo.',
                        confirmText: 'Restaurar',
                      );
                      if (!confirmed) return;
                      await BackupService.restore(data);
                      ref.invalidate(planningProvider);
                      ref.invalidate(transactionsProvider);
                      ref.invalidate(budgetsProvider);
                      ref.invalidate(goalsProvider);
                      ref.invalidate(settingsProvider);
                      if (context.mounted) {
                        SnackBarUtils.showSuccess(
                          context,
                          'Backup restaurado. Os dados já estão atualizados.',
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        SnackBarUtils.showError(
                          context,
                          'Erro ao importar backup. Verifique se o arquivo é válido.',
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ─── About Section ───
          _SectionHeader(title: 'Sobre', icon: Icons.info_outline_rounded),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset('assets/images/logo.webp', height: 56),
                ),
                const SizedBox(height: 12),
                Text(
                  'YourFinance',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'v1.4.1',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textTertiary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ─── Settings Tile ────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: iconColor.withValues(alpha: 0.12),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          color: AppTheme.textTertiary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppTheme.textTertiary,
        size: 20,
      ),
    );
  }
}
