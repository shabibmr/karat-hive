import { describe, expect, it, vi } from 'vitest';
import type { AbuseReport } from '@prisma/client';
import type { PrismaService } from '../../../platform/db/prisma.service';
import type { AuditWriter } from '../../audit';
import { AbuseService } from './abuse.service';
import { AbuseRepository } from '../repository/abuse.repository';

describe('AbuseService', () => {
  const mockRepo = {
    countReportsFromUserInPast24h: vi.fn(),
    resolveReportedUserId: vi.fn(),
    createReport: vi.fn(),
  } as unknown as AbuseRepository;

  const mockPrisma = {
    $transaction: vi.fn().mockImplementation((cb) => cb(mockPrisma)),
  } as unknown as PrismaService;

  const mockAudit = {
    append: vi.fn().mockResolvedValue(undefined),
  } as unknown as AuditWriter;

  const service = new AbuseService(mockRepo, mockPrisma, mockAudit);

  it('rate limits user if > 5 reports in past 24h (FR-CUS-033 AC4)', async () => {
    vi.mocked(mockRepo.countReportsFromUserInPast24h).mockResolvedValueOnce(5);

    await expect(
      service.submitReport(
        { userId: 'user-1', role: 'CUSTOMER', accountState: 'ACTIVE' },
        {
          entityType: 'VENDOR',
          entityId: 'a0000000-0000-0000-0000-000000000001',
          category: 'FRAUDULENT_OFFER',
          description: 'Spamming fake offers',
        },
      ),
    ).rejects.toMatchObject({
      errorCode: 'RATE_LIMITED',
      status: 429,
    });
  });

  it('submits abuse report and withholds reporter identity (G2-F04)', async () => {
    vi.mocked(mockRepo.countReportsFromUserInPast24h).mockResolvedValueOnce(2);
    vi.mocked(mockRepo.resolveReportedUserId).mockResolvedValueOnce('reported-user-1');
    vi.mocked(mockRepo.createReport).mockResolvedValueOnce({
      id: 'rep-1',
      reporterUserId: 'user-1',
      reportedUserId: 'reported-user-1',
      entityType: 'VENDOR',
      entityId: 'a0000000-0000-0000-0000-000000000001',
      category: 'FRAUDULENT_OFFER',
      description: 'Spamming fake offers',
      state: 'OPEN',
      resolution: null,
      resolvedByAdminId: null,
      createdAt: new Date(),
      updatedAt: new Date(),
    } as unknown as AbuseReport);

    const result = await service.submitReport(
      { userId: 'user-1', role: 'CUSTOMER', accountState: 'ACTIVE' },
      {
        entityType: 'VENDOR',
        entityId: 'a0000000-0000-0000-0000-000000000001',
        category: 'FRAUDULENT_OFFER',
        description: 'Spamming fake offers',
      },
    );

    expect(result).toEqual({
      id: 'rep-1',
      state: 'OPEN',
      acknowledged: true,
    });
    // reporter identity is not present
    expect('reporterUserId' in result).toBe(false);
    expect(mockAudit.append).toHaveBeenCalled();
  });
});
