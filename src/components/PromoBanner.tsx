import React, { useState } from 'react';
import { Mail, X, Check, Sparkles } from 'lucide-react';
import posthog from '../lib/posthog';

const PromoBanner: React.FC = () => {
    const [email, setEmail] = useState('');
    const [submitted, setSubmitted] = useState(false);
    const [dismissed, setDismissed] = useState(false);

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (email.trim() && email.toLowerCase().includes('@gmail.com')) {
            posthog.identify(email, { email });
            posthog.capture('promo_subscribed', { email, source: 'banner' });
            posthog.people.set({ email, subscribed_to_promos: true });
            setSubmitted(true);
            setTimeout(() => {
                setDismissed(true);
            }, 3000);
        } else {
            alert('Please enter a valid @gmail.com address.');
        }
    };

    const handleDismiss = () => {
        setDismissed(true);
    };

    if (dismissed) return null;

    return (
        <div className="w-full bg-gradient-to-r from-blush-800/60 via-charcoal-900/80 to-glow-teal-900/60 border-b border-charcoal-700/50 backdrop-blur-md">
            <div className="container mx-auto px-4 py-2.5 flex flex-col sm:flex-row items-center justify-center gap-2 sm:gap-4 relative">
                {/* Close button */}
                <button
                    onClick={handleDismiss}
                    className="absolute right-3 top-1/2 -translate-y-1/2 p-1 text-charcoal-400 hover:text-white rounded-full hover:bg-charcoal-800/50 transition-colors"
                >
                    <X className="w-4 h-4" />
                </button>

                {submitted ? (
                    <div className="flex items-center gap-2 text-glow-teal-400 font-medium text-sm animate-fadeIn pr-6">
                        <Check className="w-4 h-4" />
                        <span>You're subscribed! Watch your inbox for exclusive deals.</span>
                    </div>
                ) : (
                    <>
                        <div className="flex items-center gap-2 text-sm text-charcoal-200 pr-6 sm:pr-0">
                            <Sparkles className="w-4 h-4 text-rose-400 flex-shrink-0" />
                            <span className="font-medium">Get notified about exclusive discounts & promos!</span>
                        </div>
                        <form onSubmit={handleSubmit} className="flex items-center gap-2 w-full sm:w-auto pr-6 sm:pr-0">
                            <div className="relative flex-1 sm:flex-none">
                                <Mail className="absolute left-2.5 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-charcoal-500" />
                                <input
                                    type="email"
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    placeholder="you@gmail.com"
                                    className="pl-8 pr-3 py-1.5 text-sm bg-charcoal-900/60 border border-charcoal-700/50 rounded-lg text-white placeholder-charcoal-500 focus:ring-1 focus:ring-glow-teal-500 focus:border-glow-teal-500 outline-none transition-all w-full sm:w-52"
                                    required
                                />
                            </div>
                            <button
                                type="submit"
                                className="px-4 py-1.5 text-sm font-bold bg-gradient-to-r from-glow-teal-600 to-blush-600 hover:from-glow-teal-500 hover:to-blush-500 text-white rounded-lg transition-all whitespace-nowrap shadow-sm"
                            >
                                Subscribe
                            </button>
                        </form>
                    </>
                )}
            </div>
        </div>
    );
};

export default PromoBanner;
