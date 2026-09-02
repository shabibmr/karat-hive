import { CanActivate, ExecutionContext, HttpStatus, Injectable, SetMetadata } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import type { FastifyRequest } from 'fastify';
import { viewerOf } from '../../../edge/auth/viewer-context';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';

/**
 * Usability mirror of BR-002 for the Vendor onboarding routes (SAM-GAP-7 resolution).
 * `SHELL`  — any Vendor with a profile (Awaiting-Approval shell routes).
 * `VERIFIED` — verificationState VERIFIED, activated or not (first taxonomy declaration).
 * `ACTIVE` — fully marketplace-active (dashboard and beyond).
 * The server still re-checks every rule; a bypassed guard finds a 403 waiting.
 */
export type VendorStage = 'SHELL' | 'VERIFIED' | 'ACTIVE';

export const VENDOR_STAGE_KEY = 'kh:vendor-stage';
export const VendorStageRequired = (stage: VendorStage) => SetMetadata(VENDOR_STAGE_KEY, stage);

@Injectable()
export class VendorAccessGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const stage = this.reflector.getAllAndOverride<VendorStage | undefined>(VENDOR_STAGE_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!stage) return true;

    const request = context.switchToHttp().getRequest<FastifyRequest>();
    const viewer = viewerOf(request);
    if (!viewer || viewer.role !== 'VENDOR' || !viewer.vendorProfileId) {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.VENDOR_NOT_ACTIVE);
    }
    if (viewer.accountState === 'SUSPENDED') {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.ACCOUNT_SUSPENDED);
    }
    if (viewer.accountState === 'DEACTIVATED') {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.ACCOUNT_DEACTIVATED);
    }

    const verification = viewer.vendorVerificationState;
    const isActive = verification === 'VERIFIED' && viewer.vendorActivatedAt !== null;

    if (stage === 'ACTIVE' && !isActive) {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.VENDOR_NOT_ACTIVE);
    }
    if (stage === 'VERIFIED' && verification !== 'VERIFIED') {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.VENDOR_NOT_ACTIVE);
    }
    // SHELL: any non-suspended Vendor with a profile passes.
    return true;
  }
}
