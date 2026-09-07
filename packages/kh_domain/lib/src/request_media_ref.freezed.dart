// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_media_ref.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RequestMediaRef {

 String get id; String get key; String get contentType; int get displayOrder; String? get thumbnailUrl; String? get displayUrl;
/// Create a copy of RequestMediaRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestMediaRefCopyWith<RequestMediaRef> get copyWith => _$RequestMediaRefCopyWithImpl<RequestMediaRef>(this as RequestMediaRef, _$identity);

  /// Serializes this RequestMediaRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestMediaRef&&(identical(other.id, id) || other.id == id)&&(identical(other.key, key) || other.key == key)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.displayUrl, displayUrl) || other.displayUrl == displayUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,key,contentType,displayOrder,thumbnailUrl,displayUrl);

@override
String toString() {
  return 'RequestMediaRef(id: $id, key: $key, contentType: $contentType, displayOrder: $displayOrder, thumbnailUrl: $thumbnailUrl, displayUrl: $displayUrl)';
}


}

/// @nodoc
abstract mixin class $RequestMediaRefCopyWith<$Res>  {
  factory $RequestMediaRefCopyWith(RequestMediaRef value, $Res Function(RequestMediaRef) _then) = _$RequestMediaRefCopyWithImpl;
@useResult
$Res call({
 String id, String key, String contentType, int displayOrder, String? thumbnailUrl, String? displayUrl
});




}
/// @nodoc
class _$RequestMediaRefCopyWithImpl<$Res>
    implements $RequestMediaRefCopyWith<$Res> {
  _$RequestMediaRefCopyWithImpl(this._self, this._then);

  final RequestMediaRef _self;
  final $Res Function(RequestMediaRef) _then;

/// Create a copy of RequestMediaRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? key = null,Object? contentType = null,Object? displayOrder = null,Object? thumbnailUrl = freezed,Object? displayUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,displayUrl: freezed == displayUrl ? _self.displayUrl : displayUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestMediaRef].
extension RequestMediaRefPatterns on RequestMediaRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestMediaRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestMediaRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestMediaRef value)  $default,){
final _that = this;
switch (_that) {
case _RequestMediaRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestMediaRef value)?  $default,){
final _that = this;
switch (_that) {
case _RequestMediaRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String key,  String contentType,  int displayOrder,  String? thumbnailUrl,  String? displayUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestMediaRef() when $default != null:
return $default(_that.id,_that.key,_that.contentType,_that.displayOrder,_that.thumbnailUrl,_that.displayUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String key,  String contentType,  int displayOrder,  String? thumbnailUrl,  String? displayUrl)  $default,) {final _that = this;
switch (_that) {
case _RequestMediaRef():
return $default(_that.id,_that.key,_that.contentType,_that.displayOrder,_that.thumbnailUrl,_that.displayUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String key,  String contentType,  int displayOrder,  String? thumbnailUrl,  String? displayUrl)?  $default,) {final _that = this;
switch (_that) {
case _RequestMediaRef() when $default != null:
return $default(_that.id,_that.key,_that.contentType,_that.displayOrder,_that.thumbnailUrl,_that.displayUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RequestMediaRef implements RequestMediaRef {
  const _RequestMediaRef({this.id = '', this.key = '', this.contentType = 'image/jpeg', this.displayOrder = 0, this.thumbnailUrl, this.displayUrl});
  factory _RequestMediaRef.fromJson(Map<String, dynamic> json) => _$RequestMediaRefFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String key;
@override@JsonKey() final  String contentType;
@override@JsonKey() final  int displayOrder;
@override final  String? thumbnailUrl;
@override final  String? displayUrl;

/// Create a copy of RequestMediaRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestMediaRefCopyWith<_RequestMediaRef> get copyWith => __$RequestMediaRefCopyWithImpl<_RequestMediaRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestMediaRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestMediaRef&&(identical(other.id, id) || other.id == id)&&(identical(other.key, key) || other.key == key)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.displayUrl, displayUrl) || other.displayUrl == displayUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,key,contentType,displayOrder,thumbnailUrl,displayUrl);

@override
String toString() {
  return 'RequestMediaRef(id: $id, key: $key, contentType: $contentType, displayOrder: $displayOrder, thumbnailUrl: $thumbnailUrl, displayUrl: $displayUrl)';
}


}

/// @nodoc
abstract mixin class _$RequestMediaRefCopyWith<$Res> implements $RequestMediaRefCopyWith<$Res> {
  factory _$RequestMediaRefCopyWith(_RequestMediaRef value, $Res Function(_RequestMediaRef) _then) = __$RequestMediaRefCopyWithImpl;
@override @useResult
$Res call({
 String id, String key, String contentType, int displayOrder, String? thumbnailUrl, String? displayUrl
});




}
/// @nodoc
class __$RequestMediaRefCopyWithImpl<$Res>
    implements _$RequestMediaRefCopyWith<$Res> {
  __$RequestMediaRefCopyWithImpl(this._self, this._then);

  final _RequestMediaRef _self;
  final $Res Function(_RequestMediaRef) _then;

/// Create a copy of RequestMediaRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? key = null,Object? contentType = null,Object? displayOrder = null,Object? thumbnailUrl = freezed,Object? displayUrl = freezed,}) {
  return _then(_RequestMediaRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,displayOrder: null == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,displayUrl: freezed == displayUrl ? _self.displayUrl : displayUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
