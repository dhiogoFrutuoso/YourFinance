import 'package:freezed_annotation/freezed_annotation.dart';

part 'custom_category.freezed.dart';
part 'custom_category.g.dart';

@freezed
abstract class CustomCategory with _$CustomCategory {
  const CustomCategory._();
  const factory CustomCategory({
    required String id,
    required String name,
    required String iconHex,
    required String colorHex,
    required bool isVariableBucket, // Define se é um "Balde" (Despesa Variável)
    required double bucketLimit,    // O teto (Ex: 500 para Feira)
  }) = _CustomCategory;

  factory CustomCategory.fromJson(Map<String, dynamic> json) => _$CustomCategoryFromJson(json);
}
