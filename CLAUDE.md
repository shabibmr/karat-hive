# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**The repository for Karat Hive**, a request-driven gold marketplace for the UAE.

| Surface | Path | Stack |
|---|---|---|
| Backend monolith | `backend/` | NestJS 11 + Fastify + Prisma + Vitest |
| Mobile app — Customer *or* Vendor by account role | `apps/kh_mobile/karat_hive/` | Flutter, Dart SDK `>=3.9.0 <4.0.0` |
| Admin Portal | `apps/kh_admin/` | Flutter Web, same SDK constraint |
| Shared Dart packages | `packages/` | `kh_core`, `kh_domain`, `kh_api`, `kh_design_system`, `kh_l10n`, `kh_ui_domain` |

Melos 8 manages the Dart workspace and its config lives in the root `pubspec.yaml` — there is **no** standalone `melos.yaml`. `apps/kh_admin` is deliberately excluded from that workspace and built standalone. CI is `.github/workflows/backend.yml` and `frontend.yml`. Specification documents and the static HTML prototype (`ui-mock/`) remain companion references.

Much of the work here is still *authoring or revising documents*, and for that, consistency across documents is the correctness criterion — treat it the way you would treat a passing test suite. But there is now substantial code behind the specs, and the two have drifted in places. When a document and the code disagree, **say so** rather than silently trusting either; several documents carry stale status tables while the code has moved on.

## Runnable surfaces

Checkpoint-1 vendor onboarding and admin taxonomy are on `main`, including Google Sign-In on the Flutter clients **and** Firebase ID-token acceptance in the Nest `AuthGuard`.

```bash
cd backend && npm run start:dev                          # API :3000
cd apps/kh_mobile/karat_hive && flutter run --dart-define-from-file=config/dev.json
cd apps/kh_admin && flutter run -d chrome --dart-define=KH_API_BASE=http://localhost:3000
npx --yes serve ui-mock                                  # static 67-screen prototype (HTTP only)

melos bootstrap && melos run analyze && melos run test   # Dart workspace (excludes kh_admin)
cd backend && npm run build && npm test                  # backend gate
```

Sign-in is **Google only** (vendor and admin) for product gates. Clients send a Firebase ID token as `Authorization: Bearer`; the backend verifies it (Google JWKS, `FIREBASE_PROJECT_ID`), finds or creates the user, and still issues its own HS256 access/refresh JWTs on the legacy password/OTP routes. Do not treat password/OTP credentials as a Checkpoint-1 gate.

`ui-mock/` is a dependency-free HTML/CSS/JS prototype of all 67 screens. Screen partials load via `fetch`, so it **must be served over HTTP** — opening `index.html` from the filesystem shows a blank shell.

Navigation is hash-routed: `#/customer/CUS-S04`, `#/vendor/VEN-S09`, `#/admin/ADM-S07`. Login is a role chooser with no password. Adding a screen means adding the HTML partial under `ui-mock/screens/<role>/` **and** registering it in the `window.KH_NAV` route table in `ui-mock/js/nav.js` — a partial that is not in that table is unreachable.

## Document authority chain

Read in this order when you need to understand a decision. Later documents may not contradict earlier ones.

| Document | Role |
|---|---|
| `docs/Requirements-raw.txt` | **Sole source input.** Never edit. Every requirement traces back to a line number here |
| `CONTEXT.md` | Ubiquitous language. Binding vocabulary, including the `_Avoid_` list under each term |
| `docs/Requirements-Spec-v1.3.md` | **Authoritative SRS** (~2,850 lines). What the system must do |
| `docs/adr/0001`–`0009` | Why the shape is this shape. Short, one decision each |
| `docs/Architecture-Backend.md`, `docs/Architecture-Frontend.md` | How it gets built. Derived from the SRS; cite it, never restate it |
| `docs/API-Route-Inventory.md` | Pre-code HTTP catalogue (`[PROPOSED]`). Paths, schemas, errors. Superseded by generated OpenAPI (`NFR-030`) once code exists |
| `docs/Physical-Data-Model.md` | Pre-code PostgreSQL schema (`[PROPOSED]`). Encoded in `backend/prisma/schema.prisma`. Assumes `AD-BE-05` |
| `docs/Backend-Implementation-Plan.md` | Backend build order P0–P12 and task list T01–T46. Does not override the SRS |
| `docs/Backend-Gap-Fix-Plan.md` | P0/P1 review-gap fixes (F01–F17). ⚠️ Its status tables all still say `pending`; **all seventeen are landed in code.** Trust the code |
| `docs/Spec-Document-Sequence.md` | Remaining specs after the API inventory — ordered, no duplicates of the catalogue |
| `docs/Screen-API-Map.md` | Screen → endpoint coverage check (`[PROPOSED]`). Every screen's load / actions / empty-error state mapped to a route or `error.code`; gap register (`SAM-GAP-nn`) |
| `docs/Async-Contract.md` | Pre-code outbox contract (`[PROPOSED]`). Event payloads, consumers, scheduled jobs, notification dispatch. Expands Architecture-Backend §11; decision prefix `AD-ASYNC-nn` |
| `docs/checkpoints/checkpoint-1-vendor-onboarding-vertical.md` + `-tasks.md` | **Shipped.** Plan of record + task register for the first Vendor vertical (`VEN-S01`–`S05`, `S16`) |
| `docs/Vendor-App-Completion-Plan.md` + `Vendor-App-Completion-Tasks.md` | Plan of record + task register for the remaining 16 Vendor screens, check-points CP-2…CP-6. Slices `Backend-Implementation-Plan.md`, does not renumber it |
| `docs/Admin-Checkpoint-1-Taxonomy-Plan.md` + `Admin-Checkpoint-1-Tasks.md` | Plan of record + task register for the Admin taxonomy vertical |
| `ui-screens/` | Field-level inventory of the 67 screens, plus `component-widgets.md` (shared `SH-*` widget catalogue) and `Karat_Hive_UI_Design_Context.md` (visual system) |
| `ui-mock/` | Interactive realisation of `ui-screens/` |
| `docs/old/` | Superseded versions. Read-only history |

**Versioning habit:** substantive SRS revisions are superseded, not edited in place — the old file moves to `docs/old/`, a new `-vN.N` file becomes authoritative, and `docs/old/README.md` plus every inbound reference is updated. Check `grep -rl "Requirements-Spec-v1\.2"` style before declaring a version bump complete.

## Identifier systems

These appear in every document and are the connective tissue between them. Identifiers are stable and **never reused**.

| Prefix | Meaning | Defined in |
|---|---|---|
| `FR-CUS/VEN/ADM/SYS-nnn` | Functional requirement by actor; `SYS` = no human actor | SRS §4 |
| `BR-nnn` | Business rule — prevails over any conflicting FR | SRS §5.1 |
| `NFR-nnn` | Non-functional requirement | SRS §8 |
| `C-nn` | Design/implementation constraint | SRS §2.5 |
| `CUS-Snn` / `VEN-Snn` / `ADM-Snn` | Screen | SRS Appendix C, `ui-screens/` |
| `SH-*` | Shared UI component | `ui-screens/component-widgets.md` |
| `AD-BE-nn` / `AD-FE-nn` | Architecture decision | the two architecture documents |
| `AD-API-nn` | HTTP catalogue decision | `docs/API-Route-Inventory.md` |
| `AD-ASYNC-nn` | Async / outbox contract decision | `docs/Async-Contract.md` |
| `SAM-GAP-nn` | Screen-vs-API coverage gap | `docs/Screen-API-Map.md` |
| `P0`–`P12` / `T01`–`T46` | Backend build phase / backend task | `docs/Backend-Implementation-Plan.md` |
| `F01`–`F17` / `D01`–`D04` | Review-gap fix / doc-hygiene item | `docs/Backend-Gap-Fix-Plan.md` |
| `D-1`, `D-2` | Recorded backend deviations (no outbox consumers; leased drain) | `docs/Backend-Implementation-Plan.md`, closed by `T45` / `T46` |
| `CP1-*` … `CP6-*` | Vendor check-point task, by track — `A` backend, `B` Flutter, `F` foundations, `I` infra, `V` verification | the checkpoint task registers |
| `ADM-BE-nnn` / `ADM-FE-nnn` | Admin check-point task | `docs/Admin-Checkpoint-1-Tasks.md` |
| `CU-nn` / `VE-nn` / `AD-nn` | **Individual** (screen-specific, non-shared) widget — Customer / Vendor / Admin | `ui-screens/component-widgets.md` §2 |

**Never cite an ID without verifying it exists and means what you think.** IDs are close together numerically and easy to transpose — `FR-CUS-006` is a Request type, `FR-CUS-007` is image upload.

Two collisions to watch specifically:

- **`AD-nn` is an Admin widget; `AD-BE-nn` / `AD-FE-nn` / `AD-API-nn` / `AD-ASYNC-nn` are architecture decisions.** `AD-05` (verification queue UI) and `AD-BE-05` (Prisma + raw SQL) are unrelated. Never shorten a decision ID.
- **`T01`–`T46` (backend tasks) vs `CP2-A01`-style check-point tasks** address the same work at different granularity. A check-point task register *slices* a `T`-ID; it never renumbers or supersedes it. Tick a `T`-ID only for the role path actually delivered.

### Status tags

- **`[ASSUMED]`** (SRS) — inferred by the spec author, not stated by the business. Every one needs Product Owner confirmation; they are indexed in SRS Appendix B.3. When adding an inferred requirement, tag it rather than leaving a gap.
- **`[PROPOSED]`** (architecture docs) — a decision this document makes that the SRS does not fix. Needs Technical Lead sign-off; must be registered in the document's §3 decision register.
- **`[BLOCKED]`** — waits on an external decision. Must also appear in that document's open-decisions section.

## Domain invariants

These are load-bearing. Any document or future code that weakens one is wrong, regardless of what else it improves.

1. **Identity masking until Acceptance** (`BR-006`, `FR-SYS-003`, `NFR-013`). Masked fields are **absent from API payloads** — not null, not empty, not hidden by the client. Enforced server-side. Reveal is scoped to the single Connection that produced it (`BR-007`); it never generalises to other Requests.
2. **Acceptance is atomic and irreversible** (`BR-011`–`BR-013`, `FR-SYS-006`, `FR-SYS-007`). Accepting one Offer rejects all competitors, creates exactly one Connection, and reveals both identities, in one transaction.
3. **Requests hard-expire at 48 hours** (`C-07`). No Customer extension. Warning at T−6 h.
4. **A Vendor needs three things to act**: verification state `VERIFIED`, account state `ACTIVE`, **and** an active Type Subscription for that Request type (`BR-002`, `FR-VEN-031`). Verification alone is not enough.
5. **A Vendor never learns a competing Vendor's identity, price, or terms** — before, during or after (`BR-008`). Only the Offer count.
6. **WhatsApp is an outbound `wa.me` deep link only** (`C-03`, SRS §7.2). No Business API, no callback, no conversation content — the platform is technically incapable of reading it (`NFR-017`).
7. **Settlement happens off-platform** (`BR-015`). The platform brokers introductions and has no authoritative knowledge of whether a deal closed.
8. **Units:** AED, grams, karat/fineness. Timestamps stored UTC, displayed Gulf Standard Time (`BR-021`, `C-01`, `C-02`).

## Fixed technology stack

Prescribed by the source material (`Requirements-raw.txt` L96–L103), not an open engineering choice — constraints `C-10`–`C-13`, reasoned in `adr/0006`, `adr/0007`, `adr/0008` and `adr/0009`.

- **Flutter** for all three surfaces — one dual-mode mobile binary (Customer *or* Vendor by account role), plus Flutter Web for the Admin Portal (`C-10`, confirmed)
- **Node.js monolith** — single deployable, no service decomposition, **no message broker**
- **PostgreSQL** — single system of record, **no secondary datastore** for cache, search or queue
- **Managed Postgres** — Supabase for non-production (`adr/0009`, `AD-BE-15`); the backend connects directly as `postgres`. The bundled PostgREST **Data API is locked down** — RLS deny-all on every `public` table, `anon`/`authenticated` grants revoked. No Supabase Auth / Realtime / Edge. Do not add Supabase client SDKs or RLS policies
- **Object storage** — Cloudflare R2 (S3-compatible), MinIO for local/CI (`C-13`, `adr/0008`)

`C-11` and `C-12` bite: with no broker and no Redis, asynchronous work uses a PostgreSQL transactional outbox and rate limiting uses PostgreSQL token buckets (backend architecture §11, §13.6). Do not propose Redis, Kafka or Elasticsearch without explicitly framing it as an exception to `C-12`.

## Live open decisions

Do not silently resolve these by inference; they are recorded as open on purpose.

| Item | Blocks |
|---|---|
| **Offer validity option set** — `FR-VEN-013` says 12/24/48 h; the SRS §6 entity dictionary says 24/48/72/168 (`AD-API-07`, inventory §23) | `VEN-S09`/`VEN-S10`, i.e. the whole Offer vertical. Clients must read `platform-config.offerValidityHours` and never hard-code the set |
| **`T36` schema deltas** — `SAM-GAP` + `Async-Contract` §10 columns and four partial indexes, still `[PROPOSED]` pending Technical Lead sign-off | `T41` offer-expiry warning, `T44` document expiry, and the initial migration being frozen |
| **Yahoo Finance redistribution terms** | Displaying reference gold rates to end users |
| **Admin data grid — build or buy** (`AD-FE-12`) | 14 Admin list screens |
| **Object-storage data residency** (`NFR-020`) — Cloudflare R2 has no UAE-region guarantee | Production storage of KYC personal data; swappable behind the S3 adapter, so non-blocking |

Resolved (see `docs/old/README.md` and Appendix D of the SRS): `C-10` — Admin Portal is the Flutter Web target (confirmed 1 Sep 2026); `C-13` — object storage is Cloudflare R2 + MinIO (`adr/0008`); **Supabase Data-API / RLS exposure** — locked down at the database 6 Sep 2026 (`adr/0009`, `AD-BE-15`).

## Writing conventions

- Tables over prose lists; mermaid for diagrams (`flowchart`, `stateDiagram-v2`, `erDiagram`, `sequenceDiagram`). Mermaid renders natively — do not add a JS library.
- Every requirement carries a **Source** line citing either a raw-notes line number or `[ASSUMED]`.
- SRS Appendix B claims **100 % coverage of every non-blank line** of `Requirements-raw.txt`, with a stated count. If the raw notes change, that count and the traceability rows must be recomputed — it is a factual claim, not boilerplate.
- Use `CONTEXT.md` terminology exactly, including honouring the `_Avoid_` lists (a Request is never a "listing"; an Offer is never a "bid"; a Connection is never a "chat").
- The architecture documents cite requirements rather than restating them. If you find yourself re-explaining a rule, link to it instead.
