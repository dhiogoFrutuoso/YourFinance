import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_item.freezed.dart';
part 'plan_item.g.dart';

enum PlanItemType { 
  entradaFixa, 
  entradaPrevista, 
  entradaVariavel,
  despesaObrigatoria, 
  despesaPrevista,
  despesaVariavelObrigatoria
}

@freezed
abstract class PlanItem with _$PlanItem {
  const PlanItem._();
  const factory PlanItem({
    required String id,
    required PlanItemType type,
    required String name,
    String? description,
    required double value,
    DateTime? dueDate,
    required String monthRef, // format: YYYY-MM
    required DateTime createdAt,
    bool? isInstallment,
    int? totalInstallments,
    DateTime? expirationDate,
    bool? isReceivedEarly,
    String? customCategoryId,
  }) = _PlanItem;

  factory PlanItem.fromJson(Map<String, dynamic> json) => _$PlanItemFromJson(json);
}
