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
  /// **'Indicative sample figures. The admin dashboard endpoint (GET /v1/admin/dashboard) is not implemented yet — no number below reflects live platform data.'**
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

  /// No description provided for @vendorsDetailStubBody.
  ///
  /// In en, this message translates to:
  /// **'Full vendor inspection (ADM-S06) is scheduled for a later milestone.'**
  String get vendorsDetailStubBody;

  /// No description provided for @vendorsDetailVendorId.
  ///
  /// In en, this message translates to:
  /// **'Vendor ID: {id}'**
  String vendorsDetailVendorId(String id);

  /// No description provided for @vendorsDetailComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Account actions and document review will appear here.'**
  String get vendorsDetailComingSoon;

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
