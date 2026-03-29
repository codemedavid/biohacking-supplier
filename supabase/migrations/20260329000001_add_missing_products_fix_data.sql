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
