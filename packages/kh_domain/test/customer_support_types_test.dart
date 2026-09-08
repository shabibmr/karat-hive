import 'package:kh_domain/kh_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Review', () {
    test('parses inventory Review wire', () {
      final review = Review.fromJson({
        'id': 'rev-1',
        'connectionId': 'conn-1',
        'authorType': 'CUSTOMER',
        'rating': 5,
        'comment': 'Fair terms',
        'state': 'PENDING_MODERATION',
        'editableUntil': '2026-09-15T12:00:00.000Z',
        'createdAt': '2026-09-01T12:00:00.000Z',
      });
      expect(review.rating, 5);
      expect(review.state, ReviewState.pendingModeration);
      expect(review.connectionId, 'conn-1');
      expect(review.authorType, PartyRole.customer);
    });
  });

  group('AppNotification', () {
    test('parses centre payload', () {
      final n = AppNotification.fromJson({
        'id': 'n1',
        'type': 'FIRST_OFFER',
        'title': 'New Offer',
        'body': 'You received an Offer',
        'deepLink': '/requests/req-1',
        'isCritical': false,
        'createdAt': '2026-09-01T12:00:00.000Z',
      });
      expect(n.type, 'FIRST_OFFER');
      expect(n.readAt, isNull);
      expect(n.isCritical, isFalse);
    });
  });

  group('AbuseReport', () {
    test('parses acknowledgement and entity types', () {
      expect(AbuseEntityType.parse('OFFER'), AbuseEntityType.offer);
      expect(AbuseEntityType.parse('CONNECTION'), AbuseEntityType.connection);
      expect(AbuseEntityType.parse('VENDOR'), AbuseEntityType.vendor);
      expect(AbuseEntityType.parse('CUSTOMER'), AbuseEntityType.customer);
      final ack = AbuseReport.fromJson({
        'id': 'ab-1',
        'state': 'OPEN',
        'acknowledged': true,
      });
      expect(ack.acknowledged, isTrue);
      expect(ack.state, AbuseReportState.open);
    });
  });

  group('UserSettings', () {
    test('parses language, quiet hours, notification prefs', () {
      final s = UserSettings.fromJson({
        'preferredLanguage': 'ar',
        'defaultRegionId': 'reg-1',
        'quietHours': {
          'start': '22:00',
          'end': '07:00',
          'timezone': 'Asia/Dubai',
        },
        'notifications': {
          'FIRST_OFFER': {'inApp': true, 'push': true, 'email': false},
        },
      });
      expect(s.preferredLanguage, 'ar');
      expect(s.quietHours?.start, '22:00');
      expect(s.notifications['FIRST_OFFER']?.push, isTrue);
    });
  });

  group('PlatformConfig', () {
    test('has maxConcurrentLiveRequests and optional legal URLs (SAM-GAP-5)', () {
      final cfg = PlatformConfig.fromJson({
        'requestLifetimeHours': 48,
        'offerValidityHours': [12, 24, 48],
        'defaultOfferValidityHours': 24,
        'bullionMinimumAed': '500.00',
        'maxConcurrentLiveRequests': 10,
        'maxRequestImages': 5,
        'maxOfferImages': 3,
        'maxImageBytes': 5242880,
        'acceptedImageTypes': ['image/jpeg'],
        'karatList': ['24K', '22K'],
        'maxOfferRevisions': 3,
        'requestExpiryWarningHours': 6,
        'termsUrl': 'https://karathive.ae/legal/terms',
        'privacyUrl': 'https://karathive.ae/legal/privacy',
        'supportContactUrl': 'https://karathive.ae/support',
        'subscriptionContactUrl': 'https://karathive.ae/subscriptions',
      });
      expect(cfg.maxConcurrentLiveRequests, 10);
      expect(cfg.bullionMinimumAed, '500.00');
      expect(cfg.termsUrl, contains('terms'));
      expect(cfg.privacyUrl, contains('privacy'));
      expect(cfg.supportContactUrl, isNotNull);
    });

    test('legal URLs are optional when absent', () {
      final cfg = PlatformConfig.fromJson({
        'requestLifetimeHours': 48,
        'offerValidityHours': [24],
        'defaultOfferValidityHours': 24,
        'bullionMinimumAed': '500.00',
        'maxConcurrentLiveRequests': 10,
        'maxRequestImages': 5,
        'maxOfferImages': 3,
        'maxImageBytes': 1,
        'acceptedImageTypes': <String>[],
        'karatList': <String>[],
        'maxOfferRevisions': 3,
        'requestExpiryWarningHours': 6,
      });
      expect(cfg.termsUrl, isNull);
      expect(cfg.privacyUrl, isNull);
    });
  });

  group('GoldRateSnapshot', () {
    test('available and stale flags', () {
      final licensed = GoldRateSnapshot.fromJson({
        'available': true,
        'stale': true,
        'source': 'FEED',
        'sourceTimestamp': '2026-09-01T08:00:00.000Z',
        'ingestedAt': '2026-09-01T08:01:00.000Z',
        'staleAfter': '2026-09-01T10:00:00.000Z',
        'rates': [
          {'karat': '24K', 'ratePerGramAed': '370.00'},
        ],
        'disclaimer': 'Indicative only',
      });
      expect(licensed.available, isTrue);
      expect(licensed.stale, isTrue);
      expect(licensed.rates.single.karat, Karat.k24);
      expect(licensed.rates.single.ratePerGramAed, '370.00');

      final blocked = GoldRateSnapshot.fromJson({
        'available': false,
        'reason': 'DISPLAY_NOT_LICENSED',
      });
      expect(blocked.available, isFalse);
      expect(blocked.stale, isFalse);
      expect(blocked.rates, isEmpty);
      expect(blocked.reason, 'DISPLAY_NOT_LICENSED');
    });
  });
}
