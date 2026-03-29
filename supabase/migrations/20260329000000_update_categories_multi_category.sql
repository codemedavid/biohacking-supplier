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
