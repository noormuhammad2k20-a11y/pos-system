<?php

/**
 * GustoPOS Enterprise Backend API
 * Handles all AJAX requests with KOT, recipes, settings, and enterprise features
 */

header('Content-Type: application/json');
require_once 'db.php';
require_once 'helpers.php';
require_once 'classes.php';
require_once 'sync-helpers.php';
require_once 'controllers/OrderController.php';
require_once 'controllers/InventoryController.php';
require_once 'controllers/SettingsController.php';
require_once 'controllers/BusinessDayController.php'; // Replaces ShiftController
if (session_status() === PHP_SESSION_NONE) session_start();
date_default_timezone_set('Asia/Karachi');

$action = $_REQUEST['action'] ?? '';
$userRole = $_SESSION['role'] ?? 'cashier';

// --- JSON BODY DECODE (Fix for array inputs like return items) ---
$json = file_get_contents('php://input');
if ($json) {
    $data = json_decode($json, true);
    if (is_array($data)) {
        $_REQUEST = array_merge($_REQUEST, $data);
        $_POST = array_merge($_POST, $data);
    }
}

// --- JWT STATELESS AUTH CHECK ---
$authHeader = $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '';
$token = null;
if (preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
    $token = $matches[1];
} elseif (!empty($_REQUEST['token'])) {
    $token = $_REQUEST['token'];
}

require_once 'csrf_helper.php';

if ($token) {
    $tokenData = JWTAuth::validateToken($token);
    if ($tokenData) {
        $userRole = $tokenData['role'];
        // For JWT calls, we simulate session params but don't strictly require server-side session
        // However, if we need to write to session for hybrid, we can. 
        // But let's keep it stateless-ish.
        $_SESSION['user_id'] = $tokenData['user_id'] ?? 0;
        $_SESSION['username'] = $tokenData['username'] ?? 'System';
        $_SESSION['role'] = $userRole;
    }
} elseif (isset($_SESSION['user_id'])) {
    // Session-based Auth -> REQUIRE CSRF for POST
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $csrfToken = $_SERVER['HTTP_X_CSRF_TOKEN'] ?? $_POST['csrf_token'] ?? '';
        if (!Csrf::verify($csrfToken)) {
            echo json_encode(['success' => false, 'message' => 'CSRF Token Invalid or Expired']);
            exit;
        }
    }
}

// Define admin-only actions
$adminOnlyActions = [
    'update_setting',
    'update_settings_batch',
    'save_settings_management',
    'upload_logo',
    'add_category',
    'update_category',
    'delete_category',
    'add_product',
    'update_product',
    'delete_product',
    'get_dashboard_analytics',
    'get_export_data',
    'get_sales_summary',
    'export_sales',
    'export_sales_csv',
    'close_shift',
    'get_zreport_history',
    'get_zreport',
    'export_zreports',
    // New Shift Management APIs
    'open_shift',
    'close_shift_complete',
    'get_shift_details',
    'add_shift_expense',
    'delete_shift_expense',
    'get_shift_expenses',
    'export_inventory',
    'add_staff',
    'update_staff',
    'delete_staff',
    'void_order',
    'get_expenses',
    'add_expense',
    'update_expense',
    'delete_expense',
    'update_inventory_item',
    'delete_inventory_item',
    'delete_supplier',
    'reset_application_data'
];

if ($userRole === 'cashier' && in_box($action, $adminOnlyActions)) {
    echo json_encode(['success' => false, 'message' => 'Access denied: Admin only']);
    exit;
}

function in_box($needle, $haystack)
{
    return in_array($needle, $haystack);
}

// --- CONTROLLER ROUTING map ---
$routes = [
    'get_inventory' => ['InventoryController', 'getInventory'],
    'add_stock' => ['InventoryController', 'addStock'],
    'add_inventory_item' => ['InventoryController', 'addItem'],
    'update_inventory_item' => ['InventoryController', 'updateItem'],
    'delete_inventory_item' => ['InventoryController', 'deleteItem'],

    // Settings & Metadata
    'get_metadata' => ['SettingsController', 'getMetadata'],
    'get_settings_management' => ['SettingsController', 'getSettings'],
    'save_settings_management' => ['SettingsController', 'updateSettings'],
    'upload_restaurant_logo' => ['SettingsController', 'uploadLogo'],

    // Order Routes
    'place_order' => ['OrderController', 'placeOrder'],
    'create_order' => ['OrderController', 'placeOrder'],
    'void_order' => ['OrderController', 'voidOrder'],
    'add_payment' => ['OrderController', 'addPayment'],

    'transfer_table' => ['OrderController', 'transferTable'],
    'merge_tables' => ['OrderController', 'mergeTables'],
    // Business Day Management Routes (Primary)
    'get_business_day_status' => ['BusinessDayController', 'getStatus'],
    'get_business_day_stats' => ['BusinessDayController', 'getCurrentStats'],
    'open_business_day' => ['BusinessDayController', 'openBusinessDay'],
    'close_business_day' => ['BusinessDayController', 'closeBusinessDay'],

    // Legacy mapping (Aliases for backward compatibility until frontend full refresh)
    'get_shift_status' => ['BusinessDayController', 'getStatus'],
    'open_shift' => ['BusinessDayController', 'openBusinessDay'],
    'close_shift' => ['BusinessDayController', 'closeBusinessDay'],
    'get_shift_snapshot' => ['BusinessDayController', 'getCurrentStats'],
    'get_current_shift' => ['BusinessDayController', 'getCurrentStats'],
    'close_shift_complete' => ['BusinessDayController', 'closeBusinessDay'],

    // History & Expenses
    'get_business_day_history' => ['BusinessDayController', 'getBusinessDayHistory'],
    'add_business_day_expense' => ['BusinessDayController', 'addExpense'],
    'delete_business_day_expense' => ['BusinessDayController', 'deleteExpense'],
    'get_business_day_expenses' => ['BusinessDayController', 'getExpenses'],

    // Legacy Expense Routes
    'get_shift_history' => ['BusinessDayController', 'getBusinessDayHistory'],
    'add_shift_expense' => ['BusinessDayController', 'addExpense'],
    'delete_shift_expense' => ['BusinessDayController', 'deleteExpense'],
    'get_shift_expenses' => ['BusinessDayController', 'getExpenses'],
    'reset_application_data' => ['SettingsController', 'resetData'],
];

if (isset($routes[$action])) {
    [$controllerName, $method] = $routes[$action];
    require_once "controllers/$controllerName.php";
    $controller = new $controllerName($pdo);
    $controller->$method();
    exit;
}

// --- OFFLINE-FIRST PWA SYNC ENDPOINTS ---
// Simple ping endpoint for connectivity check
if ($action === 'ping') {
    echo json_encode(['success' => true, 'timestamp' => date('Y-m-d H:i:s')]);
    exit;
}

// Pull changes from server (delta sync)
if ($action === 'sync_pull') {
    $lastSync = $_GET['last_sync'] ?? '1970-01-01 00:00:00';

    try {
        $changes = [
            'products' => getChangedRecords($pdo, 'products', $lastSync),
            'categories' => getChangedRecords($pdo, 'categories', $lastSync),
            'tables' => getChangedRecords($pdo, 'restaurant_tables', $lastSync),
            'inventory' => getChangedRecords($pdo, 'inventory', $lastSync),
            'settings' => getChangedRecords($pdo, 'settings', $lastSync),
        ];

        echo json_encode([
            'success' => true,
            'changes' => $changes,
            'server_time' => date('Y-m-d H:i:s')
        ]);
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Sync pull failed: ' . $e->getMessage()
        ]);
    }
    exit;
}

// Push changes to server
if ($action === 'sync_push') {
    $changes = json_decode(file_get_contents('php://input'), true);

    if (!$changes || !isset($changes['changes'])) {
        echo json_encode(['success' => false, 'message' => 'No changes provided']);
        exit;
    }

    $conflicts = [];
    $applied = 0;

    foreach ($changes['changes'] as $change) {
        try {
            $result = applyChange($pdo, $change);
            if ($result['success']) {
                $applied++;
            } elseif ($result['conflict']) {
                $conflicts[] = $result;
            }
        } catch (Exception $e) {
            error_log("Sync error: " . $e->getMessage());
        }
    }

    echo json_encode([
        'success' => true,
        'applied' => $applied,
        'conflicts' => $conflicts,
        'server_time' => date('Y-m-d H:i:s')
    ]);
    exit;
}

// --- LEGACY ROUTING ---
switch ($action) {
    // usage of generate_report moved to newer implementation below

    case 'delete_table':
        $tableId = $_POST['table_id'] ?? 0;
        echo json_encode(deleteTable($pdo, $tableId));
        break;

    case 'closeShiftComplete':
        echo json_encode(closeShiftComplete($pdo, $_SESSION['user_id'], $_POST));
        break;

    case 'get_settings':
        // ... rest of switch ...
        $category = $_GET['category'] ?? 'all';
        $cacheKey = "settings_$category";
        $cached = GustoCache::get($cacheKey);
        if ($cached) {
            echo json_encode(['success' => true, 'data' => $cached, 'cached' => true]);
            break;
        }

        $sql = "SELECT * FROM settings";
        if ($category !== 'all') $sql .= " WHERE category = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute($category !== 'all' ? [$category] : []);
        $settings = [];
        foreach ($stmt->fetchAll() as $row) {
            $value = $row['setting_value'];
            if ($row['setting_type'] === 'boolean') $value = ($value === 'true');
            elseif ($row['setting_type'] === 'number') $value = floatval($value);
            elseif ($row['setting_type'] === 'json') $value = json_decode($value, true);
            $settings[$row['setting_key']] = $value;
        }
        GustoCache::set($cacheKey, $settings);
        echo json_encode(['success' => true, 'data' => $settings]);
        break;

    case 'get_setting':
        $key = $_GET['key'] ?? '';
        $stmt = $pdo->prepare("SELECT * FROM settings WHERE setting_key = ?");
        $stmt->execute([$key]);
        $row = $stmt->fetch();
        $value = $row ? $row['setting_value'] : null;
        echo json_encode(['success' => true, 'value' => $value]);
        break;

    case 'update_setting':
        $key = $_POST['key'] ?? '';
        $value = $_POST['value'] ?? '';
        $stmt = $pdo->prepare("UPDATE settings SET setting_value = ? WHERE setting_key = ?");
        $stmt->execute([$value, $key]);
        echo json_encode(['success' => true]);
        break;

    case 'update_settings_batch':
        $settings = json_decode($_POST['settings'] ?? '{}', true);
        foreach ($settings as $key => $value) {
            if (is_bool($value)) $value = $value ? 'true' : 'false';
            if ($value === null || $value === '') continue; // Skip empty values

            // Use INSERT ON DUPLICATE KEY UPDATE to create missing settings
            $stmt = $pdo->prepare("INSERT INTO settings (setting_key, setting_value, setting_type, category) 
                                   VALUES (?, ?, 'text', 'general') 
                                   ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)");
            $stmt->execute([$key, (string)$value]);
        }
        GustoCache::clear('settings_all');
        echo json_encode(['success' => true, 'message' => 'Settings saved']);
        break;

    case 'upload_logo':
        if (!isset($_FILES['logo']) || $_FILES['logo']['error'] !== UPLOAD_ERR_OK) {
            echo json_encode(['success' => false, 'message' => 'No file uploaded or upload error.']);
            break;
        }

        $uploadDir = 'assets/';
        if (!is_dir($uploadDir)) mkdir($uploadDir, 0777, true);

        $ext = pathinfo($_FILES['logo']['name'], PATHINFO_EXTENSION);
        $filename = 'logo_' . time() . '.' . $ext;
        $targetPath = $uploadDir . $filename;

        if (move_uploaded_file($_FILES['logo']['tmp_name'], $targetPath)) {
            // Update setting in database
            $stmt = $pdo->prepare("INSERT INTO settings (setting_key, setting_value, category) 
                                   VALUES ('restaurant_logo', ?, 'general') 
                                   ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)");
            $stmt->execute([$targetPath]);
            GustoCache::clear('settings_all');
            echo json_encode(['success' => true, 'path' => $targetPath]);
        } else {
            echo json_encode(['success' => false, 'message' => 'Failed to move uploaded file.']);
        }
        break;


    // ============ CATEGORIES ============
    case 'get_categories':
        $cached = GustoCache::get('categories');
        if ($cached) {
            echo json_encode(['success' => true, 'data' => $cached, 'cached' => true]);
            break;
        }

        $stmt = $pdo->query("SELECT * FROM categories ORDER BY name");
        $data = $stmt->fetchAll();
        GustoCache::set('categories', $data);
        echo json_encode(['success' => true, 'data' => $data]);
        break;

    case 'add_category':
        $name = $_POST['name'] ?? '';
        $stmt = $pdo->prepare("INSERT INTO categories (name) VALUES (?)");
        $stmt->execute([$name]);
        GustoCache::clear('categories');
        echo json_encode(['success' => true, 'id' => $pdo->lastInsertId()]);
        break;

    case 'update_category':
        $id = $_POST['id'] ?? 0;
        $name = $_POST['name'] ?? '';
        $stmt = $pdo->prepare("UPDATE categories SET name = ? WHERE id = ?");
        $stmt->execute([$name, $id]);
        GustoCache::clear('categories');
        echo json_encode(['success' => true]);
        break;

    case 'delete_category':
        $id = $_POST['id'] ?? 0;
        // Check if products exist in category
        $stmt = $pdo->prepare("SELECT COUNT(*) FROM products WHERE category_id = ?");
        $stmt->execute([$id]);
        if ($stmt->fetchColumn() > 0) {
            echo json_encode(['success' => false, 'message' => 'Category has products. Delete or move them first.']);
        } else {
            $stmt = $pdo->prepare("DELETE FROM categories WHERE id = ?");
            $stmt->execute([$id]);
            GustoCache::clear('categories');
            echo json_encode(['success' => true]);
        }
        break;

    // ============ PRODUCTS ============
    case 'get_products':
        $categoryId = $_GET['category_id'] ?? 'all';
        $sql = "SELECT p.*, c.name as category_name, (SELECT inventory_id FROM recipes WHERE product_id = p.id LIMIT 1) as linked_inventory_id FROM products p LEFT JOIN categories c ON p.category_id = c.id WHERE p.is_available = 1";
        if ($categoryId !== 'all') $sql .= " AND p.category_id = ?";
        $sql .= " ORDER BY p.name";
        $stmt = $pdo->prepare($sql);
        $stmt->execute($categoryId !== 'all' ? [$categoryId] : []);
        echo json_encode(['success' => true, 'data' => $stmt->fetchAll()]);
        break;

    case 'get_all_products':
        $page = max(1, intval($_GET['page'] ?? 1));
        $limit = max(1, intval($_GET['limit'] ?? 5));
        $offset = ($page - 1) * $limit;

        $totalRecords = $pdo->query("SELECT COUNT(*) FROM products")->fetchColumn();
        $totalPages = ceil($totalRecords / $limit);

        $stmt = $pdo->prepare("SELECT p.*, c.name as category_name, (SELECT inventory_id FROM recipes WHERE product_id = p.id LIMIT 1) as linked_inventory_id FROM products p LEFT JOIN categories c ON p.category_id = c.id ORDER BY p.name LIMIT ? OFFSET ?");
        $stmt->bindValue(1, $limit, PDO::PARAM_INT);
        $stmt->bindValue(2, $offset, PDO::PARAM_INT);
        $stmt->execute();

        echo json_encode([
            'success' => true,
            'data' => $stmt->fetchAll(),
            'pagination' => [
                'current_page' => $page,
                'total_pages' => (int)$totalPages,
                'total_records' => (int)$totalRecords,
                'limit' => $limit
            ]
        ]);
        break;

    case 'add_product':
        $name = $_POST['name'] ?? '';
        $price = $_POST['price'] ?? 0;
        $categoryId = $_POST['category_id'] ?: null;
        $image = 'https://placehold.co/150x100/png?text=Item';

        if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
            $uploadDir = 'uploads/products/';
            if (!is_dir($uploadDir)) mkdir($uploadDir, 0777, true);

            $ext = pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION);
            $filename = 'prod_' . time() . '_' . rand(100, 999) . '.' . $ext;
            $targetPath = $uploadDir . $filename;

            if (move_uploaded_file($_FILES['image']['tmp_name'], $targetPath)) {
                $image = $targetPath;
            }
        }

        $stmt = $pdo->prepare("INSERT INTO products (name, price, category_id, image) VALUES (?, ?, ?, ?)");
        $stmt->execute([$name, $price, $categoryId, $image]);
        $newProdId = $pdo->lastInsertId();

        // Direct Inventory Link
        $linkedInventoryId = $_POST['inventory_id'] ?? null;
        if ($linkedInventoryId) {
            $stmt = $pdo->prepare("INSERT INTO recipes (product_id, inventory_id, qty_required) VALUES (?, ?, 1)");
            $stmt->execute([$newProdId, $linkedInventoryId]);
        }

        echo json_encode(['success' => true, 'id' => $newProdId]);
        break;

    case 'update_product':
        $id = $_POST['id'] ?? 0;
        $name = $_POST['name'] ?? '';
        $price = $_POST['price'] ?? 0;
        $categoryId = $_POST['category_id'] ?: null;

        $sql = "UPDATE products SET name = ?, price = ?, category_id = ?";
        $params = [$name, $price, $categoryId];

        if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
            $uploadDir = 'uploads/products/';
            if (!is_dir($uploadDir)) mkdir($uploadDir, 0777, true);

            $ext = pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION);
            $filename = 'prod_' . time() . '_' . rand(100, 999) . '.' . $ext;
            $targetPath = $uploadDir . $filename;

            if (move_uploaded_file($_FILES['image']['tmp_name'], $targetPath)) {
                $sql .= ", image = ?";
                $params[] = $targetPath;
            }
        }

        $sql .= " WHERE id = ?";
        $params[] = $id;

        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);

        // Direct Inventory Link Update
        if (isset($_POST['inventory_id'])) {
            $linkedInventoryId = $_POST['inventory_id'];
            // Clear existing recipes for this product (assuming 1:1 for this feature)
            $pdo->prepare("DELETE FROM recipes WHERE product_id = ?")->execute([$id]);

            if ($linkedInventoryId) {
                $pdo->prepare("INSERT INTO recipes (product_id, inventory_id, qty_required) VALUES (?, ?, 1)")->execute([$id, $linkedInventoryId]);
            }
        }

        echo json_encode(['success' => true]);
        break;

    case 'toggle_product_availability':
        $id = $_POST['id'] ?? 0;
        $isAvailable = $_POST['is_available'] ?? 1;
        $stmt = $pdo->prepare("UPDATE products SET is_available = ? WHERE id = ?");
        $stmt->execute([$isAvailable, $id]);
        echo json_encode(['success' => true]);
        break;

    case 'delete_product':
        $id = $_POST['id'] ?? 0;
        $stmt = $pdo->prepare("DELETE FROM products WHERE id = ?");
        $stmt->execute([$id]);
        echo json_encode(['success' => true]);
        break;

    // ============ RECIPES ============
    case 'get_recipes':
        $productId = $_GET['product_id'] ?? null;
        $page = max(1, intval($_GET['page'] ?? 1));
        $limit = max(1, intval($_GET['limit'] ?? 5));
        $offset = ($page - 1) * $limit;

        $sqlBase = "FROM recipes r 
                JOIN products p ON r.product_id = p.id 
                JOIN inventory i ON r.inventory_id = i.id";
        $where = "";
        $params = [];
        if ($productId) {
            $where = " WHERE r.product_id = ?";
            $params[] = $productId;
        }

        // Count total
        $totalRecords = $pdo->prepare("SELECT COUNT(*) $sqlBase $where");
        $totalRecords->execute($params);
        $totalCount = $totalRecords->fetchColumn();
        $totalPages = ceil($totalCount / $limit);

        $sql = "SELECT r.*, p.name as product_name, i.name as ingredient_name, i.consumption_unit 
                $sqlBase $where ORDER BY p.name, i.name LIMIT $limit OFFSET $offset";
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);

        echo json_encode([
            'success' => true,
            'data' => $stmt->fetchAll(),
            'pagination' => [
                'current_page' => $page,
                'total_pages' => (int)$totalPages,
                'total_records' => (int)$totalCount,
                'limit' => $limit
            ]
        ]);
        break;

    case 'add_recipe':
        $productId = $_POST['product_id'] ?? 0;
        $inventoryId = $_POST['inventory_id'] ?? 0;
        $qtyRequired = $_POST['qty_required'] ?? 0;
        $stmt = $pdo->prepare("INSERT INTO recipes (product_id, inventory_id, qty_required) VALUES (?, ?, ?)");
        $stmt->execute([$productId, $inventoryId, $qtyRequired]);
        echo json_encode(['success' => true, 'id' => $pdo->lastInsertId()]);
        break;

    case 'update_recipe':
        $id = $_POST['id'] ?? 0;
        $qtyRequired = $_POST['qty_required'] ?? 0;
        $stmt = $pdo->prepare("UPDATE recipes SET qty_required = ? WHERE id = ?");
        $stmt->execute([$qtyRequired, $id]);
        echo json_encode(['success' => true]);
        break;

    case 'delete_recipe':
        $id = $_POST['id'] ?? 0;
        $stmt = $pdo->prepare("DELETE FROM recipes WHERE id = ?");
        $stmt->execute([$id]);
        echo json_encode(['success' => true]);
        break;

    case 'check_stock_availability':
        $productId = $_REQUEST['product_id'] ?? 0;
        $qty = $_REQUEST['quantity'] ?? 1;
        $items = json_decode($_POST['items'] ?? '[]', true);

        if (empty($items) && $productId) {
            $items = [['product_id' => $productId, 'quantity' => $qty, 'name' => 'Item']];
        }

        $unavailable = [];
        foreach ($items as $item) {
            $stmt = $pdo->prepare("SELECT r.*, i.name, i.quantity as available, i.consumption_unit 
                                   FROM recipes r JOIN inventory i ON r.inventory_id = i.id 
                                   WHERE r.product_id = ?");
            $stmt->execute([$item['product_id']]);
            foreach ($stmt->fetchAll() as $recipe) {
                $required = $recipe['qty_required'] * $item['quantity'];
                if ($required > $recipe['available']) {
                    $unavailable[] = [
                        'product' => $item['name'] ?? 'Product',
                        'product_id' => $item['product_id'],
                        'ingredient' => $recipe['name'],
                        'required' => $required,
                        'available' => $recipe['available'],
                        'unit' => $recipe['consumption_unit']
                    ];
                }
            }
        }
        echo json_encode(['success' => true, 'can_make' => empty($unavailable), 'insufficient_items' => $unavailable, 'shortages' => $unavailable]);
        exit;

        // ============ TABLES ============
    case 'get_tables':
        $stmt = $pdo->query("SELECT t.*, s.name as waiter_name, u.display_name as locked_user_name 
                             FROM restaurant_tables t 
                             LEFT JOIN staff s ON t.waiter_id = s.id 
                             LEFT JOIN users u ON t.locked_by = u.id 
                             ORDER BY t.name");
        $tables = $stmt->fetchAll();

        // Auto-unlock if stale (> 5 mins)
        $updated = false;
        foreach ($tables as &$t) {
            if ($t['locked_at'] && (time() - strtotime($t['locked_at']) > 300)) {
                $pdo->prepare("UPDATE restaurant_tables SET locked_by = NULL, locked_at = NULL WHERE id = ?")->execute([$t['id']]);
                $t['locked_by'] = null;
                $t['locked_at'] = null;
                $t['locked_user_name'] = null;
                $updated = true;
            }
        }
        if ($updated) broadcastWS('refresh_tables');

        echo json_encode(['success' => true, 'data' => $tables]);
        break;

    case 'lock_table':
        $id = $_POST['id'] ?? 0;
        $userId = $tokenData['user_id'] ?? ($_SESSION['user_id'] ?? 0);

        if (!$userId) {
            echo json_encode(['success' => false, 'message' => 'Unauthorized']);
            exit;
        }

        $stmt = $pdo->prepare("SELECT locked_by, locked_at FROM restaurant_tables WHERE id = ?");
        $stmt->execute([$id]);
        $table = $stmt->fetch();

        // If locked by someone else and not stale
        if ($table && $table['locked_by'] && $table['locked_by'] != $userId && (time() - strtotime($table['locked_at']) < 300)) {
            $userStmt = $pdo->prepare("SELECT display_name FROM users WHERE id = ?");
            $userStmt->execute([$table['locked_by']]);
            $locker = $userStmt->fetchColumn();
            echo json_encode(['success' => false, 'message' => "Table is locked by $locker"]);
            break;
        }

        $stmt = $pdo->prepare("UPDATE restaurant_tables SET locked_by = ?, locked_at = NOW() WHERE id = ?");
        $stmt->execute([$userId, $id]);

        broadcastWS('table_locked', ['table_id' => $id, 'user_id' => $userId]);
        echo json_encode(['success' => true]);
        break;

    case 'unlock_table':
        $id = $_POST['id'] ?? 0;
        $userId = $tokenData['user_id'] ?? ($_SESSION['user_id'] ?? 0);

        // Only unlock if locked by self or admin override (optional)
        $stmt = $pdo->prepare("UPDATE restaurant_tables SET locked_by = NULL, locked_at = NULL WHERE id = ? AND (locked_by = ? OR ? = 'admin')");
        // For simplicity, allowing unlock by ID check. Passing userRole would be better for admin override.
        $stmt->execute([$id, $userId, $userRole]);

        broadcastWS('table_unlocked', ['table_id' => $id]);
        echo json_encode(['success' => true]);
        break;

    case 'update_table_status':
        $id = $_POST['id'] ?? 0;
        $status = $_POST['status'] ?? 'free';
        $waiterId = $_POST['waiter_id'] ?: null;
        $occupiedSince = ($status === 'busy') ? date('Y-m-d H:i:s') : null;
        $stmt = $pdo->prepare("UPDATE restaurant_tables SET status = ?, waiter_id = ?, occupied_since = ? WHERE id = ?");
        $stmt->execute([$status, $waiterId, $occupiedSince, $id]);
        broadcastWS('refresh_tables');
        echo json_encode(['success' => true]);
        break;

    case 'clear_table':
        $id = $_POST['id'] ?? 0;
        $stmt = $pdo->prepare("UPDATE restaurant_tables SET status = 'free', waiter_id = NULL, occupied_since = NULL, current_order_id = NULL, locked_by = NULL, locked_at = NULL WHERE id = ?");
        $stmt->execute([$id]);
        broadcastWS('refresh_tables');
        echo json_encode(['success' => true]);
        break;

    case 'add_table':
        $name = $_POST['name'] ?? '';
        $seats = $_POST['seats'] ?? 4;
        $stmt = $pdo->prepare("INSERT INTO restaurant_tables (name, seats, status) VALUES (?, ?, 'free')");
        $stmt->execute([$name, $seats]);
        broadcastWS('refresh_tables');
        echo json_encode(['success' => true, 'id' => $pdo->lastInsertId()]);
        break;

    case 'update_table':
        $id = $_POST['id'] ?? 0;
        $name = $_POST['name'] ?? '';
        $seats = $_POST['seats'] ?? 4;
        $stmt = $pdo->prepare("UPDATE restaurant_tables SET name = ?, seats = ? WHERE id = ?");
        $stmt->execute([$name, $seats, $id]);
        broadcastWS('refresh_tables');
        echo json_encode(['success' => true]);
        break;

    case 'generate_report':
        ob_clean();
        header('Content-Type: application/json');
        try {
            $start_date = $_REQUEST['start_date'] ?? date('Y-m-d');
            $end_date = $_REQUEST['end_date'] ?? date('Y-m-d');
            $page = max(1, intval($_REQUEST['page'] ?? 1));
            $limit = max(1, intval($_REQUEST['limit'] ?? 20));
            $offset = ($page - 1) * $limit;
            $search = $_REQUEST['search'] ?? '';

            // Fetch Dynamic Setting
            $stmt = $pdo->prepare("SELECT setting_value FROM settings WHERE setting_key = 'business_day_start'");
            $stmt->execute();
            $cutoff = (int)($stmt->fetchColumn() ?: 0);

            // Apply Business Day Logic
            $start_full = date('Y-m-d H:i:s', strtotime("$start_date $cutoff:00:00"));
            $end_full   = date('Y-m-d H:i:s', strtotime("$end_date $cutoff:00:00 +1 day -1 second"));

            // 4. SEARCH FILTERS
            $searchClause = "";
            $searchParams = [];
            if (!empty($search)) {
                $searchClause = " AND (order_number LIKE ? OR customer_name LIKE ? OR created_at LIKE ? OR total LIKE ? OR payment_method LIKE ? OR status LIKE ? OR order_type LIKE ?)";
                $searchTerm = "%$search%";
                $searchParams = array_fill(0, 7, $searchTerm);
            }

            // 5. QUERY TOTALS
            $statsQuery = "SELECT 
                COUNT(*) as total_orders,
                COALESCE(SUM(total), 0) as total_revenue,
                COALESCE(SUM(CASE WHEN payment_method = 'cash' THEN total ELSE 0 END), 0) as cash_sales
                FROM orders 
                WHERE status = 'completed' AND created_at BETWEEN ? AND ? $searchClause";

            $stmt = $pdo->prepare($statsQuery);
            $stmt->execute(array_merge([$start_full, $end_full], $searchParams));
            $stats = $stmt->fetch(PDO::FETCH_ASSOC);

            // 6. QUERY EXPENSES
            $expQuery = "SELECT COALESCE(SUM(amount), 0) as total_expenses FROM expenses WHERE created_at BETWEEN ? AND ?";
            $stmt = $pdo->prepare($expQuery);
            $stmt->execute([$start_full, $end_full]);
            $expenses = $stmt->fetch(PDO::FETCH_ASSOC);

            // 7. QUERY TRANSACTIONS
            $listQuery = "SELECT order_number, created_at, customer_name, payment_method, total, status, order_type 
                          FROM orders 
                          WHERE status = 'completed' AND created_at BETWEEN ? AND ? $searchClause 
                          ORDER BY created_at DESC LIMIT ? OFFSET ?";
            $stmt = $pdo->prepare($listQuery);
            $bindIdx = 1;
            $stmt->bindValue($bindIdx++, $start_full);
            $stmt->bindValue($bindIdx++, $end_full);
            foreach ($searchParams as $param) {
                $stmt->bindValue($bindIdx++, $param);
            }
            $stmt->bindValue($bindIdx++, $limit, PDO::PARAM_INT);
            $stmt->bindValue($bindIdx++, $offset, PDO::PARAM_INT);
            $stmt->execute();
            $transactions = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // 8. QUERY ITEM BREAKDOWN
            $itemQuery = "SELECT product_name, SUM(quantity) as total_qty 
                          FROM order_items 
                          JOIN orders ON order_items.order_id = orders.id 
                          WHERE orders.status = 'completed' AND orders.created_at BETWEEN ? AND ? 
                          GROUP BY product_name 
                          ORDER BY total_qty DESC";
            $stmt = $pdo->prepare($itemQuery);
            $stmt->execute([$start_full, $end_full]);
            $itemBreakdown = $stmt->fetchAll(PDO::FETCH_ASSOC);

            // 9. RETURN RESPONSE (With Encoding Fix)
            $total_records = (int)$stats['total_orders'];
            $total_pages = ceil($total_records / $limit);
            $rev = (float)$stats['total_revenue'];
            $exp = (float)$expenses['total_expenses'];

            $response = [
                'status' => 'success',
                'meta' => [
                    'business_day_start' => $cutoff,
                    'range_start' => $start_full,
                    'range_end' => $end_full
                ],
                'data' => [
                    'orders' => $total_records,
                    'revenue' => number_format($rev, 2),
                    'cash_sales' => number_format((float)$stats['cash_sales'], 2),
                    'expenses' => number_format($exp, 2),
                    'net_profit' => number_format($rev - $exp, 2),
                    'transactions' => $transactions,
                    'item_breakdown' => $itemBreakdown,
                    'pagination' => [
                        'total_records' => $total_records,
                        'total_pages' => $total_pages,
                        'current_page' => $page,
                        'limit' => $limit
                    ]
                ]
            ];

            // Use substitute to handle special characters without breaking JSON
            echo json_encode($response, JSON_INVALID_UTF8_SUBSTITUTE | JSON_PARTIAL_OUTPUT_ON_ERROR);
        } catch (Exception $e) {
            echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
        }
        exit;

    case 'get_table_running_bill':
        $tableId = $_GET['table_id'] ?? 0;
        $rows = [];

        // First try: Find order by table_id directly
        $stmt = $pdo->prepare("SELECT o.*, oi.id as item_id, oi.product_name, oi.quantity, oi.price, oi.is_kot_printed, oi.notes
                               FROM orders o 
                               JOIN order_items oi ON o.id = oi.order_id 
                               WHERE o.table_id = ? AND o.status IN ('pending', 'held') 
                               ORDER BY oi.id");
        $stmt->execute([$tableId]);
        $rows = $stmt->fetchAll();

        // Fallback: If no order found by table_id, check via current_order_id in restaurant_tables
        if (empty($rows)) {
            $tableStmt = $pdo->prepare("SELECT current_order_id FROM restaurant_tables WHERE id = ?");
            $tableStmt->execute([$tableId]);
            $tableData = $tableStmt->fetch();

            if ($tableData && $tableData['current_order_id']) {
                $stmt = $pdo->prepare("SELECT o.*, oi.id as item_id, oi.product_name, oi.quantity, oi.price, oi.is_kot_printed, oi.notes
                                       FROM orders o 
                                       JOIN order_items oi ON o.id = oi.order_id 
                                       WHERE o.id = ? AND o.status IN ('pending', 'held') 
                                       ORDER BY oi.id");
                $stmt->execute([$tableData['current_order_id']]);
                $rows = $stmt->fetchAll();
            }
        }

        if (empty($rows)) {
            echo json_encode(['success' => true, 'data' => null]);
        } else {
            $order = ['id' => $rows[0]['id'], 'order_number' => $rows[0]['order_number'], 'items' => []];
            foreach ($rows as $row) {
                $order['items'][] = [
                    'id' => $row['item_id'],
                    'product_name' => $row['product_name'],
                    'quantity' => $row['quantity'],
                    'price' => $row['price'],
                    'is_kot_printed' => $row['is_kot_printed'],
                    'notes' => $row['notes']
                ];
            }
            echo json_encode(['success' => true, 'data' => $order]);
        }
        break;

    // ============ ORDERS (Enterprise) ============
    case 'create_order':
        $customerName = $_POST['customer_name'] ?? 'Walk-in';
        $tableId = $_POST['table_id'] ?: null;
        $orderType = $_POST['order_type'] ?? 'dine_in';
        $items = json_decode($_POST['items'] ?? '[]', true);

        // --- STRICT STOCK CHECK ---
        $strict = 'true'; // Force strict mode (Mandatory)
        if ($strict === 'true' || $strict === '1') {
            $stockCheck = checkStockAvailability($pdo, $items);
            if (!$stockCheck['success']) {
                echo json_encode(['success' => false, 'message' => 'Insufficient stock: ' . implode(', ', $stockCheck['missing'])]);
                break;
            }
        }

        try {
            // === START TRANSACTION ===
            $pdo->beginTransaction();

            $subtotal = $_POST['subtotal'] ?? 0;
            $tax = $_POST['tax'] ?? 0;
            $serviceCharge = $_POST['service_charge'] ?? 0;
            $packagingCharge = $_POST['packaging_charge'] ?? 0;
            $deliveryFee = $_POST['delivery_fee'] ?? 0;
            $total = $_POST['total'] ?? 0;
            $status = $_POST['status'] ?? 'pending';

            if ($orderType !== 'dine_in') {
                $tableId = null;
            }

            $orderId = null;
            $isExistingOrder = false; // Track if we're merging into an existing order

            if ($tableId) {
                // STRICT: First check if ANY pending/held order exists for this table
                $orderStmt = $pdo->prepare("SELECT id, token_number, order_number FROM orders WHERE table_id = ? AND status IN ('pending', 'held') ORDER BY id DESC LIMIT 1");
                $orderStmt->execute([$tableId]);
                $existing = $orderStmt->fetch();

                if ($existing) {
                    // ALWAYS merge - never create duplicate orders for same table
                    $orderId = $existing['id'];
                    $tokenNumber = $existing['token_number'];
                    $orderNumber = $existing['order_number'];
                    $isExistingOrder = true;
                } else {
                    // FALLBACK: Check current_order_id on table
                    $tableStmt = $pdo->prepare("SELECT current_order_id FROM restaurant_tables WHERE id = ?");
                    $tableStmt->execute([$tableId]);
                    $tableData = $tableStmt->fetch();

                    if ($tableData && $tableData['current_order_id']) {
                        $checkStmt = $pdo->prepare("SELECT id, token_number, order_number FROM orders WHERE id = ? AND status IN ('pending', 'held')");
                        $checkStmt->execute([$tableData['current_order_id']]);
                        $existing = $checkStmt->fetch();
                        if ($existing) {
                            $orderId = $existing['id'];
                            $tokenNumber = $existing['token_number'];
                            $orderNumber = $existing['order_number'];
                            $isExistingOrder = true;
                        }
                    }
                }
            }

            // STRICT SESSION LOGIC: Block order if no active session
            $inputShiftId = $_POST['shift_id'] ?? null;
            $shiftId = null;

            // Only accept input if it's a positive integer
            if (!empty($inputShiftId) && is_numeric($inputShiftId) && $inputShiftId > 0) {
                $shiftId = $inputShiftId;
            }

            // If invalid or missing, FORCE fetch the current open shift
            if (!$shiftId) {
                $stmt = $pdo->query("SELECT id FROM shifts WHERE status = 'open' ORDER BY id DESC LIMIT 1");
                $shiftId = $stmt->fetchColumn();
            }

            // If still no shift, create a temporary 'auto-open' shift or block (Decided: Block)
            if (!$shiftId) {
                $pdo->rollBack();
                echo json_encode(['success' => false, 'message' => 'System Error: No active shift found. Please open a shift.']);
                exit;
            }

            // Ensure orderId is set if passed (variables like $tableId, $items were parsed at top of function)
            $orderId = $_POST['order_id'] ?? ($orderId ?? 0);

            // Validate existing if ID provided
            if ($orderId) {
                $stmt = $pdo->prepare("SELECT id, status, shift_id, token_number, order_number FROM orders WHERE id = ?");
                $stmt->execute([$orderId]);
                $existing = $stmt->fetch();
                if ($existing) {
                    $isExistingOrder = true;
                    // Preserve existing numbers if we found it by ID
                    $tokenNumber = $existing['token_number'];
                    $orderNumber = $existing['order_number'];
                } else {
                    $orderId = 0; // Invalid ID, treat as new
                    $isExistingOrder = false;
                }
            }

            if (!$orderId) {
                /*
                 * Token Generation (Session Based)
                 * Reset token number to 1 for each new session.
                 */
                $tokenNumber = 1;
                if ($shiftId) {
                    $tokenStmt = $pdo->prepare("SELECT MAX(token_number) FROM orders WHERE shift_id = ?");
                    $tokenStmt->execute([$shiftId]);
                    $maxToken = $tokenStmt->fetchColumn();
                    $tokenNumber = ($maxToken) ? $maxToken + 1 : 1;
                } else {
                    // Fallback (Legacy)
                    $tokenStmt = $pdo->prepare("SELECT MAX(token_number) FROM orders WHERE DATE(created_at) = CURDATE()");
                    $tokenStmt->execute();
                    $maxToken = $tokenStmt->fetchColumn();
                    $tokenNumber = ($maxToken) ? $maxToken + 1 : 1;
                }

                $orderNumber = 'INV-' . date('ymd') . '-' . str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);

                // Calculate initial totals (0, will be updated)
                $stmt = $pdo->prepare("INSERT INTO orders (order_number, token_number, customer_name, table_id, order_type, subtotal, tax, service_charge, packaging_charge, delivery_fee, total, status, completed_at, shift_id, payment_method, payment_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

                // CASH-ONLY OPTIMIZATION: Initialize all variables first            
                $paymentMethod = 'Cash';
                $paymentStatus = 'unpaid';
                $completedAt = null;

                if ($status === 'completed') {
                    $paymentStatus = 'paid';
                    $completedAt = date('Y-m-d H:i:s');
                }

                $stmt->execute([$orderNumber, $tokenNumber, $customerName, $tableId, $orderType, $subtotal, $tax, $serviceCharge, $packagingCharge, $deliveryFee, $total, $status, $completedAt, $shiftId, $paymentMethod, $paymentStatus]);
                $orderId = $pdo->lastInsertId();
            }

            // UPSERT Items - REFACTORED: Fetch ALL existing items first to avoid N+1 and ensure robust matching
            $existingItemsMap = [];
            $stmt = $pdo->prepare("SELECT id, product_id, quantity FROM order_items WHERE order_id = ?");
            $stmt->execute([$orderId]);
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $existingItemsMap[$row['product_id']] = $row;
            }

            // Flag to determine if we ADD to existing quantity or REPLACE it
            // Default is false (Sync Mode - Replace) unless frontend explicitly requests Incremental Mode
            $isIncremental = filter_var($_POST['incremental'] ?? false, FILTER_VALIDATE_BOOLEAN);

            $updateItemStmt = $pdo->prepare("UPDATE order_items SET quantity = ?, price = ?, notes = ? WHERE id = ?"); // Added price/notes update
            $insertItemStmt = $pdo->prepare("INSERT INTO order_items (order_id, product_id, product_name, quantity, price, notes) VALUES (?, ?, ?, ?, ?, ?)");

            foreach ($items as $item) {
                // ROBUST MATCHING: Use product_id
                if (isset($existingItemsMap[$item['id']])) {
                    $existingItem = $existingItemsMap[$item['id']];

                    // CALCULATE NEW QUANTITY based on mode
                    $newQuantity = $item['quantity'];
                    if ($isIncremental) {
                        $newQuantity += $existingItem['quantity'];
                    }

                    // UPDATE: Set to the calculated new quantity
                    $updateItemStmt->execute([$newQuantity, $item['price'], $item['notes'] ?? null, $existingItem['id']]);

                    unset($existingItemsMap[$item['id']]);
                } else {
                    // INSERT: New item
                    $insertItemStmt->execute([$orderId, $item['id'], $item['name'], $item['quantity'], $item['price'], $item['notes'] ?? null]);
                }
            }

            // NOTE: Remaining items in $existingItemsMap are those NOT in the current cart.
            // If Sync Mode (isIncremental=false), we technically should delete them to match the cart state exactly.
            // But for safety in a multi-user POS environment, we often avoid silent deletes unless explicit.
            // For now, we only update/insert.

            // Always recalculate if we appended or created
            recalculateOrderTotals($pdo, $orderId);

            // Update table status if dine-in - for BOTH new AND merged orders
            if ($tableId && $orderType === 'dine_in') {
                $pdo->prepare("UPDATE restaurant_tables SET status = 'busy', occupied_since = NOW(), current_order_id = ? WHERE id = ?")->execute([$orderId, $tableId]);
            }

            // Deduct stock if order is completed (rare here, usually only on payment)
            if (isset($status) && $status === 'completed') {
                deductStockForOrder($pdo, $orderId);
            }

            // === COMMIT TRANSACTION ===
            $pdo->commit();

            // --- REAL-TIME BROADCAST (After Commit) ---
            broadcastWS('new_order', ['order_id' => $orderId, 'order_number' => $orderNumber ?? 'Merged']);

            echo json_encode(['success' => true, 'order_id' => $orderId, 'order_number' => $orderNumber ?? 'Merged', 'token_number' => $tokenNumber ?? 0, 'merged' => $isExistingOrder]);
        } catch (Exception $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            error_log("Order Creation Failed: " . $e->getMessage());
            echo json_encode(['success' => false, 'message' => 'Order creation failed: ' . $e->getMessage()]);
        }
        break;

    case 'add_items_to_order':
        $orderId = $_POST['order_id'] ?? 0;
        $items = json_decode($_POST['items'] ?? '[]', true);

        // --- STRICT STOCK CHECK ---
        // $stmt = $pdo->query("SELECT setting_value FROM settings WHERE setting_key = 'strict_stock_control'");
        $strict = 'true'; // Force strict mode (Mandatory)
        if ($strict === 'true' || $strict === '1') {
            $stockCheck = checkStockAvailability($pdo, $items);
            if (!$stockCheck['success']) {
                echo json_encode(['success' => false, 'message' => 'Insufficient stock: ' . implode(', ', $stockCheck['missing'])]);
                break;
            }
        }

        $itemStmt = $pdo->prepare("INSERT INTO order_items (order_id, product_id, product_name, quantity, price, notes) VALUES (?, ?, ?, ?, ?, ?)");
        foreach ($items as $item) {
            $itemStmt->execute([$orderId, $item['id'], $item['name'], $item['quantity'], $item['price'], $item['notes'] ?? null]);
        }

        // Recalculate totals
        recalculateOrderTotals($pdo, $orderId);

        echo json_encode(['success' => true]);
        break;

    case 'complete_order':
        $orderId = $_POST['order_id'] ?? 0;

        // 1. Mark order as completed & PAID (Cash-Only Optimization)
        $stmt = $pdo->prepare("UPDATE orders SET status = 'completed', completed_at = NOW(), payment_status = 'paid', payment_method = 'Cash' WHERE id = ?");
        $stmt->execute([$orderId]);

        // 2. THIS IS THE "COMPLETE & CLEAR" ACTION
        // Free the table, clear the waiter, clear the current order
        $stmt = $pdo->prepare("SELECT table_id FROM orders WHERE id = ?");
        $stmt->execute([$orderId]);
        $order = $stmt->fetch();

        if ($order && $order['table_id']) {
            $pdo->prepare("UPDATE restaurant_tables SET status = 'free', current_order_id = NULL, occupied_since = NULL, waiter_id = NULL WHERE id = ?")->execute([$order['table_id']]);

            // Broadcast to update UI color to Green (Free)
            broadcastWS('refresh_tables');
        }

        // Deduct stock
        deductStockForOrder($pdo, $orderId);

        echo json_encode(['success' => true]);
        break;

    case 'get_held_orders':
        $stmt = $pdo->query("SELECT o.*, 
            GROUP_CONCAT(CONCAT(oi.quantity, 'x ', oi.product_name) SEPARATOR ', ') as items_summary,
            TIMESTAMPDIFF(MINUTE, o.created_at, NOW()) as minutes_ago
            FROM orders o 
            LEFT JOIN order_items oi ON o.id = oi.order_id 
            WHERE o.status = 'held' 
            GROUP BY o.id 
            ORDER BY o.created_at DESC");
        echo json_encode(['success' => true, 'data' => $stmt->fetchAll()]);
        break;

    case 'retrieve_order':
        $id = $_POST['id'] ?? 0;
        $stmt = $pdo->prepare("SELECT * FROM orders WHERE id = ?");
        $stmt->execute([$id]);
        $order = $stmt->fetch();
        if ($order) {
            $stmt = $pdo->prepare("SELECT * FROM order_items WHERE order_id = ?");
            $stmt->execute([$id]);
            $order['items'] = $stmt->fetchAll();
        }
        echo json_encode(['success' => true, 'data' => $order]);
        break;

    case 'get_order':
        $id = $_GET['id'] ?? 0;
        $stmt = $pdo->prepare("SELECT * FROM orders WHERE id = ?");
        $stmt->execute([$id]);
        $order = $stmt->fetch();
        if ($order) {
            $stmt = $pdo->prepare("SELECT * FROM order_items WHERE order_id = ?");
            $stmt->execute([$id]);
            $order['items'] = $stmt->fetchAll();
        }
        echo json_encode(['success' => true, 'data' => $order]);
        break;

    case 'get_orders':
        $status = $_GET['status'] ?? 'completed';
        $date = $_GET['date'] ?? '';
        $search = $_GET['search'] ?? '';
        $orderType = $_GET['order_type'] ?? '';
        $page = max(1, intval($_GET['page'] ?? 1));
        $limit = max(1, intval($_GET['limit'] ?? 5));
        $offset = ($page - 1) * $limit;

        if ($status === 'deleted_all') {
            $where = "status IN ('deleted', 'void_waste', 'void_return')";
            $params = [];
        } else {
            $where = "status = ?";
            $params = [$status];
        }

        if ($date) {
            $where .= " AND DATE(created_at) = ?";
            $params[] = $date;
        }
        if ($search) {
            $where .= " AND (customer_name LIKE ? OR order_number LIKE ?)";
            $params[] = "%$search%";
            $params[] = "%$search%";
        }
        if ($orderType) {
            $where .= " AND order_type = ?";
            $params[] = $orderType;
        }

        // Count total records
        $countSql = "SELECT COUNT(*) FROM orders WHERE $where";
        $countStmt = $pdo->prepare($countSql);
        $countStmt->execute($params);
        $totalRecords = $countStmt->fetchColumn();
        $totalPages = ceil($totalRecords / $limit);

        // Fetch paginated data
        $sql = "SELECT * FROM orders WHERE $where ORDER BY created_at DESC LIMIT $limit OFFSET $offset";
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);

        echo json_encode([
            'success' => true,
            'data' => $stmt->fetchAll(),
            'pagination' => [
                'current_page' => $page,
                'total_pages' => (int)$totalPages,
                'total_records' => (int)$totalRecords,
                'limit' => $limit
            ]
        ]);
        break;

    case 'void_order':
        $id = $_POST['id'] ?? 0;
        $voidType = $_POST['void_type'] ?? 'waste';
        $reason = $_POST['reason'] ?? '';
        $deletedBy = $_POST['deleted_by'] ?? 'Admin';

        // If return, restore stock
        if ($voidType === 'return') {
            restoreStockForOrder($pdo, $id);
        }

        $stmt = $pdo->prepare("UPDATE orders SET status = 'deleted', void_type = ?, delete_reason = ?, deleted_by = ? WHERE id = ?");
        $stmt->execute([$voidType, $reason, $deletedBy, $id]);

        // Clear table if linked
        $stmt = $pdo->prepare("SELECT table_id FROM orders WHERE id = ?");
        $stmt->execute([$id]);
        $order = $stmt->fetch();
        if ($order && $order['table_id']) {
            $pdo->prepare("UPDATE restaurant_tables SET status = 'free', current_order_id = NULL WHERE id = ?")->execute([$order['table_id']]);
        }

        echo json_encode(['success' => true]);
        break;

    case 'delete_order':
        $id = $_POST['id'] ?? 0;
        $reason = $_POST['reason'] ?? 'Manual Delete';
        $deletedBy = $_SESSION['username'] ?? 'Admin'; // Capture who deleted it

        try {
            $pdo->beginTransaction();

            // 1. Restore stock safely (Check if function exists first)
            if (function_exists('restoreStockForOrder')) {
                restoreStockForOrder($pdo, $id);
            }

            // 2. Update Order Status to 'deleted'
            $stmt = $pdo->prepare("UPDATE orders SET status = 'deleted', delete_reason = ?, deleted_by = ? WHERE id = ?");
            $stmt->execute([$reason, $deletedBy, $id]);

            // 3. Free the table if it was occupied by this order
            $stmtTable = $pdo->prepare("SELECT table_id FROM orders WHERE id = ?");
            $stmtTable->execute([$id]);
            $orderRow = $stmtTable->fetch();

            if ($orderRow && $orderRow['table_id']) {
                $pdo->prepare("UPDATE restaurant_tables SET status = 'free', current_order_id = NULL, waiter_id = NULL, occupied_since = NULL WHERE id = ?")
                    ->execute([$orderRow['table_id']]);
            }

            $pdo->commit();
            echo json_encode(['success' => true]);
        } catch (Exception $e) {
            $pdo->rollBack();
            echo json_encode(['success' => false, 'message' => 'Delete failed: ' . $e->getMessage()]);
        }
        break;

    case 'restore_order':
        $id = $_POST['id'] ?? 0;
        $stmt = $pdo->prepare("UPDATE orders SET status = 'completed', delete_reason = NULL, deleted_by = NULL, void_type = NULL WHERE id = ?");
        $stmt->execute([$id]);
        echo json_encode(['success' => true]);
        break;

    case 'return_order_items':
        require_once 'controllers/OrderController.php';
        $controller = new OrderController($pdo);
        $controller->returnOrderItems();
        break;

    // ============ KOT (Kitchen Order Ticket) ============
    case 'get_pending_kot':
        // Ensuring this query does not cause errors and pulls active orders
        $stmt = $pdo->query("SELECT oi.*, o.order_number, o.token_number, o.customer_name, o.table_id, t.name as table_name,
                             TIMESTAMPDIFF(MINUTE, o.created_at, NOW()) as minutes_ago
                             FROM order_items oi
                             JOIN orders o ON oi.order_id = o.id
                             LEFT JOIN restaurant_tables t ON o.table_id = t.id
                             WHERE oi.is_kot_printed = 0 
                             AND o.status IN ('pending', 'completed')
                             AND o.status != 'deleted'
                             ORDER BY o.created_at ASC");
        echo json_encode(['success' => true, 'data' => $stmt->fetchAll()]);
        break;

    case 'mark_kot_printed':
        $itemIds = json_decode($_POST['item_ids'] ?? '[]', true);
        if (!empty($itemIds)) {
            $placeholders = implode(',', array_fill(0, count($itemIds), '?'));
            $stmt = $pdo->prepare("UPDATE order_items SET is_kot_printed = 1, kot_time = NOW() WHERE id IN ($placeholders)");
            $stmt->execute($itemIds);
        }
        echo json_encode(['success' => true]);
        break;

    case 'mark_bill_printed':
        $orderId = $_POST['order_id'] ?? 0;
        $stmt = $pdo->prepare("UPDATE orders SET is_bill_printed = 1 WHERE id = ?");
        $stmt->execute([$orderId]);
        echo json_encode(['success' => true]);
        break;

    // ============ SUPPLIERS ============
    case 'get_suppliers':
        $page = max(1, intval($_GET['page'] ?? 1));
        $limit = max(1, intval($_GET['limit'] ?? 5));
        $offset = ($page - 1) * $limit;

        $totalRecords = $pdo->query("SELECT COUNT(*) FROM suppliers")->fetchColumn();
        $totalPages = ceil($totalRecords / $limit);

        $stmt = $pdo->prepare("SELECT * FROM suppliers ORDER BY name LIMIT ? OFFSET ?");
        $stmt->bindValue(1, $limit, PDO::PARAM_INT);
        $stmt->bindValue(2, $offset, PDO::PARAM_INT);
        $stmt->execute();

        echo json_encode([
            'success' => true,
            'data' => $stmt->fetchAll(),
            'pagination' => [
                'current_page' => $page,
                'total_pages' => (int)$totalPages,
                'total_records' => (int)$totalRecords,
                'limit' => $limit
            ]
        ]);
        break;

    case 'add_supplier':
        $name = $_POST['name'] ?? '';
        $contact = $_POST['contact'] ?? '';
        $email = $_POST['email'] ?? '';
        $address = $_POST['address'] ?? '';
        $stmt = $pdo->prepare("INSERT INTO suppliers (name, contact, email, address) VALUES (?, ?, ?, ?)");
        $stmt->execute([$name, $contact, $email, $address]);
        echo json_encode(['success' => true, 'id' => $pdo->lastInsertId()]);
        break;

    case 'update_supplier':
        $id = $_POST['id'] ?? 0;
        $name = $_POST['name'] ?? '';
        $contact = $_POST['contact'] ?? '';
        $email = $_POST['email'] ?? '';
        $address = $_POST['address'] ?? '';
        $stmt = $pdo->prepare("UPDATE suppliers SET name = ?, contact = ?, email = ?, address = ? WHERE id = ?");
        $stmt->execute([$name, $contact, $email, $address, $id]);
        echo json_encode(['success' => true]);
        break;

    case 'delete_supplier':
        $id = $_POST['id'] ?? 0;
        // Check if has inventory items
        $stmt = $pdo->prepare("SELECT COUNT(*) FROM inventory WHERE supplier_id = ?");
        $stmt->execute([$id]);
        if ($stmt->fetchColumn() > 0) {
            echo json_encode(['success' => false, 'message' => 'Supplier has inventory items. Remove them first.']);
        } else {
            $stmt = $pdo->prepare("DELETE FROM suppliers WHERE id = ?");
            $stmt->execute([$id]);
            echo json_encode(['success' => true]);
        }
        break;

    // ============ INVENTORY ============
    case 'get_inventory':
        $page = max(1, intval($_GET['page'] ?? 1));
        $limit = max(1, intval($_GET['limit'] ?? 5));
        $offset = ($page - 1) * $limit;

        // Count total records
        $totalRecords = $pdo->query("SELECT COUNT(*) FROM inventory")->fetchColumn();
        $totalPages = ceil($totalRecords / $limit);

        $stmt = $pdo->prepare("SELECT i.*, s.name as supplier_name,
            CASE 
                WHEN i.quantity <= 0 THEN 'out'
                WHEN i.quantity <= i.min_quantity THEN 'low'
                WHEN i.quantity <= i.min_quantity * 2 THEN 'medium'
                ELSE 'ok'
            END as stock_status
            FROM inventory i 
            LEFT JOIN suppliers s ON i.supplier_id = s.id 
            ORDER BY i.name LIMIT ? OFFSET ?");
        $stmt->bindValue(1, $limit, PDO::PARAM_INT);
        $stmt->bindValue(2, $offset, PDO::PARAM_INT);
        $stmt->execute();

        echo json_encode([
            'success' => true,
            'data' => $stmt->fetchAll(),
            'pagination' => [
                'current_page' => $page,
                'total_pages' => (int)$totalPages,
                'total_records' => (int)$totalRecords,
                'limit' => $limit
            ]
        ]);
        break;

    case 'add_inventory_item':
        $name = $_POST['name'] ?? '';
        $sku = $_POST['sku'] ?? '';
        $purchaseUnit = $_POST['purchase_unit'] ?? 'Pcs';
        $consumptionUnit = $_POST['consumption_unit'] ?? 'Pcs';
        $conversionFactor = $_POST['conversion_factor'] ?? 1;
        $quantity = $_POST['quantity'] ?? 0;
        $minQuantity = $_POST['min_quantity'] ?? 5;
        $costPerUnit = $_POST['cost_per_unit'] ?? 0;
        $supplierId = $_POST['supplier_id'] ?: null;

        $stmt = $pdo->prepare("INSERT INTO inventory (name, sku, purchase_unit, consumption_unit, conversion_factor, quantity, min_quantity, cost_per_unit, supplier_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->execute([$name, $sku, $purchaseUnit, $consumptionUnit, $conversionFactor, $quantity, $minQuantity, $costPerUnit, $supplierId]);
        echo json_encode(['success' => true, 'id' => $pdo->lastInsertId()]);
        break;

    case 'update_inventory_item':
        $id = $_POST['id'] ?? 0;
        $name = $_POST['name'] ?? '';
        $sku = $_POST['sku'] ?? '';
        $minQuantity = $_POST['min_quantity'] ?? 5;
        $costPerUnit = $_POST['cost_per_unit'] ?? 0;
        $supplierId = $_POST['supplier_id'] ?: null;
        $stmt = $pdo->prepare("UPDATE inventory SET name = ?, sku = ?, min_quantity = ?, cost_per_unit = ?, supplier_id = ? WHERE id = ?");
        $stmt->execute([$name, $sku, $minQuantity, $costPerUnit, $supplierId, $id]);
        echo json_encode(['success' => true]);
        break;

    case 'delete_inventory_item':
        $id = $_POST['id'] ?? 0;
        // Check if used in recipes
        $stmt = $pdo->prepare("SELECT COUNT(*) FROM recipes WHERE inventory_id = ?");
        $stmt->execute([$id]);
        if ($stmt->fetchColumn() > 0) {
            echo json_encode(['success' => false, 'message' => 'Item is used in recipes. Remove from recipes first.']);
        } else {
            $stmt = $pdo->prepare("DELETE FROM inventory WHERE id = ?");
            $stmt->execute([$id]);
            echo json_encode(['success' => true]);
        }
        break;

    case 'add_stock':
        $id = $_POST['id'] ?? 0;
        $quantity = floatval($_POST['quantity'] ?? 0);
        $notes = $_POST['notes'] ?? 'Stock In';

        try {
            $pdo->beginTransaction();

            // 1. Atomic Update (Prevent Race Condition)
            $stmt = $pdo->prepare("UPDATE inventory SET quantity = quantity + ? WHERE id = ?");
            $stmt->execute([$quantity, $id]);

            // 2. Fetch new balance correctly *after* update
            $stmt = $pdo->prepare("SELECT quantity FROM inventory WHERE id = ?");
            $stmt->execute([$id]);
            $newBalance = $stmt->fetchColumn();

            // 3. Log the change
            $stmt = $pdo->prepare("INSERT INTO stock_logs (inventory_id, qty_change, balance_after, reason, notes) VALUES (?, ?, ?, 'restock', ?)");
            $stmt->execute([$id, $quantity, $newBalance, $notes]);

            $pdo->commit();
            echo json_encode(['success' => true]);
        } catch (Exception $e) {
            $pdo->rollBack();
            echo json_encode(['success' => false, 'message' => 'Transaction failed: ' . $e->getMessage()]);
        }
        break;

    case 'adjust_stock':
        $id = $_POST['id'] ?? 0;
        $newQuantity = $_POST['quantity'] ?? 0;
        $reason = $_POST['reason'] ?? 'adjustment';
        $notes = $_POST['notes'] ?? '';

        $stmt = $pdo->prepare("SELECT quantity FROM inventory WHERE id = ?");
        $stmt->execute([$id]);
        $current = $stmt->fetch();
        $change = floatval($newQuantity) - floatval($current['quantity']);

        $stmt = $pdo->prepare("UPDATE inventory SET quantity = ? WHERE id = ?");
        $stmt->execute([$newQuantity, $id]);

        $stmt = $pdo->prepare("INSERT INTO stock_logs (inventory_id, qty_change, balance_after, reason, notes) VALUES (?, ?, ?, ?, ?)");
        $stmt->execute([$id, $change, $newQuantity, $reason, $notes]);

        echo json_encode(['success' => true]);
        break;

    case 'get_stock_logs':
        $inventoryId = $_GET['inventory_id'] ?? null;
        $sql = "SELECT l.*, i.name as item_name FROM stock_logs l JOIN inventory i ON l.inventory_id = i.id";
        if ($inventoryId) $sql .= " WHERE l.inventory_id = ?";
        $sql .= " ORDER BY l.created_at DESC LIMIT 100";
        $stmt = $pdo->prepare($sql);
        $stmt->execute($inventoryId ? [$inventoryId] : []);
        echo json_encode(['success' => true, 'data' => $stmt->fetchAll()]);
        break;

    // ============ EXPENSES ============
    case 'get_expenses':
        $page = max(1, intval($_GET['page'] ?? 1));
        $limit = max(1, intval($_GET['limit'] ?? 5));
        $offset = ($page - 1) * $limit;

        // Count total records
        $totalRecords = $pdo->query("SELECT COUNT(*) FROM expenses")->fetchColumn();
        $totalPages = ceil($totalRecords / $limit);

        $stmt = $pdo->prepare("SELECT * FROM expenses ORDER BY created_at DESC LIMIT ? OFFSET ?");
        $stmt->bindValue(1, $limit, PDO::PARAM_INT);
        $stmt->bindValue(2, $offset, PDO::PARAM_INT);
        $stmt->execute();

        echo json_encode([
            'success' => true,
            'data' => $stmt->fetchAll(),
            'pagination' => [
                'current_page' => $page,
                'total_pages' => (int)$totalPages,
                'total_records' => (int)$totalRecords,
                'limit' => $limit
            ]
        ]);
        break;

    case 'add_expense':
        $description = $_POST['description'] ?? '';
        $category = $_POST['category'] ?? 'Other';
        $amount = $_POST['amount'] ?? 0;

        // Auto-link to active shift if exists
        $stmtShift = $pdo->query("SELECT id FROM shifts WHERE status = 'open' LIMIT 1");
        $activeShiftId = $stmtShift->fetchColumn();

        $stmt = $pdo->prepare("INSERT INTO expenses (description, category, amount, shift_id) VALUES (?, ?, ?, ?)");
        $stmt->execute([$description, $category, $amount, $activeShiftId ?: null]);
        echo json_encode(['success' => true, 'id' => $pdo->lastInsertId()]);
        break;

    case 'update_expense':
        $id = $_POST['id'] ?? 0;
        $description = $_POST['description'] ?? '';
        $category = $_POST['category'] ?? '';
        $amount = $_POST['amount'] ?? 0;
        $stmt = $pdo->prepare("UPDATE expenses SET description = ?, category = ?, amount = ? WHERE id = ?");
        $stmt->execute([$description, $category, $amount, $id]);
        echo json_encode(['success' => true]);
        break;

    case 'delete_expense':
        $id = $_POST['id'] ?? 0;
        $stmt = $pdo->prepare("DELETE FROM expenses WHERE id = ?");
        $stmt->execute([$id]);
        echo json_encode(['success' => true]);
        break;

    // ============ STAFF ============
    case 'get_staff':
        $page = max(1, intval($_GET['page'] ?? 1));
        $limit = max(1, intval($_GET['limit'] ?? 5));
        $offset = ($page - 1) * $limit;

        $totalRecords = $pdo->query("SELECT COUNT(*) FROM staff")->fetchColumn();
        $totalPages = ceil($totalRecords / $limit);

        $stmt = $pdo->prepare("SELECT * FROM staff ORDER BY name LIMIT ? OFFSET ?");
        $stmt->bindValue(1, $limit, PDO::PARAM_INT);
        $stmt->bindValue(2, $offset, PDO::PARAM_INT);
        $stmt->execute();

        echo json_encode([
            'success' => true,
            'data' => $stmt->fetchAll(),
            'pagination' => [
                'current_page' => $page,
                'total_pages' => (int)$totalPages,
                'total_records' => (int)$totalRecords,
                'limit' => $limit
            ]
        ]);
        break;

    case 'add_staff':
        $name = $_POST['name'] ?? '';
        $role = $_POST['role'] ?? 'waiter';
        $pin = $_POST['pin'] ?? null;
        $stmt = $pdo->prepare("INSERT INTO staff (name, role, pin) VALUES (?, ?, ?)");
        $stmt->execute([$name, $role, $pin]);
        echo json_encode(['success' => true, 'id' => $pdo->lastInsertId()]);
        break;

    case 'update_staff':
        $id = $_POST['id'] ?? 0;
        $name = $_POST['name'] ?? '';
        $role = $_POST['role'] ?? '';
        $stmt = $pdo->prepare("UPDATE staff SET name = ?, role = ? WHERE id = ?");
        $stmt->execute([$name, $role, $id]);
        echo json_encode(['success' => true]);
        break;

    case 'delete_staff':
        $id = $_POST['id'] ?? 0;
        $stmt = $pdo->prepare("DELETE FROM staff WHERE id = ?");
        $stmt->execute([$id]);
        echo json_encode(['success' => true]);
        break;

    // ============ SALES REPORTS / EXPORT DATA ============
    case 'get_export_data':
        $page = max(1, intval($_GET['page'] ?? 1));
        $limit = max(1, intval($_GET['limit'] ?? 20));
        $offset = ($page - 1) * $limit;
        $search = $_GET['search'] ?? '';
        $startDate = $_GET['start_date'] ?? '';
        $endDate = $_GET['end_date'] ?? '';

        // Build WHERE clause
        $where = ["status != 'pending'"]; // Exclude draft/pending orders
        $params = [];

        if ($search) {
            $where[] = "(order_number LIKE ? OR customer_name LIKE ?)";
            $params[] = "%$search%";
            $params[] = "%$search%";
        }

        if ($startDate) {
            $where[] = "DATE(created_at) >= ?";
            $params[] = $startDate;
        }

        if ($endDate) {
            $where[] = "DATE(created_at) <= ?";
            $params[] = $endDate;
        }

        // Status filter
        $status = $_GET['status'] ?? '';
        if ($status) {
            $where[] = "status = ?";
            $params[] = $status;
        }

        // Order type filter
        $orderType = $_GET['order_type'] ?? '';
        if ($orderType) {
            $where[] = "order_type = ?";
            $params[] = $orderType;
        }

        $whereClause = implode(' AND ', $where);

        // Count total records
        $countStmt = $pdo->prepare("SELECT COUNT(*) FROM orders WHERE $whereClause");
        $countStmt->execute($params);
        $totalRecords = $countStmt->fetchColumn();
        $totalPages = ceil($totalRecords / $limit);

        // Fetch paginated data
        $sql = "SELECT id, order_number, customer_name, order_type, subtotal, tax, total, 
                       status, created_at, completed_at 
                FROM orders 
                WHERE $whereClause 
                ORDER BY created_at DESC 
                LIMIT $limit OFFSET $offset";

        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);

        $data = $stmt->fetchAll();

        echo json_encode([
            'success' => true,
            'data' => $data,
            'pagination' => [
                'current_page' => $page,
                'total_pages' => (int)$totalPages,
                'total_records' => (int)$totalRecords,
                'from' => $offset + 1,
                'to' => min($offset + $limit, $totalRecords),
                'total' => (int)$totalRecords
            ]
        ]);
        break;

    case 'toggle_shift':
        $id = $_POST['id'] ?? 0;
        $action = $_POST['shift_action'] ?? 'start';
        if ($action === 'start') {
            $stmt = $pdo->prepare("UPDATE staff SET is_active = 1, shift_start = NOW() WHERE id = ?");
        } else {
            $stmt = $pdo->prepare("UPDATE staff SET is_active = 0, shift_start = NULL WHERE id = ?");
        }
        $stmt->execute([$id]);
        echo json_encode(['success' => true]);
        break;

    case 'export_sales':
        $startDate = $_GET['start'] ?? date('Y-m-d');
        $endDate = $_GET['end'] ?? date('Y-m-d');
        $format = $_GET['format'] ?? 'csv';
        $today = date('Y-m-d');

        // 1. Check for Active Shift
        $stmtShift = $pdo->query("SELECT id FROM shifts WHERE status = 'open' LIMIT 1");
        $activeShiftId = $stmtShift->fetchColumn();

        $isViewingToday = ($startDate === $today && $endDate === $today);
        $where = "status = 'completed'";
        $params = [];

        if ($isViewingToday && $activeShiftId) {
            // STRICT SHIFT MODE
            $where .= " AND shift_id = ?";
            $params[] = $activeShiftId;
        } else {
            // DATE RANGE MODE
            $where .= " AND DATE(created_at) BETWEEN ? AND ?";
            $params[] = $startDate;
            $params[] = $endDate;
        }

        // Fetch Data
        $stmt = $pdo->prepare("SELECT order_number, created_at, customer_name, payment_method, total, status FROM orders WHERE $where ORDER BY created_at DESC");
        $stmt->execute($params);
        $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if ($format === 'json') {
            echo json_encode(['success' => true, 'data' => $orders]);
            break;
        }

        // CSV Export
        header('Content-Type: text/csv');
        header('Content-Disposition: attachment; filename="sales_report_' . date('Ymd') . '.csv"');
        $output = fopen('php://output', 'w');
        fputcsv($output, ['Order #', 'Date', 'Customer', 'Payment', 'Total', 'Status']);
        foreach ($orders as $row) {
            fputcsv($output, $row);
        }
        fclose($output);
        break;

    // ============ DASHBOARD ============
    case 'get_dashboard':
        $stmt = $pdo->prepare("SELECT setting_value FROM settings WHERE setting_key = 'business_day_start'");
        $stmt->execute();
        $cutoff = (int)($stmt->fetchColumn() ?: 6);
        $currentHour = (int)date('H');
        if ($currentHour < $cutoff) $start = date('Y-m-d H:i:s', strtotime("yesterday $cutoff:00:00"));
        else $start = date('Y-m-d H:i:s', strtotime("today $cutoff:00:00"));

        $stmt = $pdo->prepare("SELECT COALESCE(SUM(total), 0) as sales, COUNT(*) as count FROM orders WHERE status = 'completed' AND created_at >= ?");
        $stmt->execute([$start]);
        $res = $stmt->fetch();

        echo json_encode([
            'success' => true,
            'data' => [
                'total_sales' => (float)$res['sales'],
                'order_count' => (int)$res['count'],
                'cogs' => 0,
                'net_profit' => 0
            ]
        ]);
        break;

    // ============ PRINT DATA ============
    case 'get_receipt_data':
        $orderId = $_GET['order_id'] ?? 0;

        // Get order
        $stmt = $pdo->prepare("SELECT o.*, t.name as table_name FROM orders o LEFT JOIN restaurant_tables t ON o.table_id = t.id WHERE o.id = ?");
        $stmt->execute([$orderId]);
        $order = $stmt->fetch();

        if (!$order) {
            echo json_encode(['success' => false, 'message' => 'Order not found']);
            break;
        }

        // Get items
        $stmt = $pdo->prepare("SELECT * FROM order_items WHERE order_id = ?");
        $stmt->execute([$orderId]);
        $order['items'] = $stmt->fetchAll();

        // Cash Only Optimization: No need to query payments table
        $order['payments'] = []; // Force empty to skip logic in frontend, though printer.js is now hardcoded for cash.

        // Get settings
        $stmt = $pdo->query("SELECT setting_key, setting_value FROM settings");
        $settings = [];
        foreach ($stmt->fetchAll() as $row) {
            $settings[$row['setting_key']] = $row['setting_value'];
        }

        echo json_encode(['success' => true, 'order' => $order, 'settings' => $settings]);
        break;

    case 'get_kot_data':
        $itemIds = $_GET['item_ids'] ?? '';
        $ids = array_filter(explode(',', $itemIds));
        if (empty($ids)) {
            echo json_encode(['success' => false, 'message' => 'No items']);
            break;
        }

        $placeholders = implode(',', array_fill(0, count($ids), '?'));
        // 1. Get pending KOT items
        $stmt = $pdo->prepare("
            SELECT oi.*, o.order_number, o.token_number, o.table_id, t.name as table_name,
                   o.created_at as order_time, p.name as product_name
            FROM order_items oi
            JOIN orders o ON oi.order_id = o.id
            LEFT JOIN products p ON oi.product_id = p.id
            LEFT JOIN restaurant_tables t ON o.table_id = t.id
            WHERE oi.id IN ($placeholders)");
        $stmt->execute($ids);

        $items = $stmt->fetchAll();
        $orderInfo = $items ? ['order_number' => $items[0]['order_number'], 'table_name' => $items[0]['table_name'], 'customer_name' => $items[0]['customer_name']] : null;

        echo json_encode(['success' => true, 'items' => $items, 'order' => $orderInfo]);
        break;



    // ============ MODULAR REPORTS & ANALYTICS ============
    case 'get_dashboard_stats':
        // 1. Timezone Check (Just to be safe)
        date_default_timezone_set('Asia/Karachi');

        // 2. Fetch "Day Start Time" from Database (Client setting)
        // Default to 06 (6 AM) if not set
        $stmt = $pdo->prepare("SELECT setting_value FROM settings WHERE setting_key = 'business_day_start'");
        $stmt->execute();
        $settingVal = $stmt->fetchColumn();
        $cutoff = ($settingVal !== false) ? (int)$settingVal : 6;

        // 3. Logic: Which day to consider?
        $currentHour = (int)date('H'); // Current hour (0-23)
        $todayDate = date('Y-m-d');

        if ($currentHour < $cutoff) {
            // SCENARIO: It's late night (e.g., 3 AM) but shop opens at 6 AM.
            // This sale belongs to the "Previous Day" shift.
            $businessDate = date('Y-m-d', strtotime('-1 day'));
        } else {
            // SCENARIO: It's regular hours (after cutoff).
            // This is "Today's" sale.
            $businessDate = date('Y-m-d');
        }

        // 4. Create Start and End Timestamps
        // Start: Business Date + Cutoff Hour
        $start_full = $businessDate . " " . str_pad($cutoff, 2, '0', STR_PAD_LEFT) . ":00:00";

        // End: Start Time + 24 Hours (Covers full shift into next morning)
        $end_full = date('Y-m-d H:i:s', strtotime("$start_full +24 hours"));

        // Helper: Calculate previous period (Yesterday same time range)
        $prev_start = date('Y-m-d H:i:s', strtotime("$start_full -24 hours"));
        $prev_end   = date('Y-m-d H:i:s', strtotime("$end_full -24 hours"));

        // Helper Function to get stats for a range
        function getBusinessDayStats($pdo, $start, $end)
        {
            // Sales & Orders
            $stmt = $pdo->prepare("SELECT COALESCE(SUM(total), 0) as total, COUNT(*) as count 
                                   FROM orders 
                                   WHERE status = 'completed' 
                                   AND created_at >= ? AND created_at < ?");
            $stmt->execute([$start, $end]);
            $res = $stmt->fetch();
            $sales = floatval($res['total']);
            $count = intval($res['count']);

            // Expenses
            $stmt = $pdo->prepare("SELECT COALESCE(SUM(amount), 0) FROM expenses WHERE created_at >= ? AND created_at < ?");
            $stmt->execute([$start, $end]);
            $expenses = floatval($stmt->fetchColumn());

            // COGS
            $stmt = $pdo->prepare("SELECT COALESCE(SUM(r.qty_required * i.cost_per_unit * oi.quantity), 0) as cogs
                                   FROM order_items oi
                                   JOIN orders o ON oi.order_id = o.id
                                   JOIN recipes r ON oi.product_id = r.product_id
                                   JOIN inventory i ON r.inventory_id = i.id
                                   WHERE o.status = 'completed' AND o.created_at >= ? AND o.created_at < ?");
            $stmt->execute([$start, $end]);
            $cogs = floatval($stmt->fetchColumn());

            return [
                'sales' => $sales,
                'count' => $count,
                'expenses' => $expenses,
                'cogs' => $cogs,
                'net_profit' => $sales - $expenses - $cogs
            ];
        }

        // 5. Get Current & Previous Stats
        $current = getBusinessDayStats($pdo, $start_full, $end_full);
        $previous = getBusinessDayStats($pdo, $prev_start, $prev_end);

        // 6. Calculate Percentages
        $calcPct = function ($curr, $prev) {
            if ($prev == 0) return $curr > 0 ? 100 : 0;
            return round((($curr - $prev) / $prev) * 100, 1);
        };

        $pct_sales = $calcPct($current['sales'], $previous['sales']);
        $pct_orders = $calcPct($current['count'], $previous['count']);
        $pct_profit = $calcPct($current['net_profit'], $previous['net_profit']);

        // 7. Recent Orders & Other Stats (Keep existing logic)
        $stmt = $pdo->query("SELECT order_number, total, created_at, status FROM orders ORDER BY id DESC LIMIT 5");
        $recent = $stmt->fetchAll();

        $stmt = $pdo->prepare("SELECT oi.product_name, SUM(oi.quantity) as total_sold 
                               FROM order_items oi 
                               JOIN orders o ON oi.order_id = o.id 
                               WHERE o.status = 'completed' AND o.created_at >= ? AND o.created_at < ? 
                               GROUP BY oi.product_id 
                               ORDER BY total_sold DESC LIMIT 5");
        $stmt->execute([$start_full, $end_full]);
        $bestItems = $stmt->fetchAll();

        $stmt = $pdo->query("SELECT name, quantity, min_quantity, consumption_unit as unit FROM inventory WHERE quantity <= min_quantity ORDER BY quantity ASC LIMIT 5");
        $lowStock = $stmt->fetchAll();

        // Sales per Shift history (Standard chart)
        $stmt = $pdo->query("
            SELECT s.id, DATE(s.start_time) as date, 
            COALESCE(SUM(o.total), 0) as total 
            FROM shifts s
            LEFT JOIN orders o ON s.id = o.shift_id AND o.status = 'completed'
            WHERE s.status = 'closed' 
            GROUP BY s.id
            ORDER BY s.id DESC 
            LIMIT 7
        ");
        $shiftSales = array_reverse($stmt->fetchAll());

        echo json_encode([
            'success' => true,
            'stats' => [
                'total_sales' => $current['sales'],
                'order_count' => $current['count'],
                'expenses' => $current['expenses'],
                'cogs' => $current['cogs'],
                'net_profit' => $current['net_profit'],
                'growth' => [
                    'sales' => $pct_sales,
                    'orders' => $pct_orders,
                    'profit' => $pct_profit
                ],
                'meta' => [
                    'range_start' => $start_full,
                    'range_end' => $end_full,
                    'prev_start' => $prev_start,
                    'prev_end' => $prev_end,
                    'cutoff' => $cutoff
                ]
            ],
            'chart' => $shiftSales,
            'recent' => $recent,
            'best_items' => $bestItems,
            'low_stock' => $lowStock
        ]);
        exit;


    case 'get_zreport_history':
        $date = $_GET['date'] ?? '';
        $page = max(1, intval($_GET['page'] ?? 1));
        $limit = max(1, intval($_GET['limit'] ?? 5));
        $offset = ($page - 1) * $limit;

        // Use shift_closings for history (immutability)
        // If we want to link to shift_id, we might need to join shifts, but shift_closings has shift_start/end

        $where = "1=1";
        $params = [];
        if ($date) {
            $where .= " AND DATE(shift_start) = ?";
            $params[] = $date;
        }

        // Count total
        $countStmt = $pdo->prepare("SELECT COUNT(*) FROM shift_closings WHERE $where");
        $countStmt->execute($params);
        $totalRecords = $countStmt->fetchColumn();
        $totalPages = ceil($totalRecords / $limit);

        // Fetch History with full details
        $sql = "SELECT * FROM shift_closings WHERE $where ORDER BY shift_end DESC LIMIT $limit OFFSET $offset";
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);

        echo json_encode([
            'success' => true,
            'data' => $stmt->fetchAll(),
            'pagination' => [
                'current_page' => $page,
                'total_pages' => (int)$totalPages,
                'total_records' => (int)$totalRecords,
                'limit' => $limit
            ]
        ]);
        exit;

    case 'get_zreport':
        $id = $_GET['id'] ?? 0;
        $stmt = $pdo->prepare("SELECT * FROM shifts WHERE id = ?");
        $stmt->execute([$id]);
        echo json_encode(['success' => true, 'data' => $stmt->fetch()]);
        exit;


    case 'get_sales_summary':
        $shiftId = $_GET['shift_id'] ?? 0;

        // Detailed itemized sales summary
        $stmt = $pdo->prepare("SELECT oi.product_name, SUM(oi.quantity) as total_sold, SUM(oi.quantity * oi.price) as total_revenue
                               FROM order_items oi 
                               JOIN orders o ON oi.order_id = o.id 
                               WHERE o.shift_id = ? AND o.status = 'completed' 
                               GROUP BY oi.product_id 
                               ORDER BY total_sold DESC");
        $stmt->execute([$shiftId]);
        $items = $stmt->fetchAll();

        // Total sales for the period
        $stmt = $pdo->prepare("SELECT SUM(total) as revenue, COUNT(*) as count 
                               FROM orders 
                               WHERE shift_id = ? AND status = 'completed'");
        $stmt->execute([$shiftId]);
        $totals = $stmt->fetch();

        echo json_encode([
            'success' => true,
            'items' => $items,
            'totals' => [
                'revenue' => floatval($totals['revenue'] ?? 0),
                'order_count' => intval($totals['count'] ?? 0),
                'shift_id' => $shiftId
            ]
        ]);
        exit;

    case 'export_sales_csv':
        $start = $_GET['start_date'] ?? date('Y-m-d');
        $end = $_GET['end_date'] ?? date('Y-m-d');
        $stmt = $pdo->prepare("SELECT * FROM orders WHERE DATE(created_at) BETWEEN ? AND ? ORDER BY created_at DESC");
        $stmt->execute([$start, $end]);
        $orders = $stmt->fetchAll();

        header('Content-Type: text/csv');
        header('Content-Disposition: attachment; filename=sales_report_' . $start . '_to_' . $end . '.csv');
        $out = fopen('php://output', 'w');
        fputcsv($out, ['Order #', 'Date', 'Customer', 'Type', 'Subtotal', 'Tax', 'Total', 'Status']);
        foreach ($orders as $o) {
            fputcsv($out, [$o['order_number'], $o['created_at'], $o['customer_name'], $o['order_type'], $o['subtotal'], $o['tax'], $o['total'], $o['status']]);
        }
        fclose($out);
    case 'export_inventory':
        $stmt = $pdo->query("SELECT i.name, i.sku, i.quantity, i.consumption_unit, i.min_quantity, s.name as supplier FROM inventory i LEFT JOIN suppliers s ON i.supplier_id = s.id ORDER BY i.name");
        $items = $stmt->fetchAll();

        header('Content-Type: text/csv');
        header('Content-Disposition: attachment; filename=inventory_' . date('Y-m-d') . '.csv');

        $output = fopen('php://output', 'w');
        fputcsv($output, ['Item', 'SKU', 'Quantity', 'Unit', 'Min Qty', 'Supplier']);
        foreach ($items as $item) {
            fputcsv($output, [$item['name'], $item['sku'], $item['quantity'], $item['consumption_unit'], $item['min_quantity'], $item['supplier']]);
        }
        fclose($output);
        exit;



        // ============ EXPORT DATA (Preview) ============

        // ============ Z-REPORT HISTORY ============
    case 'get_notifications':
        $notifications = [];

        // Low stock notifications
        $stmt = $pdo->query("SELECT name, quantity, min_quantity, consumption_unit FROM inventory WHERE quantity <= min_quantity");
        foreach ($stmt->fetchAll() as $row) {
            $status = $row['quantity'] <= 0 ? 'Out of Stock' : 'Low Stock';
            $notifications[] = [
                'type' => 'stock',
                'title' => $status,
                'message' => "{$row['name']} is {$status} ({$row['quantity']} {$row['consumption_unit']})",
                'time' => date('H:i')
            ];
        }

        // Pending KOT notifications
        $stmt = $pdo->query("SELECT COUNT(DISTINCT order_id) as count FROM order_items WHERE is_kot_printed = 0");
        $kotCount = $stmt->fetchColumn();
        if ($kotCount > 0) {
            $notifications[] = [
                'type' => 'kot',
                'title' => 'Pending KOT',
                'message' => "There are {$kotCount} pending orders in kitchen",
                'time' => date('H:i')
            ];
        }

        echo json_encode(['success' => true, 'data' => $notifications]);
        exit;

    case 'get_shifts':
        // Get all business day shifts (closed and ongoing)
        $stmt = $pdo->prepare("SELECT * FROM business_days ORDER BY opened_at DESC LIMIT 30");
        $stmt->execute();
        $shifts = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode(['success' => true, 'data' => $shifts]);
        break;


    case 'get_shift_status':
        $stmt = $pdo->prepare("SELECT * FROM shifts WHERE status = 'open' ORDER BY id DESC LIMIT 1");
        $stmt->execute();
        $shift = $stmt->fetch();
        echo json_encode(['success' => true, 'shift' => $shift]);
        break;

    default:
        echo json_encode(['success' => false, 'message' => 'Invalid action: ' . $action]);
        exit;
}
