# Admin Portal review — Part 4: Unified picture & identifier index

| | |
|---|---|
| **Product** | Karat Hive |
| **Surface** | Flutter Web Admin Portal (`apps/kh_admin`) plus the four-surface documentation carve that feeds it |
| **HEAD** | `88802985d39a4679724875d900275fa038d3bb89` (`main` = `origin/main`) — abbreviated `8880298` in source notes |
| **Dates** | Carve analysis 8 September 2026 · Flutter/Dart and simplification 9 September 2026 |
| **Status** | Part 4 of 4, split by category from [`comprehensive-review.md`](comprehensive-review.md) at HEAD `8880298`. **Not the plan of record.** `Admin-App-Completion-Plan.md` still owns product scope. |
| **Does not override** | SRS v1.3 · `API-Route-Inventory.md` · `Architecture-Frontend.md` · `Architecture-Backend.md` · `Admin-App-Completion-Plan.md` |
| **Does not mint** | `FR-*`, `AD-FE-*`, `AD-API-*`, `ADM-S*`, `ADM-C-*`, `SAM-GAP-*`, `ADM-INS-*` — those are cited, not replaced |
| **Decision prefixes in play** | `SDC-nn` (carve) · `ADM-SMP-nn` (simplification) · `E1`–`E30` (Flutter/Dart enhancements) |

This is **part 4 of 4** split from [`comprehensive-review.md`](comprehensive-review.md); the combined document remains the single-file reading and is unchanged. Sibling parts: [carve](comprehensive-review-carve-v1.md) · [flutter-dart](comprehensive-review-flutter-dart-v1.md) · [simplification](comprehensive-review-simplification-v1.md). Section numbering (§5, §6) is inherited from the parent. For how the three reviews relate, see §0 in [carve-v1](comprehensive-review-carve-v1.md).

---

## 5. Unified picture — what is already true, what is still open

**IDs resolve in:** `SDC-*` → [carve-v1](comprehensive-review-carve-v1.md) §1.2 · `E1`–`E30` → [flutter-dart-v1](comprehensive-review-flutter-dart-v1.md) §3.4 · `ADM-SMP-*` → [simplification-v1](comprehensive-review-simplification-v1.md) §4.1 · `ADM-INS-*` → companion [`docs/inspection/`](../inspection/README.md) · full index in §6 below.

### 5.1 Facts all three reviews agree on

These are the same fact, named three ways. Do not mint a fourth ID.

| Fact | Inspection | Flutter/Dart | Simplification |
|---|---|---|---|
| `kh_admin` is outside Melos / shared packages; it reimplements a *regressed* subset of `kh_core` | `ADM-INS-53` | §3.3.1, E15 | `ADM-SMP-01`, `ADM-SMP-65` |
| Two list-controller families; boolean soup; ~900 duplicated lines | `ADM-INS-19`, `ADM-INS-20` | §3.3.4, E9 | `ADM-SMP-20`, `ADM-SMP-21`, `ADM-SMP-61` |
| God presentation files (request 1,484 / offer 1,388 / announcements 1,210) | `ADM-INS-22` | §3.3.3, E12 | `ADM-SMP-26`, `ADM-SMP-27` |
| `KhDataTable` eager `Column`+`for`; nested `SingleChildScrollView`; blocked on `AD-FE-12` | `ADM-INS-13`, `ADM-INS-70` | §3.3.5, E13 | `ADM-SMP-40`, `ADM-SMP-41` |
| URL query state only on some lists; 8 of 13 have none | `ADM-INS-33` | §3.3.11, E19 | `ADM-SMP-07` PART, `ADM-SMP-63` |
| Empty `gold_rate/` + `auth/` shells; Gold Rates is a placeholder | `ADM-INS-21`, `ADM-INS-51` | E8 | `ADM-SMP-31`; nav exclusion **FIXED** as `ADM-SMP-32`/`60` |
| Dead Firestore / Analytics services; FCM foreground never wired | `ADM-INS-41`, `ADM-INS-42` | E23 | `ADM-SMP-30` **FIXED** (services deleted; FCM file kept) |
| Envelope unwrap re-derived per repo | `ADM-INS-52` | (folded into E9 / `AD-FE-06`) | `ADM-SMP-04`, `ADM-SMP-05`, `ADM-SMP-10`, `ADM-SMP-62` |
| No `.select(`; whole-state watches | `ADM-INS-73` | §3.3.4 | `ADM-SMP-42` |
| Analyzer too loose; `unused_element: ignore`; `riverpod_lint` unused | `ADM-INS-15` | E10 | `ADM-SMP-33` |
| `fl_chart` eager; no `deferred as` | `ADM-INS-37` | E23 | `ADM-SMP-45` |
| Client-side filter of a page (`admin_users` whole dataset; requests `where` after fetch) | `ADM-INS-46` | E20 | `ADM-SMP-29` |

### 5.2 What the carve must carry that the code reviews do not own

These are documentation-scope, not Dart-scope. They belong in `01-Admin-Requirements.md` and `02-Admin-API-Contract.md` if the carve proceeds.

- 33 `FR-ADM` requirements, of which 6 are `[ASSUMED]` (`002`, `012`, `019`, `028`, `032`, `033`) and need Product Owner sign-off.
- 60 specified admin routes vs ~45 live; double-wrapped envelope and `Decimal`→string as built on `main`.
- ADM-S20 deferred pending Yahoo Finance redistribution terms. Backend exists; UI is out of scope. Do not silently implement.
- `FR-ADM-002` role differentiation deferred. v1 RBAC is flat `role = ADMIN` (`AD-API-03`). ADM-S23 ships with no Role selector (`SAM-GAP-13`) even though `ui-screens/admin/README.md` still documents three roles. Live tension — do not silently resolve.
- Admin is the masking **exemption** (Arch-Backend §9.5). Masked fields are absent from customer/vendor payloads; admin always sees identity.
- Shared admin list query `limit` max 100.
- Open carve decisions: `SDC-07` (move vs copy) and `SDC-08` (skill after admin pilot).

### 5.3 What Tier-0 already closed (do not re-do)

| Closed | How |
|---|---|
| Duplicate `hasMore` / `_asMap` / `_toDouble` | `lib/core/api/json_parse.dart` |
| Duplicate `_stringMapsEqual` + query-nav try/catch | `lib/core/router/query_navigation.dart` (`ADM-SMP-07` still PART — 5 files not all migrated) |
| 350 ms debounce plumbing on 9 list screens | `lib/core/widgets/debounced_search_mixin.dart` |
| `dynamic kh` on 35 helpers | typed `KhThemeExtension` |
| Per-frame `DateFormat` / `NumberFormat` | `lib/core/format/kh_formats.dart` |
| Export poll 400 ms × 40 | doubling backoff, 12 attempts, 2 s cap |
| Dead Firestore + Analytics services | deleted; FCM background handler kept |
| Router placeholder exclusion list | `isLive` is the single source of truth |

### 5.4 Ranked remaining work (no new IDs)

This is a reading order, not a new plan of record. `Admin-App-Completion-Plan.md` still owns product scope.

| Rank | Work | Why first | Do not mix with |
|---|---|---|---|
| 1 | **E3 + E5 + E10 + E18** | Typed API errors, global Flutter error hooks, strict analyzer, missing request-list widget test. Safer default for every later screen. | Riverpod 3, `AD-FE-12`, ADM-S20 |
| 2 | **`ADM-SMP-64`** | Taxonomy/verification URL-clear is a real behaviour bug; the shared helper already has the right semantics. Wants a regression test. | Visual banner merge (`ADM-SMP-08`) |
| 3 | **E1 + E2 + E6 + E7** | Web token policy, idle timeout, redacting logger, password form gated to autologin. P0 security. | Package-graph migration |
| 4 | **`ADM-SMP-65` / E15** (sign-off) | Rejoin Melos / `path:` deps. Dissolves the fork (`ADM-SMP-01`) and much of the list kernel / envelope work. Migration is not cheap. | List-kernel rewrite in the fork |
| 5 | **E9 / `ADM-SMP-61`** | One list kernel. Collapses `ADM-SMP-20/21/24/25` and most of `13`. Prefer adopting `kh_core`'s `PagedListController` *after* rank 4, not before. | Riverpod 3 upgrade |
| 6 | **`ADM-SMP-62`** | Normalise the envelope once in `ApiClient._send`. Collapses remaining `ADM-SMP-04/05/10`. | Per-repo sentinel tweaks |
| 7 | **E13 / `ADM-SMP-40/41`** | Virtualised table. Blocked on `AD-FE-12`. Do not resolve buy-vs-build inside a cleanup PR. | Scroll-semantics change without a grid decision |
| 8 | **E14, E24, E12** | ARB + Semantics + split god screens. Product-visible, high volume, no architecture fork. | — |
| 9 | **Carve phases 1–2** | `docs/core/` then the 35-file admin set, by hand. Independent of Dart work. Confirm `SDC-07` and `SDC-08` first. | Authoring the skill before the admin pilot |

### 5.5 Explicit non-goals (repeated because they are easy to violate)

- Do not override the SRS, the API inventory, or either architecture document.
- Do not mint `FR-*`, `AD-FE-*`, `ADM-S*`, `SAM-GAP-*`, or additional `ADM-INS-*` from these reviews.
- Do not silently implement ADM-S20.
- Do not silently resolve `FR-ADM-002` three-role vs flat-`ADMIN` tension.
- Do not add Redis, Kafka, Elasticsearch, or keep Firestore “just in case” (`C-12`, `AD-FE-09`).
- Do not jump Riverpod 3 in the same slice as list-state unification.
- Do not resolve `AD-FE-12` (build or buy the admin data grid) inside a cleanup PR.
- Do not treat this synthesis as the plan of record.

---

## 6. Identifier index

Every identifier this folder uses, so they are not re-derived.

| Prefix | Meaning | Count / range | Status |
|---|---|---|---|
| `SDC-01`–`06` | Carve decisions, agreed | 6 | Proposal, not executed |
| `SDC-07`, `SDC-08` | Move-vs-copy · skill-after-pilot | 2 | Open for confirmation |
| `ADM-SMP-01`–`13` | Reuse | 13 (4 FIXED, 1 PART, 8 OPEN) | Snapshot + Tier-0 |
| `ADM-SMP-20`–`33` | Simplification | 14 (3 FIXED, 11 OPEN) | Snapshot + Tier-0 |
| `ADM-SMP-40`–`46` | Efficiency | 7 (2 FIXED, 5 OPEN) | Snapshot + Tier-0 |
| `ADM-SMP-60`–`65` | Altitude | 6 (1 FIXED, 5 OPEN) | Snapshot + Tier-0 |
| `E1`–`E8` | Flutter/Dart P0 enhancements | 8 | Suggested slices |
| `E9`–`E18` | Flutter/Dart P1 enhancements | 10 | Suggested slices |
| `E19`–`E30` | Flutter/Dart P2 enhancements | 12 | Suggested slices |
| `FR-ADM-001`–`033` | Admin functional requirements | 33 (6 `[ASSUMED]`) | SRS, cited |
| `ADM-S01`–`S23` | Admin screens | 23 (S20 deferred) | SRS Appendix C.3, cited |
| `ADM-INS-01`–`87` | Inspection register | 87, gaps reserved | Companion folder, cited |

Reserved and unused on purpose: `ADM-SMP-14`–`19`, `34`–`39`, `47`–`59`, `66`–`79`. Gaps are reserved, not mistakes.
