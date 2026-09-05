library kh_l10n;

import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

/// Minimal string table for the onboarding vertical. A full ARB + gen_l10n setup
/// replaces this once more surfaces land (Architecture-Frontend §14).
class KhStrings {
  KhStrings(this.locale);
  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('ar')];
  static const delegates = <LocalizationsDelegate<dynamic>>[
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
      'dashboard.title': 'Dashboard',
      'dashboard.newRequests': 'New requests',
      'dashboard.pendingOffers': 'Pending offers',
      'dashboard.activeConnections': 'Active connections',
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
      'dashboard.title': 'لوحة التحكم',
      'dashboard.newRequests': 'طلبات جديدة',
      'dashboard.pendingOffers': 'عروض معلّقة',
      'dashboard.activeConnections': 'اتصالات نشطة',
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
