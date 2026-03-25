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

  -- === TB500(Thymosin B4 Acetate） ===
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

  -- === HGH 191AA (Somatropin） ===
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