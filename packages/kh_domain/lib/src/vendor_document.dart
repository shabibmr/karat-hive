import 'package:freezed_annotation/freezed_annotation.dart';

part 'vendor_document.freezed.dart';
part 'vendor_document.g.dart';

enum VendorDocumentType {
  tradeLicence,
  emiratesId,
  vatCert,
  tradingPermit,
  tenancy,
  other;

  String get wire => switch (this) {
        tradeLicence => 'TRADE_LICENCE',
        emiratesId => 'EMIRATES_ID',
        vatCert => 'VAT_CERT',
        tradingPermit => 'TRADING_PERMIT',
        tenancy => 'TENANCY',
        other => 'OTHER',
      };

  static VendorDocumentType parse(String? raw) => switch (raw) {
        'TRADE_LICENCE' => tradeLicence,
        'EMIRATES_ID' => emiratesId,
        'VAT_CERT' => vatCert,
        'TRADING_PERMIT' => tradingPermit,
        'TENANCY' => tenancy,
        _ => other,
      };

  String get label => switch (this) {
        tradeLicence => 'Trade licence',
        emiratesId => 'Emirates ID',
        vatCert => 'VAT certificate',
        tradingPermit => 'Trading permit',
        tenancy => 'Tenancy contract',
        other => 'Other document',
      };
}

const mandatoryVendorDocuments = [
  VendorDocumentType.tradeLicence,
  VendorDocumentType.emiratesId,
];

class _VendorDocumentTypeConverter
    implements JsonConverter<VendorDocumentType, String?> {
  const _VendorDocumentTypeConverter();

  @override
  VendorDocumentType fromJson(String? json) => VendorDocumentType.parse(json);

  @override
  String toJson(VendorDocumentType object) => object.wire;
}

Map<String, dynamic> _normalizeVendorDocumentJson(Map<String, dynamic> json) {
  final expiry = json['expiryDate'];
  String? expiryIso;
  if (expiry != null) {
    final raw = expiry.toString();
    expiryIso = raw.contains('T')
        ? (DateTime.tryParse(raw)?.toIso8601String())
        : (DateTime.tryParse('${raw}T00:00:00Z')?.toIso8601String());
  }

  final uploadedAt = DateTime.parse(json['uploadedAt'] as String);

  return {
    ...json,
    'documentType': json['documentType']?.toString(),
    'verified': json['verified'] as bool? ?? false,
    'uploadedAt': uploadedAt.toIso8601String(),
    'expiryDate': expiryIso,
  };
}

/// Vendor KYC / compliance document metadata (CP2-F06 freezed pattern).
@freezed
abstract class VendorDocument with _$VendorDocument {
  const factory VendorDocument({
    required String id,
    @_VendorDocumentTypeConverter() required VendorDocumentType documentType,
    required bool verified,
    required DateTime uploadedAt,
    DateTime? expiryDate,
  }) = _VendorDocument;

  factory VendorDocument.fromJson(Map<String, dynamic> json) =>
      _$VendorDocumentFromJson(_normalizeVendorDocumentJson(json));
}
