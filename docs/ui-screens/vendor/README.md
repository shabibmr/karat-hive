# Vendor screens

**User:** Vendor (jeweller / gold business)  
**Platform:** Mobile app — Vendor mode (same dual-mode binary as Customer)  
**Optimisation:** Dense working tool. Scan → filter → open → offer in at most two taps from the feed for Submit Offer.

## Shell modes

| Vendor state | Shell | Marketplace access |
|---|---|---|
| `PENDING_VERIFICATION`, more-info | **VEN-S03** Awaiting Approval | None |
| `VERIFIED` but not `ACTIVE` | Constrained onboarding (categories/regions) | None |
| `ACTIVE` + type subscription | Full app (dashboard, feed, offers) | Yes for subscribed Request types |
| `SUSPENDED` / `DEACTIVATED` / `REJECTED` | Login refused or status message | None |

## Primary destinations (ACTIVE)

| Area | Screens |
|---|---|
| Dashboard | VEN-S05 |
| Requests | VEN-S06, VEN-S07, VEN-S08 |
| Offers | VEN-S09, VEN-S10, VEN-S11 |
| Connections | VEN-S12, VEN-S13 |
| Profile / commercial | VEN-S15, VEN-S16, VEN-S22 |
| History / reviews | VEN-S14, VEN-S20 |
| Notifications / settings | VEN-S17, VEN-S18 |

## Identity masking

Customer name, mobile, email, exact address are **absent** from Request list/detail until that Vendor’s Offer is accepted. Show pseudonymous label + coarse Region + trust signals only (`BR-006`, `NFR-013`). Competitor prices are never shown (`BR-008`).

## Inventory

See [../README.md](../README.md) for the full VEN-S01…S22 table.
