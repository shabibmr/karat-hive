// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gold_rate_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GoldRateSnapshotDto {

 bool get available; bool get stale; String? get reason; String? get source; DateTime? get sourceTimestamp; DateTime? get ingestedAt; DateTime? get staleAfter; List<GoldRateRowDto> get rates; String? get disclaimer;
/// Create a copy of GoldRateSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoldRateSnapshotDtoCopyWith<GoldRateSnapshotDto> get copyWith => _$GoldRateSnapshotDtoCopyWithImpl<GoldRateSnapshotDto>(this as GoldRateSnapshotDto, _$identity);

  /// Serializes this GoldRateSnapshotDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoldRateSnapshotDto&&(identical(other.available, available) || other.available == available)&&(identical(other.stale, stale) || other.stale == stale)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.source, source) || other.source == source)&&(identical(other.sourceTimestamp, sourceTimestamp) || other.sourceTimestamp == sourceTimestamp)&&(identical(other.ingestedAt, ingestedAt) || other.ingestedAt == ingestedAt)&&(identical(other.staleAfter, staleAfter) || other.staleAfter == staleAfter)&&const DeepCollectionEquality().equals(other.rates, rates)&&(identical(other.disclaimer, disclaimer) || other.disclaimer == disclaimer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,available,stale,reason,source,sourceTimestamp,ingestedAt,staleAfter,const DeepCollectionEquality().hash(rates),disclaimer);

@override
String toString() {
  return 'GoldRateSnapshotDto(available: $available, stale: $stale, reason: $reason, source: $source, sourceTimestamp: $sourceTimestamp, ingestedAt: $ingestedAt, staleAfter: $staleAfter, rates: $rates, disclaimer: $disclaimer)';
}


}

/// @nodoc
abstract mixin class $GoldRateSnapshotDtoCopyWith<$Res>  {
  factory $GoldRateSnapshotDtoCopyWith(GoldRateSnapshotDto value, $Res Function(GoldRateSnapshotDto) _then) = _$GoldRateSnapshotDtoCopyWithImpl;
@useResult
$Res call({
 bool available, bool stale, String? reason, String? source, DateTime? sourceTimestamp, DateTime? ingestedAt, DateTime? staleAfter, List<GoldRateRowDto> rates, String? disclaimer
});




}
/// @nodoc
class _$GoldRateSnapshotDtoCopyWithImpl<$Res>
    implements $GoldRateSnapshotDtoCopyWith<$Res> {
  _$GoldRateSnapshotDtoCopyWithImpl(this._self, this._then);

  final GoldRateSnapshotDto _self;
  final $Res Function(GoldRateSnapshotDto) _then;

/// Create a copy of GoldRateSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? available = null,Object? stale = null,Object? reason = freezed,Object? source = freezed,Object? sourceTimestamp = freezed,Object? ingestedAt = freezed,Object? staleAfter = freezed,Object? rates = null,Object? disclaimer = freezed,}) {
  return _then(_self.copyWith(
available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,stale: null == stale ? _self.stale : stale // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,sourceTimestamp: freezed == sourceTimestamp ? _self.sourceTimestamp : sourceTimestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,ingestedAt: freezed == ingestedAt ? _self.ingestedAt : ingestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,staleAfter: freezed == staleAfter ? _self.staleAfter : staleAfter // ignore: cast_nullable_to_non_nullable
as DateTime?,rates: null == rates ? _self.rates : rates // ignore: cast_nullable_to_non_nullable
as List<GoldRateRowDto>,disclaimer: freezed == disclaimer ? _self.disclaimer : disclaimer // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GoldRateSnapshotDto].
extension GoldRateSnapshotDtoPatterns on GoldRateSnapshotDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoldRateSnapshotDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoldRateSnapshotDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoldRateSnapshotDto value)  $default,){
final _that = this;
switch (_that) {
case _GoldRateSnapshotDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoldRateSnapshotDto value)?  $default,){
final _that = this;
switch (_that) {
case _GoldRateSnapshotDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool available,  bool stale,  String? reason,  String? source,  DateTime? sourceTimestamp,  DateTime? ingestedAt,  DateTime? staleAfter,  List<GoldRateRowDto> rates,  String? disclaimer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoldRateSnapshotDto() when $default != null:
return $default(_that.available,_that.stale,_that.reason,_that.source,_that.sourceTimestamp,_that.ingestedAt,_that.staleAfter,_that.rates,_that.disclaimer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool available,  bool stale,  String? reason,  String? source,  DateTime? sourceTimestamp,  DateTime? ingestedAt,  DateTime? staleAfter,  List<GoldRateRowDto> rates,  String? disclaimer)  $default,) {final _that = this;
switch (_that) {
case _GoldRateSnapshotDto():
return $default(_that.available,_that.stale,_that.reason,_that.source,_that.sourceTimestamp,_that.ingestedAt,_that.staleAfter,_that.rates,_that.disclaimer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool available,  bool stale,  String? reason,  String? source,  DateTime? sourceTimestamp,  DateTime? ingestedAt,  DateTime? staleAfter,  List<GoldRateRowDto> rates,  String? disclaimer)?  $default,) {final _that = this;
switch (_that) {
case _GoldRateSnapshotDto() when $default != null:
return $default(_that.available,_that.stale,_that.reason,_that.source,_that.sourceTimestamp,_that.ingestedAt,_that.staleAfter,_that.rates,_that.disclaimer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoldRateSnapshotDto implements GoldRateSnapshotDto {
  const _GoldRateSnapshotDto({required this.available, required this.stale, this.reason, this.source, this.sourceTimestamp, this.ingestedAt, this.staleAfter, final  List<GoldRateRowDto> rates = const <GoldRateRowDto>[], this.disclaimer}): _rates = rates;
  factory _GoldRateSnapshotDto.fromJson(Map<String, dynamic> json) => _$GoldRateSnapshotDtoFromJson(json);

@override final  bool available;
@override final  bool stale;
@override final  String? reason;
@override final  String? source;
@override final  DateTime? sourceTimestamp;
@override final  DateTime? ingestedAt;
@override final  DateTime? staleAfter;
 final  List<GoldRateRowDto> _rates;
@override@JsonKey() List<GoldRateRowDto> get rates {
  if (_rates is EqualUnmodifiableListView) return _rates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rates);
}

@override final  String? disclaimer;

/// Create a copy of GoldRateSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoldRateSnapshotDtoCopyWith<_GoldRateSnapshotDto> get copyWith => __$GoldRateSnapshotDtoCopyWithImpl<_GoldRateSnapshotDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoldRateSnapshotDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoldRateSnapshotDto&&(identical(other.available, available) || other.available == available)&&(identical(other.stale, stale) || other.stale == stale)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.source, source) || other.source == source)&&(identical(other.sourceTimestamp, sourceTimestamp) || other.sourceTimestamp == sourceTimestamp)&&(identical(other.ingestedAt, ingestedAt) || other.ingestedAt == ingestedAt)&&(identical(other.staleAfter, staleAfter) || other.staleAfter == staleAfter)&&const DeepCollectionEquality().equals(other._rates, _rates)&&(identical(other.disclaimer, disclaimer) || other.disclaimer == disclaimer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,available,stale,reason,source,sourceTimestamp,ingestedAt,staleAfter,const DeepCollectionEquality().hash(_rates),disclaimer);

@override
String toString() {
  return 'GoldRateSnapshotDto(available: $available, stale: $stale, reason: $reason, source: $source, sourceTimestamp: $sourceTimestamp, ingestedAt: $ingestedAt, staleAfter: $staleAfter, rates: $rates, disclaimer: $disclaimer)';
}


}

/// @nodoc
abstract mixin class _$GoldRateSnapshotDtoCopyWith<$Res> implements $GoldRateSnapshotDtoCopyWith<$Res> {
  factory _$GoldRateSnapshotDtoCopyWith(_GoldRateSnapshotDto value, $Res Function(_GoldRateSnapshotDto) _then) = __$GoldRateSnapshotDtoCopyWithImpl;
@override @useResult
$Res call({
 bool available, bool stale, String? reason, String? source, DateTime? sourceTimestamp, DateTime? ingestedAt, DateTime? staleAfter, List<GoldRateRowDto> rates, String? disclaimer
});




}
/// @nodoc
class __$GoldRateSnapshotDtoCopyWithImpl<$Res>
    implements _$GoldRateSnapshotDtoCopyWith<$Res> {
  __$GoldRateSnapshotDtoCopyWithImpl(this._self, this._then);

  final _GoldRateSnapshotDto _self;
  final $Res Function(_GoldRateSnapshotDto) _then;

/// Create a copy of GoldRateSnapshotDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? available = null,Object? stale = null,Object? reason = freezed,Object? source = freezed,Object? sourceTimestamp = freezed,Object? ingestedAt = freezed,Object? staleAfter = freezed,Object? rates = null,Object? disclaimer = freezed,}) {
  return _then(_GoldRateSnapshotDto(
available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,stale: null == stale ? _self.stale : stale // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,sourceTimestamp: freezed == sourceTimestamp ? _self.sourceTimestamp : sourceTimestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,ingestedAt: freezed == ingestedAt ? _self.ingestedAt : ingestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,staleAfter: freezed == staleAfter ? _self.staleAfter : staleAfter // ignore: cast_nullable_to_non_nullable
as DateTime?,rates: null == rates ? _self._rates : rates // ignore: cast_nullable_to_non_nullable
as List<GoldRateRowDto>,disclaimer: freezed == disclaimer ? _self.disclaimer : disclaimer // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$GoldRateRowDto {

 String get karat; String get ratePerGramAed;
/// Create a copy of GoldRateRowDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoldRateRowDtoCopyWith<GoldRateRowDto> get copyWith => _$GoldRateRowDtoCopyWithImpl<GoldRateRowDto>(this as GoldRateRowDto, _$identity);

  /// Serializes this GoldRateRowDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoldRateRowDto&&(identical(other.karat, karat) || other.karat == karat)&&(identical(other.ratePerGramAed, ratePerGramAed) || other.ratePerGramAed == ratePerGramAed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,karat,ratePerGramAed);

@override
String toString() {
  return 'GoldRateRowDto(karat: $karat, ratePerGramAed: $ratePerGramAed)';
}


}

/// @nodoc
abstract mixin class $GoldRateRowDtoCopyWith<$Res>  {
  factory $GoldRateRowDtoCopyWith(GoldRateRowDto value, $Res Function(GoldRateRowDto) _then) = _$GoldRateRowDtoCopyWithImpl;
@useResult
$Res call({
 String karat, String ratePerGramAed
});




}
/// @nodoc
class _$GoldRateRowDtoCopyWithImpl<$Res>
    implements $GoldRateRowDtoCopyWith<$Res> {
  _$GoldRateRowDtoCopyWithImpl(this._self, this._then);

  final GoldRateRowDto _self;
  final $Res Function(GoldRateRowDto) _then;

/// Create a copy of GoldRateRowDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? karat = null,Object? ratePerGramAed = null,}) {
  return _then(_self.copyWith(
karat: null == karat ? _self.karat : karat // ignore: cast_nullable_to_non_nullable
as String,ratePerGramAed: null == ratePerGramAed ? _self.ratePerGramAed : ratePerGramAed // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GoldRateRowDto].
extension GoldRateRowDtoPatterns on GoldRateRowDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoldRateRowDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoldRateRowDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoldRateRowDto value)  $default,){
final _that = this;
switch (_that) {
case _GoldRateRowDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoldRateRowDto value)?  $default,){
final _that = this;
switch (_that) {
case _GoldRateRowDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String karat,  String ratePerGramAed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoldRateRowDto() when $default != null:
return $default(_that.karat,_that.ratePerGramAed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String karat,  String ratePerGramAed)  $default,) {final _that = this;
switch (_that) {
case _GoldRateRowDto():
return $default(_that.karat,_that.ratePerGramAed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String karat,  String ratePerGramAed)?  $default,) {final _that = this;
switch (_that) {
case _GoldRateRowDto() when $default != null:
return $default(_that.karat,_that.ratePerGramAed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoldRateRowDto implements GoldRateRowDto {
  const _GoldRateRowDto({required this.karat, required this.ratePerGramAed});
  factory _GoldRateRowDto.fromJson(Map<String, dynamic> json) => _$GoldRateRowDtoFromJson(json);

@override final  String karat;
@override final  String ratePerGramAed;

/// Create a copy of GoldRateRowDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoldRateRowDtoCopyWith<_GoldRateRowDto> get copyWith => __$GoldRateRowDtoCopyWithImpl<_GoldRateRowDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoldRateRowDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoldRateRowDto&&(identical(other.karat, karat) || other.karat == karat)&&(identical(other.ratePerGramAed, ratePerGramAed) || other.ratePerGramAed == ratePerGramAed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,karat,ratePerGramAed);

@override
String toString() {
  return 'GoldRateRowDto(karat: $karat, ratePerGramAed: $ratePerGramAed)';
}


}

/// @nodoc
abstract mixin class _$GoldRateRowDtoCopyWith<$Res> implements $GoldRateRowDtoCopyWith<$Res> {
  factory _$GoldRateRowDtoCopyWith(_GoldRateRowDto value, $Res Function(_GoldRateRowDto) _then) = __$GoldRateRowDtoCopyWithImpl;
@override @useResult
$Res call({
 String karat, String ratePerGramAed
});




}
/// @nodoc
class __$GoldRateRowDtoCopyWithImpl<$Res>
    implements _$GoldRateRowDtoCopyWith<$Res> {
  __$GoldRateRowDtoCopyWithImpl(this._self, this._then);

  final _GoldRateRowDto _self;
  final $Res Function(_GoldRateRowDto) _then;

/// Create a copy of GoldRateRowDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? karat = null,Object? ratePerGramAed = null,}) {
  return _then(_GoldRateRowDto(
karat: null == karat ? _self.karat : karat // ignore: cast_nullable_to_non_nullable
as String,ratePerGramAed: null == ratePerGramAed ? _self.ratePerGramAed : ratePerGramAed // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
