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
    Locale('en'),
    Locale('ar'),
  ];

  /// VEN-S07 filter sheet title
  ///
  /// In en, this message translates to:
  /// **'Filter Requests'**
  String get filterRequests;

  /// VEN-S07 clear all draft filters
  ///
  /// In en, this message translates to:
  /// **'Reset All'**
  String get resetAll;

  /// VEN-S07 includeResponded toggle label
  ///
  /// In en, this message translates to:
  /// **'Include already responded requests'**
  String get includeAlreadyResponded;

  /// VEN-S07 apply draft filters CTA
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// VEN-S07 sort section heading
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// VEN-S07 request-type section heading
  ///
  /// In en, this message translates to:
  /// **'Request Type'**
  String get requestType;

  /// VEN-S07 saved presets section heading
  ///
  /// In en, this message translates to:
  /// **'Filter Presets'**
  String get filterPresets;

  /// VEN-S07 empty presets copy
  ///
  /// In en, this message translates to:
  /// **'No saved presets yet.'**
  String get noSavedPresetsYet;

  /// VEN-S07 save preset action
  ///
  /// In en, this message translates to:
  /// **'Save current filters as preset'**
  String get saveCurrentFiltersAsPreset;

  /// VEN-S22 app bar title
  ///
  /// In en, this message translates to:
  /// **'Subscriptions & Entitlements'**
  String get subscriptionsTitle;

  /// VEN-S22 BR-002 entitlement banner
  ///
  /// In en, this message translates to:
  /// **'Each request category requires an active type subscription to receive matches and submit offers (BR-002).'**
  String get subscriptionsRequirementBanner;

  /// VEN-S22 section heading above type cards
  ///
  /// In en, this message translates to:
  /// **'Category Entitlements'**
  String get categoryEntitlements;

  /// VEN-S22 deep-link CTA (AD-API-04)
  ///
  /// In en, this message translates to:
  /// **'Manage Subscriptions / Contact Support'**
  String get manageSubscriptionsContact;

  /// VEN-S22 footnote under contact CTA
  ///
  /// In en, this message translates to:
  /// **'Subscription changes are handled by Karat Hive account management.'**
  String get subscriptionChangesHandled;

  /// VEN-S22 NONE entitlement state copy
  ///
  /// In en, this message translates to:
  /// **'No active subscription. You will not receive matches for this category.'**
  String get noActiveSubscription;

  /// SnackBar when subscription contact deep link fails
  ///
  /// In en, this message translates to:
  /// **'Could not open {url}'**
  String couldNotOpenUrl(String url);
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
