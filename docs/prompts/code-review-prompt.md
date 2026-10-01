# AI Code Review Prompt: Karat Hive Workspace

> **Workflow**: This prompt implements the code review workflow for the Karat Hive workspace.
> **Last Optimized**: 2026-09-29

You are an expert Vibe Coding Architect, Security Analyst, and PostgreSQL Database Engineer. Perform a comprehensive code review of the **entire Karat Hive workspace** (Monorepo with Node.js Monolith + Flutter Multi-Surface Apps). This prompt is optimized for **Vibe Coding** practices—ensuring the codebase is AI-ready, maintainable, and free of technical debt.

---

## 1. Project Context

**Project**: Karat Hive (0.1.0 backend / 1.0.0+1 mobile & admin) — Request-driven gold marketplace for the UAE with three deployables sharing one Postgres database: a Node.js monolith (`backend/`), a dual-mode Customer/Vendor Flutter app (`apps/kh_mobile/karat_hive/`), and a Flutter Web Admin Portal (`apps/kh_admin/`).

**Architecture**:
*   **Monorepo**: Multi-surface architecture with NestJS 11 backend monolith, Flutter mobile/web apps, and shared Dart packages (`kh_core`, `kh_domain`, `kh_api`, `kh_design_system`, `kh_ui_domain`, `kh_l10n`, `kh_media`).
*   **Database**: PostgreSQL (Prisma 5.22.0 ORM, migrations in `backend/prisma/migrations/`, schema in `backend/prisma/schema.prisma`).
*   **Logging**: NestJS built-in `Logger` and custom `PerfTimer` in backend; Fastify `onResponse` HTTP logging; `kh_core` `AppLogger` and `PerfLog` in Flutter client with `PerfLogSink` to Firestore.
*   **Async & Workers**: PostgreSQL Transactional Outbox pattern (`backend/src/platform/outbox/`) + internal cron scheduler (`backend/src/platform/scheduler/`). Strict constraint: No Redis, no external message broker (`C-11`/`C-12`).
*   **Storage**: Oracle Object Storage (S3 Compatibility API in `ap-hyderabad-1`, `adr/0013`). MinIO/Supabase Storage fallback.
*   **Auth / Identity**: Google Sign-In with Firebase Auth (`adr/0010`); JWT verification via `jose` 6.x in backend.
*   **Deployment**: Custom deployment shell scripts (`scripts/deploy-all.sh`, `scripts/deploy-prod.sh`, etc.), reverse proxy, environment-based configuration.
*   **Design System**: `kh_design_system` package ("1a Classic" design system).

**Reference Files**:
- `CLAUDE.md` - Project rules, constraints (`C-01`–`C-13`), business rules (`BR-001`–`BR-021`), and domain invariants
- Active skills: `generate-readme`, `generate-review-prompts`, `run-architecture-review`, `run-code-review`, `run-config-layer-audit`, `run-feature-complete`, `run-feature-plan`, `run-implementation-plan-review-1`, `run-implementation-plan-review-2`, `run-retention-cleanup`, `run-spring-cleaning`, `setup-reviews`
- `docs/Requirements-Spec-v1.5.md` - Authoritative SRS
- `docs/adr/` - Architecture Decision Records (`0001`–`0014`)
- `docs/Physical-Data-Model.md` & `backend/prisma/schema.prisma` - Database schema
- `docs/API-Route-Inventory.md` - API endpoints catalogue
- `docs/Screen-API-Map.md` - Screen-to-API mapping
- `docs/prompts/known-patterns.md` - Intentional code patterns (consult before flagging suspicious patterns)

---

## 2. Historical Report Awareness

Before starting your analysis, read **all previous code review reports** in `docs/reports/code-review/`. For each issue found in prior reports, check its current status:

- **Resolved (strikethrough `~~...~~`)**: The issue was fixed. Do NOT re-flag it.
- **Deferred to backlog**: The issue was acknowledged and intentionally deferred. Reference the backlog item but do NOT re-flag it as a new finding.
- **False positive / Not an issue**: The finding was investigated and determined to be incorrect or normal behavior. Do NOT re-flag it.
- **Disregarded**: The team reviewed and chose not to act. Do NOT re-flag it.

Only flag issues that are **genuinely new** or represent **regressions** of previously fixed items.

### Known Patterns Awareness

Before flagging suspicious code patterns as bugs, consult `docs/prompts/known-patterns.md`. This file documents intentional design decisions (e.g., OTP optionality during development phase, `as any` casts for Prisma limitations, unawaited fire-and-forget telemetry). If a finding matches a documented known pattern, **do not flag it** as a bug.

---

## 3. Vibe Coding Principles (PRIORITY)

### 🎯 10-Second Rule
If it takes more than 10 seconds to explain a file's purpose to an AI, the file is too complex.

| Check | Target | Status |
|:------|:-------|:-------|
| No file exceeds 500 lines (God Component — hard limit) | All Source Files | ✅/❌ |
| No file exceeds 475 lines (RED — imminent God Component) | All Source Files | ✅/❌ |
| Component has single responsibility | Flutter widgets / Riverpod controllers | ✅/❌ |
| Service has clear domain boundary | `backend/src/modules/` | ✅/❌ |

**File Size Zone Reference** (500-line hard limit):

| Lines | Zone | Action |
|------:|:-----|:-------|
| < 450 | ✅ Safe | No action needed |
| 450–474 | 🟡 Monitor | Note it; do not add features |
| 475–499 | 🔴 RED | Provide decomposition plan now |
| 500+ | 💀 God Component | Must decompose before next feature |

### 🧠 Karpathy-Inspired Coding Principles
| Check | Target | Status |
|:------|:-------|:-------|
| No speculative features beyond requirements | All changes | ✅/❌ |
| No abstractions for single-use code | All changes | ✅/❌ |
| No non-surgical changes (refactoring unrelated code) | All changes | ✅/❌ |
| Surgical Cleanup: unused imports/variables removed | All changed files | ✅/❌ |
| Assumptions explicitly stated if uncertain | Documentation / Comments | ✅/❌ |

### 🧹 Clean Code & Type Safety
| Check | Location | Status |
|:------|:---------|:-------|
| No unused imports | All files | ✅/❌ |
| No commented-out code blocks | All files | ✅/❌ |
| No orphaned files (never imported) | Source directories | ✅/❌ |
| No unused dependencies | Manifest files | ✅/❌ |
| Strict type annotations (no unnecessary `any` or `dynamic`) | TypeScript & Dart | ✅/❌ |
| Module separation: logic in services/controllers, routes in controllers/edge | Monolith & Flutter | ✅/❌ |

---

## 4. Review Priorities (Ordered)

| Priority | Focus Area | Description |
|:---------|:-----------|:------------|
| 🔴 **1** | **Vibe Coding Compliance** | 500-line limit, surgical changes, single responsibility |
| 🔴 **2** | **Correctness & Domain Invariants** | Identity masking until acceptance (`BR-006`/`BR-011`), 48h Request lifecycle, atomic offer acceptance |
| 🔴 **3** | **Security & Auth** | Google Auth verification, auth guards, tenant isolation, input validation (Zod schemas) |
| 🔴 **4** | **Error Handling** | try/catch coverage, NestJS exception filters, Flutter Riverpod AsyncValue error states |
| 🟡 **5** | **Performance & Database Integrity** | Outbox draining latency, Prisma N+1 queries, unindexed foreign keys, connection pooling |
| 🟡 **6** | **Logging & Observability** | Structured logging via NestJS Logger, `PerfTimer` & `PerfLog` hygiene, no stray `console.log` |
| 🟡 **7** | **Async & Outbox Processing** | Outbox claimer/dispatcher health, idempotency, retry mechanisms |
| 🟡 **8** | **Dead Code & Bloat** | Unused exports, orphaned files, redundant dependencies |
| 🟢 **9** | **Testing & Test Quality** | Vitest unit/integration specs, Flutter widget tests |
| 🟢 **10** | **API Design & OpenAPI Parity** | OpenAPI generation accuracy, REST conventions, consistent response formats |
| 🟢 **11** | **Maintainability & Boundary Enforcement** | `eslint-plugin-boundaries` rule compliance between backend modules |

---

## 5. Environment Constraints

- **Backend**: Node.js >=20, NestJS 11, Fastify 5, Prisma 5.22, TypeScript 5.9, Zod 3.25
- **Frontend / Mobile**: Dart >=3.9, Flutter, Flutter Riverpod 2.6, GoRouter 14.6, Dio 5.7
- **Database**: PostgreSQL 15+
- **Linting**: ESLint 9 (with `eslint-plugin-boundaries`), `dart analyze` (with `flutter_lints` 5.0 and `hardcoded_strings_lint`)
- **Apps**: `backend/`, `apps/kh_mobile/karat_hive/`, `apps/kh_admin/`

---

## 6. Required Output Sections

### 🎯 Vibe Coding Compliance Report
*   **God Components** (> 500 lines): List and mandate decomposition. **RED Zone** (475–499 lines): List and provide decomposition plan. **Monitor** (450–474 lines): List with line count.
*   **Dead Code**: Unused imports, commented blocks, orphaned files.
*   **Type Safety**: List `any` or loose `dynamic` usages.

### 🔐 Security & Domain Invariant Review
*   **Identity Masking Verification**: Ensure customer/vendor identity fields remain completely absent before offer acceptance (`BR-006`).
*   **Vendor Entitlements**: Verify vendors require Verification + Active status + Active Type Subscription (`BR-002`).
*   **Auth Guard Coverage**: Verify every protected route has `AuthGuard`.
*   **Input Validation**: Confirm all incoming HTTP requests validate against Zod schemas.

### 📊 Logging & Telemetry Review
*   **Backend Logging**: Verify usage of NestJS `Logger` (no raw `console.log` in backend services).
*   **Performance Instrumentation**: Verify `PerfTimer` and `PerfLog` are guarded by environment flags (`PERF_LOG` / `KH_PERF_LOG` / `kDebugMode`).
*   **Privacy / PII Check**: Confirm no PII (phone, email, names) is written to `perf_logs` or log streams.

### 🗄️ Database & Outbox Review
*   **Transaction Boundaries**: Verify multi-table state mutations (e.g. Accept Offer, Publish Request) run in Prisma transactions.
*   **Outbox Event Integrity**: Ensure outbox records are inserted within the same transaction as state changes.
*   **Index Coverage**: Check for proper indexes on frequently queried fields (`requestId`, `vendorId`, `customerId`, `status`).

### 📱 Flutter & Mobile Architecture Review
*   **Multi-Platform Safety**: Ensure web-specific code (`dart:html`, `package:web`) is isolated from native builds.
*   **State Management**: Riverpod providers lifecycle hygiene and error handling.
*   **Asset / Network Resilience**: Proper image loading error fallbacks and timeout configurations.

### 🔍 Deep Clean Analysis
*   **Debug Noise**: `console.log`, debugger statements, commented code blocks.
*   **Obsolete Artifacts**: Temporary files or backup files.
*   **Orphaned Files**: Files unreferenced anywhere in the codebase.

### 🔍 Issues & Improvements
Group findings by severity:
- 🔴 **Critical**: Bugs, invariant violations, security gaps, data inconsistency risks
- 🟡 **Important**: Performance bottlenecks, missing error handling, God Components
- 🟢 **Minor**: Code style, minor typing improvements, documentation drift

### 🚀 Refactor Plan ("Vibe Check")
Identify the single messiest file and provide a step-by-step refactoring plan.

### ✅ Grading Section
Score (1-10) on:
- Security & Domain Invariants: /10
- Stability & Error Handling: /10
- Maintainability & Modularity: /10
- Performance & Database Efficiency: /10
- **Overall Vibe Score**: /10

---

## 7. Action Plan

Prioritized list of actionable steps to address findings:

| Priority | Action | Effort | Files Affected | Recommended Model | Mode |
|:---------|:-------|:------:|:---------------|:------------------|:----:|
| 🔴 High | *action description* | Low/Med/High | *file list* | *model name* | Fast/Planning |
| 🟡 Medium | *action description* | Low/Med/High | *file list* | *model name* | Fast/Planning |
| 🟢 Low | *action description* | Low/Med/High | *file list* | *model name* | Fast/Planning |