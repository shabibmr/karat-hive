// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'common_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegionSummaryDto {

 String get id; String get nameEn; String get nameAr; bool get isActive; int get displayOrder;
/// Create a copy of RegionSummaryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegionSummaryDtoCopyWith<RegionSummaryDto> get copyWith => _$RegionSummaryDtoCopyWithImpl<RegionSummaryDto>(this as RegionSummaryDto, _$identity);

  /// Serializes this RegionSummaryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegionSummaryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameEn,nameAr,isActive,displayOrder);

@override
String toString() {
  return 'RegionSummaryDto(id: $id, nameEn: $nameEn, nameAr: $nameAr, isActive: $isActive, displayOrder: $displayOrder)';
}


}

/// @nodoc
abstract mixin class $RegionSummaryDtoCopyWith<$Res>  {
  factory $RegionSummaryDtoCopyWith(RegionSummaryDto value, $Res Function(RegionSummaryDto) _then) = _$RegionSummaryDtoCopyWithImpl;
@useResult
$Res call({
 String id, String nameEn, String nameAr, bool isActive, int displayOrder
});




}
/// @nodoc
class _$RegionSummaryDtoCopyWithImpl<$Res>
    implements $RegionSummaryDtoCopyWith<$Res> {
  _$RegionSummaryDtoCopyWithImpl(this._self, this._then);

  final RegionSummaryDto _self;
  final $Res Function(RegionSummaryDto) _then;

/// Create a copy of RegionSummaryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nameEn = null,Object? nameAr = null,Object? isActive = null,Object? displayOrder = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RegionSummaryDto].
extension RegionSummaryDtoPatterns on RegionSummaryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegionSummaryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegionSummaryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegionSummaryDto value)  $default,){
final _that = this;
switch (_that) {
case _RegionSummaryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegionSummaryDto value)?  $default,){
final _that = this;
switch (_that) {
case _RegionSummaryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nameEn,  String nameAr,  bool isActive,  int displayOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegionSummaryDto() when $default != null:
return $default(_that.id,_that.nameEn,_that.nameAr,_that.isActive,_that.displayOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nameEn,  String nameAr,  bool isActive,  int displayOrder)  $default,) {final _that = this;
switch (_that) {
case _RegionSummaryDto():
return $default(_that.id,_that.nameEn,_that.nameAr,_that.isActive,_that.displayOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nameEn,  String nameAr,  bool isActive,  int displayOrder)?  $default,) {final _that = this;
switch (_that) {
case _RegionSummaryDto() when $default != null:
return $default(_that.id,_that.nameEn,_that.nameAr,_that.isActive,_that.displayOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegionSummaryDto implements RegionSummaryDto {
  const _RegionSummaryDto({required this.id, required this.nameEn, required this.nameAr, required this.isActive, required this.displayOrder});
  factory _RegionSummaryDto.fromJson(Map<String, dynamic> json) => _$RegionSummaryDtoFromJson(json);

@override final  String id;
@override final  String nameEn;
@override final  String nameAr;
@override final  bool isActive;
@override final  int displayOrder;

/// Create a copy of RegionSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegionSummaryDtoCopyWith<_RegionSummaryDto> get copyWith => __$RegionSummaryDtoCopyWithImpl<_RegionSummaryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegionSummaryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegionSummaryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameEn,nameAr,isActive,displayOrder);

@override
String toString() {
  return 'RegionSummaryDto(id: $id, nameEn: $nameEn, nameAr: $nameAr, isActive: $isActive, displayOrder: $displayOrder)';
}


}

/// @nodoc
abstract mixin class _$RegionSummaryDtoCopyWith<$Res> implements $RegionSummaryDtoCopyWith<$Res> {
  factory _$RegionSummaryDtoCopyWith(_RegionSummaryDto value, $Res Function(_RegionSummaryDto) _then) = __$RegionSummaryDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String nameEn, String nameAr, bool isActive, int displayOrder
});




}
/// @nodoc
class __$RegionSummaryDtoCopyWithImpl<$Res>
    implements _$RegionSummaryDtoCopyWith<$Res> {
  __$RegionSummaryDtoCopyWithImpl(this._self, this._then);

  final _RegionSummaryDto _self;
  final $Res Function(_RegionSummaryDto) _then;

/// Create a copy of RegionSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nameEn = null,Object? nameAr = null,Object? isActive = null,Object? displayOrder = null,}) {
  return _then(_RegionSummaryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RatingSummaryDto {

 String get average; int get count; Map<String, int> get distribution; bool get limitedHistory;
/// Create a copy of RatingSummaryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RatingSummaryDtoCopyWith<RatingSummaryDto> get copyWith => _$RatingSummaryDtoCopyWithImpl<RatingSummaryDto>(this as RatingSummaryDto, _$identity);

  /// Serializes this RatingSummaryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RatingSummaryDto&&(identical(other.average, average) || other.average == average)&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other.distribution, distribution)&&(identical(other.limitedHistory, limitedHistory) || other.limitedHistory == limitedHistory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,average,count,const DeepCollectionEquality().hash(distribution),limitedHistory);

@override
String toString() {
  return 'RatingSummaryDto(average: $average, count: $count, distribution: $distribution, limitedHistory: $limitedHistory)';
}


}

/// @nodoc
abstract mixin class $RatingSummaryDtoCopyWith<$Res>  {
  factory $RatingSummaryDtoCopyWith(RatingSummaryDto value, $Res Function(RatingSummaryDto) _then) = _$RatingSummaryDtoCopyWithImpl;
@useResult
$Res call({
 String average, int count, Map<String, int> distribution, bool limitedHistory
});




}
/// @nodoc
class _$RatingSummaryDtoCopyWithImpl<$Res>
    implements $RatingSummaryDtoCopyWith<$Res> {
  _$RatingSummaryDtoCopyWithImpl(this._self, this._then);

  final RatingSummaryDto _self;
  final $Res Function(RatingSummaryDto) _then;

/// Create a copy of RatingSummaryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? average = null,Object? count = null,Object? distribution = null,Object? limitedHistory = null,}) {
  return _then(_self.copyWith(
average: null == average ? _self.average : average // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,distribution: null == distribution ? _self.distribution : distribution // ignore: cast_nullable_to_non_nullable
as Map<String, int>,limitedHistory: null == limitedHistory ? _self.limitedHistory : limitedHistory // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RatingSummaryDto].
extension RatingSummaryDtoPatterns on RatingSummaryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RatingSummaryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RatingSummaryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RatingSummaryDto value)  $default,){
final _that = this;
switch (_that) {
case _RatingSummaryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RatingSummaryDto value)?  $default,){
final _that = this;
switch (_that) {
case _RatingSummaryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String average,  int count,  Map<String, int> distribution,  bool limitedHistory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RatingSummaryDto() when $default != null:
return $default(_that.average,_that.count,_that.distribution,_that.limitedHistory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String average,  int count,  Map<String, int> distribution,  bool limitedHistory)  $default,) {final _that = this;
switch (_that) {
case _RatingSummaryDto():
return $default(_that.average,_that.count,_that.distribution,_that.limitedHistory);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String average,  int count,  Map<String, int> distribution,  bool limitedHistory)?  $default,) {final _that = this;
switch (_that) {
case _RatingSummaryDto() when $default != null:
return $default(_that.average,_that.count,_that.distribution,_that.limitedHistory);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RatingSummaryDto implements RatingSummaryDto {
  const _RatingSummaryDto({required this.average, required this.count, final  Map<String, int> distribution = const <String, int>{}, this.limitedHistory = false}): _distribution = distribution;
  factory _RatingSummaryDto.fromJson(Map<String, dynamic> json) => _$RatingSummaryDtoFromJson(json);

@override final  String average;
@override final  int count;
 final  Map<String, int> _distribution;
@override@JsonKey() Map<String, int> get distribution {
  if (_distribution is EqualUnmodifiableMapView) return _distribution;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_distribution);
}

@override@JsonKey() final  bool limitedHistory;

/// Create a copy of RatingSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RatingSummaryDtoCopyWith<_RatingSummaryDto> get copyWith => __$RatingSummaryDtoCopyWithImpl<_RatingSummaryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RatingSummaryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RatingSummaryDto&&(identical(other.average, average) || other.average == average)&&(identical(other.count, count) || other.count == count)&&const DeepCollectionEquality().equals(other._distribution, _distribution)&&(identical(other.limitedHistory, limitedHistory) || other.limitedHistory == limitedHistory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,average,count,const DeepCollectionEquality().hash(_distribution),limitedHistory);

@override
String toString() {
  return 'RatingSummaryDto(average: $average, count: $count, distribution: $distribution, limitedHistory: $limitedHistory)';
}


}

/// @nodoc
abstract mixin class _$RatingSummaryDtoCopyWith<$Res> implements $RatingSummaryDtoCopyWith<$Res> {
  factory _$RatingSummaryDtoCopyWith(_RatingSummaryDto value, $Res Function(_RatingSummaryDto) _then) = __$RatingSummaryDtoCopyWithImpl;
@override @useResult
$Res call({
 String average, int count, Map<String, int> distribution, bool limitedHistory
});




}
/// @nodoc
class __$RatingSummaryDtoCopyWithImpl<$Res>
    implements _$RatingSummaryDtoCopyWith<$Res> {
  __$RatingSummaryDtoCopyWithImpl(this._self, this._then);

  final _RatingSummaryDto _self;
  final $Res Function(_RatingSummaryDto) _then;

/// Create a copy of RatingSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? average = null,Object? count = null,Object? distribution = null,Object? limitedHistory = null,}) {
  return _then(_RatingSummaryDto(
average: null == average ? _self.average : average // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,distribution: null == distribution ? _self._distribution : distribution // ignore: cast_nullable_to_non_nullable
as Map<String, int>,limitedHistory: null == limitedHistory ? _self.limitedHistory : limitedHistory // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$OfferTermsDto {

 String get offeredPrice; String? get makingCharges; String? get ratePerGram; String? get deliveryTimeframe; String? get warrantyTerms; String? get vendorNote; int get validityHours;
/// Create a copy of OfferTermsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferTermsDtoCopyWith<OfferTermsDto> get copyWith => _$OfferTermsDtoCopyWithImpl<OfferTermsDto>(this as OfferTermsDto, _$identity);

  /// Serializes this OfferTermsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferTermsDto&&(identical(other.offeredPrice, offeredPrice) || other.offeredPrice == offeredPrice)&&(identical(other.makingCharges, makingCharges) || other.makingCharges == makingCharges)&&(identical(other.ratePerGram, ratePerGram) || other.ratePerGram == ratePerGram)&&(identical(other.deliveryTimeframe, deliveryTimeframe) || other.deliveryTimeframe == deliveryTimeframe)&&(identical(other.warrantyTerms, warrantyTerms) || other.warrantyTerms == warrantyTerms)&&(identical(other.vendorNote, vendorNote) || other.vendorNote == vendorNote)&&(identical(other.validityHours, validityHours) || other.validityHours == validityHours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,offeredPrice,makingCharges,ratePerGram,deliveryTimeframe,warrantyTerms,vendorNote,validityHours);

@override
String toString() {
  return 'OfferTermsDto(offeredPrice: $offeredPrice, makingCharges: $makingCharges, ratePerGram: $ratePerGram, deliveryTimeframe: $deliveryTimeframe, warrantyTerms: $warrantyTerms, vendorNote: $vendorNote, validityHours: $validityHours)';
}


}

/// @nodoc
abstract mixin class $OfferTermsDtoCopyWith<$Res>  {
  factory $OfferTermsDtoCopyWith(OfferTermsDto value, $Res Function(OfferTermsDto) _then) = _$OfferTermsDtoCopyWithImpl;
@useResult
$Res call({
 String offeredPrice, String? makingCharges, String? ratePerGram, String? deliveryTimeframe, String? warrantyTerms, String? vendorNote, int validityHours
});




}
/// @nodoc
class _$OfferTermsDtoCopyWithImpl<$Res>
    implements $OfferTermsDtoCopyWith<$Res> {
  _$OfferTermsDtoCopyWithImpl(this._self, this._then);

  final OfferTermsDto _self;
  final $Res Function(OfferTermsDto) _then;

/// Create a copy of OfferTermsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? offeredPrice = null,Object? makingCharges = freezed,Object? ratePerGram = freezed,Object? deliveryTimeframe = freezed,Object? warrantyTerms = freezed,Object? vendorNote = freezed,Object? validityHours = null,}) {
  return _then(_self.copyWith(
offeredPrice: null == offeredPrice ? _self.offeredPrice : offeredPrice // ignore: cast_nullable_to_non_nullable
as String,makingCharges: freezed == makingCharges ? _self.makingCharges : makingCharges // ignore: cast_nullable_to_non_nullable
as String?,ratePerGram: freezed == ratePerGram ? _self.ratePerGram : ratePerGram // ignore: cast_nullable_to_non_nullable
as String?,deliveryTimeframe: freezed == deliveryTimeframe ? _self.deliveryTimeframe : deliveryTimeframe // ignore: cast_nullable_to_non_nullable
as String?,warrantyTerms: freezed == warrantyTerms ? _self.warrantyTerms : warrantyTerms // ignore: cast_nullable_to_non_nullable
as String?,vendorNote: freezed == vendorNote ? _self.vendorNote : vendorNote // ignore: cast_nullable_to_non_nullable
as String?,validityHours: null == validityHours ? _self.validityHours : validityHours // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OfferTermsDto].
extension OfferTermsDtoPatterns on OfferTermsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferTermsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferTermsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferTermsDto value)  $default,){
final _that = this;
switch (_that) {
case _OfferTermsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferTermsDto value)?  $default,){
final _that = this;
switch (_that) {
case _OfferTermsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String offeredPrice,  String? makingCharges,  String? ratePerGram,  String? deliveryTimeframe,  String? warrantyTerms,  String? vendorNote,  int validityHours)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferTermsDto() when $default != null:
return $default(_that.offeredPrice,_that.makingCharges,_that.ratePerGram,_that.deliveryTimeframe,_that.warrantyTerms,_that.vendorNote,_that.validityHours);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String offeredPrice,  String? makingCharges,  String? ratePerGram,  String? deliveryTimeframe,  String? warrantyTerms,  String? vendorNote,  int validityHours)  $default,) {final _that = this;
switch (_that) {
case _OfferTermsDto():
return $default(_that.offeredPrice,_that.makingCharges,_that.ratePerGram,_that.deliveryTimeframe,_that.warrantyTerms,_that.vendorNote,_that.validityHours);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String offeredPrice,  String? makingCharges,  String? ratePerGram,  String? deliveryTimeframe,  String? warrantyTerms,  String? vendorNote,  int validityHours)?  $default,) {final _that = this;
switch (_that) {
case _OfferTermsDto() when $default != null:
return $default(_that.offeredPrice,_that.makingCharges,_that.ratePerGram,_that.deliveryTimeframe,_that.warrantyTerms,_that.vendorNote,_that.validityHours);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfferTermsDto implements OfferTermsDto {
  const _OfferTermsDto({required this.offeredPrice, this.makingCharges, this.ratePerGram, this.deliveryTimeframe, this.warrantyTerms, this.vendorNote, required this.validityHours});
  factory _OfferTermsDto.fromJson(Map<String, dynamic> json) => _$OfferTermsDtoFromJson(json);

@override final  String offeredPrice;
@override final  String? makingCharges;
@override final  String? ratePerGram;
@override final  String? deliveryTimeframe;
@override final  String? warrantyTerms;
@override final  String? vendorNote;
@override final  int validityHours;

/// Create a copy of OfferTermsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferTermsDtoCopyWith<_OfferTermsDto> get copyWith => __$OfferTermsDtoCopyWithImpl<_OfferTermsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferTermsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferTermsDto&&(identical(other.offeredPrice, offeredPrice) || other.offeredPrice == offeredPrice)&&(identical(other.makingCharges, makingCharges) || other.makingCharges == makingCharges)&&(identical(other.ratePerGram, ratePerGram) || other.ratePerGram == ratePerGram)&&(identical(other.deliveryTimeframe, deliveryTimeframe) || other.deliveryTimeframe == deliveryTimeframe)&&(identical(other.warrantyTerms, warrantyTerms) || other.warrantyTerms == warrantyTerms)&&(identical(other.vendorNote, vendorNote) || other.vendorNote == vendorNote)&&(identical(other.validityHours, validityHours) || other.validityHours == validityHours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,offeredPrice,makingCharges,ratePerGram,deliveryTimeframe,warrantyTerms,vendorNote,validityHours);

@override
String toString() {
  return 'OfferTermsDto(offeredPrice: $offeredPrice, makingCharges: $makingCharges, ratePerGram: $ratePerGram, deliveryTimeframe: $deliveryTimeframe, warrantyTerms: $warrantyTerms, vendorNote: $vendorNote, validityHours: $validityHours)';
}


}

/// @nodoc
abstract mixin class _$OfferTermsDtoCopyWith<$Res> implements $OfferTermsDtoCopyWith<$Res> {
  factory _$OfferTermsDtoCopyWith(_OfferTermsDto value, $Res Function(_OfferTermsDto) _then) = __$OfferTermsDtoCopyWithImpl;
@override @useResult
$Res call({
 String offeredPrice, String? makingCharges, String? ratePerGram, String? deliveryTimeframe, String? warrantyTerms, String? vendorNote, int validityHours
});




}
/// @nodoc
class __$OfferTermsDtoCopyWithImpl<$Res>
    implements _$OfferTermsDtoCopyWith<$Res> {
  __$OfferTermsDtoCopyWithImpl(this._self, this._then);

  final _OfferTermsDto _self;
  final $Res Function(_OfferTermsDto) _then;

/// Create a copy of OfferTermsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? offeredPrice = null,Object? makingCharges = freezed,Object? ratePerGram = freezed,Object? deliveryTimeframe = freezed,Object? warrantyTerms = freezed,Object? vendorNote = freezed,Object? validityHours = null,}) {
  return _then(_OfferTermsDto(
offeredPrice: null == offeredPrice ? _self.offeredPrice : offeredPrice // ignore: cast_nullable_to_non_nullable
as String,makingCharges: freezed == makingCharges ? _self.makingCharges : makingCharges // ignore: cast_nullable_to_non_nullable
as String?,ratePerGram: freezed == ratePerGram ? _self.ratePerGram : ratePerGram // ignore: cast_nullable_to_non_nullable
as String?,deliveryTimeframe: freezed == deliveryTimeframe ? _self.deliveryTimeframe : deliveryTimeframe // ignore: cast_nullable_to_non_nullable
as String?,warrantyTerms: freezed == warrantyTerms ? _self.warrantyTerms : warrantyTerms // ignore: cast_nullable_to_non_nullable
as String?,vendorNote: freezed == vendorNote ? _self.vendorNote : vendorNote // ignore: cast_nullable_to_non_nullable
as String?,validityHours: null == validityHours ? _self.validityHours : validityHours // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$MediaRefDto {

 String get id; String get key; int get displayOrder; String? get state; String? get purpose; String? get contentType; int? get byteSize;
/// Create a copy of MediaRefDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaRefDtoCopyWith<MediaRefDto> get copyWith => _$MediaRefDtoCopyWithImpl<MediaRefDto>(this as MediaRefDto, _$identity);

  /// Serializes this MediaRefDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaRefDto&&(identical(other.id, id) || other.id == id)&&(identical(other.key, key) || other.key == key)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.state, state) || other.state == state)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.byteSize, byteSize) || other.byteSize == byteSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,key,displayOrder,state,purpose,contentType,byteSize);

@override
String toString() {
  return 'MediaRefDto(id: $id, key: $key, displayOrder: $displayOrder, state: $state, purpose: $purpose, contentType: $contentType, byteSize: $byteSize)';
}


}

/// @nodoc
abstract mixin class $MediaRefDtoCopyWith<$Res>  {
  factory $MediaRefDtoCopyWith(MediaRefDto value, $Res Function(MediaRefDto) _then) = _$MediaRefDtoCopyWithImpl;
@useResult
$Res call({
 String id, String key, int displayOrder, String? state, String? purpose, String? contentType, int? byteSize
});




}
/// @nodoc
class _$MediaRefDtoCopyWithImpl<$Res>
    implements $MediaRefDtoCopyWith<$Res> {
  _$MediaRefDtoCopyWithImpl(this._self, this._then);

  final MediaRefDto _self;
  final $Res Function(MediaRefDto) _then;

/// Create a copy of MediaRefDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? key = null,Object? displayOrder = null,Object? state = freezed,Object? purpose = freezed,Object? contentType = freezed,Object? byteSize = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,purpose: freezed == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,byteSize: freezed == byteSize ? _self.byteSize : byteSize // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaRefDto].
extension MediaRefDtoPatterns on MediaRefDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaRefDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaRefDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaRefDto value)  $default,){
final _that = this;
switch (_that) {
case _MediaRefDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaRefDto value)?  $default,){
final _that = this;
switch (_that) {
case _MediaRefDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String key,  int displayOrder,  String? state,  String? purpose,  String? contentType,  int? byteSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaRefDto() when $default != null:
return $default(_that.id,_that.key,_that.displayOrder,_that.state,_that.purpose,_that.contentType,_that.byteSize);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String key,  int displayOrder,  String? state,  String? purpose,  String? contentType,  int? byteSize)  $default,) {final _that = this;
switch (_that) {
case _MediaRefDto():
return $default(_that.id,_that.key,_that.displayOrder,_that.state,_that.purpose,_that.contentType,_that.byteSize);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String key,  int displayOrder,  String? state,  String? purpose,  String? contentType,  int? byteSize)?  $default,) {final _that = this;
switch (_that) {
case _MediaRefDto() when $default != null:
return $default(_that.id,_that.key,_that.displayOrder,_that.state,_that.purpose,_that.contentType,_that.byteSize);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MediaRefDto implements MediaRefDto {
  const _MediaRefDto({required this.id, required this.key, required this.displayOrder, this.state, this.purpose, this.contentType, this.byteSize});
  factory _MediaRefDto.fromJson(Map<String, dynamic> json) => _$MediaRefDtoFromJson(json);

@override final  String id;
@override final  String key;
@override final  int displayOrder;
@override final  String? state;
@override final  String? purpose;
@override final  String? contentType;
@override final  int? byteSize;

/// Create a copy of MediaRefDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaRefDtoCopyWith<_MediaRefDto> get copyWith => __$MediaRefDtoCopyWithImpl<_MediaRefDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaRefDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaRefDto&&(identical(other.id, id) || other.id == id)&&(identical(other.key, key) || other.key == key)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.state, state) || other.state == state)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.byteSize, byteSize) || other.byteSize == byteSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,key,displayOrder,state,purpose,contentType,byteSize);

@override
String toString() {
  return 'MediaRefDto(id: $id, key: $key, displayOrder: $displayOrder, state: $state, purpose: $purpose, contentType: $contentType, byteSize: $byteSize)';
}


}

/// @nodoc
abstract mixin class _$MediaRefDtoCopyWith<$Res> implements $MediaRefDtoCopyWith<$Res> {
  factory _$MediaRefDtoCopyWith(_MediaRefDto value, $Res Function(_MediaRefDto) _then) = __$MediaRefDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String key, int displayOrder, String? state, String? purpose, String? contentType, int? byteSize
});




}
/// @nodoc
class __$MediaRefDtoCopyWithImpl<$Res>
    implements _$MediaRefDtoCopyWith<$Res> {
  __$MediaRefDtoCopyWithImpl(this._self, this._then);

  final _MediaRefDto _self;
  final $Res Function(_MediaRefDto) _then;

/// Create a copy of MediaRefDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? key = null,Object? displayOrder = null,Object? state = freezed,Object? purpose = freezed,Object? contentType = freezed,Object? byteSize = freezed,}) {
  return _then(_MediaRefDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,purpose: freezed == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,byteSize: freezed == byteSize ? _self.byteSize : byteSize // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
