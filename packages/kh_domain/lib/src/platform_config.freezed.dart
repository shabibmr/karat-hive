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

 int get requestLifetimeHours; List<int> get offerValidityHours; int get defaultOfferValidityHours; String get bullionMinimumAed; int get maxConcurrentLiveRequests; int get maxRequestImages; int get maxOfferImages; int get maxImageBytes; List<String> get acceptedImageTypes; List<String> get karatList; int get maxOfferRevisions; int get requestExpiryWarningHours; String? get termsUrl; String? get privacyUrl; String? get supportContactUrl; String? get subscriptionContactUrl;
/// Create a copy of PlatformConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlatformConfigCopyWith<PlatformConfig> get copyWith => _$PlatformConfigCopyWithImpl<PlatformConfig>(this as PlatformConfig, _$identity);

  /// Serializes this PlatformConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlatformConfig&&(identical(other.requestLifetimeHours, requestLifetimeHours) || other.requestLifetimeHours == requestLifetimeHours)&&const DeepCollectionEquality().equals(other.offerValidityHours, offerValidityHours)&&(identical(other.defaultOfferValidityHours, defaultOfferValidityHours) || other.defaultOfferValidityHours == defaultOfferValidityHours)&&(identical(other.bullionMinimumAed, bullionMinimumAed) || other.bullionMinimumAed == bullionMinimumAed)&&(identical(other.maxConcurrentLiveRequests, maxConcurrentLiveRequests) || other.maxConcurrentLiveRequests == maxConcurrentLiveRequests)&&(identical(other.maxRequestImages, maxRequestImages) || other.maxRequestImages == maxRequestImages)&&(identical(other.maxOfferImages, maxOfferImages) || other.maxOfferImages == maxOfferImages)&&(identical(other.maxImageBytes, maxImageBytes) || other.maxImageBytes == maxImageBytes)&&const DeepCollectionEquality().equals(other.acceptedImageTypes, acceptedImageTypes)&&const DeepCollectionEquality().equals(other.karatList, karatList)&&(identical(other.maxOfferRevisions, maxOfferRevisions) || other.maxOfferRevisions == maxOfferRevisions)&&(identical(other.requestExpiryWarningHours, requestExpiryWarningHours) || other.requestExpiryWarningHours == requestExpiryWarningHours)&&(identical(other.termsUrl, termsUrl) || other.termsUrl == termsUrl)&&(identical(other.privacyUrl, privacyUrl) || other.privacyUrl == privacyUrl)&&(identical(other.supportContactUrl, supportContactUrl) || other.supportContactUrl == supportContactUrl)&&(identical(other.subscriptionContactUrl, subscriptionContactUrl) || other.subscriptionContactUrl == subscriptionContactUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requestLifetimeHours,const DeepCollectionEquality().hash(offerValidityHours),defaultOfferValidityHours,bullionMinimumAed,maxConcurrentLiveRequests,maxRequestImages,maxOfferImages,maxImageBytes,const DeepCollectionEquality().hash(acceptedImageTypes),const DeepCollectionEquality().hash(karatList),maxOfferRevisions,requestExpiryWarningHours,termsUrl,privacyUrl,supportContactUrl,subscriptionContactUrl);

@override
String toString() {
  return 'PlatformConfig(requestLifetimeHours: $requestLifetimeHours, offerValidityHours: $offerValidityHours, defaultOfferValidityHours: $defaultOfferValidityHours, bullionMinimumAed: $bullionMinimumAed, maxConcurrentLiveRequests: $maxConcurrentLiveRequests, maxRequestImages: $maxRequestImages, maxOfferImages: $maxOfferImages, maxImageBytes: $maxImageBytes, acceptedImageTypes: $acceptedImageTypes, karatList: $karatList, maxOfferRevisions: $maxOfferRevisions, requestExpiryWarningHours: $requestExpiryWarningHours, termsUrl: $termsUrl, privacyUrl: $privacyUrl, supportContactUrl: $supportContactUrl, subscriptionContactUrl: $subscriptionContactUrl)';
}


}

/// @nodoc
abstract mixin class $PlatformConfigCopyWith<$Res>  {
  factory $PlatformConfigCopyWith(PlatformConfig value, $Res Function(PlatformConfig) _then) = _$PlatformConfigCopyWithImpl;
@useResult
$Res call({
 int requestLifetimeHours, List<int> offerValidityHours, int defaultOfferValidityHours, String bullionMinimumAed, int maxConcurrentLiveRequests, int maxRequestImages, int maxOfferImages, int maxImageBytes, List<String> acceptedImageTypes, List<String> karatList, int maxOfferRevisions, int requestExpiryWarningHours, String? termsUrl, String? privacyUrl, String? supportContactUrl, String? subscriptionContactUrl
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
@pragma('vm:prefer-inline') @override $Res call({Object? requestLifetimeHours = null,Object? offerValidityHours = null,Object? defaultOfferValidityHours = null,Object? bullionMinimumAed = null,Object? maxConcurrentLiveRequests = null,Object? maxRequestImages = null,Object? maxOfferImages = null,Object? maxImageBytes = null,Object? acceptedImageTypes = null,Object? karatList = null,Object? maxOfferRevisions = null,Object? requestExpiryWarningHours = null,Object? termsUrl = freezed,Object? privacyUrl = freezed,Object? supportContactUrl = freezed,Object? subscriptionContactUrl = freezed,}) {
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
as int,termsUrl: freezed == termsUrl ? _self.termsUrl : termsUrl // ignore: cast_nullable_to_non_nullable
as String?,privacyUrl: freezed == privacyUrl ? _self.privacyUrl : privacyUrl // ignore: cast_nullable_to_non_nullable
as String?,supportContactUrl: freezed == supportContactUrl ? _self.supportContactUrl : supportContactUrl // ignore: cast_nullable_to_non_nullable
as String?,subscriptionContactUrl: freezed == subscriptionContactUrl ? _self.subscriptionContactUrl : subscriptionContactUrl // ignore: cast_nullable_to_non_nullable
as String?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int requestLifetimeHours,  List<int> offerValidityHours,  int defaultOfferValidityHours,  String bullionMinimumAed,  int maxConcurrentLiveRequests,  int maxRequestImages,  int maxOfferImages,  int maxImageBytes,  List<String> acceptedImageTypes,  List<String> karatList,  int maxOfferRevisions,  int requestExpiryWarningHours,  String? termsUrl,  String? privacyUrl,  String? supportContactUrl,  String? subscriptionContactUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlatformConfig() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int requestLifetimeHours,  List<int> offerValidityHours,  int defaultOfferValidityHours,  String bullionMinimumAed,  int maxConcurrentLiveRequests,  int maxRequestImages,  int maxOfferImages,  int maxImageBytes,  List<String> acceptedImageTypes,  List<String> karatList,  int maxOfferRevisions,  int requestExpiryWarningHours,  String? termsUrl,  String? privacyUrl,  String? supportContactUrl,  String? subscriptionContactUrl)  $default,) {final _that = this;
switch (_that) {
case _PlatformConfig():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int requestLifetimeHours,  List<int> offerValidityHours,  int defaultOfferValidityHours,  String bullionMinimumAed,  int maxConcurrentLiveRequests,  int maxRequestImages,  int maxOfferImages,  int maxImageBytes,  List<String> acceptedImageTypes,  List<String> karatList,  int maxOfferRevisions,  int requestExpiryWarningHours,  String? termsUrl,  String? privacyUrl,  String? supportContactUrl,  String? subscriptionContactUrl)?  $default,) {final _that = this;
switch (_that) {
case _PlatformConfig() when $default != null:
return $default(_that.requestLifetimeHours,_that.offerValidityHours,_that.defaultOfferValidityHours,_that.bullionMinimumAed,_that.maxConcurrentLiveRequests,_that.maxRequestImages,_that.maxOfferImages,_that.maxImageBytes,_that.acceptedImageTypes,_that.karatList,_that.maxOfferRevisions,_that.requestExpiryWarningHours,_that.termsUrl,_that.privacyUrl,_that.supportContactUrl,_that.subscriptionContactUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlatformConfig implements PlatformConfig {
  const _PlatformConfig({this.requestLifetimeHours = 48, final  List<int> offerValidityHours = const [12, 24, 48], this.defaultOfferValidityHours = 24, this.bullionMinimumAed = '5000', this.maxConcurrentLiveRequests = 3, this.maxRequestImages = 5, this.maxOfferImages = 3, this.maxImageBytes = 0, final  List<String> acceptedImageTypes = const ['image/jpeg', 'image/png', 'image/webp'], final  List<String> karatList = const ['18', '21', '22', '24'], this.maxOfferRevisions = 3, this.requestExpiryWarningHours = 6, this.termsUrl, this.privacyUrl, this.supportContactUrl, this.subscriptionContactUrl}): _offerValidityHours = offerValidityHours,_acceptedImageTypes = acceptedImageTypes,_karatList = karatList;
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
@override@JsonKey() final  int maxRequestImages;
@override@JsonKey() final  int maxOfferImages;
@override@JsonKey() final  int maxImageBytes;
 final  List<String> _acceptedImageTypes;
@override@JsonKey() List<String> get acceptedImageTypes {
  if (_acceptedImageTypes is EqualUnmodifiableListView) return _acceptedImageTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_acceptedImageTypes);
}

 final  List<String> _karatList;
@override@JsonKey() List<String> get karatList {
  if (_karatList is EqualUnmodifiableListView) return _karatList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_karatList);
}

@override@JsonKey() final  int maxOfferRevisions;
@override@JsonKey() final  int requestExpiryWarningHours;
@override final  String? termsUrl;
@override final  String? privacyUrl;
@override final  String? supportContactUrl;
@override final  String? subscriptionContactUrl;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlatformConfig&&(identical(other.requestLifetimeHours, requestLifetimeHours) || other.requestLifetimeHours == requestLifetimeHours)&&const DeepCollectionEquality().equals(other._offerValidityHours, _offerValidityHours)&&(identical(other.defaultOfferValidityHours, defaultOfferValidityHours) || other.defaultOfferValidityHours == defaultOfferValidityHours)&&(identical(other.bullionMinimumAed, bullionMinimumAed) || other.bullionMinimumAed == bullionMinimumAed)&&(identical(other.maxConcurrentLiveRequests, maxConcurrentLiveRequests) || other.maxConcurrentLiveRequests == maxConcurrentLiveRequests)&&(identical(other.maxRequestImages, maxRequestImages) || other.maxRequestImages == maxRequestImages)&&(identical(other.maxOfferImages, maxOfferImages) || other.maxOfferImages == maxOfferImages)&&(identical(other.maxImageBytes, maxImageBytes) || other.maxImageBytes == maxImageBytes)&&const DeepCollectionEquality().equals(other._acceptedImageTypes, _acceptedImageTypes)&&const DeepCollectionEquality().equals(other._karatList, _karatList)&&(identical(other.maxOfferRevisions, maxOfferRevisions) || other.maxOfferRevisions == maxOfferRevisions)&&(identical(other.requestExpiryWarningHours, requestExpiryWarningHours) || other.requestExpiryWarningHours == requestExpiryWarningHours)&&(identical(other.termsUrl, termsUrl) || other.termsUrl == termsUrl)&&(identical(other.privacyUrl, privacyUrl) || other.privacyUrl == privacyUrl)&&(identical(other.supportContactUrl, supportContactUrl) || other.supportContactUrl == supportContactUrl)&&(identical(other.subscriptionContactUrl, subscriptionContactUrl) || other.subscriptionContactUrl == subscriptionContactUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requestLifetimeHours,const DeepCollectionEquality().hash(_offerValidityHours),defaultOfferValidityHours,bullionMinimumAed,maxConcurrentLiveRequests,maxRequestImages,maxOfferImages,maxImageBytes,const DeepCollectionEquality().hash(_acceptedImageTypes),const DeepCollectionEquality().hash(_karatList),maxOfferRevisions,requestExpiryWarningHours,termsUrl,privacyUrl,supportContactUrl,subscriptionContactUrl);

@override
String toString() {
  return 'PlatformConfig(requestLifetimeHours: $requestLifetimeHours, offerValidityHours: $offerValidityHours, defaultOfferValidityHours: $defaultOfferValidityHours, bullionMinimumAed: $bullionMinimumAed, maxConcurrentLiveRequests: $maxConcurrentLiveRequests, maxRequestImages: $maxRequestImages, maxOfferImages: $maxOfferImages, maxImageBytes: $maxImageBytes, acceptedImageTypes: $acceptedImageTypes, karatList: $karatList, maxOfferRevisions: $maxOfferRevisions, requestExpiryWarningHours: $requestExpiryWarningHours, termsUrl: $termsUrl, privacyUrl: $privacyUrl, supportContactUrl: $supportContactUrl, subscriptionContactUrl: $subscriptionContactUrl)';
}


}

/// @nodoc
abstract mixin class _$PlatformConfigCopyWith<$Res> implements $PlatformConfigCopyWith<$Res> {
  factory _$PlatformConfigCopyWith(_PlatformConfig value, $Res Function(_PlatformConfig) _then) = __$PlatformConfigCopyWithImpl;
@override @useResult
$Res call({
 int requestLifetimeHours, List<int> offerValidityHours, int defaultOfferValidityHours, String bullionMinimumAed, int maxConcurrentLiveRequests, int maxRequestImages, int maxOfferImages, int maxImageBytes, List<String> acceptedImageTypes, List<String> karatList, int maxOfferRevisions, int requestExpiryWarningHours, String? termsUrl, String? privacyUrl, String? supportContactUrl, String? subscriptionContactUrl
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
@override @pragma('vm:prefer-inline') $Res call({Object? requestLifetimeHours = null,Object? offerValidityHours = null,Object? defaultOfferValidityHours = null,Object? bullionMinimumAed = null,Object? maxConcurrentLiveRequests = null,Object? maxRequestImages = null,Object? maxOfferImages = null,Object? maxImageBytes = null,Object? acceptedImageTypes = null,Object? karatList = null,Object? maxOfferRevisions = null,Object? requestExpiryWarningHours = null,Object? termsUrl = freezed,Object? privacyUrl = freezed,Object? supportContactUrl = freezed,Object? subscriptionContactUrl = freezed,}) {
  return _then(_PlatformConfig(
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
as int,termsUrl: freezed == termsUrl ? _self.termsUrl : termsUrl // ignore: cast_nullable_to_non_nullable
as String?,privacyUrl: freezed == privacyUrl ? _self.privacyUrl : privacyUrl // ignore: cast_nullable_to_non_nullable
as String?,supportContactUrl: freezed == supportContactUrl ? _self.supportContactUrl : supportContactUrl // ignore: cast_nullable_to_non_nullable
as String?,subscriptionContactUrl: freezed == subscriptionContactUrl ? _self.subscriptionContactUrl : subscriptionContactUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
