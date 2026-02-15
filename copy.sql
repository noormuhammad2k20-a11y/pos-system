-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3307
-- Generation Time: Feb 08, 2026 at 01:10 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `gustopos_production_1`
--

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `entity` varchar(50) DEFAULT NULL,
  `entity_id` int(11) DEFAULT NULL,
  `details` text DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `audit_logs`
--

INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES
(1, 1, 'OPEN_SHIFT', 'shifts', 1, 'Shift opened with start cash: 0', NULL, '2026-02-07 23:31:49'),
(2, 1, 'CLOSE_SHIFT', 'shifts', 1, 'Shift closed. Actual: 200, Expected: 75.9', NULL, '2026-02-07 23:33:08'),
(3, 1, 'OPEN_SHIFT', 'shifts', 2, 'Shift opened with start cash: 0', NULL, '2026-02-07 23:57:52');

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `sort_order` int(11) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`, `sort_order`, `is_active`, `created_at`) VALUES
(1, 'Burgers', 1, 1, '2026-02-07 23:31:15'),
(2, 'Pizzas', 2, 1, '2026-02-07 23:31:15'),
(3, 'Drinks', 3, 1, '2026-02-07 23:31:15'),
(4, 'Desserts', 4, 1, '2026-02-07 23:31:15'),
(5, 'Sides', 5, 1, '2026-02-07 23:31:15');

-- --------------------------------------------------------

--
-- Table structure for table `expenses`
--

CREATE TABLE `expenses` (
  `id` int(11) NOT NULL,
  `shift_id` int(11) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT 0.00,
  `status` enum('pending','approved') DEFAULT 'approved',
  `added_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `expenses`
--

INSERT INTO `expenses` (`id`, `description`, `category`, `amount`, `status`, `created_at`) VALUES
(1, 'Laborum nihil pariat', 'Other', 930.00, 'approved', '2026-02-07 23:32:00');

-- --------------------------------------------------------

--
-- Table structure for table `inventory`
--

CREATE TABLE `inventory` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `sku` varchar(100) DEFAULT NULL,
  `purchase_unit` varchar(50) DEFAULT 'Pcs',
  `consumption_unit` varchar(50) DEFAULT 'Pcs',
  `conversion_factor` decimal(10,3) DEFAULT 1.000,
  `quantity` decimal(10,3) DEFAULT 0.000,
  `min_quantity` decimal(10,3) DEFAULT 5.000,
  `cost_per_unit` decimal(10,2) DEFAULT 0.00,
  `supplier_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `inventory`
--

INSERT INTO `inventory` (`id`, `name`, `sku`, `purchase_unit`, `consumption_unit`, `conversion_factor`, `quantity`, `min_quantity`, `cost_per_unit`, `supplier_id`, `created_at`, `updated_at`) VALUES
(1, 'Burger Bun', 'ING-001', 'Pack', 'Pcs', 1.000, 97.000, 20.000, 0.50, NULL, '2026-02-07 23:31:15', '2026-02-07 23:32:12'),
(2, 'Beef Patty', 'ING-002', 'Box', 'Pcs', 1.000, 47.000, 10.000, 2.00, NULL, '2026-02-07 23:31:15', '2026-02-07 23:32:12'),
(3, 'Cheddar Cheese', 'ING-003', 'Block', 'Slice', 20.000, 198.000, 40.000, 0.20, NULL, '2026-02-07 23:31:15', '2026-02-07 23:32:12'),
(4, 'Coca Cola Can', 'DRK-001', 'Case', 'Can', 1.000, 47.000, 12.000, 1.00, NULL, '2026-02-07 23:31:15', '2026-02-07 23:32:12'),
(5, 'Coffee Beans', 'DRK-002', 'Kg', 'Shot', 50.000, 500.000, 50.000, 0.10, NULL, '2026-02-07 23:31:15', '2026-02-07 23:31:15');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` int(11) NOT NULL,
  `order_number` varchar(20) NOT NULL,
  `token_number` int(11) DEFAULT 0,
  `shift_id` int(11) DEFAULT NULL,
  `table_id` int(11) DEFAULT NULL,
  `waiter_id` int(11) DEFAULT NULL,
  `customer_name` varchar(255) DEFAULT 'Walk-in',
  `order_type` enum('dine_in','takeaway','delivery') DEFAULT 'dine_in',
  `payment_method` enum('cash','card','other') DEFAULT 'cash',
  `subtotal` decimal(10,2) DEFAULT 0.00,
  `tax` decimal(10,2) DEFAULT 0.00,
  `service_charge` decimal(10,2) DEFAULT 0.00,
  `packaging_charge` decimal(10,2) DEFAULT 0.00,
  `delivery_fee` decimal(10,2) DEFAULT 0.00,
  `discount` decimal(10,2) DEFAULT 0.00,
  `total` decimal(10,2) DEFAULT 0.00,
  `status` enum('pending','held','completed','deleted') DEFAULT 'pending',
  `is_bill_printed` tinyint(1) DEFAULT 0,
  `void_type` enum('waste','return') DEFAULT NULL,
  `deleted_by` varchar(100) DEFAULT NULL,
  `delete_reason` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `completed_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `order_number`, `token_number`, `shift_id`, `table_id`, `customer_name`, `order_type`, `payment_method`, `subtotal`, `tax`, `service_charge`, `packaging_charge`, `delivery_fee`, `discount`, `total`, `status`, `is_bill_printed`, `void_type`, `deleted_by`, `delete_reason`, `created_at`, `completed_at`) VALUES
(1, 'INV-1001', 0, 1, NULL, 'Walk-in', '', 'cash', 69.00, 6.90, 0.00, 1.00, 3.00, 0.00, 75.90, 'completed', 0, NULL, NULL, NULL, '2026-02-07 23:32:12', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `quantity` int(11) DEFAULT 1,
  `price` decimal(10,2) DEFAULT 0.00,
  `notes` varchar(255) DEFAULT NULL,
  `is_kot_printed` tinyint(1) DEFAULT 0,
  `kot_time` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `product_id`, `product_name`, `quantity`, `price`, `notes`, `is_kot_printed`, `kot_time`) VALUES
(1, 1, 2, 'Cheese Burger', 2, 14.00, '', 0, NULL),
(2, 1, 8, 'Chocolate Cake', 1, 6.00, '', 0, NULL),
(3, 1, 1, 'Classic Beef Burger', 1, 12.00, '', 0, NULL),
(4, 1, 6, 'Coca Cola', 1, 3.00, '', 0, NULL),
(5, 1, 3, 'Double Bacon', 1, 16.00, '', 0, NULL),
(6, 1, 9, 'French Fries', 1, 4.00, '', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `price` decimal(10,2) NOT NULL DEFAULT 0.00,
  `cost_price` decimal(10,2) DEFAULT 0.00,
  `category_id` int(11) DEFAULT NULL,
  `image` varchar(500) DEFAULT 'https://placehold.co/150x100/png?text=Item',
  `barcode` varchar(100) DEFAULT NULL,
  `is_available` tinyint(1) DEFAULT 1,
  `sort_order` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `name`, `price`, `cost_price`, `category_id`, `image`, `barcode`, `is_available`, `sort_order`, `created_at`, `updated_at`) VALUES
(1, 'Classic Beef Burger', 12.00, 0.00, 1, 'https://placehold.co/150x100/E8B067/333?text=Burger', NULL, 1, 0, '2026-02-07 23:31:15', '2026-02-07 23:31:15'),
(2, 'Cheese Burger', 14.00, 0.00, 1, 'https://placehold.co/150x100/F5C77E/333?text=Cheese', NULL, 1, 0, '2026-02-07 23:31:15', '2026-02-07 23:31:15'),
(3, 'Double Bacon', 16.00, 0.00, 1, 'https://placehold.co/150x100/D4956A/333?text=Bacon', NULL, 1, 0, '2026-02-07 23:31:15', '2026-02-07 23:31:15'),
(4, 'Pepperoni Pizza', 18.00, 0.00, 2, 'https://placehold.co/150x100/E85A4F/333?text=Pizza', NULL, 1, 0, '2026-02-07 23:31:15', '2026-02-07 23:31:15'),
(5, 'Margherita', 15.00, 0.00, 2, 'https://placehold.co/150x100/F28B82/333?text=Margherita', NULL, 1, 0, '2026-02-07 23:31:15', '2026-02-07 23:31:15'),
(6, 'Coca Cola', 3.00, 0.00, 3, 'https://placehold.co/150x100/B71C1C/fff?text=Cola', NULL, 1, 0, '2026-02-07 23:31:15', '2026-02-07 23:31:15'),
(7, 'Iced Latte', 4.50, 0.00, 3, 'https://placehold.co/150x100/795548/fff?text=Latte', NULL, 1, 0, '2026-02-07 23:31:15', '2026-02-07 23:31:15'),
(8, 'Chocolate Cake', 6.00, 0.00, 4, 'https://placehold.co/150x100/5D4037/fff?text=Cake', NULL, 1, 0, '2026-02-07 23:31:15', '2026-02-07 23:31:15'),
(9, 'French Fries', 4.00, 0.00, 5, 'https://placehold.co/150x100/FFC107/333?text=Fries', NULL, 1, 0, '2026-02-07 23:31:15', '2026-02-07 23:31:15');

-- --------------------------------------------------------

--
-- Table structure for table `recipes`
--

CREATE TABLE `recipes` (
  `id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `inventory_id` int(11) NOT NULL,
  `qty_required` decimal(10,3) NOT NULL DEFAULT 0.000
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `recipes`
--

INSERT INTO `recipes` (`id`, `product_id`, `inventory_id`, `qty_required`) VALUES
(1, 1, 1, 1.000),
(2, 1, 2, 1.000),
(3, 2, 1, 1.000),
(4, 2, 2, 1.000),
(5, 2, 3, 1.000),
(6, 6, 4, 1.000),
(7, 7, 5, 2.000);

-- --------------------------------------------------------

--
-- Table structure for table `restaurant_tables`
--

CREATE TABLE `restaurant_tables` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `seats` int(11) DEFAULT 4,
  `status` enum('free','busy','needs_payment') DEFAULT 'free',
  `waiter_id` int(11) DEFAULT NULL,
  `occupied_since` datetime DEFAULT NULL,
  `current_order_id` int(11) DEFAULT NULL,
  `locked_by` int(11) DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `position_x` int(11) DEFAULT 0,
  `position_y` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `restaurant_tables`
--

INSERT INTO `restaurant_tables` (`id`, `name`, `seats`, `status`, `waiter_id`, `occupied_since`, `current_order_id`, `locked_by`, `locked_at`, `position_x`, `position_y`) VALUES
(1, 'T-01', 4, 'free', NULL, NULL, NULL, NULL, NULL, 0, 0),
(2, 'T-02', 4, 'free', NULL, NULL, NULL, NULL, NULL, 0, 0),
(3, 'T-03', 2, 'free', NULL, NULL, NULL, NULL, NULL, 0, 0),
(4, 'T-04', 6, 'free', NULL, NULL, NULL, NULL, NULL, 0, 0),
(5, 'T-05', 4, 'free', NULL, NULL, NULL, NULL, NULL, 0, 0),
(6, 'T-06', 8, 'free', NULL, NULL, NULL, NULL, NULL, 0, 0),
(7, 'T-07', 2, 'free', NULL, NULL, NULL, NULL, NULL, 0, 0),
(8, 'T-08', 4, 'free', NULL, NULL, NULL, NULL, NULL, 0, 0),
(9, 'T-09', 4, 'free', NULL, NULL, NULL, NULL, NULL, 0, 0),
(10, 'T-10', 6, 'free', NULL, NULL, NULL, NULL, NULL, 0, 0),
(11, 'T-11', 4, 'free', NULL, NULL, NULL, NULL, NULL, 0, 0),
(12, 'T-12', 8, 'free', NULL, NULL, NULL, NULL, NULL, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `id` int(11) NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `setting_type` enum('text','number','boolean','json') DEFAULT 'text',
  `category` varchar(50) DEFAULT 'general'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`id`, `setting_key`, `setting_value`, `setting_type`, `category`) VALUES
(1, 'restaurant_name', 'GustoPOS Restaurant', 'text', 'general'),
(2, 'restaurant_address', '123 Food Street, City', 'text', 'general'),
(3, 'restaurant_phone', '+1 234 567 890', 'text', 'general'),
(4, 'restaurant_logo', '', 'text', 'general'),
(5, 'tax_rate', '10', 'number', 'general'),
(6, 'tax_name', 'VAT', 'text', 'general'),
(7, 'service_charge_rate', '0', 'number', 'general'),
(8, 'packaging_fee', '1.00', 'number', 'general'),
(9, 'delivery_fee', '3.00', 'number', 'general'),
(10, 'currency_symbol', 'PKR', 'text', 'general'),
(11, 'cashier_access_pos', 'true', 'boolean', 'permissions'),
(12, 'cashier_access_floor', 'true', 'boolean', 'permissions'),
(13, 'cashier_view_reports', 'false', 'boolean', 'permissions'),
(14, 'cashier_export_data', 'false', 'boolean', 'permissions'),
(15, 'cashier_access_settings', 'false', 'boolean', 'permissions'),
(16, 'cashier_void_orders', 'false', 'boolean', 'permissions'),
(17, 'admin_full_access', 'true', 'boolean', 'permissions'),
(18, 'default_order_type', 'walkin', 'text', 'order'),
(19, 'show_order_timer', 'true', 'boolean', 'order'),
(20, 'allow_qty_edit_after_kot', 'true', 'boolean', 'order'),
(21, 'allow_cancel_after_payment', 'false', 'boolean', 'order'),
(22, 'merge_orders_same_table', 'false', 'boolean', 'order'),
(23, 'auto_release_table', 'true', 'boolean', 'tables'),
(24, 'table_color_free', '#12b76a', 'text', 'tables'),
(25, 'table_color_busy', '#f04438', 'text', 'tables'),
(26, 'table_color_reserved', '#f79009', 'text', 'tables'),
(27, 'allow_merge_table', 'false', 'boolean', 'tables'),
(28, 'strict_stock_control', 'false', 'boolean', 'inventory'),
(29, 'show_logo_receipt', 'true', 'boolean', 'receipt'),
(30, 'show_cashier_receipt', 'true', 'boolean', 'receipt'),
(31, 'printer_width', '80', 'number', 'receipt'),
(32, 'receipt_header', 'Welcome to our restaurant!', 'text', 'receipt'),
(33, 'receipt_footer', 'Thank you for visiting!', 'text', 'receipt'),
(34, 'timezone', 'Asia/Karachi', 'text', 'system'),
(35, 'date_format', 'DD/MM/YYYY', 'text', 'system'),
(36, 'store_open_time', '09:00', 'text', 'system'),
(37, 'store_close_time', '22:00', 'text', 'system');

-- --------------------------------------------------------

--
-- Table structure for table `shifts`
--

CREATE TABLE `shifts` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `start_time` datetime NOT NULL DEFAULT current_timestamp(),
  `end_time` datetime DEFAULT NULL,
  `start_cash` decimal(10,2) DEFAULT 0.00,
  `actual_cash` decimal(10,2) DEFAULT 0.00,
  `status` enum('open','closed') DEFAULT 'open',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `shifts`
--

INSERT INTO `shifts` (`id`, `user_id`, `start_time`, `end_time`, `start_cash`, `actual_cash`, `status`, `notes`, `created_at`, `updated_at`) VALUES
(1, 1, '2026-02-08 04:31:49', '2026-02-08 04:33:08', 0.00, 200.00, 'closed', NULL, '2026-02-07 23:31:49', '2026-02-07 23:33:08'),
(2, 1, '2026-02-08 04:57:52', NULL, 0.00, 0.00, 'open', NULL, '2026-02-07 23:57:52', '2026-02-07 23:57:52');

-- --------------------------------------------------------

--
-- Table structure for table `shift_closings`
--

CREATE TABLE `shift_closings` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_name` varchar(100) DEFAULT NULL,
  `shift_start` datetime DEFAULT NULL,
  `shift_end` datetime DEFAULT current_timestamp(),
  `total_sales` decimal(10,2) DEFAULT 0.00,
  `total_cash_sales` decimal(10,2) DEFAULT 0.00,
  `total_card_sales` decimal(10,2) DEFAULT 0.00,
  `total_expenses` decimal(10,2) DEFAULT 0.00,
  `net_profit` decimal(10,2) DEFAULT 0.00,
  `total_orders` int(11) DEFAULT 0,
  `total_voids` int(11) DEFAULT 0,
  `total_void_amount` decimal(10,2) DEFAULT 0.00,
  `total_refunds` decimal(10,2) DEFAULT 0.00,
  `expected_cash` decimal(10,2) DEFAULT 0.00,
  `actual_cash` decimal(10,2) DEFAULT 0.00,
  `difference` decimal(10,2) DEFAULT 0.00,
  `json_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`json_data`)),
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `shift_closings`
--

INSERT INTO `shift_closings` (`id`, `user_id`, `user_name`, `shift_start`, `shift_end`, `total_sales`, `total_cash_sales`, `total_card_sales`, `total_expenses`, `net_profit`, `total_orders`, `total_voids`, `total_void_amount`, `total_refunds`, `expected_cash`, `actual_cash`, `difference`, `json_data`, `notes`, `created_at`) VALUES
(1, 1, 'admin', '2026-02-08 04:31:49', '2026-02-08 04:33:08', 75.90, 75.90, 0.00, 0.00, 75.90, 1, 0, 0.00, 0.00, 75.90, 200.00, 124.10, '{\"start_cash\":0,\"cash_sales\":\"75.90\",\"card_sales\":\"0.00\",\"expenses\":\"0.00\"}', '', '2026-02-07 23:33:08');

-- --------------------------------------------------------

--
-- Table structure for table `staff`
--

CREATE TABLE `staff` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `role` enum('waiter','chef','manager','cashier') DEFAULT 'waiter',
  `pin` varchar(10) DEFAULT NULL,
  `shift_start` datetime DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `staff`
--

INSERT INTO `staff` (`id`, `name`, `role`, `pin`, `shift_start`, `is_active`, `created_at`) VALUES
(1, 'Alice Johnson', 'waiter', NULL, NULL, 1, '2026-02-07 23:31:15'),
(2, 'Mike Smith', 'chef', NULL, NULL, 1, '2026-02-07 23:31:15'),
(3, 'Sarah Davis', 'manager', NULL, NULL, 1, '2026-02-07 23:31:15');

-- --------------------------------------------------------

--
-- Table structure for table `stock_logs`
--

CREATE TABLE `stock_logs` (
  `id` int(11) NOT NULL,
  `inventory_id` int(11) NOT NULL,
  `qty_change` decimal(10,3) DEFAULT 0.000,
  `balance_after` decimal(10,3) DEFAULT 0.000,
  `reason` enum('sale','waste','return','restock','adjustment') DEFAULT 'adjustment',
  `reference_type` varchar(50) DEFAULT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `user_name` varchar(100) DEFAULT 'System',
  `notes` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `stock_logs`
--

INSERT INTO `stock_logs` (`id`, `inventory_id`, `qty_change`, `balance_after`, `reason`, `reference_type`, `reference_id`, `user_name`, `notes`, `created_at`) VALUES
(1, 1, -2.000, 98.000, 'sale', 'order', 1, 'System', NULL, '2026-02-07 23:32:12'),
(2, 2, -2.000, 48.000, 'sale', 'order', 1, 'System', NULL, '2026-02-07 23:32:12'),
(3, 3, -2.000, 198.000, 'sale', 'order', 1, 'System', NULL, '2026-02-07 23:32:12'),
(4, 1, -1.000, 97.000, 'sale', 'order', 1, 'System', NULL, '2026-02-07 23:32:12'),
(5, 2, -1.000, 47.000, 'sale', 'order', 1, 'System', NULL, '2026-02-07 23:32:12'),
(6, 4, -1.000, 47.000, 'sale', 'order', 1, 'System', NULL, '2026-02-07 23:32:12');

-- --------------------------------------------------------

--
-- Table structure for table `suppliers`
--

CREATE TABLE `suppliers` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `contact` varchar(100) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `display_name` varchar(100) DEFAULT NULL,
  `role` enum('admin','cashier') DEFAULT 'cashier',
  `is_active` tinyint(1) DEFAULT 1,
  `last_login` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password_hash`, `display_name`, `role`, `is_active`, `last_login`, `created_at`, `updated_at`) VALUES
(1, 'admin', '0192023a7bbd73250516f069df18b500', 'Administrator', 'admin', 1, NULL, '2026-02-07 23:31:14', '2026-02-07 23:31:14'),
(2, 'cashier', 'dbb8c54ee649f8af049357a5f99cede6', 'Main Cashier', 'cashier', 1, NULL, '2026-02-07 23:31:14', '2026-02-07 23:31:14');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_audit_user` (`user_id`),
  ADD KEY `idx_audit_action` (`action`),
  ADD KEY `idx_audit_date` (`created_at`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_cat_active` (`is_active`);

--
-- Indexes for table `expenses`
--
ALTER TABLE `expenses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_expense_shift` (`shift_id`),
  ADD KEY `idx_expense_user` (`added_by`),
  ADD KEY `idx_expense_date` (`created_at`);

--
-- Indexes for table `inventory`
--
ALTER TABLE `inventory`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_inv_sku` (`sku`),
  ADD KEY `idx_inv_supplier` (`supplier_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_order_status` (`status`),
  ADD KEY `idx_order_shift` (`shift_id`),
  ADD KEY `idx_order_table` (`table_id`),
  ADD KEY `idx_order_waiter` (`waiter_id`),
  ADD KEY `idx_order_created` (`created_at`),
  ADD KEY `idx_order_number` (`order_number`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_item_order` (`order_id`),
  ADD KEY `idx_item_product` (`product_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_prod_category` (`category_id`),
  ADD KEY `idx_prod_available` (`is_available`),
  ADD KEY `idx_prod_barcode` (`barcode`);

--
-- Indexes for table `recipes`
--
ALTER TABLE `recipes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_recipe_product` (`product_id`),
  ADD KEY `idx_recipe_inventory` (`inventory_id`);

--
-- Indexes for table `restaurant_tables`
--
ALTER TABLE `restaurant_tables`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_table_status` (`status`);

--
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `setting_key` (`setting_key`),
  ADD KEY `idx_setting_key` (`setting_key`),
  ADD KEY `idx_setting_category` (`category`);

--
-- Indexes for table `shifts`
--
ALTER TABLE `shifts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_shift_status` (`status`),
  ADD KEY `idx_shift_user` (`user_id`),
  ADD KEY `idx_shift_date` (`start_time`);

--
-- Indexes for table `shift_closings`
--
ALTER TABLE `shift_closings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_closing_user` (`user_id`),
  ADD KEY `idx_closing_date` (`shift_end`);


-- Indexes for table `staff`
--
ALTER TABLE `staff`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_staff_role` (`role`),
  ADD KEY `idx_staff_active` (`is_active`);

--
-- Indexes for table `stock_logs`
--
ALTER TABLE `stock_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_stock_inventory` (`inventory_id`),
  ADD KEY `idx_stock_date` (`created_at`);

--
-- Indexes for table `suppliers`
--
ALTER TABLE `suppliers`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `idx_user_username` (`username`),
  ADD KEY `idx_user_role` (`role`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `expenses`
--
ALTER TABLE `expenses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `inventory`
--
ALTER TABLE `inventory`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `recipes`
--
ALTER TABLE `recipes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `restaurant_tables`
--
ALTER TABLE `restaurant_tables`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `settings`
--
ALTER TABLE `settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `shifts`
--
ALTER TABLE `shifts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `shift_closings`
--
ALTER TABLE `shift_closings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;


--
-- AUTO_INCREMENT for table `staff`
--
ALTER TABLE `staff`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `stock_logs`
--
ALTER TABLE `stock_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `suppliers`
--
ALTER TABLE `suppliers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `inventory`
--
ALTER TABLE `inventory`
  ADD CONSTRAINT `inventory_ibfk_1` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`shift_id`) REFERENCES `shifts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`table_id`) REFERENCES `restaurant_tables` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `orders_ibfk_3` FOREIGN KEY (`waiter_id`) REFERENCES `staff` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `expenses`
--
ALTER TABLE `expenses`
  ADD CONSTRAINT `expenses_ibfk_1` FOREIGN KEY (`shift_id`) REFERENCES `shifts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `expenses_ibfk_2` FOREIGN KEY (`added_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `recipes`
--
ALTER TABLE `recipes`
  ADD CONSTRAINT `recipes_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `recipes_ibfk_2` FOREIGN KEY (`inventory_id`) REFERENCES `inventory` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `shifts`
--
ALTER TABLE `shifts`
  ADD CONSTRAINT `shifts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `restaurant_tables`
--
ALTER TABLE `restaurant_tables`
  ADD CONSTRAINT `restaurant_tables_ibfk_1` FOREIGN KEY (`waiter_id`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `restaurant_tables_ibfk_2` FOREIGN KEY (`current_order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `shift_closings`
--
ALTER TABLE `shift_closings`
  ADD CONSTRAINT `shift_closings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;


--
-- Constraints for table `stock_logs`
--
ALTER TABLE `stock_logs`
  ADD CONSTRAINT `stock_logs_ibfk_1` FOREIGN KEY (`inventory_id`) REFERENCES `inventory` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
