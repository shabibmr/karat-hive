# backend

Single Node.js monolith (`C-11`): HTTP API and workers in one deployable, PostgreSQL as the only datastore (`C-12`).

Layout matches `docs/Architecture-Backend.md` §21. No npm workspaces inside this tree. Flutter clients live under `apps/` and `packages/`, not here.

Physical schema: `prisma/schema.prisma` (companion `docs/Physical-Data-Model.md`). Partial uniques and `pg_trgm` live in `prisma/sql/` because Prisma cannot express them. Those SQL files are folded into the initial Prisma migration.

Build order and backlog: [`docs/Backend-Implementation-Plan.md`](../docs/Backend-Implementation-Plan.md). P0/P1 review fixes: [`docs/Backend-Gap-Fix-Plan.md`](../docs/Backend-Gap-Fix-Plan.md).

## Local run (no Docker)

Needs Node 20+ and, for `/ready` and later domain work, a local PostgreSQL 16 with `pgcrypto` and `pg_trgm`. The API process itself starts without a database: `GET /health` is liveness, `GET /ready` is the DB check.

`JWT_ACCESS_SECRET` is required (min 16 characters). The process refuses to boot with a missing or banned-default secret. Copy `.env.example` and keep the example secret or replace it.

`AuthGuard` accepts either an app-issued HS256 access JWT or a Firebase ID token (RS256, verified against Google JWKS for `FIREBASE_PROJECT_ID`). Flutter clients using Google Sign-In send the Firebase ID token as `Authorization: Bearer`. First-time Firebase users are auto-provisioned as `VENDOR`; Admin must already exist (seed) and match by email.

```bash
cp .env.example .env          # then set DATABASE_URL to your local Postgres
npm install
npx prisma generate
npx prisma migrate deploy     # skip until Postgres exists
npm run start:dev
```

```
GET http://127.0.0.1:3000/health   # 200 even if Postgres is down (development)
GET http://127.0.0.1:3000/ready    # 503 until Postgres exists and migrate deploy has run
```

Production (`NODE_ENV=production`) fail-fasts if PostgreSQL is down or migrations are not current.

```bash
npm test           # unit tests (outbox, job_lock, rate-limit, idempotency, masking, env)
npm run lint       # module-boundary rules
npm run format:check
```

Worker role (same binary, `AD-BE-07` / `KH_ROLE`). The worker **listens** so `/health` and `/ready` stay reachable. Local `KH_ROLE=all` runs HTTP plus the outbox drain loop in one process:

```bash
npm run start:worker
```

```powershell
$env:KH_ROLE = "worker"
node dist/main.js
```

`APP_ROLE` is a one-release alias for `KH_ROLE`.

Create the database once (any client): `CREATE DATABASE karat_hive;` then `CREATE EXTENSION IF NOT EXISTS pgcrypto; CREATE EXTENSION IF NOT EXISTS pg_trgm;` — or let the init migration create the extensions.

`docker/` remains as an optional later path. It is not required to run this tree.
