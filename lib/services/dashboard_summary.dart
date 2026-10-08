import '../models/plan_item.dart';
import '../models/transaction.dart';
import 'finance_math.dart';

/// The card and its detail sheet always sum the same entries.
class DashboardEntry {
  final String title;
  final double value;
  final String note;
  final DateTime? date;
  final double? planned;
  final double? realized;
  final Transaction? transaction;
  final List<DashboardEntry>? children;

  const DashboardEntry({
    required this.title,
    required this.value,
    this.note = '',
    this.date,
    this.planned,
    this.realized,
    this.transaction,
    this.children,
  });

  static double total(Iterable<DashboardEntry> entries) =>
      entries.fold(0.0, (sum, entry) => sum + entry.value);
}

class DashboardSummary {
  final List<Transaction> transactions;
  final List<PlanItem> plans;
  final String month;

  DashboardSummary(this.transactions, List<PlanItem> plans, this.month)
    : plans = plans.where((p) => FinanceMath.activeInMonth(p, month)).toList();

  List<Transaction> get monthRows => FinanceMath.month(
    transactions,
    month,
  ).where((t) => !FinanceMath.isRollover(t)).toList();
  List<PlanItem> get mandatoryPlans => plans
      .where(
        (p) =>
            p.type == PlanItemType.despesaObrigatoria ||
            p.type == PlanItemType.despesaVariavelObrigatoria,
      )
      .toList();

  List<DashboardEntry> _plans(
    Iterable<PlanItem> items, {
    bool remaining = false,
  }) {
    final rows = monthRows;
    final entries = items
        .map((p) {
          final realized = FinanceMath.realized(p, rows);
          return DashboardEntry(
            title: p.name,
            value: remaining
                ? (((p.value - realized) * 100).round() / 100).clamp(
                    0.0,
                    double.infinity,
                  )
                : p.value,
            date: p.dueDate == null
                ? null
                : FinanceMath.inMonth(p.dueDate!, month),
            note: FinanceMath.isIncome(p)
                ? 'Recebimento previsto'
                : 'Despesa planejada',
            planned: p.value,
            realized: realized,
          );
        })
        .where((e) => !remaining || e.value > 0)
        .toList();
    entries.sort(
      (a, b) => (a.date ?? DateTime(9999)).compareTo(b.date ?? DateTime(9999)),
    );
    return entries;
  }

  List<DashboardEntry> _ledger(
    Iterable<Transaction> rows, {
    bool cashFlow = false,
  }) {
    final sorted = rows.toList()..sort((a, b) => b.date.compareTo(a.date));
    return sorted
        .map(
          (t) => DashboardEntry(
            title: t.title ?? t.categorySnapshotName ?? 'Lançamento',
            value: cashFlow
                ? FinanceMath.signed(t)
                : (t.isReversal ? -t.value : t.value),
            note: [
              t.isReversal
                  ? 'Estorno'
                  : (t.kind == TransactionKind.entrada ? 'Recebido' : 'Pago'),
              if (t.categorySnapshotName != null) t.categorySnapshotName!,
            ].join(' • '),
            date: t.date,
            transaction: t,
          ),
        )
        .toList();
  }

  bool _expense(Transaction t) => t.isReversal
      ? t.kind == TransactionKind.entrada
      : t.kind == TransactionKind.despesa;

  bool _belongsTo(Transaction t, Set<String> planIds) =>
      planIds.contains(t.planItemId) ||
      (t.isReversal &&
          transactions.any(
            (original) =>
                original.id == t.reversalOfId &&
                planIds.contains(original.planItemId),
          ));

  List<DashboardEntry> get toReceive =>
      _plans(plans.where(FinanceMath.isIncome), remaining: true);
  List<DashboardEntry> get mandatory => _plans(mandatoryPlans);
  List<DashboardEntry> get toPay => _plans(mandatoryPlans, remaining: true);
  List<DashboardEntry> get plannedAdditional =>
      _plans(plans.where((p) => p.type == PlanItemType.despesaPrevista));
  List<DashboardEntry> get paidMandatory {
    final ids = mandatoryPlans.map((p) => p.id).toSet();
    return _ledger(monthRows.where((t) => _expense(t) && _belongsTo(t, ids)));
  }

  List<DashboardEntry> get additional {
    final ids = mandatoryPlans.map((p) => p.id).toSet();
    return _ledger(monthRows.where((t) => _expense(t) && !_belongsTo(t, ids)));
  }

  List<DashboardEntry> get received =>
      _ledger(monthRows.where((t) => !_expense(t)));
  List<DashboardEntry> get expenses => _ledger(monthRows.where(_expense));
  List<DashboardEntry> get monthResult => _ledger(monthRows, cashFlow: true);
  List<DashboardEntry> get previous => _ledger(
    transactions.where(
      (t) =>
          !FinanceMath.isRollover(t) &&
          t.date.isBefore(DateTime.parse('$month-01')),
    ),
    cashFlow: true,
  );
  List<DashboardEntry> get balance {
    final start = DateTime.parse('$month-01');
    final next = DateTime(start.year, start.month + 1);
    return _ledger(
      transactions.where(
        (t) => !FinanceMath.isRollover(t) && t.date.isBefore(next),
      ),
      cashFlow: true,
    );
  }

  List<DashboardEntry> get projection => [
    DashboardEntry(
      title: 'Saldo acumulado até o mês',
      value: DashboardEntry.total(balance),
      children: balance,
    ),
    DashboardEntry(
      title: 'Total a Receber',
      value: DashboardEntry.total(toReceive),
      children: toReceive,
    ),
    DashboardEntry(
      title: 'Falta Pagar no Mês',
      value: -DashboardEntry.total(toPay),
      note: 'Deduzido do saldo projetado',
      children: toPay,
    ),
  ];
}
