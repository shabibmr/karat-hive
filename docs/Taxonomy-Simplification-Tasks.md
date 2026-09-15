# Taxonomy Simplification — Implementation task list

| | |
|---|---|
| **Product** | Karat Hive |
| **Document** | Executable task list derived from [`Taxonomy-Simplification-Plan.md`](Taxonomy-Simplification-Plan.md) |
| **Status** | Working backlog — plan is `[PROPOSED]`, blocked on Decision Log (plan §3) |
| **Prefix** | `TAX-nn` — stable, never reused |
| **Does not override** | `Taxonomy-Simplification-Plan.md` · SRS v1.3 · Physical-Data-Model · API-Route-Inventory |

This file is the work list: IDs, order, files, acceptance. It does not restate rationale — see plan §1. Gate 0 decisions are resolved (plan §3, 15 September 2026): Categories = specific items (Option A), Regions = 7 Emirates only, no souk zones (Option B), API compat = drop `children`/`parentId` immediately, no transition window.

**Verification commands** (plan header):
- Backend: `cd backend && npm run test && npm run test:integration`
- Admin: `cd apps/kh_admin && flutter analyze && flutter test`
- Mobile: `cd apps/kh_mobile/karat_hive && flutter analyze && flutter test`

---

## Gate 0 — Decisions (resolved 15 September 2026)

| ID | Task | Resolution | Status |
|---|---|---|---|
| `TAX-00a` | Active **Category** set (plan §3.1) | **Option A** — specific items: Rings, Chains & Necklaces, Bangles & Bracelets, Earrings, Pendants, Jewellery Sets, Gold Bars/Bullion, Gold Coins, Scrap & Old Gold, Luxury Gold Watches | resolved |
| `TAX-00b` | Active **Region** set (plan §3.2) | **Option B** — 7 Emirates only (Abu Dhabi, Dubai, Sharjah, Ajman, Umm Al Quwain, Ras Al Khaimah, Fujairah); no souk-zone entries | resolved |
| `TAX-00c` | API backward-compatibility approach (plan §3.3) | **Drop immediately** — `children`/`parentId` removed from `TaxonomyNode` at deploy time, no transition window | resolved |

---

## Phase 1 — DB & Seed (`backend/prisma/`)

| ID | Task | File(s) | Depends on | Status |
|---|---|---|---|---|
| `TAX-01` | Remove `parentId`/`parent`/`children` from `Category` and `Region` models; change composite index to `(displayOrder)` | `backend/prisma/schema.prisma` | `TAX-00a`, `TAX-00b` | open |
| `TAX-02` | Write & run migration: drop `*_parent_id_fkey`, drop composite hierarchy indexes, create flat `display_order` indexes, drop `parent_id` columns | `backend/prisma/migrations/20260915120000_flatten_taxonomy/migration.sql` | `TAX-01` | open |
| `TAX-03` | Flatten `CATEGORIES`/`REGIONS` arrays to 1-level lists; replace `seedTree()` with `seedFlat()` | `backend/prisma/seed/taxonomy.seed.ts` | `TAX-00a`, `TAX-00b`, `TAX-02` | open |

**Verify:** `npx prisma migrate dev` and seed run cleanly against a scratch DB.

---

## Phase 2 — Backend Core (`backend/src/modules/taxonomy/`)

| ID | Task | File(s) | Depends on | Status |
|---|---|---|---|---|
| `TAX-04` | Remove `parentId` from create/update inputs; drop `parentId` filtering from max-`displayOrder` aggregation; remove `countChildren()`; update `countReferences()` per kind | `repository/taxonomy.repository.ts` | `TAX-02` | open |
| `TAX-05` | Remove `HIERARCHY_DEPTH_EXCEEDED`/`SELF_PARENT` validation and children-on-update check; simplify `listTree()` to flat sorted list; drop `parentId` from audit snapshots | `application/taxonomy.service.ts` | `TAX-04` | open |
| `TAX-06` | Drop `parentId` from `CategorySummary`/`RegionSummary`; replace `toTree()` with `presentFlat()`; drop `children` from `TaxonomyNode` entirely (`TAX-00c`: no transition window) | `presenter/taxonomy.presenter.ts` | `TAX-05` | open |
| `TAX-07` | Remove `parentId` from Zod schemas (`createCategorySchema`, `updateCategorySchema`, `createRegionSchema`, `updateRegionSchema`) | `controller/admin-taxonomy.controller.ts` | `TAX-06` | open |
| `TAX-08` | Remove hierarchy-depth/self-parent unit tests; update payloads without `parentId` | `application/taxonomy.service.spec.ts`, `controller/admin-taxonomy.controller.spec.ts` | `TAX-07` | open |
| `TAX-09` | Update/extend integration tests to verify flat CRUD | `backend/test/integration/admin-taxonomy.spec.ts` | `TAX-08` | open |

**Verify:** `cd backend && npm run test && npm run test:integration`

---

## Phase 3 — Shared Dart Packages (`packages/`)

| ID | Task | File(s) | Depends on | Status |
|---|---|---|---|---|
| `TAX-10` | Remove `parentId` from `CategorySummary`/`RegionSummary` (field, ctor arg, JSON parse) | `packages/kh_domain/lib/src/party.dart` | `TAX-06` | open |
| `TAX-11` | Remove `parentId` from `CategorySummaryDto`/`RegionSummaryDto` | `packages/kh_api/lib/src/dtos/common_dtos.dart` | `TAX-06` | open |
| `TAX-12` | Remove recursive `walk(TaxonomyNode n)`; render `FilterChip`s directly from `nodes` in `CategoryRegionPicker` | `packages/kh_ui_domain/lib/kh_ui_domain.dart` | `TAX-10`, `TAX-11` | open |

**Verify:** `flutter test` in `kh_domain`, `kh_api`, `kh_ui_domain`.

---

## Phase 4 — Admin Portal (`apps/kh_admin/`)

| ID | Task | File(s) | Depends on | Status |
|---|---|---|---|---|
| `TAX-13` | Remove `parentId`/`children` from model and Create/Update DTOs; re-run `build_runner` | `lib/features/taxonomy/model/taxonomy_node.dart`, `taxonomy_dto.dart` | `TAX-11` | open |
| `TAX-14` | Replace `_insertIntoTree`/`_updateInTree` with flat `_insertIntoList`/update+sort | `lib/features/taxonomy/controller/taxonomy_controller.dart` | `TAX-13` | open |
| `TAX-15` | Remove `_findParentOf`, recursive child search, `onRequestCreateChild`, `EditorMode.createChild`; rename "+ Add Root Category" → "+ Add Category" (and Region); update subtitles | `lib/features/taxonomy/presentation/taxonomy_screen.dart` | `TAX-14` | open |
| `TAX-16` | Refactor tree view into flat `TaxonomyListView`; remove chevrons, `_expandedNodeIds`, indentation, `subdirectory_arrow_right` | `lib/features/taxonomy/presentation/taxonomy_tree.dart` | `TAX-14` | open |
| `TAX-17` | Simplify `EditorMode` to `{edit, create}`; remove `parentNode`, `onRequestCreateChild`, "Child of:" subtitle, `canCreateChild`, "+ Add Subcategory"/"+ Add Area" | `lib/features/taxonomy/presentation/node_editor_panel.dart` | `TAX-14` | open |
| `TAX-18` | Update `categoriesSubtitle`/`regionsSubtitle`; remove `newChildCategory`, `newChildRegion`, `addChildCategory`, `addChildRegion`, `levelLimitReached` | `lib/l10n/app_en.arb`, `app_ar.arb` | `TAX-15` | open |
| `TAX-19` | Update tests for flat model/controller/screen/repository and responsive suite | `test/features/taxonomy/taxonomy_screen_test.dart`, `taxonomy_controller_test.dart`, `taxonomy_repository_test.dart`, `test/responsive/admin_responsive_test.dart` | `TAX-13`–`TAX-18` | open |

**Verify:** `cd apps/kh_admin && flutter analyze && flutter test`

---

## Phase 5 — Mobile App (`apps/kh_mobile/karat_hive/`)

| ID | Task | File(s) | Depends on | Status |
|---|---|---|---|---|
| `TAX-20` | Simplify `taxonomyLeaves(List<TaxonomyNode> nodes)` to return `nodes` directly | `lib/features/request_create/presentation/widgets/create_flow_chrome.dart` | `TAX-12` | open |
| `TAX-21` | Remove `_leaves()` tree-traversal helper; pass `nodes` directly | `lib/features/auth/presentation/vendor_register_screen.dart` | `TAX-12` | open |
| `TAX-22` | Remove `_leaves()` tree-traversal helper | `lib/features/request_feed/presentation/request_filters_sheet.dart` | `TAX-12` | open |
| `TAX-23` | Remove `_leaves()` tree-traversal helper | `lib/features/offers_vendor/presentation/offer_history_screen.dart` | `TAX-12` | open |
| `TAX-24` | Update mock/fixture data to flat taxonomy | `request_feed_screens_test.dart`, `request_filters_sheet_test.dart`, `mobile_responsive_test.dart`, `guest_lookups_media_test.dart` | `TAX-20`–`TAX-23` | open |

**Verify:** `cd apps/kh_mobile/karat_hive && flutter analyze && flutter test`

---

## Phase 6 — Documentation

| ID | Task | File(s) | Depends on | Status |
|---|---|---|---|---|
| `TAX-25` | Update route/schema references to drop `parentId`, reflect flat taxonomy | `docs/API-Route-Inventory.md` | `TAX-09` | open |
| `TAX-26` | Update Category/Region table definitions to drop `parent_id`, `parent`/`children` relations | `docs/Physical-Data-Model.md` | `TAX-02` | open |

**Verify:** doc review — grep for `parentId`/`parent_id` across `docs/` returns no stale references outside `docs/old/`.

---

## Manual verification (post-implementation, plan §6)

| ID | Check | Depends on |
|---|---|---|
| `TAX-27` | Admin Categories screen: flat list w/ order, icon, active chips; "+ Add Category" has no parent selector; edit/save works; no "+ Add Subcategory" anywhere | `TAX-15`, `TAX-17` |
| `TAX-28` | Admin Regions screen: flat list; add/edit/deactivate works | `TAX-15`, `TAX-17` |
| `TAX-29` | Mobile request creation: category picker and region picker render flat lists | `TAX-20` |
| `TAX-30` | Vendor onboarding/settings: Categories & Regions declaration screen selects and saves correctly, activation status triggers | `TAX-21` |
