-- ==============================================================
-- Set image_url on newly added supplier products
-- Images live in public/product-images/
-- ==============================================================

BEGIN;

-- --------- New supplier products ---------

UPDATE public.products SET image_url = '/product-images/16_Acetic-Acid_10ml.png', updated_at = now()
  WHERE code = 'AA10' AND spec = '10ml*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/BAC_Water_10ml.png', updated_at = now()
  WHERE code = 'BA10' AND spec = '10ml*10vials' AND image_url IS NULL;

-- (no image available for code WA3)
-- (no image available for code WA10)
UPDATE public.products SET image_url = '/product-images/23_BPC-157_10mg.png', updated_at = now()
  WHERE code = 'BC10' AND spec = '10mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/112_TB-500_10mg.png', updated_at = now()
  WHERE code = 'BT10' AND spec = '10mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/CJC-1295-NODAC-10mg.png', updated_at = now()
  WHERE code = 'CND10' AND spec = '10mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/DSIP_15mg.png', updated_at = now()
  WHERE code = 'D15' AND spec = '15mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/04_KPV_10mg.png', updated_at = now()
  WHERE code = 'KPV10' AND spec = '10mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/118_Thymosin-Alpha-1_10mg.png', updated_at = now()
  WHERE code = 'TA10' AND spec = '10mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/VIP-10mg.png', updated_at = now()
  WHERE code = 'VIP10' AND spec = '10mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/42_GHK-Cu_100mg.png', updated_at = now()
  WHERE code = 'CU100' AND spec = '100mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/GHKcu _topical_1g.png', updated_at = now()
  WHERE code = 'CU 1g' AND spec = '1g*1tube' AND image_url IS NULL;

-- (no image available for code AHKCU 1g)
UPDATE public.products SET image_url = '/product-images/28_Cagrilintide_10mg_blend.png', updated_at = now()
  WHERE code = 'CS10' AND spec = '10mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/26_Cagrilintide_10mg.png', updated_at = now()
  WHERE code = 'CGL10' AND spec = '10mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/71_MOTS-C_40mg.png', updated_at = now()
  WHERE code = 'MS40' AND spec = '40mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/Semaglutide_5mg.png', updated_at = now()
  WHERE code = 'SM5' AND spec = '5mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/Semaglutide_10mg.png', updated_at = now()
  WHERE code = 'SM10' AND spec = '10mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/Semaglutide_15mg.png', updated_at = now()
  WHERE code = 'SM15' AND spec = '15mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/Semaglutide_20mg.png', updated_at = now()
  WHERE code = 'SM20' AND spec = '20mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/Semaglutide_30mg.png', updated_at = now()
  WHERE code = 'SM30' AND spec = '30mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/Tirzepatide_10mg.png', updated_at = now()
  WHERE code = 'TR10' AND spec = '10mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/Tirzepatide_15mg.png', updated_at = now()
  WHERE code = 'TR15' AND spec = '15mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/Tirzepatide_20mg.png', updated_at = now()
  WHERE code = 'TR20' AND spec = '20mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/Tirzepatide_30mg.png', updated_at = now()
  WHERE code = 'TR30' AND spec = '30mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/Tirzepatide_40mg.png', updated_at = now()
  WHERE code = 'TR40' AND spec = '40mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/Tirzepatide_50mg.png', updated_at = now()
  WHERE code = 'TR50' AND spec = '50mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/Tirzepatide_60mg.png', updated_at = now()
  WHERE code = 'TR60' AND spec = '60mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/Tirzepatide 100mg.png', updated_at = now()
  WHERE code = 'TR100' AND spec = '100mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/Retatrutide_10mg.png', updated_at = now()
  WHERE code = 'RT10' AND spec = '10mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/Retatrutide_15mg.png', updated_at = now()
  WHERE code = 'RT15' AND spec = '15mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/Retatrutide_20mg.png', updated_at = now()
  WHERE code = 'RT20' AND spec = '20mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/Retatrutide_30mg.png', updated_at = now()
  WHERE code = 'RT30' AND spec = '30mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/Retatrutide_36mg.png', updated_at = now()
  WHERE code = 'RT36' AND spec = '36mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/Retatrutide_40mg.png', updated_at = now()
  WHERE code = 'RT40' AND spec = '40mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/Retatrutide_50mg.png', updated_at = now()
  WHERE code = 'RT50' AND spec = '50mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/Retatrutide_60mg.png', updated_at = now()
  WHERE code = 'RT60' AND spec = '60mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/114_Tesamorelin_10mg.png', updated_at = now()
  WHERE code = 'TSM10' AND spec = '10mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/115_Tesamorelin_15mg.png', updated_at = now()
  WHERE code = 'TSM15' AND spec = '15mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/116_Tesamorelin_20mg.png', updated_at = now()
  WHERE code = 'TSM20' AND spec = '20mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/12_AOD-9604_10mg.png', updated_at = now()
  WHERE code = '10AD' AND spec = '10mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/07_5-Amino-1MQ_10mg.png', updated_at = now()
  WHERE code = '5AM-10' AND spec = '10mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/5-Amino-1MQ-50mg.png', updated_at = now()
  WHERE code = '5AM-50' AND spec = '50mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/Epithalon-50mg.png', updated_at = now()
  WHERE code = 'ET50' AND spec = '50mg*10vials' AND image_url IS NULL;

-- (no image available for code G10k)
UPDATE public.products SET image_url = '/product-images/60_Kisspeptin-10_10mg.png', updated_at = now()
  WHERE code = 'KS10' AND spec = '10mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/50_HGH_15iu.png', updated_at = now()
  WHERE code = 'H15' AND spec = '15iu*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/51_HGH_24iu.png', updated_at = now()
  WHERE code = 'H24' AND spec = '24iu*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/54_IGF-1-LR3_1mg.png', updated_at = now()
  WHERE code = 'IG1' AND spec = '1mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/58_Ipamorelin_10mg.png', updated_at = now()
  WHERE code = 'IP10' AND spec = '10mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/103_Sermorelin_10mg.png', updated_at = now()
  WHERE code = 'SMO10' AND spec = '10mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/79_Pinealon_10mg.png', updated_at = now()
  WHERE code = 'PI10' AND spec = '10mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/80_Pinealon_20mg.png', updated_at = now()
  WHERE code = 'P20' AND spec = '20mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/93_Selank_10mg.png', updated_at = now()
  WHERE code = 'SK10' AND spec = '10mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/101_Semax_10mg.png', updated_at = now()
  WHERE code = 'XA10' AND spec = '10mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/NAD+_500mg.png', updated_at = now()
  WHERE code = 'NJ500' AND spec = '500mg*10vials' AND image_url IS NULL;

UPDATE public.products SET image_url = '/product-images/SS-31_50mg.png', updated_at = now()
  WHERE code = '2S50' AND spec = '50mg*10vials' AND image_url IS NULL;

-- (no image available for code B12)
-- --------- Two additional variations ---------

UPDATE public.products SET image_url = '/product-images/Glutathione-BOXED-1500mg.png', updated_at = now()
  WHERE code = 'GTT' AND spec = '1500mg*10vials' AND image_url IS NULL;

-- (no image available for PNC-27 5mg*10vials — skipped)

-- --------- Price-fix products that still lack image_url ---------

-- PNC-27 5mg*5vials: no image available
-- LL37 (code '375'): already using /product-images/68_LL-37_5mg.png if set, otherwise set it
UPDATE public.products SET image_url = '/product-images/68_LL-37_5mg.png', updated_at = now()
  WHERE name = 'LL37' AND image_url IS NULL;

-- SLU-PP-322 (code '322')
UPDATE public.products SET image_url = '/product-images/105_SLU-PP-322_5mg.png', updated_at = now()
  WHERE name = 'SLU-PP-322' AND image_url IS NULL;

COMMIT;
