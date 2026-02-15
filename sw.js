/**
 * GustoPOS Service Worker
 * Enhanced offline-first PWA with Background Sync
 */

const CACHE_VERSION = 'v4';
const CACHE_NAME = `gusto-pwa-${CACHE_VERSION}`;
const RUNTIME_CACHE = `gusto-runtime-${CACHE_VERSION}`;
const IMAGE_CACHE = `gusto-images-${CACHE_VERSION}`;

// App Shell - Critical files for offline operation
const APP_SHELL = [
    './',
    './index.php',
    './app.js',
    './db-manager.js',
    './network-manager.js',
    './sync-manager.js',
    './offline.js',
    './manifest.json',
    './printer.js'
];

// External CDN resources
const CDN_RESOURCES = [
    'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css',
    'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css',
    'https://cdn.jsdelivr.net/npm/chart.js',
    'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap'
];

// Install event - Cache app shell
self.addEventListener('install', event => {
    console.log('[SW] Installing service worker...');

    // Skip waiting to activate immediately
    self.skipWaiting();

    event.waitUntil(
        caches.open(CACHE_NAME)
            .then(cache => {
                console.log('[SW] Caching app shell');
                return cache.addAll(APP_SHELL.concat(CDN_RESOURCES));
            })
            .catch(error => {
                console.error('[SW] Cache installation failed:', error);
            })
    );
});

// Activate event - Clean up old caches
self.addEventListener('activate', event => {
    console.log('[SW] Activating service worker...');

    event.waitUntil(
        Promise.all([
            // Take control of all clients immediately
            clients.claim(),

            // Delete old caches
            caches.keys().then(cacheNames => {
                return Promise.all(
                    cacheNames
                        .filter(cacheName => {
                            return cacheName.startsWith('gusto-') &&
                                cacheName !== CACHE_NAME &&
                                cacheName !== RUNTIME_CACHE &&
                                cacheName !== IMAGE_CACHE;
                        })
                        .map(cacheName => {
                            console.log('[SW] Deleting old cache:', cacheName);
                            return caches.delete(cacheName);
                        })
                );
            })
        ])
    );
});

// Fetch event - Serve from cache or network with strategies
self.addEventListener('fetch', event => {
    const { request } = event;
    const url = new URL(request.url);

    // Skip non-GET requests
    if (request.method !== 'GET') {
        return;
    }

    // Skip chrome-extension and other non-http requests
    if (!url.protocol.startsWith('http')) {
        return;
    }

    // Strategy 1: Network First for API requests (dynamic data)
    if (url.pathname.includes('backend.php') || url.pathname.includes('api.php')) {
        event.respondWith(networkFirstStrategy(request));
        return;
    }

    // Strategy 2: Network First for PHP pages (to avoid ERR_FAILED on initial load)
    // PHP pages are dynamic and should always try network first
    if (url.pathname.endsWith('.php') || url.pathname === '/' || url.pathname.endsWith('/')) {
        event.respondWith(networkFirstStrategy(request));
        return;
    }

    // Strategy 3: Cache First for static JS and CSS files
    if (url.pathname.endsWith('.js') || url.pathname.endsWith('.css')) {
        event.respondWith(cacheFirstStrategy(request));
        return;
    }

    // Strategy 4: Stale While Revalidate for images
    if (
        url.pathname.includes('.jpg') ||
        url.pathname.includes('.png') ||
        url.pathname.includes('.webp') ||
        url.pathname.includes('.svg') ||
        url.hostname.includes('placehold.co') ||
        url.hostname.includes('ui-avatars.com')
    ) {
        event.respondWith(staleWhileRevalidateStrategy(request));
        return;
    }

    // Strategy 4: Cache First for CDN resources
    if (
        url.hostname.includes('cdn.') ||
        url.hostname.includes('cdnjs.') ||
        url.hostname.includes('googleapis.com') ||
        url.hostname.includes('gstatic.com')
    ) {
        event.respondWith(cacheFirstStrategy(request));
        return;
    }

    // Default: Network First
    event.respondWith(networkFirstStrategy(request));
});

/**
 * Network First Strategy
 * Try network first, fallback to cache on failure
 * Best for: Dynamic data, API responses
 */
async function networkFirstStrategy(request) {
    try {
        const networkResponse = await fetch(request);

        // Cache successful responses
        if (networkResponse && networkResponse.status === 200) {
            const responseClone = networkResponse.clone();
            caches.open(RUNTIME_CACHE).then(cache => cache.put(request, responseClone));
        }

        return networkResponse;
    } catch (error) {
        // Network failed, try cache
        const cachedResponse = await caches.match(request);

        if (cachedResponse) {
            console.log('[SW] Serving from cache (offline):', request.url);
            return cachedResponse;
        }

        // Return offline page for navigation requests
        if (request.mode === 'navigate') {
            return caches.match('./index.php');
        }

        // Return error for other requests
        return new Response('Offline and no cached version available', {
            status: 503,
            statusText: 'Service Unavailable',
            headers: new Headers({ 'Content-Type': 'text/plain' })
        });
    }
}

/**
 * Cache First Strategy
 * Try cache first, fallback to network
 * Best for: Static assets, app shell
 */
async function cacheFirstStrategy(request) {
    const cachedResponse = await caches.match(request);

    if (cachedResponse) {
        return cachedResponse;
    }

    try {
        const networkResponse = await fetch(request);

        // Cache the new response
        if (networkResponse && networkResponse.status === 200) {
            const responseClone = networkResponse.clone();
            caches.open(CACHE_NAME).then(cache => cache.put(request, responseClone));
        }

        return networkResponse;
    } catch (error) {
        console.error('[SW] Cache first failed:', error);
        // Fallback to 404 instead of 503 to allow graceful failure
        return new Response('Resource not found', {
            status: 404,
            statusText: 'Not Found'
        });
    }
}

/**
 * Stale While Revalidate Strategy
 * Return cached version immediately, update cache in background
 * Best for: Images, fonts, non-critical resources
 */
async function staleWhileRevalidateStrategy(request) {
    const cachedResponse = await caches.match(request);

    const fetchPromise = fetch(request).then(networkResponse => {
        if (networkResponse && networkResponse.status === 200) {
            const responseClone = networkResponse.clone();
            caches.open(IMAGE_CACHE).then(c => c.put(request, responseClone));
        }
        return networkResponse;
    }).catch(() => null);

    return cachedResponse || fetchPromise || new Response('Resource not available', {
        status: 404,
        statusText: 'Not Found'
    });
}

/**
 * Background Sync Event
 * Sync offline data when connection is restored
 */
self.addEventListener('sync', event => {
    console.log('[SW] Background sync triggered:', event.tag);

    if (event.tag === 'sync-offline-data') {
        event.waitUntil(syncOfflineData());
    }
});

async function syncOfflineData() {
    try {
        console.log('[SW] Syncing offline data in background...');

        // Notify all clients to trigger sync
        const clients = await self.clients.matchAll();
        clients.forEach(client => {
            client.postMessage({
                type: 'BACKGROUND_SYNC',
                action: 'sync-offline-data'
            });
        });

        return Promise.resolve();
    } catch (error) {
        console.error('[SW] Background sync failed:', error);
        return Promise.reject(error);
    }
}

/**
 * Message handler for client communication
 */
self.addEventListener('message', event => {
    console.log('[SW] Message received:', event.data);

    if (event.data && event.data.type === 'SKIP_WAITING') {
        self.skipWaiting();
    }

    if (event.data && event.data.type === 'CACHE_URLS') {
        event.waitUntil(
            caches.open(RUNTIME_CACHE)
                .then(cache => cache.addAll(event.data.urls))
        );
    }

    if (event.data && event.data.type === 'CLEAR_CACHE') {
        event.waitUntil(
            caches.keys().then(cacheNames => {
                return Promise.all(
                    cacheNames.map(cacheName => caches.delete(cacheName))
                );
            })
        );
    }
});

/**
 * Push notification handler (future feature)
 */
self.addEventListener('push', event => {
    const data = event.data ? event.data.json() : { title: 'GustoPOS', body: 'New notification' };

    const options = {
        body: data.body,
        icon: './assets/icon-192.png',
        badge: './assets/badge-72.png',
        vibrate: [200, 100, 200],
        data: data
    };

    event.waitUntil(
        self.registration.showNotification(data.title, options)
    );
});

/**
 * Notification click handler
 */
self.addEventListener('notificationclick', event => {
    event.notification.close();

    event.waitUntil(
        clients.openWindow('/')
    );
});

console.log('[SW] Service Worker loaded');
