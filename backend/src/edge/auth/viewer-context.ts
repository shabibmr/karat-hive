import type { FastifyRequest } from 'fastify';
import type { UserAccountState, UserType, VendorVerificationState } from '@prisma/client';

export type ViewerRole = UserType;

export type ViewerContext = {
  userId: string;
  role: ViewerRole;
  tokenVersion: number;
  accountState: UserAccountState;
  preferredLanguage: 'en' | 'ar';
  vendorProfileId: string | null;
  vendorVerificationState: VendorVerificationState | null;
  vendorActivatedAt: Date | null;
  customerProfileId: string | null;
  adminProfileId: string | null;
};

export const VIEWER_CONTEXT_KEY = 'kh:viewer';

export function viewerOf(request: FastifyRequest): ViewerContext | undefined {
  return (request as FastifyRequest & { [VIEWER_CONTEXT_KEY]?: ViewerContext })[VIEWER_CONTEXT_KEY];
}
