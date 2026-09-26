import 'package:flutter_test/flutter_test.dart';
import 'package:kh_api/kh_api.dart';

void main() {
  group('ReviewDto.fromJson', () {
    test('parses a published review with a vendor response', () {
      final review = ReviewDto.fromJson({
        'id': 'rev-1',
        'connectionId': 'con-1',
        'authorType': 'CUSTOMER',
        'authorDisplayName': 'A. Customer',
        'rating': 5,
        'comment': 'Great service',
        'state': 'PUBLISHED',
        'vendorResponse': {'text': 'Thank you!', 'state': 'PUBLISHED'},
        'editableUntil': '2026-09-20T00:00:00.000Z',
        'createdAt': '2026-09-06T00:00:00.000Z',
        'publishedAt': '2026-09-07T00:00:00.000Z',
      });

      expect(review.rating, 5);
      expect(review.vendorResponse!.text, 'Thank you!');
      expect(review.publishedAt, isNotNull);
    });

    test('defaults authorType and tolerates a missing vendor response', () {
      final review = ReviewDto.fromJson({
        'id': 'rev-2',
        'rating': 4,
        'editableUntil': '2026-09-20T00:00:00.000Z',
        'createdAt': '2026-09-06T00:00:00.000Z',
      });

      expect(review.authorType, 'CUSTOMER');
      expect(review.vendorResponse, isNull);
      expect(review.publishedAt, isNull);
    });
  });

  group('UserSettingsDto.fromJson', () {
    test('parses quiet hours and per-category notification prefs', () {
      final settings = UserSettingsDto.fromJson({
        'preferredLanguage': 'ar',
        'defaultRegionId': 'r1',
        'quietHours': {'start': '22:00', 'end': '07:00'},
        'notifications': {
          'offer_updates': {
            'inApp': true,
            'push': false,
            'emailChannel': false,
          },
        },
      });

      expect(settings.preferredLanguage, 'ar');
      expect(settings.quietHours!.start, '22:00');
      expect(settings.quietHours!.timezone, 'Asia/Dubai');
      expect(settings.notifications['offer_updates']!.push, isFalse);
    });

    test('defaults language and tolerates an absent notifications map', () {
      final settings = UserSettingsDto.fromJson({});
      expect(settings.preferredLanguage, 'en');
      expect(settings.notifications, isEmpty);
    });
  });

  group('QuietHoursDto', () {
    test('toJson omits timezone — only start/end are ever sent back', () {
      const hours = QuietHoursDto(start: '22:00', end: '07:00');
      expect(hours.toJson(), {'start': '22:00', 'end': '07:00'});
    });
  });

  group('UserSettingsPatch.toJson', () {
    test('omits absent fields but sends explicit null on clear flags', () {
      const patch = UserSettingsPatch(
        preferredLanguage: 'ar',
        clearDefaultRegion: true,
        clearQuietHours: true,
      );
      expect(patch.toJson(), {
        'preferredLanguage': 'ar',
        'defaultRegionId': null,
        'quietHours': null,
      });
    });

    test('sends the value, not null, when a field is simply set', () {
      const patch = UserSettingsPatch(defaultRegionId: 'r2');
      expect(patch.toJson(), {'defaultRegionId': 'r2'});
    });
  });

  group('PlatformConfigDto.fromJson', () {
    test('coerces string-encoded ints and fills defaults', () {
      final config = PlatformConfigDto.fromJson({
        'requestLifetimeHours': '48',
        'bullionMinimumAed': 5000,
        'acceptedImageTypes': ['image/jpeg', 'image/png'],
        'karatList': ['18', '22', '24'],
        'termsUrl': 'https://karathive.test/terms',
        'privacyUrl': 'https://karathive.test/privacy',
        'supportContactUrl': 'https://karathive.test/support',
        'subscriptionContactUrl': 'https://karathive.test/subscribe',
      });

      expect(config.requestLifetimeHours, 48);
      expect(config.bullionMinimumAed, '5000');
      expect(config.offerValidityHours, [12, 24, 48]);
      expect(config.karatList, ['18', '22', '24']);
    });
  });

  group('AuthSessionDto.fromJson', () {
    test('parses a session-family row', () {
      final session = AuthSessionDto.fromJson({
        'id': 'sess-1',
        'deviceLabel': 'iPhone 15',
        'lastUsedAt': '2026-09-10T08:00:00.000Z',
        'createdAt': '2026-09-01T08:00:00.000Z',
        'isCurrent': true,
      });

      expect(session.deviceLabel, 'iPhone 15');
      expect(session.isCurrent, isTrue);
    });

    test('defaults isCurrent to false', () {
      final session = AuthSessionDto.fromJson({
        'id': 'sess-2',
        'lastUsedAt': '2026-09-10T08:00:00.000Z',
        'createdAt': '2026-09-01T08:00:00.000Z',
      });
      expect(session.isCurrent, isFalse);
    });
  });

  group('VendorRatingSummaryDto.fromJson', () {
    test('parses masked vendor plus reviewer-labelled reviews', () {
      final summary = VendorRatingSummaryDto.fromJson({
        'vendor': {'label': 'Vendor · Deira', 'connectionCount': 5},
        'reviews': [
          {
            'id': 'rev-1',
            'rating': 5,
            'reviewerLabel': 'Customer #12',
            'comment': 'Fast and fair.',
          },
        ],
      });

      expect(summary.vendor.label, 'Vendor · Deira');
      expect(summary.reviews.single.reviewerLabel, 'Customer #12');
    });
  });

  group('RequestDraftInput', () {
    test('toJson omits every field left unset', () {
      const draft = RequestDraftInput(
        requestType: 'FIND_ORNAMENT',
      );
      expect(draft.toJson(), {
        'requestType': 'FIND_ORNAMENT',
      });
    });

    test('fromJson round-trips a full draft payload', () {
      final draft = RequestDraftInput.fromJson({
        'requestType': 'SELL_GOLD',
        'weightGrams': '10.5',
        'quantity': 2,
        'mediaKeys': ['m1', 'm2'],
      });
      expect(draft.requestType, 'SELL_GOLD');
      expect(draft.weightGrams, '10.5');
      expect(draft.mediaKeys, ['m1', 'm2']);
    });
  });
}
