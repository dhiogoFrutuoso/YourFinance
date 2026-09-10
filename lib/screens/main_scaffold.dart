import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../providers/planning_provider.dart';
import '../services/month_manager_service.dart';
import '../widgets/glass_card.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MonthManagerService.checkAndApplyRollover(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthRef = ref.watch(selectedMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: _GlobalMonthDropdown(
          currentMonthRef: monthRef,
          onChanged: (newMonth) {
            ref.read(selectedMonthProvider.notifier).update(newMonth);
          },
        ),
        backgroundColor: AppTheme.colorCanvas,
        elevation: 0,
        centerTitle: true,
      ),
      body: widget.navigationShell,
      extendBody: true,
      bottomNavigationBar: _FloatingBottomNav(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

class _FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: Icons.edit_calendar_outlined, activeIcon: Icons.edit_calendar, label: 'Plano'),
    _NavItem(icon: Icons.space_dashboard_outlined, activeIcon: Icons.space_dashboard, label: 'Dash'),
    _NavItem(icon: Icons.list_alt_outlined, activeIcon: Icons.list_alt, label: 'Extrato'),
    _NavItem(icon: Icons.donut_large_outlined, activeIcon: Icons.donut_large, label: 'Status'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.surface.withOpacity(0.75),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final isSelected = index == currentIndex;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon with glow
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primary.withOpacity(0.4),
                                        blurRadius: 14,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.textTertiary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Label
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.textTertiary,
                            ),
                            child: Text(item.label),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ─── Global Month Dropdown ───────────────────────────────────────────────

class _GlobalMonthDropdown extends StatelessWidget {
  final String currentMonthRef;
  final ValueChanged<String> onChanged;

  const _GlobalMonthDropdown({
    required this.currentMonthRef,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final parts = currentMonthRef.split('-');
        DateTime initialDate = DateTime(int.parse(parts[0]), int.parse(parts[1]));
        
        final picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          initialDatePickerMode: DatePickerMode.year,
        );
        if (picked != null) {
          final newMonthRef = '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
          onChanged(newMonthRef);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.colorPrimary),
          const SizedBox(width: 8),
          Text(
            Formatters.formatMonthRef(currentMonthRef),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.colorInk,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.colorInkSoft, size: 18),
        ],
      ),
    );
  }
}
