
-- Create shifts table
CREATE TABLE IF NOT EXISTS shifts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NULL,
    start_cash DECIMAL(10,2) DEFAULT 0.00,
    actual_cash DECIMAL(10,2) NULL,
    status ENUM('open', 'closed') DEFAULT 'open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_status (status),
    INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create shift_expenses table
CREATE TABLE IF NOT EXISTS shift_expenses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shift_id INT NOT NULL,
    category VARCHAR(50) NOT NULL,
    description VARCHAR(255) NULL,
    amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (shift_id) REFERENCES shifts(id) ON DELETE CASCADE,
    INDEX idx_shift (shift_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add shift_id to orders table if it doesn't exist
-- We use a stored procedure to correctly handle "IF NOT EXISTS" for columns in MySQL
DROP PROCEDURE IF EXISTS AddShiftIdToOrders;
DELIMITER //
CREATE PROCEDURE AddShiftIdToOrders()
BEGIN
    IF NOT EXISTS (
        SELECT * FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = 'orders' 
        AND COLUMN_NAME = 'shift_id'
    ) THEN
        ALTER TABLE orders ADD COLUMN shift_id INT NULL AFTER user_id;
        ALTER TABLE orders ADD INDEX idx_shift_id (shift_id);
    END IF;
END //
DELIMITER ;
CALL AddShiftIdToOrders();
DROP PROCEDURE AddShiftIdToOrders;
