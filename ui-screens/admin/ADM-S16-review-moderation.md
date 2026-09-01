# ADM-S16 · Review moderation queue

| | |
|---|---|
| **User** | Platform Admin |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-026` |

## Purpose

Hold-for-approval queue for reviews and Vendor responses (mandatory mode; not a toggle).

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Dashboard queue |
| Exit | Decision; next item |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Queue list | Display | — | new / flagged / auto-flagged | Reviews + Vendor responses |
| Author | Display | — | Customer or Vendor | |
| Reviewed party | Display | — | — | |
| Connection link | Display | — | — | |
| Star rating | Display | — | 1–5 | |
| Comment text | Display | — | full | |
| Vendor response text | Display | Conditional | ≤ 500 | |
| Decision: Approve | Action | — | publish | Recompute aggregates |
| Decision: Reject | Action | — | reason to author | Withhold |
| Decision: Redact | Action | — | edit offending passage | Original retained internally |
| Rationale | Input | Yes | text | On reject/redact |
| Flag context | Display | Conditional | unfair flag | From VEN-S20 |

## Validation & rules

- Not visible until approved.
- Only PUBLISHED contribute to aggregates.
- Every decision audit-logged.

## Empty / error / edge states

- Empty queue.

## Related screens

ADM-S02 · ADM-S04 · ADM-S06
