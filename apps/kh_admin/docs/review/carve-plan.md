# Surface doc sets — carve plan

| | |
|---|---|
| **HEAD** | `8880298` · 8 September 2026 |
| **Status** | Proposal under review. **Not the plan of record.** Nothing executed. |
| **Index** | [`README.md`](README.md) · admin analysis in [`admin-content-filter.md`](admin-content-filter.md) |

---

## 1. Context

Every specification in this repo lives in one flat `docs/` folder covering all four surfaces
at once. The per-surface material is scattered inside the shared documents — admin FRs at
SRS 1184–1644, admin screens at 2791–2818, admin routes at inventory 664–723 *and*
1694–1991 — so scoping to one surface is an archaeology pass every time.

The goal: a developer or an agent session scoped to one folder has what that surface needs
without opening repo-wide `docs/`. Four surfaces multiply the problem the naive way, so
shared material is carved **once** into `docs/core/` and each surface set holds only its own
content plus links into core.

Authority stays with the originals. Everything carved is derived and says so.

Two structural facts shape the layout, both verified against the tree:

- **Customer and Vendor are not separate apps.** One dual-mode binary at
  `apps/kh_mobile/karat_hive/` (`C-08`, `C-10`), backed by six shared packages in
  `packages/`. They get one mobile doc set with two mode subfolders.
- **Backend is different in kind.** `Architecture-Backend.md`, `Async-Contract.md`,
  `Physical-Data-Model.md`, `Backend-Implementation-Plan.md`, `Backend-Gap-Fix-Plan.md`,
  `Backend-Gap-Tasks.md`, `backend_code_review_and_gap_report.md` and
  `Template-Lock-Review-Plan.md` — 4,192 lines — are *already* backend-only. That set is
  largely a re-home and an index, not an extraction.

---

## 2. Method — three pieces (`SDC-06`)

A skill alone does this badly, because the expensive part is not the first carve. It is
re-syncing four derived sets when `Requirements-Spec-v1.3` is superseded by v1.4 and every
line number shifts. A skill carries no state between runs, so it cannot know what went stale.

| Piece | Path | Holds | Why separate |
|---|---|---|---|
| **Skill** | `.claude/skills/carve-surface-docs/SKILL.md` | The *judgment* — classification rules, file taxonomy, derived-from header, house rules | Stateless between runs |
| **Manifest** | `docs/surface-map.md` | The *state* — which source section belongs to which surface, plus last-synced SHAs | Line numbers die on a version bump; this anchors by `§4.3` / `FR-ADM-*` / heading text |
| **Script** | `scripts/check-surface-docs.mjs` | The *mechanical checks* — ID coverage, link resolution, staleness | Extraction needs judgment; verification does not, and belongs in CI |

### 2.1 The skill

Invoked `/carve-surface-docs <surface>`, surface ∈ `admin | customer | vendor | backend | core`.
It encodes:

1. **Classification rule.** Every section of every source is ADMIN-ONLY / MOBILE-ONLY /
   BACKEND-ONLY / CORE / EXCLUDED. Ambiguity resolves toward **core** — duplicated content
   is the failure mode being avoided.
2. **File taxonomy** — the `00`–`08` numbering in §4, stable across surfaces so
   `02-*-API-Contract.md` means the same thing everywhere.
3. **Derived-from header**, mandatory on every generated file:
   ```markdown
   > **Derived**, not authoritative. Source: `docs/API-Route-Inventory.md` §21.
   > If this file and the source disagree, **the source wins**.
   > Last synced: 2026-09-08 · source commit: `8880298`
   ```
4. **House rules lifted from root `CLAUDE.md`** — never cite an ID without verifying it
   exists and means what you think; honour the `_Avoid_` lists in `CONTEXT.md`; tables over
   prose; cite requirements rather than restating them.
5. **Anchoring rule** — reference sources by section number, heading text or identifier.
   **Never by line number.**

### 2.2 The manifest

One table per source document:

| Source | Anchor | Surface | Target |
|---|---|---|---|
| `Requirements-Spec-v1.3.md` | §4.1 `FR-CUS-001…034` | customer | `customer/01-Customer-Requirements.md` |
| `Requirements-Spec-v1.3.md` | §4.3 `FR-ADM-001…033` | admin | `01-Admin-Requirements.md` |
| `Requirements-Spec-v1.3.md` | §5.1 `BR-001…022` | core | `core/03-Cross-Cutting-Requirements.md` |
| `API-Route-Inventory.md` | §3.2 Envelope | core | `core/02-API-Conventions.md` |
| `API-Route-Inventory.md` | §21 (all subsections) | admin | `02-Admin-API-Contract.md` |
| `Architecture-Frontend.md` | §16 Admin Portal on Flutter Web | admin | `03-Frontend-Architecture.md` |

Plus a `last_synced_sha` per source. A source whose current SHA differs from the recorded
one has stale derivatives — which is what the script reports.

### 2.3 The check script

Read-only, Node, no dependencies, CI-friendly:

- **ID coverage** — every `FR-CUS-nnn`, `FR-VEN-nnn`, `FR-ADM-nnn`, `FR-SYS-nnn`, `BR-nnn`,
  `NFR-nnn`, `C-nn`, screen ID and `AD-*` decision appears in exactly the set(s) the
  manifest assigns it. Targets: **34 / 31 / 33 / 12** FRs, **67** screens.
- **No invented IDs** — every ID cited in a derived file exists in some source. The check
  that matters most; root `CLAUDE.md` calls out how easily `FR-CUS-006` and `FR-CUS-007`
  transpose.
- **Link resolution** — every relative link resolves, including `../../../docs/core/`
  back-references.
- **Staleness** — source SHA vs manifest `last_synced_sha`; non-zero exit when a source has
  moved ahead of its derivatives.

---

## 3. `docs/core/` — carved once, ~2,400 lines (`SDC-05`)

| File | Built from |
|---|---|
| `README.md` | New — index, and the rule that core is derived while `docs/` wins |
| `01-Glossary-and-Invariants.md` | `CONTEXT.md` whole (131) · root `CLAUDE.md` domain invariants, identifier systems, status tags, fixed stack, live open decisions · SRS §1.3 conventions, §2.5 `C-01…C-13` |
| `02-API-Conventions.md` | Inventory §2 `AD-API-01…13`, §3.2 envelope, §3.3 idempotency, §3.4 auth, §3.7 status, §4.1–4.3 aliases/enums/pagination, §5.1–5.3 errors · Arch-Backend §13.2–13.6, §14.1/14.2/14.4 |
| `03-Cross-Cutting-Requirements.md` | SRS §3.4 permissions matrix · `FR-SYS-001…012` · `BR-001…022` · the NFR set · masking pipeline (Arch-Backend §9.1–9.5) |
| `04-Entity-Dictionary.md` | SRS §6.1 ERD + §6.2 all entities + §5.2–5.5 state machines · `Physical-Data-Model.md` §1 conventions, §3 ownership, §5 DB-enforced rules, §10 RLS posture |
| `05-Design-Tokens.md` | Design Context palette / M3 / shape / borders / typography / status / empty / loading / responsive / RTL / a11y / spacing / buttons / dialogs / copywriting · `component-widgets.md` full `SH-*` catalogue |
| `06-ADRs.md` | **Index only** — one line per `adr/0001`–`0010` with a link. They are already short, single-decision files in the right place; copying would restate, not clarify |

---

## 4. Surface layouts

### 4.1 `apps/kh_admin/docs/` — 10 files + 24 screens

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

### 4.2 `apps/kh_mobile/karat_hive/docs/` — 6 shared + two mode folders (`SDC-04`)

```
README.md · 00-Product-Context.md · 02-Mobile-API-Contract.md · 03-Frontend-Architecture.md
04-Data-Model.md · 05-UI-Design.md
customer/  01-Customer-Requirements.md (FR-CUS-001…034) · 07-Task-Register.md · screens/ (22+README)
vendor/    01-Vendor-Requirements.md   (FR-VEN-001…031) · 06-Completion-Plan.md
           07-Task-Register.md · screens/ (22+README)
```

The six shared files are genuinely shared — one binary, one router, one design system, one
API client. `05-UI-Design.md` is the largest single carve in the project: most of the
3,035-line Design Context is customer/vendor motion and composition rules. Mode-folder
sources: `Vendor-App-Completion-Plan.md`, `Vendor-App-Completion-Tasks.md`,
`checkpoints/checkpoint-customer-mode-tasks.md`.

### 4.3 `backend/docs/` — 10 files, mostly moves

`README.md` · `00-Product-Context.md` · `01-Backend-Requirements.md` (module-indexed view of
the server-side acceptance criteria across all three actor FR sets) · `02-API-Contract.md`
(module-indexed index into the route inventory) · `03-Architecture.md` ←
`Architecture-Backend.md` · `04-Data-Model.md` ← `Physical-Data-Model.md` ·
`05-Async-Contract.md` ← `Async-Contract.md` · `06-Implementation-Plan.md` ←
`Backend-Implementation-Plan.md` · `07-Task-Register.md` ← `Backend-Gap-Tasks.md` +
`Backend-Gap-Fix-Plan.md` · `08-Review-and-Gaps.md` ← `backend_code_review_and_gap_report.md`
+ `Template-Lock-Review-Plan.md`.

### 4.4 Per-surface `CLAUDE.md`

Each surface root gets a short `CLAUDE.md`: read order, the identifier prefixes that session
will meet, the run command, and the rule that root `docs/` stays authoritative.

**Total: ~115 files** (core 7 · admin 35 · mobile 58 · backend 11 · skill · manifest ·
script) against ~13,600 lines of existing specification.

---

## 5. Execution order

Five phases, each independently shippable.

| Phase | Work | Gate |
|---|---|---|
| **1. Core** | Carve `docs/core/` (7 files) | Everything links to it, so it settles first |
| **2. Admin pilot** | The 35-file admin set, by hand | Already fully analysed; proves the taxonomy against a real surface |
| **3. Tooling** | Write skill, manifest, check script; run against core + admin and fix what it finds | Script green on two sets |
| **4. Mobile** | `/carve-surface-docs customer`, then `vendor` (58 files) | Largest surface; the skill earns its cost here |
| **5. Backend** | `/carve-surface-docs backend` (11 files) | Mostly `git mv` + redirect stubs |

### `SDC-08` — the skill is authored third, not first

**Open for confirmation.** A skill written from one completed real carve will be
substantially better than one written from a guess about it. The admin surface is already
fully inventoried (see [`admin-content-filter.md`](admin-content-filter.md)), so it is a
free pilot. Reordering to put the skill first is possible but produces a worse skill.

### `SDC-07` — move vs copy

**Open for confirmation.** Documents that are surface-only **and referenced by nothing
else** should be *moved* with a one-line redirect stub, not copied — two live copies of a
tick list drift within a day.

Verified safe to move: the four admin documents (`Admin-App-Completion-Plan.md`,
`Admin-App-Completion-Tasks.md`, `Admin-Backend-Followup-Tasks.md`,
`admin-backend-api-gaps.md` — their only inbound links are to each other), the vendor and
customer task documents, and the seven backend documents.

Stub shape:

```markdown
# Admin App Completion — Plan of Record
Moved to [`apps/kh_admin/docs/06-Completion-Plan.md`](../apps/kh_admin/docs/06-Completion-Plan.md).
```

Everything else — the four shared specs, `ui-screens/`, `CONTEXT.md` — stays put and is the
authority.

---

## 6. Files touched

**Created** — ~115, per §3 and §4.

**Modified** — redirect stubs at moved paths; the authority-chain table in root `CLAUDE.md`
gains rows for `docs/core/` and the surface sets.

**Untouched** — the four shared specs, `ui-screens/`, `ui-mock/`, `docs/old/`,
`Requirements-raw.txt`, and all application code. No Dart or TypeScript changes.

Note: `Admin-App-Completion-Plan.md`, `Admin-App-Completion-Tasks.md` and
`Admin-Backend-Followup-Tasks.md` are currently modified in the working tree — carry
working-tree state, not `HEAD`.

---

## 7. Verification

Docs-only, so verification is consistency checking — this repo's stated correctness
criterion.

1. **`node scripts/check-surface-docs.mjs` exits 0** — ID coverage (34 / 31 / 33 / 12 FRs,
   67 screens, all `BR` / `NFR` / `C` / `AD-*`), no invented IDs, all links resolve, no
   stale sources.
2. **No content lost.** Diff the ID set in each source section against the ID set in its
   derived file; the derived set must be equal, never smaller.
3. **No broken inbound links.**
   `grep -rn "Admin-App-Completion\|Vendor-App-Completion\|Architecture-Backend\|Async-Contract\|Physical-Data-Model" --include=*.md .`
   returns only stubs and derived files.
4. **Builds unaffected.** `cd apps/kh_admin && flutter analyze && flutter test` (green,
   141+ tests) · `cd apps/kh_mobile/karat_hive && flutter analyze && flutter test` ·
   `cd backend && npm run build && npm test`. Confirms no new `docs/` folder is picked up by
   the Dart or Node toolchains.
5. **Skill re-run is idempotent.** Running `/carve-surface-docs admin` again with no source
   change produces no diff — the real test that the skill encodes the rules rather than the
   outcome.
6. **Spot-read.** From `apps/kh_admin/docs/` alone, could someone start ADM-S03? From
   `vendor/` alone, VEN-S09?
