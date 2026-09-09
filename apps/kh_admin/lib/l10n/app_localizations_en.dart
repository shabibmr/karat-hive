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
      'Live platform figures from GET /v1/admin/dashboard. Queue rows snapshot verification, abuse reports, and pending reviews. Settlement is off-platform; GMV is not shown.';

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
  String get dashboardRangeLabel => 'Date range';

  @override
  String get dashboardRange7 => 'Last 7 days';

  @override
  String get dashboardRange30 => 'Last 30 days';

  @override
  String get dashboardRange90 => 'Last 90 days';

  @override
  String get dashboardTrendsHeading => 'Trends';

  @override
  String get dashboardTrendCaption =>
      'Request volume by state over the selected range.';

  @override
  String get dashboardTrendEmpty => 'No trend data for this range.';

  @override
  String get dashboardQueueRetry => 'Retry';

  @override
  String get queueSourceVerification => 'verification queue';

  @override
  String get queueSourceAbuse => 'abuse reports';

  @override
  String get queueSourceReview => 'pending reviews';

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
  String vendorsDetailVendorId(String id) {
    return 'Vendor ID: $id';
  }

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

  @override
  String get offersListEyebrow => 'Marketplace Audit';

  @override
  String get offersListHeading => 'Offers';

  @override
  String get offersListSubtitle =>
      'Platform-wide vendor offer monitoring and inspection';

  @override
  String get offersFilterState => 'Offer state';

  @override
  String get offersFilterAllStates => 'All States';

  @override
  String get offersFilterRequestType => 'Request type';

  @override
  String get offersFilterAllTypes => 'All Types';

  @override
  String get offersFilterSearch => 'Search';

  @override
  String get offersFilterSearchHint => 'Offer ID, vendor name, request ref…';

  @override
  String get offersFilterSearchTooltip => 'Search offers';

  @override
  String get offersColumnReference => 'Offer Reference/ID';

  @override
  String get offersColumnParentRequest => 'Parent Request';

  @override
  String get offersColumnVendor => 'Vendor Name';

  @override
  String get offersColumnOfferedPrice => 'Offered Price (AED)';

  @override
  String get offersColumnState => 'State';

  @override
  String get offersColumnSubmissionDate => 'Submission Date';

  @override
  String get offersColumnExpiryDate => 'Expiry Date';

  @override
  String get offersColumnOutcome => 'Outcome';

  @override
  String get offersColumnAction => 'Action';

  @override
  String get offersOutcomeAcceptedByCustomer => 'Accepted by Customer';

  @override
  String get offersOutcomeRejected => 'Rejected';

  @override
  String get offersOutcomeExpired => 'Expired';

  @override
  String get offersOutcomePending => 'Pending';

  @override
  String get offersActionInspect => 'Inspect';

  @override
  String offersPaginationShowing(int count) {
    return 'Showing $count offers';
  }

  @override
  String offersPaginationShowingOf(int count, int total) {
    return 'Showing $count offers of $total';
  }

  @override
  String get offersPaginationPrevious => 'Previous';

  @override
  String offersPaginationPage(int page) {
    return 'Page $page';
  }

  @override
  String get offersPaginationNext => 'Next';

  @override
  String get offersEmptyTitle => 'No offers found';

  @override
  String get offersEmptyBody => 'No offers match the current filter criteria.';

  @override
  String get offersErrorTitle => 'Failed to load offers';

  @override
  String get offersRetry => 'Retry';

  @override
  String get offersDetailBack => 'Back to Offers';

  @override
  String offersDetailEyebrow(String reference) {
    return 'OFFER $reference';
  }

  @override
  String offersDetailHeaderMeta(String date, int hours) {
    return 'Submitted on $date · Validity ${hours}h';
  }

  @override
  String offersDetailHeaderMetaExpires(String date, int hours, String expiry) {
    return 'Submitted on $date · Validity ${hours}h (Expires $expiry)';
  }

  @override
  String get offersDetailCompetingWonTitle =>
      'COMPETING OFFER WON THIS REQUEST';

  @override
  String offersDetailCompetingWonBody(
    String reference,
    String vendorPart,
    String pricePart,
  ) {
    return 'Customer selected winning offer $reference$vendorPart$pricePart.';
  }

  @override
  String offersDetailCompetingWonBy(String vendor) {
    return ' by $vendor';
  }

  @override
  String offersDetailCompetingWonFor(String price) {
    return ' for $price';
  }

  @override
  String get offersDetailInspectWinning => 'Inspect Winning Offer';

  @override
  String get offersDetailVendorProfileTitle => 'Unmasked Vendor Profile';

  @override
  String get offersDetailViewVendor => 'View Vendor';

  @override
  String get offersDetailNoVendor => 'No vendor details provided.';

  @override
  String get offersDetailLabelLegalName => 'Legal Business Name';

  @override
  String get offersDetailLabelTradingName => 'Trading Name';

  @override
  String get offersDetailLabelTradeLicence => 'Trade Licence';

  @override
  String get offersDetailLabelContactMobile => 'Contact Person & Mobile';

  @override
  String get offersDetailLabelBusinessEmail => 'Business Email';

  @override
  String get offersDetailLabelVendorRating => 'Vendor Rating';

  @override
  String offersDetailDealsSuffix(int deals) {
    return ' ($deals deals completed)';
  }

  @override
  String get offersDetailParentRequestTitle => 'Parent Request Reference';

  @override
  String get offersDetailOpenRequest => 'Open Request';

  @override
  String get offersDetailNoParentRequest => 'No parent request linked.';

  @override
  String get offersDetailLabelRequestReference => 'Request Reference';

  @override
  String get offersDetailLabelRequestType => 'Request Type';

  @override
  String get offersDetailLabelCustomerMobile => 'Customer Name & Mobile';

  @override
  String get offersDetailLabelCategory => 'Category';

  @override
  String get offersDetailLabelRegion => 'Region';

  @override
  String get offersDetailLabelIndicativeBudget => 'Indicative Budget';

  @override
  String get offersDetailLabelRequestNotes => 'Request Notes';

  @override
  String get offersDetailPricingTitle => 'Pricing Breakdown';

  @override
  String get offersDetailPricingGoldValue => 'Gold Metal Value';

  @override
  String offersDetailPricingGoldHintRate(String rate) {
    return 'Base gold price ($rate/g)';
  }

  @override
  String get offersDetailPricingGoldHint => 'Base gold price component';

  @override
  String get offersDetailPricingMaking => 'Making / Crafting Charges';

  @override
  String get offersDetailPricingMakingHint => 'Labour and artistry charges';

  @override
  String get offersDetailPricingVat => 'Value Added Tax (VAT 5%)';

  @override
  String get offersDetailPricingVatHint => 'UAE statutory tax';

  @override
  String get offersDetailPricingTotal => 'Total Offered Price';

  @override
  String get offersDetailTermsTitle => 'Commercial Terms, Notes & Attachments';

  @override
  String get offersDetailLabelDelivery => 'Delivery / Readiness Timeframe';

  @override
  String get offersDetailDeliveryDefault => 'Immediate dispatch / collection';

  @override
  String get offersDetailLabelWarranty => 'Warranty / Buy-Back Terms';

  @override
  String get offersDetailWarrantyDefault => 'Standard UAE jeweller guarantee';

  @override
  String get offersDetailLabelVendorNote => 'Vendor Note';

  @override
  String get offersDetailVendorNoteDefault =>
      'No free-text note provided by vendor.';

  @override
  String get offersDetailLabelValidityExpiry => 'Offer Validity & Expiry';

  @override
  String offersDetailValidityExpiryValue(int hours, String date) {
    return '$hours hours · Expiry: $date';
  }

  @override
  String get offersDetailLabelDeclineReason => 'Decline Reason';

  @override
  String offersDetailAttachmentsCount(int count) {
    return 'Attachments & Certificates ($count)';
  }

  @override
  String get offersDetailNoAttachments =>
      'No media files or certificates attached by vendor.';

  @override
  String get offersDetailRevisionsTitle => 'Revisions History (FR-VEN-014)';

  @override
  String offersDetailRevisionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count revisions',
      one: '1 revision',
    );
    return '$_temp0';
  }

  @override
  String get offersDetailNoRevisions =>
      'Initial offer terms. No modifications were made pre-acceptance.';

  @override
  String offersDetailRevisionNumber(int number) {
    return 'Rev #$number';
  }

  @override
  String offersDetailRevisionOffered(String price) {
    return 'Offered: $price';
  }

  @override
  String offersDetailRevisionMakingSuffix(String making) {
    return ' (Making: $making)';
  }

  @override
  String offersDetailRevisionNote(String note) {
    return 'Note: $note';
  }

  @override
  String get offersDetailTransitionsTitle => 'State Transitions Timeline';

  @override
  String offersDetailNoTransitions(String state) {
    return 'Offer is in $state state. No state transition audit recorded.';
  }

  @override
  String offersDetailTransitionActor(String actor) {
    return 'By: $actor';
  }

  @override
  String offersDetailTransitionReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get offersDetailNotesTitle => 'Internal Administrative Notes';

  @override
  String get offersDetailNotesSubtitle =>
      'Admin inspection notes are internal to Karat Hive. Commercial terms are read-only.';

  @override
  String get offersDetailNotesHint => 'Add an internal note about this offer…';

  @override
  String get offersDetailAddNote => 'Add Note';

  @override
  String get offersDetailNoNotes => 'No internal notes added yet.';

  @override
  String get offersDetailErrorTitle => 'Failed to load offer details';

  @override
  String get requestsListEyebrow => 'Marketplace Audit';

  @override
  String get requestsListHeading => 'Requests';

  @override
  String get requestsListSubtitle =>
      'Platform requests oversight and inspection';

  @override
  String get requestsFilterType => 'Request Type';

  @override
  String get requestsFilterAllTypes => 'All Types';

  @override
  String get requestsFilterDirection => 'Direction';

  @override
  String get requestsFilterAllDirections => 'All Directions';

  @override
  String get requestsFilterStatus => 'Status';

  @override
  String get requestsFilterAllStates => 'All States';

  @override
  String get requestsFilterSearch => 'Search';

  @override
  String get requestsFilterSearchHint => 'Reference, notes, customer…';

  @override
  String get requestsFilterSearchTooltip => 'Search';

  @override
  String get requestsFilterZeroOffers => 'Zero Offers';

  @override
  String get requestsColumnReference => 'Reference';

  @override
  String get requestsColumnType => 'Type';

  @override
  String get requestsColumnDirection => 'Direction';

  @override
  String get requestsColumnCustomer => 'Customer';

  @override
  String get requestsColumnCategory => 'Category';

  @override
  String get requestsColumnRegion => 'Region';

  @override
  String get requestsColumnIndicativeValue => 'Indicative Value';

  @override
  String get requestsColumnOffers => 'Offers';

  @override
  String get requestsColumnState => 'State';

  @override
  String get requestsColumnDate => 'Date';

  @override
  String get requestsColumnAction => 'Action';

  @override
  String get requestsActionInspect => 'Inspect';

  @override
  String get requestsLoadMore => 'Load more';

  @override
  String get requestsPaginationPrevious => 'Previous';

  @override
  String requestsPaginationPage(int page) {
    return 'Page $page';
  }

  @override
  String get requestsPaginationNext => 'Next';

  @override
  String get requestsEmptyBody => 'No requests match the current filters.';

  @override
  String get requestsRetry => 'Retry';

  @override
  String get requestsDetailBack => 'Back to Requests';

  @override
  String get requestsDetailEyebrow => 'Request Oversight';

  @override
  String get requestsDetailNoReference => 'NO REFERENCE';

  @override
  String requestsDetailPublishedAt(String date) {
    return 'Published $date GST';
  }

  @override
  String requestsDetailCreatedAt(String date) {
    return 'Created $date GST';
  }

  @override
  String get requestsDetailNoteAdded => 'Note added successfully.';

  @override
  String requestsDetailNoteAddFailed(String error) {
    return 'Failed to add note: $error';
  }

  @override
  String get requestsDetailRemoveSuccess => 'Request successfully removed.';

  @override
  String requestsDetailRemoveFailed(String error) {
    return 'Failed to remove request: $error';
  }

  @override
  String get requestsDetailRemovedTitle =>
      'REQUEST REMOVED BY PLATFORM MODERATION (FR-ADM-019)';

  @override
  String requestsDetailRemovedReason(String code, String text) {
    return 'Reason: $code · $text';
  }

  @override
  String get requestsDetailRemovedReasonCodeDefault => 'POLICY_VIOLATION';

  @override
  String get requestsDetailRemovedReasonTextDefault =>
      'Violates platform trading guidelines';

  @override
  String requestsDetailRemovedPolicyClause(String clause) {
    return 'Policy clause cited: $clause';
  }

  @override
  String get requestsDetailConnectionTitle => 'ACTIVE CONNECTION ESTABLISHED';

  @override
  String requestsDetailConnectionParties(String vendor, String customer) {
    return 'Accepted Vendor: $vendor · Customer: $customer';
  }

  @override
  String requestsDetailConnectionMeta(String date, String channel) {
    return 'Connected at: $date GST · Channel: $channel';
  }

  @override
  String get requestsDetailConnectionChannelDefault => 'WHATSAPP';

  @override
  String get requestsDetailWhatsappChannel => 'WhatsApp Channel';

  @override
  String get requestsDetailSpecsTitle =>
      'Commercial Requirements & Specifications';

  @override
  String get requestsDetailSpecsReadOnly =>
      'READ-ONLY FOR ADMIN (FR-ADM-018 AC3)';

  @override
  String get requestsDetailLabelReferenceCode => 'Reference Code';

  @override
  String get requestsDetailLabelRequestType => 'Request Type';

  @override
  String get requestsDetailLabelMarketDirection => 'Market Direction';

  @override
  String get requestsDetailLabelCategory => 'Category';

  @override
  String get requestsDetailLabelRegion => 'Region';

  @override
  String get requestsDetailLabelOrnamentType => 'Ornament Type';

  @override
  String get requestsDetailLabelPurityKarat => 'Purity / Karat';

  @override
  String get requestsDetailLabelWeight => 'Weight';

  @override
  String get requestsDetailLabelCondition => 'Condition';

  @override
  String get requestsDetailLabelDenomination => 'Denomination';

  @override
  String get requestsDetailLabelQuantity => 'Quantity';

  @override
  String get requestsDetailLabelMintRefiner => 'Mint / Refiner';

  @override
  String get requestsDetailLabelIndicativeValue => 'Indicative Value';

  @override
  String get requestsDetailLabelCustomerBudget => 'Customer Budget';

  @override
  String requestsDetailWeightApproximate(String weight) {
    return '${weight}g (Approximate)';
  }

  @override
  String requestsDetailWeightExact(String weight) {
    return '${weight}g (Exact)';
  }

  @override
  String requestsDetailQuantityUnits(int quantity) {
    return '$quantity units';
  }

  @override
  String requestsDetailBudgetValue(String min, String max) {
    return 'AED $min – $max';
  }

  @override
  String requestsDetailBudgetValueFlexible(String min, String max) {
    return 'AED $min – $max (Flexible)';
  }

  @override
  String get requestsDetailCustomerNotes => 'Customer Notes:';

  @override
  String get requestsDetailCustomerProfileTitle => 'Unmasked Customer Profile';

  @override
  String requestsDetailCustomerId(String id) {
    return 'Customer ID: $id';
  }

  @override
  String get requestsDetailLabelMobilePhone => 'Mobile Phone';

  @override
  String get requestsDetailLabelEmailAddress => 'Email Address';

  @override
  String get requestsDetailLabelMemberSince => 'Member Since';

  @override
  String requestsDetailMediaTitle(int count) {
    return 'Uploaded Media ($count)';
  }

  @override
  String get requestsDetailNoMedia => 'No media uploaded for this request.';

  @override
  String requestsDetailImageNumber(int number) {
    return 'Image #$number';
  }

  @override
  String requestsDetailOffersTitle(int count) {
    return 'Received Offers ($count)';
  }

  @override
  String get requestsDetailNoOffers => 'No offers submitted yet.';

  @override
  String get requestsDetailOffersColumnVendor => 'Vendor';

  @override
  String get requestsDetailOffersColumnPrice => 'Offered Price';

  @override
  String get requestsDetailOffersColumnStatus => 'Status';

  @override
  String get requestsDetailOffersColumnSubmitted => 'Submitted';

  @override
  String get requestsDetailOffersColumnTurnaround => 'Turnaround';

  @override
  String requestsDetailOfferDays(int days) {
    return '$days days';
  }

  @override
  String requestsDetailMatchedTitle(int count) {
    return 'Matched Vendors ($count)';
  }

  @override
  String get requestsDetailNoMatched => 'No vendors matched to this request.';

  @override
  String requestsDetailMatchedAt(String date) {
    return 'Matched: $date';
  }

  @override
  String get requestsDetailViewed => 'VIEWED';

  @override
  String get requestsDetailNotViewed => 'NOT VIEWED';

  @override
  String get requestsDetailTimelineTitle => 'State Transition History';

  @override
  String get requestsDetailNoTransitions => 'No recorded transitions.';

  @override
  String requestsDetailTimelineBy(String actor) {
    return 'by $actor';
  }

  @override
  String get requestsDetailModerationTitle => 'Platform Moderation';

  @override
  String get requestsDetailModerationBody =>
      'Administrators can forcibly remove requests that violate platform trading policies (FR-ADM-019).';

  @override
  String get requestsDetailAlreadyRemoved => 'Request Already Removed';

  @override
  String get requestsDetailRemoveRequest => 'Remove Request';

  @override
  String requestsDetailNotesTitle(int count) {
    return 'Admin Internal Notes ($count)';
  }

  @override
  String get requestsDetailNoNotes => 'No internal notes recorded.';

  @override
  String get requestsDetailAddNoteLabel => 'Add Internal Note';

  @override
  String get requestsDetailAddNoteHint => 'Record audit or compliance notes…';

  @override
  String get requestsDetailAddNote => 'Add Note';

  @override
  String get requestsDetailRemoveDialogTitle => 'Remove Request';

  @override
  String requestsDetailRemoveDialogBody(String reference) {
    return 'Removing \"$reference\" sets status to REMOVED, withdraws all pending offers, and notifies both parties.';
  }

  @override
  String get requestsDetailRemoveReasonCode => 'Reason Code';

  @override
  String get requestsDetailRemoveReasonPolicyViolation => 'Policy violation';

  @override
  String get requestsDetailRemoveReasonProhibitedItem =>
      'Prohibited item / Contraband';

  @override
  String get requestsDetailRemoveReasonFraudulent =>
      'Fraudulent or misleading listing';

  @override
  String get requestsDetailRemoveReasonCustomerRequested =>
      'Customer requested cancellation';

  @override
  String get requestsDetailRemoveReasonOther => 'Other administrative reason';

  @override
  String get requestsDetailRemovePolicyClauseLabel =>
      'Policy Clause (cited to customer)';

  @override
  String get requestsDetailRemovePolicyClauseHint =>
      'e.g. Terms of Service §4.2';

  @override
  String get requestsDetailRemoveJustificationLabel =>
      'Detailed Justification & Notes';

  @override
  String get requestsDetailRemoveJustificationHint =>
      'State reason for audit log…';

  @override
  String get requestsDetailRemoveJustificationRequired =>
      'Detailed justification is required.';

  @override
  String get requestsDetailConfirmRemoval => 'Confirm Removal';

  @override
  String get requestsDetailErrorRetry => 'Retry';

  @override
  String get reportsEyebrow => 'BUSINESS INTELLIGENCE';

  @override
  String get reportsHeading => 'Platform Analytics & Reports';

  @override
  String get reportsSubtitle =>
      'Operational reports over a date range, filtered by Region and Category.';

  @override
  String get reportsIndicativeNote =>
      'Figures are indicative operational metrics, not settlement or GMV. Settlement happens off-platform. Units: AED, grams, karat/fineness. Timestamps display as Gulf Standard Time.';

  @override
  String get reportsTypeLabel => 'Report type';

  @override
  String get reportsTypeAcquisition => 'Customer acquisition & retention';

  @override
  String get reportsTypeVendorLeague => 'Vendor performance league';

  @override
  String get reportsTypeRequestVolume => 'Request volume';

  @override
  String get reportsTypeOfferCompetitiveness => 'Offer competitiveness';

  @override
  String get reportsTypeFunnel => 'Funnel conversion';

  @override
  String get reportsTypeLiquidityGaps => 'Liquidity gaps';

  @override
  String get reportsTypeRatingDistribution => 'Rating distribution';

  @override
  String get reportsFrom => 'From (YYYY-MM-DD)';

  @override
  String get reportsTo => 'To (YYYY-MM-DD)';

  @override
  String get reportsRegionId => 'Region ID (optional)';

  @override
  String get reportsCategoryId => 'Category ID (optional)';

  @override
  String get reportsApply => 'Apply';

  @override
  String get reportsEmptyPeriod =>
      'No rows for this period. Try a different date range, Region, or Category.';

  @override
  String get reportsEmptyChart => 'No chart data for this period.';

  @override
  String get reportsRetry => 'Retry';

  @override
  String get reportsExportCsv => 'Export CSV';

  @override
  String get reportsExportXlsx => 'Export XLSX';

  @override
  String get reportsExportPng => 'Export chart PNG';

  @override
  String get reportsExportPurposeTitle => 'Export purpose';

  @override
  String get reportsExportPurposeHint =>
      'Required for the audit watermark (admin, timestamp, purpose).';

  @override
  String get reportsExportPurposeLabel => 'Purpose';

  @override
  String get reportsExportPurposeRequired => 'Purpose is required.';

  @override
  String get reportsExportConfirm => 'Start export';

  @override
  String get reportsExportCancel => 'Cancel';

  @override
  String get reportsExportAsyncNotice =>
      'Exports over 50,000 rows are generated asynchronously and delivered as a time-limited download link. Personal-data exports are watermarked with admin, time, and purpose (NFR-016).';
}
