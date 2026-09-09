import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background message received: ${message.messageId}');
}

class FirebaseNotificationService {
  FirebaseNotificationService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  Future<NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    return settings;
  }

  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Error fetching FCM token: $e');
      return null;
    }
  }

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// Subscribes to foreground and opened-app FCM streams. Caller must cancel
  /// the returned subscriptions (push invalidation binder does this).
  List<StreamSubscription<RemoteMessage>> initializeForegroundHandler({
    void Function(RemoteMessage message)? onMessageReceived,
    void Function(RemoteMessage message)? onMessageOpenedApp,
  }) {
    return [
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM foreground message: ${message.notification?.title}');
        onMessageReceived?.call(message);
      }),
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('FCM opened app from notification: ${message.data}');
        onMessageOpenedApp?.call(message);
      }),
    ];
  }

  Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(topic);

  Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);
}

final firebaseNotificationServiceProvider =
    Provider<FirebaseNotificationService>((ref) {
  return FirebaseNotificationService();
});
