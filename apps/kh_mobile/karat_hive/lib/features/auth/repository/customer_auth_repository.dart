import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';

import '../../../app/di.dart';

/// Domain-shaped wrapper over [KhApi] for the Customer auth vertical
/// (`CUS-S01`, CFE-09 / CFE-10). `presentation` never touches `kh_api`; it goes
/// controller → repository → `kh_api` (Architecture-Frontend §5.2).
///
/// Google Sign-In is the only login (`adr/0010`): there is no `oauth/bind` step.
/// An unbound Google token comes back from `POST /v1/auth/google/session` as
/// `401 UNAUTHENTICATED` and the caller routes to the completion step, it is not
/// an error toast.
class CustomerAuthRepository {
  CustomerAuthRepository(this._api);
  final KhApi _api;

  /// Legal document versions accepted at registration. The backend stores the
  /// string verbatim (`registerCustomerSchema`); there is no server-provided
  /// version yet, so this mirrors the Vendor register flow's constant.
  static const termsVersion = '1.0';
  static const privacyVersion = '1.0';

  /// Exchanges a Firebase/Google ID token for a Karat Hive [SessionBundle].
  /// Unbound identity → `Err(UnauthorisedFailure(code: 'UNAUTHENTICATED'))`.
  Future<Result<SessionBundle>> googleSession(String idToken) =>
      _api.googleSession(idToken: idToken);

  /// Requests an OTP to prove a real mobile number for a new Customer.
  Future<Result<OtpChallenge>> requestOtp(String mobileNumber) =>
      _api.otpRequest(mobileNumber: mobileNumber, purpose: 'REGISTER_CUSTOMER');

  Future<Result<OtpVerifyResult>> verifyOtp(String challengeId, String code) =>
      _api.otpVerify(challengeId: challengeId, code: code);

  /// Completes a new Google user: binds the Google identity (`firebaseToken`),
  /// attaches the verified mobile (`challengeId`), records terms acceptance, and
  /// returns a signed-in [SessionBundle].
  Future<Result<SessionBundle>> registerCustomer({
    required String firebaseToken,
    required String challengeId,
    required String displayName,
    String? email,
    String? preferredLanguage,
    String? defaultRegionId,
  }) =>
      _api.registerCustomer(
        firebaseToken: firebaseToken,
        challengeId: challengeId,
        displayName: displayName,
        email: email,
        preferredLanguage: preferredLanguage ?? 'en',
        defaultRegionId: defaultRegionId,
        termsVersion: termsVersion,
        privacyVersion: privacyVersion,
      );
}

final customerAuthRepositoryProvider = Provider<CustomerAuthRepository>(
  (ref) => CustomerAuthRepository(ref.watch(khApiProvider)),
);
