import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A custom animated toggle switch with neon purple styling.
/// When enabled, can expand a child panel using AnimatedContainer.
class AnimatedToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final Widget? expandedChild;

  const AnimatedToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.expandedChild,
  });

  @override
  State<AnimatedToggle> createState() => _AnimatedToggleState();
}

class _AnimatedToggleState extends State<AnimatedToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            ScaleTransition(
              scale: _scaleAnimation,
              child: GestureDetector(
                onTapDown: (_) => _controller.forward(),
                onTapUp: (_) {
                  _controller.reverse();
                  widget.onChanged(!widget.value);
                },
                onTapCancel: () => _controller.reverse(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  width: 52,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: widget.value
                        ? AppTheme.primary.withOpacity(0.3)
                        : AppTheme.surface,
                    border: Border.all(
                      color: widget.value
                          ? AppTheme.primary
                          : Colors.white.withOpacity(0.15),
                      width: 1.5,
                    ),
                    boxShadow: widget.value
                        ? AppTheme.glowShadow(blurRadius: 8, opacity: 0.2)
                        : [],
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    alignment: widget.value
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.value
                            ? AppTheme.primary
                            : AppTheme.textTertiary,
                        boxShadow: widget.value
                            ? [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.5),
                                  blurRadius: 6,
                                ),
                              ]
                            : [],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Expandable panel
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: widget.expandedChild ?? const SizedBox.shrink(),
          ),
          crossFadeState: widget.value && widget.expandedChild != null
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
          sizeCurve: Curves.easeOutCubic,
        ),
      ],
    );
  }
}
