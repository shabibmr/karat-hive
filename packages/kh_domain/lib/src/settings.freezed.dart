// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountDeletionRequest {

 String get id; String get state; DateTime get createdAt; String? get challengeId; DateTime? get expiresAt; int? get retryAfterSeconds;
/// Create a copy of AccountDeletionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountDeletionRequestCopyWith<AccountDeletionRequest> get copyWith => _$AccountDeletionRequestCopyWithImpl<AccountDeletionRequest>(this as AccountDeletionRequest, _$identity);

  /// Serializes this AccountDeletionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountDeletionRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.state, state) || other.state == state)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.retryAfterSeconds, retryAfterSeconds) || other.retryAfterSeconds == retryAfterSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,state,createdAt,challengeId,expiresAt,retryAfterSeconds);

@override
String toString() {
  return 'AccountDeletionRequest(id: $id, state: $state, createdAt: $createdAt, challengeId: $challengeId, expiresAt: $expiresAt, retryAfterSeconds: $retryAfterSeconds)';
}


}

/// @nodoc
abstract mixin class $AccountDeletionRequestCopyWith<$Res>  {
  factory $AccountDeletionRequestCopyWith(AccountDeletionRequest value, $Res Function(AccountDeletionRequest) _then) = _$AccountDeletionRequestCopyWithImpl;
@useResult
$Res call({
 String id, String state, DateTime createdAt, String? challengeId, DateTime? expiresAt, int? retryAfterSeconds
});




}
/// @nodoc
class _$AccountDeletionRequestCopyWithImpl<$Res>
    implements $AccountDeletionRequestCopyWith<$Res> {
  _$AccountDeletionRequestCopyWithImpl(this._self, this._then);

  final AccountDeletionRequest _self;
  final $Res Function(AccountDeletionRequest) _then;

/// Create a copy of AccountDeletionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? state = null,Object? createdAt = null,Object? challengeId = freezed,Object? expiresAt = freezed,Object? retryAfterSeconds = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,challengeId: freezed == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,retryAfterSeconds: freezed == retryAfterSeconds ? _self.retryAfterSeconds : retryAfterSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountDeletionRequest].
extension AccountDeletionRequestPatterns on AccountDeletionRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountDeletionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountDeletionRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountDeletionRequest value)  $default,){
final _that = this;
switch (_that) {
case _AccountDeletionRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountDeletionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AccountDeletionRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String state,  DateTime createdAt,  String? challengeId,  DateTime? expiresAt,  int? retryAfterSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountDeletionRequest() when $default != null:
return $default(_that.id,_that.state,_that.createdAt,_that.challengeId,_that.expiresAt,_that.retryAfterSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String state,  DateTime createdAt,  String? challengeId,  DateTime? expiresAt,  int? retryAfterSeconds)  $default,) {final _that = this;
switch (_that) {
case _AccountDeletionRequest():
return $default(_that.id,_that.state,_that.createdAt,_that.challengeId,_that.expiresAt,_that.retryAfterSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String state,  DateTime createdAt,  String? challengeId,  DateTime? expiresAt,  int? retryAfterSeconds)?  $default,) {final _that = this;
switch (_that) {
case _AccountDeletionRequest() when $default != null:
return $default(_that.id,_that.state,_that.createdAt,_that.challengeId,_that.expiresAt,_that.retryAfterSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccountDeletionRequest implements AccountDeletionRequest {
  const _AccountDeletionRequest({required this.id, required this.state, required this.createdAt, this.challengeId, this.expiresAt, this.retryAfterSeconds});
  factory _AccountDeletionRequest.fromJson(Map<String, dynamic> json) => _$AccountDeletionRequestFromJson(json);

@override final  String id;
@override final  String state;
@override final  DateTime createdAt;
@override final  String? challengeId;
@override final  DateTime? expiresAt;
@override final  int? retryAfterSeconds;

/// Create a copy of AccountDeletionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountDeletionRequestCopyWith<_AccountDeletionRequest> get copyWith => __$AccountDeletionRequestCopyWithImpl<_AccountDeletionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountDeletionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountDeletionRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.state, state) || other.state == state)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.retryAfterSeconds, retryAfterSeconds) || other.retryAfterSeconds == retryAfterSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,state,createdAt,challengeId,expiresAt,retryAfterSeconds);

@override
String toString() {
  return 'AccountDeletionRequest(id: $id, state: $state, createdAt: $createdAt, challengeId: $challengeId, expiresAt: $expiresAt, retryAfterSeconds: $retryAfterSeconds)';
}


}

/// @nodoc
abstract mixin class _$AccountDeletionRequestCopyWith<$Res> implements $AccountDeletionRequestCopyWith<$Res> {
  factory _$AccountDeletionRequestCopyWith(_AccountDeletionRequest value, $Res Function(_AccountDeletionRequest) _then) = __$AccountDeletionRequestCopyWithImpl;
@override @useResult
$Res call({
 String id, String state, DateTime createdAt, String? challengeId, DateTime? expiresAt, int? retryAfterSeconds
});




}
/// @nodoc
class __$AccountDeletionRequestCopyWithImpl<$Res>
    implements _$AccountDeletionRequestCopyWith<$Res> {
  __$AccountDeletionRequestCopyWithImpl(this._self, this._then);

  final _AccountDeletionRequest _self;
  final $Res Function(_AccountDeletionRequest) _then;

/// Create a copy of AccountDeletionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? state = null,Object? createdAt = null,Object? challengeId = freezed,Object? expiresAt = freezed,Object? retryAfterSeconds = freezed,}) {
  return _then(_AccountDeletionRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,challengeId: freezed == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,retryAfterSeconds: freezed == retryAfterSeconds ? _self.retryAfterSeconds : retryAfterSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$QuietHours {

 String get start; String get end; String get timezone;
/// Create a copy of QuietHours
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuietHoursCopyWith<QuietHours> get copyWith => _$QuietHoursCopyWithImpl<QuietHours>(this as QuietHours, _$identity);

  /// Serializes this QuietHours to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuietHours&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.timezone, timezone) || other.timezone == timezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,start,end,timezone);

@override
String toString() {
  return 'QuietHours(start: $start, end: $end, timezone: $timezone)';
}


}

/// @nodoc
abstract mixin class $QuietHoursCopyWith<$Res>  {
  factory $QuietHoursCopyWith(QuietHours value, $Res Function(QuietHours) _then) = _$QuietHoursCopyWithImpl;
@useResult
$Res call({
 String start, String end, String timezone
});




}
/// @nodoc
class _$QuietHoursCopyWithImpl<$Res>
    implements $QuietHoursCopyWith<$Res> {
  _$QuietHoursCopyWithImpl(this._self, this._then);

  final QuietHours _self;
  final $Res Function(QuietHours) _then;

/// Create a copy of QuietHours
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? start = null,Object? end = null,Object? timezone = null,}) {
  return _then(_self.copyWith(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [QuietHours].
extension QuietHoursPatterns on QuietHours {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuietHours value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuietHours() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuietHours value)  $default,){
final _that = this;
switch (_that) {
case _QuietHours():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuietHours value)?  $default,){
final _that = this;
switch (_that) {
case _QuietHours() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String start,  String end,  String timezone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuietHours() when $default != null:
return $default(_that.start,_that.end,_that.timezone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String start,  String end,  String timezone)  $default,) {final _that = this;
switch (_that) {
case _QuietHours():
return $default(_that.start,_that.end,_that.timezone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String start,  String end,  String timezone)?  $default,) {final _that = this;
switch (_that) {
case _QuietHours() when $default != null:
return $default(_that.start,_that.end,_that.timezone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuietHours implements QuietHours {
  const _QuietHours({required this.start, required this.end, this.timezone = 'Asia/Dubai'});
  factory _QuietHours.fromJson(Map<String, dynamic> json) => _$QuietHoursFromJson(json);

@override final  String start;
@override final  String end;
@override@JsonKey() final  String timezone;

/// Create a copy of QuietHours
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuietHoursCopyWith<_QuietHours> get copyWith => __$QuietHoursCopyWithImpl<_QuietHours>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuietHoursToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuietHours&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.timezone, timezone) || other.timezone == timezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,start,end,timezone);

@override
String toString() {
  return 'QuietHours(start: $start, end: $end, timezone: $timezone)';
}


}

/// @nodoc
abstract mixin class _$QuietHoursCopyWith<$Res> implements $QuietHoursCopyWith<$Res> {
  factory _$QuietHoursCopyWith(_QuietHours value, $Res Function(_QuietHours) _then) = __$QuietHoursCopyWithImpl;
@override @useResult
$Res call({
 String start, String end, String timezone
});




}
/// @nodoc
class __$QuietHoursCopyWithImpl<$Res>
    implements _$QuietHoursCopyWith<$Res> {
  __$QuietHoursCopyWithImpl(this._self, this._then);

  final _QuietHours _self;
  final $Res Function(_QuietHours) _then;

/// Create a copy of QuietHours
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? start = null,Object? end = null,Object? timezone = null,}) {
  return _then(_QuietHours(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$NotificationChannelPref {

 bool get inApp; bool get push;// Wire key is `emailChannel`, not `email` — `email` is a reserved
// identity key on the backend (edge/masking/identity-keys.ts) and trips
// MaskingInterceptor's leak check on this non-identity boolean.
 bool get emailChannel;
/// Create a copy of NotificationChannelPref
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationChannelPrefCopyWith<NotificationChannelPref> get copyWith => _$NotificationChannelPrefCopyWithImpl<NotificationChannelPref>(this as NotificationChannelPref, _$identity);

  /// Serializes this NotificationChannelPref to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationChannelPref&&(identical(other.inApp, inApp) || other.inApp == inApp)&&(identical(other.push, push) || other.push == push)&&(identical(other.emailChannel, emailChannel) || other.emailChannel == emailChannel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,inApp,push,emailChannel);

@override
String toString() {
  return 'NotificationChannelPref(inApp: $inApp, push: $push, emailChannel: $emailChannel)';
}


}

/// @nodoc
abstract mixin class $NotificationChannelPrefCopyWith<$Res>  {
  factory $NotificationChannelPrefCopyWith(NotificationChannelPref value, $Res Function(NotificationChannelPref) _then) = _$NotificationChannelPrefCopyWithImpl;
@useResult
$Res call({
 bool inApp, bool push, bool emailChannel
});




}
/// @nodoc
class _$NotificationChannelPrefCopyWithImpl<$Res>
    implements $NotificationChannelPrefCopyWith<$Res> {
  _$NotificationChannelPrefCopyWithImpl(this._self, this._then);

  final NotificationChannelPref _self;
  final $Res Function(NotificationChannelPref) _then;

/// Create a copy of NotificationChannelPref
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? inApp = null,Object? push = null,Object? emailChannel = null,}) {
  return _then(_self.copyWith(
inApp: null == inApp ? _self.inApp : inApp // ignore: cast_nullable_to_non_nullable
as bool,push: null == push ? _self.push : push // ignore: cast_nullable_to_non_nullable
as bool,emailChannel: null == emailChannel ? _self.emailChannel : emailChannel // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationChannelPref].
extension NotificationChannelPrefPatterns on NotificationChannelPref {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationChannelPref value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationChannelPref() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationChannelPref value)  $default,){
final _that = this;
switch (_that) {
case _NotificationChannelPref():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationChannelPref value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationChannelPref() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool inApp,  bool push,  bool emailChannel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationChannelPref() when $default != null:
return $default(_that.inApp,_that.push,_that.emailChannel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool inApp,  bool push,  bool emailChannel)  $default,) {final _that = this;
switch (_that) {
case _NotificationChannelPref():
return $default(_that.inApp,_that.push,_that.emailChannel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool inApp,  bool push,  bool emailChannel)?  $default,) {final _that = this;
switch (_that) {
case _NotificationChannelPref() when $default != null:
return $default(_that.inApp,_that.push,_that.emailChannel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationChannelPref implements NotificationChannelPref {
  const _NotificationChannelPref({required this.inApp, required this.push, required this.emailChannel});
  factory _NotificationChannelPref.fromJson(Map<String, dynamic> json) => _$NotificationChannelPrefFromJson(json);

@override final  bool inApp;
@override final  bool push;
// Wire key is `emailChannel`, not `email` — `email` is a reserved
// identity key on the backend (edge/masking/identity-keys.ts) and trips
// MaskingInterceptor's leak check on this non-identity boolean.
@override final  bool emailChannel;

/// Create a copy of NotificationChannelPref
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationChannelPrefCopyWith<_NotificationChannelPref> get copyWith => __$NotificationChannelPrefCopyWithImpl<_NotificationChannelPref>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationChannelPrefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationChannelPref&&(identical(other.inApp, inApp) || other.inApp == inApp)&&(identical(other.push, push) || other.push == push)&&(identical(other.emailChannel, emailChannel) || other.emailChannel == emailChannel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,inApp,push,emailChannel);

@override
String toString() {
  return 'NotificationChannelPref(inApp: $inApp, push: $push, emailChannel: $emailChannel)';
}


}

/// @nodoc
abstract mixin class _$NotificationChannelPrefCopyWith<$Res> implements $NotificationChannelPrefCopyWith<$Res> {
  factory _$NotificationChannelPrefCopyWith(_NotificationChannelPref value, $Res Function(_NotificationChannelPref) _then) = __$NotificationChannelPrefCopyWithImpl;
@override @useResult
$Res call({
 bool inApp, bool push, bool emailChannel
});




}
/// @nodoc
class __$NotificationChannelPrefCopyWithImpl<$Res>
    implements _$NotificationChannelPrefCopyWith<$Res> {
  __$NotificationChannelPrefCopyWithImpl(this._self, this._then);

  final _NotificationChannelPref _self;
  final $Res Function(_NotificationChannelPref) _then;

/// Create a copy of NotificationChannelPref
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? inApp = null,Object? push = null,Object? emailChannel = null,}) {
  return _then(_NotificationChannelPref(
inApp: null == inApp ? _self.inApp : inApp // ignore: cast_nullable_to_non_nullable
as bool,push: null == push ? _self.push : push // ignore: cast_nullable_to_non_nullable
as bool,emailChannel: null == emailChannel ? _self.emailChannel : emailChannel // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$UserSettings {

 String get preferredLanguage; Map<String, NotificationChannelPref> get notifications; String? get defaultRegionId; QuietHours? get quietHours; String? get defaultFilterPresetId;
/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserSettingsCopyWith<UserSettings> get copyWith => _$UserSettingsCopyWithImpl<UserSettings>(this as UserSettings, _$identity);

  /// Serializes this UserSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSettings&&(identical(other.preferredLanguage, preferredLanguage) || other.preferredLanguage == preferredLanguage)&&const DeepCollectionEquality().equals(other.notifications, notifications)&&(identical(other.defaultRegionId, defaultRegionId) || other.defaultRegionId == defaultRegionId)&&(identical(other.quietHours, quietHours) || other.quietHours == quietHours)&&(identical(other.defaultFilterPresetId, defaultFilterPresetId) || other.defaultFilterPresetId == defaultFilterPresetId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,preferredLanguage,const DeepCollectionEquality().hash(notifications),defaultRegionId,quietHours,defaultFilterPresetId);

@override
String toString() {
  return 'UserSettings(preferredLanguage: $preferredLanguage, notifications: $notifications, defaultRegionId: $defaultRegionId, quietHours: $quietHours, defaultFilterPresetId: $defaultFilterPresetId)';
}


}

/// @nodoc
abstract mixin class $UserSettingsCopyWith<$Res>  {
  factory $UserSettingsCopyWith(UserSettings value, $Res Function(UserSettings) _then) = _$UserSettingsCopyWithImpl;
@useResult
$Res call({
 String preferredLanguage, Map<String, NotificationChannelPref> notifications, String? defaultRegionId, QuietHours? quietHours, String? defaultFilterPresetId
});


$QuietHoursCopyWith<$Res>? get quietHours;

}
/// @nodoc
class _$UserSettingsCopyWithImpl<$Res>
    implements $UserSettingsCopyWith<$Res> {
  _$UserSettingsCopyWithImpl(this._self, this._then);

  final UserSettings _self;
  final $Res Function(UserSettings) _then;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? preferredLanguage = null,Object? notifications = null,Object? defaultRegionId = freezed,Object? quietHours = freezed,Object? defaultFilterPresetId = freezed,}) {
  return _then(_self.copyWith(
preferredLanguage: null == preferredLanguage ? _self.preferredLanguage : preferredLanguage // ignore: cast_nullable_to_non_nullable
as String,notifications: null == notifications ? _self.notifications : notifications // ignore: cast_nullable_to_non_nullable
as Map<String, NotificationChannelPref>,defaultRegionId: freezed == defaultRegionId ? _self.defaultRegionId : defaultRegionId // ignore: cast_nullable_to_non_nullable
as String?,quietHours: freezed == quietHours ? _self.quietHours : quietHours // ignore: cast_nullable_to_non_nullable
as QuietHours?,defaultFilterPresetId: freezed == defaultFilterPresetId ? _self.defaultFilterPresetId : defaultFilterPresetId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuietHoursCopyWith<$Res>? get quietHours {
    if (_self.quietHours == null) {
    return null;
  }

  return $QuietHoursCopyWith<$Res>(_self.quietHours!, (value) {
    return _then(_self.copyWith(quietHours: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserSettings].
extension UserSettingsPatterns on UserSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserSettings value)  $default,){
final _that = this;
switch (_that) {
case _UserSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserSettings value)?  $default,){
final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String preferredLanguage,  Map<String, NotificationChannelPref> notifications,  String? defaultRegionId,  QuietHours? quietHours,  String? defaultFilterPresetId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that.preferredLanguage,_that.notifications,_that.defaultRegionId,_that.quietHours,_that.defaultFilterPresetId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String preferredLanguage,  Map<String, NotificationChannelPref> notifications,  String? defaultRegionId,  QuietHours? quietHours,  String? defaultFilterPresetId)  $default,) {final _that = this;
switch (_that) {
case _UserSettings():
return $default(_that.preferredLanguage,_that.notifications,_that.defaultRegionId,_that.quietHours,_that.defaultFilterPresetId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String preferredLanguage,  Map<String, NotificationChannelPref> notifications,  String? defaultRegionId,  QuietHours? quietHours,  String? defaultFilterPresetId)?  $default,) {final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that.preferredLanguage,_that.notifications,_that.defaultRegionId,_that.quietHours,_that.defaultFilterPresetId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserSettings implements UserSettings {
  const _UserSettings({required this.preferredLanguage, required final  Map<String, NotificationChannelPref> notifications, this.defaultRegionId, this.quietHours, this.defaultFilterPresetId}): _notifications = notifications;
  factory _UserSettings.fromJson(Map<String, dynamic> json) => _$UserSettingsFromJson(json);

@override final  String preferredLanguage;
 final  Map<String, NotificationChannelPref> _notifications;
@override Map<String, NotificationChannelPref> get notifications {
  if (_notifications is EqualUnmodifiableMapView) return _notifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_notifications);
}

@override final  String? defaultRegionId;
@override final  QuietHours? quietHours;
@override final  String? defaultFilterPresetId;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserSettingsCopyWith<_UserSettings> get copyWith => __$UserSettingsCopyWithImpl<_UserSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSettings&&(identical(other.preferredLanguage, preferredLanguage) || other.preferredLanguage == preferredLanguage)&&const DeepCollectionEquality().equals(other._notifications, _notifications)&&(identical(other.defaultRegionId, defaultRegionId) || other.defaultRegionId == defaultRegionId)&&(identical(other.quietHours, quietHours) || other.quietHours == quietHours)&&(identical(other.defaultFilterPresetId, defaultFilterPresetId) || other.defaultFilterPresetId == defaultFilterPresetId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,preferredLanguage,const DeepCollectionEquality().hash(_notifications),defaultRegionId,quietHours,defaultFilterPresetId);

@override
String toString() {
  return 'UserSettings(preferredLanguage: $preferredLanguage, notifications: $notifications, defaultRegionId: $defaultRegionId, quietHours: $quietHours, defaultFilterPresetId: $defaultFilterPresetId)';
}


}

/// @nodoc
abstract mixin class _$UserSettingsCopyWith<$Res> implements $UserSettingsCopyWith<$Res> {
  factory _$UserSettingsCopyWith(_UserSettings value, $Res Function(_UserSettings) _then) = __$UserSettingsCopyWithImpl;
@override @useResult
$Res call({
 String preferredLanguage, Map<String, NotificationChannelPref> notifications, String? defaultRegionId, QuietHours? quietHours, String? defaultFilterPresetId
});


@override $QuietHoursCopyWith<$Res>? get quietHours;

}
/// @nodoc
class __$UserSettingsCopyWithImpl<$Res>
    implements _$UserSettingsCopyWith<$Res> {
  __$UserSettingsCopyWithImpl(this._self, this._then);

  final _UserSettings _self;
  final $Res Function(_UserSettings) _then;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? preferredLanguage = null,Object? notifications = null,Object? defaultRegionId = freezed,Object? quietHours = freezed,Object? defaultFilterPresetId = freezed,}) {
  return _then(_UserSettings(
preferredLanguage: null == preferredLanguage ? _self.preferredLanguage : preferredLanguage // ignore: cast_nullable_to_non_nullable
as String,notifications: null == notifications ? _self._notifications : notifications // ignore: cast_nullable_to_non_nullable
as Map<String, NotificationChannelPref>,defaultRegionId: freezed == defaultRegionId ? _self.defaultRegionId : defaultRegionId // ignore: cast_nullable_to_non_nullable
as String?,quietHours: freezed == quietHours ? _self.quietHours : quietHours // ignore: cast_nullable_to_non_nullable
as QuietHours?,defaultFilterPresetId: freezed == defaultFilterPresetId ? _self.defaultFilterPresetId : defaultFilterPresetId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuietHoursCopyWith<$Res>? get quietHours {
    if (_self.quietHours == null) {
    return null;
  }

  return $QuietHoursCopyWith<$Res>(_self.quietHours!, (value) {
    return _then(_self.copyWith(quietHours: value));
  });
}
}

// dart format on
