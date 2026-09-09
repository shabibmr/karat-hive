import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/time/clock.dart';

class FixedClock implements Clock {
  const FixedClock(this.fixedTime);

  final DateTime fixedTime;

  @override
  DateTime now() => fixedTime;
}

void main() {
  group('Clock & SystemClock', () {
    test('SystemClock returns current wall clock time', () {
      const clock = SystemClock();
      final before = DateTime.now();
      final current = clock.now();
      final after = DateTime.now();

      expect(current.isAfter(before) || current.isAtSameMomentAs(before), isTrue);
      expect(current.isBefore(after) || current.isAtSameMomentAs(after), isTrue);
    });

    test('clockProvider defaults to SystemClock', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final clock = container.read(clockProvider);
      expect(clock, isA<SystemClock>());

      final before = DateTime.now();
      final time = clock.now();
      final after = DateTime.now();

      expect(time.isAfter(before) || time.isAtSameMomentAs(before), isTrue);
      expect(time.isBefore(after) || time.isAtSameMomentAs(after), isTrue);
    });

    test('clockProvider can be overridden with a custom Clock in ProviderContainer', () {
      final fixedInstant = DateTime.utc(2026, 9, 9, 12, 0, 0);
      final container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(FixedClock(fixedInstant)),
        ],
      );
      addTearDown(container.dispose);

      final clock = container.read(clockProvider);
      expect(clock.now(), equals(fixedInstant));
    });

    testWidgets('clockProvider overridden in ProviderScope(overrides: [...]) returns fixed time', (tester) async {
      final fixedInstant = DateTime.utc(2026, 1, 15, 8, 30, 0);
      DateTime? observedTime;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clockProvider.overrideWithValue(FixedClock(fixedInstant)),
          ],
          child: Consumer(
            builder: (context, ref, child) {
              observedTime = ref.watch(clockProvider).now();
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(observedTime, equals(fixedInstant));
    });
  });
}
