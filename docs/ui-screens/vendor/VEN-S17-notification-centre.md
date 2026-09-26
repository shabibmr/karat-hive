# VEN-S17 · Notification centre

| | |
|---|---|
| **User** | Vendor |
| **Platform** | Mobile — Vendor mode |
| **Requirements** | `FR-VEN-026` |

## Purpose

In-app 90-day notification history with deep links for Vendor business events.

## Entry / exit

| Direction | Path |
|---|---|
| Entry | Bell / push |
| Exit | Deep-linked screen |

## Fields

| Field / UI element | Kind | Required | Type / options | Notes |
|---|---|---|---|---|
| Notification list | Display | — | 90 days | |
| Title / body | Display | — | — | |
| Category | Display | — | new Request, accept, reject, expiry, edit, cancel, verification, KYC expiry, review, announcement | |
| Timestamp | Display | — | datetime | |
| Read / unread | Display | — | — | |
| Open deep link | Action | — | — | |

## Triggers

New matched Request (≤60 s); Offer accepted/rejected; Offer expiring 6 h; expired; Request edited while PENDING Offer held; Request cancelled; verification outcome; KYC nearing expiry; new review; announcement.

Quiet hours / business hours may queue delivery (VEN-S18 / VEN-S16).

## Empty / error / edge states

- Empty list.

## Related screens

VEN-S18 · action targets
