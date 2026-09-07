// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_verification_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VendorVerificationDetailImpl _$$VendorVerificationDetailImplFromJson(
  Map<String, dynamic> json,
) => _$VendorVerificationDetailImpl(
  id: json['id'] as String,
  legalBusinessName: json['legalBusinessName'] as String,
  tradeLicenceNumber: json['tradeLicenceNumber'] as String,
  licenceExpiryDate: _dateFromJson(json['licenceExpiryDate']),
  businessAddress: json['businessAddress'] as String,
  contactPersonName: json['contactPersonName'] as String,
  businessEmail: json['businessEmail'] as String,
  documents:
      (json['documents'] as List<dynamic>?)
          ?.map((e) => VendorDocumentDetail.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <VendorDocumentDetail>[],
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  regions:
      (json['regions'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  tradingName: json['tradingName'] as String?,
  mobileNumber: json['mobileNumber'] as String?,
  oldestWaitingHours: (json['oldestWaitingHours'] as num?)?.toDouble(),
  submittedAt: json['submittedAt'] == null
      ? null
      : DateTime.parse(json['submittedAt'] as String),
);

Map<String, dynamic> _$$VendorVerificationDetailImplToJson(
  _$VendorVerificationDetailImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'legalBusinessName': instance.legalBusinessName,
  'tradeLicenceNumber': instance.tradeLicenceNumber,
  'licenceExpiryDate': instance.licenceExpiryDate.toIso8601String(),
  'businessAddress': instance.businessAddress,
  'contactPersonName': instance.contactPersonName,
  'businessEmail': instance.businessEmail,
  'documents': instance.documents,
  'categories': instance.categories,
  'regions': instance.regions,
  'tradingName': instance.tradingName,
  'mobileNumber': instance.mobileNumber,
  'oldestWaitingHours': instance.oldestWaitingHours,
  'submittedAt': instance.submittedAt?.toIso8601String(),
};

_$VendorDocumentDetailImpl _$$VendorDocumentDetailImplFromJson(
  Map<String, dynamic> json,
) => _$VendorDocumentDetailImpl(
  id: json['id'] as String,
  documentType: json['documentType'] as String,
  uploadedAt: DateTime.parse(json['uploadedAt'] as String),
  fileName: json['fileName'] as String?,
  mimeType: json['mimeType'] as String?,
  sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
  expiryDate: json['expiryDate'] == null
      ? null
      : DateTime.parse(json['expiryDate'] as String),
  verified: json['verified'] as bool? ?? false,
);

Map<String, dynamic> _$$VendorDocumentDetailImplToJson(
  _$VendorDocumentDetailImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'documentType': instance.documentType,
  'uploadedAt': instance.uploadedAt.toIso8601String(),
  'fileName': instance.fileName,
  'mimeType': instance.mimeType,
  'sizeBytes': instance.sizeBytes,
  'expiryDate': instance.expiryDate?.toIso8601String(),
  'verified': instance.verified,
};
