// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MediaRef {

 String get id; String get key;@_MediaStateConverter() MediaState get state;@_MediaPurposeConverter() MediaPurpose get purpose; String get contentType; int get byteSize; int get displayOrder; String? get thumbnailUrl; String? get displayUrl;
/// Create a copy of MediaRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaRefCopyWith<MediaRef> get copyWith => _$MediaRefCopyWithImpl<MediaRef>(this as MediaRef, _$identity);

  /// Serializes this MediaRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaRef&&(identical(other.id, id) || other.id == id)&&(identical(other.key, key) || other.key == key)&&(identical(other.state, state) || other.state == state)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.byteSize, byteSize) || other.byteSize == byteSize)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.displayUrl, displayUrl) || other.displayUrl == displayUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,key,state,purpose,contentType,byteSize,displayOrder,thumbnailUrl,displayUrl);

@override
String toString() {
  return 'MediaRef(id: $id, key: $key, state: $state, purpose: $purpose, contentType: $contentType, byteSize: $byteSize, displayOrder: $displayOrder, thumbnailUrl: $thumbnailUrl, displayUrl: $displayUrl)';
}


}

/// @nodoc
abstract mixin class $MediaRefCopyWith<$Res>  {
  factory $MediaRefCopyWith(MediaRef value, $Res Function(MediaRef) _then) = _$MediaRefCopyWithImpl;
@useResult
$Res call({
 String id, String key,@_MediaStateConverter() MediaState state,@_MediaPurposeConverter() MediaPurpose purpose, String contentType, int byteSize, int displayOrder, String? thumbnailUrl, String? displayUrl
});




}
/// @nodoc
class _$MediaRefCopyWithImpl<$Res>
    implements $MediaRefCopyWith<$Res> {
  _$MediaRefCopyWithImpl(this._self, this._then);

  final MediaRef _self;
  final $Res Function(MediaRef) _then;

/// Create a copy of MediaRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? key = null,Object? state = null,Object? purpose = null,Object? contentType = null,Object? byteSize = null,Object? displayOrder = null,Object? thumbnailUrl = freezed,Object? displayUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as MediaState,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as MediaPurpose,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,byteSize: null == byteSize ? _self.byteSize : byteSize // ignore: cast_nullable_to_non_nullable
as int,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,displayUrl: freezed == displayUrl ? _self.displayUrl : displayUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaRef].
extension MediaRefPatterns on MediaRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaRef value)  $default,){
final _that = this;
switch (_that) {
case _MediaRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaRef value)?  $default,){
final _that = this;
switch (_that) {
case _MediaRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String key, @_MediaStateConverter()  MediaState state, @_MediaPurposeConverter()  MediaPurpose purpose,  String contentType,  int byteSize,  int displayOrder,  String? thumbnailUrl,  String? displayUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaRef() when $default != null:
return $default(_that.id,_that.key,_that.state,_that.purpose,_that.contentType,_that.byteSize,_that.displayOrder,_that.thumbnailUrl,_that.displayUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String key, @_MediaStateConverter()  MediaState state, @_MediaPurposeConverter()  MediaPurpose purpose,  String contentType,  int byteSize,  int displayOrder,  String? thumbnailUrl,  String? displayUrl)  $default,) {final _that = this;
switch (_that) {
case _MediaRef():
return $default(_that.id,_that.key,_that.state,_that.purpose,_that.contentType,_that.byteSize,_that.displayOrder,_that.thumbnailUrl,_that.displayUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String key, @_MediaStateConverter()  MediaState state, @_MediaPurposeConverter()  MediaPurpose purpose,  String contentType,  int byteSize,  int displayOrder,  String? thumbnailUrl,  String? displayUrl)?  $default,) {final _that = this;
switch (_that) {
case _MediaRef() when $default != null:
return $default(_that.id,_that.key,_that.state,_that.purpose,_that.contentType,_that.byteSize,_that.displayOrder,_that.thumbnailUrl,_that.displayUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MediaRef implements MediaRef {
  const _MediaRef({required this.id, required this.key, @_MediaStateConverter() required this.state, @_MediaPurposeConverter() required this.purpose, required this.contentType, required this.byteSize, required this.displayOrder, this.thumbnailUrl, this.displayUrl});
  factory _MediaRef.fromJson(Map<String, dynamic> json) => _$MediaRefFromJson(json);

@override final  String id;
@override final  String key;
@override@_MediaStateConverter() final  MediaState state;
@override@_MediaPurposeConverter() final  MediaPurpose purpose;
@override final  String contentType;
@override final  int byteSize;
@override final  int displayOrder;
@override final  String? thumbnailUrl;
@override final  String? displayUrl;

/// Create a copy of MediaRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaRefCopyWith<_MediaRef> get copyWith => __$MediaRefCopyWithImpl<_MediaRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaRef&&(identical(other.id, id) || other.id == id)&&(identical(other.key, key) || other.key == key)&&(identical(other.state, state) || other.state == state)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.byteSize, byteSize) || other.byteSize == byteSize)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.displayUrl, displayUrl) || other.displayUrl == displayUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,key,state,purpose,contentType,byteSize,displayOrder,thumbnailUrl,displayUrl);

@override
String toString() {
  return 'MediaRef(id: $id, key: $key, state: $state, purpose: $purpose, contentType: $contentType, byteSize: $byteSize, displayOrder: $displayOrder, thumbnailUrl: $thumbnailUrl, displayUrl: $displayUrl)';
}


}

/// @nodoc
abstract mixin class _$MediaRefCopyWith<$Res> implements $MediaRefCopyWith<$Res> {
  factory _$MediaRefCopyWith(_MediaRef value, $Res Function(_MediaRef) _then) = __$MediaRefCopyWithImpl;
@override @useResult
$Res call({
 String id, String key,@_MediaStateConverter() MediaState state,@_MediaPurposeConverter() MediaPurpose purpose, String contentType, int byteSize, int displayOrder, String? thumbnailUrl, String? displayUrl
});




}
/// @nodoc
class __$MediaRefCopyWithImpl<$Res>
    implements _$MediaRefCopyWith<$Res> {
  __$MediaRefCopyWithImpl(this._self, this._then);

  final _MediaRef _self;
  final $Res Function(_MediaRef) _then;

/// Create a copy of MediaRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? key = null,Object? state = null,Object? purpose = null,Object? contentType = null,Object? byteSize = null,Object? displayOrder = null,Object? thumbnailUrl = freezed,Object? displayUrl = freezed,}) {
  return _then(_MediaRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as MediaState,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as MediaPurpose,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,byteSize: null == byteSize ? _self.byteSize : byteSize // ignore: cast_nullable_to_non_nullable
as int,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,displayUrl: freezed == displayUrl ? _self.displayUrl : displayUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RequestForCustomer {

 String get id;@_RequestTypeConverter() RequestType get requestType;@_DirectionConverter() Direction get direction;@_RequestStateConverter() RequestState get state; CategorySummary get category; RegionSummary get region; bool get weightIsApproximate; bool get budgetIsFlexible; int get offerCount; List<MediaRef> get media; DateTime get createdAt; DateTime get updatedAt; String? get reference; String? get notes; String? get weightGrams;@_NullableKaratConverter() Karat? get purityKarat;@_NullableOrnamentTypeConverter() OrnamentType? get ornamentType;@_NullableItemConditionConverter() ItemCondition? get condition; String? get denominationGrams; int? get quantity; String? get mintOrRefiner; String? get budgetMin; String? get budgetMax; String? get indicativeValue; DateTime? get publishedAt; DateTime? get expiresAt; String? get cancellationReason; String? get acceptedOfferId;/// Absent on the wire → UI hides the unread marker (CM-K01 / SAM-GAP-1).
 int? get unreadOfferCount;/// Absent unless ACCEPTED and the Connection join is present (SAM-GAP-3).
 String? get connectionId;
/// Create a copy of RequestForCustomer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestForCustomerCopyWith<RequestForCustomer> get copyWith => _$RequestForCustomerCopyWithImpl<RequestForCustomer>(this as RequestForCustomer, _$identity);

  /// Serializes this RequestForCustomer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestForCustomer&&(identical(other.id, id) || other.id == id)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.state, state) || other.state == state)&&(identical(other.category, category) || other.category == category)&&(identical(other.region, region) || other.region == region)&&(identical(other.weightIsApproximate, weightIsApproximate) || other.weightIsApproximate == weightIsApproximate)&&(identical(other.budgetIsFlexible, budgetIsFlexible) || other.budgetIsFlexible == budgetIsFlexible)&&(identical(other.offerCount, offerCount) || other.offerCount == offerCount)&&const DeepCollectionEquality().equals(other.media, media)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.weightGrams, weightGrams) || other.weightGrams == weightGrams)&&(identical(other.purityKarat, purityKarat) || other.purityKarat == purityKarat)&&(identical(other.ornamentType, ornamentType) || other.ornamentType == ornamentType)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.denominationGrams, denominationGrams) || other.denominationGrams == denominationGrams)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.mintOrRefiner, mintOrRefiner) || other.mintOrRefiner == mintOrRefiner)&&(identical(other.budgetMin, budgetMin) || other.budgetMin == budgetMin)&&(identical(other.budgetMax, budgetMax) || other.budgetMax == budgetMax)&&(identical(other.indicativeValue, indicativeValue) || other.indicativeValue == indicativeValue)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.acceptedOfferId, acceptedOfferId) || other.acceptedOfferId == acceptedOfferId)&&(identical(other.unreadOfferCount, unreadOfferCount) || other.unreadOfferCount == unreadOfferCount)&&(identical(other.connectionId, connectionId) || other.connectionId == connectionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,requestType,direction,state,category,region,weightIsApproximate,budgetIsFlexible,offerCount,const DeepCollectionEquality().hash(media),createdAt,updatedAt,reference,notes,weightGrams,purityKarat,ornamentType,condition,denominationGrams,quantity,mintOrRefiner,budgetMin,budgetMax,indicativeValue,publishedAt,expiresAt,cancellationReason,acceptedOfferId,unreadOfferCount,connectionId]);

@override
String toString() {
  return 'RequestForCustomer(id: $id, requestType: $requestType, direction: $direction, state: $state, category: $category, region: $region, weightIsApproximate: $weightIsApproximate, budgetIsFlexible: $budgetIsFlexible, offerCount: $offerCount, media: $media, createdAt: $createdAt, updatedAt: $updatedAt, reference: $reference, notes: $notes, weightGrams: $weightGrams, purityKarat: $purityKarat, ornamentType: $ornamentType, condition: $condition, denominationGrams: $denominationGrams, quantity: $quantity, mintOrRefiner: $mintOrRefiner, budgetMin: $budgetMin, budgetMax: $budgetMax, indicativeValue: $indicativeValue, publishedAt: $publishedAt, expiresAt: $expiresAt, cancellationReason: $cancellationReason, acceptedOfferId: $acceptedOfferId, unreadOfferCount: $unreadOfferCount, connectionId: $connectionId)';
}


}

/// @nodoc
abstract mixin class $RequestForCustomerCopyWith<$Res>  {
  factory $RequestForCustomerCopyWith(RequestForCustomer value, $Res Function(RequestForCustomer) _then) = _$RequestForCustomerCopyWithImpl;
@useResult
$Res call({
 String id,@_RequestTypeConverter() RequestType requestType,@_DirectionConverter() Direction direction,@_RequestStateConverter() RequestState state, CategorySummary category, RegionSummary region, bool weightIsApproximate, bool budgetIsFlexible, int offerCount, List<MediaRef> media, DateTime createdAt, DateTime updatedAt, String? reference, String? notes, String? weightGrams,@_NullableKaratConverter() Karat? purityKarat,@_NullableOrnamentTypeConverter() OrnamentType? ornamentType,@_NullableItemConditionConverter() ItemCondition? condition, String? denominationGrams, int? quantity, String? mintOrRefiner, String? budgetMin, String? budgetMax, String? indicativeValue, DateTime? publishedAt, DateTime? expiresAt, String? cancellationReason, String? acceptedOfferId, int? unreadOfferCount, String? connectionId
});


$CategorySummaryCopyWith<$Res> get category;$RegionSummaryCopyWith<$Res> get region;

}
/// @nodoc
class _$RequestForCustomerCopyWithImpl<$Res>
    implements $RequestForCustomerCopyWith<$Res> {
  _$RequestForCustomerCopyWithImpl(this._self, this._then);

  final RequestForCustomer _self;
  final $Res Function(RequestForCustomer) _then;

/// Create a copy of RequestForCustomer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? requestType = null,Object? direction = null,Object? state = null,Object? category = null,Object? region = null,Object? weightIsApproximate = null,Object? budgetIsFlexible = null,Object? offerCount = null,Object? media = null,Object? createdAt = null,Object? updatedAt = null,Object? reference = freezed,Object? notes = freezed,Object? weightGrams = freezed,Object? purityKarat = freezed,Object? ornamentType = freezed,Object? condition = freezed,Object? denominationGrams = freezed,Object? quantity = freezed,Object? mintOrRefiner = freezed,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? indicativeValue = freezed,Object? publishedAt = freezed,Object? expiresAt = freezed,Object? cancellationReason = freezed,Object? acceptedOfferId = freezed,Object? unreadOfferCount = freezed,Object? connectionId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,requestType: null == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as RequestType,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as Direction,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as RequestState,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategorySummary,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as RegionSummary,weightIsApproximate: null == weightIsApproximate ? _self.weightIsApproximate : weightIsApproximate // ignore: cast_nullable_to_non_nullable
as bool,budgetIsFlexible: null == budgetIsFlexible ? _self.budgetIsFlexible : budgetIsFlexible // ignore: cast_nullable_to_non_nullable
as bool,offerCount: null == offerCount ? _self.offerCount : offerCount // ignore: cast_nullable_to_non_nullable
as int,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as List<MediaRef>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,weightGrams: freezed == weightGrams ? _self.weightGrams : weightGrams // ignore: cast_nullable_to_non_nullable
as String?,purityKarat: freezed == purityKarat ? _self.purityKarat : purityKarat // ignore: cast_nullable_to_non_nullable
as Karat?,ornamentType: freezed == ornamentType ? _self.ornamentType : ornamentType // ignore: cast_nullable_to_non_nullable
as OrnamentType?,condition: freezed == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as ItemCondition?,denominationGrams: freezed == denominationGrams ? _self.denominationGrams : denominationGrams // ignore: cast_nullable_to_non_nullable
as String?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int?,mintOrRefiner: freezed == mintOrRefiner ? _self.mintOrRefiner : mintOrRefiner // ignore: cast_nullable_to_non_nullable
as String?,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin // ignore: cast_nullable_to_non_nullable
as String?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as String?,indicativeValue: freezed == indicativeValue ? _self.indicativeValue : indicativeValue // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,acceptedOfferId: freezed == acceptedOfferId ? _self.acceptedOfferId : acceptedOfferId // ignore: cast_nullable_to_non_nullable
as String?,unreadOfferCount: freezed == unreadOfferCount ? _self.unreadOfferCount : unreadOfferCount // ignore: cast_nullable_to_non_nullable
as int?,connectionId: freezed == connectionId ? _self.connectionId : connectionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RequestForCustomer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategorySummaryCopyWith<$Res> get category {
  
  return $CategorySummaryCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of RequestForCustomer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegionSummaryCopyWith<$Res> get region {
  
  return $RegionSummaryCopyWith<$Res>(_self.region, (value) {
    return _then(_self.copyWith(region: value));
  });
}
}


/// Adds pattern-matching-related methods to [RequestForCustomer].
extension RequestForCustomerPatterns on RequestForCustomer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestForCustomer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestForCustomer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestForCustomer value)  $default,){
final _that = this;
switch (_that) {
case _RequestForCustomer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestForCustomer value)?  $default,){
final _that = this;
switch (_that) {
case _RequestForCustomer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @_RequestTypeConverter()  RequestType requestType, @_DirectionConverter()  Direction direction, @_RequestStateConverter()  RequestState state,  CategorySummary category,  RegionSummary region,  bool weightIsApproximate,  bool budgetIsFlexible,  int offerCount,  List<MediaRef> media,  DateTime createdAt,  DateTime updatedAt,  String? reference,  String? notes,  String? weightGrams, @_NullableKaratConverter()  Karat? purityKarat, @_NullableOrnamentTypeConverter()  OrnamentType? ornamentType, @_NullableItemConditionConverter()  ItemCondition? condition,  String? denominationGrams,  int? quantity,  String? mintOrRefiner,  String? budgetMin,  String? budgetMax,  String? indicativeValue,  DateTime? publishedAt,  DateTime? expiresAt,  String? cancellationReason,  String? acceptedOfferId,  int? unreadOfferCount,  String? connectionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestForCustomer() when $default != null:
return $default(_that.id,_that.requestType,_that.direction,_that.state,_that.category,_that.region,_that.weightIsApproximate,_that.budgetIsFlexible,_that.offerCount,_that.media,_that.createdAt,_that.updatedAt,_that.reference,_that.notes,_that.weightGrams,_that.purityKarat,_that.ornamentType,_that.condition,_that.denominationGrams,_that.quantity,_that.mintOrRefiner,_that.budgetMin,_that.budgetMax,_that.indicativeValue,_that.publishedAt,_that.expiresAt,_that.cancellationReason,_that.acceptedOfferId,_that.unreadOfferCount,_that.connectionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @_RequestTypeConverter()  RequestType requestType, @_DirectionConverter()  Direction direction, @_RequestStateConverter()  RequestState state,  CategorySummary category,  RegionSummary region,  bool weightIsApproximate,  bool budgetIsFlexible,  int offerCount,  List<MediaRef> media,  DateTime createdAt,  DateTime updatedAt,  String? reference,  String? notes,  String? weightGrams, @_NullableKaratConverter()  Karat? purityKarat, @_NullableOrnamentTypeConverter()  OrnamentType? ornamentType, @_NullableItemConditionConverter()  ItemCondition? condition,  String? denominationGrams,  int? quantity,  String? mintOrRefiner,  String? budgetMin,  String? budgetMax,  String? indicativeValue,  DateTime? publishedAt,  DateTime? expiresAt,  String? cancellationReason,  String? acceptedOfferId,  int? unreadOfferCount,  String? connectionId)  $default,) {final _that = this;
switch (_that) {
case _RequestForCustomer():
return $default(_that.id,_that.requestType,_that.direction,_that.state,_that.category,_that.region,_that.weightIsApproximate,_that.budgetIsFlexible,_that.offerCount,_that.media,_that.createdAt,_that.updatedAt,_that.reference,_that.notes,_that.weightGrams,_that.purityKarat,_that.ornamentType,_that.condition,_that.denominationGrams,_that.quantity,_that.mintOrRefiner,_that.budgetMin,_that.budgetMax,_that.indicativeValue,_that.publishedAt,_that.expiresAt,_that.cancellationReason,_that.acceptedOfferId,_that.unreadOfferCount,_that.connectionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @_RequestTypeConverter()  RequestType requestType, @_DirectionConverter()  Direction direction, @_RequestStateConverter()  RequestState state,  CategorySummary category,  RegionSummary region,  bool weightIsApproximate,  bool budgetIsFlexible,  int offerCount,  List<MediaRef> media,  DateTime createdAt,  DateTime updatedAt,  String? reference,  String? notes,  String? weightGrams, @_NullableKaratConverter()  Karat? purityKarat, @_NullableOrnamentTypeConverter()  OrnamentType? ornamentType, @_NullableItemConditionConverter()  ItemCondition? condition,  String? denominationGrams,  int? quantity,  String? mintOrRefiner,  String? budgetMin,  String? budgetMax,  String? indicativeValue,  DateTime? publishedAt,  DateTime? expiresAt,  String? cancellationReason,  String? acceptedOfferId,  int? unreadOfferCount,  String? connectionId)?  $default,) {final _that = this;
switch (_that) {
case _RequestForCustomer() when $default != null:
return $default(_that.id,_that.requestType,_that.direction,_that.state,_that.category,_that.region,_that.weightIsApproximate,_that.budgetIsFlexible,_that.offerCount,_that.media,_that.createdAt,_that.updatedAt,_that.reference,_that.notes,_that.weightGrams,_that.purityKarat,_that.ornamentType,_that.condition,_that.denominationGrams,_that.quantity,_that.mintOrRefiner,_that.budgetMin,_that.budgetMax,_that.indicativeValue,_that.publishedAt,_that.expiresAt,_that.cancellationReason,_that.acceptedOfferId,_that.unreadOfferCount,_that.connectionId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RequestForCustomer implements RequestForCustomer {
  const _RequestForCustomer({required this.id, @_RequestTypeConverter() required this.requestType, @_DirectionConverter() required this.direction, @_RequestStateConverter() required this.state, required this.category, required this.region, required this.weightIsApproximate, required this.budgetIsFlexible, required this.offerCount, required final  List<MediaRef> media, required this.createdAt, required this.updatedAt, this.reference, this.notes, this.weightGrams, @_NullableKaratConverter() this.purityKarat, @_NullableOrnamentTypeConverter() this.ornamentType, @_NullableItemConditionConverter() this.condition, this.denominationGrams, this.quantity, this.mintOrRefiner, this.budgetMin, this.budgetMax, this.indicativeValue, this.publishedAt, this.expiresAt, this.cancellationReason, this.acceptedOfferId, this.unreadOfferCount, this.connectionId}): _media = media;
  factory _RequestForCustomer.fromJson(Map<String, dynamic> json) => _$RequestForCustomerFromJson(json);

@override final  String id;
@override@_RequestTypeConverter() final  RequestType requestType;
@override@_DirectionConverter() final  Direction direction;
@override@_RequestStateConverter() final  RequestState state;
@override final  CategorySummary category;
@override final  RegionSummary region;
@override final  bool weightIsApproximate;
@override final  bool budgetIsFlexible;
@override final  int offerCount;
 final  List<MediaRef> _media;
@override List<MediaRef> get media {
  if (_media is EqualUnmodifiableListView) return _media;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_media);
}

@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? reference;
@override final  String? notes;
@override final  String? weightGrams;
@override@_NullableKaratConverter() final  Karat? purityKarat;
@override@_NullableOrnamentTypeConverter() final  OrnamentType? ornamentType;
@override@_NullableItemConditionConverter() final  ItemCondition? condition;
@override final  String? denominationGrams;
@override final  int? quantity;
@override final  String? mintOrRefiner;
@override final  String? budgetMin;
@override final  String? budgetMax;
@override final  String? indicativeValue;
@override final  DateTime? publishedAt;
@override final  DateTime? expiresAt;
@override final  String? cancellationReason;
@override final  String? acceptedOfferId;
/// Absent on the wire → UI hides the unread marker (CM-K01 / SAM-GAP-1).
@override final  int? unreadOfferCount;
/// Absent unless ACCEPTED and the Connection join is present (SAM-GAP-3).
@override final  String? connectionId;

/// Create a copy of RequestForCustomer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestForCustomerCopyWith<_RequestForCustomer> get copyWith => __$RequestForCustomerCopyWithImpl<_RequestForCustomer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestForCustomerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestForCustomer&&(identical(other.id, id) || other.id == id)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.state, state) || other.state == state)&&(identical(other.category, category) || other.category == category)&&(identical(other.region, region) || other.region == region)&&(identical(other.weightIsApproximate, weightIsApproximate) || other.weightIsApproximate == weightIsApproximate)&&(identical(other.budgetIsFlexible, budgetIsFlexible) || other.budgetIsFlexible == budgetIsFlexible)&&(identical(other.offerCount, offerCount) || other.offerCount == offerCount)&&const DeepCollectionEquality().equals(other._media, _media)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.weightGrams, weightGrams) || other.weightGrams == weightGrams)&&(identical(other.purityKarat, purityKarat) || other.purityKarat == purityKarat)&&(identical(other.ornamentType, ornamentType) || other.ornamentType == ornamentType)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.denominationGrams, denominationGrams) || other.denominationGrams == denominationGrams)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.mintOrRefiner, mintOrRefiner) || other.mintOrRefiner == mintOrRefiner)&&(identical(other.budgetMin, budgetMin) || other.budgetMin == budgetMin)&&(identical(other.budgetMax, budgetMax) || other.budgetMax == budgetMax)&&(identical(other.indicativeValue, indicativeValue) || other.indicativeValue == indicativeValue)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.acceptedOfferId, acceptedOfferId) || other.acceptedOfferId == acceptedOfferId)&&(identical(other.unreadOfferCount, unreadOfferCount) || other.unreadOfferCount == unreadOfferCount)&&(identical(other.connectionId, connectionId) || other.connectionId == connectionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,requestType,direction,state,category,region,weightIsApproximate,budgetIsFlexible,offerCount,const DeepCollectionEquality().hash(_media),createdAt,updatedAt,reference,notes,weightGrams,purityKarat,ornamentType,condition,denominationGrams,quantity,mintOrRefiner,budgetMin,budgetMax,indicativeValue,publishedAt,expiresAt,cancellationReason,acceptedOfferId,unreadOfferCount,connectionId]);

@override
String toString() {
  return 'RequestForCustomer(id: $id, requestType: $requestType, direction: $direction, state: $state, category: $category, region: $region, weightIsApproximate: $weightIsApproximate, budgetIsFlexible: $budgetIsFlexible, offerCount: $offerCount, media: $media, createdAt: $createdAt, updatedAt: $updatedAt, reference: $reference, notes: $notes, weightGrams: $weightGrams, purityKarat: $purityKarat, ornamentType: $ornamentType, condition: $condition, denominationGrams: $denominationGrams, quantity: $quantity, mintOrRefiner: $mintOrRefiner, budgetMin: $budgetMin, budgetMax: $budgetMax, indicativeValue: $indicativeValue, publishedAt: $publishedAt, expiresAt: $expiresAt, cancellationReason: $cancellationReason, acceptedOfferId: $acceptedOfferId, unreadOfferCount: $unreadOfferCount, connectionId: $connectionId)';
}


}

/// @nodoc
abstract mixin class _$RequestForCustomerCopyWith<$Res> implements $RequestForCustomerCopyWith<$Res> {
  factory _$RequestForCustomerCopyWith(_RequestForCustomer value, $Res Function(_RequestForCustomer) _then) = __$RequestForCustomerCopyWithImpl;
@override @useResult
$Res call({
 String id,@_RequestTypeConverter() RequestType requestType,@_DirectionConverter() Direction direction,@_RequestStateConverter() RequestState state, CategorySummary category, RegionSummary region, bool weightIsApproximate, bool budgetIsFlexible, int offerCount, List<MediaRef> media, DateTime createdAt, DateTime updatedAt, String? reference, String? notes, String? weightGrams,@_NullableKaratConverter() Karat? purityKarat,@_NullableOrnamentTypeConverter() OrnamentType? ornamentType,@_NullableItemConditionConverter() ItemCondition? condition, String? denominationGrams, int? quantity, String? mintOrRefiner, String? budgetMin, String? budgetMax, String? indicativeValue, DateTime? publishedAt, DateTime? expiresAt, String? cancellationReason, String? acceptedOfferId, int? unreadOfferCount, String? connectionId
});


@override $CategorySummaryCopyWith<$Res> get category;@override $RegionSummaryCopyWith<$Res> get region;

}
/// @nodoc
class __$RequestForCustomerCopyWithImpl<$Res>
    implements _$RequestForCustomerCopyWith<$Res> {
  __$RequestForCustomerCopyWithImpl(this._self, this._then);

  final _RequestForCustomer _self;
  final $Res Function(_RequestForCustomer) _then;

/// Create a copy of RequestForCustomer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? requestType = null,Object? direction = null,Object? state = null,Object? category = null,Object? region = null,Object? weightIsApproximate = null,Object? budgetIsFlexible = null,Object? offerCount = null,Object? media = null,Object? createdAt = null,Object? updatedAt = null,Object? reference = freezed,Object? notes = freezed,Object? weightGrams = freezed,Object? purityKarat = freezed,Object? ornamentType = freezed,Object? condition = freezed,Object? denominationGrams = freezed,Object? quantity = freezed,Object? mintOrRefiner = freezed,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? indicativeValue = freezed,Object? publishedAt = freezed,Object? expiresAt = freezed,Object? cancellationReason = freezed,Object? acceptedOfferId = freezed,Object? unreadOfferCount = freezed,Object? connectionId = freezed,}) {
  return _then(_RequestForCustomer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,requestType: null == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as RequestType,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as Direction,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as RequestState,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategorySummary,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as RegionSummary,weightIsApproximate: null == weightIsApproximate ? _self.weightIsApproximate : weightIsApproximate // ignore: cast_nullable_to_non_nullable
as bool,budgetIsFlexible: null == budgetIsFlexible ? _self.budgetIsFlexible : budgetIsFlexible // ignore: cast_nullable_to_non_nullable
as bool,offerCount: null == offerCount ? _self.offerCount : offerCount // ignore: cast_nullable_to_non_nullable
as int,media: null == media ? _self._media : media // ignore: cast_nullable_to_non_nullable
as List<MediaRef>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,weightGrams: freezed == weightGrams ? _self.weightGrams : weightGrams // ignore: cast_nullable_to_non_nullable
as String?,purityKarat: freezed == purityKarat ? _self.purityKarat : purityKarat // ignore: cast_nullable_to_non_nullable
as Karat?,ornamentType: freezed == ornamentType ? _self.ornamentType : ornamentType // ignore: cast_nullable_to_non_nullable
as OrnamentType?,condition: freezed == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as ItemCondition?,denominationGrams: freezed == denominationGrams ? _self.denominationGrams : denominationGrams // ignore: cast_nullable_to_non_nullable
as String?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int?,mintOrRefiner: freezed == mintOrRefiner ? _self.mintOrRefiner : mintOrRefiner // ignore: cast_nullable_to_non_nullable
as String?,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin // ignore: cast_nullable_to_non_nullable
as String?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as String?,indicativeValue: freezed == indicativeValue ? _self.indicativeValue : indicativeValue // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,acceptedOfferId: freezed == acceptedOfferId ? _self.acceptedOfferId : acceptedOfferId // ignore: cast_nullable_to_non_nullable
as String?,unreadOfferCount: freezed == unreadOfferCount ? _self.unreadOfferCount : unreadOfferCount // ignore: cast_nullable_to_non_nullable
as int?,connectionId: freezed == connectionId ? _self.connectionId : connectionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RequestForCustomer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategorySummaryCopyWith<$Res> get category {
  
  return $CategorySummaryCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of RequestForCustomer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegionSummaryCopyWith<$Res> get region {
  
  return $RegionSummaryCopyWith<$Res>(_self.region, (value) {
    return _then(_self.copyWith(region: value));
  });
}
}

// dart format on
