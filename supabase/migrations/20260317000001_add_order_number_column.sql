-- Add order_number column to orders table
ALTER TABLE orders ADD COLUMN IF NOT EXISTS order_number TEXT;

-- Create index for order_number lookups
CREATE INDEX IF NOT EXISTS idx_orders_order_number ON orders(order_number);
