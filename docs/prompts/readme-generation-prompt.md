# Role
You are a Technical Writer and Open Source Maintainer. Generate a professional, high-quality `README.md` file for the **Karat Hive** project that is ready for GitHub.

# Context
The project is **Karat Hive** (`karat-hive`). Karat Hive is a request-driven gold marketplace for the UAE with three deployables sharing one PostgreSQL database:
1. `backend/`: Node.js monolith with NestJS 11, Fastify 5, and Prisma 5 ORM.
2. `apps/kh_mobile/karat_hive/`: Flutter multi-surface mobile application for Customers and Vendors.
3. `apps/kh_admin/`: Flutter Web Admin Portal.
4. `packages/`: Shared Dart packages (`kh_core`, `kh_domain`, `kh_api`, `kh_design_system`, `kh_ui_domain`, `kh_l10n`, `kh_media`).

---

## Required Sections & Content:

1. **Header:**
   * Project Title: **Karat Hive**
   * Catchy one-line description: Request-Driven Gold Marketplace for the UAE.
   * **Badges**: Flutter, NestJS, TypeScript, PostgreSQL, Prisma, License.

2. **About the Project:**
   * Overview of the marketplace: Reverse-auction / request-driven model where customers post gold requests (ornaments, coins, bullion, scrap gold) and verified vendors submit offers within a strictly enforced 48-hour lifecycle.
   * **Key Invariants**:
     - 🛡️ **Identity Masking**: Customer and Vendor identities remain completely hidden until an offer is accepted.
     - ⏱️ **48-Hour Lifecycle**: Requests automatically expire after 48 hours.
     - 🤝 **Direct WhatsApp Handoff**: Atomic deal acceptance creates a connection for off-platform settlement.
     - 📦 **Transactional Outbox**: Asynchronous events and notifications run on PostgreSQL outbox (no Redis/brokers).

3. **Tech Stack:**
   * **Backend**: Node.js 20+, NestJS 11, Fastify 5, Prisma 5.22, Zod 3.25, TypeScript 5.9.
   * **Mobile & Admin**: Flutter (Dart >=3.9), Flutter Riverpod 2.6, GoRouter 14.6, Dio 5.7, Freezed.
   * **Database**: PostgreSQL 15+ (Prisma ORM).
   * **Object Storage**: Oracle Cloud Infrastructure (OCI) Object Storage S3 Compatibility API (`ap-hyderabad-1`).
   * **Authentication**: Google Sign-In with Firebase Auth (`jose` JWT verification on backend).

4. **Getting Started:**
   * **Prerequisites**: Node.js 20+, Flutter SDK 3.24+, PostgreSQL 15+.
   * **Backend Setup**:
     ```bash
     cd backend
     npm install
     npm run prisma:generate
     npm run start:dev
     ```
   * **Mobile / Web Setup**:
     ```bash
     dart pub get
     cd apps/kh_mobile/karat_hive
     flutter run
     ```
   * **Admin Portal Setup**:
     ```bash
     cd apps/kh_admin
     flutter run -d chrome
     ```
   * **Environment Setup**: Document key environment variables for `.env` (e.g., `DATABASE_URL`, `JWT_SECRET`, `OCI_STORAGE_*`, `PERF_LOG`).

5. **Project Structure:**
   * Simplified tree view detailing `backend/`, `apps/kh_mobile/`, `apps/kh_admin/`, `packages/`, `docs/`, `scripts/`.

6. **Key Scripts & Workflows:**
   * `scripts/deploy-all.sh`: Builds and deploys backend, mobile web, and admin web.
   * `scripts/check-perf-logs.js`: Reads and analyzes performance telemetry from Firestore.
   * `backend/scripts/generate-openapi.ts`: Generates OpenAPI specification from Zod schemas.

7. **Project Status & Roadmap:**
   * Summary of completed milestones (Vendor Onboarding, Customer Mode, Request Flow Performance Instrumentation).
   * Reference to `docs/Requirements-Spec-v1.5.md` and `docs/adr/`.

8. **Developer Runbooks & Skills:**
   * Document available `.agent/skills/` (`run-code-review`, `run-architecture-review`, `run-spring-cleaning`, `generate-readme`, `run-feature-plan`, etc.).

---

## Style Guidelines:
* Use standard GitHub Flavored Markdown.
* Professional, clear, and well-structured with tables and emojis for visual clarity.