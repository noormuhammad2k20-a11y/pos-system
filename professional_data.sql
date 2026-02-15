-- GustoPOS Professional Database Upgrade
-- This script provides a clean, premium starting state for the application.
-- WARNING: This will TRUNCATE (clear) existing categories, products, and test transaction data.

SET FOREIGN_KEY_CHECKS = 0;

-- 1. CLEANUP TEST DATA (Ensures a professional starting state)
DELETE FROM `audit_logs`;
DELETE FROM `order_items`;
DELETE FROM `order_payments`;
DELETE FROM `orders`;
DELETE FROM `shifts`;
DELETE FROM `shift_closings`;
DELETE FROM `stock_logs`;
DELETE FROM `expenses`;

-- 2. RESET CORE MENU DATA
DELETE FROM `categories`;
DELETE FROM `products`;
DELETE FROM `recipes`;

-- Optional: Reset Auto-increment counters (Safe to do in sequence)
ALTER TABLE `categories` AUTO_INCREMENT = 1;
ALTER TABLE `products` AUTO_INCREMENT = 1;
ALTER TABLE `recipes` AUTO_INCREMENT = 1;
ALTER TABLE `orders` AUTO_INCREMENT = 1;
ALTER TABLE `order_items` AUTO_INCREMENT = 1;
ALTER TABLE `shifts` AUTO_INCREMENT = 1;

-- 3. INSERT PROFESSIONAL CATEGORIES
INSERT INTO `categories` (`id`, `name`, `sort_order`, `is_active`) VALUES
(1, 'Burgers', 1, 1),
(2, 'Pizzas', 2, 1),
(3, 'Drinks', 3, 1),
(4, 'Desserts', 4, 1),
(5, 'Sides', 5, 1),
(6, 'Salads', 6, 1),
(7, 'Sandwiches', 7, 1),
(8, 'Specials', 8, 1);

-- 4. INSERT PREMIUM PRODUCTS WITH 4K IMAGES
INSERT INTO `products` (`id`, `name`, `price`, `cost_price`, `category_id`, `image`, `is_available`, `sort_order`) VALUES
-- Burgers (Cat 1)
(1, 'Classic Angus Burger', 1200.00, 450.00, 1, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=1000', 1, 1),
(2, 'Truffle Mushroom Swiss', 1500.00, 600.00, 1, 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?q=80&w=1000', 1, 2),
(3, 'Spicy Jalapeño Burger', 1400.00, 500.00, 1, 'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?q=80&w=1000', 1, 3),
(4, 'BBQ Bacon King', 1600.00, 700.00, 1, 'https://images.unsplash.com/photo-1550547660-d9450f859549?q=80&w=1000', 1, 4),
-- Pizzas (Cat 2)
(5, 'Signature Margherita', 1500.00, 500.00, 2, 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?q=80&w=1000', 1, 1),
(6, 'Double Pepperoni Feast', 1800.00, 650.00, 2, 'https://images.unsplash.com/photo-1628840042765-356cda07504e?q=80&w=1000', 1, 2),
(7, 'Truffle Honey Pizza', 2200.00, 800.00, 2, 'https://images.unsplash.com/photo-1513104890138-7c749659a591?q=80&w=1000', 1, 3),
(8, 'Garden Veggie', 1700.00, 550.00, 2, 'https://images.unsplash.com/photo-1571407970349-bc81e7e96d47?q=80&w=1000', 1, 4),
-- Drinks (Cat 3)
(9, 'Artisanal Lemonade', 400.00, 100.00, 3, 'https://images.unsplash.com/photo-1523677012304-d0251193015a?q=80&w=1000', 1, 1),
(10, 'Premium Roasted Latte', 550.00, 150.00, 3, 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?q=80&w=1000', 1, 2),
(11, 'Fresh Green Juice', 700.00, 250.00, 3, 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?q=80&w=1000', 1, 3),
(12, 'Sparkling Mineral Water', 300.00, 50.00, 3, 'https://images.unsplash.com/photo-1559839914-17aae19cea9e?q=80&w=1000', 1, 4),
-- Desserts (Cat 4)
(13, 'Belgian Chocolate Lava', 900.00, 350.00, 4, 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?q=80&w=1000', 1, 1),
(14, 'New York Cheesecake', 800.00, 300.00, 4, 'https://images.unsplash.com/photo-1533134242443-d4fd21530ead?q=80&w=1000', 1, 2),
(15, 'Madagascar Vanilla Crème Brûlée', 1000.00, 400.00, 4, 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?q=80&w=1000', 1, 3),
-- Sides (Cat 5)
(16, 'Truffle Parmesan Fries', 600.00, 200.00, 5, 'https://images.unsplash.com/photo-1630384066252-19e1ed15b448?q=80&w=1000', 1, 1),
(17, 'Loaded Potato Skins', 800.00, 250.00, 5, 'https://images.unsplash.com/photo-1639024471283-03518883511d?q=80&w=1000', 1, 2),
(18, 'Honey Mustard Slaw', 400.00, 120.00, 5, 'https://images.unsplash.com/photo-1531749956461-7bf38dec7131?q=80&w=1000', 1, 3),
-- Salads (Cat 6)
(19, 'Classic Caesar Chicken', 1200.00, 400.00, 6, 'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?q=80&w=1000', 1, 1),
(20, 'Mediterranean Greek', 1100.00, 350.00, 6, 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?q=80&w=1000', 1, 2),
(21, 'Superfood Quinoa Bowl', 1300.00, 450.00, 6, 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=1000', 1, 3),
-- Sandwiches (Cat 7)
(22, 'Ultimate Club Sandwich', 1300.00, 450.00, 7, 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?q=80&w=1000', 1, 1),
(23, 'Ribeye Steak Panini', 1600.00, 650.00, 7, 'https://images.unsplash.com/photo-1539252554452-da7accb7f9b2?q=80&w=1000', 1, 2),
-- Specials (Cat 8)
(24, 'Wagyu Beef Carpaccio', 2400.00, 1000.00, 8, 'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?q=80&w=1000', 1, 1),
(25, 'Pan-Seared Atlantic Salmon', 2800.00, 1200.00, 8, 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?q=80&w=1000', 1, 2);

-- 5. UPDATE INVENTORY FOR CORE ITEMS
UPDATE `inventory` SET `quantity` = 500.00 WHERE `id` IN (1,2,3,4,5,9,10,11);

-- 6. ALIGN RECIPES (Sample links for inventory deduction)
INSERT INTO `recipes` (`product_id`, `inventory_id`, `qty_required`) VALUES
(1, 1, 1.000), -- Angus Burger -> Bun
(1, 2, 1.000), -- Angus Burger -> Patty
(9, 4, 1.000), -- Lemonade -> (Reuse Cola inventory slot for demo)
(10, 5, 2.000);-- Latte -> Coffee Beans

-- 7. PROFESSIONAL SETTINGS
UPDATE `settings` SET `setting_value` = 'The Grand Gusto' WHERE `setting_key` = 'restaurant_name';
UPDATE `settings` SET `setting_value` = '123 Luxury Boulevard, Gourmet District' WHERE `setting_key` = 'restaurant_address';
UPDATE `settings` SET `setting_value` = '+1 (555) GUSTO-100' WHERE `setting_key` = 'restaurant_phone';
UPDATE `settings` SET `setting_value` = 'Rs ' WHERE `setting_key` = 'currency_symbol';
UPDATE `settings` SET `setting_value` = 'Thank you for dining at The Grand Gusto. Follow us on Instagram @TheGrandGusto' WHERE `setting_key` = 'receipt_footer';

SET FOREIGN_KEY_CHECKS = 1;
