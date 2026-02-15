<?php
require_once 'db.php';
try {
    $sql = "CREATE TABLE IF NOT EXISTS order_payments (
        id INT AUTO_INCREMENT PRIMARY KEY,
        order_id INT NOT NULL,
        payment_method VARCHAR(50) NOT NULL,
        amount DECIMAL(10, 2) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX (order_id)
    )";
    $pdo->exec($sql);
    echo "Fallback table 'order_payments' created/verified.";
} catch (PDOException $e) {
    echo "Error creating table: " . $e->getMessage();
}
