-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3307
-- Generation Time: Feb 12, 2026 at 03:13 AM
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
-- Database: `gustopos_new_test`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddColumnIfNotExists` (IN `tableName` VARCHAR(64), IN `columnName` VARCHAR(64), IN `columnCondition` VARCHAR(255))   BEGIN
    IF NOT EXISTS (
        SELECT * FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = tableName 
        AND COLUMN_NAME = columnName
    ) THEN
        SET @sql = CONCAT('ALTER TABLE `', tableName, '` ADD COLUMN `', columnName, '` ', columnCondition);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

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
(15, 1, 'OPEN_SHIFT', 'shifts', 8, 'Shift opened with start cash: 0', NULL, '2026-02-10 01:35:41'),
(16, 1, 'CLOSE_SHIFT', 'shifts', 8, 'Shift closed. Actual: 1000, Expected: 402', NULL, '2026-02-10 05:29:24'),
(17, 1, 'OPEN_SHIFT', 'shifts', 9, 'Shift opened with start cash: 0', NULL, '2026-02-10 05:29:36'),
(18, 1, 'CLOSE_SHIFT', 'shifts', 9, 'Shift closed. Actual: 0, Expected: 0', NULL, '2026-02-10 05:45:14'),
(19, 1, 'OPEN_SHIFT', 'shifts', 10, 'Shift opened with start cash: 0', NULL, '2026-02-10 05:45:40'),
(20, 1, 'CLOSE_SHIFT', 'shifts', 10, 'Shift closed. Actual: 0, Expected: 0', NULL, '2026-02-10 05:56:35'),
(21, 1, 'OPEN_SHIFT', 'shifts', 11, 'Shift opened with start cash: 0', NULL, '2026-02-10 05:56:42'),
(22, 1, 'CLOSE_SHIFT', 'shifts', 11, 'Shift closed. Actual: 0, Expected: 0', NULL, '2026-02-10 06:24:08'),
(23, 1, 'OPEN_SHIFT', 'shifts', 12, 'Shift opened with start cash: 0', NULL, '2026-02-10 06:24:14'),
(24, 1, 'CLOSE_SHIFT', 'shifts', 12, 'Shift closed. Actual: 500, Expected: 471.5', NULL, '2026-02-10 07:48:56'),
(25, 1, 'OPEN_SHIFT', 'shifts', 13, 'Shift opened with start cash: 0', NULL, '2026-02-10 07:49:10'),
(26, 1, 'CLOSE_SHIFT', 'shifts', 13, 'Shift closed. Actual: 2000, Expected: 1029.5', NULL, '2026-02-10 19:26:16'),
(27, 1, 'OPEN_SHIFT', 'shifts', 14, 'Shift opened with start cash: 0', NULL, '2026-02-11 11:27:50'),
(28, 1, 'CLOSE_SHIFT', 'shifts', 14, 'Shift closed. Actual: 100, Expected: 572', NULL, '2026-02-11 11:31:48'),
(29, 1, 'OPEN_SHIFT', 'shifts', 15, 'Shift opened with start cash: 0', NULL, '2026-02-11 11:31:59'),
(30, 1, 'CLOSE_SHIFT', 'shifts', 15, 'Shift closed. Actual: 1000, Expected: 165.5', NULL, '2026-02-11 11:33:25'),
(31, 1, 'OPEN_SHIFT', 'shifts', 16, 'Shift opened with start cash: 0', NULL, '2026-02-11 11:33:44'),
(32, 1, 'CLOSE_SHIFT', 'shifts', 16, 'Shift closed. Actual: 200, Expected: 3268.5', NULL, '2026-02-11 14:45:19'),
(33, 1, 'CLOSE_SHIFT', 'shifts', 17, 'Shift closed. Actual: 679, Expected: 2323.5', NULL, '2026-02-11 15:47:18'),
(34, 1, 'CLOSE_SHIFT', 'shifts', 18, 'Shift closed. Actual: 8, Expected: 0', NULL, '2026-02-11 15:47:26'),
(35, 1, 'CLOSE_SHIFT', 'shifts', 19, 'Shift closed. Actual: 8, Expected: 0', NULL, '2026-02-11 15:47:27'),
(36, 1, 'CLOSE_SHIFT', 'shifts', 20, 'Shift closed. Actual: 0, Expected: 3226.5', NULL, '2026-02-11 19:52:18'),
(37, 1, 'OPEN_SHIFT', 'shifts', 21, 'Shift opened with start cash: 0', NULL, '2026-02-11 19:52:47'),
(38, 1, 'CLOSE_SHIFT', 'shifts', 21, 'Shift closed. Actual: 76, Expected: 7280', NULL, '2026-02-11 20:22:08'),
(39, 1, 'OPEN_SHIFT', 'shifts', 22, 'Shift opened with start cash: 0', NULL, '2026-02-11 20:22:31'),
(40, 1, 'CLOSE_SHIFT', 'shifts', 22, 'Shift closed. Actual: 76, Expected: 456', NULL, '2026-02-11 21:00:05'),
(41, 1, 'OPEN_SHIFT', 'shifts', 23, 'Shift opened with start cash: 0', NULL, '2026-02-11 21:10:38'),
(42, 1, 'CLOSE_SHIFT', 'shifts', 23, 'Shift closed. Actual: 20000, Expected: 906', NULL, '2026-02-11 21:56:02');

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
(9, 6, 'Sequi quidem proiden', 'Other', 3500.00, 'approved', NULL, '2026-02-09 22:06:00'),
(10, 16, 'Biryani Akram', 'Utilities', 500.00, 'approved', NULL, '2026-02-11 11:54:55'),
(11, NULL, 'Biryani', 'Ingredients', 1000.00, 'approved', 1, '2026-02-11 23:44:15'),
(12, NULL, 'Qui et blanditiis ar', 'Ingredients', 84.00, 'approved', 1, '2026-02-12 00:02:33'),
(13, NULL, 'Porro at deserunt ut', 'Supplies', 600.00, 'approved', 1, '2026-02-12 00:29:19'),
(14, NULL, 'Hic facere est sint ', 'Utilities', 22.00, 'approved', 1, '2026-02-12 01:07:09');

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
(9, 'Coke 250ml', 'SKU-100', 'Pcs', 'Pcs', 1.000, 0.000, 10.000, 80.00, NULL, '2026-02-08 19:28:08', '2026-02-11 19:55:38'),
(10, 'Cakes', 'SKU-900', 'Pcs', 'Pcs', 1.000, 0.000, 5.000, 15.00, 3, '2026-02-08 19:46:54', '2026-02-11 19:53:16'),
(11, 'Aquafina', 'SKU-260209-8916', 'Pcs', 'Pcs', 1.000, 0.000, 10.000, 80.00, 2, '2026-02-09 15:54:26', '2026-02-12 01:52:14');

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
  `order_type_id` int(11) DEFAULT NULL,
  `payment_method` enum('cash','card','other') DEFAULT 'cash',
  `payment_method_id` int(11) DEFAULT NULL,
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
  `completed_at` datetime DEFAULT NULL,
  `payment_status` varchar(20) DEFAULT 'unpaid'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `order_number`, `token_number`, `shift_id`, `table_id`, `waiter_id`, `customer_name`, `order_type`, `order_type_id`, `payment_method`, `payment_method_id`, `subtotal`, `tax`, `service_charge`, `packaging_charge`, `delivery_fee`, `discount`, `total`, `status`, `is_bill_printed`, `void_type`, `deleted_by`, `delete_reason`, `created_at`, `completed_at`, `payment_status`) VALUES
(1, 'INV-1001', 0, 1, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 69.00, 6.90, 0.00, 1.00, 3.00, 0.00, 75.90, 'completed', 0, NULL, NULL, NULL, '2026-02-07 23:32:12', NULL, 'unpaid'),
(2, 'INV-1002', 0, 2, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 20.00, 2.00, 0.00, 1.00, 3.00, 0.00, 22.00, 'completed', 0, NULL, NULL, NULL, '2026-02-08 13:51:12', NULL, 'unpaid'),
(3, 'INV-1003', 0, 2, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 154.50, 2.10, 0.00, 1.00, 3.00, 0.00, 156.60, 'completed', 0, NULL, NULL, NULL, '2026-02-08 13:51:25', '2026-02-08 18:51:45', 'unpaid'),
(4, 'INV-1004', 0, 2, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 39.00, 3.90, 0.00, 1.00, 3.00, 0.00, 42.90, 'completed', 0, NULL, NULL, NULL, '2026-02-08 14:23:39', '2026-02-09 01:34:02', 'unpaid'),
(5, 'INV-1005', 0, 3, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 92.50, 9.25, 0.00, 1.00, 3.00, 0.00, 101.75, 'completed', 0, NULL, NULL, NULL, '2026-02-08 14:30:58', NULL, 'unpaid'),
(6, 'INV-1006', 0, 3, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 32.00, 3.20, 0.00, 1.00, 3.00, 0.00, 35.20, 'completed', 0, NULL, NULL, NULL, '2026-02-08 14:59:05', NULL, 'unpaid'),
(7, 'INV-1007', 0, 3, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 20.00, 2.00, 0.00, 1.00, 3.00, 0.00, 22.00, 'completed', 0, NULL, NULL, NULL, '2026-02-08 14:59:15', NULL, 'unpaid'),
(8, 'INV-1008', 0, 3, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 87.00, 8.70, 0.00, 1.00, 3.00, 0.00, 95.70, 'completed', 0, NULL, NULL, NULL, '2026-02-08 14:59:24', NULL, 'unpaid'),
(9, 'INV-1009', 0, 3, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 55.00, 5.50, 0.00, 1.00, 3.00, 0.00, 60.50, 'completed', 0, NULL, NULL, NULL, '2026-02-08 14:59:32', NULL, 'unpaid'),
(10, 'INV-1010', 0, 3, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 110.50, 11.05, 0.00, 1.00, 3.00, 0.00, 121.55, 'completed', 0, NULL, NULL, NULL, '2026-02-08 14:59:48', NULL, 'unpaid'),
(11, 'INV-1011', 0, 3, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 69.00, 6.90, 0.00, 1.00, 3.00, 0.00, 75.90, 'completed', 0, NULL, NULL, NULL, '2026-02-08 15:00:03', NULL, 'unpaid'),
(12, 'INV-1012', 0, 3, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 92.50, 9.25, 0.00, 1.00, 3.00, 0.00, 101.75, 'completed', 0, NULL, NULL, NULL, '2026-02-08 15:00:18', NULL, 'unpaid'),
(13, 'INV-1013', 0, 4, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 87.50, 8.75, 0.00, 1.00, 3.00, 0.00, 96.25, 'completed', 0, NULL, NULL, NULL, '2026-02-08 15:05:05', NULL, 'unpaid'),
(14, 'INV-1014', 0, 4, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 32.00, 3.20, 0.00, 1.00, 3.00, 0.00, 35.20, 'completed', 0, NULL, NULL, NULL, '2026-02-08 16:02:26', NULL, 'unpaid'),
(15, 'INV-1015', 0, 4, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 432.00, 43.20, 0.00, 1.00, 3.00, 0.00, 475.20, 'completed', 0, NULL, NULL, NULL, '2026-02-08 19:44:27', NULL, 'unpaid'),
(16, 'INV-1016', 0, 4, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 120.00, 12.00, 0.00, 1.00, 3.00, 0.00, 132.00, 'completed', 0, NULL, NULL, NULL, '2026-02-08 19:47:52', NULL, 'unpaid'),
(17, 'INV-1017', 0, 4, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 100.00, 10.00, 0.00, 1.00, 3.00, 0.00, 110.00, 'completed', 0, NULL, NULL, NULL, '2026-02-08 19:48:12', NULL, 'unpaid'),
(18, 'INV-1018', 0, 4, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 40.00, 4.00, 0.00, 1.00, 3.00, 0.00, 44.00, 'completed', 0, NULL, NULL, NULL, '2026-02-08 19:48:40', NULL, 'unpaid'),
(19, 'INV-1019', 0, 4, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 80.00, 8.00, 0.00, 1.00, 3.00, 0.00, 88.00, 'completed', 0, NULL, NULL, NULL, '2026-02-08 20:00:00', NULL, 'unpaid'),
(20, 'INV-1020', 0, 4, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 60.00, 6.00, 0.00, 1.00, 3.00, 0.00, 66.00, 'completed', 0, NULL, NULL, NULL, '2026-02-08 20:00:42', NULL, 'unpaid'),
(21, 'INV-1021', 0, 4, NULL, NULL, 'Cade Diaz (35 seats)', 'dine_in', 1, 'cash', 1, 96.00, 9.60, 0.00, 1.00, 3.00, 0.00, 105.60, 'completed', 0, NULL, NULL, NULL, '2026-02-08 20:33:54', '2026-02-09 03:02:29', 'unpaid'),
(22, 'INV-1022', 0, 4, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 55.50, 5.55, 0.00, 1.00, 3.00, 0.00, 61.05, 'completed', 0, NULL, NULL, NULL, '2026-02-08 20:34:22', '2026-02-09 03:02:56', 'unpaid'),
(23, 'INV-1023', 0, 4, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 114.00, 11.40, 0.00, 1.00, 3.00, 0.00, 125.40, 'completed', 0, NULL, NULL, NULL, '2026-02-08 20:34:34', NULL, 'unpaid'),
(24, 'INV-1024', 0, 4, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 37.50, 0.00, 0.00, 0.00, 0.00, 0.00, 37.50, 'completed', 0, NULL, NULL, NULL, '2026-02-08 20:36:53', NULL, 'unpaid'),
(43, 'INV-1043', 0, 4, 12, NULL, 'T-04 (6 seats)', 'dine_in', 1, 'cash', 1, 39.50, 0.00, 0.00, 0.00, 0.00, 0.00, 39.50, 'completed', 0, NULL, NULL, NULL, '2026-02-08 22:53:04', '2026-02-09 05:09:02', 'unpaid'),
(44, 'INV-1044', 0, 4, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 23.50, 0.00, 0.00, 0.00, 0.00, 0.00, 23.50, 'completed', 0, NULL, NULL, NULL, '2026-02-08 22:57:41', '2026-02-09 04:57:39', 'unpaid'),
(45, 'INV-1045', 0, 4, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 126.00, 0.00, 0.00, 0.00, 0.00, 0.00, 126.00, 'completed', 0, NULL, NULL, NULL, '2026-02-08 23:55:27', NULL, 'unpaid'),
(46, 'INV-1046', 0, 4, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 131.50, 0.00, 0.00, 0.00, 0.00, 0.00, 131.50, 'completed', 0, NULL, NULL, NULL, '2026-02-08 23:55:50', NULL, 'unpaid'),
(47, 'INV-1047', 0, 4, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 122.00, 0.00, 0.00, 0.00, 0.00, 0.00, 122.00, 'completed', 0, NULL, NULL, NULL, '2026-02-08 23:59:45', '2026-02-09 05:20:30', 'unpaid'),
(48, 'INV-1048', 0, 4, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 122.00, 0.00, 0.00, 0.00, 0.00, 0.00, 122.00, 'completed', 0, NULL, NULL, NULL, '2026-02-08 23:59:52', NULL, 'unpaid'),
(49, 'INV-1049', 0, 4, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 106.00, 0.00, 0.00, 0.00, 0.00, 0.00, 106.00, 'completed', 0, NULL, NULL, NULL, '2026-02-09 00:02:35', NULL, 'unpaid'),
(50, 'INV-1050', 0, 4, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 72.50, 0.00, 0.00, 0.00, 0.00, 0.00, 72.50, 'completed', 0, NULL, NULL, NULL, '2026-02-09 00:03:53', NULL, 'unpaid'),
(51, 'INV-1051', 0, 4, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 108.00, 0.00, 0.00, 0.00, 0.00, 0.00, 108.00, 'completed', 0, NULL, NULL, NULL, '2026-02-09 00:07:53', NULL, 'unpaid'),
(52, 'INV-1052', 0, 4, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 122.00, 0.00, 0.00, 0.00, 0.00, 0.00, 122.00, 'completed', 0, NULL, NULL, NULL, '2026-02-09 00:14:36', NULL, 'unpaid'),
(53, 'INV-1053', 0, 4, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 33.50, 0.00, 0.00, 0.00, 0.00, 0.00, 33.50, 'completed', 0, NULL, NULL, NULL, '2026-02-09 00:18:59', NULL, 'unpaid'),
(54, 'INV-1054', 0, 4, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 200.00, 0.00, 0.00, 0.00, 0.00, 0.00, 200.00, 'completed', 0, NULL, NULL, NULL, '2026-02-09 00:19:23', NULL, 'unpaid'),
(55, 'INV-1055', 0, 6, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 19.50, 0.00, 0.00, 0.00, 0.00, 0.00, 19.50, 'completed', 0, NULL, NULL, NULL, '2026-02-09 22:02:00', NULL, 'unpaid'),
(56, 'INV-1056', 0, 6, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 96.00, 0.00, 0.00, 0.00, 0.00, 0.00, 96.00, 'completed', 0, NULL, NULL, NULL, '2026-02-09 22:02:42', NULL, 'unpaid'),
(57, 'INV-1057', 0, 6, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 19.50, 0.00, 0.00, 0.00, 0.00, 0.00, 19.50, 'completed', 0, NULL, NULL, NULL, '2026-02-09 22:06:45', NULL, 'unpaid'),
(58, 'INV-1058', 0, 6, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 144.00, 0.00, 0.00, 0.00, 0.00, 0.00, 144.00, 'completed', 0, NULL, NULL, NULL, '2026-02-09 22:06:49', NULL, 'unpaid'),
(59, 'INV-1059', 0, 6, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 30.00, 0.00, 0.00, 0.00, 0.00, 0.00, 30.00, 'completed', 0, NULL, NULL, NULL, '2026-02-09 22:06:59', NULL, 'unpaid'),
(60, 'INV-1060', 0, 6, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 36.00, 0.00, 0.00, 0.00, 0.00, 0.00, 36.00, 'completed', 0, NULL, NULL, NULL, '2026-02-09 22:07:03', NULL, 'unpaid'),
(61, 'INV-1061', 0, 7, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 14.00, 0.00, 0.00, 0.00, 0.00, 0.00, 14.00, '', 0, NULL, NULL, 'West', '2026-02-10 00:45:50', NULL, 'unpaid'),
(64, 'INV-1064', 0, 7, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 96.00, 0.00, 0.00, 0.00, 0.00, 0.00, 96.00, 'completed', 0, NULL, NULL, NULL, '2026-02-10 01:32:06', '2026-02-10 10:31:03', 'unpaid'),
(65, 'INV-1065', 0, 7, 12, NULL, 'T-12 (8 seats)', 'dine_in', 1, 'cash', 1, 40.00, 0.00, 0.00, 0.00, 0.00, 0.00, 40.00, 'completed', 0, NULL, NULL, NULL, '2026-02-10 01:32:14', '2026-02-10 11:08:03', 'paid'),
(66, 'INV-1066', 0, 8, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 302.00, 0.00, 0.00, 0.00, 0.00, 0.00, 302.00, 'completed', 0, NULL, NULL, NULL, '2026-02-10 01:36:14', NULL, 'unpaid'),
(67, 'INV-1067', 0, 8, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 100.00, 0.00, 0.00, 0.00, 0.00, 0.00, 100.00, 'completed', 0, NULL, NULL, NULL, '2026-02-10 02:24:00', NULL, 'unpaid'),
(68, 'INV-1068', 0, 8, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 100.00, 0.00, 0.00, 0.00, 0.00, 0.00, 100.00, '', 0, NULL, NULL, 'Nothing ', '2026-02-10 02:25:15', NULL, 'unpaid'),
(69, 'INV-1069', 0, 8, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 30.00, 0.00, 0.00, 0.00, 0.00, 0.00, 30.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 03:46:52', NULL, 'unpaid'),
(70, 'INV-1070', 0, 8, NULL, NULL, 'Walk-in', '', NULL, 'cash', 1, 15.00, 0.00, 0.00, 0.00, 0.00, 0.00, 15.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 03:46:59', NULL, 'unpaid'),
(71, 'INV-260210-3815', 1, 8, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 46.00, 0.00, 0.00, 0.00, 0.00, 0.00, 46.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 04:11:34', NULL, 'unpaid'),
(72, 'INV-260210-4093', 2, 8, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 32.00, 0.00, 0.00, 0.00, 0.00, 0.00, 32.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 04:17:51', NULL, 'unpaid'),
(73, 'INV-260210-2084', 3, 8, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 146.00, 0.00, 0.00, 0.00, 0.00, 0.00, 146.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 04:26:12', NULL, 'unpaid'),
(74, 'INV-260210-7520', 4, 8, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 20.00, 0.00, 0.00, 0.00, 0.00, 0.00, 20.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 04:34:37', NULL, 'unpaid'),
(75, 'INV-260210-3304', 5, 8, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 134.50, 0.00, 0.00, 0.00, 0.00, 0.00, 134.50, 'pending', 0, NULL, NULL, NULL, '2026-02-10 04:44:47', NULL, 'unpaid'),
(76, 'INV-260210-7391', 1, 9, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 46.00, 0.00, 0.00, 0.00, 0.00, 0.00, 46.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 05:30:05', NULL, 'unpaid'),
(77, 'INV-260210-9930', 2, 9, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 32.00, 0.00, 0.00, 0.00, 0.00, 0.00, 32.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 05:30:57', NULL, 'unpaid'),
(78, 'INV-260210-1800', 3, 9, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 126.00, 0.00, 0.00, 0.00, 0.00, 0.00, 126.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 05:39:17', NULL, 'unpaid'),
(79, 'INV-260210-1072', 4, 9, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 130.00, 0.00, 0.00, 0.00, 0.00, 0.00, 130.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 05:40:58', NULL, 'unpaid'),
(80, 'INV-260210-4355', 5, 9, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 23.50, 0.00, 0.00, 0.00, 0.00, 0.00, 23.50, 'pending', 0, NULL, NULL, NULL, '2026-02-10 05:41:12', NULL, 'unpaid'),
(81, 'INV-260210-2510', 6, 9, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 60.00, 0.00, 0.00, 0.00, 0.00, 0.00, 60.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 05:42:08', NULL, 'unpaid'),
(82, 'INV-260210-2875', 7, 9, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 60.00, 0.00, 0.00, 0.00, 0.00, 0.00, 60.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 05:42:19', NULL, 'unpaid'),
(83, 'INV-260210-5780', 8, 9, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 156.00, 0.00, 0.00, 0.00, 0.00, 0.00, 156.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 05:42:42', NULL, 'unpaid'),
(84, 'INV-260210-4654', 9, 9, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 60.00, 0.00, 0.00, 0.00, 0.00, 0.00, 60.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 05:42:53', NULL, 'unpaid'),
(85, 'INV-260210-3275', 10, 9, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 60.00, 0.00, 0.00, 0.00, 0.00, 0.00, 60.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 05:44:23', NULL, 'unpaid'),
(86, 'INV-260210-1804', 1, 10, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 46.00, 0.00, 0.00, 0.00, 0.00, 0.00, 46.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 05:45:43', NULL, 'unpaid'),
(87, 'INV-260210-9884', 1, 11, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 46.00, 0.00, 0.00, 0.00, 0.00, 0.00, 46.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 06:06:58', NULL, 'unpaid'),
(88, 'INV-260210-5795', 2, 11, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 23.50, 0.00, 0.00, 0.00, 0.00, 0.00, 23.50, 'pending', 0, NULL, NULL, NULL, '2026-02-10 06:07:43', NULL, 'unpaid'),
(89, 'INV-260210-6053', 3, 11, NULL, NULL, 'Walk-in', 'dine_in', NULL, 'cash', NULL, 112.00, 0.00, 0.00, 0.00, 0.00, 0.00, 112.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 06:07:50', NULL, 'unpaid'),
(90, 'INV-260210-5757', 4, 11, NULL, NULL, 'Walk-in', 'dine_in', NULL, 'cash', NULL, 112.00, 0.00, 0.00, 0.00, 0.00, 0.00, 112.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 06:07:52', NULL, 'unpaid'),
(91, 'INV-260210-4448', 5, 11, NULL, NULL, 'Walk-in', 'dine_in', NULL, 'cash', NULL, 112.00, 0.00, 0.00, 0.00, 0.00, 0.00, 112.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 06:07:52', NULL, 'unpaid'),
(92, 'INV-260210-1061', 6, 11, NULL, NULL, 'Walk-in', 'dine_in', NULL, 'cash', NULL, 112.00, 0.00, 0.00, 0.00, 0.00, 0.00, 112.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 06:07:57', NULL, 'unpaid'),
(93, 'INV-260210-5223', 7, 11, NULL, NULL, 'Walk-in', 'dine_in', NULL, 'cash', NULL, 112.00, 0.00, 0.00, 0.00, 0.00, 0.00, 112.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 06:07:57', NULL, 'unpaid'),
(94, 'INV-260210-4179', 8, 11, NULL, NULL, 'Walk-in', 'dine_in', NULL, 'cash', NULL, 112.00, 0.00, 0.00, 0.00, 0.00, 0.00, 112.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 06:07:57', NULL, 'unpaid'),
(95, 'INV-260210-9037', 9, 11, 12, NULL, 'T-12 (8 seats)', 'dine_in', NULL, 'cash', NULL, 100.00, 0.00, 0.00, 0.00, 0.00, 0.00, 100.00, 'completed', 0, NULL, NULL, NULL, '2026-02-10 06:08:33', '2026-02-11 16:53:36', 'paid'),
(96, 'INV-260210-6624', 10, 11, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 100.00, 0.00, 0.00, 0.00, 0.00, 0.00, 100.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 06:08:44', NULL, 'unpaid'),
(97, 'INV-260210-8769', 11, 11, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 112.00, 0.00, 0.00, 0.00, 0.00, 0.00, 112.00, 'pending', 0, NULL, NULL, NULL, '2026-02-10 06:22:39', NULL, 'unpaid'),
(98, 'INV-260210-5642', 1, 12, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 42.00, 0.00, 0.00, 0.00, 0.00, 0.00, 42.00, 'completed', 0, NULL, NULL, NULL, '2026-02-10 06:24:19', '2026-02-10 11:24:19', 'paid'),
(99, 'INV-260210-7709', 2, 12, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 126.00, 0.00, 0.00, 0.00, 0.00, 0.00, 126.00, 'completed', 0, NULL, NULL, NULL, '2026-02-10 06:34:44', '2026-02-10 07:34:44', 'paid'),
(100, 'INV-260210-5480', 3, 12, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 183.50, 0.00, 0.00, 0.00, 0.00, 0.00, 183.50, 'completed', 0, NULL, NULL, NULL, '2026-02-10 06:34:59', '2026-02-10 07:34:59', 'paid'),
(101, 'INV-260210-4557', 4, 12, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 120.00, 0.00, 0.00, 0.00, 0.00, 0.00, 120.00, 'completed', 0, NULL, NULL, NULL, '2026-02-10 06:35:24', '2026-02-10 07:35:24', 'paid'),
(102, 'INV-260210-9577', 1, 13, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 183.50, 0.00, 0.00, 0.00, 0.00, 0.00, 183.50, 'completed', 0, NULL, NULL, NULL, '2026-02-10 08:32:40', '2026-02-10 09:32:40', 'paid'),
(103, 'INV-260210-4902', 2, 13, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 60.00, 0.00, 0.00, 0.00, 0.00, 0.00, 60.00, 'completed', 0, NULL, NULL, NULL, '2026-02-10 16:48:02', '2026-02-10 17:48:02', 'paid'),
(104, 'INV-260210-3514', 3, 13, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 60.00, 0.00, 0.00, 0.00, 0.00, 0.00, 60.00, 'completed', 0, NULL, NULL, NULL, '2026-02-10 16:48:19', '2026-02-10 17:48:19', 'paid'),
(105, 'INV-260210-2684', 4, 13, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 126.00, 0.00, 0.00, 0.00, 0.00, 0.00, 126.00, 'completed', 0, NULL, NULL, NULL, '2026-02-10 18:14:19', '2026-02-10 19:14:19', 'paid'),
(106, 'INV-260210-6946', 5, 13, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 600.00, 0.00, 0.00, 0.00, 0.00, 0.00, 600.00, 'completed', 0, NULL, NULL, NULL, '2026-02-10 19:23:05', '2026-02-10 20:23:05', 'paid'),
(107, 'INV-260211-4272', 1, 14, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 146.00, 0.00, 0.00, 0.00, 0.00, 0.00, 146.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 11:27:59', '2026-02-11 12:27:59', 'paid'),
(108, 'INV-260211-7832', 2, 14, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 142.00, 0.00, 0.00, 0.00, 0.00, 0.00, 142.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 11:28:13', '2026-02-11 12:28:13', 'paid'),
(109, 'INV-260211-6040', 3, 14, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 142.00, 0.00, 0.00, 0.00, 0.00, 0.00, 142.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 11:28:22', '2026-02-11 12:28:22', 'paid'),
(110, 'INV-260211-5446', 4, 14, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 142.00, 0.00, 0.00, 0.00, 0.00, 0.00, 142.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 11:30:16', '2026-02-11 12:30:16', 'paid'),
(111, 'INV-260211-8995', 1, 15, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 165.50, 0.00, 0.00, 0.00, 0.00, 0.00, 165.50, 'completed', 0, NULL, NULL, NULL, '2026-02-11 11:32:12', '2026-02-11 12:32:12', 'paid'),
(112, 'INV-260211-9861', 1, 16, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 126.00, 0.00, 0.00, 0.00, 0.00, 0.00, 126.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 11:33:53', '2026-02-11 12:33:53', 'paid'),
(113, 'INV-260211-7576', 2, 16, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 120.00, 0.00, 0.00, 0.00, 0.00, 0.00, 120.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 11:34:48', '2026-02-11 12:34:48', 'paid'),
(114, 'INV-260211-2962', 3, 16, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 11400.00, 0.00, 0.00, 0.00, 0.00, 0.00, 11400.00, '', 0, NULL, NULL, 'return', '2026-02-11 11:40:32', '2026-02-11 12:40:32', 'paid'),
(115, 'INV-260211-9174', 4, 16, 1, NULL, 'T-01 (4 seats)', 'dine_in', NULL, 'cash', NULL, 391.50, 0.00, 0.00, 0.00, 0.00, 0.00, 391.50, 'completed', 0, NULL, NULL, NULL, '2026-02-11 11:47:01', '2026-02-11 16:50:01', 'paid'),
(116, 'INV-260211-4454', 5, 16, 5, NULL, 'T-01 (4 seats)', 'dine_in', NULL, 'cash', NULL, 391.50, 0.00, 0.00, 0.00, 0.00, 0.00, 391.50, 'completed', 0, NULL, NULL, NULL, '2026-02-11 11:47:33', '2026-02-11 16:48:02', 'paid'),
(117, 'INV-260211-4249', 6, 16, 1, NULL, 'T-01 (4 seats)', 'dine_in', NULL, 'cash', NULL, 154.00, 0.00, 0.00, 0.00, 0.00, 0.00, 154.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 11:49:49', '2026-02-11 16:50:15', 'paid'),
(118, 'INV-260211-3275', 7, 16, 1, NULL, 'T-01 (4 seats)', 'dine_in', NULL, 'cash', NULL, 154.00, 0.00, 0.00, 0.00, 0.00, 0.00, 154.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 11:49:56', '2026-02-11 16:50:20', 'paid'),
(119, 'INV-260211-0247', 8, 16, 1, NULL, 'T-01 (4 seats)', 'dine_in', NULL, 'cash', NULL, 134.00, 0.00, 0.00, 0.00, 0.00, 0.00, 134.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 11:50:38', '2026-02-11 16:50:49', 'paid'),
(120, 'INV-260211-2318', 9, 16, 1, NULL, 'T-01 (4 seats)', 'dine_in', NULL, 'cash', NULL, 134.00, 0.00, 0.00, 0.00, 0.00, 0.00, 134.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 11:50:45', '2026-02-11 16:51:19', 'paid'),
(121, 'INV-260211-1468', 10, 16, 1, NULL, 'T-01 (4 seats)', 'dine_in', NULL, 'cash', NULL, 168.00, 0.00, 0.00, 0.00, 0.00, 0.00, 168.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 11:52:02', '2026-02-11 16:52:21', 'paid'),
(122, 'INV-260211-5857', 11, 16, 1, NULL, 'T-01 (4 seats)', 'dine_in', NULL, 'cash', NULL, 400.00, 0.00, 0.00, 0.00, 0.00, 0.00, 400.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 11:52:18', '2026-02-11 17:47:40', 'paid'),
(123, 'INV-260211-8524', 12, 16, 11, NULL, 'T-11 (4 seats)', 'dine_in', NULL, 'cash', NULL, 34.00, 0.00, 0.00, 0.00, 0.00, 0.00, 34.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 11:52:39', '2026-02-11 17:04:20', 'paid'),
(124, 'INV-260211-5798', 13, 16, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 34.00, 0.00, 0.00, 0.00, 0.00, 0.00, 34.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 11:52:51', '2026-02-11 12:52:51', 'paid'),
(125, 'INV-260211-1674', 14, 16, 9, NULL, 'T-09 (4 seats)', 'dine_in', NULL, 'cash', NULL, 34.00, 0.00, 0.00, 0.00, 0.00, 0.00, 34.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 11:53:06', '2026-02-11 16:53:22', 'paid'),
(126, 'INV-260211-3542', 15, 16, 9, NULL, 'T-09 (4 seats)', 'dine_in', NULL, 'cash', NULL, 19.50, 0.00, 0.00, 0.00, 0.00, 0.00, 19.50, 'completed', 0, NULL, NULL, NULL, '2026-02-11 11:53:19', '2026-02-11 16:53:28', 'paid'),
(127, 'INV-260211-5083', 16, 16, 11, NULL, 'T-11 (4 seats)', 'dine_in', NULL, 'cash', NULL, 152.00, 0.00, 0.00, 0.00, 0.00, 0.00, 152.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 12:04:15', '2026-02-11 17:04:26', 'paid'),
(128, 'INV-260211-9437', 17, 16, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 134.00, 0.00, 0.00, 0.00, 0.00, 0.00, 134.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 12:27:44', '2026-02-11 13:27:44', 'paid'),
(129, 'INV-260211-0634', 18, 16, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 34.00, 0.00, 0.00, 0.00, 0.00, 0.00, 34.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 12:28:35', '2026-02-11 13:28:35', 'paid'),
(130, 'INV-260211-0502', 19, 16, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 120.00, 0.00, 0.00, 0.00, 0.00, 0.00, 120.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 12:29:20', '2026-02-11 13:29:20', 'paid'),
(131, 'INV-260211-6756', 20, 16, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 380.00, 0.00, 0.00, 0.00, 0.00, 0.00, 380.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 12:29:25', '2026-02-11 13:29:25', 'paid'),
(132, 'INV-260211-9790', 21, 16, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 48.00, 0.00, 0.00, 0.00, 0.00, 0.00, 48.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 12:29:29', '2026-02-11 13:29:29', 'paid'),
(133, 'INV-260211-0053', 22, 16, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 42.00, 0.00, 0.00, 0.00, 0.00, 0.00, 42.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 12:29:33', '2026-02-11 13:29:33', 'paid'),
(134, 'INV-260211-3261', 23, 16, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 360.00, 0.00, 0.00, 0.00, 0.00, 0.00, 360.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 12:29:38', '2026-02-11 13:29:38', 'paid'),
(135, 'INV-260211-6322', 24, 16, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 34.00, 0.00, 0.00, 0.00, 0.00, 0.00, 34.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 12:47:12', '2026-02-11 13:47:12', 'paid'),
(136, 'INV-260211-8197', 25, 16, 1, NULL, 'T-01 (4 seats)', 'dine_in', NULL, 'cash', NULL, 28.00, 0.00, 0.00, 0.00, 0.00, 0.00, 28.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 12:47:24', '2026-02-11 17:47:46', 'paid'),
(137, 'INV-260211-6004', 26, 16, 1, NULL, 'T-01 (4 seats)', 'dine_in', NULL, 'cash', NULL, 42.00, 0.00, 0.00, 0.00, 0.00, 0.00, 42.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 12:47:31', '2026-02-11 19:32:05', 'paid'),
(138, 'INV-260211-8843', 27, 16, 1, NULL, 'T-01 (4 seats)', 'dine_in', NULL, 'cash', NULL, 100.00, 0.00, 0.00, 0.00, 0.00, 0.00, 100.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 12:47:37', '2026-02-11 19:32:10', 'paid'),
(147, 'TEST-TODAY', 1001, 20, NULL, NULL, 'Test User', 'dine_in', 3, 'cash', 2, 80.00, 0.00, 0.00, 0.00, 0.00, 0.00, 100.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 09:59:18', '2026-02-11 14:59:18', 'paid'),
(148, 'TEST-YESTERDAY', 1002, 20, NULL, NULL, 'Test User', 'dine_in', 3, 'cash', 2, 40.00, 0.00, 0.00, 0.00, 0.00, 0.00, 50.00, 'completed', 0, NULL, NULL, NULL, '2026-02-10 09:59:18', '2026-02-10 14:59:18', 'paid'),
(149, 'INV-260211-1999', 1003, 20, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 40.00, 0.00, 0.00, 0.00, 0.00, 0.00, 40.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 14:26:37', '2026-02-11 15:26:37', 'paid'),
(150, 'INV-260211-5512', 1004, 20, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 28.00, 0.00, 0.00, 0.00, 0.00, 0.00, 28.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 14:26:56', '2026-02-11 15:26:56', 'paid'),
(151, 'INV-260211-6758', 1005, 20, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 36.00, 0.00, 0.00, 0.00, 0.00, 0.00, 36.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 14:27:16', '2026-02-11 15:27:16', 'paid'),
(152, 'INV-260211-9114', 1006, 20, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 8.00, 0.00, 0.00, 0.00, 0.00, 0.00, 8.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 14:27:25', '2026-02-11 15:27:25', 'paid'),
(153, 'INV-260211-7122', 1007, 20, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 42.00, 0.00, 0.00, 0.00, 0.00, 0.00, 42.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 14:28:06', '2026-02-11 15:28:06', 'paid'),
(154, 'INV-260211-3819', 1008, 20, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 160.00, 0.00, 0.00, 0.00, 0.00, 0.00, 160.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 14:28:14', '2026-02-11 15:28:14', 'paid'),
(155, 'INV-260211-7883', 1009, 20, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 28.00, 0.00, 0.00, 0.00, 0.00, 0.00, 28.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 14:30:25', '2026-02-11 15:30:25', 'paid'),
(156, 'INV-260211-1132', 1010, 20, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 300.00, 0.00, 0.00, 0.00, 0.00, 0.00, 300.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 14:30:43', '2026-02-11 15:30:43', 'paid'),
(157, 'INV-260211-2449', 1011, 20, 1, NULL, 'T-01 (4 seats)', 'dine_in', NULL, 'cash', NULL, 318.00, 0.00, 0.00, 0.00, 0.00, 0.00, 318.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 14:31:08', '2026-02-11 19:32:14', 'paid'),
(158, 'INV-260211-7892', 1012, 20, 1, NULL, 'T-01 (4 seats)', 'dine_in', NULL, 'cash', NULL, 709.50, 0.00, 0.00, 0.00, 0.00, 0.00, 709.50, 'completed', 0, NULL, NULL, NULL, '2026-02-11 14:31:29', '2026-02-11 19:32:17', 'paid'),
(159, 'INV-260211-3146', 1013, 20, 1, NULL, 'T-01 (4 seats)', 'dine_in', NULL, 'cash', NULL, 34.00, 0.00, 0.00, 0.00, 0.00, 0.00, 34.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 14:34:18', '2026-02-11 19:34:22', 'paid'),
(160, 'INV-260211-1352', 1014, 20, 1, NULL, 'T-01 (4 seats)', 'dine_in', NULL, 'cash', NULL, 238.00, 0.00, 0.00, 0.00, 0.00, 0.00, 238.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 14:35:11', '2026-02-11 19:35:48', 'paid'),
(161, 'INV-260211-4825', 1015, 20, 1, NULL, 'T-01 (4 seats)', 'dine_in', NULL, 'cash', NULL, 253.00, 0.00, 0.00, 0.00, 0.00, 0.00, 253.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 14:35:45', '2026-02-11 19:36:41', 'paid'),
(162, 'INV-260211-8962', 1016, 20, 1, NULL, 'T-01 (4 seats)', 'dine_in', NULL, 'cash', NULL, 140.00, 0.00, 0.00, 0.00, 0.00, 0.00, 140.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 14:36:35', '2026-02-11 19:36:45', 'paid'),
(163, 'INV-260211-7828', 1017, 20, 1, NULL, 'T-01 (4 seats)', 'dine_in', NULL, 'cash', NULL, 80.00, 0.00, 0.00, 0.00, 0.00, 0.00, 80.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 14:37:07', '2026-02-11 19:37:14', 'paid'),
(164, 'INV-1164', 1018, 17, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 114.00, 0.00, 0.00, 0.00, 0.00, 0.00, 114.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 15:41:16', '2026-02-11 16:41:16', 'paid'),
(165, 'INV-1165', 1019, 17, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 28.00, 0.00, 0.00, 0.00, 0.00, 0.00, 28.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 15:42:24', '2026-02-11 16:42:24', 'paid'),
(166, 'INV-1166', 1020, 17, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 1621.50, 0.00, 0.00, 0.00, 0.00, 0.00, 1621.50, 'completed', 0, NULL, NULL, NULL, '2026-02-11 15:42:57', '2026-02-11 20:43:34', 'paid'),
(167, 'INV-1167', 1021, 17, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 340.00, 0.00, 0.00, 0.00, 0.00, 0.00, 340.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 15:44:10', '2026-02-11 20:44:29', 'paid'),
(168, 'INV-1168', 1022, 17, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 220.00, 0.00, 0.00, 0.00, 0.00, 0.00, 220.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 15:44:54', '2026-02-11 20:45:03', 'paid'),
(169, 'INV-1169', 1023, 20, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 408.00, 0.00, 0.00, 0.00, 0.00, 0.00, 408.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 15:47:55', '2026-02-11 16:47:55', 'paid'),
(170, 'INV-1170', 1024, 20, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 40.00, 0.00, 0.00, 0.00, 0.00, 0.00, 40.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 15:48:10', '2026-02-11 16:48:10', 'paid'),
(171, 'INV-1171', 1, 20, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 214.00, 0.00, 0.00, 0.00, 0.00, 0.00, 214.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 19:36:59', '2026-02-11 20:36:59', 'paid'),
(172, 'INV-260211-3468', 1, 21, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 288.00, 0.00, 0.00, 0.00, 0.00, 0.00, 288.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 19:53:16', '2026-02-11 20:53:16', 'paid'),
(173, 'INV-260211-7649', 2, 21, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 160.00, 0.00, 0.00, 0.00, 0.00, 0.00, 160.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 19:55:02', '2026-02-11 20:55:02', 'paid'),
(174, 'INV-260211-1946', 3, 21, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 6400.00, 0.00, 0.00, 0.00, 0.00, 0.00, 6400.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 19:55:38', '2026-02-11 20:55:38', 'paid'),
(175, 'INV-1175', 4, 21, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 84.00, 0.00, 0.00, 0.00, 0.00, 0.00, 84.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 19:58:13', '2026-02-11 20:58:13', 'paid'),
(176, 'INV-1176', 5, 21, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 28.00, 0.00, 0.00, 0.00, 0.00, 0.00, 28.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 19:59:03', '2026-02-11 20:59:03', 'paid'),
(177, 'INV-1177', 6, 21, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 42.00, 0.00, 0.00, 0.00, 0.00, 0.00, 42.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 19:59:17', '2026-02-11 20:59:17', 'paid'),
(178, 'INV-260211-0416', 7, 21, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 28.00, 0.00, 0.00, 0.00, 0.00, 0.00, 28.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 20:03:57', '2026-02-11 21:03:57', 'paid'),
(179, 'INV-260211-5190', 8, 21, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 152.00, 0.00, 0.00, 0.00, 0.00, 0.00, 152.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 20:09:34', '2026-02-11 21:09:34', 'paid'),
(180, 'INV-260211-2454', 9, 21, NULL, NULL, 'Walk-in', '', NULL, 'cash', NULL, 56.00, 0.00, 0.00, 0.00, 0.00, 0.00, 56.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 20:20:02', '2026-02-11 21:20:02', 'paid'),
(181, 'INV-1181', 10, 21, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 42.00, 0.00, 0.00, 0.00, 0.00, 0.00, 42.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 20:21:28', '2026-02-11 21:21:28', 'paid'),
(182, 'INV-1182', 11, 22, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 456.00, 0.00, 0.00, 0.00, 0.00, 0.00, 456.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 20:22:36', '2026-02-11 21:22:36', 'paid'),
(183, 'INV-1183', 12, 23, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 356.00, 0.00, 0.00, 0.00, 0.00, 0.00, 356.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 21:10:42', '2026-02-12 02:10:42', 'paid'),
(184, 'INV-1184', 13, 23, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 272.00, 0.00, 0.00, 0.00, 0.00, 0.00, 272.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 21:10:53', '2026-02-12 02:10:53', 'paid'),
(185, 'INV-1185', 14, 23, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 152.00, 0.00, 0.00, 0.00, 0.00, 0.00, 152.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 21:48:26', '2026-02-12 02:48:26', 'paid'),
(186, 'INV-1186', 15, 23, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 42.00, 0.00, 0.00, 0.00, 0.00, 0.00, 42.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 21:48:33', '2026-02-12 02:48:33', 'paid'),
(187, 'INV-1187', 16, 23, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 42.00, 0.00, 0.00, 0.00, 0.00, 0.00, 42.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 21:48:47', '2026-02-12 02:48:47', 'paid'),
(188, 'INV-1188', 17, 23, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 42.00, 0.00, 0.00, 0.00, 0.00, 0.00, 42.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 21:49:11', '2026-02-12 02:49:11', 'paid'),
(199, 'INV-1199', 18, 24, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 148.00, 0.00, 0.00, 0.00, 0.00, 0.00, 148.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 23:42:18', '2026-02-12 04:42:18', 'paid'),
(200, 'INV-1200', 19, 24, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 319.50, 0.00, 0.00, 0.00, 0.00, 0.00, 319.50, 'completed', 0, NULL, NULL, NULL, '2026-02-11 23:42:41', '2026-02-12 04:42:41', 'paid'),
(201, 'INV-1201', 20, 24, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 14.00, 0.00, 0.00, 0.00, 0.00, 0.00, 14.00, 'completed', 0, NULL, NULL, NULL, '2026-02-11 23:43:02', '2026-02-12 04:43:02', 'paid'),
(202, 'INV-1202', 21, 24, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '', 0, NULL, NULL, 'ny', '2026-02-12 00:47:14', '2026-02-12 05:47:14', 'paid'),
(203, 'INV-1203', 22, 24, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 10200.00, 0.00, 0.00, 0.00, 0.00, 0.00, 10200.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 01:52:14', '2026-02-12 06:52:14', 'paid');

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
(166, 43, 5, 'Margherita', 1, 15.00, '', 1, '2026-02-11 00:27:53'),
(167, 43, 7, 'Iced Latte', 1, 4.50, '', 1, '2026-02-11 00:27:53'),
(168, 43, 9, 'French Fries', 1, 4.00, '', 1, '2026-02-11 00:27:53'),
(169, 43, 3, 'Double Bacon', 1, 16.00, '', 1, '2026-02-11 00:27:53'),
(170, 44, 9, 'French Fries', 1, 4.00, '', 1, '2026-02-11 00:27:53'),
(171, 44, 7, 'Iced Latte', 1, 4.50, '', 1, '2026-02-11 00:27:53'),
(172, 44, 5, 'Margherita', 1, 15.00, '', 1, '2026-02-11 00:27:53'),
(173, 45, 2, 'Cheese Burger', 1, 14.00, '', 1, '2026-02-11 00:27:53'),
(174, 45, 6, 'Coca Cola', 1, 80.00, '', 1, '2026-02-11 00:27:53'),
(175, 45, 1, 'Classic Beef Burger', 1, 12.00, '', 1, '2026-02-11 00:27:53'),
(176, 45, 3, 'Double Bacon', 1, 16.00, '', 1, '2026-02-11 00:27:53'),
(177, 45, 9, 'French Fries', 1, 4.00, '', 1, '2026-02-11 00:27:53'),
(178, 46, 6, 'Coca Cola', 1, 80.00, '', 1, '2026-02-11 00:27:53'),
(179, 46, 1, 'Classic Beef Burger', 1, 12.00, '', 1, '2026-02-11 00:27:53'),
(180, 46, 3, 'Double Bacon', 1, 16.00, '', 1, '2026-02-11 00:27:53'),
(181, 46, 9, 'French Fries', 1, 4.00, '', 1, '2026-02-11 00:27:53'),
(182, 46, 7, 'Iced Latte', 1, 4.50, '', 1, '2026-02-11 00:27:53'),
(183, 46, 5, 'Margherita', 1, 15.00, '', 1, '2026-02-11 00:27:53'),
(184, 47, 2, 'Cheese Burger', 1, 14.00, '', 1, '2026-02-11 00:27:53'),
(185, 47, 1, 'Classic Beef Burger', 1, 12.00, '', 1, '2026-02-11 00:27:53'),
(186, 47, 6, 'Coca Cola', 1, 80.00, '', 1, '2026-02-11 00:27:53'),
(187, 47, 3, 'Double Bacon', 1, 16.00, '', 1, '2026-02-11 00:27:53'),
(188, 48, 2, 'Cheese Burger', 1, 14.00, '', 1, '2026-02-11 00:27:53'),
(189, 48, 1, 'Classic Beef Burger', 1, 12.00, '', 1, '2026-02-11 00:27:53'),
(190, 48, 6, 'Coca Cola', 1, 80.00, '', 1, '2026-02-11 00:27:53'),
(191, 48, 3, 'Double Bacon', 1, 16.00, '', 1, '2026-02-11 00:27:53'),
(192, 49, 2, 'Cheese Burger', 1, 14.00, '', 1, '2026-02-11 00:27:53'),
(193, 49, 1, 'Classic Beef Burger', 1, 12.00, '', 1, '2026-02-11 00:27:53'),
(194, 49, 6, 'Coca Cola', 1, 80.00, '', 1, '2026-02-11 00:27:53'),
(195, 50, 2, 'Cheese Burger', 4, 14.00, '', 1, '2026-02-11 00:27:53'),
(196, 50, 9, 'French Fries', 3, 4.00, '', 1, '2026-02-11 00:27:53'),
(197, 50, 7, 'Iced Latte', 1, 4.50, '', 1, '2026-02-11 00:27:53'),
(198, 51, 1, 'Classic Beef Burger', 1, 12.00, '', 1, '2026-02-11 00:27:53'),
(199, 51, 6, 'Coca Cola', 1, 80.00, '', 1, '2026-02-11 00:27:53'),
(200, 51, 3, 'Double Bacon', 1, 16.00, '', 1, '2026-02-11 00:27:53'),
(201, 52, 2, 'Cheese Burger', 1, 14.00, '', 1, '2026-02-11 00:27:53'),
(202, 52, 1, 'Classic Beef Burger', 1, 12.00, '', 1, '2026-02-11 00:27:53'),
(203, 52, 6, 'Coca Cola', 1, 80.00, '', 1, '2026-02-11 00:27:53'),
(204, 52, 3, 'Double Bacon', 1, 16.00, '', 1, '2026-02-11 00:27:53'),
(205, 53, 2, 'Cheese Burger', 1, 14.00, '', 1, '2026-02-11 00:27:53'),
(206, 53, 7, 'Iced Latte', 1, 4.50, '', 1, '2026-02-11 00:27:53'),
(207, 53, 5, 'Margherita', 1, 15.00, '', 1, '2026-02-11 00:27:53'),
(208, 54, 9, 'French Fries', 2, 4.00, '', 1, '2026-02-11 00:27:53'),
(209, 54, 3, 'Double Bacon', 2, 16.00, '', 1, '2026-02-11 00:27:53'),
(210, 54, 6, 'Coca Cola', 2, 80.00, '', 1, '2026-02-11 00:27:53'),
(211, 55, 5, 'Margherita', 1, 15.00, '', 1, '2026-02-11 00:27:53'),
(212, 55, 7, 'Iced Latte', 1, 4.50, '', 1, '2026-02-11 00:27:53'),
(213, 56, 6, 'Coca Cola', 1, 80.00, '', 1, '2026-02-11 00:27:53'),
(214, 56, 3, 'Double Bacon', 1, 16.00, '', 1, '2026-02-11 00:27:53'),
(215, 57, 5, 'Margherita', 1, 15.00, '', 1, '2026-02-11 00:27:53'),
(216, 57, 7, 'Iced Latte', 1, 4.50, '', 1, '2026-02-11 00:27:53'),
(217, 58, 3, 'Double Bacon', 4, 16.00, '', 1, '2026-02-11 00:27:53'),
(218, 58, 6, 'Coca Cola', 1, 80.00, '', 1, '2026-02-11 00:27:53'),
(219, 59, 5, 'Margherita', 2, 15.00, '', 1, '2026-02-11 00:27:53'),
(220, 60, 4, 'Pepperoni Pizza', 2, 18.00, '', 1, '2026-02-11 00:27:53'),
(221, 61, 2, 'Cheese Burger', 1, 14.00, '', 0, NULL),
(224, 64, 6, 'Coca Cola', 1, 80.00, '', 1, '2026-02-11 00:27:53'),
(225, 64, 3, 'Double Bacon', 1, 16.00, '', 1, '2026-02-11 00:27:53'),
(226, 65, 8, 'Chocolate Cake', 2, 20.00, '', 1, '2026-02-11 00:27:53'),
(227, 66, 2, 'Cheese Burger', 1, 14.00, '', 1, '2026-02-11 00:27:53'),
(228, 66, 8, 'Chocolate Cake', 1, 20.00, '', 1, '2026-02-11 00:27:53'),
(229, 66, 1, 'Classic Beef Burger', 1, 12.00, '', 1, '2026-02-11 00:27:53'),
(230, 66, 6, 'Coca Cola', 3, 80.00, '', 1, '2026-02-11 00:27:53'),
(231, 66, 3, 'Double Bacon', 1, 16.00, '', 1, '2026-02-11 00:27:53'),
(232, 67, 8, 'Chocolate Cake', 5, 20.00, '', 1, '2026-02-11 00:27:53'),
(233, 68, 8, 'Chocolate Cake', 5, 20.00, '', 0, NULL),
(234, 69, 4, 'Pepperoni Pizza', 1, 18.00, '', 1, '2026-02-11 00:27:53'),
(235, 69, 1, 'Classic Beef Burger', 1, 12.00, '', 1, '2026-02-11 00:27:53'),
(236, 70, 5, 'Margherita', 1, 15.00, '', 1, '2026-02-11 00:27:53'),
(237, 71, 2, 'Cheese Burger', 1, 14.00, NULL, 1, '2026-02-11 00:27:53'),
(238, 71, 8, 'Chocolate Cake', 1, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(239, 71, 1, 'Classic Beef Burger', 1, 12.00, NULL, 1, '2026-02-11 00:27:53'),
(240, 72, 2, 'Cheese Burger', 1, 14.00, NULL, 1, '2026-02-11 00:27:53'),
(241, 72, 4, 'Pepperoni Pizza', 1, 18.00, NULL, 1, '2026-02-11 00:27:53'),
(242, 73, 2, 'Cheese Burger', 1, 14.00, NULL, 1, '2026-02-11 00:27:53'),
(243, 73, 8, 'Chocolate Cake', 1, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(244, 73, 1, 'Classic Beef Burger', 1, 12.00, NULL, 1, '2026-02-11 00:27:53'),
(245, 73, 6, 'Coca Cola', 1, 80.00, NULL, 1, '2026-02-11 00:27:53'),
(246, 73, 3, 'Double Bacon', 1, 16.00, NULL, 1, '2026-02-11 00:27:53'),
(247, 73, 9, 'French Fries', 1, 4.00, NULL, 1, '2026-02-11 00:27:53'),
(248, 74, 9, 'French Fries', 1, 4.00, NULL, 1, '2026-02-11 00:27:53'),
(249, 74, 3, 'Double Bacon', 1, 16.00, NULL, 1, '2026-02-11 00:27:53'),
(250, 75, 2, 'Cheese Burger', 1, 14.00, NULL, 1, '2026-02-11 00:27:53'),
(251, 75, 8, 'Chocolate Cake', 1, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(252, 75, 1, 'Classic Beef Burger', 1, 12.00, NULL, 1, '2026-02-11 00:27:53'),
(253, 75, 6, 'Coca Cola', 1, 80.00, NULL, 1, '2026-02-11 00:27:53'),
(254, 75, 9, 'French Fries', 1, 4.00, NULL, 1, '2026-02-11 00:27:53'),
(255, 75, 7, 'Iced Latte', 1, 4.50, NULL, 1, '2026-02-11 00:27:53'),
(256, 76, 2, 'Cheese Burger', 1, 14.00, NULL, 1, '2026-02-11 00:27:53'),
(257, 76, 8, 'Chocolate Cake', 1, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(258, 76, 1, 'Classic Beef Burger', 1, 12.00, NULL, 1, '2026-02-11 00:27:53'),
(259, 77, 2, 'Cheese Burger', 1, 14.00, NULL, 1, '2026-02-11 00:27:53'),
(260, 77, 4, 'Pepperoni Pizza', 1, 18.00, NULL, 1, '2026-02-11 00:27:53'),
(261, 78, 2, 'Cheese Burger', 1, 14.00, NULL, 1, '2026-02-11 00:27:53'),
(262, 78, 8, 'Chocolate Cake', 1, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(263, 78, 1, 'Classic Beef Burger', 1, 12.00, NULL, 1, '2026-02-11 00:27:53'),
(264, 78, 6, 'Coca Cola', 1, 80.00, NULL, 1, '2026-02-11 00:27:53'),
(265, 79, 4, 'Pepperoni Pizza', 1, 18.00, NULL, 1, '2026-02-11 00:27:53'),
(266, 79, 1, 'Classic Beef Burger', 1, 12.00, NULL, 1, '2026-02-11 00:27:53'),
(267, 79, 6, 'Coca Cola', 1, 80.00, NULL, 1, '2026-02-11 00:27:53'),
(268, 79, 3, 'Double Bacon', 1, 16.00, NULL, 1, '2026-02-11 00:27:53'),
(269, 79, 9, 'French Fries', 1, 4.00, NULL, 1, '2026-02-11 00:27:53'),
(270, 80, 5, 'Margherita', 1, 15.00, NULL, 1, '2026-02-11 00:27:53'),
(271, 80, 7, 'Iced Latte', 1, 4.50, NULL, 1, '2026-02-11 00:27:53'),
(272, 80, 9, 'French Fries', 1, 4.00, NULL, 1, '2026-02-11 00:27:53'),
(273, 81, 8, 'Chocolate Cake', 3, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(274, 82, 8, 'Chocolate Cake', 3, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(275, 83, 8, 'Chocolate Cake', 3, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(276, 83, 1, 'Classic Beef Burger', 1, 12.00, NULL, 1, '2026-02-11 00:27:53'),
(277, 83, 6, 'Coca Cola', 1, 80.00, NULL, 1, '2026-02-11 00:27:53'),
(278, 83, 9, 'French Fries', 1, 4.00, NULL, 1, '2026-02-11 00:27:53'),
(279, 84, 8, 'Chocolate Cake', 3, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(280, 85, 8, 'Chocolate Cake', 3, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(281, 86, 2, 'Cheese Burger', 1, 14.00, NULL, 1, '2026-02-11 00:27:53'),
(282, 86, 8, 'Chocolate Cake', 1, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(283, 86, 1, 'Classic Beef Burger', 1, 12.00, NULL, 1, '2026-02-11 00:27:53'),
(284, 87, 2, 'Cheese Burger', 1, 14.00, NULL, 1, '2026-02-11 00:27:53'),
(285, 87, 8, 'Chocolate Cake', 1, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(286, 87, 1, 'Classic Beef Burger', 1, 12.00, NULL, 1, '2026-02-11 00:27:53'),
(287, 88, 5, 'Margherita', 1, 15.00, NULL, 1, '2026-02-11 00:27:53'),
(288, 88, 7, 'Iced Latte', 1, 4.50, NULL, 1, '2026-02-11 00:27:53'),
(289, 88, 9, 'French Fries', 1, 4.00, NULL, 1, '2026-02-11 00:27:53'),
(290, 89, 8, 'Chocolate Cake', 1, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(291, 89, 1, 'Classic Beef Burger', 1, 12.00, NULL, 1, '2026-02-11 00:27:53'),
(292, 89, 6, 'Coca Cola', 1, 80.00, NULL, 1, '2026-02-11 00:27:53'),
(293, 90, 8, 'Chocolate Cake', 1, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(294, 90, 1, 'Classic Beef Burger', 1, 12.00, NULL, 1, '2026-02-11 00:27:53'),
(295, 90, 6, 'Coca Cola', 1, 80.00, NULL, 1, '2026-02-11 00:27:53'),
(296, 91, 8, 'Chocolate Cake', 1, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(297, 91, 1, 'Classic Beef Burger', 1, 12.00, NULL, 1, '2026-02-11 00:27:53'),
(298, 91, 6, 'Coca Cola', 1, 80.00, NULL, 1, '2026-02-11 00:27:53'),
(299, 92, 8, 'Chocolate Cake', 1, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(300, 92, 1, 'Classic Beef Burger', 1, 12.00, NULL, 1, '2026-02-11 00:27:53'),
(301, 92, 6, 'Coca Cola', 1, 80.00, NULL, 1, '2026-02-11 00:27:53'),
(302, 93, 8, 'Chocolate Cake', 1, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(303, 93, 1, 'Classic Beef Burger', 1, 12.00, NULL, 1, '2026-02-11 00:27:53'),
(304, 93, 6, 'Coca Cola', 1, 80.00, NULL, 1, '2026-02-11 00:27:53'),
(305, 94, 8, 'Chocolate Cake', 1, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(306, 94, 1, 'Classic Beef Burger', 1, 12.00, NULL, 1, '2026-02-11 00:27:53'),
(307, 94, 6, 'Coca Cola', 1, 80.00, NULL, 1, '2026-02-11 00:27:53'),
(308, 95, 8, 'Chocolate Cake', 5, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(309, 96, 8, 'Chocolate Cake', 5, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(310, 97, 1, 'Classic Beef Burger', 1, 12.00, NULL, 1, '2026-02-11 00:27:53'),
(311, 97, 6, 'Coca Cola', 1, 80.00, NULL, 1, '2026-02-11 00:27:53'),
(312, 97, 3, 'Double Bacon', 1, 16.00, NULL, 1, '2026-02-11 00:27:53'),
(313, 97, 9, 'French Fries', 1, 4.00, NULL, 1, '2026-02-11 00:27:53'),
(314, 98, 2, 'Cheese Burger', 3, 14.00, NULL, 1, '2026-02-11 00:27:53'),
(315, 99, 2, 'Cheese Burger', 1, 14.00, NULL, 1, '2026-02-11 00:27:53'),
(316, 99, 8, 'Chocolate Cake', 1, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(317, 99, 1, 'Classic Beef Burger', 1, 12.00, NULL, 1, '2026-02-11 00:27:53'),
(318, 99, 6, 'Coca Cola', 1, 80.00, NULL, 1, '2026-02-11 00:27:53'),
(319, 100, 2, 'Cheese Burger', 1, 14.00, NULL, 1, '2026-02-11 00:27:53'),
(320, 100, 8, 'Chocolate Cake', 1, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(321, 100, 1, 'Classic Beef Burger', 1, 12.00, NULL, 1, '2026-02-11 00:27:53'),
(322, 100, 6, 'Coca Cola', 1, 80.00, NULL, 1, '2026-02-11 00:27:53'),
(323, 100, 3, 'Double Bacon', 1, 16.00, NULL, 1, '2026-02-11 00:27:53'),
(324, 100, 9, 'French Fries', 1, 4.00, NULL, 1, '2026-02-11 00:27:53'),
(325, 100, 7, 'Iced Latte', 1, 4.50, NULL, 1, '2026-02-11 00:27:53'),
(326, 100, 5, 'Margherita', 1, 15.00, NULL, 1, '2026-02-11 00:27:53'),
(327, 100, 4, 'Pepperoni Pizza', 1, 18.00, NULL, 1, '2026-02-11 00:27:53'),
(328, 101, 8, 'Chocolate Cake', 6, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(329, 102, 2, 'Cheese Burger', 1, 14.00, NULL, 1, '2026-02-11 00:27:53'),
(330, 102, 8, 'Chocolate Cake', 1, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(331, 102, 1, 'Classic Beef Burger', 1, 12.00, NULL, 1, '2026-02-11 00:27:53'),
(332, 102, 6, 'Coca Cola', 1, 80.00, NULL, 1, '2026-02-11 00:27:53'),
(333, 102, 3, 'Double Bacon', 1, 16.00, NULL, 1, '2026-02-11 00:27:53'),
(334, 102, 9, 'French Fries', 1, 4.00, NULL, 1, '2026-02-11 00:27:53'),
(335, 102, 7, 'Iced Latte', 1, 4.50, NULL, 1, '2026-02-11 00:27:53'),
(336, 102, 5, 'Margherita', 1, 15.00, NULL, 1, '2026-02-11 00:27:53'),
(337, 102, 4, 'Pepperoni Pizza', 1, 18.00, NULL, 1, '2026-02-11 00:27:53'),
(338, 103, 8, 'Chocolate Cake', 3, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(339, 104, 8, 'Chocolate Cake', 3, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(340, 105, 2, 'Cheese Burger', 1, 14.00, NULL, 1, '2026-02-11 00:27:53'),
(341, 105, 8, 'Chocolate Cake', 1, 20.00, NULL, 1, '2026-02-11 00:27:53'),
(342, 105, 1, 'Classic Beef Burger', 1, 12.00, NULL, 1, '2026-02-11 00:27:53'),
(343, 105, 6, 'Coca Cola', 1, 80.00, NULL, 1, '2026-02-11 00:27:53'),
(344, 106, 11, 'Water', 5, 120.00, NULL, 1, '2026-02-11 00:27:53'),
(345, 107, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(346, 107, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(347, 107, 1, 'Classic Beef Burger', 1, 12.00, NULL, 0, NULL),
(348, 107, 6, 'Coca Cola', 1, 80.00, NULL, 0, NULL),
(349, 107, 3, 'Double Bacon', 1, 16.00, NULL, 0, NULL),
(350, 107, 9, 'French Fries', 1, 4.00, NULL, 0, NULL),
(351, 108, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(352, 108, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(353, 108, 1, 'Classic Beef Burger', 1, 12.00, NULL, 0, NULL),
(354, 108, 6, 'Coca Cola', 1, 80.00, NULL, 0, NULL),
(355, 108, 3, 'Double Bacon', 1, 16.00, NULL, 0, NULL),
(356, 109, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(357, 109, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(358, 109, 1, 'Classic Beef Burger', 1, 12.00, NULL, 0, NULL),
(359, 109, 6, 'Coca Cola', 1, 80.00, NULL, 0, NULL),
(360, 109, 3, 'Double Bacon', 1, 16.00, NULL, 0, NULL),
(361, 110, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(362, 110, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(363, 110, 1, 'Classic Beef Burger', 1, 12.00, NULL, 0, NULL),
(364, 110, 6, 'Coca Cola', 1, 80.00, NULL, 0, NULL),
(365, 110, 3, 'Double Bacon', 1, 16.00, NULL, 0, NULL),
(366, 111, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(367, 111, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(368, 111, 1, 'Classic Beef Burger', 1, 12.00, NULL, 0, NULL),
(369, 111, 6, 'Coca Cola', 1, 80.00, NULL, 0, NULL),
(370, 111, 3, 'Double Bacon', 1, 16.00, NULL, 0, NULL),
(371, 111, 9, 'French Fries', 1, 4.00, NULL, 0, NULL),
(372, 111, 7, 'Iced Latte', 1, 4.50, NULL, 0, NULL),
(373, 111, 5, 'Margherita', 1, 15.00, NULL, 0, NULL),
(374, 112, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(375, 112, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(376, 112, 1, 'Classic Beef Burger', 1, 12.00, NULL, 0, NULL),
(377, 112, 6, 'Coca Cola', 1, 80.00, NULL, 0, NULL),
(378, 113, 8, 'Chocolate Cake', 6, 20.00, NULL, 0, NULL),
(379, 114, 11, 'Water', 95, 120.00, NULL, 0, NULL),
(380, 115, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(381, 115, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(382, 115, 1, 'Classic Beef Burger', 1, 100.00, NULL, 0, NULL),
(383, 115, 6, 'Coca Cola', 1, 80.00, NULL, 0, NULL),
(384, 115, 3, 'Double Bacon', 1, 16.00, NULL, 0, NULL),
(385, 115, 9, 'French Fries', 1, 4.00, NULL, 0, NULL),
(386, 115, 7, 'Iced Latte', 1, 4.50, NULL, 0, NULL),
(387, 115, 5, 'Margherita', 1, 15.00, NULL, 0, NULL),
(388, 115, 11, 'Water', 1, 120.00, NULL, 0, NULL),
(389, 115, 4, 'Pepperoni Pizza', 1, 18.00, NULL, 0, NULL),
(390, 116, 11, 'Water', 1, 120.00, NULL, 0, NULL),
(391, 116, 4, 'Pepperoni Pizza', 1, 18.00, NULL, 0, NULL),
(392, 116, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(393, 116, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(394, 116, 1, 'Classic Beef Burger', 1, 100.00, NULL, 0, NULL),
(395, 116, 6, 'Coca Cola', 1, 80.00, NULL, 0, NULL),
(396, 116, 3, 'Double Bacon', 1, 16.00, NULL, 0, NULL),
(397, 116, 9, 'French Fries', 1, 4.00, NULL, 0, NULL),
(398, 116, 7, 'Iced Latte', 1, 4.50, NULL, 0, NULL),
(399, 116, 5, 'Margherita', 1, 15.00, NULL, 0, NULL),
(400, 117, 11, 'Water', 1, 120.00, NULL, 0, NULL),
(401, 117, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(402, 117, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(403, 118, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(404, 118, 11, 'Water', 1, 120.00, NULL, 0, NULL),
(405, 118, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(406, 119, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(407, 119, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(408, 119, 1, 'Classic Beef Burger', 1, 100.00, NULL, 0, NULL),
(409, 120, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(410, 120, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(411, 120, 1, 'Classic Beef Burger', 1, 100.00, NULL, 0, NULL),
(412, 121, 2, 'Cheese Burger', 2, 14.00, NULL, 0, NULL),
(413, 121, 8, 'Chocolate Cake', 2, 20.00, NULL, 0, NULL),
(414, 121, 1, 'Classic Beef Burger', 1, 100.00, NULL, 0, NULL),
(415, 122, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(416, 122, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(417, 122, 1, 'Classic Beef Burger', 1, 100.00, NULL, 0, NULL),
(418, 122, 4, 'Pepperoni Pizza', 1, 18.00, NULL, 0, NULL),
(419, 122, 11, 'Water', 2, 120.00, NULL, 0, NULL),
(420, 122, 9, 'French Fries', 2, 4.00, NULL, 0, NULL),
(421, 123, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(422, 123, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(423, 124, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(424, 124, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(425, 125, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(426, 125, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(427, 126, 7, 'Iced Latte', 1, 4.50, NULL, 0, NULL),
(428, 126, 5, 'Margherita', 1, 15.00, NULL, 0, NULL),
(429, 127, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(430, 127, 4, 'Pepperoni Pizza', 1, 18.00, NULL, 0, NULL),
(431, 127, 11, 'Water', 1, 120.00, NULL, 0, NULL),
(432, 128, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(433, 128, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(434, 128, 1, 'Classic Beef Burger', 1, 100.00, NULL, 0, NULL),
(435, 129, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(436, 129, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(437, 130, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(438, 130, 1, 'Classic Beef Burger', 1, 100.00, NULL, 0, NULL),
(439, 131, 1, 'Classic Beef Burger', 3, 100.00, NULL, 0, NULL),
(440, 131, 6, 'Coca Cola', 1, 80.00, NULL, 0, NULL),
(441, 132, 3, 'Double Bacon', 3, 16.00, NULL, 0, NULL),
(442, 133, 2, 'Cheese Burger', 3, 14.00, NULL, 0, NULL),
(443, 134, 11, 'Water', 3, 120.00, NULL, 0, NULL),
(444, 135, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(445, 135, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(446, 136, 2, 'Cheese Burger', 2, 14.00, NULL, 0, NULL),
(447, 137, 2, 'Cheese Burger', 3, 14.00, NULL, 0, NULL),
(448, 138, 8, 'Chocolate Cake', 5, 20.00, NULL, 0, NULL),
(451, 149, 8, 'Chocolate Cake', 2, 20.00, NULL, 0, NULL),
(452, 150, 2, 'Cheese Burger', 2, 14.00, NULL, 0, NULL),
(453, 151, 4, 'Pepperoni Pizza', 2, 18.00, NULL, 0, NULL),
(454, 152, 9, 'French Fries', 2, 4.00, NULL, 0, NULL),
(455, 153, 2, 'Cheese Burger', 3, 14.00, NULL, 0, NULL),
(456, 154, 6, 'Coca Cola', 2, 80.00, NULL, 0, NULL),
(457, 155, 2, 'Cheese Burger', 2, 14.00, NULL, 0, NULL),
(458, 156, 1, 'Classic Beef Burger', 3, 100.00, NULL, 0, NULL),
(459, 157, 6, 'Coca Cola', 2, 80.00, NULL, 0, NULL),
(460, 157, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(461, 157, 11, 'Water', 1, 120.00, NULL, 0, NULL),
(462, 157, 4, 'Pepperoni Pizza', 1, 18.00, NULL, 0, NULL),
(463, 158, 6, 'Coca Cola', 3, 80.00, NULL, 0, NULL),
(464, 158, 8, 'Chocolate Cake', 2, 20.00, NULL, 0, NULL),
(465, 158, 11, 'Water', 2, 120.00, NULL, 0, NULL),
(466, 158, 4, 'Pepperoni Pizza', 2, 18.00, NULL, 0, NULL),
(467, 158, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(468, 158, 1, 'Classic Beef Burger', 1, 100.00, NULL, 0, NULL),
(469, 158, 3, 'Double Bacon', 1, 16.00, NULL, 0, NULL),
(470, 158, 9, 'French Fries', 1, 4.00, NULL, 0, NULL),
(471, 158, 7, 'Iced Latte', 1, 4.50, NULL, 0, NULL),
(472, 158, 5, 'Margherita', 1, 15.00, NULL, 0, NULL),
(473, 159, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(474, 159, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(475, 160, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(476, 160, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(477, 160, 1, 'Classic Beef Burger', 1, 100.00, NULL, 0, NULL),
(478, 160, 6, 'Coca Cola', 1, 80.00, NULL, 0, NULL),
(479, 160, 3, 'Double Bacon', 1, 16.00, NULL, 0, NULL),
(480, 160, 9, 'French Fries', 2, 4.00, NULL, 0, NULL),
(481, 161, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(482, 161, 8, 'Chocolate Cake', 1, 20.00, NULL, 0, NULL),
(483, 161, 1, 'Classic Beef Burger', 1, 100.00, NULL, 0, NULL),
(484, 161, 6, 'Coca Cola', 1, 80.00, NULL, 0, NULL),
(485, 161, 3, 'Double Bacon', 1, 16.00, NULL, 0, NULL),
(486, 161, 9, 'French Fries', 2, 4.00, NULL, 0, NULL),
(487, 161, 5, 'Margherita', 1, 15.00, NULL, 0, NULL),
(488, 162, 8, 'Chocolate Cake', 7, 20.00, NULL, 0, NULL),
(489, 163, 8, 'Chocolate Cake', 4, 20.00, NULL, 0, NULL),
(490, 164, 2, 'Cheese Burger', 1, 14.00, '', 0, NULL),
(491, 164, 8, 'Chocolate Cake', 1, 20.00, '', 0, NULL),
(492, 164, 6, 'Coca Cola', 1, 80.00, '', 0, NULL),
(493, 165, 2, 'Cheese Burger', 2, 14.00, '', 0, NULL),
(494, 166, 8, 'Chocolate Cake', 7, 20.00, '', 0, NULL),
(495, 166, 2, 'Cheese Burger', 5, 14.00, '', 0, NULL),
(496, 166, 11, 'Water', 5, 120.00, '', 0, NULL),
(497, 166, 4, 'Pepperoni Pizza', 5, 18.00, '', 0, NULL),
(498, 166, 5, 'Margherita', 8, 15.00, '', 0, NULL),
(499, 166, 1, 'Classic Beef Burger', 3, 100.00, '', 0, NULL),
(500, 166, 6, 'Coca Cola', 3, 80.00, '', 0, NULL),
(501, 166, 3, 'Double Bacon', 3, 16.00, '', 0, NULL),
(502, 166, 7, 'Iced Latte', 3, 4.50, '', 0, NULL),
(503, 167, 11, 'Water', 2, 120.00, '', 0, NULL),
(504, 167, 1, 'Classic Beef Burger', 1, 100.00, '', 0, NULL),
(505, 168, 11, 'Water', 1, 120.00, '', 0, NULL),
(506, 168, 1, 'Classic Beef Burger', 1, 100.00, '', 0, NULL),
(507, 169, 2, 'Cheese Burger', 2, 14.00, '', 0, NULL),
(508, 169, 11, 'Water', 3, 120.00, '', 0, NULL),
(509, 169, 8, 'Chocolate Cake', 1, 20.00, '', 0, NULL),
(510, 170, 8, 'Chocolate Cake', 2, 20.00, '', 0, NULL),
(511, 171, 2, 'Cheese Burger', 1, 14.00, '', 0, NULL),
(512, 171, 8, 'Chocolate Cake', 1, 20.00, '', 0, NULL),
(513, 171, 1, 'Classic Beef Burger', 1, 100.00, '', 0, NULL),
(514, 171, 6, 'Coca Cola', 1, 80.00, '', 0, NULL),
(515, 172, 2, 'Cheese Burger', 2, 14.00, NULL, 0, NULL),
(516, 172, 8, 'Chocolate Cake', 13, 20.00, NULL, 0, NULL),
(517, 173, 6, 'Coca Cola', 2, 80.00, NULL, 0, NULL),
(518, 174, 6, 'Coca Cola', 80, 80.00, NULL, 0, NULL),
(519, 175, 2, 'Cheese Burger', 6, 14.00, '', 0, NULL),
(520, 176, 2, 'Cheese Burger', 2, 14.00, '', 0, NULL),
(521, 177, 2, 'Cheese Burger', 3, 14.00, '', 0, NULL),
(522, 178, 2, 'Cheese Burger', 2, 14.00, NULL, 0, NULL),
(523, 179, 2, 'Cheese Burger', 1, 14.00, NULL, 0, NULL),
(524, 179, 4, 'Pepperoni Pizza', 1, 18.00, NULL, 0, NULL),
(525, 179, 11, 'Water', 1, 120.00, NULL, 0, NULL),
(526, 180, 2, 'Cheese Burger', 4, 14.00, NULL, 0, NULL),
(527, 181, 2, 'Cheese Burger', 3, 14.00, '', 0, NULL),
(528, 182, 2, 'Cheese Burger', 4, 14.00, '', 0, NULL),
(529, 182, 1, 'Classic Beef Burger', 4, 100.00, '', 0, NULL),
(530, 183, 2, 'Cheese Burger', 4, 14.00, '', 0, NULL),
(531, 183, 1, 'Classic Beef Burger', 3, 100.00, '', 0, NULL),
(532, 184, 2, 'Cheese Burger', 1, 14.00, '', 0, NULL),
(533, 184, 11, 'Water', 2, 120.00, '', 0, NULL),
(534, 184, 4, 'Pepperoni Pizza', 1, 18.00, '', 0, NULL),
(535, 185, 2, 'Cheese Burger', 1, 14.00, '', 0, NULL),
(536, 185, 4, 'Pepperoni Pizza', 1, 18.00, '', 0, NULL),
(537, 185, 11, 'Water', 1, 120.00, '', 0, NULL),
(538, 186, 2, 'Cheese Burger', 3, 14.00, '', 0, NULL),
(539, 187, 2, 'Cheese Burger', 3, 14.00, '', 0, NULL),
(540, 188, 2, 'Cheese Burger', 3, 14.00, '', 0, NULL),
(541, 199, 2, 'Cheese Burger', 2, 14.00, '', 0, NULL),
(542, 199, 11, 'Water', 1, 120.00, '', 0, NULL),
(543, 200, 2, 'Cheese Burger', 3, 14.00, '', 0, NULL),
(544, 200, 11, 'Water', 1, 120.00, '', 0, NULL),
(545, 200, 4, 'Pepperoni Pizza', 1, 18.00, '', 0, NULL),
(546, 200, 3, 'Double Bacon', 1, 16.00, '', 0, NULL),
(547, 200, 9, 'French Fries', 1, 4.00, '', 0, NULL),
(548, 200, 7, 'Iced Latte', 1, 4.50, '', 0, NULL),
(549, 200, 5, 'Margherita', 1, 15.00, '', 0, NULL),
(550, 200, 1, 'Classic Beef Burger', 1, 100.00, '', 0, NULL),
(551, 201, 2, 'Cheese Burger', 1, 14.00, '', 0, NULL),
(553, 203, 11, 'Water', 85, 120.00, '', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `order_payments`
--

CREATE TABLE `order_payments` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `payment_method` varchar(50) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `order_types`
--

CREATE TABLE `order_types` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `slug` varchar(50) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_types`
--

INSERT INTO `order_types` (`id`, `name`, `slug`, `is_active`) VALUES
(1, 'Dine-in', 'dine_in', 1),
(2, 'Takeaway', 'takeaway', 1),
(3, 'Delivery', 'delivery', 1),
(4, 'Walk-in', 'walk_in', 1);

-- --------------------------------------------------------

--
-- Table structure for table `payment_methods`
--

CREATE TABLE `payment_methods` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `slug` varchar(50) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payment_methods`
--

INSERT INTO `payment_methods` (`id`, `name`, `slug`, `is_active`) VALUES
(1, 'Cash', 'cash', 1),
(2, 'Card', 'card', 1),
(3, 'Other', 'other', 1);

-- --------------------------------------------------------

--
-- Table structure for table `permissions`
--

CREATE TABLE `permissions` (
  `id` int(11) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `name` varchar(100) NOT NULL,
  `category` varchar(50) DEFAULT 'general'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `permissions`
--

INSERT INTO `permissions` (`id`, `slug`, `name`, `category`) VALUES
(1, 'pos_access', 'Access POS (Ordering)', 'POS'),
(2, 'floor_plan_access', 'Access Floor Plan', 'POS'),
(3, 'view_reports', 'View Sales Reports', 'Reports'),
(4, 'export_data', 'Export Sale Data', 'Reports'),
(5, 'settings_access', 'Access Settings Management', 'System'),
(6, 'void_orders', 'Void/Delete Orders', 'Logic'),
(7, 'hide_financials', 'Hide Financial Dashboard', 'Logic');

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
(1, 'Classic Beef Burger', 100.00, 0.00, 1, 'https://placehold.co/150x100/E8B067/333?text=Burger', NULL, 1, 0, '2026-02-07 23:31:15', '2026-02-11 11:45:41'),
(2, 'Cheese Burger', 14.00, 0.00, 1, 'https://placehold.co/150x100/F5C77E/333?text=Cheese', NULL, 1, 0, '2026-02-07 23:31:15', '2026-02-07 23:31:15'),
(3, 'Double Bacon', 16.00, 0.00, 1, 'https://placehold.co/150x100/D4956A/333?text=Bacon', NULL, 1, 0, '2026-02-07 23:31:15', '2026-02-07 23:31:15'),
(4, 'Pepperoni Pizza', 18.00, 0.00, 2, 'https://placehold.co/150x100/E85A4F/333?text=Pizza', NULL, 1, 0, '2026-02-07 23:31:15', '2026-02-07 23:31:15'),
(5, 'Margherita', 15.00, 0.00, 2, 'https://placehold.co/150x100/F28B82/333?text=Margherita', NULL, 1, 0, '2026-02-07 23:31:15', '2026-02-07 23:31:15'),
(6, 'Coca Cola', 80.00, 0.00, 3, 'https://placehold.co/150x100/B71C1C/fff?text=Cola', NULL, 1, 0, '2026-02-07 23:31:15', '2026-02-08 19:44:00'),
(7, 'Iced Latte', 4.50, 0.00, 3, 'https://placehold.co/150x100/795548/fff?text=Latte', NULL, 1, 0, '2026-02-07 23:31:15', '2026-02-07 23:31:15'),
(8, 'Chocolate Cake', 20.00, 0.00, 4, 'https://placehold.co/150x100/5D4037/fff?text=Cake', NULL, 1, 0, '2026-02-07 23:31:15', '2026-02-08 19:47:40'),
(9, 'French Fries', 4.00, 0.00, 5, 'https://placehold.co/150x100/FFC107/333?text=Fries', NULL, 1, 0, '2026-02-07 23:31:15', '2026-02-07 23:31:15'),
(11, 'Water', 120.00, 0.00, 3, 'uploads/products/prod_1770861016_927.png', NULL, 1, 0, '2026-02-10 19:22:17', '2026-02-12 01:50:16');

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
(12, 8, 10, 1.000),
(16, 6, 9, 1.000),
(18, 11, 11, 1.000);

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
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `slug` varchar(50) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `name`, `slug`, `is_active`) VALUES
(1, 'Admin', 'admin', 1),
(2, 'Manager', 'manager', 1),
(3, 'Cashier', 'cashier', 1),
(4, 'Kitchen Staff', 'chef', 1),
(5, 'Waiter', 'waiter', 1);

-- --------------------------------------------------------

--
-- Table structure for table `role_permissions`
--

CREATE TABLE `role_permissions` (
  `role_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `role_permissions`
--

INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(1, 6),
(1, 7),
(3, 1),
(3, 2);

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
(1, 'restaurant_name', 'Cafe Arsalan Restaurant ', 'text', 'general'),
(2, 'restaurant_address', 'Ali Palace Qasimabad', 'text', 'general'),
(3, 'restaurant_phone', '0303 4980786', 'text', 'general'),
(4, 'restaurant_logo', 'assets/logo_1770594873.png', 'text', 'receipt'),
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
(18, 'default_order_type', 'walk_in', 'text', 'order'),
(19, 'show_order_timer', 'true', 'boolean', 'order'),
(20, 'allow_qty_edit_after_kot', 'true', 'boolean', 'order'),
(21, 'allow_cancel_after_payment', 'false', 'boolean', 'order'),
(22, 'merge_orders_same_table', 'false', 'boolean', 'order'),
(23, 'auto_release_table', 'true', 'boolean', 'tables'),
(24, 'table_color_free', '#10b24e', 'text', 'tables'),
(25, 'table_color_busy', '#0f0cbb', 'text', 'tables'),
(26, 'table_color_reserved', '#f79009', 'text', 'tables'),
(27, 'allow_merge_table', 'false', 'boolean', 'tables'),
(28, 'strict_stock_control', 'false', 'boolean', 'inventory'),
(29, 'show_logo_receipt', 'true', 'boolean', 'receipt'),
(30, 'show_cashier_receipt', 'true', 'boolean', 'receipt'),
(31, 'printer_width', '80', 'number', 'receipt'),
(32, 'receipt_header', '', 'text', 'receipt'),
(33, 'receipt_footer', 'Thank you for visiting!', 'text', 'receipt'),
(34, 'timezone', 'Asia/Karachi', 'text', 'system'),
(35, 'date_format', 'MM/DD/YYYY', 'text', 'system'),
(36, 'store_open_time', '09:00', 'text', 'system'),
(37, 'store_close_time', '22:00', 'text', 'system'),
(41, 'show_logo_on_receipt', 'true', 'boolean', 'receipt'),
(43, 'service_charge', '', 'text', 'general'),
(48, 'rounding_rule', 'Nearest Whole', 'text', 'general'),
(50, 'require_bill_before_payment', 'true', 'boolean', 'general'),
(51, 'auto_merge_items', 'true', 'boolean', 'general'),
(53, 'allow_table_transfer', 'false', 'boolean', 'general'),
(57, 'table_color_waiters', '#000000', 'text', 'general'),
(58, 'kot_print_copies', '', 'text', 'general'),
(59, 'auto_print_kot', 'false', 'boolean', 'general'),
(60, 'show_notes_on_kot', 'false', 'boolean', 'general'),
(61, 'print_logo_on_kot', 'true', 'boolean', 'general'),
(62, 'printer_type', 'usb', 'text', 'general'),
(63, 'paper_width', '80', 'number', 'general'),
(66, 'stock_deduction_mode', 'On Order', 'text', 'general'),
(67, 'low_stock_warning_limit', '10', 'text', 'general'),
(68, 'block_out_of_stock_orders', 'true', 'boolean', 'general'),
(77, 'cashier_hide_financial_data', 'false', 'boolean', 'general'),
(1231, 'pos_access', 'true', 'boolean', 'general'),
(1232, 'floor_plan_access', 'true', 'boolean', 'general'),
(1233, 'view_reports', 'true', 'boolean', 'general'),
(1234, 'export_data', 'true', 'boolean', 'general'),
(1235, 'settings_access', 'true', 'boolean', 'general'),
(1236, 'void_orders', 'true', 'boolean', 'general'),
(1237, 'hide_financials', 'true', 'boolean', 'general'),
(1403, 'allow_item_cancellation_after_kot', 'false', 'boolean', 'order'),
(1404, 'receipt_font_size', '', 'text', 'receipt'),
(1405, 'debug_mode', 'true', 'boolean', 'system'),
(1406, 'auto_backup', 'true', 'boolean', 'system'),
(1407, 'software_version', '1.0.0', 'text', 'system'),
(1454, 'allow_price_override', 'false', 'boolean', 'order'),
(1455, 'order_cancel_grace_period', '5', 'number', 'order'),
(1456, 'token_reset_logic', 'daily', 'text', 'order'),
(1457, 'auto_merge_table_orders', 'true', 'boolean', 'order'),
(1458, 'receipt_layout_type', 'detailed', 'text', 'receipt'),
(1460, 'show_category_on_receipt', 'false', 'boolean', 'receipt'),
(1461, 'custom_footer_note', '', 'text', 'receipt'),
(1462, 'show_developer_branding', 'true', 'boolean', 'receipt'),
(1463, 'maintenance_mode', 'true', 'boolean', 'system'),
(1464, 'backup_path', 'backups/', 'text', 'system'),
(1465, 'log_retention_days', '30', 'number', 'system'),
(1466, 'system_version', 'v2.5.0', 'text', 'system'),
(1747, 'business_day_start', '6', 'number', 'localization');

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
(8, 1, '2026-02-10 06:35:41', '2026-02-10 10:29:24', 0.00, 1000.00, 'closed', NULL, '2026-02-10 01:35:41', '2026-02-10 05:29:24'),
(9, 1, '2026-02-10 10:29:36', '2026-02-10 10:45:14', 0.00, 0.00, 'closed', NULL, '2026-02-10 05:29:36', '2026-02-10 05:45:14'),
(10, 1, '2026-02-10 10:45:40', '2026-02-10 10:56:35', 0.00, 0.00, 'closed', NULL, '2026-02-10 05:45:40', '2026-02-10 05:56:35'),
(11, 1, '2026-02-10 10:56:42', '2026-02-10 11:24:08', 0.00, 0.00, 'closed', NULL, '2026-02-10 05:56:42', '2026-02-10 06:24:08'),
(12, 1, '2026-02-10 11:24:14', '2026-02-10 12:48:56', 0.00, 500.00, 'closed', NULL, '2026-02-10 06:24:14', '2026-02-10 07:48:56'),
(13, 1, '2026-02-10 12:49:10', '2026-02-11 00:26:16', 0.00, 2000.00, 'closed', NULL, '2026-02-10 07:49:10', '2026-02-10 19:26:16'),
(14, 1, '2026-02-11 16:27:50', '2026-02-11 16:31:48', 0.00, 100.00, 'closed', NULL, '2026-02-11 11:27:50', '2026-02-11 11:31:48'),
(15, 1, '2026-02-11 16:31:59', '2026-02-11 16:33:25', 0.00, 1000.00, 'closed', NULL, '2026-02-11 11:31:59', '2026-02-11 11:33:25'),
(16, 1, '2026-02-11 16:33:44', '2026-02-11 19:45:19', 0.00, 200.00, 'closed', NULL, '2026-02-11 11:33:44', '2026-02-11 14:45:19'),
(17, 1, '2026-02-11 14:56:08', '2026-02-11 20:47:18', 0.00, 679.00, 'closed', NULL, '2026-02-11 13:56:08', '2026-02-11 15:47:18'),
(18, 1, '2026-02-11 14:57:32', '2026-02-11 20:47:26', 0.00, 8.00, 'closed', NULL, '2026-02-11 13:57:32', '2026-02-11 15:47:26'),
(19, 1, '2026-02-11 14:58:31', '2026-02-11 20:47:27', 0.00, 8.00, 'closed', NULL, '2026-02-11 13:58:31', '2026-02-11 15:47:27'),
(20, 1, '2026-02-11 14:59:18', '2026-02-12 00:52:18', 0.00, 0.00, 'closed', NULL, '2026-02-11 13:59:18', '2026-02-11 19:52:18'),
(21, 1, '2026-02-12 00:52:47', '2026-02-12 01:22:08', 0.00, 76.00, 'closed', NULL, '2026-02-11 19:52:47', '2026-02-11 20:22:08'),
(22, 1, '2026-02-12 01:22:31', '2026-02-12 02:00:05', 0.00, 76.00, 'closed', NULL, '2026-02-11 20:22:31', '2026-02-11 21:00:05'),
(23, 1, '2026-02-12 02:10:38', '2026-02-12 02:56:02', 0.00, 20000.00, 'closed', NULL, '2026-02-11 21:10:38', '2026-02-11 21:56:02'),
(24, 1, '2026-02-12 04:42:18', NULL, 0.00, 0.00, 'open', NULL, '2026-02-11 23:42:18', '2026-02-11 23:42:18');

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
(7, 1, 'admin', '2026-02-10 05:34:25', '2026-02-10 06:35:08', 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0.00, 0.00, 0.00, 2000.00, 2000.00, '{\"start_cash\":0,\"cash_sales\":\"0.00\",\"card_sales\":\"0.00\",\"expenses\":\"0.00\"}', '', '2026-02-10 01:35:08'),
(8, 1, 'admin', '2026-02-10 06:35:41', '2026-02-10 10:29:24', 402.00, 402.00, 0.00, 0.00, 402.00, 2, 0, 0.00, 0.00, 402.00, 1000.00, 598.00, '{\"start_cash\":0,\"cash_sales\":\"402.00\",\"card_sales\":\"0.00\",\"expenses\":\"0.00\"}', '', '2026-02-10 05:29:24'),
(9, 1, 'admin', '2026-02-10 10:29:36', '2026-02-10 10:45:14', 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0.00, 0.00, 0.00, 0.00, 0.00, '{\"start_cash\":0,\"cash_sales\":\"0.00\",\"card_sales\":\"0.00\",\"expenses\":\"0.00\"}', '', '2026-02-10 05:45:14'),
(10, 1, 'admin', '2026-02-10 10:45:40', '2026-02-10 10:56:35', 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0.00, 0.00, 0.00, 0.00, 0.00, '{\"start_cash\":0,\"cash_sales\":\"0.00\",\"card_sales\":\"0.00\",\"expenses\":\"0.00\"}', '', '2026-02-10 05:56:35'),
(11, 1, 'admin', '2026-02-10 10:56:42', '2026-02-10 11:24:08', 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0.00, 0.00, 0.00, 0.00, 0.00, '{\"start_cash\":0,\"cash_sales\":\"0.00\",\"card_sales\":\"0.00\",\"expenses\":\"0.00\"}', '', '2026-02-10 06:24:08'),
(12, 1, 'admin', '2026-02-10 11:24:14', '2026-02-10 12:48:56', 471.50, 471.50, 0.00, 0.00, 471.50, 4, 0, 0.00, 0.00, 471.50, 500.00, 28.50, '{\"start_cash\":0,\"cash_sales\":\"471.50\",\"card_sales\":\"0.00\",\"expenses\":\"0.00\"}', '', '2026-02-10 07:48:56'),
(13, 1, 'admin', '2026-02-10 12:49:10', '2026-02-11 00:26:16', 1029.50, 1029.50, 0.00, 0.00, 1029.50, 5, 0, 0.00, 0.00, 1029.50, 2000.00, 970.50, '{\"start_cash\":0,\"cash_sales\":\"1029.50\",\"card_sales\":\"0.00\",\"expenses\":\"0.00\"}', '', '2026-02-10 19:26:16'),
(14, 1, 'admin', '2026-02-11 16:27:50', '2026-02-11 16:31:48', 572.00, 572.00, 0.00, 0.00, 572.00, 4, 0, 0.00, 0.00, 572.00, 100.00, -472.00, '{\"start_cash\":0,\"cash_sales\":\"572.00\",\"card_sales\":\"0.00\",\"expenses\":\"0.00\"}', '', '2026-02-11 11:31:48'),
(15, 1, 'admin', '2026-02-11 16:31:59', '2026-02-11 16:33:25', 165.50, 165.50, 0.00, 0.00, 165.50, 1, 0, 0.00, 0.00, 165.50, 1000.00, 834.50, '{\"start_cash\":0,\"cash_sales\":\"165.50\",\"card_sales\":\"0.00\",\"expenses\":\"0.00\"}', '', '2026-02-11 11:33:25'),
(16, 1, 'admin', '2026-02-11 16:33:44', '2026-02-11 19:45:19', 3768.50, 3768.50, 0.00, 500.00, 3268.50, 26, 0, 0.00, 0.00, 3268.50, 200.00, -3068.50, '{\"start_cash\":0,\"cash_sales\":\"3768.50\",\"card_sales\":\"0.00\",\"expenses\":\"500.00\"}', '', '2026-02-11 14:45:19'),
(17, 1, 'admin', '2026-02-11 14:56:08', '2026-02-11 20:47:18', 2323.50, 2323.50, 0.00, 0.00, 2323.50, 5, 0, 0.00, 0.00, 2323.50, 679.00, -1644.50, '{\"start_cash\":0,\"cash_sales\":\"2323.50\",\"card_sales\":\"0.00\",\"expenses\":\"0.00\"}', '', '2026-02-11 15:47:18'),
(18, 1, 'admin', '2026-02-11 14:57:32', '2026-02-11 20:47:26', 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0.00, 0.00, 0.00, 8.00, 8.00, '{\"start_cash\":0,\"cash_sales\":\"0.00\",\"card_sales\":\"0.00\",\"expenses\":\"0.00\"}', '', '2026-02-11 15:47:26'),
(19, 1, 'admin', '2026-02-11 14:58:31', '2026-02-11 20:47:27', 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0.00, 0.00, 0.00, 8.00, 8.00, '{\"start_cash\":0,\"cash_sales\":\"0.00\",\"card_sales\":\"0.00\",\"expenses\":\"0.00\"}', '', '2026-02-11 15:47:27'),
(20, 1, 'admin', '2026-02-11 14:59:18', '2026-02-12 00:52:18', 3226.50, 3226.50, 0.00, 0.00, 3226.50, 20, 0, 0.00, 0.00, 3226.50, 0.00, -3226.50, '{\"start_cash\":0,\"cash_sales\":\"3226.50\",\"card_sales\":\"0.00\",\"expenses\":\"0.00\"}', '', '2026-02-11 19:52:18'),
(21, 1, 'admin', '2026-02-12 00:52:47', '2026-02-12 01:22:08', 7280.00, 7280.00, 0.00, 0.00, 7280.00, 10, 0, 0.00, 0.00, 7280.00, 76.00, -7204.00, '{\"start_cash\":0,\"cash_sales\":\"7280.00\",\"card_sales\":\"0.00\",\"expenses\":\"0.00\"}', '66', '2026-02-11 20:22:08'),
(22, 1, 'admin', '2026-02-12 01:22:31', '2026-02-12 02:00:05', 456.00, 456.00, 0.00, 0.00, 456.00, 1, 0, 0.00, 0.00, 456.00, 76.00, -380.00, '{\"start_cash\":0,\"cash_sales\":\"456.00\",\"card_sales\":\"0.00\",\"expenses\":\"0.00\"}', 'h', '2026-02-11 21:00:05'),
(23, 1, 'admin', '2026-02-12 02:10:38', '2026-02-12 02:56:02', 906.00, 906.00, 0.00, 0.00, 906.00, 6, 0, 0.00, 0.00, 906.00, 20000.00, 19094.00, '{\"start_cash\":0,\"cash_sales\":\"906.00\",\"card_sales\":\"0.00\",\"expenses\":\"0.00\"}', '', '2026-02-11 21:56:02');

-- --------------------------------------------------------

--
-- Table structure for table `staff`
--

CREATE TABLE `staff` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `role_id` int(11) DEFAULT NULL,
  `role` enum('waiter','chef','manager','cashier') DEFAULT 'waiter',
  `pin` varchar(10) DEFAULT NULL,
  `shift_start` datetime DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `staff`
--

INSERT INTO `staff` (`id`, `name`, `role_id`, `role`, `pin`, `shift_start`, `is_active`, `created_at`) VALUES
(1, 'Alice Johnson', 5, 'waiter', NULL, NULL, 1, '2026-02-07 23:31:15'),
(2, 'Mike Smith', 4, 'chef', NULL, NULL, 1, '2026-02-07 23:31:15'),
(3, 'Sarah Davis', 2, 'manager', NULL, NULL, 1, '2026-02-07 23:31:15');

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
(171, 10, 5.000, 100.000, 'return', 'order', 68, 'System', NULL, '2026-02-10 02:25:57'),
(172, 10, -2.000, 98.000, 'sale', 'order', 65, 'System', NULL, '2026-02-10 06:08:04'),
(173, 10, -1.000, 97.000, 'sale', 'order', 99, 'System', NULL, '2026-02-10 06:34:44'),
(174, 10, -1.000, 96.000, 'sale', 'order', 100, 'System', NULL, '2026-02-10 06:34:59'),
(175, 10, -6.000, 90.000, 'sale', 'order', 101, 'System', NULL, '2026-02-10 06:35:24'),
(176, 10, -1.000, 89.000, 'sale', 'order', 102, 'System', NULL, '2026-02-10 08:32:40'),
(177, 10, -3.000, 86.000, 'sale', 'order', 103, 'System', NULL, '2026-02-10 16:48:02'),
(178, 10, -3.000, 83.000, 'sale', 'order', 104, 'System', NULL, '2026-02-10 16:48:19'),
(179, 10, -1.000, 82.000, 'sale', 'order', 105, 'System', NULL, '2026-02-10 18:14:20'),
(180, 11, -5.000, 95.000, 'sale', 'order', 106, 'System', NULL, '2026-02-10 19:23:05'),
(181, 10, -1.000, 81.000, 'sale', 'order', 107, 'System', NULL, '2026-02-11 11:28:00'),
(182, 10, -1.000, 80.000, 'sale', 'order', 108, 'System', NULL, '2026-02-11 11:28:13'),
(183, 10, -1.000, 79.000, 'sale', 'order', 109, 'System', NULL, '2026-02-11 11:28:22'),
(184, 10, -1.000, 78.000, 'sale', 'order', 110, 'System', NULL, '2026-02-11 11:30:16'),
(185, 10, -1.000, 77.000, 'sale', 'order', 111, 'System', NULL, '2026-02-11 11:32:12'),
(186, 10, -1.000, 76.000, 'sale', 'order', 112, 'System', NULL, '2026-02-11 11:33:53'),
(187, 10, -6.000, 70.000, 'sale', 'order', 113, 'System', NULL, '2026-02-11 11:34:48'),
(188, 11, -95.000, 0.000, 'sale', 'order', 114, 'System', NULL, '2026-02-11 11:40:32'),
(189, 11, 20.000, 20.000, 'restock', NULL, NULL, 'System', 'Stock In', '2026-02-11 11:41:46'),
(190, 11, 95.000, 115.000, 'return', 'order', 114, 'System', NULL, '2026-02-11 11:42:58'),
(191, 11, -1.000, 114.000, 'sale', 'order', 116, 'System', NULL, '2026-02-11 11:48:02'),
(192, 10, -1.000, 69.000, 'sale', 'order', 116, 'System', NULL, '2026-02-11 11:48:02'),
(193, 10, -1.000, 68.000, 'sale', 'order', 115, 'System', NULL, '2026-02-11 11:50:01'),
(194, 11, -1.000, 113.000, 'sale', 'order', 115, 'System', NULL, '2026-02-11 11:50:01'),
(195, 11, -1.000, 112.000, 'sale', 'order', 117, 'System', NULL, '2026-02-11 11:50:15'),
(196, 10, -1.000, 67.000, 'sale', 'order', 117, 'System', NULL, '2026-02-11 11:50:15'),
(197, 11, -1.000, 111.000, 'sale', 'order', 118, 'System', NULL, '2026-02-11 11:50:21'),
(198, 10, -1.000, 66.000, 'sale', 'order', 118, 'System', NULL, '2026-02-11 11:50:21'),
(199, 10, -1.000, 65.000, 'sale', 'order', 119, 'System', NULL, '2026-02-11 11:50:49'),
(200, 10, -1.000, 64.000, 'sale', 'order', 120, 'System', NULL, '2026-02-11 11:51:19'),
(201, 10, -2.000, 62.000, 'sale', 'order', 121, 'System', NULL, '2026-02-11 11:52:21'),
(202, 10, -1.000, 61.000, 'sale', 'order', 124, 'System', NULL, '2026-02-11 11:52:51'),
(203, 10, -1.000, 60.000, 'sale', 'order', 125, 'System', NULL, '2026-02-11 11:53:22'),
(204, 10, -5.000, 55.000, 'sale', 'order', 95, 'System', NULL, '2026-02-11 11:53:36'),
(205, 10, -1.000, 54.000, 'sale', 'order', 123, 'System', NULL, '2026-02-11 12:04:21'),
(206, 11, -1.000, 110.000, 'sale', 'order', 127, 'System', NULL, '2026-02-11 12:04:26'),
(207, 10, -1.000, 53.000, 'sale', 'order', 128, 'System', NULL, '2026-02-11 12:27:44'),
(208, 10, -1.000, 52.000, 'sale', 'order', 129, 'System', NULL, '2026-02-11 12:28:35'),
(209, 10, -1.000, 51.000, 'sale', 'order', 130, 'System', NULL, '2026-02-11 12:29:20'),
(210, 11, -3.000, 107.000, 'sale', 'order', 134, 'System', NULL, '2026-02-11 12:29:38'),
(211, 10, -1.000, 50.000, 'sale', 'order', 135, 'System', NULL, '2026-02-11 12:47:12'),
(212, 10, -1.000, 49.000, 'sale', 'order', 122, 'System', NULL, '2026-02-11 12:47:40'),
(213, 11, -2.000, 105.000, 'sale', 'order', 122, 'System', NULL, '2026-02-11 12:47:40'),
(216, 10, -2.000, 47.000, 'sale', 'order', 149, 'System', NULL, '2026-02-11 14:26:38'),
(217, 10, -5.000, 42.000, 'sale', 'order', 138, 'System', NULL, '2026-02-11 14:32:10'),
(218, 10, -1.000, 41.000, 'sale', 'order', 157, 'System', NULL, '2026-02-11 14:32:14'),
(219, 11, -1.000, 104.000, 'sale', 'order', 157, 'System', NULL, '2026-02-11 14:32:14'),
(220, 10, -2.000, 39.000, 'sale', 'order', 158, 'System', NULL, '2026-02-11 14:32:17'),
(221, 11, -2.000, 102.000, 'sale', 'order', 158, 'System', NULL, '2026-02-11 14:32:17'),
(222, 10, -1.000, 38.000, 'sale', 'order', 159, 'System', NULL, '2026-02-11 14:34:22'),
(223, 10, -1.000, 37.000, 'sale', 'order', 160, 'System', NULL, '2026-02-11 14:35:48'),
(224, 10, -1.000, 36.000, 'sale', 'order', 161, 'System', NULL, '2026-02-11 14:36:41'),
(225, 10, -7.000, 29.000, 'sale', 'order', 162, 'System', NULL, '2026-02-11 14:36:45'),
(226, 10, -4.000, 25.000, 'sale', 'order', 163, 'System', NULL, '2026-02-11 14:37:15'),
(227, 10, -1.000, 24.000, 'sale', 'order', 164, 'System', NULL, '2026-02-11 15:41:17'),
(228, 10, -7.000, 17.000, 'sale', 'order', 166, 'System', NULL, '2026-02-11 15:43:34'),
(229, 11, -5.000, 97.000, 'sale', 'order', 166, 'System', NULL, '2026-02-11 15:43:34'),
(230, 11, -2.000, 95.000, 'sale', 'order', 167, 'System', NULL, '2026-02-11 15:44:29'),
(231, 11, -2.000, 93.000, 'sale', 'order', 168, 'System', NULL, '2026-02-11 15:45:03'),
(232, 11, 1.000, 94.000, 'return', NULL, NULL, 'System', 'Return Order INV-1168', '2026-02-11 15:46:23'),
(233, 11, -3.000, 91.000, 'sale', 'order', 169, 'System', NULL, '2026-02-11 15:47:55'),
(234, 10, -1.000, 16.000, 'sale', 'order', 169, 'System', NULL, '2026-02-11 15:47:55'),
(235, 10, -2.000, 14.000, 'sale', 'order', 170, 'System', NULL, '2026-02-11 15:48:10'),
(236, 10, -1.000, 13.000, 'sale', 'order', 171, 'System', NULL, '2026-02-11 19:36:59'),
(237, 10, -13.000, 0.000, 'sale', 'order', 172, 'System', NULL, '2026-02-11 19:53:16'),
(238, 9, -2.000, 80.000, 'sale', 'order', 173, 'System', NULL, '2026-02-11 19:55:02'),
(239, 9, -80.000, 0.000, 'sale', 'order', 174, 'System', NULL, '2026-02-11 19:55:38'),
(240, 11, -1.000, 90.000, 'sale', 'order', 179, 'System', NULL, '2026-02-11 20:09:34'),
(241, 11, -2.000, 88.000, 'sale', 'order', 184, 'System', NULL, '2026-02-11 21:10:53'),
(242, 11, -1.000, 87.000, 'sale', 'order', 185, 'System', NULL, '2026-02-11 21:48:26'),
(243, 11, -1.000, 86.000, 'sale', 'order', 199, 'System', NULL, '2026-02-11 23:42:18'),
(244, 11, -1.000, 85.000, 'sale', 'order', 200, 'System', NULL, '2026-02-11 23:42:41'),
(245, 11, -4.000, 81.000, 'sale', 'order', 202, 'System', NULL, '2026-02-12 00:47:14'),
(246, 11, 4.000, 85.000, 'return', NULL, NULL, 'System', 'Return Order INV-1202', '2026-02-12 00:47:37'),
(247, 11, -85.000, 0.000, 'sale', 'order', 203, 'System', NULL, '2026-02-12 01:52:14');

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
-- Table structure for table `taxes`
--

CREATE TABLE `taxes` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `rate` decimal(10,2) NOT NULL DEFAULT 0.00,
  `type` enum('percentage','fixed') DEFAULT 'percentage',
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
  ADD KEY `idx_order_number` (`order_number`),
  ADD KEY `idx_token_number` (`token_number`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_item_order` (`order_id`),
  ADD KEY `idx_item_product` (`product_id`);

--
-- Indexes for table `order_payments`
--
ALTER TABLE `order_payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`);

--
-- Indexes for table `order_types`
--
ALTER TABLE `order_types`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Indexes for table `payment_methods`
--
ALTER TABLE `payment_methods`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Indexes for table `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

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
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Indexes for table `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD PRIMARY KEY (`role_id`,`permission_id`),
  ADD KEY `permission_id` (`permission_id`);

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
-- Indexes for table `taxes`
--
ALTER TABLE `taxes`
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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `expenses`
--
ALTER TABLE `expenses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `inventory`
--
ALTER TABLE `inventory`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=204;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=554;

--
-- AUTO_INCREMENT for table `order_payments`
--
ALTER TABLE `order_payments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `order_types`
--
ALTER TABLE `order_types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `payment_methods`
--
ALTER TABLE `payment_methods`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `permissions`
--
ALTER TABLE `permissions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `recipes`
--
ALTER TABLE `recipes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `restaurant_tables`
--
ALTER TABLE `restaurant_tables`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `settings`
--
ALTER TABLE `settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2422;

--
-- AUTO_INCREMENT for table `shifts`
--
ALTER TABLE `shifts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `shift_closings`
--
ALTER TABLE `shift_closings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `staff`
--
ALTER TABLE `staff`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `stock_logs`
--
ALTER TABLE `stock_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=248;

--
-- AUTO_INCREMENT for table `suppliers`
--
ALTER TABLE `suppliers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `taxes`
--
ALTER TABLE `taxes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

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
-- Constraints for table `order_payments`
--
ALTER TABLE `order_payments`
  ADD CONSTRAINT `order_payments_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE;

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
-- Constraints for table `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD CONSTRAINT `role_permissions_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `role_permissions_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE;

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
