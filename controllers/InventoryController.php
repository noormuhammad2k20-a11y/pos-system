<?php
require_once 'BaseController.php';

class InventoryController extends BaseController
{

    public function getInventory()
    {
        $page = max(1, intval($this->getParam('page', 1)));
        $limit = max(1, intval($this->getParam('limit', 5)));
        $offset = ($page - 1) * $limit;

        $totalRecords = $this->pdo->query("SELECT COUNT(*) FROM inventory")->fetchColumn();
        $totalPages = ceil($totalRecords / $limit);

        $stmt = $this->pdo->prepare("SELECT i.*, s.name as supplier_name,
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

        $this->jsonResponse([
            'data' => $stmt->fetchAll(),
            'pagination' => [
                'current_page' => $page,
                'total_pages' => (int)$totalPages,
                'total_records' => (int)$totalRecords,
                'limit' => $limit
            ]
        ]);
    }

    public function addStock()
    {
        $id = $this->getParam('id', 0);
        $quantity = floatval($this->getParam('quantity', 0));
        $notes = $this->getParam('notes', 'Stock In');

        try {
            $this->pdo->beginTransaction();

            // 1. Atomic Update
            $stmt = $this->pdo->prepare("UPDATE inventory SET quantity = quantity + ? WHERE id = ?");
            $stmt->execute([$quantity, $id]);

            // 2. Fetch new balance
            $stmt = $this->pdo->prepare("SELECT quantity FROM inventory WHERE id = ?");
            $stmt->execute([$id]);
            $newBalance = $stmt->fetchColumn();

            // 3. Log
            $stmt = $this->pdo->prepare("INSERT INTO stock_logs (inventory_id, qty_change, balance_after, reason, notes) VALUES (?, ?, ?, 'restock', ?)");
            $stmt->execute([$id, $quantity, $newBalance, $notes]);

            $this->pdo->commit();
            $this->jsonResponse(['success' => true]);
        } catch (Exception $e) {
            $this->pdo->rollBack();
            $this->errorResponse('Transaction failed: ' . $e->getMessage());
        }
    }

    public function addItem()
    {
        $name = $this->getParam('name');
        $sku = $this->getParam('sku');

        if (empty($sku)) {
            // Auto-generate SKU: SKU-TIMESTAMP-RANDOM
            $sku = 'SKU-' . date('ymd') . '-' . rand(1000, 9999);
        }
        $stmt = $this->pdo->prepare("INSERT INTO inventory (name, sku, purchase_unit, consumption_unit, conversion_factor, quantity, min_quantity, cost_per_unit, supplier_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->execute([
            $name,
            $sku,
            $this->getParam('purchase_unit', 'Pcs'),
            $this->getParam('consumption_unit', 'Pcs'),
            $this->getParam('conversion_factor', 1),
            $this->getParam('quantity', 0),
            $this->getParam('min_quantity', 5),
            $this->getParam('cost_per_unit', 0),
            $this->getParam('supplier_id') ?: null
        ]);
        $this->jsonResponse(['success' => true, 'id' => $this->pdo->lastInsertId()]);
    }

    public function updateItem()
    {
        $stmt = $this->pdo->prepare("UPDATE inventory SET name = ?, sku = ?, min_quantity = ?, cost_per_unit = ?, supplier_id = ? WHERE id = ?");
        $stmt->execute([
            $this->getParam('name'),
            $this->getParam('sku'),
            $this->getParam('min_quantity'),
            $this->getParam('cost_per_unit', 0),
            $this->getParam('supplier_id') ?: null,
            $this->getParam('id')
        ]);
        $this->jsonResponse(['success' => true]);
    }

    public function deleteItem()
    {
        $id = $this->getParam('id');
        $stmt = $this->pdo->prepare("SELECT COUNT(*) FROM recipes WHERE inventory_id = ?");
        $stmt->execute([$id]);
        if ($stmt->fetchColumn() > 0) {
            $this->errorResponse('Item is used in recipes. Remove from recipes first.');
        } else {
            $stmt = $this->pdo->prepare("DELETE FROM inventory WHERE id = ?");
            $stmt->execute([$id]);
            $this->jsonResponse(['success' => true]);
        }
    }
}
