<?php
require_once 'd:/Xamp/htdocs/Tailor/New_folder/New_folder_login_3/db.php';

try {
    $sql = "INSERT INTO settings (setting_key, setting_value, setting_type, category) 
            VALUES ('business_day_start', '0', 'number', 'localization') 
            ON DUPLICATE KEY UPDATE category = 'localization'";

    $pdo->exec($sql);
    echo "Database update successful.";
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}
