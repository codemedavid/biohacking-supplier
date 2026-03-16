// Currency formatting utilities

export function formatPrice(price: number): string {
  return `₱${price.toLocaleString('en-PH', {
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  })}`;
}

export function formatPriceWithDecimals(price: number): string {
  return `₱${price.toLocaleString('en-PH', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })}`;
}

export function formatUSD(price: number): string {
  return `$${price.toLocaleString('en-US', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })}`;
}

export function formatCurrency(price: number, currency: 'USD' | 'PHP'): string {
  if (currency === 'USD') return formatUSD(price);
  return formatPriceWithDecimals(price);
}

export const CURRENCY_SYMBOL = '₱';
export const CURRENCY_CODE = 'PHP';
