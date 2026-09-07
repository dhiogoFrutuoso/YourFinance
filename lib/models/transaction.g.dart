// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Transaction _$TransactionFromJson(Map<String, dynamic> json) => _Transaction(
  id: json['id'] as String,
  kind: $enumDecode(_$TransactionKindEnumMap, json['kind']),
  value: (json['value'] as num).toDouble(),
  date: DateTime.parse(json['date'] as String),
  paymentMethod: $enumDecode(_$PaymentMethodEnumMap, json['paymentMethod']),
  planItemId: json['planItemId'] as String?,
  categorySnapshotName: json['categorySnapshotName'] as String?,
  title: json['title'] as String?,
  isReversal: json['isReversal'] as bool? ?? false,
  reversalOfId: json['reversalOfId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$TransactionToJson(_Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': _$TransactionKindEnumMap[instance.kind]!,
      'value': instance.value,
      'date': instance.date.toIso8601String(),
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'planItemId': instance.planItemId,
      'categorySnapshotName': instance.categorySnapshotName,
      'title': instance.title,
      'isReversal': instance.isReversal,
      'reversalOfId': instance.reversalOfId,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$TransactionKindEnumMap = {
  TransactionKind.entrada: 'entrada',
  TransactionKind.despesa: 'despesa',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.dinheiro: 'dinheiro',
  PaymentMethod.pix: 'pix',
  PaymentMethod.cartaoCredito: 'cartaoCredito',
};
