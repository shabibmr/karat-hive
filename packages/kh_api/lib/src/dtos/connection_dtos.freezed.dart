// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TalkDto {

 bool get available; String get waUrl; String get phone; String get callUrl;
/// Create a copy of TalkDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TalkDtoCopyWith<TalkDto> get copyWith => _$TalkDtoCopyWithImpl<TalkDto>(this as TalkDto, _$identity);

  /// Serializes this TalkDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TalkDto&&(identical(other.available, available) || other.available == available)&&(identical(other.waUrl, waUrl) || other.waUrl == waUrl)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.callUrl, callUrl) || other.callUrl == callUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,available,waUrl,phone,callUrl);

@override
String toString() {
  return 'TalkDto(available: $available, waUrl: $waUrl, phone: $phone, callUrl: $callUrl)';
}


}

/// @nodoc
abstract mixin class $TalkDtoCopyWith<$Res>  {
  factory $TalkDtoCopyWith(TalkDto value, $Res Function(TalkDto) _then) = _$TalkDtoCopyWithImpl;
@useResult
$Res call({
 bool available, String waUrl, String phone, String callUrl
});




}
/// @nodoc
class _$TalkDtoCopyWithImpl<$Res>
    implements $TalkDtoCopyWith<$Res> {
  _$TalkDtoCopyWithImpl(this._self, this._then);

  final TalkDto _self;
  final $Res Function(TalkDto) _then;

/// Create a copy of TalkDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? available = null,Object? waUrl = null,Object? phone = null,Object? callUrl = null,}) {
  return _then(_self.copyWith(
available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,waUrl: null == waUrl ? _self.waUrl : waUrl // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,callUrl: null == callUrl ? _self.callUrl : callUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TalkDto].
extension TalkDtoPatterns on TalkDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TalkDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TalkDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TalkDto value)  $default,){
final _that = this;
switch (_that) {
case _TalkDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TalkDto value)?  $default,){
final _that = this;
switch (_that) {
case _TalkDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool available,  String waUrl,  String phone,  String callUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TalkDto() when $default != null:
return $default(_that.available,_that.waUrl,_that.phone,_that.callUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool available,  String waUrl,  String phone,  String callUrl)  $default,) {final _that = this;
switch (_that) {
case _TalkDto():
return $default(_that.available,_that.waUrl,_that.phone,_that.callUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool available,  String waUrl,  String phone,  String callUrl)?  $default,) {final _that = this;
switch (_that) {
case _TalkDto() when $default != null:
return $default(_that.available,_that.waUrl,_that.phone,_that.callUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TalkDto implements TalkDto {
  const _TalkDto({required this.available, required this.waUrl, required this.phone, required this.callUrl});
  factory _TalkDto.fromJson(Map<String, dynamic> json) => _$TalkDtoFromJson(json);

@override final  bool available;
@override final  String waUrl;
@override final  String phone;
@override final  String callUrl;

/// Create a copy of TalkDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TalkDtoCopyWith<_TalkDto> get copyWith => __$TalkDtoCopyWithImpl<_TalkDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TalkDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TalkDto&&(identical(other.available, available) || other.available == available)&&(identical(other.waUrl, waUrl) || other.waUrl == waUrl)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.callUrl, callUrl) || other.callUrl == callUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,available,waUrl,phone,callUrl);

@override
String toString() {
  return 'TalkDto(available: $available, waUrl: $waUrl, phone: $phone, callUrl: $callUrl)';
}


}

/// @nodoc
abstract mixin class _$TalkDtoCopyWith<$Res> implements $TalkDtoCopyWith<$Res> {
  factory _$TalkDtoCopyWith(_TalkDto value, $Res Function(_TalkDto) _then) = __$TalkDtoCopyWithImpl;
@override @useResult
$Res call({
 bool available, String waUrl, String phone, String callUrl
});




}
/// @nodoc
class __$TalkDtoCopyWithImpl<$Res>
    implements _$TalkDtoCopyWith<$Res> {
  __$TalkDtoCopyWithImpl(this._self, this._then);

  final _TalkDto _self;
  final $Res Function(_TalkDto) _then;

/// Create a copy of TalkDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? available = null,Object? waUrl = null,Object? phone = null,Object? callUrl = null,}) {
  return _then(_TalkDto(
available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,waUrl: null == waUrl ? _self.waUrl : waUrl // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,callUrl: null == callUrl ? _self.callUrl : callUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RevealedVendorDto {

 String get id; String get legalBusinessName; String get tradingName; String get tradeLicenceNumber; String get phone; int get connectionCount; RegionSummaryDto? get region; RatingSummaryDto? get rating;
/// Create a copy of RevealedVendorDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevealedVendorDtoCopyWith<RevealedVendorDto> get copyWith => _$RevealedVendorDtoCopyWithImpl<RevealedVendorDto>(this as RevealedVendorDto, _$identity);

  /// Serializes this RevealedVendorDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevealedVendorDto&&(identical(other.id, id) || other.id == id)&&(identical(other.legalBusinessName, legalBusinessName) || other.legalBusinessName == legalBusinessName)&&(identical(other.tradingName, tradingName) || other.tradingName == tradingName)&&(identical(other.tradeLicenceNumber, tradeLicenceNumber) || other.tradeLicenceNumber == tradeLicenceNumber)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.connectionCount, connectionCount) || other.connectionCount == connectionCount)&&(identical(other.region, region) || other.region == region)&&(identical(other.rating, rating) || other.rating == rating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,legalBusinessName,tradingName,tradeLicenceNumber,phone,connectionCount,region,rating);

@override
String toString() {
  return 'RevealedVendorDto(id: $id, legalBusinessName: $legalBusinessName, tradingName: $tradingName, tradeLicenceNumber: $tradeLicenceNumber, phone: $phone, connectionCount: $connectionCount, region: $region, rating: $rating)';
}


}

/// @nodoc
abstract mixin class $RevealedVendorDtoCopyWith<$Res>  {
  factory $RevealedVendorDtoCopyWith(RevealedVendorDto value, $Res Function(RevealedVendorDto) _then) = _$RevealedVendorDtoCopyWithImpl;
@useResult
$Res call({
 String id, String legalBusinessName, String tradingName, String tradeLicenceNumber, String phone, int connectionCount, RegionSummaryDto? region, RatingSummaryDto? rating
});


$RegionSummaryDtoCopyWith<$Res>? get region;$RatingSummaryDtoCopyWith<$Res>? get rating;

}
/// @nodoc
class _$RevealedVendorDtoCopyWithImpl<$Res>
    implements $RevealedVendorDtoCopyWith<$Res> {
  _$RevealedVendorDtoCopyWithImpl(this._self, this._then);

  final RevealedVendorDto _self;
  final $Res Function(RevealedVendorDto) _then;

/// Create a copy of RevealedVendorDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? legalBusinessName = null,Object? tradingName = null,Object? tradeLicenceNumber = null,Object? phone = null,Object? connectionCount = null,Object? region = freezed,Object? rating = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,legalBusinessName: null == legalBusinessName ? _self.legalBusinessName : legalBusinessName // ignore: cast_nullable_to_non_nullable
as String,tradingName: null == tradingName ? _self.tradingName : tradingName // ignore: cast_nullable_to_non_nullable
as String,tradeLicenceNumber: null == tradeLicenceNumber ? _self.tradeLicenceNumber : tradeLicenceNumber // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,connectionCount: null == connectionCount ? _self.connectionCount : connectionCount // ignore: cast_nullable_to_non_nullable
as int,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as RegionSummaryDto?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as RatingSummaryDto?,
  ));
}
/// Create a copy of RevealedVendorDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegionSummaryDtoCopyWith<$Res>? get region {
    if (_self.region == null) {
    return null;
  }

  return $RegionSummaryDtoCopyWith<$Res>(_self.region!, (value) {
    return _then(_self.copyWith(region: value));
  });
}/// Create a copy of RevealedVendorDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatingSummaryDtoCopyWith<$Res>? get rating {
    if (_self.rating == null) {
    return null;
  }

  return $RatingSummaryDtoCopyWith<$Res>(_self.rating!, (value) {
    return _then(_self.copyWith(rating: value));
  });
}
}


/// Adds pattern-matching-related methods to [RevealedVendorDto].
extension RevealedVendorDtoPatterns on RevealedVendorDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevealedVendorDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevealedVendorDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevealedVendorDto value)  $default,){
final _that = this;
switch (_that) {
case _RevealedVendorDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevealedVendorDto value)?  $default,){
final _that = this;
switch (_that) {
case _RevealedVendorDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String legalBusinessName,  String tradingName,  String tradeLicenceNumber,  String phone,  int connectionCount,  RegionSummaryDto? region,  RatingSummaryDto? rating)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RevealedVendorDto() when $default != null:
return $default(_that.id,_that.legalBusinessName,_that.tradingName,_that.tradeLicenceNumber,_that.phone,_that.connectionCount,_that.region,_that.rating);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String legalBusinessName,  String tradingName,  String tradeLicenceNumber,  String phone,  int connectionCount,  RegionSummaryDto? region,  RatingSummaryDto? rating)  $default,) {final _that = this;
switch (_that) {
case _RevealedVendorDto():
return $default(_that.id,_that.legalBusinessName,_that.tradingName,_that.tradeLicenceNumber,_that.phone,_that.connectionCount,_that.region,_that.rating);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String legalBusinessName,  String tradingName,  String tradeLicenceNumber,  String phone,  int connectionCount,  RegionSummaryDto? region,  RatingSummaryDto? rating)?  $default,) {final _that = this;
switch (_that) {
case _RevealedVendorDto() when $default != null:
return $default(_that.id,_that.legalBusinessName,_that.tradingName,_that.tradeLicenceNumber,_that.phone,_that.connectionCount,_that.region,_that.rating);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RevealedVendorDto implements RevealedVendorDto {
  const _RevealedVendorDto({required this.id, required this.legalBusinessName, required this.tradingName, required this.tradeLicenceNumber, required this.phone, required this.connectionCount, this.region, this.rating});
  factory _RevealedVendorDto.fromJson(Map<String, dynamic> json) => _$RevealedVendorDtoFromJson(json);

@override final  String id;
@override final  String legalBusinessName;
@override final  String tradingName;
@override final  String tradeLicenceNumber;
@override final  String phone;
@override final  int connectionCount;
@override final  RegionSummaryDto? region;
@override final  RatingSummaryDto? rating;

/// Create a copy of RevealedVendorDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevealedVendorDtoCopyWith<_RevealedVendorDto> get copyWith => __$RevealedVendorDtoCopyWithImpl<_RevealedVendorDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RevealedVendorDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevealedVendorDto&&(identical(other.id, id) || other.id == id)&&(identical(other.legalBusinessName, legalBusinessName) || other.legalBusinessName == legalBusinessName)&&(identical(other.tradingName, tradingName) || other.tradingName == tradingName)&&(identical(other.tradeLicenceNumber, tradeLicenceNumber) || other.tradeLicenceNumber == tradeLicenceNumber)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.connectionCount, connectionCount) || other.connectionCount == connectionCount)&&(identical(other.region, region) || other.region == region)&&(identical(other.rating, rating) || other.rating == rating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,legalBusinessName,tradingName,tradeLicenceNumber,phone,connectionCount,region,rating);

@override
String toString() {
  return 'RevealedVendorDto(id: $id, legalBusinessName: $legalBusinessName, tradingName: $tradingName, tradeLicenceNumber: $tradeLicenceNumber, phone: $phone, connectionCount: $connectionCount, region: $region, rating: $rating)';
}


}

/// @nodoc
abstract mixin class _$RevealedVendorDtoCopyWith<$Res> implements $RevealedVendorDtoCopyWith<$Res> {
  factory _$RevealedVendorDtoCopyWith(_RevealedVendorDto value, $Res Function(_RevealedVendorDto) _then) = __$RevealedVendorDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String legalBusinessName, String tradingName, String tradeLicenceNumber, String phone, int connectionCount, RegionSummaryDto? region, RatingSummaryDto? rating
});


@override $RegionSummaryDtoCopyWith<$Res>? get region;@override $RatingSummaryDtoCopyWith<$Res>? get rating;

}
/// @nodoc
class __$RevealedVendorDtoCopyWithImpl<$Res>
    implements _$RevealedVendorDtoCopyWith<$Res> {
  __$RevealedVendorDtoCopyWithImpl(this._self, this._then);

  final _RevealedVendorDto _self;
  final $Res Function(_RevealedVendorDto) _then;

/// Create a copy of RevealedVendorDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? legalBusinessName = null,Object? tradingName = null,Object? tradeLicenceNumber = null,Object? phone = null,Object? connectionCount = null,Object? region = freezed,Object? rating = freezed,}) {
  return _then(_RevealedVendorDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,legalBusinessName: null == legalBusinessName ? _self.legalBusinessName : legalBusinessName // ignore: cast_nullable_to_non_nullable
as String,tradingName: null == tradingName ? _self.tradingName : tradingName // ignore: cast_nullable_to_non_nullable
as String,tradeLicenceNumber: null == tradeLicenceNumber ? _self.tradeLicenceNumber : tradeLicenceNumber // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,connectionCount: null == connectionCount ? _self.connectionCount : connectionCount // ignore: cast_nullable_to_non_nullable
as int,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as RegionSummaryDto?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as RatingSummaryDto?,
  ));
}

/// Create a copy of RevealedVendorDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegionSummaryDtoCopyWith<$Res>? get region {
    if (_self.region == null) {
    return null;
  }

  return $RegionSummaryDtoCopyWith<$Res>(_self.region!, (value) {
    return _then(_self.copyWith(region: value));
  });
}/// Create a copy of RevealedVendorDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatingSummaryDtoCopyWith<$Res>? get rating {
    if (_self.rating == null) {
    return null;
  }

  return $RatingSummaryDtoCopyWith<$Res>(_self.rating!, (value) {
    return _then(_self.copyWith(rating: value));
  });
}
}


/// @nodoc
mixin _$ConnectionOfferDto {

 String get id; String get offeredPrice; String? get makingCharges; String? get ratePerGram; int get validityHours; String? get deliveryTimeframe; String? get warrantyTerms; String? get vendorNote;
/// Create a copy of ConnectionOfferDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionOfferDtoCopyWith<ConnectionOfferDto> get copyWith => _$ConnectionOfferDtoCopyWithImpl<ConnectionOfferDto>(this as ConnectionOfferDto, _$identity);

  /// Serializes this ConnectionOfferDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionOfferDto&&(identical(other.id, id) || other.id == id)&&(identical(other.offeredPrice, offeredPrice) || other.offeredPrice == offeredPrice)&&(identical(other.makingCharges, makingCharges) || other.makingCharges == makingCharges)&&(identical(other.ratePerGram, ratePerGram) || other.ratePerGram == ratePerGram)&&(identical(other.validityHours, validityHours) || other.validityHours == validityHours)&&(identical(other.deliveryTimeframe, deliveryTimeframe) || other.deliveryTimeframe == deliveryTimeframe)&&(identical(other.warrantyTerms, warrantyTerms) || other.warrantyTerms == warrantyTerms)&&(identical(other.vendorNote, vendorNote) || other.vendorNote == vendorNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,offeredPrice,makingCharges,ratePerGram,validityHours,deliveryTimeframe,warrantyTerms,vendorNote);

@override
String toString() {
  return 'ConnectionOfferDto(id: $id, offeredPrice: $offeredPrice, makingCharges: $makingCharges, ratePerGram: $ratePerGram, validityHours: $validityHours, deliveryTimeframe: $deliveryTimeframe, warrantyTerms: $warrantyTerms, vendorNote: $vendorNote)';
}


}

/// @nodoc
abstract mixin class $ConnectionOfferDtoCopyWith<$Res>  {
  factory $ConnectionOfferDtoCopyWith(ConnectionOfferDto value, $Res Function(ConnectionOfferDto) _then) = _$ConnectionOfferDtoCopyWithImpl;
@useResult
$Res call({
 String id, String offeredPrice, String? makingCharges, String? ratePerGram, int validityHours, String? deliveryTimeframe, String? warrantyTerms, String? vendorNote
});




}
/// @nodoc
class _$ConnectionOfferDtoCopyWithImpl<$Res>
    implements $ConnectionOfferDtoCopyWith<$Res> {
  _$ConnectionOfferDtoCopyWithImpl(this._self, this._then);

  final ConnectionOfferDto _self;
  final $Res Function(ConnectionOfferDto) _then;

/// Create a copy of ConnectionOfferDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? offeredPrice = null,Object? makingCharges = freezed,Object? ratePerGram = freezed,Object? validityHours = null,Object? deliveryTimeframe = freezed,Object? warrantyTerms = freezed,Object? vendorNote = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,offeredPrice: null == offeredPrice ? _self.offeredPrice : offeredPrice // ignore: cast_nullable_to_non_nullable
as String,makingCharges: freezed == makingCharges ? _self.makingCharges : makingCharges // ignore: cast_nullable_to_non_nullable
as String?,ratePerGram: freezed == ratePerGram ? _self.ratePerGram : ratePerGram // ignore: cast_nullable_to_non_nullable
as String?,validityHours: null == validityHours ? _self.validityHours : validityHours // ignore: cast_nullable_to_non_nullable
as int,deliveryTimeframe: freezed == deliveryTimeframe ? _self.deliveryTimeframe : deliveryTimeframe // ignore: cast_nullable_to_non_nullable
as String?,warrantyTerms: freezed == warrantyTerms ? _self.warrantyTerms : warrantyTerms // ignore: cast_nullable_to_non_nullable
as String?,vendorNote: freezed == vendorNote ? _self.vendorNote : vendorNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConnectionOfferDto].
extension ConnectionOfferDtoPatterns on ConnectionOfferDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConnectionOfferDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConnectionOfferDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConnectionOfferDto value)  $default,){
final _that = this;
switch (_that) {
case _ConnectionOfferDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConnectionOfferDto value)?  $default,){
final _that = this;
switch (_that) {
case _ConnectionOfferDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String offeredPrice,  String? makingCharges,  String? ratePerGram,  int validityHours,  String? deliveryTimeframe,  String? warrantyTerms,  String? vendorNote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConnectionOfferDto() when $default != null:
return $default(_that.id,_that.offeredPrice,_that.makingCharges,_that.ratePerGram,_that.validityHours,_that.deliveryTimeframe,_that.warrantyTerms,_that.vendorNote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String offeredPrice,  String? makingCharges,  String? ratePerGram,  int validityHours,  String? deliveryTimeframe,  String? warrantyTerms,  String? vendorNote)  $default,) {final _that = this;
switch (_that) {
case _ConnectionOfferDto():
return $default(_that.id,_that.offeredPrice,_that.makingCharges,_that.ratePerGram,_that.validityHours,_that.deliveryTimeframe,_that.warrantyTerms,_that.vendorNote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String offeredPrice,  String? makingCharges,  String? ratePerGram,  int validityHours,  String? deliveryTimeframe,  String? warrantyTerms,  String? vendorNote)?  $default,) {final _that = this;
switch (_that) {
case _ConnectionOfferDto() when $default != null:
return $default(_that.id,_that.offeredPrice,_that.makingCharges,_that.ratePerGram,_that.validityHours,_that.deliveryTimeframe,_that.warrantyTerms,_that.vendorNote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConnectionOfferDto implements ConnectionOfferDto {
  const _ConnectionOfferDto({required this.id, required this.offeredPrice, this.makingCharges, this.ratePerGram, required this.validityHours, this.deliveryTimeframe, this.warrantyTerms, this.vendorNote});
  factory _ConnectionOfferDto.fromJson(Map<String, dynamic> json) => _$ConnectionOfferDtoFromJson(json);

@override final  String id;
@override final  String offeredPrice;
@override final  String? makingCharges;
@override final  String? ratePerGram;
@override final  int validityHours;
@override final  String? deliveryTimeframe;
@override final  String? warrantyTerms;
@override final  String? vendorNote;

/// Create a copy of ConnectionOfferDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectionOfferDtoCopyWith<_ConnectionOfferDto> get copyWith => __$ConnectionOfferDtoCopyWithImpl<_ConnectionOfferDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConnectionOfferDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConnectionOfferDto&&(identical(other.id, id) || other.id == id)&&(identical(other.offeredPrice, offeredPrice) || other.offeredPrice == offeredPrice)&&(identical(other.makingCharges, makingCharges) || other.makingCharges == makingCharges)&&(identical(other.ratePerGram, ratePerGram) || other.ratePerGram == ratePerGram)&&(identical(other.validityHours, validityHours) || other.validityHours == validityHours)&&(identical(other.deliveryTimeframe, deliveryTimeframe) || other.deliveryTimeframe == deliveryTimeframe)&&(identical(other.warrantyTerms, warrantyTerms) || other.warrantyTerms == warrantyTerms)&&(identical(other.vendorNote, vendorNote) || other.vendorNote == vendorNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,offeredPrice,makingCharges,ratePerGram,validityHours,deliveryTimeframe,warrantyTerms,vendorNote);

@override
String toString() {
  return 'ConnectionOfferDto(id: $id, offeredPrice: $offeredPrice, makingCharges: $makingCharges, ratePerGram: $ratePerGram, validityHours: $validityHours, deliveryTimeframe: $deliveryTimeframe, warrantyTerms: $warrantyTerms, vendorNote: $vendorNote)';
}


}

/// @nodoc
abstract mixin class _$ConnectionOfferDtoCopyWith<$Res> implements $ConnectionOfferDtoCopyWith<$Res> {
  factory _$ConnectionOfferDtoCopyWith(_ConnectionOfferDto value, $Res Function(_ConnectionOfferDto) _then) = __$ConnectionOfferDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String offeredPrice, String? makingCharges, String? ratePerGram, int validityHours, String? deliveryTimeframe, String? warrantyTerms, String? vendorNote
});




}
/// @nodoc
class __$ConnectionOfferDtoCopyWithImpl<$Res>
    implements _$ConnectionOfferDtoCopyWith<$Res> {
  __$ConnectionOfferDtoCopyWithImpl(this._self, this._then);

  final _ConnectionOfferDto _self;
  final $Res Function(_ConnectionOfferDto) _then;

/// Create a copy of ConnectionOfferDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? offeredPrice = null,Object? makingCharges = freezed,Object? ratePerGram = freezed,Object? validityHours = null,Object? deliveryTimeframe = freezed,Object? warrantyTerms = freezed,Object? vendorNote = freezed,}) {
  return _then(_ConnectionOfferDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,offeredPrice: null == offeredPrice ? _self.offeredPrice : offeredPrice // ignore: cast_nullable_to_non_nullable
as String,makingCharges: freezed == makingCharges ? _self.makingCharges : makingCharges // ignore: cast_nullable_to_non_nullable
as String?,ratePerGram: freezed == ratePerGram ? _self.ratePerGram : ratePerGram // ignore: cast_nullable_to_non_nullable
as String?,validityHours: null == validityHours ? _self.validityHours : validityHours // ignore: cast_nullable_to_non_nullable
as int,deliveryTimeframe: freezed == deliveryTimeframe ? _self.deliveryTimeframe : deliveryTimeframe // ignore: cast_nullable_to_non_nullable
as String?,warrantyTerms: freezed == warrantyTerms ? _self.warrantyTerms : warrantyTerms // ignore: cast_nullable_to_non_nullable
as String?,vendorNote: freezed == vendorNote ? _self.vendorNote : vendorNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ConnectionRequestRefDto {

 String get id; String? get reference; String get requestType; String get direction; CategorySummaryDto get category; RegionSummaryDto get region;
/// Create a copy of ConnectionRequestRefDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionRequestRefDtoCopyWith<ConnectionRequestRefDto> get copyWith => _$ConnectionRequestRefDtoCopyWithImpl<ConnectionRequestRefDto>(this as ConnectionRequestRefDto, _$identity);

  /// Serializes this ConnectionRequestRefDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionRequestRefDto&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.category, category) || other.category == category)&&(identical(other.region, region) || other.region == region));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reference,requestType,direction,category,region);

@override
String toString() {
  return 'ConnectionRequestRefDto(id: $id, reference: $reference, requestType: $requestType, direction: $direction, category: $category, region: $region)';
}


}

/// @nodoc
abstract mixin class $ConnectionRequestRefDtoCopyWith<$Res>  {
  factory $ConnectionRequestRefDtoCopyWith(ConnectionRequestRefDto value, $Res Function(ConnectionRequestRefDto) _then) = _$ConnectionRequestRefDtoCopyWithImpl;
@useResult
$Res call({
 String id, String? reference, String requestType, String direction, CategorySummaryDto category, RegionSummaryDto region
});


$CategorySummaryDtoCopyWith<$Res> get category;$RegionSummaryDtoCopyWith<$Res> get region;

}
/// @nodoc
class _$ConnectionRequestRefDtoCopyWithImpl<$Res>
    implements $ConnectionRequestRefDtoCopyWith<$Res> {
  _$ConnectionRequestRefDtoCopyWithImpl(this._self, this._then);

  final ConnectionRequestRefDto _self;
  final $Res Function(ConnectionRequestRefDto) _then;

/// Create a copy of ConnectionRequestRefDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reference = freezed,Object? requestType = null,Object? direction = null,Object? category = null,Object? region = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,requestType: null == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategorySummaryDto,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as RegionSummaryDto,
  ));
}
/// Create a copy of ConnectionRequestRefDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategorySummaryDtoCopyWith<$Res> get category {
  
  return $CategorySummaryDtoCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of ConnectionRequestRefDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegionSummaryDtoCopyWith<$Res> get region {
  
  return $RegionSummaryDtoCopyWith<$Res>(_self.region, (value) {
    return _then(_self.copyWith(region: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConnectionRequestRefDto].
extension ConnectionRequestRefDtoPatterns on ConnectionRequestRefDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConnectionRequestRefDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConnectionRequestRefDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConnectionRequestRefDto value)  $default,){
final _that = this;
switch (_that) {
case _ConnectionRequestRefDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConnectionRequestRefDto value)?  $default,){
final _that = this;
switch (_that) {
case _ConnectionRequestRefDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? reference,  String requestType,  String direction,  CategorySummaryDto category,  RegionSummaryDto region)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConnectionRequestRefDto() when $default != null:
return $default(_that.id,_that.reference,_that.requestType,_that.direction,_that.category,_that.region);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? reference,  String requestType,  String direction,  CategorySummaryDto category,  RegionSummaryDto region)  $default,) {final _that = this;
switch (_that) {
case _ConnectionRequestRefDto():
return $default(_that.id,_that.reference,_that.requestType,_that.direction,_that.category,_that.region);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? reference,  String requestType,  String direction,  CategorySummaryDto category,  RegionSummaryDto region)?  $default,) {final _that = this;
switch (_that) {
case _ConnectionRequestRefDto() when $default != null:
return $default(_that.id,_that.reference,_that.requestType,_that.direction,_that.category,_that.region);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConnectionRequestRefDto implements ConnectionRequestRefDto {
  const _ConnectionRequestRefDto({required this.id, this.reference, required this.requestType, required this.direction, required this.category, required this.region});
  factory _ConnectionRequestRefDto.fromJson(Map<String, dynamic> json) => _$ConnectionRequestRefDtoFromJson(json);

@override final  String id;
@override final  String? reference;
@override final  String requestType;
@override final  String direction;
@override final  CategorySummaryDto category;
@override final  RegionSummaryDto region;

/// Create a copy of ConnectionRequestRefDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectionRequestRefDtoCopyWith<_ConnectionRequestRefDto> get copyWith => __$ConnectionRequestRefDtoCopyWithImpl<_ConnectionRequestRefDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConnectionRequestRefDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConnectionRequestRefDto&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.category, category) || other.category == category)&&(identical(other.region, region) || other.region == region));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reference,requestType,direction,category,region);

@override
String toString() {
  return 'ConnectionRequestRefDto(id: $id, reference: $reference, requestType: $requestType, direction: $direction, category: $category, region: $region)';
}


}

/// @nodoc
abstract mixin class _$ConnectionRequestRefDtoCopyWith<$Res> implements $ConnectionRequestRefDtoCopyWith<$Res> {
  factory _$ConnectionRequestRefDtoCopyWith(_ConnectionRequestRefDto value, $Res Function(_ConnectionRequestRefDto) _then) = __$ConnectionRequestRefDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String? reference, String requestType, String direction, CategorySummaryDto category, RegionSummaryDto region
});


@override $CategorySummaryDtoCopyWith<$Res> get category;@override $RegionSummaryDtoCopyWith<$Res> get region;

}
/// @nodoc
class __$ConnectionRequestRefDtoCopyWithImpl<$Res>
    implements _$ConnectionRequestRefDtoCopyWith<$Res> {
  __$ConnectionRequestRefDtoCopyWithImpl(this._self, this._then);

  final _ConnectionRequestRefDto _self;
  final $Res Function(_ConnectionRequestRefDto) _then;

/// Create a copy of ConnectionRequestRefDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reference = freezed,Object? requestType = null,Object? direction = null,Object? category = null,Object? region = null,}) {
  return _then(_ConnectionRequestRefDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,requestType: null == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategorySummaryDto,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as RegionSummaryDto,
  ));
}

/// Create a copy of ConnectionRequestRefDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategorySummaryDtoCopyWith<$Res> get category {
  
  return $CategorySummaryDtoCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of ConnectionRequestRefDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegionSummaryDtoCopyWith<$Res> get region {
  
  return $RegionSummaryDtoCopyWith<$Res>(_self.region, (value) {
    return _then(_self.copyWith(region: value));
  });
}
}


/// @nodoc
mixin _$CustomerConnectionDto {

 String get id; String get offerId; String get requestId; String get state; DateTime get identityRevealedAt; DateTime? get closedAt; String? get closedBy; RevealedVendorDto get vendor; ConnectionOfferDto get offer; ConnectionRequestRefDto get request; TalkDto get talk;
/// Create a copy of CustomerConnectionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerConnectionDtoCopyWith<CustomerConnectionDto> get copyWith => _$CustomerConnectionDtoCopyWithImpl<CustomerConnectionDto>(this as CustomerConnectionDto, _$identity);

  /// Serializes this CustomerConnectionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerConnectionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.state, state) || other.state == state)&&(identical(other.identityRevealedAt, identityRevealedAt) || other.identityRevealedAt == identityRevealedAt)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&(identical(other.closedBy, closedBy) || other.closedBy == closedBy)&&(identical(other.vendor, vendor) || other.vendor == vendor)&&(identical(other.offer, offer) || other.offer == offer)&&(identical(other.request, request) || other.request == request)&&(identical(other.talk, talk) || other.talk == talk));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,offerId,requestId,state,identityRevealedAt,closedAt,closedBy,vendor,offer,request,talk);

@override
String toString() {
  return 'CustomerConnectionDto(id: $id, offerId: $offerId, requestId: $requestId, state: $state, identityRevealedAt: $identityRevealedAt, closedAt: $closedAt, closedBy: $closedBy, vendor: $vendor, offer: $offer, request: $request, talk: $talk)';
}


}

/// @nodoc
abstract mixin class $CustomerConnectionDtoCopyWith<$Res>  {
  factory $CustomerConnectionDtoCopyWith(CustomerConnectionDto value, $Res Function(CustomerConnectionDto) _then) = _$CustomerConnectionDtoCopyWithImpl;
@useResult
$Res call({
 String id, String offerId, String requestId, String state, DateTime identityRevealedAt, DateTime? closedAt, String? closedBy, RevealedVendorDto vendor, ConnectionOfferDto offer, ConnectionRequestRefDto request, TalkDto talk
});


$RevealedVendorDtoCopyWith<$Res> get vendor;$ConnectionOfferDtoCopyWith<$Res> get offer;$ConnectionRequestRefDtoCopyWith<$Res> get request;$TalkDtoCopyWith<$Res> get talk;

}
/// @nodoc
class _$CustomerConnectionDtoCopyWithImpl<$Res>
    implements $CustomerConnectionDtoCopyWith<$Res> {
  _$CustomerConnectionDtoCopyWithImpl(this._self, this._then);

  final CustomerConnectionDto _self;
  final $Res Function(CustomerConnectionDto) _then;

/// Create a copy of CustomerConnectionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? offerId = null,Object? requestId = null,Object? state = null,Object? identityRevealedAt = null,Object? closedAt = freezed,Object? closedBy = freezed,Object? vendor = null,Object? offer = null,Object? request = null,Object? talk = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,offerId: null == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,identityRevealedAt: null == identityRevealedAt ? _self.identityRevealedAt : identityRevealedAt // ignore: cast_nullable_to_non_nullable
as DateTime,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,closedBy: freezed == closedBy ? _self.closedBy : closedBy // ignore: cast_nullable_to_non_nullable
as String?,vendor: null == vendor ? _self.vendor : vendor // ignore: cast_nullable_to_non_nullable
as RevealedVendorDto,offer: null == offer ? _self.offer : offer // ignore: cast_nullable_to_non_nullable
as ConnectionOfferDto,request: null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as ConnectionRequestRefDto,talk: null == talk ? _self.talk : talk // ignore: cast_nullable_to_non_nullable
as TalkDto,
  ));
}
/// Create a copy of CustomerConnectionDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RevealedVendorDtoCopyWith<$Res> get vendor {
  
  return $RevealedVendorDtoCopyWith<$Res>(_self.vendor, (value) {
    return _then(_self.copyWith(vendor: value));
  });
}/// Create a copy of CustomerConnectionDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConnectionOfferDtoCopyWith<$Res> get offer {
  
  return $ConnectionOfferDtoCopyWith<$Res>(_self.offer, (value) {
    return _then(_self.copyWith(offer: value));
  });
}/// Create a copy of CustomerConnectionDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConnectionRequestRefDtoCopyWith<$Res> get request {
  
  return $ConnectionRequestRefDtoCopyWith<$Res>(_self.request, (value) {
    return _then(_self.copyWith(request: value));
  });
}/// Create a copy of CustomerConnectionDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TalkDtoCopyWith<$Res> get talk {
  
  return $TalkDtoCopyWith<$Res>(_self.talk, (value) {
    return _then(_self.copyWith(talk: value));
  });
}
}


/// Adds pattern-matching-related methods to [CustomerConnectionDto].
extension CustomerConnectionDtoPatterns on CustomerConnectionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerConnectionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerConnectionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerConnectionDto value)  $default,){
final _that = this;
switch (_that) {
case _CustomerConnectionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerConnectionDto value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerConnectionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String offerId,  String requestId,  String state,  DateTime identityRevealedAt,  DateTime? closedAt,  String? closedBy,  RevealedVendorDto vendor,  ConnectionOfferDto offer,  ConnectionRequestRefDto request,  TalkDto talk)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerConnectionDto() when $default != null:
return $default(_that.id,_that.offerId,_that.requestId,_that.state,_that.identityRevealedAt,_that.closedAt,_that.closedBy,_that.vendor,_that.offer,_that.request,_that.talk);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String offerId,  String requestId,  String state,  DateTime identityRevealedAt,  DateTime? closedAt,  String? closedBy,  RevealedVendorDto vendor,  ConnectionOfferDto offer,  ConnectionRequestRefDto request,  TalkDto talk)  $default,) {final _that = this;
switch (_that) {
case _CustomerConnectionDto():
return $default(_that.id,_that.offerId,_that.requestId,_that.state,_that.identityRevealedAt,_that.closedAt,_that.closedBy,_that.vendor,_that.offer,_that.request,_that.talk);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String offerId,  String requestId,  String state,  DateTime identityRevealedAt,  DateTime? closedAt,  String? closedBy,  RevealedVendorDto vendor,  ConnectionOfferDto offer,  ConnectionRequestRefDto request,  TalkDto talk)?  $default,) {final _that = this;
switch (_that) {
case _CustomerConnectionDto() when $default != null:
return $default(_that.id,_that.offerId,_that.requestId,_that.state,_that.identityRevealedAt,_that.closedAt,_that.closedBy,_that.vendor,_that.offer,_that.request,_that.talk);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomerConnectionDto implements CustomerConnectionDto {
  const _CustomerConnectionDto({required this.id, required this.offerId, required this.requestId, required this.state, required this.identityRevealedAt, this.closedAt, this.closedBy, required this.vendor, required this.offer, required this.request, required this.talk});
  factory _CustomerConnectionDto.fromJson(Map<String, dynamic> json) => _$CustomerConnectionDtoFromJson(json);

@override final  String id;
@override final  String offerId;
@override final  String requestId;
@override final  String state;
@override final  DateTime identityRevealedAt;
@override final  DateTime? closedAt;
@override final  String? closedBy;
@override final  RevealedVendorDto vendor;
@override final  ConnectionOfferDto offer;
@override final  ConnectionRequestRefDto request;
@override final  TalkDto talk;

/// Create a copy of CustomerConnectionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerConnectionDtoCopyWith<_CustomerConnectionDto> get copyWith => __$CustomerConnectionDtoCopyWithImpl<_CustomerConnectionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomerConnectionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerConnectionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.state, state) || other.state == state)&&(identical(other.identityRevealedAt, identityRevealedAt) || other.identityRevealedAt == identityRevealedAt)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&(identical(other.closedBy, closedBy) || other.closedBy == closedBy)&&(identical(other.vendor, vendor) || other.vendor == vendor)&&(identical(other.offer, offer) || other.offer == offer)&&(identical(other.request, request) || other.request == request)&&(identical(other.talk, talk) || other.talk == talk));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,offerId,requestId,state,identityRevealedAt,closedAt,closedBy,vendor,offer,request,talk);

@override
String toString() {
  return 'CustomerConnectionDto(id: $id, offerId: $offerId, requestId: $requestId, state: $state, identityRevealedAt: $identityRevealedAt, closedAt: $closedAt, closedBy: $closedBy, vendor: $vendor, offer: $offer, request: $request, talk: $talk)';
}


}

/// @nodoc
abstract mixin class _$CustomerConnectionDtoCopyWith<$Res> implements $CustomerConnectionDtoCopyWith<$Res> {
  factory _$CustomerConnectionDtoCopyWith(_CustomerConnectionDto value, $Res Function(_CustomerConnectionDto) _then) = __$CustomerConnectionDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String offerId, String requestId, String state, DateTime identityRevealedAt, DateTime? closedAt, String? closedBy, RevealedVendorDto vendor, ConnectionOfferDto offer, ConnectionRequestRefDto request, TalkDto talk
});


@override $RevealedVendorDtoCopyWith<$Res> get vendor;@override $ConnectionOfferDtoCopyWith<$Res> get offer;@override $ConnectionRequestRefDtoCopyWith<$Res> get request;@override $TalkDtoCopyWith<$Res> get talk;

}
/// @nodoc
class __$CustomerConnectionDtoCopyWithImpl<$Res>
    implements _$CustomerConnectionDtoCopyWith<$Res> {
  __$CustomerConnectionDtoCopyWithImpl(this._self, this._then);

  final _CustomerConnectionDto _self;
  final $Res Function(_CustomerConnectionDto) _then;

/// Create a copy of CustomerConnectionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? offerId = null,Object? requestId = null,Object? state = null,Object? identityRevealedAt = null,Object? closedAt = freezed,Object? closedBy = freezed,Object? vendor = null,Object? offer = null,Object? request = null,Object? talk = null,}) {
  return _then(_CustomerConnectionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,offerId: null == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,identityRevealedAt: null == identityRevealedAt ? _self.identityRevealedAt : identityRevealedAt // ignore: cast_nullable_to_non_nullable
as DateTime,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,closedBy: freezed == closedBy ? _self.closedBy : closedBy // ignore: cast_nullable_to_non_nullable
as String?,vendor: null == vendor ? _self.vendor : vendor // ignore: cast_nullable_to_non_nullable
as RevealedVendorDto,offer: null == offer ? _self.offer : offer // ignore: cast_nullable_to_non_nullable
as ConnectionOfferDto,request: null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as ConnectionRequestRefDto,talk: null == talk ? _self.talk : talk // ignore: cast_nullable_to_non_nullable
as TalkDto,
  ));
}

/// Create a copy of CustomerConnectionDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RevealedVendorDtoCopyWith<$Res> get vendor {
  
  return $RevealedVendorDtoCopyWith<$Res>(_self.vendor, (value) {
    return _then(_self.copyWith(vendor: value));
  });
}/// Create a copy of CustomerConnectionDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConnectionOfferDtoCopyWith<$Res> get offer {
  
  return $ConnectionOfferDtoCopyWith<$Res>(_self.offer, (value) {
    return _then(_self.copyWith(offer: value));
  });
}/// Create a copy of CustomerConnectionDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConnectionRequestRefDtoCopyWith<$Res> get request {
  
  return $ConnectionRequestRefDtoCopyWith<$Res>(_self.request, (value) {
    return _then(_self.copyWith(request: value));
  });
}/// Create a copy of CustomerConnectionDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TalkDtoCopyWith<$Res> get talk {
  
  return $TalkDtoCopyWith<$Res>(_self.talk, (value) {
    return _then(_self.copyWith(talk: value));
  });
}
}

// dart format on
