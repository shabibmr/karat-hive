// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vendor_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VendorDocument {

 String get id;@_VendorDocumentTypeConverter() VendorDocumentType get documentType; bool get verified; DateTime get uploadedAt; DateTime? get expiryDate;
/// Create a copy of VendorDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorDocumentCopyWith<VendorDocument> get copyWith => _$VendorDocumentCopyWithImpl<VendorDocument>(this as VendorDocument, _$identity);

  /// Serializes this VendorDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,documentType,verified,uploadedAt,expiryDate);

@override
String toString() {
  return 'VendorDocument(id: $id, documentType: $documentType, verified: $verified, uploadedAt: $uploadedAt, expiryDate: $expiryDate)';
}


}

/// @nodoc
abstract mixin class $VendorDocumentCopyWith<$Res>  {
  factory $VendorDocumentCopyWith(VendorDocument value, $Res Function(VendorDocument) _then) = _$VendorDocumentCopyWithImpl;
@useResult
$Res call({
 String id,@_VendorDocumentTypeConverter() VendorDocumentType documentType, bool verified, DateTime uploadedAt, DateTime? expiryDate
});




}
/// @nodoc
class _$VendorDocumentCopyWithImpl<$Res>
    implements $VendorDocumentCopyWith<$Res> {
  _$VendorDocumentCopyWithImpl(this._self, this._then);

  final VendorDocument _self;
  final $Res Function(VendorDocument) _then;

/// Create a copy of VendorDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? documentType = null,Object? verified = null,Object? uploadedAt = null,Object? expiryDate = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as VendorDocumentType,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [VendorDocument].
extension VendorDocumentPatterns on VendorDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorDocument value)  $default,){
final _that = this;
switch (_that) {
case _VendorDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorDocument value)?  $default,){
final _that = this;
switch (_that) {
case _VendorDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @_VendorDocumentTypeConverter()  VendorDocumentType documentType,  bool verified,  DateTime uploadedAt,  DateTime? expiryDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorDocument() when $default != null:
return $default(_that.id,_that.documentType,_that.verified,_that.uploadedAt,_that.expiryDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @_VendorDocumentTypeConverter()  VendorDocumentType documentType,  bool verified,  DateTime uploadedAt,  DateTime? expiryDate)  $default,) {final _that = this;
switch (_that) {
case _VendorDocument():
return $default(_that.id,_that.documentType,_that.verified,_that.uploadedAt,_that.expiryDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @_VendorDocumentTypeConverter()  VendorDocumentType documentType,  bool verified,  DateTime uploadedAt,  DateTime? expiryDate)?  $default,) {final _that = this;
switch (_that) {
case _VendorDocument() when $default != null:
return $default(_that.id,_that.documentType,_that.verified,_that.uploadedAt,_that.expiryDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VendorDocument implements VendorDocument {
  const _VendorDocument({required this.id, @_VendorDocumentTypeConverter() required this.documentType, required this.verified, required this.uploadedAt, this.expiryDate});
  factory _VendorDocument.fromJson(Map<String, dynamic> json) => _$VendorDocumentFromJson(json);

@override final  String id;
@override@_VendorDocumentTypeConverter() final  VendorDocumentType documentType;
@override final  bool verified;
@override final  DateTime uploadedAt;
@override final  DateTime? expiryDate;

/// Create a copy of VendorDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorDocumentCopyWith<_VendorDocument> get copyWith => __$VendorDocumentCopyWithImpl<_VendorDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VendorDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,documentType,verified,uploadedAt,expiryDate);

@override
String toString() {
  return 'VendorDocument(id: $id, documentType: $documentType, verified: $verified, uploadedAt: $uploadedAt, expiryDate: $expiryDate)';
}


}

/// @nodoc
abstract mixin class _$VendorDocumentCopyWith<$Res> implements $VendorDocumentCopyWith<$Res> {
  factory _$VendorDocumentCopyWith(_VendorDocument value, $Res Function(_VendorDocument) _then) = __$VendorDocumentCopyWithImpl;
@override @useResult
$Res call({
 String id,@_VendorDocumentTypeConverter() VendorDocumentType documentType, bool verified, DateTime uploadedAt, DateTime? expiryDate
});




}
/// @nodoc
class __$VendorDocumentCopyWithImpl<$Res>
    implements _$VendorDocumentCopyWith<$Res> {
  __$VendorDocumentCopyWithImpl(this._self, this._then);

  final _VendorDocument _self;
  final $Res Function(_VendorDocument) _then;

/// Create a copy of VendorDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? documentType = null,Object? verified = null,Object? uploadedAt = null,Object? expiryDate = freezed,}) {
  return _then(_VendorDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as VendorDocumentType,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
