import { describe, expect, it, vi, beforeEach } from 'vitest';
import { HttpStatus } from '@nestjs/common';
import { OtpService } from './otp.service';
import { ErrorCode } from '../../../edge/errors/error-codes';
import { Clock } from '../../../shared/clock';
import type { Env } from '../../../config/env';
import type { OtpSender } from '../../../platform/ports/otp-sender.port';
import type { OtpRepository } from '../repository/otp.repository';
import type { UserRepository } from '../repository/user.repository';
import type { User } from '@prisma/client';

describe('OtpService', () => {
  let service: OtpService;
  let env: Env;
  let sender: OtpSender;
  let clock: Clock;
  let repo: OtpRepository;
  let users: UserRepository;

  const mockNow = new Date('2026-09-26T10:00:00Z');

  beforeEach(() => {
    env = {
      OTP_MAX_PER_NUMBER_PER_HOUR: 5,
      OTP_TTL_SECONDS: 300,
      OTP_DEV_MODE: 'fixed',
      OTP_FIXED_CODE: '123456',
    } as unknown as Env;

    sender = {
      send: vi.fn().mockResolvedValue(undefined),
    } as unknown as OtpSender;

    clock = {
      now: vi.fn().mockReturnValue(mockNow),
    } as unknown as Clock;

    repo = {
      countSince: vi.fn().mockResolvedValue(0),
      create: vi.fn().mockResolvedValue({ id: 'chal-1' }),
      findById: vi.fn().mockResolvedValue(null),
      incrementAttempts: vi.fn().mockResolvedValue({}),
      consume: vi.fn().mockResolvedValue({}),
    } as unknown as OtpRepository;

    users = {
      findByMobile: vi.fn().mockResolvedValue(null),
    } as unknown as UserRepository;

    service = new OtpService(env, sender, clock, repo, users);
  });

  it('issues challenge for customer registration when number not registered', async () => {
    const res = await service.issueChallenge('+971501112233', 'REGISTER_CUSTOMER');
    expect(res.challengeId).toBe('chal-1');
    expect(sender.send).toHaveBeenCalled();
  });

  it('throws 409 MOBILE_ALREADY_REGISTERED when registered with same role for customer', async () => {
    vi.mocked(users.findByMobile).mockResolvedValue({
      id: 'u-1',
      userType: 'CUSTOMER',
    } as User);

    await expect(
      service.issueChallenge('+971501112233', 'REGISTER_CUSTOMER'),
    ).rejects.toMatchObject({
      status: HttpStatus.CONFLICT,
      errorCode: ErrorCode.MOBILE_ALREADY_REGISTERED,
    });
  });

  it('throws 409 ACCOUNT_ROLE_CONFLICT when registered with different role for customer', async () => {
    vi.mocked(users.findByMobile).mockResolvedValue({
      id: 'u-1',
      userType: 'VENDOR',
    } as User);

    await expect(
      service.issueChallenge('+971501112233', 'REGISTER_CUSTOMER'),
    ).rejects.toMatchObject({
      status: HttpStatus.CONFLICT,
      errorCode: ErrorCode.ACCOUNT_ROLE_CONFLICT,
    });
  });

  it('throws 409 MOBILE_ALREADY_REGISTERED when registered with same role for vendor', async () => {
    vi.mocked(users.findByMobile).mockResolvedValue({
      id: 'u-1',
      userType: 'VENDOR',
    } as User);

    await expect(
      service.issueChallenge('+971501112233', 'REGISTER_VENDOR'),
    ).rejects.toMatchObject({
      status: HttpStatus.CONFLICT,
      errorCode: ErrorCode.MOBILE_ALREADY_REGISTERED,
    });
  });

  it('throws 409 ACCOUNT_ROLE_CONFLICT when registered with different role for vendor', async () => {
    vi.mocked(users.findByMobile).mockResolvedValue({
      id: 'u-1',
      userType: 'CUSTOMER',
    } as User);

    await expect(
      service.issueChallenge('+971501112233', 'REGISTER_VENDOR'),
    ).rejects.toMatchObject({
      status: HttpStatus.CONFLICT,
      errorCode: ErrorCode.ACCOUNT_ROLE_CONFLICT,
    });
  });
});
