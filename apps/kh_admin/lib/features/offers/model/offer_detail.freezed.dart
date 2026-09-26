// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offer_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OfferParentRequestSummary {

 String get id; String? get reference;@JsonKey(unknownEnumValue: RequestType.findOrnament) RequestType? get requestType;@_PartyConverter() Party? get customer; String? get regionName; double? get indicativeValue; String? get notes;
/// Create a copy of OfferParentRequestSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferParentRequestSummaryCopyWith<OfferParentRequestSummary> get copyWith => _$OfferParentRequestSummaryCopyWithImpl<OfferParentRequestSummary>(this as OfferParentRequestSummary, _$identity);

  /// Serializes this OfferParentRequestSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferParentRequestSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.regionName, regionName) || other.regionName == regionName)&&(identical(other.indicativeValue, indicativeValue) || other.indicativeValue == indicativeValue)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reference,requestType,customer,regionName,indicativeValue,notes);

@override
String toString() {
  return 'OfferParentRequestSummary(id: $id, reference: $reference, requestType: $requestType, customer: $customer, regionName: $regionName, indicativeValue: $indicativeValue, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $OfferParentRequestSummaryCopyWith<$Res>  {
  factory $OfferParentRequestSummaryCopyWith(OfferParentRequestSummary value, $Res Function(OfferParentRequestSummary) _then) = _$OfferParentRequestSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String? reference,@JsonKey(unknownEnumValue: RequestType.findOrnament) RequestType? requestType,@_PartyConverter() Party? customer, String? regionName, double? indicativeValue, String? notes
});




}
/// @nodoc
class _$OfferParentRequestSummaryCopyWithImpl<$Res>
    implements $OfferParentRequestSummaryCopyWith<$Res> {
  _$OfferParentRequestSummaryCopyWithImpl(this._self, this._then);

  final OfferParentRequestSummary _self;
  final $Res Function(OfferParentRequestSummary) _then;

/// Create a copy of OfferParentRequestSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reference = freezed,Object? requestType = freezed,Object? customer = freezed,Object? regionName = freezed,Object? indicativeValue = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,requestType: freezed == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as RequestType?,customer: freezed == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as Party?,regionName: freezed == regionName ? _self.regionName : regionName // ignore: cast_nullable_to_non_nullable
as String?,indicativeValue: freezed == indicativeValue ? _self.indicativeValue : indicativeValue // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OfferParentRequestSummary].
extension OfferParentRequestSummaryPatterns on OfferParentRequestSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferParentRequestSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferParentRequestSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferParentRequestSummary value)  $default,){
final _that = this;
switch (_that) {
case _OfferParentRequestSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferParentRequestSummary value)?  $default,){
final _that = this;
switch (_that) {
case _OfferParentRequestSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? reference, @JsonKey(unknownEnumValue: RequestType.findOrnament)  RequestType? requestType, @_PartyConverter()  Party? customer,  String? regionName,  double? indicativeValue,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferParentRequestSummary() when $default != null:
return $default(_that.id,_that.reference,_that.requestType,_that.customer,_that.regionName,_that.indicativeValue,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? reference, @JsonKey(unknownEnumValue: RequestType.findOrnament)  RequestType? requestType, @_PartyConverter()  Party? customer,  String? regionName,  double? indicativeValue,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _OfferParentRequestSummary():
return $default(_that.id,_that.reference,_that.requestType,_that.customer,_that.regionName,_that.indicativeValue,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? reference, @JsonKey(unknownEnumValue: RequestType.findOrnament)  RequestType? requestType, @_PartyConverter()  Party? customer,  String? regionName,  double? indicativeValue,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _OfferParentRequestSummary() when $default != null:
return $default(_that.id,_that.reference,_that.requestType,_that.customer,_that.regionName,_that.indicativeValue,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfferParentRequestSummary implements OfferParentRequestSummary {
  const _OfferParentRequestSummary({required this.id, this.reference, @JsonKey(unknownEnumValue: RequestType.findOrnament) this.requestType, @_PartyConverter() this.customer, this.regionName, this.indicativeValue, this.notes});
  factory _OfferParentRequestSummary.fromJson(Map<String, dynamic> json) => _$OfferParentRequestSummaryFromJson(json);

@override final  String id;
@override final  String? reference;
@override@JsonKey(unknownEnumValue: RequestType.findOrnament) final  RequestType? requestType;
@override@_PartyConverter() final  Party? customer;
@override final  String? regionName;
@override final  double? indicativeValue;
@override final  String? notes;

/// Create a copy of OfferParentRequestSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferParentRequestSummaryCopyWith<_OfferParentRequestSummary> get copyWith => __$OfferParentRequestSummaryCopyWithImpl<_OfferParentRequestSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferParentRequestSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferParentRequestSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.regionName, regionName) || other.regionName == regionName)&&(identical(other.indicativeValue, indicativeValue) || other.indicativeValue == indicativeValue)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reference,requestType,customer,regionName,indicativeValue,notes);

@override
String toString() {
  return 'OfferParentRequestSummary(id: $id, reference: $reference, requestType: $requestType, customer: $customer, regionName: $regionName, indicativeValue: $indicativeValue, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$OfferParentRequestSummaryCopyWith<$Res> implements $OfferParentRequestSummaryCopyWith<$Res> {
  factory _$OfferParentRequestSummaryCopyWith(_OfferParentRequestSummary value, $Res Function(_OfferParentRequestSummary) _then) = __$OfferParentRequestSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String? reference,@JsonKey(unknownEnumValue: RequestType.findOrnament) RequestType? requestType,@_PartyConverter() Party? customer, String? regionName, double? indicativeValue, String? notes
});




}
/// @nodoc
class __$OfferParentRequestSummaryCopyWithImpl<$Res>
    implements _$OfferParentRequestSummaryCopyWith<$Res> {
  __$OfferParentRequestSummaryCopyWithImpl(this._self, this._then);

  final _OfferParentRequestSummary _self;
  final $Res Function(_OfferParentRequestSummary) _then;

/// Create a copy of OfferParentRequestSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reference = freezed,Object? requestType = freezed,Object? customer = freezed,Object? regionName = freezed,Object? indicativeValue = freezed,Object? notes = freezed,}) {
  return _then(_OfferParentRequestSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,requestType: freezed == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as RequestType?,customer: freezed == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as Party?,regionName: freezed == regionName ? _self.regionName : regionName // ignore: cast_nullable_to_non_nullable
as String?,indicativeValue: freezed == indicativeValue ? _self.indicativeValue : indicativeValue // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$OfferVendorSummary {

 String get id; String get legalBusinessName; String? get tradingName; String? get tradeLicenceNumber; String? get contactPersonName; String? get mobileNumber; String? get email; double? get rating; int? get completedDeals;
/// Create a copy of OfferVendorSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferVendorSummaryCopyWith<OfferVendorSummary> get copyWith => _$OfferVendorSummaryCopyWithImpl<OfferVendorSummary>(this as OfferVendorSummary, _$identity);

  /// Serializes this OfferVendorSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferVendorSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.legalBusinessName, legalBusinessName) || other.legalBusinessName == legalBusinessName)&&(identical(other.tradingName, tradingName) || other.tradingName == tradingName)&&(identical(other.tradeLicenceNumber, tradeLicenceNumber) || other.tradeLicenceNumber == tradeLicenceNumber)&&(identical(other.contactPersonName, contactPersonName) || other.contactPersonName == contactPersonName)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.completedDeals, completedDeals) || other.completedDeals == completedDeals));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,legalBusinessName,tradingName,tradeLicenceNumber,contactPersonName,mobileNumber,email,rating,completedDeals);

@override
String toString() {
  return 'OfferVendorSummary(id: $id, legalBusinessName: $legalBusinessName, tradingName: $tradingName, tradeLicenceNumber: $tradeLicenceNumber, contactPersonName: $contactPersonName, mobileNumber: $mobileNumber, email: $email, rating: $rating, completedDeals: $completedDeals)';
}


}

/// @nodoc
abstract mixin class $OfferVendorSummaryCopyWith<$Res>  {
  factory $OfferVendorSummaryCopyWith(OfferVendorSummary value, $Res Function(OfferVendorSummary) _then) = _$OfferVendorSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String legalBusinessName, String? tradingName, String? tradeLicenceNumber, String? contactPersonName, String? mobileNumber, String? email, double? rating, int? completedDeals
});




}
/// @nodoc
class _$OfferVendorSummaryCopyWithImpl<$Res>
    implements $OfferVendorSummaryCopyWith<$Res> {
  _$OfferVendorSummaryCopyWithImpl(this._self, this._then);

  final OfferVendorSummary _self;
  final $Res Function(OfferVendorSummary) _then;

/// Create a copy of OfferVendorSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? legalBusinessName = null,Object? tradingName = freezed,Object? tradeLicenceNumber = freezed,Object? contactPersonName = freezed,Object? mobileNumber = freezed,Object? email = freezed,Object? rating = freezed,Object? completedDeals = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,legalBusinessName: null == legalBusinessName ? _self.legalBusinessName : legalBusinessName // ignore: cast_nullable_to_non_nullable
as String,tradingName: freezed == tradingName ? _self.tradingName : tradingName // ignore: cast_nullable_to_non_nullable
as String?,tradeLicenceNumber: freezed == tradeLicenceNumber ? _self.tradeLicenceNumber : tradeLicenceNumber // ignore: cast_nullable_to_non_nullable
as String?,contactPersonName: freezed == contactPersonName ? _self.contactPersonName : contactPersonName // ignore: cast_nullable_to_non_nullable
as String?,mobileNumber: freezed == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,completedDeals: freezed == completedDeals ? _self.completedDeals : completedDeals // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [OfferVendorSummary].
extension OfferVendorSummaryPatterns on OfferVendorSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferVendorSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferVendorSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferVendorSummary value)  $default,){
final _that = this;
switch (_that) {
case _OfferVendorSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferVendorSummary value)?  $default,){
final _that = this;
switch (_that) {
case _OfferVendorSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String legalBusinessName,  String? tradingName,  String? tradeLicenceNumber,  String? contactPersonName,  String? mobileNumber,  String? email,  double? rating,  int? completedDeals)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferVendorSummary() when $default != null:
return $default(_that.id,_that.legalBusinessName,_that.tradingName,_that.tradeLicenceNumber,_that.contactPersonName,_that.mobileNumber,_that.email,_that.rating,_that.completedDeals);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String legalBusinessName,  String? tradingName,  String? tradeLicenceNumber,  String? contactPersonName,  String? mobileNumber,  String? email,  double? rating,  int? completedDeals)  $default,) {final _that = this;
switch (_that) {
case _OfferVendorSummary():
return $default(_that.id,_that.legalBusinessName,_that.tradingName,_that.tradeLicenceNumber,_that.contactPersonName,_that.mobileNumber,_that.email,_that.rating,_that.completedDeals);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String legalBusinessName,  String? tradingName,  String? tradeLicenceNumber,  String? contactPersonName,  String? mobileNumber,  String? email,  double? rating,  int? completedDeals)?  $default,) {final _that = this;
switch (_that) {
case _OfferVendorSummary() when $default != null:
return $default(_that.id,_that.legalBusinessName,_that.tradingName,_that.tradeLicenceNumber,_that.contactPersonName,_that.mobileNumber,_that.email,_that.rating,_that.completedDeals);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfferVendorSummary implements OfferVendorSummary {
  const _OfferVendorSummary({required this.id, required this.legalBusinessName, this.tradingName, this.tradeLicenceNumber, this.contactPersonName, this.mobileNumber, this.email, this.rating, this.completedDeals});
  factory _OfferVendorSummary.fromJson(Map<String, dynamic> json) => _$OfferVendorSummaryFromJson(json);

@override final  String id;
@override final  String legalBusinessName;
@override final  String? tradingName;
@override final  String? tradeLicenceNumber;
@override final  String? contactPersonName;
@override final  String? mobileNumber;
@override final  String? email;
@override final  double? rating;
@override final  int? completedDeals;

/// Create a copy of OfferVendorSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferVendorSummaryCopyWith<_OfferVendorSummary> get copyWith => __$OfferVendorSummaryCopyWithImpl<_OfferVendorSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferVendorSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferVendorSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.legalBusinessName, legalBusinessName) || other.legalBusinessName == legalBusinessName)&&(identical(other.tradingName, tradingName) || other.tradingName == tradingName)&&(identical(other.tradeLicenceNumber, tradeLicenceNumber) || other.tradeLicenceNumber == tradeLicenceNumber)&&(identical(other.contactPersonName, contactPersonName) || other.contactPersonName == contactPersonName)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.completedDeals, completedDeals) || other.completedDeals == completedDeals));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,legalBusinessName,tradingName,tradeLicenceNumber,contactPersonName,mobileNumber,email,rating,completedDeals);

@override
String toString() {
  return 'OfferVendorSummary(id: $id, legalBusinessName: $legalBusinessName, tradingName: $tradingName, tradeLicenceNumber: $tradeLicenceNumber, contactPersonName: $contactPersonName, mobileNumber: $mobileNumber, email: $email, rating: $rating, completedDeals: $completedDeals)';
}


}

/// @nodoc
abstract mixin class _$OfferVendorSummaryCopyWith<$Res> implements $OfferVendorSummaryCopyWith<$Res> {
  factory _$OfferVendorSummaryCopyWith(_OfferVendorSummary value, $Res Function(_OfferVendorSummary) _then) = __$OfferVendorSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String legalBusinessName, String? tradingName, String? tradeLicenceNumber, String? contactPersonName, String? mobileNumber, String? email, double? rating, int? completedDeals
});




}
/// @nodoc
class __$OfferVendorSummaryCopyWithImpl<$Res>
    implements _$OfferVendorSummaryCopyWith<$Res> {
  __$OfferVendorSummaryCopyWithImpl(this._self, this._then);

  final _OfferVendorSummary _self;
  final $Res Function(_OfferVendorSummary) _then;

/// Create a copy of OfferVendorSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? legalBusinessName = null,Object? tradingName = freezed,Object? tradeLicenceNumber = freezed,Object? contactPersonName = freezed,Object? mobileNumber = freezed,Object? email = freezed,Object? rating = freezed,Object? completedDeals = freezed,}) {
  return _then(_OfferVendorSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,legalBusinessName: null == legalBusinessName ? _self.legalBusinessName : legalBusinessName // ignore: cast_nullable_to_non_nullable
as String,tradingName: freezed == tradingName ? _self.tradingName : tradingName // ignore: cast_nullable_to_non_nullable
as String?,tradeLicenceNumber: freezed == tradeLicenceNumber ? _self.tradeLicenceNumber : tradeLicenceNumber // ignore: cast_nullable_to_non_nullable
as String?,contactPersonName: freezed == contactPersonName ? _self.contactPersonName : contactPersonName // ignore: cast_nullable_to_non_nullable
as String?,mobileNumber: freezed == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,completedDeals: freezed == completedDeals ? _self.completedDeals : completedDeals // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$OfferAttachment {

 String get id; String get fileName; String? get url; String? get mimeType; int? get sizeBytes; DateTime? get uploadedAt;
/// Create a copy of OfferAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferAttachmentCopyWith<OfferAttachment> get copyWith => _$OfferAttachmentCopyWithImpl<OfferAttachment>(this as OfferAttachment, _$identity);

  /// Serializes this OfferAttachment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferAttachment&&(identical(other.id, id) || other.id == id)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.url, url) || other.url == url)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fileName,url,mimeType,sizeBytes,uploadedAt);

@override
String toString() {
  return 'OfferAttachment(id: $id, fileName: $fileName, url: $url, mimeType: $mimeType, sizeBytes: $sizeBytes, uploadedAt: $uploadedAt)';
}


}

/// @nodoc
abstract mixin class $OfferAttachmentCopyWith<$Res>  {
  factory $OfferAttachmentCopyWith(OfferAttachment value, $Res Function(OfferAttachment) _then) = _$OfferAttachmentCopyWithImpl;
@useResult
$Res call({
 String id, String fileName, String? url, String? mimeType, int? sizeBytes, DateTime? uploadedAt
});




}
/// @nodoc
class _$OfferAttachmentCopyWithImpl<$Res>
    implements $OfferAttachmentCopyWith<$Res> {
  _$OfferAttachmentCopyWithImpl(this._self, this._then);

  final OfferAttachment _self;
  final $Res Function(OfferAttachment) _then;

/// Create a copy of OfferAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fileName = null,Object? url = freezed,Object? mimeType = freezed,Object? sizeBytes = freezed,Object? uploadedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,uploadedAt: freezed == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [OfferAttachment].
extension OfferAttachmentPatterns on OfferAttachment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferAttachment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferAttachment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferAttachment value)  $default,){
final _that = this;
switch (_that) {
case _OfferAttachment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferAttachment value)?  $default,){
final _that = this;
switch (_that) {
case _OfferAttachment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fileName,  String? url,  String? mimeType,  int? sizeBytes,  DateTime? uploadedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferAttachment() when $default != null:
return $default(_that.id,_that.fileName,_that.url,_that.mimeType,_that.sizeBytes,_that.uploadedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fileName,  String? url,  String? mimeType,  int? sizeBytes,  DateTime? uploadedAt)  $default,) {final _that = this;
switch (_that) {
case _OfferAttachment():
return $default(_that.id,_that.fileName,_that.url,_that.mimeType,_that.sizeBytes,_that.uploadedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fileName,  String? url,  String? mimeType,  int? sizeBytes,  DateTime? uploadedAt)?  $default,) {final _that = this;
switch (_that) {
case _OfferAttachment() when $default != null:
return $default(_that.id,_that.fileName,_that.url,_that.mimeType,_that.sizeBytes,_that.uploadedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfferAttachment implements OfferAttachment {
  const _OfferAttachment({required this.id, required this.fileName, this.url, this.mimeType, this.sizeBytes, this.uploadedAt});
  factory _OfferAttachment.fromJson(Map<String, dynamic> json) => _$OfferAttachmentFromJson(json);

@override final  String id;
@override final  String fileName;
@override final  String? url;
@override final  String? mimeType;
@override final  int? sizeBytes;
@override final  DateTime? uploadedAt;

/// Create a copy of OfferAttachment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferAttachmentCopyWith<_OfferAttachment> get copyWith => __$OfferAttachmentCopyWithImpl<_OfferAttachment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferAttachmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferAttachment&&(identical(other.id, id) || other.id == id)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.url, url) || other.url == url)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fileName,url,mimeType,sizeBytes,uploadedAt);

@override
String toString() {
  return 'OfferAttachment(id: $id, fileName: $fileName, url: $url, mimeType: $mimeType, sizeBytes: $sizeBytes, uploadedAt: $uploadedAt)';
}


}

/// @nodoc
abstract mixin class _$OfferAttachmentCopyWith<$Res> implements $OfferAttachmentCopyWith<$Res> {
  factory _$OfferAttachmentCopyWith(_OfferAttachment value, $Res Function(_OfferAttachment) _then) = __$OfferAttachmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String fileName, String? url, String? mimeType, int? sizeBytes, DateTime? uploadedAt
});




}
/// @nodoc
class __$OfferAttachmentCopyWithImpl<$Res>
    implements _$OfferAttachmentCopyWith<$Res> {
  __$OfferAttachmentCopyWithImpl(this._self, this._then);

  final _OfferAttachment _self;
  final $Res Function(_OfferAttachment) _then;

/// Create a copy of OfferAttachment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fileName = null,Object? url = freezed,Object? mimeType = freezed,Object? sizeBytes = freezed,Object? uploadedAt = freezed,}) {
  return _then(_OfferAttachment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,uploadedAt: freezed == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$OfferRevisionItem {

 int get revisionNumber; DateTime get revisedAt; double get offeredPrice; double? get makingCharges; double? get ratePerGram; String? get deliveryTimeframe; String? get vendorNote; String? get changeSummary;
/// Create a copy of OfferRevisionItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferRevisionItemCopyWith<OfferRevisionItem> get copyWith => _$OfferRevisionItemCopyWithImpl<OfferRevisionItem>(this as OfferRevisionItem, _$identity);

  /// Serializes this OfferRevisionItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferRevisionItem&&(identical(other.revisionNumber, revisionNumber) || other.revisionNumber == revisionNumber)&&(identical(other.revisedAt, revisedAt) || other.revisedAt == revisedAt)&&(identical(other.offeredPrice, offeredPrice) || other.offeredPrice == offeredPrice)&&(identical(other.makingCharges, makingCharges) || other.makingCharges == makingCharges)&&(identical(other.ratePerGram, ratePerGram) || other.ratePerGram == ratePerGram)&&(identical(other.deliveryTimeframe, deliveryTimeframe) || other.deliveryTimeframe == deliveryTimeframe)&&(identical(other.vendorNote, vendorNote) || other.vendorNote == vendorNote)&&(identical(other.changeSummary, changeSummary) || other.changeSummary == changeSummary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,revisionNumber,revisedAt,offeredPrice,makingCharges,ratePerGram,deliveryTimeframe,vendorNote,changeSummary);

@override
String toString() {
  return 'OfferRevisionItem(revisionNumber: $revisionNumber, revisedAt: $revisedAt, offeredPrice: $offeredPrice, makingCharges: $makingCharges, ratePerGram: $ratePerGram, deliveryTimeframe: $deliveryTimeframe, vendorNote: $vendorNote, changeSummary: $changeSummary)';
}


}

/// @nodoc
abstract mixin class $OfferRevisionItemCopyWith<$Res>  {
  factory $OfferRevisionItemCopyWith(OfferRevisionItem value, $Res Function(OfferRevisionItem) _then) = _$OfferRevisionItemCopyWithImpl;
@useResult
$Res call({
 int revisionNumber, DateTime revisedAt, double offeredPrice, double? makingCharges, double? ratePerGram, String? deliveryTimeframe, String? vendorNote, String? changeSummary
});




}
/// @nodoc
class _$OfferRevisionItemCopyWithImpl<$Res>
    implements $OfferRevisionItemCopyWith<$Res> {
  _$OfferRevisionItemCopyWithImpl(this._self, this._then);

  final OfferRevisionItem _self;
  final $Res Function(OfferRevisionItem) _then;

/// Create a copy of OfferRevisionItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? revisionNumber = null,Object? revisedAt = null,Object? offeredPrice = null,Object? makingCharges = freezed,Object? ratePerGram = freezed,Object? deliveryTimeframe = freezed,Object? vendorNote = freezed,Object? changeSummary = freezed,}) {
  return _then(_self.copyWith(
revisionNumber: null == revisionNumber ? _self.revisionNumber : revisionNumber // ignore: cast_nullable_to_non_nullable
as int,revisedAt: null == revisedAt ? _self.revisedAt : revisedAt // ignore: cast_nullable_to_non_nullable
as DateTime,offeredPrice: null == offeredPrice ? _self.offeredPrice : offeredPrice // ignore: cast_nullable_to_non_nullable
as double,makingCharges: freezed == makingCharges ? _self.makingCharges : makingCharges // ignore: cast_nullable_to_non_nullable
as double?,ratePerGram: freezed == ratePerGram ? _self.ratePerGram : ratePerGram // ignore: cast_nullable_to_non_nullable
as double?,deliveryTimeframe: freezed == deliveryTimeframe ? _self.deliveryTimeframe : deliveryTimeframe // ignore: cast_nullable_to_non_nullable
as String?,vendorNote: freezed == vendorNote ? _self.vendorNote : vendorNote // ignore: cast_nullable_to_non_nullable
as String?,changeSummary: freezed == changeSummary ? _self.changeSummary : changeSummary // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OfferRevisionItem].
extension OfferRevisionItemPatterns on OfferRevisionItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferRevisionItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferRevisionItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferRevisionItem value)  $default,){
final _that = this;
switch (_that) {
case _OfferRevisionItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferRevisionItem value)?  $default,){
final _that = this;
switch (_that) {
case _OfferRevisionItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int revisionNumber,  DateTime revisedAt,  double offeredPrice,  double? makingCharges,  double? ratePerGram,  String? deliveryTimeframe,  String? vendorNote,  String? changeSummary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferRevisionItem() when $default != null:
return $default(_that.revisionNumber,_that.revisedAt,_that.offeredPrice,_that.makingCharges,_that.ratePerGram,_that.deliveryTimeframe,_that.vendorNote,_that.changeSummary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int revisionNumber,  DateTime revisedAt,  double offeredPrice,  double? makingCharges,  double? ratePerGram,  String? deliveryTimeframe,  String? vendorNote,  String? changeSummary)  $default,) {final _that = this;
switch (_that) {
case _OfferRevisionItem():
return $default(_that.revisionNumber,_that.revisedAt,_that.offeredPrice,_that.makingCharges,_that.ratePerGram,_that.deliveryTimeframe,_that.vendorNote,_that.changeSummary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int revisionNumber,  DateTime revisedAt,  double offeredPrice,  double? makingCharges,  double? ratePerGram,  String? deliveryTimeframe,  String? vendorNote,  String? changeSummary)?  $default,) {final _that = this;
switch (_that) {
case _OfferRevisionItem() when $default != null:
return $default(_that.revisionNumber,_that.revisedAt,_that.offeredPrice,_that.makingCharges,_that.ratePerGram,_that.deliveryTimeframe,_that.vendorNote,_that.changeSummary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfferRevisionItem implements OfferRevisionItem {
  const _OfferRevisionItem({required this.revisionNumber, required this.revisedAt, required this.offeredPrice, this.makingCharges, this.ratePerGram, this.deliveryTimeframe, this.vendorNote, this.changeSummary});
  factory _OfferRevisionItem.fromJson(Map<String, dynamic> json) => _$OfferRevisionItemFromJson(json);

@override final  int revisionNumber;
@override final  DateTime revisedAt;
@override final  double offeredPrice;
@override final  double? makingCharges;
@override final  double? ratePerGram;
@override final  String? deliveryTimeframe;
@override final  String? vendorNote;
@override final  String? changeSummary;

/// Create a copy of OfferRevisionItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferRevisionItemCopyWith<_OfferRevisionItem> get copyWith => __$OfferRevisionItemCopyWithImpl<_OfferRevisionItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferRevisionItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferRevisionItem&&(identical(other.revisionNumber, revisionNumber) || other.revisionNumber == revisionNumber)&&(identical(other.revisedAt, revisedAt) || other.revisedAt == revisedAt)&&(identical(other.offeredPrice, offeredPrice) || other.offeredPrice == offeredPrice)&&(identical(other.makingCharges, makingCharges) || other.makingCharges == makingCharges)&&(identical(other.ratePerGram, ratePerGram) || other.ratePerGram == ratePerGram)&&(identical(other.deliveryTimeframe, deliveryTimeframe) || other.deliveryTimeframe == deliveryTimeframe)&&(identical(other.vendorNote, vendorNote) || other.vendorNote == vendorNote)&&(identical(other.changeSummary, changeSummary) || other.changeSummary == changeSummary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,revisionNumber,revisedAt,offeredPrice,makingCharges,ratePerGram,deliveryTimeframe,vendorNote,changeSummary);

@override
String toString() {
  return 'OfferRevisionItem(revisionNumber: $revisionNumber, revisedAt: $revisedAt, offeredPrice: $offeredPrice, makingCharges: $makingCharges, ratePerGram: $ratePerGram, deliveryTimeframe: $deliveryTimeframe, vendorNote: $vendorNote, changeSummary: $changeSummary)';
}


}

/// @nodoc
abstract mixin class _$OfferRevisionItemCopyWith<$Res> implements $OfferRevisionItemCopyWith<$Res> {
  factory _$OfferRevisionItemCopyWith(_OfferRevisionItem value, $Res Function(_OfferRevisionItem) _then) = __$OfferRevisionItemCopyWithImpl;
@override @useResult
$Res call({
 int revisionNumber, DateTime revisedAt, double offeredPrice, double? makingCharges, double? ratePerGram, String? deliveryTimeframe, String? vendorNote, String? changeSummary
});




}
/// @nodoc
class __$OfferRevisionItemCopyWithImpl<$Res>
    implements _$OfferRevisionItemCopyWith<$Res> {
  __$OfferRevisionItemCopyWithImpl(this._self, this._then);

  final _OfferRevisionItem _self;
  final $Res Function(_OfferRevisionItem) _then;

/// Create a copy of OfferRevisionItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? revisionNumber = null,Object? revisedAt = null,Object? offeredPrice = null,Object? makingCharges = freezed,Object? ratePerGram = freezed,Object? deliveryTimeframe = freezed,Object? vendorNote = freezed,Object? changeSummary = freezed,}) {
  return _then(_OfferRevisionItem(
revisionNumber: null == revisionNumber ? _self.revisionNumber : revisionNumber // ignore: cast_nullable_to_non_nullable
as int,revisedAt: null == revisedAt ? _self.revisedAt : revisedAt // ignore: cast_nullable_to_non_nullable
as DateTime,offeredPrice: null == offeredPrice ? _self.offeredPrice : offeredPrice // ignore: cast_nullable_to_non_nullable
as double,makingCharges: freezed == makingCharges ? _self.makingCharges : makingCharges // ignore: cast_nullable_to_non_nullable
as double?,ratePerGram: freezed == ratePerGram ? _self.ratePerGram : ratePerGram // ignore: cast_nullable_to_non_nullable
as double?,deliveryTimeframe: freezed == deliveryTimeframe ? _self.deliveryTimeframe : deliveryTimeframe // ignore: cast_nullable_to_non_nullable
as String?,vendorNote: freezed == vendorNote ? _self.vendorNote : vendorNote // ignore: cast_nullable_to_non_nullable
as String?,changeSummary: freezed == changeSummary ? _self.changeSummary : changeSummary // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$OfferStateTransitionItem {

 String? get fromState; String get toState; DateTime get transitionedAt; String? get actor; String? get reason;
/// Create a copy of OfferStateTransitionItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferStateTransitionItemCopyWith<OfferStateTransitionItem> get copyWith => _$OfferStateTransitionItemCopyWithImpl<OfferStateTransitionItem>(this as OfferStateTransitionItem, _$identity);

  /// Serializes this OfferStateTransitionItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferStateTransitionItem&&(identical(other.fromState, fromState) || other.fromState == fromState)&&(identical(other.toState, toState) || other.toState == toState)&&(identical(other.transitionedAt, transitionedAt) || other.transitionedAt == transitionedAt)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fromState,toState,transitionedAt,actor,reason);

@override
String toString() {
  return 'OfferStateTransitionItem(fromState: $fromState, toState: $toState, transitionedAt: $transitionedAt, actor: $actor, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $OfferStateTransitionItemCopyWith<$Res>  {
  factory $OfferStateTransitionItemCopyWith(OfferStateTransitionItem value, $Res Function(OfferStateTransitionItem) _then) = _$OfferStateTransitionItemCopyWithImpl;
@useResult
$Res call({
 String? fromState, String toState, DateTime transitionedAt, String? actor, String? reason
});




}
/// @nodoc
class _$OfferStateTransitionItemCopyWithImpl<$Res>
    implements $OfferStateTransitionItemCopyWith<$Res> {
  _$OfferStateTransitionItemCopyWithImpl(this._self, this._then);

  final OfferStateTransitionItem _self;
  final $Res Function(OfferStateTransitionItem) _then;

/// Create a copy of OfferStateTransitionItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fromState = freezed,Object? toState = null,Object? transitionedAt = null,Object? actor = freezed,Object? reason = freezed,}) {
  return _then(_self.copyWith(
fromState: freezed == fromState ? _self.fromState : fromState // ignore: cast_nullable_to_non_nullable
as String?,toState: null == toState ? _self.toState : toState // ignore: cast_nullable_to_non_nullable
as String,transitionedAt: null == transitionedAt ? _self.transitionedAt : transitionedAt // ignore: cast_nullable_to_non_nullable
as DateTime,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OfferStateTransitionItem].
extension OfferStateTransitionItemPatterns on OfferStateTransitionItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferStateTransitionItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferStateTransitionItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferStateTransitionItem value)  $default,){
final _that = this;
switch (_that) {
case _OfferStateTransitionItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferStateTransitionItem value)?  $default,){
final _that = this;
switch (_that) {
case _OfferStateTransitionItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? fromState,  String toState,  DateTime transitionedAt,  String? actor,  String? reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferStateTransitionItem() when $default != null:
return $default(_that.fromState,_that.toState,_that.transitionedAt,_that.actor,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? fromState,  String toState,  DateTime transitionedAt,  String? actor,  String? reason)  $default,) {final _that = this;
switch (_that) {
case _OfferStateTransitionItem():
return $default(_that.fromState,_that.toState,_that.transitionedAt,_that.actor,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? fromState,  String toState,  DateTime transitionedAt,  String? actor,  String? reason)?  $default,) {final _that = this;
switch (_that) {
case _OfferStateTransitionItem() when $default != null:
return $default(_that.fromState,_that.toState,_that.transitionedAt,_that.actor,_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfferStateTransitionItem implements OfferStateTransitionItem {
  const _OfferStateTransitionItem({this.fromState, required this.toState, required this.transitionedAt, this.actor, this.reason});
  factory _OfferStateTransitionItem.fromJson(Map<String, dynamic> json) => _$OfferStateTransitionItemFromJson(json);

@override final  String? fromState;
@override final  String toState;
@override final  DateTime transitionedAt;
@override final  String? actor;
@override final  String? reason;

/// Create a copy of OfferStateTransitionItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferStateTransitionItemCopyWith<_OfferStateTransitionItem> get copyWith => __$OfferStateTransitionItemCopyWithImpl<_OfferStateTransitionItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferStateTransitionItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferStateTransitionItem&&(identical(other.fromState, fromState) || other.fromState == fromState)&&(identical(other.toState, toState) || other.toState == toState)&&(identical(other.transitionedAt, transitionedAt) || other.transitionedAt == transitionedAt)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fromState,toState,transitionedAt,actor,reason);

@override
String toString() {
  return 'OfferStateTransitionItem(fromState: $fromState, toState: $toState, transitionedAt: $transitionedAt, actor: $actor, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$OfferStateTransitionItemCopyWith<$Res> implements $OfferStateTransitionItemCopyWith<$Res> {
  factory _$OfferStateTransitionItemCopyWith(_OfferStateTransitionItem value, $Res Function(_OfferStateTransitionItem) _then) = __$OfferStateTransitionItemCopyWithImpl;
@override @useResult
$Res call({
 String? fromState, String toState, DateTime transitionedAt, String? actor, String? reason
});




}
/// @nodoc
class __$OfferStateTransitionItemCopyWithImpl<$Res>
    implements _$OfferStateTransitionItemCopyWith<$Res> {
  __$OfferStateTransitionItemCopyWithImpl(this._self, this._then);

  final _OfferStateTransitionItem _self;
  final $Res Function(_OfferStateTransitionItem) _then;

/// Create a copy of OfferStateTransitionItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fromState = freezed,Object? toState = null,Object? transitionedAt = null,Object? actor = freezed,Object? reason = freezed,}) {
  return _then(_OfferStateTransitionItem(
fromState: freezed == fromState ? _self.fromState : fromState // ignore: cast_nullable_to_non_nullable
as String?,toState: null == toState ? _self.toState : toState // ignore: cast_nullable_to_non_nullable
as String,transitionedAt: null == transitionedAt ? _self.transitionedAt : transitionedAt // ignore: cast_nullable_to_non_nullable
as DateTime,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$OfferInternalNoteItem {

 String get id; String get author; String get text; DateTime get createdAt;
/// Create a copy of OfferInternalNoteItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferInternalNoteItemCopyWith<OfferInternalNoteItem> get copyWith => _$OfferInternalNoteItemCopyWithImpl<OfferInternalNoteItem>(this as OfferInternalNoteItem, _$identity);

  /// Serializes this OfferInternalNoteItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferInternalNoteItem&&(identical(other.id, id) || other.id == id)&&(identical(other.author, author) || other.author == author)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,author,text,createdAt);

@override
String toString() {
  return 'OfferInternalNoteItem(id: $id, author: $author, text: $text, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $OfferInternalNoteItemCopyWith<$Res>  {
  factory $OfferInternalNoteItemCopyWith(OfferInternalNoteItem value, $Res Function(OfferInternalNoteItem) _then) = _$OfferInternalNoteItemCopyWithImpl;
@useResult
$Res call({
 String id, String author, String text, DateTime createdAt
});




}
/// @nodoc
class _$OfferInternalNoteItemCopyWithImpl<$Res>
    implements $OfferInternalNoteItemCopyWith<$Res> {
  _$OfferInternalNoteItemCopyWithImpl(this._self, this._then);

  final OfferInternalNoteItem _self;
  final $Res Function(OfferInternalNoteItem) _then;

/// Create a copy of OfferInternalNoteItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? author = null,Object? text = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [OfferInternalNoteItem].
extension OfferInternalNoteItemPatterns on OfferInternalNoteItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferInternalNoteItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferInternalNoteItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferInternalNoteItem value)  $default,){
final _that = this;
switch (_that) {
case _OfferInternalNoteItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferInternalNoteItem value)?  $default,){
final _that = this;
switch (_that) {
case _OfferInternalNoteItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String author,  String text,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferInternalNoteItem() when $default != null:
return $default(_that.id,_that.author,_that.text,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String author,  String text,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _OfferInternalNoteItem():
return $default(_that.id,_that.author,_that.text,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String author,  String text,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _OfferInternalNoteItem() when $default != null:
return $default(_that.id,_that.author,_that.text,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfferInternalNoteItem implements OfferInternalNoteItem {
  const _OfferInternalNoteItem({required this.id, required this.author, required this.text, required this.createdAt});
  factory _OfferInternalNoteItem.fromJson(Map<String, dynamic> json) => _$OfferInternalNoteItemFromJson(json);

@override final  String id;
@override final  String author;
@override final  String text;
@override final  DateTime createdAt;

/// Create a copy of OfferInternalNoteItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferInternalNoteItemCopyWith<_OfferInternalNoteItem> get copyWith => __$OfferInternalNoteItemCopyWithImpl<_OfferInternalNoteItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferInternalNoteItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferInternalNoteItem&&(identical(other.id, id) || other.id == id)&&(identical(other.author, author) || other.author == author)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,author,text,createdAt);

@override
String toString() {
  return 'OfferInternalNoteItem(id: $id, author: $author, text: $text, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$OfferInternalNoteItemCopyWith<$Res> implements $OfferInternalNoteItemCopyWith<$Res> {
  factory _$OfferInternalNoteItemCopyWith(_OfferInternalNoteItem value, $Res Function(_OfferInternalNoteItem) _then) = __$OfferInternalNoteItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String author, String text, DateTime createdAt
});




}
/// @nodoc
class __$OfferInternalNoteItemCopyWithImpl<$Res>
    implements _$OfferInternalNoteItemCopyWith<$Res> {
  __$OfferInternalNoteItemCopyWithImpl(this._self, this._then);

  final _OfferInternalNoteItem _self;
  final $Res Function(_OfferInternalNoteItem) _then;

/// Create a copy of OfferInternalNoteItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? author = null,Object? text = null,Object? createdAt = null,}) {
  return _then(_OfferInternalNoteItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$OfferDetail {

 String get id; String? get reference;@JsonKey(unknownEnumValue: OfferState.pending) OfferState get state; double get offeredPrice; double? get weightGrams; String? get purityKarat; double? get makingCharges; double? get ratePerGram; double? get goldPrice; double? get vat; double? get totalAmount; String? get deliveryTimeframe; String? get warrantyTerms; String? get vendorNote; DateTime? get expiresAt; DateTime get submittedAt; DateTime? get decidedAt; String? get declineReason; int get revisionCount; String? get winningOfferId; String? get winningOfferReference; double? get winningOfferPrice; String? get winningVendorName; OfferParentRequestSummary? get parentRequest; OfferVendorSummary? get vendor; List<OfferAttachment> get attachments; List<OfferRevisionItem> get revisions; List<OfferStateTransitionItem> get stateTransitions; List<OfferInternalNoteItem> get internalNotes;
/// Create a copy of OfferDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferDetailCopyWith<OfferDetail> get copyWith => _$OfferDetailCopyWithImpl<OfferDetail>(this as OfferDetail, _$identity);

  /// Serializes this OfferDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.state, state) || other.state == state)&&(identical(other.offeredPrice, offeredPrice) || other.offeredPrice == offeredPrice)&&(identical(other.weightGrams, weightGrams) || other.weightGrams == weightGrams)&&(identical(other.purityKarat, purityKarat) || other.purityKarat == purityKarat)&&(identical(other.makingCharges, makingCharges) || other.makingCharges == makingCharges)&&(identical(other.ratePerGram, ratePerGram) || other.ratePerGram == ratePerGram)&&(identical(other.goldPrice, goldPrice) || other.goldPrice == goldPrice)&&(identical(other.vat, vat) || other.vat == vat)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.deliveryTimeframe, deliveryTimeframe) || other.deliveryTimeframe == deliveryTimeframe)&&(identical(other.warrantyTerms, warrantyTerms) || other.warrantyTerms == warrantyTerms)&&(identical(other.vendorNote, vendorNote) || other.vendorNote == vendorNote)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.declineReason, declineReason) || other.declineReason == declineReason)&&(identical(other.revisionCount, revisionCount) || other.revisionCount == revisionCount)&&(identical(other.winningOfferId, winningOfferId) || other.winningOfferId == winningOfferId)&&(identical(other.winningOfferReference, winningOfferReference) || other.winningOfferReference == winningOfferReference)&&(identical(other.winningOfferPrice, winningOfferPrice) || other.winningOfferPrice == winningOfferPrice)&&(identical(other.winningVendorName, winningVendorName) || other.winningVendorName == winningVendorName)&&(identical(other.parentRequest, parentRequest) || other.parentRequest == parentRequest)&&(identical(other.vendor, vendor) || other.vendor == vendor)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&const DeepCollectionEquality().equals(other.revisions, revisions)&&const DeepCollectionEquality().equals(other.stateTransitions, stateTransitions)&&const DeepCollectionEquality().equals(other.internalNotes, internalNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reference,state,offeredPrice,weightGrams,purityKarat,makingCharges,ratePerGram,goldPrice,vat,totalAmount,deliveryTimeframe,warrantyTerms,vendorNote,expiresAt,submittedAt,decidedAt,declineReason,revisionCount,winningOfferId,winningOfferReference,winningOfferPrice,winningVendorName,parentRequest,vendor,const DeepCollectionEquality().hash(attachments),const DeepCollectionEquality().hash(revisions),const DeepCollectionEquality().hash(stateTransitions),const DeepCollectionEquality().hash(internalNotes)]);

@override
String toString() {
  return 'OfferDetail(id: $id, reference: $reference, state: $state, offeredPrice: $offeredPrice, weightGrams: $weightGrams, purityKarat: $purityKarat, makingCharges: $makingCharges, ratePerGram: $ratePerGram, goldPrice: $goldPrice, vat: $vat, totalAmount: $totalAmount, deliveryTimeframe: $deliveryTimeframe, warrantyTerms: $warrantyTerms, vendorNote: $vendorNote, expiresAt: $expiresAt, submittedAt: $submittedAt, decidedAt: $decidedAt, declineReason: $declineReason, revisionCount: $revisionCount, winningOfferId: $winningOfferId, winningOfferReference: $winningOfferReference, winningOfferPrice: $winningOfferPrice, winningVendorName: $winningVendorName, parentRequest: $parentRequest, vendor: $vendor, attachments: $attachments, revisions: $revisions, stateTransitions: $stateTransitions, internalNotes: $internalNotes)';
}


}

/// @nodoc
abstract mixin class $OfferDetailCopyWith<$Res>  {
  factory $OfferDetailCopyWith(OfferDetail value, $Res Function(OfferDetail) _then) = _$OfferDetailCopyWithImpl;
@useResult
$Res call({
 String id, String? reference,@JsonKey(unknownEnumValue: OfferState.pending) OfferState state, double offeredPrice, double? weightGrams, String? purityKarat, double? makingCharges, double? ratePerGram, double? goldPrice, double? vat, double? totalAmount, String? deliveryTimeframe, String? warrantyTerms, String? vendorNote, DateTime? expiresAt, DateTime submittedAt, DateTime? decidedAt, String? declineReason, int revisionCount, String? winningOfferId, String? winningOfferReference, double? winningOfferPrice, String? winningVendorName, OfferParentRequestSummary? parentRequest, OfferVendorSummary? vendor, List<OfferAttachment> attachments, List<OfferRevisionItem> revisions, List<OfferStateTransitionItem> stateTransitions, List<OfferInternalNoteItem> internalNotes
});


$OfferParentRequestSummaryCopyWith<$Res>? get parentRequest;$OfferVendorSummaryCopyWith<$Res>? get vendor;

}
/// @nodoc
class _$OfferDetailCopyWithImpl<$Res>
    implements $OfferDetailCopyWith<$Res> {
  _$OfferDetailCopyWithImpl(this._self, this._then);

  final OfferDetail _self;
  final $Res Function(OfferDetail) _then;

/// Create a copy of OfferDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reference = freezed,Object? state = null,Object? offeredPrice = null,Object? weightGrams = freezed,Object? purityKarat = freezed,Object? makingCharges = freezed,Object? ratePerGram = freezed,Object? goldPrice = freezed,Object? vat = freezed,Object? totalAmount = freezed,Object? deliveryTimeframe = freezed,Object? warrantyTerms = freezed,Object? vendorNote = freezed,Object? expiresAt = freezed,Object? submittedAt = null,Object? decidedAt = freezed,Object? declineReason = freezed,Object? revisionCount = null,Object? winningOfferId = freezed,Object? winningOfferReference = freezed,Object? winningOfferPrice = freezed,Object? winningVendorName = freezed,Object? parentRequest = freezed,Object? vendor = freezed,Object? attachments = null,Object? revisions = null,Object? stateTransitions = null,Object? internalNotes = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OfferState,offeredPrice: null == offeredPrice ? _self.offeredPrice : offeredPrice // ignore: cast_nullable_to_non_nullable
as double,weightGrams: freezed == weightGrams ? _self.weightGrams : weightGrams // ignore: cast_nullable_to_non_nullable
as double?,purityKarat: freezed == purityKarat ? _self.purityKarat : purityKarat // ignore: cast_nullable_to_non_nullable
as String?,makingCharges: freezed == makingCharges ? _self.makingCharges : makingCharges // ignore: cast_nullable_to_non_nullable
as double?,ratePerGram: freezed == ratePerGram ? _self.ratePerGram : ratePerGram // ignore: cast_nullable_to_non_nullable
as double?,goldPrice: freezed == goldPrice ? _self.goldPrice : goldPrice // ignore: cast_nullable_to_non_nullable
as double?,vat: freezed == vat ? _self.vat : vat // ignore: cast_nullable_to_non_nullable
as double?,totalAmount: freezed == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double?,deliveryTimeframe: freezed == deliveryTimeframe ? _self.deliveryTimeframe : deliveryTimeframe // ignore: cast_nullable_to_non_nullable
as String?,warrantyTerms: freezed == warrantyTerms ? _self.warrantyTerms : warrantyTerms // ignore: cast_nullable_to_non_nullable
as String?,vendorNote: freezed == vendorNote ? _self.vendorNote : vendorNote // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,declineReason: freezed == declineReason ? _self.declineReason : declineReason // ignore: cast_nullable_to_non_nullable
as String?,revisionCount: null == revisionCount ? _self.revisionCount : revisionCount // ignore: cast_nullable_to_non_nullable
as int,winningOfferId: freezed == winningOfferId ? _self.winningOfferId : winningOfferId // ignore: cast_nullable_to_non_nullable
as String?,winningOfferReference: freezed == winningOfferReference ? _self.winningOfferReference : winningOfferReference // ignore: cast_nullable_to_non_nullable
as String?,winningOfferPrice: freezed == winningOfferPrice ? _self.winningOfferPrice : winningOfferPrice // ignore: cast_nullable_to_non_nullable
as double?,winningVendorName: freezed == winningVendorName ? _self.winningVendorName : winningVendorName // ignore: cast_nullable_to_non_nullable
as String?,parentRequest: freezed == parentRequest ? _self.parentRequest : parentRequest // ignore: cast_nullable_to_non_nullable
as OfferParentRequestSummary?,vendor: freezed == vendor ? _self.vendor : vendor // ignore: cast_nullable_to_non_nullable
as OfferVendorSummary?,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<OfferAttachment>,revisions: null == revisions ? _self.revisions : revisions // ignore: cast_nullable_to_non_nullable
as List<OfferRevisionItem>,stateTransitions: null == stateTransitions ? _self.stateTransitions : stateTransitions // ignore: cast_nullable_to_non_nullable
as List<OfferStateTransitionItem>,internalNotes: null == internalNotes ? _self.internalNotes : internalNotes // ignore: cast_nullable_to_non_nullable
as List<OfferInternalNoteItem>,
  ));
}
/// Create a copy of OfferDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferParentRequestSummaryCopyWith<$Res>? get parentRequest {
    if (_self.parentRequest == null) {
    return null;
  }

  return $OfferParentRequestSummaryCopyWith<$Res>(_self.parentRequest!, (value) {
    return _then(_self.copyWith(parentRequest: value));
  });
}/// Create a copy of OfferDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferVendorSummaryCopyWith<$Res>? get vendor {
    if (_self.vendor == null) {
    return null;
  }

  return $OfferVendorSummaryCopyWith<$Res>(_self.vendor!, (value) {
    return _then(_self.copyWith(vendor: value));
  });
}
}


/// Adds pattern-matching-related methods to [OfferDetail].
extension OfferDetailPatterns on OfferDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferDetail value)  $default,){
final _that = this;
switch (_that) {
case _OfferDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferDetail value)?  $default,){
final _that = this;
switch (_that) {
case _OfferDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? reference, @JsonKey(unknownEnumValue: OfferState.pending)  OfferState state,  double offeredPrice,  double? weightGrams,  String? purityKarat,  double? makingCharges,  double? ratePerGram,  double? goldPrice,  double? vat,  double? totalAmount,  String? deliveryTimeframe,  String? warrantyTerms,  String? vendorNote,  DateTime? expiresAt,  DateTime submittedAt,  DateTime? decidedAt,  String? declineReason,  int revisionCount,  String? winningOfferId,  String? winningOfferReference,  double? winningOfferPrice,  String? winningVendorName,  OfferParentRequestSummary? parentRequest,  OfferVendorSummary? vendor,  List<OfferAttachment> attachments,  List<OfferRevisionItem> revisions,  List<OfferStateTransitionItem> stateTransitions,  List<OfferInternalNoteItem> internalNotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferDetail() when $default != null:
return $default(_that.id,_that.reference,_that.state,_that.offeredPrice,_that.weightGrams,_that.purityKarat,_that.makingCharges,_that.ratePerGram,_that.goldPrice,_that.vat,_that.totalAmount,_that.deliveryTimeframe,_that.warrantyTerms,_that.vendorNote,_that.expiresAt,_that.submittedAt,_that.decidedAt,_that.declineReason,_that.revisionCount,_that.winningOfferId,_that.winningOfferReference,_that.winningOfferPrice,_that.winningVendorName,_that.parentRequest,_that.vendor,_that.attachments,_that.revisions,_that.stateTransitions,_that.internalNotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? reference, @JsonKey(unknownEnumValue: OfferState.pending)  OfferState state,  double offeredPrice,  double? weightGrams,  String? purityKarat,  double? makingCharges,  double? ratePerGram,  double? goldPrice,  double? vat,  double? totalAmount,  String? deliveryTimeframe,  String? warrantyTerms,  String? vendorNote,  DateTime? expiresAt,  DateTime submittedAt,  DateTime? decidedAt,  String? declineReason,  int revisionCount,  String? winningOfferId,  String? winningOfferReference,  double? winningOfferPrice,  String? winningVendorName,  OfferParentRequestSummary? parentRequest,  OfferVendorSummary? vendor,  List<OfferAttachment> attachments,  List<OfferRevisionItem> revisions,  List<OfferStateTransitionItem> stateTransitions,  List<OfferInternalNoteItem> internalNotes)  $default,) {final _that = this;
switch (_that) {
case _OfferDetail():
return $default(_that.id,_that.reference,_that.state,_that.offeredPrice,_that.weightGrams,_that.purityKarat,_that.makingCharges,_that.ratePerGram,_that.goldPrice,_that.vat,_that.totalAmount,_that.deliveryTimeframe,_that.warrantyTerms,_that.vendorNote,_that.expiresAt,_that.submittedAt,_that.decidedAt,_that.declineReason,_that.revisionCount,_that.winningOfferId,_that.winningOfferReference,_that.winningOfferPrice,_that.winningVendorName,_that.parentRequest,_that.vendor,_that.attachments,_that.revisions,_that.stateTransitions,_that.internalNotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? reference, @JsonKey(unknownEnumValue: OfferState.pending)  OfferState state,  double offeredPrice,  double? weightGrams,  String? purityKarat,  double? makingCharges,  double? ratePerGram,  double? goldPrice,  double? vat,  double? totalAmount,  String? deliveryTimeframe,  String? warrantyTerms,  String? vendorNote,  DateTime? expiresAt,  DateTime submittedAt,  DateTime? decidedAt,  String? declineReason,  int revisionCount,  String? winningOfferId,  String? winningOfferReference,  double? winningOfferPrice,  String? winningVendorName,  OfferParentRequestSummary? parentRequest,  OfferVendorSummary? vendor,  List<OfferAttachment> attachments,  List<OfferRevisionItem> revisions,  List<OfferStateTransitionItem> stateTransitions,  List<OfferInternalNoteItem> internalNotes)?  $default,) {final _that = this;
switch (_that) {
case _OfferDetail() when $default != null:
return $default(_that.id,_that.reference,_that.state,_that.offeredPrice,_that.weightGrams,_that.purityKarat,_that.makingCharges,_that.ratePerGram,_that.goldPrice,_that.vat,_that.totalAmount,_that.deliveryTimeframe,_that.warrantyTerms,_that.vendorNote,_that.expiresAt,_that.submittedAt,_that.decidedAt,_that.declineReason,_that.revisionCount,_that.winningOfferId,_that.winningOfferReference,_that.winningOfferPrice,_that.winningVendorName,_that.parentRequest,_that.vendor,_that.attachments,_that.revisions,_that.stateTransitions,_that.internalNotes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfferDetail extends OfferDetail {
  const _OfferDetail({required this.id, this.reference, @JsonKey(unknownEnumValue: OfferState.pending) this.state = OfferState.pending, required this.offeredPrice, this.weightGrams, this.purityKarat, this.makingCharges, this.ratePerGram, this.goldPrice, this.vat, this.totalAmount, this.deliveryTimeframe, this.warrantyTerms, this.vendorNote, this.expiresAt, required this.submittedAt, this.decidedAt, this.declineReason, this.revisionCount = 0, this.winningOfferId, this.winningOfferReference, this.winningOfferPrice, this.winningVendorName, this.parentRequest, this.vendor, final  List<OfferAttachment> attachments = const [], final  List<OfferRevisionItem> revisions = const [], final  List<OfferStateTransitionItem> stateTransitions = const [], final  List<OfferInternalNoteItem> internalNotes = const []}): _attachments = attachments,_revisions = revisions,_stateTransitions = stateTransitions,_internalNotes = internalNotes,super._();
  factory _OfferDetail.fromJson(Map<String, dynamic> json) => _$OfferDetailFromJson(json);

@override final  String id;
@override final  String? reference;
@override@JsonKey(unknownEnumValue: OfferState.pending) final  OfferState state;
@override final  double offeredPrice;
@override final  double? weightGrams;
@override final  String? purityKarat;
@override final  double? makingCharges;
@override final  double? ratePerGram;
@override final  double? goldPrice;
@override final  double? vat;
@override final  double? totalAmount;
@override final  String? deliveryTimeframe;
@override final  String? warrantyTerms;
@override final  String? vendorNote;
@override final  DateTime? expiresAt;
@override final  DateTime submittedAt;
@override final  DateTime? decidedAt;
@override final  String? declineReason;
@override@JsonKey() final  int revisionCount;
@override final  String? winningOfferId;
@override final  String? winningOfferReference;
@override final  double? winningOfferPrice;
@override final  String? winningVendorName;
@override final  OfferParentRequestSummary? parentRequest;
@override final  OfferVendorSummary? vendor;
 final  List<OfferAttachment> _attachments;
@override@JsonKey() List<OfferAttachment> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

 final  List<OfferRevisionItem> _revisions;
@override@JsonKey() List<OfferRevisionItem> get revisions {
  if (_revisions is EqualUnmodifiableListView) return _revisions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_revisions);
}

 final  List<OfferStateTransitionItem> _stateTransitions;
@override@JsonKey() List<OfferStateTransitionItem> get stateTransitions {
  if (_stateTransitions is EqualUnmodifiableListView) return _stateTransitions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stateTransitions);
}

 final  List<OfferInternalNoteItem> _internalNotes;
@override@JsonKey() List<OfferInternalNoteItem> get internalNotes {
  if (_internalNotes is EqualUnmodifiableListView) return _internalNotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_internalNotes);
}


/// Create a copy of OfferDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferDetailCopyWith<_OfferDetail> get copyWith => __$OfferDetailCopyWithImpl<_OfferDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.state, state) || other.state == state)&&(identical(other.offeredPrice, offeredPrice) || other.offeredPrice == offeredPrice)&&(identical(other.weightGrams, weightGrams) || other.weightGrams == weightGrams)&&(identical(other.purityKarat, purityKarat) || other.purityKarat == purityKarat)&&(identical(other.makingCharges, makingCharges) || other.makingCharges == makingCharges)&&(identical(other.ratePerGram, ratePerGram) || other.ratePerGram == ratePerGram)&&(identical(other.goldPrice, goldPrice) || other.goldPrice == goldPrice)&&(identical(other.vat, vat) || other.vat == vat)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.deliveryTimeframe, deliveryTimeframe) || other.deliveryTimeframe == deliveryTimeframe)&&(identical(other.warrantyTerms, warrantyTerms) || other.warrantyTerms == warrantyTerms)&&(identical(other.vendorNote, vendorNote) || other.vendorNote == vendorNote)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.declineReason, declineReason) || other.declineReason == declineReason)&&(identical(other.revisionCount, revisionCount) || other.revisionCount == revisionCount)&&(identical(other.winningOfferId, winningOfferId) || other.winningOfferId == winningOfferId)&&(identical(other.winningOfferReference, winningOfferReference) || other.winningOfferReference == winningOfferReference)&&(identical(other.winningOfferPrice, winningOfferPrice) || other.winningOfferPrice == winningOfferPrice)&&(identical(other.winningVendorName, winningVendorName) || other.winningVendorName == winningVendorName)&&(identical(other.parentRequest, parentRequest) || other.parentRequest == parentRequest)&&(identical(other.vendor, vendor) || other.vendor == vendor)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&const DeepCollectionEquality().equals(other._revisions, _revisions)&&const DeepCollectionEquality().equals(other._stateTransitions, _stateTransitions)&&const DeepCollectionEquality().equals(other._internalNotes, _internalNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reference,state,offeredPrice,weightGrams,purityKarat,makingCharges,ratePerGram,goldPrice,vat,totalAmount,deliveryTimeframe,warrantyTerms,vendorNote,expiresAt,submittedAt,decidedAt,declineReason,revisionCount,winningOfferId,winningOfferReference,winningOfferPrice,winningVendorName,parentRequest,vendor,const DeepCollectionEquality().hash(_attachments),const DeepCollectionEquality().hash(_revisions),const DeepCollectionEquality().hash(_stateTransitions),const DeepCollectionEquality().hash(_internalNotes)]);

@override
String toString() {
  return 'OfferDetail(id: $id, reference: $reference, state: $state, offeredPrice: $offeredPrice, weightGrams: $weightGrams, purityKarat: $purityKarat, makingCharges: $makingCharges, ratePerGram: $ratePerGram, goldPrice: $goldPrice, vat: $vat, totalAmount: $totalAmount, deliveryTimeframe: $deliveryTimeframe, warrantyTerms: $warrantyTerms, vendorNote: $vendorNote, expiresAt: $expiresAt, submittedAt: $submittedAt, decidedAt: $decidedAt, declineReason: $declineReason, revisionCount: $revisionCount, winningOfferId: $winningOfferId, winningOfferReference: $winningOfferReference, winningOfferPrice: $winningOfferPrice, winningVendorName: $winningVendorName, parentRequest: $parentRequest, vendor: $vendor, attachments: $attachments, revisions: $revisions, stateTransitions: $stateTransitions, internalNotes: $internalNotes)';
}


}

/// @nodoc
abstract mixin class _$OfferDetailCopyWith<$Res> implements $OfferDetailCopyWith<$Res> {
  factory _$OfferDetailCopyWith(_OfferDetail value, $Res Function(_OfferDetail) _then) = __$OfferDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String? reference,@JsonKey(unknownEnumValue: OfferState.pending) OfferState state, double offeredPrice, double? weightGrams, String? purityKarat, double? makingCharges, double? ratePerGram, double? goldPrice, double? vat, double? totalAmount, String? deliveryTimeframe, String? warrantyTerms, String? vendorNote, DateTime? expiresAt, DateTime submittedAt, DateTime? decidedAt, String? declineReason, int revisionCount, String? winningOfferId, String? winningOfferReference, double? winningOfferPrice, String? winningVendorName, OfferParentRequestSummary? parentRequest, OfferVendorSummary? vendor, List<OfferAttachment> attachments, List<OfferRevisionItem> revisions, List<OfferStateTransitionItem> stateTransitions, List<OfferInternalNoteItem> internalNotes
});


@override $OfferParentRequestSummaryCopyWith<$Res>? get parentRequest;@override $OfferVendorSummaryCopyWith<$Res>? get vendor;

}
/// @nodoc
class __$OfferDetailCopyWithImpl<$Res>
    implements _$OfferDetailCopyWith<$Res> {
  __$OfferDetailCopyWithImpl(this._self, this._then);

  final _OfferDetail _self;
  final $Res Function(_OfferDetail) _then;

/// Create a copy of OfferDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reference = freezed,Object? state = null,Object? offeredPrice = null,Object? weightGrams = freezed,Object? purityKarat = freezed,Object? makingCharges = freezed,Object? ratePerGram = freezed,Object? goldPrice = freezed,Object? vat = freezed,Object? totalAmount = freezed,Object? deliveryTimeframe = freezed,Object? warrantyTerms = freezed,Object? vendorNote = freezed,Object? expiresAt = freezed,Object? submittedAt = null,Object? decidedAt = freezed,Object? declineReason = freezed,Object? revisionCount = null,Object? winningOfferId = freezed,Object? winningOfferReference = freezed,Object? winningOfferPrice = freezed,Object? winningVendorName = freezed,Object? parentRequest = freezed,Object? vendor = freezed,Object? attachments = null,Object? revisions = null,Object? stateTransitions = null,Object? internalNotes = null,}) {
  return _then(_OfferDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OfferState,offeredPrice: null == offeredPrice ? _self.offeredPrice : offeredPrice // ignore: cast_nullable_to_non_nullable
as double,weightGrams: freezed == weightGrams ? _self.weightGrams : weightGrams // ignore: cast_nullable_to_non_nullable
as double?,purityKarat: freezed == purityKarat ? _self.purityKarat : purityKarat // ignore: cast_nullable_to_non_nullable
as String?,makingCharges: freezed == makingCharges ? _self.makingCharges : makingCharges // ignore: cast_nullable_to_non_nullable
as double?,ratePerGram: freezed == ratePerGram ? _self.ratePerGram : ratePerGram // ignore: cast_nullable_to_non_nullable
as double?,goldPrice: freezed == goldPrice ? _self.goldPrice : goldPrice // ignore: cast_nullable_to_non_nullable
as double?,vat: freezed == vat ? _self.vat : vat // ignore: cast_nullable_to_non_nullable
as double?,totalAmount: freezed == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double?,deliveryTimeframe: freezed == deliveryTimeframe ? _self.deliveryTimeframe : deliveryTimeframe // ignore: cast_nullable_to_non_nullable
as String?,warrantyTerms: freezed == warrantyTerms ? _self.warrantyTerms : warrantyTerms // ignore: cast_nullable_to_non_nullable
as String?,vendorNote: freezed == vendorNote ? _self.vendorNote : vendorNote // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,declineReason: freezed == declineReason ? _self.declineReason : declineReason // ignore: cast_nullable_to_non_nullable
as String?,revisionCount: null == revisionCount ? _self.revisionCount : revisionCount // ignore: cast_nullable_to_non_nullable
as int,winningOfferId: freezed == winningOfferId ? _self.winningOfferId : winningOfferId // ignore: cast_nullable_to_non_nullable
as String?,winningOfferReference: freezed == winningOfferReference ? _self.winningOfferReference : winningOfferReference // ignore: cast_nullable_to_non_nullable
as String?,winningOfferPrice: freezed == winningOfferPrice ? _self.winningOfferPrice : winningOfferPrice // ignore: cast_nullable_to_non_nullable
as double?,winningVendorName: freezed == winningVendorName ? _self.winningVendorName : winningVendorName // ignore: cast_nullable_to_non_nullable
as String?,parentRequest: freezed == parentRequest ? _self.parentRequest : parentRequest // ignore: cast_nullable_to_non_nullable
as OfferParentRequestSummary?,vendor: freezed == vendor ? _self.vendor : vendor // ignore: cast_nullable_to_non_nullable
as OfferVendorSummary?,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<OfferAttachment>,revisions: null == revisions ? _self._revisions : revisions // ignore: cast_nullable_to_non_nullable
as List<OfferRevisionItem>,stateTransitions: null == stateTransitions ? _self._stateTransitions : stateTransitions // ignore: cast_nullable_to_non_nullable
as List<OfferStateTransitionItem>,internalNotes: null == internalNotes ? _self._internalNotes : internalNotes // ignore: cast_nullable_to_non_nullable
as List<OfferInternalNoteItem>,
  ));
}

/// Create a copy of OfferDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferParentRequestSummaryCopyWith<$Res>? get parentRequest {
    if (_self.parentRequest == null) {
    return null;
  }

  return $OfferParentRequestSummaryCopyWith<$Res>(_self.parentRequest!, (value) {
    return _then(_self.copyWith(parentRequest: value));
  });
}/// Create a copy of OfferDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferVendorSummaryCopyWith<$Res>? get vendor {
    if (_self.vendor == null) {
    return null;
  }

  return $OfferVendorSummaryCopyWith<$Res>(_self.vendor!, (value) {
    return _then(_self.copyWith(vendor: value));
  });
}
}

// dart format on
