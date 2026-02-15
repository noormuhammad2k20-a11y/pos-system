<?php
require_once 'db.php';

try {
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $sql = file_get_contents(__DIR__ . '/migrations/002_restore_shift_management.sql');

    echo "Running migration 002_restore_shift_management.sql...\n";
    $pdo->exec($sql);
    echo "Migration executed successfully.\n";
} catch (PDOException $e) {
    echo "Database Error: " . $e->getMessage() . "\n";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
