-- Phase 3: Business Logic Expansion

-- 1. Audit Logs
CREATE TABLE IF NOT EXISTS audit_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NULL,
    user_name VARCHAR(100) NULL,
    action VARCHAR(50) NOT NULL, -- e.g., 'UPDATE_PRICE', 'VOID_ORDER'
    entity VARCHAR(50) NULL, -- e.g., 'products', 'orders'
    entity_id INT NULL,
    details TEXT NULL, -- JSON or text description
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Modifiers (Global list of extras)
CREATE TABLE IF NOT EXISTS modifiers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) DEFAULT 0.00,
    category VARCHAR(50) DEFAULT 'general', -- e.g., 'Toppings', 'Cooking Level'
    is_active TINYINT(1) DEFAULT 1
);

-- 3. Order Item Modifiers (Selected modifiers for a specific item)
CREATE TABLE IF NOT EXISTS order_item_modifiers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_item_id INT NOT NULL,
    modifier_id INT NULL,
    modifier_name VARCHAR(100) NOT NULL, -- store name in case original is deleted
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_item_id) REFERENCES order_items(id) ON DELETE CASCADE
);

-- 4. Order Payments (For Split Bill / Partial Payments)
CREATE TABLE IF NOT EXISTS order_payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50) DEFAULT 'cash', -- cash, card, online
    transaction_ref VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- 5. Add payment tracking columns to orders
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_status ENUM('unpaid', 'partial', 'paid') DEFAULT 'unpaid';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS paid_amount DECIMAL(10,2) DEFAULT 0.00;

-- 6. Insert default modifiers
INSERT INTO modifiers (name, price, category) VALUES 
('Extra Cheese', 1.50, 'Toppings'),
('No Onions', 0.00, 'Preferences'),
('Spicy', 0.50, 'Preferences'),
('Takeaway Box', 0.50, 'Packaging');
