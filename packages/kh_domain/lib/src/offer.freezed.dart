// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OfferTerms {

 String get offeredPrice; int get validityHours; String? get weightGrams; String? get makingCharges; String? get ratePerGram; String? get deliveryTimeframe; String? get warrantyTerms; String? get vendorNote; List<MediaRef> get media;
/// Create a copy of OfferTerms
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferTermsCopyWith<OfferTerms> get copyWith => _$OfferTermsCopyWithImpl<OfferTerms>(this as OfferTerms, _$identity);

  /// Serializes this OfferTerms to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferTerms&&(identical(other.offeredPrice, offeredPrice) || other.offeredPrice == offeredPrice)&&(identical(other.validityHours, validityHours) || other.validityHours == validityHours)&&(identical(other.weightGrams, weightGrams) || other.weightGrams == weightGrams)&&(identical(other.makingCharges, makingCharges) || other.makingCharges == makingCharges)&&(identical(other.ratePerGram, ratePerGram) || other.ratePerGram == ratePerGram)&&(identical(other.deliveryTimeframe, deliveryTimeframe) || other.deliveryTimeframe == deliveryTimeframe)&&(identical(other.warrantyTerms, warrantyTerms) || other.warrantyTerms == warrantyTerms)&&(identical(other.vendorNote, vendorNote) || other.vendorNote == vendorNote)&&const DeepCollectionEquality().equals(other.media, media));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,offeredPrice,validityHours,weightGrams,makingCharges,ratePerGram,deliveryTimeframe,warrantyTerms,vendorNote,const DeepCollectionEquality().hash(media));

@override
String toString() {
  return 'OfferTerms(offeredPrice: $offeredPrice, validityHours: $validityHours, weightGrams: $weightGrams, makingCharges: $makingCharges, ratePerGram: $ratePerGram, deliveryTimeframe: $deliveryTimeframe, warrantyTerms: $warrantyTerms, vendorNote: $vendorNote, media: $media)';
}


}

/// @nodoc
abstract mixin class $OfferTermsCopyWith<$Res>  {
  factory $OfferTermsCopyWith(OfferTerms value, $Res Function(OfferTerms) _then) = _$OfferTermsCopyWithImpl;
@useResult
$Res call({
 String offeredPrice, int validityHours, String? weightGrams, String? makingCharges, String? ratePerGram, String? deliveryTimeframe, String? warrantyTerms, String? vendorNote, List<MediaRef> media
});




}
/// @nodoc
class _$OfferTermsCopyWithImpl<$Res>
    implements $OfferTermsCopyWith<$Res> {
  _$OfferTermsCopyWithImpl(this._self, this._then);

  final OfferTerms _self;
  final $Res Function(OfferTerms) _then;

/// Create a copy of OfferTerms
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? offeredPrice = null,Object? validityHours = null,Object? weightGrams = freezed,Object? makingCharges = freezed,Object? ratePerGram = freezed,Object? deliveryTimeframe = freezed,Object? warrantyTerms = freezed,Object? vendorNote = freezed,Object? media = null,}) {
  return _then(_self.copyWith(
offeredPrice: null == offeredPrice ? _self.offeredPrice : offeredPrice // ignore: cast_nullable_to_non_nullable
as String,validityHours: null == validityHours ? _self.validityHours : validityHours // ignore: cast_nullable_to_non_nullable
as int,weightGrams: freezed == weightGrams ? _self.weightGrams : weightGrams // ignore: cast_nullable_to_non_nullable
as String?,makingCharges: freezed == makingCharges ? _self.makingCharges : makingCharges // ignore: cast_nullable_to_non_nullable
as String?,ratePerGram: freezed == ratePerGram ? _self.ratePerGram : ratePerGram // ignore: cast_nullable_to_non_nullable
as String?,deliveryTimeframe: freezed == deliveryTimeframe ? _self.deliveryTimeframe : deliveryTimeframe // ignore: cast_nullable_to_non_nullable
as String?,warrantyTerms: freezed == warrantyTerms ? _self.warrantyTerms : warrantyTerms // ignore: cast_nullable_to_non_nullable
as String?,vendorNote: freezed == vendorNote ? _self.vendorNote : vendorNote // ignore: cast_nullable_to_non_nullable
as String?,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as List<MediaRef>,
  ));
}

}


/// Adds pattern-matching-related methods to [OfferTerms].
extension OfferTermsPatterns on OfferTerms {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferTerms value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferTerms() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferTerms value)  $default,){
final _that = this;
switch (_that) {
case _OfferTerms():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferTerms value)?  $default,){
final _that = this;
switch (_that) {
case _OfferTerms() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String offeredPrice,  int validityHours,  String? weightGrams,  String? makingCharges,  String? ratePerGram,  String? deliveryTimeframe,  String? warrantyTerms,  String? vendorNote,  List<MediaRef> media)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferTerms() when $default != null:
return $default(_that.offeredPrice,_that.validityHours,_that.weightGrams,_that.makingCharges,_that.ratePerGram,_that.deliveryTimeframe,_that.warrantyTerms,_that.vendorNote,_that.media);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String offeredPrice,  int validityHours,  String? weightGrams,  String? makingCharges,  String? ratePerGram,  String? deliveryTimeframe,  String? warrantyTerms,  String? vendorNote,  List<MediaRef> media)  $default,) {final _that = this;
switch (_that) {
case _OfferTerms():
return $default(_that.offeredPrice,_that.validityHours,_that.weightGrams,_that.makingCharges,_that.ratePerGram,_that.deliveryTimeframe,_that.warrantyTerms,_that.vendorNote,_that.media);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String offeredPrice,  int validityHours,  String? weightGrams,  String? makingCharges,  String? ratePerGram,  String? deliveryTimeframe,  String? warrantyTerms,  String? vendorNote,  List<MediaRef> media)?  $default,) {final _that = this;
switch (_that) {
case _OfferTerms() when $default != null:
return $default(_that.offeredPrice,_that.validityHours,_that.weightGrams,_that.makingCharges,_that.ratePerGram,_that.deliveryTimeframe,_that.warrantyTerms,_that.vendorNote,_that.media);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfferTerms implements OfferTerms {
  const _OfferTerms({required this.offeredPrice, this.validityHours = 24, this.weightGrams, this.makingCharges, this.ratePerGram, this.deliveryTimeframe, this.warrantyTerms, this.vendorNote, final  List<MediaRef> media = const <MediaRef>[]}): _media = media;
  factory _OfferTerms.fromJson(Map<String, dynamic> json) => _$OfferTermsFromJson(json);

@override final  String offeredPrice;
@override@JsonKey() final  int validityHours;
@override final  String? weightGrams;
@override final  String? makingCharges;
@override final  String? ratePerGram;
@override final  String? deliveryTimeframe;
@override final  String? warrantyTerms;
@override final  String? vendorNote;
 final  List<MediaRef> _media;
@override@JsonKey() List<MediaRef> get media {
  if (_media is EqualUnmodifiableListView) return _media;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_media);
}


/// Create a copy of OfferTerms
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferTermsCopyWith<_OfferTerms> get copyWith => __$OfferTermsCopyWithImpl<_OfferTerms>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferTermsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferTerms&&(identical(other.offeredPrice, offeredPrice) || other.offeredPrice == offeredPrice)&&(identical(other.validityHours, validityHours) || other.validityHours == validityHours)&&(identical(other.weightGrams, weightGrams) || other.weightGrams == weightGrams)&&(identical(other.makingCharges, makingCharges) || other.makingCharges == makingCharges)&&(identical(other.ratePerGram, ratePerGram) || other.ratePerGram == ratePerGram)&&(identical(other.deliveryTimeframe, deliveryTimeframe) || other.deliveryTimeframe == deliveryTimeframe)&&(identical(other.warrantyTerms, warrantyTerms) || other.warrantyTerms == warrantyTerms)&&(identical(other.vendorNote, vendorNote) || other.vendorNote == vendorNote)&&const DeepCollectionEquality().equals(other._media, _media));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,offeredPrice,validityHours,weightGrams,makingCharges,ratePerGram,deliveryTimeframe,warrantyTerms,vendorNote,const DeepCollectionEquality().hash(_media));

@override
String toString() {
  return 'OfferTerms(offeredPrice: $offeredPrice, validityHours: $validityHours, weightGrams: $weightGrams, makingCharges: $makingCharges, ratePerGram: $ratePerGram, deliveryTimeframe: $deliveryTimeframe, warrantyTerms: $warrantyTerms, vendorNote: $vendorNote, media: $media)';
}


}

/// @nodoc
abstract mixin class _$OfferTermsCopyWith<$Res> implements $OfferTermsCopyWith<$Res> {
  factory _$OfferTermsCopyWith(_OfferTerms value, $Res Function(_OfferTerms) _then) = __$OfferTermsCopyWithImpl;
@override @useResult
$Res call({
 String offeredPrice, int validityHours, String? weightGrams, String? makingCharges, String? ratePerGram, String? deliveryTimeframe, String? warrantyTerms, String? vendorNote, List<MediaRef> media
});




}
/// @nodoc
class __$OfferTermsCopyWithImpl<$Res>
    implements _$OfferTermsCopyWith<$Res> {
  __$OfferTermsCopyWithImpl(this._self, this._then);

  final _OfferTerms _self;
  final $Res Function(_OfferTerms) _then;

/// Create a copy of OfferTerms
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? offeredPrice = null,Object? validityHours = null,Object? weightGrams = freezed,Object? makingCharges = freezed,Object? ratePerGram = freezed,Object? deliveryTimeframe = freezed,Object? warrantyTerms = freezed,Object? vendorNote = freezed,Object? media = null,}) {
  return _then(_OfferTerms(
offeredPrice: null == offeredPrice ? _self.offeredPrice : offeredPrice // ignore: cast_nullable_to_non_nullable
as String,validityHours: null == validityHours ? _self.validityHours : validityHours // ignore: cast_nullable_to_non_nullable
as int,weightGrams: freezed == weightGrams ? _self.weightGrams : weightGrams // ignore: cast_nullable_to_non_nullable
as String?,makingCharges: freezed == makingCharges ? _self.makingCharges : makingCharges // ignore: cast_nullable_to_non_nullable
as String?,ratePerGram: freezed == ratePerGram ? _self.ratePerGram : ratePerGram // ignore: cast_nullable_to_non_nullable
as String?,deliveryTimeframe: freezed == deliveryTimeframe ? _self.deliveryTimeframe : deliveryTimeframe // ignore: cast_nullable_to_non_nullable
as String?,warrantyTerms: freezed == warrantyTerms ? _self.warrantyTerms : warrantyTerms // ignore: cast_nullable_to_non_nullable
as String?,vendorNote: freezed == vendorNote ? _self.vendorNote : vendorNote // ignore: cast_nullable_to_non_nullable
as String?,media: null == media ? _self._media : media // ignore: cast_nullable_to_non_nullable
as List<MediaRef>,
  ));
}


}


/// @nodoc
mixin _$OfferForCustomer {

 String get id; String get requestId;@_OfferStateConverter() OfferState get state;@JsonKey(fromJson: _offerTermsFromJson, toJson: _offerTermsToJson) OfferTerms get terms; MaskedParty get vendor; DateTime get submittedAt; DateTime get expiresAt; int get revisionCount; DateTime? get decidedAt; DateTime? get viewedByCustomerAt;/// Wire included `viewedByCustomerAt` (SAM-GAP-1). Absent → UI hides unread.
 bool get viewedByCustomerAtPresent;
/// Create a copy of OfferForCustomer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferForCustomerCopyWith<OfferForCustomer> get copyWith => _$OfferForCustomerCopyWithImpl<OfferForCustomer>(this as OfferForCustomer, _$identity);

  /// Serializes this OfferForCustomer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferForCustomer&&(identical(other.id, id) || other.id == id)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.state, state) || other.state == state)&&(identical(other.terms, terms) || other.terms == terms)&&(identical(other.vendor, vendor) || other.vendor == vendor)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.revisionCount, revisionCount) || other.revisionCount == revisionCount)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.viewedByCustomerAt, viewedByCustomerAt) || other.viewedByCustomerAt == viewedByCustomerAt)&&(identical(other.viewedByCustomerAtPresent, viewedByCustomerAtPresent) || other.viewedByCustomerAtPresent == viewedByCustomerAtPresent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,requestId,state,terms,vendor,submittedAt,expiresAt,revisionCount,decidedAt,viewedByCustomerAt,viewedByCustomerAtPresent);

@override
String toString() {
  return 'OfferForCustomer(id: $id, requestId: $requestId, state: $state, terms: $terms, vendor: $vendor, submittedAt: $submittedAt, expiresAt: $expiresAt, revisionCount: $revisionCount, decidedAt: $decidedAt, viewedByCustomerAt: $viewedByCustomerAt, viewedByCustomerAtPresent: $viewedByCustomerAtPresent)';
}


}

/// @nodoc
abstract mixin class $OfferForCustomerCopyWith<$Res>  {
  factory $OfferForCustomerCopyWith(OfferForCustomer value, $Res Function(OfferForCustomer) _then) = _$OfferForCustomerCopyWithImpl;
@useResult
$Res call({
 String id, String requestId,@_OfferStateConverter() OfferState state,@JsonKey(fromJson: _offerTermsFromJson, toJson: _offerTermsToJson) OfferTerms terms, MaskedParty vendor, DateTime submittedAt, DateTime expiresAt, int revisionCount, DateTime? decidedAt, DateTime? viewedByCustomerAt, bool viewedByCustomerAtPresent
});


$OfferTermsCopyWith<$Res> get terms;

}
/// @nodoc
class _$OfferForCustomerCopyWithImpl<$Res>
    implements $OfferForCustomerCopyWith<$Res> {
  _$OfferForCustomerCopyWithImpl(this._self, this._then);

  final OfferForCustomer _self;
  final $Res Function(OfferForCustomer) _then;

/// Create a copy of OfferForCustomer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? requestId = null,Object? state = null,Object? terms = null,Object? vendor = null,Object? submittedAt = null,Object? expiresAt = null,Object? revisionCount = null,Object? decidedAt = freezed,Object? viewedByCustomerAt = freezed,Object? viewedByCustomerAtPresent = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OfferState,terms: null == terms ? _self.terms : terms // ignore: cast_nullable_to_non_nullable
as OfferTerms,vendor: null == vendor ? _self.vendor : vendor // ignore: cast_nullable_to_non_nullable
as MaskedParty,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,revisionCount: null == revisionCount ? _self.revisionCount : revisionCount // ignore: cast_nullable_to_non_nullable
as int,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,viewedByCustomerAt: freezed == viewedByCustomerAt ? _self.viewedByCustomerAt : viewedByCustomerAt // ignore: cast_nullable_to_non_nullable
as DateTime?,viewedByCustomerAtPresent: null == viewedByCustomerAtPresent ? _self.viewedByCustomerAtPresent : viewedByCustomerAtPresent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of OfferForCustomer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferTermsCopyWith<$Res> get terms {
  
  return $OfferTermsCopyWith<$Res>(_self.terms, (value) {
    return _then(_self.copyWith(terms: value));
  });
}
}


/// Adds pattern-matching-related methods to [OfferForCustomer].
extension OfferForCustomerPatterns on OfferForCustomer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferForCustomer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferForCustomer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferForCustomer value)  $default,){
final _that = this;
switch (_that) {
case _OfferForCustomer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferForCustomer value)?  $default,){
final _that = this;
switch (_that) {
case _OfferForCustomer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String requestId, @_OfferStateConverter()  OfferState state, @JsonKey(fromJson: _offerTermsFromJson, toJson: _offerTermsToJson)  OfferTerms terms,  MaskedParty vendor,  DateTime submittedAt,  DateTime expiresAt,  int revisionCount,  DateTime? decidedAt,  DateTime? viewedByCustomerAt,  bool viewedByCustomerAtPresent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferForCustomer() when $default != null:
return $default(_that.id,_that.requestId,_that.state,_that.terms,_that.vendor,_that.submittedAt,_that.expiresAt,_that.revisionCount,_that.decidedAt,_that.viewedByCustomerAt,_that.viewedByCustomerAtPresent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String requestId, @_OfferStateConverter()  OfferState state, @JsonKey(fromJson: _offerTermsFromJson, toJson: _offerTermsToJson)  OfferTerms terms,  MaskedParty vendor,  DateTime submittedAt,  DateTime expiresAt,  int revisionCount,  DateTime? decidedAt,  DateTime? viewedByCustomerAt,  bool viewedByCustomerAtPresent)  $default,) {final _that = this;
switch (_that) {
case _OfferForCustomer():
return $default(_that.id,_that.requestId,_that.state,_that.terms,_that.vendor,_that.submittedAt,_that.expiresAt,_that.revisionCount,_that.decidedAt,_that.viewedByCustomerAt,_that.viewedByCustomerAtPresent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String requestId, @_OfferStateConverter()  OfferState state, @JsonKey(fromJson: _offerTermsFromJson, toJson: _offerTermsToJson)  OfferTerms terms,  MaskedParty vendor,  DateTime submittedAt,  DateTime expiresAt,  int revisionCount,  DateTime? decidedAt,  DateTime? viewedByCustomerAt,  bool viewedByCustomerAtPresent)?  $default,) {final _that = this;
switch (_that) {
case _OfferForCustomer() when $default != null:
return $default(_that.id,_that.requestId,_that.state,_that.terms,_that.vendor,_that.submittedAt,_that.expiresAt,_that.revisionCount,_that.decidedAt,_that.viewedByCustomerAt,_that.viewedByCustomerAtPresent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfferForCustomer implements OfferForCustomer {
  const _OfferForCustomer({required this.id, required this.requestId, @_OfferStateConverter() required this.state, @JsonKey(fromJson: _offerTermsFromJson, toJson: _offerTermsToJson) required this.terms, required this.vendor, required this.submittedAt, required this.expiresAt, required this.revisionCount, this.decidedAt, this.viewedByCustomerAt, this.viewedByCustomerAtPresent = false});
  factory _OfferForCustomer.fromJson(Map<String, dynamic> json) => _$OfferForCustomerFromJson(json);

@override final  String id;
@override final  String requestId;
@override@_OfferStateConverter() final  OfferState state;
@override@JsonKey(fromJson: _offerTermsFromJson, toJson: _offerTermsToJson) final  OfferTerms terms;
@override final  MaskedParty vendor;
@override final  DateTime submittedAt;
@override final  DateTime expiresAt;
@override final  int revisionCount;
@override final  DateTime? decidedAt;
@override final  DateTime? viewedByCustomerAt;
/// Wire included `viewedByCustomerAt` (SAM-GAP-1). Absent → UI hides unread.
@override@JsonKey() final  bool viewedByCustomerAtPresent;

/// Create a copy of OfferForCustomer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferForCustomerCopyWith<_OfferForCustomer> get copyWith => __$OfferForCustomerCopyWithImpl<_OfferForCustomer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferForCustomerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferForCustomer&&(identical(other.id, id) || other.id == id)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.state, state) || other.state == state)&&(identical(other.terms, terms) || other.terms == terms)&&(identical(other.vendor, vendor) || other.vendor == vendor)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.revisionCount, revisionCount) || other.revisionCount == revisionCount)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.viewedByCustomerAt, viewedByCustomerAt) || other.viewedByCustomerAt == viewedByCustomerAt)&&(identical(other.viewedByCustomerAtPresent, viewedByCustomerAtPresent) || other.viewedByCustomerAtPresent == viewedByCustomerAtPresent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,requestId,state,terms,vendor,submittedAt,expiresAt,revisionCount,decidedAt,viewedByCustomerAt,viewedByCustomerAtPresent);

@override
String toString() {
  return 'OfferForCustomer(id: $id, requestId: $requestId, state: $state, terms: $terms, vendor: $vendor, submittedAt: $submittedAt, expiresAt: $expiresAt, revisionCount: $revisionCount, decidedAt: $decidedAt, viewedByCustomerAt: $viewedByCustomerAt, viewedByCustomerAtPresent: $viewedByCustomerAtPresent)';
}


}

/// @nodoc
abstract mixin class _$OfferForCustomerCopyWith<$Res> implements $OfferForCustomerCopyWith<$Res> {
  factory _$OfferForCustomerCopyWith(_OfferForCustomer value, $Res Function(_OfferForCustomer) _then) = __$OfferForCustomerCopyWithImpl;
@override @useResult
$Res call({
 String id, String requestId,@_OfferStateConverter() OfferState state,@JsonKey(fromJson: _offerTermsFromJson, toJson: _offerTermsToJson) OfferTerms terms, MaskedParty vendor, DateTime submittedAt, DateTime expiresAt, int revisionCount, DateTime? decidedAt, DateTime? viewedByCustomerAt, bool viewedByCustomerAtPresent
});


@override $OfferTermsCopyWith<$Res> get terms;

}
/// @nodoc
class __$OfferForCustomerCopyWithImpl<$Res>
    implements _$OfferForCustomerCopyWith<$Res> {
  __$OfferForCustomerCopyWithImpl(this._self, this._then);

  final _OfferForCustomer _self;
  final $Res Function(_OfferForCustomer) _then;

/// Create a copy of OfferForCustomer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? requestId = null,Object? state = null,Object? terms = null,Object? vendor = null,Object? submittedAt = null,Object? expiresAt = null,Object? revisionCount = null,Object? decidedAt = freezed,Object? viewedByCustomerAt = freezed,Object? viewedByCustomerAtPresent = null,}) {
  return _then(_OfferForCustomer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OfferState,terms: null == terms ? _self.terms : terms // ignore: cast_nullable_to_non_nullable
as OfferTerms,vendor: null == vendor ? _self.vendor : vendor // ignore: cast_nullable_to_non_nullable
as MaskedParty,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,revisionCount: null == revisionCount ? _self.revisionCount : revisionCount // ignore: cast_nullable_to_non_nullable
as int,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,viewedByCustomerAt: freezed == viewedByCustomerAt ? _self.viewedByCustomerAt : viewedByCustomerAt // ignore: cast_nullable_to_non_nullable
as DateTime?,viewedByCustomerAtPresent: null == viewedByCustomerAtPresent ? _self.viewedByCustomerAtPresent : viewedByCustomerAtPresent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of OfferForCustomer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferTermsCopyWith<$Res> get terms {
  
  return $OfferTermsCopyWith<$Res>(_self.terms, (value) {
    return _then(_self.copyWith(terms: value));
  });
}
}


/// @nodoc
mixin _$ReviewExcerpt {

 String get abbreviatedName; int get rating; String? get comment;
/// Create a copy of ReviewExcerpt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewExcerptCopyWith<ReviewExcerpt> get copyWith => _$ReviewExcerptCopyWithImpl<ReviewExcerpt>(this as ReviewExcerpt, _$identity);

  /// Serializes this ReviewExcerpt to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewExcerpt&&(identical(other.abbreviatedName, abbreviatedName) || other.abbreviatedName == abbreviatedName)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,abbreviatedName,rating,comment);

@override
String toString() {
  return 'ReviewExcerpt(abbreviatedName: $abbreviatedName, rating: $rating, comment: $comment)';
}


}

/// @nodoc
abstract mixin class $ReviewExcerptCopyWith<$Res>  {
  factory $ReviewExcerptCopyWith(ReviewExcerpt value, $Res Function(ReviewExcerpt) _then) = _$ReviewExcerptCopyWithImpl;
@useResult
$Res call({
 String abbreviatedName, int rating, String? comment
});




}
/// @nodoc
class _$ReviewExcerptCopyWithImpl<$Res>
    implements $ReviewExcerptCopyWith<$Res> {
  _$ReviewExcerptCopyWithImpl(this._self, this._then);

  final ReviewExcerpt _self;
  final $Res Function(ReviewExcerpt) _then;

/// Create a copy of ReviewExcerpt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? abbreviatedName = null,Object? rating = null,Object? comment = freezed,}) {
  return _then(_self.copyWith(
abbreviatedName: null == abbreviatedName ? _self.abbreviatedName : abbreviatedName // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReviewExcerpt].
extension ReviewExcerptPatterns on ReviewExcerpt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewExcerpt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewExcerpt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewExcerpt value)  $default,){
final _that = this;
switch (_that) {
case _ReviewExcerpt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewExcerpt value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewExcerpt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String abbreviatedName,  int rating,  String? comment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewExcerpt() when $default != null:
return $default(_that.abbreviatedName,_that.rating,_that.comment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String abbreviatedName,  int rating,  String? comment)  $default,) {final _that = this;
switch (_that) {
case _ReviewExcerpt():
return $default(_that.abbreviatedName,_that.rating,_that.comment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String abbreviatedName,  int rating,  String? comment)?  $default,) {final _that = this;
switch (_that) {
case _ReviewExcerpt() when $default != null:
return $default(_that.abbreviatedName,_that.rating,_that.comment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReviewExcerpt implements ReviewExcerpt {
  const _ReviewExcerpt({required this.abbreviatedName, required this.rating, this.comment});
  factory _ReviewExcerpt.fromJson(Map<String, dynamic> json) => _$ReviewExcerptFromJson(json);

@override final  String abbreviatedName;
@override final  int rating;
@override final  String? comment;

/// Create a copy of ReviewExcerpt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewExcerptCopyWith<_ReviewExcerpt> get copyWith => __$ReviewExcerptCopyWithImpl<_ReviewExcerpt>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewExcerptToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewExcerpt&&(identical(other.abbreviatedName, abbreviatedName) || other.abbreviatedName == abbreviatedName)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,abbreviatedName,rating,comment);

@override
String toString() {
  return 'ReviewExcerpt(abbreviatedName: $abbreviatedName, rating: $rating, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$ReviewExcerptCopyWith<$Res> implements $ReviewExcerptCopyWith<$Res> {
  factory _$ReviewExcerptCopyWith(_ReviewExcerpt value, $Res Function(_ReviewExcerpt) _then) = __$ReviewExcerptCopyWithImpl;
@override @useResult
$Res call({
 String abbreviatedName, int rating, String? comment
});




}
/// @nodoc
class __$ReviewExcerptCopyWithImpl<$Res>
    implements _$ReviewExcerptCopyWith<$Res> {
  __$ReviewExcerptCopyWithImpl(this._self, this._then);

  final _ReviewExcerpt _self;
  final $Res Function(_ReviewExcerpt) _then;

/// Create a copy of ReviewExcerpt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? abbreviatedName = null,Object? rating = null,Object? comment = freezed,}) {
  return _then(_ReviewExcerpt(
abbreviatedName: null == abbreviatedName ? _self.abbreviatedName : abbreviatedName // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$VendorRatingDetail {

@JsonKey(fromJson: _ratingSummaryFromJson, toJson: _ratingSummaryToJson) RatingSummary get summary; List<ReviewExcerpt> get excerpts;
/// Create a copy of VendorRatingDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorRatingDetailCopyWith<VendorRatingDetail> get copyWith => _$VendorRatingDetailCopyWithImpl<VendorRatingDetail>(this as VendorRatingDetail, _$identity);

  /// Serializes this VendorRatingDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorRatingDetail&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.excerpts, excerpts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,summary,const DeepCollectionEquality().hash(excerpts));

@override
String toString() {
  return 'VendorRatingDetail(summary: $summary, excerpts: $excerpts)';
}


}

/// @nodoc
abstract mixin class $VendorRatingDetailCopyWith<$Res>  {
  factory $VendorRatingDetailCopyWith(VendorRatingDetail value, $Res Function(VendorRatingDetail) _then) = _$VendorRatingDetailCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _ratingSummaryFromJson, toJson: _ratingSummaryToJson) RatingSummary summary, List<ReviewExcerpt> excerpts
});




}
/// @nodoc
class _$VendorRatingDetailCopyWithImpl<$Res>
    implements $VendorRatingDetailCopyWith<$Res> {
  _$VendorRatingDetailCopyWithImpl(this._self, this._then);

  final VendorRatingDetail _self;
  final $Res Function(VendorRatingDetail) _then;

/// Create a copy of VendorRatingDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? summary = null,Object? excerpts = null,}) {
  return _then(_self.copyWith(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as RatingSummary,excerpts: null == excerpts ? _self.excerpts : excerpts // ignore: cast_nullable_to_non_nullable
as List<ReviewExcerpt>,
  ));
}

}


/// Adds pattern-matching-related methods to [VendorRatingDetail].
extension VendorRatingDetailPatterns on VendorRatingDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorRatingDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorRatingDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorRatingDetail value)  $default,){
final _that = this;
switch (_that) {
case _VendorRatingDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorRatingDetail value)?  $default,){
final _that = this;
switch (_that) {
case _VendorRatingDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _ratingSummaryFromJson, toJson: _ratingSummaryToJson)  RatingSummary summary,  List<ReviewExcerpt> excerpts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorRatingDetail() when $default != null:
return $default(_that.summary,_that.excerpts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _ratingSummaryFromJson, toJson: _ratingSummaryToJson)  RatingSummary summary,  List<ReviewExcerpt> excerpts)  $default,) {final _that = this;
switch (_that) {
case _VendorRatingDetail():
return $default(_that.summary,_that.excerpts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _ratingSummaryFromJson, toJson: _ratingSummaryToJson)  RatingSummary summary,  List<ReviewExcerpt> excerpts)?  $default,) {final _that = this;
switch (_that) {
case _VendorRatingDetail() when $default != null:
return $default(_that.summary,_that.excerpts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VendorRatingDetail extends VendorRatingDetail {
  const _VendorRatingDetail({@JsonKey(fromJson: _ratingSummaryFromJson, toJson: _ratingSummaryToJson) required this.summary, final  List<ReviewExcerpt> excerpts = const <ReviewExcerpt>[]}): _excerpts = excerpts,super._();
  factory _VendorRatingDetail.fromJson(Map<String, dynamic> json) => _$VendorRatingDetailFromJson(json);

@override@JsonKey(fromJson: _ratingSummaryFromJson, toJson: _ratingSummaryToJson) final  RatingSummary summary;
 final  List<ReviewExcerpt> _excerpts;
@override@JsonKey() List<ReviewExcerpt> get excerpts {
  if (_excerpts is EqualUnmodifiableListView) return _excerpts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_excerpts);
}


/// Create a copy of VendorRatingDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorRatingDetailCopyWith<_VendorRatingDetail> get copyWith => __$VendorRatingDetailCopyWithImpl<_VendorRatingDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VendorRatingDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorRatingDetail&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._excerpts, _excerpts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,summary,const DeepCollectionEquality().hash(_excerpts));

@override
String toString() {
  return 'VendorRatingDetail(summary: $summary, excerpts: $excerpts)';
}


}

/// @nodoc
abstract mixin class _$VendorRatingDetailCopyWith<$Res> implements $VendorRatingDetailCopyWith<$Res> {
  factory _$VendorRatingDetailCopyWith(_VendorRatingDetail value, $Res Function(_VendorRatingDetail) _then) = __$VendorRatingDetailCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _ratingSummaryFromJson, toJson: _ratingSummaryToJson) RatingSummary summary, List<ReviewExcerpt> excerpts
});




}
/// @nodoc
class __$VendorRatingDetailCopyWithImpl<$Res>
    implements _$VendorRatingDetailCopyWith<$Res> {
  __$VendorRatingDetailCopyWithImpl(this._self, this._then);

  final _VendorRatingDetail _self;
  final $Res Function(_VendorRatingDetail) _then;

/// Create a copy of VendorRatingDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? summary = null,Object? excerpts = null,}) {
  return _then(_VendorRatingDetail(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as RatingSummary,excerpts: null == excerpts ? _self._excerpts : excerpts // ignore: cast_nullable_to_non_nullable
as List<ReviewExcerpt>,
  ));
}


}


/// @nodoc
mixin _$OfferRequestSummary {

 String get id;@_RequestTypeConverter() RequestType get requestType;@_DirectionConverter() Direction get direction; String get customerLabel; String? get reference; String? get categoryId; String? get categoryName; String? get regionId; String? get regionName; String? get purityKarat; String? get weightGrams; String? get budgetMax; DateTime? get expiresAt;
/// Create a copy of OfferRequestSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferRequestSummaryCopyWith<OfferRequestSummary> get copyWith => _$OfferRequestSummaryCopyWithImpl<OfferRequestSummary>(this as OfferRequestSummary, _$identity);

  /// Serializes this OfferRequestSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferRequestSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.customerLabel, customerLabel) || other.customerLabel == customerLabel)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.regionName, regionName) || other.regionName == regionName)&&(identical(other.purityKarat, purityKarat) || other.purityKarat == purityKarat)&&(identical(other.weightGrams, weightGrams) || other.weightGrams == weightGrams)&&(identical(other.budgetMax, budgetMax) || other.budgetMax == budgetMax)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,requestType,direction,customerLabel,reference,categoryId,categoryName,regionId,regionName,purityKarat,weightGrams,budgetMax,expiresAt);

@override
String toString() {
  return 'OfferRequestSummary(id: $id, requestType: $requestType, direction: $direction, customerLabel: $customerLabel, reference: $reference, categoryId: $categoryId, categoryName: $categoryName, regionId: $regionId, regionName: $regionName, purityKarat: $purityKarat, weightGrams: $weightGrams, budgetMax: $budgetMax, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $OfferRequestSummaryCopyWith<$Res>  {
  factory $OfferRequestSummaryCopyWith(OfferRequestSummary value, $Res Function(OfferRequestSummary) _then) = _$OfferRequestSummaryCopyWithImpl;
@useResult
$Res call({
 String id,@_RequestTypeConverter() RequestType requestType,@_DirectionConverter() Direction direction, String customerLabel, String? reference, String? categoryId, String? categoryName, String? regionId, String? regionName, String? purityKarat, String? weightGrams, String? budgetMax, DateTime? expiresAt
});




}
/// @nodoc
class _$OfferRequestSummaryCopyWithImpl<$Res>
    implements $OfferRequestSummaryCopyWith<$Res> {
  _$OfferRequestSummaryCopyWithImpl(this._self, this._then);

  final OfferRequestSummary _self;
  final $Res Function(OfferRequestSummary) _then;

/// Create a copy of OfferRequestSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? requestType = null,Object? direction = null,Object? customerLabel = null,Object? reference = freezed,Object? categoryId = freezed,Object? categoryName = freezed,Object? regionId = freezed,Object? regionName = freezed,Object? purityKarat = freezed,Object? weightGrams = freezed,Object? budgetMax = freezed,Object? expiresAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,requestType: null == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as RequestType,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as Direction,customerLabel: null == customerLabel ? _self.customerLabel : customerLabel // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as String?,regionName: freezed == regionName ? _self.regionName : regionName // ignore: cast_nullable_to_non_nullable
as String?,purityKarat: freezed == purityKarat ? _self.purityKarat : purityKarat // ignore: cast_nullable_to_non_nullable
as String?,weightGrams: freezed == weightGrams ? _self.weightGrams : weightGrams // ignore: cast_nullable_to_non_nullable
as String?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [OfferRequestSummary].
extension OfferRequestSummaryPatterns on OfferRequestSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferRequestSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferRequestSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferRequestSummary value)  $default,){
final _that = this;
switch (_that) {
case _OfferRequestSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferRequestSummary value)?  $default,){
final _that = this;
switch (_that) {
case _OfferRequestSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @_RequestTypeConverter()  RequestType requestType, @_DirectionConverter()  Direction direction,  String customerLabel,  String? reference,  String? categoryId,  String? categoryName,  String? regionId,  String? regionName,  String? purityKarat,  String? weightGrams,  String? budgetMax,  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferRequestSummary() when $default != null:
return $default(_that.id,_that.requestType,_that.direction,_that.customerLabel,_that.reference,_that.categoryId,_that.categoryName,_that.regionId,_that.regionName,_that.purityKarat,_that.weightGrams,_that.budgetMax,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @_RequestTypeConverter()  RequestType requestType, @_DirectionConverter()  Direction direction,  String customerLabel,  String? reference,  String? categoryId,  String? categoryName,  String? regionId,  String? regionName,  String? purityKarat,  String? weightGrams,  String? budgetMax,  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _OfferRequestSummary():
return $default(_that.id,_that.requestType,_that.direction,_that.customerLabel,_that.reference,_that.categoryId,_that.categoryName,_that.regionId,_that.regionName,_that.purityKarat,_that.weightGrams,_that.budgetMax,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @_RequestTypeConverter()  RequestType requestType, @_DirectionConverter()  Direction direction,  String customerLabel,  String? reference,  String? categoryId,  String? categoryName,  String? regionId,  String? regionName,  String? purityKarat,  String? weightGrams,  String? budgetMax,  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _OfferRequestSummary() when $default != null:
return $default(_that.id,_that.requestType,_that.direction,_that.customerLabel,_that.reference,_that.categoryId,_that.categoryName,_that.regionId,_that.regionName,_that.purityKarat,_that.weightGrams,_that.budgetMax,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfferRequestSummary implements OfferRequestSummary {
  const _OfferRequestSummary({required this.id, @_RequestTypeConverter() required this.requestType, @_DirectionConverter() required this.direction, required this.customerLabel, this.reference, this.categoryId, this.categoryName, this.regionId, this.regionName, this.purityKarat, this.weightGrams, this.budgetMax, this.expiresAt});
  factory _OfferRequestSummary.fromJson(Map<String, dynamic> json) => _$OfferRequestSummaryFromJson(json);

@override final  String id;
@override@_RequestTypeConverter() final  RequestType requestType;
@override@_DirectionConverter() final  Direction direction;
@override final  String customerLabel;
@override final  String? reference;
@override final  String? categoryId;
@override final  String? categoryName;
@override final  String? regionId;
@override final  String? regionName;
@override final  String? purityKarat;
@override final  String? weightGrams;
@override final  String? budgetMax;
@override final  DateTime? expiresAt;

/// Create a copy of OfferRequestSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferRequestSummaryCopyWith<_OfferRequestSummary> get copyWith => __$OfferRequestSummaryCopyWithImpl<_OfferRequestSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferRequestSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferRequestSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.customerLabel, customerLabel) || other.customerLabel == customerLabel)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.regionName, regionName) || other.regionName == regionName)&&(identical(other.purityKarat, purityKarat) || other.purityKarat == purityKarat)&&(identical(other.weightGrams, weightGrams) || other.weightGrams == weightGrams)&&(identical(other.budgetMax, budgetMax) || other.budgetMax == budgetMax)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,requestType,direction,customerLabel,reference,categoryId,categoryName,regionId,regionName,purityKarat,weightGrams,budgetMax,expiresAt);

@override
String toString() {
  return 'OfferRequestSummary(id: $id, requestType: $requestType, direction: $direction, customerLabel: $customerLabel, reference: $reference, categoryId: $categoryId, categoryName: $categoryName, regionId: $regionId, regionName: $regionName, purityKarat: $purityKarat, weightGrams: $weightGrams, budgetMax: $budgetMax, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$OfferRequestSummaryCopyWith<$Res> implements $OfferRequestSummaryCopyWith<$Res> {
  factory _$OfferRequestSummaryCopyWith(_OfferRequestSummary value, $Res Function(_OfferRequestSummary) _then) = __$OfferRequestSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id,@_RequestTypeConverter() RequestType requestType,@_DirectionConverter() Direction direction, String customerLabel, String? reference, String? categoryId, String? categoryName, String? regionId, String? regionName, String? purityKarat, String? weightGrams, String? budgetMax, DateTime? expiresAt
});




}
/// @nodoc
class __$OfferRequestSummaryCopyWithImpl<$Res>
    implements _$OfferRequestSummaryCopyWith<$Res> {
  __$OfferRequestSummaryCopyWithImpl(this._self, this._then);

  final _OfferRequestSummary _self;
  final $Res Function(_OfferRequestSummary) _then;

/// Create a copy of OfferRequestSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? requestType = null,Object? direction = null,Object? customerLabel = null,Object? reference = freezed,Object? categoryId = freezed,Object? categoryName = freezed,Object? regionId = freezed,Object? regionName = freezed,Object? purityKarat = freezed,Object? weightGrams = freezed,Object? budgetMax = freezed,Object? expiresAt = freezed,}) {
  return _then(_OfferRequestSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,requestType: null == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as RequestType,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as Direction,customerLabel: null == customerLabel ? _self.customerLabel : customerLabel // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as String?,regionName: freezed == regionName ? _self.regionName : regionName // ignore: cast_nullable_to_non_nullable
as String?,purityKarat: freezed == purityKarat ? _self.purityKarat : purityKarat // ignore: cast_nullable_to_non_nullable
as String?,weightGrams: freezed == weightGrams ? _self.weightGrams : weightGrams // ignore: cast_nullable_to_non_nullable
as String?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$OfferForVendor {

 String get id; String get requestId;@_OfferStateConverter() OfferState get state;@JsonKey(fromJson: _offerTermsFromJson, toJson: _offerTermsToJson) OfferTerms get terms; DateTime get submittedAt; DateTime get expiresAt; int get revisionCount; DateTime? get decidedAt; DateTime? get viewedByCustomerAt; OfferRequestSummary? get requestSummary;@_NullableOfferDeclineReasonConverter() OfferDeclineReason? get declineReason; bool get awardedElsewhere;/// Present when this Offer produced a Connection. Absent → UI keeps the
/// disabled copy rather than inventing a path (CP4-B05).
 String? get connectionId;
/// Create a copy of OfferForVendor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferForVendorCopyWith<OfferForVendor> get copyWith => _$OfferForVendorCopyWithImpl<OfferForVendor>(this as OfferForVendor, _$identity);

  /// Serializes this OfferForVendor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferForVendor&&(identical(other.id, id) || other.id == id)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.state, state) || other.state == state)&&(identical(other.terms, terms) || other.terms == terms)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.revisionCount, revisionCount) || other.revisionCount == revisionCount)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.viewedByCustomerAt, viewedByCustomerAt) || other.viewedByCustomerAt == viewedByCustomerAt)&&(identical(other.requestSummary, requestSummary) || other.requestSummary == requestSummary)&&(identical(other.declineReason, declineReason) || other.declineReason == declineReason)&&(identical(other.awardedElsewhere, awardedElsewhere) || other.awardedElsewhere == awardedElsewhere)&&(identical(other.connectionId, connectionId) || other.connectionId == connectionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,requestId,state,terms,submittedAt,expiresAt,revisionCount,decidedAt,viewedByCustomerAt,requestSummary,declineReason,awardedElsewhere,connectionId);

@override
String toString() {
  return 'OfferForVendor(id: $id, requestId: $requestId, state: $state, terms: $terms, submittedAt: $submittedAt, expiresAt: $expiresAt, revisionCount: $revisionCount, decidedAt: $decidedAt, viewedByCustomerAt: $viewedByCustomerAt, requestSummary: $requestSummary, declineReason: $declineReason, awardedElsewhere: $awardedElsewhere, connectionId: $connectionId)';
}


}

/// @nodoc
abstract mixin class $OfferForVendorCopyWith<$Res>  {
  factory $OfferForVendorCopyWith(OfferForVendor value, $Res Function(OfferForVendor) _then) = _$OfferForVendorCopyWithImpl;
@useResult
$Res call({
 String id, String requestId,@_OfferStateConverter() OfferState state,@JsonKey(fromJson: _offerTermsFromJson, toJson: _offerTermsToJson) OfferTerms terms, DateTime submittedAt, DateTime expiresAt, int revisionCount, DateTime? decidedAt, DateTime? viewedByCustomerAt, OfferRequestSummary? requestSummary,@_NullableOfferDeclineReasonConverter() OfferDeclineReason? declineReason, bool awardedElsewhere, String? connectionId
});


$OfferTermsCopyWith<$Res> get terms;$OfferRequestSummaryCopyWith<$Res>? get requestSummary;

}
/// @nodoc
class _$OfferForVendorCopyWithImpl<$Res>
    implements $OfferForVendorCopyWith<$Res> {
  _$OfferForVendorCopyWithImpl(this._self, this._then);

  final OfferForVendor _self;
  final $Res Function(OfferForVendor) _then;

/// Create a copy of OfferForVendor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? requestId = null,Object? state = null,Object? terms = null,Object? submittedAt = null,Object? expiresAt = null,Object? revisionCount = null,Object? decidedAt = freezed,Object? viewedByCustomerAt = freezed,Object? requestSummary = freezed,Object? declineReason = freezed,Object? awardedElsewhere = null,Object? connectionId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OfferState,terms: null == terms ? _self.terms : terms // ignore: cast_nullable_to_non_nullable
as OfferTerms,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,revisionCount: null == revisionCount ? _self.revisionCount : revisionCount // ignore: cast_nullable_to_non_nullable
as int,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,viewedByCustomerAt: freezed == viewedByCustomerAt ? _self.viewedByCustomerAt : viewedByCustomerAt // ignore: cast_nullable_to_non_nullable
as DateTime?,requestSummary: freezed == requestSummary ? _self.requestSummary : requestSummary // ignore: cast_nullable_to_non_nullable
as OfferRequestSummary?,declineReason: freezed == declineReason ? _self.declineReason : declineReason // ignore: cast_nullable_to_non_nullable
as OfferDeclineReason?,awardedElsewhere: null == awardedElsewhere ? _self.awardedElsewhere : awardedElsewhere // ignore: cast_nullable_to_non_nullable
as bool,connectionId: freezed == connectionId ? _self.connectionId : connectionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of OfferForVendor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferTermsCopyWith<$Res> get terms {
  
  return $OfferTermsCopyWith<$Res>(_self.terms, (value) {
    return _then(_self.copyWith(terms: value));
  });
}/// Create a copy of OfferForVendor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferRequestSummaryCopyWith<$Res>? get requestSummary {
    if (_self.requestSummary == null) {
    return null;
  }

  return $OfferRequestSummaryCopyWith<$Res>(_self.requestSummary!, (value) {
    return _then(_self.copyWith(requestSummary: value));
  });
}
}


/// Adds pattern-matching-related methods to [OfferForVendor].
extension OfferForVendorPatterns on OfferForVendor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferForVendor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferForVendor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferForVendor value)  $default,){
final _that = this;
switch (_that) {
case _OfferForVendor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferForVendor value)?  $default,){
final _that = this;
switch (_that) {
case _OfferForVendor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String requestId, @_OfferStateConverter()  OfferState state, @JsonKey(fromJson: _offerTermsFromJson, toJson: _offerTermsToJson)  OfferTerms terms,  DateTime submittedAt,  DateTime expiresAt,  int revisionCount,  DateTime? decidedAt,  DateTime? viewedByCustomerAt,  OfferRequestSummary? requestSummary, @_NullableOfferDeclineReasonConverter()  OfferDeclineReason? declineReason,  bool awardedElsewhere,  String? connectionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferForVendor() when $default != null:
return $default(_that.id,_that.requestId,_that.state,_that.terms,_that.submittedAt,_that.expiresAt,_that.revisionCount,_that.decidedAt,_that.viewedByCustomerAt,_that.requestSummary,_that.declineReason,_that.awardedElsewhere,_that.connectionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String requestId, @_OfferStateConverter()  OfferState state, @JsonKey(fromJson: _offerTermsFromJson, toJson: _offerTermsToJson)  OfferTerms terms,  DateTime submittedAt,  DateTime expiresAt,  int revisionCount,  DateTime? decidedAt,  DateTime? viewedByCustomerAt,  OfferRequestSummary? requestSummary, @_NullableOfferDeclineReasonConverter()  OfferDeclineReason? declineReason,  bool awardedElsewhere,  String? connectionId)  $default,) {final _that = this;
switch (_that) {
case _OfferForVendor():
return $default(_that.id,_that.requestId,_that.state,_that.terms,_that.submittedAt,_that.expiresAt,_that.revisionCount,_that.decidedAt,_that.viewedByCustomerAt,_that.requestSummary,_that.declineReason,_that.awardedElsewhere,_that.connectionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String requestId, @_OfferStateConverter()  OfferState state, @JsonKey(fromJson: _offerTermsFromJson, toJson: _offerTermsToJson)  OfferTerms terms,  DateTime submittedAt,  DateTime expiresAt,  int revisionCount,  DateTime? decidedAt,  DateTime? viewedByCustomerAt,  OfferRequestSummary? requestSummary, @_NullableOfferDeclineReasonConverter()  OfferDeclineReason? declineReason,  bool awardedElsewhere,  String? connectionId)?  $default,) {final _that = this;
switch (_that) {
case _OfferForVendor() when $default != null:
return $default(_that.id,_that.requestId,_that.state,_that.terms,_that.submittedAt,_that.expiresAt,_that.revisionCount,_that.decidedAt,_that.viewedByCustomerAt,_that.requestSummary,_that.declineReason,_that.awardedElsewhere,_that.connectionId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfferForVendor extends OfferForVendor {
  const _OfferForVendor({required this.id, required this.requestId, @_OfferStateConverter() required this.state, @JsonKey(fromJson: _offerTermsFromJson, toJson: _offerTermsToJson) required this.terms, required this.submittedAt, required this.expiresAt, required this.revisionCount, this.decidedAt, this.viewedByCustomerAt, this.requestSummary, @_NullableOfferDeclineReasonConverter() this.declineReason, this.awardedElsewhere = false, this.connectionId}): super._();
  factory _OfferForVendor.fromJson(Map<String, dynamic> json) => _$OfferForVendorFromJson(json);

@override final  String id;
@override final  String requestId;
@override@_OfferStateConverter() final  OfferState state;
@override@JsonKey(fromJson: _offerTermsFromJson, toJson: _offerTermsToJson) final  OfferTerms terms;
@override final  DateTime submittedAt;
@override final  DateTime expiresAt;
@override final  int revisionCount;
@override final  DateTime? decidedAt;
@override final  DateTime? viewedByCustomerAt;
@override final  OfferRequestSummary? requestSummary;
@override@_NullableOfferDeclineReasonConverter() final  OfferDeclineReason? declineReason;
@override@JsonKey() final  bool awardedElsewhere;
/// Present when this Offer produced a Connection. Absent → UI keeps the
/// disabled copy rather than inventing a path (CP4-B05).
@override final  String? connectionId;

/// Create a copy of OfferForVendor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferForVendorCopyWith<_OfferForVendor> get copyWith => __$OfferForVendorCopyWithImpl<_OfferForVendor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferForVendorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferForVendor&&(identical(other.id, id) || other.id == id)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.state, state) || other.state == state)&&(identical(other.terms, terms) || other.terms == terms)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.revisionCount, revisionCount) || other.revisionCount == revisionCount)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.viewedByCustomerAt, viewedByCustomerAt) || other.viewedByCustomerAt == viewedByCustomerAt)&&(identical(other.requestSummary, requestSummary) || other.requestSummary == requestSummary)&&(identical(other.declineReason, declineReason) || other.declineReason == declineReason)&&(identical(other.awardedElsewhere, awardedElsewhere) || other.awardedElsewhere == awardedElsewhere)&&(identical(other.connectionId, connectionId) || other.connectionId == connectionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,requestId,state,terms,submittedAt,expiresAt,revisionCount,decidedAt,viewedByCustomerAt,requestSummary,declineReason,awardedElsewhere,connectionId);

@override
String toString() {
  return 'OfferForVendor(id: $id, requestId: $requestId, state: $state, terms: $terms, submittedAt: $submittedAt, expiresAt: $expiresAt, revisionCount: $revisionCount, decidedAt: $decidedAt, viewedByCustomerAt: $viewedByCustomerAt, requestSummary: $requestSummary, declineReason: $declineReason, awardedElsewhere: $awardedElsewhere, connectionId: $connectionId)';
}


}

/// @nodoc
abstract mixin class _$OfferForVendorCopyWith<$Res> implements $OfferForVendorCopyWith<$Res> {
  factory _$OfferForVendorCopyWith(_OfferForVendor value, $Res Function(_OfferForVendor) _then) = __$OfferForVendorCopyWithImpl;
@override @useResult
$Res call({
 String id, String requestId,@_OfferStateConverter() OfferState state,@JsonKey(fromJson: _offerTermsFromJson, toJson: _offerTermsToJson) OfferTerms terms, DateTime submittedAt, DateTime expiresAt, int revisionCount, DateTime? decidedAt, DateTime? viewedByCustomerAt, OfferRequestSummary? requestSummary,@_NullableOfferDeclineReasonConverter() OfferDeclineReason? declineReason, bool awardedElsewhere, String? connectionId
});


@override $OfferTermsCopyWith<$Res> get terms;@override $OfferRequestSummaryCopyWith<$Res>? get requestSummary;

}
/// @nodoc
class __$OfferForVendorCopyWithImpl<$Res>
    implements _$OfferForVendorCopyWith<$Res> {
  __$OfferForVendorCopyWithImpl(this._self, this._then);

  final _OfferForVendor _self;
  final $Res Function(_OfferForVendor) _then;

/// Create a copy of OfferForVendor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? requestId = null,Object? state = null,Object? terms = null,Object? submittedAt = null,Object? expiresAt = null,Object? revisionCount = null,Object? decidedAt = freezed,Object? viewedByCustomerAt = freezed,Object? requestSummary = freezed,Object? declineReason = freezed,Object? awardedElsewhere = null,Object? connectionId = freezed,}) {
  return _then(_OfferForVendor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OfferState,terms: null == terms ? _self.terms : terms // ignore: cast_nullable_to_non_nullable
as OfferTerms,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,revisionCount: null == revisionCount ? _self.revisionCount : revisionCount // ignore: cast_nullable_to_non_nullable
as int,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,viewedByCustomerAt: freezed == viewedByCustomerAt ? _self.viewedByCustomerAt : viewedByCustomerAt // ignore: cast_nullable_to_non_nullable
as DateTime?,requestSummary: freezed == requestSummary ? _self.requestSummary : requestSummary // ignore: cast_nullable_to_non_nullable
as OfferRequestSummary?,declineReason: freezed == declineReason ? _self.declineReason : declineReason // ignore: cast_nullable_to_non_nullable
as OfferDeclineReason?,awardedElsewhere: null == awardedElsewhere ? _self.awardedElsewhere : awardedElsewhere // ignore: cast_nullable_to_non_nullable
as bool,connectionId: freezed == connectionId ? _self.connectionId : connectionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of OfferForVendor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferTermsCopyWith<$Res> get terms {
  
  return $OfferTermsCopyWith<$Res>(_self.terms, (value) {
    return _then(_self.copyWith(terms: value));
  });
}/// Create a copy of OfferForVendor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferRequestSummaryCopyWith<$Res>? get requestSummary {
    if (_self.requestSummary == null) {
    return null;
  }

  return $OfferRequestSummaryCopyWith<$Res>(_self.requestSummary!, (value) {
    return _then(_self.copyWith(requestSummary: value));
  });
}
}

/// @nodoc
mixin _$OfferTermsInput {

 String get offeredPrice; int get validityHours; String? get weightGrams; String? get makingCharges; String? get ratePerGram; String? get deliveryTimeframe; String? get warrantyTerms; String? get vendorNote; List<String> get mediaKeys;
/// Create a copy of OfferTermsInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferTermsInputCopyWith<OfferTermsInput> get copyWith => _$OfferTermsInputCopyWithImpl<OfferTermsInput>(this as OfferTermsInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferTermsInput&&(identical(other.offeredPrice, offeredPrice) || other.offeredPrice == offeredPrice)&&(identical(other.validityHours, validityHours) || other.validityHours == validityHours)&&(identical(other.weightGrams, weightGrams) || other.weightGrams == weightGrams)&&(identical(other.makingCharges, makingCharges) || other.makingCharges == makingCharges)&&(identical(other.ratePerGram, ratePerGram) || other.ratePerGram == ratePerGram)&&(identical(other.deliveryTimeframe, deliveryTimeframe) || other.deliveryTimeframe == deliveryTimeframe)&&(identical(other.warrantyTerms, warrantyTerms) || other.warrantyTerms == warrantyTerms)&&(identical(other.vendorNote, vendorNote) || other.vendorNote == vendorNote)&&const DeepCollectionEquality().equals(other.mediaKeys, mediaKeys));
}


@override
int get hashCode => Object.hash(runtimeType,offeredPrice,validityHours,weightGrams,makingCharges,ratePerGram,deliveryTimeframe,warrantyTerms,vendorNote,const DeepCollectionEquality().hash(mediaKeys));

@override
String toString() {
  return 'OfferTermsInput(offeredPrice: $offeredPrice, validityHours: $validityHours, weightGrams: $weightGrams, makingCharges: $makingCharges, ratePerGram: $ratePerGram, deliveryTimeframe: $deliveryTimeframe, warrantyTerms: $warrantyTerms, vendorNote: $vendorNote, mediaKeys: $mediaKeys)';
}


}

/// @nodoc
abstract mixin class $OfferTermsInputCopyWith<$Res>  {
  factory $OfferTermsInputCopyWith(OfferTermsInput value, $Res Function(OfferTermsInput) _then) = _$OfferTermsInputCopyWithImpl;
@useResult
$Res call({
 String offeredPrice, int validityHours, String? weightGrams, String? makingCharges, String? ratePerGram, String? deliveryTimeframe, String? warrantyTerms, String? vendorNote, List<String> mediaKeys
});




}
/// @nodoc
class _$OfferTermsInputCopyWithImpl<$Res>
    implements $OfferTermsInputCopyWith<$Res> {
  _$OfferTermsInputCopyWithImpl(this._self, this._then);

  final OfferTermsInput _self;
  final $Res Function(OfferTermsInput) _then;

/// Create a copy of OfferTermsInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? offeredPrice = null,Object? validityHours = null,Object? weightGrams = freezed,Object? makingCharges = freezed,Object? ratePerGram = freezed,Object? deliveryTimeframe = freezed,Object? warrantyTerms = freezed,Object? vendorNote = freezed,Object? mediaKeys = null,}) {
  return _then(_self.copyWith(
offeredPrice: null == offeredPrice ? _self.offeredPrice : offeredPrice // ignore: cast_nullable_to_non_nullable
as String,validityHours: null == validityHours ? _self.validityHours : validityHours // ignore: cast_nullable_to_non_nullable
as int,weightGrams: freezed == weightGrams ? _self.weightGrams : weightGrams // ignore: cast_nullable_to_non_nullable
as String?,makingCharges: freezed == makingCharges ? _self.makingCharges : makingCharges // ignore: cast_nullable_to_non_nullable
as String?,ratePerGram: freezed == ratePerGram ? _self.ratePerGram : ratePerGram // ignore: cast_nullable_to_non_nullable
as String?,deliveryTimeframe: freezed == deliveryTimeframe ? _self.deliveryTimeframe : deliveryTimeframe // ignore: cast_nullable_to_non_nullable
as String?,warrantyTerms: freezed == warrantyTerms ? _self.warrantyTerms : warrantyTerms // ignore: cast_nullable_to_non_nullable
as String?,vendorNote: freezed == vendorNote ? _self.vendorNote : vendorNote // ignore: cast_nullable_to_non_nullable
as String?,mediaKeys: null == mediaKeys ? _self.mediaKeys : mediaKeys // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [OfferTermsInput].
extension OfferTermsInputPatterns on OfferTermsInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferTermsInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferTermsInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferTermsInput value)  $default,){
final _that = this;
switch (_that) {
case _OfferTermsInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferTermsInput value)?  $default,){
final _that = this;
switch (_that) {
case _OfferTermsInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String offeredPrice,  int validityHours,  String? weightGrams,  String? makingCharges,  String? ratePerGram,  String? deliveryTimeframe,  String? warrantyTerms,  String? vendorNote,  List<String> mediaKeys)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferTermsInput() when $default != null:
return $default(_that.offeredPrice,_that.validityHours,_that.weightGrams,_that.makingCharges,_that.ratePerGram,_that.deliveryTimeframe,_that.warrantyTerms,_that.vendorNote,_that.mediaKeys);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String offeredPrice,  int validityHours,  String? weightGrams,  String? makingCharges,  String? ratePerGram,  String? deliveryTimeframe,  String? warrantyTerms,  String? vendorNote,  List<String> mediaKeys)  $default,) {final _that = this;
switch (_that) {
case _OfferTermsInput():
return $default(_that.offeredPrice,_that.validityHours,_that.weightGrams,_that.makingCharges,_that.ratePerGram,_that.deliveryTimeframe,_that.warrantyTerms,_that.vendorNote,_that.mediaKeys);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String offeredPrice,  int validityHours,  String? weightGrams,  String? makingCharges,  String? ratePerGram,  String? deliveryTimeframe,  String? warrantyTerms,  String? vendorNote,  List<String> mediaKeys)?  $default,) {final _that = this;
switch (_that) {
case _OfferTermsInput() when $default != null:
return $default(_that.offeredPrice,_that.validityHours,_that.weightGrams,_that.makingCharges,_that.ratePerGram,_that.deliveryTimeframe,_that.warrantyTerms,_that.vendorNote,_that.mediaKeys);case _:
  return null;

}
}

}

/// @nodoc


class _OfferTermsInput extends OfferTermsInput {
  const _OfferTermsInput({required this.offeredPrice, this.validityHours = 24, this.weightGrams, this.makingCharges, this.ratePerGram, this.deliveryTimeframe, this.warrantyTerms, this.vendorNote, final  List<String> mediaKeys = const <String>[]}): _mediaKeys = mediaKeys,super._();
  

@override final  String offeredPrice;
@override@JsonKey() final  int validityHours;
@override final  String? weightGrams;
@override final  String? makingCharges;
@override final  String? ratePerGram;
@override final  String? deliveryTimeframe;
@override final  String? warrantyTerms;
@override final  String? vendorNote;
 final  List<String> _mediaKeys;
@override@JsonKey() List<String> get mediaKeys {
  if (_mediaKeys is EqualUnmodifiableListView) return _mediaKeys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mediaKeys);
}


/// Create a copy of OfferTermsInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferTermsInputCopyWith<_OfferTermsInput> get copyWith => __$OfferTermsInputCopyWithImpl<_OfferTermsInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferTermsInput&&(identical(other.offeredPrice, offeredPrice) || other.offeredPrice == offeredPrice)&&(identical(other.validityHours, validityHours) || other.validityHours == validityHours)&&(identical(other.weightGrams, weightGrams) || other.weightGrams == weightGrams)&&(identical(other.makingCharges, makingCharges) || other.makingCharges == makingCharges)&&(identical(other.ratePerGram, ratePerGram) || other.ratePerGram == ratePerGram)&&(identical(other.deliveryTimeframe, deliveryTimeframe) || other.deliveryTimeframe == deliveryTimeframe)&&(identical(other.warrantyTerms, warrantyTerms) || other.warrantyTerms == warrantyTerms)&&(identical(other.vendorNote, vendorNote) || other.vendorNote == vendorNote)&&const DeepCollectionEquality().equals(other._mediaKeys, _mediaKeys));
}


@override
int get hashCode => Object.hash(runtimeType,offeredPrice,validityHours,weightGrams,makingCharges,ratePerGram,deliveryTimeframe,warrantyTerms,vendorNote,const DeepCollectionEquality().hash(_mediaKeys));

@override
String toString() {
  return 'OfferTermsInput(offeredPrice: $offeredPrice, validityHours: $validityHours, weightGrams: $weightGrams, makingCharges: $makingCharges, ratePerGram: $ratePerGram, deliveryTimeframe: $deliveryTimeframe, warrantyTerms: $warrantyTerms, vendorNote: $vendorNote, mediaKeys: $mediaKeys)';
}


}

/// @nodoc
abstract mixin class _$OfferTermsInputCopyWith<$Res> implements $OfferTermsInputCopyWith<$Res> {
  factory _$OfferTermsInputCopyWith(_OfferTermsInput value, $Res Function(_OfferTermsInput) _then) = __$OfferTermsInputCopyWithImpl;
@override @useResult
$Res call({
 String offeredPrice, int validityHours, String? weightGrams, String? makingCharges, String? ratePerGram, String? deliveryTimeframe, String? warrantyTerms, String? vendorNote, List<String> mediaKeys
});




}
/// @nodoc
class __$OfferTermsInputCopyWithImpl<$Res>
    implements _$OfferTermsInputCopyWith<$Res> {
  __$OfferTermsInputCopyWithImpl(this._self, this._then);

  final _OfferTermsInput _self;
  final $Res Function(_OfferTermsInput) _then;

/// Create a copy of OfferTermsInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? offeredPrice = null,Object? validityHours = null,Object? weightGrams = freezed,Object? makingCharges = freezed,Object? ratePerGram = freezed,Object? deliveryTimeframe = freezed,Object? warrantyTerms = freezed,Object? vendorNote = freezed,Object? mediaKeys = null,}) {
  return _then(_OfferTermsInput(
offeredPrice: null == offeredPrice ? _self.offeredPrice : offeredPrice // ignore: cast_nullable_to_non_nullable
as String,validityHours: null == validityHours ? _self.validityHours : validityHours // ignore: cast_nullable_to_non_nullable
as int,weightGrams: freezed == weightGrams ? _self.weightGrams : weightGrams // ignore: cast_nullable_to_non_nullable
as String?,makingCharges: freezed == makingCharges ? _self.makingCharges : makingCharges // ignore: cast_nullable_to_non_nullable
as String?,ratePerGram: freezed == ratePerGram ? _self.ratePerGram : ratePerGram // ignore: cast_nullable_to_non_nullable
as String?,deliveryTimeframe: freezed == deliveryTimeframe ? _self.deliveryTimeframe : deliveryTimeframe // ignore: cast_nullable_to_non_nullable
as String?,warrantyTerms: freezed == warrantyTerms ? _self.warrantyTerms : warrantyTerms // ignore: cast_nullable_to_non_nullable
as String?,vendorNote: freezed == vendorNote ? _self.vendorNote : vendorNote // ignore: cast_nullable_to_non_nullable
as String?,mediaKeys: null == mediaKeys ? _self._mediaKeys : mediaKeys // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
