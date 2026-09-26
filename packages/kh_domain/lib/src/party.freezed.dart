// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'party.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegionSummary {

 String get id; String get nameEn; String get nameAr; bool get isActive; int get displayOrder;
/// Create a copy of RegionSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegionSummaryCopyWith<RegionSummary> get copyWith => _$RegionSummaryCopyWithImpl<RegionSummary>(this as RegionSummary, _$identity);

  /// Serializes this RegionSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegionSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameEn,nameAr,isActive,displayOrder);



}

/// @nodoc
abstract mixin class $RegionSummaryCopyWith<$Res>  {
  factory $RegionSummaryCopyWith(RegionSummary value, $Res Function(RegionSummary) _then) = _$RegionSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String nameEn, String nameAr, bool isActive, int displayOrder
});




}
/// @nodoc
class _$RegionSummaryCopyWithImpl<$Res>
    implements $RegionSummaryCopyWith<$Res> {
  _$RegionSummaryCopyWithImpl(this._self, this._then);

  final RegionSummary _self;
  final $Res Function(RegionSummary) _then;

/// Create a copy of RegionSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nameEn = null,Object? nameAr = null,Object? isActive = null,Object? displayOrder = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RegionSummary].
extension RegionSummaryPatterns on RegionSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegionSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegionSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegionSummary value)  $default,){
final _that = this;
switch (_that) {
case _RegionSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegionSummary value)?  $default,){
final _that = this;
switch (_that) {
case _RegionSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nameEn,  String nameAr,  bool isActive,  int displayOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegionSummary() when $default != null:
return $default(_that.id,_that.nameEn,_that.nameAr,_that.isActive,_that.displayOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nameEn,  String nameAr,  bool isActive,  int displayOrder)  $default,) {final _that = this;
switch (_that) {
case _RegionSummary():
return $default(_that.id,_that.nameEn,_that.nameAr,_that.isActive,_that.displayOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nameEn,  String nameAr,  bool isActive,  int displayOrder)?  $default,) {final _that = this;
switch (_that) {
case _RegionSummary() when $default != null:
return $default(_that.id,_that.nameEn,_that.nameAr,_that.isActive,_that.displayOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegionSummary extends RegionSummary {
  const _RegionSummary({required this.id, required this.nameEn, required this.nameAr, this.isActive = true, this.displayOrder = 0}): super._();
  factory _RegionSummary.fromJson(Map<String, dynamic> json) => _$RegionSummaryFromJson(json);

@override final  String id;
@override final  String nameEn;
@override final  String nameAr;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  int displayOrder;

/// Create a copy of RegionSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegionSummaryCopyWith<_RegionSummary> get copyWith => __$RegionSummaryCopyWithImpl<_RegionSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegionSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegionSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameEn,nameAr,isActive,displayOrder);



}

/// @nodoc
abstract mixin class _$RegionSummaryCopyWith<$Res> implements $RegionSummaryCopyWith<$Res> {
  factory _$RegionSummaryCopyWith(_RegionSummary value, $Res Function(_RegionSummary) _then) = __$RegionSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String nameEn, String nameAr, bool isActive, int displayOrder
});




}
/// @nodoc
class __$RegionSummaryCopyWithImpl<$Res>
    implements _$RegionSummaryCopyWith<$Res> {
  __$RegionSummaryCopyWithImpl(this._self, this._then);

  final _RegionSummary _self;
  final $Res Function(_RegionSummary) _then;

/// Create a copy of RegionSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nameEn = null,Object? nameAr = null,Object? isActive = null,Object? displayOrder = null,}) {
  return _then(_RegionSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
