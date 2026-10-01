# Architecture Review Prompt — Karat Hive

> **Workflow**: This prompt implements the architecture review workflow for the Karat Hive workspace.
> **Last Optimized**: 2026-09-29
> **Scope**: System-level architecture, data flow, scaling, technology fitness, and evolution strategy.
> **Out of Scope**: File-level code quality (→ Code Review), dead code and unused deps (→ Spring Cleaning), README accuracy (→ README Generation).

You are a **Lead System Architect** and **Vibe Coding Auditor**. Perform a full-spectrum architectural audit of the **Karat Hive** workspace (0.1.0 backend / 1.0.0+1 apps). This review evaluates systemic health — how well the parts of the system work together, whether the technology choices are still the right ones, and where the architecture must evolve.

---

## 1. Project Context

**Project**: Karat Hive (0.1.0 backend / 1.0.0+1 apps) — Request-driven gold marketplace for the UAE with three deployables sharing one Postgres database: a Node.js monolith (`backend/`), a dual-mode Customer/Vendor Flutter app (`apps/kh_mobile/karat_hive/`), and a Flutter Web Admin Portal (`apps/kh_admin/`).

**Architecture**: Monorepo with Node.js Monolith + Flutter Multi-Surface Apps
*   **Backend**: Node.js 20+ monolith with NestJS 11, Fastify 5, Prisma 5.22 ORM, PostgreSQL.
*   **Frontend**: Flutter (Dart >=3.9) mobile application (`apps/kh_mobile/karat_hive/`) and Flutter Web Admin Portal (`apps/kh_admin/`).
*   **Shared Packages**: `packages/kh_core`, `packages/kh_domain`, `packages/kh_api`, `packages/kh_design_system`, `packages/kh_ui_domain`, `packages/kh_l10n`, `packages/kh_media`.
*   **Async & Workers**: PostgreSQL Transactional Outbox pattern (`backend/src/platform/outbox/`) + scheduler (`backend/src/platform/scheduler/`). Strict constraint: No Redis, no external message broker (`C-11`/`C-12`).
*   **Storage**: Oracle Cloud Infrastructure (OCI) Object Storage S3 Compatibility API in `ap-hyderabad-1` (`adr/0013`).

**External Service Dependencies**:
- PostgreSQL Database (Supabase non-prod / self-hosted prod)
- Oracle Object Storage (OCI S3 API)
- Google Sign-In / Firebase Auth
- WhatsApp (`wa.me` deep linking for off-platform settlement)

**Reference Files**:
- `CLAUDE.md` — Architectural invariants, rules, and constraints
- `docs/Requirements-Spec-v1.5.md` — Authoritative SRS
- `docs/adr/` — Architecture Decision Records (`0001`–`0014`)
- `docs/architecture/Architecture-Backend.md` & `docs/architecture/Architecture-Frontend.md`
- `docs/Physical-Data-Model.md` & `backend/prisma/schema.prisma`

---

## 2. Historical Report Awareness

Before starting your analysis, check if `docs/reports/architecture-review/` exists and contains previous reports. For each issue found in prior reports:
- **Resolved**: The issue was addressed. Do NOT re-flag it.
- **Deferred to backlog**: Acknowledged and intentionally deferred.
- **Accepted risk**: The team evaluated and chose to accept it.
- **Superseded**: A design change made the concern irrelevant.

Only flag issues that are **genuinely new** or represent **regressions** of previously resolved items.

---

## 3. Phase 1: Live Data Gathering

### 3.1 Database & Schema Architecture
Read model and migration files directly:
- `backend/prisma/schema.prisma`
- `backend/prisma/migrations/`
- Review relationship cardinalities, cascade behaviors, and index definitions on high-frequency tables (`Request`, `Offer`, `Connection`, `OutboxEvent`).

### 3.2 Outbox & Async Event Architecture
Review outbox configuration and worker intervals:
- Outbox claimer (`backend/src/platform/outbox/outbox.claimer.ts`)
- Outbox dispatcher (`backend/src/platform/outbox/outbox.dispatcher.ts`)
- Scheduler intervals (`backend/src/main.ts`)

### 3.3 Commit Velocity & Churn Analysis
- Run `git log -n 20 --oneline` to understand recent active changes.

---

## 4. Architectural Review Dimensions

### 4.1 System Topology & Module Boundaries
- **Monolith Layering**: Verify module boundaries enforced by `eslint-plugin-boundaries`. Ensure modules interact strictly via their public interfaces (`index.ts`).
- **Package Decoupling**: Verify that `kh_mobile` and `kh_admin` never import each other directly and communicate only via shared packages (`packages/kh_*`).

### 4.2 Data Architecture & Multi-Tenancy
- **Domain Invariant Enforcement**: Verify server-side masking (`edge/masking`) guarantees zero identity leakage before offer acceptance (`BR-006`).
- **Transactional Integrity**: Confirm atomic acceptance (`BR-011`–`BR-013`) executes in a single transaction (Offer accept + other Offers reject + Connection create + Outbox event).
- **Outbox Scaling**: Evaluate outbox polling frequency vs event generation rate.

### 4.3 Identity & Auth Architecture
- **Google Auth Integration**: Verification flow using `jose` JWT validation in backend.
- **Session & Token Strategy**: Token expiration and refresh handling across mobile and web.

### 4.4 Mobile & Web Multi-Surface Architecture
- **Code Sharing vs Isolation**: Evaluate shared UI vs platform-specific adaptations between `kh_mobile` and `kh_admin`.
- **Media Pipeline**: Client-side image prep, direct upload to OCI S3 via signed URLs, and async server-side thumbnail processing.

### 4.5 Deployment & Operational Architecture
- **Environment Parity**: Consistency across local, staging, and production environments.
- **Deploy Scripts**: Health checks and zero-downtime execution in `scripts/deploy-all.sh`.

---

## 5. Output Format

### ⚡ Architecture Vibe Rating
Score the architecture (1–10) across key dimensions:
- System topology & modularity: /10
- Data architecture & invariants: /10
- Async & outbox maturity: /10
- Multi-surface Flutter architecture: /10
- Deployment & operational readiness: /10
- **Overall Architecture Score**: /10

### 🔴 The "Critical 3"
The three biggest systemic risks:
| # | Risk | Evidence | Consequence | Mitigation |
|:-:|:-----|:---------|:------------|:-----------|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |

### 🏗️ Architectural Recommendations
- Structure & Module Boundaries
- Data Architecture & Outbox Optimizations
- Operational & Deployment Patterns

### 🗓️ 12-Month Technical Evolution Roadmap
| Quarter | Theme | Key Actions | Success Criteria |
|:--------|:------|:------------|:----------------|
| Q3 2026 | Foundation & Hardening | | |
| Q4 2026 | Scale & Performance | | |
| Q1 2027 | Multi-Region & Advanced Matching | | |
| Q2 2027 | Enterprise Integrations | | |

---

## 6. Execution Rules
1. **Evidence over opinion**: Every claim must cite a file path, ADR, or configuration value.
2. **Systemic over localized**: Cross-cutting architecture concerns only (file-level issues belong in Code Review).