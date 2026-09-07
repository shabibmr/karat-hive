// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RequestListItem _$RequestListItemFromJson(Map<String, dynamic> json) {
  return _RequestListItem.fromJson(json);
}

/// @nodoc
mixin _$RequestListItem {
  String get id => throw _privateConstructorUsedError;
  String? get reference => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: RequestType.findOrnament)
  RequestType get requestType => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: Direction.buy)
  Direction get direction => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: RequestState.draft)
  RequestState get state => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  String? get customerId => throw _privateConstructorUsedError;
  String? get customerPhone => throw _privateConstructorUsedError;
  String get categoryName => throw _privateConstructorUsedError;
  String get regionName => throw _privateConstructorUsedError;
  double? get indicativeValue => throw _privateConstructorUsedError;
  double? get budgetMin => throw _privateConstructorUsedError;
  double? get budgetMax => throw _privateConstructorUsedError;
  int get offerCount => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get ornamentType => throw _privateConstructorUsedError;
  double? get weightGrams => throw _privateConstructorUsedError;
  String? get purityKarat => throw _privateConstructorUsedError;
  DateTime? get publishedAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this RequestListItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RequestListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RequestListItemCopyWith<RequestListItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequestListItemCopyWith<$Res> {
  factory $RequestListItemCopyWith(
    RequestListItem value,
    $Res Function(RequestListItem) then,
  ) = _$RequestListItemCopyWithImpl<$Res, RequestListItem>;
  @useResult
  $Res call({
    String id,
    String? reference,
    @JsonKey(unknownEnumValue: RequestType.findOrnament)
    RequestType requestType,
    @JsonKey(unknownEnumValue: Direction.buy) Direction direction,
    @JsonKey(unknownEnumValue: RequestState.draft) RequestState state,
    String customerName,
    String? customerId,
    String? customerPhone,
    String categoryName,
    String regionName,
    double? indicativeValue,
    double? budgetMin,
    double? budgetMax,
    int offerCount,
    String? notes,
    String? ornamentType,
    double? weightGrams,
    String? purityKarat,
    DateTime? publishedAt,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$RequestListItemCopyWithImpl<$Res, $Val extends RequestListItem>
    implements $RequestListItemCopyWith<$Res> {
  _$RequestListItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RequestListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reference = freezed,
    Object? requestType = null,
    Object? direction = null,
    Object? state = null,
    Object? customerName = null,
    Object? customerId = freezed,
    Object? customerPhone = freezed,
    Object? categoryName = null,
    Object? regionName = null,
    Object? indicativeValue = freezed,
    Object? budgetMin = freezed,
    Object? budgetMax = freezed,
    Object? offerCount = null,
    Object? notes = freezed,
    Object? ornamentType = freezed,
    Object? weightGrams = freezed,
    Object? purityKarat = freezed,
    Object? publishedAt = freezed,
    Object? createdAt = freezed,
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
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            customerId: freezed == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            customerPhone: freezed == customerPhone
                ? _value.customerPhone
                : customerPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            categoryName: null == categoryName
                ? _value.categoryName
                : categoryName // ignore: cast_nullable_to_non_nullable
                      as String,
            regionName: null == regionName
                ? _value.regionName
                : regionName // ignore: cast_nullable_to_non_nullable
                      as String,
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
            offerCount: null == offerCount
                ? _value.offerCount
                : offerCount // ignore: cast_nullable_to_non_nullable
                      as int,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            ornamentType: freezed == ornamentType
                ? _value.ornamentType
                : ornamentType // ignore: cast_nullable_to_non_nullable
                      as String?,
            weightGrams: freezed == weightGrams
                ? _value.weightGrams
                : weightGrams // ignore: cast_nullable_to_non_nullable
                      as double?,
            purityKarat: freezed == purityKarat
                ? _value.purityKarat
                : purityKarat // ignore: cast_nullable_to_non_nullable
                      as String?,
            publishedAt: freezed == publishedAt
                ? _value.publishedAt
                : publishedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
abstract class _$$RequestListItemImplCopyWith<$Res>
    implements $RequestListItemCopyWith<$Res> {
  factory _$$RequestListItemImplCopyWith(
    _$RequestListItemImpl value,
    $Res Function(_$RequestListItemImpl) then,
  ) = __$$RequestListItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? reference,
    @JsonKey(unknownEnumValue: RequestType.findOrnament)
    RequestType requestType,
    @JsonKey(unknownEnumValue: Direction.buy) Direction direction,
    @JsonKey(unknownEnumValue: RequestState.draft) RequestState state,
    String customerName,
    String? customerId,
    String? customerPhone,
    String categoryName,
    String regionName,
    double? indicativeValue,
    double? budgetMin,
    double? budgetMax,
    int offerCount,
    String? notes,
    String? ornamentType,
    double? weightGrams,
    String? purityKarat,
    DateTime? publishedAt,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$RequestListItemImplCopyWithImpl<$Res>
    extends _$RequestListItemCopyWithImpl<$Res, _$RequestListItemImpl>
    implements _$$RequestListItemImplCopyWith<$Res> {
  __$$RequestListItemImplCopyWithImpl(
    _$RequestListItemImpl _value,
    $Res Function(_$RequestListItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RequestListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reference = freezed,
    Object? requestType = null,
    Object? direction = null,
    Object? state = null,
    Object? customerName = null,
    Object? customerId = freezed,
    Object? customerPhone = freezed,
    Object? categoryName = null,
    Object? regionName = null,
    Object? indicativeValue = freezed,
    Object? budgetMin = freezed,
    Object? budgetMax = freezed,
    Object? offerCount = null,
    Object? notes = freezed,
    Object? ornamentType = freezed,
    Object? weightGrams = freezed,
    Object? purityKarat = freezed,
    Object? publishedAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$RequestListItemImpl(
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
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        customerId: freezed == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        customerPhone: freezed == customerPhone
            ? _value.customerPhone
            : customerPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        categoryName: null == categoryName
            ? _value.categoryName
            : categoryName // ignore: cast_nullable_to_non_nullable
                  as String,
        regionName: null == regionName
            ? _value.regionName
            : regionName // ignore: cast_nullable_to_non_nullable
                  as String,
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
        offerCount: null == offerCount
            ? _value.offerCount
            : offerCount // ignore: cast_nullable_to_non_nullable
                  as int,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        ornamentType: freezed == ornamentType
            ? _value.ornamentType
            : ornamentType // ignore: cast_nullable_to_non_nullable
                  as String?,
        weightGrams: freezed == weightGrams
            ? _value.weightGrams
            : weightGrams // ignore: cast_nullable_to_non_nullable
                  as double?,
        purityKarat: freezed == purityKarat
            ? _value.purityKarat
            : purityKarat // ignore: cast_nullable_to_non_nullable
                  as String?,
        publishedAt: freezed == publishedAt
            ? _value.publishedAt
            : publishedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
class _$RequestListItemImpl extends _RequestListItem {
  const _$RequestListItemImpl({
    required this.id,
    this.reference,
    @JsonKey(unknownEnumValue: RequestType.findOrnament)
    required this.requestType,
    @JsonKey(unknownEnumValue: Direction.buy) required this.direction,
    @JsonKey(unknownEnumValue: RequestState.draft) required this.state,
    this.customerName = 'Unknown Customer',
    this.customerId,
    this.customerPhone,
    this.categoryName = '—',
    this.regionName = '—',
    this.indicativeValue,
    this.budgetMin,
    this.budgetMax,
    this.offerCount = 0,
    this.notes,
    this.ornamentType,
    this.weightGrams,
    this.purityKarat,
    this.publishedAt,
    this.createdAt,
  }) : super._();

  factory _$RequestListItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$RequestListItemImplFromJson(json);

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
  @JsonKey()
  final String customerName;
  @override
  final String? customerId;
  @override
  final String? customerPhone;
  @override
  @JsonKey()
  final String categoryName;
  @override
  @JsonKey()
  final String regionName;
  @override
  final double? indicativeValue;
  @override
  final double? budgetMin;
  @override
  final double? budgetMax;
  @override
  @JsonKey()
  final int offerCount;
  @override
  final String? notes;
  @override
  final String? ornamentType;
  @override
  final double? weightGrams;
  @override
  final String? purityKarat;
  @override
  final DateTime? publishedAt;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'RequestListItem(id: $id, reference: $reference, requestType: $requestType, direction: $direction, state: $state, customerName: $customerName, customerId: $customerId, customerPhone: $customerPhone, categoryName: $categoryName, regionName: $regionName, indicativeValue: $indicativeValue, budgetMin: $budgetMin, budgetMax: $budgetMax, offerCount: $offerCount, notes: $notes, ornamentType: $ornamentType, weightGrams: $weightGrams, purityKarat: $purityKarat, publishedAt: $publishedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RequestListItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.requestType, requestType) ||
                other.requestType == requestType) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.regionName, regionName) ||
                other.regionName == regionName) &&
            (identical(other.indicativeValue, indicativeValue) ||
                other.indicativeValue == indicativeValue) &&
            (identical(other.budgetMin, budgetMin) ||
                other.budgetMin == budgetMin) &&
            (identical(other.budgetMax, budgetMax) ||
                other.budgetMax == budgetMax) &&
            (identical(other.offerCount, offerCount) ||
                other.offerCount == offerCount) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.ornamentType, ornamentType) ||
                other.ornamentType == ornamentType) &&
            (identical(other.weightGrams, weightGrams) ||
                other.weightGrams == weightGrams) &&
            (identical(other.purityKarat, purityKarat) ||
                other.purityKarat == purityKarat) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
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
    customerName,
    customerId,
    customerPhone,
    categoryName,
    regionName,
    indicativeValue,
    budgetMin,
    budgetMax,
    offerCount,
    notes,
    ornamentType,
    weightGrams,
    purityKarat,
    publishedAt,
    createdAt,
  ]);

  /// Create a copy of RequestListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RequestListItemImplCopyWith<_$RequestListItemImpl> get copyWith =>
      __$$RequestListItemImplCopyWithImpl<_$RequestListItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RequestListItemImplToJson(this);
  }
}

abstract class _RequestListItem extends RequestListItem {
  const factory _RequestListItem({
    required final String id,
    final String? reference,
    @JsonKey(unknownEnumValue: RequestType.findOrnament)
    required final RequestType requestType,
    @JsonKey(unknownEnumValue: Direction.buy)
    required final Direction direction,
    @JsonKey(unknownEnumValue: RequestState.draft)
    required final RequestState state,
    final String customerName,
    final String? customerId,
    final String? customerPhone,
    final String categoryName,
    final String regionName,
    final double? indicativeValue,
    final double? budgetMin,
    final double? budgetMax,
    final int offerCount,
    final String? notes,
    final String? ornamentType,
    final double? weightGrams,
    final String? purityKarat,
    final DateTime? publishedAt,
    final DateTime? createdAt,
  }) = _$RequestListItemImpl;
  const _RequestListItem._() : super._();

  factory _RequestListItem.fromJson(Map<String, dynamic> json) =
      _$RequestListItemImpl.fromJson;

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
  String get customerName;
  @override
  String? get customerId;
  @override
  String? get customerPhone;
  @override
  String get categoryName;
  @override
  String get regionName;
  @override
  double? get indicativeValue;
  @override
  double? get budgetMin;
  @override
  double? get budgetMax;
  @override
  int get offerCount;
  @override
  String? get notes;
  @override
  String? get ornamentType;
  @override
  double? get weightGrams;
  @override
  String? get purityKarat;
  @override
  DateTime? get publishedAt;
  @override
  DateTime? get createdAt;

  /// Create a copy of RequestListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RequestListItemImplCopyWith<_$RequestListItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
