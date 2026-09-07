// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Transaction {

 String get id; TransactionKind get kind; double get value; DateTime get date; PaymentMethod get paymentMethod; String? get planItemId; String? get categorySnapshotName; String? get title; bool get isReversal; String? get reversalOfId; DateTime get createdAt;
/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionCopyWith<Transaction> get copyWith => _$TransactionCopyWithImpl<Transaction>(this as Transaction, _$identity);

  /// Serializes this Transaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transaction&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.value, value) || other.value == value)&&(identical(other.date, date) || other.date == date)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.planItemId, planItemId) || other.planItemId == planItemId)&&(identical(other.categorySnapshotName, categorySnapshotName) || other.categorySnapshotName == categorySnapshotName)&&(identical(other.title, title) || other.title == title)&&(identical(other.isReversal, isReversal) || other.isReversal == isReversal)&&(identical(other.reversalOfId, reversalOfId) || other.reversalOfId == reversalOfId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,kind,value,date,paymentMethod,planItemId,categorySnapshotName,title,isReversal,reversalOfId,createdAt);

@override
String toString() {
  return 'Transaction(id: $id, kind: $kind, value: $value, date: $date, paymentMethod: $paymentMethod, planItemId: $planItemId, categorySnapshotName: $categorySnapshotName, title: $title, isReversal: $isReversal, reversalOfId: $reversalOfId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TransactionCopyWith<$Res>  {
  factory $TransactionCopyWith(Transaction value, $Res Function(Transaction) _then) = _$TransactionCopyWithImpl;
@useResult
$Res call({
 String id, TransactionKind kind, double value, DateTime date, PaymentMethod paymentMethod, String? planItemId, String? categorySnapshotName, String? title, bool isReversal, String? reversalOfId, DateTime createdAt
});




}
/// @nodoc
class _$TransactionCopyWithImpl<$Res>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._self, this._then);

  final Transaction _self;
  final $Res Function(Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? value = null,Object? date = null,Object? paymentMethod = null,Object? planItemId = freezed,Object? categorySnapshotName = freezed,Object? title = freezed,Object? isReversal = null,Object? reversalOfId = freezed,Object? createdAt = null,}) {
  return _then(Transaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as TransactionKind,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,planItemId: freezed == planItemId ? _self.planItemId : planItemId // ignore: cast_nullable_to_non_nullable
as String?,categorySnapshotName: freezed == categorySnapshotName ? _self.categorySnapshotName : categorySnapshotName // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,isReversal: null == isReversal ? _self.isReversal : isReversal // ignore: cast_nullable_to_non_nullable
as bool,reversalOfId: freezed == reversalOfId ? _self.reversalOfId : reversalOfId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Transaction].
extension TransactionPatterns on Transaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Transaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Transaction value)  $default,){
final _that = this;
switch (_that) {
case _Transaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Transaction value)?  $default,){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  TransactionKind kind,  double value,  DateTime date,  PaymentMethod paymentMethod,  String? planItemId,  String? categorySnapshotName,  String? title,  bool isReversal,  String? reversalOfId,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.kind,_that.value,_that.date,_that.paymentMethod,_that.planItemId,_that.categorySnapshotName,_that.title,_that.isReversal,_that.reversalOfId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  TransactionKind kind,  double value,  DateTime date,  PaymentMethod paymentMethod,  String? planItemId,  String? categorySnapshotName,  String? title,  bool isReversal,  String? reversalOfId,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Transaction():
return $default(_that.id,_that.kind,_that.value,_that.date,_that.paymentMethod,_that.planItemId,_that.categorySnapshotName,_that.title,_that.isReversal,_that.reversalOfId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  TransactionKind kind,  double value,  DateTime date,  PaymentMethod paymentMethod,  String? planItemId,  String? categorySnapshotName,  String? title,  bool isReversal,  String? reversalOfId,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.kind,_that.value,_that.date,_that.paymentMethod,_that.planItemId,_that.categorySnapshotName,_that.title,_that.isReversal,_that.reversalOfId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Transaction extends Transaction {
  const _Transaction({required this.id, required this.kind, required this.value, required this.date, required this.paymentMethod, this.planItemId, this.categorySnapshotName, this.title, this.isReversal = false, this.reversalOfId, required this.createdAt}): super._();
  factory _Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);

@override final  String id;
@override final  TransactionKind kind;
@override final  double value;
@override final  DateTime date;
@override final  PaymentMethod paymentMethod;
@override final  String? planItemId;
@override final  String? categorySnapshotName;
@override final  String? title;
@override@JsonKey() final  bool isReversal;
@override final  String? reversalOfId;
@override final  DateTime createdAt;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionCopyWith<_Transaction> get copyWith => __$TransactionCopyWithImpl<_Transaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Transaction&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.value, value) || other.value == value)&&(identical(other.date, date) || other.date == date)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.planItemId, planItemId) || other.planItemId == planItemId)&&(identical(other.categorySnapshotName, categorySnapshotName) || other.categorySnapshotName == categorySnapshotName)&&(identical(other.title, title) || other.title == title)&&(identical(other.isReversal, isReversal) || other.isReversal == isReversal)&&(identical(other.reversalOfId, reversalOfId) || other.reversalOfId == reversalOfId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,kind,value,date,paymentMethod,planItemId,categorySnapshotName,title,isReversal,reversalOfId,createdAt);

@override
String toString() {
  return 'Transaction(id: $id, kind: $kind, value: $value, date: $date, paymentMethod: $paymentMethod, planItemId: $planItemId, categorySnapshotName: $categorySnapshotName, title: $title, isReversal: $isReversal, reversalOfId: $reversalOfId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TransactionCopyWith<$Res> implements $TransactionCopyWith<$Res> {
  factory _$TransactionCopyWith(_Transaction value, $Res Function(_Transaction) _then) = __$TransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, TransactionKind kind, double value, DateTime date, PaymentMethod paymentMethod, String? planItemId, String? categorySnapshotName, String? title, bool isReversal, String? reversalOfId, DateTime createdAt
});




}
/// @nodoc
class __$TransactionCopyWithImpl<$Res>
    implements _$TransactionCopyWith<$Res> {
  __$TransactionCopyWithImpl(this._self, this._then);

  final _Transaction _self;
  final $Res Function(_Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? value = null,Object? date = null,Object? paymentMethod = null,Object? planItemId = freezed,Object? categorySnapshotName = freezed,Object? title = freezed,Object? isReversal = null,Object? reversalOfId = freezed,Object? createdAt = null,}) {
  return _then(_Transaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as TransactionKind,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,planItemId: freezed == planItemId ? _self.planItemId : planItemId // ignore: cast_nullable_to_non_nullable
as String?,categorySnapshotName: freezed == categorySnapshotName ? _self.categorySnapshotName : categorySnapshotName // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,isReversal: null == isReversal ? _self.isReversal : isReversal // ignore: cast_nullable_to_non_nullable
as bool,reversalOfId: freezed == reversalOfId ? _self.reversalOfId : reversalOfId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
