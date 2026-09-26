# ADM-S04 · Customer detail

| | |
|---|---|
| **User** | Platform Admin |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-011`, `FR-ADM-012` |

## Purpose

Full Customer record, history, and suspension/deletion actions.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | ADM-S03 |
| Exit | Lists; audit |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Profile data (unmasked) | Display | — | name, mobile, email, photo, Region, language | |
| Account state / created / OAuth bound | Display | — | — | |
| Requests (all states) | Display | — | list | |
| Offers received | Display | — | list | |
| Connections | Display | — | list | |
| Reviews written / received | Display | — | list | |
| Abuse reports by/against | Display | — | list | |
| Internal notes | Input | No | text | Admin-only; attributed + timestamped |
| Add note | Action | — | — | |
| Suspend | Action | — | reason list + free text | Immediate; closes PUBLISHED Requests |
| Reactivate | Action | — | — | Login restored; not Requests |
| Initiate data deletion | Action | — | — | Per FR-CUS-004 policy |
| Open record audit | System | — | — | Opening logged |

## Validation & rules

- Suspension reason required; Vendor notify on cancelled Offers.
- Both actions audit-logged.

## Empty / error / edge states

- Already suspended.

## Related screens

ADM-S03 · ADM-S08 · ADM-S21
