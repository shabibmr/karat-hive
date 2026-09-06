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
  SUBSCRIPTION_REQUIRED: {
    en: 'An active subscription for this request type is required.',
    ar: 'مطلوب اشتراك نشط لنوع الطلب هذا.',
  },
  REQUEST_NOT_PUBLISHABLE: {
    en: 'This request is missing required fields and cannot be published.',
    ar: 'هذا الطلب تنقصه بعض الحقول المطلوبة ولا يمكن نشره.',
  },
  BULLION_BELOW_MINIMUM: {
    en: 'Bullion request value must meet the minimum threshold.',
    ar: 'قيمة طلب السبائك يجب أن تستوفي الحد الأدنى المطلوب.',
  },
  GOLD_RATE_UNAVAILABLE: {
    en: 'Live gold rate is currently unavailable for bullion pricing.',
    ar: 'سعر الذهب المباشر غير متوفر حالياً لتسعير السبائك.',
  },
  CONCURRENT_REQUEST_LIMIT: {
    en: 'You have reached the maximum number of live requests.',
    ar: 'لقد وصلت إلى الحد الأقصى من الطلبات النشطة.',
  },
  STRUCTURAL_FIELD_IMMUTABLE: {
    en: 'Structural fields cannot be modified after a request is published.',
    ar: 'لا يمكن تعديل الحقول الهيكلية بعد نشر الطلب.',
  },
  CONTACT_DETAILS_IN_TEXT: {
    en: 'Contact details (phone numbers or emails) are not allowed in notes.',
    ar: 'لا يُسمح بإدراج بيانات الاتصال (أرقام الهواتف أو البريد الإلكتروني) في الملاحظات.',
  },
  OAUTH_REQUIRED: {
    en: 'An external account binding is required before publishing.',
    ar: 'يلزم ربط حساب خارجي قبل النشر.',
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
