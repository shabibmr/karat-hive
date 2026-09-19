import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/profile_settings/controller/settings_controller.dart';
import 'package:karat_hive/features/profile_settings/presentation/customer_settings_screen.dart';
import 'package:karat_hive/features/profile_settings/repository/profile_settings_repository.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileSettingsRepository extends Mock
    implements ProfileSettingsRepository {}

Widget _host({
  required List<Override> overrides,
  Widget child = const CustomerSettingsScreen(),
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

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

UserSettings _mockSettings({
  String preferredLanguage = 'en',
  String? defaultRegionId,
  Map<String, NotificationChannelPref> notifications = const {},
}) =>
    UserSettings(
      preferredLanguage: preferredLanguage,
      defaultRegionId: defaultRegionId,
      notifications: notifications,
    );

void main() {
  late _MockProfileSettingsRepository repo;

  setUp(() {
    repo = _MockProfileSettingsRepository();
    when(() => repo.settings())
        .thenAnswer((_) async => Ok(_mockSettings()));
    when(
      () => repo.patchSettings(
        preferredLanguage: any(named: 'preferredLanguage'),
        defaultRegionId: any(named: 'defaultRegionId'),
        quietHours: any(named: 'quietHours'),
        defaultFilterPresetId: any(named: 'defaultFilterPresetId'),
        notifications: any(named: 'notifications'),
      ),
    ).thenAnswer((_) async => Ok(_mockSettings()));
  });

  testWidgets('CUS-S21 renders account action rows', (tester) async {
    await tester.pumpWidget(
      _host(overrides: [
        profileSettingsRepositoryProvider.overrideWithValue(repo),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer-settings-logout-row')), findsOneWidget);
    expect(find.byKey(const Key('deactivate-account-row')), findsOneWidget);
    expect(find.byKey(const Key('request-deletion-row')), findsOneWidget);
    expect(find.byKey(const Key('app-version-row')), findsOneWidget);
  });

  group('Deactivate account', () {
    testWidgets('confirm deactivates and logs out', (tester) async {
      when(() => repo.deactivateAccount()).thenAnswer(
        (_) async => Ok(
          const MeUser(
            userId: 'u2',
            userType: 'CUSTOMER',
            mobileNumber: '+971500000002',
            preferredLanguage: 'en',
            accountState: AccountState.deactivated,
          ),
        ),
      );

      var loggedOut = false;
      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
          ],
          child: CustomerSettingsScreen(onLogout: () async => loggedOut = true),
        ),
      );
      await tester.pumpAndSettle();

      await _tap(tester, find.byKey(const Key('deactivate-account-row')));
      await tester.tap(find.widgetWithText(FilledButton, 'Deactivate'));
      await tester.pumpAndSettle();

      verify(() => repo.deactivateAccount()).called(1);
      expect(loggedOut, isTrue);
    });

    testWidgets('failure (recent Connection) surfaces server message',
        (tester) async {
      when(() => repo.deactivateAccount()).thenAnswer(
        (_) async => const Err(
          ConflictFailure(message: 'Blocked by a recent Connection.'),
        ),
      );

      await tester.pumpWidget(
        _host(overrides: [
          profileSettingsRepositoryProvider.overrideWithValue(repo),
        ]),
      );
      await tester.pumpAndSettle();

      await _tap(tester, find.byKey(const Key('deactivate-account-row')));
      await tester.tap(find.widgetWithText(FilledButton, 'Deactivate'));
      await tester.pumpAndSettle();

      expect(find.text('Blocked by a recent Connection.'), findsOneWidget);
    });
  });

  group('Request permanent deletion', () {
    testWidgets('two-step OTP confirm succeeds', (tester) async {
      when(() => repo.createDeletionRequest()).thenAnswer(
        (_) async => Ok(
          AccountDeletionRequest(
            id: 'del1',
            state: 'PENDING_OTP',
            createdAt: DateTime.utc(2026, 9, 16),
            challengeId: 'chal1',
          ),
        ),
      );
      when(
        () => repo.verifyDeletionOtp(
          challengeId: 'chal1',
          code: '123456',
        ),
      ).thenAnswer(
        (_) async => const Ok(OtpVerifyResult(mobileVerified: true)),
      );
      when(
        () => repo.confirmDeletionRequest('del1', challengeId: 'chal1'),
      ).thenAnswer(
        (_) async => Ok(
          AccountDeletionRequest(
            id: 'del1',
            state: 'CONFIRMED',
            createdAt: DateTime.utc(2026, 9, 16),
          ),
        ),
      );

      var loggedOut = false;
      await tester.pumpWidget(
        _host(
          overrides: [
            profileSettingsRepositoryProvider.overrideWithValue(repo),
          ],
          child: CustomerSettingsScreen(onLogout: () async => loggedOut = true),
        ),
      );
      await tester.pumpAndSettle();

      await _tap(tester, find.byKey(const Key('request-deletion-row')));
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('deletion-otp-input')), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('deletion-otp-input')),
        '123456',
      );
      await _tap(
        tester,
        find.byKey(const Key('deletion-otp-submit-button')),
      );

      verify(() => repo.createDeletionRequest()).called(1);
      verify(() => repo.verifyDeletionOtp(challengeId: 'chal1', code: '123456'))
          .called(1);
      verify(() => repo.confirmDeletionRequest('del1', challengeId: 'chal1'))
          .called(1);
      expect(loggedOut, isTrue);
    });

    testWidgets('blocked by recent Connection surfaces server message',
        (tester) async {
      when(() => repo.createDeletionRequest()).thenAnswer(
        (_) async => const Err(
          ConflictFailure(
            message: 'Refused: Connection created within the last 30 days.',
          ),
        ),
      );

      await tester.pumpWidget(
        _host(overrides: [
          profileSettingsRepositoryProvider.overrideWithValue(repo),
        ]),
      );
      await tester.pumpAndSettle();

      await _tap(tester, find.byKey(const Key('request-deletion-row')));
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(
        find.text('Refused: Connection created within the last 30 days.'),
        findsOneWidget,
      );
    });

    testWidgets('wrong OTP code shows inline error, does not confirm',
        (tester) async {
      when(() => repo.createDeletionRequest()).thenAnswer(
        (_) async => Ok(
          AccountDeletionRequest(
            id: 'del1',
            state: 'PENDING_OTP',
            createdAt: DateTime.utc(2026, 9, 16),
            challengeId: 'chal1',
          ),
        ),
      );
      when(
        () => repo.verifyDeletionOtp(
          challengeId: 'chal1',
          code: any(named: 'code'),
        ),
      ).thenAnswer(
        (_) async => const Ok(OtpVerifyResult(mobileVerified: false)),
      );

      await tester.pumpWidget(
        _host(overrides: [
          profileSettingsRepositoryProvider.overrideWithValue(repo),
        ]),
      );
      await tester.pumpAndSettle();

      await _tap(tester, find.byKey(const Key('request-deletion-row')));
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('deletion-otp-input')),
        '000000',
      );
      await _tap(
        tester,
        find.byKey(const Key('deletion-otp-submit-button')),
      );

      expect(find.byKey(const Key('deletion-otp-error')), findsOneWidget);
      verifyNever(
        () => repo.confirmDeletionRequest(any(), challengeId: any(named: 'challengeId')),
      );
    });
  });
}
