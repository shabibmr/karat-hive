# Admin Portal — implementation workstreams (v1)

| | |
|---|---|
| **Product** | Karat Hive |
| **Surface** | Flutter Web Admin Portal (`apps/kh_admin`) |
| **HEAD** | `88802985d39a4679724875d900275fa038d3bb89` (`main` = `origin/main`) — abbreviated `8880298` |
| **Date** | 9 September 2026 |
| **Status** | Planning aid. **Not the plan of record** — `Admin-App-Completion-Plan.md` still owns product scope. |
| **Source** | Re-cut of [`comprehensive-review.md`](comprehensive-review.md) §3–§5 for parallel execution. No finding reworded; every `E*` / `ADM-SMP-*` maps to exactly one stream (index at the end). |
| **Companion split** | [`comprehensive-review-*-v1.md`](comprehensive-review-carve-v1.md) — the *by-review* lens (read one review at a time). This file is the *by-workstream* lens (build in parallel). Same content, different cut. |

Per-stream work orders: [`workstreams/`](workstreams/).

---

## 1. Why this cut

The by-review split groups findings by the review that produced them. That is right for reading and wrong for parallel coding:

- `request_detail_screen.dart` collects edits from all three reviews at once.
- The single largest item — `kh_admin` rejoining the shared `packages/` graph — sits *underneath* the list kernel, the envelope work, and the masking types.
- Two agents told "do the Flutter/Dart review" and "do the simplification review" would both rewrite the list controllers.

This cut groups the same findings by **merge-conflict surface + dependency order**. The rule that keeps it parallel:

> Only **S1** touches list controllers / repositories. Only **S3** touches `KhDataTable`. Only **S4** touches `main.dart` / `app_router.dart` / `pubspec.yaml`. Everything else is feature-folder-local or test-only.

## 2. Conflict hot-spots — these draw the boundaries

| File / area | Why contended | Owner | Handoff rule |
|---|---|---|---|
| `analysis_options.yaml` | Turning on lints creates work in every file | **S0** | Lands in wave 0 before any other stream branches |
| `lib/` import style (relative → `package:`) | Whole-tree mechanical diff | **S0** | Same PR as the analyzer change |
| `main.dart` | Error hooks, Firebase init, session, FCM, flavours | **S0** then **S4** | S0 merges its hook insertion first; S4 owns the rest |
| `pubspec.yaml` (app) | `path:` deps (S1) vs Firebase removal (S4) | **S1** then **S4** | S1 merges the package-graph change first |
| `lib/core/api/api_client.dart` | `serverTime` (S0) vs envelope normalise (S1) | **S0** then **S1** | S0's `serverTime` capture lands first |
| every `lib/features/*/controller` + `repository` + `model` | List kernel rewrites all of them | **S1** | No other stream edits these while S1 runs |
| `lib/core/widgets/kh_data_table.dart` | Virtualisation | **S3** | Blocked on `AD-FE-12`; sequence per-list after S1 |
| list `*_screen.dart` scroll wrappers | S1 (kernel) → S3 (scroll) → S5 (strings/a11y) | pipeline | One feature at a time through the pipeline |
| `*_detail_screen.dart` | S2 (split) → S5 (strings/a11y) | pipeline | S2 lands the new widget tree before S5 sweeps it |
| `app_*.arb` | String migration | **S5** | Merges late, after S1–S4 settle |
| `test/` | Additive only | **S7** | Never conflicts; screen tests for restructured screens land after S2/S3 |

## 3. The streams

| Stream | Scope | Items | Parallelism | Depends on | Blocks |
|---|---|---|---|---|---|
| **S0 · Foundation** | analyzer, imports, error hooks, logger, error-map helper, `serverTime`/clock infra | E10, E11, E5, E6, E3‑helper, E16‑infra, `ADM‑SMP‑33` | 1 owner, ~2 PRs, internally ordered | — | everything |
| **S1 · List-data spine** | package graph, envelope, list kernel, filter models, query codec, server-side filters | E9, E15, E19, E20, E30 · `ADM‑SMP‑01/65/04/05/10/62/07/63/64/20/21/22/23/24/25/29/61` | 1 owner, sequential; ~50% of total effort | S0 | S3 per-list, S6 (abuse/dashboard) |
| **S2 · Detail screens** | shared detail primitives, then god-screen splits | E12, E17 · `ADM‑SMP‑08/09/11/12/26/27` | primitives first, then 1 agent per screen | S0 | S5 on detail screens |
| **S3 · Shared widgets & perf** | `KhDataTable` virtualisation, `.select()`, image bounds | E13, E29 · `ADM‑SMP‑40/41/42` | 1 owner; pause before list screens | S0; then S1 per-list | — |
| **S4 · App-shell / bootstrap / platform** | web token policy, idle timeout, password gating, Firebase, deferred imports, flavours, FCM, typed routes | E1, E2, E7, E8, E23, E26, E27 · `ADM‑SMP‑30/31/45/46` · `ADM‑INS‑04` | 1 owner | S0 | — |
| **S5 · i18n & a11y sweep** | ARB migration, Semantics, targets, `SelectionArea`, directional insets, de-litteralise colours/styles | E14, E24 · `ADM‑INS‑03/18` | per-screen, additive; **merge last** | S1, S2 | — |
| **S6 · Feature completion** | dashboard resilience + trends, abuse actions | E4, E21, E22 | parallel, isolated feature folders | S0; S1 for abuse/dashboard state | — |
| **S7 · Testing** | request-list test, missing controllers, goldens, integration_test, CI budget | E18, E25, E28 | fully parallel, start immediately | — | — |
| **S8 · Docs carve** | `docs/core/` → admin pilot → tooling → mobile → backend | `SDC‑01…08` (phases in review §1.6) | fully independent track, no code | confirm `SDC‑07`/`SDC‑08` | — |

## 4. File / directory ownership

| Path | Stream | Note |
|---|---|---|
| `analysis_options.yaml` | S0 | |
| `lib/**` import statements | S0 | mechanical pass, wave 0 |
| `lib/core/error/`, `lib/core/log/` (new) | S0 | |
| `lib/core/api/api_client.dart` | S0 → S1 | `serverTime` then envelope |
| `lib/core/api/json_parse.dart` | S1 | |
| `lib/core/list/` (new — kernel) | S1 | |
| `lib/core/router/*_query_params.dart`, `query_navigation.dart` | S1 | |
| root `pubspec.yaml` / `melos.yaml` | S1 | package-graph rejoin |
| `apps/kh_admin/pubspec.yaml` | S1 → S4 | path deps then Firebase removal |
| `lib/features/*/controller/`, `*/repository/`, `*/model/` | S1 | S6 for `dashboard`/`abuse` behaviour after migration |
| `lib/core/widgets/kh_data_table.dart` | S3 | |
| `lib/core/widgets/detail_*` (new) | S2 | |
| `lib/features/*/presentation/*_detail_screen.dart` | S2 → S5 | |
| `lib/features/*/presentation/*_list_screen.dart` | S1 → S3 → S5 | pipeline per feature |
| `lib/features/{dashboard,reports,abuse}/` | S6 | after S1 |
| `main.dart` | S0 → S4 | |
| `app_router.dart` | S4 | |
| `lib/core/auth/` | S4 | |
| `web/` | S4 | |
| `lib/l10n/`, `app_*.arb` | S5 | |
| `lib/core/widgets/kh_admin_scaffold.dart` | S5 | nav titles → ARB; Semantics |
| `test/**`, `.github/workflows/frontend.yml` | S7 | |
| `docs/**` | S8 | |

## 5. Sequencing (waves)

**Wave 0 — unblock.**
- S0 lands (2 PRs: `analyzer + package imports`, then `error hooks + logger + error-map helper + serverTime/clock`).
- S7 and S8 start now and run continuously.

**Wave 1 — fan out.**
- S1 starts (long-running, one owner). Sub-order: package graph → envelope → list kernel → filter models → query codec → server-side filters → audit call.
- S2 lands the shared primitives (`KhDetailCard`, `KhDetailRow`, `KhFeedbackBanner`, use `KhMetricCard`), then one agent per detail screen (`request` → `offer` → `announcements` → `vendor` → `settings` → `customer` → `audit` → `connection`).
- S4 runs in full.
- S3 builds the virtualised `KhDataTable` behind a flag but does **not** rewire list screens yet.
- S6 runs for `dashboard` (already `AsyncNotifier`); abuse waits for S1.

**Wave 2 — converge.**
- As S1 migrates each list feature, S3 swaps that screen to the virtualised table + `.select()`.
- S5 sweeps: ARB, Semantics, targets, directional insets, colour/style de-litteralisation — across all screens, merging last.
- S6 finishes abuse actions.
- S7 adds goldens + integration_test against the settled widget trees.

## 6. Cross-stream handoffs (explicit)

1. **S0 → all:** analyzer + `package:` imports merged before any stream branches.
2. **S0 → S4:** `main.dart` error-hook insertion merged before S4 touches `main.dart`.
3. **S0 → S1:** `ApiClient.meta.serverTime` + `Clock` provider merged before S1 reworks `api_client.dart`.
4. **S1 → S4:** app `pubspec.yaml` `path:` deps merged before S4 removes Firebase packages.
5. **S1 → S3 (per feature):** S3 rewires a list screen only after that feature's controller is on the kernel.
6. **S1 → S6:** abuse actions (E22) start after `features/abuse` is on the kernel (Family B → kernel migration is part of S1).
7. **S2 → S5 (per screen):** S5 sweeps a detail screen only after S2 has split it.
8. **S1/S4 → S5:** ARB sweep starts after list features and shell bootstrap are stable, to avoid rebasing string churn.
9. **S2/S3 → S7:** screen goldens / integration tests for restructured screens land after the restructure.

## 7. Per-feature pipelines

**List features** (`vendors`, `requests`, `offers`, `customers`, `connections`, `audit`, `abuse`, `moderation`, `announcements`, `admin_users`):
`S1 kernel + query state` → `S3 virtualised table + .select()` → `S5 ARB + Semantics`

**Detail features** (`request`, `offer`, `vendor`, `customer`, `connection` details; `announcements`, `platform_settings`, `audit` screens):
`S2 split into header/summary/timeline/actions/dialogs` → `S5 ARB + Semantics`

## 8. Blocked / out of scope (do not resolve inside a stream)

| Item | Effect |
|---|---|
| `AD-FE-12` — admin data grid build-or-buy (open) | Blocks S3 `KhDataTable` virtualisation from being *final*; build the lazy viewport, do not pick a vendor grid |
| Riverpod 3 upgrade | Not in the same slice as S1's list-state work (`E9` note) |
| ADM-S20 gold rates | Deferred pending Yahoo Finance terms — S4 hides the nav, does not implement |
| `FR-ADM-002` three-role RBAC | Deferred to flat `role = ADMIN` — do not add a Role selector |
| `SDC-07` (move vs copy) · `SDC-08` (skill after pilot) | Confirm before S8 phase 3 |
| Dependency major-version bumps (`flutter_riverpod` 3, `go_router` 18, …) | Separate dedicated PR after S1 |

## 9. Identifier → stream index

| ID | Stream | ID | Stream |
|---|---|---|---|
| E1 | S4 | `ADM-SMP-01` | S1 |
| E2 | S4 | `ADM-SMP-04` | S1 |
| E3 | S0 (helper) + S1/S2/S6 (call sites) | `ADM-SMP-05` | S1 |
| E4 | S6 | `ADM-SMP-07` | S1 |
| E5 | S0 | `ADM-SMP-08` | S2 |
| E6 | S0 | `ADM-SMP-09` | S2 |
| E7 | S4 | `ADM-SMP-10` | S1 |
| E8 | S4 | `ADM-SMP-11` | S2 |
| E9 | S1 | `ADM-SMP-12` | S2 |
| E10 | S0 | `ADM-SMP-20` | S1 |
| E11 | S0 | `ADM-SMP-21` | S1 |
| E12 | S2 | `ADM-SMP-22` | S1 |
| E13 | S3 | `ADM-SMP-23` | S1 |
| E14 | S5 | `ADM-SMP-24` | S1 |
| E15 | S1 | `ADM-SMP-25` | S1 |
| E16 | S0 (infra) + S5 (consumers) | `ADM-SMP-26` | S2 |
| E17 | S2 | `ADM-SMP-27` | S2 |
| E18 | S7 | `ADM-SMP-29` | S1 |
| E19 | S1 | `ADM-SMP-30` | S4 (pkg) — service delete done in Tier-0 |
| E20 | S1 | `ADM-SMP-31` | S4 |
| E21 | S6 | `ADM-SMP-33` | S0 |
| E22 | S6 | `ADM-SMP-40` | S3 |
| E23 | S4 | `ADM-SMP-41` | S3 |
| E24 | S5 | `ADM-SMP-42` | S3 |
| E25 | S7 | `ADM-SMP-45` | S4 |
| E26 | S4 | `ADM-SMP-46` | S4 |
| E27 | S4 | `ADM-SMP-61` | S1 |
| E28 | S7 | `ADM-SMP-62` | S1 |
| E29 | S3 | `ADM-SMP-63` | S1 |
| E30 | S1 | `ADM-SMP-64` | S1 |
| | | `ADM-SMP-65` | S1 |

`ADM-SMP-02/03/06/13/28/32/43/44/60` are already **FIXED** in the working tree (Tier-0) — see [`comprehensive-review.md`](comprehensive-review.md) §4.7. `ADM-SMP-02/03` are shared but `ADM-SMP-07` is still PART (5 files not fully migrated) → S1 finishes it.
