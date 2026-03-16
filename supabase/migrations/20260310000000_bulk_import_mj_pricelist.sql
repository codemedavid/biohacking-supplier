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

  -- === TB500(Thymosin B4 Acetate） ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('TB500(Thymosin B4 Acetate）', 'Thymosin Beta-4 peptide studied for wound healing and tissue regeneration.', 'research', 613.80, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'BT5', '5mg*10vials', 10, 'vials', true, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'TB500(Thymosin B4 Acetate）' LIMIT 1; END IF;

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

  -- === HGH 191AA (Somatropin） ===
  INSERT INTO products (name, description, category, base_price, purity_percentage, stock_quantity, available, featured, storage_conditions, code, spec, units_per_pack, unit_type, onhand_available, preorder_available)
  VALUES ('HGH 191AA (Somatropin）', 'Human Growth Hormone 191AA (Somatropin) for growth research.', 'research', 495.00, 99.0, 100, true, false, 'Store at -20°C, protect from light', 'H10', '10iu*10vials', 10, 'vials', false, true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO pid;
  IF pid IS NULL THEN SELECT id INTO pid FROM products WHERE name = 'HGH 191AA (Somatropin）' LIMIT 1; END IF;

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