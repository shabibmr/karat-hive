import { describe, expect, it, vi, beforeEach } from 'vitest';
import type { ClaimedOutboxEvent } from '../../../platform/outbox/outbox.claimer';
import type { OutboxDispatcher } from '../../../platform/outbox/outbox.dispatcher';
import { NotificationDispatcher } from './notification.dispatcher';
import { NotificationService } from './notification.service';
import { NotificationRepository } from '../repository/notification.repository';
import { NOTIFICATION_CONSUMER_EVENTS } from '../domain/notification.plans';

function event(overrides: Partial<ClaimedOutboxEvent> = {}): ClaimedOutboxEvent {
  return {
    id: 'evt-1',
    eventType: 'offer.submitted',
    aggregateType: 'offer',
    aggregateId: 'off-1',
    payload: {},
    attempts: 0,
    ...overrides,
  };
}

describe('NotificationDispatcher (G2-N02)', () => {
  const registrations: Array<{ eventType: string; consumer: string }> = [];
  const outbox = {
    register: vi.fn((eventType: string, consumer: string) => {
      registrations.push({ eventType, consumer });
    }),
  } as unknown as OutboxDispatcher;

  const repo = {
    findVendorUserIdsByOfferIds: vi.fn(),
    findVendorUserIdsByProfileIds: vi.fn(),
    findPendingOfferVendorUserIds: vi.fn(),
    findOfferVendorUserIdsForRequest: vi.fn(),
    findAdminUserIds: vi.fn(),
    findAnnouncement: vi.fn(),
    findAudienceUserIds: vi.fn(),
    updateAnnouncementDispatchStats: vi.fn().mockResolvedValue(undefined),
  } as unknown as NotificationRepository;

  const notifications = {
    deliver: vi.fn().mockResolvedValue({ id: 'n-1' }),
  } as unknown as NotificationService;

  let dispatcher: NotificationDispatcher;

  beforeEach(() => {
    registrations.length = 0;
    vi.mocked(notifications.deliver).mockClear();
    vi.mocked(repo.findVendorUserIdsByOfferIds).mockReset();
    dispatcher = new NotificationDispatcher(outbox, repo, notifications);
  });

  it('registers notifications:dispatch for all 21 consumer events', () => {
    dispatcher.onModuleInit();
    expect(registrations).toHaveLength(21);
    expect(new Set(registrations.map((r) => r.eventType))).toEqual(
      new Set(NOTIFICATION_CONSUMER_EVENTS),
    );
    expect(registrations.every((r) => r.consumer === 'notifications:dispatch')).toBe(true);
  });

  it('delivers offer.submitted to the Customer with first-Offer copy', async () => {
    await dispatcher.handle(
      event({
        payload: {
          offerId: 'off-1',
          requestId: 'req-1',
          customerUserId: 'cus-1',
          isFirstOfferOnRequest: true,
        },
      }),
    );

    expect(notifications.deliver).toHaveBeenCalledOnce();
    expect(vi.mocked(notifications.deliver).mock.calls[0]?.[0]).toMatchObject({
      recipientUserId: 'cus-1',
      type: 'offer.submitted',
      titleEn: 'You have a new Offer',
      deepLink: '/requests/req-1/offers',
      channels: ['IN_APP', 'PUSH'],
      isCritical: false,
    });
  });

  it('delivers request.matched to the Vendor', async () => {
    await dispatcher.handle(
      event({
        eventType: 'request.matched',
        payload: { requestId: 'req-1', vendorUserId: 'ven-1' },
      }),
    );

    expect(vi.mocked(notifications.deliver).mock.calls[0]?.[0]).toMatchObject({
      recipientUserId: 'ven-1',
      type: 'request.matched',
      titleEn: 'New matched Request',
      deepLink: '/requests/req-1',
    });
  });

  it('fans offer.accepted to winner, losers, and Customer without reading the winning Offer', async () => {
    vi.mocked(repo.findVendorUserIdsByOfferIds).mockResolvedValueOnce(['ven-lose']);

    await dispatcher.handle(
      event({
        eventType: 'offer.accepted',
        payload: {
          requestId: 'req-1',
          acceptedOfferId: 'offer-win',
          connectionId: 'conn-1',
          customerUserId: 'cus-1',
          winnerVendorUserId: 'ven-win',
          rejectedOfferIds: ['offer-l1'],
        },
      }),
    );

    expect(repo.findVendorUserIdsByOfferIds).toHaveBeenCalledWith(['offer-l1']);
    const delivered = vi.mocked(notifications.deliver).mock.calls.map((c) => c[0]);
    expect(delivered.map((d) => d.recipientUserId)).toEqual(['ven-win', 'ven-lose', 'cus-1']);
    const loser = delivered.find((d) => d.recipientUserId === 'ven-lose');
    expect(loser?.titleEn).toBe('The Customer selected another Vendor');
    expect(loser?.bodyEn).not.toMatch(/AED|price|ven-win|offer-win/i);
    expect(loser?.deepLink).toBe('/requests/req-1');
  });

  it('skips events that have no notification trigger', async () => {
    await dispatcher.handle(event({ eventType: 'request.published', payload: { requestId: 'r' } }));
    await dispatcher.handle(event({ eventType: 'media.uploaded', payload: {} }));
    expect(notifications.deliver).not.toHaveBeenCalled();
  });

  it('warns on an unknown event type', async () => {
    const warn = vi.spyOn(dispatcher['logger'], 'warn');
    await dispatcher.handle(event({ eventType: 'not.a.real.event', payload: {} }));
    expect(warn).toHaveBeenCalledWith('Unknown event type not.a.real.event');
    expect(notifications.deliver).not.toHaveBeenCalled();
  });
});
