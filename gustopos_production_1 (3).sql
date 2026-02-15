-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3307
-- Generation Time: Feb 10, 2026 at 05:00 AM
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
(3, 1, 'OPEN_SHIFT', 'shifts', 2, 'Shift opened with start cash: 0', NULL, '2026-02-07 23:57:52'),
(4, 1, 'CLOSE_SHIFT', 'shifts', 2, 'Shift closed. Actual: 300, Expected: -21.4', NULL, '2026-02-08 14:28:54'),
(5, 1, 'OPEN_SHIFT', 'shifts', 3, 'Shift opened with start cash: 0', NULL, '2026-02-08 14:30:34'),
(6, 1, 'CLOSE_SHIFT', 'shifts', 3, 'Shift closed. Actual: 1000, Expected: -355.65', NULL, '2026-02-08 15:03:04'),
(7, 1, 'OPEN_SHIFT', 'shifts', 4, 'Shift opened with start cash: 0', NULL, '2026-02-08 15:04:45'),
(8, 1, 'CLOSE_SHIFT', 'shifts', 4, 'Shift closed. Actual: 3000, Expected: -417.3', NULL, '2026-02-09 21:59:08'),
(9, 1, 'OPEN_SHIFT', 'shifts', 5, 'Shift opened with start cash: 0', NULL, '2026-02-09 21:59:43'),
(10, 1, 'CLOSE_SHIFT', 'shifts', 5, 'Shift closed. Actual: 0, Expected: 0', NULL, '2026-02-09 22:00:42'),
(11, 1, 'OPEN_SHIFT', 'shifts', 6, 'Shift opened with start cash: 0', NULL, '2026-02-09 22:01:23'),
(12, 1, 'CLOSE_SHIFT', 'shifts', 6, 'Shift closed. Actual: 2000, Expected: -3155', NULL, '2026-02-09 22:37:00'),
(13, 1, 'OPEN_SHIFT', 'shifts', 7, 'Shift opened with start cash: 0', NULL, '2026-02-10 00:34:25'),
(14, 1, 'CLOSE_SHIFT', 'shifts', 7, 'Shift closed. Actual: 2000, Expected: 0', NULL, '2026-02-10 01:35:08'),
(15, 1, 'OPEN_SHIFT', 'shifts', 8, 'Shift opened with start cash: 0', NULL, '2026-02-10 01:35:41');

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

INSERT INTO `expenses` (`id`, `shift_id`, `description`, `category`, `amount`, `status`, `added_by`, `created_at`) VALUES
(1, NULL, 'Laborum nihil pariat', 'Other', 930.00, 'approved', NULL, '2026-02-07 23:32:00'),
(2, NULL, 'Sint obcaecati culpa', 'Other', 300.00, 'approved', NULL, '2026-02-08 13:53:55'),
(3, 2, 'Biryani', 'Supplies', 200.00, 'approved', NULL, '2026-02-08 14:26:43'),
(4, 3, 'Modi maiores blandit', 'Utilities', 970.00, 'approved', NULL, '2026-02-08 14:57:36'),
(5, 4, 'Placeat enim pariat', 'Other', 1200.00, 'approved', NULL, '2026-02-09 21:14:55'),
(6, 4, 'Dolore vel praesenti', 'Utilities', 600.00, 'approved', NULL, '2026-02-09 21:58:03'),
(7, 4, 'Vero quia aperiam fu', 'Supplies', 600.00, 'approved', NULL, '2026-02-09 21:58:19'),
(8, 4, 'Fugit fugiat vel s', 'Other', 600.00, 'approved', NULL, '2026-02-09 21:58:38'),
(9, 6, 'Sequi quidem proiden', 'Other', 3500.00, 'approved', NULL, '2026-02-09 22:06:00');

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
(1, 'Burger Bun', 'ING-001', 'Pack', 'Pcs', 1.000, 48.000, 20.000, 0.50, NULL, '2026-02-07 23:31:15', '2026-02-09 00:20:31'),
(2, 'Beef Patty', 'ING-002', 'Box', 'Pcs', 1.000, 0.000, 30.000, 2.00, NULL, '2026-02-07 23:31:15', '2026-02-09 00:18:59'),
(3, 'Cheddar Cheese', 'ING-003', 'Block', 'Slice', 20.000, 170.000, 40.000, 0.20, 3, '2026-02-07 23:31:15', '2026-02-09 15:39:12'),
(4, 'Coca Cola Can', 'DRK-001', 'Case', 'Can', 1.000, 48.000, 12.000, 1.00, NULL, '2026-02-07 23:31:15', '2026-02-08 15:42:08'),
(5, 'Coffee Beans', 'DRK-002', 'Kg', 'Shot', 50.000, 468.000, 50.000, 0.10, 2, '2026-02-07 23:31:15', '2026-02-09 22:06:45'),
(9, 'Coke 250ml', 'SKU-100', 'Pcs', 'Pcs', 1.000, 82.000, 10.000, 80.00, NULL, '2026-02-08 19:28:08', '2026-02-09 22:06:49'),
(10, 'Cakes', 'SKU-99', 'Pcs', 'Pcs', 1.000, 100.000, 5.000, 20.00, 3, '2026-02-08 19:46:54', '2026-02-10 02:25:57'),
(11, 'Aquafina', 'SKU-260209-8916', 'Pcs', 'Pcs', 1.000, 100.000, 10.000, 80.00, 2, '2026-02-09 15:54:26', '2026-02-09 15:54:59');

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

INSERT INTO `orders` (`id`, `order_number`, `token_number`, `shift_id`, `table_id`, `waiter_id`, `customer_name`, `order_type`, `payment_method`, `subtotal`, `tax`, `service_charge`, `packaging_charge`, `delivery_fee`, `discount`, `total`, `status`, `is_bill_printed`, `void_type`, `deleted_by`, `delete_reason`, `created_at`, `completed_at`) VALUES
(1, 'INV-1001', 0, 1, NULL, NULL, 'Walk-in', '', 'cash', 69.00, 6.90, 0.00, 1.00, 3.00, 0.00, 75.90, 'completed', 0, NULL, NULL, NULL, '2026-02-07 23:32:12', NULL),
(2, 'INV-1002', 0, 2, NULL, NULL, 'Walk-in', '', 'cash', 20.00, 2.00, 0.00, 1.00, 3.00, 0.00, 22.00, 'completed', 0, NULL, NULL, NULL, '2026-02-08 13:51:12', NULL),
(3, 'INV-1003', 0, 2, 1, NULL, 'T-01 (4 seats)', 'dine_in', 'cash', 154.50, 2.10, 0.00, 1.00, 3.00, 0.00, 156.60, 'completed', 0, NULL, NULL, NULL, '2026-02-08 13:51:25', '2026-02-08 18:51:45'),
(4, 'INV-1004', 0, 2, 1, NULL, 'T-01 (4 seats)', 'dine_in', 'cash', 39.00, 3.90, 0.00, 1.00, 3.00, 0.00, 42.90, 'completed', 0, NULL, NULL, NULL, '2026-02-08 14:23:39', '2026-02-09 01:34:02'),
(5, 'INV-1005', 0, 3, NULL, NULL, 'Walk-in', '', 'cash', 92.50, 9.25, 0.00, 1.00, 3.00, 0.00, 101.75, 'completed', 0, NULL, NULL, NULL, '2026-02-08 14:30:58', NULL),
(6, 'INV-1006', 0, 3, NULL, NULL, 'Walk-in', '', 'cash', 32.00, 3.20, 0.00, 1.00, 3.00, 0.00, 35.20, 'completed', 0, NULL, NULL, NULL, '2026-02-08 14:59:05', NULL),
(7, 'INV-1007', 0, 3, NULL, NULL, 'Walk-in', '', 'cash', 20.00, 2.00, 0.00, 1.00, 3.00, 0.00, 22.00, 'completed', 0, NULL, NULL, NULL, '2026-02-08 14:59:15', NULL),
(8, 'INV-1008', 0, 3, NULL, NULL, 'Walk-in', '', 'cash', 87.00, 8.70, 0.00, 1.00, 3.00, 0.00, 95.70, 'completed', 0, NULL, NULL, NULL, '2026-02-08 14:59:24', NULL),
(9, 'INV-1009', 0, 3, NULL, NULL, 'Walk-in', '', 'cash', 55.00, 5.50, 0.00, 1.00, 3.00, 0.00, 60.50, 'completed', 0, NULL, NULL, NULL, '2026-02-08 14:59:32', NULL),
(10, 'INV-1010', 0, 3, NULL, NULL, 'Walk-in', '', 'cash', 110.50, 11.05, 0.00, 1.00, 3.00, 0.00, 121.55, 'completed', 0, NULL, NULL, NULL, '2026-02-08 14:59:48', NULL),
(11, 'INV-1011', 0, 3, NULL, NULL, 'Walk-in', '', 'cash', 69.00, 6.90, 0.00, 1.00, 3.00, 0.00, 75.90, 'completed', 0, NULL, NULL, NULL, '2026-02-08 15:00:03', NULL),
(12, 'INV-1012', 0, 3, NULL, NULL, 'Walk-in', '', 'cash', 92.50, 9.25, 0.00, 1.00, 3.00, 0.00, 101.75, 'completed', 0, NULL, NULL, NULL, '2026-02-08 15:00:18', NULL),
(13, 'INV-1013', 0, 4, NULL, NULL, 'Walk-in', '', 'cash', 87.50, 8.75, 0.00, 1.00, 3.00, 0.00, 96.25, 'completed', 0, NULL, NULL, NULL, '2026-02-08 15:05:05', NULL),
(14, 'INV-1014', 0, 4, NULL, NULL, 'Walk-in', '', 'cash', 32.00, 3.20, 0.00, 1.00, 3.00, 0.00, 35.20, 'completed', 0, NULL, NULL, NULL, '2026-02-08 16:02:26', NULL),
(15, 'INV-1015', 0, 4, NULL, NULL, 'Walk-in', '', 'cash', 432.00, 43.20, 0.00, 1.00, 3.00, 0.00, 475.20, 'completed', 0, NULL, NULL, NULL, '2026-02-08 19:44:27', NULL),
(16, 'INV-1016', 0, 4, NULL, NULL, 'Walk-in', '', 'cash', 120.00, 12.00, 0.00, 1.00, 3.00, 0.00, 132.00, 'completed', 0, NULL, NULL, NULL, '2026-02-08 19:47:52', NULL),
(17, 'INV-1017', 0, 4, NULL, NULL, 'Walk-in', '', 'cash', 100.00, 10.00, 0.00, 1.00, 3.00, 0.00, 110.00, 'completed', 0, NULL, NULL, NULL, '2026-02-08 19:48:12', NULL),
(18, 'INV-1018', 0, 4, NULL, NULL, 'Walk-in', '', 'cash', 40.00, 4.00, 0.00, 1.00, 3.00, 0.00, 44.00, 'completed', 0, NULL, NULL, NULL, '2026-02-08 19:48:40', NULL),
(19, 'INV-1019', 0, 4, NULL, NULL, 'Walk-in', '', 'cash', 80.00, 8.00, 0.00, 1.00, 3.00, 0.00, 88.00, 'completed', 0, NULL, NULL, NULL, '2026-02-08 20:00:00', NULL),
(20, 'INV-1020', 0, 4, NULL, NULL, 'Walk-in', '', 'cash', 60.00, 6.00, 0.00, 1.00, 3.00, 0.00, 66.00, 'completed', 0, NULL, NULL, NULL, '2026-02-08 20:00:42', NULL),
(21, 'INV-1021', 0, 4, NULL, NULL, 'Cade Diaz (35 seats)', 'dine_in', 'cash', 96.00, 9.60, 0.00, 1.00, 3.00, 0.00, 105.60, 'completed', 0, NULL, NULL, NULL, '2026-02-08 20:33:54', '2026-02-09 03:02:29'),
(22, 'INV-1022', 0, 4, 1, NULL, 'T-01 (4 seats)', 'dine_in', 'cash', 55.50, 5.55, 0.00, 1.00, 3.00, 0.00, 61.05, 'completed', 0, NULL, NULL, NULL, '2026-02-08 20:34:22', '2026-02-09 03:02:56'),
(23, 'INV-1023', 0, 4, NULL, NULL, 'Walk-in', '', 'cash', 114.00, 11.40, 0.00, 1.00, 3.00, 0.00, 125.40, 'completed', 0, NULL, NULL, NULL, '2026-02-08 20:34:34', NULL),
(24, 'INV-1024', 0, 4, NULL, NULL, 'Walk-in', '', 'cash', 37.50, 0.00, 0.00, 0.00, 0.00, 0.00, 37.50, 'completed', 0, NULL, NULL, NULL, '2026-02-08 20:36:53', NULL),
(43, 'INV-1043', 0, 4, 12, NULL, 'T-04 (6 seats)', 'dine_in', 'cash', 39.50, 0.00, 0.00, 0.00, 0.00, 0.00, 39.50, 'completed', 0, NULL, NULL, NULL, '2026-02-08 22:53:04', '2026-02-09 05:09:02'),
(44, 'INV-1044', 0, 4, 1, NULL, 'T-01 (4 seats)', 'dine_in', 'cash', 23.50, 0.00, 0.00, 0.00, 0.00, 0.00, 23.50, 'completed', 0, NULL, NULL, NULL, '2026-02-08 22:57:41', '2026-02-09 04:57:39'),
(45, 'INV-1045', 0, 4, NULL, NULL, 'Walk-in', '', 'cash', 126.00, 0.00, 0.00, 0.00, 0.00, 0.00, 126.00, 'completed', 0, NULL, NULL, NULL, '2026-02-08 23:55:27', NULL),
(46, 'INV-1046', 0, 4, NULL, NULL, 'Walk-in', '', 'cash', 131.50, 0.00, 0.00, 0.00, 0.00, 0.00, 131.50, 'completed', 0, NULL, NULL, NULL, '2026-02-08 23:55:50', NULL),
(47, 'INV-1047', 0, 4, 1, NULL, 'T-01 (4 seats)', 'dine_in', 'cash', 122.00, 0.00, 0.00, 0.00, 0.00, 0.00, 122.00, 'completed', 0, NULL, NULL, NULL, '2026-02-08 23:59:45', '2026-02-09 05:20:30'),
(48, 'INV-1048', 0, 4, NULL, NULL, 'Walk-in', '', 'cash', 122.00, 0.00, 0.00, 0.00, 0.00, 0.00, 122.00, 'completed', 0, NULL, NULL, NULL, '2026-02-08 23:59:52', NULL),
(49, 'INV-1049', 0, 4, NULL, NULL, 'Walk-in', '', 'cash', 106.00, 0.00, 0.00, 0.00, 0.00, 0.00, 106.00, 'completed', 0, NULL, NULL, NULL, '2026-02-09 00:02:35', NULL),
(50, 'INV-1050', 0, 4, NULL, NULL, 'Walk-in', '', 'cash', 72.50, 0.00, 0.00, 0.00, 0.00, 0.00, 72.50, 'completed', 0, NULL, NULL, NULL, '2026-02-09 00:03:53', NULL),
(51, 'INV-1051', 0, 4, NULL, NULL, 'Walk-in', '', 'cash', 108.00, 0.00, 0.00, 0.00, 0.00, 0.00, 108.00, 'completed', 0, NULL, NULL, NULL, '2026-02-09 00:07:53', NULL),
(52, 'INV-1052', 0, 4, NULL, NULL, 'Walk-in', '', 'cash', 122.00, 0.00, 0.00, 0.00, 0.00, 0.00, 122.00, 'completed', 0, NULL, NULL, NULL, '2026-02-09 00:14:36', NULL),
(53, 'INV-1053', 0, 4, NULL, NULL, 'Walk-in', '', 'cash', 33.50, 0.00, 0.00, 0.00, 0.00, 0.00, 33.50, 'completed', 0, NULL, NULL, NULL, '2026-02-09 00:18:59', NULL),
(54, 'INV-1054', 0, 4, NULL, NULL, 'Walk-in', '', 'cash', 200.00, 0.00, 0.00, 0.00, 0.00, 0.00, 200.00, 'completed', 0, NULL, NULL, NULL, '2026-02-09 00:19:23', NULL),
(55, 'INV-1055', 0, 6, NULL, NULL, 'Walk-in', '', 'cash', 19.50, 0.00, 0.00, 0.00, 0.00, 0.00, 19.50, 'completed', 0, NULL, NULL, NULL, '2026-02-09 22:02:00', NULL),
(56, 'INV-1056', 0, 6, NULL, NULL, 'Walk-in', '', 'cash', 96.00, 0.00, 0.00, 0.00, 0.00, 0.00, 96.00, 'completed', 0, NULL, NULL, NULL, '2026-02-09 22:02:42', NULL),
(57, 'INV-1057', 0, 6, NULL, NULL, 'Walk-in', '', 'cash', 19.50, 0.00, 0.00, 0.00, 0.00, 0.00, 19.50, 'completed', 0, NULL, NULL, NULL, '2026-02-09 22:06:45', NULL),
(58, 'INV-1058', 0, 6, NULL, NULL, 'Walk-in', '', 'cash', 144.00, 0.00, 0.00, 0.00, 0.00, 0.00, 144.00, 'completed', 0, NULL, NULL, NULL, '2026-02-09 22:06:49', NULL),
(59, 'INV-1059', 0, 6, NULL, NULL, 'Walk-in', '', 'cash', 30.00, 0.00, 0.00, 0.00, 0.00, 0.00, 30.00, 'completed', 0, NULL, NULL, NULL, '2026-02-09 22:06:59', NULL),
(60, 'INV-1060', 0, 6, NULL, NULL, 'Walk-in', '', 'cash', 36.00, 0.00, 0.00, 0.00, 0.00, 0.00, 36.00, 'completed', 0, NULL, NULL, NULL, '2026-02-09 22:07:03', NULL),
(61, 'INV-1061', 0, 7, NULL, NULL, 'Walk-in', '', 'cash', 14.00, 0.00, 0.00, 0.00, 0.00, 0.00, 14.00, '', 0, NULL, NULL, 'West', '2026-02-10 00:45:50', NULL),
(64, 'INV-1064', 0, 7, 1, NULL, 'T-01 (4 seats)', 'dine_in', 'cash', 96.00, 0.00, 0.00, 0.00, 0.00, 0.00, 96.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 01:32:06', NULL),
(65, 'INV-1065', 0, 7, 12, NULL, 'T-12 (8 seats)', 'dine_in', 'cash', 40.00, 0.00, 0.00, 0.00, 0.00, 0.00, 40.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 01:32:14', NULL),
(66, 'INV-1066', 0, 8, NULL, NULL, 'Walk-in', '', 'cash', 302.00, 0.00, 0.00, 0.00, 0.00, 0.00, 302.00, 'completed', 0, NULL, NULL, NULL, '2026-02-10 01:36:14', NULL),
(67, 'INV-1067', 0, 8, NULL, NULL, 'Walk-in', '', 'cash', 100.00, 0.00, 0.00, 0.00, 0.00, 0.00, 100.00, 'completed', 0, NULL, NULL, NULL, '2026-02-10 02:24:00', NULL),
(68, 'INV-1068', 0, 8, NULL, NULL, 'Walk-in', '', 'cash', 100.00, 0.00, 0.00, 0.00, 0.00, 0.00, 100.00, '', 0, NULL, NULL, 'Nothing ', '2026-02-10 02:25:15', NULL),
(69, 'INV-1069', 0, 8, NULL, NULL, 'Walk-in', '', 'cash', 30.00, 0.00, 0.00, 0.00, 0.00, 0.00, 30.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 03:46:52', NULL),
(70, 'INV-1070', 0, 8, NULL, NULL, 'Walk-in', '', 'cash', 15.00, 0.00, 0.00, 0.00, 0.00, 0.00, 15.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 03:46:59', NULL);

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
(1, 1, 2, 'Cheese Burger', 2, 14.00, '', 1, '2026-02-09 03:17:44'),
(2, 1, 8, 'Chocolate Cake', 1, 6.00, '', 1, '2026-02-09 03:17:44'),
(3, 1, 1, 'Classic Beef Burger', 1, 12.00, '', 1, '2026-02-09 03:17:44'),
(4, 1, 6, 'Coca Cola', 1, 3.00, '', 1, '2026-02-09 03:17:44'),
(5, 1, 3, 'Double Bacon', 1, 16.00, '', 1, '2026-02-09 03:17:44'),
(6, 1, 9, 'French Fries', 1, 4.00, '', 1, '2026-02-09 03:17:44'),
(7, 2, 2, 'Cheese Burger', 1, 14.00, '', 1, '2026-02-09 03:17:44'),
(8, 2, 8, 'Chocolate Cake', 1, 6.00, '', 1, '2026-02-09 03:17:44'),
(9, 3, 6, 'Coca Cola', 3, 3.00, '', 1, '2026-02-09 03:17:44'),
(10, 3, 1, 'Classic Beef Burger', 3, 12.00, '', 1, '2026-02-09 03:17:44'),
(11, 3, 8, 'Chocolate Cake', 3, 6.00, '', 1, '2026-02-09 03:17:44'),
(12, 3, 2, 'Cheese Burger', 2, 14.00, '', 1, '2026-02-09 03:17:44'),
(13, 3, 4, 'Pepperoni Pizza', 2, 18.00, '', 1, '2026-02-09 03:17:44'),
(14, 3, 9, 'French Fries', 2, 4.00, '', 1, '2026-02-09 03:17:44'),
(15, 3, 7, 'Iced Latte', 1, 4.50, '', 1, '2026-02-09 03:17:44'),
(16, 3, 5, 'Margherita', 1, 15.00, '', 1, '2026-02-09 03:17:44'),
(17, 4, 1, 'Classic Beef Burger', 1, 12.00, '', 1, '2026-02-09 03:17:44'),
(18, 4, 8, 'Chocolate Cake', 1, 6.00, '', 1, '2026-02-09 03:17:44'),
(19, 4, 4, 'Pepperoni Pizza', 1, 18.00, '', 1, '2026-02-09 03:17:44'),
(20, 4, 6, 'Coca Cola', 1, 3.00, '', 1, '2026-02-09 03:17:44'),
(21, 5, 2, 'Cheese Burger', 1, 14.00, '', 1, '2026-02-09 03:17:44'),
(22, 5, 8, 'Chocolate Cake', 1, 6.00, '', 1, '2026-02-09 03:17:44'),
(23, 5, 1, 'Classic Beef Burger', 1, 12.00, '', 1, '2026-02-09 03:17:44'),
(24, 5, 6, 'Coca Cola', 1, 3.00, '', 1, '2026-02-09 03:17:44'),
(25, 5, 3, 'Double Bacon', 1, 16.00, '', 1, '2026-02-09 03:17:44'),
(26, 5, 9, 'French Fries', 1, 4.00, '', 1, '2026-02-09 03:17:44'),
(27, 5, 7, 'Iced Latte', 1, 4.50, '', 1, '2026-02-09 03:17:44'),
(28, 5, 5, 'Margherita', 1, 15.00, '', 1, '2026-02-09 03:17:44'),
(29, 5, 4, 'Pepperoni Pizza', 1, 18.00, '', 1, '2026-02-09 03:17:44'),
(30, 6, 2, 'Cheese Burger', 1, 14.00, '', 1, '2026-02-09 03:17:44'),
(31, 6, 8, 'Chocolate Cake', 1, 6.00, '', 1, '2026-02-09 03:17:44'),
(32, 6, 1, 'Classic Beef Burger', 1, 12.00, '', 1, '2026-02-09 03:17:44'),
(33, 7, 2, 'Cheese Burger', 1, 14.00, '', 1, '2026-02-09 03:17:44'),
(34, 7, 8, 'Chocolate Cake', 1, 6.00, '', 1, '2026-02-09 03:17:44'),
(35, 8, 2, 'Cheese Burger', 1, 14.00, '', 1, '2026-02-09 03:17:44'),
(36, 8, 8, 'Chocolate Cake', 1, 6.00, '', 1, '2026-02-09 03:17:44'),
(37, 8, 1, 'Classic Beef Burger', 1, 12.00, '', 1, '2026-02-09 03:17:44'),
(38, 8, 4, 'Pepperoni Pizza', 2, 18.00, '', 1, '2026-02-09 03:17:44'),
(39, 8, 3, 'Double Bacon', 1, 16.00, '', 1, '2026-02-09 03:17:44'),
(40, 8, 6, 'Coca Cola', 1, 3.00, '', 1, '2026-02-09 03:17:44'),
(41, 9, 2, 'Cheese Burger', 1, 14.00, '', 1, '2026-02-09 03:17:44'),
(42, 9, 8, 'Chocolate Cake', 1, 6.00, '', 1, '2026-02-09 03:17:44'),
(43, 9, 1, 'Classic Beef Burger', 1, 12.00, '', 1, '2026-02-09 03:17:44'),
(44, 9, 6, 'Coca Cola', 1, 3.00, '', 1, '2026-02-09 03:17:44'),
(45, 9, 3, 'Double Bacon', 1, 16.00, '', 1, '2026-02-09 03:17:44'),
(46, 9, 9, 'French Fries', 1, 4.00, '', 1, '2026-02-09 03:17:44'),
(47, 10, 2, 'Cheese Burger', 1, 14.00, '', 1, '2026-02-09 03:17:44'),
(48, 10, 4, 'Pepperoni Pizza', 2, 18.00, '', 1, '2026-02-09 03:17:44'),
(49, 10, 8, 'Chocolate Cake', 1, 6.00, '', 1, '2026-02-09 03:17:44'),
(50, 10, 1, 'Classic Beef Burger', 1, 12.00, '', 1, '2026-02-09 03:17:44'),
(51, 10, 6, 'Coca Cola', 1, 3.00, '', 1, '2026-02-09 03:17:44'),
(52, 10, 3, 'Double Bacon', 1, 16.00, '', 1, '2026-02-09 03:17:44'),
(53, 10, 9, 'French Fries', 1, 4.00, '', 1, '2026-02-09 03:17:44'),
(54, 10, 7, 'Iced Latte', 1, 4.50, '', 1, '2026-02-09 03:17:44'),
(55, 10, 5, 'Margherita', 1, 15.00, '', 1, '2026-02-09 03:17:44'),
(56, 11, 2, 'Cheese Burger', 1, 14.00, '', 1, '2026-02-09 03:17:44'),
(57, 11, 8, 'Chocolate Cake', 1, 6.00, '', 1, '2026-02-09 03:17:44'),
(58, 11, 1, 'Classic Beef Burger', 1, 12.00, '', 1, '2026-02-09 03:17:44'),
(59, 11, 6, 'Coca Cola', 1, 3.00, '', 1, '2026-02-09 03:17:44'),
(60, 11, 3, 'Double Bacon', 1, 16.00, '', 1, '2026-02-09 03:17:44'),
(61, 11, 4, 'Pepperoni Pizza', 1, 18.00, '', 1, '2026-02-09 03:17:44'),
(62, 12, 5, 'Margherita', 1, 15.00, '', 1, '2026-02-09 03:17:44'),
(63, 12, 7, 'Iced Latte', 1, 4.50, '', 1, '2026-02-09 03:17:44'),
(64, 12, 9, 'French Fries', 1, 4.00, '', 1, '2026-02-09 03:17:44'),
(65, 12, 3, 'Double Bacon', 1, 16.00, '', 1, '2026-02-09 03:17:44'),
(66, 12, 6, 'Coca Cola', 1, 3.00, '', 1, '2026-02-09 03:17:44'),
(67, 12, 1, 'Classic Beef Burger', 1, 12.00, '', 1, '2026-02-09 03:17:44'),
(68, 12, 8, 'Chocolate Cake', 1, 6.00, '', 1, '2026-02-09 03:17:44'),
(69, 12, 2, 'Cheese Burger', 1, 14.00, '', 1, '2026-02-09 03:17:44'),
(70, 12, 4, 'Pepperoni Pizza', 1, 18.00, '', 1, '2026-02-09 03:17:44'),
(71, 13, 2, 'Cheese Burger', 1, 14.00, '', 1, '2026-02-09 03:17:44'),
(72, 13, 1, 'Classic Beef Burger', 1, 12.00, '', 1, '2026-02-09 03:17:44'),
(73, 13, 3, 'Double Bacon', 1, 16.00, '', 1, '2026-02-09 03:17:44'),
(74, 13, 9, 'French Fries', 2, 4.00, '', 1, '2026-02-09 03:17:44'),
(75, 13, 7, 'Iced Latte', 1, 4.50, '', 1, '2026-02-09 03:17:44'),
(76, 13, 5, 'Margherita', 1, 15.00, '', 1, '2026-02-09 03:17:44'),
(77, 13, 4, 'Pepperoni Pizza', 1, 18.00, '', 1, '2026-02-09 03:17:44'),
(78, 14, 2, 'Cheese Burger', 1, 14.00, '', 1, '2026-02-09 03:17:44'),
(79, 14, 8, 'Chocolate Cake', 1, 6.00, '', 1, '2026-02-09 03:17:44'),
(80, 14, 1, 'Classic Beef Burger', 1, 12.00, '', 1, '2026-02-09 03:17:44'),
(81, 15, 2, 'Cheese Burger', 1, 14.00, '', 1, '2026-02-09 03:17:44'),
(82, 15, 8, 'Chocolate Cake', 1, 6.00, '', 1, '2026-02-09 03:17:44'),
(83, 15, 1, 'Classic Beef Burger', 1, 12.00, '', 1, '2026-02-09 03:17:44'),
(84, 15, 6, 'Coca Cola', 5, 80.00, '', 1, '2026-02-09 03:17:44'),
(85, 16, 8, 'Chocolate Cake', 6, 20.00, '', 1, '2026-02-09 03:17:44'),
(86, 17, 8, 'Chocolate Cake', 5, 20.00, '', 1, '2026-02-09 03:17:44'),
(87, 18, 8, 'Chocolate Cake', 2, 20.00, '', 1, '2026-02-09 03:17:44'),
(88, 19, 8, 'Chocolate Cake', 4, 20.00, '', 1, '2026-02-09 03:17:44'),
(89, 20, 8, 'Chocolate Cake', 3, 20.00, '', 1, '2026-02-09 03:17:44'),
(90, 21, 2, 'Cheese Burger', 1, 14.00, '', 1, '2026-02-09 03:17:44'),
(91, 21, 4, 'Pepperoni Pizza', 1, 18.00, '', 1, '2026-02-09 03:17:44'),
(92, 21, 3, 'Double Bacon', 2, 16.00, '', 1, '2026-02-09 03:17:44'),
(93, 21, 9, 'French Fries', 2, 4.00, '', 1, '2026-02-09 03:17:44'),
(94, 21, 7, 'Iced Latte', 2, 4.50, '', 1, '2026-02-09 03:17:44'),
(95, 21, 5, 'Margherita', 1, 15.00, '', 1, '2026-02-09 03:17:44'),
(96, 22, 2, 'Cheese Burger', 1, 14.00, '', 1, '2026-02-09 03:17:44'),
(97, 22, 9, 'French Fries', 1, 4.00, '', 1, '2026-02-09 03:17:44'),
(98, 22, 7, 'Iced Latte', 1, 4.50, '', 1, '2026-02-09 03:17:44'),
(99, 22, 5, 'Margherita', 1, 15.00, '', 1, '2026-02-09 03:17:44'),
(100, 22, 4, 'Pepperoni Pizza', 1, 18.00, '', 1, '2026-02-09 03:17:44'),
(101, 23, 2, 'Cheese Burger', 1, 14.00, '', 1, '2026-02-09 03:17:44'),
(102, 23, 6, 'Coca Cola', 1, 80.00, '', 1, '2026-02-09 03:17:44'),
(103, 23, 3, 'Double Bacon', 1, 16.00, '', 1, '2026-02-09 03:17:44'),
(104, 23, 9, 'French Fries', 1, 4.00, '', 1, '2026-02-09 03:17:44'),
(105, 24, 2, 'Cheese Burger', 1, 14.00, '', 1, '2026-02-09 03:17:44'),
(106, 24, 7, 'Iced Latte', 1, 4.50, '', 1, '2026-02-09 03:17:44'),
(107, 24, 5, 'Margherita', 1, 15.00, '', 1, '2026-02-09 03:17:44'),
(108, 24, 9, 'French Fries', 1, 4.00, '', 1, '2026-02-09 03:17:44'),
(166, 43, 5, 'Margherita', 1, 15.00, '', 0, NULL),
(167, 43, 7, 'Iced Latte', 1, 4.50, '', 0, NULL),
(168, 43, 9, 'French Fries', 1, 4.00, '', 0, NULL),
(169, 43, 3, 'Double Bacon', 1, 16.00, '', 0, NULL),
(170, 44, 9, 'French Fries', 1, 4.00, '', 0, NULL),
(171, 44, 7, 'Iced Latte', 1, 4.50, '', 0, NULL),
(172, 44, 5, 'Margherita', 1, 15.00, '', 0, NULL),
(173, 45, 2, 'Cheese Burger', 1, 14.00, '', 0, NULL),
(174, 45, 6, 'Coca Cola', 1, 80.00, '', 0, NULL),
(175, 45, 1, 'Classic Beef Burger', 1, 12.00, '', 0, NULL),
(176, 45, 3, 'Double Bacon', 1, 16.00, '', 0, NULL),
(177, 45, 9, 'French Fries', 1, 4.00, '', 0, NULL),
(178, 46, 6, 'Coca Cola', 1, 80.00, '', 0, NULL),
(179, 46, 1, 'Classic Beef Burger', 1, 12.00, '', 0, NULL),
(180, 46, 3, 'Double Bacon', 1, 16.00, '', 0, NULL),
(181, 46, 9, 'French Fries', 1, 4.00, '', 0, NULL),
(182, 46, 7, 'Iced Latte', 1, 4.50, '', 0, NULL),
(183, 46, 5, 'Margherita', 1, 15.00, '', 0, NULL),
(184, 47, 2, 'Cheese Burger', 1, 14.00, '', 0, NULL),
(185, 47, 1, 'Classic Beef Burger', 1, 12.00, '', 0, NULL),
(186, 47, 6, 'Coca Cola', 1, 80.00, '', 0, NULL),
(187, 47, 3, 'Double Bacon', 1, 16.00, '', 0, NULL),
(188, 48, 2, 'Cheese Burger', 1, 14.00, '', 0, NULL),
(189, 48, 1, 'Classic Beef Burger', 1, 12.00, '', 0, NULL),
(190, 48, 6, 'Coca Cola', 1, 80.00, '', 0, NULL),
(191, 48, 3, 'Double Bacon', 1, 16.00, '', 0, NULL),
(192, 49, 2, 'Cheese Burger', 1, 14.00, '', 0, NULL),
(193, 49, 1, 'Classic Beef Burger', 1, 12.00, '', 0, NULL),
(194, 49, 6, 'Coca Cola', 1, 80.00, '', 0, NULL),
(195, 50, 2, 'Cheese Burger', 4, 14.00, '', 0, NULL),
(196, 50, 9, 'French Fries', 3, 4.00, '', 0, NULL),
(197, 50, 7, 'Iced Latte', 1, 4.50, '', 0, NULL),
(198, 51, 1, 'Classic Beef Burger', 1, 12.00, '', 0, NULL),
(199, 51, 6, 'Coca Cola', 1, 80.00, '', 0, NULL),
(200, 51, 3, 'Double Bacon', 1, 16.00, '', 0, NULL),
(201, 52, 2, 'Cheese Burger', 1, 14.00, '', 0, NULL),
(202, 52, 1, 'Classic Beef Burger', 1, 12.00, '', 0, NULL),
(203, 52, 6, 'Coca Cola', 1, 80.00, '', 0, NULL),
(204, 52, 3, 'Double Bacon', 1, 16.00, '', 0, NULL),
(205, 53, 2, 'Cheese Burger', 1, 14.00, '', 0, NULL),
(206, 53, 7, 'Iced Latte', 1, 4.50, '', 0, NULL),
(207, 53, 5, 'Margherita', 1, 15.00, '', 0, NULL),
(208, 54, 9, 'French Fries', 2, 4.00, '', 0, NULL),
(209, 54, 3, 'Double Bacon', 2, 16.00, '', 0, NULL),
(210, 54, 6, 'Coca Cola', 2, 80.00, '', 0, NULL),
(211, 55, 5, 'Margherita', 1, 15.00, '', 0, NULL),
(212, 55, 7, 'Iced Latte', 1, 4.50, '', 0, NULL),
(213, 56, 6, 'Coca Cola', 1, 80.00, '', 0, NULL),
(214, 56, 3, 'Double Bacon', 1, 16.00, '', 0, NULL),
(215, 57, 5, 'Margherita', 1, 15.00, '', 0, NULL),
(216, 57, 7, 'Iced Latte', 1, 4.50, '', 0, NULL),
(217, 58, 3, 'Double Bacon', 4, 16.00, '', 0, NULL),
(218, 58, 6, 'Coca Cola', 1, 80.00, '', 0, NULL),
(219, 59, 5, 'Margherita', 2, 15.00, '', 0, NULL),
(220, 60, 4, 'Pepperoni Pizza', 2, 18.00, '', 0, NULL),
(221, 61, 2, 'Cheese Burger', 1, 14.00, '', 0, NULL),
(224, 64, 6, 'Coca Cola', 1, 80.00, '', 0, NULL),
(225, 64, 3, 'Double Bacon', 1, 16.00, '', 0, NULL),
(226, 65, 8, 'Chocolate Cake', 2, 20.00, '', 0, NULL),
(227, 66, 2, 'Cheese Burger', 1, 14.00, '', 0, NULL),
(228, 66, 8, 'Chocolate Cake', 1, 20.00, '', 0, NULL),
(229, 66, 1, 'Classic Beef Burger', 1, 12.00, '', 0, NULL),
(230, 66, 6, 'Coca Cola', 3, 80.00, '', 0, NULL),
(231, 66, 3, 'Double Bacon', 1, 16.00, '', 0, NULL),
(232, 67, 8, 'Chocolate Cake', 5, 20.00, '', 0, NULL),
(233, 68, 8, 'Chocolate Cake', 5, 20.00, '', 0, NULL),
(234, 69, 4, 'Pepperoni Pizza', 1, 18.00, '', 0, NULL),
(235, 69, 1, 'Classic Beef Burger', 1, 12.00, '', 0, NULL),
(236, 70, 5, 'Margherita', 1, 15.00, '', 0, NULL);

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
(6, 'Coca Cola', 80.00, 0.00, 3, 'https://placehold.co/150x100/B71C1C/fff?text=Cola', NULL, 1, 0, '2026-02-07 23:31:15', '2026-02-08 19:44:00'),
(7, 'Iced Latte', 4.50, 0.00, 3, 'https://placehold.co/150x100/795548/fff?text=Latte', NULL, 1, 0, '2026-02-07 23:31:15', '2026-02-07 23:31:15'),
(8, 'Chocolate Cake', 20.00, 0.00, 4, 'https://placehold.co/150x100/5D4037/fff?text=Cake', NULL, 1, 0, '2026-02-07 23:31:15', '2026-02-08 19:47:40'),
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
(11, 8, 10, 1.000);

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
(1, 'T-01', 4, 'busy', NULL, '2026-02-10 06:32:06', 64, NULL, NULL, 0, 0),
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
(12, 'T-12', 8, 'busy', NULL, '2026-02-10 06:32:14', 65, NULL, NULL, 0, 0);

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
(77, 'cashier_hide_financial_data', 'false', 'boolean', 'general'),
(1159, 'phone_number', '16641688478', 'number', 'general'),
(1160, 'address', 'Hyderabad', 'text', 'general');

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
(2, 1, '2026-02-08 04:57:52', '2026-02-08 19:28:54', 0.00, 300.00, 'closed', NULL, '2026-02-07 23:57:52', '2026-02-08 14:28:54'),
(3, 1, '2026-02-08 19:30:34', '2026-02-08 20:03:04', 0.00, 1000.00, 'closed', NULL, '2026-02-08 14:30:34', '2026-02-08 15:03:04'),
(4, 1, '2026-02-08 20:04:45', '2026-02-10 02:59:08', 0.00, 3000.00, 'closed', NULL, '2026-02-08 15:04:45', '2026-02-09 21:59:08'),
(5, 1, '2026-02-10 02:59:43', '2026-02-10 03:00:42', 0.00, 0.00, 'closed', NULL, '2026-02-09 21:59:43', '2026-02-09 22:00:42'),
(6, 1, '2026-02-10 03:01:23', '2026-02-10 03:37:00', 0.00, 2000.00, 'closed', NULL, '2026-02-09 22:01:23', '2026-02-09 22:37:00'),
(7, 1, '2026-02-10 05:34:25', '2026-02-10 06:35:08', 0.00, 2000.00, 'closed', NULL, '2026-02-10 00:34:25', '2026-02-10 01:35:08'),
(8, 1, '2026-02-10 06:35:41', NULL, 0.00, 0.00, 'open', NULL, '2026-02-10 01:35:41', '2026-02-10 01:35:41');

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
(1, 1, 'admin', '2026-02-08 04:31:49', '2026-02-08 04:33:08', 75.90, 75.90, 0.00, 0.00, 75.90, 1, 0, 0.00, 0.00, 75.90, 200.00, 124.10, '{\"start_cash\":0,\"cash_sales\":\"75.90\",\"card_sales\":\"0.00\",\"expenses\":\"0.00\"}', '', '2026-02-07 23:33:08'),
(2, 1, 'admin', '2026-02-08 04:57:52', '2026-02-08 19:28:54', 178.60, 178.60, 0.00, 200.00, -21.40, 2, 0, 0.00, 0.00, -21.40, 300.00, 321.40, '{\"start_cash\":0,\"cash_sales\":\"178.60\",\"card_sales\":\"0.00\",\"expenses\":\"200.00\"}', 'New', '2026-02-08 14:28:54'),
(3, 1, 'admin', '2026-02-08 19:30:34', '2026-02-08 20:03:04', 614.35, 614.35, 0.00, 970.00, -355.65, 8, 0, 0.00, 0.00, -355.65, 1000.00, 1355.65, '{\"start_cash\":0,\"cash_sales\":\"614.35\",\"card_sales\":\"0.00\",\"expenses\":\"970.00\"}', '', '2026-02-08 15:03:04'),
(4, 1, 'admin', '2026-02-08 20:04:45', '2026-02-10 02:59:08', 2582.70, 2582.70, 0.00, 3000.00, -417.30, 24, 0, 0.00, 0.00, -417.30, 3000.00, 3417.30, '{\"start_cash\":0,\"cash_sales\":\"2582.70\",\"card_sales\":\"0.00\",\"expenses\":\"3000.00\"}', '', '2026-02-09 21:59:08'),
(5, 1, 'admin', '2026-02-10 02:59:43', '2026-02-10 03:00:42', 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0.00, 0.00, 0.00, 0.00, 0.00, '{\"start_cash\":0,\"cash_sales\":\"0.00\",\"card_sales\":\"0.00\",\"expenses\":\"0.00\"}', '', '2026-02-09 22:00:42'),
(6, 1, 'admin', '2026-02-10 03:01:23', '2026-02-10 03:37:00', 345.00, 345.00, 0.00, 3500.00, -3155.00, 6, 0, 0.00, 0.00, -3155.00, 2000.00, 5155.00, '{\"start_cash\":0,\"cash_sales\":\"345.00\",\"card_sales\":\"0.00\",\"expenses\":\"3500.00\"}', '', '2026-02-09 22:37:00'),
(7, 1, 'admin', '2026-02-10 05:34:25', '2026-02-10 06:35:08', 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0.00, 0.00, 0.00, 2000.00, 2000.00, '{\"start_cash\":0,\"cash_sales\":\"0.00\",\"card_sales\":\"0.00\",\"expenses\":\"0.00\"}', '', '2026-02-10 01:35:08');

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
(6, 4, -1.000, 47.000, 'sale', 'order', 1, 'System', NULL, '2026-02-07 23:32:12'),
(7, 1, -1.000, 96.000, 'sale', 'order', 2, 'System', NULL, '2026-02-08 13:51:12'),
(8, 2, -1.000, 46.000, 'sale', 'order', 2, 'System', NULL, '2026-02-08 13:51:12'),
(9, 3, -1.000, 197.000, 'sale', 'order', 2, 'System', NULL, '2026-02-08 13:51:12'),
(10, 4, -3.000, 44.000, 'sale', 'order', 3, 'System', NULL, '2026-02-08 13:51:45'),
(11, 1, -3.000, 93.000, 'sale', 'order', 3, 'System', NULL, '2026-02-08 13:51:45'),
(12, 2, -3.000, 43.000, 'sale', 'order', 3, 'System', NULL, '2026-02-08 13:51:45'),
(13, 1, -2.000, 91.000, 'sale', 'order', 3, 'System', NULL, '2026-02-08 13:51:45'),
(14, 2, -2.000, 41.000, 'sale', 'order', 3, 'System', NULL, '2026-02-08 13:51:45'),
(15, 3, -2.000, 195.000, 'sale', 'order', 3, 'System', NULL, '2026-02-08 13:51:45'),
(16, 5, -2.000, 498.000, 'sale', 'order', 3, 'System', NULL, '2026-02-08 13:51:45'),
(17, 1, -1.000, 90.000, 'sale', 'order', 5, 'System', NULL, '2026-02-08 14:30:58'),
(18, 2, -1.000, 40.000, 'sale', 'order', 5, 'System', NULL, '2026-02-08 14:30:58'),
(19, 3, -1.000, 194.000, 'sale', 'order', 5, 'System', NULL, '2026-02-08 14:30:58'),
(20, 1, -1.000, 89.000, 'sale', 'order', 5, 'System', NULL, '2026-02-08 14:30:58'),
(21, 2, -1.000, 39.000, 'sale', 'order', 5, 'System', NULL, '2026-02-08 14:30:58'),
(22, 4, -1.000, 43.000, 'sale', 'order', 5, 'System', NULL, '2026-02-08 14:30:58'),
(23, 5, -2.000, 496.000, 'sale', 'order', 5, 'System', NULL, '2026-02-08 14:30:58'),
(24, 1, -1.000, 88.000, 'sale', 'order', 6, 'System', NULL, '2026-02-08 14:59:05'),
(25, 2, -1.000, 38.000, 'sale', 'order', 6, 'System', NULL, '2026-02-08 14:59:05'),
(26, 3, -1.000, 193.000, 'sale', 'order', 6, 'System', NULL, '2026-02-08 14:59:05'),
(27, 1, -1.000, 87.000, 'sale', 'order', 6, 'System', NULL, '2026-02-08 14:59:05'),
(28, 2, -1.000, 37.000, 'sale', 'order', 6, 'System', NULL, '2026-02-08 14:59:05'),
(29, 1, -1.000, 86.000, 'sale', 'order', 7, 'System', NULL, '2026-02-08 14:59:15'),
(30, 2, -1.000, 36.000, 'sale', 'order', 7, 'System', NULL, '2026-02-08 14:59:15'),
(31, 3, -1.000, 192.000, 'sale', 'order', 7, 'System', NULL, '2026-02-08 14:59:15'),
(32, 1, -1.000, 85.000, 'sale', 'order', 8, 'System', NULL, '2026-02-08 14:59:24'),
(33, 2, -1.000, 35.000, 'sale', 'order', 8, 'System', NULL, '2026-02-08 14:59:24'),
(34, 3, -1.000, 191.000, 'sale', 'order', 8, 'System', NULL, '2026-02-08 14:59:24'),
(35, 1, -1.000, 84.000, 'sale', 'order', 8, 'System', NULL, '2026-02-08 14:59:24'),
(36, 2, -1.000, 34.000, 'sale', 'order', 8, 'System', NULL, '2026-02-08 14:59:24'),
(37, 4, -1.000, 42.000, 'sale', 'order', 8, 'System', NULL, '2026-02-08 14:59:24'),
(38, 1, -1.000, 83.000, 'sale', 'order', 9, 'System', NULL, '2026-02-08 14:59:32'),
(39, 2, -1.000, 33.000, 'sale', 'order', 9, 'System', NULL, '2026-02-08 14:59:32'),
(40, 3, -1.000, 190.000, 'sale', 'order', 9, 'System', NULL, '2026-02-08 14:59:32'),
(41, 1, -1.000, 82.000, 'sale', 'order', 9, 'System', NULL, '2026-02-08 14:59:32'),
(42, 2, -1.000, 32.000, 'sale', 'order', 9, 'System', NULL, '2026-02-08 14:59:32'),
(43, 4, -1.000, 41.000, 'sale', 'order', 9, 'System', NULL, '2026-02-08 14:59:32'),
(44, 1, -1.000, 81.000, 'sale', 'order', 10, 'System', NULL, '2026-02-08 14:59:48'),
(45, 2, -1.000, 31.000, 'sale', 'order', 10, 'System', NULL, '2026-02-08 14:59:48'),
(46, 3, -1.000, 189.000, 'sale', 'order', 10, 'System', NULL, '2026-02-08 14:59:48'),
(47, 1, -1.000, 80.000, 'sale', 'order', 10, 'System', NULL, '2026-02-08 14:59:48'),
(48, 2, -1.000, 30.000, 'sale', 'order', 10, 'System', NULL, '2026-02-08 14:59:48'),
(49, 4, -1.000, 40.000, 'sale', 'order', 10, 'System', NULL, '2026-02-08 14:59:48'),
(50, 5, -2.000, 494.000, 'sale', 'order', 10, 'System', NULL, '2026-02-08 14:59:48'),
(51, 1, -1.000, 79.000, 'sale', 'order', 11, 'System', NULL, '2026-02-08 15:00:03'),
(52, 2, -1.000, 29.000, 'sale', 'order', 11, 'System', NULL, '2026-02-08 15:00:03'),
(53, 3, -1.000, 188.000, 'sale', 'order', 11, 'System', NULL, '2026-02-08 15:00:03'),
(54, 1, -1.000, 78.000, 'sale', 'order', 11, 'System', NULL, '2026-02-08 15:00:03'),
(55, 2, -1.000, 28.000, 'sale', 'order', 11, 'System', NULL, '2026-02-08 15:00:03'),
(56, 4, -1.000, 39.000, 'sale', 'order', 11, 'System', NULL, '2026-02-08 15:00:03'),
(57, 5, -2.000, 492.000, 'sale', 'order', 12, 'System', NULL, '2026-02-08 15:00:18'),
(58, 4, -1.000, 38.000, 'sale', 'order', 12, 'System', NULL, '2026-02-08 15:00:18'),
(59, 1, -1.000, 77.000, 'sale', 'order', 12, 'System', NULL, '2026-02-08 15:00:18'),
(60, 2, -1.000, 27.000, 'sale', 'order', 12, 'System', NULL, '2026-02-08 15:00:18'),
(61, 1, -1.000, 76.000, 'sale', 'order', 12, 'System', NULL, '2026-02-08 15:00:18'),
(62, 2, -1.000, 26.000, 'sale', 'order', 12, 'System', NULL, '2026-02-08 15:00:18'),
(63, 3, -1.000, 187.000, 'sale', 'order', 12, 'System', NULL, '2026-02-08 15:00:18'),
(64, 1, -1.000, 75.000, 'sale', 'order', 13, 'System', NULL, '2026-02-08 15:05:05'),
(65, 2, -1.000, 25.000, 'sale', 'order', 13, 'System', NULL, '2026-02-08 15:05:05'),
(66, 3, -1.000, 186.000, 'sale', 'order', 13, 'System', NULL, '2026-02-08 15:05:05'),
(67, 1, -1.000, 74.000, 'sale', 'order', 13, 'System', NULL, '2026-02-08 15:05:05'),
(68, 2, -1.000, 24.000, 'sale', 'order', 13, 'System', NULL, '2026-02-08 15:05:05'),
(69, 5, -2.000, 490.000, 'sale', 'order', 13, 'System', NULL, '2026-02-08 15:05:05'),
(70, 4, 10.000, 48.000, 'restock', NULL, NULL, 'System', 'Stock In', '2026-02-08 15:42:08'),
(74, 1, -1.000, 73.000, 'sale', 'order', 14, 'System', NULL, '2026-02-08 16:02:26'),
(75, 2, -1.000, 23.000, 'sale', 'order', 14, 'System', NULL, '2026-02-08 16:02:26'),
(76, 3, -1.000, 185.000, 'sale', 'order', 14, 'System', NULL, '2026-02-08 16:02:26'),
(77, 1, -1.000, 72.000, 'sale', 'order', 14, 'System', NULL, '2026-02-08 16:02:26'),
(78, 2, -1.000, 22.000, 'sale', 'order', 14, 'System', NULL, '2026-02-08 16:02:26'),
(79, 9, 100.000, 100.000, 'restock', NULL, NULL, 'System', 'Stock In', '2026-02-08 19:28:33'),
(80, 1, -1.000, 71.000, 'sale', 'order', 15, 'System', NULL, '2026-02-08 19:44:27'),
(81, 2, -1.000, 21.000, 'sale', 'order', 15, 'System', NULL, '2026-02-08 19:44:27'),
(82, 3, -1.000, 184.000, 'sale', 'order', 15, 'System', NULL, '2026-02-08 19:44:27'),
(83, 1, -1.000, 70.000, 'sale', 'order', 15, 'System', NULL, '2026-02-08 19:44:27'),
(84, 2, -1.000, 20.000, 'sale', 'order', 15, 'System', NULL, '2026-02-08 19:44:27'),
(85, 9, -5.000, 95.000, 'sale', 'order', 15, 'System', NULL, '2026-02-08 19:44:27'),
(86, 10, 10.000, 10.000, 'restock', NULL, NULL, 'System', 'Stock In', '2026-02-08 19:47:10'),
(87, 10, -6.000, 4.000, 'sale', 'order', 16, 'System', NULL, '2026-02-08 19:47:52'),
(88, 10, -5.000, 0.000, 'sale', 'order', 17, 'System', NULL, '2026-02-08 19:48:12'),
(89, 10, -2.000, 0.000, 'sale', 'order', 18, 'System', NULL, '2026-02-08 19:48:40'),
(90, 10, 7.000, 7.000, 'restock', NULL, NULL, 'System', 'Stock In', '2026-02-08 19:59:44'),
(91, 10, -4.000, 3.000, 'sale', 'order', 19, 'System', NULL, '2026-02-08 20:00:00'),
(92, 10, -3.000, 0.000, 'sale', 'order', 20, 'System', NULL, '2026-02-08 20:00:42'),
(93, 1, -1.000, 69.000, 'sale', 'order', 4, 'System', NULL, '2026-02-08 20:34:02'),
(94, 2, -1.000, 19.000, 'sale', 'order', 4, 'System', NULL, '2026-02-08 20:34:02'),
(95, 10, -1.000, 0.000, 'sale', 'order', 4, 'System', NULL, '2026-02-08 20:34:02'),
(96, 9, -1.000, 94.000, 'sale', 'order', 4, 'System', NULL, '2026-02-08 20:34:02'),
(97, 1, -1.000, 68.000, 'sale', 'order', 23, 'System', NULL, '2026-02-08 20:34:34'),
(98, 2, -1.000, 18.000, 'sale', 'order', 23, 'System', NULL, '2026-02-08 20:34:34'),
(99, 3, -1.000, 183.000, 'sale', 'order', 23, 'System', NULL, '2026-02-08 20:34:34'),
(100, 9, -1.000, 93.000, 'sale', 'order', 23, 'System', NULL, '2026-02-08 20:34:34'),
(101, 1, -1.000, 67.000, 'sale', 'order', 24, 'System', NULL, '2026-02-08 20:36:53'),
(102, 2, -1.000, 17.000, 'sale', 'order', 24, 'System', NULL, '2026-02-08 20:36:53'),
(103, 3, -1.000, 182.000, 'sale', 'order', 24, 'System', NULL, '2026-02-08 20:36:53'),
(104, 5, -2.000, 488.000, 'sale', 'order', 24, 'System', NULL, '2026-02-08 20:36:53'),
(105, 1, -1.000, 66.000, 'sale', 'order', 21, 'System', NULL, '2026-02-08 22:02:29'),
(106, 2, -1.000, 16.000, 'sale', 'order', 21, 'System', NULL, '2026-02-08 22:02:30'),
(107, 3, -1.000, 181.000, 'sale', 'order', 21, 'System', NULL, '2026-02-08 22:02:30'),
(108, 5, -4.000, 484.000, 'sale', 'order', 21, 'System', NULL, '2026-02-08 22:02:30'),
(109, 1, -1.000, 65.000, 'sale', 'order', 22, 'System', NULL, '2026-02-08 22:02:56'),
(110, 2, -1.000, 15.000, 'sale', 'order', 22, 'System', NULL, '2026-02-08 22:02:56'),
(111, 3, -1.000, 180.000, 'sale', 'order', 22, 'System', NULL, '2026-02-08 22:02:56'),
(112, 5, -2.000, 482.000, 'sale', 'order', 22, 'System', NULL, '2026-02-08 22:02:56'),
(113, 1, -1.000, 64.000, 'sale', 'order', 45, 'System', NULL, '2026-02-08 23:55:27'),
(114, 2, -1.000, 14.000, 'sale', 'order', 45, 'System', NULL, '2026-02-08 23:55:27'),
(115, 3, -1.000, 179.000, 'sale', 'order', 45, 'System', NULL, '2026-02-08 23:55:27'),
(116, 9, -1.000, 92.000, 'sale', 'order', 45, 'System', NULL, '2026-02-08 23:55:27'),
(117, 1, -1.000, 63.000, 'sale', 'order', 45, 'System', NULL, '2026-02-08 23:55:27'),
(118, 2, -1.000, 13.000, 'sale', 'order', 45, 'System', NULL, '2026-02-08 23:55:27'),
(119, 9, -1.000, 91.000, 'sale', 'order', 46, 'System', NULL, '2026-02-08 23:55:50'),
(120, 1, -1.000, 62.000, 'sale', 'order', 46, 'System', NULL, '2026-02-08 23:55:50'),
(121, 2, -1.000, 12.000, 'sale', 'order', 46, 'System', NULL, '2026-02-08 23:55:50'),
(122, 5, -2.000, 480.000, 'sale', 'order', 46, 'System', NULL, '2026-02-08 23:55:50'),
(123, 5, -2.000, 478.000, 'sale', 'order', 44, 'System', NULL, '2026-02-08 23:57:39'),
(124, 1, -1.000, 61.000, 'sale', 'order', 48, 'System', NULL, '2026-02-08 23:59:52'),
(125, 2, -1.000, 11.000, 'sale', 'order', 48, 'System', NULL, '2026-02-08 23:59:52'),
(126, 3, -1.000, 178.000, 'sale', 'order', 48, 'System', NULL, '2026-02-08 23:59:52'),
(127, 1, -1.000, 60.000, 'sale', 'order', 48, 'System', NULL, '2026-02-08 23:59:52'),
(128, 2, -1.000, 10.000, 'sale', 'order', 48, 'System', NULL, '2026-02-08 23:59:52'),
(129, 9, -1.000, 90.000, 'sale', 'order', 48, 'System', NULL, '2026-02-08 23:59:52'),
(130, 1, -1.000, 59.000, 'sale', 'order', 49, 'System', NULL, '2026-02-09 00:02:35'),
(131, 2, -1.000, 9.000, 'sale', 'order', 49, 'System', NULL, '2026-02-09 00:02:35'),
(132, 3, -1.000, 177.000, 'sale', 'order', 49, 'System', NULL, '2026-02-09 00:02:35'),
(133, 1, -1.000, 58.000, 'sale', 'order', 49, 'System', NULL, '2026-02-09 00:02:35'),
(134, 2, -1.000, 8.000, 'sale', 'order', 49, 'System', NULL, '2026-02-09 00:02:35'),
(135, 9, -1.000, 89.000, 'sale', 'order', 49, 'System', NULL, '2026-02-09 00:02:35'),
(136, 1, -4.000, 54.000, 'sale', 'order', 50, 'System', NULL, '2026-02-09 00:03:53'),
(137, 2, -4.000, 4.000, 'sale', 'order', 50, 'System', NULL, '2026-02-09 00:03:53'),
(138, 3, -4.000, 173.000, 'sale', 'order', 50, 'System', NULL, '2026-02-09 00:03:53'),
(139, 5, -2.000, 476.000, 'sale', 'order', 50, 'System', NULL, '2026-02-09 00:03:53'),
(140, 1, -1.000, 53.000, 'sale', 'order', 51, 'System', NULL, '2026-02-09 00:07:53'),
(141, 2, -1.000, 3.000, 'sale', 'order', 51, 'System', NULL, '2026-02-09 00:07:53'),
(142, 9, -1.000, 88.000, 'sale', 'order', 51, 'System', NULL, '2026-02-09 00:07:53'),
(143, 5, -2.000, 474.000, 'sale', 'order', 43, 'System', NULL, '2026-02-09 00:09:02'),
(144, 1, -1.000, 52.000, 'sale', 'order', 52, 'System', NULL, '2026-02-09 00:14:36'),
(145, 2, -1.000, 2.000, 'sale', 'order', 52, 'System', NULL, '2026-02-09 00:14:36'),
(146, 3, -1.000, 172.000, 'sale', 'order', 52, 'System', NULL, '2026-02-09 00:14:36'),
(147, 1, -1.000, 51.000, 'sale', 'order', 52, 'System', NULL, '2026-02-09 00:14:36'),
(148, 2, -1.000, 1.000, 'sale', 'order', 52, 'System', NULL, '2026-02-09 00:14:36'),
(149, 9, -1.000, 87.000, 'sale', 'order', 52, 'System', NULL, '2026-02-09 00:14:36'),
(150, 1, -1.000, 50.000, 'sale', 'order', 53, 'System', NULL, '2026-02-09 00:18:59'),
(151, 2, -1.000, 0.000, 'sale', 'order', 53, 'System', NULL, '2026-02-09 00:18:59'),
(152, 3, -1.000, 171.000, 'sale', 'order', 53, 'System', NULL, '2026-02-09 00:18:59'),
(153, 5, -2.000, 472.000, 'sale', 'order', 53, 'System', NULL, '2026-02-09 00:18:59'),
(154, 9, -2.000, 85.000, 'sale', 'order', 54, 'System', NULL, '2026-02-09 00:19:23'),
(155, 1, -1.000, 49.000, 'sale', 'order', 47, 'System', NULL, '2026-02-09 00:20:31'),
(156, 2, -1.000, 0.000, 'sale', 'order', 47, 'System', NULL, '2026-02-09 00:20:31'),
(157, 3, -1.000, 170.000, 'sale', 'order', 47, 'System', NULL, '2026-02-09 00:20:31'),
(158, 1, -1.000, 48.000, 'sale', 'order', 47, 'System', NULL, '2026-02-09 00:20:31'),
(159, 2, -1.000, 0.000, 'sale', 'order', 47, 'System', NULL, '2026-02-09 00:20:31'),
(160, 9, -1.000, 84.000, 'sale', 'order', 47, 'System', NULL, '2026-02-09 00:20:31'),
(161, 11, 100.000, 100.000, 'restock', NULL, NULL, 'System', 'Stock In', '2026-02-09 15:54:59'),
(162, 5, -2.000, 470.000, 'sale', 'order', 55, 'System', NULL, '2026-02-09 22:02:00'),
(163, 9, -1.000, 83.000, 'sale', 'order', 56, 'System', NULL, '2026-02-09 22:02:42'),
(164, 5, -2.000, 468.000, 'sale', 'order', 57, 'System', NULL, '2026-02-09 22:06:45'),
(165, 9, -1.000, 82.000, 'sale', 'order', 58, 'System', NULL, '2026-02-09 22:06:49'),
(166, 10, 100.000, 100.000, 'restock', NULL, NULL, 'System', 'Stock In', '2026-02-10 00:44:07'),
(170, 10, -5.000, 95.000, 'sale', 'order', 68, 'System', NULL, '2026-02-10 02:25:15'),
(171, 10, 5.000, 100.000, 'return', 'order', 68, 'System', NULL, '2026-02-10 02:25:57');

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

--
-- Dumping data for table `suppliers`
--

INSERT INTO `suppliers` (`id`, `name`, `contact`, `email`, `address`, `is_active`, `created_at`) VALUES
(2, 'Frances Rodgers', 'Numquam', 'vumubyquh@mailinator.com', 'Hyd', 1, '2026-02-08 16:08:03'),
(3, 'Hoyt Chase', 'Itaque qui ad quisqu', 'lisybiq@mailinator.com', 'Qasimabad', 1, '2026-02-08 16:08:24');

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
(1, 'admin', '$2y$10$4RO6ZYS.ywzlf0PRTfY6.uOq0IyCza7yztOFPo.tthKpXhfwVYvLq', 'Administrator', 'admin', 1, NULL, '2026-02-07 23:31:14', '2026-02-09 20:36:36'),
(2, 'cashier', '$2y$10$I2YT/gPbmvGiYEAATwIxve7fU8kUIElCKKK1Vd34rgQgbTGjGDmhO', 'Main Cashier', 'cashier', 1, NULL, '2026-02-07 23:31:14', '2026-02-10 00:32:40');

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
  ADD KEY `idx_table_status` (`status`),
  ADD KEY `restaurant_tables_ibfk_1` (`waiter_id`),
  ADD KEY `restaurant_tables_ibfk_2` (`current_order_id`);

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

--
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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `expenses`
--
ALTER TABLE `expenses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `inventory`
--
ALTER TABLE `inventory`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=71;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=237;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `recipes`
--
ALTER TABLE `recipes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `restaurant_tables`
--
ALTER TABLE `restaurant_tables`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `settings`
--
ALTER TABLE `settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1198;

--
-- AUTO_INCREMENT for table `shifts`
--
ALTER TABLE `shifts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `shift_closings`
--
ALTER TABLE `shift_closings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `staff`
--
ALTER TABLE `staff`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `stock_logs`
--
ALTER TABLE `stock_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=172;

--
-- AUTO_INCREMENT for table `suppliers`
--
ALTER TABLE `suppliers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

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
-- Constraints for table `expenses`
--
ALTER TABLE `expenses`
  ADD CONSTRAINT `expenses_ibfk_1` FOREIGN KEY (`shift_id`) REFERENCES `shifts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `expenses_ibfk_2` FOREIGN KEY (`added_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

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
-- Constraints for table `restaurant_tables`
--
ALTER TABLE `restaurant_tables`
  ADD CONSTRAINT `restaurant_tables_ibfk_1` FOREIGN KEY (`waiter_id`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `restaurant_tables_ibfk_2` FOREIGN KEY (`current_order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `shifts`
--
ALTER TABLE `shifts`
  ADD CONSTRAINT `shifts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

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
