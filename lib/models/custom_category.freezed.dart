// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'custom_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CustomCategory {

 String get id; String get name; String get iconHex; String get colorHex; bool get isVariableBucket; double get bucketLimit;
/// Create a copy of CustomCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomCategoryCopyWith<CustomCategory> get copyWith => _$CustomCategoryCopyWithImpl<CustomCategory>(this as CustomCategory, _$identity);

  /// Serializes this CustomCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconHex, iconHex) || other.iconHex == iconHex)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&(identical(other.isVariableBucket, isVariableBucket) || other.isVariableBucket == isVariableBucket)&&(identical(other.bucketLimit, bucketLimit) || other.bucketLimit == bucketLimit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,iconHex,colorHex,isVariableBucket,bucketLimit);

@override
String toString() {
  return 'CustomCategory(id: $id, name: $name, iconHex: $iconHex, colorHex: $colorHex, isVariableBucket: $isVariableBucket, bucketLimit: $bucketLimit)';
}


}

/// @nodoc
abstract mixin class $CustomCategoryCopyWith<$Res>  {
  factory $CustomCategoryCopyWith(CustomCategory value, $Res Function(CustomCategory) _then) = _$CustomCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String name, String iconHex, String colorHex, bool isVariableBucket, double bucketLimit
});




}
/// @nodoc
class _$CustomCategoryCopyWithImpl<$Res>
    implements $CustomCategoryCopyWith<$Res> {
  _$CustomCategoryCopyWithImpl(this._self, this._then);

  final CustomCategory _self;
  final $Res Function(CustomCategory) _then;

/// Create a copy of CustomCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? iconHex = null,Object? colorHex = null,Object? isVariableBucket = null,Object? bucketLimit = null,}) {
  return _then(CustomCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconHex: null == iconHex ? _self.iconHex : iconHex // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,isVariableBucket: null == isVariableBucket ? _self.isVariableBucket : isVariableBucket // ignore: cast_nullable_to_non_nullable
as bool,bucketLimit: null == bucketLimit ? _self.bucketLimit : bucketLimit // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomCategory].
extension CustomCategoryPatterns on CustomCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomCategory value)  $default,){
final _that = this;
switch (_that) {
case _CustomCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomCategory value)?  $default,){
final _that = this;
switch (_that) {
case _CustomCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String iconHex,  String colorHex,  bool isVariableBucket,  double bucketLimit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomCategory() when $default != null:
return $default(_that.id,_that.name,_that.iconHex,_that.colorHex,_that.isVariableBucket,_that.bucketLimit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String iconHex,  String colorHex,  bool isVariableBucket,  double bucketLimit)  $default,) {final _that = this;
switch (_that) {
case _CustomCategory():
return $default(_that.id,_that.name,_that.iconHex,_that.colorHex,_that.isVariableBucket,_that.bucketLimit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String iconHex,  String colorHex,  bool isVariableBucket,  double bucketLimit)?  $default,) {final _that = this;
switch (_that) {
case _CustomCategory() when $default != null:
return $default(_that.id,_that.name,_that.iconHex,_that.colorHex,_that.isVariableBucket,_that.bucketLimit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomCategory extends CustomCategory {
  const _CustomCategory({required this.id, required this.name, required this.iconHex, required this.colorHex, required this.isVariableBucket, required this.bucketLimit}): super._();
  factory _CustomCategory.fromJson(Map<String, dynamic> json) => _$CustomCategoryFromJson(json);

@override final  String id;
@override final  String name;
@override final  String iconHex;
@override final  String colorHex;
@override final  bool isVariableBucket;
@override final  double bucketLimit;

/// Create a copy of CustomCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomCategoryCopyWith<_CustomCategory> get copyWith => __$CustomCategoryCopyWithImpl<_CustomCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconHex, iconHex) || other.iconHex == iconHex)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&(identical(other.isVariableBucket, isVariableBucket) || other.isVariableBucket == isVariableBucket)&&(identical(other.bucketLimit, bucketLimit) || other.bucketLimit == bucketLimit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,iconHex,colorHex,isVariableBucket,bucketLimit);

@override
String toString() {
  return 'CustomCategory(id: $id, name: $name, iconHex: $iconHex, colorHex: $colorHex, isVariableBucket: $isVariableBucket, bucketLimit: $bucketLimit)';
}


}

/// @nodoc
abstract mixin class _$CustomCategoryCopyWith<$Res> implements $CustomCategoryCopyWith<$Res> {
  factory _$CustomCategoryCopyWith(_CustomCategory value, $Res Function(_CustomCategory) _then) = __$CustomCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String iconHex, String colorHex, bool isVariableBucket, double bucketLimit
});




}
/// @nodoc
class __$CustomCategoryCopyWithImpl<$Res>
    implements _$CustomCategoryCopyWith<$Res> {
  __$CustomCategoryCopyWithImpl(this._self, this._then);

  final _CustomCategory _self;
  final $Res Function(_CustomCategory) _then;

/// Create a copy of CustomCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? iconHex = null,Object? colorHex = null,Object? isVariableBucket = null,Object? bucketLimit = null,}) {
  return _then(_CustomCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconHex: null == iconHex ? _self.iconHex : iconHex // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,isVariableBucket: null == isVariableBucket ? _self.isVariableBucket : isVariableBucket // ignore: cast_nullable_to_non_nullable
as bool,bucketLimit: null == bucketLimit ? _self.bucketLimit : bucketLimit // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
