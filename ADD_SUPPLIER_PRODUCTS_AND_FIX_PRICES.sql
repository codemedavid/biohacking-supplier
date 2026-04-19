-- ==============================================================
-- Peptide website: add missing supplier products + variations,
-- plus fix 5 price mismatches against BiohackingSupplier.com pricelist
-- ==============================================================

BEGIN;

-- ------------------------------------------------------------
-- 1) PRICE FIXES (website base_price corrected to match supplier)
-- ------------------------------------------------------------

-- PNC-27: $173.66 -> $126.06 (Excel: 5mg*5vials = $126.06)
UPDATE public.products SET base_price = 126.06, updated_at = now()
  WHERE code = 'PNC 27' AND name = 'PNC-27';

-- LL37 (Excel code 375): $627.00 -> $112.82 (Excel: 5mg*10vials = $112.82)
UPDATE public.products SET base_price = 112.82, code = '375', updated_at = now()
  WHERE name = 'LL37';

-- AHK-CU (Excel code AHKCU 100): $683.76 -> $103.60 (Excel: 100mg*10vials = $103.60)
UPDATE public.products SET base_price = 103.60, code = 'AHKCU 100', updated_at = now()
  WHERE code = 'AU100' AND name = 'AHK-CU';

-- SLU-PP-322 (Excel code 322): $1023.00 -> $126.06 (Excel: 5mg*10vials = $126.06)
UPDATE public.products SET base_price = 126.06, code = '322', updated_at = now()
  WHERE name = 'SLU-PP-322';

-- Lemon Bottle (Excel code 柠檬瓶): $660.00 -> $97.61 (Excel: 10mg*10vials = $97.61)
UPDATE public.products SET base_price = 97.61, updated_at = now()
  WHERE code = 'Lemon Bottle' AND name = 'Lemon Bottle';

-- ------------------------------------------------------------
-- 2) NEW PRODUCTS + DOSAGE VARIATIONS (INSERT ... ON CONFLICT)
-- ------------------------------------------------------------

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('a043ecd3-b7f8-5a2f-a6c8-8c300d01f365', 'Acetic Acid Water', 'Acetic acid water 0.6% for peptide reconstitution research.', 'water-reconstitution', 14.7900, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'AA10', '10ml*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('387caeac-6e4a-5c16-9f9b-c2167025b23e', 'Bacteriostatic Water', 'Benzyl alcohol 0.9% bacteriostatic water for peptide reconstitution research.', 'water-reconstitution', 14.7900, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'BA10', '10ml*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('2f7eb5f0-d552-59c0-8c12-3523b67fecad', 'Sterile Water', 'Sterile water for injection — peptide reconstitution research.', 'water-reconstitution', 13.8000, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'WA3', '3ml*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('7364a8f5-0a95-5b21-acfb-44076125930b', 'Sterile Water', 'Sterile water for injection — peptide reconstitution research.', 'water-reconstitution', 14.7900, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'WA10', '10ml*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('7b70e699-76ff-53cb-ab48-02a5b40e3d33', 'BPC 157', 'Body Protection Compound peptide known for tissue repair and recovery research.', 'healing-recovery', 99.4400, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'BC10', '10mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('ded78a54-642f-5582-9caa-146b4be057a3', 'TB500 (Thymosin B4 Acetate)', 'Thymosin Beta-4 peptide studied for wound healing and tissue regeneration.', 'healing-recovery', 158.4500, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'BT10', '10mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('272766bb-f0d0-545f-b7e4-104cecdf7147', 'CJC-1295 NO DAC', 'Modified GHRH analog without Drug Affinity Complex for growth hormone studies.', 'healing-recovery', 173.6600, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'CND10', '10mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('629f3b9f-ed9f-513a-b612-b9a77944657d', 'DSIP', 'Delta Sleep-Inducing Peptide for sleep regulation and stress response research.', 'healing-recovery', 116.6200, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'D15', '15mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('b2f5b230-cc7e-5a78-9666-85bcb49184db', '(KPV) LYSINE-PROLINE-VALINE', 'KPV anti-inflammatory tripeptide for gut health and skin research.', 'healing-recovery', 91.8300, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'KPV10', '10mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('95aec13a-9cc6-5769-a351-87970a0eef72', 'Thymosin Alpha-1', 'Immune-modulating peptide for immune system enhancement research.', 'healing-recovery', 173.6600, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'TA10', '10mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('2145bc66-75a0-5d46-b5f5-7acc637eadf0', '(VIP) Vasoactive Intestinal Peptide', 'Neuropeptide for immune modulation, respiratory, and gut health research.', 'healing-recovery', 154.6500, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'VIP10', '10mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('2e904e9e-96b2-50ac-9cd5-16f70c22f26a', 'GHK-CU', 'Copper peptide complex with regenerative and anti-aging research applications.', 'skin-hair', 78.5900, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'CU100', '100mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('a20c33c6-1caf-5818-8395-c140cb0b8188', 'Cosmetic GHK-Cu 1g', 'Cosmetic-grade GHK-Cu copper tripeptide for topical skin research.', 'skin-hair', 34.8900, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'CU 1g', '1g*1tube', 1, 'tube', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('054fbbab-1eb7-529a-9cf5-f38a570c458f', 'Cosmetic AHK-Cu 1g', 'Cosmetic-grade AHK-Cu copper peptide for topical skin and hair research.', 'skin-hair', 44.8900, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'AHKCU 1g', '1g*1tube', 1, 'tube', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('d85dc054-2e96-59a3-8b35-4e0ef4add355', 'CagriSema (Cagrilintide 5mg + Semaglutide 5mg)', 'Cagrilintide 5mg + Semaglutide 5mg combination blend for advanced metabolic research.', 'weight-loss', 202.1100, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'CS10', '10mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('79e7ff04-c246-5aee-862b-cc5a93d86e9d', 'Cagrilintide', 'Long-acting amylin analog peptide for metabolic and appetite research.', 'weight-loss', 181.2700, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'CGL10', '10mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('1190fc0e-f34b-520f-b50a-90d607313eaf', 'MOTS-C', 'Mitochondrial-derived peptide for metabolic regulation and exercise mimetic research.', 'weight-loss', 183.1000, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'MS40', '40mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('da824447-9ffb-5bf4-9f2b-17060a17cc6a', 'Semaglutide', 'GLP-1 receptor agonist peptide for metabolic research.', 'weight-loss', 78.5900, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'SM5', '5mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('3d6c7685-797a-5782-a0e8-1bee28122d24', 'Semaglutide', 'GLP-1 receptor agonist peptide for metabolic research.', 'weight-loss', 88.0300, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'SM10', '10mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('a5b03c80-ca81-5b26-bb55-c59a8cf0fd31', 'Semaglutide', 'GLP-1 receptor agonist peptide for metabolic research.', 'weight-loss', 97.6100, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'SM15', '15mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('cebe70e4-48e9-5b79-9d51-ddebab5ba560', 'Semaglutide', 'GLP-1 receptor agonist peptide for metabolic research.', 'weight-loss', 109.0100, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'SM20', '20mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('f4e7c47b-68fa-563b-bc37-f63c06c97de4', 'Semaglutide', 'GLP-1 receptor agonist peptide for metabolic research.', 'weight-loss', 126.0600, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'SM30', '30mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('9150da60-7fb3-57bd-b611-f5f45064bf2b', 'Tirzepatide', 'Dual GIP/GLP-1 receptor agonist peptide for advanced metabolic studies.', 'weight-loss', 90.0000, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'TR10', '10mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('8668a17e-b39d-5b01-ab4c-d753b410a029', 'Tirzepatide', 'Dual GIP/GLP-1 receptor agonist peptide for advanced metabolic studies.', 'weight-loss', 103.2400, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'TR15', '15mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('c3e04791-0071-565d-89ab-770928a1a5a9', 'Tirzepatide', 'Dual GIP/GLP-1 receptor agonist peptide for advanced metabolic studies.', 'weight-loss', 114.6500, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'TR20', '20mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('c873fede-40e4-5db3-9929-b43279fd63e9', 'Tirzepatide', 'Dual GIP/GLP-1 receptor agonist peptide for advanced metabolic studies.', 'weight-loss', 131.8300, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'TR30', '30mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('f4da0206-6e2a-575a-8e28-c0a14043f007', 'Tirzepatide', 'Dual GIP/GLP-1 receptor agonist peptide for advanced metabolic studies.', 'weight-loss', 148.8700, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'TR40', '40mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('78cdeaec-b50b-5aaa-b386-3db0a60f7819', 'Tirzepatide', 'Dual GIP/GLP-1 receptor agonist peptide for advanced metabolic studies.', 'weight-loss', 167.8900, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'TR50', '50mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('51575ff6-0764-5f83-b005-66197f97443b', 'Tirzepatide', 'Dual GIP/GLP-1 receptor agonist peptide for advanced metabolic studies.', 'weight-loss', 186.9000, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'TR60', '60mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('92761a8e-d96f-5cf5-b301-9161cbcd5b99', 'Tirzepatide', 'Dual GIP/GLP-1 receptor agonist peptide for advanced metabolic studies.', 'weight-loss', 278.6800, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'TR100', '100mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('f22d739d-e26f-5da1-bfb4-0a27a4fcaca1', 'Retatrutide', 'Triple-agonist GLP-1/GIP/Glucagon receptor peptide for cutting-edge research.', 'weight-loss', 116.6200, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'RT10', '10mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('fea5f23b-39d1-55bc-948c-8e7932d4a835', 'Retatrutide', 'Triple-agonist GLP-1/GIP/Glucagon receptor peptide for cutting-edge research.', 'weight-loss', 133.6600, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'RT15', '15mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('daaa6a24-2be7-5bb8-bcd8-592913159f9e', 'Retatrutide', 'Triple-agonist GLP-1/GIP/Glucagon receptor peptide for cutting-edge research.', 'weight-loss', 152.6800, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'RT20', '20mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('dd8fbd14-d32f-5e27-b692-f3408181e625', 'Retatrutide', 'Triple-agonist GLP-1/GIP/Glucagon receptor peptide for cutting-edge research.', 'weight-loss', 192.6800, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'RT30', '30mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('c18fcc54-d259-5284-9ca5-a502d239f20c', 'Retatrutide', 'Triple-agonist GLP-1/GIP/Glucagon receptor peptide for cutting-edge research.', 'weight-loss', 216.5600, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'RT36', '36mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('e413fb41-b21f-545c-b10f-24feee5b6ac6', 'Retatrutide', 'Triple-agonist GLP-1/GIP/Glucagon receptor peptide for cutting-edge research.', 'weight-loss', 230.7000, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'RT40', '40mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('941de169-9a36-5aaa-9c41-0ab64830ca94', 'Retatrutide', 'Triple-agonist GLP-1/GIP/Glucagon receptor peptide for cutting-edge research.', 'weight-loss', 249.7200, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'RT50', '50mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('486222dc-6c33-5150-9471-0f03d377a524', 'Retatrutide', 'Triple-agonist GLP-1/GIP/Glucagon receptor peptide for cutting-edge research.', 'weight-loss', 268.7300, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'RT60', '60mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('2398f33a-d003-5467-94f7-2345575feaf0', 'Tesamorelin', 'Growth hormone releasing factor analog for lipodystrophy and GH research.', 'weight-loss', 183.1000, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'TSM10', '10mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('2156d7af-799b-5d32-a570-9470c54810c9', 'Tesamorelin', 'Growth hormone releasing factor analog for lipodystrophy and GH research.', 'weight-loss', 256.8000, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'TSM15', '15mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('f2f33780-6318-5c09-a375-cbec5e8df25b', 'Tesamorelin', 'Growth hormone releasing factor analog for lipodystrophy and GH research.', 'weight-loss', 301.6000, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'TSM20', '20mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('9ef0a818-3e51-5de7-b506-847b3e19068e', 'AOD-9604', 'Anti-Obesity Drug peptide fragment for fat metabolism research.', 'weight-loss', 189.8000, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, '10AD', '10mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('f2af1274-6cb6-5268-84ab-4d1cd47b3c50', '5-amino-1mq', '5-Amino-1MQ NNMT inhibitor for fat metabolism research.', 'weight-loss', 116.0000, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, '5AM-10', '10mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('b12e68f1-5527-590f-b505-7415089e1829', '5-amino-1mq', '5-Amino-1MQ NNMT inhibitor for fat metabolism research.', 'weight-loss', 145.6000, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, '5AM-50', '50mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('cef95573-21f4-590c-a959-c7aa0020e55d', 'Epithalon', 'Tetrapeptide studied for telomerase activation and anti-aging research.', 'anti-aging', 224.9300, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'ET50', '50mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('4aeda620-814e-50c2-9445-c36c2e3d1fbe', 'HCG', 'Human Chorionic Gonadotropin for reproductive and hormonal research.', 'hormone-libido', 167.8900, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'G10k', '10000iu*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('1282e52d-48d7-5927-a7c0-2f4ca9ce739b', 'KissPeptin-10', 'Neuropeptide involved in reproductive hormone regulation research.', 'hormone-libido', 126.0600, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'KS10', '10mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('e472cf7e-6edc-561b-a68d-6eb854165179', 'HGH 191AA (Somatropin)', 'Human Growth Hormone 191AA (Somatropin) for growth research.', 'growth-hormone', 107.0400, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'H15', '15iu*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('d1b9ed52-9891-515e-be49-731c223cd0db', 'HGH 191AA (Somatropin)', 'Human Growth Hormone 191AA (Somatropin) for growth research.', 'growth-hormone', 145.0700, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'H24', '24iu*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('1e0afa72-66fc-5cdd-8dda-694347309e81', 'IGF-1LR3', 'Insulin-like Growth Factor-1 Long R3 for growth and tissue development research.', 'growth-hormone', 183.1000, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'IG1', '1mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('77bc6d5f-fb4b-593a-8d70-31c02b323805', 'Ipamorelin', 'Selective growth hormone secretagogue for targeted GH release research.', 'growth-hormone', 103.2400, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'IP10', '10mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('15e5a277-6278-5196-bfee-04a2928e557c', 'Sermorelin Acetate', 'Growth hormone releasing hormone analog for GH stimulation research.', 'growth-hormone', 126.0600, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'SMO10', '10mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('c1dc2eac-bd6f-5bf1-840f-c631b58f3a58', 'Pinealon', 'Tripeptide bioregulator for brain function and neuroprotection research.', 'neuropeptides', 97.6100, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'PI10', '10mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('9fe44e91-ea10-5917-a644-80e0631dcfdd', 'Pinealon', 'Tripeptide bioregulator for brain function and neuroprotection research.', 'neuropeptides', 116.6200, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'P20', '20mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('e4fdf2d3-b20f-5ec8-ae04-8389a168b2ba', 'Selank', 'Synthetic analog of tuftsin with anxiolytic and nootropic research applications.', 'neuropeptides', 91.8300, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'SK10', '10mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('cd0aff29-fe2b-5dd5-9d02-a1a10ea86eb0', 'Semax', 'Synthetic ACTH analog peptide for cognitive enhancement and neuroprotection research.', 'neuropeptides', 88.0300, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'XA10', '10mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('2e29eca1-bdee-54c5-a9d6-af13a3dbf33e', 'NAD', 'Nicotinamide Adenine Dinucleotide for cellular energy and longevity research.', 'mitochondrial', 107.0400, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'NJ500', '500mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('512a6217-181b-59ee-9199-6519eeb23260', 'SS-31', 'Mitochondria-targeted peptide (Elamipretide) for cellular energy and protection research.', 'mitochondrial', 278.1700, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, '2S50', '50mg*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, name, description, category, base_price, discount_price, discount_start_date, discount_end_date, discount_active, purity_percentage, molecular_weight, cas_number, sequence, storage_conditions, inclusions, stock_quantity, available, featured, image_url, safety_sheet_url, code, spec, units_per_pack, unit_type, region_restriction, onhand_available, preorder_available, notes, created_at, updated_at) VALUES
  ('e9d9aaf4-9a5d-5bc2-ae8b-7b33ee1d6754', 'Vitamin B12', 'Vitamin B12 injection for energy metabolism and nutritional research.', 'specialty', 69.0100, null, null, null, false, '99.00', null, null, null, 'Store at -20°C, protect from light', null, 100, true, false, null, null, 'B12', '10mL*10vials', 10, 'vials', null, false, true, null, now(), now())
  ON CONFLICT (id) DO NOTHING;

COMMIT;
