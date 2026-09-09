import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/auth/idle_timeout.dart';
import 'package:kh_admin/core/auth/session_controller.dart';
import 'package:kh_admin/core/auth/session_state.dart';

class _MockSessionController extends StateNotifier<SessionState>
    implements SessionController {
  _MockSessionController()
      : super(const SessionState(status: SessionStatus.authenticated));

  bool logoutCalled = false;
  int logoutCallCount = 0;

  @override
  Future<void> init() async {}

  @override
  Future<void> login(String email, String password) async {}

  @override
  Future<void> loginWithPassword(String email, String password) async {}

  @override
  Future<void> logout({bool broadcast = true}) async {
    logoutCalled = true;
    logoutCallCount++;
    state = const SessionState(status: SessionStatus.unauthenticated);
  }

  @override
  Future<bool> silentRefresh() async => true;
}

void main() {
  group('IdleTimeoutManager', () {
    testWidgets('fires onTimeout when idle for specified duration', (tester) async {
      int timeoutCount = 0;
      final manager = IdleTimeoutManager(
        timeout: const Duration(minutes: 60),
        onTimeout: () => timeoutCount++,
      );

      expect(manager.isActive, isTrue);
      expect(timeoutCount, equals(0));

      await tester.pump(const Duration(minutes: 59));
      expect(timeoutCount, equals(0));

      await tester.pump(const Duration(minutes: 1));
      expect(timeoutCount, equals(1));

      manager.dispose();
    });

    testWidgets('recordActivity resets timer and delays timeout', (tester) async {
      int timeoutCount = 0;
      final manager = IdleTimeoutManager(
        timeout: const Duration(minutes: 60),
        onTimeout: () => timeoutCount++,
      );

      // Elapse 45 minutes
      await tester.pump(const Duration(minutes: 45));
      expect(timeoutCount, equals(0));

      // Activity occurs, resetting timer
      manager.recordActivity();
      expect(manager.lastActivity, isNotNull);

      // Elapse another 45 minutes (total 90 minutes from start)
      await tester.pump(const Duration(minutes: 45));
      // Should NOT have fired because it was reset at 45m
      expect(timeoutCount, equals(0));

      // Elapse remaining 15 minutes to reach 60m since reset
      await tester.pump(const Duration(minutes: 15));
      expect(timeoutCount, equals(1));

      manager.dispose();
    });

    testWidgets('pause and resume correctly suspend and restart timer', (tester) async {
      int timeoutCount = 0;
      final manager = IdleTimeoutManager(
        timeout: const Duration(minutes: 60),
        onTimeout: () => timeoutCount++,
      );

      await tester.pump(const Duration(minutes: 30));
      manager.pause();
      expect(manager.isPaused, isTrue);
      expect(manager.isActive, isFalse);

      // Advance past original expiration time while paused
      await tester.pump(const Duration(minutes: 60));
      expect(timeoutCount, equals(0));

      // Resume starts a fresh timeout
      manager.resume();
      expect(manager.isPaused, isFalse);
      expect(manager.isActive, isTrue);

      await tester.pump(const Duration(minutes: 59));
      expect(timeoutCount, equals(0));

      await tester.pump(const Duration(minutes: 1));
      expect(timeoutCount, equals(1));

      manager.dispose();
    });

    testWidgets('cancel stops timer permanently until restarted', (tester) async {
      int timeoutCount = 0;
      final manager = IdleTimeoutManager(
        timeout: const Duration(minutes: 60),
        onTimeout: () => timeoutCount++,
      );

      manager.cancel();
      expect(manager.isActive, isFalse);

      await tester.pump(const Duration(minutes: 120));
      expect(timeoutCount, equals(0));

      manager.start();
      expect(manager.isActive, isTrue);

      await tester.pump(const Duration(minutes: 60));
      expect(timeoutCount, equals(1));

      manager.dispose();
    });
  });

  group('IdleTimeoutListener Widget', () {
    testWidgets('fires onTimeout when idle for custom duration', (tester) async {
      int timeoutCount = 0;
      const customTimeout = Duration(seconds: 10);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdleTimeoutListener(
              timeout: customTimeout,
              onTimeout: () => timeoutCount++,
              child: const Center(child: Text('Content')),
            ),
          ),
        ),
      );

      expect(timeoutCount, equals(0));

      // Advance by 9 seconds - should not fire
      await tester.pump(const Duration(seconds: 9));
      expect(timeoutCount, equals(0));

      // Advance by 1 second - reaches 10s, should fire
      await tester.pump(const Duration(seconds: 1));
      expect(timeoutCount, equals(1));
    });

    testWidgets('fires onTimeout at default 60-minute duration', (tester) async {
      int timeoutCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdleTimeoutListener(
              onTimeout: () => timeoutCount++,
              child: const Center(child: Text('Content')),
            ),
          ),
        ),
      );

      expect(timeoutCount, equals(0));

      // Advance by 59 minutes - should not fire
      await tester.pump(const Duration(minutes: 59));
      expect(timeoutCount, equals(0));

      // Advance by 1 minute - reaches 60m, should fire
      await tester.pump(const Duration(minutes: 1));
      expect(timeoutCount, equals(1));
    });

    testWidgets('pointer movement resets timer and prevents premature timeout', (tester) async {
      int timeoutCount = 0;
      const timeout = Duration(seconds: 10);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdleTimeoutListener(
              timeout: timeout,
              onTimeout: () => timeoutCount++,
              child: const SizedBox(
                width: 300,
                height: 300,
                child: Text('Content'),
              ),
            ),
          ),
        ),
      );

      // Advance 7 seconds
      await tester.pump(const Duration(seconds: 7));
      expect(timeoutCount, equals(0));

      // Mouse pointer movement
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: const Offset(50, 50));
      await tester.pump();
      await gesture.moveTo(const Offset(60, 60));
      await tester.pump();

      // Advance 7 seconds (14s total from start, but only 7s since pointer movement)
      await tester.pump(const Duration(seconds: 7));
      expect(timeoutCount, equals(0));

      // Advance 3 more seconds (10s since pointer movement) -> should fire
      await tester.pump(const Duration(seconds: 3));
      expect(timeoutCount, equals(1));

      await gesture.removePointer();
    });

    testWidgets('pointer down resets timer and prevents premature timeout', (tester) async {
      int timeoutCount = 0;
      const timeout = Duration(seconds: 10);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdleTimeoutListener(
              timeout: timeout,
              onTimeout: () => timeoutCount++,
              child: const SizedBox(
                width: 300,
                height: 300,
                child: Text('Click target'),
              ),
            ),
          ),
        ),
      );

      // Advance 8 seconds
      await tester.pump(const Duration(seconds: 8));
      expect(timeoutCount, equals(0));

      // Tap on widget
      await tester.tap(find.text('Click target'));
      await tester.pump();

      // Advance 8 seconds again (16s total from start, 8s since tap)
      await tester.pump(const Duration(seconds: 8));
      expect(timeoutCount, equals(0));

      // Advance remaining 2 seconds
      await tester.pump(const Duration(seconds: 2));
      expect(timeoutCount, equals(1));
    });

    testWidgets('pointer scroll signal resets timer', (tester) async {
      int timeoutCount = 0;
      const timeout = Duration(seconds: 10);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdleTimeoutListener(
              timeout: timeout,
              onTimeout: () => timeoutCount++,
              child: const SizedBox(
                width: 300,
                height: 300,
                child: Text('Scroll target'),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 8));
      expect(timeoutCount, equals(0));

      // Send pointer scroll event
      final pointerLocation = tester.getCenter(find.text('Scroll target'));
      final gesture = await tester.startGesture(pointerLocation, kind: PointerDeviceKind.mouse);
      await gesture.up();
      await tester.pump();

      // Advance 8 seconds again
      await tester.pump(const Duration(seconds: 8));
      expect(timeoutCount, equals(0));

      // Complete 10 seconds since scroll
      await tester.pump(const Duration(seconds: 2));
      expect(timeoutCount, equals(1));
    });

    testWidgets('keyboard key event resets timer', (tester) async {
      int timeoutCount = 0;
      const timeout = Duration(seconds: 10);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdleTimeoutListener(
              timeout: timeout,
              onTimeout: () => timeoutCount++,
              child: const SizedBox(
                width: 300,
                height: 300,
                child: Text('Keyboard target'),
              ),
            ),
          ),
        ),
      );

      // Advance 8 seconds
      await tester.pump(const Duration(seconds: 8));
      expect(timeoutCount, equals(0));

      // Simulate hardware key event
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pump();

      // Advance 8 seconds
      await tester.pump(const Duration(seconds: 8));
      expect(timeoutCount, equals(0));

      // Advance 2 more seconds -> fires
      await tester.pump(const Duration(seconds: 2));
      expect(timeoutCount, equals(1));
    });

    testWidgets('does not fire when enabled is false', (tester) async {
      int timeoutCount = 0;
      const timeout = Duration(seconds: 10);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdleTimeoutListener(
              enabled: false,
              timeout: timeout,
              onTimeout: () => timeoutCount++,
              child: const Text('Disabled'),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 100));
      expect(timeoutCount, equals(0));
    });

    testWidgets('dynamic enabled toggle starts and stops timer', (tester) async {
      int timeoutCount = 0;
      const timeout = Duration(seconds: 10);

      Widget buildHarness({required bool enabled}) {
        return MaterialApp(
          home: Scaffold(
            body: IdleTimeoutListener(
              enabled: enabled,
              timeout: timeout,
              onTimeout: () => timeoutCount++,
              child: const Text('Toggle test'),
            ),
          ),
        );
      }

      await tester.pumpWidget(buildHarness(enabled: false));
      await tester.pump(const Duration(seconds: 15));
      expect(timeoutCount, equals(0));

      // Enable it
      await tester.pumpWidget(buildHarness(enabled: true));
      await tester.pump(const Duration(seconds: 9));
      expect(timeoutCount, equals(0));

      await tester.pump(const Duration(seconds: 1));
      expect(timeoutCount, equals(1));
    });

    testWidgets('programmatic resetOf resets ancestor timer', (tester) async {
      int timeoutCount = 0;
      const timeout = Duration(seconds: 10);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdleTimeoutListener(
              timeout: timeout,
              onTimeout: () => timeoutCount++,
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => IdleTimeoutListener.resetOf(context),
                  child: const Text('Reset Button'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 8));
      expect(timeoutCount, equals(0));

      // Press reset button
      await tester.tap(find.text('Reset Button'));
      await tester.pump();

      // Advance 8 seconds
      await tester.pump(const Duration(seconds: 8));
      expect(timeoutCount, equals(0));

      // Advance 2 seconds
      await tester.pump(const Duration(seconds: 2));
      expect(timeoutCount, equals(1));
    });

    testWidgets('programmatic pause and resume on state works', (tester) async {
      int timeoutCount = 0;
      const timeout = Duration(seconds: 10);
      late IdleTimeoutListenerState state;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdleTimeoutListener(
              timeout: timeout,
              onTimeout: () => timeoutCount++,
              child: Builder(
                builder: (context) {
                  state = IdleTimeoutListener.of(context)!;
                  return const Text('Pause test');
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 5));
      state.pause();
      expect(state.isPaused, isTrue);

      // Advance well past timeout while paused
      await tester.pump(const Duration(seconds: 20));
      expect(timeoutCount, equals(0));

      // Resume
      state.resume();
      expect(state.isPaused, isFalse);

      await tester.pump(const Duration(seconds: 9));
      expect(timeoutCount, equals(0));

      await tester.pump(const Duration(seconds: 1));
      expect(timeoutCount, equals(1));
    });

    testWidgets('IdleTimeoutDetector typedef works as an alias', (tester) async {
      int timeoutCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdleTimeoutDetector(
              timeout: const Duration(seconds: 5),
              onTimeout: () => timeoutCount++,
              child: const Text('Alias test'),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 5));
      expect(timeoutCount, equals(1));
    });
  });

  group('IdleWarningDialog', () {
    testWidgets('renders warning dialog with countdown, stay logged in and logout buttons', (tester) async {
      bool stayLoggedInCalled = false;
      bool logoutCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdleWarningDialog(
              countdown: const Duration(minutes: 5),
              onStayLoggedIn: () => stayLoggedInCalled = true,
              onLogout: () => logoutCalled = true,
            ),
          ),
        ),
      );

      expect(find.byType(IdleWarningDialog), findsOneWidget);
      expect(find.byKey(const Key('idle-warning-dialog')), findsOneWidget);
      expect(find.text('Session Expiring Soon'), findsOneWidget);
      expect(find.byKey(const Key('idle-warning-countdown')), findsOneWidget);
      expect(find.text('05:00'), findsOneWidget);
      expect(find.byKey(const Key('idle-stay-logged-in-button')), findsOneWidget);
      expect(find.byKey(const Key('idle-logout-button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('idle-stay-logged-in-button')));
      await tester.pump();
      expect(stayLoggedInCalled, isTrue);

      await tester.tap(find.byKey(const Key('idle-logout-button')));
      await tester.pump();
      expect(logoutCalled, isTrue);
    });

    testWidgets('countdown decrements over time', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdleWarningDialog(
              countdown: const Duration(seconds: 10),
              onStayLoggedIn: () {},
              onLogout: () {},
            ),
          ),
        ),
      );

      expect(find.text('00:10'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      expect(find.text('00:07'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      expect(find.text('00:03'), findsOneWidget);
    });

    testWidgets('countdown reaching zero triggers onLogout callback', (tester) async {
      bool logoutCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdleWarningDialog(
              countdown: const Duration(seconds: 3),
              onStayLoggedIn: () {},
              onLogout: () => logoutCalled = true,
            ),
          ),
        ),
      );

      expect(logoutCalled, isFalse);

      await tester.pump(const Duration(seconds: 2));
      expect(logoutCalled, isFalse);

      await tester.pump(const Duration(seconds: 1));
      expect(logoutCalled, isTrue);
    });
  });

  group('showIdleWarningDialog function', () {
    testWidgets('opens modal dialog and triggers callbacks on button actions', (tester) async {
      bool stayLoggedInCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showIdleWarningDialog(
                    context,
                    countdown: const Duration(minutes: 5),
                    onStayLoggedIn: () => stayLoggedInCalled = true,
                    onLogout: () {},
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(IdleWarningDialog), findsNothing);

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(IdleWarningDialog), findsOneWidget);
      expect(find.text('Session Expiring Soon'), findsOneWidget);

      // Tap Stay Logged In button
      await tester.tap(find.byKey(const Key('idle-stay-logged-in-button')));
      await tester.pumpAndSettle();

      expect(find.byType(IdleWarningDialog), findsNothing);
      expect(stayLoggedInCalled, isTrue);
    });

    testWidgets('pops dialog on logout button press', (tester) async {
      bool logoutCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showIdleWarningDialog(
                    context,
                    countdown: const Duration(minutes: 5),
                    onStayLoggedIn: () {},
                    onLogout: () => logoutCalled = true,
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(IdleWarningDialog), findsOneWidget);

      await tester.tap(find.byKey(const Key('idle-logout-button')));
      await tester.pumpAndSettle();

      expect(find.byType(IdleWarningDialog), findsNothing);
      expect(logoutCalled, isTrue);
    });
  });

  group('IdleTimeoutListener Warning Phase & Logout', () {
    testWidgets('triggers warning phase and renders warning dialog before timeout', (tester) async {
      const timeout = Duration(seconds: 10);
      const warningDuration = Duration(seconds: 4);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdleTimeoutListener(
              timeout: timeout,
              warningDuration: warningDuration,
              child: const Text('Admin Dashboard Content'),
            ),
          ),
        ),
      );

      // At 5 seconds, warning phase has not triggered yet (10s - 4s = 6s)
      await tester.pump(const Duration(seconds: 5));
      expect(find.byType(IdleWarningDialog), findsNothing);

      // Advance to 6 seconds: warning triggers!
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(IdleWarningDialog), findsOneWidget);
      expect(find.text('Session Expiring Soon'), findsOneWidget);
      expect(find.text('00:04'), findsOneWidget);

      // Settle the remaining countdown (4s) so logout fires and dismisses dialog cleanly
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(IdleWarningDialog), findsNothing);
    });

    testWidgets('stay logged in button resets idle timer and closes warning dialog', (tester) async {
      const timeout = Duration(seconds: 10);
      const warningDuration = Duration(seconds: 4);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdleTimeoutListener(
              timeout: timeout,
              warningDuration: warningDuration,
              child: const Text('Admin Content'),
            ),
          ),
        ),
      );

      // Advance to 6 seconds -> warning shows
      await tester.pump(const Duration(seconds: 6));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(IdleWarningDialog), findsOneWidget);

      // Tap Stay Logged In
      await tester.tap(find.byKey(const Key('idle-stay-logged-in-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(IdleWarningDialog), findsNothing);

      // Advance 5 seconds from reset: warning should NOT be showing
      await tester.pump(const Duration(seconds: 5));
      expect(find.byType(IdleWarningDialog), findsNothing);

      // Advance 1 more second (6s total since reset) -> warning shows again!
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(IdleWarningDialog), findsOneWidget);

      // Settle remaining countdown
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('unanswered warning dialog triggers sessionControllerProvider.notifier.logout() on timeout', (tester) async {
      final mockSessionController = _MockSessionController();
      const timeout = Duration(seconds: 10);
      const warningDuration = Duration(seconds: 4);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionControllerProvider.overrideWith((ref) => mockSessionController),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: IdleTimeoutListener(
                timeout: timeout,
                warningDuration: warningDuration,
                child: Text('Admin Shell'),
              ),
            ),
          ),
        ),
      );

      expect(mockSessionController.logoutCalled, isFalse);

      // Advance to warning phase (6s)
      await tester.pump(const Duration(seconds: 6));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(IdleWarningDialog), findsOneWidget);
      expect(mockSessionController.logoutCalled, isFalse);

      // Advance past warning countdown (4s more, reaching 10s)
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 300));
      expect(mockSessionController.logoutCalled, isTrue);
      expect(find.byType(IdleWarningDialog), findsNothing);
    });

    testWidgets('explicit Log Out button in warning dialog triggers logout immediately', (tester) async {
      final mockSessionController = _MockSessionController();
      const timeout = Duration(seconds: 10);
      const warningDuration = Duration(seconds: 4);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionControllerProvider.overrideWith((ref) => mockSessionController),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: IdleTimeoutListener(
                timeout: timeout,
                warningDuration: warningDuration,
                child: Text('Admin Shell'),
              ),
            ),
          ),
        ),
      );

      // Advance to warning phase
      await tester.pump(const Duration(seconds: 6));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(IdleWarningDialog), findsOneWidget);
      expect(mockSessionController.logoutCalled, isFalse);

      // Click Log Out button immediately
      await tester.tap(find.byKey(const Key('idle-logout-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(mockSessionController.logoutCalled, isTrue);
      expect(find.byType(IdleWarningDialog), findsNothing);
    });

    testWidgets('onWarning callback is invoked when warning phase begins', (tester) async {
      int warningCount = 0;
      const timeout = Duration(seconds: 10);
      const warningDuration = Duration(seconds: 3);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdleTimeoutListener(
              timeout: timeout,
              warningDuration: warningDuration,
              onWarning: () => warningCount++,
              child: const Text('Warning callback test'),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 6));
      expect(warningCount, equals(0));

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 300));
      expect(warningCount, equals(1));

      // Cleanup remaining 3 seconds of countdown
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('warningDuration >= timeout bypasses warning phase and triggers logout at timeout', (tester) async {
      final mockSessionController = _MockSessionController();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionControllerProvider.overrideWith((ref) => mockSessionController),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: IdleTimeoutListener(
                timeout: Duration(seconds: 5),
                warningDuration: Duration(minutes: 5),
                child: Text('Bypass warning test'),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 4));
      expect(find.byType(IdleWarningDialog), findsNothing);
      expect(mockSessionController.logoutCalled, isFalse);

      await tester.pump(const Duration(seconds: 1));
      expect(mockSessionController.logoutCalled, isTrue);
      expect(find.byType(IdleWarningDialog), findsNothing);
    });

    testWidgets('warningDuration: null bypasses warning phase', (tester) async {
      final mockSessionController = _MockSessionController();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionControllerProvider.overrideWith((ref) => mockSessionController),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: IdleTimeoutListener(
                timeout: Duration(seconds: 5),
                warningDuration: null,
                child: Text('Null warning test'),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 4));
      expect(find.byType(IdleWarningDialog), findsNothing);
      expect(mockSessionController.logoutCalled, isFalse);

      await tester.pump(const Duration(seconds: 1));
      expect(mockSessionController.logoutCalled, isTrue);
      expect(find.byType(IdleWarningDialog), findsNothing);
    });
  });
}
