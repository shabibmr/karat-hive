# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

**A pre-implementation specification repository for Karat Hive**, a request-driven gold marketplace for the UAE. There is **no application code yet** — no `package.json`, no `pubspec.yaml`, no build, no test suite. The deliverables are specification documents and one static HTML prototype. It is a git repository (remote: `github.com/shabibmr/karat-hive`, private).

Work here is almost always *authoring or revising documents*. Treat consistency across documents as the primary correctness criterion, the way you would treat a passing test suite elsewhere.

## The only runnable thing

`ui-mock/` is a dependency-free HTML/CSS/JS prototype of all 67 screens. Screen partials load via `fetch`, so it **must be served over HTTP** — opening `index.html` from the filesystem shows a blank shell.

```bash
npx --yes serve ui-mock          # or:  cd ui-mock && python -m http.server 5173
```

Navigation is hash-routed: `#/customer/CUS-S04`, `#/vendor/VEN-S09`, `#/admin/ADM-S07`. Login is a role chooser with no password. Adding a screen means adding the HTML partial under `ui-mock/screens/<role>/` **and** registering it in the `window.KH_NAV` route table in `ui-mock/js/nav.js` — a partial that is not in that table is unreachable.

## Document authority chain

Read in this order when you need to understand a decision. Later documents may not contradict earlier ones.

| Document | Role |
|---|---|
| `docs/Requirements-raw.txt` | **Sole source input.** Never edit. Every requirement traces back to a line number here |
| `CONTEXT.md` | Ubiquitous language. Binding vocabulary, including the `_Avoid_` list under each term |
| `docs/Requirements-Spec-v1.3.md` | **Authoritative SRS** (~2,850 lines). What the system must do |
| `docs/adr/0001`–`0008` | Why the shape is this shape. Short, one decision each |
| `docs/Architecture-Backend.md`, `docs/Architecture-Frontend.md` | How it gets built. Derived from the SRS; cite it, never restate it |
| `docs/API-Route-Inventory.md` | Pre-code HTTP catalogue (`[PROPOSED]`). Paths, schemas, errors. Superseded by generated OpenAPI (`NFR-030`) once code exists |
| `docs/Physical-Data-Model.md` | Pre-code PostgreSQL schema (`[PROPOSED]`). Encoded in `backend/prisma/schema.prisma`. Assumes `AD-BE-05` |
| `docs/Backend-Implementation-Plan.md` | Backend build order P0–P12 and task list T01–T44. Does not override the SRS |
| `docs/Backend-Gap-Fix-Plan.md` | P0/P1 review-gap fixes (F01–F17). Does not override the SRS |
| `docs/Spec-Document-Sequence.md` | Remaining specs after the API inventory — ordered, no duplicates of the catalogue |
| `docs/Screen-API-Map.md` | Screen → endpoint coverage check (`[PROPOSED]`). Every screen's load / actions / empty-error state mapped to a route or `error.code`; gap register (`SAM-GAP-nn`) |
| `docs/Async-Contract.md` | Pre-code outbox contract (`[PROPOSED]`). Event payloads, consumers, scheduled jobs, notification dispatch. Expands Architecture-Backend §11; decision prefix `AD-ASYNC-nn` |
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

**Never cite an ID without verifying it exists and means what you think.** IDs are close together numerically and easy to transpose — `FR-CUS-006` is a Request type, `FR-CUS-007` is image upload.

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

Prescribed by the source material (`Requirements-raw.txt` L96–L103), not an open engineering choice — constraints `C-10`–`C-13`, reasoned in `adr/0006`, `adr/0007` and `adr/0008`.

- **Flutter** for all three surfaces — one dual-mode mobile binary (Customer *or* Vendor by account role), plus Flutter Web for the Admin Portal (`C-10`, confirmed)
- **Node.js monolith** — single deployable, no service decomposition, **no message broker**
- **PostgreSQL** — single system of record, **no secondary datastore** for cache, search or queue
- **Object storage** — Cloudflare R2 (S3-compatible), MinIO for local/CI (`C-13`, `adr/0008`)

`C-11` and `C-12` bite: with no broker and no Redis, asynchronous work uses a PostgreSQL transactional outbox and rate limiting uses PostgreSQL token buckets (backend architecture §11, §13.6). Do not propose Redis, Kafka or Elasticsearch without explicitly framing it as an exception to `C-12`.

## Live open decisions

Do not silently resolve these by inference; they are recorded as open on purpose.

| Item | Blocks |
|---|---|
| **Yahoo Finance redistribution terms** | Displaying reference gold rates to end users |
| **Admin data grid — build or buy** (`AD-FE-12`) | 14 Admin list screens |
| **Object-storage data residency** (`NFR-020`) — Cloudflare R2 has no UAE-region guarantee | Production storage of KYC personal data; swappable behind the S3 adapter, so non-blocking |

Resolved (see `docs/old/README.md` and Appendix D of the SRS): `C-10` — Admin Portal is the Flutter Web target (confirmed 1 Sep 2026); `C-13` — object storage is Cloudflare R2 + MinIO (`adr/0008`).

## Writing conventions

- Tables over prose lists; mermaid for diagrams (`flowchart`, `stateDiagram-v2`, `erDiagram`, `sequenceDiagram`). Mermaid renders natively — do not add a JS library.
- Every requirement carries a **Source** line citing either a raw-notes line number or `[ASSUMED]`.
- SRS Appendix B claims **100 % coverage of every non-blank line** of `Requirements-raw.txt`, with a stated count. If the raw notes change, that count and the traceability rows must be recomputed — it is a factual claim, not boilerplate.
- Use `CONTEXT.md` terminology exactly, including honouring the `_Avoid_` lists (a Request is never a "listing"; an Offer is never a "bid"; a Connection is never a "chat").
- The architecture documents cite requirements rather than restating them. If you find yourself re-explaining a rule, link to it instead.
