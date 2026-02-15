<?php
require_once 'db.php';
try {
    $sql = file_get_contents('add_business_day_setting.sql');
    $pdo->exec($sql);
    echo "Business day setting added.";
} catch (PDOException $e) {
    echo "Error adding setting: " . $e->getMessage();
}
