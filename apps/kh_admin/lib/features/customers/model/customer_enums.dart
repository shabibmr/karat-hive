import 'package:json_annotation/json_annotation.dart';

/// Customer account lifecycle state (`UserAccountState` in Prisma).
@JsonEnum(alwaysCreate: true)
enum CustomerAccountState {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('SUSPENDED')
  suspended,
  @JsonValue('DEACTIVATED')
  deactivated,
  /// Unrecognized API value — never treat as Active for lifecycle UI.
  @JsonValue('UNKNOWN')
  unknown;

  String get apiValue {
    switch (this) {
      case CustomerAccountState.active:
        return 'ACTIVE';
      case CustomerAccountState.suspended:
        return 'SUSPENDED';
      case CustomerAccountState.deactivated:
        return 'DEACTIVATED';
      case CustomerAccountState.unknown:
        return 'UNKNOWN';
    }
  }

  String get displayName {
    switch (this) {
      case CustomerAccountState.active:
        return 'Active';
      case CustomerAccountState.suspended:
        return 'Suspended';
      case CustomerAccountState.deactivated:
        return 'Deactivated';
      case CustomerAccountState.unknown:
        return 'Unknown';
    }
  }

  /// Null/empty → null (no filter). Unrecognized wire values → [unknown].
  static CustomerAccountState? fromApi(String? value) {
    if (value == null || value.isEmpty) return null;
    final upper = value.toUpperCase().trim();
    for (final state in CustomerAccountState.values) {
      if (state == CustomerAccountState.unknown) continue;
      if (state.apiValue == upper) return state;
    }
    return CustomerAccountState.unknown;
  }
}
