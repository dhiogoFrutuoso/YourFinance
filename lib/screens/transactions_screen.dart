import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../providers/transactions_provider.dart';
import '../providers/planning_provider.dart';
import '../models/transaction.dart' as model_transaction;
import '../models/plan_item.dart';
import '../utils/formatters.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/glassmorphism_modal.dart';
import '../widgets/neon_text_field.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _searchQuery = '';
  final Set<String> _activeFilters = {};
  bool _sortByDateDesc = true;
  bool _searchExpanded = false;
  DateTimeRange? _filterDateRange;

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
      
      if (_filterDateRange != null) {
        final d = DateTime(t.date.year, t.date.month, t.date.day);
        final start = DateTime(_filterDateRange!.start.year, _filterDateRange!.start.month, _filterDateRange!.start.day);
        final end = DateTime(_filterDateRange!.end.year, _filterDateRange!.end.month, _filterDateRange!.end.day);
        if (d.isBefore(start) || d.isAfter(end)) return false;
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

    // Group by day for sticky headers
    final grouped = _groupByDay(filtered);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Extrato',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _sortByDateDesc ? Icons.sort_rounded : Icons.sort_by_alpha_rounded,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () => setState(() => _sortByDateDesc = !_sortByDateDesc),
                  ),
                  IconButton(
                    icon: Icon(
                      _filterDateRange != null ? Icons.filter_alt_rounded : Icons.filter_alt_outlined,
                      color: _filterDateRange != null ? AppTheme.primary : AppTheme.textSecondary,
                    ),
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: _filterDateRange,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: AppTheme.primary,
                                surface: AppTheme.surface,
                                onSurface: AppTheme.textPrimary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() => _filterDateRange = picked);
                      }
                    },
                  ),
                  IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _searchExpanded ? Icons.close_rounded : Icons.search_rounded,
                        key: ValueKey(_searchExpanded),
                        color: _searchExpanded ? AppTheme.primary : AppTheme.textSecondary,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _searchExpanded = !_searchExpanded;
                        if (!_searchExpanded) _searchQuery = '';
                      });
                    },
                  ),
                ],
              ),
            ),

            // ─── Expandable Search Bar ───
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: NeonTextField(
                  hintText: 'Pesquisar transações...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textTertiary, size: 20),
                  onChanged: (v) => setState(() => _searchQuery = v),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                ),
              ),
              crossFadeState: _searchExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
              sizeCurve: Curves.easeOutCubic,
            ),

            // ─── Filter Chips ───
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (_filterDateRange != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _filterDateRange = null),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.primary),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${Formatters.formatDate(_filterDateRange!.start)} - ${Formatters.formatDate(_filterDateRange!.end)}',
                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.close_rounded, size: 14, color: AppTheme.primary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ...['Entrada', 'Despesa', 'Dinheiro', 'Pix', 'Cartão'].map((f) {
                  final isActive = _activeFilters.contains(f);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isActive) _activeFilters.remove(f);
                          else _activeFilters.add(f);
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive ? AppTheme.primary : Colors.white.withOpacity(0.15),
                            width: 1,
                          ),
                          boxShadow: isActive
                              ? AppTheme.glowShadow(blurRadius: 8, opacity: 0.2)
                              : [],
                        ),
                        child: Text(
                          f,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                            color: isActive ? Colors.white : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ─── Transaction List with Sticky Headers ───
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: AppTheme.textTertiary.withOpacity(0.4)),
                          const SizedBox(height: 12),
                          Text(
                            'Nenhuma transação encontrada.',
                            style: GoogleFonts.inter(color: AppTheme.textTertiary, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      itemCount: grouped.length,
                      itemBuilder: (context, index) {
                        final group = grouped[index];
                        return _DayGroup(
                          dayLabel: group.label,
                          transactions: group.transactions,
                          onEdit: (t) => _showAddTransactionModal(
                            context,
                            t.kind == model_transaction.TransactionKind.entrada,
                            transactionToEdit: t,
                          ),
                          onDelete: (t) => _confirmDelete(context, t),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Income FAB
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: AppTheme.success.withOpacity(0.3), blurRadius: 12),
                ],
              ),
              child: FloatingActionButton.extended(
                heroTag: 'btn_income',
                onPressed: () => _showAddTransactionModal(context, true),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text('Entrada', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                backgroundColor: AppTheme.success,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 10),
            // Expense FAB
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: AppTheme.error.withOpacity(0.3), blurRadius: 12),
                ],
              ),
              child: FloatingActionButton.extended(
                heroTag: 'btn_expense',
                onPressed: () => _showAddTransactionModal(context, false),
                icon: const Icon(Icons.remove_rounded, size: 20),
                label: Text('Despesa', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                backgroundColor: AppTheme.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_DayGroupData> _groupByDay(List<model_transaction.Transaction> transactions) {
    final Map<String, List<model_transaction.Transaction>> map = {};
    for (var t in transactions) {
      final key = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []);
      map[key]!.add(t);
    }

    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final yesterdayKey = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    final sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));

    return sortedKeys.map((key) {
      String label;
      if (key == today) {
        label = 'Hoje';
      } else if (key == yesterdayKey) {
        label = 'Ontem';
      } else {
        final parts = key.split('-');
        label = '${parts[2]}/${parts[1]}/${parts[0]}';
      }
      return _DayGroupData(label: label, transactions: map[key]!);
    }).toList();
  }

  void _confirmDelete(BuildContext context, model_transaction.Transaction original) async {
    final confirmed = await GlassmorphismModal.show(
      context: context, 
      title: 'Excluir Transação?',
      content: 'O estorno será registrado automaticamente.',
      confirmText: 'Excluir',
      confirmIcon: Icons.delete_outline_rounded,
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
      backgroundColor: Colors.transparent,
      builder: (context) => _AddTransactionSheet(isIncome: isIncome, transactionToEdit: transactionToEdit),
    );
  }
}

// ─── Day Group Data ───────────────────────────────────────────────

class _DayGroupData {
  final String label;
  final List<model_transaction.Transaction> transactions;
  const _DayGroupData({required this.label, required this.transactions});
}

// ─── Day Group Widget ─────────────────────────────────────────────

class _DayGroup extends StatelessWidget {
  final String dayLabel;
  final List<model_transaction.Transaction> transactions;
  final ValueChanged<model_transaction.Transaction> onEdit;
  final ValueChanged<model_transaction.Transaction> onDelete;

  const _DayGroup({
    required this.dayLabel,
    required this.transactions,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sticky-style day header
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 0, 8),
          child: Text(
            dayLabel,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        // Transaction items
        ...transactions.map((t) => _TransactionTile(
          transaction: t,
          onEdit: () => onEdit(t),
          onDelete: () => onDelete(t),
        )),
      ],
    );
  }
}

// ─── Individual Transaction Tile (Dismissible) ────────────────────

class _TransactionTile extends StatelessWidget {
  final model_transaction.Transaction transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TransactionTile({
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _getPaymentIcon(model_transaction.PaymentMethod method) {
    switch (method) {
      case model_transaction.PaymentMethod.dinheiro:
        return Icons.payments_rounded;
      case model_transaction.PaymentMethod.pix:
        return Icons.bolt_rounded;
      case model_transaction.PaymentMethod.cartaoCredito:
        return Icons.credit_card_rounded;
    }
  }

  String _getMethodName(model_transaction.PaymentMethod m) {
    switch (m) {
      case model_transaction.PaymentMethod.dinheiro: return 'Dinheiro';
      case model_transaction.PaymentMethod.pix: return 'Pix';
      case model_transaction.PaymentMethod.cartaoCredito: return 'Cartão';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final isIncome = (t.kind == model_transaction.TransactionKind.entrada && !t.isReversal) ||
                     (t.kind == model_transaction.TransactionKind.despesa && t.isReversal);
    final color = isIncome ? AppTheme.success : AppTheme.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey(t.id),
        background: _dismissBackground(
          alignment: Alignment.centerLeft,
          color: AppTheme.primary,
          icon: Icons.edit_rounded,
          label: 'Editar',
        ),
        secondaryBackground: _dismissBackground(
          alignment: Alignment.centerRight,
          color: AppTheme.error,
          icon: Icons.delete_outline_rounded,
          label: 'Excluir',
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            onEdit();
            return false;
          } else {
            onDelete();
            return false;
          }
        },
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Payment method icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.12),
                ),
                child: Icon(
                  t.isReversal ? Icons.sync_alt_rounded : _getPaymentIcon(t.paymentMethod),
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              // Title + details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title ?? t.categorySnapshotName ?? 'Transação',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        decoration: t.isReversal ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${Formatters.formatDate(t.date)} • ${_getMethodName(t.paymentMethod)}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // Value
              Text(
                '${isIncome ? '+' : '-'} ${Formatters.formatCurrency(t.value)}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                  decoration: t.isReversal ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dismissBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignment == Alignment.centerLeft
            ? [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Text(label, style: GoogleFonts.inter(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
              ]
            : [
                Text(label, style: GoogleFonts.inter(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(width: 8),
                Icon(icon, color: color, size: 22),
              ],
      ),
    );
  }
}

// ─── Add Transaction Bottom Sheet ─────────────────────────────────

class _AddTransactionSheet extends ConsumerStatefulWidget {
  final bool isIncome;
  final model_transaction.Transaction? transactionToEdit;
  
  const _AddTransactionSheet({required this.isIncome, this.transactionToEdit});

  @override
  ConsumerState<_AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<_AddTransactionSheet> {
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
    ref.watch(selectedMonthProvider);
    final plannedItems = ref.watch(planningProvider);
    final transactions = ref.watch(transactionsProvider);
    
    final totalIncomes = transactions.where((t) => t.kind == model_transaction.TransactionKind.entrada && !t.isReversal).fold(0.0, (sum, t) => sum + t.value);
    final totalExpenses = transactions.where((t) => t.kind == model_transaction.TransactionKind.despesa && !t.isReversal).fold(0.0, (sum, t) => sum + t.value);
    final currentBalance = totalIncomes - totalExpenses;
    
    final categoryOptions = widget.isIncome
        ? plannedItems.where((i) => i.type == PlanItemType.entradaFixa || i.type == PlanItemType.entradaPrevista || i.type == PlanItemType.entradaVariavel).toList()
        : plannedItems.where((i) => i.type == PlanItemType.despesaObrigatoria || i.type == PlanItemType.despesaVariavelObrigatoria || i.type == PlanItemType.despesaPrevista).toList();

    if (widget.transactionToEdit != null && _selectedPlanItem == null && widget.transactionToEdit!.planItemId != null) {
      try {
        _selectedPlanItem = categoryOptions.firstWhere((i) => i.id == widget.transactionToEdit!.planItemId);
      } catch (e) {}
    }

    final accentColor = widget.isIncome ? AppTheme.success : AppTheme.error;
    double bottomBarClearance = 100.0;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: accentColor.withOpacity(0.3), width: 1),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + bottomBarClearance,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
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
                const SizedBox(height: 20),

                // Title
                Text(
                  widget.transactionToEdit == null
                      ? (widget.isIncome ? 'Nova Entrada' : 'Nova Despesa')
                      : 'Editar Transação',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Value
                NeonTextField(
                  controller: _valueController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  labelText: 'Valor (R\$)',
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Campo obrigatório';
                    if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Valor inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                
                // Painel de Contexto Reativo
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _valueController,
                  builder: (context, value, child) {
                    final inputValue = double.tryParse(value.text.replaceAll(',', '.')) ?? 0.0;
                    final projectedBalance = widget.isIncome 
                        ? currentBalance + inputValue 
                        : currentBalance - inputValue;
                        
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Saldo Atual:', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                              Text(Formatters.formatCurrency(currentBalance), style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Após ${widget.isIncome ? 'recebimento' : 'pagamento'}:', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                              Text(
                                Formatters.formatCurrency(projectedBalance), 
                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: projectedBalance >= 0 ? AppTheme.success : AppTheme.error)
                              ),
                            ],
                          ),
                          if (_selectedPlanItem != null && _selectedPlanItem!.type == PlanItemType.despesaVariavelObrigatoria) ...[
                            const SizedBox(height: 8),
                            Builder(
                              builder: (context) {
                                final plan = _selectedPlanItem!;
                                final realized = transactions
                                  .where((t) => t.planItemId == plan.id && !t.isReversal && t.date.month == _date.month && t.date.year == _date.year)
                                  .fold(0.0, (s,t) => s+t.value);
                                final remaining = (plan.value - realized - inputValue).clamp(0.0, double.infinity);
                                return Text(
                                  'Falta ${Formatters.formatCurrency(remaining)} para atingir o limite desta categoria.',
                                  style: GoogleFonts.inter(fontSize: 12, color: remaining > 0 ? AppTheme.textTertiary : AppTheme.error),
                                );
                              }
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Date
                GestureDetector(
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
                    decoration: const InputDecoration(
                      labelText: 'Data',
                      suffixIcon: Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.textTertiary),
                    ),
                    child: Text(
                      Formatters.formatDate(_date),
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Payment method
                DropdownButtonFormField<model_transaction.PaymentMethod>(
                  value: _paymentMethod,
                  decoration: const InputDecoration(labelText: 'Meio de Pagamento'),
                  dropdownColor: AppTheme.surface,
                  menuMaxHeight: 250,
                  borderRadius: BorderRadius.circular(16),
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

                // Category (Vínculo)
                DropdownButtonFormField<PlanItem?>(
                  value: _selectedPlanItem,
                  decoration: const InputDecoration(labelText: 'Categoria (Vínculo)'),
                  dropdownColor: AppTheme.surface,
                  menuMaxHeight: 250,
                  borderRadius: BorderRadius.circular(16),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(widget.isIncome ? 'Entrada Adicional (Não planejada)' : 'Despesa Adicional (Não planejada)'),
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
                  NeonTextField(
                    controller: _titleController,
                    labelText: widget.isIncome ? 'Título da Entrada' : 'Título da Despesa',
                    validator: (v) => v == null || v.trim().isEmpty ? 'Título é obrigatório' : null,
                  ),
                const SizedBox(height: 28),

                // Save button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: accentColor,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.3),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: widget.isIncome ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                        ref.read(transactionsProvider.notifier).addTransaction(t);
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'Salvar Transação',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
