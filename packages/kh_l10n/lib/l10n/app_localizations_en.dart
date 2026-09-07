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
}
