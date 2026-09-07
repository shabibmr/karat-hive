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
  String get dashboardEyebrow => 'نظرة عامة على المنصة';

  @override
  String get dashboardHeading => 'مركز التحكم الإداري';

  @override
  String get systemOperational => 'النظام يعمل';

  @override
  String get dashboardSampleDataNotice =>
      'أرقام إرشادية للعرض فقط. لم يتم تنفيذ نقطة نهاية لوحة التحكم الإدارية (GET /v1/admin/dashboard) بعد — ولا يعكس أي رقم أدناه بيانات المنصة الفعلية.';

  @override
  String get quickActionQueues => 'قوائم الإجراءات السريعة';

  @override
  String get queueColumnItem => 'عنصر القائمة';

  @override
  String get queueColumnType => 'النوع';

  @override
  String get queueColumnSubmitted => 'تاريخ الإرسال';

  @override
  String get queueColumnStatus => 'الحالة';

  @override
  String get queueColumnAction => 'الإجراء';

  @override
  String get categoriesEyebrow => 'إعدادات التصنيف';

  @override
  String get categoriesTitle => 'فئات المنتجات';

  @override
  String get categoriesSubtitle =>
      'إدارة تصنيف فئات المنتجات المكون من مستويين للطلبات وتخصصات التجار.';

  @override
  String get regionsEyebrow => 'التصنيف الجغرافي';

  @override
  String get regionsTitle => 'مناطق الإمارات وأسواق الذهب';

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

  @override
  String get vendorsEyebrow => 'إدارة التجار';

  @override
  String get vendorsTitle => 'قائمة التجار';

  @override
  String get vendorsSubtitle =>
      'تصفح وابحث عن التجار حسب حالة التحقق وحالة الحساب.';

  @override
  String get vendorsFilterVerification => 'حالة التحقق';

  @override
  String get vendorsFilterAccount => 'حالة الحساب';

  @override
  String get vendorsFilterSearch => 'بحث';

  @override
  String get vendorsFilterSearchHint => 'اسم النشاط، الرخصة، الجوال…';

  @override
  String get vendorsFilterAll => 'الكل';

  @override
  String get vendorsColumnBusiness => 'اسم النشاط';

  @override
  String get vendorsColumnTrading => 'الاسم التجاري';

  @override
  String get vendorsColumnVerification => 'التحقق';

  @override
  String get vendorsColumnAccount => 'الحساب';

  @override
  String get vendorsColumnWaiting => 'مدة الانتظار';

  @override
  String get vendorsColumnAction => 'إجراء';

  @override
  String get vendorsActionView => 'عرض';

  @override
  String get vendorsActionReviewKyc => 'مراجعة KYC';

  @override
  String get vendorsEmptyTitle => 'لم يتم العثور على تجار';

  @override
  String get vendorsEmptyBody => 'لا يوجد تجار يطابقون عوامل التصفية الحالية.';

  @override
  String get vendorsErrorTitle => 'تعذر تحميل التجار';

  @override
  String get vendorsRetry => 'إعادة المحاولة';

  @override
  String get vendorsLoadMore => 'تحميل المزيد';

  @override
  String get vendorsVerificationRegistered => 'مسجل';

  @override
  String get vendorsVerificationPending => 'قيد التحقق';

  @override
  String get vendorsVerificationVerified => 'تم التحقق';

  @override
  String get vendorsVerificationRejected => 'مرفوض';

  @override
  String get vendorsAccountActive => 'نشط';

  @override
  String get vendorsAccountSuspended => 'معلق';

  @override
  String get vendorsAccountDeactivated => 'معطل';

  @override
  String vendorsWaitingHours(int hours) {
    return 'انتظار $hours ساعة';
  }

  @override
  String get vendorsDetailEyebrow => 'ملف التاجر';

  @override
  String get vendorsDetailTitle => 'تفاصيل التاجر';

  @override
  String get vendorsDetailStubBody =>
      'فحص التاجر الكامل (ADM-S06) مخطط لمرحلة لاحقة.';

  @override
  String vendorsDetailVendorId(String id) {
    return 'معرف التاجر: $id';
  }

  @override
  String get vendorsDetailComingSoon =>
      'ستظهر إجراءات الحساب ومراجعة المستندات هنا.';

  @override
  String get verificationEyebrow => 'مراجع الامتثال';

  @override
  String verificationHeading(int count) {
    return 'قائمة التحقق من KYC ($count قيد الانتظار)';
  }

  @override
  String get verificationHeadingLoading => 'قائمة التحقق من KYC';

  @override
  String get verificationSubtitle =>
      'راجع طلبات KYC للتجار من الأقدم إلى الأحدث. يتم تسجيل كل عرض مستند وقرار في سجل التدقيق.';

  @override
  String get oldestFirstBadge => 'الأقدم أولاً';

  @override
  String get refresh => 'تحديث';

  @override
  String get verificationColumnBusiness => 'النشاط التجاري';

  @override
  String get verificationColumnLicence => 'الرخصة';

  @override
  String get verificationColumnWaiting => 'مدة الانتظار';

  @override
  String get verificationColumnStatus => 'الحالة';

  @override
  String get statusPendingVerification => 'قيد الانتظار';

  @override
  String get waitingLessThanHour => '< ساعة واحدة';

  @override
  String waitingHours(int hours) {
    return '$hours ساعة انتظار';
  }

  @override
  String waitingDays(int days) {
    return '$days يوم انتظار';
  }

  @override
  String get emptyVerificationTitle => 'القائمة فارغة';

  @override
  String get emptyVerificationBody =>
      'لا يوجد تجار بانتظار التحقق من KYC حالياً.';

  @override
  String get verificationLoadErrorTitle => 'تعذر تحميل قائمة التحقق';

  @override
  String get tryAgain => 'إعادة المحاولة';

  @override
  String get declaredBusinessProfile => 'الملف التجاري المُصرَّح به';

  @override
  String get legalNameLabel => 'الاسم القانوني';

  @override
  String get tradeLicenceLabel => 'رخصة التجارة';

  @override
  String get licenceExpiryLabel => 'انتهاء الرخصة';

  @override
  String get emirateLabel => 'الإمارة / المنطقة';

  @override
  String get contactPersonLabel => 'جهة الاتصال';

  @override
  String get businessAddressLabel => 'العنوان المسجّل';

  @override
  String get notDeclared => 'غير مُصرَّح';

  @override
  String get adminRationaleLabel => 'مبررات / ملاحظات المراجعة الإدارية';

  @override
  String get adminRationaleHint =>
      'أدخل سبب الموافقة أو الرفض أو طلب معلومات إضافية…';

  @override
  String get rationaleRequired => 'المبرر أو الرسالة مطلوب لكل قرار';

  @override
  String get documentInspectorTitle => 'عارض المستندات';

  @override
  String get noDocumentsUploaded => 'لم يتم رفع أي مستندات.';

  @override
  String get selectDocumentToView => 'اختر مستنداً لتحميل العارض.';

  @override
  String get openFullscreenViewer => 'فتح العارض بملء الشاشة';

  @override
  String documentSizeLabel(String sizeMb) {
    return '$sizeMb ميجابايت';
  }

  @override
  String get documentTypeTradeLicence => 'رخصة تجارية';

  @override
  String get documentTypeEmiratesId => 'الهوية الإماراتية';

  @override
  String get documentTypeVatCert => 'شهادة ضريبة القيمة المضافة';

  @override
  String get documentTypeTradingPermit => 'تصريح تجاري';

  @override
  String get documentTypeTenancy => 'عقد إيجار';

  @override
  String get documentTypeOther => 'مستند آخر';

  @override
  String get approveVendorButton => 'الموافقة على التاجر وتفعيل الوصول للسوق';

  @override
  String get requestInfoButton => 'طلب معلومات إضافية';

  @override
  String get rejectVendorButton => 'رفض الطلب';

  @override
  String get approveConfirmTitle => 'الموافقة على طلب التاجر؟';

  @override
  String get approveConfirmBody =>
      'سيتم وضع التاجر في حالة تم التحقق وقد يُفعَّل إذا كانت الفئات والمناطق مُصرَّحة مسبقاً. يُسجَّل القرار في سجل التدقيق.';

  @override
  String get confirmApprove => 'موافقة';

  @override
  String get rejectConfirmTitle => 'رفض طلب التاجر؟';

  @override
  String get rejectConfirmBody =>
      'سيُبلَّغ التاجر بمبررك ويمكنه إعادة تقديم المستندات. يُسجَّل القرار في سجل التدقيق.';

  @override
  String get confirmReject => 'رفض';

  @override
  String get requestInfoConfirmTitle => 'طلب معلومات إضافية؟';

  @override
  String get requestInfoConfirmBody =>
      'يبقى التاجر في قائمة التحقق ويرى رسالتك في شاشة انتظار الموافقة.';

  @override
  String get confirmRequestInfo => 'إرسال الطلب';

  @override
  String get toastVendorApproved => 'تمت الموافقة على التاجر بنجاح.';

  @override
  String get toastVendorRejected => 'تم رفض طلب التاجر.';

  @override
  String get toastInfoRequested => 'تم إرسال طلب المعلومات إلى التاجر.';
}
