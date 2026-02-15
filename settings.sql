-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3307
-- Generation Time: Feb 09, 2026 at 01:15 AM
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
(1, 'restaurant_name', 'Cafe Arsalan ', 'text', 'general'),
(2, 'restaurant_address', '123 Food Street, City', 'text', 'general'),
(3, 'restaurant_phone', '+1 234 567 890', 'text', 'general'),
(4, 'restaurant_logo', 'assets/logo_1770594873.png', 'text', 'general'),
(5, 'tax_rate', '0', 'number', 'general'),
(6, 'tax_name', 'VAT', 'text', 'general'),
(7, 'service_charge_rate', '0', 'number', 'general'),
(8, 'packaging_fee', '0', 'number', 'general'),
(9, 'delivery_fee', '0', 'number', 'general'),
(10, 'currency_symbol', 'Rs: ', 'text', 'general'),
(11, 'cashier_access_pos', 'true', 'boolean', 'permissions'),
(12, 'cashier_access_floor', 'true', 'boolean', 'permissions'),
(13, 'cashier_view_reports', 'false', 'boolean', 'permissions'),
(14, 'cashier_export_data', 'false', 'boolean', 'permissions'),
(15, 'cashier_access_settings', 'false', 'boolean', 'permissions'),
(16, 'cashier_void_orders', 'false', 'boolean', 'permissions'),
(17, 'admin_full_access', 'true', 'boolean', 'permissions'),
(18, 'default_order_type', 'Walk-in', 'text', 'order'),
(19, 'show_order_timer', 'true', 'boolean', 'order'),
(20, 'allow_qty_edit_after_kot', 'true', 'boolean', 'order'),
(21, 'allow_cancel_after_payment', 'false', 'boolean', 'order'),
(22, 'merge_orders_same_table', 'false', 'boolean', 'order'),
(23, 'auto_release_table', 'true', 'boolean', 'tables'),
(24, 'table_color_free', '#10b24e', 'text', 'tables'),
(25, 'table_color_busy', '#d41c1c', 'text', 'tables'),
(26, 'table_color_reserved', '#f79009', 'text', 'tables'),
(27, 'allow_merge_table', 'false', 'boolean', 'tables'),
(28, 'strict_stock_control', 'false', 'boolean', 'inventory'),
(29, 'show_logo_receipt', 'true', 'boolean', 'receipt'),
(30, 'show_cashier_receipt', 'true', 'boolean', 'receipt'),
(31, 'printer_width', '80', 'number', 'receipt'),
(32, 'receipt_header', '', 'text', 'receipt'),
(33, 'receipt_footer', 'Thank you for visiting!', 'text', 'receipt'),
(34, 'timezone', 'Asia/Karachi', 'text', 'system'),
(35, 'date_format', 'DD/MM/YYYY', 'text', 'system'),
(36, 'store_open_time', '09:00', 'text', 'system'),
(37, 'store_close_time', '22:00', 'text', 'system'),

(41, 'show_logo_on_receipt', 'true', 'boolean', 'general'),
(43, 'service_charge', '', 'text', 'general'),
(48, 'rounding_rule', 'Nearest Whole', 'text', 'general'),
(50, 'require_bill_before_payment', 'false', 'boolean', 'general'),
(51, 'auto_merge_items', 'true', 'boolean', 'general'),
(53, 'allow_table_transfer', 'false', 'boolean', 'general'),
(57, 'table_color_waiters', '#000000', 'text', 'general'),
(58, 'kot_print_copies', '', 'text', 'general'),
(59, 'auto_print_kot', 'false', 'boolean', 'general'),
(60, 'show_notes_on_kot', 'false', 'boolean', 'general'),
(61, 'print_logo_on_kot', 'true', 'boolean', 'general'),
(62, 'printer_type', 'usb', 'text', 'general'),
(63, 'paper_width', '80', 'number', 'general'),
(66, 'stock_deduction_mode', 'On Payment', 'text', 'general'),
(67, 'low_stock_warning_limit', '10', 'text', 'general'),
(68, 'block_out_of_stock_orders', 'true', 'boolean', 'general'),
(77, 'cashier_hide_financial_data', 'false', 'boolean', 'general');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `setting_key` (`setting_key`),
  ADD KEY `idx_setting_key` (`setting_key`),
  ADD KEY `idx_setting_category` (`category`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `settings`
--
ALTER TABLE `settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1158;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
