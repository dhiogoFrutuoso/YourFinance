import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plan_item.dart';
import '../services/hive_service.dart';



// Actually, let's just make it a Notifier
class SelectedMonthNotifier extends Notifier<String> {
  @override
  String build() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  void update(String newMonth) {
    state = newMonth;
  }
}
final selectedMonthProvider = NotifierProvider<SelectedMonthNotifier, String>(SelectedMonthNotifier.new);

class PlanningNotifier extends Notifier<List<PlanItem>> {
  @override
  List<PlanItem> build() {
    final monthRef = ref.watch(selectedMonthProvider);
    return HiveService.getPlanItemsByMonth(monthRef);
  }

  void _loadItems() {
    final monthRef = ref.watch(selectedMonthProvider);
    state = HiveService.getPlanItemsByMonth(monthRef);
  }

  Future<void> addPlanItem(PlanItem item) async {
    await HiveService.savePlanItem(item);
    _loadItems();
  }

  Future<void> removePlanItem(String id) async {
    await HiveService.deletePlanItem(id);
    _loadItems();
  }

  Future<void> duplicatePreviousMonthItems() async {
    final monthRef = ref.watch(selectedMonthProvider);
    final year = int.parse(monthRef.split('-')[0]);
    final month = int.parse(monthRef.split('-')[1]);
    
    var prevMonth = month - 1;
    var prevYear = year;
    if (prevMonth == 0) {
      prevMonth = 12;
      prevYear = year - 1;
    }
    final prevMonthRef = '$prevYear-${prevMonth.toString().padLeft(2, '0')}';
    
    final prevItems = HiveService.getPlanItemsByMonth(prevMonthRef)
        .where((item) => item.type == PlanItemType.entradaFixa || item.type == PlanItemType.despesaObrigatoria)
        .toList();
        
    for (final item in prevItems) {
      final newItem = item.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString() + item.id.substring(0, 4),
        monthRef: monthRef,
        createdAt: DateTime.now(),
      );
      await HiveService.savePlanItem(newItem);
    }
    _loadItems();
  }
}

final planningProvider = NotifierProvider<PlanningNotifier, List<PlanItem>>(PlanningNotifier.new);
