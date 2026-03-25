import { describe, it, expect } from 'vitest';
import {
  buildStructuredPricing,
  getPriceType,
  hasMultiPricing,
  getAvailablePurchaseModes,
  getAvailableFulfillmentTypes,
  getPriceForSelection,
  getPrimaryPrice,
  getPurchaseModeLabel,
  getFulfillmentTypeLabel,
} from '../pricing';
import {
  mockProduct,
  mockProductWithPrices,
  mockProductPHOnly,
  mockProductNoDiscount,
  mockPrices,
} from '../../test/fixtures';

describe('pricing utilities', () => {
  describe('buildStructuredPricing', () => {
    it('builds structured pricing from flat price rows', () => {
      const result = buildStructuredPricing(mockPrices);

      expect(result.preorder_box).toEqual({ usd: 84.23 });
      expect(result.onhand_box).toEqual({ usd: 100 });
      expect(result.preorder_vial).toEqual({ usd: 10 });
      expect(result.onhand_vial).toEqual({ usd: 12 });
      expect(result.complete_set).toEqual({ usd: 150 });
    });

    it('returns empty object for empty price array', () => {
      const result = buildStructuredPricing([]);
      expect(result).toEqual({});
    });

    it('handles single price type', () => {
      const result = buildStructuredPricing([mockPrices[0]]);
      expect(result.preorder_box).toEqual({ usd: 84.23 });
      expect(result.onhand_box).toBeUndefined();
    });
  });

  describe('getPriceType', () => {
    it('returns complete_set for complete_set purchase mode', () => {
      expect(getPriceType('complete_set', 'onhand')).toBe('complete_set');
      expect(getPriceType('complete_set', 'preorder')).toBe('complete_set');
    });

    it('combines fulfillment type and purchase mode for box', () => {
      expect(getPriceType('box', 'preorder')).toBe('preorder_box');
      expect(getPriceType('box', 'onhand')).toBe('onhand_box');
    });

    it('combines fulfillment type and purchase mode for vial', () => {
      expect(getPriceType('vial', 'preorder')).toBe('preorder_vial');
      expect(getPriceType('vial', 'onhand')).toBe('onhand_vial');
    });
  });

  describe('hasMultiPricing', () => {
    it('returns true when product has prices', () => {
      expect(hasMultiPricing(mockProductWithPrices)).toBe(true);
    });

    it('returns false when product has no prices', () => {
      expect(hasMultiPricing(mockProduct)).toBe(false);
    });

    it('returns false when prices is undefined', () => {
      const product = { ...mockProduct, prices: undefined };
      expect(hasMultiPricing(product)).toBe(false);
    });
  });

  describe('getAvailablePurchaseModes', () => {
    it('returns all purchase modes from product prices', () => {
      const modes = getAvailablePurchaseModes(mockProductWithPrices);
      expect(modes).toContain('box');
      expect(modes).toContain('vial');
      expect(modes).toContain('complete_set');
    });

    it('returns empty array when no prices', () => {
      expect(getAvailablePurchaseModes(mockProduct)).toEqual([]);
    });

    it('returns only modes present in prices', () => {
      const product = {
        ...mockProduct,
        prices: [mockPrices[0]], // only preorder_box
      };
      const modes = getAvailablePurchaseModes(product);
      expect(modes).toContain('box');
      expect(modes).not.toContain('vial');
      expect(modes).not.toContain('complete_set');
    });
  });

  describe('getAvailableFulfillmentTypes', () => {
    it('returns both fulfillment types for box mode', () => {
      const types = getAvailableFulfillmentTypes(mockProductWithPrices, 'box');
      expect(types).toContain('preorder');
      expect(types).toContain('onhand');
    });

    it('returns both fulfillment types for vial mode', () => {
      const types = getAvailableFulfillmentTypes(mockProductWithPrices, 'vial');
      expect(types).toContain('preorder');
      expect(types).toContain('onhand');
    });

    it('returns onhand only for complete_set', () => {
      const types = getAvailableFulfillmentTypes(mockProductWithPrices, 'complete_set');
      expect(types).toEqual(['onhand']);
    });

    it('respects product-level availability flags', () => {
      const product = {
        ...mockProductWithPrices,
        preorder_available: false,
      };
      const types = getAvailableFulfillmentTypes(product, 'box');
      expect(types).not.toContain('preorder');
      expect(types).toContain('onhand');
    });

    it('respects onhand_available flag', () => {
      const product = {
        ...mockProductWithPrices,
        onhand_available: false,
      };
      const types = getAvailableFulfillmentTypes(product, 'box');
      expect(types).toContain('preorder');
      expect(types).not.toContain('onhand');
    });

    it('removes preorder for PH-only products', () => {
      const product = {
        ...mockProductPHOnly,
        prices: mockPrices,
      };
      const types = getAvailableFulfillmentTypes(product, 'box');
      expect(types).not.toContain('preorder');
    });

    it('returns empty array when no prices', () => {
      expect(getAvailableFulfillmentTypes(mockProduct, 'box')).toEqual([]);
    });
  });

  describe('getPriceForSelection', () => {
    it('returns USD price for preorder box', () => {
      const result = getPriceForSelection(mockProductWithPrices, 'box', 'preorder');
      expect(result).toEqual({ usd: 84.23 });
    });

    it('returns USD for onhand box', () => {
      const result = getPriceForSelection(mockProductWithPrices, 'box', 'onhand');
      expect(result).toEqual({ usd: 100 });
    });

    it('returns complete_set price regardless of fulfillment type', () => {
      const result = getPriceForSelection(mockProductWithPrices, 'complete_set', 'onhand');
      expect(result).toEqual({ usd: 150 });
    });

    it('returns empty object when no prices', () => {
      expect(getPriceForSelection(mockProduct, 'box', 'preorder')).toEqual({});
    });
  });

  describe('getPrimaryPrice', () => {
    it('returns USD price', () => {
      const result = getPrimaryPrice(mockProductWithPrices, 'box', 'preorder');
      expect(result).toEqual({ amount: 84.23, currency: 'USD' });
    });

    it('returns null when no matching price', () => {
      const result = getPrimaryPrice(mockProduct, 'box', 'preorder');
      expect(result).toBeNull();
    });
  });

  describe('getPurchaseModeLabel', () => {
    it('returns correct labels', () => {
      expect(getPurchaseModeLabel('box')).toBe('Per Box');
      expect(getPurchaseModeLabel('vial')).toBe('Per Vial');
      expect(getPurchaseModeLabel('complete_set')).toBe('Complete Set');
    });
  });

  describe('getFulfillmentTypeLabel', () => {
    it('returns correct labels', () => {
      expect(getFulfillmentTypeLabel('preorder')).toBe('Pre-order / Group Buy');
      expect(getFulfillmentTypeLabel('onhand')).toBe('On-hand PH Warehouse');
    });
  });
});
