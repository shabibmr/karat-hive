// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verification_decision_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VerifyDecisionDto _$VerifyDecisionDtoFromJson(Map<String, dynamic> json) {
  return _VerifyDecisionDto.fromJson(json);
}

/// @nodoc
mixin _$VerifyDecisionDto {
  String get rationale => throw _privateConstructorUsedError;

  /// Serializes this VerifyDecisionDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VerifyDecisionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VerifyDecisionDtoCopyWith<VerifyDecisionDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerifyDecisionDtoCopyWith<$Res> {
  factory $VerifyDecisionDtoCopyWith(
    VerifyDecisionDto value,
    $Res Function(VerifyDecisionDto) then,
  ) = _$VerifyDecisionDtoCopyWithImpl<$Res, VerifyDecisionDto>;
  @useResult
  $Res call({String rationale});
}

/// @nodoc
class _$VerifyDecisionDtoCopyWithImpl<$Res, $Val extends VerifyDecisionDto>
    implements $VerifyDecisionDtoCopyWith<$Res> {
  _$VerifyDecisionDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VerifyDecisionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rationale = null}) {
    return _then(
      _value.copyWith(
            rationale: null == rationale
                ? _value.rationale
                : rationale // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VerifyDecisionDtoImplCopyWith<$Res>
    implements $VerifyDecisionDtoCopyWith<$Res> {
  factory _$$VerifyDecisionDtoImplCopyWith(
    _$VerifyDecisionDtoImpl value,
    $Res Function(_$VerifyDecisionDtoImpl) then,
  ) = __$$VerifyDecisionDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String rationale});
}

/// @nodoc
class __$$VerifyDecisionDtoImplCopyWithImpl<$Res>
    extends _$VerifyDecisionDtoCopyWithImpl<$Res, _$VerifyDecisionDtoImpl>
    implements _$$VerifyDecisionDtoImplCopyWith<$Res> {
  __$$VerifyDecisionDtoImplCopyWithImpl(
    _$VerifyDecisionDtoImpl _value,
    $Res Function(_$VerifyDecisionDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VerifyDecisionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rationale = null}) {
    return _then(
      _$VerifyDecisionDtoImpl(
        rationale: null == rationale
            ? _value.rationale
            : rationale // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VerifyDecisionDtoImpl implements _VerifyDecisionDto {
  const _$VerifyDecisionDtoImpl({required this.rationale});

  factory _$VerifyDecisionDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$VerifyDecisionDtoImplFromJson(json);

  @override
  final String rationale;

  @override
  String toString() {
    return 'VerifyDecisionDto(rationale: $rationale)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerifyDecisionDtoImpl &&
            (identical(other.rationale, rationale) ||
                other.rationale == rationale));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, rationale);

  /// Create a copy of VerifyDecisionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VerifyDecisionDtoImplCopyWith<_$VerifyDecisionDtoImpl> get copyWith =>
      __$$VerifyDecisionDtoImplCopyWithImpl<_$VerifyDecisionDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VerifyDecisionDtoImplToJson(this);
  }
}

abstract class _VerifyDecisionDto implements VerifyDecisionDto {
  const factory _VerifyDecisionDto({required final String rationale}) =
      _$VerifyDecisionDtoImpl;

  factory _VerifyDecisionDto.fromJson(Map<String, dynamic> json) =
      _$VerifyDecisionDtoImpl.fromJson;

  @override
  String get rationale;

  /// Create a copy of VerifyDecisionDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VerifyDecisionDtoImplCopyWith<_$VerifyDecisionDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RejectDecisionDto _$RejectDecisionDtoFromJson(Map<String, dynamic> json) {
  return _RejectDecisionDto.fromJson(json);
}

/// @nodoc
mixin _$RejectDecisionDto {
  String get rationale => throw _privateConstructorUsedError;

  /// Serializes this RejectDecisionDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RejectDecisionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RejectDecisionDtoCopyWith<RejectDecisionDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RejectDecisionDtoCopyWith<$Res> {
  factory $RejectDecisionDtoCopyWith(
    RejectDecisionDto value,
    $Res Function(RejectDecisionDto) then,
  ) = _$RejectDecisionDtoCopyWithImpl<$Res, RejectDecisionDto>;
  @useResult
  $Res call({String rationale});
}

/// @nodoc
class _$RejectDecisionDtoCopyWithImpl<$Res, $Val extends RejectDecisionDto>
    implements $RejectDecisionDtoCopyWith<$Res> {
  _$RejectDecisionDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RejectDecisionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rationale = null}) {
    return _then(
      _value.copyWith(
            rationale: null == rationale
                ? _value.rationale
                : rationale // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RejectDecisionDtoImplCopyWith<$Res>
    implements $RejectDecisionDtoCopyWith<$Res> {
  factory _$$RejectDecisionDtoImplCopyWith(
    _$RejectDecisionDtoImpl value,
    $Res Function(_$RejectDecisionDtoImpl) then,
  ) = __$$RejectDecisionDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String rationale});
}

/// @nodoc
class __$$RejectDecisionDtoImplCopyWithImpl<$Res>
    extends _$RejectDecisionDtoCopyWithImpl<$Res, _$RejectDecisionDtoImpl>
    implements _$$RejectDecisionDtoImplCopyWith<$Res> {
  __$$RejectDecisionDtoImplCopyWithImpl(
    _$RejectDecisionDtoImpl _value,
    $Res Function(_$RejectDecisionDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RejectDecisionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rationale = null}) {
    return _then(
      _$RejectDecisionDtoImpl(
        rationale: null == rationale
            ? _value.rationale
            : rationale // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RejectDecisionDtoImpl implements _RejectDecisionDto {
  const _$RejectDecisionDtoImpl({required this.rationale});

  factory _$RejectDecisionDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RejectDecisionDtoImplFromJson(json);

  @override
  final String rationale;

  @override
  String toString() {
    return 'RejectDecisionDto(rationale: $rationale)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RejectDecisionDtoImpl &&
            (identical(other.rationale, rationale) ||
                other.rationale == rationale));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, rationale);

  /// Create a copy of RejectDecisionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RejectDecisionDtoImplCopyWith<_$RejectDecisionDtoImpl> get copyWith =>
      __$$RejectDecisionDtoImplCopyWithImpl<_$RejectDecisionDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RejectDecisionDtoImplToJson(this);
  }
}

abstract class _RejectDecisionDto implements RejectDecisionDto {
  const factory _RejectDecisionDto({required final String rationale}) =
      _$RejectDecisionDtoImpl;

  factory _RejectDecisionDto.fromJson(Map<String, dynamic> json) =
      _$RejectDecisionDtoImpl.fromJson;

  @override
  String get rationale;

  /// Create a copy of RejectDecisionDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RejectDecisionDtoImplCopyWith<_$RejectDecisionDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RequestInfoDto _$RequestInfoDtoFromJson(Map<String, dynamic> json) {
  return _RequestInfoDto.fromJson(json);
}

/// @nodoc
mixin _$RequestInfoDto {
  String get message => throw _privateConstructorUsedError;

  /// Serializes this RequestInfoDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RequestInfoDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RequestInfoDtoCopyWith<RequestInfoDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequestInfoDtoCopyWith<$Res> {
  factory $RequestInfoDtoCopyWith(
    RequestInfoDto value,
    $Res Function(RequestInfoDto) then,
  ) = _$RequestInfoDtoCopyWithImpl<$Res, RequestInfoDto>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$RequestInfoDtoCopyWithImpl<$Res, $Val extends RequestInfoDto>
    implements $RequestInfoDtoCopyWith<$Res> {
  _$RequestInfoDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RequestInfoDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _value.copyWith(
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RequestInfoDtoImplCopyWith<$Res>
    implements $RequestInfoDtoCopyWith<$Res> {
  factory _$$RequestInfoDtoImplCopyWith(
    _$RequestInfoDtoImpl value,
    $Res Function(_$RequestInfoDtoImpl) then,
  ) = __$$RequestInfoDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$RequestInfoDtoImplCopyWithImpl<$Res>
    extends _$RequestInfoDtoCopyWithImpl<$Res, _$RequestInfoDtoImpl>
    implements _$$RequestInfoDtoImplCopyWith<$Res> {
  __$$RequestInfoDtoImplCopyWithImpl(
    _$RequestInfoDtoImpl _value,
    $Res Function(_$RequestInfoDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RequestInfoDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$RequestInfoDtoImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RequestInfoDtoImpl implements _RequestInfoDto {
  const _$RequestInfoDtoImpl({required this.message});

  factory _$RequestInfoDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RequestInfoDtoImplFromJson(json);

  @override
  final String message;

  @override
  String toString() {
    return 'RequestInfoDto(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RequestInfoDtoImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of RequestInfoDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RequestInfoDtoImplCopyWith<_$RequestInfoDtoImpl> get copyWith =>
      __$$RequestInfoDtoImplCopyWithImpl<_$RequestInfoDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RequestInfoDtoImplToJson(this);
  }
}

abstract class _RequestInfoDto implements RequestInfoDto {
  const factory _RequestInfoDto({required final String message}) =
      _$RequestInfoDtoImpl;

  factory _RequestInfoDto.fromJson(Map<String, dynamic> json) =
      _$RequestInfoDtoImpl.fromJson;

  @override
  String get message;

  /// Create a copy of RequestInfoDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RequestInfoDtoImplCopyWith<_$RequestInfoDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
