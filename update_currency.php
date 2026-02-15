<?php
require_once 'db.php';
require_once 'classes.php';

echo "Updating Currency Symbol...\n";

try {
    // Check if setting exists
    $stmt = $pdo->prepare("SELECT id FROM settings WHERE setting_key = 'currency_symbol'");
    $stmt->execute();
    if ($stmt->fetchColumn()) {
        $pdo->exec("UPDATE settings SET setting_value = 'Rs ' WHERE setting_key = 'currency_symbol'");
        echo "Updated existing currency setting to 'Rs '\n";
    } else {
        $pdo->exec("INSERT INTO settings (setting_key, setting_value, setting_type, category) VALUES ('currency_symbol', 'Rs ', 'text', 'general')");
        echo "Inserted new currency setting 'Rs '\n";
    }

    // Clear cache so frontend picks it up (if settings are cached)
    // Settings usually aren't cached in GustoCache but let's be safe if they use it.
    GustoCache::clear();

    echo "Done! Please refresh the page.\n";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
