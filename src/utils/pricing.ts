import type { Product, ProductPrice, StructuredPricing, PurchaseMode, FulfillmentType, PriceType, CurrencyCode } from '../types';

/**
 * Build structured pricing map from flat ProductPrice rows
 */
export function buildStructuredPricing(prices: ProductPrice[]): StructuredPricing {
  const structured: StructuredPricing = {};

  for (const p of prices) {
    switch (p.price_type) {
      case 'preorder_box':
        if (!structured.preorder_box) structured.preorder_box = {};
        structured.preorder_box.usd = p.amount;
        break;
      case 'preorder_vial':
        if (!structured.preorder_vial) structured.preorder_vial = {};
        structured.preorder_vial.usd = p.amount;
        break;
      case 'onhand_box':
        if (!structured.onhand_box) structured.onhand_box = {};
        structured.onhand_box.usd = p.amount;
        break;
      case 'onhand_vial':
        if (!structured.onhand_vial) structured.onhand_vial = {};
        structured.onhand_vial.usd = p.amount;
        break;
      case 'complete_set':
        if (!structured.complete_set) structured.complete_set = {};
        structured.complete_set.usd = p.amount;
        break;
    }
  }

  return structured;
}

/**
 * Get the PriceType key from purchase mode + fulfillment type
 */
export function getPriceType(purchaseMode: PurchaseMode, fulfillmentType: FulfillmentType): PriceType {
  if (purchaseMode === 'complete_set') return 'complete_set';
  return `${fulfillmentType}_${purchaseMode}` as PriceType;
}

/**
 * Check if a product has multi-pricing (product_prices rows)
 */
export function hasMultiPricing(product: Product): boolean {
  return !!(product.prices && product.prices.length > 0);
}

/**
 * Get available purchase modes for a product
 */
export function getAvailablePurchaseModes(product: Product): PurchaseMode[] {
  if (!product.prices || product.prices.length === 0) return [];

  const modes: PurchaseMode[] = [];
  const hasBox = product.prices.some(p => p.price_type.endsWith('_box'));
  const hasVial = product.prices.some(p => p.price_type.endsWith('_vial'));
  const hasCompleteSet = product.prices.some(p => p.price_type === 'complete_set');

  if (hasBox) modes.push('box');
  if (hasVial) modes.push('vial');
  if (hasCompleteSet) modes.push('complete_set');

  return modes;
}

/**
 * Get available fulfillment types for a product and purchase mode
 */
export function getAvailableFulfillmentTypes(product: Product, purchaseMode: PurchaseMode): FulfillmentType[] {
  if (!product.prices || product.prices.length === 0) return [];
  if (purchaseMode === 'complete_set') return ['onhand']; // complete_set is always on-hand

  const types: Set<FulfillmentType> = new Set();
  for (const p of product.prices) {
    if (purchaseMode === 'box') {
      if (p.price_type === 'preorder_box') types.add('preorder');
      if (p.price_type === 'onhand_box') types.add('onhand');
    }
    if (purchaseMode === 'vial') {
      if (p.price_type === 'preorder_vial') types.add('preorder');
      if (p.price_type === 'onhand_vial') types.add('onhand');
    }
  }

  // Respect product-level availability flags
  if (!product.preorder_available) types.delete('preorder');
  if (!product.onhand_available) types.delete('onhand');

  // Philippines-only products: no preorder international
  if (product.region_restriction === 'PH') {
    types.delete('preorder');
  }

  return Array.from(types);
}

/**
 * Get price for a specific purchase mode + fulfillment type
 * Returns { usd?: number }
 */
export function getPriceForSelection(
  product: Product,
  purchaseMode: PurchaseMode,
  fulfillmentType: FulfillmentType
): { usd?: number } {
  if (!product.prices || product.prices.length === 0) return {};

  const priceType = getPriceType(purchaseMode, fulfillmentType);
  const result: { usd?: number } = {};

  for (const p of product.prices) {
    if (p.price_type === priceType) {
      result.usd = p.amount;
    }
  }

  return result;
}

/**
 * Get the primary display price (USD)
 */
export function getPrimaryPrice(
  product: Product,
  purchaseMode: PurchaseMode,
  fulfillmentType: FulfillmentType
): { amount: number; currency: CurrencyCode } | null {
  const prices = getPriceForSelection(product, purchaseMode, fulfillmentType);

  if (prices.usd !== undefined) return { amount: prices.usd, currency: 'USD' };
  return null;
}

/**
 * Get label for purchase mode
 */
export function getPurchaseModeLabel(mode: PurchaseMode): string {
  switch (mode) {
    case 'box': return 'Per Box';
    case 'vial': return 'Per Vial';
    case 'complete_set': return 'Complete Set';
  }
}

/**
 * Get label for fulfillment type
 */
export function getFulfillmentTypeLabel(type: FulfillmentType): string {
  switch (type) {
    case 'preorder': return 'Pre-order / Group Buy';
    case 'onhand': return 'On-hand PH Warehouse';
  }
}
