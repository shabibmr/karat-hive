import 'package:karat_hive/app/session/session_controller.dart';
import 'package:kh_domain/kh_domain.dart';

VendorMe testVendorMe({
  VendorLifecycle lifecycle = VendorLifecycle.pendingVerification,
  List<String> categoryIds = const [],
  List<String> regionIds = const [],
  bool awayMode = false,
  AwaitingApprovalReason? awaitingApprovalReason =
      AwaitingApprovalReason.pendingDocuments,
  String? verificationMessage = 'Please re-upload the trade licence.',
}) {
  return VendorMe(
    vendorProfileId: 'vp1',
    lifecycle: lifecycle,
    awaitingApproval: lifecycle != VendorLifecycle.active,
    tradingName: 'Al Noor',
    legalBusinessName: 'Al Noor LLC',
    categoryCount: categoryIds.length,
    regionCount: regionIds.length,
    categoryIds: categoryIds,
    regionIds: regionIds,
    awayMode: awayMode,
    awaitingApprovalReason: awaitingApprovalReason,
    verificationMessage: verificationMessage,
  );
}

MeUser testVendorUser({VendorMe? vendor}) {
  return MeUser(
    userId: 'u1',
    userType: 'VENDOR',
    mobileNumber: '+971500000001',
    preferredLanguage: 'en',
    vendor: vendor ?? testVendorMe(),
  );
}

/// Avoids Firebase in widget/controller tests. Do not call [signOut] unless
/// the test is prepared for the Firebase Auth path.
class FakeSessionController extends SessionController {
  FakeSessionController(this._initial);
  final SessionState _initial;

  @override
  SessionState build() => _initial;

  @override
  Future<void> refreshUser() async {}
}
