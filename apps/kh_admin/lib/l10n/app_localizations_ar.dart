// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'بوابة إدارة كارات هايف';

  @override
  String get loginTitle => 'إدارة المنصة';

  @override
  String get loginSubtitle => 'بوابة الإدارة الداخلية لكارات هايف';

  @override
  String get loginInstructions =>
      'يرجى تسجيل الدخول باستخدام بيانات الاعتماد الإدارية الخاصة بك.';

  @override
  String get emailLabel => 'البريد الإلكتروني للمسؤول';

  @override
  String get emailHint => 'admin@karathive.ae';

  @override
  String get emailRequired => 'البريد الإلكتروني للمسؤول مطلوب';

  @override
  String get emailInvalid => 'يرجى إدخال عنوان بريد إلكتروني صالح';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get passwordHint => 'أدخل كلمة المرور';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get passwordTooShort => 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل';

  @override
  String get signInButton => 'المصادقة والدخول إلى البوابة';

  @override
  String get signingIn => 'جارٍ المصادقة...';

  @override
  String get errorAccountLocked =>
      'تم قفل حسابك الإداري مؤقتًا بسبب تكرار محاولات تسجيل الدخول الفاشلة. يرجى الانتظار 30 دقيقة أو الاتصال بمسؤول الأمان.';

  @override
  String get errorInvalidCredentials =>
      'بيانات الاعتماد الإدارية غير صالحة. يرجى التحقق من بريدك الإلكتروني وكلمة المرور.';

  @override
  String get errorServerUnavailable =>
      'الخدمة الإدارية غير متوفرة حالياً. يرجى التحقق من اتصالك وإعادة المحاولة.';

  @override
  String get errorUnknown => 'حدث خطأ غير متوقع. يرجى إعادة المحاولة.';

  @override
  String get categoriesTitle => 'إدارة الفئات';

  @override
  String get categoriesSubtitle =>
      'إدارة تصنيف فئات المنتجات المكون من مستويين للطلبات وتخصصات التجار.';

  @override
  String get regionsTitle => 'إدارة المناطق';

  @override
  String get regionsSubtitle =>
      'إدارة التصنيف الجغرافي (الإمارات والمناطق) لتوجيه الطلبات عبر المنصة.';

  @override
  String get showInactive => 'عرض غير النشط';

  @override
  String get hideInactive => 'إخفاء غير النشط';

  @override
  String get addRootCategory => '+ إضافة فئة';

  @override
  String get addRootRegion => '+ إضافة منطقة';

  @override
  String get addChildCategory => 'إضافة فئة فرعية';

  @override
  String get addChildRegion => 'إضافة منطقة فرعية';

  @override
  String get editCategory => 'تعديل الفئة';

  @override
  String get editRegion => 'تعديل المنطقة';

  @override
  String get createRootCategory => 'فئة رئيسية جديدة';

  @override
  String get createRootRegion => 'منطقة رئيسية جديدة';

  @override
  String get newChildCategory => 'فئة فرعية جديدة';

  @override
  String get newChildRegion => 'منطقة فرعية جديدة';

  @override
  String get nameEnLabel => 'الاسم (بالإنجليزية)';

  @override
  String get nameArLabel => 'الاسم (بالعربية)';

  @override
  String get nameEnRequired =>
      'الاسم باللغة الإنجليزية مطلوب ولا يمكن أن يكون فارغاً';

  @override
  String get nameArRequired =>
      'الاسم باللغة العربية مطلوب ولا يمكن أن يكون فارغاً';

  @override
  String get iconLabel => 'الأيقونة';

  @override
  String get displayOrderLabel => 'ترتيب العرض';

  @override
  String get activeStatusLabel => 'حالة النشاط';

  @override
  String get activeStatusDescription =>
      'يتم إخفاء العناصر غير النشطة من اختيارات العملاء والتجار ولكن يتم الاحتفاظ بالارتباطات السابقة.';

  @override
  String get saveButton => 'حفظ التغييرات';

  @override
  String get createButton => 'إنشاء';

  @override
  String get deactivateButton => 'تعطيل';

  @override
  String deactivateConfirmTitle(String name) {
    return 'تعطيل $name؟';
  }

  @override
  String deactivateConfirmBody(String name) {
    return 'هل أنت متأكد من رغبتك في تعطيل \"$name\"؟ لن تتمكن الطلبات الجديدة من اختيار العناصر غير النشطة، مع الاحتفاظ بالارتباطات الحالية. يمكن إلغاء هذا الإجراء لاحقاً.';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirmDeactivate => 'تعطيل';

  @override
  String get statusActive => 'نشط';

  @override
  String get statusInactive => 'غير نشط';

  @override
  String get emptyCategoriesTitle => 'لم يتم العثور على فئات';

  @override
  String get emptyCategoriesBody =>
      'لم يتم إعداد فئات منتجات بعد. قم بإنشاء فئة رئيسية للبدء في بناء هيكل التصنيف.';

  @override
  String get emptyRegionsTitle => 'لم يتم العثور على مناطق';

  @override
  String get emptyRegionsBody =>
      'لم يتم إعداد مناطق بعد. قم بإنشاء إمارة أو منطقة رئيسية للبدء.';

  @override
  String get toastCategoryCreated => 'تم إنشاء الفئة بنجاح.';

  @override
  String get toastCategoryUpdated => 'تم تحديث الفئة بنجاح.';

  @override
  String get toastCategoryDeactivated => 'تم تعطيل الفئة بنجاح.';

  @override
  String get toastRegionCreated => 'تم إنشاء المنطقة بنجاح.';

  @override
  String get toastRegionUpdated => 'تم تحديث المنطقة بنجاح.';

  @override
  String get toastRegionDeactivated => 'تم تعطيل المنطقة بنجاح.';

  @override
  String get levelLimitReached =>
      'تم الوصول إلى الحد الأقصى للتسلسل الهرمي (مستويان). لا يمكن إضافة عناصر فرعية لهذا العنصر.';

  @override
  String get selectNodeToEdit =>
      'حدد عنصراً من شجرة التصنيف لتعديله أو إضافة عنصر فرعي، أو قم بإنشاء عنصر رئيسي جديد.';
}
