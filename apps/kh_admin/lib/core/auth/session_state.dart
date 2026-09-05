import 'package:flutter/foundation.dart';
import 'auth_models.dart';

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
  });

  final SessionStatus status;
  final SessionTokens? tokens;
  final AdminUser? admin;
  final String? errorMessage;

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
    bool clearTokens = false,
    bool clearAdmin = false,
    bool clearError = false,
  }) {
    return SessionState(
      status: status ?? this.status,
      tokens: clearTokens ? null : (tokens ?? this.tokens),
      admin: clearAdmin ? null : (admin ?? this.admin),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
