import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart' as model_transaction;
import '../providers/transactions_provider.dart';

class MonthManagerService {
  static Future<void> checkAndApplyRollover(WidgetRef ref) async {
    final transactionsProviderNotifier = ref.read(transactionsProvider.notifier);
    final allTransactions = ref.read(transactionsProvider);
    
    if (allTransactions.isEmpty) return;

    final now = DateTime.now();
    final currentMonthRef = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final rolloverId = 'rollover_$currentMonthRef';

    // Check if rollover already exists for current month
    final exists = allTransactions.any((t) => t.id == rolloverId);
    if (exists) return;

    // Determine previous month
    var prevMonth = now.month - 1;
    var prevYear = now.year;
    if (prevMonth == 0) {
      prevMonth = 12;
      prevYear = now.year - 1;
    }
    final prevMonthRef = '${prevYear}-${prevMonth.toString().padLeft(2, '0')}';

    // Calculate balance of previous month
    double prevIncomes = 0;
    double prevExpenses = 0;

    final prevMonthTransactions = allTransactions.where((t) {
      final tMonthRef = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
      return tMonthRef == prevMonthRef;
    }).toList();

    for (var t in prevMonthTransactions) {
      if (t.isReversal) {
        if (t.kind == model_transaction.TransactionKind.entrada) {
          prevIncomes += t.value;
        } else {
          prevExpenses += t.value;
        }
      } else {
        if (t.kind == model_transaction.TransactionKind.entrada) {
          prevIncomes += t.value;
        } else {
          prevExpenses += t.value;
        }
      }
    }

    final balance = prevIncomes - prevExpenses;

    if (balance != 0) {
      final rolloverTx = model_transaction.Transaction(
        id: rolloverId,
        kind: balance >= 0 
            ? model_transaction.TransactionKind.entrada 
            : model_transaction.TransactionKind.despesa,
        value: balance.abs(),
        date: DateTime(now.year, now.month, 1),
        paymentMethod: model_transaction.PaymentMethod.dinheiro,
        title: 'Saldo Anterior Acumulado',
        categorySnapshotName: 'Rollover',
        createdAt: DateTime.now(),
      );

      await transactionsProviderNotifier.addTransaction(rolloverTx);
    }
  }
}
