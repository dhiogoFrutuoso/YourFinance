import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Scrollable confirmation shared by all destructive and corrective actions.
class GlassmorphismModal {
  static Future<bool> show({
    required BuildContext context,
    required String title,
    String? content,
    String confirmText = 'Excluir',
    String cancelText = 'Cancelar',
    Color confirmColor = AppTheme.error,
    IconData? confirmIcon,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            scrollable: true,
            icon: Icon(
              confirmIcon ?? Icons.warning_amber_rounded,
              color: confirmColor,
              size: 32,
            ),
            title: Text(title),
            content: Text(
              content ?? 'Tem certeza? Esta ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(cancelText),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: confirmColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(confirmText),
              ),
            ],
          ),
        ) ??
        false;
  }
}
