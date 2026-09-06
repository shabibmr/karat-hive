import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

Widget _host(Widget child) => MaterialApp(
      theme: khTheme(),
      home: Scaffold(body: child),
    );

void main() {
  group('ExpiryCountdown (SH-DOM-07)', () {
    testWidgets('derives countdown from ServerClock offset, not device time', (tester) async {
      final clock = ServerClock();
      final deviceNow = DateTime.now().toUtc();
      clock.syncFrom(deviceNow.add(const Duration(hours: 2)));

      final expiresAt = deviceNow.add(const Duration(hours: 3));

      await tester.pumpWidget(
        _host(
          ExpiryCountdown(
            expiresAt: expiresAt,
            clock: clock,
          ),
        ),
      );

      expect(find.textContaining('left'), findsOneWidget);
      expect(find.textContaining('1h 0m left'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('displays normal urgency styling when > 24 hours remaining', (tester) async {
      final clock = ServerClock();
      final now = clock.now();
      final expiresAt = now.add(const Duration(hours: 36));

      await tester.pumpWidget(
        _host(
          ExpiryCountdown(
            expiresAt: expiresAt,
            clock: clock,
          ),
        ),
      );

      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.textContaining('1d 12h left'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('displays warning urgency styling when between 6 and 24 hours remaining', (tester) async {
      final clock = ServerClock();
      final now = clock.now();
      final expiresAt = now.add(const Duration(hours: 12));

      await tester.pumpWidget(
        _host(
          ExpiryCountdown(
            expiresAt: expiresAt,
            clock: clock,
          ),
        ),
      );

      expect(find.byIcon(Icons.access_time_filled), findsOneWidget);
      expect(find.textContaining('12h 0m left'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('displays critical urgency styling when < 6 hours remaining', (tester) async {
      final clock = ServerClock();
      final now = clock.now();
      final expiresAt = now.add(const Duration(hours: 3));

      await tester.pumpWidget(
        _host(
          ExpiryCountdown(
            expiresAt: expiresAt,
            clock: clock,
          ),
        ),
      );

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.textContaining('3h 0m left'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('displays expired label and invokes onExpired callback when past deadline', (tester) async {
      final clock = ServerClock();
      final now = clock.now();
      final expiresAt = now.subtract(const Duration(seconds: 10));

      bool expiredNotified = false;

      await tester.pumpWidget(
        _host(
          ExpiryCountdown(
            expiresAt: expiresAt,
            clock: clock,
            onExpired: () {
              expiredNotified = true;
            },
          ),
        ),
      );

      expect(find.byIcon(Icons.timer_off_outlined), findsOneWidget);
      expect(find.text('Expired'), findsOneWidget);
      expect(expiredNotified, isTrue);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('ticks internally on timer without rebuilding outer widget', (tester) async {
      DateTime simulatedNow = DateTime.utc(2026, 9, 7, 12, 0, 0);
      final clock = ServerClock(nowProvider: () => simulatedNow);
      final expiresAt = simulatedNow.add(const Duration(seconds: 5));

      int outerBuildCount = 0;

      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) {
              outerBuildCount++;
              return ExpiryCountdown(
                expiresAt: expiresAt,
                clock: clock,
              );
            },
          ),
        ),
      );

      expect(outerBuildCount, 1);
      expect(find.text('5s left'), findsOneWidget);

      // Advance simulated clock by 1 second and pump
      simulatedNow = simulatedNow.add(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('4s left'), findsOneWidget);
      // Outer builder was NOT rebuilt
      expect(outerBuildCount, 1);

      // Advance another 2 seconds
      simulatedNow = simulatedNow.add(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('2s left'), findsOneWidget);
      expect(outerBuildCount, 1);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('resolves clock from ServerClockScope', (tester) async {
      final clock = ServerClock();
      final deviceNow = DateTime.now().toUtc();
      clock.syncFrom(deviceNow.add(const Duration(hours: 10)));
      final expiresAt = deviceNow.add(const Duration(hours: 11));

      await tester.pumpWidget(
        _host(
          ServerClockScope(
            clock: clock,
            child: ExpiryCountdown(
              expiresAt: expiresAt,
            ),
          ),
        ),
      );

      expect(find.textContaining('1h 0m left'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
