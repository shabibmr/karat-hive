// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RequestListState {
  List<RequestListItem> get items => throw _privateConstructorUsedError;
  RequestListFilters get filters => throw _privateConstructorUsedError;
  String? get nextCursor => throw _privateConstructorUsedError;
  bool? get hasMore => throw _privateConstructorUsedError;
  int? get totalCount => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  List<String?> get cursorHistory => throw _privateConstructorUsedError;

  /// Create a copy of RequestListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RequestListStateCopyWith<RequestListState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequestListStateCopyWith<$Res> {
  factory $RequestListStateCopyWith(
    RequestListState value,
    $Res Function(RequestListState) then,
  ) = _$RequestListStateCopyWithImpl<$Res, RequestListState>;
  @useResult
  $Res call({
    List<RequestListItem> items,
    RequestListFilters filters,
    String? nextCursor,
    bool? hasMore,
    int? totalCount,
    bool isLoading,
    bool isLoadingMore,
    String? error,
    int page,
    List<String?> cursorHistory,
  });

  $RequestListFiltersCopyWith<$Res> get filters;
}

/// @nodoc
class _$RequestListStateCopyWithImpl<$Res, $Val extends RequestListState>
    implements $RequestListStateCopyWith<$Res> {
  _$RequestListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RequestListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? filters = null,
    Object? nextCursor = freezed,
    Object? hasMore = freezed,
    Object? totalCount = freezed,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? error = freezed,
    Object? page = null,
    Object? cursorHistory = null,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<RequestListItem>,
            filters: null == filters
                ? _value.filters
                : filters // ignore: cast_nullable_to_non_nullable
                      as RequestListFilters,
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
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoadingMore: null == isLoadingMore
                ? _value.isLoadingMore
                : isLoadingMore // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            cursorHistory: null == cursorHistory
                ? _value.cursorHistory
                : cursorHistory // ignore: cast_nullable_to_non_nullable
                      as List<String?>,
          )
          as $Val,
    );
  }

  /// Create a copy of RequestListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RequestListFiltersCopyWith<$Res> get filters {
    return $RequestListFiltersCopyWith<$Res>(_value.filters, (value) {
      return _then(_value.copyWith(filters: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RequestListStateImplCopyWith<$Res>
    implements $RequestListStateCopyWith<$Res> {
  factory _$$RequestListStateImplCopyWith(
    _$RequestListStateImpl value,
    $Res Function(_$RequestListStateImpl) then,
  ) = __$$RequestListStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<RequestListItem> items,
    RequestListFilters filters,
    String? nextCursor,
    bool? hasMore,
    int? totalCount,
    bool isLoading,
    bool isLoadingMore,
    String? error,
    int page,
    List<String?> cursorHistory,
  });

  @override
  $RequestListFiltersCopyWith<$Res> get filters;
}

/// @nodoc
class __$$RequestListStateImplCopyWithImpl<$Res>
    extends _$RequestListStateCopyWithImpl<$Res, _$RequestListStateImpl>
    implements _$$RequestListStateImplCopyWith<$Res> {
  __$$RequestListStateImplCopyWithImpl(
    _$RequestListStateImpl _value,
    $Res Function(_$RequestListStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RequestListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? filters = null,
    Object? nextCursor = freezed,
    Object? hasMore = freezed,
    Object? totalCount = freezed,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? error = freezed,
    Object? page = null,
    Object? cursorHistory = null,
  }) {
    return _then(
      _$RequestListStateImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<RequestListItem>,
        filters: null == filters
            ? _value.filters
            : filters // ignore: cast_nullable_to_non_nullable
                  as RequestListFilters,
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
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoadingMore: null == isLoadingMore
            ? _value.isLoadingMore
            : isLoadingMore // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        cursorHistory: null == cursorHistory
            ? _value._cursorHistory
            : cursorHistory // ignore: cast_nullable_to_non_nullable
                  as List<String?>,
      ),
    );
  }
}

/// @nodoc

class _$RequestListStateImpl extends _RequestListState {
  const _$RequestListStateImpl({
    final List<RequestListItem> items = const [],
    this.filters = const RequestListFilters(),
    this.nextCursor,
    this.hasMore,
    this.totalCount,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.page = 1,
    final List<String?> cursorHistory = const [null],
  }) : _items = items,
       _cursorHistory = cursorHistory,
       super._();

  final List<RequestListItem> _items;
  @override
  @JsonKey()
  List<RequestListItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final RequestListFilters filters;
  @override
  final String? nextCursor;
  @override
  final bool? hasMore;
  @override
  final int? totalCount;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isLoadingMore;
  @override
  final String? error;
  @override
  @JsonKey()
  final int page;
  final List<String?> _cursorHistory;
  @override
  @JsonKey()
  List<String?> get cursorHistory {
    if (_cursorHistory is EqualUnmodifiableListView) return _cursorHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cursorHistory);
  }

  @override
  String toString() {
    return 'RequestListState(items: $items, filters: $filters, nextCursor: $nextCursor, hasMore: $hasMore, totalCount: $totalCount, isLoading: $isLoading, isLoadingMore: $isLoadingMore, error: $error, page: $page, cursorHistory: $cursorHistory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RequestListStateImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.filters, filters) || other.filters == filters) &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.page, page) || other.page == page) &&
            const DeepCollectionEquality().equals(
              other._cursorHistory,
              _cursorHistory,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    filters,
    nextCursor,
    hasMore,
    totalCount,
    isLoading,
    isLoadingMore,
    error,
    page,
    const DeepCollectionEquality().hash(_cursorHistory),
  );

  /// Create a copy of RequestListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RequestListStateImplCopyWith<_$RequestListStateImpl> get copyWith =>
      __$$RequestListStateImplCopyWithImpl<_$RequestListStateImpl>(
        this,
        _$identity,
      );
}

abstract class _RequestListState extends RequestListState {
  const factory _RequestListState({
    final List<RequestListItem> items,
    final RequestListFilters filters,
    final String? nextCursor,
    final bool? hasMore,
    final int? totalCount,
    final bool isLoading,
    final bool isLoadingMore,
    final String? error,
    final int page,
    final List<String?> cursorHistory,
  }) = _$RequestListStateImpl;
  const _RequestListState._() : super._();

  @override
  List<RequestListItem> get items;
  @override
  RequestListFilters get filters;
  @override
  String? get nextCursor;
  @override
  bool? get hasMore;
  @override
  int? get totalCount;
  @override
  bool get isLoading;
  @override
  bool get isLoadingMore;
  @override
  String? get error;
  @override
  int get page;
  @override
  List<String?> get cursorHistory;

  /// Create a copy of RequestListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RequestListStateImplCopyWith<_$RequestListStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
