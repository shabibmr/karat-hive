# CUS-S09 · Request review & publish

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-014`, `FR-CUS-015`, `FR-CUS-001` (OAuth gate), [`adr/0010`](../../docs/adr/0010-google-signin-only-login.md), [`adr/0011`](../../docs/adr/0011-guest-first-landing.md) |

## Purpose

Review the full Request draft, save as draft (signed-in only), or publish to fan out to matched Vendors. Guest must log in on Publish; a successful Customer login auto-publishes (`adr/0011`).

## Entry / exit

| Direction | Path |
|---|---|
| Entry | End of create flows |
| Exit success publish | Confirmation → CUS-S10 |
| Exit draft | CUS-S02 / drafts |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Full Request summary | Display | — | all type fields + images | Read-only review |
| Indicative valuation / budget | Display | — | AED | Type-dependent |
| OAuth / Login gate | Action / Display | Conditional | Google (`adr/0010`) | Guest, or signed-in without Google binding. Dismissible without wiping the in-memory form |
| Save as draft | Action | — | — | Signed-in only. Guest draft is in-memory; no server draft |
| Publish | Action | — | — | DRAFT → PUBLISHED. Guest → Login then auto-publish if Customer |
| Confirmation — Request reference | System | — | e.g. KH-RQ-2026-004821 | On success |
| Confirmation — hard expiry | System | — | published_at + 48 h | No extension |

## Validation & rules

- All type-specific mandatory fields validated server-side.
- Publish refused without a bound Google session (`BR-001`, `adr/0010`).
- Guest publish: Login → Customer auto-publish; Vendor drops draft and leaves create; cancel keeps form.
- Fan-out + notifications on publish.

## Empty / error / edge states

- Validation failures listed inline/summary.
- Concurrent published limit (10).
- Bullion below minimum.

## Related screens

CUS-S10 · CUS-S01 Login · CUS-S02 · CUS-S23
