import { describe, it, expect, vi, beforeEach } from 'vitest';

// Mock posthog-js before importing our module
const mockInit = vi.fn();
const mockIdentify = vi.fn();
const mockPeopleSet = vi.fn();

vi.mock('posthog-js', () => ({
  default: {
    init: mockInit,
    identify: mockIdentify,
    people: { set: mockPeopleSet },
  },
}));

describe('posthog integration', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.resetModules();
  });

  describe('initPostHog', () => {
    it('initializes PostHog with correct config when key is present', async () => {
      Object.defineProperty(import.meta, 'env', {
        value: {
          ...import.meta.env,
          VITE_POSTHOG_KEY: 'phc_test123',
          VITE_POSTHOG_HOST: 'https://posthog.example.com',
        },
        configurable: true,
      });

      const { initPostHog } = await import('../posthog');
      initPostHog();

      expect(mockInit).toHaveBeenCalledWith(
        expect.any(String),
        expect.objectContaining({
          person_profiles: 'identified_only',
          capture_pageview: true,
          capture_pageleave: true,
        })
      );
    });
  });

  describe('identifyWithEmail', () => {
    it('calls posthog.identify with email properties', async () => {
      const { identifyWithEmail } = await import('../posthog');
      identifyWithEmail('user@example.com');

      expect(mockIdentify).toHaveBeenCalledWith('user@example.com', {
        email: 'user@example.com',
        $email: 'user@example.com',
      });
    });

    it('sets people properties with subscribed flag', async () => {
      const { identifyWithEmail } = await import('../posthog');
      identifyWithEmail('user@example.com');

      expect(mockPeopleSet).toHaveBeenCalledWith({
        email: 'user@example.com',
        $email: 'user@example.com',
        subscribed_to_promos: true,
      });
    });

    it('merges additional properties', async () => {
      const { identifyWithEmail } = await import('../posthog');
      identifyWithEmail('user@example.com', { plan: 'premium' });

      expect(mockIdentify).toHaveBeenCalledWith('user@example.com', {
        email: 'user@example.com',
        $email: 'user@example.com',
        plan: 'premium',
      });

      expect(mockPeopleSet).toHaveBeenCalledWith({
        email: 'user@example.com',
        $email: 'user@example.com',
        subscribed_to_promos: true,
        plan: 'premium',
      });
    });
  });
});
