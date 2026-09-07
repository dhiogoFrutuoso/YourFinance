import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/plan_item.dart';
import '../models/transaction.dart' as model_transaction;

class HiveService {
  static const String _planItemsBoxName = 'planItemsBox';
  static const String _transactionsBoxName = 'transactionsBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_planItemsBoxName);
    await Hive.openBox<String>(_transactionsBoxName);
  }

  // --- Plan Items ---
  static Box<String> get _planItemsBox => Hive.box<String>(_planItemsBoxName);

  static Future<void> savePlanItem(PlanItem item) async {
    final jsonStr = jsonEncode(item.toJson());
    await _planItemsBox.put(item.id, jsonStr);
  }

  static Future<void> deletePlanItem(String id) async {
    await _planItemsBox.delete(id);
  }

  static List<PlanItem> getPlanItems() {
    return _planItemsBox.values.map((jsonStr) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return PlanItem.fromJson(map);
    }).toList();
  }

  static List<PlanItem> getPlanItemsByMonth(String monthRef) {
    return getPlanItems().where((item) => item.monthRef == monthRef).toList();
  }

  // --- Transactions ---
  static Box<String> get _transactionsBox => Hive.box<String>(_transactionsBoxName);

  static Future<void> saveTransaction(model_transaction.Transaction transaction) async {
    final jsonStr = jsonEncode(transaction.toJson());
    await _transactionsBox.put(transaction.id, jsonStr);
  }

  static List<model_transaction.Transaction> getTransactions() {
    final transactions = _transactionsBox.values.map((jsonStr) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return model_transaction.Transaction.fromJson(map);
    }).toList();
    transactions.sort((a, b) => b.date.compareTo(a.date)); // Descending order
    return transactions;
  }

  static Future<void> clearAll() async {
    await _planItemsBox.clear();
    await _transactionsBox.clear();
  }
}
