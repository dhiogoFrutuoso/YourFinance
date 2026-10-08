import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:your_finance/models/plan_item.dart';
import 'package:your_finance/models/transaction.dart';
import 'package:your_finance/providers/planning_provider.dart';
import 'package:your_finance/providers/transactions_provider.dart';
import 'package:your_finance/providers/targets_provider.dart';
import 'package:your_finance/services/finance_math.dart';
import 'package:your_finance/services/backup_service.dart';
import 'package:your_finance/services/hive_service.dart';
import 'package:your_finance/services/predictive_service.dart';

final date = DateTime(2026, 10, 8);
Transaction tx(
  String id,
  double value, {
  TransactionKind kind = TransactionKind.despesa,
  bool reversal = false,
  String? original,
  String? plan,
  DateTime? at,
}) => Transaction(
  id: id,
  kind: kind,
  value: value,
  date: at ?? date,
  paymentMethod: PaymentMethod.pix,
  createdAt: date,
  isReversal: reversal,
  reversalOfId: original,
  planItemId: plan,
  categorySnapshotName: 'Casa',
);
PlanItem plan({
  bool? installment,
  String month = '2026-10',
  int? count,
  DateTime? due,
}) => PlanItem(
  id: 'p',
  type: PlanItemType.despesaObrigatoria,
  name: 'Aluguel',
  value: 100,
  monthRef: month,
  createdAt: date,
  isInstallment: installment,
  totalInstallments: count,
  dueDate: due,
);
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temp;
  late ProviderContainer container;
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('yourfinance-test-');
    Hive.init(temp.path);
    for (final name in ['planItemsBox', 'transactionsBox', 'preferences']) {
      await Hive.openBox<String>(name);
    }
    container = ProviderContainer();
  });
  tearDown(() async {
    container.dispose();
    await Hive.close();
    await temp.delete(recursive: true);
  });
  test('parses Brazilian money and rejects invalid values', () {
    expect(FinanceMath.parseMoney('R\$ 1.234,56'), 1234.56);
    for (final value in ['NaN', 'Infinity', '-1', '0', '0.001', '', 'abc']) {
      expect(FinanceMath.parseMoney(value), isNull);
    }
  });
  test('legacy nullable installment and recurring months work', () {
    expect(FinanceMath.activeInMonth(plan(), '2026-10'), isTrue);
    expect(FinanceMath.activeInMonth(plan(), '2026-11'), isFalse);
    final p = plan(installment: true, count: 3);
    expect(FinanceMath.activeInMonth(p, '2026-09'), isFalse);
    expect(FinanceMath.activeInMonth(p, '2026-12'), isTrue);
    expect(FinanceMath.activeInMonth(p, '2027-01'), isFalse);
  });
  test(
    'installment provider includes earlier origin and clamps due date',
    () async {
      await HiveService.savePlanItem(
        plan(
          installment: true,
          month: '2026-01',
          count: 3,
          due: DateTime(2026, 1, 31),
        ),
      );
      final p = HiveService.getPlanItemsByMonth('2026-02').single;
      expect(p.dueDate, DateTime(2026, 2, 28));
      expect(p.monthRef, '2026-01');
    },
  );
  test('partial payment and reversal keep obligation pending', () {
    final rows = [
      tx('a', 70, plan: 'p'),
      tx('b', 20, plan: 'p'),
      tx('c', 70, reversal: true, original: 'a', kind: TransactionKind.entrada),
    ];
    expect(FinanceMath.realized(plan(), rows), 20);
    expect(FinanceMath.balance(rows), -20);
    expect(FinanceMath.expensesByCategory(rows, rows)['Casa'], 20);
    expect(
      PredictiveService.calculateProjectedBalance(
        targetDate: date,
        currentDate: date,
        currentBalance: 200,
        currentMonthTransactions: rows,
        plannedItems: [plan()],
        daysInMonth: 31,
      ),
      120,
    );
  });
  test('rollovers do not double count assets or expenses', () {
    final rows = [
      tx('salary', 1000, kind: TransactionKind.entrada),
      tx('expense', 100),
      tx('rollover_2026-10', 900, kind: TransactionKind.entrada),
    ];
    expect(FinanceMath.balance(rows), 900);
  });
  test('reversal preserves original and rejects duplicates', () async {
    final notifier = container.read(transactionsProvider.notifier);
    final original = tx('a', 100, plan: 'p');
    await notifier.addTransaction(original);
    await notifier.reverseTransaction(original);
    expect(HiveService.getTransactions().length, 2);
    expect(FinanceMath.balance(HiveService.getTransactions()), 0);
    expect(FinanceMath.realized(plan(), HiveService.getTransactions()), 0);
    await expectLater(notifier.reverseTransaction(original), throwsStateError);
  });
  test('correction retains original, reversal and replacement', () async {
    final notifier = container.read(transactionsProvider.notifier);
    final original = tx('a', 100);
    await notifier.addTransaction(original);
    await notifier.correctTransaction(original, tx('a', 60));
    expect(HiveService.getTransactions().length, 3);
    expect(
      HiveService.getTransactions().firstWhere((t) => t.id == 'a').value,
      100,
    );
    expect(FinanceMath.balance(HiveService.getTransactions()), -60);
  });
  test('copying previous month is idempotent and advances dates', () async {
    await HiveService.savePlanItem(
      plan(month: '2026-09', due: DateTime(2026, 9, 30)),
    );
    container.read(selectedMonthProvider.notifier).update('2026-10');
    final notifier = container.read(planningProvider.notifier);
    await notifier.duplicatePreviousMonthItems();
    await notifier.duplicatePreviousMonthItems();
    expect(HiveService.getPlanItemsByMonth('2026-10').length, 1);
    expect(
      HiveService.getPlanItemsByMonth('2026-10').single.dueDate,
      DateTime(2026, 10, 30),
    );
  });
  test(
    'malformed backup is rejected before changing existing records',
    () async {
      await HiveService.saveTransaction(tx('keep', 50));
      await expectLater(
        BackupService.restore({
          'transactions': [],
          'planItems': [
            {'invalid': true},
          ],
        }),
        throwsA(anything),
      );
      expect(HiveService.getTransactions().single.id, 'keep');
      expect(
        () => BackupService.validate(
          jsonEncode({
            'transactions': [tx('x', -1).toJson()],
            'planItems': [],
          }),
        ),
        throwsFormatException,
      );
    },
  );
  test('old backup remains compatible and recovery copy is stored', () async {
    await HiveService.saveTransaction(tx('previous', 50));
    await BackupService.restore({
      'transactions': [tx('restored', 30).toJson()],
      'planItems': [],
    });
    expect(HiveService.getTransactions().single.id, 'restored');
    expect(
      Hive.box<String>('preferences').get('recoveryBackup'),
      contains('previous'),
    );
  });
  test('budgets and goals persist and round trip in backup', () async {
    final target = FinanceTarget(
      id: 'g',
      name: 'Reserva',
      target: 1200,
      saved: 200,
      deadline: DateTime(2026, 12, 31),
    );
    await container.read(goalsProvider.notifier).save(target);
    expect(target.monthlyContribution(DateTime(2026, 11, 1)), 500);
    final data = BackupService.validate(jsonEncode(BackupService.snapshot()));
    expect((data['preferences'] as Map)['goals'], contains('Reserva'));
    container.invalidate(goalsProvider);
    expect(container.read(goalsProvider).single.saved, 200);
  });
}
