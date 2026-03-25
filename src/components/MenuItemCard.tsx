import React, { useState, useMemo } from 'react';
import { Plus, Minus, ShoppingCart, Package, Pen } from 'lucide-react';
import type { Product, ProductVariation, PenType, PurchaseMode, FulfillmentType, CurrencyCode } from '../types';
import { hasMultiPricing, getAvailablePurchaseModes, getAvailableFulfillmentTypes, getPriceForSelection } from '../utils/pricing';
import { formatCurrency } from '../utils/currency';

interface MenuItemCardProps {
  product: Product;
  onAddToCart: (product: Product, variation?: ProductVariation, quantity?: number, penType?: PenType, purchaseMode?: PurchaseMode, fulfillmentType?: FulfillmentType, price?: number, currency?: CurrencyCode) => void;
  cartQuantity?: number;
  onUpdateQuantity?: (index: number, quantity: number) => void;
  onProductClick?: (product: Product) => void;
}

const MenuItemCard: React.FC<MenuItemCardProps> = ({
  product,
  onAddToCart,
  cartQuantity = 0,
  onProductClick,
}) => {
  const [imageError, setImageError] = useState(false);
  const [selectedVariation, setSelectedVariation] = useState<ProductVariation | undefined>(
    product.variations && product.variations.length > 0 ? product.variations[0] : undefined
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

  // Update fulfillment when purchase mode changes
  const handlePurchaseModeChange = (mode: PurchaseMode) => {
    setSelectedPurchaseMode(mode);
    const newFulfillments = getAvailableFulfillmentTypes(product, mode);
    if (!newFulfillments.includes(selectedFulfillment)) {
      setSelectedFulfillment(newFulfillments[0] || 'preorder');
    }
  };

  const isInjectableProduct = product.category !== 'supplies';

  // Price calculation
  const multiPrices = useMemo(() => {
    if (!isMultiPriced) return null;
    return getPriceForSelection(product, selectedPurchaseMode, selectedFulfillment);
  }, [product, selectedPurchaseMode, selectedFulfillment, isMultiPriced]);

  const currentPrice = (() => {
    if (isMultiPriced && multiPrices) {
      return multiPrices.usd ?? 0;
    }
    if (selectedPenType === 'disposable' && selectedVariation?.disposable_pen_price) {
      return selectedVariation.disposable_pen_price;
    }
    if (selectedPenType === 'reusable' && selectedVariation?.reusable_pen_price) {
      return selectedVariation.reusable_pen_price;
    }
    return selectedVariation
      ? (selectedVariation.discount_active && selectedVariation.discount_price)
        ? selectedVariation.discount_price
        : selectedVariation.price
      : (product.discount_active && product.discount_price)
        ? product.discount_price
        : product.base_price;
  })();

  const displayCurrency: CurrencyCode = 'USD';

  const hasDiscount = !isMultiPriced && (selectedVariation
    ? (selectedVariation.discount_active && selectedVariation.discount_price !== null)
    : (product.discount_active && product.discount_price !== null));

  const originalPrice = selectedVariation ? selectedVariation.price : product.base_price;

  const handleAddToCart = () => {
    if (isMultiPriced) {
      onAddToCart(product, selectedVariation, quantity, null, selectedPurchaseMode, selectedFulfillment, multiPrices?.usd, 'USD');
    } else {
      onAddToCart(product, selectedVariation, quantity, isInjectableProduct ? selectedPenType : null);
    }
    setQuantity(1);
  };

  const availableStock = selectedVariation ? selectedVariation.stock_quantity : product.stock_quantity;

  const hasAnyStock = product.variations && product.variations.length > 0
    ? product.variations.some(v => v.stock_quantity > 0)
    : product.stock_quantity > 0;

  const incrementQuantity = () => {
    setQuantity(prev => {
      if (prev >= availableStock) {
        alert(`Only ${availableStock} item(s) available in stock.`);
        return prev;
      }
      return prev + 1;
    });
  };

  const decrementQuantity = () => setQuantity(prev => prev > 1 ? prev - 1 : 1);

  return (
    <div className="bg-white h-full flex flex-col group relative border border-charcoal-100 rounded-2xl shadow-sm hover:shadow-md hover:border-glow-teal-200 transition-all duration-300">
      {/* Click overlay for product details */}
      <div
        onClick={() => onProductClick?.(product)}
        className="absolute inset-x-0 top-0 h-28 sm:h-44 z-10 cursor-pointer"
        title="View details"
      />

      {/* Product Image */}
      <div className="relative h-28 sm:h-44 bg-charcoal-50 overflow-hidden rounded-t-2xl border-b border-charcoal-100">
        {product.image_url && !imageError ? (
          <img
            src={product.image_url}
            alt={product.name}
            className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
            onError={() => setImageError(true)}
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center text-charcoal-300 bg-charcoal-50">
            <Package className="w-16 h-16 opacity-50" />
          </div>
        )}

        {/* Badges */}
        <div className="absolute top-3 left-3 flex flex-col gap-2 pointer-events-none z-20">
          {product.featured && (
            <span className="px-2 py-1 bg-glow-teal-500 text-white text-[10px] font-bold uppercase tracking-wider rounded-lg shadow-sm">
              Featured
            </span>
          )}
          {hasDiscount && (
            <span className="px-2 py-1 bg-glow-teal-500 text-white text-[10px] font-bold rounded-lg shadow-sm">
              {Math.round((1 - currentPrice / originalPrice) * 100)}% OFF
            </span>
          )}
        </div>

        {/* Info Badges - Top Right */}
        <div className="absolute top-3 right-3 flex flex-col gap-1 pointer-events-none z-20">
          {product.region_restriction === 'PH' && (
            <span className="px-1.5 py-0.5 bg-amber-500 text-white text-[8px] sm:text-[9px] font-bold rounded-md shadow-sm">
              PH Only
            </span>
          )}
        </div>

        {/* Stock Status Overlay */}
        {(!product.available || !hasAnyStock) && (
          <div className="absolute inset-0 bg-white/80 backdrop-blur-[1px] flex items-center justify-center z-20">
            <span className="bg-charcoal-100 text-charcoal-500 px-3 py-1 text-xs font-bold rounded-lg border border-charcoal-200 uppercase tracking-wide">
              {!product.available ? 'Unavailable' : 'Out of Stock'}
            </span>
          </div>
        )}
      </div>

      {/* Product Details */}
      <div className="p-2.5 sm:p-4 flex-1 flex flex-col">
        <h3 className="font-heading font-bold text-charcoal-800 text-xs sm:text-base mb-0.5 sm:mb-1 line-clamp-2 tracking-tight">
          {product.name}
        </h3>

        {/* Code & Spec */}
        {(product.code || product.spec) && (
          <div className="flex flex-wrap gap-1 mb-1">
            {product.code && (
              <span className="text-[8px] sm:text-[9px] font-mono text-charcoal-400 bg-charcoal-50 px-1 py-0.5 rounded">
                {product.code}
              </span>
            )}
            {product.spec && (
              <span className="text-[8px] sm:text-[9px] text-charcoal-400 bg-charcoal-50 px-1 py-0.5 rounded">
                {product.spec}
              </span>
            )}
          </div>
        )}

        <p className="text-[10px] sm:text-xs text-charcoal-400 mb-2 sm:mb-3 line-clamp-2 min-h-[1.5rem] sm:min-h-[2.5rem] leading-relaxed">
          {product.description}
        </p>


        {/* Legacy: Variations (Sizes) - only show if no multi-pricing */}
        {!isMultiPriced && (
          <div className="mb-2 sm:mb-4 min-h-[1.5rem] sm:min-h-[2rem]">
            {product.variations && product.variations.length > 0 && (
              <div className="flex flex-wrap gap-1 sm:gap-2">
                {product.variations.slice(0, 2).map((variation) => {
                  const isOutOfStock = variation.stock_quantity === 0;
                  return (
                    <button
                      key={variation.id}
                      onClick={(e) => {
                        e.stopPropagation();
                        if (!isOutOfStock) {
                          setSelectedVariation(variation);
                        }
                      }}
                      disabled={isOutOfStock}
                      className={`
                        px-1.5 sm:px-2 py-0.5 sm:py-1 text-[9px] sm:text-[10px] font-medium rounded-lg border transition-all duration-200 relative z-20
                        ${selectedVariation?.id === variation.id && !isOutOfStock
                          ? 'bg-glow-teal-50 border-glow-teal-300 text-glow-teal-700'
                          : isOutOfStock
                            ? 'bg-charcoal-50 text-charcoal-300 border-charcoal-100 cursor-not-allowed'
                            : 'bg-white text-charcoal-500 border-charcoal-200 hover:border-glow-teal-300 hover:text-glow-teal-600'
                        }
                      `}
                    >
                      {variation.name}
                    </button>
                  );
                })}
                {product.variations.length > 2 && (
                  <span className="text-[9px] sm:text-[10px] text-charcoal-400 self-center">
                    +{product.variations.length - 2}
                  </span>
                )}
              </div>
            )}
          </div>
        )}

        {/* Legacy: Pen Type Selection - only show if no multi-pricing */}
        {!isMultiPriced && isInjectableProduct && selectedVariation && (
          <div className="mb-2 sm:mb-4">
            <div className="flex flex-wrap gap-1">
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  setSelectedPenType(null);
                }}
                className={`
                  px-1.5 py-0.5 text-[8px] sm:text-[9px] font-medium rounded-lg border transition-all relative z-20 flex items-center gap-1
                  ${selectedPenType === null
                    ? 'bg-glow-teal-50 border-glow-teal-300 text-glow-teal-700'
                    : 'bg-white text-charcoal-400 border-charcoal-200 hover:border-glow-teal-300 hover:text-glow-teal-600'
                  }
                `}
                title="Complete Set (with insulin syringes & alcohol swabs)"
              >
                Set
              </button>

              {selectedVariation?.disposable_pen_price && (
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    setSelectedPenType('disposable');
                  }}
                  className={`
                    px-1.5 py-0.5 text-[8px] sm:text-[9px] font-medium rounded-lg border transition-all relative z-20 flex items-center gap-1
                    ${selectedPenType === 'disposable'
                      ? 'bg-glow-teal-50 border-glow-teal-300 text-glow-teal-700'
                      : 'bg-white text-charcoal-400 border-charcoal-200 hover:border-glow-teal-300 hover:text-glow-teal-600'
                    }
                  `}
                  title="Disposable Pen (includes 3 needles)"
                >
                  <Pen className="w-2 h-2" />
                  Disp
                </button>
              )}

              {selectedVariation?.reusable_pen_price && (
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    setSelectedPenType('reusable');
                  }}
                  className={`
                    px-1.5 py-0.5 text-[8px] sm:text-[9px] font-medium rounded-lg border transition-all relative z-20 flex items-center gap-1
                    ${selectedPenType === 'reusable'
                      ? 'bg-glow-teal-50 border-glow-teal-300 text-glow-teal-700'
                      : 'bg-white text-charcoal-400 border-charcoal-200 hover:border-glow-teal-300 hover:text-glow-teal-600'
                    }
                  `}
                  title="Reusable Pen (includes cartridge & 3 needles)"
                >
                  <Pen className="w-2 h-2" />
                  Reus
                </button>
              )}
            </div>
          </div>
        )}

        <div className="flex-1" />

        {/* Price and Cart Actions */}
        <div className="flex flex-col gap-2 sm:gap-3 mt-auto">
          {/* Multi-pricing display */}
          {isMultiPriced && multiPrices ? (
            <div className="flex flex-col gap-0.5">
              {multiPrices.usd !== undefined ? (
                <span className="text-sm sm:text-lg font-bold text-charcoal-800">
                  {formatCurrency(multiPrices.usd)}
                </span>
              ) : (
                <span className="text-[10px] sm:text-xs text-charcoal-400 italic">Price not available</span>
              )}
            </div>
          ) : hasDiscount ? (
            <div className="flex items-baseline gap-1 sm:gap-2">
              <span className="text-sm sm:text-lg font-bold text-charcoal-800">
                {formatCurrency(currentPrice)}
              </span>
              <span className="text-[10px] sm:text-xs text-charcoal-400 line-through">
                {formatCurrency(originalPrice)}
              </span>
            </div>
          ) : (
            <div className="flex items-baseline">
              <span className="text-sm sm:text-lg font-bold text-charcoal-800">
                {formatCurrency(currentPrice)}
              </span>
            </div>
          )}

          <div className="flex items-center gap-1.5 sm:gap-2 relative z-20">
            {/* Quantity Controls */}
            <div className="flex items-center bg-charcoal-50 border border-charcoal-200 rounded-xl">
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  decrementQuantity();
                }}
                className="p-1 sm:p-1.5 hover:bg-charcoal-100 transition-colors rounded-l-xl text-charcoal-500"
                disabled={!hasAnyStock || !product.available}
              >
                <Minus className="w-3 h-3" />
              </button>
              <span className="w-6 sm:w-8 text-center text-[10px] sm:text-xs font-bold text-charcoal-700">
                {quantity}
              </span>
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  incrementQuantity();
                }}
                className="p-1 sm:p-1.5 hover:bg-charcoal-100 transition-colors rounded-r-xl text-charcoal-500"
                disabled={quantity >= availableStock || !hasAnyStock || !product.available}
              >
                <Plus className="w-3 h-3" />
              </button>
            </div>

            {/* Add to Cart Button */}
            <button
              onClick={(e) => {
                e.stopPropagation();
                if (quantity > availableStock) {
                  alert(`Only ${availableStock} item(s) available in stock.`);
                  setQuantity(availableStock);
                  return;
                }
                handleAddToCart();
              }}
              disabled={!hasAnyStock || availableStock === 0 || !product.available || (isMultiPriced && !multiPrices?.usd)}
              className="flex-1 btn-primary py-1.5 sm:py-2 text-[10px] sm:text-xs flex items-center justify-center gap-1 sm:gap-2 disabled:opacity-50 disabled:cursor-not-allowed disabled:shadow-none"
            >
              <ShoppingCart className="w-3 h-3" />
              <span className="hidden sm:inline">Add</span>
            </button>
          </div>

          {/* Cart Status */}
          {cartQuantity > 0 && (
            <div className="text-center text-[10px] text-glow-teal-700 font-medium bg-glow-teal-50 rounded-lg py-1 border border-glow-teal-200">
              {cartQuantity} in cart
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default MenuItemCard;
