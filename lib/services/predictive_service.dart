import '../models/transaction.dart' as model_transaction;
import '../models/plan_item.dart';

class PredictiveService {
  static double calculateProjectedBalance({
    required DateTime targetDate,
    required DateTime currentDate,
    required double currentBalance,
    required List<model_transaction.Transaction> currentMonthTransactions,
    required List<PlanItem> plannedItems,
    required int daysInMonth,
  }) {
    double projectedBalance = currentBalance;
    final targetDay = targetDate.day;

    for (var plan in plannedItems) {
      // Quanto já foi realizado (pago/recebido) deste plano neste mês
      final realizedAmount = currentMonthTransactions
          .where((t) => t.planItemId == plan.id && !t.isReversal)
          .fold(0.0, (sum, t) => sum + t.value);

      // Regra de Ouro: Qualquer item que JÁ FOI PAGO OU RECEBIDO deve ser completamente ignorado
      final isPaid = realizedAmount >= plan.value;
      if (isPaid) continue;

      final dueDate = plan.dueDate ?? plan.expirationDate ?? DateTime(targetDate.year, targetDate.month, targetDate.day);

      // Só consideramos itens cujo dia de vencimento/recebimento seja ATÉ o dia selecionado
      if (dueDate.day <= targetDay) {
        final isIncome = plan.type == PlanItemType.entradaFixa || 
                         plan.type == PlanItemType.entradaPrevista || 
                         plan.type == PlanItemType.entradaVariavel;

        final pendingValue = plan.value - realizedAmount;

        if (isIncome) {
          projectedBalance += pendingValue; // O que SOMA
        } else {
          projectedBalance -= pendingValue; // O que SUBTRAI
        }
      }
    }

    return projectedBalance;
  }
}
