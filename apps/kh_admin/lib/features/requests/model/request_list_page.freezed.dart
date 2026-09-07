// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_list_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RequestListPage {
  List<RequestListItem> get items => throw _privateConstructorUsedError;
  String? get nextCursor => throw _privateConstructorUsedError;
  bool? get hasMore => throw _privateConstructorUsedError;
  int? get totalCount => throw _privateConstructorUsedError;

  /// Create a copy of RequestListPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RequestListPageCopyWith<RequestListPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequestListPageCopyWith<$Res> {
  factory $RequestListPageCopyWith(
    RequestListPage value,
    $Res Function(RequestListPage) then,
  ) = _$RequestListPageCopyWithImpl<$Res, RequestListPage>;
  @useResult
  $Res call({
    List<RequestListItem> items,
    String? nextCursor,
    bool? hasMore,
    int? totalCount,
  });
}

/// @nodoc
class _$RequestListPageCopyWithImpl<$Res, $Val extends RequestListPage>
    implements $RequestListPageCopyWith<$Res> {
  _$RequestListPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RequestListPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? nextCursor = freezed,
    Object? hasMore = freezed,
    Object? totalCount = freezed,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<RequestListItem>,
            nextCursor: freezed == nextCursor
                ? _value.nextCursor
                : nextCursor // ignore: cast_nullable_to_non_nullable
                      as String?,
            hasMore: freezed == hasMore
                ? _value.hasMore
                : hasMore // ignore: cast_nullable_to_non_nullable
                      as bool?,
            totalCount: freezed == totalCount
                ? _value.totalCount
                : totalCount // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RequestListPageImplCopyWith<$Res>
    implements $RequestListPageCopyWith<$Res> {
  factory _$$RequestListPageImplCopyWith(
    _$RequestListPageImpl value,
    $Res Function(_$RequestListPageImpl) then,
  ) = __$$RequestListPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<RequestListItem> items,
    String? nextCursor,
    bool? hasMore,
    int? totalCount,
  });
}

/// @nodoc
class __$$RequestListPageImplCopyWithImpl<$Res>
    extends _$RequestListPageCopyWithImpl<$Res, _$RequestListPageImpl>
    implements _$$RequestListPageImplCopyWith<$Res> {
  __$$RequestListPageImplCopyWithImpl(
    _$RequestListPageImpl _value,
    $Res Function(_$RequestListPageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RequestListPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? nextCursor = freezed,
    Object? hasMore = freezed,
    Object? totalCount = freezed,
  }) {
    return _then(
      _$RequestListPageImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<RequestListItem>,
        nextCursor: freezed == nextCursor
            ? _value.nextCursor
            : nextCursor // ignore: cast_nullable_to_non_nullable
                  as String?,
        hasMore: freezed == hasMore
            ? _value.hasMore
            : hasMore // ignore: cast_nullable_to_non_nullable
                  as bool?,
        totalCount: freezed == totalCount
            ? _value.totalCount
            : totalCount // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$RequestListPageImpl extends _RequestListPage {
  const _$RequestListPageImpl({
    required final List<RequestListItem> items,
    this.nextCursor,
    this.hasMore,
    this.totalCount,
  }) : _items = items,
       super._();

  final List<RequestListItem> _items;
  @override
  List<RequestListItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final String? nextCursor;
  @override
  final bool? hasMore;
  @override
  final int? totalCount;

  @override
  String toString() {
    return 'RequestListPage(items: $items, nextCursor: $nextCursor, hasMore: $hasMore, totalCount: $totalCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RequestListPageImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    nextCursor,
    hasMore,
    totalCount,
  );

  /// Create a copy of RequestListPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RequestListPageImplCopyWith<_$RequestListPageImpl> get copyWith =>
      __$$RequestListPageImplCopyWithImpl<_$RequestListPageImpl>(
        this,
        _$identity,
      );
}

abstract class _RequestListPage extends RequestListPage {
  const factory _RequestListPage({
    required final List<RequestListItem> items,
    final String? nextCursor,
    final bool? hasMore,
    final int? totalCount,
  }) = _$RequestListPageImpl;
  const _RequestListPage._() : super._();

  @override
  List<RequestListItem> get items;
  @override
  String? get nextCursor;
  @override
  bool? get hasMore;
  @override
  int? get totalCount;

  /// Create a copy of RequestListPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RequestListPageImplCopyWith<_$RequestListPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
