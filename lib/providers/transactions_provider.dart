import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart' as model_transaction;
import '../services/hive_service.dart';

class TransactionsNotifier extends Notifier<List<model_transaction.Transaction>> {
  @override
  List<model_transaction.Transaction> build() {
    return HiveService.getTransactions();
  }

  void _loadItems() {
    state = HiveService.getTransactions();
  }

  Future<void> addTransaction(model_transaction.Transaction transaction) async {
    await HiveService.saveTransaction(transaction);
    _loadItems();
  }

  Future<void> reverseTransaction(model_transaction.Transaction original) async {
    final reversal = model_transaction.Transaction(
      id: const Uuid().v4(),
      kind: original.kind == model_transaction.TransactionKind.entrada 
            ? model_transaction.TransactionKind.despesa 
            : model_transaction.TransactionKind.entrada,
      value: original.value,
      date: DateTime.now(),
      paymentMethod: original.paymentMethod,
      isReversal: true,
      reversalOfId: original.id,
      title: 'Estorno: ${original.title ?? original.categorySnapshotName ?? ""}',
      createdAt: DateTime.now(),
    );
    await HiveService.saveTransaction(reversal);
    _loadItems();
  }
}

final transactionsProvider = NotifierProvider<TransactionsNotifier, List<model_transaction.Transaction>>(TransactionsNotifier.new);

