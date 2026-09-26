// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vendor_list_filters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VendorListFilters {

 VendorVerificationState? get verificationState; VendorAccountState? get accountState; String get query;
/// Create a copy of VendorListFilters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorListFiltersCopyWith<VendorListFilters> get copyWith => _$VendorListFiltersCopyWithImpl<VendorListFilters>(this as VendorListFilters, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorListFilters&&(identical(other.verificationState, verificationState) || other.verificationState == verificationState)&&(identical(other.accountState, accountState) || other.accountState == accountState)&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,verificationState,accountState,query);

@override
String toString() {
  return 'VendorListFilters(verificationState: $verificationState, accountState: $accountState, query: $query)';
}


}

/// @nodoc
abstract mixin class $VendorListFiltersCopyWith<$Res>  {
  factory $VendorListFiltersCopyWith(VendorListFilters value, $Res Function(VendorListFilters) _then) = _$VendorListFiltersCopyWithImpl;
@useResult
$Res call({
 VendorVerificationState? verificationState, VendorAccountState? accountState, String query
});




}
/// @nodoc
class _$VendorListFiltersCopyWithImpl<$Res>
    implements $VendorListFiltersCopyWith<$Res> {
  _$VendorListFiltersCopyWithImpl(this._self, this._then);

  final VendorListFilters _self;
  final $Res Function(VendorListFilters) _then;

/// Create a copy of VendorListFilters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? verificationState = freezed,Object? accountState = freezed,Object? query = null,}) {
  return _then(_self.copyWith(
verificationState: freezed == verificationState ? _self.verificationState : verificationState // ignore: cast_nullable_to_non_nullable
as VendorVerificationState?,accountState: freezed == accountState ? _self.accountState : accountState // ignore: cast_nullable_to_non_nullable
as VendorAccountState?,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VendorListFilters].
extension VendorListFiltersPatterns on VendorListFilters {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorListFilters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorListFilters() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorListFilters value)  $default,){
final _that = this;
switch (_that) {
case _VendorListFilters():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorListFilters value)?  $default,){
final _that = this;
switch (_that) {
case _VendorListFilters() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VendorVerificationState? verificationState,  VendorAccountState? accountState,  String query)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorListFilters() when $default != null:
return $default(_that.verificationState,_that.accountState,_that.query);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VendorVerificationState? verificationState,  VendorAccountState? accountState,  String query)  $default,) {final _that = this;
switch (_that) {
case _VendorListFilters():
return $default(_that.verificationState,_that.accountState,_that.query);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VendorVerificationState? verificationState,  VendorAccountState? accountState,  String query)?  $default,) {final _that = this;
switch (_that) {
case _VendorListFilters() when $default != null:
return $default(_that.verificationState,_that.accountState,_that.query);case _:
  return null;

}
}

}

/// @nodoc


class _VendorListFilters implements VendorListFilters {
  const _VendorListFilters({this.verificationState, this.accountState, this.query = ''});
  

@override final  VendorVerificationState? verificationState;
@override final  VendorAccountState? accountState;
@override@JsonKey() final  String query;

/// Create a copy of VendorListFilters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorListFiltersCopyWith<_VendorListFilters> get copyWith => __$VendorListFiltersCopyWithImpl<_VendorListFilters>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorListFilters&&(identical(other.verificationState, verificationState) || other.verificationState == verificationState)&&(identical(other.accountState, accountState) || other.accountState == accountState)&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,verificationState,accountState,query);

@override
String toString() {
  return 'VendorListFilters(verificationState: $verificationState, accountState: $accountState, query: $query)';
}


}

/// @nodoc
abstract mixin class _$VendorListFiltersCopyWith<$Res> implements $VendorListFiltersCopyWith<$Res> {
  factory _$VendorListFiltersCopyWith(_VendorListFilters value, $Res Function(_VendorListFilters) _then) = __$VendorListFiltersCopyWithImpl;
@override @useResult
$Res call({
 VendorVerificationState? verificationState, VendorAccountState? accountState, String query
});




}
/// @nodoc
class __$VendorListFiltersCopyWithImpl<$Res>
    implements _$VendorListFiltersCopyWith<$Res> {
  __$VendorListFiltersCopyWithImpl(this._self, this._then);

  final _VendorListFilters _self;
  final $Res Function(_VendorListFilters) _then;

/// Create a copy of VendorListFilters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? verificationState = freezed,Object? accountState = freezed,Object? query = null,}) {
  return _then(_VendorListFilters(
verificationState: freezed == verificationState ? _self.verificationState : verificationState // ignore: cast_nullable_to_non_nullable
as VendorVerificationState?,accountState: freezed == accountState ? _self.accountState : accountState // ignore: cast_nullable_to_non_nullable
as VendorAccountState?,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
