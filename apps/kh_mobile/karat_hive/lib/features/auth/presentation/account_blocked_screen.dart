import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../../app/session/session_controller.dart';

class AccountBlockedScreen extends ConsumerWidget {
  const AccountBlockedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = KhStrings.of(context);
    final tokens = context.tokens;
    final session = ref.watch(sessionProvider);
    final message = switch (session) {
      AuthBlocked(:final failure) =>
        failure.message ?? _fallback(strings, failure),
      SignedIn(:final user) when user.accountState == AccountState.suspended =>
        strings.s('auth.accountSuspended'),
      SignedIn(:final user) when user.accountState == AccountState.deactivated =>
        strings.s('auth.accountDeactivated'),
      _ => strings.s('auth.accountSuspended'),
    };

    return KhScaffold(
      title: strings.s('app.title'),
      body: Padding(
        key: const Key('customer-blocked'),
        padding: EdgeInsets.all(tokens.space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KhInlineError(message: message),
            SizedBox(height: tokens.space.lg),
            KhButton(
              label: strings.s('common.logout'),
              secondary: true,
              onPressed: () => ref.read(sessionProvider.notifier).signOut(),
            ),
          ],
        ),
      ),
    );
  }

  String _fallback(KhStrings strings, Failure failure) {
    if (failure.code == 'ACCOUNT_DEACTIVATED') {
      return strings.s('auth.accountDeactivated');
    }
    return strings.s('auth.accountSuspended');
  }
}
