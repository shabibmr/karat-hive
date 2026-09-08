import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../controller/customer_completion_controller.dart';
import '../controller/customer_onboarding_controller.dart';
import '../model/customer_completion_form.dart';

/// `CUS-S01` — Customer onboarding (CFE-09 + CFE-10).
///
/// Google Sign-In is the only login (`adr/0010`). An unbound Google token is not
/// an error: it lands on the completion step ([_CompletionView]).
class CustomerOnboardingScreen extends ConsumerWidget {
  const CustomerOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = KhL10n.of(context);
    final state = ref.watch(customerOnboardingControllerProvider);

    return KhScaffold(
      title: l10n.appTitle,
      body: switch (state) {
        OnboardingNeedsCompletion() => const _CompletionView(),
        OnboardingAuthenticated() => const KhLoadingView(),
        _ => _WelcomeView(state: state),
      },
    );
  }
}

class _WelcomeView extends ConsumerWidget {
  const _WelcomeView({required this.state});

  final CustomerOnboardingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = KhL10n.of(context);
    final busy = state is OnboardingBusy;
    final biometric = ref.watch(customerBiometricUnlockProvider);

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
        if (state is OnboardingLockedOut) ...[
          _LockoutMessage(message: (state as OnboardingLockedOut).message),
          const SizedBox(height: 16),
        ],
        if (state is OnboardingFailure) ...[
          KhInlineError(
            message: (state as OnboardingFailure).failure.message ??
                l10n.authSignInFailed,
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
    );
  }
}

class _LockoutMessage extends StatelessWidget {
  const _LockoutMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = KhL10n.of(context);
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

class _CompletionView extends ConsumerStatefulWidget {
  const _CompletionView();

  @override
  ConsumerState<_CompletionView> createState() => _CompletionViewState();
}

class _CompletionViewState extends ConsumerState<_CompletionView> {
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  String _code = '';
  bool _seededText = false;

  @override
  void initState() {
    super.initState();
    // Seed the flow-scoped form with the Firebase token from the sign-in step.
    final state = ref.read(customerOnboardingControllerProvider);
    if (state is OnboardingNeedsCompletion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(customerCompletionControllerProvider.notifier).begin(
              firebaseIdToken: state.firebaseIdToken,
              suggestedName: state.suggestedName,
              suggestedEmail: state.suggestedEmail,
            );
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = KhL10n.of(context);
    final form = ref.watch(customerCompletionControllerProvider);
    final controller = ref.read(customerCompletionControllerProvider.notifier);

    if (!_seededText) {
      _seededText = true;
      _name.text = form.displayName;
      _mobile.text = form.mobileNumber;
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 16),
        Text(
          l10n.authCompleteProfileTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.authCompleteProfileSubtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        if (form.failure != null) ...[
          KhInlineError(
            message: form.failure!.message ?? l10n.authSignInFailed,
          ),
          const SizedBox(height: 16),
        ],
        if (form.step == CompletionStep.code)
          _CodeStep(
            mobile: form.mobileNumber,
            busy: form.busy,
            canSubmit: form.canSubmitCode,
            onChanged: (v) => _code = v,
            onResend: controller.sendCode,
            onVerify: () => controller.verifyAndRegister(_code),
            onBack: controller.backToDetails,
          )
        else
          _DetailsStep(
            name: _name,
            mobile: _mobile,
            termsAccepted: form.termsAccepted,
            busy: form.busy || form.step == CompletionStep.submitting,
            canContinue: form.detailsComplete,
            onName: controller.setName,
            onMobile: controller.setMobile,
            onTerms: controller.setTermsAccepted,
            onContinue: controller.sendCode,
          ),
      ],
    );
  }
}

class _DetailsStep extends StatelessWidget {
  const _DetailsStep({
    required this.name,
    required this.mobile,
    required this.termsAccepted,
    required this.busy,
    required this.canContinue,
    required this.onName,
    required this.onMobile,
    required this.onTerms,
    required this.onContinue,
  });

  final TextEditingController name;
  final TextEditingController mobile;
  final bool termsAccepted;
  final bool busy;
  final bool canContinue;
  final ValueChanged<String> onName;
  final ValueChanged<String> onMobile;
  final ValueChanged<bool> onTerms;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = KhL10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KhTextField(
          label: l10n.authDisplayNameLabel,
          controller: name,
          onChanged: onName,
        ),
        KhTextField(
          label: l10n.authMobile,
          controller: mobile,
          keyboardType: TextInputType.phone,
          onChanged: onMobile,
        ),
        CheckboxListTile(
          key: const Key('accept-terms-checkbox'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: termsAccepted,
          onChanged: (v) => onTerms(v ?? false),
          title: Text(l10n.authAcceptTerms),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 32, bottom: 12),
          child: Wrap(
            spacing: 16,
            children: [
              Text(l10n.authViewTerms,
                  style: Theme.of(context).textTheme.bodySmall),
              Text(l10n.authViewPrivacy,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        if (!termsAccepted)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 12),
            child: Text(
              l10n.authAcceptTermsRequired,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
        KhButton(
          label: l10n.authSendCode,
          busy: busy,
          onPressed: canContinue ? onContinue : null,
        ),
      ],
    );
  }
}

class _CodeStep extends StatelessWidget {
  const _CodeStep({
    required this.mobile,
    required this.busy,
    required this.canSubmit,
    required this.onChanged,
    required this.onResend,
    required this.onVerify,
    required this.onBack,
  });

  final String mobile;
  final bool busy;
  final bool canSubmit;
  final ValueChanged<String> onChanged;
  final VoidCallback onResend;
  final VoidCallback onVerify;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = KhL10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.authOtpSentTo(mobile)),
        const SizedBox(height: 12),
        OtpField(onChanged: onChanged, onResend: onResend),
        const SizedBox(height: 12),
        KhButton(
          label: l10n.authVerifyAndContinue,
          busy: busy,
          onPressed: canSubmit ? onVerify : null,
        ),
        TextButton(
          onPressed: busy ? null : onBack,
          child: Text(l10n.authChangeNumber),
        ),
      ],
    );
  }
}
