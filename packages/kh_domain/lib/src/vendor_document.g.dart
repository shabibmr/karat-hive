// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VendorDocument _$VendorDocumentFromJson(Map<String, dynamic> json) =>
    _VendorDocument(
      id: json['id'] as String,
      documentType: const _VendorDocumentTypeConverter().fromJson(
        json['documentType'] as String?,
      ),
      verified: json['verified'] as bool,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
    );

Map<String, dynamic> _$VendorDocumentToJson(_VendorDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'documentType': const _VendorDocumentTypeConverter().toJson(
        instance.documentType,
      ),
      'verified': instance.verified,
      'uploadedAt': instance.uploadedAt.toIso8601String(),
      'expiryDate': instance.expiryDate?.toIso8601String(),
    };
