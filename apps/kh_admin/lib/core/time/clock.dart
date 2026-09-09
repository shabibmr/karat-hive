import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Clock abstraction for retrieving the current timestamp, overridable in tests.
abstract class Clock {
  DateTime now();
}

/// Default clock implementation backed by the system's wall clock ([DateTime.now]).
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// Provider exposing the current [Clock] instance.
///
/// Defaults to [SystemClock], overridable in [ProviderScope] for deterministic tests.
final Provider<Clock> clockProvider = Provider<Clock>((ref) => const SystemClock());
