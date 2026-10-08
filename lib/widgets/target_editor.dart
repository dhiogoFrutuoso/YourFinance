import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../providers/targets_provider.dart';
import '../services/finance_math.dart';
import '../widgets/glassmorphism_modal.dart';
import '../utils/formatters.dart';

Future<void> showTargetEditor(
  BuildContext context, {
  required bool budget,
  required List<String> categories,
  FinanceTarget? target,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (_) =>
      _TargetEditor(budget: budget, categories: categories, target: target),
);

class _TargetEditor extends ConsumerStatefulWidget {
  final bool budget;
  final List<String> categories;
  final FinanceTarget? target;
  const _TargetEditor({
    required this.budget,
    required this.categories,
    this.target,
  });
  @override
  ConsumerState<_TargetEditor> createState() => _TargetEditorState();
}

class _TargetEditorState extends ConsumerState<_TargetEditor> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name, _amount, _saved;
  DateTime? _deadline;
  String? _category;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.target?.name);
    _amount = TextEditingController(
      text: widget.target?.target.toStringAsFixed(2),
    );
    _saved = TextEditingController(
      text: (widget.target?.saved ?? 0).toStringAsFixed(2),
    );
    _deadline = widget.target?.deadline;
    _category = widget.target?.category;
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _saved.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = {...widget.categories, ?_category}.toList()..sort();
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        8,
        24,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.budget ? 'Orçamento mensal' : 'Meta financeira',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              widget.budget
                  ? 'Acompanhe os gastos líquidos do mês selecionado. O limite se repete a cada mês.'
                  : 'Acompanhe uma reserva manual. Atualizar a meta não movimenta o saldo do extrato.',
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nome'),
              maxLength: 80,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Informe um nome' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amount,
              decoration: InputDecoration(
                labelText: widget.budget
                    ? 'Limite mensal (R\$)'
                    : 'Valor da meta (R\$)',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) => FinanceMath.parseMoney(v) == null
                  ? 'Informe um valor positivo'
                  : null,
            ),
            const SizedBox(height: 16),
            if (widget.budget)
              DropdownButtonFormField<String>(
                initialValue: _category,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Todas as despesas'),
                  ),
                  ...categories.map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _category = v),
              ),
            if (!widget.budget) ...[
              TextFormField(
                controller: _saved,
                decoration: const InputDecoration(
                  labelText: 'Valor já reservado (R\$)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) =>
                    (v?.trim() == '0' ||
                        v?.trim() == '0.00' ||
                        v?.trim() == '0,00' ||
                        FinanceMath.parseMoney(v) != null)
                    ? null
                    : 'Informe zero ou um valor positivo',
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.event),
                label: Text(
                  _deadline == null
                      ? 'Definir prazo'
                      : 'Prazo: ${Formatters.formatDate(_deadline!)}',
                ),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _deadline ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _deadline = date);
                },
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy
                  ? null
                  : () async {
                      if (!_form.currentState!.validate()) return;
                      if (widget.target != null) {
                        final confirmed = await GlassmorphismModal.show(
                          context: context,
                          title: 'Salvar alterações?',
                          content:
                              'Os valores deste acompanhamento serão atualizados.',
                          confirmText: 'Salvar',
                        );
                        if (!confirmed || !context.mounted) return;
                      }
                      setState(() => _busy = true);
                      try {
                        await ref
                            .read(
                              widget.budget
                                  ? budgetsProvider.notifier
                                  : goalsProvider.notifier,
                            )
                            .save(
                              FinanceTarget(
                                id: widget.target?.id ?? const Uuid().v4(),
                                name: _name.text.trim(),
                                target: FinanceMath.parseMoney(_amount.text)!,
                                saved: widget.budget
                                    ? 0
                                    : FinanceMath.parseMoney(_saved.text) ?? 0,
                                category: _category,
                                deadline: _deadline,
                              ),
                            );
                        if (context.mounted) Navigator.pop(context);
                      } catch (_) {
                        if (context.mounted) {
                          setState(() => _busy = false);
                          SnackBarUtils.showError(
                            context,
                            'Não foi possível salvar. Tente novamente.',
                          );
                        }
                      }
                    },
              child: Text(_busy ? 'Salvando…' : 'Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
