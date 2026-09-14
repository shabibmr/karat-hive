# CUS-S23 · Guest Landing

| | |
|---|---|
| **User** | Guest (unauthenticated, Customer mode) |
| **Platform** | Mobile — Customer mode |
| **Requirements** | [`adr/0011`](../../docs/adr/0011-guest-first-landing.md). Working rule until SRS Appendix C is rewritten. Related: `FR-CUS-001`, `FR-CUS-002`, `FR-CUS-005`, `adr/0010` |
| **Status** | `[PROPOSED]` screen ID — next unused Customer ID. Never reuse. |

## Purpose

Cold-start surface when there is no live session. Discover the four Request Types, read how the loop works, start a create flow, or log in. Not the signed-in Dashboard (`CUS-S02`).

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Splash, no live token / expired / refresh failed |
| Exit — service | CUS-S03 (or type-specific create) as Guest |
| Exit — Log in | CUS-S01 (same Login as publish gate) |
| Exit — Jeweller | `VEN-S01` Vendor signup |
| Not an entry | Returning Customer or Vendor with a live token (they skip this screen) |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Log in | Action | — | text button, top-right | Subtle. Same Login as CUS-S09 publish gate |
| Find jewellery | Action | — | service card | Domain type: Find An Ornament. Display copy may be friendlier |
| Sell my gold | Action | — | service card | Domain type: Sell Old Gold |
| Coins | Action | — | service card | Domain type: Buy/Sell Gold Coin(s) |
| Bullion | Action | — | service card | Domain type: Buy/Sell Gold Bullion |
| How this works | Display / Action | — | expandable or sheet, one pattern for all four | Shape: post → get Offers → accept → Talk on WhatsApp. Type-specific bits only (e.g. bullion minimum) |
| Are you a jeweller? Register here. | Action | — | footer text link | Vendor signup. Not a filled button next to the four cards |

## Validation & rules

- No session required to render this screen or to open a service.
- Splash must not show this screen when a valid session exists (`adr/0011`).
- Four services only. No fifth card. No prominent Jeweller CTA.
- Guest create draft is in-memory; this screen does not persist it.

## Empty / error / edge states

- Google cancel from Login: return here (or to the in-memory create form if that was the origin).
- Network fail is a Login-screen problem, not this landing.

## Related screens

CUS-S01 Login / signup · CUS-S02 Dashboard (signed-in, different screen) · CUS-S03…S09 create · VEN-S01 Vendor signup
