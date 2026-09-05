import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/auth/presentation/vendor_login_screen.dart';
import 'package:karat_hive/features/auth/repository/auth_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepo extends Mock implements AuthRepository {}

Widget _host(Widget child, List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        localizationsDelegates: KhStrings.delegates,
        supportedLocales: KhStrings.supportedLocales,
        home: child,
      ),
    );

void main() {
  testWidgets('shows an inline error when OTP request fails (SH-FND-13)', (tester) async {
    final repo = _MockAuthRepo();
    when(() => repo.requestOtp(any(), any())).thenAnswer(
      (_) async => const Err(RateLimitedFailure(message: 'Too many codes requested.')),
    );

    await tester.pumpWidget(
      _host(const VendorLoginScreen(), [authRepositoryProvider.overrideWithValue(repo)]),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '+971500000001');
    await tester.tap(find.text('Send code'));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('inline-error')), findsOneWidget);
    expect(find.text('Too many codes requested.'), findsOneWidget);
  });

  testWidgets('renders both sign-in tabs', (tester) async {
    await tester.pumpWidget(
      _host(const VendorLoginScreen(), const []),
    );
    await tester.pumpAndSettle();
    expect(find.text('Mobile & code'), findsOneWidget);
    expect(find.text('Email & password'), findsOneWidget);
  });
}
