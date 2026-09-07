import 'package:freezed_annotation/freezed_annotation.dart';

part 'vendor_verification_detail.freezed.dart';
part 'vendor_verification_detail.g.dart';

DateTime _dateFromJson(dynamic value) {
  if (value is String && !value.contains('T')) {
    return DateTime.parse('${value}T00:00:00Z');
  }
  return DateTime.parse(value as String);
}

/// Full vendor payload from `GET /v1/admin/vendors/{id}` for ADM-S07 review.
@freezed
class VendorVerificationDetail with _$VendorVerificationDetail {
  const factory VendorVerificationDetail({
    required String id,
    required String legalBusinessName,
    required String tradeLicenceNumber,
    @JsonKey(fromJson: _dateFromJson) required DateTime licenceExpiryDate,
    required String businessAddress,
    required String contactPersonName,
    required String businessEmail,
    @Default(<VendorDocumentDetail>[]) List<VendorDocumentDetail> documents,
    @Default(<String>[]) List<String> categories,
    @Default(<String>[]) List<String> regions,
    String? tradingName,
    String? mobileNumber,
    double? oldestWaitingHours,
    DateTime? submittedAt,
  }) = _VendorVerificationDetail;

  factory VendorVerificationDetail.fromJson(Map<String, dynamic> json) =>
      _$VendorVerificationDetailFromJson(json);
}

/// KYC document metadata returned on the admin vendor detail payload.
@freezed
class VendorDocumentDetail with _$VendorDocumentDetail {
  const factory VendorDocumentDetail({
    required String id,
    required String documentType,
    required DateTime uploadedAt,
    String? fileName,
    String? mimeType,
    int? sizeBytes,
    DateTime? expiryDate,
    @Default(false) bool verified,
  }) = _VendorDocumentDetail;

  factory VendorDocumentDetail.fromJson(Map<String, dynamic> json) =>
      _$VendorDocumentDetailFromJson(json);
}
