# Admin App Completion — Task Register

> **Source of truth**: [`Admin-App-Completion-Plan.md`](Admin-App-Completion-Plan.md)
> **Branch**: `main` (completion work continues on `main`)
> **Prefix**: `ADM-C-nn` (Admin completion). Slices `Backend-Implementation-Plan.md` `T`-IDs; does not renumber them.

Legend: `[x]` done · `[~]` in progress · `[ ]` not started

---

## Slice 0 — Reconcile with `main` (done)

- [x] **ADM-C-01** New branch `feat/admin-portal-on-main` off `origin/main`; admin Flutter app replanted; branch's parallel backend dropped.
- [x] **ADM-C-02** 3-way reconcile the 4 `main`-owned files onto the `G2-A14` Google-session auth flow.
- [x] **ADM-C-03** Adapt vendors / verification / offers / requests repos to `main`'s raw admin responses (`getCollection` double-wrap, Decimal strings, nested keys, notes merge, client-side filters). Repo/parsing tests added. `flutter analyze` clean, `flutter test` 141 pass.
- [x] **ADM-C-04** `Admin-App-Completion-Plan.md` + this register.

## Slice 1 — Land the adapted verticals (ADM-S05–S11)

- [ ] **ADM-C-10** Seed a local backend, dev auto-login, click through Vendors / Verification / Requests / Offers list+detail; fix live-data breakage; capture screenshots. *(blocked on live seed + browser; not this Flutter slice)*
- [x] **ADM-C-11** `offers` + `requests` l10n — ~220 keys EN/AR, wired via `AppLocalizations`. Commit `6100943`.
- [x] **ADM-C-12** URL query-param state for `vendors` / `requests` / `offers` list filters (mirror `verification_query_params.dart`).
- [x] **ADM-C-13** Removed orphaned ARB keys (`vendorsDetailStubBody`, `vendorsDetailComingSoon`). Commit `6100943`.
- [ ] **ADM-C-14** Commit per vertical; open draft PR with GIF. *(commit on this slice; GIF/PR still open)*

## Slice 2 — Dashboard (ADM-S02)

- [x] **ADM-C-20** Replace `dashboard_screen.dart` sample data with `GET /v1/admin/dashboard`; keep responsive layout; loading / error / empty states. Live queue snapshots (verification / abuse / pending reviews); KYC count tile replaces fake AED 4.2M.

## Group A — list/detail pattern, backend ready

- [x] **ADM-C-30** ADM-S22 audit-log — model + repo (`GET /v1/admin/audit-log`, filters `actorUserId,action,entityType,entityId,from,to,ip`), `KhDataTable` list, client-side row detail (`SAM-GAP-12`), self-view audit note, tests. Route `/audit`.
- [x] **ADM-C-31** ADM-S03 customer-list — clone vendor-list; `GET /v1/admin/customers`; PII list-access audit note. Route `/customers`.
- [x] **ADM-C-32** ADM-S04 customer-detail — clone vendor-detail; `GET /v1/admin/customers/:id`; suspend / reactivate / erasure dialogs (mandatory reason). Route `/customers/:id`.

## Group B — queue / moderation, backend ready

- [x] **ADM-C-40** ADM-S12 connection-list — `GET /v1/admin/connections`; derived "no contact 48h" column. Route `/connections`.
- [x] **ADM-C-41** ADM-S13 connection-detail — `GET /v1/admin/connections/:id`; close action (reason, notifies both). Route `/connections/:id`.
- [x] **ADM-C-42** ADM-S21 abuse-report queue — `GET /v1/admin/abuse-reports(/:id)`; resolve / dismiss with rationale; reporter never disclosed. Route `/abuse`.
- [x] **ADM-C-43** ADM-S16 review-moderation — `GET /v1/admin/reviews`; approve / reject / redact (rationale on reject/redact). Route `/moderation`.
- [x] **ADM-C-44** ADM-S23 admin-user-management — `GET/POST /v1/admin/admins`, suspend / revoke; **no Role selector** (`SAM-GAP-13`, `AD-API-03`). Route `/admin-users`.

## Group C — config screens

- [x] **ADM-C-50** ADM-S19 platform-settings — `GET /v1/admin/settings`, `PATCH /v1/admin/settings/:key`; typed rows + range validation; flag the offer-validity field pending the live decision; coarse Super-Admin confirm.
- [x] **ADM-C-51** ADM-S18 announcement-composer — `GET/POST /v1/admin/announcements`, cancel; bilingual form, audience/channel selects, schedule, delivery list. `SAM-GAP-10` (no pre-send count).

## Group D — heaviest (reports & analytics)

- ~~ADM-C-60, ADM-C-61~~ — **withdrawn**: gold-rate config (ADM-S20) descoped from this effort (Yahoo Finance redistribution terms open; retained in SRS §7.4 / ui-screens/admin/ADM-S20).
- [x] **ADM-C-62** Introduce a charting library into `kh_admin` — `fl_chart` (MIT, Flutter Web).
- [x] **ADM-C-63** ADM-S17 reports & analytics — `GET /v1/admin/reports/:name` (7 types), `POST /v1/admin/exports` + poll `GET /v1/admin/exports/:id`; charts + results table + export flow. Client-side CSV fallback (backend download route still missing).

## Backend follow-ups (raise as `G2-*`)

- [ ] **ADM-C-70** Admin list routes double-wrap the envelope — fix `admin.controller.ts` to return `{ data: items, meta: { nextCursor } }` like the customer controllers; then simplify `ApiClient.getCollection`.
- [ ] **ADM-C-71** `listRequests` / `listOffers` — add the filter params the screens need (`requestType`, `direction`, `categoryId`, `regionId`, price/value ranges, `zeroOffers`).
- [ ] **ADM-C-72** Request detail — include `matchedVendors`, a state timeline, and deep `connections` (nested vendor/customer).
- [ ] **ADM-C-73** Offer detail — expose state transitions; give `OfferRevision` real columns or a typed projection.
- [ ] **ADM-C-74** Signed / public media URL for admin document view (current `/v1/media/<key>` needs a bearer a new tab can't send).
- [ ] **ADM-C-75** `admin_note` create response — return `author:{displayName}` to match the list shape.
