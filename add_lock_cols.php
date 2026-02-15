<?php
require_once 'db.php';

try {
    $pdo->exec("ALTER TABLE restaurant_tables 
                ADD COLUMN locked_by INT NULL DEFAULT NULL, 
                ADD COLUMN locked_at DATETIME NULL DEFAULT NULL");
    echo "Added locked_by and locked_at columns successfully.";
} catch (PDOException $e) {
    if (strpos($e->getMessage(), 'Duplicate column') !== false) {
        echo "Columns already exist.";
    } else {
        echo "Error: " . $e->getMessage();
    }
}
