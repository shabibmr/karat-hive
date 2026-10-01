# VEN-S10 · Withdraw Offer

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-014`, [`adr/0015`](../../docs/adr/0015-offers-live-with-their-request.md) |

## Purpose

Show a sent Offer's terms and let the Vendor withdraw it while it is PENDING. Offers cannot be revised; to change terms the Vendor withdraws and submits a new Offer. (The file name keeps the old "revise" wording so links stay stable.)

## Entry / exit

| Direction | Path |
|---|---|
| Entry | VEN-S08 / VEN-S11 Pending |
| Exit | VEN-S11; VEN-S09 to submit a new Offer after withdrawing |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Current terms | Display | — | all Offer fields | Read-only |
| Seen by Customer | Display | — | badge | From `viewedByCustomerAt` |
| No-edit notice | Display | — | copy | "Offers cannot be updated once sent…" |
| Withdraw Offer | Action | Conditional | confirm | Only while PENDING → WITHDRAWN; notifies Customer |

## Validation & rules

- Withdraw only while PENDING; blocked after ACCEPTED.

## Empty / error / edge states

- Offer no longer PENDING (`OFFER_NOT_PENDING`).

## Related screens

VEN-S09 · VEN-S11
