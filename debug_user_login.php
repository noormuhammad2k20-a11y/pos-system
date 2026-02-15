<?php
require_once 'db.php';

$username = $_GET['user'] ?? 'cashier3';
$password = $_GET['pass'] ?? '1234'; // Default test pass

echo "<h1>Login Diagnostic for: " . htmlspecialchars($username) . "</h1>";

// 1. Check if user exists at all (ignoring is_active)
$stmt = $pdo->prepare("SELECT * FROM users WHERE username = ?");
$stmt->execute([$username]);
$user = $stmt->fetch();

if (!$user) {
    echo "<h2 style='color:red'>User NOT FOUND in database.</h2>";
    echo "Tips: Check for whitespace or case sensitivity.";
    exit;
}

echo "<h2>User Found:</h2>";
echo "<pre>";
print_r($user);
echo "</pre>";

// 2. Check is_active
if ($user['is_active'] != 1) {
    echo "<h2 style='color:red'>CRITICAL: User is INACTIVE (is_active = {$user['is_active']})</h2>";
    echo "<p>Login query requires `is_active = 1`.</p>";
} else {
    echo "<h3 style='color:green'>User is Active.</h3>";
}

// 3. Analyze Password Hash
$hash = $user['password_hash'];
echo "<h3>Password Analysis:</h3>";
echo "Stored Hash: " . htmlspecialchars($hash) . "<br>";

if (password_verify($password, $hash)) {
    echo "<h3 style='color:green'>Bcrypt Verification: SUCCESS! Password matches '$password'</h3>";
} else {
    echo "<p style='color:orange'>Bcrypt Verification: Failed for '$password'</p>";
}

if ($hash === md5($password)) {
    echo "<h3 style='color:green'>MD5 Verification: SUCCESS! Password matches '$password'</h3>";
} else {
    echo "<p>MD5 Verification: Fail</p>";
}

if ($hash === $password) {
    echo "<h2 style='color:red'>SECURITY WARNING: Password is stored as PLAIN TEXT!</h2>";
    echo "<p>The login system expects a Hash. It will not match plain text.</p>";
    echo "<form method='post'><input type='hidden' name='fix' value='1'><button>Fix Now (Convert to Bcrypt)</button></form>";
}

// 4. Fixer
if (isset($_POST['fix'])) {
    $newHash = password_hash($password, PASSWORD_BCRYPT);
    $pdo->prepare("UPDATE users SET password_hash = ? WHERE id = ?")->execute([$newHash, $user['id']]);
    echo "<h2 style='color:green'>Password FIXED! Try logging in now.</h2>";
}
