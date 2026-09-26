import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';

import 'app/app.dart';
import 'app/di.dart';
import 'core/firebase/firebase.dart';
import 'firebase_options.dart';

/// Nothing heavy before the first frame (Architecture-Frontend §17): restore
/// tokens and render; the session provider resolves the rest.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env env = Env.fromDefines();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Fetch dynamic environment config from Firestore with graceful fallback
    final configService = FirestoreConfigService();
    final remoteUrl = await configService.fetchRemoteApiBaseUrl(env.flavor);
    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      env = env.copyWith(apiBaseUrl: remoteUrl);
      debugPrint('[Bootstrap] Using remote API base URL from Firestore: ${env.apiBaseUrl}');
    } else {
      debugPrint('[Bootstrap] Using default API base URL: ${env.apiBaseUrl}');
    }
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }

  final resolvedEnv = env;
  KhNetworkImage.urlResolver = resolvedEnv.resolveUrl;

  runApp(
    ProviderScope(
      overrides: [
        envProvider.overrideWithValue(env),
      ],
      child: const KaratHiveApp(),
    ),
  );
}
