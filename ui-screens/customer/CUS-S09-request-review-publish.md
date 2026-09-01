# CUS-S09 · Request review & publish

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-014`, `FR-CUS-015`, `FR-CUS-001` (OAuth gate) |

## Purpose

Review the full Request draft, save as draft, or publish to fan out to matched Vendors.

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
| OAuth gate prompt | Action / Display | Conditional | provider | If not yet bound |
| Save as draft | Action | — | — | No mandatory-field validation |
| Publish | Action | — | — | DRAFT → PUBLISHED |
| Confirmation — Request reference | System | — | e.g. KH-RQ-2026-004821 | On success |
| Confirmation — hard expiry | System | — | published_at + 48 h | No extension |

## Validation & rules

- All type-specific mandatory fields validated server-side.
- Publish refused without OAuth (`BR-001`).
- Fan-out + notifications on publish.

## Empty / error / edge states

- Validation failures listed inline/summary.
- Concurrent published limit (10).
- Bullion below minimum.

## Related screens

CUS-S10 · CUS-S01 OAuth · CUS-S02
