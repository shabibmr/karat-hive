// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OtpChallenge {

 String get challengeId; DateTime get expiresAt;
/// Create a copy of OtpChallenge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtpChallengeCopyWith<OtpChallenge> get copyWith => _$OtpChallengeCopyWithImpl<OtpChallenge>(this as OtpChallenge, _$identity);

  /// Serializes this OtpChallenge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpChallenge&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,challengeId,expiresAt);

@override
String toString() {
  return 'OtpChallenge(challengeId: $challengeId, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $OtpChallengeCopyWith<$Res>  {
  factory $OtpChallengeCopyWith(OtpChallenge value, $Res Function(OtpChallenge) _then) = _$OtpChallengeCopyWithImpl;
@useResult
$Res call({
 String challengeId, DateTime expiresAt
});




}
/// @nodoc
class _$OtpChallengeCopyWithImpl<$Res>
    implements $OtpChallengeCopyWith<$Res> {
  _$OtpChallengeCopyWithImpl(this._self, this._then);

  final OtpChallenge _self;
  final $Res Function(OtpChallenge) _then;

/// Create a copy of OtpChallenge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? challengeId = null,Object? expiresAt = null,}) {
  return _then(_self.copyWith(
challengeId: null == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [OtpChallenge].
extension OtpChallengePatterns on OtpChallenge {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OtpChallenge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OtpChallenge() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OtpChallenge value)  $default,){
final _that = this;
switch (_that) {
case _OtpChallenge():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OtpChallenge value)?  $default,){
final _that = this;
switch (_that) {
case _OtpChallenge() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String challengeId,  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OtpChallenge() when $default != null:
return $default(_that.challengeId,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String challengeId,  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _OtpChallenge():
return $default(_that.challengeId,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String challengeId,  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _OtpChallenge() when $default != null:
return $default(_that.challengeId,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OtpChallenge implements OtpChallenge {
  const _OtpChallenge({required this.challengeId, required this.expiresAt});
  factory _OtpChallenge.fromJson(Map<String, dynamic> json) => _$OtpChallengeFromJson(json);

@override final  String challengeId;
@override final  DateTime expiresAt;

/// Create a copy of OtpChallenge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtpChallengeCopyWith<_OtpChallenge> get copyWith => __$OtpChallengeCopyWithImpl<_OtpChallenge>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OtpChallengeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpChallenge&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,challengeId,expiresAt);

@override
String toString() {
  return 'OtpChallenge(challengeId: $challengeId, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$OtpChallengeCopyWith<$Res> implements $OtpChallengeCopyWith<$Res> {
  factory _$OtpChallengeCopyWith(_OtpChallenge value, $Res Function(_OtpChallenge) _then) = __$OtpChallengeCopyWithImpl;
@override @useResult
$Res call({
 String challengeId, DateTime expiresAt
});




}
/// @nodoc
class __$OtpChallengeCopyWithImpl<$Res>
    implements _$OtpChallengeCopyWith<$Res> {
  __$OtpChallengeCopyWithImpl(this._self, this._then);

  final _OtpChallenge _self;
  final $Res Function(_OtpChallenge) _then;

/// Create a copy of OtpChallenge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? challengeId = null,Object? expiresAt = null,}) {
  return _then(_OtpChallenge(
challengeId: null == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$SessionBundle {

@JsonKey(fromJson: _sessionTokensFromJson, toJson: _sessionTokensToJson) SessionTokens get tokens;@JsonKey(fromJson: _meUserFromJson, toJson: _meUserToJson) MeUser get user;
/// Create a copy of SessionBundle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionBundleCopyWith<SessionBundle> get copyWith => _$SessionBundleCopyWithImpl<SessionBundle>(this as SessionBundle, _$identity);

  /// Serializes this SessionBundle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionBundle&&(identical(other.tokens, tokens) || other.tokens == tokens)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tokens,user);

@override
String toString() {
  return 'SessionBundle(tokens: $tokens, user: $user)';
}


}

/// @nodoc
abstract mixin class $SessionBundleCopyWith<$Res>  {
  factory $SessionBundleCopyWith(SessionBundle value, $Res Function(SessionBundle) _then) = _$SessionBundleCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _sessionTokensFromJson, toJson: _sessionTokensToJson) SessionTokens tokens,@JsonKey(fromJson: _meUserFromJson, toJson: _meUserToJson) MeUser user
});


$MeUserCopyWith<$Res> get user;

}
/// @nodoc
class _$SessionBundleCopyWithImpl<$Res>
    implements $SessionBundleCopyWith<$Res> {
  _$SessionBundleCopyWithImpl(this._self, this._then);

  final SessionBundle _self;
  final $Res Function(SessionBundle) _then;

/// Create a copy of SessionBundle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tokens = null,Object? user = null,}) {
  return _then(_self.copyWith(
tokens: null == tokens ? _self.tokens : tokens // ignore: cast_nullable_to_non_nullable
as SessionTokens,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as MeUser,
  ));
}
/// Create a copy of SessionBundle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MeUserCopyWith<$Res> get user {
  
  return $MeUserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [SessionBundle].
extension SessionBundlePatterns on SessionBundle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionBundle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionBundle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionBundle value)  $default,){
final _that = this;
switch (_that) {
case _SessionBundle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionBundle value)?  $default,){
final _that = this;
switch (_that) {
case _SessionBundle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _sessionTokensFromJson, toJson: _sessionTokensToJson)  SessionTokens tokens, @JsonKey(fromJson: _meUserFromJson, toJson: _meUserToJson)  MeUser user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionBundle() when $default != null:
return $default(_that.tokens,_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _sessionTokensFromJson, toJson: _sessionTokensToJson)  SessionTokens tokens, @JsonKey(fromJson: _meUserFromJson, toJson: _meUserToJson)  MeUser user)  $default,) {final _that = this;
switch (_that) {
case _SessionBundle():
return $default(_that.tokens,_that.user);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _sessionTokensFromJson, toJson: _sessionTokensToJson)  SessionTokens tokens, @JsonKey(fromJson: _meUserFromJson, toJson: _meUserToJson)  MeUser user)?  $default,) {final _that = this;
switch (_that) {
case _SessionBundle() when $default != null:
return $default(_that.tokens,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionBundle implements SessionBundle {
  const _SessionBundle({@JsonKey(fromJson: _sessionTokensFromJson, toJson: _sessionTokensToJson) required this.tokens, @JsonKey(fromJson: _meUserFromJson, toJson: _meUserToJson) required this.user});
  factory _SessionBundle.fromJson(Map<String, dynamic> json) => _$SessionBundleFromJson(json);

@override@JsonKey(fromJson: _sessionTokensFromJson, toJson: _sessionTokensToJson) final  SessionTokens tokens;
@override@JsonKey(fromJson: _meUserFromJson, toJson: _meUserToJson) final  MeUser user;

/// Create a copy of SessionBundle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionBundleCopyWith<_SessionBundle> get copyWith => __$SessionBundleCopyWithImpl<_SessionBundle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionBundleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionBundle&&(identical(other.tokens, tokens) || other.tokens == tokens)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tokens,user);

@override
String toString() {
  return 'SessionBundle(tokens: $tokens, user: $user)';
}


}

/// @nodoc
abstract mixin class _$SessionBundleCopyWith<$Res> implements $SessionBundleCopyWith<$Res> {
  factory _$SessionBundleCopyWith(_SessionBundle value, $Res Function(_SessionBundle) _then) = __$SessionBundleCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _sessionTokensFromJson, toJson: _sessionTokensToJson) SessionTokens tokens,@JsonKey(fromJson: _meUserFromJson, toJson: _meUserToJson) MeUser user
});


@override $MeUserCopyWith<$Res> get user;

}
/// @nodoc
class __$SessionBundleCopyWithImpl<$Res>
    implements _$SessionBundleCopyWith<$Res> {
  __$SessionBundleCopyWithImpl(this._self, this._then);

  final _SessionBundle _self;
  final $Res Function(_SessionBundle) _then;

/// Create a copy of SessionBundle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tokens = null,Object? user = null,}) {
  return _then(_SessionBundle(
tokens: null == tokens ? _self.tokens : tokens // ignore: cast_nullable_to_non_nullable
as SessionTokens,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as MeUser,
  ));
}

/// Create a copy of SessionBundle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MeUserCopyWith<$Res> get user {
  
  return $MeUserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// @nodoc
mixin _$OtpVerifyResult {

 bool get mobileVerified; String? get challengeId; SessionBundle? get session;
/// Create a copy of OtpVerifyResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtpVerifyResultCopyWith<OtpVerifyResult> get copyWith => _$OtpVerifyResultCopyWithImpl<OtpVerifyResult>(this as OtpVerifyResult, _$identity);

  /// Serializes this OtpVerifyResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpVerifyResult&&(identical(other.mobileVerified, mobileVerified) || other.mobileVerified == mobileVerified)&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId)&&(identical(other.session, session) || other.session == session));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mobileVerified,challengeId,session);

@override
String toString() {
  return 'OtpVerifyResult(mobileVerified: $mobileVerified, challengeId: $challengeId, session: $session)';
}


}

/// @nodoc
abstract mixin class $OtpVerifyResultCopyWith<$Res>  {
  factory $OtpVerifyResultCopyWith(OtpVerifyResult value, $Res Function(OtpVerifyResult) _then) = _$OtpVerifyResultCopyWithImpl;
@useResult
$Res call({
 bool mobileVerified, String? challengeId, SessionBundle? session
});


$SessionBundleCopyWith<$Res>? get session;

}
/// @nodoc
class _$OtpVerifyResultCopyWithImpl<$Res>
    implements $OtpVerifyResultCopyWith<$Res> {
  _$OtpVerifyResultCopyWithImpl(this._self, this._then);

  final OtpVerifyResult _self;
  final $Res Function(OtpVerifyResult) _then;

/// Create a copy of OtpVerifyResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mobileVerified = null,Object? challengeId = freezed,Object? session = freezed,}) {
  return _then(_self.copyWith(
mobileVerified: null == mobileVerified ? _self.mobileVerified : mobileVerified // ignore: cast_nullable_to_non_nullable
as bool,challengeId: freezed == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String?,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as SessionBundle?,
  ));
}
/// Create a copy of OtpVerifyResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionBundleCopyWith<$Res>? get session {
    if (_self.session == null) {
    return null;
  }

  return $SessionBundleCopyWith<$Res>(_self.session!, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}


/// Adds pattern-matching-related methods to [OtpVerifyResult].
extension OtpVerifyResultPatterns on OtpVerifyResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OtpVerifyResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OtpVerifyResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OtpVerifyResult value)  $default,){
final _that = this;
switch (_that) {
case _OtpVerifyResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OtpVerifyResult value)?  $default,){
final _that = this;
switch (_that) {
case _OtpVerifyResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool mobileVerified,  String? challengeId,  SessionBundle? session)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OtpVerifyResult() when $default != null:
return $default(_that.mobileVerified,_that.challengeId,_that.session);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool mobileVerified,  String? challengeId,  SessionBundle? session)  $default,) {final _that = this;
switch (_that) {
case _OtpVerifyResult():
return $default(_that.mobileVerified,_that.challengeId,_that.session);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool mobileVerified,  String? challengeId,  SessionBundle? session)?  $default,) {final _that = this;
switch (_that) {
case _OtpVerifyResult() when $default != null:
return $default(_that.mobileVerified,_that.challengeId,_that.session);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OtpVerifyResult implements OtpVerifyResult {
  const _OtpVerifyResult({this.mobileVerified = false, this.challengeId, this.session});
  factory _OtpVerifyResult.fromJson(Map<String, dynamic> json) => _$OtpVerifyResultFromJson(json);

@override@JsonKey() final  bool mobileVerified;
@override final  String? challengeId;
@override final  SessionBundle? session;

/// Create a copy of OtpVerifyResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtpVerifyResultCopyWith<_OtpVerifyResult> get copyWith => __$OtpVerifyResultCopyWithImpl<_OtpVerifyResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OtpVerifyResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpVerifyResult&&(identical(other.mobileVerified, mobileVerified) || other.mobileVerified == mobileVerified)&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId)&&(identical(other.session, session) || other.session == session));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mobileVerified,challengeId,session);

@override
String toString() {
  return 'OtpVerifyResult(mobileVerified: $mobileVerified, challengeId: $challengeId, session: $session)';
}


}

/// @nodoc
abstract mixin class _$OtpVerifyResultCopyWith<$Res> implements $OtpVerifyResultCopyWith<$Res> {
  factory _$OtpVerifyResultCopyWith(_OtpVerifyResult value, $Res Function(_OtpVerifyResult) _then) = __$OtpVerifyResultCopyWithImpl;
@override @useResult
$Res call({
 bool mobileVerified, String? challengeId, SessionBundle? session
});


@override $SessionBundleCopyWith<$Res>? get session;

}
/// @nodoc
class __$OtpVerifyResultCopyWithImpl<$Res>
    implements _$OtpVerifyResultCopyWith<$Res> {
  __$OtpVerifyResultCopyWithImpl(this._self, this._then);

  final _OtpVerifyResult _self;
  final $Res Function(_OtpVerifyResult) _then;

/// Create a copy of OtpVerifyResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mobileVerified = null,Object? challengeId = freezed,Object? session = freezed,}) {
  return _then(_OtpVerifyResult(
mobileVerified: null == mobileVerified ? _self.mobileVerified : mobileVerified // ignore: cast_nullable_to_non_nullable
as bool,challengeId: freezed == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String?,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as SessionBundle?,
  ));
}

/// Create a copy of OtpVerifyResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionBundleCopyWith<$Res>? get session {
    if (_self.session == null) {
    return null;
  }

  return $SessionBundleCopyWith<$Res>(_self.session!, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}


/// @nodoc
mixin _$UploadIntent {

 String get key; String get uploadUrl; Map<String, String> get requiredHeaders; int get maxBytes;
/// Create a copy of UploadIntent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadIntentCopyWith<UploadIntent> get copyWith => _$UploadIntentCopyWithImpl<UploadIntent>(this as UploadIntent, _$identity);

  /// Serializes this UploadIntent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadIntent&&(identical(other.key, key) || other.key == key)&&(identical(other.uploadUrl, uploadUrl) || other.uploadUrl == uploadUrl)&&const DeepCollectionEquality().equals(other.requiredHeaders, requiredHeaders)&&(identical(other.maxBytes, maxBytes) || other.maxBytes == maxBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,uploadUrl,const DeepCollectionEquality().hash(requiredHeaders),maxBytes);

@override
String toString() {
  return 'UploadIntent(key: $key, uploadUrl: $uploadUrl, requiredHeaders: $requiredHeaders, maxBytes: $maxBytes)';
}


}

/// @nodoc
abstract mixin class $UploadIntentCopyWith<$Res>  {
  factory $UploadIntentCopyWith(UploadIntent value, $Res Function(UploadIntent) _then) = _$UploadIntentCopyWithImpl;
@useResult
$Res call({
 String key, String uploadUrl, Map<String, String> requiredHeaders, int maxBytes
});




}
/// @nodoc
class _$UploadIntentCopyWithImpl<$Res>
    implements $UploadIntentCopyWith<$Res> {
  _$UploadIntentCopyWithImpl(this._self, this._then);

  final UploadIntent _self;
  final $Res Function(UploadIntent) _then;

/// Create a copy of UploadIntent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? uploadUrl = null,Object? requiredHeaders = null,Object? maxBytes = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,uploadUrl: null == uploadUrl ? _self.uploadUrl : uploadUrl // ignore: cast_nullable_to_non_nullable
as String,requiredHeaders: null == requiredHeaders ? _self.requiredHeaders : requiredHeaders // ignore: cast_nullable_to_non_nullable
as Map<String, String>,maxBytes: null == maxBytes ? _self.maxBytes : maxBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadIntent].
extension UploadIntentPatterns on UploadIntent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadIntent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadIntent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadIntent value)  $default,){
final _that = this;
switch (_that) {
case _UploadIntent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadIntent value)?  $default,){
final _that = this;
switch (_that) {
case _UploadIntent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String uploadUrl,  Map<String, String> requiredHeaders,  int maxBytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadIntent() when $default != null:
return $default(_that.key,_that.uploadUrl,_that.requiredHeaders,_that.maxBytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String uploadUrl,  Map<String, String> requiredHeaders,  int maxBytes)  $default,) {final _that = this;
switch (_that) {
case _UploadIntent():
return $default(_that.key,_that.uploadUrl,_that.requiredHeaders,_that.maxBytes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String uploadUrl,  Map<String, String> requiredHeaders,  int maxBytes)?  $default,) {final _that = this;
switch (_that) {
case _UploadIntent() when $default != null:
return $default(_that.key,_that.uploadUrl,_that.requiredHeaders,_that.maxBytes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UploadIntent implements UploadIntent {
  const _UploadIntent({required this.key, required this.uploadUrl, final  Map<String, String> requiredHeaders = const <String, String>{}, this.maxBytes = 0}): _requiredHeaders = requiredHeaders;
  factory _UploadIntent.fromJson(Map<String, dynamic> json) => _$UploadIntentFromJson(json);

@override final  String key;
@override final  String uploadUrl;
 final  Map<String, String> _requiredHeaders;
@override@JsonKey() Map<String, String> get requiredHeaders {
  if (_requiredHeaders is EqualUnmodifiableMapView) return _requiredHeaders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_requiredHeaders);
}

@override@JsonKey() final  int maxBytes;

/// Create a copy of UploadIntent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadIntentCopyWith<_UploadIntent> get copyWith => __$UploadIntentCopyWithImpl<_UploadIntent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UploadIntentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadIntent&&(identical(other.key, key) || other.key == key)&&(identical(other.uploadUrl, uploadUrl) || other.uploadUrl == uploadUrl)&&const DeepCollectionEquality().equals(other._requiredHeaders, _requiredHeaders)&&(identical(other.maxBytes, maxBytes) || other.maxBytes == maxBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,uploadUrl,const DeepCollectionEquality().hash(_requiredHeaders),maxBytes);

@override
String toString() {
  return 'UploadIntent(key: $key, uploadUrl: $uploadUrl, requiredHeaders: $requiredHeaders, maxBytes: $maxBytes)';
}


}

/// @nodoc
abstract mixin class _$UploadIntentCopyWith<$Res> implements $UploadIntentCopyWith<$Res> {
  factory _$UploadIntentCopyWith(_UploadIntent value, $Res Function(_UploadIntent) _then) = __$UploadIntentCopyWithImpl;
@override @useResult
$Res call({
 String key, String uploadUrl, Map<String, String> requiredHeaders, int maxBytes
});




}
/// @nodoc
class __$UploadIntentCopyWithImpl<$Res>
    implements _$UploadIntentCopyWith<$Res> {
  __$UploadIntentCopyWithImpl(this._self, this._then);

  final _UploadIntent _self;
  final $Res Function(_UploadIntent) _then;

/// Create a copy of UploadIntent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? uploadUrl = null,Object? requiredHeaders = null,Object? maxBytes = null,}) {
  return _then(_UploadIntent(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,uploadUrl: null == uploadUrl ? _self.uploadUrl : uploadUrl // ignore: cast_nullable_to_non_nullable
as String,requiredHeaders: null == requiredHeaders ? _self._requiredHeaders : requiredHeaders // ignore: cast_nullable_to_non_nullable
as Map<String, String>,maxBytes: null == maxBytes ? _self.maxBytes : maxBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
