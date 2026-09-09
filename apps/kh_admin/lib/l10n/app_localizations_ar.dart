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
      'أرقام المنصة الحية من GET /v1/admin/dashboard. صفوف قوائم الإجراءات لقطات من التحقق وبلاغات الإساءة والمراجعات المعلقة. التسوية تتم خارج المنصة؛ ولا يُعرض حجم التداول.';

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
  String get dashboardRangeLabel => 'النطاق الزمني';

  @override
  String get dashboardRange7 => 'آخر 7 أيام';

  @override
  String get dashboardRange30 => 'آخر 30 يومًا';

  @override
  String get dashboardRange90 => 'آخر 90 يومًا';

  @override
  String get dashboardTrendsHeading => 'الاتجاهات';

  @override
  String get dashboardTrendCaption =>
      'حجم الطلبات حسب الحالة خلال النطاق المحدد.';

  @override
  String get dashboardTrendEmpty => 'لا توجد بيانات اتجاه لهذا النطاق.';

  @override
  String get dashboardQueueRetry => 'إعادة المحاولة';

  @override
  String get queueSourceVerification => 'قائمة التحقق';

  @override
  String get queueSourceAbuse => 'بلاغات الإساءة';

  @override
  String get queueSourceReview => 'المراجعات المعلقة';

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
  String vendorsDetailVendorId(String id) {
    return 'معرف التاجر: $id';
  }

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

  @override
  String get offersListEyebrow => 'تدقيق السوق';

  @override
  String get offersListHeading => 'العروض';

  @override
  String get offersListSubtitle => 'مراقبة وفحص عروض التجار على مستوى المنصة';

  @override
  String get offersFilterState => 'حالة العرض';

  @override
  String get offersFilterAllStates => 'جميع الحالات';

  @override
  String get offersFilterRequestType => 'نوع الطلب';

  @override
  String get offersFilterAllTypes => 'جميع الأنواع';

  @override
  String get offersFilterSearch => 'بحث';

  @override
  String get offersFilterSearchHint => 'معرف العرض، اسم التاجر، مرجع الطلب…';

  @override
  String get offersFilterSearchTooltip => 'البحث في العروض';

  @override
  String get offersColumnReference => 'مرجع/معرف العرض';

  @override
  String get offersColumnParentRequest => 'الطلب الأصلي';

  @override
  String get offersColumnVendor => 'اسم التاجر';

  @override
  String get offersColumnOfferedPrice => 'السعر المعروض (درهم)';

  @override
  String get offersColumnState => 'الحالة';

  @override
  String get offersColumnSubmissionDate => 'تاريخ التقديم';

  @override
  String get offersColumnExpiryDate => 'تاريخ الانتهاء';

  @override
  String get offersColumnOutcome => 'النتيجة';

  @override
  String get offersColumnAction => 'إجراء';

  @override
  String get offersOutcomeAcceptedByCustomer => 'مقبول من العميل';

  @override
  String get offersOutcomeRejected => 'مرفوض';

  @override
  String get offersOutcomeExpired => 'منتهٍ';

  @override
  String get offersOutcomePending => 'قيد الانتظار';

  @override
  String get offersActionInspect => 'فحص';

  @override
  String offersPaginationShowing(int count) {
    return 'عرض $count عرضاً';
  }

  @override
  String offersPaginationShowingOf(int count, int total) {
    return 'عرض $count من $total عرضاً';
  }

  @override
  String get offersPaginationPrevious => 'السابق';

  @override
  String offersPaginationPage(int page) {
    return 'صفحة $page';
  }

  @override
  String get offersPaginationNext => 'التالي';

  @override
  String get offersEmptyTitle => 'لم يتم العثور على عروض';

  @override
  String get offersEmptyBody => 'لا توجد عروض تطابق معايير التصفية الحالية.';

  @override
  String get offersErrorTitle => 'تعذر تحميل العروض';

  @override
  String get offersRetry => 'إعادة المحاولة';

  @override
  String get offersDetailBack => 'العودة إلى العروض';

  @override
  String offersDetailEyebrow(String reference) {
    return 'عرض $reference';
  }

  @override
  String offersDetailHeaderMeta(String date, int hours) {
    return 'قُدِّم في $date · الصلاحية $hours ساعة';
  }

  @override
  String offersDetailHeaderMetaExpires(String date, int hours, String expiry) {
    return 'قُدِّم في $date · الصلاحية $hours ساعة (ينتهي في $expiry)';
  }

  @override
  String get offersDetailCompetingWonTitle => 'فاز عرض منافس بهذا الطلب';

  @override
  String offersDetailCompetingWonBody(
    String reference,
    String vendorPart,
    String pricePart,
  ) {
    return 'اختار العميل العرض الفائز $reference$vendorPart$pricePart.';
  }

  @override
  String offersDetailCompetingWonBy(String vendor) {
    return ' من $vendor';
  }

  @override
  String offersDetailCompetingWonFor(String price) {
    return ' بمبلغ $price';
  }

  @override
  String get offersDetailInspectWinning => 'فحص العرض الفائز';

  @override
  String get offersDetailVendorProfileTitle => 'ملف التاجر غير المُخفى';

  @override
  String get offersDetailViewVendor => 'عرض التاجر';

  @override
  String get offersDetailNoVendor => 'لم تُقدَّم تفاصيل التاجر.';

  @override
  String get offersDetailLabelLegalName => 'الاسم القانوني للنشاط';

  @override
  String get offersDetailLabelTradingName => 'الاسم التجاري';

  @override
  String get offersDetailLabelTradeLicence => 'الرخصة التجارية';

  @override
  String get offersDetailLabelContactMobile => 'جهة الاتصال والجوال';

  @override
  String get offersDetailLabelBusinessEmail => 'البريد الإلكتروني للنشاط';

  @override
  String get offersDetailLabelVendorRating => 'تقييم التاجر';

  @override
  String offersDetailDealsSuffix(int deals) {
    return ' ($deals صفقة مكتملة)';
  }

  @override
  String get offersDetailParentRequestTitle => 'مرجع الطلب الأصلي';

  @override
  String get offersDetailOpenRequest => 'فتح الطلب';

  @override
  String get offersDetailNoParentRequest => 'لا يوجد طلب أصلي مرتبط.';

  @override
  String get offersDetailLabelRequestReference => 'مرجع الطلب';

  @override
  String get offersDetailLabelRequestType => 'نوع الطلب';

  @override
  String get offersDetailLabelCustomerMobile => 'اسم العميل والجوال';

  @override
  String get offersDetailLabelCategory => 'الفئة';

  @override
  String get offersDetailLabelRegion => 'المنطقة';

  @override
  String get offersDetailLabelIndicativeBudget => 'الميزانية الإرشادية';

  @override
  String get offersDetailLabelRequestNotes => 'ملاحظات الطلب';

  @override
  String get offersDetailPricingTitle => 'تفصيل التسعير';

  @override
  String get offersDetailPricingGoldValue => 'قيمة معدن الذهب';

  @override
  String offersDetailPricingGoldHintRate(String rate) {
    return 'سعر الذهب الأساسي ($rate/غرام)';
  }

  @override
  String get offersDetailPricingGoldHint => 'مكوّن سعر الذهب الأساسي';

  @override
  String get offersDetailPricingMaking => 'رسوم التصنيع / الصياغة';

  @override
  String get offersDetailPricingMakingHint => 'رسوم العمالة والحرفية';

  @override
  String get offersDetailPricingVat => 'ضريبة القيمة المضافة (5%)';

  @override
  String get offersDetailPricingVatHint => 'الضريبة النظامية في الإمارات';

  @override
  String get offersDetailPricingTotal => 'إجمالي السعر المعروض';

  @override
  String get offersDetailTermsTitle => 'الشروط التجارية والملاحظات والمرفقات';

  @override
  String get offersDetailLabelDelivery => 'مدة التسليم / الجاهزية';

  @override
  String get offersDetailDeliveryDefault => 'إرسال / استلام فوري';

  @override
  String get offersDetailLabelWarranty => 'شروط الضمان / إعادة الشراء';

  @override
  String get offersDetailWarrantyDefault => 'ضمان جواهرجي الإمارات القياسي';

  @override
  String get offersDetailLabelVendorNote => 'ملاحظة التاجر';

  @override
  String get offersDetailVendorNoteDefault => 'لم يقدّم التاجر أي ملاحظة نصية.';

  @override
  String get offersDetailLabelValidityExpiry => 'صلاحية العرض وانتهاؤه';

  @override
  String offersDetailValidityExpiryValue(int hours, String date) {
    return '$hours ساعة · الانتهاء: $date';
  }

  @override
  String get offersDetailLabelDeclineReason => 'سبب الرفض';

  @override
  String offersDetailAttachmentsCount(int count) {
    return 'المرفقات والشهادات ($count)';
  }

  @override
  String get offersDetailNoAttachments =>
      'لم يرفق التاجر أي ملفات وسائط أو شهادات.';

  @override
  String get offersDetailRevisionsTitle => 'سجل المراجعات (FR-VEN-014)';

  @override
  String offersDetailRevisionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مراجعة',
    );
    return '$_temp0';
  }

  @override
  String get offersDetailNoRevisions =>
      'شروط العرض الأولية. لم تُجرَ أي تعديلات قبل القبول.';

  @override
  String offersDetailRevisionNumber(int number) {
    return 'مراجعة رقم $number';
  }

  @override
  String offersDetailRevisionOffered(String price) {
    return 'المعروض: $price';
  }

  @override
  String offersDetailRevisionMakingSuffix(String making) {
    return ' (التصنيع: $making)';
  }

  @override
  String offersDetailRevisionNote(String note) {
    return 'ملاحظة: $note';
  }

  @override
  String get offersDetailTransitionsTitle => 'الجدول الزمني لتحولات الحالة';

  @override
  String offersDetailNoTransitions(String state) {
    return 'العرض في حالة $state. لم يُسجَّل أي تدقيق لتحولات الحالة.';
  }

  @override
  String offersDetailTransitionActor(String actor) {
    return 'بواسطة: $actor';
  }

  @override
  String offersDetailTransitionReason(String reason) {
    return 'السبب: $reason';
  }

  @override
  String get offersDetailNotesTitle => 'ملاحظات إدارية داخلية';

  @override
  String get offersDetailNotesSubtitle =>
      'ملاحظات فحص المسؤول داخلية لكارات هايف. الشروط التجارية للقراءة فقط.';

  @override
  String get offersDetailNotesHint => 'أضف ملاحظة داخلية حول هذا العرض…';

  @override
  String get offersDetailAddNote => 'إضافة ملاحظة';

  @override
  String get offersDetailNoNotes => 'لم تُضف أي ملاحظات داخلية بعد.';

  @override
  String get offersDetailErrorTitle => 'تعذر تحميل تفاصيل العرض';

  @override
  String get requestsListEyebrow => 'تدقيق السوق';

  @override
  String get requestsListHeading => 'الطلبات';

  @override
  String get requestsListSubtitle => 'الإشراف على طلبات المنصة وفحصها';

  @override
  String get requestsFilterType => 'نوع الطلب';

  @override
  String get requestsFilterAllTypes => 'جميع الأنواع';

  @override
  String get requestsFilterDirection => 'الاتجاه';

  @override
  String get requestsFilterAllDirections => 'جميع الاتجاهات';

  @override
  String get requestsFilterStatus => 'الحالة';

  @override
  String get requestsFilterAllStates => 'جميع الحالات';

  @override
  String get requestsFilterSearch => 'بحث';

  @override
  String get requestsFilterSearchHint => 'المرجع، الملاحظات، العميل…';

  @override
  String get requestsFilterSearchTooltip => 'بحث';

  @override
  String get requestsFilterZeroOffers => 'بلا عروض';

  @override
  String get requestsColumnReference => 'المرجع';

  @override
  String get requestsColumnType => 'النوع';

  @override
  String get requestsColumnDirection => 'الاتجاه';

  @override
  String get requestsColumnCustomer => 'العميل';

  @override
  String get requestsColumnCategory => 'الفئة';

  @override
  String get requestsColumnRegion => 'المنطقة';

  @override
  String get requestsColumnIndicativeValue => 'القيمة الإرشادية';

  @override
  String get requestsColumnOffers => 'العروض';

  @override
  String get requestsColumnState => 'الحالة';

  @override
  String get requestsColumnDate => 'التاريخ';

  @override
  String get requestsColumnAction => 'إجراء';

  @override
  String get requestsActionInspect => 'فحص';

  @override
  String get requestsLoadMore => 'تحميل المزيد';

  @override
  String get requestsPaginationPrevious => 'السابق';

  @override
  String requestsPaginationPage(int page) {
    return 'صفحة $page';
  }

  @override
  String get requestsPaginationNext => 'التالي';

  @override
  String get requestsEmptyBody => 'لا توجد طلبات تطابق عوامل التصفية الحالية.';

  @override
  String get requestsRetry => 'إعادة المحاولة';

  @override
  String get requestsDetailBack => 'العودة إلى الطلبات';

  @override
  String get requestsDetailEyebrow => 'الإشراف على الطلب';

  @override
  String get requestsDetailNoReference => 'بلا مرجع';

  @override
  String requestsDetailPublishedAt(String date) {
    return 'نُشِر $date بتوقيت الخليج';
  }

  @override
  String requestsDetailCreatedAt(String date) {
    return 'أُنشئ $date بتوقيت الخليج';
  }

  @override
  String get requestsDetailNoteAdded => 'تمت إضافة الملاحظة بنجاح.';

  @override
  String requestsDetailNoteAddFailed(String error) {
    return 'تعذرت إضافة الملاحظة: $error';
  }

  @override
  String get requestsDetailRemoveSuccess => 'تمت إزالة الطلب بنجاح.';

  @override
  String requestsDetailRemoveFailed(String error) {
    return 'تعذرت إزالة الطلب: $error';
  }

  @override
  String get requestsDetailRemovedTitle =>
      'تمت إزالة الطلب بواسطة إشراف المنصة (FR-ADM-019)';

  @override
  String requestsDetailRemovedReason(String code, String text) {
    return 'السبب: $code · $text';
  }

  @override
  String get requestsDetailRemovedReasonCodeDefault => 'POLICY_VIOLATION';

  @override
  String get requestsDetailRemovedReasonTextDefault =>
      'ينتهك إرشادات التداول على المنصة';

  @override
  String requestsDetailRemovedPolicyClause(String clause) {
    return 'بند السياسة المُستشهد به: $clause';
  }

  @override
  String get requestsDetailConnectionTitle => 'تم إنشاء اتصال نشط';

  @override
  String requestsDetailConnectionParties(String vendor, String customer) {
    return 'التاجر المقبول: $vendor · العميل: $customer';
  }

  @override
  String requestsDetailConnectionMeta(String date, String channel) {
    return 'تم الاتصال في: $date بتوقيت الخليج · القناة: $channel';
  }

  @override
  String get requestsDetailConnectionChannelDefault => 'WHATSAPP';

  @override
  String get requestsDetailWhatsappChannel => 'قناة واتساب';

  @override
  String get requestsDetailSpecsTitle => 'المتطلبات التجارية والمواصفات';

  @override
  String get requestsDetailSpecsReadOnly =>
      'للقراءة فقط للمسؤول (FR-ADM-018 AC3)';

  @override
  String get requestsDetailLabelReferenceCode => 'رمز المرجع';

  @override
  String get requestsDetailLabelRequestType => 'نوع الطلب';

  @override
  String get requestsDetailLabelMarketDirection => 'اتجاه السوق';

  @override
  String get requestsDetailLabelCategory => 'الفئة';

  @override
  String get requestsDetailLabelRegion => 'المنطقة';

  @override
  String get requestsDetailLabelOrnamentType => 'نوع الحلي';

  @override
  String get requestsDetailLabelPurityKarat => 'النقاء / القيراط';

  @override
  String get requestsDetailLabelWeight => 'الوزن';

  @override
  String get requestsDetailLabelCondition => 'الحالة';

  @override
  String get requestsDetailLabelDenomination => 'الفئة الوزنية';

  @override
  String get requestsDetailLabelQuantity => 'الكمية';

  @override
  String get requestsDetailLabelMintRefiner => 'دار السك / المصفاة';

  @override
  String get requestsDetailLabelIndicativeValue => 'القيمة الإرشادية';

  @override
  String get requestsDetailLabelCustomerBudget => 'ميزانية العميل';

  @override
  String requestsDetailWeightApproximate(String weight) {
    return '$weight غرام (تقريبي)';
  }

  @override
  String requestsDetailWeightExact(String weight) {
    return '$weight غرام (دقيق)';
  }

  @override
  String requestsDetailQuantityUnits(int quantity) {
    return '$quantity وحدة';
  }

  @override
  String requestsDetailBudgetValue(String min, String max) {
    return '$min – $max درهم';
  }

  @override
  String requestsDetailBudgetValueFlexible(String min, String max) {
    return '$min – $max درهم (مرن)';
  }

  @override
  String get requestsDetailCustomerNotes => 'ملاحظات العميل:';

  @override
  String get requestsDetailCustomerProfileTitle => 'ملف العميل غير المُخفى';

  @override
  String requestsDetailCustomerId(String id) {
    return 'معرف العميل: $id';
  }

  @override
  String get requestsDetailLabelMobilePhone => 'رقم الجوال';

  @override
  String get requestsDetailLabelEmailAddress => 'البريد الإلكتروني';

  @override
  String get requestsDetailLabelMemberSince => 'عضو منذ';

  @override
  String requestsDetailMediaTitle(int count) {
    return 'الوسائط المرفوعة ($count)';
  }

  @override
  String get requestsDetailNoMedia => 'لم تُرفع أي وسائط لهذا الطلب.';

  @override
  String requestsDetailImageNumber(int number) {
    return 'صورة رقم $number';
  }

  @override
  String requestsDetailOffersTitle(int count) {
    return 'العروض المستلمة ($count)';
  }

  @override
  String get requestsDetailNoOffers => 'لم تُقدَّم أي عروض بعد.';

  @override
  String get requestsDetailOffersColumnVendor => 'التاجر';

  @override
  String get requestsDetailOffersColumnPrice => 'السعر المعروض';

  @override
  String get requestsDetailOffersColumnStatus => 'الحالة';

  @override
  String get requestsDetailOffersColumnSubmitted => 'تاريخ التقديم';

  @override
  String get requestsDetailOffersColumnTurnaround => 'مدة الإنجاز';

  @override
  String requestsDetailOfferDays(int days) {
    return '$days يوماً';
  }

  @override
  String requestsDetailMatchedTitle(int count) {
    return 'التجار المطابقون ($count)';
  }

  @override
  String get requestsDetailNoMatched => 'لا يوجد تجار مطابقون لهذا الطلب.';

  @override
  String requestsDetailMatchedAt(String date) {
    return 'تمت المطابقة: $date';
  }

  @override
  String get requestsDetailViewed => 'تمت المشاهدة';

  @override
  String get requestsDetailNotViewed => 'لم تتم المشاهدة';

  @override
  String get requestsDetailTimelineTitle => 'سجل تحولات الحالة';

  @override
  String get requestsDetailNoTransitions => 'لا توجد تحولات مسجّلة.';

  @override
  String requestsDetailTimelineBy(String actor) {
    return 'بواسطة $actor';
  }

  @override
  String get requestsDetailModerationTitle => 'إشراف المنصة';

  @override
  String get requestsDetailModerationBody =>
      'يمكن للمسؤولين إزالة الطلبات التي تنتهك سياسات التداول على المنصة قسراً (FR-ADM-019).';

  @override
  String get requestsDetailAlreadyRemoved => 'تمت إزالة الطلب بالفعل';

  @override
  String get requestsDetailRemoveRequest => 'إزالة الطلب';

  @override
  String requestsDetailNotesTitle(int count) {
    return 'ملاحظات المسؤول الداخلية ($count)';
  }

  @override
  String get requestsDetailNoNotes => 'لا توجد ملاحظات داخلية مسجّلة.';

  @override
  String get requestsDetailAddNoteLabel => 'إضافة ملاحظة داخلية';

  @override
  String get requestsDetailAddNoteHint => 'سجّل ملاحظات التدقيق أو الامتثال…';

  @override
  String get requestsDetailAddNote => 'إضافة ملاحظة';

  @override
  String get requestsDetailRemoveDialogTitle => 'إزالة الطلب';

  @override
  String requestsDetailRemoveDialogBody(String reference) {
    return 'إزالة \"$reference\" تضبط الحالة على REMOVED، وتسحب جميع العروض المعلقة، وتُخطر الطرفين.';
  }

  @override
  String get requestsDetailRemoveReasonCode => 'رمز السبب';

  @override
  String get requestsDetailRemoveReasonPolicyViolation => 'انتهاك السياسة';

  @override
  String get requestsDetailRemoveReasonProhibitedItem => 'عنصر محظور / ممنوع';

  @override
  String get requestsDetailRemoveReasonFraudulent => 'إعلان احتيالي أو مضلل';

  @override
  String get requestsDetailRemoveReasonCustomerRequested =>
      'طلب العميل الإلغاء';

  @override
  String get requestsDetailRemoveReasonOther => 'سبب إداري آخر';

  @override
  String get requestsDetailRemovePolicyClauseLabel =>
      'بند السياسة (المُستشهد به للعميل)';

  @override
  String get requestsDetailRemovePolicyClauseHint => 'مثال: شروط الخدمة §4.2';

  @override
  String get requestsDetailRemoveJustificationLabel =>
      'التبرير التفصيلي والملاحظات';

  @override
  String get requestsDetailRemoveJustificationHint =>
      'اذكر السبب لسجل التدقيق…';

  @override
  String get requestsDetailRemoveJustificationRequired =>
      'التبرير التفصيلي مطلوب.';

  @override
  String get requestsDetailConfirmRemoval => 'تأكيد الإزالة';

  @override
  String get requestsDetailErrorRetry => 'إعادة المحاولة';

  @override
  String get reportsEyebrow => 'ذكاء الأعمال';

  @override
  String get reportsHeading => 'تحليلات وتقارير المنصة';

  @override
  String get reportsSubtitle =>
      'تقارير تشغيلية عبر فترة زمنية، مع التصفية حسب المنطقة والفئة.';

  @override
  String get reportsIndicativeNote =>
      'الأرقام مؤشرات تشغيلية وليست تسوية أو قيمة صفقات. تتم التسوية خارج المنصة. الوحدات: درهم، غرام، قيراط/نقاء. تُعرض الطوابع الزمنية بتوقيت الخليج.';

  @override
  String get reportsTypeLabel => 'نوع التقرير';

  @override
  String get reportsTypeAcquisition => 'اكتساب العملاء والاحتفاظ بهم';

  @override
  String get reportsTypeVendorLeague => 'ترتيب أداء التجار';

  @override
  String get reportsTypeRequestVolume => 'حجم الطلبات';

  @override
  String get reportsTypeOfferCompetitiveness => 'تنافسية العروض';

  @override
  String get reportsTypeFunnel => 'تحويل مسار التعامل';

  @override
  String get reportsTypeLiquidityGaps => 'فجوات السيولة';

  @override
  String get reportsTypeRatingDistribution => 'توزيع التقييمات';

  @override
  String get reportsFrom => 'من (YYYY-MM-DD)';

  @override
  String get reportsTo => 'إلى (YYYY-MM-DD)';

  @override
  String get reportsRegionId => 'معرّف المنطقة (اختياري)';

  @override
  String get reportsCategoryId => 'معرّف الفئة (اختياري)';

  @override
  String get reportsApply => 'تطبيق';

  @override
  String get reportsEmptyPeriod =>
      'لا توجد صفوف لهذه الفترة. جرّب نطاقاً زمنياً أو منطقة أو فئة مختلفة.';

  @override
  String get reportsEmptyChart => 'لا توجد بيانات للرسم البياني في هذه الفترة.';

  @override
  String get reportsRetry => 'إعادة المحاولة';

  @override
  String get reportsExportCsv => 'تصدير CSV';

  @override
  String get reportsExportXlsx => 'تصدير XLSX';

  @override
  String get reportsExportPng => 'تصدير الرسم PNG';

  @override
  String get reportsExportPurposeTitle => 'غرض التصدير';

  @override
  String get reportsExportPurposeHint =>
      'مطلوب لعلامة التدقيق المائية (المسؤول، الوقت، الغرض).';

  @override
  String get reportsExportPurposeLabel => 'الغرض';

  @override
  String get reportsExportPurposeRequired => 'الغرض مطلوب.';

  @override
  String get reportsExportConfirm => 'بدء التصدير';

  @override
  String get reportsExportCancel => 'إلغاء';

  @override
  String get reportsExportAsyncNotice =>
      'عمليات التصدير التي تتجاوز 50,000 صف تُنشأ بشكل غير متزامن وتُسلَّم عبر رابط تنزيل محدود زمنياً. صادرات البيانات الشخصية تُوسَم بعلامة مائية تتضمن المسؤول والوقت والغرض (NFR-016).';
}
