import React, { useState } from 'react';
import { ChevronDown, ChevronUp, FlaskConical, Package, CreditCard, Truck, ArrowLeft, MessageCircle, HelpCircle } from 'lucide-react';
import { useFAQs } from '../hooks/useFAQs';

const categoryIcons: { [key: string]: React.ReactElement } = {
    'PRODUCT & USAGE': <FlaskConical className="w-5 h-5" />,
    'ORDERING & PACKAGING': <Package className="w-5 h-5" />,
    'PAYMENT METHODS': <CreditCard className="w-5 h-5" />,
    'SHIPPING & DELIVERY': <Truck className="w-5 h-5" />,
};

const categoryColors: { [key: string]: string } = {
    'PRODUCT & USAGE': 'text-charcoal-800 border-charcoal-200 bg-white',
    'ORDERING & PACKAGING': 'text-charcoal-800 border-charcoal-200 bg-white',
    'PAYMENT METHODS': 'text-charcoal-800 border-charcoal-200 bg-white',
    'SHIPPING & DELIVERY': 'text-charcoal-800 border-charcoal-200 bg-white',
};

const FAQ: React.FC = () => {
    const { faqs, categories, loading } = useFAQs();
    const [openItems, setOpenItems] = useState<Set<string>>(new Set());
    const [activeCategory, setActiveCategory] = useState<string | null>(null);

    const toggleItem = (id: string) => {
        setOpenItems(prev => {
            const newSet = new Set(prev);
            if (newSet.has(id)) {
                newSet.delete(id);
            } else {
                newSet.add(id);
            }
            return newSet;
        });
    };

    const filteredFAQs = activeCategory
        ? faqs.filter(faq => faq.category === activeCategory)
        : faqs;

    const viberUrl = 'viber://chat?number=%2B639989747336';
    const whatsappUrl = 'https://wa.me/639989747336';

    if (loading) {
        return (
            <div className="min-h-screen bg-theme-bg flex items-center justify-center">
                <div className="animate-spin w-8 h-8 border-2 border-charcoal-700/50 border-t-transparent rounded-full" />
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-theme-bg">
            {/* Header */}
            <div className="bg-white border-b border-charcoal-200 shadow-sm sticky top-0 z-10">
                <div className="container mx-auto px-4 py-4">
                    <div className="flex items-center gap-4">
                        <a
                            href="/"
                            className="p-2 hover:bg-charcoal-50 rounded-lg transition-colors group"
                        >
                            <ArrowLeft className="w-5 h-5 text-charcoal-600 group-hover:text-charcoal-800" />
                        </a>
                        <div className="flex items-center gap-2">
                            <HelpCircle className="w-6 h-6 text-charcoal-800" />
                            <h1 className="text-xl md:text-2xl font-bold text-charcoal-800">Frequently Asked Questions</h1>
                        </div>
                    </div>
                </div>
            </div>

            <div className="container mx-auto px-4 py-8 max-w-4xl">
                {/* Category Filter */}
                <div className="flex flex-wrap gap-2 mb-8">
                    <button
                        onClick={() => setActiveCategory(null)}
                        className={`px-6 py-2.5 rounded-full text-sm font-bold transition-all border shadow-sm ${activeCategory === null
                            ? 'bg-charcoal-800 text-white border-charcoal-700 shadow-md transform scale-105'
                            : 'bg-white text-charcoal-700 border-charcoal-200 hover:bg-charcoal-50'
                            }`}
                    >
                        All
                    </button>
                    {categories.map(category => (
                        <button
                            key={category}
                            onClick={() => setActiveCategory(category)}
                            className={`px-4 py-2.5 rounded-full text-xs md:text-sm font-bold transition-all flex items-center gap-2 border shadow-sm ${activeCategory === category
                                ? 'bg-charcoal-800 text-white border-charcoal-700 shadow-md transform scale-105'
                                : 'bg-white text-charcoal-700 border-charcoal-200 hover:bg-charcoal-50 hover:text-charcoal-800'
                                }`}
                        >
                            <span className={activeCategory === category ? 'text-white' : 'text-charcoal-700'}>
                                {categoryIcons[category]}
                            </span>
                            {category}
                        </button>
                    ))}
                </div>

                {/* FAQ Items by Category */}
                {(activeCategory ? [activeCategory] : categories).map(category => (
                    <div key={category} className="mb-10">
                        {/* Section Header */}
                        <div className="flex items-center gap-3 mb-6 px-4 py-3 rounded-lg border border-charcoal-200 bg-charcoal-50 shadow-sm w-full">
                            <span className="text-charcoal-700">
                                {categoryIcons[category] || <HelpCircle className="w-5 h-5" />}
                            </span>
                            <h2 className="font-bold text-sm md:text-base uppercase tracking-wide text-charcoal-800">{category}</h2>
                        </div>

                        <div className="space-y-4">
                            {filteredFAQs
                                .filter(faq => faq.category === category)
                                .map(faq => (
                                    <div
                                        key={faq.id}
                                        className="bg-white rounded-xl border border-charcoal-200 shadow-sm hover:shadow-md transition-all duration-200"
                                    >
                                        <button
                                            onClick={() => toggleItem(faq.id)}
                                            className="w-full px-6 py-5 flex items-start justify-between text-left group gap-4"
                                        >
                                            <span className="font-bold text-charcoal-800 text-base md:text-lg group-hover:text-charcoal-900 transition-colors leading-snug">
                                                {faq.question}
                                            </span>
                                            {openItems.has(faq.id) ? (
                                                <ChevronUp className="w-5 h-5 text-charcoal-500 flex-shrink-0 mt-1" />
                                            ) : (
                                                <ChevronDown className="w-5 h-5 text-charcoal-500 group-hover:text-charcoal-700 flex-shrink-0 transition-colors mt-1" />
                                            )}
                                        </button>
                                        {openItems.has(faq.id) && (
                                            <div className="px-6 pb-6 pt-0">
                                                <div className="h-px w-full bg-charcoal-200 mb-4"></div>
                                                <p className="text-charcoal-700 whitespace-pre-line leading-relaxed text-base">
                                                    {faq.answer}
                                                </p>
                                            </div>
                                        )}
                                    </div>
                                ))}
                        </div>
                    </div>
                ))}

                {/* Contact CTA */}
                <div className="mt-12 bg-white rounded-2xl border border-charcoal-200 p-6 md:p-8 text-center shadow-lg">
                    <h3 className="text-lg md:text-xl font-bold text-charcoal-800 mb-2">
                        Still have questions?
                    </h3>
                    <p className="text-charcoal-600 mb-6">
                        We're here to help! Reach out to us via Viber or WhatsApp for quick assistance.
                    </p>
                    <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
                        <a
                            href={viberUrl}
                            className="w-full sm:w-auto inline-flex items-center justify-center gap-2 bg-[#7360f2] text-white px-6 py-3 rounded-lg font-medium hover:opacity-90 transition-all shadow-md hover:shadow-lg"
                        >
                            <MessageCircle className="w-5 h-5" />
                            Message us on Viber
                        </a>
                        <a
                            href={whatsappUrl}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="w-full sm:w-auto inline-flex items-center justify-center gap-2 bg-[#25D366] text-white px-6 py-3 rounded-lg font-medium hover:opacity-90 transition-all shadow-md hover:shadow-lg"
                        >
                            <MessageCircle className="w-5 h-5" />
                            Message us on WhatsApp
                        </a>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default FAQ;
