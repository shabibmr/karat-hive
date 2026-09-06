import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_core/kh_core.dart';

void main() {
  group('PagedResult', () {
    test('computes hasMore from nextCursor and items', () {
      const p1 = PagedResult(items: ['a', 'b'], nextCursor: 'c1');
      expect(p1.hasMore, isTrue);

      const p2 = PagedResult(items: ['a', 'b'], nextCursor: null);
      expect(p2.hasMore, isFalse);

      const p3 = PagedResult(items: ['a', 'b'], nextCursor: '');
      expect(p3.hasMore, isFalse);

      const p4 = PagedResult(items: <String>[], nextCursor: 'c1');
      expect(p4.hasMore, isFalse);
    });

    test('explicit hasMore overrides heuristic', () {
      const p = PagedResult(items: ['a'], nextCursor: 'c1', hasMore: false);
      expect(p.hasMore, isFalse);
    });

    test('empty factory creates empty result with hasMore=false', () {
      const p = PagedResult<int>.empty();
      expect(p.items, isEmpty);
      expect(p.nextCursor, isNull);
      expect(p.hasMore, isFalse);
    });
  });

  group('PagedListController - Initial Load', () {
    test('autoLoad loads first page on creation', () async {
      final controller = PagedListController<String>(
        fetcher: (cursor) async {
          expect(cursor, isNull);
          return const PagedResult(items: ['item1', 'item2'], nextCursor: 'cur1');
        },
        autoLoad: true,
      );

      // Await next event loop for autoLoad
      await Future<void>.delayed(Duration.zero);

      expect(controller.value.items, ['item1', 'item2']);
      expect(controller.value.nextCursor, 'cur1');
      expect(controller.value.hasMore, isTrue);
      expect(controller.value.isIdle, isTrue);
      expect(controller.value.isEmpty, isFalse);
      expect(controller.value.hasError, isFalse);

      controller.dispose();
    });

    test('autoLoad: false does not load until explicit loadInitial()', () async {
      var fetchCount = 0;
      final controller = PagedListController<String>(
        fetcher: (cursor) async {
          fetchCount++;
          return const PagedResult(items: ['a'], nextCursor: null);
        },
        autoLoad: false,
      );

      expect(controller.value.isInitial, isTrue);
      expect(fetchCount, 0);

      await controller.loadInitial();
      expect(fetchCount, 1);
      expect(controller.value.items, ['a']);
      expect(controller.value.hasMore, isFalse);

      controller.dispose();
    });

    test('handles empty first page gracefully', () async {
      final controller = PagedListController<String>(
        fetcher: (cursor) async => const PagedResult.empty(),
        autoLoad: false,
      );

      await controller.loadInitial();

      expect(controller.value.items, isEmpty);
      expect(controller.value.isEmpty, isTrue);
      expect(controller.value.hasMore, isFalse);
      expect(controller.value.isIdle, isTrue);

      controller.dispose();
    });

    test('handles error on first page load', () async {
      final controller = PagedListController<String>(
        fetcher: (cursor) async => throw Exception('Network timeout'),
        autoLoad: false,
      );

      await controller.loadInitial();

      expect(controller.value.items, isEmpty);
      expect(controller.value.hasError, isTrue);
      expect(controller.value.isInitialError, isTrue);
      expect(controller.value.isNextPageError, isFalse);

      controller.dispose();
    });
  });

  group('PagedListController - Next Page & Appending', () {
    test('loadNextPage appends items and advances cursor', () async {
      final controller = PagedListController<String>(
        fetcher: (cursor) async {
          if (cursor == null) {
            return const PagedResult(items: ['item1', 'item2'], nextCursor: 'cursor_page2');
          } else if (cursor == 'cursor_page2') {
            return const PagedResult(items: ['item3', 'item4'], nextCursor: 'cursor_page3');
          } else {
            return const PagedResult(items: ['item5'], nextCursor: null);
          }
        },
        autoLoad: false,
      );

      await controller.loadInitial();
      expect(controller.value.items, ['item1', 'item2']);
      expect(controller.value.nextCursor, 'cursor_page2');
      expect(controller.value.hasMore, isTrue);

      await controller.loadNextPage();
      expect(controller.value.items, ['item1', 'item2', 'item3', 'item4']);
      expect(controller.value.nextCursor, 'cursor_page3');
      expect(controller.value.hasMore, isTrue);

      await controller.loadNextPage();
      expect(controller.value.items, ['item1', 'item2', 'item3', 'item4', 'item5']);
      expect(controller.value.nextCursor, isNull);
      expect(controller.value.hasMore, isFalse);

      controller.dispose();
    });

    test('CRITICAL: next page failure retains loaded items and allows retry', () async {
      var attempt = 0;
      final controller = PagedListController<String>(
        fetcher: (cursor) async {
          if (cursor == null) {
            return const PagedResult(items: ['A', 'B'], nextCursor: 'cur2');
          }
          attempt++;
          if (attempt == 1) {
            throw Exception('HTTP 500 on page 2');
          }
          return const PagedResult(items: ['C', 'D'], nextCursor: null);
        },
        autoLoad: false,
      );

      await controller.loadInitial();
      expect(controller.value.items, ['A', 'B']);

      // Attempt 1 for page 2 fails
      await controller.loadNextPage();
      // Loaded items MUST BE RETAINED per Frontend Architecture §9.6
      expect(controller.value.items, ['A', 'B']);
      expect(controller.value.isNextPageError, isTrue);
      expect(controller.value.isInitialError, isFalse);
      expect(controller.value.error, isNotNull);

      // Retry loads page 2 successfully
      await controller.retry();
      expect(controller.value.items, ['A', 'B', 'C', 'D']);
      expect(controller.value.hasError, isFalse);
      expect(controller.value.hasMore, isFalse);

      controller.dispose();
    });

    test('does not load next page if hasMore is false or nextCursor is null', () async {
      var count = 0;
      final controller = PagedListController<String>(
        fetcher: (cursor) async {
          count++;
          return const PagedResult(items: ['only_item'], nextCursor: null);
        },
        autoLoad: false,
      );

      await controller.loadInitial();
      expect(count, 1);
      expect(controller.value.hasMore, isFalse);

      await controller.loadNextPage();
      expect(count, 1); // Not called

      controller.dispose();
    });
  });

  group('PagedListController - Duplicate Page & Loop Detection', () {
    test('stops pagination if server returns an already-visited cursor (cycle detection)', () async {
      var call = 0;
      final controller = PagedListController<String>(
        fetcher: (cursor) async {
          call++;
          if (call == 1) {
            return const PagedResult(items: ['page1_item'], nextCursor: 'c1');
          } else {
            // Server erroneously returns previously visited cursor 'c1'
            return const PagedResult(items: ['page2_item'], nextCursor: 'c1');
          }
        },
        autoLoad: false,
      );

      await controller.loadInitial();
      expect(controller.value.nextCursor, 'c1');

      await controller.loadNextPage();
      // Detected cursor cycle! Must stop pagination to avoid infinite loop
      expect(controller.value.hasMore, isFalse);
      expect(controller.value.nextCursor, isNull);

      controller.dispose();
    });

    test('stops pagination if server returns identical cursor to current', () async {
      final controller = PagedListController<String>(
        fetcher: (cursor) async {
          if (cursor == null) {
            return const PagedResult(items: ['1'], nextCursor: 'same_cursor');
          } else {
            // Returns same cursor as input
            return const PagedResult(items: ['2'], nextCursor: 'same_cursor');
          }
        },
        autoLoad: false,
      );

      await controller.loadInitial();
      await controller.loadNextPage();

      expect(controller.value.hasMore, isFalse);
      expect(controller.value.nextCursor, isNull);

      controller.dispose();
    });

    test('deduplicates items when itemKey extractor is provided', () async {
      final controller = PagedListController<Map<String, dynamic>>(
        fetcher: (cursor) async {
          if (cursor == null) {
            return const PagedResult(
              items: [
                {'id': '1', 'name': 'First'},
                {'id': '2', 'name': 'Second'},
              ],
              nextCursor: 'c2',
            );
          } else {
            // Server returned overlapping items
            return const PagedResult(
              items: [
                {'id': '2', 'name': 'Duplicate Second'},
                {'id': '3', 'name': 'Third'},
              ],
              nextCursor: null,
            );
          }
        },
        itemKey: (item) => item['id'],
        autoLoad: false,
      );

      await controller.loadInitial();
      expect(controller.value.items.length, 2);

      await controller.loadNextPage();
      // Should deduplicate item id '2'
      expect(controller.value.items.length, 3);
      expect(controller.value.items.map((i) => i['id']).toList(), ['1', '2', '3']);

      controller.dispose();
    });

    test('stops pagination if subsequent page returns empty items', () async {
      final controller = PagedListController<String>(
        fetcher: (cursor) async {
          if (cursor == null) {
            return const PagedResult(items: ['A'], nextCursor: 'c2');
          } else {
            return const PagedResult(items: [], nextCursor: 'c3');
          }
        },
        autoLoad: false,
      );

      await controller.loadInitial();
      expect(controller.value.hasMore, isTrue);

      await controller.loadNextPage();
      expect(controller.value.hasMore, isFalse);
      expect(controller.value.items, ['A']);

      controller.dispose();
    });
  });

  group('PagedListController - Refresh & Retry', () {
    test('refresh preserves existing items while fetching, then replaces on success', () async {
      final completer = Completer<PagedResult<String>>();
      var refreshCalled = false;

      final controller = PagedListController<String>(
        fetcher: (cursor) async {
          if (!refreshCalled) {
            return const PagedResult(items: ['old1', 'old2'], nextCursor: 'cur_old');
          } else {
            return completer.future;
          }
        },
        autoLoad: false,
      );

      await controller.loadInitial();
      expect(controller.value.items, ['old1', 'old2']);

      refreshCalled = true;
      final refreshFuture = controller.refresh();

      // During refresh: status is refreshing, old items are STILL VISIBLE
      expect(controller.value.isRefreshing, isTrue);
      expect(controller.value.items, ['old1', 'old2']);

      // Complete refresh
      completer.complete(const PagedResult(items: ['new1', 'new2', 'new3'], nextCursor: 'cur_new'));
      await refreshFuture;

      expect(controller.value.isIdle, isTrue);
      expect(controller.value.items, ['new1', 'new2', 'new3']);
      expect(controller.value.nextCursor, 'cur_new');

      controller.dispose();
    });

    test('refresh failure retains existing items', () async {
      var call = 0;
      final controller = PagedListController<String>(
        fetcher: (cursor) async {
          call++;
          if (call == 1) {
            return const PagedResult(items: ['existing'], nextCursor: null);
          } else {
            throw Exception('Refresh network error');
          }
        },
        autoLoad: false,
      );

      await controller.loadInitial();
      expect(controller.value.items, ['existing']);

      await controller.refresh();
      // Items still preserved!
      expect(controller.value.items, ['existing']);
      expect(controller.value.hasError, isTrue);

      controller.dispose();
    });

    test('retry restarts initial load on isInitialError', () async {
      var call = 0;
      final controller = PagedListController<String>(
        fetcher: (cursor) async {
          call++;
          if (call == 1) throw Exception('First try failed');
          return const PagedResult(items: ['recovered'], nextCursor: null);
        },
        autoLoad: false,
      );

      await controller.loadInitial();
      expect(controller.value.isInitialError, isTrue);

      await controller.retry();
      expect(controller.value.isIdle, isTrue);
      expect(controller.value.items, ['recovered']);

      controller.dispose();
    });
  });

  group('PagedListController - Dispose safety', () {
    test('disposed controller drops in-flight results without notifying', () async {
      final completer = Completer<PagedResult<String>>();
      final controller = PagedListController<String>(
        fetcher: (cursor) => completer.future,
        autoLoad: false,
      );

      controller.loadInitial();
      expect(controller.value.isInitialLoading, isTrue);

      controller.dispose();
      // Complete in-flight future after disposal
      completer.complete(const PagedResult(items: ['late'], nextCursor: null));
      await Future<void>.delayed(Duration.zero);

      // Should not throw or crash
      expect(controller.value.items, isEmpty);
    });
  });
}
