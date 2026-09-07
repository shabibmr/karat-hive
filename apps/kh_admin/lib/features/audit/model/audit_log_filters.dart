/// Filter criteria for querying audit logs (ADM-S22).
class AuditLogFilters {
  const AuditLogFilters({
    this.actorUserId,
    this.action,
    this.entityType,
    this.entityId,
    this.from,
    this.to,
    this.ip,
  });

  final String? actorUserId;
  final String? action;
  final String? entityType;
  final String? entityId;
  final DateTime? from;
  final DateTime? to;
  final String? ip;

  bool get hasActiveFilters =>
      (actorUserId != null && actorUserId!.isNotEmpty) ||
      (action != null && action!.isNotEmpty) ||
      (entityType != null && entityType!.isNotEmpty) ||
      (entityId != null && entityId!.isNotEmpty) ||
      from != null ||
      to != null ||
      (ip != null && ip!.isNotEmpty);

  AuditLogFilters copyWith({
    String? actorUserId,
    String? action,
    String? entityType,
    String? entityId,
    DateTime? from,
    DateTime? to,
    String? ip,
    bool clearActorUserId = false,
    bool clearAction = false,
    bool clearEntityType = false,
    bool clearEntityId = false,
    bool clearFrom = false,
    bool clearTo = false,
    bool clearIp = false,
  }) {
    return AuditLogFilters(
      actorUserId: clearActorUserId ? null : (actorUserId ?? this.actorUserId),
      action: clearAction ? null : (action ?? this.action),
      entityType: clearEntityType ? null : (entityType ?? this.entityType),
      entityId: clearEntityId ? null : (entityId ?? this.entityId),
      from: clearFrom ? null : (from ?? this.from),
      to: clearTo ? null : (to ?? this.to),
      ip: clearIp ? null : (ip ?? this.ip),
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      if (actorUserId != null && actorUserId!.isNotEmpty)
        'actorUserId': actorUserId,
      if (action != null && action!.isNotEmpty) 'action': action,
      if (entityType != null && entityType!.isNotEmpty)
        'entityType': entityType,
      if (entityId != null && entityId!.isNotEmpty) 'entityId': entityId,
      if (from != null) 'from': from!.toUtc().toIso8601String(),
      if (to != null) 'to': to!.toUtc().toIso8601String(),
      if (ip != null && ip!.isNotEmpty) 'ip': ip,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuditLogFilters &&
          runtimeType == other.runtimeType &&
          actorUserId == other.actorUserId &&
          action == other.action &&
          entityType == other.entityType &&
          entityId == other.entityId &&
          from == other.from &&
          to == other.to &&
          ip == other.ip;

  @override
  int get hashCode =>
      Object.hash(actorUserId, action, entityType, entityId, from, to, ip);
}
