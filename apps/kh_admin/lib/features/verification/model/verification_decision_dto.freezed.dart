// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verification_decision_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VerifyDecisionDto {

 String get rationale;
/// Create a copy of VerifyDecisionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifyDecisionDtoCopyWith<VerifyDecisionDto> get copyWith => _$VerifyDecisionDtoCopyWithImpl<VerifyDecisionDto>(this as VerifyDecisionDto, _$identity);

  /// Serializes this VerifyDecisionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifyDecisionDto&&(identical(other.rationale, rationale) || other.rationale == rationale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rationale);

@override
String toString() {
  return 'VerifyDecisionDto(rationale: $rationale)';
}


}

/// @nodoc
abstract mixin class $VerifyDecisionDtoCopyWith<$Res>  {
  factory $VerifyDecisionDtoCopyWith(VerifyDecisionDto value, $Res Function(VerifyDecisionDto) _then) = _$VerifyDecisionDtoCopyWithImpl;
@useResult
$Res call({
 String rationale
});




}
/// @nodoc
class _$VerifyDecisionDtoCopyWithImpl<$Res>
    implements $VerifyDecisionDtoCopyWith<$Res> {
  _$VerifyDecisionDtoCopyWithImpl(this._self, this._then);

  final VerifyDecisionDto _self;
  final $Res Function(VerifyDecisionDto) _then;

/// Create a copy of VerifyDecisionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rationale = null,}) {
  return _then(_self.copyWith(
rationale: null == rationale ? _self.rationale : rationale // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VerifyDecisionDto].
extension VerifyDecisionDtoPatterns on VerifyDecisionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerifyDecisionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerifyDecisionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerifyDecisionDto value)  $default,){
final _that = this;
switch (_that) {
case _VerifyDecisionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerifyDecisionDto value)?  $default,){
final _that = this;
switch (_that) {
case _VerifyDecisionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rationale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerifyDecisionDto() when $default != null:
return $default(_that.rationale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rationale)  $default,) {final _that = this;
switch (_that) {
case _VerifyDecisionDto():
return $default(_that.rationale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rationale)?  $default,) {final _that = this;
switch (_that) {
case _VerifyDecisionDto() when $default != null:
return $default(_that.rationale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerifyDecisionDto implements VerifyDecisionDto {
  const _VerifyDecisionDto({required this.rationale});
  factory _VerifyDecisionDto.fromJson(Map<String, dynamic> json) => _$VerifyDecisionDtoFromJson(json);

@override final  String rationale;

/// Create a copy of VerifyDecisionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerifyDecisionDtoCopyWith<_VerifyDecisionDto> get copyWith => __$VerifyDecisionDtoCopyWithImpl<_VerifyDecisionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerifyDecisionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifyDecisionDto&&(identical(other.rationale, rationale) || other.rationale == rationale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rationale);

@override
String toString() {
  return 'VerifyDecisionDto(rationale: $rationale)';
}


}

/// @nodoc
abstract mixin class _$VerifyDecisionDtoCopyWith<$Res> implements $VerifyDecisionDtoCopyWith<$Res> {
  factory _$VerifyDecisionDtoCopyWith(_VerifyDecisionDto value, $Res Function(_VerifyDecisionDto) _then) = __$VerifyDecisionDtoCopyWithImpl;
@override @useResult
$Res call({
 String rationale
});




}
/// @nodoc
class __$VerifyDecisionDtoCopyWithImpl<$Res>
    implements _$VerifyDecisionDtoCopyWith<$Res> {
  __$VerifyDecisionDtoCopyWithImpl(this._self, this._then);

  final _VerifyDecisionDto _self;
  final $Res Function(_VerifyDecisionDto) _then;

/// Create a copy of VerifyDecisionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rationale = null,}) {
  return _then(_VerifyDecisionDto(
rationale: null == rationale ? _self.rationale : rationale // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RejectDecisionDto {

 String get rationale;
/// Create a copy of RejectDecisionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RejectDecisionDtoCopyWith<RejectDecisionDto> get copyWith => _$RejectDecisionDtoCopyWithImpl<RejectDecisionDto>(this as RejectDecisionDto, _$identity);

  /// Serializes this RejectDecisionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RejectDecisionDto&&(identical(other.rationale, rationale) || other.rationale == rationale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rationale);

@override
String toString() {
  return 'RejectDecisionDto(rationale: $rationale)';
}


}

/// @nodoc
abstract mixin class $RejectDecisionDtoCopyWith<$Res>  {
  factory $RejectDecisionDtoCopyWith(RejectDecisionDto value, $Res Function(RejectDecisionDto) _then) = _$RejectDecisionDtoCopyWithImpl;
@useResult
$Res call({
 String rationale
});




}
/// @nodoc
class _$RejectDecisionDtoCopyWithImpl<$Res>
    implements $RejectDecisionDtoCopyWith<$Res> {
  _$RejectDecisionDtoCopyWithImpl(this._self, this._then);

  final RejectDecisionDto _self;
  final $Res Function(RejectDecisionDto) _then;

/// Create a copy of RejectDecisionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rationale = null,}) {
  return _then(_self.copyWith(
rationale: null == rationale ? _self.rationale : rationale // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RejectDecisionDto].
extension RejectDecisionDtoPatterns on RejectDecisionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RejectDecisionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RejectDecisionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RejectDecisionDto value)  $default,){
final _that = this;
switch (_that) {
case _RejectDecisionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RejectDecisionDto value)?  $default,){
final _that = this;
switch (_that) {
case _RejectDecisionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rationale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RejectDecisionDto() when $default != null:
return $default(_that.rationale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rationale)  $default,) {final _that = this;
switch (_that) {
case _RejectDecisionDto():
return $default(_that.rationale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rationale)?  $default,) {final _that = this;
switch (_that) {
case _RejectDecisionDto() when $default != null:
return $default(_that.rationale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RejectDecisionDto implements RejectDecisionDto {
  const _RejectDecisionDto({required this.rationale});
  factory _RejectDecisionDto.fromJson(Map<String, dynamic> json) => _$RejectDecisionDtoFromJson(json);

@override final  String rationale;

/// Create a copy of RejectDecisionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RejectDecisionDtoCopyWith<_RejectDecisionDto> get copyWith => __$RejectDecisionDtoCopyWithImpl<_RejectDecisionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RejectDecisionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RejectDecisionDto&&(identical(other.rationale, rationale) || other.rationale == rationale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rationale);

@override
String toString() {
  return 'RejectDecisionDto(rationale: $rationale)';
}


}

/// @nodoc
abstract mixin class _$RejectDecisionDtoCopyWith<$Res> implements $RejectDecisionDtoCopyWith<$Res> {
  factory _$RejectDecisionDtoCopyWith(_RejectDecisionDto value, $Res Function(_RejectDecisionDto) _then) = __$RejectDecisionDtoCopyWithImpl;
@override @useResult
$Res call({
 String rationale
});




}
/// @nodoc
class __$RejectDecisionDtoCopyWithImpl<$Res>
    implements _$RejectDecisionDtoCopyWith<$Res> {
  __$RejectDecisionDtoCopyWithImpl(this._self, this._then);

  final _RejectDecisionDto _self;
  final $Res Function(_RejectDecisionDto) _then;

/// Create a copy of RejectDecisionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rationale = null,}) {
  return _then(_RejectDecisionDto(
rationale: null == rationale ? _self.rationale : rationale // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RequestInfoDto {

 String get message;
/// Create a copy of RequestInfoDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestInfoDtoCopyWith<RequestInfoDto> get copyWith => _$RequestInfoDtoCopyWithImpl<RequestInfoDto>(this as RequestInfoDto, _$identity);

  /// Serializes this RequestInfoDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestInfoDto&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'RequestInfoDto(message: $message)';
}


}

/// @nodoc
abstract mixin class $RequestInfoDtoCopyWith<$Res>  {
  factory $RequestInfoDtoCopyWith(RequestInfoDto value, $Res Function(RequestInfoDto) _then) = _$RequestInfoDtoCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$RequestInfoDtoCopyWithImpl<$Res>
    implements $RequestInfoDtoCopyWith<$Res> {
  _$RequestInfoDtoCopyWithImpl(this._self, this._then);

  final RequestInfoDto _self;
  final $Res Function(RequestInfoDto) _then;

/// Create a copy of RequestInfoDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestInfoDto].
extension RequestInfoDtoPatterns on RequestInfoDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestInfoDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestInfoDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestInfoDto value)  $default,){
final _that = this;
switch (_that) {
case _RequestInfoDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestInfoDto value)?  $default,){
final _that = this;
switch (_that) {
case _RequestInfoDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestInfoDto() when $default != null:
return $default(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message)  $default,) {final _that = this;
switch (_that) {
case _RequestInfoDto():
return $default(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message)?  $default,) {final _that = this;
switch (_that) {
case _RequestInfoDto() when $default != null:
return $default(_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RequestInfoDto implements RequestInfoDto {
  const _RequestInfoDto({required this.message});
  factory _RequestInfoDto.fromJson(Map<String, dynamic> json) => _$RequestInfoDtoFromJson(json);

@override final  String message;

/// Create a copy of RequestInfoDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestInfoDtoCopyWith<_RequestInfoDto> get copyWith => __$RequestInfoDtoCopyWithImpl<_RequestInfoDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestInfoDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestInfoDto&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'RequestInfoDto(message: $message)';
}


}

/// @nodoc
abstract mixin class _$RequestInfoDtoCopyWith<$Res> implements $RequestInfoDtoCopyWith<$Res> {
  factory _$RequestInfoDtoCopyWith(_RequestInfoDto value, $Res Function(_RequestInfoDto) _then) = __$RequestInfoDtoCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class __$RequestInfoDtoCopyWithImpl<$Res>
    implements _$RequestInfoDtoCopyWith<$Res> {
  __$RequestInfoDtoCopyWithImpl(this._self, this._then);

  final _RequestInfoDto _self;
  final $Res Function(_RequestInfoDto) _then;

/// Create a copy of RequestInfoDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_RequestInfoDto(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
