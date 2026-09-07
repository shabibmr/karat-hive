// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'party.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MaskedParty {

@_UserRoleConverter() UserRole get role; String? get region; String? get pseudonym;@JsonKey(fromJson: _ratingSummaryFromJson) RatingSummary? get rating; int get dealCount;
/// Create a copy of MaskedParty
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaskedPartyCopyWith<MaskedParty> get copyWith => _$MaskedPartyCopyWithImpl<MaskedParty>(this as MaskedParty, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaskedParty&&(identical(other.role, role) || other.role == role)&&(identical(other.region, region) || other.region == region)&&(identical(other.pseudonym, pseudonym) || other.pseudonym == pseudonym)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.dealCount, dealCount) || other.dealCount == dealCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role,region,pseudonym,rating,dealCount);

@override
String toString() {
  return 'MaskedParty(role: $role, region: $region, pseudonym: $pseudonym, rating: $rating, dealCount: $dealCount)';
}


}

/// @nodoc
abstract mixin class $MaskedPartyCopyWith<$Res>  {
  factory $MaskedPartyCopyWith(MaskedParty value, $Res Function(MaskedParty) _then) = _$MaskedPartyCopyWithImpl;
@useResult
$Res call({
@_UserRoleConverter() UserRole role, String? region, String? pseudonym,@JsonKey(fromJson: _ratingSummaryFromJson) RatingSummary? rating, int dealCount
});




}
/// @nodoc
class _$MaskedPartyCopyWithImpl<$Res>
    implements $MaskedPartyCopyWith<$Res> {
  _$MaskedPartyCopyWithImpl(this._self, this._then);

  final MaskedParty _self;
  final $Res Function(MaskedParty) _then;

/// Create a copy of MaskedParty
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = null,Object? region = freezed,Object? pseudonym = freezed,Object? rating = freezed,Object? dealCount = null,}) {
  return _then(_self.copyWith(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,pseudonym: freezed == pseudonym ? _self.pseudonym : pseudonym // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as RatingSummary?,dealCount: null == dealCount ? _self.dealCount : dealCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MaskedParty].
extension MaskedPartyPatterns on MaskedParty {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MaskedParty value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MaskedParty() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MaskedParty value)  $default,){
final _that = this;
switch (_that) {
case _MaskedParty():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MaskedParty value)?  $default,){
final _that = this;
switch (_that) {
case _MaskedParty() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@_UserRoleConverter()  UserRole role,  String? region,  String? pseudonym, @JsonKey(fromJson: _ratingSummaryFromJson)  RatingSummary? rating,  int dealCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MaskedParty() when $default != null:
return $default(_that.role,_that.region,_that.pseudonym,_that.rating,_that.dealCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@_UserRoleConverter()  UserRole role,  String? region,  String? pseudonym, @JsonKey(fromJson: _ratingSummaryFromJson)  RatingSummary? rating,  int dealCount)  $default,) {final _that = this;
switch (_that) {
case _MaskedParty():
return $default(_that.role,_that.region,_that.pseudonym,_that.rating,_that.dealCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@_UserRoleConverter()  UserRole role,  String? region,  String? pseudonym, @JsonKey(fromJson: _ratingSummaryFromJson)  RatingSummary? rating,  int dealCount)?  $default,) {final _that = this;
switch (_that) {
case _MaskedParty() when $default != null:
return $default(_that.role,_that.region,_that.pseudonym,_that.rating,_that.dealCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _MaskedParty extends MaskedParty {
  const _MaskedParty({@_UserRoleConverter() required this.role, this.region, this.pseudonym, @JsonKey(fromJson: _ratingSummaryFromJson) this.rating, this.dealCount = 0}): super._();
  factory _MaskedParty.fromJson(Map<String, dynamic> json) => _$MaskedPartyFromJson(json);

@override@_UserRoleConverter() final  UserRole role;
@override final  String? region;
@override final  String? pseudonym;
@override@JsonKey(fromJson: _ratingSummaryFromJson) final  RatingSummary? rating;
@override@JsonKey() final  int dealCount;

/// Create a copy of MaskedParty
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaskedPartyCopyWith<_MaskedParty> get copyWith => __$MaskedPartyCopyWithImpl<_MaskedParty>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaskedParty&&(identical(other.role, role) || other.role == role)&&(identical(other.region, region) || other.region == region)&&(identical(other.pseudonym, pseudonym) || other.pseudonym == pseudonym)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.dealCount, dealCount) || other.dealCount == dealCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role,region,pseudonym,rating,dealCount);

@override
String toString() {
  return 'MaskedParty(role: $role, region: $region, pseudonym: $pseudonym, rating: $rating, dealCount: $dealCount)';
}


}

/// @nodoc
abstract mixin class _$MaskedPartyCopyWith<$Res> implements $MaskedPartyCopyWith<$Res> {
  factory _$MaskedPartyCopyWith(_MaskedParty value, $Res Function(_MaskedParty) _then) = __$MaskedPartyCopyWithImpl;
@override @useResult
$Res call({
@_UserRoleConverter() UserRole role, String? region, String? pseudonym,@JsonKey(fromJson: _ratingSummaryFromJson) RatingSummary? rating, int dealCount
});




}
/// @nodoc
class __$MaskedPartyCopyWithImpl<$Res>
    implements _$MaskedPartyCopyWith<$Res> {
  __$MaskedPartyCopyWithImpl(this._self, this._then);

  final _MaskedParty _self;
  final $Res Function(_MaskedParty) _then;

/// Create a copy of MaskedParty
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = null,Object? region = freezed,Object? pseudonym = freezed,Object? rating = freezed,Object? dealCount = null,}) {
  return _then(_MaskedParty(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,pseudonym: freezed == pseudonym ? _self.pseudonym : pseudonym // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as RatingSummary?,dealCount: null == dealCount ? _self.dealCount : dealCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$RevealedParty {

 String get name; String get mobile;@_UserRoleConverter() UserRole get role; String? get address; String? get business;@JsonKey(fromJson: _ratingSummaryFromJson) RatingSummary? get rating; int get dealCount;
/// Create a copy of RevealedParty
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevealedPartyCopyWith<RevealedParty> get copyWith => _$RevealedPartyCopyWithImpl<RevealedParty>(this as RevealedParty, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevealedParty&&(identical(other.name, name) || other.name == name)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.role, role) || other.role == role)&&(identical(other.address, address) || other.address == address)&&(identical(other.business, business) || other.business == business)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.dealCount, dealCount) || other.dealCount == dealCount));
}


@override
int get hashCode => Object.hash(runtimeType,name,mobile,role,address,business,rating,dealCount);

@override
String toString() {
  return 'RevealedParty(name: $name, mobile: $mobile, role: $role, address: $address, business: $business, rating: $rating, dealCount: $dealCount)';
}


}

/// @nodoc
abstract mixin class $RevealedPartyCopyWith<$Res>  {
  factory $RevealedPartyCopyWith(RevealedParty value, $Res Function(RevealedParty) _then) = _$RevealedPartyCopyWithImpl;
@useResult
$Res call({
 String name, String mobile,@_UserRoleConverter() UserRole role, String? address, String? business,@JsonKey(fromJson: _ratingSummaryFromJson) RatingSummary? rating, int dealCount
});




}
/// @nodoc
class _$RevealedPartyCopyWithImpl<$Res>
    implements $RevealedPartyCopyWith<$Res> {
  _$RevealedPartyCopyWithImpl(this._self, this._then);

  final RevealedParty _self;
  final $Res Function(RevealedParty) _then;

/// Create a copy of RevealedParty
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? mobile = null,Object? role = null,Object? address = freezed,Object? business = freezed,Object? rating = freezed,Object? dealCount = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,mobile: null == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,business: freezed == business ? _self.business : business // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as RatingSummary?,dealCount: null == dealCount ? _self.dealCount : dealCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RevealedParty].
extension RevealedPartyPatterns on RevealedParty {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevealedParty value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevealedParty() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevealedParty value)  $default,){
final _that = this;
switch (_that) {
case _RevealedParty():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevealedParty value)?  $default,){
final _that = this;
switch (_that) {
case _RevealedParty() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String mobile, @_UserRoleConverter()  UserRole role,  String? address,  String? business, @JsonKey(fromJson: _ratingSummaryFromJson)  RatingSummary? rating,  int dealCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RevealedParty() when $default != null:
return $default(_that.name,_that.mobile,_that.role,_that.address,_that.business,_that.rating,_that.dealCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String mobile, @_UserRoleConverter()  UserRole role,  String? address,  String? business, @JsonKey(fromJson: _ratingSummaryFromJson)  RatingSummary? rating,  int dealCount)  $default,) {final _that = this;
switch (_that) {
case _RevealedParty():
return $default(_that.name,_that.mobile,_that.role,_that.address,_that.business,_that.rating,_that.dealCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String mobile, @_UserRoleConverter()  UserRole role,  String? address,  String? business, @JsonKey(fromJson: _ratingSummaryFromJson)  RatingSummary? rating,  int dealCount)?  $default,) {final _that = this;
switch (_that) {
case _RevealedParty() when $default != null:
return $default(_that.name,_that.mobile,_that.role,_that.address,_that.business,_that.rating,_that.dealCount);case _:
  return null;

}
}

}

/// @nodoc


class _RevealedParty extends RevealedParty {
  const _RevealedParty({required this.name, required this.mobile, @_UserRoleConverter() required this.role, this.address, this.business, @JsonKey(fromJson: _ratingSummaryFromJson) this.rating, this.dealCount = 0}): super._();
  

@override final  String name;
@override final  String mobile;
@override@_UserRoleConverter() final  UserRole role;
@override final  String? address;
@override final  String? business;
@override@JsonKey(fromJson: _ratingSummaryFromJson) final  RatingSummary? rating;
@override@JsonKey() final  int dealCount;

/// Create a copy of RevealedParty
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevealedPartyCopyWith<_RevealedParty> get copyWith => __$RevealedPartyCopyWithImpl<_RevealedParty>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevealedParty&&(identical(other.name, name) || other.name == name)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.role, role) || other.role == role)&&(identical(other.address, address) || other.address == address)&&(identical(other.business, business) || other.business == business)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.dealCount, dealCount) || other.dealCount == dealCount));
}


@override
int get hashCode => Object.hash(runtimeType,name,mobile,role,address,business,rating,dealCount);

@override
String toString() {
  return 'RevealedParty(name: $name, mobile: $mobile, role: $role, address: $address, business: $business, rating: $rating, dealCount: $dealCount)';
}


}

/// @nodoc
abstract mixin class _$RevealedPartyCopyWith<$Res> implements $RevealedPartyCopyWith<$Res> {
  factory _$RevealedPartyCopyWith(_RevealedParty value, $Res Function(_RevealedParty) _then) = __$RevealedPartyCopyWithImpl;
@override @useResult
$Res call({
 String name, String mobile,@_UserRoleConverter() UserRole role, String? address, String? business,@JsonKey(fromJson: _ratingSummaryFromJson) RatingSummary? rating, int dealCount
});




}
/// @nodoc
class __$RevealedPartyCopyWithImpl<$Res>
    implements _$RevealedPartyCopyWith<$Res> {
  __$RevealedPartyCopyWithImpl(this._self, this._then);

  final _RevealedParty _self;
  final $Res Function(_RevealedParty) _then;

/// Create a copy of RevealedParty
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? mobile = null,Object? role = null,Object? address = freezed,Object? business = freezed,Object? rating = freezed,Object? dealCount = null,}) {
  return _then(_RevealedParty(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,mobile: null == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,business: freezed == business ? _self.business : business // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as RatingSummary?,dealCount: null == dealCount ? _self.dealCount : dealCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
