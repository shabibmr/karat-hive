import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/profile_settings/controller/settings_controller.dart';
import 'package:karat_hive/features/profile_settings/presentation/settings_screen.dart';
import 'package:karat_hive/features/profile_settings/repository/profile_settings_repository.dart';
import 'package:karat_hive/features/request_feed/controller/request_feed_controller.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileSettingsRepository extends Mock
    implements ProfileSettingsRepository {}

Widget _host({
  required List<Override> overrides,
  Widget child = const SettingsScreen(),
}) {
  return ProviderScope(
    overrides: overrides,
    child: Consumer(
      builder: (context, ref, _) {
        final locale = ref.watch(appLocaleProvider);
        return MaterialApp(
          theme: khTheme(),
          locale: locale,
          supportedLocales: KhStrings.supportedLocales,
          localizationsDelegates: KhStrings.delegates,
          home: child,
        );
      },
    ),
  );
}

void _setLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

UserSettings _mockSettings({
  String preferredLanguage = 'en',
  QuietHours? quietHours,
  Map<String, NotificationChannelPref> notifications = const {},
  String? defaultFilterPresetId,
}) =>
    UserSettings(
      preferredLanguage: preferredLanguage,
      quietHours: quietHours,
      notifications: notifications,
      defaultFilterPresetId: defaultFilterPresetId,
    );

void main() {
  late _MockProfileSettingsRepository repo;
  late String currentLang;
  late QuietHours? currentQuietHours;
  late Map<String, NotificationChannelPref> currentNotifications;
  late String? currentDefaultFilterPresetId;

  setUp(() {
    repo = _MockProfileSettingsRepository();
    currentLang = 'en';
    currentQuietHours = null;
    currentNotifications = const {};
    currentDefaultFilterPresetId = null;
    when(() => repo.settings()).thenAnswer(
      (_) async => Ok(_mockSettings(
        preferredLanguage: currentLang,
        quietHours: currentQuietHours,
        notifications: currentNotifications,
        defaultFilterPresetId: currentDefaultFilterPresetId,
      )),
    );
    when(
      () => repo.patchSettings(
        preferredLanguage: any(named: 'preferredLanguage'),
        defaultRegionId: any(named: 'defaultRegionId'),
        quietHours: any(named: 'quietHours'),
        defaultFilterPresetId: any(named: 'defaultFilterPresetId'),
        notifications: any(named: 'notifications'),
      ),
    ).thenAnswer((invocation) async {
      final lang =
          invocation.namedArguments[#preferredLanguage] as String?;
      if (lang != null) currentLang = lang;
      if (invocation.namedArguments.containsKey(#quietHours)) {
        currentQuietHours =
            invocation.namedArguments[#quietHours] as QuietHours?;
      }
      final notifs = invocation.namedArguments[#notifications]
          as Map<String, NotificationChannelPref>?;
      if (notifs != null) currentNotifications = notifs;
      if (invocation.namedArguments.containsKey(#defaultFilterPresetId)) {
        final val =
            invocation.namedArguments[#defaultFilterPresetId] as String?;
        currentDefaultFilterPresetId =
            (val == null || val.isEmpty) ? null : val;
      }

      return Ok(_mockSettings(
        preferredLanguage: currentLang,
        quietHours: currentQuietHours,
        notifications: currentNotifications,
        defaultFilterPresetId: currentDefaultFilterPresetId,
      ));
    });
    when(() => repo.listSessions()).thenAnswer((_) async => const Ok([]));
    when(() => repo.revokeSession(any())).thenAnswer((_) async => const Ok(null));
    when(() => repo.setPassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        )).thenAnswer((_) async => const Ok(null));
  });

  group('VEN-S18 SettingsScreen Language & Immediate RTL', () {
    testWidgets('renders LanguagePickerTile inside SettingsGroup',
        (tester) async {
      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SettingsGroup), findsNWidgets(7));
      expect(
        find.descendant(
          of: find.byType(SettingsGroup),
          matching: find.byType(LanguagePickerTile),
        ),
        findsOneWidget,
      );
      expect(find.text('App Language'), findsOneWidget);
      expect(find.text('English (LTR)'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(SettingsScreen))),
        TextDirection.ltr,
      );
    });

    testWidgets(
        'tapping Arabic segment updates locale, triggers patch, updates label and sets RTL',
        (tester) async {
      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        Directionality.of(tester.element(find.byType(SettingsScreen))),
        TextDirection.ltr,
      );
      expect(find.text('English (LTR)'), findsOneWidget);

      // Tap Arabic segment
      await tester.tap(find.text('عربي'));
      await tester.pumpAndSettle();

      verify(
        () => repo.patchSettings(
          preferredLanguage: 'ar',
          defaultRegionId: any(named: 'defaultRegionId'),
          quietHours: any(named: 'quietHours'),
          defaultFilterPresetId: any(named: 'defaultFilterPresetId'),
          notifications: any(named: 'notifications'),
        ),
      ).called(1);

      expect(find.text('العربية (Arabic - RTL)'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(SettingsScreen))),
        TextDirection.rtl,
      );
    });

    testWidgets('switching back to English updates Directionality to LTR',
        (tester) async {
      currentLang = 'ar';

      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('العربية (Arabic - RTL)'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(SettingsScreen))),
        TextDirection.rtl,
      );

      // Switch back to English
      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();

      verify(
        () => repo.patchSettings(
          preferredLanguage: 'en',
          defaultRegionId: any(named: 'defaultRegionId'),
          quietHours: any(named: 'quietHours'),
          defaultFilterPresetId: any(named: 'defaultFilterPresetId'),
          notifications: any(named: 'notifications'),
        ),
      ).called(1);

      expect(find.text('English (LTR)'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(SettingsScreen))),
        TextDirection.ltr,
      );
    });

    testWidgets('initial locale reads from userSettingsProvider preferredLanguage',
        (tester) async {
      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
            userSettingsProvider.overrideWith(
              (ref) async => _mockSettings(preferredLanguage: 'ar'),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('العربية (Arabic - RTL)'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(SettingsScreen))),
        TextDirection.rtl,
      );
    });
  });

  group('AppLocaleNotifier unit tests', () {
    test('initializes with ar when userSettingsProvider has ar', () async {
      final container = ProviderContainer(
        overrides: [
          userSettingsProvider.overrideWith(
            (ref) async => _mockSettings(preferredLanguage: 'ar'),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Listen to trigger build and wait for future
      container.listen(appLocaleProvider, (_, __) {});
      await container.read(userSettingsProvider.future);

      expect(container.read(appLocaleProvider), const Locale('ar'));
    });

    test('initializes with en when userSettingsProvider has en', () async {
      final container = ProviderContainer(
        overrides: [
          userSettingsProvider.overrideWith(
            (ref) async => _mockSettings(preferredLanguage: 'en'),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.listen(appLocaleProvider, (_, __) {});
      await container.read(userSettingsProvider.future);

      expect(container.read(appLocaleProvider), const Locale('en'));
    });

    test('setLocale and setLanguageCode update state', () {
      final container = ProviderContainer(
        overrides: [
          userSettingsProvider.overrideWith(
            (ref) async => _mockSettings(preferredLanguage: 'en'),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(appLocaleProvider), const Locale('en'));

      container.read(appLocaleProvider.notifier).setLanguageCode('ar');
      expect(container.read(appLocaleProvider), const Locale('ar'));

      container.read(appLocaleProvider.notifier).setLocale(const Locale('en'));
      expect(container.read(appLocaleProvider), const Locale('en'));
    });
  });

  group('VEN-S18 Notification Matrix', () {
    testWidgets('renders Push, Email, SMS channels and 4 categories',
        (tester) async {
      _setLargeViewport(tester);

      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(
        find.byKey(const Key('notification-preference-matrix')),
        findsOneWidget,
      );

      // 4 Categories
      expect(find.text('Request Matches'), findsOneWidget);
      expect(find.text('Offer Updates'), findsOneWidget);
      expect(find.text('Connection Alerts'), findsOneWidget);
      expect(find.text('Security & Disputes'), findsOneWidget);

      expect(
        find.byKey(const Key('notif-pref-category-request_matches')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('notif-pref-category-offer_updates')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('notif-pref-category-connection_alerts')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('notif-pref-category-security')),
        findsOneWidget,
      );

      // 3 Channels per category (4 categories * 3 channels = 12 toggles)
      expect(find.text('Push'), findsNWidgets(4));
      expect(find.text('Email'), findsNWidgets(4));
      expect(find.text('SMS'), findsNWidgets(4));
    });

    testWidgets('security category is locked and cannot be toggled off',
        (tester) async {
      _setLargeViewport(tester);

      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('notif-pref-lock-security')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('notif-pref-hint-security')),
        findsOneWidget,
      );
      expect(find.text('Required for account security'), findsOneWidget);

      final pushToggle = tester.widget<KhToggle>(
        find.byKey(const Key('notif-pref-security-push')),
      );
      expect(pushToggle.value, isTrue);
      expect(pushToggle.enabled, isFalse);
      expect(pushToggle.onChanged, isNull);

      final emailToggle = tester.widget<KhToggle>(
        find.byKey(const Key('notif-pref-security-email')),
      );
      expect(emailToggle.value, isTrue);
      expect(emailToggle.enabled, isFalse);
      expect(emailToggle.onChanged, isNull);

      final smsToggle = tester.widget<KhToggle>(
        find.byKey(const Key('notif-pref-security-inApp')),
      );
      expect(smsToggle.value, isTrue);
      expect(smsToggle.enabled, isFalse);
      expect(smsToggle.onChanged, isNull);

      // Attempt to tap locked push toggle
      await _tap(tester, find.byKey(const Key('notif-pref-security-push')));

      verifyNever(
        () => repo.patchSettings(
          preferredLanguage: any(named: 'preferredLanguage'),
          defaultRegionId: any(named: 'defaultRegionId'),
          quietHours: any(named: 'quietHours'),
          defaultFilterPresetId: any(named: 'defaultFilterPresetId'),
          notifications: any(named: 'notifications'),
        ),
      );
    });

    testWidgets(
        'unlocked notification category toggles call patchSettings(notifications: ...)',
        (tester) async {
      _setLargeViewport(tester);

      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Tap Push toggle for Request Matches
      await _tap(
        tester,
        find.descendant(
          of: find.byKey(const Key('notif-pref-request_matches-push')),
          matching: find.byType(Switch),
        ),
      );

      verify(
        () => repo.patchSettings(
          preferredLanguage: any(named: 'preferredLanguage'),
          defaultRegionId: any(named: 'defaultRegionId'),
          quietHours: any(named: 'quietHours'),
          defaultFilterPresetId: any(named: 'defaultFilterPresetId'),
          notifications: any(
            named: 'notifications',
            that: isA<Map<String, NotificationChannelPref>>().having(
              (m) => m['request_matches']?.push,
              'request_matches.push',
              isTrue,
            ),
          ),
        ),
      ).called(1);

      // Tap Email toggle for Offer Updates
      await _tap(
        tester,
        find.descendant(
          of: find.byKey(const Key('notif-pref-offer_updates-email')),
          matching: find.byType(Switch),
        ),
      );

      verify(
        () => repo.patchSettings(
          preferredLanguage: any(named: 'preferredLanguage'),
          defaultRegionId: any(named: 'defaultRegionId'),
          quietHours: any(named: 'quietHours'),
          defaultFilterPresetId: any(named: 'defaultFilterPresetId'),
          notifications: any(
            named: 'notifications',
            that: isA<Map<String, NotificationChannelPref>>().having(
              (m) => m['offer_updates']?.email,
              'offer_updates.email',
              isTrue,
            ),
          ),
        ),
      ).called(1);
    });
  });

  group('VEN-S18 Quiet Hours', () {
    testWidgets(
        'quiet hours toggle updates state and triggers patchSettings(quietHours: ...)',
        (tester) async {
      _setLargeViewport(tester);

      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('quiet-hours-toggle')), findsOneWidget);
      expect(
        tester
            .widget<KhToggle>(find.byKey(const Key('quiet-hours-toggle')))
            .value,
        isFalse,
      );
      expect(find.byKey(const Key('quiet-hours-start')), findsNothing);
      expect(find.byKey(const Key('quiet-hours-end')), findsNothing);

      // Enable quiet hours
      await _tap(
        tester,
        find.descendant(
          of: find.byKey(const Key('quiet-hours-toggle')),
          matching: find.byType(Switch),
        ),
      );

      verify(
        () => repo.patchSettings(
          preferredLanguage: any(named: 'preferredLanguage'),
          defaultRegionId: any(named: 'defaultRegionId'),
          quietHours: any(
            named: 'quietHours',
            that: isA<QuietHours>()
                .having((q) => q.start, 'start', '22:00')
                .having((q) => q.end, 'end', '07:00'),
          ),
          defaultFilterPresetId: any(named: 'defaultFilterPresetId'),
          notifications: any(named: 'notifications'),
        ),
      ).called(1);

      expect(find.byKey(const Key('quiet-hours-start')), findsOneWidget);
      expect(find.byKey(const Key('quiet-hours-end')), findsOneWidget);
      expect(find.text('22:00'), findsOneWidget);
      expect(find.text('07:00'), findsOneWidget);

      // Disable quiet hours
      await _tap(
        tester,
        find.descendant(
          of: find.byKey(const Key('quiet-hours-toggle')),
          matching: find.byType(Switch),
        ),
      );

      verify(
        () => repo.patchSettings(
          preferredLanguage: any(named: 'preferredLanguage'),
          defaultRegionId: any(named: 'defaultRegionId'),
          quietHours: null,
          defaultFilterPresetId: any(named: 'defaultFilterPresetId'),
          notifications: any(named: 'notifications'),
        ),
      ).called(1);

      expect(find.byKey(const Key('quiet-hours-start')), findsNothing);
      expect(find.byKey(const Key('quiet-hours-end')), findsNothing);
    });

    testWidgets(
        'tapping start time picker updates quiet hours and triggers patchSettings',
        (tester) async {
      _setLargeViewport(tester);

      currentQuietHours = const QuietHours(start: '22:00', end: '07:00');

      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
          ],
          child: SettingsScreen(
            timePicker: (context, {required initialTime}) async =>
                const TimeOfDay(hour: 23, minute: 15),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('22:00'), findsOneWidget);

      await _tap(tester, find.byKey(const Key('quiet-hours-start')));

      verify(
        () => repo.patchSettings(
          preferredLanguage: any(named: 'preferredLanguage'),
          defaultRegionId: any(named: 'defaultRegionId'),
          quietHours: any(
            named: 'quietHours',
            that: isA<QuietHours>()
                .having((q) => q.start, 'start', '23:15')
                .having((q) => q.end, 'end', '07:00'),
          ),
          defaultFilterPresetId: any(named: 'defaultFilterPresetId'),
          notifications: any(named: 'notifications'),
        ),
      ).called(1);

      expect(find.text('23:15'), findsOneWidget);
    });

    testWidgets(
        'tapping end time picker updates quiet hours and triggers patchSettings',
        (tester) async {
      _setLargeViewport(tester);

      currentQuietHours = const QuietHours(start: '22:00', end: '07:00');

      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
          ],
          child: SettingsScreen(
            timePicker: (context, {required initialTime}) async =>
                const TimeOfDay(hour: 8, minute: 30),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('07:00'), findsOneWidget);

      await _tap(tester, find.byKey(const Key('quiet-hours-end')));

      verify(
        () => repo.patchSettings(
          preferredLanguage: any(named: 'preferredLanguage'),
          defaultRegionId: any(named: 'defaultRegionId'),
          quietHours: any(
            named: 'quietHours',
            that: isA<QuietHours>()
                .having((q) => q.start, 'start', '22:00')
                .having((q) => q.end, 'end', '08:30'),
          ),
          defaultFilterPresetId: any(named: 'defaultFilterPresetId'),
          notifications: any(named: 'notifications'),
        ),
      ).called(1);

      expect(find.text('08:30'), findsOneWidget);
    });

    testWidgets('default showTimePicker opens time picker dialog',
        (tester) async {
      _setLargeViewport(tester);

      currentQuietHours = const QuietHours(start: '22:00', end: '07:00');

      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
          ],
          child: const SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await _tap(tester, find.byKey(const Key('quiet-hours-start')));

      expect(find.byType(TimePickerDialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      verify(
        () => repo.patchSettings(
          preferredLanguage: any(named: 'preferredLanguage'),
          defaultRegionId: any(named: 'defaultRegionId'),
          quietHours: any(
            named: 'quietHours',
            that: isA<QuietHours>()
                .having((q) => q.start, 'start', '22:00')
                .having((q) => q.end, 'end', '07:00'),
          ),
          defaultFilterPresetId: any(named: 'defaultFilterPresetId'),
          notifications: any(named: 'notifications'),
        ),
      ).called(1);
    });
  });

  group('VEN-S18 SettingsScreen Default Filter Preset (CP6-B03.4)', () {
    final samplePresets = [
      FilterPresetItem(
        id: 'pre-gold-bars',
        name: 'Gold Bullion 24K',
        filters: {'purityKarat': '24k'},
        createdAt: DateTime.utc(2026, 9, 8),
      ),
      FilterPresetItem(
        id: 'pre-rings',
        name: 'Diamond Rings',
        filters: {'categoryId': 'cat-ring'},
        createdAt: DateTime.utc(2026, 9, 8),
      ),
    ];

    testWidgets(
        'renders Default Filter Preset row with current selection or None',
        (tester) async {
      _setLargeViewport(tester);

      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
            filterPresetsListProvider.overrideWith((ref) async => samplePresets),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('default-filter-preset-row')),
        findsOneWidget,
      );
      expect(find.text('Default Filter Preset'), findsOneWidget);
      expect(find.text('None'), findsOneWidget);
    });

    testWidgets(
        'tapping Default Filter Preset opens dialog and selecting preset patches settings',
        (tester) async {
      _setLargeViewport(tester);

      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
            filterPresetsListProvider.overrideWith((ref) async => samplePresets),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await _tap(tester, find.byKey(const Key('default-filter-preset-row')));

      expect(find.text('Default Filter Preset'), findsWidgets);
      expect(find.byKey(const Key('preset-option-none')), findsOneWidget);
      expect(
        find.byKey(const Key('preset-option-pre-gold-bars')),
        findsOneWidget,
      );
      expect(find.text('Gold Bullion 24K'), findsOneWidget);

      await tester.tap(find.byKey(const Key('preset-option-pre-gold-bars')));
      await tester.pumpAndSettle();

      verify(
        () => repo.patchSettings(
          preferredLanguage: any(named: 'preferredLanguage'),
          defaultRegionId: any(named: 'defaultRegionId'),
          quietHours: any(named: 'quietHours'),
          defaultFilterPresetId: 'pre-gold-bars',
          notifications: any(named: 'notifications'),
        ),
      ).called(1);

      expect(find.text('Gold Bullion 24K'), findsOneWidget);
    });

    testWidgets('selecting None clears the default preset', (tester) async {
      _setLargeViewport(tester);
      currentDefaultFilterPresetId = 'pre-gold-bars';

      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
            filterPresetsListProvider.overrideWith((ref) async => samplePresets),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gold Bullion 24K'), findsOneWidget);

      await _tap(tester, find.byKey(const Key('default-filter-preset-row')));
      await tester.tap(find.byKey(const Key('preset-option-none')));
      await tester.pumpAndSettle();

      verify(
        () => repo.patchSettings(
          preferredLanguage: any(named: 'preferredLanguage'),
          defaultRegionId: any(named: 'defaultRegionId'),
          quietHours: any(named: 'quietHours'),
          defaultFilterPresetId: '',
          notifications: any(named: 'notifications'),
        ),
      ).called(1);

      expect(find.text('None'), findsOneWidget);
    });
  });

  group('VEN-S18 SettingsScreen Password & Active Sessions (CP6-B03.5)', () {
    final sampleSessions = [
      AuthSessionDto(
        id: 'session-curr',
        deviceLabel: 'Safari on macOS',
        lastIp: '192.168.1.5',
        lastUsedAt: DateTime.utc(2026, 9, 8, 14, 30),
        createdAt: DateTime.utc(2026, 9, 1),
        isCurrent: true,
      ),
      AuthSessionDto(
        id: 'session-other',
        deviceLabel: 'iPhone 15 Pro, iOS 17.4',
        lastIp: '10.0.0.4',
        lastUsedAt: DateTime.utc(2026, 9, 7, 10, 15),
        createdAt: DateTime.utc(2026, 9, 2),
        isCurrent: false,
      ),
    ];

    testWidgets('change password dialog validates policy and mismatch',
        (tester) async {
      _setLargeViewport(tester);

      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await _tap(tester, find.byKey(const Key('change-password-row')));
      expect(find.text('Change Password'), findsWidgets);

      // Submit empty
      await tester.tap(find.byKey(const Key('submit-password-button')));
      await tester.pumpAndSettle();
      expect(find.text('Current password is required.'), findsOneWidget);

      // Enter current password and weak new password (< 8 chars)
      await tester.enterText(
        find.byKey(const Key('current-password-input')),
        'oldpassword123',
      );
      await tester.enterText(
        find.byKey(const Key('new-password-input')),
        'Short1!',
      );
      await tester.tap(find.byKey(const Key('submit-password-button')));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Password must be at least 8 characters, include 1 uppercase letter, 1 number, and 1 symbol.',
        ),
        findsOneWidget,
      );

      // Enter mismatched confirm password
      await tester.enterText(
        find.byKey(const Key('new-password-input')),
        'StrongPassword1!',
      );
      await tester.enterText(
        find.byKey(const Key('confirm-password-input')),
        'MismatchPassword1!',
      );
      await tester.tap(find.byKey(const Key('submit-password-button')));
      await tester.pumpAndSettle();
      expect(find.text('Passwords do not match.'), findsOneWidget);
    });

    testWidgets(
        'submitting valid password invokes setPassword and shows snackbar',
        (tester) async {
      _setLargeViewport(tester);

      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await _tap(tester, find.byKey(const Key('change-password-row')));

      await tester.enterText(
        find.byKey(const Key('current-password-input')),
        'CurrentPass123!',
      );
      await tester.enterText(
        find.byKey(const Key('new-password-input')),
        'NewStrongPass123!',
      );
      await tester.enterText(
        find.byKey(const Key('confirm-password-input')),
        'NewStrongPass123!',
      );
      await tester.tap(find.byKey(const Key('submit-password-button')));
      await tester.pumpAndSettle();

      verify(
        () => repo.setPassword(
          currentPassword: 'CurrentPass123!',
          newPassword: 'NewStrongPass123!',
        ),
      ).called(1);

      expect(find.text('Password changed successfully.'), findsOneWidget);
    });

    testWidgets(
        'renders active sessions list with platform icon, IP, and badges',
        (tester) async {
      _setLargeViewport(tester);
      when(() => repo.listSessions()).thenAnswer((_) async => Ok(sampleSessions));

      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Active Sessions'), findsOneWidget);
      expect(find.text('Safari on macOS'), findsOneWidget);
      expect(find.text('iPhone 15 Pro, iOS 17.4'), findsOneWidget);
      expect(find.textContaining('192.168.1.5'), findsOneWidget);
      expect(find.textContaining('10.0.0.4'), findsOneWidget);

      // Current device badge
      expect(
        find.byKey(const Key('current-device-badge-session-curr')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('revoke-button-session-curr')),
        findsNothing,
      );

      // Other device revoke button
      expect(
        find.byKey(const Key('revoke-button-session-other')),
        findsOneWidget,
      );

      // Verify Last active timestamp formatting in GST (UTC+4)
      expect(
        find.textContaining('Last active: 08/09/2026 18:30'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Last active: 07/09/2026 14:15'),
        findsOneWidget,
      );
    });

    testWidgets(
        'formats session last active timestamp according to GST (UTC+4 offset)',
        (tester) async {
      _setLargeViewport(tester);
      // UTC timestamp crossing midnight when converted to GST (+4h):
      // 2026-09-08 21:45 UTC -> 2026-09-09 01:45 GST
      final gstSession = [
        AuthSessionDto(
          id: 'session-gst-midnight',
          deviceLabel: 'Chrome on Linux',
          lastIp: '127.0.0.1',
          lastUsedAt: DateTime.utc(2026, 9, 8, 21, 45),
          createdAt: DateTime.utc(2026, 9, 1),
          isCurrent: true,
        ),
      ];
      when(() => repo.listSessions()).thenAnswer((_) async => Ok(gstSession));

      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('IP: 127.0.0.1 • Last active: 09/09/2026 01:45'),
        findsOneWidget,
      );
    });

    testWidgets(
        'revoking session shows confirm dialog and invokes repo.revokeSession',
        (tester) async {
      _setLargeViewport(tester);
      when(() => repo.listSessions()).thenAnswer((_) async => Ok(sampleSessions));

      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await _tap(tester, find.byKey(const Key('revoke-button-session-other')));

      expect(find.text('Revoke Session'), findsOneWidget);
      expect(
        find.text(
          'Are you sure you want to revoke this session? That device will be signed out immediately.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Revoke'));
      await tester.pumpAndSettle();

      verify(() => repo.revokeSession('session-other')).called(1);
      expect(find.text('Session revoked successfully.'), findsOneWidget);
    });
  });

  group('VEN-S18 SettingsScreen Legal, App Version, Logout (CP6-B03.6)', () {
    testWidgets('tapping legal rows triggers openUrl callback', (tester) async {
      _setLargeViewport(tester);
      final openedUrls = <String>[];

      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
          ],
          child: SettingsScreen(
            openUrl: (url) async {
              openedUrls.add(url);
              return true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _tap(tester, find.byKey(const Key('terms-of-service-row')));
      expect(openedUrls, contains('https://karathive.ae/terms'));

      await _tap(tester, find.byKey(const Key('privacy-policy-row')));
      expect(openedUrls, contains('https://karathive.ae/privacy'));

      await _tap(tester, find.byKey(const Key('support-help-row')));
      expect(openedUrls, contains('https://karathive.ae/support'));
    });

    testWidgets('renders App Version row with correct version text',
        (tester) async {
      _setLargeViewport(tester);

      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('app-version-row')), findsOneWidget);
      expect(find.text('App Version'), findsOneWidget);
      expect(find.text('v1.0.0 (build 42)'), findsOneWidget);
    });

    testWidgets(
        'tapping Log Out row shows confirmation dialog and invokes onLogout',
        (tester) async {
      _setLargeViewport(tester);
      var loggedOut = false;

      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
          ],
          child: SettingsScreen(
            onLogout: () async {
              loggedOut = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _tap(tester, find.byKey(const Key('logout-row')));

      expect(find.text('Log Out'), findsWidgets);
      expect(
        find.text('Are you sure you want to log out of your account?'),
        findsOneWidget,
      );

      // Confirm log out
      await tester.tap(find.widgetWithText(FilledButton, 'Log Out'));
      await tester.pumpAndSettle();

      expect(loggedOut, isTrue);
    });

    testWidgets('cancelling Log Out dialog does not invoke onLogout',
        (tester) async {
      _setLargeViewport(tester);
      var loggedOut = false;

      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
          ],
          child: SettingsScreen(
            onLogout: () async {
              loggedOut = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _tap(tester, find.byKey(const Key('logout-row')));

      expect(find.text('Log Out'), findsWidgets);

      // Cancel
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(loggedOut, isFalse);
    });
  });
}
