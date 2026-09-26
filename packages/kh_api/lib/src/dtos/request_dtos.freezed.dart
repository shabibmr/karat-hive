// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CustomerRequestDto {

 String get id; String? get reference; String get requestType; String get direction; String get state; RegionSummaryDto get region; String? get notes; String? get weightGrams; bool get weightIsApproximate; String? get purityKarat; String? get ornamentType; String? get condition; String? get denominationGrams; int? get quantity; String? get mintOrRefiner; String? get budgetMin; String? get budgetMax; bool get budgetIsFlexible; String? get indicativeValue; DateTime? get publishedAt; DateTime? get expiresAt; int get offerCount; int? get unreadOfferCount; List<MediaRefDto> get media; DateTime get createdAt; DateTime get updatedAt; Map<String, dynamic>? get gemstones; String? get cancellationReason; String? get acceptedOfferId;// Deep-link target for `CUS-S10` → `CUS-S15` when `state == ACCEPTED` (`SAM-GAP-3`).
 String? get connectionId;// Nested only on `GET /v1/requests/:id` (owner presenter).
 List<CustomerOfferDto>? get offers;
/// Create a copy of CustomerRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerRequestDtoCopyWith<CustomerRequestDto> get copyWith => _$CustomerRequestDtoCopyWithImpl<CustomerRequestDto>(this as CustomerRequestDto, _$identity);

  /// Serializes this CustomerRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerRequestDto&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.state, state) || other.state == state)&&(identical(other.region, region) || other.region == region)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.weightGrams, weightGrams) || other.weightGrams == weightGrams)&&(identical(other.weightIsApproximate, weightIsApproximate) || other.weightIsApproximate == weightIsApproximate)&&(identical(other.purityKarat, purityKarat) || other.purityKarat == purityKarat)&&(identical(other.ornamentType, ornamentType) || other.ornamentType == ornamentType)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.denominationGrams, denominationGrams) || other.denominationGrams == denominationGrams)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.mintOrRefiner, mintOrRefiner) || other.mintOrRefiner == mintOrRefiner)&&(identical(other.budgetMin, budgetMin) || other.budgetMin == budgetMin)&&(identical(other.budgetMax, budgetMax) || other.budgetMax == budgetMax)&&(identical(other.budgetIsFlexible, budgetIsFlexible) || other.budgetIsFlexible == budgetIsFlexible)&&(identical(other.indicativeValue, indicativeValue) || other.indicativeValue == indicativeValue)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.offerCount, offerCount) || other.offerCount == offerCount)&&(identical(other.unreadOfferCount, unreadOfferCount) || other.unreadOfferCount == unreadOfferCount)&&const DeepCollectionEquality().equals(other.media, media)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.gemstones, gemstones)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.acceptedOfferId, acceptedOfferId) || other.acceptedOfferId == acceptedOfferId)&&(identical(other.connectionId, connectionId) || other.connectionId == connectionId)&&const DeepCollectionEquality().equals(other.offers, offers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reference,requestType,direction,state,region,notes,weightGrams,weightIsApproximate,purityKarat,ornamentType,condition,denominationGrams,quantity,mintOrRefiner,budgetMin,budgetMax,budgetIsFlexible,indicativeValue,publishedAt,expiresAt,offerCount,unreadOfferCount,const DeepCollectionEquality().hash(media),createdAt,updatedAt,const DeepCollectionEquality().hash(gemstones),cancellationReason,acceptedOfferId,connectionId,const DeepCollectionEquality().hash(offers)]);

@override
String toString() {
  return 'CustomerRequestDto(id: $id, reference: $reference, requestType: $requestType, direction: $direction, state: $state, region: $region, notes: $notes, weightGrams: $weightGrams, weightIsApproximate: $weightIsApproximate, purityKarat: $purityKarat, ornamentType: $ornamentType, condition: $condition, denominationGrams: $denominationGrams, quantity: $quantity, mintOrRefiner: $mintOrRefiner, budgetMin: $budgetMin, budgetMax: $budgetMax, budgetIsFlexible: $budgetIsFlexible, indicativeValue: $indicativeValue, publishedAt: $publishedAt, expiresAt: $expiresAt, offerCount: $offerCount, unreadOfferCount: $unreadOfferCount, media: $media, createdAt: $createdAt, updatedAt: $updatedAt, gemstones: $gemstones, cancellationReason: $cancellationReason, acceptedOfferId: $acceptedOfferId, connectionId: $connectionId, offers: $offers)';
}


}

/// @nodoc
abstract mixin class $CustomerRequestDtoCopyWith<$Res>  {
  factory $CustomerRequestDtoCopyWith(CustomerRequestDto value, $Res Function(CustomerRequestDto) _then) = _$CustomerRequestDtoCopyWithImpl;
@useResult
$Res call({
 String id, String? reference, String requestType, String direction, String state, RegionSummaryDto region, String? notes, String? weightGrams, bool weightIsApproximate, String? purityKarat, String? ornamentType, String? condition, String? denominationGrams, int? quantity, String? mintOrRefiner, String? budgetMin, String? budgetMax, bool budgetIsFlexible, String? indicativeValue, DateTime? publishedAt, DateTime? expiresAt, int offerCount, int? unreadOfferCount, List<MediaRefDto> media, DateTime createdAt, DateTime updatedAt, Map<String, dynamic>? gemstones, String? cancellationReason, String? acceptedOfferId, String? connectionId, List<CustomerOfferDto>? offers
});


$RegionSummaryDtoCopyWith<$Res> get region;

}
/// @nodoc
class _$CustomerRequestDtoCopyWithImpl<$Res>
    implements $CustomerRequestDtoCopyWith<$Res> {
  _$CustomerRequestDtoCopyWithImpl(this._self, this._then);

  final CustomerRequestDto _self;
  final $Res Function(CustomerRequestDto) _then;

/// Create a copy of CustomerRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reference = freezed,Object? requestType = null,Object? direction = null,Object? state = null,Object? region = null,Object? notes = freezed,Object? weightGrams = freezed,Object? weightIsApproximate = null,Object? purityKarat = freezed,Object? ornamentType = freezed,Object? condition = freezed,Object? denominationGrams = freezed,Object? quantity = freezed,Object? mintOrRefiner = freezed,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? budgetIsFlexible = null,Object? indicativeValue = freezed,Object? publishedAt = freezed,Object? expiresAt = freezed,Object? offerCount = null,Object? unreadOfferCount = freezed,Object? media = null,Object? createdAt = null,Object? updatedAt = null,Object? gemstones = freezed,Object? cancellationReason = freezed,Object? acceptedOfferId = freezed,Object? connectionId = freezed,Object? offers = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,requestType: null == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as RegionSummaryDto,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,weightGrams: freezed == weightGrams ? _self.weightGrams : weightGrams // ignore: cast_nullable_to_non_nullable
as String?,weightIsApproximate: null == weightIsApproximate ? _self.weightIsApproximate : weightIsApproximate // ignore: cast_nullable_to_non_nullable
as bool,purityKarat: freezed == purityKarat ? _self.purityKarat : purityKarat // ignore: cast_nullable_to_non_nullable
as String?,ornamentType: freezed == ornamentType ? _self.ornamentType : ornamentType // ignore: cast_nullable_to_non_nullable
as String?,condition: freezed == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String?,denominationGrams: freezed == denominationGrams ? _self.denominationGrams : denominationGrams // ignore: cast_nullable_to_non_nullable
as String?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int?,mintOrRefiner: freezed == mintOrRefiner ? _self.mintOrRefiner : mintOrRefiner // ignore: cast_nullable_to_non_nullable
as String?,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin // ignore: cast_nullable_to_non_nullable
as String?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as String?,budgetIsFlexible: null == budgetIsFlexible ? _self.budgetIsFlexible : budgetIsFlexible // ignore: cast_nullable_to_non_nullable
as bool,indicativeValue: freezed == indicativeValue ? _self.indicativeValue : indicativeValue // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,offerCount: null == offerCount ? _self.offerCount : offerCount // ignore: cast_nullable_to_non_nullable
as int,unreadOfferCount: freezed == unreadOfferCount ? _self.unreadOfferCount : unreadOfferCount // ignore: cast_nullable_to_non_nullable
as int?,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as List<MediaRefDto>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,gemstones: freezed == gemstones ? _self.gemstones : gemstones // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,acceptedOfferId: freezed == acceptedOfferId ? _self.acceptedOfferId : acceptedOfferId // ignore: cast_nullable_to_non_nullable
as String?,connectionId: freezed == connectionId ? _self.connectionId : connectionId // ignore: cast_nullable_to_non_nullable
as String?,offers: freezed == offers ? _self.offers : offers // ignore: cast_nullable_to_non_nullable
as List<CustomerOfferDto>?,
  ));
}
/// Create a copy of CustomerRequestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegionSummaryDtoCopyWith<$Res> get region {
  
  return $RegionSummaryDtoCopyWith<$Res>(_self.region, (value) {
    return _then(_self.copyWith(region: value));
  });
}
}


/// Adds pattern-matching-related methods to [CustomerRequestDto].
extension CustomerRequestDtoPatterns on CustomerRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _CustomerRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? reference,  String requestType,  String direction,  String state,  RegionSummaryDto region,  String? notes,  String? weightGrams,  bool weightIsApproximate,  String? purityKarat,  String? ornamentType,  String? condition,  String? denominationGrams,  int? quantity,  String? mintOrRefiner,  String? budgetMin,  String? budgetMax,  bool budgetIsFlexible,  String? indicativeValue,  DateTime? publishedAt,  DateTime? expiresAt,  int offerCount,  int? unreadOfferCount,  List<MediaRefDto> media,  DateTime createdAt,  DateTime updatedAt,  Map<String, dynamic>? gemstones,  String? cancellationReason,  String? acceptedOfferId,  String? connectionId,  List<CustomerOfferDto>? offers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerRequestDto() when $default != null:
return $default(_that.id,_that.reference,_that.requestType,_that.direction,_that.state,_that.region,_that.notes,_that.weightGrams,_that.weightIsApproximate,_that.purityKarat,_that.ornamentType,_that.condition,_that.denominationGrams,_that.quantity,_that.mintOrRefiner,_that.budgetMin,_that.budgetMax,_that.budgetIsFlexible,_that.indicativeValue,_that.publishedAt,_that.expiresAt,_that.offerCount,_that.unreadOfferCount,_that.media,_that.createdAt,_that.updatedAt,_that.gemstones,_that.cancellationReason,_that.acceptedOfferId,_that.connectionId,_that.offers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? reference,  String requestType,  String direction,  String state,  RegionSummaryDto region,  String? notes,  String? weightGrams,  bool weightIsApproximate,  String? purityKarat,  String? ornamentType,  String? condition,  String? denominationGrams,  int? quantity,  String? mintOrRefiner,  String? budgetMin,  String? budgetMax,  bool budgetIsFlexible,  String? indicativeValue,  DateTime? publishedAt,  DateTime? expiresAt,  int offerCount,  int? unreadOfferCount,  List<MediaRefDto> media,  DateTime createdAt,  DateTime updatedAt,  Map<String, dynamic>? gemstones,  String? cancellationReason,  String? acceptedOfferId,  String? connectionId,  List<CustomerOfferDto>? offers)  $default,) {final _that = this;
switch (_that) {
case _CustomerRequestDto():
return $default(_that.id,_that.reference,_that.requestType,_that.direction,_that.state,_that.region,_that.notes,_that.weightGrams,_that.weightIsApproximate,_that.purityKarat,_that.ornamentType,_that.condition,_that.denominationGrams,_that.quantity,_that.mintOrRefiner,_that.budgetMin,_that.budgetMax,_that.budgetIsFlexible,_that.indicativeValue,_that.publishedAt,_that.expiresAt,_that.offerCount,_that.unreadOfferCount,_that.media,_that.createdAt,_that.updatedAt,_that.gemstones,_that.cancellationReason,_that.acceptedOfferId,_that.connectionId,_that.offers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? reference,  String requestType,  String direction,  String state,  RegionSummaryDto region,  String? notes,  String? weightGrams,  bool weightIsApproximate,  String? purityKarat,  String? ornamentType,  String? condition,  String? denominationGrams,  int? quantity,  String? mintOrRefiner,  String? budgetMin,  String? budgetMax,  bool budgetIsFlexible,  String? indicativeValue,  DateTime? publishedAt,  DateTime? expiresAt,  int offerCount,  int? unreadOfferCount,  List<MediaRefDto> media,  DateTime createdAt,  DateTime updatedAt,  Map<String, dynamic>? gemstones,  String? cancellationReason,  String? acceptedOfferId,  String? connectionId,  List<CustomerOfferDto>? offers)?  $default,) {final _that = this;
switch (_that) {
case _CustomerRequestDto() when $default != null:
return $default(_that.id,_that.reference,_that.requestType,_that.direction,_that.state,_that.region,_that.notes,_that.weightGrams,_that.weightIsApproximate,_that.purityKarat,_that.ornamentType,_that.condition,_that.denominationGrams,_that.quantity,_that.mintOrRefiner,_that.budgetMin,_that.budgetMax,_that.budgetIsFlexible,_that.indicativeValue,_that.publishedAt,_that.expiresAt,_that.offerCount,_that.unreadOfferCount,_that.media,_that.createdAt,_that.updatedAt,_that.gemstones,_that.cancellationReason,_that.acceptedOfferId,_that.connectionId,_that.offers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomerRequestDto implements CustomerRequestDto {
  const _CustomerRequestDto({required this.id, this.reference, required this.requestType, required this.direction, required this.state, required this.region, this.notes, this.weightGrams, required this.weightIsApproximate, this.purityKarat, this.ornamentType, this.condition, this.denominationGrams, this.quantity, this.mintOrRefiner, this.budgetMin, this.budgetMax, required this.budgetIsFlexible, this.indicativeValue, this.publishedAt, this.expiresAt, required this.offerCount, this.unreadOfferCount, final  List<MediaRefDto> media = const <MediaRefDto>[], required this.createdAt, required this.updatedAt, final  Map<String, dynamic>? gemstones, this.cancellationReason, this.acceptedOfferId, this.connectionId, final  List<CustomerOfferDto>? offers}): _media = media,_gemstones = gemstones,_offers = offers;
  factory _CustomerRequestDto.fromJson(Map<String, dynamic> json) => _$CustomerRequestDtoFromJson(json);

@override final  String id;
@override final  String? reference;
@override final  String requestType;
@override final  String direction;
@override final  String state;
@override final  RegionSummaryDto region;
@override final  String? notes;
@override final  String? weightGrams;
@override final  bool weightIsApproximate;
@override final  String? purityKarat;
@override final  String? ornamentType;
@override final  String? condition;
@override final  String? denominationGrams;
@override final  int? quantity;
@override final  String? mintOrRefiner;
@override final  String? budgetMin;
@override final  String? budgetMax;
@override final  bool budgetIsFlexible;
@override final  String? indicativeValue;
@override final  DateTime? publishedAt;
@override final  DateTime? expiresAt;
@override final  int offerCount;
@override final  int? unreadOfferCount;
 final  List<MediaRefDto> _media;
@override@JsonKey() List<MediaRefDto> get media {
  if (_media is EqualUnmodifiableListView) return _media;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_media);
}

@override final  DateTime createdAt;
@override final  DateTime updatedAt;
 final  Map<String, dynamic>? _gemstones;
@override Map<String, dynamic>? get gemstones {
  final value = _gemstones;
  if (value == null) return null;
  if (_gemstones is EqualUnmodifiableMapView) return _gemstones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? cancellationReason;
@override final  String? acceptedOfferId;
// Deep-link target for `CUS-S10` → `CUS-S15` when `state == ACCEPTED` (`SAM-GAP-3`).
@override final  String? connectionId;
// Nested only on `GET /v1/requests/:id` (owner presenter).
 final  List<CustomerOfferDto>? _offers;
// Nested only on `GET /v1/requests/:id` (owner presenter).
@override List<CustomerOfferDto>? get offers {
  final value = _offers;
  if (value == null) return null;
  if (_offers is EqualUnmodifiableListView) return _offers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of CustomerRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerRequestDtoCopyWith<_CustomerRequestDto> get copyWith => __$CustomerRequestDtoCopyWithImpl<_CustomerRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomerRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerRequestDto&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.state, state) || other.state == state)&&(identical(other.region, region) || other.region == region)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.weightGrams, weightGrams) || other.weightGrams == weightGrams)&&(identical(other.weightIsApproximate, weightIsApproximate) || other.weightIsApproximate == weightIsApproximate)&&(identical(other.purityKarat, purityKarat) || other.purityKarat == purityKarat)&&(identical(other.ornamentType, ornamentType) || other.ornamentType == ornamentType)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.denominationGrams, denominationGrams) || other.denominationGrams == denominationGrams)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.mintOrRefiner, mintOrRefiner) || other.mintOrRefiner == mintOrRefiner)&&(identical(other.budgetMin, budgetMin) || other.budgetMin == budgetMin)&&(identical(other.budgetMax, budgetMax) || other.budgetMax == budgetMax)&&(identical(other.budgetIsFlexible, budgetIsFlexible) || other.budgetIsFlexible == budgetIsFlexible)&&(identical(other.indicativeValue, indicativeValue) || other.indicativeValue == indicativeValue)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.offerCount, offerCount) || other.offerCount == offerCount)&&(identical(other.unreadOfferCount, unreadOfferCount) || other.unreadOfferCount == unreadOfferCount)&&const DeepCollectionEquality().equals(other._media, _media)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._gemstones, _gemstones)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.acceptedOfferId, acceptedOfferId) || other.acceptedOfferId == acceptedOfferId)&&(identical(other.connectionId, connectionId) || other.connectionId == connectionId)&&const DeepCollectionEquality().equals(other._offers, _offers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reference,requestType,direction,state,region,notes,weightGrams,weightIsApproximate,purityKarat,ornamentType,condition,denominationGrams,quantity,mintOrRefiner,budgetMin,budgetMax,budgetIsFlexible,indicativeValue,publishedAt,expiresAt,offerCount,unreadOfferCount,const DeepCollectionEquality().hash(_media),createdAt,updatedAt,const DeepCollectionEquality().hash(_gemstones),cancellationReason,acceptedOfferId,connectionId,const DeepCollectionEquality().hash(_offers)]);

@override
String toString() {
  return 'CustomerRequestDto(id: $id, reference: $reference, requestType: $requestType, direction: $direction, state: $state, region: $region, notes: $notes, weightGrams: $weightGrams, weightIsApproximate: $weightIsApproximate, purityKarat: $purityKarat, ornamentType: $ornamentType, condition: $condition, denominationGrams: $denominationGrams, quantity: $quantity, mintOrRefiner: $mintOrRefiner, budgetMin: $budgetMin, budgetMax: $budgetMax, budgetIsFlexible: $budgetIsFlexible, indicativeValue: $indicativeValue, publishedAt: $publishedAt, expiresAt: $expiresAt, offerCount: $offerCount, unreadOfferCount: $unreadOfferCount, media: $media, createdAt: $createdAt, updatedAt: $updatedAt, gemstones: $gemstones, cancellationReason: $cancellationReason, acceptedOfferId: $acceptedOfferId, connectionId: $connectionId, offers: $offers)';
}


}

/// @nodoc
abstract mixin class _$CustomerRequestDtoCopyWith<$Res> implements $CustomerRequestDtoCopyWith<$Res> {
  factory _$CustomerRequestDtoCopyWith(_CustomerRequestDto value, $Res Function(_CustomerRequestDto) _then) = __$CustomerRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String? reference, String requestType, String direction, String state, RegionSummaryDto region, String? notes, String? weightGrams, bool weightIsApproximate, String? purityKarat, String? ornamentType, String? condition, String? denominationGrams, int? quantity, String? mintOrRefiner, String? budgetMin, String? budgetMax, bool budgetIsFlexible, String? indicativeValue, DateTime? publishedAt, DateTime? expiresAt, int offerCount, int? unreadOfferCount, List<MediaRefDto> media, DateTime createdAt, DateTime updatedAt, Map<String, dynamic>? gemstones, String? cancellationReason, String? acceptedOfferId, String? connectionId, List<CustomerOfferDto>? offers
});


@override $RegionSummaryDtoCopyWith<$Res> get region;

}
/// @nodoc
class __$CustomerRequestDtoCopyWithImpl<$Res>
    implements _$CustomerRequestDtoCopyWith<$Res> {
  __$CustomerRequestDtoCopyWithImpl(this._self, this._then);

  final _CustomerRequestDto _self;
  final $Res Function(_CustomerRequestDto) _then;

/// Create a copy of CustomerRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reference = freezed,Object? requestType = null,Object? direction = null,Object? state = null,Object? region = null,Object? notes = freezed,Object? weightGrams = freezed,Object? weightIsApproximate = null,Object? purityKarat = freezed,Object? ornamentType = freezed,Object? condition = freezed,Object? denominationGrams = freezed,Object? quantity = freezed,Object? mintOrRefiner = freezed,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? budgetIsFlexible = null,Object? indicativeValue = freezed,Object? publishedAt = freezed,Object? expiresAt = freezed,Object? offerCount = null,Object? unreadOfferCount = freezed,Object? media = null,Object? createdAt = null,Object? updatedAt = null,Object? gemstones = freezed,Object? cancellationReason = freezed,Object? acceptedOfferId = freezed,Object? connectionId = freezed,Object? offers = freezed,}) {
  return _then(_CustomerRequestDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,requestType: null == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as RegionSummaryDto,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,weightGrams: freezed == weightGrams ? _self.weightGrams : weightGrams // ignore: cast_nullable_to_non_nullable
as String?,weightIsApproximate: null == weightIsApproximate ? _self.weightIsApproximate : weightIsApproximate // ignore: cast_nullable_to_non_nullable
as bool,purityKarat: freezed == purityKarat ? _self.purityKarat : purityKarat // ignore: cast_nullable_to_non_nullable
as String?,ornamentType: freezed == ornamentType ? _self.ornamentType : ornamentType // ignore: cast_nullable_to_non_nullable
as String?,condition: freezed == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String?,denominationGrams: freezed == denominationGrams ? _self.denominationGrams : denominationGrams // ignore: cast_nullable_to_non_nullable
as String?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int?,mintOrRefiner: freezed == mintOrRefiner ? _self.mintOrRefiner : mintOrRefiner // ignore: cast_nullable_to_non_nullable
as String?,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin // ignore: cast_nullable_to_non_nullable
as String?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as String?,budgetIsFlexible: null == budgetIsFlexible ? _self.budgetIsFlexible : budgetIsFlexible // ignore: cast_nullable_to_non_nullable
as bool,indicativeValue: freezed == indicativeValue ? _self.indicativeValue : indicativeValue // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,offerCount: null == offerCount ? _self.offerCount : offerCount // ignore: cast_nullable_to_non_nullable
as int,unreadOfferCount: freezed == unreadOfferCount ? _self.unreadOfferCount : unreadOfferCount // ignore: cast_nullable_to_non_nullable
as int?,media: null == media ? _self._media : media // ignore: cast_nullable_to_non_nullable
as List<MediaRefDto>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,gemstones: freezed == gemstones ? _self._gemstones : gemstones // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,acceptedOfferId: freezed == acceptedOfferId ? _self.acceptedOfferId : acceptedOfferId // ignore: cast_nullable_to_non_nullable
as String?,connectionId: freezed == connectionId ? _self.connectionId : connectionId // ignore: cast_nullable_to_non_nullable
as String?,offers: freezed == offers ? _self._offers : offers // ignore: cast_nullable_to_non_nullable
as List<CustomerOfferDto>?,
  ));
}

/// Create a copy of CustomerRequestDto
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
mixin _$RequestDraftInput {

@JsonKey(includeIfNull: false) String? get requestType;@JsonKey(includeIfNull: false) String? get direction;@JsonKey(includeIfNull: false) String? get regionId;@JsonKey(includeIfNull: false) String? get notes;@JsonKey(includeIfNull: false) Object? get weightGrams;@JsonKey(includeIfNull: false) bool? get weightIsApproximate;@JsonKey(includeIfNull: false) String? get purityKarat;@JsonKey(includeIfNull: false) String? get ornamentType;@JsonKey(includeIfNull: false) String? get condition;@JsonKey(includeIfNull: false) Object? get denominationGrams;@JsonKey(includeIfNull: false) int? get quantity;@JsonKey(includeIfNull: false) String? get mintOrRefiner;@JsonKey(includeIfNull: false) Object? get budgetMin;@JsonKey(includeIfNull: false) Object? get budgetMax;@JsonKey(includeIfNull: false) bool? get budgetIsFlexible;@JsonKey(includeIfNull: false) Map<String, dynamic>? get gemstones;@JsonKey(includeIfNull: false) List<String>? get mediaKeys;
/// Create a copy of RequestDraftInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestDraftInputCopyWith<RequestDraftInput> get copyWith => _$RequestDraftInputCopyWithImpl<RequestDraftInput>(this as RequestDraftInput, _$identity);

  /// Serializes this RequestDraftInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestDraftInput&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.weightGrams, weightGrams)&&(identical(other.weightIsApproximate, weightIsApproximate) || other.weightIsApproximate == weightIsApproximate)&&(identical(other.purityKarat, purityKarat) || other.purityKarat == purityKarat)&&(identical(other.ornamentType, ornamentType) || other.ornamentType == ornamentType)&&(identical(other.condition, condition) || other.condition == condition)&&const DeepCollectionEquality().equals(other.denominationGrams, denominationGrams)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.mintOrRefiner, mintOrRefiner) || other.mintOrRefiner == mintOrRefiner)&&const DeepCollectionEquality().equals(other.budgetMin, budgetMin)&&const DeepCollectionEquality().equals(other.budgetMax, budgetMax)&&(identical(other.budgetIsFlexible, budgetIsFlexible) || other.budgetIsFlexible == budgetIsFlexible)&&const DeepCollectionEquality().equals(other.gemstones, gemstones)&&const DeepCollectionEquality().equals(other.mediaKeys, mediaKeys));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requestType,direction,regionId,notes,const DeepCollectionEquality().hash(weightGrams),weightIsApproximate,purityKarat,ornamentType,condition,const DeepCollectionEquality().hash(denominationGrams),quantity,mintOrRefiner,const DeepCollectionEquality().hash(budgetMin),const DeepCollectionEquality().hash(budgetMax),budgetIsFlexible,const DeepCollectionEquality().hash(gemstones),const DeepCollectionEquality().hash(mediaKeys));

@override
String toString() {
  return 'RequestDraftInput(requestType: $requestType, direction: $direction, regionId: $regionId, notes: $notes, weightGrams: $weightGrams, weightIsApproximate: $weightIsApproximate, purityKarat: $purityKarat, ornamentType: $ornamentType, condition: $condition, denominationGrams: $denominationGrams, quantity: $quantity, mintOrRefiner: $mintOrRefiner, budgetMin: $budgetMin, budgetMax: $budgetMax, budgetIsFlexible: $budgetIsFlexible, gemstones: $gemstones, mediaKeys: $mediaKeys)';
}


}

/// @nodoc
abstract mixin class $RequestDraftInputCopyWith<$Res>  {
  factory $RequestDraftInputCopyWith(RequestDraftInput value, $Res Function(RequestDraftInput) _then) = _$RequestDraftInputCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? requestType,@JsonKey(includeIfNull: false) String? direction,@JsonKey(includeIfNull: false) String? regionId,@JsonKey(includeIfNull: false) String? notes,@JsonKey(includeIfNull: false) Object? weightGrams,@JsonKey(includeIfNull: false) bool? weightIsApproximate,@JsonKey(includeIfNull: false) String? purityKarat,@JsonKey(includeIfNull: false) String? ornamentType,@JsonKey(includeIfNull: false) String? condition,@JsonKey(includeIfNull: false) Object? denominationGrams,@JsonKey(includeIfNull: false) int? quantity,@JsonKey(includeIfNull: false) String? mintOrRefiner,@JsonKey(includeIfNull: false) Object? budgetMin,@JsonKey(includeIfNull: false) Object? budgetMax,@JsonKey(includeIfNull: false) bool? budgetIsFlexible,@JsonKey(includeIfNull: false) Map<String, dynamic>? gemstones,@JsonKey(includeIfNull: false) List<String>? mediaKeys
});




}
/// @nodoc
class _$RequestDraftInputCopyWithImpl<$Res>
    implements $RequestDraftInputCopyWith<$Res> {
  _$RequestDraftInputCopyWithImpl(this._self, this._then);

  final RequestDraftInput _self;
  final $Res Function(RequestDraftInput) _then;

/// Create a copy of RequestDraftInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requestType = freezed,Object? direction = freezed,Object? regionId = freezed,Object? notes = freezed,Object? weightGrams = freezed,Object? weightIsApproximate = freezed,Object? purityKarat = freezed,Object? ornamentType = freezed,Object? condition = freezed,Object? denominationGrams = freezed,Object? quantity = freezed,Object? mintOrRefiner = freezed,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? budgetIsFlexible = freezed,Object? gemstones = freezed,Object? mediaKeys = freezed,}) {
  return _then(_self.copyWith(
requestType: freezed == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as String?,direction: freezed == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,weightGrams: freezed == weightGrams ? _self.weightGrams : weightGrams ,weightIsApproximate: freezed == weightIsApproximate ? _self.weightIsApproximate : weightIsApproximate // ignore: cast_nullable_to_non_nullable
as bool?,purityKarat: freezed == purityKarat ? _self.purityKarat : purityKarat // ignore: cast_nullable_to_non_nullable
as String?,ornamentType: freezed == ornamentType ? _self.ornamentType : ornamentType // ignore: cast_nullable_to_non_nullable
as String?,condition: freezed == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String?,denominationGrams: freezed == denominationGrams ? _self.denominationGrams : denominationGrams ,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int?,mintOrRefiner: freezed == mintOrRefiner ? _self.mintOrRefiner : mintOrRefiner // ignore: cast_nullable_to_non_nullable
as String?,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin ,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax ,budgetIsFlexible: freezed == budgetIsFlexible ? _self.budgetIsFlexible : budgetIsFlexible // ignore: cast_nullable_to_non_nullable
as bool?,gemstones: freezed == gemstones ? _self.gemstones : gemstones // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,mediaKeys: freezed == mediaKeys ? _self.mediaKeys : mediaKeys // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestDraftInput].
extension RequestDraftInputPatterns on RequestDraftInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestDraftInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestDraftInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestDraftInput value)  $default,){
final _that = this;
switch (_that) {
case _RequestDraftInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestDraftInput value)?  $default,){
final _that = this;
switch (_that) {
case _RequestDraftInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? requestType, @JsonKey(includeIfNull: false)  String? direction, @JsonKey(includeIfNull: false)  String? regionId, @JsonKey(includeIfNull: false)  String? notes, @JsonKey(includeIfNull: false)  Object? weightGrams, @JsonKey(includeIfNull: false)  bool? weightIsApproximate, @JsonKey(includeIfNull: false)  String? purityKarat, @JsonKey(includeIfNull: false)  String? ornamentType, @JsonKey(includeIfNull: false)  String? condition, @JsonKey(includeIfNull: false)  Object? denominationGrams, @JsonKey(includeIfNull: false)  int? quantity, @JsonKey(includeIfNull: false)  String? mintOrRefiner, @JsonKey(includeIfNull: false)  Object? budgetMin, @JsonKey(includeIfNull: false)  Object? budgetMax, @JsonKey(includeIfNull: false)  bool? budgetIsFlexible, @JsonKey(includeIfNull: false)  Map<String, dynamic>? gemstones, @JsonKey(includeIfNull: false)  List<String>? mediaKeys)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestDraftInput() when $default != null:
return $default(_that.requestType,_that.direction,_that.regionId,_that.notes,_that.weightGrams,_that.weightIsApproximate,_that.purityKarat,_that.ornamentType,_that.condition,_that.denominationGrams,_that.quantity,_that.mintOrRefiner,_that.budgetMin,_that.budgetMax,_that.budgetIsFlexible,_that.gemstones,_that.mediaKeys);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? requestType, @JsonKey(includeIfNull: false)  String? direction, @JsonKey(includeIfNull: false)  String? regionId, @JsonKey(includeIfNull: false)  String? notes, @JsonKey(includeIfNull: false)  Object? weightGrams, @JsonKey(includeIfNull: false)  bool? weightIsApproximate, @JsonKey(includeIfNull: false)  String? purityKarat, @JsonKey(includeIfNull: false)  String? ornamentType, @JsonKey(includeIfNull: false)  String? condition, @JsonKey(includeIfNull: false)  Object? denominationGrams, @JsonKey(includeIfNull: false)  int? quantity, @JsonKey(includeIfNull: false)  String? mintOrRefiner, @JsonKey(includeIfNull: false)  Object? budgetMin, @JsonKey(includeIfNull: false)  Object? budgetMax, @JsonKey(includeIfNull: false)  bool? budgetIsFlexible, @JsonKey(includeIfNull: false)  Map<String, dynamic>? gemstones, @JsonKey(includeIfNull: false)  List<String>? mediaKeys)  $default,) {final _that = this;
switch (_that) {
case _RequestDraftInput():
return $default(_that.requestType,_that.direction,_that.regionId,_that.notes,_that.weightGrams,_that.weightIsApproximate,_that.purityKarat,_that.ornamentType,_that.condition,_that.denominationGrams,_that.quantity,_that.mintOrRefiner,_that.budgetMin,_that.budgetMax,_that.budgetIsFlexible,_that.gemstones,_that.mediaKeys);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  String? requestType, @JsonKey(includeIfNull: false)  String? direction, @JsonKey(includeIfNull: false)  String? regionId, @JsonKey(includeIfNull: false)  String? notes, @JsonKey(includeIfNull: false)  Object? weightGrams, @JsonKey(includeIfNull: false)  bool? weightIsApproximate, @JsonKey(includeIfNull: false)  String? purityKarat, @JsonKey(includeIfNull: false)  String? ornamentType, @JsonKey(includeIfNull: false)  String? condition, @JsonKey(includeIfNull: false)  Object? denominationGrams, @JsonKey(includeIfNull: false)  int? quantity, @JsonKey(includeIfNull: false)  String? mintOrRefiner, @JsonKey(includeIfNull: false)  Object? budgetMin, @JsonKey(includeIfNull: false)  Object? budgetMax, @JsonKey(includeIfNull: false)  bool? budgetIsFlexible, @JsonKey(includeIfNull: false)  Map<String, dynamic>? gemstones, @JsonKey(includeIfNull: false)  List<String>? mediaKeys)?  $default,) {final _that = this;
switch (_that) {
case _RequestDraftInput() when $default != null:
return $default(_that.requestType,_that.direction,_that.regionId,_that.notes,_that.weightGrams,_that.weightIsApproximate,_that.purityKarat,_that.ornamentType,_that.condition,_that.denominationGrams,_that.quantity,_that.mintOrRefiner,_that.budgetMin,_that.budgetMax,_that.budgetIsFlexible,_that.gemstones,_that.mediaKeys);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RequestDraftInput implements RequestDraftInput {
  const _RequestDraftInput({@JsonKey(includeIfNull: false) this.requestType, @JsonKey(includeIfNull: false) this.direction, @JsonKey(includeIfNull: false) this.regionId, @JsonKey(includeIfNull: false) this.notes, @JsonKey(includeIfNull: false) this.weightGrams, @JsonKey(includeIfNull: false) this.weightIsApproximate, @JsonKey(includeIfNull: false) this.purityKarat, @JsonKey(includeIfNull: false) this.ornamentType, @JsonKey(includeIfNull: false) this.condition, @JsonKey(includeIfNull: false) this.denominationGrams, @JsonKey(includeIfNull: false) this.quantity, @JsonKey(includeIfNull: false) this.mintOrRefiner, @JsonKey(includeIfNull: false) this.budgetMin, @JsonKey(includeIfNull: false) this.budgetMax, @JsonKey(includeIfNull: false) this.budgetIsFlexible, @JsonKey(includeIfNull: false) final  Map<String, dynamic>? gemstones, @JsonKey(includeIfNull: false) final  List<String>? mediaKeys}): _gemstones = gemstones,_mediaKeys = mediaKeys;
  factory _RequestDraftInput.fromJson(Map<String, dynamic> json) => _$RequestDraftInputFromJson(json);

@override@JsonKey(includeIfNull: false) final  String? requestType;
@override@JsonKey(includeIfNull: false) final  String? direction;
@override@JsonKey(includeIfNull: false) final  String? regionId;
@override@JsonKey(includeIfNull: false) final  String? notes;
@override@JsonKey(includeIfNull: false) final  Object? weightGrams;
@override@JsonKey(includeIfNull: false) final  bool? weightIsApproximate;
@override@JsonKey(includeIfNull: false) final  String? purityKarat;
@override@JsonKey(includeIfNull: false) final  String? ornamentType;
@override@JsonKey(includeIfNull: false) final  String? condition;
@override@JsonKey(includeIfNull: false) final  Object? denominationGrams;
@override@JsonKey(includeIfNull: false) final  int? quantity;
@override@JsonKey(includeIfNull: false) final  String? mintOrRefiner;
@override@JsonKey(includeIfNull: false) final  Object? budgetMin;
@override@JsonKey(includeIfNull: false) final  Object? budgetMax;
@override@JsonKey(includeIfNull: false) final  bool? budgetIsFlexible;
 final  Map<String, dynamic>? _gemstones;
@override@JsonKey(includeIfNull: false) Map<String, dynamic>? get gemstones {
  final value = _gemstones;
  if (value == null) return null;
  if (_gemstones is EqualUnmodifiableMapView) return _gemstones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<String>? _mediaKeys;
@override@JsonKey(includeIfNull: false) List<String>? get mediaKeys {
  final value = _mediaKeys;
  if (value == null) return null;
  if (_mediaKeys is EqualUnmodifiableListView) return _mediaKeys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of RequestDraftInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestDraftInputCopyWith<_RequestDraftInput> get copyWith => __$RequestDraftInputCopyWithImpl<_RequestDraftInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestDraftInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestDraftInput&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.weightGrams, weightGrams)&&(identical(other.weightIsApproximate, weightIsApproximate) || other.weightIsApproximate == weightIsApproximate)&&(identical(other.purityKarat, purityKarat) || other.purityKarat == purityKarat)&&(identical(other.ornamentType, ornamentType) || other.ornamentType == ornamentType)&&(identical(other.condition, condition) || other.condition == condition)&&const DeepCollectionEquality().equals(other.denominationGrams, denominationGrams)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.mintOrRefiner, mintOrRefiner) || other.mintOrRefiner == mintOrRefiner)&&const DeepCollectionEquality().equals(other.budgetMin, budgetMin)&&const DeepCollectionEquality().equals(other.budgetMax, budgetMax)&&(identical(other.budgetIsFlexible, budgetIsFlexible) || other.budgetIsFlexible == budgetIsFlexible)&&const DeepCollectionEquality().equals(other._gemstones, _gemstones)&&const DeepCollectionEquality().equals(other._mediaKeys, _mediaKeys));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requestType,direction,regionId,notes,const DeepCollectionEquality().hash(weightGrams),weightIsApproximate,purityKarat,ornamentType,condition,const DeepCollectionEquality().hash(denominationGrams),quantity,mintOrRefiner,const DeepCollectionEquality().hash(budgetMin),const DeepCollectionEquality().hash(budgetMax),budgetIsFlexible,const DeepCollectionEquality().hash(_gemstones),const DeepCollectionEquality().hash(_mediaKeys));

@override
String toString() {
  return 'RequestDraftInput(requestType: $requestType, direction: $direction, regionId: $regionId, notes: $notes, weightGrams: $weightGrams, weightIsApproximate: $weightIsApproximate, purityKarat: $purityKarat, ornamentType: $ornamentType, condition: $condition, denominationGrams: $denominationGrams, quantity: $quantity, mintOrRefiner: $mintOrRefiner, budgetMin: $budgetMin, budgetMax: $budgetMax, budgetIsFlexible: $budgetIsFlexible, gemstones: $gemstones, mediaKeys: $mediaKeys)';
}


}

/// @nodoc
abstract mixin class _$RequestDraftInputCopyWith<$Res> implements $RequestDraftInputCopyWith<$Res> {
  factory _$RequestDraftInputCopyWith(_RequestDraftInput value, $Res Function(_RequestDraftInput) _then) = __$RequestDraftInputCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) String? requestType,@JsonKey(includeIfNull: false) String? direction,@JsonKey(includeIfNull: false) String? regionId,@JsonKey(includeIfNull: false) String? notes,@JsonKey(includeIfNull: false) Object? weightGrams,@JsonKey(includeIfNull: false) bool? weightIsApproximate,@JsonKey(includeIfNull: false) String? purityKarat,@JsonKey(includeIfNull: false) String? ornamentType,@JsonKey(includeIfNull: false) String? condition,@JsonKey(includeIfNull: false) Object? denominationGrams,@JsonKey(includeIfNull: false) int? quantity,@JsonKey(includeIfNull: false) String? mintOrRefiner,@JsonKey(includeIfNull: false) Object? budgetMin,@JsonKey(includeIfNull: false) Object? budgetMax,@JsonKey(includeIfNull: false) bool? budgetIsFlexible,@JsonKey(includeIfNull: false) Map<String, dynamic>? gemstones,@JsonKey(includeIfNull: false) List<String>? mediaKeys
});




}
/// @nodoc
class __$RequestDraftInputCopyWithImpl<$Res>
    implements _$RequestDraftInputCopyWith<$Res> {
  __$RequestDraftInputCopyWithImpl(this._self, this._then);

  final _RequestDraftInput _self;
  final $Res Function(_RequestDraftInput) _then;

/// Create a copy of RequestDraftInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requestType = freezed,Object? direction = freezed,Object? regionId = freezed,Object? notes = freezed,Object? weightGrams = freezed,Object? weightIsApproximate = freezed,Object? purityKarat = freezed,Object? ornamentType = freezed,Object? condition = freezed,Object? denominationGrams = freezed,Object? quantity = freezed,Object? mintOrRefiner = freezed,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? budgetIsFlexible = freezed,Object? gemstones = freezed,Object? mediaKeys = freezed,}) {
  return _then(_RequestDraftInput(
requestType: freezed == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as String?,direction: freezed == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,weightGrams: freezed == weightGrams ? _self.weightGrams : weightGrams ,weightIsApproximate: freezed == weightIsApproximate ? _self.weightIsApproximate : weightIsApproximate // ignore: cast_nullable_to_non_nullable
as bool?,purityKarat: freezed == purityKarat ? _self.purityKarat : purityKarat // ignore: cast_nullable_to_non_nullable
as String?,ornamentType: freezed == ornamentType ? _self.ornamentType : ornamentType // ignore: cast_nullable_to_non_nullable
as String?,condition: freezed == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String?,denominationGrams: freezed == denominationGrams ? _self.denominationGrams : denominationGrams ,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int?,mintOrRefiner: freezed == mintOrRefiner ? _self.mintOrRefiner : mintOrRefiner // ignore: cast_nullable_to_non_nullable
as String?,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin ,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax ,budgetIsFlexible: freezed == budgetIsFlexible ? _self.budgetIsFlexible : budgetIsFlexible // ignore: cast_nullable_to_non_nullable
as bool?,gemstones: freezed == gemstones ? _self._gemstones : gemstones // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,mediaKeys: freezed == mediaKeys ? _self._mediaKeys : mediaKeys // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
