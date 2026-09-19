// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReviewDto {

 String get id; String get connectionId; String get authorType;// CUSTOMER | VENDOR
 String? get authorDisplayName; int get rating; String? get comment; String get state; ReviewResponseDto? get vendorResponse; DateTime get editableUntil; DateTime get createdAt; DateTime? get publishedAt;
/// Create a copy of ReviewDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewDtoCopyWith<ReviewDto> get copyWith => _$ReviewDtoCopyWithImpl<ReviewDto>(this as ReviewDto, _$identity);

  /// Serializes this ReviewDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewDto&&(identical(other.id, id) || other.id == id)&&(identical(other.connectionId, connectionId) || other.connectionId == connectionId)&&(identical(other.authorType, authorType) || other.authorType == authorType)&&(identical(other.authorDisplayName, authorDisplayName) || other.authorDisplayName == authorDisplayName)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.state, state) || other.state == state)&&(identical(other.vendorResponse, vendorResponse) || other.vendorResponse == vendorResponse)&&(identical(other.editableUntil, editableUntil) || other.editableUntil == editableUntil)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,connectionId,authorType,authorDisplayName,rating,comment,state,vendorResponse,editableUntil,createdAt,publishedAt);

@override
String toString() {
  return 'ReviewDto(id: $id, connectionId: $connectionId, authorType: $authorType, authorDisplayName: $authorDisplayName, rating: $rating, comment: $comment, state: $state, vendorResponse: $vendorResponse, editableUntil: $editableUntil, createdAt: $createdAt, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class $ReviewDtoCopyWith<$Res>  {
  factory $ReviewDtoCopyWith(ReviewDto value, $Res Function(ReviewDto) _then) = _$ReviewDtoCopyWithImpl;
@useResult
$Res call({
 String id, String connectionId, String authorType, String? authorDisplayName, int rating, String? comment, String state, ReviewResponseDto? vendorResponse, DateTime editableUntil, DateTime createdAt, DateTime? publishedAt
});


$ReviewResponseDtoCopyWith<$Res>? get vendorResponse;

}
/// @nodoc
class _$ReviewDtoCopyWithImpl<$Res>
    implements $ReviewDtoCopyWith<$Res> {
  _$ReviewDtoCopyWithImpl(this._self, this._then);

  final ReviewDto _self;
  final $Res Function(ReviewDto) _then;

/// Create a copy of ReviewDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? connectionId = null,Object? authorType = null,Object? authorDisplayName = freezed,Object? rating = null,Object? comment = freezed,Object? state = null,Object? vendorResponse = freezed,Object? editableUntil = null,Object? createdAt = null,Object? publishedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,connectionId: null == connectionId ? _self.connectionId : connectionId // ignore: cast_nullable_to_non_nullable
as String,authorType: null == authorType ? _self.authorType : authorType // ignore: cast_nullable_to_non_nullable
as String,authorDisplayName: freezed == authorDisplayName ? _self.authorDisplayName : authorDisplayName // ignore: cast_nullable_to_non_nullable
as String?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,vendorResponse: freezed == vendorResponse ? _self.vendorResponse : vendorResponse // ignore: cast_nullable_to_non_nullable
as ReviewResponseDto?,editableUntil: null == editableUntil ? _self.editableUntil : editableUntil // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of ReviewDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReviewResponseDtoCopyWith<$Res>? get vendorResponse {
    if (_self.vendorResponse == null) {
    return null;
  }

  return $ReviewResponseDtoCopyWith<$Res>(_self.vendorResponse!, (value) {
    return _then(_self.copyWith(vendorResponse: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReviewDto].
extension ReviewDtoPatterns on ReviewDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewDto value)  $default,){
final _that = this;
switch (_that) {
case _ReviewDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewDto value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String connectionId,  String authorType,  String? authorDisplayName,  int rating,  String? comment,  String state,  ReviewResponseDto? vendorResponse,  DateTime editableUntil,  DateTime createdAt,  DateTime? publishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewDto() when $default != null:
return $default(_that.id,_that.connectionId,_that.authorType,_that.authorDisplayName,_that.rating,_that.comment,_that.state,_that.vendorResponse,_that.editableUntil,_that.createdAt,_that.publishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String connectionId,  String authorType,  String? authorDisplayName,  int rating,  String? comment,  String state,  ReviewResponseDto? vendorResponse,  DateTime editableUntil,  DateTime createdAt,  DateTime? publishedAt)  $default,) {final _that = this;
switch (_that) {
case _ReviewDto():
return $default(_that.id,_that.connectionId,_that.authorType,_that.authorDisplayName,_that.rating,_that.comment,_that.state,_that.vendorResponse,_that.editableUntil,_that.createdAt,_that.publishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String connectionId,  String authorType,  String? authorDisplayName,  int rating,  String? comment,  String state,  ReviewResponseDto? vendorResponse,  DateTime editableUntil,  DateTime createdAt,  DateTime? publishedAt)?  $default,) {final _that = this;
switch (_that) {
case _ReviewDto() when $default != null:
return $default(_that.id,_that.connectionId,_that.authorType,_that.authorDisplayName,_that.rating,_that.comment,_that.state,_that.vendorResponse,_that.editableUntil,_that.createdAt,_that.publishedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReviewDto implements ReviewDto {
  const _ReviewDto({required this.id, required this.connectionId, required this.authorType, this.authorDisplayName, required this.rating, this.comment, required this.state, this.vendorResponse, required this.editableUntil, required this.createdAt, this.publishedAt});
  factory _ReviewDto.fromJson(Map<String, dynamic> json) => _$ReviewDtoFromJson(json);

@override final  String id;
@override final  String connectionId;
@override final  String authorType;
// CUSTOMER | VENDOR
@override final  String? authorDisplayName;
@override final  int rating;
@override final  String? comment;
@override final  String state;
@override final  ReviewResponseDto? vendorResponse;
@override final  DateTime editableUntil;
@override final  DateTime createdAt;
@override final  DateTime? publishedAt;

/// Create a copy of ReviewDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewDtoCopyWith<_ReviewDto> get copyWith => __$ReviewDtoCopyWithImpl<_ReviewDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewDto&&(identical(other.id, id) || other.id == id)&&(identical(other.connectionId, connectionId) || other.connectionId == connectionId)&&(identical(other.authorType, authorType) || other.authorType == authorType)&&(identical(other.authorDisplayName, authorDisplayName) || other.authorDisplayName == authorDisplayName)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.state, state) || other.state == state)&&(identical(other.vendorResponse, vendorResponse) || other.vendorResponse == vendorResponse)&&(identical(other.editableUntil, editableUntil) || other.editableUntil == editableUntil)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,connectionId,authorType,authorDisplayName,rating,comment,state,vendorResponse,editableUntil,createdAt,publishedAt);

@override
String toString() {
  return 'ReviewDto(id: $id, connectionId: $connectionId, authorType: $authorType, authorDisplayName: $authorDisplayName, rating: $rating, comment: $comment, state: $state, vendorResponse: $vendorResponse, editableUntil: $editableUntil, createdAt: $createdAt, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class _$ReviewDtoCopyWith<$Res> implements $ReviewDtoCopyWith<$Res> {
  factory _$ReviewDtoCopyWith(_ReviewDto value, $Res Function(_ReviewDto) _then) = __$ReviewDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String connectionId, String authorType, String? authorDisplayName, int rating, String? comment, String state, ReviewResponseDto? vendorResponse, DateTime editableUntil, DateTime createdAt, DateTime? publishedAt
});


@override $ReviewResponseDtoCopyWith<$Res>? get vendorResponse;

}
/// @nodoc
class __$ReviewDtoCopyWithImpl<$Res>
    implements _$ReviewDtoCopyWith<$Res> {
  __$ReviewDtoCopyWithImpl(this._self, this._then);

  final _ReviewDto _self;
  final $Res Function(_ReviewDto) _then;

/// Create a copy of ReviewDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? connectionId = null,Object? authorType = null,Object? authorDisplayName = freezed,Object? rating = null,Object? comment = freezed,Object? state = null,Object? vendorResponse = freezed,Object? editableUntil = null,Object? createdAt = null,Object? publishedAt = freezed,}) {
  return _then(_ReviewDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,connectionId: null == connectionId ? _self.connectionId : connectionId // ignore: cast_nullable_to_non_nullable
as String,authorType: null == authorType ? _self.authorType : authorType // ignore: cast_nullable_to_non_nullable
as String,authorDisplayName: freezed == authorDisplayName ? _self.authorDisplayName : authorDisplayName // ignore: cast_nullable_to_non_nullable
as String?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,vendorResponse: freezed == vendorResponse ? _self.vendorResponse : vendorResponse // ignore: cast_nullable_to_non_nullable
as ReviewResponseDto?,editableUntil: null == editableUntil ? _self.editableUntil : editableUntil // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of ReviewDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReviewResponseDtoCopyWith<$Res>? get vendorResponse {
    if (_self.vendorResponse == null) {
    return null;
  }

  return $ReviewResponseDtoCopyWith<$Res>(_self.vendorResponse!, (value) {
    return _then(_self.copyWith(vendorResponse: value));
  });
}
}


/// @nodoc
mixin _$ReviewResponseDto {

 String get text; String get state;
/// Create a copy of ReviewResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewResponseDtoCopyWith<ReviewResponseDto> get copyWith => _$ReviewResponseDtoCopyWithImpl<ReviewResponseDto>(this as ReviewResponseDto, _$identity);

  /// Serializes this ReviewResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewResponseDto&&(identical(other.text, text) || other.text == text)&&(identical(other.state, state) || other.state == state));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,state);

@override
String toString() {
  return 'ReviewResponseDto(text: $text, state: $state)';
}


}

/// @nodoc
abstract mixin class $ReviewResponseDtoCopyWith<$Res>  {
  factory $ReviewResponseDtoCopyWith(ReviewResponseDto value, $Res Function(ReviewResponseDto) _then) = _$ReviewResponseDtoCopyWithImpl;
@useResult
$Res call({
 String text, String state
});




}
/// @nodoc
class _$ReviewResponseDtoCopyWithImpl<$Res>
    implements $ReviewResponseDtoCopyWith<$Res> {
  _$ReviewResponseDtoCopyWithImpl(this._self, this._then);

  final ReviewResponseDto _self;
  final $Res Function(ReviewResponseDto) _then;

/// Create a copy of ReviewResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? state = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReviewResponseDto].
extension ReviewResponseDtoPatterns on ReviewResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _ReviewResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  String state)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewResponseDto() when $default != null:
return $default(_that.text,_that.state);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  String state)  $default,) {final _that = this;
switch (_that) {
case _ReviewResponseDto():
return $default(_that.text,_that.state);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  String state)?  $default,) {final _that = this;
switch (_that) {
case _ReviewResponseDto() when $default != null:
return $default(_that.text,_that.state);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReviewResponseDto implements ReviewResponseDto {
  const _ReviewResponseDto({required this.text, required this.state});
  factory _ReviewResponseDto.fromJson(Map<String, dynamic> json) => _$ReviewResponseDtoFromJson(json);

@override final  String text;
@override final  String state;

/// Create a copy of ReviewResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewResponseDtoCopyWith<_ReviewResponseDto> get copyWith => __$ReviewResponseDtoCopyWithImpl<_ReviewResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewResponseDto&&(identical(other.text, text) || other.text == text)&&(identical(other.state, state) || other.state == state));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,state);

@override
String toString() {
  return 'ReviewResponseDto(text: $text, state: $state)';
}


}

/// @nodoc
abstract mixin class _$ReviewResponseDtoCopyWith<$Res> implements $ReviewResponseDtoCopyWith<$Res> {
  factory _$ReviewResponseDtoCopyWith(_ReviewResponseDto value, $Res Function(_ReviewResponseDto) _then) = __$ReviewResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String text, String state
});




}
/// @nodoc
class __$ReviewResponseDtoCopyWithImpl<$Res>
    implements _$ReviewResponseDtoCopyWith<$Res> {
  __$ReviewResponseDtoCopyWithImpl(this._self, this._then);

  final _ReviewResponseDto _self;
  final $Res Function(_ReviewResponseDto) _then;

/// Create a copy of ReviewResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? state = null,}) {
  return _then(_ReviewResponseDto(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
