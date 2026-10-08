import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../providers/planning_provider.dart';
import '../providers/transactions_provider.dart';
import '../providers/targets_provider.dart';
import '../providers/settings_provider.dart';
import '../services/finance_math.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/glass_card.dart';
import '../widgets/target_editor.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final all = ref.watch(transactionsProvider);
    final rows = FinanceMath.month(
      all,
      month,
    ).where((t) => !FinanceMath.isRollover(t)).toList();
    final categories = FinanceMath.expensesByCategory(rows, all);
    final names = {
      for (final t in all) t.categorySnapshotName ?? 'Sem categoria',
      ...ref
          .watch(planningProvider)
          .where((p) => !FinanceMath.isIncome(p))
          .map((p) => p.name),
    }.toList();
    final hidden = ref.watch(settingsProvider).hideAmounts;
    String money(double value) =>
        hidden ? '••••' : Formatters.formatCurrency(value);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Seu dinheiro em detalhes'),
          actions: [
            IconButton(
              tooltip: 'Exportar extrato do mês em CSV',
              icon: const Icon(Icons.download_outlined),
              onPressed: () async {
                try {
                  String cell(String value) =>
                      '"${(RegExp(r'^[=+@\-]').hasMatch(value) ? "'" : '') + value.replaceAll('"', '""')}"';
                  final csv =
                      '\uFEFFData;Descrição;Categoria;Tipo;Valor;Meio;Estorno\r\n${rows.map((t) => [Formatters.formatDate(t.date), t.title ?? '', t.categorySnapshotName ?? '', t.kind.name, t.value.toStringAsFixed(2).replaceAll('.', ','), t.paymentMethod.name, t.isReversal ? 'Sim' : 'Não'].map(cell).join(';')).join('\r\n')}';
                  final saved = await FilePicker.saveFile(
                    fileName: 'yourfinance_$month.csv',
                    bytes: Uint8List.fromList(utf8.encode(csv)),
                    mimeType: 'text/csv',
                  );
                  if (saved != null && context.mounted) {
                    SnackBarUtils.showSuccess(context, 'Relatório exportado.');
                  }
                } catch (_) {
                  if (context.mounted) {
                    SnackBarUtils.showError(
                      context,
                      'Não foi possível exportar o relatório.',
                    );
                  }
                }
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Relatórios'),
              Tab(text: 'Orçamentos'),
              Tab(text: 'Metas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'ANÁLISE • ${Formatters.formatMonthRef(month)}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Compare seus meses e entenda o destino de cada gasto. Estornos reduzem os totais; saldos transportados não são receitas.',
                ),
                const SizedBox(height: 24),
                _section(
                  context,
                  'Receitas e despesas • 6 meses',
                  _HistoryChart(all: all, month: month, hidden: hidden),
                ),
                const SizedBox(height: 20),
                _section(
                  context,
                  'Despesas por categoria',
                  _CategoryChart(
                    categories: categories,
                    money: money,
                    hidden: hidden,
                    onSelect: (name) =>
                        _showCategory(context, name, rows, all, money),
                  ),
                ),
                const SizedBox(height: 20),
                _section(
                  context,
                  'Meios de pagamento',
                  Column(
                    children: PaymentMethod.values.map((method) {
                      final subset = rows.where(
                        (t) => t.paymentMethod == method,
                      );
                      final value = FinanceMath.expensesByCategory(
                        subset,
                        all,
                      ).values.fold(0.0, (s, v) => s + v);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          method == PaymentMethod.cartaoCredito
                              ? Icons.credit_card
                              : Icons.payments_outlined,
                        ),
                        title: Text(switch (method) {
                          PaymentMethod.pix => 'Pix',
                          PaymentMethod.dinheiro => 'Dinheiro',
                          PaymentMethod.cartaoCredito => 'Cartão de crédito',
                        }),
                        trailing: Text(money(value)),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                _section(
                  context,
                  '5 maiores gastos',
                  _LargestExpenses(rows: rows, all: all, money: money),
                ),
              ],
            ),
            _targets(context, ref, true, categories, names, money),
            _targets(context, ref, false, categories, names, money),
          ],
        ),
      ),
    );
  }

  Widget _targets(
    BuildContext context,
    WidgetRef ref,
    bool budget,
    Map<String, double> categories,
    List<String> names,
    String Function(double) money,
  ) {
    final targets = ref.watch(budget ? budgetsProvider : goalsProvider);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          budget ? 'Limites que ajudam a decidir' : 'Um passo mais perto',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          budget
              ? 'O consumo acompanha o mês selecionado. Toque em um orçamento para ajustar o limite.'
              : 'Registre o total reservado e acompanhe quanto falta para chegar lá.',
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () =>
              showTargetEditor(context, budget: budget, categories: names),
          icon: const Icon(Icons.add),
          label: Text(budget ? 'Criar orçamento' : 'Criar meta'),
        ),
        const SizedBox(height: 20),
        if (targets.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Icon(
                  budget ? Icons.pie_chart_outline : Icons.flag_outlined,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  budget
                      ? 'Defina seu primeiro limite mensal.'
                      : 'Qual objetivo você quer alcançar?',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ...targets.map((target) {
          final spent = budget
              ? (target.category == null
                    ? categories.values.fold(0.0, (s, v) => s + v)
                    : categories[target.category] ?? 0.0)
              : target.saved;
          final ratio = spent / target.target;
          final color = budget
              ? (ratio >= 1
                    ? AppTheme.error
                    : ratio >= .8
                    ? AppTheme.warning
                    : AppTheme.success)
              : AppTheme.primary;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GlassCard(
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => showTargetEditor(
                  context,
                  budget: budget,
                  categories: names,
                  target: target,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              target.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const Icon(Icons.edit_outlined, size: 20),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        budget
                            ? target.category ?? 'Todas as despesas'
                            : target.deadline == null
                            ? 'Sem prazo definido'
                            : 'Até ${Formatters.formatDate(target.deadline!)}',
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: ratio.clamp(0, 1),
                        color: color,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                        semanticsLabel: target.name,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${money(spent)} de ${money(target.target)}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        budget
                            ? (ratio > 1
                                  ? 'Limite excedido em ${money(spent - target.target)}'
                                  : ratio >= .8
                                  ? 'Atenção: perto do limite'
                                  : 'Disponível: ${money(target.target - spent)}')
                            : ratio >= 1
                            ? 'Meta alcançada!'
                            : target.deadline == null
                            ? 'Faltam ${money(target.target - spent)} para alcançar a meta'
                            : 'Reserve ${money(target.monthlyContribution(DateTime.now()))} por mês${target.deadline != null && target.deadline!.isBefore(DateTime.now()) ? ' • prazo encerrado' : ''}',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

Widget _section(BuildContext context, String title, Widget child) => GlassCard(
  padding: const EdgeInsets.all(20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 20),
      child,
    ],
  ),
);

class _HistoryChart extends StatelessWidget {
  final List<Transaction> all;
  final String month;
  final bool hidden;
  const _HistoryChart({
    required this.all,
    required this.month,
    required this.hidden,
  });
  @override
  Widget build(BuildContext context) {
    final end = DateTime.parse('$month-01');
    final months = List.generate(
      6,
      (i) => FinanceMath.monthOf(DateTime(end.year, end.month - 5 + i)),
    );
    double net(String m, bool income) => FinanceMath.month(all, m)
        .where((t) => !FinanceMath.isRollover(t))
        .fold(0.0, (sum, t) {
          final originalIncome = t.isReversal
              ? t.kind == TransactionKind.despesa
              : t.kind == TransactionKind.entrada;
          return sum +
              (originalIncome == income
                  ? (t.isReversal ? -t.value : t.value)
                  : 0);
        });
    if (hidden) {
      return const Text(
        'Valores ocultos. Use o ícone de olho para exibir os gráficos.',
      );
    }
    return Column(
      children: [
        const Wrap(
          spacing: 24,
          children: [
            Text('● Receitas', style: TextStyle(color: AppTheme.success)),
            Text('● Despesas', style: TextStyle(color: AppTheme.error)),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 190,
          child: BarChart(
            BarChartData(
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, meta) => Text(
                      months[v.toInt().clamp(0, 5)].substring(5),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
              barGroups: List.generate(
                6,
                (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: net(months[i], true),
                      color: AppTheme.success,
                      width: 10,
                    ),
                    BarChartRodData(
                      toY: net(months[i], false),
                      color: AppTheme.error,
                      width: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...months.map(
          (m) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Wrap(
              spacing: 12,
              children: [
                Text(Formatters.formatMonthRef(m)),
                Text(
                  '↑ ${Formatters.formatCurrency(net(m, true))}',
                  style: const TextStyle(color: AppTheme.success),
                ),
                Text(
                  '↓ ${Formatters.formatCurrency(net(m, false))}',
                  style: const TextStyle(color: AppTheme.error),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryChart extends StatelessWidget {
  final Map<String, double> categories;
  final String Function(double) money;
  final bool hidden;
  final void Function(String) onSelect;
  const _CategoryChart({
    required this.categories,
    required this.money,
    required this.hidden,
    required this.onSelect,
  });
  static const colors = [
    AppTheme.primary,
    AppTheme.success,
    AppTheme.warning,
    Color(0xFF60A5FA),
    Color(0xFFF472B6),
    AppTheme.error,
  ];
  @override
  Widget build(BuildContext context) {
    final entries = categories.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold(0.0, (s, e) => s + e.value);
    if (entries.isEmpty) {
      return const Text(
        'Sem despesas líquidas neste mês. Registre uma despesa para começar.',
      );
    }
    return Column(
      children: [
        if (!hidden)
          SizedBox(
            height: 190,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 50,
                sectionsSpace: 3,
                sections: List.generate(
                  entries.length,
                  (i) => PieChartSectionData(
                    color: colors[i % colors.length],
                    value: entries[i].value,
                    title: '',
                    radius: 34,
                  ),
                ),
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    final index =
                        response?.touchedSection?.touchedSectionIndex ?? -1;
                    if (event is FlTapUpEvent &&
                        index >= 0 &&
                        index < entries.length) {
                      onSelect(entries[index].key);
                    }
                  },
                ),
              ),
            ),
          ),
        ...List.generate(
          entries.length,
          (i) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 6,
              backgroundColor: colors[i % colors.length],
            ),
            title: Text(entries[i].key),
            subtitle: Text(money(entries[i].value)),
            trailing: Text(
              hidden
                  ? '•••'
                  : '${(entries[i].value / total * 100).toStringAsFixed(1)}%',
            ),
            onTap: () => onSelect(entries[i].key),
          ),
        ),
      ],
    );
  }
}

class _LargestExpenses extends StatelessWidget {
  final List<Transaction> rows, all;
  final String Function(double) money;
  const _LargestExpenses({
    required this.rows,
    required this.all,
    required this.money,
  });
  @override
  Widget build(BuildContext context) {
    final reversed = all
        .where((t) => t.isReversal)
        .map((t) => t.reversalOfId)
        .toSet();
    final sorted =
        rows
            .where(
              (t) =>
                  t.kind == TransactionKind.despesa &&
                  !t.isReversal &&
                  !reversed.contains(t.id),
            )
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return Column(
      children: [
        if (sorted.isEmpty) const Text('Nenhum gasto efetivo para exibir.'),
        ...sorted
            .take(5)
            .map(
              (t) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.title ?? t.categorySnapshotName ?? 'Despesa'),
                subtitle: Text(Formatters.formatDate(t.date)),
                trailing: Text(money(t.value)),
                onTap: () => showTransactionDetails(context, t, money),
              ),
            ),
      ],
    );
  }
}

void _showCategory(
  BuildContext context,
  String name,
  List<Transaction> rows,
  List<Transaction> all,
  String Function(double) money,
) {
  final originals = {for (final t in all) t.id: t};
  final selected = rows
      .where(
        (t) =>
            (t.categorySnapshotName ??
                    originals[t.reversalOfId]?.categorySnapshotName ??
                    'Sem categoria') ==
                name &&
            ((!t.isReversal && t.kind == TransactionKind.despesa) ||
                (t.isReversal && t.kind == TransactionKind.entrada)),
      )
      .toList();
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => FractionallySizedBox(
      heightFactor: .7,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(name, style: Theme.of(context).textTheme.titleLarge),
          ),
          Expanded(
            child: ListView(
              children: selected
                  .map(
                    (t) => ListTile(
                      title: Text(t.title ?? name),
                      subtitle: Text(
                        '${Formatters.formatDate(t.date)}${t.isReversal ? ' • Estorno' : ''}',
                      ),
                      trailing: Text(money(t.value)),
                      onTap: () => showTransactionDetails(context, t, money),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    ),
  );
}

void showTransactionDetails(
  BuildContext context,
  Transaction t,
  String Function(double) money,
) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t.title ?? t.categorySnapshotName ?? 'Transação',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            money(t.value),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text('Data contábil: ${Formatters.formatDate(t.date)}'),
          Text('Registrado em: ${Formatters.formatDate(t.createdAt)}'),
          Text('Categoria: ${t.categorySnapshotName ?? 'Sem categoria'}'),
          Text('Meio: ${t.paymentMethod.name}'),
          Text(
            t.isReversal
                ? 'Estorno • original preservado'
                : 'Lançamento efetivado',
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    ),
  );
}
