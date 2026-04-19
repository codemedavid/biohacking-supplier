-- ==============================================================
-- Add 2 missing Excel variations (Glutathione 1500mg, PNC-27 5mg*10vials)
-- Against BiohackingSupplier.com pricelist
-- ==============================================================

BEGIN;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('051bcadc-5041-5731-b5ff-16e7bbfab560', 'Glutathione (Boxed)', 'Research grade peptide for scientific study.', 'skin-hair', 97.6100, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'GTT', '1500mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('7e81e858-8736-532d-af25-cfac67d88126', 'PNC-27 *10mg', 'Research grade peptide for scientific study.', 'specialty', 173.6600, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'PNC 27', '5mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

COMMIT;
