import '../providers/settings_provider.dart';
import '../providers/targets_provider.dart';
import 'reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../providers/transactions_provider.dart';
import '../providers/planning_provider.dart';
import '../models/transaction.dart' as model_transaction;
import '../services/dashboard_summary.dart';
import '../widgets/dashboard_details_sheet.dart';
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
    final summary = DashboardSummary(transactions, plannedItems, monthRef);
    final totalIncomes = DashboardEntry.total(summary.received);
    final totalExpenses = DashboardEntry.total(summary.expenses);
    final balance = DashboardEntry.total(summary.balance);
    final total =
        totalIncomes.clamp(0, double.infinity) +
        totalExpenses.clamp(0, double.infinity);
    final spentPercentage = totalIncomes > 0
        ? (totalExpenses / totalIncomes * 100).clamp(0, 999)
        : 0.0;
    void details(
      String title,
      String description,
      List<DashboardEntry> entries,
    ) => showDashboardDetails(
      context,
      title: title,
      month: monthRef,
      description: description,
      entries: entries,
    );
    Widget stat(
      String label,
      IconData icon,
      Color color,
      List<DashboardEntry> entries,
      String description, {
      String? subtitle,
    }) => QuickStatCard(
      key: ValueKey(label),
      label: label,
      value: money(DashboardEntry.total(entries)),
      icon: icon,
      color: color,
      subtitle1: subtitle,
      onTap: () => details(label, description, entries),
    );
    final budgets = ref.watch(budgetsProvider);
    final goals = ref.watch(goalsProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
              // ─── Big Number Display ───
              GlassCard(
                onTap: () => details(
                  'Saldo acumulado até o mês',
                  'Entradas e saídas até o fim do mês selecionado. Lançamentos de transporte de saldo não são somados novamente.',
                  summary.balance,
                ),
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
                    const Text(
                      'Ver lançamentos ›',
                      style: TextStyle(fontSize: 12),
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

              Text(
                'Detalhes do planejamento',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              const Text('Toque em um card para ver a composição.'),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: MediaQuery.sizeOf(context).width >= 700 ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: MediaQuery.textScalerOf(context).scale(200),
                children: [
                  stat(
                    'Total a Receber',
                    Icons.download_rounded,
                    AppTheme.success,
                    summary.toReceive,
                    'Receitas planejadas ainda pendentes no mês. Cada valor desconta o que já foi recebido, considerando estornos.',
                  ),
                  stat(
                    'Obrigatório a Gastar',
                    Icons.warning_amber_rounded,
                    AppTheme.error,
                    summary.mandatory,
                    'Total planejado das despesas fixas e variáveis obrigatórias do mês, incluindo as que já foram pagas.',
                  ),
                  stat(
                    'Já Pago (Fixas)',
                    Icons.check_circle_outline_rounded,
                    AppTheme.primary,
                    summary.paidMandatory,
                    'Pagamentos vinculados às despesas obrigatórias do mês. Estornos aparecem negativos e reduzem o total.',
                  ),
                  stat(
                    'Gasto Adicional',
                    Icons.receipt_long_rounded,
                    Colors.orange,
                    summary.additional,
                    'Despesas do mês fora das obrigações planejadas. Estornos aparecem negativos e reduzem o total.',
                  ),
                  stat(
                    'Adicionais Previstas',
                    Icons.lightbulb_outline_rounded,
                    Colors.amber,
                    summary.plannedAdditional,
                    'Despesas adicionais previstas no planejamento do mês, com o valor realizado e o restante de cada item.',
                  ),
                  stat(
                    'Sobra Anterior',
                    Icons.history_rounded,
                    AppTheme.textSecondary,
                    summary.previous,
                    'Saldo de todos os lançamentos anteriores ao mês selecionado. Entradas somam e saídas subtraem, sem duplicar transferências automáticas de saldo.',
                  ),
                  stat(
                    'Falta Pagar no Mês',
                    Icons.schedule_rounded,
                    AppTheme.error,
                    summary.toPay,
                    'Despesas obrigatórias ainda pendentes no mês. Itens quitados ficam fora desta lista; pagamentos parciais e estornos ajustam o restante.',
                  ),
                  stat(
                    'Total Não Gasto (Livre)',
                    Icons.savings_rounded,
                    AppTheme.success,
                    summary.projection,
                    'Projeção: saldo acumulado + receitas restantes − despesas obrigatórias restantes. Despesas adicionais ainda não pagas não são deduzidas. Toque em cada parcela para ver seus itens.',
                    subtitle: 'Projeção após obrigações',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              GlassCard(
                onTap: () => details(
                  'Resultado do mês',
                  'Entradas menos saídas do mês selecionado, incluindo os efeitos dos estornos.',
                  summary.monthResult,
                ),
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
                    const Text('Ver lançamentos ›'),
                    const SizedBox(height: 8),
                    Text(
                      '${budgets.length} orçamentos • ${goals.length} metas em acompanhamento',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
