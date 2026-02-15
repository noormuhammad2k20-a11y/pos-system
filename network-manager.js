/**
 * GustoPOS Network Manager
 * Monitors online/offline status and connection quality
 * Provides event-driven architecture for network state changes
 */

const NetworkManager = {
    online: navigator.onLine,
    listeners: [],
    connectionQuality: 'unknown',
    lastOnlineTime: null,
    lastOfflineTime: null,
    checkInterval: null,

    /**
     * Initialize network monitoring
     */
    init() {
        console.log('[NetworkManager] Initializing...');

        // Listen to browser online/offline events
        window.addEventListener('online', () => this.handleOnline());
        window.addEventListener('offline', () => this.handleOffline());

        // Initial state
        this.online = navigator.onLine;
        this.updateUI();

        // Periodic connectivity check (every 30 seconds)
        this.checkInterval = setInterval(() => this.checkConnectivity(), 30000);

        // Initial connectivity check
        this.checkConnectivity();

        console.log('[NetworkManager] Initial status:', this.online ? 'ONLINE' : 'OFFLINE');
    },

    /**
     * Check actual connectivity (not just browser state)
     * Pings server to verify real connection
     */
    async checkConnectivity() {
        if (!navigator.onLine) {
            this.connectionQuality = 'offline';
            return false;
        }

        const startTime = performance.now();

        try {
            // Ping server with small request
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 5000);

            const response = await fetch('backend.php?action=ping', {
                method: 'GET',
                cache: 'no-cache',
                signal: controller.signal
            });

            clearTimeout(timeoutId);
            const endTime = performance.now();
            const latency = endTime - startTime;

            if (response.ok) {
                // Determine connection quality based on latency
                if (latency < 200) {
                    this.connectionQuality = 'excellent';
                } else if (latency < 500) {
                    this.connectionQuality = 'good';
                } else if (latency < 1000) {
                    this.connectionQuality = 'fair';
                } else {
                    this.connectionQuality = 'poor';
                }

                console.log(`[NetworkManager] Connection quality: ${this.connectionQuality} (${latency.toFixed(0)}ms)`);
                return true;
            } else {
                this.connectionQuality = 'offline';
                return false;
            }
        } catch (error) {
            console.warn('[NetworkManager] Connectivity check failed:', error.message);
            this.connectionQuality = 'offline';
            return false;
        }
    },

    /**
     * Handle online event
     */
    handleOnline() {
        console.log('[NetworkManager] ✓ Connection restored');
        this.online = true;
        this.lastOnlineTime = new Date();
        this.updateUI();
        this.notifyListeners('online');
        this.checkConnectivity(); // Verify actual connectivity
    },

    /**
     * Handle offline event
     */
    handleOffline() {
        console.log('[NetworkManager] ✗ Connection lost');
        this.online = false;
        this.lastOfflineTime = new Date();
        this.connectionQuality = 'offline';
        this.updateUI();
        this.notifyListeners('offline');
    },

    /**
     * Check if currently online
     */
    isOnline() {
        return this.online && navigator.onLine;
    },

    /**
     * Get connection quality
     */
    getConnectionQuality() {
        return this.connectionQuality;
    },

    /**
     * Subscribe to network state changes
     */
    subscribe(callback) {
        this.listeners.push(callback);
        return () => {
            this.listeners = this.listeners.filter(cb => cb !== callback);
        };
    },

    /**
     * Notify all listeners of state change
     */
    notifyListeners(event) {
        this.listeners.forEach(callback => {
            try {
                callback(event, {
                    online: this.online,
                    quality: this.connectionQuality,
                    lastOnlineTime: this.lastOnlineTime,
                    lastOfflineTime: this.lastOfflineTime
                });
            } catch (error) {
                console.error('[NetworkManager] Listener error:', error);
            }
        });
    },

    /**
     * Update UI to reflect network status
     */
    updateUI() {
        const banner = document.getElementById('offline-banner');
        const syncButton = document.getElementById('offline-sync-btn');
        const statusIndicator = document.getElementById('network-status-indicator');

        if (this.online) {
            // Hide offline banner
            if (banner) {
                banner.classList.add('hidden');
                banner.classList.remove('show');
            }

            // Show sync button if there are pending changes (will be handled by SyncManager)

            // Update status indicator
            if (statusIndicator) {
                statusIndicator.className = 'network-status online';
                statusIndicator.title = `Online - ${this.connectionQuality}`;
                statusIndicator.innerHTML = '<i class="fas fa-wifi"></i>';
            }
        } else {
            // Show offline banner
            if (banner) {
                banner.classList.remove('hidden');
                banner.classList.add('show');
            }

            // Update status indicator
            if (statusIndicator) {
                statusIndicator.className = 'network-status offline';
                statusIndicator.title = 'Offline';
                statusIndicator.innerHTML = '<i class="fas fa-wifi-slash"></i>';
            }
        }
    },

    /**
     * Wait for online status (useful for retry logic)
     */
    waitForOnline(timeout = 60000) {
        return new Promise((resolve, reject) => {
            if (this.isOnline()) {
                resolve();
                return;
            }

            const timeoutId = setTimeout(() => {
                unsubscribe();
                reject(new Error('Timeout waiting for online status'));
            }, timeout);

            const unsubscribe = this.subscribe((event) => {
                if (event === 'online') {
                    clearTimeout(timeoutId);
                    unsubscribe();
                    resolve();
                }
            });
        });
    },

    /**
     * Format offline duration for display
     */
    getOfflineDuration() {
        if (this.online || !this.lastOfflineTime) {
            return null;
        }

        const now = new Date();
        const duration = now - this.lastOfflineTime;
        const minutes = Math.floor(duration / 60000);
        const hours = Math.floor(minutes / 60);

        if (hours > 0) {
            return `${hours}h ${minutes % 60}m`;
        } else if (minutes > 0) {
            return `${minutes}m`;
        } else {
            return 'Just now';
        }
    },

    /**
     * Cleanup
     */
    destroy() {
        if (this.checkInterval) {
            clearInterval(this.checkInterval);
        }
        window.removeEventListener('online', this.handleOnline);
        window.removeEventListener('offline', this.handleOffline);
    }
};

// Auto-initialize on load
if (typeof window !== 'undefined') {
    window.addEventListener('load', () => {
        NetworkManager.init();
    });
}
