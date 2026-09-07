// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get filterRequests => 'Filter Requests';

  @override
  String get resetAll => 'Reset All';

  @override
  String get includeAlreadyResponded => 'Include already responded requests';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get sortBy => 'Sort By';

  @override
  String get requestType => 'Request Type';

  @override
  String get filterPresets => 'Filter Presets';

  @override
  String get noSavedPresetsYet => 'No saved presets yet.';

  @override
  String get saveCurrentFiltersAsPreset => 'Save current filters as preset';

  @override
  String get subscriptionsTitle => 'Subscriptions & Entitlements';

  @override
  String get subscriptionsRequirementBanner =>
      'Each request category requires an active type subscription to receive matches and submit offers (BR-002).';

  @override
  String get categoryEntitlements => 'Category Entitlements';

  @override
  String get manageSubscriptionsContact =>
      'Manage Subscriptions / Contact Support';

  @override
  String get subscriptionChangesHandled =>
      'Subscription changes are handled by Karat Hive account management.';

  @override
  String get noActiveSubscription =>
      'No active subscription. You will not receive matches for this category.';

  @override
  String couldNotOpenUrl(String url) {
    return 'Could not open $url';
  }

  @override
  String get availableRequestsTitle => 'Available Requests';

  @override
  String get failedToLoadMatchingRequests =>
      'Failed to load matching requests.';

  @override
  String get noMatchingRequests => 'No Matching Requests';

  @override
  String get emptyFeedResetFiltersHint =>
      'Try resetting your active filters to see more requests.';

  @override
  String get emptyFeedBroadenHint =>
      'Broaden your Categories and Regions, or check that you have an active Type Subscription for the request types you want to see.';

  @override
  String get resetFilters => 'Reset Filters';

  @override
  String get viewSubscriptions => 'View Subscriptions';

  @override
  String get allCaughtUp => 'You are all caught up';

  @override
  String requestTitleWithId(String requestId) {
    return 'Request $requestId';
  }

  @override
  String get couldNotLoadRequestDetails => 'Could not load request details.';

  @override
  String get requestDetailsFallback => 'Request Details';

  @override
  String get customerSummary => 'Customer Summary';

  @override
  String get customerNotes => 'Customer Notes';

  @override
  String offersReceived(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offers received',
      one: '$count offer received',
    );
    return '$_temp0';
  }

  @override
  String get competitorPricingHidden =>
      'Competitor pricing and terms are hidden per marketplace rules.';

  @override
  String get requestExpired => 'Request Expired';

  @override
  String get requestClosed => 'Request Closed';

  @override
  String get makeAnOfferCp3 => 'Make an Offer (CP-3)';

  @override
  String get biddingOpensCp3 => 'Bidding opens in Check-Point 3.';

  @override
  String get makeAnOffer => 'Make an Offer';

  @override
  String get myOffersTitle => 'My Offers';

  @override
  String get submitOfferTitle => 'Submit Offer';

  @override
  String get reviseOfferTitle => 'Revise Offer';

  @override
  String get submitOfferAction => 'Submit Offer';

  @override
  String get reviseOfferAction => 'Save revision';

  @override
  String get withdrawOfferAction => 'Withdraw Offer';

  @override
  String get withdrawOfferConfirmTitle => 'Withdraw this Offer?';

  @override
  String get withdrawOfferConfirmBody =>
      'You can submit a new Offer afterwards if the Request is still open.';

  @override
  String get offerTabPending => 'Pending';

  @override
  String get offerTabAccepted => 'Accepted';

  @override
  String get offerTabClosed => 'Closed';

  @override
  String get offerStatePending => 'Pending';

  @override
  String get offerStateAccepted => 'Accepted';

  @override
  String get offerStateRejected => 'Rejected';

  @override
  String get offerStateExpired => 'Expired';

  @override
  String get offerStateWithdrawn => 'Withdrawn';

  @override
  String get offerStateUnknown => 'Unknown';

  @override
  String get offerFallbackTitle => 'Offer';

  @override
  String get offerAwardedElsewhere => 'This Request was awarded elsewhere.';

  @override
  String get offerConnectionCp4 => 'Connection opens in Check-Point 4.';

  @override
  String get offerSearchByReference => 'Search by reference';

  @override
  String get offerValidityLabel => 'Validity';

  @override
  String offerValidityHours(int hours) {
    return '$hours hours';
  }

  @override
  String offerAbsoluteExpiry(String when) {
    return 'Expires at $when';
  }

  @override
  String get offerPriceLabel => 'Offered price';

  @override
  String get offerMakingChargesLabel => 'Making charges (optional)';

  @override
  String get offerRatePerGramLabel => 'Rate per gram (optional)';

  @override
  String get offerDeliveryLabel => 'Delivery / readiness';

  @override
  String get offerWarrantyLabel => 'Warranty / buy-back terms';

  @override
  String get offerNoteLabel => 'Note (no contact details)';

  @override
  String get offerImagesHint => 'Up to 3 supporting images (optional).';

  @override
  String get offerCurrentTerms => 'Current terms';

  @override
  String get offerNewTerms => 'New terms';

  @override
  String offerRevisionsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count revisions remaining',
      one: '$count revision remaining',
    );
    return '$_temp0';
  }

  @override
  String get offersEmptyBody =>
      'No offers yet. Submit an Offer from a matched Request.';

  @override
  String get couldNotLoadOffers => 'Could not load offers.';

  @override
  String get couldNotLoadRequest => 'Could not load request.';

  @override
  String get couldNotLoadOffer => 'Could not load offer.';

  @override
  String get commonSubmitting => 'Submitting…';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get couldNotLoadDashboard => 'Could not load your dashboard.';

  @override
  String matchingRequestsWaiting(int count) {
    return '$count matching request(s) waiting';
  }

  @override
  String get noNewRequestsRightNow => 'No new requests right now';

  @override
  String get latestMatches => 'Latest matches';

  @override
  String get seeAll => 'See all';

  @override
  String offersExpiringWithin24h(int count) {
    return '$count expiring within 24h';
  }

  @override
  String get activeBidsAwaiting => 'Active bids awaiting customer response';

  @override
  String get offerManagementCp3 => 'Offer management opens in Check-Point 3';

  @override
  String connectionsNoTalkYet(int count) {
    return '$count with no talk yet';
  }

  @override
  String get wonDealsChats => 'Won deals & direct customer chats';

  @override
  String get connectionsOpenCp4 => 'Connections open in Check-Point 4';

  @override
  String activeEntitlementsCount(int count) {
    return '$count active entitlement(s)';
  }

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortExpiringSoon => 'Expiring Soon';

  @override
  String get sortHighestValue => 'Highest Value';

  @override
  String get sortFewestOffers => 'Fewest Offers';

  @override
  String get requestTypeFindOrnament => 'Find Ornament';

  @override
  String get requestTypeCustomDesign => 'Custom Design';

  @override
  String get requestTypeBullion => 'Bullion';

  @override
  String get requestTypeBullionInvestment => 'Bullion & Investment';

  @override
  String get requestTypeRepairResize => 'Repair & Resize';

  @override
  String get category => 'Category';

  @override
  String get couldNotLoadCategories => 'Could not load categories';

  @override
  String get anyCategory => 'Any category';

  @override
  String get region => 'Region';

  @override
  String get couldNotLoadRegions => 'Could not load regions';

  @override
  String get anyRegion => 'Any region';

  @override
  String get budgetAed => 'Budget (AED)';

  @override
  String get minLabel => 'Min';

  @override
  String get maxLabel => 'Max';

  @override
  String get purityKarat => 'Purity (Karat)';

  @override
  String get couldNotLoadPresets => 'Could not load presets';

  @override
  String get saveFilterPreset => 'Save Filter Preset';

  @override
  String get presetNameHint => 'Preset name (e.g. Dubai 22K Rings)';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get couldNotLoadSubscriptionDetails =>
      'Could not load subscription details.';

  @override
  String get planRate => 'Plan Rate:';

  @override
  String aedPerMonth(String price) {
    return 'AED $price / month';
  }

  @override
  String get nextRenewal => 'Next Renewal:';

  @override
  String gracePeriodActiveUntil(String date) {
    return 'Grace period active until $date. Renew now to avoid losing matching eligibility.';
  }

  @override
  String get subscriptionExpiredPaused =>
      'Subscription expired. Matching requests for this category are currently paused.';

  @override
  String get responded => 'Responded';

  @override
  String offerCountShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offers',
      one: '$count offer',
    );
    return '$_temp0';
  }

  @override
  String get budgetFrom => 'From ';

  @override
  String get budgetUpTo => 'Up to ';

  @override
  String get openBudget => 'Open Budget';

  @override
  String get requestFallback => 'Request';

  @override
  String get specifications => 'Specifications';

  @override
  String get purity => 'Purity';

  @override
  String get weight => 'Weight';

  @override
  String get budget => 'Budget';

  @override
  String get type => 'Type';

  @override
  String get direction => 'Direction';

  @override
  String get notes => 'Notes';

  @override
  String karatGold(String karat) {
    return '${karat}K Gold';
  }

  @override
  String weightGrams(String weight) {
    return '$weight g';
  }

  @override
  String weightGramsApprox(String weight) {
    return '$weight g (approx)';
  }

  @override
  String budgetRangeAed(String min, String max) {
    return 'AED $min - $max';
  }

  @override
  String budgetRangeAedFlex(String min, String max) {
    return 'AED $min - $max (flex)';
  }

  @override
  String budgetFromAed(String amount) {
    return 'From AED $amount';
  }

  @override
  String budgetUpToAed(String amount) {
    return 'Up to AED $amount';
  }

  @override
  String get budgetOpen => 'Open';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardRating => 'Rating';

  @override
  String get dashboardNoReviews => 'No reviews yet';

  @override
  String get dashboardGoldRates => 'Reference gold rates';

  @override
  String get dashboardSubscriptions => 'Type subscriptions';

  @override
  String get dashboardNoSubscriptions => 'No type subscriptions yet';

  @override
  String get dashboardNewRequests => 'New requests';

  @override
  String get dashboardPendingOffers => 'Pending offers';

  @override
  String get dashboardActiveConnections => 'Active connections';

  @override
  String get commonEmpty => 'Nothing here yet';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonLogout => 'Log out';

  @override
  String get appTitle => 'Karat Hive';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authRegister => 'Create a vendor account';

  @override
  String get authMobile => 'Mobile number';

  @override
  String get authEmail => 'Business email';

  @override
  String get authPassword => 'Password';

  @override
  String get authSendCode => 'Send code';

  @override
  String get authResendCode => 'Resend code';

  @override
  String get authEnterCode => 'Enter the 6-digit code';

  @override
  String get authVerify => 'Verify';

  @override
  String get authOtpTab => 'Mobile & code';

  @override
  String get authPasswordTab => 'Email & password';

  @override
  String get authSignInFailed => 'Sign in failed.';

  @override
  String get authContinue => 'Continue';

  @override
  String get authBackToSignIn => 'Back to sign in';

  @override
  String get authOtpSentMobile => 'We sent a code to your mobile number.';

  @override
  String get authVerifyAndCreateAccount => 'Verify & create account';

  @override
  String get authRegistrationFailed => 'Registration failed.';

  @override
  String get authLegalBusinessName => 'Legal business name';

  @override
  String get authTradingName => 'Trading name';

  @override
  String get authTradeLicenceNumber => 'Trade licence number';

  @override
  String get authLicenceExpiry => 'Licence expiry (YYYY-MM-DD)';

  @override
  String get authBusinessAddress => 'Business address';

  @override
  String get authContactPerson => 'Contact person';

  @override
  String get authHomeRegion => 'Home region';

  @override
  String get authCategoriesYouServe => 'Categories you serve';

  @override
  String get authRegionsYouServe => 'Regions you serve';

  @override
  String get authSignInWithGoogle => 'Sign in with Google';

  @override
  String get authSigningInWithGoogle => 'Signing in...';

  @override
  String authGoogleSignInFailed(String error) {
    return 'Google Sign-In failed: $error';
  }

  @override
  String get onboardingAwaitingTitle => 'Verification in progress';

  @override
  String get onboardingPendingDocuments =>
      'Upload your business documents to continue.';

  @override
  String get onboardingPendingAdmin => 'Our team is reviewing your documents.';

  @override
  String get onboardingCategoriesRequired =>
      'Choose the categories and regions you serve.';

  @override
  String get onboardingRejected => 'Your application needs changes.';

  @override
  String get onboardingUploadKyc => 'Upload documents';

  @override
  String get onboardingResubmit => 'Resubmit for review';

  @override
  String get onboardingCategoriesRegions => 'Categories & regions';

  @override
  String get onboardingSave => 'Save';

  @override
  String get onboardingAwayMode => 'Away mode';

  @override
  String get onboardingAwayModeHint =>
      'Pause new-request notifications without deactivating.';

  @override
  String get onboardingVolumePlaceholder =>
      'Matched-request volume will appear once matching is live.';

  @override
  String get onboardingKycUploadHint =>
      'Upload your trade licence and Emirates ID for verification.';

  @override
  String get onboardingCategoriesHeading => 'Categories';

  @override
  String get onboardingRegionsHeading => 'Regions';

  @override
  String get onboardingCouldNotSave => 'Could not save.';

  @override
  String get commonDone => 'Done';

  @override
  String get uploadActionAdd => 'Add';

  @override
  String get uploadActionReplace => 'Replace';

  @override
  String get uploadActionRetry => 'Retry';

  @override
  String get budgetRangeSeparator => ' - ';

  @override
  String get dashboardGoldRatesUnavailable => 'Reference rates unavailable';

  @override
  String get lifecycleRegistered => 'Registered';

  @override
  String get lifecyclePendingVerification => 'Under review';

  @override
  String get lifecycleVerified => 'Verified';

  @override
  String get lifecycleActive => 'Active';

  @override
  String get lifecycleSuspended => 'Suspended';

  @override
  String get lifecycleRejected => 'Needs changes';

  @override
  String get lifecycleDeactivated => 'Deactivated';

  @override
  String get lifecycleUnknown => 'Unknown';

  @override
  String get relativeTimeJustNow => 'just now';

  @override
  String relativeTimeMinutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String relativeTimeHoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String relativeTimeDaysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get expiryExpired => 'Expired';

  @override
  String expiryDaysHoursLeft(int days, int hours) {
    return '${days}d ${hours}h left';
  }

  @override
  String expiryHoursMinutesLeft(int hours, int minutes) {
    return '${hours}h ${minutes}m left';
  }

  @override
  String expiryMinutesSecondsLeft(int minutes, int seconds) {
    return '${minutes}m ${seconds}s left';
  }

  @override
  String expirySecondsLeft(int seconds) {
    return '${seconds}s left';
  }

  @override
  String expiryTimeRemainingSemantics(String text) {
    return 'Time remaining: $text';
  }

  @override
  String dealCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count deals',
      one: '$count deal',
    );
    return '$_temp0';
  }

  @override
  String get connectionsTitle => 'Connections';

  @override
  String get connectionsEmptyBody =>
      'No Connections yet. Accepted Offers appear here.';

  @override
  String get couldNotLoadConnections => 'Could not load Connections.';

  @override
  String get couldNotLoadConnection => 'Could not load this Connection.';

  @override
  String get connectionSectionActive => 'Active';

  @override
  String get connectionSectionClosed => 'Closed';

  @override
  String get connectionStateActive => 'Active';

  @override
  String get connectionStateClosed => 'Closed';

  @override
  String get connectionStateUnknown => 'Unknown';

  @override
  String get connectionTalk => 'Talk';

  @override
  String get connectionCall => 'Call';

  @override
  String get connectionCopyNumber => 'Copy number';

  @override
  String get connectionCopied => 'Copied';

  @override
  String get connectionClose => 'Close Connection';

  @override
  String get connectionCloseConfirmTitle => 'Close this Connection?';

  @override
  String get connectionCloseConfirmBody =>
      'Details stay available. Reviews open in Check-Point 5.';

  @override
  String get connectionClosedBanner =>
      'This Connection is closed. Details remain available.';

  @override
  String get connectionReviewsCp5 => 'Reviews open in Check-Point 5';

  @override
  String get connectionWhatsAppMissing =>
      'WhatsApp is not available. Copy the number or call instead.';

  @override
  String get connectionCouldNotOpenTalk => 'Could not open WhatsApp.';

  @override
  String get connectionDetailTitle => 'Connection';

  @override
  String get connectionIdentityRevealedAt => 'Identity revealed';

  @override
  String get connectionAcceptedTerms => 'Accepted Offer terms';

  @override
  String get connectionLeaveFeedback => 'Leave feedback';

  @override
  String get connectionReport => 'Report';
}
