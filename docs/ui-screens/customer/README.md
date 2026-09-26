# Customer screens

**User:** Customer  
**Platform:** Mobile app — Customer mode (iOS / Android, shared dual-mode binary)  
**Optimisation:** Infrequent, high-intent sessions. Request creation completable in under 2 minutes for a returning user. Offer comparison legible without horizontal scroll. Live Requests hard-expire in **48 hours**.

## Shell & navigation (inferred from FR set)

Typical primary destinations:

| Area | Screens |
|---|---|
| Guest (no session) | CUS-S23 |
| Login / signup | CUS-S01 |
| Home / Requests | CUS-S02 (signed-in Dashboard), CUS-S10 |
| Create | CUS-S03 → type-specific create → CUS-S08 → CUS-S09 |
| Offers | CUS-S11, CUS-S12, CUS-S13, CUS-S14 |
| Connections | CUS-S16, CUS-S15 |
| History | CUS-S17 |
| Profile / Settings | CUS-S20, CUS-S21 |
| Notifications | CUS-S19 |

## Auth gates

1. **Cold start** — no live token → Guest Landing (`CUS-S23`). Live Customer token → Dashboard (`CUS-S02`). (`adr/0011`)
2. **Login** — Google only (`adr/0010`), on CUS-S01. Same screen for corner Log in and publish gate. OTP proves a mobile number; it is not a login.
3. **Publish** — Guest must log in; Customer login auto-publishes. Server still refuses publish without a bound Google session (`BR-001`).
4. Suspended / deactivated accounts cannot authenticate (blocked screen, not Guest).

## Identity masking

Until Acceptance, Vendor identity on Offers is **masked** (label, Region, rating, deal count). Real Vendor business details appear only on **CUS-S15** after Mark as Interested.

## Inventory

See [../README.md](../README.md) for the full CUS-S01…S23 table.
