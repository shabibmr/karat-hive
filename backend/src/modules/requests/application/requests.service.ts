import { HttpStatus, Injectable } from '@nestjs/common';
import { RequestState } from '@prisma/client';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { PrismaService } from '../../../platform/db/prisma.service';
import { withTx } from '../../../platform/db/tx';
import { enqueueOutbox } from '../../../platform/outbox/outbox.producer';
import { Clock } from '../../../shared/clock';
import { CreateRequestDraftInput, REQUEST_EXPIRY_HOURS } from '../domain/requests.types';
import { CustomerRequestView, presentCustomerRequest } from '../presenter/request-customer.presenter';
import { presentVendorRequest, VendorRequestView } from '../presenter/request-vendor.presenter';
import { RequestsRepository } from '../repository/requests.repository';

@Injectable()
export class RequestsService {
  constructor(
    private readonly repository: RequestsRepository,
    private readonly prisma: PrismaService,
    private readonly clock: Clock,
  ) {}

  async createDraft(input: CreateRequestDraftInput): Promise<CustomerRequestView> {
    const created = await this.repository.createDraft(input);
    return presentCustomerRequest(created);
  }

  async publishRequest(requestId: string, customerProfileId: string): Promise<CustomerRequestView> {
    const existing = await this.repository.findById(requestId);
    if (!existing) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }
    if (existing.customerProfileId !== customerProfileId) {
      throw new ApiException(HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
    }
    if (existing.state !== RequestState.DRAFT) {
      throw new ApiException(HttpStatus.CONFLICT, ErrorCode.REQUEST_NOT_PUBLISHABLE);
    }

    const now = this.clock.now();
    const expiresAt = new Date(now.getTime() + REQUEST_EXPIRY_HOURS * 60 * 60 * 1000);
    const reference = existing.reference ?? `REQ-${Date.now().toString(36).toUpperCase()}-${Math.random().toString(36).substring(2, 6).toUpperCase()}`;

    const published = await withTx(this.prisma, async (tx) => {
      const updated = await this.repository.publish(requestId, reference, now, expiresAt, tx);

      await enqueueOutbox(tx, {
        eventType: 'request.published',
        aggregateType: 'request',
        aggregateId: updated.id,
        payload: {
          requestId: updated.id,
          reference: updated.reference,
          customerProfileId: updated.customerProfileId,
          requestType: updated.requestType,
          categoryId: updated.categoryId,
          regionId: updated.regionId,
          purityKarat: updated.purityKarat,
          weightGrams: updated.weightGrams ? updated.weightGrams.toString() : null,
          publishedAt: now.toISOString(),
          expiresAt: expiresAt.toISOString(),
        },
      });

      return updated;
    });

    return presentCustomerRequest(published);
  }

  async getRequestForVendor(
    requestId: string,
    vendorProfileId: string,
  ): Promise<VendorRequestView> {
    const request = await this.repository.findById(requestId);
    if (!request || request.state === RequestState.DRAFT || request.state === RequestState.CANCELLED) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    // CP2-A10: Must be in the caller's match set; if not -> 404, never 403
    const match = await this.repository.findVendorMatch(requestId, vendorProfileId);
    if (!match || !match.isEligible) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    const regionName = (request as unknown as { region?: { nameEn?: string } })?.region?.nameEn ?? 'UAE';
    return presentVendorRequest(
      request as Parameters<typeof presentVendorRequest>[0],
      {
        label: `Customer in ${regionName}`,
        region: regionName,
        ratingScore: 5.0,
        dealCount: 1,
      },
      match.viewedAt,
    );
  }

  async getRequestForCustomer(
    requestId: string,
    customerProfileId: string,
  ): Promise<CustomerRequestView> {
    const request = await this.repository.findById(requestId);
    if (!request || request.customerProfileId !== customerProfileId) {
      throw new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    }

    return presentCustomerRequest(request);
  }
}
