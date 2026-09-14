# Context Map

Karat Hive is one domain (a request-driven gold marketplace) realised across three technical surfaces: the backend API, the customer/vendor mobile app, and the admin portal. The domain vocabulary — Request, Offer, Connection, identity masking, and so on — is **shared**, not split by surface. Read the shared context for every topic; consult a surface context only when the topic touches something specific to that surface's implementation.

| Context | Path | Scope |
|---|---|---|
| **Shared** (read for every topic) | `CONTEXT.md` (repo root) | The binding domain vocabulary and business rules (`BR-*`), used identically by backend, kh_mobile, and kh_admin. This is the authoritative glossary per `CLAUDE.md`'s document authority chain — do not fork or duplicate its terms into a surface context. |
| Backend | `backend/CONTEXT.md` *(not yet created)* | Node.js monolith-specific concerns only — e.g. outbox/job vocabulary not already covered by `docs/Async-Contract.md`. |
| kh_mobile | `apps/kh_mobile/karat_hive/CONTEXT.md` *(not yet created)* | Customer/vendor Flutter app-specific concerns only — e.g. client-only state vocabulary. |
| kh_admin | `apps/kh_admin/CONTEXT.md` *(not yet created)* | Admin Flutter portal-specific concerns only. |

System-wide architecture decisions stay in the root `docs/adr/`. A surface may accumulate its own `docs/adr/` alongside its `CONTEXT.md` for decisions scoped to that surface only (e.g. a kh_admin-only UI library choice) — see `docs/agents/domain.md`.

The three surface-specific `CONTEXT.md` files don't exist yet. Per `docs/agents/domain.md`, they're created lazily — only when a term or decision genuinely specific to that surface needs recording, not upfront.
