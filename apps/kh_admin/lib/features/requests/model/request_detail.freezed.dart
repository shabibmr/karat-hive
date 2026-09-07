// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CustomerProfileSummary _$CustomerProfileSummaryFromJson(
  Map<String, dynamic> json,
) {
  return _CustomerProfileSummary.fromJson(json);
}

/// @nodoc
mixin _$CustomerProfileSummary {
  String get id => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get mobileNumber => throw _privateConstructorUsedError;
  String get accountState => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CustomerProfileSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerProfileSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerProfileSummaryCopyWith<CustomerProfileSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerProfileSummaryCopyWith<$Res> {
  factory $CustomerProfileSummaryCopyWith(
    CustomerProfileSummary value,
    $Res Function(CustomerProfileSummary) then,
  ) = _$CustomerProfileSummaryCopyWithImpl<$Res, CustomerProfileSummary>;
  @useResult
  $Res call({
    String id,
    String fullName,
    String? email,
    String? mobileNumber,
    String accountState,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$CustomerProfileSummaryCopyWithImpl<
  $Res,
  $Val extends CustomerProfileSummary
>
    implements $CustomerProfileSummaryCopyWith<$Res> {
  _$CustomerProfileSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerProfileSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? email = freezed,
    Object? mobileNumber = freezed,
    Object? accountState = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            mobileNumber: freezed == mobileNumber
                ? _value.mobileNumber
                : mobileNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            accountState: null == accountState
                ? _value.accountState
                : accountState // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomerProfileSummaryImplCopyWith<$Res>
    implements $CustomerProfileSummaryCopyWith<$Res> {
  factory _$$CustomerProfileSummaryImplCopyWith(
    _$CustomerProfileSummaryImpl value,
    $Res Function(_$CustomerProfileSummaryImpl) then,
  ) = __$$CustomerProfileSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String fullName,
    String? email,
    String? mobileNumber,
    String accountState,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$CustomerProfileSummaryImplCopyWithImpl<$Res>
    extends
        _$CustomerProfileSummaryCopyWithImpl<$Res, _$CustomerProfileSummaryImpl>
    implements _$$CustomerProfileSummaryImplCopyWith<$Res> {
  __$$CustomerProfileSummaryImplCopyWithImpl(
    _$CustomerProfileSummaryImpl _value,
    $Res Function(_$CustomerProfileSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerProfileSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? email = freezed,
    Object? mobileNumber = freezed,
    Object? accountState = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$CustomerProfileSummaryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        mobileNumber: freezed == mobileNumber
            ? _value.mobileNumber
            : mobileNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        accountState: null == accountState
            ? _value.accountState
            : accountState // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerProfileSummaryImpl implements _CustomerProfileSummary {
  const _$CustomerProfileSummaryImpl({
    required this.id,
    required this.fullName,
    this.email,
    this.mobileNumber,
    this.accountState = 'ACTIVE',
    this.createdAt,
  });

  factory _$CustomerProfileSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerProfileSummaryImplFromJson(json);

  @override
  final String id;
  @override
  final String fullName;
  @override
  final String? email;
  @override
  final String? mobileNumber;
  @override
  @JsonKey()
  final String accountState;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'CustomerProfileSummary(id: $id, fullName: $fullName, email: $email, mobileNumber: $mobileNumber, accountState: $accountState, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerProfileSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.mobileNumber, mobileNumber) ||
                other.mobileNumber == mobileNumber) &&
            (identical(other.accountState, accountState) ||
                other.accountState == accountState) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    fullName,
    email,
    mobileNumber,
    accountState,
    createdAt,
  );

  /// Create a copy of CustomerProfileSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerProfileSummaryImplCopyWith<_$CustomerProfileSummaryImpl>
  get copyWith =>
      __$$CustomerProfileSummaryImplCopyWithImpl<_$CustomerProfileSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerProfileSummaryImplToJson(this);
  }
}

abstract class _CustomerProfileSummary implements CustomerProfileSummary {
  const factory _CustomerProfileSummary({
    required final String id,
    required final String fullName,
    final String? email,
    final String? mobileNumber,
    final String accountState,
    final DateTime? createdAt,
  }) = _$CustomerProfileSummaryImpl;

  factory _CustomerProfileSummary.fromJson(Map<String, dynamic> json) =
      _$CustomerProfileSummaryImpl.fromJson;

  @override
  String get id;
  @override
  String get fullName;
  @override
  String? get email;
  @override
  String? get mobileNumber;
  @override
  String get accountState;
  @override
  DateTime? get createdAt;

  /// Create a copy of CustomerProfileSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerProfileSummaryImplCopyWith<_$CustomerProfileSummaryImpl>
  get copyWith => throw _privateConstructorUsedError;
}

RequestMediaItem _$RequestMediaItemFromJson(Map<String, dynamic> json) {
  return _RequestMediaItem.fromJson(json);
}

/// @nodoc
mixin _$RequestMediaItem {
  String get id => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  String? get fileName => throw _privateConstructorUsedError;
  String? get mimeType => throw _privateConstructorUsedError;
  int? get sizeBytes => throw _privateConstructorUsedError;
  int get displayOrder => throw _privateConstructorUsedError;

  /// Serializes this RequestMediaItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RequestMediaItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RequestMediaItemCopyWith<RequestMediaItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequestMediaItemCopyWith<$Res> {
  factory $RequestMediaItemCopyWith(
    RequestMediaItem value,
    $Res Function(RequestMediaItem) then,
  ) = _$RequestMediaItemCopyWithImpl<$Res, RequestMediaItem>;
  @useResult
  $Res call({
    String id,
    String url,
    String? thumbnailUrl,
    String? fileName,
    String? mimeType,
    int? sizeBytes,
    int displayOrder,
  });
}

/// @nodoc
class _$RequestMediaItemCopyWithImpl<$Res, $Val extends RequestMediaItem>
    implements $RequestMediaItemCopyWith<$Res> {
  _$RequestMediaItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RequestMediaItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? thumbnailUrl = freezed,
    Object? fileName = freezed,
    Object? mimeType = freezed,
    Object? sizeBytes = freezed,
    Object? displayOrder = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            thumbnailUrl: freezed == thumbnailUrl
                ? _value.thumbnailUrl
                : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            fileName: freezed == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                      as String?,
            mimeType: freezed == mimeType
                ? _value.mimeType
                : mimeType // ignore: cast_nullable_to_non_nullable
                      as String?,
            sizeBytes: freezed == sizeBytes
                ? _value.sizeBytes
                : sizeBytes // ignore: cast_nullable_to_non_nullable
                      as int?,
            displayOrder: null == displayOrder
                ? _value.displayOrder
                : displayOrder // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RequestMediaItemImplCopyWith<$Res>
    implements $RequestMediaItemCopyWith<$Res> {
  factory _$$RequestMediaItemImplCopyWith(
    _$RequestMediaItemImpl value,
    $Res Function(_$RequestMediaItemImpl) then,
  ) = __$$RequestMediaItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String url,
    String? thumbnailUrl,
    String? fileName,
    String? mimeType,
    int? sizeBytes,
    int displayOrder,
  });
}

/// @nodoc
class __$$RequestMediaItemImplCopyWithImpl<$Res>
    extends _$RequestMediaItemCopyWithImpl<$Res, _$RequestMediaItemImpl>
    implements _$$RequestMediaItemImplCopyWith<$Res> {
  __$$RequestMediaItemImplCopyWithImpl(
    _$RequestMediaItemImpl _value,
    $Res Function(_$RequestMediaItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RequestMediaItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? thumbnailUrl = freezed,
    Object? fileName = freezed,
    Object? mimeType = freezed,
    Object? sizeBytes = freezed,
    Object? displayOrder = null,
  }) {
    return _then(
      _$RequestMediaItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        thumbnailUrl: freezed == thumbnailUrl
            ? _value.thumbnailUrl
            : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileName: freezed == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String?,
        mimeType: freezed == mimeType
            ? _value.mimeType
            : mimeType // ignore: cast_nullable_to_non_nullable
                  as String?,
        sizeBytes: freezed == sizeBytes
            ? _value.sizeBytes
            : sizeBytes // ignore: cast_nullable_to_non_nullable
                  as int?,
        displayOrder: null == displayOrder
            ? _value.displayOrder
            : displayOrder // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RequestMediaItemImpl implements _RequestMediaItem {
  const _$RequestMediaItemImpl({
    required this.id,
    required this.url,
    this.thumbnailUrl,
    this.fileName,
    this.mimeType,
    this.sizeBytes,
    this.displayOrder = 0,
  });

  factory _$RequestMediaItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$RequestMediaItemImplFromJson(json);

  @override
  final String id;
  @override
  final String url;
  @override
  final String? thumbnailUrl;
  @override
  final String? fileName;
  @override
  final String? mimeType;
  @override
  final int? sizeBytes;
  @override
  @JsonKey()
  final int displayOrder;

  @override
  String toString() {
    return 'RequestMediaItem(id: $id, url: $url, thumbnailUrl: $thumbnailUrl, fileName: $fileName, mimeType: $mimeType, sizeBytes: $sizeBytes, displayOrder: $displayOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RequestMediaItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.sizeBytes, sizeBytes) ||
                other.sizeBytes == sizeBytes) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    url,
    thumbnailUrl,
    fileName,
    mimeType,
    sizeBytes,
    displayOrder,
  );

  /// Create a copy of RequestMediaItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RequestMediaItemImplCopyWith<_$RequestMediaItemImpl> get copyWith =>
      __$$RequestMediaItemImplCopyWithImpl<_$RequestMediaItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RequestMediaItemImplToJson(this);
  }
}

abstract class _RequestMediaItem implements RequestMediaItem {
  const factory _RequestMediaItem({
    required final String id,
    required final String url,
    final String? thumbnailUrl,
    final String? fileName,
    final String? mimeType,
    final int? sizeBytes,
    final int displayOrder,
  }) = _$RequestMediaItemImpl;

  factory _RequestMediaItem.fromJson(Map<String, dynamic> json) =
      _$RequestMediaItemImpl.fromJson;

  @override
  String get id;
  @override
  String get url;
  @override
  String? get thumbnailUrl;
  @override
  String? get fileName;
  @override
  String? get mimeType;
  @override
  int? get sizeBytes;
  @override
  int get displayOrder;

  /// Create a copy of RequestMediaItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RequestMediaItemImplCopyWith<_$RequestMediaItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchedVendorItem _$MatchedVendorItemFromJson(Map<String, dynamic> json) {
  return _MatchedVendorItem.fromJson(json);
}

/// @nodoc
mixin _$MatchedVendorItem {
  String get vendorId => throw _privateConstructorUsedError;
  String get businessName => throw _privateConstructorUsedError;
  String? get tradingName => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;
  bool get isEligible => throw _privateConstructorUsedError;
  DateTime get matchedAt => throw _privateConstructorUsedError;
  DateTime? get viewedAt => throw _privateConstructorUsedError;

  /// Serializes this MatchedVendorItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchedVendorItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchedVendorItemCopyWith<MatchedVendorItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchedVendorItemCopyWith<$Res> {
  factory $MatchedVendorItemCopyWith(
    MatchedVendorItem value,
    $Res Function(MatchedVendorItem) then,
  ) = _$MatchedVendorItemCopyWithImpl<$Res, MatchedVendorItem>;
  @useResult
  $Res call({
    String vendorId,
    String businessName,
    String? tradingName,
    double? rating,
    bool isEligible,
    DateTime matchedAt,
    DateTime? viewedAt,
  });
}

/// @nodoc
class _$MatchedVendorItemCopyWithImpl<$Res, $Val extends MatchedVendorItem>
    implements $MatchedVendorItemCopyWith<$Res> {
  _$MatchedVendorItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchedVendorItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vendorId = null,
    Object? businessName = null,
    Object? tradingName = freezed,
    Object? rating = freezed,
    Object? isEligible = null,
    Object? matchedAt = null,
    Object? viewedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            vendorId: null == vendorId
                ? _value.vendorId
                : vendorId // ignore: cast_nullable_to_non_nullable
                      as String,
            businessName: null == businessName
                ? _value.businessName
                : businessName // ignore: cast_nullable_to_non_nullable
                      as String,
            tradingName: freezed == tradingName
                ? _value.tradingName
                : tradingName // ignore: cast_nullable_to_non_nullable
                      as String?,
            rating: freezed == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double?,
            isEligible: null == isEligible
                ? _value.isEligible
                : isEligible // ignore: cast_nullable_to_non_nullable
                      as bool,
            matchedAt: null == matchedAt
                ? _value.matchedAt
                : matchedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            viewedAt: freezed == viewedAt
                ? _value.viewedAt
                : viewedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchedVendorItemImplCopyWith<$Res>
    implements $MatchedVendorItemCopyWith<$Res> {
  factory _$$MatchedVendorItemImplCopyWith(
    _$MatchedVendorItemImpl value,
    $Res Function(_$MatchedVendorItemImpl) then,
  ) = __$$MatchedVendorItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String vendorId,
    String businessName,
    String? tradingName,
    double? rating,
    bool isEligible,
    DateTime matchedAt,
    DateTime? viewedAt,
  });
}

/// @nodoc
class __$$MatchedVendorItemImplCopyWithImpl<$Res>
    extends _$MatchedVendorItemCopyWithImpl<$Res, _$MatchedVendorItemImpl>
    implements _$$MatchedVendorItemImplCopyWith<$Res> {
  __$$MatchedVendorItemImplCopyWithImpl(
    _$MatchedVendorItemImpl _value,
    $Res Function(_$MatchedVendorItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchedVendorItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vendorId = null,
    Object? businessName = null,
    Object? tradingName = freezed,
    Object? rating = freezed,
    Object? isEligible = null,
    Object? matchedAt = null,
    Object? viewedAt = freezed,
  }) {
    return _then(
      _$MatchedVendorItemImpl(
        vendorId: null == vendorId
            ? _value.vendorId
            : vendorId // ignore: cast_nullable_to_non_nullable
                  as String,
        businessName: null == businessName
            ? _value.businessName
            : businessName // ignore: cast_nullable_to_non_nullable
                  as String,
        tradingName: freezed == tradingName
            ? _value.tradingName
            : tradingName // ignore: cast_nullable_to_non_nullable
                  as String?,
        rating: freezed == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double?,
        isEligible: null == isEligible
            ? _value.isEligible
            : isEligible // ignore: cast_nullable_to_non_nullable
                  as bool,
        matchedAt: null == matchedAt
            ? _value.matchedAt
            : matchedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        viewedAt: freezed == viewedAt
            ? _value.viewedAt
            : viewedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchedVendorItemImpl implements _MatchedVendorItem {
  const _$MatchedVendorItemImpl({
    required this.vendorId,
    required this.businessName,
    this.tradingName,
    this.rating,
    this.isEligible = true,
    required this.matchedAt,
    this.viewedAt,
  });

  factory _$MatchedVendorItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchedVendorItemImplFromJson(json);

  @override
  final String vendorId;
  @override
  final String businessName;
  @override
  final String? tradingName;
  @override
  final double? rating;
  @override
  @JsonKey()
  final bool isEligible;
  @override
  final DateTime matchedAt;
  @override
  final DateTime? viewedAt;

  @override
  String toString() {
    return 'MatchedVendorItem(vendorId: $vendorId, businessName: $businessName, tradingName: $tradingName, rating: $rating, isEligible: $isEligible, matchedAt: $matchedAt, viewedAt: $viewedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchedVendorItemImpl &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.businessName, businessName) ||
                other.businessName == businessName) &&
            (identical(other.tradingName, tradingName) ||
                other.tradingName == tradingName) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.isEligible, isEligible) ||
                other.isEligible == isEligible) &&
            (identical(other.matchedAt, matchedAt) ||
                other.matchedAt == matchedAt) &&
            (identical(other.viewedAt, viewedAt) ||
                other.viewedAt == viewedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    vendorId,
    businessName,
    tradingName,
    rating,
    isEligible,
    matchedAt,
    viewedAt,
  );

  /// Create a copy of MatchedVendorItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchedVendorItemImplCopyWith<_$MatchedVendorItemImpl> get copyWith =>
      __$$MatchedVendorItemImplCopyWithImpl<_$MatchedVendorItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchedVendorItemImplToJson(this);
  }
}

abstract class _MatchedVendorItem implements MatchedVendorItem {
  const factory _MatchedVendorItem({
    required final String vendorId,
    required final String businessName,
    final String? tradingName,
    final double? rating,
    final bool isEligible,
    required final DateTime matchedAt,
    final DateTime? viewedAt,
  }) = _$MatchedVendorItemImpl;

  factory _MatchedVendorItem.fromJson(Map<String, dynamic> json) =
      _$MatchedVendorItemImpl.fromJson;

  @override
  String get vendorId;
  @override
  String get businessName;
  @override
  String? get tradingName;
  @override
  double? get rating;
  @override
  bool get isEligible;
  @override
  DateTime get matchedAt;
  @override
  DateTime? get viewedAt;

  /// Create a copy of MatchedVendorItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchedVendorItemImplCopyWith<_$MatchedVendorItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RequestOfferItem _$RequestOfferItemFromJson(Map<String, dynamic> json) {
  return _RequestOfferItem.fromJson(json);
}

/// @nodoc
mixin _$RequestOfferItem {
  String get id => throw _privateConstructorUsedError;
  String get vendorId => throw _privateConstructorUsedError;
  String get vendorName => throw _privateConstructorUsedError;
  double get priceAED => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: OfferState.pending)
  OfferState get state => throw _privateConstructorUsedError;
  String? get outcome => throw _privateConstructorUsedError;
  DateTime get submittedAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  int? get estimatedDays => throw _privateConstructorUsedError;

  /// Serializes this RequestOfferItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RequestOfferItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RequestOfferItemCopyWith<RequestOfferItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequestOfferItemCopyWith<$Res> {
  factory $RequestOfferItemCopyWith(
    RequestOfferItem value,
    $Res Function(RequestOfferItem) then,
  ) = _$RequestOfferItemCopyWithImpl<$Res, RequestOfferItem>;
  @useResult
  $Res call({
    String id,
    String vendorId,
    String vendorName,
    double priceAED,
    @JsonKey(unknownEnumValue: OfferState.pending) OfferState state,
    String? outcome,
    DateTime submittedAt,
    String? notes,
    int? estimatedDays,
  });
}

/// @nodoc
class _$RequestOfferItemCopyWithImpl<$Res, $Val extends RequestOfferItem>
    implements $RequestOfferItemCopyWith<$Res> {
  _$RequestOfferItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RequestOfferItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? vendorId = null,
    Object? vendorName = null,
    Object? priceAED = null,
    Object? state = null,
    Object? outcome = freezed,
    Object? submittedAt = null,
    Object? notes = freezed,
    Object? estimatedDays = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            vendorId: null == vendorId
                ? _value.vendorId
                : vendorId // ignore: cast_nullable_to_non_nullable
                      as String,
            vendorName: null == vendorName
                ? _value.vendorName
                : vendorName // ignore: cast_nullable_to_non_nullable
                      as String,
            priceAED: null == priceAED
                ? _value.priceAED
                : priceAED // ignore: cast_nullable_to_non_nullable
                      as double,
            state: null == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as OfferState,
            outcome: freezed == outcome
                ? _value.outcome
                : outcome // ignore: cast_nullable_to_non_nullable
                      as String?,
            submittedAt: null == submittedAt
                ? _value.submittedAt
                : submittedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            estimatedDays: freezed == estimatedDays
                ? _value.estimatedDays
                : estimatedDays // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RequestOfferItemImplCopyWith<$Res>
    implements $RequestOfferItemCopyWith<$Res> {
  factory _$$RequestOfferItemImplCopyWith(
    _$RequestOfferItemImpl value,
    $Res Function(_$RequestOfferItemImpl) then,
  ) = __$$RequestOfferItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String vendorId,
    String vendorName,
    double priceAED,
    @JsonKey(unknownEnumValue: OfferState.pending) OfferState state,
    String? outcome,
    DateTime submittedAt,
    String? notes,
    int? estimatedDays,
  });
}

/// @nodoc
class __$$RequestOfferItemImplCopyWithImpl<$Res>
    extends _$RequestOfferItemCopyWithImpl<$Res, _$RequestOfferItemImpl>
    implements _$$RequestOfferItemImplCopyWith<$Res> {
  __$$RequestOfferItemImplCopyWithImpl(
    _$RequestOfferItemImpl _value,
    $Res Function(_$RequestOfferItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RequestOfferItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? vendorId = null,
    Object? vendorName = null,
    Object? priceAED = null,
    Object? state = null,
    Object? outcome = freezed,
    Object? submittedAt = null,
    Object? notes = freezed,
    Object? estimatedDays = freezed,
  }) {
    return _then(
      _$RequestOfferItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        vendorId: null == vendorId
            ? _value.vendorId
            : vendorId // ignore: cast_nullable_to_non_nullable
                  as String,
        vendorName: null == vendorName
            ? _value.vendorName
            : vendorName // ignore: cast_nullable_to_non_nullable
                  as String,
        priceAED: null == priceAED
            ? _value.priceAED
            : priceAED // ignore: cast_nullable_to_non_nullable
                  as double,
        state: null == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as OfferState,
        outcome: freezed == outcome
            ? _value.outcome
            : outcome // ignore: cast_nullable_to_non_nullable
                  as String?,
        submittedAt: null == submittedAt
            ? _value.submittedAt
            : submittedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        estimatedDays: freezed == estimatedDays
            ? _value.estimatedDays
            : estimatedDays // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RequestOfferItemImpl implements _RequestOfferItem {
  const _$RequestOfferItemImpl({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.priceAED,
    @JsonKey(unknownEnumValue: OfferState.pending)
    this.state = OfferState.pending,
    this.outcome,
    required this.submittedAt,
    this.notes,
    this.estimatedDays,
  });

  factory _$RequestOfferItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$RequestOfferItemImplFromJson(json);

  @override
  final String id;
  @override
  final String vendorId;
  @override
  final String vendorName;
  @override
  final double priceAED;
  @override
  @JsonKey(unknownEnumValue: OfferState.pending)
  final OfferState state;
  @override
  final String? outcome;
  @override
  final DateTime submittedAt;
  @override
  final String? notes;
  @override
  final int? estimatedDays;

  @override
  String toString() {
    return 'RequestOfferItem(id: $id, vendorId: $vendorId, vendorName: $vendorName, priceAED: $priceAED, state: $state, outcome: $outcome, submittedAt: $submittedAt, notes: $notes, estimatedDays: $estimatedDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RequestOfferItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.vendorName, vendorName) ||
                other.vendorName == vendorName) &&
            (identical(other.priceAED, priceAED) ||
                other.priceAED == priceAED) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.outcome, outcome) || other.outcome == outcome) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.estimatedDays, estimatedDays) ||
                other.estimatedDays == estimatedDays));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    vendorId,
    vendorName,
    priceAED,
    state,
    outcome,
    submittedAt,
    notes,
    estimatedDays,
  );

  /// Create a copy of RequestOfferItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RequestOfferItemImplCopyWith<_$RequestOfferItemImpl> get copyWith =>
      __$$RequestOfferItemImplCopyWithImpl<_$RequestOfferItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RequestOfferItemImplToJson(this);
  }
}

abstract class _RequestOfferItem implements RequestOfferItem {
  const factory _RequestOfferItem({
    required final String id,
    required final String vendorId,
    required final String vendorName,
    required final double priceAED,
    @JsonKey(unknownEnumValue: OfferState.pending) final OfferState state,
    final String? outcome,
    required final DateTime submittedAt,
    final String? notes,
    final int? estimatedDays,
  }) = _$RequestOfferItemImpl;

  factory _RequestOfferItem.fromJson(Map<String, dynamic> json) =
      _$RequestOfferItemImpl.fromJson;

  @override
  String get id;
  @override
  String get vendorId;
  @override
  String get vendorName;
  @override
  double get priceAED;
  @override
  @JsonKey(unknownEnumValue: OfferState.pending)
  OfferState get state;
  @override
  String? get outcome;
  @override
  DateTime get submittedAt;
  @override
  String? get notes;
  @override
  int? get estimatedDays;

  /// Create a copy of RequestOfferItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RequestOfferItemImplCopyWith<_$RequestOfferItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RequestTimelineEvent _$RequestTimelineEventFromJson(Map<String, dynamic> json) {
  return _RequestTimelineEvent.fromJson(json);
}

/// @nodoc
mixin _$RequestTimelineEvent {
  @JsonKey(unknownEnumValue: RequestState.draft)
  RequestState get state => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get actor => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this RequestTimelineEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RequestTimelineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RequestTimelineEventCopyWith<RequestTimelineEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequestTimelineEventCopyWith<$Res> {
  factory $RequestTimelineEventCopyWith(
    RequestTimelineEvent value,
    $Res Function(RequestTimelineEvent) then,
  ) = _$RequestTimelineEventCopyWithImpl<$Res, RequestTimelineEvent>;
  @useResult
  $Res call({
    @JsonKey(unknownEnumValue: RequestState.draft) RequestState state,
    DateTime timestamp,
    String? actor,
    String? notes,
  });
}

/// @nodoc
class _$RequestTimelineEventCopyWithImpl<
  $Res,
  $Val extends RequestTimelineEvent
>
    implements $RequestTimelineEventCopyWith<$Res> {
  _$RequestTimelineEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RequestTimelineEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? state = null,
    Object? timestamp = null,
    Object? actor = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            state: null == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as RequestState,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            actor: freezed == actor
                ? _value.actor
                : actor // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RequestTimelineEventImplCopyWith<$Res>
    implements $RequestTimelineEventCopyWith<$Res> {
  factory _$$RequestTimelineEventImplCopyWith(
    _$RequestTimelineEventImpl value,
    $Res Function(_$RequestTimelineEventImpl) then,
  ) = __$$RequestTimelineEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(unknownEnumValue: RequestState.draft) RequestState state,
    DateTime timestamp,
    String? actor,
    String? notes,
  });
}

/// @nodoc
class __$$RequestTimelineEventImplCopyWithImpl<$Res>
    extends _$RequestTimelineEventCopyWithImpl<$Res, _$RequestTimelineEventImpl>
    implements _$$RequestTimelineEventImplCopyWith<$Res> {
  __$$RequestTimelineEventImplCopyWithImpl(
    _$RequestTimelineEventImpl _value,
    $Res Function(_$RequestTimelineEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RequestTimelineEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? state = null,
    Object? timestamp = null,
    Object? actor = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _$RequestTimelineEventImpl(
        state: null == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as RequestState,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        actor: freezed == actor
            ? _value.actor
            : actor // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RequestTimelineEventImpl implements _RequestTimelineEvent {
  const _$RequestTimelineEventImpl({
    @JsonKey(unknownEnumValue: RequestState.draft)
    this.state = RequestState.draft,
    required this.timestamp,
    this.actor,
    this.notes,
  });

  factory _$RequestTimelineEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$RequestTimelineEventImplFromJson(json);

  @override
  @JsonKey(unknownEnumValue: RequestState.draft)
  final RequestState state;
  @override
  final DateTime timestamp;
  @override
  final String? actor;
  @override
  final String? notes;

  @override
  String toString() {
    return 'RequestTimelineEvent(state: $state, timestamp: $timestamp, actor: $actor, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RequestTimelineEventImpl &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.actor, actor) || other.actor == actor) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, state, timestamp, actor, notes);

  /// Create a copy of RequestTimelineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RequestTimelineEventImplCopyWith<_$RequestTimelineEventImpl>
  get copyWith =>
      __$$RequestTimelineEventImplCopyWithImpl<_$RequestTimelineEventImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RequestTimelineEventImplToJson(this);
  }
}

abstract class _RequestTimelineEvent implements RequestTimelineEvent {
  const factory _RequestTimelineEvent({
    @JsonKey(unknownEnumValue: RequestState.draft) final RequestState state,
    required final DateTime timestamp,
    final String? actor,
    final String? notes,
  }) = _$RequestTimelineEventImpl;

  factory _RequestTimelineEvent.fromJson(Map<String, dynamic> json) =
      _$RequestTimelineEventImpl.fromJson;

  @override
  @JsonKey(unknownEnumValue: RequestState.draft)
  RequestState get state;
  @override
  DateTime get timestamp;
  @override
  String? get actor;
  @override
  String? get notes;

  /// Create a copy of RequestTimelineEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RequestTimelineEventImplCopyWith<_$RequestTimelineEventImpl>
  get copyWith => throw _privateConstructorUsedError;
}

RequestConnectionSummary _$RequestConnectionSummaryFromJson(
  Map<String, dynamic> json,
) {
  return _RequestConnectionSummary.fromJson(json);
}

/// @nodoc
mixin _$RequestConnectionSummary {
  String get id => throw _privateConstructorUsedError;
  String get vendorId => throw _privateConstructorUsedError;
  String get vendorName => throw _privateConstructorUsedError;
  String get customerId => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  String get state => throw _privateConstructorUsedError;
  DateTime get connectedAt => throw _privateConstructorUsedError;
  DateTime? get identityRevealedAt => throw _privateConstructorUsedError;
  DateTime? get closedAt => throw _privateConstructorUsedError;
  String? get whatsappUrl => throw _privateConstructorUsedError;
  String? get channel => throw _privateConstructorUsedError;

  /// Serializes this RequestConnectionSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RequestConnectionSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RequestConnectionSummaryCopyWith<RequestConnectionSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequestConnectionSummaryCopyWith<$Res> {
  factory $RequestConnectionSummaryCopyWith(
    RequestConnectionSummary value,
    $Res Function(RequestConnectionSummary) then,
  ) = _$RequestConnectionSummaryCopyWithImpl<$Res, RequestConnectionSummary>;
  @useResult
  $Res call({
    String id,
    String vendorId,
    String vendorName,
    String customerId,
    String customerName,
    String state,
    DateTime connectedAt,
    DateTime? identityRevealedAt,
    DateTime? closedAt,
    String? whatsappUrl,
    String? channel,
  });
}

/// @nodoc
class _$RequestConnectionSummaryCopyWithImpl<
  $Res,
  $Val extends RequestConnectionSummary
>
    implements $RequestConnectionSummaryCopyWith<$Res> {
  _$RequestConnectionSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RequestConnectionSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? vendorId = null,
    Object? vendorName = null,
    Object? customerId = null,
    Object? customerName = null,
    Object? state = null,
    Object? connectedAt = null,
    Object? identityRevealedAt = freezed,
    Object? closedAt = freezed,
    Object? whatsappUrl = freezed,
    Object? channel = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            vendorId: null == vendorId
                ? _value.vendorId
                : vendorId // ignore: cast_nullable_to_non_nullable
                      as String,
            vendorName: null == vendorName
                ? _value.vendorName
                : vendorName // ignore: cast_nullable_to_non_nullable
                      as String,
            customerId: null == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            state: null == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as String,
            connectedAt: null == connectedAt
                ? _value.connectedAt
                : connectedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            identityRevealedAt: freezed == identityRevealedAt
                ? _value.identityRevealedAt
                : identityRevealedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            closedAt: freezed == closedAt
                ? _value.closedAt
                : closedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            whatsappUrl: freezed == whatsappUrl
                ? _value.whatsappUrl
                : whatsappUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            channel: freezed == channel
                ? _value.channel
                : channel // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RequestConnectionSummaryImplCopyWith<$Res>
    implements $RequestConnectionSummaryCopyWith<$Res> {
  factory _$$RequestConnectionSummaryImplCopyWith(
    _$RequestConnectionSummaryImpl value,
    $Res Function(_$RequestConnectionSummaryImpl) then,
  ) = __$$RequestConnectionSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String vendorId,
    String vendorName,
    String customerId,
    String customerName,
    String state,
    DateTime connectedAt,
    DateTime? identityRevealedAt,
    DateTime? closedAt,
    String? whatsappUrl,
    String? channel,
  });
}

/// @nodoc
class __$$RequestConnectionSummaryImplCopyWithImpl<$Res>
    extends
        _$RequestConnectionSummaryCopyWithImpl<
          $Res,
          _$RequestConnectionSummaryImpl
        >
    implements _$$RequestConnectionSummaryImplCopyWith<$Res> {
  __$$RequestConnectionSummaryImplCopyWithImpl(
    _$RequestConnectionSummaryImpl _value,
    $Res Function(_$RequestConnectionSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RequestConnectionSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? vendorId = null,
    Object? vendorName = null,
    Object? customerId = null,
    Object? customerName = null,
    Object? state = null,
    Object? connectedAt = null,
    Object? identityRevealedAt = freezed,
    Object? closedAt = freezed,
    Object? whatsappUrl = freezed,
    Object? channel = freezed,
  }) {
    return _then(
      _$RequestConnectionSummaryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        vendorId: null == vendorId
            ? _value.vendorId
            : vendorId // ignore: cast_nullable_to_non_nullable
                  as String,
        vendorName: null == vendorName
            ? _value.vendorName
            : vendorName // ignore: cast_nullable_to_non_nullable
                  as String,
        customerId: null == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        state: null == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String,
        connectedAt: null == connectedAt
            ? _value.connectedAt
            : connectedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        identityRevealedAt: freezed == identityRevealedAt
            ? _value.identityRevealedAt
            : identityRevealedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        closedAt: freezed == closedAt
            ? _value.closedAt
            : closedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        whatsappUrl: freezed == whatsappUrl
            ? _value.whatsappUrl
            : whatsappUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        channel: freezed == channel
            ? _value.channel
            : channel // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RequestConnectionSummaryImpl implements _RequestConnectionSummary {
  const _$RequestConnectionSummaryImpl({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.customerId,
    required this.customerName,
    this.state = 'ACTIVE',
    required this.connectedAt,
    this.identityRevealedAt,
    this.closedAt,
    this.whatsappUrl,
    this.channel,
  });

  factory _$RequestConnectionSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$RequestConnectionSummaryImplFromJson(json);

  @override
  final String id;
  @override
  final String vendorId;
  @override
  final String vendorName;
  @override
  final String customerId;
  @override
  final String customerName;
  @override
  @JsonKey()
  final String state;
  @override
  final DateTime connectedAt;
  @override
  final DateTime? identityRevealedAt;
  @override
  final DateTime? closedAt;
  @override
  final String? whatsappUrl;
  @override
  final String? channel;

  @override
  String toString() {
    return 'RequestConnectionSummary(id: $id, vendorId: $vendorId, vendorName: $vendorName, customerId: $customerId, customerName: $customerName, state: $state, connectedAt: $connectedAt, identityRevealedAt: $identityRevealedAt, closedAt: $closedAt, whatsappUrl: $whatsappUrl, channel: $channel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RequestConnectionSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.vendorName, vendorName) ||
                other.vendorName == vendorName) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.connectedAt, connectedAt) ||
                other.connectedAt == connectedAt) &&
            (identical(other.identityRevealedAt, identityRevealedAt) ||
                other.identityRevealedAt == identityRevealedAt) &&
            (identical(other.closedAt, closedAt) ||
                other.closedAt == closedAt) &&
            (identical(other.whatsappUrl, whatsappUrl) ||
                other.whatsappUrl == whatsappUrl) &&
            (identical(other.channel, channel) || other.channel == channel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    vendorId,
    vendorName,
    customerId,
    customerName,
    state,
    connectedAt,
    identityRevealedAt,
    closedAt,
    whatsappUrl,
    channel,
  );

  /// Create a copy of RequestConnectionSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RequestConnectionSummaryImplCopyWith<_$RequestConnectionSummaryImpl>
  get copyWith =>
      __$$RequestConnectionSummaryImplCopyWithImpl<
        _$RequestConnectionSummaryImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RequestConnectionSummaryImplToJson(this);
  }
}

abstract class _RequestConnectionSummary implements RequestConnectionSummary {
  const factory _RequestConnectionSummary({
    required final String id,
    required final String vendorId,
    required final String vendorName,
    required final String customerId,
    required final String customerName,
    final String state,
    required final DateTime connectedAt,
    final DateTime? identityRevealedAt,
    final DateTime? closedAt,
    final String? whatsappUrl,
    final String? channel,
  }) = _$RequestConnectionSummaryImpl;

  factory _RequestConnectionSummary.fromJson(Map<String, dynamic> json) =
      _$RequestConnectionSummaryImpl.fromJson;

  @override
  String get id;
  @override
  String get vendorId;
  @override
  String get vendorName;
  @override
  String get customerId;
  @override
  String get customerName;
  @override
  String get state;
  @override
  DateTime get connectedAt;
  @override
  DateTime? get identityRevealedAt;
  @override
  DateTime? get closedAt;
  @override
  String? get whatsappUrl;
  @override
  String? get channel;

  /// Create a copy of RequestConnectionSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RequestConnectionSummaryImplCopyWith<_$RequestConnectionSummaryImpl>
  get copyWith => throw _privateConstructorUsedError;
}

RequestInternalNoteItem _$RequestInternalNoteItemFromJson(
  Map<String, dynamic> json,
) {
  return _RequestInternalNoteItem.fromJson(json);
}

/// @nodoc
mixin _$RequestInternalNoteItem {
  String get id => throw _privateConstructorUsedError;
  String get authorName => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this RequestInternalNoteItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RequestInternalNoteItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RequestInternalNoteItemCopyWith<RequestInternalNoteItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequestInternalNoteItemCopyWith<$Res> {
  factory $RequestInternalNoteItemCopyWith(
    RequestInternalNoteItem value,
    $Res Function(RequestInternalNoteItem) then,
  ) = _$RequestInternalNoteItemCopyWithImpl<$Res, RequestInternalNoteItem>;
  @useResult
  $Res call({String id, String authorName, String text, DateTime createdAt});
}

/// @nodoc
class _$RequestInternalNoteItemCopyWithImpl<
  $Res,
  $Val extends RequestInternalNoteItem
>
    implements $RequestInternalNoteItemCopyWith<$Res> {
  _$RequestInternalNoteItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RequestInternalNoteItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorName = null,
    Object? text = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            authorName: null == authorName
                ? _value.authorName
                : authorName // ignore: cast_nullable_to_non_nullable
                      as String,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RequestInternalNoteItemImplCopyWith<$Res>
    implements $RequestInternalNoteItemCopyWith<$Res> {
  factory _$$RequestInternalNoteItemImplCopyWith(
    _$RequestInternalNoteItemImpl value,
    $Res Function(_$RequestInternalNoteItemImpl) then,
  ) = __$$RequestInternalNoteItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String authorName, String text, DateTime createdAt});
}

/// @nodoc
class __$$RequestInternalNoteItemImplCopyWithImpl<$Res>
    extends
        _$RequestInternalNoteItemCopyWithImpl<
          $Res,
          _$RequestInternalNoteItemImpl
        >
    implements _$$RequestInternalNoteItemImplCopyWith<$Res> {
  __$$RequestInternalNoteItemImplCopyWithImpl(
    _$RequestInternalNoteItemImpl _value,
    $Res Function(_$RequestInternalNoteItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RequestInternalNoteItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorName = null,
    Object? text = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$RequestInternalNoteItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        authorName: null == authorName
            ? _value.authorName
            : authorName // ignore: cast_nullable_to_non_nullable
                  as String,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RequestInternalNoteItemImpl implements _RequestInternalNoteItem {
  const _$RequestInternalNoteItemImpl({
    required this.id,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  factory _$RequestInternalNoteItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$RequestInternalNoteItemImplFromJson(json);

  @override
  final String id;
  @override
  final String authorName;
  @override
  final String text;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'RequestInternalNoteItem(id: $id, authorName: $authorName, text: $text, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RequestInternalNoteItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, authorName, text, createdAt);

  /// Create a copy of RequestInternalNoteItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RequestInternalNoteItemImplCopyWith<_$RequestInternalNoteItemImpl>
  get copyWith =>
      __$$RequestInternalNoteItemImplCopyWithImpl<
        _$RequestInternalNoteItemImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RequestInternalNoteItemImplToJson(this);
  }
}

abstract class _RequestInternalNoteItem implements RequestInternalNoteItem {
  const factory _RequestInternalNoteItem({
    required final String id,
    required final String authorName,
    required final String text,
    required final DateTime createdAt,
  }) = _$RequestInternalNoteItemImpl;

  factory _RequestInternalNoteItem.fromJson(Map<String, dynamic> json) =
      _$RequestInternalNoteItemImpl.fromJson;

  @override
  String get id;
  @override
  String get authorName;
  @override
  String get text;
  @override
  DateTime get createdAt;

  /// Create a copy of RequestInternalNoteItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RequestInternalNoteItemImplCopyWith<_$RequestInternalNoteItemImpl>
  get copyWith => throw _privateConstructorUsedError;
}

RequestDetail _$RequestDetailFromJson(Map<String, dynamic> json) {
  return _RequestDetail.fromJson(json);
}

/// @nodoc
mixin _$RequestDetail {
  String get id => throw _privateConstructorUsedError;
  String? get reference => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: RequestType.findOrnament)
  RequestType get requestType => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: Direction.buy)
  Direction get direction => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: RequestState.draft)
  RequestState get state => throw _privateConstructorUsedError;
  CustomerProfileSummary get customer => throw _privateConstructorUsedError;
  String get categoryName => throw _privateConstructorUsedError;
  String get regionName => throw _privateConstructorUsedError;
  String? get ornamentType => throw _privateConstructorUsedError;
  double? get weightGrams => throw _privateConstructorUsedError;
  bool get weightIsApproximate => throw _privateConstructorUsedError;
  String? get purityKarat => throw _privateConstructorUsedError;
  String? get condition => throw _privateConstructorUsedError;
  double? get denominationGrams => throw _privateConstructorUsedError;
  int? get quantity => throw _privateConstructorUsedError;
  String? get mintOrRefiner => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  double? get indicativeValue => throw _privateConstructorUsedError;
  double? get budgetMin => throw _privateConstructorUsedError;
  double? get budgetMax => throw _privateConstructorUsedError;
  bool get budgetIsFlexible => throw _privateConstructorUsedError;
  DateTime? get publishedAt => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get cancellationReason => throw _privateConstructorUsedError;
  String? get removalReasonCode => throw _privateConstructorUsedError;
  String? get removalReasonText => throw _privateConstructorUsedError;
  String? get removalPolicyClause => throw _privateConstructorUsedError;
  List<RequestMediaItem> get media => throw _privateConstructorUsedError;
  List<MatchedVendorItem> get matchedVendors =>
      throw _privateConstructorUsedError;
  List<RequestOfferItem> get offers => throw _privateConstructorUsedError;
  List<RequestTimelineEvent> get timeline => throw _privateConstructorUsedError;
  RequestConnectionSummary? get connection =>
      throw _privateConstructorUsedError;
  List<RequestInternalNoteItem> get internalNotes =>
      throw _privateConstructorUsedError;

  /// Serializes this RequestDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RequestDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RequestDetailCopyWith<RequestDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequestDetailCopyWith<$Res> {
  factory $RequestDetailCopyWith(
    RequestDetail value,
    $Res Function(RequestDetail) then,
  ) = _$RequestDetailCopyWithImpl<$Res, RequestDetail>;
  @useResult
  $Res call({
    String id,
    String? reference,
    @JsonKey(unknownEnumValue: RequestType.findOrnament)
    RequestType requestType,
    @JsonKey(unknownEnumValue: Direction.buy) Direction direction,
    @JsonKey(unknownEnumValue: RequestState.draft) RequestState state,
    CustomerProfileSummary customer,
    String categoryName,
    String regionName,
    String? ornamentType,
    double? weightGrams,
    bool weightIsApproximate,
    String? purityKarat,
    String? condition,
    double? denominationGrams,
    int? quantity,
    String? mintOrRefiner,
    String? notes,
    double? indicativeValue,
    double? budgetMin,
    double? budgetMax,
    bool budgetIsFlexible,
    DateTime? publishedAt,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? cancellationReason,
    String? removalReasonCode,
    String? removalReasonText,
    String? removalPolicyClause,
    List<RequestMediaItem> media,
    List<MatchedVendorItem> matchedVendors,
    List<RequestOfferItem> offers,
    List<RequestTimelineEvent> timeline,
    RequestConnectionSummary? connection,
    List<RequestInternalNoteItem> internalNotes,
  });

  $CustomerProfileSummaryCopyWith<$Res> get customer;
  $RequestConnectionSummaryCopyWith<$Res>? get connection;
}

/// @nodoc
class _$RequestDetailCopyWithImpl<$Res, $Val extends RequestDetail>
    implements $RequestDetailCopyWith<$Res> {
  _$RequestDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RequestDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reference = freezed,
    Object? requestType = null,
    Object? direction = null,
    Object? state = null,
    Object? customer = null,
    Object? categoryName = null,
    Object? regionName = null,
    Object? ornamentType = freezed,
    Object? weightGrams = freezed,
    Object? weightIsApproximate = null,
    Object? purityKarat = freezed,
    Object? condition = freezed,
    Object? denominationGrams = freezed,
    Object? quantity = freezed,
    Object? mintOrRefiner = freezed,
    Object? notes = freezed,
    Object? indicativeValue = freezed,
    Object? budgetMin = freezed,
    Object? budgetMax = freezed,
    Object? budgetIsFlexible = null,
    Object? publishedAt = freezed,
    Object? expiresAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? cancellationReason = freezed,
    Object? removalReasonCode = freezed,
    Object? removalReasonText = freezed,
    Object? removalPolicyClause = freezed,
    Object? media = null,
    Object? matchedVendors = null,
    Object? offers = null,
    Object? timeline = null,
    Object? connection = freezed,
    Object? internalNotes = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            reference: freezed == reference
                ? _value.reference
                : reference // ignore: cast_nullable_to_non_nullable
                      as String?,
            requestType: null == requestType
                ? _value.requestType
                : requestType // ignore: cast_nullable_to_non_nullable
                      as RequestType,
            direction: null == direction
                ? _value.direction
                : direction // ignore: cast_nullable_to_non_nullable
                      as Direction,
            state: null == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as RequestState,
            customer: null == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as CustomerProfileSummary,
            categoryName: null == categoryName
                ? _value.categoryName
                : categoryName // ignore: cast_nullable_to_non_nullable
                      as String,
            regionName: null == regionName
                ? _value.regionName
                : regionName // ignore: cast_nullable_to_non_nullable
                      as String,
            ornamentType: freezed == ornamentType
                ? _value.ornamentType
                : ornamentType // ignore: cast_nullable_to_non_nullable
                      as String?,
            weightGrams: freezed == weightGrams
                ? _value.weightGrams
                : weightGrams // ignore: cast_nullable_to_non_nullable
                      as double?,
            weightIsApproximate: null == weightIsApproximate
                ? _value.weightIsApproximate
                : weightIsApproximate // ignore: cast_nullable_to_non_nullable
                      as bool,
            purityKarat: freezed == purityKarat
                ? _value.purityKarat
                : purityKarat // ignore: cast_nullable_to_non_nullable
                      as String?,
            condition: freezed == condition
                ? _value.condition
                : condition // ignore: cast_nullable_to_non_nullable
                      as String?,
            denominationGrams: freezed == denominationGrams
                ? _value.denominationGrams
                : denominationGrams // ignore: cast_nullable_to_non_nullable
                      as double?,
            quantity: freezed == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int?,
            mintOrRefiner: freezed == mintOrRefiner
                ? _value.mintOrRefiner
                : mintOrRefiner // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            indicativeValue: freezed == indicativeValue
                ? _value.indicativeValue
                : indicativeValue // ignore: cast_nullable_to_non_nullable
                      as double?,
            budgetMin: freezed == budgetMin
                ? _value.budgetMin
                : budgetMin // ignore: cast_nullable_to_non_nullable
                      as double?,
            budgetMax: freezed == budgetMax
                ? _value.budgetMax
                : budgetMax // ignore: cast_nullable_to_non_nullable
                      as double?,
            budgetIsFlexible: null == budgetIsFlexible
                ? _value.budgetIsFlexible
                : budgetIsFlexible // ignore: cast_nullable_to_non_nullable
                      as bool,
            publishedAt: freezed == publishedAt
                ? _value.publishedAt
                : publishedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            cancellationReason: freezed == cancellationReason
                ? _value.cancellationReason
                : cancellationReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            removalReasonCode: freezed == removalReasonCode
                ? _value.removalReasonCode
                : removalReasonCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            removalReasonText: freezed == removalReasonText
                ? _value.removalReasonText
                : removalReasonText // ignore: cast_nullable_to_non_nullable
                      as String?,
            removalPolicyClause: freezed == removalPolicyClause
                ? _value.removalPolicyClause
                : removalPolicyClause // ignore: cast_nullable_to_non_nullable
                      as String?,
            media: null == media
                ? _value.media
                : media // ignore: cast_nullable_to_non_nullable
                      as List<RequestMediaItem>,
            matchedVendors: null == matchedVendors
                ? _value.matchedVendors
                : matchedVendors // ignore: cast_nullable_to_non_nullable
                      as List<MatchedVendorItem>,
            offers: null == offers
                ? _value.offers
                : offers // ignore: cast_nullable_to_non_nullable
                      as List<RequestOfferItem>,
            timeline: null == timeline
                ? _value.timeline
                : timeline // ignore: cast_nullable_to_non_nullable
                      as List<RequestTimelineEvent>,
            connection: freezed == connection
                ? _value.connection
                : connection // ignore: cast_nullable_to_non_nullable
                      as RequestConnectionSummary?,
            internalNotes: null == internalNotes
                ? _value.internalNotes
                : internalNotes // ignore: cast_nullable_to_non_nullable
                      as List<RequestInternalNoteItem>,
          )
          as $Val,
    );
  }

  /// Create a copy of RequestDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CustomerProfileSummaryCopyWith<$Res> get customer {
    return $CustomerProfileSummaryCopyWith<$Res>(_value.customer, (value) {
      return _then(_value.copyWith(customer: value) as $Val);
    });
  }

  /// Create a copy of RequestDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RequestConnectionSummaryCopyWith<$Res>? get connection {
    if (_value.connection == null) {
      return null;
    }

    return $RequestConnectionSummaryCopyWith<$Res>(_value.connection!, (value) {
      return _then(_value.copyWith(connection: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RequestDetailImplCopyWith<$Res>
    implements $RequestDetailCopyWith<$Res> {
  factory _$$RequestDetailImplCopyWith(
    _$RequestDetailImpl value,
    $Res Function(_$RequestDetailImpl) then,
  ) = __$$RequestDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? reference,
    @JsonKey(unknownEnumValue: RequestType.findOrnament)
    RequestType requestType,
    @JsonKey(unknownEnumValue: Direction.buy) Direction direction,
    @JsonKey(unknownEnumValue: RequestState.draft) RequestState state,
    CustomerProfileSummary customer,
    String categoryName,
    String regionName,
    String? ornamentType,
    double? weightGrams,
    bool weightIsApproximate,
    String? purityKarat,
    String? condition,
    double? denominationGrams,
    int? quantity,
    String? mintOrRefiner,
    String? notes,
    double? indicativeValue,
    double? budgetMin,
    double? budgetMax,
    bool budgetIsFlexible,
    DateTime? publishedAt,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? cancellationReason,
    String? removalReasonCode,
    String? removalReasonText,
    String? removalPolicyClause,
    List<RequestMediaItem> media,
    List<MatchedVendorItem> matchedVendors,
    List<RequestOfferItem> offers,
    List<RequestTimelineEvent> timeline,
    RequestConnectionSummary? connection,
    List<RequestInternalNoteItem> internalNotes,
  });

  @override
  $CustomerProfileSummaryCopyWith<$Res> get customer;
  @override
  $RequestConnectionSummaryCopyWith<$Res>? get connection;
}

/// @nodoc
class __$$RequestDetailImplCopyWithImpl<$Res>
    extends _$RequestDetailCopyWithImpl<$Res, _$RequestDetailImpl>
    implements _$$RequestDetailImplCopyWith<$Res> {
  __$$RequestDetailImplCopyWithImpl(
    _$RequestDetailImpl _value,
    $Res Function(_$RequestDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RequestDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reference = freezed,
    Object? requestType = null,
    Object? direction = null,
    Object? state = null,
    Object? customer = null,
    Object? categoryName = null,
    Object? regionName = null,
    Object? ornamentType = freezed,
    Object? weightGrams = freezed,
    Object? weightIsApproximate = null,
    Object? purityKarat = freezed,
    Object? condition = freezed,
    Object? denominationGrams = freezed,
    Object? quantity = freezed,
    Object? mintOrRefiner = freezed,
    Object? notes = freezed,
    Object? indicativeValue = freezed,
    Object? budgetMin = freezed,
    Object? budgetMax = freezed,
    Object? budgetIsFlexible = null,
    Object? publishedAt = freezed,
    Object? expiresAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? cancellationReason = freezed,
    Object? removalReasonCode = freezed,
    Object? removalReasonText = freezed,
    Object? removalPolicyClause = freezed,
    Object? media = null,
    Object? matchedVendors = null,
    Object? offers = null,
    Object? timeline = null,
    Object? connection = freezed,
    Object? internalNotes = null,
  }) {
    return _then(
      _$RequestDetailImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        reference: freezed == reference
            ? _value.reference
            : reference // ignore: cast_nullable_to_non_nullable
                  as String?,
        requestType: null == requestType
            ? _value.requestType
            : requestType // ignore: cast_nullable_to_non_nullable
                  as RequestType,
        direction: null == direction
            ? _value.direction
            : direction // ignore: cast_nullable_to_non_nullable
                  as Direction,
        state: null == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as RequestState,
        customer: null == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as CustomerProfileSummary,
        categoryName: null == categoryName
            ? _value.categoryName
            : categoryName // ignore: cast_nullable_to_non_nullable
                  as String,
        regionName: null == regionName
            ? _value.regionName
            : regionName // ignore: cast_nullable_to_non_nullable
                  as String,
        ornamentType: freezed == ornamentType
            ? _value.ornamentType
            : ornamentType // ignore: cast_nullable_to_non_nullable
                  as String?,
        weightGrams: freezed == weightGrams
            ? _value.weightGrams
            : weightGrams // ignore: cast_nullable_to_non_nullable
                  as double?,
        weightIsApproximate: null == weightIsApproximate
            ? _value.weightIsApproximate
            : weightIsApproximate // ignore: cast_nullable_to_non_nullable
                  as bool,
        purityKarat: freezed == purityKarat
            ? _value.purityKarat
            : purityKarat // ignore: cast_nullable_to_non_nullable
                  as String?,
        condition: freezed == condition
            ? _value.condition
            : condition // ignore: cast_nullable_to_non_nullable
                  as String?,
        denominationGrams: freezed == denominationGrams
            ? _value.denominationGrams
            : denominationGrams // ignore: cast_nullable_to_non_nullable
                  as double?,
        quantity: freezed == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int?,
        mintOrRefiner: freezed == mintOrRefiner
            ? _value.mintOrRefiner
            : mintOrRefiner // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        indicativeValue: freezed == indicativeValue
            ? _value.indicativeValue
            : indicativeValue // ignore: cast_nullable_to_non_nullable
                  as double?,
        budgetMin: freezed == budgetMin
            ? _value.budgetMin
            : budgetMin // ignore: cast_nullable_to_non_nullable
                  as double?,
        budgetMax: freezed == budgetMax
            ? _value.budgetMax
            : budgetMax // ignore: cast_nullable_to_non_nullable
                  as double?,
        budgetIsFlexible: null == budgetIsFlexible
            ? _value.budgetIsFlexible
            : budgetIsFlexible // ignore: cast_nullable_to_non_nullable
                  as bool,
        publishedAt: freezed == publishedAt
            ? _value.publishedAt
            : publishedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        cancellationReason: freezed == cancellationReason
            ? _value.cancellationReason
            : cancellationReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        removalReasonCode: freezed == removalReasonCode
            ? _value.removalReasonCode
            : removalReasonCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        removalReasonText: freezed == removalReasonText
            ? _value.removalReasonText
            : removalReasonText // ignore: cast_nullable_to_non_nullable
                  as String?,
        removalPolicyClause: freezed == removalPolicyClause
            ? _value.removalPolicyClause
            : removalPolicyClause // ignore: cast_nullable_to_non_nullable
                  as String?,
        media: null == media
            ? _value._media
            : media // ignore: cast_nullable_to_non_nullable
                  as List<RequestMediaItem>,
        matchedVendors: null == matchedVendors
            ? _value._matchedVendors
            : matchedVendors // ignore: cast_nullable_to_non_nullable
                  as List<MatchedVendorItem>,
        offers: null == offers
            ? _value._offers
            : offers // ignore: cast_nullable_to_non_nullable
                  as List<RequestOfferItem>,
        timeline: null == timeline
            ? _value._timeline
            : timeline // ignore: cast_nullable_to_non_nullable
                  as List<RequestTimelineEvent>,
        connection: freezed == connection
            ? _value.connection
            : connection // ignore: cast_nullable_to_non_nullable
                  as RequestConnectionSummary?,
        internalNotes: null == internalNotes
            ? _value._internalNotes
            : internalNotes // ignore: cast_nullable_to_non_nullable
                  as List<RequestInternalNoteItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RequestDetailImpl extends _RequestDetail {
  const _$RequestDetailImpl({
    required this.id,
    this.reference,
    @JsonKey(unknownEnumValue: RequestType.findOrnament)
    this.requestType = RequestType.findOrnament,
    @JsonKey(unknownEnumValue: Direction.buy) this.direction = Direction.buy,
    @JsonKey(unknownEnumValue: RequestState.draft)
    this.state = RequestState.draft,
    required this.customer,
    this.categoryName = '—',
    this.regionName = '—',
    this.ornamentType,
    this.weightGrams,
    this.weightIsApproximate = false,
    this.purityKarat,
    this.condition,
    this.denominationGrams,
    this.quantity,
    this.mintOrRefiner,
    this.notes,
    this.indicativeValue,
    this.budgetMin,
    this.budgetMax,
    this.budgetIsFlexible = false,
    this.publishedAt,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.cancellationReason,
    this.removalReasonCode,
    this.removalReasonText,
    this.removalPolicyClause,
    final List<RequestMediaItem> media = const [],
    final List<MatchedVendorItem> matchedVendors = const [],
    final List<RequestOfferItem> offers = const [],
    final List<RequestTimelineEvent> timeline = const [],
    this.connection,
    final List<RequestInternalNoteItem> internalNotes = const [],
  }) : _media = media,
       _matchedVendors = matchedVendors,
       _offers = offers,
       _timeline = timeline,
       _internalNotes = internalNotes,
       super._();

  factory _$RequestDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$RequestDetailImplFromJson(json);

  @override
  final String id;
  @override
  final String? reference;
  @override
  @JsonKey(unknownEnumValue: RequestType.findOrnament)
  final RequestType requestType;
  @override
  @JsonKey(unknownEnumValue: Direction.buy)
  final Direction direction;
  @override
  @JsonKey(unknownEnumValue: RequestState.draft)
  final RequestState state;
  @override
  final CustomerProfileSummary customer;
  @override
  @JsonKey()
  final String categoryName;
  @override
  @JsonKey()
  final String regionName;
  @override
  final String? ornamentType;
  @override
  final double? weightGrams;
  @override
  @JsonKey()
  final bool weightIsApproximate;
  @override
  final String? purityKarat;
  @override
  final String? condition;
  @override
  final double? denominationGrams;
  @override
  final int? quantity;
  @override
  final String? mintOrRefiner;
  @override
  final String? notes;
  @override
  final double? indicativeValue;
  @override
  final double? budgetMin;
  @override
  final double? budgetMax;
  @override
  @JsonKey()
  final bool budgetIsFlexible;
  @override
  final DateTime? publishedAt;
  @override
  final DateTime? expiresAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final String? cancellationReason;
  @override
  final String? removalReasonCode;
  @override
  final String? removalReasonText;
  @override
  final String? removalPolicyClause;
  final List<RequestMediaItem> _media;
  @override
  @JsonKey()
  List<RequestMediaItem> get media {
    if (_media is EqualUnmodifiableListView) return _media;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_media);
  }

  final List<MatchedVendorItem> _matchedVendors;
  @override
  @JsonKey()
  List<MatchedVendorItem> get matchedVendors {
    if (_matchedVendors is EqualUnmodifiableListView) return _matchedVendors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_matchedVendors);
  }

  final List<RequestOfferItem> _offers;
  @override
  @JsonKey()
  List<RequestOfferItem> get offers {
    if (_offers is EqualUnmodifiableListView) return _offers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_offers);
  }

  final List<RequestTimelineEvent> _timeline;
  @override
  @JsonKey()
  List<RequestTimelineEvent> get timeline {
    if (_timeline is EqualUnmodifiableListView) return _timeline;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_timeline);
  }

  @override
  final RequestConnectionSummary? connection;
  final List<RequestInternalNoteItem> _internalNotes;
  @override
  @JsonKey()
  List<RequestInternalNoteItem> get internalNotes {
    if (_internalNotes is EqualUnmodifiableListView) return _internalNotes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_internalNotes);
  }

  @override
  String toString() {
    return 'RequestDetail(id: $id, reference: $reference, requestType: $requestType, direction: $direction, state: $state, customer: $customer, categoryName: $categoryName, regionName: $regionName, ornamentType: $ornamentType, weightGrams: $weightGrams, weightIsApproximate: $weightIsApproximate, purityKarat: $purityKarat, condition: $condition, denominationGrams: $denominationGrams, quantity: $quantity, mintOrRefiner: $mintOrRefiner, notes: $notes, indicativeValue: $indicativeValue, budgetMin: $budgetMin, budgetMax: $budgetMax, budgetIsFlexible: $budgetIsFlexible, publishedAt: $publishedAt, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt, cancellationReason: $cancellationReason, removalReasonCode: $removalReasonCode, removalReasonText: $removalReasonText, removalPolicyClause: $removalPolicyClause, media: $media, matchedVendors: $matchedVendors, offers: $offers, timeline: $timeline, connection: $connection, internalNotes: $internalNotes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RequestDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.requestType, requestType) ||
                other.requestType == requestType) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.regionName, regionName) ||
                other.regionName == regionName) &&
            (identical(other.ornamentType, ornamentType) ||
                other.ornamentType == ornamentType) &&
            (identical(other.weightGrams, weightGrams) ||
                other.weightGrams == weightGrams) &&
            (identical(other.weightIsApproximate, weightIsApproximate) ||
                other.weightIsApproximate == weightIsApproximate) &&
            (identical(other.purityKarat, purityKarat) ||
                other.purityKarat == purityKarat) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.denominationGrams, denominationGrams) ||
                other.denominationGrams == denominationGrams) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.mintOrRefiner, mintOrRefiner) ||
                other.mintOrRefiner == mintOrRefiner) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.indicativeValue, indicativeValue) ||
                other.indicativeValue == indicativeValue) &&
            (identical(other.budgetMin, budgetMin) ||
                other.budgetMin == budgetMin) &&
            (identical(other.budgetMax, budgetMax) ||
                other.budgetMax == budgetMax) &&
            (identical(other.budgetIsFlexible, budgetIsFlexible) ||
                other.budgetIsFlexible == budgetIsFlexible) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.cancellationReason, cancellationReason) ||
                other.cancellationReason == cancellationReason) &&
            (identical(other.removalReasonCode, removalReasonCode) ||
                other.removalReasonCode == removalReasonCode) &&
            (identical(other.removalReasonText, removalReasonText) ||
                other.removalReasonText == removalReasonText) &&
            (identical(other.removalPolicyClause, removalPolicyClause) ||
                other.removalPolicyClause == removalPolicyClause) &&
            const DeepCollectionEquality().equals(other._media, _media) &&
            const DeepCollectionEquality().equals(
              other._matchedVendors,
              _matchedVendors,
            ) &&
            const DeepCollectionEquality().equals(other._offers, _offers) &&
            const DeepCollectionEquality().equals(other._timeline, _timeline) &&
            (identical(other.connection, connection) ||
                other.connection == connection) &&
            const DeepCollectionEquality().equals(
              other._internalNotes,
              _internalNotes,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    reference,
    requestType,
    direction,
    state,
    customer,
    categoryName,
    regionName,
    ornamentType,
    weightGrams,
    weightIsApproximate,
    purityKarat,
    condition,
    denominationGrams,
    quantity,
    mintOrRefiner,
    notes,
    indicativeValue,
    budgetMin,
    budgetMax,
    budgetIsFlexible,
    publishedAt,
    expiresAt,
    createdAt,
    updatedAt,
    cancellationReason,
    removalReasonCode,
    removalReasonText,
    removalPolicyClause,
    const DeepCollectionEquality().hash(_media),
    const DeepCollectionEquality().hash(_matchedVendors),
    const DeepCollectionEquality().hash(_offers),
    const DeepCollectionEquality().hash(_timeline),
    connection,
    const DeepCollectionEquality().hash(_internalNotes),
  ]);

  /// Create a copy of RequestDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RequestDetailImplCopyWith<_$RequestDetailImpl> get copyWith =>
      __$$RequestDetailImplCopyWithImpl<_$RequestDetailImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RequestDetailImplToJson(this);
  }
}

abstract class _RequestDetail extends RequestDetail {
  const factory _RequestDetail({
    required final String id,
    final String? reference,
    @JsonKey(unknownEnumValue: RequestType.findOrnament)
    final RequestType requestType,
    @JsonKey(unknownEnumValue: Direction.buy) final Direction direction,
    @JsonKey(unknownEnumValue: RequestState.draft) final RequestState state,
    required final CustomerProfileSummary customer,
    final String categoryName,
    final String regionName,
    final String? ornamentType,
    final double? weightGrams,
    final bool weightIsApproximate,
    final String? purityKarat,
    final String? condition,
    final double? denominationGrams,
    final int? quantity,
    final String? mintOrRefiner,
    final String? notes,
    final double? indicativeValue,
    final double? budgetMin,
    final double? budgetMax,
    final bool budgetIsFlexible,
    final DateTime? publishedAt,
    final DateTime? expiresAt,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final String? cancellationReason,
    final String? removalReasonCode,
    final String? removalReasonText,
    final String? removalPolicyClause,
    final List<RequestMediaItem> media,
    final List<MatchedVendorItem> matchedVendors,
    final List<RequestOfferItem> offers,
    final List<RequestTimelineEvent> timeline,
    final RequestConnectionSummary? connection,
    final List<RequestInternalNoteItem> internalNotes,
  }) = _$RequestDetailImpl;
  const _RequestDetail._() : super._();

  factory _RequestDetail.fromJson(Map<String, dynamic> json) =
      _$RequestDetailImpl.fromJson;

  @override
  String get id;
  @override
  String? get reference;
  @override
  @JsonKey(unknownEnumValue: RequestType.findOrnament)
  RequestType get requestType;
  @override
  @JsonKey(unknownEnumValue: Direction.buy)
  Direction get direction;
  @override
  @JsonKey(unknownEnumValue: RequestState.draft)
  RequestState get state;
  @override
  CustomerProfileSummary get customer;
  @override
  String get categoryName;
  @override
  String get regionName;
  @override
  String? get ornamentType;
  @override
  double? get weightGrams;
  @override
  bool get weightIsApproximate;
  @override
  String? get purityKarat;
  @override
  String? get condition;
  @override
  double? get denominationGrams;
  @override
  int? get quantity;
  @override
  String? get mintOrRefiner;
  @override
  String? get notes;
  @override
  double? get indicativeValue;
  @override
  double? get budgetMin;
  @override
  double? get budgetMax;
  @override
  bool get budgetIsFlexible;
  @override
  DateTime? get publishedAt;
  @override
  DateTime? get expiresAt;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  String? get cancellationReason;
  @override
  String? get removalReasonCode;
  @override
  String? get removalReasonText;
  @override
  String? get removalPolicyClause;
  @override
  List<RequestMediaItem> get media;
  @override
  List<MatchedVendorItem> get matchedVendors;
  @override
  List<RequestOfferItem> get offers;
  @override
  List<RequestTimelineEvent> get timeline;
  @override
  RequestConnectionSummary? get connection;
  @override
  List<RequestInternalNoteItem> get internalNotes;

  /// Create a copy of RequestDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RequestDetailImplCopyWith<_$RequestDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
