import 'package:flutter/material.dart';
import 'package:kh_l10n/kh_l10n.dart';

/// `SH-AUTH-05` — OAuth-required banner (CFE-11).
///
/// A presentational primitive. It carries no logic about *when* to show — the
/// caller decides that from [`publishGateProvider`] (proactive) or an
/// `OAUTH_REQUIRED` failure (reactive). CFE-19 (`request_create`, `CUS-S09`)
/// mounts it directly above the publish action:
///
/// ```dart
/// if (!ref.watch(publishGateProvider).canPublish ||
///     isOAuthRequired(lastFailure))
///   OAuthPublishGateBanner(
///     busy: onboarding is OnboardingBusy,
///     onVerify: () => ref
///         .read(customerOnboardingControllerProvider.notifier)
///         .signInWithGoogle(),
///   ),
/// ```
///
/// It only gates the publish button, never the create-flow entry
/// (Architecture-Frontend §7.3).
class OAuthPublishGateBanner extends StatelessWidget {
  const OAuthPublishGateBanner({
    super.key,
    required this.onVerify,
    this.busy = false,
    this.message,
  });

  /// Invoked when the user taps "Verify with Google". CFE-19 wires this to
  /// `CustomerOnboardingController.signInWithGoogle()`, whose success path
  /// refreshes the session so `oauthBound` flips true and the banner clears.
  final VoidCallback onVerify;
  final bool busy;

  /// Optional override — pass the server's localised `error.message` when the
  /// banner is shown in reaction to an `OAUTH_REQUIRED` failure.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = KhL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key('oauth-publish-gate-banner'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_outlined, color: scheme.onSecondaryContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.authPublishGateTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: scheme.onSecondaryContainer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message ?? l10n.authPublishGateBody,
            style: TextStyle(color: scheme.onSecondaryContainer),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton.icon(
              key: const Key('oauth-publish-gate-verify'),
              onPressed: busy ? null : onVerify,
              icon: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.g_mobiledata, size: 24),
              label: Text(l10n.authPublishGateAction),
            ),
          ),
        ],
      ),
    );
  }
}
