import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/offers/model/offer_enums.dart';
import 'package:kh_admin/features/offers/model/offer_list_filters.dart';
import 'package:kh_admin/features/offers/repository/offer_repository.dart';

/// Fixtures mirror origin/main's `backend/src/modules/admin/` output: RAW Prisma
/// rows wrapped only by the response envelope.
/// - list: admin routes double-wrap -> `{ data: { data: [rows], nextCursor } }`.
///   Rows carry `vendorProfileId` (no `vendorId`), Decimal columns as STRINGS,
///   and nest the request/vendor under `request` / `vendorProfile`.
/// - detail: raw `Offer` with `vendorProfile.user`, `request.customerProfile.user`,
///   and `revisions[].previousTerms` (JSON blob, no price columns).
/// - notes: create response has NO `author`; list response nests
///   `author: { displayName }`.
void main() {
  Map<String, dynamic> rawOfferRow({
    required String id,
    required String state,
    String offeredPrice = '14850.00',
  }) {
    return {
      'id': id,
      'requestId': 'req-$id',
      'vendorProfileId': 'ven-$id',
      'state': state,
      'offeredPrice': offeredPrice,
      'makingCharges': '450.00',
      'ratePerGram': '275.00',
      'deliveryTimeframe': '2-3 business days',
      'warrantyTerms': '1-year polish included',
      'vendorNote': 'Velvet box included',
      'validityHours': 48,
      'expiresAt': '2026-08-12T05:12:00.000Z',
      'expiryWarnedAt': null,
      'viewedByCustomerAt': null,
      'revisionCount': 1,
      'submittedAt': '2026-08-10T05:12:00.000Z',
      'decidedAt': null,
      'declineReason': null,
      'createdAt': '2026-08-10T05:12:00.000Z',
      'updatedAt': '2026-08-10T05:12:00.000Z',
      'vendorProfile': <String, dynamic>{
        'id': 'ven-$id',
        'legalBusinessName': 'Al Noor Jewellery LLC',
        'tradingName': 'Al Noor Jewellers',
        'tradeLicenceNumber': 'CN-1092834',
        'contactPersonName': 'Ahmed Hassan',
        'businessEmail': 'contact@alnoor.ae',
        'aggregateRating': '4.8',
        'offersAcceptedCount': 42,
      },
      'request': <String, dynamic>{
        'id': 'req-$id',
        'reference': 'KH-RQ-2026-01482',
        'requestType': 'FIND_ORNAMENT',
        'notes': 'Looking for an 18K necklace set',
        'indicativeValue': '15000.00',
      },
    };
  }

  ApiClient buildClient() {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final path = options.path;

          if (path == '/v1/admin/offers') {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': {
                    'data': [
                      rawOfferRow(id: 'off-1', state: 'PENDING'),
                      rawOfferRow(
                        id: 'off-2',
                        state: 'ACCEPTED',
                        offeredPrice: '18900.00',
                      ),
                    ],
                    'nextCursor': 'off-2',
                  },
                  'meta': {'requestId': 'req-list-1'},
                },
              ),
            );
          }

          if (path == '/v1/admin/offers/off-1') {
            final row = rawOfferRow(id: 'off-1', state: 'REJECTED')
              ..['decidedAt'] = '2026-08-11T10:00:00.000Z'
              ..['declineReason'] = 'PRICE_TOO_HIGH';
            (row['vendorProfile'] as Map<String, dynamic>)['user'] =
                <String, dynamic>{
              'id': 'user-ven-1',
              'email': 'ops@alnoor.ae',
              'mobileNumber': '+97145550101',
            };
            (row['request'] as Map<String, dynamic>)['customerProfile'] =
                <String, dynamic>{
              'id': 'cust-1',
              'displayName': 'Sara Al Maktoum',
              'user': <String, dynamic>{
                'id': 'user-cust-1',
                'email': 'sara@example.ae',
                'mobileNumber': '+971501234567',
              },
            };
            row['revisions'] = [
              <String, dynamic>{
                'id': 'rev-1',
                'offerId': 'off-1',
                'revisionNumber': 1,
                'revisedAt': '2026-08-10T08:30:00.000Z',
                'previousTerms': <String, dynamic>{
                  'offeredPrice': '15450.00',
                  'makingCharges': '600.00',
                  'ratePerGram': '270.00',
                  'deliveryTimeframe': '3-4 business days',
                  'warrantyTerms': null,
                  'vendorNote': 'Original submission',
                  'validityHours': 48,
                },
              },
            ];
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'data': row},
              ),
            );
          }

          if (path == '/v1/admin/offers/off-1/notes' &&
              options.method == 'GET') {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': [
                    {
                      'id': 'note-1',
                      'entityType': 'offers',
                      'entityId': 'off-1',
                      'text': 'Vendor pricing verified against bullion index.',
                      'authorAdminId': 'admin-1',
                      'createdAt': '2026-08-10T06:00:00.000Z',
                      'author': {'displayName': 'Platform Admin'},
                    },
                  ],
                },
              ),
            );
          }

          if (path == '/v1/admin/offers/off-1/notes' &&
              options.method == 'POST') {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                // NOTE: create response carries no `author` string.
                data: {
                  'data': {
                    'id': 'note-new',
                    'entityType': 'offers',
                    'entityId': 'off-1',
                    'text': options.data['text'],
                    'authorAdminId': 'admin-7',
                    'createdAt': '2026-08-12T09:00:00.000Z',
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

  late OfferRepository repository;

  setUp(() {
    repository = OfferRepository(buildClient());
  });

  group('fetchOffers', () {
    test('normalises vendorProfileId, string decimals and nested request',
        () async {
      final page = await repository.fetchOffers();

      expect(page.items, hasLength(2));
      final first = page.items.first;
      expect(first.id, 'off-1');
      expect(first.vendorId, 'ven-off-1');
      expect(first.vendorName, 'Al Noor Jewellery LLC');
      expect(first.offeredPrice, 14850.0);
      expect(first.makingCharges, 450.0);
      expect(first.ratePerGram, 275.0);
      expect(first.requestReference, 'KH-RQ-2026-01482');
      expect(first.requestType, RequestType.findOrnament);
      expect(first.state, OfferState.pending);
    });

    test('derives hasMore/nextCursor from the lifted cursor', () async {
      final page = await repository.fetchOffers();
      expect(page.nextCursor, 'off-2');
      expect(page.hasMore, isTrue);
      expect(page.totalCount, isNull);
    });

    test('applies unsupported filters (price/type/query) client-side',
        () async {
      final byType = await repository.fetchOffers(
        filters: const OfferListFilters(requestType: RequestType.goldCoin),
      );
      expect(byType.items, isEmpty);

      final byPrice = await repository.fetchOffers(
        filters: const OfferListFilters(minPrice: 16000),
      );
      expect(byPrice.items.map((e) => e.id), ['off-2']);

      final byQuery = await repository.fetchOffers(
        filters: const OfferListFilters(query: 'ven-off-2'),
      );
      expect(byQuery.items.map((e) => e.id), ['off-2']);
    });
  });

  group('fetchOfferDetail', () {
    test('maps vendorProfile/request/user and string decimals', () async {
      final detail = await repository.fetchOfferDetail('off-1');

      expect(detail.offeredPrice, 14850.0);
      expect(detail.makingCharges, 450.0);
      expect(detail.state, OfferState.rejected);

      expect(detail.vendor, isNotNull);
      expect(detail.vendor!.legalBusinessName, 'Al Noor Jewellery LLC');
      expect(detail.vendor!.email, 'ops@alnoor.ae');
      expect(detail.vendor!.mobileNumber, '+97145550101');
      expect(detail.vendor!.rating, 4.8);
      expect(detail.vendor!.completedDeals, 42);

      expect(detail.parentRequest, isNotNull);
      expect(detail.parentRequest!.reference, 'KH-RQ-2026-01482');
      expect(detail.parentRequest!.customerName, 'Sara Al Maktoum');
      expect(detail.parentRequest!.customerMobile, '+971501234567');
      expect(detail.parentRequest!.indicativeValue, 15000.0);
    });

    test('pulls revision prices out of previousTerms', () async {
      final detail = await repository.fetchOfferDetail('off-1');

      expect(detail.revisions, hasLength(1));
      final rev = detail.revisions.first;
      expect(rev.revisionNumber, 1);
      expect(rev.offeredPrice, 15450.0);
      expect(rev.makingCharges, 600.0);
      expect(rev.deliveryTimeframe, '3-4 business days');
    });

    test('merges internal notes from the notes route (author from object)',
        () async {
      final detail = await repository.fetchOfferDetail('off-1');

      expect(detail.internalNotes, hasLength(1));
      expect(detail.internalNotes.first.author, 'Platform Admin');
      expect(detail.attachments, isEmpty);
      expect(detail.stateTransitions, isEmpty);
    });
  });

  group('addNote', () {
    test('sends only {text} and does not throw on a response without author',
        () async {
      final note = await repository.addNote('off-1', note: 'Reviewed VAT.');

      expect(note.id, 'note-new');
      expect(note.text, 'Reviewed VAT.');
      // Falls back to authorAdminId when no author string is present.
      expect(note.author, 'admin-7');
    });
  });
}
