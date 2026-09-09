# Admin Portal review — Part 1: Surface documentation carve

| | |
|---|---|
| **Product** | Karat Hive |
| **Surface** | Flutter Web Admin Portal (`apps/kh_admin`) plus the four-surface documentation carve that feeds it |
| **HEAD** | `88802985d39a4679724875d900275fa038d3bb89` (`main` = `origin/main`) — abbreviated `8880298` in source notes |
| **Dates** | Carve analysis 8 September 2026 · Flutter/Dart and simplification 9 September 2026 |
| **Status** | Part 1 of 4, split by category from [`comprehensive-review.md`](comprehensive-review.md) at HEAD `8880298`. **Not the plan of record.** Nothing in the carve proposal has been executed. |
| **Does not override** | SRS v1.3 · `API-Route-Inventory.md` · `Architecture-Frontend.md` · `Architecture-Backend.md` · `Admin-App-Completion-Plan.md` |
| **Does not mint** | `FR-*`, `AD-FE-*`, `AD-API-*`, `ADM-S*`, `ADM-C-*`, `SAM-GAP-*`, `ADM-INS-*` — those are cited, not replaced |
| **Decision prefix in this part** | `SDC-nn` (carve). Stable, never reused. |

This is **part 1 of 4** split from [`comprehensive-review.md`](comprehensive-review.md); the combined document remains the single-file reading and is unchanged. Sibling parts: [flutter-dart](comprehensive-review-flutter-dart-v1.md) · [simplification](comprehensive-review-simplification-v1.md) · [synthesis](comprehensive-review-synthesis-v1.md). Section numbers (§0, §1, §2) are inherited from the parent so internal cross-references still resolve.

This part is the reading of the surface-doc carve and the admin content filter under [`apps/kh_admin/docs/review/`](README.md). It does not replace the source files; it restates every decision, classification and caveat so they can be reviewed in one place.

| Source file | What it contributed |
|---|---|
| [`README.md`](README.md) | Carve-set index, `SDC-01`–`SDC-08`, the question the carve answers |
| [`carve-plan.md`](carve-plan.md) | Method, `docs/core/` layout, four surface layouts, execution order, verification |
| [`admin-content-filter.md`](admin-content-filter.md) | Every source section classified ADMIN-ONLY / COMMON / EXCLUDED, with line ranges at this HEAD |

Companion, **not** part of this folder: [`docs/inspection/`](../inspection/README.md) (`ADM-INS-01`–`87`). Where a fact appears in both an inspection ID and a review finding, the inspection ID remains authoritative for standards and spec conformance. This document repeats the *quantity* and the *named replacement*, not a second verdict.

---

## 0. How the three reviews relate

Three different questions were asked of the same surface.

| Review | Question | Outcome at this HEAD |
|---|---|---|
| **Surface-doc carve** (`SDC-*`) | Can a developer or agent scoped to `apps/kh_admin` work without opening the 2,800-line SRS and the other repo-wide specs? | Proposal. Nothing executed. Admin filter is complete; other surfaces are scoped but not inventoried at the same depth. |
| **Flutter/Dart checklist** (`E1`–`E30`) | Does the portal meet the library-agnostic Flutter/Dart bar and Architecture-Frontend? | Snapshot. Architecture *shape* is right; consistency and depth are not. 7 of 15 checklist areas **Fail**. |
| **Simplification** (`ADM-SMP-*`) | What does the code make harder than it needs to be? | Snapshot + **9 FIXED**, **1 PART** applied in this working tree. 40 findings. Does not hunt correctness bugs. |

They overlap on the same facts (list-controller duplication, Melos exclusion, table virtualisation, unused Firebase, URL state). They do **not** renumber each other. The unification is in §5 (Unified picture), now [`comprehensive-review-synthesis-v1.md`](comprehensive-review-synthesis-v1.md).

**Line numbers** in the carve filter and simplification evidence columns are artefacts of HEAD `8880298` and will not survive an SRS version bump or further edits. Use identifiers (`FR-ADM-003`, `ADM-SMP-20`, `E9`) to re-find work. Files listed as `FIXED` in the simplification pass have since shifted.

---

## 1. Surface documentation carve

### 1.1 The question

`docs/` is one flat folder serving four surfaces. Working on any one of them means loading `Requirements-Spec-v1.3.md` (2,846 lines), `API-Route-Inventory.md` (2,137), `Architecture-Frontend.md` (871) and `Architecture-Backend.md` (1,116) and filtering ~70 % of each away by hand.

The proposal carves per-surface doc sets so a developer — or an agent session scoped to one folder — has what that surface needs without opening repo-wide `docs/`.

Authority stays with the originals. Everything carved is **derived** and says so.

Two structural facts shape the layout, both verified against the tree:

- **Customer and Vendor are not separate apps.** One dual-mode binary at `apps/kh_mobile/karat_hive/` (`C-08`, `C-10`), backed by six shared packages in `packages/`. They get one mobile doc set with two mode subfolders.
- **Backend is different in kind.** `Architecture-Backend.md`, `Async-Contract.md`, `Physical-Data-Model.md`, `Backend-Implementation-Plan.md`, `Backend-Gap-Fix-Plan.md`, `Backend-Gap-Tasks.md`, `backend_code_review_and_gap_report.md` and `Template-Lock-Review-Plan.md` — 4,192 lines — are *already* backend-only. That set is largely a re-home and an index, not an extraction.

### 1.2 Decisions (`SDC-nn`)

Stable, never reused.

| ID | Decision | Status |
|---|---|---|
| `SDC-01` | Derived sets are **self-contained extracts** with a derived-from header; authority stays with `docs/` | Agreed |
| `SDC-02` | Screen specs are **copied verbatim** per screen, not merged into one file | Agreed |
| `SDC-03` | ~9–10 top-level files per surface, one concern each, stable `00`–`08` numbering across surfaces | Agreed |
| `SDC-04` | Customer + Vendor share **one mobile set** with two mode subfolders (one dual-mode binary, `C-08`/`C-10`) | Agreed |
| `SDC-05` | The ~2,400 lines of common material are carved **once** into `docs/core/`; surfaces link to it | Agreed |
| `SDC-06` | Tooling is **skill + manifest + check script**, not a skill alone | Agreed |
| `SDC-07` | Surface-only documents referenced by nothing else are **moved with a redirect stub**, not copied | Open — flagged in the carve plan |
| `SDC-08` | The skill is authored **after** the admin pilot, not before | Open — flagged in the carve plan |

### 1.3 Method — three pieces (`SDC-06`)

A skill alone does this badly. The expensive part is not the first carve. It is re-syncing four derived sets when `Requirements-Spec-v1.3` is superseded by v1.4 and every line number shifts. A skill carries no state between runs, so it cannot know what went stale.

| Piece | Path | Holds | Why separate |
|---|---|---|---|
| **Skill** | `.claude/skills/carve-surface-docs/SKILL.md` | The *judgment* — classification rules, file taxonomy, derived-from header, house rules | Stateless between runs |
| **Manifest** | `docs/surface-map.md` | The *state* — which source section belongs to which surface, plus last-synced SHAs | Line numbers die on a version bump; this anchors by `§4.3` / `FR-ADM-*` / heading text |
| **Script** | `scripts/check-surface-docs.mjs` | The *mechanical checks* — ID coverage, link resolution, staleness | Extraction needs judgment; verification does not, and belongs in CI |

#### 1.3.1 The skill

Invoked `/carve-surface-docs <surface>`, surface ∈ `admin | customer | vendor | backend | core`. It encodes:

1. **Classification rule.** Every section of every source is ADMIN-ONLY / MOBILE-ONLY / BACKEND-ONLY / CORE / EXCLUDED. Ambiguity resolves toward **core** — duplicated content is the failure mode being avoided.
2. **File taxonomy** — the `00`–`08` numbering in §1.5, stable across surfaces so `02-*-API-Contract.md` means the same thing everywhere.
3. **Derived-from header**, mandatory on every generated file:

   ```markdown
   > **Derived**, not authoritative. Source: `docs/API-Route-Inventory.md` §21.
   > If this file and the source disagree, **the source wins**.
   > Last synced: 2026-09-08 · source commit: `8880298`
   ```

4. **House rules lifted from root `CLAUDE.md`** — never cite an ID without verifying it exists and means what you think; honour the `_Avoid_` lists in `CONTEXT.md`; tables over prose; cite requirements rather than restating them.
5. **Anchoring rule** — reference sources by section number, heading text or identifier. **Never by line number.**

#### 1.3.2 The manifest

One table per source document. Example rows:

| Source | Anchor | Surface | Target |
|---|---|---|---|
| `Requirements-Spec-v1.3.md` | §4.1 `FR-CUS-001…034` | customer | `customer/01-Customer-Requirements.md` |
| `Requirements-Spec-v1.3.md` | §4.3 `FR-ADM-001…033` | admin | `01-Admin-Requirements.md` |
| `Requirements-Spec-v1.3.md` | §5.1 `BR-001…022` | core | `core/03-Cross-Cutting-Requirements.md` |
| `API-Route-Inventory.md` | §3.2 Envelope | core | `core/02-API-Conventions.md` |
| `API-Route-Inventory.md` | §21 (all subsections) | admin | `02-Admin-API-Contract.md` |
| `Architecture-Frontend.md` | §16 Admin Portal on Flutter Web | admin | `03-Frontend-Architecture.md` |

Plus a `last_synced_sha` per source. A source whose current SHA differs from the recorded one has stale derivatives — which is what the script reports.

#### 1.3.3 The check script

Read-only, Node, no dependencies, CI-friendly:

- **ID coverage** — every `FR-CUS-nnn`, `FR-VEN-nnn`, `FR-ADM-nnn`, `FR-SYS-nnn`, `BR-nnn`, `NFR-nnn`, `C-nn`, screen ID and `AD-*` decision appears in exactly the set(s) the manifest assigns it. Targets: **34 / 31 / 33 / 12** FRs, **67** screens.
- **No invented IDs** — every ID cited in a derived file exists in some source. The check that matters most; root `CLAUDE.md` calls out how easily `FR-CUS-006` and `FR-CUS-007` transpose.
- **Link resolution** — every relative link resolves, including `../../../docs/core/` back-references.
- **Staleness** — source SHA vs manifest `last_synced_sha`; non-zero exit when a source has moved ahead of its derivatives.

### 1.4 `docs/core/` — carved once, ~2,400 lines (`SDC-05`)

| File | Built from |
|---|---|
| `README.md` | New — index, and the rule that core is derived while `docs/` wins |
| `01-Glossary-and-Invariants.md` | `CONTEXT.md` whole (131) · root `CLAUDE.md` domain invariants, identifier systems, status tags, fixed stack, live open decisions · SRS §1.3 conventions, §2.5 `C-01…C-13` |
| `02-API-Conventions.md` | Inventory §2 `AD-API-01…13`, §3.2 envelope, §3.3 idempotency, §3.4 auth, §3.7 status, §4.1–4.3 aliases/enums/pagination, §5.1–5.3 errors · Arch-Backend §13.2–13.6, §14.1/14.2/14.4 |
| `03-Cross-Cutting-Requirements.md` | SRS §3.4 permissions matrix · `FR-SYS-001…012` · `BR-001…022` · the NFR set · masking pipeline (Arch-Backend §9.1–9.5) |
| `04-Entity-Dictionary.md` | SRS §6.1 ERD + §6.2 all entities + §5.2–5.5 state machines · `Physical-Data-Model.md` §1 conventions, §3 ownership, §5 DB-enforced rules, §10 RLS posture |
| `05-Design-Tokens.md` | Design Context palette / M3 / shape / borders / typography / status / empty / loading / responsive / RTL / a11y / spacing / buttons / dialogs / copywriting · `component-widgets.md` full `SH-*` catalogue |
| `06-ADRs.md` | **Index only** — one line per `adr/0001`–`0010` with a link. They are already short, single-decision files in the right place; copying would restate, not clarify |

### 1.5 Surface layouts

#### 1.5.1 `apps/kh_admin/docs/` — 10 files + 24 screens

| File | Content |
|---|---|
| `README.md` | Index, authority chain, re-sync rule |
| `00-Product-Context.md` | Admin persona (SRS §3.3), permissions-matrix admin column, admin as the masking **exemption**, run command |
| `01-Admin-Requirements.md` | `FR-ADM-001…033` (6 `[ASSUMED]`: 002, 012, 019, 028, 032, 033) + admin-relevance column over `BR`/`NFR` pointing into `core/03` |
| `02-Admin-API-Contract.md` | 60 route-index rows · §21's 14 subsections · §5.4 admin errors · the `*ForAdmin` presenters · **plus "As built on `main`"**: double-wrapped envelope, `Decimal`→string, ~45 live routes vs 60 specified |
| `03-Frontend-Architecture.md` | Arch-Frontend §4.2, §7.4, §15.2, **§16 whole**, §17.4, Appendix A rows 805–822 · plus the `kh_admin` tree as built |
| `04-Data-Model.md` | `audit_log`, `platform_setting`, `admin_note`, `announcement`, `export_job` |
| `05-UI-Design.md` | Design Context §79 / §80 / §81 / §104-admin · the `Kh*` widget catalogue |
| `06-Completion-Plan.md` | ← `docs/Admin-App-Completion-Plan.md` |
| `07-Task-Register.md` | ← `docs/Admin-App-Completion-Tasks.md` + condensed Checkpoint-1 history |
| `08-Backend-Gaps.md` | ← `Admin-Backend-Followup-Tasks.md` + `admin-backend-api-gaps.md`, merged, both ID sets cross-referenced |
| `screens/` | 23 verbatim copies + README |

#### 1.5.2 `apps/kh_mobile/karat_hive/docs/` — 6 shared + two mode folders (`SDC-04`)

```
README.md · 00-Product-Context.md · 02-Mobile-API-Contract.md · 03-Frontend-Architecture.md
04-Data-Model.md · 05-UI-Design.md
customer/  01-Customer-Requirements.md (FR-CUS-001…034) · 07-Task-Register.md · screens/ (22+README)
vendor/    01-Vendor-Requirements.md   (FR-VEN-001…031) · 06-Completion-Plan.md
           07-Task-Register.md · screens/ (22+README)
```

The six shared files are genuinely shared — one binary, one router, one design system, one API client. `05-UI-Design.md` is the largest single carve in the project: most of the 3,035-line Design Context is customer/vendor motion and composition rules. Mode-folder sources: `Vendor-App-Completion-Plan.md`, `Vendor-App-Completion-Tasks.md`, `checkpoints/checkpoint-customer-mode-tasks.md`.

#### 1.5.3 `backend/docs/` — 10 files, mostly moves

`README.md` · `00-Product-Context.md` · `01-Backend-Requirements.md` (module-indexed view of the server-side acceptance criteria across all three actor FR sets) · `02-API-Contract.md` (module-indexed index into the route inventory) · `03-Architecture.md` ← `Architecture-Backend.md` · `04-Data-Model.md` ← `Physical-Data-Model.md` · `05-Async-Contract.md` ← `Async-Contract.md` · `06-Implementation-Plan.md` ← `Backend-Implementation-Plan.md` · `07-Task-Register.md` ← `Backend-Gap-Tasks.md` + `Backend-Gap-Fix-Plan.md` · `08-Review-and-Gaps.md` ← `backend_code_review_and_gap_report.md` + `Template-Lock-Review-Plan.md`.

#### 1.5.4 Per-surface `CLAUDE.md`

Each surface root gets a short `CLAUDE.md`: read order, the identifier prefixes that session will meet, the run command, and the rule that root `docs/` stays authoritative.

**Total: ~115 files** (core 7 · admin 35 · mobile 58 · backend 11 · skill · manifest · script) against ~13,600 lines of existing specification.

### 1.6 Execution order

Five phases, each independently shippable.

| Phase | Work | Gate |
|---|---|---|
| **1. Core** | Carve `docs/core/` (7 files) | Everything links to it, so it settles first |
| **2. Admin pilot** | The 35-file admin set, by hand | Already fully analysed; proves the taxonomy against a real surface |
| **3. Tooling** | Write skill, manifest, check script; run against core + admin and fix what it finds | Script green on two sets |
| **4. Mobile** | `/carve-surface-docs customer`, then `vendor` (58 files) | Largest surface; the skill earns its cost here |
| **5. Backend** | `/carve-surface-docs backend` (11 files) | Mostly `git mv` + redirect stubs |

#### `SDC-08` — the skill is authored third, not first

**Open for confirmation.** A skill written from one completed real carve will be substantially better than one written from a guess about it. The admin surface is already fully inventoried (see §2), so it is a free pilot. Reordering to put the skill first is possible but produces a worse skill.

#### `SDC-07` — move vs copy

**Open for confirmation.** Documents that are surface-only **and referenced by nothing else** should be *moved* with a one-line redirect stub, not copied — two live copies of a tick list drift within a day.

Verified safe to move: the four admin documents (`Admin-App-Completion-Plan.md`, `Admin-App-Completion-Tasks.md`, `Admin-Backend-Followup-Tasks.md`, `admin-backend-api-gaps.md` — their only inbound links are to each other), the vendor and customer task documents, and the seven backend documents.

Stub shape:

```markdown
# Admin App Completion — Plan of Record
Moved to [`apps/kh_admin/docs/06-Completion-Plan.md`](../apps/kh_admin/docs/06-Completion-Plan.md).
```

Everything else — the four shared specs, `ui-screens/`, `CONTEXT.md` — stays put and is the authority.

### 1.7 Files the carve would touch

**Created** — ~115, per §1.4 and §1.5.

**Modified** — redirect stubs at moved paths; the authority-chain table in root `CLAUDE.md` gains rows for `docs/core/` and the surface sets.

**Untouched** — the four shared specs, `ui-screens/`, `ui-mock/`, `docs/old/`, `Requirements-raw.txt`, and all application code. No Dart or TypeScript changes.

Note: `Admin-App-Completion-Plan.md`, `Admin-App-Completion-Tasks.md` and `Admin-Backend-Followup-Tasks.md` were modified in the working tree at the time of the carve notes — carry working-tree state, not `HEAD`.

### 1.8 Carve verification

Docs-only, so verification is consistency checking — this repo's stated correctness criterion.

1. **`node scripts/check-surface-docs.mjs` exits 0** — ID coverage (34 / 31 / 33 / 12 FRs, 67 screens, all `BR` / `NFR` / `C` / `AD-*`), no invented IDs, all links resolve, no stale sources.
2. **No content lost.** Diff the ID set in each source section against the ID set in its derived file; the derived set must be equal, never smaller.
3. **No broken inbound links.** `grep -rn "Admin-App-Completion\|Vendor-App-Completion\|Architecture-Backend\|Async-Contract\|Physical-Data-Model" --include=*.md .` returns only stubs and derived files.
4. **Builds unaffected.** `cd apps/kh_admin && flutter analyze && flutter test` (green, 141+ tests at carve time; 352 at the simplification pass) · `cd apps/kh_mobile/karat_hive && flutter analyze && flutter test` · `cd backend && npm run build && npm test`. Confirms no new `docs/` folder is picked up by the Dart or Node toolchains.
5. **Skill re-run is idempotent.** Running `/carve-surface-docs admin` again with no source change produces no diff — the real test that the skill encodes the rules rather than the outcome.
6. **Spot-read.** From `apps/kh_admin/docs/` alone, could someone start ADM-S03? From `vendor/` alone, VEN-S09?

---

## 2. Admin content filter

Every section of every source document classified ADMIN-ONLY / COMMON / EXCLUDED. Line ranges are inclusive and correct at HEAD `8880298`. Use them to do the work now, not to re-find it later — the manifest in §1.3.2 anchors by section number and identifier instead.

### 2.1 Admin-only material — the whole of it

| Source | Lines | Content |
|---|---|---|
| `docs/Requirements-Spec-v1.3.md` | 1184–1644 | **`FR-ADM-001…033`** — 33 requirements |
| | 220–227 | §3.3 Platform Admin persona |
| | 1909–1932 | §5.4 Vendor account state machine — drives ADM-S05–S07 verify / activate / suspend |
| | 2278–2304 | `AUDIT_LOG` + `PLATFORM_SETTING` entity dictionary |
| | 2791–2818 | Appendix C.3 — the `ADM-S01…S23` screen table (rows 2795–2817) |
| `docs/API-Route-Inventory.md` | 664–723 | **60 admin route-index rows** — ≈41 % of the whole API surface |
| | 1694–1991 | **§21, the admin API chapter** — 14 subsections, one per screen group |
| | 381–388 · 430–438 · 466–489 | `RequestForAdmin` · `OfferForAdmin` · `ConnectionForAdmin` presenters |
| | 558–568 | §5.4 admin error codes |
| | 2052–2073 | §22.3 `FR-ADM` → route traceability |
| `docs/Architecture-Frontend.md` | 178–183 · 347–350 · 604–618 · **619–654** · 682–687 · 756–766 · 805–822 | §4.2 why admin is a separate app · §7.4 admin shell · §15.2 keyboard / a11y release gate · **§16 the entire Flutter Web chapter incl. `AD-FE-12`** · §17.4 web perf · §21.1 blockers · Appendix A screen→module map |
| `ui-screens/admin/` | 23 files | Field-level inventory per screen (~1,050 lines) |
| `ui-screens/admin/README.md` | 33 | Roles, primary destinations, the unmasked-identity rule |
| `ui-screens/Karat_Hive_UI_Design_Context.md` | 2264–2327 · 2854–2865 | §79 Admin Portal · §80 Admin Dashboard · §81 Admin motion · §104 admin animation budget |
| `docs/Admin-App-Completion-Plan.md` | 142 | Plan of record |
| `docs/Admin-App-Completion-Tasks.md` | 60 | `ADM-C-*` register |
| `docs/Admin-Backend-Followup-Tasks.md` | 54 | `ADM-C-70…76` |
| `docs/admin-backend-api-gaps.md` | 120 | `BUG-ADM-01`, `GAP-ADM-01…08`, route↔screen matrix |
| `docs/Admin-Checkpoint-1-Taxonomy-Plan.md` + `-Tasks.md` + `.csv` | 258 + 304 | Checkpoint-1 history — condense, do not copy whole |
| `docs/Screen-API-Map.md` | 113–146 + `SAM-GAP-9/10/12/13` | Admin screen → endpoint coverage |

#### 2.1.1 `FR-ADM` sub-group ranges

| Lines | Sub-section | Requirements |
|---|---|---|
| 1188–1218 | 4.3.1 Access control | `001` (1192), `002` `[ASSUMED]` (1206) |
| 1219–1305 | 4.3.2 Dashboard and platform statistics | `003`–`009` |
| 1306–1350 | 4.3.3 Customer management | `010`, `011`, `012` `[ASSUMED]` |
| 1351–1411 | 4.3.4 Vendor management | `013`–`016` |
| 1412–1502 | 4.3.5 Request / Offer / Connection oversight | `017`–`023` (`019` `[ASSUMED]`) |
| 1503–1644 | 4.3.6 Taxonomy, content, configuration | `024`–`033` (`028`, `032`, `033` `[ASSUMED]`) |

6 of 33 are `[ASSUMED]` and need Product Owner sign-off: `002`, `012`, `019`, `028`, `032`, `033`. Series totals for context — `FR-CUS` 34, `FR-VEN` 31, `FR-ADM` 33, `FR-SYS` 12 = 110.

#### 2.1.2 §21 admin API subsection map

| Lines | Subsection | Screens / FRs |
|---|---|---|
| 1694–1715 | Preamble — 404-not-403 for non-admin tokens, no self-registration, coarse RBAC (`AD-API-03`), list auditing, shared admin list query (`limit` **max 100**), internal notes (`AD-API-12`) | cross-cutting |
| 1716–1732 | 21.1 Dashboard | ADM-S02 · `FR-ADM-003…009` |
| 1733–1758 | 21.2 Customers | ADM-S03/S04 · `FR-ADM-010…012` |
| 1759–1799 | 21.3 Vendors — list, detail, verification, access | ADM-S05–S07 · `FR-ADM-013…016` |
| 1800–1820 | 21.4 Type Subscription grant `[PROPOSED]` `AD-API-04` | `FR-VEN-031` |
| 1821–1857 | 21.5 Requests, Offers, Connections | ADM-S08–S13 · `FR-ADM-017…023` |
| 1858–1872 | 21.6 Taxonomy — **`[BUILT · Checkpoint-1]`** | ADM-S14/S15 · `FR-ADM-024/025` |
| 1873–1888 | 21.7 Review moderation | ADM-S16 · `FR-ADM-026` |
| 1889–1907 | 21.8 Reports and exports | ADM-S17 · `FR-ADM-027/028` |
| 1908–1924 | 21.9 Announcements | ADM-S18 · `FR-ADM-029` |
| 1925–1938 | 21.10 Platform settings | ADM-S19 · `FR-ADM-030` |
| 1939–1951 | 21.11 Gold rates | ADM-S20 · `FR-ADM-031` |
| 1952–1962 | 21.12 Abuse queue `[ASSUMED]` | ADM-S21 · `FR-ADM-032` |
| 1963–1972 | 21.13 Audit log `[ASSUMED]` | ADM-S22 · `FR-ADM-033` |
| 1973–1991 | 21.14 Admin user management `[ASSUMED]`, coarse | ADM-S23 · `FR-ADM-002` |

### 2.2 Common material the admin surface genuinely needs

Under `SDC-05` this is carved once into `docs/core/` rather than inlined per surface.

| Source | Lines | Why needed |
|---|---|---|
| `CONTEXT.md` | all 131 | Ubiquitous language and the `_Avoid_` lists — admin screens name every domain entity |
| root `CLAUDE.md` | — | Authority chain, identifier systems, status tags, domain invariants, fixed stack, live open decisions |
| SRS | 62–91 · 118–190 · 228–253 · 1645–1815 · 1816–1945 · 1992–2304 · 2305–2318 · 2361–2394 · 2395–2463 | Conventions · constraints (`C-01/02/04/05/09/10/12/13`) · §3.4 permissions matrix · `FR-SYS-002/003/010/011/012` · `BR-001…022` · state machines · entity dictionary · §7.1 Admin Portal ≥1280 px · §7.5 API + §7.6 storage · NFRs (`002`, `008`, `013`, `014`, `015`, `019`–`025`, `027`, `029`, `030`) |
| API Inventory | 55–76 · 90–163 · 190–207 · 250–256 · 490–530 · 2099–2119 | `AD-API-01…13` · envelope · idempotency · auth · status codes · pagination (**admin `limit` max 100**) · generic + identity errors · open tensions |
| Arch-Frontend | 108–126 · 192–313 · 318–323 · 339–356 · 357–439 · 440–493 · 494–550 · 573–597 · 655–666 · 678–681 · 688–738 · 739–755 | `AD-FE-01…14` · package/feature structure · layers + Riverpod · go_router · design system · data layer + interceptors · masking-as-type · freshness · media · l10n / RTL · budgets · security · build · testing |
| Arch-Backend | 123–158 · 390–425 · 430–479 · 533–574 · 628–631 · 647–671 · 678–709 · 722–753 · 826–846 · 857–862 | Invariants · `AD-BE-01…16` · request lifecycle · **masking pipeline incl. §9.5 "admin always sees identity"** · outbox + event catalogue · volumes · `pg_trgm` search semantics · erasure · replica reads · envelope / errors / idempotency / pagination / rate-limit · auth paths, tokens, authorisation model · platform settings · **audit field set** · UTC↔GST |
| `docs/Physical-Data-Model.md` | 22–55 · 56–87 · 111–135 · 198–209 | Conventions · table ownership (`admin_note`, `announcement`, `export_job` are the admin-write surface) · DB-enforced rules · Supabase RLS posture |
| `ui-screens/component-widgets.md` | `SH-FND-*` · `SH-DOM-03/08/09` · `SH-TAX-01/02` · `SH-MED-03/04` · `SH-ID-02/03` | Shared widget contracts the admin screens reference |
| `ui-screens/Karat_Hive_UI_Design_Context.md` | 114–160 · 409–498 · 499–592 · 1362–1429 · 1724–1786 · 2417–2515 · 2536–2551 · 2930–2980 | Palette / tokens · M3 + shape + borders · typography · status / empty / loading systems · responsive + RTL + a11y · consistency, spacing, buttons · dialogs · copywriting |
| `docs/adr/0001`–`0010` | ~100 total | All ten are short and all bear on admin |

#### 2.2.1 Minimum backend read-set for an admin frontend developer

≈300 of `Architecture-Backend.md`'s 1,116 lines: §2.3 (123–135) · §3 (136–158) · §8.2 (390–425) · §9.1–9.5 (430–479) · §11.1–11.2 (533–574) · §12.4/12.6/12.7/12.8 (628–631, 647–671) · §13.2–13.6 (678–709) · §14.1/14.2/14.4 (722–737, 742–753) · §17.1/17.2/17.5 (826–846, 857–862).

### 2.3 Excluded — deliberately

- SRS §4.1 Customer FR (258–743) and §4.2 Vendor FR (744–1183) — **except** `FR-VEN-002` (KYC, @764) and `FR-VEN-031` (subscriptions, @1169), which ADM-S07 and the subscription grant depend on.
- API Inventory §13–§17, §19, §20 — customer/vendor route chapters. Exception: 1660–1674 (`/v1/me/subscriptions`, `AD-API-04`).
- Arch-Frontend §4.3 dual-mode · §7.2 mobile shell · §13.1/13.3/13.4 push · §15.1 · §17.2.
- Arch-Backend §5 deployment · §6 runtime · §10 acceptance transaction · §12.1/12.3/12.5 · §19 reliability · §21 source layout · Appendix B.
- `ui-screens/customer/`, `ui-screens/vendor/` · `ui-mock/` · `docs/old/` · `Requirements-raw.txt`.
- `Vendor-App-Completion-*` · `Backend-Gap-*` · `Backend-Implementation-Plan.md` · `Template-Lock-Review-Plan.md` · `checkpoint-customer-mode-tasks.md`.
- `Async-Contract.md` — except the admin-emitting events, folded into `02-Admin-API-Contract.md`.

### 2.4 Cross-document quick reference

| Admin concern | SRS v1.3 | API Inventory | Arch-Frontend | Arch-Backend |
|---|---|---|---|---|
| Screen list (23) | 2791–2818 | §21 subsections | Appx A 805–822 | — |
| Requirements (33) | 1184–1644 | §22.3 2052–2073 | — | Appx A 1020–1058 |
| Routes (60) | — | 664–723 index · 1694–1991 detail | — | §7.1 296–338 |
| RBAC / auth | §3.4 228–253 · `FR-ADM-001/002` | §3.4 140–163 · `AD-API-01/03/13` | §7.3 339–346 | §14.1/14.2/14.4 |
| Envelope / errors | §7.5 2361–2375 | §3.2 · §5.1/5.2/5.4 | §6.3 304–313 | §13.2 678–691 |
| Pagination | `NFR-002` | §4.3 250–256 · §21 preamble | §9.6 434–439 | §13.4 696–699 |
| Masking (admin exemption) | `BR-006`–`008` · `FR-SYS-003` | §3.5 · `*ForAdmin` presenters | §10 440–493 | **§9.5 474–479** |
| Audit log | `FR-SYS-011` · `FR-ADM-033` · `AUDIT_LOG` 2278 | §21.13 | Appx A `audit` module | §17.2 841–846 |
| Data grid (`AD-FE-12`) | note @2846 | §23 @2107 | **§16.1 623–633** | — |
| Platform settings | `FR-ADM-030` · `BR-020` · `PLATFORM_SETTING` 2293 | §21.10 | — | §17.1 826–840 |
| Already built | — | §21.6 `[BUILT · Checkpoint-1]` | `AD-FE-02` @110 | — |

### 2.5 Two scope caveats that must travel with the derived set

- **ADM-S20 (gold-rate configuration) is deferred** from the current build (`Architecture-Frontend.md` line 819; `SAM-GAP-11` withdrawn). The backend exists in `AdminGoldRateController`; the UI is out of scope pending Yahoo Finance redistribution terms.
- **`FR-ADM-002` role differentiation is deferred.** v1 RBAC is a flat `role = ADMIN` (`AD-API-03`; inventory lines 62 and 1700), so ADM-S23 ships with no Role selector (`SAM-GAP-13`) — even though `ui-screens/admin/README.md` still documents three roles. That tension is live and should be carried into `01-Admin-Requirements.md`, not silently resolved.
