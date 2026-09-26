// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vendor_verification_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VendorVerificationDetail {

 String get id; String get legalBusinessName; String get tradeLicenceNumber;@JsonKey(fromJson: _dateFromJson) DateTime get licenceExpiryDate; String get businessAddress; String get contactPersonName; String get businessEmail; List<VendorDocumentDetail> get documents; List<String> get regions; String? get tradingName; String? get mobileNumber; double? get oldestWaitingHours; DateTime? get submittedAt;
/// Create a copy of VendorVerificationDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorVerificationDetailCopyWith<VendorVerificationDetail> get copyWith => _$VendorVerificationDetailCopyWithImpl<VendorVerificationDetail>(this as VendorVerificationDetail, _$identity);

  /// Serializes this VendorVerificationDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorVerificationDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.legalBusinessName, legalBusinessName) || other.legalBusinessName == legalBusinessName)&&(identical(other.tradeLicenceNumber, tradeLicenceNumber) || other.tradeLicenceNumber == tradeLicenceNumber)&&(identical(other.licenceExpiryDate, licenceExpiryDate) || other.licenceExpiryDate == licenceExpiryDate)&&(identical(other.businessAddress, businessAddress) || other.businessAddress == businessAddress)&&(identical(other.contactPersonName, contactPersonName) || other.contactPersonName == contactPersonName)&&(identical(other.businessEmail, businessEmail) || other.businessEmail == businessEmail)&&const DeepCollectionEquality().equals(other.documents, documents)&&const DeepCollectionEquality().equals(other.regions, regions)&&(identical(other.tradingName, tradingName) || other.tradingName == tradingName)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.oldestWaitingHours, oldestWaitingHours) || other.oldestWaitingHours == oldestWaitingHours)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,legalBusinessName,tradeLicenceNumber,licenceExpiryDate,businessAddress,contactPersonName,businessEmail,const DeepCollectionEquality().hash(documents),const DeepCollectionEquality().hash(regions),tradingName,mobileNumber,oldestWaitingHours,submittedAt);

@override
String toString() {
  return 'VendorVerificationDetail(id: $id, legalBusinessName: $legalBusinessName, tradeLicenceNumber: $tradeLicenceNumber, licenceExpiryDate: $licenceExpiryDate, businessAddress: $businessAddress, contactPersonName: $contactPersonName, businessEmail: $businessEmail, documents: $documents, regions: $regions, tradingName: $tradingName, mobileNumber: $mobileNumber, oldestWaitingHours: $oldestWaitingHours, submittedAt: $submittedAt)';
}


}

/// @nodoc
abstract mixin class $VendorVerificationDetailCopyWith<$Res>  {
  factory $VendorVerificationDetailCopyWith(VendorVerificationDetail value, $Res Function(VendorVerificationDetail) _then) = _$VendorVerificationDetailCopyWithImpl;
@useResult
$Res call({
 String id, String legalBusinessName, String tradeLicenceNumber,@JsonKey(fromJson: _dateFromJson) DateTime licenceExpiryDate, String businessAddress, String contactPersonName, String businessEmail, List<VendorDocumentDetail> documents, List<String> regions, String? tradingName, String? mobileNumber, double? oldestWaitingHours, DateTime? submittedAt
});




}
/// @nodoc
class _$VendorVerificationDetailCopyWithImpl<$Res>
    implements $VendorVerificationDetailCopyWith<$Res> {
  _$VendorVerificationDetailCopyWithImpl(this._self, this._then);

  final VendorVerificationDetail _self;
  final $Res Function(VendorVerificationDetail) _then;

/// Create a copy of VendorVerificationDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? legalBusinessName = null,Object? tradeLicenceNumber = null,Object? licenceExpiryDate = null,Object? businessAddress = null,Object? contactPersonName = null,Object? businessEmail = null,Object? documents = null,Object? regions = null,Object? tradingName = freezed,Object? mobileNumber = freezed,Object? oldestWaitingHours = freezed,Object? submittedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,legalBusinessName: null == legalBusinessName ? _self.legalBusinessName : legalBusinessName // ignore: cast_nullable_to_non_nullable
as String,tradeLicenceNumber: null == tradeLicenceNumber ? _self.tradeLicenceNumber : tradeLicenceNumber // ignore: cast_nullable_to_non_nullable
as String,licenceExpiryDate: null == licenceExpiryDate ? _self.licenceExpiryDate : licenceExpiryDate // ignore: cast_nullable_to_non_nullable
as DateTime,businessAddress: null == businessAddress ? _self.businessAddress : businessAddress // ignore: cast_nullable_to_non_nullable
as String,contactPersonName: null == contactPersonName ? _self.contactPersonName : contactPersonName // ignore: cast_nullable_to_non_nullable
as String,businessEmail: null == businessEmail ? _self.businessEmail : businessEmail // ignore: cast_nullable_to_non_nullable
as String,documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<VendorDocumentDetail>,regions: null == regions ? _self.regions : regions // ignore: cast_nullable_to_non_nullable
as List<String>,tradingName: freezed == tradingName ? _self.tradingName : tradingName // ignore: cast_nullable_to_non_nullable
as String?,mobileNumber: freezed == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String?,oldestWaitingHours: freezed == oldestWaitingHours ? _self.oldestWaitingHours : oldestWaitingHours // ignore: cast_nullable_to_non_nullable
as double?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [VendorVerificationDetail].
extension VendorVerificationDetailPatterns on VendorVerificationDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorVerificationDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorVerificationDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorVerificationDetail value)  $default,){
final _that = this;
switch (_that) {
case _VendorVerificationDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorVerificationDetail value)?  $default,){
final _that = this;
switch (_that) {
case _VendorVerificationDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String legalBusinessName,  String tradeLicenceNumber, @JsonKey(fromJson: _dateFromJson)  DateTime licenceExpiryDate,  String businessAddress,  String contactPersonName,  String businessEmail,  List<VendorDocumentDetail> documents,  List<String> regions,  String? tradingName,  String? mobileNumber,  double? oldestWaitingHours,  DateTime? submittedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorVerificationDetail() when $default != null:
return $default(_that.id,_that.legalBusinessName,_that.tradeLicenceNumber,_that.licenceExpiryDate,_that.businessAddress,_that.contactPersonName,_that.businessEmail,_that.documents,_that.regions,_that.tradingName,_that.mobileNumber,_that.oldestWaitingHours,_that.submittedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String legalBusinessName,  String tradeLicenceNumber, @JsonKey(fromJson: _dateFromJson)  DateTime licenceExpiryDate,  String businessAddress,  String contactPersonName,  String businessEmail,  List<VendorDocumentDetail> documents,  List<String> regions,  String? tradingName,  String? mobileNumber,  double? oldestWaitingHours,  DateTime? submittedAt)  $default,) {final _that = this;
switch (_that) {
case _VendorVerificationDetail():
return $default(_that.id,_that.legalBusinessName,_that.tradeLicenceNumber,_that.licenceExpiryDate,_that.businessAddress,_that.contactPersonName,_that.businessEmail,_that.documents,_that.regions,_that.tradingName,_that.mobileNumber,_that.oldestWaitingHours,_that.submittedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String legalBusinessName,  String tradeLicenceNumber, @JsonKey(fromJson: _dateFromJson)  DateTime licenceExpiryDate,  String businessAddress,  String contactPersonName,  String businessEmail,  List<VendorDocumentDetail> documents,  List<String> regions,  String? tradingName,  String? mobileNumber,  double? oldestWaitingHours,  DateTime? submittedAt)?  $default,) {final _that = this;
switch (_that) {
case _VendorVerificationDetail() when $default != null:
return $default(_that.id,_that.legalBusinessName,_that.tradeLicenceNumber,_that.licenceExpiryDate,_that.businessAddress,_that.contactPersonName,_that.businessEmail,_that.documents,_that.regions,_that.tradingName,_that.mobileNumber,_that.oldestWaitingHours,_that.submittedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VendorVerificationDetail implements VendorVerificationDetail {
  const _VendorVerificationDetail({required this.id, required this.legalBusinessName, required this.tradeLicenceNumber, @JsonKey(fromJson: _dateFromJson) required this.licenceExpiryDate, required this.businessAddress, required this.contactPersonName, required this.businessEmail, final  List<VendorDocumentDetail> documents = const <VendorDocumentDetail>[], final  List<String> regions = const <String>[], this.tradingName, this.mobileNumber, this.oldestWaitingHours, this.submittedAt}): _documents = documents,_regions = regions;
  factory _VendorVerificationDetail.fromJson(Map<String, dynamic> json) => _$VendorVerificationDetailFromJson(json);

@override final  String id;
@override final  String legalBusinessName;
@override final  String tradeLicenceNumber;
@override@JsonKey(fromJson: _dateFromJson) final  DateTime licenceExpiryDate;
@override final  String businessAddress;
@override final  String contactPersonName;
@override final  String businessEmail;
 final  List<VendorDocumentDetail> _documents;
@override@JsonKey() List<VendorDocumentDetail> get documents {
  if (_documents is EqualUnmodifiableListView) return _documents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_documents);
}

 final  List<String> _regions;
@override@JsonKey() List<String> get regions {
  if (_regions is EqualUnmodifiableListView) return _regions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_regions);
}

@override final  String? tradingName;
@override final  String? mobileNumber;
@override final  double? oldestWaitingHours;
@override final  DateTime? submittedAt;

/// Create a copy of VendorVerificationDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorVerificationDetailCopyWith<_VendorVerificationDetail> get copyWith => __$VendorVerificationDetailCopyWithImpl<_VendorVerificationDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VendorVerificationDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorVerificationDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.legalBusinessName, legalBusinessName) || other.legalBusinessName == legalBusinessName)&&(identical(other.tradeLicenceNumber, tradeLicenceNumber) || other.tradeLicenceNumber == tradeLicenceNumber)&&(identical(other.licenceExpiryDate, licenceExpiryDate) || other.licenceExpiryDate == licenceExpiryDate)&&(identical(other.businessAddress, businessAddress) || other.businessAddress == businessAddress)&&(identical(other.contactPersonName, contactPersonName) || other.contactPersonName == contactPersonName)&&(identical(other.businessEmail, businessEmail) || other.businessEmail == businessEmail)&&const DeepCollectionEquality().equals(other._documents, _documents)&&const DeepCollectionEquality().equals(other._regions, _regions)&&(identical(other.tradingName, tradingName) || other.tradingName == tradingName)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.oldestWaitingHours, oldestWaitingHours) || other.oldestWaitingHours == oldestWaitingHours)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,legalBusinessName,tradeLicenceNumber,licenceExpiryDate,businessAddress,contactPersonName,businessEmail,const DeepCollectionEquality().hash(_documents),const DeepCollectionEquality().hash(_regions),tradingName,mobileNumber,oldestWaitingHours,submittedAt);

@override
String toString() {
  return 'VendorVerificationDetail(id: $id, legalBusinessName: $legalBusinessName, tradeLicenceNumber: $tradeLicenceNumber, licenceExpiryDate: $licenceExpiryDate, businessAddress: $businessAddress, contactPersonName: $contactPersonName, businessEmail: $businessEmail, documents: $documents, regions: $regions, tradingName: $tradingName, mobileNumber: $mobileNumber, oldestWaitingHours: $oldestWaitingHours, submittedAt: $submittedAt)';
}


}

/// @nodoc
abstract mixin class _$VendorVerificationDetailCopyWith<$Res> implements $VendorVerificationDetailCopyWith<$Res> {
  factory _$VendorVerificationDetailCopyWith(_VendorVerificationDetail value, $Res Function(_VendorVerificationDetail) _then) = __$VendorVerificationDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String legalBusinessName, String tradeLicenceNumber,@JsonKey(fromJson: _dateFromJson) DateTime licenceExpiryDate, String businessAddress, String contactPersonName, String businessEmail, List<VendorDocumentDetail> documents, List<String> regions, String? tradingName, String? mobileNumber, double? oldestWaitingHours, DateTime? submittedAt
});




}
/// @nodoc
class __$VendorVerificationDetailCopyWithImpl<$Res>
    implements _$VendorVerificationDetailCopyWith<$Res> {
  __$VendorVerificationDetailCopyWithImpl(this._self, this._then);

  final _VendorVerificationDetail _self;
  final $Res Function(_VendorVerificationDetail) _then;

/// Create a copy of VendorVerificationDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? legalBusinessName = null,Object? tradeLicenceNumber = null,Object? licenceExpiryDate = null,Object? businessAddress = null,Object? contactPersonName = null,Object? businessEmail = null,Object? documents = null,Object? regions = null,Object? tradingName = freezed,Object? mobileNumber = freezed,Object? oldestWaitingHours = freezed,Object? submittedAt = freezed,}) {
  return _then(_VendorVerificationDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,legalBusinessName: null == legalBusinessName ? _self.legalBusinessName : legalBusinessName // ignore: cast_nullable_to_non_nullable
as String,tradeLicenceNumber: null == tradeLicenceNumber ? _self.tradeLicenceNumber : tradeLicenceNumber // ignore: cast_nullable_to_non_nullable
as String,licenceExpiryDate: null == licenceExpiryDate ? _self.licenceExpiryDate : licenceExpiryDate // ignore: cast_nullable_to_non_nullable
as DateTime,businessAddress: null == businessAddress ? _self.businessAddress : businessAddress // ignore: cast_nullable_to_non_nullable
as String,contactPersonName: null == contactPersonName ? _self.contactPersonName : contactPersonName // ignore: cast_nullable_to_non_nullable
as String,businessEmail: null == businessEmail ? _self.businessEmail : businessEmail // ignore: cast_nullable_to_non_nullable
as String,documents: null == documents ? _self._documents : documents // ignore: cast_nullable_to_non_nullable
as List<VendorDocumentDetail>,regions: null == regions ? _self._regions : regions // ignore: cast_nullable_to_non_nullable
as List<String>,tradingName: freezed == tradingName ? _self.tradingName : tradingName // ignore: cast_nullable_to_non_nullable
as String?,mobileNumber: freezed == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String?,oldestWaitingHours: freezed == oldestWaitingHours ? _self.oldestWaitingHours : oldestWaitingHours // ignore: cast_nullable_to_non_nullable
as double?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$VendorDocumentDetail {

 String get id; String get documentType; DateTime get uploadedAt; String? get fileName; String? get mimeType; int? get sizeBytes; DateTime? get expiryDate; bool get verified;
/// Create a copy of VendorDocumentDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorDocumentDetailCopyWith<VendorDocumentDetail> get copyWith => _$VendorDocumentDetailCopyWithImpl<VendorDocumentDetail>(this as VendorDocumentDetail, _$identity);

  /// Serializes this VendorDocumentDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorDocumentDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.verified, verified) || other.verified == verified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,documentType,uploadedAt,fileName,mimeType,sizeBytes,expiryDate,verified);

@override
String toString() {
  return 'VendorDocumentDetail(id: $id, documentType: $documentType, uploadedAt: $uploadedAt, fileName: $fileName, mimeType: $mimeType, sizeBytes: $sizeBytes, expiryDate: $expiryDate, verified: $verified)';
}


}

/// @nodoc
abstract mixin class $VendorDocumentDetailCopyWith<$Res>  {
  factory $VendorDocumentDetailCopyWith(VendorDocumentDetail value, $Res Function(VendorDocumentDetail) _then) = _$VendorDocumentDetailCopyWithImpl;
@useResult
$Res call({
 String id, String documentType, DateTime uploadedAt, String? fileName, String? mimeType, int? sizeBytes, DateTime? expiryDate, bool verified
});




}
/// @nodoc
class _$VendorDocumentDetailCopyWithImpl<$Res>
    implements $VendorDocumentDetailCopyWith<$Res> {
  _$VendorDocumentDetailCopyWithImpl(this._self, this._then);

  final VendorDocumentDetail _self;
  final $Res Function(VendorDocumentDetail) _then;

/// Create a copy of VendorDocumentDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? documentType = null,Object? uploadedAt = null,Object? fileName = freezed,Object? mimeType = freezed,Object? sizeBytes = freezed,Object? expiryDate = freezed,Object? verified = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as String,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [VendorDocumentDetail].
extension VendorDocumentDetailPatterns on VendorDocumentDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorDocumentDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorDocumentDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorDocumentDetail value)  $default,){
final _that = this;
switch (_that) {
case _VendorDocumentDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorDocumentDetail value)?  $default,){
final _that = this;
switch (_that) {
case _VendorDocumentDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String documentType,  DateTime uploadedAt,  String? fileName,  String? mimeType,  int? sizeBytes,  DateTime? expiryDate,  bool verified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorDocumentDetail() when $default != null:
return $default(_that.id,_that.documentType,_that.uploadedAt,_that.fileName,_that.mimeType,_that.sizeBytes,_that.expiryDate,_that.verified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String documentType,  DateTime uploadedAt,  String? fileName,  String? mimeType,  int? sizeBytes,  DateTime? expiryDate,  bool verified)  $default,) {final _that = this;
switch (_that) {
case _VendorDocumentDetail():
return $default(_that.id,_that.documentType,_that.uploadedAt,_that.fileName,_that.mimeType,_that.sizeBytes,_that.expiryDate,_that.verified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String documentType,  DateTime uploadedAt,  String? fileName,  String? mimeType,  int? sizeBytes,  DateTime? expiryDate,  bool verified)?  $default,) {final _that = this;
switch (_that) {
case _VendorDocumentDetail() when $default != null:
return $default(_that.id,_that.documentType,_that.uploadedAt,_that.fileName,_that.mimeType,_that.sizeBytes,_that.expiryDate,_that.verified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VendorDocumentDetail implements VendorDocumentDetail {
  const _VendorDocumentDetail({required this.id, required this.documentType, required this.uploadedAt, this.fileName, this.mimeType, this.sizeBytes, this.expiryDate, this.verified = false});
  factory _VendorDocumentDetail.fromJson(Map<String, dynamic> json) => _$VendorDocumentDetailFromJson(json);

@override final  String id;
@override final  String documentType;
@override final  DateTime uploadedAt;
@override final  String? fileName;
@override final  String? mimeType;
@override final  int? sizeBytes;
@override final  DateTime? expiryDate;
@override@JsonKey() final  bool verified;

/// Create a copy of VendorDocumentDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorDocumentDetailCopyWith<_VendorDocumentDetail> get copyWith => __$VendorDocumentDetailCopyWithImpl<_VendorDocumentDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VendorDocumentDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorDocumentDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.verified, verified) || other.verified == verified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,documentType,uploadedAt,fileName,mimeType,sizeBytes,expiryDate,verified);

@override
String toString() {
  return 'VendorDocumentDetail(id: $id, documentType: $documentType, uploadedAt: $uploadedAt, fileName: $fileName, mimeType: $mimeType, sizeBytes: $sizeBytes, expiryDate: $expiryDate, verified: $verified)';
}


}

/// @nodoc
abstract mixin class _$VendorDocumentDetailCopyWith<$Res> implements $VendorDocumentDetailCopyWith<$Res> {
  factory _$VendorDocumentDetailCopyWith(_VendorDocumentDetail value, $Res Function(_VendorDocumentDetail) _then) = __$VendorDocumentDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String documentType, DateTime uploadedAt, String? fileName, String? mimeType, int? sizeBytes, DateTime? expiryDate, bool verified
});




}
/// @nodoc
class __$VendorDocumentDetailCopyWithImpl<$Res>
    implements _$VendorDocumentDetailCopyWith<$Res> {
  __$VendorDocumentDetailCopyWithImpl(this._self, this._then);

  final _VendorDocumentDetail _self;
  final $Res Function(_VendorDocumentDetail) _then;

/// Create a copy of VendorDocumentDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? documentType = null,Object? uploadedAt = null,Object? fileName = freezed,Object? mimeType = freezed,Object? sizeBytes = freezed,Object? expiryDate = freezed,Object? verified = null,}) {
  return _then(_VendorDocumentDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as String,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
