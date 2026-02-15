<?php
require_once 'db.php';

try {
    // Check if column exists
    $stmt = $pdo->query("SHOW COLUMNS FROM orders LIKE 'token_number'");
    if ($stmt->rowCount() == 0) {
        $pdo->exec("ALTER TABLE orders ADD COLUMN token_number INT DEFAULT 1 AFTER order_number");
        echo "Successfully added 'token_number' column to 'orders' table.";
    } else {
        echo "'token_number' column already exists.";
    }
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}
