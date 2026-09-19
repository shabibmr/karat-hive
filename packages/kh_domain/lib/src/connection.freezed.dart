// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TalkPayload {

 String get waUrl; String get mobileNumber; bool get available; String get prefilledMessage; String get callUrl;
/// Create a copy of TalkPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TalkPayloadCopyWith<TalkPayload> get copyWith => _$TalkPayloadCopyWithImpl<TalkPayload>(this as TalkPayload, _$identity);

  /// Serializes this TalkPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TalkPayload&&(identical(other.waUrl, waUrl) || other.waUrl == waUrl)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.available, available) || other.available == available)&&(identical(other.prefilledMessage, prefilledMessage) || other.prefilledMessage == prefilledMessage)&&(identical(other.callUrl, callUrl) || other.callUrl == callUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,waUrl,mobileNumber,available,prefilledMessage,callUrl);

@override
String toString() {
  return 'TalkPayload(waUrl: $waUrl, mobileNumber: $mobileNumber, available: $available, prefilledMessage: $prefilledMessage, callUrl: $callUrl)';
}


}

/// @nodoc
abstract mixin class $TalkPayloadCopyWith<$Res>  {
  factory $TalkPayloadCopyWith(TalkPayload value, $Res Function(TalkPayload) _then) = _$TalkPayloadCopyWithImpl;
@useResult
$Res call({
 String waUrl, String mobileNumber, bool available, String prefilledMessage, String callUrl
});




}
/// @nodoc
class _$TalkPayloadCopyWithImpl<$Res>
    implements $TalkPayloadCopyWith<$Res> {
  _$TalkPayloadCopyWithImpl(this._self, this._then);

  final TalkPayload _self;
  final $Res Function(TalkPayload) _then;

/// Create a copy of TalkPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? waUrl = null,Object? mobileNumber = null,Object? available = null,Object? prefilledMessage = null,Object? callUrl = null,}) {
  return _then(_self.copyWith(
waUrl: null == waUrl ? _self.waUrl : waUrl // ignore: cast_nullable_to_non_nullable
as String,mobileNumber: null == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,prefilledMessage: null == prefilledMessage ? _self.prefilledMessage : prefilledMessage // ignore: cast_nullable_to_non_nullable
as String,callUrl: null == callUrl ? _self.callUrl : callUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TalkPayload].
extension TalkPayloadPatterns on TalkPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TalkPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TalkPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TalkPayload value)  $default,){
final _that = this;
switch (_that) {
case _TalkPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TalkPayload value)?  $default,){
final _that = this;
switch (_that) {
case _TalkPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String waUrl,  String mobileNumber,  bool available,  String prefilledMessage,  String callUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TalkPayload() when $default != null:
return $default(_that.waUrl,_that.mobileNumber,_that.available,_that.prefilledMessage,_that.callUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String waUrl,  String mobileNumber,  bool available,  String prefilledMessage,  String callUrl)  $default,) {final _that = this;
switch (_that) {
case _TalkPayload():
return $default(_that.waUrl,_that.mobileNumber,_that.available,_that.prefilledMessage,_that.callUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String waUrl,  String mobileNumber,  bool available,  String prefilledMessage,  String callUrl)?  $default,) {final _that = this;
switch (_that) {
case _TalkPayload() when $default != null:
return $default(_that.waUrl,_that.mobileNumber,_that.available,_that.prefilledMessage,_that.callUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TalkPayload extends TalkPayload {
  const _TalkPayload({required this.waUrl, required this.mobileNumber, required this.available, this.prefilledMessage = '', this.callUrl = ''}): super._();
  factory _TalkPayload.fromJson(Map<String, dynamic> json) => _$TalkPayloadFromJson(json);

@override final  String waUrl;
@override final  String mobileNumber;
@override final  bool available;
@override@JsonKey() final  String prefilledMessage;
@override@JsonKey() final  String callUrl;

/// Create a copy of TalkPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TalkPayloadCopyWith<_TalkPayload> get copyWith => __$TalkPayloadCopyWithImpl<_TalkPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TalkPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TalkPayload&&(identical(other.waUrl, waUrl) || other.waUrl == waUrl)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.available, available) || other.available == available)&&(identical(other.prefilledMessage, prefilledMessage) || other.prefilledMessage == prefilledMessage)&&(identical(other.callUrl, callUrl) || other.callUrl == callUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,waUrl,mobileNumber,available,prefilledMessage,callUrl);

@override
String toString() {
  return 'TalkPayload(waUrl: $waUrl, mobileNumber: $mobileNumber, available: $available, prefilledMessage: $prefilledMessage, callUrl: $callUrl)';
}


}

/// @nodoc
abstract mixin class _$TalkPayloadCopyWith<$Res> implements $TalkPayloadCopyWith<$Res> {
  factory _$TalkPayloadCopyWith(_TalkPayload value, $Res Function(_TalkPayload) _then) = __$TalkPayloadCopyWithImpl;
@override @useResult
$Res call({
 String waUrl, String mobileNumber, bool available, String prefilledMessage, String callUrl
});




}
/// @nodoc
class __$TalkPayloadCopyWithImpl<$Res>
    implements _$TalkPayloadCopyWith<$Res> {
  __$TalkPayloadCopyWithImpl(this._self, this._then);

  final _TalkPayload _self;
  final $Res Function(_TalkPayload) _then;

/// Create a copy of TalkPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? waUrl = null,Object? mobileNumber = null,Object? available = null,Object? prefilledMessage = null,Object? callUrl = null,}) {
  return _then(_TalkPayload(
waUrl: null == waUrl ? _self.waUrl : waUrl // ignore: cast_nullable_to_non_nullable
as String,mobileNumber: null == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,prefilledMessage: null == prefilledMessage ? _self.prefilledMessage : prefilledMessage // ignore: cast_nullable_to_non_nullable
as String,callUrl: null == callUrl ? _self.callUrl : callUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ConnectionRequestSnapshot {

 String get id;@_RequestTypeConverter() RequestType get requestType;@_DirectionConverter() Direction get direction; String? get reference; CategorySummary? get category; RegionSummary? get region;
/// Create a copy of ConnectionRequestSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionRequestSnapshotCopyWith<ConnectionRequestSnapshot> get copyWith => _$ConnectionRequestSnapshotCopyWithImpl<ConnectionRequestSnapshot>(this as ConnectionRequestSnapshot, _$identity);

  /// Serializes this ConnectionRequestSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionRequestSnapshot&&(identical(other.id, id) || other.id == id)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.category, category) || other.category == category)&&(identical(other.region, region) || other.region == region));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,requestType,direction,reference,category,region);

@override
String toString() {
  return 'ConnectionRequestSnapshot(id: $id, requestType: $requestType, direction: $direction, reference: $reference, category: $category, region: $region)';
}


}

/// @nodoc
abstract mixin class $ConnectionRequestSnapshotCopyWith<$Res>  {
  factory $ConnectionRequestSnapshotCopyWith(ConnectionRequestSnapshot value, $Res Function(ConnectionRequestSnapshot) _then) = _$ConnectionRequestSnapshotCopyWithImpl;
@useResult
$Res call({
 String id,@_RequestTypeConverter() RequestType requestType,@_DirectionConverter() Direction direction, String? reference, CategorySummary? category, RegionSummary? region
});


$CategorySummaryCopyWith<$Res>? get category;$RegionSummaryCopyWith<$Res>? get region;

}
/// @nodoc
class _$ConnectionRequestSnapshotCopyWithImpl<$Res>
    implements $ConnectionRequestSnapshotCopyWith<$Res> {
  _$ConnectionRequestSnapshotCopyWithImpl(this._self, this._then);

  final ConnectionRequestSnapshot _self;
  final $Res Function(ConnectionRequestSnapshot) _then;

/// Create a copy of ConnectionRequestSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? requestType = null,Object? direction = null,Object? reference = freezed,Object? category = freezed,Object? region = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,requestType: null == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as RequestType,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as Direction,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategorySummary?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as RegionSummary?,
  ));
}
/// Create a copy of ConnectionRequestSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategorySummaryCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategorySummaryCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of ConnectionRequestSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegionSummaryCopyWith<$Res>? get region {
    if (_self.region == null) {
    return null;
  }

  return $RegionSummaryCopyWith<$Res>(_self.region!, (value) {
    return _then(_self.copyWith(region: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConnectionRequestSnapshot].
extension ConnectionRequestSnapshotPatterns on ConnectionRequestSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConnectionRequestSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConnectionRequestSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConnectionRequestSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _ConnectionRequestSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConnectionRequestSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _ConnectionRequestSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @_RequestTypeConverter()  RequestType requestType, @_DirectionConverter()  Direction direction,  String? reference,  CategorySummary? category,  RegionSummary? region)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConnectionRequestSnapshot() when $default != null:
return $default(_that.id,_that.requestType,_that.direction,_that.reference,_that.category,_that.region);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @_RequestTypeConverter()  RequestType requestType, @_DirectionConverter()  Direction direction,  String? reference,  CategorySummary? category,  RegionSummary? region)  $default,) {final _that = this;
switch (_that) {
case _ConnectionRequestSnapshot():
return $default(_that.id,_that.requestType,_that.direction,_that.reference,_that.category,_that.region);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @_RequestTypeConverter()  RequestType requestType, @_DirectionConverter()  Direction direction,  String? reference,  CategorySummary? category,  RegionSummary? region)?  $default,) {final _that = this;
switch (_that) {
case _ConnectionRequestSnapshot() when $default != null:
return $default(_that.id,_that.requestType,_that.direction,_that.reference,_that.category,_that.region);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConnectionRequestSnapshot implements ConnectionRequestSnapshot {
  const _ConnectionRequestSnapshot({required this.id, @_RequestTypeConverter() required this.requestType, @_DirectionConverter() required this.direction, this.reference, this.category, this.region});
  factory _ConnectionRequestSnapshot.fromJson(Map<String, dynamic> json) => _$ConnectionRequestSnapshotFromJson(json);

@override final  String id;
@override@_RequestTypeConverter() final  RequestType requestType;
@override@_DirectionConverter() final  Direction direction;
@override final  String? reference;
@override final  CategorySummary? category;
@override final  RegionSummary? region;

/// Create a copy of ConnectionRequestSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectionRequestSnapshotCopyWith<_ConnectionRequestSnapshot> get copyWith => __$ConnectionRequestSnapshotCopyWithImpl<_ConnectionRequestSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConnectionRequestSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConnectionRequestSnapshot&&(identical(other.id, id) || other.id == id)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.category, category) || other.category == category)&&(identical(other.region, region) || other.region == region));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,requestType,direction,reference,category,region);

@override
String toString() {
  return 'ConnectionRequestSnapshot(id: $id, requestType: $requestType, direction: $direction, reference: $reference, category: $category, region: $region)';
}


}

/// @nodoc
abstract mixin class _$ConnectionRequestSnapshotCopyWith<$Res> implements $ConnectionRequestSnapshotCopyWith<$Res> {
  factory _$ConnectionRequestSnapshotCopyWith(_ConnectionRequestSnapshot value, $Res Function(_ConnectionRequestSnapshot) _then) = __$ConnectionRequestSnapshotCopyWithImpl;
@override @useResult
$Res call({
 String id,@_RequestTypeConverter() RequestType requestType,@_DirectionConverter() Direction direction, String? reference, CategorySummary? category, RegionSummary? region
});


@override $CategorySummaryCopyWith<$Res>? get category;@override $RegionSummaryCopyWith<$Res>? get region;

}
/// @nodoc
class __$ConnectionRequestSnapshotCopyWithImpl<$Res>
    implements _$ConnectionRequestSnapshotCopyWith<$Res> {
  __$ConnectionRequestSnapshotCopyWithImpl(this._self, this._then);

  final _ConnectionRequestSnapshot _self;
  final $Res Function(_ConnectionRequestSnapshot) _then;

/// Create a copy of ConnectionRequestSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? requestType = null,Object? direction = null,Object? reference = freezed,Object? category = freezed,Object? region = freezed,}) {
  return _then(_ConnectionRequestSnapshot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,requestType: null == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as RequestType,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as Direction,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategorySummary?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as RegionSummary?,
  ));
}

/// Create a copy of ConnectionRequestSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategorySummaryCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategorySummaryCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of ConnectionRequestSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegionSummaryCopyWith<$Res>? get region {
    if (_self.region == null) {
    return null;
  }

  return $RegionSummaryCopyWith<$Res>(_self.region!, (value) {
    return _then(_self.copyWith(region: value));
  });
}
}


/// @nodoc
mixin _$ConnectionAcceptedOffer {

 String get id;@JsonKey(fromJson: _connectionOfferTermsFromJson, toJson: _connectionOfferTermsToJson) OfferTerms get terms; DateTime? get submittedAt;
/// Create a copy of ConnectionAcceptedOffer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionAcceptedOfferCopyWith<ConnectionAcceptedOffer> get copyWith => _$ConnectionAcceptedOfferCopyWithImpl<ConnectionAcceptedOffer>(this as ConnectionAcceptedOffer, _$identity);

  /// Serializes this ConnectionAcceptedOffer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionAcceptedOffer&&(identical(other.id, id) || other.id == id)&&(identical(other.terms, terms) || other.terms == terms)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,terms,submittedAt);

@override
String toString() {
  return 'ConnectionAcceptedOffer(id: $id, terms: $terms, submittedAt: $submittedAt)';
}


}

/// @nodoc
abstract mixin class $ConnectionAcceptedOfferCopyWith<$Res>  {
  factory $ConnectionAcceptedOfferCopyWith(ConnectionAcceptedOffer value, $Res Function(ConnectionAcceptedOffer) _then) = _$ConnectionAcceptedOfferCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(fromJson: _connectionOfferTermsFromJson, toJson: _connectionOfferTermsToJson) OfferTerms terms, DateTime? submittedAt
});


$OfferTermsCopyWith<$Res> get terms;

}
/// @nodoc
class _$ConnectionAcceptedOfferCopyWithImpl<$Res>
    implements $ConnectionAcceptedOfferCopyWith<$Res> {
  _$ConnectionAcceptedOfferCopyWithImpl(this._self, this._then);

  final ConnectionAcceptedOffer _self;
  final $Res Function(ConnectionAcceptedOffer) _then;

/// Create a copy of ConnectionAcceptedOffer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? terms = null,Object? submittedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,terms: null == terms ? _self.terms : terms // ignore: cast_nullable_to_non_nullable
as OfferTerms,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of ConnectionAcceptedOffer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferTermsCopyWith<$Res> get terms {
  
  return $OfferTermsCopyWith<$Res>(_self.terms, (value) {
    return _then(_self.copyWith(terms: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConnectionAcceptedOffer].
extension ConnectionAcceptedOfferPatterns on ConnectionAcceptedOffer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConnectionAcceptedOffer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConnectionAcceptedOffer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConnectionAcceptedOffer value)  $default,){
final _that = this;
switch (_that) {
case _ConnectionAcceptedOffer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConnectionAcceptedOffer value)?  $default,){
final _that = this;
switch (_that) {
case _ConnectionAcceptedOffer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(fromJson: _connectionOfferTermsFromJson, toJson: _connectionOfferTermsToJson)  OfferTerms terms,  DateTime? submittedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConnectionAcceptedOffer() when $default != null:
return $default(_that.id,_that.terms,_that.submittedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(fromJson: _connectionOfferTermsFromJson, toJson: _connectionOfferTermsToJson)  OfferTerms terms,  DateTime? submittedAt)  $default,) {final _that = this;
switch (_that) {
case _ConnectionAcceptedOffer():
return $default(_that.id,_that.terms,_that.submittedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(fromJson: _connectionOfferTermsFromJson, toJson: _connectionOfferTermsToJson)  OfferTerms terms,  DateTime? submittedAt)?  $default,) {final _that = this;
switch (_that) {
case _ConnectionAcceptedOffer() when $default != null:
return $default(_that.id,_that.terms,_that.submittedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConnectionAcceptedOffer implements ConnectionAcceptedOffer {
  const _ConnectionAcceptedOffer({required this.id, @JsonKey(fromJson: _connectionOfferTermsFromJson, toJson: _connectionOfferTermsToJson) required this.terms, this.submittedAt});
  factory _ConnectionAcceptedOffer.fromJson(Map<String, dynamic> json) => _$ConnectionAcceptedOfferFromJson(json);

@override final  String id;
@override@JsonKey(fromJson: _connectionOfferTermsFromJson, toJson: _connectionOfferTermsToJson) final  OfferTerms terms;
@override final  DateTime? submittedAt;

/// Create a copy of ConnectionAcceptedOffer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectionAcceptedOfferCopyWith<_ConnectionAcceptedOffer> get copyWith => __$ConnectionAcceptedOfferCopyWithImpl<_ConnectionAcceptedOffer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConnectionAcceptedOfferToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConnectionAcceptedOffer&&(identical(other.id, id) || other.id == id)&&(identical(other.terms, terms) || other.terms == terms)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,terms,submittedAt);

@override
String toString() {
  return 'ConnectionAcceptedOffer(id: $id, terms: $terms, submittedAt: $submittedAt)';
}


}

/// @nodoc
abstract mixin class _$ConnectionAcceptedOfferCopyWith<$Res> implements $ConnectionAcceptedOfferCopyWith<$Res> {
  factory _$ConnectionAcceptedOfferCopyWith(_ConnectionAcceptedOffer value, $Res Function(_ConnectionAcceptedOffer) _then) = __$ConnectionAcceptedOfferCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(fromJson: _connectionOfferTermsFromJson, toJson: _connectionOfferTermsToJson) OfferTerms terms, DateTime? submittedAt
});


@override $OfferTermsCopyWith<$Res> get terms;

}
/// @nodoc
class __$ConnectionAcceptedOfferCopyWithImpl<$Res>
    implements _$ConnectionAcceptedOfferCopyWith<$Res> {
  __$ConnectionAcceptedOfferCopyWithImpl(this._self, this._then);

  final _ConnectionAcceptedOffer _self;
  final $Res Function(_ConnectionAcceptedOffer) _then;

/// Create a copy of ConnectionAcceptedOffer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? terms = null,Object? submittedAt = freezed,}) {
  return _then(_ConnectionAcceptedOffer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,terms: null == terms ? _self.terms : terms // ignore: cast_nullable_to_non_nullable
as OfferTerms,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of ConnectionAcceptedOffer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferTermsCopyWith<$Res> get terms {
  
  return $OfferTermsCopyWith<$Res>(_self.terms, (value) {
    return _then(_self.copyWith(terms: value));
  });
}
}


/// @nodoc
mixin _$ConnectionForCustomer {

 String get id;@_ConnectionStateConverter() ConnectionState get state;@JsonKey(fromJson: _vendorPartyFromJson) RevealedParty get vendor; TalkPayload get talk; DateTime get identityRevealedAt; ConnectionRequestSnapshot? get request; ConnectionAcceptedOffer? get acceptedOffer; DateTime? get closedAt;@_NullableClosedByConverter() ClosedBy? get closedBy; String? get offerId; String? get requestId; DateTime? get createdAt; Review? get myReview;
/// Create a copy of ConnectionForCustomer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionForCustomerCopyWith<ConnectionForCustomer> get copyWith => _$ConnectionForCustomerCopyWithImpl<ConnectionForCustomer>(this as ConnectionForCustomer, _$identity);

  /// Serializes this ConnectionForCustomer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionForCustomer&&(identical(other.id, id) || other.id == id)&&(identical(other.state, state) || other.state == state)&&(identical(other.vendor, vendor) || other.vendor == vendor)&&(identical(other.talk, talk) || other.talk == talk)&&(identical(other.identityRevealedAt, identityRevealedAt) || other.identityRevealedAt == identityRevealedAt)&&(identical(other.request, request) || other.request == request)&&(identical(other.acceptedOffer, acceptedOffer) || other.acceptedOffer == acceptedOffer)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&(identical(other.closedBy, closedBy) || other.closedBy == closedBy)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.myReview, myReview) || other.myReview == myReview));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,state,vendor,talk,identityRevealedAt,request,acceptedOffer,closedAt,closedBy,offerId,requestId,createdAt,myReview);

@override
String toString() {
  return 'ConnectionForCustomer(id: $id, state: $state, vendor: $vendor, talk: $talk, identityRevealedAt: $identityRevealedAt, request: $request, acceptedOffer: $acceptedOffer, closedAt: $closedAt, closedBy: $closedBy, offerId: $offerId, requestId: $requestId, createdAt: $createdAt, myReview: $myReview)';
}


}

/// @nodoc
abstract mixin class $ConnectionForCustomerCopyWith<$Res>  {
  factory $ConnectionForCustomerCopyWith(ConnectionForCustomer value, $Res Function(ConnectionForCustomer) _then) = _$ConnectionForCustomerCopyWithImpl;
@useResult
$Res call({
 String id,@_ConnectionStateConverter() ConnectionState state,@JsonKey(fromJson: _vendorPartyFromJson) RevealedParty vendor, TalkPayload talk, DateTime identityRevealedAt, ConnectionRequestSnapshot? request, ConnectionAcceptedOffer? acceptedOffer, DateTime? closedAt,@_NullableClosedByConverter() ClosedBy? closedBy, String? offerId, String? requestId, DateTime? createdAt, Review? myReview
});


$TalkPayloadCopyWith<$Res> get talk;$ConnectionRequestSnapshotCopyWith<$Res>? get request;$ConnectionAcceptedOfferCopyWith<$Res>? get acceptedOffer;$ReviewCopyWith<$Res>? get myReview;

}
/// @nodoc
class _$ConnectionForCustomerCopyWithImpl<$Res>
    implements $ConnectionForCustomerCopyWith<$Res> {
  _$ConnectionForCustomerCopyWithImpl(this._self, this._then);

  final ConnectionForCustomer _self;
  final $Res Function(ConnectionForCustomer) _then;

/// Create a copy of ConnectionForCustomer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? state = null,Object? vendor = null,Object? talk = null,Object? identityRevealedAt = null,Object? request = freezed,Object? acceptedOffer = freezed,Object? closedAt = freezed,Object? closedBy = freezed,Object? offerId = freezed,Object? requestId = freezed,Object? createdAt = freezed,Object? myReview = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ConnectionState,vendor: null == vendor ? _self.vendor : vendor // ignore: cast_nullable_to_non_nullable
as RevealedParty,talk: null == talk ? _self.talk : talk // ignore: cast_nullable_to_non_nullable
as TalkPayload,identityRevealedAt: null == identityRevealedAt ? _self.identityRevealedAt : identityRevealedAt // ignore: cast_nullable_to_non_nullable
as DateTime,request: freezed == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as ConnectionRequestSnapshot?,acceptedOffer: freezed == acceptedOffer ? _self.acceptedOffer : acceptedOffer // ignore: cast_nullable_to_non_nullable
as ConnectionAcceptedOffer?,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,closedBy: freezed == closedBy ? _self.closedBy : closedBy // ignore: cast_nullable_to_non_nullable
as ClosedBy?,offerId: freezed == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,myReview: freezed == myReview ? _self.myReview : myReview // ignore: cast_nullable_to_non_nullable
as Review?,
  ));
}
/// Create a copy of ConnectionForCustomer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TalkPayloadCopyWith<$Res> get talk {
  
  return $TalkPayloadCopyWith<$Res>(_self.talk, (value) {
    return _then(_self.copyWith(talk: value));
  });
}/// Create a copy of ConnectionForCustomer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConnectionRequestSnapshotCopyWith<$Res>? get request {
    if (_self.request == null) {
    return null;
  }

  return $ConnectionRequestSnapshotCopyWith<$Res>(_self.request!, (value) {
    return _then(_self.copyWith(request: value));
  });
}/// Create a copy of ConnectionForCustomer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConnectionAcceptedOfferCopyWith<$Res>? get acceptedOffer {
    if (_self.acceptedOffer == null) {
    return null;
  }

  return $ConnectionAcceptedOfferCopyWith<$Res>(_self.acceptedOffer!, (value) {
    return _then(_self.copyWith(acceptedOffer: value));
  });
}/// Create a copy of ConnectionForCustomer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReviewCopyWith<$Res>? get myReview {
    if (_self.myReview == null) {
    return null;
  }

  return $ReviewCopyWith<$Res>(_self.myReview!, (value) {
    return _then(_self.copyWith(myReview: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConnectionForCustomer].
extension ConnectionForCustomerPatterns on ConnectionForCustomer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConnectionForCustomer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConnectionForCustomer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConnectionForCustomer value)  $default,){
final _that = this;
switch (_that) {
case _ConnectionForCustomer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConnectionForCustomer value)?  $default,){
final _that = this;
switch (_that) {
case _ConnectionForCustomer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @_ConnectionStateConverter()  ConnectionState state, @JsonKey(fromJson: _vendorPartyFromJson)  RevealedParty vendor,  TalkPayload talk,  DateTime identityRevealedAt,  ConnectionRequestSnapshot? request,  ConnectionAcceptedOffer? acceptedOffer,  DateTime? closedAt, @_NullableClosedByConverter()  ClosedBy? closedBy,  String? offerId,  String? requestId,  DateTime? createdAt,  Review? myReview)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConnectionForCustomer() when $default != null:
return $default(_that.id,_that.state,_that.vendor,_that.talk,_that.identityRevealedAt,_that.request,_that.acceptedOffer,_that.closedAt,_that.closedBy,_that.offerId,_that.requestId,_that.createdAt,_that.myReview);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @_ConnectionStateConverter()  ConnectionState state, @JsonKey(fromJson: _vendorPartyFromJson)  RevealedParty vendor,  TalkPayload talk,  DateTime identityRevealedAt,  ConnectionRequestSnapshot? request,  ConnectionAcceptedOffer? acceptedOffer,  DateTime? closedAt, @_NullableClosedByConverter()  ClosedBy? closedBy,  String? offerId,  String? requestId,  DateTime? createdAt,  Review? myReview)  $default,) {final _that = this;
switch (_that) {
case _ConnectionForCustomer():
return $default(_that.id,_that.state,_that.vendor,_that.talk,_that.identityRevealedAt,_that.request,_that.acceptedOffer,_that.closedAt,_that.closedBy,_that.offerId,_that.requestId,_that.createdAt,_that.myReview);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @_ConnectionStateConverter()  ConnectionState state, @JsonKey(fromJson: _vendorPartyFromJson)  RevealedParty vendor,  TalkPayload talk,  DateTime identityRevealedAt,  ConnectionRequestSnapshot? request,  ConnectionAcceptedOffer? acceptedOffer,  DateTime? closedAt, @_NullableClosedByConverter()  ClosedBy? closedBy,  String? offerId,  String? requestId,  DateTime? createdAt,  Review? myReview)?  $default,) {final _that = this;
switch (_that) {
case _ConnectionForCustomer() when $default != null:
return $default(_that.id,_that.state,_that.vendor,_that.talk,_that.identityRevealedAt,_that.request,_that.acceptedOffer,_that.closedAt,_that.closedBy,_that.offerId,_that.requestId,_that.createdAt,_that.myReview);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConnectionForCustomer implements ConnectionForCustomer {
  const _ConnectionForCustomer({required this.id, @_ConnectionStateConverter() required this.state, @JsonKey(fromJson: _vendorPartyFromJson) required this.vendor, required this.talk, required this.identityRevealedAt, this.request, this.acceptedOffer, this.closedAt, @_NullableClosedByConverter() this.closedBy, this.offerId, this.requestId, this.createdAt, this.myReview});
  factory _ConnectionForCustomer.fromJson(Map<String, dynamic> json) => _$ConnectionForCustomerFromJson(json);

@override final  String id;
@override@_ConnectionStateConverter() final  ConnectionState state;
@override@JsonKey(fromJson: _vendorPartyFromJson) final  RevealedParty vendor;
@override final  TalkPayload talk;
@override final  DateTime identityRevealedAt;
@override final  ConnectionRequestSnapshot? request;
@override final  ConnectionAcceptedOffer? acceptedOffer;
@override final  DateTime? closedAt;
@override@_NullableClosedByConverter() final  ClosedBy? closedBy;
@override final  String? offerId;
@override final  String? requestId;
@override final  DateTime? createdAt;
@override final  Review? myReview;

/// Create a copy of ConnectionForCustomer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectionForCustomerCopyWith<_ConnectionForCustomer> get copyWith => __$ConnectionForCustomerCopyWithImpl<_ConnectionForCustomer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConnectionForCustomerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConnectionForCustomer&&(identical(other.id, id) || other.id == id)&&(identical(other.state, state) || other.state == state)&&(identical(other.vendor, vendor) || other.vendor == vendor)&&(identical(other.talk, talk) || other.talk == talk)&&(identical(other.identityRevealedAt, identityRevealedAt) || other.identityRevealedAt == identityRevealedAt)&&(identical(other.request, request) || other.request == request)&&(identical(other.acceptedOffer, acceptedOffer) || other.acceptedOffer == acceptedOffer)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&(identical(other.closedBy, closedBy) || other.closedBy == closedBy)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.myReview, myReview) || other.myReview == myReview));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,state,vendor,talk,identityRevealedAt,request,acceptedOffer,closedAt,closedBy,offerId,requestId,createdAt,myReview);

@override
String toString() {
  return 'ConnectionForCustomer(id: $id, state: $state, vendor: $vendor, talk: $talk, identityRevealedAt: $identityRevealedAt, request: $request, acceptedOffer: $acceptedOffer, closedAt: $closedAt, closedBy: $closedBy, offerId: $offerId, requestId: $requestId, createdAt: $createdAt, myReview: $myReview)';
}


}

/// @nodoc
abstract mixin class _$ConnectionForCustomerCopyWith<$Res> implements $ConnectionForCustomerCopyWith<$Res> {
  factory _$ConnectionForCustomerCopyWith(_ConnectionForCustomer value, $Res Function(_ConnectionForCustomer) _then) = __$ConnectionForCustomerCopyWithImpl;
@override @useResult
$Res call({
 String id,@_ConnectionStateConverter() ConnectionState state,@JsonKey(fromJson: _vendorPartyFromJson) RevealedParty vendor, TalkPayload talk, DateTime identityRevealedAt, ConnectionRequestSnapshot? request, ConnectionAcceptedOffer? acceptedOffer, DateTime? closedAt,@_NullableClosedByConverter() ClosedBy? closedBy, String? offerId, String? requestId, DateTime? createdAt, Review? myReview
});


@override $TalkPayloadCopyWith<$Res> get talk;@override $ConnectionRequestSnapshotCopyWith<$Res>? get request;@override $ConnectionAcceptedOfferCopyWith<$Res>? get acceptedOffer;@override $ReviewCopyWith<$Res>? get myReview;

}
/// @nodoc
class __$ConnectionForCustomerCopyWithImpl<$Res>
    implements _$ConnectionForCustomerCopyWith<$Res> {
  __$ConnectionForCustomerCopyWithImpl(this._self, this._then);

  final _ConnectionForCustomer _self;
  final $Res Function(_ConnectionForCustomer) _then;

/// Create a copy of ConnectionForCustomer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? state = null,Object? vendor = null,Object? talk = null,Object? identityRevealedAt = null,Object? request = freezed,Object? acceptedOffer = freezed,Object? closedAt = freezed,Object? closedBy = freezed,Object? offerId = freezed,Object? requestId = freezed,Object? createdAt = freezed,Object? myReview = freezed,}) {
  return _then(_ConnectionForCustomer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ConnectionState,vendor: null == vendor ? _self.vendor : vendor // ignore: cast_nullable_to_non_nullable
as RevealedParty,talk: null == talk ? _self.talk : talk // ignore: cast_nullable_to_non_nullable
as TalkPayload,identityRevealedAt: null == identityRevealedAt ? _self.identityRevealedAt : identityRevealedAt // ignore: cast_nullable_to_non_nullable
as DateTime,request: freezed == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as ConnectionRequestSnapshot?,acceptedOffer: freezed == acceptedOffer ? _self.acceptedOffer : acceptedOffer // ignore: cast_nullable_to_non_nullable
as ConnectionAcceptedOffer?,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,closedBy: freezed == closedBy ? _self.closedBy : closedBy // ignore: cast_nullable_to_non_nullable
as ClosedBy?,offerId: freezed == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,myReview: freezed == myReview ? _self.myReview : myReview // ignore: cast_nullable_to_non_nullable
as Review?,
  ));
}

/// Create a copy of ConnectionForCustomer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TalkPayloadCopyWith<$Res> get talk {
  
  return $TalkPayloadCopyWith<$Res>(_self.talk, (value) {
    return _then(_self.copyWith(talk: value));
  });
}/// Create a copy of ConnectionForCustomer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConnectionRequestSnapshotCopyWith<$Res>? get request {
    if (_self.request == null) {
    return null;
  }

  return $ConnectionRequestSnapshotCopyWith<$Res>(_self.request!, (value) {
    return _then(_self.copyWith(request: value));
  });
}/// Create a copy of ConnectionForCustomer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConnectionAcceptedOfferCopyWith<$Res>? get acceptedOffer {
    if (_self.acceptedOffer == null) {
    return null;
  }

  return $ConnectionAcceptedOfferCopyWith<$Res>(_self.acceptedOffer!, (value) {
    return _then(_self.copyWith(acceptedOffer: value));
  });
}/// Create a copy of ConnectionForCustomer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReviewCopyWith<$Res>? get myReview {
    if (_self.myReview == null) {
    return null;
  }

  return $ReviewCopyWith<$Res>(_self.myReview!, (value) {
    return _then(_self.copyWith(myReview: value));
  });
}
}


/// @nodoc
mixin _$AcceptOfferResult {

 OfferForCustomer get offer; ConnectionForCustomer get connection;
/// Create a copy of AcceptOfferResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AcceptOfferResultCopyWith<AcceptOfferResult> get copyWith => _$AcceptOfferResultCopyWithImpl<AcceptOfferResult>(this as AcceptOfferResult, _$identity);

  /// Serializes this AcceptOfferResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AcceptOfferResult&&(identical(other.offer, offer) || other.offer == offer)&&(identical(other.connection, connection) || other.connection == connection));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,offer,connection);

@override
String toString() {
  return 'AcceptOfferResult(offer: $offer, connection: $connection)';
}


}

/// @nodoc
abstract mixin class $AcceptOfferResultCopyWith<$Res>  {
  factory $AcceptOfferResultCopyWith(AcceptOfferResult value, $Res Function(AcceptOfferResult) _then) = _$AcceptOfferResultCopyWithImpl;
@useResult
$Res call({
 OfferForCustomer offer, ConnectionForCustomer connection
});


$OfferForCustomerCopyWith<$Res> get offer;$ConnectionForCustomerCopyWith<$Res> get connection;

}
/// @nodoc
class _$AcceptOfferResultCopyWithImpl<$Res>
    implements $AcceptOfferResultCopyWith<$Res> {
  _$AcceptOfferResultCopyWithImpl(this._self, this._then);

  final AcceptOfferResult _self;
  final $Res Function(AcceptOfferResult) _then;

/// Create a copy of AcceptOfferResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? offer = null,Object? connection = null,}) {
  return _then(_self.copyWith(
offer: null == offer ? _self.offer : offer // ignore: cast_nullable_to_non_nullable
as OfferForCustomer,connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as ConnectionForCustomer,
  ));
}
/// Create a copy of AcceptOfferResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferForCustomerCopyWith<$Res> get offer {
  
  return $OfferForCustomerCopyWith<$Res>(_self.offer, (value) {
    return _then(_self.copyWith(offer: value));
  });
}/// Create a copy of AcceptOfferResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConnectionForCustomerCopyWith<$Res> get connection {
  
  return $ConnectionForCustomerCopyWith<$Res>(_self.connection, (value) {
    return _then(_self.copyWith(connection: value));
  });
}
}


/// Adds pattern-matching-related methods to [AcceptOfferResult].
extension AcceptOfferResultPatterns on AcceptOfferResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AcceptOfferResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AcceptOfferResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AcceptOfferResult value)  $default,){
final _that = this;
switch (_that) {
case _AcceptOfferResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AcceptOfferResult value)?  $default,){
final _that = this;
switch (_that) {
case _AcceptOfferResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OfferForCustomer offer,  ConnectionForCustomer connection)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AcceptOfferResult() when $default != null:
return $default(_that.offer,_that.connection);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OfferForCustomer offer,  ConnectionForCustomer connection)  $default,) {final _that = this;
switch (_that) {
case _AcceptOfferResult():
return $default(_that.offer,_that.connection);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OfferForCustomer offer,  ConnectionForCustomer connection)?  $default,) {final _that = this;
switch (_that) {
case _AcceptOfferResult() when $default != null:
return $default(_that.offer,_that.connection);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AcceptOfferResult implements AcceptOfferResult {
  const _AcceptOfferResult({required this.offer, required this.connection});
  factory _AcceptOfferResult.fromJson(Map<String, dynamic> json) => _$AcceptOfferResultFromJson(json);

@override final  OfferForCustomer offer;
@override final  ConnectionForCustomer connection;

/// Create a copy of AcceptOfferResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AcceptOfferResultCopyWith<_AcceptOfferResult> get copyWith => __$AcceptOfferResultCopyWithImpl<_AcceptOfferResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AcceptOfferResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AcceptOfferResult&&(identical(other.offer, offer) || other.offer == offer)&&(identical(other.connection, connection) || other.connection == connection));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,offer,connection);

@override
String toString() {
  return 'AcceptOfferResult(offer: $offer, connection: $connection)';
}


}

/// @nodoc
abstract mixin class _$AcceptOfferResultCopyWith<$Res> implements $AcceptOfferResultCopyWith<$Res> {
  factory _$AcceptOfferResultCopyWith(_AcceptOfferResult value, $Res Function(_AcceptOfferResult) _then) = __$AcceptOfferResultCopyWithImpl;
@override @useResult
$Res call({
 OfferForCustomer offer, ConnectionForCustomer connection
});


@override $OfferForCustomerCopyWith<$Res> get offer;@override $ConnectionForCustomerCopyWith<$Res> get connection;

}
/// @nodoc
class __$AcceptOfferResultCopyWithImpl<$Res>
    implements _$AcceptOfferResultCopyWith<$Res> {
  __$AcceptOfferResultCopyWithImpl(this._self, this._then);

  final _AcceptOfferResult _self;
  final $Res Function(_AcceptOfferResult) _then;

/// Create a copy of AcceptOfferResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? offer = null,Object? connection = null,}) {
  return _then(_AcceptOfferResult(
offer: null == offer ? _self.offer : offer // ignore: cast_nullable_to_non_nullable
as OfferForCustomer,connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as ConnectionForCustomer,
  ));
}

/// Create a copy of AcceptOfferResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferForCustomerCopyWith<$Res> get offer {
  
  return $OfferForCustomerCopyWith<$Res>(_self.offer, (value) {
    return _then(_self.copyWith(offer: value));
  });
}/// Create a copy of AcceptOfferResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConnectionForCustomerCopyWith<$Res> get connection {
  
  return $ConnectionForCustomerCopyWith<$Res>(_self.connection, (value) {
    return _then(_self.copyWith(connection: value));
  });
}
}


/// @nodoc
mixin _$ConnectionForVendor {

 String get id;@_ConnectionStateConverter() ConnectionState get state;@JsonKey(fromJson: _customerPartyFromJson) RevealedParty get customer; TalkPayload get talk; DateTime get identityRevealedAt; ConnectionRequestSnapshot? get request; ConnectionAcceptedOffer? get acceptedOffer; DateTime? get closedAt;@_NullableClosedByConverter() ClosedBy? get closedBy; String? get offerId; String? get requestId; DateTime? get createdAt;
/// Create a copy of ConnectionForVendor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionForVendorCopyWith<ConnectionForVendor> get copyWith => _$ConnectionForVendorCopyWithImpl<ConnectionForVendor>(this as ConnectionForVendor, _$identity);

  /// Serializes this ConnectionForVendor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionForVendor&&(identical(other.id, id) || other.id == id)&&(identical(other.state, state) || other.state == state)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.talk, talk) || other.talk == talk)&&(identical(other.identityRevealedAt, identityRevealedAt) || other.identityRevealedAt == identityRevealedAt)&&(identical(other.request, request) || other.request == request)&&(identical(other.acceptedOffer, acceptedOffer) || other.acceptedOffer == acceptedOffer)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&(identical(other.closedBy, closedBy) || other.closedBy == closedBy)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,state,customer,talk,identityRevealedAt,request,acceptedOffer,closedAt,closedBy,offerId,requestId,createdAt);

@override
String toString() {
  return 'ConnectionForVendor(id: $id, state: $state, customer: $customer, talk: $talk, identityRevealedAt: $identityRevealedAt, request: $request, acceptedOffer: $acceptedOffer, closedAt: $closedAt, closedBy: $closedBy, offerId: $offerId, requestId: $requestId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ConnectionForVendorCopyWith<$Res>  {
  factory $ConnectionForVendorCopyWith(ConnectionForVendor value, $Res Function(ConnectionForVendor) _then) = _$ConnectionForVendorCopyWithImpl;
@useResult
$Res call({
 String id,@_ConnectionStateConverter() ConnectionState state,@JsonKey(fromJson: _customerPartyFromJson) RevealedParty customer, TalkPayload talk, DateTime identityRevealedAt, ConnectionRequestSnapshot? request, ConnectionAcceptedOffer? acceptedOffer, DateTime? closedAt,@_NullableClosedByConverter() ClosedBy? closedBy, String? offerId, String? requestId, DateTime? createdAt
});


$TalkPayloadCopyWith<$Res> get talk;$ConnectionRequestSnapshotCopyWith<$Res>? get request;$ConnectionAcceptedOfferCopyWith<$Res>? get acceptedOffer;

}
/// @nodoc
class _$ConnectionForVendorCopyWithImpl<$Res>
    implements $ConnectionForVendorCopyWith<$Res> {
  _$ConnectionForVendorCopyWithImpl(this._self, this._then);

  final ConnectionForVendor _self;
  final $Res Function(ConnectionForVendor) _then;

/// Create a copy of ConnectionForVendor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? state = null,Object? customer = null,Object? talk = null,Object? identityRevealedAt = null,Object? request = freezed,Object? acceptedOffer = freezed,Object? closedAt = freezed,Object? closedBy = freezed,Object? offerId = freezed,Object? requestId = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ConnectionState,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as RevealedParty,talk: null == talk ? _self.talk : talk // ignore: cast_nullable_to_non_nullable
as TalkPayload,identityRevealedAt: null == identityRevealedAt ? _self.identityRevealedAt : identityRevealedAt // ignore: cast_nullable_to_non_nullable
as DateTime,request: freezed == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as ConnectionRequestSnapshot?,acceptedOffer: freezed == acceptedOffer ? _self.acceptedOffer : acceptedOffer // ignore: cast_nullable_to_non_nullable
as ConnectionAcceptedOffer?,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,closedBy: freezed == closedBy ? _self.closedBy : closedBy // ignore: cast_nullable_to_non_nullable
as ClosedBy?,offerId: freezed == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of ConnectionForVendor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TalkPayloadCopyWith<$Res> get talk {
  
  return $TalkPayloadCopyWith<$Res>(_self.talk, (value) {
    return _then(_self.copyWith(talk: value));
  });
}/// Create a copy of ConnectionForVendor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConnectionRequestSnapshotCopyWith<$Res>? get request {
    if (_self.request == null) {
    return null;
  }

  return $ConnectionRequestSnapshotCopyWith<$Res>(_self.request!, (value) {
    return _then(_self.copyWith(request: value));
  });
}/// Create a copy of ConnectionForVendor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConnectionAcceptedOfferCopyWith<$Res>? get acceptedOffer {
    if (_self.acceptedOffer == null) {
    return null;
  }

  return $ConnectionAcceptedOfferCopyWith<$Res>(_self.acceptedOffer!, (value) {
    return _then(_self.copyWith(acceptedOffer: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConnectionForVendor].
extension ConnectionForVendorPatterns on ConnectionForVendor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConnectionForVendor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConnectionForVendor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConnectionForVendor value)  $default,){
final _that = this;
switch (_that) {
case _ConnectionForVendor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConnectionForVendor value)?  $default,){
final _that = this;
switch (_that) {
case _ConnectionForVendor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @_ConnectionStateConverter()  ConnectionState state, @JsonKey(fromJson: _customerPartyFromJson)  RevealedParty customer,  TalkPayload talk,  DateTime identityRevealedAt,  ConnectionRequestSnapshot? request,  ConnectionAcceptedOffer? acceptedOffer,  DateTime? closedAt, @_NullableClosedByConverter()  ClosedBy? closedBy,  String? offerId,  String? requestId,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConnectionForVendor() when $default != null:
return $default(_that.id,_that.state,_that.customer,_that.talk,_that.identityRevealedAt,_that.request,_that.acceptedOffer,_that.closedAt,_that.closedBy,_that.offerId,_that.requestId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @_ConnectionStateConverter()  ConnectionState state, @JsonKey(fromJson: _customerPartyFromJson)  RevealedParty customer,  TalkPayload talk,  DateTime identityRevealedAt,  ConnectionRequestSnapshot? request,  ConnectionAcceptedOffer? acceptedOffer,  DateTime? closedAt, @_NullableClosedByConverter()  ClosedBy? closedBy,  String? offerId,  String? requestId,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ConnectionForVendor():
return $default(_that.id,_that.state,_that.customer,_that.talk,_that.identityRevealedAt,_that.request,_that.acceptedOffer,_that.closedAt,_that.closedBy,_that.offerId,_that.requestId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @_ConnectionStateConverter()  ConnectionState state, @JsonKey(fromJson: _customerPartyFromJson)  RevealedParty customer,  TalkPayload talk,  DateTime identityRevealedAt,  ConnectionRequestSnapshot? request,  ConnectionAcceptedOffer? acceptedOffer,  DateTime? closedAt, @_NullableClosedByConverter()  ClosedBy? closedBy,  String? offerId,  String? requestId,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ConnectionForVendor() when $default != null:
return $default(_that.id,_that.state,_that.customer,_that.talk,_that.identityRevealedAt,_that.request,_that.acceptedOffer,_that.closedAt,_that.closedBy,_that.offerId,_that.requestId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConnectionForVendor extends ConnectionForVendor {
  const _ConnectionForVendor({required this.id, @_ConnectionStateConverter() required this.state, @JsonKey(fromJson: _customerPartyFromJson) required this.customer, required this.talk, required this.identityRevealedAt, this.request, this.acceptedOffer, this.closedAt, @_NullableClosedByConverter() this.closedBy, this.offerId, this.requestId, this.createdAt}): super._();
  factory _ConnectionForVendor.fromJson(Map<String, dynamic> json) => _$ConnectionForVendorFromJson(json);

@override final  String id;
@override@_ConnectionStateConverter() final  ConnectionState state;
@override@JsonKey(fromJson: _customerPartyFromJson) final  RevealedParty customer;
@override final  TalkPayload talk;
@override final  DateTime identityRevealedAt;
@override final  ConnectionRequestSnapshot? request;
@override final  ConnectionAcceptedOffer? acceptedOffer;
@override final  DateTime? closedAt;
@override@_NullableClosedByConverter() final  ClosedBy? closedBy;
@override final  String? offerId;
@override final  String? requestId;
@override final  DateTime? createdAt;

/// Create a copy of ConnectionForVendor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectionForVendorCopyWith<_ConnectionForVendor> get copyWith => __$ConnectionForVendorCopyWithImpl<_ConnectionForVendor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConnectionForVendorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConnectionForVendor&&(identical(other.id, id) || other.id == id)&&(identical(other.state, state) || other.state == state)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.talk, talk) || other.talk == talk)&&(identical(other.identityRevealedAt, identityRevealedAt) || other.identityRevealedAt == identityRevealedAt)&&(identical(other.request, request) || other.request == request)&&(identical(other.acceptedOffer, acceptedOffer) || other.acceptedOffer == acceptedOffer)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&(identical(other.closedBy, closedBy) || other.closedBy == closedBy)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,state,customer,talk,identityRevealedAt,request,acceptedOffer,closedAt,closedBy,offerId,requestId,createdAt);

@override
String toString() {
  return 'ConnectionForVendor(id: $id, state: $state, customer: $customer, talk: $talk, identityRevealedAt: $identityRevealedAt, request: $request, acceptedOffer: $acceptedOffer, closedAt: $closedAt, closedBy: $closedBy, offerId: $offerId, requestId: $requestId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ConnectionForVendorCopyWith<$Res> implements $ConnectionForVendorCopyWith<$Res> {
  factory _$ConnectionForVendorCopyWith(_ConnectionForVendor value, $Res Function(_ConnectionForVendor) _then) = __$ConnectionForVendorCopyWithImpl;
@override @useResult
$Res call({
 String id,@_ConnectionStateConverter() ConnectionState state,@JsonKey(fromJson: _customerPartyFromJson) RevealedParty customer, TalkPayload talk, DateTime identityRevealedAt, ConnectionRequestSnapshot? request, ConnectionAcceptedOffer? acceptedOffer, DateTime? closedAt,@_NullableClosedByConverter() ClosedBy? closedBy, String? offerId, String? requestId, DateTime? createdAt
});


@override $TalkPayloadCopyWith<$Res> get talk;@override $ConnectionRequestSnapshotCopyWith<$Res>? get request;@override $ConnectionAcceptedOfferCopyWith<$Res>? get acceptedOffer;

}
/// @nodoc
class __$ConnectionForVendorCopyWithImpl<$Res>
    implements _$ConnectionForVendorCopyWith<$Res> {
  __$ConnectionForVendorCopyWithImpl(this._self, this._then);

  final _ConnectionForVendor _self;
  final $Res Function(_ConnectionForVendor) _then;

/// Create a copy of ConnectionForVendor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? state = null,Object? customer = null,Object? talk = null,Object? identityRevealedAt = null,Object? request = freezed,Object? acceptedOffer = freezed,Object? closedAt = freezed,Object? closedBy = freezed,Object? offerId = freezed,Object? requestId = freezed,Object? createdAt = freezed,}) {
  return _then(_ConnectionForVendor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as ConnectionState,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as RevealedParty,talk: null == talk ? _self.talk : talk // ignore: cast_nullable_to_non_nullable
as TalkPayload,identityRevealedAt: null == identityRevealedAt ? _self.identityRevealedAt : identityRevealedAt // ignore: cast_nullable_to_non_nullable
as DateTime,request: freezed == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as ConnectionRequestSnapshot?,acceptedOffer: freezed == acceptedOffer ? _self.acceptedOffer : acceptedOffer // ignore: cast_nullable_to_non_nullable
as ConnectionAcceptedOffer?,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,closedBy: freezed == closedBy ? _self.closedBy : closedBy // ignore: cast_nullable_to_non_nullable
as ClosedBy?,offerId: freezed == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of ConnectionForVendor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TalkPayloadCopyWith<$Res> get talk {
  
  return $TalkPayloadCopyWith<$Res>(_self.talk, (value) {
    return _then(_self.copyWith(talk: value));
  });
}/// Create a copy of ConnectionForVendor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConnectionRequestSnapshotCopyWith<$Res>? get request {
    if (_self.request == null) {
    return null;
  }

  return $ConnectionRequestSnapshotCopyWith<$Res>(_self.request!, (value) {
    return _then(_self.copyWith(request: value));
  });
}/// Create a copy of ConnectionForVendor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConnectionAcceptedOfferCopyWith<$Res>? get acceptedOffer {
    if (_self.acceptedOffer == null) {
    return null;
  }

  return $ConnectionAcceptedOfferCopyWith<$Res>(_self.acceptedOffer!, (value) {
    return _then(_self.copyWith(acceptedOffer: value));
  });
}
}

// dart format on
