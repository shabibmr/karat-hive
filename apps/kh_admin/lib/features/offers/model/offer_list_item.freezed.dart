// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offer_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OfferListItem _$OfferListItemFromJson(Map<String, dynamic> json) {
  return _OfferListItem.fromJson(json);
}

/// @nodoc
mixin _$OfferListItem {
  String get id => throw _privateConstructorUsedError;
  String? get reference => throw _privateConstructorUsedError;
  String get requestId => throw _privateConstructorUsedError;
  String? get requestReference => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: RequestType.findOrnament)
  RequestType? get requestType => throw _privateConstructorUsedError;
  String get vendorId => throw _privateConstructorUsedError;
  String get vendorName => throw _privateConstructorUsedError;
  double get offeredPrice => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: OfferState.pending)
  OfferState get state => throw _privateConstructorUsedError;
  DateTime get submittedAt => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  String? get outcome => throw _privateConstructorUsedError;
  double? get makingCharges => throw _privateConstructorUsedError;
  double? get ratePerGram => throw _privateConstructorUsedError;

  /// Serializes this OfferListItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OfferListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OfferListItemCopyWith<OfferListItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OfferListItemCopyWith<$Res> {
  factory $OfferListItemCopyWith(
    OfferListItem value,
    $Res Function(OfferListItem) then,
  ) = _$OfferListItemCopyWithImpl<$Res, OfferListItem>;
  @useResult
  $Res call({
    String id,
    String? reference,
    String requestId,
    String? requestReference,
    @JsonKey(unknownEnumValue: RequestType.findOrnament)
    RequestType? requestType,
    String vendorId,
    String vendorName,
    double offeredPrice,
    @JsonKey(unknownEnumValue: OfferState.pending) OfferState state,
    DateTime submittedAt,
    DateTime? expiresAt,
    String? outcome,
    double? makingCharges,
    double? ratePerGram,
  });
}

/// @nodoc
class _$OfferListItemCopyWithImpl<$Res, $Val extends OfferListItem>
    implements $OfferListItemCopyWith<$Res> {
  _$OfferListItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OfferListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reference = freezed,
    Object? requestId = null,
    Object? requestReference = freezed,
    Object? requestType = freezed,
    Object? vendorId = null,
    Object? vendorName = null,
    Object? offeredPrice = null,
    Object? state = null,
    Object? submittedAt = null,
    Object? expiresAt = freezed,
    Object? outcome = freezed,
    Object? makingCharges = freezed,
    Object? ratePerGram = freezed,
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
            requestId: null == requestId
                ? _value.requestId
                : requestId // ignore: cast_nullable_to_non_nullable
                      as String,
            requestReference: freezed == requestReference
                ? _value.requestReference
                : requestReference // ignore: cast_nullable_to_non_nullable
                      as String?,
            requestType: freezed == requestType
                ? _value.requestType
                : requestType // ignore: cast_nullable_to_non_nullable
                      as RequestType?,
            vendorId: null == vendorId
                ? _value.vendorId
                : vendorId // ignore: cast_nullable_to_non_nullable
                      as String,
            vendorName: null == vendorName
                ? _value.vendorName
                : vendorName // ignore: cast_nullable_to_non_nullable
                      as String,
            offeredPrice: null == offeredPrice
                ? _value.offeredPrice
                : offeredPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            state: null == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as OfferState,
            submittedAt: null == submittedAt
                ? _value.submittedAt
                : submittedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            outcome: freezed == outcome
                ? _value.outcome
                : outcome // ignore: cast_nullable_to_non_nullable
                      as String?,
            makingCharges: freezed == makingCharges
                ? _value.makingCharges
                : makingCharges // ignore: cast_nullable_to_non_nullable
                      as double?,
            ratePerGram: freezed == ratePerGram
                ? _value.ratePerGram
                : ratePerGram // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OfferListItemImplCopyWith<$Res>
    implements $OfferListItemCopyWith<$Res> {
  factory _$$OfferListItemImplCopyWith(
    _$OfferListItemImpl value,
    $Res Function(_$OfferListItemImpl) then,
  ) = __$$OfferListItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? reference,
    String requestId,
    String? requestReference,
    @JsonKey(unknownEnumValue: RequestType.findOrnament)
    RequestType? requestType,
    String vendorId,
    String vendorName,
    double offeredPrice,
    @JsonKey(unknownEnumValue: OfferState.pending) OfferState state,
    DateTime submittedAt,
    DateTime? expiresAt,
    String? outcome,
    double? makingCharges,
    double? ratePerGram,
  });
}

/// @nodoc
class __$$OfferListItemImplCopyWithImpl<$Res>
    extends _$OfferListItemCopyWithImpl<$Res, _$OfferListItemImpl>
    implements _$$OfferListItemImplCopyWith<$Res> {
  __$$OfferListItemImplCopyWithImpl(
    _$OfferListItemImpl _value,
    $Res Function(_$OfferListItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OfferListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reference = freezed,
    Object? requestId = null,
    Object? requestReference = freezed,
    Object? requestType = freezed,
    Object? vendorId = null,
    Object? vendorName = null,
    Object? offeredPrice = null,
    Object? state = null,
    Object? submittedAt = null,
    Object? expiresAt = freezed,
    Object? outcome = freezed,
    Object? makingCharges = freezed,
    Object? ratePerGram = freezed,
  }) {
    return _then(
      _$OfferListItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        reference: freezed == reference
            ? _value.reference
            : reference // ignore: cast_nullable_to_non_nullable
                  as String?,
        requestId: null == requestId
            ? _value.requestId
            : requestId // ignore: cast_nullable_to_non_nullable
                  as String,
        requestReference: freezed == requestReference
            ? _value.requestReference
            : requestReference // ignore: cast_nullable_to_non_nullable
                  as String?,
        requestType: freezed == requestType
            ? _value.requestType
            : requestType // ignore: cast_nullable_to_non_nullable
                  as RequestType?,
        vendorId: null == vendorId
            ? _value.vendorId
            : vendorId // ignore: cast_nullable_to_non_nullable
                  as String,
        vendorName: null == vendorName
            ? _value.vendorName
            : vendorName // ignore: cast_nullable_to_non_nullable
                  as String,
        offeredPrice: null == offeredPrice
            ? _value.offeredPrice
            : offeredPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        state: null == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as OfferState,
        submittedAt: null == submittedAt
            ? _value.submittedAt
            : submittedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        outcome: freezed == outcome
            ? _value.outcome
            : outcome // ignore: cast_nullable_to_non_nullable
                  as String?,
        makingCharges: freezed == makingCharges
            ? _value.makingCharges
            : makingCharges // ignore: cast_nullable_to_non_nullable
                  as double?,
        ratePerGram: freezed == ratePerGram
            ? _value.ratePerGram
            : ratePerGram // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OfferListItemImpl implements _OfferListItem {
  const _$OfferListItemImpl({
    required this.id,
    this.reference,
    required this.requestId,
    this.requestReference,
    @JsonKey(unknownEnumValue: RequestType.findOrnament) this.requestType,
    required this.vendorId,
    required this.vendorName,
    required this.offeredPrice,
    @JsonKey(unknownEnumValue: OfferState.pending)
    this.state = OfferState.pending,
    required this.submittedAt,
    this.expiresAt,
    this.outcome,
    this.makingCharges,
    this.ratePerGram,
  });

  factory _$OfferListItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$OfferListItemImplFromJson(json);

  @override
  final String id;
  @override
  final String? reference;
  @override
  final String requestId;
  @override
  final String? requestReference;
  @override
  @JsonKey(unknownEnumValue: RequestType.findOrnament)
  final RequestType? requestType;
  @override
  final String vendorId;
  @override
  final String vendorName;
  @override
  final double offeredPrice;
  @override
  @JsonKey(unknownEnumValue: OfferState.pending)
  final OfferState state;
  @override
  final DateTime submittedAt;
  @override
  final DateTime? expiresAt;
  @override
  final String? outcome;
  @override
  final double? makingCharges;
  @override
  final double? ratePerGram;

  @override
  String toString() {
    return 'OfferListItem(id: $id, reference: $reference, requestId: $requestId, requestReference: $requestReference, requestType: $requestType, vendorId: $vendorId, vendorName: $vendorName, offeredPrice: $offeredPrice, state: $state, submittedAt: $submittedAt, expiresAt: $expiresAt, outcome: $outcome, makingCharges: $makingCharges, ratePerGram: $ratePerGram)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OfferListItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            (identical(other.requestReference, requestReference) ||
                other.requestReference == requestReference) &&
            (identical(other.requestType, requestType) ||
                other.requestType == requestType) &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.vendorName, vendorName) ||
                other.vendorName == vendorName) &&
            (identical(other.offeredPrice, offeredPrice) ||
                other.offeredPrice == offeredPrice) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.outcome, outcome) || other.outcome == outcome) &&
            (identical(other.makingCharges, makingCharges) ||
                other.makingCharges == makingCharges) &&
            (identical(other.ratePerGram, ratePerGram) ||
                other.ratePerGram == ratePerGram));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    reference,
    requestId,
    requestReference,
    requestType,
    vendorId,
    vendorName,
    offeredPrice,
    state,
    submittedAt,
    expiresAt,
    outcome,
    makingCharges,
    ratePerGram,
  );

  /// Create a copy of OfferListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OfferListItemImplCopyWith<_$OfferListItemImpl> get copyWith =>
      __$$OfferListItemImplCopyWithImpl<_$OfferListItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OfferListItemImplToJson(this);
  }
}

abstract class _OfferListItem implements OfferListItem {
  const factory _OfferListItem({
    required final String id,
    final String? reference,
    required final String requestId,
    final String? requestReference,
    @JsonKey(unknownEnumValue: RequestType.findOrnament)
    final RequestType? requestType,
    required final String vendorId,
    required final String vendorName,
    required final double offeredPrice,
    @JsonKey(unknownEnumValue: OfferState.pending) final OfferState state,
    required final DateTime submittedAt,
    final DateTime? expiresAt,
    final String? outcome,
    final double? makingCharges,
    final double? ratePerGram,
  }) = _$OfferListItemImpl;

  factory _OfferListItem.fromJson(Map<String, dynamic> json) =
      _$OfferListItemImpl.fromJson;

  @override
  String get id;
  @override
  String? get reference;
  @override
  String get requestId;
  @override
  String? get requestReference;
  @override
  @JsonKey(unknownEnumValue: RequestType.findOrnament)
  RequestType? get requestType;
  @override
  String get vendorId;
  @override
  String get vendorName;
  @override
  double get offeredPrice;
  @override
  @JsonKey(unknownEnumValue: OfferState.pending)
  OfferState get state;
  @override
  DateTime get submittedAt;
  @override
  DateTime? get expiresAt;
  @override
  String? get outcome;
  @override
  double? get makingCharges;
  @override
  double? get ratePerGram;

  /// Create a copy of OfferListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OfferListItemImplCopyWith<_$OfferListItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
