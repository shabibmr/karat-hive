# VEN-S13 · Connection detail

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-021`, `FR-VEN-022` |

## Purpose

Revealed Customer identity and contact actions (Talk, call) for an accepted introduction.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | VEN-S12; Accepted Offers |
| Exit | WhatsApp / phone; review; close |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Customer name | Display | — | string | **Revealed** |
| Customer mobile | Display | — | phone | Copy + tap-to-call |
| Customer Region | Display | — | — | |
| Platform tenure | Display | — | duration / since | |
| Prior completed Connections count | Display | — | integer | |
| Request reference | Display | — | string | |
| Accepted Offer terms | Display | — | full | |
| Connection state | Display | — | ACTIVE / CLOSED | |
| Identity revealed at | Display | — | datetime | Audited |
| Talk | Action | Conditional | ACTIVE | WhatsApp pre-filled message |
| Tap-to-call | Action | Conditional | ACTIVE | |
| Copy number | Action | — | — | Fallback |
| Close Connection | Action | Conditional | ACTIVE | → review prompt VEN-S19 |
| Leave feedback | Action | — | — | VEN-S19 |
| Report | Action | — | — | VEN-S21 |
| Read-only banner | Display | Conditional | CLOSED | Details remain accessible |

## Validation & rules

- Identity only via Connection (`FR-CUS-024`).
- Access to revealed contact details audit-logged.
- No bulk export of Customer contacts (`NFR-016`).
- Platform never stores conversation content.

## Empty / error / edge states

- WhatsApp missing → Web / copy / call.

## Related screens

VEN-S12 · VEN-S19 · VEN-S21
