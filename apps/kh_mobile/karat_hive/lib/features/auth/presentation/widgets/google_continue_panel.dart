import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../controller/customer_onboarding_controller.dart';

/// Shared Continue-with-Google panel for Login doors (GL-35).
///
/// Biometric is optional and off by default — Guest Login does not require it.
class GoogleContinuePanel extends ConsumerWidget {
  const GoogleContinuePanel({
    super.key,
    this.showBiometric = false,
    this.onDismiss,
  });

  final bool showBiometric;

  /// Optional dismiss (overlay close / cancel). Resets onboarding to idle first.
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = KhL10n.of(context)!;
    final state = ref.watch(customerOnboardingControllerProvider);
    final busy = state is OnboardingBusy;
    final biometric = ref.watch(customerBiometricUnlockProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state is OnboardingLockedOut) ...[
          _LockoutBanner(message: state.message),
          const SizedBox(height: 16),
        ],
        if (state is OnboardingFailure) ...[
          KhInlineError(
            message: state.failure.message ?? l10n.authSignInFailed,
          ),
          const SizedBox(height: 16),
        ],
        FilledButton.icon(
          key: const Key('customer-google-signin'),
          onPressed: busy
              ? null
              : () => ref
                  .read(customerOnboardingControllerProvider.notifier)
                  .signInWithGoogle(),
          icon: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.g_mobiledata, size: 28),
          label: Text(busy ? l10n.authSigningIn : l10n.authContinueWithGoogle),
        ),
        if (showBiometric) ...[
          const SizedBox(height: 24),
          SwitchListTile(
            key: const Key('biometric-unlock-toggle'),
            contentPadding: EdgeInsets.zero,
            value: biometric,
            onChanged: (v) =>
                ref.read(customerBiometricUnlockProvider.notifier).state = v,
            title: Text(l10n.authBiometricUnlock),
            subtitle: Text(l10n.authBiometricUnlockHint),
          ),
        ],
        if (onDismiss != null) ...[
          const SizedBox(height: 8),
          TextButton(
            key: const Key('google-continue-dismiss'),
            onPressed: busy
                ? null
                : () {
                    ref
                        .read(customerOnboardingControllerProvider.notifier)
                        .resetToIdle();
                    onDismiss!();
                  },
            child: Text(l10n.commonCancel),
          ),
        ],
      ],
    );
  }
}

class _LockoutBanner extends StatelessWidget {
  const _LockoutBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = KhL10n.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key('auth-lockout-message'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.authLockoutTitle,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: scheme.onErrorContainer),
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(message, style: TextStyle(color: scheme.onErrorContainer)),
          ],
          const SizedBox(height: 6),
          Text(
            l10n.authLockoutHelp,
            style: TextStyle(color: scheme.onErrorContainer),
          ),
        ],
      ),
    );
  }
}
