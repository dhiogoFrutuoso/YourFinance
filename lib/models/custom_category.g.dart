// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CustomCategory _$CustomCategoryFromJson(Map<String, dynamic> json) =>
    _CustomCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      iconHex: json['iconHex'] as String,
      colorHex: json['colorHex'] as String,
      isVariableBucket: json['isVariableBucket'] as bool,
      bucketLimit: (json['bucketLimit'] as num).toDouble(),
    );

Map<String, dynamic> _$CustomCategoryToJson(_CustomCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'iconHex': instance.iconHex,
      'colorHex': instance.colorHex,
      'isVariableBucket': instance.isVariableBucket,
      'bucketLimit': instance.bucketLimit,
    };
