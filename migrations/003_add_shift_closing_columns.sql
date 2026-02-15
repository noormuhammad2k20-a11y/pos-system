-- Migration: Add detailed financial columns to shift_closings for immutable Z-Reports
-- Created: 2026-02-08

ALTER TABLE `shift_closings`
ADD COLUMN `total_cash_sales` DECIMAL(10,2) DEFAULT 0.00 AFTER `total_sales`,
ADD COLUMN `total_card_sales` DECIMAL(10,2) DEFAULT 0.00 AFTER `total_cash_sales`,
ADD COLUMN `total_expenses` DECIMAL(10,2) DEFAULT 0.00 AFTER `total_card_sales`,
ADD COLUMN `total_refunds` DECIMAL(10,2) DEFAULT 0.00 AFTER `total_expenses`,
ADD COLUMN `total_void_amount` DECIMAL(10,2) DEFAULT 0.00 AFTER `total_refunds`,
ADD COLUMN `json_data` TEXT DEFAULT NULL AFTER `notes`;

-- Ensure indexes for performance if they don't exist (though table creation usually handles basic ones)
-- ADD INDEX `idx_shift_closings_start` (`shift_start`);
