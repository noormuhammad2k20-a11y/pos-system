<?php
require_once 'db.php';
try {
    // 1. Add Column
    $pdo->exec("ALTER TABLE users ADD COLUMN pin VARCHAR(10) NULL UNIQUE AFTER role");
    echo "Added 'pin' column to users table.\n";
} catch (Exception $e) {
    if (strpos($e->getMessage(), "Duplicate column") !== false) {
        echo "'pin' column already exists.\n";
    } else {
        echo "Error adding column: " . $e->getMessage() . "\n";
    }
}

// 2. Set Test PINs
try {
    $pdo->prepare("UPDATE users SET pin = '1234' WHERE username = 'cashier3'")->execute();
    $pdo->prepare("UPDATE users SET pin = '1111' WHERE username = 'admin'")->execute();
    echo "Set PIN 1234 for cashier3 and 1111 for admin.\n";
} catch (Exception $e) {
    echo "Error updating PINS: " . $e->getMessage() . "\n";
}