import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kh_admin/core/log/kh_logger.dart';
import 'package:kh_admin/core/log/kh_logger_provider.dart';

class FirebaseAuthService {
  FirebaseAuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    KhLogger? logger,
  })  : _customAuth = auth,
        _customGoogleSignIn = googleSignIn,
        _logger = logger ?? const KhLogger();

  final FirebaseAuth? _customAuth;
  final GoogleSignIn? _customGoogleSignIn;
  final KhLogger _logger;
  static bool _googleSignInInitialized = false;

  FirebaseAuth? get _auth {
    if (_customAuth != null) return _customAuth;
    try {
      return FirebaseAuth.instance;
    } on Object catch (_) {
      return null;
    }
  }

  GoogleSignIn? get _googleSignIn {
    if (_customGoogleSignIn != null) return _customGoogleSignIn;
    try {
      return GoogleSignIn.instance;
    } on Object catch (_) {
      return null;
    }
  }

  User? get currentUser => _auth?.currentUser;

  Stream<User?> get authStateChanges =>
      _auth?.authStateChanges() ?? const Stream.empty();

  /// Returns the current Firebase user's ID token, optionally forcing a refresh.
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return _auth?.currentUser?.getIdToken(forceRefresh);
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    final gsi = _googleSignIn;
    if (gsi == null) return;
    if (!_googleSignInInitialized) {
      await gsi.initialize(
        clientId: kIsWeb
            ? '132845397292-t8q9pjhr4jdrei8ha44b0lipjd1c5h5n.apps.googleusercontent.com'
            : null,
      );
      _googleSignInInitialized = true;
    }
  }

  /// Signs in with Google using GoogleSignIn.instance and Firebase Auth.
  Future<UserCredential?> signInWithGoogle() async {
    final auth = _auth;
    final gsi = _googleSignIn;
    if (auth == null || gsi == null) {
      throw StateError('Firebase Auth or Google Sign-In is not initialized.');
    }
    try {
      await _ensureGoogleSignInInitialized();
      final account = await gsi.authenticate();
      final idToken = account.authentication.idToken;

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      return await auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e, st) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      _logger.error('Google Sign-In exception', e, st);
      rethrow;
    } on Object catch (e, st) {
      _logger.error('Error signing in with Google', e, st);
      rethrow;
    }
  }

  /// Signs in with email and password.
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    final auth = _auth;
    if (auth == null) {
      throw StateError('Firebase Auth is not initialized.');
    }
    return auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Signs out from both Firebase and Google.
  Future<void> signOut() async {
    try {
      final futures = <Future<dynamic>>[];
      if (_auth != null) futures.add(_auth!.signOut());
      if (_googleSignIn != null) futures.add(_googleSignIn!.signOut());
      await Future.wait(futures);
    } on Object catch (e, st) {
      _logger.error('Error signing out', e, st);
      rethrow;
    }
  }
}

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  final logger = ref.watch(khLoggerProvider);
  return FirebaseAuthService(logger: logger);
});

final firebaseUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return authService.authStateChanges;
});
