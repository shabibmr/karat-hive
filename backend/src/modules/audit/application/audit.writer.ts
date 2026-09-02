import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import type { DbTx } from '../../../platform/db/tx';

export type AuditAppendInput = {
  actorUserId?: string | null;
  action: string;
  entityType: string;
  entityId?: string | null;
  beforeValue?: Prisma.InputJsonValue | null;
  afterValue?: Prisma.InputJsonValue | null;
  ipAddress?: string | null;
  userAgent?: string | null;
};

@Injectable()
export class AuditWriter {
  async append(tx: DbTx, input: AuditAppendInput): Promise<void> {
    await tx.auditLog.create({
      data: {
        actorUserId: input.actorUserId ?? null,
        action: input.action,
        entityType: input.entityType,
        entityId: input.entityId ?? null,
        beforeValue: input.beforeValue ?? undefined,
        afterValue: input.afterValue ?? undefined,
        ipAddress: input.ipAddress ?? null,
        userAgent: input.userAgent ?? null,
      },
    });
  }
}
