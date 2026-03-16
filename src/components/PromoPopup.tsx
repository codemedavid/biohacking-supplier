import React, { useState, useEffect } from 'react';
import { X, Mail, Sparkles } from 'lucide-react';
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
                email: email,
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

            <div className="relative w-full max-w-md bg-white rounded-2xl shadow-luxury border border-charcoal-100 overflow-hidden animate-slideUp">
                <button
                    onClick={handleClose}
                    className="absolute top-4 right-4 p-2 text-charcoal-400 hover:text-charcoal-600 hover:bg-charcoal-50 rounded-full transition-all z-10"
                >
                    <X className="w-5 h-5" />
                </button>

                <div className="p-8 text-center relative">
                    <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-blush-300 via-glow-teal-300 to-blush-300"></div>

                    <div className="w-16 h-16 bg-glow-teal-50 rounded-full flex items-center justify-center mx-auto mb-6 border border-glow-teal-100 shadow-sm">
                        <Sparkles className="w-8 h-8 text-glow-teal-400" />
                    </div>

                    <h2 className="font-heading text-2xl font-bold text-charcoal-800 mb-2">
                        Unlock Exclusive Promos!
                    </h2>
                    <p className="text-sm text-charcoal-500 mb-8">
                        Enter your Gmail address to receive notifications about our latest peptide releases and exclusive discounts.
                    </p>

                    {submitted ? (
                        <div className="bg-glow-teal-50 rounded-xl p-6 border border-glow-teal-200 animate-fadeIn">
                            <p className="text-glow-teal-700 font-bold mb-1">You're on the list!</p>
                            <p className="text-xs text-charcoal-500">Keep an eye on your inbox for upcoming promos.</p>
                        </div>
                    ) : (
                        <form onSubmit={handleSubmit} className="space-y-4">
                            <div className="relative">
                                <Mail className="absolute left-4 top-1/2 transform -translate-y-1/2 text-charcoal-400 w-5 h-5" />
                                <input
                                    type="email"
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    placeholder="your.name@gmail.com"
                                    className="w-full pl-12 pr-4 py-3 bg-charcoal-50 border border-charcoal-200 rounded-xl focus:ring-2 focus:ring-glow-teal-200 focus:border-glow-teal-300 text-charcoal-700 placeholder-charcoal-400 transition-all outline-none"
                                    required
                                />
                            </div>
                            <button
                                type="submit"
                                className="w-full py-3 bg-gradient-to-r from-glow-teal-400 to-glow-teal-500 hover:from-glow-teal-500 hover:to-glow-teal-600 text-white font-bold rounded-xl shadow-soft transition-all transform hover:-translate-y-0.5"
                            >
                                Subscribe for Promos
                            </button>
                            <p className="text-[10px] text-charcoal-400 mt-4">
                                By subscribing, you agree to receive marketing emails. You can unsubscribe at any time.
                            </p>
                        </form>
                    )}
                </div>
            </div>
        </div>
    );
};

export default PromoPopup;
