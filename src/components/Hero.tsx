import React, { useEffect, useState } from 'react';
import { ArrowRight, Sparkles, Shield, FlaskConical, Award } from 'lucide-react';

interface HeroProps {
  onShopAll: () => void;
}

const Hero: React.FC<HeroProps> = ({ onShopAll }) => {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    setIsVisible(true);
  }, []);

  return (
    <div className="relative min-h-[90vh] overflow-hidden grain-overlay flex items-center justify-center">

      {/* Modern Gradient Background - Refined */}
      <div className="absolute inset-0 bg-gradient-to-b from-theme-bg via-blush-light to-theme-bg" />

      {/* Abstract Shapes */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden">
        {/* Top Right Blob */}
        <div
          className="absolute -top-[20%] -right-[10%] w-[800px] h-[800px] rounded-full blur-3xl opacity-20 animate-pulse"
          style={{ background: 'radial-gradient(circle, #9333EA 0%, transparent 70%)', animationDuration: '8s' }}
        />
        {/* Bottom Left Blob */}
        <div
          className="absolute -bottom-[10%] -left-[10%] w-[600px] h-[600px] rounded-full blur-3xl opacity-10 animate-pulse"
          style={{ background: 'radial-gradient(circle, #06B6D4 0%, transparent 70%)', animationDuration: '10s' }}
        />
      </div>

      {/* Main Container */}
      <div className="relative z-10 w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 md:py-20 flex flex-col items-center">

        {/* Glass Card Container for Content Consistency */}
        <div className={`
          relative backdrop-blur-xl bg-charcoal-900/40 border border-charcoal-800/50 shadow-[0_0_40px_rgba(147,51,234,0.15)] rounded-[2rem] 
          p-8 md:p-12 lg:p-16 max-w-4xl w-full text-center
          transition-all duration-1000 ease-out transform
          ${isVisible ? 'opacity-100 translate-y-0 scale-100' : 'opacity-0 translate-y-10 scale-95'}
        `}>

          {/* Decorative Sparkle */}
          <div className="absolute -top-6 -right-6 hidden md:block animate-bounce" style={{ animationDuration: '3s' }}>
            <Sparkles className="w-12 h-12 text-blush-400 opacity-80" />
          </div>



          {/* Badge */}
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-charcoal-900/60 border border-glow-teal-500/30 shadow-sm mb-6">
            <FlaskConical className="w-3.5 h-3.5 text-glow-teal-400" />
            <span className="text-xs font-bold text-glow-teal-100 tracking-widest uppercase">Premium Grade • Lab Tested</span>
          </div>

          {/* Main Headline */}
          <h1 className="text-4xl md:text-5xl lg:text-6xl font-heading font-bold text-white mb-6 leading-tight tracking-tight drop-shadow-sm">
            Reject Average. <br className="hidden md:block" />
            <span className="text-blush-500">
              Reveal Your Radiance.
            </span>
          </h1>

          {/* Subheading */}
          <p className="text-lg md:text-xl text-charcoal-200 mb-10 max-w-2xl mx-auto leading-relaxed font-light">
            Elevate your wellness with premium, high-purity peptides designed for results you can see and feel.
          </p>

          {/* Action Buttons */}
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4 w-full">
            <button
              onClick={onShopAll}
              className="btn-primary flex items-center justify-center gap-2 group w-full sm:w-auto min-w-[200px]"
            >
              Start Your Journey
              <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
            </button>


          </div>

        </div>

        {/* Trust Indicators - Floating Below */}
        <div className={`
          mt-12 flex flex-wrap justify-center gap-4 md:gap-8 
          transition-all duration-1000 delay-300 ease-out
          ${isVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-10'}
        `}>
          {[
            { icon: Shield, label: '99% Purity Guaranteed' },
            { icon: FlaskConical, label: 'Third-Party Lab Tested' },
            { icon: Award, label: 'Premium Grade Source' },
          ].map((item, idx) => (
            <div key={idx} className="flex items-center gap-2 px-5 py-2.5 bg-charcoal-900/50 backdrop-blur-sm rounded-full border border-charcoal-700/50 shadow-sm text-sm font-medium text-charcoal-200">
              <item.icon className="w-4 h-4 text-glow-teal-400" />
              {item.label}
            </div>
          ))}
        </div>

      </div>
    </div>
  );
};

export default Hero;
