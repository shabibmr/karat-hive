import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/profile_settings/controller/settings_controller.dart';
import 'package:karat_hive/features/profile_settings/presentation/customer_profile_screen.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

Widget _host({Widget child = const CustomerProfileScreen()}) {
  return ProviderScope(
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

void main() {
  testWidgets('renders a Log Out row', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer-logout-row')), findsOneWidget);
  });

  testWidgets('tapping Log Out shows confirmation dialog and invokes onLogout',
      (tester) async {
    var loggedOut = false;

    await tester.pumpWidget(
      _host(
        child: CustomerProfileScreen(
          onLogout: () async {
            loggedOut = true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _tap(tester, find.byKey(const Key('customer-logout-row')));

    expect(
      find.text('Are you sure you want to log out of your account?'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Log Out'));
    await tester.pumpAndSettle();

    expect(loggedOut, isTrue);
  });

  testWidgets('cancelling the dialog does not invoke onLogout', (tester) async {
    var loggedOut = false;

    await tester.pumpWidget(
      _host(
        child: CustomerProfileScreen(
          onLogout: () async {
            loggedOut = true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _tap(tester, find.byKey(const Key('customer-logout-row')));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(loggedOut, isFalse);
  });
}
