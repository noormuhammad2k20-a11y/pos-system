/**
 * GustoPOS Offline Manager
 * Handles saving orders to IndexedDB when offline and syncing them when online.
 */

const OfflineManager = {
    dbName: 'GustoPOS_DB',
    storeName: 'offline_orders',
    dbVersion: 1,
    db: null,

    init() {
        return new Promise((resolve, reject) => {
            const request = indexedDB.open(this.dbName, this.dbVersion);

            request.onerror = (event) => {
                console.error("IndexedDB error:", event.target.error);
                reject("DB Error");
            };

            request.onupgradeneeded = (event) => {
                const db = event.target.result;
                if (!db.objectStoreNames.contains(this.storeName)) {
                    db.createObjectStore(this.storeName, { keyPath: "id", autoIncrement: true });
                }
            };

            request.onsuccess = (event) => {
                this.db = event.target.result;
                this.checkPendingOrders();
                resolve(this.db);
            };
        });
    },

    saveOrder(orderData) {
        return new Promise((resolve, reject) => {
            if (!this.db) { reject("DB not initialized"); return; }

            const transaction = this.db.transaction([this.storeName], "readwrite");
            const store = transaction.objectStore(this.storeName);
            const request = store.add({
                ...orderData,
                savedAt: new Date().toISOString()
            });

            request.onsuccess = () => {
                showToast('Order saved OFFLINE', 'warning');
                this.updateSyncUI(true);
                resolve(true);
            };

            request.onerror = () => reject("Save failed");
        });
    },

    async syncOrders() {
        if (!navigator.onLine) {
            showToast('Still offline', 'error');
            return;
        }

        const orders = await this.getAllOrders();
        if (orders.length === 0) {
            showToast('No pending orders', 'info');
            return;
        }

        let syncedCount = 0;
        showToast(`Syncing ${orders.length} orders...`, 'info');

        for (const order of orders) {
            try {
                // Remove ID to let server generate it
                const { id, savedAt, ...payload } = order;

                const res = await api('place_order', payload); // Uses global api function
                if (res.success) {
                    await this.deleteOrder(order.id);
                    syncedCount++;
                }
            } catch (e) {
                console.error("Sync failed for order", order, e);
            }
        }

        if (syncedCount === orders.length) {
            showToast('All offline orders synced!', 'success');
            this.updateSyncUI(false);
        } else {
            showToast(`Synced ${syncedCount}/${orders.length} orders`, 'warning');
        }
    },

    getAllOrders() {
        return new Promise((resolve) => {
            const transaction = this.db.transaction([this.storeName], "readonly");
            const store = transaction.objectStore(this.storeName);
            const request = store.getAll();
            request.onsuccess = () => resolve(request.result);
        });
    },

    deleteOrder(id) {
        return new Promise((resolve) => {
            const transaction = this.db.transaction([this.storeName], "readwrite");
            const store = transaction.objectStore(this.storeName);
            store.delete(id);
            transaction.oncomplete = () => resolve();
        });
    },

    checkPendingOrders() {
        this.getAllOrders().then(orders => {
            this.updateSyncUI(orders.length > 0);
        });
    },

    updateSyncUI(hasPending) {
        const btn = document.getElementById('offline-sync-btn');
        if (btn) {
            btn.style.display = hasPending ? 'flex' : 'none';
            if (hasPending) {
                btn.classList.add('pulse-animation');
            }
        }
    }
};

// Initialize on load and setup automated sync
window.addEventListener('load', async () => {
    await OfflineManager.init();

    // Auto-sync when connection returns
    window.addEventListener('online', () => {
        console.log('[OfflineManager] System back online. Triggering sync...');
        OfflineManager.syncOrders();
    });

    // Periodic heartbeat sync (every 5 minutes) if online
    setInterval(() => {
        if (navigator.onLine) {
            OfflineManager.checkPendingOrders();
            OfflineManager.getAllOrders().then(orders => {
                if (orders.length > 0) OfflineManager.syncOrders();
            });
        }
    }, 300000);
});
