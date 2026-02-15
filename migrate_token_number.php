<?php
require_once 'db.php';

try {
    // 1. Add token_number column if it doesn't exist
    $pdo->exec("ALTER TABLE orders ADD COLUMN IF NOT EXISTS token_number INT DEFAULT NULL");

    // 2. Add index for performance on token resets
    $pdo->exec("CREATE INDEX IF NOT EXISTS idx_token_number ON orders(token_number)");

    echo "SQL Migration Successful: token_number column added to orders table.\n";
} catch (Exception $e) {
    // If IF NOT EXISTS is not supported by the specific MySQL version (it is in newer versions), 
    // we use a more robust check.
    try {
        $pdo->exec("ALTER TABLE orders ADD COLUMN token_number INT DEFAULT NULL");
        $pdo->exec("CREATE INDEX idx_token_number ON orders(token_number)");
        echo "SQL Migration Successful: token_number column added.\n";
    } catch (Exception $e2) {
        if (strpos($e2->getMessage(), 'Duplicate column name') !== false) {
            echo "Migration Skipped: token_number column already exists.\n";
        } else {
            die("Migration Failed: " . $e2->getMessage());
        }
    }
}
