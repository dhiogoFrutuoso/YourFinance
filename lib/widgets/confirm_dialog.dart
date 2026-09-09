import 'package:flutter/material.dart';
import 'glassmorphism_modal.dart';

/// Confirm dialog that delegates to GlassmorphismModal.
/// Maintains backward compatibility with existing call sites.
class ConfirmDialog {
  static Future<bool> show({
    required BuildContext context,
    required String title,
    String? content,
  }) async {
    return GlassmorphismModal.show(
      context: context,
      title: title,
      content: content,
      confirmText: 'Excluir',
      cancelText: 'Cancelar',
      confirmIcon: Icons.delete_outline_rounded,
    );
  }
}
