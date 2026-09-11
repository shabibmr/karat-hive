import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../../app/guards.dart';
import '../../../app/session/session_controller.dart';
import '../controller/customer_onboarding_controller.dart';
import 'widgets/customer_completion_view.dart';
import 'widgets/google_continue_panel.dart';

/// Customer Login / onboarding door (CFE-09 + CFE-10).
///
/// Reused as Guest corner Log in (`/customer/onboarding`) — not the home
/// screen (GL-36). Google Sign-In is the only login (`adr/0010`).
class CustomerOnboardingScreen extends ConsumerWidget {
  const CustomerOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = KhL10n.of(context)!;
    final state = ref.watch(customerOnboardingControllerProvider);
    final session = ref.watch(sessionProvider);
    final showBackToGuest = session is SignedOut;

    return KhScaffold(
      title: l10n.guestLogIn,
      onBack: showBackToGuest
          ? () => context.go(AppGuards.guestLanding)
          : null,
      body: switch (state) {
        OnboardingNeedsCompletion(
          :final firebaseIdToken,
          :final suggestedName,
          :final suggestedEmail,
        ) =>
          CustomerCompletionView(
            firebaseIdToken: firebaseIdToken,
            suggestedName: suggestedName,
            suggestedEmail: suggestedEmail,
          ),
        OnboardingAuthenticated() => const KhLoadingView(),
        _ => const _WelcomeView(),
      },
    );
  }
}

class _WelcomeView extends StatelessWidget {
  const _WelcomeView();

  @override
  Widget build(BuildContext context) {
    final l10n = KhL10n.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        Text(
          l10n.authWelcomeTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.authWelcomeSubtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),
        // Corner Login keeps biometric; Publish overlay uses panel without it.
        const GoogleContinuePanel(showBiometric: true),
      ],
    );
  }
}
