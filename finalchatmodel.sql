-- phpMyAdmin SQL Dump
-- version 4.6.6deb5
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Sep 19, 2020 at 02:16 PM
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
  `channel_admin` bigint(20) NOT NULL COMMENT 'Id of the user who created channel',
  `channel_status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '= 1 active ,  = 2 inactive',
  `creation_datetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'time when channel was created'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `channels`
--

INSERT INTO `channels` (`channel_id`, `channel_type`, `channel_name`, `channel_picture`, `channel_admin`, `channel_status`, `creation_datetime`) VALUES
(4, 0, NULL, NULL, 1, 1, '2020-09-19 04:33:31'),
(5, 1, 'himachal lads', 'group pofile photo link', 3, 1, '2020-09-19 06:11:36');

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
(8, 4),
(13, 5);

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
(1, 1, 4, 'hey user2 how have you been?', '2020-09-19 04:35:48', 0),
(2, 2, 4, 'hey user1', '2020-09-19 05:29:20', 0),
(3, 2, 4, 'i am great how are you', '2020-09-19 05:29:20', 0),
(4, 1, 4, 'i am great as well,thankyou for asking ', '2020-09-19 05:44:00', 0),
(5, 1, 4, 'hows fam?', '2020-09-19 05:44:00', 0),
(6, 1, 4, 'and your daughter ?', '2020-09-19 05:44:30', 0),
(7, 1, 4, 'man i am coming to meet ya', '2020-09-19 05:44:30', 0),
(8, 1, 4, 'lets have a drink together', '2020-09-19 05:44:48', 0),
(9, 3, 5, 'guys up for dinner?', '2020-09-19 06:12:44', 0),
(10, 1, 5, 'i am not feeling good', '2020-09-19 06:21:22', 0),
(11, 1, 5, 'i will take a rain check this time', '2020-09-19 06:21:22', 0),
(12, 2, 5, 'me too, let plan it for another day', '2020-09-19 06:44:37', 0),
(13, 2, 5, 'sunday probably', '2020-09-19 06:44:37', 0);

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
(1, '432dszxc42242444255', 'user1', 'user1@yopmail.com', '70f77978466b9a3073d41c5e3fbbcfb1', 'user1 profile picture link', '9501910623', 1),
(2, '432dszxc4224244433', 'user2', 'user2@yopmail.com', '70f77978466b9a3073d41c5e3fbbcfb1', 'user2 profile picture link', '9501910622', 1),
(3, '432dszxc422424442', 'user3', 'user3@yopmail.com', '70f77978466b9a3073d41c5e3fbbcfb1', 'user3 profile picture link', '94394944344', 1);

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
(1, 1, 4, 1, 8, 0, '2020-09-19 04:34:49'),
(2, 2, 4, 1, 8, 0, '2020-09-19 04:34:49'),
(3, 3, 5, 1, 13, 0, '2020-09-19 06:11:58'),
(4, 1, 5, 1, 11, 0, '2020-09-19 06:11:58'),
(5, 2, 5, 1, 13, 0, '2020-09-19 06:12:06');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `channels`
--
ALTER TABLE `channels`
  ADD PRIMARY KEY (`channel_id`),
  ADD KEY `channel_admin_FK` (`channel_admin`);

--
-- Indexes for table `channel_last_message`
--
ALTER TABLE `channel_last_message`
  ADD UNIQUE KEY `uniqueChanel` (`channel_id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `idx_user_id_messages` (`user_id`),
  ADD KEY `idx_channel_id_messages` (`channel_id`);

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
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_channel_id` (`channel_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `channels`
--
ALTER TABLE `channels`
  MODIFY `channel_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `message_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;
--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `user_channels`
--
ALTER TABLE `user_channels`
  MODIFY `user_channel_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `channels`
--
ALTER TABLE `channels`
  ADD CONSTRAINT `channel_admin_FK` FOREIGN KEY (`channel_admin`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `user_channels`
--
ALTER TABLE `user_channels`
  ADD CONSTRAINT `channel_mapping` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`channel_id`),
  ADD CONSTRAINT `user_mapping` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
