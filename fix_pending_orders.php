<?php
require_once 'db.php';
try {
    $sql = "UPDATE orders 
            SET status = 'completed', 
                payment_status = 'paid', 
                payment_method = 'Cash',
                completed_at = created_at 
            WHERE status = 'pending' 
              AND shift_id = (SELECT id FROM shifts WHERE status = 'open' LIMIT 1)
              AND table_id IS NULL";
    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    echo "Fixed pending walk-in orders: " . $stmt->rowCount();
} catch (PDOException $e) {
    echo "Error fixing orders: " . $e->getMessage();
}
