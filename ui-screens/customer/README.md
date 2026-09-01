# Customer screens

**User:** Customer  
**Platform:** Mobile app — Customer mode (iOS / Android, shared dual-mode binary)  
**Optimisation:** Infrequent, high-intent sessions. Request creation completable in under 2 minutes for a returning user. Offer comparison legible without horizontal scroll. Live Requests hard-expire in **48 hours**.

## Shell & navigation (inferred from FR set)

Typical primary destinations:

| Area | Screens |
|---|---|
| Home / Requests | CUS-S02, CUS-S10 |
| Create | CUS-S03 → type-specific create → CUS-S08 → CUS-S09 |
| Offers | CUS-S11, CUS-S12, CUS-S13, CUS-S14 |
| Connections | CUS-S16, CUS-S15 |
| History | CUS-S17 |
| Profile / Settings | CUS-S20, CUS-S21 |
| Notifications | CUS-S19 |

## Auth gates

1. **Registration / login** — UAE mobile + OTP (CUS-S01).
2. **One-time OAuth** — required before first Request **publish** (not before draft composition). Profile and drafts may work without OAuth; publish is refused server-side (`BR-001`).
3. Suspended / deactivated accounts cannot authenticate.

## Identity masking

Until Acceptance, Vendor identity on Offers is **masked** (label, Region, rating, deal count). Real Vendor business details appear only on **CUS-S15** after Mark as Interested.

## Inventory

See [../README.md](../README.md) for the full CUS-S01…S22 table.
