// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gold_rate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GoldRateRow {

@_KaratConverter() Karat get karat; String get ratePerGramAed;
/// Create a copy of GoldRateRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoldRateRowCopyWith<GoldRateRow> get copyWith => _$GoldRateRowCopyWithImpl<GoldRateRow>(this as GoldRateRow, _$identity);

  /// Serializes this GoldRateRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoldRateRow&&(identical(other.karat, karat) || other.karat == karat)&&(identical(other.ratePerGramAed, ratePerGramAed) || other.ratePerGramAed == ratePerGramAed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,karat,ratePerGramAed);

@override
String toString() {
  return 'GoldRateRow(karat: $karat, ratePerGramAed: $ratePerGramAed)';
}


}

/// @nodoc
abstract mixin class $GoldRateRowCopyWith<$Res>  {
  factory $GoldRateRowCopyWith(GoldRateRow value, $Res Function(GoldRateRow) _then) = _$GoldRateRowCopyWithImpl;
@useResult
$Res call({
@_KaratConverter() Karat karat, String ratePerGramAed
});




}
/// @nodoc
class _$GoldRateRowCopyWithImpl<$Res>
    implements $GoldRateRowCopyWith<$Res> {
  _$GoldRateRowCopyWithImpl(this._self, this._then);

  final GoldRateRow _self;
  final $Res Function(GoldRateRow) _then;

/// Create a copy of GoldRateRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? karat = null,Object? ratePerGramAed = null,}) {
  return _then(_self.copyWith(
karat: null == karat ? _self.karat : karat // ignore: cast_nullable_to_non_nullable
as Karat,ratePerGramAed: null == ratePerGramAed ? _self.ratePerGramAed : ratePerGramAed // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GoldRateRow].
extension GoldRateRowPatterns on GoldRateRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoldRateRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoldRateRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoldRateRow value)  $default,){
final _that = this;
switch (_that) {
case _GoldRateRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoldRateRow value)?  $default,){
final _that = this;
switch (_that) {
case _GoldRateRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@_KaratConverter()  Karat karat,  String ratePerGramAed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoldRateRow() when $default != null:
return $default(_that.karat,_that.ratePerGramAed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@_KaratConverter()  Karat karat,  String ratePerGramAed)  $default,) {final _that = this;
switch (_that) {
case _GoldRateRow():
return $default(_that.karat,_that.ratePerGramAed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@_KaratConverter()  Karat karat,  String ratePerGramAed)?  $default,) {final _that = this;
switch (_that) {
case _GoldRateRow() when $default != null:
return $default(_that.karat,_that.ratePerGramAed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoldRateRow implements GoldRateRow {
  const _GoldRateRow({@_KaratConverter() required this.karat, required this.ratePerGramAed});
  factory _GoldRateRow.fromJson(Map<String, dynamic> json) => _$GoldRateRowFromJson(json);

@override@_KaratConverter() final  Karat karat;
@override final  String ratePerGramAed;

/// Create a copy of GoldRateRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoldRateRowCopyWith<_GoldRateRow> get copyWith => __$GoldRateRowCopyWithImpl<_GoldRateRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoldRateRowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoldRateRow&&(identical(other.karat, karat) || other.karat == karat)&&(identical(other.ratePerGramAed, ratePerGramAed) || other.ratePerGramAed == ratePerGramAed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,karat,ratePerGramAed);

@override
String toString() {
  return 'GoldRateRow(karat: $karat, ratePerGramAed: $ratePerGramAed)';
}


}

/// @nodoc
abstract mixin class _$GoldRateRowCopyWith<$Res> implements $GoldRateRowCopyWith<$Res> {
  factory _$GoldRateRowCopyWith(_GoldRateRow value, $Res Function(_GoldRateRow) _then) = __$GoldRateRowCopyWithImpl;
@override @useResult
$Res call({
@_KaratConverter() Karat karat, String ratePerGramAed
});




}
/// @nodoc
class __$GoldRateRowCopyWithImpl<$Res>
    implements _$GoldRateRowCopyWith<$Res> {
  __$GoldRateRowCopyWithImpl(this._self, this._then);

  final _GoldRateRow _self;
  final $Res Function(_GoldRateRow) _then;

/// Create a copy of GoldRateRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? karat = null,Object? ratePerGramAed = null,}) {
  return _then(_GoldRateRow(
karat: null == karat ? _self.karat : karat // ignore: cast_nullable_to_non_nullable
as Karat,ratePerGramAed: null == ratePerGramAed ? _self.ratePerGramAed : ratePerGramAed // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$GoldRateSnapshot {

 bool get available; bool get stale;@_GoldRateSourceConverter() GoldRateSource get source; DateTime? get sourceTimestamp; DateTime? get ingestedAt; DateTime? get staleAfter; List<GoldRateRow> get rates; String? get disclaimer; String? get reason;
/// Create a copy of GoldRateSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoldRateSnapshotCopyWith<GoldRateSnapshot> get copyWith => _$GoldRateSnapshotCopyWithImpl<GoldRateSnapshot>(this as GoldRateSnapshot, _$identity);

  /// Serializes this GoldRateSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoldRateSnapshot&&(identical(other.available, available) || other.available == available)&&(identical(other.stale, stale) || other.stale == stale)&&(identical(other.source, source) || other.source == source)&&(identical(other.sourceTimestamp, sourceTimestamp) || other.sourceTimestamp == sourceTimestamp)&&(identical(other.ingestedAt, ingestedAt) || other.ingestedAt == ingestedAt)&&(identical(other.staleAfter, staleAfter) || other.staleAfter == staleAfter)&&const DeepCollectionEquality().equals(other.rates, rates)&&(identical(other.disclaimer, disclaimer) || other.disclaimer == disclaimer)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,available,stale,source,sourceTimestamp,ingestedAt,staleAfter,const DeepCollectionEquality().hash(rates),disclaimer,reason);

@override
String toString() {
  return 'GoldRateSnapshot(available: $available, stale: $stale, source: $source, sourceTimestamp: $sourceTimestamp, ingestedAt: $ingestedAt, staleAfter: $staleAfter, rates: $rates, disclaimer: $disclaimer, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $GoldRateSnapshotCopyWith<$Res>  {
  factory $GoldRateSnapshotCopyWith(GoldRateSnapshot value, $Res Function(GoldRateSnapshot) _then) = _$GoldRateSnapshotCopyWithImpl;
@useResult
$Res call({
 bool available, bool stale,@_GoldRateSourceConverter() GoldRateSource source, DateTime? sourceTimestamp, DateTime? ingestedAt, DateTime? staleAfter, List<GoldRateRow> rates, String? disclaimer, String? reason
});




}
/// @nodoc
class _$GoldRateSnapshotCopyWithImpl<$Res>
    implements $GoldRateSnapshotCopyWith<$Res> {
  _$GoldRateSnapshotCopyWithImpl(this._self, this._then);

  final GoldRateSnapshot _self;
  final $Res Function(GoldRateSnapshot) _then;

/// Create a copy of GoldRateSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? available = null,Object? stale = null,Object? source = null,Object? sourceTimestamp = freezed,Object? ingestedAt = freezed,Object? staleAfter = freezed,Object? rates = null,Object? disclaimer = freezed,Object? reason = freezed,}) {
  return _then(_self.copyWith(
available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,stale: null == stale ? _self.stale : stale // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as GoldRateSource,sourceTimestamp: freezed == sourceTimestamp ? _self.sourceTimestamp : sourceTimestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,ingestedAt: freezed == ingestedAt ? _self.ingestedAt : ingestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,staleAfter: freezed == staleAfter ? _self.staleAfter : staleAfter // ignore: cast_nullable_to_non_nullable
as DateTime?,rates: null == rates ? _self.rates : rates // ignore: cast_nullable_to_non_nullable
as List<GoldRateRow>,disclaimer: freezed == disclaimer ? _self.disclaimer : disclaimer // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GoldRateSnapshot].
extension GoldRateSnapshotPatterns on GoldRateSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoldRateSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoldRateSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoldRateSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _GoldRateSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoldRateSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _GoldRateSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool available,  bool stale, @_GoldRateSourceConverter()  GoldRateSource source,  DateTime? sourceTimestamp,  DateTime? ingestedAt,  DateTime? staleAfter,  List<GoldRateRow> rates,  String? disclaimer,  String? reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoldRateSnapshot() when $default != null:
return $default(_that.available,_that.stale,_that.source,_that.sourceTimestamp,_that.ingestedAt,_that.staleAfter,_that.rates,_that.disclaimer,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool available,  bool stale, @_GoldRateSourceConverter()  GoldRateSource source,  DateTime? sourceTimestamp,  DateTime? ingestedAt,  DateTime? staleAfter,  List<GoldRateRow> rates,  String? disclaimer,  String? reason)  $default,) {final _that = this;
switch (_that) {
case _GoldRateSnapshot():
return $default(_that.available,_that.stale,_that.source,_that.sourceTimestamp,_that.ingestedAt,_that.staleAfter,_that.rates,_that.disclaimer,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool available,  bool stale, @_GoldRateSourceConverter()  GoldRateSource source,  DateTime? sourceTimestamp,  DateTime? ingestedAt,  DateTime? staleAfter,  List<GoldRateRow> rates,  String? disclaimer,  String? reason)?  $default,) {final _that = this;
switch (_that) {
case _GoldRateSnapshot() when $default != null:
return $default(_that.available,_that.stale,_that.source,_that.sourceTimestamp,_that.ingestedAt,_that.staleAfter,_that.rates,_that.disclaimer,_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoldRateSnapshot implements GoldRateSnapshot {
  const _GoldRateSnapshot({required this.available, required this.stale, @_GoldRateSourceConverter() this.source = GoldRateSource.unknown, this.sourceTimestamp, this.ingestedAt, this.staleAfter, final  List<GoldRateRow> rates = const <GoldRateRow>[], this.disclaimer, this.reason}): _rates = rates;
  factory _GoldRateSnapshot.fromJson(Map<String, dynamic> json) => _$GoldRateSnapshotFromJson(json);

@override final  bool available;
@override final  bool stale;
@override@JsonKey()@_GoldRateSourceConverter() final  GoldRateSource source;
@override final  DateTime? sourceTimestamp;
@override final  DateTime? ingestedAt;
@override final  DateTime? staleAfter;
 final  List<GoldRateRow> _rates;
@override@JsonKey() List<GoldRateRow> get rates {
  if (_rates is EqualUnmodifiableListView) return _rates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rates);
}

@override final  String? disclaimer;
@override final  String? reason;

/// Create a copy of GoldRateSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoldRateSnapshotCopyWith<_GoldRateSnapshot> get copyWith => __$GoldRateSnapshotCopyWithImpl<_GoldRateSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoldRateSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoldRateSnapshot&&(identical(other.available, available) || other.available == available)&&(identical(other.stale, stale) || other.stale == stale)&&(identical(other.source, source) || other.source == source)&&(identical(other.sourceTimestamp, sourceTimestamp) || other.sourceTimestamp == sourceTimestamp)&&(identical(other.ingestedAt, ingestedAt) || other.ingestedAt == ingestedAt)&&(identical(other.staleAfter, staleAfter) || other.staleAfter == staleAfter)&&const DeepCollectionEquality().equals(other._rates, _rates)&&(identical(other.disclaimer, disclaimer) || other.disclaimer == disclaimer)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,available,stale,source,sourceTimestamp,ingestedAt,staleAfter,const DeepCollectionEquality().hash(_rates),disclaimer,reason);

@override
String toString() {
  return 'GoldRateSnapshot(available: $available, stale: $stale, source: $source, sourceTimestamp: $sourceTimestamp, ingestedAt: $ingestedAt, staleAfter: $staleAfter, rates: $rates, disclaimer: $disclaimer, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$GoldRateSnapshotCopyWith<$Res> implements $GoldRateSnapshotCopyWith<$Res> {
  factory _$GoldRateSnapshotCopyWith(_GoldRateSnapshot value, $Res Function(_GoldRateSnapshot) _then) = __$GoldRateSnapshotCopyWithImpl;
@override @useResult
$Res call({
 bool available, bool stale,@_GoldRateSourceConverter() GoldRateSource source, DateTime? sourceTimestamp, DateTime? ingestedAt, DateTime? staleAfter, List<GoldRateRow> rates, String? disclaimer, String? reason
});




}
/// @nodoc
class __$GoldRateSnapshotCopyWithImpl<$Res>
    implements _$GoldRateSnapshotCopyWith<$Res> {
  __$GoldRateSnapshotCopyWithImpl(this._self, this._then);

  final _GoldRateSnapshot _self;
  final $Res Function(_GoldRateSnapshot) _then;

/// Create a copy of GoldRateSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? available = null,Object? stale = null,Object? source = null,Object? sourceTimestamp = freezed,Object? ingestedAt = freezed,Object? staleAfter = freezed,Object? rates = null,Object? disclaimer = freezed,Object? reason = freezed,}) {
  return _then(_GoldRateSnapshot(
available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,stale: null == stale ? _self.stale : stale // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as GoldRateSource,sourceTimestamp: freezed == sourceTimestamp ? _self.sourceTimestamp : sourceTimestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,ingestedAt: freezed == ingestedAt ? _self.ingestedAt : ingestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,staleAfter: freezed == staleAfter ? _self.staleAfter : staleAfter // ignore: cast_nullable_to_non_nullable
as DateTime?,rates: null == rates ? _self._rates : rates // ignore: cast_nullable_to_non_nullable
as List<GoldRateRow>,disclaimer: freezed == disclaimer ? _self.disclaimer : disclaimer // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
