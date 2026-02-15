-- GustoPOS Enterprise Database Schema
-- Run this in MySQL to create all required tables

CREATE DATABASE IF NOT EXISTS gustopos_login_2;
USE gustopos_login_2;

-- Categories table
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category_id INT,
    image VARCHAR(255) DEFAULT 'https://placehold.co/150x100/png?text=Item',
    is_available TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- Suppliers
CREATE TABLE IF NOT EXISTS suppliers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact VARCHAR(100),
    email VARCHAR(255),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Restaurant Tables (floor plan)
CREATE TABLE IF NOT EXISTS restaurant_tables (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    seats INT DEFAULT 4,
    status ENUM('free', 'busy', 'needs_payment') DEFAULT 'free',
    waiter_id INT NULL,
    occupied_since DATETIME NULL,
    current_order_id INT NULL
);

-- Orders (Enterprise)
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(20),
    table_id INT NULL,
    customer_name VARCHAR(255) DEFAULT 'Walk-in',
    order_type ENUM('dine_in', 'takeaway', 'delivery') DEFAULT 'dine_in',
    subtotal DECIMAL(10,2) DEFAULT 0,
    tax DECIMAL(10,2) DEFAULT 0,
    service_charge DECIMAL(10,2) DEFAULT 0,
    packaging_charge DECIMAL(10,2) DEFAULT 0,
    delivery_fee DECIMAL(10,2) DEFAULT 0,
    discount DECIMAL(10,2) DEFAULT 0,
    total DECIMAL(10,2) DEFAULT 0,
    status ENUM('pending', 'held', 'completed', 'deleted') DEFAULT 'pending',
    is_bill_printed TINYINT(1) DEFAULT 0,
    void_type ENUM('waste', 'return') NULL,
    deleted_by VARCHAR(100) NULL,
    delete_reason VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME NULL,
    INDEX idx_order_status (status),
    INDEX idx_order_created (created_at)
);

-- Order items (with KOT tracking)
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    product_name VARCHAR(255),
    quantity INT DEFAULT 1,
    price DECIMAL(10,2),
    notes VARCHAR(255) NULL,
    is_kot_printed TINYINT(1) DEFAULT 0,
    kot_time DATETIME NULL,
    INDEX idx_item_order (order_id),
    INDEX idx_item_product (product_id),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Inventory (Enterprise with unit conversion)
CREATE TABLE IF NOT EXISTS inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    sku VARCHAR(100),
    purchase_unit VARCHAR(50) DEFAULT 'Pcs',
    consumption_unit VARCHAR(50) DEFAULT 'Pcs',
    conversion_factor DECIMAL(10,3) DEFAULT 1,
    quantity DECIMAL(10,3) DEFAULT 0,
    min_quantity DECIMAL(10,3) DEFAULT 5,
    cost_per_unit DECIMAL(10,2) DEFAULT 0,
    supplier_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE SET NULL
);

-- Recipe mapping (product ingredients)
CREATE TABLE IF NOT EXISTS recipes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    inventory_id INT NOT NULL,
    qty_required DECIMAL(10,3) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (inventory_id) REFERENCES inventory(id) ON DELETE CASCADE
);

-- Stock movement logs
CREATE TABLE IF NOT EXISTS stock_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    inventory_id INT NOT NULL,
    qty_change DECIMAL(10,3),
    balance_after DECIMAL(10,3),
    reason ENUM('sale', 'waste', 'return', 'restock', 'adjustment') DEFAULT 'adjustment',
    reference_type VARCHAR(50) NULL,
    reference_id INT NULL,
    user_name VARCHAR(100) DEFAULT 'System',
    notes VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (inventory_id) REFERENCES inventory(id) ON DELETE CASCADE
);

-- System Settings
CREATE TABLE IF NOT EXISTS settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    setting_type ENUM('text', 'number', 'boolean', 'json') DEFAULT 'text',
    category VARCHAR(50) DEFAULT 'general'
);

-- Expenses
CREATE TABLE IF NOT EXISTS expenses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    description VARCHAR(255),
    category VARCHAR(100),
    amount DECIMAL(10,2),
    status ENUM('pending', 'approved') DEFAULT 'approved',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Staff
CREATE TABLE IF NOT EXISTS staff (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    role ENUM('waiter', 'chef', 'manager', 'cashier') DEFAULT 'waiter',
    pin VARCHAR(10) NULL,
    shift_start DATETIME NULL,
    is_active TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Users (Login System)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(100),
    role ENUM('admin', 'cashier') DEFAULT 'cashier',
    is_active TINYINT(1) DEFAULT 1,
    last_login DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Shift Closings (Z-Report)
CREATE TABLE IF NOT EXISTS shift_closings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    user_name VARCHAR(100),
    shift_start DATETIME,
    shift_end DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_sales DECIMAL(10,2) DEFAULT 0,
    total_orders INT DEFAULT 0,
    total_voids INT DEFAULT 0,
    expected_cash DECIMAL(10,2) DEFAULT 0,
    actual_cash DECIMAL(10,2) DEFAULT 0,
    difference DECIMAL(10,2) DEFAULT 0,
    notes TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- ==================================
-- DEFAULT SETTINGS (All 10 Categories)
-- ==================================
INSERT INTO settings (setting_key, setting_value, setting_type, category) VALUES
-- 1. GENERAL - Restaurant Info
('restaurant_name', 'GustoPOS Restaurant', 'text', 'general'),
('restaurant_address', '123 Food Street, City', 'text', 'general'),
('restaurant_phone', '+1 234 567 890', 'text', 'general'),
('restaurant_logo', '', 'text', 'general'),
('tax_rate', '10', 'number', 'general'),
('tax_name', 'VAT', 'text', 'general'),
('service_charge_rate', '0', 'number', 'general'),
('packaging_fee', '1.00', 'number', 'general'),
('delivery_fee', '3.00', 'number', 'general'),
('currency_symbol', 'PKR', 'text', 'general'),

-- 2. PERMISSIONS - Role Access
('cashier_access_pos', 'true', 'boolean', 'permissions'),
('cashier_access_floor', 'true', 'boolean', 'permissions'),
('cashier_view_reports', 'false', 'boolean', 'permissions'),
('cashier_export_data', 'false', 'boolean', 'permissions'),
('cashier_access_settings', 'false', 'boolean', 'permissions'),
('cashier_void_orders', 'false', 'boolean', 'permissions'),
('admin_full_access', 'true', 'boolean', 'permissions'),
('allow_soft_lock', 'true', 'boolean', 'permissions'),

-- 3. ORDER & POS BEHAVIOR
('default_order_type', 'walkin', 'text', 'order'),
('show_order_timer', 'true', 'boolean', 'order'),
('allow_qty_edit_after_kot', 'true', 'boolean', 'order'),
('allow_cancel_after_payment', 'false', 'boolean', 'order'),
('merge_orders_same_table', 'false', 'boolean', 'order'),
('require_bill_before_pay', 'true', 'boolean', 'order'),

-- 4. TABLE & FLOOR PLAN
('auto_release_table', 'true', 'boolean', 'tables'),
('allow_table_transfer', 'false', 'boolean', 'tables'),
('allow_table_merge', 'false', 'boolean', 'tables'),
('table_color_free', '#12b76a', 'text', 'tables'),
('table_color_busy', '#f04438', 'text', 'tables'),
('table_color_reserved', '#f79009', 'text', 'tables'),
('table_color_payment', '#0d6efd', 'text', 'tables'),

-- 5. KITCHEN & KOT
('kot_print_copies', '1', 'number', 'kitchen'),
('auto_print_kot', 'true', 'boolean', 'kitchen'),
('show_modifiers_kot', 'true', 'boolean', 'kitchen'),
('show_notes_kot', 'true', 'boolean', 'kitchen'),
('kot_separate_kitchen', 'false', 'boolean', 'kitchen'),
('kot_separate_bar', 'false', 'boolean', 'kitchen'),
('kot_separate_dessert', 'false', 'boolean', 'kitchen'),

-- 6. INVENTORY & STOCK
('low_stock_threshold', '5', 'number', 'inventory'),
('stock_deduct_on', 'payment_complete', 'text', 'inventory'),
('block_order_zero_stock', 'false', 'boolean', 'inventory'),
('allow_negative_stock', 'false', 'boolean', 'inventory'),
('daily_inventory_reconcile', 'false', 'boolean', 'inventory'),

-- 7. PRICING & DISCOUNTS
('allow_manual_discount', 'cashier', 'text', 'pricing'),
('max_discount_percent', '20', 'number', 'pricing'),
('round_total_method', '1', 'text', 'pricing'),
('happy_hour_enabled', 'false', 'boolean', 'pricing'),
('time_based_pricing', 'false', 'boolean', 'pricing'),

-- 8. RECEIPT & INVOICE
('show_logo_receipt', 'true', 'boolean', 'receipt'),
('show_cashier_receipt', 'true', 'boolean', 'receipt'),
('show_table_receipt', 'true', 'boolean', 'receipt'),
('show_order_number_receipt', 'true', 'boolean', 'receipt'),
('duplicate_receipt', 'false', 'boolean', 'receipt'),
('print_qr_receipt', 'false', 'boolean', 'receipt'),
('printer_width', '80', 'number', 'receipt'),
('receipt_header', 'Welcome to our restaurant!', 'text', 'receipt'),
('receipt_footer', 'Thank you for visiting! No refunds after payment.', 'text', 'receipt'),
('footer_walkin', 'Thank you for walking in!', 'text', 'receipt'),
('footer_dinein', 'We hope you enjoyed your meal!', 'text', 'receipt'),
('footer_delivery', 'Thank you for choosing us!', 'text', 'receipt'),

-- 9. REPORTS & AUDIT
('allow_export_reports', 'true', 'boolean', 'reports'),
('daily_zreport_email', 'false', 'boolean', 'reports'),
('hide_financial_cashier', 'true', 'boolean', 'reports'),
('audit_log_login', 'true', 'boolean', 'reports'),
('audit_log_delete', 'true', 'boolean', 'reports'),
('audit_log_price', 'false', 'boolean', 'reports'),
('audit_log_stock', 'false', 'boolean', 'reports'),

-- 10. SYSTEM & PERFORMANCE
('enable_cache', 'false', 'boolean', 'system'),
('enable_realtime', 'false', 'boolean', 'system'),
('enable_offline', 'false', 'boolean', 'system'),
('auto_backup_schedule', 'daily', 'text', 'system'),
('timezone', 'Asia/Karachi', 'text', 'system'),
('date_format', 'DD/MM/YYYY', 'text', 'system'),
('maintenance_mode', 'false', 'boolean', 'system'),
('store_open_time', '09:00', 'text', 'system'),
('store_close_time', '22:00', 'text', 'system');


-- ==================================
-- DEFAULT USERS
-- ==================================
INSERT INTO users (username, password_hash, display_name, role) VALUES
('admin', MD5('admin123'), 'Administrator', 'admin'),
('cashier', MD5('cashier123'), 'Main Cashier', 'cashier');

-- ==================================
-- SAMPLE DATA
-- ==================================

-- Sample categories
INSERT INTO categories (name) VALUES 
('Burgers'), ('Pizzas'), ('Drinks'), ('Desserts'), ('Sides');

-- Sample suppliers
INSERT INTO suppliers (name, contact, email, address) VALUES
('Bakery Inc', '+1 555-1001', 'orders@bakeryinc.com', '100 Bread Lane'),
('Dairy Co', '+1 555-1002', 'sales@dairyco.com', '200 Milk Road'),
('Farm Fresh', '+1 555-1003', 'fresh@farmfresh.com', '300 Green Valley'),
('Meat Factory', '+1 555-1004', 'supply@meatfactory.com', '400 Protein Street'),
('Java Beans', '+1 555-1005', 'coffee@javabeans.com', '500 Roast Avenue');

-- Sample products
INSERT INTO products (name, price, category_id, image) VALUES 
('Classic Beef Burger', 12.00, 1, 'https://placehold.co/150x100/E8B067/333?text=Burger'),
('Cheese Burger', 14.00, 1, 'https://placehold.co/150x100/F5C77E/333?text=Cheese'),
('Double Bacon', 16.00, 1, 'https://placehold.co/150x100/D4956A/333?text=Bacon'),
('Veggie Burger', 11.00, 1, 'https://placehold.co/150x100/8BC34A/333?text=Veggie'),
('Pepperoni Pizza', 18.00, 2, 'https://placehold.co/150x100/E85A4F/333?text=Pizza'),
('Margherita', 15.00, 2, 'https://placehold.co/150x100/F28B82/333?text=Margherita'),
('BBQ Chicken Pizza', 19.00, 2, 'https://placehold.co/150x100/C9745B/333?text=BBQ'),
('Coca Cola', 3.00, 3, 'https://placehold.co/150x100/B71C1C/fff?text=Cola'),
('Iced Latte', 4.50, 3, 'https://placehold.co/150x100/795548/fff?text=Latte'),
('Orange Juice', 4.00, 3, 'https://placehold.co/150x100/FF9800/333?text=OJ'),
('Chocolate Cake', 6.00, 4, 'https://placehold.co/150x100/5D4037/fff?text=Cake'),
('Ice Cream', 5.00, 4, 'https://placehold.co/150x100/FFCCBC/333?text=IceCream'),
('Apple Pie', 5.50, 4, 'https://placehold.co/150x100/A1887F/fff?text=Pie'),
('French Fries', 4.00, 5, 'https://placehold.co/150x100/FFC107/333?text=Fries'),
('Onion Rings', 4.50, 5, 'https://placehold.co/150x100/FFB74D/333?text=Rings');

-- Sample tables
INSERT INTO restaurant_tables (name, seats, status) VALUES 
('T-01', 4, 'free'),
('T-02', 4, 'busy'),
('T-03', 2, 'free'),
('T-04', 6, 'free'),
('T-05', 4, 'needs_payment'),
('T-06', 8, 'free'),
('T-07', 2, 'free'),
('T-08', 4, 'free'),
('T-09', 4, 'busy'),
('T-10', 6, 'free'),
('T-11', 4, 'free'),
('T-12', 8, 'free');

-- Sample inventory with supplier links
INSERT INTO inventory (name, sku, purchase_unit, consumption_unit, conversion_factor, quantity, min_quantity, cost_per_unit, supplier_id) VALUES 
('Burger Buns', 'SKU-101', 'Pack (10)', 'Pcs', 10, 120, 20, 2.50, 1),
('Cheese Slices', 'SKU-205', 'Kg', 'Gram', 1000, 2000, 500, 8.00, 2),
('Tomato Sauce', 'SKU-301', 'Ltr', 'ml', 1000, 5000, 1000, 3.00, 3),
('Beef Patties', 'SKU-400', 'Box (20)', 'Pcs', 20, 100, 30, 25.00, 4),
('Lettuce', 'SKU-102', 'Kg', 'Gram', 1000, 3000, 500, 2.00, 3),
('Onions', 'SKU-103', 'Kg', 'Gram', 1000, 10000, 2000, 1.50, 3),
('Milk', 'SKU-500', 'Ltr', 'ml', 1000, 12000, 3000, 1.20, 2),
('Coffee Beans', 'SKU-600', 'Kg', 'Gram', 1000, 4000, 500, 12.00, 5),
('Pizza Dough', 'SKU-700', 'Pcs', 'Pcs', 1, 50, 15, 1.50, 1),
('Mozzarella', 'SKU-701', 'Kg', 'Gram', 1000, 5000, 1000, 10.00, 2);

-- Sample recipe mappings (product ingredients)
INSERT INTO recipes (product_id, inventory_id, qty_required) VALUES
-- Classic Beef Burger: 1 bun, 1 patty, 2 cheese slices (50g), 30g lettuce, 20g onion
(1, 1, 1),    -- Burger Bun
(1, 4, 1),    -- Beef Patty
(1, 2, 50),   -- Cheese (grams)
(1, 5, 30),   -- Lettuce (grams)
(1, 6, 20),   -- Onion (grams)
-- Cheese Burger: same + extra cheese
(2, 1, 1),
(2, 4, 1),
(2, 2, 80),
(2, 5, 30),
(2, 6, 20),
-- Iced Latte: 200ml milk, 15g coffee
(9, 7, 200),
(9, 8, 15),
-- Margherita Pizza: 1 dough, 100g mozzarella, 50ml sauce
(6, 9, 1),
(6, 10, 100),
(6, 3, 50);

-- Sample expenses
INSERT INTO expenses (description, category, amount) VALUES 
('Vegetables Purchase', 'Ingredients', 150.00),
('Electricity Bill', 'Utilities', 320.00),
('Staff Uniforms', 'Supplies', 85.00),
('Kitchen Equipment Repair', 'Maintenance', 200.00);

-- Sample staff
INSERT INTO staff (name, role, is_active, shift_start) VALUES 
('Alice Johnson', 'waiter', 1, NOW()),
('Mike Smith', 'chef', 1, NOW()),
('Bob Williams', 'waiter', 0, NULL),
('Sarah Davis', 'manager', 1, NOW()),
('Tom Brown', 'cashier', 0, NULL);

-- Sample completed orders
INSERT INTO orders (order_number, customer_name, order_type, subtotal, tax, total, status, created_at) VALUES 
('INV-1023', 'John Doe', 'dine_in', 40.91, 4.09, 45.00, 'completed', DATE_SUB(NOW(), INTERVAL 2 HOUR)),
('INV-1022', 'Sarah Smith', 'takeaway', 20.00, 2.00, 23.00, 'completed', DATE_SUB(NOW(), INTERVAL 3 HOUR)),
('INV-1021', 'Walk-in', 'dine_in', 11.36, 1.14, 12.50, 'completed', DATE_SUB(NOW(), INTERVAL 4 HOUR)),
('INV-1020', 'Mike Ross', 'delivery', 50.00, 5.00, 58.00, 'completed', DATE_SUB(NOW(), INTERVAL 5 HOUR)),
('INV-1019', 'Harvey S.', 'dine_in', 80.91, 8.09, 89.00, 'completed', DATE_SUB(NOW(), INTERVAL 6 HOUR));

-- Sample order items (marked as KOT printed for completed orders)
INSERT INTO order_items (order_id, product_id, product_name, quantity, price, is_kot_printed, kot_time) VALUES 
(1, 1, 'Classic Beef Burger', 2, 12.00, 1, DATE_SUB(NOW(), INTERVAL 2 HOUR)),
(1, 9, 'Iced Latte', 2, 4.50, 1, DATE_SUB(NOW(), INTERVAL 2 HOUR)),
(2, 5, 'Pepperoni Pizza', 1, 18.00, 1, DATE_SUB(NOW(), INTERVAL 3 HOUR)),
(3, 8, 'Coca Cola', 2, 3.00, 1, DATE_SUB(NOW(), INTERVAL 4 HOUR)),
(3, 12, 'Ice Cream', 1, 5.00, 1, DATE_SUB(NOW(), INTERVAL 4 HOUR));
 