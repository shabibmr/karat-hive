# task.md — S2 & S3 completion checklist

Plan: `implementation_plan.md`. Verify per wave: `cd apps/kh_admin && flutter analyze && flutter test`.

## Wave A — S2 primitives
- [x] TR-S2-03 DECIDE feedback-banner spec (vendor treatment, border alpha 0.4)
- [x] TR-S2-04 KhFeedbackBanner + 3 call sites + test

## Wave B — S2 presentation→repo
- [x] TR-S2-15 move fetchDocumentUrl into VerificationDocViewController
- [x] TR-S2-16 sweep RepositoryProvider in presentation/ → 0

## Wave C — S2 split god screens
- [ ] TR-S2-06 request_detail_screen.dart
- [ ] TR-S2-07 offer_detail_screen.dart
- [ ] TR-S2-08 announcements_screen.dart
- [ ] TR-S2-09 compose_announcement_dialog.dart (extract)
- [ ] TR-S2-10 vendor_detail_screen.dart
- [ ] TR-S2-11 platform_settings_screen.dart
- [ ] TR-S2-12 customer_detail_screen.dart
- [ ] TR-S2-13 audit_screen.dart (structure only)
- [ ] TR-S2-14 connection_detail_screen.dart

## Wave D — S3 golden harness
- [ ] TR-S3-02 KhDataTable golden (LTR/RTL/200%) + test/support/golden.dart

## Wave E — S3 per-list rewire + selectors
- [ ] TR-S3-03a / TR-S3-04a requests
- [ ] TR-S3-03b / TR-S3-04b vendors
- [ ] TR-S3-03c / TR-S3-04c offers
- [ ] TR-S3-03d / TR-S3-04d announcements
- [ ] TR-S3-03e / TR-S3-04e platform_settings
- [ ] TR-S3-03f / TR-S3-04f admin_users
- [ ] TR-S3-03g / TR-S3-04g moderation
- [ ] TR-S3-03h / TR-S3-04h abuse
- [ ] TR-S3-03i / TR-S3-04i audit
- [ ] TR-S3-03j / TR-S3-04j connections
- [ ] TR-S3-03k / TR-S3-04k customers
- [ ] TR-S3-03l / TR-S3-04l reports

## Wave F — S3 doc
- [x] TR-S3-06 handoff note to docs/admin-backend-api-gaps.md (GAP-ADM-07)

---
**Session stop point: 5 tasks completed (TR-S2-03, TR-S2-04, TR-S2-15, TR-S2-16, TR-S3-06).**
Remaining: Wave C (9 god-screen splits), Wave D (golden harness), Wave E (12 list rewires + selectors).
