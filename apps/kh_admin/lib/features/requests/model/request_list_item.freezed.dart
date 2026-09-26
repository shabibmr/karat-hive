// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RequestListItem {

 String get id; String? get reference;@JsonKey(unknownEnumValue: RequestType.findOrnament) RequestType get requestType;@JsonKey(unknownEnumValue: Direction.buy) Direction get direction;@JsonKey(unknownEnumValue: RequestState.draft) RequestState get state; String get customerName; String? get customerId; String? get customerPhone; String get regionName; double? get indicativeValue; double? get budgetMin; double? get budgetMax; int get offerCount; String? get notes; String? get ornamentType; double? get weightGrams; String? get purityKarat; DateTime? get publishedAt; DateTime? get createdAt;
/// Create a copy of RequestListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestListItemCopyWith<RequestListItem> get copyWith => _$RequestListItemCopyWithImpl<RequestListItem>(this as RequestListItem, _$identity);

  /// Serializes this RequestListItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestListItem&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.state, state) || other.state == state)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.regionName, regionName) || other.regionName == regionName)&&(identical(other.indicativeValue, indicativeValue) || other.indicativeValue == indicativeValue)&&(identical(other.budgetMin, budgetMin) || other.budgetMin == budgetMin)&&(identical(other.budgetMax, budgetMax) || other.budgetMax == budgetMax)&&(identical(other.offerCount, offerCount) || other.offerCount == offerCount)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.ornamentType, ornamentType) || other.ornamentType == ornamentType)&&(identical(other.weightGrams, weightGrams) || other.weightGrams == weightGrams)&&(identical(other.purityKarat, purityKarat) || other.purityKarat == purityKarat)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reference,requestType,direction,state,customerName,customerId,customerPhone,regionName,indicativeValue,budgetMin,budgetMax,offerCount,notes,ornamentType,weightGrams,purityKarat,publishedAt,createdAt]);

@override
String toString() {
  return 'RequestListItem(id: $id, reference: $reference, requestType: $requestType, direction: $direction, state: $state, customerName: $customerName, customerId: $customerId, customerPhone: $customerPhone, regionName: $regionName, indicativeValue: $indicativeValue, budgetMin: $budgetMin, budgetMax: $budgetMax, offerCount: $offerCount, notes: $notes, ornamentType: $ornamentType, weightGrams: $weightGrams, purityKarat: $purityKarat, publishedAt: $publishedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $RequestListItemCopyWith<$Res>  {
  factory $RequestListItemCopyWith(RequestListItem value, $Res Function(RequestListItem) _then) = _$RequestListItemCopyWithImpl;
@useResult
$Res call({
 String id, String? reference,@JsonKey(unknownEnumValue: RequestType.findOrnament) RequestType requestType,@JsonKey(unknownEnumValue: Direction.buy) Direction direction,@JsonKey(unknownEnumValue: RequestState.draft) RequestState state, String customerName, String? customerId, String? customerPhone, String regionName, double? indicativeValue, double? budgetMin, double? budgetMax, int offerCount, String? notes, String? ornamentType, double? weightGrams, String? purityKarat, DateTime? publishedAt, DateTime? createdAt
});




}
/// @nodoc
class _$RequestListItemCopyWithImpl<$Res>
    implements $RequestListItemCopyWith<$Res> {
  _$RequestListItemCopyWithImpl(this._self, this._then);

  final RequestListItem _self;
  final $Res Function(RequestListItem) _then;

/// Create a copy of RequestListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reference = freezed,Object? requestType = null,Object? direction = null,Object? state = null,Object? customerName = null,Object? customerId = freezed,Object? customerPhone = freezed,Object? regionName = null,Object? indicativeValue = freezed,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? offerCount = null,Object? notes = freezed,Object? ornamentType = freezed,Object? weightGrams = freezed,Object? purityKarat = freezed,Object? publishedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,requestType: null == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as RequestType,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as Direction,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as RequestState,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,regionName: null == regionName ? _self.regionName : regionName // ignore: cast_nullable_to_non_nullable
as String,indicativeValue: freezed == indicativeValue ? _self.indicativeValue : indicativeValue // ignore: cast_nullable_to_non_nullable
as double?,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin // ignore: cast_nullable_to_non_nullable
as double?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as double?,offerCount: null == offerCount ? _self.offerCount : offerCount // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,ornamentType: freezed == ornamentType ? _self.ornamentType : ornamentType // ignore: cast_nullable_to_non_nullable
as String?,weightGrams: freezed == weightGrams ? _self.weightGrams : weightGrams // ignore: cast_nullable_to_non_nullable
as double?,purityKarat: freezed == purityKarat ? _self.purityKarat : purityKarat // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestListItem].
extension RequestListItemPatterns on RequestListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestListItem value)  $default,){
final _that = this;
switch (_that) {
case _RequestListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestListItem value)?  $default,){
final _that = this;
switch (_that) {
case _RequestListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? reference, @JsonKey(unknownEnumValue: RequestType.findOrnament)  RequestType requestType, @JsonKey(unknownEnumValue: Direction.buy)  Direction direction, @JsonKey(unknownEnumValue: RequestState.draft)  RequestState state,  String customerName,  String? customerId,  String? customerPhone,  String regionName,  double? indicativeValue,  double? budgetMin,  double? budgetMax,  int offerCount,  String? notes,  String? ornamentType,  double? weightGrams,  String? purityKarat,  DateTime? publishedAt,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestListItem() when $default != null:
return $default(_that.id,_that.reference,_that.requestType,_that.direction,_that.state,_that.customerName,_that.customerId,_that.customerPhone,_that.regionName,_that.indicativeValue,_that.budgetMin,_that.budgetMax,_that.offerCount,_that.notes,_that.ornamentType,_that.weightGrams,_that.purityKarat,_that.publishedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? reference, @JsonKey(unknownEnumValue: RequestType.findOrnament)  RequestType requestType, @JsonKey(unknownEnumValue: Direction.buy)  Direction direction, @JsonKey(unknownEnumValue: RequestState.draft)  RequestState state,  String customerName,  String? customerId,  String? customerPhone,  String regionName,  double? indicativeValue,  double? budgetMin,  double? budgetMax,  int offerCount,  String? notes,  String? ornamentType,  double? weightGrams,  String? purityKarat,  DateTime? publishedAt,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _RequestListItem():
return $default(_that.id,_that.reference,_that.requestType,_that.direction,_that.state,_that.customerName,_that.customerId,_that.customerPhone,_that.regionName,_that.indicativeValue,_that.budgetMin,_that.budgetMax,_that.offerCount,_that.notes,_that.ornamentType,_that.weightGrams,_that.purityKarat,_that.publishedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? reference, @JsonKey(unknownEnumValue: RequestType.findOrnament)  RequestType requestType, @JsonKey(unknownEnumValue: Direction.buy)  Direction direction, @JsonKey(unknownEnumValue: RequestState.draft)  RequestState state,  String customerName,  String? customerId,  String? customerPhone,  String regionName,  double? indicativeValue,  double? budgetMin,  double? budgetMax,  int offerCount,  String? notes,  String? ornamentType,  double? weightGrams,  String? purityKarat,  DateTime? publishedAt,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _RequestListItem() when $default != null:
return $default(_that.id,_that.reference,_that.requestType,_that.direction,_that.state,_that.customerName,_that.customerId,_that.customerPhone,_that.regionName,_that.indicativeValue,_that.budgetMin,_that.budgetMax,_that.offerCount,_that.notes,_that.ornamentType,_that.weightGrams,_that.purityKarat,_that.publishedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RequestListItem extends RequestListItem {
  const _RequestListItem({required this.id, this.reference, @JsonKey(unknownEnumValue: RequestType.findOrnament) required this.requestType, @JsonKey(unknownEnumValue: Direction.buy) required this.direction, @JsonKey(unknownEnumValue: RequestState.draft) required this.state, this.customerName = 'Unknown Customer', this.customerId, this.customerPhone, this.regionName = '—', this.indicativeValue, this.budgetMin, this.budgetMax, this.offerCount = 0, this.notes, this.ornamentType, this.weightGrams, this.purityKarat, this.publishedAt, this.createdAt}): super._();
  factory _RequestListItem.fromJson(Map<String, dynamic> json) => _$RequestListItemFromJson(json);

@override final  String id;
@override final  String? reference;
@override@JsonKey(unknownEnumValue: RequestType.findOrnament) final  RequestType requestType;
@override@JsonKey(unknownEnumValue: Direction.buy) final  Direction direction;
@override@JsonKey(unknownEnumValue: RequestState.draft) final  RequestState state;
@override@JsonKey() final  String customerName;
@override final  String? customerId;
@override final  String? customerPhone;
@override@JsonKey() final  String regionName;
@override final  double? indicativeValue;
@override final  double? budgetMin;
@override final  double? budgetMax;
@override@JsonKey() final  int offerCount;
@override final  String? notes;
@override final  String? ornamentType;
@override final  double? weightGrams;
@override final  String? purityKarat;
@override final  DateTime? publishedAt;
@override final  DateTime? createdAt;

/// Create a copy of RequestListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestListItemCopyWith<_RequestListItem> get copyWith => __$RequestListItemCopyWithImpl<_RequestListItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestListItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestListItem&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.state, state) || other.state == state)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.regionName, regionName) || other.regionName == regionName)&&(identical(other.indicativeValue, indicativeValue) || other.indicativeValue == indicativeValue)&&(identical(other.budgetMin, budgetMin) || other.budgetMin == budgetMin)&&(identical(other.budgetMax, budgetMax) || other.budgetMax == budgetMax)&&(identical(other.offerCount, offerCount) || other.offerCount == offerCount)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.ornamentType, ornamentType) || other.ornamentType == ornamentType)&&(identical(other.weightGrams, weightGrams) || other.weightGrams == weightGrams)&&(identical(other.purityKarat, purityKarat) || other.purityKarat == purityKarat)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reference,requestType,direction,state,customerName,customerId,customerPhone,regionName,indicativeValue,budgetMin,budgetMax,offerCount,notes,ornamentType,weightGrams,purityKarat,publishedAt,createdAt]);

@override
String toString() {
  return 'RequestListItem(id: $id, reference: $reference, requestType: $requestType, direction: $direction, state: $state, customerName: $customerName, customerId: $customerId, customerPhone: $customerPhone, regionName: $regionName, indicativeValue: $indicativeValue, budgetMin: $budgetMin, budgetMax: $budgetMax, offerCount: $offerCount, notes: $notes, ornamentType: $ornamentType, weightGrams: $weightGrams, purityKarat: $purityKarat, publishedAt: $publishedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$RequestListItemCopyWith<$Res> implements $RequestListItemCopyWith<$Res> {
  factory _$RequestListItemCopyWith(_RequestListItem value, $Res Function(_RequestListItem) _then) = __$RequestListItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String? reference,@JsonKey(unknownEnumValue: RequestType.findOrnament) RequestType requestType,@JsonKey(unknownEnumValue: Direction.buy) Direction direction,@JsonKey(unknownEnumValue: RequestState.draft) RequestState state, String customerName, String? customerId, String? customerPhone, String regionName, double? indicativeValue, double? budgetMin, double? budgetMax, int offerCount, String? notes, String? ornamentType, double? weightGrams, String? purityKarat, DateTime? publishedAt, DateTime? createdAt
});




}
/// @nodoc
class __$RequestListItemCopyWithImpl<$Res>
    implements _$RequestListItemCopyWith<$Res> {
  __$RequestListItemCopyWithImpl(this._self, this._then);

  final _RequestListItem _self;
  final $Res Function(_RequestListItem) _then;

/// Create a copy of RequestListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reference = freezed,Object? requestType = null,Object? direction = null,Object? state = null,Object? customerName = null,Object? customerId = freezed,Object? customerPhone = freezed,Object? regionName = null,Object? indicativeValue = freezed,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? offerCount = null,Object? notes = freezed,Object? ornamentType = freezed,Object? weightGrams = freezed,Object? purityKarat = freezed,Object? publishedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_RequestListItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,requestType: null == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as RequestType,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as Direction,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as RequestState,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,regionName: null == regionName ? _self.regionName : regionName // ignore: cast_nullable_to_non_nullable
as String,indicativeValue: freezed == indicativeValue ? _self.indicativeValue : indicativeValue // ignore: cast_nullable_to_non_nullable
as double?,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin // ignore: cast_nullable_to_non_nullable
as double?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as double?,offerCount: null == offerCount ? _self.offerCount : offerCount // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,ornamentType: freezed == ornamentType ? _self.ornamentType : ornamentType // ignore: cast_nullable_to_non_nullable
as String?,weightGrams: freezed == weightGrams ? _self.weightGrams : weightGrams // ignore: cast_nullable_to_non_nullable
as double?,purityKarat: freezed == purityKarat ? _self.purityKarat : purityKarat // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
