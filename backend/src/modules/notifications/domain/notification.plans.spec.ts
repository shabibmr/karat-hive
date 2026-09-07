import { describe, expect, it } from 'vitest';
import {
  intentsFor,
  isNotificationConsumerEvent,
  NOTIFICATION_CONSUMER_EVENTS,
  NOTIFICATION_DISPATCH_EVENTS,
} from './notification.plans';

describe('notification plans (G2-N02)', () => {
  it('consumes the 21 Async-Contract events', () => {
    expect(NOTIFICATION_CONSUMER_EVENTS).toHaveLength(21);
    expect(NOTIFICATION_DISPATCH_EVENTS).toHaveLength(17);
    for (const eventType of NOTIFICATION_CONSUMER_EVENTS) {
      expect(isNotificationConsumerEvent(eventType)).toBe(true);
    }
  });

  it('routes request.matched to the Vendor', () => {
    const intents = intentsFor('request.matched', {
      requestId: 'req-1',
      vendorUserId: 'ven-user',
    });
    expect(intents).toHaveLength(1);
    expect(intents[0]).toMatchObject({
      copyKey: 'request.matched',
      recipient: { type: 'user', userId: 'ven-user' },
      deepLink: '/requests/req-1',
      channels: ['IN_APP', 'PUSH'],
      isCritical: false,
    });
  });

  it('routes offer.submitted first vs subsequent to the Customer', () => {
    const first = intentsFor('offer.submitted', {
      requestId: 'req-1',
      customerUserId: 'cus-1',
      isFirstOfferOnRequest: true,
    });
    expect(first[0]?.copyKey).toBe('offer.submitted.first');
    expect(first[0]?.deepLink).toBe('/requests/req-1/offers');

    const later = intentsFor('offer.submitted', {
      requestId: 'req-1',
      customerUserId: 'cus-1',
      isFirstOfferOnRequest: false,
    });
    expect(later[0]?.copyKey).toBe('offer.submitted.subsequent');
  });

  it('routes offer.accepted to winner, losers, and Customer without joining the accepted Offer', () => {
    const intents = intentsFor('offer.accepted', {
      requestId: 'req-1',
      acceptedOfferId: 'offer-win',
      connectionId: 'conn-1',
      customerUserId: 'cus-1',
      winnerVendorUserId: 'ven-win',
      rejectedOfferIds: ['offer-l1', 'offer-l2'],
    });

    expect(intents.map((i) => i.copyKey)).toEqual([
      'offer.accepted.winner',
      'offer.accepted.loser',
      'offer.accepted.customer',
    ]);

    const loser = intents.find((i) => i.copyKey === 'offer.accepted.loser');
    expect(loser?.recipient).toEqual({
      type: 'offerVendors',
      offerIds: ['offer-l1', 'offer-l2'],
    });
    expect(loser?.deepLink).toBe('/requests/req-1');
    expect(JSON.stringify(loser)).not.toMatch(/offer-win/);
    expect(JSON.stringify(intents)).not.toMatch(/price/i);
  });

  it('routes request.edited to pending-Offer Vendors when ids are omitted', () => {
    const intents = intentsFor('request.edited', { requestId: 'req-1' });
    expect(intents[0]?.recipient).toEqual({
      type: 'pendingOfferVendors',
      requestId: 'req-1',
    });
  });

  it('keeps draft purge in-app only', () => {
    const intents = intentsFor('request.draft.purge_warning', {
      requestId: 'req-1',
      customerUserId: 'cus-1',
    });
    expect(intents[0]?.channels).toEqual(['IN_APP']);
  });

  it('returns no intents for skip events and unknown types', () => {
    expect(intentsFor('request.published', { requestId: 'req-1' })).toEqual([]);
    expect(intentsFor('media.uploaded', {})).toEqual([]);
    expect(intentsFor('not.a.real.event', {})).toEqual([]);
  });

  it('unwraps an OutboxEnvelope data object', () => {
    const intents = intentsFor('offer.withdrawn', {
      eventId: 'evt-1',
      eventType: 'offer.withdrawn',
      data: { requestId: 'req-1', customerUserId: 'cus-1' },
    });
    expect(intents[0]?.recipient).toEqual({ type: 'user', userId: 'cus-1' });
  });
});
