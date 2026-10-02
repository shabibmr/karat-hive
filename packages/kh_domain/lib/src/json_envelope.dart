// Shared JSON helpers for API resource maps.

Map<String, dynamic> mapJson(Object? raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return const {};
}

/// Peels a mistaken extra `{ data: resource }` layer from double-enveloped
/// responses (controller returned `{ data }` and EnvelopeInterceptor wrapped
/// again). Prefer fixing the controller; this keeps older deployments parseable.
Map<String, dynamic> unwrapResourceJson(
  Map<String, dynamic> json, {
  String idKey = 'id',
}) {
  if (json[idKey] != null) return json;
  final nested = json['data'];
  if (nested is Map) return mapJson(nested);
  return json;
}
