# ************************************************************
# Sequel Pro SQL dump
# Version 4541
#
# http://www.sequelpro.com/
# https://github.com/sequelpro/sequelpro
#
# Host: 127.0.0.1 (MySQL 5.7.19)
# Database: router_manager
# Generation Time: 2017-08-25 00:28:16 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table tbl_router
# ------------------------------------------------------------

DROP TABLE IF EXISTS `tbl_router`;

CREATE TABLE `tbl_router` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(200) DEFAULT '',
  `username` varchar(200) NOT NULL DEFAULT '',
  `password` varchar(200) NOT NULL DEFAULT '',
  `ip_address` varchar(200) NOT NULL DEFAULT '',
  `description` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `tbl_router` WRITE;
/*!40000 ALTER TABLE `tbl_router` DISABLE KEYS */;

INSERT INTO `tbl_router` (`id`, `name`, `username`, `password`, `ip_address`, `description`)
VALUES
	(1,'a','admin','123456','10.0.0.1',NULL),
	(4,'d','admin','123456','10.10.10.2','test'),
	(5,'c','asd','aasd','asd',NULL);

/*!40000 ALTER TABLE `tbl_router` ENABLE KEYS */;
UNLOCK TABLES;



/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
