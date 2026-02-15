/**
 * GustoPOS Sync Manager
 * Handles bidirectional synchronization between IndexedDB and server
 * Implements conflict resolution and automatic retry logic
 */

const SyncManager = {
    syncing: false,
    syncInterval: null,
    autoSyncEnabled: true,
    retryDelay: 5000, // Start with 5 seconds
    maxRetryDelay: 300000, // Max 5 minutes
    lastSyncTime: null,
    pendingChanges: 0,

    /**
     * Initialize sync manager
     */
    async init() {
        console.log('[SyncManager] Initializing...');

        // Load last sync time
        this.lastSyncTime = await DBManager.getSyncMetadata('lastSyncTime', null);

        // Subscribe to network changes
        NetworkManager.subscribe(async (event, info) => {
            if (event === 'online' && this.autoSyncEnabled) {
                console.log('[SyncManager] Connection restored, triggering sync...');
                setTimeout(() => this.sync(), 1000); // Delay 1s to let connection stabilize
            }
        });

        // Periodic sync check (every 5 minutes when online)
        this.syncInterval = setInterval(() => {
            if (NetworkManager.isOnline() && this.autoSyncEnabled) {
                this.checkPendingChanges();
            }
        }, 300000); // 5 minutes

        // Initial check
        await this.checkPendingChanges();
        console.log('[SyncManager] ✓ Ready');
    },

    /**
     * Check for pending changes and update UI
     */
    async checkPendingChanges() {
        try {
            const count = await DBManager.count('sync_queue');
            this.pendingChanges = count;
            this.updateSyncUI();

            if (count > 0 && NetworkManager.isOnline() && !this.syncing) {
                console.log(`[SyncManager] Found ${count} pending changes`);
                // Auto-sync if enabled
                if (this.autoSyncEnabled) {
                    await this.sync();
                }
            }
        } catch (error) {
            console.error('[SyncManager] Error checking pending changes:', error);
        }
    },

    /**
     * Queue a change for synchronization
     */
    async queueChange(entity, action, data, priority = 'normal') {
        try {
            const change = {
                entity,
                action, // 'add', 'update', 'delete'
                data,
                timestamp: new Date().toISOString(),
                status: 'pending',
                retries: 0,
                priority,
                localId: data.id || null
            };

            await DBManager.add('sync_queue', change);
            this.pendingChanges++;
            this.updateSyncUI();

            console.log(`[SyncManager] Queued ${action} on ${entity}#${data.id || 'new'}`);

            // Attempt immediate sync if online
            if (NetworkManager.isOnline() && this.autoSyncEnabled) {
                setTimeout(() => this.sync(), 500);
            }
        } catch (error) {
            console.error('[SyncManager] Error queuing change:', error);
        }
    },

    /**
     * Main synchronization function
     */
    async sync() {
        if (this.syncing) {
            console.log('[SyncManager] Sync already in progress, skipping');
            return { success: false, message: 'Sync already in progress' };
        }

        if (!NetworkManager.isOnline()) {
            console.log('[SyncManager] Cannot sync while offline');
            return { success: false, message: 'No internet connection' };
        }

        this.syncing = true;
        this.showSyncProgress(true);

        try {
            console.log('[SyncManager] Starting synchronization...');

            // Step 1: Push local changes to server
            const pushResult = await this.pushChanges();

            // Step 2: Pull server changes to local
            const pullResult = await this.pullChanges();

            // Step 3: Update metadata
            this.lastSyncTime = new Date().toISOString();
            await DBManager.setSyncMetadata('lastSyncTime', this.lastSyncTime);

            this.pendingChanges = 0;
            this.retryDelay = 5000; // Reset retry delay

            console.log('[SyncManager] ✓ Sync complete', {
                pushed: pushResult.synced,
                pulled: pullResult.updated,
                conflicts: pushResult.conflicts
            });

            this.showSyncProgress(false);
            this.updateSyncUI();

            // Show success notification
            if (pushResult.synced > 0 || pullResult.updated > 0) {
                this.showToast(
                    `Sync complete! ${pushResult.synced} sent, ${pullResult.updated} received`,
                    'success'
                );
            }

            return {
                success: true,
                pushed: pushResult.synced,
                pulled: pullResult.updated,
                conflicts: pushResult.conflicts
            };

        } catch (error) {
            console.error('[SyncManager] Sync failed:', error);
            this.showSyncProgress(false);
            this.handleSyncError(error);
            return { success: false, error: error.message };
        } finally {
            this.syncing = false;
        }
    },

    /**
     * Push local changes to server
     */
    async pushChanges() {
        const queue = await DBManager.getAll('sync_queue');
        const pendingChanges = queue.filter(item => item.status === 'pending');

        if (pendingChanges.length === 0) {
            return { synced: 0, conflicts: [] };
        }

        console.log(`[SyncManager] Pushing ${pendingChanges.length} changes to server...`);

        let synced = 0;
        const conflicts = [];

        for (const change of pendingChanges) {
            try {
                const result = await this.pushSingleChange(change);

                if (result.success) {
                    // Remove from queue
                    await DBManager.delete('sync_queue', change.id);

                    // Update local record with server data
                    if (result.serverId && change.entity !== 'orders') {
                        await this.updateLocalWithServerId(change.entity, change.localId, result.serverId);
                    }

                    synced++;
                } else if (result.conflict) {
                    conflicts.push(result);
                    await this.handleConflict(change, result);
                } else {
                    // Update retry count
                    change.retries++;
                    change.lastError = result.error;
                    await DBManager.update('sync_queue', change.id, change);
                }
            } catch (error) {
                console.error(`[SyncManager] Error pushing change ${change.id}:`, error);
                change.retries++;
                change.lastError = error.message;
                await DBManager.update('sync_queue', change.id, change);
            }
        }

        return { synced, conflicts };
    },

    /**
     * Push a single change to the server
     */
    async pushSingleChange(change) {
        const { entity, action, data } = change;

        // Map entity to API action
        const actionMap = {
            products: {
                add: 'add_product',
                update: 'update_product',
                delete: 'delete_product'
            },
            categories: {
                add: 'add_category',
                update: 'update_category',
                delete: 'delete_category'
            },
            tables: {
                add: 'add_table',
                update: 'update_table',
                delete: 'delete_table'
            },
            orders: {
                add: 'place_order',
                update: 'update_order',
                delete: 'void_order'
            },
            inventory: {
                add: 'add_inventory_item',
                update: 'update_inventory_item',
                delete: 'delete_inventory_item'
            },
            staff: {
                add: 'add_staff',
                update: 'update_staff',
                delete: 'delete_staff'
            },
            settings: {
                update: 'update_settings_batch'
            }
        };

        const apiAction = actionMap[entity]?.[action];
        if (!apiAction) {
            console.warn(`[SyncManager] No API mapping for ${entity}.${action}`);
            return { success: false, error: 'No API mapping' };
        }

        try {
            // Make API call using global api function
            const response = await fetch('backend.php', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: new URLSearchParams({ action: apiAction, ...data })
            });

            const result = await response.json();

            if (result.success) {
                return {
                    success: true,
                    serverId: result.id || result.order_id || data.id,
                    data: result
                };
            } else if (result.conflict) {
                return {
                    success: false,
                    conflict: true,
                    serverVersion: result.serverVersion,
                    error: result.message
                };
            } else {
                return {
                    success: false,
                    error: result.message || 'Unknown error'
                };
            }
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    },

    /**
     * Pull server changes to local
     */
    async pullChanges() {
        const lastSync = await DBManager.getSyncMetadata('lastSyncTime', '1970-01-01 00:00:00');

        console.log(`[SyncManager] Pulling changes since ${lastSync}...`);

        try {
            const response = await fetch('backend.php', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: new URLSearchParams({
                    action: 'sync_pull',
                    last_sync: lastSync
                })
            });

            const result = await response.json();

            if (!result.success) {
                throw new Error(result.message || 'Pull failed');
            }

            let updated = 0;

            // Update each entity type
            for (const [entity, records] of Object.entries(result.changes || {})) {
                if (records && records.length > 0) {
                    console.log(`[SyncManager] Updating ${records.length} ${entity} records`);
                    await DBManager.bulkAdd(entity, records);
                    updated += records.length;
                }
            }

            return { updated };
        } catch (error) {
            console.error('[SyncManager] Pull failed:', error);
            throw error;
        }
    },

    /**
     * Handle conflict resolution
     */
    async handleConflict(localChange, serverResponse) {
        console.warn('[SyncManager] Conflict detected:', localChange.entity, localChange.data.id);

        // Last-write-wins strategy: Server always wins
        // For production, you might want manual resolution for critical data

        if (serverResponse.serverVersion) {
            // Update local with server version
            await DBManager.update(
                localChange.entity,
                localChange.data.id,
                serverResponse.serverVersion
            );

            // Mark as synced
            await DBManager.delete('sync_queue', localChange.id);

            console.log('[SyncManager] Conflict resolved: Server version applied');

            // Notify user about conflict
            this.showToast(
                `Conflict resolved for ${localChange.entity}. Server version applied.`,
                'warning'
            );
        }
    },

    /**
     * Update local record with server-generated ID
     */
    async updateLocalWithServerId(entity, localId, serverId) {
        if (localId !== serverId) {
            const record = await DBManager.getById(entity, localId);
            if (record) {
                await DBManager.delete(entity, localId);
                record.id = serverId;
                await DBManager.add(entity, record);
            }
        }
    },

    /**
     * Handle sync errors with retry logic
     */
    handleSyncError(error) {
        console.error('[SyncManager] Error:', error);

        this.showToast('Sync failed. Will retry automatically.', 'error');

        // Exponential backoff
        if (this.autoSyncEnabled && NetworkManager.isOnline()) {
            this.retryDelay = Math.min(this.retryDelay * 2, this.maxRetryDelay);
            console.log(`[SyncManager] Retrying in ${this.retryDelay / 1000}s...`);

            setTimeout(() => {
                if (NetworkManager.isOnline()) {
                    this.sync();
                }
            }, this.retryDelay);
        }
    },

    /**
     * Update sync UI elements
     */
    updateSyncUI() {
        const syncButton = document.getElementById('offline-sync-btn');
        const syncBadge = document.getElementById('sync-badge');

        if (this.pendingChanges > 0) {
            if (syncButton) {
                syncButton.style.display = 'flex';
                syncButton.classList.add('pulse-animation');
            }
            if (syncBadge) {
                syncBadge.textContent = this.pendingChanges;
                syncBadge.style.display = 'inline-block';
            }
        } else {
            if (syncButton) {
                syncButton.style.display = 'none';
                syncButton.classList.remove('pulse-animation');
            }
            if (syncBadge) {
                syncBadge.style.display = 'none';
            }
        }
    },

    /**
     * Show/hide sync progress indicator
     */
    showSyncProgress(show) {
        const progress = document.getElementById('sync-progress');
        if (progress) {
            progress.style.display = show ? 'flex' : 'none';
        }
    },

    /**
     * Show toast notification
     */
    showToast(message, type = 'info') {
        if (typeof showToast === 'function') {
            showToast(message, type);
        } else {
            console.log(`[SyncManager] ${type.toUpperCase()}: ${message}`);
        }
    },

    /**
     * Manual sync trigger
     */
    async manualSync() {
        console.log('[SyncManager] Manual sync triggered');
        return await this.sync();
    },

    /**
     * Enable/disable auto sync
     */
    setAutoSync(enabled) {
        this.autoSyncEnabled = enabled;
        console.log('[SyncManager] Auto-sync:', enabled ? 'enabled' : 'disabled');
    },

    /**
     * Get sync status
     */
    getStatus() {
        return {
            syncing: this.syncing,
            pendingChanges: this.pendingChanges,
            lastSyncTime: this.lastSyncTime,
            autoSyncEnabled: this.autoSyncEnabled,
            online: NetworkManager.isOnline()
        };
    },

    /**
     * Clear all pending changes (use carefully!)
     */
    async clearQueue() {
        await DBManager.clear('sync_queue');
        this.pendingChanges = 0;
        this.updateSyncUI();
        console.log('[SyncManager] Queue cleared');
    }
};

// Auto-initialize on load
if (typeof window !== 'undefined') {
    window.addEventListener('load', async () => {
        // Wait for dependencies
        const waitForDeps = setInterval(async () => {
            if (typeof DBManager !== 'undefined' &&
                typeof NetworkManager !== 'undefined' &&
                DBManager.db &&
                NetworkManager.online !== undefined) {
                clearInterval(waitForDeps);
                await SyncManager.init();
            }
        }, 100);

        // Timeout after 5 seconds
        setTimeout(() => clearInterval(waitForDeps), 5000);
    });
}
