import 'package:flutter/foundation.dart';

/// Sealed lifecycle state for cursor-paginated data where `loading && error`
/// is unrepresentable (TR-S1-14).
@immutable
sealed class CursorListState<TItem, TFilters> {
  const CursorListState({required this.filters});

  /// Active filter criteria.
  final TFilters filters;

  /// Accumulated or current-page items.
  List<TItem> get items;

  /// Next cursor for subsequent page fetch.
  String? get nextCursor;

  /// Optional total count if supplied by backend.
  int? get totalCount;

  /// Whether a next page is available according to cursor.
  bool get hasMore;

  /// True during initial loading.
  bool get isLoading;

  /// True during background subsequent-page fetching.
  bool get isPaging;

  /// Alias for isPaging for backwards compatibility with UI screens.
  bool get isLoadingMore => isPaging;

  /// Error message from last failed request, or null.
  String? get errorMessage;

  /// Alias for errorMessage for backwards compatibility with UI screens.
  String? get error => errorMessage;

  /// Current 1-based page number.
  int get page => 1;

  /// History of cursors leading up to current page.
  List<String?> get cursorHistory => const [null];

  /// Whether next page can be requested.
  bool get canGoNext => hasMore && !isLoading && !isPaging;

  /// Whether previous page can be navigated to.
  bool get canGoPrevious => page > 1 && !isLoading && !isPaging;

  /// Whether more items can be loaded (appended).
  bool get canLoadMore => hasMore && !isLoading && !isPaging;
}

/// Initial state before the first page request has been made.
final class CursorListInitial<TItem, TFilters>
    extends CursorListState<TItem, TFilters> {
  const CursorListInitial({required super.filters});

  @override
  List<TItem> get items => const [];
  @override
  String? get nextCursor => null;
  @override
  int? get totalCount => null;
  @override
  bool get hasMore => false;
  @override
  bool get isLoading => false;
  @override
  bool get isPaging => false;
  @override
  String? get errorMessage => null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CursorListInitial<TItem, TFilters> &&
          runtimeType == other.runtimeType &&
          filters == other.filters;

  @override
  int get hashCode => Object.hash(runtimeType, filters);
}

/// First page load is currently in flight.
final class CursorListLoading<TItem, TFilters>
    extends CursorListState<TItem, TFilters> {
  const CursorListLoading({required super.filters});

  @override
  List<TItem> get items => const [];
  @override
  String? get nextCursor => null;
  @override
  int? get totalCount => null;
  @override
  bool get hasMore => false;
  @override
  bool get isLoading => true;
  @override
  bool get isPaging => false;
  @override
  String? get errorMessage => null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CursorListLoading<TItem, TFilters> &&
          runtimeType == other.runtimeType &&
          filters == other.filters;

  @override
  int get hashCode => Object.hash(runtimeType, filters);
}

/// Successfully loaded page state.
final class CursorListLoaded<TItem, TFilters>
    extends CursorListState<TItem, TFilters> {
  const CursorListLoaded({
    required super.filters,
    required this.items,
    this.nextCursor,
    this.totalCount,
    this.isPaging = false,
    this.page = 1,
    this.cursorHistory = const [null],
  });

  @override
  final List<TItem> items;
  @override
  final String? nextCursor;
  @override
  final int? totalCount;
  @override
  final bool isPaging;
  @override
  final int page;
  @override
  final List<String?> cursorHistory;

  @override
  bool get isLoading => false;
  @override
  String? get errorMessage => null;

  @override
  bool get hasMore =>
      nextCursor != null && nextCursor!.trim().isNotEmpty;

  CursorListLoaded<TItem, TFilters> copyWith({
    TFilters? filters,
    List<TItem>? items,
    String? nextCursor,
    bool clearCursor = false,
    int? totalCount,
    bool? isPaging,
    int? page,
    List<String?>? cursorHistory,
  }) {
    return CursorListLoaded<TItem, TFilters>(
      filters: filters ?? this.filters,
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      totalCount: totalCount ?? this.totalCount,
      isPaging: isPaging ?? this.isPaging,
      page: page ?? this.page,
      cursorHistory: cursorHistory ?? this.cursorHistory,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CursorListLoaded<TItem, TFilters> &&
          runtimeType == other.runtimeType &&
          filters == other.filters &&
          nextCursor == other.nextCursor &&
          totalCount == other.totalCount &&
          isPaging == other.isPaging &&
          page == other.page &&
          listEquals(items, other.items) &&
          listEquals(cursorHistory, other.cursorHistory);

  @override
  int get hashCode => Object.hash(
        runtimeType,
        filters,
        nextCursor,
        totalCount,
        isPaging,
        page,
        Object.hashAll(items),
        Object.hashAll(cursorHistory),
      );
}

/// Request failed with an error. Previously loaded items may be retained for retry.
final class CursorListError<TItem, TFilters>
    extends CursorListState<TItem, TFilters> {
  const CursorListError({
    required super.filters,
    required this.errorMessage,
    this.rawError,
    this.items = const [],
    this.page = 1,
    this.nextCursor,
    this.totalCount,
    this.cursorHistory = const [null],
  });

  @override
  final String errorMessage;
  final Object? rawError;
  @override
  final List<TItem> items;
  @override
  final int page;
  @override
  final String? nextCursor;
  @override
  final int? totalCount;
  @override
  final List<String?> cursorHistory;

  @override
  bool get isLoading => false;
  @override
  bool get isPaging => false;

  @override
  bool get hasMore =>
      nextCursor != null && nextCursor!.trim().isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CursorListError<TItem, TFilters> &&
          runtimeType == other.runtimeType &&
          filters == other.filters &&
          errorMessage == other.errorMessage &&
          rawError == other.rawError &&
          page == other.page &&
          nextCursor == other.nextCursor &&
          totalCount == other.totalCount &&
          listEquals(items, other.items) &&
          listEquals(cursorHistory, other.cursorHistory);

  @override
  int get hashCode => Object.hash(
        runtimeType,
        filters,
        errorMessage,
        rawError,
        page,
        nextCursor,
        totalCount,
        Object.hashAll(items),
        Object.hashAll(cursorHistory),
      );
}
