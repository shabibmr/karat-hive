# Offers live with their Request; no revision, no Offers-received state

An Offer expires when its Request hard-expires. The Vendor no longer picks a validity window. An Offer cannot be revised: to change terms, the Vendor withdraws it and submits a new one. A Request stays `PUBLISHED` while Offers arrive. There is no `OFFERS_RECEIVED` state. Every Offer states the weight (grams) and karat it prices.

**Why.** Product changed this in code on 20 September 2026 (commit `0fc3d1b`) and confirmed it in the 1 October 2026 docs cleanup. A Request already has a fixed 48-hour life (`C-07`). A second, shorter clock per Offer added choices without buying anything: the Customer can't act on an Offer after the Request expires anyway. Revision history added screens (`VEN-S10` revise) and rules (`OFFER_REVISION_LIMIT`) for what withdraw-and-resubmit already covers. `OFFERS_RECEIVED` only restated `offerCount > 0`, and had to fall back to `PUBLISHED` when the last pending Offer expired. Weight and karat on the Offer let the Customer compare like with like.

**What changes.**

| Before | Now |
|---|---|
| Vendor picks validity 12 / 24 / 48 h, default 24 h, clamped to the Request's expiry (`FR-VEN-013`) | `offer.expires_at` = `request.expires_at`, set at submission |
| Up to 3 revisions (`OFFER_REVISION_LIMIT`), revision history shown to the Customer | `POST /v1/offers/{id}/revise` returns `403 OFFER_REVISION_NOT_ALLOWED`. Withdraw, then submit again (`BR-009` still allows one pending Offer per Vendor per Request) |
| `PUBLISHED → OFFERS_RECEIVED` on the first Offer; back to `PUBLISHED` if the last pending Offer expires | The Request stays `PUBLISHED` until `ACCEPTED`, `EXPIRED`, `CANCELLED` or `REMOVED`. `offerCount` carries "has Offers" |
| Offer terms: price, making charges, rate per gram, delivery, warranty, note | Plus required `weightGrams` and `purityKarat` |

**Consequences.** `offer_revision` and `offer.revision_count` remain in the schema, unused, until a migration drops them. The `offer.revised` event and its notification are no longer emitted. The Offer T−6 h warning coincides with the Request's T−6 h warning. SRS v1.6 rewrites `FR-VEN-013`, the revise requirement, §5.2 and §5.3 to match.

**Considered options.** Keep Vendor-chosen validity and revision, and restore them in code. Rejected: Product confirmed the simpler model.
