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
mixin _$VendorMe {

 String get vendorProfileId;@_VendorLifecycleConverter() VendorLifecycle get lifecycle; bool get awaitingApproval; String get tradingName; String get legalBusinessName; int get categoryCount; int get regionCount; List<String> get categoryIds; List<String> get regionIds; bool get awayMode;@_AwaitingApprovalReasonConverter() AwaitingApprovalReason? get awaitingApprovalReason; String? get verificationMessage;
/// Create a copy of VendorMe
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorMeCopyWith<VendorMe> get copyWith => _$VendorMeCopyWithImpl<VendorMe>(this as VendorMe, _$identity);

  /// Serializes this VendorMe to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorMe&&(identical(other.vendorProfileId, vendorProfileId) || other.vendorProfileId == vendorProfileId)&&(identical(other.lifecycle, lifecycle) || other.lifecycle == lifecycle)&&(identical(other.awaitingApproval, awaitingApproval) || other.awaitingApproval == awaitingApproval)&&(identical(other.tradingName, tradingName) || other.tradingName == tradingName)&&(identical(other.legalBusinessName, legalBusinessName) || other.legalBusinessName == legalBusinessName)&&(identical(other.categoryCount, categoryCount) || other.categoryCount == categoryCount)&&(identical(other.regionCount, regionCount) || other.regionCount == regionCount)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds)&&const DeepCollectionEquality().equals(other.regionIds, regionIds)&&(identical(other.awayMode, awayMode) || other.awayMode == awayMode)&&(identical(other.awaitingApprovalReason, awaitingApprovalReason) || other.awaitingApprovalReason == awaitingApprovalReason)&&(identical(other.verificationMessage, verificationMessage) || other.verificationMessage == verificationMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vendorProfileId,lifecycle,awaitingApproval,tradingName,legalBusinessName,categoryCount,regionCount,const DeepCollectionEquality().hash(categoryIds),const DeepCollectionEquality().hash(regionIds),awayMode,awaitingApprovalReason,verificationMessage);

@override
String toString() {
  return 'VendorMe(vendorProfileId: $vendorProfileId, lifecycle: $lifecycle, awaitingApproval: $awaitingApproval, tradingName: $tradingName, legalBusinessName: $legalBusinessName, categoryCount: $categoryCount, regionCount: $regionCount, categoryIds: $categoryIds, regionIds: $regionIds, awayMode: $awayMode, awaitingApprovalReason: $awaitingApprovalReason, verificationMessage: $verificationMessage)';
}


}

/// @nodoc
abstract mixin class $VendorMeCopyWith<$Res>  {
  factory $VendorMeCopyWith(VendorMe value, $Res Function(VendorMe) _then) = _$VendorMeCopyWithImpl;
@useResult
$Res call({
 String vendorProfileId,@_VendorLifecycleConverter() VendorLifecycle lifecycle, bool awaitingApproval, String tradingName, String legalBusinessName, int categoryCount, int regionCount, List<String> categoryIds, List<String> regionIds, bool awayMode,@_AwaitingApprovalReasonConverter() AwaitingApprovalReason? awaitingApprovalReason, String? verificationMessage
});




}
/// @nodoc
class _$VendorMeCopyWithImpl<$Res>
    implements $VendorMeCopyWith<$Res> {
  _$VendorMeCopyWithImpl(this._self, this._then);

  final VendorMe _self;
  final $Res Function(VendorMe) _then;

/// Create a copy of VendorMe
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? vendorProfileId = null,Object? lifecycle = null,Object? awaitingApproval = null,Object? tradingName = null,Object? legalBusinessName = null,Object? categoryCount = null,Object? regionCount = null,Object? categoryIds = null,Object? regionIds = null,Object? awayMode = null,Object? awaitingApprovalReason = freezed,Object? verificationMessage = freezed,}) {
  return _then(_self.copyWith(
vendorProfileId: null == vendorProfileId ? _self.vendorProfileId : vendorProfileId // ignore: cast_nullable_to_non_nullable
as String,lifecycle: null == lifecycle ? _self.lifecycle : lifecycle // ignore: cast_nullable_to_non_nullable
as VendorLifecycle,awaitingApproval: null == awaitingApproval ? _self.awaitingApproval : awaitingApproval // ignore: cast_nullable_to_non_nullable
as bool,tradingName: null == tradingName ? _self.tradingName : tradingName // ignore: cast_nullable_to_non_nullable
as String,legalBusinessName: null == legalBusinessName ? _self.legalBusinessName : legalBusinessName // ignore: cast_nullable_to_non_nullable
as String,categoryCount: null == categoryCount ? _self.categoryCount : categoryCount // ignore: cast_nullable_to_non_nullable
as int,regionCount: null == regionCount ? _self.regionCount : regionCount // ignore: cast_nullable_to_non_nullable
as int,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,regionIds: null == regionIds ? _self.regionIds : regionIds // ignore: cast_nullable_to_non_nullable
as List<String>,awayMode: null == awayMode ? _self.awayMode : awayMode // ignore: cast_nullable_to_non_nullable
as bool,awaitingApprovalReason: freezed == awaitingApprovalReason ? _self.awaitingApprovalReason : awaitingApprovalReason // ignore: cast_nullable_to_non_nullable
as AwaitingApprovalReason?,verificationMessage: freezed == verificationMessage ? _self.verificationMessage : verificationMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VendorMe].
extension VendorMePatterns on VendorMe {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorMe value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorMe() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorMe value)  $default,){
final _that = this;
switch (_that) {
case _VendorMe():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorMe value)?  $default,){
final _that = this;
switch (_that) {
case _VendorMe() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String vendorProfileId, @_VendorLifecycleConverter()  VendorLifecycle lifecycle,  bool awaitingApproval,  String tradingName,  String legalBusinessName,  int categoryCount,  int regionCount,  List<String> categoryIds,  List<String> regionIds,  bool awayMode, @_AwaitingApprovalReasonConverter()  AwaitingApprovalReason? awaitingApprovalReason,  String? verificationMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorMe() when $default != null:
return $default(_that.vendorProfileId,_that.lifecycle,_that.awaitingApproval,_that.tradingName,_that.legalBusinessName,_that.categoryCount,_that.regionCount,_that.categoryIds,_that.regionIds,_that.awayMode,_that.awaitingApprovalReason,_that.verificationMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String vendorProfileId, @_VendorLifecycleConverter()  VendorLifecycle lifecycle,  bool awaitingApproval,  String tradingName,  String legalBusinessName,  int categoryCount,  int regionCount,  List<String> categoryIds,  List<String> regionIds,  bool awayMode, @_AwaitingApprovalReasonConverter()  AwaitingApprovalReason? awaitingApprovalReason,  String? verificationMessage)  $default,) {final _that = this;
switch (_that) {
case _VendorMe():
return $default(_that.vendorProfileId,_that.lifecycle,_that.awaitingApproval,_that.tradingName,_that.legalBusinessName,_that.categoryCount,_that.regionCount,_that.categoryIds,_that.regionIds,_that.awayMode,_that.awaitingApprovalReason,_that.verificationMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String vendorProfileId, @_VendorLifecycleConverter()  VendorLifecycle lifecycle,  bool awaitingApproval,  String tradingName,  String legalBusinessName,  int categoryCount,  int regionCount,  List<String> categoryIds,  List<String> regionIds,  bool awayMode, @_AwaitingApprovalReasonConverter()  AwaitingApprovalReason? awaitingApprovalReason,  String? verificationMessage)?  $default,) {final _that = this;
switch (_that) {
case _VendorMe() when $default != null:
return $default(_that.vendorProfileId,_that.lifecycle,_that.awaitingApproval,_that.tradingName,_that.legalBusinessName,_that.categoryCount,_that.regionCount,_that.categoryIds,_that.regionIds,_that.awayMode,_that.awaitingApprovalReason,_that.verificationMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VendorMe implements VendorMe {
  const _VendorMe({required this.vendorProfileId, @_VendorLifecycleConverter() required this.lifecycle, required this.awaitingApproval, required this.tradingName, required this.legalBusinessName, required this.categoryCount, required this.regionCount, final  List<String> categoryIds = const <String>[], final  List<String> regionIds = const <String>[], this.awayMode = false, @_AwaitingApprovalReasonConverter() this.awaitingApprovalReason, this.verificationMessage}): _categoryIds = categoryIds,_regionIds = regionIds;
  factory _VendorMe.fromJson(Map<String, dynamic> json) => _$VendorMeFromJson(json);

@override final  String vendorProfileId;
@override@_VendorLifecycleConverter() final  VendorLifecycle lifecycle;
@override final  bool awaitingApproval;
@override final  String tradingName;
@override final  String legalBusinessName;
@override final  int categoryCount;
@override final  int regionCount;
 final  List<String> _categoryIds;
@override@JsonKey() List<String> get categoryIds {
  if (_categoryIds is EqualUnmodifiableListView) return _categoryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoryIds);
}

 final  List<String> _regionIds;
@override@JsonKey() List<String> get regionIds {
  if (_regionIds is EqualUnmodifiableListView) return _regionIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_regionIds);
}

@override@JsonKey() final  bool awayMode;
@override@_AwaitingApprovalReasonConverter() final  AwaitingApprovalReason? awaitingApprovalReason;
@override final  String? verificationMessage;

/// Create a copy of VendorMe
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorMeCopyWith<_VendorMe> get copyWith => __$VendorMeCopyWithImpl<_VendorMe>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VendorMeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorMe&&(identical(other.vendorProfileId, vendorProfileId) || other.vendorProfileId == vendorProfileId)&&(identical(other.lifecycle, lifecycle) || other.lifecycle == lifecycle)&&(identical(other.awaitingApproval, awaitingApproval) || other.awaitingApproval == awaitingApproval)&&(identical(other.tradingName, tradingName) || other.tradingName == tradingName)&&(identical(other.legalBusinessName, legalBusinessName) || other.legalBusinessName == legalBusinessName)&&(identical(other.categoryCount, categoryCount) || other.categoryCount == categoryCount)&&(identical(other.regionCount, regionCount) || other.regionCount == regionCount)&&const DeepCollectionEquality().equals(other._categoryIds, _categoryIds)&&const DeepCollectionEquality().equals(other._regionIds, _regionIds)&&(identical(other.awayMode, awayMode) || other.awayMode == awayMode)&&(identical(other.awaitingApprovalReason, awaitingApprovalReason) || other.awaitingApprovalReason == awaitingApprovalReason)&&(identical(other.verificationMessage, verificationMessage) || other.verificationMessage == verificationMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vendorProfileId,lifecycle,awaitingApproval,tradingName,legalBusinessName,categoryCount,regionCount,const DeepCollectionEquality().hash(_categoryIds),const DeepCollectionEquality().hash(_regionIds),awayMode,awaitingApprovalReason,verificationMessage);

@override
String toString() {
  return 'VendorMe(vendorProfileId: $vendorProfileId, lifecycle: $lifecycle, awaitingApproval: $awaitingApproval, tradingName: $tradingName, legalBusinessName: $legalBusinessName, categoryCount: $categoryCount, regionCount: $regionCount, categoryIds: $categoryIds, regionIds: $regionIds, awayMode: $awayMode, awaitingApprovalReason: $awaitingApprovalReason, verificationMessage: $verificationMessage)';
}


}

/// @nodoc
abstract mixin class _$VendorMeCopyWith<$Res> implements $VendorMeCopyWith<$Res> {
  factory _$VendorMeCopyWith(_VendorMe value, $Res Function(_VendorMe) _then) = __$VendorMeCopyWithImpl;
@override @useResult
$Res call({
 String vendorProfileId,@_VendorLifecycleConverter() VendorLifecycle lifecycle, bool awaitingApproval, String tradingName, String legalBusinessName, int categoryCount, int regionCount, List<String> categoryIds, List<String> regionIds, bool awayMode,@_AwaitingApprovalReasonConverter() AwaitingApprovalReason? awaitingApprovalReason, String? verificationMessage
});




}
/// @nodoc
class __$VendorMeCopyWithImpl<$Res>
    implements _$VendorMeCopyWith<$Res> {
  __$VendorMeCopyWithImpl(this._self, this._then);

  final _VendorMe _self;
  final $Res Function(_VendorMe) _then;

/// Create a copy of VendorMe
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vendorProfileId = null,Object? lifecycle = null,Object? awaitingApproval = null,Object? tradingName = null,Object? legalBusinessName = null,Object? categoryCount = null,Object? regionCount = null,Object? categoryIds = null,Object? regionIds = null,Object? awayMode = null,Object? awaitingApprovalReason = freezed,Object? verificationMessage = freezed,}) {
  return _then(_VendorMe(
vendorProfileId: null == vendorProfileId ? _self.vendorProfileId : vendorProfileId // ignore: cast_nullable_to_non_nullable
as String,lifecycle: null == lifecycle ? _self.lifecycle : lifecycle // ignore: cast_nullable_to_non_nullable
as VendorLifecycle,awaitingApproval: null == awaitingApproval ? _self.awaitingApproval : awaitingApproval // ignore: cast_nullable_to_non_nullable
as bool,tradingName: null == tradingName ? _self.tradingName : tradingName // ignore: cast_nullable_to_non_nullable
as String,legalBusinessName: null == legalBusinessName ? _self.legalBusinessName : legalBusinessName // ignore: cast_nullable_to_non_nullable
as String,categoryCount: null == categoryCount ? _self.categoryCount : categoryCount // ignore: cast_nullable_to_non_nullable
as int,regionCount: null == regionCount ? _self.regionCount : regionCount // ignore: cast_nullable_to_non_nullable
as int,categoryIds: null == categoryIds ? _self._categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,regionIds: null == regionIds ? _self._regionIds : regionIds // ignore: cast_nullable_to_non_nullable
as List<String>,awayMode: null == awayMode ? _self.awayMode : awayMode // ignore: cast_nullable_to_non_nullable
as bool,awaitingApprovalReason: freezed == awaitingApprovalReason ? _self.awaitingApprovalReason : awaitingApprovalReason // ignore: cast_nullable_to_non_nullable
as AwaitingApprovalReason?,verificationMessage: freezed == verificationMessage ? _self.verificationMessage : verificationMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MeUser {

 String get userId; String get userType; String get mobileNumber; String get preferredLanguage; String? get email; VendorMe? get vendor;
/// Create a copy of MeUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeUserCopyWith<MeUser> get copyWith => _$MeUserCopyWithImpl<MeUser>(this as MeUser, _$identity);

  /// Serializes this MeUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeUser&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userType, userType) || other.userType == userType)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.preferredLanguage, preferredLanguage) || other.preferredLanguage == preferredLanguage)&&(identical(other.email, email) || other.email == email)&&(identical(other.vendor, vendor) || other.vendor == vendor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,userType,mobileNumber,preferredLanguage,email,vendor);

@override
String toString() {
  return 'MeUser(userId: $userId, userType: $userType, mobileNumber: $mobileNumber, preferredLanguage: $preferredLanguage, email: $email, vendor: $vendor)';
}


}

/// @nodoc
abstract mixin class $MeUserCopyWith<$Res>  {
  factory $MeUserCopyWith(MeUser value, $Res Function(MeUser) _then) = _$MeUserCopyWithImpl;
@useResult
$Res call({
 String userId, String userType, String mobileNumber, String preferredLanguage, String? email, VendorMe? vendor
});


$VendorMeCopyWith<$Res>? get vendor;

}
/// @nodoc
class _$MeUserCopyWithImpl<$Res>
    implements $MeUserCopyWith<$Res> {
  _$MeUserCopyWithImpl(this._self, this._then);

  final MeUser _self;
  final $Res Function(MeUser) _then;

/// Create a copy of MeUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? userType = null,Object? mobileNumber = null,Object? preferredLanguage = null,Object? email = freezed,Object? vendor = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userType: null == userType ? _self.userType : userType // ignore: cast_nullable_to_non_nullable
as String,mobileNumber: null == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String,preferredLanguage: null == preferredLanguage ? _self.preferredLanguage : preferredLanguage // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,vendor: freezed == vendor ? _self.vendor : vendor // ignore: cast_nullable_to_non_nullable
as VendorMe?,
  ));
}
/// Create a copy of MeUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VendorMeCopyWith<$Res>? get vendor {
    if (_self.vendor == null) {
    return null;
  }

  return $VendorMeCopyWith<$Res>(_self.vendor!, (value) {
    return _then(_self.copyWith(vendor: value));
  });
}
}


/// Adds pattern-matching-related methods to [MeUser].
extension MeUserPatterns on MeUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeUser value)  $default,){
final _that = this;
switch (_that) {
case _MeUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeUser value)?  $default,){
final _that = this;
switch (_that) {
case _MeUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String userType,  String mobileNumber,  String preferredLanguage,  String? email,  VendorMe? vendor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeUser() when $default != null:
return $default(_that.userId,_that.userType,_that.mobileNumber,_that.preferredLanguage,_that.email,_that.vendor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String userType,  String mobileNumber,  String preferredLanguage,  String? email,  VendorMe? vendor)  $default,) {final _that = this;
switch (_that) {
case _MeUser():
return $default(_that.userId,_that.userType,_that.mobileNumber,_that.preferredLanguage,_that.email,_that.vendor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String userType,  String mobileNumber,  String preferredLanguage,  String? email,  VendorMe? vendor)?  $default,) {final _that = this;
switch (_that) {
case _MeUser() when $default != null:
return $default(_that.userId,_that.userType,_that.mobileNumber,_that.preferredLanguage,_that.email,_that.vendor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MeUser implements MeUser {
  const _MeUser({required this.userId, required this.userType, required this.mobileNumber, required this.preferredLanguage, this.email, this.vendor});
  factory _MeUser.fromJson(Map<String, dynamic> json) => _$MeUserFromJson(json);

@override final  String userId;
@override final  String userType;
@override final  String mobileNumber;
@override final  String preferredLanguage;
@override final  String? email;
@override final  VendorMe? vendor;

/// Create a copy of MeUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeUserCopyWith<_MeUser> get copyWith => __$MeUserCopyWithImpl<_MeUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeUser&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userType, userType) || other.userType == userType)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.preferredLanguage, preferredLanguage) || other.preferredLanguage == preferredLanguage)&&(identical(other.email, email) || other.email == email)&&(identical(other.vendor, vendor) || other.vendor == vendor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,userType,mobileNumber,preferredLanguage,email,vendor);

@override
String toString() {
  return 'MeUser(userId: $userId, userType: $userType, mobileNumber: $mobileNumber, preferredLanguage: $preferredLanguage, email: $email, vendor: $vendor)';
}


}

/// @nodoc
abstract mixin class _$MeUserCopyWith<$Res> implements $MeUserCopyWith<$Res> {
  factory _$MeUserCopyWith(_MeUser value, $Res Function(_MeUser) _then) = __$MeUserCopyWithImpl;
@override @useResult
$Res call({
 String userId, String userType, String mobileNumber, String preferredLanguage, String? email, VendorMe? vendor
});


@override $VendorMeCopyWith<$Res>? get vendor;

}
/// @nodoc
class __$MeUserCopyWithImpl<$Res>
    implements _$MeUserCopyWith<$Res> {
  __$MeUserCopyWithImpl(this._self, this._then);

  final _MeUser _self;
  final $Res Function(_MeUser) _then;

/// Create a copy of MeUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? userType = null,Object? mobileNumber = null,Object? preferredLanguage = null,Object? email = freezed,Object? vendor = freezed,}) {
  return _then(_MeUser(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userType: null == userType ? _self.userType : userType // ignore: cast_nullable_to_non_nullable
as String,mobileNumber: null == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String,preferredLanguage: null == preferredLanguage ? _self.preferredLanguage : preferredLanguage // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,vendor: freezed == vendor ? _self.vendor : vendor // ignore: cast_nullable_to_non_nullable
as VendorMe?,
  ));
}

/// Create a copy of MeUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VendorMeCopyWith<$Res>? get vendor {
    if (_self.vendor == null) {
    return null;
  }

  return $VendorMeCopyWith<$Res>(_self.vendor!, (value) {
    return _then(_self.copyWith(vendor: value));
  });
}
}

// dart format on
