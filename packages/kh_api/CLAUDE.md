# kh_api

Typed API surface over `kh_core`'s `KhApiClient`. Despite the "contract-first" description, **these clients are hand-written** — OpenAPI generation is deferred, so `backend/openapi/openapi.json` and this package can drift. When a call misbehaves, diff against the Nest controller.

## Two layers on KhApi

`KhApi` exposes sub-clients — `api.requests`, `api.offers`, `api.connections`, `api.reviews`, `api.notifications`, `api.vendor`, … — and *also* carries a long tail of flat backwards-compat methods (`api.publishRequest(…)`, `api.acceptOffer(…)`) that just forward to them.

**Write new code against the sub-clients.** Leave the flat methods alone; features still call them.

`src/clients/` is one file per backend area; `src/dtos/` holds the freezed wire types.

## Mapping is this package's job

DTOs are mapped to `kh_domain` types here so generated wire shapes never reach controllers or widgets. A screen should receive `RequestForCustomer`, not a raw `Map`.

Clients return `Result<T>`; envelope unwrapping happens in `KhApiClient`. Pass `unwrapData: false` only when you need `meta` alongside `data` (see `RequestDraftSave.fromEnvelope`).

Presenter-specific types are audience-split the same way the backend's presenters are: `RequestForCustomer` vs the vendor feed types, `OfferForCustomer` vs `OfferForVendor`. Pick the one matching the caller's role.

Run `melos run gen` after touching a DTO, and add new exports to `lib/kh_api.dart`.
