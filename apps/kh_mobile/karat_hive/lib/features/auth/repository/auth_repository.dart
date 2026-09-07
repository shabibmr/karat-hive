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

  Future<Result<SessionBundle>> loginPassword(String email, String password) =>
      _api.loginPassword(email: email, password: password);

  Future<Result<SessionBundle>> googleSession(String idToken) =>
      _api.googleSession(idToken: idToken);
}

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository(ref.watch(khApiProvider)));
