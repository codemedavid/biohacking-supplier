import React, { useState } from 'react';
import { X, Check } from 'lucide-react';
import posthog from '../lib/posthog';
import { identifyWithEmail } from '../lib/posthog';

const PromoBanner: React.FC = () => {
    const [email, setEmail] = useState('');
    const [submitted, setSubmitted] = useState(false);
    const [dismissed, setDismissed] = useState(false);

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (email.trim() && email.toLowerCase().includes('@gmail.com')) {
            identifyWithEmail(email);
            posthog.capture('BS_banner_subscribed', { email, source: 'banner' });
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
        <div className="w-full bg-charcoal-50 border-b border-charcoal-100">
            <div className="container mx-auto px-4 py-2 flex flex-col sm:flex-row items-center justify-center gap-2 sm:gap-3 relative">
                <button
                    onClick={handleDismiss}
                    className="absolute right-3 top-1/2 -translate-y-1/2 p-1 text-charcoal-400 hover:text-charcoal-600 rounded-full hover:bg-charcoal-100 transition-colors"
                >
                    <X className="w-4 h-4" />
                </button>

                {submitted ? (
                    <div className="flex items-center gap-2 text-glow-teal-700 font-medium text-sm animate-fadeIn pr-6">
                        <Check className="w-4 h-4" />
                        <span>You're subscribed!</span>
                    </div>
                ) : (
                    <>
                        <span className="text-sm font-medium text-charcoal-600 pr-6 sm:pr-0">Get exclusive deals</span>
                        <form onSubmit={handleSubmit} className="flex items-center gap-2 w-full sm:w-auto pr-6 sm:pr-0">
                            <input
                                type="email"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                placeholder="you@gmail.com"
                                className="px-3 py-1.5 text-sm bg-white border border-charcoal-200 rounded-lg text-charcoal-700 placeholder-charcoal-400 focus:ring-1 focus:ring-glow-teal-300 focus:border-glow-teal-300 outline-none transition-all flex-1 sm:w-52"
                                required
                            />
                            <button
                                type="submit"
                                className="px-3 py-1.5 text-sm font-semibold bg-glow-teal-500 hover:bg-glow-teal-600 text-white rounded-lg transition-colors whitespace-nowrap"
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
