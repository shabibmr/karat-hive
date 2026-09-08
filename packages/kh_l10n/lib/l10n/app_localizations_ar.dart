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

  @override
  String get availableRequestsTitle => 'الطلبات المتاحة';

  @override
  String get failedToLoadMatchingRequests => 'تعذّر تحميل الطلبات المطابقة.';

  @override
  String get noMatchingRequests => 'لا توجد طلبات مطابقة';

  @override
  String get emptyFeedResetFiltersHint =>
      'جرّب إعادة تعيين عوامل التصفية النشطة لعرض المزيد من الطلبات.';

  @override
  String get emptyFeedBroadenHint =>
      'وسّع الفئات والمناطق، أو تأكد من وجود اشتراك نوع نشط لأنواع الطلبات التي تريد رؤيتها.';

  @override
  String get resetFilters => 'إعادة تعيين عوامل التصفية';

  @override
  String get viewSubscriptions => 'عرض الاشتراكات';

  @override
  String get allCaughtUp => 'أنت مطّلع على كل شيء';

  @override
  String requestTitleWithId(String requestId) {
    return 'الطلب $requestId';
  }

  @override
  String get couldNotLoadRequestDetails => 'تعذّر تحميل تفاصيل الطلب.';

  @override
  String get requestDetailsFallback => 'تفاصيل الطلب';

  @override
  String get customerSummary => 'ملخص العميل';

  @override
  String get customerNotes => 'ملاحظات العميل';

  @override
  String offersReceived(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عرض مستلم',
      many: '$count عرضًا مستلمًا',
      few: '$count عروض مستلمة',
      two: 'عرضان مستلمان',
      one: 'عرض واحد مستلم',
      zero: 'لا عروض مستلمة',
    );
    return '$_temp0';
  }

  @override
  String get competitorPricingHidden =>
      'أسعار وشروط المنافسين مخفية وفق قواعد السوق.';

  @override
  String get requestExpired => 'انتهت صلاحية الطلب';

  @override
  String get requestClosed => 'الطلب مغلق';

  @override
  String get makeAnOfferCp3 => 'قدّم عرضًا (المرحلة 3)';

  @override
  String get biddingOpensCp3 => 'يُفتح تقديم العروض في نقطة التحقق 3.';

  @override
  String get makeAnOffer => 'قدّم عرضًا';

  @override
  String get myOffersTitle => 'عروضي';

  @override
  String get submitOfferTitle => 'تقديم عرض';

  @override
  String get reviseOfferTitle => 'تعديل العرض';

  @override
  String get submitOfferAction => 'تقديم العرض';

  @override
  String get reviseOfferAction => 'حفظ التعديل';

  @override
  String get withdrawOfferAction => 'سحب العرض';

  @override
  String get withdrawOfferConfirmTitle => 'سحب هذا العرض؟';

  @override
  String get withdrawOfferConfirmBody =>
      'يمكنك تقديم عرض جديد لاحقًا إذا بقي الطلب مفتوحًا.';

  @override
  String get offerTabPending => 'قيد الانتظار';

  @override
  String get offerTabAccepted => 'مقبول';

  @override
  String get offerTabClosed => 'مغلق';

  @override
  String get offerStatePending => 'قيد الانتظار';

  @override
  String get offerStateAccepted => 'مقبول';

  @override
  String get offerStateRejected => 'مرفوض';

  @override
  String get offerStateExpired => 'منتهي';

  @override
  String get offerStateWithdrawn => 'مسحوب';

  @override
  String get offerStateUnknown => 'غير معروف';

  @override
  String get offerFallbackTitle => 'عرض';

  @override
  String get offerAwardedElsewhere => 'تم ترسية هذا الطلب على جهة أخرى.';

  @override
  String get offerConnectionCp4 => 'يُفتح الاتصال في نقطة التحقق 4.';

  @override
  String get offerSearchByReference => 'البحث بالمرجع';

  @override
  String get offerValidityLabel => 'مدة الصلاحية';

  @override
  String offerValidityHours(int hours) {
    return '$hours ساعة';
  }

  @override
  String offerAbsoluteExpiry(String when) {
    return 'ينتهي في $when';
  }

  @override
  String get offerPriceLabel => 'السعر المعروض';

  @override
  String get offerMakingChargesLabel => 'أجور التصنيع (اختياري)';

  @override
  String get offerRatePerGramLabel => 'السعر للجرام (اختياري)';

  @override
  String get offerDeliveryLabel => 'التسليم / الجاهزية';

  @override
  String get offerWarrantyLabel => 'الضمان / إعادة الشراء';

  @override
  String get offerNoteLabel => 'ملاحظة (بدون بيانات تواصل)';

  @override
  String get offerImagesHint => 'حتى 3 صور داعمة (اختياري).';

  @override
  String get offerCurrentTerms => 'الشروط الحالية';

  @override
  String get offerNewTerms => 'الشروط الجديدة';

  @override
  String offerRevisionsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تعديل متبقٍ',
      many: '$count تعديلًا متبقيًا',
      few: '$count تعديلات متبقية',
      two: 'تعديلان متبقيان',
      one: 'تعديل واحد متبقٍ',
      zero: 'لا تعديلات متبقية',
    );
    return '$_temp0';
  }

  @override
  String get offersEmptyBody =>
      'لا عروض بعد. قدّم عرضًا من طلب مطابق ليظهر هنا.';

  @override
  String get couldNotLoadOffers => 'تعذّر تحميل العروض.';

  @override
  String get couldNotLoadRequest => 'تعذّر تحميل الطلب.';

  @override
  String get couldNotLoadOffer => 'تعذّر تحميل العرض.';

  @override
  String get commonSubmitting => 'جارٍ الإرسال…';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get couldNotLoadDashboard => 'تعذّر تحميل لوحة التحكم.';

  @override
  String matchingRequestsWaiting(int count) {
    return '$count طلب(ات) مطابقة بانتظارك';
  }

  @override
  String get noNewRequestsRightNow => 'لا توجد طلبات جديدة حاليًا';

  @override
  String get latestMatches => 'أحدث المطابقات';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String offersExpiringWithin24h(int count) {
    return '$count تنتهي خلال 24 ساعة';
  }

  @override
  String get activeBidsAwaiting => 'عروض نشطة بانتظار رد العميل';

  @override
  String get offerManagementCp3 => 'تُفتح إدارة العروض في نقطة التحقق 3';

  @override
  String connectionsNoTalkYet(int count) {
    return '$count بدون محادثة بعد';
  }

  @override
  String get wonDealsChats => 'صفقات فائزة ومحادثات مباشرة مع العملاء';

  @override
  String get connectionsOpenCp4 => 'تُفتح الاتصالات في نقطة التحقق 4';

  @override
  String activeEntitlementsCount(int count) {
    return '$count استحقاق(ات) نشطة';
  }

  @override
  String get sortNewest => 'الأحدث';

  @override
  String get sortExpiringSoon => 'الأقرب لانتهاء الصلاحية';

  @override
  String get sortHighestValue => 'الأعلى قيمة';

  @override
  String get sortFewestOffers => 'الأقل عروضًا';

  @override
  String get requestTypeFindOrnament => 'البحث عن حلية';

  @override
  String get requestTypeCustomDesign => 'تصميم مخصص';

  @override
  String get requestTypeBullion => 'سبائك';

  @override
  String get requestTypeBullionInvestment => 'سبائك واستثمار';

  @override
  String get requestTypeRepairResize => 'إصلاح وتعديل المقاس';

  @override
  String get category => 'الفئة';

  @override
  String get couldNotLoadCategories => 'تعذّر تحميل الفئات';

  @override
  String get anyCategory => 'أي فئة';

  @override
  String get region => 'المنطقة';

  @override
  String get couldNotLoadRegions => 'تعذّر تحميل المناطق';

  @override
  String get anyRegion => 'أي منطقة';

  @override
  String get budgetAed => 'الميزانية (درهم)';

  @override
  String get minLabel => 'الحد الأدنى';

  @override
  String get maxLabel => 'الحد الأعلى';

  @override
  String get purityKarat => 'النقاء (قيراط)';

  @override
  String get couldNotLoadPresets => 'تعذّر تحميل الإعدادات المحفوظة';

  @override
  String get saveFilterPreset => 'حفظ إعداد التصفية';

  @override
  String get presetNameHint => 'اسم الإعداد (مثل خواتم دبي 22 قيراط)';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get couldNotLoadSubscriptionDetails => 'تعذّر تحميل تفاصيل الاشتراك.';

  @override
  String get planRate => 'سعر الخطة:';

  @override
  String aedPerMonth(String price) {
    return '$price درهم / شهر';
  }

  @override
  String get nextRenewal => 'التجديد القادم:';

  @override
  String gracePeriodActiveUntil(String date) {
    return 'فترة السماح نشطة حتى $date. جدّد الآن لتجنب فقدان أهلية المطابقة.';
  }

  @override
  String get subscriptionExpiredPaused =>
      'انتهى الاشتراك. طلبات المطابقة لهذه الفئة متوقفة حاليًا.';

  @override
  String get responded => 'تم الرد';

  @override
  String offerCountShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عرض',
      many: '$count عرضًا',
      few: '$count عروض',
      two: 'عرضان',
      one: 'عرض واحد',
      zero: 'لا عروض',
    );
    return '$_temp0';
  }

  @override
  String get budgetFrom => 'من ';

  @override
  String get budgetUpTo => 'حتى ';

  @override
  String get openBudget => 'ميزانية مفتوحة';

  @override
  String get requestFallback => 'طلب';

  @override
  String get specifications => 'المواصفات';

  @override
  String get purity => 'النقاء';

  @override
  String get weight => 'الوزن';

  @override
  String get budget => 'الميزانية';

  @override
  String get type => 'النوع';

  @override
  String get direction => 'الاتجاه';

  @override
  String get notes => 'ملاحظات';

  @override
  String karatGold(String karat) {
    return 'ذهب $karat قيراط';
  }

  @override
  String weightGrams(String weight) {
    return '$weight غ';
  }

  @override
  String weightGramsApprox(String weight) {
    return '$weight غ (تقريبًا)';
  }

  @override
  String budgetRangeAed(String min, String max) {
    return '$min - $max درهم';
  }

  @override
  String budgetRangeAedFlex(String min, String max) {
    return '$min - $max درهم (مرن)';
  }

  @override
  String budgetFromAed(String amount) {
    return 'من $amount درهم';
  }

  @override
  String budgetUpToAed(String amount) {
    return 'حتى $amount درهم';
  }

  @override
  String get budgetOpen => 'مفتوحة';

  @override
  String get dashboardTitle => 'لوحة التحكم';

  @override
  String get dashboardRating => 'التقييم';

  @override
  String get dashboardNoReviews => 'لا توجد تقييمات بعد';

  @override
  String get dashboardGoldRates => 'أسعار الذهب المرجعية';

  @override
  String get dashboardSubscriptions => 'اشتراكات النوع';

  @override
  String get dashboardNoSubscriptions => 'لا توجد اشتراكات نوع بعد';

  @override
  String get dashboardNewRequests => 'طلبات جديدة';

  @override
  String get dashboardPendingOffers => 'عروض معلّقة';

  @override
  String get dashboardActiveConnections => 'اتصالات نشطة';

  @override
  String get commonEmpty => 'لا يوجد شيء بعد';

  @override
  String get commonRetry => 'حاول مرة أخرى';

  @override
  String get commonLogout => 'تسجيل الخروج';

  @override
  String get appTitle => 'كارات هايف';

  @override
  String get authSignIn => 'تسجيل الدخول';

  @override
  String get authRegister => 'إنشاء حساب تاجر';

  @override
  String get authMobile => 'رقم الجوال';

  @override
  String get authEmail => 'البريد الإلكتروني للنشاط';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get authSendCode => 'إرسال الرمز';

  @override
  String get authResendCode => 'إعادة إرسال الرمز';

  @override
  String get authEnterCode => 'أدخل الرمز المكوّن من 6 أرقام';

  @override
  String get authVerify => 'تحقق';

  @override
  String get authOtpTab => 'الجوال والرمز';

  @override
  String get authPasswordTab => 'البريد وكلمة المرور';

  @override
  String get authSignInFailed =>
      'تعذّر تسجيل الدخول. تحقّق من اتصالك وحاول مرة أخرى.';

  @override
  String get authContinue => 'متابعة';

  @override
  String get authBackToSignIn => 'العودة لتسجيل الدخول';

  @override
  String get authOtpSentMobile => 'أرسلنا رمزاً إلى رقم جوالك.';

  @override
  String get authVerifyAndCreateAccount => 'تحقق وأنشئ الحساب';

  @override
  String get authRegistrationFailed => 'فشل التسجيل.';

  @override
  String get authLegalBusinessName => 'الاسم القانوني للنشاط';

  @override
  String get authTradingName => 'الاسم التجاري';

  @override
  String get authTradeLicenceNumber => 'رقم الرخصة التجارية';

  @override
  String get authLicenceExpiry => 'انتهاء الرخصة (YYYY-MM-DD)';

  @override
  String get authBusinessAddress => 'عنوان النشاط';

  @override
  String get authContactPerson => 'شخص الاتصال';

  @override
  String get authHomeRegion => 'المنطقة الرئيسية';

  @override
  String get authCategoriesYouServe => 'الفئات التي تخدمها';

  @override
  String get authRegionsYouServe => 'المناطق التي تخدمها';

  @override
  String get authSignInWithGoogle => 'تسجيل الدخول عبر Google';

  @override
  String get authSigningInWithGoogle => 'جارٍ تسجيل الدخول...';

  @override
  String authGoogleSignInFailed(String error) {
    return 'فشل تسجيل الدخول عبر Google: $error';
  }

  @override
  String get onboardingAwaitingTitle => 'جارٍ التحقق';

  @override
  String get onboardingPendingDocuments => 'ارفع مستندات نشاطك للمتابعة.';

  @override
  String get onboardingPendingAdmin => 'يقوم فريقنا بمراجعة مستنداتك.';

  @override
  String get onboardingCategoriesRequired =>
      'اختر الفئات والمناطق التي تخدمها.';

  @override
  String get onboardingRejected => 'يحتاج طلبك إلى تعديلات.';

  @override
  String get onboardingUploadKyc => 'رفع المستندات';

  @override
  String get onboardingResubmit => 'إعادة الإرسال للمراجعة';

  @override
  String get onboardingCategoriesRegions => 'الفئات والمناطق';

  @override
  String get onboardingSave => 'حفظ';

  @override
  String get onboardingAwayMode => 'وضع الغياب';

  @override
  String get onboardingAwayModeHint =>
      'إيقاف إشعارات الطلبات الجديدة دون تعطيل الحساب.';

  @override
  String get onboardingVolumePlaceholder =>
      'يظهر حجم الطلبات المطابقة بعد تفعيل المطابقة.';

  @override
  String get onboardingKycUploadHint =>
      'ارفع رخصتك التجارية وبطاقة الهوية الإماراتية للتحقق.';

  @override
  String get onboardingCategoriesHeading => 'الفئات';

  @override
  String get onboardingRegionsHeading => 'المناطق';

  @override
  String get onboardingCouldNotSave => 'تعذّر الحفظ.';

  @override
  String get commonDone => 'تم';

  @override
  String get uploadActionAdd => 'إضافة';

  @override
  String get uploadActionReplace => 'استبدال';

  @override
  String get uploadActionRetry => 'إعادة المحاولة';

  @override
  String get budgetRangeSeparator => ' - ';

  @override
  String get dashboardGoldRatesUnavailable => 'الأسعار المرجعية غير متاحة';

  @override
  String get lifecycleRegistered => 'مسجّل';

  @override
  String get lifecyclePendingVerification => 'قيد المراجعة';

  @override
  String get lifecycleVerified => 'موثّق';

  @override
  String get lifecycleActive => 'نشط';

  @override
  String get lifecycleSuspended => 'موقوف';

  @override
  String get lifecycleRejected => 'يحتاج تعديلات';

  @override
  String get lifecycleDeactivated => 'معطّل';

  @override
  String get lifecycleUnknown => 'غير معروف';

  @override
  String get relativeTimeJustNow => 'الآن';

  @override
  String relativeTimeMinutesAgo(int count) {
    return 'منذ $count د';
  }

  @override
  String relativeTimeHoursAgo(int count) {
    return 'منذ $count س';
  }

  @override
  String relativeTimeDaysAgo(int count) {
    return 'منذ $count ي';
  }

  @override
  String get expiryExpired => 'منتهية';

  @override
  String expiryDaysHoursLeft(int days, int hours) {
    return 'متبقي $daysي $hoursس';
  }

  @override
  String expiryHoursMinutesLeft(int hours, int minutes) {
    return 'متبقي $hoursس $minutesد';
  }

  @override
  String expiryMinutesSecondsLeft(int minutes, int seconds) {
    return 'متبقي $minutesد $secondsث';
  }

  @override
  String expirySecondsLeft(int seconds) {
    return 'متبقي $secondsث';
  }

  @override
  String expiryTimeRemainingSemantics(String text) {
    return 'الوقت المتبقي: $text';
  }

  @override
  String dealCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صفقة',
      many: '$count صفقة',
      few: '$count صفقات',
      two: 'صفقتان',
      one: 'صفقة واحدة',
      zero: 'لا صفقات',
    );
    return '$_temp0';
  }

  @override
  String get connectionsTitle => 'الاتصالات';

  @override
  String get connectionsEmptyBody =>
      'لا اتصالات بعد. تظهر العروض المقبولة هنا.';

  @override
  String get couldNotLoadConnections => 'تعذّر تحميل الاتصالات.';

  @override
  String get couldNotLoadConnection => 'تعذّر تحميل هذا الاتصال.';

  @override
  String get connectionSectionActive => 'نشط';

  @override
  String get connectionSectionClosed => 'مغلق';

  @override
  String get connectionStateActive => 'نشط';

  @override
  String get connectionStateClosed => 'مغلق';

  @override
  String get connectionStateUnknown => 'غير معروف';

  @override
  String get connectionTalk => 'تحدث';

  @override
  String get connectionCall => 'اتصال';

  @override
  String get connectionCopyNumber => 'نسخ الرقم';

  @override
  String get connectionCopied => 'تم النسخ';

  @override
  String get connectionClose => 'إغلاق الاتصال';

  @override
  String get connectionCloseConfirmTitle => 'إغلاق هذا الاتصال؟';

  @override
  String get connectionCloseConfirmBody =>
      'تبقى التفاصيل متاحة. تُفتح المراجعات في نقطة التحقق 5.';

  @override
  String get connectionClosedBanner => 'هذا الاتصال مغلق. تبقى التفاصيل متاحة.';

  @override
  String get connectionReviewsCp5 => 'تُفتح المراجعات في نقطة التحقق 5';

  @override
  String get connectionWhatsAppMissing =>
      'واتساب غير متاح. انسخ الرقم أو اتصل بدلاً من ذلك.';

  @override
  String get connectionCouldNotOpenTalk => 'تعذّر فتح واتساب.';

  @override
  String get connectionDetailTitle => 'اتصال';

  @override
  String get connectionIdentityRevealedAt => 'كُشف الهوية في';

  @override
  String get connectionAcceptedTerms => 'شروط العرض المقبول';

  @override
  String get connectionLeaveFeedback => 'ترك تقييم';

  @override
  String get connectionReport => 'إبلاغ';

  @override
  String get authWelcomeTitle => 'مرحبًا بك في كارات هايف';

  @override
  String get authWelcomeSubtitle =>
      'اطلب الذهب بطريقتك — اشترِ المشغولات، أو بِع الذهب القديم، أو اطلب العملات والسبائك. سجّل الدخول للبدء.';

  @override
  String get authContinueWithGoogle => 'المتابعة عبر Google';

  @override
  String get authSigningIn => 'جارٍ تسجيل الدخول…';

  @override
  String get authBiometricUnlock => 'الفتح بالمقاييس الحيوية';

  @override
  String get authBiometricUnlockHint =>
      'استخدم بصمة الوجه أو الإصبع على هذا الجهاز بدلاً من تسجيل الدخول مرة أخرى.';

  @override
  String get authLockoutTitle => 'لا يمكنك تسجيل الدخول';

  @override
  String get authLockoutHelp => 'تواصل مع الدعم إذا كنت تعتقد أن هذا خطأ.';

  @override
  String get authCompleteProfileTitle => 'أكمل إعداد حسابك';

  @override
  String get authCompleteProfileSubtitle =>
      'خطوة أخيرة. أكّد اسمك وتحقّق من رقم جوال حتى يتمكّن التجّار من التواصل معك عبر واتساب.';

  @override
  String get authDisplayNameLabel => 'اسمك';

  @override
  String authOtpSentTo(String mobile) {
    return 'أرسلنا رمزًا مكوّنًا من 6 أرقام إلى $mobile';
  }

  @override
  String get authAcceptTerms => 'أوافق على شروط الخدمة وسياسة الخصوصية';

  @override
  String get authAcceptTermsRequired =>
      'وافق على شروط الخدمة وسياسة الخصوصية للمتابعة.';

  @override
  String get authViewTerms => 'شروط الخدمة';

  @override
  String get authViewPrivacy => 'سياسة الخصوصية';

  @override
  String get authChangeNumber => 'تغيير الرقم';

  @override
  String get authCreateAccount => 'إنشاء حساب';

  @override
  String get authVerifyAndContinue => 'تحقّق وتابع';

  @override
  String get authPublishGateTitle => 'تحقّق عبر Google للنشر';

  @override
  String get authPublishGateBody =>
      'يتطلّب نشر الطلب تحقّقًا لمرة واحدة عبر Google. أما التصفّح وإنشاء مسودة الطلب فلا يتطلّبان ذلك.';

  @override
  String get authPublishGateAction => 'تحقّق عبر Google';
}
