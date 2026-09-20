import 'package:flutter/foundation.dart';
import 'package:kh_admin/core/auth/auth_models.dart';

enum SessionStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
}

/// Immutable session state.
@immutable
class SessionState {
  const SessionState({
    this.status = SessionStatus.initial,
    this.tokens,
    this.admin,
    this.errorMessage,
    this.bootstrapped = true,
  });

  final SessionStatus status;
  final SessionTokens? tokens;
  final AdminUser? admin;
  final String? errorMessage;

  /// `false` only while [SessionController] resolves the session for the very
  /// first time. The route guard parks on the splash route until this flips,
  /// so protected screens never mount against an unresolved session.
  /// Defaults to `true` so a directly-constructed state (tests, fakes) is not
  /// treated as mid-bootstrap.
  final bool bootstrapped;

  bool get isAuthenticated =>
      status == SessionStatus.authenticated &&
      tokens != null &&
      tokens!.accessToken.isNotEmpty;

  bool get isLoading =>
      status == SessionStatus.loading || status == SessionStatus.initial;

  SessionState copyWith({
    SessionStatus? status,
    SessionTokens? tokens,
    AdminUser? admin,
    String? errorMessage,
    bool? bootstrapped,
    bool clearTokens = false,
    bool clearAdmin = false,
    bool clearError = false,
  }) {
    return SessionState(
      status: status ?? this.status,
      tokens: clearTokens ? null : (tokens ?? this.tokens),
      admin: clearAdmin ? null : (admin ?? this.admin),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      bootstrapped: bootstrapped ?? this.bootstrapped,
    );
  }
}
