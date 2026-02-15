<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

require 'db.php';

// Mock Session
if (session_status() == PHP_SESSION_NONE) {
    session_start();
}
$_SESSION['user_id'] = 1;
$_SESSION['role'] = 'admin';
$_SESSION['shop_id'] = 1;

// 1. Setup Dates
$now = date('Y-m-d H:i:s');
$yesterday = date('Y-m-d H:i:s', strtotime('-1 day'));

// 0. Cleanup from previous failed runs
$pdo->exec("DELETE FROM orders WHERE customer_name = 'Test User'");
$pdo->exec("DELETE FROM shifts WHERE user_id = 1 AND status = 'open' AND start_time = '$now'"); // Be careful not to delete real shifts

// 2. Setup Test Data

// Ensure a shift exists
$pdo->exec("INSERT INTO shifts (user_id, start_time, status) VALUES (1, '$now', 'open')");
$shiftId = $pdo->lastInsertId();

// Ensure order_type exists
$stmt = $pdo->query("SELECT id FROM order_types LIMIT 1");
$orderTypeId = $stmt->fetchColumn();
if (!$orderTypeId) {
    // Check if table exists first? excessive. Assume it does.
    $pdo->exec("INSERT INTO order_types (name, slug) VALUES ('Dine In', 'dine_in')");
    $orderTypeId = $pdo->lastInsertId();
}

// Ensure payment_method exists
$stmt = $pdo->query("SELECT id FROM payment_methods LIMIT 1");
$paymentMethodId = $stmt->fetchColumn();
if (!$paymentMethodId) {
    $pdo->exec("INSERT INTO payment_methods (name, slug) VALUES ('Cash', 'cash')");
    $paymentMethodId = $pdo->lastInsertId();
}

// Create Order TODAY
$stmt = $pdo->prepare("INSERT INTO orders (order_number, token_number, customer_name, table_id, order_type, order_type_id, payment_method, payment_method_id, subtotal, tax, service_charge, discount, packaging_charge, delivery_fee, total, status, shift_id, created_at, payment_status, completed_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

$stmt->execute([
    'TEST-TODAY',
    '1001',
    'Test User',
    null,
    'dine_in',
    $orderTypeId,
    'cash',
    $paymentMethodId,
    80.00,
    0,
    0,
    0,
    0,
    0,
    100.00,
    'completed',
    $shiftId,
    $now,
    'paid',
    $now
]);
$todayOrderId = $pdo->lastInsertId();

// Create Order YESTERDAY
$stmt->execute([
    'TEST-YESTERDAY',
    '1002',
    'Test User',
    null,
    'dine_in',
    $orderTypeId,
    'cash',
    $paymentMethodId,
    40.00,
    0,
    0,
    0,
    0,
    0,
    50.00,
    'completed',
    $shiftId,
    $yesterday,
    'paid',
    $yesterday
]);
$yesterdayOrderId = $pdo->lastInsertId();

// 2. Call API
$_REQUEST['action'] = 'get_dashboard_stats';
$_GET['action'] = 'get_dashboard_stats';

ob_start();
try {
    require 'backend.php';
} catch (Exception $e) {
    // Ignore exit
}
$output = ob_get_clean();

// 3. Cleanup
$pdo->exec("DELETE FROM orders WHERE id IN ($todayOrderId, $yesterdayOrderId)");
$pdo->exec("DELETE FROM shifts WHERE id = $shiftId");
// Don't delete order_types/payment_methods as they might be used by others

// 4. Analyze
$json = json_decode($output, true);
if (!$json) {
    echo "FAILED: Invalid JSON\n$output\n";
    exit;
}

$stats = $json['stats'];
echo "Total Sales (Today): " . $stats['total_sales'] . "\n"; // Expected 100.00 (Gross)
echo "Net Profit (Today): " . $stats['net_profit'] . "\n";   // Expected 80.00 (Net) - 0 expenses/cogs
echo "Growth Sales: " . $stats['growth']['sales'] . "%\n";   // Expected 100 vs 50 = +100%

if ($stats['total_sales'] == 100 && $stats['growth']['sales'] == 100) {
    echo "VERIFICATION PASSED\n";
} else {
    echo "VERIFICATION FAILED\n";
}
