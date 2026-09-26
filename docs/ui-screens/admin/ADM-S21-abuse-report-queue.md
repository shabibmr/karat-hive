# ADM-S21 · Abuse report queue

| | |
|---|---|
| **User** | Platform Admin |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-032` |

## Purpose

Triage Customer/Vendor abuse reports; resolve without disclosing reporter identity to reported party.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Dashboard queue |
| Exit | Linked entity records; resolution |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Queue list | Display | — | severity then age | |
| Category | Display | — | report category | |
| Reporter | Display | — | Admin sees | Not disclosed to reported |
| Reported party | Display | — | — | |
| Linked entity | Display / Action | — | Request/Offer/Connection | One-step jump |
| Age | Display | — | duration | |
| Free-text body | Display | — | — | |
| Resolution: Dismiss | Action | — | rationale | |
| Resolution: Warn | Action | — | rationale | |
| Resolution: Suspend | Action | — | rationale | |
| Resolution: Deactivate | Action | — | rationale | |
| Rationale | Input | Yes | text | |
| Reporter resolution notice | System | — | acknowledged resolved | Detail not sent to reported |

## Validation & rules

- All actions audit-logged.
- Priority auto-flag when Request has 3 distinct Vendor reports.

## Empty / error / edge states

- Empty queue.

## Related screens

ADM-S04 · ADM-S06 · ADM-S09 · ADM-S02
