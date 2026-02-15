-- GustoPOS Settings Migration
-- Run this to add all new settings to existing database

INSERT IGNORE INTO settings (setting_key, setting_value, setting_type, category) VALUES
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
('receipt_footer', 'Thank you for visiting!', 'text', 'receipt'),
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

SELECT CONCAT('Total settings: ', COUNT(*)) as result FROM settings;
