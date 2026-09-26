// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_list_filters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RequestListFilters {

 String get query; RequestType? get requestType; Direction? get direction; RequestState? get state; String? get regionId; bool get zeroOffersOnly; double? get minValue; double? get maxValue;
/// Create a copy of RequestListFilters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestListFiltersCopyWith<RequestListFilters> get copyWith => _$RequestListFiltersCopyWithImpl<RequestListFilters>(this as RequestListFilters, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestListFilters&&(identical(other.query, query) || other.query == query)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.state, state) || other.state == state)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.zeroOffersOnly, zeroOffersOnly) || other.zeroOffersOnly == zeroOffersOnly)&&(identical(other.minValue, minValue) || other.minValue == minValue)&&(identical(other.maxValue, maxValue) || other.maxValue == maxValue));
}


@override
int get hashCode => Object.hash(runtimeType,query,requestType,direction,state,regionId,zeroOffersOnly,minValue,maxValue);

@override
String toString() {
  return 'RequestListFilters(query: $query, requestType: $requestType, direction: $direction, state: $state, regionId: $regionId, zeroOffersOnly: $zeroOffersOnly, minValue: $minValue, maxValue: $maxValue)';
}


}

/// @nodoc
abstract mixin class $RequestListFiltersCopyWith<$Res>  {
  factory $RequestListFiltersCopyWith(RequestListFilters value, $Res Function(RequestListFilters) _then) = _$RequestListFiltersCopyWithImpl;
@useResult
$Res call({
 String query, RequestType? requestType, Direction? direction, RequestState? state, String? regionId, bool zeroOffersOnly, double? minValue, double? maxValue
});




}
/// @nodoc
class _$RequestListFiltersCopyWithImpl<$Res>
    implements $RequestListFiltersCopyWith<$Res> {
  _$RequestListFiltersCopyWithImpl(this._self, this._then);

  final RequestListFilters _self;
  final $Res Function(RequestListFilters) _then;

/// Create a copy of RequestListFilters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? requestType = freezed,Object? direction = freezed,Object? state = freezed,Object? regionId = freezed,Object? zeroOffersOnly = null,Object? minValue = freezed,Object? maxValue = freezed,}) {
  return _then(_self.copyWith(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,requestType: freezed == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as RequestType?,direction: freezed == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as Direction?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as RequestState?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as String?,zeroOffersOnly: null == zeroOffersOnly ? _self.zeroOffersOnly : zeroOffersOnly // ignore: cast_nullable_to_non_nullable
as bool,minValue: freezed == minValue ? _self.minValue : minValue // ignore: cast_nullable_to_non_nullable
as double?,maxValue: freezed == maxValue ? _self.maxValue : maxValue // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestListFilters].
extension RequestListFiltersPatterns on RequestListFilters {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestListFilters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestListFilters() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestListFilters value)  $default,){
final _that = this;
switch (_that) {
case _RequestListFilters():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestListFilters value)?  $default,){
final _that = this;
switch (_that) {
case _RequestListFilters() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  RequestType? requestType,  Direction? direction,  RequestState? state,  String? regionId,  bool zeroOffersOnly,  double? minValue,  double? maxValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestListFilters() when $default != null:
return $default(_that.query,_that.requestType,_that.direction,_that.state,_that.regionId,_that.zeroOffersOnly,_that.minValue,_that.maxValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  RequestType? requestType,  Direction? direction,  RequestState? state,  String? regionId,  bool zeroOffersOnly,  double? minValue,  double? maxValue)  $default,) {final _that = this;
switch (_that) {
case _RequestListFilters():
return $default(_that.query,_that.requestType,_that.direction,_that.state,_that.regionId,_that.zeroOffersOnly,_that.minValue,_that.maxValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  RequestType? requestType,  Direction? direction,  RequestState? state,  String? regionId,  bool zeroOffersOnly,  double? minValue,  double? maxValue)?  $default,) {final _that = this;
switch (_that) {
case _RequestListFilters() when $default != null:
return $default(_that.query,_that.requestType,_that.direction,_that.state,_that.regionId,_that.zeroOffersOnly,_that.minValue,_that.maxValue);case _:
  return null;

}
}

}

/// @nodoc


class _RequestListFilters implements RequestListFilters {
  const _RequestListFilters({this.query = '', this.requestType, this.direction, this.state, this.regionId, this.zeroOffersOnly = false, this.minValue, this.maxValue});
  

@override@JsonKey() final  String query;
@override final  RequestType? requestType;
@override final  Direction? direction;
@override final  RequestState? state;
@override final  String? regionId;
@override@JsonKey() final  bool zeroOffersOnly;
@override final  double? minValue;
@override final  double? maxValue;

/// Create a copy of RequestListFilters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestListFiltersCopyWith<_RequestListFilters> get copyWith => __$RequestListFiltersCopyWithImpl<_RequestListFilters>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestListFilters&&(identical(other.query, query) || other.query == query)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.state, state) || other.state == state)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.zeroOffersOnly, zeroOffersOnly) || other.zeroOffersOnly == zeroOffersOnly)&&(identical(other.minValue, minValue) || other.minValue == minValue)&&(identical(other.maxValue, maxValue) || other.maxValue == maxValue));
}


@override
int get hashCode => Object.hash(runtimeType,query,requestType,direction,state,regionId,zeroOffersOnly,minValue,maxValue);

@override
String toString() {
  return 'RequestListFilters(query: $query, requestType: $requestType, direction: $direction, state: $state, regionId: $regionId, zeroOffersOnly: $zeroOffersOnly, minValue: $minValue, maxValue: $maxValue)';
}


}

/// @nodoc
abstract mixin class _$RequestListFiltersCopyWith<$Res> implements $RequestListFiltersCopyWith<$Res> {
  factory _$RequestListFiltersCopyWith(_RequestListFilters value, $Res Function(_RequestListFilters) _then) = __$RequestListFiltersCopyWithImpl;
@override @useResult
$Res call({
 String query, RequestType? requestType, Direction? direction, RequestState? state, String? regionId, bool zeroOffersOnly, double? minValue, double? maxValue
});




}
/// @nodoc
class __$RequestListFiltersCopyWithImpl<$Res>
    implements _$RequestListFiltersCopyWith<$Res> {
  __$RequestListFiltersCopyWithImpl(this._self, this._then);

  final _RequestListFilters _self;
  final $Res Function(_RequestListFilters) _then;

/// Create a copy of RequestListFilters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? requestType = freezed,Object? direction = freezed,Object? state = freezed,Object? regionId = freezed,Object? zeroOffersOnly = null,Object? minValue = freezed,Object? maxValue = freezed,}) {
  return _then(_RequestListFilters(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,requestType: freezed == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as RequestType?,direction: freezed == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as Direction?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as RequestState?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as String?,zeroOffersOnly: null == zeroOffersOnly ? _self.zeroOffersOnly : zeroOffersOnly // ignore: cast_nullable_to_non_nullable
as bool,minValue: freezed == minValue ? _self.minValue : minValue // ignore: cast_nullable_to_non_nullable
as double?,maxValue: freezed == maxValue ? _self.maxValue : maxValue // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
