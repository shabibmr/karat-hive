# Implementation Plan: Simplify Categories & Regions Taxonomy to 1 Level

**Goal:** Simplify the Karat Hive Category and Region taxonomy from a 2-level hierarchy (root and sub levels) to a clean, flat 1-level structure across the entire stack.  
**Target Date:** September 2026  
**Status:** [PROPOSED]  
**Verification Command:**  
- Backend: `cd backend && npm run test && npm run test:integration`  
- Admin: `cd apps/kh_admin && flutter analyze && flutter test`  
- Mobile: `cd apps/kh_mobile/karat_hive && flutter analyze && flutter test`  

---

## 1. Executive Summary & Rationale

Currently, Karat Hive models both **Category** (product classification) and **Region** (geographic matching) as a two-level self-referential tree (`parentId` referencing another node of the same kind). In practice:
- **Categories** are divided into top-level groups (*Jewellery, Bullion, Gold Coins, Scrap, Watches*) and leaf subcategories (*Rings, Chains, Small Bars...*).
- **Regions** are divided into Emirates (*Abu Dhabi, Dubai, Sharjah...*) and areas/souks (*Deira Gold Souk, Bur Dubai, Al Ain...*).
- In both Customer and Vendor flows, transactions and matching bind strictly to individual leaves. The parent/root level acts primarily as a grouping mechanism.
- Maintaining a 2-level tree introduces substantial complexity: recursive tree walkers, expand/collapse UI state, dual-level validation (`HIERARCHY_DEPTH_EXCEEDED`, `SELF_PARENT`), and composite indexes on `(parent_id, display_order)`.

Simplifying both taxonomies to a **single level** eliminates recursive traversal, streamlines admin taxonomy management, reduces mobile onboarding cognitive load, and cleans up the schema and API contract.

---

## 2. High-Level Architecture Diagram

```mermaid
graph TD
    subgraph Database Layer
        DB_Cat["Category Table<br/>• DROP COLUMN parent_id<br/>• DROP CONSTRAINT category_parent_id_fkey<br/>• INDEX on (display_order)"]
        DB_Reg["Region Table<br/>• DROP COLUMN parent_id<br/>• DROP CONSTRAINT region_parent_id_fkey<br/>• INDEX on (display_order)"]
        Seed["Prisma Seed (Flat taxonomy)"]
    end

    subgraph Backend Services & Edge
        Repo["TaxonomyRepository<br/>• Remove parentId inputs<br/>• Remove countChildren()"]
        Serv["TaxonomyService<br/>• Remove hierarchy depth validation<br/>• Flat audit logging"]
        Pres["TaxonomyPresenter<br/>• Remove parentId & toTree recursion<br/>• Flat sort by displayOrder"]
        Ctrl["AdminTaxonomyController<br/>• Remove parentId from Zod schemas"]
    end

    subgraph Shared Dart Packages
        Domain["kh_domain<br/>• Remove parentId from CategorySummary/RegionSummary"]
        Api["kh_api<br/>• Remove parentId from CategorySummaryDto/RegionSummaryDto"]
        UiDomain["kh_ui_domain<br/>• CategoryRegionPicker: direct node rendering"]
    end

    subgraph Flutter Admin Portal (apps/kh_admin)
        AdminModel["TaxonomyNode & DTOs<br/>• Remove parentId & children fields"]
        AdminCtrl["TaxonomyController<br/>• Flat list insert/update/sort"]
        AdminScreen["TaxonomyScreen<br/>• Remove child-mode handlers"]
        AdminList["TaxonomyTree -> Flat List<br/>• Remove chevrons & indentation"]
        AdminEditor["NodeEditorPanel<br/>• Remove Subcategory/Area creation"]
    end

    subgraph Flutter Mobile App (apps/kh_mobile)
        MobileReq["Request Create Chrome<br/>• Remove taxonomyLeaves() walk"]
        MobileReg["Vendor Register<br/>• Remove _leaves() generator"]
        MobileFeed["Request Filters Sheet<br/>• Remove _leaves() generator"]
        MobileOffers["Offer History<br/>• Remove _leaves() generator"]
    end

    DB_Cat --> Repo
    DB_Reg --> Repo
    Repo --> Serv --> Pres --> Ctrl
    Ctrl --> Api --> AdminCtrl
    Ctrl --> Api --> MobileReq
    Domain --> AdminModel
    Domain --> UiDomain
```

---

## 3. Decision Log & User Feedback Points

> [!NOTE]
> **Decisions Resolved 15 September 2026:**
>
> 1. **Active Category Set for 1-Level Model — RESOLVED: Option A.**
>    Specific product items as the 1st-level categories: *Rings, Chains & Necklaces, Bangles & Bracelets, Earrings, Pendants, Jewellery Sets, Gold Bars / Bullion, Gold Coins, Scrap & Old Gold, Luxury Gold Watches*.
>
> 2. **Active Region Set for 1-Level Model — RESOLVED: Option B.**
>    Strictly the 7 Emirates: *Abu Dhabi, Dubai, Sharjah, Ajman, Umm Al Quwain, Ras Al Khaimah, Fujairah*. No separate souk-zone entries (e.g. no standalone *Deira Gold Souk* node) — souk-level detail, if ever needed, is out of scope for this taxonomy.
>
> 3. **API Backward Compatibility — RESOLVED: drop immediately.**
>    `GET /v1/categories` and `GET /v1/regions` ship the trimmed `TaxonomyNode` shape at deploy time — no `children` field, no `parentId`. No transition window; mobile/admin clients must be updated in the same release.

---

## 4. Comprehensive Inventory of Changes

### 4.1. Database & Persistence Layer (`backend/prisma/`)

#### 1. `backend/prisma/schema.prisma`
- **Category Model**:
  - Remove `parentId String? @map("parent_id") @db.Uuid`
  - Remove `parent Category? @relation("CategoryTree", fields: [parentId], references: [id], onDelete: Restrict)`
  - Remove `children Category[] @relation("CategoryTree")`
  - Change `@@index([parentId, displayOrder])` to `@@index([displayOrder])`
- **Region Model**:
  - Remove `parentId String? @map("parent_id") @db.Uuid`
  - Remove `parent Region? @relation("RegionTree", fields: [parentId], references: [id], onDelete: Restrict)`
  - Remove `children Region[] @relation("RegionTree")`
  - Change `@@index([parentId, displayOrder])` to `@@index([displayOrder])`

#### 2. Prisma SQL Migration (`backend/prisma/migrations/20260915120000_flatten_taxonomy/migration.sql`)
```sql
-- Drop self-referential foreign keys
ALTER TABLE "category" DROP CONSTRAINT IF EXISTS "category_parent_id_fkey";
ALTER TABLE "region" DROP CONSTRAINT IF EXISTS "region_parent_id_fkey";

-- Drop composite hierarchy indexes
DROP INDEX IF EXISTS "category_parent_id_display_order_idx";
DROP INDEX IF EXISTS "region_parent_id_display_order_idx";

-- Create single-level display order indexes
CREATE INDEX "category_display_order_idx" ON "category"("display_order");
CREATE INDEX "region_display_order_idx" ON "region"("display_order");

-- Drop parent_id columns
ALTER TABLE "category" DROP COLUMN IF EXISTS "parent_id";
ALTER TABLE "region" DROP COLUMN IF EXISTS "parent_id";
```

#### 3. `backend/prisma/seed/taxonomy.seed.ts`
- Flatten `CATEGORIES` array to 1-level list with optional `icon` keys.
- Flatten `REGIONS` array to 1-level list.
- Replace `seedTree()` with a flat upsert function `seedFlat()`.

---

### 4.2. Backend Application Layer (`backend/src/modules/taxonomy/`)

#### 1. `repository/taxonomy.repository.ts`
- Remove `parentId` from `CreateTaxonomyInput` and `UpdateTaxonomyInput`.
- Update `createCategory()` and `createRegion()`:
  - Aggregate max `displayOrder` across all active items without `parentId` filtering.
- Remove `countChildren(kind, id)`.
- Update `countReferences(kind, id)`:
  - Categories: Count `request.count({ where: { categoryId: id } }) + vendorCategory.count({ where: { categoryId: id } })`.
  - Regions: Count `request.count({ where: { regionId: id } }) + vendorRegion.count({ where: { regionId: id } }) + customerProfile.count({ where: { defaultRegionId: id } })`.

#### 2. `application/taxonomy.service.ts`
- Remove `if (input.parentId)` validation blocks in `create()` and `update()`.
- Remove `HIERARCHY_DEPTH_EXCEEDED` and `SELF_PARENT` error paths.
- Remove children check on update (`A node with existing children cannot become a child...`).
- Simplify `listTree()` to return the sorted flat list from repository.
- Remove `parentId` from before/after audit log snapshots.

#### 3. `presenter/taxonomy.presenter.ts`
- `CategorySummary`: Remove `parentId`.
- `RegionSummary`: Remove `parentId`.
- `TaxonomyNode`:
  ```typescript
  export type TaxonomyNode = {
    id: string;
    nameEn: string;
    nameAr: string;
    displayOrder: number;
    isActive: boolean;
    icon?: string | null;
  };
  ```
- Replace `toTree()` with `presentFlatList()`:
  ```typescript
  function presentFlat(rows: Rowish[]): TaxonomyNode[] {
    return rows
      .map(r => ({
        id: r.id,
        nameEn: r.nameEn,
        nameAr: r.nameAr,
        displayOrder: r.displayOrder,
        isActive: r.isActive,
        ...(r.icon ? { icon: r.icon } : {}),
      }))
      .sort((a, b) => a.displayOrder - b.displayOrder || a.nameEn.localeCompare(b.nameEn));
  }
  ```

#### 4. `controller/admin-taxonomy.controller.ts`
- Remove `parentId` field from `createCategorySchema`, `updateCategorySchema`, `createRegionSchema`, and `updateRegionSchema`.

#### 5. Backend Unit & Integration Tests
- `backend/src/modules/taxonomy/application/taxonomy.service.spec.ts`: Remove tests for hierarchy depth violation and self-parenting.
- `backend/src/modules/taxonomy/controller/admin-taxonomy.controller.spec.ts`: Update test payloads without `parentId`.
- `backend/test/integration/admin-taxonomy.spec.ts`: Verify flat CRUD operations.

---

### 4.3. Shared Dart Packages (`packages/`)

#### 1. `packages/kh_domain/lib/src/party.dart`
- In `CategorySummary`: Remove `final String? parentId;`, remove constructor arg `this.parentId`, remove `j['parentId']`.
- In `RegionSummary`: Remove `final String? parentId;`, remove constructor arg `this.parentId`, remove `j['parentId']`.

#### 2. `packages/kh_api/lib/src/dtos/common_dtos.dart`
- In `CategorySummaryDto`: Remove `parentId`.
- In `RegionSummaryDto`: Remove `parentId`.

#### 3. `packages/kh_ui_domain/lib/kh_ui_domain.dart`
- In `CategoryRegionPicker`:
  - Remove recursive tree-walking function `void walk(TaxonomyNode n)`.
  - Render `FilterChip` items directly from `nodes`.

---

### 4.4. Flutter Admin Web Portal (`apps/kh_admin/`)

#### 1. Models & DTOs
- `lib/features/taxonomy/model/taxonomy_node.dart`:
  - Remove `String? parentId` and `List<TaxonomyNode> children`.
- `lib/features/taxonomy/model/taxonomy_dto.dart`:
  - Remove `String? parentId` from `CreateTaxonomyDto` and `UpdateTaxonomyDto`.
- Re-run `dart run build_runner build --delete-conflicting-outputs`.

#### 2. Controller
- `lib/features/taxonomy/controller/taxonomy_controller.dart`:
  - Replace `_insertIntoTree` and `_updateInTree` with flat list insert and map:
  ```dart
  static List<TaxonomyNode> _insertIntoList(List<TaxonomyNode> list, TaxonomyNode newNode) {
    final updated = [...list, newNode];
    _sortList(updated);
    return updated;
  }
  ```

#### 3. Presentation & Screen Components
- `lib/features/taxonomy/presentation/taxonomy_screen.dart`:
  - Remove `_findParentOf` and recursive child search in `_findNodeById`.
  - Remove `onRequestCreateChild` and `EditorMode.createChild`.
  - Rename action button from "+ Add Root Category" to "+ Add Category" (and "+ Add Region").
  - Update subtitles to reflect single-level management.
- `lib/features/taxonomy/presentation/taxonomy_tree.dart`:
  - Refactor into flat `TaxonomyListView`.
  - Remove expand/collapse chevrons, `_expandedNodeIds`, indentation (`spacing.treeIndent`), and `subdirectory_arrow_right`.
  - Simplify search filtering to match directly on flat nodes without child aggregation.
- `lib/features/taxonomy/presentation/node_editor_panel.dart`:
  - Simplify `EditorMode` enum to:
    ```dart
    enum EditorMode { edit, create }
    ```
  - Remove `parentNode` and `onRequestCreateChild` props.
  - Remove "Child of: ..." subtitle in header.
  - Remove `canCreateChild`, "+ Add Subcategory", and "+ Add Area" buttons.
- `lib/l10n/app_en.arb` & `app_ar.arb`:
  - Update `categoriesSubtitle` and `regionsSubtitle`.
  - Remove obsolete keys: `newChildCategory`, `newChildRegion`, `addChildCategory`, `addChildRegion`, `levelLimitReached`.

#### 4. Admin Portal Tests
- `apps/kh_admin/test/features/taxonomy/taxonomy_screen_test.dart`
- `apps/kh_admin/test/features/taxonomy/taxonomy_controller_test.dart`
- `apps/kh_admin/test/features/taxonomy/taxonomy_repository_test.dart`
- `apps/kh_admin/test/responsive/admin_responsive_test.dart`

---

### 4.5. Flutter Mobile App (`apps/kh_mobile/`)

#### 1. Request Creation
- `apps/kh_mobile/karat_hive/lib/features/request_create/presentation/widgets/create_flow_chrome.dart`:
  - Simplify `taxonomyLeaves(List<TaxonomyNode> nodes)` to directly return `nodes`.

#### 2. Vendor Onboarding & Registration
- `apps/kh_mobile/karat_hive/lib/features/auth/presentation/vendor_register_screen.dart`:
  - Remove `_leaves()` tree traversal helper; pass `nodes` directly.

#### 3. Filtering Sheets
- `apps/kh_mobile/karat_hive/lib/features/request_feed/presentation/request_filters_sheet.dart`:
  - Remove `_leaves()` tree traversal helper.
- `apps/kh_mobile/karat_hive/lib/features/offers_vendor/presentation/offer_history_screen.dart`:
  - Remove `_leaves()` tree traversal helper.

#### 4. Mobile Test Suites
- Update mock test data in `request_feed_screens_test.dart`, `request_filters_sheet_test.dart`, `mobile_responsive_test.dart`, and `guest_lookups_media_test.dart`.

---

## 5. Execution Phasing & Rollout Order

| Phase | Steps & Work items | Verification |
|---|---|---|
| **Phase 1: DB & Seed** | 1. Update `schema.prisma`<br/>2. Generate & test migration<br/>3. Flatten `taxonomy.seed.ts` | Prisma migrate & seed runs cleanly |
| **Phase 2: Backend Core** | 1. Update `TaxonomyRepository` & `TaxonomyService`<br/>2. Update `TaxonomyPresenter`<br/>3. Update `AdminTaxonomyController` Zod schemas | `npm run test` & `npm run test:integration` |
| **Phase 3: Shared Packages** | 1. Update `kh_domain`<br/>2. Update `kh_api`<br/>3. Update `kh_ui_domain` | `flutter analyze && flutter test` in all 3 packages |
| **Phase 4: Admin Portal** | 1. Update Freezed DTOs & re-run `build_runner`<br/>2. Update `TaxonomyController`<br/>3. Update `TaxonomyScreen`, `TaxonomyTree`, and `NodeEditorPanel`<br/>4. Update ARB files | `flutter test` in `apps/kh_admin` |
| **Phase 5: Mobile App** | 1. Simplify `taxonomyLeaves()` & `_leaves()` calls<br/>2. Update test fixtures | `flutter test` in `apps/kh_mobile/karat_hive` |
| **Phase 6: Documentation** | 1. Update `API-Route-Inventory.md`<br/>2. Update `Physical-Data-Model.md` | Doc review |

---

## 6. Verification & Validation Plan

### Automated Test Commands
```bash
# 1. Backend validation
cd /Users/admin/code/gold/karat-hive/backend
npm run test
npm run test:integration

# 2. Shared packages validation
cd /Users/admin/code/gold/karat-hive/packages/kh_domain && flutter test
cd /Users/admin/code/gold/karat-hive/packages/kh_api && flutter test
cd /Users/admin/code/gold/karat-hive/packages/kh_ui_domain && flutter test

# 3. Admin App validation
cd /Users/admin/code/gold/karat-hive/apps/kh_admin
flutter analyze
flutter test

# 4. Mobile App validation
cd /Users/admin/code/gold/karat-hive/apps/kh_mobile/karat_hive
flutter analyze
flutter test
```

### Manual Verification Steps
1. **Admin Categories Screen (`/taxonomy/categories`)**:
   - Verify category list renders as a flat list with order, icon, and active status chips.
   - Click "+ Add Category"; verify only standard name/icon/order inputs appear (no parent selector).
   - Edit an existing category and save; verify immediate update and success toast.
   - Verify no "+ Add Subcategory" button appears anywhere.
2. **Admin Regions Screen (`/taxonomy/regions`)**:
   - Verify region list renders flat.
   - Add/edit/deactivate a region; verify smooth operation.
3. **Mobile Request Creation Flow**:
   - Select "Find An Ornament" -> verify category picker shows the flat list.
   - Verify region selection renders the flat list cleanly.
4. **Vendor Onboarding / Settings**:
   - Open Categories & Regions declaration screen.
   - Select categories and regions; save and verify vendor activation status triggers properly.
