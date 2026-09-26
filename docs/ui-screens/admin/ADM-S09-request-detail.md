# ADM-S09 · Request detail

| | |
|---|---|
| **User** | Platform Admin |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-018`, `FR-ADM-019` |

## Purpose

Full Request oversight including matched Vendors, Offers, state history; remove if policy violation.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | ADM-S08 |
| Exit | Lists; moderation action |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Customer-supplied data + images | Display | — | full | |
| Matched Vendors list | Display | — | identities | |
| All Offers with terms + Vendor | Display | — | unmasked | |
| State-transition history | Display | — | timestamps | |
| Resulting Connection | Display | Conditional | link | If accepted |
| Internal note | Input | No | text | |
| Remove Request | Action | — | reason required | → REMOVED; withdraw pending Offers; notify parties |
| Read-only commercial terms | Display | — | — | Admin cannot edit price/requirements |

## Validation & rules

- Removal retained for audit; never hard-deleted.
- Removal audit-logged.

## Empty / error / edge states

- Already REMOVED.

## Related screens

ADM-S08 · ADM-S11 · ADM-S13
