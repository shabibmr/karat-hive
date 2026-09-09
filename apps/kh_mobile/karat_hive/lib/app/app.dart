import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../features/profile_settings/controller/settings_controller.dart';
import 'notifications/push_invalidation_binder.dart';
import 'router.dart';

class KaratHiveApp extends ConsumerWidget {
  const KaratHiveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AD-FE-10: keep FCM → provider invalidation subscribed for app lifetime.
    ref.watch(pushInvalidationBinderProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Karat Hive',
      debugShowCheckedModeBanner: false,
      theme: khTheme(),
      routerConfig: router,
      locale: ref.watch(appLocaleProvider),
      supportedLocales: KhStrings.supportedLocales,
      localizationsDelegates: KhStrings.delegates,
    );
  }
}
