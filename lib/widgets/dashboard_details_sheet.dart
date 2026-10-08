import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../screens/reports_screen.dart';
import '../services/dashboard_summary.dart';
import '../utils/formatters.dart';

void showDashboardDetails(
  BuildContext context, {
  required String title,
  required String month,
  required String description,
  required List<DashboardEntry> entries,
}) {
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
        ? AnimationStyle.noAnimation
        : null,
    builder: (context) => Consumer(
      builder: (context, ref, _) {
        final hidden = ref.watch(settingsProvider).hideAmounts;
        String money(double value) =>
            hidden ? '••••' : Formatters.formatCurrency(value);
        return FractionallySizedBox(
          heightFactor: .85,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Fechar detalhes',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: entries.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Referência: ${Formatters.formatMonthRef(month)}',
                              ),
                              const SizedBox(height: 8),
                              Text(
                                money(DashboardEntry.total(entries)),
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 12),
                              Text(description),
                              const SizedBox(height: 8),
                              Text(
                                entries.isEmpty
                                    ? 'Nenhum item para listar neste período.'
                                    : '${entries.length} ${entries.length == 1 ? 'item' : 'itens'} na composição',
                              ),
                            ],
                          ),
                        );
                      }
                      final entry = entries[index - 1];
                      final interactive =
                          entry.transaction != null || entry.children != null;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: !interactive
                              ? null
                              : () {
                                  if (entry.children != null) {
                                    showDashboardDetails(
                                      context,
                                      title: entry.title,
                                      month: month,
                                      description:
                                          'Itens que compõem este valor.',
                                      entries: entry.children!,
                                    );
                                  } else {
                                    showTransactionDetails(
                                      context,
                                      entry.transaction!,
                                      money,
                                    );
                                  }
                                },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  money(entry.value),
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                if (entry.note.isNotEmpty) Text(entry.note),
                                Text(
                                  entry.date == null
                                      ? (entry.planned != null
                                            ? 'Sem vencimento definido'
                                            : '')
                                      : '${entry.planned != null ? 'Vencimento' : 'Data'}: ${Formatters.formatDate(entry.date!)}',
                                ),
                                if (entry.planned != null) ...[
                                  const SizedBox(height: 8),
                                  Text('Planejado: ${money(entry.planned!)}'),
                                  Text('Realizado: ${money(entry.realized!)}'),
                                  Text(
                                    'Restante: ${money((entry.planned! - entry.realized!).clamp(0.0, double.infinity))}',
                                  ),
                                ],
                                if (interactive) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    entry.children != null
                                        ? 'Ver composição ›'
                                        : 'Ver lançamento ›',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
