// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_url_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DocumentUrlResponse {

 String get url; DateTime get expiresAt;
/// Create a copy of DocumentUrlResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentUrlResponseCopyWith<DocumentUrlResponse> get copyWith => _$DocumentUrlResponseCopyWithImpl<DocumentUrlResponse>(this as DocumentUrlResponse, _$identity);

  /// Serializes this DocumentUrlResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentUrlResponse&&(identical(other.url, url) || other.url == url)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,expiresAt);

@override
String toString() {
  return 'DocumentUrlResponse(url: $url, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $DocumentUrlResponseCopyWith<$Res>  {
  factory $DocumentUrlResponseCopyWith(DocumentUrlResponse value, $Res Function(DocumentUrlResponse) _then) = _$DocumentUrlResponseCopyWithImpl;
@useResult
$Res call({
 String url, DateTime expiresAt
});




}
/// @nodoc
class _$DocumentUrlResponseCopyWithImpl<$Res>
    implements $DocumentUrlResponseCopyWith<$Res> {
  _$DocumentUrlResponseCopyWithImpl(this._self, this._then);

  final DocumentUrlResponse _self;
  final $Res Function(DocumentUrlResponse) _then;

/// Create a copy of DocumentUrlResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? expiresAt = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentUrlResponse].
extension DocumentUrlResponsePatterns on DocumentUrlResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentUrlResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentUrlResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentUrlResponse value)  $default,){
final _that = this;
switch (_that) {
case _DocumentUrlResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentUrlResponse value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentUrlResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentUrlResponse() when $default != null:
return $default(_that.url,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _DocumentUrlResponse():
return $default(_that.url,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _DocumentUrlResponse() when $default != null:
return $default(_that.url,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentUrlResponse implements DocumentUrlResponse {
  const _DocumentUrlResponse({required this.url, required this.expiresAt});
  factory _DocumentUrlResponse.fromJson(Map<String, dynamic> json) => _$DocumentUrlResponseFromJson(json);

@override final  String url;
@override final  DateTime expiresAt;

/// Create a copy of DocumentUrlResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentUrlResponseCopyWith<_DocumentUrlResponse> get copyWith => __$DocumentUrlResponseCopyWithImpl<_DocumentUrlResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentUrlResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentUrlResponse&&(identical(other.url, url) || other.url == url)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,expiresAt);

@override
String toString() {
  return 'DocumentUrlResponse(url: $url, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$DocumentUrlResponseCopyWith<$Res> implements $DocumentUrlResponseCopyWith<$Res> {
  factory _$DocumentUrlResponseCopyWith(_DocumentUrlResponse value, $Res Function(_DocumentUrlResponse) _then) = __$DocumentUrlResponseCopyWithImpl;
@override @useResult
$Res call({
 String url, DateTime expiresAt
});




}
/// @nodoc
class __$DocumentUrlResponseCopyWithImpl<$Res>
    implements _$DocumentUrlResponseCopyWith<$Res> {
  __$DocumentUrlResponseCopyWithImpl(this._self, this._then);

  final _DocumentUrlResponse _self;
  final $Res Function(_DocumentUrlResponse) _then;

/// Create a copy of DocumentUrlResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? expiresAt = null,}) {
  return _then(_DocumentUrlResponse(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
