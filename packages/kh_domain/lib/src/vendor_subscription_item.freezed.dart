// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vendor_subscription_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VendorSubscriptionItem {

 String get requestType; String get state; String get priceAed; DateTime? get periodStart; DateTime? get periodEnd; DateTime? get graceEndsAt; DateTime? get renewalDate; bool get canOffer;
/// Create a copy of VendorSubscriptionItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorSubscriptionItemCopyWith<VendorSubscriptionItem> get copyWith => _$VendorSubscriptionItemCopyWithImpl<VendorSubscriptionItem>(this as VendorSubscriptionItem, _$identity);

  /// Serializes this VendorSubscriptionItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorSubscriptionItem&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.state, state) || other.state == state)&&(identical(other.priceAed, priceAed) || other.priceAed == priceAed)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.graceEndsAt, graceEndsAt) || other.graceEndsAt == graceEndsAt)&&(identical(other.renewalDate, renewalDate) || other.renewalDate == renewalDate)&&(identical(other.canOffer, canOffer) || other.canOffer == canOffer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requestType,state,priceAed,periodStart,periodEnd,graceEndsAt,renewalDate,canOffer);

@override
String toString() {
  return 'VendorSubscriptionItem(requestType: $requestType, state: $state, priceAed: $priceAed, periodStart: $periodStart, periodEnd: $periodEnd, graceEndsAt: $graceEndsAt, renewalDate: $renewalDate, canOffer: $canOffer)';
}


}

/// @nodoc
abstract mixin class $VendorSubscriptionItemCopyWith<$Res>  {
  factory $VendorSubscriptionItemCopyWith(VendorSubscriptionItem value, $Res Function(VendorSubscriptionItem) _then) = _$VendorSubscriptionItemCopyWithImpl;
@useResult
$Res call({
 String requestType, String state, String priceAed, DateTime? periodStart, DateTime? periodEnd, DateTime? graceEndsAt, DateTime? renewalDate, bool canOffer
});




}
/// @nodoc
class _$VendorSubscriptionItemCopyWithImpl<$Res>
    implements $VendorSubscriptionItemCopyWith<$Res> {
  _$VendorSubscriptionItemCopyWithImpl(this._self, this._then);

  final VendorSubscriptionItem _self;
  final $Res Function(VendorSubscriptionItem) _then;

/// Create a copy of VendorSubscriptionItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requestType = null,Object? state = null,Object? priceAed = null,Object? periodStart = freezed,Object? periodEnd = freezed,Object? graceEndsAt = freezed,Object? renewalDate = freezed,Object? canOffer = null,}) {
  return _then(_self.copyWith(
requestType: null == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,priceAed: null == priceAed ? _self.priceAed : priceAed // ignore: cast_nullable_to_non_nullable
as String,periodStart: freezed == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,graceEndsAt: freezed == graceEndsAt ? _self.graceEndsAt : graceEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,renewalDate: freezed == renewalDate ? _self.renewalDate : renewalDate // ignore: cast_nullable_to_non_nullable
as DateTime?,canOffer: null == canOffer ? _self.canOffer : canOffer // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [VendorSubscriptionItem].
extension VendorSubscriptionItemPatterns on VendorSubscriptionItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorSubscriptionItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorSubscriptionItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorSubscriptionItem value)  $default,){
final _that = this;
switch (_that) {
case _VendorSubscriptionItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorSubscriptionItem value)?  $default,){
final _that = this;
switch (_that) {
case _VendorSubscriptionItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String requestType,  String state,  String priceAed,  DateTime? periodStart,  DateTime? periodEnd,  DateTime? graceEndsAt,  DateTime? renewalDate,  bool canOffer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorSubscriptionItem() when $default != null:
return $default(_that.requestType,_that.state,_that.priceAed,_that.periodStart,_that.periodEnd,_that.graceEndsAt,_that.renewalDate,_that.canOffer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String requestType,  String state,  String priceAed,  DateTime? periodStart,  DateTime? periodEnd,  DateTime? graceEndsAt,  DateTime? renewalDate,  bool canOffer)  $default,) {final _that = this;
switch (_that) {
case _VendorSubscriptionItem():
return $default(_that.requestType,_that.state,_that.priceAed,_that.periodStart,_that.periodEnd,_that.graceEndsAt,_that.renewalDate,_that.canOffer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String requestType,  String state,  String priceAed,  DateTime? periodStart,  DateTime? periodEnd,  DateTime? graceEndsAt,  DateTime? renewalDate,  bool canOffer)?  $default,) {final _that = this;
switch (_that) {
case _VendorSubscriptionItem() when $default != null:
return $default(_that.requestType,_that.state,_that.priceAed,_that.periodStart,_that.periodEnd,_that.graceEndsAt,_that.renewalDate,_that.canOffer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VendorSubscriptionItem implements VendorSubscriptionItem {
  const _VendorSubscriptionItem({required this.requestType, required this.state, this.priceAed = '0.00', this.periodStart, this.periodEnd, this.graceEndsAt, this.renewalDate, this.canOffer = false});
  factory _VendorSubscriptionItem.fromJson(Map<String, dynamic> json) => _$VendorSubscriptionItemFromJson(json);

@override final  String requestType;
@override final  String state;
@override@JsonKey() final  String priceAed;
@override final  DateTime? periodStart;
@override final  DateTime? periodEnd;
@override final  DateTime? graceEndsAt;
@override final  DateTime? renewalDate;
@override@JsonKey() final  bool canOffer;

/// Create a copy of VendorSubscriptionItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorSubscriptionItemCopyWith<_VendorSubscriptionItem> get copyWith => __$VendorSubscriptionItemCopyWithImpl<_VendorSubscriptionItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VendorSubscriptionItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorSubscriptionItem&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.state, state) || other.state == state)&&(identical(other.priceAed, priceAed) || other.priceAed == priceAed)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.graceEndsAt, graceEndsAt) || other.graceEndsAt == graceEndsAt)&&(identical(other.renewalDate, renewalDate) || other.renewalDate == renewalDate)&&(identical(other.canOffer, canOffer) || other.canOffer == canOffer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requestType,state,priceAed,periodStart,periodEnd,graceEndsAt,renewalDate,canOffer);

@override
String toString() {
  return 'VendorSubscriptionItem(requestType: $requestType, state: $state, priceAed: $priceAed, periodStart: $periodStart, periodEnd: $periodEnd, graceEndsAt: $graceEndsAt, renewalDate: $renewalDate, canOffer: $canOffer)';
}


}

/// @nodoc
abstract mixin class _$VendorSubscriptionItemCopyWith<$Res> implements $VendorSubscriptionItemCopyWith<$Res> {
  factory _$VendorSubscriptionItemCopyWith(_VendorSubscriptionItem value, $Res Function(_VendorSubscriptionItem) _then) = __$VendorSubscriptionItemCopyWithImpl;
@override @useResult
$Res call({
 String requestType, String state, String priceAed, DateTime? periodStart, DateTime? periodEnd, DateTime? graceEndsAt, DateTime? renewalDate, bool canOffer
});




}
/// @nodoc
class __$VendorSubscriptionItemCopyWithImpl<$Res>
    implements _$VendorSubscriptionItemCopyWith<$Res> {
  __$VendorSubscriptionItemCopyWithImpl(this._self, this._then);

  final _VendorSubscriptionItem _self;
  final $Res Function(_VendorSubscriptionItem) _then;

/// Create a copy of VendorSubscriptionItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requestType = null,Object? state = null,Object? priceAed = null,Object? periodStart = freezed,Object? periodEnd = freezed,Object? graceEndsAt = freezed,Object? renewalDate = freezed,Object? canOffer = null,}) {
  return _then(_VendorSubscriptionItem(
requestType: null == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,priceAed: null == priceAed ? _self.priceAed : priceAed // ignore: cast_nullable_to_non_nullable
as String,periodStart: freezed == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime?,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,graceEndsAt: freezed == graceEndsAt ? _self.graceEndsAt : graceEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,renewalDate: freezed == renewalDate ? _self.renewalDate : renewalDate // ignore: cast_nullable_to_non_nullable
as DateTime?,canOffer: null == canOffer ? _self.canOffer : canOffer // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
