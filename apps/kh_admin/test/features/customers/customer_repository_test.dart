import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/api/api_exception.dart';
import 'package:kh_admin/features/customers/model/customer_enums.dart';
import 'package:kh_admin/features/customers/model/customer_list_filters.dart';
import 'package:kh_admin/features/customers/model/customer_list_item.dart';
import 'package:kh_admin/features/customers/repository/customer_repository.dart';

class _FakeApiClient extends ApiClient {
  _FakeApiClient();

  ({List<dynamic> items, Map<String, dynamic>? meta}) collectionResponse =
      (items: const [], meta: null);
  Map<String, dynamic>? lastCollectionQuery;
  String? lastCollectionPath;

  Map<String, Object?> getResponses = {};
  String? lastGetPath;

  Map<String, Object?> postResponses = {};
  String? lastPostPath;
  dynamic lastPostData;

  bool shouldThrowOnGet = false;
  bool shouldThrowOnPost = false;
  bool shouldThrowOnCollection = false;

  @override
  Future<({List<dynamic> items, Map<String, dynamic>? meta})> getCollection(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    if (shouldThrowOnCollection) {
      throw const ApiException(
        statusCode: 500,
        code: 'INTERNAL_ERROR',
        message: 'Server error',
      );
    }
    lastCollectionPath = path;
    lastCollectionQuery = queryParameters;
    return collectionResponse;
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (shouldThrowOnGet) {
      throw const ApiException(
        statusCode: 404,
        code: 'NOT_FOUND',
        message: 'Not found',
      );
    }
    lastGetPath = path;
    if (getResponses.containsKey(path)) {
      return getResponses[path];
    }
    throw StateError('Unexpected GET $path');
  }

  @override
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (shouldThrowOnPost) {
      throw const ApiException(
        statusCode: 400,
        code: 'BAD_REQUEST',
        message: 'Bad request',
      );
    }
    lastPostPath = path;
    lastPostData = data;
    if (postResponses.containsKey(path)) {
      return postResponses[path];
    }
    return {'success': true};
  }
}

Map<String, dynamic> _rawPrismaCustomerRow({
  required String id,
  String displayName = 'Fatima Al Mansoori',
  String? email = 'fatima@example.ae',
  String? phone = '+971501234567',
  String accountState = 'ACTIVE',
  int requestCount = 3,
  DateTime? createdAt,
}) =>
    {
      'id': id,
      'userId': 'user-$id',
      'displayName': displayName,
      'createdAt': (createdAt ?? DateTime.parse('2026-08-10T12:00:00.000Z'))
          .toIso8601String(),
      'user': {
        'id': 'user-$id',
        'email': email,
        'mobileNumber': phone,
        'accountState': accountState,
        'createdAt': (createdAt ?? DateTime.parse('2026-08-10T12:00:00.000Z'))
            .toIso8601String(),
      },
      '_count': {
        'requests': requestCount,
      },
    };

void main() {
  late _FakeApiClient api;
  late CustomerRepository repo;

  setUp(() {
    api = _FakeApiClient();
    repo = CustomerRepository(api);
  });

  group('CustomerRepository.normalizeListItem', () {
    test('normalizes raw Prisma row: lifts user.accountState, user.email, and user.mobileNumber', () {
      final raw = _rawPrismaCustomerRow(
        id: 'cust-1',
        displayName: 'Sara Ahmed',
        email: 'sara@example.ae',
        phone: '+971559876543',
        accountState: 'SUSPENDED',
        requestCount: 5,
      );

      final normalized = CustomerRepository.normalizeListItem(raw);
      final item = CustomerListItem.fromJson(normalized);

      expect(item.id, 'cust-1');
      expect(item.userId, 'user-cust-1');
      expect(item.displayName, 'Sara Ahmed');
      expect(item.email, 'sara@example.ae');
      expect(item.mobileNumber, '+971559876543');
      expect(item.accountState, CustomerAccountState.suspended);
      expect(item.requestCount, 5);
      expect(item.createdAt, DateTime.parse('2026-08-10T12:00:00.000Z'));
    });

    test('handles missing user and null fields gracefully with fallback defaults', () {
      final raw = <String, dynamic>{
        'id': 'cust-2',
        'displayName': 'Guest User',
      };

      final normalized = CustomerRepository.normalizeListItem(raw);
      final item = CustomerListItem.fromJson(normalized);

      expect(item.id, 'cust-2');
      expect(item.displayName, 'Guest User');
      expect(item.email, isNull);
      expect(item.mobileNumber, isNull);
      expect(item.accountState, CustomerAccountState.active);
      expect(item.requestCount, 0);
      expect(item.createdAt, isNull);
    });

    test('counts requests from embedded requests list when _count is absent', () {
      final raw = <String, dynamic>{
        'id': 'cust-3',
        'displayName': 'Rashid',
        'requests': [
          {'id': 'req-1'},
          {'id': 'req-2'},
        ],
        'user': {
          'email': 'rashid@test.ae',
          'accountState': 'DEACTIVATED',
        },
      };

      final normalized = CustomerRepository.normalizeListItem(raw);
      final item = CustomerListItem.fromJson(normalized);

      expect(item.requestCount, 2);
      expect(item.accountState, CustomerAccountState.deactivated);
      expect(item.email, 'rashid@test.ae');
    });
  });

  group('CustomerRepository.fetchCustomers', () {
    test('builds query parameters with q, state, limit, cursor and derives hasMore', () async {
      api.collectionResponse = (
        items: [
          _rawPrismaCustomerRow(id: 'c1'),
          _rawPrismaCustomerRow(id: 'c2'),
        ],
        meta: {'nextCursor': 'cursor-c2'},
      );

      final page = await repo.fetchCustomers(
        filters: const CustomerListFilters(
          query: 'Sara',
          accountState: CustomerAccountState.suspended,
        ),
        cursor: 'cursor-c0',
        limit: 15,
      );

      expect(api.lastCollectionPath, '/v1/admin/customers');
      expect(api.lastCollectionQuery, {
        'limit': '15',
        'cursor': 'cursor-c0',
        'state': 'SUSPENDED',
        'q': 'Sara',
      });
      expect(page.items.length, 2);
      expect(page.nextCursor, 'cursor-c2');
      expect(page.hasMore, isTrue);
    });

    test('omits optional query parameters when not provided', () async {
      api.collectionResponse = (
        items: [_rawPrismaCustomerRow(id: 'c1')],
        meta: null,
      );

      final page = await repo.fetchCustomers();

      expect(api.lastCollectionQuery, {
        'limit': '20',
      });
      expect(page.hasMore, isFalse);
    });

    test('propagates collection fetch errors', () async {
      api.shouldThrowOnCollection = true;

      expect(
        () => repo.fetchCustomers(),
        throwsA(isA<ApiException>()),
      );
    });

    test('writes audit log on initial customer list load (FR-ADM-010 AC5 / ADM-INS-40)', () async {
      api.collectionResponse = (
        items: [_rawPrismaCustomerRow(id: 'c1')],
        meta: null,
      );

      await repo.fetchCustomers();

      expect(api.lastPostPath, '/v1/admin/audit-log');
      expect(api.lastPostData, isA<Map<String, dynamic>>());
      final postData = api.lastPostData as Map<String, dynamic>;
      expect(postData['action'], 'CUSTOMER_LIST_VIEWED');
      expect(postData['entityType'], 'customer_list');
      expect(postData['occurredAt'], isNotNull);
    });

    test('does not write audit log when paging with cursor', () async {
      api.collectionResponse = (
        items: [_rawPrismaCustomerRow(id: 'c2')],
        meta: null,
      );

      await repo.fetchCustomers(cursor: 'cursor-page-2');

      expect(api.lastPostPath, isNull);
    });

    test('survives audit log post error without failing customer fetch', () async {
      api.collectionResponse = (
        items: [_rawPrismaCustomerRow(id: 'c1')],
        meta: null,
      );
      api.shouldThrowOnPost = true;

      final page = await repo.fetchCustomers();

      expect(page.items, hasLength(1));
    });
  });

  group('CustomerRepository.fetchCustomerDetail', () {
    test('fetches customer detail and merges admin notes', () async {
      api.getResponses['/v1/admin/customers/cust-1'] = {
        'id': 'cust-1',
        'userId': 'user-1',
        'displayName': 'Maryam Al Hashimi',
        'createdAt': '2026-08-01T10:00:00.000Z',
        'defaultRegion': {
          'nameEn': 'Dubai',
          'nameAr': 'دبي',
        },
        'user': {
          'email': 'maryam@example.ae',
          'mobileNumber': '+971501112233',
          'accountState': 'ACTIVE',
        },
        'requests': [
          {
            'id': 'req-1',
            'reference': 'KH-REQ-001',
            'requestType': 'FIND_ORNAMENT',
            'direction': 'BUY',
            'state': 'PUBLISHED',
            'notes': '22K gold bangle',
            'budgetMin': 3000,
            'budgetMax': 5000,
            'offerCount': 2,
            'createdAt': '2026-08-02T10:00:00.000Z',
          }
        ],
      };

      api.getResponses['/v1/admin/customers/cust-1/notes'] = [
        {
          'id': 'note-1',
          'text': 'Verified proof of identity in branch',
          'createdAt': '2026-08-03T11:00:00.000Z',
          'author': {'displayName': 'Admin Omar'},
        }
      ];

      final detail = await repo.fetchCustomerDetail('cust-1');

      expect(detail.id, 'cust-1');
      expect(detail.userId, 'user-1');
      expect(detail.displayName, 'Maryam Al Hashimi');
      expect(detail.email, 'maryam@example.ae');
      expect(detail.mobileNumber, '+971501112233');
      expect(detail.accountState, CustomerAccountState.active);
      expect(detail.defaultRegion, 'Dubai');
      expect(detail.requests.length, 1);
      expect(detail.requests.first.reference, 'KH-REQ-001');
      expect(detail.requests.first.budgetMax, 5000.0);
      expect(detail.adminNotes.length, 1);
      expect(detail.adminNotes.first.authorName, 'Admin Omar');
      expect(detail.adminNotes.first.text, 'Verified proof of identity in branch');
    });

    test('propagates customer detail fetch error when customer not found', () async {
      api.shouldThrowOnGet = true;

      expect(
        () => repo.fetchCustomerDetail('unknown-id'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('CustomerRepository Actions', () {
    test('suspendCustomer posts correct payload', () async {
      api.postResponses['/v1/admin/customers/c-1/suspend'] = {'status': 'SUSPENDED'};

      await repo.suspendCustomer(
        'c-1',
        reasonCode: 'ABUSE_SUSPICION',
        reasonText: 'Multiple fraud reports lodged',
      );

      expect(api.lastPostPath, '/v1/admin/customers/c-1/suspend');
      expect(api.lastPostData, {
        'reasonCode': 'ABUSE_SUSPICION',
        'reasonText': 'Multiple fraud reports lodged',
      });
    });

    test('reactivateCustomer posts correct payload', () async {
      api.postResponses['/v1/admin/customers/c-1/reactivate'] = {'status': 'ACTIVE'};

      await repo.reactivateCustomer(
        'c-1',
        reasonText: 'Cleared following fraud review',
      );

      expect(api.lastPostPath, '/v1/admin/customers/c-1/reactivate');
      expect(api.lastPostData, {
        'reasonText': 'Cleared following fraud review',
      });
    });

    test('erasureCustomer posts to erasure route', () async {
      api.postResponses['/v1/admin/customers/c-1/erasure'] = {'completed': true};

      await repo.erasureCustomer(
        'c-1',
        reasonText: 'Customer requested PDPL erasure',
      );

      expect(api.lastPostPath, '/v1/admin/customers/c-1/erasure');
      expect(api.lastPostData, {
        'reasonText': 'Customer requested PDPL erasure',
      });
    });

    test('createAdminNote posts text and returns CustomerAdminNote', () async {
      api.postResponses['/v1/admin/customers/c-1/notes'] = {
        'id': 'note-99',
        'text': 'Customer called support desk',
        'createdAt': '2026-09-08T00:00:00.000Z',
        'author': {'displayName': 'Admin Aisha'},
      };

      final note = await repo.createAdminNote('c-1', 'Customer called support desk');

      expect(api.lastPostPath, '/v1/admin/customers/c-1/notes');
      expect(api.lastPostData, {'text': 'Customer called support desk'});
      expect(note.id, 'note-99');
      expect(note.text, 'Customer called support desk');
      expect(note.authorName, 'Admin Aisha');
    });

    test('listAdminNotes unwraps list of notes', () async {
      api.getResponses['/v1/admin/customers/c-1/notes'] = [
        {
          'id': 'n-1',
          'text': 'Note 1',
          'createdAt': '2026-09-07T10:00:00.000Z',
          'authorName': 'Admin Z',
        }
      ];

      final notes = await repo.listAdminNotes('c-1');

      expect(notes.length, 1);
      expect(notes.first.id, 'n-1');
      expect(notes.first.authorName, 'Admin Z');
    });
  });
}
