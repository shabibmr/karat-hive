import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/moderation/model/moderation_enums.dart';
import 'package:kh_admin/features/moderation/model/moderation_filters.dart';
import 'package:kh_admin/features/moderation/repository/moderation_repository.dart';

void main() {
  Map<String, dynamic> rawReviewRow({
    required String id,
    String state = 'PENDING_MODERATION',
    int rating = 5,
    String comment = 'Exceptional craftsmanship and service',
    String? vendorResponse,
  }) {
    return {
      'id': id,
      'connectionId': 'conn-$id',
      'authorType': 'CUSTOMER',
      'authorUserId': 'user-auth-$id',
      'subjectUserId': 'user-subj-$id',
      'rating': rating,
      'comment': comment,
      'state': state,
      'vendorResponse': vendorResponse,
      'vendorResponseState': null,
      'moderatedByAdminId': null,
      'editableUntil': '2026-09-02T10:00:00.000Z',
      'publishedAt': state == 'PUBLISHED' ? '2026-09-01T12:00:00.000Z' : null,
      'createdAt': '2026-09-01T10:00:00.000Z',
      'updatedAt': '2026-09-01T10:00:00.000Z',
      'author': {
        'id': 'user-auth-$id',
        'email': 'customer@example.com',
        'customerProfile': {'displayName': 'Fatima Customer'},
      },
      'subject': {
        'id': 'user-subj-$id',
        'email': 'vendor@example.com',
        'vendorProfile': {'tradingName': 'Al Noor Jewellery'},
      },
      'connection': {
        'id': 'conn-$id',
        'requestId': 'req-10',
        'offerId': 'off-20',
      },
    };
  }

  ApiClient buildClient({
    void Function(RequestOptions)? onPostApprove,
    void Function(RequestOptions)? onPostReject,
    void Function(RequestOptions)? onPostRedact,
  }) {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final path = options.path;

          if (path == '/v1/admin/reviews') {
            final query = options.queryParameters;
            var rows = [
              rawReviewRow(id: 'rev-1', state: 'PENDING_MODERATION'),
              rawReviewRow(id: 'rev-2', state: 'PENDING_MODERATION'),
            ];

            if (query['state'] != null) {
              rows = rows.where((r) => r['state'] == query['state']).toList();
            }
            if (query['authorType'] != null) {
              rows = rows.where((r) => r['authorType'] == query['authorType']).toList();
            }
            if (query['q'] != null) {
              final q = query['q'].toString().toLowerCase();
              rows = rows
                  .where((r) =>
                      r['id'].toString().toLowerCase().contains(q) ||
                      r['comment'].toString().toLowerCase().contains(q))
                  .toList();
            }

            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': {
                    'data': rows,
                    'nextCursor': 'rev-2',
                  },
                  'meta': {'nextCursor': 'rev-2'},
                },
              ),
            );
          }

          if (path.startsWith('/v1/admin/reviews/') && path.endsWith('/approve')) {
            onPostApprove?.call(options);
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'data': {'id': 'rev-1', 'state': 'PUBLISHED'}},
              ),
            );
          }

          if (path.startsWith('/v1/admin/reviews/') && path.endsWith('/reject')) {
            onPostReject?.call(options);
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'data': {'id': 'rev-1', 'state': 'REJECTED'}},
              ),
            );
          }

          if (path.startsWith('/v1/admin/reviews/') && path.endsWith('/redact')) {
            onPostRedact?.call(options);
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'data': {'id': 'rev-1', 'state': 'REDACTED'}},
              ),
            );
          }

          return handler.next(options);
        },
      ),
    );
    return ApiClient(dio: dio);
  }

  group('ModerationRepository', () {
    test('fetches reviews and parses items correctly', () async {
      final client = buildClient();
      final repo = ModerationRepository(client);

      final page = await repo.fetchReviews();

      expect(page.items.length, 2);
      expect(page.items.first.id, 'rev-1');
      expect(page.items.first.rating, 5);
      expect(page.items.first.state, ReviewState.pendingModeration);
      expect(page.items.first.authorName, 'Fatima Customer');
      expect(page.items.first.subjectName, 'Al Noor Jewellery');
      expect(page.hasMore, true);
      expect(page.nextCursor, 'rev-2');
    });

    test('filters reviews by query via query parameters', () async {
      final client = buildClient();
      final repo = ModerationRepository(client);

      final page = await repo.fetchReviews(
        filters: const ModerationFilters(query: 'rev-1'),
      );

      expect(page.items.length, 1);
      expect(page.items.first.id, 'rev-1');
    });

    test('filters reviews by authorType via query parameters', () async {
      final client = buildClient();
      final repo = ModerationRepository(client);

      final page = await repo.fetchReviews(
        filters: const ModerationFilters(authorType: AuthorType.customer),
      );

      expect(page.items.length, 2);
    });

    test('calls approve endpoint', () async {
      RequestOptions? captured;
      final client = buildClient(onPostApprove: (opt) => captured = opt);
      final repo = ModerationRepository(client);

      await repo.approveReview('rev-1');

      expect(captured, isNotNull);
      expect(captured!.path, '/v1/admin/reviews/rev-1/approve');
    });

    test('calls reject endpoint with rationale', () async {
      RequestOptions? captured;
      final client = buildClient(onPostReject: (opt) => captured = opt);
      final repo = ModerationRepository(client);

      await repo.rejectReview('rev-1', rationale: 'Policy violation');

      expect(captured, isNotNull);
      expect(captured!.path, '/v1/admin/reviews/rev-1/reject');
      expect(captured!.data, {'rationale': 'Policy violation'});
    });

    test('calls redact endpoint with rationale and redacted comment', () async {
      RequestOptions? captured;
      final client = buildClient(onPostRedact: (opt) => captured = opt);
      final repo = ModerationRepository(client);

      await repo.redactReview(
        'rev-1',
        rationale: 'PII removed',
        redactedComment: 'Clean comment without phone number',
      );

      expect(captured, isNotNull);
      expect(captured!.path, '/v1/admin/reviews/rev-1/redact');
      expect(captured!.data, {
        'rationale': 'PII removed',
        'redactedComment': 'Clean comment without phone number',
      });
    });
  });
}
