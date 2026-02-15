<?php
require_once 'db.php';
require_once 'helpers.php';

try {
    // 1. Setup Test Data
    // Check columns: name, quantity, consumption_unit (not unit!), cost_per_unit (maybe?)
    // Let's try minimal insert or use known columns
    $pdo->exec("INSERT INTO inventory (name, quantity, consumption_unit) VALUES ('Test Void Item', 100, 'pcs')");
    $invId = $pdo->lastInsertId();

    $pdo->exec("INSERT INTO products (name, price, category_id) VALUES ('Test Void Product', 20, 1)");
    $prodId = $pdo->lastInsertId();

    $pdo->exec("INSERT INTO recipes (product_id, inventory_id, qty_required) VALUES ($prodId, $invId, 1)");

    echo "Setup: InvID $invId (Qty 100), ProdID $prodId\n";

    // 2. Test Void Waste
    // Create Order
    $pdo->exec("INSERT INTO orders (order_number, total, status, payment_method) VALUES ('VOID-TEST-1', 20, 'completed', 'cash')");
    $orderId1 = $pdo->lastInsertId();
    $pdo->exec("INSERT INTO order_items (order_id, product_id, quantity, price) VALUES ($orderId1, $prodId, 1, 20)");

    // Deduct Stock
    deductStockForOrder($pdo, $orderId1);
    $stmt = $pdo->query("SELECT quantity FROM inventory WHERE id = $invId");
    $qty1 = $stmt->fetchColumn();
    echo "After Sale 1: Qty $qty1 (Expected 99)\n";

    // Void as Waste
    // Simulate Controller Logic
    $pdo->exec("UPDATE orders SET status = 'void_waste', delete_reason = 'Test Waste' WHERE id = $orderId1");
    // No restoration

    $stmt = $pdo->query("SELECT quantity FROM inventory WHERE id = $invId");
    $qty2 = $stmt->fetchColumn();
    echo "After Void Waste: Qty $qty2 (Expected 99)\n";


    // 3. Test Void Return
    // Create Order
    $pdo->exec("INSERT INTO orders (order_number, total, status, payment_method) VALUES ('VOID-TEST-2', 20, 'completed', 'cash')");
    $orderId2 = $pdo->lastInsertId();
    $pdo->exec("INSERT INTO order_items (order_id, product_id, quantity, price) VALUES ($orderId2, $prodId, 1, 20)");

    // Deduct Stock
    deductStockForOrder($pdo, $orderId2);
    $stmt = $pdo->query("SELECT quantity FROM inventory WHERE id = $invId");
    $qty3 = $stmt->fetchColumn();
    echo "After Sale 2: Qty $qty3 (Expected 98)\n";

    // Void as Return
    $pdo->exec("UPDATE orders SET status = 'void_return', delete_reason = 'Test Return' WHERE id = $orderId2");
    restoreStockForOrder($pdo, $orderId2);

    $stmt = $pdo->query("SELECT quantity FROM inventory WHERE id = $invId");
    $qty4 = $stmt->fetchColumn();
    echo "After Void Return: Qty $qty4 (Expected 99)\n";

    // Cleanup
    $pdo->exec("DELETE FROM inventory WHERE id = $invId");
    $pdo->exec("DELETE FROM products WHERE id = $prodId");
    $pdo->exec("DELETE FROM recipes WHERE product_id = $prodId");
    $pdo->exec("DELETE FROM orders WHERE id IN ($orderId1, $orderId2)");
    $pdo->exec("DELETE FROM order_items WHERE order_id IN ($orderId1, $orderId2)");

    echo "Done.\n";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
}
