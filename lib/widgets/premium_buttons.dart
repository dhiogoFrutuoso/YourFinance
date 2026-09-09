import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PremiumPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        // Inherits default from AppTheme, but we can enforce some properties if needed
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colorInk),
              ),
            )
          else if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          if (!isLoading) Text(label),
        ],
      ),
    );
  }
}

class PremiumGhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isActive;
  final IconData? icon;

  const PremiumGhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isActive = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // If isActive is true, it highlights in primary color
    return TextButton(
      onPressed: onPressed,
      style: isActive
          ? TextButton.styleFrom(
              foregroundColor: AppTheme.colorPrimary,
              side: const BorderSide(color: AppTheme.colorPrimary, width: 1),
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(label),
        ],
      ),
    );
  }
}
