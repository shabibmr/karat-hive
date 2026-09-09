import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_exception.dart';
import 'package:kh_admin/core/list/cursor_paginated_notifier.dart';
import 'package:kh_admin/core/list/list_state.dart';
import 'package:kh_admin/core/list/paginated.dart';

class _TestItem {
  const _TestItem({required this.id, required this.name});
  final String id;
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TestItem && id == other.id && name == other.name;

  @override
  int get hashCode => Object.hash(id, name);
}

class _TestFilters {
  const _TestFilters({this.query = ''});
  final String query;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TestFilters && query == other.query;

  @override
  int get hashCode => query.hashCode;
}

class _FakeCursorNotifier
    extends CursorPaginatedNotifier<_TestItem, _TestFilters> {
  _FakeCursorNotifier({
    this.customPageSize = 20,
    this.shouldFailInitial = false,
    this.shouldFailNextPage = false,
  });

  final int customPageSize;
  bool shouldFailInitial;
  bool shouldFailNextPage;
  int fetchCallCount = 0;

  @override
  int get pageSize => customPageSize;

  @override
  _TestFilters get initialFilters => const _TestFilters();

  @override
  Object? Function(_TestItem item)? get itemKey => (item) => item.id;

  @override
  Future<Paginated<_TestItem>> fetchPage({
    required _TestFilters filters,
    String? cursor,
    int limit = 20,
  }) async {
    fetchCallCount++;
    if (cursor == null && shouldFailInitial) {
      throw const ApiException(
        statusCode: 500,
        code: 'INTERNAL_ERROR',
        message: 'Database unavailable',
      );
    }
    if (cursor != null && shouldFailNextPage) {
      throw const ApiException(
        statusCode: 500,
        code: 'INTERNAL_ERROR',
        message: 'Page fetch failed',
      );
    }

    if (cursor == null) {
      return Paginated<_TestItem>(
        items: [
          const _TestItem(id: '1', name: 'Item 1'),
          const _TestItem(id: '2', name: 'Item 2'),
        ],
        nextCursor: 'cur-2',
        totalCount: 4,
      );
    }

    if (cursor == 'cur-2') {
      return Paginated<_TestItem>(
        items: [
          const _TestItem(id: '3', name: 'Item 3'),
          const _TestItem(id: '4', name: 'Item 4'),
        ],
        nextCursor: 'cur-loop',
      );
    }

    if (cursor == 'cur-loop') {
      // Return a cycle to test cycle detection
      return Paginated<_TestItem>(
        items: [
          const _TestItem(id: '5', name: 'Item 5'),
        ],
        nextCursor: 'cur-2', // previously seen cursor!
      );
    }

    return const Paginated<_TestItem>.empty();
  }
}

void main() {
  group('CursorPaginatedNotifier & CursorListState (TR-S1-14..16)', () {
    test('enforces query limit <= 100 in build()', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final overLimitProvider =
          NotifierProvider<_FakeCursorNotifier, CursorListState<_TestItem, _TestFilters>>(
        () => _FakeCursorNotifier(customPageSize: 101),
      );

      expect(
        () => container.read(overLimitProvider),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('loads initial page and sets CursorListLoaded', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final provider =
          NotifierProvider<_FakeCursorNotifier, CursorListState<_TestItem, _TestFilters>>(
        _FakeCursorNotifier.new,
      );

      // Initial read kicks off loadInitial
      var state = container.read(provider);
      expect(state, isA<CursorListLoading<_TestItem, _TestFilters>>());
      expect(state.isLoading, isTrue);
      expect(state.errorMessage, isNull);

      await container.read(provider.notifier).loadInitial();
      state = container.read(provider);

      expect(state, isA<CursorListLoaded<_TestItem, _TestFilters>>());
      expect(state.isLoading, isFalse);
      expect(state.items, hasLength(2));
      expect(state.hasMore, isTrue);
      expect(state.nextCursor, 'cur-2');
      expect(state.totalCount, 4);
      expect(state.errorMessage, isNull);
    });

    test('state transitions loading -> error -> retry -> loaded', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final fake = _FakeCursorNotifier(shouldFailInitial: true);
      final provider =
          NotifierProvider<_FakeCursorNotifier, CursorListState<_TestItem, _TestFilters>>(
        () => fake,
      );

      await container.read(provider.notifier).loadInitial();
      var state = container.read(provider);

      expect(state, isA<CursorListError<_TestItem, _TestFilters>>());
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, 'Database unavailable');

      // Now heal the error and retry
      fake.shouldFailInitial = false;
      await container.read(provider.notifier).retry();
      state = container.read(provider);

      expect(state, isA<CursorListLoaded<_TestItem, _TestFilters>>());
      expect(state.isLoading, isFalse);
      expect(state.items, hasLength(2));
      expect(state.errorMessage, isNull);
    });

    test('impossible combination: loading && error cannot coexist', () {
      const state1 = CursorListLoading<_TestItem, _TestFilters>(filters: _TestFilters());
      expect(state1.isLoading, isTrue);
      expect(state1.errorMessage, isNull);

      const state2 = CursorListError<_TestItem, _TestFilters>(
        filters: _TestFilters(),
        errorMessage: 'Something went wrong',
      );
      expect(state2.isLoading, isFalse);
      expect(state2.errorMessage, isNotNull);

      const state3 = CursorListLoaded<_TestItem, _TestFilters>(
        filters: _TestFilters(),
        items: [],
      );
      expect(state3.isLoading, isFalse);
      expect(state3.errorMessage, isNull);
    });

    test('paginates forward with nextPage() and tracks page number', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final provider =
          NotifierProvider<_FakeCursorNotifier, CursorListState<_TestItem, _TestFilters>>(
        _FakeCursorNotifier.new,
      );

      final notifier = container.read(provider.notifier);
      await notifier.loadInitial();

      var state = container.read(provider);
      expect(state.page, 1);
      expect(state.canGoNext, isTrue);

      await notifier.nextPage();
      state = container.read(provider);

      expect(state.page, 2);
      expect(state.items.first.id, '3');
      expect(state.canGoPrevious, isTrue);

      await notifier.previousPage();
      state = container.read(provider);

      expect(state.page, 1);
      expect(state.items.first.id, '1');
    });

    test('cursor cycle halts pagination (sets nextCursor to null)', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final provider =
          NotifierProvider<_FakeCursorNotifier, CursorListState<_TestItem, _TestFilters>>(
        _FakeCursorNotifier.new,
      );

      final notifier = container.read(provider.notifier);
      await notifier.loadInitial(); // visits cur-2
      await notifier.nextPage(); // visits cur-loop
      await notifier.nextPage(); // receives cur-2 again! (cycle)

      final state = container.read(provider);
      expect(state.nextCursor, isNull);
      expect(state.hasMore, isFalse);
    });

    test('applyFilters skips refetch when filter is identical', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final fake = _FakeCursorNotifier();
      final provider =
          NotifierProvider<_FakeCursorNotifier, CursorListState<_TestItem, _TestFilters>>(
        () => fake,
      );

      final notifier = container.read(provider.notifier);
      await notifier.loadInitial();
      final callCountBefore = fake.fetchCallCount;

      // Same filter applied
      await notifier.applyFilters(const _TestFilters(query: ''));
      expect(fake.fetchCallCount, callCountBefore);

      // Different filter applied
      await notifier.applyFilters(const _TestFilters(query: 'gold'));
      expect(fake.fetchCallCount, greaterThan(callCountBefore));
    });
  });
}
