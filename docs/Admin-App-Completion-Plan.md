# Admin App Completion — Plan of Record

| | |
|---|---|
| **Product** | Karat Hive |
| **Document** | Plan of record for the remaining Admin Portal screens, Flutter Web (`apps/kh_admin`) |
| **Version** | 1.0 |
| **Status** | Draft — awaiting Technical Lead sign-off on the `[PROPOSED]` register (§7) |
| **Date** | 7 September 2026 |
| **Scope** | Admin Portal only. `apps/kh_admin` is standalone (excluded from the Melos workspace) |
| **Task register** | Flutter: [`Admin-App-Completion-Tasks.md`](Admin-App-Completion-Tasks.md). Backend follow-ups: [`Admin-Backend-Followup-Tasks.md`](Admin-Backend-Followup-Tasks.md) (`ADM-C-70`–`ADM-C-76`). |
| **Predecessor** | [`Admin-Checkpoint-1-Taxonomy-Plan.md`](Admin-Checkpoint-1-Taxonomy-Plan.md) |
| **Does not override** | SRS v1.3 · `API-Route-Inventory.md` · `Architecture-Frontend.md` · `Screen-API-Map.md` |

This document cites the authority chain; it does not restate it. Where it and the SRS
disagree, the SRS wins. It slices `Backend-Implementation-Plan.md` `T`-IDs, it does not renumber them.

---

## 1. Context

Checkpoint-1 delivered one Admin vertical end-to-end — login → taxonomy (Categories +
Regions) — plus a thin dashboard. Google-only sign-in (`adr/0010`) and the `G2-A14`
Google-ID-token → Karat Hive session exchange landed on `main` afterwards.

Since then **`main` gained a near-complete admin backend.** `10dfbca` added
`backend/src/modules/admin/` — `admin.controller.ts` now exposes ~45 `/v1/admin/*` routes
covering **every** admin screen (dashboard, customers, vendors, verification, requests,
offers, connections, reviews, abuse-reports, announcements, settings, audit-log, admins,
reports/exports, generic notes), plus the `reviews`, `connections`, `abuse`, `gold-rate`,
`notifications`, `settings` domain modules. Responses are **raw Prisma rows** wrapped by
the global envelope interceptor — there is no admin DTO/presenter layer.

### 1.1 What the tree actually looks like (branch `feat/admin-portal-on-main`)

| Area | State |
|---|---|
| Admin backend routes | ~45 `/v1/admin/*` routes live on `main`. Every remaining screen has a route. Known gaps in §5. |
| Flutter — done | `auth` (login), `taxonomy` (Categories, Regions), `dashboard` (thin, sample data) |
| Flutter — built, contract-adapted this slice | `vendors` (list + detail), `verification` (queue + detail), `requests` (list + detail), `offers` (list + detail) — repos normalise `main`'s raw responses |
| Flutter — placeholder route only | `customers`, `connections`, `moderation`, `reports`, `announcements`, `settings`, `abuse`, `audit`, `admin-users` |
| Foundation | Design tokens, `ApiClient` (+ `getCollection`), `SessionController`, `GoRouter` + guards, `KhAdminScaffold`, EN/AR l10n, shared widgets (`kh_data_table`, `kh_metric_card`, `kh_status_chip`, `kh_screen_header`) — complete |

**Honest summary: the admin backend is essentially built; the remaining work is
overwhelmingly Flutter, screen by screen, against routes that already exist.**

## 2. Screen ledger (ADM-S01–S23)

In-scope Flutter screens are **done** (8 Sep 2026). The only remaining placeholder is ADM-S20 (deferred). Backend payload gaps for some screens are [`Admin-Backend-Followup-Tasks.md`](Admin-Backend-Followup-Tasks.md), not missing screens.

| Screen | Route | Backend | Flutter | State |
|---|---|---|---|---|
| ADM-S01 Login | `/login` | ✅ | ✅ | **Done** (CP-1 + G2-A14) |
| ADM-S02 Dashboard | `/` | ✅ `GET /v1/admin/dashboard` | ✅ live metrics + queue snapshots | **Done** |
| ADM-S03 Customer list | `/customers` | ✅ | ✅ | **Done** |
| ADM-S04 Customer detail | `/customers/:id` | ✅ (+ suspend/reactivate/erasure) | ✅ | **Done** |
| ADM-S05 Vendor list | `/vendors` | ✅ | ✅ | **Done** |
| ADM-S06 Vendor detail | `/vendors/:id` | ✅ | ✅ | **Done** |
| ADM-S07 Verification queue + detail | `/verification` | ✅ | ✅ | **Done** |
| ADM-S08 Request list | `/requests` | ✅ (filters limited, §5) | ✅ (client-side extra filters) | **Done** |
| ADM-S09 Request detail | `/requests/:id` | ✅ (sub-resources limited, §5) | ✅ (empty sections until ADM-C-72) | **Done** |
| ADM-S10 Offer list | `/offers` | ✅ (filters limited, §5) | ✅ (client-side extra filters) | **Done** |
| ADM-S11 Offer detail | `/offers/:id` | ✅ | ✅ (revisions until ADM-C-73) | **Done** |
| ADM-S12 Connection list | `/connections` | ✅ | ✅ | **Done** |
| ADM-S13 Connection detail | `/connections/:id` | ✅ (+ close) | ✅ | **Done** |
| ADM-S14 Categories | `/taxonomy/categories` | ✅ | ✅ | **Done** (CP-1) |
| ADM-S15 Regions | `/taxonomy/regions` | ✅ | ✅ | **Done** (CP-1) |
| ADM-S16 Review moderation | `/moderation` | ✅ | ✅ | **Done** |
| ADM-S17 Reports & analytics | `/reports` | ✅ (`reports/:name`, `exports`; download bytes ADM-C-76) | ✅ (`fl_chart` + CSV fallback) | **Done** |
| ADM-S18 Announcement composer | `/announcements` | ✅ | ✅ | **Done** |
| ADM-S19 Platform settings | `/settings` | ✅ | ✅ | **Done** |
| ADM-S20 Gold-rate config | `/gold-rates` | — | placeholder | **Deferred** — out of this completion effort (Yahoo Finance redistribution terms open). Tracked in SRS §7.4 / ADM-S20. |
| ADM-S21 Abuse-report queue | `/abuse` | ✅ | ✅ | **Done** |
| ADM-S22 Audit log | `/audit` | ✅ | ✅ | **Done** |
| ADM-S23 Admin user management | `/admin-users` | ✅ | ✅ | **Done** |

## 3. Build order

**Slice 1 — land the adapted verticals (this branch).**
Vendors, verification, requests, offers repos now normalise `main`'s raw responses.
Remaining: manual click-through against a seeded local backend, screenshot pass, and the
polish items in §4. Commit per vertical.

**Slice 2 — Dashboard real data.** Replace `dashboard_screen.dart` sample data with
`GET /v1/admin/dashboard`; keep the responsive layout.

**Group A — unblocked, reuse the shipped list/detail pattern** (`KhDataTable`,
`vendor_list`/`vendor_detail`, repo→controller→model, URL query-params):
1. **ADM-S22 audit-log** — read-only filtered list, no detail route (self-contained rows, `SAM-GAP-12`). Smallest.
2. **ADM-S03 customer-list** — near-clone of vendor-list; add PII list-access audit note.
3. **ADM-S04 customer-detail** — clone of vendor-detail; suspend / reactivate / erasure dialogs.

**Group B — queue / moderation screens, backend already present:**
4. ADM-S12 + S13 connection list + detail.
5. ADM-S21 abuse-report queue.
6. ADM-S16 review moderation.
7. ADM-S23 admin user management — drop the Role selector (`SAM-GAP-13`, `AD-API-03`).

**Group C — config screens (open decisions apply):**
8. ADM-S19 platform-settings — flag the offer-validity option-set field pending the live decision.
9. ADM-S18 announcement composer — bilingual form + delivery list; `SAM-GAP-10` (no pre-send audience count).

**Group D — heaviest:**
10. ADM-S17 reports & analytics — 7 report types + async export polling; **introduce a charting library** (none in `kh_admin` yet).

## 4. Polish backlog for the adapted verticals (§2 "verify + polish")

| Item | Screens | Note |
|---|---|---|
| Manual click-through + screenshots vs seeded backend | S05–S11 | Not yet done — fixtures are synthetic |
| URL query-param state for list filters | S05, S08, S10 | Only verification syncs to the URL today (`AD-FE` §16.2) |
| Document view uses authenticated relative URL | S07 | `/v1/media/<key>` needs bearer; new-tab open can't attach it — needs a signed/public media URL from backend |
| `offers` / `requests` l10n | S08–S11 | Hardcoded English; `vendors` + `verification` are localised |
| Remove orphaned ARB keys | — | `vendorsDetailStubBody`, `vendorsDetailComingSoon` |

## 5. Known backend gaps (raise as `G2-*` follow-ups; frontends work around for now)

Live tick list: [`Admin-Backend-Followup-Tasks.md`](Admin-Backend-Followup-Tasks.md).

| Gap | Impact | Workaround in place |
|---|---|---|
| Admin list routes **double-wrap** the envelope (`body.data.data`, `body.meta.nextCursor` always null) | vendors/offers/requests lists | `ApiClient.getCollection` tolerates both shapes |
| Prisma `Decimal` columns serialise as JSON **strings** | every money/rating field | repos `double.tryParse(v.toString())` |
| `listRequests` supports only `q` + `state`; `listOffers` only `state` + `vendorId` | S08/S10 filters (`requestType`, `direction`, price/value ranges, `categoryId`, `zeroOffers`) | client-side filter of the loaded page |
| Request detail omits `matchedVendors`, `timeline`, and deep `connections` includes | S09 sections | rendered empty with `TODO(backend)` |
| Offer detail omits `stateTransitions`, `attachments`; revisions carry only a `previousTerms` JSON blob | S11 sections | parsed from blob / empty |
| `admin_note` create response has no `author`; list nests `author:{displayName}` | notes on S09/S11 | repo synthesises author from `authorAdminId` / nested object |
| `Media` rows carry no filename | doc lists on S06/S07 | `fileName` left null |

## 6. Verification

- `cd apps/kh_admin && flutter analyze && flutter test` green.
- `cd backend && npm run build && npm test` green (unchanged from `main`).
- Seeded local backend (`npm run seed` — admin email must match the Google account),
  `flutter run -d chrome --dart-define=KH_API_BASE=http://localhost:3000`, dev auto-login,
  click through each live screen; record a GIF for the PR.

## 7. `[PROPOSED]` decision register

| ID | Decision | Rationale |
|---|---|---|
| ADM-FE-P01 | Admin repos **normalise raw Prisma responses in the repository layer** rather than adding a backend DTO layer | Keeps the FE replant self-contained; backend DTOs are a separate `G2-*` concern |
| ADM-FE-P02 | Unsupported list filters are applied **client-side on the loaded page** | Avoids blocking screens on backend filter work; acceptable at current data volumes |
| ADM-FE-P03 | `AD-FE-12` (data-grid build/buy) is resolved as **build** — the minimal `KhDataTable` ships; virtualisation / column sort / keyboard nav deferred | Already in use for the shipped list screens; revisit before ADM-S03/S17/S22 hit real volume |
