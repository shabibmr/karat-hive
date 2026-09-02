import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../controller/vendor_login_controller.dart';

class VendorLoginScreen extends ConsumerStatefulWidget {
  const VendorLoginScreen({super.key});

  @override
  ConsumerState<VendorLoginScreen> createState() => _VendorLoginScreenState();
}

class _VendorLoginScreenState extends ConsumerState<VendorLoginScreen> {
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();

  @override
  void dispose() {
    _mobile.dispose();
    _email.dispose();
    _password.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = KhStrings.of(context);
    final state = ref.watch(vendorLoginControllerProvider);
    final controller = ref.read(vendorLoginControllerProvider.notifier);
    final busy = state is LoginBusy;
    final failure = state is LoginError ? state.failure : null;

    return DefaultTabController(
      length: 2,
      child: KhScaffold(
        title: s.s('auth.signIn'),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (failure != null) ...[
              KhInlineError(message: failure.message ?? 'Sign in failed.'),
              const SizedBox(height: 12),
            ],
            const TabBar(tabs: [Tab(text: 'Mobile & code'), Tab(text: 'Email & password')]),
            SizedBox(
              height: 320,
              child: TabBarView(
                children: [
                  _OtpTab(
                    mobile: _mobile,
                    code: _code,
                    state: state,
                    busy: busy,
                    onSend: () => controller.sendOtp(_mobile.text.trim()),
                    onVerify: (cid) => controller.verifyOtp(cid, _code.text.trim()),
                  ),
                  _PasswordTab(
                    email: _email,
                    password: _password,
                    busy: busy,
                    onSubmit: () => controller.loginPassword(
                      _email.text.trim(),
                      _password.text,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => context.go('/vendor/register'),
              child: Text(s.s('auth.register')),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpTab extends StatelessWidget {
  const _OtpTab({
    required this.mobile,
    required this.code,
    required this.state,
    required this.busy,
    required this.onSend,
    required this.onVerify,
  });

  final TextEditingController mobile;
  final TextEditingController code;
  final LoginState state;
  final bool busy;
  final VoidCallback onSend;
  final void Function(String challengeId) onVerify;

  @override
  Widget build(BuildContext context) {
    final sent = state is LoginOtpSent ? state as LoginOtpSent : null;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          KhTextField(
            label: 'Mobile number',
            controller: mobile,
            keyboardType: TextInputType.phone,
          ),
          if (sent == null)
            KhButton(label: 'Send code', onPressed: onSend, busy: busy)
          else ...[
            OtpField(
              onChanged: (v) => code.text = v,
              onResend: onSend,
            ),
            const SizedBox(height: 12),
            KhButton(
              label: 'Verify',
              onPressed: () => onVerify(sent.challengeId),
              busy: busy,
            ),
          ],
        ],
      ),
    );
  }
}

class _PasswordTab extends StatelessWidget {
  const _PasswordTab({
    required this.email,
    required this.password,
    required this.busy,
    required this.onSubmit,
  });

  final TextEditingController email;
  final TextEditingController password;
  final bool busy;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          children: [
            KhTextField(
              label: 'Business email',
              controller: email,
              keyboardType: TextInputType.emailAddress,
            ),
            KhTextField(label: 'Password', controller: password, obscure: true),
            KhButton(label: 'Sign in', onPressed: onSubmit, busy: busy),
          ],
        ),
      );
}
