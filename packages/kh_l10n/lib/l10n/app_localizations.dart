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

  /// VEN-S06 app bar title
  ///
  /// In en, this message translates to:
  /// **'Available Requests'**
  String get availableRequestsTitle;

  /// VEN-S06 initial load error
  ///
  /// In en, this message translates to:
  /// **'Failed to load matching requests.'**
  String get failedToLoadMatchingRequests;

  /// VEN-S06 empty feed title
  ///
  /// In en, this message translates to:
  /// **'No Matching Requests'**
  String get noMatchingRequests;

  /// VEN-S06 empty feed copy when filters active
  ///
  /// In en, this message translates to:
  /// **'Try resetting your active filters to see more requests.'**
  String get emptyFeedResetFiltersHint;

  /// VEN-S06 empty feed copy when no filters
  ///
  /// In en, this message translates to:
  /// **'Broaden your Categories and Regions, or check that you have an active Type Subscription for the request types you want to see.'**
  String get emptyFeedBroadenHint;

  /// VEN-S06 empty-state reset filters CTA
  ///
  /// In en, this message translates to:
  /// **'Reset Filters'**
  String get resetFilters;

  /// VEN-S06 empty-state subscriptions CTA
  ///
  /// In en, this message translates to:
  /// **'View Subscriptions'**
  String get viewSubscriptions;

  /// VEN-S06 end-of-list sentinel
  ///
  /// In en, this message translates to:
  /// **'You are all caught up'**
  String get allCaughtUp;

  /// VEN-S08 app bar title with request id
  ///
  /// In en, this message translates to:
  /// **'Request {requestId}'**
  String requestTitleWithId(String requestId);

  /// VEN-S08 detail load error
  ///
  /// In en, this message translates to:
  /// **'Could not load request details.'**
  String get couldNotLoadRequestDetails;

  /// VEN-S08 title when reference is null
  ///
  /// In en, this message translates to:
  /// **'Request Details'**
  String get requestDetailsFallback;

  /// VEN-S08 masked customer card heading
  ///
  /// In en, this message translates to:
  /// **'Customer Summary'**
  String get customerSummary;

  /// VEN-S08 notes card heading
  ///
  /// In en, this message translates to:
  /// **'Customer Notes'**
  String get customerNotes;

  /// VEN-S08 offer count summary (BR-008)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} offer received} other{{count} offers received}}'**
  String offersReceived(int count);

  /// VEN-S08 BR-008 subtitle under offer count
  ///
  /// In en, this message translates to:
  /// **'Competitor pricing and terms are hidden per marketplace rules.'**
  String get competitorPricingHidden;

  /// VEN-S08 disabled CTA when request expired
  ///
  /// In en, this message translates to:
  /// **'Request Expired'**
  String get requestExpired;

  /// VEN-S08 disabled CTA when request closed
  ///
  /// In en, this message translates to:
  /// **'Request Closed'**
  String get requestClosed;

  /// Deprecated CP-3 placeholder; prefer makeAnOffer
  ///
  /// In en, this message translates to:
  /// **'Make an Offer (CP-3)'**
  String get makeAnOfferCp3;

  /// Deprecated CP-3 snackbar
  ///
  /// In en, this message translates to:
  /// **'Bidding opens in Check-Point 3.'**
  String get biddingOpensCp3;

  /// VEN-S08 primary CTA to open VEN-S09
  ///
  /// In en, this message translates to:
  /// **'Make an Offer'**
  String get makeAnOffer;

  /// VEN-S11 screen title
  ///
  /// In en, this message translates to:
  /// **'My Offers'**
  String get myOffersTitle;

  /// VEN-S09 screen title
  ///
  /// In en, this message translates to:
  /// **'Submit Offer'**
  String get submitOfferTitle;

  /// VEN-S10 screen title
  ///
  /// In en, this message translates to:
  /// **'Revise Offer'**
  String get reviseOfferTitle;

  /// VEN-S09 submit button
  ///
  /// In en, this message translates to:
  /// **'Submit Offer'**
  String get submitOfferAction;

  /// VEN-S10 revise button
  ///
  /// In en, this message translates to:
  /// **'Save revision'**
  String get reviseOfferAction;

  /// VEN-S10 withdraw button
  ///
  /// In en, this message translates to:
  /// **'Withdraw Offer'**
  String get withdrawOfferAction;

  /// VEN-S10 withdraw confirm dialog title
  ///
  /// In en, this message translates to:
  /// **'Withdraw this Offer?'**
  String get withdrawOfferConfirmTitle;

  /// VEN-S10 withdraw confirm dialog body
  ///
  /// In en, this message translates to:
  /// **'You can submit a new Offer afterwards if the Request is still open.'**
  String get withdrawOfferConfirmBody;

  /// VEN-S11 PENDING tab
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get offerTabPending;

  /// VEN-S11 ACCEPTED tab
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get offerTabAccepted;

  /// VEN-S11 CLOSED tab
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get offerTabClosed;

  /// No description provided for @offerStatePending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get offerStatePending;

  /// No description provided for @offerStateAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get offerStateAccepted;

  /// No description provided for @offerStateRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get offerStateRejected;

  /// No description provided for @offerStateExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get offerStateExpired;

  /// No description provided for @offerStateWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get offerStateWithdrawn;

  /// No description provided for @offerStateUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get offerStateUnknown;

  /// No description provided for @offerFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get offerFallbackTitle;

  /// VEN-S11 CLOSED tab BR-008 safe notice
  ///
  /// In en, this message translates to:
  /// **'This Request was awarded elsewhere.'**
  String get offerAwardedElsewhere;

  /// VEN-S11 accepted row stub until CP-4
  ///
  /// In en, this message translates to:
  /// **'Connection opens in Check-Point 4.'**
  String get offerConnectionCp4;

  /// No description provided for @offerSearchByReference.
  ///
  /// In en, this message translates to:
  /// **'Search by reference'**
  String get offerSearchByReference;

  /// No description provided for @offerValidityLabel.
  ///
  /// In en, this message translates to:
  /// **'Validity'**
  String get offerValidityLabel;

  /// No description provided for @offerValidityHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours'**
  String offerValidityHours(int hours);

  /// No description provided for @offerAbsoluteExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expires at {when}'**
  String offerAbsoluteExpiry(String when);

  /// No description provided for @offerPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Offered price'**
  String get offerPriceLabel;

  /// No description provided for @offerMakingChargesLabel.
  ///
  /// In en, this message translates to:
  /// **'Making charges (optional)'**
  String get offerMakingChargesLabel;

  /// No description provided for @offerRatePerGramLabel.
  ///
  /// In en, this message translates to:
  /// **'Rate per gram (optional)'**
  String get offerRatePerGramLabel;

  /// No description provided for @offerDeliveryLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery / readiness'**
  String get offerDeliveryLabel;

  /// No description provided for @offerWarrantyLabel.
  ///
  /// In en, this message translates to:
  /// **'Warranty / buy-back terms'**
  String get offerWarrantyLabel;

  /// No description provided for @offerNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (no contact details)'**
  String get offerNoteLabel;

  /// No description provided for @offerImagesHint.
  ///
  /// In en, this message translates to:
  /// **'Up to 3 supporting images (optional).'**
  String get offerImagesHint;

  /// No description provided for @offerCurrentTerms.
  ///
  /// In en, this message translates to:
  /// **'Current terms'**
  String get offerCurrentTerms;

  /// No description provided for @offerNewTerms.
  ///
  /// In en, this message translates to:
  /// **'New terms'**
  String get offerNewTerms;

  /// No description provided for @offerRevisionsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} revision remaining} other{{count} revisions remaining}}'**
  String offerRevisionsRemaining(int count);

  /// No description provided for @offersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No offers yet. Submit an Offer from a matched Request.'**
  String get offersEmptyBody;

  /// No description provided for @couldNotLoadOffers.
  ///
  /// In en, this message translates to:
  /// **'Could not load offers.'**
  String get couldNotLoadOffers;

  /// No description provided for @couldNotLoadRequest.
  ///
  /// In en, this message translates to:
  /// **'Could not load request.'**
  String get couldNotLoadRequest;

  /// No description provided for @couldNotLoadOffer.
  ///
  /// In en, this message translates to:
  /// **'Could not load offer.'**
  String get couldNotLoadOffer;

  /// No description provided for @commonSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting…'**
  String get commonSubmitting;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// VEN-S05 dashboard load error
  ///
  /// In en, this message translates to:
  /// **'Could not load your dashboard.'**
  String get couldNotLoadDashboard;

  /// VEN-S05 new-requests card subtitle when count > 0
  ///
  /// In en, this message translates to:
  /// **'{count} matching request(s) waiting'**
  String matchingRequestsWaiting(int count);

  /// VEN-S05 new-requests card subtitle when empty
  ///
  /// In en, this message translates to:
  /// **'No new requests right now'**
  String get noNewRequestsRightNow;

  /// VEN-S05 preview section header
  ///
  /// In en, this message translates to:
  /// **'Latest matches'**
  String get latestMatches;

  /// VEN-S05 preview section action
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// VEN-S05 pending-offers urgency subtitle
  ///
  /// In en, this message translates to:
  /// **'{count} expiring within 24h'**
  String offersExpiringWithin24h(int count);

  /// VEN-S05 pending-offers default subtitle
  ///
  /// In en, this message translates to:
  /// **'Active bids awaiting customer response'**
  String get activeBidsAwaiting;

  /// VEN-S05 pending-offers disabled snackbar
  ///
  /// In en, this message translates to:
  /// **'Offer management opens in Check-Point 3'**
  String get offerManagementCp3;

  /// VEN-S05 connections urgency subtitle
  ///
  /// In en, this message translates to:
  /// **'{count} with no talk yet'**
  String connectionsNoTalkYet(int count);

  /// VEN-S05 connections default subtitle
  ///
  /// In en, this message translates to:
  /// **'Won deals & direct customer chats'**
  String get wonDealsChats;

  /// VEN-S05 connections disabled snackbar
  ///
  /// In en, this message translates to:
  /// **'Connections open in Check-Point 4'**
  String get connectionsOpenCp4;

  /// VEN-S05 subscriptions tile subtitle when entitlements exist
  ///
  /// In en, this message translates to:
  /// **'{count} active entitlement(s)'**
  String activeEntitlementsCount(int count);

  /// VEN-S07 sort chip NEWEST
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// VEN-S07 sort chip EXPIRING
  ///
  /// In en, this message translates to:
  /// **'Expiring Soon'**
  String get sortExpiringSoon;

  /// VEN-S07 sort chip HIGHEST_VALUE
  ///
  /// In en, this message translates to:
  /// **'Highest Value'**
  String get sortHighestValue;

  /// VEN-S07 sort chip FEWEST_OFFERS
  ///
  /// In en, this message translates to:
  /// **'Fewest Offers'**
  String get sortFewestOffers;

  /// FIND_ORNAMENT display name
  ///
  /// In en, this message translates to:
  /// **'Find Ornament'**
  String get requestTypeFindOrnament;

  /// CUSTOM_DESIGN display name
  ///
  /// In en, this message translates to:
  /// **'Custom Design'**
  String get requestTypeCustomDesign;

  /// BULLION short display name (filters)
  ///
  /// In en, this message translates to:
  /// **'Bullion'**
  String get requestTypeBullion;

  /// BULLION long display name (subscriptions)
  ///
  /// In en, this message translates to:
  /// **'Bullion & Investment'**
  String get requestTypeBullionInvestment;

  /// REPAIR_RESIZE display name
  ///
  /// In en, this message translates to:
  /// **'Repair & Resize'**
  String get requestTypeRepairResize;

  /// Shared category field label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// VEN-S07 categories load error
  ///
  /// In en, this message translates to:
  /// **'Could not load categories'**
  String get couldNotLoadCategories;

  /// VEN-S07 category dropdown null option
  ///
  /// In en, this message translates to:
  /// **'Any category'**
  String get anyCategory;

  /// Shared region field label
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// VEN-S07 regions load error
  ///
  /// In en, this message translates to:
  /// **'Could not load regions'**
  String get couldNotLoadRegions;

  /// VEN-S07 region dropdown null option
  ///
  /// In en, this message translates to:
  /// **'Any region'**
  String get anyRegion;

  /// VEN-S07 budget section heading
  ///
  /// In en, this message translates to:
  /// **'Budget (AED)'**
  String get budgetAed;

  /// VEN-S07 min budget field label
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get minLabel;

  /// VEN-S07 max budget field label
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get maxLabel;

  /// VEN-S07 purity section heading
  ///
  /// In en, this message translates to:
  /// **'Purity (Karat)'**
  String get purityKarat;

  /// VEN-S07 presets load error
  ///
  /// In en, this message translates to:
  /// **'Could not load presets'**
  String get couldNotLoadPresets;

  /// VEN-S07 save-preset dialog title
  ///
  /// In en, this message translates to:
  /// **'Save Filter Preset'**
  String get saveFilterPreset;

  /// VEN-S07 save-preset dialog hint
  ///
  /// In en, this message translates to:
  /// **'Preset name (e.g. Dubai 22K Rings)'**
  String get presetNameHint;

  /// Generic cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Generic save action
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// VEN-S22 subscriptions load error
  ///
  /// In en, this message translates to:
  /// **'Could not load subscription details.'**
  String get couldNotLoadSubscriptionDetails;

  /// VEN-S22 subscription card plan-rate label
  ///
  /// In en, this message translates to:
  /// **'Plan Rate:'**
  String get planRate;

  /// VEN-S22 monthly plan price
  ///
  /// In en, this message translates to:
  /// **'AED {price} / month'**
  String aedPerMonth(String price);

  /// VEN-S22 renewal date label
  ///
  /// In en, this message translates to:
  /// **'Next Renewal:'**
  String get nextRenewal;

  /// VEN-S22 GRACE state warning
  ///
  /// In en, this message translates to:
  /// **'Grace period active until {date}. Renew now to avoid losing matching eligibility.'**
  String gracePeriodActiveUntil(String date);

  /// VEN-S22 EXPIRED/LAPSED state copy
  ///
  /// In en, this message translates to:
  /// **'Subscription expired. Matching requests for this category are currently paused.'**
  String get subscriptionExpiredPaused;

  /// SH-REQ-01 responded marker on vendor request card
  ///
  /// In en, this message translates to:
  /// **'Responded'**
  String get responded;

  /// SH-REQ-01 offer count on vendor request card
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} offer} other{{count} offers}}'**
  String offerCountShort(int count);

  /// SH-REQ-01 budget lower-bound prefix
  ///
  /// In en, this message translates to:
  /// **'From '**
  String get budgetFrom;

  /// SH-REQ-01 budget upper-bound prefix
  ///
  /// In en, this message translates to:
  /// **'Up to '**
  String get budgetUpTo;

  /// SH-REQ-01 when no budget bounds
  ///
  /// In en, this message translates to:
  /// **'Open Budget'**
  String get openBudget;

  /// SH-REQ-01 card title when reference and category absent
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get requestFallback;

  /// VEN-S08 specification grid heading
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get specifications;

  /// Specification grid purity label
  ///
  /// In en, this message translates to:
  /// **'Purity'**
  String get purity;

  /// Specification grid weight label
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// Specification grid budget label
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// Specification grid type label
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// Specification grid direction label
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get direction;

  /// Specification grid notes label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Specification grid purity value
  ///
  /// In en, this message translates to:
  /// **'{karat}K Gold'**
  String karatGold(String karat);

  /// Specification grid exact weight value
  ///
  /// In en, this message translates to:
  /// **'{weight} g'**
  String weightGrams(String weight);

  /// Specification grid approximate weight value
  ///
  /// In en, this message translates to:
  /// **'{weight} g (approx)'**
  String weightGramsApprox(String weight);

  /// Specification grid budget range
  ///
  /// In en, this message translates to:
  /// **'AED {min} - {max}'**
  String budgetRangeAed(String min, String max);

  /// Specification grid flexible budget range
  ///
  /// In en, this message translates to:
  /// **'AED {min} - {max} (flex)'**
  String budgetRangeAedFlex(String min, String max);

  /// Specification grid min-only budget
  ///
  /// In en, this message translates to:
  /// **'From AED {amount}'**
  String budgetFromAed(String amount);

  /// Specification grid max-only budget
  ///
  /// In en, this message translates to:
  /// **'Up to AED {amount}'**
  String budgetUpToAed(String amount);

  /// Specification grid open budget value
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get budgetOpen;

  /// VEN-S05 app bar title (KhStrings migration)
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// VEN-S05 rating tile title
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get dashboardRating;

  /// VEN-S05 rating empty subtitle
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get dashboardNoReviews;

  /// VEN-S05 gold rates tile title
  ///
  /// In en, this message translates to:
  /// **'Reference gold rates'**
  String get dashboardGoldRates;

  /// VEN-S05 subscriptions tile title
  ///
  /// In en, this message translates to:
  /// **'Type subscriptions'**
  String get dashboardSubscriptions;

  /// VEN-S05 subscriptions empty subtitle
  ///
  /// In en, this message translates to:
  /// **'No type subscriptions yet'**
  String get dashboardNoSubscriptions;

  /// VEN-S05 new-requests panel label
  ///
  /// In en, this message translates to:
  /// **'New requests'**
  String get dashboardNewRequests;

  /// VEN-S05 pending-offers panel label
  ///
  /// In en, this message translates to:
  /// **'Pending offers'**
  String get dashboardPendingOffers;

  /// VEN-S05 active-connections panel label
  ///
  /// In en, this message translates to:
  /// **'Active connections'**
  String get dashboardActiveConnections;

  /// Generic empty-state message
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get commonEmpty;

  /// Generic retry action
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// Generic log-out action
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get commonLogout;

  /// Mobile app title
  ///
  /// In en, this message translates to:
  /// **'Karat Hive'**
  String get appTitle;

  /// VEN-S01 sign-in title / primary CTA
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// VEN-S01 link to vendor registration
  ///
  /// In en, this message translates to:
  /// **'Create a vendor account'**
  String get authRegister;

  /// VEN-S01 mobile field label
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get authMobile;

  /// VEN-S01 email field label
  ///
  /// In en, this message translates to:
  /// **'Business email'**
  String get authEmail;

  /// VEN-S01 password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// VEN-S01 OTP request CTA
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get authSendCode;

  /// VEN-S01 OTP resend CTA
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get authResendCode;

  /// VEN-S01 OTP entry hint
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get authEnterCode;

  /// VEN-S01 OTP verify CTA
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authVerify;

  /// VEN-S01 OTP tab label
  ///
  /// In en, this message translates to:
  /// **'Mobile & code'**
  String get authOtpTab;

  /// VEN-S01 password tab label
  ///
  /// In en, this message translates to:
  /// **'Email & password'**
  String get authPasswordTab;

  /// VEN-S01 generic sign-in error
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. Check your connection and try again.'**
  String get authSignInFailed;

  /// VEN-S04 registration continue CTA
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authContinue;

  /// VEN-S04 link back to login
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authBackToSignIn;

  /// VEN-S04 OTP step instruction
  ///
  /// In en, this message translates to:
  /// **'We sent a code to your mobile number.'**
  String get authOtpSentMobile;

  /// VEN-S04 OTP verify CTA
  ///
  /// In en, this message translates to:
  /// **'Verify & create account'**
  String get authVerifyAndCreateAccount;

  /// VEN-S04 registration error fallback
  ///
  /// In en, this message translates to:
  /// **'Registration failed.'**
  String get authRegistrationFailed;

  /// VEN-S04 legal business name field
  ///
  /// In en, this message translates to:
  /// **'Legal business name'**
  String get authLegalBusinessName;

  /// VEN-S04 trading name field
  ///
  /// In en, this message translates to:
  /// **'Trading name'**
  String get authTradingName;

  /// VEN-S04 trade licence number field
  ///
  /// In en, this message translates to:
  /// **'Trade licence number'**
  String get authTradeLicenceNumber;

  /// VEN-S04 licence expiry field
  ///
  /// In en, this message translates to:
  /// **'Licence expiry (YYYY-MM-DD)'**
  String get authLicenceExpiry;

  /// VEN-S04 business address field
  ///
  /// In en, this message translates to:
  /// **'Business address'**
  String get authBusinessAddress;

  /// VEN-S04 contact person field
  ///
  /// In en, this message translates to:
  /// **'Contact person'**
  String get authContactPerson;

  /// VEN-S04 home region picker heading
  ///
  /// In en, this message translates to:
  /// **'Home region'**
  String get authHomeRegion;

  /// VEN-S04 served categories heading
  ///
  /// In en, this message translates to:
  /// **'Categories you serve'**
  String get authCategoriesYouServe;

  /// VEN-S04 served regions heading
  ///
  /// In en, this message translates to:
  /// **'Regions you serve'**
  String get authRegionsYouServe;

  /// VEN-S01 Google Sign-In button label
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get authSignInWithGoogle;

  /// VEN-S01 Google Sign-In busy label
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get authSigningInWithGoogle;

  /// VEN-S01 Google Sign-In error snackbar
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In failed: {error}'**
  String authGoogleSignInFailed(String error);

  /// VEN-S03 awaiting-approval app bar title
  ///
  /// In en, this message translates to:
  /// **'Verification in progress'**
  String get onboardingAwaitingTitle;

  /// VEN-S03 reason when documents missing
  ///
  /// In en, this message translates to:
  /// **'Upload your business documents to continue.'**
  String get onboardingPendingDocuments;

  /// VEN-S03 reason while admin reviews
  ///
  /// In en, this message translates to:
  /// **'Our team is reviewing your documents.'**
  String get onboardingPendingAdmin;

  /// VEN-S03 reason when categories not set
  ///
  /// In en, this message translates to:
  /// **'Choose the categories and regions you serve.'**
  String get onboardingCategoriesRequired;

  /// VEN-S03 reason when verification rejected
  ///
  /// In en, this message translates to:
  /// **'Your application needs changes.'**
  String get onboardingRejected;

  /// VEN-S02 / VEN-S03 KYC upload CTA and title
  ///
  /// In en, this message translates to:
  /// **'Upload documents'**
  String get onboardingUploadKyc;

  /// VEN-S03 resubmit CTA after rejection
  ///
  /// In en, this message translates to:
  /// **'Resubmit for review'**
  String get onboardingResubmit;

  /// VEN-S16 title and navigation CTA
  ///
  /// In en, this message translates to:
  /// **'Categories & regions'**
  String get onboardingCategoriesRegions;

  /// VEN-S16 save preferences CTA
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get onboardingSave;

  /// VEN-S16 away-mode toggle title
  ///
  /// In en, this message translates to:
  /// **'Away mode'**
  String get onboardingAwayMode;

  /// VEN-S16 away-mode toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Pause new-request notifications without deactivating.'**
  String get onboardingAwayModeHint;

  /// VEN-S16 placeholder until matching volume is available
  ///
  /// In en, this message translates to:
  /// **'Matched-request volume will appear once matching is live.'**
  String get onboardingVolumePlaceholder;

  /// VEN-S02 KYC upload intro copy
  ///
  /// In en, this message translates to:
  /// **'Upload your trade licence and Emirates ID for verification.'**
  String get onboardingKycUploadHint;

  /// VEN-S16 categories section heading
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get onboardingCategoriesHeading;

  /// VEN-S16 regions section heading
  ///
  /// In en, this message translates to:
  /// **'Regions'**
  String get onboardingRegionsHeading;

  /// VEN-S16 save failure fallback
  ///
  /// In en, this message translates to:
  /// **'Could not save.'**
  String get onboardingCouldNotSave;

  /// Generic done / finish CTA
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// SH-MED-04 empty-state action
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get uploadActionAdd;

  /// SH-MED-04 uploaded-state action
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get uploadActionReplace;

  /// SH-MED-04 failed-state action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get uploadActionRetry;

  /// SH-REQ-01 separator between min and max MoneyDisplay
  ///
  /// In en, this message translates to:
  /// **' - '**
  String get budgetRangeSeparator;

  /// VEN-S05 gold rates empty/error subtitle
  ///
  /// In en, this message translates to:
  /// **'Reference rates unavailable'**
  String get dashboardGoldRatesUnavailable;

  /// VendorLifecycle.registered display label
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get lifecycleRegistered;

  /// VendorLifecycle.pendingVerification display label
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get lifecyclePendingVerification;

  /// VendorLifecycle.verified display label
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get lifecycleVerified;

  /// VendorLifecycle.active display label
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get lifecycleActive;

  /// VendorLifecycle.suspended display label
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get lifecycleSuspended;

  /// VendorLifecycle.rejected display label
  ///
  /// In en, this message translates to:
  /// **'Needs changes'**
  String get lifecycleRejected;

  /// VendorLifecycle.deactivated display label
  ///
  /// In en, this message translates to:
  /// **'Deactivated'**
  String get lifecycleDeactivated;

  /// VendorLifecycle.unknown display label
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get lifecycleUnknown;

  /// SH-DOM-08 relative time when under one minute
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get relativeTimeJustNow;

  /// SH-DOM-08 relative time in minutes
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String relativeTimeMinutesAgo(int count);

  /// SH-DOM-08 relative time in hours
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String relativeTimeHoursAgo(int count);

  /// SH-DOM-08 relative time in days
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String relativeTimeDaysAgo(int count);

  /// SH-DOM-07 expired countdown label
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expiryExpired;

  /// SH-DOM-07 countdown when days remain
  ///
  /// In en, this message translates to:
  /// **'{days}d {hours}h left'**
  String expiryDaysHoursLeft(int days, int hours);

  /// SH-DOM-07 countdown when hours remain
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m left'**
  String expiryHoursMinutesLeft(int hours, int minutes);

  /// SH-DOM-07 countdown when minutes remain
  ///
  /// In en, this message translates to:
  /// **'{minutes}m {seconds}s left'**
  String expiryMinutesSecondsLeft(int minutes, int seconds);

  /// SH-DOM-07 countdown when only seconds remain
  ///
  /// In en, this message translates to:
  /// **'{seconds}s left'**
  String expirySecondsLeft(int seconds);

  /// SH-DOM-07 screen-reader label for countdown
  ///
  /// In en, this message translates to:
  /// **'Time remaining: {text}'**
  String expiryTimeRemainingSemantics(String text);

  /// SH-ID-07 completed deal count on trust signal
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} deal} other{{count} deals}}'**
  String dealCount(int count);

  /// VEN-S12 screen title
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get connectionsTitle;

  /// VEN-S12 empty state
  ///
  /// In en, this message translates to:
  /// **'No Connections yet. Accepted Offers appear here.'**
  String get connectionsEmptyBody;

  /// VEN-S12 list error
  ///
  /// In en, this message translates to:
  /// **'Could not load Connections.'**
  String get couldNotLoadConnections;

  /// VEN-S13 detail error
  ///
  /// In en, this message translates to:
  /// **'Could not load this Connection.'**
  String get couldNotLoadConnection;

  /// VEN-S12 Active section header
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get connectionSectionActive;

  /// VEN-S12 Closed section header
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get connectionSectionClosed;

  /// No description provided for @connectionStateActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get connectionStateActive;

  /// No description provided for @connectionStateClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get connectionStateClosed;

  /// No description provided for @connectionStateUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get connectionStateUnknown;

  /// SH-CON-02 Talk button
  ///
  /// In en, this message translates to:
  /// **'Talk'**
  String get connectionTalk;

  /// SH-CON-03 tap-to-call
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get connectionCall;

  /// SH-FND-22 phone copy tooltip
  ///
  /// In en, this message translates to:
  /// **'Copy number'**
  String get connectionCopyNumber;

  /// SH-FND-22 success toast
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get connectionCopied;

  /// VEN-S13 close action
  ///
  /// In en, this message translates to:
  /// **'Close Connection'**
  String get connectionClose;

  /// VEN-S13 close confirm title
  ///
  /// In en, this message translates to:
  /// **'Close this Connection?'**
  String get connectionCloseConfirmTitle;

  /// VEN-S13 close confirm body
  ///
  /// In en, this message translates to:
  /// **'Details stay available. Reviews open in Check-Point 5.'**
  String get connectionCloseConfirmBody;

  /// VEN-S13 read-only banner
  ///
  /// In en, this message translates to:
  /// **'This Connection is closed. Details remain available.'**
  String get connectionClosedBanner;

  /// Post-close review prompt until CP-5
  ///
  /// In en, this message translates to:
  /// **'Reviews open in Check-Point 5'**
  String get connectionReviewsCp5;

  /// VEN-S13 Talk fallback when waUrl is absent
  ///
  /// In en, this message translates to:
  /// **'WhatsApp is not available. Copy the number or call instead.'**
  String get connectionWhatsAppMissing;

  /// SnackBar when wa.me launch fails
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp.'**
  String get connectionCouldNotOpenTalk;

  /// VEN-S13 app bar title
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get connectionDetailTitle;

  /// VEN-S13 revealed-at label
  ///
  /// In en, this message translates to:
  /// **'Identity revealed'**
  String get connectionIdentityRevealedAt;

  /// VEN-S13 terms section
  ///
  /// In en, this message translates to:
  /// **'Accepted Offer terms'**
  String get connectionAcceptedTerms;

  /// VEN-S13 review CTA stub until CP-5
  ///
  /// In en, this message translates to:
  /// **'Leave feedback'**
  String get connectionLeaveFeedback;

  /// VEN-S13 report CTA stub until CP-5
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get connectionReport;

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
