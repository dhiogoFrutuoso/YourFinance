import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../services/backup_service.dart';
import '../utils/formatters.dart';

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
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Segurança', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Exigir Biometria / PIN'),
            subtitle: const Text('Ao abrir o aplicativo'),
            value: settings.useBiometrics,
            activeColor: Theme.of(context).primaryColor,
            onChanged: (val) {
              ref.read(settingsProvider.notifier).toggleBiometrics(val);
            },
          ),
          const Divider(height: 32),
          const Text('Dados e Backup', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Exportar Backup'),
            subtitle: const Text('Salvar dados em JSON'),
            onTap: () async {
              try {
                final path = await BackupService.exportBackup();
                if (mounted) {
                  SnackBarUtils.showSuccess(context, 'Backup salvo em: \$path');
                }
              } catch (e) {
                if (mounted) {
                  SnackBarUtils.showError(context, 'Erro ao exportar backup');
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Importar Backup'),
            subtitle: const Text('Restaurar dados a partir de um JSON'),
            onTap: () {
              SnackBarUtils.showSuccess(context, 'Funcionalidade de importar requer selecionar arquivo JSON.');
            },
          ),
        ],
      ),
    );
  }
}

