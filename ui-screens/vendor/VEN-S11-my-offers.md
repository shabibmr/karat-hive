# VEN-S11 · My Offers

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-016`, `FR-VEN-017`, `FR-VEN-018`, `FR-VEN-019` |

## Purpose

All submitted Offers under tabs Pending / Accepted / Rejected–Expired.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Dashboard; nav Offers |
| Exit | Detail; Connection; revise |

## Fields

### Common chrome

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Tab: Pending (count) | Filter / Sort | — | — | Matches dashboard |
| Tab: Accepted (count) | Filter / Sort | — | — | |
| Tab: Rejected / Expired (count) | Filter / Sort | — | — | Includes WITHDRAWN |
| Filter — date range | Filter / Sort | No | — | |
| Filter — Request type | Filter / Sort | No | — | |
| Search — Request reference | Filter / Sort | No | string | |
| Row: Request summary | Display | — | — | |
| Row: offered price | Display | — | AED | |
| Row: submission time | Display | — | datetime | |
| Row: status | Display | — | enum | |
| Open Offer detail | Action | — | — | |

### Pending tab extras

| Field / UI element | Kind | Notes |
|---|---|---|
| Countdown to expiry | System | Prioritise &lt; 24 h |
| Revise | Action | → VEN-S10 |
| Withdraw | Action | → VEN-S10 |

### Accepted tab extras

| Field / UI element | Kind | Notes |
|---|---|---|
| Acceptance time / elapsed | Display | |
| Link to Connection | Action | → VEN-S13 |
| No Talk flag | Display | Prompt contact |

### Rejected / Expired tab extras

| Field / UI element | Kind | Notes |
|---|---|---|
| Specific state | Display | REJECTED / EXPIRED / WITHDRAWN |
| Awarded elsewhere notice | Display | No winning price/Vendor (`BR-008`) |
| Decline reason category | Display | If Customer supplied |
| Read-only | Display | No actions |

## Validation & rules

- Competitive context never discloses other Vendors’ terms.

## Empty / error / edge states

- Empty per tab.

## Related screens

VEN-S10 · VEN-S13 · VEN-S08
