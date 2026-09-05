export type IdentityAuthCode = 'UNAUTHENTICATED' | 'TOKEN_EXPIRED' | 'REFRESH_REUSE_DETECTED';

export class IdentityAuthError extends Error {
  constructor(readonly code: IdentityAuthCode) {
    super(code);
  }
}
