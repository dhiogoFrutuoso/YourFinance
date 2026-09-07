import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import '../providers/planning_provider.dart';
import '../models/plan_item.dart';
import '../utils/formatters.dart';
import '../widgets/confirm_dialog.dart';

class PlanningScreen extends ConsumerStatefulWidget {
  const PlanningScreen({super.key});

  @override
  ConsumerState<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends ConsumerState<PlanningScreen> {
  @override
  Widget build(BuildContext context) {
    final monthRef = ref.watch(selectedMonthProvider);
    final allItems = ref.watch(planningProvider);

    // Filter items based on installments and expiration date
    final items = allItems.where((i) {
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

    double totalIncomes = 0;
    double totalExpenses = 0;

    for (var item in items) {
      if (item.type == PlanItemType.entradaFixa || item.type == PlanItemType.entradaPrevista) {
        totalIncomes += item.value;
      } else {
        totalExpenses += item.value;
      }
    }
    
    final balance = totalIncomes - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planejamento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Duplicar do mês anterior',
            onPressed: () async {
              await ref.read(planningProvider.notifier).duplicatePreviousMonthItems();
              HapticFeedback.mediumImpact();
              if (mounted) {
                SnackBarUtils.showSuccess(context, 'Itens do mês anterior duplicados!');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(totalIncomes, totalExpenses, balance),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum item planejado para este mês.\nToque em + para adicionar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      
                      String installmentText = '';
                      if (item.isInstallment == true) {
                        final currentMonthParts = monthRef.split('-');
                        final currentMonthDate = DateTime(int.parse(currentMonthParts[0]), int.parse(currentMonthParts[1]));
                        final startMonthParts = item.monthRef.split('-');
                        final startMonthDate = DateTime(int.parse(startMonthParts[0]), int.parse(startMonthParts[1]));
                        final diffMonths = (currentMonthDate.year - startMonthDate.year) * 12 + currentMonthDate.month - startMonthDate.month;
                        installmentText = ' (Parcela ${diffMonths + 1}/${item.totalInstallments})';
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Icon(
                            _getIconForType(item.type),
                            color: _getColorForType(item.type),
                          ),
                          title: Text('${item.name}$installmentText'),
                          subtitle: Text(
                            item.expirationDate != null 
                              ? 'Válido até: ${Formatters.formatDate(item.expirationDate!)}'
                              : (item.description ?? _getTypeName(item.type)),
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                Formatters.formatCurrency(item.value),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getColorForType(item.type),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.white54),
                                onPressed: () => _showAddItemModal(context, monthRef, item: item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.white54),
                                onPressed: () => _confirmDelete(context, item.id, item.name),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemModal(context, monthRef),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(double incomes, double expenses, double balance) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).primaryColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Síntese do Planejamento', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Receitas Previstas:', style: TextStyle(color: Colors.white)),
              Text(Formatters.formatCurrency(incomes), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Despesas Previstas:', style: TextStyle(color: Colors.white)),
              Text(Formatters.formatCurrency(expenses), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Saldo Restante:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(
                Formatters.formatCurrency(balance), 
                style: TextStyle(
                  color: balance >= 0 ? Colors.green : Colors.red, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 18
                )
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(PlanItemType type) {
    switch (type) {
      case PlanItemType.entradaFixa:
        return Icons.account_balance_wallet;
      case PlanItemType.entradaPrevista:
        return Icons.trending_up;
      case PlanItemType.despesaObrigatoria:
        return Icons.receipt_long;
      case PlanItemType.despesaPrevista:
        return Icons.shopping_cart;
    }
  }

  Color _getColorForType(PlanItemType type) {
    if (type == PlanItemType.entradaFixa || type == PlanItemType.entradaPrevista) {
      return Colors.green;
    }
    return Colors.red;
  }

  String _getTypeName(PlanItemType type) {
    switch (type) {
      case PlanItemType.entradaFixa:
        return 'Entrada Fixa';
      case PlanItemType.entradaPrevista:
        return 'Entrada Prevista';
      case PlanItemType.despesaObrigatoria:
        return 'Despesa Obrigatória';
      case PlanItemType.despesaPrevista:
        return 'Despesa Prevista';
    }
  }

  void _confirmDelete(BuildContext context, String id, String itemName) async {
    final confirmed = await ConfirmDialog.show(
      context: context, 
      title: 'Excluir $itemName?'
    );
    if (confirmed) {
      ref.read(planningProvider.notifier).removePlanItem(id);
    }
  }

  void _showAddItemModal(BuildContext context, String monthRef, {PlanItem? item}) {
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
        child: _AddItemForm(monthRef: monthRef, itemToEdit: item),
      ),
    );
  }
}

class _AddItemForm extends ConsumerStatefulWidget {
  final String monthRef;
  final PlanItem? itemToEdit;
  
  const _AddItemForm({required this.monthRef, this.itemToEdit});

  @override
  ConsumerState<_AddItemForm> createState() => _AddItemFormState();
}

class _AddItemFormState extends ConsumerState<_AddItemForm> {
  final _formKey = GlobalKey<FormState>();
  late PlanItemType _type;
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _valueController = TextEditingController();
  
  bool _isInstallment = false;
  final _installmentsController = TextEditingController();
  DateTime? _expirationDate;

  @override
  void initState() {
    super.initState();
    if (widget.itemToEdit != null) {
      _type = widget.itemToEdit!.type;
      _nameController.text = widget.itemToEdit!.name;
      _descController.text = widget.itemToEdit!.description ?? '';
      _valueController.text = widget.itemToEdit!.value.toString();
      _isInstallment = widget.itemToEdit!.isInstallment ?? false;
      _installmentsController.text = widget.itemToEdit!.totalInstallments?.toString() ?? '';
      _expirationDate = widget.itemToEdit!.expirationDate;
    } else {
      _type = PlanItemType.despesaObrigatoria;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _valueController.dispose();
    _installmentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.itemToEdit == null ? 'Novo Item de Planejamento' : 'Editar Item',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<PlanItemType>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Tipo de Item'),
              items: PlanItemType.values.map((t) {
                return DropdownMenuItem(
                  value: t,
                  child: Text(_getTypeName(t)),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _type = v);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome (ex: Aluguel)'),
              validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('É parcelado?', style: TextStyle(fontSize: 16, color: Colors.white)),
                Switch(
                  value: _isInstallment,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (val) => setState(() => _isInstallment = val),
                ),
              ],
            ),
            if (_isInstallment) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _installmentsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total de Parcelas'),
                validator: (v) {
                  if (_isInstallment && (v == null || int.tryParse(v) == null)) {
                    return 'Insira um número válido';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _expirationDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _expirationDate = picked);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Data de Validade (Opcional)',
                  suffixIcon: _expirationDate != null 
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _expirationDate = null),
                      ) 
                    : null
                ),
                child: Text(_expirationDate != null ? Formatters.formatDate(_expirationDate!) : 'Nenhuma (Sempre válido)'),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final item = PlanItem(
                    id: widget.itemToEdit?.id ?? const Uuid().v4(),
                    type: _type,
                    name: _nameController.text.trim(),
                    description: _descController.text.trim(),
                    value: double.parse(_valueController.text.replaceAll(',', '.')),
                    monthRef: widget.itemToEdit?.monthRef ?? widget.monthRef,
                    createdAt: widget.itemToEdit?.createdAt ?? DateTime.now(),
                    isInstallment: _isInstallment,
                    totalInstallments: _isInstallment ? int.parse(_installmentsController.text) : null,
                    expirationDate: _expirationDate,
                  );
                  ref.read(planningProvider.notifier).addPlanItem(item);
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getTypeName(PlanItemType type) {
    switch (type) {
      case PlanItemType.entradaFixa:
        return 'Entrada Fixa';
      case PlanItemType.entradaPrevista:
        return 'Entrada Prevista';
      case PlanItemType.despesaObrigatoria:
        return 'Despesa Obrigatória';
      case PlanItemType.despesaPrevista:
        return 'Despesa Adicional Prevista';
    }
  }
}
