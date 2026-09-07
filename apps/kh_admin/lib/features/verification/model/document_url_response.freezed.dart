// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_url_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DocumentUrlResponse _$DocumentUrlResponseFromJson(Map<String, dynamic> json) {
  return _DocumentUrlResponse.fromJson(json);
}

/// @nodoc
mixin _$DocumentUrlResponse {
  String get url => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this DocumentUrlResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DocumentUrlResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DocumentUrlResponseCopyWith<DocumentUrlResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentUrlResponseCopyWith<$Res> {
  factory $DocumentUrlResponseCopyWith(
    DocumentUrlResponse value,
    $Res Function(DocumentUrlResponse) then,
  ) = _$DocumentUrlResponseCopyWithImpl<$Res, DocumentUrlResponse>;
  @useResult
  $Res call({String url, DateTime expiresAt});
}

/// @nodoc
class _$DocumentUrlResponseCopyWithImpl<$Res, $Val extends DocumentUrlResponse>
    implements $DocumentUrlResponseCopyWith<$Res> {
  _$DocumentUrlResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DocumentUrlResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? url = null, Object? expiresAt = null}) {
    return _then(
      _value.copyWith(
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DocumentUrlResponseImplCopyWith<$Res>
    implements $DocumentUrlResponseCopyWith<$Res> {
  factory _$$DocumentUrlResponseImplCopyWith(
    _$DocumentUrlResponseImpl value,
    $Res Function(_$DocumentUrlResponseImpl) then,
  ) = __$$DocumentUrlResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String url, DateTime expiresAt});
}

/// @nodoc
class __$$DocumentUrlResponseImplCopyWithImpl<$Res>
    extends _$DocumentUrlResponseCopyWithImpl<$Res, _$DocumentUrlResponseImpl>
    implements _$$DocumentUrlResponseImplCopyWith<$Res> {
  __$$DocumentUrlResponseImplCopyWithImpl(
    _$DocumentUrlResponseImpl _value,
    $Res Function(_$DocumentUrlResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DocumentUrlResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? url = null, Object? expiresAt = null}) {
    return _then(
      _$DocumentUrlResponseImpl(
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DocumentUrlResponseImpl implements _DocumentUrlResponse {
  const _$DocumentUrlResponseImpl({required this.url, required this.expiresAt});

  factory _$DocumentUrlResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentUrlResponseImplFromJson(json);

  @override
  final String url;
  @override
  final DateTime expiresAt;

  @override
  String toString() {
    return 'DocumentUrlResponse(url: $url, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentUrlResponseImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, url, expiresAt);

  /// Create a copy of DocumentUrlResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentUrlResponseImplCopyWith<_$DocumentUrlResponseImpl> get copyWith =>
      __$$DocumentUrlResponseImplCopyWithImpl<_$DocumentUrlResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentUrlResponseImplToJson(this);
  }
}

abstract class _DocumentUrlResponse implements DocumentUrlResponse {
  const factory _DocumentUrlResponse({
    required final String url,
    required final DateTime expiresAt,
  }) = _$DocumentUrlResponseImpl;

  factory _DocumentUrlResponse.fromJson(Map<String, dynamic> json) =
      _$DocumentUrlResponseImpl.fromJson;

  @override
  String get url;
  @override
  DateTime get expiresAt;

  /// Create a copy of DocumentUrlResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DocumentUrlResponseImplCopyWith<_$DocumentUrlResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
