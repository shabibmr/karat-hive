import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

/// BR-008 competitor-blindness keys (mirrors backend `COMPETITOR_KEYS`).
const competitorKeys = <String>{
  'competitorPrice',
  'competitorPrices',
  'competingPrices',
  'winningPrice',
  'winningVendor',
  'winningVendorId',
  'winningVendorName',
  'competitorId',
  'competitorName',
  'competitorVendor',
  'competingVendor',
  'competingVendors',
  'competitorTerms',
  'competingTerms',
  'competitorOffers',
  'competingOffers',
};

/// Loser in-app row after Acceptance (`offer.rejected`, Async-Contract §7.2).
Map<String, dynamic> loserNotificationFixture({
  String id = 'ntf-loser-1',
  String requestId = '11111111-1111-1111-1111-111111111111',
}) =>
    {
      'id': id,
      'type': 'offer.rejected',
      'title': 'The Customer selected another Vendor',
      'body': 'The Customer accepted a different Offer on this Request.',
      'deepLink': '/requests/$requestId',
      'isCritical': false,
      'createdAt': '2026-09-08T10:00:00.000Z',
    };

/// Winner in-app row after Acceptance (`offer.accepted`).
Map<String, dynamic> acceptedNotificationFixture({
  String id = 'ntf-win-1',
  String connectionId = '33333333-3333-3333-3333-333333333333',
}) =>
    {
      'id': id,
      'type': 'offer.accepted',
      'title': 'Your Offer was accepted',
      'body': 'The Customer accepted your Offer. You are now connected.',
      'deepLink': '/connections/$connectionId',
      'isCritical': true,
      'createdAt': '2026-09-08T10:00:00.000Z',
    };

String? findCompetitorKey(Object? value) {
  if (value is List) {
    for (final item in value) {
      final hit = findCompetitorKey(item);
      if (hit != null) return hit;
    }
    return null;
  }
  if (value is Map) {
    for (final entry in value.entries) {
      final key = entry.key.toString();
      if (competitorKeys.contains(key)) return key;
      final nested = findCompetitorKey(entry.value);
      if (nested != null) return nested;
    }
  }
  return null;
}

final _leakyCopy = RegExp(
  r'AED|winningPrice|competitorPrice|ven-win|offer-win|offeredPrice',
  caseSensitive: false,
);

void expectNoCompetitorCopy(Map<String, dynamic> fixture) {
  for (final field in ['title', 'body', 'deepLink']) {
    final text = fixture[field]?.toString() ?? '';
    expect(
      text,
      isNot(matches(_leakyCopy)),
      reason: '$field must not leak competitor price/identity (BR-008)',
    );
  }
}

final DateTime _fixedNow = DateTime.utc(2026, 9, 8, 12);

Widget _host(Widget child) => MaterialApp(
      theme: khTheme(),
      home: Scaffold(body: child),
    );

void main() {
  group('BR-008 VEN-S17 notification fixtures (CP5-B07.1)', () {
    test('loser and accepted wire fixtures omit competitor price keys', () {
      final loser = loserNotificationFixture();
      final accepted = acceptedNotificationFixture();

      expect(findCompetitorKey(loser), isNull);
      expect(findCompetitorKey(accepted), isNull);
      expectNoCompetitorCopy(loser);
      expectNoCompetitorCopy(accepted);

      final loserN = AppNotification.fromJson(loser);
      final acceptedN = AppNotification.fromJson(accepted);
      expect(loserN.type, 'offer.rejected');
      expect(acceptedN.type, 'offer.accepted');
      expect(loserN.deepLink, startsWith('/requests/'));
      expect(acceptedN.deepLink, startsWith('/connections/'));
      expect(loserN.body, isNot(matches(_leakyCopy)));
      expect(acceptedN.body, isNot(matches(_leakyCopy)));
    });

    testWidgets(
      'SH-NTF-01 renders loser/accepted copy without competitor price text',
      (tester) async {
        final loser = AppNotification.fromJson(loserNotificationFixture());
        final accepted =
            AppNotification.fromJson(acceptedNotificationFixture());

        await tester.pumpWidget(
          _host(
            Column(
              children: [
                NotificationListItem(notification: loser, now: _fixedNow),
                NotificationListItem(notification: accepted, now: _fixedNow),
              ],
            ),
          ),
        );

        expect(
          find.text('The Customer selected another Vendor'),
          findsOneWidget,
        );
        expect(find.text('Your Offer was accepted'), findsOneWidget);
        expect(find.textContaining('AED'), findsNothing);
        expect(find.textContaining('winningPrice'), findsNothing);
        expect(find.textContaining('competitorPrice'), findsNothing);
        expect(find.textContaining('3950'), findsNothing);
      },
    );
  });
}
