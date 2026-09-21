import 'package:kh_admin/features/admin_users/model/admin_user_enums.dart';
import 'package:kh_admin/core/auth/admin_role.dart';

/// Single item in ADM-S23 Admin User Provisioning & Management.
///
/// Encapsulates the backend `AdminProfile` and associated `User` model.
class AdminUserItem {
  const AdminUserItem({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.email,
    required this.accountState,
    required this.createdAt,
    this.updatedAt,
    this.role,
  });

  /// The AdminProfile ID (or User ID if flat).
  final String id;

  /// The underlying User ID.
  final String userId;

  /// Administrator's display name.
  final String displayName;

  /// Administrator's verified email address.
  final String email;

  /// Lifecycle state of the admin user (ACTIVE, SUSPENDED, DEACTIVATED).
  final AdminAccountState accountState;

  /// Timestamp when the admin user was created.
  final DateTime createdAt;

  /// Timestamp of the last update, if available.
  final DateTime? updatedAt;

  /// RBAC role returned by the backend. Null means the server returned a legacy
  /// payload; UI actions must fail closed until the role is resolved.
  final AdminRole? role;

  factory AdminUserItem.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : null;
    final profileMap = json['profile'] is Map<String, dynamic>
        ? json['profile'] as Map<String, dynamic>
        : null;

    final id = profileMap?['id']?.toString() ??
        json['id']?.toString() ??
        userMap?['id']?.toString() ??
        '';

    final userId = profileMap?['userId']?.toString() ??
        json['userId']?.toString() ??
        userMap?['id']?.toString() ??
        '';

    final displayName = profileMap?['displayName']?.toString() ??
        json['displayName']?.toString() ??
        '';

    final email = userMap?['email']?.toString() ??
        json['email']?.toString() ??
        '';

    final rawState = userMap?['accountState']?.toString() ??
        profileMap?['accountState']?.toString() ??
        json['accountState']?.toString();

    final accountState = AdminAccountState.fromWire(rawState) ?? AdminAccountState.active;

    final rawCreatedAt = profileMap?['createdAt'] ??
        userMap?['createdAt'] ??
        json['createdAt'];

    final rawUpdatedAt = profileMap?['updatedAt'] ??
        userMap?['updatedAt'] ??
        json['updatedAt'];

    if (rawCreatedAt == null) {
      throw const FormatException('AdminUserItem.createdAt is required');
    }
    final createdAt = DateTime.tryParse(rawCreatedAt.toString());
    if (createdAt == null) {
      throw FormatException(
        'Invalid AdminUserItem.createdAt: $rawCreatedAt',
      );
    }

    final updatedAt = rawUpdatedAt != null
        ? DateTime.tryParse(rawUpdatedAt.toString())
        : null;

    return AdminUserItem(
      id: id,
      userId: userId,
      displayName: displayName,
      email: email,
      accountState: accountState,
      createdAt: createdAt,
      updatedAt: updatedAt,
      role: AdminRoleWire.fromWire(
        profileMap?['role']?.toString() ?? json['role']?.toString(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'accountState': accountState.wireValue,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (role != null) 'role': role!.wireValue,
      'user': <String, dynamic>{
        'id': userId,
        'email': email,
        'accountState': accountState.wireValue,
        'createdAt': createdAt.toIso8601String(),
      },
    };
  }

  AdminUserItem copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? email,
    AdminAccountState? accountState,
    DateTime? createdAt,
    DateTime? updatedAt,
    AdminRole? role,
  }) {
    return AdminUserItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      accountState: accountState ?? this.accountState,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUserItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          displayName == other.displayName &&
          email == other.email &&
          accountState == other.accountState &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          role == other.role;

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        displayName,
        email,
        accountState,
        createdAt,
        updatedAt,
      );

  @override
  String toString() =>
      'AdminUserItem(id: $id, displayName: $displayName, email: $email, state: ${accountState.wireValue}, role: ${role?.wireValue})';
}
