import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surface.withOpacity(0.6),
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
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              subtitle: Text(
                'Ao abrir o aplicativo',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textTertiary,
                ),
              ),
              value: settings.useBiometrics,
              activeColor: AppTheme.primary,
              onChanged: (val) {
                ref.read(settingsProvider.notifier).toggleBiometrics(val);
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
                      if (mounted) {
                        SnackBarUtils.showSuccess(context, 'Backup salvo em: $path');
                      }
                    } catch (e) {
                      if (mounted) {
                        SnackBarUtils.showError(context, 'Erro ao exportar backup');
                      }
                    }
                  },
                ),
                Divider(height: 1, indent: 56, color: Colors.white.withOpacity(0.06)),
                _SettingsTile(
                  icon: Icons.download_rounded,
                  iconColor: AppTheme.primary,
                  title: 'Importar Backup',
                  subtitle: 'Restaurar dados a partir de um JSON',
                  onTap: () async {
                    try {
                      await BackupService.importBackup();
                      if (mounted) {
                        SnackBarUtils.showSuccess(context, 'Backup restaurado com sucesso! Reinicie o app para ver os dados.');
                      }
                    } catch (e) {
                      if (mounted) {
                        SnackBarUtils.showError(context, 'Erro ao importar backup. Verifique se o arquivo é válido.');
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
                  child: Image.asset('assets/images/logo.png', height: 56),
                ),
                const SizedBox(height: 12),
                Text(
                  'YourFinance',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'v1.0.0',
                  style: GoogleFonts.inter(
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
          style: GoogleFonts.inter(
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
          color: iconColor.withOpacity(0.12),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppTheme.textTertiary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary, size: 20),
    );
  }
}
