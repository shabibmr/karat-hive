# Admin Backend API Verification & Gap Report

**Date**: 8 September 2026  
**Document**: `docs/admin-backend-api-gaps.md`  
**Scope**: Verification of Backend APIs supporting the Karat Hive Flutter Web Admin Portal (`apps/kh_admin`, screens ADM-S01–ADM-S23).

---

## 1. Executive Summary

A comprehensive verification of the backend API routes located in `backend/src/modules/admin/` (`AdminController`, `AdminService`, `AdminRepository`) and associated controllers (`AdminTaxonomyController`, `AdminGoldRateController`, `AdminSubscriptionController`) was conducted against the 23 screens of the Admin Portal specification (`ui-screens/admin/` and `docs/Requirements-Spec-v1.3.md`).

While ~45 admin endpoints exist covering most verticals, **1 critical bug** and several significant parameter/projection gaps were identified that impact upcoming module implementations.

---

## 2. Critical Bugs Found

### BUG-ADM-01: `GET /v1/admin/reviews` executes `listRequests` (Review Moderation — ADM-S16)
- **Location**: `backend/src/modules/admin/controller/admin.controller.ts` (lines 378–388)
- **Code**:
  ```typescript
  // --- Review Moderation ---
  @Get('reviews')
  async listReviews(
    @Query('limit') limit?: string,
    @Query('cursor') cursor?: string,
  ) {
    const data = await this.service.listRequests({
      limit: limit ? Number.parseInt(limit, 10) : undefined,
      cursor,
    });
    return { data: data.items, nextCursor: data.nextCursor };
  }
  ```
- **Impact**: Any call to fetch reviews to moderate on ADM-S16 returns Request objects instead of Review objects. Furthermore, `AdminService` and `AdminRepository` do not even have a `listReviews` implementation.
- **Required Fix**:
  - Add `listReviews` to `AdminRepository` querying `prisma.review` with state filtering (`PENDING_MODERATION`, `PUBLISHED`, `REJECTED`, `REDACTED`), including author/subject user details and connection/request info.
  - Implement `listReviews` in `AdminService` and wire `admin.controller.ts` to call it.

---

## 3. Missing Parameters & Query Filter Gaps

### GAP-ADM-01: Missing Audit Log Filters (Audit Log — ADM-S22)
- **Location**: `admin.controller.ts:478` and `admin.repository.ts:528`
- **Issue**: The endpoint `GET /v1/admin/audit-log` only accepts `limit` and `cursor`.
- **Missing Filters**: `actorUserId`, `action`, `entityType`, `entityId`, `from`, `to`, `ip`.
- **Impact**: ADM-S22 UI allows filtering by actor, action type, entity, date range, and IP address. The repository currently queries all rows with only cursor pagination.

### GAP-ADM-02: Missing Request List Filters (Requests — ADM-S08)
- **Location**: `admin.controller.ts:291` and `admin.repository.ts:310`
- **Issue**: `GET /v1/admin/requests` only filters by `q` (text search) and `state`.
- **Missing Filters**: `requestType` (FIND_ORNAMENT, SELL_OLD_GOLD, GOLD_COIN, GOLD_BULLION), `direction` (BUY, SELL), `categoryId`, `regionId`, and `zeroOffers` flag.
- **Frontend State (`TR-S1-27`)**: Post-fetch client `.where()` filtering was removed to preserve cursor-pagination semantics. `RequestRepository.fetchRequests` passes all filters as query parameters (`limit`, `cursor`, `q`, `state`, `requestType`, `direction`, `categoryId`, `regionId`, `zeroOffers`, `minValue`, `maxValue`). Backend must accept and filter by these parameters.

### GAP-ADM-03: Missing Offer List Filters (Offers — ADM-S10)
- **Location**: `admin.controller.ts:324` and `admin.repository.ts:371`
- **Issue**: `GET /v1/admin/offers` only filters by `state` and `vendorId`.
- **Missing Filters**: `requestType`, date range (`dateFrom`, `dateTo`), value ranges (`minPrice`, `maxPrice`), search (`q`).
- **Frontend State (`TR-S1-29`)**: Post-fetch client `.where()` filtering was removed. `OfferRepository.fetchOffers` passes all filter parameters to the backend query string. Backend must accept and filter by these parameters.

### GAP-ADM-04: Customer List Missing Request Count (Customers — ADM-S03)
- **Location**: `admin.repository.ts:70`
- **Issue**: `listCustomers` fetches `customerProfile` and `user`, but does not include `_count: { select: { requests: true } }`.
- **Impact**: The ADM-S03 table displays "Total Requests" per customer; currently this field is null/absent from the list response.

### GAP-ADM-11: Customer-List Access Audit Endpoint (Customers — ADM-S03 / FR-ADM-010 AC5 / ADM-INS-40)
- **Location**: `POST /v1/admin/audit-log`
- **Issue**: Per `FR-ADM-010` AC5 and `FR-SYS-011`, viewing the customer list exposes personal data in bulk and must be logged to the immutable audit trail. The frontend issues `POST /v1/admin/audit-log` on initial customer list load (`action: CUSTOMER_LIST_VIEWED`, `entityType: customer_list`).
- **Backend Status**: Backend only has `GET /v1/admin/audit-log`. Frontend handles missing route fail-open / best-effort so list loading is not blocked. Backend must add `POST /v1/admin/audit-log` or log access internally in `GET /v1/admin/customers`.

### GAP-ADM-12: Missing Connection List Filters (Connections — ADM-S12)
- **Location**: `admin.controller.ts` and `admin.repository.ts`
- **Issue**: `GET /v1/admin/connections` accepts `state`, `limit`, `cursor`, but does not filter by `q` (free text query for customer/vendor names, IDs, amounts) or `hasNoContactOnly` (SLA flag for 48h without contact).
- **Frontend State (`TR-S1-29`)**: Post-fetch filtering removed; `ConnectionRepository.fetchConnections` passes `state`, `q`, and `hasNoContactOnly` to query parameters.

### GAP-ADM-13: Missing Announcement List Filters (Announcements — ADM-S18)
- **Location**: `admin.controller.ts` and `admin.repository.ts`
- **Issue**: `GET /v1/admin/announcements` accepts `status`, `limit`, `cursor`, but does not filter by `audienceType` (ALL, VENDOR, CUSTOMER) or `q` (text search).
- **Frontend State (`TR-S1-29`)**: Post-fetch filtering removed; `AnnouncementRepository.fetchAnnouncements` passes `status`, `audienceType`, and `q` to query parameters.

### GAP-ADM-14: Missing Abuse Report Queue Filters (Abuse Reports — ADM-S21)
- **Location**: `admin.controller.ts` and `admin.repository.ts`
- **Issue**: `GET /v1/admin/abuse-reports` accepts `state`, `limit`, `cursor`, but does not filter by `entityType` or `q` (text search).
- **Frontend State (`TR-S1-29`)**: Post-fetch filtering removed; `AbuseRepository.fetchAbuseReports` passes `state`, `entityType`, and `q` to query parameters.

### GAP-ADM-15: Missing Review Moderation Filters (Reviews — ADM-S16)
- **Location**: `admin.controller.ts` and `admin.repository.ts`
- **Issue**: Besides BUG-ADM-01 (`GET /v1/admin/reviews` calling `listRequests`), the moderation queue requires `state` (`PENDING_MODERATION`, `PUBLISHED`, `REJECTED`, `REDACTED`), `authorType`, and `q`.
- **Frontend State (`TR-S1-29`)**: Post-fetch filtering removed; `ModerationRepository.fetchReviews` passes `state`, `authorType`, and `q` to query parameters.

---

## 4. Missing Sub-Resources & Detail Projections

### GAP-ADM-05: Request Detail Missing Timeline and Matched Vendors (ADM-S09)
- **Location**: `admin.repository.ts:320` (`findRequest`)
- **Issue**: `findRequest` returns request, customerProfile, category, region, and offers. It omits:
  - `matchedVendors` count / list
  - `stateTransitions` timeline
  - Deep nested details for connection.
- **Status in Flutter**: UI renders empty placeholder with `TODO(backend)`.

### GAP-ADM-06: Offer Detail Missing State Transitions & Attachments (ADM-S11)
- **Location**: `admin.repository.ts:401` (`findOffer`)
- **Issue**: Omits offer lifecycle state transitions and image/document attachments. Revisions only expose raw JSON blob `previousTerms`.

### GAP-ADM-07: Media URL Authorization for Document Preview (ADM-S07 / ADM-S06)
- **Location**: `/v1/admin/vendors/:id/documents/:docId/url`
- **Issue**: Returning `/v1/media/<key>` requires an `Authorization: Bearer <token>` header. Opening document previews in a new browser tab fails because standard browser navigation cannot attach custom Authorization headers without a presigned temporary URL or token query parameter.
- **Frontend ownership (`TR-S3-06`)**: S3 only bounds image decode (`TR-S3-05`, done — KYC docs open externally, no inline `Image` decode). The bearer-less `/v1/media/<key>` → presigned/public signed-URL open is **owned by S4 (`TR-S4-19`)**, not S3. The admin client already prefixes `khApiBase` and opens in a new tab (`VerificationDocViewController.openDocument`, `TR-S2-15`); it will render correctly once this gap is closed.

### GAP-ADM-08: Inconsistent Admin Note Author Shape (ADM-S09 / ADM-S11)
- **Location**: `admin.repository.ts:546` vs `admin.repository.ts:557`
- **Issue**: `POST :collection/:id/notes` creates and returns the record without author details, whereas `GET :collection/:id/notes` returns `author: { displayName }`. Frontend must synthesize author.

### GAP-ADM-09: Dashboard counts are not date-range scoped (Dashboard — ADM-S02)
- **Location**: `admin.controller.ts` `@Get('dashboard')` → `admin.service.ts` `getDashboard()` → `admin.repository.ts` `getDashboardStats()`
- **Issue**: `GET /v1/admin/dashboard` accepts no query params; the six counts are all-time.
- **Frontend state (`TR-S6-03`)**: the ADM-S02 date-range selector (7 / 30 / 90 days) is wired end-to-end — `DashboardRepository.fetchStats` sends `from`/`to` as `yyyy-MM-dd` and the controller refetches on change — but the endpoint ignores them, so the stat cards do not yet re-scope. No error (Fastify drops unknown query keys).
- **Required Fix**: accept optional `from`/`to` on `GET /v1/admin/dashboard` and scope the count queries (`createdAt` / state-as-of) to that window.

### GAP-ADM-10: No time-series report for dashboard trends (Dashboard — ADM-S02)
- **Location**: `admin.repository.ts` `getReportData()` — every branch returns categorical `groupBy` rows; `series` is always `[]`.
- **Issue**: there is no endpoint returning a daily/weekly bucketed series for any metric, so a real trend *line* over time cannot be drawn.
- **Frontend state (`TR-S6-04`)**: the ADM-S02 "Trends" section reuses `GET /v1/admin/reports/request-volume` scoped to the selected range (request counts by state). It is range-aware but not a time series.
- **Required Fix**: add a `series`-returning report (e.g. `request-volume` with a `bucket=day|week` param, or a dedicated `dashboard-trends` route) so the dashboard can plot metric-over-time.

---

## 5. Summary Matrix of Backend Routes vs Admin Screens

| Screen ID | Screen Name | Required Route(s) | Backend Status | Gap / Notes |
|---|---|---|---|---|
| ADM-S01 | Login | `POST /v1/auth/google/session` | ✅ Operational | Handled via G2-A14 Google session exchange |
| ADM-S02 | Dashboard | `GET /v1/admin/dashboard`<br>`GET /v1/admin/reports/request-volume` | ⚠️ Partially Complete | Counts returned but not date-range scoped (GAP-ADM-09); no time-series report for trends (GAP-ADM-10); recent activity feed missing |
| ADM-S03 | Customer List | `GET /v1/admin/customers`<br>`POST /v1/admin/audit-log` | ⚠️ Partially Complete | Missing `_count: { requests: true }` (GAP-ADM-04); missing `POST /v1/admin/audit-log` access audit endpoint (GAP-ADM-11) |
| ADM-S04 | Customer Detail | `GET /v1/admin/customers/:id`<br>`POST :id/suspend`<br>`POST :id/reactivate`<br>`POST :id/erasure` | ✅ Operational | Actions and notes routes supported |
| ADM-S05 | Vendor List | `GET /v1/admin/vendors` | ✅ Operational | Full query filters supported |
| ADM-S06 | Vendor Detail | `GET /v1/admin/vendors/:id`<br>`POST :id/activate\|suspend\|reactivate\|deactivate`<br>`POST/PATCH :id/subscriptions` | ✅ Operational | Full detail & lifecycle actions supported |
| ADM-S07 | Verification Queue | `GET /v1/admin/verification-queue`<br>`POST /v1/admin/vendors/:id/verify\|reject\|request-info` | ✅ Operational | Full queue and decision actions supported |
| ADM-S08 | Request List | `GET /v1/admin/requests` | ⚠️ Partially Complete | Missing `requestType`, `direction`, `categoryId`, `regionId`, `zeroOffers` query params (GAP-ADM-02) |
| ADM-S09 | Request Detail | `GET /v1/admin/requests/:id`<br>`POST :id/remove` | ⚠️ Partially Complete | Missing timeline and matched vendors in projection (GAP-ADM-05) |
| ADM-S10 | Offer List | `GET /v1/admin/offers` | ⚠️ Partially Complete | Missing `requestType`, date range, value range, `q` query params (GAP-ADM-03) |
| ADM-S11 | Offer Detail | `GET /v1/admin/offers/:id` | ⚠️ Partially Complete | Missing `stateTransitions` and attachments projection (GAP-ADM-06) |
| ADM-S12 | Connection List | `GET /v1/admin/connections` | ⚠️ Partially Complete | Missing `q` search and `hasNoContactOnly` query params (GAP-ADM-12) |
| ADM-S13 | Connection Detail | `GET /v1/admin/connections/:id`<br>`POST :id/close` | ✅ Operational | Includes contact events; close action supported |
| ADM-S14 | Category Taxonomy | `GET/POST/PUT/DELETE /v1/admin/taxonomy/category` | ✅ Operational | Handled by `AdminTaxonomyController` |
| ADM-S15 | Region Taxonomy | `GET/POST/PUT/DELETE /v1/admin/taxonomy/region` | ✅ Operational | Handled by `AdminTaxonomyController` |
| ADM-S16 | Review Moderation | `GET /v1/admin/reviews`<br>`POST :id/approve\|reject\|redact` | ❌ Critical Bug | `GET /v1/admin/reviews` calls `listRequests` (BUG-ADM-01); missing `state`, `authorType`, `q` filters (GAP-ADM-15) |
| ADM-S17 | Reports & Analytics | `GET /v1/admin/reports/:name`<br>`POST /v1/admin/exports`<br>`GET /v1/admin/exports/:id` | ✅ Operational | 7 report names supported; async export polling |
| ADM-S18 | Announcements | `GET/POST /v1/admin/announcements`<br>`POST :id/cancel` | ⚠️ Partially Complete | Missing `audienceType` and `q` query params (GAP-ADM-13) |
| ADM-S19 | Platform Settings | `GET /v1/admin/settings`<br>`PATCH /v1/admin/settings/:key` | ✅ Operational | Key-value settings with confirmation supported |
| ADM-S20 | Gold Rates | `GET /v1/admin/gold-rates`<br>`GET :history`<br>`POST :override` | ✅ Operational | Backend exists in `AdminGoldRateController`; UI deferred |
| ADM-S21 | Abuse Reports | `GET /v1/admin/abuse-reports`<br>`GET :id`<br>`POST :id/resolve\|dismiss` | ⚠️ Partially Complete | Missing `entityType` and `q` query params (GAP-ADM-14) |
| ADM-S22 | Audit Log | `GET /v1/admin/audit-log` | ⚠️ Partially Complete | Missing query filters (actor, action, entity, dates, ip) (GAP-ADM-01) |
| ADM-S23 | Admin Users | `GET/POST /v1/admin/admins`<br>`POST :id/suspend\|revoke` | ✅ Operational | Provisioning, suspension, revocation supported |
