import posthog from 'posthog-js';

const POSTHOG_KEY = import.meta.env.VITE_POSTHOG_KEY as string;
const POSTHOG_HOST = import.meta.env.VITE_POSTHOG_HOST as string || 'https://us.i.posthog.com';

export function initPostHog() {
    if (POSTHOG_KEY) {
        posthog.init(POSTHOG_KEY, {
            api_host: POSTHOG_HOST,
            person_profiles: 'identified_only',
            capture_pageview: true,
            capture_pageleave: true,
        });
    }
}

/**
 * Identify a user and set their email for PostHog messaging workflows.
 * Sets both `email` and `$email` (PostHog's reserved property for the default email channel).
 */
export function identifyWithEmail(email: string, properties?: Record<string, unknown>) {
    posthog.identify(email, {
        email,
        $email: email,
        ...properties,
    });
    posthog.people.set({
        email,
        $email: email,
        subscribed_to_promos: true,
        ...properties,
    });
}

export default posthog;
