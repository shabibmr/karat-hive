import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../../app/session/session_controller.dart';
import 'widgets/customer_completion_view.dart';

/// Customer signup after UnboundGoogle (GL-42 / GL-43).
///
/// Thin wrapper: seeds [CustomerCompletionController] with the Firebase ID
/// token from [UnboundGoogle]. Do not use the legacy OTP-only register path.
class CustomerRegisterScreen extends ConsumerWidget {
  const CustomerRegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = KhL10n.of(context)!;
    final session = ref.watch(sessionProvider);

    if (session is! UnboundGoogle || session.firebaseIdToken.isEmpty) {
      return KhScaffold(
        title: l10n.authCompleteProfileTitle,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.authSignInFailed,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return KhScaffold(
      key: const Key('customer-register-completion'),
      title: l10n.authCompleteProfileTitle,
      body: CustomerCompletionView(
        firebaseIdToken: session.firebaseIdToken,
        suggestedName: session.suggestedName,
        suggestedEmail: session.suggestedEmail,
      ),
    );
  }
}
