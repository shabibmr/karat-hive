# VEN-S10 · Revise / withdraw Offer

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-014` |

## Purpose

Change terms or withdraw while Offer is PENDING (max 3 revisions).

## Entry / exit

| Direction | Path |
|---|---|
| Entry | VEN-S08 / VEN-S11 Pending |
| Exit | Updated Offer detail / list |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Current terms snapshot | Display | — | all Offer fields | |
| Revision count remaining | Display | — | 0–3 | Max 3 revisions |
| Offered price | Input | Yes | AED | Same schema as submit |
| Validity period | Input | Yes | configured set | Resets expiry; ≤ Request expiry |
| Making charges / rate / delivery / warranty / note / images | Input | No | as submit | |
| Save revision | Action | — | — | Notifies Customer with old vs new price |
| Withdraw Offer | Action | — | confirm | → WITHDRAWN; notifies Customer |

## Validation & rules

- Only while PENDING; blocked after ACCEPTED.
- Revision history retained internally.

## Empty / error / edge states

- Revision limit reached; Offer no longer PENDING.

## Related screens

VEN-S09 · VEN-S11
