import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// SH-AUTH-02 — 6-digit code entry with a resend affordance.
class OtpField extends StatelessWidget {
  const OtpField({
    super.key,
    required this.onChanged,
    required this.onResend,
    this.resendCooldownSeconds = 0,
    this.errorText,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback onResend;
  final int resendCooldownSeconds;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('otp-input'),
          maxLength: 6,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: 'Verification code',
            counterText: '',
            errorText: errorText,
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: resendCooldownSeconds > 0 ? null : onResend,
            child: Text(
              resendCooldownSeconds > 0
                  ? 'Resend in ${resendCooldownSeconds}s'
                  : 'Resend code',
            ),
          ),
        ),
      ],
    );
  }
}
