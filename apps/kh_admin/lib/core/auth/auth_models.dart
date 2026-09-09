import 'package:flutter/foundation.dart';

/// Persisted session tokens.
@immutable
class SessionTokens {
  const SessionTokens({
    required this.accessToken,
    required this.accessExpiresAt,
    required this.refreshToken,
    required this.refreshExpiresAt,
  });

  final String accessToken;
  final DateTime accessExpiresAt;
  final String refreshToken;
  final DateTime refreshExpiresAt;

  factory SessionTokens.fromJson(Map<String, dynamic> json) {
    return SessionTokens(
      accessToken: json['accessToken'] as String? ?? '',
      accessExpiresAt: DateTime.tryParse(json['accessExpiresAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      refreshToken: json['refreshToken'] as String? ?? '',
      refreshExpiresAt: DateTime.tryParse(json['refreshExpiresAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'accessExpiresAt': accessExpiresAt.toIso8601String(),
        'refreshToken': refreshToken,
        'refreshExpiresAt': refreshExpiresAt.toIso8601String(),
      };
}

/// Admin identity profile.
@immutable
class AdminUser {
  const AdminUser({
    required this.userId,
    required this.userType,
    required this.email,
    required this.displayName,
  });

  final String userId;
  final String userType;
  final String? email;
  final String displayName;

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    final adminMap = json['admin'] as Map<String, dynamic>?;
    final displayName = adminMap?['displayName'] as String? ??
        json['displayName'] as String? ??
        'Platform Admin';

    return AdminUser(
      userId: json['userId'] as String? ?? json['id'] as String? ?? '',
      userType: json['userType'] as String? ?? 'ADMIN',
      email: json['email'] as String?,
      displayName: displayName,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userType': userType,
        'email': email,
        'admin': {'displayName': displayName},
      };
}

/// Authentication session bundle returned by login and refresh endpoints.
@immutable
class SessionBundle {
  const SessionBundle({
    required this.tokens,
    required this.user,
  });

  final SessionTokens tokens;
  final AdminUser user;

  factory SessionBundle.fromJson(Map<String, dynamic> json) {
    final tokens = SessionTokens.fromJson(
      json.containsKey('tokens') && json['tokens'] is Map<String, dynamic>
          ? json['tokens'] as Map<String, dynamic>
          : json,
    );
    final user = AdminUser.fromJson(
      (json['user'] as Map<String, dynamic>?) ?? json,
    );

    return SessionBundle(tokens: tokens, user: user);
  }
}
