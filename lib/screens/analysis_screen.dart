import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/transactions_provider.dart';
import '../providers/planning_provider.dart';
import '../models/transaction.dart' as model_transaction;
import '../models/plan_item.dart';
import '../utils/formatters.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/insight_box.dart';

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
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── Header ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primary.withOpacity(0.15),
                      ),
                      child: const Icon(Icons.insights_rounded, color: AppTheme.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Análises',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Inteligência financeira',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ─── Sections ───
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildABCSection(currentMonthTransactions),
                  const SizedBox(height: 20),
                  _buildProjectionsSection(plannedItems, monthRef),
                  const SizedBox(height: 20),
                  _buildSurvivalSection(plannedItems, currentMonthTransactions, monthRef),
                  const SizedBox(height: 20),
                  _buildPaymentMethodsSection(currentMonthTransactions),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 1. Curva ABC ──────────────────────────────────────────────

  Widget _buildABCSection(List<model_transaction.Transaction> transactions) {
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

    return _AnalysisCard(
      title: 'Curva ABC',
      subtitle: 'Concentração de Gastos',
      icon: Icons.pie_chart_rounded,
      child: Column(
        children: [
          if (sorted.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Sem dados de despesas.',
                style: GoogleFonts.inter(color: AppTheme.textTertiary, fontSize: 13),
              ),
            )
          else
            _CustomTable(
              headers: ['Categoria', 'Valor', '%'],
              rows: sorted.map((e) {
                final perc = (e.value / total) * 100;
                return [e.key, Formatters.formatCurrency(e.value), '${perc.toStringAsFixed(1)}%'];
              }).toList(),
            ),
          InsightBox(text: synthesis),
        ],
      ),
    );
  }

  // ─── 2. Projeção de Parcelas ────────────────────────────────────

  Widget _buildProjectionsSection(List<PlanItem> plannedItems, String currentMonthRef) {
    final installments = plannedItems.where((i) => i.isInstallment == true).toList();
    
    final currentMonthParts = currentMonthRef.split('-');
    final currentMonthDate = DateTime(int.parse(currentMonthParts[0]), int.parse(currentMonthParts[1]));

    double m1 = 0, m2 = 0, m3 = 0;
    
    for (var item in installments) {
      final startMonthParts = item.monthRef.split('-');
      final startMonthDate = DateTime(int.parse(startMonthParts[0]), int.parse(startMonthParts[1]));
      
      final d1 = DateTime(currentMonthDate.year, currentMonthDate.month + 1);
      final diff1 = (d1.year - startMonthDate.year) * 12 + d1.month - startMonthDate.month;
      if (diff1 >= 0 && diff1 < (item.totalInstallments ?? 1)) m1 += item.value;

      final d2 = DateTime(currentMonthDate.year, currentMonthDate.month + 2);
      final diff2 = (d2.year - startMonthDate.year) * 12 + d2.month - startMonthDate.month;
      if (diff2 >= 0 && diff2 < (item.totalInstallments ?? 1)) m2 += item.value;

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

    return _AnalysisCard(
      title: 'Projeção',
      subtitle: 'Parcelas nos Próximos 3 Meses',
      icon: Icons.timeline_rounded,
      child: Column(
        children: [
          _CustomTable(
            headers: ['Período', 'Comprometido'],
            rows: [
              ['+1 Mês', Formatters.formatCurrency(m1)],
              ['+2 Meses', Formatters.formatCurrency(m2)],
              ['+3 Meses', Formatters.formatCurrency(m3)],
            ],
          ),
          InsightBox(text: synthesis),
        ],
      ),
    );
  }

  // ─── 3. Fator de Sobrevivência ──────────────────────────────────

  Widget _buildSurvivalSection(List<PlanItem> plannedItems, List<model_transaction.Transaction> transactions, String currentMonthRef) {
    final fixedIncome = plannedItems.where((i) => i.type == PlanItemType.entradaFixa).fold<double>(0, (prev, curr) => prev + curr.value);
    final mandatoryExpense = plannedItems.where((i) => i.type == PlanItemType.despesaObrigatoria).fold<double>(0, (prev, curr) => prev + curr.value);

    final factor = mandatoryExpense > 0 ? (fixedIncome / mandatoryExpense) : 0;
    
    String synthesis = "Fator de sobrevivência não calculado (sem despesas obrigatórias).";
    Color insightColor = AppTheme.primary;
    if (mandatoryExpense > 0) {
      if (factor < 1) {
        synthesis = "ALERTA: Sua renda fixa não é suficiente para bancar sua vida fixa. Você depende de renda extra ou está gerando dívidas todos os meses.";
        insightColor = AppTheme.error;
      } else if (factor < 1.3) {
        synthesis = "Margem de segurança muito baixa. Qualquer imprevisto pode comprometer suas finanças.";
        insightColor = AppTheme.warning;
      } else {
        synthesis = "Bom! Sua renda fixa cobre tranquilamente seu padrão de vida essencial.";
        insightColor = AppTheme.success;
      }
    }

    return _AnalysisCard(
      title: 'Sobrevivência',
      subtitle: 'Renda vs. Despesa Fixa',
      icon: Icons.shield_rounded,
      child: Column(
        children: [
          _CustomTable(
            headers: ['Métrica', 'Valor'],
            rows: [
              ['Renda Fixa', Formatters.formatCurrency(fixedIncome)],
              ['Despesa Obrigatória', Formatters.formatCurrency(mandatoryExpense)],
              ['Proporção', '${factor.toStringAsFixed(2)}x'],
            ],
            valueColors: [AppTheme.success, AppTheme.error, null],
          ),
          InsightBox(text: synthesis, accentColor: insightColor),
        ],
      ),
    );
  }

  // ─── 4. Meios de Pagamento ──────────────────────────────────────

  Widget _buildPaymentMethodsSection(List<model_transaction.Transaction> transactions) {
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
    Color insightColor = AppTheme.primary;
    if (pixCount > 0 || creditCount > 0 || moneyCount > 0) {
      if (creditTotal > (pixTotal + moneyTotal) * 2) {
        synthesis = "CUIDADO: Uso desproporcional do Cartão de Crédito. Alto risco de descontrole e falsa sensação de poder de compra.";
        insightColor = AppTheme.error;
      } else if (pixCount > 10) {
        synthesis = "Muitas transações via Pix identificadas. Cuidado com micro-gastos que somam grandes valores invisíveis.";
        insightColor = AppTheme.warning;
      } else {
        synthesis = "Uso equilibrado dos meios de pagamento.";
        insightColor = AppTheme.success;
      }
    }

    return _AnalysisCard(
      title: 'Pagamentos',
      subtitle: 'Uso de Meios de Pagamento',
      icon: Icons.credit_card_rounded,
      child: Column(
        children: [
          _CustomTable(
            headers: ['Método', 'Qtd', 'Total'],
            rows: [
              ['Pix', '$pixCount', Formatters.formatCurrency(pixTotal)],
              ['Cartão', '$creditCount', Formatters.formatCurrency(creditTotal)],
              ['Dinheiro', '$moneyCount', Formatters.formatCurrency(moneyTotal)],
            ],
          ),
          InsightBox(text: synthesis, accentColor: insightColor),
        ],
      ),
    );
  }
}

// ─── Analysis Card Container ──────────────────────────────────────

class _AnalysisCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _AnalysisCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary.withOpacity(0.12),
                  ),
                  child: Icon(icon, color: AppTheme.primary, size: 16),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withOpacity(0.06)),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─── Custom Table (Row/Column based, no DataTable) ────────────────

class _CustomTable extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;
  final List<Color?>? valueColors;

  const _CustomTable({
    required this.headers,
    required this.rows,
    this.valueColors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header row
        Row(
          children: headers.asMap().entries.map((entry) {
            final isFirst = entry.key == 0;
            final isLast = entry.key == headers.length - 1;
            return Expanded(
              flex: isFirst ? 3 : 2,
              child: Text(
                entry.value,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textTertiary,
                  letterSpacing: 0.5,
                ),
                textAlign: isLast ? TextAlign.right : (isFirst ? TextAlign.left : TextAlign.center),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Divider(height: 1, color: Colors.white.withOpacity(0.06)),

        // Data rows
        ...rows.asMap().entries.map((rowEntry) {
          final rowIndex = rowEntry.key;
          final row = rowEntry.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: row.asMap().entries.map((cellEntry) {
                    final colIndex = cellEntry.key;
                    final isFirst = colIndex == 0;
                    final isLast = colIndex == row.length - 1;
                    Color? cellColor;
                    if (valueColors != null && rowIndex < valueColors!.length && colIndex > 0) {
                      cellColor = valueColors![rowIndex];
                    }
                    return Expanded(
                      flex: isFirst ? 3 : 2,
                      child: Text(
                        cellEntry.value,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: isFirst ? FontWeight.w500 : FontWeight.w600,
                          color: cellColor ?? (isFirst ? AppTheme.textSecondary : AppTheme.textPrimary),
                        ),
                        textAlign: isLast ? TextAlign.right : (isFirst ? TextAlign.left : TextAlign.center),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (rowIndex < rows.length - 1)
                Divider(height: 1, color: Colors.white.withOpacity(0.04)),
            ],
          );
        }),
      ],
    );
  }
}
