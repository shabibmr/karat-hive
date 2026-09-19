// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserSettingsDto {

 String get preferredLanguage;// en | ar
 String? get defaultRegionId; QuietHoursDto? get quietHours; String? get defaultFilterPresetId; Map<String, NotificationChannelPrefsDto> get notifications;
/// Create a copy of UserSettingsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserSettingsDtoCopyWith<UserSettingsDto> get copyWith => _$UserSettingsDtoCopyWithImpl<UserSettingsDto>(this as UserSettingsDto, _$identity);

  /// Serializes this UserSettingsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSettingsDto&&(identical(other.preferredLanguage, preferredLanguage) || other.preferredLanguage == preferredLanguage)&&(identical(other.defaultRegionId, defaultRegionId) || other.defaultRegionId == defaultRegionId)&&(identical(other.quietHours, quietHours) || other.quietHours == quietHours)&&(identical(other.defaultFilterPresetId, defaultFilterPresetId) || other.defaultFilterPresetId == defaultFilterPresetId)&&const DeepCollectionEquality().equals(other.notifications, notifications));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,preferredLanguage,defaultRegionId,quietHours,defaultFilterPresetId,const DeepCollectionEquality().hash(notifications));

@override
String toString() {
  return 'UserSettingsDto(preferredLanguage: $preferredLanguage, defaultRegionId: $defaultRegionId, quietHours: $quietHours, defaultFilterPresetId: $defaultFilterPresetId, notifications: $notifications)';
}


}

/// @nodoc
abstract mixin class $UserSettingsDtoCopyWith<$Res>  {
  factory $UserSettingsDtoCopyWith(UserSettingsDto value, $Res Function(UserSettingsDto) _then) = _$UserSettingsDtoCopyWithImpl;
@useResult
$Res call({
 String preferredLanguage, String? defaultRegionId, QuietHoursDto? quietHours, String? defaultFilterPresetId, Map<String, NotificationChannelPrefsDto> notifications
});


$QuietHoursDtoCopyWith<$Res>? get quietHours;

}
/// @nodoc
class _$UserSettingsDtoCopyWithImpl<$Res>
    implements $UserSettingsDtoCopyWith<$Res> {
  _$UserSettingsDtoCopyWithImpl(this._self, this._then);

  final UserSettingsDto _self;
  final $Res Function(UserSettingsDto) _then;

/// Create a copy of UserSettingsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? preferredLanguage = null,Object? defaultRegionId = freezed,Object? quietHours = freezed,Object? defaultFilterPresetId = freezed,Object? notifications = null,}) {
  return _then(_self.copyWith(
preferredLanguage: null == preferredLanguage ? _self.preferredLanguage : preferredLanguage // ignore: cast_nullable_to_non_nullable
as String,defaultRegionId: freezed == defaultRegionId ? _self.defaultRegionId : defaultRegionId // ignore: cast_nullable_to_non_nullable
as String?,quietHours: freezed == quietHours ? _self.quietHours : quietHours // ignore: cast_nullable_to_non_nullable
as QuietHoursDto?,defaultFilterPresetId: freezed == defaultFilterPresetId ? _self.defaultFilterPresetId : defaultFilterPresetId // ignore: cast_nullable_to_non_nullable
as String?,notifications: null == notifications ? _self.notifications : notifications // ignore: cast_nullable_to_non_nullable
as Map<String, NotificationChannelPrefsDto>,
  ));
}
/// Create a copy of UserSettingsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuietHoursDtoCopyWith<$Res>? get quietHours {
    if (_self.quietHours == null) {
    return null;
  }

  return $QuietHoursDtoCopyWith<$Res>(_self.quietHours!, (value) {
    return _then(_self.copyWith(quietHours: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserSettingsDto].
extension UserSettingsDtoPatterns on UserSettingsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserSettingsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserSettingsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserSettingsDto value)  $default,){
final _that = this;
switch (_that) {
case _UserSettingsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserSettingsDto value)?  $default,){
final _that = this;
switch (_that) {
case _UserSettingsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String preferredLanguage,  String? defaultRegionId,  QuietHoursDto? quietHours,  String? defaultFilterPresetId,  Map<String, NotificationChannelPrefsDto> notifications)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserSettingsDto() when $default != null:
return $default(_that.preferredLanguage,_that.defaultRegionId,_that.quietHours,_that.defaultFilterPresetId,_that.notifications);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String preferredLanguage,  String? defaultRegionId,  QuietHoursDto? quietHours,  String? defaultFilterPresetId,  Map<String, NotificationChannelPrefsDto> notifications)  $default,) {final _that = this;
switch (_that) {
case _UserSettingsDto():
return $default(_that.preferredLanguage,_that.defaultRegionId,_that.quietHours,_that.defaultFilterPresetId,_that.notifications);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String preferredLanguage,  String? defaultRegionId,  QuietHoursDto? quietHours,  String? defaultFilterPresetId,  Map<String, NotificationChannelPrefsDto> notifications)?  $default,) {final _that = this;
switch (_that) {
case _UserSettingsDto() when $default != null:
return $default(_that.preferredLanguage,_that.defaultRegionId,_that.quietHours,_that.defaultFilterPresetId,_that.notifications);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserSettingsDto implements UserSettingsDto {
  const _UserSettingsDto({required this.preferredLanguage, this.defaultRegionId, this.quietHours, this.defaultFilterPresetId, final  Map<String, NotificationChannelPrefsDto> notifications = const <String, NotificationChannelPrefsDto>{}}): _notifications = notifications;
  factory _UserSettingsDto.fromJson(Map<String, dynamic> json) => _$UserSettingsDtoFromJson(json);

@override final  String preferredLanguage;
// en | ar
@override final  String? defaultRegionId;
@override final  QuietHoursDto? quietHours;
@override final  String? defaultFilterPresetId;
 final  Map<String, NotificationChannelPrefsDto> _notifications;
@override@JsonKey() Map<String, NotificationChannelPrefsDto> get notifications {
  if (_notifications is EqualUnmodifiableMapView) return _notifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_notifications);
}


/// Create a copy of UserSettingsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserSettingsDtoCopyWith<_UserSettingsDto> get copyWith => __$UserSettingsDtoCopyWithImpl<_UserSettingsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserSettingsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSettingsDto&&(identical(other.preferredLanguage, preferredLanguage) || other.preferredLanguage == preferredLanguage)&&(identical(other.defaultRegionId, defaultRegionId) || other.defaultRegionId == defaultRegionId)&&(identical(other.quietHours, quietHours) || other.quietHours == quietHours)&&(identical(other.defaultFilterPresetId, defaultFilterPresetId) || other.defaultFilterPresetId == defaultFilterPresetId)&&const DeepCollectionEquality().equals(other._notifications, _notifications));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,preferredLanguage,defaultRegionId,quietHours,defaultFilterPresetId,const DeepCollectionEquality().hash(_notifications));

@override
String toString() {
  return 'UserSettingsDto(preferredLanguage: $preferredLanguage, defaultRegionId: $defaultRegionId, quietHours: $quietHours, defaultFilterPresetId: $defaultFilterPresetId, notifications: $notifications)';
}


}

/// @nodoc
abstract mixin class _$UserSettingsDtoCopyWith<$Res> implements $UserSettingsDtoCopyWith<$Res> {
  factory _$UserSettingsDtoCopyWith(_UserSettingsDto value, $Res Function(_UserSettingsDto) _then) = __$UserSettingsDtoCopyWithImpl;
@override @useResult
$Res call({
 String preferredLanguage, String? defaultRegionId, QuietHoursDto? quietHours, String? defaultFilterPresetId, Map<String, NotificationChannelPrefsDto> notifications
});


@override $QuietHoursDtoCopyWith<$Res>? get quietHours;

}
/// @nodoc
class __$UserSettingsDtoCopyWithImpl<$Res>
    implements _$UserSettingsDtoCopyWith<$Res> {
  __$UserSettingsDtoCopyWithImpl(this._self, this._then);

  final _UserSettingsDto _self;
  final $Res Function(_UserSettingsDto) _then;

/// Create a copy of UserSettingsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? preferredLanguage = null,Object? defaultRegionId = freezed,Object? quietHours = freezed,Object? defaultFilterPresetId = freezed,Object? notifications = null,}) {
  return _then(_UserSettingsDto(
preferredLanguage: null == preferredLanguage ? _self.preferredLanguage : preferredLanguage // ignore: cast_nullable_to_non_nullable
as String,defaultRegionId: freezed == defaultRegionId ? _self.defaultRegionId : defaultRegionId // ignore: cast_nullable_to_non_nullable
as String?,quietHours: freezed == quietHours ? _self.quietHours : quietHours // ignore: cast_nullable_to_non_nullable
as QuietHoursDto?,defaultFilterPresetId: freezed == defaultFilterPresetId ? _self.defaultFilterPresetId : defaultFilterPresetId // ignore: cast_nullable_to_non_nullable
as String?,notifications: null == notifications ? _self._notifications : notifications // ignore: cast_nullable_to_non_nullable
as Map<String, NotificationChannelPrefsDto>,
  ));
}

/// Create a copy of UserSettingsDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuietHoursDtoCopyWith<$Res>? get quietHours {
    if (_self.quietHours == null) {
    return null;
  }

  return $QuietHoursDtoCopyWith<$Res>(_self.quietHours!, (value) {
    return _then(_self.copyWith(quietHours: value));
  });
}
}


/// @nodoc
mixin _$QuietHoursDto {

 String get start; String get end;// Never sent back to the server — outbound payloads are start/end only.
@JsonKey(includeToJson: false) String get timezone;
/// Create a copy of QuietHoursDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuietHoursDtoCopyWith<QuietHoursDto> get copyWith => _$QuietHoursDtoCopyWithImpl<QuietHoursDto>(this as QuietHoursDto, _$identity);

  /// Serializes this QuietHoursDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuietHoursDto&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.timezone, timezone) || other.timezone == timezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,start,end,timezone);

@override
String toString() {
  return 'QuietHoursDto(start: $start, end: $end, timezone: $timezone)';
}


}

/// @nodoc
abstract mixin class $QuietHoursDtoCopyWith<$Res>  {
  factory $QuietHoursDtoCopyWith(QuietHoursDto value, $Res Function(QuietHoursDto) _then) = _$QuietHoursDtoCopyWithImpl;
@useResult
$Res call({
 String start, String end,@JsonKey(includeToJson: false) String timezone
});




}
/// @nodoc
class _$QuietHoursDtoCopyWithImpl<$Res>
    implements $QuietHoursDtoCopyWith<$Res> {
  _$QuietHoursDtoCopyWithImpl(this._self, this._then);

  final QuietHoursDto _self;
  final $Res Function(QuietHoursDto) _then;

/// Create a copy of QuietHoursDto
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


/// Adds pattern-matching-related methods to [QuietHoursDto].
extension QuietHoursDtoPatterns on QuietHoursDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuietHoursDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuietHoursDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuietHoursDto value)  $default,){
final _that = this;
switch (_that) {
case _QuietHoursDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuietHoursDto value)?  $default,){
final _that = this;
switch (_that) {
case _QuietHoursDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String start,  String end, @JsonKey(includeToJson: false)  String timezone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuietHoursDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String start,  String end, @JsonKey(includeToJson: false)  String timezone)  $default,) {final _that = this;
switch (_that) {
case _QuietHoursDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String start,  String end, @JsonKey(includeToJson: false)  String timezone)?  $default,) {final _that = this;
switch (_that) {
case _QuietHoursDto() when $default != null:
return $default(_that.start,_that.end,_that.timezone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuietHoursDto implements QuietHoursDto {
  const _QuietHoursDto({required this.start, required this.end, @JsonKey(includeToJson: false) this.timezone = 'Asia/Dubai'});
  factory _QuietHoursDto.fromJson(Map<String, dynamic> json) => _$QuietHoursDtoFromJson(json);

@override final  String start;
@override final  String end;
// Never sent back to the server — outbound payloads are start/end only.
@override@JsonKey(includeToJson: false) final  String timezone;

/// Create a copy of QuietHoursDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuietHoursDtoCopyWith<_QuietHoursDto> get copyWith => __$QuietHoursDtoCopyWithImpl<_QuietHoursDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuietHoursDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuietHoursDto&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.timezone, timezone) || other.timezone == timezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,start,end,timezone);

@override
String toString() {
  return 'QuietHoursDto(start: $start, end: $end, timezone: $timezone)';
}


}

/// @nodoc
abstract mixin class _$QuietHoursDtoCopyWith<$Res> implements $QuietHoursDtoCopyWith<$Res> {
  factory _$QuietHoursDtoCopyWith(_QuietHoursDto value, $Res Function(_QuietHoursDto) _then) = __$QuietHoursDtoCopyWithImpl;
@override @useResult
$Res call({
 String start, String end,@JsonKey(includeToJson: false) String timezone
});




}
/// @nodoc
class __$QuietHoursDtoCopyWithImpl<$Res>
    implements _$QuietHoursDtoCopyWith<$Res> {
  __$QuietHoursDtoCopyWithImpl(this._self, this._then);

  final _QuietHoursDto _self;
  final $Res Function(_QuietHoursDto) _then;

/// Create a copy of QuietHoursDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? start = null,Object? end = null,Object? timezone = null,}) {
  return _then(_QuietHoursDto(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$NotificationChannelPrefsDto {

 bool get inApp; bool get push; bool get email;
/// Create a copy of NotificationChannelPrefsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationChannelPrefsDtoCopyWith<NotificationChannelPrefsDto> get copyWith => _$NotificationChannelPrefsDtoCopyWithImpl<NotificationChannelPrefsDto>(this as NotificationChannelPrefsDto, _$identity);

  /// Serializes this NotificationChannelPrefsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationChannelPrefsDto&&(identical(other.inApp, inApp) || other.inApp == inApp)&&(identical(other.push, push) || other.push == push)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,inApp,push,email);

@override
String toString() {
  return 'NotificationChannelPrefsDto(inApp: $inApp, push: $push, email: $email)';
}


}

/// @nodoc
abstract mixin class $NotificationChannelPrefsDtoCopyWith<$Res>  {
  factory $NotificationChannelPrefsDtoCopyWith(NotificationChannelPrefsDto value, $Res Function(NotificationChannelPrefsDto) _then) = _$NotificationChannelPrefsDtoCopyWithImpl;
@useResult
$Res call({
 bool inApp, bool push, bool email
});




}
/// @nodoc
class _$NotificationChannelPrefsDtoCopyWithImpl<$Res>
    implements $NotificationChannelPrefsDtoCopyWith<$Res> {
  _$NotificationChannelPrefsDtoCopyWithImpl(this._self, this._then);

  final NotificationChannelPrefsDto _self;
  final $Res Function(NotificationChannelPrefsDto) _then;

/// Create a copy of NotificationChannelPrefsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? inApp = null,Object? push = null,Object? email = null,}) {
  return _then(_self.copyWith(
inApp: null == inApp ? _self.inApp : inApp // ignore: cast_nullable_to_non_nullable
as bool,push: null == push ? _self.push : push // ignore: cast_nullable_to_non_nullable
as bool,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationChannelPrefsDto].
extension NotificationChannelPrefsDtoPatterns on NotificationChannelPrefsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationChannelPrefsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationChannelPrefsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationChannelPrefsDto value)  $default,){
final _that = this;
switch (_that) {
case _NotificationChannelPrefsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationChannelPrefsDto value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationChannelPrefsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool inApp,  bool push,  bool email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationChannelPrefsDto() when $default != null:
return $default(_that.inApp,_that.push,_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool inApp,  bool push,  bool email)  $default,) {final _that = this;
switch (_that) {
case _NotificationChannelPrefsDto():
return $default(_that.inApp,_that.push,_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool inApp,  bool push,  bool email)?  $default,) {final _that = this;
switch (_that) {
case _NotificationChannelPrefsDto() when $default != null:
return $default(_that.inApp,_that.push,_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationChannelPrefsDto implements NotificationChannelPrefsDto {
  const _NotificationChannelPrefsDto({this.inApp = true, this.push = true, this.email = false});
  factory _NotificationChannelPrefsDto.fromJson(Map<String, dynamic> json) => _$NotificationChannelPrefsDtoFromJson(json);

@override@JsonKey() final  bool inApp;
@override@JsonKey() final  bool push;
@override@JsonKey() final  bool email;

/// Create a copy of NotificationChannelPrefsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationChannelPrefsDtoCopyWith<_NotificationChannelPrefsDto> get copyWith => __$NotificationChannelPrefsDtoCopyWithImpl<_NotificationChannelPrefsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationChannelPrefsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationChannelPrefsDto&&(identical(other.inApp, inApp) || other.inApp == inApp)&&(identical(other.push, push) || other.push == push)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,inApp,push,email);

@override
String toString() {
  return 'NotificationChannelPrefsDto(inApp: $inApp, push: $push, email: $email)';
}


}

/// @nodoc
abstract mixin class _$NotificationChannelPrefsDtoCopyWith<$Res> implements $NotificationChannelPrefsDtoCopyWith<$Res> {
  factory _$NotificationChannelPrefsDtoCopyWith(_NotificationChannelPrefsDto value, $Res Function(_NotificationChannelPrefsDto) _then) = __$NotificationChannelPrefsDtoCopyWithImpl;
@override @useResult
$Res call({
 bool inApp, bool push, bool email
});




}
/// @nodoc
class __$NotificationChannelPrefsDtoCopyWithImpl<$Res>
    implements _$NotificationChannelPrefsDtoCopyWith<$Res> {
  __$NotificationChannelPrefsDtoCopyWithImpl(this._self, this._then);

  final _NotificationChannelPrefsDto _self;
  final $Res Function(_NotificationChannelPrefsDto) _then;

/// Create a copy of NotificationChannelPrefsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? inApp = null,Object? push = null,Object? email = null,}) {
  return _then(_NotificationChannelPrefsDto(
inApp: null == inApp ? _self.inApp : inApp // ignore: cast_nullable_to_non_nullable
as bool,push: null == push ? _self.push : push // ignore: cast_nullable_to_non_nullable
as bool,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PlatformConfigDto {

 int get requestLifetimeHours; List<int> get offerValidityHours; int get defaultOfferValidityHours; String get bullionMinimumAed; int get maxConcurrentLiveRequests; int get maxRequestImages; int get maxOfferImages; int get maxImageBytes; List<String> get acceptedImageTypes; List<String> get karatList; int get maxOfferRevisions; int get requestExpiryWarningHours; String get termsUrl; String get privacyUrl; String get supportContactUrl; String get subscriptionContactUrl;
/// Create a copy of PlatformConfigDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlatformConfigDtoCopyWith<PlatformConfigDto> get copyWith => _$PlatformConfigDtoCopyWithImpl<PlatformConfigDto>(this as PlatformConfigDto, _$identity);

  /// Serializes this PlatformConfigDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlatformConfigDto&&(identical(other.requestLifetimeHours, requestLifetimeHours) || other.requestLifetimeHours == requestLifetimeHours)&&const DeepCollectionEquality().equals(other.offerValidityHours, offerValidityHours)&&(identical(other.defaultOfferValidityHours, defaultOfferValidityHours) || other.defaultOfferValidityHours == defaultOfferValidityHours)&&(identical(other.bullionMinimumAed, bullionMinimumAed) || other.bullionMinimumAed == bullionMinimumAed)&&(identical(other.maxConcurrentLiveRequests, maxConcurrentLiveRequests) || other.maxConcurrentLiveRequests == maxConcurrentLiveRequests)&&(identical(other.maxRequestImages, maxRequestImages) || other.maxRequestImages == maxRequestImages)&&(identical(other.maxOfferImages, maxOfferImages) || other.maxOfferImages == maxOfferImages)&&(identical(other.maxImageBytes, maxImageBytes) || other.maxImageBytes == maxImageBytes)&&const DeepCollectionEquality().equals(other.acceptedImageTypes, acceptedImageTypes)&&const DeepCollectionEquality().equals(other.karatList, karatList)&&(identical(other.maxOfferRevisions, maxOfferRevisions) || other.maxOfferRevisions == maxOfferRevisions)&&(identical(other.requestExpiryWarningHours, requestExpiryWarningHours) || other.requestExpiryWarningHours == requestExpiryWarningHours)&&(identical(other.termsUrl, termsUrl) || other.termsUrl == termsUrl)&&(identical(other.privacyUrl, privacyUrl) || other.privacyUrl == privacyUrl)&&(identical(other.supportContactUrl, supportContactUrl) || other.supportContactUrl == supportContactUrl)&&(identical(other.subscriptionContactUrl, subscriptionContactUrl) || other.subscriptionContactUrl == subscriptionContactUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requestLifetimeHours,const DeepCollectionEquality().hash(offerValidityHours),defaultOfferValidityHours,bullionMinimumAed,maxConcurrentLiveRequests,maxRequestImages,maxOfferImages,maxImageBytes,const DeepCollectionEquality().hash(acceptedImageTypes),const DeepCollectionEquality().hash(karatList),maxOfferRevisions,requestExpiryWarningHours,termsUrl,privacyUrl,supportContactUrl,subscriptionContactUrl);

@override
String toString() {
  return 'PlatformConfigDto(requestLifetimeHours: $requestLifetimeHours, offerValidityHours: $offerValidityHours, defaultOfferValidityHours: $defaultOfferValidityHours, bullionMinimumAed: $bullionMinimumAed, maxConcurrentLiveRequests: $maxConcurrentLiveRequests, maxRequestImages: $maxRequestImages, maxOfferImages: $maxOfferImages, maxImageBytes: $maxImageBytes, acceptedImageTypes: $acceptedImageTypes, karatList: $karatList, maxOfferRevisions: $maxOfferRevisions, requestExpiryWarningHours: $requestExpiryWarningHours, termsUrl: $termsUrl, privacyUrl: $privacyUrl, supportContactUrl: $supportContactUrl, subscriptionContactUrl: $subscriptionContactUrl)';
}


}

/// @nodoc
abstract mixin class $PlatformConfigDtoCopyWith<$Res>  {
  factory $PlatformConfigDtoCopyWith(PlatformConfigDto value, $Res Function(PlatformConfigDto) _then) = _$PlatformConfigDtoCopyWithImpl;
@useResult
$Res call({
 int requestLifetimeHours, List<int> offerValidityHours, int defaultOfferValidityHours, String bullionMinimumAed, int maxConcurrentLiveRequests, int maxRequestImages, int maxOfferImages, int maxImageBytes, List<String> acceptedImageTypes, List<String> karatList, int maxOfferRevisions, int requestExpiryWarningHours, String termsUrl, String privacyUrl, String supportContactUrl, String subscriptionContactUrl
});




}
/// @nodoc
class _$PlatformConfigDtoCopyWithImpl<$Res>
    implements $PlatformConfigDtoCopyWith<$Res> {
  _$PlatformConfigDtoCopyWithImpl(this._self, this._then);

  final PlatformConfigDto _self;
  final $Res Function(PlatformConfigDto) _then;

/// Create a copy of PlatformConfigDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requestLifetimeHours = null,Object? offerValidityHours = null,Object? defaultOfferValidityHours = null,Object? bullionMinimumAed = null,Object? maxConcurrentLiveRequests = null,Object? maxRequestImages = null,Object? maxOfferImages = null,Object? maxImageBytes = null,Object? acceptedImageTypes = null,Object? karatList = null,Object? maxOfferRevisions = null,Object? requestExpiryWarningHours = null,Object? termsUrl = null,Object? privacyUrl = null,Object? supportContactUrl = null,Object? subscriptionContactUrl = null,}) {
  return _then(_self.copyWith(
requestLifetimeHours: null == requestLifetimeHours ? _self.requestLifetimeHours : requestLifetimeHours // ignore: cast_nullable_to_non_nullable
as int,offerValidityHours: null == offerValidityHours ? _self.offerValidityHours : offerValidityHours // ignore: cast_nullable_to_non_nullable
as List<int>,defaultOfferValidityHours: null == defaultOfferValidityHours ? _self.defaultOfferValidityHours : defaultOfferValidityHours // ignore: cast_nullable_to_non_nullable
as int,bullionMinimumAed: null == bullionMinimumAed ? _self.bullionMinimumAed : bullionMinimumAed // ignore: cast_nullable_to_non_nullable
as String,maxConcurrentLiveRequests: null == maxConcurrentLiveRequests ? _self.maxConcurrentLiveRequests : maxConcurrentLiveRequests // ignore: cast_nullable_to_non_nullable
as int,maxRequestImages: null == maxRequestImages ? _self.maxRequestImages : maxRequestImages // ignore: cast_nullable_to_non_nullable
as int,maxOfferImages: null == maxOfferImages ? _self.maxOfferImages : maxOfferImages // ignore: cast_nullable_to_non_nullable
as int,maxImageBytes: null == maxImageBytes ? _self.maxImageBytes : maxImageBytes // ignore: cast_nullable_to_non_nullable
as int,acceptedImageTypes: null == acceptedImageTypes ? _self.acceptedImageTypes : acceptedImageTypes // ignore: cast_nullable_to_non_nullable
as List<String>,karatList: null == karatList ? _self.karatList : karatList // ignore: cast_nullable_to_non_nullable
as List<String>,maxOfferRevisions: null == maxOfferRevisions ? _self.maxOfferRevisions : maxOfferRevisions // ignore: cast_nullable_to_non_nullable
as int,requestExpiryWarningHours: null == requestExpiryWarningHours ? _self.requestExpiryWarningHours : requestExpiryWarningHours // ignore: cast_nullable_to_non_nullable
as int,termsUrl: null == termsUrl ? _self.termsUrl : termsUrl // ignore: cast_nullable_to_non_nullable
as String,privacyUrl: null == privacyUrl ? _self.privacyUrl : privacyUrl // ignore: cast_nullable_to_non_nullable
as String,supportContactUrl: null == supportContactUrl ? _self.supportContactUrl : supportContactUrl // ignore: cast_nullable_to_non_nullable
as String,subscriptionContactUrl: null == subscriptionContactUrl ? _self.subscriptionContactUrl : subscriptionContactUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PlatformConfigDto].
extension PlatformConfigDtoPatterns on PlatformConfigDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlatformConfigDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlatformConfigDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlatformConfigDto value)  $default,){
final _that = this;
switch (_that) {
case _PlatformConfigDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlatformConfigDto value)?  $default,){
final _that = this;
switch (_that) {
case _PlatformConfigDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int requestLifetimeHours,  List<int> offerValidityHours,  int defaultOfferValidityHours,  String bullionMinimumAed,  int maxConcurrentLiveRequests,  int maxRequestImages,  int maxOfferImages,  int maxImageBytes,  List<String> acceptedImageTypes,  List<String> karatList,  int maxOfferRevisions,  int requestExpiryWarningHours,  String termsUrl,  String privacyUrl,  String supportContactUrl,  String subscriptionContactUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlatformConfigDto() when $default != null:
return $default(_that.requestLifetimeHours,_that.offerValidityHours,_that.defaultOfferValidityHours,_that.bullionMinimumAed,_that.maxConcurrentLiveRequests,_that.maxRequestImages,_that.maxOfferImages,_that.maxImageBytes,_that.acceptedImageTypes,_that.karatList,_that.maxOfferRevisions,_that.requestExpiryWarningHours,_that.termsUrl,_that.privacyUrl,_that.supportContactUrl,_that.subscriptionContactUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int requestLifetimeHours,  List<int> offerValidityHours,  int defaultOfferValidityHours,  String bullionMinimumAed,  int maxConcurrentLiveRequests,  int maxRequestImages,  int maxOfferImages,  int maxImageBytes,  List<String> acceptedImageTypes,  List<String> karatList,  int maxOfferRevisions,  int requestExpiryWarningHours,  String termsUrl,  String privacyUrl,  String supportContactUrl,  String subscriptionContactUrl)  $default,) {final _that = this;
switch (_that) {
case _PlatformConfigDto():
return $default(_that.requestLifetimeHours,_that.offerValidityHours,_that.defaultOfferValidityHours,_that.bullionMinimumAed,_that.maxConcurrentLiveRequests,_that.maxRequestImages,_that.maxOfferImages,_that.maxImageBytes,_that.acceptedImageTypes,_that.karatList,_that.maxOfferRevisions,_that.requestExpiryWarningHours,_that.termsUrl,_that.privacyUrl,_that.supportContactUrl,_that.subscriptionContactUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int requestLifetimeHours,  List<int> offerValidityHours,  int defaultOfferValidityHours,  String bullionMinimumAed,  int maxConcurrentLiveRequests,  int maxRequestImages,  int maxOfferImages,  int maxImageBytes,  List<String> acceptedImageTypes,  List<String> karatList,  int maxOfferRevisions,  int requestExpiryWarningHours,  String termsUrl,  String privacyUrl,  String supportContactUrl,  String subscriptionContactUrl)?  $default,) {final _that = this;
switch (_that) {
case _PlatformConfigDto() when $default != null:
return $default(_that.requestLifetimeHours,_that.offerValidityHours,_that.defaultOfferValidityHours,_that.bullionMinimumAed,_that.maxConcurrentLiveRequests,_that.maxRequestImages,_that.maxOfferImages,_that.maxImageBytes,_that.acceptedImageTypes,_that.karatList,_that.maxOfferRevisions,_that.requestExpiryWarningHours,_that.termsUrl,_that.privacyUrl,_that.supportContactUrl,_that.subscriptionContactUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlatformConfigDto implements PlatformConfigDto {
  const _PlatformConfigDto({required this.requestLifetimeHours, required final  List<int> offerValidityHours, required this.defaultOfferValidityHours, required this.bullionMinimumAed, required this.maxConcurrentLiveRequests, required this.maxRequestImages, required this.maxOfferImages, required this.maxImageBytes, required final  List<String> acceptedImageTypes, required final  List<String> karatList, required this.maxOfferRevisions, required this.requestExpiryWarningHours, required this.termsUrl, required this.privacyUrl, required this.supportContactUrl, required this.subscriptionContactUrl}): _offerValidityHours = offerValidityHours,_acceptedImageTypes = acceptedImageTypes,_karatList = karatList;
  factory _PlatformConfigDto.fromJson(Map<String, dynamic> json) => _$PlatformConfigDtoFromJson(json);

@override final  int requestLifetimeHours;
 final  List<int> _offerValidityHours;
@override List<int> get offerValidityHours {
  if (_offerValidityHours is EqualUnmodifiableListView) return _offerValidityHours;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_offerValidityHours);
}

@override final  int defaultOfferValidityHours;
@override final  String bullionMinimumAed;
@override final  int maxConcurrentLiveRequests;
@override final  int maxRequestImages;
@override final  int maxOfferImages;
@override final  int maxImageBytes;
 final  List<String> _acceptedImageTypes;
@override List<String> get acceptedImageTypes {
  if (_acceptedImageTypes is EqualUnmodifiableListView) return _acceptedImageTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_acceptedImageTypes);
}

 final  List<String> _karatList;
@override List<String> get karatList {
  if (_karatList is EqualUnmodifiableListView) return _karatList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_karatList);
}

@override final  int maxOfferRevisions;
@override final  int requestExpiryWarningHours;
@override final  String termsUrl;
@override final  String privacyUrl;
@override final  String supportContactUrl;
@override final  String subscriptionContactUrl;

/// Create a copy of PlatformConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlatformConfigDtoCopyWith<_PlatformConfigDto> get copyWith => __$PlatformConfigDtoCopyWithImpl<_PlatformConfigDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlatformConfigDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlatformConfigDto&&(identical(other.requestLifetimeHours, requestLifetimeHours) || other.requestLifetimeHours == requestLifetimeHours)&&const DeepCollectionEquality().equals(other._offerValidityHours, _offerValidityHours)&&(identical(other.defaultOfferValidityHours, defaultOfferValidityHours) || other.defaultOfferValidityHours == defaultOfferValidityHours)&&(identical(other.bullionMinimumAed, bullionMinimumAed) || other.bullionMinimumAed == bullionMinimumAed)&&(identical(other.maxConcurrentLiveRequests, maxConcurrentLiveRequests) || other.maxConcurrentLiveRequests == maxConcurrentLiveRequests)&&(identical(other.maxRequestImages, maxRequestImages) || other.maxRequestImages == maxRequestImages)&&(identical(other.maxOfferImages, maxOfferImages) || other.maxOfferImages == maxOfferImages)&&(identical(other.maxImageBytes, maxImageBytes) || other.maxImageBytes == maxImageBytes)&&const DeepCollectionEquality().equals(other._acceptedImageTypes, _acceptedImageTypes)&&const DeepCollectionEquality().equals(other._karatList, _karatList)&&(identical(other.maxOfferRevisions, maxOfferRevisions) || other.maxOfferRevisions == maxOfferRevisions)&&(identical(other.requestExpiryWarningHours, requestExpiryWarningHours) || other.requestExpiryWarningHours == requestExpiryWarningHours)&&(identical(other.termsUrl, termsUrl) || other.termsUrl == termsUrl)&&(identical(other.privacyUrl, privacyUrl) || other.privacyUrl == privacyUrl)&&(identical(other.supportContactUrl, supportContactUrl) || other.supportContactUrl == supportContactUrl)&&(identical(other.subscriptionContactUrl, subscriptionContactUrl) || other.subscriptionContactUrl == subscriptionContactUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requestLifetimeHours,const DeepCollectionEquality().hash(_offerValidityHours),defaultOfferValidityHours,bullionMinimumAed,maxConcurrentLiveRequests,maxRequestImages,maxOfferImages,maxImageBytes,const DeepCollectionEquality().hash(_acceptedImageTypes),const DeepCollectionEquality().hash(_karatList),maxOfferRevisions,requestExpiryWarningHours,termsUrl,privacyUrl,supportContactUrl,subscriptionContactUrl);

@override
String toString() {
  return 'PlatformConfigDto(requestLifetimeHours: $requestLifetimeHours, offerValidityHours: $offerValidityHours, defaultOfferValidityHours: $defaultOfferValidityHours, bullionMinimumAed: $bullionMinimumAed, maxConcurrentLiveRequests: $maxConcurrentLiveRequests, maxRequestImages: $maxRequestImages, maxOfferImages: $maxOfferImages, maxImageBytes: $maxImageBytes, acceptedImageTypes: $acceptedImageTypes, karatList: $karatList, maxOfferRevisions: $maxOfferRevisions, requestExpiryWarningHours: $requestExpiryWarningHours, termsUrl: $termsUrl, privacyUrl: $privacyUrl, supportContactUrl: $supportContactUrl, subscriptionContactUrl: $subscriptionContactUrl)';
}


}

/// @nodoc
abstract mixin class _$PlatformConfigDtoCopyWith<$Res> implements $PlatformConfigDtoCopyWith<$Res> {
  factory _$PlatformConfigDtoCopyWith(_PlatformConfigDto value, $Res Function(_PlatformConfigDto) _then) = __$PlatformConfigDtoCopyWithImpl;
@override @useResult
$Res call({
 int requestLifetimeHours, List<int> offerValidityHours, int defaultOfferValidityHours, String bullionMinimumAed, int maxConcurrentLiveRequests, int maxRequestImages, int maxOfferImages, int maxImageBytes, List<String> acceptedImageTypes, List<String> karatList, int maxOfferRevisions, int requestExpiryWarningHours, String termsUrl, String privacyUrl, String supportContactUrl, String subscriptionContactUrl
});




}
/// @nodoc
class __$PlatformConfigDtoCopyWithImpl<$Res>
    implements _$PlatformConfigDtoCopyWith<$Res> {
  __$PlatformConfigDtoCopyWithImpl(this._self, this._then);

  final _PlatformConfigDto _self;
  final $Res Function(_PlatformConfigDto) _then;

/// Create a copy of PlatformConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requestLifetimeHours = null,Object? offerValidityHours = null,Object? defaultOfferValidityHours = null,Object? bullionMinimumAed = null,Object? maxConcurrentLiveRequests = null,Object? maxRequestImages = null,Object? maxOfferImages = null,Object? maxImageBytes = null,Object? acceptedImageTypes = null,Object? karatList = null,Object? maxOfferRevisions = null,Object? requestExpiryWarningHours = null,Object? termsUrl = null,Object? privacyUrl = null,Object? supportContactUrl = null,Object? subscriptionContactUrl = null,}) {
  return _then(_PlatformConfigDto(
requestLifetimeHours: null == requestLifetimeHours ? _self.requestLifetimeHours : requestLifetimeHours // ignore: cast_nullable_to_non_nullable
as int,offerValidityHours: null == offerValidityHours ? _self._offerValidityHours : offerValidityHours // ignore: cast_nullable_to_non_nullable
as List<int>,defaultOfferValidityHours: null == defaultOfferValidityHours ? _self.defaultOfferValidityHours : defaultOfferValidityHours // ignore: cast_nullable_to_non_nullable
as int,bullionMinimumAed: null == bullionMinimumAed ? _self.bullionMinimumAed : bullionMinimumAed // ignore: cast_nullable_to_non_nullable
as String,maxConcurrentLiveRequests: null == maxConcurrentLiveRequests ? _self.maxConcurrentLiveRequests : maxConcurrentLiveRequests // ignore: cast_nullable_to_non_nullable
as int,maxRequestImages: null == maxRequestImages ? _self.maxRequestImages : maxRequestImages // ignore: cast_nullable_to_non_nullable
as int,maxOfferImages: null == maxOfferImages ? _self.maxOfferImages : maxOfferImages // ignore: cast_nullable_to_non_nullable
as int,maxImageBytes: null == maxImageBytes ? _self.maxImageBytes : maxImageBytes // ignore: cast_nullable_to_non_nullable
as int,acceptedImageTypes: null == acceptedImageTypes ? _self._acceptedImageTypes : acceptedImageTypes // ignore: cast_nullable_to_non_nullable
as List<String>,karatList: null == karatList ? _self._karatList : karatList // ignore: cast_nullable_to_non_nullable
as List<String>,maxOfferRevisions: null == maxOfferRevisions ? _self.maxOfferRevisions : maxOfferRevisions // ignore: cast_nullable_to_non_nullable
as int,requestExpiryWarningHours: null == requestExpiryWarningHours ? _self.requestExpiryWarningHours : requestExpiryWarningHours // ignore: cast_nullable_to_non_nullable
as int,termsUrl: null == termsUrl ? _self.termsUrl : termsUrl // ignore: cast_nullable_to_non_nullable
as String,privacyUrl: null == privacyUrl ? _self.privacyUrl : privacyUrl // ignore: cast_nullable_to_non_nullable
as String,supportContactUrl: null == supportContactUrl ? _self.supportContactUrl : supportContactUrl // ignore: cast_nullable_to_non_nullable
as String,subscriptionContactUrl: null == subscriptionContactUrl ? _self.subscriptionContactUrl : subscriptionContactUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
