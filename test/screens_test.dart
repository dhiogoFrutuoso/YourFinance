import 'package:your_finance/main.dart';
import 'package:your_finance/routes.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:your_finance/models/plan_item.dart';
import 'package:your_finance/models/transaction.dart' as model;
import 'package:your_finance/providers/planning_provider.dart';
import 'package:your_finance/providers/targets_provider.dart';
import 'package:your_finance/providers/settings_provider.dart';
import 'package:your_finance/screens/dashboard_screen.dart';
import 'package:your_finance/screens/planning_screen.dart';
import 'package:your_finance/screens/transactions_screen.dart';
import 'package:your_finance/screens/status_screen.dart';
import 'package:your_finance/screens/reports_screen.dart';
import 'package:your_finance/screens/settings_screen.dart';
import 'package:your_finance/services/hive_service.dart';
import 'package:your_finance/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final loader = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/Inter.ttf'));
    await loader.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  late Directory temp;
  late ProviderContainer container;
  final boundary = GlobalKey();
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('yourfinance-ui-');
    Hive.init(temp.path);
    for (final name in ['planItemsBox', 'transactionsBox', 'preferences']) {
      await Hive.openBox<String>(name);
    }
    container = ProviderContainer();
    container.read(selectedMonthProvider.notifier).update('2026-10');
    final date = DateTime(2026, 10, 5);
    await HiveService.savePlanItem(
      PlanItem(
        id: 'rent',
        type: PlanItemType.despesaObrigatoria,
        name: 'Moradia',
        value: 1250,
        monthRef: '2026-10',
        createdAt: date,
      ),
    );
    await HiveService.savePlanItem(
      PlanItem(
        id: 'salary',
        type: PlanItemType.entradaFixa,
        name: 'Salário',
        value: 5200,
        monthRef: '2026-10',
        createdAt: date,
      ),
    );
    for (var i = 0; i < 6; i++) {
      await HiveService.saveTransaction(
        model.Transaction(
          id: 'income$i',
          kind: model.TransactionKind.entrada,
          value: 5200,
          date: DateTime(2026, 5 + i, 5),
          paymentMethod: model.PaymentMethod.pix,
          title: 'Salário',
          planItemId: i == 5 ? 'salary' : null,
          createdAt: date,
        ),
      );
      await HiveService.saveTransaction(
        model.Transaction(
          id: 'expense$i',
          kind: model.TransactionKind.despesa,
          value: 1250,
          date: DateTime(2026, 5 + i, 8),
          paymentMethod: model.PaymentMethod.pix,
          title: 'Aluguel',
          categorySnapshotName: 'Moradia',
          planItemId: i == 5 ? 'rent' : null,
          createdAt: date,
        ),
      );
    }
    await HiveService.saveTransaction(
      model.Transaction(
        id: 'market',
        kind: model.TransactionKind.despesa,
        value: 460,
        date: date,
        paymentMethod: model.PaymentMethod.cartaoCredito,
        title: 'Mercado',
        categorySnapshotName: 'Alimentação',
        createdAt: date,
      ),
    );
  });
  tearDown(() async {
    container.dispose();
    await Hive.close();
    await temp.delete(recursive: true);
  });
  Future<void> pump(
    WidgetTester tester,
    Widget page, {
    Size size = const Size(375, 812),
    double scale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scale),
              disableAnimations: true,
            ),
            child: child!,
          ),
          home: RepaintBoundary(key: boundary, child: page),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> screenshot(WidgetTester tester, String name) async {
    await tester.runAsync(() async {
      final image =
          await (boundary.currentContext!.findRenderObject()
                  as RenderRepaintBoundary)
              .toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('build/screenshots');
      await dir.create(recursive: true);
      await File(
        '${dir.path}/$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  for (final entry in <String, Widget>{
    'dashboard': const DashboardScreen(),
    'planning': const PlanningScreen(),
    'transactions': const TransactionsScreen(),
    'status': const StatusScreen(),
    'reports': const ReportsScreen(),
    'settings': const SettingsScreen(),
  }.entries) {
    testWidgets(
      '${entry.key} renders at phone width with persisted legacy data',
      (tester) async {
        await pump(tester, entry.value);
        expect(tester.takeException(), isNull);
        await screenshot(tester, entry.key);
      },
    );
  }
  testWidgets('reports create a budget with validation and persist it', (
    tester,
  ) async {
    await pump(tester, const ReportsScreen());
    await tester.tap(find.text('Orçamentos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Criar orçamento'));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text('Salvar'));
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await tester.pumpAndSettle();
    expect(find.text('Informe um nome'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Limite mensal');
    await tester.enterText(find.byType(TextFormField).at(1), '2.000,00');
    await tester.runAsync(() async {
      await tester.tap(find.text('Salvar'));
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await tester.pumpAndSettle();
    expect(container.read(budgetsProvider).single.target, 2000);
    expect(find.text('Limite mensal'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await screenshot(tester, 'budgets');
  });
  testWidgets('goal form creates an actual saved target', (tester) async {
    await pump(tester, const ReportsScreen());
    await tester.tap(find.text('Metas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Criar meta'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Reserva de emergência',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '10000');
    await tester.enterText(find.byType(TextFormField).at(2), '1500');
    await tester.ensureVisible(find.text('Salvar'));
    await tester.runAsync(() async {
      await tester.tap(find.text('Salvar'));
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await tester.pumpAndSettle();
    expect(container.read(goalsProvider).single.saved, 1500);
    expect(tester.takeException(), isNull);
    await screenshot(tester, 'goals');
  });
  testWidgets('category details modal and hide amounts work', (tester) async {
    await pump(tester, const ReportsScreen());
    await tester.drag(find.byType(ListView).first, const Offset(0, -580));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Moradia').first);
    await tester.pumpAndSettle();
    expect(find.text('Aluguel'), findsWidgets);
    expect(tester.takeException(), isNull);
    Navigator.of(tester.element(find.text('Aluguel').last)).pop();
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => container.read(settingsProvider.notifier).toggleAmounts(),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('R\$'), findsNothing);
  });
  testWidgets('dashboard supports landscape and enlarged text', (tester) async {
    await pump(
      tester,
      const DashboardScreen(),
      size: const Size(844, 390),
      scale: 1.6,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'full app navigation and quick transaction preserve month and category',
    (tester) async {
      goRouter.go('/dashboard');
      await pump(tester, const YourFinanceApp());
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Adicionar lançamento'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nova despesa'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), '35,90');
      await tester.enterText(find.byType(TextFormField).at(1), 'Almoço');
      await tester.enterText(find.byType(TextFormField).at(2), 'Alimentação');
      await tester.ensureVisible(find.text('Salvar Transação'));
      await tester.runAsync(() async {
        await tester.tap(find.text('Salvar Transação'));
        await Future<void>.delayed(const Duration(milliseconds: 150));
      });
      await tester.pumpAndSettle();
      final saved = HiveService.getTransactions().firstWhere(
        (t) => t.title == 'Almoço',
      );
      expect(saved.value, 35.90);
      expect(saved.categorySnapshotName, 'Alimentação');
      expect(saved.date.month, 10);
      expect(tester.takeException(), isNull);
      for (
        var attempt = 0;
        attempt < 20 && find.text('Salvar Transação').evaluate().isNotEmpty;
        attempt++
      ) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pumpAndSettle();
      }
      expect(find.text('Salvar Transação'), findsNothing);
      await screenshot(tester, 'app-dashboard');
    },
  );
  testWidgets(
    'expense and Pix filters intersect and global month is respected',
    (tester) async {
      await pump(tester, const TransactionsScreen());
      await tester.tap(find.text('Despesa').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pix').first);
      await tester.pumpAndSettle();
      expect(find.text('Aluguel'), findsOneWidget);
      expect(find.text('Salário'), findsNothing);
      expect(find.text('Mercado'), findsNothing);
      container.read(selectedMonthProvider.notifier).update('2027-01');
      await tester.pumpAndSettle();
      expect(find.text('Aluguel'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
