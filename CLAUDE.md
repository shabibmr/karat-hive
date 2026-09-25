# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Karat Hive is a request-driven gold marketplace for the UAE: three deployables sharing one Postgres database — a Node.js monolith (`backend/`), a dual-mode Customer/Vendor Flutter app (`apps/kh_mobile/karat_hive/`), and a Flutter Web Admin Portal (`apps/kh_admin/`). `docs/`, `ui-screens/`, and the static prototype `ui-mock/` are companion references.

Work here is most often *authoring or revising documents*. Treat consistency across documents as the primary correctness criterion — the way you'd treat a passing test suite elsewhere.

## Reading order

When a decision needs tracing back, read in this order. Later documents may not contradict earlier ones.

| Document | Role |
|---|---|
| `docs/Requirements-raw.txt` | **Sole source input.** Never edit. Every requirement traces to a line number here |
| `CONTEXT.md` | Ubiquitous language — binding vocabulary, including the `_Avoid_` list under each term |
| `docs/Requirements-Spec-v1.4.md` | **Authoritative SRS.** What the system must do |
| `docs/adr/0001`–`0013` | Why the shape is this shape, one decision each. `0010` Google-only login; `0011` Guest-first launch; `0013` object storage on Oracle S3 (`ap-hyderabad-1`; supersedes `0012` R2 KYC) |
| `docs/Architecture-Backend.md`, `docs/Architecture-Frontend.md` | How it gets built. Derived from the SRS; cite it, never restate it |
| `docs/API-Route-Inventory.md` | Pre-code HTTP catalogue (`[PROPOSED]`). Superseded by generated OpenAPI (`NFR-030`) once code exists |
| `docs/Physical-Data-Model.md` | Pre-code Postgres schema (`[PROPOSED]`). Encoded in `backend/prisma/schema.prisma` |
| `docs/Backend-Implementation-Plan.md`, `docs/Backend-Gap-Fix-Plan.md` | Backend build order and gap fixes. Neither overrides the SRS |
| `docs/Screen-API-Map.md` | Screen → endpoint coverage; gap register `SAM-GAP-nn` |
| `ui-screens/` | Field-level inventory of the 68 screens, plus `component-widgets.md` (`SH-*` widgets) and the visual-system doc |
| `ui-mock/` | Interactive realisation of `ui-screens/` |
| `docs/old/` | Superseded versions — read-only history |

**Versioning habit:** a substantive SRS revision is superseded, not edited in place — the old file moves to `docs/old/`, a new `-vN.N` file becomes authoritative, `docs/old/README.md` and every inbound reference are updated, and SRS Appendix B's coverage count is recomputed (it's a factual claim, not boilerplate).

## Identifiers

The connective tissue between documents. Stable, never reused. IDs sit close together numerically and are easy to transpose — `FR-CUS-006` is a Request type, `FR-CUS-007` is image upload. Never cite one without checking it exists and means what you think.

| Prefix | Meaning | Defined in |
|---|---|---|
| `FR-CUS/VEN/ADM/SYS-nnn` | Functional requirement by actor; `SYS` = no human actor | SRS §4 |
| `BR-nnn` | Business rule — prevails over any conflicting FR | SRS §5.1 |
| `NFR-nnn` | Non-functional requirement | SRS §8 |
| `C-nn` | Design/implementation constraint | SRS §2.5 |
| `CUS-Snn` / `VEN-Snn` / `ADM-Snn` | Screen | SRS Appendix C, `ui-screens/` |
| `SH-*` | Shared UI component | `ui-screens/component-widgets.md` |
| `AD-BE-nn` / `AD-FE-nn` | Architecture decision | the two architecture documents |
| `AD-API-nn` / `AD-ASYNC-nn` | HTTP catalogue / async contract decision | `docs/API-Route-Inventory.md` / `docs/Async-Contract.md` |
| `SAM-GAP-nn` | Screen-vs-API coverage gap | `docs/Screen-API-Map.md` |

**Status tags:** `[ASSUMED]` (SRS) — inferred, needs Product Owner confirmation, indexed in Appendix B.3. `[PROPOSED]` (architecture docs) — a decision the SRS doesn't fix, needs Technical Lead sign-off, registered in that document's §3. `[BLOCKED]` — waits on an external decision, must also appear in that document's open-decisions section.

## Roles and services

Four actors, defined in `CONTEXT.md`: **Guest** (unauthenticated, browses and composes, cannot publish), **Customer** (one-time external identity binding before first publish), **Vendor** (needs `VERIFIED` + `ACTIVE` + an active Type Subscription for the Request type — verification alone is not enough, `BR-002`), **Platform Admin** (`kh_admin`). `kh_mobile` is one binary rendering as Customer or Vendor by account role; no account holds both.

Four Request Types, the unit of Vendor subscription entitlement and immutable once published: **Find An Ornament** (buy), **Sell Old Gold** (sell), **Buy/Sell Gold Coin(s)**, **Buy/Sell Gold Bullion** (direction chosen by the Customer on the last two).

## The 48-hour Request lifecycle

A published Request hard-expires 48 hours after publication — no Customer extension, ever (`C-07`, `FR-SYS-005`). A T−6h warning notification fires before expiry. Vendor-chosen Offer validity (default 24h, up to 48h) can never extend past the parent Request's hard expiry.

```
DRAFT → PUBLISHED → OFFERS_RECEIVED → ACCEPTED → CLOSED
  ↓         ↓              ↓
CANCELLED EXPIRED(48h)   EXPIRED(48h) / CANCELLED / REMOVED
```

- `PUBLISHED` → `OFFERS_RECEIVED` on the first Offer; falls back to `PUBLISHED` if the last pending Offer expires unaccepted.
- **Acceptance is atomic and irreversible** (`BR-011`–`BR-013`): one Customer action accepts exactly one Offer, rejects every other pending Offer on that Request, creates exactly one Connection, and reveals both identities — one transaction.
- Before acceptance, identity fields are **absent** from API payloads for both parties (`BR-006`), never null or client-hidden.
- A Connection survives closure as a read-only record. "Talk" only opens a `wa.me` deep link — the platform never reads conversation content (`C-03`) and has no authoritative knowledge that a deal closed (`BR-015`; settlement is off-platform).
- No broker, no Redis (`C-11`/`C-12`) — expiry, warnings, and other async effects run off a Postgres transactional outbox (`backend/src/platform/outbox/`) plus a scheduler (`backend/src/platform/scheduler/`), never a queue worker.

## Domain invariants

Load-bearing. Any document or code that weakens one is wrong regardless of what else it improves.

1. **Identity masking until Acceptance** — masking is enforced server-side (`edge/masking`); reveal is scoped to the single Connection that produced it (`BR-007`), never generalised.
2. **Vendor never learns a competitor's identity, price, or terms** — before, during, or after (`BR-008`). Only the Offer count.
3. **A Vendor needs three things**, not one: verification, `ACTIVE`, and an active Type Subscription for that Request type.
4. **Taxonomy is flat.** `Category` and `Region` are single-level lists — no `parentId`, no depth, sort by `display_order` only (migration `20260915120000_flatten_taxonomy`). Don't reintroduce hierarchy without a new ADR.
5. **Units:** AED, grams, karat/fineness. Timestamps stored UTC, displayed Gulf Standard Time (`BR-021`).

## Fixed technology stack

Prescribed by the source material (`Requirements-raw.txt` L96–L103), not an open choice — `C-10`–`C-13`, `adr/0006`–`0009`.

- **Flutter** everywhere — one dual-mode mobile binary, plus Flutter Web for Admin
- **Node.js monolith** — single deployable, no service decomposition, **no message broker**
- **PostgreSQL** — the only system of record, no secondary datastore for cache/search/queue
- **Supabase** (non-prod, `adr/0009`) — backend connects directly as `postgres`; the PostgREST Data API is deny-all RLS, `anon`/`authenticated` grants revoked. No Supabase Auth/Realtime/Edge, no client SDKs, no RLS policies
- **Oracle Object Storage** (S3 Compatibility API, `ap-hyderabad-1`) for hosted object storage (`adr/0013`); MinIO or local disk for local/CI; Supabase Storage as non-prod fallback when OCI credentials are unset

`C-11`/`C-12` bite in code: async work goes through the outbox, not a queue; rate limiting is Postgres token buckets, not Redis. Don't propose Redis, Kafka, or Elasticsearch without explicitly framing it as an exception to `C-12`.

## Working product notes (code ahead of docs)

- **Customer bottom nav:** Home (dashboard: hero + service grid + activity summary) · **My Requests** (open/live list; AppBar **History** → terminal history) · Connections · Alerts · Profile. Do not mount the open-request list on Home. Docs/`ui-screens`/`ui-mock`/SRS Appendix C may still describe the old combined Home — prefer this shell behaviour until those docs are rewritten.

## Architecture gotchas

- **Backend module boundaries are lint-enforced, not conventional.** Each `backend/src/modules/<name>/` exposes only `index.ts` to other modules; `eslint-plugin-boundaries` (`backend/eslint.config.mjs`) fails the build on a direct cross-module import or on `edge`/`platform` reaching into a module's internals. A lint failure here is a layering violation to fix, not a rule to suppress.
- **`kh_admin` is outside the Melos/Dart-pub workspace** (`melos.yaml`, deliberate). `dart run melos analyze` / `melos gen` reach `kh_mobile` and `packages/kh_*` but not `kh_admin` — run its analyze/test/build from inside `apps/kh_admin` directly. `flutter analyze` is also wrong for either app; the workspace lint script is `dart analyze` (`hardcoded_strings_lint` needs it).
- **`ui-mock/` must be served over HTTP**, never opened as a file — screen partials load via `fetch` and a `file://` origin shows a blank shell. Adding a screen means both the HTML partial under `ui-mock/screens/<role>/` **and** an entry in `window.KH_NAV` (`ui-mock/js/nav.js`); a partial missing from that table is unreachable.
- **`kh_mobile` and `kh_admin` never import each other** (`docs/Architecture-Frontend.md` §4–§5); shared code only through `packages/kh_core`, `kh_domain`, `kh_api`, `kh_design_system`, `kh_ui_domain`, `kh_l10n`, `kh_media`.
- **OTP is optional/deferred, not a Checkpoint-1 gate**, for both Customer and Vendor registration — the backend accepts a self-reported `mobileNumber` with no `challengeId` (`mobileVerifiedAt` stays null). This is a stated temporary development-phase bypass in code comments, not a permanent design call — don't harden it as if it were.
- Every screen must work at both a narrow and a wide viewport regardless of the app's primary orientation (`kh_admin` desktop-first, `kh_mobile` mobile-first) — check both before calling a screen done.

## Live open decisions

Don't resolve these by inference; they're recorded as open on purpose.

| Item | Blocks |
|---|---|
| Yahoo Finance redistribution terms | Displaying reference gold rates to end users |
| Admin data grid — build or buy (`AD-FE-12`) | 14 Admin list screens |
| Production PostgreSQL region (`NFR-020`) | UAE-consistent region for the live database. Hosted **object** bytes are on Oracle Object Storage S3 in `ap-hyderabad-1` (`adr/0013`) — India, not UAE; a UAE OCI region remains a future config swap |

Resolved, see `docs/old/README.md` and SRS Appendix D: `C-10` Admin Portal is Flutter Web (1 Sep 2026); `C-13` hosted object storage is Oracle Object Storage S3 Compatibility in `ap-hyderabad-1` (`adr/0013`, superseding R2 KYC interim `adr/0012`); Supabase Data-API/RLS locked down (6 Sep 2026, `adr/0009`); Guest-first launch (11 Sep 2026, `adr/0011` — SRS Appendix C still lists 22 Customer screens until the next SRS bump).

## Writing conventions

- Tables over prose lists; mermaid for diagrams — it renders natively, no JS library.
- Every requirement carries a **Source** line: a raw-notes line number or `[ASSUMED]`.
- Use `CONTEXT.md` terminology exactly, honouring the `_Avoid_` lists — a Request is never a "listing", an Offer never a "bid", a Connection never a "chat".
- Architecture documents cite requirements rather than restate them. Re-explaining a rule inline means it should be a link instead.

## Agent skills

- **Issue tracker:** GitHub issues on `github.com/shabibmr/karat-hive` via `gh`. See `docs/agents/issue-tracker.md`.
- **Domain docs:** shared `CONTEXT.md` plus optional surface-specific `CONTEXT.md` under `backend/`, `apps/kh_mobile/karat_hive/`, `apps/kh_admin/` — see `CONTEXT-MAP.md` and `docs/agents/domain.md`.
