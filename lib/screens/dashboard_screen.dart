import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
      final tMonthRef = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
      return tMonthRef == monthRef;
    }).toList();

    double totalIncomes = 0;
    double totalExpenses = 0;

    for (var t in currentMonthTransactions) {
      if (!t.isReversal) {
        if (t.kind == model_transaction.TransactionKind.entrada) {
          totalIncomes += t.value;
        } else {
          totalExpenses += t.value;
        }
      }
    }
    
    // Add reversals correctly
    for (var t in currentMonthTransactions) {
       if (t.isReversal) {
          if (t.kind == model_transaction.TransactionKind.entrada) {
             totalIncomes += t.value;
          } else {
             totalExpenses += t.value;
          }
       }
    }

    final balance = totalIncomes - totalExpenses;
    final total = totalIncomes + totalExpenses;
    final spentPercentage = totalIncomes > 0 ? ((totalExpenses / totalIncomes) * 100).clamp(0, 999) : 0.0;

    final currentMonthPlans = plannedItems.where((i) {
      if (!i.isInstallment! && i.monthRef != monthRef) return false;
      if (i.expirationDate != null) {
        final currentMonthParts = monthRef.split('-');
        final currentMonthDate = DateTime(int.parse(currentMonthParts[0]), int.parse(currentMonthParts[1]));
        if (currentMonthDate.isAfter(i.expirationDate!)) return false;
      }
      if (i.isInstallment!) {
        final currentMonthParts = monthRef.split('-');
        final currentMonthDate = DateTime(int.parse(currentMonthParts[0]), int.parse(currentMonthParts[1]));
        final startMonthParts = i.monthRef.split('-');
        final startMonthDate = DateTime(int.parse(startMonthParts[0]), int.parse(startMonthParts[1]));
        if (currentMonthDate.isBefore(startMonthDate)) return false;
        final diffMonths = (currentMonthDate.year - startMonthDate.year) * 12 + currentMonthDate.month - startMonthDate.month;
        if (diffMonths >= (i.totalInstallments ?? 1)) return false;
      }
      return true;
    }).toList();

    double plannedIncomes = currentMonthPlans
        .where((i) => i.type == PlanItemType.entradaFixa || i.type == PlanItemType.entradaPrevista || i.type == PlanItemType.entradaVariavel)
        .fold(0.0, (sum, i) => sum + i.value);
    double alreadyReceived = currentMonthTransactions
        .where((t) => t.kind == model_transaction.TransactionKind.entrada && t.planItemId != null && !t.isReversal)
        .fold(0.0, (sum, t) => sum + t.value);
    double totalToReceive = (plannedIncomes - alreadyReceived).clamp(0.0, double.infinity);

    double mandatoryToSpend = currentMonthPlans
        .where((i) => i.type == PlanItemType.despesaObrigatoria || i.type == PlanItemType.despesaVariavelObrigatoria)
        .fold(0.0, (sum, i) => sum + i.value);

    double alreadyPaidMandatory = currentMonthTransactions
        .where((t) {
          if (t.kind != model_transaction.TransactionKind.despesa || t.planItemId == null || t.isReversal) return false;
          final plan = currentMonthPlans.firstWhere((p) => p.id == t.planItemId, orElse: () => PlanItem(id: '', type: PlanItemType.despesaPrevista, name: '', value: 0, monthRef: '', createdAt: DateTime.now()));
          return plan.type == PlanItemType.despesaObrigatoria || plan.type == PlanItemType.despesaVariavelObrigatoria;
        })
        .fold(0.0, (sum, t) => sum + t.value);

    double spentOnAdditionals = currentMonthTransactions
        .where((t) {
          if (t.kind != model_transaction.TransactionKind.despesa || t.isReversal) return false;
          if (t.planItemId == null) return true;
          final plan = currentMonthPlans.firstWhere((p) => p.id == t.planItemId, orElse: () => PlanItem(id: '', type: PlanItemType.despesaPrevista, name: '', value: 0, monthRef: '', createdAt: DateTime.now()));
          return plan.type == PlanItemType.despesaPrevista;
        })
        .fold(0.0, (sum, t) => sum + t.value);

    double plannedAdditionals = currentMonthPlans
        .where((i) => i.type == PlanItemType.despesaPrevista)
        .fold(0.0, (sum, i) => sum + i.value);

    double rolloverMoney = currentMonthTransactions
        .where((t) => !t.isReversal && (t.title == 'Saldo Mês Anterior' || t.title == 'Saldo Anterior Acumulado' || t.title == 'Saldo do Mês Anterior'))
        .fold(0.0, (sum, t) => sum + t.value);

    double leftToPay = (mandatoryToSpend - alreadyPaidMandatory).clamp(0.0, double.infinity);
    double totalNaoGasto = (totalToReceive + alreadyReceived) - totalExpenses;

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá! 👋',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Visão geral das finanças',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Logo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset('assets/images/logo.png', height: 32),
                      ),
                      const SizedBox(width: 8),
                      // Settings
                      GestureDetector(
                        onTap: () => context.push('/settings'),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.surface.withOpacity(0.6),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: const Icon(Icons.settings_rounded, size: 20, color: AppTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),



              // ─── Big Number Display ───
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                borderColor: balance >= 0 
                    ? AppTheme.success.withOpacity(0.15) 
                    : AppTheme.error.withOpacity(0.15),
                child: Column(
                  children: [
                    Text(
                      'Saldo Atual',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Formatters.formatCurrency(balance),
                      style: GoogleFonts.inter(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: balance >= 0 ? AppTheme.success : AppTheme.error,
                        letterSpacing: -2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── Grid Analítico Preditivo ───
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  QuickStatCard(label: 'Total a Receber', value: Formatters.formatCurrency(totalToReceive), icon: Icons.download_rounded, color: AppTheme.success),
                  QuickStatCard(label: 'Obrigatório a Gastar', value: Formatters.formatCurrency(mandatoryToSpend), icon: Icons.warning_amber_rounded, color: AppTheme.error),
                  QuickStatCard(label: 'Já Pago (Fixas)', value: Formatters.formatCurrency(alreadyPaidMandatory), icon: Icons.check_circle_outline_rounded, color: AppTheme.primary),
                  QuickStatCard(label: 'Gasto Adicional', value: Formatters.formatCurrency(spentOnAdditionals), icon: Icons.receipt_long_rounded, color: Colors.orange),
                  QuickStatCard(label: 'Adicionais Previstas', value: Formatters.formatCurrency(plannedAdditionals), icon: Icons.lightbulb_outline_rounded, color: Colors.amber),
                  QuickStatCard(label: 'Sobra Anterior', value: Formatters.formatCurrency(rolloverMoney), icon: Icons.history_rounded, color: AppTheme.textSecondary),
                  QuickStatCard(label: 'Falta Pagar no Mês', value: Formatters.formatCurrency(leftToPay), icon: Icons.schedule_rounded, color: AppTheme.error),
                  QuickStatCard(
                    label: 'Total Não Gasto (Livre)', 
                    value: Formatters.formatCurrency(totalNaoGasto), 
                    icon: Icons.savings_rounded, 
                    color: AppTheme.success,
                    subtitle1: 'Já recebido: ${Formatters.formatCurrency(alreadyReceived)}',
                    subtitle2: 'A receber: ${Formatters.formatCurrency(totalToReceive)}',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ─── Linha do Tempo Preditiva ───
              TimelineWidget(currentBalance: balance),
              const SizedBox(height: 24),

              // ─── Donut Chart ───
              if (total > 0) ...[
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Distribuição',
                        style: GoogleFonts.inter(
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
                                  style: GoogleFonts.inter(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  'gasto',
                                  style: GoogleFonts.inter(
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
                          _LegendDot(color: AppTheme.success, label: 'Entradas'),
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
                  Text(
                    'Últimas Transações',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.go('/transactions');
                    },
                    child: Text(
                      'Ver todas',
                      style: GoogleFonts.inter(
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

  Widget _buildRecentTransactions(List<model_transaction.Transaction> transactions) {
    if (transactions.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long_rounded, size: 40, color: AppTheme.textTertiary.withOpacity(0.4)),
              const SizedBox(height: 12),
              Text(
                'Nenhuma transação neste mês.',
                style: GoogleFonts.inter(color: AppTheme.textTertiary, fontSize: 14),
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
          final isIncome = (t.kind == model_transaction.TransactionKind.entrada && !t.isReversal) || 
                           (t.kind == model_transaction.TransactionKind.despesa && t.isReversal);
          final color = isIncome ? AppTheme.success : AppTheme.error;
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.12),
                      ),
                      child: Icon(
                        isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
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
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            Formatters.formatDate(t.date),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${isIncome ? '+' : '-'} ${Formatters.formatCurrency(t.value)}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              if (index < recent.length - 1)
                Divider(
                  height: 1,
                  indent: 66,
                  color: Colors.white.withOpacity(0.06),
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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
