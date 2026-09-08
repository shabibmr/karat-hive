import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of KhL10n
/// returned by `KhL10n.of(context)`.
///
/// Applications need to include `KhL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: KhL10n.localizationsDelegates,
///   supportedLocales: KhL10n.supportedLocales,
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
/// be consistent with the languages listed in the KhL10n.supportedLocales
/// property.
abstract class KhL10n {
  KhL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static KhL10n of(BuildContext context) {
    return Localizations.of<KhL10n>(context, KhL10n)!;
  }

  static const LocalizationsDelegate<KhL10n> delegate = _KhL10nDelegate();

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

  /// Application name, shown in the shell app bar
  ///
  /// In en, this message translates to:
  /// **'Karat Hive'**
  String get appTitle;

  /// Customer bottom-nav: Home / Requests tab (CUS-S02)
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Customer bottom-nav: Notifications tab (CUS-S19)
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// Customer bottom-nav: Profile tab (CUS-S20)
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Connections destination label (CUS-S16)
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get navConnections;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// No description provided for @commonLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get commonLogout;

  /// No description provided for @commonEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get commonEmpty;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Create a vendor account'**
  String get authRegister;

  /// No description provided for @authMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get authMobile;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Business email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get authSendCode;

  /// No description provided for @authResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get authResendCode;

  /// No description provided for @authEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get authEnterCode;

  /// No description provided for @authVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authVerify;

  /// No description provided for @authOtpTab.
  ///
  /// In en, this message translates to:
  /// **'Mobile & code'**
  String get authOtpTab;

  /// No description provided for @authPasswordTab.
  ///
  /// In en, this message translates to:
  /// **'Email & password'**
  String get authPasswordTab;

  /// No description provided for @authGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authGoogle;

  /// No description provided for @onboardingAwaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification in progress'**
  String get onboardingAwaitingTitle;

  /// No description provided for @onboardingPendingDocuments.
  ///
  /// In en, this message translates to:
  /// **'Upload your business documents to continue.'**
  String get onboardingPendingDocuments;

  /// No description provided for @onboardingPendingAdmin.
  ///
  /// In en, this message translates to:
  /// **'Our team is reviewing your documents.'**
  String get onboardingPendingAdmin;

  /// No description provided for @onboardingCategoriesRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose the categories and regions you serve.'**
  String get onboardingCategoriesRequired;

  /// No description provided for @onboardingRejected.
  ///
  /// In en, this message translates to:
  /// **'Your application needs changes.'**
  String get onboardingRejected;

  /// No description provided for @onboardingUploadKyc.
  ///
  /// In en, this message translates to:
  /// **'Upload documents'**
  String get onboardingUploadKyc;

  /// No description provided for @onboardingResubmit.
  ///
  /// In en, this message translates to:
  /// **'Resubmit for review'**
  String get onboardingResubmit;

  /// No description provided for @onboardingCategoriesRegions.
  ///
  /// In en, this message translates to:
  /// **'Categories & regions'**
  String get onboardingCategoriesRegions;

  /// No description provided for @onboardingSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get onboardingSave;

  /// No description provided for @onboardingAwayMode.
  ///
  /// In en, this message translates to:
  /// **'Away mode'**
  String get onboardingAwayMode;

  /// No description provided for @onboardingAwayModeHint.
  ///
  /// In en, this message translates to:
  /// **'Pause new-request notifications without deactivating.'**
  String get onboardingAwayModeHint;

  /// No description provided for @onboardingVolumePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Matched-request volume will appear once matching is live.'**
  String get onboardingVolumePlaceholder;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get dashboardRating;

  /// No description provided for @dashboardNoReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get dashboardNoReviews;

  /// No description provided for @dashboardGoldRates.
  ///
  /// In en, this message translates to:
  /// **'Reference gold rates'**
  String get dashboardGoldRates;

  /// No description provided for @dashboardGoldRatesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Reference rates unavailable'**
  String get dashboardGoldRatesUnavailable;

  /// No description provided for @dashboardSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Type subscriptions'**
  String get dashboardSubscriptions;

  /// No description provided for @dashboardNoSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'No type subscriptions yet'**
  String get dashboardNoSubscriptions;

  /// No description provided for @dashboardNewRequests.
  ///
  /// In en, this message translates to:
  /// **'New requests'**
  String get dashboardNewRequests;

  /// No description provided for @dashboardPendingOffers.
  ///
  /// In en, this message translates to:
  /// **'Pending offers'**
  String get dashboardPendingOffers;

  /// No description provided for @dashboardActiveConnections.
  ///
  /// In en, this message translates to:
  /// **'Active connections'**
  String get dashboardActiveConnections;

  /// No description provided for @lifecycleRegistered.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get lifecycleRegistered;

  /// No description provided for @lifecyclePendingVerification.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get lifecyclePendingVerification;

  /// No description provided for @lifecycleVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get lifecycleVerified;

  /// No description provided for @lifecycleActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get lifecycleActive;

  /// No description provided for @lifecycleSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get lifecycleSuspended;

  /// No description provided for @lifecycleRejected.
  ///
  /// In en, this message translates to:
  /// **'Needs changes'**
  String get lifecycleRejected;

  /// No description provided for @lifecycleDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Deactivated'**
  String get lifecycleDeactivated;

  /// No description provided for @lifecycleUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get lifecycleUnknown;

  /// No description provided for @customerRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get customerRequestsTitle;

  /// No description provided for @customerRequestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You have no active requests. Start one to receive offers.'**
  String get customerRequestsEmpty;

  /// No description provided for @customerNewRequest.
  ///
  /// In en, this message translates to:
  /// **'New request'**
  String get customerNewRequest;

  /// No description provided for @customerOffersTitle.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get customerOffersTitle;

  /// No description provided for @customerNotificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get customerNotificationsEmpty;

  /// No description provided for @customerProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get customerProfileTitle;

  /// No description provided for @authWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Karat Hive'**
  String get authWelcomeTitle;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Request gold your way — buy ornaments, sell old gold, or order coins and bullion. Sign in to get started.'**
  String get authWelcomeSubtitle;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get authSigningIn;

  /// No description provided for @authSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. Check your connection and try again.'**
  String get authSignInFailed;

  /// No description provided for @authBiometricUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock with biometrics'**
  String get authBiometricUnlock;

  /// No description provided for @authBiometricUnlockHint.
  ///
  /// In en, this message translates to:
  /// **'Use Face ID or fingerprint on this device instead of signing in again.'**
  String get authBiometricUnlockHint;

  /// No description provided for @authLockoutTitle.
  ///
  /// In en, this message translates to:
  /// **'You can\'t sign in'**
  String get authLockoutTitle;

  /// No description provided for @authLockoutHelp.
  ///
  /// In en, this message translates to:
  /// **'Contact support if you think this is a mistake.'**
  String get authLockoutHelp;

  /// No description provided for @authCompleteProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish setting up your account'**
  String get authCompleteProfileTitle;

  /// No description provided for @authCompleteProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One more step. Confirm your name and verify a mobile number so vendors can reach you on WhatsApp.'**
  String get authCompleteProfileSubtitle;

  /// No description provided for @authDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get authDisplayNameLabel;

  /// No description provided for @authOtpSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {mobile}'**
  String authOtpSentTo(String mobile);

  /// No description provided for @authAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'I accept the Terms of Service and the Privacy Policy'**
  String get authAcceptTerms;

  /// No description provided for @authAcceptTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'Accept the Terms of Service and Privacy Policy to continue.'**
  String get authAcceptTermsRequired;

  /// No description provided for @authViewTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get authViewTerms;

  /// No description provided for @authViewPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get authViewPrivacy;

  /// No description provided for @authChangeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get authChangeNumber;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authVerifyAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify and continue'**
  String get authVerifyAndContinue;

  /// No description provided for @authPublishGateTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify with Google to publish'**
  String get authPublishGateTitle;

  /// No description provided for @authPublishGateBody.
  ///
  /// In en, this message translates to:
  /// **'Publishing a request needs a one-time Google verification. Browsing and drafting a request do not.'**
  String get authPublishGateBody;

  /// No description provided for @authPublishGateAction.
  ///
  /// In en, this message translates to:
  /// **'Verify with Google'**
  String get authPublishGateAction;
}

class _KhL10nDelegate extends LocalizationsDelegate<KhL10n> {
  const _KhL10nDelegate();

  @override
  Future<KhL10n> load(Locale locale) {
    return SynchronousFuture<KhL10n>(lookupKhL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_KhL10nDelegate old) => false;
}

KhL10n lookupKhL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return KhL10nAr();
    case 'en':
      return KhL10nEn();
  }

  throw FlutterError(
    'KhL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
