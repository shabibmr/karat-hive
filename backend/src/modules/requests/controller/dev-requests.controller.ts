import {
  CanActivate,
  Controller,
  ExecutionContext,
  HttpCode,
  HttpStatus,
  Inject,
  Injectable,
  Post,
  UseGuards,
} from '@nestjs/common';
import {
  Direction,
  Karat,
  Prisma,
  RequestState,
  RequestType,
  UserAccountState,
  UserType,
} from '@prisma/client';
import type { FastifyRequest } from 'fastify';
import { ENV, type Env } from '../../../config/env';
import { Public } from '../../../edge/auth/public.decorator';
import { ApiException } from '../../../edge/errors/api-exception';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { PrismaService } from '../../../platform/db/prisma.service';
import { enqueueOutbox } from '../../../platform/outbox/outbox.producer';
import { withTx } from '../../../platform/db/tx';
import { Clock } from '../../../shared/clock';
import { REQUEST_EXPIRY_HOURS } from '../domain/requests.types';
import { presentCustomerRequest } from '../presenter/request-customer.presenter';

@Injectable()
export class DevRequestsGuard implements CanActivate {
  constructor(@Inject(ENV) private readonly env: Env) {}

  canActivate(context: ExecutionContext): boolean {
    const notFound = new ApiException(HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND);
    if (!this.env.DEV_VERIFY_ENABLED || this.env.NODE_ENV === 'production') throw notFound;
    const request = context.switchToHttp().getRequest<FastifyRequest>();
    const key = request.headers['x-dev-key'];
    if (typeof key !== 'string' || key !== this.env.DEV_VERIFY_KEY) throw notFound;
    return true;
  }
}

@Controller('v1/dev/requests')
export class DevRequestsController {
  constructor(
    private readonly prisma: PrismaService,
    private readonly clock: Clock,
  ) {}

  @Public()
  @UseGuards(DevRequestsGuard)
  @HttpCode(HttpStatus.CREATED)
  @Post('seed')
  async seedRequests() {
    const now = this.clock.now();
    const expiresAt = new Date(now.getTime() + REQUEST_EXPIRY_HOURS * 60 * 60 * 1000);

    return withTx(this.prisma, async (tx) => {
      // Find or create test customer user and profile
      let user = await tx.user.findFirst({
        where: { email: 'dev-customer@karathive.ae' },
        include: { customerProfile: true },
      });

      if (!user) {
        user = await tx.user.create({
          data: {
            userType: UserType.CUSTOMER,
            accountState: UserAccountState.ACTIVE,
            email: 'dev-customer@karathive.ae',
            mobileNumber: '+971501234567',
            customerProfile: {
              create: {
                displayName: 'Dev Customer',
              },
            },
          },
          include: { customerProfile: true },
        });
      }

      if (!user || !user.customerProfile) {
        throw new Error('Failed to ensure customer profile for dev seed.');
      }

      const customerProfileId = user.customerProfile.id;

      // Get existing category and region
      const category = await tx.category.findFirst();
      const region = await tx.region.findFirst();

      if (!category || !region) {
        throw new Error('Categories and regions must be seeded before seeding requests.');
      }

      const types: RequestType[] = [
        RequestType.FIND_ORNAMENT,
        RequestType.SELL_OLD_GOLD,
        RequestType.GOLD_COIN,
        RequestType.GOLD_BULLION,
      ];

      const created = [];
      for (const reqType of types) {
        const reference = `REQ-DEV-${reqType.substring(0, 4)}-${Date.now().toString(36).toUpperCase()}`;
        const req = await tx.request.create({
          data: {
            reference,
            customerProfileId,
            requestType: reqType,
            direction: reqType === RequestType.SELL_OLD_GOLD ? Direction.SELL : Direction.BUY,
            state: RequestState.PUBLISHED,
            categoryId: category.id,
            regionId: region.id,
            purityKarat: Karat.K22,
            weightGrams: new Prisma.Decimal('15.50'),
            budgetMin: new Prisma.Decimal('3000.00'),
            budgetMax: new Prisma.Decimal('4500.00'),
            notes: `Dev seed request for ${reqType}`,
            publishedAt: now,
            expiresAt,
          },
        });

        await enqueueOutbox(tx, {
          eventType: 'request.published',
          aggregateType: 'request',
          aggregateId: req.id,
          payload: {
            requestId: req.id,
            reference: req.reference,
            customerProfileId: req.customerProfileId,
            requestType: req.requestType,
            categoryId: req.categoryId,
            regionId: req.regionId,
            purityKarat: req.purityKarat,
            weightGrams: req.weightGrams ? req.weightGrams.toString() : null,
            publishedAt: now.toISOString(),
            expiresAt: expiresAt.toISOString(),
          },
        });

        created.push(presentCustomerRequest(req));
      }

      return {
        seededCustomer: {
          userId: user.id,
          email: user.email,
          customerProfileId,
        },
        requests: created,
      };
    });
  }
}
