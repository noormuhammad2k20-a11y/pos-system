-- Migration: Add/Update POS Settings
TRUNCATE TABLE settings; -- Reset for clean state as per new requirements

INSERT INTO settings (setting_key, setting_value, setting_type, category) VALUES
-- 1. GENERAL INFO
('restaurant_name', 'Gusto POS', 'text', 'general'),
('phone_number', '+92 300 1234567', 'text', 'general'),
('address', 'Main Boulevard, Lahore, Pakistan', 'text', 'general'),
('restaurant_logo', '', 'text', 'general'),
('show_logo_on_receipt', 'true', 'boolean', 'general'),

-- 2. FINANCIALS
('tax_rate', '16', 'number', 'financials'),
('service_charge', '10', 'number', 'financials'),
('packaging_fee', '50', 'number', 'financials'),
('delivery_fee', '100', 'number', 'financials'),
('currency_symbol', 'Rs', 'text', 'financials'),

-- 3. POS LOGIC
('default_order_type', 'Walk-in', 'text', 'pos_logic'),
('rounding_rule', 'Nearest Whole', 'text', 'pos_logic'),
('show_order_timer', 'true', 'boolean', 'pos_logic'),
('require_bill_before_payment', 'true', 'boolean', 'pos_logic'),
('auto_merge_items', 'false', 'boolean', 'pos_logic'),

-- 4. TABLE MANAGEMENT
('auto_release_table', 'true', 'boolean', 'tables'),
('allow_table_transfer', 'true', 'boolean', 'tables'),
('table_color_free', '#12b76a', 'text', 'tables'),
('table_color_busy', '#f04438', 'text', 'tables'),
('table_color_reserved', '#f79009', 'text', 'tables'),
('table_color_waiters', '#17a2b8', 'text', 'tables'),

-- 5. KOT & PRINTING
('kot_print_copies', '1', 'number', 'printing'),
('auto_print_kot', 'true', 'boolean', 'printing'),
('show_notes_on_kot', 'true', 'boolean', 'printing'),
('print_logo_on_kot', 'false', 'boolean', 'printing'),
('printer_type', 'USB', 'text', 'printing'),
('paper_width', '80mm', 'text', 'printing'),
('receipt_header', 'Welcome to Gusto POS', 'text', 'printing'),
('receipt_footer', 'Thank you for dining with us!', 'text', 'printing'),

-- 6. INVENTORY CONTROL
('stock_deduction_mode', 'On Payment', 'text', 'inventory'),
('low_stock_warning_limit', '10', 'number', 'inventory'),
('block_out_of_stock_orders', 'true', 'boolean', 'inventory'),

-- 7. LOCALIZATION
('timezone', 'Asia/Karachi', 'text', 'localization'),
('date_format', 'DD/MM/YYYY', 'text', 'localization'),

-- 8. PERMISSIONS (CASHIER)
('cashier_access_pos', 'true', 'boolean', 'permissions'),
('cashier_access_floor', 'true', 'boolean', 'permissions'),
('cashier_view_reports', 'false', 'boolean', 'permissions'),
('cashier_export_data', 'false', 'boolean', 'permissions'),
('cashier_access_settings', 'false', 'boolean', 'permissions'),
('cashier_void_orders', 'false', 'boolean', 'permissions'),
('cashier_hide_financial_data', 'true', 'boolean', 'permissions');
