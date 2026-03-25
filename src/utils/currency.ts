// Currency formatting utilities

export function formatPrice(price: number): string {
  return `$${price.toLocaleString('en-US', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })}`;
}

export function formatPriceWithDecimals(price: number): string {
  return `$${price.toLocaleString('en-US', {
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

export function formatCurrency(price: number, _currency?: 'USD'): string {
  return formatUSD(price);
}

export const CURRENCY_SYMBOL = '$';
export const CURRENCY_CODE = 'USD';
