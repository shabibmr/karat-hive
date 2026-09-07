import 'package:kh_domain/kh_domain.dart';
import 'package:test/test.dart';

void main() {
  group('PlatformConfig', () {
    test('parses flat JSON with nested legal map', () {
      final cfg = PlatformConfig.fromJson({
        'requestLifetimeHours': 48,
        'offerValidityHours': [12, 24, 48],
        'defaultOfferValidityHours': 24,
        'bullionMinimumAed': '5000',
        'maxConcurrentLiveRequests': 3,
        'maxOfferRevisions': 3,
        'requestExpiryWarningHours': 6,
        'karatList': ['18', '21', '22', '24'],
        'supportContactUrl': 'https://karathive.ae/support',
        'subscriptionContactUrl': 'https://karathive.ae/subscriptions',
        'legal': {
          'termsUrl': 'https://karathive.ae/terms',
          'privacyUrl': 'https://karathive.ae/privacy',
        },
      });

      expect(cfg.requestLifetimeHours, 48);
      expect(cfg.offerValidityHours, [12, 24, 48]);
      expect(cfg.defaultOfferValidityHours, 24);
      expect(cfg.bullionMinimumAed, '5000');
      expect(cfg.termsUrl, 'https://karathive.ae/terms');
      expect(cfg.privacyUrl, 'https://karathive.ae/privacy');
    });

    test('reads support.contactUrl and karats alias', () {
      final cfg = PlatformConfig.fromJson({
        'karats': [18, 22],
        'bullionMinimumAed': 7500,
        'offerValidityHours': ['12', '48'],
        'support': {'contactUrl': 'https://example.com/help'},
      });

      expect(cfg.karatList, ['18', '22']);
      expect(cfg.bullionMinimumAed, '7500');
      expect(cfg.offerValidityHours, [12, 48]);
      expect(cfg.supportContactUrl, 'https://example.com/help');
      expect(cfg.subscriptionContactUrl, isNull);
      expect(cfg.termsUrl, isNull);
      expect(cfg.privacyUrl, isNull);
    });

    test('applies defaults for empty payload', () {
      final cfg = PlatformConfig.fromJson({});

      expect(cfg.requestLifetimeHours, 48);
      expect(cfg.offerValidityHours, [12, 24, 48]);
      expect(cfg.defaultOfferValidityHours, 24);
      expect(cfg.bullionMinimumAed, '5000');
      expect(cfg.maxConcurrentLiveRequests, 3);
      expect(cfg.maxOfferRevisions, 3);
      expect(cfg.requestExpiryWarningHours, 6);
      expect(cfg.karatList, ['18', '21', '22', '24']);
    });

    test('serializes to JSON', () {
      const cfg = PlatformConfig(
        requestLifetimeHours: 36,
        offerValidityHours: [24],
        defaultOfferValidityHours: 24,
        bullionMinimumAed: '1000',
        maxConcurrentLiveRequests: 2,
        maxOfferRevisions: 1,
        requestExpiryWarningHours: 4,
        karatList: ['22'],
        supportContactUrl: 'https://a/support',
        subscriptionContactUrl: 'https://a/subs',
        termsUrl: 'https://a/terms',
        privacyUrl: 'https://a/privacy',
      );

      expect(cfg.toJson(), {
        'requestLifetimeHours': 36,
        'offerValidityHours': [24],
        'defaultOfferValidityHours': 24,
        'bullionMinimumAed': '1000',
        'maxConcurrentLiveRequests': 2,
        'maxRequestImages': 5,
        'maxOfferImages': 3,
        'maxImageBytes': 0,
        'acceptedImageTypes': ['image/jpeg', 'image/png', 'image/webp'],
        'karatList': ['22'],
        'maxOfferRevisions': 1,
        'requestExpiryWarningHours': 4,
        'termsUrl': 'https://a/terms',
        'privacyUrl': 'https://a/privacy',
        'supportContactUrl': 'https://a/support',
        'subscriptionContactUrl': 'https://a/subs',
      });
    });

    test('copyWith and value equality', () {
      const a = PlatformConfig();
      const b = PlatformConfig();
      final c = a.copyWith(requestLifetimeHours: 24);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(c.requestLifetimeHours, 24);
      expect(a, isNot(equals(c)));
    });
  });
}
