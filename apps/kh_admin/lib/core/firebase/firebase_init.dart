import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_admin/core/firebase/firebase_notification_service.dart';
import 'package:kh_admin/core/log/kh_logger.dart';
import 'package:kh_admin/firebase_options.dart';

enum FirebaseInitStatus {
  uninitialized,
  initializing,
  initialized,
  failed,
}

class FirebaseInitState {
  const FirebaseInitState({
    this.status = FirebaseInitStatus.uninitialized,
    this.error,
  });

  final FirebaseInitStatus status;
  final Object? error;

  bool get isFailed => status == FirebaseInitStatus.failed;
  bool get isInitialized => status == FirebaseInitStatus.initialized;
  bool get isInitializing => status == FirebaseInitStatus.initializing;
}

final firebaseInitStateProvider = StateProvider<FirebaseInitState>((ref) {
  return const FirebaseInitState();
});

/// Non-blocking Firebase initialization, failing closed on errors (TR-S4-19 / E27 / ADM-INS-86).
Future<void> initializeFirebaseNonBlocking(
  WidgetRef ref, {
  KhLogger logger = const KhLogger(),
}) async {
  final notifier = ref.read(firebaseInitStateProvider.notifier);
  notifier.state = const FirebaseInitState(status: FirebaseInitStatus.initializing);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    notifier.state = const FirebaseInitState(status: FirebaseInitStatus.initialized);
  } on Object catch (e, st) {
    logger.error('Firebase initialization failed (failing closed): $e', e, st);
    notifier.state = FirebaseInitState(
      status: FirebaseInitStatus.failed,
      error: e,
    );
  }
}
