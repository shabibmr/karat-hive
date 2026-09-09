# S8 · Documentation carve

> Work order derived from [`../comprehensive-review.md`](../comprehensive-review.md) §1–§2 (full detail: [`../comprehensive-review-carve-v1.md`](../comprehensive-review-carve-v1.md)).

| | |
|---|---|
| **Goal** | Carve per-surface doc sets so a session scoped to `apps/kh_admin` needs no repo-wide `docs/`. |
| **Owner** | 1 agent (doc work), independent of all code streams. |
| **Parallelism** | Fully independent track — **no code overlap**, runs start to finish alongside S0–S7. |
| **Depends on** | Confirm `SDC-07` (move vs copy) and `SDC-08` (skill after pilot) before phase 3. |
| **Blocks** | — |
| **Owns** | `docs/**`, `.claude/skills/carve-surface-docs/`, `scripts/check-surface-docs.mjs` |

## Decisions already taken (`SDC-01`–`06`, agreed)
Self-contained extracts with a derived-from header (authority stays with `docs/`) · screen specs copied verbatim per screen · `00`–`08` numbering stable across surfaces · Customer + Vendor share one mobile set with two mode subfolders · ~2,400 lines of common material carved once into `docs/core/` · tooling is skill + manifest + check script.

## Open (`SDC-07`, `SDC-08`) — confirm first
- **`SDC-07`** — surface-only docs referenced by nothing else are *moved* with a redirect stub, not copied. Verified safe: the four admin docs (`Admin-App-Completion-Plan.md`, `Admin-App-Completion-Tasks.md`, `Admin-Backend-Followup-Tasks.md`, `admin-backend-api-gaps.md`), the vendor/customer task docs, the seven backend docs.
- **`SDC-08`** — the skill is authored **after** the admin pilot (phase 2), not before.

## Phases (review §1.6)
| Phase | Work | Gate |
|---|---|---|
| **1. Core** | Carve `docs/core/` — 7 files (README, Glossary+Invariants, API-Conventions, Cross-Cutting-Requirements, Entity-Dictionary, Design-Tokens, ADRs-index) | Everything links to it; settles first |
| **2. Admin pilot** | The 35-file `apps/kh_admin/docs/` set by hand (10 top-level + 23 screen copies + READMEs) — see review §1.5.1 | Proves the taxonomy on a real surface |
| **3. Tooling** | `.claude/skills/carve-surface-docs/SKILL.md` + `docs/surface-map.md` manifest + `scripts/check-surface-docs.mjs` | Script green on core + admin |
| **4. Mobile** | `/carve-surface-docs customer` then `vendor` — 58 files | Largest surface |
| **5. Backend** | `/carve-surface-docs backend` — 11 files, mostly `git mv` + redirect stubs | — |

## Admin-set content that must travel (review §2, §5.2)
- 33 `FR-ADM` requirements — 6 `[ASSUMED]` (`002`, `012`, `019`, `028`, `032`, `033`) need Product Owner sign-off.
- 60 specified admin routes vs ~45 live; **double-wrapped envelope** and `Decimal`→string as built on `main`.
- ADM-S20 gold rates **deferred** (Yahoo Finance terms) — backend exists, UI out of scope, do not silently implement.
- `FR-ADM-002` role differentiation **deferred** — v1 RBAC is flat `role = ADMIN` (`AD-API-03`); ADM-S23 ships with no Role selector (`SAM-GAP-13`) though `ui-screens/admin/README.md` still documents three roles. Carry the tension into `01-Admin-Requirements.md`, do not resolve.
- Admin is the masking **exemption** (`Arch-Backend §9.5`) — masked fields absent from customer/vendor payloads; admin always sees identity.
- Shared admin list query `limit` **max 100**.

## Verification (review §1.8)
1. `node scripts/check-surface-docs.mjs` exits 0 — ID coverage (34 / 31 / 33 / 12 FRs, 67 screens, all `BR`/`NFR`/`C`/`AD-*`), no invented IDs, all links resolve, no stale sources.
2. No content lost — diff the ID set in each source section against its derived file; derived must be ⊇ source.
3. No broken inbound links — `grep -rn "Admin-App-Completion\|Vendor-App-Completion\|Architecture-Backend\|Async-Contract\|Physical-Data-Model" --include=*.md .` returns only stubs and derived files.
4. Builds unaffected — `flutter analyze && flutter test` in both Flutter packages; `npm run build && npm test` in `backend/`.
5. Skill re-run is idempotent — `/carve-surface-docs admin` twice with no source change → no diff.
6. Spot-read — from `apps/kh_admin/docs/` alone, could someone start ADM-S03? From `vendor/` alone, VEN-S09?
