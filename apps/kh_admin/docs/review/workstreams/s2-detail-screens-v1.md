# S2 · Detail screens

> Work order derived from [`../comprehensive-review.md`](../comprehensive-review.md) §3.3.3 and §4.2–§4.3. Line numbers are HEAD `8880298` artefacts.

| | |
|---|---|
| **Goal** | Extract shared detail primitives, then break the god screens into rebuild-bounded widgets. |
| **Owner** | 1 agent for the primitives, then 1 agent per detail screen (fan out). |
| **Parallelism** | High after the primitives land. |
| **Depends on** | S0 (analyzer, error helper). |
| **Blocks** | S5 on each detail screen. |
| **Owns** | `lib/core/widgets/detail_*` (new), `lib/features/{request,offer,vendor,customer,connection}/presentation/`, `lib/features/{announcements,platform_settings,audit}/presentation/` (structure only) |
| **Do not** | change list controllers/repositories (S1); do ARB/Semantics work (S5) — leave strings as-is, S5 sweeps after |

## Step 1 — shared primitives (blocking within S2, 1 PR)

### `ADM-SMP-11` — label/value row invented 5×
`_buildDetailRow` (request), `_DetailRow` (offer), `_buildFieldRow` (vendor:260), `_buildInfoRow` (customer:330), inline (connection). Two are widget classes, three are methods.
→ one `KhDetailRow` widget in `lib/core/widgets/`.

### `ADM-SMP-12` — no shared detail-card scaffold
The same `Container` + `BoxDecoration` literal appears **8×** in `request_detail_screen.dart` alone.
→ one `KhDetailCard` scaffold.

### `ADM-SMP-08` — feedback banner written 3× (needs design sign-off)
`customer_detail:222`, `request_detail:248`, `vendor_detail:178` — divergent padding, alpha (0.10 vs 0.12), border alpha, icon style (outline vs filled), text weight, dismissibility. Each carries a test-facing `Key`. Merging **picks a visual winner** on ≥2 screens.
→ `KhFeedbackBanner`; get the visual decision confirmed before merging; preserve the `Key`s.

### `ADM-SMP-09` — `_buildStatTile` beside a real `KhMetricCard`
`announcements_screen.dart:312` hand-rolls a metric tile.
→ replace with `KhMetricCard`.

**Done when:** the four primitives exist, unit-tested, with goldens requested from S7.

## Step 2 — split the god screens (`E12`, `ADM-SMP-26`, `-27`) — one agent each

19 presentation files exceed 400 lines (19,132 total, ~36% of `lib/`). They mix layout, dialogs, mutations, copy and formatting in one `State` class (`ADM-INS-22`); private `_build*` helpers stay in-file so they get no `const` and no independent rebuild boundary.

| Order | File | Lines | Notes |
|---|---|---|---|
| 1 | `request_detail_screen.dart` | 1,484 | worst; 8× the card literal |
| 2 | `offer_detail_screen.dart` | 1,388 | |
| 3 | `announcements_screen.dart` | 1,210 | **extract `_ComposeAnnouncementDialog` (~440 L, `:774-1210`) to its own file** — it is a whole second feature |
| 4 | `vendor_detail_screen.dart` | 1,075 | |
| 5 | `platform_settings_screen.dart` | 1,059 | |
| 6 | `customer_detail_screen.dart` | 1,022 | |
| 7 | `audit_screen.dart` | 882 | |
| 8 | `connection_detail_screen.dart` | 819 | |

**Do per file:** split into `header` / `summary` / `timeline` / `actions` / `dialogs` widgets (real `StatelessWidget`/`ConsumerWidget`, `const` where possible), each in its own file under the feature's `presentation/`. Use the Step-1 primitives. No behaviour change, no string change.
**Done when:** each screen file is a composition root; no `_build*` method returns a subtree larger than a screenful.

## `E17` / `ADM-INS-11` — presentation must not call repositories
`verification_detail_pane.dart` calls `ref.read(verificationRepositoryProvider).fetchDocumentUrl` directly.
→ move the call into `VerificationController`; the pane reads controller state.
**Done when:** no `ref.read(*RepositoryProvider)` in any `presentation/` file.

## Verification
`flutter analyze && flutter test`; every detail screen renders unchanged (pixel diff via S7 goldens once they exist); narrow + wide viewport spot-check.
