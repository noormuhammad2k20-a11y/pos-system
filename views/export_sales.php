<?php
// Sales Reports View (Analytical)
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
$csrf_token = $_SESSION['csrf_token'] ?? '';
?>
<style>
/* GUSTOPOS THEME PAGINATION OVERRIDES */
.gusto-page-link {
    background-color: var(--surface) !important;
    border-color: var(--border) !important;
    color: var(--text-main) !important;
    padding: 8px 14px;
    font-weight: 500;
    transition: all 0.2s ease;
}

.gusto-page-link:hover {
    background-color: var(--primary-bg) !important;
    color: var(--primary) !important;
    border-color: var(--primary) !important;
}

.page-item.active .gusto-page-link {
    background-color: var(--primary) !important;
    border-color: var(--primary) !important;
    color: #fff !important;
    box-shadow: 0 4px 10px rgba(255, 107, 0, 0.2);
}

.page-item.disabled .gusto-page-link {
    background-color: var(--bg-body) !important;
    color: var(--text-sub) !important;
    opacity: 0.6;
}

/* Dark mode adjustments for pagination */
[data-theme="dark"] .gusto-page-link {
    background-color: #252525 !important;
    border-color: #333 !important;
}

[data-theme="dark"] .page-item.active .gusto-page-link {
    background-color: var(--primary) !important;
    color: #000 !important;
    font-weight: 700;
}

/* --- ADVANCED ANALYTICS CARDS (Premium UI) --- */
.analytics-card-premium {
    border: 1px solid var(--border);
    background: var(--surface);
    border-radius: 20px;
    padding: 24px;
    position: relative;
    overflow: hidden;
    transition: all 0.4s cubic-bezier(0.165, 0.84, 0.44, 1);
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}

.analytics-card-premium:hover {
    transform: translateY(-5px);
    box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.08), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
    border-color: var(--primary);
}

.card-icon-wrapper {
    width: 48px;
    height: 48px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.25rem;
    margin-bottom: 20px;
    transition: all 0.3s ease;
}

.card-title-text {
    font-size: 0.85rem;
    font-weight: 600;
    color: var(--text-sub);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 8px;
}

.card-value-text {
    font-size: 1.75rem;
    font-weight: 800;
    color: var(--text-main);
    letter-spacing: -0.5px;
}

/* Color Variants */
.variant-revenue .card-icon-wrapper {
    background: rgba(79, 70, 229, 0.1);
    color: #4F46E5;
}

.variant-cash .card-icon-wrapper {
    background: rgba(16, 185, 129, 0.1);
    color: #10B981;
}

.variant-expenses .card-icon-wrapper {
    background: rgba(244, 63, 94, 0.1);
    color: #F43F5E;
}

.variant-orders .card-icon-wrapper {
    background: rgba(245, 158, 11, 0.1);
    color: #F59E0B;
}

/* Indicator lines */
.analytics-card-premium::after {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 4px;
    height: 100%;
    opacity: 0.8;
}

.variant-revenue::after {
    background: #4F46E5;
}

.variant-cash::after {
    background: #10B981;
}

.variant-expenses::after {
    background: #F43F5E;
}

.variant-orders::after {
    background: #F59E0B;
}

/* Dark Mode nuanced */
[data-theme="dark"] .analytics-card-premium {
    background: #1e1e1e;
    border-color: #333;
}

[data-theme="dark"] .card-icon-wrapper {
    filter: brightness(1.2);
}
</style>
<div id="export-view" class="view-section">
    <div class="page-header d-flex justify-content-between align-items-center mb-4">
        <div>
            <h3 class="fw-bold mb-1">Sales Reports</h3>
            <p class="text-muted mb-0 small text-uppercase">Business Analysis & Insights</p>
        </div>
        <div class="d-flex gap-3">
            <button class="btn btn-outline-primary rounded-pill px-4 fw-bold" id="printReportBtn">
                <i class="fas fa-print me-2"></i> Print Summary
            </button>
        </div>
    </div>

    <div class="row g-3 mb-4">
        <div class="col-md-3">
            <div class="analytics-card-premium variant-revenue h-100">
                <div>
                    <div class="card-icon-wrapper">
                        <i class="fas fa-chart-line"></i>
                    </div>
                    <div class="card-title-text">Total Revenue</div>
                </div>
                <div class="card-value-text" id="report-total-revenue">$0.00</div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="analytics-card-premium variant-cash h-100">
                <div>
                    <div class="card-icon-wrapper">
                        <i class="fas fa-money-bill-wave"></i>
                    </div>
                    <div class="card-title-text">Cash Sales</div>
                </div>
                <div class="card-value-text" id="report-cash-sales">$0.00</div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="analytics-card-premium variant-expenses h-100">
                <div>
                    <div class="card-icon-wrapper">
                        <i class="fas fa-wallet"></i>
                    </div>
                    <div class="card-title-text">Total Expenses</div>
                </div>
                <div class="card-value-text" id="report-total-expenses">$0.00</div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="analytics-card-premium variant-orders h-100">
                <div>
                    <div class="card-icon-wrapper">
                        <i class="fas fa-shopping-basket"></i>
                    </div>
                    <div class="card-title-text">Total Orders</div>
                </div>
                <div class="card-value-text" id="report-total-orders">0</div>
            </div>
        </div>
    </div>

    <div class="card border-0 shadow-sm rounded-4 mb-4">
        <div class="card-body p-4">
            <div class="row g-3 align-items-end mb-3">
                <div class="col-md-3">
                    <label class="form-label small fw-bold text-muted">Start Date</label>
                    <input type="date" id="report-start" class="form-control bg-light border-0">
                </div>

                <div class="col-md-3">
                    <label class="form-label small fw-bold text-muted">End Date</label>
                    <input type="date" id="report-end" class="form-control bg-light border-0">
                </div>

                <div class="col-md-3">
                    <label class="form-label small fw-bold text-muted">Search Report</label>
                    <div class="input-group bg-light rounded-3 overflow-hidden">
                        <span class="input-group-text bg-transparent border-0 text-muted"><i
                                class="fas fa-search"></i></span>
                        <input type="text" id="report-search" class="form-control bg-transparent border-0 px-0"
                            placeholder="Search anything...">
                    </div>
                </div>

                <div class="col-md-2">
                    <button class="btn btn-primary w-100 fw-bold" id="generateBtn"
                        style="height: 42px; border-radius: 8px;">
                        Generate Report
                    </button>
                </div>

                <div class="col-12 mt-2">
                    <div class="d-flex gap-2 flex-wrap">
                        <button type="button" class="btn btn-sm btn-outline-primary"
                            onclick="applyQuickFilter('today', event)">Today</button>
                        <button type="button" class="btn btn-sm btn-outline-primary"
                            onclick="applyQuickFilter('yesterday', event)">Yesterday</button>
                        <button type="button" class="btn btn-sm btn-outline-primary"
                            onclick="applyQuickFilter('week', event)">Last 7 Days</button>
                        <button type="button" class="btn btn-sm btn-outline-primary"
                            onclick="applyQuickFilter('month', event)">This Month</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="card border-0 shadow-sm rounded-4">
        <div class="card-header bg-white py-3 border-bottom">
            <h5 class="m-0 fw-bold">Transaction Verification List</h5>
        </div>
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="bg-light">
                    <tr>
                        <th class="ps-4">Invoice #</th>
                        <th>Date & Time</th>
                        <th>Customer</th>
                        <th>Type</th>
                        <th>Payment</th>
                        <th>Total</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody id="export-preview-tbody">
                    <tr>
                        <td colspan="7" class="text-center py-5 text-muted">Select dates and click Generate Report</td>
                    </tr>
                </tbody>
            </table>
        </div>
        <div class="card-footer bg-white border-top-0 py-3">
            <nav aria-label="Transaction pagination">
                <ul class="pagination justify-content-center mb-0" id="report-pagination">
                </ul>
            </nav>
        </div>
    </div>
</div>

<script>
// DEFINE GLOBAL HELPERS
window.csrfToken = "<?php echo $csrf_token; ?>";

window.applyQuickFilter = function(period, e) {
    if (e) e.preventDefault();

    let today = new Date();
    let start = new Date();
    let end = new Date();

    // Helper to format YYYY-MM-DD
    const fmt = d => d.toISOString().split('T')[0];

    switch (period) {
        case 'today':
            // start & end are already today
            break;
        case 'yesterday':
            start.setDate(today.getDate() - 1);
            end.setDate(today.getDate() - 1);
            break;
        case 'week':
            start.setDate(today.getDate() - 6); // Last 7 days including today
            break;
        case 'month':
            start = new Date(today.getFullYear(), today.getMonth(), 1);
            end = new Date(today.getFullYear(), today.getMonth() + 1, 0);
            break;
    }

    $('#report-start').val(fmt(start));
    $('#report-end').val(fmt(end));

    // Auto-trigger generation
    $('#generateBtn').click();
};

$(document).ready(function() {

    let currentStats = null;
    let currentPage = 1;
    let currentRange = {
        start: '',
        end: ''
    };

    // --- LOAD PAGE FUNCTION ---
    function loadPage(page) {
        let startDate = $('#report-start').val();
        let endDate = $('#report-end').val();
        let searchTerm = $('#report-search').val();

        if (!startDate || !endDate) {
            alert("Please select both Start and End dates.");
            return;
        }

        currentPage = page;
        let btn = $('#generateBtn');
        btn.prop('disabled', true).text('Loading...');

        $('#export-preview-tbody').html(`
                <tr>
                    <td colspan="7" class="text-center py-5">
                        <div class="py-4">
                            <i class="fas fa-spinner fa-spin text-primary mb-3" style="font-size: 2rem;"></i>
                            <h6 class="text-muted fw-bold">Loading Page ${page}...</h6>
                        </div>
                    </td>
                </tr>
            `);

        $.ajax({
            url: 'backend.php?action=generate_report',
            type: 'POST',
            data: {
                start_date: startDate,
                end_date: endDate,
                page: page,
                limit: 20,
                search: searchTerm,
                csrf_token: window.csrfToken
            },
            dataType: 'json',
            success: function(response) {
                // ROBUST ERROR CHECKING:
                // 1. Check if response is null or false (common JSON encoding failure in PHP)
                if (!response) {
                    alert(
                        "Server Error: Empty Response. (Possible data encoding issue in backend)"
                        );
                    $('#export-preview-tbody').html(
                        '<tr><td colspan="7" class="text-center text-danger">Server Error: Data Encoding Failed</td></tr>'
                    );
                    return;
                }

                // 2. Check for standard success flags
                if (response.status === 'success' || response.success === true) {
                    let d = response.data;
                    let p = d.pagination;

                    // 1. Update Cards
                    $('#report-total-revenue').text(d.revenue);
                    $('#report-cash-sales').text(d.cash_sales);
                    $('#report-total-expenses').text(d.expenses);
                    $('#report-total-orders').text(d.orders);

                    // 2. Save for Printing & State
                    currentStats = d;
                    currentRange = {
                        start: startDate,
                        end: endDate
                    };

                    // 3. Populate Table
                    let rows = '';
                    if (d.transactions && d.transactions.length > 0) {
                        d.transactions.forEach(t => {
                            let badgeClass = t.status === 'completed' ? 'bg-success' :
                                'bg-warning';
                            rows += `
                                <tr>
                                    <td>${t.order_number}</td>
                                    <td>${t.created_at}</td>
                                    <td>${t.customer_name || 'Walk-in'}</td>
                                    <td>${t.order_type || 'Dine-in'}</td> 
                                    <td>${t.payment_method ? t.payment_method.toUpperCase() : '-'}</td>
                                    <td>${parseFloat(t.total).toFixed(2)}</td>
                                    <td><span class="badge ${badgeClass}">${t.status}</span></td>
                                </tr>
                            `;
                        });
                    } else {
                        rows =
                            '<tr><td colspan="7" class="text-center p-3">No sales found in this range.</td></tr>';
                    }
                    $('#export-preview-tbody').html(rows);

                    // 4. Render Pagination Controls
                    renderPagination(p.total_pages, p.current_page);

                } else {
                    // 3. Handle explicit error from backend
                    let msg = response.message || response.msg || "Unknown error";
                    alert("Server Error: " + msg);
                    $('#export-preview-tbody').html(
                        `<tr><td colspan="7" class="text-center text-danger">${msg}</td></tr>`
                    );
                }
            },
            error: function(xhr, status, error) {
                console.error("AJAX Error:", xhr.responseText);
                alert("Connection Failed: " + error);
                $('#export-preview-tbody').html(
                    '<tr><td colspan="7" class="text-center text-danger">Connection Failed. Check console.</td></tr>'
                );
            },
            complete: function() {
                btn.prop('disabled', false).text('Generate Report');
            }
        });
    }

    // --- RENDER PAGINATION ---
    function renderPagination(totalPages, currentPage) {
        let container = $('#report-pagination');
        container.empty();

        if (totalPages <= 1) return;

        let html = '';

        // Previous
        html += `
                <li class="page-item ${currentPage === 1 ? 'disabled' : ''}">
                    <a class="page-link gusto-page-link" href="#" data-page="${currentPage - 1}">
                        <i class="fas fa-chevron-left"></i>
                    </a>
                </li>
            `;

        // Page numbers
        let start = Math.max(1, currentPage - 2);
        let end = Math.min(totalPages, currentPage + 2);

        if (start > 1) {
            html += `
                    <li class="page-item"><a class="page-link gusto-page-link" href="#" data-page="1">1</a></li>
                    ${start > 2 ? '<li class="page-item disabled"><span class="page-link border-0 bg-transparent">...</span></li>' : ''}
                `;
        }

        for (let i = start; i <= end; i++) {
            html += `
                    <li class="page-item ${i === currentPage ? 'active' : ''}">
                        <a class="page-link gusto-page-link" href="#" data-page="${i}">${i}</a>
                    </li>
                `;
        }

        if (end < totalPages) {
            html += `
                    ${end < totalPages - 1 ? '<li class="page-item disabled"><span class="page-link border-0 bg-transparent">...</span></li>' : ''}
                    <li class="page-item"><a class="page-link gusto-page-link" href="#" data-page="${totalPages}">${totalPages}</a></li>
                `;
        }

        // Next
        html += `
                <li class="page-item ${currentPage === totalPages ? 'disabled' : ''}">
                    <a class="page-link gusto-page-link" href="#" data-page="${currentPage + 1}">
                        <i class="fas fa-chevron-right"></i>
                    </a>
                </li>
            `;

        container.append(html);
    }

    // --- PAGINATION CLICK ---
    $(document).on('click', '#report-pagination .page-link', function(e) {
        e.preventDefault();
        let page = $(this).data('page');
        if (page && !$(this).parent().hasClass('disabled') && !$(this).parent().hasClass('active')) {
            loadPage(page);
        }
    });

    // --- LIVE SEARCH TRIGGER ---
    $('#report-search').on('input', function() {
        clearTimeout(this.delay);
        this.delay = setTimeout(function() {
            loadPage(1);
        }, 500);
    });

    // --- GENERATE REPORT CLICK ---
    $('#generateBtn').click(function(e) {
        e.preventDefault();
        loadPage(1);
    });

    // --- PRINT THERMAL REPORT ---
    $('#printReportBtn').click(function() {
        if (!currentStats) {
            alert("Please generate a report first!");
            return;
        }
        printThermalReceipt(currentStats, currentRange.start, currentRange.end);
    });

    function printThermalReceipt(stats, start, end) {
        let frameId = 'print_frame_' + new Date().getTime();
        let frame = $('<iframe id="' + frameId + '" name="' + frameId + '"></iframe>')
            .css({
                position: 'absolute',
                top: '-1000px',
                left: '-1000px',
                width: '300px'
            })
            .appendTo('body');

        let doc = frame[0].contentWindow.document;

        let html = `
            <html>
            <head>
                <style>
                    body { font-family: 'Courier New', monospace; font-size: 12px; margin: 0; padding: 10px; width: 300px; color: #000; }
                    .header { text-align: center; font-weight: bold; font-size: 14px; margin-bottom: 5px; }
                    .meta { text-align: center; font-size: 11px; margin-bottom: 10px; }
                    .line { border-bottom: 1px dashed #000; margin: 5px 0; }
                    .row { display: flex; justify-content: space-between; margin-bottom: 3px; }
                    .bold { font-weight: bold; }
                </style>
            </head>
            <body>
                <div class="header">GUSTO POS REPORT</div>
                <div class="meta">
                    Period: ${start} to ${end}<br>
                    Generated: ${new Date().toLocaleTimeString()}
                </div>
                <div class="line"></div>
                
                <div class="row"><span>Total Orders:</span><span class="bold">${stats.orders}</span></div>
                <div class="row"><span>Total Revenue:</span><span class="bold">${stats.revenue}</span></div>
                <div class="row"><span>Cash Sales:</span><span>${stats.cash_sales}</span></div>
                <div class="row"><span>Expenses:</span><span>${stats.expenses}</span></div>
                
                <div class="line"></div>
                
                <div class="header" style="font-size: 11px; margin-top: 5px;">ITEM SALES SUMMARY</div>
                ${(stats.item_breakdown || []).map(item => `
                    <div class="row">
                        <span>${item.product_name}</span>
                        <span>${item.total_qty}</span>
                    </div>
                `).join('')}
                
                <div class="line"></div>
                <div class="row bold" style="font-size: 14px;"><span>NET PROFIT:</span><span>${stats.net_profit}</span></div>
                <div class="line"></div>
                
                <div style="text-align: center; margin-top: 15px;">*** END OF REPORT ***</div>
            </body>
            </html>
        `;

        doc.open();
        doc.write(html);
        doc.close();

        setTimeout(function() {
            frame[0].contentWindow.focus();
            frame[0].contentWindow.print();
            setTimeout(function() {
                frame.remove();
            }, 60000);
        }, 500);
    }
});
</script>