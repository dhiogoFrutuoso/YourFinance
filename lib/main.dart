import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes.dart';
import 'theme/app_theme.dart';
import 'services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await HiveService.init();

  runApp(
    const ProviderScope(
      child: YourFinanceApp(),
    ),
  );
}

class YourFinanceApp extends StatelessWidget {
  const YourFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'YourFinance',
      theme: AppTheme.darkTheme,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
