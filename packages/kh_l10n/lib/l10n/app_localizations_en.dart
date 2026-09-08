// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class KhL10nEn extends KhL10n {
  KhL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Karat Hive';

  @override
  String get navHome => 'Home';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navProfile => 'Profile';

  @override
  String get navConnections => 'Connections';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonLogout => 'Log out';

  @override
  String get commonEmpty => 'Nothing here yet';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonClose => 'Close';

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
  String get authGoogle => 'Continue with Google';

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
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardRating => 'Rating';

  @override
  String get dashboardNoReviews => 'No reviews yet';

  @override
  String get dashboardGoldRates => 'Reference gold rates';

  @override
  String get dashboardGoldRatesUnavailable => 'Reference rates unavailable';

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
  String get customerRequestsTitle => 'My Requests';

  @override
  String get customerRequestsEmpty =>
      'You have no active requests. Start one to receive offers.';

  @override
  String get customerNewRequest => 'New request';

  @override
  String get customerOffersTitle => 'Offers';

  @override
  String get customerNotificationsEmpty => 'No notifications yet.';

  @override
  String get customerProfileTitle => 'Profile';

  @override
  String get authWelcomeTitle => 'Welcome to Karat Hive';

  @override
  String get authWelcomeSubtitle =>
      'Request gold your way — buy ornaments, sell old gold, or order coins and bullion. Sign in to get started.';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authSigningIn => 'Signing in…';

  @override
  String get authSignInFailed =>
      'Could not sign in. Check your connection and try again.';

  @override
  String get authBiometricUnlock => 'Unlock with biometrics';

  @override
  String get authBiometricUnlockHint =>
      'Use Face ID or fingerprint on this device instead of signing in again.';

  @override
  String get authLockoutTitle => 'You can\'t sign in';

  @override
  String get authLockoutHelp =>
      'Contact support if you think this is a mistake.';

  @override
  String get authCompleteProfileTitle => 'Finish setting up your account';

  @override
  String get authCompleteProfileSubtitle =>
      'One more step. Confirm your name and verify a mobile number so vendors can reach you on WhatsApp.';

  @override
  String get authDisplayNameLabel => 'Your name';

  @override
  String authOtpSentTo(String mobile) {
    return 'We sent a 6-digit code to $mobile';
  }

  @override
  String get authAcceptTerms =>
      'I accept the Terms of Service and the Privacy Policy';

  @override
  String get authAcceptTermsRequired =>
      'Accept the Terms of Service and Privacy Policy to continue.';

  @override
  String get authViewTerms => 'Terms of Service';

  @override
  String get authViewPrivacy => 'Privacy Policy';

  @override
  String get authChangeNumber => 'Change number';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authVerifyAndContinue => 'Verify and continue';

  @override
  String get authPublishGateTitle => 'Verify with Google to publish';

  @override
  String get authPublishGateBody =>
      'Publishing a request needs a one-time Google verification. Browsing and drafting a request do not.';

  @override
  String get authPublishGateAction => 'Verify with Google';
}
