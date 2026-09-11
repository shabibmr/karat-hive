import 'package:karat_hive/app/session/session_controller.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

/// A [SessionController] that records `onAuthenticated` without touching secure
/// storage or Firebase — for the Customer auth vertical's unit tests.
class RecordingSessionController extends SessionController {
  RecordingSessionController([this._initial = const SignedOut()]);
  final SessionState _initial;
  final List<SessionBundle> authenticated = [];

  @override
  SessionState build() => _initial;

  @override
  Future<void> onAuthenticated(SessionBundle bundle) async {
    authenticated.add(bundle);
    state = SignedIn(bundle.user);
  }

  @override
  void markUnboundGoogle({
    required String firebaseIdToken,
    String? suggestedName,
    String? suggestedEmail,
  }) {
    state = UnboundGoogle(
      firebaseIdToken: firebaseIdToken,
      suggestedName: suggestedName,
      suggestedEmail: suggestedEmail,
    );
  }

  @override
  void markAuthBlocked(Failure failure) {
    state = AuthBlocked(failure);
  }

  @override
  Future<void> refreshUser() async {}
}

SessionBundle testCustomerBundle({bool oauthBound = true}) => SessionBundle(
      tokens: SessionTokens(
        accessToken: 'access',
        refreshToken: 'refresh',
        accessExpiresAt: DateTime.utc(2030),
        refreshExpiresAt: DateTime.utc(2030),
      ),
      user: MeUser(
        userId: 'c1',
        userType: 'CUSTOMER',
        mobileNumber: '+971500000009',
        preferredLanguage: 'en',
        oauthBound: oauthBound,
        customer: const CustomerMe(
          displayName: 'Layla',
          reviewCount: 0,
          connectionCount: 0,
        ),
      ),
    );
