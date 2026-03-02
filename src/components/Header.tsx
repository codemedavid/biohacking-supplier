import React, { useState } from 'react';
import { ShoppingCart, Menu, X, FlaskConical, HelpCircle, Truck, Calculator } from 'lucide-react';

interface HeaderProps {
  cartItemsCount: number;
  onCartClick: () => void;
  onMenuClick: () => void;
}

const Header: React.FC<HeaderProps> = ({ cartItemsCount, onCartClick, onMenuClick }) => {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const currentPath = typeof window !== 'undefined' ? window.location.pathname : '/';

  return (
    <>
      <header className="bg-charcoal-900/95 backdrop-blur-sm sticky top-0 z-50 border-b border-charcoal-700/50">
        <div className="container mx-auto px-4 md:px-6 py-3">
          <div className="flex items-center justify-between gap-4">
            {/* Logo - Rectangular */}
            <button
              onClick={() => { onMenuClick(); setMobileMenuOpen(false); }}
              className="flex items-center hover:opacity-90 transition-opacity"
            >

              <span className="ml-3 text-lg sm:text-xl font-heading font-bold text-blush-600 tracking-tight">
                Nexus Peptides
              </span>
            </button>

            {/* Right Side Navigation */}
            <div className="flex items-center gap-2 md:gap-6 ml-auto">
              {/* Desktop Navigation */}
              <nav className="hidden md:flex items-center gap-1 lg:gap-2">
                <button
                  onClick={onMenuClick}
                  className={`text-sm font-medium ${currentPath === '/' ? 'text-white bg-charcoal-800/40' : 'text-charcoal-400'} hover:text-blush-600 px-4 py-2 rounded-lg transition-colors flex items-center gap-2`}
                >
                  <FlaskConical className="w-4 h-4" />
                  Products
                </button>
                <a
                  href="/calculator"
                  className={`text-sm font-medium ${currentPath === '/calculator' ? 'text-white bg-charcoal-800/40' : 'text-charcoal-400'} hover:text-blush-600 px-4 py-2 rounded-lg transition-colors flex items-center gap-2`}
                >
                  <Calculator className="w-4 h-4" />
                  Calculator
                </a>
                <a
                  href="/protocols"
                  className={`text-sm font-medium ${currentPath === '/protocols' ? 'text-white bg-charcoal-800/40' : 'text-charcoal-400'} hover:text-blush-600 px-4 py-2 rounded-lg transition-colors flex items-center gap-2`}
                >
                  <FlaskConical className="w-4 h-4" />
                  Protocols
                </a>
                <a
                  href="/track-order"
                  className={`text-sm font-medium ${currentPath === '/track-order' ? 'text-white bg-charcoal-800/40' : 'text-charcoal-400'} hover:text-blush-600 px-4 py-2 rounded-lg transition-colors flex items-center gap-2`}
                >
                  <Truck className="w-4 h-4" />
                  Track
                </a>
                <a
                  href="/faq"
                  className={`text-sm font-medium ${currentPath === '/faq' ? 'text-white bg-charcoal-800/40' : 'text-charcoal-400'} hover:text-blush-600 px-4 py-2 rounded-lg transition-colors flex items-center gap-2`}
                >
                  <HelpCircle className="w-4 h-4" />
                  FAQ
                </a>
              </nav>

              {/* Cart Button */}
              <button
                onClick={onCartClick}
                className="relative p-2.5 text-charcoal-200 hover:bg-charcoal-800/60 rounded-xl transition-colors"
              >
                <ShoppingCart className="w-5 h-5" />
                {cartItemsCount > 0 && (
                  <span className="absolute -top-1 -right-1 bg-blush-600 text-white text-[10px] font-bold rounded-full min-w-[18px] h-[18px] flex items-center justify-center px-1">
                    {cartItemsCount > 99 ? '99+' : cartItemsCount}
                  </span>
                )}
              </button>

              {/* Mobile Menu Button */}
              <button
                onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
                className="md:hidden p-2.5 text-charcoal-200 hover:bg-charcoal-800/60 rounded-xl transition-colors"
                aria-label="Toggle menu"
              >
                {mobileMenuOpen ? (
                  <X className="w-6 h-6" />
                ) : (
                  <Menu className="w-6 h-6" />
                )}
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Mobile Navigation Menu */}
      {mobileMenuOpen && (
        <div className="md:hidden fixed inset-0 z-[60]">
          {/* Backdrop */}
          <div
            className="absolute inset-0 bg-charcoal-900/30 backdrop-blur-sm"
            onClick={() => setMobileMenuOpen(false)}
          />

          {/* Sidebar Drawer */}
          <div
            className="absolute top-0 right-0 bottom-0 w-[300px] bg-charcoal-900/40 backdrop-blur-md shadow-2xl border-l border-charcoal-700/50 flex flex-col"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Drawer Header */}
            <div className="flex items-center justify-between p-5 border-b border-charcoal-700/50">
              <div className="flex items-center gap-3">

                <span className="text-lg font-heading font-bold text-blush-600">
                  Nexus Peptides
                </span>
              </div>
              <button
                onClick={() => setMobileMenuOpen(false)}
                className="p-2 text-charcoal-500 hover:text-rose-500 transition-colors rounded-lg hover:bg-charcoal-800/60"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Navigation Items */}
            <nav className="flex-1 overflow-y-auto p-4">
              <div className="flex flex-col space-y-1">
                <button
                  onClick={() => {
                    onMenuClick();
                    setMobileMenuOpen(false);
                  }}
                  className={`flex items-center gap-3 p-4 rounded-xl text-left font-medium hover:bg-charcoal-800/60 transition-colors ${currentPath === '/' ? 'text-white bg-charcoal-800/40' : 'text-charcoal-400'}`}
                >
                  <div className="p-2 rounded-lg bg-charcoal-800/60 text-blush-600">
                    <FlaskConical className="w-[18px] h-[18px]" />
                  </div>
                  Products
                </button>

                <a
                  href="/calculator"
                  className={`flex items-center gap-3 p-4 rounded-xl text-left font-medium hover:bg-charcoal-800/60 transition-colors ${currentPath === '/calculator' ? 'text-white bg-charcoal-800/40' : 'text-charcoal-400'}`}
                >
                  <div className="p-2 rounded-lg bg-charcoal-800/60 text-blush-600">
                    <Calculator className="w-[18px] h-[18px]" />
                  </div>
                  Calculator
                </a>

                <a
                  href="/protocols"
                  className={`flex items-center gap-3 p-4 rounded-xl text-left font-medium hover:bg-charcoal-800/60 transition-colors ${currentPath === '/protocols' ? 'text-white bg-charcoal-800/40' : 'text-charcoal-400'}`}
                >
                  <div className="p-2 rounded-lg bg-charcoal-800/60 text-blush-600">
                    <FlaskConical className="w-[18px] h-[18px]" />
                  </div>
                  Protocols
                </a>

                <a
                  href="/track-order"
                  className={`flex items-center gap-3 p-4 rounded-xl text-left font-medium hover:bg-charcoal-800/60 transition-colors ${currentPath === '/track-order' ? 'text-white bg-charcoal-800/40' : 'text-charcoal-400'}`}
                >
                  <div className="p-2 rounded-lg bg-charcoal-800/60 text-blush-600">
                    <Truck className="w-[18px] h-[18px]" />
                  </div>
                  Track Order
                </a>

                <a
                  href="/faq"
                  className={`flex items-center gap-3 p-4 rounded-xl text-left font-medium hover:bg-charcoal-800/60 transition-colors ${currentPath === '/faq' ? 'text-white bg-charcoal-800/40' : 'text-charcoal-400'}`}
                >
                  <div className="p-2 rounded-lg bg-charcoal-800/60 text-blush-600">
                    <HelpCircle className="w-[18px] h-[18px]" />
                  </div>
                  FAQ
                </a>
              </div>
            </nav>
          </div>
        </div>
      )}
    </>
  );
};

export default Header;
