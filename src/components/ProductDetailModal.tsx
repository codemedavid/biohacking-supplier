import React, { useState, useMemo } from 'react';
import { X, Package, Beaker, ShoppingCart, Plus, Minus, Sparkles, ArrowLeft, Pen } from 'lucide-react';
import type { Product, ProductVariation, PenType, PurchaseMode, FulfillmentType, CurrencyCode } from '../types';
import { hasMultiPricing, getAvailablePurchaseModes, getAvailableFulfillmentTypes, getPriceForSelection, getPurchaseModeLabel } from '../utils/pricing';
import { formatCurrency } from '../utils/currency';

interface ProductDetailModalProps {
  product: Product;
  onClose: () => void;
  onAddToCart: (product: Product, variation: ProductVariation | undefined, quantity: number, penType?: PenType, purchaseMode?: PurchaseMode, fulfillmentType?: FulfillmentType, price?: number, currency?: CurrencyCode) => void;
}

const ProductDetailModal: React.FC<ProductDetailModalProps> = ({ product, onClose, onAddToCart }) => {
  const getFirstAvailableVariation = () => {
    if (!product.variations || product.variations.length === 0) return undefined;
    const available = product.variations.find(v => v.stock_quantity > 0);
    return available || product.variations[0];
  };

  const [imageError, setImageError] = useState(false);
  const [selectedVariation, setSelectedVariation] = useState<ProductVariation | undefined>(
    getFirstAvailableVariation()
  );
  const [quantity, setQuantity] = useState(1);
  const [selectedPenType, setSelectedPenType] = useState<PenType>(null);

  // Multi-pricing state
  const isMultiPriced = hasMultiPricing(product);
  const availableModes = useMemo(() => getAvailablePurchaseModes(product), [product]);
  const [selectedPurchaseMode, setSelectedPurchaseMode] = useState<PurchaseMode>(availableModes[0] || 'box');

  const availableFulfillments = useMemo(
    () => getAvailableFulfillmentTypes(product, selectedPurchaseMode),
    [product, selectedPurchaseMode]
  );
  const [selectedFulfillment, setSelectedFulfillment] = useState<FulfillmentType>(availableFulfillments[0] || 'preorder');

  const handlePurchaseModeChange = (mode: PurchaseMode) => {
    setSelectedPurchaseMode(mode);
    const newFulfillments = getAvailableFulfillmentTypes(product, mode);
    if (!newFulfillments.includes(selectedFulfillment)) {
      setSelectedFulfillment(newFulfillments[0] || 'preorder');
    }
  };

  const isInjectableProduct = product.category !== 'supplies';
  const hasDiscount = !isMultiPriced && product.discount_active && product.discount_price;

  // Multi-pricing
  const multiPrices = useMemo(() => {
    if (!isMultiPriced) return null;
    return getPriceForSelection(product, selectedPurchaseMode, selectedFulfillment);
  }, [product, selectedPurchaseMode, selectedFulfillment, isMultiPriced]);

  const calculatePrice = () => {
    if (isMultiPriced && multiPrices) {
      return multiPrices.usd ?? 0;
    }
    if (!selectedVariation) return product.base_price;
    if (selectedPenType === 'disposable' && selectedVariation.disposable_pen_price) {
      return selectedVariation.disposable_pen_price;
    }
    if (selectedPenType === 'reusable' && selectedVariation.reusable_pen_price) {
      return selectedVariation.reusable_pen_price;
    }
    return selectedVariation.price;
  };

  const currentPrice = calculatePrice();
  const displayCurrency: CurrencyCode = 'USD';
  const showPurity = Boolean(product.purity_percentage);

  const hasAnyStock = product.variations && product.variations.length > 0
    ? product.variations.some(v => v.stock_quantity > 0)
    : product.stock_quantity > 0;

  const incrementQuantity = () => setQuantity(prev => prev + 1);
  const decrementQuantity = () => setQuantity(prev => prev > 1 ? prev - 1 : 1);

  const handleAddToCart = () => {
    if (isMultiPriced) {
      onAddToCart(product, selectedVariation, quantity, null, selectedPurchaseMode, selectedFulfillment, multiPrices?.usd, 'USD');
    } else {
      onAddToCart(product, selectedVariation, quantity, isInjectableProduct ? selectedPenType : null);
    }
    onClose();
  };

  return (
    <div className="fixed inset-0 bg-charcoal-800/20 backdrop-blur-sm flex items-center justify-center z-50 p-2 sm:p-4 overflow-y-auto">
      <div className="bg-white rounded-2xl shadow-luxury max-w-4xl w-full max-h-[95vh] sm:max-h-[90vh] overflow-hidden my-2 sm:my-8 border border-charcoal-100">
        {/* Header */}
        <div className="bg-white text-charcoal-800 p-3 sm:p-4 md:p-6 relative border-b border-charcoal-100">
          <button
            onClick={onClose}
            className="absolute top-2 right-2 sm:top-3 sm:right-3 md:top-4 md:right-4 p-1.5 sm:p-2 hover:bg-charcoal-50 rounded-xl transition-colors text-charcoal-400 hover:text-charcoal-600"
          >
            <X className="w-4 h-4 sm:w-5 sm:h-5 md:w-6 md:h-6" />
          </button>
          <div className="pr-10 sm:pr-12">
            <h2 className="font-heading text-base sm:text-xl md:text-2xl lg:text-3xl font-bold mb-1.5 sm:mb-2 text-charcoal-800 tracking-tight">{product.name}</h2>
            <div className="flex items-center gap-1.5 sm:gap-2 md:gap-3 flex-wrap">
              {product.code && (
                <span className="inline-flex items-center px-2 py-0.5 rounded-lg text-[10px] sm:text-xs font-mono font-semibold bg-charcoal-50 border border-charcoal-200 text-charcoal-600">
                  {product.code}
                </span>
              )}
              {product.spec && (
                <span className="inline-flex items-center px-2 py-0.5 rounded-lg text-[10px] sm:text-xs font-semibold bg-charcoal-50 border border-charcoal-200 text-charcoal-500">
                  {product.spec}
                </span>
              )}
              {showPurity && (
                <span className="inline-flex items-center px-2 py-0.5 rounded-lg text-[10px] sm:text-xs font-semibold bg-glow-teal-50 border border-glow-teal-200 text-glow-teal-700">
                  <Sparkles className="w-3 h-3 mr-1" />
                  {product.purity_percentage}% Pure
                </span>
              )}
              {product.featured && (
                <span className="inline-flex items-center px-2 py-0.5 rounded-lg text-[10px] sm:text-xs font-semibold bg-glow-teal-50 border border-glow-teal-200 text-glow-teal-700">
                  Featured
                </span>
              )}
              {hasDiscount && (
                <span className="inline-flex items-center px-2 py-0.5 rounded-lg text-[10px] sm:text-xs font-semibold bg-glow-teal-50 border border-glow-teal-200 text-glow-teal-700">
                  Sale
                </span>
              )}
            </div>

            {/* Product Info Badges */}
            <div className="flex items-center gap-1.5 mt-2 flex-wrap">
              {product.region_restriction === 'PH' && (
                <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-lg text-[10px] sm:text-xs font-bold bg-amber-50 border border-amber-200 text-amber-700">
                  Philippines Only
                </span>
              )}
              {product.units_per_pack && product.unit_type && (
                <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-lg text-[10px] sm:text-xs font-medium bg-charcoal-50 border border-charcoal-200 text-charcoal-500">
                  {product.units_per_pack} {product.unit_type}/pack
                </span>
              )}
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="p-3 sm:p-4 md:p-6 overflow-y-auto max-h-[calc(95vh-180px)] sm:max-h-[calc(90vh-280px)]">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-3 sm:gap-4 md:gap-6">
            {/* Left Column */}
            <div className="space-y-3 sm:space-y-4 md:space-y-6">
              <div className="relative h-40 sm:h-48 md:h-56 lg:h-64 bg-charcoal-50 rounded-2xl overflow-hidden border border-charcoal-100">
                {product.image_url && !imageError ? (
                  <img
                    src={product.image_url}
                    alt={product.name}
                    className="w-full h-full object-cover"
                    onError={() => setImageError(true)}
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center text-charcoal-300 bg-charcoal-50">
                    <Package className="w-16 h-16 sm:w-20 sm:h-20 opacity-50" />
                  </div>
                )}
              </div>

              <div>
                <h3 className="font-heading text-sm sm:text-base md:text-lg font-bold text-charcoal-800 mb-1.5 sm:mb-2 flex items-center gap-1.5 sm:gap-2">
                  <Beaker className="w-3.5 h-3.5 sm:w-4 sm:h-4 md:w-5 md:h-5 text-glow-teal-400" />
                  Product Description
                </h3>
                <p className="text-xs sm:text-sm md:text-base text-charcoal-500 leading-relaxed font-sans">{product.description}</p>
              </div>

              {product.inclusions && product.inclusions.length > 0 && (
                <div className="bg-glow-teal-50 rounded-xl p-3 sm:p-4 border border-glow-teal-100">
                  <h3 className="font-heading text-sm sm:text-base md:text-lg font-bold text-charcoal-800 mb-2 sm:mb-3 flex items-center gap-1.5 sm:gap-2">
                    <Package className="w-3.5 h-3.5 sm:w-4 sm:h-4 md:w-5 md:h-5 text-glow-teal-400" />
                    Kit Inclusions
                  </h3>
                  <ul className="space-y-1.5 sm:space-y-2">
                    {product.inclusions.map((inclusion, idx) => (
                      <li key={idx} className="text-[11px] sm:text-xs md:text-sm text-charcoal-600 flex items-start gap-2">
                        <span className="text-glow-teal-500 font-bold mt-0.5">&#10003;</span>
                        <span className="flex-1">{inclusion}</span>
                      </li>
                    ))}
                  </ul>
                </div>
              )}

              <div className="bg-charcoal-50 rounded-xl p-3 sm:p-4 border border-charcoal-100">
                <h3 className="font-heading text-sm sm:text-base md:text-lg font-bold text-charcoal-800 mb-2 sm:mb-3 flex items-center gap-1.5 sm:gap-2">
                  <Beaker className="w-3.5 h-3.5 sm:w-4 sm:h-4 md:w-5 md:h-5 text-glow-teal-400" />
                  Technical Specifications
                </h3>
                <div className="space-y-1.5 sm:space-y-2">
                  {showPurity && (
                    <div className="flex justify-between">
                      <span className="text-charcoal-500 text-[11px] sm:text-xs md:text-sm">Purity Analysis:</span>
                      <span className="font-semibold text-glow-teal-600 text-[11px] sm:text-xs md:text-sm">{product.purity_percentage}% (HPLC Verified)</span>
                    </div>
                  )}
                  <div className="flex justify-between">
                    <span className="text-charcoal-500 text-[11px] sm:text-xs md:text-sm">Storage:</span>
                    <span className="font-medium text-charcoal-700 text-[11px] sm:text-xs md:text-sm">{product.storage_conditions}</span>
                  </div>
                  {product.units_per_pack && (
                    <div className="flex justify-between">
                      <span className="text-charcoal-500 text-[11px] sm:text-xs md:text-sm">Pack Size:</span>
                      <span className="font-medium text-charcoal-700 text-[11px] sm:text-xs md:text-sm">{product.units_per_pack} {product.unit_type}</span>
                    </div>
                  )}
                  <div className="flex justify-between">
                    <span className="text-charcoal-500 text-[11px] sm:text-xs md:text-sm">Availability:</span>
                    <span className={`font-medium text-[11px] sm:text-xs md:text-sm ${(product.variations && product.variations.length > 0
                      ? product.variations.some(v => v.stock_quantity > 0)
                      : product.stock_quantity > 0)
                      ? 'text-glow-teal-600'
                      : 'text-red-400'
                      }`}>
                      {product.variations && product.variations.length > 0
                        ? product.variations.reduce((sum, v) => sum + v.stock_quantity, 0)
                        : product.stock_quantity} units
                    </span>
                  </div>
                </div>
              </div>

              {/* Product Notes */}
              {product.notes && (
                <div className="bg-amber-50 rounded-xl p-3 sm:p-4 border border-amber-100">
                  <p className="text-xs sm:text-sm text-amber-700">{product.notes}</p>
                </div>
              )}
            </div>

            {/* Right Column - Purchase Section */}
            <div className="space-y-3 sm:space-y-4 md:space-y-6">
              <div className="bg-white rounded-2xl p-3 sm:p-4 md:p-6 border border-charcoal-100 shadow-md">

                {/* MULTI-PRICING PURCHASE FLOW */}
                {isMultiPriced ? (
                  <>
                    {/* Price Display - Per Box */}
                    <div className="text-center mb-4 bg-charcoal-50 rounded-xl p-4 border border-charcoal-100">
                      {multiPrices && multiPrices.usd !== undefined ? (
                        <>
                          <div className="text-3xl sm:text-4xl font-bold text-charcoal-800 mb-1">
                            {formatCurrency(multiPrices.usd)}
                          </div>
                          <div className="text-xs text-charcoal-400 mt-1">
                            {getPurchaseModeLabel(selectedPurchaseMode)}
                            {product.units_per_pack && product.unit_type && ` · ${product.units_per_pack} ${product.unit_type} per box`}
                          </div>
                        </>
                      ) : (
                        <div className="text-charcoal-400 text-sm py-2">
                          Price not available
                        </div>
                      )}
                    </div>
                  </>
                ) : (
                  /* LEGACY PRICING FLOW */
                  <>
                    <div className="text-center mb-3 sm:mb-4">
                      {hasDiscount ? (
                        <>
                          <div className="flex items-center justify-center gap-2 mb-1">
                            <span className="text-base sm:text-lg md:text-xl lg:text-2xl text-charcoal-400 line-through font-medium">
                              {formatCurrency(product.base_price)}
                            </span>
                            <span className="text-xs sm:text-sm font-bold text-glow-teal-700 bg-glow-teal-50 px-2 py-1 rounded-lg border border-glow-teal-200">
                              {Math.round((1 - product.discount_price! / product.base_price) * 100)}% OFF
                            </span>
                          </div>
                          <div className="text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-bold text-charcoal-800 mb-2">
                            {formatCurrency(currentPrice)}
                          </div>
                          <div className="inline-block bg-glow-teal-50 text-glow-teal-700 px-2 py-0.5 sm:px-2.5 sm:py-1 md:px-3 md:py-1 rounded-lg text-[10px] sm:text-xs md:text-sm font-bold border border-glow-teal-200">
                            Savings: {formatCurrency(product.base_price - product.discount_price!)}
                          </div>
                        </>
                      ) : (
                        <div className="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold text-charcoal-800">
                          {formatCurrency(currentPrice)}
                        </div>
                      )}
                    </div>

                    {product.variations && product.variations.length > 0 && (
                      <div className="mb-3 sm:mb-4">
                        <label className="block text-xs sm:text-sm font-bold text-charcoal-700 mb-1.5 sm:mb-2 uppercase tracking-wide">
                          Select Format
                        </label>
                        <div className="grid grid-cols-2 gap-2">
                          {product.variations.map((variation) => {
                            const isOutOfStock = variation.stock_quantity === 0;
                            const isSelected = selectedVariation?.id === variation.id;
                            return (
                              <button
                                key={variation.id}
                                onClick={() => {
                                  if (variation.stock_quantity > 0) {
                                    setSelectedVariation(variation);
                                  }
                                }}
                                disabled={isOutOfStock}
                                className={`
                                  p-3 rounded-xl border text-sm text-left transition-all
                                  ${isSelected
                                    ? 'border-glow-teal-300 bg-glow-teal-50 text-charcoal-800 ring-1 ring-glow-teal-300'
                                    : 'border-charcoal-200 hover:border-glow-teal-200 text-charcoal-600 bg-white'
                                  }
                                  ${isOutOfStock ? 'opacity-50 cursor-not-allowed bg-charcoal-50' : ''}
                                `}
                              >
                                <div className="font-bold">{variation.name}</div>
                                <div className="text-xs opacity-80">{formatCurrency(variation.price)}</div>
                                {isOutOfStock && <div className="text-xs text-red-400 font-bold mt-1">Out of Stock</div>}
                              </button>
                            );
                          })}
                        </div>
                        {selectedVariation && selectedVariation.stock_quantity === 0 && (
                          <p className="text-xs text-red-400 mt-1.5 font-semibold">
                            This format is currently unavailable.
                          </p>
                        )}
                      </div>
                    )}

                    {isInjectableProduct && (
                      <div className="mb-3 sm:mb-4">
                        <label className="block text-xs sm:text-sm font-bold text-charcoal-700 mb-1.5 sm:mb-2 uppercase tracking-wide flex items-center gap-2">
                          <Pen className="w-4 h-4 text-glow-teal-400" />
                          Pen Type
                        </label>
                        <div className="grid grid-cols-1 gap-2">
                          <button
                            onClick={() => setSelectedPenType(null)}
                            className={`
                              p-3 rounded-xl border text-sm text-left transition-all flex justify-between items-center
                              ${selectedPenType === null
                                ? 'border-glow-teal-300 bg-glow-teal-50 text-charcoal-800 ring-1 ring-glow-teal-300'
                                : 'border-charcoal-200 hover:border-glow-teal-200 text-charcoal-600 bg-white'
                              }
                            `}
                          >
                            <div>
                              <div className="font-bold">Complete Set</div>
                              <div className="text-xs opacity-80">With insulin syringes & alcohol swabs</div>
                            </div>
                            <div className="font-bold text-charcoal-800">
                              {selectedVariation ? formatCurrency(selectedVariation.price) : ''}
                            </div>
                          </button>

                          <button
                            onClick={() => setSelectedPenType('disposable')}
                            disabled={!selectedVariation?.disposable_pen_price}
                            className={`
                              p-3 rounded-xl border text-sm text-left transition-all flex justify-between items-center
                              ${selectedPenType === 'disposable'
                                ? 'border-glow-teal-300 bg-glow-teal-50 text-charcoal-800 ring-1 ring-glow-teal-300'
                                : 'border-charcoal-200 hover:border-glow-teal-200 text-charcoal-600 bg-white'
                              }
                              ${!selectedVariation?.disposable_pen_price ? 'opacity-50 cursor-not-allowed bg-charcoal-50' : ''}
                            `}
                          >
                            <div>
                              <div className="font-bold">Disposable Pen</div>
                              <div className="text-xs opacity-80">Includes 3 needles</div>
                            </div>
                            <div className="font-bold text-charcoal-800">
                              {selectedVariation?.disposable_pen_price
                                ? formatCurrency(selectedVariation.disposable_pen_price)
                                : 'N/A'}
                            </div>
                          </button>

                          <button
                            onClick={() => setSelectedPenType('reusable')}
                            disabled={!selectedVariation?.reusable_pen_price}
                            className={`
                              p-3 rounded-xl border text-sm text-left transition-all flex justify-between items-center
                              ${selectedPenType === 'reusable'
                                ? 'border-glow-teal-300 bg-glow-teal-50 text-charcoal-800 ring-1 ring-glow-teal-300'
                                : 'border-charcoal-200 hover:border-glow-teal-200 text-charcoal-600 bg-white'
                              }
                              ${!selectedVariation?.reusable_pen_price ? 'opacity-50 cursor-not-allowed bg-charcoal-50' : ''}
                            `}
                          >
                            <div>
                              <div className="font-bold">Reusable Pen</div>
                              <div className="text-xs opacity-80">Includes cartridge & 3 needles</div>
                            </div>
                            <div className="font-bold text-charcoal-800">
                              {selectedVariation?.reusable_pen_price
                                ? formatCurrency(selectedVariation.reusable_pen_price)
                                : 'N/A'}
                            </div>
                          </button>
                        </div>

                        {!selectedPenType && (
                          <p className="text-xs text-charcoal-400 mt-1.5">
                            Optional: Select your preferred pen type
                          </p>
                        )}
                      </div>
                    )}
                  </>
                )}

                {/* Quantity */}
                <div className="mb-3 sm:mb-4">
                  <label className="block text-xs sm:text-sm font-bold text-charcoal-700 mb-1.5 sm:mb-2 uppercase tracking-wide">
                    Quantity
                  </label>
                  <div className="flex items-center justify-center gap-3 sm:gap-4 md:gap-5">
                    <button
                      onClick={decrementQuantity}
                      className="w-10 h-10 sm:w-12 sm:h-12 flex items-center justify-center bg-charcoal-50 border border-charcoal-200 hover:bg-charcoal-100 rounded-xl transition-all active:scale-95 text-charcoal-500"
                      disabled={!product.available}
                    >
                      <Minus className="w-5 h-5" />
                    </button>
                    <span className="text-xl sm:text-2xl font-bold text-charcoal-800 min-w-[50px] text-center">
                      {quantity}
                    </span>
                    <button
                      onClick={incrementQuantity}
                      className="w-10 h-10 sm:w-12 sm:h-12 flex items-center justify-center bg-charcoal-50 border border-charcoal-200 hover:bg-charcoal-100 rounded-xl transition-all active:scale-95 text-charcoal-500"
                      disabled={!product.available}
                    >
                      <Plus className="w-5 h-5" />
                    </button>
                  </div>
                </div>

                {/* Total Estimate */}
                <div className="bg-charcoal-50 rounded-xl p-3 mb-4 border border-charcoal-100">
                  <div className="flex justify-between items-center">
                    <span className="text-charcoal-500 font-medium text-sm">Total Estimate:</span>
                    <span className="text-xl font-bold text-charcoal-800">
                      {formatCurrency(currentPrice * quantity, displayCurrency)}
                    </span>
                  </div>
                </div>

                <button
                  onClick={handleAddToCart}
                  disabled={!product.available || !hasAnyStock || (selectedVariation && selectedVariation.stock_quantity === 0) || (!selectedVariation && product.stock_quantity === 0) || (isMultiPriced && !multiPrices?.usd)}
                  className="w-full btn-primary py-3 md:py-4 text-sm md:text-base flex items-center justify-center gap-2"
                >
                  <ShoppingCart className="w-5 h-5" />
                  {!product.available
                    ? 'Unavailable'
                    : (!hasAnyStock || (selectedVariation && selectedVariation.stock_quantity === 0) || (!selectedVariation && product.stock_quantity === 0)
                      ? 'Out of Stock'
                      : 'Add to Cart')}
                </button>

                <button
                  onClick={onClose}
                  className="w-full mt-3 py-3 text-sm md:text-base font-medium text-charcoal-500 hover:text-charcoal-700 hover:bg-charcoal-50 rounded-xl transition-colors flex items-center justify-center gap-2"
                >
                  <ArrowLeft className="w-4 h-4" />
                  Return to Shop
                </button>
              </div>

              {product.available && (product.variations && product.variations.length > 0
                ? product.variations.some(v => v.stock_quantity > 0 && v.stock_quantity < 10)
                : product.stock_quantity < 10 && product.stock_quantity > 0) && (
                  <div className="bg-rose-50 border border-rose-100 rounded-xl p-3">
                    <p className="text-xs text-rose-600 font-medium flex items-center gap-2">
                      <span className="font-bold">!</span>
                      Low stock: Only {product.variations && product.variations.length > 0
                        ? product.variations.reduce((sum, v) => sum + v.stock_quantity, 0)
                        : product.stock_quantity} units remaining
                    </p>
                  </div>
                )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProductDetailModal;
