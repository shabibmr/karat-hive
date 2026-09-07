import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../../app/guards.dart';
import '../../../core/firebase/firebase.dart';

/// CUS-S01 — Google is the only login (`adr/0010`). No password tab.
class CustomerOnboardingScreen extends ConsumerStatefulWidget {
  const CustomerOnboardingScreen({super.key});

  @override
  ConsumerState<CustomerOnboardingScreen> createState() =>
      _CustomerOnboardingScreenState();
}

class _CustomerOnboardingScreenState extends ConsumerState<CustomerOnboardingScreen> {
  bool _googleSigningIn = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final strings = KhStrings.of(context);
    final tokens = context.tokens;

    return KhScaffold(
      title: strings.s('app.title'),
      body: ListView(
        key: const Key('cus-s01-onboarding'),
        padding: EdgeInsets.all(tokens.space.md),
        children: [
          Text(
            strings.s('auth.signIn'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: tokens.space.sm),
          Text(
            strings.s('auth.googleSignIn'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.ink.withValues(alpha: 0.7),
                ),
          ),
          if (_error != null) ...[
            SizedBox(height: tokens.space.md),
            KhInlineError(message: _error!),
          ],
          SizedBox(height: tokens.space.lg),
          OutlinedButton.icon(
            key: const Key('google-signin-button'),
            onPressed: _googleSigningIn ? null : _signInWithGoogle,
            icon: _googleSigningIn
                ? SizedBox(
                    width: tokens.space.md + tokens.space.xs,
                    height: tokens.space.md + tokens.space.xs,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.account_circle_outlined),
            label: Text(
              _googleSigningIn
                  ? (AppLocalizations.of(context)?.authSigningInWithGoogle ??
                      'Signing in...')
                  : strings.s('auth.googleSignIn'),
            ),
          ),
          SizedBox(height: tokens.space.md),
          TextButton(
            onPressed: () => context.go(AppGuards.login),
            child: Text(strings.s('auth.vendorSignIn')),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() {
      _googleSigningIn = true;
      _error = null;
    });
    try {
      await ref.read(firebaseAuthServiceProvider).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        final message =
            l10n?.authGoogleSignInFailed('$e') ?? 'Google Sign-In failed: $e';
        setState(() => _error = message);
        messenger.showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _googleSigningIn = false);
    }
  }
}
