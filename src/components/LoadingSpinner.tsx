import React from 'react';

const LoadingSpinner: React.FC = () => {
    return (
        <div className="flex items-center justify-center min-h-[50vh]">
            <div className="relative">
                <div className="w-12 h-12 rounded-full border-4 border-charcoal-100"></div>
                <div className="w-12 h-12 rounded-full border-4 border-glow-teal-400 border-t-transparent animate-spin absolute top-0 left-0"></div>
            </div>
        </div>
    );
};

export default LoadingSpinner;
