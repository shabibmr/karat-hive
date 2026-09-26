# VEN-S01 · Registration — business details

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-001`, `FR-VEN-025` |

## Purpose

Self-register a Vendor business; account enters `PENDING_VERIFICATION` (marketplace locked).

## Entry / exit

| Direction | Path |
|---|---|
| Entry | App role Vendor / register |
| Exit | VEN-S02 KYC; VEN-S03 Awaiting Approval |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Legal business name | Input | Yes | string ≤ 200 | Re-verify if later changed |
| Trading name | Input | Yes | string ≤ 200 | Public-facing |
| Trade licence number | Input | Yes | string ≤ 50 unique | |
| Licence expiry date | Input | Yes | date | Entity field |
| Emirate / Region | Input | Yes | Region taxonomy | |
| Business address | Input | Yes | text | |
| Contact person name | Input | Yes | string ≤ 100 | |
| Mobile number | Input | Yes | E.164 | OTP verified before submit |
| OTP | Input | Yes | numeric | |
| Business email | Input | Yes | email | |
| Service Categories | Input | Yes | multi-select ≥1 | Matching |
| Served Regions | Input | Yes | multi-select ≥1 | Matching |
| Accept Vendor agreement / Privacy | Input | Yes | checkbox | Assumed with registration |
| Submit registration | Action | — | — | → PENDING_VERIFICATION |

## Validation & rules

- OTP required before submit.
- No Request/Offer access until ACTIVE (`BR-002`).

## Empty / error / edge states

- Duplicate mobile/licence; OTP fail.

## Related screens

VEN-S02 · VEN-S03 · VEN-S04
