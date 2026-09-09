import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

final DateTime _fixedNow = DateTime.utc(2026, 9, 7, 12, 0, 0);

AppNotification _notification({
  String id = 'n1',
  String type = 'offer.submitted',
  String title = 'New Offer',
  String body = 'You received an Offer',
  String deepLink = '/requests/req-1',
  bool isCritical = false,
  DateTime? readAt,
  DateTime? createdAt,
}) =>
    AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      deepLink: deepLink,
      isCritical: isCritical,
      readAt: readAt,
      createdAt: createdAt ?? _fixedNow.subtract(const Duration(minutes: 12)),
    );

Widget _host(Widget child) => MaterialApp(
      theme: khTheme(),
      home: Scaffold(body: child),
    );

void main() {
  test('notificationCategoryIcon maps known types', () {
    expect(
      notificationCategoryIcon('offer.submitted'),
      Icons.local_offer_outlined,
    );
    expect(
      notificationCategoryIcon('request.matched'),
      Icons.inbox_outlined,
    );
    expect(
      notificationCategoryIcon('offer.accepted'),
      Icons.check_circle_outline,
    );
    expect(
      notificationCategoryIcon('request.expiry.warning'),
      Icons.schedule_outlined,
    );
    expect(
      notificationCategoryIcon('announcement.scheduled'),
      Icons.campaign_outlined,
    );
    expect(
      notificationCategoryIcon('unknown.thing'),
      Icons.notifications_outlined,
    );
  });

  testWidgets('SH-NTF-01 shows title, body, category icon, unread marker',
      (tester) async {
    await tester.pumpWidget(
      _host(
        NotificationListItem(
          notification: _notification(),
          now: _fixedNow,
          onTap: () {},
        ),
      ),
    );

    expect(find.byKey(const Key('notification-item-n1')), findsOneWidget);
    expect(find.text('New Offer'), findsOneWidget);
    expect(find.text('You received an Offer'), findsOneWidget);
    expect(find.byKey(const Key('notification-category-n1')), findsOneWidget);
    expect(find.byKey(const Key('notification-unread-n1')), findsOneWidget);
    expect(find.byIcon(Icons.local_offer_outlined), findsOneWidget);
  });

  testWidgets('SH-NTF-01 hides unread marker when readAt is set',
      (tester) async {
    await tester.pumpWidget(
      _host(
        NotificationListItem(
          notification: _notification(
            readAt: _fixedNow.subtract(const Duration(minutes: 1)),
          ),
          now: _fixedNow,
          onTap: () {},
        ),
      ),
    );

    expect(find.byKey(const Key('notification-unread-n1')), findsNothing);
  });

  testWidgets('SH-NTF-01 onTap fires for deep link', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _host(
        NotificationListItem(
          notification: _notification(),
          now: _fixedNow,
          onTap: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('notification-item-n1')));
    expect(tapped, isTrue);
  });
}
