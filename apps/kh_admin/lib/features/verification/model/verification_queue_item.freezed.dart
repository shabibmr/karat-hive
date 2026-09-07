// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verification_queue_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VerificationQueueItem _$VerificationQueueItemFromJson(
  Map<String, dynamic> json,
) {
  return _VerificationQueueItem.fromJson(json);
}

/// @nodoc
mixin _$VerificationQueueItem {
  String get id => throw _privateConstructorUsedError;
  String get legalBusinessName => throw _privateConstructorUsedError;
  String get tradeLicenceNumber => throw _privateConstructorUsedError;
  double get oldestWaitingHours => throw _privateConstructorUsedError;
  String? get tradingName => throw _privateConstructorUsedError;
  DateTime? get submittedAt => throw _privateConstructorUsedError;

  /// Serializes this VerificationQueueItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VerificationQueueItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VerificationQueueItemCopyWith<VerificationQueueItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerificationQueueItemCopyWith<$Res> {
  factory $VerificationQueueItemCopyWith(
    VerificationQueueItem value,
    $Res Function(VerificationQueueItem) then,
  ) = _$VerificationQueueItemCopyWithImpl<$Res, VerificationQueueItem>;
  @useResult
  $Res call({
    String id,
    String legalBusinessName,
    String tradeLicenceNumber,
    double oldestWaitingHours,
    String? tradingName,
    DateTime? submittedAt,
  });
}

/// @nodoc
class _$VerificationQueueItemCopyWithImpl<
  $Res,
  $Val extends VerificationQueueItem
>
    implements $VerificationQueueItemCopyWith<$Res> {
  _$VerificationQueueItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VerificationQueueItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? legalBusinessName = null,
    Object? tradeLicenceNumber = null,
    Object? oldestWaitingHours = null,
    Object? tradingName = freezed,
    Object? submittedAt = freezed,
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
            tradeLicenceNumber: null == tradeLicenceNumber
                ? _value.tradeLicenceNumber
                : tradeLicenceNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            oldestWaitingHours: null == oldestWaitingHours
                ? _value.oldestWaitingHours
                : oldestWaitingHours // ignore: cast_nullable_to_non_nullable
                      as double,
            tradingName: freezed == tradingName
                ? _value.tradingName
                : tradingName // ignore: cast_nullable_to_non_nullable
                      as String?,
            submittedAt: freezed == submittedAt
                ? _value.submittedAt
                : submittedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VerificationQueueItemImplCopyWith<$Res>
    implements $VerificationQueueItemCopyWith<$Res> {
  factory _$$VerificationQueueItemImplCopyWith(
    _$VerificationQueueItemImpl value,
    $Res Function(_$VerificationQueueItemImpl) then,
  ) = __$$VerificationQueueItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String legalBusinessName,
    String tradeLicenceNumber,
    double oldestWaitingHours,
    String? tradingName,
    DateTime? submittedAt,
  });
}

/// @nodoc
class __$$VerificationQueueItemImplCopyWithImpl<$Res>
    extends
        _$VerificationQueueItemCopyWithImpl<$Res, _$VerificationQueueItemImpl>
    implements _$$VerificationQueueItemImplCopyWith<$Res> {
  __$$VerificationQueueItemImplCopyWithImpl(
    _$VerificationQueueItemImpl _value,
    $Res Function(_$VerificationQueueItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VerificationQueueItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? legalBusinessName = null,
    Object? tradeLicenceNumber = null,
    Object? oldestWaitingHours = null,
    Object? tradingName = freezed,
    Object? submittedAt = freezed,
  }) {
    return _then(
      _$VerificationQueueItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        legalBusinessName: null == legalBusinessName
            ? _value.legalBusinessName
            : legalBusinessName // ignore: cast_nullable_to_non_nullable
                  as String,
        tradeLicenceNumber: null == tradeLicenceNumber
            ? _value.tradeLicenceNumber
            : tradeLicenceNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        oldestWaitingHours: null == oldestWaitingHours
            ? _value.oldestWaitingHours
            : oldestWaitingHours // ignore: cast_nullable_to_non_nullable
                  as double,
        tradingName: freezed == tradingName
            ? _value.tradingName
            : tradingName // ignore: cast_nullable_to_non_nullable
                  as String?,
        submittedAt: freezed == submittedAt
            ? _value.submittedAt
            : submittedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VerificationQueueItemImpl implements _VerificationQueueItem {
  const _$VerificationQueueItemImpl({
    required this.id,
    required this.legalBusinessName,
    required this.tradeLicenceNumber,
    this.oldestWaitingHours = 0,
    this.tradingName,
    this.submittedAt,
  });

  factory _$VerificationQueueItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$VerificationQueueItemImplFromJson(json);

  @override
  final String id;
  @override
  final String legalBusinessName;
  @override
  final String tradeLicenceNumber;
  @override
  @JsonKey()
  final double oldestWaitingHours;
  @override
  final String? tradingName;
  @override
  final DateTime? submittedAt;

  @override
  String toString() {
    return 'VerificationQueueItem(id: $id, legalBusinessName: $legalBusinessName, tradeLicenceNumber: $tradeLicenceNumber, oldestWaitingHours: $oldestWaitingHours, tradingName: $tradingName, submittedAt: $submittedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerificationQueueItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.legalBusinessName, legalBusinessName) ||
                other.legalBusinessName == legalBusinessName) &&
            (identical(other.tradeLicenceNumber, tradeLicenceNumber) ||
                other.tradeLicenceNumber == tradeLicenceNumber) &&
            (identical(other.oldestWaitingHours, oldestWaitingHours) ||
                other.oldestWaitingHours == oldestWaitingHours) &&
            (identical(other.tradingName, tradingName) ||
                other.tradingName == tradingName) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    legalBusinessName,
    tradeLicenceNumber,
    oldestWaitingHours,
    tradingName,
    submittedAt,
  );

  /// Create a copy of VerificationQueueItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VerificationQueueItemImplCopyWith<_$VerificationQueueItemImpl>
  get copyWith =>
      __$$VerificationQueueItemImplCopyWithImpl<_$VerificationQueueItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VerificationQueueItemImplToJson(this);
  }
}

abstract class _VerificationQueueItem implements VerificationQueueItem {
  const factory _VerificationQueueItem({
    required final String id,
    required final String legalBusinessName,
    required final String tradeLicenceNumber,
    final double oldestWaitingHours,
    final String? tradingName,
    final DateTime? submittedAt,
  }) = _$VerificationQueueItemImpl;

  factory _VerificationQueueItem.fromJson(Map<String, dynamic> json) =
      _$VerificationQueueItemImpl.fromJson;

  @override
  String get id;
  @override
  String get legalBusinessName;
  @override
  String get tradeLicenceNumber;
  @override
  double get oldestWaitingHours;
  @override
  String? get tradingName;
  @override
  DateTime? get submittedAt;

  /// Create a copy of VerificationQueueItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VerificationQueueItemImplCopyWith<_$VerificationQueueItemImpl>
  get copyWith => throw _privateConstructorUsedError;
}
