library kh_l10n;

import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'l10n/app_localizations.dart';

export 'l10n/app_localizations.dart';

/// Legacy inlined string table for CP-1 auth/onboarding/shell copy.
///
/// CP2-F05 introduces ARB + `gen_l10n` (`AppLocalizations`) for new surfaces.
/// Existing `KhStrings.s(...)` call sites stay until a later F05 migration pass.
class KhStrings {
  KhStrings(this.locale);
  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('ar')];
  static const delegates = <LocalizationsDelegate<dynamic>>[
    AppLocalizations.delegate,
    _KhStringsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static KhStrings of(BuildContext context) =>
      Localizations.of<KhStrings>(context, KhStrings) ?? KhStrings(const Locale('en'));

  bool get isRtl => locale.languageCode == 'ar';

  String s(String key) => (_table[locale.languageCode] ?? _table['en']!)[key] ?? key;

  static final _table = <String, Map<String, String>>{
    'en': {
      'app.title': 'Karat Hive',
      'auth.signIn': 'Sign in',
      'auth.register': 'Create a vendor account',
      'auth.mobile': 'Mobile number',
      'auth.email': 'Business email',
      'auth.password': 'Password',
      'auth.sendCode': 'Send code',
      'auth.resendCode': 'Resend code',
      'auth.enterCode': 'Enter the 6-digit code',
      'auth.verify': 'Verify',
      'auth.otpTab': 'Mobile & code',
      'auth.passwordTab': 'Email & password',
      'onboarding.awaitingTitle': 'Verification in progress',
      'onboarding.pendingDocuments': 'Upload your business documents to continue.',
      'onboarding.pendingAdmin': 'Our team is reviewing your documents.',
      'onboarding.categoriesRequired': 'Choose the categories and regions you serve.',
      'onboarding.rejected': 'Your application needs changes.',
      'onboarding.uploadKyc': 'Upload documents',
      'onboarding.resubmit': 'Resubmit for review',
      'onboarding.categoriesRegions': 'Categories & regions',
      'onboarding.save': 'Save',
      'onboarding.awayMode': 'Away mode',
      'onboarding.awayModeHint': 'Pause new-request notifications without deactivating.',
      'onboarding.volumePlaceholder':
          'Matched-request volume will appear once matching is live.',
      'dashboard.title': 'Dashboard',
      'dashboard.rating': 'Rating',
      'dashboard.noReviews': 'No reviews yet',
      'dashboard.goldRates': 'Reference gold rates',
      'dashboard.goldRatesUnavailable': 'Reference rates unavailable',
      'dashboard.subscriptions': 'Type subscriptions',
      'dashboard.noSubscriptions': 'No type subscriptions yet',
      'dashboard.newRequests': 'New requests',
      'dashboard.pendingOffers': 'Pending offers',
      'dashboard.activeConnections': 'Active connections',
      'lifecycle.registered': 'Registered',
      'lifecycle.pendingVerification': 'Under review',
      'lifecycle.verified': 'Verified',
      'lifecycle.active': 'Active',
      'lifecycle.suspended': 'Suspended',
      'lifecycle.rejected': 'Needs changes',
      'lifecycle.deactivated': 'Deactivated',
      'lifecycle.unknown': 'Unknown',
      'common.retry': 'Try again',
      'common.logout': 'Log out',
      'common.empty': 'Nothing here yet',
    },
    'ar': {
      'app.title': 'كارات هايف',
      'auth.signIn': 'تسجيل الدخول',
      'auth.register': 'إنشاء حساب تاجر',
      'auth.mobile': 'رقم الجوال',
      'auth.email': 'البريد الإلكتروني للنشاط',
      'auth.password': 'كلمة المرور',
      'auth.sendCode': 'إرسال الرمز',
      'auth.resendCode': 'إعادة إرسال الرمز',
      'auth.enterCode': 'أدخل الرمز المكوّن من 6 أرقام',
      'auth.verify': 'تحقق',
      'auth.otpTab': 'الجوال والرمز',
      'auth.passwordTab': 'البريد وكلمة المرور',
      'onboarding.awaitingTitle': 'جارٍ التحقق',
      'onboarding.pendingDocuments': 'ارفع مستندات نشاطك للمتابعة.',
      'onboarding.pendingAdmin': 'يقوم فريقنا بمراجعة مستنداتك.',
      'onboarding.categoriesRequired': 'اختر الفئات والمناطق التي تخدمها.',
      'onboarding.rejected': 'يحتاج طلبك إلى تعديلات.',
      'onboarding.uploadKyc': 'رفع المستندات',
      'onboarding.resubmit': 'إعادة الإرسال للمراجعة',
      'onboarding.categoriesRegions': 'الفئات والمناطق',
      'onboarding.save': 'حفظ',
      'onboarding.awayMode': 'وضع الغياب',
      'onboarding.awayModeHint': 'إيقاف إشعارات الطلبات الجديدة دون تعطيل الحساب.',
      'onboarding.volumePlaceholder': 'يظهر حجم الطلبات المطابقة بعد تفعيل المطابقة.',
      'dashboard.title': 'لوحة التحكم',
      'dashboard.rating': 'التقييم',
      'dashboard.noReviews': 'لا توجد تقييمات بعد',
      'dashboard.goldRates': 'أسعار الذهب المرجعية',
      'dashboard.goldRatesUnavailable': 'الأسعار المرجعية غير متاحة',
      'dashboard.subscriptions': 'اشتراكات النوع',
      'dashboard.noSubscriptions': 'لا توجد اشتراكات نوع بعد',
      'dashboard.newRequests': 'طلبات جديدة',
      'dashboard.pendingOffers': 'عروض معلّقة',
      'dashboard.activeConnections': 'اتصالات نشطة',
      'lifecycle.registered': 'مسجّل',
      'lifecycle.pendingVerification': 'قيد المراجعة',
      'lifecycle.verified': 'موثّق',
      'lifecycle.active': 'نشط',
      'lifecycle.suspended': 'موقوف',
      'lifecycle.rejected': 'يحتاج تعديلات',
      'lifecycle.deactivated': 'معطّل',
      'lifecycle.unknown': 'غير معروف',
      'common.retry': 'حاول مرة أخرى',
      'common.logout': 'تسجيل الخروج',
      'common.empty': 'لا يوجد شيء بعد',
    },
  };
}

class _KhStringsDelegate extends LocalizationsDelegate<KhStrings> {
  const _KhStringsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<KhStrings> load(Locale locale) async => KhStrings(locale);

  @override
  bool shouldReload(_KhStringsDelegate old) => false;
}

/// AED money formatting lives in exactly one place (Architecture-Frontend §8.4).
class MoneyFormatter {
  static String aed(num amount, {String locale = 'en'}) =>
      NumberFormat.currency(locale: locale == 'ar' ? 'ar_AE' : 'en_AE', symbol: 'AED ')
          .format(amount);
}

class RelativeTimeFormatter {
  static String since(DateTime past, {DateTime? now}) {
    final d = (now ?? DateTime.now().toUtc()).difference(past);
    if (d.inMinutes < 1) return 'just now';
    if (d.inHours < 1) return '${d.inMinutes}m ago';
    if (d.inDays < 1) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}
