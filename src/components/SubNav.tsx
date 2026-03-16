import React from 'react';
import { useCategories } from '../hooks/useCategories';

interface SubNavProps {
    selectedCategory: string;
    onCategoryClick: (categoryId: string) => void;
}

const SubNav: React.FC<SubNavProps> = ({ selectedCategory, onCategoryClick }) => {
    const { categories, loading } = useCategories();

    if (loading) {
        return (
            <div className="bg-white/90 backdrop-blur-md border-b border-charcoal-100 hidden md:block">
                <div className="container mx-auto px-4 py-4">
                    <div className="flex space-x-3 overflow-x-auto">
                        {[1, 2, 3, 4, 5].map((i) => (
                            <div key={i} className="animate-pulse bg-charcoal-100 h-10 w-32 rounded-xl" />
                        ))}
                    </div>
                </div>
            </div>
        );
    }

    return (
        <nav className="bg-white/90 backdrop-blur-md sticky top-[64px] md:top-[80px] lg:top-[88px] z-40 border-b border-charcoal-100 shadow-sm">
            <div className="container mx-auto px-4">
                <div className="flex items-center space-x-2 py-4 overflow-x-auto scrollbar-hide">
                    {categories.map((category) => {
                        const isSelected = selectedCategory === category.id;

                        return (
                            <button
                                key={category.id}
                                onClick={() => onCategoryClick(category.id)}
                                className={`
                  flex items-center space-x-2 px-5 py-2.5 rounded-xl font-bold whitespace-nowrap
                  transition-all duration-300 text-sm uppercase tracking-wider
                  ${isSelected
                                        ? 'bg-glow-teal-500 text-white shadow-soft'
                                        : 'bg-charcoal-50 text-charcoal-500 hover:text-glow-teal-600 hover:bg-glow-teal-50 border border-charcoal-100'
                                    }
                `}
                            >
                                <span>{category.name}</span>
                            </button>
                        );
                    })}
                </div>
            </div>

            <style>{`
        .scrollbar-hide::-webkit-scrollbar {
          display: none;
        }
        .scrollbar-hide {
          -ms-overflow-style: none;
          scrollbar-width: none;
        }
      `}</style>
        </nav>
    );
};

export default SubNav;
