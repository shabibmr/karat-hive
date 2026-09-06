import { Injectable } from '@nestjs/common';
import type { PlatformSetting, Prisma } from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';
import type { DbTx } from '../../../platform/db/tx';

@Injectable()
export class SettingsRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(tx?: DbTx): Promise<PlatformSetting[]> {
    const client = tx ?? this.prisma;
    return client.platformSetting.findMany();
  }

  async findByKey(key: string, tx?: DbTx): Promise<PlatformSetting | null> {
    const client = tx ?? this.prisma;
    return client.platformSetting.findUnique({ where: { key } });
  }

  async upsert(
    key: string,
    value: Prisma.InputJsonValue,
    dataType: string,
    tx?: DbTx,
  ): Promise<PlatformSetting> {
    const client = tx ?? this.prisma;
    return client.platformSetting.upsert({
      where: { key },
      update: { value, dataType },
      create: { key, value, dataType },
    });
  }
}
