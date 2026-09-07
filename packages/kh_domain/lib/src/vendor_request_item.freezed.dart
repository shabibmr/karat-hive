// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vendor_request_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VendorRequestItem {

 String get id; String? get reference; String get requestType; String get direction; String get state; String get categoryId; String? get categoryName; String get regionId; String? get regionName; double? get weightGrams; bool get weightIsApproximate; String? get purityKarat; double? get budgetMin; double? get budgetMax; bool get budgetIsFlexible; String? get notes; DateTime? get publishedAt; DateTime? get expiresAt; int get offerCount; DateTime? get viewedAt; bool get hasResponded; MaskedParty get customer; List<RequestMediaRef> get media;
/// Create a copy of VendorRequestItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorRequestItemCopyWith<VendorRequestItem> get copyWith => _$VendorRequestItemCopyWithImpl<VendorRequestItem>(this as VendorRequestItem, _$identity);

  /// Serializes this VendorRequestItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorRequestItem&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.state, state) || other.state == state)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.regionName, regionName) || other.regionName == regionName)&&(identical(other.weightGrams, weightGrams) || other.weightGrams == weightGrams)&&(identical(other.weightIsApproximate, weightIsApproximate) || other.weightIsApproximate == weightIsApproximate)&&(identical(other.purityKarat, purityKarat) || other.purityKarat == purityKarat)&&(identical(other.budgetMin, budgetMin) || other.budgetMin == budgetMin)&&(identical(other.budgetMax, budgetMax) || other.budgetMax == budgetMax)&&(identical(other.budgetIsFlexible, budgetIsFlexible) || other.budgetIsFlexible == budgetIsFlexible)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.offerCount, offerCount) || other.offerCount == offerCount)&&(identical(other.viewedAt, viewedAt) || other.viewedAt == viewedAt)&&(identical(other.hasResponded, hasResponded) || other.hasResponded == hasResponded)&&(identical(other.customer, customer) || other.customer == customer)&&const DeepCollectionEquality().equals(other.media, media));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reference,requestType,direction,state,categoryId,categoryName,regionId,regionName,weightGrams,weightIsApproximate,purityKarat,budgetMin,budgetMax,budgetIsFlexible,notes,publishedAt,expiresAt,offerCount,viewedAt,hasResponded,customer,const DeepCollectionEquality().hash(media)]);

@override
String toString() {
  return 'VendorRequestItem(id: $id, reference: $reference, requestType: $requestType, direction: $direction, state: $state, categoryId: $categoryId, categoryName: $categoryName, regionId: $regionId, regionName: $regionName, weightGrams: $weightGrams, weightIsApproximate: $weightIsApproximate, purityKarat: $purityKarat, budgetMin: $budgetMin, budgetMax: $budgetMax, budgetIsFlexible: $budgetIsFlexible, notes: $notes, publishedAt: $publishedAt, expiresAt: $expiresAt, offerCount: $offerCount, viewedAt: $viewedAt, hasResponded: $hasResponded, customer: $customer, media: $media)';
}


}

/// @nodoc
abstract mixin class $VendorRequestItemCopyWith<$Res>  {
  factory $VendorRequestItemCopyWith(VendorRequestItem value, $Res Function(VendorRequestItem) _then) = _$VendorRequestItemCopyWithImpl;
@useResult
$Res call({
 String id, String? reference, String requestType, String direction, String state, String categoryId, String? categoryName, String regionId, String? regionName, double? weightGrams, bool weightIsApproximate, String? purityKarat, double? budgetMin, double? budgetMax, bool budgetIsFlexible, String? notes, DateTime? publishedAt, DateTime? expiresAt, int offerCount, DateTime? viewedAt, bool hasResponded, MaskedParty customer, List<RequestMediaRef> media
});


$MaskedPartyCopyWith<$Res> get customer;

}
/// @nodoc
class _$VendorRequestItemCopyWithImpl<$Res>
    implements $VendorRequestItemCopyWith<$Res> {
  _$VendorRequestItemCopyWithImpl(this._self, this._then);

  final VendorRequestItem _self;
  final $Res Function(VendorRequestItem) _then;

/// Create a copy of VendorRequestItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reference = freezed,Object? requestType = null,Object? direction = null,Object? state = null,Object? categoryId = null,Object? categoryName = freezed,Object? regionId = null,Object? regionName = freezed,Object? weightGrams = freezed,Object? weightIsApproximate = null,Object? purityKarat = freezed,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? budgetIsFlexible = null,Object? notes = freezed,Object? publishedAt = freezed,Object? expiresAt = freezed,Object? offerCount = null,Object? viewedAt = freezed,Object? hasResponded = null,Object? customer = null,Object? media = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,requestType: null == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,regionId: null == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as String,regionName: freezed == regionName ? _self.regionName : regionName // ignore: cast_nullable_to_non_nullable
as String?,weightGrams: freezed == weightGrams ? _self.weightGrams : weightGrams // ignore: cast_nullable_to_non_nullable
as double?,weightIsApproximate: null == weightIsApproximate ? _self.weightIsApproximate : weightIsApproximate // ignore: cast_nullable_to_non_nullable
as bool,purityKarat: freezed == purityKarat ? _self.purityKarat : purityKarat // ignore: cast_nullable_to_non_nullable
as String?,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin // ignore: cast_nullable_to_non_nullable
as double?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as double?,budgetIsFlexible: null == budgetIsFlexible ? _self.budgetIsFlexible : budgetIsFlexible // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,offerCount: null == offerCount ? _self.offerCount : offerCount // ignore: cast_nullable_to_non_nullable
as int,viewedAt: freezed == viewedAt ? _self.viewedAt : viewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,hasResponded: null == hasResponded ? _self.hasResponded : hasResponded // ignore: cast_nullable_to_non_nullable
as bool,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as MaskedParty,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as List<RequestMediaRef>,
  ));
}
/// Create a copy of VendorRequestItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MaskedPartyCopyWith<$Res> get customer {
  
  return $MaskedPartyCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}
}


/// Adds pattern-matching-related methods to [VendorRequestItem].
extension VendorRequestItemPatterns on VendorRequestItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorRequestItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorRequestItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorRequestItem value)  $default,){
final _that = this;
switch (_that) {
case _VendorRequestItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorRequestItem value)?  $default,){
final _that = this;
switch (_that) {
case _VendorRequestItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? reference,  String requestType,  String direction,  String state,  String categoryId,  String? categoryName,  String regionId,  String? regionName,  double? weightGrams,  bool weightIsApproximate,  String? purityKarat,  double? budgetMin,  double? budgetMax,  bool budgetIsFlexible,  String? notes,  DateTime? publishedAt,  DateTime? expiresAt,  int offerCount,  DateTime? viewedAt,  bool hasResponded,  MaskedParty customer,  List<RequestMediaRef> media)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorRequestItem() when $default != null:
return $default(_that.id,_that.reference,_that.requestType,_that.direction,_that.state,_that.categoryId,_that.categoryName,_that.regionId,_that.regionName,_that.weightGrams,_that.weightIsApproximate,_that.purityKarat,_that.budgetMin,_that.budgetMax,_that.budgetIsFlexible,_that.notes,_that.publishedAt,_that.expiresAt,_that.offerCount,_that.viewedAt,_that.hasResponded,_that.customer,_that.media);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? reference,  String requestType,  String direction,  String state,  String categoryId,  String? categoryName,  String regionId,  String? regionName,  double? weightGrams,  bool weightIsApproximate,  String? purityKarat,  double? budgetMin,  double? budgetMax,  bool budgetIsFlexible,  String? notes,  DateTime? publishedAt,  DateTime? expiresAt,  int offerCount,  DateTime? viewedAt,  bool hasResponded,  MaskedParty customer,  List<RequestMediaRef> media)  $default,) {final _that = this;
switch (_that) {
case _VendorRequestItem():
return $default(_that.id,_that.reference,_that.requestType,_that.direction,_that.state,_that.categoryId,_that.categoryName,_that.regionId,_that.regionName,_that.weightGrams,_that.weightIsApproximate,_that.purityKarat,_that.budgetMin,_that.budgetMax,_that.budgetIsFlexible,_that.notes,_that.publishedAt,_that.expiresAt,_that.offerCount,_that.viewedAt,_that.hasResponded,_that.customer,_that.media);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? reference,  String requestType,  String direction,  String state,  String categoryId,  String? categoryName,  String regionId,  String? regionName,  double? weightGrams,  bool weightIsApproximate,  String? purityKarat,  double? budgetMin,  double? budgetMax,  bool budgetIsFlexible,  String? notes,  DateTime? publishedAt,  DateTime? expiresAt,  int offerCount,  DateTime? viewedAt,  bool hasResponded,  MaskedParty customer,  List<RequestMediaRef> media)?  $default,) {final _that = this;
switch (_that) {
case _VendorRequestItem() when $default != null:
return $default(_that.id,_that.reference,_that.requestType,_that.direction,_that.state,_that.categoryId,_that.categoryName,_that.regionId,_that.regionName,_that.weightGrams,_that.weightIsApproximate,_that.purityKarat,_that.budgetMin,_that.budgetMax,_that.budgetIsFlexible,_that.notes,_that.publishedAt,_that.expiresAt,_that.offerCount,_that.viewedAt,_that.hasResponded,_that.customer,_that.media);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VendorRequestItem extends VendorRequestItem {
  const _VendorRequestItem({required this.id, this.reference, required this.requestType, required this.direction, required this.state, required this.categoryId, this.categoryName, required this.regionId, this.regionName, this.weightGrams, this.weightIsApproximate = false, this.purityKarat, this.budgetMin, this.budgetMax, this.budgetIsFlexible = false, this.notes, this.publishedAt, this.expiresAt, this.offerCount = 0, this.viewedAt, this.hasResponded = false, required this.customer, final  List<RequestMediaRef> media = const <RequestMediaRef>[]}): _media = media,super._();
  factory _VendorRequestItem.fromJson(Map<String, dynamic> json) => _$VendorRequestItemFromJson(json);

@override final  String id;
@override final  String? reference;
@override final  String requestType;
@override final  String direction;
@override final  String state;
@override final  String categoryId;
@override final  String? categoryName;
@override final  String regionId;
@override final  String? regionName;
@override final  double? weightGrams;
@override@JsonKey() final  bool weightIsApproximate;
@override final  String? purityKarat;
@override final  double? budgetMin;
@override final  double? budgetMax;
@override@JsonKey() final  bool budgetIsFlexible;
@override final  String? notes;
@override final  DateTime? publishedAt;
@override final  DateTime? expiresAt;
@override@JsonKey() final  int offerCount;
@override final  DateTime? viewedAt;
@override@JsonKey() final  bool hasResponded;
@override final  MaskedParty customer;
 final  List<RequestMediaRef> _media;
@override@JsonKey() List<RequestMediaRef> get media {
  if (_media is EqualUnmodifiableListView) return _media;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_media);
}


/// Create a copy of VendorRequestItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorRequestItemCopyWith<_VendorRequestItem> get copyWith => __$VendorRequestItemCopyWithImpl<_VendorRequestItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VendorRequestItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorRequestItem&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.state, state) || other.state == state)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.regionName, regionName) || other.regionName == regionName)&&(identical(other.weightGrams, weightGrams) || other.weightGrams == weightGrams)&&(identical(other.weightIsApproximate, weightIsApproximate) || other.weightIsApproximate == weightIsApproximate)&&(identical(other.purityKarat, purityKarat) || other.purityKarat == purityKarat)&&(identical(other.budgetMin, budgetMin) || other.budgetMin == budgetMin)&&(identical(other.budgetMax, budgetMax) || other.budgetMax == budgetMax)&&(identical(other.budgetIsFlexible, budgetIsFlexible) || other.budgetIsFlexible == budgetIsFlexible)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.offerCount, offerCount) || other.offerCount == offerCount)&&(identical(other.viewedAt, viewedAt) || other.viewedAt == viewedAt)&&(identical(other.hasResponded, hasResponded) || other.hasResponded == hasResponded)&&(identical(other.customer, customer) || other.customer == customer)&&const DeepCollectionEquality().equals(other._media, _media));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reference,requestType,direction,state,categoryId,categoryName,regionId,regionName,weightGrams,weightIsApproximate,purityKarat,budgetMin,budgetMax,budgetIsFlexible,notes,publishedAt,expiresAt,offerCount,viewedAt,hasResponded,customer,const DeepCollectionEquality().hash(_media)]);

@override
String toString() {
  return 'VendorRequestItem(id: $id, reference: $reference, requestType: $requestType, direction: $direction, state: $state, categoryId: $categoryId, categoryName: $categoryName, regionId: $regionId, regionName: $regionName, weightGrams: $weightGrams, weightIsApproximate: $weightIsApproximate, purityKarat: $purityKarat, budgetMin: $budgetMin, budgetMax: $budgetMax, budgetIsFlexible: $budgetIsFlexible, notes: $notes, publishedAt: $publishedAt, expiresAt: $expiresAt, offerCount: $offerCount, viewedAt: $viewedAt, hasResponded: $hasResponded, customer: $customer, media: $media)';
}


}

/// @nodoc
abstract mixin class _$VendorRequestItemCopyWith<$Res> implements $VendorRequestItemCopyWith<$Res> {
  factory _$VendorRequestItemCopyWith(_VendorRequestItem value, $Res Function(_VendorRequestItem) _then) = __$VendorRequestItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String? reference, String requestType, String direction, String state, String categoryId, String? categoryName, String regionId, String? regionName, double? weightGrams, bool weightIsApproximate, String? purityKarat, double? budgetMin, double? budgetMax, bool budgetIsFlexible, String? notes, DateTime? publishedAt, DateTime? expiresAt, int offerCount, DateTime? viewedAt, bool hasResponded, MaskedParty customer, List<RequestMediaRef> media
});


@override $MaskedPartyCopyWith<$Res> get customer;

}
/// @nodoc
class __$VendorRequestItemCopyWithImpl<$Res>
    implements _$VendorRequestItemCopyWith<$Res> {
  __$VendorRequestItemCopyWithImpl(this._self, this._then);

  final _VendorRequestItem _self;
  final $Res Function(_VendorRequestItem) _then;

/// Create a copy of VendorRequestItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reference = freezed,Object? requestType = null,Object? direction = null,Object? state = null,Object? categoryId = null,Object? categoryName = freezed,Object? regionId = null,Object? regionName = freezed,Object? weightGrams = freezed,Object? weightIsApproximate = null,Object? purityKarat = freezed,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? budgetIsFlexible = null,Object? notes = freezed,Object? publishedAt = freezed,Object? expiresAt = freezed,Object? offerCount = null,Object? viewedAt = freezed,Object? hasResponded = null,Object? customer = null,Object? media = null,}) {
  return _then(_VendorRequestItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,requestType: null == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,regionId: null == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as String,regionName: freezed == regionName ? _self.regionName : regionName // ignore: cast_nullable_to_non_nullable
as String?,weightGrams: freezed == weightGrams ? _self.weightGrams : weightGrams // ignore: cast_nullable_to_non_nullable
as double?,weightIsApproximate: null == weightIsApproximate ? _self.weightIsApproximate : weightIsApproximate // ignore: cast_nullable_to_non_nullable
as bool,purityKarat: freezed == purityKarat ? _self.purityKarat : purityKarat // ignore: cast_nullable_to_non_nullable
as String?,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin // ignore: cast_nullable_to_non_nullable
as double?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as double?,budgetIsFlexible: null == budgetIsFlexible ? _self.budgetIsFlexible : budgetIsFlexible // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,offerCount: null == offerCount ? _self.offerCount : offerCount // ignore: cast_nullable_to_non_nullable
as int,viewedAt: freezed == viewedAt ? _self.viewedAt : viewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,hasResponded: null == hasResponded ? _self.hasResponded : hasResponded // ignore: cast_nullable_to_non_nullable
as bool,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as MaskedParty,media: null == media ? _self._media : media // ignore: cast_nullable_to_non_nullable
as List<RequestMediaRef>,
  ));
}

/// Create a copy of VendorRequestItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MaskedPartyCopyWith<$Res> get customer {
  
  return $MaskedPartyCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}
}

// dart format on
