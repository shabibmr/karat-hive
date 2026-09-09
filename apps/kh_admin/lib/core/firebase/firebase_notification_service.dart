import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_admin/core/log/kh_logger.dart';
import 'package:kh_admin/core/log/kh_logger_provider.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  const KhLogger().info('FCM background message received: ${message.messageId}');
}

class FirebaseNotificationService {
  FirebaseNotificationService({
    FirebaseMessaging? messaging,
    KhLogger? logger,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _logger = logger ?? const KhLogger();

  final FirebaseMessaging _messaging;
  final KhLogger _logger;

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
    } on Object catch (e, st) {
      _logger.error('Error fetching FCM token', e, st);
      return null;
    }
  }

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  void initializeForegroundHandler({
    void Function(RemoteMessage message)? onMessageReceived,
    void Function(RemoteMessage message)? onMessageOpenedApp,
  }) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.info('FCM foreground message received: ${message.messageId}');
      if (onMessageReceived != null) {
        onMessageReceived(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logger.info('FCM opened app from notification: ${message.messageId}');
      if (onMessageOpenedApp != null) {
        onMessageOpenedApp(message);
      }
    });
  }

  Future<void> subscribeToTopic(String topic) => _messaging.subscribeToTopic(topic);

  Future<void> unsubscribeFromTopic(String topic) => _messaging.unsubscribeFromTopic(topic);
}

final firebaseNotificationServiceProvider = Provider<FirebaseNotificationService>((ref) {
  final logger = ref.watch(khLoggerProvider);
  return FirebaseNotificationService(logger: logger);
});
