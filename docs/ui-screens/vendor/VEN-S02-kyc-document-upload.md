# VEN-S02 · KYC document upload

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-002` |

## Purpose

Upload business documentation for Admin verification; encrypted private storage.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | After registration; Awaiting Approval re-upload |
| Exit | VEN-S03 status |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Trade licence document | Input | Yes | PDF/JPEG/PNG ≤ 10 MB | `TRADE_LICENCE` |
| Emirates ID (authorised contact) | Input | Yes | PDF/JPEG/PNG | `EMIRATES_ID` |
| VAT registration certificate | Input | No | file | |
| Gold/precious-metal trading permit | Input | No | file | |
| Shop tenancy contract | Input | No | file | |
| Document expiry date (per doc) | Input | Conditional | date | Where applicable; 30-day reminders |
| Upload progress | System | — | — | |
| Replace document | Action | Conditional | — | On reject/resubmit |
| Submit / Save | Action | — | — | |

## Validation & rules

- Docs never exposed to Customers or other Vendors.
- Rejected verification may replace and resubmit.

## Empty / error / edge states

- Format/size rejection; missing mandatory docs.

## Related screens

VEN-S03 · VEN-S01
