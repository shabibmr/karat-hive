import 'package:kh_core/kh_core.dart';

PagedResult<T> parsePagedEnvelope<T>(
  dynamic raw,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (raw is List) {
    return PagedResult(
      items: raw
          .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false),
    );
  }
  if (raw is Map) {
    final map = Map<String, dynamic>.from(raw);
    final dataList = (map['data'] as List?) ?? const [];
    final metaRaw = map['meta'];
    final meta = metaRaw is Map
        ? Map<String, dynamic>.from(metaRaw)
        : const <String, dynamic>{};
    return PagedResult(
      items: dataList
          .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false),
      nextCursor: meta['nextCursor'] as String?,
      hasMore: meta['hasMore'] as bool?,
    );
  }
  return const PagedResult.empty();
}
