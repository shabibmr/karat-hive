# Sherlock: Vendor Screen-by-Screen Case Blog

**Case**: Vendor App Complete Screen Audit  
**Categorisation**: Screen-by-Screen (`VEN-S01` through `VEN-S22`)  
**Scope**: 22 Units (Flutter Mobile Vendor Mode)  
**Method**: Review-only deduction, code-linked evidence, strict aspect-by-aspect verification.  
**Log Location**: `docs/Sherlock-Case-Blog/Vendor-Screen-Review-Case-Blog.md`

---

## 1. Master Unit Checklist (The Mind Palace)

| # | Unit ID | Screen Name | Spec Link | Status |
|---|---|---|---|---|
| 1 | `VEN-S01` | Registration — Business Details | [VEN-S01-registration.md](file:///E:/work/karat_hive/ui-screens/vendor/VEN-S01-registration.md) | ✅ Solved |
| 2 | `VEN-S02` | KYC Document Upload | [VEN-S02-kyc-document-upload.md](file:///E:/work/karat_hive/ui-screens/vendor/VEN-S02-kyc-document-upload.md) | ✅ Solved |
| 3 | `VEN-S03` | Awaiting Approval Shell | [VEN-S03-awaiting-approval.md](file:///E:/work/karat_hive/ui-screens/vendor/VEN-S03-awaiting-approval.md) | ✅ Solved |
| 4 | `VEN-S04` | Vendor Login | [VEN-S04-login.md](file:///E:/work/karat_hive/ui-screens/vendor/VEN-S04-login.md) | ✅ Solved |
| 5 | `VEN-S05` | Vendor Dashboard | [VEN-S05-dashboard.md](file:///E:/work/karat_hive/ui-screens/vendor/VEN-S05-dashboard.md) | ✅ Solved |
| 6 | `VEN-S06` | Available Requests Feed | [VEN-S06-available-requests.md](file:///E:/work/karat_hive/ui-screens/vendor/VEN-S06-available-requests.md) | ✅ Solved |
| 7 | `VEN-S07` | Request Filters & Presets | [VEN-S07-request-filters.md](file:///E:/work/karat_hive/ui-screens/vendor/VEN-S07-request-filters.md) | ✅ Solved |
| 8 | `VEN-S08` | Masked Request Detail | [VEN-S08-request-detail.md](file:///E:/work/karat_hive/ui-screens/vendor/VEN-S08-request-detail.md) | ✅ Solved |
| 9 | `VEN-S09` | Submit Offer | [VEN-S09-submit-offer.md](file:///E:/work/karat_hive/ui-screens/vendor/VEN-S09-submit-offer.md) | ✅ Solved |
| 10 | `VEN-S10` | Revise / Withdraw Offer | [VEN-S10-revise-withdraw-offer.md](file:///E:/work/karat_hive/ui-screens/vendor/VEN-S10-revise-withdraw-offer.md) | ✅ Solved |
| 11 | `VEN-S11` | My Offers / Status Hub | [VEN-S11-my-offers.md](file:///E:/work/karat_hive/ui-screens/vendor/VEN-S11-my-offers.md) | ✅ Solved |
| 12 | `VEN-S12` | Connection List | [VEN-S12-connections-list.md](file:///E:/work/karat_hive/ui-screens/vendor/VEN-S12-connections-list.md) | ✅ Solved |
| 13 | `VEN-S13` | Connection Detail & Unmasked Contact | [VEN-S13-connection-detail.md](file:///E:/work/karat_hive/ui-screens/vendor/VEN-S13-connection-detail.md) | ✅ Solved |
| 14 | `VEN-S14` | Offer History & Performance Metrics | [VEN-S14-offer-history.md](file:///E:/work/karat_hive/ui-screens/vendor/VEN-S14-offer-history.md) | 🟡 Investigating |
| 15 | `VEN-S15` | Business Profile | [VEN-S15-business-profile.md](file:///E:/work/karat_hive/ui-screens/vendor/VEN-S15-business-profile.md) | ⏳ Cold |
| 16 | `VEN-S16` | Categories, Regions & Business Hours | [VEN-S16-categories-regions.md](file:///E:/work/karat_hive/ui-screens/vendor/VEN-S16-categories-regions.md) | ⏳ Cold |
| 17 | `VEN-S17` | Notification Centre | [VEN-S17-notification-centre.md](file:///E:/work/karat_hive/ui-screens/vendor/VEN-S17-notification-centre.md) | ⏳ Cold |
| 18 | `VEN-S18` | Settings | [VEN-S18-settings.md](file:///E:/work/karat_hive/ui-screens/vendor/VEN-S18-settings.md) | ⏳ Cold |
| 19 | `VEN-S19` | Leave Customer Feedback | [VEN-S19-leave-customer-feedback.md](file:///E:/work/karat_hive/ui-screens/vendor/VEN-S19-leave-customer-feedback.md) | ⏳ Cold |
| 20 | `VEN-S20` | My Reviews & Responses | [VEN-S20-my-reviews.md](file:///E:/work/karat_hive/ui-screens/vendor/VEN-S20-my-reviews.md) | ⏳ Cold |
| 21 | `VEN-S21` | Report Abuse | [VEN-S21-report-abuse.md](file:///E:/work/karat_hive/ui-screens/vendor/VEN-S21-report-abuse.md) | ⏳ Cold |
| 22 | `VEN-S22` | Subscription by Request Type | [VEN-S22-subscription.md](file:///E:/work/karat_hive/ui-screens/vendor/VEN-S22-subscription.md) | ⏳ Cold |

---

## 2. Unit Decisions & Findings Log

### VEN-S04 · Login
- **Status**: ✅ Solved
- **Decisions**: Auto-login on cold launch if valid token exists; `flutter_hive` temporary token storage adapter (scheduled migration to secure storage); Google Sign-In with registration link.

### VEN-S01 · Registration — Business Details
- **Status**: ✅ Solved
- **Decisions**: 4-page wizard flow (About You, Store Profile, Store Location, Contact & Agreement); deferred legal/trade licence to KYC (`VEN-S02`); categories deferred to `VEN-S16`; OTP bypassed for dev; 409 conflict handled via `KhInlineError`.

### VEN-S02 · KYC Document Upload
- **Status**: ✅ Solved
- **Decisions**: Combined official details (legal name, trade licence #, expiry) + verification documents uploader (Trade Licence, Emirates ID of authorized contact); submit enabled only when text fields + mandatory documents uploaded; upload via `/v1/media/upload-intent`.

### VEN-S03 · Awaiting Approval Shell
- **Status**: ✅ Solved
- **Decisions**: Zero marketplace access (guarded via `VendorAccessGuard`); 15s polling + resume sync; rejection/more-info banner; resubmit on REJECTED; automatic routing to `VEN-S16` on VERIFIED.

### VEN-S05 · Vendor Dashboard
- **Status**: ✅ Solved
- **Decisions**: Real metric counts (New Requests preview, Pending Offers expiring in 24h, Active Connections, Type Subscriptions, Rating summary); reference gold rates hidden; `GET /v1/me/dashboard` stage `ACTIVE` enforcement.

### VEN-S06 · Available Requests Feed
- **Status**: ✅ Solved
- **Decisions**: Request cards with category, karat, budget, location; commercial shielding (`BR-006` / `BR-008`); pull-to-refresh + cursor pagination; mark-viewed on tap.

### VEN-S07 · Request Filters & Presets
- **Status**: ✅ Solved
- **Decisions**: Filter drawer (Sort, Type chips, Category/Region, Budget, Karat, Hide responded toggle); filter preset saving (`POST /v1/filter-presets`) and switching; "Reset All" clears drafts.

### VEN-S08 · Masked Request Detail
- **Status**: ✅ Solved
- **Decisions**: Media gallery (`KhImageGallery`); Expiry countdown (`ExpiryCountdown`); masked Customer summary (`MaskedPartyLabel`); specification grid; report abuse entry; sticky "Make an Offer" CTA $\rightarrow$ `VEN-S09`.

### VEN-S09 · Submit Offer
- **Status**: ✅ Solved
- **Decisions**: Direct total price input; validity fixed to 24h system default capped by request expiry; gold weight explicit field; notes with `BR-022` contact masking; 1 to 3 supporting images required.

### VEN-S10 · Revise / Withdraw Offer
- **Status**: ✅ Solved
- **Decisions**: Customer Seen status indicator; revisions capped at 1 (`kMaxOfferRevisions = 1`); revision locked once viewed by Customer; 5-minute grace window from submission; clear countdown and lock banners.

### VEN-S11 · My Offers / Status Hub
- **Status**: ✅ Solved
- **Decisions**: Thick frosted glass gaussian blur masking on customer identity; competitor offer counts suppressed; primary uploaded image as thumbnail; Pending / Accepted / Closed tabs with search.

### VEN-S12 · Connection List
- **Status**: ✅ Solved (Audit: 2026-09-09)
- **Decisions**: Active vs Closed grouping; counterparty unmasking (real customer name); Talk shortcut to WhatsApp with contact event recording; agreed price snapshot.
- **Findings**: F-1 dead field `meta.hasMore`; C-1 Close Connection affordance missing on list (contradicts `FR-VEN-020` AC3 vs `VEN-S12.md`); C-2 read views not audit-logged (`FR-VEN-021` AC4); C-3 pagination sort inconsistency.

### VEN-S13 · Connection Detail & Unmasked Contact
- **Status**: ✅ Solved — Sherlock pass 2026-09-09, review-only. A ✅ / B ✅ / C ✅ / D ✅.
- **Spec**: `ui-screens/vendor/VEN-S13-connection-detail.md` · **SRS**: `FR-VEN-021`, `FR-VEN-022` · **Invariants**: `FR-CUS-024`, `BR-007`, `BR-008`, `NFR-016`, `NFR-017`, `C-02`, `C-03`, `BR-021`, `FR-SYS-011`
- **Design Decisions**:
  1. Revealed customer card: Avatar initial, full name, phone chip with copy button, WhatsApp button, phone call button, completed deals trust badge.
  2. Direct WhatsApp "Talk" hub: Primary CTA button launching server-built `wa.me` URL, logging `WHATSAPP` contact event. Fallback tap-to-call.
  3. Agreed Offer terms: Full breakdown of agreed price, gold weight, making charges, rate/g, vendor notes.
  4. Lifecycle actions: "Close Connection" with confirmation dialog $\rightarrow$ prompt review (`VEN-S19`), "Leave feedback", and "Report" (`VEN-S21`).
  5. Closed state persistence: Details remain accessible in read-only mode with `ConnectionClosedBanner`.
- **Findings Logged**:
  - `A. Visible Components`: Spec fields absent (Customer Region never arrives from backend; Platform tenure / member-since omitted; Completed connections count not a standalone labelled line; Connection state ACTIVE/CLOSED chip missing from header). Inconsistent Talk icon vs VEN-S12.
  - `B. Functions`: `getConnectionById` writes no audit entry on contact read (F-1); `closeConnection` bypasses state machine (F-3); Close emits outbox event but no audit entry (F-4).
  - `C. Business Rules`: Customer Region missing in vendor presenter (C-1); Member-since absent (C-2); Connection count folded into badge (C-3); Status chip absent (C-4); Contact read not audit-logged (C-5 / L6); `identityRevealedAt` formatted with raw `toLocal()` instead of GST (C-6); Offer payload omits `weightGrams` (C-7); Talk phone populated even when CLOSED (C-8); Admin reads via customer presenter (C-9).
  - `D. Anything Else`: Deep-linkable `/vendor/connections/:id`; a11y labels needed for icon buttons; tablet/320px width responsiveness to verify.

### VEN-S14 · Offer History & Performance Metrics
- **Status**: 🟡 Investigating
- **Spec**: `ui-screens/vendor/VEN-S14-offer-history.md` · **SRS**: `FR-VEN-023` (AC1–AC4) · **Invariants**: `BR-008`, `BR-021`
- **Aspects**:
  - `A. Visible Components`: ✅ Solved (Audit: 2026-09-10)
  - `B. Functions`: 🟡 Investigating
  - `C. Business Rules`: ⏳ Pending
  - `D. Anything Else`: ⏳ Pending
- **Findings Logged**:
  - `A. Visible Components`:
    - A-1: Missing 4th metric card ("Avg offered vs accepted (when lost)" / "Avg Winning Deal"). Spec `VEN-S14.md:32` and `FR-VEN-023` AC2 require it; UI currently leaves an asymmetrical single card on row 2.
    - A-2: Terminal card non-interactive. Spec `VEN-S14.md:18` defines Exit: "open historical Offer", but `_TerminalOfferCard` has no tap handler, affordance, or route linkage.

---

## 3. Open Leads & Technical Debt (Consolidated)

| # | Lead | Origin | Owner Surface | Confidence |
|---|---|---|---|---|
| L1 | `VendorRequestItem` drops `myOffer` object returned by `GET /v1/requests/{id}`; blocks `FR-VEN-010` AC4 "View / Revise Offer" CTA on VEN-S08. | VEN-S08 | `kh_domain`, `kh_api`, `request_detail_screen.dart` | Confident |
| L2 | Publication time (`publishedAt`) fetched but not rendered on VEN-S08. | VEN-S08 | `request_detail_screen.dart` | Confident |
| L3 | `markViewed` in controller is fire-and-forget; failure can desync dashboard New-Requests count. | VEN-S08 | `request_detail_controller.dart` | Near certain |
| L4 | Submit Offer backend errors surface raw error codes without localized friendly copy. | VEN-S09 | `submit_offer_controller.dart`, `kh_l10n` | Near certain |
| L5 | VEN-S12 list lacks Close Connection button (`FR-VEN-020` AC3 vs `VEN-S12.md:35`). Decision needed on canonical location. | VEN-S12 | `Requirements-Spec-v1.3.md`, `connections_screen.dart` | Confident |
| L6 | Revealed Customer phone reads are not audit-logged (`FR-VEN-021` AC4 / `FR-SYS-011`). | VEN-S12, VEN-S13 | `backend/.../connection.service.ts` | Near certain |
| L7 | Active-first order across pages not guaranteed if server sorts purely by `createdAt desc`. | VEN-S12 | `connection.repository.ts` | Confident |
| L8 | Unmasked phone and talk payload emitted on CLOSED connection records. | VEN-S12, VEN-S13 | `connection.presenter.ts` | Near certain |
| L9 | Dead field `meta.hasMore` on connections response. Double fallback on `offer` key. | VEN-S12 | `connections_client.dart` | Confident |
| L10 | Semantics and screen-reader accessibility on Talk button unverified. | VEN-S12 | `connections_screen.dart` | Working hypothesis |
| L11 | Visual inconsistency: Talk icon is generic external link on VEN-S12 vs WhatsApp glyph on VEN-S13. | VEN-S12, VEN-S13 | `connection_widgets.dart` | Confident |
| L12 | VEN-S13 C-1/C-2/C-3/C-4: spec fields not delivered on detail (Customer Region, tenure, explicit connection count line, status chip). | VEN-S13 | `connection.presenter.ts`, `revealed_party_card.dart` | Confident |
| L13 | VEN-S13 C-6: `identityRevealedAt` formatted with raw `toLocal()` instead of GST (`BR-021`/`C-02`). | VEN-S13 | `connection_detail_screen.dart` | Confident |
| L14 | VEN-S13 C-7: Offer payload block omits `weightGrams` on connection detail read. | VEN-S13 | `connection.presenter.ts` | Near certain |
| L15 | VEN-S13 C-9: Admin reading vendor connection uses `presentConnectionForCustomer`. | VEN-S13 | `connection.service.ts` | Near certain |
| L16 | VEN-S13 F-3/C-10/C-11: `closeConnection` bypasses state machine; close emits outbox event but no audit entry. | VEN-S13 | `connection.service.ts` | Confident |
| L17 | VEN-S13 C-12/C-13/F-5: Missing placeholder when offer/request null; "Leave feedback" accessible on active unclosed connection. | VEN-S13 | `connection_detail_screen.dart` | Working hypothesis |
| L18 | Password policy mismatch: backend requires min 12 chars (upper, lower, digit); mobile client requires min 8 chars (upper, digit, symbol). | VEN-S18 | `backend/.../password-policy.ts`, `settings_screen.dart` | Confident |
| L19 | Extract normalized `Contact` entity for external CRM synchronization. | VEN-S02 | Backend Domain | — |
| L20 | Token storage migration: `flutter_hive` to secure storage. | VEN-S04 | `auth` feature | — |
