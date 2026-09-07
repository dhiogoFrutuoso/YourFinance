import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ConfirmDialog {
  static Future<bool> show({
    required BuildContext context,
    required String title,
    String? content,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          content: Text(
            content ?? 'Tem certeza que deseja excluir? Esta ação não pode ser desfeita.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
              ),
              child: const Text('Excluir', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
