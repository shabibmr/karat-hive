import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/connections/model/connection_enums.dart';
import 'package:kh_admin/features/connections/model/connection_list_filters.dart';
import 'package:kh_admin/features/connections/model/connection_list_item.dart';
import 'package:kh_admin/features/connections/repository/connection_repository.dart';

void main() {
  Map<String, dynamic> rawConnectionRow({
    required String id,
    String state = 'ACTIVE',
    String offeredPrice = '18500.00',
    String? customerName = 'Fatima Al Mansoori',
    String? vendorName = 'Damani Jewellers LLC',
    String createdAt = '2026-09-01T10:00:00.000Z',
    List<Map<String, dynamic>> contactEvents = const [],
  }) {
    return {
      'id': id,
      'requestId': 'req-$id',
      'offerId': 'off-$id',
      'customerProfileId': 'cust-$id',
      'vendorProfileId': 'ven-$id',
      'state': state,
      'identityRevealedAt': '2026-09-01T10:00:00.000Z',
      'closedAt': null,
      'closedBy': null,
      'createdAt': createdAt,
      'updatedAt': createdAt,
      'request': <String, dynamic>{
        'id': 'req-$id',
        'reference': 'KH-RQ-2026-99',
        'requestType': 'FIND_ORNAMENT',
        'notes': 'Looking for wedding necklace',
        'indicativeValue': '20000.00',
        'weightGrams': '45.50',
        'purityKarat': 'K22',
        'customerProfile': <String, dynamic>{
          'id': 'cust-$id',
          'displayName': customerName,
          'user': <String, dynamic>{
            'id': 'user-cust-$id',
            'email': 'fatima@example.ae',
            'mobileNumber': '+971501234567',
          },
        },
      },
      'offer': <String, dynamic>{
        'id': 'off-$id',
        'offeredPrice': offeredPrice,
        'makingCharges': '500.00',
        'ratePerGram': '285.00',
        'validityHours': 24,
        'expiresAt': '2026-09-02T10:00:00.000Z',
        'deliveryTimeframe': '3 business days',
        'warrantyTerms': 'Full lifetime polish',
        'vendorNote': 'Includes velvet gift box',
        'vendorProfile': <String, dynamic>{
          'id': 'ven-$id',
          'legalBusinessName': vendorName,
          'tradingName': 'Damani Dubai',
          'tradeLicenceNumber': 'TL-102938',
          'aggregateRating': '4.8',
          'user': <String, dynamic>{
            'id': 'user-ven-$id',
            'email': 'contact@damani.ae',
            'mobileNumber': '+97145551234',
          },
        },
      },
      'contactEvents': contactEvents,
    };
  }

  ApiClient buildClient({
    void Function(RequestOptions)? onPostClose,
    void Function(RequestOptions)? onPostNote,
  }) {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final path = options.path;

          if (path == '/v1/admin/connections') {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': {
                    'data': [
                      rawConnectionRow(
                        id: 'conn-1',
                        state: 'ACTIVE',
                        createdAt: '2026-08-01T10:00:00.000Z',
                        contactEvents: [],
                      ),
                      rawConnectionRow(
                        id: 'conn-2',
                        state: 'CLOSED',
                        offeredPrice: '25000.00',
                        contactEvents: [
                          {
                            'id': 'ce-1',
                            'connectionId': 'conn-2',
                            'channel': 'WHATSAPP',
                            'initiatedBy': 'CUSTOMER',
                            'occurredAt': '2026-08-02T11:00:00.000Z',
                          }
                        ],
                      ),
                    ],
                    'nextCursor': 'conn-2',
                  },
                  'meta': {'nextCursor': 'conn-2'},
                },
              ),
            );
          }

          if (path == '/v1/admin/connections/conn-1') {
            final row = rawConnectionRow(
              id: 'conn-1',
              state: 'ACTIVE',
              contactEvents: [
                {
                  'id': 'ce-1',
                  'connectionId': 'conn-1',
                  'channel': 'WHATSAPP',
                  'initiatedBy': 'CUSTOMER',
                  'occurredAt': '2026-08-01T12:00:00.000Z',
                }
              ],
            );
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'data': row},
              ),
            );
          }

          if (path == '/v1/admin/connections/conn-1/close' && options.method == 'POST') {
            onPostClose?.call(options);
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': {
                    'id': 'conn-1',
                    'state': 'CLOSED',
                    'closedAt': '2026-09-08T00:00:00.000Z',
                    'closedBy': 'ADMIN',
                  },
                },
              ),
            );
          }

          if (path == '/v1/admin/connections/conn-1/notes' && options.method == 'GET') {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': [
                    {
                      'id': 'note-1',
                      'author': {'displayName': 'Super Admin'},
                      'text': 'Initial customer contact verified.',
                      'createdAt': '2026-08-01T15:00:00.000Z',
                    },
                  ],
                },
              ),
            );
          }

          if (path == '/v1/admin/connections/conn-1/notes' && options.method == 'POST') {
            onPostNote?.call(options);
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'data': {
                    'id': 'note-2',
                    'text': options.data['text'],
                    'authorAdminId': 'admin-42',
                    'createdAt': '2026-08-02T10:00:00.000Z',
                  },
                },
              ),
            );
          }

          return handler.next(options);
        },
      ),
    );

    return ApiClient(baseUrl: 'http://localhost:3000', dio: dio);
  }

  group('ConnectionRepository - fetchConnections normalization', () {
    test('normalizes raw Prisma row with unmasked parties, decimals, and dates', () async {
      final repo = ConnectionRepository(buildClient());
      final page = await repo.fetchConnections();

      expect(page.items, hasLength(2));
      final first = page.items.first;
      expect(first.id, 'conn-1');
      expect(first.requestId, 'req-conn-1');
      expect(first.offerId, 'off-conn-1');
      expect(first.customerName, 'Fatima Al Mansoori');
      expect(first.vendorName, 'Damani Jewellers LLC');
      expect(first.agreedPriceAed, 18500.0);
      expect(first.requestType, 'FIND_ORNAMENT');
      expect(first.state, ConnectionState.active);
      expect(first.contactEventsCount, 0);
      expect(first.lastContactAt, isNull);
      expect(first.hasNoContact48h, isTrue); // created in Aug 2026, no contact events

      final second = page.items[1];
      expect(second.id, 'conn-2');
      expect(second.state, ConnectionState.closed);
      expect(second.agreedPriceAed, 25000.0);
      expect(second.contactEventsCount, 1);
      expect(second.lastContactAt, isNotNull);
      expect(second.hasNoContact48h, isFalse); // closed state
    });

    test('falls back to user email and tradingName when display names are absent', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': [
                    rawConnectionRow(
                      id: 'conn-fallback',
                      customerName: null,
                      vendorName: null,
                    ),
                  ],
                },
              ),
            );
          },
        ),
      );

      final repo = ConnectionRepository(ApiClient(baseUrl: 'http://localhost:3000', dio: dio));
      final page = await repo.fetchConnections();
      expect(page.items, hasLength(1));
      expect(page.items.first.customerName, 'fatima@example.ae');
      expect(page.items.first.vendorName, 'Damani Dubai');
    });

    test('handles cursor pagination and nextCursor', () async {
      final repo = ConnectionRepository(buildClient());
      final page = await repo.fetchConnections();

      expect(page.nextCursor, 'conn-2');
      expect(page.hasMore, isTrue);
      expect(page.canLoadMore, isTrue);
    });

    test('applies client-side query search', () async {
      final repo = ConnectionRepository(buildClient());
      final searchResult = await repo.fetchConnections(
        filters: const ConnectionListFilters(query: '25000'),
      );
      expect(searchResult.items.map((e) => e.id), ['conn-2']);
    });
  });

  group('ConnectionRepository - 48h SLA Calculation', () {
    final now = DateTime(2026, 9, 8, 12, 0);

    test('is true when active, created > 48h ago, and 0 contact events', () {
      final createdAt = now.subtract(const Duration(hours: 49));
      final result = ConnectionListItem.calculateHasNoContact48h(
        state: ConnectionState.active,
        createdAt: createdAt,
        contactEventsCount: 0,
        lastContactAt: null,
        now: now,
      );
      expect(result, isTrue);
    });

    test('is true when active, created > 48h ago, and lastContactAt is null', () {
      final createdAt = now.subtract(const Duration(hours: 50));
      final result = ConnectionListItem.calculateHasNoContact48h(
        state: ConnectionState.active,
        createdAt: createdAt,
        contactEventsCount: 1, // corrupted count but null lastContactAt
        lastContactAt: null,
        now: now,
      );
      expect(result, isTrue);
    });

    test('is false when active, created > 48h ago, but contact event occurred', () {
      final createdAt = now.subtract(const Duration(hours: 72));
      final lastContact = now.subtract(const Duration(hours: 40));
      final result = ConnectionListItem.calculateHasNoContact48h(
        state: ConnectionState.active,
        createdAt: createdAt,
        contactEventsCount: 2,
        lastContactAt: lastContact,
        now: now,
      );
      expect(result, isFalse);
    });

    test('is false when active but created < 48h ago (within introduction window)', () {
      final createdAt = now.subtract(const Duration(hours: 24));
      final result = ConnectionListItem.calculateHasNoContact48h(
        state: ConnectionState.active,
        createdAt: createdAt,
        contactEventsCount: 0,
        lastContactAt: null,
        now: now,
      );
      expect(result, isFalse);
    });

    test('is false when state is closed, even if created > 48h ago and 0 contact events', () {
      final createdAt = now.subtract(const Duration(hours: 100));
      final result = ConnectionListItem.calculateHasNoContact48h(
        state: ConnectionState.closed,
        createdAt: createdAt,
        contactEventsCount: 0,
        lastContactAt: null,
        now: now,
      );
      expect(result, isFalse);
    });
  });

  group('ConnectionRepository - fetchConnectionDetail and Close Action', () {
    test('fetches full detail and merges supplementary admin notes', () async {
      final repo = ConnectionRepository(buildClient());
      final detail = await repo.fetchConnectionDetail('conn-1');

      expect(detail.id, 'conn-1');
      expect(detail.state, ConnectionState.active);
      expect(detail.customer?.displayName, 'Fatima Al Mansoori');
      expect(detail.customer?.email, 'fatima@example.ae');
      expect(detail.vendor?.legalBusinessName, 'Damani Jewellers LLC');
      expect(detail.offer?.agreedPriceAed, 18500.0);
      expect(detail.offer?.deliveryTimeframe, '3 business days');
      expect(detail.request?.requestType, 'FIND_ORNAMENT');
      expect(detail.contactEvents, hasLength(1));
      expect(detail.contactEvents.first.channel, 'WHATSAPP');
      expect(detail.adminNotes, hasLength(1));
      expect(detail.adminNotes.first.author, 'Super Admin');
      expect(detail.adminNotes.first.text, 'Initial customer contact verified.');
    });

    test('closeConnection issues POST /close with mandatory reasonText', () async {
      RequestOptions? captured;
      final repo = ConnectionRepository(buildClient(onPostClose: (opts) => captured = opts));

      await repo.closeConnection('conn-1', reasonText: 'Customer requested cancellation.');

      expect(captured, isNotNull);
      expect(captured!.path, '/v1/admin/connections/conn-1/close');
      expect(captured!.data, {'reasonText': 'Customer requested cancellation.'});
    });

    test('createAdminNote issues POST /notes with text and parses response', () async {
      RequestOptions? captured;
      final repo = ConnectionRepository(buildClient(onPostNote: (opts) => captured = opts));

      final note = await repo.createAdminNote('conn-1', 'SLA check conducted.');

      expect(captured, isNotNull);
      expect(captured!.path, '/v1/admin/connections/conn-1/notes');
      expect(captured!.data, {'text': 'SLA check conducted.'});
      expect(note.id, 'note-2');
      expect(note.text, 'SLA check conducted.');
      expect(note.author, 'admin-42');
    });
  });
}
