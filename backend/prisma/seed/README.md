# Seed

Run after `prisma migrate` against local Postgres from `backend/docker/docker-compose.yml`.

```bash
cd backend && npm run seed
```

Orchestrator (`index.ts`) calls, in order: `seedAdmin` → `seedTaxonomy` → `seedPlatformSettings` → `seedVendor` (CP1-A03b). Re-runs are idempotent. Override fixtures via `SEED_ADMIN_*` and `SEED_VENDOR_*` in `.env` (see `.env.example`). Do not commit `.env`.

Minimum contents for a demonstrable migrate (NFR-002 production-scale seed is later):

| Row                                                                                           | Why                                                                                                                                                                                                                                    |
| --------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| One `admin_profile` + `user` (email/password, TOTP unset in local)                            | Admin portal login; `FR-ADM-002` — no self-register                                                                                                                                                                                    |
| UAE `region` tree (emirate → area)                                                            | Matching (`FR-SYS-002`), Customer default Region                                                                                                                                                                                       |
| `category` two-level tree                                                                     | Matching, Request create                                                                                                                                                                                                               |
| `platform_setting` defaults                                                                   | `request.lifetime_hours` = 48 (`C-07`); `bullion.minimum_value_aed` = 500 (`BR-010`); `offer.validity_hours_options` = `[12,24,48]`; `offer.default_validity_hours` = 24; `request.max_concurrent_live` = 10; karat list; media limits |
| Optional: one Customer, one `ACTIVE` Vendor with Categories + Regions + one Type Subscription | Lets Request publish + match without Admin clicks                                                                                                                                                                                      |

Do **not** seed production KYC document bytes. Do **not** invent competing-Vendor prices in fixtures that leak through Vendor presenters (`BR-008`).

Gold rates: either skip (bullion publish will 503) or insert a `MANUAL_OVERRIDE` row per karat with an expiry — Yahoo terms still `[BLOCKED]` for end-user display.
