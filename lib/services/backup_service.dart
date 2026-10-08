import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import '../models/plan_item.dart';
import '../models/transaction.dart';
import 'hive_service.dart';

class BackupService {
  static Map<String, dynamic> snapshot() => {
    'schemaVersion': 2,
    'planItems': HiveService.getPlanItems().map((e) => e.toJson()).toList(),
    'transactions': HiveService.getTransactions()
        .map((e) => e.toJson())
        .toList(),
    'preferences':
        Map<String, String>.from(Hive.box<String>('preferences').toMap())
          ..remove('useBiometrics')
          ..remove('recoveryBackup'),
  };
  static Future<String?> exportBackup() async {
    final uri = await FilePicker.saveFile(
      fileName:
          'yourfinance_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      bytes: Uint8List.fromList(utf8.encode(jsonEncode(snapshot()))),
      mimeType: 'application/json',
    );
    return uri?.toString();
  }

  static Map<String, dynamic> validate(String text) {
    final data = jsonDecode(text) as Map<String, dynamic>;
    if (data['planItems'] is! List || data['transactions'] is! List) {
      throw const FormatException('Backup incompleto');
    }
    if (data['schemaVersion'] != null && data['schemaVersion'] != 2) {
      throw const FormatException('Versão incompatível');
    }
    final plans = (data['planItems'] as List)
        .map((e) => PlanItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final rows = (data['transactions'] as List)
        .map((e) => Transaction.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    if (plans.any(
          (p) =>
              p.id.isEmpty ||
              p.name.trim().isEmpty ||
              !p.value.isFinite ||
              p.value <= 0 ||
              !RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(p.monthRef) ||
              (p.isInstallment == true && (p.totalInstallments ?? 0) < 1),
        ) ||
        rows.any((t) => t.id.isEmpty || !t.value.isFinite || t.value <= 0)) {
      throw const FormatException('Valores inválidos');
    }
    if (plans.map((p) => p.id).toSet().length != plans.length ||
        rows.map((t) => t.id).toSet().length != rows.length) {
      throw const FormatException('IDs duplicados');
    }
    if (data['preferences'] != null) {
      final prefs = Map<String, String>.from(data['preferences']);
      for (final key in ['budgets', 'goals']) {
        if (prefs[key] != null) {
          final items = jsonDecode(prefs[key]!) as List;
          for (final item in items) {
            if (item['id'] is! String ||
                item['name'] is! String ||
                item['target'] is! num ||
                !(item['target'] as num).isFinite ||
                item['target'] <= 0) {
              throw const FormatException('Meta ou orçamento inválido');
            }
            if (item['saved'] is! num ||
                !(item['saved'] as num).isFinite ||
                item['saved'] < 0) {
              throw const FormatException('Saldo de meta inválido');
            }
            if (item['deadline'] != null) DateTime.parse(item['deadline']);
          }
        }
      }
    }
    return data;
  }

  static Future<void> _write(Map<String, dynamic> data) async {
    await HiveService.clearAll();
    for (final p in data['planItems']) {
      await HiveService.savePlanItem(
        PlanItem.fromJson(Map<String, dynamic>.from(p)),
      );
    }
    for (final t in data['transactions']) {
      await HiveService.saveTransaction(
        Transaction.fromJson(Map<String, dynamic>.from(t)),
      );
    }
    final prefs = Hive.box<String>('preferences');
    await prefs.deleteAll(['budgets', 'goals', 'hideAmounts']);
    if (data['preferences'] != null) {
      final preferences = Map<String, String>.from(data['preferences']);
      await prefs.putAll({
        for (final key in ['budgets', 'goals', 'hideAmounts'])
          if (preferences.containsKey(key)) key: preferences[key]!,
      });
    }
  }

  static Future<void> restore(Map<String, dynamic> data) async {
    validate(jsonEncode(data));
    final previous = snapshot();
    await Hive.box<String>(
      'preferences',
    ).put('recoveryBackup', jsonEncode(previous));
    try {
      await _write(data);
    } catch (_) {
      await _write(previous);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> pickBackup() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (files.isEmpty) return null;
    final bytes = await files.first.readAsBytes();
    return validate(utf8.decode(bytes));
  }
}
