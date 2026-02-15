-- Advanced System Settings Migration
-- Adds advanced printing settings

-- Advanced Printing Settings
INSERT INTO settings (setting_key, setting_value, setting_type, category) 
VALUES 
('printer_type', 'usb', 'text', 'printing'),
('receipt_printer_ip', '', 'text', 'printing'),
('kitchen_printer_ip', '', 'text', 'printing'),
('print_logo_on_kot', 'false', 'boolean', 'printing')
ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value);
