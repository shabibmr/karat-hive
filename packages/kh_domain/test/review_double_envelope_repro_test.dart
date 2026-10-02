import 'package:kh_domain/kh_domain.dart';
import 'package:test/test.dart';

Map<String, dynamic> _reviewPayload() => {
      'id': 'rev-1',
      'connectionId': 'conn-1',
      'authorType': 'CUSTOMER',
      'rating': 5,
      'state': 'PENDING_MODERATION',
      'editableUntil': '2026-04-03T12:00:00.000Z',
      'createdAt': '2026-04-02T12:00:00.000Z',
      'comment': 'Great vendor',
    };

void main() {
  test('Review peels double-enveloped { data: review }', () {
    final review = Review.fromJson({
      'data': _reviewPayload(),
    });
    expect(review.id, 'rev-1');
    expect(review.connectionId, 'conn-1');
    expect(review.rating, 5);
    expect(review.state, ReviewState.pendingModeration);
    expect(review.comment, 'Great vendor');
  });

  test('Review parses bare resource', () {
    final review = Review.fromJson(_reviewPayload());
    expect(review.id, 'rev-1');
    expect(review.authorType, PartyRole.customer);
  });
}
