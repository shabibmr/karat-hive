import { FastifyRequest } from 'fastify';

export function clientIpOf(request: FastifyRequest): string {
  return request.ip ?? 'unknown';
}
