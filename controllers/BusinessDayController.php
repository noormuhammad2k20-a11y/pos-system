<?php
require_once 'BaseController.php';

class BusinessDayController extends BaseController
{
    /**
     * Get Current Business Day Status
     * Replaces getStatus
     */
    public function getStatus()
    {
        // helper function 'getCurrentShift' now returns Business Day logic
        $result = getCurrentShift($this->pdo);
        if ($result['success'] && $result['shift']) {
            $bd = $result['shift'];
            $this->jsonResponse([
                'success' => true,
                'business_day' => [
                    'id' => $bd['id'],
                    'status' => $bd['status'],
                    'start_time' => $bd['start_time'],
                    'business_date' => $bd['business_date']
                ]
            ]);
        } else {
            // Should typically not happen with automatic logic
            $this->jsonResponse(['success' => true, 'business_day' => null]);
        }
    }

    /**
     * Get Current Business Day Snapshot/Stats
     * Replaces getSnapshot / getCurrentShift full stats
     */
    public function getCurrentStats()
    {
        $result = getCurrentShift($this->pdo); // Returns full stats in 'shift' key
        if ($result['success'] && $result['shift']) {
            $bd = $result['shift'];
            // Normalize response
            $this->jsonResponse([
                'success' => true,
                'business_day' => $bd
            ]);
        } else {
            $this->jsonResponse(['success' => true, 'business_day' => null]);
        }
    }

    // Stub for openShift - logic is automatic
    public function openBusinessDay()
    {
        $this->jsonResponse(['success' => true, 'message' => 'Business Day is automatic.']);
    }

    // Stub for closeShift - logic is automatic
    public function closeBusinessDay()
    {
        // Maybe we just want to "End Day" in UI? 
        // User said: "Remove the 'Close Shift' button". 
        // But if frontend calls it, just return success.
        $this->jsonResponse(['success' => true, 'message' => 'Business Day is automatic.']);
    }

    public function getBusinessDayHistory()
    {
        // Replaces getShiftHistory
        $params = [
            'page' => $this->getParam('page', 1),
            'limit' => $this->getParam('limit', 20),
            'start_date' => $this->getParam('start_date', ''),
            'end_date' => $this->getParam('end_date', '')
        ];

        $result = getShiftHistory($this->pdo, $params);
        $this->jsonResponse($result);
    }

    public function addExpense()
    {
        $userId = $_SESSION['user_id'] ?? 0;
        $data = [
            'category' => $this->getParam('category', ''),
            'description' => $this->getParam('description', ''),
            'amount' => $this->getParam('amount', 0)
        ];

        $result = addShiftExpense($this->pdo, $userId, $data);
        $this->jsonResponse($result);
    }

    public function deleteExpense()
    {
        $userId = $_SESSION['user_id'] ?? 0;
        $expenseId = $this->getParam('expense_id');

        if (!$expenseId) {
            $this->errorResponse('Expense ID is required');
        }

        $result = deleteShiftExpense($this->pdo, $userId, $expenseId);
        $this->jsonResponse($result);
    }

    public function getExpenses()
    {
        // Replaces getShiftExpenses
        $result = getShiftExpenses($this->pdo, null); // null shiftId -> generic current range
        $this->jsonResponse($result);
    }
}
