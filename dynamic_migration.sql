-- DYNAMIC POS REFACTOR MIGRATION
-- This script refactors ENUMs into Lookup Tables and adds a Dynamic Permissions system.

SET FOREIGN_KEY_CHECKS = 0;

-- 1. Create Lookup Tables
CREATE TABLE IF NOT EXISTS `payment_methods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `slug` varchar(50) NOT NULL UNIQUE,
  `is_active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `order_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `slug` varchar(50) NOT NULL UNIQUE,
  `is_active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `slug` varchar(50) NOT NULL UNIQUE,
  `is_active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `slug` varchar(100) NOT NULL UNIQUE,
  `name` varchar(100) NOT NULL,
  `category` varchar(50) DEFAULT 'general',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `role_permissions` (
  `role_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`role_id`,`permission_id`),
  FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `taxes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `rate` decimal(10,2) NOT NULL DEFAULT 0.00,
  `type` enum('percentage','fixed') DEFAULT 'percentage',
  `is_active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Populate Initial Data
INSERT IGNORE INTO `payment_methods` (`name`, `slug`) VALUES 
('Cash', 'cash'), 
('Card', 'card'), 
('Other', 'other');

INSERT IGNORE INTO `order_types` (`name`, `slug`) VALUES 
('Dine-in', 'dine_in'), 
('Takeaway', 'takeaway'), 
('Delivery', 'delivery'),
('Walk-in', 'walk_in');

INSERT IGNORE INTO `roles` (`name`, `slug`) VALUES 
('Admin', 'admin'),
('Manager', 'manager'),
('Cashier', 'cashier'),
('Kitchen Staff', 'chef'),
('Waiter', 'waiter');

-- 3. Migration Helper Procedure
DELIMITER //
CREATE PROCEDURE AddColumnIfNotExists(
    IN tableName VARCHAR(64),
    IN columnName VARCHAR(64),
    IN columnCondition VARCHAR(255)
)
BEGIN
    IF NOT EXISTS (
        SELECT * FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = tableName 
        AND COLUMN_NAME = columnName
    ) THEN
        SET @sql = CONCAT('ALTER TABLE `', tableName, '` ADD COLUMN `', columnName, '` ', columnCondition);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END //
DELIMITER ;

-- 3.1 Migrate Role Data for Staff
CALL AddColumnIfNotExists('staff', 'role_id', 'int(11) DEFAULT NULL AFTER `name`');

UPDATE `staff` SET `role_id` = (SELECT id FROM roles WHERE slug = 'waiter') WHERE `role` = 'waiter';
UPDATE `staff` SET `role_id` = (SELECT id FROM roles WHERE slug = 'chef') WHERE `role` = 'chef';
UPDATE `staff` SET `role_id` = (SELECT id FROM roles WHERE slug = 'manager') WHERE `role` = 'manager';
UPDATE `staff` SET `role_id` = (SELECT id FROM roles WHERE slug = 'cashier') WHERE `role` = 'cashier';

-- 4. Migrate Order Data
CALL AddColumnIfNotExists('orders', 'payment_method_id', 'int(11) DEFAULT NULL AFTER `payment_method`');
CALL AddColumnIfNotExists('orders', 'order_type_id', 'int(11) DEFAULT NULL AFTER `order_type`');

UPDATE `orders` SET `payment_method_id` = (SELECT id FROM payment_methods WHERE slug = 'cash') WHERE `payment_method` = 'cash';
UPDATE `orders` SET `payment_method_id` = (SELECT id FROM payment_methods WHERE slug = 'card') WHERE `payment_method` = 'card';
UPDATE `orders` SET `payment_method_id` = (SELECT id FROM payment_methods WHERE slug = 'other') WHERE `payment_method` = 'other';

UPDATE `orders` SET `order_type_id` = (SELECT id FROM order_types WHERE slug = 'dine_in') WHERE `order_type` = 'dine_in';
UPDATE `orders` SET `order_type_id` = (SELECT id FROM order_types WHERE slug = 'takeaway') WHERE `order_type` = 'takeaway';
UPDATE `orders` SET `order_type_id` = (SELECT id FROM order_types WHERE slug = 'delivery') WHERE `order_type` = 'delivery';

-- 5. Permissions Migration
-- Define all existing permissions
INSERT IGNORE INTO `permissions` (`slug`, `name`, `category`) VALUES
('pos_access', 'Access POS (Ordering)', 'POS'),
('floor_plan_access', 'Access Floor Plan', 'POS'),
('view_reports', 'View Sales Reports', 'Reports'),
('export_data', 'Export Sale Data', 'Reports'),
('settings_access', 'Access Settings Management', 'System'),
('void_orders', 'Void/Delete Orders', 'Logic'),
('hide_financials', 'Hide Financial Dashboard', 'Logic');

-- Map settings to permissions for the 'cashier' role (Role ID 3 if created as above)
-- We'll use a procedure or multiple INSERTs based on current settings
INSERT IGNORE INTO `role_permissions` (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p 
WHERE r.slug = 'cashier' AND p.slug IN (
    SELECT 'pos_access' FROM settings WHERE setting_key = 'cashier_access_pos' AND setting_value = 'true'
    UNION SELECT 'floor_plan_access' FROM settings WHERE setting_key = 'cashier_access_floor' AND setting_value = 'true'
    UNION SELECT 'view_reports' FROM settings WHERE setting_key = 'cashier_view_reports' AND setting_value = 'true'
    UNION SELECT 'export_data' FROM settings WHERE setting_key = 'cashier_export_data' AND setting_value = 'true'
    UNION SELECT 'settings_access' FROM settings WHERE setting_key = 'cashier_access_settings' AND setting_value = 'true'
    UNION SELECT 'void_orders' FROM settings WHERE setting_key = 'cashier_void_orders' AND setting_value = 'true'
    UNION SELECT 'hide_financials' FROM settings WHERE setting_key = 'cashier_hide_financial_data' AND setting_value = 'true'
);

-- Admin gets everything
INSERT IGNORE INTO `role_permissions` (role_id, permission_id)
SELECT (SELECT id FROM roles WHERE slug = 'admin'), id FROM permissions;

-- 6. Final Schema Cleanup
-- DROP PROCEDURE AddColumnIfNotExists;
-- ALTER TABLE `staff` DROP COLUMN `role`;
-- ALTER TABLE `orders` DROP COLUMN `payment_method`;
-- ALTER TABLE `orders` DROP COLUMN `order_type`;

SET FOREIGN_KEY_CHECKS = 1;
COMMIT;
