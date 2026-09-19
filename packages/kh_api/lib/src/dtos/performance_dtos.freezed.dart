// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'performance_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RatingTrendPointDto {

/// `YYYY-MM` calendar month (`SAM-GAP-8`).
 String get period; double get average; int get count;
/// Create a copy of RatingTrendPointDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RatingTrendPointDtoCopyWith<RatingTrendPointDto> get copyWith => _$RatingTrendPointDtoCopyWithImpl<RatingTrendPointDto>(this as RatingTrendPointDto, _$identity);

  /// Serializes this RatingTrendPointDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RatingTrendPointDto&&(identical(other.period, period) || other.period == period)&&(identical(other.average, average) || other.average == average)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,period,average,count);

@override
String toString() {
  return 'RatingTrendPointDto(period: $period, average: $average, count: $count)';
}


}

/// @nodoc
abstract mixin class $RatingTrendPointDtoCopyWith<$Res>  {
  factory $RatingTrendPointDtoCopyWith(RatingTrendPointDto value, $Res Function(RatingTrendPointDto) _then) = _$RatingTrendPointDtoCopyWithImpl;
@useResult
$Res call({
 String period, double average, int count
});




}
/// @nodoc
class _$RatingTrendPointDtoCopyWithImpl<$Res>
    implements $RatingTrendPointDtoCopyWith<$Res> {
  _$RatingTrendPointDtoCopyWithImpl(this._self, this._then);

  final RatingTrendPointDto _self;
  final $Res Function(RatingTrendPointDto) _then;

/// Create a copy of RatingTrendPointDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = null,Object? average = null,Object? count = null,}) {
  return _then(_self.copyWith(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,average: null == average ? _self.average : average // ignore: cast_nullable_to_non_nullable
as double,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RatingTrendPointDto].
extension RatingTrendPointDtoPatterns on RatingTrendPointDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RatingTrendPointDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RatingTrendPointDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RatingTrendPointDto value)  $default,){
final _that = this;
switch (_that) {
case _RatingTrendPointDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RatingTrendPointDto value)?  $default,){
final _that = this;
switch (_that) {
case _RatingTrendPointDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String period,  double average,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RatingTrendPointDto() when $default != null:
return $default(_that.period,_that.average,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String period,  double average,  int count)  $default,) {final _that = this;
switch (_that) {
case _RatingTrendPointDto():
return $default(_that.period,_that.average,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String period,  double average,  int count)?  $default,) {final _that = this;
switch (_that) {
case _RatingTrendPointDto() when $default != null:
return $default(_that.period,_that.average,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RatingTrendPointDto implements RatingTrendPointDto {
  const _RatingTrendPointDto({required this.period, required this.average, required this.count});
  factory _RatingTrendPointDto.fromJson(Map<String, dynamic> json) => _$RatingTrendPointDtoFromJson(json);

/// `YYYY-MM` calendar month (`SAM-GAP-8`).
@override final  String period;
@override final  double average;
@override final  int count;

/// Create a copy of RatingTrendPointDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RatingTrendPointDtoCopyWith<_RatingTrendPointDto> get copyWith => __$RatingTrendPointDtoCopyWithImpl<_RatingTrendPointDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RatingTrendPointDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RatingTrendPointDto&&(identical(other.period, period) || other.period == period)&&(identical(other.average, average) || other.average == average)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,period,average,count);

@override
String toString() {
  return 'RatingTrendPointDto(period: $period, average: $average, count: $count)';
}


}

/// @nodoc
abstract mixin class _$RatingTrendPointDtoCopyWith<$Res> implements $RatingTrendPointDtoCopyWith<$Res> {
  factory _$RatingTrendPointDtoCopyWith(_RatingTrendPointDto value, $Res Function(_RatingTrendPointDto) _then) = __$RatingTrendPointDtoCopyWithImpl;
@override @useResult
$Res call({
 String period, double average, int count
});




}
/// @nodoc
class __$RatingTrendPointDtoCopyWithImpl<$Res>
    implements _$RatingTrendPointDtoCopyWith<$Res> {
  __$RatingTrendPointDtoCopyWithImpl(this._self, this._then);

  final _RatingTrendPointDto _self;
  final $Res Function(_RatingTrendPointDto) _then;

/// Create a copy of RatingTrendPointDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = null,Object? average = null,Object? count = null,}) {
  return _then(_RatingTrendPointDto(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,average: null == average ? _self.average : average // ignore: cast_nullable_to_non_nullable
as double,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PerformanceOutcomeDto {

 String get state; int get count;
/// Create a copy of PerformanceOutcomeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PerformanceOutcomeDtoCopyWith<PerformanceOutcomeDto> get copyWith => _$PerformanceOutcomeDtoCopyWithImpl<PerformanceOutcomeDto>(this as PerformanceOutcomeDto, _$identity);

  /// Serializes this PerformanceOutcomeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PerformanceOutcomeDto&&(identical(other.state, state) || other.state == state)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,state,count);

@override
String toString() {
  return 'PerformanceOutcomeDto(state: $state, count: $count)';
}


}

/// @nodoc
abstract mixin class $PerformanceOutcomeDtoCopyWith<$Res>  {
  factory $PerformanceOutcomeDtoCopyWith(PerformanceOutcomeDto value, $Res Function(PerformanceOutcomeDto) _then) = _$PerformanceOutcomeDtoCopyWithImpl;
@useResult
$Res call({
 String state, int count
});




}
/// @nodoc
class _$PerformanceOutcomeDtoCopyWithImpl<$Res>
    implements $PerformanceOutcomeDtoCopyWith<$Res> {
  _$PerformanceOutcomeDtoCopyWithImpl(this._self, this._then);

  final PerformanceOutcomeDto _self;
  final $Res Function(PerformanceOutcomeDto) _then;

/// Create a copy of PerformanceOutcomeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? state = null,Object? count = null,}) {
  return _then(_self.copyWith(
state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PerformanceOutcomeDto].
extension PerformanceOutcomeDtoPatterns on PerformanceOutcomeDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PerformanceOutcomeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PerformanceOutcomeDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PerformanceOutcomeDto value)  $default,){
final _that = this;
switch (_that) {
case _PerformanceOutcomeDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PerformanceOutcomeDto value)?  $default,){
final _that = this;
switch (_that) {
case _PerformanceOutcomeDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String state,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PerformanceOutcomeDto() when $default != null:
return $default(_that.state,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String state,  int count)  $default,) {final _that = this;
switch (_that) {
case _PerformanceOutcomeDto():
return $default(_that.state,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String state,  int count)?  $default,) {final _that = this;
switch (_that) {
case _PerformanceOutcomeDto() when $default != null:
return $default(_that.state,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PerformanceOutcomeDto implements PerformanceOutcomeDto {
  const _PerformanceOutcomeDto({required this.state, required this.count});
  factory _PerformanceOutcomeDto.fromJson(Map<String, dynamic> json) => _$PerformanceOutcomeDtoFromJson(json);

@override final  String state;
@override final  int count;

/// Create a copy of PerformanceOutcomeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PerformanceOutcomeDtoCopyWith<_PerformanceOutcomeDto> get copyWith => __$PerformanceOutcomeDtoCopyWithImpl<_PerformanceOutcomeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PerformanceOutcomeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PerformanceOutcomeDto&&(identical(other.state, state) || other.state == state)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,state,count);

@override
String toString() {
  return 'PerformanceOutcomeDto(state: $state, count: $count)';
}


}

/// @nodoc
abstract mixin class _$PerformanceOutcomeDtoCopyWith<$Res> implements $PerformanceOutcomeDtoCopyWith<$Res> {
  factory _$PerformanceOutcomeDtoCopyWith(_PerformanceOutcomeDto value, $Res Function(_PerformanceOutcomeDto) _then) = __$PerformanceOutcomeDtoCopyWithImpl;
@override @useResult
$Res call({
 String state, int count
});




}
/// @nodoc
class __$PerformanceOutcomeDtoCopyWithImpl<$Res>
    implements _$PerformanceOutcomeDtoCopyWith<$Res> {
  __$PerformanceOutcomeDtoCopyWithImpl(this._self, this._then);

  final _PerformanceOutcomeDto _self;
  final $Res Function(_PerformanceOutcomeDto) _then;

/// Create a copy of PerformanceOutcomeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? state = null,Object? count = null,}) {
  return _then(_PerformanceOutcomeDto(
state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$VendorPerformanceDto {

 int get offersSubmitted;/// Decimal string from the API (e.g. `"0.25"`).
 String get acceptanceRate; int get averageResponseMinutes; List<PerformanceOutcomeDto> get byOutcome;/// Six `{ period, average, count }` points (`CP5-A05.2`).
 List<RatingTrendPointDto> get ratingTrend;
/// Create a copy of VendorPerformanceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorPerformanceDtoCopyWith<VendorPerformanceDto> get copyWith => _$VendorPerformanceDtoCopyWithImpl<VendorPerformanceDto>(this as VendorPerformanceDto, _$identity);

  /// Serializes this VendorPerformanceDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorPerformanceDto&&(identical(other.offersSubmitted, offersSubmitted) || other.offersSubmitted == offersSubmitted)&&(identical(other.acceptanceRate, acceptanceRate) || other.acceptanceRate == acceptanceRate)&&(identical(other.averageResponseMinutes, averageResponseMinutes) || other.averageResponseMinutes == averageResponseMinutes)&&const DeepCollectionEquality().equals(other.byOutcome, byOutcome)&&const DeepCollectionEquality().equals(other.ratingTrend, ratingTrend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,offersSubmitted,acceptanceRate,averageResponseMinutes,const DeepCollectionEquality().hash(byOutcome),const DeepCollectionEquality().hash(ratingTrend));

@override
String toString() {
  return 'VendorPerformanceDto(offersSubmitted: $offersSubmitted, acceptanceRate: $acceptanceRate, averageResponseMinutes: $averageResponseMinutes, byOutcome: $byOutcome, ratingTrend: $ratingTrend)';
}


}

/// @nodoc
abstract mixin class $VendorPerformanceDtoCopyWith<$Res>  {
  factory $VendorPerformanceDtoCopyWith(VendorPerformanceDto value, $Res Function(VendorPerformanceDto) _then) = _$VendorPerformanceDtoCopyWithImpl;
@useResult
$Res call({
 int offersSubmitted, String acceptanceRate, int averageResponseMinutes, List<PerformanceOutcomeDto> byOutcome, List<RatingTrendPointDto> ratingTrend
});




}
/// @nodoc
class _$VendorPerformanceDtoCopyWithImpl<$Res>
    implements $VendorPerformanceDtoCopyWith<$Res> {
  _$VendorPerformanceDtoCopyWithImpl(this._self, this._then);

  final VendorPerformanceDto _self;
  final $Res Function(VendorPerformanceDto) _then;

/// Create a copy of VendorPerformanceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? offersSubmitted = null,Object? acceptanceRate = null,Object? averageResponseMinutes = null,Object? byOutcome = null,Object? ratingTrend = null,}) {
  return _then(_self.copyWith(
offersSubmitted: null == offersSubmitted ? _self.offersSubmitted : offersSubmitted // ignore: cast_nullable_to_non_nullable
as int,acceptanceRate: null == acceptanceRate ? _self.acceptanceRate : acceptanceRate // ignore: cast_nullable_to_non_nullable
as String,averageResponseMinutes: null == averageResponseMinutes ? _self.averageResponseMinutes : averageResponseMinutes // ignore: cast_nullable_to_non_nullable
as int,byOutcome: null == byOutcome ? _self.byOutcome : byOutcome // ignore: cast_nullable_to_non_nullable
as List<PerformanceOutcomeDto>,ratingTrend: null == ratingTrend ? _self.ratingTrend : ratingTrend // ignore: cast_nullable_to_non_nullable
as List<RatingTrendPointDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [VendorPerformanceDto].
extension VendorPerformanceDtoPatterns on VendorPerformanceDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorPerformanceDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorPerformanceDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorPerformanceDto value)  $default,){
final _that = this;
switch (_that) {
case _VendorPerformanceDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorPerformanceDto value)?  $default,){
final _that = this;
switch (_that) {
case _VendorPerformanceDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int offersSubmitted,  String acceptanceRate,  int averageResponseMinutes,  List<PerformanceOutcomeDto> byOutcome,  List<RatingTrendPointDto> ratingTrend)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorPerformanceDto() when $default != null:
return $default(_that.offersSubmitted,_that.acceptanceRate,_that.averageResponseMinutes,_that.byOutcome,_that.ratingTrend);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int offersSubmitted,  String acceptanceRate,  int averageResponseMinutes,  List<PerformanceOutcomeDto> byOutcome,  List<RatingTrendPointDto> ratingTrend)  $default,) {final _that = this;
switch (_that) {
case _VendorPerformanceDto():
return $default(_that.offersSubmitted,_that.acceptanceRate,_that.averageResponseMinutes,_that.byOutcome,_that.ratingTrend);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int offersSubmitted,  String acceptanceRate,  int averageResponseMinutes,  List<PerformanceOutcomeDto> byOutcome,  List<RatingTrendPointDto> ratingTrend)?  $default,) {final _that = this;
switch (_that) {
case _VendorPerformanceDto() when $default != null:
return $default(_that.offersSubmitted,_that.acceptanceRate,_that.averageResponseMinutes,_that.byOutcome,_that.ratingTrend);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VendorPerformanceDto implements VendorPerformanceDto {
  const _VendorPerformanceDto({required this.offersSubmitted, required this.acceptanceRate, required this.averageResponseMinutes, final  List<PerformanceOutcomeDto> byOutcome = const <PerformanceOutcomeDto>[], final  List<RatingTrendPointDto> ratingTrend = const <RatingTrendPointDto>[]}): _byOutcome = byOutcome,_ratingTrend = ratingTrend;
  factory _VendorPerformanceDto.fromJson(Map<String, dynamic> json) => _$VendorPerformanceDtoFromJson(json);

@override final  int offersSubmitted;
/// Decimal string from the API (e.g. `"0.25"`).
@override final  String acceptanceRate;
@override final  int averageResponseMinutes;
 final  List<PerformanceOutcomeDto> _byOutcome;
@override@JsonKey() List<PerformanceOutcomeDto> get byOutcome {
  if (_byOutcome is EqualUnmodifiableListView) return _byOutcome;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byOutcome);
}

/// Six `{ period, average, count }` points (`CP5-A05.2`).
 final  List<RatingTrendPointDto> _ratingTrend;
/// Six `{ period, average, count }` points (`CP5-A05.2`).
@override@JsonKey() List<RatingTrendPointDto> get ratingTrend {
  if (_ratingTrend is EqualUnmodifiableListView) return _ratingTrend;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ratingTrend);
}


/// Create a copy of VendorPerformanceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorPerformanceDtoCopyWith<_VendorPerformanceDto> get copyWith => __$VendorPerformanceDtoCopyWithImpl<_VendorPerformanceDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VendorPerformanceDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorPerformanceDto&&(identical(other.offersSubmitted, offersSubmitted) || other.offersSubmitted == offersSubmitted)&&(identical(other.acceptanceRate, acceptanceRate) || other.acceptanceRate == acceptanceRate)&&(identical(other.averageResponseMinutes, averageResponseMinutes) || other.averageResponseMinutes == averageResponseMinutes)&&const DeepCollectionEquality().equals(other._byOutcome, _byOutcome)&&const DeepCollectionEquality().equals(other._ratingTrend, _ratingTrend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,offersSubmitted,acceptanceRate,averageResponseMinutes,const DeepCollectionEquality().hash(_byOutcome),const DeepCollectionEquality().hash(_ratingTrend));

@override
String toString() {
  return 'VendorPerformanceDto(offersSubmitted: $offersSubmitted, acceptanceRate: $acceptanceRate, averageResponseMinutes: $averageResponseMinutes, byOutcome: $byOutcome, ratingTrend: $ratingTrend)';
}


}

/// @nodoc
abstract mixin class _$VendorPerformanceDtoCopyWith<$Res> implements $VendorPerformanceDtoCopyWith<$Res> {
  factory _$VendorPerformanceDtoCopyWith(_VendorPerformanceDto value, $Res Function(_VendorPerformanceDto) _then) = __$VendorPerformanceDtoCopyWithImpl;
@override @useResult
$Res call({
 int offersSubmitted, String acceptanceRate, int averageResponseMinutes, List<PerformanceOutcomeDto> byOutcome, List<RatingTrendPointDto> ratingTrend
});




}
/// @nodoc
class __$VendorPerformanceDtoCopyWithImpl<$Res>
    implements _$VendorPerformanceDtoCopyWith<$Res> {
  __$VendorPerformanceDtoCopyWithImpl(this._self, this._then);

  final _VendorPerformanceDto _self;
  final $Res Function(_VendorPerformanceDto) _then;

/// Create a copy of VendorPerformanceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? offersSubmitted = null,Object? acceptanceRate = null,Object? averageResponseMinutes = null,Object? byOutcome = null,Object? ratingTrend = null,}) {
  return _then(_VendorPerformanceDto(
offersSubmitted: null == offersSubmitted ? _self.offersSubmitted : offersSubmitted // ignore: cast_nullable_to_non_nullable
as int,acceptanceRate: null == acceptanceRate ? _self.acceptanceRate : acceptanceRate // ignore: cast_nullable_to_non_nullable
as String,averageResponseMinutes: null == averageResponseMinutes ? _self.averageResponseMinutes : averageResponseMinutes // ignore: cast_nullable_to_non_nullable
as int,byOutcome: null == byOutcome ? _self._byOutcome : byOutcome // ignore: cast_nullable_to_non_nullable
as List<PerformanceOutcomeDto>,ratingTrend: null == ratingTrend ? _self._ratingTrend : ratingTrend // ignore: cast_nullable_to_non_nullable
as List<RatingTrendPointDto>,
  ));
}


}


/// @nodoc
mixin _$PerformanceExportDto {

 String get downloadUrl; DateTime get expiresAt;
/// Create a copy of PerformanceExportDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PerformanceExportDtoCopyWith<PerformanceExportDto> get copyWith => _$PerformanceExportDtoCopyWithImpl<PerformanceExportDto>(this as PerformanceExportDto, _$identity);

  /// Serializes this PerformanceExportDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PerformanceExportDto&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,downloadUrl,expiresAt);

@override
String toString() {
  return 'PerformanceExportDto(downloadUrl: $downloadUrl, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $PerformanceExportDtoCopyWith<$Res>  {
  factory $PerformanceExportDtoCopyWith(PerformanceExportDto value, $Res Function(PerformanceExportDto) _then) = _$PerformanceExportDtoCopyWithImpl;
@useResult
$Res call({
 String downloadUrl, DateTime expiresAt
});




}
/// @nodoc
class _$PerformanceExportDtoCopyWithImpl<$Res>
    implements $PerformanceExportDtoCopyWith<$Res> {
  _$PerformanceExportDtoCopyWithImpl(this._self, this._then);

  final PerformanceExportDto _self;
  final $Res Function(PerformanceExportDto) _then;

/// Create a copy of PerformanceExportDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? downloadUrl = null,Object? expiresAt = null,}) {
  return _then(_self.copyWith(
downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PerformanceExportDto].
extension PerformanceExportDtoPatterns on PerformanceExportDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PerformanceExportDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PerformanceExportDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PerformanceExportDto value)  $default,){
final _that = this;
switch (_that) {
case _PerformanceExportDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PerformanceExportDto value)?  $default,){
final _that = this;
switch (_that) {
case _PerformanceExportDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String downloadUrl,  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PerformanceExportDto() when $default != null:
return $default(_that.downloadUrl,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String downloadUrl,  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _PerformanceExportDto():
return $default(_that.downloadUrl,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String downloadUrl,  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _PerformanceExportDto() when $default != null:
return $default(_that.downloadUrl,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PerformanceExportDto implements PerformanceExportDto {
  const _PerformanceExportDto({required this.downloadUrl, required this.expiresAt});
  factory _PerformanceExportDto.fromJson(Map<String, dynamic> json) => _$PerformanceExportDtoFromJson(json);

@override final  String downloadUrl;
@override final  DateTime expiresAt;

/// Create a copy of PerformanceExportDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PerformanceExportDtoCopyWith<_PerformanceExportDto> get copyWith => __$PerformanceExportDtoCopyWithImpl<_PerformanceExportDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PerformanceExportDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PerformanceExportDto&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,downloadUrl,expiresAt);

@override
String toString() {
  return 'PerformanceExportDto(downloadUrl: $downloadUrl, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$PerformanceExportDtoCopyWith<$Res> implements $PerformanceExportDtoCopyWith<$Res> {
  factory _$PerformanceExportDtoCopyWith(_PerformanceExportDto value, $Res Function(_PerformanceExportDto) _then) = __$PerformanceExportDtoCopyWithImpl;
@override @useResult
$Res call({
 String downloadUrl, DateTime expiresAt
});




}
/// @nodoc
class __$PerformanceExportDtoCopyWithImpl<$Res>
    implements _$PerformanceExportDtoCopyWith<$Res> {
  __$PerformanceExportDtoCopyWithImpl(this._self, this._then);

  final _PerformanceExportDto _self;
  final $Res Function(_PerformanceExportDto) _then;

/// Create a copy of PerformanceExportDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? downloadUrl = null,Object? expiresAt = null,}) {
  return _then(_PerformanceExportDto(
downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
