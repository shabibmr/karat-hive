// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CustomerMe {

 String get displayName; int get reviewCount; int get connectionCount; String? get photoUrl;@_DefaultRegionConverter() RegionSummary? get defaultRegion;@_NullableRatingSummaryConverter() RatingSummary? get rating; int? get liveRequestCount; bool? get canCreateRequest; int? get lifetimeRequestCount;
/// Create a copy of CustomerMe
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerMeCopyWith<CustomerMe> get copyWith => _$CustomerMeCopyWithImpl<CustomerMe>(this as CustomerMe, _$identity);

  /// Serializes this CustomerMe to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerMe&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.connectionCount, connectionCount) || other.connectionCount == connectionCount)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.defaultRegion, defaultRegion) || other.defaultRegion == defaultRegion)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.liveRequestCount, liveRequestCount) || other.liveRequestCount == liveRequestCount)&&(identical(other.canCreateRequest, canCreateRequest) || other.canCreateRequest == canCreateRequest)&&(identical(other.lifetimeRequestCount, lifetimeRequestCount) || other.lifetimeRequestCount == lifetimeRequestCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayName,reviewCount,connectionCount,photoUrl,defaultRegion,rating,liveRequestCount,canCreateRequest,lifetimeRequestCount);

@override
String toString() {
  return 'CustomerMe(displayName: $displayName, reviewCount: $reviewCount, connectionCount: $connectionCount, photoUrl: $photoUrl, defaultRegion: $defaultRegion, rating: $rating, liveRequestCount: $liveRequestCount, canCreateRequest: $canCreateRequest, lifetimeRequestCount: $lifetimeRequestCount)';
}


}

/// @nodoc
abstract mixin class $CustomerMeCopyWith<$Res>  {
  factory $CustomerMeCopyWith(CustomerMe value, $Res Function(CustomerMe) _then) = _$CustomerMeCopyWithImpl;
@useResult
$Res call({
 String displayName, int reviewCount, int connectionCount, String? photoUrl,@_DefaultRegionConverter() RegionSummary? defaultRegion,@_NullableRatingSummaryConverter() RatingSummary? rating, int? liveRequestCount, bool? canCreateRequest, int? lifetimeRequestCount
});


$RegionSummaryCopyWith<$Res>? get defaultRegion;

}
/// @nodoc
class _$CustomerMeCopyWithImpl<$Res>
    implements $CustomerMeCopyWith<$Res> {
  _$CustomerMeCopyWithImpl(this._self, this._then);

  final CustomerMe _self;
  final $Res Function(CustomerMe) _then;

/// Create a copy of CustomerMe
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = null,Object? reviewCount = null,Object? connectionCount = null,Object? photoUrl = freezed,Object? defaultRegion = freezed,Object? rating = freezed,Object? liveRequestCount = freezed,Object? canCreateRequest = freezed,Object? lifetimeRequestCount = freezed,}) {
  return _then(_self.copyWith(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,connectionCount: null == connectionCount ? _self.connectionCount : connectionCount // ignore: cast_nullable_to_non_nullable
as int,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,defaultRegion: freezed == defaultRegion ? _self.defaultRegion : defaultRegion // ignore: cast_nullable_to_non_nullable
as RegionSummary?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as RatingSummary?,liveRequestCount: freezed == liveRequestCount ? _self.liveRequestCount : liveRequestCount // ignore: cast_nullable_to_non_nullable
as int?,canCreateRequest: freezed == canCreateRequest ? _self.canCreateRequest : canCreateRequest // ignore: cast_nullable_to_non_nullable
as bool?,lifetimeRequestCount: freezed == lifetimeRequestCount ? _self.lifetimeRequestCount : lifetimeRequestCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of CustomerMe
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegionSummaryCopyWith<$Res>? get defaultRegion {
    if (_self.defaultRegion == null) {
    return null;
  }

  return $RegionSummaryCopyWith<$Res>(_self.defaultRegion!, (value) {
    return _then(_self.copyWith(defaultRegion: value));
  });
}
}


/// Adds pattern-matching-related methods to [CustomerMe].
extension CustomerMePatterns on CustomerMe {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerMe value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerMe() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerMe value)  $default,){
final _that = this;
switch (_that) {
case _CustomerMe():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerMe value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerMe() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String displayName,  int reviewCount,  int connectionCount,  String? photoUrl, @_DefaultRegionConverter()  RegionSummary? defaultRegion, @_NullableRatingSummaryConverter()  RatingSummary? rating,  int? liveRequestCount,  bool? canCreateRequest,  int? lifetimeRequestCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerMe() when $default != null:
return $default(_that.displayName,_that.reviewCount,_that.connectionCount,_that.photoUrl,_that.defaultRegion,_that.rating,_that.liveRequestCount,_that.canCreateRequest,_that.lifetimeRequestCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String displayName,  int reviewCount,  int connectionCount,  String? photoUrl, @_DefaultRegionConverter()  RegionSummary? defaultRegion, @_NullableRatingSummaryConverter()  RatingSummary? rating,  int? liveRequestCount,  bool? canCreateRequest,  int? lifetimeRequestCount)  $default,) {final _that = this;
switch (_that) {
case _CustomerMe():
return $default(_that.displayName,_that.reviewCount,_that.connectionCount,_that.photoUrl,_that.defaultRegion,_that.rating,_that.liveRequestCount,_that.canCreateRequest,_that.lifetimeRequestCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String displayName,  int reviewCount,  int connectionCount,  String? photoUrl, @_DefaultRegionConverter()  RegionSummary? defaultRegion, @_NullableRatingSummaryConverter()  RatingSummary? rating,  int? liveRequestCount,  bool? canCreateRequest,  int? lifetimeRequestCount)?  $default,) {final _that = this;
switch (_that) {
case _CustomerMe() when $default != null:
return $default(_that.displayName,_that.reviewCount,_that.connectionCount,_that.photoUrl,_that.defaultRegion,_that.rating,_that.liveRequestCount,_that.canCreateRequest,_that.lifetimeRequestCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomerMe implements CustomerMe {
  const _CustomerMe({required this.displayName, required this.reviewCount, required this.connectionCount, this.photoUrl, @_DefaultRegionConverter() this.defaultRegion, @_NullableRatingSummaryConverter() this.rating, this.liveRequestCount, this.canCreateRequest, this.lifetimeRequestCount});
  factory _CustomerMe.fromJson(Map<String, dynamic> json) => _$CustomerMeFromJson(json);

@override final  String displayName;
@override final  int reviewCount;
@override final  int connectionCount;
@override final  String? photoUrl;
@override@_DefaultRegionConverter() final  RegionSummary? defaultRegion;
@override@_NullableRatingSummaryConverter() final  RatingSummary? rating;
@override final  int? liveRequestCount;
@override final  bool? canCreateRequest;
@override final  int? lifetimeRequestCount;

/// Create a copy of CustomerMe
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerMeCopyWith<_CustomerMe> get copyWith => __$CustomerMeCopyWithImpl<_CustomerMe>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomerMeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerMe&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.connectionCount, connectionCount) || other.connectionCount == connectionCount)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.defaultRegion, defaultRegion) || other.defaultRegion == defaultRegion)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.liveRequestCount, liveRequestCount) || other.liveRequestCount == liveRequestCount)&&(identical(other.canCreateRequest, canCreateRequest) || other.canCreateRequest == canCreateRequest)&&(identical(other.lifetimeRequestCount, lifetimeRequestCount) || other.lifetimeRequestCount == lifetimeRequestCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayName,reviewCount,connectionCount,photoUrl,defaultRegion,rating,liveRequestCount,canCreateRequest,lifetimeRequestCount);

@override
String toString() {
  return 'CustomerMe(displayName: $displayName, reviewCount: $reviewCount, connectionCount: $connectionCount, photoUrl: $photoUrl, defaultRegion: $defaultRegion, rating: $rating, liveRequestCount: $liveRequestCount, canCreateRequest: $canCreateRequest, lifetimeRequestCount: $lifetimeRequestCount)';
}


}

/// @nodoc
abstract mixin class _$CustomerMeCopyWith<$Res> implements $CustomerMeCopyWith<$Res> {
  factory _$CustomerMeCopyWith(_CustomerMe value, $Res Function(_CustomerMe) _then) = __$CustomerMeCopyWithImpl;
@override @useResult
$Res call({
 String displayName, int reviewCount, int connectionCount, String? photoUrl,@_DefaultRegionConverter() RegionSummary? defaultRegion,@_NullableRatingSummaryConverter() RatingSummary? rating, int? liveRequestCount, bool? canCreateRequest, int? lifetimeRequestCount
});


@override $RegionSummaryCopyWith<$Res>? get defaultRegion;

}
/// @nodoc
class __$CustomerMeCopyWithImpl<$Res>
    implements _$CustomerMeCopyWith<$Res> {
  __$CustomerMeCopyWithImpl(this._self, this._then);

  final _CustomerMe _self;
  final $Res Function(_CustomerMe) _then;

/// Create a copy of CustomerMe
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = null,Object? reviewCount = null,Object? connectionCount = null,Object? photoUrl = freezed,Object? defaultRegion = freezed,Object? rating = freezed,Object? liveRequestCount = freezed,Object? canCreateRequest = freezed,Object? lifetimeRequestCount = freezed,}) {
  return _then(_CustomerMe(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,connectionCount: null == connectionCount ? _self.connectionCount : connectionCount // ignore: cast_nullable_to_non_nullable
as int,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,defaultRegion: freezed == defaultRegion ? _self.defaultRegion : defaultRegion // ignore: cast_nullable_to_non_nullable
as RegionSummary?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as RatingSummary?,liveRequestCount: freezed == liveRequestCount ? _self.liveRequestCount : liveRequestCount // ignore: cast_nullable_to_non_nullable
as int?,canCreateRequest: freezed == canCreateRequest ? _self.canCreateRequest : canCreateRequest // ignore: cast_nullable_to_non_nullable
as bool?,lifetimeRequestCount: freezed == lifetimeRequestCount ? _self.lifetimeRequestCount : lifetimeRequestCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of CustomerMe
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegionSummaryCopyWith<$Res>? get defaultRegion {
    if (_self.defaultRegion == null) {
    return null;
  }

  return $RegionSummaryCopyWith<$Res>(_self.defaultRegion!, (value) {
    return _then(_self.copyWith(defaultRegion: value));
  });
}
}


/// @nodoc
mixin _$BusinessDayHours {

 String get open; String get close; bool get closed;
/// Create a copy of BusinessDayHours
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BusinessDayHoursCopyWith<BusinessDayHours> get copyWith => _$BusinessDayHoursCopyWithImpl<BusinessDayHours>(this as BusinessDayHours, _$identity);

  /// Serializes this BusinessDayHours to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BusinessDayHours&&(identical(other.open, open) || other.open == open)&&(identical(other.close, close) || other.close == close)&&(identical(other.closed, closed) || other.closed == closed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,open,close,closed);

@override
String toString() {
  return 'BusinessDayHours(open: $open, close: $close, closed: $closed)';
}


}

/// @nodoc
abstract mixin class $BusinessDayHoursCopyWith<$Res>  {
  factory $BusinessDayHoursCopyWith(BusinessDayHours value, $Res Function(BusinessDayHours) _then) = _$BusinessDayHoursCopyWithImpl;
@useResult
$Res call({
 String open, String close, bool closed
});




}
/// @nodoc
class _$BusinessDayHoursCopyWithImpl<$Res>
    implements $BusinessDayHoursCopyWith<$Res> {
  _$BusinessDayHoursCopyWithImpl(this._self, this._then);

  final BusinessDayHours _self;
  final $Res Function(BusinessDayHours) _then;

/// Create a copy of BusinessDayHours
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? open = null,Object? close = null,Object? closed = null,}) {
  return _then(_self.copyWith(
open: null == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as String,close: null == close ? _self.close : close // ignore: cast_nullable_to_non_nullable
as String,closed: null == closed ? _self.closed : closed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BusinessDayHours].
extension BusinessDayHoursPatterns on BusinessDayHours {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BusinessDayHours value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BusinessDayHours() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BusinessDayHours value)  $default,){
final _that = this;
switch (_that) {
case _BusinessDayHours():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BusinessDayHours value)?  $default,){
final _that = this;
switch (_that) {
case _BusinessDayHours() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String open,  String close,  bool closed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BusinessDayHours() when $default != null:
return $default(_that.open,_that.close,_that.closed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String open,  String close,  bool closed)  $default,) {final _that = this;
switch (_that) {
case _BusinessDayHours():
return $default(_that.open,_that.close,_that.closed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String open,  String close,  bool closed)?  $default,) {final _that = this;
switch (_that) {
case _BusinessDayHours() when $default != null:
return $default(_that.open,_that.close,_that.closed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BusinessDayHours implements BusinessDayHours {
  const _BusinessDayHours({required this.open, required this.close, this.closed = false});
  factory _BusinessDayHours.fromJson(Map<String, dynamic> json) => _$BusinessDayHoursFromJson(json);

@override final  String open;
@override final  String close;
@override@JsonKey() final  bool closed;

/// Create a copy of BusinessDayHours
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BusinessDayHoursCopyWith<_BusinessDayHours> get copyWith => __$BusinessDayHoursCopyWithImpl<_BusinessDayHours>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BusinessDayHoursToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BusinessDayHours&&(identical(other.open, open) || other.open == open)&&(identical(other.close, close) || other.close == close)&&(identical(other.closed, closed) || other.closed == closed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,open,close,closed);

@override
String toString() {
  return 'BusinessDayHours(open: $open, close: $close, closed: $closed)';
}


}

/// @nodoc
abstract mixin class _$BusinessDayHoursCopyWith<$Res> implements $BusinessDayHoursCopyWith<$Res> {
  factory _$BusinessDayHoursCopyWith(_BusinessDayHours value, $Res Function(_BusinessDayHours) _then) = __$BusinessDayHoursCopyWithImpl;
@override @useResult
$Res call({
 String open, String close, bool closed
});




}
/// @nodoc
class __$BusinessDayHoursCopyWithImpl<$Res>
    implements _$BusinessDayHoursCopyWith<$Res> {
  __$BusinessDayHoursCopyWithImpl(this._self, this._then);

  final _BusinessDayHours _self;
  final $Res Function(_BusinessDayHours) _then;

/// Create a copy of BusinessDayHours
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? open = null,Object? close = null,Object? closed = null,}) {
  return _then(_BusinessDayHours(
open: null == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as String,close: null == close ? _self.close : close // ignore: cast_nullable_to_non_nullable
as String,closed: null == closed ? _self.closed : closed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
