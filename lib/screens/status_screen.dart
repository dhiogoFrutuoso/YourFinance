import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/planning_provider.dart';
import '../providers/transactions_provider.dart';
import '../models/plan_item.dart';
import '../models/transaction.dart' as model_transaction;
import '../utils/formatters.dart';
import '../theme/app_theme.dart';

class StatusScreen extends ConsumerWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthRef = ref.watch(selectedMonthProvider);
    final plannedItems = ref.watch(planningProvider);
    final transactions = ref.watch(transactionsProvider);

    // Get mandatory expenses for the current month context (from planning)
    // Need to handle installments correctly as done in planning
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

    // Incomes for the current month
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
        // filter same logic... simplified for progress bar
        requiredIncomes += p.value;
      }
    }
    
    // Safety check for division by zero
    if (requiredIncomes == 0) requiredIncomes = 1;

    double progress = (totalIncomes / requiredIncomes).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status do Mês'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primary, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Meta de Arrecadação',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(Formatters.formatCurrency(totalIncomes), style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold)),
                    Text(Formatters.formatCurrency(requiredIncomes), style: const TextStyle(color: Colors.white54)),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Despesas Obrigatórias (Checklist)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: mandatoryExpenses.isEmpty
                ? const Center(child: Text('Nenhuma despesa obrigatória planejada.', style: TextStyle(color: Colors.white54)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: mandatoryExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = mandatoryExpenses[index];
                      // Check if there is a transaction matching this planItemId in the current month
                      final isPaid = currentMonthTransactions.any(
                        (t) => t.planItemId == expense.id && t.kind == model_transaction.TransactionKind.despesa
                      );

                      return Card(
                        color: isPaid ? AppTheme.cardColor.withOpacity(0.5) : AppTheme.cardColor,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Icon(
                            isPaid ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isPaid ? AppTheme.primary : Colors.white54,
                            size: 28,
                          ),
                          title: Text(
                            expense.name,
                            style: TextStyle(
                              decoration: isPaid ? TextDecoration.lineThrough : null,
                              color: isPaid ? Colors.white54 : Colors.white,
                            ),
                          ),
                          trailing: Text(
                            Formatters.formatCurrency(expense.value),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isPaid ? Colors.white54 : AppTheme.error,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
