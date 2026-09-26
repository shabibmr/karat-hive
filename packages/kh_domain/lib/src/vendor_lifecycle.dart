/// Composed Vendor marketplace state (mirrors backend `vendorLifecycle`).
enum VendorLifecycle {
  registered,
  pendingVerification,
  verified,
  active,
  suspended,
  rejected,
  deactivated,
  unknown;

  static VendorLifecycle parse(String? raw) => switch (raw) {
        'REGISTERED' => registered,
        'PENDING_VERIFICATION' => pendingVerification,
        'VERIFIED' => verified,
        'ACTIVE' => active,
        'SUSPENDED' => suspended,
        'REJECTED' => rejected,
        'DEACTIVATED' => deactivated,
        _ => unknown,
      };

  bool get isActive => this == active;
  bool get canLogin =>
      this == active || this == verified || this == pendingVerification || this == registered;
}

enum AwaitingApprovalReason {
  pendingDocuments,
  pendingAdmin,
  activationPending,
  rejected,
  unknown;

  static AwaitingApprovalReason parse(String? raw) => switch (raw) {
        'PENDING_DOCUMENTS' => pendingDocuments,
        'PENDING_ADMIN' => pendingAdmin,
        'ACTIVATION_PENDING' => activationPending,
        'REJECTED' => rejected,
        _ => unknown,
      };
}
