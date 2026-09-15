import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../../app/guards.dart';
import '../../../app/session/session_controller.dart';

/// Legacy role chooser (CM-G04). Not used on Guest / Publish / Customer Login
/// (`adr/0011`, GL-17/GL-45) — those go straight to Customer signup.
class AuthCompleterScreen extends ConsumerWidget {
  const AuthCompleterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = KhStrings.of(context);
    final tokens = context.tokens;

    return KhScaffold(
      title: strings.s('auth.chooseRole'),
      body: ListView(
        key: const Key('auth-completer'),
        padding: EdgeInsets.all(tokens.space.md),
        children: [
          Text(strings.s('auth.chooseRole')),
          SizedBox(height: tokens.space.lg),
          KhButton(
            label: strings.s('auth.continueAsCustomer'),
            onPressed: () => context.go(AppGuards.customerRegister),
          ),
          SizedBox(height: tokens.space.sm),
          KhButton(
            label: strings.s('auth.continueAsVendor'),
            secondary: true,
            onPressed: () => context.go(AppGuards.register),
          ),
          SizedBox(height: tokens.space.lg),
          TextButton(
            onPressed: () => ref.read(sessionProvider.notifier).signOut(),
            child: Text(strings.s('common.logout')),
          ),
        ],
      ),
    );
  }
}
