/**
 * GustoPOS IndexedDB Manager
 * Comprehensive offline storage for all application entities
 * Supports full CRUD operations, versioning, and migration
 */

const DBManager = {
    dbName: 'GustoPOS_OfflineDB',
    version: 2, // Increment when schema changes
    db: null,

    // Define all object stores
    stores: {
        products: { keyPath: 'id', autoIncrement: false, indexes: ['category_id', 'updated_at'] },
        categories: { keyPath: 'id', autoIncrement: false, indexes: ['updated_at'] },
        tables: { keyPath: 'id', autoIncrement: false, indexes: ['status', 'updated_at'] },
        orders: { keyPath: 'id', autoIncrement: true, indexes: ['status', 'table_id', 'updated_at', 'order_number'] },
        settings: { keyPath: 'setting_key', autoIncrement: false, indexes: ['category', 'updated_at'] },
        inventory: { keyPath: 'id', autoIncrement: false, indexes: ['updated_at'] },
        staff: { keyPath: 'id', autoIncrement: false, indexes: ['role', 'updated_at'] },
        sync_queue: { keyPath: 'id', autoIncrement: true, indexes: ['entity', 'timestamp', 'status'] },
        sync_metadata: { keyPath: 'key', autoIncrement: false }
    },

    /**
     * Initialize IndexedDB with all stores and indexes
     */
    init() {
        return new Promise((resolve, reject) => {
            console.log('[DBManager] Initializing IndexedDB...');

            const request = indexedDB.open(this.dbName, this.version);

            request.onerror = (event) => {
                console.error('[DBManager] Database error:', event.target.error);
                reject(event.target.error);
            };

            request.onblocked = () => {
                console.warn('[DBManager] Database upgrade blocked. Close other tabs.');
            };

            request.onupgradeneeded = (event) => {
                console.log('[DBManager] Upgrading database schema...');
                const db = event.target.result;
                const transaction = event.target.transaction;

                // Create or upgrade each store
                Object.entries(this.stores).forEach(([storeName, config]) => {
                    let objectStore;

                    if (!db.objectStoreNames.contains(storeName)) {
                        // Create new store
                        objectStore = db.createObjectStore(storeName, {
                            keyPath: config.keyPath,
                            autoIncrement: config.autoIncrement
                        });
                        console.log(`[DBManager] Created store: ${storeName}`);
                    } else {
                        // Get existing store for index updates
                        objectStore = transaction.objectStore(storeName);
                    }

                    // Create indexes
                    if (config.indexes) {
                        config.indexes.forEach(indexName => {
                            if (!objectStore.indexNames.contains(indexName)) {
                                objectStore.createIndex(indexName, indexName, { unique: false });
                                console.log(`[DBManager] Created index: ${storeName}.${indexName}`);
                            }
                        });
                    }
                });

                console.log('[DBManager] Schema upgrade complete');
            };

            request.onsuccess = (event) => {
                this.db = event.target.result;
                console.log('[DBManager] Database ready:', this.db.name, 'v' + this.db.version);

                // Handle version change in other tabs
                this.db.onversionchange = () => {
                    this.db.close();
                    console.warn('[DBManager] Database version changed, please reload');
                    window.location.reload();
                };

                resolve(this.db);
            };
        });
    },

    /**
     * Get all records from a store
     */
    getAll(storeName) {
        return new Promise((resolve, reject) => {
            if (!this.db) {
                reject(new Error('Database not initialized'));
                return;
            }

            const transaction = this.db.transaction([storeName], 'readonly');
            const store = transaction.objectStore(storeName);
            const request = store.getAll();

            request.onsuccess = () => {
                resolve(request.result || []);
            };

            request.onerror = () => {
                console.error(`[DBManager] Error getting all from ${storeName}:`, request.error);
                reject(request.error);
            };
        });
    },

    /**
     * Get a single record by ID
     */
    getById(storeName, id) {
        return new Promise((resolve, reject) => {
            if (!this.db) {
                reject(new Error('Database not initialized'));
                return;
            }

            const transaction = this.db.transaction([storeName], 'readonly');
            const store = transaction.objectStore(storeName);
            const request = store.get(id);

            request.onsuccess = () => {
                resolve(request.result || null);
            };

            request.onerror = () => {
                console.error(`[DBManager] Error getting ${storeName}#${id}:`, request.error);
                reject(request.error);
            };
        });
    },

    /**
     * Get records by index value
     */
    getByIndex(storeName, indexName, value) {
        return new Promise((resolve, reject) => {
            if (!this.db) {
                reject(new Error('Database not initialized'));
                return;
            }

            const transaction = this.db.transaction([storeName], 'readonly');
            const store = transaction.objectStore(storeName);
            const index = store.index(indexName);
            const request = index.getAll(value);

            request.onsuccess = () => {
                resolve(request.result || []);
            };

            request.onerror = () => {
                console.error(`[DBManager] Error querying ${storeName} by ${indexName}:`, request.error);
                reject(request.error);
            };
        });
    },

    /**
     * Add a new record
     */
    add(storeName, data) {
        return new Promise((resolve, reject) => {
            if (!this.db) {
                reject(new Error('Database not initialized'));
                return;
            }

            // Add metadata
            const record = {
                ...data,
                updated_at: new Date().toISOString(),
                version: data.version || 1,
                synced: false
            };

            const transaction = this.db.transaction([storeName], 'readwrite');
            const store = transaction.objectStore(storeName);
            const request = store.add(record);

            request.onsuccess = () => {
                console.log(`[DBManager] Added to ${storeName}:`, request.result);
                resolve(request.result);
            };

            request.onerror = () => {
                console.error(`[DBManager] Error adding to ${storeName}:`, request.error);
                reject(request.error);
            };
        });
    },

    /**
     * Update an existing record
     */
    update(storeName, id, data) {
        return new Promise((resolve, reject) => {
            if (!this.db) {
                reject(new Error('Database not initialized'));
                return;
            }

            // Update metadata
            const record = {
                ...data,
                id: id,
                updated_at: new Date().toISOString(),
                version: (data.version || 0) + 1,
                synced: false
            };

            const transaction = this.db.transaction([storeName], 'readwrite');
            const store = transaction.objectStore(storeName);
            const request = store.put(record);

            request.onsuccess = () => {
                console.log(`[DBManager] Updated ${storeName}#${id}`);
                resolve(request.result);
            };

            request.onerror = () => {
                console.error(`[DBManager] Error updating ${storeName}#${id}:`, request.error);
                reject(request.error);
            };
        });
    },

    /**
     * Delete a record
     */
    delete(storeName, id) {
        return new Promise((resolve, reject) => {
            if (!this.db) {
                reject(new Error('Database not initialized'));
                return;
            }

            const transaction = this.db.transaction([storeName], 'readwrite');
            const store = transaction.objectStore(storeName);
            const request = store.delete(id);

            request.onsuccess = () => {
                console.log(`[DBManager] Deleted ${storeName}#${id}`);
                resolve();
            };

            request.onerror = () => {
                console.error(`[DBManager] Error deleting ${storeName}#${id}:`, request.error);
                reject(request.error);
            };
        });
    },

    /**
     * Clear all records from a store
     */
    clear(storeName) {
        return new Promise((resolve, reject) => {
            if (!this.db) {
                reject(new Error('Database not initialized'));
                return;
            }

            const transaction = this.db.transaction([storeName], 'readwrite');
            const store = transaction.objectStore(storeName);
            const request = store.clear();

            request.onsuccess = () => {
                console.log(`[DBManager] Cleared ${storeName}`);
                resolve();
            };

            request.onerror = () => {
                console.error(`[DBManager] Error clearing ${storeName}:`, request.error);
                reject(request.error);
            };
        });
    },

    /**
     * Bulk add multiple records (more efficient than individual adds)
     */
    bulkAdd(storeName, dataArray) {
        return new Promise((resolve, reject) => {
            if (!this.db) {
                reject(new Error('Database not initialized'));
                return;
            }

            const transaction = this.db.transaction([storeName], 'readwrite');
            const store = transaction.objectStore(storeName);
            let successCount = 0;
            let errorCount = 0;

            dataArray.forEach(data => {
                const record = {
                    ...data,
                    updated_at: data.updated_at || new Date().toISOString(),
                    version: data.version || 1,
                    synced: data.synced !== undefined ? data.synced : true
                };

                const request = store.put(record); // Use put to allow updates
                request.onsuccess = () => successCount++;
                request.onerror = () => errorCount++;
            });

            transaction.oncomplete = () => {
                console.log(`[DBManager] Bulk add to ${storeName}: ${successCount} succeeded, ${errorCount} failed`);
                resolve({ success: successCount, failed: errorCount });
            };

            transaction.onerror = () => {
                console.error(`[DBManager] Bulk add transaction failed:`, transaction.error);
                reject(transaction.error);
            };
        });
    },

    /**
     * Search records with a custom filter function
     */
    search(storeName, predicate) {
        return new Promise((resolve, reject) => {
            if (!this.db) {
                reject(new Error('Database not initialized'));
                return;
            }

            const transaction = this.db.transaction([storeName], 'readonly');
            const store = transaction.objectStore(storeName);
            const request = store.openCursor();
            const results = [];

            request.onsuccess = (event) => {
                const cursor = event.target.result;
                if (cursor) {
                    if (predicate(cursor.value)) {
                        results.push(cursor.value);
                    }
                    cursor.continue();
                } else {
                    resolve(results);
                }
            };

            request.onerror = () => {
                console.error(`[DBManager] Error searching ${storeName}:`, request.error);
                reject(request.error);
            };
        });
    },

    /**
     * Count records in a store
     */
    count(storeName) {
        return new Promise((resolve, reject) => {
            if (!this.db) {
                reject(new Error('Database not initialized'));
                return;
            }

            const transaction = this.db.transaction([storeName], 'readonly');
            const store = transaction.objectStore(storeName);
            const request = store.count();

            request.onsuccess = () => {
                resolve(request.result);
            };

            request.onerror = () => {
                reject(request.error);
            };
        });
    },

    /**
     * Get records modified since a specific timestamp
     */
    getModifiedSince(storeName, timestamp) {
        return new Promise((resolve, reject) => {
            if (!this.db) {
                reject(new Error('Database not initialized'));
                return;
            }

            const transaction = this.db.transaction([storeName], 'readonly');
            const store = transaction.objectStore(storeName);
            const index = store.index('updated_at');
            const range = IDBKeyRange.lowerBound(timestamp, true);
            const request = index.getAll(range);

            request.onsuccess = () => {
                resolve(request.result || []);
            };

            request.onerror = () => {
                reject(request.error);
            };
        });
    },

    /**
     * Get unsynced records (for sync queue processing)
     */
    getUnsynced(storeName) {
        return this.search(storeName, record => record.synced === false);
    },

    /**
     * Mark record as synced
     */
    markAsSynced(storeName, id) {
        return new Promise(async (resolve, reject) => {
            try {
                const record = await this.getById(storeName, id);
                if (record) {
                    record.synced = true;
                    await this.update(storeName, id, record);
                }
                resolve();
            } catch (error) {
                reject(error);
            }
        });
    },

    /**
     * Get or set sync metadata
     */
    async getSyncMetadata(key, defaultValue = null) {
        try {
            const metadata = await this.getById('sync_metadata', key);
            return metadata ? metadata.value : defaultValue;
        } catch (error) {
            return defaultValue;
        }
    },

    async setSyncMetadata(key, value) {
        const transaction = this.db.transaction(['sync_metadata'], 'readwrite');
        const store = transaction.objectStore('sync_metadata');
        return new Promise((resolve, reject) => {
            const request = store.put({ key, value, updated_at: new Date().toISOString() });
            request.onsuccess = () => resolve();
            request.onerror = () => reject(request.error);
        });
    },

    /**
     * Reset all data (for debugging/testing)
     */
    async resetAll() {
        console.warn('[DBManager] Resetting all data...');
        const storeNames = Object.keys(this.stores);
        for (const storeName of storeNames) {
            await this.clear(storeName);
        }
        console.log('[DBManager] All data cleared');
    },

    /**
     * Export all data (for backup)
     */
    async exportAll() {
        const data = {};
        const storeNames = Object.keys(this.stores);
        for (const storeName of storeNames) {
            data[storeName] = await this.getAll(storeName);
        }
        return data;
    },

    /**
     * Import data (for restore)
     */
    async importAll(data) {
        for (const [storeName, records] of Object.entries(data)) {
            if (this.stores[storeName]) {
                await this.bulkAdd(storeName, records);
            }
        }
        console.log('[DBManager] Data imported');
    },

    /**
     * Get storage usage estimate
     */
    async getStorageEstimate() {
        if ('storage' in navigator && 'estimate' in navigator.storage) {
            const estimate = await navigator.storage.estimate();
            return {
                usage: estimate.usage,
                quota: estimate.quota,
                percentUsed: ((estimate.usage / estimate.quota) * 100).toFixed(2)
            };
        }
        return null;
    }
};

// Auto-initialize on load
if (typeof window !== 'undefined') {
    window.addEventListener('load', async () => {
        try {
            await DBManager.init();
            console.log('[DBManager] ✓ Ready for offline operations');

            // Log storage usage
            const storage = await DBManager.getStorageEstimate();
            if (storage) {
                console.log(`[DBManager] Storage: ${(storage.usage / 1024 / 1024).toFixed(2)} MB / ${(storage.quota / 1024 / 1024).toFixed(2)} MB (${storage.percentUsed}%)`);
            }
        } catch (error) {
            console.error('[DBManager] Initialization failed:', error);
        }
    });
}
