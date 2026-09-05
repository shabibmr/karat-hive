import type { FastifyRequest } from 'fastify';
import { clientIpOf } from '../../../edge/client-ip';

export type ClientInfo = {
  ip: string | null;
  userAgent: string | null;
  acceptLanguage?: string;
};

export function clientInfoOf(request: FastifyRequest): ClientInfo {
  const ua = request.headers['user-agent'];
  const lang = request.headers['accept-language'];
  return {
    ip: clientIpOf(request),
    userAgent: typeof ua === 'string' ? ua.slice(0, 512) : null,
    acceptLanguage: typeof lang === 'string' ? lang : undefined,
  };
}
