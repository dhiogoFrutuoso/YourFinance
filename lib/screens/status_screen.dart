import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/planning_provider.dart';
import '../providers/transactions_provider.dart';
import '../models/plan_item.dart';
import '../models/transaction.dart' as model_transaction;
import '../utils/formatters.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class StatusScreen extends ConsumerWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthRef = ref.watch(selectedMonthProvider);
    final plannedItems = ref.watch(planningProvider);
    final transactions = ref.watch(transactionsProvider);

    // Get mandatory expenses for the current month context
    final mandatoryExpenses = plannedItems.where((i) {
      if (i.type != PlanItemType.despesaObrigatoria) return false;
      
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

    // Transactions for the current month
    final currentMonthTransactions = transactions.where((t) {
      final tMonthRef = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
      return tMonthRef == monthRef && !t.isReversal;
    }).toList();

    double totalIncomes = 0;
    for (var t in currentMonthTransactions) {
      if (t.kind == model_transaction.TransactionKind.entrada) {
        totalIncomes += t.value;
      }
    }

    // Required incomes based on planned expenses
    double requiredIncomes = 0;
    for (var p in plannedItems) {
      if (p.type == PlanItemType.despesaObrigatoria || p.type == PlanItemType.despesaPrevista) {
        requiredIncomes += p.value;
      }
    }
    
    if (requiredIncomes == 0) requiredIncomes = 1;
    double progress = (totalIncomes / requiredIncomes).clamp(0.0, 1.0);

    // Count paid
    int paidCount = 0;
    for (var expense in mandatoryExpenses) {
      final isPaid = currentMonthTransactions.any(
        (t) => t.planItemId == expense.id && t.kind == model_transaction.TransactionKind.despesa,
      );
      if (isPaid) paidCount++;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Text(
                    'Status do Mês',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (mandatoryExpenses.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$paidCount/${mandatoryExpenses.length}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── Progress Card ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassCard(
                borderColor: AppTheme.primary.withOpacity(0.2),
                boxShadow: AppTheme.glowShadow(blurRadius: 20, opacity: 0.12),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primary.withOpacity(0.15),
                          ),
                          child: const Icon(Icons.trending_up_rounded, color: AppTheme.primary, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Meta de Arrecadação',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Gradient progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Stack(
                        children: [
                          // Background
                          Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          // Progress fill with gradient
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              height: 12,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                gradient: AppTheme.primaryGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Formatters.formatCurrency(totalIncomes),
                          style: GoogleFonts.inter(
                            color: AppTheme.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.inter(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(requiredIncomes),
                          style: GoogleFonts.inter(
                            color: AppTheme.textTertiary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── Checklist Header ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.checklist_rounded, size: 20, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Contas Fixas',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ─── Checklist ───
            Expanded(
              child: mandatoryExpenses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 48, color: AppTheme.textTertiary.withOpacity(0.4)),
                          const SizedBox(height: 12),
                          Text(
                            'Nenhuma despesa obrigatória\nplanejada.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(color: AppTheme.textTertiary, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: mandatoryExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = mandatoryExpenses[index];
                        final isPaid = currentMonthTransactions.any(
                          (t) => t.planItemId == expense.id && t.kind == model_transaction.TransactionKind.despesa,
                        );

                        return _ChecklistItem(
                          expense: expense,
                          isPaid: isPaid,
                          index: index,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Checklist Item with Animation ────────────────────────────────

class _ChecklistItem extends StatelessWidget {
  final PlanItem expense;
  final bool isPaid;
  final int index;

  const _ChecklistItem({
    required this.expense,
    required this.isPaid,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Animated check circle
            _AnimatedCheckCircle(isPaid: isPaid),
            const SizedBox(width: 14),
            // Name
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isPaid ? AppTheme.textTertiary : AppTheme.textPrimary,
                  decoration: isPaid ? TextDecoration.lineThrough : TextDecoration.none,
                  decorationColor: AppTheme.textTertiary,
                ),
                child: Text(expense.name),
              ),
            ),
            // Value
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isPaid ? AppTheme.textTertiary : AppTheme.error,
              ),
              child: Text(Formatters.formatCurrency(expense.value)),
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: index * 60))
          .fadeIn(duration: 400.ms)
          .slideX(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
    );
  }
}

// ─── Animated Check Circle ────────────────────────────────────────

class _AnimatedCheckCircle extends StatelessWidget {
  final bool isPaid;

  const _AnimatedCheckCircle({required this.isPaid});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPaid ? AppTheme.primary : Colors.transparent,
        border: Border.all(
          color: isPaid ? AppTheme.primary : AppTheme.primary.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: isPaid
            ? [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.4),
                  blurRadius: 8,
                ),
              ]
            : [],
      ),
      child: isPaid
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
              .animate()
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.0, 1.0),
                duration: 300.ms,
                curve: Curves.elasticOut,
              )
          : null,
    );
  }
}
