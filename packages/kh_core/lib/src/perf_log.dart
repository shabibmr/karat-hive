import 'package:flutter/foundation.dart';

/// Dev-only per-phase timing logs (docs/Request-Perf-Logging-Plan.md).
///
/// Enabled in debug builds, or in a release/profile build launched with
/// `--dart-define=KH_PERF_LOG=true`, so a real device can be perf-tested
/// without shipping this to every user. Silent (no `Stopwatch`, no output)
/// otherwise.
const bool _perfLogDefine = bool.fromEnvironment('KH_PERF_LOG');
bool get perfLogEnabled => kDebugMode || _perfLogDefine;

/// One timed flow — a user action such as "attach a photo" or "publish".
/// Call [lap] after each phase completes, then [done] once, which prints a
/// single summary line and returns the result for [PerfLogSink] to persist.
class PerfLog {
  PerfLog(this.flow, {Map<String, Object?> context = const {}})
      : _context = context,
        _stopwatch = perfLogEnabled ? (Stopwatch()..start()) : null;

  /// The flow name a [done] summary prints under. Mutable so a caller that
  /// only learns which flow it's in partway through (e.g. "open" doesn't
  /// know draft vs. published until the response arrives) can retag it.
  String flow;
  final Map<String, Object?> _context;
  final Stopwatch? _stopwatch;
  final List<MapEntry<String, int>> _laps = [];
  int _lastMs = 0;

  /// Records the elapsed time (ms) since the previous lap (or start) under [label].
  void lap(String label) {
    final sw = _stopwatch;
    if (sw == null) return;
    final now = sw.elapsedMilliseconds;
    _laps.add(MapEntry(label, now - _lastMs));
    _lastMs = now;
  }

  /// Ends the flow, prints one summary line, and returns the timings so a
  /// caller (e.g. `PerfLogSink`) can persist them. Fields already collected
  /// by [lap] and [context] are merged with [extra].
  PerfLogResult done({Map<String, Object?> extra = const {}}) {
    final sw = _stopwatch;
    final totalMs = sw?.elapsedMilliseconds ?? 0;
    final phases = {for (final e in _laps) e.key: e.value};
    final fields = {..._context, ...extra};
    if (sw != null) {
      final lapsStr = _laps.map((e) => '${e.key}=${e.value}ms').join(' ');
      final fieldsStr = fields.entries
          .where((e) => e.value != null)
          .map((e) => '${e.key}=${e.value}')
          .join(' ');
      debugPrint(
        '[Perf] $flow total=${totalMs}ms'
        '${lapsStr.isNotEmpty ? ' $lapsStr' : ''}'
        '${fieldsStr.isNotEmpty ? ' $fieldsStr' : ''}',
      );
    }
    return PerfLogResult(flow: flow, totalMs: totalMs, phases: phases, fields: fields);
  }
}

/// The finished timing summary for one [PerfLog] flow, ready to hand to a
/// persistence sink (e.g. Firestore on `kh_mobile`).
class PerfLogResult {
  const PerfLogResult({
    required this.flow,
    required this.totalMs,
    required this.phases,
    required this.fields,
  });

  final String flow;
  final int totalMs;
  final Map<String, int> phases;
  final Map<String, Object?> fields;
}
