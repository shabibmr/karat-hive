import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/firebase/firebase_notification_service.dart';
import '../di.dart';
import '../session/session_controller.dart';
import 'registered_device.dart';

/// Asks for notification permission once a user is signed in, then registers
/// the FCM token with the backend (`POST /v1/devices`) and re-registers on
/// token refresh. Guests and signed-out sessions never prompt.
final deviceRegistrationBinderProvider = Provider<void>((ref) {
  final platform = switch (defaultTargetPlatform) {
    TargetPlatform.iOS => 'IOS',
    TargetPlatform.android => 'ANDROID',
    _ => null,
  };
  if (kIsWeb || platform == null) return;

  final service = ref.watch(firebaseNotificationServiceProvider);
  StreamSubscription<String>? refreshSub;
  var disposed = false;

  Future<void> register(String token) async {
    final result = await ref.read(khApiProvider).registerDevice(
          platform: platform,
          pushToken: token,
        );
    result.when(
      ok: (id) => ref.read(registeredDeviceIdProvider.notifier).set(id),
      err: (f) => debugPrint('Device registration failed: ${f.code}'),
    );
  }

  Future<void> start() async {
    try {
      final settings = await service.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;
      if (disposed) return;
      final token = await service.getToken();
      if (token != null && !disposed) await register(token);
      refreshSub ??= service.onTokenRefresh.listen(
        (t) => unawaited(register(t)),
      );
    } catch (e) {
      debugPrint('Push setup failed: $e');
    }
  }

  void stop() {
    unawaited(refreshSub?.cancel());
    refreshSub = null;
  }

  ref.listen<SessionState>(sessionProvider, (prev, next) {
    final wasIn = prev is SignedIn;
    if (next is SignedIn && !wasIn) {
      unawaited(start());
    } else if (next is! SignedIn && wasIn) {
      stop();
    }
  }, fireImmediately: true);

  ref.onDispose(() {
    disposed = true;
    stop();
  });
});
