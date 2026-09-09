import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

final DateTime _fixedNow = DateTime.utc(2026, 9, 7, 12, 0, 0);

AppNotification _notification({
  required String id,
  String type = 'offer.submitted',
  String title = 'Title',
  String body = 'Body',
  String deepLink = '/requests/req-1',
  DateTime? createdAt,
  DateTime? readAt,
}) =>
    AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      deepLink: deepLink,
      isCritical: false,
      readAt: readAt,
      createdAt: createdAt ?? _fixedNow.subtract(const Duration(hours: 1)),
    );

Widget _host(Widget child) => MaterialApp(
      theme: khTheme(),
      home: Scaffold(body: child),
    );

void main() {
  test('notificationsInCentreWindow drops items older than 90 days', () {
    final kept = _notification(
      id: 'in',
      createdAt: _fixedNow.subtract(const Duration(days: 89)),
    );
    final boundary = _notification(
      id: 'edge',
      createdAt: _fixedNow.subtract(const Duration(days: 90)),
    );
    final dropped = _notification(
      id: 'out',
      createdAt: _fixedNow.subtract(const Duration(days: 91)),
    );

    final result = notificationsInCentreWindow(
      [dropped, kept, boundary],
      now: _fixedNow,
    );

    expect(result.map((n) => n.id), ['in', 'edge']);
  });

  test('notificationsInCentreWindow sorts newest first', () {
    final older = _notification(
      id: 'older',
      createdAt: _fixedNow.subtract(const Duration(hours: 5)),
    );
    final newer = _notification(
      id: 'newer',
      createdAt: _fixedNow.subtract(const Duration(minutes: 5)),
    );

    final result = notificationsInCentreWindow(
      [older, newer],
      now: _fixedNow,
    );

    expect(result.map((n) => n.id), ['newer', 'older']);
  });

  testWidgets('SH-NTF-02 lists SH-NTF-01 items inside the window',
      (tester) async {
    await tester.pumpWidget(
      _host(
        NotificationCentreList(
          notifications: [
            _notification(
              id: 'n-new',
              title: 'New Offer',
              createdAt: _fixedNow.subtract(const Duration(minutes: 12)),
            ),
            _notification(
              id: 'n-old',
              title: 'Ancient',
              createdAt: _fixedNow.subtract(const Duration(days: 120)),
            ),
          ],
          now: _fixedNow,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onNotificationTap: (_) {},
        ),
      ),
    );

    expect(find.byKey(const Key('notification-centre-list')), findsOneWidget);
    expect(find.byKey(const Key('notification-item-n-new')), findsOneWidget);
    expect(find.byKey(const Key('notification-item-n-old')), findsNothing);
    expect(find.byType(NotificationListItem), findsOneWidget);
    expect(find.text('New Offer'), findsOneWidget);
    expect(find.text('Ancient'), findsNothing);
  });

  testWidgets('SH-NTF-02 shows KhEmptyView when window is empty',
      (tester) async {
    await tester.pumpWidget(
      _host(
        NotificationCentreList(
          notifications: [
            _notification(
              id: 'stale',
              createdAt: _fixedNow.subtract(const Duration(days: 100)),
            ),
          ],
          now: _fixedNow,
          emptyMessage: 'No notifications in the last 90 days.',
        ),
      ),
    );

    expect(find.byKey(const Key('empty-view')), findsOneWidget);
    expect(
      find.text('No notifications in the last 90 days.'),
      findsOneWidget,
    );
    expect(find.byType(NotificationListItem), findsNothing);
  });

  testWidgets('SH-NTF-02 onNotificationTap receives the item', (tester) async {
    AppNotification? tapped;
    await tester.pumpWidget(
      _host(
        NotificationCentreList(
          notifications: [
            _notification(id: 'tap-me', title: 'Tap me'),
          ],
          now: _fixedNow,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onNotificationTap: (n) => tapped = n,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('notification-item-tap-me')));
    expect(tapped?.id, 'tap-me');
  });
}
