import 'package:kh_admin/features/vendors/model/vendor_enums.dart';
import 'package:kh_admin/features/verification/model/vendor_verification_detail.dart';

/// Full vendor profile data model for ADM-S06.
class VendorDetail {
  const VendorDetail({
    required this.id,
    required this.legalBusinessName,
    this.tradingName,
    required this.tradeLicenceNumber,
    required this.licenceExpiryDate,
    required this.businessAddress,
    required this.contactPersonName,
    required this.businessEmail,
    this.mobileNumber,
    this.verificationState = VendorVerificationState.registered,
    this.accountState = VendorAccountState.active,
    this.categories = const [],
    this.regions = const [],
    this.documents = const [],
    this.oldestWaitingHours,
    this.submittedAt,
  });

  final String id;
  final String legalBusinessName;
  final String? tradingName;
  final String tradeLicenceNumber;
  final DateTime licenceExpiryDate;
  final String businessAddress;
  final String contactPersonName;
  final String businessEmail;
  final String? mobileNumber;
  final VendorVerificationState verificationState;
  final VendorAccountState accountState;
  final List<String> categories;
  final List<String> regions;
  final List<VendorDocumentDetail> documents;
  final double? oldestWaitingHours;
  final DateTime? submittedAt;

  bool get isLicenceExpired => licenceExpiryDate.isBefore(DateTime.now());

  VendorDetail copyWith({
    String? id,
    String? legalBusinessName,
    String? tradingName,
    String? tradeLicenceNumber,
    DateTime? licenceExpiryDate,
    String? businessAddress,
    String? contactPersonName,
    String? businessEmail,
    String? mobileNumber,
    VendorVerificationState? verificationState,
    VendorAccountState? accountState,
    List<String>? categories,
    List<String>? regions,
    List<VendorDocumentDetail>? documents,
    double? oldestWaitingHours,
    DateTime? submittedAt,
  }) {
    return VendorDetail(
      id: id ?? this.id,
      legalBusinessName: legalBusinessName ?? this.legalBusinessName,
      tradingName: tradingName ?? this.tradingName,
      tradeLicenceNumber: tradeLicenceNumber ?? this.tradeLicenceNumber,
      licenceExpiryDate: licenceExpiryDate ?? this.licenceExpiryDate,
      businessAddress: businessAddress ?? this.businessAddress,
      contactPersonName: contactPersonName ?? this.contactPersonName,
      businessEmail: businessEmail ?? this.businessEmail,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      verificationState: verificationState ?? this.verificationState,
      accountState: accountState ?? this.accountState,
      categories: categories ?? this.categories,
      regions: regions ?? this.regions,
      documents: documents ?? this.documents,
      oldestWaitingHours: oldestWaitingHours ?? this.oldestWaitingHours,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }

  factory VendorDetail.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val, [DateTime? fallback]) {
      if (val is DateTime) return val;
      if (val is String) {
        final parsed = DateTime.tryParse(val);
        if (parsed != null) return parsed;
      }
      return fallback ?? DateTime.now();
    }

    List<String> parseStringList(dynamic val) {
      if (val is! List) return const [];
      return val
          .map((item) {
            if (item is String) return item;
            if (item is Map<String, dynamic>) {
              // origin/main sends raw join rows:
              // `{ categoryId, category: { nameEn, nameAr } }` /
              // `{ regionId, region: { nameEn, nameAr } }`.
              final nested = item['category'] ?? item['region'];
              if (nested is Map<String, dynamic>) {
                return nested['nameEn']?.toString() ??
                    nested['nameAr']?.toString() ??
                    '';
              }
              return item['nameEn']?.toString() ?? item['name']?.toString() ?? '';
            }
            return '';
          })
          .where((s) => s.isNotEmpty)
          .toList();
    }

    List<VendorDocumentDetail> parseDocs(dynamic val) {
      if (val is! List) return const [];
      return val.whereType<Map<String, dynamic>>().map((doc) {
        final media = doc['media'] is Map<String, dynamic>
            ? doc['media'] as Map<String, dynamic>
            : null;
        return VendorDocumentDetail(
          id: doc['id']?.toString() ?? '',
          documentType: doc['documentType']?.toString() ?? '',
          uploadedAt: parseDate(doc['uploadedAt']),
          fileName: media?['fileName']?.toString() ??
              media?['originalFileName']?.toString() ??
              doc['fileName']?.toString(),
          mimeType: media?['mimeType']?.toString() ??
              media?['contentType']?.toString() ??
              doc['mimeType']?.toString(),
          sizeBytes: (media?['sizeBytes'] as num?)?.toInt() ??
              (media?['byteSize'] as num?)?.toInt() ??
              (doc['sizeBytes'] as num?)?.toInt(),
          expiryDate:
              doc['expiryDate'] != null ? parseDate(doc['expiryDate']) : null,
          verified: doc['verified'] == true,
        );
      }).toList();
    }

    final user = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : null;

    final verificationStateStr = json['verificationState']?.toString();
    final accountStateStr =
        user?['accountState']?.toString() ?? json['accountState']?.toString();

    return VendorDetail(
      id: json['id']?.toString() ?? '',
      legalBusinessName: json['legalBusinessName']?.toString() ?? '',
      tradingName: json['tradingName']?.toString(),
      tradeLicenceNumber: json['tradeLicenceNumber']?.toString() ?? '',
      licenceExpiryDate: parseDate(json['licenceExpiryDate']),
      businessAddress: json['businessAddress']?.toString() ?? '',
      contactPersonName: json['contactPersonName']?.toString() ?? '',
      businessEmail:
          json['businessEmail']?.toString() ?? user?['email']?.toString() ?? '',
      mobileNumber:
          json['mobileNumber']?.toString() ?? user?['mobileNumber']?.toString(),
      verificationState:
          VendorVerificationState.fromApi(verificationStateStr) ??
              VendorVerificationState.registered,
      accountState: VendorAccountState.fromApi(accountStateStr) ??
          VendorAccountState.active,
      categories: parseStringList(json['categories']),
      regions: parseStringList(json['regions']),
      documents: parseDocs(json['documents']),
      oldestWaitingHours: (json['oldestWaitingHours'] as num?)?.toDouble(),
      // origin/main's detail route sends neither `submittedAt` nor
      // `oldestWaitingHours`; fall back to `createdAt` for the registration date.
      submittedAt: json['submittedAt'] != null
          ? parseDate(json['submittedAt'])
          : (json['createdAt'] != null ? parseDate(json['createdAt']) : null),
    );
  }
}
