import 'package:json_annotation/json_annotation.dart';

/// Customer account lifecycle state (`UserAccountState` in Prisma).
@JsonEnum(alwaysCreate: true)
enum CustomerAccountState {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('SUSPENDED')
  suspended,
  @JsonValue('DEACTIVATED')
  deactivated;

  String get apiValue {
    switch (this) {
      case CustomerAccountState.active:
        return 'ACTIVE';
      case CustomerAccountState.suspended:
        return 'SUSPENDED';
      case CustomerAccountState.deactivated:
        return 'DEACTIVATED';
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
    }
  }

  static CustomerAccountState? fromApi(String? value) {
    if (value == null || value.isEmpty) return null;
    final upper = value.toUpperCase().trim();
    for (final state in CustomerAccountState.values) {
      if (state.apiValue == upper) return state;
    }
    return null;
  }
}
