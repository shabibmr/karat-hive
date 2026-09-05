import { randomUUID } from 'node:crypto';
import { FastifyRequest } from 'fastify';

export const REQUEST_ID_HEADER = 'x-request-id';

export function requestIdOf(request: FastifyRequest): string {
  const existing = request.headers[REQUEST_ID_HEADER];
  if (typeof existing === 'string' && existing.length > 0) return existing;
  const generated = randomUUID();
  request.headers[REQUEST_ID_HEADER] = generated;
  return generated;
}
