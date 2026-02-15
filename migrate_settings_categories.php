<?php
require_once 'db.php';

try {
    $pdo->beginTransaction();

    // 1. Update existing categories to match new organization
    $updates = [
        'order' => ['default_order_type', 'show_order_timer'],
        'receipt' => ['receipt_header', 'receipt_footer', 'show_logo_on_receipt', 'restaurant_logo']
    ];

    foreach ($updates as $cat => $keys) {
        $stmt = $pdo->prepare("UPDATE settings SET category = ? WHERE setting_key IN (" . str_repeat('?,', count($keys) - 1) . "?)");
        $stmt->execute(array_merge([$cat], $keys));
    }

    // 2. Insert new settings
    $newSettings = [
        ['allow_item_cancellation_after_kot', 'false', 'boolean', 'order'],
        ['receipt_font_size', '12', 'number', 'receipt'],
        ['debug_mode', 'false', 'boolean', 'system'],
        ['auto_backup', 'false', 'boolean', 'system'],
        ['software_version', '1.0.0', 'text', 'system']
    ];

    $stmt = $pdo->prepare("INSERT IGNORE INTO settings (setting_key, setting_value, setting_type, category) VALUES (?, ?, ?, ?)");
    foreach ($newSettings as $s) {
        $stmt->execute($s);
    }

    $pdo->commit();
    echo "Migration successful. Categories updated and new settings inserted.\n";
} catch (Exception $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    echo "Migration FAILED: " . $e->getMessage() . "\n";
}
