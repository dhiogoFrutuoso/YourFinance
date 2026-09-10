// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlanItem _$PlanItemFromJson(Map<String, dynamic> json) => _PlanItem(
  id: json['id'] as String,
  type: $enumDecode(_$PlanItemTypeEnumMap, json['type']),
  name: json['name'] as String,
  description: json['description'] as String?,
  value: (json['value'] as num).toDouble(),
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  monthRef: json['monthRef'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  isInstallment: json['isInstallment'] as bool?,
  totalInstallments: (json['totalInstallments'] as num?)?.toInt(),
  expirationDate: json['expirationDate'] == null
      ? null
      : DateTime.parse(json['expirationDate'] as String),
  isReceivedEarly: json['isReceivedEarly'] as bool?,
  customCategoryId: json['customCategoryId'] as String?,
);

Map<String, dynamic> _$PlanItemToJson(_PlanItem instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$PlanItemTypeEnumMap[instance.type]!,
  'name': instance.name,
  'description': instance.description,
  'value': instance.value,
  'dueDate': instance.dueDate?.toIso8601String(),
  'monthRef': instance.monthRef,
  'createdAt': instance.createdAt.toIso8601String(),
  'isInstallment': instance.isInstallment,
  'totalInstallments': instance.totalInstallments,
  'expirationDate': instance.expirationDate?.toIso8601String(),
  'isReceivedEarly': instance.isReceivedEarly,
  'customCategoryId': instance.customCategoryId,
};

const _$PlanItemTypeEnumMap = {
  PlanItemType.entradaFixa: 'entradaFixa',
  PlanItemType.entradaPrevista: 'entradaPrevista',
  PlanItemType.entradaVariavel: 'entradaVariavel',
  PlanItemType.despesaObrigatoria: 'despesaObrigatoria',
  PlanItemType.despesaPrevista: 'despesaPrevista',
  PlanItemType.despesaVariavelObrigatoria: 'despesaVariavelObrigatoria',
};
