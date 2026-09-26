// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vendor_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VendorListItem {

 String get id; String get legalBusinessName; String get tradingName;@JsonKey(unknownEnumValue: VendorVerificationState.registered) VendorVerificationState get verificationState;@JsonKey(unknownEnumValue: VendorAccountState.active) VendorAccountState get accountState; String? get tradeLicenceNumber; String? get region; int? get offerCount; double? get acceptanceRate; double? get rating;@JsonKey(name: 'oldestWaitingHours') int? get waitingHours;@JsonKey(name: 'createdAt') DateTime? get registeredAt;
/// Create a copy of VendorListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorListItemCopyWith<VendorListItem> get copyWith => _$VendorListItemCopyWithImpl<VendorListItem>(this as VendorListItem, _$identity);

  /// Serializes this VendorListItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorListItem&&(identical(other.id, id) || other.id == id)&&(identical(other.legalBusinessName, legalBusinessName) || other.legalBusinessName == legalBusinessName)&&(identical(other.tradingName, tradingName) || other.tradingName == tradingName)&&(identical(other.verificationState, verificationState) || other.verificationState == verificationState)&&(identical(other.accountState, accountState) || other.accountState == accountState)&&(identical(other.tradeLicenceNumber, tradeLicenceNumber) || other.tradeLicenceNumber == tradeLicenceNumber)&&(identical(other.region, region) || other.region == region)&&(identical(other.offerCount, offerCount) || other.offerCount == offerCount)&&(identical(other.acceptanceRate, acceptanceRate) || other.acceptanceRate == acceptanceRate)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.waitingHours, waitingHours) || other.waitingHours == waitingHours)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,legalBusinessName,tradingName,verificationState,accountState,tradeLicenceNumber,region,offerCount,acceptanceRate,rating,waitingHours,registeredAt);

@override
String toString() {
  return 'VendorListItem(id: $id, legalBusinessName: $legalBusinessName, tradingName: $tradingName, verificationState: $verificationState, accountState: $accountState, tradeLicenceNumber: $tradeLicenceNumber, region: $region, offerCount: $offerCount, acceptanceRate: $acceptanceRate, rating: $rating, waitingHours: $waitingHours, registeredAt: $registeredAt)';
}


}

/// @nodoc
abstract mixin class $VendorListItemCopyWith<$Res>  {
  factory $VendorListItemCopyWith(VendorListItem value, $Res Function(VendorListItem) _then) = _$VendorListItemCopyWithImpl;
@useResult
$Res call({
 String id, String legalBusinessName, String tradingName,@JsonKey(unknownEnumValue: VendorVerificationState.registered) VendorVerificationState verificationState,@JsonKey(unknownEnumValue: VendorAccountState.active) VendorAccountState accountState, String? tradeLicenceNumber, String? region, int? offerCount, double? acceptanceRate, double? rating,@JsonKey(name: 'oldestWaitingHours') int? waitingHours,@JsonKey(name: 'createdAt') DateTime? registeredAt
});




}
/// @nodoc
class _$VendorListItemCopyWithImpl<$Res>
    implements $VendorListItemCopyWith<$Res> {
  _$VendorListItemCopyWithImpl(this._self, this._then);

  final VendorListItem _self;
  final $Res Function(VendorListItem) _then;

/// Create a copy of VendorListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? legalBusinessName = null,Object? tradingName = null,Object? verificationState = null,Object? accountState = null,Object? tradeLicenceNumber = freezed,Object? region = freezed,Object? offerCount = freezed,Object? acceptanceRate = freezed,Object? rating = freezed,Object? waitingHours = freezed,Object? registeredAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,legalBusinessName: null == legalBusinessName ? _self.legalBusinessName : legalBusinessName // ignore: cast_nullable_to_non_nullable
as String,tradingName: null == tradingName ? _self.tradingName : tradingName // ignore: cast_nullable_to_non_nullable
as String,verificationState: null == verificationState ? _self.verificationState : verificationState // ignore: cast_nullable_to_non_nullable
as VendorVerificationState,accountState: null == accountState ? _self.accountState : accountState // ignore: cast_nullable_to_non_nullable
as VendorAccountState,tradeLicenceNumber: freezed == tradeLicenceNumber ? _self.tradeLicenceNumber : tradeLicenceNumber // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,offerCount: freezed == offerCount ? _self.offerCount : offerCount // ignore: cast_nullable_to_non_nullable
as int?,acceptanceRate: freezed == acceptanceRate ? _self.acceptanceRate : acceptanceRate // ignore: cast_nullable_to_non_nullable
as double?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,waitingHours: freezed == waitingHours ? _self.waitingHours : waitingHours // ignore: cast_nullable_to_non_nullable
as int?,registeredAt: freezed == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [VendorListItem].
extension VendorListItemPatterns on VendorListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorListItem value)  $default,){
final _that = this;
switch (_that) {
case _VendorListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorListItem value)?  $default,){
final _that = this;
switch (_that) {
case _VendorListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String legalBusinessName,  String tradingName, @JsonKey(unknownEnumValue: VendorVerificationState.registered)  VendorVerificationState verificationState, @JsonKey(unknownEnumValue: VendorAccountState.active)  VendorAccountState accountState,  String? tradeLicenceNumber,  String? region,  int? offerCount,  double? acceptanceRate,  double? rating, @JsonKey(name: 'oldestWaitingHours')  int? waitingHours, @JsonKey(name: 'createdAt')  DateTime? registeredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorListItem() when $default != null:
return $default(_that.id,_that.legalBusinessName,_that.tradingName,_that.verificationState,_that.accountState,_that.tradeLicenceNumber,_that.region,_that.offerCount,_that.acceptanceRate,_that.rating,_that.waitingHours,_that.registeredAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String legalBusinessName,  String tradingName, @JsonKey(unknownEnumValue: VendorVerificationState.registered)  VendorVerificationState verificationState, @JsonKey(unknownEnumValue: VendorAccountState.active)  VendorAccountState accountState,  String? tradeLicenceNumber,  String? region,  int? offerCount,  double? acceptanceRate,  double? rating, @JsonKey(name: 'oldestWaitingHours')  int? waitingHours, @JsonKey(name: 'createdAt')  DateTime? registeredAt)  $default,) {final _that = this;
switch (_that) {
case _VendorListItem():
return $default(_that.id,_that.legalBusinessName,_that.tradingName,_that.verificationState,_that.accountState,_that.tradeLicenceNumber,_that.region,_that.offerCount,_that.acceptanceRate,_that.rating,_that.waitingHours,_that.registeredAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String legalBusinessName,  String tradingName, @JsonKey(unknownEnumValue: VendorVerificationState.registered)  VendorVerificationState verificationState, @JsonKey(unknownEnumValue: VendorAccountState.active)  VendorAccountState accountState,  String? tradeLicenceNumber,  String? region,  int? offerCount,  double? acceptanceRate,  double? rating, @JsonKey(name: 'oldestWaitingHours')  int? waitingHours, @JsonKey(name: 'createdAt')  DateTime? registeredAt)?  $default,) {final _that = this;
switch (_that) {
case _VendorListItem() when $default != null:
return $default(_that.id,_that.legalBusinessName,_that.tradingName,_that.verificationState,_that.accountState,_that.tradeLicenceNumber,_that.region,_that.offerCount,_that.acceptanceRate,_that.rating,_that.waitingHours,_that.registeredAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VendorListItem implements VendorListItem {
  const _VendorListItem({required this.id, required this.legalBusinessName, required this.tradingName, @JsonKey(unknownEnumValue: VendorVerificationState.registered) required this.verificationState, @JsonKey(unknownEnumValue: VendorAccountState.active) required this.accountState, this.tradeLicenceNumber, this.region, this.offerCount, this.acceptanceRate, this.rating, @JsonKey(name: 'oldestWaitingHours') this.waitingHours, @JsonKey(name: 'createdAt') this.registeredAt});
  factory _VendorListItem.fromJson(Map<String, dynamic> json) => _$VendorListItemFromJson(json);

@override final  String id;
@override final  String legalBusinessName;
@override final  String tradingName;
@override@JsonKey(unknownEnumValue: VendorVerificationState.registered) final  VendorVerificationState verificationState;
@override@JsonKey(unknownEnumValue: VendorAccountState.active) final  VendorAccountState accountState;
@override final  String? tradeLicenceNumber;
@override final  String? region;
@override final  int? offerCount;
@override final  double? acceptanceRate;
@override final  double? rating;
@override@JsonKey(name: 'oldestWaitingHours') final  int? waitingHours;
@override@JsonKey(name: 'createdAt') final  DateTime? registeredAt;

/// Create a copy of VendorListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorListItemCopyWith<_VendorListItem> get copyWith => __$VendorListItemCopyWithImpl<_VendorListItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VendorListItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorListItem&&(identical(other.id, id) || other.id == id)&&(identical(other.legalBusinessName, legalBusinessName) || other.legalBusinessName == legalBusinessName)&&(identical(other.tradingName, tradingName) || other.tradingName == tradingName)&&(identical(other.verificationState, verificationState) || other.verificationState == verificationState)&&(identical(other.accountState, accountState) || other.accountState == accountState)&&(identical(other.tradeLicenceNumber, tradeLicenceNumber) || other.tradeLicenceNumber == tradeLicenceNumber)&&(identical(other.region, region) || other.region == region)&&(identical(other.offerCount, offerCount) || other.offerCount == offerCount)&&(identical(other.acceptanceRate, acceptanceRate) || other.acceptanceRate == acceptanceRate)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.waitingHours, waitingHours) || other.waitingHours == waitingHours)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,legalBusinessName,tradingName,verificationState,accountState,tradeLicenceNumber,region,offerCount,acceptanceRate,rating,waitingHours,registeredAt);

@override
String toString() {
  return 'VendorListItem(id: $id, legalBusinessName: $legalBusinessName, tradingName: $tradingName, verificationState: $verificationState, accountState: $accountState, tradeLicenceNumber: $tradeLicenceNumber, region: $region, offerCount: $offerCount, acceptanceRate: $acceptanceRate, rating: $rating, waitingHours: $waitingHours, registeredAt: $registeredAt)';
}


}

/// @nodoc
abstract mixin class _$VendorListItemCopyWith<$Res> implements $VendorListItemCopyWith<$Res> {
  factory _$VendorListItemCopyWith(_VendorListItem value, $Res Function(_VendorListItem) _then) = __$VendorListItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String legalBusinessName, String tradingName,@JsonKey(unknownEnumValue: VendorVerificationState.registered) VendorVerificationState verificationState,@JsonKey(unknownEnumValue: VendorAccountState.active) VendorAccountState accountState, String? tradeLicenceNumber, String? region, int? offerCount, double? acceptanceRate, double? rating,@JsonKey(name: 'oldestWaitingHours') int? waitingHours,@JsonKey(name: 'createdAt') DateTime? registeredAt
});




}
/// @nodoc
class __$VendorListItemCopyWithImpl<$Res>
    implements _$VendorListItemCopyWith<$Res> {
  __$VendorListItemCopyWithImpl(this._self, this._then);

  final _VendorListItem _self;
  final $Res Function(_VendorListItem) _then;

/// Create a copy of VendorListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? legalBusinessName = null,Object? tradingName = null,Object? verificationState = null,Object? accountState = null,Object? tradeLicenceNumber = freezed,Object? region = freezed,Object? offerCount = freezed,Object? acceptanceRate = freezed,Object? rating = freezed,Object? waitingHours = freezed,Object? registeredAt = freezed,}) {
  return _then(_VendorListItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,legalBusinessName: null == legalBusinessName ? _self.legalBusinessName : legalBusinessName // ignore: cast_nullable_to_non_nullable
as String,tradingName: null == tradingName ? _self.tradingName : tradingName // ignore: cast_nullable_to_non_nullable
as String,verificationState: null == verificationState ? _self.verificationState : verificationState // ignore: cast_nullable_to_non_nullable
as VendorVerificationState,accountState: null == accountState ? _self.accountState : accountState // ignore: cast_nullable_to_non_nullable
as VendorAccountState,tradeLicenceNumber: freezed == tradeLicenceNumber ? _self.tradeLicenceNumber : tradeLicenceNumber // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,offerCount: freezed == offerCount ? _self.offerCount : offerCount // ignore: cast_nullable_to_non_nullable
as int?,acceptanceRate: freezed == acceptanceRate ? _self.acceptanceRate : acceptanceRate // ignore: cast_nullable_to_non_nullable
as double?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,waitingHours: freezed == waitingHours ? _self.waitingHours : waitingHours // ignore: cast_nullable_to_non_nullable
as int?,registeredAt: freezed == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
