# Karat Hive — Notification Catalogue

| | |
|---|---|
| **Product** | Karat Hive — Digital Jewellery Marketplace |
| **Document** | EN/AR notification copy per dispatch trigger (pre-code catalogue) |
| **Version** | 0.3-remaining-rows |
| **Status** | Draft — all §7.2 trigger copy authored (CP5-I01.2 Vendor/Admin; CP5-I01.3 Customer, dual-role Customer, announcement, security). |
| **Date** | 8 September 2026 |
| **Source of truth** | [`docs/Async-Contract.md`](Async-Contract.md) §7 (triggers, recipients, channels, deep links, `is_critical`) · [`docs/Spec-Document-Sequence.md`](Spec-Document-Sequence.md) §4.4 · [`docs/Requirements-Spec-v1.3.md`](Requirements-Spec-v1.3.md) `FR-CUS-032`, `FR-VEN-026`, `FR-SYS-008` · [`CONTEXT.md`](../CONTEXT.md) |
| **Companion** | [`docs/Async-Contract.md`](Async-Contract.md) owns *when* and *to whom*; this document owns *wording*. |
| **Encoding target** | `notification.title_en` / `title_ar` / `body_en` / `body_ar` / `deep_link` · `kh_l10n` template keys |

---

## Table of Contents

1. [Purpose and status](#1-purpose-and-status)
2. [Row schema](#2-row-schema)
3. [Trigger index](#3-trigger-index)
4. [Vendor-facing rows](#4-vendor-facing-rows) — **CP5-I01.2**
5. [Remaining rows](#5-remaining-rows) — **CP5-I01.3**
6. [Copy conventions](#6-copy-conventions)
- [Appendix A — Revision history](#appendix-a--revision-history)

---

## 1. Purpose and status

[`Async-Contract.md`](Async-Contract.md) §7 fixes the notification *mechanism*: which outbox event fires, who the recipient is, which channels run, whether `is_critical` bypasses preferences and quiet hours, and the client deep link. It deliberately does not write bodies.

**This document is the missing copy layer** ([`Spec-Document-Sequence.md`](Spec-Document-Sequence.md) document #4). One catalogue row per trigger in Async-Contract §7.2. It supplies EN/AR title and body, the `kh_l10n` template key, placeholders, quiet-hours behaviour relative to §7.1, and whether a Vendor in `Vshell` (Awaiting-Approval) may receive the notification.

**What this document does not do.** It does not invent event types, recipients, channels, deep links, or `is_critical` flags — those stay in Async-Contract §7.2. It does not restate dispatch retry or idempotency (`FR-SYS-008.3`, `FR-SYS-008.5`). It does not invent competing-Vendor identity or price in any payload (`BR-008`).

**Authoring waves**

| Wave | Task | Section | Scope |
|---|---|---|---|
| 0 | CP5-I01.1 | this skeleton | Schema, trigger index, empty row shells |
| 1 | CP5-I01.2 | [§4](#4-vendor-facing-rows) | Rows where a Vendor is a recipient |
| 2 | CP5-I01.3 | [§5](#5-remaining-rows) | Customer-only, announcement, and security-critical rows |

Domain nouns follow [`CONTEXT.md`](../CONTEXT.md) exactly. A Request is never a "listing"; an Offer is never a "bid"; a Connection is never a "chat"; Fan-out is never a bare "broadcast".

---

## 2. Row schema

Every filled catalogue row uses these columns. Values in the **Fixed from Async-Contract §7.2** group are cited, not re-decided. Values in the **Copy (this document)** group are authored in CP5-I01.2 / CP5-I01.3.

| Column | Owner | Notes |
|---|---|---|
| Trigger | Async-Contract §7.2 | Inventory §18 label |
| Event | Async-Contract §7.2 / §4 | Dotted event token; do not invent new ones |
| Recipient | Async-Contract §7.2 | User-id source; role using CONTEXT terms |
| Channels | Async-Contract §7.2 | `IN_APP` / `PUSH` / `EMAIL` / `SMS` (`AD-ASYNC-07`) |
| `is_critical` | Async-Contract §7.2 | `true` bypasses preferences and quiet hours (§7.1, `FR-SYS-008.2`) |
| Deep link | Async-Contract §7.2 | Client route in `notification.deep_link` |
| Template key | **This document** | `kh_l10n` key — TBD until wave fill |
| Placeholders | **This document** | Named tokens only; never a competing Vendor’s identity, price, or terms (`BR-008`) |
| Title EN / Title AR | **This document** | ≤ 200 chars (schema `title_en` / `title_ar`) — TBD |
| Body EN / Body AR | **This document** | TBD |
| Quiet-hours behaviour | **This document** | Cite §7.1: honour preferences when `is_critical = no`; deliver when `is_critical = yes` |
| `Vshell` allowed | **This document** | Whether a Vendor in Awaiting-Approval may receive this row (`Vshell` auth class in inventory §6) — TBD |

**Status marks used in empty shells**

| Mark | Meaning |
|---|---|
| *cited* | Copied from Async-Contract §7.2 for traceability |
| — TBD | Awaits CP5-I01.2 or CP5-I01.3 |
| — n/a | Column does not apply to this recipient role |

---

## 3. Trigger index

Exact trigger set from [`Async-Contract.md`](Async-Contract.md) §7.2. **No events are added here.** Fill wave assigns which later task authors the copy columns.

| # | Trigger (inventory §18) | Event | Recipient | Fill wave |
|---|---|---|---|---|
| 1 | New matched Request | `request.matched` | Vendor | CP5-I01.2 |
| 2 | First Offer received | `offer.submitted` (`isFirstOfferOnRequest`) | Customer | CP5-I01.3 |
| 3 | Subsequent Offer received | `offer.submitted` | Customer | CP5-I01.3 |
| 4 | Offer revised | `offer.revised` | Customer | CP5-I01.3 |
| 5 | Offer withdrawn | `offer.withdrawn` | Customer | CP5-I01.3 |
| 6 | Request approaching expiry (T−6 h) | `request.expiry.warning` | Customer | CP5-I01.3 |
| 7 | Request expired | `request.expired` | Customer + each affected Vendor | CP5-I01.2 |
| 8 | Request edited | `request.edited` | Vendors with a pending Offer | CP5-I01.2 |
| 9 | Request cancelled | `request.cancelled` | each affected Vendor | CP5-I01.2 |
| 10 | Unfinished draft (T−3 d) | `request.draft.purge_warning` | Customer | CP5-I01.3 |
| 11 | Offer approaching expiry (T−6 h) | `offer.expiry.warning` | Vendor (own Offer) | CP5-I01.2 |
| 12 | Offer expired | `offer.expired` | Vendor + Customer | CP5-I01.2 |
| 13 | Offer accepted (winner) | `offer.accepted` | winner Vendor | CP5-I01.2 |
| 14 | Offer rejected (loser) | `offer.accepted` (per `rejectedOfferIds`) | loser Vendor | CP5-I01.2 |
| 15 | Connected (Customer confirmation) | `offer.accepted` | Customer | CP5-I01.3 |
| 16 | Connection closed | `connection.closed` | Customer + Vendor | CP5-I01.2 |
| 17 | Review reminder | `connection.closed` | Customer + Vendor | CP5-I01.2 |
| 18 | New review received | `review.published` | reviewed party | CP5-I01.2 |
| 19 | Verification outcome | `vendor.verification.decided` | Vendor | CP5-I01.2 |
| 20 | Document / KYC nearing expiry | `vendor.document.expiring` | Vendor + Admins | CP5-I01.2 |
| 21 | Platform announcement | `announcement.scheduled` | expanded `audience` | CP5-I01.3 |
| 22 | Security-critical account events | *inline `notifications:dispatch` `[PROPOSED]`* | affected user | CP5-I01.3 |

Rows 7, 12, 16, 17 and 20 notify more than one role under a single §7.2 trigger. Wave CP5-I01.2 authors Vendor-facing (and Admin, where listed) copy; CP5-I01.3 authors the separate Customer templates where wording or deep link differs. Event types are not forked.

---

## 4. Vendor-facing rows

**Task:** CP5-I01.2. **Status:** filled — Vendor EN/AR copy (and Admin for #20). Customer wording for dual-role triggers (#7, #12, #16, #17) and Customer-as-reviewed-party (#18) is in [§5](#5-remaining-rows); event types are not forked.

Fixed columns are cited from Async-Contract §7.2. Copy columns authored here. Quiet hours for every row below: **honour preferences and quiet hours at dispatch** (§7.1) because `is_critical = no`.

| # | Trigger | Event | Recipient | Channels | `is_critical` | Deep link | Template key | Placeholders | Title EN | Title AR | Body EN | Body AR | Quiet hours | `Vshell` allowed |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | New matched Request | `request.matched` *cited* | Vendor | in-app, push *cited* | no *cited* | `/requests/{requestId}` *cited* | `notif.vendor.request_matched` | `{categoryLabel}`, `{regionLabel}`, `{requestType}` | New matched Request | طلب مطابق جديد | A new Request ({requestType}) in {categoryLabel} · {regionLabel} matches your profile. Open it to review and submit an Offer. | طلب جديد ({requestType}) في {categoryLabel} · {regionLabel} يطابق ملفك. افتحه للمراجعة وتقديم عرض. | honour (§7.1) | no |
| 7 | Request expired | `request.expired` *cited* | each affected Vendor *(Customer → §5)* | in-app, push *cited* | no *cited* | `/requests/{requestId}` *cited* | `notif.vendor.request_expired` | `{requestId}` | Request expired | انتهت صلاحية الطلب | A Request you offered on has expired. Your Offer was withdrawn by the system. | انتهت صلاحية طلب قدّمت عليه عرضًا. سحب النظام عرضك. | honour (§7.1) | no |
| 8 | Request edited | `request.edited` *cited* | Vendors with a pending Offer | in-app, push *cited* | no *cited* | `/requests/{requestId}` *cited* | `notif.vendor.request_edited` | `{requestId}` | Request edited | تم تعديل الطلب | A Request you offered on was edited. Review the changes before your Offer expires. | عُدّل طلب قدّمت عليه عرضًا. راجع التغييرات قبل انتهاء صلاحية عرضك. | honour (§7.1) | no |
| 9 | Request cancelled | `request.cancelled` *cited* | each affected Vendor | in-app, push *cited* | no *cited* | `/requests/{requestId}` *cited* | `notif.vendor.request_cancelled` | `{requestId}` | Request cancelled | تم إلغاء الطلب | A Request you offered on was cancelled. Your Offer was withdrawn. | أُلغي طلب قدّمت عليه عرضًا. تم سحب عرضك. | honour (§7.1) | no |
| 11 | Offer approaching expiry (T−6 h) | `offer.expiry.warning` *cited* | Vendor (own Offer) | in-app, push *cited* | no *cited* | `/offers/{offerId}` *cited* | `notif.vendor.offer_expiry_warning` | `{hoursRemaining}`, `{offerId}`, `{expiresAt}` | Your Offer expires soon | عرضك على وشك الانتهاء | Your Offer expires in about {hoursRemaining} hours. Revise it if you still want it considered. | ينتهي عرضك خلال حوالي {hoursRemaining} ساعات. عدّله إن رغبت أن يبقى معروضًا. | honour (§7.1) | no |
| 12 | Offer expired | `offer.expired` *cited* | Vendor *(Customer → §5)* | in-app, push *cited* | no *cited* | `/offers/{offerId}` *cited* (Vendor route) | `notif.vendor.offer_expired` | `{offerId}`, `{requestId}` | Your Offer expired | انتهت صلاحية عرضك | Your Offer on this Request has expired and is no longer available for Acceptance. | انتهت صلاحية عرضك على هذا الطلب ولم يعد متاحًا للقبول. | honour (§7.1) | no |
| 13 | Offer accepted (winner) | `offer.accepted` *cited* | winner Vendor | in-app, push *cited* | no *cited* | `/connections/{connectionId}` *cited* | `notif.vendor.offer_accepted_winner` | `{connectionId}`, `{requestId}` | Your Offer was accepted | تم قبول عرضك | The Customer accepted your Offer. Identity Reveal is complete — open the Connection to Talk. | قبل العميل عرضك. اكتملت عملية كشف الهوية — افتح الاتصال ثم اضغط «تحدث». | honour (§7.1) | no |
| 14 | Offer rejected (loser) | `offer.accepted` *cited* | loser Vendor | in-app, push *cited* | no *cited* | `/requests/{requestId}` *cited* — **no price, no identity** | `notif.vendor.offer_accepted_loser` | `{requestId}` *(own `offerId` only; never join `acceptedOfferId` — `BR-008`, `AD-ASYNC-03`)* | Offer not selected | لم يُختر عرضك | The Customer selected another Vendor for this Request. | اختار العميل تاجرًا آخر لهذا الطلب. | honour (§7.1) | no |
| 16 | Connection closed | `connection.closed` *cited* | Vendor *(Customer → §5)* | in-app *cited* | no *cited* | `/connections/{connectionId}` *cited* | `notif.vendor.connection_closed` | `{connectionId}`, `{closedBy}` | Connection closed | تم إغلاق الاتصال | This Connection was closed. Details remain available. | أُغلق هذا الاتصال. تبقى التفاصيل متاحة. | honour (§7.1) | no |
| 17 | Review reminder | `connection.closed` *cited* | Vendor *(Customer → §5)* | in-app, push *cited* | no *cited* | `/connections/{connectionId}/review` *cited* | `notif.vendor.review_reminder` | `{connectionId}` | Leave a Review | اترك مراجعة | This Connection is closed. Leave a Review for the other party while details are fresh. | أُغلق هذا الاتصال. اترك مراجعة للطرف الآخر بينما التفاصيل ما زالت حاضرة. | honour (§7.1) | no |
| 18 | New review received | `review.published` *cited* | reviewed Vendor *(Customer-as-subject → §5)* | in-app, push *cited* | no *cited* | Vendor reviews screen *cited* | `notif.vendor.review_published` | `{reviewId}`, `{connectionId}` | New Review received | وصلت مراجعة جديدة | You received a new Review on a Connection. | تلقيت مراجعة جديدة على أحد اتصالاتك. | honour (§7.1) | no |
| 19 | Verification outcome | `vendor.verification.decided` *cited* | Vendor | in-app, push, email *cited* | no *cited* | `/me/vendor` *cited* | `notif.vendor.verification_decided.{decision}` (`verified` \| `rejected` \| `more_info`) | `{decision}`, `{reason}` (required when `REJECTED` / `MORE_INFO`) | **verified:** You're verified · **rejected:** Verification not approved · **more_info:** More information needed | **verified:** تم التحقق من حسابك · **rejected:** لم يُعتمد التحقق · **more_info:** يلزم معلومات إضافية | **verified:** Your Verification was approved. Finish marketplace-access steps to receive matched Requests. · **rejected:** Your Verification was not approved. {reason} · **more_info:** Provide the requested information to continue Verification. {reason} | **verified:** اعتُمد التحقق من حسابك. أكمل خطوات الوصول إلى السوق لتلقي الطلبات المطابقة. · **rejected:** لم يُعتمد التحقق من حسابك. {reason} · **more_info:** قدّم المعلومات المطلوبة لمتابعة التحقق. {reason} | honour (§7.1) | yes |
| 20 | Document / KYC nearing expiry | `vendor.document.expiring` *cited* | Vendor | in-app, push, email *cited* | no *cited* | `/me/vendor/documents` *cited* | `notif.vendor.document_expiring` | `{documentType}`, `{daysRemaining}`, `{expiresOn}` | Document expires soon | وثيقة على وشك الانتهاء | Your {documentType} expires in {daysRemaining} days ({expiresOn}). Upload a renewed document to stay eligible. | تنتهي صلاحية {documentType} خلال {daysRemaining} يومًا ({expiresOn}). ارفع وثيقة مجدّدة للبقاء مؤهلًا. | honour (§7.1) | yes |
| 20 | Document / KYC nearing expiry | `vendor.document.expiring` *cited* | Admins | in-app, push, email *cited* | no *cited* | `/me/vendor/documents` *cited* | `notif.admin.document_expiring` | `{documentType}`, `{daysRemaining}`, `{expiresOn}`, `{vendorProfileId}` | Vendor document expiring | وثيقة تاجر على وشك الانتهاء | A Vendor’s {documentType} expires in {daysRemaining} days ({expiresOn}). Profile {vendorProfileId}. | تنتهي صلاحية {documentType} لأحد التجار خلال {daysRemaining} يومًا ({expiresOn}). الملف {vendorProfileId}. | honour (§7.1) | — n/a |

---

## 5. Remaining rows

**Task:** CP5-I01.3. **Status:** filled — Customer-only rows, dual-role Customer templates (#7, #12, #16, #17, #18), announcement pass-through, and security-critical variants. Fixed columns cited from Async-Contract §7.2. No new event types.

Quiet hours: **honour (§7.1)** when `is_critical = no`; **bypass (critical)** when `is_critical = yes` (#22) or when an announcement’s `critical = true` (#21).

| # | Trigger | Event | Recipient | Channels | `is_critical` | Deep link | Template key | Placeholders | Title EN | Title AR | Body EN | Body AR | Quiet hours | `Vshell` allowed |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 2 | First Offer received | `offer.submitted` (`isFirstOfferOnRequest`) *cited* | Customer | in-app, push *cited* | no *cited* | `/requests/{requestId}/offers` *cited* | `notif.customer.offer_submitted_first` | `{requestId}`, `{offerId}` *(never Vendor identity — `BR-006`)* | You have a new Offer | لديك عرض جديد | You received the first Offer on your Request. Open Offers to review price and terms. | وصل أول عرض على طلبك. افتح العروض لمراجعة السعر والشروط. | honour (§7.1) | — n/a |
| 3 | Subsequent Offer received | `offer.submitted` *cited* | Customer | in-app, push *cited* | no *cited* | `/requests/{requestId}/offers` *cited* | `notif.customer.offer_submitted_subsequent` | `{requestId}`, `{offerId}` *(never Vendor identity — `BR-006`)* | Another Offer received | وصل عرض آخر | Another Offer arrived on your Request. Open Offers to compare. | وصل عرض آخر على طلبك. افتح العروض للمقارنة. | honour (§7.1) | — n/a |
| 4 | Offer revised | `offer.revised` *cited* | Customer | in-app, push *cited* | no *cited* | `/requests/{requestId}/offers` *cited* | `notif.customer.offer_revised` | `{requestId}`, `{offerId}`, `{previousPrice}`, `{newPrice}` *(never Vendor identity — `BR-006`)* | An Offer was revised | تم تعديل عرض | An Offer on your Request was revised from {previousPrice} to {newPrice}. Review the updated terms. | عُدّل عرض على طلبك من {previousPrice} إلى {newPrice}. راجع الشروط المحدَّثة. | honour (§7.1) | — n/a |
| 5 | Offer withdrawn | `offer.withdrawn` *cited* | Customer | in-app, push *cited* | no *cited* | `/requests/{requestId}/offers` *cited* | `notif.customer.offer_withdrawn` | `{requestId}`, `{offerId}` *(never Vendor identity — `BR-006`)* | An Offer was withdrawn | تم سحب عرض | A Vendor withdrew an Offer on your Request. | سحب تاجر عرضًا على طلبك. | honour (§7.1) | — n/a |
| 6 | Request approaching expiry (T−6 h) | `request.expiry.warning` *cited* | Customer | in-app, push *cited* | no *cited* | `/requests/{requestId}` *cited* | `notif.customer.request_expiry_warning` | `{requestId}`, `{hoursRemaining}`, `{expiresAt}` | Your Request expires soon | طلبك على وشك الانتهاء | Your Request expires in about {hoursRemaining} hours. No extension is available. | ينتهي طلبك خلال حوالي {hoursRemaining} ساعات. لا يتوفر تمديد. | honour (§7.1) | — n/a |
| 7 | Request expired | `request.expired` *cited* | Customer | in-app, push *cited* | no *cited* | `/requests/{requestId}` *cited* | `notif.customer.request_expired` | `{requestId}`, `{expiredAt}` | Your Request expired | انتهت صلاحية طلبك | Your Request has expired. Pending Offers were withdrawn by the system. You may duplicate it to publish again. | انتهت صلاحية طلبك. سحب النظام العروض المعلّقة. يمكنك تكراره للنشر من جديد. | honour (§7.1) | — n/a |
| 10 | Unfinished draft (T−3 d) | `request.draft.purge_warning` *cited* | Customer | in-app *cited* | no *cited* | `/requests/{requestId}` *cited* | `notif.customer.request_draft_purge_warning` | `{requestId}`, `{purgeAfter}` | Unfinished Request will be deleted | سيُحذف طلب غير مكتمل | An unfinished Request will be deleted in 3 days ({purgeAfter}). Open it to continue or discard. | سيُحذف طلب غير مكتمل خلال 3 أيام ({purgeAfter}). افتحه للمتابعة أو تجاهله. | honour (§7.1) | — n/a |
| 12 | Offer expired | `offer.expired` *cited* | Customer | in-app, push *cited* | no *cited* | `/requests/{requestId}/offers` *cited* (Customer route) | `notif.customer.offer_expired` | `{requestId}`, `{offerId}` *(never Vendor identity — `BR-006`)* | An Offer expired | انتهت صلاحية عرض | An Offer on your Request has expired and is no longer available for Acceptance. | انتهت صلاحية عرض على طلبك ولم يعد متاحًا للقبول. | honour (§7.1) | — n/a |
| 15 | Connected (Customer confirmation) | `offer.accepted` *cited* | Customer | in-app, push *cited* | no *cited* | `/connections/{connectionId}` *cited* | `notif.customer.offer_accepted_connected` | `{connectionId}`, `{requestId}`, `{acceptedOfferId}` | You are now connected | أصبحتما متصلَين | Acceptance is complete. Identity Reveal is done — open the Connection to Talk. | اكتمل القبول. تم كشف الهوية — افتح الاتصال ثم اضغط «تحدث». | honour (§7.1) | — n/a |
| 16 | Connection closed | `connection.closed` *cited* | Customer | in-app *cited* | no *cited* | `/connections/{connectionId}` *cited* | `notif.customer.connection_closed` | `{connectionId}`, `{closedBy}` | Connection closed | تم إغلاق الاتصال | This Connection was closed. Details remain available. | أُغلق هذا الاتصال. تبقى التفاصيل متاحة. | honour (§7.1) | — n/a |
| 17 | Review reminder | `connection.closed` *cited* | Customer | in-app, push *cited* | no *cited* | `/connections/{connectionId}/review` *cited* | `notif.customer.review_reminder` | `{connectionId}` | Leave a Review | اترك مراجعة | This Connection is closed. Leave a Review for the other party while details are fresh. | أُغلق هذا الاتصال. اترك مراجعة للطرف الآخر بينما التفاصيل ما زالت حاضرة. | honour (§7.1) | — n/a |
| 18 | New review received | `review.published` *cited* | reviewed Customer | in-app, push *cited* | no *cited* | Customer reviews screen *cited* | `notif.customer.review_published` | `{reviewId}`, `{connectionId}` | New Review received | وصلت مراجعة جديدة | You received a new Review on a Connection. | تلقيت مراجعة جديدة على أحد اتصالاتك. | honour (§7.1) | — n/a |
| 21 | Platform announcement | `announcement.scheduled` *cited* | expanded `audience` | per `channels` *cited* | per `critical` *cited* | announcement detail route *cited* | `notif.announcement.scheduled` | `{announcementId}`, `{titleEn}`, `{titleAr}`, `{bodyEn}`, `{bodyAr}` *(pass-through from `announcement` row)* | `{titleEn}` | `{titleAr}` | `{bodyEn}` | `{bodyAr}` | honour when `critical = false`; bypass when `critical = true` (§7.1) | yes *(when audience includes Awaiting-Approval)* |
| 22 | Security-critical account events | *inline `[PROPOSED]`* *cited* | affected user | in-app, push, **SMS** *cited* | **yes** *cited* | `/settings/security` *cited* | `notif.security.{kind}` (`otp` \| `password` \| `new_device` \| `suspension`) | `{kind}`, `{reason}` (required when `suspension`) | **otp:** Security code sent · **password:** Password changed · **new_device:** New device signed in · **suspension:** Account suspended | **otp:** تم إرسال رمز أمان · **password:** تم تغيير كلمة المرور · **new_device:** تسجيل دخول من جهاز جديد · **suspension:** تم تعليق الحساب | **otp:** A one-time security code was sent for your account. If you did not request it, open Security settings. · **password:** Your password was changed. If this was not you, secure your account now. · **new_device:** A new device signed in to your account. Review active sessions in Security settings. · **suspension:** Your account was suspended. {reason} | **otp:** أُرسل رمز أمان لمرة واحدة لحسابك. إن لم تطلبه، افتح إعدادات الأمان. · **password:** تم تغيير كلمة مرورك. إن لم تكن أنت، أمّن حسابك الآن. · **new_device:** سُجّل الدخول إلى حسابك من جهاز جديد. راجع الجلسات النشطة في إعدادات الأمان. · **suspension:** تم تعليق حسابك. {reason} | bypass (critical) *cited* | yes |

---

## 6. Copy conventions

Binding for all filled catalogue rows. Stated so implementers do not drift.

1. **Event vocabulary is closed.** Every row’s Event column must already appear in Async-Contract §7.2 (and the §4 catalogue behind it). New triggers require an Async-Contract change first, not a silent catalogue row.
2. **CONTEXT.md nouns only.** Prefer Request, Offer, Connection, Acceptance, Match Set, Fan-out, Type Subscription, Identity Reveal. Honour each term’s `_Avoid_` list.
3. **No competitor leakage (`BR-008`).** Loser and peer Vendor copy must not name another Vendor, their price, or their terms. Async-Contract §7.2 already marks Offer rejected (loser) as **no price, no identity**.
4. **Quiet hours follow §7.1.** Non-critical rows honour `notification_preference` and quiet hours at dispatch time (`FR-CUS-034`, `FR-VEN-027`). Critical rows always deliver (`FR-SYS-008.2`).
5. **In-app is always written.** Channel lists may omit push/email/SMS by preference; the in-app centre row is still created (`FR-SYS-008.6`).
6. **`Vshell` is explicit.** Verification and document rows likely reach Awaiting-Approval Vendors; marketplace Fan-out rows typically do not. Each Vendor-facing row must say yes or no — do not leave the cell blank after CP5-I01.2.
7. **Locale.** Server selects EN/AR from `USER.preferred_language` with `Accept-Language` fallback (`NFR-024`, `NFR-022`). Catalogue authors supply both languages; they do not format money or dates in the template beyond placeholder tokens.

---

## Appendix A — Revision history

| Version | Date | Change |
|---|---|---|
| 0.3-remaining-rows | 8 Sep 2026 | CP5-I01.3 — filled §5 Remaining rows: Customer-only (#2–#6, #10, #15), dual-role Customer templates (#7, #12, #16–#18), announcement pass-through (#21), security-critical variants (#22). Template keys, placeholders, EN/AR, quiet-hours, `Vshell`. Events from Async-Contract §7.2 only. |
| 0.2-vendor-rows | 8 Sep 2026 | CP5-I01.2 — filled §4 Vendor-facing rows (and Admin for `vendor.document.expiring`): template keys, placeholders, EN/AR title/body, quiet-hours, `Vshell`. No new event types. §5 Remaining left for CP5-I01.3. |
| 0.1-skeleton | 8 Sep 2026 | CP5-I01.1 — document skeleton: row schema, §7.2 trigger index, empty Vendor-facing and Remaining shells. No EN/AR copy. |
