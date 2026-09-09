/// Coercion helpers for raw backend rows.
///
/// The admin API serves Prisma rows without a DTO layer (`ADM-FE-P01`), so
/// repositories receive loosely-typed maps: `Decimal` columns arrive as JSON
/// strings, joins arrive as nested maps, and optional relations arrive as
/// `null`. These helpers give every repository one implementation of that
/// coercion instead of a private copy per feature.
library;

/// Narrows [value] to a string-keyed map, or an empty map when it is neither.
///
/// Covers the `Map<dynamic, dynamic>` that JSON decoding can yield for nested
/// relations.
Map<String, dynamic> asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

/// Coerces [value] to a double, falling back to [fallback] when absent or
/// unparseable. Handles `Decimal` columns serialised as JSON strings.
double toDouble(dynamic value, [double fallback = 0.0]) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? fallback;
}

/// As [toDouble], but preserves the difference between "absent" and "zero".
double? toDoubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

/// Whether a further page exists, given the cursor returned in `meta`.
///
/// The admin list routes send no `hasMore` flag — the presence of a non-empty
/// next cursor is the only pagination signal.
bool hasMoreFromCursor(String? nextCursor) =>
    nextCursor != null && nextCursor.isNotEmpty;

/// Unwraps an entity from an API response, ensuring a string-keyed map is returned.
///
/// Strips single or double `{ data: ... }` response wrappers without relying on
/// repo-local sentinel heuristics.
Map<String, dynamic> unwrapEntity(dynamic response) {
  if (response is! Map) {
    return const <String, dynamic>{};
  }
  var current = response;
  if (current.containsKey('data') && current['data'] is Map) {
    current = current['data'] as Map;
  }
  return asMap(current);
}

