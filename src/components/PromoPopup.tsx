import React, { useState, useEffect } from 'react';
import { X, Mail } from 'lucide-react';
import posthog from '../lib/posthog';
import { identifyWithEmail } from '../lib/posthog';

const PromoPopup: React.FC = () => {
    const [isOpen, setIsOpen] = useState(false);
    const [email, setEmail] = useState('');
    const [submitted, setSubmitted] = useState(false);

    useEffect(() => {
        const hasSeenPopup = localStorage.getItem('hasSeenPromoPopup');
        if (!hasSeenPopup) {
            const timer = setTimeout(() => {
                setIsOpen(true);
            }, 3000);
            return () => clearTimeout(timer);
        }
    }, []);

    const handleClose = () => {
        setIsOpen(false);
        localStorage.setItem('hasSeenPromoPopup', 'true');
    };

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (email.trim() && email.toLowerCase().includes('@gmail.com')) {
            identifyWithEmail(email);
            posthog.capture('BS_popup_subscribed', {
                email,
                source: 'popup',
            });
            setSubmitted(true);
            setTimeout(() => {
                handleClose();
            }, 3000);
        } else {
            alert('Please enter a valid Gmail address.');
        }
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
            <div
                className="absolute inset-0 bg-charcoal-800/20 backdrop-blur-sm"
                onClick={handleClose}
            />

            <div className="relative w-full max-w-sm bg-white rounded-xl shadow-lg border border-charcoal-100 overflow-hidden animate-slideUp">
                <button
                    onClick={handleClose}
                    className="absolute top-3 right-3 p-1.5 text-charcoal-400 hover:text-charcoal-600 rounded-full hover:bg-charcoal-50 transition-all z-10"
                >
                    <X className="w-4 h-4" />
                </button>

                <div className="p-6 text-center">
                    <h2 className="font-heading text-lg font-bold text-charcoal-800 mb-1">
                        Stay in the loop
                    </h2>
                    <p className="text-xs text-charcoal-500 mb-5">
                        Get exclusive deals and updates straight to your inbox.
                    </p>

                    {submitted ? (
                        <div className="bg-glow-teal-50 rounded-lg p-4 border border-glow-teal-200 animate-fadeIn">
                            <p className="text-glow-teal-700 font-semibold text-sm">You're subscribed!</p>
                        </div>
                    ) : (
                        <form onSubmit={handleSubmit} className="space-y-3">
                            <div className="relative">
                                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 text-charcoal-400 w-4 h-4" />
                                <input
                                    type="email"
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    placeholder="you@gmail.com"
                                    className="w-full pl-10 pr-4 py-2.5 text-sm bg-charcoal-50 border border-charcoal-200 rounded-lg focus:ring-2 focus:ring-glow-teal-200 focus:border-glow-teal-300 text-charcoal-700 placeholder-charcoal-400 transition-all outline-none"
                                    required
                                />
                            </div>
                            <button
                                type="submit"
                                className="w-full py-2.5 text-sm bg-glow-teal-500 hover:bg-glow-teal-600 text-white font-semibold rounded-lg transition-colors"
                            >
                                Subscribe
                            </button>
                            <p className="text-[10px] text-charcoal-400">
                                We'll only send you the good stuff. Unsubscribe anytime.
                            </p>
                        </form>
                    )}
                </div>
            </div>
        </div>
    );
};

export default PromoPopup;
