import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/plan_item.dart';
import '../models/transaction.dart' as model_transaction;
import 'hive_service.dart';

class BackupService {
  static Future<String> exportBackup() async {
    final planItems = HiveService.getPlanItems();
    final transactions = HiveService.getTransactions();

    final backupData = {
      'planItems': planItems.map((e) => e.toJson()).toList(),
      'transactions': transactions.map((e) => e.toJson()).toList(),
    };

    final jsonStr = jsonEncode(backupData);
    
    // Save to public Downloads directory
    final dir = Directory('/storage/emulated/0/Download');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    final file = File('${dir.path}/yourfinance_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonStr);
    
    return file.path;
  }

  static Future<void> importBackup() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result.isNotEmpty && result.first.path != null) {
      final file = File(result.first.path!);
      if (!await file.exists()) return;

      final jsonStr = await file.readAsString();
      final backupData = jsonDecode(jsonStr) as Map<String, dynamic>;

      await HiveService.clearAll();

      if (backupData.containsKey('planItems')) {
        final planItemsList = backupData['planItems'] as List;
        for (var itemMap in planItemsList) {
          final item = PlanItem.fromJson(itemMap as Map<String, dynamic>);
          await HiveService.savePlanItem(item);
        }
      }

      if (backupData.containsKey('transactions')) {
        final transactionsList = backupData['transactions'] as List;
        for (var itemMap in transactionsList) {
          final item = model_transaction.Transaction.fromJson(itemMap as Map<String, dynamic>);
          await HiveService.saveTransaction(item);
        }
      }
    }
  }
}
