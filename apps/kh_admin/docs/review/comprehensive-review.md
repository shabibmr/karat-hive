# Admin Portal — comprehensive review

| | |
|---|---|
| **Product** | Karat Hive |
| **Surface** | Flutter Web Admin Portal (`apps/kh_admin`) plus the four-surface documentation carve that feeds it |
| **HEAD** | `88802985d39a4679724875d900275fa038d3bb89` (`main` = `origin/main`) — abbreviated `8880298` in source notes |
| **Dates** | Carve analysis 8 September 2026 · Flutter/Dart and simplification 9 September 2026 |
| **Status** | Synthesis of the `apps/kh_admin/docs/review/` set. **Not the plan of record.** Nothing in the carve proposal has been executed. Simplification Tier-0 *has* been applied in the working tree. |
| **Does not override** | SRS v1.3 · `API-Route-Inventory.md` · `Architecture-Frontend.md` · `Architecture-Backend.md` · `Admin-App-Completion-Plan.md` |
| **Does not mint** | `FR-*`, `AD-FE-*`, `AD-API-*`, `ADM-S*`, `ADM-C-*`, `SAM-GAP-*`, `ADM-INS-*` — those are cited, not replaced |
| **Decision prefixes already in play** | `SDC-nn` (carve) · `ADM-SMP-nn` (simplification) · `E1`–`E30` (Flutter/Dart enhancements, local to that review) |

This document is the single reading of everything currently under [`apps/kh_admin/docs/review/`](README.md). It does not replace the source files; it restates every decision, classification, finding, caveat, applied fix, and enhancement so they can be reviewed in one place.

| Source file | What it contributed |
|---|---|
| [`README.md`](README.md) | Carve-set index, `SDC-01`–`SDC-08`, the question the carve answers |
| [`carve-plan.md`](carve-plan.md) | Method, `docs/core/` layout, four surface layouts, execution order, verification |
| [`admin-content-filter.md`](admin-content-filter.md) | Every source section classified ADMIN-ONLY / COMMON / EXCLUDED, with line ranges at this HEAD |
| [`flutter-dart-code-review.md`](flutter-dart-code-review.md) | Pointer only. Canonical engineering review: [`docs/Admin-Flutter-Dart-Code-Review.md`](../../../../docs/Admin-Flutter-Dart-Code-Review.md) |
| [`simplification-review.md`](simplification-review.md) | `ADM-SMP-01`–`65` register, four axes, Tier-0 applied work, behavioural divergence |

Companion, **not** part of this folder: [`docs/inspection/`](../inspection/README.md) (`ADM-INS-01`–`87`). Where a fact appears in both an inspection ID and a review finding, the inspection ID remains authoritative for standards and spec conformance. This document repeats the *quantity* and the *named replacement*, not a second verdict.

---

## 0. How the three reviews relate

Three different questions were asked of the same surface.

| Review | Question | Outcome at this HEAD |
|---|---|---|
| **Surface-doc carve** (`SDC-*`) | Can a developer or agent scoped to `apps/kh_admin` work without opening the 2,800-line SRS and the other repo-wide specs? | Proposal. Nothing executed. Admin filter is complete; other surfaces are scoped but not inventoried at the same depth. |
| **Flutter/Dart checklist** (`E1`–`E30`) | Does the portal meet the library-agnostic Flutter/Dart bar and Architecture-Frontend? | Snapshot. Architecture *shape* is right; consistency and depth are not. 7 of 15 checklist areas **Fail**. |
| **Simplification** (`ADM-SMP-*`) | What does the code make harder than it needs to be? | Snapshot + **9 FIXED**, **1 PART** applied in this working tree. 40 findings. Does not hunt correctness bugs. |

They overlap on the same facts (list-controller duplication, Melos exclusion, table virtualisation, unused Firebase, URL state). They do **not** renumber each other. The unification is in §8 of this document.

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

---

## 3. Flutter/Dart engineering review

Canonical source: [`docs/Admin-Flutter-Dart-Code-Review.md`](../../../../docs/Admin-Flutter-Dart-Code-Review.md). The file in this folder is a move stub.

The portal is a working feature-first Flutter Web app: login, shell, and live routes for ADM-S01–S19 and S21–S23 (ADM-S20 gold rates remain a placeholder). The gaps below are against the Flutter/Dart checklist and Architecture-Frontend, not “the app does not exist.”

### 3.1 Executive summary

The architecture **shape** is right: `lib/features/<name>/{controller,model,presentation,repository}`, Riverpod providers, a typed `ApiClient`, a design-token `ThemeExtension`, `go_router` auth redirect, and EN/AR `gen-l10n` scaffolding. CI already runs `flutter analyze`, `flutter test`, and `flutter build web` for this package.

What is not right is **consistency and depth**. List state is boolean soup instead of `AsyncValue`. Presentation files are 600–1,400 lines. Tables are fully built, not virtualised. User-facing English is still hardcoded on most Group C screens. Analyzer settings are stock `flutter_lints` with two rules *disabled*. Web token policy, idle timeout, Semantics, and global error capture are missing. Several Firebase SDKs are on the bundle and unused.

#### Scorecard

| # | Area | Verdict | Worst gap |
|---|---|---|---|
| 1 | Project health | **Partial** | Uneven feature recipe; Melos exclusion; unused Firebase |
| 2 | Dart language | **Partial** | Broad `on Object catch` + `e.toString()`; relative imports |
| 3 | Widgets | **Fail** | God `build()` methods; `_build*` helpers; hardcoded colours |
| 4 | State management | **Partial** | Lists: `isLoading`/`error` flags; details: `AsyncValue` |
| 5 | Performance | **Fail** | `KhDataTable` + outer `SingleChildScrollView`; no `deferred as` |
| 6 | Testing | **Partial** | Good unit/widget coverage; no goldens, e2e, request-list screen, or several controllers |
| 7 | Accessibility | **Fail** | Zero `Semantics`; row 44; sidebar 38; offer Inspect 30 |
| 8 | Platform / responsive | **Partial** | Desktop breakpoint exists; `MediaQuery.of`; no keyboard conventions |
| 9 | Security | **Fail** | Web persists access+refresh; seed password default; unmasked logs |
| 10 | Packages | **Partial** | Unused Firestore/Messaging/Analytics; stale major versions |
| 11 | Navigation | **Partial** | Auth guard exists; untyped string routes; leftover placeholder map |
| 12 | Error handling | **Fail** | No `FlutterError.onError`; raw exceptions in UI; dashboard fail-open |
| 13 | Internationalization | **Fail** | ARB exists; most chrome and Group C copy is English literals |
| 14 | Dependency injection | **Partial** | Riverpod graph is the DI; widgets still `ref.read` repositories |
| 15 | Static analysis | **Fail** | No strict-casts/inference/raw-types; `riverpod_lint` unused |

**7 Fail · 8 Partial · 0 Pass.**

### 3.2 What already works (do not regress)

| Strength | Evidence |
|---|---|
| Feature-first modules (`AD-FE-08`) | `lib/features/*/{controller,model,presentation,repository}` |
| Repositories wrap Dio; UI does not call Dio | e.g. `RequestRepository`, `VendorRepository`, `apiClientProvider` |
| Detail screens use `AsyncValue` | verification, taxonomy, dashboard, request/offer/vendor/customer/connection detail |
| Token attach + single-flight 401 refresh | `ApiClient._send`, `SessionController.silentRefresh` |
| Typed error envelope exists | `ApiException` (`code`, `message`, `requestId`) |
| Design tokens for the dark canvas | `KhThemeExtension`, `KhColors.dark`, `buildKhAdminTheme()` |
| Auth redirect on `GoRouter` | `RouterNotifier.redirect` |
| `mounted` checks on many async UI paths | login, verification dialogs, list search debounce |
| Tests per most features | `test/features/*` controller + repository + screen |
| CI job for this package | `.github/workflows/frontend.yml` `admin` job |
| No `print()` in `lib/` | `debugPrint` only (still unfiltered — see §3.11) |
| Platform URL open isolated | `core/platform/open_url_web.dart` / `open_url_stub.dart` |
| Hover on table rows | `KhDataTable` `InkWell.hoverColor` |

### 3.3 Findings by checklist section

Each finding cites evidence. Where the inspection register already owns the fact, the `ADM-INS-*` ID is given so this review does not renumber it.

#### 3.3.1 General project health — Partial

**Folder structure is consistent at the top level and inconsistent inside features.** Checkpoint-1 verticals (vendors list, requests, offers, taxonomy, verification) use `@freezed` models, generated JSON, and URL query helpers. Later screens (customers, connections, abuse, audit, moderation, settings, announcements, admin-users) hand-roll `copyWith` / `==` / `fromJson` and skip URL state (`ADM-INS-05`, `ADM-INS-50`).

Empty shells remain:

- `lib/features/gold_rate/{controller,model,presentation,repository}/` — ADM-S20 is deferred; nav still registers `/gold-rates` as a placeholder (`ADM-INS-21`, `ADM-INS-51`).
- `lib/features/auth/{controller,model,repository}/` — login lives in `presentation/` only; session lives in `lib/core/auth/`.

`kh_admin` is **excluded from the Melos workspace** (`pubspec.yaml` at repo root, `AD-FE-02`). It cannot import `kh_domain` / `kh_design_system` / `kh_l10n` and reimplements tokens, chips, and party fields (`ADM-INS-53`).

`pubspec.yaml` pulls `cloud_firestore`, `firebase_messaging`, and `firebase_analytics`. `FirestoreService` is unused (`ADM-INS-41`). FCM: background handler is registered in `main()`; `initializeForegroundHandler` is **never called**, so foreground messages and tap-to-invalidate never run (`ADM-INS-08`, `ADM-INS-42`). `FirebaseAnalyticsObserver` / `getObserver()` is never attached to `GoRouter`. `cupertino_icons` is unused on a web-first admin canvas.

**Enhance:** one list-feature recipe (freezed model + `AsyncValue`/sealed list state + URL helper + ARB keys + screen/controller/repo tests). Delete or hide gold-rate until ADM-S20. Drop unused Firebase packages until `AD-FE-10` is implemented. Plan Melos inclusion as a dedicated slice so `kh_domain` masking types can land.

#### 3.3.2 Dart language pitfalls — Partial

| Pattern | Where | Why it matters |
|---|---|---|
| `on Object catch (e)` then `e.toString()` | vendor/request/offer/customer/connection/audit list controllers; request/customer detail | Catches `Error` (bugs) and shows Dio/envelope text (`ADM-INS-60`). **27** `on Object catch` sites |
| `catch` without `on` | **68** sites: query-param helpers, session, dashboard queues, login, Firebase, logout | Swallows failures; URL updates no-op (`ADM-INS-62`); dashboard queues look empty (`ADM-INS-61`); `AuthRepository.logout` is best-effort swallow |
| Relative imports in `lib/` | entire `lib/` | Tests use `package:kh_admin/...`; production does not (`ADM-INS-16`) |
| `Future.microtask(refresh)` in `Notifier.build()` | six list controllers | Side-effect in `build()`; races with the first frame; prefer `ref.listen` / explicit load / `AsyncNotifier` |
| `late final TextEditingController` | every list screen | Acceptable if initialised in `initState`; prefer constructor init |
| Identity as `String?` | `OfferParentRequestSummary.customerName` / `customerMobile` / `customerEmail` | Compiles a pre-acceptance widget against fields it must never have (`ADM-INS-06`, `AD-FE-07`) |
| `DateTime.now()` as parse fallback / age | verification wait hours, vendor licence expiry, audit range | Device clock, not `meta.serverTime` (`ADM-INS-07`) |

`ApiClient.get` returns `Future<dynamic>`. Call sites downcast. That is implicit `dynamic` at the transport boundary. A generated OpenAPI client (`AD-FE-06`, deferred) or typed `get<T>` would close it.

**Enhance:** map `on ApiException catch` to a user-facing `error.code` catalogue; never `e.toString()` in state. Enable `avoid_catches_without_on_clauses`. Switch list controllers to `AsyncNotifier` (or a sealed `ListViewState`). Convert `lib/` to `package:kh_admin` imports. Capture `meta.serverTime` in `ApiClient` and inject a clock.

#### 3.3.3 Widget best practices — Fail

Largest presentation files (generated l10n excluded):

| File | Lines |
|---|---|
| `request_detail_screen.dart` | 1,484 |
| `offer_detail_screen.dart` | 1,388 |
| `announcements_screen.dart` | 1,210 |
| `vendor_detail_screen.dart` | 1,075 |
| `platform_settings_screen.dart` | 1,059 |
| `customer_detail_screen.dart` | 1,022 |
| `audit_screen.dart` | 882 |
| `connection_detail_screen.dart` | 819 |

These mix layout, dialogs, mutations, copy, and formatting in one `State` class (`ADM-INS-22`). Private `_build*` helpers stay in the same file, so they do not get `const` constructors or independent rebuild boundaries.

Theming is token-based **until it is not**: `Colors.white` / `Colors.black` on action buttons (vendor/customer/request detail, login, verification dialogs) (`ADM-INS-18`). Inline `TextStyle(fontSize: 12.0)` on offer list and connection detail bypasses `kh.typography`.

`KhDataTable` uses a `for` loop over every row inside a `Column` (`ADM-INS-13`). List screens wrap that table in another vertical `SingleChildScrollView` (`ADM-INS-70`). `GlobalKey<FormState>` usage is appropriate (forms, not tree identity).

**Enhance:** split each god screen into header / summary / timeline / actions / dialogs widgets. Extract `KhDataTable` rows to a lazy viewport (see §3.3.5). Ban raw `Colors.*` and raw `TextStyle` via lint + review. Prefer `context.kh.colors.onPrimary` for button foregrounds.

#### 3.3.4 State management (Riverpod) — Partial

**Two recipes coexist.**

Detail / dashboard / taxonomy / verification: `AsyncNotifier` + `AsyncValue` — loading, data, and error are exclusive. This matches `AD-FE-03`.

Lists: a single class with `isLoading`, `isLoadingMore`, `error`, and `items` (`VendorListState` and twins). `isLoading && error != null` is representable (`ADM-INS-19`). Customers/abuse/audit/announcements/admin-users duplicate that shape by hand instead of freezed.

`SessionController` is a `StateNotifier`; list controllers are `Notifier`; some later features are `StateNotifier` again (abuse, announcements, admin users). One Riverpod generation would reduce ceremony.

`Notifier.build()` scheduling `Future.microtask(refresh)` is a side effect inside the provider build. `AsyncNotifier.build()` returning the fetch is the idiomatic replacement.

Presentation calls the repository on verification document open (`verification_detail_pane.dart` `ref.read(verificationRepositoryProvider).fetchDocumentUrl`) (`ADM-INS-11`). Controllers should own that.

Screens `ref.watch` the whole list state, so a filter-chip tweak rebuilds the table (`ADM-INS-73`). Use `select`.

No `ProviderObserver` / error observer.

**Enhance:** shared `AdminCursorListState<T, F>` (sealed or `AsyncValue` + pagination metadata). One `AdminCursorListController` base. Document-open goes through `VerificationController`. `ref.watch(listProvider.select((s) => s.items))` vs filters. Add a `ProviderObserver` that reports to the logger (once logging exists).

#### 3.3.5 Performance — Fail

| Issue | Evidence | Spec |
|---|---|---|
| Every table cell is in the tree | `KhDataTable` `for` rows | Architecture-Frontend §17.3; `ADM-INS-13` |
| Nested scroll prevents lazy build | list screens wrap the table in `SingleChildScrollView` | `ADM-INS-70` |
| Eager route imports | `app_router.dart` imports every screen, including `fl_chart` via reports | §16.2 / §17.4; `ADM-INS-37` |
| Client-side filter of one page | `RequestRepository.fetchRequests` filters after fetch; `hasMore` follows unfiltered cursor | `ADM-INS-46` |
| Export poll 400 ms × 40 | `ReportsRepository.pollInterval` | `ADM-INS-71` — **FIXED** in simplification Tier-0 as `ADM-SMP-44` |
| `MediaQuery.of(context).size.width` | `kh_admin_scaffold.dart` | Prefer `MediaQuery.sizeOf`; `ADM-INS-17` |
| No image decode bounds | KYC / vendor documents | `ADM-INS-72` |
| Extra SDKs on first load | Firestore, Messaging, Analytics, `fl_chart` | `ADM-INS-41`, `ADM-INS-42` |
| No first-load budget in CI | `frontend.yml` `admin` job builds web, does not measure | `ADM-INS-84` |

`ListView.builder` appears in the taxonomy tree only. Admin tables are the hot path.

**Enhance:** replace `KhDataTable`’s `Column`+`for` with a vertical `ListView.builder` (fixed `itemExtent` from `kh.spacing.tableRowHeight`) inside the horizontal scroller; drop the outer `SingleChildScrollView`. Deferred-load reports, audit, announcements. Push list filters to the API (backend follow-up) instead of shrinking the page. Poll exports on 1–2 s. Track compressed main-js size in CI.

#### 3.3.6 Testing — Partial

Present: API client, session, most query-params, most feature controller/repository/screen tests, shared widget tests, one responsive test. No mocktail/mockito — tests use hand fakes and `ProviderScope` overrides. That isolation style is healthy.

**Feature coverage (controller / repository / screen):**

| Feature | Controller | Repository | Screen |
|---|---|---|---|
| abuse, admin_users, announcements, connections, customers, moderation, settings, verification | yes | yes | yes |
| offers, vendors | list only | yes | list **and** detail |
| audit | **no** | yes | yes |
| dashboard, reports | **no** | yes | yes |
| taxonomy | yes | **no** | yes |
| requests | list only | yes | **neither** list nor detail screen (`request_detail_parse_test.dart` is model JSON only) |
| gold_rate | n/a (empty) | n/a | n/a |

Also untested: `request_detail_controller`, `offer_detail_controller`, `vendor_detail_controller`, `verification_query_params` (the other query-param helpers *are* tested).

Missing against Architecture-Frontend §20 and the Flutter checklist:

| Gap | ID |
|---|---|
| No LTR/RTL (or 200% text scale) goldens for `KhStatusChip`, `KhDataTable`, `KhMetricCard`, `KhScreenHeader` | `ADM-INS-01` |
| No `test/features/requests/request_list_screen_test.dart` (empty/error) | `ADM-INS-39` |
| No `integration_test` / seeded Chrome click-through | `ADM-INS-80` |
| No coverage gate on business logic | — |
| Two analyzer warnings in tests | unused import in `announcements_screen_test.dart`; unused fake params in `platform_settings_controller_test.dart` |

Boolean-soup list controllers are not tested for exclusive state transitions (loading→error, retry).

**Enhance:** add the missing request-list widget test first (cheap). Then audit/dashboard/reports controller tests and taxonomy repository tests. Goldens for the four shared widgets in LTR, RTL, and 200% text scale. One integration_test for login → dashboard → one list → detail. Fail CI on `flutter analyze` warnings in this package (keep the job scoped to `apps/kh_admin`).

#### 3.3.7 Accessibility — Fail

| Check | Result |
|---|---|
| `Semantics` / `semanticLabel` / `ExcludeSemantics` | **Zero** matches in `lib/` (`ADM-INS-12`) |
| Hit targets ≥ 48 px | Tokens: `tableRowHeight: 44`, `buttonHeight: 36`, `inputHeight: 40`. Worse: sidebar row **38**, offer Inspect `minimumSize: Size(60, 30)`, table `IconButton`s with 18 px icons (`ADM-INS-63`) |
| `SelectionArea` for canvas copy-paste | Absent |
| In-app find (Ctrl+F is a no-op on canvas) | Absent (`ADM-INS-36`) |
| Keyboard: Esc / Enter / row focus | Absent |
| Color not sole state indicator | Status chips have labels — good |
| Focus order | Untested |

Dense admin tables can stay dense, but icon-only actions, sidebar items, and the offer Inspect control still need a 48 px minimum (padding around a smaller visual is enough).

**Enhance:** wrap icon buttons in `Semantics(button: true, label: …)`. Add `SelectionArea` at the scaffold body. Raise interactive targets to 48. Add a list find field bound to the existing `q` filter.

#### 3.3.8 Platform and responsive design — Partial

This is a **Flutter Web** product that still carries Android/iOS/Windows/Linux/macOS runners from `flutter create`. Fine for local, irrelevant for production.

The shell breakpoint `kDesktopBreakpoint = 1280` and compact top bar at 600 are documented and tested (`test/responsive/admin_responsive_test.dart`). Hover exists on table rows. `SafeArea` is not used (web desktop); not a defect.

Gaps: the shell mixes `MediaQuery.of(context).size.width` (sidebar breakpoint) with `MediaQuery.sizeOf` (compact top bar) — prefer `sizeOf` / `widthOf` everywhere (`ADM-INS-17`); physical `Alignment.centerLeft` / `centerRight` on the scaffold and two detail screens (`ADM-INS-03`); `dart:html` in `open_url_web.dart` (`avoid_web_libraries_in_flutter`, `deprecated_member_use`) instead of `package:web`; no `Shortcuts` / focus traversal policy. Sidebar already uses `ListView.separated`; tables do not (`KhDataTable` has **16** call sites, all eager).

**Enhance:** directional alignment everywhere. Replace `dart:html` with `package:web` (or `url_launcher`). Add a portal `Shortcuts` map (Esc closes dialog, `/` focuses find). Keep desktop-first; do not invest in mobile Admin layouts beyond the existing drawer.

#### 3.3.9 Security — Fail

| Check | Result |
|---|---|
| Tokens in `FlutterSecureStorage` | Same `FlutterSecureStorage()` on every platform — **no `kIsWeb` branch, no `WebOptions`**. Web backend is localStorage. Architecture-Frontend §18.1 wants access token **in memory only** (`ADM-INS-09`) |
| Idle timeout 60 min + warning | Missing (`FR-ADM-001` AC4; `ADM-INS-30`) |
| Seed password in source | `DevAuthConfig` default `'AdminSecret123!'` (`ADM-INS-45`) |
| Logs mask PII/tokens | No; FCM and Google sign-in `debugPrint` payloads (`ADM-INS-10`) |
| HTTPS enforced | Default `KH_API_BASE` is `http://localhost:3000`; no prod check that the base is `https://` |
| KYC document open | Presentation fetches URL then `window.open` (`ADM-INS-48`); bearer-less `/v1/media/<key>` still a risk if signed URLs are not used |
| API keys in Dart | Google web client ID is in `web/index.html` **and** `firebase_auth_service.dart` (`kIsWeb ? '132845…' : null`). Expected for GIS, not a server secret. Firebase keys live in `firebase_options.dart` |
| Multi-tab logout | Not observed until 401 (`ADM-INS-85`) |
| Password login still on ADM-S01 | `loginWithPassword` + email/password form; `adr/0010` is Google-only (`ADM-INS-31` is SRS vs ADR conflict — keep password behind `KH_DEV_AUTOLOGIN` only) |

**Enhance (P0):** stop persisting tokens on `kIsWeb`; keep access in memory; re-auth on reload. Implement idle timer + warning dialog. Gate password login to the autologin define. Replace `debugPrint` with a logger that redacts `Authorization`, emails, mobiles. In production flavour, refuse non-HTTPS bases.

#### 3.3.10 Packages and dependencies — Partial

`flutter pub get` reported **41** packages with newer versions incompatible with current constraints. Notable majors behind: `flutter_riverpod` 2.6.1 (3.x available), `go_router` 14 (18 available), `flutter_secure_storage` 9 (11 available), `flutter_lints` 5 (6 available). Do not jump Riverpod 3 in the same slice as list-state unification.

`custom_lint` and `riverpod_lint` are in `dev_dependencies` and **not enabled** in `analysis_options.yaml` (`ADM-INS-15`).

`fl_chart` is justified by ADM-S17 but is eager-loaded (`ADM-INS-37`).

Firestore on a product whose constraint is **no secondary datastore** (`C-12`, `AD-FE-09`) is a policy smell, not just bundle weight. (Dead `FirestoreService` / `FirebaseAnalyticsService` deleted in simplification Tier-0; packages may still be in `pubspec.yaml`.)

**Enhance:** enable `custom_lint` + `riverpod_lint` now (cheap). Remove unused Firebase packages. Schedule a dedicated dependency-upgrade PR after list-state work. Do not add Redis/Kafka/Elasticsearch; do not keep Firestore “just in case.”

#### 3.3.11 Navigation and routing — Partial

One `GoRouter` with a shell and an auth `redirect` — good. Dialogs correctly use `Navigator.pop` (local overlay), not a second routing style.

Gaps (`ADM-INS-04`, `ADM-INS-33`, `ADM-INS-51`):

- Paths are magic strings (`'/vendors'`, `'/requests'`), duplicated in `kAdminNavItems` and `GoRoute` tables.
- `state.pathParameters['id'] ?? ''` — empty id still builds the detail screen.
- Query params (filters, cursor, selected id) wired only for vendors/requests/offers/verification/taxonomy; cursor/sort never encoded even there.
- Leftover `...kAdminNavItems.where(not registered) → _GenericPlaceholderScreen` existed only for gold rates; the exclusion list was a second source of truth. **FIXED** in simplification Tier-0 (`ADM-SMP-32` / `ADM-SMP-60`) by reading `isLive`.

**Enhance:** typed routes (`go_router` 14 still supports `GoRoute` + a `AdminRoutes` class of constants; typed routes package can wait). Reject empty `:id`. Encode cursor + selected id on every list. Replace the placeholder spread with a single explicit gold-rate route or hide the nav item.

#### 3.3.12 Error handling — Fail

| Framework hook | Present? |
|---|---|
| `FlutterError.onError` | No (`ADM-INS-12`) |
| `PlatformDispatcher.instance.onError` | No |
| `ErrorWidget.builder` (release) | No |
| `runZonedGuarded` / Crashlytics / Sentry | No |
| Riverpod `ProviderObserver` | No |

Login maps `ApiException` codes to ARB strings (with English fallbacks) — the best error UX in the app. List controllers do the opposite: `e.toString()`. Dashboard queues return `[]` on any throw (`ADM-INS-61`), so a down verification API looks like an empty queue. Firebase init failure is swallowed and the app still runs (`ADM-INS-86`).

**Enhance:** install global handlers in `main()` that log (redacted) and show `ErrorWidget` with a retry, not the red screen. Map `ApiException.code` in one helper used by every controller. Dashboard queues should carry a per-source error chip, not vanish. Fail closed on Firebase init if Google Sign-In is the only production login.

#### 3.3.13 Internationalization — Fail

`l10n.yaml` + `app_en.arb` / `app_ar.arb` + generated delegates in `MaterialApp.router` — setup is correct. Generated API has **412 keys** (359 getters + 53 parameterized); `app_ar.arb` has the same key set. Partial **call-site** use: login, dashboard, taxonomy, vendors, verification, offers, requests, reports — typically as `l10n?.key ?? 'English fallback'` rather than required `AppLocalizations.of(context)!`.

**No `AppLocalizations` import** in: customers, connections, abuse, audit, admin_users, announcements, moderation, settings, and `kh_admin_scaffold.dart` (nav titles are English constants: `'Dashboard'`, `'Gold Rates'`, `'Soon'`, `'Sign Out'`). Login still hardcodes `'Administrative Portal'` and `'Sign in with Google'` next to ARB fallbacks (`ADM-INS-02`). RTL physical alignments remain (`ADM-INS-03`). No hardcoded-string lint. Dates/times are not obviously Gulf Standard Time (`BR-021`) — device/local formatting plus `DateTime.now()` (`ADM-INS-07`).

**Enhance:** lint hardcoded strings (the mobile workspace already has this habit). Move shell, lists, and dialogs to ARB before adding more screens. Use `AlignmentDirectional` and `EdgeInsetsDirectional`. Format instants via server time + `Asia/Dubai` display.

#### 3.3.14 Dependency injection — Partial

Riverpod **is** the DI container. `ApiClient`, `TokenStorage`, repositories, and controllers are providers. Tests override them. That matches `AD-FE-03`.

Gaps: the only confirmed presentation→repository call is `verification_detail_pane.dart` `fetchDocumentUrl` (`ADM-INS-11`). Other screens go through controllers. `SessionController` still `new`s collaborators inside the provider rather than taking interfaces at the boundary (testable today via constructor — keep that). No flavour-specific provider graph (`dev`/`staging`/`prod`) (`ADM-INS-81`). Firestore/FCM/Analytics providers exist with no consumers. Repositories are concrete classes only (no `abstract` interfaces); Riverpod overrides still make them testable.

**Enhance:** presentation never reads a repository provider — only controllers. Environment via `--dart-define-from-file` (already the Architecture-Frontend rule). Do not add GetIt.

#### 3.3.15 Static analysis — Fail

Current `analysis_options.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml
analyzer:
  errors:
    invalid_annotation_target: ignore
    unused_element: ignore
```

Missing vs the checklist and Architecture-Frontend §19.2 (`ADM-INS-15`):

- `strict-casts`, `strict-inference`, `strict-raw-types`
- `always_use_package_imports`, `unawaited_futures`, `avoid_catches_without_on_clauses`, `prefer_final_locals` (explicit)
- hardcoded-strings / no-`DateTime.now()` lints named in Architecture-Frontend
- `custom_lint` plugin for `riverpod_lint`
- `unused_element: ignore` hides dead code (`ADM-SMP-33`)

A workspace `flutter analyze` reported **two kh_admin test warnings** and no `lib/` issues — because the config is too loose to see the problems in this review.

**Enhance:** copy the mobile package’s stricter analyzer as the baseline, then turn on one rule group per PR so the first strict pass is reviewable.

### 3.4 Suggested enhancements (`E1`–`E30`)

Grouped by payoff. Each item is a slice that can merge independently. Do not treat this as a rewrite of `Admin-App-Completion-Plan.md`.

#### P0 — correctness, security, user-visible failure

| # | Enhancement | Closes |
|---|---|---|
| E1 | Web: access token in memory only; do not persist refresh on `kIsWeb`; re-auth on reload | `ADM-INS-09` |
| E2 | 60-minute idle timeout + warning dialog; activity listener on pointer/keyboard | `ADM-INS-30` |
| E3 | Map `ApiException` in one helper; list controllers `on ApiException`; never `e.toString()` in UI | `ADM-INS-60` |
| E4 | Dashboard queue sources fail **closed** (error chip / retry), not `[]` | `ADM-INS-61` |
| E5 | `FlutterError.onError` + `PlatformDispatcher.onError` + release `ErrorWidget.builder` | `ADM-INS-12` |
| E6 | Redacting logger; delete payload `debugPrint` in FCM / Google sign-in | `ADM-INS-10` |
| E7 | Password form only when `KH_DEV_AUTOLOGIN`; production path is Google Sign-In (`adr/0010`) | `ADM-INS-31` (product), login UX |
| E8 | Hide or remove Gold Rates nav until ADM-S20; delete empty feature dirs | `ADM-INS-21`, `ADM-INS-51` |

#### P1 — architecture consistency (stops the recipe from forking further)

| # | Enhancement | Closes |
|---|---|---|
| E9 | Shared cursor-list kernel: sealed/`AsyncValue` state + controller + URL codec | `ADM-INS-19`, `ADM-INS-20`, `ADM-INS-23` |
| E10 | Strict `analysis_options.yaml` + enable `riverpod_lint` | `ADM-INS-15` |
| E11 | `package:kh_admin` imports in `lib/` | `ADM-INS-16` |
| E12 | Split god detail screens (request/offer/vendor/customer first) | `ADM-INS-22` |
| E13 | Virtualised `KhDataTable` + remove outer `SingleChildScrollView` | `ADM-INS-13`, `ADM-INS-70` |
| E14 | ARB-only user-visible strings for shell + remaining lists; directional insets | `ADM-INS-02`, `ADM-INS-03` |
| E15 | `MaskedParty` / `RevealedParty` (or import `kh_domain` once Melos includes this app) | `ADM-INS-06`, `ADM-INS-53` |
| E16 | `ApiClient` keeps `meta.serverTime`; injected clock; no `DateTime.now()` for ages | `ADM-INS-07` |
| E17 | Presentation never calls repositories (verification documents via controller) | `ADM-INS-11` |
| E18 | Request list widget test (empty/error/loading); then audit/dashboard/reports controllers and taxonomy repository | `ADM-INS-39` |

#### P2 — product completeness and operability

| # | Enhancement | Closes |
|---|---|---|
| E19 | URL-encode filters **and** cursor on every list | `ADM-INS-33` |
| E20 | Server-side filters (stop page-local `where`); coordinate with admin API gaps | `ADM-INS-34`, `ADM-INS-46` |
| E21 | Dashboard date range, trends, drill-down query | `ADM-INS-32` |
| E22 | Abuse actions: warn / suspend / deactivate | `ADM-INS-38` |
| E23 | Deferred imports for reports / audit / announcements; drop unused Firebase | `ADM-INS-37`, `ADM-INS-41`, `ADM-INS-42` |
| E24 | Semantics + 48 px targets + `SelectionArea` + in-app find | `ADM-INS-12`, `ADM-INS-36`, `ADM-INS-63` |
| E25 | LTR+RTL goldens at 100% and 200% text scale | `ADM-INS-01` |
| E26 | Flavours `dev`/`staging`/`prod`; HTTPS-only prod base; contract-version / 426 screen | `ADM-INS-81`, `ADM-INS-82` |
| E27 | FCM (or 30 s poll) invalidates list providers | `ADM-INS-08` |
| E28 | Integration_test login → dashboard → list → detail; first-load size budget in CI | `ADM-INS-80`, `ADM-INS-84` |
| E29 | Signed-URL KYC open; `cacheWidth` when thumbnails exist | `ADM-INS-48`, `ADM-INS-72` |
| E30 | Customer list access audit call (`FR-ADM-010` AC5) | `ADM-INS-40` |

### 3.5 Recommended first implementation slice

If only one PR follows the Flutter/Dart review, do **E3 + E5 + E10 + E18**: typed API errors in list controllers, global Flutter error hooks, strict analyzer (even if it takes a follow-up to clear new lints), and the missing request-list widget test. That slice does not change product scope, does not fight `AD-FE-12` (still `[BLOCKED]`), and makes every later screen inherit a safer default.

Do **not** mix E9 (list kernel) with a Riverpod 3 upgrade. Do **not** resolve `AD-FE-12` (buy vs build grid) inside a cleanup PR. Do **not** silently implement ADM-S20.

### 3.6 Flutter-checklist items folded into enhancements (no new `ADM-INS-*`)

This review does not add `ADM-INS-*` IDs. Flutter-checklist items that the register did not emphasise, treated here as enhancements rather than new IDs:

| Checklist item | Treatment |
|---|---|
| `Future.microtask(refresh)` in `Notifier.build()` | Fold into E9 (`AsyncNotifier`) |
| Mixed `StateNotifier` / `Notifier` / `AsyncNotifier` | Fold into E9 |
| `ApiClient.get` → `dynamic` | Fold into `AD-FE-06` / typed `get<T>` |
| Deprecated `dart:html` | Fold into E8/platform cleanup |
| `cupertino_icons` unused | Fold into E23 |
| Test-only analyzer warnings | Fold into E10 |
| `ProviderObserver` absent | Fold into E5 |
| `buttonHeight: 36` / `tableRowHeight: 44` | Fold into E24 (`ADM-INS-63`) |

Reserved register slots (`ADM-INS-24`–`29`, `49`, `54`–`59`, `64`–`69`, `74`–`79`, `88`–`89`) stay reserved. If Product wants these Flutter-engine notes in the register, mint there — not here.

---

## 4. Simplification review

Scope: all of `apps/kh_admin/lib` — 191 Dart files, ~53,300 lines. Finding prefix `ADM-SMP-nn` — stable, **never reused**. This pass asks *what does the code make harder than it needs to be?* — reuse, simplification, efficiency and altitude only. It does **not** hunt correctness bugs.

Four independent reviews of `lib/`, with every claim re-verified against the source before entry. Findings that could not be reproduced were dropped. Two claims were corrected during verification (§4.8).

| Range | Axis |
|---|---|
| `ADM-SMP-01`–`19` | Reuse |
| `ADM-SMP-20`–`39` | Simplification |
| `ADM-SMP-40`–`59` | Efficiency |
| `ADM-SMP-60`–`79` | Altitude |

**Status:** `FIXED` applied in this pass · `PART` partly applied · `OPEN` documented only.

**Counts:** 13 reuse · 14 simplification · 7 efficiency · 6 altitude = **40 findings**, of which **9 are fixed** and 1 partly fixed in this pass.

### 4.1 Register

#### Reuse (`01`–`19`)

| ID | Status | Title | Primary evidence | Cites |
|---|---|---|---|---|
| **ADM-SMP-01** | OPEN | `kh_admin` forks `kh_core` / `kh_design_system` as a **regressed subset** | `lib/core/api/api_client.dart` vs `packages/kh_core/lib/src/api_client.dart` | ADM-INS-53 |
| **ADM-SMP-02** | FIXED | `hasMore` derived by the same 1-line expression in **9** repositories | 9 × `*_repository.dart` | ADM-INS-20 |
| **ADM-SMP-03** | FIXED | `_asMap` / `_toDouble` byte-identical in 2 repos, inlined in a 3rd | `connection_repository.dart:241`, `offer_repository.dart:305` | ADM-INS-52 |
| **ADM-SMP-04** | OPEN | Nested `user` / `profile` flattening re-derived in **6** repos | `customer:59`, `vendor:62`, `connection:123`, `offer:120`, `verification:57`, `admin_user:70` | ADM-INS-52 |
| **ADM-SMP-05** | OPEN | Single-entity unwrap uses a different **sentinel field** per feature | `admin_user:70` (`id`/`profile`/`user`), `announcement:106` (`titleEn`), `settings:78` (`key`), `reports:132` (`name`) | ADM-INS-52 |
| **ADM-SMP-06** | FIXED | `_stringMapsEqual` byte-identical in 3 router files | `offer:177`, `request:161`, `vendor:101` | ADM-INS-20 |
| **ADM-SMP-07** | PART | Query-param navigation boilerplate repeated in 5 files | `lib/core/router/*_query_params.dart` | ADM-INS-33 |
| **ADM-SMP-08** | OPEN | Feedback banner written 3× with divergent visuals | `customer_detail:222`, `request_detail:248`, `vendor_detail:178` | — |
| **ADM-SMP-09** | OPEN | `_buildStatTile` hand-rolls a metric tile beside a real `KhMetricCard` | `announcements_screen.dart:312` | — |
| **ADM-SMP-10** | OPEN | 3 repos bypass `ApiClient.getCollection` and unwrap by hand | `verification:20`, `taxonomy`, `reports` | — |
| **ADM-SMP-11** | OPEN | The label/value row primitive is invented **5 times under 5 names** | `_buildDetailRow` (request), `_DetailRow` (offer), `_buildFieldRow` (vendor:260), `_buildInfoRow` (customer:330), inline (connection) | ADM-INS-22 |
| **ADM-SMP-12** | OPEN | No shared detail-card scaffold; the same `Container`+`BoxDecoration` literal appears 8× in one file | `request_detail_screen.dart` | ADM-INS-22 |
| **ADM-SMP-13** | FIXED | 350 ms debounce `Timer` plumbing duplicated across **9** list screens | 9 × `*_screen.dart` | ADM-INS-23 |

#### Simplification (`20`–`39`)

| ID | Status | Title | Primary evidence | Cites |
|---|---|---|---|---|
| **ADM-SMP-20** | OPEN | **6** cursor-list controllers ~85% byte-identical (~900 duplicated lines) | vendors / requests / offers / customers / connections / audit | ADM-INS-19, ADM-INS-20 |
| **ADM-SMP-21** | OPEN | **4** more list controllers on a *second*, incompatible `StateNotifier` idiom | abuse / moderation / announcements / admin_users | ADM-INS-20 |
| **ADM-SMP-22** | OPEN | 11 filter models split across **three** `copyWith`-clear idioms | `@freezed` (3) · `bool clearX` (7) · `T? Function()?` (`customer_list_filters.dart:13`) | ADM-INS-05 |
| **ADM-SMP-23** | OPEN | 4 filter models define no `==` / `hashCode`, so equality-based rebuild-skipping cannot work | abuse / moderation / announcement / report filters | — |
| **ADM-SMP-24** | OPEN | `hasMore` is **stored state derivable from `nextCursor`**, then re-derived again in `canLoadMore` | 9 page DTOs + 10 controller states | — |
| **ADM-SMP-25** | OPEN | 11 near-identical `XxxListPage` envelopes instead of one `Paginated<T>` | `*_list_page.dart` | ADM-INS-20 |
| **ADM-SMP-26** | OPEN | **19** presentation files exceed 400 lines, totalling 19,132 — ~36% of `lib/` | `request_detail` 1484 · `offer_detail` 1388 · `announcements` 1210 | ADM-INS-22 |
| **ADM-SMP-27** | OPEN | `_ComposeAnnouncementDialog` (~440 lines) lives at the end of another screen's file | `announcements_screen.dart:774-1210` | ADM-INS-22 |
| **ADM-SMP-28** | FIXED | `dynamic kh` on 35 helper signatures defeats type checking on the theme | request / vendor / connection detail screens | — |
| **ADM-SMP-29** | OPEN | `admin_users` fetches the **entire** dataset and filters client-side — no cursor at all | `admin_user_controller.dart:88` | ADM-INS-46 |
| **ADM-SMP-30** | FIXED | `FirestoreService` + `FirebaseAnalyticsService` dead — zero references in `lib/` or `test/` | `lib/core/firebase/` | ADM-INS-41, ADM-INS-42 |
| **ADM-SMP-31** | OPEN | `gold_rate/` (4 dirs) and `auth/{controller,model,repository}` are `.gitkeep`-only shells | `lib/features/` | ADM-INS-21 |
| **ADM-SMP-32** | FIXED | Router placeholder exclusion list = 18 lines restating a flag that already exists | `app_router.dart:205` | ADM-INS-51 |
| **ADM-SMP-33** | OPEN | `unused_element: ignore` suppresses the lint that would have caught `ADM-SMP-30` | `analysis_options.yaml:14` | ADM-INS-15 |

#### Efficiency (`40`–`59`)

| ID | Status | Title | Primary evidence | Cites |
|---|---|---|---|---|
| **ADM-SMP-40** | OPEN | `KhDataTable` builds **every** row into a `Column` — no lazy path at any page size | `kh_data_table.dart:73-81` | ADM-INS-13 |
| **ADM-SMP-41** | OPEN | 12 list screens nest that table inside a **second** `SingleChildScrollView` | see §4.4 | ADM-INS-70 |
| **ADM-SMP-42** | OPEN | **Zero** `.select(` calls in 191 files — every screen watches whole controller state | 16 screens | ADM-INS-73 |
| **ADM-SMP-43** | FIXED | `DateFormat` / `NumberFormat` constructed per `build()`, up to 8× in one frame | `request_detail_screen.dart` (8 sites) | — |
| **ADM-SMP-44** | FIXED | Export poll: flat 400 ms × 40 attempts, no backoff | `reports_repository.dart:24` | ADM-INS-71 |
| **ADM-SMP-45** | OPEN | `fl_chart` eagerly imported for one screen; no `deferred as` | `report_chart.dart:1` | ADM-INS-37 |
| **ADM-SMP-46** | OPEN | `Firebase.initializeApp` blocks the first frame | `main.dart:16` | ADM-INS-86 |

#### Altitude (`60`–`79`)

| ID | Status | Title | Deeper change | Cites |
|---|---|---|---|---|
| **ADM-SMP-60** | FIXED | Nav liveness had **two sources of truth** | Read the `isLive` flag that already exists | ADM-INS-51 |
| **ADM-SMP-61** | OPEN | No list kernel — every feature re-implements paginate+filter+search | One `CursorPaginatedNotifier<TItem, TFilters>`; `kh_core` already ships `PagedListController` (365 L) | ADM-INS-20 |
| **ADM-SMP-62** | OPEN | No shared response normaliser — repos each re-derive the envelope shape | Fix the double-wrap in `ApiClient._send`, as `getCollection` already does for lists | ADM-INS-52 |
| **ADM-SMP-63** | OPEN | No query-params codec, so **8 of 13** list screens have no URL state at all | One `QueryParamsCodec<T>` + the shared navigation extension | ADM-INS-33 |
| **ADM-SMP-64** | OPEN | `taxonomy` / `verification` **never clear** the query string — see §4.6 | Adopt the shared navigation extension | ADM-INS-62 |
| **ADM-SMP-65** | OPEN | `kh_admin` is outside the shared package graph, so fixes cannot propagate either way | Add the `path:` deps `kh_mobile` already uses | ADM-INS-53 |

### 4.2 Reuse

#### The fork is the expensive one (`ADM-SMP-01`, `ADM-SMP-65`)

`packages/` already contains `kh_core`, `kh_domain`, `kh_api`, `kh_design_system`, `kh_l10n` and `kh_ui_domain`. `apps/kh_mobile/karat_hive/pubspec.yaml` consumes all six via `path:` deps. `apps/kh_admin/pubspec.yaml` consumes **none** — it depends on `dio`, `flutter_riverpod` and `go_router` directly and rebuilds the shared layer:

| Concept | `kh_admin` | `packages/` | Difference |
|---|---|---|---|
| HTTP client | `lib/core/api/api_client.dart` | `kh_core/src/api_client.dart` (258 L) | admin lacks correlation-id + idempotency-key headers and server-clock sync |
| Error model | `ApiException` — one flat class with a `code` string | `kh_core/src/failure.dart` — sealed `Failure` hierarchy | admin cannot pattern-match on failure kind |
| Token storage | `lib/core/auth/token_storage.dart` | `kh_core/src/token_storage.dart` (64 L) | admin keeps expiries as raw strings, `kh_core` parses to `DateTime` |
| Paged list | 13 hand-rolled controllers | `kh_core/src/paged_list_controller.dart` (365 L) | generic, with cursor-cycle detection and dedup by key |
| Status chip | `KhStatusChip` (5 tones) | `KhStatusChip` (6 tones) | **same class name**, incompatible tone enums |

This is not simply duplication — the admin copy is a **regressed subset**. A fix landed in `kh_core` (a refresh race, a missing header) does not reach the admin portal, and vice versa. Everything else in this document is downstream of it.

#### Repository normalisation (`ADM-SMP-02`–`05`, `ADM-SMP-10`)

`ApiClient.getCollection` already unwraps the list envelope centrally, including the documented pre-`ADM-C-70` double-wrap fallback. That knowledge stops at the boundary: `getCollection` returns a raw `meta` map, so all **9** paginated repos then wrote the same line —

```dart
final hasMore = nextCursor != null && nextCursor.isNotEmpty;
```

— and for **single** entities, five repos each invented a different sentinel field to decide whether a residual `data` wrapper is present (`id`/`profile`/`user`, `titleEn`, `key`, `name`). Five independent heuristics that must each be re-checked whenever the backend envelope moves.

`ADM-SMP-02`/`03` are now shared via `lib/core/api/json_parse.dart`. `ADM-SMP-04`/`05`/`10` remain.

#### The other duplications

`ADM-SMP-11` is the sharpest small example: the same "label on the left, value on the right" row is implemented five times under five names — `_buildDetailRow`, `_DetailRow`, `_buildFieldRow`, `_buildInfoRow`, and inline. Two of the five are widget classes, three are methods.

`ADM-SMP-08` — three feedback banners with divergent padding, alpha (0.10 vs 0.12), border alpha, icon style (outline vs filled), text weight and dismissibility. Merging them picks a winner visually on at least two screens, and each carries a test-facing `Key`. Design decision, not cleanup.

`ADM-SMP-09` — announcements invents `_buildStatTile` next to a real `KhMetricCard`.

`ADM-SMP-12` — no shared detail-card scaffold; the same `Container`+`BoxDecoration` literal appears 8× in `request_detail_screen.dart`.

### 4.3 Simplification

#### Two competing list idioms, neither shared (`ADM-SMP-20`, `ADM-SMP-21`)

Ten list controllers, ~1,784 lines, split into two families that solve the same problem differently:

| | Family A — cursor + prev/next | Family B — `StateNotifier`, infinite only |
|---|---|---|
| Members | vendors, requests, offers, customers, connections, audit | abuse, moderation, announcements, admin_users |
| State | `@freezed` (3) / hand-written (3) | hand-written (4) |
| Paging | `refresh`/`loadMore`/`nextPage`/`previousPage` + `cursorHistory` | `loadInitial`/`loadMore` only |

`vendor_list_controller.dart` vs `offer_list_controller.dart` differ in **26 of 174 lines**; `abuse_controller.dart` vs `moderation_controller.dart` in 54 of 183. The drift is already visible: `audit` has no `totalCount`, `customer` has no `totalCount`, and `admin_users` has no pagination at all (`ADM-SMP-29`).

**The codebase already knows the better idiom.** All five *detail* controllers use `FamilyAsyncNotifier` + `AsyncValue` with no hand-rolled loading flags. Only the list side never adopted it.

#### Derivable state (`ADM-SMP-24`)

`hasMore` is computed from `nextCursor` in the repository, **stored** in the page DTO, **stored again** in controller state, then re-derived a third time:

```dart
bool get canLoadMore {
  if (hasMore == false) return false;
  final cursor = nextCursor;
  return cursor != null && cursor.isNotEmpty;   // the same test again
}
```

It is also typed `bool?` in five controllers and `bool` in the other five. `copyWith` can move `hasMore` without `nextCursor`, so the two can desync. Deleting the field in favour of one getter on `nextCursor` removes a field from 9 DTOs and 10 states and makes the desync unrepresentable.

#### Filter-model drift (`ADM-SMP-22`, `ADM-SMP-23`)

11 filter models, three `copyWith`-clear idioms: `@freezed` (3), `bool clearX` (7), `T? Function()?` (`customer_list_filters.dart`). Four of them (abuse / moderation / announcement / report) define no `==` / `hashCode`, so equality-based rebuild-skipping cannot work.

#### Presentation weight (`ADM-SMP-26`, `ADM-SMP-27`)

19 files over 400 lines, 19,132 lines total — roughly **36% of `lib/`** is screen code, and the three largest are detail screens whose per-card scaffolding is copy-pasted (`ADM-SMP-12`). `announcements_screen.dart` additionally carries a whole second feature — a ~440-line compose dialog — larger than most complete list screens.

### 4.4 Efficiency

#### Table rendering (`ADM-SMP-40`, `ADM-SMP-41`)

`kh_data_table.dart:73-81` builds every row eagerly:

```dart
child: Column(
  children: [
    _headerRow(context),
    for (var i = 0; i < rows.length; i++)
      _bodyRow(context, rows[i], isLast: i == rows.length - 1),
  ],
),
```

There is no `ListView.builder` path at any page size. This is currently masked by a default page size of 20 (`request_repository.dart:15`) — the widget itself has no ceiling. On top of that, all 12 screens that host the table wrap it in an outer `SingleChildScrollView` while the table runs its own scroll view internally (`kh_data_table.dart:69`), so every list screen pays two nested scroll/layout passes per frame:

`request_list` · `vendor_list` · `offer_list` · `announcements` · `platform_settings` · `admin_users` · `moderation` · `abuse` · `audit` · `connection_list` · `customer_list` · `reports`

Both are blocked behind `AD-FE-12` (admin data grid — build or buy), which is still an open decision.

#### Watch granularity (`ADM-SMP-42`)

`grep -rn "\.select(" lib/` returns **0** across 191 files. `RequestListState` bundles 10 independent fields; flipping `isLoadingMore` during `nextPage()` rebuilds the whole screen subtree including the table, even though `items` did not change.

#### Remaining efficiency items

- `ADM-SMP-43` FIXED — 4 shared formatter instances in `lib/core/format/kh_formats.dart`.
- `ADM-SMP-44` FIXED — export poll now doubling backoff capped at 2 s, 12 attempts (~21 s of patience across 12 requests; old flat interval spent 40 to cover ~16 s). A zero interval still disables waiting, so tests are unaffected.
- `ADM-SMP-45` OPEN — `fl_chart` eagerly imported; `deferred as` changes web load semantics and wants a measured before/after.
- `ADM-SMP-46` OPEN — `Firebase.initializeApp` blocks the first frame.

### 4.5 Altitude

Ranked by how much else each one would remove:

1. **`ADM-SMP-65` — rejoin the package graph.** Wiring is cheap (`path:` deps, as `kh_mobile` already does); migration is not. But it dissolves `ADM-SMP-01` and much of `61`/`62`.
2. **`ADM-SMP-61` — one list kernel.** Collapses `ADM-SMP-20`, `21`, `24`, `25` and most of `13`. `kh_core/paged_list_controller.dart` already exists.
3. **`ADM-SMP-62` — normalise once, at the client.** If `_send` resolved the double-wrap the way `getCollection` already does for lists, `ADM-SMP-02`–`05` and `10` stop existing.
4. **`ADM-SMP-63` — a query-params codec.** The reason 8 of 13 list screens have no URL state is that adopting the pattern costs a bespoke ~150-line file per feature.
5. **`ADM-SMP-60` — fixed.** The pattern to notice: the router restated a fact the nav table already held. Special-casing on top of shared infrastructure is the smell; reading the existing flag is the fix.

### 4.6 Behavioural divergence found (not fixed) — `ADM-SMP-64`

Verified empirically while unifying the query-param helpers, and worth a decision:

```dart
// taxonomy_query_params.dart:66, verification_query_params.dart:54
final newUri = state.uri.replace(
  queryParameters: updated.toQueryParameters().isEmpty
      ? null                                   // <-- keeps the OLD query
      : updated.toQueryParameters(),
);
```

`Uri.replace(queryParameters: null)` **preserves** the existing query rather than clearing it:

```text
/taxonomy/categories?selectedId=abc&showInactive=true
  .replace(queryParameters: null)      -> /taxonomy/categories?selectedId=abc&showInactive=true
  .replace(queryParameters: const {})  -> /taxonomy/categories?
```

So on those two screens, clearing the last filter does not clear the URL. The other three files (`offer`, `request`, `vendor`) pass `const <String, String>{}` and clear correctly.

**Not fixed here** — this is a behaviour change, outside a quality pass's remit, and it wants a regression test alongside it. The shared `applyQueryParameters` extension added in this pass already has the correct semantics, so the fix is to migrate those two files onto it.

### 4.7 Applied in this pass (Tier 0)

31 files changed, **387 deletions against 172 insertions**, plus 137 lines of new shared code. Analyzer and tests unchanged from baseline throughout.

| ID | Change | Effect |
|---|---|---|
| `ADM-SMP-32` `60` | `app_router.dart`: 18-line route-exclusion chain → `.where((item) => !item.isLive)` | −18 lines; one source of truth. The 16 excluded paths exactly matched the 16 `isLive: true` items, and *Gold Rates* remains the only placeholder |
| `ADM-SMP-30` | Deleted `firestore_service.dart` (45 L) and `firebase_analytics_service.dart` (54 L); trimmed the barrel | −99 lines. `FirestoreService` also contradicted `C-12` / `AD-FE-09` (no secondary datastore). `FirebaseNotificationService` **kept** — `main.dart:19` needs its background handler |
| `ADM-SMP-06` `07` | New `lib/core/router/query_navigation.dart` — one `applyQueryParameters` extension + one `stringMapsEqual` | 3 copies of the helper and 3 copies of the try/catch collapsed to one |
| `ADM-SMP-02` `03` | New `lib/core/api/json_parse.dart` — `asMap`, `toDouble`, `toDoubleOrNull`, `hasMoreFromCursor` | 9 repos share the cursor derivation; 3 share the coercion helpers |
| `ADM-SMP-43` | New `lib/core/format/kh_formats.dart` — 4 shared formatter instances | Removes up to 8 formatter allocations per frame on the request detail screen |
| `ADM-SMP-13` | New `lib/core/widgets/debounced_search_mixin.dart` | 9 screens lose their `Timer` field, `dispose` cancel and timer plumbing. `admin_users`' 300 ms is preserved by overriding `searchDebounceDuration` |
| `ADM-SMP-28` | `dynamic kh` → `KhThemeExtension kh` on 35 signatures | Restores type checking on every theme access in the three worst detail screens; compiled with no type errors, proving the annotations were already correct |
| `ADM-SMP-44` | Export poll: flat 400 ms × 40 → doubling backoff capped at 2 s, 12 attempts | ~21 s of patience across **12** requests, where the old flat interval spent **40** to cover ~16 s. A zero interval still disables waiting, so tests are unaffected |

#### Deliberately not applied

| ID | Why |
|---|---|
| `ADM-SMP-08` | The three banners differ in padding, alpha (0.10 vs 0.12), border alpha, icon style (outline vs filled), text weight and dismissibility. Merging them **picks a winner visually** on at least two screens, and each carries a test-facing `Key`. That is a design decision, not a cleanup |
| `ADM-SMP-64` | A behaviour change; wants a regression test (see §4.6) |
| `ADM-SMP-01` `65` | Cross-package migration — needs sign-off |
| `ADM-SMP-61` `62` `63` | Structural; ~900 lines of controller logic and 11 DTOs |
| `ADM-SMP-40` `41` | Blocked behind `AD-FE-12`; changes scroll semantics |
| `ADM-SMP-45` `46` | `deferred as` changes web load semantics — wants a measured before/after |
| `ADM-SMP-31` | `gold_rate/` is a real deferred screen (ADM-S20), not litter; deleting its shell is a planning decision |
| `ADM-SMP-22` `26` `27` | Already owned by `ADM-INS-05` / `ADM-INS-22` |

### 4.8 Corrections made during this pass

Two claims did not survive verification and are recorded so they are not re-derived:

| Claim | Correction |
|---|---|
| "`lib/` has no empty directories, so `ADM-INS-21` is stale" | **Wrong.** `find -type d -empty` misses them because each holds a `.gitkeep`. The `gold_rate/` and `auth/` shells are real — `ADM-INS-21` stands, and is re-registered here as `ADM-SMP-31` |
| "`FirebaseNotificationService` is unused and can be deleted with its siblings" | **Wrong.** The class has no external references, but `main.dart:19` uses the file's free function `firebaseMessagingBackgroundHandler`. The file is kept |

### 4.9 Simplification verification

```bash
cd apps/kh_admin
flutter analyze --no-fatal-infos    # 3 issues, all pre-existing, all in test/
flutter test                        # 352 tests, all passing
flutter run -d chrome --dart-define=KH_API_BASE=http://localhost:3000
```

Both were run before and after the Tier-0 fixes with identical results — 3 analyzer issues (`announcements_screen_test.dart:9`, `platform_settings_controller_test.dart:11,13`, none in `lib/`) and 352 passing tests.

Manual checks worth doing before merge:

| Change | Check |
|---|---|
| `ADM-SMP-32` | Every sidebar entry routes to its real screen; only *Gold Rates* shows the placeholder |
| `ADM-SMP-13` | Type into search on each of the 9 list screens — one request after the pause, not one per keystroke; `admin_users` still at 300 ms |
| `ADM-SMP-44` | Run an export and confirm it still completes; the first re-check is 400 ms, later ones stretch to 2 s |
| `ADM-SMP-28` `43` | Request and vendor detail screens render unchanged |

Per the standing responsive rule for `kh_admin`, spot-check one list screen and one detail screen at both a narrow and a wide viewport. `test/responsive/admin_responsive_test.dart` covers phone through desktop and passes.

---

## 5. Unified picture — what is already true, what is still open

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
