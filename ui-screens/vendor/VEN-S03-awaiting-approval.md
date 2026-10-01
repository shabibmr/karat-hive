# VEN-S03 · Awaiting Approval shell

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-003`, `FR-ADM-015` |

## Purpose

Exclusive shell for non-ACTIVE Vendors: verification status, Admin messages, document re-upload, support — **no marketplace data**.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Login while PENDING_VERIFICATION or REJECTED |
| Exit | ACTIVE → VEN-S05; or refused states |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Verification state | Display | — | PENDING_VERIFICATION, REJECTED | |
| Expected review messaging | Display | — | copy | **No SLA promised** (PO) |
| Admin message / more-info request | Display | — | text | |
| Document re-upload | Action | Conditional | → VEN-S02 | If allowed |
| Support contact | Action | — | — | |
| Logout | Action | — | — | |

## Validation & rules

- Server-side authorisation blocks dashboard, feed, Offers, Connections, others’ ratings (`NFR-013` pattern).
- Client routing alone is insufficient.

## Empty / error / edge states

- Rejected with reason; more-info state.

## Related screens

VEN-S02 · VEN-S05 (only when ACTIVE; approval activates in one step)
