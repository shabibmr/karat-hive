import { Injectable } from '@nestjs/common';
import { Prisma, type GoldRateSource, type Karat } from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';
import type { DbTx } from '../../../platform/db/tx';
import { ALL_KARATS } from '../domain/purity';
import { pickEffectiveRate, type RateRow } from '../domain/effective-rate';
import {
  GOLD_RATE_SETTING,
  parseIngestState,
  type GoldRateIngestState,
} from '../domain/settings-keys';

@Injectable()
export class GoldRateRepository {
  constructor(private readonly prisma: PrismaService) {}

  private db(tx?: DbTx) {
    return tx ?? this.prisma;
  }

  async getSetting(key: string, tx?: DbTx): Promise<unknown> {
    const row = await this.db(tx).platformSetting.findUnique({ where: { key } });
    return row?.value ?? null;
  }

  async setSetting(key: string, value: unknown, dataType: string, tx?: DbTx): Promise<void> {
    await this.db(tx).platformSetting.upsert({
      where: { key },
      update: { value: value as Prisma.InputJsonValue },
      create: { key, value: value as Prisma.InputJsonValue, dataType },
    });
  }

  async getIngestState(tx?: DbTx): Promise<GoldRateIngestState> {
    const value = await this.getSetting(GOLD_RATE_SETTING.ingestState, tx);
    return parseIngestState(value);
  }

  async setIngestState(state: GoldRateIngestState, tx?: DbTx): Promise<void> {
    await this.setSetting(GOLD_RATE_SETTING.ingestState, state, 'json', tx);
  }

  async upsertFeedRate(
    input: {
      purityKarat: Karat;
      ratePerGramAed: Prisma.Decimal;
      sourceTimestamp: Date;
      feedProvider: string;
    },
    tx?: DbTx,
  ): Promise<RateRow> {
    return this.db(tx).goldRate.upsert({
      where: {
        purityKarat_source_sourceTimestamp: {
          purityKarat: input.purityKarat,
          source: 'FEED',
          sourceTimestamp: input.sourceTimestamp,
        },
      },
      create: {
        purityKarat: input.purityKarat,
        ratePerGramAed: input.ratePerGramAed,
        source: 'FEED',
        feedProvider: input.feedProvider,
        sourceTimestamp: input.sourceTimestamp,
      },
      update: {
        ratePerGramAed: input.ratePerGramAed,
        feedProvider: input.feedProvider,
      },
    });
  }

  async createOverride(
    input: {
      purityKarat: Karat;
      ratePerGramAed: Prisma.Decimal;
      sourceTimestamp: Date;
      overrideReason: string;
      overrideExpiresAt: Date;
    },
    tx?: DbTx,
  ): Promise<RateRow> {
    return this.db(tx).goldRate.upsert({
      where: {
        purityKarat_source_sourceTimestamp: {
          purityKarat: input.purityKarat,
          source: 'MANUAL_OVERRIDE',
          sourceTimestamp: input.sourceTimestamp,
        },
      },
      create: {
        purityKarat: input.purityKarat,
        ratePerGramAed: input.ratePerGramAed,
        source: 'MANUAL_OVERRIDE',
        feedProvider: null,
        sourceTimestamp: input.sourceTimestamp,
        overrideReason: input.overrideReason,
        overrideExpiresAt: input.overrideExpiresAt,
      },
      update: {
        ratePerGramAed: input.ratePerGramAed,
        overrideReason: input.overrideReason,
        overrideExpiresAt: input.overrideExpiresAt,
      },
    });
  }

  async findCandidates(karat: Karat, tx?: DbTx): Promise<RateRow[]> {
    return this.db(tx).goldRate.findMany({
      where: { purityKarat: karat },
      orderBy: [{ sourceTimestamp: 'desc' }, { createdAt: 'desc' }],
      take: 20,
    });
  }

  async findEffectiveRate(karat: Karat, now: Date, tx?: DbTx): Promise<RateRow | null> {
    const rows = await this.findCandidates(karat, tx);
    return pickEffectiveRate(rows, now);
  }

  async findEffectiveRates(now: Date, tx?: DbTx): Promise<RateRow[]> {
    const picked = await Promise.all(
      ALL_KARATS.map((karat) => this.findEffectiveRate(karat, now, tx)),
    );
    return picked.filter((row): row is RateRow => row !== null);
  }

  async listHistory(options: {
    limit: number;
    cursor?: string;
    karat?: Karat;
    source?: GoldRateSource;
  }): Promise<{ items: RateRow[]; nextCursor: string | null }> {
    const limit = Math.min(options.limit, 100);
    const items = await this.prisma.goldRate.findMany({
      where: {
        ...(options.karat ? { purityKarat: options.karat } : {}),
        ...(options.source ? { source: options.source } : {}),
      },
      take: limit + 1,
      ...(options.cursor ? { cursor: { id: options.cursor }, skip: 1 } : {}),
      orderBy: [{ sourceTimestamp: 'desc' }, { createdAt: 'desc' }, { id: 'desc' }],
    });

    let nextCursor: string | null = null;
    if (items.length > limit) {
      const next = items.pop();
      nextCursor = next?.id ?? null;
    }
    return { items, nextCursor };
  }

  async listActiveAdminUserIds(tx?: DbTx): Promise<string[]> {
    const rows = await this.db(tx).user.findMany({
      where: { userType: 'ADMIN', accountState: 'ACTIVE', deletedAt: null },
      select: { id: true },
    });
    return rows.map((r) => r.id);
  }
}
