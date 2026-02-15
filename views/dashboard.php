<?php
// Dashboard View Module
?>
<div id="dashboard-view" class="view-section active">
    <div class="page-header d-flex justify-content-between align-items-center mb-4">
        <div>
            <h3 class="fw-bold mb-1">Business Overview</h3>
            <p class="text-muted mb-0 small text-uppercase fw-semibold" style="letter-spacing: 1px;">Live Analytics &
                Performance</p>
        </div>
        <div class="d-flex gap-3">
            <div class="header-stat-group d-none d-lg-flex bg-white border rounded-pill px-4 py-2 shadow-sm">
                <div class="text-center border-end pe-3">
                    <small class="text-muted d-block text-xs uppercase">Net Profit</small>
                    <span class="fw-bold text-success" id="header-net-profit">$0.00</span>
                </div>
                <div class="text-center ps-3">
                    <small class="text-muted d-block text-xs uppercase">Sales Value</small>
                    <span class="fw-bold" id="header-total-sales">$0.00</span>
                </div>
            </div>
            <button class="btn btn-primary rounded-pill px-4 shadow-sm h-100" onclick="loadDashboard()">
                <i class="fas fa-sync-alt me-2"></i> Refresh
            </button>
        </div>
    </div>

    <!-- Quick Stats Cards -->
    <div class="row g-4 mb-4">
        <div class="col-xl-3 col-md-6">
            <div class="dashboard-card primary-gradient">
                <div class="card-content">
                    <span class="card-label">Daily Sales</span>
                    <h2 class="card-value" id="dash-total-sales">$0.00</h2>
                    <div class="card-footer">
                        <span class="trend" id="trend-sales">--%</span> vs yesterday
                    </div>
                </div>
                <div class="card-icon"><i class="fas fa-shopping-cart"></i></div>
            </div>
        </div>
        <div class="col-xl-3 col-md-6">
            <div class="dashboard-card success-gradient">
                <div class="card-content">
                    <span class="card-label">Orders Completed</span>
                    <h2 class="card-value" id="dash-order-count">0</h2>
                    <div class="card-footer">
                        <span class="trend" id="trend-orders">--%</span> vs yesterday
                    </div>
                </div>
                <div class="card-icon"><i class="fas fa-receipt"></i></div>
            </div>
        </div>
        <div class="col-xl-3 col-md-6">
            <div class="dashboard-card warning-gradient">
                <div class="card-content">
                    <span class="card-label">COGS (Today)</span>
                    <h2 class="card-value" id="dash-cogs">$0.00</h2>
                    <div class="card-footer">
                        <span class="trend">Estimated cost</span>
                    </div>
                </div>
                <div class="card-icon"><i class="fas fa-coins"></i></div>
            </div>
        </div>
        <div class="col-xl-3 col-md-6">
            <div class="dashboard-card info-gradient">
                <div class="card-content">
                    <span class="card-label">Net Profit</span>
                    <h2 class="card-value" id="dash-net-profit">$0.00</h2>
                    <div class="card-footer">
                        <span class="trend" id="trend-profit">--%</span> vs yesterday
                    </div>
                </div>
                <div class="card-icon"><i class="fas fa-piggy-bank"></i></div>
            </div>
        </div>
    </div>

    <!-- Charts & Details Area -->
    <div class="row g-4">
        <div class="col-xl-8">
            <div class="row g-4">
                <!-- Operational Alerts -->
                <div class="col-md-6">
                    <div class="content-card h-100">
                        <div class="card-header-custom border-bottom">
                            <h5 class="m-0 fw-bold"><i class="fas fa-bell text-warning me-2"></i>Action Required</h5>
                        </div>
                        <div class="card-body-custom p-3" id="dashboard-alerts-container">
                            <div class="alert-item d-flex align-items-center mb-3 bg-light rounded p-2">
                                <div class="icon-box bg-white text-danger shadow-sm rounded-circle me-3"
                                    style="width:40px;height:40px;display:flex;align-items:center;justify-content:center;">
                                    <i class="fas fa-exclamation-triangle"></i>
                                </div>
                                <div>
                                    <p class="mb-0 fw-bold text-dark">Low Stock Alert</p>
                                    <small class="text-muted">3 items are below threshold</small>
                                </div>
                                <button class="btn btn-sm btn-outline-danger ms-auto">View</button>
                            </div>
                            <div class="alert-item d-flex align-items-center bg-light rounded p-2">
                                <div class="icon-box bg-white text-warning shadow-sm rounded-circle me-3"
                                    style="width:40px;height:40px;display:flex;align-items:center;justify-content:center;">
                                    <i class="fas fa-clock"></i>
                                </div>
                                <div>
                                    <p class="mb-0 fw-bold text-dark">Kitchen Delay</p>
                                    <small class="text-muted">Order #1024 is late (25m)</small>
                                </div>
                                <button class="btn btn-sm btn-outline-warning ms-auto">Check</button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Live Status -->
                <div class="col-md-6">
                    <div class="content-card h-100">
                        <div class="card-header-custom border-bottom">
                            <h5 class="m-0 fw-bold"><i class="fas fa-server text-primary me-2"></i>System Status</h5>
                        </div>
                        <div class="card-body-custom p-4">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <span class="text-muted">Database Connection</span>
                                <span class="badge bg-success-subtle text-success px-3 py-2 rounded-pill"><i
                                        class="fas fa-check me-1"></i> Stable</span>
                            </div>
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <span class="text-muted">Printer Service</span>
                                <span class="badge bg-success-subtle text-success px-3 py-2 rounded-pill"><i
                                        class="fas fa-check me-1"></i> Online</span>
                            </div>
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="text-muted">Last Backup</span>
                                <span class="text-dark fw-bold">Today, 04:00 AM</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Top Selling (Mini) -->
                <div class="col-12">
                    <div class="content-card">
                        <div class="card-header-custom border-bottom">
                            <h5 class="m-0 fw-bold">🔥 Trending Today</h5>
                        </div>
                        <div class="card-body-custom p-3 d-flex gap-3 overflow-auto" id="dashboard-trending-container">
                            <div class="trending-item border rounded p-2 flex-fill text-center">
                                <h6 class="text-primary fw-bold mb-1">Chicken Burger</h6>
                                <small class="text-muted">24 Sold</small>
                            </div>
                            <div class="trending-item border rounded p-2 flex-fill text-center">
                                <h6 class="text-primary fw-bold mb-1">Cola 500ml</h6>
                                <small class="text-muted">18 Sold</small>
                            </div>
                            <div class="trending-item border rounded p-2 flex-fill text-center">
                                <h6 class="text-primary fw-bold mb-1">Spicy Fries</h6>
                                <small class="text-muted">12 Sold</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xl-4">
            <div class="content-card h-100">
                <div class="card-header-custom border-bottom">
                    <h5 class="m-0 fw-bold">Recent Activities</h5>
                </div>
                <div class="card-body-custom p-0">
                    <div class="activity-feed" id="dashboard-activity-feed">
                        <div class="text-center py-5 text-muted">
                            <i class="fas fa-spinner fa-spin fa-2x mb-3"></i>
                            <p>Loading recent data...</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
    /* Dashboard Specific Premium Styles */
    .dashboard-card {
        background: white;
        border-radius: 20px;
        padding: 24px;
        position: relative;
        overflow: hidden;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
        border: 1px solid rgba(0, 0, 0, 0.05);
        transition: transform 0.3s ease, box-shadow 0.3s ease;
        height: 100%;
    }

    .dashboard-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 15px 40px rgba(0, 0, 0, 0.1);
    }

    .dashboard-card .card-content {
        position: relative;
        z-index: 2;
    }

    .dashboard-card .card-label {
        font-size: 0.8rem;
        font-weight: 700;
        text-transform: uppercase;
        color: var(--text-muted);
        letter-spacing: 0.5px;
    }

    .dashboard-card .card-value {
        font-size: 2rem;
        font-weight: 800;
        margin: 10px 0;
    }

    .dashboard-card .card-footer {
        font-size: 0.75rem;
        color: var(--text-muted);
    }

    .dashboard-card .card-icon {
        position: absolute;
        top: -10px;
        right: -10px;
        font-size: 5rem;
        opacity: 0.05;
        transform: rotate(-15deg);
    }

    .dashboard-card.primary-gradient {
        border-left: 5px solid var(--primary);
    }

    .dashboard-card.success-gradient {
        border-left: 5px solid #12B76A;
    }

    .dashboard-card.warning-gradient {
        border-left: 5px solid #F79009;
    }

    .dashboard-card.info-gradient {
        border-left: 5px solid #00D1FF;
    }

    .content-card {
        background: white;
        border-radius: 20px;
        box-shadow: 0 5px 20px rgba(0, 0, 0, 0.03);
        border: 1px solid rgba(0, 0, 0, 0.05);
        overflow: hidden;
    }

    .card-header-custom {
        padding: 20px 24px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .activity-feed .activity-item {
        padding: 16px 24px;
        border-bottom: 1px solid rgba(0, 0, 0, 0.05);
        display: flex;
        gap: 15px;
        align-items: center;
    }

    .activity-feed .activity-item:last-child {
        border-bottom: none;
    }

    .activity-icon {
        width: 40px;
        height: 40px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1rem;
        flex-shrink: 0;
    }

    .activity-details p {
        margin: 0;
        font-size: 0.85rem;
        font-weight: 500;
    }

    .activity-details small {
        color: var(--text-muted);
        font-size: 0.75rem;
    }

    .trend.up {
        color: #12B76A;
        font-weight: 600;
    }

    .trend.down {
        color: #F04438;
        font-weight: 600;
    }

    .text-xs {
        font-size: 0.7rem;
    }

    /* DARK MODE OVERRIDES */
    [data-theme="dark"] .dashboard-card,
    [data-theme="dark"] .content-card,
    [data-theme="dark"] .header-stat-group {
        background: var(--surface);
        border-color: var(--border);
        color: var(--text-main);
    }

    [data-theme="dark"] .alert-item,
    [data-theme="dark"] .trending-item {
        background: #2D2D2D !important;
        border-color: #444 !important;
        color: var(--text-main);
    }

    [data-theme="dark"] .alert-item p {
        color: var(--text-main) !important;
    }

    [data-theme="dark"] .icon-box {
        background: #333 !important;
    }

    [data-theme="dark"] .dashboard-card .card-label,
    [data-theme="dark"] .dashboard-card .card-footer {
        color: var(--text-sub);
    }
</style>