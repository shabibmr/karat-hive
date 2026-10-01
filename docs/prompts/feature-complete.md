# Feature Complete Workflow — Karat Hive

> **Workflow**: This workflow is executed when a feature implementation is completed in the Karat Hive workspace.
> **Last Optimized**: 2026-09-29

You are an expert AI development assistant in Antigravity 2. Follow these structured steps to verify and finalize the completed feature.

---

## 1. Identify the Completed Feature
- Review recent conversation history, task lists, and `git status` / `git log` to summarize what was built, modified, and tested.

## 2. Update Project Management Artifacts
- Check off completed items in relevant tracking files:
  - `task.md` or `implementation_plan.md` in app/package subdirectories (if present).
  - `backend/TASKS.md` or `backend/tasks.csv` (for backend deliverables).
  - `docs/checkpoints/` checkpoint task registers.

## 3. Update Project Documentation & Specifications
- Update roadmap or checkpoint status files in `docs/` reflecting the new capabilities.
- Ensure `docs/Screen-API-Map.md` or `docs/API-Route-Inventory.md` are updated if new endpoints or screens were added.

## 4. Update Project Rules & Modular Skills
- If the feature introduced new architectural patterns, conventions, or common pitfalls, update `CLAUDE.md`.
- If new runbook skills were created or updated, verify their `SKILL.md` in `.agent/skills/`.

## 5. Update Database Schema & Models (Conditional)
- If database models were modified:
  - Confirm `backend/prisma/schema.prisma` is up to date.
  - Run `npm run prisma:validate` in `backend/`.
  - Update `docs/Physical-Data-Model.md` if schema tables/relations changed.

## 6. Update Documentation & Guides
- Create or update relevant user/developer guides under `docs/` (e.g., API documentation, performance testing guides).

## 7. Update CHANGELOG & Versioning
- Review `git diff` against base branch.
- Add an entry under the Unreleased section in `CHANGELOG.md` following Keep a Changelog conventions.

## 8. Final Verification Commands
Execute the project-specific verification commands:
```bash
# 1. Backend Verification
cd backend
npm run lint
npm run test

# 2. Workspace Linting & Diagnostics
cd ..
dart analyze
```

## 9. Commit, Tag & Push (USER ACTION)

> [!IMPORTANT]
> Git commit, tag, and push actions must be performed by the **USER** (or with explicit user permission).

Provide the user with the suggested Git commands:
```bash
git add .
git commit -m "feat(<scope>): <description of completed feature>"
git push origin <branch-name>
```
