import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/api/api_exception.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/settings/model/platform_setting_item.dart';
import 'package:kh_admin/features/settings/presentation/platform_settings_screen.dart';
import 'package:kh_admin/features/settings/repository/platform_settings_repository.dart';

class _MockSettingsRepository extends PlatformSettingsRepository {
  _MockSettingsRepository() : super(ApiClient());

  List<PlatformSettingItem> mockItems = [
    PlatformSettingItem(
      key: 'request.lifetime_hours',
      value: 48,
      dataType: 'number',
      description: 'Request lifetime in hours before expiration.',
      allowedRange: const SettingAllowedRange(min: 1, max: 168),
      category: SettingCategory.lifecycle,
    ),
    PlatformSettingItem(
      key: 'offer.validity_hours_options',
      value: [12, 24, 48],
      dataType: 'number[]',
      description: 'Available validity options in hours for vendor offers.',
      category: SettingCategory.lifecycle,
    ),
    PlatformSettingItem(
      key: 'offer.default_validity_hours',
      value: 24,
      dataType: 'number',
      description: 'Default expiration window for offers.',
      allowedRange: const SettingAllowedRange(
        enumValues: PlatformSettingItem.offerValidityHours,
      ),
      category: SettingCategory.lifecycle,
    ),
    PlatformSettingItem(
      key: 'bullion.minimum_value_aed',
      value: 500,
      dataType: 'money',
      description: 'Minimum listing threshold for bullion.',
      allowedRange: const SettingAllowedRange(min: 100),
      category: SettingCategory.limits,
    ),
    PlatformSettingItem(
      key: 'media.image.max_bytes',
      value: 5242880,
      dataType: 'number',
      description: 'Max image upload bytes.',
      allowedRange: const SettingAllowedRange(min: 1024, max: 20971520),
      category: SettingCategory.media,
    ),
    PlatformSettingItem(
      key: 'goldRates.endUserDisplay',
      value: false,
      dataType: 'boolean',
      description: 'Feature gate for end-user gold rates.',
      requiresSuperAdmin: true,
      category: SettingCategory.security,
    ),
  ];

  String? lastUpdatedKey;
  dynamic lastUpdatedValue;
  bool? lastUpdatedConfirm;
  bool shouldThrowRangeError = false;
  bool failFetch = false;
  Completer<List<PlatformSettingItem>>? delay;

  @override
  Future<List<PlatformSettingItem>> fetchSettings() async {
    if (delay != null) return delay!.future;
    if (failFetch) {
      throw ApiException(
        statusCode: 500,
        code: 'INTERNAL_ERROR',
        message: 'Settings service unavailable',
      );
    }
    return mockItems;
  }

  @override
  Future<PlatformSettingItem> updateSetting(
    String key,
    dynamic value, {
    bool? confirm,
  }) async {
    lastUpdatedKey = key;
    lastUpdatedValue = value;
    lastUpdatedConfirm = confirm;

    if (shouldThrowRangeError) {
      throw ApiException(
        statusCode: 400,
        code: 'SETTING_OUT_OF_RANGE',
        message: 'Supplied setting value is outside permitted allowedRange.',
      );
    }

    final index = mockItems.indexWhere((s) => s.key == key);
    final updated = PlatformSettingItem(
      key: key,
      value: value,
      dataType: index >= 0 ? mockItems[index].dataType : 'string',
      description: index >= 0 ? mockItems[index].description : null,
      allowedRange: index >= 0 ? mockItems[index].allowedRange : null,
      requiresSuperAdmin:
          index >= 0 ? mockItems[index].requiresSuperAdmin : false,
      category: index >= 0 ? mockItems[index].category : null,
    );
    if (index >= 0) {
      mockItems[index] = updated;
    }
    return updated;
  }
}

void main() {
  Widget buildTestableScreen({required PlatformSettingsRepository repository}) {
    return ProviderScope(
      overrides: [
        platformSettingsRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: buildKhAdminTheme(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: const Scaffold(
          body: PlatformSettingsScreen(),
        ),
      ),
    );
  }

  group('PlatformSettingsScreen', () {
    testWidgets('renders screen header, metrics, decision banner, and settings table',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _MockSettingsRepository();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      expect(find.text('PLATFORM GOVERNANCE'), findsOneWidget);
      expect(find.text('Platform Settings'), findsOneWidget);

      expect(find.text('TOTAL SETTINGS'), findsOneWidget);
      expect(find.text('LIFECYCLE RULES'), findsOneWidget);
      expect(find.text('TRADING LIMITS'), findsOneWidget);
      expect(find.text('MEDIA & STORAGE'), findsOneWidget);

      expect(find.byKey(const Key('offer-validity-decision-banner')), findsOneWidget);
      expect(
        find.text('ARCHITECTURE DECISION PENDING: OFFER VALIDITY MODEL'),
        findsOneWidget,
      );
      expect(find.text('PENDING DECISION'), findsOneWidget);

      expect(find.text('request.lifetime_hours'), findsOneWidget);
      expect(find.text('bullion.minimum_value_aed'), findsOneWidget);
      expect(find.text('goldRates.endUserDisplay'), findsOneWidget);

      // Offer validity decision badges
      expect(find.text('Decision Pending'), findsNWidgets(2));
    });

    testWidgets('category filter pills filter the settings table', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _MockSettingsRepository();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      // Tap Trading Limits
      await tester.tap(find.textContaining('Trading Limits (1)'));
      await tester.pumpAndSettle();

      expect(find.text('bullion.minimum_value_aed'), findsOneWidget);
      expect(find.text('request.lifetime_hours'), findsNothing);

      // Tap All Settings
      await tester.tap(find.textContaining('All Settings'));
      await tester.pumpAndSettle();

      expect(find.text('request.lifetime_hours'), findsOneWidget);
      expect(find.text('bullion.minimum_value_aed'), findsOneWidget);
    });

    testWidgets('search query filters rows by key and description', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _MockSettingsRepository();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('settings-search-field')),
        'bullion',
      );
      await tester.pumpAndSettle();

      expect(find.text('bullion.minimum_value_aed'), findsOneWidget);
      expect(find.text('request.lifetime_hours'), findsNothing);
    });

    testWidgets('opens edit dialog and edits numeric setting within allowedRange',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _MockSettingsRepository();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      // Tap edit button for request.lifetime_hours
      final editBtn = find.byKey(const Key('edit-setting-request.lifetime_hours'));
      expect(editBtn, findsOneWidget);
      await tester.tap(editBtn);
      await tester.pumpAndSettle();

      expect(find.text('Edit Platform Setting'), findsOneWidget);
      expect(find.textContaining('Allowed Range: Range: 1 - 168'), findsOneWidget);

      final valueField = find.byKey(const Key('setting-value-field'));
      expect(valueField, findsOneWidget);

      // Test client-side range validation failure (value 500 > max 168)
      await tester.enterText(valueField, '500');
      await tester.tap(find.byKey(const Key('save-setting-button')));
      await tester.pumpAndSettle();

      expect(find.text('Value must be at most 168'), findsOneWidget);
      expect(repo.lastUpdatedKey, isNull);

      // Enter valid value 72
      await tester.enterText(valueField, '72');
      await tester.tap(find.byKey(const Key('save-setting-button')));
      await tester.pumpAndSettle();

      expect(repo.lastUpdatedKey, 'request.lifetime_hours');
      expect(repo.lastUpdatedValue, 72);
      expect(find.text('Edit Platform Setting'), findsNothing);
    });

    testWidgets('requires Super-Admin confirmation checkbox for sensitive parameters',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _MockSettingsRepository();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      // Tap edit button for goldRates.endUserDisplay (requiresSuperAdmin: true)
      final editBtn = find.byKey(const Key('edit-setting-goldRates.endUserDisplay'));
      expect(editBtn, findsOneWidget);
      await tester.tap(editBtn);
      await tester.pumpAndSettle();

      expect(find.text('SUPER-ADMIN CONFIRMATION REQUIRED'), findsOneWidget);

      // Toggle boolean switch
      await tester.tap(find.byKey(const Key('setting-boolean-switch')));
      await tester.pumpAndSettle();

      // Attempt submit without super admin confirm
      await tester.tap(find.byKey(const Key('save-setting-button')));
      await tester.pumpAndSettle();

      expect(
        find.text('Super-Admin confirmation is required for this parameter.'),
        findsOneWidget,
      );
      expect(repo.lastUpdatedKey, isNull);

      // Check the confirmation checkbox
      await tester.tap(find.byKey(const Key('super-admin-confirm-checkbox')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save-setting-button')));
      await tester.pumpAndSettle();

      expect(repo.lastUpdatedKey, 'goldRates.endUserDisplay');
      expect(repo.lastUpdatedValue, true);
      expect(repo.lastUpdatedConfirm, true);
    });

    testWidgets('shows loading indicator while settings are in flight',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _MockSettingsRepository()
        ..delay = Completer<List<PlatformSettingItem>>();
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pump();

      expect(find.byKey(const Key('settings-list-loading')), findsOneWidget);

      repo.delay!.complete(const []);
      await tester.pumpAndSettle();
    });

    testWidgets('shows empty state when no settings match', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _MockSettingsRepository()..mockItems = [];
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('settings-list-empty')), findsOneWidget);
    });

    testWidgets('shows error state and retries on failure', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _MockSettingsRepository()..failFetch = true;
      await tester.pumpWidget(buildTestableScreen(repository: repo));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('settings-list-error')), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
