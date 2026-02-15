<?php
require_once 'db.php';
try {
    $sql = file_get_contents('add_payment_columns.sql');
    $pdo->exec($sql);
    echo "Migration successful: Payment columns added.";
} catch (PDOException $e) {
    echo "Migration failed: " . $e->getMessage();
}
