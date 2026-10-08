import '../models/plan_item.dart';
import '../models/transaction.dart';

/// Shared accounting rules. Reversals keep their actual cash-flow direction.
class FinanceMath {
  static String monthOf(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';
  static bool isIncome(PlanItem plan) => const [
    PlanItemType.entradaFixa,
    PlanItemType.entradaPrevista,
    PlanItemType.entradaVariavel,
  ].contains(plan.type);
  static bool isRollover(Transaction t) =>
      t.id.startsWith('rollover_') || t.categorySnapshotName == 'Rollover';
  static double signed(Transaction t) =>
      t.kind == TransactionKind.entrada ? t.value : -t.value;
  static double balance(Iterable<Transaction> rows) =>
      rows.where((t) => !isRollover(t)).fold(0.0, (sum, t) => sum + signed(t));
  static List<Transaction> month(Iterable<Transaction> rows, String month) =>
      rows.where((t) => monthOf(t.date) == month).toList();
  static double realized(PlanItem plan, Iterable<Transaction> rows) {
    final list = rows.toList();
    final ids = list
        .where((t) => t.planItemId == plan.id && !t.isReversal)
        .map((t) => t.id)
        .toSet();
    return list
        .where(
          (t) =>
              t.planItemId == plan.id ||
              (t.isReversal && ids.contains(t.reversalOfId)),
        )
        .fold(0.0, (sum, t) => sum + signed(t) * (isIncome(plan) ? 1 : -1));
  }

  static bool activeInMonth(PlanItem p, String month) {
    final target = DateTime.parse('$month-01');
    final start = DateTime.parse('${p.monthRef}-01');
    if (target.isBefore(start)) return false;
    if (p.expirationDate != null && target.isAfter(p.expirationDate!)) {
      return false;
    }
    if (p.isInstallment != true) return p.monthRef == month;
    final distance =
        (target.year - start.year) * 12 + target.month - start.month;
    return distance < (p.totalInstallments ?? 1);
  }

  static DateTime inMonth(DateTime date, String month) {
    final target = DateTime.parse('$month-01');
    return DateTime(
      target.year,
      target.month,
      date.day.clamp(1, DateTime(target.year, target.month + 1, 0).day),
    );
  }

  static Map<String, double> expensesByCategory(
    Iterable<Transaction> rows,
    Iterable<Transaction> all,
  ) {
    final originals = {for (final t in all) t.id: t};
    final totals = <String, double>{};
    for (final t in rows) {
      if (isRollover(t)) continue;
      if ((!t.isReversal && t.kind == TransactionKind.despesa) ||
          (t.isReversal && t.kind == TransactionKind.entrada)) {
        final name =
            t.categorySnapshotName ??
            originals[t.reversalOfId]?.categorySnapshotName ??
            'Sem categoria';
        totals.update(
          name,
          (v) => v + (t.isReversal ? -t.value : t.value),
          ifAbsent: () => t.isReversal ? -t.value : t.value,
        );
      }
    }
    return totals;
  }

  static double? parseMoney(String? value) {
    var text = (value ?? '').trim().replaceAll('R\$', '').replaceAll(' ', '');
    if (text.contains(',')) {
      text = text.replaceAll('.', '').replaceAll(',', '.');
    }
    final parsed = double.tryParse(text);
    return parsed != null && parsed.isFinite && parsed >= 0.005
        ? (parsed * 100).round() / 100
        : null;
  }
}
