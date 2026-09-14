import 'package:kh_domain/kh_domain.dart';

/// Create / draft-PATCH envelope helper: owner presenter plus optional
/// `meta.warnings` (contact-details scan on save — inventory §13).
class RequestDraftSave {
  const RequestDraftSave({
    required this.request,
    this.warnings = const [],
  });

  final RequestForCustomer request;
  final List<String> warnings;

  static RequestDraftSave fromEnvelope(dynamic raw) {
    final map = raw is Map<String, dynamic>
        ? raw
        : raw is Map
            ? Map<String, dynamic>.from(raw)
            : <String, dynamic>{};
    final data = map.containsKey('data') ? map['data'] : map;
    final meta = map['meta'] is Map
        ? Map<String, dynamic>.from(map['meta'] as Map)
        : const <String, dynamic>{};
    return RequestDraftSave(
      request: RequestForCustomer.fromJson(_asMap(data)),
      warnings: _warnings(meta),
    );
  }

  static Map<String, dynamic> _asMap(Object? raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return const {};
  }

  static List<String> _warnings(Map<String, dynamic> meta) {
    final raw = meta['warnings'];
    if (raw is! List) return const [];
    return raw
        .map((e) {
          if (e is String) return e;
          if (e is Map) return (e['message'] ?? e['code'] ?? '').toString();
          return e.toString();
        })
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }
}
