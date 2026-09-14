# Domain Docs

How the engineering skills should consume this repo's domain documentation when exploring the codebase.

## Layout: shared + per-surface (see `CONTEXT-MAP.md`)

This is not a classic multi-bounded-context split. Karat Hive is one domain shared across three technical surfaces (backend, kh_mobile, kh_admin) rather than several distinct domains — so there is one **shared** glossary plus optional **surface** glossaries for implementation-only vocabulary.

```
/
├── CONTEXT-MAP.md                      ← points here
├── CONTEXT.md                          ← SHARED: the one binding domain glossary
├── docs/adr/                           ← system-wide decisions
├── backend/
│   ├── CONTEXT.md                      ← surface-specific only (not yet created)
│   └── docs/adr/                       ← surface-specific decisions (if any)
└── apps/
    ├── kh_mobile/karat_hive/
    │   └── CONTEXT.md                  ← surface-specific only (not yet created)
    └── kh_admin/
        └── CONTEXT.md                  ← surface-specific only (not yet created)
```

## Before exploring, read these

1. **`CONTEXT-MAP.md`** at the repo root — read it first to see this table.
2. **`CONTEXT.md`** at the repo root (the shared context) — read it for **every** topic, regardless of which surface you're working in. This is the authoritative glossary per `CLAUDE.md`'s document authority chain.
3. **The surface `CONTEXT.md`** for whichever of `backend/`, `apps/kh_mobile/karat_hive/`, or `apps/kh_admin/` you're working in — only if it exists. These files don't exist yet; don't flag their absence or suggest creating them upfront.
4. **`docs/adr/`** — read ADRs that touch the area you're about to work in. Also check the surface's own `docs/adr/` for surface-scoped decisions, if one exists.

If a surface `CONTEXT.md` or surface `docs/adr/` doesn't exist, **proceed silently**. The `/domain-modeling` skill creates them lazily — only when a term or decision genuinely specific to that surface (not already covered by the shared `CONTEXT.md`) needs recording.

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor proposal, a hypothesis, a test name), use the term as defined in the shared `CONTEXT.md` — including honouring its `_Avoid_` lists (e.g. a Request is never a "listing"; an Offer is never a "bid"; a Connection is never a "chat"). Don't drift to synonyms the glossary explicitly avoids.

Before treating a term as surface-specific, check it isn't already defined in the shared `CONTEXT.md` — the shared glossary is the default; a surface glossary exists only for terms that genuinely don't belong there.

If a concept isn't in either glossary, that's a signal — either you're inventing language the project doesn't use (reconsider) or there's a real gap (note it for `/domain-modeling`).

## Flag ADR conflicts

If your output contradicts an existing ADR (root or surface-scoped), surface it explicitly rather than silently overriding:

> _Contradicts ADR-0007 (event-sourced orders) — but worth reopening because…_
