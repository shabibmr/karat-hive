// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verification_queue_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VerificationQueueItem {

 String get id; String get legalBusinessName; String get tradeLicenceNumber; double get oldestWaitingHours; String? get tradingName; DateTime? get submittedAt;
/// Create a copy of VerificationQueueItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationQueueItemCopyWith<VerificationQueueItem> get copyWith => _$VerificationQueueItemCopyWithImpl<VerificationQueueItem>(this as VerificationQueueItem, _$identity);

  /// Serializes this VerificationQueueItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationQueueItem&&(identical(other.id, id) || other.id == id)&&(identical(other.legalBusinessName, legalBusinessName) || other.legalBusinessName == legalBusinessName)&&(identical(other.tradeLicenceNumber, tradeLicenceNumber) || other.tradeLicenceNumber == tradeLicenceNumber)&&(identical(other.oldestWaitingHours, oldestWaitingHours) || other.oldestWaitingHours == oldestWaitingHours)&&(identical(other.tradingName, tradingName) || other.tradingName == tradingName)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,legalBusinessName,tradeLicenceNumber,oldestWaitingHours,tradingName,submittedAt);

@override
String toString() {
  return 'VerificationQueueItem(id: $id, legalBusinessName: $legalBusinessName, tradeLicenceNumber: $tradeLicenceNumber, oldestWaitingHours: $oldestWaitingHours, tradingName: $tradingName, submittedAt: $submittedAt)';
}


}

/// @nodoc
abstract mixin class $VerificationQueueItemCopyWith<$Res>  {
  factory $VerificationQueueItemCopyWith(VerificationQueueItem value, $Res Function(VerificationQueueItem) _then) = _$VerificationQueueItemCopyWithImpl;
@useResult
$Res call({
 String id, String legalBusinessName, String tradeLicenceNumber, double oldestWaitingHours, String? tradingName, DateTime? submittedAt
});




}
/// @nodoc
class _$VerificationQueueItemCopyWithImpl<$Res>
    implements $VerificationQueueItemCopyWith<$Res> {
  _$VerificationQueueItemCopyWithImpl(this._self, this._then);

  final VerificationQueueItem _self;
  final $Res Function(VerificationQueueItem) _then;

/// Create a copy of VerificationQueueItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? legalBusinessName = null,Object? tradeLicenceNumber = null,Object? oldestWaitingHours = null,Object? tradingName = freezed,Object? submittedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,legalBusinessName: null == legalBusinessName ? _self.legalBusinessName : legalBusinessName // ignore: cast_nullable_to_non_nullable
as String,tradeLicenceNumber: null == tradeLicenceNumber ? _self.tradeLicenceNumber : tradeLicenceNumber // ignore: cast_nullable_to_non_nullable
as String,oldestWaitingHours: null == oldestWaitingHours ? _self.oldestWaitingHours : oldestWaitingHours // ignore: cast_nullable_to_non_nullable
as double,tradingName: freezed == tradingName ? _self.tradingName : tradingName // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [VerificationQueueItem].
extension VerificationQueueItemPatterns on VerificationQueueItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerificationQueueItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerificationQueueItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerificationQueueItem value)  $default,){
final _that = this;
switch (_that) {
case _VerificationQueueItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerificationQueueItem value)?  $default,){
final _that = this;
switch (_that) {
case _VerificationQueueItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String legalBusinessName,  String tradeLicenceNumber,  double oldestWaitingHours,  String? tradingName,  DateTime? submittedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerificationQueueItem() when $default != null:
return $default(_that.id,_that.legalBusinessName,_that.tradeLicenceNumber,_that.oldestWaitingHours,_that.tradingName,_that.submittedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String legalBusinessName,  String tradeLicenceNumber,  double oldestWaitingHours,  String? tradingName,  DateTime? submittedAt)  $default,) {final _that = this;
switch (_that) {
case _VerificationQueueItem():
return $default(_that.id,_that.legalBusinessName,_that.tradeLicenceNumber,_that.oldestWaitingHours,_that.tradingName,_that.submittedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String legalBusinessName,  String tradeLicenceNumber,  double oldestWaitingHours,  String? tradingName,  DateTime? submittedAt)?  $default,) {final _that = this;
switch (_that) {
case _VerificationQueueItem() when $default != null:
return $default(_that.id,_that.legalBusinessName,_that.tradeLicenceNumber,_that.oldestWaitingHours,_that.tradingName,_that.submittedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerificationQueueItem implements VerificationQueueItem {
  const _VerificationQueueItem({required this.id, required this.legalBusinessName, required this.tradeLicenceNumber, this.oldestWaitingHours = 0, this.tradingName, this.submittedAt});
  factory _VerificationQueueItem.fromJson(Map<String, dynamic> json) => _$VerificationQueueItemFromJson(json);

@override final  String id;
@override final  String legalBusinessName;
@override final  String tradeLicenceNumber;
@override@JsonKey() final  double oldestWaitingHours;
@override final  String? tradingName;
@override final  DateTime? submittedAt;

/// Create a copy of VerificationQueueItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerificationQueueItemCopyWith<_VerificationQueueItem> get copyWith => __$VerificationQueueItemCopyWithImpl<_VerificationQueueItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerificationQueueItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerificationQueueItem&&(identical(other.id, id) || other.id == id)&&(identical(other.legalBusinessName, legalBusinessName) || other.legalBusinessName == legalBusinessName)&&(identical(other.tradeLicenceNumber, tradeLicenceNumber) || other.tradeLicenceNumber == tradeLicenceNumber)&&(identical(other.oldestWaitingHours, oldestWaitingHours) || other.oldestWaitingHours == oldestWaitingHours)&&(identical(other.tradingName, tradingName) || other.tradingName == tradingName)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,legalBusinessName,tradeLicenceNumber,oldestWaitingHours,tradingName,submittedAt);

@override
String toString() {
  return 'VerificationQueueItem(id: $id, legalBusinessName: $legalBusinessName, tradeLicenceNumber: $tradeLicenceNumber, oldestWaitingHours: $oldestWaitingHours, tradingName: $tradingName, submittedAt: $submittedAt)';
}


}

/// @nodoc
abstract mixin class _$VerificationQueueItemCopyWith<$Res> implements $VerificationQueueItemCopyWith<$Res> {
  factory _$VerificationQueueItemCopyWith(_VerificationQueueItem value, $Res Function(_VerificationQueueItem) _then) = __$VerificationQueueItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String legalBusinessName, String tradeLicenceNumber, double oldestWaitingHours, String? tradingName, DateTime? submittedAt
});




}
/// @nodoc
class __$VerificationQueueItemCopyWithImpl<$Res>
    implements _$VerificationQueueItemCopyWith<$Res> {
  __$VerificationQueueItemCopyWithImpl(this._self, this._then);

  final _VerificationQueueItem _self;
  final $Res Function(_VerificationQueueItem) _then;

/// Create a copy of VerificationQueueItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? legalBusinessName = null,Object? tradeLicenceNumber = null,Object? oldestWaitingHours = null,Object? tradingName = freezed,Object? submittedAt = freezed,}) {
  return _then(_VerificationQueueItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,legalBusinessName: null == legalBusinessName ? _self.legalBusinessName : legalBusinessName // ignore: cast_nullable_to_non_nullable
as String,tradeLicenceNumber: null == tradeLicenceNumber ? _self.tradeLicenceNumber : tradeLicenceNumber // ignore: cast_nullable_to_non_nullable
as String,oldestWaitingHours: null == oldestWaitingHours ? _self.oldestWaitingHours : oldestWaitingHours // ignore: cast_nullable_to_non_nullable
as double,tradingName: freezed == tradingName ? _self.tradingName : tradingName // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
