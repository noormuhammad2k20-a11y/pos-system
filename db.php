<?php

/**
 * GustoPOS Database Connection
 * Configure your MySQL credentials in .env file
 */

require_once __DIR__ . '/EnvLoader.php';

try {
    $loader = new EnvLoader(__DIR__ . '/.env');
    $loader->load();
} catch (Exception $e) {
    // Fail silently or handle error if .env is missing/unreadable
    error_log("EnvLoader Error: " . $e->getMessage());
}

$host = getenv('DB_HOST') ?: 'localhost';
$dbname = getenv('DB_NAME') ?: 'gustopos_new_test';
$username = getenv('DB_USER') ?: 'root';
$password = getenv('DB_PASS') ?: '';
$port = getenv('DB_PORT') ?: 3307;

try {
    $pdo = new PDO("mysql:host=$host;port=$port;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Database connection failed: ' . $e->getMessage()]);
    exit;
}
