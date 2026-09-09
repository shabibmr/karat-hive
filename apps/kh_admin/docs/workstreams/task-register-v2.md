# Admin Portal — workstream task register (v2)

> **Supersedes** [`task-register-v1.md`](task-register-v1.md) — v1 is retained as the
> full record (every task, including the completed ones with their timestamps). This v2
> file carries **only the tasks still open** as of 2026-09-09.
>
> Findings are **not reworded** — every task keeps its originating `E*` / `ADM-SMP-*` /
> `ADM-INS-*` / `SDC-*` id in the **Src** column. Full context for any id: the matching
> `s*-*-v1.md` work order, then [`../review/comprehensive-review.md`](../review/comprehensive-review.md).
>
> **HEAD** `88802985` (`8880298`) — line numbers in the work orders are artefacts of that
> commit; use ids and symbol names to re-find.

## Legend & conventions

- `[ ]` not started · `[-]` in-progress · `[~]` blocked / needs a decision · `[x]` done
- **Task id:** `TR-S<stream>-<nn>` — stable, never renumbered. Sub-tasks use `a/b/c`.
  Ids match v1 exactly; nothing was renumbered on the carve.
- **Files:** exact repo paths. `[NEW]` = file to create. "shared design widgets" live under
  **`lib/core/design/widgets/…`** (`kh_data_table.dart`, `kh_status_chip.dart`,
  `kh_metric_card.dart`, `kh_screen_header.dart`). The admin scaffold is
  `lib/core/shell/kh_admin_scaffold.dart`.
- **Deps:** other `TR-*` ids, and/or a wave/handoff gate. Deps that are already `[x]` in v1
  are shown struck where useful; a bare v1 id in Deps that is not repeated here is **done**.
- **Done when:** a single checkable condition.
- Every path is `apps/kh_admin/`-relative unless it starts with `docs/`, `.github/`, or `packages/`.

## Status at carve (2026-09-09)

| Stream | State | Open tasks |
|---|---|---|
| **S0** Foundation | ✅ complete | — |
| **S1** List-data spine | 1 open (deferred) | TR-S1-03 |
| **S2** Detail screens | ✅ complete | — |
| **S3** Shared widgets & perf | ✅ complete | — |
| **S4** App-shell / bootstrap | ✅ complete | — |
| **S5** i18n & accessibility | not started | TR-S5-01 … TR-S5-25 (all) |
| **S6** Feature completion | ✅ complete | — |
| **S7** Testing | 11 open | TR-S7-01..05, -10..15 |
| **S8** Documentation carve | 11 open | TR-S8-03 … TR-S8-13 |

---

## S1 · List-data spine — remaining

**Verification:** `flutter analyze && flutter test`; then manually page + filter + deep-link
every list screen at a narrow and a wide viewport.

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S1-03** Melos: include `kh_admin` | `ADM-SMP-65` | root `pubspec.yaml`, `melos.yaml` | Add `apps/kh_admin` to the workspace package list / Melos globs. Deferred by **TR-S1-02** to a follow-up slice after the S1 data-spine work; pick up now that S1 has landed. | TR-S1-02 (done, decision = "follow-up slice") | `melos list` includes `kh_admin`. |

---

## S5 · i18n & accessibility sweep — all remaining

**Goal:** every user-visible string via ARB; every interactive element reachable and labelled.
**Depends on:** S1, S2, S4 (merges last, to avoid rebasing string churn).
**Do not** change layout structure (S2) or controller logic (S1).
**Verification:** `flutter analyze && flutter test`; run the AR locale + a screen-reader pass;
S7 goldens at 100% and 200% text scale, LTR + RTL.

### ARB migration (`E14` / `ADM-INS-02`)

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S5-01** migrate the shell | E14 | `lib/core/shell/kh_admin_scaffold.dart`, `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb` | Move nav titles + `'Dashboard'`/`'Gold Rates'`/`'Soon'`/`'Sign Out'` to ARB; `AppLocalizations.of(context)!`. | S4 shell settled (done) | no English literal in the scaffold. |
| `[ ]` **TR-S5-02..09** migrate the 8 un-migrated features | E14 | one row each: `customers`, `connections`, `abuse`, `audit`, `admin_users`, `announcements`, `moderation`, `settings` — `lib/features/<f>/presentation/**` + both ARB files | Per feature: add `AppLocalizations` import; move every visible string (incl. dialog copy) to ARB EN + AR. | S1 for that feature (done), S2 if it was split (done) | that feature has no English literal; AR keys added. |
| `[ ]` **TR-S5-10** migrate login's stragglers | E14 | `lib/features/auth/presentation/**` | Replace hardcoded `'Administrative Portal'` / `'Sign in with Google'` with ARB keys. | S4 (done) | login shows only ARB-sourced strings. |
| `[ ]` **TR-S5-11** `l10n?.key ?? '…'` → required | E14 | every file using the nullable-fallback idiom (`grep -rn "l10n?\." lib/`) | Switch to `AppLocalizations.of(context)!`; delete the English fallback literals. | TR-S5-01..10 | grep `l10n?\.` in `lib/` → 0. |
| `[ ]` **TR-S5-12** AR key-set parity check | E14 | `lib/l10n/app_ar.arb` | Every EN key has an AR entry. | TR-S5-01..11 | key sets are equal (diff is empty). |
| `[ ]` **TR-S5-13** enable the hardcoded-string lint | E14 | `analysis_options.yaml` | Turn on the lint staged in `TR-S0-09` (done). | TR-S5-11, TR-S0-09 (done) | lint on; `flutter analyze` clean for it. |

### Accessibility (`E24`)

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S5-14** `Semantics` on icon-only buttons | E24, `ADM-INS-36` | every icon-only `IconButton` (`grep -rn "IconButton(" lib/`) | Wrap in `Semantics(button: true, label: …)` with an ARB label. | TR-S5-01..12 | a screen reader announces every icon action. |
| `[ ]` **TR-S5-15** `SelectionArea` at the scaffold body | E24, `ADM-INS-63` | `lib/core/shell/kh_admin_scaffold.dart` | Wrap the body in `SelectionArea` for canvas copy-paste. | S4 shell (done) | body text is selectable. |
| `[ ]` **TR-S5-16** raise hit targets to 48px | E24, `ADM-INS-12` | `lib/core/design/theme/kh_spacing.dart`, sidebar row (38), offer Inspect (`Size(60,30)`), table `IconButton`s (18px icon) | Pad interactive targets to ≥48px (visual density can stay). | — | every tap target measures ≥48px. |
| `[ ]` **TR-S5-17** list find field bound to `q` | E24 | each list screen header / `lib/core/design/widgets/` | Add a find field wired to the existing `q` filter. | S1 per feature (done) | typing in find filters the list. |
| `[ ]` **TR-S5-18** portal `Shortcuts` map | E24 | `lib/core/shell/kh_admin_scaffold.dart` | `Shortcuts`/`Actions`: Esc closes a dialog, `/` focuses find. | TR-S5-17 | `/` focuses find; Esc closes an open dialog. |

### Directional + de-litteralise

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S5-19** `AlignmentDirectional` / `EdgeInsetsDirectional` | `ADM-INS-03` | `lib/core/shell/kh_admin_scaffold.dart` + the 2 detail screens with physical `Alignment.centerLeft/Right` | Replace physical alignment/insets with directional. | S2 for those screens (done) | AR (RTL) build mirrors; no physical `Alignment.center{Left,Right}` in `lib/`. |
| `[ ]` **TR-S5-20** de-litteralise colours | `ADM-INS-18` | vendor / customer / request detail, login, verification dialogs (`Colors.white` / `Colors.black`) | Use `context.kh.colors.onPrimary` etc. | S2 for those screens (done) | no raw `Colors.` in `lib/` outside token defs. |
| `[ ]` **TR-S5-21** de-litteralise text styles | `ADM-INS-18` | offer list + connection detail (`TextStyle(fontSize: 12.0)`) | Use `kh.typography`. | S2 for those screens (done) | no bare `TextStyle(` in `lib/` outside token defs. |
| `[ ]` **TR-S5-22** lint: ban raw `Colors.*` + raw `TextStyle` | `ADM-INS-18` | `analysis_options.yaml` | Add the custom lints. | TR-S5-20, -21 | lints on; analyze clean. |

### Time display (`E16` consumers)

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S5-23** consume `serverTime` + `Clock` | E16, `ADM-INS-07` | verification wait-hours, vendor licence-expiry, audit range — the `DateTime.now()` fallback/age sites (`grep -rn "DateTime.now()" lib/`) | Replace `DateTime.now()` with `TR-S0-21`/`TR-S0-22` providers (both done). | TR-S0-21, TR-S0-22 (done) | grep `DateTime.now()` in `lib/` → 0 (for ages/fallbacks). |
| `[ ]` **TR-S5-24** format instants in GST | E16, `BR-021` | date/time formatting call sites, `lib/core/format/kh_formats.dart` | Display via `Asia/Dubai` (Gulf Standard Time); store UTC. | TR-S5-23 | timestamps render in GST. |
| `[ ]` **TR-S5-25** enable the no-`DateTime.now()` lint | E16 | `analysis_options.yaml` | Turn on the lint staged in `TR-S0-09` (done). | TR-S5-23, TR-S0-09 (done) | lint on; analyze clean. |

---

## S7 · Testing — remaining

**Keep the style:** hand fakes + `ProviderScope` overrides, **no mocktail/mockito**.
**Verification:** `flutter test` + `flutter test integration_test` green; CI shows the size
number; `flutter analyze` warning count for `apps/kh_admin` is 0.
Done: TR-S7-06 (taxonomy repo test), TR-S7-07 (verification_query_params test), TR-S7-08 (exclusive-state transition test), TR-S7-09 (2 warnings).

### Cheap first — no restructure dependency

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S7-01** request-list screen test | E18, `ADM-INS-39` | `[NEW] test/features/requests/request_list_screen_test.dart` | empty / error / loading states. **Do this first.** | — | 3 states asserted; passes. |
| `[ ]` **TR-S7-02** `request_detail_controller` test | E18 | `[NEW] test/features/requests/request_detail_controller_test.dart` | Cover load / error / actions. | — | passes. |
| `[ ]` **TR-S7-03** `offer_detail_controller` test | E18 | `[NEW] test/features/offers/offer_detail_controller_test.dart` | Same. | — | passes. |
| `[ ]` **TR-S7-04** `vendor_detail_controller` test | E18 | `[NEW] test/features/vendors/vendor_detail_controller_test.dart` | Same. | — | passes. |
| `[ ]` **TR-S7-05** `audit` + `dashboard` + `reports` controller tests | E18 | `[NEW] test/features/{audit,dashboard,reports}/*_controller_test.dart` | Controllers untested (repos are). | — | 3 files; pass. |

### Goldens + integration + CI

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S7-10** goldens for the 4 existing shared widgets | E25, `ADM-INS-01` | `[NEW] test/core/design/widgets/*_golden_test.dart` for `KhStatusChip`, `KhDataTable`, `KhMetricCard`, `KhScreenHeader` | LTR + RTL + 200% text scale. `KhDataTable` golden already landed in `TR-S3-02` at `test/core/design/widgets/kh_data_table_golden_test.dart` — cover the other 3. | TR-S3-01 (done) | goldens pass at all 3 configs. |
| `[ ]` **TR-S7-11** goldens for the 3 new detail primitives | E25 | `[NEW] test/core/design/widgets/kh_detail_*_golden_test.dart` | `KhDetailCard`, `KhDetailRow`, `KhFeedbackBanner`. | TR-S2-01, -02, -04 (all done) | goldens pass. |
| `[ ]` **TR-S7-12** screen goldens for restructured screens | E25 | `[NEW] test/features/{requests,offers}/*_detail_golden_test.dart` + list-screen goldens | Write / re-baseline **after** S2 splits and S3 virtualises. | `TR-S2-06` (done), `TR-S2-07` (done), `TR-S3-03*` (done) | goldens match the settled trees. |
| `[ ]` **TR-S7-13** integration test | E28, `ADM-INS-80` | `[NEW] integration_test/admin_flow_test.dart` | login → dashboard → one list → detail, against a seeded Chrome. | S1 (done), S2 for those screens (done) | `flutter test integration_test` green. |
| `[ ]` **TR-S7-14** CI: compressed main-js size budget | E28, `ADM-INS-84` | `.github/workflows/frontend.yml` (`admin` job) | Measure compressed main-js after `flutter build web`; fail past a threshold. | — | CI prints the size number and fails on regression. |
| `[ ]` **TR-S7-15** CI: fail on `flutter analyze` warnings for `apps/kh_admin` | E28 | `.github/workflows/frontend.yml` | Scope an analyze-warning gate to `apps/kh_admin`. | — | a new warning fails the `admin` job. |

---

## S8 · Documentation carve — all remaining

**Goal:** carve per-surface doc sets so a session scoped to `apps/kh_admin` needs no
repo-wide `docs/`.
**Depends on:** — · **Parallelism:** fully independent, no code overlap.
**Owns:** `docs/**`, `.claude/skills/carve-surface-docs/`, `scripts/check-surface-docs.mjs`.
**Verification:** `node scripts/check-surface-docs.mjs` exits 0; no content lost (derived ⊇
source ID set); no broken inbound links; `flutter analyze && flutter test` + `backend` build
unaffected; skill re-run idempotent; spot-read passes.

| Task | Src | Files | Action | Deps | Done when |
|---|---|---|---|---|---|
| `[ ]` **TR-S8-03** carve `docs/core/` README + Glossary+Invariants | `SDC-01..06` | `[NEW] docs/core/00-README.md`, `[NEW] docs/core/01-Glossary-and-Invariants.md` | Self-contained extracts with a derived-from header (authority stays with `docs/`). | — | both files exist; header present. |
| `[ ]` **TR-S8-04** carve `docs/core/` API-Conventions + Cross-Cutting-Requirements | `SDC-01..06` | `[NEW] docs/core/02-API-Conventions.md`, `[NEW] docs/core/03-Cross-Cutting-Requirements.md` | Same pattern. | — | both files exist. |
| `[ ]` **TR-S8-05** carve `docs/core/` Entity-Dictionary + Design-Tokens + ADRs-index | `SDC-01..06` | `[NEW] docs/core/04-Entity-Dictionary.md`, `[NEW] docs/core/05-Design-Tokens.md`, `[NEW] docs/core/06-ADRs-index.md` | Same pattern; ~2,400 common lines carved once. | — | all three exist; everything links to `docs/core/`. |
| `[ ]` **TR-S8-06** admin pilot — 10 top-level docs | review §1.5.1 | `[NEW] apps/kh_admin/docs/00..09-*.md` | Hand-carve the 10 top-level admin docs (numbering `00`–`08` stable). | TR-S8-05 | 10 files exist with derived-from headers. |
| `[ ]` **TR-S8-07** admin pilot — 23 screen copies + READMEs | `SDC-02` | `[NEW] apps/kh_admin/docs/screens/ADM-S*.md` (23) + section READMEs | Copy each admin screen spec verbatim per screen. | TR-S8-06 | 23 screen files + READMEs present; content byte-identical to source screen specs. |
| `[ ]` **TR-S8-08** admin-set tensions carried, not resolved | review §2, §5.2 | `apps/kh_admin/docs/01-Admin-Requirements.md` | Carry into the derived docs, unresolved: 6 `[ASSUMED]` `FR-ADM` (`002/012/019/028/032/033`); `FR-ADM-002` flat-RBAC vs 3-role tension; ADM-S20 deferred; admin masking exemption (`Arch-Backend §9.5`); list `limit` max 100; 60 specified vs ~45 live routes + double-wrapped envelope + `Decimal`→string. | TR-S8-06 | each item appears in a derived doc, flagged as open/deferred. |
| `[ ]` **TR-S8-09** carve skill | `SDC-08` | `[NEW] .claude/skills/carve-surface-docs/SKILL.md` | Author the skill from what the admin pilot proved. | TR-S8-02, TR-S8-07 | skill exists. |
| `[ ]` **TR-S8-10** surface manifest | phase 3 | `[NEW] docs/surface-map.md` | Manifest of surfaces → doc sets → source sections. | TR-S8-07 | manifest lists core + admin. |
| `[ ]` **TR-S8-11** check script | phase 3 | `[NEW] scripts/check-surface-docs.mjs` | ID coverage (34/31/33/12 FRs, 67 screens, all `BR`/`NFR`/`C`/`AD-*`), no invented IDs, links resolve, no stale sources. | TR-S8-10 | `node scripts/check-surface-docs.mjs` exits 0 on core + admin. |
| `[ ]` **TR-S8-12** mobile carve | phase 4 | `apps/kh_mobile/**/docs/` (58 files, customer + vendor, two mode subfolders) | Run `/carve-surface-docs customer` then `vendor`. | TR-S8-11 | script green on mobile; 58 files. |
| `[ ]` **TR-S8-13** backend carve | phase 5 | `backend/docs/**` (11 files, mostly `git mv` + redirect stubs) | Run `/carve-surface-docs backend`. | TR-S8-11, TR-S8-01 | script green on backend; inbound-link grep returns only stubs + derived files. |

---

## Sequencing for the remaining work

1. **S7 cheap tests** (`TR-S7-01..05`, `-10`, `-11`) — no restructure dependency, do
   anytime; `TR-S7-12`/`-13` unblocked now that S2 and S3 have landed.
2. **S5** — merges last (string churn). Shell (`TR-S5-01`) and per-feature ARB
   (`TR-S5-02..09`) first, then `TR-S5-11..13`, then a11y and de-litteralise, then time.
3. **S8** — fully independent (decisions `TR-S8-01`/`-02` recorded); carve `docs/core/` → admin
   pilot → skill → manifest → check script → mobile → backend.
4. **S1** `TR-S1-03` (Melos) — standalone follow-up slice, do when convenient.

### Per-feature pipeline (list features) — remaining stages only

`S5 ARB` → `S5 a11y (TR-S5-14)`.
Detail: `S5 ARB` → `S5 directional/colour (TR-S5-19..21)`.
Full id chains: see the appendix in [`task-register-v1.md`](task-register-v1.md#appendix--per-feature-pipelines).
