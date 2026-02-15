<?php

/**
 * Offline-First PWA Sync Helper Functions
 * Support functions for bidirectional synchronization
 */

/**
 * Helper function to get records changed since a timestamp
 * @param PDO $pdo Database connection
 * @param string $table Table name
 * @param string $since Timestamp to get changes since
 * @return array Changed records
 */
function getChangedRecords($pdo, $table, $since)
{
    try {
        // Check if table has updated_at column
        $stmt = $pdo->prepare("SHOW COLUMNS FROM `$table` LIKE 'updated_at'");
        $stmt->execute();

        if ($stmt->rowCount() === 0) {
            // Table doesn't have updated_at, return all records
            $stmt = $pdo->query("SELECT * FROM `$table`");
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        }

        // Get records modified since timestamp
        $stmt = $pdo->prepare("SELECT * FROM `$table` WHERE updated_at > ? ORDER BY updated_at ASC");
        $stmt->execute([$since]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        error_log("getChangedRecords error for $table: " . $e->getMessage());
        return [];
    }
}

/**
 * Apply a change from the sync queue
 * @param PDO $pdo Database connection
 * @param array $change Change record
 * @return array Result with success/conflict status
 */
function applyChange($pdo, $change)
{
    $entity = $change['entity'] ?? '';
    $action = $change['action'] ?? '';
    $data = $change['data'] ?? [];

    // Map entity to table name
    $tableMap = [
        'products' => 'products',
        'categories' => 'categories',
        'tables' => 'restaurant_tables',
        'inventory' => 'inventory',
        'staff' => 'staff',
        'settings' => 'settings'
    ];

    $table = $tableMap[$entity] ?? null;
    if (!$table) {
        return ['success' => false, 'message' => 'Invalid entity'];
    }

    try {
        // Check for conflicts (version-based conflict detection)
        if ($action === 'update' && isset($data['id'])) {
            $stmt = $pdo->prepare("SELECT version, updated_at FROM `$table` WHERE id = ?");
            $stmt->execute([$data['id']]);
            $current = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($current) {
                $serverVersion = (int)($current['version'] ?? 0);
                $clientVersion = (int)($data['version'] ?? 0);

                // Server has a newer version - conflict!
                if ($serverVersion > $clientVersion) {
                    return [
                        'success' => false,
                        'conflict' => true,
                        'serverVersion' => $current,
                        'message' => 'Version conflict detected'
                    ];
                }
            }
        }

        // Apply the change based on action
        switch ($action) {
            case 'add':
            case 'update':
                // Prepare data for upsert
                $data['updated_at'] = date('Y-m-d H:i:s');
                $data['version'] = ((int)($data['version'] ?? 0)) + 1;

                // Build INSERT ... ON DUPLICATE KEY UPDATE query
                $columns = array_keys($data);
                $placeholders = array_fill(0, count($columns), '?');

                $sql = "INSERT INTO `$table` (" . implode(', ', $columns) . ") 
                        VALUES (" . implode(', ', $placeholders) . ")
                        ON DUPLICATE KEY UPDATE ";

                $updateParts = [];
                foreach ($columns as $col) {
                    if ($col !== 'id') {
                        $updateParts[] = "$col = VALUES($col)";
                    }
                }
                $sql .= implode(', ', $updateParts);

                $stmt = $pdo->prepare($sql);
                $stmt->execute(array_values($data));

                return ['success' => true, 'id' => $data['id'] ?? $pdo->lastInsertId()];

            case 'delete':
                if (!isset($data['id'])) {
                    return ['success' => false, 'message' => 'No ID provided for delete'];
                }

                $stmt = $pdo->prepare("DELETE FROM `$table` WHERE id = ?");
                $stmt->execute([$data['id']]);

                return ['success' => true];

            default:
                return ['success' => false, 'message' => 'Invalid action'];
        }
    } catch (PDOException $e) {
        error_log("applyChange error: " . $e->getMessage());
        return ['success' => false, 'message' => $e->getMessage()];
    }
}
