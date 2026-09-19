# backend

NestJS + Fastify monolith on Prisma/PostgreSQL. API and workers ship as **one binary**, selected at runtime by `KH_ROLE` (`api` | `worker` | `all`; `APP_ROLE` is a legacy alias).

## Layers

`eslint-plugin-boundaries` enforces this in `eslint.config.mjs` — `npm run lint` is the authority, not this list.

```
edge/      HTTP concerns: guards, interceptors, error filter, validation, rate limit
modules/   one folder per bounded context — the business code
platform/  ports + adapters, Prisma, outbox, scheduler, lifecycle
shared/    pure domain primitives: Clock, Money, Karat, Purity, Weight, Result
config/    Zod-validated env
```

Dependencies flow inward: `shared` imports nothing but `shared`; `platform` may reach `shared`/`config`; `edge` may reach everything but only a module's **public barrel**; modules may reach anything.

**Crossing a module boundary goes through `src/modules/<name>/index.ts`.** Deep-importing another module's service is a lint error. When you add a cross-module export, add it to that barrel.

## Module shape

```
modules/<context>/
  controller/    routes, Zod schemas, HTTP mapping
  application/   services — orchestration, transactions
  domain/        pure logic: state machines, validators, generators
  repository/    Prisma access
  presenter/     response shaping, often one per audience (…-customer, …-vendor)
  <context>.module.ts
  index.ts       the public barrel
```

Tests are `*.spec.ts` beside the file they cover. `test/` at the root holds the cross-cutting suites (contract, integration, concurrency, masking, performance) and runs under a separate Vitest config.

## Edge chain

Registered globally in `app.module.ts`: `AuthGuard` → `RateLimitGuard` → `IdempotencyInterceptor` → `EnvelopeInterceptor` → `MaskingInterceptor` → `HttpErrorFilter`.

Consequences for controller code:

- Return the **payload**; `EnvelopeInterceptor` wraps it in `{ data, meta }`.
- Routes are authenticated by default. Opt out with `@Public()`; widen with `@AdminOnly()`, `@AllowSuspended()`.
- `MaskingInterceptor` scans every response for identity keys and turns a leak into a 500. A route that legitimately reveals identity must declare `@RevealsIdentity()`.
- Throw `ApiException(status, ErrorCode, details?)` rather than Nest's HTTP exceptions, so the error envelope stays uniform.
- Validate input with the Zod pipe; the same schemas feed OpenAPI generation.

## Postgres does the infrastructure

There is no message broker and no Redis — every async primitive is a Postgres table, and all three are lease-based so multiple worker instances are safe:

- **Outbox** (`platform/outbox/`) — producers write `outbox_event` inside the business transaction; the claimer leases rows and the dispatcher delivers with backoff and a max-attempts cap.
- **Job locks** (`platform/scheduler/`) — `job_lock` upsert wins only when the existing lease has expired.
- **Rate limiting** (`edge/rate-limit/`) — token buckets in `rate_limit_bucket`, scopes declared in `rate-limit.policy.ts`.

Wrap multi-write work in `withTx(prisma, tx => …)` and pass the `tx` down through repositories, so outbox writes and audit rows commit atomically with the change.

## Ports and adapters

`platform/ports/*.port.ts` declares the interface; `platform/adapters/<vendor>/` implements it. Add a vendor by adding an adapter and binding it in `platform.module.ts` — callers depend on the port.

Storage today is **local disk** and **Supabase Storage** (KYC documents). Push is FCM + APNs behind a routed adapter; SMS is a console stub while OTP send is deferred; gold rates come from Yahoo.

## Prisma

`prisma/schema.prisma` is the model. **`prisma/sql/` is not optional** — partial unique indexes and `pg_trgm` cannot be expressed in Prisma schema and are applied as raw SQL after `migrate deploy`. CI runs `psql -f prisma/sql/extensions.sql -f prisma/sql/partial-indexes.sql` before seeding; a local DB set up without them will pass tests that production would fail.

Taxonomy is **flat** — Category and Region have no parent (`20260915120000_flatten_taxonomy`).

## Env

`config/env.ts` is a Zod schema that fail-fasts at boot. Adding a setting means adding it there, and adding it to both CI workflows if tests need it. A missing or well-known-placeholder `JWT_ACCESS_SECRET` refuses to boot in every environment.

## Contract drift

`npm run openapi:check` regenerates `openapi/openapi.json` from the Nest routes + Zod schemas and fails on any difference. Changing a route or schema means regenerating and committing it.

## Known dead code

`modules/requests/` carries an unwired plural set — `requests.service.ts`, `requests.controller.ts`, `requests.repository.ts` and their specs. `RequestsModule` registers only the **singular** `RequestService` / `RequestController` / `RequestRepository`. Edit the singular files; the plural ones serve no route.

## OTP is bypassed

Registration accepts a self-reported `mobileNumber` with no OTP challenge while SMS send is deferred, and stores `mobileVerifiedAt = null` for that path. Treat an unverified mobile as an expected state, and keep the bypass branch intact unless asked to close it.
