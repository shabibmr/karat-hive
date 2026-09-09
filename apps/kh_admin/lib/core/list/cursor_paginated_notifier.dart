import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_admin/core/api/api_exception.dart';
import 'package:kh_admin/core/list/list_state.dart';
import 'package:kh_admin/core/list/paginated.dart';

/// Abstract kernel Notifier for cursor-paginated lists (TR-S1-15).
///
/// Features:
/// - Enforces maximum query limit of 100 (`limit <= 100`).
/// - Cursor cycle detection (stops paging if the backend returns a previously seen cursor).
/// - Key-based item deduplication.
/// - Catches typed [ApiException] instead of generic stringification.
/// - Mutual exclusion guarantees from [CursorListState] (loading and error cannot coexist).
abstract class CursorPaginatedNotifier<TItem, TFilters>
    extends Notifier<CursorListState<TItem, TFilters>> {
  /// Initial filter state.
  TFilters get initialFilters;

  /// Default page size (must be <= 100).
  int get pageSize => 20;

  /// Optional item key extractor for deduplication.
  Object? Function(TItem item)? get itemKey => null;

  /// Fetches a page of data for given filters and optional cursor.
  Future<Paginated<TItem>> fetchPage({
    required TFilters filters,
    String? cursor,
    int limit = 20,
  });

  final Set<String> _visitedCursors = <String>{};
  Future<void>? _inFlightLoad;
  int _epoch = 0;

  @override
  CursorListState<TItem, TFilters> build() {
    _visitedCursors.clear();
    _inFlightLoad = null;
    _epoch = 0;

    final effectiveLimit = pageSize;
    if (effectiveLimit > 100) {
      throw ArgumentError.value(
        effectiveLimit,
        'pageSize',
        'Kernel constraint: list query limit must be <= 100',
      );
    }

    Future.microtask(() {
      if (_inFlightLoad == null && state is CursorListLoading<TItem, TFilters>) {
        loadInitial();
      }
    });
    return CursorListLoading<TItem, TFilters>(filters: initialFilters);
  }

  /// Initial or reset load. Clears cursors and history.
  Future<void> loadInitial() {
    if (_inFlightLoad != null) return _inFlightLoad!;
    final future = _performLoadInitial();
    _inFlightLoad = future;
    return future;
  }

  Future<void> _performLoadInitial() async {
    final currentEpoch = ++_epoch;
    _visitedCursors.clear();

    state = CursorListLoading<TItem, TFilters>(filters: state.filters);

    try {
      final effectiveLimit = pageSize.clamp(1, 100);
      final page = await fetchPage(
        filters: state.filters,
        cursor: null,
        limit: effectiveLimit,
      );

      if (currentEpoch != _epoch) return;

      final nextCursor = page.nextCursor;
      if (nextCursor != null && nextCursor.isNotEmpty) {
        _visitedCursors.add(nextCursor);
      }

      state = CursorListLoaded<TItem, TFilters>(
        filters: state.filters,
        items: List.unmodifiable(page.items),
        nextCursor: nextCursor,
        totalCount: page.totalCount,
        page: 1,
        cursorHistory: const [null],
      );
    } on ApiException catch (e) {
      if (currentEpoch != _epoch) return;
      state = CursorListError<TItem, TFilters>(
        filters: state.filters,
        errorMessage: e.message,
        rawError: e,
      );
    } on Object catch (e) {
      if (currentEpoch != _epoch) return;
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      state = CursorListError<TItem, TFilters>(
        filters: state.filters,
        errorMessage: msg,
        rawError: e,
      );
    } finally {
      _inFlightLoad = null;
    }
  }

  /// Refresh current view. Resets pagination to start.
  Future<void> refresh() => loadInitial();

  /// Appends more items to the current view (infinite scroll style).
  Future<void> loadMore() async {
    if (!state.canLoadMore) return;
    final currentCursor = state.nextCursor;
    if (currentCursor == null || currentCursor.isEmpty) return;

    final currentEpoch = _epoch;
    final previousItems = state.items;

    if (state is CursorListLoaded<TItem, TFilters>) {
      state = (state as CursorListLoaded<TItem, TFilters>).copyWith(isPaging: true);
    }

    try {
      final effectiveLimit = pageSize.clamp(1, 100);
      final page = await fetchPage(
        filters: state.filters,
        cursor: currentCursor,
        limit: effectiveLimit,
      );

      if (currentEpoch != _epoch) return;

      final newCursor = page.nextCursor;
      final isCycle = newCursor != null && _visitedCursors.contains(newCursor);
      final isIdentical = newCursor != null && newCursor == currentCursor;
      final loopHalt = isCycle || isIdentical;

      if (newCursor != null && newCursor.isNotEmpty) {
        _visitedCursors.add(newCursor);
      }

      // Deduplicate items if itemKey extractor exists
      final updated = List<TItem>.from(previousItems);
      final extractor = itemKey;
      if (extractor != null) {
        final existingKeys = updated.map(extractor).toSet();
        for (final item in page.items) {
          final key = extractor(item);
          if (!existingKeys.contains(key)) {
            updated.add(item);
            existingKeys.add(key);
          }
        }
      } else {
        updated.addAll(page.items);
      }

      state = CursorListLoaded<TItem, TFilters>(
        filters: state.filters,
        items: List.unmodifiable(updated),
        nextCursor: loopHalt ? null : newCursor,
        totalCount: page.totalCount ?? state.totalCount,
        isPaging: false,
        page: state.page,
        cursorHistory: state.cursorHistory,
      );
    } on ApiException catch (e) {
      if (currentEpoch != _epoch) return;
      state = CursorListError<TItem, TFilters>(
        filters: state.filters,
        errorMessage: e.message,
        rawError: e,
        items: previousItems,
        page: state.page,
        nextCursor: currentCursor,
        totalCount: state.totalCount,
        cursorHistory: state.cursorHistory,
      );
    } on Object catch (e) {
      if (currentEpoch != _epoch) return;
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      state = CursorListError<TItem, TFilters>(
        filters: state.filters,
        errorMessage: msg,
        rawError: e,
        items: previousItems,
        page: state.page,
        nextCursor: currentCursor,
        totalCount: state.totalCount,
        cursorHistory: state.cursorHistory,
      );
    }
  }

  /// Navigates forward to the next page (paged table style).
  Future<void> nextPage() async {
    if (!state.canGoNext) return;
    final currentCursor = state.nextCursor;
    if (currentCursor == null || currentCursor.isEmpty) return;

    final currentEpoch = _epoch;
    final previousItems = state.items;

    if (state is CursorListLoaded<TItem, TFilters>) {
      state = (state as CursorListLoaded<TItem, TFilters>).copyWith(isPaging: true);
    }

    try {
      final effectiveLimit = pageSize.clamp(1, 100);
      final page = await fetchPage(
        filters: state.filters,
        cursor: currentCursor,
        limit: effectiveLimit,
      );

      if (currentEpoch != _epoch) return;

      final newCursor = page.nextCursor;
      final isCycle = newCursor != null && _visitedCursors.contains(newCursor);
      final loopHalt = isCycle || (newCursor != null && newCursor == currentCursor);

      if (newCursor != null && newCursor.isNotEmpty) {
        _visitedCursors.add(newCursor);
      }

      final newHistory = [...state.cursorHistory, currentCursor];
      state = CursorListLoaded<TItem, TFilters>(
        filters: state.filters,
        items: List.unmodifiable(page.items),
        nextCursor: loopHalt ? null : newCursor,
        totalCount: page.totalCount ?? state.totalCount,
        isPaging: false,
        page: state.page + 1,
        cursorHistory: newHistory,
      );
    } on ApiException catch (e) {
      if (currentEpoch != _epoch) return;
      state = CursorListError<TItem, TFilters>(
        filters: state.filters,
        errorMessage: e.message,
        rawError: e,
        items: previousItems,
        page: state.page,
        nextCursor: currentCursor,
        totalCount: state.totalCount,
        cursorHistory: state.cursorHistory,
      );
    } on Object catch (e) {
      if (currentEpoch != _epoch) return;
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      state = CursorListError<TItem, TFilters>(
        filters: state.filters,
        errorMessage: msg,
        rawError: e,
        items: previousItems,
        page: state.page,
        nextCursor: currentCursor,
        totalCount: state.totalCount,
        cursorHistory: state.cursorHistory,
      );
    }
  }

  /// Navigates back to the previous page in history.
  Future<void> previousPage() async {
    if (!state.canGoPrevious) return;
    final targetPage = state.page - 1;
    final targetCursor = state.cursorHistory[targetPage - 1];

    final currentEpoch = _epoch;
    final previousItems = state.items;

    if (state is CursorListLoaded<TItem, TFilters>) {
      state = (state as CursorListLoaded<TItem, TFilters>).copyWith(isPaging: true);
    }

    try {
      final effectiveLimit = pageSize.clamp(1, 100);
      final page = await fetchPage(
        filters: state.filters,
        cursor: targetCursor,
        limit: effectiveLimit,
      );

      if (currentEpoch != _epoch) return;

      state = CursorListLoaded<TItem, TFilters>(
        filters: state.filters,
        items: List.unmodifiable(page.items),
        nextCursor: page.nextCursor,
        totalCount: page.totalCount ?? state.totalCount,
        isPaging: false,
        page: targetPage,
        cursorHistory: state.cursorHistory.sublist(0, targetPage),
      );
    } on ApiException catch (e) {
      if (currentEpoch != _epoch) return;
      state = CursorListError<TItem, TFilters>(
        filters: state.filters,
        errorMessage: e.message,
        rawError: e,
        items: previousItems,
        page: state.page,
        nextCursor: targetCursor,
        totalCount: state.totalCount,
        cursorHistory: state.cursorHistory,
      );
    } on Object catch (e) {
      if (currentEpoch != _epoch) return;
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      state = CursorListError<TItem, TFilters>(
        filters: state.filters,
        errorMessage: msg,
        rawError: e,
        items: previousItems,
        page: state.page,
        nextCursor: targetCursor,
        totalCount: state.totalCount,
        cursorHistory: state.cursorHistory,
      );
    }
  }

  /// Updates filters. If identical to current filters, skips refetching (TR-S1-20).
  Future<void> applyFilters(TFilters newFilters) async {
    if (state.filters == newFilters) return;
    state = CursorListLoading<TItem, TFilters>(filters: newFilters);
    await loadInitial();
  }

  /// Retries a failed load or page.
  Future<void> retry() async {
    if (state is! CursorListError<TItem, TFilters>) return;
    if (state.items.isEmpty) {
      await loadInitial();
    } else {
      await nextPage();
    }
  }
}
