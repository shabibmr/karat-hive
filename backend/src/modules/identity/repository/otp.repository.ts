import { Injectable } from '@nestjs/common';
import type { OtpChallenge, OtpPurpose } from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';

@Injectable()
export class OtpRepository {
  constructor(private readonly prisma: PrismaService) {}

  create(input: {
    mobileNumber: string;
    purpose: OtpPurpose;
    codeHash: string;
    expiresAt: Date;
    userId?: string | null;
  }): Promise<OtpChallenge> {
    return this.prisma.otpChallenge.create({
      data: {
        mobileNumber: input.mobileNumber,
        purpose: input.purpose,
        codeHash: input.codeHash,
        expiresAt: input.expiresAt,
        userId: input.userId ?? null,
      },
    });
  }

  findById(id: string): Promise<OtpChallenge | null> {
    return this.prisma.otpChallenge.findUnique({ where: { id } });
  }

  countSince(mobileNumber: string, purpose: OtpPurpose, since: Date): Promise<number> {
    return this.prisma.otpChallenge.count({
      where: { mobileNumber, purpose, createdAt: { gte: since } },
    });
  }

  async incrementAttempts(id: string): Promise<void> {
    await this.prisma.otpChallenge.update({ where: { id }, data: { attempts: { increment: 1 } } });
  }

  async consume(id: string, now: Date): Promise<void> {
    await this.prisma.otpChallenge.update({ where: { id }, data: { consumedAt: now } });
  }
}
