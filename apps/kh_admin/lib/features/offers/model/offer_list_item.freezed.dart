// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offer_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OfferListItem {

 String get id; String? get reference; String get requestId; String? get requestReference;@JsonKey(unknownEnumValue: RequestType.findOrnament) RequestType? get requestType; String get vendorId; String get vendorName; double get offeredPrice;@JsonKey(unknownEnumValue: OfferState.pending) OfferState get state; DateTime get submittedAt; DateTime? get expiresAt; String? get outcome; double? get makingCharges; double? get ratePerGram;
/// Create a copy of OfferListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferListItemCopyWith<OfferListItem> get copyWith => _$OfferListItemCopyWithImpl<OfferListItem>(this as OfferListItem, _$identity);

  /// Serializes this OfferListItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferListItem&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.requestReference, requestReference) || other.requestReference == requestReference)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.vendorId, vendorId) || other.vendorId == vendorId)&&(identical(other.vendorName, vendorName) || other.vendorName == vendorName)&&(identical(other.offeredPrice, offeredPrice) || other.offeredPrice == offeredPrice)&&(identical(other.state, state) || other.state == state)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.makingCharges, makingCharges) || other.makingCharges == makingCharges)&&(identical(other.ratePerGram, ratePerGram) || other.ratePerGram == ratePerGram));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reference,requestId,requestReference,requestType,vendorId,vendorName,offeredPrice,state,submittedAt,expiresAt,outcome,makingCharges,ratePerGram);

@override
String toString() {
  return 'OfferListItem(id: $id, reference: $reference, requestId: $requestId, requestReference: $requestReference, requestType: $requestType, vendorId: $vendorId, vendorName: $vendorName, offeredPrice: $offeredPrice, state: $state, submittedAt: $submittedAt, expiresAt: $expiresAt, outcome: $outcome, makingCharges: $makingCharges, ratePerGram: $ratePerGram)';
}


}

/// @nodoc
abstract mixin class $OfferListItemCopyWith<$Res>  {
  factory $OfferListItemCopyWith(OfferListItem value, $Res Function(OfferListItem) _then) = _$OfferListItemCopyWithImpl;
@useResult
$Res call({
 String id, String? reference, String requestId, String? requestReference,@JsonKey(unknownEnumValue: RequestType.findOrnament) RequestType? requestType, String vendorId, String vendorName, double offeredPrice,@JsonKey(unknownEnumValue: OfferState.pending) OfferState state, DateTime submittedAt, DateTime? expiresAt, String? outcome, double? makingCharges, double? ratePerGram
});




}
/// @nodoc
class _$OfferListItemCopyWithImpl<$Res>
    implements $OfferListItemCopyWith<$Res> {
  _$OfferListItemCopyWithImpl(this._self, this._then);

  final OfferListItem _self;
  final $Res Function(OfferListItem) _then;

/// Create a copy of OfferListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reference = freezed,Object? requestId = null,Object? requestReference = freezed,Object? requestType = freezed,Object? vendorId = null,Object? vendorName = null,Object? offeredPrice = null,Object? state = null,Object? submittedAt = null,Object? expiresAt = freezed,Object? outcome = freezed,Object? makingCharges = freezed,Object? ratePerGram = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,requestReference: freezed == requestReference ? _self.requestReference : requestReference // ignore: cast_nullable_to_non_nullable
as String?,requestType: freezed == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as RequestType?,vendorId: null == vendorId ? _self.vendorId : vendorId // ignore: cast_nullable_to_non_nullable
as String,vendorName: null == vendorName ? _self.vendorName : vendorName // ignore: cast_nullable_to_non_nullable
as String,offeredPrice: null == offeredPrice ? _self.offeredPrice : offeredPrice // ignore: cast_nullable_to_non_nullable
as double,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OfferState,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,outcome: freezed == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as String?,makingCharges: freezed == makingCharges ? _self.makingCharges : makingCharges // ignore: cast_nullable_to_non_nullable
as double?,ratePerGram: freezed == ratePerGram ? _self.ratePerGram : ratePerGram // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [OfferListItem].
extension OfferListItemPatterns on OfferListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferListItem value)  $default,){
final _that = this;
switch (_that) {
case _OfferListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferListItem value)?  $default,){
final _that = this;
switch (_that) {
case _OfferListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? reference,  String requestId,  String? requestReference, @JsonKey(unknownEnumValue: RequestType.findOrnament)  RequestType? requestType,  String vendorId,  String vendorName,  double offeredPrice, @JsonKey(unknownEnumValue: OfferState.pending)  OfferState state,  DateTime submittedAt,  DateTime? expiresAt,  String? outcome,  double? makingCharges,  double? ratePerGram)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferListItem() when $default != null:
return $default(_that.id,_that.reference,_that.requestId,_that.requestReference,_that.requestType,_that.vendorId,_that.vendorName,_that.offeredPrice,_that.state,_that.submittedAt,_that.expiresAt,_that.outcome,_that.makingCharges,_that.ratePerGram);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? reference,  String requestId,  String? requestReference, @JsonKey(unknownEnumValue: RequestType.findOrnament)  RequestType? requestType,  String vendorId,  String vendorName,  double offeredPrice, @JsonKey(unknownEnumValue: OfferState.pending)  OfferState state,  DateTime submittedAt,  DateTime? expiresAt,  String? outcome,  double? makingCharges,  double? ratePerGram)  $default,) {final _that = this;
switch (_that) {
case _OfferListItem():
return $default(_that.id,_that.reference,_that.requestId,_that.requestReference,_that.requestType,_that.vendorId,_that.vendorName,_that.offeredPrice,_that.state,_that.submittedAt,_that.expiresAt,_that.outcome,_that.makingCharges,_that.ratePerGram);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? reference,  String requestId,  String? requestReference, @JsonKey(unknownEnumValue: RequestType.findOrnament)  RequestType? requestType,  String vendorId,  String vendorName,  double offeredPrice, @JsonKey(unknownEnumValue: OfferState.pending)  OfferState state,  DateTime submittedAt,  DateTime? expiresAt,  String? outcome,  double? makingCharges,  double? ratePerGram)?  $default,) {final _that = this;
switch (_that) {
case _OfferListItem() when $default != null:
return $default(_that.id,_that.reference,_that.requestId,_that.requestReference,_that.requestType,_that.vendorId,_that.vendorName,_that.offeredPrice,_that.state,_that.submittedAt,_that.expiresAt,_that.outcome,_that.makingCharges,_that.ratePerGram);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfferListItem implements OfferListItem {
  const _OfferListItem({required this.id, this.reference, required this.requestId, this.requestReference, @JsonKey(unknownEnumValue: RequestType.findOrnament) this.requestType, required this.vendorId, required this.vendorName, required this.offeredPrice, @JsonKey(unknownEnumValue: OfferState.pending) this.state = OfferState.pending, required this.submittedAt, this.expiresAt, this.outcome, this.makingCharges, this.ratePerGram});
  factory _OfferListItem.fromJson(Map<String, dynamic> json) => _$OfferListItemFromJson(json);

@override final  String id;
@override final  String? reference;
@override final  String requestId;
@override final  String? requestReference;
@override@JsonKey(unknownEnumValue: RequestType.findOrnament) final  RequestType? requestType;
@override final  String vendorId;
@override final  String vendorName;
@override final  double offeredPrice;
@override@JsonKey(unknownEnumValue: OfferState.pending) final  OfferState state;
@override final  DateTime submittedAt;
@override final  DateTime? expiresAt;
@override final  String? outcome;
@override final  double? makingCharges;
@override final  double? ratePerGram;

/// Create a copy of OfferListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferListItemCopyWith<_OfferListItem> get copyWith => __$OfferListItemCopyWithImpl<_OfferListItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferListItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferListItem&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.requestReference, requestReference) || other.requestReference == requestReference)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.vendorId, vendorId) || other.vendorId == vendorId)&&(identical(other.vendorName, vendorName) || other.vendorName == vendorName)&&(identical(other.offeredPrice, offeredPrice) || other.offeredPrice == offeredPrice)&&(identical(other.state, state) || other.state == state)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.makingCharges, makingCharges) || other.makingCharges == makingCharges)&&(identical(other.ratePerGram, ratePerGram) || other.ratePerGram == ratePerGram));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reference,requestId,requestReference,requestType,vendorId,vendorName,offeredPrice,state,submittedAt,expiresAt,outcome,makingCharges,ratePerGram);

@override
String toString() {
  return 'OfferListItem(id: $id, reference: $reference, requestId: $requestId, requestReference: $requestReference, requestType: $requestType, vendorId: $vendorId, vendorName: $vendorName, offeredPrice: $offeredPrice, state: $state, submittedAt: $submittedAt, expiresAt: $expiresAt, outcome: $outcome, makingCharges: $makingCharges, ratePerGram: $ratePerGram)';
}


}

/// @nodoc
abstract mixin class _$OfferListItemCopyWith<$Res> implements $OfferListItemCopyWith<$Res> {
  factory _$OfferListItemCopyWith(_OfferListItem value, $Res Function(_OfferListItem) _then) = __$OfferListItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String? reference, String requestId, String? requestReference,@JsonKey(unknownEnumValue: RequestType.findOrnament) RequestType? requestType, String vendorId, String vendorName, double offeredPrice,@JsonKey(unknownEnumValue: OfferState.pending) OfferState state, DateTime submittedAt, DateTime? expiresAt, String? outcome, double? makingCharges, double? ratePerGram
});




}
/// @nodoc
class __$OfferListItemCopyWithImpl<$Res>
    implements _$OfferListItemCopyWith<$Res> {
  __$OfferListItemCopyWithImpl(this._self, this._then);

  final _OfferListItem _self;
  final $Res Function(_OfferListItem) _then;

/// Create a copy of OfferListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reference = freezed,Object? requestId = null,Object? requestReference = freezed,Object? requestType = freezed,Object? vendorId = null,Object? vendorName = null,Object? offeredPrice = null,Object? state = null,Object? submittedAt = null,Object? expiresAt = freezed,Object? outcome = freezed,Object? makingCharges = freezed,Object? ratePerGram = freezed,}) {
  return _then(_OfferListItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,requestReference: freezed == requestReference ? _self.requestReference : requestReference // ignore: cast_nullable_to_non_nullable
as String?,requestType: freezed == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as RequestType?,vendorId: null == vendorId ? _self.vendorId : vendorId // ignore: cast_nullable_to_non_nullable
as String,vendorName: null == vendorName ? _self.vendorName : vendorName // ignore: cast_nullable_to_non_nullable
as String,offeredPrice: null == offeredPrice ? _self.offeredPrice : offeredPrice // ignore: cast_nullable_to_non_nullable
as double,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OfferState,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,outcome: freezed == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as String?,makingCharges: freezed == makingCharges ? _self.makingCharges : makingCharges // ignore: cast_nullable_to_non_nullable
as double?,ratePerGram: freezed == ratePerGram ? _self.ratePerGram : ratePerGram // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
