import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/error/error_retry_widget.dart';
import 'package:kh_admin/core/firebase/firebase.dart';
import 'package:kh_admin/core/log/kh_logger.dart';
import 'package:kh_admin/core/log/provider_logger.dart';
import 'package:kh_admin/core/router/app_router.dart';
import 'package:kh_admin/firebase_options.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const logger = KhLogger();

  FlutterError.onError = (details) {
    logger.error(
      'Flutter error: ${details.exceptionAsString()}',
      details.exception,
      details.stack,
    );
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error('Platform error', error, stack);
    return true;
  };

  if (kReleaseMode) {
    ErrorWidget.builder = (details) => ErrorRetryWidget(details: details);
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } on Object catch (e, st) {
    logger.warning('Firebase initialization warning: $e', e, st);
  }

  runZonedGuarded(
    () {
      runApp(
        const ProviderScope(
          observers: [ProviderLogger()],
          child: KhAdminApp(),
        ),
      );
    },
    (error, stack) => logger.error('Uncaught zoned error', error, stack),
  );
}

/// Root application widget for the Karat Hive Admin Portal.
class KhAdminApp extends ConsumerWidget {
  const KhAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Karat Hive Admin Portal',
      debugShowCheckedModeBanner: false,
      theme: buildKhAdminTheme(),
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
