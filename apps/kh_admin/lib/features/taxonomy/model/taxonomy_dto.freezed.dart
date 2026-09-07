// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'taxonomy_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CreateTaxonomyDto _$CreateTaxonomyDtoFromJson(Map<String, dynamic> json) {
  return _CreateTaxonomyDto.fromJson(json);
}

/// @nodoc
mixin _$CreateTaxonomyDto {
  String? get parentId => throw _privateConstructorUsedError;
  String get nameEn => throw _privateConstructorUsedError;
  String get nameAr => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;
  int get displayOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this CreateTaxonomyDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateTaxonomyDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateTaxonomyDtoCopyWith<CreateTaxonomyDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateTaxonomyDtoCopyWith<$Res> {
  factory $CreateTaxonomyDtoCopyWith(
    CreateTaxonomyDto value,
    $Res Function(CreateTaxonomyDto) then,
  ) = _$CreateTaxonomyDtoCopyWithImpl<$Res, CreateTaxonomyDto>;
  @useResult
  $Res call({
    String? parentId,
    String nameEn,
    String nameAr,
    String? icon,
    int displayOrder,
    bool isActive,
  });
}

/// @nodoc
class _$CreateTaxonomyDtoCopyWithImpl<$Res, $Val extends CreateTaxonomyDto>
    implements $CreateTaxonomyDtoCopyWith<$Res> {
  _$CreateTaxonomyDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateTaxonomyDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? parentId = freezed,
    Object? nameEn = null,
    Object? nameAr = null,
    Object? icon = freezed,
    Object? displayOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            parentId: freezed == parentId
                ? _value.parentId
                : parentId // ignore: cast_nullable_to_non_nullable
                      as String?,
            nameEn: null == nameEn
                ? _value.nameEn
                : nameEn // ignore: cast_nullable_to_non_nullable
                      as String,
            nameAr: null == nameAr
                ? _value.nameAr
                : nameAr // ignore: cast_nullable_to_non_nullable
                      as String,
            icon: freezed == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String?,
            displayOrder: null == displayOrder
                ? _value.displayOrder
                : displayOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateTaxonomyDtoImplCopyWith<$Res>
    implements $CreateTaxonomyDtoCopyWith<$Res> {
  factory _$$CreateTaxonomyDtoImplCopyWith(
    _$CreateTaxonomyDtoImpl value,
    $Res Function(_$CreateTaxonomyDtoImpl) then,
  ) = __$$CreateTaxonomyDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? parentId,
    String nameEn,
    String nameAr,
    String? icon,
    int displayOrder,
    bool isActive,
  });
}

/// @nodoc
class __$$CreateTaxonomyDtoImplCopyWithImpl<$Res>
    extends _$CreateTaxonomyDtoCopyWithImpl<$Res, _$CreateTaxonomyDtoImpl>
    implements _$$CreateTaxonomyDtoImplCopyWith<$Res> {
  __$$CreateTaxonomyDtoImplCopyWithImpl(
    _$CreateTaxonomyDtoImpl _value,
    $Res Function(_$CreateTaxonomyDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateTaxonomyDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? parentId = freezed,
    Object? nameEn = null,
    Object? nameAr = null,
    Object? icon = freezed,
    Object? displayOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _$CreateTaxonomyDtoImpl(
        parentId: freezed == parentId
            ? _value.parentId
            : parentId // ignore: cast_nullable_to_non_nullable
                  as String?,
        nameEn: null == nameEn
            ? _value.nameEn
            : nameEn // ignore: cast_nullable_to_non_nullable
                  as String,
        nameAr: null == nameAr
            ? _value.nameAr
            : nameAr // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: freezed == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String?,
        displayOrder: null == displayOrder
            ? _value.displayOrder
            : displayOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateTaxonomyDtoImpl implements _CreateTaxonomyDto {
  const _$CreateTaxonomyDtoImpl({
    this.parentId,
    required this.nameEn,
    required this.nameAr,
    this.icon,
    this.displayOrder = 0,
    this.isActive = true,
  });

  factory _$CreateTaxonomyDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateTaxonomyDtoImplFromJson(json);

  @override
  final String? parentId;
  @override
  final String nameEn;
  @override
  final String nameAr;
  @override
  final String? icon;
  @override
  @JsonKey()
  final int displayOrder;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'CreateTaxonomyDto(parentId: $parentId, nameEn: $nameEn, nameAr: $nameAr, icon: $icon, displayOrder: $displayOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateTaxonomyDtoImpl &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    parentId,
    nameEn,
    nameAr,
    icon,
    displayOrder,
    isActive,
  );

  /// Create a copy of CreateTaxonomyDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateTaxonomyDtoImplCopyWith<_$CreateTaxonomyDtoImpl> get copyWith =>
      __$$CreateTaxonomyDtoImplCopyWithImpl<_$CreateTaxonomyDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateTaxonomyDtoImplToJson(this);
  }
}

abstract class _CreateTaxonomyDto implements CreateTaxonomyDto {
  const factory _CreateTaxonomyDto({
    final String? parentId,
    required final String nameEn,
    required final String nameAr,
    final String? icon,
    final int displayOrder,
    final bool isActive,
  }) = _$CreateTaxonomyDtoImpl;

  factory _CreateTaxonomyDto.fromJson(Map<String, dynamic> json) =
      _$CreateTaxonomyDtoImpl.fromJson;

  @override
  String? get parentId;
  @override
  String get nameEn;
  @override
  String get nameAr;
  @override
  String? get icon;
  @override
  int get displayOrder;
  @override
  bool get isActive;

  /// Create a copy of CreateTaxonomyDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateTaxonomyDtoImplCopyWith<_$CreateTaxonomyDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateTaxonomyDto _$UpdateTaxonomyDtoFromJson(Map<String, dynamic> json) {
  return _UpdateTaxonomyDto.fromJson(json);
}

/// @nodoc
mixin _$UpdateTaxonomyDto {
  String? get parentId => throw _privateConstructorUsedError;
  String? get nameEn => throw _privateConstructorUsedError;
  String? get nameAr => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;
  int? get displayOrder => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;

  /// Serializes this UpdateTaxonomyDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateTaxonomyDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateTaxonomyDtoCopyWith<UpdateTaxonomyDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateTaxonomyDtoCopyWith<$Res> {
  factory $UpdateTaxonomyDtoCopyWith(
    UpdateTaxonomyDto value,
    $Res Function(UpdateTaxonomyDto) then,
  ) = _$UpdateTaxonomyDtoCopyWithImpl<$Res, UpdateTaxonomyDto>;
  @useResult
  $Res call({
    String? parentId,
    String? nameEn,
    String? nameAr,
    String? icon,
    int? displayOrder,
    bool? isActive,
  });
}

/// @nodoc
class _$UpdateTaxonomyDtoCopyWithImpl<$Res, $Val extends UpdateTaxonomyDto>
    implements $UpdateTaxonomyDtoCopyWith<$Res> {
  _$UpdateTaxonomyDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateTaxonomyDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? parentId = freezed,
    Object? nameEn = freezed,
    Object? nameAr = freezed,
    Object? icon = freezed,
    Object? displayOrder = freezed,
    Object? isActive = freezed,
  }) {
    return _then(
      _value.copyWith(
            parentId: freezed == parentId
                ? _value.parentId
                : parentId // ignore: cast_nullable_to_non_nullable
                      as String?,
            nameEn: freezed == nameEn
                ? _value.nameEn
                : nameEn // ignore: cast_nullable_to_non_nullable
                      as String?,
            nameAr: freezed == nameAr
                ? _value.nameAr
                : nameAr // ignore: cast_nullable_to_non_nullable
                      as String?,
            icon: freezed == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String?,
            displayOrder: freezed == displayOrder
                ? _value.displayOrder
                : displayOrder // ignore: cast_nullable_to_non_nullable
                      as int?,
            isActive: freezed == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UpdateTaxonomyDtoImplCopyWith<$Res>
    implements $UpdateTaxonomyDtoCopyWith<$Res> {
  factory _$$UpdateTaxonomyDtoImplCopyWith(
    _$UpdateTaxonomyDtoImpl value,
    $Res Function(_$UpdateTaxonomyDtoImpl) then,
  ) = __$$UpdateTaxonomyDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? parentId,
    String? nameEn,
    String? nameAr,
    String? icon,
    int? displayOrder,
    bool? isActive,
  });
}

/// @nodoc
class __$$UpdateTaxonomyDtoImplCopyWithImpl<$Res>
    extends _$UpdateTaxonomyDtoCopyWithImpl<$Res, _$UpdateTaxonomyDtoImpl>
    implements _$$UpdateTaxonomyDtoImplCopyWith<$Res> {
  __$$UpdateTaxonomyDtoImplCopyWithImpl(
    _$UpdateTaxonomyDtoImpl _value,
    $Res Function(_$UpdateTaxonomyDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateTaxonomyDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? parentId = freezed,
    Object? nameEn = freezed,
    Object? nameAr = freezed,
    Object? icon = freezed,
    Object? displayOrder = freezed,
    Object? isActive = freezed,
  }) {
    return _then(
      _$UpdateTaxonomyDtoImpl(
        parentId: freezed == parentId
            ? _value.parentId
            : parentId // ignore: cast_nullable_to_non_nullable
                  as String?,
        nameEn: freezed == nameEn
            ? _value.nameEn
            : nameEn // ignore: cast_nullable_to_non_nullable
                  as String?,
        nameAr: freezed == nameAr
            ? _value.nameAr
            : nameAr // ignore: cast_nullable_to_non_nullable
                  as String?,
        icon: freezed == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String?,
        displayOrder: freezed == displayOrder
            ? _value.displayOrder
            : displayOrder // ignore: cast_nullable_to_non_nullable
                  as int?,
        isActive: freezed == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateTaxonomyDtoImpl implements _UpdateTaxonomyDto {
  const _$UpdateTaxonomyDtoImpl({
    this.parentId,
    this.nameEn,
    this.nameAr,
    this.icon,
    this.displayOrder,
    this.isActive,
  });

  factory _$UpdateTaxonomyDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateTaxonomyDtoImplFromJson(json);

  @override
  final String? parentId;
  @override
  final String? nameEn;
  @override
  final String? nameAr;
  @override
  final String? icon;
  @override
  final int? displayOrder;
  @override
  final bool? isActive;

  @override
  String toString() {
    return 'UpdateTaxonomyDto(parentId: $parentId, nameEn: $nameEn, nameAr: $nameAr, icon: $icon, displayOrder: $displayOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateTaxonomyDtoImpl &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    parentId,
    nameEn,
    nameAr,
    icon,
    displayOrder,
    isActive,
  );

  /// Create a copy of UpdateTaxonomyDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateTaxonomyDtoImplCopyWith<_$UpdateTaxonomyDtoImpl> get copyWith =>
      __$$UpdateTaxonomyDtoImplCopyWithImpl<_$UpdateTaxonomyDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateTaxonomyDtoImplToJson(this);
  }
}

abstract class _UpdateTaxonomyDto implements UpdateTaxonomyDto {
  const factory _UpdateTaxonomyDto({
    final String? parentId,
    final String? nameEn,
    final String? nameAr,
    final String? icon,
    final int? displayOrder,
    final bool? isActive,
  }) = _$UpdateTaxonomyDtoImpl;

  factory _UpdateTaxonomyDto.fromJson(Map<String, dynamic> json) =
      _$UpdateTaxonomyDtoImpl.fromJson;

  @override
  String? get parentId;
  @override
  String? get nameEn;
  @override
  String? get nameAr;
  @override
  String? get icon;
  @override
  int? get displayOrder;
  @override
  bool? get isActive;

  /// Create a copy of UpdateTaxonomyDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateTaxonomyDtoImplCopyWith<_$UpdateTaxonomyDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
