import type { ErrorCode } from './error-codes';

export type UiLanguage = 'en' | 'ar';

const MESSAGES: Record<ErrorCode, Record<UiLanguage, string>> = {
  VALIDATION_FAILED: {
    en: 'Please check the highlighted fields and try again.',
    ar: 'يرجى مراجعة الحقول المحددة ثم المحاولة مرة أخرى.',
  },
  IDEMPOTENCY_KEY_REQUIRED: {
    en: 'This action requires an Idempotency-Key header.',
    ar: 'يتطلب هذا الإجراء ترويسة Idempotency-Key.',
  },
  IDEMPOTENCY_KEY_REUSED: {
    en: 'This Idempotency-Key was already used with a different body.',
    ar: 'تم استخدام مفتاح Idempotency-Key هذا مع محتوى مختلف.',
  },
  UNAUTHENTICATED: {
    en: 'Sign in to continue.',
    ar: 'يرجى تسجيل الدخول للمتابعة.',
  },
  TOKEN_EXPIRED: {
    en: 'Your session expired. Sign in again.',
    ar: 'انتهت صلاحية جلستك. يرجى تسجيل الدخول مرة أخرى.',
  },
  REFRESH_REUSE_DETECTED: {
    en: 'This session is no longer valid. Sign in again.',
    ar: 'هذه الجلسة لم تعد صالحة. يرجى تسجيل الدخول مرة أخرى.',
  },
  FORBIDDEN: {
    en: 'You do not have permission to do that.',
    ar: 'ليست لديك صلاحية للقيام بذلك.',
  },
  NOT_FOUND: {
    en: 'The requested item could not be found.',
    ar: 'تعذر العثور على العنصر المطلوب.',
  },
  CONFLICT: {
    en: 'This action is already in progress. Wait and try again.',
    ar: 'هذا الإجراء قيد التنفيذ. انتظر ثم حاول مرة أخرى.',
  },
  RATE_LIMITED: {
    en: 'Too many attempts. Please wait and try again.',
    ar: 'محاولات كثيرة. يرجى الانتظار ثم المحاولة مرة أخرى.',
  },
  INTERNAL: {
    en: 'Something went wrong. Please try again.',
    ar: 'حدث خطأ. يرجى المحاولة مرة أخرى.',
  },
  OTP_INVALID: {
    en: 'That code is incorrect. Check it and try again.',
    ar: 'الرمز غير صحيح. تحقق منه وحاول مرة أخرى.',
  },
  OTP_EXPIRED: {
    en: 'That code has expired. Request a new one.',
    ar: 'انتهت صلاحية الرمز. اطلب رمزًا جديدًا.',
  },
  OTP_RATE_LIMITED: {
    en: 'Too many codes requested. Wait an hour and try again.',
    ar: 'تم طلب رموز كثيرة. انتظر ساعة ثم حاول مرة أخرى.',
  },
  MOBILE_ALREADY_REGISTERED: {
    en: 'An account already exists for this mobile number. Sign in instead.',
    ar: 'يوجد حساب بالفعل لهذا الرقم. سجّل الدخول بدلاً من ذلك.',
  },
  EMAIL_ALREADY_REGISTERED: {
    en: 'An account already exists for this email address.',
    ar: 'يوجد حساب بالفعل لهذا البريد الإلكتروني.',
  },
  LICENCE_ALREADY_REGISTERED: {
    en: 'A business is already registered with this trade licence number.',
    ar: 'يوجد نشاط تجاري مسجّل بالفعل بهذا الرقم للرخصة التجارية.',
  },
  ACCOUNT_LOCKED: {
    en: 'Too many failed attempts. Your account is locked for a short period.',
    ar: 'محاولات فاشلة كثيرة. تم قفل حسابك لفترة قصيرة.',
  },
  ACCOUNT_SUSPENDED: {
    en: 'This account is suspended. Contact support.',
    ar: 'هذا الحساب موقوف. تواصل مع الدعم.',
  },
  ACCOUNT_DEACTIVATED: {
    en: 'This account has been deactivated.',
    ar: 'تم إلغاء تنشيط هذا الحساب.',
  },
  VENDOR_NOT_ACTIVE: {
    en: 'Your account is not yet active. Complete verification to continue.',
    ar: 'حسابك ليس نشطًا بعد. أكمل التحقق للمتابعة.',
  },
  ILLEGAL_VENDOR_TRANSITION: {
    en: 'That action is not allowed from your current account status.',
    ar: 'هذا الإجراء غير مسموح به من حالة حسابك الحالية.',
  },
  MEDIA_TYPE_REJECTED: {
    en: 'That file type or size is not accepted.',
    ar: 'نوع الملف أو حجمه غير مقبول.',
  },
  MEDIA_QUARANTINED: {
    en: 'That file failed a safety check and cannot be used.',
    ar: 'فشل الملف في فحص السلامة ولا يمكن استخدامه.',
  },
  MEDIA_NOT_READY: {
    en: 'That file is still being processed. Try again shortly.',
    ar: 'لا يزال الملف قيد المعالجة. حاول مرة أخرى بعد قليل.',
  },
  UPLOAD_NOT_COMPLETED: {
    en: 'The upload did not complete. Upload the file again.',
    ar: 'لم يكتمل الرفع. ارفع الملف مرة أخرى.',
  },
  TAXONOMY_IN_USE: {
    en: 'This taxonomy item is in use and cannot be deleted.',
    ar: 'عنصر التصنيف هذا قيد الاستخدام ولا يمكن حذفه.',
  },
  OAUTH_REQUIRED: {
    en: 'Verify your account before publishing a request.',
    ar: 'يرجى تأكيد حسابك قبل نشر الطلب.',
  },
  REQUEST_NOT_PUBLISHABLE: {
    en: 'Please complete all required fields before publishing.',
    ar: 'يرجى إكمال جميع الحقول المطلوبة قبل النشر.',
  },
  BULLION_BELOW_MINIMUM: {
    en: 'Bullion requests must meet the minimum indicative value.',
    ar: 'يجب أن تستوفي طلبات السبائك الحد الأدنى للقيمة التقديرية.',
  },
  GOLD_RATE_UNAVAILABLE: {
    en: 'Reference gold rate is temporarily unavailable. Please try again shortly.',
    ar: 'سعر الذهب المرجعي غير متوفر حالياً. يرجى المحاولة بعد قليل.',
  },
  CONCURRENT_REQUEST_LIMIT: {
    en: 'You have reached the maximum number of active requests.',
    ar: 'لقد وصلت إلى الحد الأقصى للطلبات النشطة.',
  },
  STRUCTURAL_FIELD_IMMUTABLE: {
    en: 'Structural details of a published request cannot be modified.',
    ar: 'لا يمكن تعديل التفاصيل الهيكلية للطلب بعد النشر.',
  },
  REQUEST_NOT_CANCELLABLE: {
    en: 'This request cannot be cancelled because an offer has already been accepted.',
    ar: 'لا يمكن إلغاء هذا الطلب لأنه تم قبول عرض بالفعل.',
  },
  CONTACT_DETAILS_IN_TEXT: {
    en: 'Contact details (phone numbers, email addresses, or URLs) are not allowed in notes.',
    ar: 'لا يُسمح بإدراج تفاصيل الاتصال (أرقام الهواتف أو البريد الإلكتروني أو الروابط) في الملاحظات.',
  },
  NOT_IN_MATCH_SET: {
    en: 'You do not have access to this request.',
    ar: 'ليس لديك صلاحية الوصول إلى هذا الطلب.',
  },
  SUBSCRIPTION_REQUIRED: {
    en: 'An active type subscription is required to perform this action.',
    ar: 'مطلوب اشتراك نشط لتنفيذ هذا الإجراء.',
  },
  OFFER_NOT_OPEN: {
    en: 'This request is not currently accepting offers.',
    ar: 'هذا الطلب لا يقبل العروض حالياً.',
  },
  OFFER_ALREADY_PENDING: {
    en: 'You already have a pending offer on this request. Revise your existing offer instead.',
    ar: 'لديك بالفعل عرض معلق على هذا الطلب. يرجى تعديل عرضك الحالي بدلاً من ذلك.',
  },
  OFFER_REVISION_LIMIT: {
    en: 'Maximum number of revisions reached for this offer.',
    ar: 'تم الوصول إلى الحد الأقصى لتعديل هذا العرض.',
  },
  OFFER_NOT_PENDING: {
    en: 'This offer is no longer pending.',
    ar: 'هذا العرض لم يعد معلقاً.',
  },
  OFFER_EXPIRED: {
    en: 'This offer has expired.',
    ar: 'انتهت صلاحية هذا العرض.',
  },
  OFFER_ALREADY_ACCEPTED: {
    en: 'An offer has already been accepted for this request.',
    ar: 'تم قبول عرض آخر بالفعل لهذا الطلب.',
  },
  CONNECTION_CLOSED: {
    en: 'This connection is closed.',
    ar: 'هذا الاتصال مغلق.',
  },
  NOT_A_PARTY: {
    en: 'You are not a party to this connection.',
    ar: 'لست طرفاً في هذا الاتصال.',
  },
  REVIEW_ALREADY_EXISTS: {
    en: 'You have already submitted a review for this connection.',
    ar: 'لقد قمت بالفعل بتقديم تقييم لهذا الاتصال.',
  },
  REVIEW_EDIT_WINDOW_CLOSED: {
    en: 'The edit window for this review has closed.',
    ar: 'انتهت فترة تعديل هذا التقييم.',
  },
  SETTING_OUT_OF_RANGE: {
    en: 'The setting value is outside the allowed range.',
    ar: 'قيمة الإعداد خارج النطاق المسموح به.',
  },
  EXPORT_IN_PROGRESS: {
    en: 'An export is already in progress. Please wait for it to complete.',
    ar: 'عملية التصدير جارية بالفعل. يرجى الانتظار حتى تكتمل.',
  },
  ADMIN_SELF_REGISTRATION_FORBIDDEN: {
    en: 'Admin self-registration is forbidden.',
    ar: 'التسجيل الذاتي للمشرف غير مسموح به.',
  },
};

export function resolveLanguage(
  acceptLanguage: string | undefined,
  preferred?: UiLanguage,
): UiLanguage {
  if (preferred === 'ar' || preferred === 'en') return preferred;
  const header = (acceptLanguage ?? '').toLowerCase();
  if (header.startsWith('ar')) return 'ar';
  return 'en';
}

export function messageFor(code: ErrorCode, language: UiLanguage): string {
  return MESSAGES[code][language];
}
