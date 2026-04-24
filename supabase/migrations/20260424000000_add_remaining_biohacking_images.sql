-- Migration: Add images for the remaining biohacking products that were previously skipped
-- Source: /Downloads/Biohacking remaining 6 images.zip (2026-04-24)
-- Also splits Sterile Water into two distinct products (3ml and 10ml) so each has its own image.

UPDATE products SET image_url = '/product-images/119_HCG_10000IU.png' WHERE name = 'HCG';
UPDATE products SET image_url = '/product-images/120_Vitamin-B12_10ml.png' WHERE name = 'Vitamin B12';
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
