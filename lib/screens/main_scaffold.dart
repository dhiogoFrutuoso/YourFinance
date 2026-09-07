import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_calendar_outlined),
            activeIcon: Icon(Icons.edit_calendar),
            label: 'Plano',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.space_dashboard_outlined),
            activeIcon: Icon(Icons.space_dashboard),
            label: 'Dash',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Extrato',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.donut_large_outlined),
            activeIcon: Icon(Icons.donut_large),
            label: 'Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            activeIcon: Icon(Icons.insights),
            label: 'Análises',
          ),
        ],
      ),
    );
  }
}
