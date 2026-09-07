# ADM-S20 · Gold rate configuration

> **Status: Deferred.** Not in the current Admin Portal build scope. Blocked on the open Yahoo Finance redistribution-terms decision and pending new backend routes. Retained here as the authoritative screen spec.

| | |
|---|---|
| **User** | Platform Admin |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-031`, §7.4 |

## Purpose

Monitor Yahoo Finance–backed reference rates; configure poll/staleness; manual override when needed.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Config / rates |
| Exit | History view; override |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Source | Display | — | Yahoo Finance (default) | Manual fallback |
| Current rates by purity | Display | — | AED/g | 24K base; derived 22/21/18K |
| Source timestamp | Display | — | datetime | |
| Stale indicator | Display | Conditional | age | Default threshold 60 min |
| Feed refresh interval | Input | Yes | minutes | Default 15 |
| Staleness threshold | Input | Yes | minutes | Default 60 |
| Manual override per purity | Input | Conditional | AED/g | Reason + expiry required |
| Override reason | Input | Conditional | text | |
| Override expiry | Input | Conditional | datetime | Then resume Yahoo |
| Rate history | Display | — | timeline | Reconstruct historical valuations |
| Feed failure alert state | Display | — | after 2 h sustained | |
| Save | Action | — | — | Audit failover/override |

## Validation & rules

- Never show zero/fabricated rate; retain last good.
- Changes/failovers audit-logged.

## Empty / error / edge states

- Feed down; override active.

## Related screens

ADM-S19 · Customer rate displays
