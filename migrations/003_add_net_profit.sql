-- Migration: Add net_profit column to shift_closings table
-- Run this script to update the database schema for shift-based accounting

-- Add net_profit column to shift_closings (if not exists)
ALTER TABLE shift_closings ADD COLUMN IF NOT EXISTS net_profit DECIMAL(10,2) DEFAULT 0.00 AFTER total_expenses;

-- If the above fails (MySQL < 8.0 doesn't support IF NOT EXISTS for columns), use this instead:
-- First check if column exists, then add if not

-- SET @dbname = DATABASE();
-- SET @tablename = 'shift_closings';
-- SET @columnname = 'net_profit';
-- SET @preparedStatement = (SELECT IF(
--   (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
--    WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = @columnname) > 0,
--   'SELECT 1',
--   'ALTER TABLE shift_closings ADD COLUMN net_profit DECIMAL(10,2) DEFAULT 0.00 AFTER total_expenses'
-- ));
-- PREPARE alterIfNotExists FROM @preparedStatement;
-- EXECUTE alterIfNotExists;
-- DEALLOCATE PREPARE alterIfNotExists;
