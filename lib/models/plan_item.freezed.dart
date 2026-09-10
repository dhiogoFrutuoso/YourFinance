// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plan_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlanItem {

 String get id; PlanItemType get type; String get name; String? get description; double get value; DateTime? get dueDate; String get monthRef; DateTime get createdAt; bool? get isInstallment; int? get totalInstallments; DateTime? get expirationDate; bool? get isReceivedEarly; String? get customCategoryId;
/// Create a copy of PlanItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanItemCopyWith<PlanItem> get copyWith => _$PlanItemCopyWithImpl<PlanItem>(this as PlanItem, _$identity);

  /// Serializes this PlanItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanItem&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.value, value) || other.value == value)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.monthRef, monthRef) || other.monthRef == monthRef)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isInstallment, isInstallment) || other.isInstallment == isInstallment)&&(identical(other.totalInstallments, totalInstallments) || other.totalInstallments == totalInstallments)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate)&&(identical(other.isReceivedEarly, isReceivedEarly) || other.isReceivedEarly == isReceivedEarly)&&(identical(other.customCategoryId, customCategoryId) || other.customCategoryId == customCategoryId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,description,value,dueDate,monthRef,createdAt,isInstallment,totalInstallments,expirationDate,isReceivedEarly,customCategoryId);

@override
String toString() {
  return 'PlanItem(id: $id, type: $type, name: $name, description: $description, value: $value, dueDate: $dueDate, monthRef: $monthRef, createdAt: $createdAt, isInstallment: $isInstallment, totalInstallments: $totalInstallments, expirationDate: $expirationDate, isReceivedEarly: $isReceivedEarly, customCategoryId: $customCategoryId)';
}


}

/// @nodoc
abstract mixin class $PlanItemCopyWith<$Res>  {
  factory $PlanItemCopyWith(PlanItem value, $Res Function(PlanItem) _then) = _$PlanItemCopyWithImpl;
@useResult
$Res call({
 String id, PlanItemType type, String name, String? description, double value, DateTime? dueDate, String monthRef, DateTime createdAt, bool? isInstallment, int? totalInstallments, DateTime? expirationDate, bool? isReceivedEarly, String? customCategoryId
});




}
/// @nodoc
class _$PlanItemCopyWithImpl<$Res>
    implements $PlanItemCopyWith<$Res> {
  _$PlanItemCopyWithImpl(this._self, this._then);

  final PlanItem _self;
  final $Res Function(PlanItem) _then;

/// Create a copy of PlanItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? name = null,Object? description = freezed,Object? value = null,Object? dueDate = freezed,Object? monthRef = null,Object? createdAt = null,Object? isInstallment = freezed,Object? totalInstallments = freezed,Object? expirationDate = freezed,Object? isReceivedEarly = freezed,Object? customCategoryId = freezed,}) {
  return _then(PlanItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PlanItemType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,monthRef: null == monthRef ? _self.monthRef : monthRef // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isInstallment: freezed == isInstallment ? _self.isInstallment : isInstallment // ignore: cast_nullable_to_non_nullable
as bool?,totalInstallments: freezed == totalInstallments ? _self.totalInstallments : totalInstallments // ignore: cast_nullable_to_non_nullable
as int?,expirationDate: freezed == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isReceivedEarly: freezed == isReceivedEarly ? _self.isReceivedEarly : isReceivedEarly // ignore: cast_nullable_to_non_nullable
as bool?,customCategoryId: freezed == customCategoryId ? _self.customCategoryId : customCategoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlanItem].
extension PlanItemPatterns on PlanItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlanItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlanItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlanItem value)  $default,){
final _that = this;
switch (_that) {
case _PlanItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlanItem value)?  $default,){
final _that = this;
switch (_that) {
case _PlanItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  PlanItemType type,  String name,  String? description,  double value,  DateTime? dueDate,  String monthRef,  DateTime createdAt,  bool? isInstallment,  int? totalInstallments,  DateTime? expirationDate,  bool? isReceivedEarly,  String? customCategoryId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlanItem() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.description,_that.value,_that.dueDate,_that.monthRef,_that.createdAt,_that.isInstallment,_that.totalInstallments,_that.expirationDate,_that.isReceivedEarly,_that.customCategoryId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  PlanItemType type,  String name,  String? description,  double value,  DateTime? dueDate,  String monthRef,  DateTime createdAt,  bool? isInstallment,  int? totalInstallments,  DateTime? expirationDate,  bool? isReceivedEarly,  String? customCategoryId)  $default,) {final _that = this;
switch (_that) {
case _PlanItem():
return $default(_that.id,_that.type,_that.name,_that.description,_that.value,_that.dueDate,_that.monthRef,_that.createdAt,_that.isInstallment,_that.totalInstallments,_that.expirationDate,_that.isReceivedEarly,_that.customCategoryId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  PlanItemType type,  String name,  String? description,  double value,  DateTime? dueDate,  String monthRef,  DateTime createdAt,  bool? isInstallment,  int? totalInstallments,  DateTime? expirationDate,  bool? isReceivedEarly,  String? customCategoryId)?  $default,) {final _that = this;
switch (_that) {
case _PlanItem() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.description,_that.value,_that.dueDate,_that.monthRef,_that.createdAt,_that.isInstallment,_that.totalInstallments,_that.expirationDate,_that.isReceivedEarly,_that.customCategoryId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlanItem extends PlanItem {
  const _PlanItem({required this.id, required this.type, required this.name, this.description, required this.value, this.dueDate, required this.monthRef, required this.createdAt, this.isInstallment, this.totalInstallments, this.expirationDate, this.isReceivedEarly, this.customCategoryId}): super._();
  factory _PlanItem.fromJson(Map<String, dynamic> json) => _$PlanItemFromJson(json);

@override final  String id;
@override final  PlanItemType type;
@override final  String name;
@override final  String? description;
@override final  double value;
@override final  DateTime? dueDate;
@override final  String monthRef;
@override final  DateTime createdAt;
@override final  bool? isInstallment;
@override final  int? totalInstallments;
@override final  DateTime? expirationDate;
@override final  bool? isReceivedEarly;
@override final  String? customCategoryId;

/// Create a copy of PlanItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanItemCopyWith<_PlanItem> get copyWith => __$PlanItemCopyWithImpl<_PlanItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlanItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanItem&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.value, value) || other.value == value)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.monthRef, monthRef) || other.monthRef == monthRef)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isInstallment, isInstallment) || other.isInstallment == isInstallment)&&(identical(other.totalInstallments, totalInstallments) || other.totalInstallments == totalInstallments)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate)&&(identical(other.isReceivedEarly, isReceivedEarly) || other.isReceivedEarly == isReceivedEarly)&&(identical(other.customCategoryId, customCategoryId) || other.customCategoryId == customCategoryId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,description,value,dueDate,monthRef,createdAt,isInstallment,totalInstallments,expirationDate,isReceivedEarly,customCategoryId);

@override
String toString() {
  return 'PlanItem(id: $id, type: $type, name: $name, description: $description, value: $value, dueDate: $dueDate, monthRef: $monthRef, createdAt: $createdAt, isInstallment: $isInstallment, totalInstallments: $totalInstallments, expirationDate: $expirationDate, isReceivedEarly: $isReceivedEarly, customCategoryId: $customCategoryId)';
}


}

/// @nodoc
abstract mixin class _$PlanItemCopyWith<$Res> implements $PlanItemCopyWith<$Res> {
  factory _$PlanItemCopyWith(_PlanItem value, $Res Function(_PlanItem) _then) = __$PlanItemCopyWithImpl;
@override @useResult
$Res call({
 String id, PlanItemType type, String name, String? description, double value, DateTime? dueDate, String monthRef, DateTime createdAt, bool? isInstallment, int? totalInstallments, DateTime? expirationDate, bool? isReceivedEarly, String? customCategoryId
});




}
/// @nodoc
class __$PlanItemCopyWithImpl<$Res>
    implements _$PlanItemCopyWith<$Res> {
  __$PlanItemCopyWithImpl(this._self, this._then);

  final _PlanItem _self;
  final $Res Function(_PlanItem) _then;

/// Create a copy of PlanItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? name = null,Object? description = freezed,Object? value = null,Object? dueDate = freezed,Object? monthRef = null,Object? createdAt = null,Object? isInstallment = freezed,Object? totalInstallments = freezed,Object? expirationDate = freezed,Object? isReceivedEarly = freezed,Object? customCategoryId = freezed,}) {
  return _then(_PlanItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PlanItemType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,monthRef: null == monthRef ? _self.monthRef : monthRef // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isInstallment: freezed == isInstallment ? _self.isInstallment : isInstallment // ignore: cast_nullable_to_non_nullable
as bool?,totalInstallments: freezed == totalInstallments ? _self.totalInstallments : totalInstallments // ignore: cast_nullable_to_non_nullable
as int?,expirationDate: freezed == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isReceivedEarly: freezed == isReceivedEarly ? _self.isReceivedEarly : isReceivedEarly // ignore: cast_nullable_to_non_nullable
as bool?,customCategoryId: freezed == customCategoryId ? _self.customCategoryId : customCategoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
