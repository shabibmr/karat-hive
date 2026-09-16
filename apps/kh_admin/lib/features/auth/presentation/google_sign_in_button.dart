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
    if (!kIsWeb || !enabled || onWebCredential == null) {
      return fallback;
    }
    return impl.buildGoogleSignInButton(onIdToken: onWebCredential!);
  }
}
