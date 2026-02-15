<?php
require_once 'BaseController.php';

class SettingsController extends BaseController
{
    /**
     * GET settings grouped by category
     */
    public function getSettings()
    {
        $category = $this->getParam('category', 'all');

        $sql = "SELECT setting_key, setting_value, setting_type, category FROM settings";
        if ($category !== 'all') {
            $sql .= " WHERE category = ?";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute([$category]);
        } else {
            $stmt = $this->pdo->query($sql);
        }

        $settings = $stmt->fetchAll();
        $grouped = [];

        foreach ($settings as $s) {
            $cat = $s['category'];
            if (!isset($grouped[$cat])) $grouped[$cat] = [];

            // Type casting
            $val = $s['setting_value'];
            if ($s['setting_type'] === 'boolean') {
                $val = ($val === 'true' || $val === '1');
            } elseif ($s['setting_type'] === 'number') {
                $val = floatval($val);
            }

            $grouped[$cat][$s['setting_key']] = $val;
        }

        $this->jsonResponse(['success' => true, 'data' => $grouped]);
    }

    /**
     * GET metadata for dynamic frontend rendering
     */
    public function getMetadata()
    {
        // 1. Payment Methods
        $stmt = $this->pdo->query("SELECT id, name, slug FROM payment_methods WHERE is_active = 1");
        $paymentMethods = $stmt->fetchAll();

        // 2. Order Types
        $stmt = $this->pdo->query("SELECT id, name, slug FROM order_types WHERE is_active = 1");
        $orderTypes = $stmt->fetchAll();

        // 3. System Timezones
        $timezones = DateTimeZone::listIdentifiers();

        // 4. Printer Config (Static config that could be moved to file/DB later)
        $printerConfig = [
            'types' => [
                ['label' => 'Direct USB (WebUSB)', 'value' => 'usb'],
                ['label' => 'Bluetooth (Web Bluetooth)', 'value' => 'bluetooth'],
                ['label' => 'Network/IP (LAN)', 'value' => 'network'],
                ['label' => 'System Spooler (Browser)', 'value' => 'spooler']
            ],
            'widths' => [
                ['label' => '80mm (Standard)', 'value' => '80'],
                ['label' => '58mm (Small)', 'value' => '58']
            ]
        ];

        // 5. Settings Categories
        $stmt = $this->pdo->query("SELECT DISTINCT category FROM settings ORDER BY category ASC");
        $categories = $stmt->fetchAll(PDO::FETCH_COLUMN);

        // 6. Permissions List
        $stmt = $this->pdo->query("SELECT id, slug, name, category FROM permissions");
        $permissions = $stmt->fetchAll();

        $this->jsonResponse([
            'success' => true,
            'data' => [
                'payment_methods' => $paymentMethods,
                'order_types' => $orderTypes,
                'timezones' => $timezones,
                'printer_config' => $printerConfig,
                'categories' => $categories,
                'permissions' => $permissions
            ]
        ]);
    }

    /**
     * POST/PATCH save multiple settings
     */
    public function updateSettings()
    {
        // For security, only Admin can call this (checked in backend.php redirect)
        $data = json_decode(file_get_contents("php://input"), true);
        if (!$data) $data = $_POST;

        if (empty($data)) {
            $this->errorResponse('No data provided');
        }

        try {
            $this->pdo->beginTransaction();

            $stmt = $this->pdo->prepare("INSERT INTO settings (setting_key, setting_value, setting_type, category) 
                                   VALUES (?, ?, ?, ?) 
                                   ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)");

            foreach ($data as $key => $value) {
                // Determine type and category if inserting new
                // For simplicity, we assume they exist or we use general as fallback
                $type = is_bool($value) ? 'boolean' : (is_numeric($value) ? 'number' : 'text');
                $valStr = is_bool($value) ? ($value ? 'true' : 'false') : (string)$value;

                // Get existing category or default to general
                $check = $this->pdo->prepare("SELECT category, setting_type FROM settings WHERE setting_key = ?");
                $check->execute([$key]);
                $existing = $check->fetch();

                $cat = $existing ? $existing['category'] : 'general';
                $finalType = $existing ? $existing['setting_type'] : $type;

                $stmt->execute([$key, $valStr, $finalType, $cat]);
            }

            $this->logAudit('UPDATE_SETTINGS', 'settings', 0, 'Batch update of settings');

            // Clear caching if exists
            if (class_exists('GustoCache')) {
                GustoCache::clear('settings_all');
            }

            $this->pdo->commit();
            $this->jsonResponse(['success' => true, 'message' => 'Settings updated successfully']);
        } catch (Exception $e) {
            $this->pdo->rollBack();
            $this->errorResponse('Failed to update settings: ' . $e->getMessage());
        }
    }

    /**
     * POST upload restaurant logo
     */
    public function uploadLogo()
    {
        if (!isset($_FILES['logo']) || $_FILES['logo']['error'] !== UPLOAD_ERR_OK) {
            $this->errorResponse('No file uploaded or upload error');
        }

        $uploadDir = 'assets/';
        if (!is_dir($uploadDir)) mkdir($uploadDir, 0777, true);

        $ext = pathinfo($_FILES['logo']['name'], PATHINFO_EXTENSION);
        $filename = 'logo_' . time() . '.' . $ext;
        $targetPath = $uploadDir . $filename;

        if (move_uploaded_file($_FILES['logo']['tmp_name'], $targetPath)) {
            $stmt = $this->pdo->prepare("UPDATE settings SET setting_value = ? WHERE setting_key = 'restaurant_logo'");
            $stmt->execute([$targetPath]);

            $this->logAudit('UPLOAD_LOGO', 'settings', 0, "New logo uploaded: $targetPath");
            $this->jsonResponse(['success' => true, 'path' => $targetPath]);
        } else {
            $this->errorResponse('Failed to save uploaded file');
        }
    }

    /**
     * POST reset application data (DANGER ZONE)
     */
    public function resetData()
    {
        try {
            $this->pdo->beginTransaction();

            // 1. Transactional Tables to clear
            $tables = [
                'order_items',
                'payments',
                'orders',
                'expenses',
                'shifts',
                'audit_logs'
            ];

            // Disable foreign key checks for truncation
            $this->pdo->exec("SET FOREIGN_KEY_CHECKS = 0");

            foreach ($tables as $table) {
                $this->pdo->exec("TRUNCATE TABLE $table");
            }

            // Reset table statuses to free
            $this->pdo->exec("UPDATE restaurant_tables SET status = 'free', current_order_id = NULL, waiter_id = NULL, occupied_since = NULL, locked_by = NULL, locked_at = NULL");

            $this->pdo->exec("SET FOREIGN_KEY_CHECKS = 1");

            $this->logAudit('SYSTEM_RESET', 'system', 0, 'Full transaction data reset triggered by admin');

            $this->pdo->commit();
            $this->jsonResponse(['success' => true, 'message' => 'Application data has been successfully reset.']);
        } catch (Exception $e) {
            if ($this->pdo->inTransaction()) $this->pdo->rollBack();
            $this->errorResponse('Data reset failed: ' . $e->getMessage());
        }
    }
}
