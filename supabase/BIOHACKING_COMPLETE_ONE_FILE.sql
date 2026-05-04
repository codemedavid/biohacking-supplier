-- ============================================================================
-- BIOHACKING WEBSITE - COMPLETE ONE FILE SUPABASE SETUP
-- Generated from existing Peptide Pulse / MJ Biohacking SQL fragments.
-- Run this whole file in Supabase SQL Editor for schema + products + prices + images.
-- ============================================================================

-- SECTION 1: Base Peptide Pulse schema, storage, seed settings, couriers, orders

-- ============================================================================
-- PEPTIDE PULSE - MASTER REPLICATION SCRIPT
-- ============================================================================
-- 
-- DESCRIPTION:
-- This script contains ALL necessary SQL to set up the Biohacking Supplier database
-- from scratch. It includes:
-- 1. Tables (Categories, Products, Orders, etc.)
-- 2. RLS Policies & Security
-- 3. Storage Buckets (Images, Payment Proofs)
-- 4. Initial Seed Data (Products, Couriers, Shipping Rates)
-- 5. Helper Functions & RPCs
--
-- INSTRUCTIONS:
-- 1. Go to your Supabase Project -> SQL Editor
-- 2. Paste this entire file
-- 3. Click "RUN"
--
-- ============================================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- 1. HELPER FUNCTIONS
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 2. TABLES & SCHEMA
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 2.1 Categories
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    icon TEXT,
    sort_order INTEGER DEFAULT 0,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.categories DISABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE public.categories TO anon, authenticated, service_role;

-- ----------------------------------------------------------------------------
-- 2.2 Products
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT DEFAULT 'Uncategorized',
    base_price DECIMAL(10, 2) NOT NULL DEFAULT 0,
    discount_price DECIMAL(10, 2),
    discount_start_date TIMESTAMP WITH TIME ZONE,
    discount_end_date TIMESTAMP WITH TIME ZONE,
    discount_active BOOLEAN DEFAULT false,
    purity_percentage DECIMAL(5, 2) DEFAULT 99.0,
    molecular_weight TEXT,
    cas_number TEXT,
    sequence TEXT,
    storage_conditions TEXT DEFAULT 'Store at -20°C',
    inclusions TEXT[],
    stock_quantity INTEGER DEFAULT 0,
    available BOOLEAN DEFAULT true,
    featured BOOLEAN DEFAULT false,
    image_url TEXT,
    safety_sheet_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.products DISABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE public.products TO anon, authenticated, service_role;

-- ----------------------------------------------------------------------------
-- 2.3 Product Variations
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.product_variations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    quantity_mg DECIMAL(10, 2) NOT NULL DEFAULT 0,
    price DECIMAL(10, 2) NOT NULL DEFAULT 0,
    discount_price DECIMAL(10, 2),
    discount_active BOOLEAN DEFAULT false,
    stock_quantity INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.product_variations DISABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE public.product_variations TO anon, authenticated, service_role;

-- ----------------------------------------------------------------------------
-- 2.4 Site Settings
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.site_settings (
    id TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'text',
    description TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.site_settings DISABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE public.site_settings TO anon, authenticated, service_role;

DROP TRIGGER IF EXISTS update_site_settings_updated_at ON public.site_settings;
CREATE TRIGGER update_site_settings_updated_at
    BEFORE UPDATE ON public.site_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ----------------------------------------------------------------------------
-- 2.5 Payment Methods
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.payment_methods (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    account_number TEXT,
    account_name TEXT,
    qr_code_url TEXT,
    active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.payment_methods DISABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE public.payment_methods TO anon, authenticated, service_role;

-- ----------------------------------------------------------------------------
-- 2.6 Shipping Locations
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.shipping_locations (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    fee NUMERIC(10,2) NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    order_index INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.shipping_locations DISABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE public.shipping_locations TO anon, authenticated, service_role;

-- ----------------------------------------------------------------------------
-- 2.7 Couriers (New)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.couriers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    code TEXT NOT NULL UNIQUE, -- e.g. 'jnt', 'lbc', 'lalamove'
    name TEXT NOT NULL,
    tracking_url_template TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.couriers DISABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE public.couriers TO anon, authenticated, service_role;

-- ----------------------------------------------------------------------------
-- 2.8 Promo Codes
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.promo_codes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    discount_type TEXT NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
    discount_value DECIMAL(10, 2) NOT NULL,
    min_purchase_amount DECIMAL(10, 2) DEFAULT 0,
    max_discount_amount DECIMAL(10, 2),
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    usage_limit INTEGER,
    usage_count INTEGER DEFAULT 0,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.promo_codes DISABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE public.promo_codes TO anon, authenticated, service_role;

-- ----------------------------------------------------------------------------
-- 2.9 Orders
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_name TEXT NOT NULL,
    customer_email TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    contact_method TEXT DEFAULT 'phone',
    shipping_address TEXT NOT NULL,
    shipping_city TEXT,
    shipping_state TEXT,
    shipping_zip_code TEXT,
    shipping_country TEXT DEFAULT 'Philippines',
    shipping_barangay TEXT,
    shipping_region TEXT,
    shipping_location TEXT, -- New field
    courier_id UUID,        -- New field
    shipping_fee DECIMAL(10, 2) DEFAULT 0,
    order_items JSONB NOT NULL,
    subtotal DECIMAL(10, 2),
    total_price DECIMAL(10, 2) NOT NULL,
    pricing_mode TEXT DEFAULT 'PHP',
    payment_method_id TEXT,
    payment_method_name TEXT,
    payment_status TEXT DEFAULT 'pending',
    payment_proof_url TEXT,
    promo_code_id UUID REFERENCES public.promo_codes(id),
    promo_code TEXT,
    discount_applied DECIMAL(10, 2) DEFAULT 0,
    order_status TEXT DEFAULT 'new',
    notes TEXT,
    admin_notes TEXT,
    tracking_number TEXT,
    tracking_courier TEXT, -- Legacy, mostly replaced by courier_id logic
    shipping_provider TEXT, -- Legacy/redundant, kept for compatibility if needed
    shipping_note TEXT,
    shipped_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_orders_customer_email ON public.orders(customer_email);
CREATE INDEX IF NOT EXISTS idx_orders_customer_phone ON public.orders(customer_phone);
CREATE INDEX IF NOT EXISTS idx_orders_order_status ON public.orders(order_status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON public.orders(created_at DESC);

ALTER TABLE public.orders DISABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE public.orders TO anon, authenticated, service_role;

DROP TRIGGER IF EXISTS update_orders_updated_at ON public.orders;
CREATE TRIGGER update_orders_updated_at
    BEFORE UPDATE ON public.orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ----------------------------------------------------------------------------
-- 2.10 COA Reports
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.coa_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_name TEXT NOT NULL,
    batch TEXT,
    test_date DATE NOT NULL,
    purity_percentage DECIMAL(5,3) NOT NULL,
    quantity TEXT NOT NULL,
    task_number TEXT NOT NULL,
    verification_key TEXT NOT NULL,
    image_url TEXT NOT NULL,
    featured BOOLEAN DEFAULT false,
    manufacturer TEXT DEFAULT 'Biohacking Supplier',
    laboratory TEXT DEFAULT 'Janoshik Analytical',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.coa_reports DISABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE public.coa_reports TO anon, authenticated, service_role;

-- ----------------------------------------------------------------------------
-- 2.11 FAQs
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.faqs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'GENERAL',
    order_index INTEGER NOT NULL DEFAULT 1,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.faqs DISABLE ROW LEVEL SECURITY;
GRANT ALL ON TABLE public.faqs TO anon, authenticated, service_role;

-- ============================================================================
-- 3. STORAGE BUCKETS
-- ============================================================================

-- Helper to safely create policies
DO $$
BEGIN
    -- Payment Proofs
    INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
    VALUES ('payment-proofs', 'payment-proofs', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif'])
    ON CONFLICT (id) DO NOTHING;

    -- Product Images
    INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
    VALUES ('product-images', 'product-images', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif'])
    ON CONFLICT (id) DO NOTHING;

    -- Article Covers
    INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
    VALUES ('article-covers', 'article-covers', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp'])
    ON CONFLICT (id) DO NOTHING;

    -- Menu Images
    INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
    VALUES ('menu-images', 'menu-images', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp'])
    ON CONFLICT (id) DO NOTHING;
END $$;

-- Create Storage Policies (Simplified for Public Access)
DROP POLICY IF EXISTS "Public Select" ON storage.objects;
CREATE POLICY "Public Select" ON storage.objects FOR SELECT TO public USING (true);

DROP POLICY IF EXISTS "Public Insert" ON storage.objects;
CREATE POLICY "Public Insert" ON storage.objects FOR INSERT TO public WITH CHECK (true);

DROP POLICY IF EXISTS "Public Update" ON storage.objects;
CREATE POLICY "Public Update" ON storage.objects FOR UPDATE TO public USING (true);

-- ============================================================================
-- 4. SEED DATA
-- ============================================================================

-- 4.1 Site Settings
INSERT INTO public.site_settings (id, value, type, description) VALUES
('site_name', 'Biohacking Supplier', 'text', 'The name of the website'),
('site_logo', '/assets/logo.jpeg', 'image', 'The logo image URL for the site'),
('site_description', 'Premium Peptide Solutions', 'text', 'Short description of the site'),
('currency', '₱', 'text', 'Currency symbol for prices'),
('hero_title_prefix', 'Premium', 'text', 'Hero title prefix'),
('hero_title_highlight', 'Peptides', 'text', 'Hero title highlighted word'),
('hero_title_suffix', '& Essentials', 'text', 'Hero title suffix'),
('coa_page_enabled', 'true', 'boolean', 'Enable/disable the COA page')
ON CONFLICT (id) DO NOTHING;

-- 4.2 Categories
INSERT INTO public.categories (id, name, sort_order, icon, active) VALUES
('c0a80121-0001-4e78-94f8-585d77059001', 'Peptides', 1, 'FlaskConical', true),
('c0a80121-0002-4e78-94f8-585d77059002', 'Weight Management', 2, 'Scale', true),
('c0a80121-0003-4e78-94f8-585d77059003', 'Beauty & Anti-Aging', 3, 'Sparkles', true),
('c0a80121-0004-4e78-94f8-585d77059004', 'Wellness & Vitality', 4, 'Heart', true),
('c0a80121-0005-4e78-94f8-585d77059005', 'GLP-1 Agonists', 5, 'Pill', true),
('c0a80121-0006-4e78-94f8-585d77059006', 'Insulin Pens', 6, 'Syringe', true),
('c0a80121-0007-4e78-94f8-585d77059007', 'Accessories', 7, 'Package', true),
('c0a80121-0008-4e78-94f8-585d77059008', 'Bundles & Kits', 8, 'Gift', true)
ON CONFLICT (id) DO NOTHING;

-- 4.3 Couriers (Seed Data)
INSERT INTO public.couriers (code, name, tracking_url_template, is_active) VALUES
('lbc', 'LBC Express', 'https://www.lbcexpress.com/track/?tracking_no={tracking}', true),
('jnt', 'J&T Express', 'https://www.jtexpress.ph/index/query/gzquery.html?bills={tracking}', true),
('lalamove', 'Lalamove', NULL, true),
('grab', 'Grab Express', NULL, true),
('maxim', 'Maxim', NULL, true)
ON CONFLICT (code) DO NOTHING;

-- 4.4 Shipping Rates
-- Clear old generic ones if any
DELETE FROM shipping_locations WHERE id IN ('NCR', 'LUZON', 'VISAYAS_MINDANAO');

INSERT INTO shipping_locations (id, name, fee, is_active, order_index) VALUES
('LBC_METRO_MANILA', 'LBC - Metro Manila', 150.00, true, 1),
('LBC_LUZON',        'LBC - Luzon (Provincial)', 200.00, true, 2),
('LBC_VISMIN',       'LBC - Visayas & Mindanao', 250.00, true, 3),
('JNT_METRO_MANILA', 'J&T - Metro Manila', 120.00, true, 4),
('JNT_PROVINCIAL',   'J&T - Provincial', 180.00, true, 5),
('LALAMOVE_STANDARD', 'Lalamove (Book Yourself / Rider)', 0.00, true, 6),
('MAXIM_STANDARD',    'Maxim (Book Yourself / Rider)', 0.00, true, 7)
ON CONFLICT (id) DO UPDATE SET fee = EXCLUDED.fee;

-- 4.5 Payment Methods
INSERT INTO public.payment_methods (id, name, account_number, account_name, active, sort_order) VALUES
('gcash', 'GCash', '', 'Biohacking Supplier', true, 1),
('bdo', 'BDO', '', 'Biohacking Supplier', true, 2),
('security-bank', 'Security Bank', '', 'Biohacking Supplier', true, 3)
ON CONFLICT (id) DO NOTHING;

-- 4.6 Remove legacy sample products
-- These old demo rows used non-business variation options. The real MJ import
-- starts in Section 3.
DELETE FROM public.products
WHERE id IN (
  'a1a20001-0001-4e78-94f8-585d77059001',
  'a1a20002-0002-4e78-94f8-585d77059002',
  'a1a20003-0003-4e78-94f8-585d77059003'
);

-- ============================================================================
-- 5. RPC FUNCTIONS
-- ============================================================================

-- Function to get order details including promo code info
CREATE OR REPLACE FUNCTION get_order_details(p_order_id UUID)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'id', o.id,
        'customer_name', o.customer_name,
        'customer_email', o.customer_email,
        'customer_phone', o.customer_phone,
        'shipping_address', o.shipping_address,
        'shipping_city', o.shipping_city,
        'shipping_fee', o.shipping_fee,
        'total_price', o.total_price,
        'discount_applied', o.discount_applied,
        'promo_code', o.promo_code,
        'payment_status', o.payment_status,
        'order_status', o.order_status,
        'created_at', o.created_at,
        'items', o.order_items,
        'tracking_number', o.tracking_number,
        'shipping_provider', o.shipping_provider,
        'courier_code', c.code,
        'courier_name', c.name,
        'tracking_url_template', c.tracking_url_template
    ) INTO result
    FROM orders o
    LEFT JOIN couriers c ON o.courier_id = c.id
    WHERE o.id = p_order_id;

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ============================================================================
-- 6. FINAL CLEANUP
-- ============================================================================

-- Reload schema cache to ensure all changes verify
NOTIFY pgrst, 'reload schema';



-- SECTION 2: Product catalog columns and multi-pricing table

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
CREATE UNIQUE INDEX IF NOT EXISTS idx_products_code_spec_unique
  ON public.products (code, spec)
  WHERE code IS NOT NULL AND spec IS NOT NULL;

-- 4. Enable RLS on product_prices
ALTER TABLE product_prices ENABLE ROW LEVEL SECURITY;

-- 5. Create RLS policies (read for everyone, write for authenticated)
DROP POLICY IF EXISTS "Anyone can read product_prices" ON product_prices;
CREATE POLICY "Anyone can read product_prices"
  ON product_prices FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Authenticated users can manage product_prices" ON product_prices;
CREATE POLICY "Authenticated users can manage product_prices"
  ON product_prices FOR ALL
  USING (true)
  WITH CHECK (true);

-- 6. Enable realtime for product_prices
DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE product_prices;
EXCEPTION WHEN duplicate_object OR undefined_object THEN
  NULL;
END $$;

-- Example: Insert pricing for a product
-- INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES
--   ('product-uuid', 'preorder_box', 'USD', 88.03),
--   ('product-uuid', 'preorder_box', 'PHP', 5281.80),
--   ('product-uuid', 'preorder_vial', 'PHP', 580.998),
--   ('product-uuid', 'onhand_box', 'PHP', 6866.34),
--   ('product-uuid', 'onhand_vial', 'PHP', 823.9608),
--   ('product-uuid', 'complete_set', 'PHP', 1138.9608);


-- SECTION 3: Full MJ biohacking supplier pricelist import: products, variations, prices

-- Migration: Bulk import products from MJ Resellers Pricelist
-- Generated from spreadsheet data - 75 products with variations and multi-pricing
-- Run this in your Supabase SQL Editor

DO $$
DECLARE
  pid UUID;
BEGIN

  -- === Semaglutide ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Semaglutide', 'GLP-1 receptor agonist peptide for metabolic research. Available in multiple dosages.', 'research', 493.61, 99.0, 100, true, true, 'Store at -20°C, protect from light', 'SM2', '2mg*10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Semaglutide' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '2mg', 2.0, 493.61, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5mg', 5.0, 518.69, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10mg', 10.0, 581.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '15mg', 15.0, 644.23, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '20mg', 20.0, 719.47, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '30mg', 30.0, 832.00, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 74.7900);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 4487.4000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 493.6140);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 5833.6200);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 700.0344);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1015.0344);

  -- === Tirzepatide ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Tirzepatide', 'Dual GIP/GLP-1 receptor agonist peptide for advanced metabolic studies.', 'research', 530.77, 99.0, 100, true, true, 'Store at -20°C, protect from light', 'TR5', '5mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Tirzepatide' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5mg', 5.0, 530.77, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10mg', 10.0, 594.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '15mg', 15.0, 681.38, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '20mg', 20.0, 756.69, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '30mg', 30.0, 870.08, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '40mg', 40.0, 982.54, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '50mg', 50.0, 1108.07, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '60mg', 60.0, 1233.54, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '100mg', 100.0, 1839.29, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 80.4200);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 4825.2000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 530.7720);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 6272.7600);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 752.7312);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1067.7312);

  -- === Retatrutide ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Retatrutide', 'Triple-agonist GLP-1/GIP/Glucagon receptor peptide for cutting-edge research.', 'research', 619.08, 99.0, 100, true, true, 'Store at -20°C, protect from light', 'RT5', '5mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Retatrutide' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5mg', 5.0, 619.08, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10mg', 10.0, 769.69, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '15mg', 15.0, 882.16, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '20mg', 20.0, 1007.69, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '30mg', 30.0, 1271.69, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '36mg', 36.0, 1429.30, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '40mg', 40.0, 1522.62, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '50mg', 50.0, 1648.15, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '60mg', 60.0, 1773.62, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 93.8000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 5628.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 619.0800);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 7316.4000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 877.9680);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1192.9680);

  -- === BPC 157 ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('BPC 157', 'Body Protection Compound peptide known for tissue repair and recovery research.', 'research', 402.60, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'BC5', '5mg*10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'BPC 157' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5mg', 5.0, 402.60, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10mg', 10.0, 541.20, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 61.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 3660.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 402.6000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 4758.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 570.9600);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 885.9600);

  -- === TB500 (Thymosin B4 Acetate) ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('TB500 (Thymosin B4 Acetate)', 'Thymosin Beta-4 peptide studied for wound healing and tissue regeneration.', 'research', 613.80, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'BT5', '5mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'TB500 (Thymosin B4 Acetate)' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5mg', 5.0, 613.80, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10mg', 10.0, 943.80, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 93.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 5580.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 613.8000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 7254.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 870.4800);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1185.4800);

  -- === BPC 5mg + TB 5mg ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('BPC 5mg + TB 5mg', 'Combination blend of BPC-157 5mg and TB-500 5mg for synergistic recovery research.', 'research', 831.60, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'BB10', '10mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'BPC 5mg + TB 5mg' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 126.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 7560.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 831.6000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 9828.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 1179.3600);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1494.3600);

  -- === BPC 10mg + TB 10mg ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('BPC 10mg + TB 10mg', 'High-dose combination blend of BPC-157 10mg and TB-500 10mg.', 'research', 1445.40, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'BB20', '20mg*10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'BPC 10mg + TB 10mg' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 219.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 13140.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 1445.4000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 17082.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 2049.8400);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 2364.8400);

  -- === (GLOW) BPC 10mg+GHK-Cu50mg+Tb500 10mg ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('(GLOW) BPC 10mg+GHK-Cu50mg+Tb500 10mg', 'Thymosin Beta-4 peptide studied for wound healing and tissue regeneration.', 'research', 1419.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'BBG70', '70mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = '(GLOW) BPC 10mg+GHK-Cu50mg+Tb500 10mg' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 215.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 12900.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 1419.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 16770.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 2012.4000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 2327.4000);

  -- === GHK-CU ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('GHK-CU', 'Copper peptide complex with regenerative and anti-aging research applications.', 'cosmetic', 330.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'CU50', '50mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'GHK-CU' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '50mg', 50.0, 330.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '100mg', 100.0, 462.00, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 50.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 3000.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 330.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 3900.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 468.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 783.0000);

  -- === AHK-CU ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('AHK-CU', 'AHK-Cu copper peptide for advanced skin and hair research applications.', 'cosmetic', 683.76, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'AU100', '100mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'AHK-CU' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 103.6000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 6216.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 683.7600);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 8080.8000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 969.6960);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1284.6960);

  -- === CJC-1295 with DAC ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('CJC-1295 with DAC', 'Modified growth hormone releasing hormone analog with Drug Affinity Complex.', 'research', 1221.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'CD5', '5mg*10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'CJC-1295 with DAC' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 185.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 11100.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 1221.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 14430.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 1731.6000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 2046.6000);

  -- === CJC-1295 NO DAC 5mg + IPA5mg ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('CJC-1295 NO DAC 5mg + IPA5mg', 'CJC-1295 without DAC combined with Ipamorelin for growth hormone research.', 'research', 1452.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'CP10', '10mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'CJC-1295 NO DAC 5mg + IPA5mg' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 220.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 13200.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 1452.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 17160.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 2059.2000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 2374.2000);

  -- === CJC-1295 NO DAC ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('CJC-1295 NO DAC', 'Modified GHRH analog without Drug Affinity Complex for growth hormone studies.', 'research', 613.80, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'CND5', '5mg*10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'CJC-1295 NO DAC' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5mg', 5.0, 613.80, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10mg', 10.0, 1287.00, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 93.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 5580.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 613.8000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 8370.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 1004.4000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1319.4000);

  -- === CagriSema ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('CagriSema', 'Research grade peptide for scientific study.', 'research', 924.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'CS5', '5mg*10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'CagriSema' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5mg', 5.0, 924.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10mg', 10.0, 1551.00, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 140.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 8400.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 924.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 12600.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 1512.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1827.0000);

  -- === Cagrilintide ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Cagrilintide', 'Long-acting amylin analog peptide for metabolic and appetite research.', 'research', 904.20, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'CGL5', '5mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Cagrilintide' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5mg', 5.0, 904.20, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10mg', 10.0, 1326.60, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 137.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 8220.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 904.2000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 10686.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 1282.3200);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1597.3200);

  -- === Cerebrolysin 60mg ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Cerebrolysin 60mg', 'Neuropeptide preparation for cognitive and neurological research.', 'wellness', 409.20, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'CBL60', '60mg*6vials', 6, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Cerebrolysin 60mg' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 62.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 3720.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 409.2000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 4836.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 580.3200);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 895.3200);

  -- === DSIP ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('DSIP', 'Delta Sleep-Inducing Peptide for sleep regulation and stress response research.', 'wellness', 402.60, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'DS5', '5mg*10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'DSIP' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5mg', 5.0, 402.60, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '15mg', 15.0, 759.00, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 61.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 3660.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 402.6000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 4758.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 570.9600);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 885.9600);

  -- === Epithalon ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Epithalon', 'Tetrapeptide studied for telomerase activation and anti-aging research.', 'wellness', 488.40, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'ET10', '10mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Epithalon' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10mg', 10.0, 488.40, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '50mg', 50.0, 1168.20, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 74.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 4440.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 488.4000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 5772.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 692.6400);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1007.6400);

  -- === Glutathione ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Glutathione', 'Research grade peptide for scientific study.', 'wellness', 435.60, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'GTT', '600mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Glutathione' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '600mg', 600.0, 435.60, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '1500mg', 1500.0, 594.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10ml', 10.0, 924.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10ml', 10.0, 1254.00, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 66.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 3960.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 435.6000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 5148.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 617.7600);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 932.7600);

  -- === HCG ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('HCG', 'Human Chorionic Gonadotropin for reproductive and hormonal research.', 'research', 693.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'G5K', '5000*10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'HCG' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5000', 5000.0, 693.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10000', 10000.0, 1254.00, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 105.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 6300.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 693.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 8190.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 982.8000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1297.8000);

  -- === HGH 191AA (Somatropin) ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('HGH 191AA (Somatropin)', 'Human Growth Hormone 191AA (Somatropin) for growth research.', 'research', 495.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'H10', '10iu*10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'HGH 191AA (Somatropin)' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10iu', 10.0, 495.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '15iu', 15.0, 627.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '24iu', 24.0, 957.00, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 75.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 4500.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 495.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 5850.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 702.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1017.0000);

  -- === hyaluronic acid-5mg *1 vials ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('hyaluronic acid-5mg *1 vials', 'Injectable hyaluronic acid for skin hydration and joint research.', 'cosmetic', 2112.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'HA5', '5mg*1vials', 1, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'hyaluronic acid-5mg *1 vials' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 32.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 1920.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 2112.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 2880.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 345.6000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 660.6000);

  -- === Hexarelin Acetate ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Hexarelin Acetate', 'Growth hormone secretagogue peptide for GH release research.', 'research', 726.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'HX5', '5mg*10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Hexarelin Acetate' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 110.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 6600.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 726.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 9900.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 1188.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1503.0000);

  -- === Insulin-1vial ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Insulin-1vial', 'Insulin peptide for metabolic and glucose regulation research.', 'research', 422.40, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'ISU', '3ml/1vials', 1, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Insulin-1vial' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 64.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 3840.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 422.4000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 5760.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 691.2000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1006.2000);

  -- === IGF-1LR3 ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('IGF-1LR3', 'Insulin-like Growth Factor-1 Long R3 for growth and tissue development research.', 'research', 389.40, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'IG01', '0.1mg*10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'IGF-1LR3' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '0.1mg', 0.1, 389.40, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '1mg', 1.0, 1366.20, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 59.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 3540.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 389.4000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 5310.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 637.2000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 952.2000);

  -- === Ipamorelin ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Ipamorelin', 'Selective growth hormone secretagogue for targeted GH release research.', 'research', 382.80, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'IP5', '5mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Ipamorelin' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5mg', 5.0, 382.80, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10mg', 10.0, 594.00, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 58.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 3480.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 382.8000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 4524.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 542.8800);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 857.8800);

  -- === KissPeptin-10 ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('KissPeptin-10', 'Neuropeptide involved in reproductive hormone regulation research.', 'research', 693.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'KS5', '5mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'KissPeptin-10' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5mg', 5.0, 693.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10mg', 10.0, 957.00, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 105.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 6300.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 693.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 8190.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 982.8000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1297.8000);

  -- === (KPV) LYSINE-PROLINE-VALINE ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('(KPV) LYSINE-PROLINE-VALINE', 'KPV anti-inflammatory tripeptide for gut health and skin research.', 'wellness', 429.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'KPV5', '5mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = '(KPV) LYSINE-PROLINE-VALINE' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5mg', 5.0, 429.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10mg', 10.0, 561.00, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 65.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 3900.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 429.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 5070.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 608.4000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 923.4000);

  -- === (KLOW) GHK-CU50+TB10+BC10+KPV10 ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('(KLOW) GHK-CU50+TB10+BC10+KPV10', 'Copper peptide complex with regenerative and anti-aging research applications.', 'cosmetic', 1815.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'KLOW80', '80mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = '(KLOW) GHK-CU50+TB10+BC10+KPV10' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 275.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 16500.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 1815.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 21450.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 2574.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 2889.0000);

  -- === MOTS-C ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('MOTS-C', 'Mitochondrial-derived peptide for metabolic regulation and exercise mimetic research.', 'wellness', 528.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'MS10', '10mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'MOTS-C' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10mg', 10.0, 528.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '40mg', 40.0, 1485.00, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 80.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 4800.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 528.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 6240.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 748.8000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1063.8000);

  -- === MT1 5mg Melatonin ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('MT1 5mg Melatonin', 'Melanotan-1 peptide for photoprotection and tanning research.', 'wellness', 462.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'MT1', '10mg*10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'MT1 5mg Melatonin' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 70.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 4200.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 462.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 5460.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 655.2000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 970.2000);

  -- === MT-2 (Melanotan 2 Acetate) ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('MT-2 (Melanotan 2 Acetate)', 'Melanotan-2 peptide for skin pigmentation and tanning research.', 'cosmetic', 530.77, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'ML10', '10mg*10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'MT-2 (Melanotan 2 Acetate)' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 80.4200);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 4825.2000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 530.7720);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 6272.7600);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 752.7312);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1067.7312);

  -- === Mazdutide ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Mazdutide', 'Dual GLP-1/Glucagon receptor agonist for next-generation metabolic research.', 'research', 1246.54, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'MZ', '10mg*10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Mazdutide' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 188.8700);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 11332.2000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 1246.5420);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 14731.8600);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 1767.8232);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 2082.8232);

  -- === NAD ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('NAD', 'Nicotinamide Adenine Dinucleotide for cellular energy and longevity research.', 'wellness', 363.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'NJ100', '100mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'NAD' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '100mg', 100.0, 363.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '500mg', 500.0, 627.00, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 55.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 3300.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 363.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 4290.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 514.8000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 829.8000);

  -- === Snap-8 ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Snap-8', 'Octapeptide for wrinkle reduction and anti-aging skin research.', 'cosmetic', 422.40, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'NP810', '10mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Snap-8' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 64.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 3840.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 422.4000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 5760.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 691.2000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1006.2000);

  -- === Oxytocin Acetate*2mg ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Oxytocin Acetate*2mg', 'Oxytocin neuropeptide for social bonding and behavioral research.', 'research', 363.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'OT2', '2mg*10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Oxytocin Acetate*2mg' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 55.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 3300.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 363.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 4950.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 594.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 909.0000);

  -- === PNC-27 ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('PNC-27', 'Research grade peptide for scientific study.', 'research', 785.40, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'PNC 27', '5mg*5vials', 5, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'PNC-27' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5mg', 5.0, 785.40, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5mg', 5.0, 1146.16, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 119.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 7140.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 785.4000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 10710.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 1285.2000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1600.2000);

  -- === Pinealon ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Pinealon', 'Tripeptide bioregulator for brain function and neuroprotection research.', 'wellness', 442.20, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'PI5', '5mg*10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Pinealon' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5mg', 5.0, 442.20, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10mg', 10.0, 580.80, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '20mg', 20.0, 772.20, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 67.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 4020.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 442.2000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 5226.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 627.1200);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 942.1200);

  -- === PT-141 ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('PT-141', 'Bremelanotide peptide for sexual dysfunction and melanocortin receptor research.', 'research', 541.20, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'P41', '10mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'PT-141' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 82.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 4920.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 541.2000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 6396.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 767.5200);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1082.5200);

  -- === Ara-290 ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Ara-290', 'Erythropoietin-derived peptide for neuropathic pain and tissue protection research.', 'wellness', 495.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'RA10', '10mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Ara-290' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 75.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 4500.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 495.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 5850.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 702.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1017.0000);

  -- === Sermorelin Acetate ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Sermorelin Acetate', 'Growth hormone releasing hormone analog for GH stimulation research.', 'research', 580.80, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'SMO5', '5mg*10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Sermorelin Acetate' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5mg', 5.0, 580.80, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10mg', 10.0, 832.00, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 88.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 5280.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 580.8000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 6864.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 823.6800);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1138.6800);

  -- === Survodutide ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Survodutide', 'Dual glucagon/GLP-1 receptor agonist for metabolic and liver health research.', 'research', 1961.39, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'SUR10', '10mg*10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Survodutide' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 297.1800);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 17830.8000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 1961.3880);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 23180.0400);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 2781.6048);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 3096.6048);

  -- === Selank ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Selank', 'Synthetic analog of tuftsin with anxiolytic and nootropic research applications.', 'wellness', 389.40, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'SK5', '5mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Selank' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5mg', 5.0, 389.40, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10mg', 10.0, 561.00, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 59.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 3540.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 389.4000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 4602.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 552.2400);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 867.2400);

  -- === Thymosin Alpha-1 ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Thymosin Alpha-1', 'Immune-modulating peptide for immune system enhancement research.', 'wellness', 726.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'TA5', '5mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Thymosin Alpha-1' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5mg', 5.0, 726.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10mg', 10.0, 1188.00, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 110.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 6600.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 726.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 8580.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 1029.6000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1344.6000);

  -- === Tesamorelin ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Tesamorelin', 'Growth hormone releasing factor analog for lipodystrophy and GH research.', 'research', 792.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'TSM5', '5mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Tesamorelin' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5mg', 5.0, 792.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10mg', 10.0, 1208.46, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '15mg', 15.0, 1386.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '20mg', 20.0, 1990.56, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 120.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 7200.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 792.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 9360.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 1123.2000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1438.2000);

  -- === (VIP) Vasoactive Intestinal Peptide ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('(VIP) Vasoactive Intestinal Peptide', 'Neuropeptide for immune modulation, respiratory, and gut health research.', 'wellness', 693.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'VIP5', '5mg*10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = '(VIP) Vasoactive Intestinal Peptide' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5mg', 5.0, 693.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10mg', 10.0, 1023.00, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 105.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 6300.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 693.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 9450.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 1134.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1449.0000);

  -- === Semax ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Semax', 'Synthetic ACTH analog peptide for cognitive enhancement and neuroprotection research.', 'wellness', 330.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'XA5', '5mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Semax' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5mg', 5.0, 330.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10mg', 10.0, 528.00, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 50.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 3000.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 330.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 3900.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 468.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 783.0000);

  -- === Botulinum toxin ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Botulinum toxin', 'Purified botulinum toxin for cosmetic and therapeutic research.', 'cosmetic', 1023.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'XT100', '100iu/10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Botulinum toxin' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 155.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 9300.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 1023.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 12090.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 1450.8000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1765.8000);

  -- === Lemon Bottle ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Lemon Bottle', 'Advanced lipolysis solution for fat dissolution and body contouring research.', 'cosmetic', 660.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'Lemon Bottle', '10mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Lemon Bottle' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 100.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 6000.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 660.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 7800.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 936.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1251.0000);

  -- === LL37 ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('LL37', 'Human cathelicidin antimicrobial peptide for immune defense research.', 'research', 627.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', NULL, '5mg*10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'LL37' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 95.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 5700.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 627.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 7410.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 889.2000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1204.2000);

  -- === AOD-9604 ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('AOD-9604', 'Anti-Obesity Drug peptide fragment for fat metabolism research.', 'research', 693.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', '5AD', '5mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'AOD-9604' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5mg', 5.0, 693.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10mg', 10.0, 1095.60, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 105.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 6300.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 693.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 8190.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 982.8000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1297.8000);

  -- === SLU-PP-322 ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('SLU-PP-322', 'Novel peptide compound for advanced metabolic research.', 'research', 1023.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', NULL, '5mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'SLU-PP-322' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 155.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 9300.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 1023.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 12090.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 1450.8000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1765.8000);

  -- === SS-31 ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('SS-31', 'Mitochondria-targeted peptide (Elamipretide) for cellular energy and protection research.', 'wellness', 706.20, 99.0, 100, true, false, 'Store at -20°C, protect from light', '2S10', '10mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'SS-31' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10mg', 10.0, 706.20, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '50mg', 50.0, 2475.00, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 107.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 6420.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 706.2000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 8346.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 1001.5200);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1316.5200);

  -- === 5-amino-1mq ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('5-amino-1mq', '5-Amino-1MQ NNMT inhibitor for fat metabolism research.', 'research', 574.20, 99.0, 100, true, false, 'Store at -20°C, protect from light', '5AM-5', '5mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = '5-amino-1mq' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5mg', 5.0, 574.20, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10mg', 10.0, 726.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '50mg', 50.0, 924.00, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 87.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 5220.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 574.2000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 6786.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 814.3200);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1129.3200);

  -- === Lipo-C ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Lipo-C', 'Lipotropic injection blend for fat metabolism and energy support.', 'wellness', 660.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'LC120', '10mL*10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Lipo-C' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 100.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 6000.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 660.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 9000.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 1080.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1395.0000);

  -- === Lipo-C with Vitamins B12 - Metabolic Boost ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Lipo-C with Vitamins B12 - Metabolic Boost', 'Lipotropic injection with Vitamins B12 for metabolic boost and energy support.', 'wellness', 660.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'LC216', '10mL*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Lipo-C with Vitamins B12 - Metabolic Boost' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 100.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 6000.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 660.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 9000.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 1080.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1395.0000);

  -- === L-Carnitine ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('L-Carnitine', 'L-Carnitine injection for fat transport and energy production research.', 'wellness', 739.20, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'LC600', '10ml*10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'L-Carnitine' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 112.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 6720.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 739.2000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 10080.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 1209.6000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1524.6000);

  -- === FAT BLASTER LIPO-C *CLEAR (w/o Vitamin B12) ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('FAT BLASTER LIPO-C *CLEAR (w/o Vitamin B12)', 'Lipotropic injection blend for fat metabolism and energy support.', 'wellness', 1188.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'LC526', '10ML × 525MG*10 vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'FAT BLASTER LIPO-C *CLEAR (w/o Vitamin B12)' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 180.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 10800.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 1188.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 16200.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 1944.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 2259.0000);

  -- === FAT BLASTER LIPO-C *RED ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('FAT BLASTER LIPO-C *RED', 'Lipotropic injection blend for fat metabolism and energy support.', 'wellness', 1188.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'LC526', '10ML × 526MG*10 vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'FAT BLASTER LIPO-C *RED' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 180.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 10800.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 1188.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 14040.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 1684.8000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1999.8000);

  -- === SHRED ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('SHRED', 'SHRED blend with L-Carnitine, B12, B6, Inositol, and Methionine.', 'wellness', 924.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'SHR', '10ml x 350.25mg/ml/vial', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'SHRED' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 140.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 8400.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 924.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 10920.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 1310.4000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1625.4000);

  -- === Lipo Mino Mix ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Lipo Mino Mix', 'Lipo Mino Mix injection blend for fat metabolism and vitamin support.', 'wellness', 924.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'LMX', '10ml', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Lipo Mino Mix' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 140.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 8400.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 924.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 10920.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 1310.4000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1625.4000);

  -- === Healthy Hair Skin Nails Blend ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Healthy Hair Skin Nails Blend', 'Healthy Hair, Skin & Nails blend with essential vitamins and biotin.', 'cosmetic', 1749.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'HHB', '10ML × 150.3MG*10 vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Healthy Hair Skin Nails Blend' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 265.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 15900.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 1749.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 20670.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 2480.4000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 2795.4000);

  -- === Super Human Blend ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Super Human Blend', 'Super Human amino acid blend for performance and recovery.', 'wellness', 924.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'SHB', '10ML × 865MG*10 vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Super Human Blend' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 140.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 8400.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 924.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 10920.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 1310.4000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1625.4000);

  -- === RELAXATION PM ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('RELAXATION PM', 'Relaxation PM blend with GABA, Melatonin, Arginine, and Glutamine.', 'wellness', 1881.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'RP226', '10ML × 865MG*10 vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'RELAXATION PM' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 285.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 17100.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 1881.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 22230.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 2667.6000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 2982.6000);

  -- === GABA Relax Blend ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('GABA Relax Blend', 'GABA Relax Blend with Histidine, L-Theanine, Taurine, and Melatonin.', 'wellness', 924.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'SZ352', '10ml x 352mg/ml/vial', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'GABA Relax Blend' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 140.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 8400.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 924.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 10920.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 1310.4000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'complete_set', 'PHP', 1625.4000);

  -- === Acetic Acid Water ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Acetic Acid Water', 'Research grade peptide for scientific study.', 'research', 66.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'AA3', '3ml*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Acetic Acid Water' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '3ml', 3.0, 66.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '3ml', 3.0, 66.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10ml', 10.0, 99.00, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 10.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 600.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 66.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 780.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 93.6000);

  -- === Bacteriostatic Water ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Bacteriostatic Water', 'Research grade peptide for scientific study.', 'research', 66.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'BA3', '3ml*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'Bacteriostatic Water' LIMIT 1; END IF;

  DELETE FROM product_variations WHERE product_id = pid;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '3ml', 3.0, 66.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '5ml', 5.0, 99.00, 50);
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10ml', 10.0, 118.80, 50);

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 10.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 600.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 66.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 780.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 93.6000);

  -- === PharmaGrade Bac Water 10ml ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('PharmaGrade Bac Water 10ml', 'Pharmaceutical grade bacteriostatic water for peptide reconstitution.', 'supplies', 118.80, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'BApH10', '10ml*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'PharmaGrade Bac Water 10ml' LIMIT 1; END IF;

  DELETE FROM product_prices WHERE product_id = pid;
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 18.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'PHP', 1080.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_vial', 'PHP', 118.8000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_box', 'PHP', 1404.0000);
  INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'onhand_vial', 'PHP', 168.4800);

  RAISE NOTICE 'All products imported successfully!';
END $$;

-- SECTION 4: Correct product images from public/product-images

-- Migration: Update product image_url fields to match product image files
-- Maps each product to its representative image in /product-images/

UPDATE products SET image_url = '/product-images/Semaglutide_5mg.png' WHERE name = 'Semaglutide';
UPDATE products SET image_url = '/product-images/Tirzepatide_5mg.png' WHERE name = 'Tirzepatide';
UPDATE products SET image_url = '/product-images/Retatrutide_5mg.png' WHERE name = 'Retatrutide';
UPDATE products SET image_url = '/product-images/BPC-157-5mg.png' WHERE name = 'BPC 157';
UPDATE products SET image_url = '/product-images/111_TB-500_5mg.png' WHERE name = 'TB500 (Thymosin B4 Acetate)';
UPDATE products SET image_url = '/product-images/BPC-157-TB-10mg.png' WHERE name = 'BPC 5mg + TB 5mg';
UPDATE products SET image_url = '/product-images/BPC-157-TB-20mg.png' WHERE name = 'BPC 10mg + TB 10mg';
UPDATE products SET image_url = '/product-images/Glow_70mg.png' WHERE name = '(GLOW) BPC 10mg+GHK-Cu50mg+Tb500 10mg';
UPDATE products SET image_url = '/product-images/41_GHK-Cu_50mg.png' WHERE name = 'GHK-CU';
UPDATE products SET image_url = '/product-images/10_AHK-Cu_100mg.png' WHERE name = 'AHK-CU';
UPDATE products SET image_url = '/product-images/CJC-1295-5mg.png' WHERE name = 'CJC-1295 with DAC';
UPDATE products SET image_url = '/product-images/CJC-1295-NODAC-IPA-10mg.png' WHERE name = 'CJC-1295 NO DAC 5mg + IPA5mg';
UPDATE products SET image_url = '/product-images/CJC-1295-NODAC-10mg.png' WHERE name = 'CJC-1295 NO DAC';
UPDATE products SET image_url = '/product-images/27_Cagrilintide_5mg_blend.png' WHERE name = 'CagriSema';
UPDATE products SET image_url = '/product-images/25_Cagrilintide_5mg.png' WHERE name = 'Cagrilintide';
UPDATE products SET image_url = '/product-images/Cerebrolysin_60mg.png' WHERE name = 'Cerebrolysin 60mg';
UPDATE products SET image_url = '/product-images/DSIP_5mg.png' WHERE name = 'DSIP';
UPDATE products SET image_url = '/product-images/Epithalon-10mg.png' WHERE name = 'Epithalon';
UPDATE products SET image_url = '/product-images/Glutathione-600mg.png' WHERE name = 'Glutathione';
-- HCG image is assigned in the remaining-images section below.
UPDATE products SET image_url = '/product-images/49_HGH_10iu.png' WHERE name = 'HGH 191AA (Somatropin)';
UPDATE products SET image_url = '/product-images/HyaluronicAcid_5ml.png' WHERE name = 'hyaluronic acid-5mg *1 vials';
UPDATE products SET image_url = '/product-images/48_Hexarelin_5mg.png' WHERE name = 'Hexarelin Acetate';
UPDATE products SET image_url = '/product-images/56_Insulin_3ml.png' WHERE name = 'Insulin-1vial';
UPDATE products SET image_url = '/product-images/54_IGF-1-LR3_1mg.png' WHERE name = 'IGF-1LR3';
UPDATE products SET image_url = '/product-images/57_Ipamorelin_5mg.png' WHERE name = 'Ipamorelin';
UPDATE products SET image_url = '/product-images/59_Kisspeptin-10_5mg.png' WHERE name = 'KissPeptin-10';
UPDATE products SET image_url = '/product-images/03_KPV_5mg.png' WHERE name = '(KPV) LYSINE-PROLINE-VALINE';
UPDATE products SET image_url = '/product-images/Klow_80mg.png' WHERE name = '(KLOW) GHK-CU50+TB10+BC10+KPV10';
UPDATE products SET image_url = '/product-images/70_MOTS-C_10mg.png' WHERE name = 'MOTS-C';
UPDATE products SET image_url = '/product-images/MT-1_10mg.png' WHERE name = 'MT1 5mg Melatonin';
UPDATE products SET image_url = '/product-images/72_MT-2_10mg.png' WHERE name = 'MT-2 (Melanotan 2 Acetate)';
UPDATE products SET image_url = '/product-images/69_Mazdutide_10mg.png' WHERE name = 'Mazdutide';
UPDATE products SET image_url = '/product-images/NAD+_100mg.png' WHERE name = 'NAD';
UPDATE products SET image_url = '/product-images/106_Snap-8_10mg.png' WHERE name = 'Snap-8';
UPDATE products SET image_url = '/product-images/76_Oxytocin_2mg.png' WHERE name = 'Oxytocin Acetate*2mg';
-- PNC-27 image is assigned in the remaining-images section below.
UPDATE products SET image_url = '/product-images/78_Pinealon_5mg.png' WHERE name = 'Pinealon';
UPDATE products SET image_url = '/product-images/81_PT-141_10mg.png' WHERE name = 'PT-141';
UPDATE products SET image_url = '/product-images/ARA-290 10mg.png' WHERE name = 'Ara-290';
UPDATE products SET image_url = '/product-images/102_Sermorelin_5mg.png' WHERE name = 'Sermorelin Acetate';
UPDATE products SET image_url = '/product-images/110_Survodutide_10mg.png' WHERE name = 'Survodutide';
UPDATE products SET image_url = '/product-images/92_Selank_5mg.png' WHERE name = 'Selank';
UPDATE products SET image_url = '/product-images/117_Thymosin-Alpha-1_5mg.png' WHERE name = 'Thymosin Alpha-1';
UPDATE products SET image_url = '/product-images/113_Tesamorelin_5mg.png' WHERE name = 'Tesamorelin';
UPDATE products SET image_url = '/product-images/05_VIP_5mg.png' WHERE name = '(VIP) Vasoactive Intestinal Peptide';
UPDATE products SET image_url = '/product-images/100_Semax_5mg.png' WHERE name = 'Semax';
UPDATE products SET image_url = '/product-images/BotulinumToxin_100iu.png' WHERE name = 'Botulinum toxin';
UPDATE products SET image_url = '/product-images/62_Lemon-Bottle_10ml.png' WHERE name = 'Lemon Bottle';
UPDATE products SET image_url = '/product-images/68_LL-37_5mg.png' WHERE name = 'LL37';
UPDATE products SET image_url = '/product-images/11_AOD-9604_5mg.png' WHERE name = 'AOD-9604';
UPDATE products SET image_url = '/product-images/105_SLU-PP-322_5mg.png' WHERE name = 'SLU-PP-322';
UPDATE products SET image_url = '/product-images/SS-31_10mg.png' WHERE name = 'SS-31';
UPDATE products SET image_url = '/product-images/07_5-Amino-1MQ_10mg.png' WHERE name = '5-amino-1mq';
UPDATE products SET image_url = '/product-images/66_Lipo-C_10ml.png' WHERE name = 'Lipo-C';
UPDATE products SET image_url = '/product-images/67_Lipo-C_10ml_v2.png' WHERE name = 'Lipo-C with Vitamins B12 - Metabolic Boost';
UPDATE products SET image_url = '/product-images/L-Carnitine_10ml.png' WHERE name = 'L-Carnitine';
UPDATE products SET image_url = '/product-images/FATBLASTER_w_out_B12_10ml.png' WHERE name = 'FAT BLASTER LIPO-C *CLEAR (w/o Vitamin B12)';
UPDATE products SET image_url = '/product-images/39_FAT-BLASTER-LIPO-C-RED_10ml.png' WHERE name = 'FAT BLASTER LIPO-C *RED';
UPDATE products SET image_url = '/product-images/104_SHRED_10ml.png' WHERE name = 'SHRED';
UPDATE products SET image_url = '/product-images/LipoMinoMix_10ml.png' WHERE name = 'Lipo Mino Mix';
UPDATE products SET image_url = '/product-images/Heathy-Hair-skin.png' WHERE name = 'Healthy Hair Skin Nails Blend';
UPDATE products SET image_url = '/product-images/Super Human Blend_10ml.png' WHERE name = 'Super Human Blend';
UPDATE products SET image_url = '/product-images/82_Relaxation-PM_10ml.png' WHERE name = 'RELAXATION PM';
UPDATE products SET image_url = '/product-images/40_GABA-Relax-Blend_10ml.png' WHERE name = 'GABA Relax Blend';
UPDATE products SET image_url = '/product-images/15_Acetic-Acid_3ml.png' WHERE name = 'Acetic Acid Water';
UPDATE products SET image_url = '/product-images/17_Bacteriostatic-Water_3ml.png' WHERE name = 'Bacteriostatic Water';
UPDATE products SET image_url = '/product-images/BAC_Water_10ml.png' WHERE name = 'PharmaGrade Bac Water 10ml';


-- SECTION 5: Convert displayed catalog prices to supplier USD pricing

-- Migration: Update all prices to USD from BiohackingSupplier.com pricelist
-- Generated from Excel file - corrects product_prices, product_variations, and base_price

DO $$
DECLARE
  pid UUID;
BEGIN

  -- === Semaglutide ===
  SELECT id INTO pid FROM products WHERE code = 'SM2' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 74.79 WHERE id = pid;

    UPDATE product_variations SET price = 74.79 WHERE product_id = pid AND name = '2mg';
    UPDATE product_variations SET price = 78.59 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 88.03 WHERE product_id = pid AND name = '10mg';
    UPDATE product_variations SET price = 97.61 WHERE product_id = pid AND name = '15mg';
    UPDATE product_variations SET price = 109.01 WHERE product_id = pid AND name = '20mg';
    UPDATE product_variations SET price = 126.06 WHERE product_id = pid AND name = '30mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 74.79);
  END IF;

  -- === Tirzepatide ===
  SELECT id INTO pid FROM products WHERE code = 'TR5' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 80.42 WHERE id = pid;

    UPDATE product_variations SET price = 80.42 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 90.00 WHERE product_id = pid AND name = '10mg';
    UPDATE product_variations SET price = 103.24 WHERE product_id = pid AND name = '15mg';
    UPDATE product_variations SET price = 114.65 WHERE product_id = pid AND name = '20mg';
    UPDATE product_variations SET price = 131.83 WHERE product_id = pid AND name = '30mg';
    UPDATE product_variations SET price = 148.87 WHERE product_id = pid AND name = '40mg';
    UPDATE product_variations SET price = 167.89 WHERE product_id = pid AND name = '50mg';
    UPDATE product_variations SET price = 186.90 WHERE product_id = pid AND name = '60mg';
    UPDATE product_variations SET price = 278.68 WHERE product_id = pid AND name = '100mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 80.42);
  END IF;

  -- === Retatrutide ===
  SELECT id INTO pid FROM products WHERE code = 'RT5' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 93.80 WHERE id = pid;

    UPDATE product_variations SET price = 93.80 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 116.62 WHERE product_id = pid AND name = '10mg';
    UPDATE product_variations SET price = 133.66 WHERE product_id = pid AND name = '15mg';
    UPDATE product_variations SET price = 152.68 WHERE product_id = pid AND name = '20mg';
    UPDATE product_variations SET price = 192.68 WHERE product_id = pid AND name = '30mg';
    UPDATE product_variations SET price = 216.56 WHERE product_id = pid AND name = '36mg';
    UPDATE product_variations SET price = 230.70 WHERE product_id = pid AND name = '40mg';
    UPDATE product_variations SET price = 249.72 WHERE product_id = pid AND name = '50mg';
    UPDATE product_variations SET price = 268.73 WHERE product_id = pid AND name = '60mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 93.80);
  END IF;

  -- === BPC 157 ===
  SELECT id INTO pid FROM products WHERE code = 'BC5' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 84.23 WHERE id = pid;

    UPDATE product_variations SET price = 84.23 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 99.44 WHERE product_id = pid AND name = '10mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 84.23);
  END IF;

  -- === TB500 (Thymosin B4 Acetate) ===
  SELECT id INTO pid FROM products WHERE code = 'BT5' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 110.85 WHERE id = pid;

    UPDATE product_variations SET price = 110.85 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 158.45 WHERE product_id = pid AND name = '10mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 110.85);
  END IF;

  -- === BPC 5mg + TB 5mg ===
  SELECT id INTO pid FROM products WHERE code = 'BB10' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 126.06 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 126.06);
  END IF;

  -- === BPC 10mg + TB 10mg ===
  SELECT id INTO pid FROM products WHERE code = 'BB20' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 202.11 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 202.11);
  END IF;

  -- === (GLOW) BPC 10mg+GHK-Cu50mg+Tb500 10mg ===
  SELECT id INTO pid FROM products WHERE code = 'BBG70' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 192.68 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 192.68);
  END IF;

  -- === GHK-CU ===
  SELECT id INTO pid FROM products WHERE code = 'CU50' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 72.82 WHERE id = pid;

    UPDATE product_variations SET price = 72.82 WHERE product_id = pid AND name = '50mg';
    UPDATE product_variations SET price = 78.59 WHERE product_id = pid AND name = '100mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 72.82);
  END IF;

  -- === CJC-1295 with DAC ===
  SELECT id INTO pid FROM products WHERE code = 'CD5' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 173.66 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 173.66);
  END IF;

  -- === CJC-1295 NO DAC 5mg + IPA5mg ===
  SELECT id INTO pid FROM products WHERE code = 'CP10' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 126.06 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 126.06);
  END IF;

  -- === CJC-1295 NO DAC ===
  SELECT id INTO pid FROM products WHERE code = 'CND5' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 116.62 WHERE id = pid;

    UPDATE product_variations SET price = 173.66 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 126.06 WHERE product_id = pid AND name = '10mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 116.62);
  END IF;

  -- === CagriSema ===
  SELECT id INTO pid FROM products WHERE code = 'CS5' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 135.63 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 135.63);
  END IF;

  -- === Cagrilintide ===
  SELECT id INTO pid FROM products WHERE code = 'CGL5' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 135.63 WHERE id = pid;

    UPDATE product_variations SET price = 135.63 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 202.11 WHERE product_id = pid AND name = '10mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 135.63);
  END IF;

  -- === Cerebrolysin 60mg ===
  SELECT id INTO pid FROM products WHERE code = 'CBL60' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 67.18 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 67.18);
  END IF;

  -- === DSIP ===
  SELECT id INTO pid FROM products WHERE code = 'DS5' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 78.59 WHERE id = pid;

    UPDATE product_variations SET price = 78.59 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 116.62 WHERE product_id = pid AND name = '15mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 78.59);
  END IF;

  -- === Epithalon ===
  SELECT id INTO pid FROM products WHERE code = 'ET10' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 110.85 WHERE id = pid;

    UPDATE product_variations SET price = 110.85 WHERE product_id = pid AND name = '10mg';
    UPDATE product_variations SET price = 224.93 WHERE product_id = pid AND name = '50mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 110.85);
  END IF;

  -- === Glutathione ===
  SELECT id INTO pid FROM products WHERE code = 'GTT' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 97.61 WHERE id = pid;

    UPDATE product_variations SET price = 97.61 WHERE product_id = pid AND name = '1500mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 97.61);
  END IF;

  -- === HCG ===
  SELECT id INTO pid FROM products WHERE code = 'G5K' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 129.86 WHERE id = pid;

    UPDATE product_variations SET price = 129.86 WHERE product_id = pid AND name = '5000';
    UPDATE product_variations SET price = 167.89 WHERE product_id = pid AND name = '10000';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 129.86);
  END IF;

  -- === HGH 191AA (Somatropin) ===
  SELECT id INTO pid FROM products WHERE code = 'H10' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 91.83 WHERE id = pid;

    UPDATE product_variations SET price = 91.83 WHERE product_id = pid AND name = '10iu';
    UPDATE product_variations SET price = 107.04 WHERE product_id = pid AND name = '15iu';
    UPDATE product_variations SET price = 145.07 WHERE product_id = pid AND name = '24iu';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 91.83);
  END IF;

  -- === hyaluronic acid-5mg *1 vials ===
  SELECT id INTO pid FROM products WHERE code = 'HA5' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 65.21 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 65.21);
  END IF;

  -- === Hexarelin Acetate ===
  SELECT id INTO pid FROM products WHERE code = 'HX5' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 116.62 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 116.62);
  END IF;

  -- === Insulin-1vial ===
  SELECT id INTO pid FROM products WHERE code = 'ISU' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 69.01 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 69.01);
  END IF;

  -- === IGF-1LR3 ===
  SELECT id INTO pid FROM products WHERE code = 'IG01' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 78.59 WHERE id = pid;

    UPDATE product_variations SET price = 78.59 WHERE product_id = pid AND name = '0.1mg';
    UPDATE product_variations SET price = 183.10 WHERE product_id = pid AND name = '1mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 78.59);
  END IF;

  -- === Ipamorelin ===
  SELECT id INTO pid FROM products WHERE code = 'IP5' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 78.59 WHERE id = pid;

    UPDATE product_variations SET price = 78.59 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 103.24 WHERE product_id = pid AND name = '10mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 78.59);
  END IF;

  -- === KissPeptin-10 ===
  SELECT id INTO pid FROM products WHERE code = 'KS5' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 93.80 WHERE id = pid;

    UPDATE product_variations SET price = 93.80 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 126.06 WHERE product_id = pid AND name = '10mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 93.80);
  END IF;

  -- === (KPV) LYSINE-PROLINE-VALINE ===
  SELECT id INTO pid FROM products WHERE code = 'KPV5' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 82.39 WHERE id = pid;

    UPDATE product_variations SET price = 82.39 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 91.83 WHERE product_id = pid AND name = '10mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 82.39);
  END IF;

  -- === (KLOW) GHK-CU50+TB10+BC10+KPV10 ===
  SELECT id INTO pid FROM products WHERE code = 'KLOW80' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 230.70 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 230.70);
  END IF;

  -- === MOTS-C ===
  SELECT id INTO pid FROM products WHERE code = 'MS10' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 95.63 WHERE id = pid;

    UPDATE product_variations SET price = 95.63 WHERE product_id = pid AND name = '10mg';
    UPDATE product_variations SET price = 183.10 WHERE product_id = pid AND name = '40mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 95.63);
  END IF;

  -- === MT1 5mg Melatonin ===
  SELECT id INTO pid FROM products WHERE code = 'MT1' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 84.23 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 84.23);
  END IF;

  -- === MT-2 (Melanotan 2 Acetate) ===
  SELECT id INTO pid FROM products WHERE code = 'ML10' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 80.42 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 80.42);
  END IF;

  -- === Mazdutide ===
  SELECT id INTO pid FROM products WHERE code = 'MZ' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 188.87 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 188.87);
  END IF;

  -- === NAD ===
  SELECT id INTO pid FROM products WHERE code = 'NJ100' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 76.62 WHERE id = pid;

    UPDATE product_variations SET price = 76.62 WHERE product_id = pid AND name = '100mg';
    UPDATE product_variations SET price = 107.04 WHERE product_id = pid AND name = '500mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 76.62);
  END IF;

  -- === Snap-8 ===
  SELECT id INTO pid FROM products WHERE code = 'NP810' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 78.59 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 78.59);
  END IF;

  -- === Oxytocin Acetate*2mg ===
  SELECT id INTO pid FROM products WHERE code = 'OT2' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 78.59 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 78.59);
  END IF;

  -- === PNC-27 ===
  SELECT id INTO pid FROM products WHERE code = 'PNC 27' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 173.66 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 173.66);
  END IF;

  -- === Pinealon ===
  SELECT id INTO pid FROM products WHERE code = 'PI5' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 78.59 WHERE id = pid;

    UPDATE product_variations SET price = 78.59 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 97.61 WHERE product_id = pid AND name = '10mg';
    UPDATE product_variations SET price = 116.62 WHERE product_id = pid AND name = '20mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 78.59);
  END IF;

  -- === PT-141 ===
  SELECT id INTO pid FROM products WHERE code = 'P41' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 91.83 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 91.83);
  END IF;

  -- === Ara-290 ===
  SELECT id INTO pid FROM products WHERE code = 'RA10' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 97.61 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 97.61);
  END IF;

  -- === Sermorelin Acetate ===
  SELECT id INTO pid FROM products WHERE code = 'SMO5' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 99.44 WHERE id = pid;

    UPDATE product_variations SET price = 110.85 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 158.45 WHERE product_id = pid AND name = '10mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 99.44);
  END IF;

  -- === Survodutide ===
  SELECT id INTO pid FROM products WHERE code = 'SUR10' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 297.18 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 297.18);
  END IF;

  -- === Selank ===
  SELECT id INTO pid FROM products WHERE code = 'SK5' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 78.59 WHERE id = pid;

    UPDATE product_variations SET price = 78.59 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 91.83 WHERE product_id = pid AND name = '10mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 78.59);
  END IF;

  -- === Thymosin Alpha-1 ===
  SELECT id INTO pid FROM products WHERE code = 'TA5' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 116.62 WHERE id = pid;

    UPDATE product_variations SET price = 110.85 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 158.45 WHERE product_id = pid AND name = '10mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 116.62);
  END IF;

  -- === Tesamorelin ===
  SELECT id INTO pid FROM products WHERE code = 'TSM5' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 126.06 WHERE id = pid;

    UPDATE product_variations SET price = 126.06 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 183.10 WHERE product_id = pid AND name = '10mg';
    UPDATE product_variations SET price = 256.80 WHERE product_id = pid AND name = '15mg';
    UPDATE product_variations SET price = 301.60 WHERE product_id = pid AND name = '20mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 126.06);
  END IF;

  -- === (VIP) Vasoactive Intestinal Peptide ===
  SELECT id INTO pid FROM products WHERE code = 'VIP5' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 107.04 WHERE id = pid;

    UPDATE product_variations SET price = 107.04 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 154.65 WHERE product_id = pid AND name = '10mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 107.04);
  END IF;

  -- === Semax ===
  SELECT id INTO pid FROM products WHERE code = 'XA5' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 78.59 WHERE id = pid;

    UPDATE product_variations SET price = 78.59 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 88.03 WHERE product_id = pid AND name = '10mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 78.59);
  END IF;

  -- === Botulinum toxin ===
  SELECT id INTO pid FROM products WHERE code = 'XT100' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 145.07 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 145.07);
  END IF;

  -- === AOD-9604 ===
  SELECT id INTO pid FROM products WHERE code = '5AD' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 131.83 WHERE id = pid;

    UPDATE product_variations SET price = 131.83 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 189.80 WHERE product_id = pid AND name = '10mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 131.83);
  END IF;

  -- === SS-31 ===
  SELECT id INTO pid FROM products WHERE code = '2S10' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 116.62 WHERE id = pid;

    UPDATE product_variations SET price = 116.62 WHERE product_id = pid AND name = '10mg';
    UPDATE product_variations SET price = 278.17 WHERE product_id = pid AND name = '50mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 116.62);
  END IF;

  -- === 5-amino-1mq ===
  SELECT id INTO pid FROM products WHERE code = '5AM-5' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 101.41 WHERE id = pid;

    UPDATE product_variations SET price = 101.41 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 116.00 WHERE product_id = pid AND name = '10mg';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 101.41);
  END IF;

  -- === Lipo-C ===
  SELECT id INTO pid FROM products WHERE code = 'LC120' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 97.61 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 97.61);
  END IF;

  -- === Lipo-C with Vitamins B12 - Metabolic Boost ===
  SELECT id INTO pid FROM products WHERE code = 'LC216' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 97.61 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 97.61);
  END IF;

  -- === L-Carnitine ===
  SELECT id INTO pid FROM products WHERE code = 'LC600' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 107.04 WHERE id = pid;


    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 107.04);
  END IF;

  -- === Acetic Acid Water ===
  SELECT id INTO pid FROM products WHERE code = 'AA3' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 13.80 WHERE id = pid;

    UPDATE product_variations SET price = 13.80 WHERE product_id = pid AND name = '3ml';
    UPDATE product_variations SET price = 13.80 WHERE product_id = pid AND name = '3ml';
    UPDATE product_variations SET price = 14.79 WHERE product_id = pid AND name = '10ml';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 13.80);
  END IF;

  -- === Bacteriostatic Water ===
  SELECT id INTO pid FROM products WHERE code = 'BA3' LIMIT 1;
  IF pid IS NOT NULL THEN
    -- Update base_price to USD
    UPDATE products SET base_price = 13.80 WHERE id = pid;

    UPDATE product_variations SET price = 13.80 WHERE product_id = pid AND name = '3ml';
    UPDATE product_variations SET price = 14.79 WHERE product_id = pid AND name = '10ml';

    -- Update product_prices: remove PHP, ensure USD prices correct
    DELETE FROM product_prices WHERE product_id = pid AND currency = 'PHP';
    -- Update/insert USD preorder_box price
    DELETE FROM product_prices WHERE product_id = pid AND price_type = 'preorder_box' AND currency = 'USD';
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 13.80);
  END IF;

END $$;

-- SECTION 6: Payment methods including crypto options

-- Add crypto payment methods: BTC (Native SegWit), BTC (SegWit), USDT (Ethereum)

INSERT INTO payment_methods (id, name, account_number, account_name, qr_code_url, active, sort_order)
VALUES
  ('btc-native-segwit', 'BTC (Native SegWit)', 'Scan QR code to get address', 'Bitcoin', '/payment-qr/btc-native-segwit.jpg', true, 1),
  ('btc-segwit', 'BTC (SegWit)', 'Scan QR code to get address', 'Bitcoin', '/payment-qr/btc-segwit.jpg', true, 2),
  ('usdt-ethereum', 'USDT (Ethereum)', 'Scan QR code to get address', 'Tether USD', '/payment-qr/usdt-ethereum.jpg', true, 3)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  qr_code_url = EXCLUDED.qr_code_url,
  active = EXCLUDED.active,
  sort_order = EXCLUDED.sort_order,
  updated_at = now();


-- SECTION 7: Biohacking categories and product-category mapping

-- Migration: Update categories to match BiohackingSupplier.com Excel + multi-category support
-- Categories from spreadsheet: WATER & RECONSTITUTION, HEALING & RECOVERY, SKIN & HAIR,
-- WEIGHT LOSS, ANTI-AGING, HORMONE SUPPORT & LIBIDO, LIBIDO, GROWTH HORMONE,
-- NEUROPEPTIDES, MITOCHONDRIAL, ANTI-AGING & LONGEVITY, SPECIALTY INJECTIONS
-- Orange-highlighted products appear in multiple categories (handled via junction table)

-- ============================================================
-- STEP 1: Create product_categories junction table
-- Drop first in case a prior failed run left a partial table
-- ============================================================
DROP TABLE IF EXISTS product_categories CASCADE;

CREATE TABLE product_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  category_id TEXT NOT NULL,
  is_primary BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(product_id, category_id)
);

-- Index for fast lookups
CREATE INDEX idx_product_categories_product ON product_categories(product_id);
CREATE INDEX idx_product_categories_category ON product_categories(category_id);

-- ============================================================
-- STEP 2: Drop FK from products, recreate categories table as TEXT PK
-- The live DB has categories.id as UUID but products.category stores
-- text slugs like 'research' - they were never properly linked.
-- We drop and recreate with TEXT id since we're replacing all categories.
-- ============================================================

-- Remove any FK from products.category -> categories.id
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_category_fkey;

-- Drop and recreate categories with TEXT primary key
DROP TABLE IF EXISTS categories CASCADE;

CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT NOT NULL,
  sort_order INTEGER DEFAULT 0,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on categories (matching original setup)
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access to categories" ON categories;
CREATE POLICY "Allow public read access to categories"
  ON categories FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow all access to categories" ON categories;
CREATE POLICY "Allow all access to categories"
  ON categories FOR ALL USING (true);

-- Re-enable realtime on categories
DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE categories;
EXCEPTION WHEN duplicate_object THEN
  NULL;
END $$;

-- Insert new categories matching Excel spreadsheet
INSERT INTO categories (id, name, icon, sort_order, active) VALUES
  ('water-reconstitution', 'Water & Reconstitution', 'Droplets', 1, true),
  ('healing-recovery', 'Healing & Recovery', 'Heart', 2, true),
  ('skin-hair', 'Skin & Hair', 'Sparkles', 3, true),
  ('weight-loss', 'Weight Loss', 'TrendingDown', 4, true),
  ('anti-aging', 'Anti-Aging', 'Clock', 5, true),
  ('hormone-libido', 'Hormone & Libido Support', 'Zap', 6, true),
  ('growth-hormone', 'Growth Hormone', 'ArrowUpCircle', 7, true),
  ('neuropeptides', 'Neuropeptides', 'Brain', 8, true),
  ('mitochondrial', 'Mitochondrial', 'Atom', 9, true),
  ('anti-aging-longevity', 'Anti-Aging & Longevity', 'Hourglass', 10, true),
  ('specialty', 'Specialty Injections', 'Syringe', 11, true);

-- ============================================================
-- STEP 3: Map products to new categories using product codes
-- Product codes from Excel are matched to DB product.code field
-- ============================================================

DO $$
DECLARE
  pid UUID;
BEGIN

  -- =============================================
  -- WATER & RECONSTITUTION
  -- =============================================
  -- Acetic Acid Water (AA3)
  FOR pid IN SELECT id FROM products WHERE code IN ('AA3') OR name LIKE '%Acetic Acid%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'water-reconstitution', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'water-reconstitution' WHERE id = pid;
  END LOOP;

  -- Bacteriostatic Water (BA3)
  FOR pid IN SELECT id FROM products WHERE code IN ('BA3') OR name LIKE '%Bacteriostatic%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'water-reconstitution', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'water-reconstitution' WHERE id = pid;
  END LOOP;

  -- PharmaGrade Bac Water (BApH10)
  FOR pid IN SELECT id FROM products WHERE code IN ('BApH10') OR name LIKE '%PharmaGrade%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'water-reconstitution', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'water-reconstitution' WHERE id = pid;
  END LOOP;

  -- =============================================
  -- HEALING & RECOVERY PEPTIDES
  -- =============================================
  -- BPC 157 (BC5)
  FOR pid IN SELECT id FROM products WHERE code IN ('BC5') OR name = 'BPC 157' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'healing-recovery', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'healing-recovery' WHERE id = pid;
  END LOOP;

  -- TB500 (BT5)
  FOR pid IN SELECT id FROM products WHERE code IN ('BT5') OR name LIKE 'TB500%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'healing-recovery', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'healing-recovery' WHERE id = pid;
  END LOOP;

  -- BPC + TB blends (BB10, BB20)
  FOR pid IN SELECT id FROM products WHERE code IN ('BB10', 'BB20') OR name LIKE 'BPC%+%TB%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'healing-recovery', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'healing-recovery' WHERE id = pid;
  END LOOP;

  -- GLOW blend (BBG70)
  FOR pid IN SELECT id FROM products WHERE code IN ('BBG70') OR name LIKE '%(GLOW)%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'healing-recovery', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'healing-recovery' WHERE id = pid;
  END LOOP;

  -- Cerebrolysin (CBL60)
  FOR pid IN SELECT id FROM products WHERE code IN ('CBL60') OR name LIKE 'Cerebrolysin%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'healing-recovery', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'healing-recovery' WHERE id = pid;
  END LOOP;

  -- DSIP (DS5)
  FOR pid IN SELECT id FROM products WHERE code IN ('DS5') OR name = 'DSIP' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'healing-recovery', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'healing-recovery' WHERE id = pid;
  END LOOP;

  -- KPV (KPV5)
  FOR pid IN SELECT id FROM products WHERE code IN ('KPV5') OR name LIKE '%(KPV)%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'healing-recovery', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'healing-recovery' WHERE id = pid;
  END LOOP;

  -- Ara-290 (RA10)
  FOR pid IN SELECT id FROM products WHERE code IN ('RA10') OR name LIKE 'Ara-290%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'healing-recovery', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'healing-recovery' WHERE id = pid;
  END LOOP;

  -- Thymosin Alpha-1 (TA5)
  FOR pid IN SELECT id FROM products WHERE code IN ('TA5') OR name LIKE 'Thymosin Alpha%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'healing-recovery', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'healing-recovery' WHERE id = pid;
  END LOOP;

  -- VIP (VIP5)
  FOR pid IN SELECT id FROM products WHERE code IN ('VIP5') OR name LIKE '%(VIP)%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'healing-recovery', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'healing-recovery' WHERE id = pid;
  END LOOP;

  -- LL37 (code 375 in Excel, name LL37 in DB)
  FOR pid IN SELECT id FROM products WHERE name = 'LL37' OR name LIKE 'LL37%' OR name LIKE 'LL-37%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'healing-recovery', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'healing-recovery' WHERE id = pid;
  END LOOP;

  -- CJC-1295 DAC (CD5) - PRIMARY: healing-recovery, ALSO: growth-hormone [ORANGE]
  FOR pid IN SELECT id FROM products WHERE code IN ('CD5') OR name LIKE 'CJC-1295%DAC' OR name = 'CJC-1295 with DAC' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'healing-recovery', true) ON CONFLICT DO NOTHING;
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'growth-hormone', false) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'healing-recovery' WHERE id = pid;
  END LOOP;

  -- CJC-1295 NO DAC + IPA (CP10) - PRIMARY: healing-recovery, ALSO: growth-hormone [ORANGE]
  FOR pid IN SELECT id FROM products WHERE code IN ('CP10') OR name LIKE 'CJC-1295 NO DAC%IPA%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'healing-recovery', true) ON CONFLICT DO NOTHING;
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'growth-hormone', false) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'healing-recovery' WHERE id = pid;
  END LOOP;

  -- CJC-1295 NO DAC (CND5) - PRIMARY: healing-recovery, ALSO: growth-hormone [ORANGE]
  FOR pid IN SELECT id FROM products WHERE code IN ('CND5') OR (name = 'CJC-1295 NO DAC') LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'healing-recovery', true) ON CONFLICT DO NOTHING;
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'growth-hormone', false) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'healing-recovery' WHERE id = pid;
  END LOOP;

  -- KLOW blend (KLOW80) - PRIMARY: healing-recovery, ALSO: skin-hair [ORANGE]
  FOR pid IN SELECT id FROM products WHERE code IN ('KLOW80') OR name LIKE '%(KLOW)%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'healing-recovery', true) ON CONFLICT DO NOTHING;
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'skin-hair', false) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'healing-recovery' WHERE id = pid;
  END LOOP;

  -- =============================================
  -- SKIN & HAIR PEPTIDES
  -- =============================================
  -- GHK-CU (CU50)
  FOR pid IN SELECT id FROM products WHERE code IN ('CU50') OR name = 'GHK-CU' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'skin-hair', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'skin-hair' WHERE id = pid;
  END LOOP;

  -- AHK-CU (AU100)
  FOR pid IN SELECT id FROM products WHERE code IN ('AU100') OR name = 'AHK-CU' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'skin-hair', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'skin-hair' WHERE id = pid;
  END LOOP;

  -- Hyaluronic Acid (HA5)
  FOR pid IN SELECT id FROM products WHERE code IN ('HA5') OR name LIKE '%hyaluronic acid%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'skin-hair', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'skin-hair' WHERE id = pid;
  END LOOP;

  -- Snap-8 (NP810)
  FOR pid IN SELECT id FROM products WHERE code IN ('NP810') OR name LIKE 'Snap-8%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'skin-hair', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'skin-hair' WHERE id = pid;
  END LOOP;

  -- MT1 Melatonin (MT1)
  FOR pid IN SELECT id FROM products WHERE code IN ('MT1') OR name LIKE 'MT1%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'skin-hair', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'skin-hair' WHERE id = pid;
  END LOOP;

  -- Botulinum toxin (XT100)
  FOR pid IN SELECT id FROM products WHERE code IN ('XT100') OR name LIKE 'Botulinum%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'skin-hair', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'skin-hair' WHERE id = pid;
  END LOOP;

  -- Healthy Hair Skin Nails Blend (HHB)
  FOR pid IN SELECT id FROM products WHERE code IN ('HHB') OR name LIKE 'Healthy Hair%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'skin-hair', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'skin-hair' WHERE id = pid;
  END LOOP;

  -- Glutathione (GTT) - PRIMARY: skin-hair, ALSO: anti-aging [ORANGE]
  FOR pid IN SELECT id FROM products WHERE code IN ('GTT') OR name = 'Glutathione' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'skin-hair', true) ON CONFLICT DO NOTHING;
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'anti-aging', false) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'skin-hair' WHERE id = pid;
  END LOOP;

  -- MT-2 Melanotan 2 (ML10) - PRIMARY: skin-hair, ALSO: hormone-libido [ORANGE]
  FOR pid IN SELECT id FROM products WHERE code IN ('ML10') OR name LIKE 'MT-2%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'skin-hair', true) ON CONFLICT DO NOTHING;
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'hormone-libido', false) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'skin-hair' WHERE id = pid;
  END LOOP;

  -- =============================================
  -- WEIGHT LOSS PEPTIDES
  -- =============================================
  -- CagriSema (CS5)
  FOR pid IN SELECT id FROM products WHERE code IN ('CS5') OR name = 'CagriSema' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'weight-loss', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'weight-loss' WHERE id = pid;
  END LOOP;

  -- Cagrilintide (CGL5)
  FOR pid IN SELECT id FROM products WHERE code IN ('CGL5') OR name = 'Cagrilintide' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'weight-loss', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'weight-loss' WHERE id = pid;
  END LOOP;

  -- Lipo-C (LC120)
  FOR pid IN SELECT id FROM products WHERE code IN ('LC120') OR (name = 'Lipo-C') LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'weight-loss', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'weight-loss' WHERE id = pid;
  END LOOP;

  -- Lipo-C with B12 (LC216)
  FOR pid IN SELECT id FROM products WHERE code IN ('LC216') OR name LIKE 'Lipo-C with%B12%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'weight-loss', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'weight-loss' WHERE id = pid;
  END LOOP;

  -- L-Carnitine (LC600)
  FOR pid IN SELECT id FROM products WHERE code IN ('LC600') OR name = 'L-Carnitine' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'weight-loss', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'weight-loss' WHERE id = pid;
  END LOOP;

  -- Mazdutide (MZ)
  FOR pid IN SELECT id FROM products WHERE code IN ('MZ') OR name = 'Mazdutide' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'weight-loss', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'weight-loss' WHERE id = pid;
  END LOOP;

  -- Survodutide (SUR10)
  FOR pid IN SELECT id FROM products WHERE code IN ('SUR10') OR name = 'Survodutide' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'weight-loss', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'weight-loss' WHERE id = pid;
  END LOOP;

  -- Semaglutide (SM2)
  FOR pid IN SELECT id FROM products WHERE code IN ('SM2') OR name = 'Semaglutide' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'weight-loss', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'weight-loss' WHERE id = pid;
  END LOOP;

  -- Tirzepatide (TR5)
  FOR pid IN SELECT id FROM products WHERE code IN ('TR5') OR name = 'Tirzepatide' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'weight-loss', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'weight-loss' WHERE id = pid;
  END LOOP;

  -- Retatrutide (RT5)
  FOR pid IN SELECT id FROM products WHERE code IN ('RT5') OR name = 'Retatrutide' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'weight-loss', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'weight-loss' WHERE id = pid;
  END LOOP;

  -- AOD-9604 (5AD)
  FOR pid IN SELECT id FROM products WHERE code IN ('5AD') OR name LIKE 'AOD-9604%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'weight-loss', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'weight-loss' WHERE id = pid;
  END LOOP;

  -- 5-amino-1mq (5AM-5)
  FOR pid IN SELECT id FROM products WHERE code IN ('5AM-5') OR name LIKE '5-amino%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'weight-loss', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'weight-loss' WHERE id = pid;
  END LOOP;

  -- Fat Blaster Lipo-C CLEAR (LC526)
  FOR pid IN SELECT id FROM products WHERE code IN ('LC526') OR name LIKE 'FAT BLASTER%CLEAR%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'weight-loss', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'weight-loss' WHERE id = pid;
  END LOOP;

  -- Fat Blaster Lipo-C RED
  FOR pid IN SELECT id FROM products WHERE name LIKE 'FAT BLASTER%RED%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'weight-loss', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'weight-loss' WHERE id = pid;
  END LOOP;

  -- SHRED (SHR)
  FOR pid IN SELECT id FROM products WHERE code IN ('SHR') OR name = 'SHRED' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'weight-loss', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'weight-loss' WHERE id = pid;
  END LOOP;

  -- Lipo Mino Mix (LMX)
  FOR pid IN SELECT id FROM products WHERE code IN ('LMX') OR name LIKE 'Lipo Mino%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'weight-loss', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'weight-loss' WHERE id = pid;
  END LOOP;

  -- MOTS-C (MS10) - PRIMARY: weight-loss, ALSO: mitochondrial [ORANGE]
  FOR pid IN SELECT id FROM products WHERE code IN ('MS10') OR name = 'MOTS-C' OR name LIKE 'MOTS%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'weight-loss', true) ON CONFLICT DO NOTHING;
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'mitochondrial', false) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'weight-loss' WHERE id = pid;
  END LOOP;

  -- Tesamorelin (TSM5) - PRIMARY: weight-loss, ALSO: growth-hormone, specialty [ORANGE]
  FOR pid IN SELECT id FROM products WHERE code IN ('TSM5') OR name = 'Tesamorelin' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'weight-loss', true) ON CONFLICT DO NOTHING;
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'growth-hormone', false) ON CONFLICT DO NOTHING;
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'specialty', false) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'weight-loss' WHERE id = pid;
  END LOOP;

  -- Lemon Bottle
  FOR pid IN SELECT id FROM products WHERE name LIKE 'Lemon Bottle%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'weight-loss', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'weight-loss' WHERE id = pid;
  END LOOP;

  -- =============================================
  -- ANTI-AGING PEPTIDES
  -- =============================================
  -- Epithalon (ET10)
  FOR pid IN SELECT id FROM products WHERE code IN ('ET10') OR name = 'Epithalon' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'anti-aging', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'anti-aging' WHERE id = pid;
  END LOOP;

  -- =============================================
  -- HORMONE & LIBIDO SUPPORT PEPTIDES
  -- (Merging "HORMONE SUPPORT LIBIDO" and "LIBIDO PEPTIDES" from Excel)
  -- =============================================
  -- HCG (G5K)
  FOR pid IN SELECT id FROM products WHERE code IN ('G5K') OR name = 'HCG' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'hormone-libido', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'hormone-libido' WHERE id = pid;
  END LOOP;

  -- Insulin (ISU)
  FOR pid IN SELECT id FROM products WHERE code IN ('ISU') OR name LIKE 'Insulin%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'hormone-libido', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'hormone-libido' WHERE id = pid;
  END LOOP;

  -- Oxytocin (OT2)
  FOR pid IN SELECT id FROM products WHERE code IN ('OT2') OR name LIKE 'Oxytocin%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'hormone-libido', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'hormone-libido' WHERE id = pid;
  END LOOP;

  -- PT-141 (P41)
  FOR pid IN SELECT id FROM products WHERE code IN ('P41') OR name LIKE 'PT-141%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'hormone-libido', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'hormone-libido' WHERE id = pid;
  END LOOP;

  -- KissPeptin-10 (KS5) - PRIMARY: hormone-libido, ALSO: neuropeptides [ORANGE]
  FOR pid IN SELECT id FROM products WHERE code IN ('KS5') OR name LIKE 'KissPeptin%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'hormone-libido', true) ON CONFLICT DO NOTHING;
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'neuropeptides', false) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'hormone-libido' WHERE id = pid;
  END LOOP;

  -- =============================================
  -- GROWTH HORMONE PEPTIDES
  -- =============================================
  -- HGH 191AA (H10)
  FOR pid IN SELECT id FROM products WHERE code IN ('H10') OR name LIKE 'HGH 191AA%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'growth-hormone', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'growth-hormone' WHERE id = pid;
  END LOOP;

  -- Hexarelin Acetate (HX5)
  FOR pid IN SELECT id FROM products WHERE code IN ('HX5') OR name LIKE 'Hexarelin%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'growth-hormone', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'growth-hormone' WHERE id = pid;
  END LOOP;

  -- IGF-1LR3 (IG01)
  FOR pid IN SELECT id FROM products WHERE code IN ('IG01') OR name LIKE 'IGF-1%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'growth-hormone', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'growth-hormone' WHERE id = pid;
  END LOOP;

  -- Ipamorelin (IP5)
  FOR pid IN SELECT id FROM products WHERE code IN ('IP5') OR name = 'Ipamorelin' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'growth-hormone', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'growth-hormone' WHERE id = pid;
  END LOOP;

  -- Sermorelin Acetate (SMO5)
  FOR pid IN SELECT id FROM products WHERE code IN ('SMO5') OR name LIKE 'Sermorelin%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'growth-hormone', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'growth-hormone' WHERE id = pid;
  END LOOP;

  -- =============================================
  -- NEUROPEPTIDES
  -- =============================================
  -- Selank (SK5)
  FOR pid IN SELECT id FROM products WHERE code IN ('SK5') OR name = 'Selank' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'neuropeptides', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'neuropeptides' WHERE id = pid;
  END LOOP;

  -- Semax (XA5)
  FOR pid IN SELECT id FROM products WHERE code IN ('XA5') OR name = 'Semax' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'neuropeptides', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'neuropeptides' WHERE id = pid;
  END LOOP;

  -- Pinealon (PI5) - PRIMARY: neuropeptides, ALSO: anti-aging-longevity [ORANGE]
  FOR pid IN SELECT id FROM products WHERE code IN ('PI5') OR name = 'Pinealon' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'neuropeptides', true) ON CONFLICT DO NOTHING;
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'anti-aging-longevity', false) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'neuropeptides' WHERE id = pid;
  END LOOP;

  -- =============================================
  -- MITOCHONDRIAL PEPTIDES
  -- =============================================
  -- NAD (NJ100) - PRIMARY: mitochondrial, ALSO: anti-aging-longevity [ORANGE]
  FOR pid IN SELECT id FROM products WHERE code IN ('NJ100') OR name = 'NAD' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'mitochondrial', true) ON CONFLICT DO NOTHING;
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'anti-aging-longevity', false) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'mitochondrial' WHERE id = pid;
  END LOOP;

  -- SLU-PP-322 - PRIMARY: mitochondrial, ALSO: anti-aging-longevity [ORANGE]
  FOR pid IN SELECT id FROM products WHERE name = 'SLU-PP-322' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'mitochondrial', true) ON CONFLICT DO NOTHING;
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'anti-aging-longevity', false) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'mitochondrial' WHERE id = pid;
  END LOOP;

  -- SS-31 (2S10) - PRIMARY: mitochondrial, ALSO: anti-aging-longevity [ORANGE]
  FOR pid IN SELECT id FROM products WHERE code IN ('2S10') OR name = 'SS-31' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'mitochondrial', true) ON CONFLICT DO NOTHING;
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'anti-aging-longevity', false) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'mitochondrial' WHERE id = pid;
  END LOOP;

  -- =============================================
  -- SPECIALTY INJECTIONS
  -- =============================================
  -- PNC-27
  FOR pid IN SELECT id FROM products WHERE code LIKE 'PNC%' OR name LIKE 'PNC%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'specialty', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'specialty' WHERE id = pid;
  END LOOP;

  -- =============================================
  -- WELLNESS/BLENDS (not in Excel categories - assign to weight-loss or specialty)
  -- =============================================
  -- Super Human Blend (SHB)
  FOR pid IN SELECT id FROM products WHERE code IN ('SHB') OR name LIKE 'Super Human%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'specialty', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'specialty' WHERE id = pid;
  END LOOP;

  -- RELAXATION PM (RP226)
  FOR pid IN SELECT id FROM products WHERE code IN ('RP226') OR name LIKE 'RELAXATION%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'specialty', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'specialty' WHERE id = pid;
  END LOOP;

  -- GABA Relax Blend (SZ352)
  FOR pid IN SELECT id FROM products WHERE code IN ('SZ352') OR name LIKE 'GABA%' LOOP
    INSERT INTO product_categories (product_id, category_id, is_primary) VALUES (pid, 'specialty', true) ON CONFLICT DO NOTHING;
    UPDATE products SET category = 'specialty' WHERE id = pid;
  END LOOP;

  -- =============================================
  -- Catch-all: any products without a product_categories entry
  -- assign them to their current primary category
  -- =============================================
  INSERT INTO product_categories (product_id, category_id, is_primary)
  SELECT p.id, p.category, true
  FROM products p
  WHERE NOT EXISTS (
    SELECT 1 FROM product_categories pc WHERE pc.product_id = p.id
  )
  AND p.category IS NOT NULL
  AND p.available = true
  ON CONFLICT DO NOTHING;

END $$;

-- ============================================================
-- STEP 4: Enable RLS but allow public read access
-- ============================================================
ALTER TABLE product_categories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access to product_categories" ON product_categories;
CREATE POLICY "Allow public read access to product_categories"
  ON product_categories FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Allow authenticated insert to product_categories" ON product_categories;
CREATE POLICY "Allow authenticated insert to product_categories"
  ON product_categories FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated update to product_categories" ON product_categories;
CREATE POLICY "Allow authenticated update to product_categories"
  ON product_categories FOR UPDATE
  USING (true);

DROP POLICY IF EXISTS "Allow authenticated delete to product_categories" ON product_categories;
CREATE POLICY "Allow authenticated delete to product_categories"
  ON product_categories FOR DELETE
  USING (true);

-- Enable realtime for the junction table
DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE product_categories;
EXCEPTION WHEN duplicate_object THEN
  NULL; -- already added
END $$;


-- SECTION 8: Missing product fixes and remaining image products

-- Migration: Add missing products from BiohackingSupplier.com Excel + fix codes/prices
-- Products that exist in the Excel but not in the database

DO $$
DECLARE
  pid UUID;
BEGIN

  -- ============================================================
  -- FIX PRODUCT CODES (products exist but with wrong/missing codes)
  -- ============================================================

  -- SLU-PP-322: code should be '322'
  UPDATE products SET code = '322' WHERE name = 'SLU-PP-322' AND (code IS NULL OR code != '322');

  -- LL37: code should be '375'
  UPDATE products SET code = '375' WHERE (name = 'LL37' OR name LIKE 'LL-37%') AND (code IS NULL OR code != '375');

  -- Lemon Bottle: update code to match Excel
  UPDATE products SET code = '柠檬瓶' WHERE name LIKE 'Lemon Bottle%' AND (code IS NULL OR code = 'Lemon Bottle');

  -- AHK-CU: Excel uses code 'AHKCU 100', DB has 'AU100' - update to match Excel
  UPDATE products SET code = 'AHKCU 100' WHERE name = 'AHK-CU' AND code = 'AU100';

  -- ============================================================
  -- ADD MISSING PRODUCTS
  -- ============================================================

  -- === Sterile Water (WA3) ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Sterile Water', 'Sterile water for reconstitution of lyophilized peptides.', 'water-reconstitution', 13.80, 99.0, 100, true, false, 'Store at room temperature', 'WA3', '3mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE code = 'WA3' LIMIT 1; END IF;

  IF pid IS NOT NULL THEN
    DELETE FROM product_variations WHERE product_id = pid;
    INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '3ml', 3.0, 13.80, 100);
    INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES (pid, '10ml', 10.0, 14.79, 100);

    DELETE FROM product_prices WHERE product_id = pid;
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 13.80);

    -- Add to product_categories
    INSERT INTO product_categories (product_id, category_id, is_primary)
    VALUES (pid, 'water-reconstitution', true) ON CONFLICT DO NOTHING;
  END IF;

  -- === Cosmetic GHKCU 1g (CU 1g) ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Cosmetic GHK-CU 1g', 'Cosmetic-grade GHK-Cu copper peptide in 1g tube for topical research applications.', 'skin-hair', 34.89, 99.0, 100, true, false, 'Store at room temperature, protect from light', 'CU 1g', '1g*1tube', 1, 'tube', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE code = 'CU 1g' LIMIT 1; END IF;

  IF pid IS NOT NULL THEN
    DELETE FROM product_prices WHERE product_id = pid;
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 34.89);

    INSERT INTO product_categories (product_id, category_id, is_primary)
    VALUES (pid, 'skin-hair', true) ON CONFLICT DO NOTHING;
  END IF;

  -- === Cosmetic AHKCU 1g (AHKCU 1g) ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Cosmetic AHK-CU 1g', 'Cosmetic-grade AHK-Cu copper peptide in 1g tube for topical research applications.', 'skin-hair', 44.89, 99.0, 100, true, false, 'Store at room temperature, protect from light', 'AHKCU 1g', '1g*1tube', 1, 'tube', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE code = 'AHKCU 1g' LIMIT 1; END IF;

  IF pid IS NOT NULL THEN
    DELETE FROM product_prices WHERE product_id = pid;
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 44.89);

    INSERT INTO product_categories (product_id, category_id, is_primary)
    VALUES (pid, 'skin-hair', true) ON CONFLICT DO NOTHING;
  END IF;

  -- === Vitamin B12 (B12) ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('Vitamin B12', 'Methylcobalamin B12 injectable solution for research.', 'specialty', 69.01, 99.0, 100, true, false, 'Store at room temperature, protect from light', 'B12', '10mL*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE code = 'B12' LIMIT 1; END IF;

  IF pid IS NOT NULL THEN
    DELETE FROM product_prices WHERE product_id = pid;
    INSERT INTO product_prices (product_id, price_type, currency, amount) VALUES (pid, 'preorder_box', 'USD', 69.01);

    INSERT INTO product_categories (product_id, category_id, is_primary)
    VALUES (pid, 'specialty', true) ON CONFLICT DO NOTHING;
  END IF;

  -- ============================================================
  -- VERIFY/FIX VARIATION PRICES TO MATCH EXCEL
  -- (Some variations may have been created with old prices)
  -- ============================================================

  -- Acetic Acid Water (AA3): 3ml=$13.80, 10ml=$14.79
  SELECT id INTO pid FROM products WHERE code = 'AA3' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 13.80 WHERE product_id = pid AND name = '3ml';
    UPDATE product_variations SET price = 14.79 WHERE product_id = pid AND name = '10ml';
    -- Ensure 10ml variation exists
    INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity)
    SELECT pid, '10ml', 10.0, 14.79, 100
    WHERE NOT EXISTS (SELECT 1 FROM product_variations WHERE product_id = pid AND name = '10ml');
  END IF;

  -- Bacteriostatic Water (BA3): 3ml=$13.80, 10ml=$14.79
  SELECT id INTO pid FROM products WHERE code = 'BA3' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 13.80 WHERE product_id = pid AND name = '3ml';
    UPDATE product_variations SET price = 14.79 WHERE product_id = pid AND name = '10ml';
    INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity)
    SELECT pid, '10ml', 10.0, 14.79, 100
    WHERE NOT EXISTS (SELECT 1 FROM product_variations WHERE product_id = pid AND name = '10ml');
  END IF;

  -- BPC 157 (BC5): 5mg=$84.23, 10mg=$99.44
  SELECT id INTO pid FROM products WHERE code = 'BC5' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 84.23 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 99.44 WHERE product_id = pid AND name = '10mg';
  END IF;

  -- TB500 (BT5): 5mg=$110.85, 10mg=$158.45
  SELECT id INTO pid FROM products WHERE code = 'BT5' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 110.85 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 158.45 WHERE product_id = pid AND name = '10mg';
    INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity)
    SELECT pid, '10mg', 10.0, 158.45, 100
    WHERE NOT EXISTS (SELECT 1 FROM product_variations WHERE product_id = pid AND name = '10mg');
  END IF;

  -- GHK-CU (CU50): 50mg=$72.82, 100mg=$78.59
  SELECT id INTO pid FROM products WHERE code = 'CU50' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 72.82 WHERE product_id = pid AND name = '50mg';
    UPDATE product_variations SET price = 78.59 WHERE product_id = pid AND name = '100mg';
  END IF;

  -- CJC-1295 NO DAC (CND5): 5mg=$116.62, 10mg=$173.66
  SELECT id INTO pid FROM products WHERE code = 'CND5' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 116.62 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 173.66 WHERE product_id = pid AND name = '10mg';
  END IF;

  -- CagriSema (CS5): 5mg=$135.63, 10mg=$202.11
  SELECT id INTO pid FROM products WHERE code = 'CS5' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 135.63 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 202.11 WHERE product_id = pid AND name = '10mg';
  END IF;

  -- Cagrilintide (CGL5): 5mg=$135.63, 10mg=$181.27
  SELECT id INTO pid FROM products WHERE code = 'CGL5' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 135.63 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 181.27 WHERE product_id = pid AND name = '10mg';
  END IF;

  -- DSIP (DS5): 5mg=$78.59, 15mg=$116.62
  SELECT id INTO pid FROM products WHERE code = 'DS5' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 78.59 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 116.62 WHERE product_id = pid AND name = '15mg';
  END IF;

  -- Epithalon (ET10): 10mg=$110.85, 50mg=$224.93
  SELECT id INTO pid FROM products WHERE code = 'ET10' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 110.85 WHERE product_id = pid AND name = '10mg';
    UPDATE product_variations SET price = 224.93 WHERE product_id = pid AND name = '50mg';
  END IF;

  -- Glutathione (GTT): 1500mg=$97.61
  SELECT id INTO pid FROM products WHERE code = 'GTT' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 97.61 WHERE product_id = pid AND (name = '1500mg' OR name = '600mg');
    UPDATE products SET base_price = 97.61, spec = '1500mg*10vials' WHERE id = pid;
  END IF;

  -- HCG (G5K): 5000=$129.86, 10000=$167.89
  SELECT id INTO pid FROM products WHERE code = 'G5K' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 129.86 WHERE product_id = pid AND name = '5000';
    UPDATE product_variations SET price = 167.89 WHERE product_id = pid AND name = '10000';
    INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity)
    SELECT pid, '10000', 10000.0, 167.89, 100
    WHERE NOT EXISTS (SELECT 1 FROM product_variations WHERE product_id = pid AND name = '10000');
  END IF;

  -- HGH 191AA (H10): 10iu=$91.83, 15iu=$107.04, 24iu=$145.07
  SELECT id INTO pid FROM products WHERE code = 'H10' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 91.83 WHERE product_id = pid AND name = '10iu';
    UPDATE product_variations SET price = 107.04 WHERE product_id = pid AND name = '15iu';
    UPDATE product_variations SET price = 145.07 WHERE product_id = pid AND name = '24iu';
  END IF;

  -- IGF-1LR3 (IG01): 0.1mg=$78.59, 1mg=$183.10
  SELECT id INTO pid FROM products WHERE code = 'IG01' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 78.59 WHERE product_id = pid AND name = '0.1mg';
    UPDATE product_variations SET price = 183.10 WHERE product_id = pid AND name = '1mg';
  END IF;

  -- Ipamorelin (IP5): 5mg=$78.59, 10mg=$103.24
  SELECT id INTO pid FROM products WHERE code = 'IP5' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 78.59 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 103.24 WHERE product_id = pid AND name = '10mg';
  END IF;

  -- KissPeptin (KS5): 5mg=$93.80, 10mg=$126.06
  SELECT id INTO pid FROM products WHERE code = 'KS5' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 93.80 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 126.06 WHERE product_id = pid AND name = '10mg';
  END IF;

  -- KPV (KPV5): 5mg=$82.39, 10mg=$91.83
  SELECT id INTO pid FROM products WHERE code = 'KPV5' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 82.39 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 91.83 WHERE product_id = pid AND name = '10mg';
  END IF;

  -- MOTS-C (MS10): 10mg=$95.63, 40mg=$183.10
  SELECT id INTO pid FROM products WHERE code = 'MS10' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 95.63 WHERE product_id = pid AND name = '10mg';
    UPDATE product_variations SET price = 183.10 WHERE product_id = pid AND name = '40mg';
  END IF;

  -- NAD (NJ100): 100mg=$76.62, 500mg=$107.04
  SELECT id INTO pid FROM products WHERE code = 'NJ100' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 76.62 WHERE product_id = pid AND name = '100mg';
    UPDATE product_variations SET price = 107.04 WHERE product_id = pid AND name = '500mg';
  END IF;

  -- Pinealon (PI5): 5mg=$78.59, 10mg=$97.61, 20mg=$116.62
  SELECT id INTO pid FROM products WHERE code = 'PI5' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 78.59 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 97.61 WHERE product_id = pid AND name = '10mg';
    UPDATE product_variations SET price = 116.62 WHERE product_id = pid AND name = '20mg';
  END IF;

  -- Selank (SK5): 5mg=$78.59, 10mg=$91.83
  SELECT id INTO pid FROM products WHERE code = 'SK5' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 78.59 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 91.83 WHERE product_id = pid AND name = '10mg';
  END IF;

  -- Semax (XA5): 5mg=$78.59, 10mg=$88.03
  SELECT id INTO pid FROM products WHERE code = 'XA5' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 78.59 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 88.03 WHERE product_id = pid AND name = '10mg';
  END IF;

  -- Sermorelin (SMO5): 5mg=$99.44, 10mg=$126.06
  SELECT id INTO pid FROM products WHERE code = 'SMO5' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 99.44 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 126.06 WHERE product_id = pid AND name = '10mg';
  END IF;

  -- SS-31 (2S10): 10mg=$116.62, 50mg=$278.17
  SELECT id INTO pid FROM products WHERE code = '2S10' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 116.62 WHERE product_id = pid AND name = '10mg';
    UPDATE product_variations SET price = 278.17 WHERE product_id = pid AND name = '50mg';
  END IF;

  -- AOD-9604 (5AD): 5mg=$131.83, 10mg=$189.80
  SELECT id INTO pid FROM products WHERE code = '5AD' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 131.83 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 189.80 WHERE product_id = pid AND name = '10mg';
  END IF;

  -- 5-amino-1mq (5AM-5): 5mg=$101.41, 10mg=$116.00, 50mg=$145.60
  SELECT id INTO pid FROM products WHERE code = '5AM-5' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 101.41 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 116.00 WHERE product_id = pid AND name = '10mg';
    UPDATE product_variations SET price = 145.60 WHERE product_id = pid AND name = '50mg';
  END IF;

  -- Thymosin Alpha-1 (TA5): 5mg=$116.62, 10mg=$173.66
  SELECT id INTO pid FROM products WHERE code = 'TA5' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 116.62 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 173.66 WHERE product_id = pid AND name = '10mg';
  END IF;

  -- VIP (VIP5): 5mg=$107.04, 10mg=$154.65
  SELECT id INTO pid FROM products WHERE code = 'VIP5' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 107.04 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 154.65 WHERE product_id = pid AND name = '10mg';
  END IF;

  -- Tesamorelin (TSM5): 5mg=$126.06, 10mg=$183.10, 15mg=$256.80, 20mg=$301.60
  SELECT id INTO pid FROM products WHERE code = 'TSM5' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 126.06 WHERE product_id = pid AND name = '5mg';
    UPDATE product_variations SET price = 183.10 WHERE product_id = pid AND name = '10mg';
    UPDATE product_variations SET price = 256.80 WHERE product_id = pid AND name = '15mg';
    UPDATE product_variations SET price = 301.60 WHERE product_id = pid AND name = '20mg';
  END IF;

  -- PNC-27: 5mg*5vials=$126.06, 5mg*10vials=$173.66
  SELECT id INTO pid FROM products WHERE code = 'PNC 27' OR name LIKE 'PNC%' LIMIT 1;
  IF pid IS NOT NULL THEN
    UPDATE product_variations SET price = 126.06 WHERE product_id = pid AND name = '5mg' AND stock_quantity < 10;
    -- Ensure both variations exist (5-vial and 10-vial packs)
    UPDATE products SET base_price = 126.06 WHERE id = pid;
  END IF;

  -- ============================================================
  -- UPDATE BASE PRICES for products that might have old prices
  -- (Safety net - ensures base_price matches Excel)
  -- ============================================================
  UPDATE products SET base_price = 13.80 WHERE code = 'AA3';
  UPDATE products SET base_price = 13.80 WHERE code = 'BA3';
  UPDATE products SET base_price = 84.23 WHERE code = 'BC5';
  UPDATE products SET base_price = 110.85 WHERE code = 'BT5';
  UPDATE products SET base_price = 126.06 WHERE code = 'BB10';
  UPDATE products SET base_price = 202.11 WHERE code = 'BB20';
  UPDATE products SET base_price = 192.68 WHERE code = 'BBG70';
  UPDATE products SET base_price = 173.66 WHERE code = 'CD5';
  UPDATE products SET base_price = 126.06 WHERE code = 'CP10';
  UPDATE products SET base_price = 116.62 WHERE code = 'CND5';
  UPDATE products SET base_price = 67.18 WHERE code = 'CBL60';
  UPDATE products SET base_price = 78.59 WHERE code = 'DS5';
  UPDATE products SET base_price = 82.39 WHERE code = 'KPV5';
  UPDATE products SET base_price = 230.70 WHERE code = 'KLOW80';
  UPDATE products SET base_price = 97.61 WHERE code = 'RA10';
  UPDATE products SET base_price = 116.62 WHERE code = 'TA5';
  UPDATE products SET base_price = 107.04 WHERE code = 'VIP5';
  UPDATE products SET base_price = 112.82 WHERE code = '375';
  UPDATE products SET base_price = 72.82 WHERE code = 'CU50';
  UPDATE products SET base_price = 103.60 WHERE code = 'AHKCU 100';
  UPDATE products SET base_price = 97.61 WHERE code = 'GTT';
  UPDATE products SET base_price = 65.21 WHERE code = 'HA5';
  UPDATE products SET base_price = 78.59 WHERE code = 'NP810';
  UPDATE products SET base_price = 84.23 WHERE code = 'MT1';
  UPDATE products SET base_price = 80.42 WHERE code = 'ML10';
  UPDATE products SET base_price = 145.07 WHERE code = 'XT100';
  UPDATE products SET base_price = 135.63 WHERE code = 'CS5';
  UPDATE products SET base_price = 135.63 WHERE code = 'CGL5';
  UPDATE products SET base_price = 97.61 WHERE code = 'LC120';
  UPDATE products SET base_price = 97.61 WHERE code = 'LC216';
  UPDATE products SET base_price = 107.04 WHERE code = 'LC600';
  UPDATE products SET base_price = 95.63 WHERE code = 'MS10';
  UPDATE products SET base_price = 188.87 WHERE code = 'MZ';
  UPDATE products SET base_price = 297.18 WHERE code = 'SUR10';
  UPDATE products SET base_price = 74.79 WHERE code = 'SM2';
  UPDATE products SET base_price = 80.42 WHERE code = 'TR5';
  UPDATE products SET base_price = 93.80 WHERE code = 'RT5';
  UPDATE products SET base_price = 126.06 WHERE code = 'TSM5';
  UPDATE products SET base_price = 131.83 WHERE code = '5AD';
  UPDATE products SET base_price = 101.41 WHERE code = '5AM-5';
  UPDATE products SET base_price = 110.85 WHERE code = 'ET10';
  UPDATE products SET base_price = 129.86 WHERE code = 'G5K';
  UPDATE products SET base_price = 69.01 WHERE code = 'ISU';
  UPDATE products SET base_price = 93.80 WHERE code = 'KS5';
  UPDATE products SET base_price = 78.59 WHERE code = 'OT2';
  UPDATE products SET base_price = 91.83 WHERE code = 'P41';
  UPDATE products SET base_price = 91.83 WHERE code = 'H10';
  UPDATE products SET base_price = 116.62 WHERE code = 'HX5';
  UPDATE products SET base_price = 78.59 WHERE code = 'IG01';
  UPDATE products SET base_price = 78.59 WHERE code = 'IP5';
  UPDATE products SET base_price = 99.44 WHERE code = 'SMO5';
  UPDATE products SET base_price = 97.61 WHERE code = '柠檬瓶';
  UPDATE products SET base_price = 78.59 WHERE code = 'PI5';
  UPDATE products SET base_price = 78.59 WHERE code = 'SK5';
  UPDATE products SET base_price = 78.59 WHERE code = 'XA5';
  UPDATE products SET base_price = 76.62 WHERE code = 'NJ100';
  UPDATE products SET base_price = 126.06 WHERE code = '322';
  UPDATE products SET base_price = 116.62 WHERE code = '2S10';
  UPDATE products SET base_price = 126.06 WHERE code = 'PNC 27';
  UPDATE products SET base_price = 80.42 WHERE code = 'ML10';

  -- ============================================================
  -- UPDATE PREORDER_BOX USD PRICES (safety net)
  -- ============================================================
  -- Update all preorder_box USD prices to match Excel
  UPDATE product_prices SET amount = 13.80 WHERE product_id = (SELECT id FROM products WHERE code = 'AA3' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 13.80 WHERE product_id = (SELECT id FROM products WHERE code = 'BA3' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 84.23 WHERE product_id = (SELECT id FROM products WHERE code = 'BC5' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 110.85 WHERE product_id = (SELECT id FROM products WHERE code = 'BT5' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 126.06 WHERE product_id = (SELECT id FROM products WHERE code = 'BB10' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 202.11 WHERE product_id = (SELECT id FROM products WHERE code = 'BB20' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 192.68 WHERE product_id = (SELECT id FROM products WHERE code = 'BBG70' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 173.66 WHERE product_id = (SELECT id FROM products WHERE code = 'CD5' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 126.06 WHERE product_id = (SELECT id FROM products WHERE code = 'CP10' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 116.62 WHERE product_id = (SELECT id FROM products WHERE code = 'CND5' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 135.63 WHERE product_id = (SELECT id FROM products WHERE code = 'CS5' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 135.63 WHERE product_id = (SELECT id FROM products WHERE code = 'CGL5' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 67.18 WHERE product_id = (SELECT id FROM products WHERE code = 'CBL60' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 78.59 WHERE product_id = (SELECT id FROM products WHERE code = 'DS5' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 110.85 WHERE product_id = (SELECT id FROM products WHERE code = 'ET10' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 97.61 WHERE product_id = (SELECT id FROM products WHERE code = 'GTT' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 129.86 WHERE product_id = (SELECT id FROM products WHERE code = 'G5K' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 91.83 WHERE product_id = (SELECT id FROM products WHERE code = 'H10' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 65.21 WHERE product_id = (SELECT id FROM products WHERE code = 'HA5' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 116.62 WHERE product_id = (SELECT id FROM products WHERE code = 'HX5' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 69.01 WHERE product_id = (SELECT id FROM products WHERE code = 'ISU' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 78.59 WHERE product_id = (SELECT id FROM products WHERE code = 'IG01' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 78.59 WHERE product_id = (SELECT id FROM products WHERE code = 'IP5' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 93.80 WHERE product_id = (SELECT id FROM products WHERE code = 'KS5' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 82.39 WHERE product_id = (SELECT id FROM products WHERE code = 'KPV5' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 230.70 WHERE product_id = (SELECT id FROM products WHERE code = 'KLOW80' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 95.63 WHERE product_id = (SELECT id FROM products WHERE code = 'MS10' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 84.23 WHERE product_id = (SELECT id FROM products WHERE code = 'MT1' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 80.42 WHERE product_id = (SELECT id FROM products WHERE code = 'ML10' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 188.87 WHERE product_id = (SELECT id FROM products WHERE code = 'MZ' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 76.62 WHERE product_id = (SELECT id FROM products WHERE code = 'NJ100' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 78.59 WHERE product_id = (SELECT id FROM products WHERE code = 'NP810' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 78.59 WHERE product_id = (SELECT id FROM products WHERE code = 'OT2' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 91.83 WHERE product_id = (SELECT id FROM products WHERE code = 'P41' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 78.59 WHERE product_id = (SELECT id FROM products WHERE code = 'PI5' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 126.06 WHERE product_id = (SELECT id FROM products WHERE code = 'PNC 27' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 97.61 WHERE product_id = (SELECT id FROM products WHERE code = 'RA10' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 78.59 WHERE product_id = (SELECT id FROM products WHERE code = 'SK5' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 99.44 WHERE product_id = (SELECT id FROM products WHERE code = 'SMO5' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 297.18 WHERE product_id = (SELECT id FROM products WHERE code = 'SUR10' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 116.62 WHERE product_id = (SELECT id FROM products WHERE code = 'TA5' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 126.06 WHERE product_id = (SELECT id FROM products WHERE code = 'TSM5' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 107.04 WHERE product_id = (SELECT id FROM products WHERE code = 'VIP5' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 78.59 WHERE product_id = (SELECT id FROM products WHERE code = 'XA5' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 145.07 WHERE product_id = (SELECT id FROM products WHERE code = 'XT100' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 131.83 WHERE product_id = (SELECT id FROM products WHERE code = '5AD' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 116.62 WHERE product_id = (SELECT id FROM products WHERE code = '2S10' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 101.41 WHERE product_id = (SELECT id FROM products WHERE code = '5AM-5' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 126.06 WHERE product_id = (SELECT id FROM products WHERE code = '322' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 112.82 WHERE product_id = (SELECT id FROM products WHERE code = '375' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 97.61 WHERE product_id = (SELECT id FROM products WHERE code = 'LC120' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 97.61 WHERE product_id = (SELECT id FROM products WHERE code = 'LC216' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 107.04 WHERE product_id = (SELECT id FROM products WHERE code = 'LC600' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 74.79 WHERE product_id = (SELECT id FROM products WHERE code = 'SM2' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 80.42 WHERE product_id = (SELECT id FROM products WHERE code = 'TR5' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 93.80 WHERE product_id = (SELECT id FROM products WHERE code = 'RT5' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 103.60 WHERE product_id = (SELECT id FROM products WHERE code = 'AHKCU 100' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';
  UPDATE product_prices SET amount = 97.61 WHERE product_id = (SELECT id FROM products WHERE name LIKE 'Lemon Bottle%' LIMIT 1) AND price_type = 'preorder_box' AND currency = 'USD';

END $$;

-- Migration: Add images for the remaining biohacking products that were previously skipped
-- Source: /Downloads/Biohacking remaining 6 images.zip (2026-04-24)
-- Also splits Sterile Water into two distinct products (3ml and 10ml) so each has its own image.

UPDATE products SET image_url = '/product-images/119_HCG_10000IU.png' WHERE name = 'HCG';
UPDATE products SET image_url = '/product-images/120_Vitamin-B12_10ml.png' WHERE name = 'Vitamin B12';
UPDATE products SET image_url = '/product-images/GHKcu _topical_1g.png' WHERE name = 'Cosmetic GHK-CU 1g';
UPDATE products SET image_url = '/product-images/121_Cosmetic-AHK-Cu_1g.png' WHERE name = 'Cosmetic AHK-CU 1g';
UPDATE products SET image_url = '/product-images/124_PNC-27_5mg.png' WHERE name = 'PNC-27';

-- === Split Sterile Water into two separate products ===
DO $$
DECLARE
  pid_3ml UUID;
  pid_10ml UUID;
BEGIN
  -- Rename the existing Sterile Water (code WA3) to "Sterile Water 3ml"
  UPDATE products
     SET name = 'Sterile Water 3ml',
         spec = '3ml*10vials',
         base_price = 13.80,
         image_url = '/product-images/122_Sterile-Water_3ml.png'
   WHERE code = 'WA3'
     AND name IN ('Sterile Water', 'Sterile Water 3ml');

  SELECT id INTO pid_3ml FROM products WHERE code = 'WA3' LIMIT 1;

  -- Keep only the 3ml variation on the renamed product
  IF pid_3ml IS NOT NULL THEN
    DELETE FROM product_variations WHERE product_id = pid_3ml AND name = '10ml';
    INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity)
      SELECT pid_3ml, '3ml', 3.0, 13.80, 100
       WHERE NOT EXISTS (
         SELECT 1 FROM product_variations WHERE product_id = pid_3ml AND name = '3ml'
       );
  END IF;

  -- Create the new Sterile Water 10ml product
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available, image_url)
  VALUES ('Sterile Water 10ml', 'Sterile water for reconstitution of lyophilized peptides.', 'water-reconstitution', 14.79, 99.0, 100, true, false, 'Store at room temperature', 'WA10', '10ml*10vials', 10, 'vials', true, true, '/product-images/123_Sterile-Water_10ml.png')
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid_10ml;

  IF pid_10ml IS NULL THEN
    SELECT id INTO pid_10ml FROM products WHERE code = 'WA10' LIMIT 1;
  END IF;

  IF pid_10ml IS NOT NULL THEN
    UPDATE products
       SET image_url = '/product-images/123_Sterile-Water_10ml.png'
     WHERE id = pid_10ml;

    INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity)
      SELECT pid_10ml, '10ml', 10.0, 14.79, 100
       WHERE NOT EXISTS (
         SELECT 1 FROM product_variations WHERE product_id = pid_10ml AND name = '10ml'
       );

    INSERT INTO product_prices (product_id, price_type, currency, amount)
      SELECT pid_10ml, 'preorder_box', 'USD', 14.79
       WHERE NOT EXISTS (
         SELECT 1 FROM product_prices
          WHERE product_id = pid_10ml AND price_type = 'preorder_box' AND currency = 'USD'
       );

    INSERT INTO product_categories (product_id, category_id, is_primary)
      VALUES (pid_10ml, 'water-reconstitution', true)
      ON CONFLICT DO NOTHING;
  END IF;
END $$;


-- SECTION 8.5: Complete exact BiohackingSupplier.com.xlsx line-item products
-- Source: /Users/ynadonaire/Downloads/BiohackingSupplier.com.xlsx
-- The workbook is one line item per Cat. No/spec. This block keeps the existing
-- variation products, but also ensures every workbook line item has its own
-- products row keyed by (code, spec).

WITH source (code, name, spec, price, category, image_url) AS (
  VALUES
  ('AA3', 'Acetic Acid Water 3mg', '3mg*10vials', 13.80, 'water-reconstitution', '/product-images/15_Acetic-Acid_3ml.png'),
  ('AA10', 'Acetic Acid Water 10mg', '10mg*10vials', 14.79, 'water-reconstitution', '/product-images/16_Acetic-Acid_10ml.png'),
  ('BA3', 'Bacteriostatic Water 3mg', '3mg*10vials', 13.80, 'water-reconstitution', '/product-images/17_Bacteriostatic-Water_3ml.png'),
  ('BA10', 'Bacteriostatic Water 10mg', '10mg*10vials', 14.79, 'water-reconstitution', '/product-images/BAC_Water_10ml.png'),
  ('BC10', 'BPC 157 10mg', '10mg*10vials', 99.44, 'healing-recovery', '/product-images/BPC-157-10mg.png'),
  ('BT10', 'TB500 (Thymosin B4 Acetate) 10mg', '10mg*10vials', 158.45, 'healing-recovery', '/product-images/112_TB-500_10mg.png'),
  ('CU100', 'GHK-CU 100mg', '100mg*10vials', 78.59, 'skin-hair', '/product-images/42_GHK-Cu_100mg.png'),
  ('CND10', 'CJC-1295 NO DAC 10mg', '10mg*10vials', 173.66, 'healing-recovery', '/product-images/CJC-1295-NODAC-10mg.png'),
  ('CS10', 'CagriSema 10mg', '10mg*10vials', 202.11, 'weight-loss', NULL),
  ('CGL10', 'Cagrilintide 10mg', '10mg*10vials', 181.27, 'weight-loss', '/product-images/26_Cagrilintide_10mg.png'),
  ('D15', 'DSIP 15mg', '15mg*10vials', 116.62, 'healing-recovery', NULL),
  ('ET50', 'Epithalon 50mg', '50mg*10vials', 224.93, 'anti-aging', '/product-images/Epithalon-50mg.png'),
  ('G10k', 'HCG 10000', '10000*10vials', 167.89, 'hormone-libido', '/product-images/119_HCG_10000IU.png'),
  ('H15', 'HGH 191AA (Somatropin) 15iu', '15iu*10vials', 107.04, 'growth-hormone', '/product-images/50_HGH_15iu.png'),
  ('H24', 'HGH 191AA (Somatropin) 24iu', '24iu*10vials', 145.07, 'growth-hormone', '/product-images/51_HGH_24iu.png'),
  ('IG1', 'IGF-1LR3 1mg', '1mg*10vials', 183.10, 'growth-hormone', '/product-images/54_IGF-1-LR3_1mg.png'),
  ('IP10', 'Ipamorelin 10mg', '10mg*10vials', 103.24, 'growth-hormone', '/product-images/58_Ipamorelin_10mg.png'),
  ('KS10', 'KissPeptin-10 10mg', '10mg*10vials', 126.06, 'hormone-libido', '/product-images/60_Kisspeptin-10_10mg.png'),
  ('KPV10', 'KPV 10mg', '10mg*10vials', 91.83, 'healing-recovery', '/product-images/04_KPV_10mg.png'),
  ('MS40', 'MOTS-C 40mg', '40mg*10vials', 183.10, 'weight-loss', '/product-images/71_MOTS-C_40mg.png'),
  ('NJ500', 'NAD 500mg', '500mg*10vials', 107.04, 'mitochondrial', '/product-images/NAD+_500mg.png'),
  ('PNC 27', 'PNC-27 5mg', '5mg*10vials', 173.66, 'specialty', '/product-images/124_PNC-27_5mg.png'),
  ('PI10', 'Pinealon 10mg', '10mg*10vials', 97.61, 'neuropeptides', '/product-images/79_Pinealon_10mg.png'),
  ('P20', 'Pinealon 20mg', '20mg*10vials', 116.62, 'neuropeptides', '/product-images/80_Pinealon_20mg.png'),
  ('SMO10', 'Sermorelin Acetate 10mg', '10mg*10vials', 126.06, 'growth-hormone', '/product-images/103_Sermorelin_10mg.png'),
  ('RT10', 'Retatrutide 10mg', '10mg*10vials', 116.62, 'weight-loss', '/product-images/Retatrutide_10mg.png'),
  ('RT15', 'Retatrutide 15mg', '15mg*10vials', 133.66, 'weight-loss', '/product-images/Retatrutide_15mg.png'),
  ('RT20', 'Retatrutide 20mg', '20mg*10vials', 152.68, 'weight-loss', '/product-images/Retatrutide_20mg.png'),
  ('RT30', 'Retatrutide 30mg', '30mg*10vials', 192.68, 'weight-loss', '/product-images/Retatrutide_30mg.png'),
  ('RT36', 'Retatrutide 36mg', '36mg*10vials', 216.56, 'weight-loss', '/product-images/Retatrutide_36mg.png'),
  ('RT40', 'Retatrutide 40mg', '40mg*10vials', 230.70, 'weight-loss', '/product-images/Retatrutide_40mg.png'),
  ('RT50', 'Retatrutide 50mg', '50mg*10vials', 249.72, 'weight-loss', '/product-images/Retatrutide_50mg.png'),
  ('RT60', 'Retatrutide 60mg', '60mg*10vials', 268.73, 'weight-loss', '/product-images/Retatrutide_60mg.png'),
  ('SM5', 'Semaglutide 5mg', '5mg*10vials', 78.59, 'weight-loss', '/product-images/Semaglutide_5mg.png'),
  ('SM10', 'Semaglutide 10mg', '10mg*10vials', 88.03, 'weight-loss', '/product-images/Semaglutide_10mg.png'),
  ('SM15', 'Semaglutide 15mg', '15mg*10vials', 97.61, 'weight-loss', '/product-images/Semaglutide_15mg.png'),
  ('SM20', 'Semaglutide 20mg', '20mg*10vials', 109.01, 'weight-loss', '/product-images/Semaglutide_20mg.png'),
  ('SM30', 'Semaglutide 30mg', '30mg*10vials', 126.06, 'weight-loss', '/product-images/Semaglutide_30mg.png'),
  ('SK10', 'Selank 10mg', '10mg*10vials', 91.83, 'neuropeptides', '/product-images/93_Selank_10mg.png'),
  ('TR10', 'Tirzepatide 10mg', '10mg*10vials', 90.00, 'weight-loss', '/product-images/Tirzepatide_10mg.png'),
  ('TR15', 'Tirzepatide 15mg', '15mg*10vials', 103.24, 'weight-loss', '/product-images/Tirzepatide_15mg.png'),
  ('TR20', 'Tirzepatide 20mg', '20mg*10vials', 114.65, 'weight-loss', '/product-images/Tirzepatide_20mg.png'),
  ('TR30', 'Tirzepatide 30mg', '30mg*10vials', 131.83, 'weight-loss', '/product-images/Tirzepatide_30mg.png'),
  ('TR40', 'Tirzepatide 40mg', '40mg*10vials', 148.87, 'weight-loss', '/product-images/Tirzepatide_40mg.png'),
  ('TR50', 'Tirzepatide 50mg', '50mg*10vials', 167.89, 'weight-loss', '/product-images/Tirzepatide_50mg.png'),
  ('TR60', 'Tirzepatide 60mg', '60mg*10vials', 186.90, 'weight-loss', '/product-images/Tirzepatide_60mg.png'),
  ('TR100', 'Tirzepatide 100mg', '100mg*10vials', 278.68, 'weight-loss', '/product-images/Tirzepatide 100mg.png'),
  ('TA10', 'Thymosin Alpha-1 10mg', '10mg*10vials', 173.66, 'healing-recovery', '/product-images/118_Thymosin-Alpha-1_10mg.png'),
  ('TSM10', 'Tesamorelin 10mg', '10mg*10vials', 183.10, 'weight-loss', '/product-images/114_Tesamorelin_10mg.png'),
  ('TSM15', 'Tesamorelin 15mg', '15mg*10vials', 256.80, 'weight-loss', '/product-images/115_Tesamorelin_15mg.png'),
  ('TSM20', 'Tesamorelin 20mg', '20mg*10vials', 301.60, 'weight-loss', '/product-images/116_Tesamorelin_20mg.png'),
  ('VIP10', 'VIP 10mg', '10mg*10vials', 154.65, 'healing-recovery', '/product-images/VIP-10mg.png'),
  ('WA3', 'BAC Water 3mg', '3mg*10vials', 53.80, 'water-reconstitution', '/product-images/122_Sterile-Water_3ml.png'),
  ('WA10', 'BAC Water 10mg', '10mg*10vials', 54.79, 'water-reconstitution', '/product-images/123_Sterile-Water_10ml.png'),
  ('XA10', 'Semax 10mg', '10mg*10vials', 88.03, 'neuropeptides', '/product-images/101_Semax_10mg.png'),
  ('375', 'LL37', '5mg*10vials', 112.82, 'healing-recovery', '/product-images/68_LL-37_5mg.png'),
  ('10AD', 'AOD-9604 10mg', '10mg*10vials', 189.80, 'weight-loss', NULL),
  ('322', 'SLU-PP-322', '5mg*10vials', 126.06, 'mitochondrial', '/product-images/105_SLU-PP-322_5mg.png'),
  ('2S50', 'SS-31 50mg', '50mg*10vials', 278.17, 'mitochondrial', '/product-images/SS-31_50mg.png'),
  ('5AM-10', '5-amino-1mq 10mg', '10mg*10vials', 116.00, 'weight-loss', '/product-images/07_5-Amino-1MQ_10mg.png'),
  ('5AM-50', '5-amino-1mq 50mg', '50mg*10vials', 145.60, 'weight-loss', '/product-images/5-Amino-1MQ-50mg.png')
)
INSERT INTO public.products (
  name, description, category, base_price, purity_percentage, stock_quantity,
  available, featured, storage_conditions, code, spec, units_per_pack, unit_type,
  onhand_available, preorder_available, image_url
)
SELECT
  source.name,
  'BiohackingSupplier.com workbook line item.',
  source.category,
  source.price,
  99.0,
  100,
  true,
  false,
  CASE WHEN source.category = 'water-reconstitution' THEN 'Store at room temperature' ELSE 'Store at -20°C, protect from light' END,
  source.code,
  source.spec,
  10,
  CASE WHEN source.spec ILIKE '%tube%' THEN 'tube' ELSE 'vials' END,
  true,
  true,
  source.image_url
FROM source
ON CONFLICT (code, spec) WHERE code IS NOT NULL AND spec IS NOT NULL
DO UPDATE SET
  base_price = EXCLUDED.base_price,
  category = EXCLUDED.category,
  stock_quantity = GREATEST(COALESCE(public.products.stock_quantity, 0), EXCLUDED.stock_quantity),
  available = true,
  preorder_available = true,
  image_url = COALESCE(public.products.image_url, EXCLUDED.image_url),
  updated_at = timezone('utc'::text, now());

WITH source (code, spec, price) AS (
  VALUES
  ('AA3', '3mg*10vials', 13.80), ('AA10', '10mg*10vials', 14.79),
  ('BA3', '3mg*10vials', 13.80), ('BA10', '10mg*10vials', 14.79),
  ('BC10', '10mg*10vials', 99.44), ('BT10', '10mg*10vials', 158.45),
  ('CU100', '100mg*10vials', 78.59), ('CND10', '10mg*10vials', 173.66),
  ('CS10', '10mg*10vials', 202.11), ('CGL10', '10mg*10vials', 181.27),
  ('D15', '15mg*10vials', 116.62), ('ET50', '50mg*10vials', 224.93),
  ('G10k', '10000*10vials', 167.89), ('H15', '15iu*10vials', 107.04),
  ('H24', '24iu*10vials', 145.07), ('IG1', '1mg*10vials', 183.10),
  ('IP10', '10mg*10vials', 103.24), ('KS10', '10mg*10vials', 126.06),
  ('KPV10', '10mg*10vials', 91.83), ('MS40', '40mg*10vials', 183.10),
  ('NJ500', '500mg*10vials', 107.04), ('PNC 27', '5mg*10vials', 173.66),
  ('PI10', '10mg*10vials', 97.61), ('P20', '20mg*10vials', 116.62),
  ('SMO10', '10mg*10vials', 126.06), ('RT10', '10mg*10vials', 116.62),
  ('RT15', '15mg*10vials', 133.66), ('RT20', '20mg*10vials', 152.68),
  ('RT30', '30mg*10vials', 192.68), ('RT36', '36mg*10vials', 216.56),
  ('RT40', '40mg*10vials', 230.70), ('RT50', '50mg*10vials', 249.72),
  ('RT60', '60mg*10vials', 268.73), ('SM5', '5mg*10vials', 78.59),
  ('SM10', '10mg*10vials', 88.03), ('SM15', '15mg*10vials', 97.61),
  ('SM20', '20mg*10vials', 109.01), ('SM30', '30mg*10vials', 126.06),
  ('SK10', '10mg*10vials', 91.83), ('TR10', '10mg*10vials', 90.00),
  ('TR15', '15mg*10vials', 103.24), ('TR20', '20mg*10vials', 114.65),
  ('TR30', '30mg*10vials', 131.83), ('TR40', '40mg*10vials', 148.87),
  ('TR50', '50mg*10vials', 167.89), ('TR60', '60mg*10vials', 186.90),
  ('TR100', '100mg*10vials', 278.68), ('TA10', '10mg*10vials', 173.66),
  ('TSM10', '10mg*10vials', 183.10), ('TSM15', '15mg*10vials', 256.80),
  ('TSM20', '20mg*10vials', 301.60), ('VIP10', '10mg*10vials', 154.65),
  ('WA3', '3mg*10vials', 53.80), ('WA10', '10mg*10vials', 54.79),
  ('XA10', '10mg*10vials', 88.03), ('10AD', '10mg*10vials', 189.80),
  ('375', '5mg*10vials', 112.82), ('322', '5mg*10vials', 126.06),
  ('2S50', '50mg*10vials', 278.17), ('5AM-10', '10mg*10vials', 116.00),
  ('5AM-50', '50mg*10vials', 145.60)
)
INSERT INTO public.product_prices (product_id, price_type, currency, amount)
SELECT p.id, 'preorder_box', 'USD', source.price
FROM source
JOIN public.products p ON p.code = source.code AND p.spec = source.spec
ON CONFLICT (product_id, price_type, currency, min_qty)
DO UPDATE SET amount = EXCLUDED.amount, updated_at = now();

WITH source (code, spec, category) AS (
  VALUES
  ('AA3', '3mg*10vials', 'water-reconstitution'), ('AA10', '10mg*10vials', 'water-reconstitution'),
  ('BA3', '3mg*10vials', 'water-reconstitution'), ('BA10', '10mg*10vials', 'water-reconstitution'),
  ('BC10', '10mg*10vials', 'healing-recovery'), ('BT10', '10mg*10vials', 'healing-recovery'),
  ('CU100', '100mg*10vials', 'skin-hair'), ('CND10', '10mg*10vials', 'healing-recovery'),
  ('CS10', '10mg*10vials', 'weight-loss'), ('CGL10', '10mg*10vials', 'weight-loss'),
  ('D15', '15mg*10vials', 'healing-recovery'), ('ET50', '50mg*10vials', 'anti-aging'),
  ('G10k', '10000*10vials', 'hormone-libido'), ('H15', '15iu*10vials', 'growth-hormone'),
  ('H24', '24iu*10vials', 'growth-hormone'), ('IG1', '1mg*10vials', 'growth-hormone'),
  ('IP10', '10mg*10vials', 'growth-hormone'), ('KS10', '10mg*10vials', 'hormone-libido'),
  ('KPV10', '10mg*10vials', 'healing-recovery'), ('MS40', '40mg*10vials', 'weight-loss'),
  ('NJ500', '500mg*10vials', 'mitochondrial'), ('PNC 27', '5mg*10vials', 'specialty'),
  ('PI10', '10mg*10vials', 'neuropeptides'), ('P20', '20mg*10vials', 'neuropeptides'),
  ('SMO10', '10mg*10vials', 'growth-hormone'), ('RT10', '10mg*10vials', 'weight-loss'),
  ('RT15', '15mg*10vials', 'weight-loss'), ('RT20', '20mg*10vials', 'weight-loss'),
  ('RT30', '30mg*10vials', 'weight-loss'), ('RT36', '36mg*10vials', 'weight-loss'),
  ('RT40', '40mg*10vials', 'weight-loss'), ('RT50', '50mg*10vials', 'weight-loss'),
  ('RT60', '60mg*10vials', 'weight-loss'), ('SM5', '5mg*10vials', 'weight-loss'),
  ('SM10', '10mg*10vials', 'weight-loss'), ('SM15', '15mg*10vials', 'weight-loss'),
  ('SM20', '20mg*10vials', 'weight-loss'), ('SM30', '30mg*10vials', 'weight-loss'),
  ('SK10', '10mg*10vials', 'neuropeptides'), ('TR10', '10mg*10vials', 'weight-loss'),
  ('TR15', '15mg*10vials', 'weight-loss'), ('TR20', '20mg*10vials', 'weight-loss'),
  ('TR30', '30mg*10vials', 'weight-loss'), ('TR40', '40mg*10vials', 'weight-loss'),
  ('TR50', '50mg*10vials', 'weight-loss'), ('TR60', '60mg*10vials', 'weight-loss'),
  ('TR100', '100mg*10vials', 'weight-loss'), ('TA10', '10mg*10vials', 'healing-recovery'),
  ('TSM10', '10mg*10vials', 'weight-loss'), ('TSM15', '15mg*10vials', 'weight-loss'),
  ('TSM20', '20mg*10vials', 'weight-loss'), ('VIP10', '10mg*10vials', 'healing-recovery'),
  ('WA3', '3mg*10vials', 'water-reconstitution'), ('WA10', '10mg*10vials', 'water-reconstitution'),
  ('XA10', '10mg*10vials', 'neuropeptides'), ('10AD', '10mg*10vials', 'weight-loss'),
  ('375', '5mg*10vials', 'healing-recovery'), ('322', '5mg*10vials', 'mitochondrial'),
  ('2S50', '50mg*10vials', 'mitochondrial'), ('5AM-10', '10mg*10vials', 'weight-loss'),
  ('5AM-50', '50mg*10vials', 'weight-loss')
)
INSERT INTO public.product_categories (product_id, category_id, is_primary)
SELECT p.id, source.category, true
FROM source
JOIN public.products p ON p.code = source.code AND p.spec = source.spec
ON CONFLICT DO NOTHING;


-- SECTION 9: Protocols table and seed content

-- =====================================================================
-- SETUP PROTOCOLS: creates the protocols table + RLS policies + seeds
-- Run this ONCE in Supabase SQL Editor.
-- Safe to re-run: it drops existing rows before seeding.
-- =====================================================================

-- 1. Table -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS protocols (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  dosage TEXT NOT NULL,
  frequency TEXT NOT NULL,
  duration TEXT NOT NULL,
  notes TEXT[] DEFAULT '{}',
  storage TEXT NOT NULL,
  sort_order INTEGER DEFAULT 0,
  active BOOLEAN DEFAULT true,
  product_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_protocols_product_id ON protocols(product_id);

-- 2. Row Level Security -----------------------------------------------
ALTER TABLE protocols ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can read active protocols" ON protocols;
CREATE POLICY "Public can read active protocols" ON protocols
  FOR SELECT USING (active = true);

DROP POLICY IF EXISTS "Admins can manage protocols" ON protocols;
CREATE POLICY "Admins can manage protocols" ON protocols
  FOR ALL USING (true) WITH CHECK (true);

-- 3. Seed data ---------------------------------------------------------
DELETE FROM protocols;

INSERT INTO protocols (name, category, dosage, frequency, duration, notes, storage, sort_order, active) VALUES

('Tirzepetide 15MG Protocol', 'Weight Management', '2.5mg - 7.5mg weekly (dose based on vial size)', 'Once weekly on the same day', '12-16 weeks per cycle',
 ARRAY['Start with 2.5mg for first 4 weeks', 'Increase by 2.5mg every 4 weeks as tolerated', 'This is the 15mg vial - yields multiple doses', 'Inject subcutaneously in abdomen, thigh, or upper arm', 'Take with or without food', 'Rotate injection sites'],
 'Refrigerate at 2-8C. Once in use, can be kept at room temperature for up to 21 days.', 1, true),

('Tirzepetide 30MG Protocol', 'Weight Management', '5mg - 15mg weekly (higher dose vial)', 'Once weekly on the same day', '12-16 weeks per cycle',
 ARRAY['Start with 5mg for first 4 weeks if experienced', 'Increase by 2.5-5mg every 4 weeks as tolerated', 'Maximum dose is 15mg weekly', 'This larger vial offers more flexibility', 'Inject subcutaneously', 'May cause nausea initially - eat smaller meals'],
 'Refrigerate at 2-8C.', 2, true),

('NAD+ 500MG Protocol', 'Longevity & Anti-Aging', '100mg - 250mg daily', 'Once daily, preferably morning', '8-12 weeks per cycle',
 ARRAY['Start with 100mg and increase gradually', 'Subcutaneous or intramuscular injection', 'Higher dose vial allows extended use', 'Take in morning to avoid sleep disruption', 'Supports cellular energy and repair', 'Some initial flushing is normal'],
 'Refrigerate after reconstitution. Protect from light.', 3, true),

('GHK CU 50MG Protocol', 'Beauty & Regeneration', '1mg - 2mg daily', 'Once daily', '8-12 weeks per cycle',
 ARRAY['Can be used topically or via injection', 'Promotes collagen synthesis', 'Supports skin elasticity and wound healing', 'Also used for hair regrowth', 'Copper peptide with many benefits', 'Safe for long-term use'],
 'Refrigerate after reconstitution.', 4, true),

('GHK CU 100MG Protocol', 'Beauty & Regeneration', '2mg - 3mg daily', 'Once daily', '8-12 weeks per cycle',
 ARRAY['Higher concentration for extended protocols', 'Excellent for anti-aging protocols', 'Can inject near treatment area', 'Supports tissue repair', 'Works synergistically with other peptides', 'Monitor for copper sensitivity'],
 'Refrigerate after reconstitution.', 5, true),

('DSIP 5MG Protocol', 'Sleep & Recovery', '100mcg - 300mcg before bed', 'Once daily, 30 min before sleep', '2-4 weeks per cycle',
 ARRAY['Start with 100mcg to assess tolerance', 'Promotes deep, restorative sleep', 'Do not combine with other sedatives', 'Effects build over several days', 'Take 2-4 week breaks between cycles', 'Subcutaneous injection preferred'],
 'Refrigerate after reconstitution.', 6, true),

('DSIP 15MG Protocol', 'Sleep & Recovery', '200mcg - 400mcg before bed', 'Once daily, 30 min before sleep', '4-6 weeks per cycle',
 ARRAY['Larger vial for extended sleep support', 'Gradually increase dose as needed', 'Supports natural sleep architecture', 'May help with stress-related insomnia', 'Avoid alcohol when using', 'Take breaks to prevent tolerance'],
 'Refrigerate after reconstitution.', 7, true),

('Glutathione 1500MG Protocol', 'Detox & Skin Brightening', '200mg - 500mg every other day', '3-4 times weekly', '8-12 weeks per cycle',
 ARRAY['Master antioxidant for detoxification', 'Skin brightening and evening tone', 'Can inject subcutaneously or intramuscularly', 'Often combined with Vitamin C', 'Supports liver function', 'Results visible after 4-6 weeks'],
 'Refrigerate. Protect from light and heat.', 8, true),

('Lipo C with B12 Protocol', 'Fat Burning & Energy', '1ml injection', '2-3 times weekly', 'Ongoing or 8-12 week cycles',
 ARRAY['Lipotropic injection for fat metabolism', 'Boosts energy and metabolism', 'Inject intramuscularly in thigh or buttock', 'Best combined with exercise program', 'Supports liver fat processing', 'B12 provides energy boost'],
 'Refrigerate. Protect from light.', 9, true),

('SS31 10MG Protocol', 'Mitochondrial Health', '5mg - 10mg daily', 'Once daily', '4-6 weeks per cycle',
 ARRAY['Targets inner mitochondrial membrane', 'Protects against oxidative stress', 'Supports cellular energy production', 'Inject subcutaneously', 'Best taken in morning', 'Take 4-week breaks between cycles'],
 'Refrigerate. Protect from light.', 10, true),

('SS31 50MG Protocol', 'Mitochondrial Health', '10mg - 20mg daily', 'Once daily', '4-8 weeks per cycle',
 ARRAY['Higher dose for intensive protocols', 'Advanced mitochondrial support', 'Anti-aging at cellular level', 'Monitor energy levels', 'May enhance exercise performance', 'Rotate injection sites'],
 'Refrigerate. Protect from light.', 11, true),

('MOTS C 10MG Protocol', 'Metabolic Health', '5mg twice weekly', 'Twice weekly (e.g., Mon/Thu)', '8-12 weeks per cycle',
 ARRAY['Mitochondrial-derived peptide', 'Improves insulin sensitivity', 'Enhances exercise capacity', 'Take before exercise for best results', 'Supports metabolic health', 'Intramuscular or subcutaneous'],
 'Refrigerate after reconstitution.', 12, true),

('MOTS C 40MG Protocol', 'Metabolic Health', '10mg twice weekly', 'Twice weekly (e.g., Mon/Thu)', '8-12 weeks per cycle',
 ARRAY['Higher dose for intensive protocols', 'Enhanced metabolic optimization', 'Great for athletes and active users', 'Best taken pre-workout', 'Supports weight management', 'Monitor blood glucose if diabetic'],
 'Refrigerate after reconstitution.', 13, true),

('KLOW (CU50+TB10+BC10+KPV10) Protocol', 'Healing & Anti-Inflammatory', 'As pre-mixed or follow component ratios', 'Once daily', '6-8 weeks per cycle',
 ARRAY['Powerful combination stack', 'GHK-Cu for regeneration', 'TB-500 for tissue repair', 'BPC-157 for healing', 'KPV for anti-inflammatory', 'All-in-one healing protocol'],
 'Refrigerate after reconstitution.', 14, true),

('Lemon Bottle 10MG Protocol', 'Fat Dissolving', 'Apply as directed to treatment area', 'Weekly treatments', '4-6 sessions typically',
 ARRAY['Lipolytic solution for fat reduction', 'Professional application recommended', 'Targets stubborn fat deposits', 'Massage after application', 'Results visible after 2-3 sessions', 'Avoid strenuous exercise 24hours after'],
 'Refrigerate. Keep away from direct sunlight.', 15, true),

('KPV 10MG + GHKCu 50MG Protocol', 'Anti-Inflammatory & Regeneration', 'KPV: 200mcg + GHKCu: 1mg daily', 'Once daily', '6-8 weeks per cycle',
 ARRAY['Synergistic anti-inflammatory combo', 'KPV reduces inflammation', 'GHKCu promotes tissue repair', 'Great for skin and gut health', 'Subcutaneous injection', 'Can split doses AM/PM'],
 'Refrigerate after reconstitution.', 16, true),

('Snap-8 (Botox in a Bottle) Protocol', 'Anti-Wrinkle', 'Apply topically to wrinkle-prone areas', 'Twice daily', 'Ongoing use',
 ARRAY['Topical anti-wrinkle peptide', 'Apply to forehead, crows feet, frown lines', 'Works by relaxing facial muscles', 'Visible results in 2-4 weeks', 'Safe for daily use', 'Can layer under moisturizer'],
 'Store at room temperature. Keep sealed.', 17, true),

('GHKCu Cosmetic Grade (1 gram) Protocol', 'Professional Cosmetic Use', 'Mix into serums: 0.1-0.5% concentration', 'Daily as part of skincare routine', 'Ongoing use',
 ARRAY['High-grade copper peptide powder', 'Mix into your preferred serum base', 'Start with lower concentration', 'Store mixed serum in dark bottle', 'Promotes collagen and elastin', 'Professional skincare formulation'],
 'Store powder in freezer. Mixed serum refrigerate.', 18, true),

('Semax 10MG + Selank 10MG Protocol', 'Cognitive Enhancement', 'Semax: 300mcg + Selank: 250mcg daily', '1-2 times daily', '2-4 weeks per cycle',
 ARRAY['Powerful nootropic combination', 'Semax for focus and memory', 'Selank for anxiety and stress', 'Intranasal or subcutaneous', 'Best taken morning/early afternoon', 'Take breaks between cycles'],
 'Refrigerate. Use within 30 days.', 19, true),

('KPV 5MG Protocol', 'Anti-Inflammatory', '100mcg - 200mcg daily', 'Once daily', '4-8 weeks per cycle',
 ARRAY['Potent anti-inflammatory peptide', 'Alpha-MSH fragment', 'Gut health and skin conditions', 'Subcutaneous injection', 'No significant side effects', 'Works systemically'],
 'Refrigerate after reconstitution.', 20, true),

('KPV 10MG Protocol', 'Anti-Inflammatory', '200mcg - 400mcg daily', 'Once or twice daily', '4-8 weeks per cycle',
 ARRAY['Higher dose for stronger effect', 'Excellent for inflammatory conditions', 'Can split dose morning/evening', 'Supports gut barrier function', 'Anti-microbial properties', 'Safe for extended use'],
 'Refrigerate after reconstitution.', 21, true),

('Tesamorelin 5MG Protocol', 'Growth Hormone', '1mg daily', 'Once daily before bed on empty stomach', '12-26 weeks per cycle',
 ARRAY['FDA-approved GHRH analog', 'Reduces visceral fat', 'Inject subcutaneously in abdomen', 'No food 2 hours before/after', 'Stimulates natural GH release', 'Monitor IGF-1 levels'],
 'Refrigerate at 2-8C.', 22, true),

('Tesamorelin 10MG Protocol', 'Growth Hormone', '1mg - 2mg daily', 'Once daily before bed on empty stomach', '12-26 weeks per cycle',
 ARRAY['Larger vial for extended use', 'Same protocol as 5MG', 'Consistent timing important', 'Best taken before bed', 'Avoid eating after injection', 'Results visible after 8-12 weeks'],
 'Refrigerate at 2-8C.', 23, true),

('Epitalon 10MG Protocol', 'Longevity & Anti-Aging', '5mg - 10mg daily for 10-20 days', 'Once daily, preferably before bed', '10-20 day cycles, 4-6 months apart',
 ARRAY['Telomere elongation peptide', 'Short intense cycles', 'Promotes melatonin production', 'Anti-aging at DNA level', 'Take 2-3 cycles per year', 'Subcutaneous injection'],
 'Refrigerate. Stable for 6 months.', 24, true),

('Epitalon 50MG Protocol', 'Longevity & Anti-Aging', '10mg daily for 10-20 days', 'Once daily, preferably before bed', '10-20 day cycles, 4-6 months apart',
 ARRAY['Higher dose vial for multiple cycles', 'Ultimate longevity peptide', 'Resets biological clock', 'Improves sleep quality', 'Supports immune function', 'Visible anti-aging effects'],
 'Refrigerate. Stable for 6 months.', 25, true),

('PT141 10MG Protocol', 'Sexual Wellness', '500mcg - 2mg as needed', 'As needed, 1-2 hours before activity', 'Use as needed, 24hr minimum between doses',
 ARRAY['Also known as Bremelanotide', 'Start with 500mcg to assess tolerance', 'Effects last 24-72 hours', 'Inject subcutaneously 45min-2hours before', 'May cause nausea initially', 'Maximum once per 24 hours'],
 'Refrigerate. Use within 30 days.', 26, true);


-- SECTION 10: Protocol file/image upload support
ALTER TABLE public.protocols ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE public.protocols ADD COLUMN IF NOT EXISTS content_type TEXT NOT NULL DEFAULT 'text';
ALTER TABLE public.protocols ADD COLUMN IF NOT EXISTS file_url TEXT;
ALTER TABLE public.protocols DROP CONSTRAINT IF EXISTS protocols_product_id_fkey;
ALTER TABLE public.protocols
  ADD CONSTRAINT protocols_product_id_fkey
  FOREIGN KEY (product_id)
  REFERENCES public.products(id)
  ON DELETE SET NULL;
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) VALUES ('protocol-files', 'protocol-files', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'application/pdf']) ON CONFLICT (id) DO NOTHING;
DROP POLICY IF EXISTS "Public can read protocol files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload protocol files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update protocol files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete protocol files" ON storage.objects;
CREATE POLICY "Public can read protocol files" ON storage.objects FOR SELECT TO public USING (bucket_id = 'protocol-files');
CREATE POLICY "Authenticated users can upload protocol files" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'protocol-files');
CREATE POLICY "Authenticated users can update protocol files" ON storage.objects FOR UPDATE TO authenticated USING (bucket_id = 'protocol-files') WITH CHECK (bucket_id = 'protocol-files');
CREATE POLICY "Authenticated users can delete protocol files" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'protocol-files');


-- SECTION 11: Final schema cache reload and verification
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS order_number TEXT;
NOTIFY pgrst, 'reload schema';
SELECT 'products' AS table_name, count(*) AS rows FROM public.products UNION ALL SELECT 'product_images', count(*) FROM public.products WHERE image_url IS NOT NULL UNION ALL SELECT 'categories', count(*) FROM public.categories UNION ALL SELECT 'protocols', count(*) FROM public.protocols;
