import 'package:kh_domain/src/connection.dart';
import 'package:kh_domain/src/offer.dart';
import 'package:kh_domain/src/request.dart';
import 'package:kh_domain/src/vendor_request_item.dart';

/// Human-readable Request title for UI (e.g. `Ring 22gm 22K`).
///
/// Never uses the system `KH-RQ-…` reference.
String formatRequestDisplayTitle({
  RequestType requestType = RequestType.unknown,
  OrnamentType? ornamentType,
  Object? weightGrams,
  Karat? purityKarat,
  String? purityKaratLabel,
  String? denominationGrams,
  int? quantity,
  String fallback = 'Request',
}) {
  final karat = _karatLabel(purityKarat, purityKaratLabel);
  final weight = _formatWeight(weightGrams);

  if (requestType == RequestType.goldCoin) {
    final parts = <String>[];
    if (quantity != null && quantity > 0) {
      parts.add('$quantity×');
    }
    final denom = _formatWeight(denominationGrams);
    if (denom != null) {
      parts.add('${denom}g');
    }
    parts.add('Coin');
    if (karat != null) parts.add(karat);
    if (quantity != null || denom != null || karat != null) {
      return parts.join(' ');
    }
  } else if (requestType == RequestType.goldBullion) {
    final parts = <String>[];
    if (weight != null) parts.add('${weight}gm');
    parts.add('Bullion');
    if (karat != null) parts.add(karat);
    if (weight != null || karat != null) {
      return parts.join(' ');
    }
  } else {
    final parts = <String>[];
    final ornament = _ornamentLabel(ornamentType);
    if (ornament != null) parts.add(ornament);
    if (weight != null) parts.add('${weight}gm');
    if (karat != null) parts.add(karat);
    if (parts.isNotEmpty) return parts.join(' ');
  }

  final typeLabel = _requestTypeFallback(requestType);
  if (typeLabel != null) return typeLabel;

  return fallback;
}

extension RequestForCustomerDisplayTitle on RequestForCustomer {
  String displayTitle({String locale = 'en', String fallback = 'Request'}) =>
      formatRequestDisplayTitle(
        requestType: requestType,
        ornamentType: ornamentType,
        weightGrams: weightGrams,
        purityKarat: purityKarat,
        denominationGrams: denominationGrams,
        quantity: quantity,
        fallback: fallback,
      );
}

extension VendorRequestItemDisplayTitle on VendorRequestItem {
  String displayTitle({String fallback = 'Request'}) =>
      formatRequestDisplayTitle(
        requestType: RequestType.parse(requestType),
        weightGrams: weightGrams,
        purityKaratLabel: purityKarat,
        fallback: fallback,
      );
}

extension OfferRequestSummaryDisplayTitle on OfferRequestSummary {
  String displayTitle({String fallback = 'Request'}) =>
      formatRequestDisplayTitle(
        requestType: requestType,
        weightGrams: weightGrams,
        purityKaratLabel: purityKarat,
        fallback: fallback,
      );
}

extension ConnectionRequestSnapshotDisplayTitle on ConnectionRequestSnapshot {
  String displayTitle({String locale = 'en', String fallback = 'Request'}) =>
      formatRequestDisplayTitle(
        requestType: requestType,
        fallback: fallback,
      );
}

String? _ornamentLabel(OrnamentType? type) {
  if (type == null || type == OrnamentType.unknown) return null;
  final wire = type.wire;
  if (wire.isEmpty || wire == 'UNKNOWN') return null;
  return '${wire[0].toUpperCase()}${wire.substring(1).toLowerCase()}';
}

String? _karatLabel(Karat? karat, String? raw) {
  if (karat != null && karat != Karat.unknown) return karat.wire;
  final trimmed = raw?.trim();
  if (trimmed == null || trimmed.isEmpty || trimmed == 'UNKNOWN') return null;
  return trimmed;
}

/// Formats a weight for display: strips trailing zeros (`22.00` → `22`).
String? _formatWeight(Object? raw) {
  if (raw == null) return null;
  if (raw is num) {
    if (raw == 0) return null;
    return _stripTrailingZeros(raw.toDouble());
  }
  final text = raw.toString().trim();
  if (text.isEmpty) return null;
  final parsed = double.tryParse(text);
  if (parsed == null) return text;
  if (parsed == 0) return null;
  return _stripTrailingZeros(parsed);
}

String _stripTrailingZeros(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  var s = value.toStringAsFixed(2);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
  }
  return s;
}

String? _requestTypeFallback(RequestType type) => switch (type) {
      RequestType.findOrnament => 'Find An Ornament',
      RequestType.sellOldGold => 'Sell Old Gold',
      RequestType.goldCoin => 'Gold Coin',
      RequestType.goldBullion => 'Gold Bullion',
      RequestType.unknown => null,
    };
