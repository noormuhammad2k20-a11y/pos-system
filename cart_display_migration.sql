-- Cart Display Settings Migration
-- Adds toggles for controlling cart and receipt display

INSERT INTO settings (setting_key, setting_value, setting_type, category) 
VALUES 
('show_subtotal', 'true', 'boolean', 'display'),
('enable_tax', 'true', 'boolean', 'display'),
('enable_service_charge', 'true', 'boolean', 'display')
ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value);
