import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import '../providers/transactions_provider.dart';
import '../providers/planning_provider.dart';
import '../models/transaction.dart' as model_transaction;
import '../models/plan_item.dart';
import '../utils/formatters.dart';
import '../widgets/confirm_dialog.dart';
import '../theme/app_theme.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _searchQuery = '';
  Set<String> _activeFilters = {};
  bool _sortByDateDesc = true;

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    
    var filtered = transactions.where((t) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final title = (t.title ?? t.categorySnapshotName ?? '').toLowerCase();
        final value = t.value.toString();
        if (!title.contains(query) && !value.contains(query)) {
          return false;
        }
      }
      
      if (_activeFilters.isNotEmpty) {
        bool matches = false;
        if (_activeFilters.contains('Entrada') && t.kind == model_transaction.TransactionKind.entrada) matches = true;
        if (_activeFilters.contains('Despesa') && t.kind == model_transaction.TransactionKind.despesa) matches = true;
        if (_activeFilters.contains('Dinheiro') && t.paymentMethod == model_transaction.PaymentMethod.dinheiro) matches = true;
        if (_activeFilters.contains('Pix') && t.paymentMethod == model_transaction.PaymentMethod.pix) matches = true;
        if (_activeFilters.contains('Cartão') && t.paymentMethod == model_transaction.PaymentMethod.cartaoCredito) matches = true;
        if (!matches) return false;
      }
      return true;
    }).toList();

    if (!_sortByDateDesc) {
      filtered.sort((a, b) => b.value.compareTo(a.value));
    } else {
      filtered.sort((a, b) => b.date.compareTo(a.date));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro e Auditoria'),
        actions: [
          IconButton(
            icon: Icon(_sortByDateDesc ? Icons.sort : Icons.sort_by_alpha),
            onPressed: () {
              setState(() => _sortByDateDesc = !_sortByDateDesc);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar...',
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                'Entrada', 'Despesa', 'Dinheiro', 'Pix', 'Cartão'
              ].map((f) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(f),
                  selected: _activeFilters.contains(f),
                  selectedColor: AppTheme.primary.withOpacity(0.2),
                  side: BorderSide(
                    color: _activeFilters.contains(f) ? AppTheme.primary : Colors.white24,
                  ),
                  labelStyle: TextStyle(
                    color: _activeFilters.contains(f) ? AppTheme.primary : Colors.white70,
                    fontWeight: _activeFilters.contains(f) ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (sel) {
                    setState(() {
                      if (sel) _activeFilters.add(f);
                      else _activeFilters.remove(f);
                    });
                  },
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Nenhuma transação encontrada.', style: TextStyle(color: Colors.white54)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final t = filtered[index];
                      final isIncome = (t.kind == model_transaction.TransactionKind.entrada && !t.isReversal) || 
                                       (t.kind == model_transaction.TransactionKind.despesa && t.isReversal);
                      final color = isIncome ? AppTheme.success : AppTheme.error;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withOpacity(0.1),
                            child: Icon(
                              t.isReversal ? Icons.sync_alt : (isIncome ? Icons.arrow_upward : Icons.arrow_downward),
                              color: color,
                            ),
                          ),
                          title: Text(t.title ?? t.categorySnapshotName ?? 'Transação', 
                            style: TextStyle(
                              decoration: t.isReversal ? TextDecoration.lineThrough : null,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text('${Formatters.formatDate(t.date)} • ${_getMethodName(t.paymentMethod)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                Formatters.formatCurrency(t.value),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                  decoration: t.isReversal ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.white54),
                                onPressed: () => _showAddTransactionModal(
                                  context, 
                                  t.kind == model_transaction.TransactionKind.entrada, 
                                  transactionToEdit: t
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.white54),
                                onPressed: () => _confirmDelete(context, t),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'btn1',
            onPressed: () => _showAddTransactionModal(context, true),
            icon: const Icon(Icons.add),
            label: const Text('Entrada'),
            backgroundColor: AppTheme.success,
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'btn2',
            onPressed: () => _showAddTransactionModal(context, false),
            icon: const Icon(Icons.remove),
            label: const Text('Despesa'),
            backgroundColor: AppTheme.error,
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  String _getMethodName(model_transaction.PaymentMethod m) {
    switch (m) {
      case model_transaction.PaymentMethod.dinheiro: return 'Dinheiro';
      case model_transaction.PaymentMethod.pix: return 'Pix';
      case model_transaction.PaymentMethod.cartaoCredito: return 'Cartão de Crédito';
    }
  }

  void _confirmDelete(BuildContext context, model_transaction.Transaction original) async {
    final confirmed = await ConfirmDialog.show(
      context: context, 
      title: 'Excluir Transação?',
    );
    if (confirmed) {
      ref.read(transactionsProvider.notifier).reverseTransaction(original);
      HapticFeedback.heavyImpact();
    }
  }

  void _showAddTransactionModal(BuildContext context, bool isIncome, {model_transaction.Transaction? transactionToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _AddTransactionForm(isIncome: isIncome, transactionToEdit: transactionToEdit),
      ),
    );
  }
}

class _AddTransactionForm extends ConsumerStatefulWidget {
  final bool isIncome;
  final model_transaction.Transaction? transactionToEdit;
  
  const _AddTransactionForm({required this.isIncome, this.transactionToEdit});

  @override
  ConsumerState<_AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends ConsumerState<_AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _titleController = TextEditingController();
  DateTime _date = DateTime.now();
  model_transaction.PaymentMethod _paymentMethod = model_transaction.PaymentMethod.pix;
  PlanItem? _selectedPlanItem;

  @override
  void initState() {
    super.initState();
    if (widget.transactionToEdit != null) {
      final t = widget.transactionToEdit!;
      _valueController.text = t.value.toString();
      _titleController.text = t.title ?? '';
      _date = t.date;
      _paymentMethod = t.paymentMethod;
      // We cannot easily preselect _selectedPlanItem because it requires knowing the list from provider
      // but we will do it in build() if it matches.
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monthRef = ref.watch(selectedMonthProvider);
    final plannedItems = ref.watch(planningProvider);
    
    // For expenses, offer mandatory expenses as category
    final categoryOptions = widget.isIncome ? [] : plannedItems.where((i) => i.type == PlanItemType.despesaObrigatoria).toList();

    if (widget.transactionToEdit != null && _selectedPlanItem == null && widget.transactionToEdit!.planItemId != null) {
      try {
        _selectedPlanItem = categoryOptions.firstWhere((i) => i.id == widget.transactionToEdit!.planItemId);
      } catch (e) {}
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.transactionToEdit == null ? (widget.isIncome ? 'Adicionar Entrada' : 'Adicionar Despesa') : 'Editar Transação',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Valor (R\$)'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Campo obrigatório';
                if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Data'),
                child: Text(Formatters.formatDate(_date)),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<model_transaction.PaymentMethod>(
              value: _paymentMethod,
              decoration: const InputDecoration(labelText: 'Meio de Pagamento'),
              items: model_transaction.PaymentMethod.values.map((m) {
                return DropdownMenuItem(
                  value: m,
                  child: Text(_getMethodName(m)),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _paymentMethod = v);
              },
            ),
            const SizedBox(height: 16),
            if (!widget.isIncome) ...[
              DropdownButtonFormField<PlanItem?>(
                value: _selectedPlanItem,
                decoration: const InputDecoration(labelText: 'Categoria (Vínculo)'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Despesa Adicional (Não planejada)'),
                  ),
                  ...categoryOptions.map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.name),
                  ))
                ],
                onChanged: (v) {
                  setState(() => _selectedPlanItem = v);
                },
              ),
              const SizedBox(height: 16),
              if (_selectedPlanItem == null)
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Título da Despesa'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Título é obrigatório para despesas adicionais' : null,
                ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isIncome ? AppTheme.success : AppTheme.error,
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final t = model_transaction.Transaction(
                    id: widget.transactionToEdit?.id ?? const Uuid().v4(),
                    kind: widget.isIncome ? model_transaction.TransactionKind.entrada : model_transaction.TransactionKind.despesa,
                    value: double.parse(_valueController.text.replaceAll(',', '.')),
                    date: _date,
                    paymentMethod: _paymentMethod,
                    planItemId: _selectedPlanItem?.id,
                    categorySnapshotName: _selectedPlanItem?.name,
                    title: _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : null,
                    createdAt: widget.transactionToEdit?.createdAt ?? DateTime.now(),
                  );
                  ref.read(transactionsProvider.notifier).addTransaction(t); // add overwrites in Hive if ID matches
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                }
              },
              child: const Text('Salvar Transação'),
            ),
          ],
        ),
      ),
    );
  }

  String _getMethodName(model_transaction.PaymentMethod m) {
    switch (m) {
      case model_transaction.PaymentMethod.dinheiro: return 'Dinheiro';
      case model_transaction.PaymentMethod.pix: return 'Pix';
      case model_transaction.PaymentMethod.cartaoCredito: return 'Cartão de Crédito';
    }
  }
}
