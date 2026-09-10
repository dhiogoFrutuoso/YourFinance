import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/plan_item.dart';
import '../models/transaction.dart' as model_transaction;
import '../providers/planning_provider.dart';
import '../providers/transactions_provider.dart';
import '../services/predictive_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class TimelineWidget extends ConsumerWidget {
  final double currentBalance;

  const TimelineWidget({super.key, required this.currentBalance});

  void _showPredictiveModal(BuildContext context, DateTime targetDate, List<PlanItem> dayItems, double projectedBalance, List<model_transaction.Transaction> currentMonthTransactions) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isSafe = projectedBalance >= 0;
        double bottomBarClearance = 100.0;
        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + bottomBarClearance, left: 16, right: 16, top: 16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(
                    isSafe ? Icons.check_circle_rounded : Icons.warning_rounded,
                    color: isSafe ? AppTheme.success : AppTheme.error,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Previsão para dia ${targetDate.day}',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Mini-Extrato (Breakdown)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Saldo Atual: ${Formatters.formatCurrency(currentBalance)}', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    Text(
                      'Saldo Projetado: ${Formatters.formatCurrency(projectedBalance)}', 
                      style: GoogleFonts.inter(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold, 
                        color: isSafe ? AppTheme.success : AppTheme.error
                      )
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Eventos do Dia
              if (dayItems.isNotEmpty) ...[
                Text(
                  'Eventos deste dia:',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: dayItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = dayItems[index];
                      final isIncome = item.type == PlanItemType.entradaFixa || 
                                       item.type == PlanItemType.entradaPrevista || 
                                       item.type == PlanItemType.entradaVariavel;
                      final realized = currentMonthTransactions.where((t) => t.planItemId == item.id && !t.isReversal).fold(0.0, (s,t) => s+t.value);
                      final isResolved = realized >= item.value;
                      
                      final color = isResolved ? const Color(0xFF6B7280) : (isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444));
                      final iconData = isResolved ? Icons.check_circle_rounded : (isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded);
                      
                      return Row(
                        children: [
                          Icon(iconData, size: 16, color: color),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.name,
                              style: GoogleFonts.inter(
                                fontSize: 14, 
                                color: isResolved ? AppTheme.textTertiary : AppTheme.textPrimary,
                                decoration: isResolved ? TextDecoration.lineThrough : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            Formatters.formatCurrency(item.value),
                            style: GoogleFonts.inter(
                              fontSize: 14, 
                              fontWeight: FontWeight.bold, 
                              color: color,
                              decoration: isResolved ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Itens pagos já estão refletidos no saldo atual.',
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textTertiary, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary.withOpacity(0.15),
                  foregroundColor: AppTheme.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Entendi',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthRef = ref.watch(selectedMonthProvider);
    final parts = monthRef.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final plannedItems = ref.watch(planningProvider);
    final transactions = ref.watch(transactionsProvider);
    final now = DateTime.now();

    final currentMonthTransactions = transactions.where((t) {
      return t.date.year == year && t.date.month == month;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Linha do Tempo Preditiva',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: daysInMonth,
            itemBuilder: (context, index) {
              final day = index + 1;
              final date = DateTime(year, month, day);
              
              // Verifica se há despesas ou entradas vencendo hoje
              final itemsOnDay = plannedItems.where((i) => 
                (i.expirationDate != null && i.expirationDate!.day == day) ||
                (i.dueDate != null && i.dueDate!.day == day)
              ).toList();

              final hasBalloon = itemsOnDay.isNotEmpty;
              final isToday = now.year == year && now.month == month && now.day == day;

              return GestureDetector(
                onTap: () {
                  if (hasBalloon) {
                    final projectedBalance = PredictiveService.calculateProjectedBalance(
                      targetDate: date,
                      currentDate: now,
                      currentBalance: currentBalance,
                      currentMonthTransactions: currentMonthTransactions,
                      plannedItems: plannedItems,
                      daysInMonth: daysInMonth,
                    );
                    _showPredictiveModal(context, date, itemsOnDay, projectedBalance, currentMonthTransactions);
                  }
                },
                child: Container(
                  width: 50,
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Eixo Horizontal
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          color: isToday ? AppTheme.primary : Colors.white.withOpacity(0.05),
                        ),
                      ),
                      // Dia Text
                      Positioned(
                        bottom: 0,
                        child: Text(
                          day.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                            color: isToday ? AppTheme.primary : AppTheme.textTertiary,
                          ),
                        ),
                      ),
                      // Ponto no eixo
                      Positioned(
                        bottom: 17,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isToday ? AppTheme.primary : AppTheme.surface,
                            border: Border.all(
                              color: isToday ? AppTheme.primary : Colors.white.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      // Balão (Pin)
                      if (hasBalloon)
                        Builder(
                          builder: (context) {
                            int pendingCount = 0;
                            int paidCount = 0;
                            bool hasPendingIncome = false;
                            bool hasPendingExpense = false;
                            
                            for (var item in itemsOnDay) {
                               final realized = currentMonthTransactions.where((t) => t.planItemId == item.id && !t.isReversal).fold(0.0, (s,t) => s+t.value);
                               if (realized >= item.value) {
                                 paidCount++;
                               } else {
                                 pendingCount++;
                                 if (item.type == PlanItemType.entradaFixa || item.type == PlanItemType.entradaPrevista || item.type == PlanItemType.entradaVariavel) {
                                   hasPendingIncome = true;
                                 } else {
                                   hasPendingExpense = true;
                                 }
                               }
                            }
                            
                            Color pendingColor;
                            IconData pendingIcon;
                            if (hasPendingIncome && hasPendingExpense) {
                              pendingColor = AppTheme.primary;
                              pendingIcon = Icons.swap_vert_rounded;
                            } else if (hasPendingIncome) {
                              pendingColor = const Color(0xFF10B981);
                              pendingIcon = Icons.arrow_upward_rounded;
                            } else {
                              pendingColor = const Color(0xFFEF4444);
                              pendingIcon = Icons.arrow_downward_rounded;
                            }

                            final pendingBubble = Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: pendingColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: pendingColor.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(pendingIcon, size: 10, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    pendingCount.toString(),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );

                            final paidBubble = Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6B7280), // Cinza
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded, size: 10, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    paidCount.toString(),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );

                            return Positioned(
                              bottom: 35,
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  if (paidCount > 0 && pendingCount > 0)
                                    Positioned(
                                      top: -8,
                                      right: -8,
                                      child: paidBubble,
                                    ),
                                  if (paidCount > 0 && pendingCount == 0)
                                    paidBubble,
                                  if (pendingCount > 0)
                                    pendingBubble,
                                ],
                              ),
                            );
                          }
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
