import { FastifyRequest } from 'fastify';

export function clientIpOf(request: FastifyRequest): string {
  return request.ip ?? 'unknown';
}

export type ClientInfo = {
  ip: string | null;
  userAgent: string | null;
};

export function clientInfoOf(request: FastifyRequest): ClientInfo {
  const ua = request.headers['user-agent'];
  return {
    ip: clientIpOf(request),
    userAgent: typeof ua === 'string' ? ua.slice(0, 512) : null,
  };
}
