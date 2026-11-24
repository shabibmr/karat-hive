import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service wrapping Firebase In-App Messaging (FIAM) capabilities.
/// Provides methods to trigger contextual in-app messages and suppress message
/// rendering during critical user journeys (e.g. KYC document scanning, checkout).
class FirebaseInAppMessagingService {
  FirebaseInAppMessagingService({FirebaseInAppMessaging? inAppMessaging})
      : _fiam = inAppMessaging ?? FirebaseInAppMessaging.instance;

  final FirebaseInAppMessaging _fiam;

  FirebaseInAppMessaging get instance => _fiam;

  /// Programmatically triggers a contextual in-app message mapped to [eventName].
  Future<void> triggerEvent(String eventName) async {
    try {
      await _fiam.triggerEvent(eventName);
    } catch (e) {
      debugPrint(
        '[FirebaseInAppMessagingService] triggerEvent($eventName) failed: $e',
      );
    }
  }

  /// Enables or disables suppression of in-app message displays.
  /// When suppressed, no in-app messages will render until suppression is disabled.
  Future<void> setMessagesSuppressed(bool suppress) async {
    try {
      await _fiam.setMessagesSuppressed(suppress);
    } catch (e) {
      debugPrint(
        '[FirebaseInAppMessagingService] setMessagesSuppressed($suppress) failed: $e',
      );
    }
  }

  /// Determines whether automatic data collection is enabled for FIAM.
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {
    try {
      await _fiam.setAutomaticDataCollectionEnabled(enabled);
    } catch (e) {
      debugPrint(
        '[FirebaseInAppMessagingService] setAutomaticDataCollectionEnabled($enabled) failed: $e',
      );
    }
  }
}

final firebaseInAppMessagingServiceProvider =
    Provider<FirebaseInAppMessagingService>(
  (ref) => FirebaseInAppMessagingService(),
);
