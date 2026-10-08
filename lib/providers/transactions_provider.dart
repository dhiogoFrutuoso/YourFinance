import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart' as model_transaction;
import '../services/hive_service.dart';

class TransactionsNotifier
    extends Notifier<List<model_transaction.Transaction>> {
  final _reversing = <String>{};
  @override
  List<model_transaction.Transaction> build() {
    return HiveService.getTransactions();
  }

  void _loadItems() {
    state = HiveService.getTransactions();
  }

  Future<void> addTransaction(model_transaction.Transaction transaction) async {
    if (!transaction.value.isFinite || transaction.value <= 0) {
      throw ArgumentError('Informe um valor positivo.');
    }
    if (state.any((t) => t.id == transaction.id)) {
      throw StateError('O histórico não pode ser sobrescrito.');
    }
    await HiveService.saveTransaction(transaction);
    _loadItems();
  }

  Future<void> reverseTransaction(
    model_transaction.Transaction original,
  ) async {
    if (_reversing.contains(original.id) ||
        original.isReversal ||
        state.any((t) => t.reversalOfId == original.id)) {
      throw StateError('Esta transação já foi estornada.');
    }
    final reversal = model_transaction.Transaction(
      id: 'reversal_${original.id}',
      kind: original.kind == model_transaction.TransactionKind.entrada
          ? model_transaction.TransactionKind.despesa
          : model_transaction.TransactionKind.entrada,
      value: original.value,
      date: original.date,
      paymentMethod: original.paymentMethod,
      planItemId: original.planItemId,
      categorySnapshotName: original.categorySnapshotName,
      isReversal: true,
      reversalOfId: original.id,
      title:
          'Estorno: ${original.title ?? original.categorySnapshotName ?? ""}',
      createdAt: DateTime.now(),
    );
    _reversing.add(original.id);
    try {
      await HiveService.saveTransaction(reversal);
      _loadItems();
    } finally {
      _reversing.remove(original.id);
    }
  }

  Future<void> correctTransaction(
    model_transaction.Transaction original,
    model_transaction.Transaction replacement,
  ) async {
    if (!replacement.value.isFinite || replacement.value <= 0) {
      throw ArgumentError('Valor inválido');
    }
    await reverseTransaction(original);
    try {
      await addTransaction(
        replacement.copyWith(id: const Uuid().v4(), createdAt: DateTime.now()),
      );
    } catch (_) {
      await HiveService.removeFailedReversal('reversal_${original.id}');
      _loadItems();
      rethrow;
    }
  }
}

final transactionsProvider =
    NotifierProvider<TransactionsNotifier, List<model_transaction.Transaction>>(
      TransactionsNotifier.new,
    );
