-- Migration: Add multi-pricing support (preorder/onhand, box/vial/complete_set)
-- Run this in your Supabase SQL Editor

-- 1. Add new columns to products table
ALTER TABLE products
  ADD COLUMN IF NOT EXISTS code TEXT,
  ADD COLUMN IF NOT EXISTS spec TEXT,
  ADD COLUMN IF NOT EXISTS units_per_pack INTEGER DEFAULT 10,
  ADD COLUMN IF NOT EXISTS unit_type TEXT DEFAULT 'vials',
  ADD COLUMN IF NOT EXISTS region_restriction TEXT DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS onhand_available BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS preorder_available BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS notes TEXT DEFAULT NULL;

-- 2. Create product_prices table
CREATE TABLE IF NOT EXISTS product_prices (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  price_type TEXT NOT NULL CHECK (price_type IN ('preorder_box', 'preorder_vial', 'onhand_box', 'onhand_vial', 'complete_set')),
  currency TEXT NOT NULL DEFAULT 'PHP' CHECK (currency IN ('USD', 'PHP')),
  amount NUMERIC(12,4) NOT NULL,
  min_qty INTEGER DEFAULT 1,
  max_qty INTEGER DEFAULT NULL,
  is_override BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(product_id, price_type, currency, min_qty)
);

-- 3. Create index for fast lookups
CREATE INDEX IF NOT EXISTS idx_product_prices_product_id ON product_prices(product_id);
CREATE INDEX IF NOT EXISTS idx_product_prices_type ON product_prices(price_type);

-- 4. Enable RLS on product_prices
ALTER TABLE product_prices ENABLE ROW LEVEL SECURITY;

-- 5. Create RLS policies (read for everyone, write for authenticated)
CREATE POLICY "Anyone can read product_prices"
  ON product_prices FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can manage product_prices"
  ON product_prices FOR ALL
  USING (true)
  WITH CHECK (true);

-- 6. Enable realtime for product_prices
ALTER PUBLICATION supabase_realtime ADD TABLE product_prices;

-- Example: Insert pricing for a product
-- INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES
--   ('product-uuid', 'preorder_box', 'USD', 88.03),
--   ('product-uuid', 'preorder_box', 'PHP', 5281.80),
--   ('product-uuid', 'preorder_vial', 'PHP', 580.998),
--   ('product-uuid', 'onhand_box', 'PHP', 6866.34),
--   ('product-uuid', 'onhand_vial', 'PHP', 823.9608),
--   ('product-uuid', 'complete_set', 'PHP', 1138.9608);
