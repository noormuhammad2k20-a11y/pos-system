<?php
require_once 'db.php';

echo "<h1>GustoPOS Security Update</h1>";
echo "<p>Migrating passwords from MD5 to Bcrypt...</p>";

try {
    // 1. Reset Admin
    $adminPass = password_hash('admin123', PASSWORD_BCRYPT);
    $stmt = $pdo->prepare("UPDATE users SET password_hash = ? WHERE username = 'admin'");
    $stmt->execute([$adminPass]);
    echo "<div>✅ Admin password reset to standard secure hash.</div>";

    // 2. Reset Cashier
    $cashierPass = password_hash('cashier123', PASSWORD_BCRYPT);
    $stmt = $pdo->prepare("UPDATE users SET password_hash = ? WHERE username = 'cashier'");
    $stmt->execute([$cashierPass]);
    echo "<div>✅ Cashier password reset to standard secure hash.</div>";

    echo "<h3>Migration Complete. You can now use updated login.php</h3>";
} catch (PDOException $e) {
    echo "<div style='color:red'>Error: " . $e->getMessage() . "</div>";
}