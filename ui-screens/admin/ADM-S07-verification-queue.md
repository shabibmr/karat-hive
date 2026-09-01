# ADM-S07 · Verification queue & document reviewer

| | |
|---|---|
| **User** | Platform Admin |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-015` |

## Purpose

Oldest-first queue to approve, reject, or request more information on Vendor KYC. No published SLA.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Dashboard queue; Vendor list pending |
| Exit | Next queue item; Vendor notified |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Queue list | Display | — | PENDING_VERIFICATION | Default oldest-first |
| Waiting age | Display | — | duration | |
| Declared business details | Display | — | side-by-side with docs | |
| Document viewer (full resolution) | Display | — | all uploaded types | View logged |
| Decision: Approve | Action | — | → VERIFIED (then ACTIVE path) | Rationale required |
| Decision: Reject | Action | — | → REJECTED | Rationale + reason to Vendor; resubmit allowed |
| Decision: Request more information | Action | — | stays PENDING | Message to Vendor |
| Rationale | Input | Yes | text | On approve/reject |
| Message to Vendor | Input | Conditional | text | More-info / reject reason |

## Validation & rules

- Approval is sole path toward marketplace access; still needs ACTIVE + subscriptions.
- Decision audit-logged with Admin id.
- Vendor notified within ~1 minute.

## Empty / error / edge states

- Empty queue.

## Related screens

ADM-S06 · ADM-S02
