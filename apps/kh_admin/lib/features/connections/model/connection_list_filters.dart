import 'package:kh_admin/features/connections/model/connection_enums.dart';

/// Filter criteria for ADM-S12 Connection List.
class ConnectionListFilters {
  const ConnectionListFilters({
    this.state,
    this.query = '',
    this.hasNoContactOnly = false,
  });

  final ConnectionState? state;
  final String query;
  final bool hasNoContactOnly;

  ConnectionListFilters copyWith({
    ConnectionState? state,
    bool clearState = false,
    String? query,
    bool? hasNoContactOnly,
  }) {
    return ConnectionListFilters(
      state: clearState ? null : (state ?? this.state),
      query: query ?? this.query,
      hasNoContactOnly: hasNoContactOnly ?? this.hasNoContactOnly,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionListFilters &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          query == other.query &&
          hasNoContactOnly == other.hasNoContactOnly;

  @override
  int get hashCode => Object.hash(state, query, hasNoContactOnly);
}
