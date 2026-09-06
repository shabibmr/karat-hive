import 'dart:async';
import 'package:flutter/foundation.dart';

/// Represents a single page of items returned by a cursor-paginated API endpoint.
class PagedResult<T> {
  const PagedResult({
    required this.items,
    this.nextCursor,
    bool? hasMore,
  }) : _hasMore = hasMore;

  /// The list of items returned in this page.
  final List<T> items;

  /// The cursor to request the subsequent page. Null if no further page exists.
  final String? nextCursor;

  final bool? _hasMore;

  /// Whether additional pages are available.
  ///
  /// If explicit `hasMore` is provided, returns that value.
  /// Otherwise, evaluates to true only when items is non-empty and `nextCursor`
  /// is non-null and non-empty.
  bool get hasMore {
    if (_hasMore != null) return _hasMore;
    return items.isNotEmpty &&
        nextCursor != null &&
        nextCursor!.trim().isNotEmpty;
  }

  /// Empty page sentinel.
  const PagedResult.empty()
      : items = const [],
        nextCursor = null,
        _hasMore = false;
}

/// Lifecycle status of a paged list.
enum PagedListStatus {
  /// Initial idle state before the first page request has begun.
  initial,

  /// First page is loading (empty list being populated).
  loadingFirstPage,

  /// Subsequent page is loading (existing items are retained).
  loadingNextPage,

  /// Pull-to-refresh in progress (existing items are retained during fetch).
  refreshing,

  /// Idle state after successful load.
  idle,

  /// Error state after a failed fetch.
  error,
}

/// Immutable state representation for a cursor-paginated list.
@immutable
class PagedListState<T> {
  const PagedListState({
    this.items = const [],
    this.status = PagedListStatus.initial,
    this.nextCursor,
    this.hasMore = true,
    this.error,
    this.visitedCursors = const {},
  });

  /// The current accumulated list of items.
  final List<T> items;

  /// The current lifecycle status of the paged list.
  final PagedListStatus status;

  /// The cursor for the next page, or null if no further page exists.
  final String? nextCursor;

  /// Whether there are more items to fetch.
  final bool hasMore;

  /// Error from the most recent failed fetch, or null if healthy.
  final Object? error;

  /// Set of cursors already requested, used to detect duplicate page loops.
  final Set<String> visitedCursors;

  // Convenience state accessors:
  bool get isInitial => status == PagedListStatus.initial;
  bool get isInitialLoading => status == PagedListStatus.loadingFirstPage;
  bool get isLoadingNextPage => status == PagedListStatus.loadingNextPage;
  bool get isRefreshing => status == PagedListStatus.refreshing;
  bool get isLoading => isInitialLoading || isLoadingNextPage || isRefreshing;
  bool get isIdle => status == PagedListStatus.idle;
  bool get hasError => error != null;

  /// True if the list has completed a load and contains zero items.
  bool get isEmpty =>
      items.isEmpty &&
      !isLoading &&
      !hasError &&
      status != PagedListStatus.initial;

  /// True if the list currently has loaded items.
  bool get hasItems => items.isNotEmpty;

  /// True if next page load failed while retaining previously loaded items.
  bool get isNextPageError =>
      hasItems && hasError && status == PagedListStatus.error;

  /// True if the first page load failed with no items.
  bool get isInitialError =>
      items.isEmpty && hasError && status == PagedListStatus.error;

  PagedListState<T> copyWith({
    List<T>? items,
    PagedListStatus? status,
    String? nextCursor,
    bool clearCursor = false,
    bool? hasMore,
    Object? error,
    bool clearError = false,
    Set<String>? visitedCursors,
  }) {
    return PagedListState<T>(
      items: items ?? this.items,
      status: status ?? this.status,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      visitedCursors: visitedCursors ?? this.visitedCursors,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PagedListState<T> &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          nextCursor == other.nextCursor &&
          hasMore == other.hasMore &&
          error == other.error &&
          listEquals(items, other.items);

  @override
  int get hashCode =>
      Object.hash(status, nextCursor, hasMore, error, Object.hashAll(items));
}

/// Page fetcher function signature. Takes a cursor (null for initial/refresh)
/// and returns a [PagedResult].
typedef PageFetcher<T> = Future<PagedResult<T>> Function(String? cursor);

/// Item key extractor function signature for deduplication.
typedef ItemKeyExtractor<T> = Object? Function(T item);

/// Cursor-based pagination controller per Frontend Architecture §9.6.
///
/// Handles:
/// - Initial page load and subsequent page appending.
/// - Next cursor tracking and visited-cursor loop detection.
/// - Retry on next-page failure WITHOUT losing previously loaded items.
/// - Refresh resetting cursor to start while preserving display during fetch.
/// - Graceful handling of empty pages and duplicate page responses.
class PagedListController<T> extends ValueNotifier<PagedListState<T>> {
  PagedListController({
    required PageFetcher<T> fetcher,
    ItemKeyExtractor<T>? itemKey,
    bool autoLoad = true,
  })  : _fetcher = fetcher,
        _itemKey = itemKey,
        super(const PagedListState()) {
    if (autoLoad) {
      loadInitial();
    }
  }

  final PageFetcher<T> _fetcher;
  final ItemKeyExtractor<T>? _itemKey;

  bool _isDisposed = false;
  int _epoch = 0;

  /// Loads the first page. Clears previous items and resets cursor.
  Future<void> loadInitial() async {
    if (_isDisposed) return;

    final currentEpoch = ++_epoch;
    value = value.copyWith(
      items: const [],
      status: PagedListStatus.loadingFirstPage,
      nextCursor: null,
      hasMore: true,
      clearError: true,
      visitedCursors: const {},
    );

    try {
      final page = await _fetcher(null);
      if (_isDisposed || currentEpoch != _epoch) return;

      final nextCursor = page.nextCursor;
      final visited = <String>{};
      if (nextCursor != null && nextCursor.isNotEmpty) {
        visited.add(nextCursor);
      }

      value = PagedListState<T>(
        items: List.unmodifiable(page.items),
        status: PagedListStatus.idle,
        nextCursor: nextCursor,
        hasMore: page.hasMore,
        error: null,
        visitedCursors: visited,
      );
    } catch (e) {
      if (_isDisposed || currentEpoch != _epoch) return;

      value = value.copyWith(
        status: PagedListStatus.error,
        error: e,
        items: const [],
      );
    }
  }

  /// Loads the subsequent page using [PagedListState.nextCursor].
  ///
  /// If loading fails, previously loaded items are retained, allowing the user
  /// to retry without losing context.
  Future<void> loadNextPage() async {
    if (_isDisposed) return;
    if (!value.hasMore) return;
    if (value.isLoading) return;
    if (value.isInitialError) return;

    final cursor = value.nextCursor;
    if (cursor == null || cursor.trim().isEmpty) {
      value = value.copyWith(hasMore: false);
      return;
    }

    final currentEpoch = _epoch;
    value = value.copyWith(
      status: PagedListStatus.loadingNextPage,
      clearError: true,
    );

    try {
      final page = await _fetcher(cursor);
      if (_isDisposed || currentEpoch != _epoch) return;

      // Duplicate-page & cycle detection (Frontend Arch §9.6):
      final newCursor = page.nextCursor;
      final alreadyVisited =
          newCursor != null && value.visitedCursors.contains(newCursor);
      final isIdenticalCursor = newCursor != null && newCursor == cursor;

      // Append items, deduplicating if itemKey is configured:
      final updatedItems = List<T>.from(value.items);
      if (_itemKey != null) {
        final existingKeys = updatedItems.map(_itemKey).toSet();
        for (final item in page.items) {
          final key = _itemKey(item);
          if (!existingKeys.contains(key)) {
            updatedItems.add(item);
            existingKeys.add(key);
          }
        }
      } else {
        updatedItems.addAll(page.items);
      }

      // If page is empty or cursor looped or did not advance, stop pagination
      final isCycle = alreadyVisited || isIdenticalCursor;
      final hasMore = !isCycle && page.hasMore && page.items.isNotEmpty;

      final updatedVisited = Set<String>.from(value.visitedCursors);
      if (newCursor != null && newCursor.isNotEmpty) {
        updatedVisited.add(newCursor);
      }

      value = PagedListState<T>(
        items: List.unmodifiable(updatedItems),
        status: PagedListStatus.idle,
        nextCursor: isCycle ? null : newCursor,
        hasMore: hasMore,
        error: null,
        visitedCursors: updatedVisited,
      );
    } catch (e) {
      if (_isDisposed || currentEpoch != _epoch) return;

      // Retain previously loaded items; set error status
      value = value.copyWith(
        status: PagedListStatus.error,
        error: e,
      );
    }
  }

  /// Pull-to-refresh handler.
  ///
  /// Refreshes the list by requesting cursor=null while keeping current items
  /// visible until the new page arrives.
  Future<void> refresh() async {
    if (_isDisposed) return;

    final currentEpoch = ++_epoch;
    value = value.copyWith(
      status: PagedListStatus.refreshing,
      clearError: true,
    );

    try {
      final page = await _fetcher(null);
      if (_isDisposed || currentEpoch != _epoch) return;

      final nextCursor = page.nextCursor;
      final visited = <String>{};
      if (nextCursor != null && nextCursor.isNotEmpty) {
        visited.add(nextCursor);
      }

      value = PagedListState<T>(
        items: List.unmodifiable(page.items),
        status: PagedListStatus.idle,
        nextCursor: nextCursor,
        hasMore: page.hasMore,
        error: null,
        visitedCursors: visited,
      );
    } catch (e) {
      if (_isDisposed || currentEpoch != _epoch) return;

      // Keep existing items, but mark error
      value = value.copyWith(
        status: PagedListStatus.error,
        error: e,
      );
    }
  }

  /// Retries the failed operation.
  ///
  /// If the initial load failed, restarts initial load.
  /// If a subsequent page failed, retries loading that page with the saved cursor.
  Future<void> retry() async {
    if (value.isInitialError) {
      return loadInitial();
    } else if (value.isNextPageError) {
      return loadNextPage();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _epoch++;
    super.dispose();
  }
}
