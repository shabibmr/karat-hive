# S3 · Shared widgets & performance

> Work order derived from [`../comprehensive-review.md`](../comprehensive-review.md) §3.3.5 and §4.4. Line numbers are HEAD `8880298` artefacts.

| | |
|---|---|
| **Goal** | Make the admin table lazy, stop whole-state rebuilds, bound image decode. |
| **Owner** | 1 agent. |
| **Parallelism** | Build the widget in isolation early; rewire list screens **per feature after S1 migrates that feature**. |
| **Depends on** | S0; then S1 per-list. |
| **Blocks** | — |
| **Owns** | `lib/core/widgets/kh_data_table.dart`, the list-screen scroll wrappers (jointly sequenced with S1), image/media widgets |
| **Do not** | pick a third-party data-grid — `AD-FE-12` (build or buy) is still open; build the lazy viewport only |

## `E13` / `ADM-SMP-40` / `ADM-SMP-41` — virtualise `KhDataTable`
- **Now:** `kh_data_table.dart:73-81` builds every row into a `Column` via a `for` loop — no `ListView.builder` path at any page size. Masked today by a default page size of 20 (`request_repository.dart:15`); the widget has no ceiling. All **12** hosting screens wrap it in an outer `SingleChildScrollView` while the table runs its own scroll view internally (`kh_data_table.dart:69`) → two nested scroll/layout passes per frame. Screens: `request_list`, `vendor_list`, `offer_list`, `announcements`, `platform_settings`, `admin_users`, `moderation`, `abuse`, `audit`, `connection_list`, `customer_list`, `reports`. 16 `KhDataTable` call sites, all eager. Sidebar already uses `ListView.separated`; tables don't.
- **Do:** replace the `Column` + `for` with a vertical `ListView.builder` (fixed `itemExtent` from `kh.spacing.tableRowHeight`) inside the horizontal scroller. Drop the outer `SingleChildScrollView` at each call site. Keep the row hover (`InkWell.hoverColor`) and header behaviour.
- **Sequence:** build + golden the new table behind the existing API first. Then, as S1 lands each list feature on the kernel, swap that screen. Do not rewire a screen whose controller S1 hasn't migrated.
- **Done when:** a 500-row page renders without building 500 widgets; one scroll view per list screen.

## `ADM-SMP-42` — `.select()` granularity
- **Now:** `grep -rn "\.select(" lib/` returns **0** across 191 files. Every screen `ref.watch`es whole controller state, so a filter-chip tweak rebuilds the table (`ADM-INS-73`). `RequestListState` bundles 10 fields; flipping `isLoadingMore` during `nextPage()` rebuilds the whole subtree though `items` didn't change.
- **Do:** `ref.watch(listProvider.select((s) => s.items))` for the table; separate watches for filters, pagination flags, error. Pairs naturally with S1's sealed kernel state — coordinate so the state shape exposes clean selectors.
- **Done when:** toggling a filter chip or `isLoadingMore` does not rebuild the row list.

## `E29` / `ADM-INS-72` / `ADM-INS-48` — image decode bounds + signed KYC
- **Now:** no decode bounds on KYC / vendor documents. KYC open path: presentation fetches URL then `window.open`; bearer-less `/v1/media/<key>` is a risk if signed URLs aren't used.
- **Do:** add `cacheWidth` / `cacheHeight` wherever thumbnails render. For signed-URL KYC open, coordinate with S4 (it owns the media/auth path) — S3 only bounds the decode.
- **Done when:** no full-resolution decode for a thumbnail-sized slot.

## Verification
`flutter analyze && flutter test`; scroll a large list at 60fps in profile mode; S7 goldens for `KhDataTable` (LTR/RTL/200%) pass.
