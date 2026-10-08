import '../providers/settings_provider.dart';
import '../providers/targets_provider.dart';
import 'reports_screen.dart';
import '../services/finance_math.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../providers/transactions_provider.dart';
import '../providers/planning_provider.dart';
import '../models/transaction.dart' as model_transaction;
import '../models/plan_item.dart';
import '../utils/formatters.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/quick_stat_card.dart';
import '../widgets/timeline_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final monthRef = ref.watch(selectedMonthProvider);
    final plannedItems = ref.watch(planningProvider);

    // Filter transactions for current month
    final currentMonthTransactions = transactions.where((t) {
      final tMonthRef =
          '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
      return tMonthRef == monthRef;
    }).toList();

    final hidden = ref.watch(settingsProvider).hideAmounts;
    String money(double value) =>
        hidden ? '••••' : Formatters.formatCurrency(value);
    final cashRows = currentMonthTransactions
        .where((t) => !FinanceMath.isRollover(t))
        .toList();
    double totalIncomes = 0, totalExpenses = 0;
    for (final t in cashRows) {
      if ((!t.isReversal &&
              t.kind == model_transaction.TransactionKind.entrada) ||
          (t.isReversal &&
              t.kind == model_transaction.TransactionKind.despesa)) {
        totalIncomes += t.isReversal ? -t.value : t.value;
      } else {
        totalExpenses += t.isReversal ? -t.value : t.value;
      }
    }
    final endOfMonth = DateTime.parse('$monthRef-01');
    final nextMonth = DateTime(endOfMonth.year, endOfMonth.month + 1);
    final balance = FinanceMath.balance(
      transactions.where((t) => t.date.isBefore(nextMonth)),
    );
    final total =
        totalIncomes.clamp(0, double.infinity) +
        totalExpenses.clamp(0, double.infinity);
    final spentPercentage = totalIncomes > 0
        ? (totalExpenses / totalIncomes * 100).clamp(0, 999)
        : 0.0;
    final currentMonthPlans = plannedItems;
    final incomePlans = currentMonthPlans.where(FinanceMath.isIncome);
    final mandatory = currentMonthPlans.where(
      (p) =>
          p.type == PlanItemType.despesaObrigatoria ||
          p.type == PlanItemType.despesaVariavelObrigatoria,
    );
    final alreadyReceived = incomePlans.fold(
      0.0,
      (s, p) => s + FinanceMath.realized(p, currentMonthTransactions),
    );
    final totalToReceive = incomePlans.fold(
      0.0,
      (s, p) =>
          s +
          (p.value - FinanceMath.realized(p, currentMonthTransactions)).clamp(
            0,
            double.infinity,
          ),
    );
    final mandatoryToSpend = mandatory.fold(0.0, (s, p) => s + p.value);
    final alreadyPaidMandatory = mandatory.fold(
      0.0,
      (s, p) => s + FinanceMath.realized(p, currentMonthTransactions),
    );
    final plannedAdditionals = currentMonthPlans
        .where((p) => p.type == PlanItemType.despesaPrevista)
        .fold(0.0, (s, p) => s + p.value);
    final spentOnAdditionals = totalExpenses - alreadyPaidMandatory;
    final rolloverMoney = FinanceMath.balance(
      transactions.where((t) => t.date.isBefore(endOfMonth)),
    );
    final leftToPay = mandatory.fold(
      0.0,
      (s, p) =>
          s +
          (p.value - FinanceMath.realized(p, currentMonthTransactions)).clamp(
            0,
            double.infinity,
          ),
    );
    final totalNaoGasto = balance + totalToReceive - leftToPay;
    final budgets = ref.watch(budgetsProvider);
    final goals = ref.watch(goalsProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Header with Greeting + Settings ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seu mês, em foco',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Visão geral das finanças',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // Logo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/logo.webp',
                          height: 32,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Settings
                      GestureDetector(
                        onTap: () => context.push('/settings'),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.surface.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: const Icon(
                            Icons.settings_rounded,
                            size: 20,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () => context.push('/reports'),
                    icon: const Icon(Icons.query_stats),
                    label: const Text('Relatórios e metas'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/transactions'),
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resultado do mês',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 24,
                      runSpacing: 12,
                      children: [
                        Text(
                          '↑ Receitas  ${money(totalIncomes)}',
                          style: const TextStyle(color: AppTheme.success),
                        ),
                        Text(
                          '↓ Despesas  ${money(totalExpenses)}',
                          style: const TextStyle(color: AppTheme.error),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Balanço: ${money(totalIncomes - totalExpenses)}'),
                    const SizedBox(height: 8),
                    Text(
                      '${budgets.length} orçamentos • ${goals.length} metas em acompanhamento',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // ─── Big Number Display ───
              GlassCard(
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 20,
                ),
                borderColor: balance >= 0
                    ? AppTheme.success.withValues(alpha: 0.15)
                    : AppTheme.error.withValues(alpha: 0.15),
                child: Column(
                  children: [
                    Text(
                      'Saldo acumulado até o mês',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        money(balance),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: balance >= 0
                              ? AppTheme.success
                              : AppTheme.error,
                          letterSpacing: -2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── Grid Analítico Preditivo ───
              ExpansionTile(
                title: const Text('Detalhes do planejamento'),
                tilePadding: EdgeInsets.zero,
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: MediaQuery.textScalerOf(context).scale(220),
                    children: [
                      QuickStatCard(
                        label: 'Total a Receber',
                        value: money(totalToReceive),
                        icon: Icons.download_rounded,
                        color: AppTheme.success,
                      ),
                      QuickStatCard(
                        label: 'Obrigatório a Gastar',
                        value: money(mandatoryToSpend),
                        icon: Icons.warning_amber_rounded,
                        color: AppTheme.error,
                      ),
                      QuickStatCard(
                        label: 'Já Pago (Fixas)',
                        value: money(alreadyPaidMandatory),
                        icon: Icons.check_circle_outline_rounded,
                        color: AppTheme.primary,
                      ),
                      QuickStatCard(
                        label: 'Gasto Adicional',
                        value: money(spentOnAdditionals),
                        icon: Icons.receipt_long_rounded,
                        color: Colors.orange,
                      ),
                      QuickStatCard(
                        label: 'Adicionais Previstas',
                        value: money(plannedAdditionals),
                        icon: Icons.lightbulb_outline_rounded,
                        color: Colors.amber,
                      ),
                      QuickStatCard(
                        label: 'Sobra Anterior',
                        value: money(rolloverMoney),
                        icon: Icons.history_rounded,
                        color: AppTheme.textSecondary,
                      ),
                      QuickStatCard(
                        label: 'Falta Pagar no Mês',
                        value: money(leftToPay),
                        icon: Icons.schedule_rounded,
                        color: AppTheme.error,
                      ),
                      QuickStatCard(
                        label: 'Projeção após obrigações',
                        value: money(totalNaoGasto),
                        icon: Icons.savings_rounded,
                        color: AppTheme.success,
                        subtitle1: 'Já recebido: ${money(alreadyReceived)}',
                        subtitle2: 'A receber: ${money(totalToReceive)}',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ─── Linha do Tempo Preditiva ───
              if (!hidden) TimelineWidget(currentBalance: balance),
              const SizedBox(height: 24),

              // ─── Donut Chart ───
              if (total > 0 && !hidden) ...[
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Distribuição',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 60,
                                startDegreeOffset: -90,
                                sections: [
                                  if (totalIncomes > 0)
                                    PieChartSectionData(
                                      color: AppTheme.success,
                                      value: totalIncomes,
                                      title: '',
                                      radius: 16,
                                    ),
                                  if (totalExpenses > 0)
                                    PieChartSectionData(
                                      color: AppTheme.error,
                                      value: totalExpenses,
                                      title: '',
                                      radius: 16,
                                    ),
                                ],
                              ),
                            ),
                            // Center text
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${spentPercentage.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  'gasto',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: AppTheme.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LegendDot(
                            color: AppTheme.success,
                            label: 'Entradas',
                          ),
                          const SizedBox(width: 24),
                          _LegendDot(color: AppTheme.error, label: 'Saídas'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ─── Recent Transactions ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Últimas Transações',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.go('/transactions');
                    },
                    child: Text(
                      'Ver todas',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildRecentTransactions(currentMonthTransactions),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(
    List<model_transaction.Transaction> transactions,
  ) {
    if (transactions.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 40,
                color: AppTheme.textTertiary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 12),
              Text(
                'Nenhuma transação neste mês.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppTheme.textTertiary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final recent = transactions.take(5).toList();

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: List.generate(recent.length, (index) {
          final t = recent[index];
          final isIncome =
              (t.kind == model_transaction.TransactionKind.entrada &&
                  !t.isReversal) ||
              (t.kind == model_transaction.TransactionKind.despesa &&
                  t.isReversal);
          final color = isIncome ? AppTheme.success : AppTheme.error;

          return Column(
            children: [
              InkWell(
                onTap: () => showTransactionDetails(
                  context,
                  t,
                  (v) => ref.read(settingsProvider).hideAmounts
                      ? '••••'
                      : Formatters.formatCurrency(v),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.12),
                        ),
                        child: Icon(
                          isIncome
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          color: color,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.title ?? t.categorySnapshotName ?? 'Transação',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              Formatters.formatDate(t.date),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: AppTheme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        ref.watch(settingsProvider).hideAmounts
                            ? '••••'
                            : '${isIncome ? '+' : '-'} ${Formatters.formatCurrency(t.value)}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (index < recent.length - 1)
                Divider(
                  height: 1,
                  indent: 66,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Legend Dot ────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
