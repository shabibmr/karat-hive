// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offer_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MaskedVendorDto {

 String get label; RegionSummaryDto? get region; int get connectionCount; RatingSummaryDto? get rating;
/// Create a copy of MaskedVendorDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaskedVendorDtoCopyWith<MaskedVendorDto> get copyWith => _$MaskedVendorDtoCopyWithImpl<MaskedVendorDto>(this as MaskedVendorDto, _$identity);

  /// Serializes this MaskedVendorDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaskedVendorDto&&(identical(other.label, label) || other.label == label)&&(identical(other.region, region) || other.region == region)&&(identical(other.connectionCount, connectionCount) || other.connectionCount == connectionCount)&&(identical(other.rating, rating) || other.rating == rating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,region,connectionCount,rating);

@override
String toString() {
  return 'MaskedVendorDto(label: $label, region: $region, connectionCount: $connectionCount, rating: $rating)';
}


}

/// @nodoc
abstract mixin class $MaskedVendorDtoCopyWith<$Res>  {
  factory $MaskedVendorDtoCopyWith(MaskedVendorDto value, $Res Function(MaskedVendorDto) _then) = _$MaskedVendorDtoCopyWithImpl;
@useResult
$Res call({
 String label, RegionSummaryDto? region, int connectionCount, RatingSummaryDto? rating
});


$RegionSummaryDtoCopyWith<$Res>? get region;$RatingSummaryDtoCopyWith<$Res>? get rating;

}
/// @nodoc
class _$MaskedVendorDtoCopyWithImpl<$Res>
    implements $MaskedVendorDtoCopyWith<$Res> {
  _$MaskedVendorDtoCopyWithImpl(this._self, this._then);

  final MaskedVendorDto _self;
  final $Res Function(MaskedVendorDto) _then;

/// Create a copy of MaskedVendorDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? region = freezed,Object? connectionCount = null,Object? rating = freezed,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as RegionSummaryDto?,connectionCount: null == connectionCount ? _self.connectionCount : connectionCount // ignore: cast_nullable_to_non_nullable
as int,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as RatingSummaryDto?,
  ));
}
/// Create a copy of MaskedVendorDto
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
}/// Create a copy of MaskedVendorDto
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


/// Adds pattern-matching-related methods to [MaskedVendorDto].
extension MaskedVendorDtoPatterns on MaskedVendorDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MaskedVendorDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MaskedVendorDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MaskedVendorDto value)  $default,){
final _that = this;
switch (_that) {
case _MaskedVendorDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MaskedVendorDto value)?  $default,){
final _that = this;
switch (_that) {
case _MaskedVendorDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  RegionSummaryDto? region,  int connectionCount,  RatingSummaryDto? rating)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MaskedVendorDto() when $default != null:
return $default(_that.label,_that.region,_that.connectionCount,_that.rating);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  RegionSummaryDto? region,  int connectionCount,  RatingSummaryDto? rating)  $default,) {final _that = this;
switch (_that) {
case _MaskedVendorDto():
return $default(_that.label,_that.region,_that.connectionCount,_that.rating);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  RegionSummaryDto? region,  int connectionCount,  RatingSummaryDto? rating)?  $default,) {final _that = this;
switch (_that) {
case _MaskedVendorDto() when $default != null:
return $default(_that.label,_that.region,_that.connectionCount,_that.rating);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MaskedVendorDto implements MaskedVendorDto {
  const _MaskedVendorDto({required this.label, this.region, required this.connectionCount, this.rating});
  factory _MaskedVendorDto.fromJson(Map<String, dynamic> json) => _$MaskedVendorDtoFromJson(json);

@override final  String label;
@override final  RegionSummaryDto? region;
@override final  int connectionCount;
@override final  RatingSummaryDto? rating;

/// Create a copy of MaskedVendorDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaskedVendorDtoCopyWith<_MaskedVendorDto> get copyWith => __$MaskedVendorDtoCopyWithImpl<_MaskedVendorDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaskedVendorDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaskedVendorDto&&(identical(other.label, label) || other.label == label)&&(identical(other.region, region) || other.region == region)&&(identical(other.connectionCount, connectionCount) || other.connectionCount == connectionCount)&&(identical(other.rating, rating) || other.rating == rating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,region,connectionCount,rating);

@override
String toString() {
  return 'MaskedVendorDto(label: $label, region: $region, connectionCount: $connectionCount, rating: $rating)';
}


}

/// @nodoc
abstract mixin class _$MaskedVendorDtoCopyWith<$Res> implements $MaskedVendorDtoCopyWith<$Res> {
  factory _$MaskedVendorDtoCopyWith(_MaskedVendorDto value, $Res Function(_MaskedVendorDto) _then) = __$MaskedVendorDtoCopyWithImpl;
@override @useResult
$Res call({
 String label, RegionSummaryDto? region, int connectionCount, RatingSummaryDto? rating
});


@override $RegionSummaryDtoCopyWith<$Res>? get region;@override $RatingSummaryDtoCopyWith<$Res>? get rating;

}
/// @nodoc
class __$MaskedVendorDtoCopyWithImpl<$Res>
    implements _$MaskedVendorDtoCopyWith<$Res> {
  __$MaskedVendorDtoCopyWithImpl(this._self, this._then);

  final _MaskedVendorDto _self;
  final $Res Function(_MaskedVendorDto) _then;

/// Create a copy of MaskedVendorDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? region = freezed,Object? connectionCount = null,Object? rating = freezed,}) {
  return _then(_MaskedVendorDto(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as RegionSummaryDto?,connectionCount: null == connectionCount ? _self.connectionCount : connectionCount // ignore: cast_nullable_to_non_nullable
as int,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as RatingSummaryDto?,
  ));
}

/// Create a copy of MaskedVendorDto
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
}/// Create a copy of MaskedVendorDto
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
mixin _$CustomerOfferDto {

 String get id; String get requestId; String get state; DateTime get submittedAt; DateTime get expiresAt; DateTime? get decidedAt; int get revisionCount; DateTime? get viewedByCustomerAt; OfferTermsDto get terms; List<MediaRefDto> get media; MaskedVendorDto get vendor;
/// Create a copy of CustomerOfferDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerOfferDtoCopyWith<CustomerOfferDto> get copyWith => _$CustomerOfferDtoCopyWithImpl<CustomerOfferDto>(this as CustomerOfferDto, _$identity);

  /// Serializes this CustomerOfferDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerOfferDto&&(identical(other.id, id) || other.id == id)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.state, state) || other.state == state)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.revisionCount, revisionCount) || other.revisionCount == revisionCount)&&(identical(other.viewedByCustomerAt, viewedByCustomerAt) || other.viewedByCustomerAt == viewedByCustomerAt)&&(identical(other.terms, terms) || other.terms == terms)&&const DeepCollectionEquality().equals(other.media, media)&&(identical(other.vendor, vendor) || other.vendor == vendor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,requestId,state,submittedAt,expiresAt,decidedAt,revisionCount,viewedByCustomerAt,terms,const DeepCollectionEquality().hash(media),vendor);

@override
String toString() {
  return 'CustomerOfferDto(id: $id, requestId: $requestId, state: $state, submittedAt: $submittedAt, expiresAt: $expiresAt, decidedAt: $decidedAt, revisionCount: $revisionCount, viewedByCustomerAt: $viewedByCustomerAt, terms: $terms, media: $media, vendor: $vendor)';
}


}

/// @nodoc
abstract mixin class $CustomerOfferDtoCopyWith<$Res>  {
  factory $CustomerOfferDtoCopyWith(CustomerOfferDto value, $Res Function(CustomerOfferDto) _then) = _$CustomerOfferDtoCopyWithImpl;
@useResult
$Res call({
 String id, String requestId, String state, DateTime submittedAt, DateTime expiresAt, DateTime? decidedAt, int revisionCount, DateTime? viewedByCustomerAt, OfferTermsDto terms, List<MediaRefDto> media, MaskedVendorDto vendor
});


$OfferTermsDtoCopyWith<$Res> get terms;$MaskedVendorDtoCopyWith<$Res> get vendor;

}
/// @nodoc
class _$CustomerOfferDtoCopyWithImpl<$Res>
    implements $CustomerOfferDtoCopyWith<$Res> {
  _$CustomerOfferDtoCopyWithImpl(this._self, this._then);

  final CustomerOfferDto _self;
  final $Res Function(CustomerOfferDto) _then;

/// Create a copy of CustomerOfferDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? requestId = null,Object? state = null,Object? submittedAt = null,Object? expiresAt = null,Object? decidedAt = freezed,Object? revisionCount = null,Object? viewedByCustomerAt = freezed,Object? terms = null,Object? media = null,Object? vendor = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,revisionCount: null == revisionCount ? _self.revisionCount : revisionCount // ignore: cast_nullable_to_non_nullable
as int,viewedByCustomerAt: freezed == viewedByCustomerAt ? _self.viewedByCustomerAt : viewedByCustomerAt // ignore: cast_nullable_to_non_nullable
as DateTime?,terms: null == terms ? _self.terms : terms // ignore: cast_nullable_to_non_nullable
as OfferTermsDto,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as List<MediaRefDto>,vendor: null == vendor ? _self.vendor : vendor // ignore: cast_nullable_to_non_nullable
as MaskedVendorDto,
  ));
}
/// Create a copy of CustomerOfferDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferTermsDtoCopyWith<$Res> get terms {
  
  return $OfferTermsDtoCopyWith<$Res>(_self.terms, (value) {
    return _then(_self.copyWith(terms: value));
  });
}/// Create a copy of CustomerOfferDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MaskedVendorDtoCopyWith<$Res> get vendor {
  
  return $MaskedVendorDtoCopyWith<$Res>(_self.vendor, (value) {
    return _then(_self.copyWith(vendor: value));
  });
}
}


/// Adds pattern-matching-related methods to [CustomerOfferDto].
extension CustomerOfferDtoPatterns on CustomerOfferDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerOfferDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerOfferDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerOfferDto value)  $default,){
final _that = this;
switch (_that) {
case _CustomerOfferDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerOfferDto value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerOfferDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String requestId,  String state,  DateTime submittedAt,  DateTime expiresAt,  DateTime? decidedAt,  int revisionCount,  DateTime? viewedByCustomerAt,  OfferTermsDto terms,  List<MediaRefDto> media,  MaskedVendorDto vendor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerOfferDto() when $default != null:
return $default(_that.id,_that.requestId,_that.state,_that.submittedAt,_that.expiresAt,_that.decidedAt,_that.revisionCount,_that.viewedByCustomerAt,_that.terms,_that.media,_that.vendor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String requestId,  String state,  DateTime submittedAt,  DateTime expiresAt,  DateTime? decidedAt,  int revisionCount,  DateTime? viewedByCustomerAt,  OfferTermsDto terms,  List<MediaRefDto> media,  MaskedVendorDto vendor)  $default,) {final _that = this;
switch (_that) {
case _CustomerOfferDto():
return $default(_that.id,_that.requestId,_that.state,_that.submittedAt,_that.expiresAt,_that.decidedAt,_that.revisionCount,_that.viewedByCustomerAt,_that.terms,_that.media,_that.vendor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String requestId,  String state,  DateTime submittedAt,  DateTime expiresAt,  DateTime? decidedAt,  int revisionCount,  DateTime? viewedByCustomerAt,  OfferTermsDto terms,  List<MediaRefDto> media,  MaskedVendorDto vendor)?  $default,) {final _that = this;
switch (_that) {
case _CustomerOfferDto() when $default != null:
return $default(_that.id,_that.requestId,_that.state,_that.submittedAt,_that.expiresAt,_that.decidedAt,_that.revisionCount,_that.viewedByCustomerAt,_that.terms,_that.media,_that.vendor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomerOfferDto extends CustomerOfferDto {
  const _CustomerOfferDto({required this.id, required this.requestId, required this.state, required this.submittedAt, required this.expiresAt, this.decidedAt, required this.revisionCount, this.viewedByCustomerAt, required this.terms, final  List<MediaRefDto> media = const <MediaRefDto>[], required this.vendor}): _media = media,super._();
  factory _CustomerOfferDto.fromJson(Map<String, dynamic> json) => _$CustomerOfferDtoFromJson(json);

@override final  String id;
@override final  String requestId;
@override final  String state;
@override final  DateTime submittedAt;
@override final  DateTime expiresAt;
@override final  DateTime? decidedAt;
@override final  int revisionCount;
@override final  DateTime? viewedByCustomerAt;
@override final  OfferTermsDto terms;
 final  List<MediaRefDto> _media;
@override@JsonKey() List<MediaRefDto> get media {
  if (_media is EqualUnmodifiableListView) return _media;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_media);
}

@override final  MaskedVendorDto vendor;

/// Create a copy of CustomerOfferDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerOfferDtoCopyWith<_CustomerOfferDto> get copyWith => __$CustomerOfferDtoCopyWithImpl<_CustomerOfferDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomerOfferDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerOfferDto&&(identical(other.id, id) || other.id == id)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.state, state) || other.state == state)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.revisionCount, revisionCount) || other.revisionCount == revisionCount)&&(identical(other.viewedByCustomerAt, viewedByCustomerAt) || other.viewedByCustomerAt == viewedByCustomerAt)&&(identical(other.terms, terms) || other.terms == terms)&&const DeepCollectionEquality().equals(other._media, _media)&&(identical(other.vendor, vendor) || other.vendor == vendor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,requestId,state,submittedAt,expiresAt,decidedAt,revisionCount,viewedByCustomerAt,terms,const DeepCollectionEquality().hash(_media),vendor);

@override
String toString() {
  return 'CustomerOfferDto(id: $id, requestId: $requestId, state: $state, submittedAt: $submittedAt, expiresAt: $expiresAt, decidedAt: $decidedAt, revisionCount: $revisionCount, viewedByCustomerAt: $viewedByCustomerAt, terms: $terms, media: $media, vendor: $vendor)';
}


}

/// @nodoc
abstract mixin class _$CustomerOfferDtoCopyWith<$Res> implements $CustomerOfferDtoCopyWith<$Res> {
  factory _$CustomerOfferDtoCopyWith(_CustomerOfferDto value, $Res Function(_CustomerOfferDto) _then) = __$CustomerOfferDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String requestId, String state, DateTime submittedAt, DateTime expiresAt, DateTime? decidedAt, int revisionCount, DateTime? viewedByCustomerAt, OfferTermsDto terms, List<MediaRefDto> media, MaskedVendorDto vendor
});


@override $OfferTermsDtoCopyWith<$Res> get terms;@override $MaskedVendorDtoCopyWith<$Res> get vendor;

}
/// @nodoc
class __$CustomerOfferDtoCopyWithImpl<$Res>
    implements _$CustomerOfferDtoCopyWith<$Res> {
  __$CustomerOfferDtoCopyWithImpl(this._self, this._then);

  final _CustomerOfferDto _self;
  final $Res Function(_CustomerOfferDto) _then;

/// Create a copy of CustomerOfferDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? requestId = null,Object? state = null,Object? submittedAt = null,Object? expiresAt = null,Object? decidedAt = freezed,Object? revisionCount = null,Object? viewedByCustomerAt = freezed,Object? terms = null,Object? media = null,Object? vendor = null,}) {
  return _then(_CustomerOfferDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,revisionCount: null == revisionCount ? _self.revisionCount : revisionCount // ignore: cast_nullable_to_non_nullable
as int,viewedByCustomerAt: freezed == viewedByCustomerAt ? _self.viewedByCustomerAt : viewedByCustomerAt // ignore: cast_nullable_to_non_nullable
as DateTime?,terms: null == terms ? _self.terms : terms // ignore: cast_nullable_to_non_nullable
as OfferTermsDto,media: null == media ? _self._media : media // ignore: cast_nullable_to_non_nullable
as List<MediaRefDto>,vendor: null == vendor ? _self.vendor : vendor // ignore: cast_nullable_to_non_nullable
as MaskedVendorDto,
  ));
}

/// Create a copy of CustomerOfferDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferTermsDtoCopyWith<$Res> get terms {
  
  return $OfferTermsDtoCopyWith<$Res>(_self.terms, (value) {
    return _then(_self.copyWith(terms: value));
  });
}/// Create a copy of CustomerOfferDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MaskedVendorDtoCopyWith<$Res> get vendor {
  
  return $MaskedVendorDtoCopyWith<$Res>(_self.vendor, (value) {
    return _then(_self.copyWith(vendor: value));
  });
}
}


/// @nodoc
mixin _$VendorRatingSummaryDto {

 MaskedVendorDto get vendor; List<VendorRatingReviewDto> get reviews;
/// Create a copy of VendorRatingSummaryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorRatingSummaryDtoCopyWith<VendorRatingSummaryDto> get copyWith => _$VendorRatingSummaryDtoCopyWithImpl<VendorRatingSummaryDto>(this as VendorRatingSummaryDto, _$identity);

  /// Serializes this VendorRatingSummaryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorRatingSummaryDto&&(identical(other.vendor, vendor) || other.vendor == vendor)&&const DeepCollectionEquality().equals(other.reviews, reviews));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vendor,const DeepCollectionEquality().hash(reviews));

@override
String toString() {
  return 'VendorRatingSummaryDto(vendor: $vendor, reviews: $reviews)';
}


}

/// @nodoc
abstract mixin class $VendorRatingSummaryDtoCopyWith<$Res>  {
  factory $VendorRatingSummaryDtoCopyWith(VendorRatingSummaryDto value, $Res Function(VendorRatingSummaryDto) _then) = _$VendorRatingSummaryDtoCopyWithImpl;
@useResult
$Res call({
 MaskedVendorDto vendor, List<VendorRatingReviewDto> reviews
});


$MaskedVendorDtoCopyWith<$Res> get vendor;

}
/// @nodoc
class _$VendorRatingSummaryDtoCopyWithImpl<$Res>
    implements $VendorRatingSummaryDtoCopyWith<$Res> {
  _$VendorRatingSummaryDtoCopyWithImpl(this._self, this._then);

  final VendorRatingSummaryDto _self;
  final $Res Function(VendorRatingSummaryDto) _then;

/// Create a copy of VendorRatingSummaryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? vendor = null,Object? reviews = null,}) {
  return _then(_self.copyWith(
vendor: null == vendor ? _self.vendor : vendor // ignore: cast_nullable_to_non_nullable
as MaskedVendorDto,reviews: null == reviews ? _self.reviews : reviews // ignore: cast_nullable_to_non_nullable
as List<VendorRatingReviewDto>,
  ));
}
/// Create a copy of VendorRatingSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MaskedVendorDtoCopyWith<$Res> get vendor {
  
  return $MaskedVendorDtoCopyWith<$Res>(_self.vendor, (value) {
    return _then(_self.copyWith(vendor: value));
  });
}
}


/// Adds pattern-matching-related methods to [VendorRatingSummaryDto].
extension VendorRatingSummaryDtoPatterns on VendorRatingSummaryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorRatingSummaryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorRatingSummaryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorRatingSummaryDto value)  $default,){
final _that = this;
switch (_that) {
case _VendorRatingSummaryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorRatingSummaryDto value)?  $default,){
final _that = this;
switch (_that) {
case _VendorRatingSummaryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MaskedVendorDto vendor,  List<VendorRatingReviewDto> reviews)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorRatingSummaryDto() when $default != null:
return $default(_that.vendor,_that.reviews);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MaskedVendorDto vendor,  List<VendorRatingReviewDto> reviews)  $default,) {final _that = this;
switch (_that) {
case _VendorRatingSummaryDto():
return $default(_that.vendor,_that.reviews);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MaskedVendorDto vendor,  List<VendorRatingReviewDto> reviews)?  $default,) {final _that = this;
switch (_that) {
case _VendorRatingSummaryDto() when $default != null:
return $default(_that.vendor,_that.reviews);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VendorRatingSummaryDto implements VendorRatingSummaryDto {
  const _VendorRatingSummaryDto({required this.vendor, required final  List<VendorRatingReviewDto> reviews}): _reviews = reviews;
  factory _VendorRatingSummaryDto.fromJson(Map<String, dynamic> json) => _$VendorRatingSummaryDtoFromJson(json);

@override final  MaskedVendorDto vendor;
 final  List<VendorRatingReviewDto> _reviews;
@override List<VendorRatingReviewDto> get reviews {
  if (_reviews is EqualUnmodifiableListView) return _reviews;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reviews);
}


/// Create a copy of VendorRatingSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorRatingSummaryDtoCopyWith<_VendorRatingSummaryDto> get copyWith => __$VendorRatingSummaryDtoCopyWithImpl<_VendorRatingSummaryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VendorRatingSummaryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorRatingSummaryDto&&(identical(other.vendor, vendor) || other.vendor == vendor)&&const DeepCollectionEquality().equals(other._reviews, _reviews));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vendor,const DeepCollectionEquality().hash(_reviews));

@override
String toString() {
  return 'VendorRatingSummaryDto(vendor: $vendor, reviews: $reviews)';
}


}

/// @nodoc
abstract mixin class _$VendorRatingSummaryDtoCopyWith<$Res> implements $VendorRatingSummaryDtoCopyWith<$Res> {
  factory _$VendorRatingSummaryDtoCopyWith(_VendorRatingSummaryDto value, $Res Function(_VendorRatingSummaryDto) _then) = __$VendorRatingSummaryDtoCopyWithImpl;
@override @useResult
$Res call({
 MaskedVendorDto vendor, List<VendorRatingReviewDto> reviews
});


@override $MaskedVendorDtoCopyWith<$Res> get vendor;

}
/// @nodoc
class __$VendorRatingSummaryDtoCopyWithImpl<$Res>
    implements _$VendorRatingSummaryDtoCopyWith<$Res> {
  __$VendorRatingSummaryDtoCopyWithImpl(this._self, this._then);

  final _VendorRatingSummaryDto _self;
  final $Res Function(_VendorRatingSummaryDto) _then;

/// Create a copy of VendorRatingSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vendor = null,Object? reviews = null,}) {
  return _then(_VendorRatingSummaryDto(
vendor: null == vendor ? _self.vendor : vendor // ignore: cast_nullable_to_non_nullable
as MaskedVendorDto,reviews: null == reviews ? _self._reviews : reviews // ignore: cast_nullable_to_non_nullable
as List<VendorRatingReviewDto>,
  ));
}

/// Create a copy of VendorRatingSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MaskedVendorDtoCopyWith<$Res> get vendor {
  
  return $MaskedVendorDtoCopyWith<$Res>(_self.vendor, (value) {
    return _then(_self.copyWith(vendor: value));
  });
}
}


/// @nodoc
mixin _$VendorRatingReviewDto {

 String get id; int get rating; String? get comment; DateTime? get publishedAt; String get reviewerLabel;
/// Create a copy of VendorRatingReviewDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorRatingReviewDtoCopyWith<VendorRatingReviewDto> get copyWith => _$VendorRatingReviewDtoCopyWithImpl<VendorRatingReviewDto>(this as VendorRatingReviewDto, _$identity);

  /// Serializes this VendorRatingReviewDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorRatingReviewDto&&(identical(other.id, id) || other.id == id)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.reviewerLabel, reviewerLabel) || other.reviewerLabel == reviewerLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rating,comment,publishedAt,reviewerLabel);

@override
String toString() {
  return 'VendorRatingReviewDto(id: $id, rating: $rating, comment: $comment, publishedAt: $publishedAt, reviewerLabel: $reviewerLabel)';
}


}

/// @nodoc
abstract mixin class $VendorRatingReviewDtoCopyWith<$Res>  {
  factory $VendorRatingReviewDtoCopyWith(VendorRatingReviewDto value, $Res Function(VendorRatingReviewDto) _then) = _$VendorRatingReviewDtoCopyWithImpl;
@useResult
$Res call({
 String id, int rating, String? comment, DateTime? publishedAt, String reviewerLabel
});




}
/// @nodoc
class _$VendorRatingReviewDtoCopyWithImpl<$Res>
    implements $VendorRatingReviewDtoCopyWith<$Res> {
  _$VendorRatingReviewDtoCopyWithImpl(this._self, this._then);

  final VendorRatingReviewDto _self;
  final $Res Function(VendorRatingReviewDto) _then;

/// Create a copy of VendorRatingReviewDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rating = null,Object? comment = freezed,Object? publishedAt = freezed,Object? reviewerLabel = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewerLabel: null == reviewerLabel ? _self.reviewerLabel : reviewerLabel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VendorRatingReviewDto].
extension VendorRatingReviewDtoPatterns on VendorRatingReviewDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorRatingReviewDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorRatingReviewDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorRatingReviewDto value)  $default,){
final _that = this;
switch (_that) {
case _VendorRatingReviewDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorRatingReviewDto value)?  $default,){
final _that = this;
switch (_that) {
case _VendorRatingReviewDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int rating,  String? comment,  DateTime? publishedAt,  String reviewerLabel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorRatingReviewDto() when $default != null:
return $default(_that.id,_that.rating,_that.comment,_that.publishedAt,_that.reviewerLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int rating,  String? comment,  DateTime? publishedAt,  String reviewerLabel)  $default,) {final _that = this;
switch (_that) {
case _VendorRatingReviewDto():
return $default(_that.id,_that.rating,_that.comment,_that.publishedAt,_that.reviewerLabel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int rating,  String? comment,  DateTime? publishedAt,  String reviewerLabel)?  $default,) {final _that = this;
switch (_that) {
case _VendorRatingReviewDto() when $default != null:
return $default(_that.id,_that.rating,_that.comment,_that.publishedAt,_that.reviewerLabel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VendorRatingReviewDto implements VendorRatingReviewDto {
  const _VendorRatingReviewDto({required this.id, required this.rating, this.comment, this.publishedAt, required this.reviewerLabel});
  factory _VendorRatingReviewDto.fromJson(Map<String, dynamic> json) => _$VendorRatingReviewDtoFromJson(json);

@override final  String id;
@override final  int rating;
@override final  String? comment;
@override final  DateTime? publishedAt;
@override final  String reviewerLabel;

/// Create a copy of VendorRatingReviewDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorRatingReviewDtoCopyWith<_VendorRatingReviewDto> get copyWith => __$VendorRatingReviewDtoCopyWithImpl<_VendorRatingReviewDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VendorRatingReviewDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorRatingReviewDto&&(identical(other.id, id) || other.id == id)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.reviewerLabel, reviewerLabel) || other.reviewerLabel == reviewerLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rating,comment,publishedAt,reviewerLabel);

@override
String toString() {
  return 'VendorRatingReviewDto(id: $id, rating: $rating, comment: $comment, publishedAt: $publishedAt, reviewerLabel: $reviewerLabel)';
}


}

/// @nodoc
abstract mixin class _$VendorRatingReviewDtoCopyWith<$Res> implements $VendorRatingReviewDtoCopyWith<$Res> {
  factory _$VendorRatingReviewDtoCopyWith(_VendorRatingReviewDto value, $Res Function(_VendorRatingReviewDto) _then) = __$VendorRatingReviewDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, int rating, String? comment, DateTime? publishedAt, String reviewerLabel
});




}
/// @nodoc
class __$VendorRatingReviewDtoCopyWithImpl<$Res>
    implements _$VendorRatingReviewDtoCopyWith<$Res> {
  __$VendorRatingReviewDtoCopyWithImpl(this._self, this._then);

  final _VendorRatingReviewDto _self;
  final $Res Function(_VendorRatingReviewDto) _then;

/// Create a copy of VendorRatingReviewDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rating = null,Object? comment = freezed,Object? publishedAt = freezed,Object? reviewerLabel = null,}) {
  return _then(_VendorRatingReviewDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewerLabel: null == reviewerLabel ? _self.reviewerLabel : reviewerLabel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
