import 'vendor_lifecycle.dart';

class VendorMe {
  const VendorMe({
    required this.vendorProfileId,
    required this.lifecycle,
    required this.awaitingApproval,
    required this.tradingName,
    required this.legalBusinessName,
    required this.categoryCount,
    required this.regionCount,
    this.awaitingApprovalReason,
    this.verificationMessage,
  });

  final String vendorProfileId;
  final VendorLifecycle lifecycle;
  final bool awaitingApproval;
  final String tradingName;
  final String legalBusinessName;
  final int categoryCount;
  final int regionCount;
  final AwaitingApprovalReason? awaitingApprovalReason;
  final String? verificationMessage;

  static VendorMe fromJson(Map<String, dynamic> j) => VendorMe(
        vendorProfileId: j['vendorProfileId'] as String,
        lifecycle: VendorLifecycle.parse(j['lifecycle'] as String?),
        awaitingApproval: j['awaitingApproval'] as bool? ?? true,
        tradingName: j['tradingName'] as String? ?? '',
        legalBusinessName: j['legalBusinessName'] as String? ?? '',
        categoryCount: j['categoryCount'] as int? ?? 0,
        regionCount: j['regionCount'] as int? ?? 0,
        awaitingApprovalReason:
            AwaitingApprovalReason.parse(j['awaitingApprovalReason'] as String?),
        verificationMessage: j['verificationMessage'] as String?,
      );
}

class MeUser {
  const MeUser({
    required this.userId,
    required this.userType,
    required this.mobileNumber,
    required this.preferredLanguage,
    this.email,
    this.vendor,
  });

  final String userId;
  final String userType;
  final String mobileNumber;
  final String preferredLanguage;
  final String? email;
  final VendorMe? vendor;

  static MeUser fromJson(Map<String, dynamic> j) => MeUser(
        userId: j['userId'] as String,
        userType: j['userType'] as String,
        mobileNumber: j['mobileNumber'] as String? ?? '',
        preferredLanguage: j['preferredLanguage'] as String? ?? 'en',
        email: j['email'] as String?,
        vendor: j['vendor'] == null
            ? null
            : VendorMe.fromJson(j['vendor'] as Map<String, dynamic>),
      );
}
