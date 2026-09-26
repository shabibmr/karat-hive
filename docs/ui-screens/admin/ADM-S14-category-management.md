# ADM-S14 · Category management [REMOVED]

| | |
|---|---|
| **User** | Platform Admin |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-024`, `BR-019` |

## Purpose

*(REMOVED per ADR 0014: Category taxonomy entity has been completely removed from the system architecture.)*

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Config nav |
| Exit | Save taxonomy |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Category tree | Display | — | parent / child | Two-level |
| Name (English) | Input | Yes | string | |
| Name (Arabic) | Input | Yes | string | |
| Icon | Input | No | asset | |
| Display order | Input | Yes | integer | |
| Active flag | Input | Yes | boolean | |
| Create | Action | — | — | |
| Rename | Action | — | — | |
| Activate / Deactivate | Action | — | — | Deactivate (in-use cannot be removed) |

## Validation & rules

- Deactivate hides from new selection; preserves associations.
- Changes apply to new Requests only (no retro reclassify).

## Empty / error / edge states

- In-use categories cannot be removed (deactivate only).

## Related screens

ADM-S15 · ADM-S19
