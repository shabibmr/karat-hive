import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';

/// Persists finished [PerfLog] flows to Firestore so timings survive on web,
/// where the browser console is lost when the tab closes
/// (docs/Request-Perf-Logging-Plan.md).
///
/// Fire-and-forget and best-effort: a write failure never surfaces to the
/// user and never affects the flow it's reporting on. Writes are opaque
/// diagnostics only — no user id, email, phone number, or Request content;
/// see `perf_logs` in the plan doc for the field list.
class PerfLogSink {
  PerfLogSink({FirebaseFirestore? firestore, String? platform})
      : _firestoreOverride = firestore,
        platform = platform ?? _platformName;

  /// Explicit override (used by tests); otherwise resolved lazily at write
  /// time so a Firebase-less environment (unit tests, a cold app start
  /// racing `Firebase.initializeApp`) fails a single write, not construction.
  final FirebaseFirestore? _firestoreOverride;
  final String platform;

  /// `requestId` here is the Request's own id, distinct from the HTTP
  /// `x-request-id`s in [result]'s fields (if the caller included them),
  /// which let a `perf_logs` document be joined back to backend log lines.
  void record(PerfLogResult result, {String? requestId, String? appFlavor}) {
    if (!perfLogEnabled) return;
    unawaited(_write(result, requestId: requestId, appFlavor: appFlavor));
  }

  Future<void> _write(
    PerfLogResult result, {
    String? requestId,
    String? appFlavor,
  }) async {
    try {
      final firestore = _firestoreOverride ?? FirebaseFirestore.instance;
      await firestore.collection('perf_logs').add({
        'flow': result.flow,
        'platform': platform,
        if (appFlavor != null) 'appFlavor': appFlavor,
        'createdAt': FieldValue.serverTimestamp(),
        'totalMs': result.totalMs,
        'phases': result.phases,
        if (requestId != null) 'requestId': requestId,
        ...result.fields,
      }).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('[PerfLogSink] failed to persist ${result.flow}: $e');
    }
  }

  static String get _platformName {
    if (kIsWeb) return 'web';
    return defaultTargetPlatform.name;
  }
}

final perfLogSinkProvider = Provider<PerfLogSink>((ref) => PerfLogSink());
