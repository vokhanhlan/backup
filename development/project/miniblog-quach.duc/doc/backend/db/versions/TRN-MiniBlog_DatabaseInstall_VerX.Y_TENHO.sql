/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

-- Create database
CREATE DATABASE IF NOT EXISTS mini_blog CHARACTER SET utf8 COLLATE utf8_general_ci;

-- Use database
USE mini_blog;

--
-- Character encoding setting
--
SET NAMES utf8;

--
-- 'user' table structure
--
CREATE TABLE IF NOT EXISTS `user` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(40) NOT NULL,
...
  `create_dt` INT(11) NOT NULL,
  `update_dt` INT(11) NOT NULL,
  `status` TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

