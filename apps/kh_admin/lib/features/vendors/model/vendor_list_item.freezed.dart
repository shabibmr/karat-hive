// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vendor_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VendorListItem _$VendorListItemFromJson(Map<String, dynamic> json) {
  return _VendorListItem.fromJson(json);
}

/// @nodoc
mixin _$VendorListItem {
  String get id => throw _privateConstructorUsedError;
  String get legalBusinessName => throw _privateConstructorUsedError;
  String get tradingName => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: VendorVerificationState.registered)
  VendorVerificationState get verificationState =>
      throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: VendorAccountState.active)
  VendorAccountState get accountState => throw _privateConstructorUsedError;
  String? get tradeLicenceNumber => throw _privateConstructorUsedError;
  String? get region => throw _privateConstructorUsedError;
  int? get offerCount => throw _privateConstructorUsedError;
  double? get acceptanceRate => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;
  @JsonKey(name: 'oldestWaitingHours')
  int? get waitingHours => throw _privateConstructorUsedError;
  @JsonKey(name: 'createdAt')
  DateTime? get registeredAt => throw _privateConstructorUsedError;

  /// Serializes this VendorListItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VendorListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VendorListItemCopyWith<VendorListItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VendorListItemCopyWith<$Res> {
  factory $VendorListItemCopyWith(
    VendorListItem value,
    $Res Function(VendorListItem) then,
  ) = _$VendorListItemCopyWithImpl<$Res, VendorListItem>;
  @useResult
  $Res call({
    String id,
    String legalBusinessName,
    String tradingName,
    @JsonKey(unknownEnumValue: VendorVerificationState.registered)
    VendorVerificationState verificationState,
    @JsonKey(unknownEnumValue: VendorAccountState.active)
    VendorAccountState accountState,
    String? tradeLicenceNumber,
    String? region,
    int? offerCount,
    double? acceptanceRate,
    double? rating,
    @JsonKey(name: 'oldestWaitingHours') int? waitingHours,
    @JsonKey(name: 'createdAt') DateTime? registeredAt,
  });
}

/// @nodoc
class _$VendorListItemCopyWithImpl<$Res, $Val extends VendorListItem>
    implements $VendorListItemCopyWith<$Res> {
  _$VendorListItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VendorListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? legalBusinessName = null,
    Object? tradingName = null,
    Object? verificationState = null,
    Object? accountState = null,
    Object? tradeLicenceNumber = freezed,
    Object? region = freezed,
    Object? offerCount = freezed,
    Object? acceptanceRate = freezed,
    Object? rating = freezed,
    Object? waitingHours = freezed,
    Object? registeredAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            legalBusinessName: null == legalBusinessName
                ? _value.legalBusinessName
                : legalBusinessName // ignore: cast_nullable_to_non_nullable
                      as String,
            tradingName: null == tradingName
                ? _value.tradingName
                : tradingName // ignore: cast_nullable_to_non_nullable
                      as String,
            verificationState: null == verificationState
                ? _value.verificationState
                : verificationState // ignore: cast_nullable_to_non_nullable
                      as VendorVerificationState,
            accountState: null == accountState
                ? _value.accountState
                : accountState // ignore: cast_nullable_to_non_nullable
                      as VendorAccountState,
            tradeLicenceNumber: freezed == tradeLicenceNumber
                ? _value.tradeLicenceNumber
                : tradeLicenceNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            region: freezed == region
                ? _value.region
                : region // ignore: cast_nullable_to_non_nullable
                      as String?,
            offerCount: freezed == offerCount
                ? _value.offerCount
                : offerCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            acceptanceRate: freezed == acceptanceRate
                ? _value.acceptanceRate
                : acceptanceRate // ignore: cast_nullable_to_non_nullable
                      as double?,
            rating: freezed == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double?,
            waitingHours: freezed == waitingHours
                ? _value.waitingHours
                : waitingHours // ignore: cast_nullable_to_non_nullable
                      as int?,
            registeredAt: freezed == registeredAt
                ? _value.registeredAt
                : registeredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VendorListItemImplCopyWith<$Res>
    implements $VendorListItemCopyWith<$Res> {
  factory _$$VendorListItemImplCopyWith(
    _$VendorListItemImpl value,
    $Res Function(_$VendorListItemImpl) then,
  ) = __$$VendorListItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String legalBusinessName,
    String tradingName,
    @JsonKey(unknownEnumValue: VendorVerificationState.registered)
    VendorVerificationState verificationState,
    @JsonKey(unknownEnumValue: VendorAccountState.active)
    VendorAccountState accountState,
    String? tradeLicenceNumber,
    String? region,
    int? offerCount,
    double? acceptanceRate,
    double? rating,
    @JsonKey(name: 'oldestWaitingHours') int? waitingHours,
    @JsonKey(name: 'createdAt') DateTime? registeredAt,
  });
}

/// @nodoc
class __$$VendorListItemImplCopyWithImpl<$Res>
    extends _$VendorListItemCopyWithImpl<$Res, _$VendorListItemImpl>
    implements _$$VendorListItemImplCopyWith<$Res> {
  __$$VendorListItemImplCopyWithImpl(
    _$VendorListItemImpl _value,
    $Res Function(_$VendorListItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VendorListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? legalBusinessName = null,
    Object? tradingName = null,
    Object? verificationState = null,
    Object? accountState = null,
    Object? tradeLicenceNumber = freezed,
    Object? region = freezed,
    Object? offerCount = freezed,
    Object? acceptanceRate = freezed,
    Object? rating = freezed,
    Object? waitingHours = freezed,
    Object? registeredAt = freezed,
  }) {
    return _then(
      _$VendorListItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        legalBusinessName: null == legalBusinessName
            ? _value.legalBusinessName
            : legalBusinessName // ignore: cast_nullable_to_non_nullable
                  as String,
        tradingName: null == tradingName
            ? _value.tradingName
            : tradingName // ignore: cast_nullable_to_non_nullable
                  as String,
        verificationState: null == verificationState
            ? _value.verificationState
            : verificationState // ignore: cast_nullable_to_non_nullable
                  as VendorVerificationState,
        accountState: null == accountState
            ? _value.accountState
            : accountState // ignore: cast_nullable_to_non_nullable
                  as VendorAccountState,
        tradeLicenceNumber: freezed == tradeLicenceNumber
            ? _value.tradeLicenceNumber
            : tradeLicenceNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        region: freezed == region
            ? _value.region
            : region // ignore: cast_nullable_to_non_nullable
                  as String?,
        offerCount: freezed == offerCount
            ? _value.offerCount
            : offerCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        acceptanceRate: freezed == acceptanceRate
            ? _value.acceptanceRate
            : acceptanceRate // ignore: cast_nullable_to_non_nullable
                  as double?,
        rating: freezed == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double?,
        waitingHours: freezed == waitingHours
            ? _value.waitingHours
            : waitingHours // ignore: cast_nullable_to_non_nullable
                  as int?,
        registeredAt: freezed == registeredAt
            ? _value.registeredAt
            : registeredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VendorListItemImpl implements _VendorListItem {
  const _$VendorListItemImpl({
    required this.id,
    required this.legalBusinessName,
    required this.tradingName,
    @JsonKey(unknownEnumValue: VendorVerificationState.registered)
    required this.verificationState,
    @JsonKey(unknownEnumValue: VendorAccountState.active)
    required this.accountState,
    this.tradeLicenceNumber,
    this.region,
    this.offerCount,
    this.acceptanceRate,
    this.rating,
    @JsonKey(name: 'oldestWaitingHours') this.waitingHours,
    @JsonKey(name: 'createdAt') this.registeredAt,
  });

  factory _$VendorListItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$VendorListItemImplFromJson(json);

  @override
  final String id;
  @override
  final String legalBusinessName;
  @override
  final String tradingName;
  @override
  @JsonKey(unknownEnumValue: VendorVerificationState.registered)
  final VendorVerificationState verificationState;
  @override
  @JsonKey(unknownEnumValue: VendorAccountState.active)
  final VendorAccountState accountState;
  @override
  final String? tradeLicenceNumber;
  @override
  final String? region;
  @override
  final int? offerCount;
  @override
  final double? acceptanceRate;
  @override
  final double? rating;
  @override
  @JsonKey(name: 'oldestWaitingHours')
  final int? waitingHours;
  @override
  @JsonKey(name: 'createdAt')
  final DateTime? registeredAt;

  @override
  String toString() {
    return 'VendorListItem(id: $id, legalBusinessName: $legalBusinessName, tradingName: $tradingName, verificationState: $verificationState, accountState: $accountState, tradeLicenceNumber: $tradeLicenceNumber, region: $region, offerCount: $offerCount, acceptanceRate: $acceptanceRate, rating: $rating, waitingHours: $waitingHours, registeredAt: $registeredAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VendorListItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.legalBusinessName, legalBusinessName) ||
                other.legalBusinessName == legalBusinessName) &&
            (identical(other.tradingName, tradingName) ||
                other.tradingName == tradingName) &&
            (identical(other.verificationState, verificationState) ||
                other.verificationState == verificationState) &&
            (identical(other.accountState, accountState) ||
                other.accountState == accountState) &&
            (identical(other.tradeLicenceNumber, tradeLicenceNumber) ||
                other.tradeLicenceNumber == tradeLicenceNumber) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.offerCount, offerCount) ||
                other.offerCount == offerCount) &&
            (identical(other.acceptanceRate, acceptanceRate) ||
                other.acceptanceRate == acceptanceRate) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.waitingHours, waitingHours) ||
                other.waitingHours == waitingHours) &&
            (identical(other.registeredAt, registeredAt) ||
                other.registeredAt == registeredAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    legalBusinessName,
    tradingName,
    verificationState,
    accountState,
    tradeLicenceNumber,
    region,
    offerCount,
    acceptanceRate,
    rating,
    waitingHours,
    registeredAt,
  );

  /// Create a copy of VendorListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VendorListItemImplCopyWith<_$VendorListItemImpl> get copyWith =>
      __$$VendorListItemImplCopyWithImpl<_$VendorListItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VendorListItemImplToJson(this);
  }
}

abstract class _VendorListItem implements VendorListItem {
  const factory _VendorListItem({
    required final String id,
    required final String legalBusinessName,
    required final String tradingName,
    @JsonKey(unknownEnumValue: VendorVerificationState.registered)
    required final VendorVerificationState verificationState,
    @JsonKey(unknownEnumValue: VendorAccountState.active)
    required final VendorAccountState accountState,
    final String? tradeLicenceNumber,
    final String? region,
    final int? offerCount,
    final double? acceptanceRate,
    final double? rating,
    @JsonKey(name: 'oldestWaitingHours') final int? waitingHours,
    @JsonKey(name: 'createdAt') final DateTime? registeredAt,
  }) = _$VendorListItemImpl;

  factory _VendorListItem.fromJson(Map<String, dynamic> json) =
      _$VendorListItemImpl.fromJson;

  @override
  String get id;
  @override
  String get legalBusinessName;
  @override
  String get tradingName;
  @override
  @JsonKey(unknownEnumValue: VendorVerificationState.registered)
  VendorVerificationState get verificationState;
  @override
  @JsonKey(unknownEnumValue: VendorAccountState.active)
  VendorAccountState get accountState;
  @override
  String? get tradeLicenceNumber;
  @override
  String? get region;
  @override
  int? get offerCount;
  @override
  double? get acceptanceRate;
  @override
  double? get rating;
  @override
  @JsonKey(name: 'oldestWaitingHours')
  int? get waitingHours;
  @override
  @JsonKey(name: 'createdAt')
  DateTime? get registeredAt;

  /// Create a copy of VendorListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VendorListItemImplCopyWith<_$VendorListItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
