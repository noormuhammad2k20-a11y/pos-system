<?php

class BaseController
{
    protected $pdo;

    public function __construct($pdo)
    {
        $this->pdo = $pdo;
    }

    protected function jsonResponse($data)
    {
        if (!isset($data['success'])) {
            $data['success'] = true;
        }
        echo json_encode($data);
        exit;
    }

    protected function errorResponse($message, $code = 400)
    {
        http_response_code($code);
        echo json_encode(['success' => false, 'message' => $message]);
        exit;
    }

    protected function getParam($key, $default = null)
    {
        return $_REQUEST[$key] ?? $default;
    }

    protected function logAudit($action, $entity, $entityId, $details = '')
    {
        try {
            $stmt = $this->pdo->prepare("INSERT INTO audit_logs (user_id, user_name, action, entity, entity_id, details) VALUES (?, ?, ?, ?, ?, ?)");
            $userId = $_SESSION['user_id'] ?? 0;
            $userName = $_SESSION['user_name'] ?? 'System';
            $stmt->execute([$userId, $userName, $action, $entity, $entityId, is_array($details) ? json_encode($details) : $details]);
        } catch (Exception $e) {
            // Silently fail logging
        }
    }

    protected function broadcast($action, $data = [])
    {
        if (function_exists('broadcastWS')) {
            broadcastWS($action, $data);
        }
    }
}
