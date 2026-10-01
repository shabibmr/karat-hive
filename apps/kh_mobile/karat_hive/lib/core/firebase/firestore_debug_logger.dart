import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint, defaultTargetPlatform, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firestore_service.dart';

/// Fire-and-forget diagnostic log written to the `debug_logs` Firestore
/// collection. Never throws and never blocks the caller — a failed write
/// (rules, offline) only prints locally.
///
/// Temporary tooling for field debugging; do not log PII, tokens or signed
/// URLs through it.
class FirestoreDebugLogger {
  FirestoreDebugLogger(this._service, {this.collection = 'debug_logs'});

  final FirestoreService _service;
  final String collection;

  void log(String scope, String event, [Map<String, Object?> data = const {}]) {
    debugPrint('[$scope] $event $data');
    _write(scope, event, data);
  }

  Future<void> _write(
    String scope,
    String event,
    Map<String, Object?> data,
  ) async {
    try {
      await _service.collection(collection).add({
        'ts': FieldValue.serverTimestamp(),
        'scope': scope,
        'event': event,
        'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
        'data': _sanitise(data),
      });
    } catch (e) {
      debugPrint('[FirestoreDebugLogger] write failed: $e');
    }
  }

  /// Firestore rejects non-primitive values; stringify anything unexpected.
  static Object? _sanitise(Object? v) {
    if (v == null || v is num || v is bool || v is String) return v;
    if (v is Map) return {for (final e in v.entries) '${e.key}': _sanitise(e.value)};
    if (v is Iterable) return [for (final e in v) _sanitise(e)];
    return v.toString();
  }

  /// Adapter for `MediaUploader.onDebug`.
  void Function(String, Map<String, Object?>) sinkFor(String scope) =>
      (event, data) => log(scope, event, data);
}

final firestoreDebugLoggerProvider = Provider<FirestoreDebugLogger>(
  (ref) => FirestoreDebugLogger(ref.watch(firestoreServiceProvider)),
);
