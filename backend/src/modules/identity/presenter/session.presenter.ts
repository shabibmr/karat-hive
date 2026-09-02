import type { IssuedTokens } from '../application/token.service';
import type { Me } from './me.presenter';

export type SessionBundle = {
  accessToken: string;
  accessExpiresAt: string;
  refreshToken: string;
  refreshExpiresAt: string;
  user: Me;
};

export function presentSession(tokens: IssuedTokens, user: Me): SessionBundle {
  return {
    accessToken: tokens.accessToken,
    accessExpiresAt: tokens.accessExpiresAt.toISOString(),
    refreshToken: tokens.refreshToken,
    refreshExpiresAt: tokens.refreshExpiresAt.toISOString(),
    user,
  };
}
