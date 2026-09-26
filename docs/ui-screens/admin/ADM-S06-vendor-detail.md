# ADM-S06 · Vendor detail

| | |
|---|---|
| **User** | Platform Admin |
| **Platform** | Admin Portal (web) |
| **Requirements** | `FR-ADM-014`, `FR-ADM-016` |

## Purpose

Full Vendor record, KYC viewer, performance, activation controls.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | ADM-S05 / S07 |
| Exit | Verification actions; lists |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Business profile (all fields) | Display | — | legal, trading, licence, address, contact, email, hours, away | |
| KYC documents | Display | — | viewer | Each view audit-logged |
| Verification history | Display | — | Admin + rationale | |
| Categories / Regions served | Display | — | — | |
| Type subscriptions | Display | — | per Request type state | |
| Offer history | Display | — | list | |
| Connections | Display | — | list | |
| Reviews received | Display | — | list | |
| Performance: acceptance rate, mean response time, expiry rate, rating trend | Display | — | metrics | |
| Verify / Reject / Request more info | Action | — | — | May deep-link ADM-S07 |
| Suspend | Action | — | reason | Blocks Requests/Offers; keeps ACTIVE Connections |
| Reactivate | Action | — | — | If KYC unexpired |
| Deactivate | Action | — | reason | Terminal; leave matching |

## Validation & rules

- State transitions require reason; notify Vendor; audit log.

## Empty / error / edge states

- Expired KYC on reactivate.

## Related screens

ADM-S07 · ADM-S05
