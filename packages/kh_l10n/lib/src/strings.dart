import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kh_l10n/src/formatters.dart';

import '../l10n/app_localizations.dart';

/// Minimal string table for Vendor CP1 plus Customer shells/auth.
/// A full ARB + gen_l10n setup replaces this once more surfaces land
/// (Architecture-Frontend §14). Do not start ARB here.
class KhStrings {
  KhStrings(this.locale);
  final Locale locale;

  factory KhStrings.fromLanguage(String locale) =>
      KhStrings(Locale(locale.startsWith('ar') ? 'ar' : 'en'));

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

  Map<String, String> get _bundle => _table[locale.languageCode] ?? _table['en']!;

  Iterable<String> get tableKeys => _bundle.keys;

  String s(String key) => _bundle[key] ?? key;

  String aed(num amount) =>
      MoneyFormatter.aed(amount, locale: locale.languageCode);

  String grams(num grams) =>
      WeightFormatter.grams(grams, locale: locale.languageCode);

  String karat(int karat) =>
      KaratFormatter.karat(karat, locale: locale.languageCode);

  String gst(DateTime utc) =>
      GstFormatter.display(utc, locale: locale.languageCode);

  String relativeTime(DateTime past, {DateTime? now}) =>
      RelativeTimeFormatter.since(past, now: now, locale: locale.languageCode);

  static final _table = <String, Map<String, String>>{
    'en': {
      'app.title': 'Karat Hive',
      'auth.signIn': 'Sign in',
      'auth.register': 'Create a vendor account',
      'auth.registerCustomer': 'Create a Customer account',
      'auth.googleSignIn': 'Continue with Google',
      'auth.displayName': 'Display name',
      'auth.emailOptional': 'Email (optional)',
      'auth.termsOfService': 'Terms of Service',
      'auth.privacyPolicy': 'Privacy Policy',
      'auth.acceptTerms': 'I accept the Terms of Service',
      'auth.acceptPrivacy': 'I accept the Privacy Policy',
      'auth.createAccount': 'Create account',
      'auth.continueAsCustomer': 'Continue as Customer',
      'auth.continueAsVendor': 'Continue as Vendor',
      'auth.mobile': 'Mobile number',
      'auth.email': 'Business email',
      'auth.password': 'Password',
      'auth.sendCode': 'Send code',
      'auth.resendCode': 'Resend code',
      'auth.enterCode': 'Enter the 6-digit code',
      'auth.verify': 'Verify',
      'auth.otpTab': 'Mobile & code',
      'auth.passwordTab': 'Email & password',
      'shell.nav.home': 'Home',
      'shell.nav.requests': 'Requests',
      'shell.nav.connections': 'Connections',
      'shell.nav.alerts': 'Alerts',
      'shell.nav.profile': 'Profile',
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
      'time.justNow': 'just now',
      'time.minutesAgo': '{n}m ago',
      'time.hoursAgo': '{n}h ago',
      'time.daysAgo': '{n}d ago',
    },
    'ar': {
      'app.title': 'كارات هايف',
      'auth.signIn': 'تسجيل الدخول',
      'auth.register': 'إنشاء حساب تاجر',
      'auth.registerCustomer': 'إنشاء حساب عميل',
      'auth.googleSignIn': 'المتابعة باستخدام Google',
      'auth.displayName': 'الاسم المعروض',
      'auth.emailOptional': 'البريد الإلكتروني (اختياري)',
      'auth.termsOfService': 'شروط الخدمة',
      'auth.privacyPolicy': 'سياسة الخصوصية',
      'auth.acceptTerms': 'أوافق على شروط الخدمة',
      'auth.acceptPrivacy': 'أوافق على سياسة الخصوصية',
      'auth.createAccount': 'إنشاء حساب',
      'auth.continueAsCustomer': 'المتابعة كعميل',
      'auth.continueAsVendor': 'المتابعة كتاجر',
      'auth.mobile': 'رقم الجوال',
      'auth.email': 'البريد الإلكتروني للنشاط',
      'auth.password': 'كلمة المرور',
      'auth.sendCode': 'إرسال الرمز',
      'auth.resendCode': 'إعادة إرسال الرمز',
      'auth.enterCode': 'أدخل الرمز المكوّن من 6 أرقام',
      'auth.verify': 'تحقق',
      'auth.otpTab': 'الجوال والرمز',
      'auth.passwordTab': 'البريد وكلمة المرور',
      'shell.nav.home': 'الرئيسية',
      'shell.nav.requests': 'الطلبات',
      'shell.nav.connections': 'الاتصالات',
      'shell.nav.alerts': 'التنبيهات',
      'shell.nav.profile': 'الملف الشخصي',
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
      'time.justNow': 'الآن',
      'time.minutesAgo': 'منذ {n} د',
      'time.hoursAgo': 'منذ {n} س',
      'time.daysAgo': 'منذ {n} ي',
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
