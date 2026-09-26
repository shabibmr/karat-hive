// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CustomerProfileSummary {

 String get id; String get fullName; String? get email; String? get mobileNumber; String get accountState; DateTime? get createdAt;
/// Create a copy of CustomerProfileSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerProfileSummaryCopyWith<CustomerProfileSummary> get copyWith => _$CustomerProfileSummaryCopyWithImpl<CustomerProfileSummary>(this as CustomerProfileSummary, _$identity);

  /// Serializes this CustomerProfileSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerProfileSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.accountState, accountState) || other.accountState == accountState)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,email,mobileNumber,accountState,createdAt);

@override
String toString() {
  return 'CustomerProfileSummary(id: $id, fullName: $fullName, email: $email, mobileNumber: $mobileNumber, accountState: $accountState, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CustomerProfileSummaryCopyWith<$Res>  {
  factory $CustomerProfileSummaryCopyWith(CustomerProfileSummary value, $Res Function(CustomerProfileSummary) _then) = _$CustomerProfileSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, String? email, String? mobileNumber, String accountState, DateTime? createdAt
});




}
/// @nodoc
class _$CustomerProfileSummaryCopyWithImpl<$Res>
    implements $CustomerProfileSummaryCopyWith<$Res> {
  _$CustomerProfileSummaryCopyWithImpl(this._self, this._then);

  final CustomerProfileSummary _self;
  final $Res Function(CustomerProfileSummary) _then;

/// Create a copy of CustomerProfileSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? email = freezed,Object? mobileNumber = freezed,Object? accountState = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,mobileNumber: freezed == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String?,accountState: null == accountState ? _self.accountState : accountState // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomerProfileSummary].
extension CustomerProfileSummaryPatterns on CustomerProfileSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerProfileSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerProfileSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerProfileSummary value)  $default,){
final _that = this;
switch (_that) {
case _CustomerProfileSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerProfileSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerProfileSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  String? email,  String? mobileNumber,  String accountState,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerProfileSummary() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.mobileNumber,_that.accountState,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  String? email,  String? mobileNumber,  String accountState,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _CustomerProfileSummary():
return $default(_that.id,_that.fullName,_that.email,_that.mobileNumber,_that.accountState,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  String? email,  String? mobileNumber,  String accountState,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CustomerProfileSummary() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.mobileNumber,_that.accountState,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomerProfileSummary implements CustomerProfileSummary {
  const _CustomerProfileSummary({required this.id, required this.fullName, this.email, this.mobileNumber, this.accountState = 'ACTIVE', this.createdAt});
  factory _CustomerProfileSummary.fromJson(Map<String, dynamic> json) => _$CustomerProfileSummaryFromJson(json);

@override final  String id;
@override final  String fullName;
@override final  String? email;
@override final  String? mobileNumber;
@override@JsonKey() final  String accountState;
@override final  DateTime? createdAt;

/// Create a copy of CustomerProfileSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerProfileSummaryCopyWith<_CustomerProfileSummary> get copyWith => __$CustomerProfileSummaryCopyWithImpl<_CustomerProfileSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomerProfileSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerProfileSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.accountState, accountState) || other.accountState == accountState)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,email,mobileNumber,accountState,createdAt);

@override
String toString() {
  return 'CustomerProfileSummary(id: $id, fullName: $fullName, email: $email, mobileNumber: $mobileNumber, accountState: $accountState, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CustomerProfileSummaryCopyWith<$Res> implements $CustomerProfileSummaryCopyWith<$Res> {
  factory _$CustomerProfileSummaryCopyWith(_CustomerProfileSummary value, $Res Function(_CustomerProfileSummary) _then) = __$CustomerProfileSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, String? email, String? mobileNumber, String accountState, DateTime? createdAt
});




}
/// @nodoc
class __$CustomerProfileSummaryCopyWithImpl<$Res>
    implements _$CustomerProfileSummaryCopyWith<$Res> {
  __$CustomerProfileSummaryCopyWithImpl(this._self, this._then);

  final _CustomerProfileSummary _self;
  final $Res Function(_CustomerProfileSummary) _then;

/// Create a copy of CustomerProfileSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? email = freezed,Object? mobileNumber = freezed,Object? accountState = null,Object? createdAt = freezed,}) {
  return _then(_CustomerProfileSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,mobileNumber: freezed == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String?,accountState: null == accountState ? _self.accountState : accountState // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$RequestMediaItem {

 String get id; String get url; String? get thumbnailUrl; String? get fileName; String? get mimeType; int? get sizeBytes; int get displayOrder;
/// Create a copy of RequestMediaItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestMediaItemCopyWith<RequestMediaItem> get copyWith => _$RequestMediaItemCopyWithImpl<RequestMediaItem>(this as RequestMediaItem, _$identity);

  /// Serializes this RequestMediaItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestMediaItem&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,thumbnailUrl,fileName,mimeType,sizeBytes,displayOrder);

@override
String toString() {
  return 'RequestMediaItem(id: $id, url: $url, thumbnailUrl: $thumbnailUrl, fileName: $fileName, mimeType: $mimeType, sizeBytes: $sizeBytes, displayOrder: $displayOrder)';
}


}

/// @nodoc
abstract mixin class $RequestMediaItemCopyWith<$Res>  {
  factory $RequestMediaItemCopyWith(RequestMediaItem value, $Res Function(RequestMediaItem) _then) = _$RequestMediaItemCopyWithImpl;
@useResult
$Res call({
 String id, String url, String? thumbnailUrl, String? fileName, String? mimeType, int? sizeBytes, int displayOrder
});




}
/// @nodoc
class _$RequestMediaItemCopyWithImpl<$Res>
    implements $RequestMediaItemCopyWith<$Res> {
  _$RequestMediaItemCopyWithImpl(this._self, this._then);

  final RequestMediaItem _self;
  final $Res Function(RequestMediaItem) _then;

/// Create a copy of RequestMediaItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? thumbnailUrl = freezed,Object? fileName = freezed,Object? mimeType = freezed,Object? sizeBytes = freezed,Object? displayOrder = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestMediaItem].
extension RequestMediaItemPatterns on RequestMediaItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestMediaItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestMediaItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestMediaItem value)  $default,){
final _that = this;
switch (_that) {
case _RequestMediaItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestMediaItem value)?  $default,){
final _that = this;
switch (_that) {
case _RequestMediaItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String url,  String? thumbnailUrl,  String? fileName,  String? mimeType,  int? sizeBytes,  int displayOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestMediaItem() when $default != null:
return $default(_that.id,_that.url,_that.thumbnailUrl,_that.fileName,_that.mimeType,_that.sizeBytes,_that.displayOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String url,  String? thumbnailUrl,  String? fileName,  String? mimeType,  int? sizeBytes,  int displayOrder)  $default,) {final _that = this;
switch (_that) {
case _RequestMediaItem():
return $default(_that.id,_that.url,_that.thumbnailUrl,_that.fileName,_that.mimeType,_that.sizeBytes,_that.displayOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String url,  String? thumbnailUrl,  String? fileName,  String? mimeType,  int? sizeBytes,  int displayOrder)?  $default,) {final _that = this;
switch (_that) {
case _RequestMediaItem() when $default != null:
return $default(_that.id,_that.url,_that.thumbnailUrl,_that.fileName,_that.mimeType,_that.sizeBytes,_that.displayOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RequestMediaItem implements RequestMediaItem {
  const _RequestMediaItem({required this.id, required this.url, this.thumbnailUrl, this.fileName, this.mimeType, this.sizeBytes, this.displayOrder = 0});
  factory _RequestMediaItem.fromJson(Map<String, dynamic> json) => _$RequestMediaItemFromJson(json);

@override final  String id;
@override final  String url;
@override final  String? thumbnailUrl;
@override final  String? fileName;
@override final  String? mimeType;
@override final  int? sizeBytes;
@override@JsonKey() final  int displayOrder;

/// Create a copy of RequestMediaItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestMediaItemCopyWith<_RequestMediaItem> get copyWith => __$RequestMediaItemCopyWithImpl<_RequestMediaItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestMediaItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestMediaItem&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,thumbnailUrl,fileName,mimeType,sizeBytes,displayOrder);

@override
String toString() {
  return 'RequestMediaItem(id: $id, url: $url, thumbnailUrl: $thumbnailUrl, fileName: $fileName, mimeType: $mimeType, sizeBytes: $sizeBytes, displayOrder: $displayOrder)';
}


}

/// @nodoc
abstract mixin class _$RequestMediaItemCopyWith<$Res> implements $RequestMediaItemCopyWith<$Res> {
  factory _$RequestMediaItemCopyWith(_RequestMediaItem value, $Res Function(_RequestMediaItem) _then) = __$RequestMediaItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String url, String? thumbnailUrl, String? fileName, String? mimeType, int? sizeBytes, int displayOrder
});




}
/// @nodoc
class __$RequestMediaItemCopyWithImpl<$Res>
    implements _$RequestMediaItemCopyWith<$Res> {
  __$RequestMediaItemCopyWithImpl(this._self, this._then);

  final _RequestMediaItem _self;
  final $Res Function(_RequestMediaItem) _then;

/// Create a copy of RequestMediaItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? thumbnailUrl = freezed,Object? fileName = freezed,Object? mimeType = freezed,Object? sizeBytes = freezed,Object? displayOrder = null,}) {
  return _then(_RequestMediaItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$MatchedVendorItem {

 String get vendorId; String get businessName; String? get tradingName; double? get rating; bool get isEligible; DateTime get matchedAt; DateTime? get viewedAt;
/// Create a copy of MatchedVendorItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchedVendorItemCopyWith<MatchedVendorItem> get copyWith => _$MatchedVendorItemCopyWithImpl<MatchedVendorItem>(this as MatchedVendorItem, _$identity);

  /// Serializes this MatchedVendorItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchedVendorItem&&(identical(other.vendorId, vendorId) || other.vendorId == vendorId)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.tradingName, tradingName) || other.tradingName == tradingName)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.isEligible, isEligible) || other.isEligible == isEligible)&&(identical(other.matchedAt, matchedAt) || other.matchedAt == matchedAt)&&(identical(other.viewedAt, viewedAt) || other.viewedAt == viewedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vendorId,businessName,tradingName,rating,isEligible,matchedAt,viewedAt);

@override
String toString() {
  return 'MatchedVendorItem(vendorId: $vendorId, businessName: $businessName, tradingName: $tradingName, rating: $rating, isEligible: $isEligible, matchedAt: $matchedAt, viewedAt: $viewedAt)';
}


}

/// @nodoc
abstract mixin class $MatchedVendorItemCopyWith<$Res>  {
  factory $MatchedVendorItemCopyWith(MatchedVendorItem value, $Res Function(MatchedVendorItem) _then) = _$MatchedVendorItemCopyWithImpl;
@useResult
$Res call({
 String vendorId, String businessName, String? tradingName, double? rating, bool isEligible, DateTime matchedAt, DateTime? viewedAt
});




}
/// @nodoc
class _$MatchedVendorItemCopyWithImpl<$Res>
    implements $MatchedVendorItemCopyWith<$Res> {
  _$MatchedVendorItemCopyWithImpl(this._self, this._then);

  final MatchedVendorItem _self;
  final $Res Function(MatchedVendorItem) _then;

/// Create a copy of MatchedVendorItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? vendorId = null,Object? businessName = null,Object? tradingName = freezed,Object? rating = freezed,Object? isEligible = null,Object? matchedAt = null,Object? viewedAt = freezed,}) {
  return _then(_self.copyWith(
vendorId: null == vendorId ? _self.vendorId : vendorId // ignore: cast_nullable_to_non_nullable
as String,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,tradingName: freezed == tradingName ? _self.tradingName : tradingName // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,isEligible: null == isEligible ? _self.isEligible : isEligible // ignore: cast_nullable_to_non_nullable
as bool,matchedAt: null == matchedAt ? _self.matchedAt : matchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,viewedAt: freezed == viewedAt ? _self.viewedAt : viewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchedVendorItem].
extension MatchedVendorItemPatterns on MatchedVendorItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchedVendorItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchedVendorItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchedVendorItem value)  $default,){
final _that = this;
switch (_that) {
case _MatchedVendorItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchedVendorItem value)?  $default,){
final _that = this;
switch (_that) {
case _MatchedVendorItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String vendorId,  String businessName,  String? tradingName,  double? rating,  bool isEligible,  DateTime matchedAt,  DateTime? viewedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchedVendorItem() when $default != null:
return $default(_that.vendorId,_that.businessName,_that.tradingName,_that.rating,_that.isEligible,_that.matchedAt,_that.viewedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String vendorId,  String businessName,  String? tradingName,  double? rating,  bool isEligible,  DateTime matchedAt,  DateTime? viewedAt)  $default,) {final _that = this;
switch (_that) {
case _MatchedVendorItem():
return $default(_that.vendorId,_that.businessName,_that.tradingName,_that.rating,_that.isEligible,_that.matchedAt,_that.viewedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String vendorId,  String businessName,  String? tradingName,  double? rating,  bool isEligible,  DateTime matchedAt,  DateTime? viewedAt)?  $default,) {final _that = this;
switch (_that) {
case _MatchedVendorItem() when $default != null:
return $default(_that.vendorId,_that.businessName,_that.tradingName,_that.rating,_that.isEligible,_that.matchedAt,_that.viewedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MatchedVendorItem implements MatchedVendorItem {
  const _MatchedVendorItem({required this.vendorId, required this.businessName, this.tradingName, this.rating, this.isEligible = true, required this.matchedAt, this.viewedAt});
  factory _MatchedVendorItem.fromJson(Map<String, dynamic> json) => _$MatchedVendorItemFromJson(json);

@override final  String vendorId;
@override final  String businessName;
@override final  String? tradingName;
@override final  double? rating;
@override@JsonKey() final  bool isEligible;
@override final  DateTime matchedAt;
@override final  DateTime? viewedAt;

/// Create a copy of MatchedVendorItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchedVendorItemCopyWith<_MatchedVendorItem> get copyWith => __$MatchedVendorItemCopyWithImpl<_MatchedVendorItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchedVendorItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchedVendorItem&&(identical(other.vendorId, vendorId) || other.vendorId == vendorId)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.tradingName, tradingName) || other.tradingName == tradingName)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.isEligible, isEligible) || other.isEligible == isEligible)&&(identical(other.matchedAt, matchedAt) || other.matchedAt == matchedAt)&&(identical(other.viewedAt, viewedAt) || other.viewedAt == viewedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vendorId,businessName,tradingName,rating,isEligible,matchedAt,viewedAt);

@override
String toString() {
  return 'MatchedVendorItem(vendorId: $vendorId, businessName: $businessName, tradingName: $tradingName, rating: $rating, isEligible: $isEligible, matchedAt: $matchedAt, viewedAt: $viewedAt)';
}


}

/// @nodoc
abstract mixin class _$MatchedVendorItemCopyWith<$Res> implements $MatchedVendorItemCopyWith<$Res> {
  factory _$MatchedVendorItemCopyWith(_MatchedVendorItem value, $Res Function(_MatchedVendorItem) _then) = __$MatchedVendorItemCopyWithImpl;
@override @useResult
$Res call({
 String vendorId, String businessName, String? tradingName, double? rating, bool isEligible, DateTime matchedAt, DateTime? viewedAt
});




}
/// @nodoc
class __$MatchedVendorItemCopyWithImpl<$Res>
    implements _$MatchedVendorItemCopyWith<$Res> {
  __$MatchedVendorItemCopyWithImpl(this._self, this._then);

  final _MatchedVendorItem _self;
  final $Res Function(_MatchedVendorItem) _then;

/// Create a copy of MatchedVendorItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vendorId = null,Object? businessName = null,Object? tradingName = freezed,Object? rating = freezed,Object? isEligible = null,Object? matchedAt = null,Object? viewedAt = freezed,}) {
  return _then(_MatchedVendorItem(
vendorId: null == vendorId ? _self.vendorId : vendorId // ignore: cast_nullable_to_non_nullable
as String,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,tradingName: freezed == tradingName ? _self.tradingName : tradingName // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,isEligible: null == isEligible ? _self.isEligible : isEligible // ignore: cast_nullable_to_non_nullable
as bool,matchedAt: null == matchedAt ? _self.matchedAt : matchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,viewedAt: freezed == viewedAt ? _self.viewedAt : viewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$RequestOfferItem {

 String get id; String get vendorId; String get vendorName; double get priceAED;@JsonKey(unknownEnumValue: OfferState.pending) OfferState get state; String? get outcome; DateTime get submittedAt; String? get notes; int? get estimatedDays;
/// Create a copy of RequestOfferItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestOfferItemCopyWith<RequestOfferItem> get copyWith => _$RequestOfferItemCopyWithImpl<RequestOfferItem>(this as RequestOfferItem, _$identity);

  /// Serializes this RequestOfferItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestOfferItem&&(identical(other.id, id) || other.id == id)&&(identical(other.vendorId, vendorId) || other.vendorId == vendorId)&&(identical(other.vendorName, vendorName) || other.vendorName == vendorName)&&(identical(other.priceAED, priceAED) || other.priceAED == priceAED)&&(identical(other.state, state) || other.state == state)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.estimatedDays, estimatedDays) || other.estimatedDays == estimatedDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,vendorId,vendorName,priceAED,state,outcome,submittedAt,notes,estimatedDays);

@override
String toString() {
  return 'RequestOfferItem(id: $id, vendorId: $vendorId, vendorName: $vendorName, priceAED: $priceAED, state: $state, outcome: $outcome, submittedAt: $submittedAt, notes: $notes, estimatedDays: $estimatedDays)';
}


}

/// @nodoc
abstract mixin class $RequestOfferItemCopyWith<$Res>  {
  factory $RequestOfferItemCopyWith(RequestOfferItem value, $Res Function(RequestOfferItem) _then) = _$RequestOfferItemCopyWithImpl;
@useResult
$Res call({
 String id, String vendorId, String vendorName, double priceAED,@JsonKey(unknownEnumValue: OfferState.pending) OfferState state, String? outcome, DateTime submittedAt, String? notes, int? estimatedDays
});




}
/// @nodoc
class _$RequestOfferItemCopyWithImpl<$Res>
    implements $RequestOfferItemCopyWith<$Res> {
  _$RequestOfferItemCopyWithImpl(this._self, this._then);

  final RequestOfferItem _self;
  final $Res Function(RequestOfferItem) _then;

/// Create a copy of RequestOfferItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? vendorId = null,Object? vendorName = null,Object? priceAED = null,Object? state = null,Object? outcome = freezed,Object? submittedAt = null,Object? notes = freezed,Object? estimatedDays = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,vendorId: null == vendorId ? _self.vendorId : vendorId // ignore: cast_nullable_to_non_nullable
as String,vendorName: null == vendorName ? _self.vendorName : vendorName // ignore: cast_nullable_to_non_nullable
as String,priceAED: null == priceAED ? _self.priceAED : priceAED // ignore: cast_nullable_to_non_nullable
as double,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OfferState,outcome: freezed == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,estimatedDays: freezed == estimatedDays ? _self.estimatedDays : estimatedDays // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestOfferItem].
extension RequestOfferItemPatterns on RequestOfferItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestOfferItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestOfferItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestOfferItem value)  $default,){
final _that = this;
switch (_that) {
case _RequestOfferItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestOfferItem value)?  $default,){
final _that = this;
switch (_that) {
case _RequestOfferItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String vendorId,  String vendorName,  double priceAED, @JsonKey(unknownEnumValue: OfferState.pending)  OfferState state,  String? outcome,  DateTime submittedAt,  String? notes,  int? estimatedDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestOfferItem() when $default != null:
return $default(_that.id,_that.vendorId,_that.vendorName,_that.priceAED,_that.state,_that.outcome,_that.submittedAt,_that.notes,_that.estimatedDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String vendorId,  String vendorName,  double priceAED, @JsonKey(unknownEnumValue: OfferState.pending)  OfferState state,  String? outcome,  DateTime submittedAt,  String? notes,  int? estimatedDays)  $default,) {final _that = this;
switch (_that) {
case _RequestOfferItem():
return $default(_that.id,_that.vendorId,_that.vendorName,_that.priceAED,_that.state,_that.outcome,_that.submittedAt,_that.notes,_that.estimatedDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String vendorId,  String vendorName,  double priceAED, @JsonKey(unknownEnumValue: OfferState.pending)  OfferState state,  String? outcome,  DateTime submittedAt,  String? notes,  int? estimatedDays)?  $default,) {final _that = this;
switch (_that) {
case _RequestOfferItem() when $default != null:
return $default(_that.id,_that.vendorId,_that.vendorName,_that.priceAED,_that.state,_that.outcome,_that.submittedAt,_that.notes,_that.estimatedDays);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RequestOfferItem implements RequestOfferItem {
  const _RequestOfferItem({required this.id, required this.vendorId, required this.vendorName, required this.priceAED, @JsonKey(unknownEnumValue: OfferState.pending) this.state = OfferState.pending, this.outcome, required this.submittedAt, this.notes, this.estimatedDays});
  factory _RequestOfferItem.fromJson(Map<String, dynamic> json) => _$RequestOfferItemFromJson(json);

@override final  String id;
@override final  String vendorId;
@override final  String vendorName;
@override final  double priceAED;
@override@JsonKey(unknownEnumValue: OfferState.pending) final  OfferState state;
@override final  String? outcome;
@override final  DateTime submittedAt;
@override final  String? notes;
@override final  int? estimatedDays;

/// Create a copy of RequestOfferItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestOfferItemCopyWith<_RequestOfferItem> get copyWith => __$RequestOfferItemCopyWithImpl<_RequestOfferItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestOfferItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestOfferItem&&(identical(other.id, id) || other.id == id)&&(identical(other.vendorId, vendorId) || other.vendorId == vendorId)&&(identical(other.vendorName, vendorName) || other.vendorName == vendorName)&&(identical(other.priceAED, priceAED) || other.priceAED == priceAED)&&(identical(other.state, state) || other.state == state)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.estimatedDays, estimatedDays) || other.estimatedDays == estimatedDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,vendorId,vendorName,priceAED,state,outcome,submittedAt,notes,estimatedDays);

@override
String toString() {
  return 'RequestOfferItem(id: $id, vendorId: $vendorId, vendorName: $vendorName, priceAED: $priceAED, state: $state, outcome: $outcome, submittedAt: $submittedAt, notes: $notes, estimatedDays: $estimatedDays)';
}


}

/// @nodoc
abstract mixin class _$RequestOfferItemCopyWith<$Res> implements $RequestOfferItemCopyWith<$Res> {
  factory _$RequestOfferItemCopyWith(_RequestOfferItem value, $Res Function(_RequestOfferItem) _then) = __$RequestOfferItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String vendorId, String vendorName, double priceAED,@JsonKey(unknownEnumValue: OfferState.pending) OfferState state, String? outcome, DateTime submittedAt, String? notes, int? estimatedDays
});




}
/// @nodoc
class __$RequestOfferItemCopyWithImpl<$Res>
    implements _$RequestOfferItemCopyWith<$Res> {
  __$RequestOfferItemCopyWithImpl(this._self, this._then);

  final _RequestOfferItem _self;
  final $Res Function(_RequestOfferItem) _then;

/// Create a copy of RequestOfferItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? vendorId = null,Object? vendorName = null,Object? priceAED = null,Object? state = null,Object? outcome = freezed,Object? submittedAt = null,Object? notes = freezed,Object? estimatedDays = freezed,}) {
  return _then(_RequestOfferItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,vendorId: null == vendorId ? _self.vendorId : vendorId // ignore: cast_nullable_to_non_nullable
as String,vendorName: null == vendorName ? _self.vendorName : vendorName // ignore: cast_nullable_to_non_nullable
as String,priceAED: null == priceAED ? _self.priceAED : priceAED // ignore: cast_nullable_to_non_nullable
as double,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as OfferState,outcome: freezed == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,estimatedDays: freezed == estimatedDays ? _self.estimatedDays : estimatedDays // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$RequestTimelineEvent {

@JsonKey(unknownEnumValue: RequestState.draft) RequestState get state; DateTime get timestamp; String? get actor; String? get notes;
/// Create a copy of RequestTimelineEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestTimelineEventCopyWith<RequestTimelineEvent> get copyWith => _$RequestTimelineEventCopyWithImpl<RequestTimelineEvent>(this as RequestTimelineEvent, _$identity);

  /// Serializes this RequestTimelineEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestTimelineEvent&&(identical(other.state, state) || other.state == state)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,state,timestamp,actor,notes);

@override
String toString() {
  return 'RequestTimelineEvent(state: $state, timestamp: $timestamp, actor: $actor, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $RequestTimelineEventCopyWith<$Res>  {
  factory $RequestTimelineEventCopyWith(RequestTimelineEvent value, $Res Function(RequestTimelineEvent) _then) = _$RequestTimelineEventCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: RequestState.draft) RequestState state, DateTime timestamp, String? actor, String? notes
});




}
/// @nodoc
class _$RequestTimelineEventCopyWithImpl<$Res>
    implements $RequestTimelineEventCopyWith<$Res> {
  _$RequestTimelineEventCopyWithImpl(this._self, this._then);

  final RequestTimelineEvent _self;
  final $Res Function(RequestTimelineEvent) _then;

/// Create a copy of RequestTimelineEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? state = null,Object? timestamp = null,Object? actor = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as RequestState,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestTimelineEvent].
extension RequestTimelineEventPatterns on RequestTimelineEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestTimelineEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestTimelineEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestTimelineEvent value)  $default,){
final _that = this;
switch (_that) {
case _RequestTimelineEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestTimelineEvent value)?  $default,){
final _that = this;
switch (_that) {
case _RequestTimelineEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: RequestState.draft)  RequestState state,  DateTime timestamp,  String? actor,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestTimelineEvent() when $default != null:
return $default(_that.state,_that.timestamp,_that.actor,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: RequestState.draft)  RequestState state,  DateTime timestamp,  String? actor,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _RequestTimelineEvent():
return $default(_that.state,_that.timestamp,_that.actor,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: RequestState.draft)  RequestState state,  DateTime timestamp,  String? actor,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _RequestTimelineEvent() when $default != null:
return $default(_that.state,_that.timestamp,_that.actor,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RequestTimelineEvent implements RequestTimelineEvent {
  const _RequestTimelineEvent({@JsonKey(unknownEnumValue: RequestState.draft) this.state = RequestState.draft, required this.timestamp, this.actor, this.notes});
  factory _RequestTimelineEvent.fromJson(Map<String, dynamic> json) => _$RequestTimelineEventFromJson(json);

@override@JsonKey(unknownEnumValue: RequestState.draft) final  RequestState state;
@override final  DateTime timestamp;
@override final  String? actor;
@override final  String? notes;

/// Create a copy of RequestTimelineEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestTimelineEventCopyWith<_RequestTimelineEvent> get copyWith => __$RequestTimelineEventCopyWithImpl<_RequestTimelineEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestTimelineEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestTimelineEvent&&(identical(other.state, state) || other.state == state)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,state,timestamp,actor,notes);

@override
String toString() {
  return 'RequestTimelineEvent(state: $state, timestamp: $timestamp, actor: $actor, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$RequestTimelineEventCopyWith<$Res> implements $RequestTimelineEventCopyWith<$Res> {
  factory _$RequestTimelineEventCopyWith(_RequestTimelineEvent value, $Res Function(_RequestTimelineEvent) _then) = __$RequestTimelineEventCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: RequestState.draft) RequestState state, DateTime timestamp, String? actor, String? notes
});




}
/// @nodoc
class __$RequestTimelineEventCopyWithImpl<$Res>
    implements _$RequestTimelineEventCopyWith<$Res> {
  __$RequestTimelineEventCopyWithImpl(this._self, this._then);

  final _RequestTimelineEvent _self;
  final $Res Function(_RequestTimelineEvent) _then;

/// Create a copy of RequestTimelineEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? state = null,Object? timestamp = null,Object? actor = freezed,Object? notes = freezed,}) {
  return _then(_RequestTimelineEvent(
state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as RequestState,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RequestConnectionSummary {

 String get id; String get vendorId; String get vendorName; String get customerId; String get customerName; String get state; DateTime get connectedAt; DateTime? get identityRevealedAt; DateTime? get closedAt; String? get whatsappUrl; String? get channel;
/// Create a copy of RequestConnectionSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestConnectionSummaryCopyWith<RequestConnectionSummary> get copyWith => _$RequestConnectionSummaryCopyWithImpl<RequestConnectionSummary>(this as RequestConnectionSummary, _$identity);

  /// Serializes this RequestConnectionSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestConnectionSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.vendorId, vendorId) || other.vendorId == vendorId)&&(identical(other.vendorName, vendorName) || other.vendorName == vendorName)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.state, state) || other.state == state)&&(identical(other.connectedAt, connectedAt) || other.connectedAt == connectedAt)&&(identical(other.identityRevealedAt, identityRevealedAt) || other.identityRevealedAt == identityRevealedAt)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&(identical(other.whatsappUrl, whatsappUrl) || other.whatsappUrl == whatsappUrl)&&(identical(other.channel, channel) || other.channel == channel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,vendorId,vendorName,customerId,customerName,state,connectedAt,identityRevealedAt,closedAt,whatsappUrl,channel);

@override
String toString() {
  return 'RequestConnectionSummary(id: $id, vendorId: $vendorId, vendorName: $vendorName, customerId: $customerId, customerName: $customerName, state: $state, connectedAt: $connectedAt, identityRevealedAt: $identityRevealedAt, closedAt: $closedAt, whatsappUrl: $whatsappUrl, channel: $channel)';
}


}

/// @nodoc
abstract mixin class $RequestConnectionSummaryCopyWith<$Res>  {
  factory $RequestConnectionSummaryCopyWith(RequestConnectionSummary value, $Res Function(RequestConnectionSummary) _then) = _$RequestConnectionSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String vendorId, String vendorName, String customerId, String customerName, String state, DateTime connectedAt, DateTime? identityRevealedAt, DateTime? closedAt, String? whatsappUrl, String? channel
});




}
/// @nodoc
class _$RequestConnectionSummaryCopyWithImpl<$Res>
    implements $RequestConnectionSummaryCopyWith<$Res> {
  _$RequestConnectionSummaryCopyWithImpl(this._self, this._then);

  final RequestConnectionSummary _self;
  final $Res Function(RequestConnectionSummary) _then;

/// Create a copy of RequestConnectionSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? vendorId = null,Object? vendorName = null,Object? customerId = null,Object? customerName = null,Object? state = null,Object? connectedAt = null,Object? identityRevealedAt = freezed,Object? closedAt = freezed,Object? whatsappUrl = freezed,Object? channel = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,vendorId: null == vendorId ? _self.vendorId : vendorId // ignore: cast_nullable_to_non_nullable
as String,vendorName: null == vendorName ? _self.vendorName : vendorName // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,connectedAt: null == connectedAt ? _self.connectedAt : connectedAt // ignore: cast_nullable_to_non_nullable
as DateTime,identityRevealedAt: freezed == identityRevealedAt ? _self.identityRevealedAt : identityRevealedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,whatsappUrl: freezed == whatsappUrl ? _self.whatsappUrl : whatsappUrl // ignore: cast_nullable_to_non_nullable
as String?,channel: freezed == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestConnectionSummary].
extension RequestConnectionSummaryPatterns on RequestConnectionSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestConnectionSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestConnectionSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestConnectionSummary value)  $default,){
final _that = this;
switch (_that) {
case _RequestConnectionSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestConnectionSummary value)?  $default,){
final _that = this;
switch (_that) {
case _RequestConnectionSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String vendorId,  String vendorName,  String customerId,  String customerName,  String state,  DateTime connectedAt,  DateTime? identityRevealedAt,  DateTime? closedAt,  String? whatsappUrl,  String? channel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestConnectionSummary() when $default != null:
return $default(_that.id,_that.vendorId,_that.vendorName,_that.customerId,_that.customerName,_that.state,_that.connectedAt,_that.identityRevealedAt,_that.closedAt,_that.whatsappUrl,_that.channel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String vendorId,  String vendorName,  String customerId,  String customerName,  String state,  DateTime connectedAt,  DateTime? identityRevealedAt,  DateTime? closedAt,  String? whatsappUrl,  String? channel)  $default,) {final _that = this;
switch (_that) {
case _RequestConnectionSummary():
return $default(_that.id,_that.vendorId,_that.vendorName,_that.customerId,_that.customerName,_that.state,_that.connectedAt,_that.identityRevealedAt,_that.closedAt,_that.whatsappUrl,_that.channel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String vendorId,  String vendorName,  String customerId,  String customerName,  String state,  DateTime connectedAt,  DateTime? identityRevealedAt,  DateTime? closedAt,  String? whatsappUrl,  String? channel)?  $default,) {final _that = this;
switch (_that) {
case _RequestConnectionSummary() when $default != null:
return $default(_that.id,_that.vendorId,_that.vendorName,_that.customerId,_that.customerName,_that.state,_that.connectedAt,_that.identityRevealedAt,_that.closedAt,_that.whatsappUrl,_that.channel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RequestConnectionSummary implements RequestConnectionSummary {
  const _RequestConnectionSummary({required this.id, required this.vendorId, required this.vendorName, required this.customerId, required this.customerName, this.state = 'ACTIVE', required this.connectedAt, this.identityRevealedAt, this.closedAt, this.whatsappUrl, this.channel});
  factory _RequestConnectionSummary.fromJson(Map<String, dynamic> json) => _$RequestConnectionSummaryFromJson(json);

@override final  String id;
@override final  String vendorId;
@override final  String vendorName;
@override final  String customerId;
@override final  String customerName;
@override@JsonKey() final  String state;
@override final  DateTime connectedAt;
@override final  DateTime? identityRevealedAt;
@override final  DateTime? closedAt;
@override final  String? whatsappUrl;
@override final  String? channel;

/// Create a copy of RequestConnectionSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestConnectionSummaryCopyWith<_RequestConnectionSummary> get copyWith => __$RequestConnectionSummaryCopyWithImpl<_RequestConnectionSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestConnectionSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestConnectionSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.vendorId, vendorId) || other.vendorId == vendorId)&&(identical(other.vendorName, vendorName) || other.vendorName == vendorName)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.state, state) || other.state == state)&&(identical(other.connectedAt, connectedAt) || other.connectedAt == connectedAt)&&(identical(other.identityRevealedAt, identityRevealedAt) || other.identityRevealedAt == identityRevealedAt)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&(identical(other.whatsappUrl, whatsappUrl) || other.whatsappUrl == whatsappUrl)&&(identical(other.channel, channel) || other.channel == channel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,vendorId,vendorName,customerId,customerName,state,connectedAt,identityRevealedAt,closedAt,whatsappUrl,channel);

@override
String toString() {
  return 'RequestConnectionSummary(id: $id, vendorId: $vendorId, vendorName: $vendorName, customerId: $customerId, customerName: $customerName, state: $state, connectedAt: $connectedAt, identityRevealedAt: $identityRevealedAt, closedAt: $closedAt, whatsappUrl: $whatsappUrl, channel: $channel)';
}


}

/// @nodoc
abstract mixin class _$RequestConnectionSummaryCopyWith<$Res> implements $RequestConnectionSummaryCopyWith<$Res> {
  factory _$RequestConnectionSummaryCopyWith(_RequestConnectionSummary value, $Res Function(_RequestConnectionSummary) _then) = __$RequestConnectionSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String vendorId, String vendorName, String customerId, String customerName, String state, DateTime connectedAt, DateTime? identityRevealedAt, DateTime? closedAt, String? whatsappUrl, String? channel
});




}
/// @nodoc
class __$RequestConnectionSummaryCopyWithImpl<$Res>
    implements _$RequestConnectionSummaryCopyWith<$Res> {
  __$RequestConnectionSummaryCopyWithImpl(this._self, this._then);

  final _RequestConnectionSummary _self;
  final $Res Function(_RequestConnectionSummary) _then;

/// Create a copy of RequestConnectionSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? vendorId = null,Object? vendorName = null,Object? customerId = null,Object? customerName = null,Object? state = null,Object? connectedAt = null,Object? identityRevealedAt = freezed,Object? closedAt = freezed,Object? whatsappUrl = freezed,Object? channel = freezed,}) {
  return _then(_RequestConnectionSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,vendorId: null == vendorId ? _self.vendorId : vendorId // ignore: cast_nullable_to_non_nullable
as String,vendorName: null == vendorName ? _self.vendorName : vendorName // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,connectedAt: null == connectedAt ? _self.connectedAt : connectedAt // ignore: cast_nullable_to_non_nullable
as DateTime,identityRevealedAt: freezed == identityRevealedAt ? _self.identityRevealedAt : identityRevealedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,whatsappUrl: freezed == whatsappUrl ? _self.whatsappUrl : whatsappUrl // ignore: cast_nullable_to_non_nullable
as String?,channel: freezed == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RequestInternalNoteItem {

 String get id; String get authorName; String get text; DateTime get createdAt;
/// Create a copy of RequestInternalNoteItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestInternalNoteItemCopyWith<RequestInternalNoteItem> get copyWith => _$RequestInternalNoteItemCopyWithImpl<RequestInternalNoteItem>(this as RequestInternalNoteItem, _$identity);

  /// Serializes this RequestInternalNoteItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestInternalNoteItem&&(identical(other.id, id) || other.id == id)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,authorName,text,createdAt);

@override
String toString() {
  return 'RequestInternalNoteItem(id: $id, authorName: $authorName, text: $text, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $RequestInternalNoteItemCopyWith<$Res>  {
  factory $RequestInternalNoteItemCopyWith(RequestInternalNoteItem value, $Res Function(RequestInternalNoteItem) _then) = _$RequestInternalNoteItemCopyWithImpl;
@useResult
$Res call({
 String id, String authorName, String text, DateTime createdAt
});




}
/// @nodoc
class _$RequestInternalNoteItemCopyWithImpl<$Res>
    implements $RequestInternalNoteItemCopyWith<$Res> {
  _$RequestInternalNoteItemCopyWithImpl(this._self, this._then);

  final RequestInternalNoteItem _self;
  final $Res Function(RequestInternalNoteItem) _then;

/// Create a copy of RequestInternalNoteItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? authorName = null,Object? text = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestInternalNoteItem].
extension RequestInternalNoteItemPatterns on RequestInternalNoteItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestInternalNoteItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestInternalNoteItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestInternalNoteItem value)  $default,){
final _that = this;
switch (_that) {
case _RequestInternalNoteItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestInternalNoteItem value)?  $default,){
final _that = this;
switch (_that) {
case _RequestInternalNoteItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String authorName,  String text,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestInternalNoteItem() when $default != null:
return $default(_that.id,_that.authorName,_that.text,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String authorName,  String text,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _RequestInternalNoteItem():
return $default(_that.id,_that.authorName,_that.text,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String authorName,  String text,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _RequestInternalNoteItem() when $default != null:
return $default(_that.id,_that.authorName,_that.text,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RequestInternalNoteItem implements RequestInternalNoteItem {
  const _RequestInternalNoteItem({required this.id, required this.authorName, required this.text, required this.createdAt});
  factory _RequestInternalNoteItem.fromJson(Map<String, dynamic> json) => _$RequestInternalNoteItemFromJson(json);

@override final  String id;
@override final  String authorName;
@override final  String text;
@override final  DateTime createdAt;

/// Create a copy of RequestInternalNoteItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestInternalNoteItemCopyWith<_RequestInternalNoteItem> get copyWith => __$RequestInternalNoteItemCopyWithImpl<_RequestInternalNoteItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestInternalNoteItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestInternalNoteItem&&(identical(other.id, id) || other.id == id)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,authorName,text,createdAt);

@override
String toString() {
  return 'RequestInternalNoteItem(id: $id, authorName: $authorName, text: $text, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$RequestInternalNoteItemCopyWith<$Res> implements $RequestInternalNoteItemCopyWith<$Res> {
  factory _$RequestInternalNoteItemCopyWith(_RequestInternalNoteItem value, $Res Function(_RequestInternalNoteItem) _then) = __$RequestInternalNoteItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String authorName, String text, DateTime createdAt
});




}
/// @nodoc
class __$RequestInternalNoteItemCopyWithImpl<$Res>
    implements _$RequestInternalNoteItemCopyWith<$Res> {
  __$RequestInternalNoteItemCopyWithImpl(this._self, this._then);

  final _RequestInternalNoteItem _self;
  final $Res Function(_RequestInternalNoteItem) _then;

/// Create a copy of RequestInternalNoteItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? authorName = null,Object? text = null,Object? createdAt = null,}) {
  return _then(_RequestInternalNoteItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$RequestDetail {

 String get id; String? get reference;@JsonKey(unknownEnumValue: RequestType.findOrnament) RequestType get requestType;@JsonKey(unknownEnumValue: Direction.buy) Direction get direction;@JsonKey(unknownEnumValue: RequestState.draft) RequestState get state; CustomerProfileSummary get customer; String get regionName; String? get ornamentType; double? get weightGrams; bool get weightIsApproximate; String? get purityKarat; String? get condition; double? get denominationGrams; int? get quantity; String? get mintOrRefiner; String? get notes; double? get indicativeValue; double? get budgetMin; double? get budgetMax; bool get budgetIsFlexible; DateTime? get publishedAt; DateTime? get expiresAt; DateTime? get createdAt; DateTime? get updatedAt; String? get cancellationReason; String? get removalReasonCode; String? get removalReasonText; String? get removalPolicyClause; List<RequestMediaItem> get media; List<MatchedVendorItem> get matchedVendors; List<RequestOfferItem> get offers; List<RequestTimelineEvent> get timeline; RequestConnectionSummary? get connection; List<RequestInternalNoteItem> get internalNotes;
/// Create a copy of RequestDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestDetailCopyWith<RequestDetail> get copyWith => _$RequestDetailCopyWithImpl<RequestDetail>(this as RequestDetail, _$identity);

  /// Serializes this RequestDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.state, state) || other.state == state)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.regionName, regionName) || other.regionName == regionName)&&(identical(other.ornamentType, ornamentType) || other.ornamentType == ornamentType)&&(identical(other.weightGrams, weightGrams) || other.weightGrams == weightGrams)&&(identical(other.weightIsApproximate, weightIsApproximate) || other.weightIsApproximate == weightIsApproximate)&&(identical(other.purityKarat, purityKarat) || other.purityKarat == purityKarat)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.denominationGrams, denominationGrams) || other.denominationGrams == denominationGrams)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.mintOrRefiner, mintOrRefiner) || other.mintOrRefiner == mintOrRefiner)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.indicativeValue, indicativeValue) || other.indicativeValue == indicativeValue)&&(identical(other.budgetMin, budgetMin) || other.budgetMin == budgetMin)&&(identical(other.budgetMax, budgetMax) || other.budgetMax == budgetMax)&&(identical(other.budgetIsFlexible, budgetIsFlexible) || other.budgetIsFlexible == budgetIsFlexible)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.removalReasonCode, removalReasonCode) || other.removalReasonCode == removalReasonCode)&&(identical(other.removalReasonText, removalReasonText) || other.removalReasonText == removalReasonText)&&(identical(other.removalPolicyClause, removalPolicyClause) || other.removalPolicyClause == removalPolicyClause)&&const DeepCollectionEquality().equals(other.media, media)&&const DeepCollectionEquality().equals(other.matchedVendors, matchedVendors)&&const DeepCollectionEquality().equals(other.offers, offers)&&const DeepCollectionEquality().equals(other.timeline, timeline)&&(identical(other.connection, connection) || other.connection == connection)&&const DeepCollectionEquality().equals(other.internalNotes, internalNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reference,requestType,direction,state,customer,regionName,ornamentType,weightGrams,weightIsApproximate,purityKarat,condition,denominationGrams,quantity,mintOrRefiner,notes,indicativeValue,budgetMin,budgetMax,budgetIsFlexible,publishedAt,expiresAt,createdAt,updatedAt,cancellationReason,removalReasonCode,removalReasonText,removalPolicyClause,const DeepCollectionEquality().hash(media),const DeepCollectionEquality().hash(matchedVendors),const DeepCollectionEquality().hash(offers),const DeepCollectionEquality().hash(timeline),connection,const DeepCollectionEquality().hash(internalNotes)]);

@override
String toString() {
  return 'RequestDetail(id: $id, reference: $reference, requestType: $requestType, direction: $direction, state: $state, customer: $customer, regionName: $regionName, ornamentType: $ornamentType, weightGrams: $weightGrams, weightIsApproximate: $weightIsApproximate, purityKarat: $purityKarat, condition: $condition, denominationGrams: $denominationGrams, quantity: $quantity, mintOrRefiner: $mintOrRefiner, notes: $notes, indicativeValue: $indicativeValue, budgetMin: $budgetMin, budgetMax: $budgetMax, budgetIsFlexible: $budgetIsFlexible, publishedAt: $publishedAt, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt, cancellationReason: $cancellationReason, removalReasonCode: $removalReasonCode, removalReasonText: $removalReasonText, removalPolicyClause: $removalPolicyClause, media: $media, matchedVendors: $matchedVendors, offers: $offers, timeline: $timeline, connection: $connection, internalNotes: $internalNotes)';
}


}

/// @nodoc
abstract mixin class $RequestDetailCopyWith<$Res>  {
  factory $RequestDetailCopyWith(RequestDetail value, $Res Function(RequestDetail) _then) = _$RequestDetailCopyWithImpl;
@useResult
$Res call({
 String id, String? reference,@JsonKey(unknownEnumValue: RequestType.findOrnament) RequestType requestType,@JsonKey(unknownEnumValue: Direction.buy) Direction direction,@JsonKey(unknownEnumValue: RequestState.draft) RequestState state, CustomerProfileSummary customer, String regionName, String? ornamentType, double? weightGrams, bool weightIsApproximate, String? purityKarat, String? condition, double? denominationGrams, int? quantity, String? mintOrRefiner, String? notes, double? indicativeValue, double? budgetMin, double? budgetMax, bool budgetIsFlexible, DateTime? publishedAt, DateTime? expiresAt, DateTime? createdAt, DateTime? updatedAt, String? cancellationReason, String? removalReasonCode, String? removalReasonText, String? removalPolicyClause, List<RequestMediaItem> media, List<MatchedVendorItem> matchedVendors, List<RequestOfferItem> offers, List<RequestTimelineEvent> timeline, RequestConnectionSummary? connection, List<RequestInternalNoteItem> internalNotes
});


$CustomerProfileSummaryCopyWith<$Res> get customer;$RequestConnectionSummaryCopyWith<$Res>? get connection;

}
/// @nodoc
class _$RequestDetailCopyWithImpl<$Res>
    implements $RequestDetailCopyWith<$Res> {
  _$RequestDetailCopyWithImpl(this._self, this._then);

  final RequestDetail _self;
  final $Res Function(RequestDetail) _then;

/// Create a copy of RequestDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reference = freezed,Object? requestType = null,Object? direction = null,Object? state = null,Object? customer = null,Object? regionName = null,Object? ornamentType = freezed,Object? weightGrams = freezed,Object? weightIsApproximate = null,Object? purityKarat = freezed,Object? condition = freezed,Object? denominationGrams = freezed,Object? quantity = freezed,Object? mintOrRefiner = freezed,Object? notes = freezed,Object? indicativeValue = freezed,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? budgetIsFlexible = null,Object? publishedAt = freezed,Object? expiresAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? cancellationReason = freezed,Object? removalReasonCode = freezed,Object? removalReasonText = freezed,Object? removalPolicyClause = freezed,Object? media = null,Object? matchedVendors = null,Object? offers = null,Object? timeline = null,Object? connection = freezed,Object? internalNotes = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,requestType: null == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as RequestType,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as Direction,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as RequestState,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as CustomerProfileSummary,regionName: null == regionName ? _self.regionName : regionName // ignore: cast_nullable_to_non_nullable
as String,ornamentType: freezed == ornamentType ? _self.ornamentType : ornamentType // ignore: cast_nullable_to_non_nullable
as String?,weightGrams: freezed == weightGrams ? _self.weightGrams : weightGrams // ignore: cast_nullable_to_non_nullable
as double?,weightIsApproximate: null == weightIsApproximate ? _self.weightIsApproximate : weightIsApproximate // ignore: cast_nullable_to_non_nullable
as bool,purityKarat: freezed == purityKarat ? _self.purityKarat : purityKarat // ignore: cast_nullable_to_non_nullable
as String?,condition: freezed == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String?,denominationGrams: freezed == denominationGrams ? _self.denominationGrams : denominationGrams // ignore: cast_nullable_to_non_nullable
as double?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int?,mintOrRefiner: freezed == mintOrRefiner ? _self.mintOrRefiner : mintOrRefiner // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,indicativeValue: freezed == indicativeValue ? _self.indicativeValue : indicativeValue // ignore: cast_nullable_to_non_nullable
as double?,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin // ignore: cast_nullable_to_non_nullable
as double?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as double?,budgetIsFlexible: null == budgetIsFlexible ? _self.budgetIsFlexible : budgetIsFlexible // ignore: cast_nullable_to_non_nullable
as bool,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,removalReasonCode: freezed == removalReasonCode ? _self.removalReasonCode : removalReasonCode // ignore: cast_nullable_to_non_nullable
as String?,removalReasonText: freezed == removalReasonText ? _self.removalReasonText : removalReasonText // ignore: cast_nullable_to_non_nullable
as String?,removalPolicyClause: freezed == removalPolicyClause ? _self.removalPolicyClause : removalPolicyClause // ignore: cast_nullable_to_non_nullable
as String?,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as List<RequestMediaItem>,matchedVendors: null == matchedVendors ? _self.matchedVendors : matchedVendors // ignore: cast_nullable_to_non_nullable
as List<MatchedVendorItem>,offers: null == offers ? _self.offers : offers // ignore: cast_nullable_to_non_nullable
as List<RequestOfferItem>,timeline: null == timeline ? _self.timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<RequestTimelineEvent>,connection: freezed == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as RequestConnectionSummary?,internalNotes: null == internalNotes ? _self.internalNotes : internalNotes // ignore: cast_nullable_to_non_nullable
as List<RequestInternalNoteItem>,
  ));
}
/// Create a copy of RequestDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerProfileSummaryCopyWith<$Res> get customer {
  
  return $CustomerProfileSummaryCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}/// Create a copy of RequestDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RequestConnectionSummaryCopyWith<$Res>? get connection {
    if (_self.connection == null) {
    return null;
  }

  return $RequestConnectionSummaryCopyWith<$Res>(_self.connection!, (value) {
    return _then(_self.copyWith(connection: value));
  });
}
}


/// Adds pattern-matching-related methods to [RequestDetail].
extension RequestDetailPatterns on RequestDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestDetail value)  $default,){
final _that = this;
switch (_that) {
case _RequestDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestDetail value)?  $default,){
final _that = this;
switch (_that) {
case _RequestDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? reference, @JsonKey(unknownEnumValue: RequestType.findOrnament)  RequestType requestType, @JsonKey(unknownEnumValue: Direction.buy)  Direction direction, @JsonKey(unknownEnumValue: RequestState.draft)  RequestState state,  CustomerProfileSummary customer,  String regionName,  String? ornamentType,  double? weightGrams,  bool weightIsApproximate,  String? purityKarat,  String? condition,  double? denominationGrams,  int? quantity,  String? mintOrRefiner,  String? notes,  double? indicativeValue,  double? budgetMin,  double? budgetMax,  bool budgetIsFlexible,  DateTime? publishedAt,  DateTime? expiresAt,  DateTime? createdAt,  DateTime? updatedAt,  String? cancellationReason,  String? removalReasonCode,  String? removalReasonText,  String? removalPolicyClause,  List<RequestMediaItem> media,  List<MatchedVendorItem> matchedVendors,  List<RequestOfferItem> offers,  List<RequestTimelineEvent> timeline,  RequestConnectionSummary? connection,  List<RequestInternalNoteItem> internalNotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestDetail() when $default != null:
return $default(_that.id,_that.reference,_that.requestType,_that.direction,_that.state,_that.customer,_that.regionName,_that.ornamentType,_that.weightGrams,_that.weightIsApproximate,_that.purityKarat,_that.condition,_that.denominationGrams,_that.quantity,_that.mintOrRefiner,_that.notes,_that.indicativeValue,_that.budgetMin,_that.budgetMax,_that.budgetIsFlexible,_that.publishedAt,_that.expiresAt,_that.createdAt,_that.updatedAt,_that.cancellationReason,_that.removalReasonCode,_that.removalReasonText,_that.removalPolicyClause,_that.media,_that.matchedVendors,_that.offers,_that.timeline,_that.connection,_that.internalNotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? reference, @JsonKey(unknownEnumValue: RequestType.findOrnament)  RequestType requestType, @JsonKey(unknownEnumValue: Direction.buy)  Direction direction, @JsonKey(unknownEnumValue: RequestState.draft)  RequestState state,  CustomerProfileSummary customer,  String regionName,  String? ornamentType,  double? weightGrams,  bool weightIsApproximate,  String? purityKarat,  String? condition,  double? denominationGrams,  int? quantity,  String? mintOrRefiner,  String? notes,  double? indicativeValue,  double? budgetMin,  double? budgetMax,  bool budgetIsFlexible,  DateTime? publishedAt,  DateTime? expiresAt,  DateTime? createdAt,  DateTime? updatedAt,  String? cancellationReason,  String? removalReasonCode,  String? removalReasonText,  String? removalPolicyClause,  List<RequestMediaItem> media,  List<MatchedVendorItem> matchedVendors,  List<RequestOfferItem> offers,  List<RequestTimelineEvent> timeline,  RequestConnectionSummary? connection,  List<RequestInternalNoteItem> internalNotes)  $default,) {final _that = this;
switch (_that) {
case _RequestDetail():
return $default(_that.id,_that.reference,_that.requestType,_that.direction,_that.state,_that.customer,_that.regionName,_that.ornamentType,_that.weightGrams,_that.weightIsApproximate,_that.purityKarat,_that.condition,_that.denominationGrams,_that.quantity,_that.mintOrRefiner,_that.notes,_that.indicativeValue,_that.budgetMin,_that.budgetMax,_that.budgetIsFlexible,_that.publishedAt,_that.expiresAt,_that.createdAt,_that.updatedAt,_that.cancellationReason,_that.removalReasonCode,_that.removalReasonText,_that.removalPolicyClause,_that.media,_that.matchedVendors,_that.offers,_that.timeline,_that.connection,_that.internalNotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? reference, @JsonKey(unknownEnumValue: RequestType.findOrnament)  RequestType requestType, @JsonKey(unknownEnumValue: Direction.buy)  Direction direction, @JsonKey(unknownEnumValue: RequestState.draft)  RequestState state,  CustomerProfileSummary customer,  String regionName,  String? ornamentType,  double? weightGrams,  bool weightIsApproximate,  String? purityKarat,  String? condition,  double? denominationGrams,  int? quantity,  String? mintOrRefiner,  String? notes,  double? indicativeValue,  double? budgetMin,  double? budgetMax,  bool budgetIsFlexible,  DateTime? publishedAt,  DateTime? expiresAt,  DateTime? createdAt,  DateTime? updatedAt,  String? cancellationReason,  String? removalReasonCode,  String? removalReasonText,  String? removalPolicyClause,  List<RequestMediaItem> media,  List<MatchedVendorItem> matchedVendors,  List<RequestOfferItem> offers,  List<RequestTimelineEvent> timeline,  RequestConnectionSummary? connection,  List<RequestInternalNoteItem> internalNotes)?  $default,) {final _that = this;
switch (_that) {
case _RequestDetail() when $default != null:
return $default(_that.id,_that.reference,_that.requestType,_that.direction,_that.state,_that.customer,_that.regionName,_that.ornamentType,_that.weightGrams,_that.weightIsApproximate,_that.purityKarat,_that.condition,_that.denominationGrams,_that.quantity,_that.mintOrRefiner,_that.notes,_that.indicativeValue,_that.budgetMin,_that.budgetMax,_that.budgetIsFlexible,_that.publishedAt,_that.expiresAt,_that.createdAt,_that.updatedAt,_that.cancellationReason,_that.removalReasonCode,_that.removalReasonText,_that.removalPolicyClause,_that.media,_that.matchedVendors,_that.offers,_that.timeline,_that.connection,_that.internalNotes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RequestDetail extends RequestDetail {
  const _RequestDetail({required this.id, this.reference, @JsonKey(unknownEnumValue: RequestType.findOrnament) this.requestType = RequestType.findOrnament, @JsonKey(unknownEnumValue: Direction.buy) this.direction = Direction.buy, @JsonKey(unknownEnumValue: RequestState.draft) this.state = RequestState.draft, required this.customer, this.regionName = '—', this.ornamentType, this.weightGrams, this.weightIsApproximate = false, this.purityKarat, this.condition, this.denominationGrams, this.quantity, this.mintOrRefiner, this.notes, this.indicativeValue, this.budgetMin, this.budgetMax, this.budgetIsFlexible = false, this.publishedAt, this.expiresAt, this.createdAt, this.updatedAt, this.cancellationReason, this.removalReasonCode, this.removalReasonText, this.removalPolicyClause, final  List<RequestMediaItem> media = const [], final  List<MatchedVendorItem> matchedVendors = const [], final  List<RequestOfferItem> offers = const [], final  List<RequestTimelineEvent> timeline = const [], this.connection, final  List<RequestInternalNoteItem> internalNotes = const []}): _media = media,_matchedVendors = matchedVendors,_offers = offers,_timeline = timeline,_internalNotes = internalNotes,super._();
  factory _RequestDetail.fromJson(Map<String, dynamic> json) => _$RequestDetailFromJson(json);

@override final  String id;
@override final  String? reference;
@override@JsonKey(unknownEnumValue: RequestType.findOrnament) final  RequestType requestType;
@override@JsonKey(unknownEnumValue: Direction.buy) final  Direction direction;
@override@JsonKey(unknownEnumValue: RequestState.draft) final  RequestState state;
@override final  CustomerProfileSummary customer;
@override@JsonKey() final  String regionName;
@override final  String? ornamentType;
@override final  double? weightGrams;
@override@JsonKey() final  bool weightIsApproximate;
@override final  String? purityKarat;
@override final  String? condition;
@override final  double? denominationGrams;
@override final  int? quantity;
@override final  String? mintOrRefiner;
@override final  String? notes;
@override final  double? indicativeValue;
@override final  double? budgetMin;
@override final  double? budgetMax;
@override@JsonKey() final  bool budgetIsFlexible;
@override final  DateTime? publishedAt;
@override final  DateTime? expiresAt;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  String? cancellationReason;
@override final  String? removalReasonCode;
@override final  String? removalReasonText;
@override final  String? removalPolicyClause;
 final  List<RequestMediaItem> _media;
@override@JsonKey() List<RequestMediaItem> get media {
  if (_media is EqualUnmodifiableListView) return _media;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_media);
}

 final  List<MatchedVendorItem> _matchedVendors;
@override@JsonKey() List<MatchedVendorItem> get matchedVendors {
  if (_matchedVendors is EqualUnmodifiableListView) return _matchedVendors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_matchedVendors);
}

 final  List<RequestOfferItem> _offers;
@override@JsonKey() List<RequestOfferItem> get offers {
  if (_offers is EqualUnmodifiableListView) return _offers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_offers);
}

 final  List<RequestTimelineEvent> _timeline;
@override@JsonKey() List<RequestTimelineEvent> get timeline {
  if (_timeline is EqualUnmodifiableListView) return _timeline;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_timeline);
}

@override final  RequestConnectionSummary? connection;
 final  List<RequestInternalNoteItem> _internalNotes;
@override@JsonKey() List<RequestInternalNoteItem> get internalNotes {
  if (_internalNotes is EqualUnmodifiableListView) return _internalNotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_internalNotes);
}


/// Create a copy of RequestDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestDetailCopyWith<_RequestDetail> get copyWith => __$RequestDetailCopyWithImpl<_RequestDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.state, state) || other.state == state)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.regionName, regionName) || other.regionName == regionName)&&(identical(other.ornamentType, ornamentType) || other.ornamentType == ornamentType)&&(identical(other.weightGrams, weightGrams) || other.weightGrams == weightGrams)&&(identical(other.weightIsApproximate, weightIsApproximate) || other.weightIsApproximate == weightIsApproximate)&&(identical(other.purityKarat, purityKarat) || other.purityKarat == purityKarat)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.denominationGrams, denominationGrams) || other.denominationGrams == denominationGrams)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.mintOrRefiner, mintOrRefiner) || other.mintOrRefiner == mintOrRefiner)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.indicativeValue, indicativeValue) || other.indicativeValue == indicativeValue)&&(identical(other.budgetMin, budgetMin) || other.budgetMin == budgetMin)&&(identical(other.budgetMax, budgetMax) || other.budgetMax == budgetMax)&&(identical(other.budgetIsFlexible, budgetIsFlexible) || other.budgetIsFlexible == budgetIsFlexible)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.removalReasonCode, removalReasonCode) || other.removalReasonCode == removalReasonCode)&&(identical(other.removalReasonText, removalReasonText) || other.removalReasonText == removalReasonText)&&(identical(other.removalPolicyClause, removalPolicyClause) || other.removalPolicyClause == removalPolicyClause)&&const DeepCollectionEquality().equals(other._media, _media)&&const DeepCollectionEquality().equals(other._matchedVendors, _matchedVendors)&&const DeepCollectionEquality().equals(other._offers, _offers)&&const DeepCollectionEquality().equals(other._timeline, _timeline)&&(identical(other.connection, connection) || other.connection == connection)&&const DeepCollectionEquality().equals(other._internalNotes, _internalNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reference,requestType,direction,state,customer,regionName,ornamentType,weightGrams,weightIsApproximate,purityKarat,condition,denominationGrams,quantity,mintOrRefiner,notes,indicativeValue,budgetMin,budgetMax,budgetIsFlexible,publishedAt,expiresAt,createdAt,updatedAt,cancellationReason,removalReasonCode,removalReasonText,removalPolicyClause,const DeepCollectionEquality().hash(_media),const DeepCollectionEquality().hash(_matchedVendors),const DeepCollectionEquality().hash(_offers),const DeepCollectionEquality().hash(_timeline),connection,const DeepCollectionEquality().hash(_internalNotes)]);

@override
String toString() {
  return 'RequestDetail(id: $id, reference: $reference, requestType: $requestType, direction: $direction, state: $state, customer: $customer, regionName: $regionName, ornamentType: $ornamentType, weightGrams: $weightGrams, weightIsApproximate: $weightIsApproximate, purityKarat: $purityKarat, condition: $condition, denominationGrams: $denominationGrams, quantity: $quantity, mintOrRefiner: $mintOrRefiner, notes: $notes, indicativeValue: $indicativeValue, budgetMin: $budgetMin, budgetMax: $budgetMax, budgetIsFlexible: $budgetIsFlexible, publishedAt: $publishedAt, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt, cancellationReason: $cancellationReason, removalReasonCode: $removalReasonCode, removalReasonText: $removalReasonText, removalPolicyClause: $removalPolicyClause, media: $media, matchedVendors: $matchedVendors, offers: $offers, timeline: $timeline, connection: $connection, internalNotes: $internalNotes)';
}


}

/// @nodoc
abstract mixin class _$RequestDetailCopyWith<$Res> implements $RequestDetailCopyWith<$Res> {
  factory _$RequestDetailCopyWith(_RequestDetail value, $Res Function(_RequestDetail) _then) = __$RequestDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String? reference,@JsonKey(unknownEnumValue: RequestType.findOrnament) RequestType requestType,@JsonKey(unknownEnumValue: Direction.buy) Direction direction,@JsonKey(unknownEnumValue: RequestState.draft) RequestState state, CustomerProfileSummary customer, String regionName, String? ornamentType, double? weightGrams, bool weightIsApproximate, String? purityKarat, String? condition, double? denominationGrams, int? quantity, String? mintOrRefiner, String? notes, double? indicativeValue, double? budgetMin, double? budgetMax, bool budgetIsFlexible, DateTime? publishedAt, DateTime? expiresAt, DateTime? createdAt, DateTime? updatedAt, String? cancellationReason, String? removalReasonCode, String? removalReasonText, String? removalPolicyClause, List<RequestMediaItem> media, List<MatchedVendorItem> matchedVendors, List<RequestOfferItem> offers, List<RequestTimelineEvent> timeline, RequestConnectionSummary? connection, List<RequestInternalNoteItem> internalNotes
});


@override $CustomerProfileSummaryCopyWith<$Res> get customer;@override $RequestConnectionSummaryCopyWith<$Res>? get connection;

}
/// @nodoc
class __$RequestDetailCopyWithImpl<$Res>
    implements _$RequestDetailCopyWith<$Res> {
  __$RequestDetailCopyWithImpl(this._self, this._then);

  final _RequestDetail _self;
  final $Res Function(_RequestDetail) _then;

/// Create a copy of RequestDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reference = freezed,Object? requestType = null,Object? direction = null,Object? state = null,Object? customer = null,Object? regionName = null,Object? ornamentType = freezed,Object? weightGrams = freezed,Object? weightIsApproximate = null,Object? purityKarat = freezed,Object? condition = freezed,Object? denominationGrams = freezed,Object? quantity = freezed,Object? mintOrRefiner = freezed,Object? notes = freezed,Object? indicativeValue = freezed,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? budgetIsFlexible = null,Object? publishedAt = freezed,Object? expiresAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? cancellationReason = freezed,Object? removalReasonCode = freezed,Object? removalReasonText = freezed,Object? removalPolicyClause = freezed,Object? media = null,Object? matchedVendors = null,Object? offers = null,Object? timeline = null,Object? connection = freezed,Object? internalNotes = null,}) {
  return _then(_RequestDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,requestType: null == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as RequestType,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as Direction,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as RequestState,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as CustomerProfileSummary,regionName: null == regionName ? _self.regionName : regionName // ignore: cast_nullable_to_non_nullable
as String,ornamentType: freezed == ornamentType ? _self.ornamentType : ornamentType // ignore: cast_nullable_to_non_nullable
as String?,weightGrams: freezed == weightGrams ? _self.weightGrams : weightGrams // ignore: cast_nullable_to_non_nullable
as double?,weightIsApproximate: null == weightIsApproximate ? _self.weightIsApproximate : weightIsApproximate // ignore: cast_nullable_to_non_nullable
as bool,purityKarat: freezed == purityKarat ? _self.purityKarat : purityKarat // ignore: cast_nullable_to_non_nullable
as String?,condition: freezed == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String?,denominationGrams: freezed == denominationGrams ? _self.denominationGrams : denominationGrams // ignore: cast_nullable_to_non_nullable
as double?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int?,mintOrRefiner: freezed == mintOrRefiner ? _self.mintOrRefiner : mintOrRefiner // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,indicativeValue: freezed == indicativeValue ? _self.indicativeValue : indicativeValue // ignore: cast_nullable_to_non_nullable
as double?,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin // ignore: cast_nullable_to_non_nullable
as double?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as double?,budgetIsFlexible: null == budgetIsFlexible ? _self.budgetIsFlexible : budgetIsFlexible // ignore: cast_nullable_to_non_nullable
as bool,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,removalReasonCode: freezed == removalReasonCode ? _self.removalReasonCode : removalReasonCode // ignore: cast_nullable_to_non_nullable
as String?,removalReasonText: freezed == removalReasonText ? _self.removalReasonText : removalReasonText // ignore: cast_nullable_to_non_nullable
as String?,removalPolicyClause: freezed == removalPolicyClause ? _self.removalPolicyClause : removalPolicyClause // ignore: cast_nullable_to_non_nullable
as String?,media: null == media ? _self._media : media // ignore: cast_nullable_to_non_nullable
as List<RequestMediaItem>,matchedVendors: null == matchedVendors ? _self._matchedVendors : matchedVendors // ignore: cast_nullable_to_non_nullable
as List<MatchedVendorItem>,offers: null == offers ? _self._offers : offers // ignore: cast_nullable_to_non_nullable
as List<RequestOfferItem>,timeline: null == timeline ? _self._timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<RequestTimelineEvent>,connection: freezed == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as RequestConnectionSummary?,internalNotes: null == internalNotes ? _self._internalNotes : internalNotes // ignore: cast_nullable_to_non_nullable
as List<RequestInternalNoteItem>,
  ));
}

/// Create a copy of RequestDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerProfileSummaryCopyWith<$Res> get customer {
  
  return $CustomerProfileSummaryCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}/// Create a copy of RequestDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RequestConnectionSummaryCopyWith<$Res>? get connection {
    if (_self.connection == null) {
    return null;
  }

  return $RequestConnectionSummaryCopyWith<$Res>(_self.connection!, (value) {
    return _then(_self.copyWith(connection: value));
  });
}
}

// dart format on
