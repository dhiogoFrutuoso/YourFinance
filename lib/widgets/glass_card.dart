import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Refactored to "Premium Card" based on shadcn/ui.
/// A premium card with a solid #111113 background, 24px border radius, and a 1px hairline border.
/// (Class name kept as GlassCard for backward compatibility)
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    // The following properties are kept for backward compatibility but ignored
    // to enforce the Premium Design System strictly.
    double? borderRadius,
    bool? withBorder,
    Color? borderColor,
    List<BoxShadow>? boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      margin: margin ?? EdgeInsets.zero,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );

    if (onTap != null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.containerRadius),
          child: Ink(
            decoration: BoxDecoration(
              color: AppTheme.colorPaper,
              borderRadius: BorderRadius.circular(AppTheme.containerRadius),
              border: Border.all(color: AppTheme.colorHairline, width: 1),
            ),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(20),
              child: child,
            ),
          ),
        ),
      );
    }

    return card;
  }
}
