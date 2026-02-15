<?php
require_once 'db.php';

echo "<h1>GustoPOS Phase 3 Migration</h1>";

try {
    $sql = file_get_contents('phase3_schema.sql');
    if (!$sql) die('phase3_schema.sql not found');

    $pdo->exec($sql);
    echo "<div>✅ Database schema updated successfully.</div>";
    echo "<ul>
        <li>Created <b>audit_logs</b> table</li>
        <li>Created <b>modifiers</b> table</li>
        <li>Created <b>order_payments</b> table</li>
        <li>Updated <b>orders</b> table (added payment status)</li>
        <li>Inserted default modifiers</li>
    </ul>";
} catch (PDOException $e) {
    echo "<div style='color:red'>Migration Failed: " . $e->getMessage() . "</div>";
}
