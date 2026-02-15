/**
 * GustoPOS Enterprise Frontend JavaScript
 * Simplified cart - Total only, Table-based orders
 */

const API_URL = 'backend.php';
let cart = [];
let currentOrderId = null;
let currentTableId = null;
let categories = [];
let products = [];
let settings = {};
let businessDayActive = false; // Business Day state
let currentBusinessDayId = null; // Track current ID
let businessDayStartTime = null; // Used for clock

let shiftUpdateInterval = null;
let dashChart = null;
let ws = null;

// Global Settings
let currencySymbol = ''; // Default, will be updated from settings
let printerConfig = { ip: '192.168.1.200', type: 'network' }; // Default

function formatCurrency(amount) {
    const symbol = window.currencySymbol || settings.currency_symbol || '';
    return `${symbol}${parseFloat(amount).toFixed(2)}`;
}

// ============ ULTRA-FAST INITIALIZATION ============
let wsRetryCount = 0;
const maxWsRetries = 0; // Disabled for offline dev

function initWebSocket() {
    if (wsRetryCount >= maxWsRetries) return;

    try {
        // Silent connection attempt
        ws = new WebSocket('ws://localhost:8080');

        ws.onopen = () => {
            console.log('WebSocket Connected');
            wsRetryCount = 0;
        };

        ws.onmessage = (event) => {
            try {
                const msg = JSON.parse(event.data);
                if (msg.action === 'new_order') {
                    showToast('New Custom Order: ' + msg.data.order_number, 'info');
                    if (document.getElementById('kitchen-view').classList.contains('active')) loadKitchenOrders();
                }
                else if (['refresh_tables', 'table_locked', 'table_unlocked'].includes(msg.action)) {
                    if (document.getElementById('tables-view').classList.contains('active')) loadTables();
                }
                else if (msg.action === 'refresh_kitchen') {
                    if (document.getElementById('kitchen-view').classList.contains('active')) loadKitchenOrders();
                }
            } catch (e) { /* Ignore parse errors */ }
        };

        ws.onclose = () => {
            wsRetryCount++;
            if (wsRetryCount < maxWsRetries) {
                setTimeout(initWebSocket, 5000); // Fixed 5s delay to reduce spam frequency
            } else {
                console.log("Live updates unavailable (WebSocket offline)");
            }
        };

        ws.onerror = (e) => {
            // Prevent default console error spam if possible
            e.preventDefault();
        };

    } catch (e) {
        // Silently fail if WebSocket constructor throws
    }
}

function logoutUser() {
    localStorage.removeItem('gusto_token');
    window.location.href = 'logout.php';
}

function debounce(func, delay) {
    let timeout;
    return (...args) => {
        clearTimeout(timeout);
        timeout = setTimeout(() => func(...args), delay);
    };
}

// ============ INITIALIZATION ============
document.addEventListener('DOMContentLoaded', async function () {
    await loadSettings();
    applySettings(); // Apply settings dynamically to UI
    updateClock();
    setInterval(updateClock, 1000);
    // setInterval(updateShiftTimer, 1000); // Legacy removed
    // initWebSocket(); // Disabled to reduce console spam

    // Check for offline orders
    if (window.OfflineManager) window.OfflineManager.init();

    if (currentUserRole === 'admin') {
        loadDashboard();
        // loadNotifications(); // Disabled until implemented
        // setInterval(loadNotifications, 30000);
    } else {
        switchView('pos');
    }

    loadCategories();
    initTheme();
    // checkShiftStatus(); // Removed legacy interval
    // setInterval(checkShiftStatus, 60000); // Removed legacy interval
});


// ============ API HELPER ============
async function api(action, data = {}, method = 'GET') {
    let url = `${API_URL}?action=${action}`;
    const options = {
        method: method,
        headers: {
            'Authorization': `Bearer ${localStorage.getItem('gusto_token')}`,
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
        }
    };

    if (method === 'GET') {
        const params = new URLSearchParams(data);
        if (params.toString()) url += `&${params.toString()}`;
    } else {
        if (data instanceof FormData) {
            options.body = data;
        } else {
            const formData = new FormData();
            for (const key in data) {
                formData.append(key, typeof data[key] === 'object' ? JSON.stringify(data[key]) : data[key]);
            }
            options.body = formData;
        }
    }

    try {
        const response = await fetch(url, options);

        // Handle HTTP Errors
        if (!response.ok) {
            let errorMsg = 'Server Error';
            try {
                const errData = await response.json();
                if (errData.message) errorMsg = errData.message;
            } catch (e) {
                const text = await response.text();
                if (text) errorMsg = 'Server: ' + text.substring(0, 150);
            }
            throw new Error(errorMsg);
        }

        const text = await response.text();
        try {
            return JSON.parse(text);
        } catch (e) {
            console.error('Invalid JSON:', text);
            throw new Error('Server (Invalid JSON): ' + text.substring(0, 100).replace(/<[^>]*>?/gm, ''));
        }

    } catch (error) {
        console.error('API Error:', error);

        // --- OFFLINE LOGIC ---
        if (!navigator.onLine && (action === 'create_order' || action === 'place_order')) {
            if (window.OfflineManager) {
                await window.OfflineManager.saveOrder(data);
                return { success: true, order_number: 'OFFLINE', offline: true };
            }
        }

        return { success: false, message: error.message || 'Connection error' };
    }
}

// ============ UI HELPERS ============

// ============ SHIFT MANAGEMENT HELPERS - REMOVED ============


// ensureActiveShift, showNoShiftModal, updateShiftTimer removed

function renderPagination(containerId, pagination, callbackName) {
    const container = typeof containerId === 'string' ? document.getElementById(containerId) : containerId;
    if (!container) return;

    if (!pagination || pagination.total_records == 0) {
        container.innerHTML = '';
        container.style.display = 'none';
        return;
    }

    container.style.display = 'flex';
    const totalPages = pagination.total_pages || 1;
    const currentPage = pagination.current_page || 1;
    const totalRecords = pagination.total_records || 0;
    const from = pagination.from || 1;
    const to = pagination.to || totalRecords;

    let html = `
        <div class="pagination-info me-auto">
            <span class="text-muted small">Showing <strong>${from}-${to}</strong> of <strong>${totalRecords}</strong></span>
        </div>
        <div class="pagination-controls d-flex gap-2">
            <button class="page-btn shadow-sm" ${currentPage <= 1 ? 'disabled' : ''} 
                onclick="${callbackName}(${currentPage - 1})">
                <i class="fas fa-chevron-left"></i>
            </button>
    `;

    if (totalPages > 1) {
        for (let i = 1; i <= totalPages; i++) {
            if (i === 1 || i === totalPages || (i >= currentPage - 2 && i <= currentPage + 2)) {
                html += `
                    <button class="page-btn shadow-sm ${i === currentPage ? 'active' : ''}" 
                        onclick="${callbackName}(${i})">${i}</button>
                `;
            } else if (i === currentPage - 3 || i === currentPage + 3) {
                html += `<span class="px-2 align-self-center">...</span>`;
            }
        }
    }

    html += `
            <button class="page-btn shadow-sm" ${currentPage >= totalPages ? 'disabled' : ''} 
                onclick="${callbackName}(${currentPage + 1})">
                <i class="fas fa-chevron-right"></i>
            </button>
        </div>
    `;

    container.innerHTML = html;
}




async function loadSettings() {
    const result = await api('get_settings');
    if (result.success) {
        settings = result.data;
        // Global Printer Initialization
        if (window.Printer) {
            const type = settings.printer_type || 'spooler';
            const width = parseInt(settings.paper_width) || 80;
            window.Printer.init(type, width);
        }
    }
}










// ============ APPLY SETTINGS DYNAMICALLY ============
function applySettings() {
    // Apply Currency Symbol globally
    window.currencySymbol = settings.currency_symbol || 'Rs ';
    document.querySelectorAll('.currency-symbol').forEach(el => el.textContent = window.currencySymbol);

    // Apply Table Colors as CSS variables
    document.documentElement.style.setProperty('--table-color-free', settings.table_color_free || '#12b76a');
    document.documentElement.style.setProperty('--table-color-busy', settings.table_color_busy || '#f04438');
    document.documentElement.style.setProperty('--table-color-reserved', settings.table_color_reserved || '#f79009');
    document.documentElement.style.setProperty('--table-color-payment', settings.table_color_payment || '#0d6efd');

    // Apply Tax & Fees globally
    window.taxRate = parseFloat(settings.tax_rate) || 0;
    window.serviceChargeRate = parseFloat(settings.service_charge_rate) || 0;
    window.packagingFee = parseFloat(settings.packaging_fee) || 0;
    window.deliveryFee = parseFloat(settings.delivery_fee) || 0;

    // Apply Cart Display Preferences
    window.showSubtotal = settings.show_subtotal !== 'false';
    window.enableTax = settings.enable_tax !== 'false';
    window.enableServiceCharge = settings.enable_service_charge !== 'false';

    // Apply Low Stock Threshold
    window.lowStockThreshold = parseInt(settings.low_stock_threshold) || 5;

    // Apply Permission-based Visibility for Cashiers
    if (typeof currentUserRole !== 'undefined' && currentUserRole === 'cashier') {
        applyPermissionRestrictions();
    }

    // Apply Date Format
    window.dateFormat = settings.date_format || 'DD/MM/YYYY';

    // Apply Stock Deduction Setting
    window.stockDeductOn = settings.stock_deduct_on || 'payment_complete';
    window.blockOrderZeroStock = settings.block_order_zero_stock === 'true' || settings.block_order_zero_stock === true;

    // Apply Print Settings
    window.autoPrintKot = settings.auto_print_kot === 'true' || settings.auto_print_kot === true;
    window.kotPrintCopies = parseInt(settings.kot_print_copies) || 1;

    // Apply Rounding
    window.roundTotalMethod = settings.round_total_method || 'none';

    // Order Settings Expansion
    window.allowPriceOverride = settings.allow_price_override === 'true' || settings.allow_price_override === true;
    window.orderCancelGracePeriod = parseInt(settings.order_cancel_grace_period) || 5;

    console.log('Settings applied:', {
        currency: window.currencySymbol,
        tax: window.taxRate + '%',
        priceOverride: window.allowPriceOverride
    });
}



function applyPermissionRestrictions() {
    // Hide sidebar items based on cashier permissions
    const navItems = document.querySelectorAll('.nav-item[data-view]');
    navItems.forEach(item => {
        const view = item.getAttribute('data-view');
        let shouldHide = false;

        switch (view) {
            case 'pos':
                shouldHide = settings.cashier_access_pos === 'false';
                break;
            case 'tables':
                shouldHide = settings.cashier_access_floor === 'false';
                break;
            case 'reports':
            case 'zreport':
            case 'export':
                shouldHide = settings.cashier_view_reports === 'false' || !settings.cashier_view_reports;
                break;
            case 'settings':
                shouldHide = settings.cashier_access_settings === 'false' || !settings.cashier_access_settings;
                break;
        }

        if (shouldHide) {
            item.style.display = 'none';
        }
    });

    // Hide export buttons if not allowed
    if (settings.cashier_export_data !== 'true') {
        document.querySelectorAll('.export-btn, [onclick*="export"]').forEach(btn => {
            if (!btn.closest('#settings-view')) btn.style.display = 'none';
        });
    }

    // Role-based Restrictions
    if (currentUser.role === 'cashier') {
        const restricted = [
            '.btn-delete-product',
            '#nav-settings',
            '#btn-void-order-auth',
            '#nav-staff',
            '.admin-only' // General class for other restricted elements
        ];
        restricted.forEach(selector => {
            document.querySelectorAll(selector).forEach(el => el.style.display = 'none');
        });

        // Hide specific buttons by ID if they exist
        const settingsBtn = document.getElementById('settings-btn');
        if (settingsBtn) settingsBtn.style.display = 'none';
    }
    if (settings.hide_financial_cashier === 'true' || settings.hide_financial_cashier === true) {
        document.querySelectorAll('.financial-data, .revenue-card, .profit-card').forEach(el => {
            el.style.display = 'none';
        });
    }
}

// Format currency with setting
function formatCurrency(amount) {
    const symbol = window.currencySymbol || settings.currency_symbol || 'Rs ';
    return symbol + parseFloat(amount || 0).toFixed(2);
}

// Format date with setting
function formatDate(dateStr) {
    if (!dateStr) return '';
    const date = new Date(dateStr);
    const format = window.dateFormat || settings.date_format || 'DD/MM/YYYY';

    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const year = date.getFullYear();

    switch (format) {
        case 'MM/DD/YYYY': return `${month}/${day}/${year}`;
        case 'YYYY-MM-DD': return `${year}-${month}-${day}`;
        default: return `${day}/${month}/${year}`;
    }
}



// Apply rounding based on setting
function applyRounding(amount) {
    const method = window.roundTotalMethod || settings.round_total_method || 'none';
    switch (method) {
        case '0.5': return Math.round(amount * 2) / 2;
        case '1': return Math.round(amount);
        default: return amount;
    }
}

// Check if stock should block order
function checkStockAvailability(productId, quantity) {
    if (!window.blockOrderZeroStock) return true;
    const product = products.find(p => p.id === productId);
    if (!product) return true;
    return parseInt(product.stock_quantity || 0) >= quantity;
}

// Check stock status for UI warnings (low/out)
function checkStockStatus(productId, requestedQty) {
    if (!globalInventoryData || globalInventoryData.length === 0) return 'ok';

    // Find inventory item linked to this product (if any)
    const product = products.find(p => p.id == productId);
    if (!product || !product.linked_inventory_id) return 'ok';

    const inventoryItem = globalInventoryData.find(i => i.id == product.linked_inventory_id);
    if (!inventoryItem) return 'ok';

    if (inventoryItem.quantity < requestedQty) return 'out';
    if (inventoryItem.quantity < requestedQty + 5) return 'low'; // Warning threshold

    return 'ok';
}

// Get table status color from settings
function getTableStatusColor(status) {
    switch (status) {
        case 'free':
        case 'available':
            return settings.table_color_free || '#12b76a';
        case 'busy':
        case 'occupied':
            return settings.table_color_busy || '#f04438';
        case 'reserved':
            return settings.table_color_reserved || '#f79009';
        case 'payment':
        case 'needs_payment':
            return settings.table_color_payment || '#0d6efd';
        default:
            return '#6c757d';
    }
}

// ============ NAVIGATION ============
function switchView(viewName, el) {
    // Role-based access control (client-side)
    const adminOnlyViews = ['dashboard', 'history', 'deleted', 'expenses', 'inventory', 'menu', 'waiters', 'recipes', 'suppliers', 'settings', 'settings-management', 'export', 'zreport', 'kitchen'];
    if (currentUserRole === 'cashier' && adminOnlyViews.includes(viewName)) {
        showToast('Access denied: Admin only', 'error');
        return;
    }

    document.querySelectorAll('.view-section').forEach(v => v.classList.remove('active'));
    const target = document.getElementById(viewName + '-view');
    if (target) target.classList.add('active');

    const sidebar = document.getElementById('sidebar');
    const overlay = document.getElementById('sidebar-overlay');
    if (sidebar.classList.contains('show-sidebar')) {
        sidebar.classList.remove('show-sidebar');
        overlay.classList.remove('active');
    }

    if (el && el.tagName === 'A') {
        document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
        el.classList.add('active');
    }

    document.getElementById('cart-panel').classList.remove('open');

    switch (viewName) {
        case 'dashboard': loadDashboard(); break;
        case 'settings-management': if (typeof loadManagementSettings === 'function') loadManagementSettings(); break;
        case 'pos': loadProducts(); loadTableOptions(); break;
        case 'tables': loadTables(); break;
        case 'history': loadOrders(); break;
        case 'deleted': loadDeletedOrders(); break;
        case 'expenses': loadExpenses(); break;
        case 'inventory': loadInventory(); break;
        case 'menu': loadMenuItems(); break;
        case 'waiters': loadStaff(); break;
        // case 'kitchen': loadKitchenOrders(); break; // Disabled Kitchen View UI
        case 'recipes': loadRecipes(); break;
        case 'suppliers': loadSuppliers(); break;

        case 'export': initExportPage(); break;
        case 'zreport': loadZReportPage(); break;
    }
}

function toggleSidebar() { document.body.classList.toggle('sidebar-collapsed'); }
function toggleMobileSidebar() {
    document.getElementById('sidebar').classList.toggle('show-sidebar');
    document.getElementById('sidebar-overlay').classList.toggle('active');
}


function updateChart(data) {
    const ctx = document.getElementById('revenueChart').getContext('2d');
    const labels = data.map(d => d.day ? d.day.substring(0, 3) : '');
    const values = data.map(d => parseFloat(d.total));

    if (revenueChart) revenueChart.destroy();

    revenueChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels.length ? labels : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            datasets: [{ label: 'Sales ($)', data: values.length ? values : [0, 0, 0, 0, 0, 0, 0], backgroundColor: '#FF6B00', borderRadius: 6 }]
        },
        options: {
            responsive: true, maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: { y: { beginAtZero: true, grid: { borderDash: [5, 5] } }, x: { grid: { display: false } } }
        }
    });
}

// ============ POS - CATEGORIES & PRODUCTS ============
async function loadCategories() {
    const result = await api('get_categories');
    if (!result.success) return;

    categories = result.data;
    let html = '<div class="cat-btn active" onclick="filterCat(\'all\', this)"><i class="fas fa-th-large"></i> All Items</div>';
    categories.forEach(c => {
        html += `<div class="cat-btn" onclick="filterCat('${c.id}', this)">${c.name}</div>`;
    });
    document.getElementById('category-scroll').innerHTML = html;

    let optHtml = '<option value="">Select Category...</option>';
    let tableHtml = '';
    categories.forEach(c => {
        optHtml += `<option value="${c.id}">${c.name}</option>`;
        tableHtml += `<tr>
            <td class="fw-bold ps-4">${c.name}</td>
            <td class="text-end pe-4">
                <button class="btn btn-sm btn-light border shadow-sm me-1" onclick="editCategory(${c.id})" title="Edit"><i class="fas fa-edit text-primary"></i></button>
                <button class="btn btn-sm btn-light border shadow-sm" onclick="deleteCategory(${c.id})" title="Delete"><i class="fas fa-trash text-danger"></i></button>
            </td>
        </tr>`;
    });
    const catSelect = document.getElementById('item-category');
    if (catSelect) catSelect.innerHTML = optHtml;

    const catEditSelect = document.getElementById('edit-item-category');
    if (catEditSelect) catEditSelect.innerHTML = optHtml;

    const catTable = document.getElementById('categories-tbody');
    if (catTable) catTable.innerHTML = tableHtml || '<tr><td colspan="2" class="text-center text-muted">No categories found</td></tr>';
}

async function saveCategory() {
    const name = document.getElementById('cat-name').value;
    if (!name) { showToast('Name is required', 'error'); return; }
    const res = await api('add_category', { name }, 'POST');
    if (res.success) {
        showToast('Category created');
        closeModal('add-category-modal');
        document.getElementById('cat-name').value = '';
        loadCategories();
    }
}

function filterCat(catId, el) {
    document.querySelectorAll('.cat-btn').forEach(b => b.classList.remove('active'));
    el.classList.add('active');
    loadProducts(catId);
}

async function deleteCategory(id) {
    if (await UI.confirm('Delete Category?', 'Are you sure you want to delete this category?')) {
        const res = await api('delete_category', { id }, 'POST');
        if (res.success) {
            showToast('Category deleted');
            loadCategories();
            loadMenuItems(); // Refresh menu table if open
        } else {
            showToast(res.message, 'error');
        }
    }
}

function editCategory(id) {
    const cat = categories.find(c => c.id == id);
    if (!cat) return;
    document.getElementById('cat-edit-id').value = cat.id;
    document.getElementById('cat-edit-name').value = cat.name;
    openModal('edit-category-modal');
}

async function saveCategoryEdit() {
    const id = document.getElementById('cat-edit-id').value;
    const name = document.getElementById('cat-edit-name').value;
    if (!name) { showToast('Name is required', 'error'); return; }

    const res = await api('update_category', { id, name }, 'POST');
    if (res.success) {
        showToast('Category updated');
        closeModal('edit-category-modal');
        loadCategories();
        loadMenuItems();
    }
}

async function loadProducts(categoryId = 'all') {
    const result = await api('get_products', { category_id: categoryId });
    if (!result.success) return;

    products = result.data;
    let html = '';
    products.forEach(p => {
        let stockVisuals = '';
        let isOutOfStock = false;
        let onClickAction = `onclick="addToCart(${p.id})"`;
        let cardClasses = 'prod-card';

        // Check Stock
        if (typeof globalInventoryData !== 'undefined' && globalInventoryData.length > 0 && p.linked_inventory_id) {
            const invItem = globalInventoryData.find(i => i.id == p.linked_inventory_id);
            if (invItem) {
                const qty = parseFloat(invItem.quantity);
                if (qty <= 0) {
                    isOutOfStock = true;
                    cardClasses += ' out-of-stock';
                    onClickAction = ''; // Remove click
                    stockVisuals += `<div class="sold-out-badge"><i class="fas fa-ban"></i> SOLD OUT</div>`;
                } else if (qty < 5) {
                    stockVisuals += `<span class="badge bg-warning text-dark low-stock-badge">${qty} Left</span>`;
                }
            }
        }

        html += `<div class="${cardClasses}" ${onClickAction}>
            ${stockVisuals}
            <img src="${p.image || 'https://placehold.co/150x100/png?text=Item'}" class="prod-img" loading="lazy" onerror="this.src='https://placehold.co/150x100/png?text=Item'">
            <div class="prod-title">${p.name}</div>
            <div class="prod-price">${formatCurrency(p.price)}</div>
            ${!isOutOfStock ? '<div class="add-btn-icon"><i class="fas fa-plus"></i></div>' : ''}
        </div>`;
    });
    document.getElementById('product-grid').innerHTML = html || '<div class="text-muted p-3">No products found</div>';
}

async function loadTableOptions() {
    const result = await api('get_tables');
    if (!result.success) return;

    let html = '<option value="">Walk-in Customer</option>';
    result.data.forEach(t => {
        // Show only free tables, OR show the table if it's currently selected (from floor plan)
        if (t.status === 'free' || (currentTableId && t.id == currentTableId)) {
            html += `<option value="${t.id}">${t.name} (${t.seats} seats)</option>`;
        }
    });
    const tableSelect = document.getElementById('cart-table');
    if (tableSelect) {
        tableSelect.innerHTML = html;

        // Add change listener to sync currentTableId with dropdown (only once)
        if (!tableSelect.dataset.listenerAdded) {
            tableSelect.addEventListener('change', function () {
                const selectedValue = this.value;
                currentTableId = selectedValue ? parseInt(selectedValue) : null;
                console.log('[cart-table change] Updated currentTableId to:', currentTableId);
            });
            tableSelect.dataset.listenerAdded = 'true';
        }
    }
}

// ============ CART MANAGEMENT ============
function addToCart(productId) {
    // Removed ensureActiveShift() to allow immediate item selection
    const product = products.find(p => p.id == productId);
    if (!product) return;

    // Proactive Stock Warning (Strict Mode)
    // Calculate total quantity including what's already in cart
    const existingItem = cart.find(item => item.id == productId);
    const currentCartQty = existingItem ? existingItem.quantity : 0;
    const proposedQty = currentCartQty + 1;

    // We need to check against backend/inventory data. 
    // Since checkStockAvailability is async or complex in frontend, 
    // we use the data already loaded in products list or make a quick check.
    // NOTE: For strict mode, we should ideally have stock in 'products' array.
    // Assuming 'products' array has 'stock_qty' or we fetch it. 
    // If not available locally, we might need a sync or check.
    // FOR NOW: We will use the existing checkStockAvailability if it's robust, 
    // otherwise we rely on the backend rejection at checkout.
    // However, user asked for "Proactive Warning".

    // Let's assume we can check against globalInventoryData if linked.
    // Or simplified: fetch stock for this product.
    // Optimally: checkStockAvailability function should handle this.

    if (globalInventoryData.length > 0) { // If inventory loaded
        // This is complex because products != inventory. 
        // We'll rely on the existing checkStockAvailability function which seems to call API or check logic.
        // Awaiting it might be slow for UI. 
        // Strategy: strict check mainly happens at checkout, but we add a visual "Low Stock" badge.
    }

    // Using the function found in grep search earlier:
    // function checkStockAvailability(productId, quantity) { ... }

    if (!checkStockAvailability(productId, proposedQty)) {
        showToast('Insufficient stock!', 'error');
        return; // Block addition
    }

    if (existingItem) {
        existingItem.quantity++;
    } else {
        cart.push({ id: product.id, name: product.name, price: parseFloat(product.price), quantity: 1, image: product.image });
    }
    renderCart();
    showToast(`${product.name} added`);
}

function updateQuantity(productId, delta) {
    const item = cart.find(i => i.id == productId);
    if (!item) return;
    item.quantity += delta;
    if (item.quantity <= 0) cart = cart.filter(i => i.id != productId);
    renderCart();
}

function removeFromCart(productId) {
    cart = cart.filter(i => i.id != productId);
    renderCart();
}

function editItemPrice(productId) {
    if (!window.allowPriceOverride) {
        showToast('Price override is disabled', 'error');
        return;
    }
    const item = cart.find(i => i.id == productId);
    if (!item) return;

    const newPrice = prompt(`Enter new price for ${item.name}:`, item.price);
    if (newPrice !== null && !isNaN(newPrice) && newPrice !== '') {
        const parsedPrice = parseFloat(newPrice);
        if (parsedPrice >= 0) {
            item.price = parsedPrice;
            renderCart();
            showToast('Price updated');
        } else {
            showToast('Invalid price', 'error');
        }
    }
}

function clearCart() {
    cart = [];
    currentOrderId = null;
    currentTableId = null;
    window.isIncrementalUpdate = false; // RESET FLAG
    document.getElementById('order-number').textContent = '#NEW';
    const tableSelect = document.getElementById('cart-table');
    if (tableSelect) tableSelect.value = '';
    renderCart();
}

function renderCart() {
    const container = document.getElementById('cart-items');
    const summaryContainer = document.getElementById('cart-summary-breakdown');
    const symbol = window.currencySymbol || '';

    // Render cart items
    if (cart.length === 0) {
        container.innerHTML = '<div class="cart-empty"><i class="fas fa-shopping-basket d-block"></i><div>Cart is empty</div><small class="text-muted">Click products to add</small></div>';
        // Build empty cart summary - Only Total
        summaryContainer.innerHTML = `
            <div class="d-flex justify-content-between small text-muted mb-2 pt-2 border-top">
                <span class="fw-bold h5 mb-0">Total</span>
                <span class="fw-bold h5 mb-0 text-primary">${symbol}0.00</span>
            </div>`;
        document.getElementById('pay-btn').textContent = 'PAY ' + symbol + '0.00';
        return;
    }

    let html = '';
    cart.forEach(item => {
        const itemTotal = item.price * item.quantity;
        // Low Stock Warning in Cart
        const stockStatus = checkStockStatus(item.id, item.quantity);
        const warning = stockStatus === 'low' ? '<span class="badge bg-warning text-dark ms-2">Low Stock</span>' : '';

        const priceClickAction = window.allowPriceOverride ? `onclick="editItemPrice(${item.id})"` : '';
        const priceStyle = window.allowPriceOverride ? 'cursor:pointer; text-decoration:dotted underline;' : '';

        html += `<div class="cart-item">
            <div style="flex:1;"><div class="fw-bold">${item.name} ${warning}</div><div class="text-muted text-xs" ${priceClickAction} style="${priceStyle}">${symbol}${item.price.toFixed(2)}</div></div>
            <div class="d-flex align-items-center gap-3">
                <div class="cart-controls">
                    <button class="qty-btn" onclick="updateQuantity(${item.id}, -1)"><i class="fas fa-minus"></i></button>
                    <span class="qty-val">${item.quantity}</span>
                    <button class="qty-btn" onclick="updateQuantity(${item.id}, 1)"><i class="fas fa-plus"></i></button>
                </div>
                <div class="fw-bold">${symbol}${itemTotal.toFixed(2)}</div>
                <i class="fas fa-times text-danger cursor-pointer" style="font-size:0.8rem;" onclick="removeFromCart(${item.id})"></i>
            </div>
        </div>`;
    });
    container.innerHTML = html;

    // === STRICT CONDITIONAL RENDERING: Build summary based on settings ===

    // Calculate values
    const subtotal = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);

    // Check which settings are enabled
    const showSubtotal = (window.showSubtotal !== false);
    const showTax = (window.enableTax !== false) && (window.taxRate > 0);
    const showService = (window.enableServiceCharge !== false) && (window.serviceChargeRate > 0);

    // Only calculate if enabled
    const taxAmount = showTax ? (subtotal * window.taxRate) / 100 : 0;
    const serviceAmount = showService ? (subtotal * window.serviceChargeRate) / 100 : 0;
    const additionalFees = (window.packagingFee || 0) + (window.deliveryFee || 0);

    let total = subtotal + taxAmount + serviceAmount + additionalFees;
    total = applyRounding(total);

    // BUILD summary HTML conditionally - NO DOM elements for disabled settings
    let summaryHTML = '';

    // Subtotal row - ONLY if enabled
    if (showSubtotal) {
        summaryHTML += `
            <div class="d-flex justify-content-between small text-muted mb-1">
                <span>Subtotal</span>
                <span>${symbol}${subtotal.toFixed(2)}</span>
            </div>`;
    }

    // Tax row - ONLY if enabled AND rate > 0
    if (showTax) {
        summaryHTML += `
            <div class="d-flex justify-content-between small text-muted mb-1">
                <span>Tax (${window.taxRate}%)</span>
                <span>${symbol}${taxAmount.toFixed(2)}</span>
            </div>`;
    }

    // Service Charge row - ONLY if enabled AND rate > 0
    if (showService) {
        summaryHTML += `
            <div class="d-flex justify-content-between small text-muted mb-1">
                <span>Service Charge (${window.serviceChargeRate}%)</span>
                <span>${symbol}${serviceAmount.toFixed(2)}</span>
            </div>`;
    }

    // Total row - ALWAYS displayed
    summaryHTML += `
        <div class="d-flex justify-content-between small text-muted mb-2 pt-2 border-top">
            <span class="fw-bold h5 mb-0">Total</span>
            <span class="fw-bold h5 mb-0 text-primary">${symbol}${total.toFixed(2)}</span>
        </div>`;

    // Inject the built HTML
    summaryContainer.innerHTML = summaryHTML;
    document.getElementById('pay-btn').textContent = 'PAY ' + symbol + total.toFixed(2);

    // Total row always displays (no changes needed)
}

// ============ ORDERS ============
async function sendToKitchen() {
    // Silent Session Check
    if (!await checkBusinessDayStatus()) {
        window.location.href = 'login.php';
        return;
    }

    if (cart.length === 0) { showToast('Cart is empty', 'error'); return; }

    const tableSelect = document.getElementById('cart-table');
    const tableId = tableSelect?.value || null;
    const customerName = tableId ? tableSelect.options[tableSelect.selectedIndex].text : 'Walk-in';

    const subtotal = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    const taxAmount = (subtotal * (window.taxRate || 0)) / 100;
    const serviceAmount = (subtotal * (window.serviceChargeRate || 0)) / 100;
    const additionalFees = (window.packagingFee || 0) + (window.deliveryFee || 0);
    let total = applyRounding(subtotal + taxAmount + serviceAmount + additionalFees);

    const orderType = tableId ? 'dine_in' : 'walk_in';

    const result = await api('create_order', {
        customer_name: customerName, table_id: tableId, order_type: orderType,
        items: cart, subtotal: subtotal.toFixed(2), tax: taxAmount.toFixed(2),
        service_charge: serviceAmount.toFixed(2), packaging_charge: window.packagingFee?.toFixed(2) || '0.00',
        delivery_fee: window.deliveryFee?.toFixed(2) || '0.00',
        total: total.toFixed(2), status: 'pending'
    }, 'POST');

    if (result.success) {
        currentOrderId = result.order_id;
        document.getElementById('order-number').textContent = result.order_number;
        showToast('Sent to Kitchen');
        if (settings.auto_print_kot) printKOT(); // Always call to clear queue (printKOT handles filtering)
        clearCart();
        loadTables();
    } else {
        showToast('Error: ' + result.message, 'error');
    }
}

async function payOrder(event, isFinalCheckout = false) {
    // 1. STOP PAGE RELOAD
    if (event) {
        event.preventDefault();
        event.stopPropagation();
    }

    // 2. CHECK BUSINESS DAY
    const isOpen = await checkBusinessDayStatus();
    if (!isOpen) {
        alert("Action Blocked: No active Business Day found. Please open a day from the backend or check your connection.");
        // window.location.href = 'login.php'; // Uncomment only after testing
        return;
    }

    // 3. PROCEED WITH PAYMENT
    // (Ensure your existing cart processing logic is here)
    if (cart.length === 0) {
        showToast('Cart is empty', 'warning');
        return;
    }

    const tableSelect = document.getElementById('cart-table');

    // ROBUST TABLE ID EXTRACTION:
    // 1. First priority: currentTableId (set from floor plan click)
    // 2. Second: dropdown value (set manually by user)
    // 3. Ensure both are synced
    let tableId = null;

    if (currentTableId) {
        tableId = currentTableId;
    } else if (tableSelect?.value && tableSelect.value !== '') {
        tableId = parseInt(tableSelect.value);
        currentTableId = tableId; // Sync global
    }

    // Final validation - make sure dropdown matches currentTableId
    if (tableId && tableSelect) {
        tableSelect.value = String(tableId);
    }

    const customerName = tableId ?
        (tableSelect?.options[tableSelect.selectedIndex]?.text || `Table ${tableId}`) : 'Walk-in';

    console.log('[payOrder] currentTableId:', currentTableId, 'dropdown value:', tableSelect?.value, 'final tableId:', tableId);

    const subtotal = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    const taxAmount = (subtotal * (window.taxRate || 0)) / 100;
    const serviceAmount = (subtotal * (window.serviceChargeRate || 0)) / 100;
    const additionalFees = (window.packagingFee || 0) + (window.deliveryFee || 0);
    let total = applyRounding(subtotal + taxAmount + serviceAmount + additionalFees);

    // Check if this is a walk-in (no table selected)
    const isWalkIn = !tableId || tableId === '' || tableId === 'null' || tableId === '0' || tableId === 0;
    console.log('[payOrder] isWalkIn:', isWalkIn);

    const orderType = isWalkIn ? 'walk_in' : 'dine_in';

    // FORCE CHECKOUT for Walk-ins (they always pay immediately)
    if (isWalkIn) isFinalCheckout = true;

    if (isWalkIn) {
        // Walk-in: Complete order immediately and print receipt
        const result = await api('create_order', {
            customer_name: 'Walk-in', table_id: null, order_type: orderType,
            items: cart, subtotal: subtotal.toFixed(2), tax: taxAmount.toFixed(2),
            service_charge: serviceAmount.toFixed(2),
            packaging_charge: window.packagingFee?.toFixed(2) || '0.00',
            delivery_fee: window.deliveryFee?.toFixed(2) || '0.00',
            total: total.toFixed(2), status: 'completed'
        }, 'POST');

        if (result.success) {
            showToast('Payment Successful! ' + result.order_number);

            // Wait for print before clearing
            try {
                // Conditional Print: Only if Final Checkout OR Walk-in
                if (isFinalCheckout || (isWalkIn && orderType === 'walk_in')) {
                    await printReceipt(result.order_id); // Counter Printer

                    // Auto-Print KOT for Kitchen (Kitchen Printer)
                    if (isWalkIn && (window.autoPrintKot || settings.auto_print_kot)) {
                        setTimeout(async () => {
                            await printKOT(); // Kitchen Printer
                        }, 1000);
                    }
                }
            } catch (printError) {
                console.error("Print failed but order saved:", printError);
                showToast('Order saved, but printing failed.', 'warning');
            }

            clearCart();
            // Stay on POS screen - No redirect
        } else {
            showToast('Error: ' + result.message, 'error');
        }
    } else {
        // Dine-In: Save/Update order
        // IF isFinalCheckout is true -> Status 'completed' + Print
        // IF isFinalCheckout is false -> Status 'pending' + NO Print

        const status = isFinalCheckout ? 'completed' : 'pending';

        const result = await api('create_order', {
            order_id: currentOrderId || null, // Explicitly target existing order if known
            incremental: window.isIncrementalUpdate || false, // FLAG: Tell backend to ADD quantities
            customer_name: customerName,
            table_id: tableId,  // EXPLICITLY sending table_id
            order_type: 'dine_in', // EXPLICITLY forced to dine_in 
            items: cart,
            subtotal: subtotal.toFixed(2),
            tax: taxAmount.toFixed(2),
            service_charge: serviceAmount.toFixed(2),
            packaging_charge: window.packagingFee?.toFixed(2) || '0.00',
            delivery_fee: window.deliveryFee?.toFixed(2) || '0.00',
            total: total.toFixed(2),
            status: status
        }, 'POST');

        if (result.success) {
            // DO NOT call update_table_status here - backend already set current_order_id
            // Table stays 'busy' until Complete & Clear is clicked
            // Extract clean table name from dropdown (e.g., "Table 1 (4 seats)" -> "Table 1")
            const tableName = tableSelect?.options[tableSelect.selectedIndex]?.text?.split(' (')[0] || `Table ${tableId}`;
            const msg = result.merged
                ? `Items added to ${tableName}'s order (${result.order_number})`
                : `Order saved to ${tableName} (${result.order_number})`;
            showToast(msg);

            // PRINT ONLY IF FINAL CHECKOUT
            if (isFinalCheckout) {
                try {
                    await printReceipt(result.order_id);
                } catch (e) { console.error(e); }

                // If completed, we might want to clear table? 
                // Currently 'Complete & Clear' is a separate button on Floor Plan. 
                // But if user clicks "Checkout" here, maybe they expect table to free up?
                // For now, adhering to strict "Add Items" logic: Just update order.
                // If status is completed, backend likely completed the order but didn't free table?
                // Backend 'create_order' doesn't free table automatically. 
                // 'complete_order' API frees table. 
                // So 'payOrder' with 'completed' might leave table busy but with a completed order?
                // The User requirement is: "Action: Checkout... trigger print function".
                // I will stick to printing.
            }

            // IMMEDIATE REFRESH OF TABLES
            // This ensures the red "Busy" color appears instantly
            loadTables();

            clearCart();
            switchView('tables');
        } else {
            showToast('Error: ' + result.message, 'error');
        }
    }
}


async function holdOrder() {
    if (cart.length === 0) { showToast('Cart is empty', 'error'); return; }

    const total = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    const tableSelect = document.getElementById('cart-table');
    const customerName = tableSelect?.value ? tableSelect.options[tableSelect.selectedIndex].text : 'Walk-in';

    const result = await api('create_order', {
        customer_name: customerName, items: cart, subtotal: total.toFixed(2),
        tax: '0', total: total.toFixed(2), status: 'held'
    }, 'POST');

    if (result.success) {
        showToast('Order Parked');
        clearCart();
        loadHeldOrders();
    }
}

async function loadHeldOrders() {
    const result = await api('get_held_orders');
    const container = document.getElementById('held-orders-list');

    if (!result.success || result.data.length === 0) {
        container.innerHTML = '<div class="p-3 text-muted text-center">No held orders</div>';
        return;
    }

    let html = '';
    result.data.forEach(o => {
        html += `<a href="#" class="list-group-item list-group-item-action p-3" onclick="retrieveOrder(${o.id})">
            <div class="d-flex w-100 justify-content-between">
                <h6 class="mb-1 fw-bold">${o.customer_name}</h6>
                <small>${o.minutes_ago} mins ago</small>
            </div>
            <p class="mb-1 text-muted small">${o.items_summary || 'Items...'}</p>
            <small class="fw-bold text-primary">$${parseFloat(o.total).toFixed(2)}</small>
        </a>`;
    });
    container.innerHTML = html;
}

async function retrieveOrder(orderId) {
    window.isIncrementalUpdate = false; // RESET FLAG (Loading full order means we are in Sync mode)
    const result = await api('retrieve_order', { id: orderId }, 'POST');
    if (!result.success || !result.data) { showToast('Failed to retrieve order', 'error'); return; }

    const order = result.data;
    cart = order.items.map(item => ({
        id: item.product_id, name: item.product_name,
        price: parseFloat(item.price), quantity: parseInt(item.quantity)
    }));

    currentOrderId = order.id;
    document.getElementById('order-number').textContent = order.order_number || '#' + order.id;
    if (order.table_id) {
        currentTableId = order.table_id;
        const tableSelect = document.getElementById('cart-table');
        if (tableSelect) tableSelect.value = order.table_id;
    }

    renderCart();
    closeModal('held-orders-modal');
    showToast('Order Retrieved');
}

async function loadOrders(page = 1) {
    const date = document.getElementById('history-date')?.value || '';
    const search = document.getElementById('history-search')?.value || '';

    const result = await api('get_orders', { page, limit: 10, status: 'completed', date, search });
    const tbody = document.getElementById('history-tbody');
    const pagination = document.getElementById('history-pagination');

    if (!result.success) {
        if (tbody) tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted">Failed to load orders</td></tr>';
        return;
    }

    let html = '';
    result.data.forEach(o => {
        html += `<tr>
            <td>${o.order_number || '#' + o.id}</td>
            <td>${new Date(o.created_at).toLocaleString()}</td>
            <td>${o.customer_name || 'Walk-in'}</td>
            <td class="fw-bold">$${parseFloat(o.total).toFixed(2)}</td>
            <td><span class="badge bg-success-subtle text-success">${o.status.toUpperCase()}</span></td>
            <td class="text-center align-middle">
                <div class="sales-action-cell">
                    <button class="btn-pro btn-view-pro" onclick="viewInvoice(${o.id})" title="View">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                    </button>
                    <button class="btn-pro btn-print-pro" onclick="printReceipt(${o.id})" title="Print">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 6 2 18 2 18 9"></polyline><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path><rect x="6" y="14" width="12" height="8"></rect></svg>
                    </button>
                    <button class="btn-pro btn-delete-pro" onclick="showVoidModal(${o.id})" title="Delete">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
                    </button>
                </div>
            </td>
        </tr>`;
    });
    if (tbody) tbody.innerHTML = html || '<tr><td colspan="6" class="text-center p-3 text-muted">No orders found</td></tr>';

    if (result.pagination) {
        if (pagination) renderPagination(pagination, result.pagination, (p) => loadOrders(p));
    }
}

// Ensure loadDeletedOrders handles the new statuses
async function loadDeletedOrders(page = 1) {
    const tbody = document.getElementById('deleted-tbody');
    if (!tbody) return;

    // Use custom flag for backend to fetch all void types
    const result = await api('get_orders', {
        page,
        limit: 10,
        status: 'deleted_all'
    });

    if (result.success) {
        if (result.data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted">No deleted orders found</td></tr>';
            return;
        }

        let html = '';
        result.data.forEach(o => {
            let statusBadge = '<span class="badge bg-danger">Deleted</span>';
            if (o.status === 'void_waste') statusBadge = '<span class="badge bg-danger">Void (Waste)</span>';
            if (o.status === 'void_return') statusBadge = '<span class="badge bg-warning text-dark">Void (Return)</span>';

            html += `
                <tr>
                    <td>${o.order_number}</td>
                    <td>${o.customer_name || 'Unknown'}</td>
                    <td>${formatCurrency(o.total)}</td>
                    <td>${o.delete_reason || '-'}</td>
                    <td>${statusBadge}</td>
                </tr>
            `;
        });
        tbody.innerHTML = html;
        if (typeof renderPagination === 'function') {
            renderPagination('deleted-pagination', result.pagination, 'loadDeletedOrders');
        }
    }
}


// ============ VOID / DELETE ORDER ============
// ============ VOID / RETURN ORDER ============
async function showVoidModal(orderId) {
    document.getElementById('void-order-id').value = orderId;
    document.getElementById('void-reason').value = '';
    document.getElementById('void-return-stock').checked = true;
    document.getElementById('void-total-refund').textContent = formatCurrency(0);

    const tbody = document.getElementById('void-items-list');
    tbody.innerHTML = '<tr><td colspan="4" class="text-center p-3">Loading items...</td></tr>';

    openModal('void-modal');

    // Fetch order details
    const res = await api('get_order', { id: orderId });
    if (!res.success || !res.data) {
        tbody.innerHTML = '<tr><td colspan="4" class="text-center text-danger">Failed to load items</td></tr>';
        return;
    }

    const order = res.data;
    let html = '';

    if (order.items && order.items.length > 0) {
        order.items.forEach(item => {
            const maxQty = parseFloat(item.quantity);
            const price = parseFloat(item.price);

            html += `
            <tr data-item-id="${item.id}" data-price="${price}">
                <td>
                    <div class="fw-bold small">${item.product_name}</div>
                    <div class="text-muted x-small">$${price.toFixed(2)}</div>
                </td>
                <td class="text-center align-middle">${maxQty}</td>
                <td class="text-center align-middle">
                    <input type="number" class="form-control form-control-sm text-center void-qty-input" 
                        min="0" max="${maxQty}" step="0.01" value="0" 
                        onchange="calculateVoidRefund()" onkeyup="calculateVoidRefund()">
                </td>
                <td class="text-end align-middle fw-bold return-amt">$0.00</td>
            </tr>`;
        });
        tbody.innerHTML = html;
    } else {
        tbody.innerHTML = '<tr><td colspan="4" class="text-center">No items found</td></tr>';
    }
}

function calculateVoidRefund() {
    let total = 0;
    document.querySelectorAll('#void-items-list tr').forEach(row => {
        const price = parseFloat(row.dataset.price);
        const qtyInput = row.querySelector('.void-qty-input');
        const amtDisplay = row.querySelector('.return-amt');

        let qty = parseFloat(qtyInput.value) || 0;
        const max = parseFloat(qtyInput.max);

        if (qty < 0) qty = 0;
        if (qty > max) { qty = max; qtyInput.value = max; }

        const lineTotal = qty * price;
        total += lineTotal;
        amtDisplay.textContent = formatCurrency(lineTotal);
    });
    document.getElementById('void-total-refund').textContent = formatCurrency(total);
}

async function processVoidReturn() {
    const orderId = document.getElementById('void-order-id').value;
    const reason = document.getElementById('void-reason').value;
    const returnStock = document.getElementById('void-return-stock').checked;

    const itemsToReturn = [];
    document.querySelectorAll('#void-items-list tr').forEach(row => {
        const qty = parseFloat(row.querySelector('.void-qty-input').value) || 0;
        if (qty > 0) {
            itemsToReturn.push({
                id: row.dataset.itemId,
                qty: qty
            });
        }
    });

    if (itemsToReturn.length === 0) {
        showToast('Please select at least one item to return', 'error');
        return;
    }

    if (!reason) {
        showToast('Please enter a reason', 'error');
        return;
    }

    if (!await UI.confirm('Confirm Return?', `Refund amount: ${document.getElementById('void-total-refund').textContent}. Proceed?`)) {
        return;
    }

    const res = await api('return_order_items', {
        order_id: orderId,
        items: itemsToReturn,
        reason: reason,
        return_stock: returnStock
    }, 'POST');

    if (res.success) {
        showToast(`Return processed. Refund: ${formatCurrency(res.refund_amount)}`);
        closeModal('void-modal');
        loadOrders(); // Refresh history

        // Refresh deleted sales if active
        if (document.getElementById('deleted-view') && document.getElementById('deleted-view').classList.contains('active')) {
            loadDeletedOrders();
        }
    } else {
        showToast(res.message || 'Return failed', 'error');
    }
}

async function restoreOrder(orderId) {
    const result = await api('restore_order', { id: orderId }, 'POST');
    if (result.success) { showToast('Order restored'); loadDeletedOrders(); }
}

async function viewInvoice(orderId) {
    const result = await api('get_order', { id: orderId });
    if (!result.success || !result.data) return;

    const o = result.data;
    const date = new Date(o.created_at);

    let itemsHtml = '';
    if (o.items) {
        o.items.forEach(item => {
            itemsHtml += `<div class="invoice-row"><span>${item.quantity} x ${item.product_name}</span><span>$${(item.price * item.quantity).toFixed(2)}</span></div>`;
        });
    }

    document.getElementById('invoice-title').textContent = 'Invoice ' + (o.order_number || '#' + o.id);

    // Additional Charges Rows
    let chargesHtml = '';
    if (parseFloat(o.tax) > 0) chargesHtml += `<div class="invoice-row"><span>Tax:</span><span>$${parseFloat(o.tax).toFixed(2)}</span></div>`;
    if (parseFloat(o.service_charge) > 0) chargesHtml += `<div class="invoice-row"><span>Service Chg:</span><span>$${parseFloat(o.service_charge).toFixed(2)}</span></div>`;
    if (parseFloat(o.packaging_charge) > 0) chargesHtml += `<div class="invoice-row"><span>Packaging:</span><span>$${parseFloat(o.packaging_charge).toFixed(2)}</span></div>`;
    if (parseFloat(o.delivery_fee) > 0) chargesHtml += `<div class="invoice-row"><span>Delivery:</span><span>$${parseFloat(o.delivery_fee).toFixed(2)}</span></div>`;

    document.getElementById('invoice-content').innerHTML = `
        <div class="text-center mb-3">
            <h6 class="fw-bold">${settings.restaurant_name || 'GUSTO BURGER'}</h6>
            <div>${settings.restaurant_address || ''}</div>
            <div>${settings.restaurant_phone || ''}</div>
        </div>
        <div class="invoice-divider"></div>
        <div class="invoice-row"><span>Date:</span><span>${date.toLocaleDateString()} ${date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span></div>
        <div class="invoice-row"><span>Order:</span><span>${o.order_number || '#' + o.id}</span></div>
        <div class="invoice-divider"></div>
        ${itemsHtml}
        <div class="invoice-divider"></div>
        <div class="invoice-row"><span>Subtotal:</span><span>$${parseFloat(o.subtotal).toFixed(2)}</span></div>
        ${chargesHtml}
        <div class="invoice-divider"></div>
        <div class="invoice-row fw-bold h5"><span>TOTAL</span><span>$${parseFloat(o.total).toFixed(2)}</span></div>
        <div class="invoice-divider"></div>
        <div class="text-center">${settings.receipt_footer || 'Thank you for visiting!'}</div>
    `;
    openModal('invoice-modal');
}

// ============ THERMAL PRINTING ============
async function printReceipt(orderId) {
    const result = await api('get_receipt_data', { order_id: orderId });
    if (!result.success) return;

    // Use Hardware-Agnostic Printer Module with raw structured data
    showToast('Printing receipt...', 'info');
    await Printer.print(result, 'counter'); // Explicit Counter Role
}

async function printKOT() {
    const result = await api('get_pending_kot');
    if (!result.success || result.data.length === 0) return;

    const items = result.data;
    const itemIds = items.map(i => i.id);
    const tokenNo = items[0].token_number || '#';
    const isTableOrder = !!items[0].table_name; // If table_name exists, it's a table order

    // REQUIREMENT: KOT is exclusively for Walk-in Customers.
    // If this is a Table order, we SKIP printing but MUST mark items as printed to clear the queue.
    if (isTableOrder) {
        console.log("Skipping KOT print for Table Order (Walk-in Only Rule)");
        await api('mark_kot_printed', { item_ids: itemIds }, 'POST');
        return;
    }

    // Use Hardware Printer if configured
    if (settings.printer_type && settings.printer_type !== 'spooler') {
        // Construct data to match Printer.formatReceipt expected structure { order, settings }
        const kotData = {
            settings: {
                restaurant_name: '*** KITCHEN ORDER ***',
                restaurant_address: `Table: ${items[0].table_name || 'Walk-in'}`,
                restaurant_phone: `TOKEN: ${tokenNo}`,
                custom_footer_note: `Kitchen Copy – Token [${tokenNo}]`
            },
            order: {
                order_number: tokenNo,
                token_number: tokenNo, // CRITICAL FIX: Ensure token_number matches tokenNo
                order_type: 'walk_in', // Fixes "Type: Dine-In" label on KOT
                created_at: new Date().toLocaleString(),
                table_name: items[0].table_name || 'Walk-in',
                items: items.map(i => ({
                    product_name: i.product_name + (i.notes ? ` (${i.notes})` : ''),
                    quantity: i.quantity,
                    price: 0
                })),
                subtotal: 0,
                tax: 0,
                service_charge: 0,
                total: 0
            }
        };

        console.log("Printing KOT for Walk-in...", kotData);
        await Printer.print(kotData, 'kitchen'); // STRICTLY pass 'kitchen' role
        await api('mark_kot_printed', { item_ids: itemIds }, 'POST');
        return;
    }

    let itemsHtml = '';
    items.forEach(item => {
        itemsHtml += `<div style="font-size:14px;margin:4px 0;"><strong>${item.quantity}x</strong> ${item.product_name}${item.notes ? ` (${item.notes})` : ''}</div>`;
    });

    // Check if logo should be included on KOT
    const showLogoOnKot = settings.print_logo_on_kot === 'true' || settings.print_logo_on_kot === true;
    const logoHtml = (showLogoOnKot && settings.restaurant_logo)
        ? `<div class="center"><img src="${settings.restaurant_logo}" style="width: 100%; max-width: 200px; height: auto; display: block; margin: 0 auto 5px auto; filter: grayscale(1);"></div>`
        : '';

    const kotHtml = `<!DOCTYPE html><html><head><style>
        @page { size: 80mm auto; margin: 0; }
        body { font-family: 'Courier New', Courier, monospace; font-size: 13px; width: 80mm; margin: 0; padding: 8px; color: #000; }
        .center { text-align: center; }
        .bold { font-weight: bold; }
        .divider { border-top: 1px dashed #000; margin: 8px 0; }
        .token-box { border: 2px solid #000; padding: 5px; margin: 5px 0; font-size: 20px; text-align: center; font-weight: bold; }
    </style></head><body>
        ${logoHtml}
        <div class="center bold" style="font-size:18px;">*** KITCHEN ORDER ***</div>
        <div class="token-box">TOKEN NO: ${tokenNo}</div>
        <div class="divider"></div>
        <div>Table: ${items[0].table_name || 'Walk-in'}</div>
        <div>Date/Time: ${new Date().toLocaleString()}</div>
        <div class="divider"></div>
        <div class="bold" style="margin-bottom:5px;">ITEMS:</div>
        ${itemsHtml}
        <div class="divider"></div>
        <div class="center bold" style="margin-top:10px;">Kitchen Copy – Token [${tokenNo}]</div>
        <script>window.onload = function() { window.print(); window.close(); }</script>
    </body></html>`;

    // Print TWO copies as requested
    for (let i = 0; i < 2; i++) {
        const printWindow = window.open('', '_blank', 'width=400,height=400');
        if (printWindow) {
            printWindow.document.write(kotHtml);
            printWindow.document.close();
        }
        if (i === 0) await new Promise(r => setTimeout(r, 600)); // Short delay between prints
    }

    await api('mark_kot_printed', { item_ids: itemIds }, 'POST');
}

// ============ KITCHEN DISPLAY ============
async function loadKitchenOrders() {
    const result = await api('get_pending_kot');
    const container = document.getElementById('kitchen-orders');

    if (!result.success || result.data.length === 0) {
        container.innerHTML = '<div class="text-center text-muted p-5"><i class="fas fa-check-circle fa-3x mb-3"></i><h5>All caught up!</h5></div>';
        return;
    }

    const grouped = {};
    result.data.forEach(item => {
        const key = item.order_id;
        if (!grouped[key]) grouped[key] = { order_number: item.order_number, table_name: item.table_name, minutes_ago: item.minutes_ago, items: [] };
        grouped[key].items.push(item);
    });

    let html = '';
    Object.values(grouped).forEach(order => {
        let itemsHtml = order.items.map(i => `<div class="mb-1"><strong>${i.quantity}x</strong> ${i.product_name}</div>`).join('');
        html += `<div class="col-md-4 col-lg-3">
            <div class="card border-warning h-100">
                <div class="card-header bg-warning-subtle d-flex justify-content-between">
                    <span class="fw-bold">${order.order_number}</span>
                    <span class="text-muted">${order.minutes_ago}m</span>
                </div>
                <div class="card-body">${itemsHtml}</div>
                <div class="card-footer bg-transparent">
                    <small class="text-muted">${order.table_name || 'Walk-in'}</small>
                </div>
            </div>
        </div>`;
    });
    container.innerHTML = `<div class="row g-3">${html}</div>`;
}

// ============ TABLES ============
function getTableStatusColor(status) {
    if (!settings) return '#12b76a';
    switch (status) {
        case 'busy':
        case 'occupied':
            return settings.table_color_busy || '#f04438';
        case 'needs_payment':
        case 'payment':
            return settings.table_color_payment || '#0d6efd';
        case 'reserved':
            return settings.table_color_reserved || '#f79009';
        default:
            return settings.table_color_free || '#12b76a';
    }
}

async function loadTables() {
    const result = await api('get_tables');
    const container = document.getElementById('tables-container');
    if (!result.success) { container.innerHTML = '<div class="text-muted">Failed to load tables</div>'; return; }

    let html = '';
    result.data.forEach(t => {
        // Get dynamic color from settings
        let statusColor = getTableStatusColor(t.status);
        let icon = 'fa-couch', statusBadge = '', timer = '';
        let statusLabel = 'Free';
        const isLocked = t.locked_by && t.locked_by != currentUserId; // Need to ensure currentUserId is available

        // Check locked status
        if (t.locked_by) {
            if (isLocked) {
                statusColor = '#6c757d'; // Grey for locked
                icon = 'fa-lock';
                statusLabel = `Locked by ${t.locked_user_name || 'User'}`;
            } else {
                // Locked by ME
                statusLabel += ' (You)';
            }
        }

        if (!isLocked) {
            if (t.status === 'busy' || t.status === 'occupied') {
                icon = 'fa-utensils';
                statusLabel = 'Busy';
                // Timer removed as per request
            } else if (t.status === 'needs_payment' || t.status === 'payment') {
                icon = 'fa-receipt';
                statusLabel = 'Pay';
            } else if (t.status === 'reserved') {
                icon = 'fa-calendar-check';
                statusLabel = 'Reserved';
            }
        }

        statusBadge = `<div class="badge mt-1" style="background: ${statusColor}20; color: ${statusColor}; border: 1px solid ${statusColor}30;">${statusLabel}</div>`;

        html += `<div class="table-card ${isLocked ? 'locked' : ''}" onclick="openTableOptions(${t.id}, '${t.name}', '${t.status}', ${isLocked}, ${t.current_order_id || 'null'})" data-table-id="${t.id}" style="border-left: 4px solid ${statusColor}; ${isLocked ? 'opacity: 0.7; cursor: not-allowed;' : ''}">
            <div class="table-icon" style="color: ${statusColor};"><i class="fas ${icon}"></i></div>
            <div class="table-name">${t.name}</div>
            <div class="table-meta">${t.seats} Seats ${t.waiter_name ? '• ' + t.waiter_name : ''}</div>
            ${statusBadge}
        </div>`;
    });
    container.innerHTML = html || '<div class="text-muted p-3">No tables yet. Click Add Table to create one.</div>';
}

async function openTableOptions(tableId, tableName, status, isLocked = false, currentOrderId = null) {
    if (isLocked) {
        showToast('Table is currently locked by another user', 'error');
        return;
    }

    // CRITICAL: Set currentTableId FIRST before any async operations
    currentTableId = tableId;
    window.selectedTableOrderId = currentOrderId; // Save for addItemsToTable logic
    console.log('[openTableOptions] Set currentTableId:', currentTableId, 'Order:', currentOrderId);

    // Attempt to lock table (don't block table selection if lock fails)
    const lockRes = await api('lock_table', { id: tableId }, 'POST');
    if (!lockRes.success) {
        console.warn('[openTableOptions] Lock failed:', lockRes.message);
        // Don't return - let user still work with table, just show warning
        // showToast(lockRes.message || 'Note: Table lock failed', 'warning');
        loadTables(); // Refresh to see current status
    }

    document.getElementById('table-modal-title').textContent = tableName + ' Options';

    // Show/Hide Delete Button
    const deleteBtn = document.getElementById('btn-delete-table');
    if (deleteBtn) {
        // Only Admins can delete tables, and only if they are FREE
        if (currentUserRole === 'admin' && status === 'free') {
            deleteBtn.style.display = 'block';
        } else {
            deleteBtn.style.display = 'none';
        }
    }

    // Add unlock listener when modal closes
    const modal = document.getElementById('table-options-modal');
    modal.dataset.lockedTableId = tableId;

    openModal('table-options-modal');
}

function closeTableOptions() {
    const modal = document.getElementById('table-options-modal');
    const tableId = modal.dataset.lockedTableId;
    if (tableId) {
        api('unlock_table', { id: tableId }, 'POST'); // Fire and forget
        delete modal.dataset.lockedTableId;
    }
    closeModal('table-options-modal');
}

async function confirmDeleteTable() {
    if (await UI.confirm('Delete Table?', 'Are you sure you want to delete this table? This action cannot be undone.')) {
        const result = await api('delete_table', { table_id: currentTableId }, 'POST');
        if (result.success) {
            showToast('Table deleted successfully');
            closeTableOptions();
            loadTables();
            // Switch back to tables view if we were there
            if (document.getElementById('tables-view').classList.contains('active')) {
                loadTables();
            }
        } else {
            showToast(result.message || 'Failed to delete table', 'error');
        }
    }
}

async function addItemsToTable() {
    closeTableOptions();

    const selectedTableId = currentTableId;
    const existingOrderId = window.selectedTableOrderId;

    // RESTRICT SINGLE ORDER: If existing order, load it!
    if (existingOrderId && existingOrderId !== 'null' && existingOrderId !== 0) {
        console.log('[addItemsToTable] Adding to existing order (Incremental):', existingOrderId);

        // OLD LOGIC: Load existing order (Bad for "Add Items" flow)
        // await retrieveOrder(existingOrderId);

        // NEW LOGIC: Incremental Mode (Empty Cart)
        clearCart(); // Start empty - moved to TOP to prevent wiping context

        currentTableId = selectedTableId;
        currentOrderId = existingOrderId;
        window.isIncrementalUpdate = true; // FLAG: We are adding to an existing order

        switchView('pos');

        // Ensure table dropdown is set
        setTimeout(() => {
            const tableSelect = document.getElementById('cart-table');
            if (tableSelect) tableSelect.value = String(selectedTableId);
            document.getElementById('order-number').textContent = 'Adding to Order #' + existingOrderId;
        }, 300);
        return;
    }

    console.log('[addItemsToTable] Starting NEW order for table:', selectedTableId);

    // Default flow for NEW order
    clearCart(); // IMPORTANT: Clear previous items to avoid confusion

    // DON'T use switchView('pos') - it has a race condition with loadTableOptions
    // Instead, manually show the POS view
    document.querySelectorAll('.view-section').forEach(v => v.classList.remove('active'));
    const target = document.getElementById('pos-view');
    if (target) target.classList.add('active');

    // Load products first
    await loadProducts();

    // Now load table options and immediately set selection
    await loadTableOptions();

    // Immediately set the dropdown value AFTER loadTableOptions completes
    const tableSelect = document.getElementById('cart-table');
    if (tableSelect && selectedTableId) {
        tableSelect.value = String(selectedTableId);
        // Also ensure currentTableId stays set for payOrder
        currentTableId = selectedTableId;
        console.log('[addItemsToTable] Final dropdown value:', tableSelect.value, 'currentTableId:', currentTableId);
    } else {
        console.warn('[addItemsToTable] Could not set table:', selectedTableId, 'dropdown:', tableSelect);
    }
}


async function checkoutTable() {
    closeTableOptions();
    // Get table's running bill first
    const billResult = await api('get_table_running_bill', { table_id: currentTableId });
    if (billResult.success && billResult.data) {
        const orderId = billResult.data.id;
        // Set table to needs_payment status (order stays open for manual receipt print)
        const result = await api('update_table_status', { id: currentTableId, status: 'needs_payment' }, 'POST');
        if (result.success) {
            showToast('Table marked for payment - print receipt when ready');
            loadTables();
        }
    } else {
        showToast('No order yet! Click "Add Items" first to create an order.', 'error');
    }
}



async function clearTable() {
    closeTableOptions();
    await api('clear_table', { id: currentTableId }, 'POST');
    showToast('Table cleared');
    loadTables();
}

// Print receipt for table's running order (without completing)
async function printTableBill() {
    const billResult = await api('get_table_running_bill', { table_id: currentTableId });
    if (billResult.success && billResult.data) {
        printReceipt(billResult.data.id);
        showToast('Receipt printed');
    } else {
        showToast('No order yet! Add items first to create an order.', 'error');
    }
}

// Complete the order, print receipt, and clear table
async function completeTableOrder() {
    closeTableOptions();
    const billResult = await api('get_table_running_bill', { table_id: currentTableId });
    if (billResult.success && billResult.data) {
        const orderId = billResult.data.id;
        // Complete the order
        const result = await api('complete_order', { order_id: orderId }, 'POST');
        if (result.success) {
            showToast('Order completed & table cleared');
            printReceipt(orderId);
            loadTables();
        }
    } else {
        showToast('No order yet! Add items first to create an order.', 'error');
    }
}


async function saveTable() {
    const name = document.getElementById('table-name').value;
    const seats = document.getElementById('table-seats').value;
    if (!name) { showToast('Enter table name', 'error'); return; }

    const result = await api('add_table', { name, seats }, 'POST');
    if (result.success) {
        showToast('Table added');
        closeModal('add-table-modal');
        document.getElementById('table-name').value = '';
        document.getElementById('table-seats').value = '4';
        loadTables();
        loadTableOptions();
    }
}

// Shift Management functions refactored and moved to Business Day logic at the end of file.

async function loadBusinessHistory() {
    const res = await api('get_business_day_history?limit=50');
    if (res.success && res.data) {
        const selects = ['export-shift-select'];
        selects.forEach(id => {
            const select = document.getElementById(id);
            if (!select) return;
            select.innerHTML = res.data.map(s => `<option value="${s.id}">${s.id} | ${formatDate(s.shift_start)} - ${s.shift_end ? formatDate(s.shift_end) : 'Running'}</option>`).join('');
            if (businessDayActive && id === 'export-shift-select') {
                // If we have an ID for the business day, we could auto-select it.
                // For now, just ignoring or selecting "today" if logical.
                // select.value = ... 
            }
        });
    }
}

function formatDate(dateStr) {
    const d = new Date(dateStr);
    return d.toLocaleDateString() + ' ' + d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
}

// ============ INVENTORY ============
// Migrated to DataTables
async function loadInventory(page = 1) {
    const result = await api('get_inventory', { page, limit: 1000 }); // Fix: Increased limit (was 12)
    const tbody = document.getElementById('inventory-tbody');
    const pagination = document.getElementById('inventory-pagination');

    if (!result.success) { if (tbody) tbody.innerHTML = '<tr><td colspan="7" class="text-center">Failed to load</td></tr>'; return; }

    let html = '';
    result.data.forEach(i => {
        let statusBadge = '';
        const qty = parseFloat(i.quantity);

        // Determine Colors directly in JS (Hardcoded for safety)
        let bgStyle = "";
        let textStyle = "";
        let label = "";

        if (qty > 10) {
            // In Stock: Light Green BG, Dark Green Text
            bgStyle = "#d1fae5";
            textStyle = "#064e3b";
            label = "In Stock";
        } else if (qty > 0) {
            // Low Stock: Light Yellow BG, Dark Brown Text
            bgStyle = "#fef3c7";
            textStyle = "#78350f";
            label = "Low Stock";
        } else {
            // Out of Stock: Light Red BG, Dark Red Text
            bgStyle = "#fee2e2";
            textStyle = "#7f1d1d";
            label = "Out of Stock";
        }

        // Generate the HTML with INLINE STYLES (Force colors with !important)
        statusBadge = `
            <span style="
                background-color: ${bgStyle} !important; 
                color: ${textStyle} !important; 
                padding: 6px 12px; 
                border-radius: 6px; 
                font-weight: 700; 
                font-size: 0.85rem;
                border: 1px solid transparent;
                display: inline-block;
                min-width: 90px;
                text-align: center;
            ">
                ${label}
            </span>
        `;

        html += `<tr>
            <td><span class="fw-medium">${i.name}</span></td>
            <td class="text-muted"><small>${i.sku || '-'}</small></td>
            <td><span class="badge bg-primary-subtle text-primary border-0">${i.category_name || i.consumption_unit || '-'}</span></td>
            <td class="fw-bold ${qty <= 10 ? 'text-danger' : ''}">${parseFloat(i.quantity).toFixed(1)}</td>
            <td>${formatCurrency(i.cost_per_unit || 0)}</td>
            <td>${i.supplier_name || '-'}</td>
            <td>${statusBadge}</td>
            <td class="text-center align-middle">
                <div class="action-cell">
                    <button class="btn-pro btn-edit-pro" onclick="editInventory(${i.id})" title="Edit">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                    </button>
                    <button class="btn-pro btn-delete-pro" onclick="deleteInventoryItem(${i.id})" title="Delete">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
                    </button>
                </div>
            </td>
        </tr>`;
    });
    if (tbody) tbody.innerHTML = html || '<tr><td colspan="7" class="text-center p-3 text-muted">No inventory items</td></tr>';

    if (result.pagination) {
        if (pagination) renderPagination(pagination, result.pagination, (p) => loadInventory(p));
    }
    populateInventorySelects(); // Consolidated dropdown update
}



// Merged Modal Logic
async function toggleStockMode(mode) {
    const containerAdd = document.getElementById('container-mode-add');
    const containerCreate = document.getElementById('container-mode-create');
    const btnSave = document.getElementById('btn-save-stock');

    if (mode === 'add') {
        containerAdd.style.display = 'block';
        containerCreate.style.display = 'none';
        btnSave.textContent = 'Update Stock';
        btnSave.classList.remove('btn-success');
        btnSave.classList.add('btn-primary');
    } else {
        containerAdd.style.display = 'none';
        containerCreate.style.display = 'block';
        btnSave.textContent = 'Create Item & Add Stock';
        btnSave.classList.remove('btn-primary');
        btnSave.classList.add('btn-success');

        // Load suppliers if empty
        const supSelect = document.getElementById('new-item-supplier');
        if (supSelect && supSelect.options.length === 0) {
            await loadSuppliersDropdown();
        }
    }
}

async function loadSuppliersDropdown() {
    const result = await api('get_suppliers', { limit: 1000 });
    const select = document.getElementById('new-item-supplier');
    if (select && result.success && result.data) {
        select.innerHTML = '<option value="">Select Supplier...</option>' +
            result.data.map(s => `<option value="${s.id}">${s.name}</option>`).join('');
    }
}

async function saveStockOrItem() {
    const mode = document.querySelector('input[name="stock-mode"]:checked').value;

    if (mode === 'add') {
        await addStock();
    } else {
        await createInventoryItem();
    }
}

async function addStock() {
    const id = document.getElementById('stock-item').value;
    const qty = document.getElementById('stock-qty').value;
    if (!id || !qty) { showToast('Fill all fields', 'error'); return; }
    const result = await api('add_stock', { id, quantity: qty }, 'POST');
    if (result.success) {
        showToast('Stock updated');
        closeModal('add-stock-modal');
        document.getElementById('stock-qty').value = '';
        loadInventory();
    }
}

async function createInventoryItem() {
    const name = document.getElementById('new-item-name').value;
    const sku = document.getElementById('new-item-sku').value;
    const supplier = document.getElementById('new-item-supplier').value;
    const cost = document.getElementById('new-item-cost').value;
    const min = document.getElementById('new-item-min').value;
    const unit = document.getElementById('new-item-unit').value || 'Pcs';

    if (!name) { showToast('Item Name is required', 'error'); return; }

    const data = {
        name,
        sku,
        supplier_id: supplier,
        cost_per_unit: cost,
        min_quantity: min,
        purchase_unit: unit,
        consumption_unit: unit,
        conversion_factor: 1,
        quantity: 0 // Initial quantity
    };

    const result = await api('add_inventory_item', data, 'POST');
    if (result.success) {
        showToast('New item created');
        closeModal('add-stock-modal');
        // Reset form
        document.getElementById('new-item-name').value = '';
        document.getElementById('new-item-sku').value = '';
        document.getElementById('new-item-cost').value = '';
        loadInventory();
        // Reload dropdowns
        loadInventoryDropdown();
    }
}

// ============ SUPPLIERS ============
// Migrated to DataTables
async function loadSuppliers(page = 1) {
    const result = await api('get_suppliers', { page, limit: 1000 }); // Fix: Increased limit
    if (!result.success) return;
    const tbody = document.getElementById('suppliers-tbody');
    const pagination = document.getElementById('suppliers-pagination');

    if (!result.success) { if (tbody) tbody.innerHTML = '<tr><td colspan="5" class="text-center">Failed to load</td></tr>'; return; }

    let html = '';
    result.data.forEach(s => {
        html += `<tr>
            <td>${s.name}</td>
            <td>${s.contact_person} / ${s.phone}</td>
            <td>${s.email}</td>
            <td>${s.address}</td>
            <td class="text-center align-middle">
                <div class="action-cell">
                    <button class="btn-pro btn-edit-pro" onclick="editSupplier(${s.id})" title="Edit">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                    </button>
                    <button class="btn-pro btn-delete-pro" onclick="deleteSupplier(${s.id})" title="Delete">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
                    </button>
                </div>
            </td>
        </tr>`;
    });
    if (tbody) tbody.innerHTML = html || '<tr><td colspan="5" class="text-center p-3 text-muted">No suppliers found</td></tr>';

    if (result.pagination) {
        if (pagination) renderPagination(pagination, result.pagination, (p) => loadSuppliers(p));
    }
}

async function saveSupplier() {
    const name = document.getElementById('supplier-name').value;
    const contact = document.getElementById('supplier-contact').value;
    const email = document.getElementById('supplier-email').value;
    const address = document.getElementById('supplier-address').value;
    if (!name) { showToast('Enter name', 'error'); return; }
    const result = await api('add_supplier', { name, contact, email, address }, 'POST');
    if (result.success) { showToast('Supplier added'); closeModal('add-supplier-modal'); loadSuppliers(); }
}

// ============ RECIPES ============
// Migrated to DataTables
async function loadRecipes(page = 1) {
    const result = await api('get_recipes', { page, limit: 10 });
    const tbody = document.getElementById('recipe-table-body');
    const pagination = document.getElementById('recipes-pagination');

    if (!result.success) { if (tbody) tbody.innerHTML = '<tr><td colspan="4" class="text-center">Failed to load</td></tr>'; return; }

    let html = '';
    result.data.forEach(r => {
        html += `<tr>
            <td>${r.product_name}</td>
            <td>${r.ingredient_name}</td>
            <td>${r.qty_required} ${r.consumption_unit || ''}</td>
            <td class="text-center align-middle">
                <div class="action-cell">
                    <button class="btn-pro btn-delete-pro" onclick="deleteRecipe(${r.id})" title="Delete">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
                    </button>
                </div>
            </td>
        </tr>`;
    });
    if (tbody) tbody.innerHTML = html || '<tr><td colspan="4" class="text-center p-3 text-muted">No recipes found</td></tr>';

    if (result.pagination) {
        if (pagination) renderPagination(pagination, result.pagination, (p) => loadRecipes(p));
    }
}

async function deleteRecipe(id) {
    if (await UI.confirm('Delete Ingredient?', 'This will remove the ingredient from the recipe.')) {
        await api('delete_recipe', { id }, 'POST');
        loadRecipes();
    }
}

// ============ EXPENSES ============
// Migrated to DataTables
async function loadExpenses(page = 1) {
    const result = await api('get_expenses', { page, limit: 1000 }); // Fix: Increased limit
    if (!result.success) return;
    const tbody = document.getElementById('expenses-tbody');
    const pagination = document.getElementById('expenses-pagination');

    if (!result.success) { if (tbody) tbody.innerHTML = '<tr><td colspan="5" class="text-center">Failed to load</td></tr>'; return; }

    let html = '';
    result.data.forEach(e => {
        html += `<tr>
            <td>${new Date(e.created_at).toLocaleDateString()}</td>
            <td><span class="badge bg-secondary">${e.category}</span></td>
            <td>${e.description}</td>
            <td class="fw-bold">${formatCurrency(e.amount)}</td>
             <td class="text-center align-middle">
                <div class="action-cell">
                    <button class="btn-pro btn-edit-pro" onclick="editExpense(${e.id})" title="Edit">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                    </button>
                    <button class="btn-pro btn-delete-pro" onclick="deleteExpense(${e.id})" title="Delete">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
                    </button>
                </div>
            </td>
        </tr>`;
    });
    if (tbody) tbody.innerHTML = html || '<tr><td colspan="5" class="text-center p-3 text-muted">No expenses found</td></tr>';

    if (result.pagination) {
        if (pagination) renderPagination(pagination, result.pagination, (p) => loadExpenses(p));
    }
}

async function saveExpense() {
    const desc = document.getElementById('expense-desc').value;
    const cat = document.getElementById('expense-cat').value;
    const amount = document.getElementById('expense-amount').value;
    if (!desc || !amount) { showToast('Fill fields', 'error'); return; }
    const result = await api('add_expense', { description: desc, category: cat, amount }, 'POST');
    if (result.success) { showToast('Expense added'); closeModal('add-expense-modal'); loadExpenses(); loadDashboard(); }
}

// ============ MENU MANAGEMENT ============
// Migrated to DataTables
async function loadMenuItems(page = 1) {
    const result = await api('get_all_products', { page, limit: 10 });
    const tbody = document.getElementById('menu-tbody');
    const pagination = document.getElementById('menu-pagination');

    if (!result.success) { if (tbody) tbody.innerHTML = '<tr><td colspan="6" class="text-center">Failed to load</td></tr>'; return; }

    // Store all retrieved products in the global array so they can be edited even if unavailable
    result.data.forEach(p => {
        const id = parseInt(p.id);
        const index = products.findIndex(prod => parseInt(prod.id) === id);
        if (index > -1) {
            products[index] = p;
        } else {
            products.push(p);
        }
    });

    let html = '';
    result.data.forEach(p => {
        html += `<tr>
            <td><img src="${p.image || 'https://placehold.co/40'}" class="rounded" width="40" height="40" style="object-fit:cover;" onerror="this.src='https://placehold.co/40'"></td>
            <td><span class="fw-bold">${p.name}</span></td>
            <td><span class="badge bg-primary-subtle text-primary border-0">${p.category_name || '-'}</span></td>
            <td class="fw-bold">${formatCurrency(p.price)}</td>
            <td>
                <div class="form-check form-switch">
                    <input class="form-check-input" type="checkbox" ${p.is_available == 1 ? 'checked' : ''} onchange="toggleAvailability(${p.id}, this.checked)">
                </div>
            </td>
            <td class="text-center align-middle">
                <div class="action-cell">
                    <button class="btn-pro btn-edit-pro" onclick="editProduct(${p.id})" title="Edit">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                    </button>
                    <button class="btn-pro btn-delete-pro" onclick="deleteProduct(${p.id})" title="Delete">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
                    </button>
                </div>
            </td>
        </tr>`;
    });
    if (tbody) tbody.innerHTML = html || '<tr><td colspan="6" class="text-center p-3 text-muted">No items found</td></tr>';

    if (result.pagination) {
        if (pagination) renderPagination(pagination, result.pagination, (p) => loadMenuItems(p));
    }
}

async function toggleAvailability(productId, isAvailable) {
    await api('toggle_product_availability', { id: productId, is_available: isAvailable ? 1 : 0 }, 'POST');
    showToast('Updated');
}

// Helper to populate inventory dropdowns for product linking
let globalInventoryData = []; // Store for filtering

async function populateInventorySelects() {
    // Re-use the same query logic as loadInventoryDropdown but target the new selects
    const result = await api('get_inventory', { limit: 1000 });
    if (!result.success || !result.data) return;

    globalInventoryData = result.data; // Store for search

    const options = buildInventoryOptions(globalInventoryData);

    const addSelect = document.getElementById('item-link-inventory');
    const editSelect = document.getElementById('edit-item-link-inventory');
    const stockSelect = document.getElementById('stock-item'); // Add Stock Modal

    if (addSelect) addSelect.innerHTML = options;
    if (editSelect) editSelect.innerHTML = options;

    // #stock-item might not need the "No Link" option, but it doesn't hurt.
    // Actually, for stock-item (Stock In), "No Link" is invalid.
    // So we should filter it out or generate specific options for it.
    if (stockSelect) {
        stockSelect.innerHTML = globalInventoryData.map(i => `<option value="${i.id}">${i.name} (${i.quantity} ${i.consumption_unit})</option>`).join('');
    }
}

function buildInventoryOptions(data) {
    if (!data) return '<option value="">No Link (Manual Recipe)</option>';
    return '<option value="">No Link (Manual Recipe)</option>' +
        data.map(i => `<option value="${i.id}">${i.name} (${i.quantity} ${i.consumption_unit})</option>`).join('');
}

function filterInventoryDocs(mode) {
    const inputId = mode === 'add' ? 'search-inventory-add' : 'search-inventory-edit';
    const selectId = mode === 'add' ? 'item-link-inventory' : 'edit-item-link-inventory';

    const query = document.getElementById(inputId).value.toLowerCase();
    const select = document.getElementById(selectId);

    // Filter data
    const filtered = globalInventoryData.filter(i => i.name.toLowerCase().includes(query));

    const currentVal = select.value;
    select.innerHTML = buildInventoryOptions(filtered);

    // restore value if it exists in filtered set
    if (filtered.find(i => i.id == currentVal)) {
        select.value = currentVal;
    }
}

async function saveMenuItem() {
    const name = document.getElementById('item-name').value;
    const price = document.getElementById('item-price').value;
    const categoryId = document.getElementById('item-category').value;
    const inventoryId = document.getElementById('item-link-inventory').value; // New field
    const imageInput = document.getElementById('item-image');

    if (!name || !price) { showToast('Fill name and price', 'error'); return; }

    const formData = new FormData();
    formData.append('name', name);
    formData.append('price', price);
    formData.append('category_id', categoryId);
    if (inventoryId) formData.append('inventory_id', inventoryId); // Send if selected

    if (imageInput.files[0]) {
        formData.append('image', imageInput.files[0]);
    }

    const result = await api('add_product', formData, 'POST');
    if (result.success) {
        showToast('Item added');
        closeModal('add-item-modal');
        loadMenuItems(); loadProducts();

        // Reset form and preview
        document.getElementById('item-name').value = '';
        document.getElementById('item-price').value = '';
        document.getElementById('item-link-inventory').value = ''; // Reset
        document.getElementById('item-image').value = '';
        document.getElementById('add-item-preview').src = 'https://placehold.co/40';
    }
}

// ============ STAFF ============
// Migrated to DataTables
async function loadStaff(page = 1) {
    const result = await api('get_staff', { page, limit: 1000 }); // Fix: Increased limit
    if (!result.success) return;
    const tbody = document.getElementById('staff-tbody');
    const pagination = document.getElementById('staff-pagination');

    if (!result.success) { if (tbody) tbody.innerHTML = '<tr><td colspan="4" class="text-center">Failed to load</td></tr>'; return; }

    let html = '';
    result.data.forEach(s => {
        let roleBadge = '<span class="badge bg-secondary">Staff</span>';
        if (s.role === 'manager') roleBadge = '<span class="badge bg-primary">Manager</span>';
        else if (s.role === 'chef') roleBadge = '<span class="badge bg-warning text-dark">Chef</span>';

        html += `<tr>
            <td>${s.name}</td>
            <td>${roleBadge}</td>
            <td>${s.current_shift_start ? new Date(s.current_shift_start).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : '<span class="text-muted">--:--</span>'}</td>
            <td>
                 ${s.is_active == 1 ? `<button class="btn btn-xs btn-danger btn-toggle-shift" data-id="${s.id}" data-action="end">End</button>` : `<button class="btn btn-xs btn-success btn-toggle-shift" data-id="${s.id}" data-action="start">Start</button>`}
                 <button class="btn btn-xs btn-light border ml-1 btn-edit-staff" data-id="${s.id}"><i class="fas fa-edit"></i></button>
                 <button class="btn btn-xs btn-outline-danger ml-1 btn-delete-staff" data-id="${s.id}"><i class="fas fa-trash"></i></button>
            </td>
        </tr>`;
    });
    if (tbody) tbody.innerHTML = html || '<tr><td colspan="4" class="text-center p-3 text-muted">No staff found</td></tr>';

    if (result.pagination) {
        if (pagination) renderPagination(pagination, result.pagination, (p) => loadStaff(p));
    }
}

async function toggleShift(staffId, action) {
    await api('toggle_shift', { id: staffId, shift_action: action }, 'POST');
    showToast('Shift ' + (action === 'start' ? 'started' : 'ended'));
    loadStaff(); loadDashboard();
}

async function saveStaff() {
    const name = document.getElementById('staff-name').value;
    const role = document.getElementById('staff-role').value;
    if (!name) { showToast('Enter name', 'error'); return; }
    const result = await api('add_staff', { name, role }, 'POST');
    if (result.success) { showToast('Staff added'); closeModal('add-staff-modal'); loadStaff(); }
}

// ============ UI HELPERS ============
function openModal(id) {
    const el = document.getElementById(id);
    if (el) {
        el.classList.add('open');
        if (id === 'held-orders-modal') loadHeldOrders();
    }
}
function closeModal(id) {
    const el = document.getElementById(id);
    if (el) el.classList.remove('open');
}
function openCartMobile() {
    const el = document.getElementById('cart-panel');
    if (el) el.classList.toggle('open');
}

function showToast(msg, type = 'success') {
    const container = document.getElementById('toast-container');
    const toast = document.createElement('div');
    toast.className = 'custom-toast';
    const icon = type === 'error' ? 'fa-exclamation-circle text-danger' : 'fa-check-circle text-success';
    toast.innerHTML = `<i class="fas ${icon} me-2"></i> ${msg}`;
    container.appendChild(toast);
    setTimeout(() => toast.classList.add('show'), 100);
    setTimeout(() => { toast.classList.remove('show'); setTimeout(() => toast.remove(), 500); }, 3000);
}


function previewImage(input, previewId) {
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function (e) {
            document.getElementById(previewId).src = e.target.result;
        }
        reader.readAsDataURL(input.files[0]);
    }
}

function updateClock() { document.getElementById('live-clock').innerText = new Date().toLocaleTimeString('en-US', { hour12: false }); }

let shiftSeconds = 0;
function updateShiftTimer() {
    shiftSeconds++;
    const hrs = Math.floor(shiftSeconds / 3600).toString().padStart(2, '0');
    const mins = Math.floor((shiftSeconds % 3600) / 60).toString().padStart(2, '0');
    const secs = (shiftSeconds % 60).toString().padStart(2, '0');
    document.getElementById('shift-timer').innerText = `${hrs}:${mins}:${secs}`;
}

// Unified Calculator Logic (Glassmorphism Design)
function calculator(input) {
    const display = document.getElementById("inputDisplay");
    const result = document.getElementById("resultDisplay");
    if (!display || !result) return;

    if (input === "C") {
        display.innerHTML = "0";
        result.innerHTML = "";
    } else if (input === "+/-") {
        if (display.innerHTML === "0") return;
        display.innerHTML = display.innerHTML.startsWith("-")
            ? display.innerHTML.slice(1)
            : "-" + display.innerHTML;
    } else if (input === "%") {
        if (display.innerHTML !== "0") {
            try {
                display.innerHTML = (parseFloat(display.innerHTML) / 100).toString();
            } catch (e) {
                result.innerHTML = "ERROR";
            }
        }
    } else if (input === "=") {
        try {
            // Replace visual operators with JS operators
            const calc = display.innerHTML
                .replace(/×/g, "*")
                .replace(/÷/g, "/")
                .replace(/−/g, "-");
            // Use Function constructor for safer evaluation than direct eval()
            const evalResult = new Function('return ' + calc)();
            result.innerHTML = evalResult.toString();
        } catch {
            result.innerHTML = "ERROR";
        }
    } else {
        if (display.innerHTML === "0" && !isNaN(input)) {
            display.innerHTML = input;
        } else {
            // Prevent multiple decimals
            if (input === '.' && display.innerHTML.includes('.') && !/[+×÷\−-]/.test(display.innerHTML)) {
                return;
            }
            display.innerHTML += input;
        }
    }

    // Dynamic font scaling for Input Display (Updated for 12-digit threshold)
    const inputLen = display.innerHTML.length;
    if (inputLen > 18) display.style.fontSize = '1.0rem';
    else if (inputLen > 15) display.style.fontSize = '1.4rem';
    else if (inputLen > 12) display.style.fontSize = '1.8rem';
    else display.style.fontSize = '2.5rem'; // Full size up to 12 digits

    // Dynamic font scaling for Result Display (Updated for 12-digit threshold)
    const resultLen = result.innerHTML.length;
    if (resultLen > 18) result.style.fontSize = '1.2rem';
    else if (resultLen > 15) result.style.fontSize = '1.8rem';
    else if (resultLen > 12) result.style.fontSize = '2.4rem';
    else result.style.fontSize = '3rem'; // Full size up to 12 digits
}

// ============ TABLE TRANSFER ============
async function openTransferModal() {
    closeTableOptions();

    // 1. Set current table info
    document.getElementById('transfer-from-id').value = currentTableId;

    // Get table name (we can grab it from the DOM element instead of refetching everything or use cache)
    // Better to fetch fresh to ensure we don't transfer a table that just got freed/busy
    const result = await api('get_tables');

    if (!result.success) {
        showToast('Failed to load table data', 'error');
        return;
    }

    const tables = result.data;
    const currentTable = tables.find(t => t.id == currentTableId);

    if (!currentTable) {
        showToast('Current table not found', 'error');
        return;
    }

    // Check if table is actually busy (double check)
    if (currentTable.status === 'free') {
        showToast('Cannot transfer a free table!', 'warning');
        return;
    }

    document.getElementById('transfer-from-name').value = currentTable.name;

    // 2. Populate Dropdown with FREE tables only
    const select = document.getElementById('transfer-to-table');
    let html = '<option value="">Select a free table...</option>';

    const freeTables = tables.filter(t => t.status === 'free');

    if (freeTables.length === 0) {
        html = '<option value="">No free tables available</option>';
    } else {
        freeTables.forEach(t => {
            html += `<option value="${t.id}">${t.name} (${t.seats} seats)</option>`;
        });
    }

    select.innerHTML = html;

    openModal('transfer-table-modal');
}

async function confirmTransferTable() {
    const fromId = document.getElementById('transfer-from-id').value;
    const toId = document.getElementById('transfer-to-table').value;

    if (!toId) {
        showToast('Please select a destination table', 'error');
        return;
    }

    if (await UI.confirm('Confirm Transfer', 'Are you sure you want to move this order to the new table?')) {
        const result = await api('transfer_table', {
            from_table_id: fromId,
            to_table_id: toId
        }, 'POST');

        if (result.success) {
            showToast('Table transferred successfully');
            closeModal('transfer-table-modal');
            loadTables();
        } else {
            showToast(result.message || 'Transfer failed', 'error');
        }
    }
}


// ============ STOCK CHECK (Pre-Order) ============
async function checkStockBeforeAdd(productId, qty = 1) {
    const result = await api('check_stock_availability', { product_id: productId, quantity: qty });
    if (!result.success) return true; // If API fails, allow order

    if (!result.can_make) {
        let msg = 'Insufficient stock:\n';
        result.insufficient_items.forEach(item => {
            msg += `• ${item.name}: Need ${item.needed}, Have ${item.available} ${item.unit}\n`;
        });
        showToast(msg, 'error');
        return false;
    }
    return true;
}

// Override addToCart with stock check (optional - enable for strict stock control)
const originalAddToCart = addToCart;
async function addToCartWithStockCheck(productId) {
    const product = products.find(p => p.id == productId);
    if (!product) return;

    const existingQty = cart.find(item => item.id == productId)?.quantity || 0;
    const stockOk = await checkStockBeforeAdd(productId, existingQty + 1);

    if (stockOk) {
        originalAddToCart(productId);
    }
}
// To enable stock check, uncomment: addToCart = addToCartWithStockCheck;

// ============ SIDEBAR FOOTER STYLING ============
// Add CSS for sidebar footer if needed
const sidebarFooterStyle = document.createElement('style');
sidebarFooterStyle.textContent = `
.sidebar-footer {
    padding: 12px;
    border-top: 1px solid rgba(255,255,255,0.1);
    margin-top: auto;
}
.sidebar-footer .text-xs { font-size: 0.75rem; }
`;
// ============ MODULAR REPORTS LOGIC
// ============ DASHBOARD ============
async function loadDashboard() {
    try {
        const res = await api('get_dashboard_stats');
        if (!res.success) return;

        // Update Big Stats
        const currency = settings.currency_symbol || '';
        const s = res.stats || {};

        // Helper to safely format numbers
        const safeNum = (val) => parseFloat(val || 0).toFixed(2);
        const safeInt = (val) => parseInt(val || 0);

        const elTotal = document.getElementById('dash-total-sales');
        if (elTotal) elTotal.textContent = currency + safeNum(s.total_sales);

        const elOrder = document.getElementById('dash-order-count');
        if (elOrder) elOrder.textContent = safeInt(s.order_count);

        const elCogs = document.getElementById('dash-cogs');
        if (elCogs) elCogs.textContent = currency + safeNum(s.cogs);

        const elProfit = document.getElementById('dash-net-profit');
        if (elProfit) elProfit.textContent = currency + safeNum(s.net_profit);

        // Header Sync
        const hProfit = document.getElementById('header-net-profit');
        if (hProfit) hProfit.textContent = currency + safeNum(s.net_profit);

        const hSales = document.getElementById('header-total-sales');
        if (hSales) hSales.textContent = currency + safeNum(s.total_sales);

        // Update Trends
        const updateTrend = (id, val) => {
            const el = document.getElementById(id);
            if (!el) return;
            const num = parseFloat(val);
            let icon = 'fa-minus';
            let cls = 'trend';

            if (num > 0) { icon = 'fa-caret-up'; cls += ' up'; }
            else if (num < 0) { icon = 'fa-caret-down'; cls += ' down'; }

            el.className = cls;
            el.innerHTML = `<i class="fas ${icon} me-1"></i> ${Math.abs(num)}%`;
        };

        if (s.growth) {
            updateTrend('trend-sales', s.growth.sales);
            updateTrend('trend-orders', s.growth.orders);
            updateTrend('trend-profit', s.growth.profit);
        }

        // Update Activity Feed
        const feed = document.getElementById('dashboard-activity-feed');
        if (!feed) return;

        const recent = res.recent || [];
        if (recent.length === 0) {
            feed.innerHTML = '<div class="text-center py-5 text-muted small">No recent activity</div>';
        } else {
            feed.innerHTML = recent.map(a => `
                <div class="activity-item">
                    <div class="activity-icon ${a.status === 'completed' ? 'bg-soft-success' : 'bg-soft-danger'}">
                        <i class="fas ${a.status === 'completed' ? 'fa-receipt' : 'fa-ban'}"></i>
                    </div>
                    <div class="activity-details flex-grow-1">
                        <p>Order #${a.order_number || 'N/A'} ${a.status === 'completed' ? 'completed' : 'cancelled'}</p>
                        <small>${a.created_at ? new Date(a.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : '-:-'}</small>
                    </div>
                    <div class="fw-bold small">${currency}${safeNum(a.total)}</div>
                </div>
            `).join('');
        }

        // Update Operational Alerts (Low Stock)
        const alertsContainer = document.getElementById('dashboard-alerts-container');
        if (alertsContainer) {
            const lowStock = res.low_stock || [];
            if (lowStock.length === 0) {
                alertsContainer.innerHTML = '<div class="text-center py-4 text-muted small"><i class="fas fa-check-circle text-success mb-2"></i><br>No alerts</div>';
            } else {
                alertsContainer.innerHTML = lowStock.map(i => `
                    <div class="alert-item d-flex align-items-center mb-3 bg-light rounded p-2">
                        <div class="icon-box bg-white text-danger shadow-sm rounded-circle me-3"
                            style="width:40px;height:40px;display:flex;align-items:center;justify-content:center;">
                            <i class="fas fa-exclamation-triangle"></i>
                        </div>
                        <div>
                            <p class="mb-0 fw-bold text-dark">${i.name}</p>
                            <small class="text-muted">Only ${parseFloat(i.quantity)} ${i.unit} left (Min: ${parseFloat(i.min_quantity)})</small>
                        </div>
                    </div>
                `).join('');
            }
        }

        // Update Trending Items
        const trendingContainer = document.getElementById('dashboard-trending-container');
        if (trendingContainer) {
            const best = res.best_items || [];
            if (best.length === 0) {
                trendingContainer.innerHTML = '<div class="text-center py-3 text-muted w-100 small">No sales data today</div>';
            } else {
                trendingContainer.innerHTML = best.map(i => `
                    <div class="trending-item border rounded p-2 flex-fill text-center" style="min-width: 120px;">
                        <h6 class="text-primary fw-bold mb-1 text-truncate">${i.product_name}</h6>
                        <small class="text-muted">${parseInt(i.total_sold)} Sold</small>
                    </div>
                `).join('');
            }
        }
    } catch (e) {
        console.error('Dashboard Load Error:', e);
        showToast('Failed to load dashboard data', 'error');
    }
}

// --- Z-REPORT ---
async function loadZReportPage() {
    // Sync with shift status
    await checkShiftStatus();

    const c = settings.currency_symbol || '$';

    // Helper to update text safely
    const setTxt = (id, val) => {
        const el = document.getElementById(id);
        if (el) el.textContent = val;
    };

    if (activeShift) {
        // Fetch a fresh snapshot for the current running UI
        const res = await api('get_shift_snapshot');
        if (res.success) {
            setTxt('zr-page-total-sales', c + res.total_sales.toFixed(2));
            setTxt('zr-page-order-count', res.order_count);
            setTxt('zr-page-avg-value', c + (res.avg_order_value || 0).toFixed(2));
            setTxt('zr-page-cash-sales', c + res.cash_sales.toFixed(2));
            setTxt('zr-page-card-sales', c + res.card_sales.toFixed(2));
            setTxt('zr-page-voids', res.void_count);
            setTxt('zr-page-expenses', c + res.total_expenses.toFixed(2));
            setTxt('zr-page-net-profit', c + res.net_profit.toFixed(2));

            // Expected cash (for reconciliation)
            setTxt('zr-page-expected-cash', c + res.expected_cash.toFixed(2));

            // Display starting cash
            setTxt('zr-display-start-cash', c + parseFloat(activeShift.start_cash).toFixed(2));

            // Update subtitle with open time
            const openTime = new Date(activeShift.start_time).toLocaleString();
            setTxt('current-shift-subtitle', 'Opened at ' + openTime);

            // Toggle states
            const closedState = document.getElementById('shift-closed-state');
            const openState = document.getElementById('shift-open-state');
            if (closedState) closedState.style.display = 'none';
            if (openState) openState.style.display = 'block';
        }
    } else {
        // Reset counters if no shift is active
        setTxt('zr-page-total-sales', c + '0.00');
        setTxt('zr-page-order-count', '0');
        setTxt('zr-page-avg-value', c + '0.00');
        setTxt('zr-page-cash-sales', c + '0.00');
        setTxt('zr-page-card-sales', c + '0.00');
        setTxt('zr-page-voids', '0');
        setTxt('zr-page-expenses', c + '0.00');
        setTxt('zr-page-net-profit', c + '0.00');
        setTxt('zr-page-expected-cash', c + '0.00');
        setTxt('zr-display-start-cash', c + '0.00');

        // Toggle states
        const closedState = document.getElementById('shift-closed-state');
        const openState = document.getElementById('shift-open-state');
        if (closedState) closedState.style.display = 'block';
        if (openState) openState.style.display = 'none';
    }

    loadZReportHistory();
}

// Migrated to DataTables
async function loadZReportHistory(page = 1) {
    const date = document.getElementById('zr-history-date').value;
    const result = await api('get_zreport_history', { date, page, limit: 10 });
    const tbody = document.getElementById('zr-history-tbody');
    const pagination = document.getElementById('zr-history-pagination');

    if (!result.success) { if (tbody) tbody.innerHTML = '<tr><td colspan="4" class="text-center">Failed to load</td></tr>'; return; }

    let html = '';
    result.data.forEach(r => {
        const diffClass = parseFloat(r.difference) < 0 ? 'text-danger' : 'text-success';
        const profitClass = parseFloat(r.net_profit) >= 0 ? 'text-success' : 'text-muted';

        html += `<tr>
            <td class="ps-4"><span class="badge bg-light text-dark shadow-sm">#${r.id}</span></td>
            <td>${new Date(r.shift_start).toLocaleString([], { dateStyle: 'short', timeStyle: 'short' })}</td>
            <td>${new Date(r.shift_end).toLocaleString([], { dateStyle: 'short', timeStyle: 'short' })}</td>
            <td class="fw-bold">$${parseFloat(r.total_sales).toFixed(2)}</td>
            <td class="text-danger">$${parseFloat(r.total_expenses).toFixed(2)}</td>
            <td class="${profitClass} fw-bold">$${parseFloat(r.net_profit).toFixed(2)}</td>
            <td>${r.user_name || 'System'}</td>
            <td class="text-end pe-4">
                <button class="btn btn-xs btn-outline-primary" onclick="printPastZReport(${r.id})" title="Reprint Z-Report"><i class="fas fa-print"></i></button>
            </td>
        </tr>`;
    });
    if (tbody) tbody.innerHTML = html || '<tr><td colspan="4" class="text-center p-3 text-muted">No history found</td></tr>';

    if (result.pagination) {
        if (pagination) renderPagination(pagination, result.pagination, (p) => loadZReportHistory(p));
    }
}

async function closeShiftPage() {
    if (!activeShift) { showToast('No active shift to close', 'info'); return; }

    const actual = document.getElementById('zr-page-actual-cash').value;
    const notes = document.getElementById('zr-page-notes').value;

    if (!actual) { showToast('Enter actual cash amount', 'error'); return; }

    if (!confirm('Are you sure you want to close this shift?')) return;

    // Use the global execute logic
    const res = await api('close_shift', { actual_cash: actual, notes: notes }, 'POST');
    if (res.success) {
        showToast('Shift closed successfully!');
        activeShift = null;
        updateShiftUI();
        await loadShiftsForSelectors();
        loadZReportPage();
        document.getElementById('zr-page-actual-cash').value = '';
        document.getElementById('zr-page-notes').value = '';
    } else {
        showToast(res.message, 'error');
    }
}

function printZReportPage() {
    const sales = document.getElementById('zr-page-total-sales').textContent;
    const expected = document.getElementById('zr-page-expected-cash').textContent;
    const actual = document.getElementById('zr-page-actual-cash').value || '0.00';

    const html = `
        <div style="width: 300px; font-family: monospace; padding: 20px; border: 1px solid #eee;">
            <center><h2>Z-REPORT</h2><p>Shift Summary Preview</p></center>
            <hr>
            <div style="display:flex; justify-content:space-between"><span>Total Sales:</span> <b>${sales}</b></div>
            <div style="display:flex; justify-content:space-between"><span>Expected:</span> <b>${expected}</b></div>
            <div style="display:flex; justify-content:space-between"><span>Actual:</span> <b>$${parseFloat(actual).toFixed(2)}</b></div>
            <hr>
            <br><br><center>__________________<br>Signature</center>
        </div>
    `;
    const win = window.open('', '', 'width=400,height=500');
    win.document.write(html);
    win.document.close();
    win.print();
}

async function printPastZReport(id) {
    const res = await api('get_zreport', { id });
    if (!res.success) return;
    const r = res.data;
    const html = `
        <div style="width: 300px; font-family: monospace; padding: 20px;">
            <center><h3>PAST Z-REPORT</h3><p>#${r.id}</p></center>
            <hr>
            <div>Cashier: ${r.user_name}</div>
            <div>Start: ${r.shift_start}</div>
            <div>End: ${r.shift_end}</div>
            <hr>
            <div style="display:flex; justify-content:space-between"><span>Sales:</span> <b>$${parseFloat(r.total_sales).toFixed(2)}</b></div>
            <div style="display:flex; justify-content:space-between"><span>Expected:</span> <b>$${parseFloat(r.expected_cash).toFixed(2)}</b></div>
            <div style="display:flex; justify-content:space-between"><span>Actual:</span> <b>$${parseFloat(r.actual_cash).toFixed(2)}</b></div>
            <div style="display:flex; justify-content:space-between"><span>Diff:</span> <b>$${parseFloat(r.difference).toFixed(2)}</b></div>
        </div>
    `;
    const win = window.open('', '', 'width=400,height=500');
    win.document.write(html);
    win.document.close();
    win.print();
}

// --- SHIFTS LOADING FOR EXPORT ---
// Note: Shifts are now managed in Z-Report section
async function loadShiftsForSelectors() {
    const shiftSelect = document.getElementById('export-shift-select');

    if (!shiftSelect) return;

    // Since shifts are in Z-Report now, we'll just provide an "All Orders" option
    // and load data directly
    shiftSelect.innerHTML = '<option value="all" selected>All Orders (Last 30 Days)</option>';

    // Remove the shift requirement - user can just use the search/filters
    shiftSelect.disabled = true;
    shiftSelect.style.opacity = '0.6';

    // Add a note ONLY if it doesn't already exist
    if (!shiftSelect.parentElement.querySelector('.shift-note')) {
        const note = document.createElement('small');
        note.className = 'text-muted d-block mt-1 shift-note';
        note.innerHTML = '<i class="fas fa-info-circle me-1"></i>Shift management is now in Z-Report section';
        shiftSelect.parentElement.appendChild(note);
    }
}

// --- EXPORT SALES ---
async function initExportPage() {
    // Set default date range (last 30 days)
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - 30);

    const startInput = document.getElementById('report-start');
    const endInput = document.getElementById('report-end');

    if (startInput) startInput.value = startDate.toISOString().split('T')[0];
    if (endInput) endInput.value = endDate.toISOString().split('T')[0];

    // Load data with default dates
    loadDetailedReport();
}

function setExportRange(range) {
    const end = new Date();
    let start = new Date();
    if (range === 'week') start.setDate(end.getDate() - 7);
    if (range === 'month') start.setMonth(end.getMonth() - 1);

    document.getElementById('export-start-date').value = start.toISOString().split('T')[0];
    document.getElementById('export-end-date').value = end.toISOString().split('T')[0];
    loadExportPreview();
}

// ============ SALES REPORTS FILTER HELPERS ============
function applyQuickFilter(period, event) {
    if (event) {
        event.preventDefault();
        event.stopPropagation();
    }
    const startDateInput = document.getElementById('export-start-date') || document.getElementById('report-start');
    const endDateInput = document.getElementById('export-end-date') || document.getElementById('report-end');

    const today = new Date();
    let startDate = new Date();
    let endDate = new Date();

    switch (period) {
        case 'today':
            startDate = today;
            endDate = today;
            break;
        case 'yesterday':
            startDate.setDate(today.getDate() - 1);
            endDate.setDate(today.getDate() - 1);
            break;
        case 'week':
            startDate.setDate(today.getDate() - 7);
            endDate = today;
            break;
        case 'month':
            startDate.setDate(today.getDate() - 30);
            endDate = today;
            break;
        case 'this_month':
            startDate = new Date(today.getFullYear(), today.getMonth(), 1);
            endDate = today;
            break;
    }

    if (startDateInput) startDateInput.value = startDate.toISOString().split('T')[0];
    if (endDateInput) endDateInput.value = endDate.toISOString().split('T')[0];

    // Auto-load data
    loadExportPreview(1);
}

function resetFilters() {
    // Reset all filter inputs
    const startDateInput = document.getElementById('export-start-date');
    const endDateInput = document.getElementById('export-end-date');
    const searchInput = document.getElementById('export-search');
    const statusFilter = document.getElementById('export-status-filter');
    const typeFilter = document.getElementById('export-type-filter');

    // Set default to last 30 days
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - 30);

    if (startDateInput) startDateInput.value = startDate.toISOString().split('T')[0];
    if (endDateInput) endDateInput.value = endDate.toISOString().split('T')[0];
    if (searchInput) searchInput.value = '';
    if (statusFilter) statusFilter.value = '';
    if (typeFilter) typeFilter.value = '';

    // Reload with default filters
    loadExportPreview(1);
}

// Migrated to DataTables
/**
 * Load Detailed Sales Report (Analytical)
 */
// Pagination State
let currentReportOrders = [];
let currentReportPage = 1;
const reportItemsPerPage = 15;

async function loadDetailedReport() {
    const startInput = document.getElementById('report-start') || document.getElementById('export-start-date');
    const endInput = document.getElementById('report-end') || document.getElementById('export-end-date');

    if (!startInput || !endInput) return; // Guard clause

    // Default to today if empty (Use local date, not UTC)
    const todayStr = new Date().toLocaleDateString('en-CA');
    if (!startInput.value) startInput.value = todayStr;
    if (!endInput.value) endInput.value = todayStr;

    const tbody = document.getElementById('export-preview-tbody');
    if (tbody) tbody.innerHTML = '<tr><td colspan="7" class="text-center py-5"><div class="spinner-border spinner-border-sm me-2"></div>Loading report...</td></tr>';

    const res = await api('get_detailed_sales_report', {
        start_date: startInput.value,
        end_date: endInput.value
    }, 'GET');

    if (res.success) {
        // 1. Update Summary Cards
        const stats = res.stats;
        animateValue('report-total-revenue', stats.total_revenue, true);
        animateValue('report-cash-sales', stats.cash_sales, true);
        animateValue('report-total-expenses', stats.total_expenses, true);
        animateValue('report-total-orders', stats.total_orders, false);

        // 2. Initialize Pagination
        currentReportOrders = res.orders;
        currentReportPage = 1;
        renderReportTable();

    } else {
        if (tbody) tbody.innerHTML = '<tr><td colspan="7" class="text-center py-5 text-danger">Failed to load report</td></tr>';
    }
}

function renderReportTable() {
    const tbody = document.getElementById('export-preview-tbody');
    if (!tbody) return;

    if (currentReportOrders.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" class="text-center py-5 text-muted">No records found for this period</td></tr>';
        renderReportPagination(); // Clear pagination
        return;
    }

    // Client-side slicing
    const start = (currentReportPage - 1) * reportItemsPerPage;
    const end = start + reportItemsPerPage;
    const paginatedItems = currentReportOrders.slice(start, end);

    let html = '';
    paginatedItems.forEach(o => {
        const statusBadge = o.status === 'completed' ? 'bg-success' : 'bg-danger';
        html += `
            <tr>
                <td class="ps-4 fw-bold">#${o.order_number}</td>
                <td>${new Date(o.created_at).toLocaleString()}</td>
                <td>${o.customer_name || 'Walk-in'}</td>
                <td>${o.order_type.replace('_', ' ').toUpperCase()}</td>
                <td>${(o.payment_method || '-').toUpperCase()}</td>
                <td class="fw-bold">${formatCurrency(o.total)}</td>
                <td><span class="badge ${statusBadge}">${o.status.toUpperCase()}</span></td>
            </tr>
        `;
    });
    tbody.innerHTML = html;
    renderReportPagination();
}

function renderReportPagination() {
    const paginationUl = document.getElementById('report-pagination');
    if (!paginationUl) return;

    const totalPages = Math.ceil(currentReportOrders.length / reportItemsPerPage);
    let html = '';

    if (totalPages <= 1) {
        paginationUl.innerHTML = '';
        return;
    }

    // Helper for buttons
    const btnClass = "page-link bg-dark text-white border-secondary";
    const activeClass = "page-link bg-warning text-dark border-warning fw-bold";

    // Previous
    const prevDisabled = currentReportPage === 1 ? 'disabled' : '';
    html += `<li class="page-item ${prevDisabled}">
        <a class="${btnClass}" href="javascript:void(0)" onclick="changeReportPage(${currentReportPage - 1})">Previous</a>
    </li>`;

    // Numbers (Simple logic: show all or max 5? Let's show all if < 10, else smart? User asked for 1, 2, 3...)
    // For simplicity and robustness, showing up to 7 pages window or similar is good. 
    // Let's implement a simple window: First, Last, and Current +/- 1

    let pagesToShow = [];
    if (totalPages <= 7) {
        for (let i = 1; i <= totalPages; i++) pagesToShow.push(i);
    } else {
        pagesToShow = [1];
        if (currentReportPage > 3) pagesToShow.push('...');

        let startWindow = Math.max(2, currentReportPage - 1);
        let endWindow = Math.min(totalPages - 1, currentReportPage + 1);

        for (let i = startWindow; i <= endWindow; i++) pagesToShow.push(i);

        if (currentReportPage < totalPages - 2) pagesToShow.push('...');
        pagesToShow.push(totalPages);
    }

    pagesToShow.forEach(p => {
        if (p === '...') {
            html += `<li class="page-item disabled"><span class="${btnClass}">...</span></li>`;
        } else {
            const isActive = p === currentReportPage;
            html += `<li class="page-item ${isActive ? 'active' : ''}">
                <a class="${isActive ? activeClass : btnClass}" href="javascript:void(0)" onclick="changeReportPage(${p})">${p}</a>
            </li>`;
        }
    });

    // Next
    const nextDisabled = currentReportPage === totalPages ? 'disabled' : '';
    html += `<li class="page-item ${nextDisabled}">
        <a class="${btnClass}" href="javascript:void(0)" onclick="changeReportPage(${currentReportPage + 1})">Next</a>
    </li>`;

    paginationUl.innerHTML = html;
}

function changeReportPage(page) {
    const totalPages = Math.ceil(currentReportOrders.length / reportItemsPerPage);
    if (page < 1 || page > totalPages) return;
    currentReportPage = page;
    renderReportTable();
    // Scroll to top of table
    document.querySelector('.table-responsive').scrollIntoView({ behavior: 'smooth' });
}

// Alias for compatibility if needed, or just rename the function
const loadExportPreview = loadDetailedReport;

// ============ STAFF MANAGEMENT ============
async function loadStaff(page = 1) {
    const result = await api('get_staff', { page, limit: 100 });
    const tbody = document.getElementById('staff-tbody');
    const pagination = document.getElementById('staff-pagination');

    if (!result.success) { if (tbody) tbody.innerHTML = '<tr><td colspan="4" class="text-center">Failed to load</td></tr>'; return; }

    let html = '';
    result.data.forEach(s => {
        // Mock shift start for now if not in DB, or use created_at
        const shiftStart = s.current_shift_start ? new Date(s.current_shift_start).toLocaleString() : '-';

        html += `<tr>
            <td>${s.name}</td>
            <td><span class="badge bg-secondary">${s.role.toUpperCase()}</span></td>
            <td>${shiftStart}</td>
            <td class="text-center align-middle">
                <div class="action-cell">
                    <button class="btn-pro btn-edit-pro" onclick="editStaff(${s.id})" title="Edit">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                    </button>
                    <button class="btn-pro btn-delete-pro" onclick="deleteStaff(${s.id})" title="Delete">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
                    </button>
                </div>
            </td>
        </tr>`;
    });
    if (tbody) tbody.innerHTML = html || '<tr><td colspan="4" class="text-center p-3 text-muted">No staff found</td></tr>';
}

function animateValue(id, value, isCurrency) {
    const el = document.getElementById(id);
    if (!el) return;
    el.textContent = isCurrency ? formatCurrency(value) : value;
}

async function downloadExportPDF() {
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF('l', 'mm', 'a4'); // Landscape A4

    const shiftId = document.getElementById('export-shift-select').value;
    const search = document.getElementById('export-search').value;

    // Fetch ALL records for the range (without pagination)
    const res = await api('get_export_data', {
        shift_id: shiftId,
        search: search,
        limit: 1000
    });
    if (!res.success || res.data.length === 0) {
        showToast('No data to export', 'error');
        return;
    }

    const restaurantName = settings.restaurant_name || 'GustoPOS';

    // Header
    doc.setFontSize(20);
    doc.setTextColor(255, 107, 0); // Primary color
    doc.text(restaurantName + ' - Sales Report', 14, 22);

    doc.setFontSize(10);
    doc.setTextColor(100);
    doc.text(`Shift ID: ${shiftId}`, 14, 30);
    doc.text(`Generated: ${new Date().toLocaleString()}`, 14, 35);

    const tableData = res.data.map(o => [
        o.order_number,
        new Date(o.created_at).toLocaleString(),
        o.customer_name || 'Walk-in',
        o.order_type,
        `$${parseFloat(o.subtotal).toFixed(2)}`,
        `$${parseFloat(o.tax).toFixed(2)}`,
        `$${parseFloat(o.total).toFixed(2)}`,
        o.status
    ]);

    doc.autoTable({
        startY: 45,
        head: [['Order Ref', 'Timestamp', 'Customer', 'Type', 'Subtotal', 'Tax', 'Total', 'Status']],
        body: tableData,
        headStyles: { fillColor: [255, 107, 0] },
        alternateRowStyles: { fillColor: [250, 250, 250] },
        margin: { top: 45 },
    });

    doc.save(`Sales_Report_Shift_${shiftId}.pdf`);
    showToast('PDF Downloaded');
}

function printExportTable() {
    const table = document.querySelector('#export-view .table').outerHTML;
    const win = window.open('', '', 'width=900,height=700');
    win.document.write(`
        <html><head><link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"></head>
        <body class="p-4">
            <h2>Sales Report Data</h2>
            <p>Generated: ${new Date().toLocaleString()}</p>
            <hr>
            ${table}
        </body></html>
    `);
    win.document.close();
    setTimeout(() => win.print(), 500);
}

async function printSalesSummary() {
    const shiftId = document.getElementById('export-shift-select').value;
    if (shiftId === "0") { showToast('Select a shift', 'error'); return; }

    const res = await api(`get_sales_summary?shift_id=${shiftId}`);
    if (!res.success) {
        showToast('Failed to fetch summary', 'error');
        return;
    }

    const { items, totals } = res;
    const currency = settings.currency_symbol || '';
    const width = '80mm';

    let itemsHtml = '';
    items.forEach(item => {
        itemsHtml += `<tr>
            <td style="font-size: 13px;">${item.product_name}</td>
            <td style="text-align: right; font-size: 13px; font-weight: bold;">${item.total_sold} units sold</td>
        </tr>`;
    });

    const receiptHtml = `<!DOCTYPE html><html><head><style>
        @page { size: ${width} auto; margin: 0; }
        body { font-family: 'Courier New', Courier, monospace; font-size: 12px; width: ${width}; margin: 0; padding: 10px; color: #000; }
        .center { text-align: center; }
        .bold { font-weight: bold; }
        .divider { border-top: 1px dashed #000; margin: 10px 0; }
        table { width: 100%; border-collapse: collapse; }
        .right { text-align: right; }
        .header { font-size: 16px; margin-bottom: 5px; }
        .summary-row { display: flex; justify-content: space-between; margin: 5px 0; font-size: 14px; }
    </style></head><body>
        <div class="center bold header">${settings.restaurant_name || 'SALES SUMMARY'}</div>
        <div class="center">${totals.start_date === totals.end_date ? totals.start_date : totals.start_date + ' to ' + totals.end_date}</div>
        <div class="divider"></div>
        
        <div class="bold" style="margin-bottom: 5px; text-decoration: underline;">ITEMIZED SALES:</div>
        <table>${itemsHtml}</table>
        
        <div class="divider"></div>
        
        <div class="summary-row bold">
            <span>TOTAL ORDERS:</span>
            <span>${totals.order_count}</span>
        </div>
        <div class="summary-row bold" style="font-size: 16px;">
            <span>TOTAL SALES:</span>
            <span>${currency}${totals.revenue.toFixed(2)}</span>
        </div>
        
        <div class="divider"></div>
        <div class="center" style="font-size: 10px; color: #666;">Generated: ${new Date().toLocaleString()}</div>
        
        <script>window.onload = function() { window.print(); window.close(); }</script>
    </body></html>`;

    const printWindow = window.open('', '_blank', 'width=450,height=600');
    printWindow.document.write(receiptHtml);
    printWindow.document.close();
}

// --- EDIT FUNCTIONS ---
function editProduct(id) {
    const p = products.find(prod => prod.id == id);
    if (!p) {
        // Fallback: If not in global products, fetch it specifically or alert
        // For now, loadMenuItems ensures it's in the global array
        console.error('[editProduct] Product not found in local array:', id);
        showToast('Product data not loaded. Please refresh.', 'error');
        return;
    }
    document.getElementById('edit-item-id').value = p.id;
    document.getElementById('edit-item-name').value = p.name;
    document.getElementById('edit-item-price').value = p.price;
    document.getElementById('edit-item-preview').src = p.image || 'https://placehold.co/40';
    document.getElementById('edit-item-image').value = '';

    // Fill category select
    let optHtml = '<option value="">Select Category...</option>';
    categories.forEach(c => optHtml += `<option value="${c.id}" ${c.id == p.category_id ? 'selected' : ''}>${c.name}</option>`);
    document.getElementById('edit-item-category').innerHTML = optHtml;

    // Set Inventory Link
    // Ensure dropdown is populated first
    if (document.getElementById('edit-item-link-inventory').options.length <= 1) {
        populateInventorySelects().then(() => {
            document.getElementById('edit-item-link-inventory').value = p.linked_inventory_id || '';
        });
    } else {
        document.getElementById('edit-item-link-inventory').value = p.linked_inventory_id || '';
    }

    openModal('edit-product-modal');
}

async function saveProductEdit() {
    const formData = new FormData();
    formData.append('id', document.getElementById('edit-item-id').value);
    formData.append('name', document.getElementById('edit-item-name').value);
    formData.append('price', document.getElementById('edit-item-price').value);
    formData.append('category_id', document.getElementById('edit-item-category').value);
    formData.append('inventory_id', document.getElementById('edit-item-link-inventory').value); // New field

    const imageInput = document.getElementById('edit-item-image');
    if (imageInput.files[0]) {
        formData.append('image', imageInput.files[0]);
    }

    const res = await api('update_product', formData, 'POST');
    if (res.success) {
        showToast('Product updated');
        closeModal('edit-product-modal');
        loadMenuItems(); loadProducts();
    }
}

function editStaff(id) {
    api('get_staff', { limit: 1000 }).then(res => {
        const s = res.data.find(st => st.id == id);
        if (!s) return;
        document.getElementById('edit-staff-id').value = s.id;
        document.getElementById('edit-staff-name').value = s.name;
        document.getElementById('edit-staff-role').value = s.role;
        openModal('edit-staff-modal');
    });
}

async function saveStaffEdit() {
    const data = {
        id: document.getElementById('edit-staff-id').value,
        name: document.getElementById('edit-staff-name').value,
        role: document.getElementById('edit-staff-role').value
    };
    const res = await api('update_staff', data, 'POST');
    if (res.success) {
        showToast('Staff updated');
        closeModal('edit-staff-modal');
        loadStaff();
    }
}

function editExpense(id) {
    api('get_expenses', { limit: 1000 }).then(res => {
        const e = res.data.find(ex => ex.id == id);
        if (!e) return;
        document.getElementById('edit-expense-id').value = e.id;
        document.getElementById('edit-expense-desc').value = e.description;
        document.getElementById('edit-expense-cat').value = e.category;
        document.getElementById('edit-expense-amount').value = e.amount;
        openModal('edit-expense-modal');
    });
}

async function saveExpenseEdit() {
    const data = {
        id: document.getElementById('edit-expense-id').value,
        description: document.getElementById('edit-expense-desc').value,
        category: document.getElementById('edit-expense-cat').value,
        amount: document.getElementById('edit-expense-amount').value
    };
    const res = await api('update_expense', data, 'POST');
    if (res.success) {
        showToast('Expense updated');
        closeModal('edit-expense-modal');
        loadExpenses();
    }
}

function editInventory(id) {
    api('get_inventory', { limit: 1000 }).then(res => {
        const i = res.data.find(inv => inv.id == id);
        if (!i) return;
        document.getElementById('edit-inv-id').value = i.id;
        document.getElementById('edit-inv-name').value = i.name;
        document.getElementById('edit-inv-sku').value = i.sku;
        document.getElementById('edit-inv-min').value = i.min_quantity;
        document.getElementById('edit-inv-cost').value = i.cost_per_unit;

        let optHtml = '<option value="">Manual / No Supplier</option>';
        api('get_suppliers').then(supRes => {
            supRes.data.forEach(s => optHtml += `<option value="${s.id}" ${s.id == i.supplier_id ? 'selected' : ''}>${s.name}</option>`);
            document.getElementById('edit-inv-supplier').innerHTML = optHtml;
            openModal('edit-inventory-modal');
        });
    });
}

async function saveInventoryEdit() {
    const data = {
        id: document.getElementById('edit-inv-id').value,
        name: document.getElementById('edit-inv-name').value,
        sku: document.getElementById('edit-inv-sku').value,
        min_quantity: document.getElementById('edit-inv-min').value,
        cost_per_unit: document.getElementById('edit-inv-cost').value,
        supplier_id: document.getElementById('edit-inv-supplier').value
    };
    const res = await api('update_inventory_item', data, 'POST');
    if (res.success) {
        showToast('Inventory updated');
        closeModal('edit-inventory-modal');
        loadInventory();
    }
}

function editSupplier(id) {
    api('get_suppliers', { limit: 1000 }).then(res => {
        const s = res.data.find(sup => sup.id == id);
        if (!s) return;
        document.getElementById('edit-sup-id').value = s.id;
        document.getElementById('edit-sup-name').value = s.name;
        document.getElementById('edit-sup-contact').value = s.contact;
        document.getElementById('edit-sup-email').value = s.email;
        document.getElementById('edit-sup-address').value = s.address;
        openModal('edit-supplier-modal');
    });
}

async function saveSupplierEdit() {
    const data = {
        id: document.getElementById('edit-sup-id').value,
        name: document.getElementById('edit-sup-name').value,
        contact: document.getElementById('edit-sup-contact').value,
        email: document.getElementById('edit-sup-email').value,
        address: document.getElementById('edit-sup-address').value
    };
    const res = await api('update_supplier', data, 'POST');
    if (res.success) {
        showToast('Supplier updated');
        closeModal('edit-supplier-modal');
        loadSuppliers(); loadInventory();
    }
}


// ============ THEME MANAGEMENT ============
function toggleTheme() {
    const html = document.documentElement;
    const currentTheme = html.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';

    html.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);

    updateThemeIcon(newTheme);
}

function updateThemeIcon(theme) {
    const icon = document.getElementById('theme-icon');
    if (icon) {
        if (theme === 'dark') {
            icon.classList.remove('fa-moon');
            icon.classList.add('fa-sun');
        } else {
            icon.classList.remove('fa-sun');
            icon.classList.add('fa-moon');
        }
    }
}

// Initialize Theme
function initTheme() {
    const savedTheme = localStorage.getItem('theme') || 'light';
    document.documentElement.setAttribute('data-theme', savedTheme);
    updateThemeIcon(savedTheme);
}

// Call initTheme immediately to avoid flash
initTheme();

// ============ UI UTILITIES ============
const UI = {
    confirm: (title, message) => {
        return new Promise((resolve) => {
            document.getElementById('confirm-title').textContent = title || 'Are you sure?';
            document.getElementById('confirm-message').textContent = message || 'This action cannot be undone.';

            const modal = new bootstrap.Modal(document.getElementById('custom-confirm-modal'));
            const yesBtn = document.getElementById('confirm-yes-btn');

            // Clean up old listeners
            const newBtn = yesBtn.cloneNode(true);
            yesBtn.parentNode.replaceChild(newBtn, yesBtn);

            newBtn.onclick = () => {
                modal.hide();
                resolve(true);
            };

            const cancelBtn = document.querySelector('#custom-confirm-modal .btn-light');
            const newCancel = cancelBtn.cloneNode(true);
            cancelBtn.parentNode.replaceChild(newCancel, cancelBtn);

            newCancel.onclick = () => {
                resolve(false);
            };

            // Handle modal close via backdrop/esc (treat as cancel)
            const el = document.getElementById('custom-confirm-modal');
            const hiddenHandler = () => {
                resolve(false);
            };
            el.addEventListener('hidden.bs.modal', hiddenHandler, { once: true });

            // If user clicks yes, we want to avoid double-resolution (true then false from hidden)
            // But implementing complex state here is overkill for a simple confirm.
            // The logic: if resolved(true), the hidden handler will still fire but the promise is settled.
            // Wait, Promises only settle once. So if we resolve(true) on click, the hidden listener resolving(false) later does nothing.
            // Correct.

            modal.show();
        });
    }
};

// ============ DELETE HANDLERS ============
async function deleteInventoryItem(id) {
    if (await UI.confirm('Delete Stock Item?', 'This will permanently remove this item from inventory.')) {
        const res = await api('delete_inventory_item', { id }, 'POST');
        if (res.success) { showToast('Item deleted successfully'); loadInventory(); }
        else showToast(res.message || 'Failed to delete', 'error');
    }
}

async function deleteExpense(id) {
    if (await UI.confirm('Delete Expense?', 'This record will be permanently deleted.')) {
        const res = await api('delete_expense', { id }, 'POST');
        if (res.success) { showToast('Expense deleted'); loadExpenses(); }
        else showToast(res.message || 'Failed to delete', 'error');
    }
}

async function deleteStaff(id) {
    if (await UI.confirm('Remove Staff Member?', 'Their access and history will remain, but they won\'t be listed.')) {
        const res = await api('delete_staff', { id }, 'POST');
        if (res.success) { showToast('Staff removed'); loadStaff(); }
        else showToast(res.message || 'Failed to delete', 'error');
    }
}

async function deleteSupplier(id) {
    if (await UI.confirm('Delete Supplier?', 'This will remove the supplier from your list.')) {
        const res = await api('delete_supplier', { id }, 'POST');
        if (res.success) { showToast('Supplier deleted'); loadSuppliers(); }
        else showToast(res.message || 'Failed to delete', 'error');
    }
}

async function deleteProduct(id) {
    if (await UI.confirm('Delete Product?', 'This product will be removed from the menu.')) {
        const res = await api('delete_product', { id }, 'POST');
        if (res.success) { showToast('Product deleted'); loadMenuItems(); }
        else showToast(res.message || 'Failed to delete', 'error');
    }
}

// ============ DATATABLES ADAPTER ============

// ============================================================================
// ENHANCED SHIFT MANAGEMENT & Z-REPORT MODULE
// ============================================================================

let currentShift = null;
let shiftRefreshInterval = null;

/**
 * Initialize Z-Report page
 */
async function initZReportPage() {
    console.log('Initializing Z-Report Page...');

    // Load current shift status
    await loadCurrentShift();

    // Load shift history
    loadShiftHistory(1);

    // Start auto-refresh if shift is active
    if (currentShift && currentShift.status === 'open') {
        startShiftAutoRefresh();
    }
}

function loadZReportPage() {
    initZReportPage();
}

/**
 * Load current shift with real-time stats
 */
async function loadCurrentShift() {
    try {
        const result = await api('get_current_shift');

        if (!result.success) {
            // If backend says success:false, it might mean no shift or error.
            // In either case, for the UI, we should probably show "Closed" state 
            // rather than hidden with error, to allow "Open Shift"
            console.warn('Shift status check failed or no shift:', result.message);
            currentShift = null;
        } else {
            currentShift = result.shift;
        }
    } catch (e) {
        console.error('Network error checking shift:', e);
        currentShift = null;
    }

    updateShiftUI();

    // Load expenses if shift is active
    if (currentShift) {
        loadShiftExpenses(currentShift.id);
    }
}

/**
 * Update UI based on current shift status
 */
function updateShiftUI() {
    const closedState = document.getElementById('shift-closed-state');
    const openState = document.getElementById('shift-open-state');

    if (!currentShift) {
        // No active shift -> Show Closed State
        if (closedState) closedState.style.display = 'block';
        if (openState) openState.style.display = 'none';

        // Reset Dashboard / Top Bar indicators if they exist
        const statusDot = document.getElementById('shift-status-dot');
        if (statusDot) statusDot.innerHTML = '<div class="status-dot bg-secondary"></div>';

    } else {
        // Active shift -> Show Open State
        if (closedState) closedState.style.display = 'none';
        if (openState) openState.style.display = 'block';

        // Update Header/Subtitle
        const titleEl = document.getElementById('current-shift-title');
        const subtitleEl = document.getElementById('current-shift-subtitle');
        const startCashEl = document.getElementById('zr-display-start-cash');

        if (subtitleEl) {
            const duration = calculateDuration(currentShift.opened_at);
            const businessDate = new Date(currentShift.opened_at).toLocaleDateString(undefined, { weekday: 'short', month: 'short', day: 'numeric' });
            subtitleEl.innerHTML = `Business Day: <strong>${businessDate}</strong> &bull; Opened ${duration} ago by ${currentShift.opened_by_name || 'User'}`;
        }

        if (startCashEl) {
            startCashEl.textContent = formatCurrency(currentShift.start_cash || 0);
        }

        // Update Top Bar Status
        const statusDot = document.getElementById('shift-status-dot');
        if (statusDot) statusDot.innerHTML = '<div class="status-dot bg-success pulse"></div>';

        // Update Stats on Pulse
        if (document.getElementById('zr-page-total-sales')) {
            const totalSales = parseFloat(currentShift.total_sales) || 0;
            const totalExpenses = parseFloat(currentShift.total_expenses) || 0;
            const netProfit = totalSales - totalExpenses;

            document.getElementById('zr-page-total-sales').textContent = formatCurrency(totalSales);
            document.getElementById('zr-page-order-count').textContent = currentShift.order_count || 0;
            document.getElementById('zr-page-avg-value').textContent = formatCurrency(currentShift.order_count > 0 ? (totalSales / currentShift.order_count) : 0);

            document.getElementById('zr-page-cash-sales').textContent = formatCurrency(currentShift.cash_sales || 0);
            document.getElementById('zr-page-card-sales').textContent = formatCurrency(currentShift.card_sales || 0);

            document.getElementById('zr-page-voids').textContent = currentShift.void_count || 0;
            document.getElementById('zr-page-expenses').textContent = formatCurrency(totalExpenses);

            // Update Financial Summary Section
            const summaryRevenue = document.getElementById('zr-summary-revenue');
            const summaryExpenses = document.getElementById('zr-summary-expenses');
            const netProfitEl = document.getElementById('zr-page-net-profit');

            if (summaryRevenue) summaryRevenue.textContent = formatCurrency(totalSales);
            if (summaryExpenses) summaryExpenses.textContent = formatCurrency(totalExpenses);

            // Net Profit = Sales - Expenses with dynamic color
            if (netProfitEl) {
                netProfitEl.textContent = formatCurrency(netProfit);
                netProfitEl.style.color = netProfit >= 0 ? '#12B76A' : '#F04438';
            }
        }
    }
}

/**
 * Calculate duration from timestamp
 */
function calculateDuration(startTime) {
    const start = new Date(startTime);
    const now = new Date();
    const diff = Math.floor((now - start) / 1000); // seconds

    const hours = Math.floor(diff / 3600);
    const minutes = Math.floor((diff % 3600) / 60);

    if (hours > 0) {
        return `${hours}h ${minutes}m`;
    }
    return `${minutes}m`;
}

/**
 * Open a new shift
 */
/**
 * Open a new shift
 */
async function openShift() {
    const startCashInput = document.getElementById('zr-starting-cash');
    const startCash = parseFloat(startCashInput.value) || 0;

    if (startCash < 0) {
        showToast('Invalid start cash amount', 'error');
        return;
    }

    const result = await api('open_shift', { initial_cash: startCash }, 'POST');

    if (result.success) {
        showToast('Shift Opened Successfully', 'success');
        // Refresh status
        await checkShiftStatus();
        loadDashboard(); // Refresh dashboard
        // UI will update automatically via checkShiftStatus -> updateShiftUI
    } else {
        showToast(result.message || 'Failed to open shift', 'error');
    }
}

/**
 * Close shift and generate Z-Report
 */
async function closeShift() {
    if (!currentShift) return;

    const actualCashInput = document.getElementById('zr-page-actual-cash');
    const actualCash = parseFloat(actualCashInput.value) || 0;
    const notes = document.getElementById('zr-notes').value;

    if (actualCash === 0) {
        if (!await UI.confirm('Confirm Zero Cash?', 'You entered $0.00 as actual cash. Is this correct?')) {
            return;
        }
    }

    const result = await api('close_shift_complete', {
        shift_id: currentShift.id,
        actual_cash: actualCash,
        notes: notes
    }, 'POST');

    if (result.success) {
        showToast('Shift Closed Successfully', 'success');
        await checkShiftStatus(); // Will set currentShift to null
        loadShiftHistory(1); // Refresh history
        loadDashboard(); // Refresh dashboard

        // Show report (optional, or print)
        // If result.shift contains analytics, we could show a modal summary
    } else {
        showToast(result.message || 'Failed to close shift', 'error');
    }
}

function updateShiftUI() {
    const closedState = document.getElementById('shift-closed-state');
    const openState = document.getElementById('shift-open-state');

    if (!closedState || !openState) return; // Not on Z-Report page

    if (currentShift && currentShift.status === 'open') {
        closedState.style.display = 'none';
        openState.style.display = 'block';

        // Update Stats
        document.getElementById('zr-display-start-cash').textContent = formatCurrency(currentShift.start_cash || 0);
        document.getElementById('zr-page-total-sales').textContent = formatCurrency(currentShift.total_sales || 0);
        document.getElementById('zr-page-order-count').textContent = currentShift.total_orders || currentShift.order_count || 0;

        const avg = currentShift.total_orders > 0 ? (currentShift.total_sales / currentShift.total_orders) : 0;
        document.getElementById('zr-page-avg-value').textContent = formatCurrency(avg);

        // We need breakdown data. checking if currentShift has it?
        // ShiftController::getCurrentShift returns simple shift data.
        // We might need to call getShiftDetails for full stats if not present in currentShift object
        // But for now let's assume currentShift has basic stats or we fetch them separately.

        // If expenses/voids are not in currentShift, we might show 0 or fetch details
        // Update: checkShiftStatus calls get_current_shift which calls getActiveShiftData (simple).
        // we might need to enhance get_current_shift to return stats OR call get_shift_details here.

        // Let's rely on loadCurrentShift() calling a detail endpoint if open?
        // Or better, make updateShiftUI trigger a stat fetch if needed.
        loadZReportStats(); // Helper to fetch live stats

    } else {
        closedState.style.display = 'block';
        openState.style.display = 'none';
    }
}

async function loadZReportStats() {
    if (!currentShift) return;
    const result = await api('get_shift_details', { shift_id: currentShift.id });
    if (result.success && result.shift) {
        const s = result.shift;
        // Update detailed stats
        document.getElementById('zr-page-total-sales').textContent = formatCurrency(s.total_sales || 0);
        document.getElementById('zr-page-order-count').textContent = s.total_orders || 0;

        // Calculate missing stats or use what's available
        // Backend getShiftDetails returns orders and expenses arrays. We need to sum them on Client or Backend.
        // Backend getShiftDetails (updated) returns total_orders, total_sales.
        // It does NOT return cash_sales/card_sales breakdown yet in the simple version?
        // Wait, my updated closeShiftComplete calculates them, but getShiftDetails just returns totals?
        // Let's compute from orders array if present

        let cashSales = 0;
        let cardSales = 0;
        let voids = 0;
        let voidAmount = 0;

        if (s.orders && Array.isArray(s.orders)) {
            s.orders.forEach(o => {
                if (o.status === 'completed') {
                    // Default to cash if payment_method missing
                    const method = o.payment_method || 'cash';
                    if (method === 'cash') cashSales += parseFloat(o.total);
                    else cardSales += parseFloat(o.total);
                } else if (o.status === 'deleted') {
                    voids++;
                    voidAmount += parseFloat(o.total);
                }
            });
        }

        document.getElementById('zr-page-cash-sales').textContent = formatCurrency(cashSales);
        document.getElementById('zr-page-card-sales').textContent = formatCurrency(cardSales);
        document.getElementById('zr-page-voids').textContent = voids; // + " ($" + voidAmount + ")"

        // Expenses
        let totalExpenses = 0;
        if (s.expenses && Array.isArray(s.expenses)) {
            s.expenses.forEach(e => totalExpenses += parseFloat(e.amount));
        }
        document.getElementById('zr-page-expenses').textContent = formatCurrency(totalExpenses);

        const netProfit = (s.total_sales || 0) - totalExpenses;
        document.getElementById('zr-page-net-profit').textContent = formatCurrency(netProfit);

        const avg = s.total_orders > 0 ? (s.total_sales / s.total_orders) : 0;
        document.getElementById('zr-page-avg-value').textContent = formatCurrency(avg);
    }
}

let shiftHistoryData = [];

async function loadShiftHistory(page = 1) {
    const tbody = document.getElementById('shift-history-body');
    if (!tbody) return;

    const result = await api('get_zreport_history', { page, limit: 5 });

    if (result.success) {
        shiftHistoryData = result.data; // Store for valid usage
        let html = '';
        if (result.data.length === 0) {
            html = '<tr><td colspan="8" class="text-center text-muted">No history found</td></tr>';
        } else {
            result.data.forEach((s, index) => {
                // Parse JSON data if needed
                let details = {};
                try {
                    details = typeof s.json_data === 'string' ? JSON.parse(s.json_data) : (s.json_data || {});
                } catch (e) { }

                // Map DB columns to UI expected format for Z-Report
                s.uiData = {
                    shift_number: s.id,
                    opened_at: s.shift_start || s.start_time,
                    closed_at: s.shift_end || s.end_time,
                    total_sales: parseFloat(s.total_sales || 0),
                    order_count: parseInt(s.total_orders || 0),
                    avg_order_value: parseInt(s.total_orders) > 0 ? (s.total_sales / s.total_orders) : 0,
                    cash_sales: parseFloat(s.total_cash_sales || details.cash_sales || 0),
                    card_sales: parseFloat(s.total_card_sales || details.card_sales || 0),
                    void_count: parseInt(s.total_voids || 0),
                    void_amount: parseFloat(s.total_void_amount || 0),
                    refund_count: parseInt(s.total_refunds || 0),
                    refund_amount: 0,
                    total_expenses: parseFloat(s.total_expenses || 0),
                    starting_cash: parseFloat(details.start_cash || 0),
                    expected_cash: parseFloat(s.expected_cash || 0),
                    ending_cash: parseFloat(s.actual_cash || 0),
                    cash_difference: parseFloat(s.difference || 0),
                    net_profit: parseFloat(s.total_sales || 0) - parseFloat(s.total_expenses || 0)
                };

                html += `
                    <tr>
                        <td class="ps-4 fw-bold">#${s.id}</td>
                        <td>${formatDate(s.shift_start || s.start_time)}<br><small class="text-muted">${formatTime(s.shift_start || s.start_time)}</small></td>
                        <td>${(s.shift_end || s.end_time) ? formatDate(s.shift_end || s.end_time) + '<br><small class="text-muted">' + formatTime(s.shift_end || s.end_time) + '</small>' : '<span class="badge bg-success">Active</span>'}</td>
                        <td class="fw-bold text-success">${formatCurrency(s.total_sales || 0)}</td>
                        <td class="text-danger">${formatCurrency(s.total_expenses || 0)}</td>
                        <td class="fw-bold" style="color: ${parseFloat(s.net_profit || 0) >= 0 ? '#12B76A' : '#F04438'};">${formatCurrency(s.net_profit || 0)}</td>
                        <td>${s.user_name || s.opened_by_name || 'User'}</td>
                        <td class="text-end pe-4">
                            <button class="btn btn-sm btn-primary" onclick="viewShiftReport(${index})"><i class="fas fa-eye"></i> View</button>
                        </td>
                    </tr>
                `;
            });
        }
        tbody.innerHTML = html;
    }
}

function viewShiftReport(index) {
    if (shiftHistoryData[index] && shiftHistoryData[index].uiData) {
        displayZReport(shiftHistoryData[index].uiData);
    }
}

function formatTime(dateStr) {
    if (!dateStr) return '';
    return new Date(dateStr).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
}

/**
 * Display Z-Report after shift closes
 */
function displayZReport(shiftData) {
    // Create a modal or dedicated section to show the Z-Report
    const reportHTML = generateZReportHTML(shiftData);

    // Show in modal
    const modal = new bootstrap.Modal(document.getElementById('zreport-modal') || createZReportModal());
    document.getElementById('zreport-modal-body').innerHTML = reportHTML;
    modal.show();
}

/**
 * Generate Z-Report HTML
 */
function generateZReportHTML(shift) {
    const analytics = shift.analytics || {};

    return `
        <div class="z-report-container">
            <!-- Header -->
            <div class="report-header text-center mb-4">
                <h2 class="fw-bold">Z-REPORT</h2>
                <p class="mb-1">Shift: ${shift.shift_number}</p>
                <p class="small text-muted">
                    ${new Date(shift.opened_at).toLocaleString()} - ${new Date(shift.closed_at).toLocaleString()}
                </p>
                <p class="small text-muted">Duration: ${calculateDuration(shift.opened_at)}</p>
            </div>
            
            <!-- Sales Summary -->
            <div class="report-section mb-4">
                <h5 class="fw-bold border-bottom pb-2">Sales Summary</h5>
                <div class="d-flex justify-content-between">
                    <span>Total Sales</span>
                    <strong>${formatCurrency(shift.total_sales)}</strong>
                </div>
                <div class="d-flex justify-content-between">
                    <span>Number of Orders</span>
                <div class="d-flex justify-content-between">
                    <span>Average Order Value</span>
                    <strong>${formatCurrency(shift.avg_order_value)}</strong>
                </div>
                <div class="d-flex justify-content-between mt-2 pt-2 border-top">
                    <span>Cash Sales</span>
                    <strong>${formatCurrency(shift.cash_sales)}</strong>
                </div>
                <div class="d-flex justify-content-between">
                    <span>Card Sales</span>
                    <strong>${formatCurrency(shift.card_sales)}</strong>
                </div>
            </div>
            
            <!-- Deductions -->
            <div class="report-section mb-4">
                <h5 class="fw-bold border-bottom pb-2">Deductions</h5>
                <div class="d-flex justify-content-between text-danger">
                    <span>Voids (${shift.void_count})</span>
                    <strong>${formatCurrency(shift.void_amount || 0)}</strong>
                </div>
                <div class="d-flex justify-content-between text-warning">
                    <span>Refunds (${shift.refund_count})</span>
                    <strong>${formatCurrency(shift.refund_amount || 0)}</strong>
                </div>
                <div class="d-flex justify-content-between">
                    <span>Discounts</span>
                    <strong>${formatCurrency(shift.discount_amount || 0)}</strong>
                </div>
            </div>
            
            <!-- Cash Reconciliation -->
            <div class="report-section mb-4">
                <h5 class="fw-bold border-bottom pb-2">Cash Reconciliation</h5>
                <div class="d-flex justify-content-between">
                    <span>Starting Cash</span>
                    <strong>${formatCurrency(shift.starting_cash)}</strong>
                </div>
                <div class="d-flex justify-content-between">
                    <span>+ Cash Sales</span>
                    <strong>${formatCurrency(shift.cash_sales)}</strong>
                </div>
                <div class="d-flex justify-content-between">
                    <span>- Expenses</span>
                    <strong>${formatCurrency(shift.total_expenses)}</strong>
                </div>
                <div class="d-flex justify-content-between mt-2 pt-2 border-top">
                    <span>Expected Cash</span>
                    <strong>${formatCurrency(shift.expected_cash)}</strong>
                </div>
                <div class="d-flex justify-content-between">
                    <span>Actual Cash</span>
                    <strong>${formatCurrency(shift.ending_cash)}</strong>
                </div>
                <div class="d-flex justify-content-between mt-2 pt-2 border-top ${shift.cash_difference >= 0 ? 'text-success' : 'text-danger'}">
                    <span>Difference (${shift.cash_difference >= 0 ? 'Over' : 'Short'})</span>
                    <strong>${formatCurrency(Math.abs(shift.cash_difference))}</strong>
                </div>
            </div>
            
            <!-- Net Profit -->
            <div class="report-section mb-4 bg-light p-3 rounded">
                <div class="d-flex justify-content-between fs-5">
                    <span class="fw-bold">Total Revenue</span>
                    <strong>${formatCurrency(shift.total_sales)}</strong>
                </div>
                <div class="d-flex justify-content-between fs-5">
                    <span class="fw-bold">Total Expenses</span>
                    <strong>${formatCurrency(shift.total_expenses)}</strong>
                </div>
                <div class="d-flex justify-content-between fs-4 mt-2 pt-2 border-top text-success">
                    <span class="fw-bold">NET PROFIT</span>
                    <strong>${formatCurrency(shift.net_profit)}</strong>
                </div>
            </div>
            
            <!-- Print Button -->
            <div class="text-center mt-4">
                <button class="btn btn-primary me-2" onclick="printZReportThermal(${shift.id})">
                    <i class="fas fa-print me-2"></i>Print Receipt
                </button>
                <button class="btn btn-outline-primary" onclick="exportShiftToPDF(${shift.id})">
                    <i class="fas fa-file-pdf me-2"></i>Export PDF
                </button>
            </div>
        </div>
    `;
}

/**
 * Create Z-Report Modal
 */
function createZReportModal() {
    const modalHTML = `
        <div class="modal fade" id="zreport-modal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Shift Z-Report</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body" id="zreport-modal-body"></div>
                </div>
            </div>
        </div>
    `;
    document.body.insertAdjacentHTML('beforeend', modalHTML);
    return document.getElementById('zreport-modal');
}

/**
 * Load shift history with pagination
 */
async function loadShiftHistory(page = 1) {
    const search = document.getElementById('shift-search')?.value || '';
    const startDate = document.getElementById('shift-start-date')?.value || '';
    const endDate = document.getElementById('shift-end-date')?.value || '';

    const result = await api('get_shift_history', {
        page,
        limit: 10,
        search,
        start_date: startDate,
        end_date: endDate
    });

    if (!result.success) {
        showToast('Failed to load shift history', 'error');
        return;
    }

    renderShiftHistory(result.data, result.pagination);
}

/**
 * Render shift history table
 */
function renderShiftHistory(shifts, pagination) {
    const tbody = document.getElementById('shift-history-tbody');
    if (!tbody) return;

    if (!shifts || shifts.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" class="text-center text-muted">No shift history found</td></tr>';
        return;
    }

    let html = '';
    shifts.forEach(shift => {
        const cashDiffClass = shift.cash_difference >= 0 ? 'text-success' : 'text-danger';
        html += `
            <tr>
                <td>${shift.shift_number}</td>
                <td>${new Date(shift.opened_at).toLocaleDateString()}</td>
                <td>${shift.opened_by_name || 'Unknown'}</td>
                <td class="text-end">${formatCurrency(shift.total_sales)}</td>
                <td class="text-center">${shift.order_count}</td>
                <td class="text-end ${cashDiffClass}">${formatCurrency(shift.cash_difference)}</td>
                <td class="text-center align-middle">
                    <div class="action-cell">
                        <button class="btn-pro btn-view-pro" onclick="viewShiftDetails(${shift.id})" title="View Details">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                        </button>
                        <button class="btn-pro btn-print-pro" onclick="printZReportThermal(${shift.id})" title="Print">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 6 2 18 2 18 9"></polyline><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2-2v5a2 2 0 0 1-2 2h-2"></path><rect x="6" y="14" width="12" height="8"></rect></svg>
                        </button>
                    </div>
                </td>
            </tr>
        `;
    });

    tbody.innerHTML = html;

    // Render pagination
    if (pagination) {
        renderPagination('shift-history-pagination', pagination, 'loadShiftHistory');
    }
}

/**
 * View shift details
 */
async function viewShiftDetails(shiftId) {
    const result = await api('get_shift_details', { shift_id: shiftId });

    if (!result.success) {
        showToast('Failed to load shift details', 'error');
        return;
    }

    displayZReport(result.shift);
}


/**
 * Print Z-Report (Business Day Summary)
 */
async function printZReport() {
    const result = await api('get_business_day_stats'); // New API

    if (!result.success || !result.data) {
        showToast('Failed to load Z-Report data', 'error');
        return;
    }

    const data = result.data;
    const reportDate = new Date().toLocaleDateString();

    const printWindow = window.open('', '_blank', 'width=400,height=600');
    if (!printWindow) { showToast('Pop-up blocked', 'error'); return; }

    const html = `
    <html><head><style>
        body { font-family: monospace; padding: 20px; text-align: center; }
        .row { display: flex; justify-content: space-between; margin: 5px 0; }
        .divider { border-top: 1px dashed black; margin: 10px 0; }
        h3 { margin: 5px 0; }
    </style></head>
    <body>
        <h3>Z-REPORT</h3>
        <div>Date: ${reportDate}</div>
        <div class="divider"></div>
        <div class="row"><span>Total Sales:</span><strong>${formatCurrency(data.total_sales_inc_tax)}</strong></div>
        <div class="row"><span>Net Sales:</span><span>${formatCurrency(data.total_sales_exc_tax)}</span></div>
        <div class="row"><span>Orders:</span><span>${data.order_count}</span></div>
        <div class="divider"></div>
        <div class="row"><span>Cash Sales:</span><span>${formatCurrency(data.payment_methods.cash || 0)}</span></div>
        <div class="row"><span>Card Sales:</span><span>${formatCurrency(data.payment_methods.card || 0)}</span></div>
        <div class="divider"></div>
        <div class="row"><span>Total Expenses:</span><span>${formatCurrency(data.total_expenses)}</span></div>
        <div class="row"><span>Net Profit:</span><strong>${formatCurrency(data.net_profit)}</strong></div>
        <div class="divider"></div>
        <div>End of Report</div>
        <script>window.onload = function() { window.print(); window.close(); }<\/script>
    </body></html>`;

    printWindow.document.write(html);
    printWindow.document.close();
}

/**
 * Print Z-Report to thermal printer (Legacy/Mapped)
 */
async function printZReportThermal(shiftId) {
    // Redirect to new Logic
    printZReport();
}



/**
 * Format left-right aligned text for thermal printer
 */


/**
 * Export shift to PDF
 */
async function exportShiftToPDF(shiftId) {
    const result = await api('get_shift_details', { shift_id: shiftId });

    if (!result.success) {
        showToast('Failed to load shift data', 'error');
        return;
    }

    const shift = result.shift;

    // Use jsPDF (assuming it's loaded)
    if (typeof jsPDF === 'undefined') {
        showToast('PDF library not loaded', 'error');
        return;
    }

    const doc = new jsPDF();

    // Header
    doc.setFontSize(20);
    doc.text('Z-REPORT', 105, 20, { align: 'center' });
    doc.setFontSize(12);
    doc.text(shift.shift_number, 105, 30, { align: 'center' });
    doc.setFontSize(10);
    doc.text(`${new Date(shift.closed_at).toLocaleString()}`, 105, 36, { align: 'center' });

    let y = 50;

    // Sales Summary
    doc.setFontSize(14);
    doc.text('Sales Summary', 20, y);
    y += 10;
    doc.setFontSize(10);
    doc.text(`Total Sales: ${formatCurrency(shift.total_sales)}`, 20, y);
    y += 6;
    doc.text(`Orders: ${shift.order_count}`, 20, y);
    y += 6;
    doc.text(`Average Order: ${formatCurrency(shift.avg_order_value)}`, 20, y);
    y += 15;

    // Cash Reconciliation
    doc.setFontSize(14);
    doc.text('Cash Reconciliation', 20, y);
    y += 10;
    doc.setFontSize(10);
    doc.text(`Starting Cash: ${formatCurrency(shift.starting_cash)}`, 20, y);
    y += 6;
    doc.text(`Cash Sales: ${formatCurrency(shift.cash_sales)}`, 20, y);
    y += 6;
    doc.text(`Expected: ${formatCurrency(shift.expected_cash)}`, 20, y);
    y += 6;
    doc.text(`Actual: ${formatCurrency(shift.ending_cash)}`, 20, y);
    y += 6;
    doc.text(`Difference: ${formatCurrency(shift.cash_difference)}`, 20, y);
    y += 15;

    // Net Profit
    doc.setFontSize(14);
    doc.text(`NET PROFIT: ${formatCurrency(shift.net_profit)}`, 20, y);

    // Save
    doc.save(`Z-Report-${shift.shift_number}.pdf`);
    showToast('PDF exported successfully!', 'success');
}

/**
 * Add expense to current business day
 */
async function saveExpense() {
    const category = document.getElementById('expense-cat')?.value || '';
    const description = document.getElementById('expense-desc')?.value || '';
    const amount = parseFloat(document.getElementById('expense-amount')?.value) || 0;

    if (!category || !description || amount <= 0) {
        showToast('Please fill all fields', 'error');
        return;
    }

    // Use current business day via backend logic
    const result = await api('add_shift_expense', {
        category,
        description,
        amount
    }, 'POST');

    if (result.success) {
        showToast('Expense added successfully', 'success');
        // Clear form
        if (document.getElementById('expense-cat')) document.getElementById('expense-cat').value = 'Ingredients';
        if (document.getElementById('expense-desc')) document.getElementById('expense-desc').value = '';
        if (document.getElementById('expense-amount')) document.getElementById('expense-amount').value = '';

        closeModal('add-expense-modal');

        // Refresh expense list if we are on that view
        if (typeof loadExpenses === 'function') {
            loadExpenses();
        }
        // Also refresh Business Day stats if available
        if (typeof getBusinessDayStats === 'function') {
            getBusinessDayStats();
        }
    } else {
        showToast(result.message || 'Failed to add expense', 'error');
    }
}

/**
 * Start auto-refresh for shift stats
 */
function startShiftAutoRefresh() {
    stopShiftAutoRefresh(); // Clear any existing interval
    shiftRefreshInterval = setInterval(() => {
        if (currentShift && currentShift.status === 'open') {
            checkShiftStatus();
        }
    }, 30000); // Every 30 seconds
}

/**
 * Stop auto-refresh
 */
function stopShiftAutoRefresh() {
    if (shiftRefreshInterval) {
        clearInterval(shiftRefreshInterval);
        shiftRefreshInterval = null;
    }
}

/**
 * Print Z-Report page (for browser printing)
 */
function printZReportPage() {
    window.print();
}

// Initialize when View is loaded
document.addEventListener('viewChanged', function (e) {
    if (e.detail.view === 'zreport') {
        initZReportPage();
    } else if (e.detail.view === 'dashboard') {
        loadDashboard();
    }
});

/**
 * Toggle expense form visibility
 */
function toggleExpenseForm() {
    const form = document.getElementById('add-expense-form');
    if (form) {
        form.style.display = form.style.display === 'none' ? 'block' : 'none';
        // Focus first input if showing
        if (form.style.display === 'block') {
            const firstInput = form.querySelector('input');
            if (firstInput) firstInput.focus();
        }
    }
}

/**
 * Load expenses for the current business day
 */
async function loadExpenses() {
    const result = await api('get_business_day_expenses');
    if (result.success) {
        renderExpensesTable(result.expenses);
    } else {
        // showToast('Failed to load expenses', 'error'); // optional
    }
}

function getCategoryBadgeClass(category) {
    if (!category) return 'bg-primary';
    const cat = category.toLowerCase().trim();
    if (cat === 'food') return 'bg-success';
    if (cat === 'utilities') return 'bg-info text-dark';
    if (cat === 'rent') return 'bg-warning text-dark';
    if (cat === 'maintenance') return 'bg-secondary';
    return 'bg-primary';
}

function renderExpensesTable(expenses) {
    const tbody = document.getElementById('expenses-tbody');
    if (!tbody) return;

    if (!expenses || expenses.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted py-4">No expenses recorded for this business day</td></tr>';
        return;
    }

    let html = '';
    expenses.forEach(exp => {
        const badgeClass = getCategoryBadgeClass(exp.category);
        html += `
            <tr>
                <td class="align-middle">${formatDate(exp.created_at)} <small class="text-muted ms-1">${new Date(exp.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</small></td>
                <td class="align-middle"><span class="badge rounded-pill ${badgeClass}">${exp.category}</span></td>
                <td class="align-middle">${exp.description}</td>
                <td class="align-middle fw-bold">${formatCurrency(exp.amount)}</td>
                <td class="text-center align-middle">
                    <div class="action-cell">
                        <button class="btn-pro btn-edit-pro" onclick="editExpense(${exp.id})" title="Edit">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                        </button>
                        <button class="btn-pro btn-delete-pro" onclick="deleteExpense(${exp.id})" title="Delete">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
                        </button>
                    </div>
                </td>
            </tr>
        `;
    });
    tbody.innerHTML = html;
}

async function deleteExpense(id) {
    if (confirm('Are you sure you want to delete this expense?')) {
        const res = await api('delete_business_day_expense', { id }, 'POST');
        if (res.success) {
            showToast('Expense deleted');
            loadExpenses();
            if (typeof getBusinessDayStats === 'function') getBusinessDayStats();
        } else {
            showToast(res.message || 'Failed to delete', 'error');
        }
    }
}

// Edit Expense Logic
async function saveExpenseEdit() {
    const id = document.getElementById('edit-expense-id').value;
    const description = document.getElementById('edit-expense-desc').value;
    const category = document.getElementById('edit-expense-cat').value;
    const amount = document.getElementById('edit-expense-amount').value;

    const res = await api('update_expense', { id, description, category, amount }, 'POST');
    if (res.success) {
        showToast('Expense updated');
        closeModal('edit-expense-modal');
        loadExpenses();
        if (typeof getBusinessDayStats === 'function') getBusinessDayStats();
    } else {
        showToast(res.message || 'Update failed', 'error');
    }
}

function editExpense(id) {
    api('get_business_day_expenses').then(res => {
        if (res.success) {
            const exp = res.data.find(e => e.id == id);
            if (exp) {
                document.getElementById('edit-expense-id').value = exp.id;
                document.getElementById('edit-expense-desc').value = exp.description;
                document.getElementById('edit-expense-cat').value = exp.category;
                document.getElementById('edit-expense-amount').value = exp.amount;
                openModal('edit-expense-modal');
            }
        }
    });
}

/**
 * Load expenses for a specific shift
 */
async function loadShiftExpenses(shiftId) {
    const result = await api('get_shift_expenses', { shift_id: shiftId });

    if (result.success) {
        renderShiftExpenses(result.expenses);
    }
}

/**
 * Render expenses table
 */
function renderShiftExpenses(expenses) {
    const tbody = document.getElementById('shift-expenses-tbody');
    if (!tbody) return;

    if (!expenses || expenses.length === 0) {
        tbody.innerHTML = '<tr><td colspan="4" class="text-center text-muted py-3">No expenses recorded for this shift</td></tr>';
        return;
    }

    let html = '';
    expenses.forEach(exp => {
        html += `
            <tr>
                <td class="ps-4">${new Date(exp.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</td>
                <td>${exp.category}</td>
                <td>${exp.description}</td>
                <td class="text-end pe-4">${formatCurrency(exp.amount)}</td>
            </tr>
        `;
    });
    tbody.innerHTML = html;
}

/* ============ GLOBAL SHIFT HELPERS ============ */

/**
 * Check Business Day Status - Silent Update
 */
async function checkBusinessDayStatus() {
    try {
        // Safe check for API availability
        if (typeof api === 'undefined') {
            console.error("API function is missing in app.js!");
            return false;
        }

        const result = await api('get_business_day_status');

        if (result && result.success && result.business_day && result.business_day.status === 'open') {
            businessDayActive = true;
            // Update UI if needed
            const timerEl = document.getElementById('business-day-timer');
            if (timerEl) timerEl.style.display = 'block';
            return true;
        } else {
            businessDayActive = false;
            return false;
        }
    } catch (e) {
        console.error("Error checking business day:", e);
        businessDayActive = false; // Default to false on error
        return false;
    }
}

/**
 * Robust check before critical POS actions - Silent & Redirect
 */
async function ensureBusinessDaySession() {
    if (!businessDayActive) {
        await checkBusinessDayStatus();
    }

    if (!businessDayActive) {
        // Silent redirect to login if no active business day (should be auto-started by backend or login)
        // However, backend auto-starts it. If still false, something is wrong.
        // User requested: "redirect the user to login.php immediately without any alerts"
        window.location.href = 'login.php';
        return false;
    }
    return true;
}

function refreshBusinessDayTimer() {
    if (!businessDayStartTime) return;
    const now = new Date();
    const diff = Math.floor((now - businessDayStartTime) / 1000);
    const hrs = Math.floor(diff / 3600).toString().padStart(2, '0');
    const mins = Math.floor((diff % 3600) / 60).toString().padStart(2, '0');
    const secs = (diff % 60).toString().padStart(2, '0');
    const timerEl = document.getElementById('business-day-timer');
    if (timerEl) timerEl.innerText = `${hrs}:${mins}:${secs}`;
}
function updateShiftTimer() {
    // Optional global timer logic
}

/**
 * Ensure shift is active before performing action
 */


// End of Dashboard Logic

// Initial Load
document.addEventListener('DOMContentLoaded', () => {
    // Determine active view
    if (document.getElementById('dashboard-view') && document.getElementById('dashboard-view').classList.contains('active')) {
        loadDashboard();
    }
    // Check shift status on load
    // checkShiftStatus(); // Removed legacy call
});
// ============ SHIFT MANAGEMENT (MODAL) ============

// ============ SHIFT MANAGEMENT (MODAL) ============
// Manual Shift Management Removed
// function openShiftModal, closeShiftModal, handleStartShift, handleCloseShift removed

async function handleStartShift(e) {
    if (e) e.preventDefault();
    const startCashInput = document.getElementById('shift-start-cash');
    const startCash = startCashInput ? parseFloat(startCashInput.value) : 0;

    if (isNaN(startCash) || startCash < 0) {
        showToast('Please enter a valid starting cash amount', 'error');
        return;
    }

    try {
        const formData = new FormData();
        formData.append('action', 'open_shift');
        formData.append('initial_cash', startCash);

        const response = await fetch(API_URL, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('gusto_token')}`
            },
            body: formData
        });

        const result = await response.json();

        if (result.success) {
            showToast('Shift started successfully', 'success');
            closeModal('start-shift-modal');

            // Force Sync to get full state and update UI consistently
            await checkShiftStatus();

        } else {
            showToast(result.message || 'Failed to start shift', 'error');
        }
    } catch (error) {
        console.error('Shift error:', error);
        showToast('Network error starting shift', 'error');
    }
}

async function handleCloseShift(e) {
    if (e) e.preventDefault();
    const endCashInput = document.getElementById('shift-end-cash');
    const notesInput = document.getElementById('shift-end-notes');

    const endCash = endCashInput ? parseFloat(endCashInput.value) : 0;
    const notes = notesInput ? notesInput.value : '';

    if (isNaN(endCash) || endCash < 0) {
        showToast('Please enter valid cash amount', 'error');
        return;
    }

    // Confirm action removed as per request

    try {
        const formData = new FormData();
        formData.append('action', 'close_shift_complete'); // Use the correct action name
        formData.append('shift_id', activeShift);
        formData.append('actual_cash', endCash);
        formData.append('notes', notes);

        const response = await fetch(API_URL, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('gusto_token')}`
            },
            body: formData
        });

        const result = await response.json();

        if (result.success) {
            showToast('Shift closed successfully', 'success');
            if (typeof closeModal === 'function') closeModal('end-shift-modal');

            // Force Sync
            await checkShiftStatus();

            // Reload page after short delay to reset state fully?
            // Or just clear UI
            if (result.message) showToast(result.message, 'info');

        } else {
            showToast(result.message || 'Failed to close shift', 'error');
        }
    } catch (error) {
        console.error('Close Shift error:', error);
        showToast('Network error closing shift', 'error');
    }
}


/**
 * Update Shift UI (Sidebar Button & Timer)
 */
/**
 * Update Shift UI (Sidebar Button & Timer)
 * Consistently toggles between Start/End shift states
 */
// updateShiftUI removed




// ============ THERMAL SALES REPORT ============
async function printDetailedSalesSummary() {
    const fromTime = document.getElementById('report-from-time').value;
    const toTime = document.getElementById('report-to-time').value;

    if (!fromTime || !toTime) {
        showToast('Please select both Start and End times', 'warning');
        return;
    }

    try {
        const response = await fetch(`${API_URL}?action=get_sales_by_range&start=${fromTime}&end=${toTime}`);
        const result = await response.json();

        if (result.success) {
            const data = result.data;
            const totalSales = parseFloat(data.total_sales || 0).toFixed(2);
            const cashSales = parseFloat(data.cash_sales || 0).toFixed(2);
            // ... existing report logic ...

            const cardSales = parseFloat(data.card_sales || 0).toFixed(2);
            const orderCount = data.order_count || 0;

            // Update Display
            document.getElementById('report-total-display').textContent = formatCurrency(totalSales);

            // Print Thermal Receipt
            const printContent = `
                <div style="font-family: 'Courier New', monospace; width: 300px; text-align: center; font-size: 12px;">
                    <div style="font-size: 16px; font-weight: bold; margin-bottom: 5px;">SALES SUMMARY</div>
                    <div style="border-bottom: 1px dashed #000; margin-bottom: 10px;"></div>
                    
                    <div style="text-align: left; margin-bottom: 5px;">From: ${new Date(fromTime).toLocaleString()}</div>
                    <div style="text-align: left; margin-bottom: 10px;">To:   ${new Date(toTime).toLocaleString()}</div>
                    
                    <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                        <span>Total Orders:</span>
                        <span>${orderCount}</span>
                    </div>
                    
                    <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                        <span>Cash Sales:</span>
                        <span>${formatCurrency(cashSales)}</span>
                    </div>
                    
                    <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                        <span>Card Sales:</span>
                        <span>${formatCurrency(cardSales)}</span>
                    </div>
                    
                    <div style="border-top: 1px dashed #000; margin: 10px 0;"></div>
                    
                    <div style="display: flex; justify-content: space-between; font-size: 16px; font-weight: bold;">
                        <span>TOTAL:</span>
                        <span>${formatCurrency(totalSales)}</span>
                    </div>
                    
                    <div style="border-top: 1px dashed #000; margin: 10px 0;"></div>
                    <div style="margin-top: 10px; font-size: 10px;">Generated by GustoPOS</div>
                    <div style="font-size: 10px;">${new Date().toLocaleString()}</div>
                </div>
            `;

            // Create a hidden iframe for printing
            const iframe = document.createElement('iframe');
            iframe.style.display = 'none';
            document.body.appendChild(iframe);

            iframe.contentDocument.write(printContent);
            iframe.contentDocument.close();

            iframe.onload = function () {
                iframe.contentWindow.focus();
                iframe.contentWindow.print();
                setTimeout(() => document.body.removeChild(iframe), 1000);
            };

        } else {
            showToast('Failed to fetch sales data', 'error');
        }
    } catch (error) {
        console.error('Report error:', error);
        showToast('Error generating report', 'error');
    }
}

// Trigger calculation on date change
async function calculateRangeSales() {
    const fromTime = document.getElementById('report-from-time').value;
    const toTime = document.getElementById('report-to-time').value;

    if (fromTime && toTime) {
        try {
            const response = await fetch(`${API_URL}?action=get_sales_by_range&start=${fromTime}&end=${toTime}`);
            const result = await response.json();

            if (result.success) {
                const total = parseFloat(result.data.total_sales || 0);
                document.getElementById('report-total-display').textContent = formatCurrency(total);
            }
        } catch (e) { console.error(e); }
    }
}

// ============ PAGINATION HELPER ============
function renderPagination(container, pagination, callback) {
    if (!pagination || pagination.total_pages <= 1) {
        if (typeof container === 'string') container = document.getElementById(container);
        if (container) container.innerHTML = '';
        return;
    }

    const currentPage = parseInt(pagination.current_page);
    const totalPages = parseInt(pagination.total_pages);

    // Right aligned with margin (me-4) as requested
    let html = '<ul class="pagination pagination-sm justify-content-end me-4 mb-0">';

    // Previous
    html += `<li class="page-item ${currentPage === 1 ? 'disabled' : ''}">
                <a class="page-link" href="#" data-page="${currentPage - 1}">&laquo;</a>
             </li>`;

    // Numbers
    const range = [];
    if (totalPages <= 7) {
        for (let i = 1; i <= totalPages; i++) range.push(i);
    } else {
        range.push(1);
        if (currentPage > 3) range.push('...');

        let start = Math.max(2, currentPage - 1);
        let end = Math.min(totalPages - 1, currentPage + 1);

        for (let i = start; i <= end; i++) range.push(i);

        if (currentPage < totalPages - 2) range.push('...');
        range.push(totalPages);
    }

    range.forEach(p => {
        if (p === '...') {
            html += `<li class="page-item disabled"><span class="page-link">...</span></li>`;
        } else {
            html += `<li class="page-item ${p === currentPage ? 'active' : ''}">
                        <a class="page-link" href="#" data-page="${p}">${p}</a>
                     </li>`;
        }
    });

    // Next
    html += `<li class="page-item ${currentPage === totalPages ? 'disabled' : ''}">
                <a class="page-link" href="#" data-page="${currentPage + 1}">&raquo;</a>
             </li>`;

    html += '</ul>';

    if (typeof container === 'string') container = document.getElementById(container);
    if (container) container.innerHTML = html;
}

// ============ EVENT DELEGATION (Fix for Dynamic Content) ============
$(document).ready(function () {
    populateInventorySelects(); // Load inventory for direct linking

    // ✅ FIX: Use Event Delegation for dynamic pagination buttons
    $(document).on('click', '.pagination .page-link', function (e) {
        e.preventDefault();

        // 1. Get the page number safely
        // Support both data-page attribute and href parsing
        let page = $(this).data('page');
        if (!page && $(this).attr('href')) {
            const parts = $(this).attr('href').split('page=');
            if (parts.length > 1) page = parts[1];
        }

        // 2. Validation: Stop if page is missing or button is disabled
        if (!page || $(this).parent().hasClass('disabled')) {
            return;
        }

        console.log("Navigating to Page:", page);

        // 3. Identify Context and Call Correct Function based on Parent ID
        const containerId = $(this).closest('.pagination, .pagination-container').find('.pagination, ul').addBack().filter('.pagination, ul').attr('id') || $(this).closest('.pagination-container').attr('id');
        const parentId = $(this).closest('[id$="-pagination"]').attr('id') || $(this).closest('ul').attr('id');

        if (parentId === 'history-pagination') loadOrders(page);
        else if (parentId === 'deleted-pagination') loadDeletedOrders(page);
        else if (parentId === 'inventory-pagination') loadInventory(page);
        else if (parentId === 'suppliers-pagination') { if (typeof loadSuppliers === 'function') loadSuppliers(page); }
        else if (parentId === 'expenses-pagination') { if (typeof loadExpenses === 'function') loadExpenses(page); }
        else if (parentId === 'menu-pagination') { if (typeof loadMenuItems === 'function') loadMenuItems(page); }
        else if (parentId === 'recipes-pagination') { if (typeof loadRecipes === 'function') loadRecipes(page); }
        else if (containerId === 'staff-pagination') loadStaff(page);
        else if (parentId === 'shift-history-pagination') loadShiftHistory(page);
        else if (parentId === 'zr-history-pagination' || parentId === 'zr-history-table') loadZReportHistory(page);
        else {
            console.warn('Unknown pagination container:', parentId);
        }
    });

    // Inventory
    $(document).on('click', '.btn-edit-inventory', function () { editInventory($(this).data('id')); });
    $(document).on('click', '.btn-delete-inventory', function () { deleteInventoryItem($(this).data('id')); });

    // Suppliers
    $(document).on('click', '.btn-edit-supplier', function () { editSupplier($(this).data('id')); });
    $(document).on('click', '.btn-delete-supplier', function () { deleteSupplier($(this).data('id')); });

    // Recipes
    $(document).on('click', '.btn-delete-recipe', function () { deleteRecipe($(this).data('id')); });

    // Expenses
    $(document).on('click', '.btn-edit-expense', function () { editExpense($(this).data('id')); });
    $(document).on('click', '.btn-delete-expense', function () { deleteExpense($(this).data('id')); });

    // Staff
    $(document).on('click', '.btn-toggle-shift', function () { toggleShift($(this).data('id'), $(this).data('action')); });
    $(document).on('click', '.btn-edit-staff', function () { editStaff($(this).data('id')); });
    $(document).on('click', '.btn-delete-staff', function () { deleteStaff($(this).data('id')); });

    // Menu Items
    $(document).on('click', '.btn-edit-product', function () { editProduct($(this).data('id')); });
    $(document).on('click', '.btn-delete-product', function () { deleteProduct($(this).data('id')); });

    // Initial Load - MOVED HERE CORRECTLY
    loadSettings();
    if (window.location.hash) {
        switchView(window.location.hash.substring(1));
    } else {
        switchView('dashboard');
    }
});
// ============ SALES REPORT FILTERS ============
function applyQuickFilter(period) {
    const startInput = document.getElementById('report-start');
    const endInput = document.getElementById('report-end');

    if (!startInput || !endInput) return;

    const today = new Date();
    let startDate = new Date();
    let endDate = new Date();

    // Use local ISO format (YYYY-MM-DD)
    const toISODate = (date) => {
        const offset = date.getTimezoneOffset();
        const localDate = new Date(date.getTime() - (offset * 60 * 1000));
        return localDate.toISOString().split('T')[0];
    };

    switch (period) {
        case 'today':
            startDate = new Date();
            endDate = new Date();
            break;
        case 'yesterday':
            startDate.setDate(today.getDate() - 1);
            endDate.setDate(today.getDate() - 1);
            break;
        case 'week':
            startDate.setDate(today.getDate() - 7);
            endDate = new Date();
            break;
        case 'month':
            startDate = new Date(today.getFullYear(), today.getMonth(), 1);
            endDate = new Date();
            break;
    }

    startInput.value = toISODate(startDate);
    endInput.value = toISODate(endDate);

    // Automatically trigger the report generation
    if (typeof loadDetailedReport === 'function') {
        loadDetailedReport();
    } else if (typeof loadExportPreview === 'function') {
        loadExportPreview();
    } else {
        // Fallback: Trigger the generate button if it exists
        const btn = document.getElementById('generateBtn');
        if (btn) btn.click();
    }
}

// ============ SETTINGS WIZARD NAVIGATION ============
$(document).on('click', '.wiz-btn', function () {
    const targetId = $(this).data('target');

    // Update active button
    $('.wiz-btn').removeClass('active');
    $(this).addClass('active');

    // Switch panels
    $('.settings-panel').removeClass('active');
    $(`#${targetId}`).addClass('active');

    // Update Title
    const title = 'Settings / ' + $(this).text().trim();
    $('#settings-title-text').text(title);

    // Smooth scroll to top of settings
    window.scrollTo({ top: 0, behavior: 'smooth' });
});

// Default: Show first panel on load if in settings view
$(document).ready(function () {
    if ($('#settings-management-view').length > 0) {
        // Ensure first button is active if none
        if ($('.wiz-btn.active').length === 0) {
            $('.wiz-btn').first().click();
        }
    }
});

/**
 * Initialize Z-Report Page (Modal View)
 */
async function initZReportPage() {
    const result = await api('get_business_day_stats');

    if (!result.success || !result.data) {
        showToast('Failed to load business day stats', 'error');
        return;
    }

    const data = result.data;

    // Update UI Elements
    const setAmount = (id, val) => {
        const el = document.getElementById(id);
        if (el) el.textContent = val;
    };

    setAmount('zr-total-sales', formatCurrency(data.total_sales_inc_tax));
    setAmount('zr-order-count', data.order_count);
    setAmount('zr-voids', data.void_count || 0);

    // Expected Cash Calculation
    // Cash Sales - Expenses. (Expenses are deducted from cash drawer usually)
    const cashSales = parseFloat(data.payment_methods.cash || 0);
    const expenses = parseFloat(data.total_expenses || 0);
    const expected = cashSales - expenses;

    setAmount('zr-expected-cash', formatCurrency(expected));

    openModal('z-report-modal');
}
