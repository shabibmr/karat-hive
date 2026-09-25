# Karat Hive — Stability & Breaking-Code Fix Plan

Repository: `shabibmr/karat-hive`

## Objective

Stabilize the current Karat Hive codebase by fixing known breaking/runtime risks, clarifying authentication and environment contracts, hardening database/outbox/scheduler behavior, and adding regression and end-to-end coverage.

## Execution Order

1. Baseline and reproduce failures
2. Authentication/session contract
3. Environment and deployment configuration
4. Flutter startup resilience
5. Database migration readiness
6. Outbox reliability
7. Scheduler reliability
8. Rate limiting correctness
9. Flutter API client hardening
10. Flavor/configuration cleanup
11. Admin/workspace CI coverage
12. API/E2E contract tests
13. CI/CD enforcement
14. Full regression matrix
15. Final end-to-end smoke test

---

## Phase 1 — Baseline

### KH-FIX-001 — Repository baseline
- Install dependencies.
- Generate Prisma client.
- Run migrations against a clean database.
- Run backend lint, type-check, unit/integration tests and build.
- Run Flutter analyze, tests and build.
- Record every failure with category and reproduction steps.

**Acceptance:** A baseline report exists and all current failures are classified.

### KH-FIX-002 — Stabilization branch
Create `fix/stability` and use it for the stabilization work.

### KH-FIX-003 — Failure classification
Classify failures as:
- BUILD
- RUNTIME
- CONFIGURATION
- AUTH
- DATABASE
- API CONTRACT
- DATA LOSS
- PERFORMANCE
- TEST/CI

---

## Phase 2 — Authentication

### KH-AUTH-001 — Define token types
Explicitly separate:
- Firebase ID token
- Karat Hive access token
- Karat Hive refresh token

### KH-AUTH-002 — Define authentication boundaries
Use Firebase authentication for session exchange only. Domain APIs must receive the Karat Hive access token.

### KH-AUTH-003 — Refactor Flutter token provider
Replace ambiguous token selection with an explicit `AuthTokenProvider` contract. Keep Firebase token retrieval separate from Karat Hive session tokens.

### KH-AUTH-004 — Audit authentication flows
Test:
- OTP/login
- Firebase exchange
- customer registration
- vendor registration
- session restore
- logout

### KH-AUTH-005 — Access-token refresh
Verify expired access tokens refresh correctly and the original request is retried exactly once.

### KH-AUTH-006 — Concurrent refresh
Ensure simultaneous 401 responses trigger one refresh operation and all waiting requests receive the refreshed token.

---

## Phase 3 — Environment & Deployment Configuration

### KH-CONFIG-001 — Define environment contract
Define complete dev/staging/prod configuration for:
- API URL
- Firebase
- database
- storage
- logging
- feature flags
- external services

### KH-CONFIG-002 — Remove unsafe API default
Remove `http://10.0.2.2:3000` as an implicit production/default API URL. Require an explicit API URL.

### KH-CONFIG-003 — Validate environment configurations
Create and validate dev, staging and production configuration templates. Secrets must never be committed.

### KH-CONFIG-004 — Resolve production storage strategy
Choose and consistently implement either OCI S3 or Supabase storage for production. Remove contradictory validation/fallback behavior.

### KH-CONFIG-005 — Backend fail-fast validation
Backend startup must fail immediately with a clear configuration error when required production settings are missing or inconsistent.

---

## Phase 4 — Flutter Startup

### KH-START-001 — Remove network dependency before first frame
Do not block `runApp()` on Firebase/Firestore/remote configuration network operations.

### KH-START-002 — Add configuration state
Implement loading/ready/error states for runtime configuration.

### KH-START-003 — Remote-config fallback
Use build-time configuration as a safe fallback. Never silently fall back to localhost for staging/production.

### KH-START-004 — Offline startup tests
Verify the app shell remains usable when Firebase, Firestore or the API is unavailable.

---

## Phase 5 — Database & Prisma

### KH-DB-001 — Replace migration readiness check
Do not determine database readiness merely from the number of completed migrations. Use Prisma migration state to verify the expected schema is current.

### KH-DB-002 — Migration policy
Define:
- development: migrate dev
- CI/test: clean database + migrations
- production: migrate deploy

### KH-DB-003 — Fresh database CI
Run all migrations against a fresh PostgreSQL instance in CI.

### KH-DB-004 — Clean migration test
Verify a completely empty database reaches the expected schema.

### KH-DB-005 — Upgrade migration test
Verify an existing previous-version database upgrades correctly.

---

## Phase 6 — Outbox Reliability

### KH-OUTBOX-001 — Unknown event handling
Unknown event types must never be silently marked DONE. Route them to retry/dead-letter/failure handling.

### KH-OUTBOX-002 — Document delivery semantics
Document that outbox delivery is at-least-once and every consumer must be idempotent.

### KH-OUTBOX-003 — Audit consumers
Review every outbox consumer for idempotency and safe retry behavior.

### KH-OUTBOX-004 — Crash-window test
Test a crash after the consumer performs its side effect but before the event is marked consumed.

### KH-OUTBOX-005 — Dead-letter handling
Implement or formalize dead-letter handling for permanently unprocessable events.

### KH-OUTBOX-006 — Retry/backoff tests
Verify retry count, exponential/backoff timing and terminal failure behavior.

---

## Phase 7 — Scheduler

### KH-SCHED-001 — Protect lock acquisition
Handle database errors from `tryAcquire()` so one DB failure does not unexpectedly terminate scheduler execution.

### KH-SCHED-002 — Database outage/recovery
Test scheduler behavior during DB outage and recovery.

### KH-SCHED-003 — Duplicate worker execution
Verify multiple scheduler workers cannot execute the same job concurrently.

### KH-SCHED-004 — Expired lease recovery
Verify abandoned/expired scheduler leases are recoverable.

---

## Phase 8 — Rate Limiting

### KH-RATE-001 — Define rate-limit algorithm
Document the intended token-bucket/fixed-window behavior and its semantics.

### KH-RATE-002 — Correct resetAt
Return a reset timestamp that actually represents the next meaningful refill/reset according to the selected algorithm.

### KH-RATE-003 — Concurrency test
Send 100 concurrent requests and verify the configured capacity is enforced correctly.

### KH-RATE-004 — Subject isolation
Verify separate users/IPs have independent rate-limit buckets where policy requires it.

---

## Phase 9 — Flutter API Client

### KH-API-001 — Separate transport and authentication
Make token acquisition an explicit dependency instead of mixing Firebase and application-session token semantics.

### KH-API-002 — Centralize 401 refresh
Remove duplicated refresh logic between response/error interceptor paths.

### KH-API-003 — Prevent refresh loops
Ensure refresh failure cannot recursively trigger another refresh cycle.

### KH-API-004 — Status mapping tests
Test 2xx, 400, 401, 403, 404, 409, 422, 429, 423, 500 and 503 responses.

---

## Phase 10 — Flutter Flavors

### KH-FLAVOR-001 — Choose one flavor strategy
Decide whether environment separation is driven by Dart defines, native Flutter flavors, or both.

### KH-FLAVOR-002 — Production configuration validation
Production builds must not compile with missing/unsafe API configuration.

### KH-FLAVOR-003 — Flavor smoke tests
Build and launch dev, staging and production configurations.

---

## Phase 11 — Admin & Workspace Coverage

### KH-WORKSPACE-001 — Audit workspace ownership
Verify every Flutter app/package is correctly represented in the workspace and dependency graph.

### KH-WORKSPACE-002 — Admin CI
Add the admin application to CI analysis, tests and build validation.

### KH-WORKSPACE-003 — Shared-package compatibility
Verify changes to shared packages cannot silently break customer/vendor/admin applications.

---

## Phase 12 — API & End-to-End Contract Tests

### KH-E2E-001 — Customer authentication
Test customer registration/login/session restoration/logout.

### KH-E2E-002 — Vendor authentication
Test vendor authentication and session lifecycle.

### KH-E2E-003 — Request lifecycle
Create, edit, publish and cancel a request.

### KH-E2E-004 — Offer lifecycle
Vendor discovers request, submits offer, modifies/cancels where supported.

### KH-E2E-005 — Connection lifecycle
Customer/vendor connection flow works end-to-end.

### KH-E2E-006 — Media lifecycle
Upload, associate, retrieve and delete media as permitted.

### KH-E2E-007 — Notifications
Verify notification creation, delivery and read-state behavior.

### KH-E2E-008 — API contract matrix
Create a matrix covering every major Flutter API client method and its corresponding backend endpoint, authentication requirement, request shape, response envelope and error behavior.

---

## Phase 13 — CI/CD

### KH-CI-001 — Backend pipeline
CI must run:
- install
- lint
- type-check
- Prisma generation
- migration validation
- unit tests
- integration tests
- production build

### KH-CI-002 — Flutter pipeline
CI must run:
- pub get
- analyze
- tests
- application builds

### KH-CI-003 — Admin pipeline
Include admin application validation.

### KH-CI-004 — Integration environment
Provide PostgreSQL and required service dependencies for integration tests.

### KH-CI-005 — Quality gates
Fail CI on relevant analyzer/type/test/build errors.

---

## Phase 14 — Regression Matrix

### Authentication
- KH-REG-001 Firebase token rejected by domain API
- KH-REG-002 Karat Hive access token accepted
- KH-REG-003 Refresh succeeds
- KH-REG-004 Concurrent refresh executes once
- KH-REG-005 Failed refresh clears session

### Configuration
- KH-REG-006 Missing API URL fails safely
- KH-REG-007 Valid production storage configuration works
- KH-REG-008 Invalid production storage configuration fails
- KH-REG-009 Dev configuration works
- KH-REG-010 Staging configuration works
- KH-REG-011 Production configuration works

### Startup
- KH-REG-012 Firebase unavailable
- KH-REG-013 Firestore unavailable
- KH-REG-014 API unavailable
- KH-REG-015 Application shell remains usable

### Outbox
- KH-REG-016 Unknown event is not marked DONE
- KH-REG-017 Consumer retry works
- KH-REG-018 Consumer idempotency works
- KH-REG-019 Dead-letter behavior works
- KH-REG-020 Expired claim recovery works

### Scheduler
- KH-REG-021 DB failure during lock acquisition
- KH-REG-022 Duplicate workers
- KH-REG-023 Expired lease recovery

### Rate limiting
- KH-REG-024 Capacity enforcement
- KH-REG-025 Token refill
- KH-REG-026 Concurrent requests
- KH-REG-027 Correct reset timestamp
- KH-REG-028 Subject isolation

---

## Phase 15 — Final End-to-End Smoke Test

Run the complete business flow:

1. Customer registers/logs in.
2. Customer creates and publishes a request.
3. Vendor sees the request.
4. Vendor submits an offer.
5. Customer sees and accepts the offer.
6. Connection is established.
7. Contact/connection event is generated.
8. Notification is delivered.
9. Review is created.
10. Request/transaction is closed.

**Acceptance:** The complete flow works against a clean, migrated database with production-like authentication and configuration.

---

## Definition of Done

The stabilization effort is complete only when:

- No known P0/P1 breaking issue remains.
- Authentication token responsibilities are unambiguous.
- Dev/staging/prod configuration is explicit and validated.
- Flutter can start without requiring network availability.
- Prisma migration state is verified correctly.
- Unknown outbox events cannot be silently lost.
- Scheduler failures are contained and recoverable.
- Rate-limit headers accurately describe behavior.
- Flutter API refresh logic is single-flight and loop-safe.
- All applications/packages are covered by CI.
- Critical API flows have automated integration/E2E tests.
- The regression matrix passes.
- The final customer-to-vendor smoke test passes.
