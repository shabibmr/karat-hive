import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../../app/guards.dart';
import '../controller/vendor_login_controller.dart';

/// VEN-S04 — Vendor Sign In (`adr/0010`).
///
/// Google Sign-In is the designated exclusive login path across all actors.
class VendorLoginScreen extends ConsumerWidget {
  const VendorLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(vendorLoginControllerProvider);
    final controller = ref.read(vendorLoginControllerProvider.notifier);
    final busy = state is LoginBusy;

    return KhScaffold(
      title: l10n?.authSignIn ?? 'Vendor Sign In',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 24),
          Text(
            l10n?.authWelcomeTitle ?? 'Welcome to Karat Hive',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.authWelcomeSubtitle ??
                'Sign in with your Google account to access your vendor portal and live requests.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          if (state is LoginError) ...[
            KhInlineError(
              message: state.failure.message ??
                  (l10n?.authSignInFailed ?? 'Sign in failed.'),
            ),
            const SizedBox(height: 16),
          ],
          if (state is LoginNeedsRegistration) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Vendor Account Found',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'This Google account is not yet registered as a Karat Hive vendor. Please register your business details to continue.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  KhButton(
                    label: 'Register Business Now',
                    onPressed: () => context.go(AppGuards.register),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          FilledButton.icon(
            key: const Key('vendor-google-signin'),
            onPressed: busy ? null : controller.signInWithGoogle,
            icon: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.g_mobiledata, size: 28),
            label: Text(
              busy
                  ? (l10n?.authSigningInWithGoogle ?? 'Signing in...')
                  : (l10n?.authSignInWithGoogle ?? 'Sign in with Google'),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () => context.go(AppGuards.register),
              child: Text(
                l10n?.authRegister ?? 'Register new vendor business',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () => context.go(AppGuards.customerOnboarding),
              child: const Text('Looking to buy or sell gold? Switch to Customer'),
            ),
          ),
        ],
      ),
    );
  }
}
