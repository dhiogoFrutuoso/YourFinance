import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transactions_provider.dart';
import '../providers/planning_provider.dart';
import '../models/transaction.dart' as model_transaction;
import '../models/plan_item.dart';
import '../utils/formatters.dart';
import '../theme/app_theme.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final plannedItems = ref.watch(planningProvider);
    final monthRef = ref.watch(selectedMonthProvider);

    final currentMonthTransactions = transactions.where((t) {
      final tMonthRef = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
      return tMonthRef == monthRef && !t.isReversal;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análises Inteligentes'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildABC(currentMonthTransactions),
            const SizedBox(height: 32),
            _buildProjections(plannedItems, monthRef),
            const SizedBox(height: 32),
            _buildSurvivalFactor(plannedItems, currentMonthTransactions, monthRef),
            const SizedBox(height: 32),
            _buildPaymentMethods(currentMonthTransactions),
            const SizedBox(height: 48), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildABC(List<model_transaction.Transaction> transactions) {
    final expenses = transactions.where((t) => t.kind == model_transaction.TransactionKind.despesa).toList();
    
    double total = 0;
    final map = <String, double>{};
    for (var e in expenses) {
      final name = e.categorySnapshotName ?? e.title ?? 'Outros';
      map[name] = (map[name] ?? 0) + e.value;
      total += e.value;
    }

    final sorted = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    
    String synthesis = "Você não registrou despesas neste mês.";
    if (sorted.isNotEmpty) {
      final top = sorted.first;
      final perc = (top.value / total) * 100;
      synthesis = "A categoria '${top.key}' está drenando ${perc.toStringAsFixed(1)}% de seus recursos. ";
      if (perc > 40) {
        synthesis += "Atenção: Concentração muito alta! Tente diversificar ou reduzir.";
      } else {
        synthesis += "Está dentro de um limite gerenciável.";
      }
    }

    return _buildCard(
      title: '1. Curva ABC (Concentração de Gastos)',
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Categoria')),
                DataColumn(label: Text('Valor'), numeric: true),
                DataColumn(label: Text('%'), numeric: true),
              ],
              rows: sorted.map((e) {
                final perc = (e.value / total) * 100;
                return DataRow(cells: [
                  DataCell(Text(e.key)),
                  DataCell(Text(Formatters.formatCurrency(e.value))),
                  DataCell(Text('${perc.toStringAsFixed(1)}%')),
                ]);
              }).toList(),
            ),
          ),
          _buildSynthesis(synthesis),
        ],
      ),
    );
  }

  Widget _buildProjections(List<PlanItem> plannedItems, String currentMonthRef) {
    final installments = plannedItems.where((i) => i.isInstallment == true).toList();
    
    final currentMonthParts = currentMonthRef.split('-');
    final currentMonthDate = DateTime(int.parse(currentMonthParts[0]), int.parse(currentMonthParts[1]));

    double m1 = 0, m2 = 0, m3 = 0;
    
    for (var item in installments) {
      final startMonthParts = item.monthRef.split('-');
      final startMonthDate = DateTime(int.parse(startMonthParts[0]), int.parse(startMonthParts[1]));
      
      // month 1 (next month)
      final d1 = DateTime(currentMonthDate.year, currentMonthDate.month + 1);
      final diff1 = (d1.year - startMonthDate.year) * 12 + d1.month - startMonthDate.month;
      if (diff1 >= 0 && diff1 < (item.totalInstallments ?? 1)) m1 += item.value;

      // month 2
      final d2 = DateTime(currentMonthDate.year, currentMonthDate.month + 2);
      final diff2 = (d2.year - startMonthDate.year) * 12 + d2.month - startMonthDate.month;
      if (diff2 >= 0 && diff2 < (item.totalInstallments ?? 1)) m2 += item.value;

      // month 3
      final d3 = DateTime(currentMonthDate.year, currentMonthDate.month + 3);
      final diff3 = (d3.year - startMonthDate.year) * 12 + d3.month - startMonthDate.month;
      if (diff3 >= 0 && diff3 < (item.totalInstallments ?? 1)) m3 += item.value;
    }

    String synthesis = "Você não tem parcelamentos ativos nos próximos meses.";
    if (m1 > 0 || m2 > 0 || m3 > 0) {
      if (m3 < m2 && m3 < m1) {
        synthesis = "O fluxo de caixa ficará mais aliviado daqui a 3 meses.";
      } else if (m1 > 1000) {
        synthesis = "Sua renda do próximo mês já está fortemente comprometida com dívidas passadas.";
      } else {
        synthesis = "Parcelamentos sob controle aparente nos próximos 90 dias.";
      }
    }

    return _buildCard(
      title: '2. Projeção de Parcelas (Próximos 3 Meses)',
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Mês')),
                DataColumn(label: Text('Dívida Comprometida'), numeric: true),
              ],
              rows: [
                DataRow(cells: [const DataCell(Text('+1 Mês')), DataCell(Text(Formatters.formatCurrency(m1)))]),
                DataRow(cells: [const DataCell(Text('+2 Meses')), DataCell(Text(Formatters.formatCurrency(m2)))]),
                DataRow(cells: [const DataCell(Text('+3 Meses')), DataCell(Text(Formatters.formatCurrency(m3)))]),
              ],
            ),
          ),
          _buildSynthesis(synthesis),
        ],
      ),
    );
  }

  Widget _buildSurvivalFactor(List<PlanItem> plannedItems, List<model_transaction.Transaction> transactions, String currentMonthRef) {
    // Only current month planned
    final fixedIncome = plannedItems.where((i) => i.type == PlanItemType.entradaFixa).fold<double>(0, (prev, curr) => prev + curr.value);
    final mandatoryExpense = plannedItems.where((i) => i.type == PlanItemType.despesaObrigatoria).fold<double>(0, (prev, curr) => prev + curr.value);

    final factor = mandatoryExpense > 0 ? (fixedIncome / mandatoryExpense) : 0;
    
    String synthesis = "Fator de sobrevivência não calculado (sem despesas obrigatórias).";
    if (mandatoryExpense > 0) {
      if (factor < 1) {
        synthesis = "ALERTA: Sua renda fixa não é suficiente para bancar sua vida fixa. Você depende de renda extra ou está gerando dívidas todos os meses.";
      } else if (factor < 1.3) {
        synthesis = "Margem de segurança muito baixa. Qualquer imprevisto pode comprometer suas finanças.";
      } else {
        synthesis = "Bom! Sua renda fixa cobre tranquilamente seu padrão de vida essencial.";
      }
    }

    return _buildCard(
      title: '3. Fator de Sobrevivência',
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Métrica')),
                DataColumn(label: Text('Valor'), numeric: true),
              ],
              rows: [
                DataRow(cells: [const DataCell(Text('Renda Fixa')), DataCell(Text(Formatters.formatCurrency(fixedIncome), style: const TextStyle(color: AppTheme.success)))]),
                DataRow(cells: [const DataCell(Text('Despesa Obrigatória')), DataCell(Text(Formatters.formatCurrency(mandatoryExpense), style: const TextStyle(color: AppTheme.error)))]),
                DataRow(cells: [const DataCell(Text('Proporção (Renda/Despesa)')), DataCell(Text('${factor.toStringAsFixed(2)}x'))]),
              ],
            ),
          ),
          _buildSynthesis(synthesis),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(List<model_transaction.Transaction> transactions) {
    int pixCount = 0; double pixTotal = 0;
    int creditCount = 0; double creditTotal = 0;
    int moneyCount = 0; double moneyTotal = 0;

    for (var t in transactions) {
      if (t.kind == model_transaction.TransactionKind.despesa) {
        if (t.paymentMethod == model_transaction.PaymentMethod.pix) { pixCount++; pixTotal += t.value; }
        else if (t.paymentMethod == model_transaction.PaymentMethod.cartaoCredito) { creditCount++; creditTotal += t.value; }
        else if (t.paymentMethod == model_transaction.PaymentMethod.dinheiro) { moneyCount++; moneyTotal += t.value; }
      }
    }

    String synthesis = "Nenhuma despesa registrada ainda.";
    if (pixCount > 0 || creditCount > 0 || moneyCount > 0) {
      if (creditTotal > (pixTotal + moneyTotal) * 2) {
        synthesis = "CUIDADO: Uso desproporcional do Cartão de Crédito. Alto risco de descontrole e falsa sensação de poder de compra.";
      } else if (pixCount > 10) {
        synthesis = "Muitas transações via Pix identificadas. Cuidado com micro-gastos que somam grandes valores invisíveis.";
      } else {
        synthesis = "Uso equilibrado dos meios de pagamento.";
      }
    }

    return _buildCard(
      title: '4. Uso de Meios de Pagamento',
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Método')),
                DataColumn(label: Text('Qtd')),
                DataColumn(label: Text('Total'), numeric: true),
              ],
              rows: [
                DataRow(cells: [const DataCell(Text('Pix')), DataCell(Text('$pixCount')), DataCell(Text(Formatters.formatCurrency(pixTotal)))]),
                DataRow(cells: [const DataCell(Text('Cartão')), DataCell(Text('$creditCount')), DataCell(Text(Formatters.formatCurrency(creditTotal)))]),
                DataRow(cells: [const DataCell(Text('Dinheiro')), DataCell(Text('$moneyCount')), DataCell(Text(Formatters.formatCurrency(moneyTotal)))]),
              ],
            ),
          ),
          _buildSynthesis(synthesis),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildSynthesis(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Síntese:',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryLight),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }
}
