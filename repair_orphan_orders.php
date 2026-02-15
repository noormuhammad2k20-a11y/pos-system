<?php
require_once 'db.php';
try {
    $sql = "UPDATE orders 
            SET shift_id = (SELECT id FROM shifts WHERE status = 'open' LIMIT 1) 
            WHERE (shift_id IS NULL OR shift_id = 0) AND created_at > DATE_SUB(NOW(), INTERVAL 24 HOUR)";
    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    echo "Orphan orders repaired: " . $stmt->rowCount();
} catch (PDOException $e) {
    echo "Error repairing orders: " . $e->getMessage();
}
