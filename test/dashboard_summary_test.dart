import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance/models/plan_item.dart';
import 'package:your_finance/models/transaction.dart';
import 'package:your_finance/services/dashboard_summary.dart';

void main() {
  test('fully paid decimal amounts leave no phantom pending item', () {
    final date = DateTime(2026, 10, 5);
    final summary = DashboardSummary(
      [
        for (final value in [0.10, 0.70])
          Transaction(
            id: '$value',
            kind: TransactionKind.despesa,
            value: value,
            date: date,
            createdAt: date,
            paymentMethod: PaymentMethod.pix,
            planItemId: 'paid',
          ),
      ],
      [
        PlanItem(
          id: 'paid',
          type: PlanItemType.despesaObrigatoria,
          name: 'Quitado',
          value: 0.80,
          monthRef: '2026-10',
          createdAt: date,
        ),
      ],
      '2026-10',
    );
    expect(summary.toPay, isEmpty);
  });
  test(
    'card totals reconcile with details, partial payments, reversals and month boundaries',
    () {
      final date = DateTime(2026, 10, 5);
      PlanItem plan(String id, PlanItemType type, double value) => PlanItem(
        id: id,
        type: type,
        name: id,
        value: value,
        monthRef: '2026-10',
        createdAt: date,
      );
      Transaction row(
        String id,
        TransactionKind kind,
        double value, {
        String? planId,
        String? reversal,
        DateTime? at,
      }) => Transaction(
        id: id,
        kind: kind,
        value: value,
        date: at ?? date,
        createdAt: date,
        paymentMethod: PaymentMethod.pix,
        planItemId: planId,
        isReversal: reversal != null,
        reversalOfId: reversal,
      );
      final summary = DashboardSummary(
        [
          row(
            'previous-income',
            TransactionKind.entrada,
            500,
            at: DateTime(2026, 9, 1),
          ),
          row(
            'previous-expense',
            TransactionKind.despesa,
            100,
            at: DateTime(2026, 9, 2),
          ),
          row('rent-paid', TransactionKind.despesa, 400, planId: 'rent'),
          row(
            'rent-refund',
            TransactionKind.entrada,
            100,
            reversal: 'rent-paid',
          ),
          row(
            'electricity-paid',
            TransactionKind.despesa,
            350,
            planId: 'electricity',
          ),
          row('salary-paid', TransactionKind.entrada, 2500, planId: 'salary'),
          row(
            'salary-refund',
            TransactionKind.despesa,
            600,
            reversal: 'salary-paid',
          ),
          row('extra-paid', TransactionKind.despesa, 60),
          row(
            'extra-refund',
            TransactionKind.entrada,
            10,
            reversal: 'extra-paid',
          ),
          row('rollover_2026-10', TransactionKind.entrada, 90000),
          row(
            'future',
            TransactionKind.entrada,
            700,
            at: DateTime(2026, 11, 1),
          ),
        ],
        [
          plan('rent', PlanItemType.despesaObrigatoria, 1000),
          plan('electricity', PlanItemType.despesaVariavelObrigatoria, 300),
          plan('salary', PlanItemType.entradaFixa, 2000),
          plan('bonus', PlanItemType.entradaPrevista, 500),
          plan('extra', PlanItemType.despesaPrevista, 150),
          plan(
            'future-plan',
            PlanItemType.despesaObrigatoria,
            500,
          ).copyWith(monthRef: '2026-11'),
        ],
        '2026-10',
      );
      expect(DashboardEntry.total(summary.toReceive), 600);
      expect(summary.toReceive.map((e) => e.value), [100, 500]);
      expect(DashboardEntry.total(summary.mandatory), 1300);
      expect(DashboardEntry.total(summary.paidMandatory), 650);
      expect(
        summary.paidMandatory.where((e) => e.value < 0).single.value,
        -100,
      );
      expect(DashboardEntry.total(summary.additional), 50);
      expect(DashboardEntry.total(summary.plannedAdditional), 150);
      expect(DashboardEntry.total(summary.previous), 400);
      expect(summary.toPay.single.title, 'rent');
      expect(summary.toPay.single.value, 700);
      expect(DashboardEntry.total(summary.received), 1900);
      expect(DashboardEntry.total(summary.expenses), 700);
      expect(DashboardEntry.total(summary.monthResult), 1200);
      expect(DashboardEntry.total(summary.balance), 1600);
      expect(DashboardEntry.total(summary.projection), 1500);
      expect(summary.projection.last.children!.single.value, 700);
    },
  );
}
