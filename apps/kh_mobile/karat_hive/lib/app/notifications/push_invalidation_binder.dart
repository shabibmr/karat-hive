import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/firebase/firebase_notification_service.dart';
import 'push_invalidation.dart';

/// Keeps FCM foreground / opened-app streams subscribed for the app lifetime
/// and invalidates Riverpod providers (AD-FE-10). No WebSocket.
final pushInvalidationBinderProvider = Provider<void>((ref) {
  final service = ref.watch(firebaseNotificationServiceProvider);

  void handle(RemoteMessage message) {
    PushInvalidationPlan.fromData(
      Map<String, dynamic>.from(message.data),
    ).apply(ref);
  }

  final subs = service.initializeForegroundHandler(
    onMessageReceived: handle,
    onMessageOpenedApp: handle,
  );

  ref.onDispose(() {
    for (final sub in subs) {
      unawaited(sub.cancel());
    }
  });
});
