import 'package:kh_domain/kh_domain.dart';
import 'package:test/test.dart';

void main() {
  group('AccountDeletionRequest', () {
    test('round-trips fields including optional challenge/expiry', () {
      final req = AccountDeletionRequest.fromJson({
        'id': 'del-1',
        'state': 'QUEUED',
        'createdAt': '2026-09-01T12:00:00.000Z',
        'challengeId': 'chal-1',
        'expiresAt': '2026-09-08T12:00:00.000Z',
        'retryAfterSeconds': 30,
      });
      expect(req.id, 'del-1');
      expect(req.state, 'QUEUED');
      expect(req.challengeId, 'chal-1');
      expect(req.retryAfterSeconds, 30);
    });

    test('applies defaults when optional fields are absent', () {
      final req = AccountDeletionRequest.fromJson({'id': 'del-2'});
      expect(req.state, 'QUEUED');
      expect(req.challengeId, isNull);
      expect(req.expiresAt, isNull);
      expect(req.retryAfterSeconds, isNull);
    });
  });

  group('ReviewVendorResponse', () {
    test('parses text and state', () {
      final r = ReviewVendorResponse.fromJson({
        'text': 'Thank you!',
        'state': 'PUBLISHED',
      });
      expect(r.text, 'Thank you!');
      expect(r.state, ReviewState.published);
    });

    test('nests inside Review.vendorResponse', () {
      final review = Review.fromJson({
        'id': 'rev-2',
        'connectionId': 'conn-2',
        'authorType': 'VENDOR',
        'rating': 4,
        'state': 'PUBLISHED',
        'editableUntil': '2026-09-15T12:00:00.000Z',
        'createdAt': '2026-09-01T12:00:00.000Z',
        'vendorResponse': {'text': 'Great deal', 'state': 'PUBLISHED'},
      });
      expect(review.vendorResponse?.text, 'Great deal');
      final json = review.toJson();
      expect(json['vendorResponse'], isA<Map<String, dynamic>>());
      expect((json['vendorResponse'] as Map<String, dynamic>)['text'], 'Great deal');
    });
  });

  group('ReviewExcerpt / VendorRatingDetail', () {
    test('ReviewExcerpt falls back across name aliases', () {
      final a = ReviewExcerpt.fromJson({
        'authorDisplayName': 'K.',
        'rating': 5,
      });
      expect(a.abbreviatedName, 'K.');
      expect(a.comment, isNull);
    });

    test('VendorRatingDetail parses summary and capped excerpts', () {
      final detail = VendorRatingDetail.fromJson({
        'summary': {'average': 4.2, 'count': 6},
        'reviews': List.generate(
          12,
          (i) => {'abbreviatedName': 'C$i', 'rating': 5},
        ),
      });
      expect(detail.summary.average, 4.2);
      expect(detail.excerpts.length, 10);
      expect(detail.limitedHistory, detail.summary.limitedHistory);
    });
  });

  group('OfferTerms toJson round-trip', () {
    test('serializes nested media as maps, not raw objects', () {
      final terms = OfferTerms.fromJson({
        'offeredPrice': '100.00',
        'media': [
          {'id': 'm1', 'key': 'k1', 'displayOrder': 0},
        ],
      });
      final json = terms.toJson();
      final media = json['media'] as List<dynamic>;
      expect(media, isA<List<dynamic>>());
      expect(media[0], isA<Map<String, dynamic>>());
      expect((media[0] as Map<String, dynamic>)['id'], 'm1');

      // Round-trip back through fromJson must not throw (regression guard for
      // the explicit_to_json build.yaml requirement).
      final reparsed = OfferTerms.fromJson(json);
      expect(reparsed.media.single.id, 'm1');
    });
  });
}
