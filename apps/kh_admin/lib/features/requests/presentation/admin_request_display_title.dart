import 'package:kh_domain/kh_domain.dart' as domain;

import 'package:kh_admin/features/requests/model/request_enums.dart';

/// Specs-based Request title for Admin UI. Never shows `KH-RQ-…`.
String adminRequestDisplayTitle({
  RequestType? requestType,
  String? requestTypeRaw,
  String? ornamentType,
  Object? weightGrams,
  String? purityKarat,
  Object? denominationGrams,
  int? quantity,
  String fallback = 'Request',
}) {
  final parsedType = requestType != null
      ? domain.RequestType.parse(requestType.apiValue)
      : domain.RequestType.parse(requestTypeRaw);

  return domain.formatRequestDisplayTitle(
    requestType: parsedType,
    ornamentType:
        ornamentType != null ? domain.OrnamentType.parse(ornamentType) : null,
    weightGrams: weightGrams,
    purityKaratLabel: purityKarat,
    denominationGrams: denominationGrams?.toString(),
    quantity: quantity,
    fallback: fallback,
  );
}
