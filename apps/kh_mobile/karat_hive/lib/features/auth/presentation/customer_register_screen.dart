import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../controller/customer_register_controller.dart';
import '../model/customer_register_form_state.dart';

/// CUS-S01 register: display name, optional email, terms, OTP phone proof.
class CustomerRegisterScreen extends ConsumerWidget {
  const CustomerRegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = KhStrings.of(context);
    final tokens = context.tokens;
    final form = ref.watch(customerRegisterControllerProvider);
    final controller = ref.read(customerRegisterControllerProvider.notifier);

    return KhScaffold(
      title: strings.s('auth.registerCustomer'),
      body: ListView(
        key: const Key('cus-s01-register'),
        padding: EdgeInsets.all(tokens.space.md),
        children: [
          if (form.failure != null) ...[
            KhInlineError(
              message: form.failure!.message ?? strings.s('auth.registerCustomer'),
            ),
            SizedBox(height: tokens.space.md),
          ],
          if (form.step == CustomerRegisterStep.otp)
            _OtpStep(
              busy: form.busy,
              onVerify: controller.verifyOtp,
              onResend: controller.sendOtp,
            )
          else ...[
            KhTextField(
              label: strings.s('auth.displayName'),
              initialValue: form.displayName,
              onChanged: (v) => controller.patch((s) => s.copyWith(displayName: v)),
            ),
            KhTextField(
              label: strings.s('auth.emailOptional'),
              initialValue: form.email,
              keyboardType: TextInputType.emailAddress,
              onChanged: (v) => controller.patch((s) => s.copyWith(email: v)),
            ),
            KhTextField(
              label: strings.s('auth.mobile'),
              initialValue: form.mobileNumber,
              keyboardType: TextInputType.phone,
              onChanged: (v) => controller.patch((s) => s.copyWith(mobileNumber: v)),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: form.acceptTerms,
              onChanged: (v) =>
                  controller.patch((s) => s.copyWith(acceptTerms: v ?? false)),
              title: Text(strings.s('auth.acceptTerms')),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: form.acceptPrivacy,
              onChanged: (v) =>
                  controller.patch((s) => s.copyWith(acceptPrivacy: v ?? false)),
              title: Text(strings.s('auth.acceptPrivacy')),
            ),
            SizedBox(height: tokens.space.md),
            KhButton(
              label: strings.s('auth.createAccount'),
              busy: form.busy,
              onPressed: form.detailsComplete ? controller.sendOtp : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _CustomerOtpStep extends StatefulWidget {
  const _CustomerOtpStep({
    required this.busy,
    required this.onVerify,
    required this.onResend,
  });

  final bool busy;
  final void Function(String code) onVerify;
  final VoidCallback onResend;

  @override
  State<_CustomerOtpStep> createState() => _CustomerOtpStepState();
}

class _CustomerOtpStepState extends State<_CustomerOtpStep> {
  String _code = '';

  @override
  Widget build(BuildContext context) {
    final strings = KhStrings.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(strings.s('auth.proveMobile')),
        SizedBox(height: context.tokens.space.md),
        OtpField(
          onChanged: (v) => _code = v,
          onResend: widget.onResend,
        ),
        SizedBox(height: context.tokens.space.md),
        KhButton(
          label: strings.s('auth.verify'),
          busy: widget.busy,
          onPressed: () => widget.onVerify(_code),
        ),
      ],
    );
  }
}
