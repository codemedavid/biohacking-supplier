// Peptide Product Types
export interface Product {
  id: string;
  name: string;
  description: string;
  category: string;
  base_price: number;
  discount_price: number | null;
  discount_start_date: string | null;
  discount_end_date: string | null;
  discount_active: boolean;

  // Product identification
  code: string | null;
  spec: string | null;
  units_per_pack: number;
  unit_type: string;

  // Availability & fulfillment
  region_restriction: string | null; // e.g. 'PH' for Philippines only
  onhand_available: boolean;
  preorder_available: boolean;
  notes: string | null;

  // Peptide-specific fields
  purity_percentage: number;
  molecular_weight: string | null;
  cas_number: string | null;
  sequence: string | null;
  storage_conditions: string;
  inclusions: string[] | null;

  // Stock and availability
  stock_quantity: number;
  available: boolean;
  featured: boolean;

  // Images and metadata
  image_url: string | null;
  safety_sheet_url: string | null;

  created_at: string;
  updated_at: string;

  // Relations
  variations?: ProductVariation[];
  prices?: ProductPrice[];
}

export interface ProductVariation {
  id: string;
  product_id: string;
  name: string;
  quantity_mg: number;
  price: number;
  // Pen type pricing - null means not available for this product
  disposable_pen_price: number | null;
  reusable_pen_price: number | null;
  discount_price: number | null;
  discount_active: boolean;
  stock_quantity: number;
  created_at: string;
}

// Multi-pricing types
export type PriceType = 'preorder_box' | 'preorder_vial' | 'onhand_box' | 'onhand_vial' | 'complete_set';
export type CurrencyCode = 'USD';
export type PurchaseMode = 'box' | 'vial' | 'complete_set';
export type FulfillmentType = 'preorder' | 'onhand';

export interface ProductPrice {
  id: string;
  product_id: string;
  price_type: PriceType;
  currency: CurrencyCode;
  amount: number;
  min_qty: number;
  max_qty: number | null;
  is_override: boolean;
  created_at: string;
  updated_at: string;
}

// Helper to get structured pricing from flat price rows
export interface StructuredPricing {
  preorder_box?: { usd?: number };
  preorder_vial?: { usd?: number };
  onhand_box?: { usd?: number };
  onhand_vial?: { usd?: number };
  complete_set?: { usd?: number };
}

export interface Category {
  id: string;
  name: string;
  icon: string;
  sort_order: number;
  active: boolean;
  created_at: string;
  updated_at: string;
}

export interface PaymentMethod {
  id: string;
  name: string;
  account_number: string;
  account_name: string;
  qr_code_url: string;
  active: boolean;
  sort_order: number;
  created_at: string;
  updated_at: string;
}

export interface SiteSetting {
  id: string;
  value: string;
  type: string;
  description: string | null;
  updated_at: string;
}

export interface SiteSettings {
  site_name: string;
  site_logo: string;
  site_description: string;
  currency: string;
  currency_code: string;
  hero_badge_text?: string;
  hero_title_prefix?: string;
  hero_title_highlight?: string;
  hero_title_suffix?: string;
  hero_subtext?: string;
  hero_tagline?: string;
  hero_description?: string;
  hero_accent_color?: string;
}

// Pen Type Options (for injectable products)
export type PenType = 'disposable' | 'reusable' | null;

// Cart Types
export interface CartItem {
  product: Product;
  variation?: ProductVariation;
  quantity: number;
  price: number;
  penType?: PenType;
  // Multi-pricing fields
  purchaseMode?: PurchaseMode;
  fulfillmentType?: FulfillmentType;
  currency?: CurrencyCode;
}

// Order Types
export interface OrderDetails {
  customer_name: string;
  customer_email: string;
  customer_phone: string;
  shipping_address: string;
  payment_method: string;
  notes?: string;
  promo_code?: string;
  discount_applied?: number;
}

export interface PromoCode {
  id: string;
  code: string;
  discount_type: 'percentage' | 'fixed';
  discount_value: number;
  min_purchase_amount: number;
  max_discount_amount?: number;
  start_date?: string;
  end_date?: string;
  usage_limit?: number;
  usage_count: number;
  active: boolean;
  created_at: string;
}
