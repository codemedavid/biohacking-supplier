import React from 'react';
import { Trash2, ShoppingBag, ArrowLeft, CreditCard, Plus, Minus, Sparkles, Activity, Globe, MapPin, Box, TestTube, Package } from 'lucide-react';
import type { CartItem } from '../types';
import { formatCurrency } from '../utils/currency';
import { getPurchaseModeLabel, getFulfillmentTypeLabel } from '../utils/pricing';

interface CartProps {
  cartItems: CartItem[];
  updateQuantity: (index: number, quantity: number) => void;
  removeFromCart: (index: number) => void;
  clearCart: () => void;
  getTotalPrice: () => number;
  getTotalUSD?: () => number;
  onContinueShopping: () => void;
  onCheckout: () => void;
}

const Cart: React.FC<CartProps> = ({
  cartItems,
  updateQuantity,
  removeFromCart,
  clearCart,
  getTotalPrice,
  getTotalUSD,
  onContinueShopping,
  onCheckout,
}) => {
  if (cartItems.length === 0) {
    return (
      <div className="min-h-screen bg-theme-bg flex items-center justify-center px-4 py-12">
        <div className="text-center max-w-md">
          <div className="bg-white rounded-3xl p-12 border border-charcoal-100 shadow-md">
            <div className="bg-glow-teal-50 w-24 h-24 rounded-full flex items-center justify-center mx-auto mb-6">
              <ShoppingBag className="w-10 h-10 text-glow-teal-400" />
            </div>
            <h2 className="font-heading text-2xl font-bold text-charcoal-800 mb-3 flex items-center justify-center gap-2">
              Your cart is empty
            </h2>
            <p className="text-charcoal-500 mb-8 max-w-xs mx-auto">
              Select products from our catalog to proceed with your research order.
            </p>
            <button
              onClick={onContinueShopping}
              className="btn-primary w-full flex items-center justify-center gap-2"
            >
              <ArrowLeft className="w-4 h-4" />
              Browse Catalog
            </button>
          </div>
        </div>
      </div>
    );
  }

  const totalPHP = getTotalPrice();
  const totalUSD = getTotalUSD ? getTotalUSD() : 0;
  const hasUSDItems = totalUSD > 0;

  return (
    <div className="min-h-screen bg-theme-bg py-6 md:py-8">
      <div className="container mx-auto px-4 max-w-6xl">
        {/* Header */}
        <div className="mb-8">
          <button
            onClick={onContinueShopping}
            className="text-charcoal-500 hover:text-glow-teal-500 font-medium mb-6 flex items-center gap-2 transition-colors group text-sm"
          >
            <ArrowLeft className="w-4 h-4 group-hover:-translate-x-1 transition-transform" />
            <span>Back to Catalog</span>
          </button>
          <div className="flex justify-between items-end pb-4 border-b border-charcoal-100">
            <div>
              <h1 className="font-heading text-2xl md:text-3xl font-bold text-charcoal-800 flex items-center gap-3">
                Shopping Cart
                <span className="text-sm font-normal text-charcoal-500 bg-charcoal-50 px-3 py-1 rounded-full border border-charcoal-100">
                  {cartItems.reduce((sum, item) => sum + item.quantity, 0)} Items
                </span>
              </h1>
            </div>
            <button
              onClick={clearCart}
              className="text-red-400 hover:text-red-500 text-sm font-medium flex items-center gap-2 hover:bg-red-50 px-3 py-2 rounded-xl transition-colors"
            >
              <Trash2 className="w-4 h-4" />
              Clear Cart
            </button>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Cart Items */}
          <div className="lg:col-span-2 space-y-4">
            {cartItems.map((item, index) => (
              <div
                key={index}
                className="bg-white rounded-2xl p-4 md:p-6 border border-charcoal-100 shadow-sm transition-all hover:shadow-md hover:border-glow-teal-200"
              >
                <div className="flex gap-6">
                  {/* Product Image */}
                  <div className="w-20 h-20 md:w-24 md:h-24 bg-charcoal-50 rounded-xl flex-shrink-0 border border-charcoal-100 overflow-hidden">
                    {item.product.image_url ? (
                      <img
                        src={item.product.image_url}
                        alt={item.product.name}
                        className="w-full h-full object-cover"
                      />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center text-charcoal-400 font-bold text-2xl bg-charcoal-50">
                        {item.product.name.charAt(0)}
                      </div>
                    )}
                  </div>

                  {/* Product Details */}
                  <div className="flex-1 min-w-0">
                    <div className="flex justify-between items-start mb-3">
                      <div>
                        <h3 className="font-heading font-bold text-charcoal-800 text-base md:text-lg mb-1">
                          {item.product.name}
                        </h3>
                        <div className="flex flex-wrap gap-2 text-xs">
                          {item.product.code && (
                            <span className="text-charcoal-400 font-mono bg-charcoal-50 px-2 py-0.5 rounded-lg border border-charcoal-100">
                              {item.product.code}
                            </span>
                          )}
                          {item.variation && (
                            <span className="text-charcoal-500 font-medium bg-charcoal-50 px-2 py-0.5 rounded-lg border border-charcoal-100">
                              Format: {item.variation.name}
                            </span>
                          )}
                          {item.product.purity_percentage && item.product.purity_percentage > 0 && (
                            <span className="text-glow-teal-700 font-medium flex items-center gap-1 bg-glow-teal-50 px-2 py-0.5 rounded-lg border border-glow-teal-200">
                              <Sparkles className="w-3 h-3" />
                              {item.product.purity_percentage}% Purity
                            </span>
                          )}
                          {item.penType && (
                            <span className="text-glow-teal-600 font-medium bg-glow-teal-50 px-2 py-0.5 rounded-lg border border-glow-teal-200">
                              {item.penType === 'disposable' ? 'Disposable Pen' : 'Reusable Pen'}
                            </span>
                          )}
                          {/* Multi-pricing badges */}
                          {item.purchaseMode && (
                            <span className="text-charcoal-600 font-medium bg-charcoal-50 px-2 py-0.5 rounded-lg border border-charcoal-200 flex items-center gap-1">
                              {item.purchaseMode === 'box' && <Box className="w-3 h-3" />}
                              {item.purchaseMode === 'vial' && <TestTube className="w-3 h-3" />}
                              {item.purchaseMode === 'complete_set' && <Package className="w-3 h-3" />}
                              {getPurchaseModeLabel(item.purchaseMode)}
                            </span>
                          )}
                          {item.fulfillmentType && (
                            <span className={`font-medium px-2 py-0.5 rounded-lg border flex items-center gap-1 ${
                              item.fulfillmentType === 'preorder'
                                ? 'text-blue-600 bg-blue-50 border-blue-200'
                                : 'text-emerald-600 bg-emerald-50 border-emerald-200'
                            }`}>
                              {item.fulfillmentType === 'preorder' ? <Globe className="w-3 h-3" /> : <MapPin className="w-3 h-3" />}
                              {getFulfillmentTypeLabel(item.fulfillmentType)}
                            </span>
                          )}
                          {item.currency === 'USD' && (
                            <span className="text-blue-700 font-bold bg-blue-50 px-2 py-0.5 rounded-lg border border-blue-200">
                              USD
                            </span>
                          )}
                        </div>
                      </div>
                      <button
                        onClick={() => removeFromCart(index)}
                        className="text-charcoal-400 hover:text-red-400 transition-colors p-1"
                        title="Remove item"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>

                    {/* Quantity and Price */}
                    <div className="flex flex-col sm:flex-row justify-between items-end sm:items-center gap-4">
                      <div className="flex items-center border border-charcoal-200 rounded-xl bg-charcoal-50">
                        <button
                          onClick={() => updateQuantity(index, item.quantity - 1)}
                          className="p-2 hover:bg-charcoal-100 transition-colors rounded-l-xl text-charcoal-500"
                        >
                          <Minus className="w-3 h-3" />
                        </button>
                        <span className="w-10 text-center font-bold text-charcoal-700 text-sm">
                          {item.quantity}
                        </span>
                        <button
                          onClick={() => {
                            const availableStock = item.variation ? item.variation.stock_quantity : item.product.stock_quantity;
                            if (item.quantity >= availableStock) {
                              alert(`Only ${availableStock} item(s) available in stock.`);
                              return;
                            }
                            updateQuantity(index, item.quantity + 1);
                          }}
                          disabled={(() => {
                            const availableStock = item.variation ? item.variation.stock_quantity : item.product.stock_quantity;
                            return item.quantity >= availableStock;
                          })()}
                          className="p-2 hover:bg-charcoal-100 transition-colors rounded-r-xl text-charcoal-500 disabled:opacity-50"
                        >
                          <Plus className="w-3 h-3" />
                        </button>
                      </div>

                      <div className="text-right">
                        <div className="text-lg md:text-xl font-bold text-charcoal-800">
                          {formatCurrency(item.price * item.quantity, item.currency || 'PHP')}
                        </div>
                        <div className="text-xs text-charcoal-500">
                          {formatCurrency(item.price, item.currency || 'PHP')} / unit
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* Order Summary */}
          <div className="lg:col-span-1">
            <div className="bg-white rounded-2xl shadow-md p-6 sticky top-24 border border-charcoal-100">
              <h2 className="font-heading text-lg font-bold text-charcoal-800 mb-6 flex items-center gap-2">
                Order Summary
                <Activity className="w-4 h-4 text-glow-teal-400" />
              </h2>

              <div className="space-y-3 mb-6">
                <div className="flex justify-between text-charcoal-500 text-sm">
                  <span>Subtotal (PHP)</span>
                  <span className="font-semibold text-charcoal-800">{formatCurrency(totalPHP, 'PHP')}</span>
                </div>

                {hasUSDItems && (
                  <div className="flex justify-between text-blue-600 text-sm">
                    <span>Subtotal (USD)</span>
                    <span className="font-semibold">{formatCurrency(totalUSD, 'USD')}</span>
                  </div>
                )}

                <div className="pt-3 border-t border-charcoal-100">
                  <div className="flex justify-between items-center mb-1">
                    <span className="text-base font-bold text-charcoal-800">Total Estimate</span>
                    <div className="text-right">
                      <div className="text-2xl font-bold text-charcoal-800">
                        {formatCurrency(totalPHP, 'PHP')}
                      </div>
                      {hasUSDItems && (
                        <div className="text-sm font-bold text-blue-600">
                          + {formatCurrency(totalUSD, 'USD')}
                        </div>
                      )}
                    </div>
                  </div>
                  <p className="text-xs text-charcoal-400 text-right font-normal">+ Shipping calculated at checkout</p>
                </div>
              </div>

              <div className="bg-glow-teal-50 rounded-xl p-4 mb-6 border border-glow-teal-100">
                <p className="text-xs text-glow-teal-700 font-medium mb-2">Shipping Information:</p>
                <ul className="text-xs text-charcoal-600 space-y-1">
                  <li className="flex justify-between"><span>Metro Manila</span> <span className="font-medium">₱150</span></li>
                  <li className="flex justify-between"><span>Provincial</span> <span className="font-medium">₱200</span></li>
                </ul>
              </div>

              <button
                onClick={onCheckout}
                className="w-full btn-primary py-3 md:py-4 text-sm md:text-base mb-3 flex items-center justify-center gap-2"
              >
                <CreditCard className="w-4 h-4" />
                Proceed to Checkout
              </button>

              <button
                onClick={onContinueShopping}
                className="w-full btn-secondary py-3 text-sm flex items-center justify-center gap-2"
              >
                Continue Browsing
              </button>

              {/* Trust Badges */}
              <div className="mt-6 pt-6 border-t border-charcoal-100 flex flex-col gap-2">
                <div className="flex items-center gap-2 text-xs text-charcoal-500">
                  <div className="w-4 h-4 rounded-full bg-glow-teal-50 flex items-center justify-center text-glow-teal-600 text-[10px]">&#10003;</div>
                  <span>Secure Encrypted Checkout</span>
                </div>
                <div className="flex items-center gap-2 text-xs text-charcoal-500">
                  <div className="w-4 h-4 rounded-full bg-glow-teal-50 flex items-center justify-center text-glow-teal-600 text-[10px]">&#10003;</div>
                  <span>HPLC Verified Purity</span>
                </div>
                <div className="flex items-center gap-2 text-xs text-charcoal-500">
                  <div className="w-4 h-4 rounded-full bg-glow-teal-50 flex items-center justify-center text-glow-teal-600 text-[10px]">&#10003;</div>
                  <span>Discreet Packaging</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Cart;
