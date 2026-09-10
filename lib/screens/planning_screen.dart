import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../providers/planning_provider.dart';
import '../models/plan_item.dart';
import '../utils/formatters.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/neon_text_field.dart';
import '../widgets/animated_toggle.dart';

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
      if (item.type == PlanItemType.entradaFixa || 
          item.type == PlanItemType.entradaPrevista || 
          item.type == PlanItemType.entradaVariavel) {
        totalIncomes += item.value;
      } else {
        totalExpenses += item.value;
      }
    }
    
    final balance = totalIncomes - totalExpenses;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── SliverAppBar with Hero Card ───
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.background,
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.copy_rounded, size: 18),
                ),
                tooltip: 'Duplicar do mês anterior',
                onPressed: () async {
                  await ref.read(planningProvider.notifier).duplicatePreviousMonthItems();
                  HapticFeedback.mediumImpact();
                  if (mounted) {
                    SnackBarUtils.showSuccess(context, 'Itens do mês anterior duplicados!');
                  }
                },
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1A0A2E),
                      AppTheme.background,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                    child: _HeroCard(
                      incomes: totalIncomes,
                      expenses: totalExpenses,
                      balance: balance,
                    ),
                  ),
                ),
              ),
              collapseMode: CollapseMode.pin,
            ),
            title: Text(
              'Planejamento',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18),
            ),
          ),

          // ─── Items List ───
          if (items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.playlist_add_rounded, size: 56, color: AppTheme.textTertiary.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum item planejado\npara este mês.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(color: AppTheme.textTertiary, fontSize: 15, height: 1.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toque em + para adicionar.',
                        style: GoogleFonts.inter(color: AppTheme.textDisabled, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = items[index];
                    return _PlanItemCard(
                      item: item,
                      monthRef: monthRef,
                      onEdit: () => _showAddItemModal(context, monthRef, item: item),
                      onDelete: () => _confirmDelete(context, item.id, item.name),
                    );
                  },
                  childCount: items.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: AppTheme.glowShadow(blurRadius: 20, opacity: 0.4),
          ),
          child: FloatingActionButton(
            onPressed: () => _showAddItemModal(context, monthRef),
            backgroundColor: AppTheme.primary,
            child: const Icon(Icons.add_rounded, size: 28),
          ),
        ),
      ),
    );
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
      backgroundColor: Colors.transparent,
      builder: (context) => _AddItemSheet(monthRef: monthRef, itemToEdit: item),
    );
  }
}

// ─── Hero Card ────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final double incomes;
  final double expenses;
  final double balance;

  const _HeroCard({
    required this.incomes,
    required this.expenses,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: AppTheme.primary.withOpacity(0.25),
      boxShadow: AppTheme.glowShadow(blurRadius: 20, opacity: 0.15),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Saldo Projetado',
            style: GoogleFonts.inter(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.formatCurrency(balance),
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: balance >= 0 ? AppTheme.success : AppTheme.error,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Receitas',
                    value: Formatters.formatCurrency(incomes),
                    color: AppTheme.success,
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
                Container(
                  width: 1,
                  height: double.infinity,
                  color: Colors.white.withOpacity(0.08),
                ),
              Expanded(
                child: _MiniStat(
                  label: 'Despesas',
                  value: Formatters.formatCurrency(expenses),
                  color: AppTheme.error,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
            ],
          ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppTheme.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Plan Item Card ───────────────────────────────────────────────

class _PlanItemCard extends StatelessWidget {
  final PlanItem item;
  final String monthRef;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PlanItemCard({
    required this.item,
    required this.monthRef,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = item.type == PlanItemType.entradaFixa || 
                     item.type == PlanItemType.entradaPrevista || 
                     item.type == PlanItemType.entradaVariavel;
    final color = isIncome ? AppTheme.success : AppTheme.error;

    String installmentText = '';
    if (item.isInstallment == true) {
      final currentMonthParts = monthRef.split('-');
      final currentMonthDate = DateTime(int.parse(currentMonthParts[0]), int.parse(currentMonthParts[1]));
      final startMonthParts = item.monthRef.split('-');
      final startMonthDate = DateTime(int.parse(startMonthParts[0]), int.parse(startMonthParts[1]));
      final diffMonths = (currentMonthDate.year - startMonthDate.year) * 12 + currentMonthDate.month - startMonthDate.month;
      installmentText = ' (${diffMonths + 1}/${item.totalInstallments})';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        children: [
          GlassCard(
            onTap: onEdit,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Type icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.12),
                  ),
                  child: Icon(_getIconForType(item.type), color: color, size: 20),
                ),
                const SizedBox(width: 12),
                // Name + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.name}$installmentText',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.expirationDate != null
                          ? '${isIncome ? 'Recebe em' : 'Vence em'}: ${Formatters.formatDate(item.expirationDate!)}'
                          : (item.description?.isNotEmpty == true ? item.description! : _getTypeName(item.type)),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Value
                Text(
                  Formatters.formatCurrency(item.value),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                // Delete button
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.textTertiary),
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
          // Expiration badge
          if (item.expirationDate != null)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(AppTheme.cardRadius),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Text(
                  '${isIncome ? 'Recebimento' : 'Vencimento'}: ${item.expirationDate!.day.toString().padLeft(2, '0')}/${item.expirationDate!.month.toString().padLeft(2, '0')}',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconForType(PlanItemType type) {
    switch (type) {
      case PlanItemType.entradaFixa:
        return Icons.account_balance_wallet_rounded;
      case PlanItemType.entradaPrevista:
        return Icons.trending_up_rounded;
      case PlanItemType.entradaVariavel:
        return Icons.rocket_launch_rounded;
      case PlanItemType.despesaObrigatoria:
        return Icons.receipt_long_rounded;
      case PlanItemType.despesaVariavelObrigatoria:
        return Icons.shopping_basket_rounded;
      case PlanItemType.despesaPrevista:
        return Icons.shopping_cart_rounded;
    }
  }

  String _getTypeName(PlanItemType type) {
    switch (type) {
      case PlanItemType.entradaFixa:
        return 'Entrada Fixa';
      case PlanItemType.entradaPrevista:
        return 'Entrada Prevista';
      case PlanItemType.entradaVariavel:
        return 'Entrada Variável';
      case PlanItemType.despesaObrigatoria:
        return 'Despesa Obrigatória';
      case PlanItemType.despesaVariavelObrigatoria:
        return 'Despesa Variável Obrigatória';
      case PlanItemType.despesaPrevista:
        return 'Despesa Prevista';
    }
  }
}

// ─── Add Item Bottom Sheet ────────────────────────────────────────

class _AddItemSheet extends ConsumerStatefulWidget {
  final String monthRef;
  final PlanItem? itemToEdit;
  
  const _AddItemSheet({required this.monthRef, this.itemToEdit});

  @override
  ConsumerState<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<_AddItemSheet> {
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
    double bottomBarClearance = 100.0;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppTheme.primary.withOpacity(0.3), width: 1),
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
                  widget.itemToEdit == null ? 'Novo Item' : 'Editar Item',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Type dropdown
                DropdownButtonFormField<PlanItemType>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Tipo de Item'),
                  dropdownColor: AppTheme.surface,
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

                // Name field
                NeonTextField(
                  controller: _nameController,
                  labelText: 'Nome (ex: Aluguel)',
                  validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),

                // Value field
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
                const SizedBox(height: 20),

                // Installment toggle
                AnimatedToggle(
                  value: _isInstallment,
                  label: 'É parcelado?',
                  onChanged: (val) => setState(() => _isInstallment = val),
                  expandedChild: NeonTextField(
                    controller: _installmentsController,
                    keyboardType: TextInputType.number,
                    labelText: 'Total de Parcelas',
                    validator: (v) {
                      if (_isInstallment && (v == null || int.tryParse(v) == null)) {
                        return 'Insira um número válido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Expiration date
                GestureDetector(
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
                      labelText: (_type == PlanItemType.entradaFixa || 
                                  _type == PlanItemType.entradaPrevista || 
                                  _type == PlanItemType.entradaVariavel) 
                                 ? 'Data de Recebimento (Opcional)' 
                                 : 'Data de Vencimento/Validade (Opcional)',
                      suffixIcon: _expirationDate != null 
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppTheme.textTertiary),
                            onPressed: () => setState(() => _expirationDate = null),
                          ) 
                        : const Icon(Icons.calendar_today_rounded, color: AppTheme.textTertiary, size: 18),
                    ),
                    child: Text(
                      _expirationDate != null ? Formatters.formatDate(_expirationDate!) : 'Nenhuma (Sempre válido)',
                      style: TextStyle(color: _expirationDate != null ? AppTheme.textPrimary : AppTheme.textTertiary),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Save button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: AppTheme.primaryGradient,
                    boxShadow: AppTheme.glowShadow(blurRadius: 16, opacity: 0.3),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
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
                    child: Text(
                      'Salvar',
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

  String _getTypeName(PlanItemType type) {
    switch (type) {
      case PlanItemType.entradaFixa:
        return 'Entrada Fixa';
      case PlanItemType.entradaPrevista:
        return 'Entrada Prevista';
      case PlanItemType.entradaVariavel:
        return 'Entrada Variável';
      case PlanItemType.despesaObrigatoria:
        return 'Despesa Obrigatória';
      case PlanItemType.despesaVariavelObrigatoria:
        return 'Despesa Variável Obrigatória';
      case PlanItemType.despesaPrevista:
        return 'Despesa Adicional Prevista';
    }
  }
}
