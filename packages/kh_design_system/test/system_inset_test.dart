import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const phone = Size(390, 844);
  const statusBar = 47.0;
  const homeIndicator = 34.0;

  Future<void> pumpPhone(
    WidgetTester tester, {
    required Widget child,
    double keyboard = 0,
  }) async {
    tester.view.physicalSize = phone;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: KhTheme.light(),
        builder: (context, routed) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(
              padding: EdgeInsets.only(
                top: statusBar,
                bottom: keyboard > 0 ? 0 : homeIndicator,
              ),
              viewPadding: const EdgeInsets.only(
                top: statusBar,
                bottom: homeIndicator,
              ),
              viewInsets: EdgeInsets.only(bottom: keyboard),
            ),
            child: KhSystemInset(child: routed!),
          );
        },
        home: child,
      ),
    );
  }

  testWidgets('phone controls sit inside the status bar and home indicator', (
    tester,
  ) async {
    await pumpPhone(
      tester,
      child: const Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: Text('Title', key: Key('title')),
        ),
        bottomNavigationBar: SizedBox(
          key: Key('nav'),
          height: 56,
          child: Center(child: Text('Home')),
        ),
      ),
    );

    expect(tester.getTopLeft(find.byKey(const Key('title'))).dy,
        greaterThanOrEqualTo(statusBar));
    expect(
      tester.getBottomLeft(find.byKey(const Key('nav'))).dy,
      lessThanOrEqualTo(phone.height - homeIndicator),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('keyboard does not stack the home indicator on the buttons', (
    tester,
  ) async {
    const keyboard = 300.0;
    await pumpPhone(
      tester,
      keyboard: keyboard,
      child: const Scaffold(
        resizeToAvoidBottomInset: true,
        body: Align(
          alignment: Alignment.bottomCenter,
          child: Text('Continue', key: Key('continue')),
        ),
      ),
    );

    final bottom = tester.getBottomLeft(find.byKey(const Key('continue'))).dy;
    // Above the keyboard, and not pushed up by another home-indicator gap.
    expect(bottom, lessThanOrEqualTo(phone.height - keyboard));
    expect(bottom, greaterThan(phone.height - keyboard - homeIndicator));
  });
}
