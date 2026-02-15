<?php
require_once 'db.php';

try {
    echo "Starting Dynamic Refactor Migration...\n";
    $sql = file_get_contents('dynamic_migration.sql');

    // Split by semicolon but preserve those inside quotes/procedures if they existed
    // For this specific file, simple splitting by ; is risky but usually okay for simple statements
    // Better: use PDO's multi-statement support if enabled, or split carefully.

    // We'll try executing the whole block if PDO allows it (depends on driver/config)
    // Most MySQL PDO drivers allow multi-query if the attribute is set.

    $pdo->exec($sql);

    echo "Migration completed successfully!\n";

    // Self-destruct for security
    // unlink(__FILE__); 
} catch (Exception $e) {
    echo "Migration FAILED: " . $e->getMessage() . "\n";
}
