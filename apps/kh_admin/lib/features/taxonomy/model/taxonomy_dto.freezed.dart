// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'taxonomy_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateTaxonomyDto {

 String get nameEn; String get nameAr; String? get icon; int get displayOrder; bool get isActive;
/// Create a copy of CreateTaxonomyDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateTaxonomyDtoCopyWith<CreateTaxonomyDto> get copyWith => _$CreateTaxonomyDtoCopyWithImpl<CreateTaxonomyDto>(this as CreateTaxonomyDto, _$identity);

  /// Serializes this CreateTaxonomyDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateTaxonomyDto&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nameEn,nameAr,icon,displayOrder,isActive);

@override
String toString() {
  return 'CreateTaxonomyDto(nameEn: $nameEn, nameAr: $nameAr, icon: $icon, displayOrder: $displayOrder, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $CreateTaxonomyDtoCopyWith<$Res>  {
  factory $CreateTaxonomyDtoCopyWith(CreateTaxonomyDto value, $Res Function(CreateTaxonomyDto) _then) = _$CreateTaxonomyDtoCopyWithImpl;
@useResult
$Res call({
 String nameEn, String nameAr, String? icon, int displayOrder, bool isActive
});




}
/// @nodoc
class _$CreateTaxonomyDtoCopyWithImpl<$Res>
    implements $CreateTaxonomyDtoCopyWith<$Res> {
  _$CreateTaxonomyDtoCopyWithImpl(this._self, this._then);

  final CreateTaxonomyDto _self;
  final $Res Function(CreateTaxonomyDto) _then;

/// Create a copy of CreateTaxonomyDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nameEn = null,Object? nameAr = null,Object? icon = freezed,Object? displayOrder = null,Object? isActive = null,}) {
  return _then(_self.copyWith(
nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateTaxonomyDto].
extension CreateTaxonomyDtoPatterns on CreateTaxonomyDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateTaxonomyDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateTaxonomyDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateTaxonomyDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateTaxonomyDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateTaxonomyDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateTaxonomyDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nameEn,  String nameAr,  String? icon,  int displayOrder,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateTaxonomyDto() when $default != null:
return $default(_that.nameEn,_that.nameAr,_that.icon,_that.displayOrder,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nameEn,  String nameAr,  String? icon,  int displayOrder,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _CreateTaxonomyDto():
return $default(_that.nameEn,_that.nameAr,_that.icon,_that.displayOrder,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nameEn,  String nameAr,  String? icon,  int displayOrder,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _CreateTaxonomyDto() when $default != null:
return $default(_that.nameEn,_that.nameAr,_that.icon,_that.displayOrder,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateTaxonomyDto implements CreateTaxonomyDto {
  const _CreateTaxonomyDto({required this.nameEn, required this.nameAr, this.icon, this.displayOrder = 0, this.isActive = true});
  factory _CreateTaxonomyDto.fromJson(Map<String, dynamic> json) => _$CreateTaxonomyDtoFromJson(json);

@override final  String nameEn;
@override final  String nameAr;
@override final  String? icon;
@override@JsonKey() final  int displayOrder;
@override@JsonKey() final  bool isActive;

/// Create a copy of CreateTaxonomyDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateTaxonomyDtoCopyWith<_CreateTaxonomyDto> get copyWith => __$CreateTaxonomyDtoCopyWithImpl<_CreateTaxonomyDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateTaxonomyDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateTaxonomyDto&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nameEn,nameAr,icon,displayOrder,isActive);

@override
String toString() {
  return 'CreateTaxonomyDto(nameEn: $nameEn, nameAr: $nameAr, icon: $icon, displayOrder: $displayOrder, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$CreateTaxonomyDtoCopyWith<$Res> implements $CreateTaxonomyDtoCopyWith<$Res> {
  factory _$CreateTaxonomyDtoCopyWith(_CreateTaxonomyDto value, $Res Function(_CreateTaxonomyDto) _then) = __$CreateTaxonomyDtoCopyWithImpl;
@override @useResult
$Res call({
 String nameEn, String nameAr, String? icon, int displayOrder, bool isActive
});




}
/// @nodoc
class __$CreateTaxonomyDtoCopyWithImpl<$Res>
    implements _$CreateTaxonomyDtoCopyWith<$Res> {
  __$CreateTaxonomyDtoCopyWithImpl(this._self, this._then);

  final _CreateTaxonomyDto _self;
  final $Res Function(_CreateTaxonomyDto) _then;

/// Create a copy of CreateTaxonomyDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nameEn = null,Object? nameAr = null,Object? icon = freezed,Object? displayOrder = null,Object? isActive = null,}) {
  return _then(_CreateTaxonomyDto(
nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$UpdateTaxonomyDto {

 String? get nameEn; String? get nameAr; String? get icon; int? get displayOrder; bool? get isActive;
/// Create a copy of UpdateTaxonomyDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateTaxonomyDtoCopyWith<UpdateTaxonomyDto> get copyWith => _$UpdateTaxonomyDtoCopyWithImpl<UpdateTaxonomyDto>(this as UpdateTaxonomyDto, _$identity);

  /// Serializes this UpdateTaxonomyDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateTaxonomyDto&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nameEn,nameAr,icon,displayOrder,isActive);

@override
String toString() {
  return 'UpdateTaxonomyDto(nameEn: $nameEn, nameAr: $nameAr, icon: $icon, displayOrder: $displayOrder, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $UpdateTaxonomyDtoCopyWith<$Res>  {
  factory $UpdateTaxonomyDtoCopyWith(UpdateTaxonomyDto value, $Res Function(UpdateTaxonomyDto) _then) = _$UpdateTaxonomyDtoCopyWithImpl;
@useResult
$Res call({
 String? nameEn, String? nameAr, String? icon, int? displayOrder, bool? isActive
});




}
/// @nodoc
class _$UpdateTaxonomyDtoCopyWithImpl<$Res>
    implements $UpdateTaxonomyDtoCopyWith<$Res> {
  _$UpdateTaxonomyDtoCopyWithImpl(this._self, this._then);

  final UpdateTaxonomyDto _self;
  final $Res Function(UpdateTaxonomyDto) _then;

/// Create a copy of UpdateTaxonomyDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nameEn = freezed,Object? nameAr = freezed,Object? icon = freezed,Object? displayOrder = freezed,Object? isActive = freezed,}) {
  return _then(_self.copyWith(
nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,displayOrder: freezed == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateTaxonomyDto].
extension UpdateTaxonomyDtoPatterns on UpdateTaxonomyDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateTaxonomyDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateTaxonomyDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateTaxonomyDto value)  $default,){
final _that = this;
switch (_that) {
case _UpdateTaxonomyDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateTaxonomyDto value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateTaxonomyDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? nameEn,  String? nameAr,  String? icon,  int? displayOrder,  bool? isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateTaxonomyDto() when $default != null:
return $default(_that.nameEn,_that.nameAr,_that.icon,_that.displayOrder,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? nameEn,  String? nameAr,  String? icon,  int? displayOrder,  bool? isActive)  $default,) {final _that = this;
switch (_that) {
case _UpdateTaxonomyDto():
return $default(_that.nameEn,_that.nameAr,_that.icon,_that.displayOrder,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? nameEn,  String? nameAr,  String? icon,  int? displayOrder,  bool? isActive)?  $default,) {final _that = this;
switch (_that) {
case _UpdateTaxonomyDto() when $default != null:
return $default(_that.nameEn,_that.nameAr,_that.icon,_that.displayOrder,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateTaxonomyDto implements UpdateTaxonomyDto {
  const _UpdateTaxonomyDto({this.nameEn, this.nameAr, this.icon, this.displayOrder, this.isActive});
  factory _UpdateTaxonomyDto.fromJson(Map<String, dynamic> json) => _$UpdateTaxonomyDtoFromJson(json);

@override final  String? nameEn;
@override final  String? nameAr;
@override final  String? icon;
@override final  int? displayOrder;
@override final  bool? isActive;

/// Create a copy of UpdateTaxonomyDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateTaxonomyDtoCopyWith<_UpdateTaxonomyDto> get copyWith => __$UpdateTaxonomyDtoCopyWithImpl<_UpdateTaxonomyDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateTaxonomyDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateTaxonomyDto&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nameEn,nameAr,icon,displayOrder,isActive);

@override
String toString() {
  return 'UpdateTaxonomyDto(nameEn: $nameEn, nameAr: $nameAr, icon: $icon, displayOrder: $displayOrder, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$UpdateTaxonomyDtoCopyWith<$Res> implements $UpdateTaxonomyDtoCopyWith<$Res> {
  factory _$UpdateTaxonomyDtoCopyWith(_UpdateTaxonomyDto value, $Res Function(_UpdateTaxonomyDto) _then) = __$UpdateTaxonomyDtoCopyWithImpl;
@override @useResult
$Res call({
 String? nameEn, String? nameAr, String? icon, int? displayOrder, bool? isActive
});




}
/// @nodoc
class __$UpdateTaxonomyDtoCopyWithImpl<$Res>
    implements _$UpdateTaxonomyDtoCopyWith<$Res> {
  __$UpdateTaxonomyDtoCopyWithImpl(this._self, this._then);

  final _UpdateTaxonomyDto _self;
  final $Res Function(_UpdateTaxonomyDto) _then;

/// Create a copy of UpdateTaxonomyDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nameEn = freezed,Object? nameAr = freezed,Object? icon = freezed,Object? displayOrder = freezed,Object? isActive = freezed,}) {
  return _then(_UpdateTaxonomyDto(
nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,displayOrder: freezed == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
