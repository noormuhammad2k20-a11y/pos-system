INSERT INTO settings (setting_key, setting_value, setting_type, category) 
VALUES ('business_day_start', '0', 'number', 'system') 
ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value);
