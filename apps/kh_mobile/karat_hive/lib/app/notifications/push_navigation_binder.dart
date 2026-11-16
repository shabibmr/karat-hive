import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/firebase/firebase_notification_service.dart';
import '../notification_deep_link.dart';
import '../router.dart';
import '../session/session_controller.dart';

/// Lets the foreground banner reach the app's [ScaffoldMessenger] without a
/// [BuildContext] (wired into `MaterialApp.router`).
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

String? _deepLinkOf(RemoteMessage m) {
  final v = m.data['deepLink'] ?? m.data['deep_link'];
  return v is String && v.trim().isNotEmpty ? v : null;
}

/// Notification taps (background and cold start) and the foreground banner.
/// Taps navigate once the session is signed in so [AppGuards] never sees an
/// unresolved session; the route table is role-prefixed, hence
/// [NotificationDeepLink.resolve].
final pushNavigationBinderProvider = Provider<void>((ref) {
  final service = ref.watch(firebaseNotificationServiceProvider);
  String? pending;

  void flush() {
    final session = ref.read(sessionProvider);
    if (pending == null || session is! SignedIn) return;
    final location = NotificationDeepLink.resolve(
      pending!,
      isVendor: session.isVendor,
    );
    pending = null;
    if (location != null) ref.read(routerProvider).go(location);
  }

  void openFrom(RemoteMessage m) {
    pending = _deepLinkOf(m);
    flush();
  }

  void banner(RemoteMessage m) {
    final n = m.notification;
    final title = n?.title;
    final body = n?.body;
    if (title == null && body == null) return;
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          content: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              messenger.hideCurrentSnackBar();
              openFrom(m);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (body != null)
                  Text(body, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      );
  }

  final subs = <StreamSubscription<RemoteMessage>>[
    FirebaseMessaging.onMessage.listen(banner),
    FirebaseMessaging.onMessageOpenedApp.listen(openFrom),
  ];
  ref.onDispose(() {
    for (final s in subs) {
      unawaited(s.cancel());
    }
  });

  // Cold start from a tapped notification.
  unawaited(
    service.getInitialMessage().then((m) {
      if (m != null) openFrom(m);
    }).catchError((Object _) {}),
  );

  // Deliver a pending link as soon as the session resolves to signed in.
  ref.listen<SessionState>(sessionProvider, (_, _) => flush());
});
