import { useState, useEffect } from 'react';
import type { CartItem, Product, ProductVariation, PenType, PurchaseMode, FulfillmentType, CurrencyCode } from '../types';

export function useCart() {
  const [cartItems, setCartItems] = useState<CartItem[]>([]);

  // Load cart from localStorage on mount
  useEffect(() => {
    const savedCart = localStorage.getItem('peptide_cart');
    if (savedCart) {
      try {
        setCartItems(JSON.parse(savedCart));
      } catch (error) {
        console.error('Error loading cart from localStorage:', error);
      }
    }
  }, []);

  // Save cart to localStorage whenever it changes
  useEffect(() => {
    localStorage.setItem('peptide_cart', JSON.stringify(cartItems));
  }, [cartItems]);

  const addToCart = (
    product: Product,
    variation?: ProductVariation,
    quantity: number = 1,
    penType?: PenType,
    purchaseMode?: PurchaseMode,
    fulfillmentType?: FulfillmentType,
    price?: number,
    currency?: CurrencyCode
  ) => {
    // Check stock availability
    const availableStock = variation ? variation.stock_quantity : product.stock_quantity;

    if (availableStock === 0) {
      alert(`Sorry, ${product.name}${variation ? ` ${variation.name}` : ''} is out of stock.`);
      return;
    }

    // Calculate price: use provided price (from multi-pricing) or fall back to legacy logic
    const finalPrice = price ?? (() => {
      if (penType === 'disposable' && variation?.disposable_pen_price) {
        return variation.disposable_pen_price;
      }
      if (penType === 'reusable' && variation?.reusable_pen_price) {
        return variation.reusable_pen_price;
      }
      return variation ? variation.price : (product.discount_active && product.discount_price ? product.discount_price : product.base_price);
    })();

    // Find existing item matching product, variation, pen type, purchase mode, and fulfillment type
    const existingItemIndex = cartItems.findIndex(
      item => item.product.id === product.id &&
        (variation ? item.variation?.id === variation.id : !item.variation) &&
        item.penType === penType &&
        item.purchaseMode === purchaseMode &&
        item.fulfillmentType === fulfillmentType
    );

    if (existingItemIndex > -1) {
      const currentQuantity = cartItems[existingItemIndex].quantity;
      const newQuantity = currentQuantity + quantity;

      if (newQuantity > availableStock) {
        const remainingStock = availableStock - currentQuantity;
        if (remainingStock > 0) {
          alert(`Only ${remainingStock} item(s) available in stock. Added ${remainingStock} to your cart.`);
          quantity = remainingStock;
        } else {
          alert(`Sorry, you already have the maximum available quantity (${currentQuantity}) in your cart.`);
          return;
        }
      }

      const updatedItems = [...cartItems];
      updatedItems[existingItemIndex].quantity += quantity;
      setCartItems(updatedItems);
    } else {
      if (quantity > availableStock) {
        alert(`Only ${availableStock} item(s) available in stock. Added ${availableStock} to your cart.`);
        quantity = availableStock;
      }

      const newItem: CartItem = {
        product,
        variation,
        quantity,
        price: finalPrice,
        penType,
        purchaseMode,
        fulfillmentType,
        currency: 'USD'
      };
      setCartItems([...cartItems, newItem]);
    }
  };

  const updateQuantity = (index: number, quantity: number) => {
    if (quantity <= 0) {
      removeFromCart(index);
      return;
    }

    const item = cartItems[index];
    const availableStock = item.variation ? item.variation.stock_quantity : item.product.stock_quantity;

    if (quantity > availableStock) {
      alert(`Only ${availableStock} item(s) available in stock.`);
      quantity = availableStock;
    }

    const updatedItems = [...cartItems];
    updatedItems[index].quantity = quantity;
    setCartItems(updatedItems);
  };

  const removeFromCart = (index: number) => {
    const updatedItems = cartItems.filter((_, i) => i !== index);
    setCartItems(updatedItems);
  };

  const clearCart = () => {
    setCartItems([]);
    localStorage.removeItem('peptide_cart');
  };

  const getTotalPrice = () => {
    return cartItems.reduce((total, item) => total + (item.price * item.quantity), 0);
  };

  const getTotalItems = () => {
    return cartItems.reduce((total, item) => total + item.quantity, 0);
  };

  return {
    cartItems,
    addToCart,
    updateQuantity,
    removeFromCart,
    clearCart,
    getTotalPrice,
    getTotalItems
  };
}
