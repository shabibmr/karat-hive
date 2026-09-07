/** Placeholder EN/AR copy keyed by event name. Final copy is Notification-Catalogue.md. */

export type NotificationCopy = {
  titleEn: string;
  titleAr: string;
  bodyEn: string;
  bodyAr: string;
};

const PLACEHOLDER_COPY: Record<string, NotificationCopy> = {
  'request.matched': {
    titleEn: 'New matched Request',
    titleAr: 'طلب مطابق جديد',
    bodyEn: 'A new Request matches your categories and region.',
    bodyAr: 'طلب جديد يطابق فئاتك ومنطقتك.',
  },
  'request.edited': {
    titleEn: 'A Request you offered on was edited',
    titleAr: 'تم تعديل طلب قدّمت عليه عرضاً',
    bodyEn: 'The Customer updated a Request you have a pending Offer on.',
    bodyAr: 'حدّث العميل طلباً لديك عرض معلّق عليه.',
  },
  'request.cancelled': {
    titleEn: 'A Request you offered on was cancelled',
    titleAr: 'تم إلغاء طلب قدّمت عليه عرضاً',
    bodyEn: 'The Customer cancelled the Request. Your pending Offer was withdrawn.',
    bodyAr: 'ألغى العميل الطلب. تم سحب عرضك المعلّق.',
  },
  'request.expired.customer': {
    titleEn: 'Your Request expired',
    titleAr: 'انتهت صلاحية طلبك',
    bodyEn: 'Your Request reached the 48-hour limit and is no longer live.',
    bodyAr: 'بلغ طلبك حد 48 ساعة ولم يعد نشطاً.',
  },
  'request.expired.vendor': {
    titleEn: 'A Request you offered on expired',
    titleAr: 'انتهت صلاحية طلب قدّمت عليه عرضاً',
    bodyEn: 'The Request expired. Your pending Offer was withdrawn.',
    bodyAr: 'انتهت صلاحية الطلب. تم سحب عرضك المعلّق.',
  },
  'request.expiry.warning': {
    titleEn: 'Your Request expires soon',
    titleAr: 'طلبك على وشك الانتهاء',
    bodyEn: 'Your Request expires in about 6 hours.',
    bodyAr: 'ينتهي طلبك خلال نحو 6 ساعات.',
  },
  'request.draft.purge_warning': {
    titleEn: 'An unfinished Request will be deleted',
    titleAr: 'سيتم حذف طلب غير مكتمل',
    bodyEn: 'An unfinished Request will be deleted in 3 days.',
    bodyAr: 'سيتم حذف طلب غير مكتمل خلال 3 أيام.',
  },
  'offer.submitted.first': {
    titleEn: 'You have a new Offer',
    titleAr: 'لديك عرض جديد',
    bodyEn: 'A Vendor submitted an Offer on your Request.',
    bodyAr: 'قدّم تاجر عرضاً على طلبك.',
  },
  'offer.submitted.subsequent': {
    titleEn: 'You have another Offer',
    titleAr: 'لديك عرض آخر',
    bodyEn: 'Another Vendor submitted an Offer on your Request.',
    bodyAr: 'قدّم تاجر آخر عرضاً على طلبك.',
  },
  'offer.revised': {
    titleEn: 'An Offer was revised',
    titleAr: 'تم تعديل عرض',
    bodyEn: 'An Offer was revised from {previousPrice} to {newPrice} AED.',
    bodyAr: 'عُدّل عرض من {previousPrice} إلى {newPrice} درهم.',
  },
  'offer.withdrawn': {
    titleEn: 'An Offer was withdrawn',
    titleAr: 'تم سحب عرض',
    bodyEn: 'A Vendor withdrew an Offer on your Request.',
    bodyAr: 'سحب تاجر عرضاً على طلبك.',
  },
  'offer.expiry.warning': {
    titleEn: 'Your Offer expires soon',
    titleAr: 'عرضك على وشك الانتهاء',
    bodyEn: 'Your Offer expires in about 6 hours.',
    bodyAr: 'ينتهي عرضك خلال نحو 6 ساعات.',
  },
  'offer.expired.vendor': {
    titleEn: 'Your Offer expired',
    titleAr: 'انتهت صلاحية عرضك',
    bodyEn: 'Your Offer reached its validity and is no longer pending.',
    bodyAr: 'بلغ عرضك مدة صلاحيته ولم يعد معلّقاً.',
  },
  'offer.expired.customer': {
    titleEn: 'An Offer expired',
    titleAr: 'انتهت صلاحية عرض',
    bodyEn: 'An Offer on your Request expired.',
    bodyAr: 'انتهت صلاحية عرض على طلبك.',
  },
  'offer.accepted.winner': {
    titleEn: 'Your Offer was accepted',
    titleAr: 'تم قبول عرضك',
    bodyEn: 'The Customer accepted your Offer. You are now connected.',
    bodyAr: 'قبل العميل عرضك. أصبحتما متصلين الآن.',
  },
  // BR-008 / AD-ASYNC-03: no price, no winner identity.
  'offer.accepted.loser': {
    titleEn: 'The Customer selected another Vendor',
    titleAr: 'اختار العميل تاجراً آخر',
    bodyEn: 'The Customer accepted a different Offer on this Request.',
    bodyAr: 'قبل العميل عرضاً مختلفاً على هذا الطلب.',
  },
  'offer.accepted.customer': {
    titleEn: 'You are now connected',
    titleAr: 'أصبحتما متصلين الآن',
    bodyEn: 'Your Acceptance created a Connection. Identities are now revealed.',
    bodyAr: 'أنشأ قبولك اتصالاً. تم الكشف عن الهويتين الآن.',
  },
  'connection.closed': {
    titleEn: 'Connection closed',
    titleAr: 'أُغلق الاتصال',
    bodyEn: 'This Connection is closed. Identity history is retained.',
    bodyAr: 'أُغلق هذا الاتصال. يُحتفظ بسجل الهوية.',
  },
  'connection.closed.review': {
    titleEn: 'Leave a review',
    titleAr: 'اترك تقييماً',
    bodyEn: 'This Connection closed. You can leave a review.',
    bodyAr: 'أُغلق هذا الاتصال. يمكنك ترك تقييم.',
  },
  'review.published': {
    titleEn: 'You received a new review',
    titleAr: 'وصلك تقييم جديد',
    bodyEn: 'A counterparty published a review of you.',
    bodyAr: 'نشر الطرف المقابل تقييماً عنك.',
  },
  'vendor.verification.decided': {
    titleEn: 'Verification update',
    titleAr: 'تحديث التحقق',
    bodyEn: 'Your verification decision is {decision}.',
    bodyAr: 'قرار التحقق الخاص بك هو {decision}.',
  },
  'announcement.scheduled': {
    titleEn: 'Platform announcement',
    titleAr: 'إعلان من المنصة',
    bodyEn: 'Karat Hive posted an announcement.',
    bodyAr: 'نشرت قيراط هايف إعلاناً.',
  },
  'vendor.document.expiring': {
    titleEn: 'A document expires in 30 days',
    titleAr: 'وثيقة تنتهي خلال 30 يوماً',
    bodyEn: 'A KYC document expires in 30 days.',
    bodyAr: 'تنتهي صلاحية وثيقة اعرف عميلك خلال 30 يوماً.',
  },
};

function substitute(template: string, vars: Record<string, string>): string {
  return template.replace(/\{(\w+)\}/g, (_, key: string) => vars[key] ?? '');
}

export function renderPlaceholderCopy(
  key: string,
  vars: Record<string, string> = {},
): NotificationCopy {
  const tpl = PLACEHOLDER_COPY[key] ?? {
    titleEn: key,
    titleAr: key,
    bodyEn: key,
    bodyAr: key,
  };
  return {
    titleEn: substitute(tpl.titleEn, vars),
    titleAr: substitute(tpl.titleAr, vars),
    bodyEn: substitute(tpl.bodyEn, vars),
    bodyAr: substitute(tpl.bodyAr, vars),
  };
}
