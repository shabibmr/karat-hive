# ADM-S17 · Reports & analytics

| | |
|---|---|
| **User** | Platform Admin |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-027`, `FR-ADM-028` |

## Purpose

Operational/business reports with charts, filters, and export.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Nav Reports |
| Exit | Export download |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Report type | Input | Yes | acquisition/retention; Vendor league; Request volume; Offer competitiveness; funnel; liquidity gaps; rating distribution | |
| Date range | Filter / Sort | Yes | — | |
| Filter Region | Filter / Sort | No | — | |
| Filter Category | Filter / Sort | No | — | |
| Results table | Display | — | — | |
| Charts | Display | — | — | |
| Export CSV | Action | — | — | Honours filters |
| Export XLSX | Action | — | — | |
| Export chart PNG | Action | — | — | |
| Async large export notice | System | Conditional | &gt; 50k rows | Time-limited link |
| PII export watermark | System | Conditional | Admin, time, purpose | Audit-logged |

## Validation & rules

- Liquidity-gap report: Category/Region with Requests but no matched Vendors.
- Indicative values labelled as such.

## Empty / error / edge states

- Empty period; export failure.

## Related screens

ADM-S02 · ADM-S22
