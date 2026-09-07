// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Karat Hive Admin Portal';

  @override
  String get loginTitle => 'PLATFORM ADMIN';

  @override
  String get loginSubtitle => 'Karat Hive Internal Management Portal';

  @override
  String get loginInstructions =>
      'Please sign in with your administrative credentials.';

  @override
  String get emailLabel => 'Admin Email';

  @override
  String get emailHint => 'admin@karathive.ae';

  @override
  String get emailRequired => 'Admin email is required';

  @override
  String get emailInvalid => 'Please enter a valid email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get signInButton => 'Authenticate & Enter Portal';

  @override
  String get signingIn => 'Authenticating...';

  @override
  String get errorAccountLocked =>
      'Your administrative account has been temporarily locked due to consecutive failed login attempts. Please wait 30 minutes or contact security.';

  @override
  String get errorInvalidCredentials =>
      'Invalid administrative credentials. Please check your email and password.';

  @override
  String get errorServerUnavailable =>
      'Administrative service unavailable. Please check your connection and try again.';

  @override
  String get errorUnknown => 'An unexpected error occurred. Please try again.';

  @override
  String get dashboardEyebrow => 'Platform Overview';

  @override
  String get dashboardHeading => 'Admin Control Center';

  @override
  String get systemOperational => 'SYSTEM OPERATIONAL';

  @override
  String get dashboardSampleDataNotice =>
      'Indicative sample figures. The admin dashboard endpoint (GET /v1/admin/dashboard) is not implemented yet — no number below reflects live platform data.';

  @override
  String get quickActionQueues => 'Quick Action Queues';

  @override
  String get queueColumnItem => 'Queue Item';

  @override
  String get queueColumnType => 'Type';

  @override
  String get queueColumnSubmitted => 'Submitted';

  @override
  String get queueColumnStatus => 'Status';

  @override
  String get queueColumnAction => 'Action';

  @override
  String get categoriesEyebrow => 'Taxonomy Config';

  @override
  String get categoriesTitle => 'Product Categories';

  @override
  String get categoriesSubtitle =>
      'Manage two-level product category taxonomy for requests and vendor specialisations.';

  @override
  String get regionsEyebrow => 'Geographic Taxonomy';

  @override
  String get regionsTitle => 'UAE Regions & Souk Zones';

  @override
  String get regionsSubtitle =>
      'Manage geographic matching taxonomy (emirates and areas) for marketplace routing.';

  @override
  String get showInactive => 'Show Inactive';

  @override
  String get hideInactive => 'Hide Inactive';

  @override
  String get addRootCategory => '+ Add Category';

  @override
  String get addRootRegion => '+ Add Region';

  @override
  String get addChildCategory => 'Add Subcategory';

  @override
  String get addChildRegion => 'Add Area';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get editRegion => 'Edit Region';

  @override
  String get createRootCategory => 'New Root Category';

  @override
  String get createRootRegion => 'New Root Region';

  @override
  String get newChildCategory => 'New Subcategory';

  @override
  String get newChildRegion => 'New Area';

  @override
  String get nameEnLabel => 'Name (English)';

  @override
  String get nameArLabel => 'Name (Arabic)';

  @override
  String get nameEnRequired => 'English name is required and cannot be blank';

  @override
  String get nameArRequired => 'Arabic name is required and cannot be blank';

  @override
  String get iconLabel => 'Icon';

  @override
  String get displayOrderLabel => 'Display Order';

  @override
  String get activeStatusLabel => 'Active Status';

  @override
  String get activeStatusDescription =>
      'Inactive nodes are hidden from customer/vendor selection but preserve existing associations.';

  @override
  String get saveButton => 'Save Changes';

  @override
  String get createButton => 'Create';

  @override
  String get deactivateButton => 'Deactivate';

  @override
  String deactivateConfirmTitle(String name) {
    return 'Deactivate $name?';
  }

  @override
  String deactivateConfirmBody(String name) {
    return 'Are you sure you want to deactivate \"$name\"? Inactive nodes cannot be selected for new requests, but existing associations are preserved. This action can be reversed later.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmDeactivate => 'Deactivate';

  @override
  String get statusActive => 'Active';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get emptyCategoriesTitle => 'No Categories Found';

  @override
  String get emptyCategoriesBody =>
      'No product categories have been configured yet. Create a root category to start building the taxonomy.';

  @override
  String get emptyRegionsTitle => 'No Regions Found';

  @override
  String get emptyRegionsBody =>
      'No regions have been configured yet. Create a root emirate or region to begin.';

  @override
  String get toastCategoryCreated => 'Category created successfully.';

  @override
  String get toastCategoryUpdated => 'Category updated successfully.';

  @override
  String get toastCategoryDeactivated => 'Category deactivated successfully.';

  @override
  String get toastRegionCreated => 'Region created successfully.';

  @override
  String get toastRegionUpdated => 'Region updated successfully.';

  @override
  String get toastRegionDeactivated => 'Region deactivated successfully.';

  @override
  String get levelLimitReached =>
      'Maximum hierarchy depth reached (2 levels). Cannot add children to this node.';

  @override
  String get selectNodeToEdit =>
      'Select a node from the tree to edit or create a child, or create a new root node.';

  @override
  String get vendorsEyebrow => 'Vendor Management';

  @override
  String get vendorsTitle => 'Vendor List';

  @override
  String get vendorsSubtitle =>
      'Browse and search vendors by verification and account state.';

  @override
  String get vendorsFilterVerification => 'Verification state';

  @override
  String get vendorsFilterAccount => 'Account state';

  @override
  String get vendorsFilterSearch => 'Search';

  @override
  String get vendorsFilterSearchHint => 'Business name, licence, mobile…';

  @override
  String get vendorsFilterAll => 'All';

  @override
  String get vendorsColumnBusiness => 'Business name';

  @override
  String get vendorsColumnTrading => 'Trading name';

  @override
  String get vendorsColumnVerification => 'Verification';

  @override
  String get vendorsColumnAccount => 'Account';

  @override
  String get vendorsColumnWaiting => 'Waiting';

  @override
  String get vendorsColumnAction => 'Action';

  @override
  String get vendorsActionView => 'View';

  @override
  String get vendorsActionReviewKyc => 'Review KYC';

  @override
  String get vendorsEmptyTitle => 'No vendors found';

  @override
  String get vendorsEmptyBody => 'No vendors match the current filters.';

  @override
  String get vendorsErrorTitle => 'Unable to load vendors';

  @override
  String get vendorsRetry => 'Try again';

  @override
  String get vendorsLoadMore => 'Load more';

  @override
  String get vendorsVerificationRegistered => 'REGISTERED';

  @override
  String get vendorsVerificationPending => 'PENDING VERIFICATION';

  @override
  String get vendorsVerificationVerified => 'VERIFIED';

  @override
  String get vendorsVerificationRejected => 'REJECTED';

  @override
  String get vendorsAccountActive => 'ACTIVE';

  @override
  String get vendorsAccountSuspended => 'SUSPENDED';

  @override
  String get vendorsAccountDeactivated => 'DEACTIVATED';

  @override
  String vendorsWaitingHours(int hours) {
    return '${hours}h waiting';
  }

  @override
  String get vendorsDetailEyebrow => 'Vendor Profile';

  @override
  String get vendorsDetailTitle => 'Vendor Detail';

  @override
  String get vendorsDetailStubBody =>
      'Full vendor inspection (ADM-S06) is scheduled for a later milestone.';

  @override
  String vendorsDetailVendorId(String id) {
    return 'Vendor ID: $id';
  }

  @override
  String get vendorsDetailComingSoon =>
      'Account actions and document review will appear here.';

  @override
  String get verificationEyebrow => 'Compliance Reviewer';

  @override
  String verificationHeading(int count) {
    return 'KYC Verification Queue ($count Pending)';
  }

  @override
  String get verificationHeadingLoading => 'KYC Verification Queue';

  @override
  String get verificationSubtitle =>
      'Review vendor KYC submissions oldest-first. Every document view and decision is audit-logged.';

  @override
  String get oldestFirstBadge => 'OLDEST FIRST';

  @override
  String get refresh => 'Refresh';

  @override
  String get verificationColumnBusiness => 'Business';

  @override
  String get verificationColumnLicence => 'Licence';

  @override
  String get verificationColumnWaiting => 'Waiting';

  @override
  String get verificationColumnStatus => 'Status';

  @override
  String get statusPendingVerification => 'PENDING';

  @override
  String get waitingLessThanHour => '< 1 hour';

  @override
  String waitingHours(int hours) {
    return '${hours}h waiting';
  }

  @override
  String waitingDays(int days) {
    return '${days}d waiting';
  }

  @override
  String get emptyVerificationTitle => 'Queue is Clear';

  @override
  String get emptyVerificationBody =>
      'No vendors are currently awaiting KYC verification.';

  @override
  String get verificationLoadErrorTitle => 'Failed to load verification queue';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get declaredBusinessProfile => 'Declared Business Profile';

  @override
  String get legalNameLabel => 'Legal Name';

  @override
  String get tradeLicenceLabel => 'Trade Licence';

  @override
  String get licenceExpiryLabel => 'Licence Expiry';

  @override
  String get emirateLabel => 'Emirate / Region';

  @override
  String get contactPersonLabel => 'Contact Person';

  @override
  String get businessAddressLabel => 'Registered Address';

  @override
  String get notDeclared => 'Not declared';

  @override
  String get adminRationaleLabel => 'Admin Review Rationale / Notes';

  @override
  String get adminRationaleHint =>
      'Enter reason for approval, rejection, or information request…';

  @override
  String get rationaleRequired =>
      'A rationale or message is required for every decision';

  @override
  String get documentInspectorTitle => 'Document Inspector';

  @override
  String get noDocumentsUploaded => 'No documents uploaded.';

  @override
  String get selectDocumentToView => 'Select a document to load the viewer.';

  @override
  String get openFullscreenViewer => 'Open Fullscreen Viewer';

  @override
  String documentSizeLabel(String sizeMb) {
    return '$sizeMb MB';
  }

  @override
  String get documentTypeTradeLicence => 'Trade licence';

  @override
  String get documentTypeEmiratesId => 'Emirates ID';

  @override
  String get documentTypeVatCert => 'VAT certificate';

  @override
  String get documentTypeTradingPermit => 'Trading permit';

  @override
  String get documentTypeTenancy => 'Tenancy contract';

  @override
  String get documentTypeOther => 'Other document';

  @override
  String get approveVendorButton => 'Approve Vendor & Activate Market Access';

  @override
  String get requestInfoButton => 'Request More Information';

  @override
  String get rejectVendorButton => 'Reject Application';

  @override
  String get approveConfirmTitle => 'Approve vendor application?';

  @override
  String get approveConfirmBody =>
      'This will mark the vendor as VERIFIED and may advance them to ACTIVE if categories and regions are already declared. The decision is audit-logged.';

  @override
  String get confirmApprove => 'Approve';

  @override
  String get rejectConfirmTitle => 'Reject vendor application?';

  @override
  String get rejectConfirmBody =>
      'The vendor will be notified with your rationale and may resubmit documents. This decision is audit-logged.';

  @override
  String get confirmReject => 'Reject';

  @override
  String get requestInfoConfirmTitle => 'Request more information?';

  @override
  String get requestInfoConfirmBody =>
      'The vendor will remain in the verification queue and see your message in their awaiting-approval shell.';

  @override
  String get confirmRequestInfo => 'Send Request';

  @override
  String get toastVendorApproved => 'Vendor approved successfully.';

  @override
  String get toastVendorRejected => 'Vendor application rejected.';

  @override
  String get toastInfoRequested => 'Information request sent to vendor.';
}
