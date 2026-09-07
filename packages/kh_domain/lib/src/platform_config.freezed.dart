// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'platform_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlatformConfig {

 int get requestLifetimeHours; List<int> get offerValidityHours; int get defaultOfferValidityHours; String get bullionMinimumAed; int get maxConcurrentLiveRequests; int get maxOfferRevisions; int get requestExpiryWarningHours; List<String> get karatList; String get supportContactUrl; String get subscriptionContactUrl; String get termsUrl; String get privacyUrl;
/// Create a copy of PlatformConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlatformConfigCopyWith<PlatformConfig> get copyWith => _$PlatformConfigCopyWithImpl<PlatformConfig>(this as PlatformConfig, _$identity);

  /// Serializes this PlatformConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlatformConfig&&(identical(other.requestLifetimeHours, requestLifetimeHours) || other.requestLifetimeHours == requestLifetimeHours)&&const DeepCollectionEquality().equals(other.offerValidityHours, offerValidityHours)&&(identical(other.defaultOfferValidityHours, defaultOfferValidityHours) || other.defaultOfferValidityHours == defaultOfferValidityHours)&&(identical(other.bullionMinimumAed, bullionMinimumAed) || other.bullionMinimumAed == bullionMinimumAed)&&(identical(other.maxConcurrentLiveRequests, maxConcurrentLiveRequests) || other.maxConcurrentLiveRequests == maxConcurrentLiveRequests)&&(identical(other.maxOfferRevisions, maxOfferRevisions) || other.maxOfferRevisions == maxOfferRevisions)&&(identical(other.requestExpiryWarningHours, requestExpiryWarningHours) || other.requestExpiryWarningHours == requestExpiryWarningHours)&&const DeepCollectionEquality().equals(other.karatList, karatList)&&(identical(other.supportContactUrl, supportContactUrl) || other.supportContactUrl == supportContactUrl)&&(identical(other.subscriptionContactUrl, subscriptionContactUrl) || other.subscriptionContactUrl == subscriptionContactUrl)&&(identical(other.termsUrl, termsUrl) || other.termsUrl == termsUrl)&&(identical(other.privacyUrl, privacyUrl) || other.privacyUrl == privacyUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requestLifetimeHours,const DeepCollectionEquality().hash(offerValidityHours),defaultOfferValidityHours,bullionMinimumAed,maxConcurrentLiveRequests,maxOfferRevisions,requestExpiryWarningHours,const DeepCollectionEquality().hash(karatList),supportContactUrl,subscriptionContactUrl,termsUrl,privacyUrl);

@override
String toString() {
  return 'PlatformConfig(requestLifetimeHours: $requestLifetimeHours, offerValidityHours: $offerValidityHours, defaultOfferValidityHours: $defaultOfferValidityHours, bullionMinimumAed: $bullionMinimumAed, maxConcurrentLiveRequests: $maxConcurrentLiveRequests, maxOfferRevisions: $maxOfferRevisions, requestExpiryWarningHours: $requestExpiryWarningHours, karatList: $karatList, supportContactUrl: $supportContactUrl, subscriptionContactUrl: $subscriptionContactUrl, termsUrl: $termsUrl, privacyUrl: $privacyUrl)';
}


}

/// @nodoc
abstract mixin class $PlatformConfigCopyWith<$Res>  {
  factory $PlatformConfigCopyWith(PlatformConfig value, $Res Function(PlatformConfig) _then) = _$PlatformConfigCopyWithImpl;
@useResult
$Res call({
 int requestLifetimeHours, List<int> offerValidityHours, int defaultOfferValidityHours, String bullionMinimumAed, int maxConcurrentLiveRequests, int maxOfferRevisions, int requestExpiryWarningHours, List<String> karatList, String supportContactUrl, String subscriptionContactUrl, String termsUrl, String privacyUrl
});




}
/// @nodoc
class _$PlatformConfigCopyWithImpl<$Res>
    implements $PlatformConfigCopyWith<$Res> {
  _$PlatformConfigCopyWithImpl(this._self, this._then);

  final PlatformConfig _self;
  final $Res Function(PlatformConfig) _then;

/// Create a copy of PlatformConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requestLifetimeHours = null,Object? offerValidityHours = null,Object? defaultOfferValidityHours = null,Object? bullionMinimumAed = null,Object? maxConcurrentLiveRequests = null,Object? maxOfferRevisions = null,Object? requestExpiryWarningHours = null,Object? karatList = null,Object? supportContactUrl = null,Object? subscriptionContactUrl = null,Object? termsUrl = null,Object? privacyUrl = null,}) {
  return _then(_self.copyWith(
requestLifetimeHours: null == requestLifetimeHours ? _self.requestLifetimeHours : requestLifetimeHours // ignore: cast_nullable_to_non_nullable
as int,offerValidityHours: null == offerValidityHours ? _self.offerValidityHours : offerValidityHours // ignore: cast_nullable_to_non_nullable
as List<int>,defaultOfferValidityHours: null == defaultOfferValidityHours ? _self.defaultOfferValidityHours : defaultOfferValidityHours // ignore: cast_nullable_to_non_nullable
as int,bullionMinimumAed: null == bullionMinimumAed ? _self.bullionMinimumAed : bullionMinimumAed // ignore: cast_nullable_to_non_nullable
as String,maxConcurrentLiveRequests: null == maxConcurrentLiveRequests ? _self.maxConcurrentLiveRequests : maxConcurrentLiveRequests // ignore: cast_nullable_to_non_nullable
as int,maxOfferRevisions: null == maxOfferRevisions ? _self.maxOfferRevisions : maxOfferRevisions // ignore: cast_nullable_to_non_nullable
as int,requestExpiryWarningHours: null == requestExpiryWarningHours ? _self.requestExpiryWarningHours : requestExpiryWarningHours // ignore: cast_nullable_to_non_nullable
as int,karatList: null == karatList ? _self.karatList : karatList // ignore: cast_nullable_to_non_nullable
as List<String>,supportContactUrl: null == supportContactUrl ? _self.supportContactUrl : supportContactUrl // ignore: cast_nullable_to_non_nullable
as String,subscriptionContactUrl: null == subscriptionContactUrl ? _self.subscriptionContactUrl : subscriptionContactUrl // ignore: cast_nullable_to_non_nullable
as String,termsUrl: null == termsUrl ? _self.termsUrl : termsUrl // ignore: cast_nullable_to_non_nullable
as String,privacyUrl: null == privacyUrl ? _self.privacyUrl : privacyUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PlatformConfig].
extension PlatformConfigPatterns on PlatformConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlatformConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlatformConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlatformConfig value)  $default,){
final _that = this;
switch (_that) {
case _PlatformConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlatformConfig value)?  $default,){
final _that = this;
switch (_that) {
case _PlatformConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int requestLifetimeHours,  List<int> offerValidityHours,  int defaultOfferValidityHours,  String bullionMinimumAed,  int maxConcurrentLiveRequests,  int maxOfferRevisions,  int requestExpiryWarningHours,  List<String> karatList,  String supportContactUrl,  String subscriptionContactUrl,  String termsUrl,  String privacyUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlatformConfig() when $default != null:
return $default(_that.requestLifetimeHours,_that.offerValidityHours,_that.defaultOfferValidityHours,_that.bullionMinimumAed,_that.maxConcurrentLiveRequests,_that.maxOfferRevisions,_that.requestExpiryWarningHours,_that.karatList,_that.supportContactUrl,_that.subscriptionContactUrl,_that.termsUrl,_that.privacyUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int requestLifetimeHours,  List<int> offerValidityHours,  int defaultOfferValidityHours,  String bullionMinimumAed,  int maxConcurrentLiveRequests,  int maxOfferRevisions,  int requestExpiryWarningHours,  List<String> karatList,  String supportContactUrl,  String subscriptionContactUrl,  String termsUrl,  String privacyUrl)  $default,) {final _that = this;
switch (_that) {
case _PlatformConfig():
return $default(_that.requestLifetimeHours,_that.offerValidityHours,_that.defaultOfferValidityHours,_that.bullionMinimumAed,_that.maxConcurrentLiveRequests,_that.maxOfferRevisions,_that.requestExpiryWarningHours,_that.karatList,_that.supportContactUrl,_that.subscriptionContactUrl,_that.termsUrl,_that.privacyUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int requestLifetimeHours,  List<int> offerValidityHours,  int defaultOfferValidityHours,  String bullionMinimumAed,  int maxConcurrentLiveRequests,  int maxOfferRevisions,  int requestExpiryWarningHours,  List<String> karatList,  String supportContactUrl,  String subscriptionContactUrl,  String termsUrl,  String privacyUrl)?  $default,) {final _that = this;
switch (_that) {
case _PlatformConfig() when $default != null:
return $default(_that.requestLifetimeHours,_that.offerValidityHours,_that.defaultOfferValidityHours,_that.bullionMinimumAed,_that.maxConcurrentLiveRequests,_that.maxOfferRevisions,_that.requestExpiryWarningHours,_that.karatList,_that.supportContactUrl,_that.subscriptionContactUrl,_that.termsUrl,_that.privacyUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlatformConfig implements PlatformConfig {
  const _PlatformConfig({this.requestLifetimeHours = 48, final  List<int> offerValidityHours = const [12, 24, 48], this.defaultOfferValidityHours = 24, this.bullionMinimumAed = '5000', this.maxConcurrentLiveRequests = 3, this.maxOfferRevisions = 3, this.requestExpiryWarningHours = 6, final  List<String> karatList = const ['18', '21', '22', '24'], this.supportContactUrl = 'https://karathive.ae/support', this.subscriptionContactUrl = 'https://karathive.ae/subscriptions', this.termsUrl = 'https://karathive.ae/terms', this.privacyUrl = 'https://karathive.ae/privacy'}): _offerValidityHours = offerValidityHours,_karatList = karatList;
  factory _PlatformConfig.fromJson(Map<String, dynamic> json) => _$PlatformConfigFromJson(json);

@override@JsonKey() final  int requestLifetimeHours;
 final  List<int> _offerValidityHours;
@override@JsonKey() List<int> get offerValidityHours {
  if (_offerValidityHours is EqualUnmodifiableListView) return _offerValidityHours;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_offerValidityHours);
}

@override@JsonKey() final  int defaultOfferValidityHours;
@override@JsonKey() final  String bullionMinimumAed;
@override@JsonKey() final  int maxConcurrentLiveRequests;
@override@JsonKey() final  int maxOfferRevisions;
@override@JsonKey() final  int requestExpiryWarningHours;
 final  List<String> _karatList;
@override@JsonKey() List<String> get karatList {
  if (_karatList is EqualUnmodifiableListView) return _karatList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_karatList);
}

@override@JsonKey() final  String supportContactUrl;
@override@JsonKey() final  String subscriptionContactUrl;
@override@JsonKey() final  String termsUrl;
@override@JsonKey() final  String privacyUrl;

/// Create a copy of PlatformConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlatformConfigCopyWith<_PlatformConfig> get copyWith => __$PlatformConfigCopyWithImpl<_PlatformConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlatformConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlatformConfig&&(identical(other.requestLifetimeHours, requestLifetimeHours) || other.requestLifetimeHours == requestLifetimeHours)&&const DeepCollectionEquality().equals(other._offerValidityHours, _offerValidityHours)&&(identical(other.defaultOfferValidityHours, defaultOfferValidityHours) || other.defaultOfferValidityHours == defaultOfferValidityHours)&&(identical(other.bullionMinimumAed, bullionMinimumAed) || other.bullionMinimumAed == bullionMinimumAed)&&(identical(other.maxConcurrentLiveRequests, maxConcurrentLiveRequests) || other.maxConcurrentLiveRequests == maxConcurrentLiveRequests)&&(identical(other.maxOfferRevisions, maxOfferRevisions) || other.maxOfferRevisions == maxOfferRevisions)&&(identical(other.requestExpiryWarningHours, requestExpiryWarningHours) || other.requestExpiryWarningHours == requestExpiryWarningHours)&&const DeepCollectionEquality().equals(other._karatList, _karatList)&&(identical(other.supportContactUrl, supportContactUrl) || other.supportContactUrl == supportContactUrl)&&(identical(other.subscriptionContactUrl, subscriptionContactUrl) || other.subscriptionContactUrl == subscriptionContactUrl)&&(identical(other.termsUrl, termsUrl) || other.termsUrl == termsUrl)&&(identical(other.privacyUrl, privacyUrl) || other.privacyUrl == privacyUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requestLifetimeHours,const DeepCollectionEquality().hash(_offerValidityHours),defaultOfferValidityHours,bullionMinimumAed,maxConcurrentLiveRequests,maxOfferRevisions,requestExpiryWarningHours,const DeepCollectionEquality().hash(_karatList),supportContactUrl,subscriptionContactUrl,termsUrl,privacyUrl);

@override
String toString() {
  return 'PlatformConfig(requestLifetimeHours: $requestLifetimeHours, offerValidityHours: $offerValidityHours, defaultOfferValidityHours: $defaultOfferValidityHours, bullionMinimumAed: $bullionMinimumAed, maxConcurrentLiveRequests: $maxConcurrentLiveRequests, maxOfferRevisions: $maxOfferRevisions, requestExpiryWarningHours: $requestExpiryWarningHours, karatList: $karatList, supportContactUrl: $supportContactUrl, subscriptionContactUrl: $subscriptionContactUrl, termsUrl: $termsUrl, privacyUrl: $privacyUrl)';
}


}

/// @nodoc
abstract mixin class _$PlatformConfigCopyWith<$Res> implements $PlatformConfigCopyWith<$Res> {
  factory _$PlatformConfigCopyWith(_PlatformConfig value, $Res Function(_PlatformConfig) _then) = __$PlatformConfigCopyWithImpl;
@override @useResult
$Res call({
 int requestLifetimeHours, List<int> offerValidityHours, int defaultOfferValidityHours, String bullionMinimumAed, int maxConcurrentLiveRequests, int maxOfferRevisions, int requestExpiryWarningHours, List<String> karatList, String supportContactUrl, String subscriptionContactUrl, String termsUrl, String privacyUrl
});




}
/// @nodoc
class __$PlatformConfigCopyWithImpl<$Res>
    implements _$PlatformConfigCopyWith<$Res> {
  __$PlatformConfigCopyWithImpl(this._self, this._then);

  final _PlatformConfig _self;
  final $Res Function(_PlatformConfig) _then;

/// Create a copy of PlatformConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requestLifetimeHours = null,Object? offerValidityHours = null,Object? defaultOfferValidityHours = null,Object? bullionMinimumAed = null,Object? maxConcurrentLiveRequests = null,Object? maxOfferRevisions = null,Object? requestExpiryWarningHours = null,Object? karatList = null,Object? supportContactUrl = null,Object? subscriptionContactUrl = null,Object? termsUrl = null,Object? privacyUrl = null,}) {
  return _then(_PlatformConfig(
requestLifetimeHours: null == requestLifetimeHours ? _self.requestLifetimeHours : requestLifetimeHours // ignore: cast_nullable_to_non_nullable
as int,offerValidityHours: null == offerValidityHours ? _self._offerValidityHours : offerValidityHours // ignore: cast_nullable_to_non_nullable
as List<int>,defaultOfferValidityHours: null == defaultOfferValidityHours ? _self.defaultOfferValidityHours : defaultOfferValidityHours // ignore: cast_nullable_to_non_nullable
as int,bullionMinimumAed: null == bullionMinimumAed ? _self.bullionMinimumAed : bullionMinimumAed // ignore: cast_nullable_to_non_nullable
as String,maxConcurrentLiveRequests: null == maxConcurrentLiveRequests ? _self.maxConcurrentLiveRequests : maxConcurrentLiveRequests // ignore: cast_nullable_to_non_nullable
as int,maxOfferRevisions: null == maxOfferRevisions ? _self.maxOfferRevisions : maxOfferRevisions // ignore: cast_nullable_to_non_nullable
as int,requestExpiryWarningHours: null == requestExpiryWarningHours ? _self.requestExpiryWarningHours : requestExpiryWarningHours // ignore: cast_nullable_to_non_nullable
as int,karatList: null == karatList ? _self._karatList : karatList // ignore: cast_nullable_to_non_nullable
as List<String>,supportContactUrl: null == supportContactUrl ? _self.supportContactUrl : supportContactUrl // ignore: cast_nullable_to_non_nullable
as String,subscriptionContactUrl: null == subscriptionContactUrl ? _self.subscriptionContactUrl : subscriptionContactUrl // ignore: cast_nullable_to_non_nullable
as String,termsUrl: null == termsUrl ? _self.termsUrl : termsUrl // ignore: cast_nullable_to_non_nullable
as String,privacyUrl: null == privacyUrl ? _self.privacyUrl : privacyUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
