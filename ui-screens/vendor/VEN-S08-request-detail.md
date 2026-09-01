# VEN-S08 · Request detail (masked Customer)

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-010`, `FR-VEN-011` |

## Purpose

Full Request attributes for Offer decision; Customer masked; competitive count only.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | VEN-S06 |
| Exit | VEN-S09 Submit Offer or VEN-S10 View/Revise |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| All images (full resolution) | Display | — | gallery | EXIF stripped |
| Specification (type-specific) | Display | — | weight, purity, ornament, coins, bullion… | |
| Budget | Display | — | AED range / flexible | |
| Notes | Display | — | text | |
| Category / Region | Display | — | — | |
| Publication time | Display | — | datetime | |
| Expiry | System | — | countdown | |
| Offers already submitted (count) | Display | — | integer | No prices/terms of others (`BR-008`) |
| Customer masked label | Display | — | e.g. Customer · Dubai · 3 previous deals | No name/mobile/email/address |
| Customer rating signal (aggregate) | Display | Conditional | limited history rules | Visible to Vendors only (`BR-018`) |
| Submit Offer | Action | Conditional | — | If no PENDING Offer |
| View / Revise Offer | Action | Conditional | — | If PENDING exists → VEN-S10 |
| Report Request | Action | — | — | → VEN-S21 |
| Mark viewed | System | — | — | Decrements New Requests |

## Validation & rules

- Identifying Customer fields **absent** from API, not client-hidden.
- Free-text contact exchange blocked by policy scanners where detected.

## Empty / error / edge states

- Request closed/expired since open: actions disabled.

## Related screens

VEN-S09 · VEN-S10 · VEN-S21
