<?php
// Settings Management View
?>
<div id="settings-management-view" class="view-section">
    <div class="container-fluid py-4">

        <!-- Command Center Header -->
        <div class="card border-0 shadow-sm rounded-4 mb-4">
            <div class="card-body p-4">
                <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
                    <div>
                        <h4 class="mb-0 fw-bold settings-header-title">
                            <i class="fas fa-cogs me-2 text-primary"></i>
                            Settings Management
                        </h4>
                        <small class="settings-header-subtitle">
                            Configure system preferences and modules
                        </small>
                    </div>

                    <div class="d-flex gap-2">
                        <button class="btn btn-light border shadow-sm fw-medium" onclick="loadManagementSettings()">
                            <i class="fas fa-sync-alt text-muted me-1"></i> Refresh
                        </button>
                        <button class="btn btn-primary shadow-sm fw-bold px-4" onclick="saveAllSettings()">
                            <i class="fas fa-save me-2"></i> Save Changes
                        </button>
                    </div>
                </div>

                <!-- Wizard Nav -->
                <div
                    class="settings-wizard-nav p-2 bg-light rounded-pill d-flex justify-content-center gap-2 flex-wrap">
                    <button class="wiz-btn active" data-target="panel-general"><i class="fas fa-info-circle"></i>
                        General</button>
                    <button class="wiz-btn" data-target="panel-inventory"><i class="fas fa-boxes"></i>
                        Inventory</button>
                    <button class="wiz-btn" data-target="panel-localization"><i class="fas fa-globe"></i>
                        Localization</button>
                    <button class="wiz-btn" data-target="panel-pos_logic"><i class="fas fa-cash-register"></i>
                        Order</button>
                    <button class="wiz-btn" data-target="panel-permissions"><i class="fas fa-user-shield"></i>
                        Permissions</button>
                    <button class="wiz-btn" data-target="panel-receipt"><i class="fas fa-file-invoice"></i>
                        Receipt</button>
                    <button class="wiz-btn" data-target="panel-printing"><i class="fas fa-print"></i> Printing</button>
                    <button class="wiz-btn" data-target="panel-system"><i class="fas fa-desktop"></i> System</button>
                    <button class="wiz-btn" data-target="panel-tables"><i class="fas fa-chair"></i> Tables</button>
                </div>
            </div>
        </div>

        <div class="row justify-content-center">
            <div class="col-lg-12">
                <div class="settings-wrapper shadow-sm rounded-4 bg-white p-5 border-0">

                    <!-- Content Area -->
                    <div class="settings-content">
                        <div class="row">
                            <div class="col-lg-12">
                                <form id="settings-management-form">

                                    <!-- 1. GENERAL INFO -->
                                    <div class="settings-panel active" id="panel-general">
                                        <h5 class="settings-section-title"><i class="fas fa-store"></i> Restaurant
                                            Information
                                        </h5>
                                        <div class="row g-4">
                                            <div class="col-12">
                                                <div class="card bg-light border-0 rounded-4 p-4 text-center mb-4">
                                                    <label class="form-label d-block fw-bold mb-3">Restaurant
                                                        Logo</label>
                                                    <div class="logo-preview-container mb-3 mx-auto">
                                                        <img id="logo-preview-img"
                                                            src="https://placehold.co/200x120/png?text=POS+Logo"
                                                            class="img-fluid rounded border shadow-sm"
                                                            style="max-height: 120px;">
                                                    </div>
                                                    <button type="button" class="btn btn-sm btn-outline-primary"
                                                        onclick="document.getElementById('logo-upload-input').click()">
                                                        <i class="fas fa-upload me-1"></i> Change Logo
                                                    </button>
                                                    <input type="file" id="logo-upload-input" hidden accept="image/*"
                                                        onchange="previewLogo(this)">
                                                    <div class="small text-muted mt-2">Recommended: PNG 400x200px</div>
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold">Restaurant Name</label>
                                                    <input type="text" name="restaurant_name"
                                                        class="form-control form-control-lg"
                                                        placeholder="Enter name...">
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold">Phone Number</label>
                                                    <input type="text" name="restaurant_phone"
                                                        class="form-control form-control-lg" placeholder="+92 ...">
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold">Address</label>
                                                    <textarea name="restaurant_address"
                                                        class="form-control form-control-lg" rows="3"
                                                        placeholder="Full address..."></textarea>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- 2. FINANCIALS -->
                                    <div class="settings-panel" id="panel-financials">
                                        <h5 class="settings-section-title"><i class="fas fa-coins"></i> Financial &
                                            Taxes</h5>
                                        <div class="row g-4">
                                            <div class="col-12">
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold">Tax Rate (%)</label>
                                                    <div class="input-group input-group-lg">
                                                        <input type="number" name="tax_rate" class="form-control"
                                                            step="0.01">
                                                        <span class="input-group-text">%</span>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold">Service Charge (%)</label>
                                                    <div class="input-group input-group-lg">
                                                        <input type="number" name="service_charge" class="form-control"
                                                            step="0.01">
                                                        <span class="input-group-text">%</span>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold">Packaging Fee</label>
                                                    <input type="number" name="packaging_fee"
                                                        class="form-control form-control-lg" step="0.01">
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold">Delivery Fee</label>
                                                    <input type="number" name="delivery_fee"
                                                        class="form-control form-control-lg" step="0.01">
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold">Currency Symbol</label>
                                                    <input type="text" name="currency_symbol"
                                                        class="form-control form-control-lg" maxlength="5">
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- 3. POS LOGIC -->
                                    <div class="settings-panel" id="panel-pos_logic">
                                        <h5 class="settings-section-title"><i class="fas fa-bolt"></i> POS Behavior &
                                            Logic</h5>
                                        <div class="row g-4">
                                            <div class="col-12">
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold">Rounding Rule</label>
                                                    <select name="rounding_rule" class="form-select form-select-lg">
                                                        <option value="None">No Rounding</option>
                                                        <option value="Nearest Whole">Nearest Whole Number</option>
                                                        <option value="Nearest 0.50">Nearest 0.50</option>
                                                        <option value="Nearest 10">Nearest 10</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="card bg-light border-0 p-4">
                                                    <div class="form-check form-switch mb-3 ps-5">
                                                        <input class="form-check-input ms-0" type="checkbox"
                                                            name="require_bill_before_payment" id="sw-bill">
                                                        <label class="form-check-label ms-2" for="sw-bill">Require Bill
                                                            Printing
                                                            before Payment</label>
                                                    </div>
                                                    <div class="form-check form-switch ps-5">
                                                        <input class="form-check-input ms-0" type="checkbox"
                                                            name="auto_merge_items" id="sw-merge">
                                                        <label class="form-check-label ms-2" for="sw-merge">Auto-merge
                                                            identical
                                                            items in cart</label>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- 4. TABLES -->
                                    <div class="settings-panel" id="panel-tables">
                                        <h5 class="settings-section-title"><i class="fas fa-th-large"></i> Floor Plan &
                                            Tables
                                        </h5>
                                        <div class="row g-4">
                                            <div class="col-12">
                                                <div class="card bg-light border-0 p-4 mb-4">
                                                    <div class="form-check form-switch mb-3 ps-5">
                                                        <input class="form-check-input ms-0" type="checkbox"
                                                            name="auto_release_table" id="sw-release">
                                                        <label class="form-check-label ms-2"
                                                            for="sw-release">Auto-release table
                                                            after payment</label>
                                                    </div>
                                                    <div class="form-check form-switch ps-5">
                                                        <input class="form-check-input ms-0" type="checkbox"
                                                            name="allow_table_transfer" id="sw-transfer">
                                                        <label class="form-check-label ms-2" for="sw-transfer">Allow
                                                            table
                                                            transfers</label>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <label class="form-label fw-bold mb-3">Status Colors</label>
                                                <div class="row g-3">
                                                    <div class="col-12">
                                                        <div class="d-flex align-items-center bg-light p-3 rounded-3">
                                                            <div style="flex: 1;"><label class="fw-semibold m-0">Free
                                                                    Table
                                                                    Color</label></div>
                                                            <input type="color" name="table_color_free"
                                                                class="form-control form-control-color"
                                                                style="width: 100px;">
                                                        </div>
                                                    </div>
                                                    <div class="col-12">
                                                        <div class="d-flex align-items-center bg-light p-3 rounded-3">
                                                            <div style="flex: 1;"><label class="fw-semibold m-0">Busy
                                                                    Table
                                                                    Color</label></div>
                                                            <input type="color" name="table_color_busy"
                                                                class="form-control form-control-color"
                                                                style="width: 100px;">
                                                        </div>
                                                    </div>
                                                    <div class="col-12">
                                                        <div class="d-flex align-items-center bg-light p-3 rounded-3">
                                                            <div style="flex: 1;"><label
                                                                    class="fw-semibold m-0">Reserved Table
                                                                    Color</label></div>
                                                            <input type="color" name="table_color_reserved"
                                                                class="form-control form-control-color"
                                                                style="width: 100px;">
                                                        </div>
                                                    </div>
                                                    <div class="col-12">
                                                        <div class="d-flex align-items-center bg-light p-3 rounded-3">
                                                            <div style="flex: 1;"><label class="fw-semibold m-0">Waiters
                                                                    Status
                                                                    Color</label></div>
                                                            <input type="color" name="table_color_waiters"
                                                                class="form-control form-control-color"
                                                                style="width: 100px;">
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- 5. PRINTING -->
                                    <div class="settings-panel" id="panel-printing">
                                        <h5 class="settings-section-title"><i class="fas fa-print"></i> KOT & Receipt
                                            Settings
                                        </h5>
                                        <div class="row g-4">
                                            <div class="col-12">
                                                <div class="mb-4">
                                                    <label class="form-label fw-semibold">KOT Print Copies</label>
                                                    <input type="number" name="kot_print_copies"
                                                        class="form-control form-control-lg" min="1" max="5">
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="card bg-light border-0 p-4 mb-4">
                                                    <div class="form-check form-switch mb-3 ps-5">
                                                        <input class="form-check-input ms-0" type="checkbox"
                                                            name="auto_print_kot" id="sw-autokot">
                                                        <label class="form-check-label ms-2" for="sw-autokot">Auto-print
                                                            KOT on
                                                            order save</label>
                                                    </div>
                                                    <div class="form-check form-switch mb-3 ps-5">
                                                        <input class="form-check-input ms-0" type="checkbox"
                                                            name="show_notes_on_kot" id="sw-kotnotes">
                                                        <label class="form-check-label ms-2" for="sw-kotnotes">Show
                                                            customer
                                                            notes on KOT</label>
                                                    </div>
                                                    <div class="form-check form-switch ps-5">
                                                        <input class="form-check-input ms-0" type="checkbox"
                                                            name="print_logo_on_kot" id="sw-kotlogo">
                                                        <label class="form-check-label ms-2" for="sw-kotlogo">Print Logo
                                                            on
                                                            KOT</label>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="mb-4">
                                                    <label class="form-label fw-semibold">Printer Type</label>
                                                    <select name="printer_type" class="form-select form-select-lg">
                                                        <option value="usb">Direct USB (WebUSB)</option>
                                                        <option value="bluetooth">Bluetooth (Web Bluetooth)</option>
                                                        <option value="network">Network/IP (LAN)</option>
                                                        <option value="spooler">System Spooler (Browser)</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="mb-4">
                                                    <label class="form-label fw-semibold">Paper Width</label>
                                                    <select name="paper_width" class="form-select form-select-lg">
                                                        <option value="80">80mm (Standard)</option>
                                                        <option value="58">58mm (Small)</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="mb-4">
                                                    <div class="row g-3 mb-4">
                                                        <div class="col-6">
                                                            <button type="button" class="btn btn-outline-dark w-100 py-2" onclick="Printer.init('bluetooth', 'counter')">
                                                                <i class="fab fa-bluetooth me-2"></i> Connect Counter Printer
                                                            </button>
                                                        </div>
                                                        <div class="col-6">
                                                            <button type="button" class="btn btn-outline-dark w-100 py-2" onclick="Printer.init('bluetooth', 'kitchen')">
                                                                <i class="fab fa-bluetooth me-2"></i> Connect Kitchen Printer
                                                            </button>
                                                        </div>
                                                    </div>
                                                    <button type="button" class="btn btn-outline-primary w-100 py-2"
                                                        onclick="testPrinterConnection()">
                                                        <i class="fas fa-print me-2"></i> Print Test Receipt
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- 6. INVENTORY -->
                                    <div class="settings-panel" id="panel-inventory">
                                        <h5 class="settings-section-title"><i class="fas fa-boxes"></i> Inventory
                                            Control</h5>
                                        <div class="row g-4">
                                            <div class="col-12">
                                                <div class="mb-4">
                                                    <label class="form-label fw-semibold">Stock Deduction Mode</label>
                                                    <select name="stock_deduction_mode"
                                                        class="form-select form-select-lg">
                                                        <option value="On Payment">On Full Payment</option>
                                                        <option value="On Order">Immediately on Order</option>
                                                        <option value="Manual">Manual Reconciliation</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="mb-4">
                                                    <label class="form-label fw-semibold">Low Stock Warning
                                                        Limit</label>
                                                    <input type="number" name="low_stock_warning_limit"
                                                        class="form-control form-control-lg">
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div
                                                    class="form-check form-switch p-4 bg-danger-subtle rounded border border-danger border-opacity-25 ps-5">
                                                    <input class="form-check-input ms-0" type="checkbox"
                                                        name="block_out_of_stock_orders" id="sw-blockstock">
                                                    <label class="form-check-label fw-bold ms-2"
                                                        for="sw-blockstock">Block
                                                        Out-of-Stock Orders</label>
                                                    <div class="small text-danger ms-2">Prevents adding items to cart if
                                                        quantity is 0 or less.</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- 7. LOCALIZATION -->
                                    <div class="settings-panel" id="panel-localization">
                                        <h5 class="settings-section-title"><i class="fas fa-globe"></i> Localization &
                                            Shift Settings</h5>
                                        <div class="row g-4">
                                            <div class="col-12">
                                                <div class="mb-4">
                                                    <label class="form-label fw-semibold">Business Day Start Hour
                                                        (Report Cutoff)</label>
                                                    <select name="business_day_start"
                                                        class="form-select form-select-lg">
                                                        <option value="0">00:00 (Midnight - Default)</option>
                                                        <option value="4">04:00 AM</option>
                                                        <option value="5">05:00 AM</option>
                                                        <option value="6">06:00 AM (Recommended for 4 AM Closing)
                                                        </option>
                                                        <option value="7">07:00 AM</option>
                                                        <option value="8">08:00 AM</option>
                                                    </select>
                                                    <div class="small text-muted mt-1">
                                                        Sales made before this time will count towards the previous
                                                        business day.
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="mb-4">
                                                    <label class="form-label fw-semibold">Date Format</label>
                                                    <select name="date_format" class="form-select form-select-lg">
                                                        <option value="DD/MM/YYYY">DD/MM/YYYY (31/12/2023)</option>
                                                        <option value="MM/DD/YYYY">MM/DD/YYYY (12/31/2023)</option>
                                                        <option value="YYYY-MM-DD">YYYY-MM-DD (2023-12-31)</option>
                                                        <option value="D MMM, YYYY">D MMM, YYYY (31 Dec, 2023)</option>
                                                    </select>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- 8. ORDER SETTINGS -->
                                    <div class="settings-panel" id="panel-order">
                                        <h5 class="settings-section-title"><i class="fas fa-shopping-cart"></i> Order
                                            Processing
                                            Settings</h5>
                                        <div class="row g-4">
                                            <div class="col-12">
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold">Default Order Type</label>
                                                    <select name="default_order_type"
                                                        class="form-select form-select-lg">
                                                        <!-- Populated via metadata -->
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold">Order Cancellation Grace
                                                        Period
                                                        (Minutes)</label>
                                                    <input type="number" name="order_cancel_grace_period"
                                                        class="form-control form-control-lg" min="0" max="60">
                                                    <div class="small text-muted mt-1">Time allowed to cancel after KOT
                                                        without
                                                        manager approval.</div>
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold">Token Reset Logic</label>
                                                    <select name="token_reset_logic" class="form-select form-select-lg">
                                                        <option value="daily">Daily Reset</option>
                                                        <option value="session">Per Shift/Session</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="card bg-light border-0 p-4">
                                                    <div class="form-check form-switch mb-3 ps-5">
                                                        <input class="form-check-input ms-0" type="checkbox"
                                                            name="allow_price_override" id="sw-price-override">
                                                        <label class="form-check-label ms-2"
                                                            for="sw-price-override">Allow Item
                                                            Price Override in Cart</label>
                                                    </div>
                                                    <div class="form-check form-switch mb-3 ps-5">
                                                        <input class="form-check-input ms-0" type="checkbox"
                                                            name="auto_merge_table_orders" id="sw-merge-tables">
                                                        <label class="form-check-label ms-2"
                                                            for="sw-merge-tables">Auto-merge
                                                            Table Orders</label>
                                                    </div>
                                                    <div class="form-check form-switch mb-3 ps-5">
                                                        <input class="form-check-input ms-0" type="checkbox"
                                                            name="show_order_timer" id="sw-timer-new">
                                                        <label class="form-check-label ms-2" for="sw-timer-new">Show
                                                            running
                                                            timer for active orders</label>
                                                    </div>
                                                    <div class="form-check form-switch ps-5">
                                                        <input class="form-check-input ms-0" type="checkbox"
                                                            name="allow_item_cancellation_after_kot" id="sw-cancel-kot">
                                                        <label class="form-check-label ms-2" for="sw-cancel-kot">Allow
                                                            Item
                                                            Cancellation After KOT (Legacy)</label>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- 9. RECEIPT CONFIGURATION -->
                                    <div class="settings-panel" id="panel-receipt">
                                        <h5 class="settings-section-title"><i class="fas fa-file-invoice"></i> Receipt
                                            Configuration</h5>
                                        <div class="row g-4">
                                            <div class="col-12">
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold">Receipt Layout Type</label>
                                                    <select name="receipt_layout_type"
                                                        class="form-select form-select-lg">
                                                        <option value="detailed">Detailed (Standard)</option>
                                                        <option value="compact">Compact (Minimalist)</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold">Receipt Font Size</label>
                                                    <select name="receipt_font_size" class="form-select form-select-lg">
                                                        <option value="small">Small (10px)</option>
                                                        <option value="medium">Medium (12px)</option>
                                                        <option value="large">Large (14px)</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold">Company Name / Header</label>
                                                    <input type="text" name="receipt_header"
                                                        class="form-control form-control-lg"
                                                        placeholder="e.g. Gusto POS">
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold">Custom Footer Note</label>
                                                    <textarea name="custom_footer_note"
                                                        class="form-control form-control-lg" rows="2"
                                                        placeholder="Thank you for visiting!"></textarea>
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="card bg-light border-0 p-4">
                                                    <div class="form-check form-switch mb-3 ps-5">
                                                        <input class="form-check-input ms-0" type="checkbox"
                                                            name="show_logo_on_receipt" id="sw-show-logo-new">
                                                        <label class="form-check-label ms-2" for="sw-show-logo-new">Show
                                                            Logo on
                                                            Receipts</label>
                                                    </div>
                                                    <div class="form-check form-switch mb-3 ps-5">
                                                        <input class="form-check-input ms-0" type="checkbox"
                                                            name="show_category_on_receipt" id="sw-show-cat">
                                                        <label class="form-check-label ms-2" for="sw-show-cat">Show Item
                                                            Categories</label>
                                                    </div>
                                                    <div class="form-check form-switch ps-5">
                                                        <input class="form-check-input ms-0" type="checkbox"
                                                            name="show_developer_branding" id="sw-branding">
                                                        <label class="form-check-label ms-2" for="sw-branding">Show
                                                            Developer
                                                            Branding</label>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- 10. SYSTEM SETTINGS -->
                                    <div class="settings-panel" id="panel-system">
                                        <h5 class="settings-section-title"><i class="fas fa-desktop"></i> System &
                                            Maintenance
                                        </h5>
                                        <div class="row g-4">
                                            <div class="col-12">
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold">Backup Storage Path</label>
                                                    <input type="text" name="backup_path"
                                                        class="form-control form-control-lg" placeholder="backups/">
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold">Log Retention Period</label>
                                                    <select name="log_retention_days"
                                                        class="form-select form-select-lg">
                                                        <option value="30">30 Days</option>
                                                        <option value="60">60 Days</option>
                                                        <option value="90">90 Days</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="card bg-light border-0 p-4">
                                                    <div class="form-check form-switch mb-3 ps-5">
                                                        <input class="form-check-input ms-0" type="checkbox"
                                                            name="maintenance_mode" id="sw-maint">
                                                        <label class="form-check-label ms-2" for="sw-maint">Enable
                                                            Maintenance
                                                            Mode</label>
                                                    </div>
                                                    <div class="form-check form-switch mb-3 ps-5">
                                                        <input class="form-check-input ms-0" type="checkbox"
                                                            name="debug_mode" id="sw-debug">
                                                        <label class="form-check-label ms-2" for="sw-debug">Enable Debug
                                                            Mode</label>
                                                    </div>
                                                    <div class="form-check form-switch ps-5">
                                                        <input class="form-check-input ms-0" type="checkbox"
                                                            name="auto_backup" id="sw-backup">
                                                        <label class="form-check-label ms-2" for="sw-backup">Auto-Backup
                                                            Database (Daily)</label>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold">System Version</label>
                                                    <input type="text" name="system_version"
                                                        class="form-control form-control-lg" readonly value="v2.5.0">
                                                    <div class="small text-muted mt-1">Gusto POS Core v2.5.0 Enterprise
                                                        Edition
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="col-12 mt-5">
                                                <div class="card border-danger bg-danger-subtle p-4">
                                                    <h6 class="text-danger fw-bold mb-3"><i
                                                            class="fas fa-exclamation-triangle"></i> DANGER ZONE</h6>
                                                    <p class="small text-muted">Resetting application data will clear
                                                        all
                                                        transactions, orders, and customer data. This action is
                                                        irreversible.
                                                    </p>
                                                    <button type="button" class="btn btn-danger px-4"
                                                        onclick="confirmDataReset()">
                                                        <i class="fas fa-trash-alt me-2"></i> Reset Application Data
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- 8. PERMISSIONS -->
                                    <div class="settings-panel" id="panel-permissions">
                                        <h5 class="settings-section-title"><i class="fas fa-user-lock"></i> Cashier
                                            Roles &
                                            Permissions</h5>
                                        <p class="text-muted small mb-4">Define what your cashier accounts can access in
                                            the
                                            system.</p>
                                        <div class="row g-4">
                                            <div class="col-12">
                                                <div class="card bg-light border-0 p-4 mb-4">
                                                    <div class="row g-3">
                                                        <div class="col-12">
                                                            <div class="form-check form-switch ps-5">
                                                                <input class="form-check-input ms-0" type="checkbox"
                                                                    name="cashier_access_pos" id="sw-cpos">
                                                                <label class="form-check-label ms-2"
                                                                    for="sw-cpos">Access POS
                                                                    (Ordering)</label>
                                                            </div>
                                                        </div>
                                                        <div class="col-12">
                                                            <div class="form-check form-switch ps-5">
                                                                <input class="form-check-input ms-0" type="checkbox"
                                                                    name="cashier_access_floor" id="sw-cfloor">
                                                                <label class="form-check-label ms-2"
                                                                    for="sw-cfloor">Access
                                                                    Floor Plan</label>
                                                            </div>
                                                        </div>
                                                        <div class="col-12">
                                                            <div class="form-check form-switch ps-5">
                                                                <input class="form-check-input ms-0" type="checkbox"
                                                                    name="cashier_view_reports" id="sw-creports">
                                                                <label class="form-check-label ms-2"
                                                                    for="sw-creports">View
                                                                    Sales Reports</label>
                                                            </div>
                                                        </div>
                                                        <div class="col-12">
                                                            <div class="form-check form-switch ps-5">
                                                                <input class="form-check-input ms-0" type="checkbox"
                                                                    name="cashier_export_data" id="sw-cexport">
                                                                <label class="form-check-label ms-2"
                                                                    for="sw-cexport">Export
                                                                    Sale Data (CSV/PDF)</label>
                                                            </div>
                                                        </div>
                                                        <div class="col-12">
                                                            <div class="form-check form-switch ps-5">
                                                                <input class="form-check-input ms-0" type="checkbox"
                                                                    name="cashier_access_settings" id="sw-csettings">
                                                                <label class="form-check-label ms-2"
                                                                    for="sw-csettings">Access
                                                                    Settings Management</label>
                                                            </div>
                                                        </div>
                                                        <div class="col-12">
                                                            <div class="form-check form-switch ps-5">
                                                                <input class="form-check-input ms-0" type="checkbox"
                                                                    name="cashier_void_orders" id="sw-cvoid">
                                                                <label class="form-check-label ms-2"
                                                                    for="sw-cvoid">Void/Delete
                                                                    Orders</label>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-12">
                                                <div class="form-check form-switch card p-4 border-0 bg-light ps-5">
                                                    <input class="form-check-input ms-0" type="checkbox"
                                                        name="cashier_hide_financial_data" id="sw-chidefin">
                                                    <label class="form-check-label fw-bold ms-2" for="sw-chidefin">Hide
                                                        Financial Dashboard from Cashier</label>
                                                    <div class="small text-muted ms-2">Hides total revenue and net
                                                        profit from
                                                        main dashboard for non-admins.</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
    /* Settings Specific Styling (Ensuring Dark Mode Compatibility) */
    [data-theme="dark"] .settings-tabs {
        background-color: #1E1E1E;
    }

    /* Header Card Styling */
    .wiz-btn {
        border: none;
        background: transparent;
        padding: 8px 18px;
        border-radius: 50px;
        font-size: 0.85rem;
        font-weight: 600;
        color: #6c757d;
        transition: all 0.3s ease;
    }

    .wiz-btn:hover {
        color: var(--primary-color, #ff6b00);
        background-color: rgba(0, 0, 0, 0.02);
    }

    .wiz-btn.active {
        background-color: white;
        color: var(--primary-color, #ff6b00) !important;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
    }

    .wiz-btn i {
        margin-right: 6px;
    }

    /* Content Animation */
    .settings-panel {
        display: none;
        max-width: 900px;
        margin: 0 auto;
    }

    .settings-panel.active {
        display: block;
        animation: slideUp 0.4s ease-out;
    }

    @keyframes slideUp {
        from {
            opacity: 0;
            transform: translateY(15px);
        }

        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    /* Dark mode support */
    [data-theme="dark"] .settings-wizard-nav {
        background-color: #1E1E1E !important;
    }

    [data-theme="dark"] .wiz-btn {
        color: #A0A0A0;
    }

    [data-theme="dark"] .settings-wrapper {
        background-color: #1E1E1E !important;
    }

    /* Clean up old sidebar styles if present */
    .settings-sidebar {
        display: none;
    }

    [data-theme="dark"] .settings-tab {
        color: #A0A0A0;
    }

    [data-theme="dark"] .settings-tab:hover {
        background-color: #2D2D2D;
        color: var(--primary);
    }

    [data-theme="dark"] .settings-tab.active {
        background: linear-gradient(135deg, var(--primary) 0%, #cc5500 100%);
        box-shadow: 0 4px 12px rgba(255, 107, 0, 0.2);
    }

    [data-theme="dark"] .settings-content {
        background-color: #1E1E1E;
    }

    [data-theme="dark"] .settings-section-title {
        color: #FFF;
        border-bottom-color: #333;
    }

    .logo-preview-container {
        width: 100%;
        max-width: 300px;
        height: 160px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: #f8f9fa;
        border: 2px dashed #ccc;
        border-radius: 12px;
        overflow: hidden;
    }

    [data-theme="dark"] .logo-preview-container {
        background: #2D2D2D;
        border-color: #444;
    }

    .settings-tab i {
        font-size: 1.1rem;
        width: 20px;
    }

    /* Professional Alignment Refinements */
    .form-control-lg,
    .form-select-lg {
        border-radius: 10px;
        padding-top: 0.75rem;
        padding-bottom: 0.75rem;
        font-size: 1rem;
    }

    .settings-panel {
        max-width: 900px;
        /* Centered layout within the col-12 */
        margin: 0 auto;
    }

    /* ===== SETTINGS HEADER (LIGHT + DARK FIX) ===== */

    /* Light mode (default) */
    .settings-header-title {
        color: #212529;
    }

    .settings-header-subtitle {
        color: #6c757d;
    }

    /* Dark mode */
    [data-theme="dark"] .settings-header-title {
        color: #ffffff;
    }

    [data-theme="dark"] .settings-header-subtitle {
        color: #a0a0a0;
    }
</style>

<script>
    /**
     * Danger Zone: Reset Application Data
     */
    async function confirmDataReset() {
        if (!confirm(
                "CRITICAL WARNING: This will permanently DELETE all orders, transactions, and customer data. Are you absolutely sure?"
            )) {
            return;
        }

        const confirmationCode = prompt("Please type 'RESET-GUSTO' to confirm this action:");
        if (confirmationCode !== 'RESET-GUSTO') {
            showToast('Invalid confirmation code. Action cancelled.', 'error');
            return;
        }

        showToast('Resetting application data...', 'info');

        try {
            const response = await fetch('backend.php?action=reset_application_data', {
                method: 'POST'
            });
            const result = await response.json();
            if (result.success) {
                showToast('Application data has been reset.', 'success');
                setTimeout(() => window.location.reload(), 2000);
            } else {
                showToast(result.message, 'error');
            }
        } catch (error) {
            showToast('Reset failed', 'error');
        }
    }
    let metadata = {};

    /**
     * Initialization and Logic for Settings Management
     */
    document.addEventListener('DOMContentLoaded', async function() {
        await fetchMetadata();
        await loadManagementSettings();
    });

    /**
     * Fetch all system metadata
     */
    async function fetchMetadata() {
        try {
            const response = await fetch('backend.php?action=get_metadata');
            const result = await response.json();
            if (result.success) {
                metadata = result.data;
                renderTabs(metadata.categories);
                populateMetadataDropdowns(metadata);
                renderPermissions(metadata.permissions);
            }
        } catch (error) {
            console.error('Metadata Fetch Error:', error);
            showToast('Failed to load system metadata', 'error');
        }
    }

    /**
     * Dynamically render sidebar tabs - DEPRECATED for Wizard
     */
    function renderTabs(categories) {
        // No-op for Wizard Layout
    }

    function switchTab(target) {
        // No-op, handled by app.js
    }

    /**
     * Populate dynamic dropdowns (Timezones, Printers, etc.)
     */
    function populateMetadataDropdowns(data) {
        // 1. Timezones
        const tzSelect = document.querySelector('[name="timezone"]');
        if (tzSelect) {
            tzSelect.innerHTML = data.timezones.map(tz => `<option value="${tz}">${tz}</option>`).join('');
        }

        // 2. Printer Types
        const printerSelect = document.querySelector('[name="printer_type"]');
        if (printerSelect) {
            printerSelect.innerHTML = data.printer_config.types.map(t => `<option value="${t.value}">${t.label}</option>`)
                .join('');
        }

        // 3. Paper Width
        const paperSelect = document.querySelector('[name="paper_width"]');
        if (paperSelect) {
            paperSelect.innerHTML = data.printer_config.widths.map(w => `<option value="${w.value}">${w.label}</option>`)
                .join('');
        }

        // 4. Default Order Type
        const orderTypeSelect = document.querySelector('[name="default_order_type"]');
        if (orderTypeSelect) {
            orderTypeSelect.innerHTML = data.order_types.map(ot => `<option value="${ot.slug}">${ot.name}</option>`).join(
                '');
        }
    }

    /**
     * Dynamically render permission toggles
     */
    function renderPermissions(permissions) {
        const container = document.querySelector('#panel-permissions .row.g-4 .col-12 .card .row.g-3');
        if (!container) return;

        container.innerHTML = permissions.map(p => `
            <div class="col-12">
                <div class="form-check form-switch ps-5">
                    <input class="form-check-input ms-0" type="checkbox" name="${p.slug}" id="sw-${p.slug}">
                    <label class="form-check-label ms-2" for="sw-${p.slug}">${p.name}</label>
                </div>
            </div>
        `).join('');
    }

    /**
     * Load settings from DB via AJAX
     */
    async function loadManagementSettings() {
        try {
            const response = await fetch('backend.php?action=get_settings_management');
            const result = await response.json();

            if (result.success) {
                const data = result.data;
                const form = document.getElementById('settings-management-form');

                // Loop through categories
                for (const category in data) {
                    const categorySettings = data[category];
                    for (const key in categorySettings) {
                        const value = categorySettings[key];
                        const input = form.querySelector(`[name="${key}"]`);

                        if (input) {
                            if (input.type === 'checkbox') {
                                input.checked = value === true;
                            } else if (input.type === 'color' || input.tagName === 'SELECT' || input.tagName ===
                                'INPUT' || input.tagName === 'TEXTAREA') {
                                input.value = value;
                            }
                        }

                        // Special handle for logo preview
                        if (key === 'restaurant_logo' && value) {
                            const logoImg = document.getElementById('logo-preview-img');
                            if (logoImg) logoImg.src = value + '?t=' + new Date().getTime();
                        }
                    }
                }
            }
        } catch (error) {
            console.error('Error loading settings:', error);
        }
    }

    /**
     * Save all settings via AJAX
     */
    async function saveAllSettings() {
        const form = document.getElementById('settings-management-form');
        const formData = new FormData(form);
        const settings = {};

        // Get all inputs including unchecked checkboxes
        form.querySelectorAll('input, select, textarea').forEach(input => {
            if (!input.name) return;

            if (input.type === 'checkbox') {
                settings[input.name] = input.checked;
            } else {
                settings[input.name] = input.value;
            }
        });

        try {
            // Retrieve CSRF token from meta tag
            const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

            const response = await fetch('backend.php?action=save_settings_management', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': csrfToken
                },
                body: JSON.stringify(settings)
            });

            const result = await response.json();
            if (result.success) {
                showToast('Settings saved successfully!', 'success');
                // Force refresh of app.js settings global if needed
                if (typeof loadAppSettings === 'function') loadAppSettings();
            } else {
                showToast(result.message, 'error');
            }
        } catch (error) {
            showToast('Failed to save settings', 'error');
        }
    }

    /**
     * Handle Logo Preview and Upload
     */
    function previewLogo(input) {
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                document.getElementById('logo-preview-img').src = e.target.result;
                // Auto start upload
                uploadLogoFile(input.files[0]);
            };
            reader.readAsDataURL(input.files[0]);
        }
    }

    async function uploadLogoFile(file) {
        const formData = new FormData();
        formData.append('logo', file);

        try {
            // Retrieve CSRF token from meta tag
            const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

            const response = await fetch('backend.php?action=upload_restaurant_logo', {
                method: 'POST',
                headers: {
                    'X-CSRF-Token': csrfToken
                },
                body: formData
            });
            const result = await response.json();
            if (result.success) {
                showToast('Logo uploaded successfully');
            } else {
                showToast(result.message, 'error');
            }
        } catch (error) {
            showToast('Logo upload failed', 'error');
        }
    }

    /**
     * Test Thermal Printer Connection
     */
    async function testPrinterConnection() {
        const form = document.getElementById('settings-management-form');
        const printerType = form.querySelector('[name="printer_type"]').value;
        const paperWidth = parseInt(form.querySelector('[name="paper_width"]').value);

        showToast(`Connecting to ${printerType} printer...`, 'info');

        const success = await Printer.init(printerType, paperWidth);
        if (!success) {
            showToast('Failed to initialize printer. Check hardware/permissions.', 'error');
            return;
        }

        const testData = {
            header: {
                name: 'TEST PRINT',
                address: 'Hardware Verification',
                phone: 'GustoPOS Hardware'
            },
            items: [{
                    name: 'Paper Check',
                    qty: 1,
                    price: 0
                },
                {
                    name: 'Hardware Link',
                    qty: 100,
                    price: 0
                }
            ],
            totals: {
                subtotal: 0,
                tax: 0,
                total: 0
            },
            footer: 'If you see this, your printer is READY!'
        };

        try {
            await Printer.print(testData);
            showToast('Test receipt sent successfully!', 'success');
        } catch (e) {
            showToast('Print failed: ' + e.message, 'error');
        }
    }
</script>