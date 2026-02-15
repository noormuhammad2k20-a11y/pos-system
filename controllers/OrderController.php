<?php
require_once 'BaseController.php';

class OrderController extends BaseController
{
    public function placeOrder()
    {
        // 1. HYBRID INPUT READING (JSON or FORM DATA)
        $json = file_get_contents("php://input");
        $orderData = json_decode($json, true);

        if (!$orderData && !empty($_POST)) {
            $orderData = $_POST;
            if (isset($orderData['items']) && is_string($orderData['items'])) {
                $orderData['items'] = json_decode($orderData['items'], true);
            }
        }

        if (!$orderData) $this->errorResponse('Invalid data');

        $items = $orderData['items'] ?? [];
        if (empty($items)) $this->errorResponse('Cart is empty');

        // 1.5 MANDATORY STOCK CHECK
        if (function_exists('checkStockAvailability')) {
            $stockCheck = checkStockAvailability($this->pdo, $items);
            if (!$stockCheck['success']) {
                $this->errorResponse('Insufficient stock: ' . implode(', ', $stockCheck['missing']));
            }
        }

        // 2. NORMALIZE INPUTS (Fixing the Parameter Mismatch)
        // Checks for both table_id (snake_case) and tableId (camelCase)
        $tableId = $orderData['table_id'] ?? $orderData['tableId'] ?? null;
        $customerName = $orderData['customer_name'] ?? $orderData['customerName'] ?? 'Walk-in';
        $orderType = $orderData['order_type'] ?? $orderData['orderType'] ?? 'walk_in';
        $paymentMethod = $orderData['payment_method'] ?? $orderData['paymentMethod'] ?? 'cash';

        // Dynamic Refactor: Support both slugs (backward compat) and explicit IDs
        $orderTypeId = $orderData['order_type_id'] ?? null;
        $paymentMethodId = $orderData['payment_method_id'] ?? null;

        if (!$tableId || $tableId === "0" || $tableId === "null" || $tableId === "undefined") $tableId = null;

        try {
            $this->pdo->beginTransaction();

            // 2.5 BUSINESS DAY ASSOCIATION (Automatic)
            // 2.5 BUSINESS DAY ASSOCIATION (Auto-Resolve for FK Constraint)
            // Check for an OPEN shift/business day
            $stmt = $this->pdo->prepare("SELECT id FROM shifts WHERE status = 'open' LIMIT 1");
            $stmt->execute();
            $openShift = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($openShift) {
                // Use existing open shift
                $activeShiftId = $openShift['id'];
            } else {
                // AUTO-START: Create a new Business Day/Shift
                // Ensure we satisfy the FK constraint in 'orders' table
                $userId = $_SESSION['user_id'] ?? 1; // Default to 1 if system
                $startTime = date('Y-m-d H:i:s');

                $stmt = $this->pdo->prepare("INSERT INTO shifts (user_id, start_time, status) VALUES (?, ?, 'open')");
                $stmt->execute([$userId, $startTime]);
                $activeShiftId = $this->pdo->lastInsertId();
            }


            // CRITICAL FIX: If tableId is present, it is NEVER a walk-in, regardless of order_type label.
            // This ensures logic downstream (like checking for existing orders and updating table status) triggers correctly.
            if ($tableId) {
                $isWalkIn = false;
            } else {
                $isWalkIn = ($orderType === 'walk_in' || $orderType === 'walkin');
            }
            $initialStatus = $orderData['status'] ?? 'pending';

            $orderId = null;
            $orderNum = null;
            $isExistingOrder = false;

            // 3. STRICT SINGLE ORDER PER TABLE - Check for ANY existing order on this table
            if (!$isWalkIn && $tableId) {
                // FIRST: Check if ANY pending/held order exists for this table (most reliable)
                // Use FOR UPDATE for row-level locking
                $orderStmt = $this->pdo->prepare("SELECT id, order_number FROM orders WHERE table_id = ? AND status IN ('pending', 'held') ORDER BY id DESC LIMIT 1 FOR UPDATE");
                $orderStmt->execute([$tableId]);
                $existingOrder = $orderStmt->fetch();

                if ($existingOrder) {
                    // ALWAYS merge into existing order - never create duplicate
                    $orderId = $existingOrder['id'];
                    $orderNum = $existingOrder['order_number'];
                    $isExistingOrder = true;
                } else {
                    // FALLBACK: Check current_order_id on table (in case order exists but table_id mismatch)
                    $stmt = $this->pdo->prepare("SELECT current_order_id FROM restaurant_tables WHERE id = ? FOR UPDATE");
                    $stmt->execute([$tableId]);
                    $table = $stmt->fetch();

                    if ($table && $table['current_order_id']) {
                        $checkStmt = $this->pdo->prepare("SELECT id, order_number FROM orders WHERE id = ? AND status IN ('pending', 'held') FOR UPDATE");
                        $checkStmt->execute([$table['current_order_id']]);
                        $existingOrder = $checkStmt->fetch();

                        if ($existingOrder) {
                            $orderId = $existingOrder['id'];
                            $orderNum = $existingOrder['order_number'];
                            $isExistingOrder = true;
                        }
                    }
                }
            }

            // 4. CREATE NEW ORDER (only if no existing order to merge into)
            if (!$orderId) {
                // Generate a temporary unique order number
                $tempNum = 'INV-TMP-' . time() . rand(100, 999);

                // Fetch IDs if only slugs provided
                if (!$orderTypeId && $orderType) {
                    $stmt = $this->pdo->prepare("SELECT id FROM order_types WHERE slug = ?");
                    $stmt->execute([$orderType]);
                    $orderTypeId = $stmt->fetchColumn() ?: null;
                }
                if (!$paymentMethodId && $paymentMethod) {
                    $stmt = $this->pdo->prepare("SELECT id FROM payment_methods WHERE slug = ?");
                    $stmt->execute([$paymentMethod]);
                    $paymentMethodId = $stmt->fetchColumn() ?: null;
                }

                $tokenNumber = $this->generateTokenNumber($activeShiftId);

                // CASH-ONLY OPTIMIZATION
                $paymentMethod = 'Cash'; // Force Cash
                $paymentStatus = 'unpaid';
                $completedAt = null;

                if ($initialStatus === 'completed' || $initialStatus === 'paid') {
                    $paymentStatus = 'paid';
                    $completedAt = date('Y-m-d H:i:s');
                    $initialStatus = 'completed';
                }

                $stmt = $this->pdo->prepare("INSERT INTO orders (order_number, token_number, customer_name, table_id, order_type, order_type_id, payment_method, payment_method_id, subtotal, tax, service_charge, discount, packaging_charge, delivery_fee, total, status, shift_id, created_at, payment_status, completed_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), ?, ?)");
                $stmt->execute([
                    $tempNum,
                    $tokenNumber,
                    $customerName,
                    $tableId,
                    $orderType, // Keep for backward compat until migration finished
                    $orderTypeId,
                    $paymentMethod,
                    $paymentMethodId,
                    $orderData['subtotal'] ?? 0,
                    $orderData['tax'] ?? 0,
                    $orderData['service_charge'] ?? 0,
                    $orderData['discount'] ?? 0,
                    $orderData['packaging_charge'] ?? 0,
                    $orderData['delivery_fee'] ?? 0,
                    $orderData['total'] ?? 0,
                    $initialStatus,
                    $activeShiftId,
                    $paymentStatus,
                    $completedAt
                ]);
                $orderId = $this->pdo->lastInsertId();
                $orderNum = 'INV-' . (1000 + $orderId);

                // Update with final order number
                $this->pdo->prepare("UPDATE orders SET order_number = ? WHERE id = ?")->execute([$orderNum, $orderId]);
            }



            // 6. UPSERT Items - Merge duplicates into single lines
            // For each item: if product already in order → increase qty, else insert new
            $checkItemStmt = $this->pdo->prepare("SELECT id, quantity FROM order_items WHERE order_id = ? AND product_id = ?");
            $updateItemStmt = $this->pdo->prepare("UPDATE order_items SET quantity = quantity + ? WHERE id = ?");
            $insertItemStmt = $this->pdo->prepare("INSERT INTO order_items (order_id, product_id, product_name, quantity, price, notes) VALUES (?, ?, ?, ?, ?, ?)");
            $stmtMod = $this->pdo->prepare("INSERT INTO order_item_modifiers (order_item_id, modifier_name, price) VALUES (?, ?, ?)");

            foreach ($items as $item) {
                $i_id = $item['id'] ?? 0;
                $i_name = $item['name'] ?? 'Unknown Item';
                $i_qty = $item['quantity'] ?? 1;
                $i_price = $item['price'] ?? 0;

                // Check if this product already exists in the order
                $checkItemStmt->execute([$orderId, $i_id]);
                $existingItem = $checkItemStmt->fetch();

                if ($existingItem) {
                    // MERGE: Update quantity of existing item
                    $updateItemStmt->execute([$i_qty, $existingItem['id']]);
                    $itemId = $existingItem['id'];
                } else {
                    // INSERT: New item
                    $insertItemStmt->execute([$orderId, $i_id, $i_name, $i_qty, $i_price, $item['notes'] ?? '']);
                    $itemId = $this->pdo->lastInsertId();
                }

                // Modifiers always append
                if (!empty($item['modifiers']) && is_array($item['modifiers'])) {
                    foreach ($item['modifiers'] as $mod) {
                        $stmtMod->execute([$itemId, $mod['name'], $mod['price']]);
                    }
                }
            }

            // 7. Recalculate Order Totals (important for merged orders)
            if ($isExistingOrder) {
                $this->recalculateOrderTotals($orderId);
            }

            // 8. Atomic Stock Deduction if fully completed
            if ($initialStatus === 'completed' || $initialStatus === 'paid') {
                if (function_exists('deductStockForOrder')) {
                    deductStockForOrder($this->pdo, $orderId);
                }
            }

            // Recalculate totals
            $this->recalculateOrderTotals($orderId);

            // Fetch final totals for logging/broadcasting
            $stmt = $this->pdo->prepare("SELECT order_number, total FROM orders WHERE id = ?");
            $stmt->execute([$orderId]);
            $finalOrder = $stmt->fetch();
            $orderNum = $finalOrder['order_number'];
            $finalTotal = $finalOrder['total'];

            // Log & Broadcast
            $action = $isExistingOrder ? 'APPEND_ORDER' : 'CREATE_ORDER';
            $message = $isExistingOrder ? "Items added to order $orderNum" : "Order $orderNum created. Total: $finalTotal";
            $this->logAudit($action, 'orders', $orderId, $message);
            $this->broadcast('new_order', ['order_number' => $orderNum, 'total' => $finalTotal]);

            // FINAL FORCE UPDATE: Update Table Status at the very end of transaction
            // This guarantees it runs for New Orders, Merged Orders, and Append Items
            if (!empty($tableId)) {
                $stmt = $this->pdo->prepare("UPDATE restaurant_tables SET status = 'busy', current_order_id = ?, occupied_since = NOW() WHERE id = ?");
                $stmt->execute([$orderId, $tableId]);
            }

            $this->pdo->commit(); // CRITICAL: Commit the transaction!

            echo json_encode(['success' => true, 'order_id' => $orderId, 'order_number' => $orderNum, 'merged' => $isExistingOrder]);
        } catch (Exception $e) {
            $this->pdo->rollBack();
            $this->errorResponse($e->getMessage());
        }
    }

    public function transferTable()
    {
        $fromTableId = $_POST['from_table_id'] ?? 0;
        $toTableId = $_POST['to_table_id'] ?? 0;

        if (!$fromTableId || !$toTableId) $this->errorResponse('Invalid tables');

        try {
            $this->pdo->beginTransaction();

            // Verify SOURCE table is busy/has order
            $stmt = $this->pdo->prepare("SELECT status, current_order_id, waiter_id, occupied_since FROM restaurant_tables WHERE id = ?");
            $stmt->execute([$fromTableId]);
            $fromTable = $stmt->fetch();

            if (!$fromTable || $fromTable['status'] === 'free') {
                throw new Exception('Source table is not busy');
            }

            // Verify TARGET table is free
            $stmt = $this->pdo->prepare("SELECT status FROM restaurant_tables WHERE id = ?");
            $stmt->execute([$toTableId]);
            $toTable = $stmt->fetch();

            if (!$toTable || $toTable['status'] !== 'free') {
                throw new Exception('Target table is not free');
            }

            // Move the order
            $orderId = $fromTable['current_order_id'];
            if ($orderId) {
                $stmt = $this->pdo->prepare("UPDATE orders SET table_id = ? WHERE id = ?");
                $stmt->execute([$toTableId, $orderId]);
            }

            // Update SOURCE table -> FREE
            $stmt = $this->pdo->prepare("UPDATE restaurant_tables SET status = 'free', current_order_id = NULL, waiter_id = NULL, occupied_since = NULL WHERE id = ?");
            $stmt->execute([$fromTableId]);

            // Update TARGET table -> BUSY (inherit details)
            $stmt = $this->pdo->prepare("UPDATE restaurant_tables SET status = 'busy', current_order_id = ?, waiter_id = ?, occupied_since = ? WHERE id = ?");
            $stmt->execute([$orderId, $fromTable['waiter_id'], $fromTable['occupied_since'], $toTableId]);

            $this->pdo->commit();

            // Broadcast update
            $this->broadcast('refresh_tables');

            echo json_encode(['success' => true]);
        } catch (Exception $e) {
            $this->pdo->rollBack();
            $this->errorResponse($e->getMessage());
        }
    }

    private function recalculateOrderTotals($orderId)
    {
        // Recalculate subtotal from all items
        $stmt = $this->pdo->prepare("SELECT SUM(quantity * price) as subtotal FROM order_items WHERE order_id = ?");
        $stmt->execute([$orderId]);
        $result = $stmt->fetch();
        $subtotal = $result['subtotal'] ?? 0;

        // Get current order to preserve tax rate
        $orderStmt = $this->pdo->prepare("SELECT tax, service_charge, packaging_charge, delivery_fee FROM orders WHERE id = ?");
        $orderStmt->execute([$orderId]);
        $order = $orderStmt->fetch();

        $taxRate = ($order['tax'] > 0 && $subtotal > 0) ? ($order['tax'] / $subtotal) : 0;
        $tax = $subtotal * $taxRate;
        $serviceRate = ($order['service_charge'] > 0 && $subtotal > 0) ? ($order['service_charge'] / $subtotal) : 0;
        $service = $subtotal * $serviceRate;
        $total = $subtotal + $tax + $service + floatval($order['packaging_charge']) + floatval($order['delivery_fee']);

        $this->pdo->prepare("UPDATE orders SET subtotal = ?, tax = ?, service_charge = ?, total = ? WHERE id = ?")
            ->execute([$subtotal, $tax, $service, $total, $orderId]);
    }

    private function generateTokenNumber($shiftId)
    {
        // 1. Get token reset logic from settings
        $stmt = $this->pdo->prepare("SELECT setting_value FROM settings WHERE setting_key = 'token_reset_logic'");
        $stmt->execute();
        $logic = $stmt->fetchColumn() ?: 'daily';

        $where = "TRUE";
        $params = [];

        if ($logic === 'shift') {
            $where = "shift_id = ?";
            $params[] = $shiftId;
        } else {
            // Daily reset
            $where = "DATE(created_at) = CURDATE()";
        }

        // Get max token number for today/shift
        $stmt = $this->pdo->prepare("SELECT MAX(token_number) FROM orders WHERE $where");
        $stmt->execute($params);
        $maxToken = (int)$stmt->fetchColumn();

        return $maxToken + 1;
    }

    public function voidOrder()
    {
        $orderId = $this->getParam('order_id');
        $reason = $this->getParam('reason');
        $voidType = $this->getParam('void_type', 'waste'); // 'return' or 'waste'

        try {
            $this->pdo->beginTransaction();

            // 1. Determine Status
            $status = ($voidType === 'return') ? 'void_return' : 'void_waste';

            // 2. Mark status
            $this->pdo->prepare("UPDATE orders SET status = ?, delete_reason = ? WHERE id = ?")->execute([$status, $reason, $orderId]);

            // 3. Mandatory Stock Handling
            if ($voidType === 'return') {
                if (function_exists('restoreStockForOrder')) {
                    restoreStockForOrder($this->pdo, $orderId);
                } else {
                    // Fallback log if function missing (should not happen if included from backend.php)
                    error_log("restoreStockForOrder function missing during void return");
                }
            }

            // 4. Free the table if it was occupied by this order
            // Check if this order is the current_order_id for any table
            $stmt = $this->pdo->prepare("SELECT id FROM restaurant_tables WHERE current_order_id = ?");
            $stmt->execute([$orderId]);
            $tableId = $stmt->fetchColumn();

            if ($tableId) {
                $this->pdo->prepare("UPDATE restaurant_tables SET status = 'free', current_order_id = NULL, occupied_since = NULL, waiter_id = NULL WHERE id = ?")->execute([$tableId]);
                $this->broadcast('refresh_tables');
            }

            $this->logAudit('VOID_ORDER', 'orders', $orderId, "Type: $voidType, Reason: $reason");
            $this->pdo->commit();
            $this->jsonResponse(['success' => true]);
        } catch (Exception $e) {
            $this->pdo->rollBack();
            $this->errorResponse('Void failed: ' . $e->getMessage());
        }
    }



    public function mergeTables()
    {
        $fromTableIds = json_decode($this->getParam('from_tables', '[]'), true);
        $toTableId = $this->getParam('to_table_id');

        if (empty($fromTableIds) || !$toTableId) {
            $this->errorResponse('Invalid tables for merge');
            return;
        }

        try {
            $this->pdo->beginTransaction();

            // 1. Lock destination table and find/create order
            $stmt = $this->pdo->prepare("SELECT current_order_id FROM restaurant_tables WHERE id = ? FOR UPDATE");
            $stmt->execute([$toTableId]);
            $toTable = $stmt->fetch();
            $destOrderId = $toTable['current_order_id'];

            if (!$destOrderId) {
                // Find any pending order for this table
                $stmt = $this->pdo->prepare("SELECT id FROM orders WHERE table_id = ? AND status IN ('pending', 'held') ORDER BY id DESC LIMIT 1 FOR UPDATE");
                $stmt->execute([$toTableId]);
                $destOrderId = $stmt->fetchColumn();

                if (!$destOrderId) {
                    // Create new order
                    $orderNum = 'INV-M-' . date('ymd') . rand(100, 999);
                    $this->pdo->prepare("INSERT INTO orders (order_number, table_id, status) VALUES (?, ?, 'pending')")->execute([$orderNum, $toTableId]);
                    $destOrderId = $this->pdo->lastInsertId();
                    $this->pdo->prepare("UPDATE restaurant_tables SET status = 'busy', current_order_id = ? WHERE id = ?")->execute([$destOrderId, $toTableId]);
                }
            }

            // 2. Process each source table
            foreach ($fromTableIds as $sourceTableId) {
                if ($sourceTableId == $toTableId) continue;

                // Lock source table
                $stmt = $this->pdo->prepare("SELECT current_order_id FROM restaurant_tables WHERE id = ? FOR UPDATE");
                $stmt->execute([$sourceTableId]);
                $sourceTable = $stmt->fetch();
                $sourceOrderId = $sourceTable['current_order_id'];

                if (!$sourceOrderId) {
                    $stmt = $this->pdo->prepare("SELECT id FROM orders WHERE table_id = ? AND status IN ('pending', 'held') ORDER BY id DESC LIMIT 1 FOR UPDATE");
                    $stmt->execute([$sourceTableId]);
                    $sourceOrderId = $stmt->fetchColumn();
                }

                if ($sourceOrderId) {
                    // Move items (UPSERT logic)
                    $stmtItems = $this->pdo->prepare("SELECT * FROM order_items WHERE order_id = ?");
                    $stmtItems->execute([$sourceOrderId]);
                    $items = $stmtItems->fetchAll();

                    foreach ($items as $item) {
                        // Check if item already in destination
                        $check = $this->pdo->prepare("SELECT id FROM order_items WHERE order_id = ? AND product_id = ? AND notes IS NULL FOR UPDATE");
                        $check->execute([$destOrderId, $item['product_id']]);
                        $existingId = $check->fetchColumn();

                        if ($existingId && !$item['notes']) {
                            $this->pdo->prepare("UPDATE order_items SET quantity = quantity + ? WHERE id = ?")->execute([$item['quantity'], $existingId]);
                        } else {
                            $this->pdo->prepare("INSERT INTO order_items (order_id, product_id, product_name, quantity, price, notes, is_kot_printed) VALUES (?, ?, ?, ?, ?, ?, ?)")
                                ->execute([$destOrderId, $item['product_id'], $item['product_name'], $item['quantity'], $item['price'], $item['notes'], $item['is_kot_printed']]);
                        }
                    }

                    // Delete source order and free table
                    $this->pdo->prepare("DELETE FROM orders WHERE id = ?")->execute([$sourceOrderId]);
                }
                $this->pdo->prepare("UPDATE restaurant_tables SET status = 'free', current_order_id = NULL, occupied_since = NULL, waiter_id = NULL WHERE id = ?")->execute([$sourceTableId]);
            }

            $this->recalculateOrderTotals($destOrderId);
            $this->logAudit('MERGE_TABLES', 'restaurant_tables', $toTableId, "Merged tables " . implode(',', $fromTableIds));
            $this->pdo->commit();
            $this->broadcast('refresh_tables');
            $this->jsonResponse(['success' => true]);
        } catch (Exception $e) {
            $this->pdo->rollBack();
            $this->errorResponse('Merge failed: ' . $e->getMessage());
        }
    }

    public function addPayment()
    {
        $orderId = $this->getParam('order_id');
        $amount = floatval($this->getParam('amount'));
        $method = $this->getParam('method', 'cash');

        try {
            $this->pdo->beginTransaction();

            // 1. Record Payment
            $stmt = $this->pdo->prepare("INSERT INTO order_payments (order_id, amount, payment_method) VALUES (?, ?, ?)");
            $stmt->execute([$orderId, $amount, $method]);

            // 2. Update Order Paid Amount
            $stmt = $this->pdo->prepare("UPDATE orders SET paid_amount = paid_amount + ? WHERE id = ?");
            $stmt->execute([$amount, $orderId]);

            // 3. Check if Fully Paid - Use FOR UPDATE
            $stmt = $this->pdo->prepare("SELECT total, paid_amount FROM orders WHERE id = ? FOR UPDATE");
            $stmt->execute([$orderId]);
            $order = $stmt->fetch();
            $newStatus = 'partial';

            if ($order['paid_amount'] >= $order['total'] - 0.01) {
                $newStatus = 'paid';
                // Mark order as completed/paid
                $this->pdo->prepare("UPDATE orders SET status = 'completed', payment_status = 'paid' WHERE id = ?")->execute([$orderId]);

                // IMPORTANT: We do NOT free the table here. 
                // The table remains 'busy' until 'Complete & Clear' is clicked manually.
            } else {
                $this->pdo->prepare("UPDATE orders SET payment_status = 'partial' WHERE id = ?")->execute([$orderId]);
            }

            $this->logAudit('ADD_PAYMENT', 'orders', $orderId, "Amount: $amount ($method). Status: $newStatus");

            $this->pdo->commit();
            $this->jsonResponse(['success' => true, 'payment_status' => $newStatus, 'paid_amount' => $order['paid_amount'] + $amount]);
        } catch (Exception $e) {
            $this->pdo->rollBack();
            $this->errorResponse('Payment failed: ' . $e->getMessage());
        }
    }

    public function returnOrderItems()
    {
        $orderId = $this->getParam('order_id');
        $itemsToReturn = $this->getParam('items');
        // Strict JSON Decode for array inputs
        if (is_string($itemsToReturn)) {
            $itemsToReturn = json_decode($itemsToReturn, true);
        }
        $reason = $this->getParam('reason');
        $returnStock = $this->getParam('return_stock', true); // Default to true

        if (empty($orderId) || empty($itemsToReturn)) {
            $this->errorResponse('Invalid data');
        }

        try {
            $this->pdo->beginTransaction();

            // 1. Fetch Order
            $stmt = $this->pdo->prepare("SELECT * FROM orders WHERE id = ?");
            $stmt->execute([$orderId]);
            $order = $stmt->fetch();

            if (!$order) throw new Exception("Order not found");
            if ($order['status'] === 'deleted' || $order['status'] === 'void_return') throw new Exception("Order already voided");

            $totalRefund = 0;
            $allItemsReturned = true;

            // 2. Process Items
            foreach ($itemsToReturn as $item) {
                $itemId = $item['id'];
                $returnQty = floatval($item['qty']);

                if ($returnQty <= 0) continue;

                // Fetch current item state
                $stmtItem = $this->pdo->prepare("SELECT * FROM order_items WHERE id = ? AND order_id = ?");
                $stmtItem->execute([$itemId, $orderId]);
                $orderItem = $stmtItem->fetch();

                if (!$orderItem) continue;

                if ($returnQty > $orderItem['quantity']) {
                    throw new Exception("Cannot return more than sold quantity for " . $orderItem['product_name']);
                }

                // Calculate refund amount (pro-rated price)
                $itemRefund = $returnQty * $orderItem['price'];
                $totalRefund += $itemRefund;

                // Update Item Quantity
                $newQty = $orderItem['quantity'] - $returnQty;

                if ($newQty == 0) {
                    // Remove item if fully returned
                    $this->pdo->prepare("DELETE FROM order_items WHERE id = ?")->execute([$itemId]);
                } else {
                    // Update quantity
                    $this->pdo->prepare("UPDATE order_items SET quantity = ? WHERE id = ?")->execute([$newQty, $itemId]);
                    $allItemsReturned = false; // At least one item remains
                }

                // Restore Stock
                if ($returnStock) {
                    $this->restoreStockSingleItem($orderItem['product_id'], $returnQty, $order['order_number']);
                }
            }

            // 3. Recalculate Order Totals
            if ($allItemsReturned) {
                // If no items left, mark as fully returned
                $this->pdo->prepare("UPDATE orders SET status = 'void_return', total = 0, subtotal = 0, tax = 0, delete_reason = ? WHERE id = ?")->execute([$reason, $orderId]);

                // Free table if applicable
                if ($order['table_id']) {
                    $this->pdo->prepare("UPDATE restaurant_tables SET status = 'free', current_order_id = NULL WHERE id = ?")->execute([$order['table_id']]);
                    if (method_exists($this, 'broadcast')) {
                        $this->broadcast('refresh_tables');
                    }
                }
            } else {
                // Partially returned - just recalculate
                if (function_exists('recalculateOrderTotals')) {
                    recalculateOrderTotals($this->pdo, $orderId);
                }
            }

            $this->logAudit('RETURN_ITEMS', 'orders', $orderId, "Returned items. Total Refund: $totalRefund. Reason: $reason");

            $this->pdo->commit();
            $this->jsonResponse(['success' => true, 'refund_amount' => $totalRefund]);
        } catch (Exception $e) {
            $this->pdo->rollBack();
            $this->errorResponse($e->getMessage());
        }
    }

    private function restoreStockSingleItem($productId, $qty, $ref)
    {
        $stmt = $this->pdo->prepare("SELECT inventory_id, qty_required FROM recipes WHERE product_id = ?");
        $stmt->execute([$productId]);
        $ingredients = $stmt->fetchAll();

        if ($ingredients) {
            foreach ($ingredients as $ing) {
                $restoreQty = $ing['qty_required'] * $qty;
                $this->pdo->prepare("UPDATE inventory SET quantity = quantity + ? WHERE id = ?")->execute([$restoreQty, $ing['inventory_id']]);

                $this->pdo->prepare("INSERT INTO stock_logs (inventory_id, qty_change, balance_after, reason, notes) 
                    VALUES (?, ?, (SELECT quantity FROM inventory WHERE id = ?), 'return', ?)")
                    ->execute([$ing['inventory_id'], $restoreQty, $ing['inventory_id'], "Return Order $ref"]);
            }
        }
    }
}
