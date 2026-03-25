import type { Product, ProductVariation, ProductPrice, CartItem } from '../types';

export const mockProduct: Product = {
  id: 'prod-1',
  name: 'BPC-157',
  description: 'Body Protection Compound',
  category: 'peptides',
  base_price: 84.23,
  discount_price: 70,
  discount_start_date: null,
  discount_end_date: null,
  discount_active: true,
  code: 'BPC157',
  spec: '5mg',
  units_per_pack: 10,
  unit_type: 'vials',
  region_restriction: null,
  onhand_available: true,
  preorder_available: true,
  notes: null,
  purity_percentage: 99.5,
  molecular_weight: '1419.53',
  cas_number: '137525-51-0',
  sequence: 'Gly-Glu-Pro-Pro-Pro-Gly-Lys-Pro-Ala-Asp-Asp-Ala-Gly-Leu-Val',
  storage_conditions: 'Store at -20C',
  inclusions: ['Certificate of Analysis', 'Bacteriostatic Water'],
  stock_quantity: 50,
  available: true,
  featured: true,
  image_url: null,
  safety_sheet_url: null,
  created_at: '2024-01-01T00:00:00Z',
  updated_at: '2024-01-01T00:00:00Z',
  variations: [],
  prices: [],
};

export const mockProductNoDiscount: Product = {
  ...mockProduct,
  id: 'prod-2',
  name: 'TB-500',
  discount_active: false,
  discount_price: null,
  stock_quantity: 5,
  preorder_available: false,
};

export const mockProductOutOfStock: Product = {
  ...mockProduct,
  id: 'prod-3',
  name: 'GHK-Cu',
  stock_quantity: 0,
};

export const mockProductPHOnly: Product = {
  ...mockProduct,
  id: 'prod-4',
  name: 'PH-Only Peptide',
  region_restriction: 'PH',
};

export const mockVariation: ProductVariation = {
  id: 'var-1',
  product_id: 'prod-1',
  name: '5mg',
  quantity_mg: 5,
  price: 84.23,
  disposable_pen_price: 95,
  reusable_pen_price: 90,
  discount_price: 70,
  discount_active: false,
  stock_quantity: 20,
  created_at: '2024-01-01T00:00:00Z',
};

export const mockVariationOutOfStock: ProductVariation = {
  ...mockVariation,
  id: 'var-2',
  name: '10mg',
  quantity_mg: 10,
  price: 99.44,
  stock_quantity: 0,
};

export const mockPrices: ProductPrice[] = [
  {
    id: 'price-1',
    product_id: 'prod-1',
    price_type: 'preorder_box',
    currency: 'USD',
    amount: 84.23,
    min_qty: 1,
    max_qty: null,
    is_override: false,
    created_at: '2024-01-01T00:00:00Z',
    updated_at: '2024-01-01T00:00:00Z',
  },
  {
    id: 'price-2',
    product_id: 'prod-1',
    price_type: 'onhand_box',
    currency: 'USD',
    amount: 100,
    min_qty: 1,
    max_qty: null,
    is_override: false,
    created_at: '2024-01-01T00:00:00Z',
    updated_at: '2024-01-01T00:00:00Z',
  },
  {
    id: 'price-3',
    product_id: 'prod-1',
    price_type: 'preorder_vial',
    currency: 'USD',
    amount: 10,
    min_qty: 1,
    max_qty: null,
    is_override: false,
    created_at: '2024-01-01T00:00:00Z',
    updated_at: '2024-01-01T00:00:00Z',
  },
  {
    id: 'price-4',
    product_id: 'prod-1',
    price_type: 'onhand_vial',
    currency: 'USD',
    amount: 12,
    min_qty: 1,
    max_qty: null,
    is_override: false,
    created_at: '2024-01-01T00:00:00Z',
    updated_at: '2024-01-01T00:00:00Z',
  },
  {
    id: 'price-5',
    product_id: 'prod-1',
    price_type: 'complete_set',
    currency: 'USD',
    amount: 150,
    min_qty: 1,
    max_qty: null,
    is_override: false,
    created_at: '2024-01-01T00:00:00Z',
    updated_at: '2024-01-01T00:00:00Z',
  },
];

export const mockProductWithPrices: Product = {
  ...mockProduct,
  prices: mockPrices,
};

export const mockCartItem: CartItem = {
  product: mockProduct,
  quantity: 2,
  price: 70,
  currency: 'USD',
};

export const mockCartItemUSD: CartItem = {
  product: mockProduct,
  quantity: 1,
  price: 45,
  currency: 'USD',
};

export const mockCartItemWithVariation: CartItem = {
  product: mockProduct,
  variation: mockVariation,
  quantity: 1,
  price: 84.23,
  currency: 'USD',
};
