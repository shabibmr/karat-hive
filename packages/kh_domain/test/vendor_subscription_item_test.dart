import 'package:kh_domain/kh_domain.dart';
import 'package:test/test.dart';

void main() {
  group('VendorSubscriptionItem', () {
    test('parses from full JSON map', () {
      final item = VendorSubscriptionItem.fromJson({
        'requestType': 'FIND_ORNAMENT',
        'state': 'ACTIVE',
        'priceAed': '499.00',
        'periodStart': '2026-08-01T00:00:00.000Z',
        'periodEnd': '2026-09-01T00:00:00.000Z',
        'graceEndsAt': '2026-09-08T00:00:00.000Z',
        'renewalDate': '2026-09-01T00:00:00.000Z',
        'canOffer': true,
      });

      expect(item.requestType, 'FIND_ORNAMENT');
      expect(item.state, 'ACTIVE');
      expect(item.priceAed, '499.00');
      expect(item.periodStart?.toUtc(), DateTime.utc(2026, 8, 1));
      expect(item.periodEnd?.toUtc(), DateTime.utc(2026, 9, 1));
      expect(item.graceEndsAt?.toUtc(), DateTime.utc(2026, 9, 8));
      expect(item.renewalDate?.toUtc(), DateTime.utc(2026, 9, 1));
      expect(item.canOffer, isTrue);
    });

    test('applies defaults and coerces numeric priceAed', () {
      final item = VendorSubscriptionItem.fromJson({
        'requestType': 'BULLION',
        'state': 'EXPIRED',
        'priceAed': 699,
      });

      expect(item.priceAed, '699');
      expect(item.canOffer, isFalse);
      expect(item.periodStart, isNull);
      expect(item.periodEnd, isNull);
      expect(item.graceEndsAt, isNull);
      expect(item.renewalDate, isNull);
    });

    test('defaults priceAed when absent', () {
      final item = VendorSubscriptionItem.fromJson({
        'requestType': 'CUSTOM_DESIGN',
        'state': 'GRACE',
      });

      expect(item.priceAed, '0.00');
    });

    test('serializes to JSON', () {
      final item = VendorSubscriptionItem(
        requestType: 'FIND_ORNAMENT',
        state: 'ACTIVE',
        priceAed: '499.00',
        canOffer: true,
        renewalDate: DateTime.utc(2026, 10, 1),
      );

      expect(item.toJson(), {
        'requestType': 'FIND_ORNAMENT',
        'state': 'ACTIVE',
        'priceAed': '499.00',
        'periodStart': null,
        'periodEnd': null,
        'graceEndsAt': null,
        'renewalDate': '2026-10-01T00:00:00.000Z',
        'canOffer': true,
      });
    });

    test('copyWith and value equality', () {
      const a = VendorSubscriptionItem(
        requestType: 'BULLION',
        state: 'ACTIVE',
        priceAed: '100.00',
        canOffer: true,
      );
      const b = VendorSubscriptionItem(
        requestType: 'BULLION',
        state: 'ACTIVE',
        priceAed: '100.00',
        canOffer: true,
      );
      final c = a.copyWith(state: 'EXPIRED', canOffer: false);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(c.state, 'EXPIRED');
      expect(c.canOffer, isFalse);
      expect(a, isNot(equals(c)));
    });
  });
}
