import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../providers/transactions_provider.dart';
import '../providers/planning_provider.dart';
import '../models/transaction.dart' as model_transaction;
import '../utils/formatters.dart';

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
             totalIncomes += t.value; // Reversal of expense is an income
          } else {
             totalExpenses += t.value; // Reversal of income is an expense
          }
       }
    }

    final balance = totalIncomes - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/images/logo.png', height: 28),
            ),
            const SizedBox(width: 8),
            const Text('Dashboard'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMonthSelector(context, monthRef),
            const SizedBox(height: 24),
            _buildSummaryCards(totalIncomes, totalExpenses, balance),
            const SizedBox(height: 24),
            if (totalIncomes > 0 || totalExpenses > 0) ...[
              _buildChart(totalIncomes, totalExpenses),
              const SizedBox(height: 24),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Últimas Transações',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to Tab 2 (index 2 for Transactions)
                    // We can just switch the tab by using a global provider or letting the user tap
                    // Since go_router handles it, maybe just show a hint.
                  },
                  child: const Text('Ver todas'),
                )
              ],
            ),
            const SizedBox(height: 8),
            _buildRecentTransactions(currentMonthTransactions),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context, String currentMonthRef) {
    return InkWell(
      onTap: () async {
        final parts = currentMonthRef.split('-');
        DateTime initialDate = DateTime(int.parse(parts[0]), int.parse(parts[1]));
        
        final picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          // Help select just month and year by initialEntryMode
          initialDatePickerMode: DatePickerMode.year,
        );
        if (picked != null) {
          final newMonthRef = '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
          ref.read(selectedMonthProvider.notifier).update(newMonthRef);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 20, color: Colors.white70),
            const SizedBox(width: 8),
            Text(
              Formatters.formatMonthRef(currentMonthRef),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(double incomes, double expenses, double balance) {
    return Column(
      children: [
        _buildCard('Saldo Restante', balance, balance >= 0 ? Colors.green : Colors.red, isLarge: true),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildCard('Entradas', incomes, Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _buildCard('Saídas', expenses, Colors.red)),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(String title, double value, Color color, {bool isLarge = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            Formatters.formatCurrency(value),
            style: TextStyle(
              fontSize: isLarge ? 28 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(double incomes, double expenses) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 60,
          sections: [
            if (incomes > 0)
              PieChartSectionData(
                color: Colors.green,
                value: incomes,
                title: '${((incomes / (incomes + expenses)) * 100).toStringAsFixed(0)}%',
                radius: 20,
                titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            if (expenses > 0)
              PieChartSectionData(
                color: Colors.red,
                value: expenses,
                title: '${((expenses / (incomes + expenses)) * 100).toStringAsFixed(0)}%',
                radius: 20,
                titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(List<model_transaction.Transaction> transactions) {
    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text('Nenhuma transação neste mês.', style: TextStyle(color: Colors.white54)),
        ),
      );
    }
    
    final recent = transactions.take(5).toList();
    
    return Column(
      children: recent.map((t) {
        final isIncome = (t.kind == model_transaction.TransactionKind.entrada && !t.isReversal) || 
                         (t.kind == model_transaction.TransactionKind.despesa && t.isReversal);
        final color = isIncome ? Colors.green : Colors.red;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(
                isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                color: color,
              ),
            ),
            title: Text(t.title ?? t.categorySnapshotName ?? 'Transação'),
            subtitle: Text(Formatters.formatDate(t.date)),
            trailing: Text(
              Formatters.formatCurrency(t.value),
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
        );
      }).toList(),
    );
  }
}

