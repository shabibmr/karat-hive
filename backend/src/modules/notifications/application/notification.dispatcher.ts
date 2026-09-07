import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import type { Prisma } from '@prisma/client';
import type { ClaimedOutboxEvent } from '../../../platform/outbox/outbox.claimer';
import { OutboxDispatcher } from '../../../platform/outbox/outbox.dispatcher';
import { renderPlaceholderCopy } from '../domain/notification.copy';
import {
  intentsFor,
  isNotificationConsumerEvent,
  isNotificationDispatchEvent,
  NOTIFICATION_CONSUMER_EVENTS,
  type Channel,
  type DispatchIntent,
  type RecipientRef,
} from '../domain/notification.plans';
import { NotificationRepository } from '../repository/notification.repository';
import { NotificationService, type DeliverNotificationInput } from './notification.service';

const CONSUMER = 'notifications:dispatch';

type AnnouncementChannels = { inApp?: boolean; push?: boolean; email?: boolean };

/**
 * Outbox consumer for Async-Contract notification events (G2-N02).
 * Quiet hours + preferences are evaluated inside deliver(), at dispatch time.
 */
@Injectable()
export class NotificationDispatcher implements OnModuleInit {
  private readonly logger = new Logger(NotificationDispatcher.name);

  constructor(
    private readonly outbox: OutboxDispatcher,
    private readonly repo: NotificationRepository,
    private readonly notifications: NotificationService,
  ) {}

  onModuleInit(): void {
    for (const eventType of NOTIFICATION_CONSUMER_EVENTS) {
      this.outbox.register(eventType, CONSUMER, (event) => this.handle(event));
    }
  }

  async handle(event: ClaimedOutboxEvent): Promise<void> {
    const eventType = event.eventType;
    if (!isNotificationConsumerEvent(eventType)) {
      this.logger.warn(`Unknown event type ${eventType}`);
      return;
    }
    if (!isNotificationDispatchEvent(eventType)) {
      return;
    }

    const intents = intentsFor(eventType, event.payload);
    if (intents.length === 0) {
      this.logger.warn(`No dispatch intents for ${eventType} eventId=${event.id}`);
      return;
    }

    for (const intent of intents) {
      await this.dispatchIntent(intent, event);
    }
  }

  private async dispatchIntent(intent: DispatchIntent, event: ClaimedOutboxEvent): Promise<void> {
    const resolved = await this.resolveRecipient(intent.recipient, intent);
    const copy = resolved.overrideCopy ?? renderPlaceholderCopy(intent.copyKey, intent.vars ?? {});
    const channels = resolved.channels ?? intent.channels;
    const isCritical = resolved.isCritical ?? intent.isCritical;

    for (const userId of resolved.userIds) {
      const input: DeliverNotificationInput = {
        recipientUserId: userId,
        type: intent.notificationType,
        category: intent.category,
        titleEn: copy.titleEn,
        titleAr: copy.titleAr,
        bodyEn: copy.bodyEn,
        bodyAr: copy.bodyAr,
        deepLink: intent.deepLink,
        isCritical,
        channels,
      };
      try {
        await this.notifications.deliver(input);
      } catch (error: unknown) {
        const msg = error instanceof Error ? error.message : String(error);
        this.logger.warn(`Deliver failed event=${event.eventType} user=${userId}: ${msg}`);
        throw error;
      }
    }

    if (intent.recipient.type === 'announcement') {
      await this.repo
        .updateAnnouncementDispatchStats(intent.recipient.announcementId, {
          sent: resolved.userIds.length,
          delivered: resolved.userIds.length,
          opened: 0,
        })
        .catch((error: unknown) => {
          const msg = error instanceof Error ? error.message : String(error);
          this.logger.warn(`Announcement stats update failed: ${msg}`);
        });
    }
  }

  private async resolveRecipient(
    ref: RecipientRef,
    intent: DispatchIntent,
  ): Promise<{
    userIds: string[];
    overrideCopy?: { titleEn: string; titleAr: string; bodyEn: string; bodyAr: string };
    channels?: Channel[];
    isCritical?: boolean;
  }> {
    switch (ref.type) {
      case 'user':
        return { userIds: [ref.userId] };
      case 'vendorProfiles':
        return { userIds: await this.repo.findVendorUserIdsByProfileIds(ref.profileIds) };
      case 'offerVendors':
        return { userIds: await this.repo.findVendorUserIdsByOfferIds(ref.offerIds) };
      case 'pendingOfferVendors':
        return { userIds: await this.repo.findPendingOfferVendorUserIds(ref.requestId) };
      case 'requestOfferVendors':
        return { userIds: await this.repo.findOfferVendorUserIdsForRequest(ref.requestId) };
      case 'admins':
        return { userIds: await this.repo.findAdminUserIds() };
      case 'announcement': {
        const ann = await this.repo.findAnnouncement(ref.announcementId);
        if (!ann) {
          this.logger.warn(`Announcement ${ref.announcementId} missing`);
          return { userIds: [] };
        }
        const audience = parseAudience(ann.audience);
        const userIds = await this.repo.findAudienceUserIds(audience);
        const channels = channelsFromAnnouncement(ann.channels, intent.channels);
        return {
          userIds,
          overrideCopy: {
            titleEn: ann.titleEn,
            titleAr: ann.titleAr,
            bodyEn: ann.bodyEn,
            bodyAr: ann.bodyAr,
          },
          channels,
          isCritical: ann.critical,
        };
      }
    }
  }
}

function parseAudience(raw: Prisma.JsonValue): {
  userTypes?: Array<'CUSTOMER' | 'VENDOR' | 'ADMIN'>;
  accountStates?: Array<'ACTIVE' | 'SUSPENDED' | 'DEACTIVATED'>;
  regionIds?: string[];
  categoryIds?: string[];
} {
  if (!raw || typeof raw !== 'object' || Array.isArray(raw)) return {};
  const obj = raw as Record<string, unknown>;
  const userTypes = Array.isArray(obj.userTypes)
    ? obj.userTypes.filter(
        (v): v is 'CUSTOMER' | 'VENDOR' | 'ADMIN' =>
          v === 'CUSTOMER' || v === 'VENDOR' || v === 'ADMIN',
      )
    : undefined;
  const accountStates = Array.isArray(obj.accountStates)
    ? obj.accountStates.filter(
        (v): v is 'ACTIVE' | 'SUSPENDED' | 'DEACTIVATED' =>
          v === 'ACTIVE' || v === 'SUSPENDED' || v === 'DEACTIVATED',
      )
    : undefined;
  const regionIds = Array.isArray(obj.regionIds)
    ? obj.regionIds.filter((v): v is string => typeof v === 'string')
    : undefined;
  const categoryIds = Array.isArray(obj.categoryIds)
    ? obj.categoryIds.filter((v): v is string => typeof v === 'string')
    : undefined;
  return { userTypes, accountStates, regionIds, categoryIds };
}

function channelsFromAnnouncement(raw: Prisma.JsonValue, fallback: Channel[]): Channel[] {
  if (!raw || typeof raw !== 'object' || Array.isArray(raw)) return fallback;
  const obj = raw as AnnouncementChannels;
  const channels: Channel[] = [];
  if (obj.inApp !== false) channels.push('IN_APP');
  if (obj.push === true) channels.push('PUSH');
  if (obj.email === true) channels.push('EMAIL');
  return channels.length > 0 ? channels : fallback;
}
