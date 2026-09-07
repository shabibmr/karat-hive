import { describe, expect, it } from 'vitest';
import {
  canTransitionRequest,
  isLiveRequestState,
  isTerminalRequestState,
  resolveRequestDirection,
} from './request-state-machine';

describe('request-state-machine', () => {
  it('allows valid transitions from DRAFT', () => {
    expect(canTransitionRequest('DRAFT', 'PUBLISHED')).toBe(true);
    expect(canTransitionRequest('DRAFT', 'CANCELLED')).toBe(true);
    expect(canTransitionRequest('DRAFT', 'REMOVED')).toBe(true);
    expect(canTransitionRequest('DRAFT', 'ACCEPTED')).toBe(false);
    expect(canTransitionRequest('DRAFT', 'EXPIRED')).toBe(false);
  });

  it('allows valid transitions from PUBLISHED', () => {
    expect(canTransitionRequest('PUBLISHED', 'OFFERS_RECEIVED')).toBe(true);
    expect(canTransitionRequest('PUBLISHED', 'CANCELLED')).toBe(true);
    expect(canTransitionRequest('PUBLISHED', 'EXPIRED')).toBe(true);
    expect(canTransitionRequest('PUBLISHED', 'DRAFT')).toBe(false);
  });

  it('allows valid transitions from OFFERS_RECEIVED', () => {
    expect(canTransitionRequest('OFFERS_RECEIVED', 'ACCEPTED')).toBe(true);
    expect(canTransitionRequest('OFFERS_RECEIVED', 'CANCELLED')).toBe(true);
    expect(canTransitionRequest('OFFERS_RECEIVED', 'EXPIRED')).toBe(true);
    expect(canTransitionRequest('OFFERS_RECEIVED', 'PUBLISHED')).toBe(false);
  });

  it('identifies terminal states correctly', () => {
    expect(isTerminalRequestState('CLOSED')).toBe(true);
    expect(isTerminalRequestState('EXPIRED')).toBe(true);
    expect(isTerminalRequestState('CANCELLED')).toBe(true);
    expect(isTerminalRequestState('REMOVED')).toBe(true);
    expect(isTerminalRequestState('DRAFT')).toBe(false);
    expect(isTerminalRequestState('PUBLISHED')).toBe(false);
    expect(isTerminalRequestState('ACCEPTED')).toBe(false);
  });

  it('identifies live states correctly', () => {
    expect(isLiveRequestState('PUBLISHED')).toBe(true);
    expect(isLiveRequestState('OFFERS_RECEIVED')).toBe(true);
    expect(isLiveRequestState('DRAFT')).toBe(false);
    expect(isLiveRequestState('ACCEPTED')).toBe(false);
    expect(isLiveRequestState('CLOSED')).toBe(false);
  });

  it('resolves request direction by type', () => {
    expect(resolveRequestDirection('FIND_ORNAMENT')).toBe('BUY');
    expect(resolveRequestDirection('FIND_ORNAMENT', 'SELL')).toBe('BUY');
    expect(resolveRequestDirection('SELL_OLD_GOLD')).toBe('SELL');
    expect(resolveRequestDirection('SELL_OLD_GOLD', 'BUY')).toBe('SELL');
    expect(resolveRequestDirection('GOLD_COIN', 'BUY')).toBe('BUY');
    expect(resolveRequestDirection('GOLD_COIN', 'SELL')).toBe('SELL');
    expect(resolveRequestDirection('GOLD_BULLION', 'BUY')).toBe('BUY');
    expect(resolveRequestDirection('GOLD_BULLION', 'SELL')).toBe('SELL');
  });
});
