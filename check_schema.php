<?php
require_once 'db.php';
$stmt = $pdo->query("SHOW COLUMNS FROM shifts");
$columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
print_r($columns);
