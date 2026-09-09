import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

Widget _host(Widget child) => MaterialApp(
      theme: khTheme(),
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    );

List<NotificationPreferenceCategory> _sampleCategories({
  NotificationChannelPref? offersPref,
}) =>
    [
      NotificationPreferenceCategory(
        id: 'offer.submitted',
        label: 'New Offers',
        pref: offersPref ??
            const NotificationChannelPref(
              inApp: true,
              push: true,
              email: false,
            ),
      ),
      const NotificationPreferenceCategory(
        id: 'security',
        label: 'Security alerts',
        pref: NotificationChannelPref(
          inApp: false,
          push: false,
          email: false,
        ),
        hint: 'Required for account security',
      ),
    ];

void main() {
  test('isLockedNotificationCategory matches backend security key', () {
    expect(isLockedNotificationCategory('security'), isTrue);
    expect(isLockedNotificationCategory('offer.submitted'), isFalse);
    expect(kLockedNotificationCategories, contains('security'));
  });

  test('NotificationPreferenceCategory.isLocked ORs explicit flag and id', () {
    const byId = NotificationPreferenceCategory(
      id: 'security',
      label: 'Security',
      pref: kLockedNotificationChannelPref,
    );
    const byFlag = NotificationPreferenceCategory(
      id: 'custom.critical',
      label: 'Critical',
      pref: kLockedNotificationChannelPref,
      locked: true,
    );
    const open = NotificationPreferenceCategory(
      id: 'offer.submitted',
      label: 'Offers',
      pref: NotificationChannelPref(inApp: true, push: false, email: false),
    );

    expect(byId.isLocked, isTrue);
    expect(byFlag.isLocked, isTrue);
    expect(open.isLocked, isFalse);
    expect(byId.effectivePref.inApp, isTrue);
    expect(byId.effectivePref.push, isTrue);
    expect(byId.effectivePref.email, isTrue);
  });

  test('notificationChannelPrefWith updates one channel', () {
    const base = NotificationChannelPref(
      inApp: true,
      push: false,
      email: false,
    );
    expect(
      notificationChannelPrefWith(base, NotificationPrefChannel.push, true)
          .push,
      isTrue,
    );
    expect(
      notificationChannelPrefWith(base, NotificationPrefChannel.email, true)
          .email,
      isTrue,
    );
    expect(
      notificationChannelPrefWith(base, NotificationPrefChannel.inApp, false)
          .inApp,
      isFalse,
    );
  });

  testWidgets('SH-NTF-03 renders category × channel toggles', (tester) async {
    await tester.pumpWidget(
      _host(NotificationPreferenceMatrix(categories: _sampleCategories())),
    );

    expect(
      find.byKey(const Key('notification-preference-matrix')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('notif-pref-category-offer.submitted')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('notif-pref-category-security')),
      findsOneWidget,
    );
    expect(find.text('New Offers'), findsOneWidget);
    expect(find.text('Security alerts'), findsOneWidget);
    expect(find.text('In-app'), findsNWidgets(2));
    expect(find.text('Push'), findsNWidgets(2));
    expect(find.text('Email'), findsNWidgets(2));
  });

  testWidgets('SH-NTF-03 locks security-critical category', (tester) async {
    await tester.pumpWidget(
      _host(
        NotificationPreferenceMatrix(
          categories: _sampleCategories(),
          onChanged: (_, __) {},
        ),
      ),
    );

    expect(find.byKey(const Key('notif-pref-lock-security')), findsOneWidget);
    expect(
      find.byKey(const Key('notif-pref-hint-security')),
      findsOneWidget,
    );
    expect(find.text('Required for account security'), findsOneWidget);

    final lockedToggle = tester.widget<KhToggle>(
      find.byKey(const Key('notif-pref-security-push')),
    );
    expect(lockedToggle.value, isTrue);
    expect(lockedToggle.enabled, isFalse);
    expect(lockedToggle.onChanged, isNull);

    final openToggle = tester.widget<KhToggle>(
      find.byKey(const Key('notif-pref-offer.submitted-email')),
    );
    expect(openToggle.value, isFalse);
    expect(openToggle.enabled, isTrue);
  });

  testWidgets('SH-NTF-03 onChanged fires for unlocked channels only',
      (tester) async {
    String? changedId;
    NotificationChannelPref? changedPref;

    await tester.pumpWidget(
      _host(
        NotificationPreferenceMatrix(
          categories: _sampleCategories(),
          onChanged: (id, next) {
            changedId = id;
            changedPref = next;
          },
        ),
      ),
    );

    Future<void> tapToggle(Key key) async {
      await tester.tap(
        find.descendant(
          of: find.byKey(key),
          matching: find.byType(Switch),
        ),
      );
      await tester.pump();
    }

    await tapToggle(const Key('notif-pref-offer.submitted-email'));
    expect(changedId, 'offer.submitted');
    expect(changedPref?.email, isTrue);
    expect(changedPref?.inApp, isTrue);
    expect(changedPref?.push, isTrue);

    changedId = null;
    changedPref = null;
    await tapToggle(const Key('notif-pref-security-push'));
    expect(changedId, isNull);
    expect(changedPref, isNull);
  });

  testWidgets('SH-NTF-03 accepts custom channel labels', (tester) async {
    await tester.pumpWidget(
      _host(
        NotificationPreferenceMatrix(
          categories: const [
            NotificationPreferenceCategory(
              id: 'offer.submitted',
              label: 'Offers',
              pref: NotificationChannelPref(
                inApp: true,
                push: false,
                email: false,
              ),
            ),
          ],
          inAppLabel: 'In-app centre',
          pushLabel: 'Push alerts',
          emailLabel: 'Email digest',
        ),
      ),
    );

    expect(find.text('In-app centre'), findsOneWidget);
    expect(find.text('Push alerts'), findsOneWidget);
    expect(find.text('Email digest'), findsOneWidget);
  });
}
