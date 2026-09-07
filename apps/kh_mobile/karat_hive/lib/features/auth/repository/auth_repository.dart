import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';

import '../../../app/di.dart';

class AuthRepository {
  AuthRepository(this._api);
  final KhApi _api;

  Future<Result<OtpChallenge>> requestOtp(String mobileNumber, String purpose) =>
      _api.otpRequest(mobileNumber: mobileNumber, purpose: purpose);

  Future<Result<OtpVerifyResult>> verifyOtp(String challengeId, String code) =>
      _api.otpVerify(challengeId: challengeId, code: code);

  Future<Result<SessionBundle>> registerVendor(Map<String, dynamic> body) =>
      _api.registerVendor(body);

  Future<Result<SessionBundle>> registerCustomer({
    String? challengeId,
    String? firebaseToken,
    required String displayName,
    String? email,
    required String preferredLanguage,
    String? defaultRegionId,
    required String termsVersion,
    required String privacyVersion,
  }) =>
      _api.registerCustomer(
        challengeId: challengeId,
        firebaseToken: firebaseToken,
        displayName: displayName,
        email: email,
        preferredLanguage: preferredLanguage,
        defaultRegionId: defaultRegionId,
        termsVersion: termsVersion,
        privacyVersion: privacyVersion,
      );

  Future<Result<SessionBundle>> loginPassword(String email, String password) =>
      _api.loginPassword(email: email, password: password);

  Future<Result<SessionBundle>> googleSession(String idToken) =>
      _api.googleSession(idToken: idToken);

  /// One-time Google bind (`POST /v1/auth/oauth/bind`). Not a login (`adr/0010`).
  Future<Result<bool>> bindGoogle(String identityToken) async {
    final r = await _api.client.send('POST', '/v1/auth/oauth/bind', body: {
      'provider': 'GOOGLE',
      'identityToken': identityToken,
    });
    return r.when(
      ok: (_) => const Ok(true),
      err: Err.new,
    );
  }
}

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository(ref.watch(khApiProvider)));
