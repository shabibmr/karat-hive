import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/error/error_retry_widget.dart';
import 'package:kh_admin/core/firebase/firebase_init.dart';
import 'package:kh_admin/core/firebase/firebase_notification_service.dart';
import 'package:kh_admin/core/firebase/firebase_push_handler.dart';
import 'package:kh_admin/core/log/kh_logger.dart';
import 'package:kh_admin/core/log/provider_logger.dart';
import 'package:kh_admin/core/platform/flavor.dart';
import 'package:kh_admin/core/router/app_router.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

Future<void> main() async {
  const logger = KhLogger();

  // TR-S4-19: runApp and binding initialization share the same Zone to prevent Zone mismatch
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();

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

      // TR-S4-15 & TR-S4-16: Fast flavor configuration validation at startup
      final flavor = AppFlavor.fromString(
        const String.fromEnvironment('KH_FLAVOR', defaultValue: 'dev'),
      );
      FlavorConfig(flavor: flavor, apiBaseUrl: khApiBase).validate();

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
class KhAdminApp extends ConsumerStatefulWidget {
  const KhAdminApp({super.key});

  @override
  ConsumerState<KhAdminApp> createState() => _KhAdminAppState();
}

class _KhAdminAppState extends ConsumerState<KhAdminApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Non-blocking Firebase init (TR-S4-19)
      await initializeFirebaseNonBlocking(ref);

      // FCM foreground push listener (TR-S4-18)
      if (mounted && ref.read(firebaseInitStateProvider).isInitialized) {
        _initForegroundPush();
      }
    });
  }

  void _initForegroundPush() {
    try {
      final notifService = ref.read(firebaseNotificationServiceProvider);
      notifService.initializeForegroundHandler(
        onMessageReceived: (message) {
          invalidateListProvidersOnPush(ref.invalidate, message);
        },
      );
    } on Object catch (_) {
      // Non-fatal if messaging is unavailable
    }
  }

  @override
  Widget build(BuildContext context) {
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

