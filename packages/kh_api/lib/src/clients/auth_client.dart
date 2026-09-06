import 'package:kh_core/kh_core.dart';
import '../dtos.dart';

class AuthClient {
  const AuthClient(this._client);
  final KhApiClient _client;

  Future<Result<OtpChallenge>> otpRequest({
    required String mobileNumber,
    required String purpose,
  }) async {
    final r = await _client.send('POST', '/v1/auth/otp/request', body: {
      'mobileNumber': mobileNumber,
      'purpose': purpose,
    });
    return r.when(
      ok: (d) => Ok(OtpChallenge.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<OtpVerifyResult>> otpVerify({
    required String challengeId,
    required String code,
  }) async {
    final r = await _client.send('POST', '/v1/auth/otp/verify', body: {
      'challengeId': challengeId,
      'code': code,
    });
    return r.when(
      ok: (d) => Ok(OtpVerifyResult.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<SessionBundle>> registerVendor(Map<String, dynamic> body) async {
    final r = await _client.send('POST', '/v1/auth/register/vendor', body: body);
    return r.when(
      ok: (d) => Ok(SessionBundle.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<SessionBundle>> loginPassword({
    required String email,
    required String password,
  }) async {
    final r = await _client.send('POST', '/v1/auth/login/password',
        body: {'email': email, 'password': password});
    return r.when(
      ok: (d) => Ok(SessionBundle.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  static Future<SessionTokens?> refresh(
    KhApiClient client,
    String refreshToken,
  ) async {
    final r = await client.send('POST', '/v1/auth/refresh',
        body: {'refreshToken': refreshToken});
    return r.when(
      ok: (d) => SessionBundle.fromJson(d as Map<String, dynamic>).tokens,
      err: (_) => null,
    );
  }

  Future<void> logout(String? refreshToken) =>
      _client.send('POST', '/v1/auth/logout', body: {'refreshToken': refreshToken});
}
