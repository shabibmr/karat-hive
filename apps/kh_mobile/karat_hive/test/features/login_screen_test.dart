import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/auth/presentation/vendor_login_screen.dart';
import 'package:karat_hive/features/auth/repository/auth_repository.dart';
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
  testWidgets('renders Google-only vendor sign-in (adr/0010)', (tester) async {
    final repo = _MockAuthRepo();

    await tester.pumpWidget(
      _host(const VendorLoginScreen(), [
        authRepositoryProvider.overrideWithValue(repo),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('vendor-google-signin')), findsOneWidget);
    expect(find.textContaining('Sign in with Google'), findsOneWidget);
    expect(find.text('Mobile & code'), findsNothing);
    expect(find.text('Email & password'), findsNothing);
    expect(find.text('Send code'), findsNothing);
  });
}
