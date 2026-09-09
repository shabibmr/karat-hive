import { beforeEach, describe, expect, it, vi } from 'vitest';
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
    lockRequest: vi.fn(),
    listDistinctVendorReporterIds: vi.fn(),
    isEntityFlagged: vi.fn(),
    flagAllReportsForEntity: vi.fn(),
  } as unknown as AbuseRepository;

  const mockPrisma = {
    $transaction: vi.fn().mockImplementation((cb) => cb(mockPrisma)),
  } as unknown as PrismaService;

  const mockAudit = {
    append: vi.fn().mockResolvedValue(undefined),
  } as unknown as AuditWriter;

  let service: AbuseService;

  const requestId = 'a0000000-0000-0000-0000-000000000099';

  function reportRow(overrides: Partial<AbuseReport> = {}): AbuseReport {
    return {
      id: 'rep-1',
      reporterUserId: 'vendor-1',
      reportedUserId: 'customer-1',
      entityType: 'REQUEST',
      entityId: requestId,
      category: 'SPAM',
      description: 'Suspicious request',
      state: 'OPEN',
      priority: false,
      resolution: null,
      resolvedByAdminId: null,
      createdAt: new Date(),
      updatedAt: new Date(),
      ...overrides,
    } as unknown as AbuseReport;
  }

  beforeEach(() => {
    vi.clearAllMocks();
    vi.mocked(mockPrisma.$transaction).mockImplementation((cb) => cb(mockPrisma));
    vi.mocked(mockAudit.append).mockResolvedValue(undefined);
    vi.mocked(mockRepo.lockRequest).mockResolvedValue(undefined);
    vi.mocked(mockRepo.flagAllReportsForEntity).mockResolvedValue(undefined);
    service = new AbuseService(mockRepo, mockPrisma, mockAudit);
  });

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
    vi.mocked(mockRepo.createReport).mockResolvedValueOnce(
      reportRow({
        id: 'rep-1',
        reporterUserId: 'user-1',
        reportedUserId: 'reported-user-1',
        entityType: 'VENDOR',
        entityId: 'a0000000-0000-0000-0000-000000000001',
        category: 'FRAUDULENT_OFFER',
        description: 'Spamming fake offers',
      }),
    );

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
    expect('reporterUserId' in result).toBe(false);
    expect(mockAudit.append).toHaveBeenCalled();
    expect(mockRepo.lockRequest).not.toHaveBeenCalled();
    expect(mockRepo.listDistinctVendorReporterIds).not.toHaveBeenCalled();
    expect(mockRepo.flagAllReportsForEntity).not.toHaveBeenCalled();
  });

  it('acquires row lock when reporting a REQUEST to prevent concurrent auto-flag races', async () => {
    vi.mocked(mockRepo.countReportsFromUserInPast24h).mockResolvedValueOnce(0);
    vi.mocked(mockRepo.resolveReportedUserId).mockResolvedValueOnce('customer-1');
    vi.mocked(mockRepo.createReport).mockResolvedValueOnce(
      reportRow({ id: 'rep-lock-1', reporterUserId: 'vendor-1' }),
    );
    vi.mocked(mockRepo.listDistinctVendorReporterIds).mockResolvedValueOnce(['vendor-1']);

    await service.submitReport(
      { userId: 'vendor-1', role: 'VENDOR', accountState: 'ACTIVE' },
      {
        entityType: 'REQUEST',
        entityId: requestId,
        category: 'SPAM',
        description: 'Testing row lock',
      },
    );

    expect(mockRepo.lockRequest).toHaveBeenCalledWith(expect.anything(), requestId);
  });

  it('auto-flags Request priority when 3 distinct Vendors report (FR-VEN-030 AC4)', async () => {
    vi.mocked(mockRepo.countReportsFromUserInPast24h).mockResolvedValueOnce(0);
    vi.mocked(mockRepo.resolveReportedUserId).mockResolvedValueOnce('customer-1');
    vi.mocked(mockRepo.createReport).mockResolvedValueOnce(
      reportRow({ id: 'rep-3', reporterUserId: 'vendor-3' }),
    );
    vi.mocked(mockRepo.listDistinctVendorReporterIds).mockResolvedValueOnce([
      'vendor-1',
      'vendor-2',
      'vendor-3',
    ]);
    vi.mocked(mockRepo.isEntityFlagged).mockResolvedValueOnce(false);

    await service.submitReport(
      { userId: 'vendor-3', role: 'VENDOR', accountState: 'ACTIVE' },
      {
        entityType: 'REQUEST',
        entityId: requestId,
        category: 'SPAM',
        description: 'Suspicious request',
      },
    );

    expect(mockRepo.lockRequest).toHaveBeenCalledWith(
      mockPrisma,
      requestId,
    );
    expect(mockRepo.listDistinctVendorReporterIds).toHaveBeenCalledWith(
      mockPrisma,
      'REQUEST',
      requestId,
    );
    expect(mockRepo.flagAllReportsForEntity).toHaveBeenCalledWith(
      mockPrisma,
      'REQUEST',
      requestId,
    );
    expect(mockAudit.append).toHaveBeenCalledWith(
      mockPrisma,
      expect.objectContaining({
        action: 'ABUSE_REPORT_AUTO_FLAGGED',
        entityId: 'rep-3',
        afterValue: expect.objectContaining({
          entityType: 'REQUEST',
          entityId: requestId,
          vendorReporterCount: 3,
        }),
      }),
    );
  });

  it('does not auto-flag when three reports are from the same Vendor', async () => {
    vi.mocked(mockRepo.countReportsFromUserInPast24h).mockResolvedValueOnce(2);
    vi.mocked(mockRepo.resolveReportedUserId).mockResolvedValueOnce('customer-1');
    vi.mocked(mockRepo.createReport).mockResolvedValueOnce(
      reportRow({ id: 'rep-same-3', reporterUserId: 'vendor-1' }),
    );
    vi.mocked(mockRepo.listDistinctVendorReporterIds).mockResolvedValueOnce(['vendor-1']);

    await service.submitReport(
      { userId: 'vendor-1', role: 'VENDOR', accountState: 'ACTIVE' },
      {
        entityType: 'REQUEST',
        entityId: requestId,
        category: 'SPAM',
        description: 'Repeat report',
      },
    );

    expect(mockRepo.lockRequest).toHaveBeenCalledWith(
      mockPrisma,
      requestId,
    );
    expect(mockRepo.flagAllReportsForEntity).not.toHaveBeenCalled();
    expect(mockRepo.isEntityFlagged).not.toHaveBeenCalled();
    expect(mockAudit.append).not.toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({ action: 'ABUSE_REPORT_AUTO_FLAGGED' }),
    );
  });

  it('fourth distinct Vendor report is idempotent — no duplicate AUTO_FLAGGED audit', async () => {
    vi.mocked(mockRepo.countReportsFromUserInPast24h).mockResolvedValueOnce(0);
    vi.mocked(mockRepo.resolveReportedUserId).mockResolvedValueOnce('customer-1');
    vi.mocked(mockRepo.createReport).mockResolvedValueOnce(
      reportRow({ id: 'rep-4', reporterUserId: 'vendor-4' }),
    );
    vi.mocked(mockRepo.listDistinctVendorReporterIds).mockResolvedValueOnce([
      'vendor-1',
      'vendor-2',
      'vendor-3',
      'vendor-4',
    ]);
    vi.mocked(mockRepo.isEntityFlagged).mockResolvedValueOnce(true);

    await service.submitReport(
      { userId: 'vendor-4', role: 'VENDOR', accountState: 'ACTIVE' },
      {
        entityType: 'REQUEST',
        entityId: requestId,
        category: 'SPAM',
        description: 'Fourth report',
      },
    );

    expect(mockRepo.flagAllReportsForEntity).toHaveBeenCalledWith(
      mockPrisma,
      'REQUEST',
      requestId,
    );
    expect(mockAudit.append).toHaveBeenCalledTimes(1);
    expect(mockAudit.append).toHaveBeenCalledWith(
      mockPrisma,
      expect.objectContaining({ action: 'ABUSE_REPORTED' }),
    );
    expect(mockAudit.append).not.toHaveBeenCalledWith(
      expect.anything(),
      expect.objectContaining({ action: 'ABUSE_REPORT_AUTO_FLAGGED' }),
    );
  });
});
