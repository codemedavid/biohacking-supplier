import { describe, it, expect } from 'vitest';
import {
  formatPrice,
  formatPriceWithDecimals,
  formatUSD,
  formatCurrency,
  CURRENCY_SYMBOL,
  CURRENCY_CODE,
} from '../currency';

describe('currency utilities', () => {
  describe('formatPrice', () => {
    it('formats USD price with dollar sign and two decimals', () => {
      expect(formatPrice(2500)).toBe('$2,500.00');
    });

    it('formats zero price', () => {
      expect(formatPrice(0)).toBe('$0.00');
    });

    it('formats large prices with commas', () => {
      expect(formatPrice(1000000)).toBe('$1,000,000.00');
    });

    it('preserves decimal portion', () => {
      expect(formatPrice(2500.99)).toBe('$2,500.99');
    });
  });

  describe('formatPriceWithDecimals', () => {
    it('formats USD price with two decimal places', () => {
      expect(formatPriceWithDecimals(2500)).toBe('$2,500.00');
    });

    it('preserves decimal values', () => {
      expect(formatPriceWithDecimals(99.5)).toBe('$99.50');
    });

    it('formats zero with decimals', () => {
      expect(formatPriceWithDecimals(0)).toBe('$0.00');
    });
  });

  describe('formatUSD', () => {
    it('formats USD price with dollar sign and two decimals', () => {
      expect(formatUSD(45)).toBe('$45.00');
    });

    it('formats fractional USD amount', () => {
      expect(formatUSD(12.5)).toBe('$12.50');
    });

    it('formats large USD amount with commas', () => {
      expect(formatUSD(1234.56)).toBe('$1,234.56');
    });

    it('formats zero USD', () => {
      expect(formatUSD(0)).toBe('$0.00');
    });
  });

  describe('formatCurrency', () => {
    it('formats as USD', () => {
      expect(formatCurrency(45, 'USD')).toBe('$45.00');
    });

    it('formats as USD when no currency specified', () => {
      expect(formatCurrency(2500)).toBe('$2,500.00');
    });
  });

  describe('constants', () => {
    it('has correct currency symbol', () => {
      expect(CURRENCY_SYMBOL).toBe('$');
    });

    it('has correct currency code', () => {
      expect(CURRENCY_CODE).toBe('USD');
    });
  });
});
