// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vendor_list_filters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$VendorListFilters {
  VendorVerificationState? get verificationState =>
      throw _privateConstructorUsedError;
  VendorAccountState? get accountState => throw _privateConstructorUsedError;
  String get query => throw _privateConstructorUsedError;

  /// Create a copy of VendorListFilters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VendorListFiltersCopyWith<VendorListFilters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VendorListFiltersCopyWith<$Res> {
  factory $VendorListFiltersCopyWith(
    VendorListFilters value,
    $Res Function(VendorListFilters) then,
  ) = _$VendorListFiltersCopyWithImpl<$Res, VendorListFilters>;
  @useResult
  $Res call({
    VendorVerificationState? verificationState,
    VendorAccountState? accountState,
    String query,
  });
}

/// @nodoc
class _$VendorListFiltersCopyWithImpl<$Res, $Val extends VendorListFilters>
    implements $VendorListFiltersCopyWith<$Res> {
  _$VendorListFiltersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VendorListFilters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? verificationState = freezed,
    Object? accountState = freezed,
    Object? query = null,
  }) {
    return _then(
      _value.copyWith(
            verificationState: freezed == verificationState
                ? _value.verificationState
                : verificationState // ignore: cast_nullable_to_non_nullable
                      as VendorVerificationState?,
            accountState: freezed == accountState
                ? _value.accountState
                : accountState // ignore: cast_nullable_to_non_nullable
                      as VendorAccountState?,
            query: null == query
                ? _value.query
                : query // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VendorListFiltersImplCopyWith<$Res>
    implements $VendorListFiltersCopyWith<$Res> {
  factory _$$VendorListFiltersImplCopyWith(
    _$VendorListFiltersImpl value,
    $Res Function(_$VendorListFiltersImpl) then,
  ) = __$$VendorListFiltersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    VendorVerificationState? verificationState,
    VendorAccountState? accountState,
    String query,
  });
}

/// @nodoc
class __$$VendorListFiltersImplCopyWithImpl<$Res>
    extends _$VendorListFiltersCopyWithImpl<$Res, _$VendorListFiltersImpl>
    implements _$$VendorListFiltersImplCopyWith<$Res> {
  __$$VendorListFiltersImplCopyWithImpl(
    _$VendorListFiltersImpl _value,
    $Res Function(_$VendorListFiltersImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VendorListFilters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? verificationState = freezed,
    Object? accountState = freezed,
    Object? query = null,
  }) {
    return _then(
      _$VendorListFiltersImpl(
        verificationState: freezed == verificationState
            ? _value.verificationState
            : verificationState // ignore: cast_nullable_to_non_nullable
                  as VendorVerificationState?,
        accountState: freezed == accountState
            ? _value.accountState
            : accountState // ignore: cast_nullable_to_non_nullable
                  as VendorAccountState?,
        query: null == query
            ? _value.query
            : query // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$VendorListFiltersImpl implements _VendorListFilters {
  const _$VendorListFiltersImpl({
    this.verificationState,
    this.accountState,
    this.query = '',
  });

  @override
  final VendorVerificationState? verificationState;
  @override
  final VendorAccountState? accountState;
  @override
  @JsonKey()
  final String query;

  @override
  String toString() {
    return 'VendorListFilters(verificationState: $verificationState, accountState: $accountState, query: $query)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VendorListFiltersImpl &&
            (identical(other.verificationState, verificationState) ||
                other.verificationState == verificationState) &&
            (identical(other.accountState, accountState) ||
                other.accountState == accountState) &&
            (identical(other.query, query) || other.query == query));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, verificationState, accountState, query);

  /// Create a copy of VendorListFilters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VendorListFiltersImplCopyWith<_$VendorListFiltersImpl> get copyWith =>
      __$$VendorListFiltersImplCopyWithImpl<_$VendorListFiltersImpl>(
        this,
        _$identity,
      );
}

abstract class _VendorListFilters implements VendorListFilters {
  const factory _VendorListFilters({
    final VendorVerificationState? verificationState,
    final VendorAccountState? accountState,
    final String query,
  }) = _$VendorListFiltersImpl;

  @override
  VendorVerificationState? get verificationState;
  @override
  VendorAccountState? get accountState;
  @override
  String get query;

  /// Create a copy of VendorListFilters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VendorListFiltersImplCopyWith<_$VendorListFiltersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
