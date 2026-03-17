import { describe, it, expect, beforeEach, vi } from 'vitest';
import { renderHook, act } from '@testing-library/react';
import { useCart } from '../useCart';
import {
  mockProduct,
  mockProductOutOfStock,
  mockProductNoDiscount,
  mockVariation,
  mockVariationOutOfStock,
} from '../../test/fixtures';

// Mock alert
const alertMock = vi.fn();
global.alert = alertMock;

describe('useCart hook', () => {
  beforeEach(() => {
    localStorage.clear();
    alertMock.mockClear();
  });

  describe('initialization', () => {
    it('starts with an empty cart', () => {
      const { result } = renderHook(() => useCart());
      expect(result.current.cartItems).toEqual([]);
      expect(result.current.getTotalItems()).toBe(0);
      expect(result.current.getTotalPrice()).toBe(0);
    });

    it('loads cart from localStorage on mount', () => {
      const savedCart = [
        { product: mockProduct, quantity: 2, price: 2000, currency: 'PHP' },
      ];
      localStorage.setItem('peptide_cart', JSON.stringify(savedCart));

      const { result } = renderHook(() => useCart());
      expect(result.current.cartItems).toHaveLength(1);
      expect(result.current.cartItems[0].quantity).toBe(2);
    });

    it('handles corrupted localStorage gracefully', () => {
      localStorage.setItem('peptide_cart', 'invalid-json');
      const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {});

      const { result } = renderHook(() => useCart());
      expect(result.current.cartItems).toEqual([]);

      consoleSpy.mockRestore();
    });
  });

  describe('addToCart', () => {
    it('adds a product to the cart', () => {
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(mockProduct);
      });

      expect(result.current.cartItems).toHaveLength(1);
      expect(result.current.cartItems[0].product.id).toBe('prod-1');
      expect(result.current.cartItems[0].quantity).toBe(1);
    });

    it('uses discount price when active', () => {
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(mockProduct);
      });

      // mockProduct has discount_active: true, discount_price: 2000
      expect(result.current.cartItems[0].price).toBe(2000);
    });

    it('uses base price when no discount', () => {
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(mockProductNoDiscount);
      });

      expect(result.current.cartItems[0].price).toBe(2500);
    });

    it('increments quantity for duplicate product', () => {
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(mockProduct);
      });
      act(() => {
        result.current.addToCart(mockProduct);
      });

      expect(result.current.cartItems).toHaveLength(1);
      expect(result.current.cartItems[0].quantity).toBe(2);
    });

    it('prevents adding out-of-stock product', () => {
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(mockProductOutOfStock);
      });

      expect(result.current.cartItems).toHaveLength(0);
      expect(alertMock).toHaveBeenCalledWith(
        expect.stringContaining('out of stock')
      );
    });

    it('prevents exceeding stock quantity', () => {
      const limitedProduct = { ...mockProduct, stock_quantity: 2 };
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(limitedProduct, undefined, 1);
      });
      act(() => {
        result.current.addToCart(limitedProduct, undefined, 1);
      });
      act(() => {
        result.current.addToCart(limitedProduct, undefined, 1);
      });

      // Should alert about max stock
      expect(alertMock).toHaveBeenCalled();
      expect(result.current.cartItems[0].quantity).toBe(2);
    });

    it('adds product with variation', () => {
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(mockProduct, mockVariation);
      });

      expect(result.current.cartItems).toHaveLength(1);
      expect(result.current.cartItems[0].variation?.id).toBe('var-1');
      expect(result.current.cartItems[0].price).toBe(1500);
    });

    it('uses variation stock for availability check', () => {
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(mockProduct, mockVariationOutOfStock);
      });

      expect(result.current.cartItems).toHaveLength(0);
      expect(alertMock).toHaveBeenCalledWith(
        expect.stringContaining('out of stock')
      );
    });

    it('uses disposable pen price when pen type is disposable', () => {
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(mockProduct, mockVariation, 1, 'disposable');
      });

      expect(result.current.cartItems[0].price).toBe(2000);
      expect(result.current.cartItems[0].penType).toBe('disposable');
    });

    it('uses reusable pen price when pen type is reusable', () => {
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(mockProduct, mockVariation, 1, 'reusable');
      });

      expect(result.current.cartItems[0].price).toBe(1800);
      expect(result.current.cartItems[0].penType).toBe('reusable');
    });

    it('uses provided price from multi-pricing', () => {
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(
          mockProduct, undefined, 1, undefined,
          'box', 'preorder', 2500, 'PHP'
        );
      });

      expect(result.current.cartItems[0].price).toBe(2500);
      expect(result.current.cartItems[0].purchaseMode).toBe('box');
      expect(result.current.cartItems[0].fulfillmentType).toBe('preorder');
      expect(result.current.cartItems[0].currency).toBe('PHP');
    });

    it('treats same product with different purchase modes as separate items', () => {
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(
          mockProduct, undefined, 1, undefined,
          'box', 'preorder', 2500, 'PHP'
        );
      });
      act(() => {
        result.current.addToCart(
          mockProduct, undefined, 1, undefined,
          'vial', 'onhand', 400, 'PHP'
        );
      });

      expect(result.current.cartItems).toHaveLength(2);
    });

    it('defaults currency to PHP', () => {
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(mockProduct);
      });

      expect(result.current.cartItems[0].currency).toBe('PHP');
    });
  });

  describe('updateQuantity', () => {
    it('updates item quantity', () => {
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(mockProduct);
      });
      act(() => {
        result.current.updateQuantity(0, 5);
      });

      expect(result.current.cartItems[0].quantity).toBe(5);
    });

    it('removes item when quantity is set to 0', () => {
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(mockProduct);
      });
      act(() => {
        result.current.updateQuantity(0, 0);
      });

      expect(result.current.cartItems).toHaveLength(0);
    });

    it('removes item when quantity is negative', () => {
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(mockProduct);
      });
      act(() => {
        result.current.updateQuantity(0, -1);
      });

      expect(result.current.cartItems).toHaveLength(0);
    });

    it('caps quantity at available stock', () => {
      const limitedProduct = { ...mockProduct, stock_quantity: 3 };
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(limitedProduct);
      });
      act(() => {
        result.current.updateQuantity(0, 10);
      });

      expect(result.current.cartItems[0].quantity).toBe(3);
      expect(alertMock).toHaveBeenCalled();
    });
  });

  describe('removeFromCart', () => {
    it('removes item at index', () => {
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(mockProduct);
      });
      act(() => {
        result.current.addToCart(mockProductNoDiscount);
      });
      act(() => {
        result.current.removeFromCart(0);
      });

      expect(result.current.cartItems).toHaveLength(1);
      expect(result.current.cartItems[0].product.id).toBe('prod-2');
    });
  });

  describe('clearCart', () => {
    it('removes all items and clears localStorage', () => {
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(mockProduct);
        result.current.addToCart(mockProductNoDiscount);
      });
      act(() => {
        result.current.clearCart();
      });

      expect(result.current.cartItems).toHaveLength(0);
      // Note: the useEffect re-saves the empty cart as '[]' after clearCart
      const saved = localStorage.getItem('peptide_cart');
      expect(saved === null || saved === '[]').toBe(true);
    });
  });

  describe('getTotalPrice', () => {
    it('calculates total for PHP items only', () => {
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(mockProduct, undefined, 2); // 2000 * 2 = 4000
      });

      expect(result.current.getTotalPrice()).toBe(4000);
    });

    it('excludes USD items from PHP total', () => {
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(
          mockProduct, undefined, 1, undefined,
          'box', 'preorder', 2500, 'PHP'
        );
      });
      act(() => {
        result.current.addToCart(
          mockProduct, undefined, 1, undefined,
          'box', 'preorder', 45, 'USD'
        );
      });

      expect(result.current.getTotalPrice()).toBe(2500);
    });

    it('returns 0 for empty cart', () => {
      const { result } = renderHook(() => useCart());
      expect(result.current.getTotalPrice()).toBe(0);
    });
  });

  describe('getTotalUSD', () => {
    it('calculates total for USD items', () => {
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(
          mockProduct, undefined, 2, undefined,
          'box', 'preorder', 45, 'USD'
        );
      });

      expect(result.current.getTotalUSD()).toBe(90);
    });

    it('returns 0 when no USD items', () => {
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(mockProduct);
      });

      expect(result.current.getTotalUSD()).toBe(0);
    });
  });

  describe('getTotalItems', () => {
    it('sums all item quantities', () => {
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(mockProduct, undefined, 3);
      });
      act(() => {
        result.current.addToCart(mockProductNoDiscount, undefined, 2);
      });

      expect(result.current.getTotalItems()).toBe(5);
    });
  });

  describe('localStorage persistence', () => {
    it('saves cart to localStorage when items change', () => {
      const { result } = renderHook(() => useCart());

      act(() => {
        result.current.addToCart(mockProduct);
      });

      const saved = JSON.parse(localStorage.getItem('peptide_cart') || '[]');
      expect(saved).toHaveLength(1);
      expect(saved[0].product.id).toBe('prod-1');
    });
  });
});
