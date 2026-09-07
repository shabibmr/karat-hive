import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/requests/model/request_enums.dart';
import 'package:kh_admin/features/requests/model/request_list_filters.dart';
import 'package:kh_admin/features/requests/repository/request_repository.dart';

/// Stubs [ApiClient] transport so the repository's normalization/merge logic
/// can be tested against origin/main's raw response shapes.
class _FakeApiClient extends ApiClient {
  _FakeApiClient();

  ({List<dynamic> items, Map<String, dynamic>? meta}) collectionResponse =
      (items: const [], meta: null);
  Map<String, Object?> getResponses = const {};
  Map<String, dynamic>? lastCollectionQuery;

  @override
  Future<({List<dynamic> items, Map<String, dynamic>? meta})> getCollection(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    lastCollectionQuery = queryParameters;
    return collectionResponse;
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (!getResponses.containsKey(path)) {
      throw StateError('unexpected GET $path');
    }
    return getResponses[path];
  }
}

Map<String, dynamic> _rawRow({
  required String id,
  int offerCount = 0,
  String requestType = 'FIND_ORNAMENT',
  String direction = 'BUY',
}) => {
      'id': id,
      'reference': 'KH-$id',
      'requestType': requestType,
      'direction': direction,
      'state': 'PUBLISHED',
      'notes': null,
      'weightGrams': '10.00',
      'purityKarat': '24K',
      'budgetMin': null,
      'budgetMax': '5000.00',
      'indicativeValue': '4800.00',
      'offerCount': offerCount,
      'createdAt': '2026-09-01T07:55:00.000Z',
      'customerProfile': {
        'id': 'cp-$id',
        'displayName': 'Customer $id',
        'user': {'mobileNumber': '+9715000000$id'},
      },
      'category': {'nameEn': 'Coins'},
      'region': {'nameEn': 'Sharjah'},
    };

void main() {
  late _FakeApiClient api;
  late RequestRepository repo;

  setUp(() {
    api = _FakeApiClient();
    repo = RequestRepository(api);
  });

  group('fetchRequests', () {
    test('normalizes rows and derives hasMore from the next cursor', () async {
      api.collectionResponse = (
        items: [_rawRow(id: '1'), _rawRow(id: '2')],
        meta: {'nextCursor': 'req-2'},
      );

      final page = await repo.fetchRequests();

      expect(page.items.length, 2);
      expect(page.items.first.customerName, 'Customer 1');
      expect(page.items.first.customerPhone, '+97150000001');
      expect(page.items.first.categoryName, 'Coins');
      expect(page.nextCursor, 'req-2');
      expect(page.hasMore, isTrue);
    });

    test('hasMore is false when no cursor is returned', () async {
      api.collectionResponse = (items: [_rawRow(id: '1')], meta: {});

      final page = await repo.fetchRequests();

      expect(page.hasMore, isFalse);
      expect(page.nextCursor, isNull);
    });

    test('only sends q/state/limit/cursor to the backend', () async {
      api.collectionResponse = (items: const [], meta: null);

      await repo.fetchRequests(
        filters: const RequestListFilters(
          query: 'bangle',
          state: RequestState.published,
          requestType: RequestType.goldCoin,
          direction: Direction.sell,
          categoryId: 'cat-1',
          zeroOffersOnly: true,
        ),
      );

      final q = api.lastCollectionQuery!;
      expect(q.keys, containsAll(<String>['limit', 'q', 'state']));
      expect(q.containsKey('requestType'), isFalse);
      expect(q.containsKey('direction'), isFalse);
      expect(q.containsKey('categoryId'), isFalse);
      expect(q.containsKey('zeroOffers'), isFalse);
    });

    test('applies zeroOffers / requestType / direction client-side', () async {
      api.collectionResponse = (
        items: [
          _rawRow(id: '1', offerCount: 0, requestType: 'GOLD_COIN'),
          _rawRow(id: '2', offerCount: 5, requestType: 'GOLD_COIN'),
          _rawRow(id: '3', offerCount: 0, requestType: 'FIND_ORNAMENT'),
        ],
        meta: null,
      );

      final page = await repo.fetchRequests(
        filters: const RequestListFilters(
          zeroOffersOnly: true,
          requestType: RequestType.goldCoin,
        ),
      );

      expect(page.items.map((i) => i.id), ['1']);
    });
  });

  group('fetchRequestDetail', () {
    test('merges notes from the separate endpoint', () async {
      api.getResponses = {
        '/v1/admin/requests/req-1': {
          'id': 'req-1',
          'reference': 'KH-REQ-1',
          'requestType': 'FIND_ORNAMENT',
          'direction': 'BUY',
          'state': 'PUBLISHED',
          'customerProfile': {
            'id': 'cp-1',
            'displayName': 'Aisha Rahman',
            'user': {'mobileNumber': '+971501234567'},
          },
          'category': {'nameEn': 'Bangles'},
          'region': {'nameEn': 'Dubai'},
          'media': const [],
          'offers': const [],
          'connections': const [],
        },
        '/v1/admin/requests/req-1/notes': [
          {
            'id': 'note-1',
            'text': 'Flagged by trust team',
            'authorAdminId': 'adm-1',
            'createdAt': '2026-09-02T11:00:00.000Z',
            'author': {'displayName': 'Sara Admin'},
          },
        ],
      };

      final detail = await repo.fetchRequestDetail('req-1');

      expect(detail.customer.fullName, 'Aisha Rahman');
      expect(detail.internalNotes.length, 1);
      expect(detail.internalNotes.single.authorName, 'Sara Admin');
      expect(detail.internalNotes.single.text, 'Flagged by trust team');
    });

    test('still returns the detail when the notes call fails', () async {
      api.getResponses = {
        '/v1/admin/requests/req-1': {
          'id': 'req-1',
          'requestType': 'FIND_ORNAMENT',
          'direction': 'BUY',
          'state': 'PUBLISHED',
          'customerProfile': {'id': 'cp-1', 'displayName': 'Aisha Rahman'},
          'category': {'nameEn': 'Bangles'},
          'region': {'nameEn': 'Dubai'},
        },
        // no '/notes' entry -> _FakeApiClient.get throws -> swallowed by repo
      };

      final detail = await repo.fetchRequestDetail('req-1');

      expect(detail.id, 'req-1');
      expect(detail.internalNotes, isEmpty);
    });
  });
}
