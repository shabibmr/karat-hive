import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart' as gsi_web;

const _webClientId =
    '132845397292-t8q9pjhr4jdrei8ha44b0lipjd1c5h5n.apps.googleusercontent.com';

/// GIS `renderButton` + authenticationEvents → ID token callback.
Widget buildGoogleSignInButton({
  required Future<void> Function(String idToken) onIdToken,
}) {
  return _GisGoogleSignInButton(onIdToken: onIdToken);
}

class _GisGoogleSignInButton extends StatefulWidget {
  const _GisGoogleSignInButton({required this.onIdToken});

  final Future<void> Function(String idToken) onIdToken;

  @override
  State<_GisGoogleSignInButton> createState() => _GisGoogleSignInButtonState();
}

class _GisGoogleSignInButtonState extends State<_GisGoogleSignInButton> {
  StreamSubscription<GoogleSignInAuthenticationEvent>? _sub;
  var _ready = false;
  Object? _initError;

  /// `renderButton` keys its platform view off `configuration.hashCode`, and
  /// `GSIButtonConfiguration` overrides neither `==` nor `hashCode` — so a
  /// config built inside `build()` yields a fresh key on every rebuild, which
  /// tears down the embedded GIS element and makes Google redraw it (the
  /// visible blink). Build it once and hold it.
  static final gsi_web.GSIButtonConfiguration _buttonConfiguration =
      gsi_web.GSIButtonConfiguration(
    type: gsi_web.GSIButtonType.standard,
    theme: gsi_web.GSIButtonTheme.outline,
    size: gsi_web.GSIButtonSize.large,
    text: gsi_web.GSIButtonText.signinWith,
    shape: gsi_web.GSIButtonShape.rectangular,
    logoAlignment: gsi_web.GSIButtonLogoAlignment.left,
    minimumWidth: 320,
  );

  /// The rendered GIS widget, cached for the same reason: an identical widget
  /// instance lets Flutter reuse the element instead of remounting the view.
  Widget? _button;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final gsi = GoogleSignIn.instance;
      await gsi.initialize(clientId: _webClientId);
      _sub = gsi.authenticationEvents.listen(_onEvent, onError: (_) {});
      if (mounted) {
        setState(() => _ready = true);
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() => _initError = e);
      }
    }
  }

  Future<void> _onEvent(GoogleSignInAuthenticationEvent event) async {
    if (event is! GoogleSignInAuthenticationEventSignIn) return;
    final idToken = event.user.authentication.idToken;
    if (idToken == null || idToken.isEmpty) return;
    await widget.onIdToken(idToken);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return Text(
        'Google Sign-In unavailable: $_initError',
        textAlign: TextAlign.center,
      );
    }
    if (!_ready) {
      return const SizedBox(
        height: 44,
        child: Center(child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )),
      );
    }
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: Center(
        child: _button ??= gsi_web.renderButton(
          configuration: _buttonConfiguration,
        ),
      ),
    );
  }
}
