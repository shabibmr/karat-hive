# VEN-S22 · Subscription by Request type

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-031` |

## Purpose

Manage independent subscription entitlements per Request type required for match inclusion and Offers.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Dashboard entitlement panel; settings; blocked Offer/match CTA |
| Exit | Subscribe/upgrade flow (billing external or in-app as implemented) |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Find An Ornament entitlement | Display | — | ACTIVE / GRACE / EXPIRED / none | Independent product |
| Sell Old Gold entitlement | Display | — | state | |
| Gold Coins entitlement | Display | — | state | |
| Gold Bullion entitlement | Display | — | state | |
| Period start / end | Display | — | per entitlement | |
| Price (AED snapshot) | Display | — | decimal | |
| Renewal date | Display | — | datetime | |
| Subscribe / upgrade | Action | — | per type | Upgrades immediate |
| Downgrade / cancel notice | Display | — | — | Downgrades at period end |
| Match eligibility explanation | Display | — | copy | Also needs VERIFIED+ACTIVE, Category, Region |

## Validation & rules

- Without active entitlement for a type: not in match set; cannot Offer on that type.
- Prices/periods Admin-configured (ADM-S19).

## Empty / error / edge states

- Grace period messaging; expired → no new matches for type.

## Related screens

VEN-S05 · VEN-S06 · VEN-S09
