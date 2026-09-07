import {
  OpenAPIRegistry,
  OpenApiGeneratorV3,
  extendZodWithOpenApi,
  type RouteConfig,
} from '@asteasolutions/zod-to-openapi';
import { z } from 'zod';
import type { DiscoveredRoute } from './discover';

extendZodWithOpenApi(z);

const successMetaSchema = z
  .object({
    requestId: z.string(),
    serverTime: z.string(),
    nextCursor: z.string().nullable(),
  })
  .openapi('SuccessMeta');

const successEnvelopeSchema = z
  .object({
    data: z.unknown(),
    meta: successMetaSchema,
  })
  .openapi('SuccessEnvelope');

const errorBodySchema = z
  .object({
    code: z.string(),
    message: z.string(),
    details: z.unknown().optional(),
    requestId: z.string().optional(),
  })
  .openapi('ErrorBody');

function pathParamsSchema(names: string[]) {
  if (names.length === 0) return undefined;
  const shape: Record<string, z.ZodString> = {};
  for (const name of names) {
    shape[name] = z.string().min(1);
  }
  return z.object(shape);
}

function toRouteConfig(route: DiscoveredRoute): RouteConfig {
  const request: NonNullable<RouteConfig['request']> = {};
  const params = pathParamsSchema(route.pathParams);
  if (params) request.params = params;
  if (route.querySchema) request.query = route.querySchema;
  if (route.bodySchema) {
    request.body = {
      content: {
        'application/json': { schema: route.bodySchema },
      },
    };
  }

  const responses: RouteConfig['responses'] = {
    [route.statusCode]: {
      description: 'Success (envelope per Architecture §13 / EnvelopeInterceptor)',
      content: {
        'application/json': { schema: successEnvelopeSchema },
      },
    },
    401: {
      description: 'Unauthenticated',
      content: { 'application/json': { schema: errorBodySchema } },
    },
    422: {
      description: 'Validation failed',
      content: { 'application/json': { schema: errorBodySchema } },
    },
  };

  return {
    method: route.method,
    path: route.path,
    operationId: route.operationId,
    tags: [route.tag],
    summary: `${route.method.toUpperCase()} ${route.path}`,
    description: `Handler ${route.controllerName}.${route.handlerName}. Request shapes come from ZodValidationPipe schemas (single source). Response DTOs are not yet Zod-exported — SuccessEnvelope is a placeholder.`,
    security: route.isPublic ? [] : [{ bearerAuth: [] }],
    request: Object.keys(request).length > 0 ? request : undefined,
    responses,
  };
}

/** Build OpenAPI 3.0 document from discovered Nest+Zod routes (AD-BE-14 / NFR-030). */
export function buildOpenApiDocument(routes: DiscoveredRoute[]): Record<string, unknown> {
  const registry = new OpenAPIRegistry();

  registry.registerComponent('securitySchemes', 'bearerAuth', {
    type: 'http',
    scheme: 'bearer',
    bearerFormat: 'JWT',
    description: 'Karat Hive access JWT (not a Firebase ID token).',
  });

  registry.register('SuccessMeta', successMetaSchema);
  registry.register('SuccessEnvelope', successEnvelopeSchema);
  registry.register('ErrorBody', errorBodySchema);

  for (const route of routes) {
    registry.registerPath(toRouteConfig(route));
  }

  const generator = new OpenApiGeneratorV3(registry.definitions);
  const document = generator.generateDocument({
    openapi: '3.0.3',
    info: {
      title: 'Karat Hive API',
      version: '0.1.0',
      description: [
        'Generated from Nest controllers + ZodValidationPipe schemas (`npm run openapi:generate`).',
        'Zod remains the single source of request shape (NFR-030, AD-BE-14).',
        'First artefact is partial: paths/methods and request Zod schemas are covered; response presenters are not yet dual-exported as Zod.',
        'Pre-code catalogue: docs/API-Route-Inventory.md — clients should treat this file as the evolving contract.',
      ].join(' '),
    },
    servers: [{ url: 'http://localhost:3000', description: 'Local API' }],
  });

  return document as unknown as Record<string, unknown>;
}
