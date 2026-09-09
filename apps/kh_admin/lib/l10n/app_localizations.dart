import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Title of the administrative web portal
  ///
  /// In en, this message translates to:
  /// **'Karat Hive Admin Portal'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'PLATFORM ADMIN'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Karat Hive Internal Management Portal'**
  String get loginSubtitle;

  /// No description provided for @loginInstructions.
  ///
  /// In en, this message translates to:
  /// **'Please sign in with your administrative credentials.'**
  String get loginInstructions;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'admin@karathive.ae'**
  String get emailHint;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Admin email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get emailInvalid;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Authenticate & Enter Portal'**
  String get signInButton;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Authenticating...'**
  String get signingIn;

  /// No description provided for @errorAccountLocked.
  ///
  /// In en, this message translates to:
  /// **'Your administrative account has been temporarily locked due to consecutive failed login attempts. Please wait 30 minutes or contact security.'**
  String get errorAccountLocked;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid administrative credentials. Please check your email and password.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorServerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Administrative service unavailable. Please check your connection and try again.'**
  String get errorServerUnavailable;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get errorUnknown;

  /// No description provided for @dashboardEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Platform Overview'**
  String get dashboardEyebrow;

  /// No description provided for @dashboardHeading.
  ///
  /// In en, this message translates to:
  /// **'Admin Control Center'**
  String get dashboardHeading;

  /// No description provided for @systemOperational.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM OPERATIONAL'**
  String get systemOperational;

  /// No description provided for @dashboardSampleDataNotice.
  ///
  /// In en, this message translates to:
  /// **'Live platform figures from GET /v1/admin/dashboard. Queue rows snapshot verification, abuse reports, and pending reviews. Settlement is off-platform; GMV is not shown.'**
  String get dashboardSampleDataNotice;

  /// No description provided for @quickActionQueues.
  ///
  /// In en, this message translates to:
  /// **'Quick Action Queues'**
  String get quickActionQueues;

  /// No description provided for @queueColumnItem.
  ///
  /// In en, this message translates to:
  /// **'Queue Item'**
  String get queueColumnItem;

  /// No description provided for @queueColumnType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get queueColumnType;

  /// No description provided for @queueColumnSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get queueColumnSubmitted;

  /// No description provided for @queueColumnStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get queueColumnStatus;

  /// No description provided for @queueColumnAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get queueColumnAction;

  /// Label above the ADM-S02 dashboard date-range selector
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get dashboardRangeLabel;

  /// No description provided for @dashboardRange7.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get dashboardRange7;

  /// No description provided for @dashboardRange30.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get dashboardRange30;

  /// No description provided for @dashboardRange90.
  ///
  /// In en, this message translates to:
  /// **'Last 90 days'**
  String get dashboardRange90;

  /// No description provided for @dashboardTrendsHeading.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get dashboardTrendsHeading;

  /// No description provided for @dashboardTrendCaption.
  ///
  /// In en, this message translates to:
  /// **'Request volume by state over the selected range.'**
  String get dashboardTrendCaption;

  /// No description provided for @dashboardTrendEmpty.
  ///
  /// In en, this message translates to:
  /// **'No trend data for this range.'**
  String get dashboardTrendEmpty;

  /// Retry button on a dashboard queue-source or trend error
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get dashboardQueueRetry;

  /// No description provided for @queueSourceVerification.
  ///
  /// In en, this message translates to:
  /// **'verification queue'**
  String get queueSourceVerification;

  /// No description provided for @queueSourceAbuse.
  ///
  /// In en, this message translates to:
  /// **'abuse reports'**
  String get queueSourceAbuse;

  /// No description provided for @queueSourceReview.
  ///
  /// In en, this message translates to:
  /// **'pending reviews'**
  String get queueSourceReview;

  /// No description provided for @categoriesEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Taxonomy Config'**
  String get categoriesEyebrow;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Categories'**
  String get categoriesTitle;

  /// No description provided for @categoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage two-level product category taxonomy for requests and vendor specialisations.'**
  String get categoriesSubtitle;

  /// No description provided for @regionsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Geographic Taxonomy'**
  String get regionsEyebrow;

  /// No description provided for @regionsTitle.
  ///
  /// In en, this message translates to:
  /// **'UAE Regions & Souk Zones'**
  String get regionsTitle;

  /// No description provided for @regionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage geographic matching taxonomy (emirates and areas) for marketplace routing.'**
  String get regionsSubtitle;

  /// No description provided for @showInactive.
  ///
  /// In en, this message translates to:
  /// **'Show Inactive'**
  String get showInactive;

  /// No description provided for @hideInactive.
  ///
  /// In en, this message translates to:
  /// **'Hide Inactive'**
  String get hideInactive;

  /// No description provided for @addRootCategory.
  ///
  /// In en, this message translates to:
  /// **'+ Add Category'**
  String get addRootCategory;

  /// No description provided for @addRootRegion.
  ///
  /// In en, this message translates to:
  /// **'+ Add Region'**
  String get addRootRegion;

  /// No description provided for @addChildCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Subcategory'**
  String get addChildCategory;

  /// No description provided for @addChildRegion.
  ///
  /// In en, this message translates to:
  /// **'Add Area'**
  String get addChildRegion;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @editRegion.
  ///
  /// In en, this message translates to:
  /// **'Edit Region'**
  String get editRegion;

  /// No description provided for @createRootCategory.
  ///
  /// In en, this message translates to:
  /// **'New Root Category'**
  String get createRootCategory;

  /// No description provided for @createRootRegion.
  ///
  /// In en, this message translates to:
  /// **'New Root Region'**
  String get createRootRegion;

  /// No description provided for @newChildCategory.
  ///
  /// In en, this message translates to:
  /// **'New Subcategory'**
  String get newChildCategory;

  /// No description provided for @newChildRegion.
  ///
  /// In en, this message translates to:
  /// **'New Area'**
  String get newChildRegion;

  /// No description provided for @nameEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (English)'**
  String get nameEnLabel;

  /// No description provided for @nameArLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (Arabic)'**
  String get nameArLabel;

  /// No description provided for @nameEnRequired.
  ///
  /// In en, this message translates to:
  /// **'English name is required and cannot be blank'**
  String get nameEnRequired;

  /// No description provided for @nameArRequired.
  ///
  /// In en, this message translates to:
  /// **'Arabic name is required and cannot be blank'**
  String get nameArRequired;

  /// No description provided for @iconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get iconLabel;

  /// No description provided for @displayOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Display Order'**
  String get displayOrderLabel;

  /// No description provided for @activeStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Active Status'**
  String get activeStatusLabel;

  /// No description provided for @activeStatusDescription.
  ///
  /// In en, this message translates to:
  /// **'Inactive nodes are hidden from customer/vendor selection but preserve existing associations.'**
  String get activeStatusDescription;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveButton;

  /// No description provided for @createButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createButton;

  /// No description provided for @deactivateButton.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivateButton;

  /// No description provided for @deactivateConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate {name}?'**
  String deactivateConfirmTitle(String name);

  /// No description provided for @deactivateConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to deactivate \"{name}\"? Inactive nodes cannot be selected for new requests, but existing associations are preserved. This action can be reversed later.'**
  String deactivateConfirmBody(String name);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirmDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get confirmDeactivate;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get statusInactive;

  /// No description provided for @emptyCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'No Categories Found'**
  String get emptyCategoriesTitle;

  /// No description provided for @emptyCategoriesBody.
  ///
  /// In en, this message translates to:
  /// **'No product categories have been configured yet. Create a root category to start building the taxonomy.'**
  String get emptyCategoriesBody;

  /// No description provided for @emptyRegionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Regions Found'**
  String get emptyRegionsTitle;

  /// No description provided for @emptyRegionsBody.
  ///
  /// In en, this message translates to:
  /// **'No regions have been configured yet. Create a root emirate or region to begin.'**
  String get emptyRegionsBody;

  /// No description provided for @toastCategoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Category created successfully.'**
  String get toastCategoryCreated;

  /// No description provided for @toastCategoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Category updated successfully.'**
  String get toastCategoryUpdated;

  /// No description provided for @toastCategoryDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Category deactivated successfully.'**
  String get toastCategoryDeactivated;

  /// No description provided for @toastRegionCreated.
  ///
  /// In en, this message translates to:
  /// **'Region created successfully.'**
  String get toastRegionCreated;

  /// No description provided for @toastRegionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Region updated successfully.'**
  String get toastRegionUpdated;

  /// No description provided for @toastRegionDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Region deactivated successfully.'**
  String get toastRegionDeactivated;

  /// No description provided for @levelLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum hierarchy depth reached (2 levels). Cannot add children to this node.'**
  String get levelLimitReached;

  /// No description provided for @selectNodeToEdit.
  ///
  /// In en, this message translates to:
  /// **'Select a node from the tree to edit or create a child, or create a new root node.'**
  String get selectNodeToEdit;

  /// No description provided for @vendorsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Vendor Management'**
  String get vendorsEyebrow;

  /// No description provided for @vendorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Vendor List'**
  String get vendorsTitle;

  /// No description provided for @vendorsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse and search vendors by verification and account state.'**
  String get vendorsSubtitle;

  /// No description provided for @vendorsFilterVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification state'**
  String get vendorsFilterVerification;

  /// No description provided for @vendorsFilterAccount.
  ///
  /// In en, this message translates to:
  /// **'Account state'**
  String get vendorsFilterAccount;

  /// No description provided for @vendorsFilterSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get vendorsFilterSearch;

  /// No description provided for @vendorsFilterSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Business name, licence, mobile…'**
  String get vendorsFilterSearchHint;

  /// No description provided for @vendorsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get vendorsFilterAll;

  /// No description provided for @vendorsColumnBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get vendorsColumnBusiness;

  /// No description provided for @vendorsColumnTrading.
  ///
  /// In en, this message translates to:
  /// **'Trading name'**
  String get vendorsColumnTrading;

  /// No description provided for @vendorsColumnVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get vendorsColumnVerification;

  /// No description provided for @vendorsColumnAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get vendorsColumnAccount;

  /// No description provided for @vendorsColumnWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get vendorsColumnWaiting;

  /// No description provided for @vendorsColumnAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get vendorsColumnAction;

  /// No description provided for @vendorsActionView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get vendorsActionView;

  /// No description provided for @vendorsActionReviewKyc.
  ///
  /// In en, this message translates to:
  /// **'Review KYC'**
  String get vendorsActionReviewKyc;

  /// No description provided for @vendorsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No vendors found'**
  String get vendorsEmptyTitle;

  /// No description provided for @vendorsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No vendors match the current filters.'**
  String get vendorsEmptyBody;

  /// No description provided for @vendorsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load vendors'**
  String get vendorsErrorTitle;

  /// No description provided for @vendorsRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get vendorsRetry;

  /// No description provided for @vendorsLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get vendorsLoadMore;

  /// No description provided for @vendorsVerificationRegistered.
  ///
  /// In en, this message translates to:
  /// **'REGISTERED'**
  String get vendorsVerificationRegistered;

  /// No description provided for @vendorsVerificationPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING VERIFICATION'**
  String get vendorsVerificationPending;

  /// No description provided for @vendorsVerificationVerified.
  ///
  /// In en, this message translates to:
  /// **'VERIFIED'**
  String get vendorsVerificationVerified;

  /// No description provided for @vendorsVerificationRejected.
  ///
  /// In en, this message translates to:
  /// **'REJECTED'**
  String get vendorsVerificationRejected;

  /// No description provided for @vendorsAccountActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get vendorsAccountActive;

  /// No description provided for @vendorsAccountSuspended.
  ///
  /// In en, this message translates to:
  /// **'SUSPENDED'**
  String get vendorsAccountSuspended;

  /// No description provided for @vendorsAccountDeactivated.
  ///
  /// In en, this message translates to:
  /// **'DEACTIVATED'**
  String get vendorsAccountDeactivated;

  /// No description provided for @vendorsWaitingHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h waiting'**
  String vendorsWaitingHours(int hours);

  /// No description provided for @vendorsDetailEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Vendor Profile'**
  String get vendorsDetailEyebrow;

  /// No description provided for @vendorsDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Vendor Detail'**
  String get vendorsDetailTitle;

  /// No description provided for @vendorsDetailVendorId.
  ///
  /// In en, this message translates to:
  /// **'Vendor ID: {id}'**
  String vendorsDetailVendorId(String id);

  /// No description provided for @verificationEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Compliance Reviewer'**
  String get verificationEyebrow;

  /// No description provided for @verificationHeading.
  ///
  /// In en, this message translates to:
  /// **'KYC Verification Queue ({count} Pending)'**
  String verificationHeading(int count);

  /// No description provided for @verificationHeadingLoading.
  ///
  /// In en, this message translates to:
  /// **'KYC Verification Queue'**
  String get verificationHeadingLoading;

  /// No description provided for @verificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review vendor KYC submissions oldest-first. Every document view and decision is audit-logged.'**
  String get verificationSubtitle;

  /// No description provided for @oldestFirstBadge.
  ///
  /// In en, this message translates to:
  /// **'OLDEST FIRST'**
  String get oldestFirstBadge;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @verificationColumnBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get verificationColumnBusiness;

  /// No description provided for @verificationColumnLicence.
  ///
  /// In en, this message translates to:
  /// **'Licence'**
  String get verificationColumnLicence;

  /// No description provided for @verificationColumnWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get verificationColumnWaiting;

  /// No description provided for @verificationColumnStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get verificationColumnStatus;

  /// No description provided for @statusPendingVerification.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get statusPendingVerification;

  /// No description provided for @waitingLessThanHour.
  ///
  /// In en, this message translates to:
  /// **'< 1 hour'**
  String get waitingLessThanHour;

  /// No description provided for @waitingHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h waiting'**
  String waitingHours(int hours);

  /// No description provided for @waitingDays.
  ///
  /// In en, this message translates to:
  /// **'{days}d waiting'**
  String waitingDays(int days);

  /// No description provided for @emptyVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Queue is Clear'**
  String get emptyVerificationTitle;

  /// No description provided for @emptyVerificationBody.
  ///
  /// In en, this message translates to:
  /// **'No vendors are currently awaiting KYC verification.'**
  String get emptyVerificationBody;

  /// No description provided for @verificationLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Failed to load verification queue'**
  String get verificationLoadErrorTitle;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @declaredBusinessProfile.
  ///
  /// In en, this message translates to:
  /// **'Declared Business Profile'**
  String get declaredBusinessProfile;

  /// No description provided for @legalNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Legal Name'**
  String get legalNameLabel;

  /// No description provided for @tradeLicenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Trade Licence'**
  String get tradeLicenceLabel;

  /// No description provided for @licenceExpiryLabel.
  ///
  /// In en, this message translates to:
  /// **'Licence Expiry'**
  String get licenceExpiryLabel;

  /// No description provided for @emirateLabel.
  ///
  /// In en, this message translates to:
  /// **'Emirate / Region'**
  String get emirateLabel;

  /// No description provided for @contactPersonLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact Person'**
  String get contactPersonLabel;

  /// No description provided for @businessAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Registered Address'**
  String get businessAddressLabel;

  /// No description provided for @notDeclared.
  ///
  /// In en, this message translates to:
  /// **'Not declared'**
  String get notDeclared;

  /// No description provided for @adminRationaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin Review Rationale / Notes'**
  String get adminRationaleLabel;

  /// No description provided for @adminRationaleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter reason for approval, rejection, or information request…'**
  String get adminRationaleHint;

  /// No description provided for @rationaleRequired.
  ///
  /// In en, this message translates to:
  /// **'A rationale or message is required for every decision'**
  String get rationaleRequired;

  /// No description provided for @documentInspectorTitle.
  ///
  /// In en, this message translates to:
  /// **'Document Inspector'**
  String get documentInspectorTitle;

  /// No description provided for @noDocumentsUploaded.
  ///
  /// In en, this message translates to:
  /// **'No documents uploaded.'**
  String get noDocumentsUploaded;

  /// No description provided for @selectDocumentToView.
  ///
  /// In en, this message translates to:
  /// **'Select a document to load the viewer.'**
  String get selectDocumentToView;

  /// No description provided for @openFullscreenViewer.
  ///
  /// In en, this message translates to:
  /// **'Open Fullscreen Viewer'**
  String get openFullscreenViewer;

  /// No description provided for @documentSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'{sizeMb} MB'**
  String documentSizeLabel(String sizeMb);

  /// No description provided for @documentTypeTradeLicence.
  ///
  /// In en, this message translates to:
  /// **'Trade licence'**
  String get documentTypeTradeLicence;

  /// No description provided for @documentTypeEmiratesId.
  ///
  /// In en, this message translates to:
  /// **'Emirates ID'**
  String get documentTypeEmiratesId;

  /// No description provided for @documentTypeVatCert.
  ///
  /// In en, this message translates to:
  /// **'VAT certificate'**
  String get documentTypeVatCert;

  /// No description provided for @documentTypeTradingPermit.
  ///
  /// In en, this message translates to:
  /// **'Trading permit'**
  String get documentTypeTradingPermit;

  /// No description provided for @documentTypeTenancy.
  ///
  /// In en, this message translates to:
  /// **'Tenancy contract'**
  String get documentTypeTenancy;

  /// No description provided for @documentTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other document'**
  String get documentTypeOther;

  /// No description provided for @approveVendorButton.
  ///
  /// In en, this message translates to:
  /// **'Approve Vendor & Activate Market Access'**
  String get approveVendorButton;

  /// No description provided for @requestInfoButton.
  ///
  /// In en, this message translates to:
  /// **'Request More Information'**
  String get requestInfoButton;

  /// No description provided for @rejectVendorButton.
  ///
  /// In en, this message translates to:
  /// **'Reject Application'**
  String get rejectVendorButton;

  /// No description provided for @approveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve vendor application?'**
  String get approveConfirmTitle;

  /// No description provided for @approveConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will mark the vendor as VERIFIED and may advance them to ACTIVE if categories and regions are already declared. The decision is audit-logged.'**
  String get approveConfirmBody;

  /// No description provided for @confirmApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get confirmApprove;

  /// No description provided for @rejectConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject vendor application?'**
  String get rejectConfirmTitle;

  /// No description provided for @rejectConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The vendor will be notified with your rationale and may resubmit documents. This decision is audit-logged.'**
  String get rejectConfirmBody;

  /// No description provided for @confirmReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get confirmReject;

  /// No description provided for @requestInfoConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Request more information?'**
  String get requestInfoConfirmTitle;

  /// No description provided for @requestInfoConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The vendor will remain in the verification queue and see your message in their awaiting-approval shell.'**
  String get requestInfoConfirmBody;

  /// No description provided for @confirmRequestInfo.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get confirmRequestInfo;

  /// No description provided for @toastVendorApproved.
  ///
  /// In en, this message translates to:
  /// **'Vendor approved successfully.'**
  String get toastVendorApproved;

  /// No description provided for @toastVendorRejected.
  ///
  /// In en, this message translates to:
  /// **'Vendor application rejected.'**
  String get toastVendorRejected;

  /// No description provided for @toastInfoRequested.
  ///
  /// In en, this message translates to:
  /// **'Information request sent to vendor.'**
  String get toastInfoRequested;

  /// No description provided for @offersListEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Marketplace Audit'**
  String get offersListEyebrow;

  /// No description provided for @offersListHeading.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offersListHeading;

  /// No description provided for @offersListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Platform-wide vendor offer monitoring and inspection'**
  String get offersListSubtitle;

  /// No description provided for @offersFilterState.
  ///
  /// In en, this message translates to:
  /// **'Offer state'**
  String get offersFilterState;

  /// No description provided for @offersFilterAllStates.
  ///
  /// In en, this message translates to:
  /// **'All States'**
  String get offersFilterAllStates;

  /// No description provided for @offersFilterRequestType.
  ///
  /// In en, this message translates to:
  /// **'Request type'**
  String get offersFilterRequestType;

  /// No description provided for @offersFilterAllTypes.
  ///
  /// In en, this message translates to:
  /// **'All Types'**
  String get offersFilterAllTypes;

  /// No description provided for @offersFilterSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get offersFilterSearch;

  /// No description provided for @offersFilterSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Offer ID, vendor name, request ref…'**
  String get offersFilterSearchHint;

  /// No description provided for @offersFilterSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search offers'**
  String get offersFilterSearchTooltip;

  /// No description provided for @offersColumnReference.
  ///
  /// In en, this message translates to:
  /// **'Offer Reference/ID'**
  String get offersColumnReference;

  /// No description provided for @offersColumnParentRequest.
  ///
  /// In en, this message translates to:
  /// **'Parent Request'**
  String get offersColumnParentRequest;

  /// No description provided for @offersColumnVendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor Name'**
  String get offersColumnVendor;

  /// No description provided for @offersColumnOfferedPrice.
  ///
  /// In en, this message translates to:
  /// **'Offered Price (AED)'**
  String get offersColumnOfferedPrice;

  /// No description provided for @offersColumnState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get offersColumnState;

  /// No description provided for @offersColumnSubmissionDate.
  ///
  /// In en, this message translates to:
  /// **'Submission Date'**
  String get offersColumnSubmissionDate;

  /// No description provided for @offersColumnExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get offersColumnExpiryDate;

  /// No description provided for @offersColumnOutcome.
  ///
  /// In en, this message translates to:
  /// **'Outcome'**
  String get offersColumnOutcome;

  /// No description provided for @offersColumnAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get offersColumnAction;

  /// No description provided for @offersOutcomeAcceptedByCustomer.
  ///
  /// In en, this message translates to:
  /// **'Accepted by Customer'**
  String get offersOutcomeAcceptedByCustomer;

  /// No description provided for @offersOutcomeRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get offersOutcomeRejected;

  /// No description provided for @offersOutcomeExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get offersOutcomeExpired;

  /// No description provided for @offersOutcomePending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get offersOutcomePending;

  /// No description provided for @offersActionInspect.
  ///
  /// In en, this message translates to:
  /// **'Inspect'**
  String get offersActionInspect;

  /// No description provided for @offersPaginationShowing.
  ///
  /// In en, this message translates to:
  /// **'Showing {count} offers'**
  String offersPaginationShowing(int count);

  /// No description provided for @offersPaginationShowingOf.
  ///
  /// In en, this message translates to:
  /// **'Showing {count} offers of {total}'**
  String offersPaginationShowingOf(int count, int total);

  /// No description provided for @offersPaginationPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get offersPaginationPrevious;

  /// No description provided for @offersPaginationPage.
  ///
  /// In en, this message translates to:
  /// **'Page {page}'**
  String offersPaginationPage(int page);

  /// No description provided for @offersPaginationNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get offersPaginationNext;

  /// No description provided for @offersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No offers found'**
  String get offersEmptyTitle;

  /// No description provided for @offersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No offers match the current filter criteria.'**
  String get offersEmptyBody;

  /// No description provided for @offersErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Failed to load offers'**
  String get offersErrorTitle;

  /// No description provided for @offersRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get offersRetry;

  /// No description provided for @offersDetailBack.
  ///
  /// In en, this message translates to:
  /// **'Back to Offers'**
  String get offersDetailBack;

  /// No description provided for @offersDetailEyebrow.
  ///
  /// In en, this message translates to:
  /// **'OFFER {reference}'**
  String offersDetailEyebrow(String reference);

  /// No description provided for @offersDetailHeaderMeta.
  ///
  /// In en, this message translates to:
  /// **'Submitted on {date} · Validity {hours}h'**
  String offersDetailHeaderMeta(String date, int hours);

  /// No description provided for @offersDetailHeaderMetaExpires.
  ///
  /// In en, this message translates to:
  /// **'Submitted on {date} · Validity {hours}h (Expires {expiry})'**
  String offersDetailHeaderMetaExpires(String date, int hours, String expiry);

  /// No description provided for @offersDetailCompetingWonTitle.
  ///
  /// In en, this message translates to:
  /// **'COMPETING OFFER WON THIS REQUEST'**
  String get offersDetailCompetingWonTitle;

  /// No description provided for @offersDetailCompetingWonBody.
  ///
  /// In en, this message translates to:
  /// **'Customer selected winning offer {reference}{vendorPart}{pricePart}.'**
  String offersDetailCompetingWonBody(
    String reference,
    String vendorPart,
    String pricePart,
  );

  /// No description provided for @offersDetailCompetingWonBy.
  ///
  /// In en, this message translates to:
  /// **' by {vendor}'**
  String offersDetailCompetingWonBy(String vendor);

  /// No description provided for @offersDetailCompetingWonFor.
  ///
  /// In en, this message translates to:
  /// **' for {price}'**
  String offersDetailCompetingWonFor(String price);

  /// No description provided for @offersDetailInspectWinning.
  ///
  /// In en, this message translates to:
  /// **'Inspect Winning Offer'**
  String get offersDetailInspectWinning;

  /// No description provided for @offersDetailVendorProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Unmasked Vendor Profile'**
  String get offersDetailVendorProfileTitle;

  /// No description provided for @offersDetailViewVendor.
  ///
  /// In en, this message translates to:
  /// **'View Vendor'**
  String get offersDetailViewVendor;

  /// No description provided for @offersDetailNoVendor.
  ///
  /// In en, this message translates to:
  /// **'No vendor details provided.'**
  String get offersDetailNoVendor;

  /// No description provided for @offersDetailLabelLegalName.
  ///
  /// In en, this message translates to:
  /// **'Legal Business Name'**
  String get offersDetailLabelLegalName;

  /// No description provided for @offersDetailLabelTradingName.
  ///
  /// In en, this message translates to:
  /// **'Trading Name'**
  String get offersDetailLabelTradingName;

  /// No description provided for @offersDetailLabelTradeLicence.
  ///
  /// In en, this message translates to:
  /// **'Trade Licence'**
  String get offersDetailLabelTradeLicence;

  /// No description provided for @offersDetailLabelContactMobile.
  ///
  /// In en, this message translates to:
  /// **'Contact Person & Mobile'**
  String get offersDetailLabelContactMobile;

  /// No description provided for @offersDetailLabelBusinessEmail.
  ///
  /// In en, this message translates to:
  /// **'Business Email'**
  String get offersDetailLabelBusinessEmail;

  /// No description provided for @offersDetailLabelVendorRating.
  ///
  /// In en, this message translates to:
  /// **'Vendor Rating'**
  String get offersDetailLabelVendorRating;

  /// No description provided for @offersDetailDealsSuffix.
  ///
  /// In en, this message translates to:
  /// **' ({deals} deals completed)'**
  String offersDetailDealsSuffix(int deals);

  /// No description provided for @offersDetailParentRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Parent Request Reference'**
  String get offersDetailParentRequestTitle;

  /// No description provided for @offersDetailOpenRequest.
  ///
  /// In en, this message translates to:
  /// **'Open Request'**
  String get offersDetailOpenRequest;

  /// No description provided for @offersDetailNoParentRequest.
  ///
  /// In en, this message translates to:
  /// **'No parent request linked.'**
  String get offersDetailNoParentRequest;

  /// No description provided for @offersDetailLabelRequestReference.
  ///
  /// In en, this message translates to:
  /// **'Request Reference'**
  String get offersDetailLabelRequestReference;

  /// No description provided for @offersDetailLabelRequestType.
  ///
  /// In en, this message translates to:
  /// **'Request Type'**
  String get offersDetailLabelRequestType;

  /// No description provided for @offersDetailLabelCustomerMobile.
  ///
  /// In en, this message translates to:
  /// **'Customer Name & Mobile'**
  String get offersDetailLabelCustomerMobile;

  /// No description provided for @offersDetailLabelCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get offersDetailLabelCategory;

  /// No description provided for @offersDetailLabelRegion.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get offersDetailLabelRegion;

  /// No description provided for @offersDetailLabelIndicativeBudget.
  ///
  /// In en, this message translates to:
  /// **'Indicative Budget'**
  String get offersDetailLabelIndicativeBudget;

  /// No description provided for @offersDetailLabelRequestNotes.
  ///
  /// In en, this message translates to:
  /// **'Request Notes'**
  String get offersDetailLabelRequestNotes;

  /// No description provided for @offersDetailPricingTitle.
  ///
  /// In en, this message translates to:
  /// **'Pricing Breakdown'**
  String get offersDetailPricingTitle;

  /// No description provided for @offersDetailPricingGoldValue.
  ///
  /// In en, this message translates to:
  /// **'Gold Metal Value'**
  String get offersDetailPricingGoldValue;

  /// No description provided for @offersDetailPricingGoldHintRate.
  ///
  /// In en, this message translates to:
  /// **'Base gold price ({rate}/g)'**
  String offersDetailPricingGoldHintRate(String rate);

  /// No description provided for @offersDetailPricingGoldHint.
  ///
  /// In en, this message translates to:
  /// **'Base gold price component'**
  String get offersDetailPricingGoldHint;

  /// No description provided for @offersDetailPricingMaking.
  ///
  /// In en, this message translates to:
  /// **'Making / Crafting Charges'**
  String get offersDetailPricingMaking;

  /// No description provided for @offersDetailPricingMakingHint.
  ///
  /// In en, this message translates to:
  /// **'Labour and artistry charges'**
  String get offersDetailPricingMakingHint;

  /// No description provided for @offersDetailPricingVat.
  ///
  /// In en, this message translates to:
  /// **'Value Added Tax (VAT 5%)'**
  String get offersDetailPricingVat;

  /// No description provided for @offersDetailPricingVatHint.
  ///
  /// In en, this message translates to:
  /// **'UAE statutory tax'**
  String get offersDetailPricingVatHint;

  /// No description provided for @offersDetailPricingTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Offered Price'**
  String get offersDetailPricingTotal;

  /// No description provided for @offersDetailTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Commercial Terms, Notes & Attachments'**
  String get offersDetailTermsTitle;

  /// No description provided for @offersDetailLabelDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery / Readiness Timeframe'**
  String get offersDetailLabelDelivery;

  /// No description provided for @offersDetailDeliveryDefault.
  ///
  /// In en, this message translates to:
  /// **'Immediate dispatch / collection'**
  String get offersDetailDeliveryDefault;

  /// No description provided for @offersDetailLabelWarranty.
  ///
  /// In en, this message translates to:
  /// **'Warranty / Buy-Back Terms'**
  String get offersDetailLabelWarranty;

  /// No description provided for @offersDetailWarrantyDefault.
  ///
  /// In en, this message translates to:
  /// **'Standard UAE jeweller guarantee'**
  String get offersDetailWarrantyDefault;

  /// No description provided for @offersDetailLabelVendorNote.
  ///
  /// In en, this message translates to:
  /// **'Vendor Note'**
  String get offersDetailLabelVendorNote;

  /// No description provided for @offersDetailVendorNoteDefault.
  ///
  /// In en, this message translates to:
  /// **'No free-text note provided by vendor.'**
  String get offersDetailVendorNoteDefault;

  /// No description provided for @offersDetailLabelValidityExpiry.
  ///
  /// In en, this message translates to:
  /// **'Offer Validity & Expiry'**
  String get offersDetailLabelValidityExpiry;

  /// No description provided for @offersDetailValidityExpiryValue.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours · Expiry: {date}'**
  String offersDetailValidityExpiryValue(int hours, String date);

  /// No description provided for @offersDetailLabelDeclineReason.
  ///
  /// In en, this message translates to:
  /// **'Decline Reason'**
  String get offersDetailLabelDeclineReason;

  /// No description provided for @offersDetailAttachmentsCount.
  ///
  /// In en, this message translates to:
  /// **'Attachments & Certificates ({count})'**
  String offersDetailAttachmentsCount(int count);

  /// No description provided for @offersDetailNoAttachments.
  ///
  /// In en, this message translates to:
  /// **'No media files or certificates attached by vendor.'**
  String get offersDetailNoAttachments;

  /// No description provided for @offersDetailRevisionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Revisions History (FR-VEN-014)'**
  String get offersDetailRevisionsTitle;

  /// No description provided for @offersDetailRevisionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 revision} other{{count} revisions}}'**
  String offersDetailRevisionCount(int count);

  /// No description provided for @offersDetailNoRevisions.
  ///
  /// In en, this message translates to:
  /// **'Initial offer terms. No modifications were made pre-acceptance.'**
  String get offersDetailNoRevisions;

  /// No description provided for @offersDetailRevisionNumber.
  ///
  /// In en, this message translates to:
  /// **'Rev #{number}'**
  String offersDetailRevisionNumber(int number);

  /// No description provided for @offersDetailRevisionOffered.
  ///
  /// In en, this message translates to:
  /// **'Offered: {price}'**
  String offersDetailRevisionOffered(String price);

  /// No description provided for @offersDetailRevisionMakingSuffix.
  ///
  /// In en, this message translates to:
  /// **' (Making: {making})'**
  String offersDetailRevisionMakingSuffix(String making);

  /// No description provided for @offersDetailRevisionNote.
  ///
  /// In en, this message translates to:
  /// **'Note: {note}'**
  String offersDetailRevisionNote(String note);

  /// No description provided for @offersDetailTransitionsTitle.
  ///
  /// In en, this message translates to:
  /// **'State Transitions Timeline'**
  String get offersDetailTransitionsTitle;

  /// No description provided for @offersDetailNoTransitions.
  ///
  /// In en, this message translates to:
  /// **'Offer is in {state} state. No state transition audit recorded.'**
  String offersDetailNoTransitions(String state);

  /// No description provided for @offersDetailTransitionActor.
  ///
  /// In en, this message translates to:
  /// **'By: {actor}'**
  String offersDetailTransitionActor(String actor);

  /// No description provided for @offersDetailTransitionReason.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String offersDetailTransitionReason(String reason);

  /// No description provided for @offersDetailNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Internal Administrative Notes'**
  String get offersDetailNotesTitle;

  /// No description provided for @offersDetailNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Admin inspection notes are internal to Karat Hive. Commercial terms are read-only.'**
  String get offersDetailNotesSubtitle;

  /// No description provided for @offersDetailNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add an internal note about this offer…'**
  String get offersDetailNotesHint;

  /// No description provided for @offersDetailAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get offersDetailAddNote;

  /// No description provided for @offersDetailNoNotes.
  ///
  /// In en, this message translates to:
  /// **'No internal notes added yet.'**
  String get offersDetailNoNotes;

  /// No description provided for @offersDetailErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Failed to load offer details'**
  String get offersDetailErrorTitle;

  /// No description provided for @requestsListEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Marketplace Audit'**
  String get requestsListEyebrow;

  /// No description provided for @requestsListHeading.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requestsListHeading;

  /// No description provided for @requestsListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Platform requests oversight and inspection'**
  String get requestsListSubtitle;

  /// No description provided for @requestsFilterType.
  ///
  /// In en, this message translates to:
  /// **'Request Type'**
  String get requestsFilterType;

  /// No description provided for @requestsFilterAllTypes.
  ///
  /// In en, this message translates to:
  /// **'All Types'**
  String get requestsFilterAllTypes;

  /// No description provided for @requestsFilterDirection.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get requestsFilterDirection;

  /// No description provided for @requestsFilterAllDirections.
  ///
  /// In en, this message translates to:
  /// **'All Directions'**
  String get requestsFilterAllDirections;

  /// No description provided for @requestsFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get requestsFilterStatus;

  /// No description provided for @requestsFilterAllStates.
  ///
  /// In en, this message translates to:
  /// **'All States'**
  String get requestsFilterAllStates;

  /// No description provided for @requestsFilterSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get requestsFilterSearch;

  /// No description provided for @requestsFilterSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Reference, notes, customer…'**
  String get requestsFilterSearchHint;

  /// No description provided for @requestsFilterSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get requestsFilterSearchTooltip;

  /// No description provided for @requestsFilterZeroOffers.
  ///
  /// In en, this message translates to:
  /// **'Zero Offers'**
  String get requestsFilterZeroOffers;

  /// No description provided for @requestsColumnReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get requestsColumnReference;

  /// No description provided for @requestsColumnType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get requestsColumnType;

  /// No description provided for @requestsColumnDirection.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get requestsColumnDirection;

  /// No description provided for @requestsColumnCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get requestsColumnCustomer;

  /// No description provided for @requestsColumnCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get requestsColumnCategory;

  /// No description provided for @requestsColumnRegion.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get requestsColumnRegion;

  /// No description provided for @requestsColumnIndicativeValue.
  ///
  /// In en, this message translates to:
  /// **'Indicative Value'**
  String get requestsColumnIndicativeValue;

  /// No description provided for @requestsColumnOffers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get requestsColumnOffers;

  /// No description provided for @requestsColumnState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get requestsColumnState;

  /// No description provided for @requestsColumnDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get requestsColumnDate;

  /// No description provided for @requestsColumnAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get requestsColumnAction;

  /// No description provided for @requestsActionInspect.
  ///
  /// In en, this message translates to:
  /// **'Inspect'**
  String get requestsActionInspect;

  /// No description provided for @requestsLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get requestsLoadMore;

  /// No description provided for @requestsPaginationPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get requestsPaginationPrevious;

  /// No description provided for @requestsPaginationPage.
  ///
  /// In en, this message translates to:
  /// **'Page {page}'**
  String requestsPaginationPage(int page);

  /// No description provided for @requestsPaginationNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get requestsPaginationNext;

  /// No description provided for @requestsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No requests match the current filters.'**
  String get requestsEmptyBody;

  /// No description provided for @requestsRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get requestsRetry;

  /// No description provided for @requestsDetailBack.
  ///
  /// In en, this message translates to:
  /// **'Back to Requests'**
  String get requestsDetailBack;

  /// No description provided for @requestsDetailEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Request Oversight'**
  String get requestsDetailEyebrow;

  /// No description provided for @requestsDetailNoReference.
  ///
  /// In en, this message translates to:
  /// **'NO REFERENCE'**
  String get requestsDetailNoReference;

  /// No description provided for @requestsDetailPublishedAt.
  ///
  /// In en, this message translates to:
  /// **'Published {date} GST'**
  String requestsDetailPublishedAt(String date);

  /// No description provided for @requestsDetailCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created {date} GST'**
  String requestsDetailCreatedAt(String date);

  /// No description provided for @requestsDetailNoteAdded.
  ///
  /// In en, this message translates to:
  /// **'Note added successfully.'**
  String get requestsDetailNoteAdded;

  /// No description provided for @requestsDetailNoteAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add note: {error}'**
  String requestsDetailNoteAddFailed(String error);

  /// No description provided for @requestsDetailRemoveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request successfully removed.'**
  String get requestsDetailRemoveSuccess;

  /// No description provided for @requestsDetailRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove request: {error}'**
  String requestsDetailRemoveFailed(String error);

  /// No description provided for @requestsDetailRemovedTitle.
  ///
  /// In en, this message translates to:
  /// **'REQUEST REMOVED BY PLATFORM MODERATION (FR-ADM-019)'**
  String get requestsDetailRemovedTitle;

  /// No description provided for @requestsDetailRemovedReason.
  ///
  /// In en, this message translates to:
  /// **'Reason: {code} · {text}'**
  String requestsDetailRemovedReason(String code, String text);

  /// No description provided for @requestsDetailRemovedReasonCodeDefault.
  ///
  /// In en, this message translates to:
  /// **'POLICY_VIOLATION'**
  String get requestsDetailRemovedReasonCodeDefault;

  /// No description provided for @requestsDetailRemovedReasonTextDefault.
  ///
  /// In en, this message translates to:
  /// **'Violates platform trading guidelines'**
  String get requestsDetailRemovedReasonTextDefault;

  /// No description provided for @requestsDetailRemovedPolicyClause.
  ///
  /// In en, this message translates to:
  /// **'Policy clause cited: {clause}'**
  String requestsDetailRemovedPolicyClause(String clause);

  /// No description provided for @requestsDetailConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE CONNECTION ESTABLISHED'**
  String get requestsDetailConnectionTitle;

  /// No description provided for @requestsDetailConnectionParties.
  ///
  /// In en, this message translates to:
  /// **'Accepted Vendor: {vendor} · Customer: {customer}'**
  String requestsDetailConnectionParties(String vendor, String customer);

  /// No description provided for @requestsDetailConnectionMeta.
  ///
  /// In en, this message translates to:
  /// **'Connected at: {date} GST · Channel: {channel}'**
  String requestsDetailConnectionMeta(String date, String channel);

  /// No description provided for @requestsDetailConnectionChannelDefault.
  ///
  /// In en, this message translates to:
  /// **'WHATSAPP'**
  String get requestsDetailConnectionChannelDefault;

  /// No description provided for @requestsDetailWhatsappChannel.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Channel'**
  String get requestsDetailWhatsappChannel;

  /// No description provided for @requestsDetailSpecsTitle.
  ///
  /// In en, this message translates to:
  /// **'Commercial Requirements & Specifications'**
  String get requestsDetailSpecsTitle;

  /// No description provided for @requestsDetailSpecsReadOnly.
  ///
  /// In en, this message translates to:
  /// **'READ-ONLY FOR ADMIN (FR-ADM-018 AC3)'**
  String get requestsDetailSpecsReadOnly;

  /// No description provided for @requestsDetailLabelReferenceCode.
  ///
  /// In en, this message translates to:
  /// **'Reference Code'**
  String get requestsDetailLabelReferenceCode;

  /// No description provided for @requestsDetailLabelRequestType.
  ///
  /// In en, this message translates to:
  /// **'Request Type'**
  String get requestsDetailLabelRequestType;

  /// No description provided for @requestsDetailLabelMarketDirection.
  ///
  /// In en, this message translates to:
  /// **'Market Direction'**
  String get requestsDetailLabelMarketDirection;

  /// No description provided for @requestsDetailLabelCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get requestsDetailLabelCategory;

  /// No description provided for @requestsDetailLabelRegion.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get requestsDetailLabelRegion;

  /// No description provided for @requestsDetailLabelOrnamentType.
  ///
  /// In en, this message translates to:
  /// **'Ornament Type'**
  String get requestsDetailLabelOrnamentType;

  /// No description provided for @requestsDetailLabelPurityKarat.
  ///
  /// In en, this message translates to:
  /// **'Purity / Karat'**
  String get requestsDetailLabelPurityKarat;

  /// No description provided for @requestsDetailLabelWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get requestsDetailLabelWeight;

  /// No description provided for @requestsDetailLabelCondition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get requestsDetailLabelCondition;

  /// No description provided for @requestsDetailLabelDenomination.
  ///
  /// In en, this message translates to:
  /// **'Denomination'**
  String get requestsDetailLabelDenomination;

  /// No description provided for @requestsDetailLabelQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get requestsDetailLabelQuantity;

  /// No description provided for @requestsDetailLabelMintRefiner.
  ///
  /// In en, this message translates to:
  /// **'Mint / Refiner'**
  String get requestsDetailLabelMintRefiner;

  /// No description provided for @requestsDetailLabelIndicativeValue.
  ///
  /// In en, this message translates to:
  /// **'Indicative Value'**
  String get requestsDetailLabelIndicativeValue;

  /// No description provided for @requestsDetailLabelCustomerBudget.
  ///
  /// In en, this message translates to:
  /// **'Customer Budget'**
  String get requestsDetailLabelCustomerBudget;

  /// No description provided for @requestsDetailWeightApproximate.
  ///
  /// In en, this message translates to:
  /// **'{weight}g (Approximate)'**
  String requestsDetailWeightApproximate(String weight);

  /// No description provided for @requestsDetailWeightExact.
  ///
  /// In en, this message translates to:
  /// **'{weight}g (Exact)'**
  String requestsDetailWeightExact(String weight);

  /// No description provided for @requestsDetailQuantityUnits.
  ///
  /// In en, this message translates to:
  /// **'{quantity} units'**
  String requestsDetailQuantityUnits(int quantity);

  /// No description provided for @requestsDetailBudgetValue.
  ///
  /// In en, this message translates to:
  /// **'AED {min} – {max}'**
  String requestsDetailBudgetValue(String min, String max);

  /// No description provided for @requestsDetailBudgetValueFlexible.
  ///
  /// In en, this message translates to:
  /// **'AED {min} – {max} (Flexible)'**
  String requestsDetailBudgetValueFlexible(String min, String max);

  /// No description provided for @requestsDetailCustomerNotes.
  ///
  /// In en, this message translates to:
  /// **'Customer Notes:'**
  String get requestsDetailCustomerNotes;

  /// No description provided for @requestsDetailCustomerProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Unmasked Customer Profile'**
  String get requestsDetailCustomerProfileTitle;

  /// No description provided for @requestsDetailCustomerId.
  ///
  /// In en, this message translates to:
  /// **'Customer ID: {id}'**
  String requestsDetailCustomerId(String id);

  /// No description provided for @requestsDetailLabelMobilePhone.
  ///
  /// In en, this message translates to:
  /// **'Mobile Phone'**
  String get requestsDetailLabelMobilePhone;

  /// No description provided for @requestsDetailLabelEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get requestsDetailLabelEmailAddress;

  /// No description provided for @requestsDetailLabelMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get requestsDetailLabelMemberSince;

  /// No description provided for @requestsDetailMediaTitle.
  ///
  /// In en, this message translates to:
  /// **'Uploaded Media ({count})'**
  String requestsDetailMediaTitle(int count);

  /// No description provided for @requestsDetailNoMedia.
  ///
  /// In en, this message translates to:
  /// **'No media uploaded for this request.'**
  String get requestsDetailNoMedia;

  /// No description provided for @requestsDetailImageNumber.
  ///
  /// In en, this message translates to:
  /// **'Image #{number}'**
  String requestsDetailImageNumber(int number);

  /// No description provided for @requestsDetailOffersTitle.
  ///
  /// In en, this message translates to:
  /// **'Received Offers ({count})'**
  String requestsDetailOffersTitle(int count);

  /// No description provided for @requestsDetailNoOffers.
  ///
  /// In en, this message translates to:
  /// **'No offers submitted yet.'**
  String get requestsDetailNoOffers;

  /// No description provided for @requestsDetailOffersColumnVendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get requestsDetailOffersColumnVendor;

  /// No description provided for @requestsDetailOffersColumnPrice.
  ///
  /// In en, this message translates to:
  /// **'Offered Price'**
  String get requestsDetailOffersColumnPrice;

  /// No description provided for @requestsDetailOffersColumnStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get requestsDetailOffersColumnStatus;

  /// No description provided for @requestsDetailOffersColumnSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get requestsDetailOffersColumnSubmitted;

  /// No description provided for @requestsDetailOffersColumnTurnaround.
  ///
  /// In en, this message translates to:
  /// **'Turnaround'**
  String get requestsDetailOffersColumnTurnaround;

  /// No description provided for @requestsDetailOfferDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String requestsDetailOfferDays(int days);

  /// No description provided for @requestsDetailMatchedTitle.
  ///
  /// In en, this message translates to:
  /// **'Matched Vendors ({count})'**
  String requestsDetailMatchedTitle(int count);

  /// No description provided for @requestsDetailNoMatched.
  ///
  /// In en, this message translates to:
  /// **'No vendors matched to this request.'**
  String get requestsDetailNoMatched;

  /// No description provided for @requestsDetailMatchedAt.
  ///
  /// In en, this message translates to:
  /// **'Matched: {date}'**
  String requestsDetailMatchedAt(String date);

  /// No description provided for @requestsDetailViewed.
  ///
  /// In en, this message translates to:
  /// **'VIEWED'**
  String get requestsDetailViewed;

  /// No description provided for @requestsDetailNotViewed.
  ///
  /// In en, this message translates to:
  /// **'NOT VIEWED'**
  String get requestsDetailNotViewed;

  /// No description provided for @requestsDetailTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'State Transition History'**
  String get requestsDetailTimelineTitle;

  /// No description provided for @requestsDetailNoTransitions.
  ///
  /// In en, this message translates to:
  /// **'No recorded transitions.'**
  String get requestsDetailNoTransitions;

  /// No description provided for @requestsDetailTimelineBy.
  ///
  /// In en, this message translates to:
  /// **'by {actor}'**
  String requestsDetailTimelineBy(String actor);

  /// No description provided for @requestsDetailModerationTitle.
  ///
  /// In en, this message translates to:
  /// **'Platform Moderation'**
  String get requestsDetailModerationTitle;

  /// No description provided for @requestsDetailModerationBody.
  ///
  /// In en, this message translates to:
  /// **'Administrators can forcibly remove requests that violate platform trading policies (FR-ADM-019).'**
  String get requestsDetailModerationBody;

  /// No description provided for @requestsDetailAlreadyRemoved.
  ///
  /// In en, this message translates to:
  /// **'Request Already Removed'**
  String get requestsDetailAlreadyRemoved;

  /// No description provided for @requestsDetailRemoveRequest.
  ///
  /// In en, this message translates to:
  /// **'Remove Request'**
  String get requestsDetailRemoveRequest;

  /// No description provided for @requestsDetailNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Internal Notes ({count})'**
  String requestsDetailNotesTitle(int count);

  /// No description provided for @requestsDetailNoNotes.
  ///
  /// In en, this message translates to:
  /// **'No internal notes recorded.'**
  String get requestsDetailNoNotes;

  /// No description provided for @requestsDetailAddNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Internal Note'**
  String get requestsDetailAddNoteLabel;

  /// No description provided for @requestsDetailAddNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Record audit or compliance notes…'**
  String get requestsDetailAddNoteHint;

  /// No description provided for @requestsDetailAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get requestsDetailAddNote;

  /// No description provided for @requestsDetailRemoveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Request'**
  String get requestsDetailRemoveDialogTitle;

  /// No description provided for @requestsDetailRemoveDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Removing \"{reference}\" sets status to REMOVED, withdraws all pending offers, and notifies both parties.'**
  String requestsDetailRemoveDialogBody(String reference);

  /// No description provided for @requestsDetailRemoveReasonCode.
  ///
  /// In en, this message translates to:
  /// **'Reason Code'**
  String get requestsDetailRemoveReasonCode;

  /// No description provided for @requestsDetailRemoveReasonPolicyViolation.
  ///
  /// In en, this message translates to:
  /// **'Policy violation'**
  String get requestsDetailRemoveReasonPolicyViolation;

  /// No description provided for @requestsDetailRemoveReasonProhibitedItem.
  ///
  /// In en, this message translates to:
  /// **'Prohibited item / Contraband'**
  String get requestsDetailRemoveReasonProhibitedItem;

  /// No description provided for @requestsDetailRemoveReasonFraudulent.
  ///
  /// In en, this message translates to:
  /// **'Fraudulent or misleading listing'**
  String get requestsDetailRemoveReasonFraudulent;

  /// No description provided for @requestsDetailRemoveReasonCustomerRequested.
  ///
  /// In en, this message translates to:
  /// **'Customer requested cancellation'**
  String get requestsDetailRemoveReasonCustomerRequested;

  /// No description provided for @requestsDetailRemoveReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other administrative reason'**
  String get requestsDetailRemoveReasonOther;

  /// No description provided for @requestsDetailRemovePolicyClauseLabel.
  ///
  /// In en, this message translates to:
  /// **'Policy Clause (cited to customer)'**
  String get requestsDetailRemovePolicyClauseLabel;

  /// No description provided for @requestsDetailRemovePolicyClauseHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Terms of Service §4.2'**
  String get requestsDetailRemovePolicyClauseHint;

  /// No description provided for @requestsDetailRemoveJustificationLabel.
  ///
  /// In en, this message translates to:
  /// **'Detailed Justification & Notes'**
  String get requestsDetailRemoveJustificationLabel;

  /// No description provided for @requestsDetailRemoveJustificationHint.
  ///
  /// In en, this message translates to:
  /// **'State reason for audit log…'**
  String get requestsDetailRemoveJustificationHint;

  /// No description provided for @requestsDetailRemoveJustificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Detailed justification is required.'**
  String get requestsDetailRemoveJustificationRequired;

  /// No description provided for @requestsDetailConfirmRemoval.
  ///
  /// In en, this message translates to:
  /// **'Confirm Removal'**
  String get requestsDetailConfirmRemoval;

  /// No description provided for @requestsDetailErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get requestsDetailErrorRetry;

  /// No description provided for @reportsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'BUSINESS INTELLIGENCE'**
  String get reportsEyebrow;

  /// No description provided for @reportsHeading.
  ///
  /// In en, this message translates to:
  /// **'Platform Analytics & Reports'**
  String get reportsHeading;

  /// No description provided for @reportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Operational reports over a date range, filtered by Region and Category.'**
  String get reportsSubtitle;

  /// No description provided for @reportsIndicativeNote.
  ///
  /// In en, this message translates to:
  /// **'Figures are indicative operational metrics, not settlement or GMV. Settlement happens off-platform. Units: AED, grams, karat/fineness. Timestamps display as Gulf Standard Time.'**
  String get reportsIndicativeNote;

  /// No description provided for @reportsTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Report type'**
  String get reportsTypeLabel;

  /// No description provided for @reportsTypeAcquisition.
  ///
  /// In en, this message translates to:
  /// **'Customer acquisition & retention'**
  String get reportsTypeAcquisition;

  /// No description provided for @reportsTypeVendorLeague.
  ///
  /// In en, this message translates to:
  /// **'Vendor performance league'**
  String get reportsTypeVendorLeague;

  /// No description provided for @reportsTypeRequestVolume.
  ///
  /// In en, this message translates to:
  /// **'Request volume'**
  String get reportsTypeRequestVolume;

  /// No description provided for @reportsTypeOfferCompetitiveness.
  ///
  /// In en, this message translates to:
  /// **'Offer competitiveness'**
  String get reportsTypeOfferCompetitiveness;

  /// No description provided for @reportsTypeFunnel.
  ///
  /// In en, this message translates to:
  /// **'Funnel conversion'**
  String get reportsTypeFunnel;

  /// No description provided for @reportsTypeLiquidityGaps.
  ///
  /// In en, this message translates to:
  /// **'Liquidity gaps'**
  String get reportsTypeLiquidityGaps;

  /// No description provided for @reportsTypeRatingDistribution.
  ///
  /// In en, this message translates to:
  /// **'Rating distribution'**
  String get reportsTypeRatingDistribution;

  /// No description provided for @reportsFrom.
  ///
  /// In en, this message translates to:
  /// **'From (YYYY-MM-DD)'**
  String get reportsFrom;

  /// No description provided for @reportsTo.
  ///
  /// In en, this message translates to:
  /// **'To (YYYY-MM-DD)'**
  String get reportsTo;

  /// No description provided for @reportsRegionId.
  ///
  /// In en, this message translates to:
  /// **'Region ID (optional)'**
  String get reportsRegionId;

  /// No description provided for @reportsCategoryId.
  ///
  /// In en, this message translates to:
  /// **'Category ID (optional)'**
  String get reportsCategoryId;

  /// No description provided for @reportsApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get reportsApply;

  /// No description provided for @reportsEmptyPeriod.
  ///
  /// In en, this message translates to:
  /// **'No rows for this period. Try a different date range, Region, or Category.'**
  String get reportsEmptyPeriod;

  /// No description provided for @reportsEmptyChart.
  ///
  /// In en, this message translates to:
  /// **'No chart data for this period.'**
  String get reportsEmptyChart;

  /// No description provided for @reportsRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get reportsRetry;

  /// No description provided for @reportsExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get reportsExportCsv;

  /// No description provided for @reportsExportXlsx.
  ///
  /// In en, this message translates to:
  /// **'Export XLSX'**
  String get reportsExportXlsx;

  /// No description provided for @reportsExportPng.
  ///
  /// In en, this message translates to:
  /// **'Export chart PNG'**
  String get reportsExportPng;

  /// No description provided for @reportsExportPurposeTitle.
  ///
  /// In en, this message translates to:
  /// **'Export purpose'**
  String get reportsExportPurposeTitle;

  /// No description provided for @reportsExportPurposeHint.
  ///
  /// In en, this message translates to:
  /// **'Required for the audit watermark (admin, timestamp, purpose).'**
  String get reportsExportPurposeHint;

  /// No description provided for @reportsExportPurposeLabel.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get reportsExportPurposeLabel;

  /// No description provided for @reportsExportPurposeRequired.
  ///
  /// In en, this message translates to:
  /// **'Purpose is required.'**
  String get reportsExportPurposeRequired;

  /// No description provided for @reportsExportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Start export'**
  String get reportsExportConfirm;

  /// No description provided for @reportsExportCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get reportsExportCancel;

  /// No description provided for @reportsExportAsyncNotice.
  ///
  /// In en, this message translates to:
  /// **'Exports over 50,000 rows are generated asynchronously and delivered as a time-limited download link. Personal-data exports are watermarked with admin, time, and purpose (NFR-016).'**
  String get reportsExportAsyncNotice;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
