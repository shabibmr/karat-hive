import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../../app/guards.dart';
import '../../../core/firebase/firebase.dart';
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
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(vendorLoginControllerProvider);
    final controller = ref.read(vendorLoginControllerProvider.notifier);
    final busy = state is LoginBusy;
    final failure = state is LoginError ? state.failure : null;

    return DefaultTabController(
      length: 2,
      child: KhScaffold(
        title: l10n?.authSignIn ?? 'Sign in',
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (failure != null) ...[
              KhInlineError(
                message:
                    failure.message ?? (l10n?.authSignInFailed ?? 'Sign in failed.'),
              ),
              const SizedBox(height: 12),
            ],
            TabBar(
              tabs: [
                Tab(text: l10n?.authOtpTab ?? 'Mobile & code'),
                Tab(text: l10n?.authPasswordTab ?? 'Email & password'),
              ],
            ),
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
              onPressed: () => context.go(AppGuards.register),
              child: Text(l10n?.authRegister ?? 'Create a vendor account'),
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
    final l10n = AppLocalizations.of(context);
    final sent = state is LoginOtpSent ? state as LoginOtpSent : null;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          KhTextField(
            label: l10n?.authMobile ?? 'Mobile number',
            controller: mobile,
            keyboardType: TextInputType.phone,
          ),
          if (sent == null)
            KhButton(
              label: l10n?.authSendCode ?? 'Send code',
              onPressed: onSend,
              busy: busy,
            )
          else ...[
            OtpField(
              onChanged: (v) => code.text = v,
              onResend: onSend,
            ),
            const SizedBox(height: 12),
            KhButton(
              label: l10n?.authVerify ?? 'Verify',
              onPressed: () => onVerify(sent.challengeId),
              busy: busy,
            ),
          ],
        ],
      ),
    );
  }
}

class _PasswordTab extends ConsumerStatefulWidget {
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
  ConsumerState<_PasswordTab> createState() => _PasswordTabState();
}

class _PasswordTabState extends ConsumerState<_PasswordTab> {
  bool _googleSigningIn = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isBusy = widget.busy || _googleSigningIn;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          KhTextField(
            label: l10n?.authEmail ?? 'Business email',
            controller: widget.email,
            keyboardType: TextInputType.emailAddress,
          ),
          KhTextField(
            label: l10n?.authPassword ?? 'Password',
            controller: widget.password,
            obscure: true,
          ),
          KhButton(
            label: l10n?.authSignIn ?? 'Sign in',
            onPressed: widget.onSubmit,
            busy: isBusy,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('google-signin-button'),
            onPressed: isBusy
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    setState(() => _googleSigningIn = true);
                    try {
                      final auth = ref.read(firebaseAuthServiceProvider);
                      await auth.signInWithGoogle();
                    } catch (e) {
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n?.authGoogleSignInFailed('$e') ??
                                  'Google Sign-In failed: $e',
                            ),
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _googleSigningIn = false);
                      }
                    }
                  },
            icon: _googleSigningIn
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.account_circle_outlined, size: 20),
            label: Text(
              _googleSigningIn
                  ? (l10n?.authSigningInWithGoogle ?? 'Signing in...')
                  : (l10n?.authSignInWithGoogle ?? 'Sign in with Google'),
            ),
          ),
        ],
      ),
    );
  }
}
