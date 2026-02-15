<?php
require_once 'db.php';

try {
    $pdo->beginTransaction();

    $newSettings = [
        // Category: 'order'
        ['allow_price_override', 'false', 'boolean', 'order'],
        ['order_cancel_grace_period', '5', 'number', 'order'],
        ['token_reset_logic', 'daily', 'text', 'order'],
        ['auto_merge_table_orders', 'true', 'boolean', 'order'],

        // Category: 'receipt'
        ['receipt_layout_type', 'detailed', 'text', 'receipt'],
        ['receipt_font_size', 'medium', 'text', 'receipt'],
        ['show_category_on_receipt', 'false', 'boolean', 'receipt'],
        ['custom_footer_note', 'Thank you for visiting!', 'text', 'receipt'],
        ['show_developer_branding', 'true', 'boolean', 'receipt'],

        // Category: 'system'
        ['maintenance_mode', 'false', 'boolean', 'system'],
        ['backup_path', 'backups/', 'text', 'system'],
        ['log_retention_days', '30', 'number', 'system'],
        ['system_version', 'v2.5.0', 'text', 'system']
    ];

    $stmt = $pdo->prepare("INSERT INTO settings (setting_key, setting_value, setting_type, category) 
                           VALUES (?, ?, ?, ?) 
                           ON DUPLICATE KEY UPDATE 
                           category = VALUES(category),
                           setting_type = VALUES(setting_type)");

    foreach ($newSettings as $s) {
        $stmt->execute($s);
    }

    $pdo->commit();
    echo "SQL Migration successful. New specialized keys inserted/updated.\n";
} catch (Exception $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    echo "SQL Migration FAILED: " . $e->getMessage() . "\n";
}
