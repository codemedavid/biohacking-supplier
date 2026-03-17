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
    it('formats PHP price with peso sign and no decimals', () => {
      expect(formatPrice(2500)).toBe('₱2,500');
    });

    it('formats zero price', () => {
      expect(formatPrice(0)).toBe('₱0');
    });

    it('formats large prices with commas', () => {
      expect(formatPrice(1000000)).toBe('₱1,000,000');
    });

    it('truncates decimal portion', () => {
      const result = formatPrice(2500.99);
      expect(result).not.toContain('.99');
    });
  });

  describe('formatPriceWithDecimals', () => {
    it('formats PHP price with two decimal places', () => {
      expect(formatPriceWithDecimals(2500)).toBe('₱2,500.00');
    });

    it('preserves decimal values', () => {
      expect(formatPriceWithDecimals(99.5)).toBe('₱99.50');
    });

    it('formats zero with decimals', () => {
      expect(formatPriceWithDecimals(0)).toBe('₱0.00');
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
    it('delegates to formatUSD for USD currency', () => {
      expect(formatCurrency(45, 'USD')).toBe('$45.00');
    });

    it('delegates to formatPriceWithDecimals for PHP currency', () => {
      expect(formatCurrency(2500, 'PHP')).toBe('₱2,500.00');
    });
  });

  describe('constants', () => {
    it('has correct currency symbol', () => {
      expect(CURRENCY_SYMBOL).toBe('₱');
    });

    it('has correct currency code', () => {
      expect(CURRENCY_CODE).toBe('PHP');
    });
  });
});
