// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offer_list_filters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OfferListFilters {

 OfferState? get state; RequestType? get requestType; String get query; String? get vendorId; DateTime? get dateFrom; DateTime? get dateTo; double? get minPrice; double? get maxPrice;
/// Create a copy of OfferListFilters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferListFiltersCopyWith<OfferListFilters> get copyWith => _$OfferListFiltersCopyWithImpl<OfferListFilters>(this as OfferListFilters, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferListFilters&&(identical(other.state, state) || other.state == state)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.query, query) || other.query == query)&&(identical(other.vendorId, vendorId) || other.vendorId == vendorId)&&(identical(other.dateFrom, dateFrom) || other.dateFrom == dateFrom)&&(identical(other.dateTo, dateTo) || other.dateTo == dateTo)&&(identical(other.minPrice, minPrice) || other.minPrice == minPrice)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice));
}


@override
int get hashCode => Object.hash(runtimeType,state,requestType,query,vendorId,dateFrom,dateTo,minPrice,maxPrice);

@override
String toString() {
  return 'OfferListFilters(state: $state, requestType: $requestType, query: $query, vendorId: $vendorId, dateFrom: $dateFrom, dateTo: $dateTo, minPrice: $minPrice, maxPrice: $maxPrice)';
}


}

/// @nodoc
abstract mixin class $OfferListFiltersCopyWith<$Res>  {
  factory $OfferListFiltersCopyWith(OfferListFilters value, $Res Function(OfferListFilters) _then) = _$OfferListFiltersCopyWithImpl;
@useResult
$Res call({
 OfferState? state, RequestType? requestType, String query, String? vendorId, DateTime? dateFrom, DateTime? dateTo, double? minPrice, double? maxPrice
});




}
/// @nodoc
class _$OfferListFiltersCopyWithImpl<$Res>
    implements $OfferListFiltersCopyWith<$Res> {
  _$OfferListFiltersCopyWithImpl(this._self, this._then);

  final OfferListFilters _self;
  final $Res Function(OfferListFilters) _then;

/// Create a copy of OfferListFilters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? state = freezed,Object? requestType = freezed,Object? query = null,Object? vendorId = freezed,Object? dateFrom = freezed,Object? dateTo = freezed,Object? minPrice = freezed,Object? maxPrice = freezed,}) {
  return _then(_self.copyWith(
state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OfferState?,requestType: freezed == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as RequestType?,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,vendorId: freezed == vendorId ? _self.vendorId : vendorId // ignore: cast_nullable_to_non_nullable
as String?,dateFrom: freezed == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,dateTo: freezed == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as DateTime?,minPrice: freezed == minPrice ? _self.minPrice : minPrice // ignore: cast_nullable_to_non_nullable
as double?,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [OfferListFilters].
extension OfferListFiltersPatterns on OfferListFilters {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferListFilters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferListFilters() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferListFilters value)  $default,){
final _that = this;
switch (_that) {
case _OfferListFilters():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferListFilters value)?  $default,){
final _that = this;
switch (_that) {
case _OfferListFilters() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OfferState? state,  RequestType? requestType,  String query,  String? vendorId,  DateTime? dateFrom,  DateTime? dateTo,  double? minPrice,  double? maxPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferListFilters() when $default != null:
return $default(_that.state,_that.requestType,_that.query,_that.vendorId,_that.dateFrom,_that.dateTo,_that.minPrice,_that.maxPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OfferState? state,  RequestType? requestType,  String query,  String? vendorId,  DateTime? dateFrom,  DateTime? dateTo,  double? minPrice,  double? maxPrice)  $default,) {final _that = this;
switch (_that) {
case _OfferListFilters():
return $default(_that.state,_that.requestType,_that.query,_that.vendorId,_that.dateFrom,_that.dateTo,_that.minPrice,_that.maxPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OfferState? state,  RequestType? requestType,  String query,  String? vendorId,  DateTime? dateFrom,  DateTime? dateTo,  double? minPrice,  double? maxPrice)?  $default,) {final _that = this;
switch (_that) {
case _OfferListFilters() when $default != null:
return $default(_that.state,_that.requestType,_that.query,_that.vendorId,_that.dateFrom,_that.dateTo,_that.minPrice,_that.maxPrice);case _:
  return null;

}
}

}

/// @nodoc


class _OfferListFilters implements OfferListFilters {
  const _OfferListFilters({this.state, this.requestType, this.query = '', this.vendorId, this.dateFrom, this.dateTo, this.minPrice, this.maxPrice});
  

@override final  OfferState? state;
@override final  RequestType? requestType;
@override@JsonKey() final  String query;
@override final  String? vendorId;
@override final  DateTime? dateFrom;
@override final  DateTime? dateTo;
@override final  double? minPrice;
@override final  double? maxPrice;

/// Create a copy of OfferListFilters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferListFiltersCopyWith<_OfferListFilters> get copyWith => __$OfferListFiltersCopyWithImpl<_OfferListFilters>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferListFilters&&(identical(other.state, state) || other.state == state)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.query, query) || other.query == query)&&(identical(other.vendorId, vendorId) || other.vendorId == vendorId)&&(identical(other.dateFrom, dateFrom) || other.dateFrom == dateFrom)&&(identical(other.dateTo, dateTo) || other.dateTo == dateTo)&&(identical(other.minPrice, minPrice) || other.minPrice == minPrice)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice));
}


@override
int get hashCode => Object.hash(runtimeType,state,requestType,query,vendorId,dateFrom,dateTo,minPrice,maxPrice);

@override
String toString() {
  return 'OfferListFilters(state: $state, requestType: $requestType, query: $query, vendorId: $vendorId, dateFrom: $dateFrom, dateTo: $dateTo, minPrice: $minPrice, maxPrice: $maxPrice)';
}


}

/// @nodoc
abstract mixin class _$OfferListFiltersCopyWith<$Res> implements $OfferListFiltersCopyWith<$Res> {
  factory _$OfferListFiltersCopyWith(_OfferListFilters value, $Res Function(_OfferListFilters) _then) = __$OfferListFiltersCopyWithImpl;
@override @useResult
$Res call({
 OfferState? state, RequestType? requestType, String query, String? vendorId, DateTime? dateFrom, DateTime? dateTo, double? minPrice, double? maxPrice
});




}
/// @nodoc
class __$OfferListFiltersCopyWithImpl<$Res>
    implements _$OfferListFiltersCopyWith<$Res> {
  __$OfferListFiltersCopyWithImpl(this._self, this._then);

  final _OfferListFilters _self;
  final $Res Function(_OfferListFilters) _then;

/// Create a copy of OfferListFilters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? state = freezed,Object? requestType = freezed,Object? query = null,Object? vendorId = freezed,Object? dateFrom = freezed,Object? dateTo = freezed,Object? minPrice = freezed,Object? maxPrice = freezed,}) {
  return _then(_OfferListFilters(
state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OfferState?,requestType: freezed == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as RequestType?,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,vendorId: freezed == vendorId ? _self.vendorId : vendorId // ignore: cast_nullable_to_non_nullable
as String?,dateFrom: freezed == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,dateTo: freezed == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as DateTime?,minPrice: freezed == minPrice ? _self.minPrice : minPrice // ignore: cast_nullable_to_non_nullable
as double?,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
