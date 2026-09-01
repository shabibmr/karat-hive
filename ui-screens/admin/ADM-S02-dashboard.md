# ADM-S02 · Dashboard

| | |
|---|---|
| **User** | Platform Admin |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-003`–`FR-ADM-009` |

## Purpose

Platform health landing with metric panels and actionable queue counts.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | After login |
| Exit | Linked management screens with pre-filters |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Date-range selector | Filter / Sort | Yes | today / 7d / 30d / 90d / custom | Applies to trends |
| Queue: pending verifications | Display + Action | — | count + age oldest | → ADM-S07 |
| Queue: open abuse reports | Display + Action | — | count | → ADM-S21 |
| Queue: reviews awaiting moderation | Display + Action | — | count | → ADM-S16 |
| Customers metric | Display | — | total, new, active, suspended + trend | → ADM-S03 |
| Vendors metric | Display | — | by state + pending queue | → ADM-S05 / S07 |
| Requests metric | Display | — | by type/direction/state; ≥1 Offer %; zero-Offer expiry % | → ADM-S08 |
| Offers metric | Display | — | by state; mean Offers/Request; TTF Offer; accept/expiry rates | → ADM-S10 |
| Connections metric | Display | — | created; active vs closed; TTF Connection; Talk usage % | → ADM-S12 |
| Platform statistics | Display | — | indicative gold weight/value; mean Request value; funnel; Category/Region mix | Labelled indicative |

## Validation & rules

- Figures consistent with ADM-S17 for same period.
- Indicative values only (no true transaction data).

## Empty / error / edge states

- Zero-activity periods.

## Related screens

All list/queue screens linked above
