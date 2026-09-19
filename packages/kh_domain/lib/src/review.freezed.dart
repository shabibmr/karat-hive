// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReviewVendorResponse {

 String get text;@_ReviewStateConverter() ReviewState get state;
/// Create a copy of ReviewVendorResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewVendorResponseCopyWith<ReviewVendorResponse> get copyWith => _$ReviewVendorResponseCopyWithImpl<ReviewVendorResponse>(this as ReviewVendorResponse, _$identity);

  /// Serializes this ReviewVendorResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewVendorResponse&&(identical(other.text, text) || other.text == text)&&(identical(other.state, state) || other.state == state));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,state);

@override
String toString() {
  return 'ReviewVendorResponse(text: $text, state: $state)';
}


}

/// @nodoc
abstract mixin class $ReviewVendorResponseCopyWith<$Res>  {
  factory $ReviewVendorResponseCopyWith(ReviewVendorResponse value, $Res Function(ReviewVendorResponse) _then) = _$ReviewVendorResponseCopyWithImpl;
@useResult
$Res call({
 String text,@_ReviewStateConverter() ReviewState state
});




}
/// @nodoc
class _$ReviewVendorResponseCopyWithImpl<$Res>
    implements $ReviewVendorResponseCopyWith<$Res> {
  _$ReviewVendorResponseCopyWithImpl(this._self, this._then);

  final ReviewVendorResponse _self;
  final $Res Function(ReviewVendorResponse) _then;

/// Create a copy of ReviewVendorResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? state = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ReviewState,
  ));
}

}


/// Adds pattern-matching-related methods to [ReviewVendorResponse].
extension ReviewVendorResponsePatterns on ReviewVendorResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewVendorResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewVendorResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewVendorResponse value)  $default,){
final _that = this;
switch (_that) {
case _ReviewVendorResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewVendorResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewVendorResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text, @_ReviewStateConverter()  ReviewState state)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewVendorResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text, @_ReviewStateConverter()  ReviewState state)  $default,) {final _that = this;
switch (_that) {
case _ReviewVendorResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text, @_ReviewStateConverter()  ReviewState state)?  $default,) {final _that = this;
switch (_that) {
case _ReviewVendorResponse() when $default != null:
return $default(_that.text,_that.state);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReviewVendorResponse implements ReviewVendorResponse {
  const _ReviewVendorResponse({required this.text, @_ReviewStateConverter() required this.state});
  factory _ReviewVendorResponse.fromJson(Map<String, dynamic> json) => _$ReviewVendorResponseFromJson(json);

@override final  String text;
@override@_ReviewStateConverter() final  ReviewState state;

/// Create a copy of ReviewVendorResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewVendorResponseCopyWith<_ReviewVendorResponse> get copyWith => __$ReviewVendorResponseCopyWithImpl<_ReviewVendorResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewVendorResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewVendorResponse&&(identical(other.text, text) || other.text == text)&&(identical(other.state, state) || other.state == state));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,state);

@override
String toString() {
  return 'ReviewVendorResponse(text: $text, state: $state)';
}


}

/// @nodoc
abstract mixin class _$ReviewVendorResponseCopyWith<$Res> implements $ReviewVendorResponseCopyWith<$Res> {
  factory _$ReviewVendorResponseCopyWith(_ReviewVendorResponse value, $Res Function(_ReviewVendorResponse) _then) = __$ReviewVendorResponseCopyWithImpl;
@override @useResult
$Res call({
 String text,@_ReviewStateConverter() ReviewState state
});




}
/// @nodoc
class __$ReviewVendorResponseCopyWithImpl<$Res>
    implements _$ReviewVendorResponseCopyWith<$Res> {
  __$ReviewVendorResponseCopyWithImpl(this._self, this._then);

  final _ReviewVendorResponse _self;
  final $Res Function(_ReviewVendorResponse) _then;

/// Create a copy of ReviewVendorResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? state = null,}) {
  return _then(_ReviewVendorResponse(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ReviewState,
  ));
}


}


/// @nodoc
mixin _$Review {

 String get id; String get connectionId;@_PartyRoleConverter() PartyRole get authorType; int get rating;@_ReviewStateConverter() ReviewState get state; DateTime get editableUntil; DateTime get createdAt; String? get comment; ReviewVendorResponse? get vendorResponse; DateTime? get publishedAt; String? get authorDisplayName;
/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewCopyWith<Review> get copyWith => _$ReviewCopyWithImpl<Review>(this as Review, _$identity);

  /// Serializes this Review to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Review&&(identical(other.id, id) || other.id == id)&&(identical(other.connectionId, connectionId) || other.connectionId == connectionId)&&(identical(other.authorType, authorType) || other.authorType == authorType)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.state, state) || other.state == state)&&(identical(other.editableUntil, editableUntil) || other.editableUntil == editableUntil)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.vendorResponse, vendorResponse) || other.vendorResponse == vendorResponse)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.authorDisplayName, authorDisplayName) || other.authorDisplayName == authorDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,connectionId,authorType,rating,state,editableUntil,createdAt,comment,vendorResponse,publishedAt,authorDisplayName);

@override
String toString() {
  return 'Review(id: $id, connectionId: $connectionId, authorType: $authorType, rating: $rating, state: $state, editableUntil: $editableUntil, createdAt: $createdAt, comment: $comment, vendorResponse: $vendorResponse, publishedAt: $publishedAt, authorDisplayName: $authorDisplayName)';
}


}

/// @nodoc
abstract mixin class $ReviewCopyWith<$Res>  {
  factory $ReviewCopyWith(Review value, $Res Function(Review) _then) = _$ReviewCopyWithImpl;
@useResult
$Res call({
 String id, String connectionId,@_PartyRoleConverter() PartyRole authorType, int rating,@_ReviewStateConverter() ReviewState state, DateTime editableUntil, DateTime createdAt, String? comment, ReviewVendorResponse? vendorResponse, DateTime? publishedAt, String? authorDisplayName
});


$ReviewVendorResponseCopyWith<$Res>? get vendorResponse;

}
/// @nodoc
class _$ReviewCopyWithImpl<$Res>
    implements $ReviewCopyWith<$Res> {
  _$ReviewCopyWithImpl(this._self, this._then);

  final Review _self;
  final $Res Function(Review) _then;

/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? connectionId = null,Object? authorType = null,Object? rating = null,Object? state = null,Object? editableUntil = null,Object? createdAt = null,Object? comment = freezed,Object? vendorResponse = freezed,Object? publishedAt = freezed,Object? authorDisplayName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,connectionId: null == connectionId ? _self.connectionId : connectionId // ignore: cast_nullable_to_non_nullable
as String,authorType: null == authorType ? _self.authorType : authorType // ignore: cast_nullable_to_non_nullable
as PartyRole,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ReviewState,editableUntil: null == editableUntil ? _self.editableUntil : editableUntil // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,vendorResponse: freezed == vendorResponse ? _self.vendorResponse : vendorResponse // ignore: cast_nullable_to_non_nullable
as ReviewVendorResponse?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,authorDisplayName: freezed == authorDisplayName ? _self.authorDisplayName : authorDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReviewVendorResponseCopyWith<$Res>? get vendorResponse {
    if (_self.vendorResponse == null) {
    return null;
  }

  return $ReviewVendorResponseCopyWith<$Res>(_self.vendorResponse!, (value) {
    return _then(_self.copyWith(vendorResponse: value));
  });
}
}


/// Adds pattern-matching-related methods to [Review].
extension ReviewPatterns on Review {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Review value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Review() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Review value)  $default,){
final _that = this;
switch (_that) {
case _Review():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Review value)?  $default,){
final _that = this;
switch (_that) {
case _Review() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String connectionId, @_PartyRoleConverter()  PartyRole authorType,  int rating, @_ReviewStateConverter()  ReviewState state,  DateTime editableUntil,  DateTime createdAt,  String? comment,  ReviewVendorResponse? vendorResponse,  DateTime? publishedAt,  String? authorDisplayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Review() when $default != null:
return $default(_that.id,_that.connectionId,_that.authorType,_that.rating,_that.state,_that.editableUntil,_that.createdAt,_that.comment,_that.vendorResponse,_that.publishedAt,_that.authorDisplayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String connectionId, @_PartyRoleConverter()  PartyRole authorType,  int rating, @_ReviewStateConverter()  ReviewState state,  DateTime editableUntil,  DateTime createdAt,  String? comment,  ReviewVendorResponse? vendorResponse,  DateTime? publishedAt,  String? authorDisplayName)  $default,) {final _that = this;
switch (_that) {
case _Review():
return $default(_that.id,_that.connectionId,_that.authorType,_that.rating,_that.state,_that.editableUntil,_that.createdAt,_that.comment,_that.vendorResponse,_that.publishedAt,_that.authorDisplayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String connectionId, @_PartyRoleConverter()  PartyRole authorType,  int rating, @_ReviewStateConverter()  ReviewState state,  DateTime editableUntil,  DateTime createdAt,  String? comment,  ReviewVendorResponse? vendorResponse,  DateTime? publishedAt,  String? authorDisplayName)?  $default,) {final _that = this;
switch (_that) {
case _Review() when $default != null:
return $default(_that.id,_that.connectionId,_that.authorType,_that.rating,_that.state,_that.editableUntil,_that.createdAt,_that.comment,_that.vendorResponse,_that.publishedAt,_that.authorDisplayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Review implements Review {
  const _Review({required this.id, required this.connectionId, @_PartyRoleConverter() required this.authorType, required this.rating, @_ReviewStateConverter() required this.state, required this.editableUntil, required this.createdAt, this.comment, this.vendorResponse, this.publishedAt, this.authorDisplayName});
  factory _Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

@override final  String id;
@override final  String connectionId;
@override@_PartyRoleConverter() final  PartyRole authorType;
@override final  int rating;
@override@_ReviewStateConverter() final  ReviewState state;
@override final  DateTime editableUntil;
@override final  DateTime createdAt;
@override final  String? comment;
@override final  ReviewVendorResponse? vendorResponse;
@override final  DateTime? publishedAt;
@override final  String? authorDisplayName;

/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewCopyWith<_Review> get copyWith => __$ReviewCopyWithImpl<_Review>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Review&&(identical(other.id, id) || other.id == id)&&(identical(other.connectionId, connectionId) || other.connectionId == connectionId)&&(identical(other.authorType, authorType) || other.authorType == authorType)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.state, state) || other.state == state)&&(identical(other.editableUntil, editableUntil) || other.editableUntil == editableUntil)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.vendorResponse, vendorResponse) || other.vendorResponse == vendorResponse)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.authorDisplayName, authorDisplayName) || other.authorDisplayName == authorDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,connectionId,authorType,rating,state,editableUntil,createdAt,comment,vendorResponse,publishedAt,authorDisplayName);

@override
String toString() {
  return 'Review(id: $id, connectionId: $connectionId, authorType: $authorType, rating: $rating, state: $state, editableUntil: $editableUntil, createdAt: $createdAt, comment: $comment, vendorResponse: $vendorResponse, publishedAt: $publishedAt, authorDisplayName: $authorDisplayName)';
}


}

/// @nodoc
abstract mixin class _$ReviewCopyWith<$Res> implements $ReviewCopyWith<$Res> {
  factory _$ReviewCopyWith(_Review value, $Res Function(_Review) _then) = __$ReviewCopyWithImpl;
@override @useResult
$Res call({
 String id, String connectionId,@_PartyRoleConverter() PartyRole authorType, int rating,@_ReviewStateConverter() ReviewState state, DateTime editableUntil, DateTime createdAt, String? comment, ReviewVendorResponse? vendorResponse, DateTime? publishedAt, String? authorDisplayName
});


@override $ReviewVendorResponseCopyWith<$Res>? get vendorResponse;

}
/// @nodoc
class __$ReviewCopyWithImpl<$Res>
    implements _$ReviewCopyWith<$Res> {
  __$ReviewCopyWithImpl(this._self, this._then);

  final _Review _self;
  final $Res Function(_Review) _then;

/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? connectionId = null,Object? authorType = null,Object? rating = null,Object? state = null,Object? editableUntil = null,Object? createdAt = null,Object? comment = freezed,Object? vendorResponse = freezed,Object? publishedAt = freezed,Object? authorDisplayName = freezed,}) {
  return _then(_Review(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,connectionId: null == connectionId ? _self.connectionId : connectionId // ignore: cast_nullable_to_non_nullable
as String,authorType: null == authorType ? _self.authorType : authorType // ignore: cast_nullable_to_non_nullable
as PartyRole,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ReviewState,editableUntil: null == editableUntil ? _self.editableUntil : editableUntil // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,vendorResponse: freezed == vendorResponse ? _self.vendorResponse : vendorResponse // ignore: cast_nullable_to_non_nullable
as ReviewVendorResponse?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,authorDisplayName: freezed == authorDisplayName ? _self.authorDisplayName : authorDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReviewVendorResponseCopyWith<$Res>? get vendorResponse {
    if (_self.vendorResponse == null) {
    return null;
  }

  return $ReviewVendorResponseCopyWith<$Res>(_self.vendorResponse!, (value) {
    return _then(_self.copyWith(vendorResponse: value));
  });
}
}

// dart format on
