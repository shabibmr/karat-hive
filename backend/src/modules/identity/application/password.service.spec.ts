import { HttpStatus } from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { ErrorCode } from '../../../edge/errors/error-codes';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import type { PasswordHasher } from './password-hasher';
import type { UserRepository } from '../repository/user.repository';
import { PasswordService } from './password.service';

function viewer(overrides: Partial<ViewerContext> = {}): ViewerContext {
  return {
    userId: 'user-1',
    role: 'VENDOR',
    tokenVersion: 0,
    accountState: 'ACTIVE',
    preferredLanguage: 'en',
    vendorProfileId: 'vp-1',
    vendorVerificationState: 'VERIFIED',
    vendorActivatedAt: new Date(),
    customerProfileId: null,
    adminProfileId: null,
    ...overrides,
  };
}

describe('PasswordService', () => {
  const good = 'Str0ngEnough!x';

  it('sets a password the first time without currentPassword', async () => {
    const hasher: PasswordHasher = {
      hash: vi.fn().mockResolvedValue('scrypt$salt$hash'),
      verify: vi.fn(),
    };
    const users = {
      findById: vi.fn().mockResolvedValue({
        id: 'user-1',
        passwordHash: null,
        deletedAt: null,
      }),
      setPasswordHash: vi.fn().mockResolvedValue(undefined),
    } as unknown as UserRepository;

    const service = new PasswordService(hasher, users);
    await service.setOrChange(viewer(), { newPassword: good });

    expect(hasher.hash).toHaveBeenCalledWith(good);
    expect(users.setPasswordHash).toHaveBeenCalledWith('user-1', 'scrypt$salt$hash');
    expect(hasher.verify).not.toHaveBeenCalled();
  });

  it('requires currentPassword when a hash already exists', async () => {
    const hasher: PasswordHasher = {
      hash: vi.fn(),
      verify: vi.fn(),
    };
    const users = {
      findById: vi.fn().mockResolvedValue({
        id: 'user-1',
        passwordHash: 'scrypt$old$old',
        deletedAt: null,
      }),
      setPasswordHash: vi.fn(),
    } as unknown as UserRepository;

    const service = new PasswordService(hasher, users);
    await expect(service.setOrChange(viewer(), { newPassword: good })).rejects.toMatchObject({
      status: HttpStatus.UNAUTHORIZED,
      errorCode: ErrorCode.UNAUTHENTICATED,
    });
    expect(users.setPasswordHash).not.toHaveBeenCalled();
  });

  it('changes password when currentPassword verifies', async () => {
    const hasher: PasswordHasher = {
      hash: vi.fn().mockResolvedValue('scrypt$new$new'),
      verify: vi.fn().mockResolvedValue(true),
    };
    const users = {
      findById: vi.fn().mockResolvedValue({
        id: 'user-1',
        passwordHash: 'scrypt$old$old',
        deletedAt: null,
      }),
      setPasswordHash: vi.fn().mockResolvedValue(undefined),
    } as unknown as UserRepository;

    const service = new PasswordService(hasher, users);
    await service.setOrChange(viewer(), { currentPassword: 'OldPassw0rd!!', newPassword: good });

    expect(hasher.verify).toHaveBeenCalledWith('OldPassw0rd!!', 'scrypt$old$old');
    expect(users.setPasswordHash).toHaveBeenCalledWith('user-1', 'scrypt$new$new');
  });

  it('rejects policy violations with PASSWORD_POLICY', async () => {
    const hasher: PasswordHasher = {
      hash: vi.fn(),
      verify: vi.fn(),
    };
    const users = {
      findById: vi.fn(),
      setPasswordHash: vi.fn(),
    } as unknown as UserRepository;

    const service = new PasswordService(hasher, users);
    await expect(service.setOrChange(viewer(), { newPassword: 'short' })).rejects.toMatchObject({
      status: HttpStatus.BAD_REQUEST,
      errorCode: ErrorCode.PASSWORD_POLICY,
    });
    expect(users.findById).not.toHaveBeenCalled();
  });

  it('forbids Customers', async () => {
    const hasher: PasswordHasher = { hash: vi.fn(), verify: vi.fn() };
    const users = { findById: vi.fn(), setPasswordHash: vi.fn() } as unknown as UserRepository;
    const service = new PasswordService(hasher, users);

    await expect(
      service.setOrChange(viewer({ role: 'CUSTOMER', vendorProfileId: null }), {
        newPassword: good,
      }),
    ).rejects.toMatchObject({
      status: HttpStatus.FORBIDDEN,
      errorCode: ErrorCode.FORBIDDEN,
    });
  });
});
