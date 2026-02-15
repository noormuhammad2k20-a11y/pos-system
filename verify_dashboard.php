<?php
// Prevent actual DB headers output
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Mock Session
if (session_status() == PHP_SESSION_NONE) {
    session_start();
}
$_SESSION['user_id'] = 1; // Assuming ID 1 exists
$_SESSION['role'] = 'admin';
$_SESSION['shop_id'] = 1;

// Mock Request
$_REQUEST['action'] = 'get_dashboard_stats';
$action = 'get_dashboard_stats'; // backend.php uses $action variable directly in some places or extracts it

// Capture Output
ob_start();
try {
    require 'backend.php';
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
$output = ob_get_clean();

// Analyze
$data = json_decode($output, true);

if (!$data) {
    echo "FAILED: Invalid JSON Response\n";
    echo "Raw Output:\n" . substr($output, 0, 500) . "...\n";
    exit(1);
}

if (!isset($data['stats']['growth'])) {
    echo "FAILED: Missing 'growth' stats\n";
    print_r($data['stats']);
    exit(1);
}

echo "SUCCESS: Dashboard Stats Retrieved\n";
print_r($data['stats']);
