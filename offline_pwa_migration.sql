-- GustoPOS Offline-First PWA Database Migration
-- Adds versioning and timestamp columns for synchronization

-- Add updated_at and version columns to products
ALTER TABLE products 
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  ADD COLUMN IF NOT EXISTS version INT DEFAULT 1;

-- Add updated_at and version columns to categories
ALTER TABLE categories 
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  ADD COLUMN IF NOT EXISTS version INT DEFAULT 1;

-- Add updated_at and version columns to restaurant_tables
ALTER TABLE restaurant_tables 
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  ADD COLUMN IF NOT EXISTS version INT DEFAULT 1;

-- Add updated_at and version columns to orders
ALTER TABLE orders 
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  ADD COLUMN IF NOT EXISTS version INT DEFAULT 1;

-- Add updated_at and version columns to inventory
ALTER TABLE inventory 
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  ADD COLUMN IF NOT EXISTS version INT DEFAULT 1;

-- Add updated_at and version columns to settings
ALTER TABLE settings 
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  ADD COLUMN IF NOT EXISTS version INT DEFAULT 1;

-- Add updated_at and version columns to staff
ALTER TABLE staff 
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  ADD COLUMN IF NOT EXISTS version INT DEFAULT 1;

-- Create indexes for sync queries (improves performance)
CREATE INDEX IF NOT EXISTS idx_products_updated ON products(updated_at);
CREATE INDEX IF NOT EXISTS idx_categories_updated ON categories(updated_at);
CREATE INDEX IF NOT EXISTS idx_tables_updated ON restaurant_tables(updated_at);
CREATE INDEX IF NOT EXISTS idx_orders_updated ON orders(updated_at);
CREATE INDEX IF NOT EXISTS idx_inventory_updated ON inventory(updated_at);
CREATE INDEX IF NOT EXISTS idx_settings_updated ON settings(updated_at);
CREATE INDEX IF NOT EXISTS idx_staff_updated ON staff(updated_at);

-- Initialize version numbers for existing records (set to 1)
UPDATE products SET version = 1 WHERE version IS NULL;
UPDATE categories SET version = 1 WHERE version IS NULL;
UPDATE restaurant_tables SET version = 1 WHERE version IS NULL;
UPDATE orders SET version = 1 WHERE version IS NULL;
UPDATE inventory SET version = 1 WHERE version IS NULL;
UPDATE settings SET version = 1 WHERE version IS NULL;
UPDATE staff SET version = 1 WHERE version IS NULL;

-- Create a table to track sync metadata (optional but useful)
CREATE TABLE IF NOT EXISTS sync_metadata (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_id VARCHAR(255) UNIQUE,
    last_sync TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sync_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

SELECT 'Migration completed successfully!' AS status;
