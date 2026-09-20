import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:kh_admin/features/auth/presentation/google_sign_in_button_stub.dart'
    if (dart.library.html) 'package:kh_admin/features/auth/presentation/google_sign_in_button_web.dart'
    as impl;

/// Platform Google Sign-In control.
///
/// On web this renders the GIS button (FedCM) so Chrome COOP cannot break the
/// Firebase `signInWithPopup` / `window.closed` handshake. On other platforms
/// it falls back to [fallback].
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.fallback,
    this.onWebCredential,
    this.enabled = true,
  });

  /// Non-web (or disabled) button built by the caller.
  final Widget fallback;

  /// Web-only: called with the Google ID token from GIS.
  final Future<void> Function(String idToken)? onWebCredential;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || onWebCredential == null) {
      return fallback;
    }
    // Keep the GIS widget mounted across `enabled` toggles (e.g. the password
    // form submitting) instead of swapping subtrees, which would tear down
    // and re-initialize Google Identity Services on every unrelated submit.
    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: impl.buildGoogleSignInButton(onIdToken: onWebCredential!),
      ),
    );
  }
}
