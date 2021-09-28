-- MySQL dump 10.13  Distrib 5.7.27, for Linux (x86_64)
--
-- Host: localhost    Database: tov
-- ------------------------------------------------------
-- Server version	5.7.27-0ubuntu0.18.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `asset`
--

DROP TABLE IF EXISTS `asset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asset` (
  `asset_id` varchar(50) NOT NULL COMMENT '파일 아이디',
  `seq` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '순번',
  `originalname` varchar(100) DEFAULT NULL COMMENT '원본 파일명',
  `encoding` varchar(50) DEFAULT NULL COMMENT '파일 엔코딩',
  `mimetype` varchar(50) DEFAULT NULL COMMENT '파일 mimetype',
  `url` varchar(100) DEFAULT NULL COMMENT '파일 접근 URL',
  `destination` varchar(100) DEFAULT NULL COMMENT '파일 저장 디렉토리',
  `filename` varchar(100) DEFAULT NULL COMMENT '저장 파일명',
  `path` varchar(100) DEFAULT NULL COMMENT '파일 저장 전체 경로',
  `size` int(11) DEFAULT NULL COMMENT '파일사이즈',
  `reg_dttm` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
  `mod_dttm` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '변경일',
  PRIMARY KEY (`asset_id`),
  UNIQUE KEY `uidx_asset_seq` (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=1571 DEFAULT CHARSET=utf8 COMMENT='파일 자산 정보';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asset`
--

LOCK TABLES `asset` WRITE;
/*!40000 ALTER TABLE `asset` DISABLE KEYS */;
/*!40000 ALTER TABLE `asset` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `seq` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '순번',
  `user_id` varchar(50) NOT NULL COMMENT '사용자 아이디',
  `email` varchar(100) NOT NULL COMMENT '사용자 이메일',
  `user_pw` varchar(100) NOT NULL COMMENT '사용자 비밀번호',
  `user_name` varchar(100) DEFAULT NULL COMMENT '사용자 이름',
  `balance` decimal(32,16) DEFAULT NULL COMMENT '잔액',
  `reg_dt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
  `mod_dt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uidx_user_seq` (`seq`),
  UNIQUE KEY `uidx_user_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8 COMMENT='사용자 정보';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (31,'u1212','asdaisy@test.com','ddkfdkerekrerkrekelre','데모님',10.3282938293993000,'2019-09-09 07:42:42','2019-11-09 01:17:00'),(32,'u8282','user@test.com','3dkdk33k3k4344k3k43','사용자',2203333332233222.1233330000000000,'2019-11-09 00:55:39','2019-11-09 01:16:50');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-11-09 10:17:31
