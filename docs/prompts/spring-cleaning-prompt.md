# Spring Cleaning Prompt — Karat Hive

> **Workflow**: Optimized for Vibe Coding practices
> **Last Optimized**: 2026-09-29

You are a **Vibe Coding** expert and **Code Quality Engineer**. Perform a comprehensive "Spring Cleaning" of the Karat Hive workspace (0.1.0 backend / 1.0.0+1 apps) to eliminate technical debt and ensure AI-readiness.

---

## Project Context

**Architecture**:
Monorepo containing:
- `backend/`: Node.js monolith with NestJS 11, Fastify 5, Prisma 5.22, PostgreSQL.
- `apps/kh_mobile/karat_hive/`: Flutter mobile application (Customer & Vendor dual-mode).
- `apps/kh_admin/`: Flutter Web Admin Portal.
- `packages/`: Shared packages (`kh_core`, `kh_domain`, `kh_api`, `kh_design_system`, `kh_ui_domain`, `kh_l10n`, `kh_media`).
- `docs/`: Technical specifications, ADRs (`0001`–`0014`), and architectural documentation.

**Entry Points**:
- Backend: `backend/src/main.ts`
- Mobile: `apps/kh_mobile/karat_hive/lib/main.dart`
- Admin: `apps/kh_admin/lib/main.dart`

**Key Directories**:
- Backend: `backend/src/modules/`, `backend/src/platform/`, `backend/src/edge/`, `backend/prisma/`
- Mobile: `apps/kh_mobile/karat_hive/lib/features/`, `apps/kh_mobile/karat_hive/lib/core/`
- Admin: `apps/kh_admin/lib/features/`, `apps/kh_admin/lib/core/`
- Shared: `packages/kh_core/lib/`, `packages/kh_domain/lib/`, `packages/kh_api/lib/`, `packages/kh_design_system/lib/`, `packages/kh_media/lib/`

---

## Historical Report Awareness

Before starting your analysis, read **all previous spring cleaning reports** in `docs/reports/spring-cleaning/`. For each issue found in prior reports, check its current status:

- **Resolved (strikethrough `~~...~~`)**: The issue was fixed. Do NOT re-flag it.
- **Deferred to backlog**: The issue was acknowledged and intentionally deferred. Reference the backlog item but do NOT re-flag it as a new finding.
- **False positive / Not an issue**: The finding was investigated and determined to be incorrect or normal behavior. Do NOT re-flag it.
- **Disregarded**: The team reviewed and chose not to act. Do NOT re-flag it.

Only flag issues that are **genuinely new** or represent **regressions** of previously fixed items.

### Known Patterns Awareness

Before flagging suspicious structural patterns as dead code or technical debt, consult `docs/prompts/known-patterns.md`. This file documents intentional design decisions (e.g., self-reported mobile bypass during development phase, test assets, unawaited fire-and-forget telemetry, scripts in `scripts/`). If a finding matches a documented known pattern, **do not flag it**.

---

## Analysis Tasks

### 1. 🗂️ Orphaned Files

Scan the workspace for source files that:
- Are not imported by any other file
- Are not listed as entry points in manifests
- Are not configuration files or standalone scripts in `scripts/`
- Are not active procedural skills in `.agent/skills/`

**Manual verification**:
- Check if file is conditionally or dynamically loaded.
- Run `git log -1 --format="%cd" -- <file>` to inspect when the file was last modified.

### 2. 📦 Unused & Phantom Dependencies

Examine all manifest files:
- `backend/package.json`
- `pubspec.yaml` (workspace root)
- `apps/kh_mobile/karat_hive/pubspec.yaml`
- `apps/kh_admin/pubspec.yaml`
- `packages/*/pubspec.yaml`

Identify:
- **Unused dependencies**: Packages declared in manifests but never imported in source code.
- **Phantom dependencies**: Packages imported in source code but missing from the corresponding manifest.

### 3. ✂️ Dead Code Blocks

Scan for:
- Unused internal functions, classes, or private variables
- Large blocks of commented-out code
- Unreachable branches and obsolete conditional blocks

### 4. 📏 Vibe Coding Compliance Check

- Files by line count zone (500-line hard limit):
  - 500+ lines → 💀 **God Component** — must decompose before next feature
  - 475–499 lines → 🔴 **RED** — provide decomposition plan now
  - 450–474 lines → 🟡 **Monitor** — note it, do not add features
  - < 450 lines → ✅ **Safe**
- `any` / untyped `dynamic` usage in non-script code
- Missing documentation on complex exported methods

### 5. 📊 Logging Compliance

Verify structured logging standards:
- Backend: Verify all services and edge layers use NestJS `Logger` (no raw `console.log` in backend code).
- Flutter: Verify usage of `AppLogger` and `PerfLog` from `kh_core`.
- Exceptions: Standalone CLI tools in `scripts/` and seed scripts in `backend/prisma/seed/`.

### 6. 🗄️ Database & Schema Hygiene

- Verify `backend/prisma/schema.prisma` against Prisma migrations in `backend/prisma/migrations/`.
- Check for unused models, redundant relation fields, or unindexed foreign keys.

### 7. 🧹 Deep Clean Analysis

#### Debug Noise
- `debugger` statements
- Stray `console.log` in backend services or Flutter widgets
- Temporary log dumps or commented test code

#### Obsolete Artifacts
- Files or folders matching `temp`, `tmp`, `bak`, `old`, `archive`, `*.bak`, `*.old`

#### Git & Secret Hygiene
- Sensitive files checked into git (API keys, credentials, service account JSONs)
- Verify `.gitignore` covers `.env`, build outputs (`dist/`, `build/`, `.dart_tool/`), and OS files

---

## Output Format

### 🔴 High Confidence — Delete
| Category | Path | Reason |
|:---------|:-----|:-------|
| Orphaned File | `path/to/file` | Never imported |
| Unused Dep | `package-name` | Not imported |

### 🟡 Low Confidence — Verify
| Category | Path | Notes |
|:---------|:-----|:------|
| Dynamic Usage? | `path/to/file` | Check for runtime loading |

### ✂️ Internal Dead Code
| File | Line(s) | Item | Action |
|:-----|:--------|:-----|:-------|
| `path` | 100-120 | `unusedFunction()` | Delete |

### 📏 Vibe Coding Violations
| File | Lines | Issue |
|:-----|:------|:------|
| `path` | 550 | Exceeds 500 lines |

### 🧹 Deep Clean Findings
| File | Line(s) | Type | Code Snippet / Details |
|:-----|:--------|:-----|:-----------------------|
| `path` | 42 | debugger | `debugger;` |

### 📦 Dependency & Manifest Review
| Package | Manifest | Status | Recommendation |
|:--------|:---------|:-------|:---------------|
| `name` | `backend/package.json` | Unused / Outdated | Remove / Update |

---

## Execution Rules

1. **Report first, then confirm** — Do not delete files without user approval.
2. **Archive over delete** — Move questionable files to a holding area if uncertain.
3. **Verify with type-check** — Ensure `npm run lint` and `dart analyze` pass after any cleanup.

---

## Recommended Actions with AI Model Selection

| Priority | Action | Effort | Files Affected | Recommended Model | Mode |
|:---------|:-------|:------:|:---------------|:------------------|:----:|
| 🔴 High | *cleanup action* | Low/Med/High | *file list* | *model name* | Fast/Planning |
| 🟡 Medium | *cleanup action* | Low/Med/High | *file list* | *model name* | Fast/Planning |
| 🟢 Low | *cleanup action* | Low/Med/High | *file list* | *model name* | Fast/Planning |