import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';

import '../../../app/session/session_controller.dart';

/// CFE-11 — the OAuth-required publish gate primitive (`BR-001`, `FR-CUS-014`,
/// Architecture-Frontend §7.3).
///
/// OAuth is not required to sign in or to browse. It gates exactly one action:
/// publishing a Request (`CUS-S09`). This reports whether the current session
/// may publish, from `session.user.oauthBound` — the client mirror of the
/// server's `OAUTH_REQUIRED` rule. A bypassed check still meets a server error.
class PublishGate {
  const PublishGate({required this.oauthBound});

  final bool oauthBound;

  bool get canPublish => oauthBound;
}

/// The server error code returned by `POST /v1/requests/{id}/publish` when the
/// Customer has no Google binding.
const kOAuthRequiredCode = 'OAUTH_REQUIRED';

/// True when [failure] is the publish-gate rejection — CFE-19 shows
/// `SH-AUTH-05` instead of a generic error when this is true.
bool isOAuthRequired(Failure failure) => failure.code == kOAuthRequiredCode;

final publishGateProvider = Provider<PublishGate>((ref) {
  final session = ref.watch(sessionProvider);
  final bound = switch (session) {
    SignedIn(:final user) => user.oauthBound,
    _ => false,
  };
  return PublishGate(oauthBound: bound);
});
