# Seed

Run after `prisma migrate` against local Postgres from `backend/docker/docker-compose.yml`.

```bash
cd backend && npm run seed
```

Orchestrator (`index.ts`) calls, in order: `seedAdmin` → `seedTaxonomy` → `seedPlatformSettings` → `seedVendor`. Re-runs are idempotent. Override fixtures via `SEED_ADMIN_*` and `SEED_VENDOR_*` in `.env` (see `.env.example`). Do not commit `.env`.

### Repair auto-provision rows

One-off cleanup for Users created by the pre-fix AuthGuard auto-provision path (`+fb_` mobiles, synthetic `PENDING_*` licences, missing terms). Dry-run by default; never invents a replacement phone — soft-deletes and bumps `tokenVersion`.

```bash
cd backend && npm run repair:auto-provision -- --dry-run
cd backend && npm run repair:auto-provision -- --apply
```

Minimum contents for a demonstrable migrate (NFR-002 production-scale seed is later):

| Row                                                                                           | Why                                                                                                                                                                                                                                    |
| --------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| One `admin_profile` + `user` (email only — no password)                                       | Admin signs in with Google using that email (`adr/0010`); `FR-ADM-002` — no self-register                                                                                                                                             |
| The seven Emirates as flat `region` rows                                                      | Display and feed filter (`FR-ADM-025`); Customer default Region                                                                                                                                                                        |
| `platform_setting` defaults                                                                   | `request.lifetime_hours` = 48 (`C-07`); `bullion.minimum_value_aed` = 500 (`BR-010`); `request.max_concurrent_live` = 10; karat list; media limits |
| Optional: one Customer, one `ACTIVE` Vendor with Regions + one Type Subscription              | Lets Request publish + match without Admin clicks                                                                                                                                                                                      |

Do **not** seed production KYC document bytes. Do **not** invent competing-Vendor prices in fixtures that leak through Vendor presenters (`BR-008`).

Gold rates: either skip (bullion publish will 503) or insert a `MANUAL_OVERRIDE` row per karat with an expiry — Yahoo terms still `[BLOCKED]` for end-user display.
