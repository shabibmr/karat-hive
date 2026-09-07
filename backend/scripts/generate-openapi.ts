/**
 * G2-GR05 / T31 — generate OpenAPI from Nest route metadata + Zod pipes.
 *
 * Usage (from backend/):
 *   npm run openapi:generate
 *   npm run openapi:check   # regenerate + fail if openapi/ drifted
 */
import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { buildOpenApiDocument } from './openapi/build-document';
import { OPENAPI_CONTROLLERS } from './openapi/controllers';
import { discoverRoutes } from './openapi/discover';

const OUT_FILE = resolve(__dirname, '../openapi/openapi.json');

function main(): void {
  const routes = discoverRoutes(OPENAPI_CONTROLLERS);
  if (routes.length === 0) {
    throw new Error('OpenAPI generation found zero routes — check OPENAPI_CONTROLLERS.');
  }

  const document = buildOpenApiDocument(routes);
  const json = `${JSON.stringify(document, null, 2)}\n`;

  mkdirSync(dirname(OUT_FILE), { recursive: true });
  writeFileSync(OUT_FILE, json, 'utf8');

  const withBody = routes.filter((r) => r.bodySchema).length;
  const withQuery = routes.filter((r) => r.querySchema).length;
  console.log(
    `Wrote ${OUT_FILE} (${routes.length} paths; ${withBody} body schemas; ${withQuery} query schemas)`,
  );
}

main();
