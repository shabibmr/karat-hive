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

class VendorDocument {
  const VendorDocument({
    required this.id,
    required this.documentType,
    required this.verified,
    required this.uploadedAt,
    this.expiryDate,
  });

  final String id;
  final VendorDocumentType documentType;
  final bool verified;
  final DateTime uploadedAt;
  final DateTime? expiryDate;

  static VendorDocument fromJson(Map<String, dynamic> j) => VendorDocument(
        id: j['id'] as String,
        documentType: VendorDocumentType.parse(j['documentType'] as String?),
        verified: j['verified'] as bool? ?? false,
        uploadedAt: DateTime.parse(j['uploadedAt'] as String),
        expiryDate: j['expiryDate'] == null
            ? null
            : DateTime.parse('${j['expiryDate']}T00:00:00Z'),
      );
}
