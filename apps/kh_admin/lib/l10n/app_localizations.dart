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
