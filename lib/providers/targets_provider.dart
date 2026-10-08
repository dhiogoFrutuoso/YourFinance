import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class FinanceTarget {
  final String id, name;
  final double target, saved;
  final String? category;
  final DateTime? deadline;
  const FinanceTarget({
    required this.id,
    required this.name,
    required this.target,
    this.saved = 0,
    this.category,
    this.deadline,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'target': target,
    'saved': saved,
    'category': category,
    'deadline': deadline?.toIso8601String(),
  };
  factory FinanceTarget.fromJson(Map<String, dynamic> j) => FinanceTarget(
    id: j['id'],
    name: j['name'],
    target: (j['target'] as num).toDouble(),
    saved: (j['saved'] as num).toDouble(),
    category: j['category'],
    deadline: j['deadline'] == null ? null : DateTime.parse(j['deadline']),
  );
  double monthlyContribution(DateTime now) {
    if (saved >= target) return 0;
    final months = deadline == null
        ? 1
        : ((deadline!.year - now.year) * 12 + deadline!.month - now.month + 1)
              .clamp(1, 1200);
    return (target - saved) / months;
  }
}

class TargetsNotifier extends Notifier<List<FinanceTarget>> {
  final String storageKey;
  TargetsNotifier(this.storageKey);
  @override
  List<FinanceTarget> build() =>
      (jsonDecode(
                Hive.box<String>(
                  'preferences',
                ).get(storageKey, defaultValue: '[]')!,
              )
              as List)
          .map((e) => FinanceTarget.fromJson(Map<String, dynamic>.from(e)))
          .toList();
  Future<void> save(FinanceTarget target) async {
    if (target.name.trim().isEmpty ||
        !target.target.isFinite ||
        target.target <= 0 ||
        !target.saved.isFinite ||
        target.saved < 0) {
      throw ArgumentError('Dados inválidos');
    }
    final next = [...state.where((e) => e.id != target.id), target];
    await Hive.box<String>(
      'preferences',
    ).put(storageKey, jsonEncode(next.map((e) => e.toJson()).toList()));
    state = next;
  }
}

final budgetsProvider = NotifierProvider<TargetsNotifier, List<FinanceTarget>>(
  () => TargetsNotifier('budgets'),
);
final goalsProvider = NotifierProvider<TargetsNotifier, List<FinanceTarget>>(
  () => TargetsNotifier('goals'),
);
