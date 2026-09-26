# CUS-S15 · Connection detail

| | |
|---|---|
| **User** | Customer |
| **Platform** | Mobile — Customer mode |
| **Requirements** | `FR-CUS-024`, `FR-CUS-025`, `FR-CUS-027` |

## Purpose

Post-Acceptance view: revealed Vendor identity, Talk (WhatsApp), close Connection, review prompt.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | After accept; CUS-S16 |
| Exit | WhatsApp external; CUS-S18 review; list |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Connection state | Display | — | ACTIVE / CLOSED | |
| Connection date | Display | — | datetime | |
| Request reference | Display | — | string | |
| Accepted Offer terms | Display | — | price + terms | |
| Vendor business name | Display | — | string | **Revealed** |
| Contact person | Display | — | string | |
| Vendor mobile | Display | — | phone | Selectable + copy |
| Shop address | Display | — | text | |
| Vendor Region | Display | — | — | |
| Talk | Action | — | wa.me deep link | Pre-composed message: platform, ref, offer summary |
| Copy number | Action | — | clipboard | Fallback if deep link fails |
| Close Connection | Action | Conditional | ACTIVE only | Prompts review |
| Leave review | Action | — | — | → CUS-S18 |
| Report | Action | — | — | → CUS-S22 |
| Read-only banner | Display | Conditional | CLOSED | History retained |

## Validation & rules

- Talk logged as contact event; conversation content never stored.
- Identity scoped to this Connection only (`BR-007`).

## Empty / error / edge states

- WhatsApp missing → WhatsApp Web / copy number.

## Related screens

CUS-S16 · CUS-S18 · CUS-S22
