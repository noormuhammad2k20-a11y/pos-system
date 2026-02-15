<?php
session_start();
// Prevent caching of the main template
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

// Require login
if (!isset($_SESSION['user_id'])) {
    header('Location: login.php');
    exit;
}
$currentUser = $_SESSION['display_name'] ?? 'User';
$currentRole = $_SESSION['role'] ?? 'cashier';
$loginTime = $_SESSION['login_time'] ?? date('Y-m-d H:i:s');

// Versioning constant for assets
$appVersion = @filemtime(__DIR__ . '/app.js') ?: '1.0.1';
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GustoPOS | Professional Admin</title>
    <?php require_once 'csrf_helper.php'; ?>
    <meta name="csrf-token" content="<?= Csrf::generate() ?>">
    <link rel="manifest" href="manifest.json">
    <meta name="theme-color" content="#0d6efd">
    <link rel="icon" type="image/svg+xml" href="favicon.svg">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link
        href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Poppins:wght@400;500;600;700&display=swap"
        resrel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- jQuery (Must be first) -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.28/jspdf.plugin.autotable.min.js"></script>

    <style>
        :root {
            --primary: #FF6B00;
            --primary-hover: #e65100;
            --primary-bg: #FFF4EB;
            --bg-body: #F2F4F7;
            --surface: #FFFFFF;
            --text-main: #1D2939;
            --text-sub: #667085;
            --border: #E4E7EC;
            --sidebar-width: 250px;
            --header-height: 65px;
            --radius: 10px;
            --shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            --status-free: #12B76A;
            --status-busy: #F04438;
            --status-pay: #F79009;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg-body);
            color: var(--text-main);
            height: 100vh;
            overflow: hidden;
            margin: 0;
            display: flex;
            font-size: 0.9rem;
        }

        h1,
        h2,
        h3,
        h4,
        h5,
        h6 {
            font-family: 'Poppins', sans-serif;
            color: var(--text-main);
            font-weight: 600;
        }

        .fw-bold {
            font-weight: 600 !important;
        }

        .text-xs {
            font-size: 0.75rem;
        }

        .cursor-pointer {
            cursor: pointer;
        }

        ::-webkit-scrollbar {
            width: 6px;
            height: 6px;
        }

        ::-webkit-scrollbar-track {
            background: transparent;
        }

        [data-theme="dark"] {
            --bg-body: #121212;
            --surface: #1E1E1E;
            --text-main: #E0E0E0;
            --text-sub: #A0A0A0;
            --border: #333333;
            --primary-bg: rgba(255, 107, 0, 0.15);
            --shadow: 0 4px 12px rgba(0, 0, 0, 0.4);

            /* Additional overrides */
            --status-free: #4caf50;
            --status-busy: #ef5350;
            --status-pay: #ffca28;
        }

        /* Dark Mode Specific Overrides */
        [data-theme="dark"] .form-control,
        [data-theme="dark"] .form-select,
        [data-theme="dark"] .input-group-text {
            background-color: #2D2D2D;
            border-color: #333;
            color: #E0E0E0;
        }

        [data-theme="dark"] .form-control:focus,
        [data-theme="dark"] .form-select:focus {
            background-color: #333;
            color: #fff;
            border-color: var(--primary);
        }

        [data-theme="dark"] .table thead th {
            background-color: #252525;
            color: #ccc;
            border-bottom-color: #444;
        }

        [data-theme="dark"] .table tbody td {
            border-bottom-color: #333;
        }

        [data-theme="dark"] .modal-content,
        [data-theme="dark"] .modal-header,
        [data-theme="dark"] .modal-footer {
            background-color: var(--surface);
            border-color: var(--border);
            color: var(--text-main);
        }

        [data-theme="dark"] .modal-header-custom {
            background-color: #252525;
            border-bottom-color: var(--border);
        }

        [data-theme="dark"] .dropdown-menu {
            background-color: var(--surface);
            border-color: var(--border);
        }

        [data-theme="dark"] .dropdown-item {
            color: var(--text-main);
        }

        [data-theme="dark"] .dropdown-item:hover {
            background-color: var(--border);
        }

        [data-theme="dark"] .bg-white {
            background-color: var(--surface) !important;
        }

        [data-theme="dark"] .text-muted {
            color: #888 !important;
        }

        [data-theme="dark"] .card {
            background-color: var(--surface);
            border-color: var(--border);
        }

        [data-theme="dark"] .cart-header,
        [data-theme="dark"] .cart-footer {
            background-color: #252525;
            border-color: var(--border);
        }

        [data-theme="dark"] .cart-item {
            background-color: #2D2D2D;
            border-color: #333;
        }

        [data-theme="dark"] .cart-controls {
            background-color: #333;
            border-color: #444;
        }

        ::-webkit-scrollbar-thumb {
            background: #D0D5DD;
            border-radius: 10px;
        }

        ::-webkit-scrollbar-thumb:hover {
            background: #98A2B3;
        }

        /* --- EXTENDED DARK MODE OVERRIDES --- */
        [data-theme="dark"] .stat-card,
        [data-theme="dark"] .premium-card,
        [data-theme="dark"] .data-table-container,
        [data-theme="dark"] .report-table-container,
        [data-theme="dark"] .filter-panel,
        [data-theme="dark"] .settings-tabs,
        [data-theme="dark"] .settings-content,
        [data-theme="dark"] .card,
        [data-theme="dark"] .invoice-preview {
            background-color: var(--surface) !important;
            border-color: var(--border);
            color: var(--text-main);
            box-shadow: none;
        }

        [data-theme="dark"] .bg-light {
            background-color: #2D2D2D !important;
            color: var(--text-main);
        }

        [data-theme="dark"] .pagination-container,
        [data-theme="dark"] .pagination-wrapper,
        [data-theme="dark"] .view-section-header,
        [data-theme="dark"] .cart-header,
        [data-theme="dark"] .get-started-step {
            background-color: var(--surface);
            border-color: var(--border);
        }

        [data-theme="dark"] .report-table thead th,
        [data-theme="dark"] .table thead th {
            background-color: #1E1E1E;
            color: #ccc;
            border-bottom-color: #333;
        }

        [data-theme="dark"] .cat-btn {
            background-color: var(--surface);
            border-color: var(--border);
            color: var(--text-main);
        }

        [data-theme="dark"] .action-card-btn {
            background-color: #2D2D2D;
            border-color: #444;
            color: var(--text-main);
        }

        [data-theme="dark"] .action-card-btn:hover {
            background-color: #333;
            border-color: var(--primary);
        }

        /* Table Card Status Colors in Dark Mode */
        [data-theme="dark"] .table-card.is-busy {
            background: rgba(240, 68, 56, 0.15);
            border-top-color: var(--status-busy);
        }

        [data-theme="dark"] .table-card.needs-attention {
            background: rgba(247, 144, 9, 0.15);
            border-top-color: var(--status-pay);
        }

        [data-theme="dark"] .modal-header-custom {
            background-color: #252525;
            border-color: var(--border);
        }


        /* PAGINATION STYLING */
        .pagination .page-link {
            color: var(--primary);
            border-color: var(--border);
            background-color: var(--surface);
            transition: all 0.2s;
        }

        .pagination .page-link:hover {
            color: white;
            background-color: var(--primary-hover);
            border-color: var(--primary-hover);
        }

        .pagination .page-item.active .page-link {
            background-color: var(--primary);
            border-color: var(--primary);
            color: white;
        }

        .pagination .page-item.disabled .page-link {
            color: var(--text-sub);
            background-color: var(--bg-body);
            border-color: var(--border);
        }

        /* Dark Mode Pagination overrides */
        [data-theme="dark"] .pagination .page-link {
            background-color: #2D2D2D;
            border-color: #444;
            color: var(--primary);
        }

        [data-theme="dark"] .pagination .page-link:hover {
            background-color: var(--primary);
            color: white;
        }

        [data-theme="dark"] .pagination .page-item.active .page-link {
            background-color: var(--primary);
            border-color: var(--primary);
        }


        #app-container {
            display: flex;
            width: 100%;
            height: 100vh;
            overflow: hidden;
        }

        .main-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            background: var(--bg-body);
        }

        .view-section {
            display: none;
            padding: 24px;
            overflow-y: auto !important;
            /* Force scrollbar */
            flex: 1;
            height: calc(100vh - var(--header-height));
        }

        .view-section.active {
            display: flex !important;
            flex-direction: column;
        }

        .pagination-container {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            margin-top: 20px;
            gap: 5px;
            padding: 15px 20px;
            background: var(--surface);
            border-top: 1px solid var(--border);
            border-radius: 0 0 12px 12px;
        }

        .pagination-info {
            margin-right: auto;
            padding-left: 5px;
        }


        .page-btn {
            min-width: 38px;
            padding: 8px 12px;
            border: 1px solid var(--border);
            background: var(--surface);
            border-radius: 8px;
            font-size: 0.85rem;
            cursor: pointer;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .page-btn:hover:not(:disabled) {
            background: var(--primary-bg);
            color: var(--primary);
            border-color: var(--primary);
        }

        .page-btn.active {
            background: var(--primary);
            color: white;
            border-color: var(--primary);
        }

        .page-btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            background: #f8f9fa;
        }

        /* Settings Tabs Styles */
        /* === SETTINGS PAGE === */
        .settings-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 20px;
        }

        .settings-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid var(--border);
        }

        /* === GUSTOPOS UNIVERSAL ACTION BUTTONS (COMPACT 32px) === */
        /* Table Cell Container - FIXED for all pages */
        /* Pages: Sales History, Deleted Sales, Expenses, Inventory, Recipes, Menu Mgmt, Suppliers, Staff */
        .sales-action-cell,
        .action-cell,
        .action-container,
        .table-actions {
            display: flex !important;
            gap: 8px !important;
            background: transparent !important;
            /* FIXED: Removes dark box */
            border: none !important;
            padding: 0 !important;
            box-shadow: none !important;
            justify-content: center;
            align-items: center;
        }

        /* --- COMPACT TACTILE BUTTON BASE (Improved Visibility for Light Mode) --- */
        .btn-pro {
            position: relative;
            border: 1px solid #d0d5dd;
            /* Darker border for constant visibility */
            outline: none;
            cursor: pointer;
            width: 36px !important;
            height: 36px !important;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #ffffff;
            transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            /* Persistent shadow */
        }

        /* Glass-top highlight (Subtle for light mode) */
        .btn-pro::before {
            content: '';
            position: absolute;
            top: 1px;
            left: 1px;
            right: 1px;
            height: 40%;
            background: linear-gradient(rgba(255, 255, 255, 0.8), rgba(255, 255, 255, 0));
            border-radius: 7px 7px 0 0;
            pointer-events: none;
            opacity: 0.3;
        }

        /* --- DARK MODE OVERRIDES (Restores the aggressive dark look) --- */
        [data-theme="dark"] .btn-pro {
            border: 1px solid #333;
            background: linear-gradient(145deg, #2a2a2a, #1a1a1a);
            box-shadow: 2px 2px 5px #0a0a0a, -1px -1px 5px #262626;
        }

        [data-theme="dark"] .btn-pro::before {
            background: linear-gradient(rgba(255, 255, 255, 0.08), transparent);
            opacity: 1;
        }

        /* --- ADAPTIVE BUTTON COLORS & HOVER --- */

        /* View Button */
        .btn-view-pro {
            color: #0095ff;
        }

        [data-theme="dark"] .btn-view-pro {
            color: #00d2ff;
        }

        .btn-view-pro:hover {
            color: #ffffff;
            background: #0095ff;
            border-color: #0095ff;
            box-shadow: 0 4px 12px rgba(0, 149, 255, 0.3);
            transform: translateY(-2px);
        }

        /* Print Button */
        .btn-print-pro {
            color: #475467;
        }

        [data-theme="dark"] .btn-print-pro {
            color: #e2e8f0;
        }

        .btn-print-pro:hover {
            color: #111111;
            background: #f2f4f7;
            border-color: #d0d5dd;
            transform: translateY(-2px);
        }

        /* Edit Button */
        .btn-edit-pro {
            color: #f79009;
        }

        [data-theme="dark"] .btn-edit-pro {
            color: #ff6b00;
        }

        .btn-edit-pro:hover {
            color: #ffffff;
            background: #ff6b00;
            border-color: #ff6b00;
            box-shadow: 0 4px 12px rgba(255, 107, 0, 0.3);
            transform: translateY(-2px);
        }

        /* Delete Button */
        .btn-delete-pro {
            color: #d92d20;
        }

        [data-theme="dark"] .btn-delete-pro {
            color: #ef4444;
        }

        .btn-delete-pro:hover {
            color: #ffffff;
            background: #ef4444;
            border-color: #ef4444;
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
            transform: translateY(-2px);
        }

        /* --- ICON SIZING --- */
        .btn-pro svg,
        .btn-pro i {
            width: 16px !important;
            height: 16px !important;
            font-size: 16px;
        }

        .btn-pro:active {
            transform: translateY(1px) scale(0.95);
        }


        .settings-wrapper {
            display: flex;
            gap: 25px;
            min-height: 70vh;
        }

        .settings-tabs {
            display: flex;
            flex-direction: column;
            gap: 10px;
            min-width: 240px;
            background: white;
            padding: 20px;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
            height: fit-content;
            position: sticky;
            top: 20px;
            border: 1px solid var(--border);
        }

        .settings-tab {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 14px 18px;
            border: none;
            background: transparent;
            border-radius: 12px;
            text-align: left;
            font-size: 0.95rem;
            font-weight: 500;
            color: var(--text-sub);
            cursor: pointer;
            transition: all 0.25s ease;
            border: 2px solid transparent;
        }

        .settings-tab:hover {
            background: var(--primary-bg);
            color: var(--primary);
            transform: translateX(4px);
        }

        .settings-tab.active {
            background: linear-gradient(135deg, var(--primary) 0%, #0052cc 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(0, 82, 204, 0.3);
            border-color: var(--primary);
        }

        .settings-tab i {
            width: 24px;
            height: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.1rem;
        }

        .settings-content {
            flex: 1;
            background: white;
            padding: 35px;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
            border: 1px solid var(--border);
        }

        .settings-panel {
            display: none;
            animation: fadeIn 0.3s ease-in-out;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(10px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .settings-panel.active {
            display: block;
        }

        .settings-section-title {
            font-weight: 700;
            font-size: 1.1rem;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid var(--border);
            color: var(--text-main);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        /* Responsive Design */
        @media (max-width: 992px) {
            .settings-wrapper {
                flex-direction: column;
                gap: 20px;
            }

            .settings-tabs {
                flex-direction: row;
                min-width: auto;
                width: 100%;
                position: static;
                overflow-x: auto;
                padding: 15px;
            }

            .settings-tab {
                flex-shrink: 0;
                min-width: fit-content;
            }

            .settings-tab:hover {
                transform: translateY(-2px);
            }

            .settings-content {
                padding: 25px 20px;
            }

            .settings-header h4 {
                font-size: 1.5rem;
            }
        }

        @media (max-width: 576px) {
            .settings-container {
                padding: 0 15px;
            }

            .settings-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }

            .settings-header h4 {
                font-size: 1.3rem;
            }

            .settings-tabs {
                padding: 10px;
                gap: 8px;
            }

            .settings-tab {
                padding: 12px 14px;
                font-size: 0.85rem;
            }

            .settings-tab i {
                width: 20px;
                height: 20px;
                font-size: 1rem;
            }

            .settings-content {
                padding: 20px 15px;
            }

            .settings-section-title {
                font-size: 1rem;
            }
        }

        .btn-primary {
            background-color: var(--primary);
            border-color: var(--primary);
        }

        .btn-primary:hover {
            background-color: var(--primary-hover);
            border-color: var(--primary-hover);
        }

        .text-primary {
            color: var(--primary) !important;
        }

        .bg-primary-subtle {
            background-color: var(--primary-bg) !important;
            color: var(--primary);
        }

        .sidebar {
            width: var(--sidebar-width);
            background: var(--surface);
            height: 100vh;
            display: flex;
            flex-direction: column;
            border-right: 1px solid var(--border);
            flex-shrink: 0;
            z-index: 1000;
            transition: transform 0.3s ease, width 0.3s ease;
            position: relative;
        }

        .brand {
            height: var(--header-height);
            display: flex;
            align-items: center;
            padding: 0 24px;
            border-bottom: 1px solid transparent;
        }

        .brand-icon {
            width: 38px;
            height: 38px;
            background: var(--primary);
            color: white;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 12px;
            font-size: 1.2rem;
            flex-shrink: 0;
            box-shadow: 0 4px 10px rgba(255, 107, 0, 0.3);
        }

        .sidebar-content {
            flex: 1;
            overflow-y: auto;
            padding: 20px 16px;
        }

        .menu-label {
            font-size: 0.75rem;
            font-weight: 700;
            color: var(--text-sub);
            text-transform: uppercase;
            margin: 25px 12px 10px;
            letter-spacing: 0.8px;
            white-space: nowrap;
        }

        .sidebar-content .menu-label:first-child {
            margin-top: 5px;
        }

        .nav-item {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 12px 16px;
            border-radius: 10px;
            color: var(--text-sub);
            text-decoration: none;
            font-weight: 500;
            transition: 0.2s;
            margin-bottom: 4px;
            cursor: pointer;
            font-size: 0.95rem;
            white-space: nowrap;
            overflow: hidden;
        }

        .nav-item:hover {
            background: var(--primary-bg);
            color: var(--primary);
        }

        .nav-item.active {
            background: var(--primary);
            color: white;
            box-shadow: 0 4px 12px rgba(255, 107, 0, 0.25);
        }

        .nav-item i {
            width: 24px;
            text-align: center;
            font-size: 1.2rem;
            flex-shrink: 0;
        }

        .sidebar-toggle-btn {
            position: absolute;
            right: -14px;
            top: 22px;
            width: 28px;
            height: 28px;
            background: var(--surface);
            color: var(--text-sub);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            border: 1px solid var(--border);
            z-index: 60;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            transition: 0.2s;
        }

        .sidebar-toggle-btn:hover {
            color: var(--primary);
            border-color: var(--primary);
        }

        @media (min-width: 1200px) {
            body.sidebar-collapsed .sidebar {
                width: 80px !important;
            }

            body.sidebar-collapsed .brand h4,
            body.sidebar-collapsed .menu-label,
            body.sidebar-collapsed .nav-item span {
                display: none;
            }

            body.sidebar-collapsed .brand {
                padding: 0;
                justify-content: center;
            }

            body.sidebar-collapsed .brand-icon {
                margin-right: 0;
            }

            body.sidebar-collapsed .nav-item {
                justify-content: center;
                padding: 14px 0;
            }

            body.sidebar-collapsed .nav-item i {
                margin: 0;
                font-size: 1.4rem;
            }

            body.sidebar-collapsed .sidebar-toggle-btn i {
                transform: rotate(180deg);
            }
        }

        .sidebar-overlay {
            position: fixed;
            inset: 0;
            background: rgba(0, 0, 0, 0.5);
            z-index: 900;
            display: none;
            backdrop-filter: blur(2px);
        }

        .mobile-toggle-btn {
            display: none;
            font-size: 1.4rem;
            color: var(--text-main);
            cursor: pointer;
            background: transparent;
            border: none;
            padding: 0;
        }

        @media (max-width: 1199px) {
            .sidebar {
                position: fixed;
                top: 0;
                left: 0;
                bottom: 0;
                transform: translateX(-100%);
                box-shadow: 4px 0 15px rgba(0, 0, 0, 0.1);
            }

            .sidebar.show-sidebar {
                transform: translateX(0);
            }

            .sidebar-toggle-btn {
                display: none;
            }

            .sidebar-overlay.active {
                display: block;
            }

            .mobile-toggle-btn {
                display: block;
            }
        }

        .main-wrapper {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            background: var(--bg-body);
            position: relative;
        }

        .top-header {
            height: var(--header-height);
            background: var(--surface);
            border-bottom: 1px solid var(--border);
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0 24px;
            flex-shrink: 0;
        }

        .live-clock {
            font-family: 'Courier New', monospace;
            font-weight: 700;
            color: var(--primary);
            font-size: 1rem;
            background: var(--primary-bg);
            padding: 5px 12px;
            border-radius: 6px;
        }

        .header-nav-group {
            background: #F2F4F7;
            border: 1px solid var(--border);
            padding: 4px;
            border-radius: 8px;
            display: flex;
            gap: 4px;
            margin-left: 15px;
        }

        .header-nav-btn {
            padding: 6px 14px;
            border-radius: 6px;
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--text-sub);
            cursor: pointer;
            transition: all 0.2s ease;
            border: none;
            background: transparent;
            display: flex;
            align-items: center;
            gap: 8px;
            white-space: nowrap;
        }

        .header-nav-btn:hover {
            color: var(--text-main);
            background: rgba(0, 0, 0, 0.03);
        }

        .header-nav-btn.active {
            background: white;
            color: var(--primary);
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.08);
        }

        .view-section {
            flex: 1;
            overflow: hidden;
            display: none;
            padding: 24px;
            flex-direction: column;
            animation: fadeIn 0.3s ease-out;
        }

        .view-section.active {
            display: flex;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(10px);
            }

            to {
                transform: translateY(0);
            }
        }

        .quick-actions-bar {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 20px;
            margin-bottom: 24px;
        }

        .quick-action-btn {
            background: white;
            border: 1px solid var(--border);
            padding: 16px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            gap: 12px;
            cursor: pointer;
            transition: 0.2s;
            box-shadow: var(--shadow);
        }

        .quick-action-btn:hover {
            border-color: var(--primary);
            transform: translateY(-3px);
        }

        .quick-icon {
            width: 42px;
            height: 42px;
            border-radius: 10px;
            background: var(--primary-bg);
            color: var(--primary);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
        }

        .stat-card {
            background: white;
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 20px;
            box-shadow: var(--shadow);
            height: 100%;
            transition: 0.3s;
            position: relative;
        }

        .stat-val {
            font-size: 1.6rem;
            font-weight: 700;
            margin: 8px 0;
            color: var(--text-main);
        }

        .chart-wrapper {
            position: relative;
            height: 250px;
            width: 100%;
        }

        #dashboard-view {
            overflow-y: auto;
        }

        .pos-container {
            display: flex;
            gap: 20px;
            height: 100%;
            overflow: hidden;
        }

        .pos-left {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 15px;
            overflow: hidden;
        }

        .cat-scroll {
            display: flex;
            gap: 10px;
            overflow-x: auto;
            padding-bottom: 5px;
            flex-shrink: 0;
        }

        .cat-btn {
            padding: 8px 20px;
            background: white;
            border: 1px solid var(--border);
            border-radius: 50px;
            font-size: 0.95rem;
            font-weight: 600;
            color: var(--text-sub);
            white-space: nowrap;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            gap: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
        }

        .cat-btn:hover {
            border-color: #FF6B00;
            color: #FF6B00;
            transform: translateY(-2px);
        }

        .cat-btn.active {
            background: linear-gradient(135deg, #FF6B00 0%, #FF8534 100%);
            color: white;
            border-color: transparent;
            box-shadow: 0 4px 12px rgba(255, 107, 0, 0.4);
            transform: translateY(-2px);
        }

        .prod-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(110px, 1fr));
            gap: 10px;
            overflow-y: auto;
            padding-right: 5px;
            padding-bottom: 80px;
        }

        .prod-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 10px;
            padding: 6px;
            cursor: pointer;
            transition: 0.2s;
            display: flex;
            flex-direction: column;
            position: relative;
        }

        .prod-card:hover {
            border-color: var(--primary);
            transform: translateY(-2px);
            box-shadow: var(--shadow);
        }

        .prod-img {
            width: 100%;
            height: 75px;
            object-fit: cover;
            border-radius: 8px;
            margin-bottom: 6px;
            background: #f5f5f5;
        }

        .prod-title {
            font-size: 0.75rem;
            font-weight: 600;
            margin-bottom: 2px;
            line-height: 1.2;
            color: var(--text-main);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .prod-price {
            font-size: 0.8rem;
            font-weight: 700;
            color: var(--primary);
        }

        .add-btn-icon {
            position: absolute;
            bottom: 6px;
            right: 6px;
            width: 22px;
            height: 22px;
            background: var(--primary-bg);
            color: var(--primary);
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.65rem;
        }

        .cart-panel {
            width: 340px;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 14px;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            flex-shrink: 0;
            box-shadow: var(--shadow);
        }

        .cart-header {
            padding: 15px 20px;
            border-bottom: 1px solid var(--border);
            background: #FCFCFD;
        }

        /* --- REDESIGNED REPORTS & Z-REPORT STYLES --- */
        .report-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 24px;
        }

        .premium-card {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.05);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            overflow: hidden;
        }

        .premium-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.08);
        }

        .gradient-card-primary {
            background: linear-gradient(135deg, #FF6B00 0%, #FF8533 100%);
            color: white;
        }

        .gradient-card-success {
            background: linear-gradient(135deg, #12B76A 0%, #2ED38A 100%);
            color: white;
        }

        .gradient-card-info {
            background: linear-gradient(135deg, #00B1FF 0%, #33C5FF 100%);
            color: white;
        }

        .gradient-card-danger {
            background: linear-gradient(135deg, #F04438 0%, #F57066 100%);
            color: white;
        }

        .filter-panel {
            background: white;
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
        }

        .summary-stat {
            padding: 20px;
            border-radius: 16px;
            text-align: center;
            transition: 0.3s;
        }

        .summary-stat .label {
            font-size: 0.8rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            opacity: 0.8;
            margin-bottom: 8px;
        }

        .summary-stat .value {
            font-size: 1.8rem;
            font-weight: 700;
        }

        .report-table-container {
            background: white;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
        }

        .report-table thead th {
            background: #F9FAFB;
            font-weight: 600;
            color: var(--text-sub);
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 0.5px;
            padding: 16px;
            border-bottom: 1px solid var(--border);
        }

        .report-table td {
            padding: 16px;
            vertical-align: middle;
            color: var(--text-main);
            border-bottom: 1px solid var(--border);
        }

        .badge-premium {
            padding: 6px 12px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.75rem;
        }

        .cart-items {
            flex: 1;
            overflow-y: auto;
            padding: 15px;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .cart-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px;
            border: 1px solid var(--border);
            border-radius: 10px;
            background: #FAFAFA;
            font-size: 0.9rem;
        }

        .cart-controls {
            display: flex;
            align-items: center;
            gap: 5px;
            background: white;
            border: 1px solid #e0e0e0;
            border-radius: 6px;
            padding: 2px;
        }

        .qty-btn {
            width: 24px;
            height: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            border: none;
            background: transparent;
            cursor: pointer;
            color: var(--text-main);
            font-size: 0.8rem;
            border-radius: 4px;
        }

        .qty-btn:hover {
            background: #eee;
        }

        .qty-val {
            width: 20px;
            text-align: center;
            font-weight: 600;
            font-size: 0.85rem;
        }

        .cart-footer {
            padding: 15px 20px;
            border-top: 1px solid var(--border);
            background: white;
        }

        .mobile-cart-btn {
            display: none;
        }

        @media (max-width: 991px) {
            .pos-container {
                flex-direction: column;
            }

            .pos-left {
                height: auto;
                flex-grow: 1;
            }

            .prod-grid {
                padding-bottom: 20px;
            }

            .pos-container {
                height: calc(100vh - var(--header-height));
                overflow-y: auto;
            }

            .cart-panel {
                position: fixed;
                top: 0;
                right: 0;
                bottom: 0;
                width: 85%;
                max-width: 380px;
                z-index: 2000;
                transform: translateX(100%);
                transition: transform 0.3s;
                margin: 0;
                border-radius: 0;
            }

            .cart-panel.open {
                transform: translateX(0);
            }

            .mobile-cart-btn {
                display: flex;
                position: fixed;
                bottom: 30px;
                right: 30px;
                z-index: 1500;
                width: 55px;
                height: 55px;
                background: var(--primary);
                color: white;
                border-radius: 50%;
                justify-content: center;
                align-items: center;
                box-shadow: 0 4px 15px rgba(255, 107, 0, 0.4);
                font-size: 1.3rem;
                cursor: pointer;
            }
        }

        .table-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
            gap: 12px;
            overflow-y: auto;
            padding-bottom: 40px;
        }

        .table-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-top: 4px solid var(--border);
            border-radius: 12px;
            padding: 10px;
            text-align: center;
            cursor: pointer;
            transition: 0.2s;
            box-shadow: var(--shadow);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 95px;
        }

        .table-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 15px rgba(0, 0, 0, 0.05);
        }

        .table-card.is-free {
            border-top-color: var(--status-free);
        }

        .table-card.is-free .table-icon {
            color: var(--status-free);
            opacity: 0.9;
        }

        .table-card.is-busy {
            border-top-color: var(--status-busy);
            background: #FFF5F5;
        }

        .table-card.is-busy .table-icon {
            color: var(--status-busy);
        }

        .table-card.needs-attention {
            border-top-color: var(--status-pay);
            background: #FFFAEB;
        }

        .table-card.needs-attention .table-icon {
            color: var(--status-pay);
        }

        .table-icon {
            font-size: 1.4rem;
            margin-bottom: 4px;
        }

        .table-name {
            font-weight: 700;
            font-size: 0.95rem;
            color: var(--text-main);
        }

        .table-meta {
            font-size: 0.75rem;
            color: var(--text-sub);
            margin-bottom: 4px;
        }

        .table-timer {
            font-size: 0.75rem;
            font-family: monospace;
            background: white;
            padding: 1px 6px;
            border-radius: 4px;
            border: 1px solid var(--border);
        }

        .data-table-container {
            background: white;
            border: 1px solid var(--border);
            border-radius: 14px;
            overflow: hidden;
            box-shadow: var(--shadow);
            display: flex;
            flex-direction: column;
            flex: 1;
            min-height: 0;
        }

        .table-scroll-wrapper {
            flex: 1;
            overflow-y: auto;
        }

        .table thead th {
            background: #F9FAFB;
            font-weight: 600;
            color: var(--text-sub);
            font-size: 0.8rem;
            text-transform: uppercase;
            padding: 14px 20px;
            border-bottom: 1px solid var(--border);
            white-space: nowrap;
            position: sticky;
            top: 0;
            z-index: 5;
        }

        .table tbody td {
            padding: 14px 20px;
            vertical-align: middle;
            color: var(--text-main);
            font-size: 0.9rem;
            border-bottom: 1px solid var(--border);
        }

        .filter-bar {
            display: flex;
            gap: 10px;
            margin-bottom: 15px;
            flex-wrap: wrap;
        }

        .pagination-wrapper {
            padding: 12px 20px;
            border-top: 1px solid var(--border);
            background: #fff;
            flex-shrink: 0;
        }

        .prod-card.out-of-stock {
            opacity: 0.7;
            filter: grayscale(100%);
            pointer-events: none;
            position: relative;
        }

        .sold-out-badge {
            position: absolute;
            top: 8px;
            right: 8px;
            background: linear-gradient(135deg, #ff4d4f 0%, #d9363e 100%);
            color: white;
            font-size: 11px;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 20px;
            z-index: 10;
            box-shadow: 0 4px 10px rgba(217, 54, 62, 0.4);
            text-transform: uppercase;
            display: flex;
            align-items: center;
            gap: 5px;
            letter-spacing: 0.5px;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .prod-card.out-of-stock img {
            filter: grayscale(100%) opacity(0.5);
            transition: all 0.3s ease;
        }

        @keyframes badge-pulse {
            0% {
                box-shadow: 0 0 0 0 rgba(255, 77, 79, 0.4);
            }

            70% {
                box-shadow: 0 0 0 10px rgba(255, 77, 79, 0);
            }

            100% {
                box-shadow: 0 0 0 0 rgba(255, 77, 79, 0);
            }
        }

        .low-stock-badge {
            position: absolute;
            top: 5px;
            right: 5px;
            font-size: 10px;
            padding: 2px 6px;
            border-radius: 10px;
            z-index: 5;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }

        .generic-modal-overlay {
            position: fixed;
            inset: 0;
            background: rgba(0, 0, 0, 0.6);
            z-index: 1050;
            display: none;
            align-items: center;
            justify-content: center;
            backdrop-filter: blur(4px);
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .modal-card {
            background: var(--surface);
            width: 90%;
            max-width: 450px;
            padding: 0;
            border-radius: 16px;
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.3);
            transform: scale(0.95) translateY(20px);
            opacity: 0;
            transition: transform 0.3s, opacity 0.3s;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            max-height: 90vh;
        }

        .generic-modal-overlay.open {
            display: flex;
            opacity: 1;
        }

        .generic-modal-overlay.open .modal-card {
            transform: scale(1) translateY(0);
            opacity: 1;
        }

        .modal-header-custom {
            padding: 18px 24px;
            border-bottom: 1px solid var(--border);
            background: #FAFAFA;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-body-custom {
            padding: 24px;
            overflow-y: auto;
        }

        .modal-close-btn {
            border: none;
            background: transparent;
            font-size: 1.3rem;
            color: var(--text-sub);
            cursor: pointer;
        }

        .action-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }

        .action-card-btn {
            background: #F9FAFB;
            border: 1px solid var(--border);
            padding: 18px;
            border-radius: 12px;
            text-align: center;
            cursor: pointer;
            transition: 0.2s;
            color: var(--text-main);
        }

        .action-card-btn:hover {
            background: white;
            border-color: var(--primary);
            box-shadow: var(--shadow);
            color: var(--primary);
        }

        .action-card-btn i {
            font-size: 1.6rem;
            display: block;
            margin-bottom: 10px;
        }

        .action-card-btn.danger {
            color: #B42318;
            background: #FEF3F2;
            border-color: #FECDCA;
        }

        .action-card-btn.danger:hover {
            background: #B42318;
            color: white;
            border-color: #B42318;
        }

        /* Calculator Container */
        .calculator-wrapper {
            background: rgba(255, 255, 255, 0.85);
            /* Adjusted for modal visibility */
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border-radius: 30px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            padding: 25px;
            width: 100%;
            max-width: 400px;
            display: flex;
            flex-direction: column;
            margin: 0 auto;
            /* Center in modal */
            position: relative;
        }

        /* Display Area */
        .calc-display {
            background: #111;
            border-radius: 15px;
            padding: 0 18px;
            margin-bottom: 20px;
            display: flex;
            /* enable flexbox */
            flex-direction: column;
            /* stack input and result */
            align-items: center;
            /* Centered horizontally */
            justify-content: center;
            /* Centered vertically */
            min-height: 60px;
            max-height: 70px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            box-shadow: inset 0 -2px 5px rgba(255, 255, 255, 0.1);
            word-break: break-all;
            text-align: center;
            /* Centered text */
        }

        .calc-input-line,
        .calc-result-line {
            color: #fff;
            text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.5);
        }

        .calc-input-line {
            font-size: 2.5rem;
            /* bigger digits */
            min-height: 40px;
            font-weight: 400;
        }

        .calc-result-line {
            font-size: 3rem;
            /* bigger result */
            min-height: 50px;
            font-weight: 700;
        }

        /* Button Grid */
        .calc-button-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 12px;
        }

        /* Buttons */
        .calc-btn {
            width: 100%;
            aspect-ratio: 1 / 1;
            font-size: 1.5rem;
            border: none;
            border-radius: 16px;
            cursor: pointer;
            transition: all 0.2s cubic-bezier(0.25, 0.8, 0.25, 1);
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', sans-serif;
            padding: 0;
            line-height: 1;
        }

        .calc-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(0, 0, 0, 0.1);
        }

        .calc-btn:active {
            transform: translateY(0);
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
        }

        /* Variants */
        .calc-btn-op {
            background: linear-gradient(135deg, #1a73e8, #4285f4);
            color: #fff;
            font-weight: 600;
        }

        .calc-btn-clear {
            background: linear-gradient(135deg, #ff5252, #ff1744);
            color: #fff;
            font-weight: 600;
        }

        .calc-btn-fn {
            background: #f1f3f4;
            color: #333;
            font-weight: 500;
        }

        .calc-btn-num {
            background: #ffffff;
            color: #202124;
            font-weight: 400;
        }

        .calc-btn-zero {
            grid-column: span 2;
            aspect-ratio: auto;
        }

        /* Dark Mode Overrides */
        [data-theme="dark"] .calculator-wrapper {
            background: rgba(30, 30, 30, 0.95);
        }

        [data-theme="dark"] .calc-display {
            background: rgba(0, 0, 0, 0.3);
            border-color: rgba(255, 255, 255, 0.1);
        }

        [data-theme="dark"] .calc-input-line {
            color: #aaa;
        }

        [data-theme="dark"] .calc-result-line {
            color: #4285f4;
        }

        [data-theme="dark"] .calc-btn-num {
            background: #2D2D2D;
            color: #eee;
        }

        [data-theme="dark"] .calc-btn-fn {
            background: #3c4043;
            color: #eee;
        }

        .calc-btn:active {
            filter: brightness(1.5);
            /* Simulates the iOS dimming/highlight effect */
        }

        [data-theme="dark"] .calc-btn:active {
            filter: brightness(1.3);
        }

        .calc-btn.span-2 {
            aspect-ratio: auto;
            grid-column: span 2;
            border-radius: 50px;
            justify-content: flex-start;
            padding-left: 32px;
        }

        .toast-container {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 2100;
        }

        .custom-toast {
            min-width: 250px;
            padding: 12px 18px;
            margin-bottom: 10px;
            border-radius: 8px;
            background: #333;
            color: #fff;
            opacity: 0;
            transition: 0.5s;
            transform: translateX(100%);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .custom-toast.show {
            opacity: 1;
            transform: translateX(0);
        }

        .invoice-preview {
            font-family: 'Courier New', monospace;
            border: 1px solid #ddd;
            padding: 20px;
            background: #fff;
            margin-bottom: 15px;
            font-size: 0.85rem;
        }

        .invoice-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 5px;
        }

        .invoice-divider {
            border-top: 1px dashed #aaa;
            margin: 10px 0;
        }

        .cart-empty {
            text-align: center;
            padding: 40px 20px;
            color: var(--text-sub);
        }

        .cart-empty i {
            font-size: 3rem;
            margin-bottom: 15px;
            opacity: 0.3;
        }

        /* GLOBAL TABLE DARK MODE OVERRIDES - High Specificity */
        [data-theme="dark"] .table {
            background-color: transparent !important;
            color: var(--text-main) !important;
        }

        [data-theme="dark"] .table tbody td,
        [data-theme="dark"] .table tbody th {
            background-color: var(--surface);
            border-color: var(--border);
            color: var(--text-main);
        }

        [data-theme="dark"] .table-hover tbody tr:hover td,
        [data-theme="dark"] .table-hover tbody tr:hover th {
            background-color: #2D2D2D !important;
            color: white !important;
        }

        [data-theme="dark"] .table-hover tbody tr:hover {
            background-color: #2D2D2D !important;
        }

        /* --- CRITICAL VISIBILITY FIX (Nuclear Option) --- */
        .badge-soft {
            padding: 5px 10px;
            border-radius: 6px;
            font-weight: 700 !important;
            font-size: 0.75rem;
            letter-spacing: 0.3px;
            opacity: 1 !important;
        }

        .badge-soft-success,
        [data-bs-theme="dark"] .badge-soft-success,
        .table-hover tr:hover .badge-soft-success {
            background-color: #d1fae5 !important;
            color: #064e3b !important;
            /* Force Dark Green */
            -webkit-text-fill-color: #064e3b !important;
            border: 1px solid #d1fae5 !important;
        }

        .badge-soft-warning,
        [data-bs-theme="dark"] .badge-soft-warning,
        .table-hover tr:hover .badge-soft-warning {
            background-color: #fef3c7 !important;
            color: #78350f !important;
            /* Force Dark Brown */
            -webkit-text-fill-color: #78350f !important;
            border: 1px solid #fef3c7 !important;
        }

        .badge-soft-danger,
        [data-bs-theme="dark"] .badge-soft-danger,
        .table-hover tr:hover .badge-soft-danger {
            background-color: #fee2e2 !important;
            color: #7f1d1d !important;
            /* Force Dark Red */
            -webkit-text-fill-color: #7f1d1d !important;
            border: 1px solid #fee2e2 !important;
        }
    </style>
</head>

<body>

    <div id="app-container">
        <div class="sidebar-overlay" id="sidebar-overlay" onclick="toggleMobileSidebar()"></div>
        <div class="sidebar" id="sidebar">
            <div class="brand">
                <div class="brand-icon"><i class="fas fa-layer-group"></i></div>
                <h4 class="m-0 fs-5">GustoPOS</h4>
            </div>
            <div class="sidebar-toggle-btn d-none d-xl-flex" onclick="toggleSidebar()"><i
                    class="fas fa-chevron-left"></i></div>
            <div class="sidebar-content">
                <?php if ($currentRole === 'admin'): ?>
                    <a class="nav-item active" onclick="switchView('dashboard', this)"><i class="fas fa-chart-pie"></i>
                        <span>Dashboard</span></a>
                    <div class="menu-label">Operations</div>
                <?php endif; ?>

                <a class="nav-item <?= $currentRole === 'cashier' ? 'active' : '' ?>"
                    onclick="switchView('pos', this)"><i class="fas fa-cash-register"></i> <span>POS
                        Terminal</span></a>
                <a class="nav-item" onclick="switchView('tables', this)"><i class="fas fa-chair"></i> <span>Floor
                        Plan</span></a>
                <?php if ($currentRole === 'admin'): ?>
                    <a class="nav-item" onclick="switchView('history', this)"><i class="fas fa-history"></i> <span>Sales
                            History</span></a>
                    <a class="nav-item" onclick="switchView('deleted', this)"><i class="fas fa-trash"></i> <span>Deleted
                            Sales</span></a>
                    <a class="nav-item" onclick="switchView('expenses', this)"><i class="fas fa-wallet"></i>
                        <span>Expenses</span></a>
                    <a class="nav-item" onclick="switchView('inventory', this)"><i class="fas fa-boxes-stacked"></i>
                        <span>Inventory</span></a>

                    <a class="nav-item" onclick="switchView('recipes', this)"><i class="fas fa-blender"></i>
                        <span>Recipes</span></a>
                    <div class="menu-label">Management</div>
                    <a class="nav-item" onclick="switchView('menu', this)"><i class="fas fa-utensils"></i> <span>Menu
                            Mgmt</span></a>
                    <a class="nav-item" onclick="switchView('suppliers', this)"><i class="fas fa-truck"></i>
                        <span>Suppliers</span></a>
                    <a class="nav-item" onclick="switchView('waiters', this)"><i class="fas fa-user-tie"></i>
                        <span>Staff</span></a>
                    <!-- Start Shift Link Removed -->
                    <div class="menu-label">Reports</div>
                    <a class="nav-item" onclick="switchView('export', this)"><i class="fas fa-download"></i>
                        <span>Export Sales</span></a>
                    <div class="menu-label">System</div>
                    <a class="nav-item" onclick="switchView('settings-management', this)"><i class="fas fa-cog"></i>
                        <span>Settings</span></a>
                <?php endif; ?>
            </div>
        </div>

        <div class="main-wrapper">
            <div class="top-header">
                <div class="d-flex align-items-center gap-3">
                    <button class="mobile-toggle-btn" onclick="toggleMobileSidebar()"><i
                            class="fas fa-bars"></i></button>
                    <div class="header-nav-group">
                        <button class="header-nav-btn" onclick="switchView('pos')" data-view="pos"><i
                                class="fas fa-cash-register"></i> POS</button>
                        <button class="header-nav-btn" onclick="switchView('tables')" data-view="tables"><i
                                class="fas fa-chair"></i> Floor</button>
                    </div>
                    <div class="d-none d-md-flex flex-column align-items-start ms-2">
                        <div class="live-clock" id="live-clock">--:--:--</div>
                        <small class="text-muted text-xs">Business Day: <span
                                id="business-day-timer">00:00:00</span></small>
                    </div>
                </div>
                <div class="d-flex align-items-center gap-3">
                    <button id="offline-sync-btn" class="btn btn-warning btn-sm fw-bold"
                        onclick="OfflineManager.syncOrders()" style="display:none; align-items:center; gap:5px;">
                        <i class="fas fa-cloud-upload-alt"></i> Sync Orders
                    </button>
                    <button class="btn btn-outline-secondary btn-sm d-none d-md-block"
                        onclick="showToast('Printing last receipt...')"><i class="fas fa-print"></i></button>
                    <button class="btn btn-outline-secondary btn-sm" onclick="toggleTheme()" title="Toggle Theme">
                        <i class="fas fa-moon" id="theme-icon"></i>
                    </button>
                    <button class="btn btn-outline-secondary btn-sm" onclick="openModal('calculator-modal')"
                        title="Calculator"><i class="fas fa-calculator"></i></button>
                    <div class="dropdown">
                        <div class="position-relative cursor-pointer text-secondary" data-bs-toggle="dropdown"
                            id="notification-bell">
                            <i class="fas fa-bell fs-5"></i>
                            <span
                                class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger"
                                id="notification-badge" style="font-size: 0.6rem; display: none;">0</span>
                        </div>
                        <ul class="dropdown-menu dropdown-menu-end shadow border-0 p-0" style="min-width: 280px;">
                            <li>
                                <h6 class="dropdown-header py-3 border-bottom">Notifications</h6>
                            </li>
                            <div id="notification-list">
                                <li><span class="dropdown-item text-muted small text-center py-4">Loading...</span></li>
                            </div>
                        </ul>
                    </div>
                    <div class="dropdown">
                        <div class="d-flex align-items-center gap-2 cursor-pointer" data-bs-toggle="dropdown">
                            <div class="d-none d-lg-block text-end me-2" style="line-height: 1.1;">
                                <div class="fw-bold small"><?= htmlspecialchars($currentUser) ?></div>
                                <small class="text-muted"
                                    style="font-size: 0.75rem;"><?= ucfirst($currentRole) ?></small>
                            </div>
                            <img src="https://ui-avatars.com/api/?name=<?= urlencode($currentUser) ?>&background=FF6B00&color=fff"
                                class="rounded-circle border" width="38" height="38" alt="Profile">
                        </div>
                        <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-2">
                            <li><a class="dropdown-item py-2" href="javascript:void(0)"
                                    onclick="switchView('settings-management')"><i class="fas fa-cog me-2"></i>
                                    Settings</a></li>
                            <li>
                                <hr class="dropdown-divider">
                            </li>
                            <li><a class="dropdown-item py-2 text-danger" href="javascript:void(0)"
                                    onclick="logoutUser()"><i class="fas fa-sign-out-alt me-2"></i> Logout</a></li>
                        </ul>
                    </div>
                </div>
            </div>

            <!-- MODULAR VIEWS -->
            <?php include 'views/dashboard.php'; ?>
            <?php include 'views/export_sales.php'; ?>
            <?php include 'views/settings_management.php'; ?>

            <!-- POS VIEW -->
            <div id="pos-view" class="view-section" style="padding: 15px;">
                <div class="pos-container">
                    <div class="pos-left">
                        <div class="cat-scroll" id="category-scroll"></div>
                        <div class="prod-grid" id="product-grid"></div>
                    </div>
                    <div class="cart-panel" id="cart-panel">
                        <div class="cart-header">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <h6 class="m-0 fw-bold">Order <span id="order-number">#NEW</span></h6>
                                <div class="d-flex gap-2">
                                    <button class="btn btn-sm btn-outline-warning" title="Held Orders"
                                        onclick="openModal('held-orders-modal')"><i class="fas fa-clock"></i></button>
                                    <i class="fas fa-trash-alt text-danger cursor-pointer pt-1" title="Clear All"
                                        onclick="clearCart()"></i>
                                </div>
                            </div>
                            <select class="form-select form-select-sm" id="cart-table">
                                <option value="">Walk-in Customer</option>
                            </select>
                        </div>
                        <div class="cart-items" id="cart-items">
                            <div class="cart-empty"><i class="fas fa-shopping-basket d-block"></i>
                                <div>Cart is empty</div><small class="text-muted">Click products to add</small>
                            </div>
                        </div>
                        <div class="cart-footer">
                            <div class="cart-summary-breakdown mb-2" id="cart-summary-breakdown">
                                <!-- Cart summary built dynamically by renderCart() -->
                            </div>
                            <div class="row g-2 mb-2">
                                <div class="col-6"><button
                                        class="btn btn-outline-secondary w-100 py-2 fw-bold rounded-3"
                                        onclick="sendToKitchen()"><i class="fas fa-fire me-2"></i>KOT</button></div>
                                <div class="col-6"><button
                                        class="btn btn-warning w-100 py-2 fw-bold rounded-3 text-white"
                                        onclick="holdOrder()"><i class="fas fa-pause me-2"></i>Hold</button></div>
                            </div>
                            <button class="btn btn-primary w-100 py-3 fw-bold rounded-3 fs-6" type="button"
                                onclick="payOrder(event, false)" id="pay-btn">PAY $0.00</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- TABLES VIEW -->
            <div id="tables-view" class="view-section">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h4 class="mb-0">Floor Plan</h4>
                    <button class="btn btn-primary" onclick="openModal('add-table-modal')"><i
                            class="fas fa-plus me-2"></i>Add Table</button>
                </div>
                <div class="table-grid" id="tables-container"></div>
            </div>

            <!-- HISTORY VIEW -->
            <div id="history-view" class="view-section">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h4 class="mb-0">Sales History</h4>
                </div>
                <div class="filter-bar">
                    <input type="date" class="form-control" id="history-date" style="width: auto;">
                    <input type="text" class="form-control" id="history-search" placeholder="Search Invoice #"
                        style="width: 200px;">
                    <button class="btn btn-primary" onclick="loadOrders()">Search</button>
                </div>
                <div class="data-table-container">
                    <div class="table-scroll-wrapper">
                        <table id="history-table" class="table table-hover mb-0">
                            <thead>
                                <tr>
                                    <th>Invoice</th>
                                    <th>Date</th>
                                    <th>Customer</th>
                                    <th>Amount</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="history-tbody"></tbody>
                        </table>
                    </div>
                </div>
                <div class="pagination-container" id="history-pagination"></div>
            </div>

            <!-- DELETED VIEW -->
            <div id="deleted-view" class="view-section">
                <h4 class="text-danger mb-3">Deleted Sales</h4>
                <div class="data-table-container">
                    <div class="table-scroll-wrapper">
                        <table id="deleted-table" class="table table-hover mb-0">
                            <thead>
                                <tr>
                                    <th>Order ID</th>
                                    <th>Deleted By</th>
                                    <th>Amount</th>
                                    <th>Reason</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody id="deleted-tbody"></tbody>
                        </table>
                    </div>
                </div>
                <div class="pagination-container" id="deleted-pagination"></div>
            </div>

            <!-- EXPENSES VIEW -->
            <div id="expenses-view" class="view-section">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h4 class="mb-0">Expenses</h4><button class="btn btn-primary"
                        onclick="openModal('add-expense-modal')"><i class="fas fa-plus me-2"></i> Add</button>
                </div>
                <div class="data-table-container">
                    <div class="table-scroll-wrapper">
                        <table id="expenses-table" class="table table-hover mb-0">
                            <thead>
                                <tr>
                                    <th>Date</th>
                                    <th>Category</th>
                                    <th>Description</th>
                                    <th>Amount</th>
                                    <th class="text-end">Action</th>
                                </tr>
                            </thead>
                            <tbody id="expenses-tbody"></tbody>
                        </table>
                    </div>
                </div>
                <div class="pagination-container" id="expenses-pagination"></div>
            </div>

            <!-- INVENTORY VIEW -->
            <div id="inventory-view" class="view-section">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h4 class="mb-0">Inventory</h4><button class="btn btn-primary"
                        onclick="openModal('add-stock-modal')"><i class="fas fa-plus me-2"></i> Stock In</button>
                </div>
                <div class="data-table-container">
                    <div class="table-scroll-wrapper">
                        <table id="inventory-table" class="table table-hover mb-0">
                            <thead>
                                <tr>
                                    <th>Item</th>
                                    <th>SKU</th>
                                    <th>Unit</th>
                                    <th>Stock</th>
                                    <th>Cost/Unit</th>
                                    <th>Supplier</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody id="inventory-tbody"></tbody>
                        </table>
                    </div>
                </div>
                <div class="pagination-container" id="inventory-pagination"></div>
            </div>

            <!-- MENU VIEW -->
            <div id="menu-view" class="view-section">
                <!-- Header with Tabs and Actions -->
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h4 class="mb-0">Menu Management</h4>

                    <div class="d-flex align-items-center gap-2">
                        <!-- Navigation Tabs -->
                        <ul class="nav nav-pills" id="menu-mgmt-tabs">
                            <li class="nav-item">
                                <button class="nav-link btn btn-light btn-sm active me-2" data-bs-toggle="pill"
                                    data-bs-target="#tab-products" onclick="toggleMenuButtons('products')"
                                    style="border-radius: 6px;">Products</button>
                            </li>
                            <li class="nav-item">
                                <button class="nav-link btn btn-light btn-sm" data-bs-toggle="pill"
                                    data-bs-target="#tab-categories"
                                    onclick="loadCategories(); toggleMenuButtons('categories')"
                                    style="border-radius: 6px;">Categories</button>
                            </li>
                        </ul>

                        <!-- Action Buttons -->
                        <div class="menu-actions" id="menu-actions">
                            <button class="btn btn-primary btn-sm" id="btn-add-item"
                                onclick="openModal('add-item-modal')"><i class="fas fa-plus me-2"></i> Add Item</button>
                            <button class="btn btn-primary btn-sm" id="btn-add-category"
                                onclick="openModal('add-category-modal')" style="display:none;"><i
                                    class="fas fa-plus me-2"></i> Add Category</button>
                        </div>
                    </div>
                </div>

                <div class="tab-content">
                    <!-- Products Tab -->
                    <div class="tab-pane fade show active" id="tab-products">
                        <div class="data-table-container">
                            <div class="table-scroll-wrapper">
                                <table id="menu-table" class="table table-hover mb-0">
                                    <thead>
                                        <tr>
                                            <th>Image</th>
                                            <th>Name</th>
                                            <th>Category</th>
                                            <th>Price</th>
                                            <th>Availability</th>
                                            <th class="text-end">Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody id="menu-tbody"></tbody>
                                </table>
                            </div>
                        </div>
                        <div class="pagination-container" id="menu-pagination"></div>
                    </div>

                    <!-- Categories Tab -->
                    <div class="tab-pane fade" id="tab-categories">
                        <div class="data-table-container">
                            <div class="table-scroll-wrapper">
                                <table id="categories-table" class="table table-hover mb-0">
                                    <thead>
                                        <tr>
                                            <th>Category Name</th>
                                            <th class="text-end">Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody id="categories-tbody"></tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- STAFF VIEW -->
            <div id="waiters-view" class="view-section">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h4 class="mb-0">Staff & Shifts</h4><button class="btn btn-primary"
                        onclick="openModal('add-staff-modal')">Add Staff</button>
                </div>
                <div class="data-table-container">
                    <div class="table-scroll-wrapper">
                        <table id="staff-table" class="table table-hover mb-0">
                            <thead>
                                <tr>
                                    <th>Name</th>
                                    <th>Role</th>
                                    <th>Shift Start</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="staff-tbody"></tbody>
                        </table>
                    </div>
                </div>
                <div class="pagination-container" id="staff-pagination"></div>
            </div>



            <!-- RECIPES VIEW -->
            <div id="recipes-view" class="view-section">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h4 class="mb-0">Recipe Management</h4>
                </div>
                <div class="card shadow-sm border-0 rounded-4 overflow-hidden">
                    <div
                        class="view-section-header p-3 bg-white border-bottom d-flex justify-content-between align-items-center">
                        <h5 class="mb-0 fw-bold">Recipe List</h5>
                        <button class="btn btn-primary btn-sm rounded-pill px-3"
                            onclick="openModal('add-recipe-modal')"><i class="fas fa-plus me-1"></i> Add Recipe</button>
                    </div>
                    <div class="table-responsive" style="max-height: 600px;">
                        <table id="recipes-table" class="table table-hover align-middle mb-0">
                            <thead>
                                <tr>
                                    <th>Product</th>
                                    <th>Ingredient</th>
                                    <th>Qty Required</th>
                                    <th class="text-end">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="recipe-table-body"></tbody>
                        </table>
                    </div>
                    <div class="pagination-container" id="recipes-pagination"></div>
                </div>
            </div>

            <!-- SUPPLIERS VIEW -->
            <div id="suppliers-view" class="view-section">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h4 class="mb-0">Suppliers</h4>
                    <button class="btn btn-primary" onclick="openModal('add-supplier-modal')"><i
                            class="fas fa-plus me-2"></i>Add Supplier</button>
                </div>
                <div class="data-table-container">
                    <div class="table-scroll-wrapper">
                        <table id="suppliers-table" class="table table-hover mb-0">
                            <thead>
                                <tr>
                                    <th>Name</th>
                                    <th>Contact</th>
                                    <th>Email</th>
                                    <th>Address</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody id="suppliers-tbody"></tbody>
                        </table>
                    </div>
                </div>
                <div id="suppliers-pagination" class="pagination-container"></div>
            </div>




        </div>
    </div>

    <!-- EXPORT VIEW -->
    <div id="export-view" class="view-section" style="display:none; overflow-y:auto;">
        <div class="settings-container">
            <div class="settings-header">
                <h4><i class="fas fa-file-export"></i>Sales Reports</h4>
                <div>
                    <button class="btn btn-outline-primary me-2" onclick="downloadExportPDF()"><i
                            class="fas fa-file-pdf me-2"></i>Download PDF</button>
                    <button class="btn btn-primary" onclick="printSalesSummary()"><i
                            class="fas fa-print me-2"></i>Summary</button>
                </div>
            </div>

            <div class="card border-0 shadow-sm mb-4">
                <div class="card-body p-4">
                    <div class="row g-3 align-items-end">
                        <div class="col-md-3">
                            <label class="small fw-bold">From Date</label>
                            <input type="date" class="form-control" id="export-start-date"
                                onchange="loadExportPreview()">
                        </div>
                        <div class="col-md-3">
                            <label class="small fw-bold">To Date</label>
                            <input type="date" class="form-control" id="export-end-date" onchange="loadExportPreview()">
                        </div>
                        <div class="col-md-4">
                            <label class="small fw-bold">Search</label>
                            <input type="text" class="form-control" id="export-search" placeholder="Search orders..."
                                onkeyup="loadExportPreview()">
                        </div>
                        <div class="col-md-2">
                            <div class="dropdown w-100">
                                <button class="btn btn-light border w-100 dropdown-toggle" type="button"
                                    data-bs-toggle="dropdown">Ranges</button>
                                <ul class="dropdown-menu">
                                    <li><a class="dropdown-item" href="#" onclick="setExportRange('today')">Today</a>
                                    </li>
                                    <li><a class="dropdown-item" href="#" onclick="setExportRange('week')">Last 7
                                            Days</a></li>
                                    <li><a class="dropdown-item" href="#" onclick="setExportRange('month')">Last 30
                                            Days</a></li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card border-0 shadow-sm">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table id="export-table" class="table table-hover mb-0">
                            <thead>
                                <tr>
                                    <th>Order Ref</th>
                                    <th>Date</th>
                                    <th>Customer</th>
                                    <th>Type</th>
                                    <th>Total</th>
                                    <th>Status</th>
                                    <th class="text-end">Action</th>
                                </tr>
                            </thead>
                            <tbody id="export-preview-tbody"></tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="pagination-container">
                <div class="pagination-info" id="export-pagination-info"></div>
                <div class="pagination-wrapper" id="export-pagination"></div>
            </div>
        </div>
    </div>

    <!-- Z-REPORT VIEW -->
    <div id="zreport-view" class="view-section" style="overflow-y:auto; display:none;">
        <div class="settings-container">
            <div class="settings-header">
                <h4><i class="fas fa-file-invoice-dollar"></i>Z-Report</h4>
                <button class="btn btn-primary rounded-pill px-4" onclick="printZReportPage()">
                    <i class="fas fa-print me-2"></i>Print Report
                </button>
            </div>

            <!-- Current Shift Summary Cards -->
            <div class="row g-4 mb-4">
                <div class="col-md-3 col-sm-6">
                    <div class="card border-0 shadow-sm h-100">
                        <div class="card-body text-center">
                            <div class="text-primary mb-2"><i class="fas fa-dollar-sign fa-2x"></i></div>
                            <h6 class="text-muted small mb-1">Total Sales</h6>
                            <h3 class="mb-0 fw-bold text-primary" id="zr-page-total-sales">$0.00</h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6">
                    <div class="card border-0 shadow-sm h-100">
                        <div class="card-body text-center">
                            <div class="text-success mb-2"><i class="fas fa-receipt fa-2x"></i></div>
                            <h6 class="text-muted small mb-1">Order Count</h6>
                            <h3 class="mb-0 fw-bold text-success" id="zr-page-order-count">0</h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6">
                    <div class="card border-0 shadow-sm h-100">
                        <div class="card-body text-center">
                            <div class="text-danger mb-2"><i class="fas fa-ban fa-2x"></i></div>
                            <h6 class="text-muted small mb-1">Voids</h6>
                            <h3 class="mb-0 fw-bold text-danger" id="zr-page-voids">0</h3>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-sm-6">
                    <div class="card border-0 shadow-sm h-100">
                        <div class="card-body text-center">
                            <div class="text-warning mb-2"><i class="fas fa-money-bill-wave fa-2x"></i></div>
                            <h6 class="text-muted small mb-1">Expected Cash</h6>
                            <h3 class="mb-0 fw-bold text-warning" id="zr-page-expected-cash">$0.00</h3>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Close Shift Section -->
            <div class="card border-0 shadow-sm mb-4">
                <div class="card-body p-4">
                    <h5 class="settings-section-title"><i class="fas fa-door-closed text-danger me-2"></i>Close
                        Current Shift</h5>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Actual Cash Amount</label>
                            <input type="number" class="form-control form-control-lg" id="zr-page-actual-cash"
                                placeholder="Enter counted cash" step="0.01">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Notes (Optional)</label>
                            <textarea class="form-control" id="zr-page-notes" rows="2"
                                placeholder="Any discrepancies or comments..."></textarea>
                        </div>
                        <div class="col-12">
                            <button class="btn btn-danger btn-lg px-5" onclick="closeShiftPage()">
                                <i class="fas fa-lock me-2"></i>Close Shift & Generate Z-Report
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Z-Report History -->
            <div class="card border-0 shadow-sm">
                <div class="card-body p-4">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h5 class="settings-section-title mb-0">
                            <i class="fas fa-history text-info me-2"></i>Report History
                        </h5>
                        <input type="date" class="form-control" id="zr-history-date" style="max-width: 200px;"
                            onchange="loadZReportHistory()">
                    </div>

                    <div class="table-scroll-wrapper">
                        <table id="zreport-table" class="table table-hover mb-0">
                            <thead>
                                <tr>
                                    <th class="ps-4">Date & Time</th>
                                    <th>Total Sales</th>
                                    <th>Difference</th>
                                    <th class="text-end pe-4">Action</th>
                                </tr>
                            </thead>
                            <tbody id="zr-history-tbody"></tbody>
                        </table>
                    </div>
                    <div class="pagination-container">
                        <div class="pagination-info" id="zr-history-pagination-info"></div>
                        <div class="pagination-wrapper" id="zr-history-pagination"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="mobile-cart-btn" onclick="openCartMobile()"><i class="fas fa-shopping-basket"></i></div>


    <!-- MODALS -->
    <div class="generic-modal-overlay" id="calculator-modal">
        <div class="modal-card"
            style="max-width: 400px; padding: 0; background: transparent; border: none; box-shadow: none;">
            <div class="modal-body-custom p-0">
                <div class="calculator-wrapper">
                    <button class="modal-close-btn"
                        style="position: absolute; top: 15px; right: 15px; z-index: 10; background: transparent; border: none; color: #888; cursor: pointer;"
                        onclick="closeModal('calculator-modal')">
                        <i class="fas fa-times"></i>
                    </button>

                    <div class="calc-display">
                        <div id="inputDisplay" class="calc-input-line">0</div>
                        <div id="resultDisplay" class="calc-result-line"></div>
                    </div>

                    <div class="calc-button-grid">
                        <button class="calc-btn calc-btn-clear" onclick="calculator('C')">C</button>
                        <button class="calc-btn calc-btn-fn" onclick="calculator('+/-')">+/-</button>
                        <button class="calc-btn calc-btn-fn" onclick="calculator('%')">%</button>
                        <button class="calc-btn calc-btn-op" onclick="calculator('÷')">÷</button>

                        <button class="calc-btn calc-btn-num" onclick="calculator('7')">7</button>
                        <button class="calc-btn calc-btn-num" onclick="calculator('8')">8</button>
                        <button class="calc-btn calc-btn-num" onclick="calculator('9')">9</button>
                        <button class="calc-btn calc-btn-op" onclick="calculator('×')">×</button>

                        <button class="calc-btn calc-btn-num" onclick="calculator('4')">4</button>
                        <button class="calc-btn calc-btn-num" onclick="calculator('5')">5</button>
                        <button class="calc-btn calc-btn-num" onclick="calculator('6')">6</button>
                        <button class="calc-btn calc-btn-op" onclick="calculator('-')">-</button>

                        <button class="calc-btn calc-btn-num" onclick="calculator('1')">1</button>
                        <button class="calc-btn calc-btn-num" onclick="calculator('2')">2</button>
                        <button class="calc-btn calc-btn-num" onclick="calculator('3')">3</button>
                        <button class="calc-btn calc-btn-op" onclick="calculator('+')">+</button>

                        <button class="calc-btn calc-btn-num calc-btn-zero" onclick="calculator('0')">0</button>
                        <button class="calc-btn calc-btn-num" onclick="calculator('.')">.</button>
                        <button class="calc-btn calc-btn-op" onclick="calculator('=')">=</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="generic-modal-overlay" id="held-orders-modal">
        <div class="modal-card">
            <div class="modal-header-custom">
                <h6 class="m-0 fw-bold">Held / Parked Orders</h6><button class="modal-close-btn"
                    onclick="closeModal('held-orders-modal')"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body-custom p-0">
                <div class="list-group list-group-flush" id="held-orders-list">
                    <div class="p-3 text-muted text-center">No held orders</div>
                </div>
            </div>
        </div>
    </div>

    <div class="generic-modal-overlay" id="invoice-modal">
        <div class="modal-card">
            <div class="modal-header-custom">
                <h6 class="m-0 fw-bold" id="invoice-title">Invoice</h6><button class="modal-close-btn"
                    onclick="closeModal('invoice-modal')"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body-custom">
                <div class="invoice-preview" id="invoice-content"></div>
                <button class="btn btn-primary w-100" onclick="showToast('Print sent!')"><i
                        class="fas fa-print me-2"></i> Print Invoice</button>
            </div>
        </div>
    </div>

    <div class="generic-modal-overlay" id="table-options-modal">
        <div class="modal-card">
            <div class="modal-header-custom">
                <h6 class="m-0 fw-bold" id="table-modal-title">Table Options</h6><button class="modal-close-btn"
                    onclick="closeTableOptions()"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body-custom">
                <div class="action-grid">
                    <div class="action-card-btn" onclick="addItemsToTable()"><i
                            class="fas fa-plus-circle text-primary"></i>
                        <div class="small fw-bold">Add Items</div>
                    </div>
                    <div class="action-card-btn" onclick="openTransferModal()"><i
                            class="fas fa-exchange-alt text-success"></i>
                        <div class="small fw-bold">Transfer</div>
                    </div>
                    <div class="action-card-btn" onclick="completeTableOrder()"><i
                            class="fas fa-cash-register text-warning"></i>
                        <div class="small fw-bold">Checkout</div>
                    </div>
                </div>

                <div class="mt-3"><button
                        class="btn btn-outline-danger w-100 btn-sm border-0 bg-danger-subtle text-danger fw-bold py-2"
                        onclick="clearTable()"><i class="fas fa-ban me-2"></i>Force Clear Table</button></div>

                <div class="mt-2"><button id="btn-delete-table"
                        class="btn btn-outline-secondary w-100 btn-sm border-0 bg-light text-muted fw-bold py-2"
                        onclick="confirmDeleteTable()" style="display: none;"><i class="fas fa-trash me-2"></i>Delete
                        Table</button></div>
            </div>

        </div>
    </div>

    <div class="generic-modal-overlay" id="transfer-table-modal">
        <div class="modal-card">
            <div class="modal-header-custom">
                <h6 class="m-0 fw-bold">Transfer Table</h6>
                <button class="modal-close-btn" onclick="closeModal('transfer-table-modal')">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="modal-body-custom">
                <div class="mb-3">
                    <label class="form-label small">From Table</label>
                    <input type="text" class="form-control" id="transfer-from-name" readonly>
                    <input type="hidden" id="transfer-from-id">
                </div>
                <div class="mb-3">
                    <label class="form-label small">To Table (Free Only)</label>
                    <select class="form-select" id="transfer-to-table"></select>
                </div>
                <button class="btn btn-success w-100 fw-bold" onclick="confirmTransferTable()">
                    <i class="fas fa-exchange-alt me-2"></i>Confirm Transfer
                </button>
            </div>
        </div>
    </div>

    <div class="generic-modal-overlay" id="add-expense-modal">
        <div class="modal-card">
            <div class="modal-header-custom">
                <h6 class="m-0 fw-bold">New Expense</h6><button class="modal-close-btn"
                    onclick="closeModal('add-expense-modal')"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body-custom">
                <div class="mb-3"><label class="form-label small">Description</label><input type="text"
                        class="form-control" id="expense-desc"></div>
                <div class="mb-3"><label class="form-label small">Category</label><select class="form-select"
                        id="expense-cat">
                        <option>Ingredients</option>
                        <option>Utilities</option>
                        <option>Supplies</option>
                        <option>Other</option>
                    </select></div>
                <div class="mb-3"><label class="form-label small">Amount</label><input type="number"
                        class="form-control" id="expense-amount" step="0.01"></div>
                <button class="btn btn-primary w-100" onclick="saveExpense()">Save Expense</button>
            </div>
        </div>
    </div>

    <div class="generic-modal-overlay" id="add-item-modal">
        <div class="modal-card">
            <div class="modal-header-custom">
                <h6 class="m-0 fw-bold">Add Menu Item</h6><button class="modal-close-btn"
                    onclick="closeModal('add-item-modal')"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body-custom">
                <div class="row g-2 mb-3">
                    <div class="col-8"><label class="small">Name</label><input type="text" class="form-control"
                            id="item-name"></div>
                    <div class="col-4"><label class="small">Price</label><input type="number" class="form-control"
                            id="item-price" step="0.01"></div>
                </div>
                <div class="mb-3"><label class="small">Category</label><select class="form-select"
                        id="item-category"></select></div>
                <div class="mb-3"><label class="small text-primary fw-bold">Link to Inventory Item (Optional)</label>
                    <input type="text" class="form-control form-control-sm mb-1" id="search-inventory-add"
                        placeholder="Type to search..." onkeyup="filterInventoryDocs('add')">
                    <select class="form-select border-primary-subtle" id="item-link-inventory">
                        <option value="">No Link (Manual Recipe)</option>
                    </select>
                    <div class="form-text x-small">Automatically creates a 1:1 recipe for stock deduction.</div>
                </div>
                <div class="mb-3">
                    <label class="small">Product Image</label>
                    <div class="d-flex align-items-center gap-3">
                        <input type="file" class="form-control form-control-sm" id="item-image" accept="image/*"
                            onchange="previewImage(this, 'add-item-preview')">
                        <img id="add-item-preview" src="https://placehold.co/40" class="rounded border" width="40"
                            height="40" style="object-fit: cover;">
                    </div>
                </div>
                <button class="btn btn-primary w-100" onclick="saveMenuItem()">Create Item</button>
            </div>
        </div>
    </div>

    <div class="generic-modal-overlay" id="add-stock-modal">
        <div class="modal-card">
            <div class="modal-header-custom">
                <h6 class="m-0 fw-bold">Stock In</h6><button class="modal-close-btn"
                    onclick="closeModal('add-stock-modal')"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body-custom">
                <!-- Mode Toggle -->
                <div class="d-flex justify-content-center mb-4">
                    <div class="btn-group w-100" role="group">
                        <input type="radio" class="btn-check" name="stock-mode" id="mode-add" value="add" checked
                            onchange="toggleStockMode('add')">
                        <label class="btn btn-outline-primary" for="mode-add">Add Stock</label>

                        <input type="radio" class="btn-check" name="stock-mode" id="mode-create" value="create"
                            onchange="toggleStockMode('create')">
                        <label class="btn btn-outline-primary" for="mode-create">Create New Item</label>
                    </div>
                </div>

                <!-- MODE A: Add Stock -->
                <div id="container-mode-add">
                    <div class="mb-3"><label class="form-label small">Select Item</label><select class="form-select"
                            id="stock-item"></select></div>
                    <div class="mb-3"><label class="small">Quantity to Add</label><input type="number"
                            class="form-control" id="stock-qty" step="0.01"></div>
                </div>

                <!-- MODE B: Create New Item -->
                <div id="container-mode-create" style="display: none;">
                    <div class="row g-2 mb-3">
                        <div class="col-8"><label class="small">Item Name</label><input type="text" class="form-control"
                                id="new-item-name"></div>
                        <div class="col-4"><label class="small">SKU (Auto)</label><input type="text"
                                class="form-control" id="new-item-sku" placeholder="Auto-generated" readonly></div>
                    </div>
                    <div class="mb-3">
                        <label class="small">Supplier</label><select class="form-select"
                            id="new-item-supplier"></select>
                    </div>
                    <div class="row g-2 mb-3">
                        <div class="col-4"><label class="small">Cost/Unit</label><input type="number"
                                class="form-control" id="new-item-cost" step="0.01"></div>
                        <div class="col-4"><label class="small">Min Qty</label><input type="number" class="form-control"
                                id="new-item-min" value="5"></div>
                        <div class="col-4"><label class="small">Unit</label><input type="text" class="form-control"
                                id="new-item-unit" value="Pcs"></div>
                    </div>
                </div>

                <div class="mt-4">
                    <button class="btn btn-primary w-100 py-2 fw-bold" id="btn-save-stock"
                        onclick="saveStockOrItem()">Update Stock</button>
                </div>
            </div>
        </div>
    </div>

    <div class="generic-modal-overlay" id="add-staff-modal">
        <div class="modal-card">
            <div class="modal-header-custom">
                <h6 class="m-0 fw-bold">Add Staff</h6><button class="modal-close-btn"
                    onclick="closeModal('add-staff-modal')"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body-custom">
                <input type="text" class="form-control mb-2" placeholder="Full Name" id="staff-name">
                <select class="form-select mb-2" id="staff-role">
                    <option value="waiter">Waiter</option>
                    <option value="chef">Chef</option>
                    <option value="manager">Manager</option>
                </select>
                <button class="btn btn-primary w-100" onclick="saveStaff()">Register</button>
            </div>
        </div>
    </div>

    <!-- Void / Return Modal -->
    <div class="generic-modal-overlay" id="void-modal">
        <div class="modal-card" style="max-width: 600px;">
            <div class="modal-header-custom">
                <h6 class="m-0 fw-bold text-danger"><i class="fas fa-undo-alt me-2"></i>Return / Void Order</h6>
                <button class="modal-close-btn" onclick="closeModal('void-modal')"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body-custom">
                <input type="hidden" id="void-order-id">

                <div class="alert alert-warning small mb-3">
                    <i class="fas fa-info-circle me-1"></i>
                    Select items to return. Unreturned items will remain in the order.
                </div>

                <!-- Items Table -->
                <div class="table-responsive mb-3"
                    style="max-height: 300px; border: 1px solid var(--border); border-radius: 8px;">
                    <table class="table table-sm table-hover mb-0" style="font-size: 0.9rem;">
                        <thead class="table-light sticky-top">
                            <tr>
                                <th style="width: 40%;">Item</th>
                                <th class="text-center" style="width: 15%;">Sold</th>
                                <th class="text-center" style="width: 20%;">Return</th>
                                <th class="text-end" style="width: 25%;">Refund</th>
                            </tr>
                        </thead>
                        <tbody id="void-items-list">
                            <!-- Populated by JS -->
                        </tbody>
                    </table>
                </div>

                <div class="d-flex justify-content-between align-items-center mb-3 p-3 bg-light rounded">
                    <span class="fw-bold">Total Refund:</span>
                    <span class="fw-bold text-danger fs-5" id="void-total-refund">$0.00</span>
                </div>

                <div class="mb-3">
                    <label class="form-label small fw-bold">Reason / Notes</label>
                    <textarea class="form-control" id="void-reason" rows="2"
                        placeholder="Reason for return..."></textarea>
                </div>

                <div class="form-check form-switch mb-4">
                    <input class="form-check-input" type="checkbox" id="void-return-stock" checked>
                    <label class="form-check-label small" for="void-return-stock">Return items to inventory</label>
                </div>

                <div class="d-grid">
                    <button class="btn btn-danger btn-lg fw-bold" onclick="processVoidReturn()">
                        <i class="fas fa-check-circle me-2"></i>Confirm Return
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Supplier Modal -->
    <div class="generic-modal-overlay" id="add-supplier-modal">
        <div class="modal-card">
            <div class="modal-header-custom">
                <h6 class="m-0 fw-bold">Add Supplier</h6>
                <button class="modal-close-btn" onclick="closeModal('add-supplier-modal')"><i
                        class="fas fa-times"></i></button>
            </div>
            <div class="modal-body-custom">
                <div class="mb-3"><label class="form-label small">Company Name</label><input type="text"
                        class="form-control" id="supplier-name"></div>
                <div class="mb-3"><label class="form-label small">Contact Person / Phone</label><input type="text"
                        class="form-control" id="supplier-contact"></div>
                <div class="mb-3"><label class="form-label small">Email</label><input type="email" class="form-control"
                        id="supplier-email"></div>
                <div class="mb-3"><label class="form-label small">Address</label><textarea class="form-control"
                        id="supplier-address" rows="2"></textarea></div>
                <button class="btn btn-primary w-100" onclick="saveSupplier()">Save Supplier</button>
            </div>
        </div>
    </div>

    <!-- Add Table Modal -->
    <div class="generic-modal-overlay" id="add-table-modal">
        <div class="modal-card">
            <div class="modal-header-custom">
                <h6 class="m-0 fw-bold">Add Table</h6>
                <button class="modal-close-btn" onclick="closeModal('add-table-modal')"><i
                        class="fas fa-times"></i></button>
            </div>
            <div class="modal-body-custom">
                <div class="mb-3"><label class="form-label small">Table Name</label><input type="text"
                        class="form-control" id="table-name" placeholder="e.g. Table 1, VIP Room"></div>
                <div class="mb-3"><label class="form-label small">Number of Seats</label><input type="number"
                        class="form-control" id="table-seats" value="4"></div>
                <button class="btn btn-primary w-100" onclick="saveTable()">Add Table</button>
            </div>
        </div>
    </div>

    <!-- Table Transfer Modal -->
    <div class="generic-modal-overlay" id="transfer-table-modal">
        <div class="modal-card">
            <div class="modal-header-custom">
                <h6 class="m-0 fw-bold"><i class="fas fa-exchange-alt text-primary me-2"></i>Transfer Table</h6>
                <button class="modal-close-btn" onclick="closeModal('transfer-table-modal')"><i
                        class="fas fa-times"></i></button>
            </div>
            <div class="modal-body-custom">
                <input type="hidden" id="transfer-from-id">
                <div class="mb-3">
                    <label class="form-label small">From Table</label>
                    <input type="text" class="form-control" id="transfer-from-name" readonly>
                </div>
                <div class="mb-3">
                    <label class="form-label small">To Table</label>
                    <select class="form-select" id="transfer-to-table"></select>
                </div>
                <button class="btn btn-primary w-100" onclick="confirmTransferTable()"><i
                        class="fas fa-exchange-alt me-2"></i>Transfer Order</button>
            </div>
        </div>
    </div>

    <!-- Z-Report Modal -->
    <div class="generic-modal-overlay" id="z-report-modal">
        <div class="modal-card" style="max-width: 500px;">
            <div class="modal-header-custom">
                <h6 class="m-0 fw-bold"><i class="fas fa-file-invoice-dollar text-success me-2"></i>Business Day Summary
                </h6>
                <button class="modal-close-btn" onclick="closeModal('z-report-modal')"><i
                        class="fas fa-times"></i></button>
            </div>
            <div class="modal-body-custom">
                <div class="alert alert-info small mb-3">
                    <i class="fas fa-info-circle me-1"></i> Summary of the current business day.
                </div>
                <div class="row g-2 mb-3">
                    <div class="col-6">
                        <div class="bg-light rounded p-3 text-center">
                            <div class="text-muted small">Total Sales</div>
                            <div class="h4 fw-bold text-primary mb-0" id="zr-total-sales">$0.00</div>
                        </div>
                    </div>
                    <div class="col-6">
                        <div class="bg-light rounded p-3 text-center">
                            <div class="text-muted small">Orders</div>
                            <div class="h4 fw-bold mb-0" id="zr-order-count">0</div>
                        </div>
                    </div>
                </div>
                <div class="row g-2 mb-3">
                    <div class="col-6">
                        <div class="bg-light rounded p-3 text-center">
                            <div class="text-muted small">Voids</div>
                            <div class="h4 fw-bold text-danger mb-0" id="zr-voids">0</div>
                        </div>
                    </div>
                    <div class="col-6">
                        <div class="bg-light rounded p-3 text-center">
                            <div class="text-muted small">Expected Cash</div>
                            <div class="h4 fw-bold text-success mb-0" id="zr-expected-cash">$0.00</div>
                        </div>
                    </div>
                </div>
                <div class="mb-3">
                    <label class="form-label small fw-bold">Actual Cash in Drawer</label>
                    <input type="number" class="form-control" id="zr-actual-cash" step="0.01"
                        placeholder="Count your cash...">
                </div>
                <div class="mb-3">
                    <label class="form-label small">Notes (optional)</label>
                    <textarea class="form-control" id="zr-notes" rows="2"
                        placeholder="Any discrepancies or notes..."></textarea>
                </div>
                <div class="d-flex gap-2">
                    <button class="btn btn-outline-primary flex-fill" onclick="printZReport()"><i
                            class="fas fa-print me-2"></i>Print Report</button>
                    <!-- Close Shift Button Removed -->
                </div>
            </div>
        </div>
    </div>

    <!-- Add Category Modal -->
    <div class="generic-modal-overlay" id="add-category-modal">
        <div class="modal-card">
            <div class="modal-header-custom">
                <h6 class="m-0 fw-bold">Add New Category</h6>
                <button class="modal-close-btn" onclick="closeModal('add-category-modal')"><i
                        class="fas fa-times"></i></button>
            </div>
            <div class="modal-body-custom">
                <div class="mb-3">
                    <label class="form-label small">Category Name</label>
                    <input type="text" class="form-control" id="cat-name" placeholder="e.g. Beverages">
                </div>
                <button class="btn btn-primary w-100" onclick="saveCategory()">Create Category</button>
            </div>
        </div>
    </div>

    <!-- Edit Category Modal -->
    <div class="generic-modal-overlay" id="edit-category-modal">
        <div class="modal-card">
            <div class="modal-header-custom">
                <h6 class="m-0 fw-bold">Edit Category</h6>
                <button class="modal-close-btn" onclick="closeModal('edit-category-modal')"><i
                        class="fas fa-times"></i></button>
            </div>
            <div class="modal-body-custom">
                <input type="hidden" id="cat-edit-id">
                <div class="mb-3">
                    <label class="form-label small">Category Name</label>
                    <input type="text" class="form-control" id="cat-edit-name">
                </div>
                <button class="btn btn-primary w-100" onclick="saveCategoryEdit()">Update Category</button>
            </div>
        </div>
    </div>

    <!-- Edit Product Modal -->
    <div class="generic-modal-overlay" id="edit-product-modal">
        <div class="modal-card">
            <div class="modal-header-custom">
                <h6 class="m-0 fw-bold">Edit Product</h6>
                <button class="modal-close-btn" onclick="closeModal('edit-product-modal')"><i
                        class="fas fa-times"></i></button>
            </div>
            <div class="modal-body-custom">
                <input type="hidden" id="edit-item-id">
                <div class="row g-2 mb-3">
                    <div class="col-8"><label class="small">Name</label><input type="text" class="form-control"
                            id="edit-item-name"></div>
                    <div class="col-4"><label class="small">Price</label><input type="number" class="form-control"
                            id="edit-item-price" step="0.01"></div>
                </div>
                <div class="mb-3"><label class="small">Category</label><select class="form-select"
                        id="edit-item-category"></select></div>
                <div class="mb-3"><label class="small text-primary fw-bold">Link to Inventory Item (Optional)</label>
                    <input type="text" class="form-control form-control-sm mb-1" id="search-inventory-edit"
                        placeholder="Type to search..." onkeyup="filterInventoryDocs('edit')">
                    <select class="form-select border-primary-subtle" id="edit-item-link-inventory">
                        <option value="">No Link (Manual Recipe)</option>
                    </select>
                    <div class="form-text x-small">Updates the 1:1 recipe. Clears existing recipes if changed.</div>
                </div>
                <div class="mb-3">
                    <label class="small">Product Image</label>
                    <div class="d-flex align-items-center gap-3">
                        <input type="file" class="form-control form-control-sm" id="edit-item-image" accept="image/*"
                            onchange="previewImage(this, 'edit-item-preview')">
                        <img id="edit-item-preview" src="" class="rounded border" width="40" height="40"
                            style="object-fit: cover;">
                    </div>
                </div>
                <button class="btn btn-primary w-100" onclick="saveProductEdit()">Update Item</button>
            </div>
        </div>
    </div>

    <!-- Edit Staff Modal -->
    <div class="generic-modal-overlay" id="edit-staff-modal">
        <div class="modal-card">
            <div class="modal-header-custom">
                <h6 class="m-0 fw-bold">Edit Staff</h6>
                <button class="modal-close-btn" onclick="closeModal('edit-staff-modal')"><i
                        class="fas fa-times"></i></button>
            </div>
            <div class="modal-body-custom">
                <input type="hidden" id="edit-staff-id">
                <div class="mb-3"><label class="small">Full Name</label><input type="text" class="form-control"
                        id="edit-staff-name"></div>
                <div class="mb-3"><label class="small">Role</label>
                    <select class="form-select" id="edit-staff-role">
                        <option value="waiter">Waiter</option>
                        <option value="chef">Chef</option>
                        <option value="manager">Manager</option>
                    </select>
                </div>
                <button class="btn btn-primary w-100" onclick="saveStaffEdit()">Update Staff</button>
            </div>
        </div>
    </div>

    <!-- Edit Expense Modal -->
    <div class="generic-modal-overlay" id="edit-expense-modal">
        <div class="modal-card">
            <div class="modal-header-custom">
                <h6 class="m-0 fw-bold">Edit Expense</h6>
                <button class="modal-close-btn" onclick="closeModal('edit-expense-modal')"><i
                        class="fas fa-times"></i></button>
            </div>
            <div class="modal-body-custom">
                <input type="hidden" id="edit-expense-id">
                <div class="mb-3"><label class="form-label small">Description</label><input type="text"
                        class="form-control" id="edit-expense-desc"></div>
                <div class="mb-3"><label class="form-label small">Category</label>
                    <select class="form-select" id="edit-expense-cat">
                        <option>Ingredients</option>
                        <option>Utilities</option>
                        <option>Supplies</option>
                        <option>Other</option>
                    </select>
                </div>
                <div class="mb-3"><label class="form-label small">Amount</label><input type="number"
                        class="form-control" id="edit-expense-amount" step="0.01"></div>
                <button class="btn btn-primary w-100" onclick="saveExpenseEdit()">Update Expense</button>
            </div>
        </div>
    </div>

    <!-- Edit Inventory Modal -->
    <div class="generic-modal-overlay" id="edit-inventory-modal">
        <div class="modal-card">
            <div class="modal-header-custom">
                <h6 class="m-0 fw-bold">Edit Inventory Item</h6>
                <button class="modal-close-btn" onclick="closeModal('edit-inventory-modal')"><i
                        class="fas fa-times"></i></button>
            </div>
            <div class="modal-body-custom">
                <input type="hidden" id="edit-inv-id">
                <div class="mb-3"><label class="form-label small">Item Name</label><input type="text"
                        class="form-control" id="edit-inv-name"></div>
                <div class="mb-3"><label class="form-label small">SKU</label><input type="text" class="form-control"
                        id="edit-inv-sku"></div>
                <div class="mb-3"><label class="form-label small">Min. Quantity (Alert)</label><input type="number"
                        class="form-control" id="edit-inv-min"></div>
                <div class="mb-3"><label class="form-label small">Cost Price (Per Unit)</label><input type="number"
                        class="form-control" id="edit-inv-cost" step="0.01"></div>
                <div class="mb-3"><label class="form-label small">Supplier</label><select class="form-select"
                        id="edit-inv-supplier"></select></div>
                <button class="btn btn-primary w-100" onclick="saveInventoryEdit()">Update Item</button>
            </div>
        </div>
    </div>

    <!-- Edit Supplier Modal -->
    <div class="generic-modal-overlay" id="edit-supplier-modal">
        <div class="modal-card">
            <div class="modal-header-custom">
                <h6 class="m-0 fw-bold">Edit Supplier</h6>
                <button class="modal-close-btn" onclick="closeModal('edit-supplier-modal')"><i
                        class="fas fa-times"></i></button>
            </div>
            <div class="modal-body-custom">
                <input type="hidden" id="edit-sup-id">
                <div class="mb-3"><label class="form-label small">Company Name</label><input type="text"
                        class="form-control" id="edit-sup-name"></div>
                <div class="mb-3"><label class="form-label small">Contact Person / Phone</label><input type="text"
                        class="form-control" id="edit-sup-contact"></div>
                <div class="mb-3"><label class="form-label small">Email</label><input type="email" class="form-control"
                        id="edit-sup-email"></div>
                <div class="mb-3"><label class="form-label small">Address</label><textarea class="form-control"
                        id="edit-sup-address" rows="2"></textarea></div>
                <button class="btn btn-primary w-100" onclick="saveSupplierEdit()">Update Supplier</button>
            </div>
        </div>
    </div>

    <!-- Custom Confirmation Modal -->
    <div class="modal fade" id="custom-confirm-modal" tabindex="-1" aria-hidden="true" style="z-index: 1060;">
        <div class="modal-dialog modal-dialog-centered modal-sm">
            <div class="modal-content border-0 shadow-lg rounded-4 overflow-hidden">
                <div class="modal-body p-4 text-center">
                    <div class="mb-3">
                        <i class="fas fa-exclamation-circle text-warning fa-3x"></i>
                    </div>
                    <h5 class="fw-bold mb-2" id="confirm-title">Are you sure?</h5>
                    <p class="text-muted small mb-4" id="confirm-message">This action cannot be undone.</p>
                    <div class="d-grid gap-2">
                        <button type="button" class="btn btn-danger rounded-pill fw-bold" id="confirm-yes-btn">Yes,
                            Delete It</button>
                        <button type="button" class="btn btn-light rounded-pill fw-bold"
                            data-bs-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Open Shift Modal - REMOVED -->

    <!-- Close Shift Modal - REMOVED -->

    <!-- Offline Status Banner -->
    <div id="offline-banner" class="hidden"
        style="position: fixed; top: 0; left: 0; right: 0; background: linear-gradient(135deg, #ff6b6b 0%, #ee5a6f 100%); color: white; padding: 12px 20px; text-align: center; z-index: 9999; box-shadow: 0 4px 12px rgba(0,0,0,0.15); font-weight: 600; display: none;">
        <i class="fas fa-wifi-slash me-2"></i>
        <span>You're offline - Changes will sync automatically when online</span>
        <button id="retry-sync" onclick="SyncManager.manualSync()"
            style="background: rgba(255,255,255,0.2); border: 1px solid rgba(255,255,255,0.3); color: white; padding: 4px 12px; border-radius: 6px; margin-left: 15px; cursor: pointer; font-size: 13px; font-weight: 600;">
            <i class="fas fa-sync me-1"></i> Retry Now
        </button>
    </div>

    <!-- Network Status Indicator -->
    <div id="network-status-indicator" class="network-status online"
        style="position: fixed; bottom: 20px; right: 20px; width: 50px; height: 50px; border-radius: 50%; background: #10b981; color: white; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 12px rgba(0,0,0,0.15); z-index: 1050; cursor: pointer; transition: all 0.3s ease;"
        title="Online">
        <i class="fas fa-wifi"></i>
    </div>

    <!-- Sync Progress Indicator -->
    <div id="sync-progress" class="hidden"
        style="position: fixed; bottom: 80px; right: 20px; background: white; padding: 12px 20px; border-radius: 12px; box-shadow: 0 4px 16px rgba(0,0,0,0.15); z-index: 1050; display: none; align-items: center; gap: 10px;">
        <i class="fas fa-sync fa-spin text-primary"></i>
        <span class="fw-600" style="font-size: 14px;">Syncing... <span id="sync-count">0/0</span></span>
    </div>

    <!-- Offline Sync Button (shows when pending changes exist) -->
    <button id="offline-sync-btn" onclick="SyncManager.manualSync()"
        style="position: fixed; bottom: 140px; right: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none; padding: 14px 24px; border-radius: 12px; box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4); z-index: 1050; display: none; cursor: pointer; font-weight: 600; align-items: center; gap: 8px;">
        <i class="fas fa-cloud-upload-alt"></i>
        <span>Sync Pending Changes</span>
        <span id="sync-badge" class="badge bg-white text-primary ms-2" style="display: none;">0</span>
    </button>

    <div class="toast-container" id="toast-container"></div>

    <script>
        if ('serviceWorker' in navigator) {
            window.addEventListener('load', () => {
                navigator.serviceWorker.register('sw.js').catch(err => console.log('SW failed', err));
            });

            // Auto-reload on service worker updates
            navigator.serviceWorker.addEventListener('controllerchange', () => {
                window.location.reload();
            });
        }
    </script>

    <script>
        const currentUserRole = "<?php echo $currentRole; ?>";
        const currentUserId = <?php echo $_SESSION['user_id']; ?>;
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Offline-First PWA Components -->
    <script src="db-manager.js"></script>
    <script src="network-manager.js"></script>
    <script src="sync-manager.js"></script>
    <script src="offline.js"></script>

    <script src="printer.js"></script>
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>

    <script src="app.js?v=<?= $appVersion ?>"></script>

    <script>
        // Toggle Menu Management Buttons
        function toggleMenuButtons(tab) {
            const btnAddItem = document.getElementById('btn-add-item');
            const btnAddCategory = document.getElementById('btn-add-category');

            if (tab === 'products') {
                if (btnAddItem) btnAddItem.style.display = 'inline-block';
                if (btnAddCategory) btnAddCategory.style.display = 'none';
            } else {
                if (btnAddItem) btnAddItem.style.display = 'none';
                if (btnAddCategory) btnAddCategory.style.display = 'inline-block';
            }
        }
    </script>

    <!-- Start/Close/No Shift Modals Removed -->

</body>

</html>