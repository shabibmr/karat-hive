# VEN-S07 · Request filters & saved presets

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-009` |

## Purpose

Search, filter, sort Available Requests; save named presets across sessions.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | VEN-S06 |
| Exit | Apply → VEN-S06 with filters |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Filter — Request type | Filter / Sort | No | enum multi | |
| Filter — direction | Filter / Sort | No | BUY / SELL | |
| Filter — Category | Filter / Sort | No | taxonomy | |
| Filter — Region | Filter / Sort | No | taxonomy | |
| Filter — weight range | Filter / Sort | No | g min–max | |
| Filter — budget range | Filter / Sort | No | AED | |
| Filter — purity | Filter / Sort | No | karat | |
| Filter — time since publication | Filter / Sort | No | window | |
| Sort | Filter / Sort | No | newest · expiring soonest · highest value · fewest Offers | |
| Free-text search | Filter / Sort | No | string | Matches reference + notes |
| Preset name | Input | Conditional | string | When saving |
| Save preset | Action | — | — | Cross-session |
| Apply preset | Action | — | list of named | |
| Reset filters | Action | — | — | One-tap when zero results |
| Apply | Action | — | — | |

## Validation & rules

- Default filter preset configurable in Settings (VEN-S18).

## Empty / error / edge states

- Zero results → offer reset.

## Related screens

VEN-S06 · VEN-S18
