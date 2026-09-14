# Product note · Vendor Type Subscription choice at onboarding

**Date:** 2026-09-11  
**Status:** Open product/spec gap (not an SRS contradiction — an underspecified capture point)  
**Source:** Product clarification session (Vendor registration / subscription channels)

## Intended product rule (stated)

1. Customers have **four Request types** (the four marketplace “channels”).
2. Each Request type has its **own Vendor subscription fee**.
3. During **Vendor onboarding**, the Vendor **multi-selects** which types they want to receive.
4. After **subscription payment** is received, Admin **locks** those entitlements.
5. The Vendor then receives **only** Requests under the locked Type Subscriptions.

## Already in the docs

| Point | Authority |
|---|---|
| Four Request types | `CONTEXT.md` (Request Type); `FR-CUS-006` / `010` / `011` / `012` |
| Revenue = subscription sold **separately per Request type** | `C-09`, `FR-VEN-031`, `adr/0005` |
| Vendor may hold one or more type entitlements | `FR-VEN-031` AC2 |
| No match / no Offer without active entitlement for that type | `FR-VEN-031` AC3, `BR-002` |
| Admin grants entitlements after **off-platform** payment; Vendor has no self-checkout | `AD-API-04` (API inventory; `[PROPOSED]`) |
| Vendor UI for entitlements | `VEN-S22` (display + subscribe deep-link) |

Terminology: use **Request Type** / **Type Subscription**, not “channel.”

## Not in the docs (and not built)

- **Multi-select of the four Request types during Vendor registration / onboarding** is **not** specified on `VEN-S01`.
- `VEN-S01` multi-selects **Service Categories** and **Served Regions** only.
- Registration / onboarding code likewise does **not** collect preferred Request types.
- Docs place subscription management on `VEN-S22` + Admin grant (`POST /v1/admin/vendors/{id}/subscriptions`), not as an onboarding field.

## Decision needed

Whether onboarding should capture:

- **A)** Preferred Request types (interest list) before payment, then Admin locks paid ones; or  
- **B)** Keep current model: no type choice at register; Vendor contacts support / Admin grants after payment (`AD-API-04` + `VEN-S22`).

Until decided, do **not** silently add Request-type multi-select to `VEN-S01`.
