import 'package:flutter/foundation.dart';

import 'package:kh_admin/core/api/json_parse.dart';
import 'package:kh_admin/core/auth/admin_role.dart';

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
    final map = asMap(json);
    return SessionTokens(
      accessToken: map['accessToken']?.toString() ?? '',
      accessExpiresAt: DateTime.tryParse(map['accessExpiresAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      refreshToken: map['refreshToken']?.toString() ?? '',
      refreshExpiresAt: DateTime.tryParse(map['refreshExpiresAt']?.toString() ?? '') ??
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
    this.role,
  });

  final String userId;
  final String userType;
  final String? email;
  final String displayName;
  final AdminRole? role;

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    final map = asMap(json);
    final adminMap = asMap(map['admin']);
    final displayName = adminMap['displayName']?.toString() ??
        map['displayName']?.toString() ??
        'Platform Admin';

    return AdminUser(
      userId: map['userId']?.toString() ?? map['id']?.toString() ?? '',
      userType: map['userType']?.toString() ?? 'ADMIN',
      email: map['email']?.toString(),
      displayName: displayName,
      role: AdminRoleWire.fromWire(
        adminMap['role']?.toString() ?? map['role']?.toString(),
      ),
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
    final map = asMap(json);
    final tokensRaw = map['tokens'];
    final tokens = SessionTokens.fromJson(
      tokensRaw is Map ? asMap(tokensRaw) : map,
    );
    final userRaw = map['user'];
    final user = AdminUser.fromJson(
      userRaw is Map ? asMap(userRaw) : map,
    );

    return SessionBundle(tokens: tokens, user: user);
  }
}
