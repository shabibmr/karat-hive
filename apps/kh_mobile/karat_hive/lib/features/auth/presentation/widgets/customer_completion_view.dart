import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../controller/customer_completion_controller.dart';
import '../../model/customer_completion_form.dart';

/// Shared Customer signup form (CFE-10) — one controller for all doors (GL-42).
class CustomerCompletionView extends ConsumerStatefulWidget {
  const CustomerCompletionView({
    super.key,
    required this.firebaseIdToken,
    this.suggestedName,
    this.suggestedEmail,
  });

  final String firebaseIdToken;
  final String? suggestedName;
  final String? suggestedEmail;

  @override
  ConsumerState<CustomerCompletionView> createState() =>
      _CustomerCompletionViewState();
}

class _CustomerCompletionViewState
    extends ConsumerState<CustomerCompletionView> {
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  String _code = '';
  bool _seededText = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(customerCompletionControllerProvider.notifier).begin(
            firebaseIdToken: widget.firebaseIdToken,
            suggestedName: widget.suggestedName,
            suggestedEmail: widget.suggestedEmail,
          );
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = KhL10n.of(context)!;
    final form = ref.watch(customerCompletionControllerProvider);
    final controller = ref.read(customerCompletionControllerProvider.notifier);

    if (!_seededText) {
      _seededText = true;
      _name.text = form.displayName.isNotEmpty
          ? form.displayName
          : (widget.suggestedName ?? '');
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
    final l10n = KhL10n.of(context)!;
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
              Text(
                l10n.authViewTerms,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                l10n.authViewPrivacy,
                style: Theme.of(context).textTheme.bodySmall,
              ),
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
    final l10n = KhL10n.of(context)!;
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
