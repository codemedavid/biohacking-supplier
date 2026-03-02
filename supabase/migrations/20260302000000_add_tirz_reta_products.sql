-- Add Sample Tirzepatide and Retatrutide Products
-- Run this in your Supabase SQL Editor

-- Get category ID for Weight Management
DO $$
DECLARE
    weight_cat_id UUID;
    tirz15_id UUID;
    tirz30_id UUID;
    reta10_id UUID;
    reta15_id UUID;
BEGIN
    SELECT id INTO weight_cat_id FROM categories WHERE name = 'Weight Management';

    -- Make sure Weight Management category exists, if not use 'All Products', if not just pick the first one
    IF weight_cat_id IS NULL THEN
        SELECT id INTO weight_cat_id FROM categories WHERE name = 'All Products';
    END IF;
    
    IF weight_cat_id IS NULL THEN
        SELECT id INTO weight_cat_id FROM categories LIMIT 1;
    END IF;

    -- Insert Tirzepatide Products
    INSERT INTO products (name, description, category, base_price, purity_percentage, featured, available, stock_quantity) 
    VALUES 
    ('Tirzepatide 15mg', 'Dual-agonist peptide (GIP & GLP-1) for premium weight management and metabolic support.', weight_cat_id, 3500.00, 99.5, true, true, 50)
    RETURNING id INTO tirz15_id;

    INSERT INTO products (name, description, category, base_price, purity_percentage, featured, available, stock_quantity) 
    VALUES 
    ('Tirzepatide 30mg', 'Maximum strength dual-agonist peptide formulation for optimal results.', weight_cat_id, 6000.00, 99.5, true, true, 25)
    RETURNING id INTO tirz30_id;

    -- Insert Retatrutide Products
    INSERT INTO products (name, description, category, base_price, purity_percentage, featured, available, stock_quantity) 
    VALUES 
    ('Retatrutide 10mg', 'Triple-agonist GLP-1/GIP/Glucagon receptor peptide for ultimate scientific research.', weight_cat_id, 4500.00, 99.2, true, true, 40)
    RETURNING id INTO reta10_id;

    INSERT INTO products (name, description, category, base_price, purity_percentage, featured, available, stock_quantity) 
    VALUES 
    ('Retatrutide 15mg', 'Advanced research-grade triple-agonist peptide for superior testing configurations.', weight_cat_id, 6500.00, 99.2, true, true, 30)
    RETURNING id INTO reta15_id;

END $$;
