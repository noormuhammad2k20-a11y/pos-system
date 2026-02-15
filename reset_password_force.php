<?php
require_once 'db.php';
$username = 'cashier3';
$password = '1234';

echo "Resetting password for: $username\n";

$stmt = $pdo->prepare("SELECT * FROM users WHERE username = ?");
$stmt->execute([$username]);
$user = $stmt->fetch();

if (!$user) {
    echo "ERROR: User '$username' NOT FOUND.\n";
    exit;
}

$hash = password_hash($password, PASSWORD_BCRYPT);
$pdo->prepare("UPDATE users SET password_hash = ? WHERE id = ?")->execute([$hash, $user['id']]);

echo "SUCCESS: Password for '$username' has been reset to '$password'.\n";
