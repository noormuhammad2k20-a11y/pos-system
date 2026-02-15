-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3307
-- Generation Time: Feb 13, 2026 at 11:39 PM
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
(1, 'Burgers', 1, 1, '2026-02-12 02:27:39'),
(2, 'Pizzas', 2, 1, '2026-02-12 02:27:39'),
(3, 'Drinks', 3, 1, '2026-02-12 02:27:39'),
(4, 'Desserts', 4, 1, '2026-02-12 02:27:39'),
(5, 'Sides', 5, 1, '2026-02-12 02:27:39'),
(6, 'Salads', 6, 1, '2026-02-12 02:27:39'),
(7, 'Sandwiches', 7, 1, '2026-02-12 02:27:39'),
(8, 'Specials', 8, 1, '2026-02-12 02:27:39');

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
(15, NULL, 'Magnam non facilis a', 'Other', 1000.00, 'approved', 1, '2026-02-12 14:58:23'),
(16, NULL, 'Pariatur Facilis vo', 'Ingredients', 6500.00, 'approved', 1, '2026-02-12 21:36:56'),
(17, NULL, 'Et et officiis occae', 'Utilities', 8000.00, 'approved', 1, '2026-02-13 21:56:13'),
(18, NULL, 'Pariatur Voluptatum', 'Other', 7000.00, 'approved', 1, '2026-02-13 21:56:20');

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
(1, 'Burger Bun', 'ING-001', 'Pack', 'Pcs', 1.000, 3.000, 20.000, 0.50, NULL, '2026-02-07 23:31:15', '2026-02-12 22:49:28'),
(2, 'Beef Patty', 'ING-002', 'Box', 'Pcs', 1.000, 468.000, 30.000, 2.00, NULL, '2026-02-07 23:31:15', '2026-02-12 20:40:39'),
(3, 'Cheddar Cheese', 'ING-003', 'Block', 'Slice', 20.000, 500.000, 40.000, 0.20, 3, '2026-02-07 23:31:15', '2026-02-12 02:27:39'),
(4, 'Coca Cola Can', 'DRK-001', 'Case', 'Can', 1.000, 500.000, 12.000, 1.00, NULL, '2026-02-07 23:31:15', '2026-02-12 02:27:39'),
(5, 'Coffee Beans', 'DRK-002', 'Kg', 'Shot', 50.000, 412.000, 50.000, 0.10, 2, '2026-02-07 23:31:15', '2026-02-13 22:18:47'),
(9, 'Coke 250ml', 'SKU-100', 'Pcs', 'Pcs', 1.000, 500.000, 10.000, 80.00, NULL, '2026-02-08 19:28:08', '2026-02-12 02:27:39'),
(10, 'Cakes', 'SKU-900', 'Pcs', 'Pcs', 1.000, 500.000, 5.000, 15.00, 3, '2026-02-08 19:46:54', '2026-02-12 02:27:39'),
(11, 'Aquafina', 'SKU-260209-8916', 'Pcs', 'Pcs', 1.000, 500.000, 10.000, 80.00, 2, '2026-02-09 15:54:26', '2026-02-12 02:27:39');

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
(1, 'INV-1001', 1, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 5100.00, 0.00, 0.00, 0.00, 0.00, 0.00, 5100.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 02:32:30', '2026-02-12 07:32:30', 'paid'),
(2, 'INV-1002', 2, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 4500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 4500.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 02:33:33', '2026-02-12 18:39:34', 'paid'),
(3, 'INV-1003', 3, 1, 2, NULL, 'T-02 (4 seats)', 'dine_in', 1, 'cash', 1, 4500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 4500.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 02:33:52', '2026-02-12 07:34:09', 'paid'),
(4, 'INV-1004', 4, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 3300.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3300.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 13:17:37', '2026-02-12 18:17:37', 'paid'),
(5, 'INV-1005', 5, 1, 2, NULL, 'T-02 (4 seats)', 'dine_in', 1, 'cash', 1, 3300.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3300.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 13:18:09', '2026-02-12 18:18:36', 'paid'),
(6, 'INV-1006', 6, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 3300.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3300.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 13:18:24', '2026-02-12 18:18:24', 'paid'),
(7, 'INV-1007', 7, 1, 2, NULL, 'T-02 (4 seats)', 'dine_in', 1, 'cash', 1, 9900.00, 0.00, 0.00, 0.00, 0.00, 0.00, 9900.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 13:18:51', '2026-02-12 18:19:02', 'paid'),
(8, 'INV-1008', 8, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 6000.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 13:36:41', '2026-02-12 18:36:41', 'paid'),
(9, 'INV-1009', 9, 1, 2, NULL, 'T-02 (4 seats)', 'dine_in', 1, 'cash', 1, 14600.00, 0.00, 0.00, 0.00, 0.00, 0.00, 14600.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 13:37:38', '2026-02-12 18:38:03', 'paid'),
(10, 'INV-1010', 10, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 1800.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1800.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 13:41:24', '2026-02-12 18:41:26', 'paid'),
(11, 'INV-1011', 11, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 5800.00, 0.00, 0.00, 0.00, 0.00, 0.00, 5800.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 13:59:11', '2026-02-12 18:59:11', 'paid'),
(12, 'INV-1012', 12, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 4800.00, 0.00, 0.00, 0.00, 0.00, 0.00, 4800.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 14:04:43', '2026-02-12 19:04:43', 'paid'),
(13, 'INV-1013', 13, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 3300.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3300.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 14:05:46', '2026-02-12 19:05:46', 'paid'),
(14, 'INV-1014', 14, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 3300.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3300.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 14:34:32', '2026-02-12 19:34:32', 'paid'),
(15, 'INV-1015', 15, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 3300.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3300.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 14:35:55', '2026-02-12 19:35:55', 'paid'),
(16, 'INV-1016', 16, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 14300.00, 0.00, 0.00, 0.00, 0.00, 0.00, 14300.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 14:36:16', '2026-02-12 19:36:26', 'paid'),
(17, 'INV-1017', 17, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 331800.00, 0.00, 0.00, 0.00, 0.00, 0.00, 331800.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 14:48:51', '2026-02-12 19:48:54', 'paid'),
(18, 'INV-1018', 18, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 1400.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1400.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 14:50:36', '2026-02-12 19:50:39', 'paid'),
(19, 'INV-1019', 19, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 5100.00, 0.00, 0.00, 0.00, 0.00, 0.00, 5100.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 14:54:11', '2026-02-12 19:54:11', 'paid'),
(20, 'INV-1020', 20, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 6000.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 14:54:53', '2026-02-12 19:55:04', 'paid'),
(21, 'INV-1021', 21, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 2800.00, 0.00, 0.00, 0.00, 0.00, 0.00, 2800.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 14:56:38', '2026-02-12 19:56:48', 'paid'),
(22, 'INV-1022', 22, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 1800.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1800.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 15:00:38', '2026-02-12 20:00:41', 'paid'),
(23, 'INV-1023', 23, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 5100.00, 0.00, 0.00, 0.00, 0.00, 0.00, 5100.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 15:01:04', '2026-02-12 20:01:07', 'paid'),
(24, 'INV-1024', 24, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 1400.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1400.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 15:01:27', '2026-02-12 20:01:27', 'paid'),
(25, 'INV-1025', 25, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 2100.00, 0.00, 0.00, 0.00, 0.00, 0.00, 2100.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 15:01:36', '2026-02-13 01:39:37', 'paid'),
(26, 'INV-1026', 26, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 3600.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3600.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 15:01:47', '2026-02-12 20:01:47', 'paid'),
(27, 'INV-1027', 27, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 9600.00, 0.00, 0.00, 0.00, 0.00, 0.00, 9600.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 15:09:02', '2026-02-12 20:09:02', 'paid'),
(28, 'INV-1028', 28, 1, 2, NULL, 'T-02 (4 seats)', 'dine_in', 1, 'cash', 1, 9750.00, 0.00, 0.00, 0.00, 0.00, 0.00, 9750.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 15:09:19', '2026-02-13 01:40:00', 'paid'),
(29, 'INV-1029', 29, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 2400.00, 0.00, 0.00, 0.00, 0.00, 0.00, 2400.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 16:07:40', '2026-02-12 21:07:40', 'paid'),
(30, 'INV-1030', 1, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '', 0, NULL, NULL, 'No', '2026-02-12 19:58:41', '2026-02-13 00:58:41', 'paid'),
(31, 'INV-1031', 2, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '', 0, NULL, NULL, 'No', '2026-02-12 20:07:03', '2026-02-13 01:07:03', 'paid'),
(32, 'INV-1032', 3, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 9900.00, 0.00, 0.00, 0.00, 0.00, 0.00, 9900.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 20:40:17', '2026-02-13 01:40:39', 'paid'),
(33, 'INV-1033', 4, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 18350.00, 0.00, 0.00, 0.00, 0.00, 0.00, 18350.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 20:54:03', '2026-02-13 01:54:20', 'paid'),
(34, 'INV-1034', 5, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 44850.00, 0.00, 0.00, 0.00, 0.00, 0.00, 44850.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 20:55:03', '2026-02-13 01:55:22', 'paid'),
(35, 'INV-1035', 6, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 14950.00, 0.00, 0.00, 0.00, 0.00, 0.00, 14950.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 21:05:08', '2026-02-13 02:05:42', 'paid'),
(36, 'INV-1036', 7, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 14950.00, 0.00, 0.00, 0.00, 0.00, 0.00, 14950.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 21:05:19', '2026-02-13 02:05:19', 'paid'),
(37, 'INV-1037', 8, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 43350.00, 0.00, 0.00, 0.00, 0.00, 0.00, 43350.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 21:15:11', '2026-02-13 02:23:59', 'paid'),
(38, 'INV-1038', 9, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 14950.00, 0.00, 0.00, 0.00, 0.00, 0.00, 14950.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 21:15:22', '2026-02-13 02:15:22', 'paid'),
(39, 'INV-1039', 10, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 14950.00, 0.00, 0.00, 0.00, 0.00, 0.00, 14950.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 21:15:59', '2026-02-13 02:15:59', 'paid'),
(40, 'INV-1040', 11, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 14950.00, 0.00, 0.00, 0.00, 0.00, 0.00, 14950.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 21:18:55', '2026-02-13 02:18:55', 'paid'),
(41, 'INV-1041', 12, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 1800.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1800.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 22:44:07', '2026-02-13 03:44:07', 'paid'),
(42, 'INV-1042', 13, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 2500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 2500.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 22:49:28', '2026-02-13 03:49:28', 'paid'),
(43, 'INV-1043', 14, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 1100.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1100.00, 'pending', 0, NULL, NULL, NULL, '2026-02-12 22:49:42', NULL, 'unpaid'),
(44, 'INV-1044', 15, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 1800.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1800.00, 'completed', 0, NULL, NULL, NULL, '2026-02-12 23:26:32', '2026-02-13 04:26:32', 'paid'),
(45, 'INV-1045', 16, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 1800.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1800.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 00:05:03', '2026-02-13 05:05:03', 'paid'),
(46, 'INV-1046', 17, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 1800.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1800.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 00:08:57', '2026-02-13 05:08:57', 'paid'),
(47, 'INV-1047', 18, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 900.00, 0.00, 0.00, 0.00, 0.00, 0.00, 900.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 00:09:47', '2026-02-13 05:09:47', 'paid'),
(48, 'INV-1048', 19, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 5600.00, 0.00, 0.00, 0.00, 0.00, 0.00, 5600.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 00:10:19', '2026-02-13 05:10:19', 'paid'),
(49, 'INV-1049', 20, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 4150.00, 0.00, 0.00, 0.00, 0.00, 0.00, 4150.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 14:46:52', '2026-02-13 20:36:14', 'paid'),
(50, 'INV-1050', 21, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 4850.00, 0.00, 0.00, 0.00, 0.00, 0.00, 4850.00, 'pending', 0, NULL, NULL, NULL, '2026-02-13 15:24:49', NULL, 'unpaid'),
(51, 'INV-1051', 22, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 1800.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1800.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 15:25:00', '2026-02-13 20:25:00', 'paid'),
(52, 'INV-1052', 23, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 1800.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1800.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 15:26:29', '2026-02-13 20:26:29', 'paid'),
(53, 'INV-1053', 24, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 3350.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3350.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 15:26:53', '2026-02-13 20:26:53', 'paid'),
(54, 'INV-1054', 25, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 22650.00, 0.00, 0.00, 0.00, 0.00, 0.00, 22650.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 15:27:45', '2026-02-13 20:27:45', 'paid'),
(55, 'INV-1055', 26, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 5750.00, 0.00, 0.00, 0.00, 0.00, 0.00, 5750.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 15:35:26', '2026-02-13 20:35:26', 'paid'),
(56, 'INV-1056', 27, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 14300.00, 0.00, 0.00, 0.00, 0.00, 0.00, 14300.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 15:36:26', '2026-02-13 20:36:36', 'paid'),
(57, 'INV-1057', 28, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 4250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 4250.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 15:36:48', '2026-02-13 20:36:52', 'paid'),
(58, 'INV-1058', 29, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 1450.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1450.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 15:37:00', '2026-02-13 20:37:03', 'paid'),
(59, 'INV-1059', 30, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 1800.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1800.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 15:37:14', '2026-02-13 20:37:17', 'paid'),
(60, 'INV-1060', 31, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 4250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 4250.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 15:37:27', '2026-02-13 20:37:27', 'paid'),
(61, 'INV-1061', 1, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 1800.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1800.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 20:08:04', '2026-02-14 01:08:04', 'paid'),
(62, 'INV-1062', 2, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 9700.00, 0.00, 0.00, 0.00, 0.00, 0.00, 9700.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 20:09:48', '2026-02-14 01:09:57', 'paid'),
(63, 'INV-1063', 3, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 2100.00, 0.00, 0.00, 0.00, 0.00, 0.00, 2100.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 20:10:27', '2026-02-14 01:45:44', 'paid'),
(64, 'INV-1064', 4, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 2100.00, 0.00, 0.00, 0.00, 0.00, 0.00, 2100.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 20:23:07', '2026-02-14 01:23:07', 'paid'),
(65, 'INV-1065', 5, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 5650.00, 0.00, 0.00, 0.00, 0.00, 0.00, 5650.00, 'pending', 0, NULL, NULL, NULL, '2026-02-13 20:23:52', NULL, 'unpaid'),
(66, 'INV-1066', 6, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 4200.00, 0.00, 0.00, 0.00, 0.00, 0.00, 4200.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 20:24:20', '2026-02-14 01:24:20', 'paid'),
(67, 'INV-1067', 7, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 5750.00, 0.00, 0.00, 0.00, 0.00, 0.00, 5750.00, 'held', 0, NULL, NULL, NULL, '2026-02-13 20:29:49', NULL, 'unpaid'),
(68, 'INV-1068', 8, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 5750.00, 0.00, 0.00, 0.00, 0.00, 0.00, 5750.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 20:29:57', '2026-02-14 01:29:57', 'paid'),
(69, 'INV-1069', 9, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 4250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 4250.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 20:39:11', '2026-02-14 01:39:11', 'paid'),
(70, 'INV-1070', 10, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3500.00, 'pending', 0, NULL, NULL, NULL, '2026-02-13 20:39:54', NULL, 'unpaid'),
(71, 'INV-1071', 11, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 5500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 5500.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 20:44:27', '2026-02-14 01:44:27', 'paid'),
(72, 'INV-1072', 12, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 5750.00, 0.00, 0.00, 0.00, 0.00, 0.00, 5750.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 21:11:46', '2026-02-14 02:11:46', 'paid'),
(73, 'INV-1073', 13, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 5100.00, 0.00, 0.00, 0.00, 0.00, 0.00, 5100.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 21:12:57', '2026-02-14 02:13:00', 'paid'),
(74, 'INV-1074', 14, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 4250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 4250.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 21:13:51', '2026-02-14 02:18:12', 'paid'),
(75, 'INV-1075', 15, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 4400.00, 0.00, 0.00, 0.00, 0.00, 0.00, 4400.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 21:14:03', '2026-02-14 02:14:03', 'paid'),
(76, 'INV-1076', 16, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 4850.00, 0.00, 0.00, 0.00, 0.00, 0.00, 4850.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 21:14:25', '2026-02-14 02:14:25', 'paid'),
(77, 'INV-1077', 17, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 8450.00, 0.00, 0.00, 0.00, 0.00, 0.00, 8450.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 21:16:40', '2026-02-14 02:16:40', 'paid'),
(78, 'INV-1078', 18, 1, 1, NULL, 'T-01 (4 seats)', 'dine_in', 1, 'cash', 1, 2800.00, 0.00, 0.00, 0.00, 0.00, 0.00, 2800.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 21:20:19', '2026-02-14 02:20:22', 'paid'),
(79, 'INV-1079', 19, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 2950.00, 0.00, 0.00, 0.00, 0.00, 0.00, 2950.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 21:23:15', '2026-02-14 02:23:15', 'paid'),
(80, 'INV-1080', 20, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 5750.00, 0.00, 0.00, 0.00, 0.00, 0.00, 5750.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 21:24:04', '2026-02-14 02:24:04', 'paid'),
(81, 'INV-1081', 21, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 7150.00, 0.00, 0.00, 0.00, 0.00, 0.00, 7150.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 21:28:01', '2026-02-14 02:28:01', 'paid'),
(82, 'INV-1082', 22, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 5750.00, 0.00, 0.00, 0.00, 0.00, 0.00, 5750.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 21:39:46', '2026-02-14 02:39:46', 'paid'),
(83, 'INV-1083', 23, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 2800.00, 0.00, 0.00, 0.00, 0.00, 0.00, 2800.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 21:46:07', '2026-02-14 02:46:07', 'paid'),
(84, 'INV-1084', 24, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 27600.00, 0.00, 0.00, 0.00, 0.00, 0.00, 27600.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 21:48:15', '2026-02-14 02:48:15', 'paid'),
(85, 'INV-1085', 25, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 5100.00, 0.00, 0.00, 0.00, 0.00, 0.00, 5100.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 21:49:16', '2026-02-14 02:49:16', 'paid'),
(86, 'INV-1086', 26, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 2050.00, 0.00, 0.00, 0.00, 0.00, 0.00, 2050.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 21:51:05', '2026-02-14 02:51:05', 'paid'),
(87, 'INV-1087', 27, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 13050.00, 0.00, 0.00, 0.00, 0.00, 0.00, 13050.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 21:53:56', '2026-02-14 02:53:56', 'paid'),
(88, 'INV-1088', 28, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 4250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 4250.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 22:01:55', '2026-02-14 03:01:55', 'paid'),
(89, 'INV-1089', 29, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 4250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 4250.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 22:04:32', '2026-02-14 03:04:32', 'paid'),
(90, 'INV-1090', 30, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 5750.00, 0.00, 0.00, 0.00, 0.00, 0.00, 5750.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 22:11:51', '2026-02-14 03:11:51', 'paid'),
(91, 'INV-1091', 31, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 7150.00, 0.00, 0.00, 0.00, 0.00, 0.00, 7150.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 22:18:47', '2026-02-14 03:18:47', 'paid'),
(92, 'INV-1092', 32, 1, NULL, NULL, 'Walk-in', '', 4, 'cash', 1, 5700.00, 0.00, 0.00, 0.00, 0.00, 0.00, 5700.00, 'completed', 0, NULL, NULL, NULL, '2026-02-13 22:27:42', '2026-02-14 03:27:42', 'paid');

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
(1, 1, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-13 20:26:34'),
(2, 1, 1, 'Classic Angus Burger', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(3, 1, 19, 'Classic Caesar Chicken', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(4, 1, 6, 'Double Pepperoni Feast', 1, 1800.00, '', 1, '2026-02-13 20:26:34'),
(5, 2, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-13 20:26:34'),
(6, 2, 6, 'Double Pepperoni Feast', 1, 1800.00, '', 1, '2026-02-13 20:26:34'),
(7, 2, 1, 'Classic Angus Burger', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(8, 3, 13, 'Belgian Chocolate Lava', 3, 900.00, '', 1, '2026-02-13 20:26:34'),
(10, 4, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-13 20:26:34'),
(11, 4, 1, 'Classic Angus Burger', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(12, 4, 19, 'Classic Caesar Chicken', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(13, 5, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-13 20:26:34'),
(14, 5, 1, 'Classic Angus Burger', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(15, 5, 19, 'Classic Caesar Chicken', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(16, 6, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-13 20:26:34'),
(17, 6, 1, 'Classic Angus Burger', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(18, 6, 19, 'Classic Caesar Chicken', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(19, 7, 13, 'Belgian Chocolate Lava', 3, 900.00, '', 1, '2026-02-13 20:26:34'),
(20, 7, 1, 'Classic Angus Burger', 3, 1200.00, '', 1, '2026-02-13 20:26:34'),
(21, 7, 19, 'Classic Caesar Chicken', 3, 1200.00, '', 1, '2026-02-13 20:26:34'),
(22, 8, 13, 'Belgian Chocolate Lava', 2, 900.00, '', 1, '2026-02-13 20:26:34'),
(23, 8, 1, 'Classic Angus Burger', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(24, 8, 19, 'Classic Caesar Chicken', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(25, 8, 6, 'Double Pepperoni Feast', 1, 1800.00, '', 1, '2026-02-13 20:26:34'),
(26, 9, 19, 'Classic Caesar Chicken', 3, 1200.00, '', 1, '2026-02-13 20:26:34'),
(27, 9, 6, 'Double Pepperoni Feast', 3, 1800.00, '', 1, '2026-02-13 20:26:34'),
(28, 9, 8, 'Garden Veggie', 2, 1700.00, '', 1, '2026-02-13 20:26:34'),
(29, 9, 1, 'Classic Angus Burger', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(30, 9, 11, 'Fresh Green Juice', 1, 700.00, '', 1, '2026-02-13 20:26:34'),
(32, 10, 13, 'Belgian Chocolate Lava', 2, 900.00, '', 1, '2026-02-13 20:26:34'),
(33, 11, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-13 20:26:34'),
(34, 11, 19, 'Classic Caesar Chicken', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(35, 11, 1, 'Classic Angus Burger', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(36, 11, 6, 'Double Pepperoni Feast', 1, 1800.00, '', 1, '2026-02-13 20:26:34'),
(37, 11, 11, 'Fresh Green Juice', 1, 700.00, '', 1, '2026-02-13 20:26:34'),
(38, 12, 13, 'Belgian Chocolate Lava', 2, 900.00, '', 1, '2026-02-13 20:26:34'),
(39, 12, 1, 'Classic Angus Burger', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(40, 12, 6, 'Double Pepperoni Feast', 1, 1800.00, '', 1, '2026-02-13 20:26:34'),
(41, 13, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-13 20:26:34'),
(42, 13, 1, 'Classic Angus Burger', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(43, 13, 19, 'Classic Caesar Chicken', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(44, 14, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-13 20:26:34'),
(45, 14, 1, 'Classic Angus Burger', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(46, 14, 19, 'Classic Caesar Chicken', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(47, 15, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-13 20:26:34'),
(48, 15, 1, 'Classic Angus Burger', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(49, 15, 19, 'Classic Caesar Chicken', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(50, 16, 19, 'Classic Caesar Chicken', 3, 1200.00, '', 1, '2026-02-13 20:26:34'),
(51, 16, 1, 'Classic Angus Burger', 3, 1200.00, '', 1, '2026-02-13 20:26:34'),
(52, 16, 13, 'Belgian Chocolate Lava', 2, 900.00, '', 1, '2026-02-13 20:26:34'),
(53, 16, 10, 'Premium Roasted Latte', 2, 550.00, '', 1, '2026-02-13 20:26:34'),
(54, 16, 6, 'Double Pepperoni Feast', 1, 1800.00, '', 1, '2026-02-13 20:26:34'),
(55, 16, 11, 'Fresh Green Juice', 1, 700.00, '', 1, '2026-02-13 20:26:34'),
(56, 16, 8, 'Garden Veggie', 1, 1700.00, '', 1, '2026-02-13 20:26:34'),
(57, 17, 11, 'Fresh Green Juice', 474, 700.00, '', 1, '2026-02-13 20:26:34'),
(58, 18, 11, 'Fresh Green Juice', 2, 700.00, '', 1, '2026-02-13 20:26:34'),
(59, 19, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-13 20:26:34'),
(60, 19, 1, 'Classic Angus Burger', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(61, 19, 19, 'Classic Caesar Chicken', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(62, 19, 6, 'Double Pepperoni Feast', 1, 1800.00, '', 1, '2026-02-13 20:26:34'),
(63, 20, 13, 'Belgian Chocolate Lava', 4, 900.00, '', 1, '2026-02-13 20:26:34'),
(64, 20, 1, 'Classic Angus Burger', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(65, 20, 19, 'Classic Caesar Chicken', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(66, 21, 11, 'Fresh Green Juice', 4, 700.00, '', 1, '2026-02-13 20:26:34'),
(67, 22, 13, 'Belgian Chocolate Lava', 2, 900.00, '', 1, '2026-02-13 20:26:34'),
(68, 23, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-13 20:26:34'),
(69, 23, 1, 'Classic Angus Burger', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(70, 23, 19, 'Classic Caesar Chicken', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(71, 23, 6, 'Double Pepperoni Feast', 1, 1800.00, '', 1, '2026-02-13 20:26:34'),
(72, 24, 11, 'Fresh Green Juice', 2, 700.00, '', 1, '2026-02-13 20:26:34'),
(73, 25, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-13 20:26:34'),
(74, 25, 1, 'Classic Angus Burger', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(75, 26, 1, 'Classic Angus Burger', 3, 1200.00, '', 1, '2026-02-13 20:26:34'),
(76, 27, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-13 20:26:34'),
(77, 27, 1, 'Classic Angus Burger', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(78, 27, 19, 'Classic Caesar Chicken', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(79, 27, 6, 'Double Pepperoni Feast', 1, 1800.00, '', 1, '2026-02-13 20:26:34'),
(80, 27, 11, 'Fresh Green Juice', 1, 700.00, '', 1, '2026-02-13 20:26:34'),
(81, 27, 8, 'Garden Veggie', 1, 1700.00, '', 1, '2026-02-13 20:26:34'),
(82, 27, 15, 'Madagascar Vanilla Crème Brûlée', 1, 1000.00, '', 1, '2026-02-13 20:26:34'),
(83, 27, 20, 'Mediterranean Greek', 1, 1100.00, '', 1, '2026-02-13 20:26:34'),
(84, 28, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-13 20:26:34'),
(85, 28, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-13 20:26:34'),
(86, 28, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-13 20:26:34'),
(87, 28, 1, 'Classic Angus Burger', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(88, 28, 19, 'Classic Caesar Chicken', 1, 1200.00, '', 1, '2026-02-13 20:26:34'),
(89, 28, 6, 'Double Pepperoni Feast', 1, 1800.00, '', 1, '2026-02-13 20:26:34'),
(90, 28, 11, 'Fresh Green Juice', 1, 700.00, '', 1, '2026-02-13 20:26:34'),
(91, 29, 1, 'Classic Angus Burger', 2, 1200.00, '', 1, '2026-02-13 20:26:34'),
(94, 32, 13, 'Belgian Chocolate Lava', 3, 900.00, '', 1, '2026-02-13 20:26:34'),
(95, 32, 1, 'Classic Angus Burger', 3, 1200.00, '', 1, '2026-02-13 20:26:34'),
(96, 32, 19, 'Classic Caesar Chicken', 3, 1200.00, '', 1, '2026-02-13 20:26:34'),
(97, 33, 13, 'Belgian Chocolate Lava', 2, 900.00, '', 1, '2026-02-13 20:26:34'),
(98, 33, 19, 'Classic Caesar Chicken', 2, 1200.00, '', 1, '2026-02-13 20:26:34'),
(99, 33, 6, 'Double Pepperoni Feast', 2, 1800.00, '', 1, '2026-02-13 20:26:34'),
(100, 33, 8, 'Garden Veggie', 2, 1700.00, '', 1, '2026-02-13 20:26:34'),
(101, 33, 24, 'Wagyu Beef Carpaccio', 1, 2400.00, '', 1, '2026-02-13 20:26:34'),
(102, 33, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-13 20:26:34'),
(103, 33, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-13 20:26:34'),
(104, 33, 3, 'Spicy Jalapeño Burger', 1, 1400.00, '', 1, '2026-02-13 20:26:34'),
(105, 33, 21, 'Superfood Quinoa Bowl', 1, 1300.00, '', 1, '2026-02-13 20:26:34'),
(106, 34, 25, 'Pan-Seared Atlantic Salmon', 3, 2800.00, '', 1, '2026-02-13 20:26:34'),
(107, 34, 10, 'Premium Roasted Latte', 3, 550.00, '', 1, '2026-02-13 20:26:34'),
(108, 34, 5, 'Signature Margherita', 3, 1500.00, '', 1, '2026-02-13 20:26:34'),
(109, 34, 3, 'Spicy Jalapeño Burger', 3, 1400.00, '', 1, '2026-02-13 20:26:34'),
(110, 34, 21, 'Superfood Quinoa Bowl', 3, 1300.00, '', 1, '2026-02-13 20:26:34'),
(111, 34, 7, 'Truffle Honey Pizza', 3, 2200.00, '', 1, '2026-02-13 20:26:34'),
(112, 34, 2, 'Truffle Mushroom Swiss', 3, 1500.00, '', 1, '2026-02-13 20:26:34'),
(113, 34, 22, 'Ultimate Club Sandwich', 3, 1300.00, '', 1, '2026-02-13 20:26:34'),
(114, 34, 24, 'Wagyu Beef Carpaccio', 3, 2400.00, '', 1, '2026-02-13 20:26:34'),
(115, 35, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-13 20:26:34'),
(116, 35, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-13 20:26:34'),
(117, 35, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-13 20:26:34'),
(118, 35, 3, 'Spicy Jalapeño Burger', 1, 1400.00, '', 1, '2026-02-13 20:26:34'),
(119, 35, 21, 'Superfood Quinoa Bowl', 1, 1300.00, '', 1, '2026-02-13 20:26:34'),
(120, 35, 7, 'Truffle Honey Pizza', 1, 2200.00, '', 1, '2026-02-13 20:26:34'),
(121, 35, 2, 'Truffle Mushroom Swiss', 1, 1500.00, '', 1, '2026-02-13 20:26:34'),
(122, 35, 22, 'Ultimate Club Sandwich', 1, 1300.00, '', 1, '2026-02-13 20:26:34'),
(123, 35, 24, 'Wagyu Beef Carpaccio', 1, 2400.00, '', 1, '2026-02-13 20:26:34'),
(124, 36, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-13 20:26:34'),
(125, 36, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-13 20:26:34'),
(126, 36, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-13 20:26:34'),
(127, 36, 3, 'Spicy Jalapeño Burger', 1, 1400.00, '', 1, '2026-02-13 20:26:34'),
(128, 36, 21, 'Superfood Quinoa Bowl', 1, 1300.00, '', 1, '2026-02-13 20:26:34'),
(129, 36, 7, 'Truffle Honey Pizza', 1, 2200.00, '', 1, '2026-02-13 20:26:34'),
(130, 36, 2, 'Truffle Mushroom Swiss', 1, 1500.00, '', 1, '2026-02-13 20:26:34'),
(131, 36, 22, 'Ultimate Club Sandwich', 1, 1300.00, '', 1, '2026-02-13 20:26:34'),
(132, 36, 24, 'Wagyu Beef Carpaccio', 1, 2400.00, '', 1, '2026-02-13 20:26:34'),
(133, 37, 25, 'Pan-Seared Atlantic Salmon', 3, 2800.00, '', 1, '2026-02-13 20:26:34'),
(134, 37, 10, 'Premium Roasted Latte', 3, 550.00, '', 1, '2026-02-13 20:26:34'),
(135, 37, 5, 'Signature Margherita', 2, 1500.00, '', 1, '2026-02-13 20:26:34'),
(136, 37, 3, 'Spicy Jalapeño Burger', 3, 1400.00, '', 1, '2026-02-13 20:26:34'),
(137, 37, 21, 'Superfood Quinoa Bowl', 3, 1300.00, '', 1, '2026-02-13 20:26:34'),
(138, 37, 7, 'Truffle Honey Pizza', 3, 2200.00, '', 1, '2026-02-13 20:26:34'),
(139, 37, 2, 'Truffle Mushroom Swiss', 3, 1500.00, '', 1, '2026-02-13 20:26:34'),
(140, 37, 22, 'Ultimate Club Sandwich', 3, 1300.00, '', 1, '2026-02-13 20:26:34'),
(141, 37, 24, 'Wagyu Beef Carpaccio', 3, 2400.00, '', 1, '2026-02-13 20:26:34'),
(142, 38, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-13 20:26:34'),
(143, 38, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-13 20:26:34'),
(144, 38, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-13 20:26:34'),
(145, 38, 3, 'Spicy Jalapeño Burger', 1, 1400.00, '', 1, '2026-02-13 20:26:34'),
(146, 38, 21, 'Superfood Quinoa Bowl', 1, 1300.00, '', 1, '2026-02-13 20:26:34'),
(147, 38, 7, 'Truffle Honey Pizza', 1, 2200.00, '', 1, '2026-02-13 20:26:34'),
(148, 38, 2, 'Truffle Mushroom Swiss', 1, 1500.00, '', 1, '2026-02-13 20:26:34'),
(149, 38, 22, 'Ultimate Club Sandwich', 1, 1300.00, '', 1, '2026-02-13 20:26:34'),
(150, 38, 24, 'Wagyu Beef Carpaccio', 1, 2400.00, '', 1, '2026-02-13 20:26:34'),
(151, 39, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-13 20:26:34'),
(152, 39, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-13 20:26:34'),
(153, 39, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-13 20:26:34'),
(154, 39, 3, 'Spicy Jalapeño Burger', 1, 1400.00, '', 1, '2026-02-13 20:26:34'),
(155, 39, 21, 'Superfood Quinoa Bowl', 1, 1300.00, '', 1, '2026-02-13 20:26:34'),
(156, 39, 7, 'Truffle Honey Pizza', 1, 2200.00, '', 1, '2026-02-13 20:26:34'),
(157, 39, 2, 'Truffle Mushroom Swiss', 1, 1500.00, '', 1, '2026-02-13 20:26:34'),
(158, 39, 22, 'Ultimate Club Sandwich', 1, 1300.00, '', 1, '2026-02-13 20:26:34'),
(159, 39, 24, 'Wagyu Beef Carpaccio', 1, 2400.00, '', 1, '2026-02-13 20:26:34'),
(160, 40, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-13 20:26:34'),
(161, 40, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-13 20:26:34'),
(162, 40, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-13 20:26:34'),
(163, 40, 3, 'Spicy Jalapeño Burger', 1, 1400.00, '', 1, '2026-02-13 20:26:34'),
(164, 40, 21, 'Superfood Quinoa Bowl', 1, 1300.00, '', 1, '2026-02-13 20:26:34'),
(165, 40, 7, 'Truffle Honey Pizza', 1, 2200.00, '', 1, '2026-02-13 20:26:34'),
(166, 40, 2, 'Truffle Mushroom Swiss', 1, 1500.00, '', 1, '2026-02-13 20:26:34'),
(167, 40, 22, 'Ultimate Club Sandwich', 1, 1300.00, '', 1, '2026-02-13 20:26:34'),
(168, 40, 24, 'Wagyu Beef Carpaccio', 1, 2400.00, '', 1, '2026-02-13 20:26:34'),
(169, 41, 13, 'Belgian Chocolate Lava', 2, 900.00, '', 1, '2026-02-13 20:26:34'),
(170, 42, 6, 'Double Pepperoni Feast', 1, 1800.00, '', 1, '2026-02-13 20:26:34'),
(171, 42, 11, 'Fresh Green Juice', 1, 700.00, '', 1, '2026-02-13 20:26:34'),
(172, 43, 20, 'Mediterranean Greek', 1, 1100.00, '', 1, '2026-02-13 20:26:34'),
(173, 44, 13, 'Belgian Chocolate Lava', 2, 900.00, '', 1, '2026-02-13 20:26:34'),
(174, 45, 13, 'Belgian Chocolate Lava', 2, 900.00, '', 1, '2026-02-13 20:26:34'),
(175, 46, 13, 'Belgian Chocolate Lava', 2, 900.00, '', 1, '2026-02-13 20:26:34'),
(176, 47, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-13 20:26:34'),
(177, 48, 25, 'Pan-Seared Atlantic Salmon', 2, 2800.00, '', 1, '2026-02-13 20:26:34'),
(178, 49, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-13 20:26:34'),
(179, 49, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-13 20:26:34'),
(180, 49, 3, 'Spicy Jalapeño Burger', 1, 1400.00, '', 1, '2026-02-13 20:26:34'),
(181, 49, 21, 'Superfood Quinoa Bowl', 1, 1300.00, '', 1, '2026-02-13 20:26:34'),
(182, 50, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-13 20:26:34'),
(183, 50, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-13 20:26:34'),
(184, 50, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-13 20:26:34'),
(185, 51, 13, 'Belgian Chocolate Lava', 2, 900.00, '', 1, '2026-02-13 20:26:34'),
(186, 52, 13, 'Belgian Chocolate Lava', 2, 900.00, '', 1, '2026-02-13 20:26:34'),
(187, 53, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-13 20:26:58'),
(188, 53, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-13 20:26:58'),
(189, 54, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-13 20:28:11'),
(190, 54, 19, 'Classic Caesar Chicken', 1, 1200.00, '', 1, '2026-02-13 20:28:11'),
(191, 54, 6, 'Double Pepperoni Feast', 1, 1800.00, '', 1, '2026-02-13 20:28:11'),
(192, 54, 8, 'Garden Veggie', 1, 1700.00, '', 1, '2026-02-13 20:28:11'),
(193, 54, 15, 'Madagascar Vanilla Crème Brûlée', 1, 1000.00, '', 1, '2026-02-13 20:28:11'),
(194, 54, 20, 'Mediterranean Greek', 1, 1100.00, '', 1, '2026-02-13 20:28:11'),
(195, 54, 22, 'Ultimate Club Sandwich', 1, 1300.00, '', 1, '2026-02-13 20:28:11'),
(196, 54, 2, 'Truffle Mushroom Swiss', 1, 1500.00, '', 1, '2026-02-13 20:28:11'),
(197, 54, 7, 'Truffle Honey Pizza', 1, 2200.00, '', 1, '2026-02-13 20:28:11'),
(198, 54, 21, 'Superfood Quinoa Bowl', 1, 1300.00, '', 1, '2026-02-13 20:28:11'),
(199, 54, 3, 'Spicy Jalapeño Burger', 1, 1400.00, '', 1, '2026-02-13 20:28:11'),
(200, 54, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-13 20:28:11'),
(201, 54, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-13 20:28:11'),
(202, 54, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-13 20:28:11'),
(203, 54, 24, 'Wagyu Beef Carpaccio', 1, 2400.00, '', 1, '2026-02-13 20:28:11'),
(204, 55, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-13 20:35:43'),
(205, 55, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-13 20:35:43'),
(206, 55, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-13 20:35:43'),
(207, 55, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-13 20:35:43'),
(208, 56, 13, 'Belgian Chocolate Lava', 2, 900.00, '', 1, '2026-02-13 20:37:36'),
(209, 56, 25, 'Pan-Seared Atlantic Salmon', 2, 2800.00, '', 1, '2026-02-13 20:37:36'),
(210, 56, 10, 'Premium Roasted Latte', 2, 550.00, '', 1, '2026-02-13 20:37:36'),
(211, 56, 5, 'Signature Margherita', 2, 1500.00, '', 1, '2026-02-13 20:37:36'),
(212, 56, 3, 'Spicy Jalapeño Burger', 2, 1400.00, '', 1, '2026-02-13 20:37:36'),
(213, 57, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-13 20:37:36'),
(214, 57, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-13 20:37:36'),
(215, 57, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-13 20:37:36'),
(216, 58, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-13 20:37:36'),
(217, 58, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-13 20:37:36'),
(218, 59, 13, 'Belgian Chocolate Lava', 2, 900.00, '', 1, '2026-02-13 20:37:36'),
(219, 60, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-13 20:37:36'),
(220, 60, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-13 20:37:36'),
(221, 60, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-13 20:37:36'),
(222, 61, 13, 'Belgian Chocolate Lava', 2, 900.00, '', 1, '2026-02-14 01:08:22'),
(223, 62, 25, 'Pan-Seared Atlantic Salmon', 2, 2800.00, '', 1, '2026-02-14 01:23:32'),
(224, 62, 10, 'Premium Roasted Latte', 2, 550.00, '', 1, '2026-02-14 01:23:32'),
(225, 62, 5, 'Signature Margherita', 2, 1500.00, '', 1, '2026-02-14 01:23:32'),
(226, 63, 15, 'Madagascar Vanilla Crème Brûlée', 1, 1000.00, '', 1, '2026-02-14 01:23:32'),
(227, 63, 20, 'Mediterranean Greek', 1, 1100.00, '', 1, '2026-02-14 01:23:32'),
(228, 64, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-14 01:23:32'),
(229, 64, 19, 'Classic Caesar Chicken', 1, 1200.00, '', 1, '2026-02-14 01:23:32'),
(230, 65, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-14 01:23:53'),
(231, 65, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-14 01:23:53'),
(232, 65, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-14 01:23:53'),
(233, 65, 3, 'Spicy Jalapeño Burger', 1, 1400.00, '', 1, '2026-02-14 01:23:53'),
(234, 66, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-14 01:24:28'),
(235, 66, 3, 'Spicy Jalapeño Burger', 1, 1400.00, '', 1, '2026-02-14 01:24:28'),
(236, 66, 21, 'Superfood Quinoa Bowl', 1, 1300.00, '', 1, '2026-02-14 01:24:28'),
(237, 67, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 0, NULL),
(238, 67, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 0, NULL),
(239, 67, 10, 'Premium Roasted Latte', 1, 550.00, '', 0, NULL),
(240, 67, 5, 'Signature Margherita', 1, 1500.00, '', 0, NULL),
(241, 68, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-14 01:30:06'),
(242, 68, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-14 01:30:06'),
(243, 68, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-14 01:30:06'),
(244, 68, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-14 01:30:06'),
(245, 69, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-14 01:39:29'),
(246, 69, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-14 01:39:29'),
(247, 69, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-14 01:39:29'),
(248, 70, 6, 'Double Pepperoni Feast', 1, 1800.00, '', 1, '2026-02-14 01:39:54'),
(249, 70, 8, 'Garden Veggie', 1, 1700.00, '', 1, '2026-02-14 01:39:54'),
(250, 71, 13, 'Belgian Chocolate Lava', 2, 900.00, '', 1, '2026-02-14 01:44:44'),
(251, 71, 7, 'Truffle Honey Pizza', 1, 2200.00, '', 1, '2026-02-14 01:44:44'),
(252, 71, 2, 'Truffle Mushroom Swiss', 1, 1500.00, '', 1, '2026-02-14 01:44:44'),
(253, 72, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-14 02:12:26'),
(254, 72, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-14 02:12:26'),
(255, 72, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-14 02:12:26'),
(256, 72, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-14 02:12:26'),
(257, 73, 3, 'Spicy Jalapeño Burger', 1, 1400.00, '', 1, '2026-02-14 02:14:14'),
(258, 73, 2, 'Truffle Mushroom Swiss', 1, 1500.00, '', 1, '2026-02-14 02:14:14'),
(259, 73, 7, 'Truffle Honey Pizza', 1, 2200.00, '', 1, '2026-02-14 02:14:14'),
(260, 74, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-14 02:14:14'),
(261, 74, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-14 02:14:14'),
(262, 74, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-14 02:14:14'),
(263, 75, 15, 'Madagascar Vanilla Crème Brûlée', 2, 1000.00, '', 1, '2026-02-14 02:14:14'),
(264, 75, 20, 'Mediterranean Greek', 1, 1100.00, '', 1, '2026-02-14 02:14:14'),
(265, 75, 22, 'Ultimate Club Sandwich', 1, 1300.00, '', 1, '2026-02-14 02:14:14'),
(266, 76, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-14 02:14:31'),
(267, 76, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-14 02:14:31'),
(268, 76, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-14 02:14:31'),
(269, 77, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-14 02:16:49'),
(270, 77, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-14 02:16:49'),
(271, 77, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-14 02:16:49'),
(272, 77, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-14 02:16:49'),
(273, 77, 3, 'Spicy Jalapeño Burger', 1, 1400.00, '', 1, '2026-02-14 02:16:49'),
(274, 77, 21, 'Superfood Quinoa Bowl', 1, 1300.00, '', 1, '2026-02-14 02:16:49'),
(275, 78, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-14 02:23:48'),
(276, 79, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-14 02:23:48'),
(277, 79, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-14 02:23:48'),
(278, 79, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-14 02:23:48'),
(279, 80, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-14 02:24:12'),
(280, 80, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-14 02:24:12'),
(281, 80, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-14 02:24:12'),
(282, 80, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-14 02:24:12'),
(283, 81, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-14 02:36:36'),
(284, 81, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-14 02:36:36'),
(285, 81, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-14 02:36:36'),
(286, 81, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-14 02:36:36'),
(287, 81, 3, 'Spicy Jalapeño Burger', 1, 1400.00, '', 1, '2026-02-14 02:36:36'),
(288, 82, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-14 02:40:28'),
(289, 82, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-14 02:40:28'),
(290, 82, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-14 02:40:28'),
(291, 82, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-14 02:40:28'),
(292, 83, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-14 02:46:17'),
(293, 83, 21, 'Superfood Quinoa Bowl', 1, 1300.00, '', 1, '2026-02-14 02:46:17'),
(294, 84, 7, 'Truffle Honey Pizza', 2, 2200.00, '', 1, '2026-02-14 02:48:45'),
(295, 84, 22, 'Ultimate Club Sandwich', 2, 1300.00, '', 1, '2026-02-14 02:48:45'),
(296, 84, 21, 'Superfood Quinoa Bowl', 2, 1300.00, '', 1, '2026-02-14 02:48:45'),
(297, 84, 24, 'Wagyu Beef Carpaccio', 2, 2400.00, '', 1, '2026-02-14 02:48:45'),
(298, 84, 10, 'Premium Roasted Latte', 2, 550.00, '', 1, '2026-02-14 02:48:45'),
(299, 84, 19, 'Classic Caesar Chicken', 2, 1200.00, '', 1, '2026-02-14 02:48:45'),
(300, 84, 6, 'Double Pepperoni Feast', 2, 1800.00, '', 1, '2026-02-14 02:48:45'),
(301, 84, 8, 'Garden Veggie', 1, 1700.00, '', 1, '2026-02-14 02:48:45'),
(302, 84, 15, 'Madagascar Vanilla Crème Brûlée', 1, 1000.00, '', 1, '2026-02-14 02:48:45'),
(303, 84, 20, 'Mediterranean Greek', 1, 1100.00, '', 1, '2026-02-14 02:48:45'),
(304, 84, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-14 02:48:45'),
(305, 84, 3, 'Spicy Jalapeño Burger', 1, 1400.00, '', 1, '2026-02-14 02:48:45'),
(306, 85, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-14 02:49:31'),
(307, 85, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-14 02:49:31'),
(308, 85, 3, 'Spicy Jalapeño Burger', 1, 1400.00, '', 1, '2026-02-14 02:49:31'),
(309, 85, 21, 'Superfood Quinoa Bowl', 1, 1300.00, '', 1, '2026-02-14 02:49:31'),
(310, 86, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-14 02:51:16'),
(311, 86, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-14 02:51:16'),
(312, 87, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-14 02:54:48'),
(313, 87, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-14 02:54:48'),
(314, 87, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-14 02:54:48'),
(315, 87, 3, 'Spicy Jalapeño Burger', 1, 1400.00, '', 1, '2026-02-14 02:54:48'),
(316, 87, 21, 'Superfood Quinoa Bowl', 1, 1300.00, '', 1, '2026-02-14 02:54:48'),
(317, 87, 7, 'Truffle Honey Pizza', 1, 2200.00, '', 1, '2026-02-14 02:54:48'),
(318, 87, 2, 'Truffle Mushroom Swiss', 1, 1500.00, '', 1, '2026-02-14 02:54:48'),
(319, 87, 22, 'Ultimate Club Sandwich', 1, 1300.00, '', 1, '2026-02-14 02:54:48'),
(320, 87, 24, 'Wagyu Beef Carpaccio', 1, 2400.00, '', 1, '2026-02-14 02:54:48'),
(321, 88, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-14 03:02:13'),
(322, 88, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-14 03:02:13'),
(323, 88, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-14 03:02:13'),
(324, 89, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-14 03:04:53'),
(325, 89, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-14 03:04:53'),
(326, 89, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-14 03:04:53'),
(327, 90, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-14 03:12:04'),
(328, 90, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-14 03:12:04'),
(329, 90, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-14 03:12:04'),
(330, 90, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-14 03:12:04'),
(331, 91, 13, 'Belgian Chocolate Lava', 1, 900.00, '', 1, '2026-02-14 03:19:09'),
(332, 91, 10, 'Premium Roasted Latte', 1, 550.00, '', 1, '2026-02-14 03:19:09'),
(333, 91, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-14 03:19:09'),
(334, 91, 3, 'Spicy Jalapeño Burger', 1, 1400.00, '', 1, '2026-02-14 03:19:09'),
(335, 91, 21, 'Superfood Quinoa Bowl', 1, 1300.00, '', 1, '2026-02-14 03:19:09'),
(336, 91, 2, 'Truffle Mushroom Swiss', 1, 1500.00, '', 1, '2026-02-14 03:19:09'),
(337, 92, 25, 'Pan-Seared Atlantic Salmon', 1, 2800.00, '', 1, '2026-02-14 03:27:58'),
(338, 92, 5, 'Signature Margherita', 1, 1500.00, '', 1, '2026-02-14 03:27:58'),
(339, 92, 3, 'Spicy Jalapeño Burger', 1, 1400.00, '', 1, '2026-02-14 03:27:58');

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
(1, 'Classic Angus Burger', 1200.00, 450.00, 1, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=1000', NULL, 1, 1, '2026-02-12 02:27:39', '2026-02-12 02:27:39'),
(2, 'Truffle Mushroom Swiss', 1500.00, 600.00, 1, 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?q=80&w=1000', NULL, 1, 2, '2026-02-12 02:27:39', '2026-02-12 02:27:39'),
(3, 'Spicy Jalapeño Burger', 1400.00, 500.00, 1, 'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?q=80&w=1000', NULL, 1, 3, '2026-02-12 02:27:39', '2026-02-12 02:27:39'),
(5, 'Signature Margherita', 1500.00, 500.00, 2, 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?q=80&w=1000', NULL, 1, 1, '2026-02-12 02:27:39', '2026-02-12 02:27:39'),
(6, 'Double Pepperoni Feast', 1800.00, 650.00, 2, 'https://images.unsplash.com/photo-1628840042765-356cda07504e?q=80&w=1000', NULL, 1, 2, '2026-02-12 02:27:39', '2026-02-12 02:27:39'),
(7, 'Truffle Honey Pizza', 2200.00, 800.00, 2, 'https://images.unsplash.com/photo-1513104890138-7c749659a591?q=80&w=1000', NULL, 1, 3, '2026-02-12 02:27:39', '2026-02-12 02:27:39'),
(8, 'Garden Veggie', 1700.00, 550.00, 2, 'https://images.unsplash.com/photo-1571407970349-bc81e7e96d47?q=80&w=1000', NULL, 1, 4, '2026-02-12 02:27:39', '2026-02-12 02:27:39'),
(10, 'Premium Roasted Latte', 550.00, 150.00, 3, 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?q=80&w=1000', NULL, 1, 2, '2026-02-12 02:27:39', '2026-02-12 02:27:39'),
(11, 'Fresh Green Juice', 700.00, 250.00, 3, 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?q=80&w=1000', NULL, 1, 3, '2026-02-12 02:27:39', '2026-02-12 02:27:39'),
(13, 'Belgian Chocolate Lava', 900.00, 350.00, 4, 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?q=80&w=1000', NULL, 1, 1, '2026-02-12 02:27:39', '2026-02-12 02:27:39'),
(15, 'Madagascar Vanilla Crème Brûlée', 1000.00, 400.00, 4, 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?q=80&w=1000', NULL, 1, 3, '2026-02-12 02:27:39', '2026-02-12 02:27:39'),
(19, 'Classic Caesar Chicken', 1200.00, 400.00, 6, 'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?q=80&w=1000', NULL, 1, 1, '2026-02-12 02:27:39', '2026-02-12 02:27:39'),
(20, 'Mediterranean Greek', 1100.00, 350.00, 6, 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?q=80&w=1000', NULL, 1, 2, '2026-02-12 02:27:39', '2026-02-12 02:27:39'),
(21, 'Superfood Quinoa Bowl', 1300.00, 450.00, 6, 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=1000', NULL, 1, 3, '2026-02-12 02:27:39', '2026-02-12 02:27:39'),
(22, 'Ultimate Club Sandwich', 1300.00, 450.00, 7, 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?q=80&w=1000', NULL, 1, 1, '2026-02-12 02:27:39', '2026-02-12 02:27:39'),
(24, 'Wagyu Beef Carpaccio', 2400.00, 1000.00, 8, 'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?q=80&w=1000', NULL, 1, 1, '2026-02-12 02:27:39', '2026-02-12 02:27:39'),
(25, 'Pan-Seared Atlantic Salmon', 2800.00, 1200.00, 8, 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?q=80&w=1000', NULL, 1, 2, '2026-02-12 02:27:39', '2026-02-12 02:27:39');

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
(4, 10, 5, 2.000),
(5, 11, 1, 1.000);

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
(3, 'restaurant_phone', '1234567890', 'text', 'general'),
(4, 'restaurant_logo', 'assets/logo_1771021652.png', 'text', 'receipt'),
(5, 'tax_rate', '0', 'number', 'general'),
(6, 'tax_name', 'VAT', 'text', 'general'),
(7, 'service_charge_rate', '0', 'number', 'general'),
(8, 'packaging_fee', '0', 'number', 'general'),
(9, 'delivery_fee', '0', 'number', 'general'),
(10, 'currency_symbol', 'Rs ', 'text', 'general'),
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
(25, 'table_color_busy', '#c50707', 'text', 'tables'),
(26, 'table_color_reserved', '#f79009', 'text', 'tables'),
(27, 'allow_merge_table', 'false', 'boolean', 'tables'),
(28, 'strict_stock_control', 'false', 'boolean', 'inventory'),
(29, 'show_logo_receipt', 'true', 'boolean', 'receipt'),
(30, 'show_cashier_receipt', 'true', 'boolean', 'receipt'),
(31, 'printer_width', '80', 'number', 'receipt'),
(32, 'receipt_header', '', 'text', 'receipt'),
(33, 'receipt_footer', 'Thank you for dining at The Grand Gusto. Follow us on Instagram @TheGrandGusto', 'text', 'receipt'),
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
(58, 'kot_print_copies', '2', 'text', 'general'),
(59, 'auto_print_kot', 'true', 'boolean', 'general'),
(60, 'show_notes_on_kot', 'false', 'boolean', 'general'),
(61, 'print_logo_on_kot', 'true', 'boolean', 'general'),
(62, 'printer_type', 'usb', 'text', 'general'),
(63, 'paper_width', '80', 'number', 'general'),
(66, 'stock_deduction_mode', 'On Order', 'text', 'general'),
(67, 'low_stock_warning_limit', '20', 'text', 'general'),
(68, 'block_out_of_stock_orders', 'true', 'boolean', 'general'),
(77, 'cashier_hide_financial_data', 'false', 'boolean', 'general'),
(1231, 'pos_access', 'true', 'boolean', 'general'),
(1232, 'floor_plan_access', 'true', 'boolean', 'general'),
(1233, 'view_reports', 'false', 'boolean', 'general'),
(1234, 'export_data', 'false', 'boolean', 'general'),
(1235, 'settings_access', 'false', 'boolean', 'general'),
(1236, 'void_orders', 'false', 'boolean', 'general'),
(1237, 'hide_financials', 'false', 'boolean', 'general'),
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
(1747, 'business_day_start', '4', 'number', 'localization');

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
(1, 1, '2026-02-12 07:32:30', NULL, 0.00, 0.00, 'open', NULL, '2026-02-12 02:32:30', '2026-02-12 02:32:30');

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
(248, 1, -1.000, 499.000, 'sale', 'order', 1, 'System', NULL, '2026-02-12 02:32:30'),
(249, 2, -1.000, 499.000, 'sale', 'order', 1, 'System', NULL, '2026-02-12 02:32:30'),
(250, 1, -1.000, 498.000, 'sale', 'order', 4, 'System', NULL, '2026-02-12 13:17:37'),
(251, 2, -1.000, 498.000, 'sale', 'order', 4, 'System', NULL, '2026-02-12 13:17:37'),
(252, 1, -1.000, 497.000, 'sale', 'order', 6, 'System', NULL, '2026-02-12 13:18:24'),
(253, 2, -1.000, 497.000, 'sale', 'order', 6, 'System', NULL, '2026-02-12 13:18:24'),
(254, 1, -1.000, 496.000, 'sale', 'order', 5, 'System', NULL, '2026-02-12 13:18:36'),
(255, 2, -1.000, 496.000, 'sale', 'order', 5, 'System', NULL, '2026-02-12 13:18:36'),
(256, 1, -3.000, 493.000, 'sale', 'order', 7, 'System', NULL, '2026-02-12 13:19:02'),
(257, 2, -3.000, 493.000, 'sale', 'order', 7, 'System', NULL, '2026-02-12 13:19:02'),
(258, 1, -1.000, 492.000, 'sale', 'order', 8, 'System', NULL, '2026-02-12 13:36:41'),
(259, 2, -1.000, 492.000, 'sale', 'order', 8, 'System', NULL, '2026-02-12 13:36:41'),
(260, 1, -1.000, 491.000, 'sale', 'order', 9, 'System', NULL, '2026-02-12 13:38:04'),
(261, 2, -1.000, 491.000, 'sale', 'order', 9, 'System', NULL, '2026-02-12 13:38:04'),
(262, 1, -1.000, 490.000, 'sale', 'order', 2, 'System', NULL, '2026-02-12 13:39:34'),
(263, 2, -1.000, 490.000, 'sale', 'order', 2, 'System', NULL, '2026-02-12 13:39:34'),
(264, 1, -1.000, 489.000, 'sale', 'order', 11, 'System', NULL, '2026-02-12 13:59:11'),
(265, 2, -1.000, 489.000, 'sale', 'order', 11, 'System', NULL, '2026-02-12 13:59:11'),
(266, 1, -1.000, 488.000, 'sale', 'order', 12, 'System', NULL, '2026-02-12 14:04:43'),
(267, 2, -1.000, 488.000, 'sale', 'order', 12, 'System', NULL, '2026-02-12 14:04:43'),
(268, 1, -1.000, 487.000, 'sale', 'order', 13, 'System', NULL, '2026-02-12 14:05:46'),
(269, 2, -1.000, 487.000, 'sale', 'order', 13, 'System', NULL, '2026-02-12 14:05:46'),
(270, 1, -1.000, 486.000, 'sale', 'order', 14, 'System', NULL, '2026-02-12 14:34:32'),
(271, 2, -1.000, 486.000, 'sale', 'order', 14, 'System', NULL, '2026-02-12 14:34:32'),
(272, 1, -1.000, 485.000, 'sale', 'order', 15, 'System', NULL, '2026-02-12 14:35:55'),
(273, 2, -1.000, 485.000, 'sale', 'order', 15, 'System', NULL, '2026-02-12 14:35:55'),
(274, 1, -3.000, 482.000, 'sale', 'order', 16, 'System', NULL, '2026-02-12 14:36:26'),
(275, 2, -3.000, 482.000, 'sale', 'order', 16, 'System', NULL, '2026-02-12 14:36:26'),
(276, 5, -4.000, 496.000, 'sale', 'order', 16, 'System', NULL, '2026-02-12 14:36:26'),
(277, 1, -474.000, 8.000, 'sale', 'order', 17, 'System', NULL, '2026-02-12 14:48:54'),
(278, 1, -4.000, 4.000, 'sale', 'order', 18, 'System', NULL, '2026-02-12 14:50:39'),
(279, 1, 2.000, 6.000, 'return', NULL, NULL, 'System', 'Return Order INV-1018', '2026-02-12 14:51:07'),
(280, 1, 10.000, 16.000, 'restock', NULL, NULL, 'System', 'Stock In', '2026-02-12 14:51:34'),
(281, 1, -1.000, 15.000, 'sale', 'order', 19, 'System', NULL, '2026-02-12 14:54:11'),
(282, 2, -1.000, 481.000, 'sale', 'order', 19, 'System', NULL, '2026-02-12 14:54:11'),
(283, 1, -1.000, 14.000, 'sale', 'order', 20, 'System', NULL, '2026-02-12 14:55:04'),
(284, 2, -1.000, 480.000, 'sale', 'order', 20, 'System', NULL, '2026-02-12 14:55:04'),
(285, 1, -14.000, 0.000, 'sale', 'order', 21, 'System', NULL, '2026-02-12 14:56:48'),
(286, 1, 10.000, 10.000, 'return', NULL, NULL, 'System', 'Return Order INV-1021', '2026-02-12 14:57:43'),
(287, 1, -1.000, 9.000, 'sale', 'order', 23, 'System', NULL, '2026-02-12 15:01:07'),
(288, 2, -1.000, 479.000, 'sale', 'order', 23, 'System', NULL, '2026-02-12 15:01:07'),
(289, 1, -2.000, 7.000, 'sale', 'order', 24, 'System', NULL, '2026-02-12 15:01:27'),
(290, 1, -3.000, 4.000, 'sale', 'order', 26, 'System', NULL, '2026-02-12 15:01:47'),
(291, 2, -3.000, 476.000, 'sale', 'order', 26, 'System', NULL, '2026-02-12 15:01:47'),
(292, 1, -1.000, 3.000, 'sale', 'order', 27, 'System', NULL, '2026-02-12 15:09:02'),
(293, 2, -1.000, 475.000, 'sale', 'order', 27, 'System', NULL, '2026-02-12 15:09:02'),
(294, 1, -1.000, 2.000, 'sale', 'order', 27, 'System', NULL, '2026-02-12 15:09:02'),
(295, 1, -2.000, 0.000, 'sale', 'order', 29, 'System', NULL, '2026-02-12 16:07:40'),
(296, 2, -2.000, 473.000, 'sale', 'order', 29, 'System', NULL, '2026-02-12 16:07:40'),
(297, 1, 10.000, 10.000, 'restock', NULL, NULL, 'System', 'Stock In', '2026-02-12 19:58:30'),
(298, 1, -6.000, 4.000, 'sale', 'order', 30, 'System', NULL, '2026-02-12 19:58:41'),
(299, 1, 6.000, 10.000, 'return', NULL, NULL, 'System', 'Return Order INV-1030', '2026-02-12 19:59:09'),
(300, 1, -5.000, 5.000, 'sale', 'order', 31, 'System', NULL, '2026-02-12 20:07:03'),
(301, 1, 5.000, 10.000, 'return', NULL, NULL, 'System', 'Return Order INV-1031', '2026-02-12 20:07:32'),
(302, 1, -1.000, 9.000, 'sale', 'order', 25, 'System', NULL, '2026-02-12 20:39:37'),
(303, 2, -1.000, 472.000, 'sale', 'order', 25, 'System', NULL, '2026-02-12 20:39:37'),
(304, 5, -2.000, 494.000, 'sale', 'order', 28, 'System', NULL, '2026-02-12 20:40:00'),
(305, 1, -1.000, 8.000, 'sale', 'order', 28, 'System', NULL, '2026-02-12 20:40:00'),
(306, 2, -1.000, 471.000, 'sale', 'order', 28, 'System', NULL, '2026-02-12 20:40:00'),
(307, 1, -1.000, 7.000, 'sale', 'order', 28, 'System', NULL, '2026-02-12 20:40:00'),
(308, 1, -3.000, 4.000, 'sale', 'order', 32, 'System', NULL, '2026-02-12 20:40:39'),
(309, 2, -3.000, 468.000, 'sale', 'order', 32, 'System', NULL, '2026-02-12 20:40:39'),
(310, 5, -2.000, 492.000, 'sale', 'order', 33, 'System', NULL, '2026-02-12 20:54:20'),
(311, 5, -6.000, 486.000, 'sale', 'order', 34, 'System', NULL, '2026-02-12 20:55:22'),
(312, 5, -2.000, 484.000, 'sale', 'order', 36, 'System', NULL, '2026-02-12 21:05:19'),
(313, 5, -2.000, 482.000, 'sale', 'order', 35, 'System', NULL, '2026-02-12 21:05:42'),
(314, 5, -2.000, 480.000, 'sale', 'order', 38, 'System', NULL, '2026-02-12 21:15:22'),
(315, 5, -2.000, 478.000, 'sale', 'order', 39, 'System', NULL, '2026-02-12 21:15:59'),
(316, 5, -2.000, 476.000, 'sale', 'order', 40, 'System', NULL, '2026-02-12 21:18:55'),
(317, 5, -6.000, 470.000, 'sale', 'order', 37, 'System', NULL, '2026-02-12 21:24:00'),
(318, 1, -1.000, 3.000, 'sale', 'order', 42, 'System', NULL, '2026-02-12 22:49:28'),
(319, 5, -2.000, 468.000, 'sale', 'order', 53, 'System', NULL, '2026-02-13 15:26:53'),
(320, 5, -2.000, 466.000, 'sale', 'order', 54, 'System', NULL, '2026-02-13 15:27:45'),
(321, 5, -2.000, 464.000, 'sale', 'order', 55, 'System', NULL, '2026-02-13 15:35:26'),
(322, 5, -2.000, 462.000, 'sale', 'order', 49, 'System', NULL, '2026-02-13 15:36:14'),
(323, 5, -4.000, 458.000, 'sale', 'order', 56, 'System', NULL, '2026-02-13 15:36:36'),
(324, 5, -2.000, 456.000, 'sale', 'order', 57, 'System', NULL, '2026-02-13 15:36:52'),
(325, 5, -2.000, 454.000, 'sale', 'order', 58, 'System', NULL, '2026-02-13 15:37:03'),
(326, 5, -2.000, 452.000, 'sale', 'order', 60, 'System', NULL, '2026-02-13 15:37:27'),
(327, 5, -4.000, 448.000, 'sale', 'order', 62, 'System', NULL, '2026-02-13 20:09:57'),
(328, 5, -2.000, 446.000, 'sale', 'order', 68, 'System', NULL, '2026-02-13 20:29:57'),
(329, 5, -2.000, 444.000, 'sale', 'order', 69, 'System', NULL, '2026-02-13 20:39:11'),
(330, 5, -2.000, 442.000, 'sale', 'order', 72, 'System', NULL, '2026-02-13 21:11:46'),
(331, 5, -2.000, 440.000, 'sale', 'order', 76, 'System', NULL, '2026-02-13 21:14:25'),
(332, 5, -2.000, 438.000, 'sale', 'order', 77, 'System', NULL, '2026-02-13 21:16:40'),
(333, 5, -2.000, 436.000, 'sale', 'order', 74, 'System', NULL, '2026-02-13 21:18:13'),
(334, 5, -2.000, 434.000, 'sale', 'order', 79, 'System', NULL, '2026-02-13 21:23:15'),
(335, 5, -2.000, 432.000, 'sale', 'order', 80, 'System', NULL, '2026-02-13 21:24:04'),
(336, 5, -2.000, 430.000, 'sale', 'order', 81, 'System', NULL, '2026-02-13 21:28:01'),
(337, 5, -2.000, 428.000, 'sale', 'order', 82, 'System', NULL, '2026-02-13 21:39:46'),
(338, 5, -4.000, 424.000, 'sale', 'order', 84, 'System', NULL, '2026-02-13 21:48:15'),
(339, 5, -2.000, 422.000, 'sale', 'order', 86, 'System', NULL, '2026-02-13 21:51:05'),
(340, 5, -2.000, 420.000, 'sale', 'order', 87, 'System', NULL, '2026-02-13 21:53:56'),
(341, 5, -2.000, 418.000, 'sale', 'order', 88, 'System', NULL, '2026-02-13 22:01:55'),
(342, 5, -2.000, 416.000, 'sale', 'order', 89, 'System', NULL, '2026-02-13 22:04:32'),
(343, 5, -2.000, 414.000, 'sale', 'order', 90, 'System', NULL, '2026-02-13 22:11:51'),
(344, 5, -2.000, 412.000, 'sale', 'order', 91, 'System', NULL, '2026-02-13 22:18:47');

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
(2, 'Frances Rodgers', '00987654', 'vumubyquh@mailinator.com', 'Hyd', 1, '2026-02-08 16:08:03'),
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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `expenses`
--
ALTER TABLE `expenses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `inventory`
--
ALTER TABLE `inventory`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=93;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=340;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `recipes`
--
ALTER TABLE `recipes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4382;

--
-- AUTO_INCREMENT for table `shifts`
--
ALTER TABLE `shifts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=345;

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
