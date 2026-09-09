# Surface doc sets — review (index)

| | |
|---|---|
| **Product** | Karat Hive |
| **Scope** | All four surfaces — Admin (`apps/kh_admin`), Customer + Vendor (`apps/kh_mobile/karat_hive`), Backend (`backend/`) |
| **HEAD** | `88802985d39a4679724875d900275fa038d3bb89` (`main` = `origin/main`) |
| **Date** | 8 September 2026 |
| **Status** | Proposal under review. **Not the plan of record.** Nothing here has been executed. |
| **Decision prefix** | `SDC-nn` — surface-doc-carve decision. Stable, never reused. |
| **Does not override** | SRS v1.3 · `API-Route-Inventory.md` · `Architecture-Frontend.md` · `Architecture-Backend.md` · `Admin-App-Completion-Plan.md` |
| **Does not mint** | `FR-*`, `AD-FE-*`, `AD-API-*`, `ADM-S*`, `ADM-C-*`, `SAM-GAP-*` — those are cited, not replaced |

## Question this answers

`docs/` is one flat folder serving four surfaces. Working on any one of them means loading
`Requirements-Spec-v1.3.md` (2,846 lines), `API-Route-Inventory.md` (2,137),
`Architecture-Frontend.md` (871) and `Architecture-Backend.md` (1,116) and filtering ~70 %
of each away by hand. This proposal carves per-surface doc sets so a developer — or an agent
session scoped to one folder — has what that surface needs without opening repo-wide `docs/`.

## Files

| File | Content |
|---|---|
| [`comprehensive-review.md`](comprehensive-review.md) | **Synthesis of this whole folder** — every `SDC-*` decision, the admin content filter, the Flutter/Dart checklist (`E1`–`E30`), and the `ADM-SMP-*` register, including Tier-0 applied work. Start here. |
| [`comprehensive-review-carve-v1.md`](comprehensive-review-carve-v1.md) | Part 1 of the synthesis, split by category: §0 how the reviews relate, §1 surface-doc carve (`SDC-*`), §2 admin content filter |
| [`comprehensive-review-flutter-dart-v1.md`](comprehensive-review-flutter-dart-v1.md) | Part 2: §3 Flutter/Dart engineering review — scorecard, per-checklist findings, `E1`–`E30` |
| [`comprehensive-review-simplification-v1.md`](comprehensive-review-simplification-v1.md) | Part 3: §4 simplification review — `ADM-SMP-01`–`65` register, four axes, Tier-0 applied work |
| [`comprehensive-review-synthesis-v1.md`](comprehensive-review-synthesis-v1.md) | Part 4: §5 unified picture (the three-way agreement), §6 identifier index |
| [`implementation-workstreams-v1.md`](implementation-workstreams-v1.md) | **By-workstream cut** of the same findings for parallel execution — 9 streams (S0–S8), conflict hot-spots, file ownership, sequencing, identifier→stream index |
| [`workstreams/`](workstreams/README.md) | Per-stream work orders (`s0`–`s8`): files touched, action, dependencies, done-when |
| [`carve-plan.md`](carve-plan.md) | The proposal — method, layout, execution order, verification |
| [`admin-content-filter.md`](admin-content-filter.md) | The admin analysis in full: every source section classified admin-only / common / excluded, with line ranges |
| [`simplification-review.md`](simplification-review.md) | Reuse / simplification / efficiency / altitude findings (`ADM-SMP-01`–`65`) |
| [`flutter-dart-code-review.md`](flutter-dart-code-review.md) | Move stub. Canonical copy: [`docs/Admin-Flutter-Dart-Code-Review.md`](../../../../docs/Admin-Flutter-Dart-Code-Review.md) |

`comprehensive-review.md` stays the single-file reading. Two lenses split the same findings:

- **By review** — `comprehensive-review-*-v1.md` (carve / flutter-dart / simplification / synthesis). Same wording, redistributed with only cross-reference fixes; §0–§6 numbering shared. For reviewing one review at a time.
- **By workstream** — `implementation-workstreams-v1.md` + `workstreams/`. The same `E*` / `ADM-SMP-*` items regrouped by merge-conflict surface and dependency order, so multiple agents can implement in parallel.

The admin filter is complete and verified. The other three surfaces are scoped but not yet
inventoried at the same depth.

## Decisions taken so far

| ID | Decision | Status |
|---|---|---|
| `SDC-01` | Derived sets are **self-contained extracts** with a derived-from header; authority stays with `docs/` | Agreed |
| `SDC-02` | Screen specs are **copied verbatim** per screen, not merged into one file | Agreed |
| `SDC-03` | ~9–10 top-level files per surface, one concern each, stable `00`–`08` numbering across surfaces | Agreed |
| `SDC-04` | Customer + Vendor share **one mobile set** with two mode subfolders (one dual-mode binary, `C-08`/`C-10`) | Agreed |
| `SDC-05` | The ~2,400 lines of common material are carved **once** into `docs/core/`; surfaces link to it | Agreed |
| `SDC-06` | Tooling is **skill + manifest + check script**, not a skill alone | Agreed |
| `SDC-07` | Surface-only documents referenced by nothing else are **moved with a redirect stub**, not copied | Open — flagged in `carve-plan.md` |
| `SDC-08` | The skill is authored **after** the admin pilot, not before | Open — flagged in `carve-plan.md` |
