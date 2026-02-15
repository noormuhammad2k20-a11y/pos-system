<?php
require_once 'classes.php';

$data = [
    'user_id' => 999,
    'username' => 'TestAdmin',
    'role' => 'admin'
];

$token = JWTAuth::createToken($data);
echo "Token: $token\n";

$validated = JWTAuth::validateToken($token);
echo "Validated Data: " . json_encode($validated) . "\n";

if ($validated && $validated['role'] === 'admin') {
    echo "SUCCESS: Local validation works.\n";
} else {
    echo "FAIL: Local validation failed.\n";
}
