-- phpMyAdmin SQL Dump
-- version 4.6.6deb5
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Sep 18, 2020 at 04:59 PM
-- Server version: 5.7.31-0ubuntu0.18.04.1
-- PHP Version: 7.2.24-0ubuntu0.18.04.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `chatmodel`
--

-- --------------------------------------------------------

--
-- Table structure for table `channels`
--

CREATE TABLE `channels` (
  `channel_id` bigint(20) NOT NULL,
  `channel_type` tinyint(4) NOT NULL DEFAULT '0' COMMENT '0 - one to one conversation, 1 - group conversation',
  `channel_name` varchar(255) DEFAULT NULL COMMENT 'only for type -1 ,groups can have names',
  `channel_picture` mediumtext COMMENT 'link of picture for type -1 , groups can have pictures',
  `channel_admin` varchar(255) DEFAULT NULL COMMENT 'email of the admin of group(only for type -1)',
  `channel_status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '= 1 active ,  = 2 inactive',
  `creation_datetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'time when channel was created'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `channels`
--

INSERT INTO `channels` (`channel_id`, `channel_type`, `channel_name`, `channel_picture`, `channel_admin`, `channel_status`, `creation_datetime`) VALUES
(1, 0, NULL, NULL, NULL, 1, '2020-09-17 05:42:48'),
(2, 0, NULL, NULL, NULL, 1, '2020-09-17 13:33:13');

-- --------------------------------------------------------

--
-- Table structure for table `channel_last_message`
--

CREATE TABLE `channel_last_message` (
  `message_id` bigint(20) NOT NULL,
  `channel_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='to store last message in each channel (to make joining easy)';

--
-- Dumping data for table `channel_last_message`
--

INSERT INTO `channel_last_message` (`message_id`, `channel_id`) VALUES
(9, 1),
(7, 2);

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `message_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `channel_id` bigint(20) NOT NULL,
  `message_text` text NOT NULL,
  `creation_datetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `is_deleted` tinyint(4) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`message_id`, `user_id`, `channel_id`, `message_text`, `creation_datetime`, `is_deleted`) VALUES
(1, 1, 1, 'hi SAHIL', '2020-09-17 07:25:03', 0),
(2, 2, 1, 'YO WASUP!', '2020-09-17 07:34:59', 0),
(3, 3, 2, 'hi sandy  nitish here', '2020-09-17 13:35:05', 0),
(4, 1, 2, 'hey nitish', '2020-09-17 15:24:27', 0),
(5, 3, 2, 'just checking if you fine', '2020-09-18 07:36:25', 0),
(6, 3, 2, 'hey you arent replying', '2020-09-18 10:43:20', 0),
(7, 3, 2, 'sandy reply bro', '2020-09-18 11:28:30', 0),
(8, 1, 1, 'nothing much bro!', '2020-09-18 11:28:59', 0),
(9, 2, 1, 'ight mate!', '2020-09-18 11:29:40', 0);

--
-- Triggers `messages`
--
DELIMITER $$
CREATE TRIGGER `check123` AFTER INSERT ON `messages` FOR EACH ROW BEGIN

 

   

      INSERT INTO channel_last_message
   ( message_id,
     channel_id)
   VALUES
   ( NEW.message_id,
     NEW.channel_id)
 ON DUPLICATE KEY 
UPDATE message_id = NEW.message_id ;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` bigint(20) NOT NULL,
  `access_token` mediumtext NOT NULL COMMENT 'access token to verify when user logs in',
  `username` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `profile_photo` mediumtext NOT NULL,
  `phone_no` varchar(255) NOT NULL,
  `is_active` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'whether user is active or not'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='users of chat app';

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `access_token`, `username`, `email`, `password`, `profile_photo`, `phone_no`, `is_active`) VALUES
(1, '', 'vikrant', 'vikrantsandal0@gmail.com', '70f77978466b9a3073d41c5e3fbbcfb1', 'ugly face', '9501910623', 1),
(2, '', 'sahil', 'sahil@gmail.com', '70f77978466b9a3073d41c5e3fbbcfb1', 'ugly shit', '9501910622', 1),
(3, '432dszxc422424442', 'nitish', 'nitish@gmail.com', '70f77978466b9a3073d41c5e3fbbcfb1', 'ugly face', '9816664466', 1);

-- --------------------------------------------------------

--
-- Table structure for table `user_channels`
--

CREATE TABLE `user_channels` (
  `user_channel_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `channel_id` bigint(20) NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '=1  active , =0 inactive state',
  `last_read_msg_id` bigint(20) NOT NULL DEFAULT '0',
  `is_pinned` tinyint(4) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='user- channels mappings ';

--
-- Dumping data for table `user_channels`
--

INSERT INTO `user_channels` (`user_channel_id`, `user_id`, `channel_id`, `status`, `last_read_msg_id`, `is_pinned`, `created_at`) VALUES
(1, 1, 1, 1, 2, 0, '2020-09-18 05:15:18'),
(2, 2, 1, 1, 0, 0, '2020-09-18 05:15:18'),
(3, 1, 2, 1, 5, 0, '2020-09-18 05:15:18'),
(4, 3, 2, 1, 0, 0, '2020-09-18 05:15:18');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `channels`
--
ALTER TABLE `channels`
  ADD PRIMARY KEY (`channel_id`);

--
-- Indexes for table `channel_last_message`
--
ALTER TABLE `channel_last_message`
  ADD UNIQUE KEY `uniqueChanel` (`channel_id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`message_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `user_channels`
--
ALTER TABLE `user_channels`
  ADD PRIMARY KEY (`user_channel_id`),
  ADD KEY `channel_mapping` (`channel_id`),
  ADD KEY `user_mapping` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `channels`
--
ALTER TABLE `channels`
  MODIFY `channel_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `message_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;
--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `user_channels`
--
ALTER TABLE `user_channels`
  MODIFY `user_channel_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `user_channels`
--
ALTER TABLE `user_channels`
  ADD CONSTRAINT `channel_mapping` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`channel_id`),
  ADD CONSTRAINT `user_mapping` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
