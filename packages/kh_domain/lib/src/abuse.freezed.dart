// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'abuse.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AbuseReport {

 String get id;@_AbuseReportStateConverter() AbuseReportState get state; bool get acknowledged;
/// Create a copy of AbuseReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AbuseReportCopyWith<AbuseReport> get copyWith => _$AbuseReportCopyWithImpl<AbuseReport>(this as AbuseReport, _$identity);

  /// Serializes this AbuseReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AbuseReport&&(identical(other.id, id) || other.id == id)&&(identical(other.state, state) || other.state == state)&&(identical(other.acknowledged, acknowledged) || other.acknowledged == acknowledged));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,state,acknowledged);

@override
String toString() {
  return 'AbuseReport(id: $id, state: $state, acknowledged: $acknowledged)';
}


}

/// @nodoc
abstract mixin class $AbuseReportCopyWith<$Res>  {
  factory $AbuseReportCopyWith(AbuseReport value, $Res Function(AbuseReport) _then) = _$AbuseReportCopyWithImpl;
@useResult
$Res call({
 String id,@_AbuseReportStateConverter() AbuseReportState state, bool acknowledged
});




}
/// @nodoc
class _$AbuseReportCopyWithImpl<$Res>
    implements $AbuseReportCopyWith<$Res> {
  _$AbuseReportCopyWithImpl(this._self, this._then);

  final AbuseReport _self;
  final $Res Function(AbuseReport) _then;

/// Create a copy of AbuseReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? state = null,Object? acknowledged = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as AbuseReportState,acknowledged: null == acknowledged ? _self.acknowledged : acknowledged // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AbuseReport].
extension AbuseReportPatterns on AbuseReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AbuseReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AbuseReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AbuseReport value)  $default,){
final _that = this;
switch (_that) {
case _AbuseReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AbuseReport value)?  $default,){
final _that = this;
switch (_that) {
case _AbuseReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @_AbuseReportStateConverter()  AbuseReportState state,  bool acknowledged)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AbuseReport() when $default != null:
return $default(_that.id,_that.state,_that.acknowledged);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @_AbuseReportStateConverter()  AbuseReportState state,  bool acknowledged)  $default,) {final _that = this;
switch (_that) {
case _AbuseReport():
return $default(_that.id,_that.state,_that.acknowledged);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @_AbuseReportStateConverter()  AbuseReportState state,  bool acknowledged)?  $default,) {final _that = this;
switch (_that) {
case _AbuseReport() when $default != null:
return $default(_that.id,_that.state,_that.acknowledged);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AbuseReport implements AbuseReport {
  const _AbuseReport({required this.id, @_AbuseReportStateConverter() required this.state, required this.acknowledged});
  factory _AbuseReport.fromJson(Map<String, dynamic> json) => _$AbuseReportFromJson(json);

@override final  String id;
@override@_AbuseReportStateConverter() final  AbuseReportState state;
@override final  bool acknowledged;

/// Create a copy of AbuseReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AbuseReportCopyWith<_AbuseReport> get copyWith => __$AbuseReportCopyWithImpl<_AbuseReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AbuseReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AbuseReport&&(identical(other.id, id) || other.id == id)&&(identical(other.state, state) || other.state == state)&&(identical(other.acknowledged, acknowledged) || other.acknowledged == acknowledged));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,state,acknowledged);

@override
String toString() {
  return 'AbuseReport(id: $id, state: $state, acknowledged: $acknowledged)';
}


}

/// @nodoc
abstract mixin class _$AbuseReportCopyWith<$Res> implements $AbuseReportCopyWith<$Res> {
  factory _$AbuseReportCopyWith(_AbuseReport value, $Res Function(_AbuseReport) _then) = __$AbuseReportCopyWithImpl;
@override @useResult
$Res call({
 String id,@_AbuseReportStateConverter() AbuseReportState state, bool acknowledged
});




}
/// @nodoc
class __$AbuseReportCopyWithImpl<$Res>
    implements _$AbuseReportCopyWith<$Res> {
  __$AbuseReportCopyWithImpl(this._self, this._then);

  final _AbuseReport _self;
  final $Res Function(_AbuseReport) _then;

/// Create a copy of AbuseReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? state = null,Object? acknowledged = null,}) {
  return _then(_AbuseReport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as AbuseReportState,acknowledged: null == acknowledged ? _self.acknowledged : acknowledged // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
