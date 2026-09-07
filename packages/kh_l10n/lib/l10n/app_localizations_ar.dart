// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get filterRequests => 'تصفية الطلبات';

  @override
  String get resetAll => 'إعادة تعيين الكل';

  @override
  String get includeAlreadyResponded => 'تضمين الطلبات التي تم الرد عليها';

  @override
  String get applyFilters => 'تطبيق عوامل التصفية';

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get requestType => 'نوع الطلب';

  @override
  String get filterPresets => 'إعدادات التصفية المحفوظة';

  @override
  String get noSavedPresetsYet => 'لا توجد إعدادات محفوظة بعد.';

  @override
  String get saveCurrentFiltersAsPreset => 'حفظ عوامل التصفية الحالية كإعداد';

  @override
  String get subscriptionsTitle => 'الاشتراكات والاستحقاقات';

  @override
  String get subscriptionsRequirementBanner =>
      'يتطلب كل فئة طلب اشتراك نوع نشطًا لاستلام المطابقات وتقديم العروض (BR-002).';

  @override
  String get categoryEntitlements => 'استحقاقات الفئات';

  @override
  String get manageSubscriptionsContact =>
      'إدارة الاشتراكات / التواصل مع الدعم';

  @override
  String get subscriptionChangesHandled =>
      'تُدار تغييرات الاشتراك عبر إدارة حساب كارات هايف.';

  @override
  String get noActiveSubscription =>
      'لا يوجد اشتراك نشط. لن تستلم مطابقات لهذه الفئة.';

  @override
  String couldNotOpenUrl(String url) {
    return 'تعذّر فتح $url';
  }
}
