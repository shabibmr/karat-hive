// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vendor_dashboard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VendorDashboard {

 int get newRequests; List<VendorRequestItem> get newRequestPreview; int get pendingOffers; int get pendingOffersExpiringWithin24h; int get activeConnections; int get activeConnectionsNoTalkCount; double? get ratingAverage; int get reviewCount; Object? get goldRates; List<VendorSubscriptionItem> get subscriptions;
/// Create a copy of VendorDashboard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorDashboardCopyWith<VendorDashboard> get copyWith => _$VendorDashboardCopyWithImpl<VendorDashboard>(this as VendorDashboard, _$identity);

  /// Serializes this VendorDashboard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorDashboard&&(identical(other.newRequests, newRequests) || other.newRequests == newRequests)&&const DeepCollectionEquality().equals(other.newRequestPreview, newRequestPreview)&&(identical(other.pendingOffers, pendingOffers) || other.pendingOffers == pendingOffers)&&(identical(other.pendingOffersExpiringWithin24h, pendingOffersExpiringWithin24h) || other.pendingOffersExpiringWithin24h == pendingOffersExpiringWithin24h)&&(identical(other.activeConnections, activeConnections) || other.activeConnections == activeConnections)&&(identical(other.activeConnectionsNoTalkCount, activeConnectionsNoTalkCount) || other.activeConnectionsNoTalkCount == activeConnectionsNoTalkCount)&&(identical(other.ratingAverage, ratingAverage) || other.ratingAverage == ratingAverage)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&const DeepCollectionEquality().equals(other.goldRates, goldRates)&&const DeepCollectionEquality().equals(other.subscriptions, subscriptions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,newRequests,const DeepCollectionEquality().hash(newRequestPreview),pendingOffers,pendingOffersExpiringWithin24h,activeConnections,activeConnectionsNoTalkCount,ratingAverage,reviewCount,const DeepCollectionEquality().hash(goldRates),const DeepCollectionEquality().hash(subscriptions));

@override
String toString() {
  return 'VendorDashboard(newRequests: $newRequests, newRequestPreview: $newRequestPreview, pendingOffers: $pendingOffers, pendingOffersExpiringWithin24h: $pendingOffersExpiringWithin24h, activeConnections: $activeConnections, activeConnectionsNoTalkCount: $activeConnectionsNoTalkCount, ratingAverage: $ratingAverage, reviewCount: $reviewCount, goldRates: $goldRates, subscriptions: $subscriptions)';
}


}

/// @nodoc
abstract mixin class $VendorDashboardCopyWith<$Res>  {
  factory $VendorDashboardCopyWith(VendorDashboard value, $Res Function(VendorDashboard) _then) = _$VendorDashboardCopyWithImpl;
@useResult
$Res call({
 int newRequests, List<VendorRequestItem> newRequestPreview, int pendingOffers, int pendingOffersExpiringWithin24h, int activeConnections, int activeConnectionsNoTalkCount, double? ratingAverage, int reviewCount, Object? goldRates, List<VendorSubscriptionItem> subscriptions
});




}
/// @nodoc
class _$VendorDashboardCopyWithImpl<$Res>
    implements $VendorDashboardCopyWith<$Res> {
  _$VendorDashboardCopyWithImpl(this._self, this._then);

  final VendorDashboard _self;
  final $Res Function(VendorDashboard) _then;

/// Create a copy of VendorDashboard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? newRequests = null,Object? newRequestPreview = null,Object? pendingOffers = null,Object? pendingOffersExpiringWithin24h = null,Object? activeConnections = null,Object? activeConnectionsNoTalkCount = null,Object? ratingAverage = freezed,Object? reviewCount = null,Object? goldRates = freezed,Object? subscriptions = null,}) {
  return _then(_self.copyWith(
newRequests: null == newRequests ? _self.newRequests : newRequests // ignore: cast_nullable_to_non_nullable
as int,newRequestPreview: null == newRequestPreview ? _self.newRequestPreview : newRequestPreview // ignore: cast_nullable_to_non_nullable
as List<VendorRequestItem>,pendingOffers: null == pendingOffers ? _self.pendingOffers : pendingOffers // ignore: cast_nullable_to_non_nullable
as int,pendingOffersExpiringWithin24h: null == pendingOffersExpiringWithin24h ? _self.pendingOffersExpiringWithin24h : pendingOffersExpiringWithin24h // ignore: cast_nullable_to_non_nullable
as int,activeConnections: null == activeConnections ? _self.activeConnections : activeConnections // ignore: cast_nullable_to_non_nullable
as int,activeConnectionsNoTalkCount: null == activeConnectionsNoTalkCount ? _self.activeConnectionsNoTalkCount : activeConnectionsNoTalkCount // ignore: cast_nullable_to_non_nullable
as int,ratingAverage: freezed == ratingAverage ? _self.ratingAverage : ratingAverage // ignore: cast_nullable_to_non_nullable
as double?,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,goldRates: freezed == goldRates ? _self.goldRates : goldRates ,subscriptions: null == subscriptions ? _self.subscriptions : subscriptions // ignore: cast_nullable_to_non_nullable
as List<VendorSubscriptionItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [VendorDashboard].
extension VendorDashboardPatterns on VendorDashboard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorDashboard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorDashboard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorDashboard value)  $default,){
final _that = this;
switch (_that) {
case _VendorDashboard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorDashboard value)?  $default,){
final _that = this;
switch (_that) {
case _VendorDashboard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int newRequests,  List<VendorRequestItem> newRequestPreview,  int pendingOffers,  int pendingOffersExpiringWithin24h,  int activeConnections,  int activeConnectionsNoTalkCount,  double? ratingAverage,  int reviewCount,  Object? goldRates,  List<VendorSubscriptionItem> subscriptions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorDashboard() when $default != null:
return $default(_that.newRequests,_that.newRequestPreview,_that.pendingOffers,_that.pendingOffersExpiringWithin24h,_that.activeConnections,_that.activeConnectionsNoTalkCount,_that.ratingAverage,_that.reviewCount,_that.goldRates,_that.subscriptions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int newRequests,  List<VendorRequestItem> newRequestPreview,  int pendingOffers,  int pendingOffersExpiringWithin24h,  int activeConnections,  int activeConnectionsNoTalkCount,  double? ratingAverage,  int reviewCount,  Object? goldRates,  List<VendorSubscriptionItem> subscriptions)  $default,) {final _that = this;
switch (_that) {
case _VendorDashboard():
return $default(_that.newRequests,_that.newRequestPreview,_that.pendingOffers,_that.pendingOffersExpiringWithin24h,_that.activeConnections,_that.activeConnectionsNoTalkCount,_that.ratingAverage,_that.reviewCount,_that.goldRates,_that.subscriptions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int newRequests,  List<VendorRequestItem> newRequestPreview,  int pendingOffers,  int pendingOffersExpiringWithin24h,  int activeConnections,  int activeConnectionsNoTalkCount,  double? ratingAverage,  int reviewCount,  Object? goldRates,  List<VendorSubscriptionItem> subscriptions)?  $default,) {final _that = this;
switch (_that) {
case _VendorDashboard() when $default != null:
return $default(_that.newRequests,_that.newRequestPreview,_that.pendingOffers,_that.pendingOffersExpiringWithin24h,_that.activeConnections,_that.activeConnectionsNoTalkCount,_that.ratingAverage,_that.reviewCount,_that.goldRates,_that.subscriptions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VendorDashboard implements VendorDashboard {
  const _VendorDashboard({required this.newRequests, final  List<VendorRequestItem> newRequestPreview = const <VendorRequestItem>[], required this.pendingOffers, this.pendingOffersExpiringWithin24h = 0, required this.activeConnections, this.activeConnectionsNoTalkCount = 0, this.ratingAverage, required this.reviewCount, this.goldRates, final  List<VendorSubscriptionItem> subscriptions = const <VendorSubscriptionItem>[]}): _newRequestPreview = newRequestPreview,_subscriptions = subscriptions;
  factory _VendorDashboard.fromJson(Map<String, dynamic> json) => _$VendorDashboardFromJson(json);

@override final  int newRequests;
 final  List<VendorRequestItem> _newRequestPreview;
@override@JsonKey() List<VendorRequestItem> get newRequestPreview {
  if (_newRequestPreview is EqualUnmodifiableListView) return _newRequestPreview;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_newRequestPreview);
}

@override final  int pendingOffers;
@override@JsonKey() final  int pendingOffersExpiringWithin24h;
@override final  int activeConnections;
@override@JsonKey() final  int activeConnectionsNoTalkCount;
@override final  double? ratingAverage;
@override final  int reviewCount;
@override final  Object? goldRates;
 final  List<VendorSubscriptionItem> _subscriptions;
@override@JsonKey() List<VendorSubscriptionItem> get subscriptions {
  if (_subscriptions is EqualUnmodifiableListView) return _subscriptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subscriptions);
}


/// Create a copy of VendorDashboard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorDashboardCopyWith<_VendorDashboard> get copyWith => __$VendorDashboardCopyWithImpl<_VendorDashboard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VendorDashboardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorDashboard&&(identical(other.newRequests, newRequests) || other.newRequests == newRequests)&&const DeepCollectionEquality().equals(other._newRequestPreview, _newRequestPreview)&&(identical(other.pendingOffers, pendingOffers) || other.pendingOffers == pendingOffers)&&(identical(other.pendingOffersExpiringWithin24h, pendingOffersExpiringWithin24h) || other.pendingOffersExpiringWithin24h == pendingOffersExpiringWithin24h)&&(identical(other.activeConnections, activeConnections) || other.activeConnections == activeConnections)&&(identical(other.activeConnectionsNoTalkCount, activeConnectionsNoTalkCount) || other.activeConnectionsNoTalkCount == activeConnectionsNoTalkCount)&&(identical(other.ratingAverage, ratingAverage) || other.ratingAverage == ratingAverage)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&const DeepCollectionEquality().equals(other.goldRates, goldRates)&&const DeepCollectionEquality().equals(other._subscriptions, _subscriptions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,newRequests,const DeepCollectionEquality().hash(_newRequestPreview),pendingOffers,pendingOffersExpiringWithin24h,activeConnections,activeConnectionsNoTalkCount,ratingAverage,reviewCount,const DeepCollectionEquality().hash(goldRates),const DeepCollectionEquality().hash(_subscriptions));

@override
String toString() {
  return 'VendorDashboard(newRequests: $newRequests, newRequestPreview: $newRequestPreview, pendingOffers: $pendingOffers, pendingOffersExpiringWithin24h: $pendingOffersExpiringWithin24h, activeConnections: $activeConnections, activeConnectionsNoTalkCount: $activeConnectionsNoTalkCount, ratingAverage: $ratingAverage, reviewCount: $reviewCount, goldRates: $goldRates, subscriptions: $subscriptions)';
}


}

/// @nodoc
abstract mixin class _$VendorDashboardCopyWith<$Res> implements $VendorDashboardCopyWith<$Res> {
  factory _$VendorDashboardCopyWith(_VendorDashboard value, $Res Function(_VendorDashboard) _then) = __$VendorDashboardCopyWithImpl;
@override @useResult
$Res call({
 int newRequests, List<VendorRequestItem> newRequestPreview, int pendingOffers, int pendingOffersExpiringWithin24h, int activeConnections, int activeConnectionsNoTalkCount, double? ratingAverage, int reviewCount, Object? goldRates, List<VendorSubscriptionItem> subscriptions
});




}
/// @nodoc
class __$VendorDashboardCopyWithImpl<$Res>
    implements _$VendorDashboardCopyWith<$Res> {
  __$VendorDashboardCopyWithImpl(this._self, this._then);

  final _VendorDashboard _self;
  final $Res Function(_VendorDashboard) _then;

/// Create a copy of VendorDashboard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? newRequests = null,Object? newRequestPreview = null,Object? pendingOffers = null,Object? pendingOffersExpiringWithin24h = null,Object? activeConnections = null,Object? activeConnectionsNoTalkCount = null,Object? ratingAverage = freezed,Object? reviewCount = null,Object? goldRates = freezed,Object? subscriptions = null,}) {
  return _then(_VendorDashboard(
newRequests: null == newRequests ? _self.newRequests : newRequests // ignore: cast_nullable_to_non_nullable
as int,newRequestPreview: null == newRequestPreview ? _self._newRequestPreview : newRequestPreview // ignore: cast_nullable_to_non_nullable
as List<VendorRequestItem>,pendingOffers: null == pendingOffers ? _self.pendingOffers : pendingOffers // ignore: cast_nullable_to_non_nullable
as int,pendingOffersExpiringWithin24h: null == pendingOffersExpiringWithin24h ? _self.pendingOffersExpiringWithin24h : pendingOffersExpiringWithin24h // ignore: cast_nullable_to_non_nullable
as int,activeConnections: null == activeConnections ? _self.activeConnections : activeConnections // ignore: cast_nullable_to_non_nullable
as int,activeConnectionsNoTalkCount: null == activeConnectionsNoTalkCount ? _self.activeConnectionsNoTalkCount : activeConnectionsNoTalkCount // ignore: cast_nullable_to_non_nullable
as int,ratingAverage: freezed == ratingAverage ? _self.ratingAverage : ratingAverage // ignore: cast_nullable_to_non_nullable
as double?,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,goldRates: freezed == goldRates ? _self.goldRates : goldRates ,subscriptions: null == subscriptions ? _self._subscriptions : subscriptions // ignore: cast_nullable_to_non_nullable
as List<VendorSubscriptionItem>,
  ));
}


}

// dart format on
