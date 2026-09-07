import { Injectable } from '@nestjs/common';
import type { PlatformSetting, Prisma, PrismaClient } from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';

export interface UserNotificationPreferenceDto {
  category: string;
  inApp: boolean;
  push: boolean;
  email: boolean;
}

@Injectable()
export class SettingsRepository {
  constructor(private readonly prisma: PrismaService) {}

  get client(): PrismaClient {
    return this.prisma;
  }

  async getAllPlatformSettings(): Promise<PlatformSetting[]> {
    return this.prisma.platformSetting.findMany();
  }

  async getPlatformSetting(key: string): Promise<PlatformSetting | null> {
    return this.prisma.platformSetting.findUnique({
      where: { key },
    });
  }

  async updatePlatformSetting(
    key: string,
    value: unknown,
    lastChangedByAdminId?: string,
  ): Promise<PlatformSetting> {
    return this.prisma.platformSetting.upsert({
      where: { key },
      update: {
        value: value as object,
        lastChangedByAdminId,
      },
      create: {
        key,
        value: value as object,
        dataType: typeof value,
        lastChangedByAdminId,
      },
    });
  }

  async getUserSettings(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        customerProfile: true,
        notificationPreferences: true,
      },
    });
    return user;
  }

  async updateUserSettings(
    userId: string,
    data: {
      preferredLanguage?: 'en' | 'ar';
      defaultRegionId?: string | null;
      quietHoursStart?: string | null;
      quietHoursEnd?: string | null;
      notifications?: Record<string, { inApp?: boolean; push?: boolean; email?: boolean }>;
    },
  ) {
    return this.prisma.$transaction(async (tx: Prisma.TransactionClient) => {
      if (
        data.preferredLanguage ||
        data.quietHoursStart !== undefined ||
        data.quietHoursEnd !== undefined
      ) {
        await tx.user.update({
          where: { id: userId },
          data: {
            ...(data.preferredLanguage ? { preferredLanguage: data.preferredLanguage } : {}),
            ...(data.quietHoursStart !== undefined
              ? { quietHoursStart: data.quietHoursStart }
              : {}),
            ...(data.quietHoursEnd !== undefined ? { quietHoursEnd: data.quietHoursEnd } : {}),
          },
        });
      }

      if (data.defaultRegionId !== undefined) {
        const cust = await tx.customerProfile.findUnique({ where: { userId } });
        if (cust) {
          await tx.customerProfile.update({
            where: { id: cust.id },
            data: { defaultRegionId: data.defaultRegionId },
          });
        }
      }

      if (data.notifications) {
        for (const [category, prefs] of Object.entries(data.notifications)) {
          await tx.notificationPreference.upsert({
            where: {
              userId_category: {
                userId,
                category,
              },
            },
            update: {
              ...(prefs.inApp !== undefined ? { inApp: prefs.inApp } : {}),
              ...(prefs.push !== undefined ? { push: prefs.push } : {}),
              ...(prefs.email !== undefined ? { email: prefs.email } : {}),
            },
            create: {
              userId,
              category,
              inApp: prefs.inApp ?? true,
              push: prefs.push ?? true,
              email: prefs.email ?? true,
            },
          });
        }
      }
    });
  }
}
