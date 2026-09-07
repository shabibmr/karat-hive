# Generated OpenAPI (`NFR-030` / `AD-BE-14`)

`openapi.json` is produced from Nest controller metadata and the same Zod schemas used by `ZodValidationPipe`. Do not hand-edit the JSON.

## Regenerate

```bash
cd backend
npm run openapi:generate
```

CI runs `npm run openapi:check`, which regenerates and fails if `openapi/` drifts from git.

## Scope (G2-GR05 first cut)

| Covered                                     | Not yet                                      |
| ------------------------------------------- | -------------------------------------------- |
| All registered Nest HTTP paths/methods      | Response presenter DTOs as Zod               |
| Request body/query Zod from pipes           | Full inventory parity annotations            |
| Bearer security + public routes (`@Public`) | Breaking-change semver gate beyond file diff |

Generator: `scripts/generate-openapi.ts` + `scripts/openapi/*`. Add new controllers to `scripts/openapi/controllers.ts`.

Until response Zod exists, success payloads are documented as the shared `SuccessEnvelope` placeholder. The pre-code catalogue remains [`docs/API-Route-Inventory.md`](../../docs/API-Route-Inventory.md).
