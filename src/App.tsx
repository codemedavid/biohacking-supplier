import { Suspense, lazy, useState } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { useCart } from './hooks/useCart';
import Header from './components/Header';
import SubNav from './components/SubNav';
import Menu from './components/Menu';
import FloatingCartButton from './components/FloatingCartButton';
import Footer from './components/Footer';
import LoadingSpinner from './components/LoadingSpinner';
import PromoBanner from './components/PromoBanner';

// Lazy load view components (not needed on initial render)
const Cart = lazy(() => import('./components/Cart'));
const Checkout = lazy(() => import('./components/Checkout'));
const PromoPopup = lazy(() => import(/* webpackChunkName: "promo-popup" */ './components/PromoPopup'));

// Lazy load route components
const AdminDashboard = lazy(() => import('./components/AdminDashboard'));
const COA = lazy(() => import('./components/COA'));
const FAQ = lazy(() => import('./components/FAQ'));
const PeptideCalculator = lazy(() => import('./components/PeptideCalculator'));
const OrderTracking = lazy(() => import('./components/OrderTracking'));
const ProtocolGuide = lazy(() => import('./components/ProtocolGuide'));

import { useMenu } from './hooks/useMenu';
// import { useCOAPageSetting } from './hooks/useCOAPageSetting';

function MainApp() {
    const cart = useCart();
    const { menuItems } = useMenu();
    const [currentView, setCurrentView] = useState<'menu' | 'cart' | 'checkout'>('menu');
    const [selectedCategory, setSelectedCategory] = useState<string>('all');

    const handleViewChange = (view: 'menu' | 'cart' | 'checkout') => {
        setCurrentView(view);
        // Scroll to top when changing views
        window.scrollTo({ top: 0, behavior: 'smooth' });
    };

    const handleCategoryClick = (categoryId: string) => {
        setSelectedCategory(categoryId);
    };

    // Filter products based on selected category (supports multi-category via junction table)
    const filteredProducts = selectedCategory === 'all'
        ? menuItems
        : menuItems.filter(item =>
            item.categoryIds?.includes(selectedCategory) || item.category === selectedCategory
        );

    return (
        <div className="min-h-screen bg-theme-bg font-sans flex flex-col">
            <Header
                cartItemsCount={cart.getTotalItems()}
                onCartClick={() => handleViewChange('cart')}
                onMenuClick={() => handleViewChange('menu')}
            />
            <PromoBanner />

            {currentView === 'menu' && (
                <SubNav selectedCategory={selectedCategory} onCategoryClick={handleCategoryClick} />
            )}

            <main className="flex-grow">
                <Suspense fallback={null}>
                    <PromoPopup />
                </Suspense>
                {currentView === 'menu' && (
                    <Menu
                        menuItems={filteredProducts}
                        addToCart={cart.addToCart}
                        cartItems={cart.cartItems}
                        updateQuantity={cart.updateQuantity}
                    />
                )}

                {currentView === 'cart' && (
                    <Suspense fallback={<LoadingSpinner />}>
                        <Cart
                            cartItems={cart.cartItems}
                            updateQuantity={cart.updateQuantity}
                            removeFromCart={cart.removeFromCart}
                            clearCart={cart.clearCart}
                            getTotalPrice={cart.getTotalPrice}
                            onContinueShopping={() => handleViewChange('menu')}
                            onCheckout={() => handleViewChange('checkout')}
                        />
                    </Suspense>
                )}

                {currentView === 'checkout' && (
                    <Suspense fallback={<LoadingSpinner />}>
                        <Checkout
                            cartItems={cart.cartItems}
                            totalPrice={cart.getTotalPrice()}
                            onBack={() => handleViewChange('cart')}
                        />
                    </Suspense>
                )}
            </main>

            {currentView === 'menu' && (
                <>
                    <FloatingCartButton
                        itemCount={cart.getTotalItems()}
                        onCartClick={() => handleViewChange('cart')}
                    />
                    <Footer />
                </>
            )}
        </div>
    );
}


function App() {
    //   const { coaPageEnabled } = useCOAPageSetting();

    return (
        <Router>
            <Suspense fallback={<LoadingSpinner />}>
                <Routes>
                    <Route path="/" element={<MainApp />} />
                    <Route path="/coa" element={<COA />} />
                    <Route path="/faq" element={<FAQ />} />
                    <Route path="/calculator" element={<PeptideCalculator />} />
                    <Route path="/track-order" element={<OrderTracking />} />
                    <Route path="/protocols" element={<ProtocolGuide />} />
                    {/* Peptalk routes removed */}
                    <Route path="/admin" element={<AdminDashboard />} />
                </Routes>
            </Suspense>
        </Router>
    );
}

export default App;
