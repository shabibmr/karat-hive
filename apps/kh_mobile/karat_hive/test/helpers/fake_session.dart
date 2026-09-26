import 'package:karat_hive/app/session/session_controller.dart';
import 'package:kh_domain/kh_domain.dart';

VendorMe testVendorMe({
  VendorLifecycle lifecycle = VendorLifecycle.pendingVerification,
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
    regionCount: regionIds.length,
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

CustomerMe testCustomerMe({
  String displayName = 'Amina',
  int reviewCount = 0,
  int connectionCount = 0,
}) {
  return CustomerMe(
    displayName: displayName,
    reviewCount: reviewCount,
    connectionCount: connectionCount,
  );
}

MeUser testCustomerUser({CustomerMe? customer}) {
  return MeUser(
    userId: 'u2',
    userType: 'CUSTOMER',
    mobileNumber: '+971500000002',
    preferredLanguage: 'en',
    customer: customer ?? testCustomerMe(),
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
