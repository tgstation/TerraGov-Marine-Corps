-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.2.10-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win32
-- HeidiSQL Version:             10.1.0.5464
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for table feedback.admin
CREATE TABLE IF NOT EXISTS `admin` (
  `ckey` varchar(32) NOT NULL,
  `rank` varchar(32) NOT NULL,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPRESSED;

-- Data exporting was unselected.
-- Dumping structure for table feedback.admin_log
CREATE TABLE IF NOT EXISTS `admin_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `round_id` int(10) unsigned NOT NULL,
  `adminckey` varchar(32) NOT NULL,
  `adminip` int(10) unsigned NOT NULL,
  `operation` enum('add admin','remove admin','change admin rank','add rank','remove rank','change rank flags') NOT NULL,
  `target` varchar(32) NOT NULL,
  `log` varchar(1000) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 ROW_FORMAT=COMPRESSED;

-- Data exporting was unselected.
-- Dumping structure for table feedback.admin_ranks
CREATE TABLE IF NOT EXISTS `admin_ranks` (
  `rank` varchar(32) NOT NULL,
  `flags` smallint(5) unsigned NOT NULL,
  `exclude_flags` smallint(5) unsigned NOT NULL,
  `can_edit_flags` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`rank`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPRESSED;

-- Data exporting was unselected.
-- Dumping structure for table feedback.ban
CREATE TABLE IF NOT EXISTS `ban` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `bantime` datetime NOT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(11) unsigned NOT NULL,
  `role` varchar(32) DEFAULT NULL,
  `expiration_time` datetime DEFAULT NULL,
  `applies_to_admins` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `reason` varchar(2048) NOT NULL,
  `ckey` varchar(32) DEFAULT NULL,
  `ip` int(10) unsigned DEFAULT NULL,
  `computerid` varchar(32) DEFAULT NULL,
  `a_ckey` varchar(32) NOT NULL,
  `a_ip` int(10) unsigned NOT NULL,
  `a_computerid` varchar(32) NOT NULL,
  `who` varchar(2048) NOT NULL,
  `adminwho` varchar(2048) NOT NULL,
  `edits` text DEFAULT NULL,
  `unbanned_datetime` datetime DEFAULT NULL,
  `unbanned_ckey` varchar(32) DEFAULT NULL,
  `unbanned_ip` int(10) unsigned DEFAULT NULL,
  `unbanned_computerid` varchar(32) DEFAULT NULL,
  `unbanned_round_id` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ban_isbanned` (`ckey`,`role`,`unbanned_datetime`,`expiration_time`),
  KEY `idx_ban_isbanned_details` (`ckey`,`ip`,`computerid`,`role`,`unbanned_datetime`,`expiration_time`),
  KEY `idx_ban_count` (`bantime`,`a_ckey`,`applies_to_admins`,`unbanned_datetime`,`expiration_time`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

-- Data exporting was unselected.
-- Dumping structure for table feedback.connection_log
CREATE TABLE IF NOT EXISTS `connection_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime DEFAULT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(11) unsigned NOT NULL,
  `ckey` varchar(45) DEFAULT NULL,
  `ip` int(10) unsigned NOT NULL,
  `computerid` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1 ROW_FORMAT=COMPRESSED;

-- Data exporting was unselected.
-- Dumping structure for table feedback.death
CREATE TABLE IF NOT EXISTS `death` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pod` varchar(50) NOT NULL,
  `x_coord` smallint(5) unsigned NOT NULL,
  `y_coord` smallint(5) unsigned NOT NULL,
  `z_coord` smallint(5) unsigned NOT NULL,
  `mapname` varchar(32) NOT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(11) NOT NULL,
  `tod` datetime NOT NULL COMMENT 'Time of death',
  `job` varchar(32) NOT NULL,
  `special` varchar(32) DEFAULT NULL,
  `name` varchar(96) NOT NULL,
  `byondkey` varchar(32) NOT NULL,
  `laname` varchar(96) DEFAULT NULL,
  `lakey` varchar(32) DEFAULT NULL,
  `bruteloss` smallint(5) unsigned NOT NULL,
  `brainloss` smallint(5) unsigned NOT NULL,
  `fireloss` smallint(5) unsigned NOT NULL,
  `oxyloss` smallint(5) unsigned NOT NULL,
  `toxloss` smallint(5) unsigned NOT NULL,
  `cloneloss` smallint(5) unsigned NOT NULL,
  `staminaloss` smallint(5) unsigned NOT NULL,
  `last_words` varchar(255) DEFAULT NULL,
  `suicide` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPRESSED;

-- Data exporting was unselected.
-- Dumping structure for table feedback.feedback
CREATE TABLE IF NOT EXISTS `feedback` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `round_id` int(11) unsigned NOT NULL,
  `key_name` varchar(32) NOT NULL,
  `version` tinyint(3) unsigned NOT NULL,
  `key_type` enum('text','amount','tally','nested tally','associative') NOT NULL,
  `json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Data exporting was unselected.
-- Dumping structure for table feedback.ipintel
CREATE TABLE IF NOT EXISTS `ipintel` (
  `ip` int(10) unsigned NOT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `intel` double NOT NULL DEFAULT 0,
  PRIMARY KEY (`ip`),
  KEY `idx_ipintel` (`ip`,`intel`,`date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPRESSED;

-- Data exporting was unselected.
-- Dumping structure for table feedback.messages
CREATE TABLE IF NOT EXISTS `messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` enum('memo','message','message sent','note','watchlist entry') NOT NULL,
  `targetckey` varchar(32) NOT NULL,
  `adminckey` varchar(32) NOT NULL,
  `text` varchar(2048) NOT NULL,
  `timestamp` datetime NOT NULL,
  `server` varchar(32) DEFAULT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(11) unsigned NOT NULL,
  `secret` tinyint(1) unsigned NOT NULL,
  `expire_timestamp` datetime DEFAULT NULL,
  `severity` enum('high','medium','minor','none') DEFAULT NULL,
  `lasteditor` varchar(32) DEFAULT NULL,
  `edits` text DEFAULT NULL,
  `deleted` tinyint(1) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_msg_ckey_time` (`targetckey`,`timestamp`,`deleted`),
  KEY `idx_msg_type_ckeys_time` (`type`,`targetckey`,`adminckey`,`timestamp`,`deleted`),
  KEY `idx_msg_type_ckey_time_odr` (`type`,`targetckey`,`timestamp`,`deleted`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1 ROW_FORMAT=COMPRESSED;

-- Data exporting was unselected.
-- Dumping structure for table feedback.player
CREATE TABLE IF NOT EXISTS `player` (
  `ckey` varchar(32) NOT NULL,
  `byond_key` varchar(32) DEFAULT NULL,
  `firstseen` datetime NOT NULL,
  `firstseen_round_id` int(11) unsigned NOT NULL,
  `lastseen` datetime NOT NULL,
  `lastseen_round_id` int(11) unsigned NOT NULL,
  `ip` int(10) unsigned NOT NULL,
  `computerid` varchar(32) NOT NULL,
  `lastadminrank` varchar(32) NOT NULL DEFAULT 'Player',
  `accountjoindate` date DEFAULT NULL,
  `flags` smallint(5) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`ckey`),
  KEY `idx_player_cid_ckey` (`computerid`,`ckey`),
  KEY `idx_player_ip_ckey` (`ip`,`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPRESSED;

-- Data exporting was unselected.
-- Dumping structure for table feedback.poll_option
CREATE TABLE IF NOT EXISTS `poll_option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pollid` int(11) NOT NULL,
  `text` varchar(255) NOT NULL,
  `minval` int(3) DEFAULT NULL,
  `maxval` int(3) DEFAULT NULL,
  `descmin` varchar(32) DEFAULT NULL,
  `descmid` varchar(32) DEFAULT NULL,
  `descmax` varchar(32) DEFAULT NULL,
  `default_percentage_calc` tinyint(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `idx_pop_pollid` (`pollid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPRESSED;

-- Data exporting was unselected.
-- Dumping structure for table feedback.poll_question
CREATE TABLE IF NOT EXISTS `poll_question` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `polltype` enum('OPTION','TEXT','NUMVAL','MULTICHOICE','IRV') NOT NULL,
  `starttime` datetime NOT NULL,
  `endtime` datetime NOT NULL,
  `question` varchar(255) NOT NULL,
  `adminonly` tinyint(1) unsigned NOT NULL,
  `multiplechoiceoptions` int(2) DEFAULT NULL,
  `createdby_ckey` varchar(32) DEFAULT NULL,
  `createdby_ip` int(10) unsigned NOT NULL,
  `dontshow` tinyint(1) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_pquest_question_time_ckey` (`question`,`starttime`,`endtime`,`createdby_ckey`,`createdby_ip`),
  KEY `idx_pquest_time_admin` (`starttime`,`endtime`,`adminonly`),
  KEY `idx_pquest_id_time_type_admin` (`id`,`starttime`,`endtime`,`polltype`,`adminonly`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPRESSED;

-- Data exporting was unselected.
-- Dumping structure for table feedback.poll_textreply
CREATE TABLE IF NOT EXISTS `poll_textreply` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `pollid` int(11) NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `ip` int(10) unsigned NOT NULL,
  `replytext` varchar(2048) NOT NULL,
  `adminrank` varchar(32) NOT NULL DEFAULT 'Player',
  PRIMARY KEY (`id`),
  KEY `idx_ptext_pollid_ckey` (`pollid`,`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPRESSED;

-- Data exporting was unselected.
-- Dumping structure for table feedback.poll_vote
CREATE TABLE IF NOT EXISTS `poll_vote` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `pollid` int(11) NOT NULL,
  `optionid` int(11) NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `ip` int(10) unsigned NOT NULL,
  `adminrank` varchar(32) NOT NULL,
  `rating` int(2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_pvote_pollid_ckey` (`pollid`,`ckey`),
  KEY `idx_pvote_optionid_ckey` (`optionid`,`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPRESSED;

-- Data exporting was unselected.
-- Dumping structure for table feedback.role_time
CREATE TABLE IF NOT EXISTS `role_time` (
  `ckey` varchar(32) NOT NULL,
  `job` varchar(32) NOT NULL,
  `minutes` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ckey`,`job`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.
-- Dumping structure for table feedback.role_time_log
CREATE TABLE IF NOT EXISTS `role_time_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `job` varchar(128) NOT NULL,
  `delta` int(11) NOT NULL,
  `datetime` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `ckey` (`ckey`),
  KEY `job` (`job`),
  KEY `datetime` (`datetime`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.
-- Dumping structure for table feedback.round
CREATE TABLE IF NOT EXISTS `round` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `initialize_datetime` datetime NOT NULL,
  `start_datetime` datetime DEFAULT NULL,
  `shutdown_datetime` datetime DEFAULT NULL,
  `end_datetime` datetime DEFAULT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `commit_hash` char(40) DEFAULT NULL,
  `game_mode` varchar(32) DEFAULT NULL,
  `game_mode_result` varchar(64) DEFAULT NULL,
  `end_state` varchar(64) DEFAULT NULL,
  `map_name` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=latin1 ROW_FORMAT=COMPRESSED;

-- Data exporting was unselected.
-- Dumping structure for table feedback.schema_revision
CREATE TABLE IF NOT EXISTS `schema_revision` (
  `major` tinyint(3) unsigned NOT NULL,
  `minor` tinyint(3) unsigned NOT NULL,
  `date` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`major`,`minor`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPRESSED;

-- Data exporting was unselected.
-- Dumping structure for table feedback.stickyban
CREATE TABLE IF NOT EXISTS `stickyban` (
  `ckey` varchar(32) NOT NULL,
  `reason` varchar(2048) NOT NULL,
  `banning_admin` varchar(32) NOT NULL,
  `datetime` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.
-- Dumping structure for table feedback.stickyban_matched_ckey
CREATE TABLE IF NOT EXISTS `stickyban_matched_ckey` (
  `stickyban` varchar(32) NOT NULL,
  `matched_ckey` varchar(32) NOT NULL,
  `first_matched` timestamp NOT NULL DEFAULT current_timestamp(),
  `exempt` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`stickyban`,`matched_ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.
-- Dumping structure for trigger feedback.role_timeTlogdelete
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `role_timeTlogdelete` AFTER DELETE ON `role_time` FOR EACH ROW BEGIN INSERT into ss13_role_time_log (ckey, job, delta) VALUES (OLD.ckey, OLD.job, 0-OLD.minutes);
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger feedback.role_timeTloginsert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `role_timeTloginsert` AFTER INSERT ON `role_time` FOR EACH ROW BEGIN INSERT into ss13_role_time_log (ckey, job, delta) VALUES (NEW.ckey, NEW.job, NEW.minutes);
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger feedback.role_timeTlogupdate
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `role_timeTlogupdate` AFTER UPDATE ON `role_time` FOR EACH ROW BEGIN INSERT into ss13_role_time_log (ckey, job, delta) VALUES (NEW.CKEY, NEW.job, NEW.minutes-OLD.minutes);
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for table information_schema.ALL_PLUGINS
CREATE TEMPORARY TABLE IF NOT EXISTS `ALL_PLUGINS` (
  `PLUGIN_NAME` varchar(64) NOT NULL DEFAULT '',
  `PLUGIN_VERSION` varchar(20) NOT NULL DEFAULT '',
  `PLUGIN_STATUS` varchar(16) NOT NULL DEFAULT '',
  `PLUGIN_TYPE` varchar(80) NOT NULL DEFAULT '',
  `PLUGIN_TYPE_VERSION` varchar(20) NOT NULL DEFAULT '',
  `PLUGIN_LIBRARY` varchar(64) DEFAULT NULL,
  `PLUGIN_LIBRARY_VERSION` varchar(20) DEFAULT NULL,
  `PLUGIN_AUTHOR` varchar(64) DEFAULT NULL,
  `PLUGIN_DESCRIPTION` longtext DEFAULT NULL,
  `PLUGIN_LICENSE` varchar(80) NOT NULL DEFAULT '',
  `LOAD_OPTION` varchar(64) NOT NULL DEFAULT '',
  `PLUGIN_MATURITY` varchar(12) NOT NULL DEFAULT '',
  `PLUGIN_AUTH_VERSION` varchar(80) DEFAULT NULL
) ENGINE=Aria DEFAULT CHARSET=utf8 PAGE_CHECKSUM=0;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.APPLICABLE_ROLES
CREATE TEMPORARY TABLE IF NOT EXISTS `APPLICABLE_ROLES` (
  `GRANTEE` varchar(190) NOT NULL DEFAULT '',
  `ROLE_NAME` varchar(128) NOT NULL DEFAULT '',
  `IS_GRANTABLE` varchar(3) NOT NULL DEFAULT '',
  `IS_DEFAULT` varchar(3) DEFAULT NULL
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.CHARACTER_SETS
CREATE TEMPORARY TABLE IF NOT EXISTS `CHARACTER_SETS` (
  `CHARACTER_SET_NAME` varchar(32) NOT NULL DEFAULT '',
  `DEFAULT_COLLATE_NAME` varchar(32) NOT NULL DEFAULT '',
  `DESCRIPTION` varchar(60) NOT NULL DEFAULT '',
  `MAXLEN` bigint(3) NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.CLIENT_STATISTICS
CREATE TEMPORARY TABLE IF NOT EXISTS `CLIENT_STATISTICS` (
  `CLIENT` varchar(64) NOT NULL DEFAULT '',
  `TOTAL_CONNECTIONS` bigint(21) NOT NULL DEFAULT 0,
  `CONCURRENT_CONNECTIONS` bigint(21) NOT NULL DEFAULT 0,
  `CONNECTED_TIME` bigint(21) NOT NULL DEFAULT 0,
  `BUSY_TIME` double NOT NULL DEFAULT 0,
  `CPU_TIME` double NOT NULL DEFAULT 0,
  `BYTES_RECEIVED` bigint(21) NOT NULL DEFAULT 0,
  `BYTES_SENT` bigint(21) NOT NULL DEFAULT 0,
  `BINLOG_BYTES_WRITTEN` bigint(21) NOT NULL DEFAULT 0,
  `ROWS_READ` bigint(21) NOT NULL DEFAULT 0,
  `ROWS_SENT` bigint(21) NOT NULL DEFAULT 0,
  `ROWS_DELETED` bigint(21) NOT NULL DEFAULT 0,
  `ROWS_INSERTED` bigint(21) NOT NULL DEFAULT 0,
  `ROWS_UPDATED` bigint(21) NOT NULL DEFAULT 0,
  `SELECT_COMMANDS` bigint(21) NOT NULL DEFAULT 0,
  `UPDATE_COMMANDS` bigint(21) NOT NULL DEFAULT 0,
  `OTHER_COMMANDS` bigint(21) NOT NULL DEFAULT 0,
  `COMMIT_TRANSACTIONS` bigint(21) NOT NULL DEFAULT 0,
  `ROLLBACK_TRANSACTIONS` bigint(21) NOT NULL DEFAULT 0,
  `DENIED_CONNECTIONS` bigint(21) NOT NULL DEFAULT 0,
  `LOST_CONNECTIONS` bigint(21) NOT NULL DEFAULT 0,
  `ACCESS_DENIED` bigint(21) NOT NULL DEFAULT 0,
  `EMPTY_QUERIES` bigint(21) NOT NULL DEFAULT 0,
  `TOTAL_SSL_CONNECTIONS` bigint(21) unsigned NOT NULL DEFAULT 0,
  `MAX_STATEMENT_TIME_EXCEEDED` bigint(21) NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.COLLATIONS
CREATE TEMPORARY TABLE IF NOT EXISTS `COLLATIONS` (
  `COLLATION_NAME` varchar(32) NOT NULL DEFAULT '',
  `CHARACTER_SET_NAME` varchar(32) NOT NULL DEFAULT '',
  `ID` bigint(11) NOT NULL DEFAULT 0,
  `IS_DEFAULT` varchar(3) NOT NULL DEFAULT '',
  `IS_COMPILED` varchar(3) NOT NULL DEFAULT '',
  `SORTLEN` bigint(3) NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.COLLATION_CHARACTER_SET_APPLICABILITY
CREATE TEMPORARY TABLE IF NOT EXISTS `COLLATION_CHARACTER_SET_APPLICABILITY` (
  `COLLATION_NAME` varchar(32) NOT NULL DEFAULT '',
  `CHARACTER_SET_NAME` varchar(32) NOT NULL DEFAULT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.COLUMNS
CREATE TEMPORARY TABLE IF NOT EXISTS `COLUMNS` (
  `TABLE_CATALOG` varchar(512) NOT NULL DEFAULT '',
  `TABLE_SCHEMA` varchar(64) NOT NULL DEFAULT '',
  `TABLE_NAME` varchar(64) NOT NULL DEFAULT '',
  `COLUMN_NAME` varchar(64) NOT NULL DEFAULT '',
  `ORDINAL_POSITION` bigint(21) unsigned NOT NULL DEFAULT 0,
  `COLUMN_DEFAULT` longtext DEFAULT NULL,
  `IS_NULLABLE` varchar(3) NOT NULL DEFAULT '',
  `DATA_TYPE` varchar(64) NOT NULL DEFAULT '',
  `CHARACTER_MAXIMUM_LENGTH` bigint(21) unsigned DEFAULT NULL,
  `CHARACTER_OCTET_LENGTH` bigint(21) unsigned DEFAULT NULL,
  `NUMERIC_PRECISION` bigint(21) unsigned DEFAULT NULL,
  `NUMERIC_SCALE` bigint(21) unsigned DEFAULT NULL,
  `DATETIME_PRECISION` bigint(21) unsigned DEFAULT NULL,
  `CHARACTER_SET_NAME` varchar(32) DEFAULT NULL,
  `COLLATION_NAME` varchar(32) DEFAULT NULL,
  `COLUMN_TYPE` longtext NOT NULL DEFAULT '',
  `COLUMN_KEY` varchar(3) NOT NULL DEFAULT '',
  `EXTRA` varchar(30) NOT NULL DEFAULT '',
  `PRIVILEGES` varchar(80) NOT NULL DEFAULT '',
  `COLUMN_COMMENT` varchar(1024) NOT NULL DEFAULT '',
  `IS_GENERATED` varchar(6) NOT NULL DEFAULT '',
  `GENERATION_EXPRESSION` longtext DEFAULT NULL
) ENGINE=Aria DEFAULT CHARSET=utf8 PAGE_CHECKSUM=0;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.COLUMN_PRIVILEGES
CREATE TEMPORARY TABLE IF NOT EXISTS `COLUMN_PRIVILEGES` (
  `GRANTEE` varchar(190) NOT NULL DEFAULT '',
  `TABLE_CATALOG` varchar(512) NOT NULL DEFAULT '',
  `TABLE_SCHEMA` varchar(64) NOT NULL DEFAULT '',
  `TABLE_NAME` varchar(64) NOT NULL DEFAULT '',
  `COLUMN_NAME` varchar(64) NOT NULL DEFAULT '',
  `PRIVILEGE_TYPE` varchar(64) NOT NULL DEFAULT '',
  `IS_GRANTABLE` varchar(3) NOT NULL DEFAULT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.ENABLED_ROLES
CREATE TEMPORARY TABLE IF NOT EXISTS `ENABLED_ROLES` (
  `ROLE_NAME` varchar(128) DEFAULT NULL
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.ENGINES
CREATE TEMPORARY TABLE IF NOT EXISTS `ENGINES` (
  `ENGINE` varchar(64) NOT NULL DEFAULT '',
  `SUPPORT` varchar(8) NOT NULL DEFAULT '',
  `COMMENT` varchar(160) NOT NULL DEFAULT '',
  `TRANSACTIONS` varchar(3) DEFAULT NULL,
  `XA` varchar(3) DEFAULT NULL,
  `SAVEPOINTS` varchar(3) DEFAULT NULL
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.EVENTS
CREATE TEMPORARY TABLE IF NOT EXISTS `EVENTS` (
  `EVENT_CATALOG` varchar(64) NOT NULL DEFAULT '',
  `EVENT_SCHEMA` varchar(64) NOT NULL DEFAULT '',
  `EVENT_NAME` varchar(64) NOT NULL DEFAULT '',
  `DEFINER` varchar(189) NOT NULL DEFAULT '',
  `TIME_ZONE` varchar(64) NOT NULL DEFAULT '',
  `EVENT_BODY` varchar(8) NOT NULL DEFAULT '',
  `EVENT_DEFINITION` longtext NOT NULL DEFAULT '',
  `EVENT_TYPE` varchar(9) NOT NULL DEFAULT '',
  `EXECUTE_AT` datetime DEFAULT NULL,
  `INTERVAL_VALUE` varchar(256) DEFAULT NULL,
  `INTERVAL_FIELD` varchar(18) DEFAULT NULL,
  `SQL_MODE` varchar(8192) NOT NULL DEFAULT '',
  `STARTS` datetime DEFAULT NULL,
  `ENDS` datetime DEFAULT NULL,
  `STATUS` varchar(18) NOT NULL DEFAULT '',
  `ON_COMPLETION` varchar(12) NOT NULL DEFAULT '',
  `CREATED` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `LAST_ALTERED` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `LAST_EXECUTED` datetime DEFAULT NULL,
  `EVENT_COMMENT` varchar(64) NOT NULL DEFAULT '',
  `ORIGINATOR` bigint(10) NOT NULL DEFAULT 0,
  `CHARACTER_SET_CLIENT` varchar(32) NOT NULL DEFAULT '',
  `COLLATION_CONNECTION` varchar(32) NOT NULL DEFAULT '',
  `DATABASE_COLLATION` varchar(32) NOT NULL DEFAULT ''
) ENGINE=Aria DEFAULT CHARSET=utf8 PAGE_CHECKSUM=0;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.FILES
CREATE TEMPORARY TABLE IF NOT EXISTS `FILES` (
  `FILE_ID` bigint(4) NOT NULL DEFAULT 0,
  `FILE_NAME` varchar(512) DEFAULT NULL,
  `FILE_TYPE` varchar(20) NOT NULL DEFAULT '',
  `TABLESPACE_NAME` varchar(64) DEFAULT NULL,
  `TABLE_CATALOG` varchar(64) NOT NULL DEFAULT '',
  `TABLE_SCHEMA` varchar(64) DEFAULT NULL,
  `TABLE_NAME` varchar(64) DEFAULT NULL,
  `LOGFILE_GROUP_NAME` varchar(64) DEFAULT NULL,
  `LOGFILE_GROUP_NUMBER` bigint(4) DEFAULT NULL,
  `ENGINE` varchar(64) NOT NULL DEFAULT '',
  `FULLTEXT_KEYS` varchar(64) DEFAULT NULL,
  `DELETED_ROWS` bigint(4) DEFAULT NULL,
  `UPDATE_COUNT` bigint(4) DEFAULT NULL,
  `FREE_EXTENTS` bigint(4) DEFAULT NULL,
  `TOTAL_EXTENTS` bigint(4) DEFAULT NULL,
  `EXTENT_SIZE` bigint(4) NOT NULL DEFAULT 0,
  `INITIAL_SIZE` bigint(21) unsigned DEFAULT NULL,
  `MAXIMUM_SIZE` bigint(21) unsigned DEFAULT NULL,
  `AUTOEXTEND_SIZE` bigint(21) unsigned DEFAULT NULL,
  `CREATION_TIME` datetime DEFAULT NULL,
  `LAST_UPDATE_TIME` datetime DEFAULT NULL,
  `LAST_ACCESS_TIME` datetime DEFAULT NULL,
  `RECOVER_TIME` bigint(4) DEFAULT NULL,
  `TRANSACTION_COUNTER` bigint(4) DEFAULT NULL,
  `VERSION` bigint(21) unsigned DEFAULT NULL,
  `ROW_FORMAT` varchar(10) DEFAULT NULL,
  `TABLE_ROWS` bigint(21) unsigned DEFAULT NULL,
  `AVG_ROW_LENGTH` bigint(21) unsigned DEFAULT NULL,
  `DATA_LENGTH` bigint(21) unsigned DEFAULT NULL,
  `MAX_DATA_LENGTH` bigint(21) unsigned DEFAULT NULL,
  `INDEX_LENGTH` bigint(21) unsigned DEFAULT NULL,
  `DATA_FREE` bigint(21) unsigned DEFAULT NULL,
  `CREATE_TIME` datetime DEFAULT NULL,
  `UPDATE_TIME` datetime DEFAULT NULL,
  `CHECK_TIME` datetime DEFAULT NULL,
  `CHECKSUM` bigint(21) unsigned DEFAULT NULL,
  `STATUS` varchar(20) NOT NULL DEFAULT '',
  `EXTRA` varchar(255) DEFAULT NULL
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.GEOMETRY_COLUMNS
CREATE TEMPORARY TABLE IF NOT EXISTS `GEOMETRY_COLUMNS` (
  `F_TABLE_CATALOG` varchar(512) NOT NULL DEFAULT '',
  `F_TABLE_SCHEMA` varchar(64) NOT NULL DEFAULT '',
  `F_TABLE_NAME` varchar(64) NOT NULL DEFAULT '',
  `F_GEOMETRY_COLUMN` varchar(64) NOT NULL DEFAULT '',
  `G_TABLE_CATALOG` varchar(512) NOT NULL DEFAULT '',
  `G_TABLE_SCHEMA` varchar(64) NOT NULL DEFAULT '',
  `G_TABLE_NAME` varchar(64) NOT NULL DEFAULT '',
  `G_GEOMETRY_COLUMN` varchar(64) NOT NULL DEFAULT '',
  `STORAGE_TYPE` tinyint(2) NOT NULL DEFAULT 0,
  `GEOMETRY_TYPE` int(7) NOT NULL DEFAULT 0,
  `COORD_DIMENSION` tinyint(2) NOT NULL DEFAULT 0,
  `MAX_PPR` tinyint(2) NOT NULL DEFAULT 0,
  `SRID` smallint(5) NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.GLOBAL_STATUS
CREATE TEMPORARY TABLE IF NOT EXISTS `GLOBAL_STATUS` (
  `VARIABLE_NAME` varchar(64) NOT NULL DEFAULT '',
  `VARIABLE_VALUE` varchar(2048) NOT NULL DEFAULT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.GLOBAL_VARIABLES
CREATE TEMPORARY TABLE IF NOT EXISTS `GLOBAL_VARIABLES` (
  `VARIABLE_NAME` varchar(64) NOT NULL DEFAULT '',
  `VARIABLE_VALUE` varchar(2048) NOT NULL DEFAULT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INDEX_STATISTICS
CREATE TEMPORARY TABLE IF NOT EXISTS `INDEX_STATISTICS` (
  `TABLE_SCHEMA` varchar(192) NOT NULL DEFAULT '',
  `TABLE_NAME` varchar(192) NOT NULL DEFAULT '',
  `INDEX_NAME` varchar(192) NOT NULL DEFAULT '',
  `ROWS_READ` bigint(21) NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_BUFFER_PAGE
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_BUFFER_PAGE` (
  `POOL_ID` bigint(21) unsigned NOT NULL DEFAULT 0,
  `BLOCK_ID` bigint(21) unsigned NOT NULL DEFAULT 0,
  `SPACE` bigint(21) unsigned NOT NULL DEFAULT 0,
  `PAGE_NUMBER` bigint(21) unsigned NOT NULL DEFAULT 0,
  `PAGE_TYPE` varchar(64) DEFAULT NULL,
  `FLUSH_TYPE` bigint(21) unsigned NOT NULL DEFAULT 0,
  `FIX_COUNT` bigint(21) unsigned NOT NULL DEFAULT 0,
  `IS_HASHED` varchar(3) DEFAULT NULL,
  `NEWEST_MODIFICATION` bigint(21) unsigned NOT NULL DEFAULT 0,
  `OLDEST_MODIFICATION` bigint(21) unsigned NOT NULL DEFAULT 0,
  `ACCESS_TIME` bigint(21) unsigned NOT NULL DEFAULT 0,
  `TABLE_NAME` varchar(1024) DEFAULT NULL,
  `INDEX_NAME` varchar(1024) DEFAULT NULL,
  `NUMBER_RECORDS` bigint(21) unsigned NOT NULL DEFAULT 0,
  `DATA_SIZE` bigint(21) unsigned NOT NULL DEFAULT 0,
  `COMPRESSED_SIZE` bigint(21) unsigned NOT NULL DEFAULT 0,
  `PAGE_STATE` varchar(64) DEFAULT NULL,
  `IO_FIX` varchar(64) DEFAULT NULL,
  `IS_OLD` varchar(3) DEFAULT NULL,
  `FREE_PAGE_CLOCK` bigint(21) unsigned NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_BUFFER_PAGE_LRU
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_BUFFER_PAGE_LRU` (
  `POOL_ID` bigint(21) unsigned NOT NULL DEFAULT 0,
  `LRU_POSITION` bigint(21) unsigned NOT NULL DEFAULT 0,
  `SPACE` bigint(21) unsigned NOT NULL DEFAULT 0,
  `PAGE_NUMBER` bigint(21) unsigned NOT NULL DEFAULT 0,
  `PAGE_TYPE` varchar(64) DEFAULT NULL,
  `FLUSH_TYPE` bigint(21) unsigned NOT NULL DEFAULT 0,
  `FIX_COUNT` bigint(21) unsigned NOT NULL DEFAULT 0,
  `IS_HASHED` varchar(3) DEFAULT NULL,
  `NEWEST_MODIFICATION` bigint(21) unsigned NOT NULL DEFAULT 0,
  `OLDEST_MODIFICATION` bigint(21) unsigned NOT NULL DEFAULT 0,
  `ACCESS_TIME` bigint(21) unsigned NOT NULL DEFAULT 0,
  `TABLE_NAME` varchar(1024) DEFAULT NULL,
  `INDEX_NAME` varchar(1024) DEFAULT NULL,
  `NUMBER_RECORDS` bigint(21) unsigned NOT NULL DEFAULT 0,
  `DATA_SIZE` bigint(21) unsigned NOT NULL DEFAULT 0,
  `COMPRESSED_SIZE` bigint(21) unsigned NOT NULL DEFAULT 0,
  `COMPRESSED` varchar(3) DEFAULT NULL,
  `IO_FIX` varchar(64) DEFAULT NULL,
  `IS_OLD` varchar(3) DEFAULT NULL,
  `FREE_PAGE_CLOCK` bigint(21) unsigned NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_BUFFER_POOL_STATS
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_BUFFER_POOL_STATS` (
  `POOL_ID` bigint(21) unsigned NOT NULL DEFAULT 0,
  `POOL_SIZE` bigint(21) unsigned NOT NULL DEFAULT 0,
  `FREE_BUFFERS` bigint(21) unsigned NOT NULL DEFAULT 0,
  `DATABASE_PAGES` bigint(21) unsigned NOT NULL DEFAULT 0,
  `OLD_DATABASE_PAGES` bigint(21) unsigned NOT NULL DEFAULT 0,
  `MODIFIED_DATABASE_PAGES` bigint(21) unsigned NOT NULL DEFAULT 0,
  `PENDING_DECOMPRESS` bigint(21) unsigned NOT NULL DEFAULT 0,
  `PENDING_READS` bigint(21) unsigned NOT NULL DEFAULT 0,
  `PENDING_FLUSH_LRU` bigint(21) unsigned NOT NULL DEFAULT 0,
  `PENDING_FLUSH_LIST` bigint(21) unsigned NOT NULL DEFAULT 0,
  `PAGES_MADE_YOUNG` bigint(21) unsigned NOT NULL DEFAULT 0,
  `PAGES_NOT_MADE_YOUNG` bigint(21) unsigned NOT NULL DEFAULT 0,
  `PAGES_MADE_YOUNG_RATE` double NOT NULL DEFAULT 0,
  `PAGES_MADE_NOT_YOUNG_RATE` double NOT NULL DEFAULT 0,
  `NUMBER_PAGES_READ` bigint(21) unsigned NOT NULL DEFAULT 0,
  `NUMBER_PAGES_CREATED` bigint(21) unsigned NOT NULL DEFAULT 0,
  `NUMBER_PAGES_WRITTEN` bigint(21) unsigned NOT NULL DEFAULT 0,
  `PAGES_READ_RATE` double NOT NULL DEFAULT 0,
  `PAGES_CREATE_RATE` double NOT NULL DEFAULT 0,
  `PAGES_WRITTEN_RATE` double NOT NULL DEFAULT 0,
  `NUMBER_PAGES_GET` bigint(21) unsigned NOT NULL DEFAULT 0,
  `HIT_RATE` bigint(21) unsigned NOT NULL DEFAULT 0,
  `YOUNG_MAKE_PER_THOUSAND_GETS` bigint(21) unsigned NOT NULL DEFAULT 0,
  `NOT_YOUNG_MAKE_PER_THOUSAND_GETS` bigint(21) unsigned NOT NULL DEFAULT 0,
  `NUMBER_PAGES_READ_AHEAD` bigint(21) unsigned NOT NULL DEFAULT 0,
  `NUMBER_READ_AHEAD_EVICTED` bigint(21) unsigned NOT NULL DEFAULT 0,
  `READ_AHEAD_RATE` double NOT NULL DEFAULT 0,
  `READ_AHEAD_EVICTED_RATE` double NOT NULL DEFAULT 0,
  `LRU_IO_TOTAL` bigint(21) unsigned NOT NULL DEFAULT 0,
  `LRU_IO_CURRENT` bigint(21) unsigned NOT NULL DEFAULT 0,
  `UNCOMPRESS_TOTAL` bigint(21) unsigned NOT NULL DEFAULT 0,
  `UNCOMPRESS_CURRENT` bigint(21) unsigned NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_CMP
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_CMP` (
  `page_size` int(5) NOT NULL DEFAULT 0,
  `compress_ops` int(11) NOT NULL DEFAULT 0,
  `compress_ops_ok` int(11) NOT NULL DEFAULT 0,
  `compress_time` int(11) NOT NULL DEFAULT 0,
  `uncompress_ops` int(11) NOT NULL DEFAULT 0,
  `uncompress_time` int(11) NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_CMPMEM
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_CMPMEM` (
  `page_size` int(5) NOT NULL DEFAULT 0,
  `buffer_pool_instance` int(11) NOT NULL DEFAULT 0,
  `pages_used` int(11) NOT NULL DEFAULT 0,
  `pages_free` int(11) NOT NULL DEFAULT 0,
  `relocation_ops` bigint(21) NOT NULL DEFAULT 0,
  `relocation_time` int(11) NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_CMPMEM_RESET
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_CMPMEM_RESET` (
  `page_size` int(5) NOT NULL DEFAULT 0,
  `buffer_pool_instance` int(11) NOT NULL DEFAULT 0,
  `pages_used` int(11) NOT NULL DEFAULT 0,
  `pages_free` int(11) NOT NULL DEFAULT 0,
  `relocation_ops` bigint(21) NOT NULL DEFAULT 0,
  `relocation_time` int(11) NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_CMP_PER_INDEX
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_CMP_PER_INDEX` (
  `database_name` varchar(192) NOT NULL DEFAULT '',
  `table_name` varchar(192) NOT NULL DEFAULT '',
  `index_name` varchar(192) NOT NULL DEFAULT '',
  `compress_ops` int(11) NOT NULL DEFAULT 0,
  `compress_ops_ok` int(11) NOT NULL DEFAULT 0,
  `compress_time` int(11) NOT NULL DEFAULT 0,
  `uncompress_ops` int(11) NOT NULL DEFAULT 0,
  `uncompress_time` int(11) NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_CMP_PER_INDEX_RESET
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_CMP_PER_INDEX_RESET` (
  `database_name` varchar(192) NOT NULL DEFAULT '',
  `table_name` varchar(192) NOT NULL DEFAULT '',
  `index_name` varchar(192) NOT NULL DEFAULT '',
  `compress_ops` int(11) NOT NULL DEFAULT 0,
  `compress_ops_ok` int(11) NOT NULL DEFAULT 0,
  `compress_time` int(11) NOT NULL DEFAULT 0,
  `uncompress_ops` int(11) NOT NULL DEFAULT 0,
  `uncompress_time` int(11) NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_CMP_RESET
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_CMP_RESET` (
  `page_size` int(5) NOT NULL DEFAULT 0,
  `compress_ops` int(11) NOT NULL DEFAULT 0,
  `compress_ops_ok` int(11) NOT NULL DEFAULT 0,
  `compress_time` int(11) NOT NULL DEFAULT 0,
  `uncompress_ops` int(11) NOT NULL DEFAULT 0,
  `uncompress_time` int(11) NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_FT_BEING_DELETED
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_FT_BEING_DELETED` (
  `DOC_ID` bigint(21) unsigned NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_FT_CONFIG
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_FT_CONFIG` (
  `KEY` varchar(193) NOT NULL DEFAULT '',
  `VALUE` varchar(193) NOT NULL DEFAULT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_FT_DEFAULT_STOPWORD
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_FT_DEFAULT_STOPWORD` (
  `value` varchar(18) NOT NULL DEFAULT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_FT_DELETED
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_FT_DELETED` (
  `DOC_ID` bigint(21) unsigned NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_FT_INDEX_CACHE
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_FT_INDEX_CACHE` (
  `WORD` varchar(337) NOT NULL DEFAULT '',
  `FIRST_DOC_ID` bigint(21) unsigned NOT NULL DEFAULT 0,
  `LAST_DOC_ID` bigint(21) unsigned NOT NULL DEFAULT 0,
  `DOC_COUNT` bigint(21) unsigned NOT NULL DEFAULT 0,
  `DOC_ID` bigint(21) unsigned NOT NULL DEFAULT 0,
  `POSITION` bigint(21) unsigned NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_FT_INDEX_TABLE
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_FT_INDEX_TABLE` (
  `WORD` varchar(337) NOT NULL DEFAULT '',
  `FIRST_DOC_ID` bigint(21) unsigned NOT NULL DEFAULT 0,
  `LAST_DOC_ID` bigint(21) unsigned NOT NULL DEFAULT 0,
  `DOC_COUNT` bigint(21) unsigned NOT NULL DEFAULT 0,
  `DOC_ID` bigint(21) unsigned NOT NULL DEFAULT 0,
  `POSITION` bigint(21) unsigned NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_LOCKS
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_LOCKS` (
  `lock_id` varchar(81) NOT NULL DEFAULT '',
  `lock_trx_id` varchar(18) NOT NULL DEFAULT '',
  `lock_mode` varchar(32) NOT NULL DEFAULT '',
  `lock_type` varchar(32) NOT NULL DEFAULT '',
  `lock_table` varchar(1024) NOT NULL DEFAULT '',
  `lock_index` varchar(1024) DEFAULT NULL,
  `lock_space` bigint(21) unsigned DEFAULT NULL,
  `lock_page` bigint(21) unsigned DEFAULT NULL,
  `lock_rec` bigint(21) unsigned DEFAULT NULL,
  `lock_data` varchar(8192) DEFAULT NULL
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_LOCK_WAITS
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_LOCK_WAITS` (
  `requesting_trx_id` varchar(18) NOT NULL DEFAULT '',
  `requested_lock_id` varchar(81) NOT NULL DEFAULT '',
  `blocking_trx_id` varchar(18) NOT NULL DEFAULT '',
  `blocking_lock_id` varchar(81) NOT NULL DEFAULT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_METRICS
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_METRICS` (
  `NAME` varchar(193) NOT NULL DEFAULT '',
  `SUBSYSTEM` varchar(193) NOT NULL DEFAULT '',
  `COUNT` bigint(21) NOT NULL DEFAULT 0,
  `MAX_COUNT` bigint(21) DEFAULT NULL,
  `MIN_COUNT` bigint(21) DEFAULT NULL,
  `AVG_COUNT` double DEFAULT NULL,
  `COUNT_RESET` bigint(21) NOT NULL DEFAULT 0,
  `MAX_COUNT_RESET` bigint(21) DEFAULT NULL,
  `MIN_COUNT_RESET` bigint(21) DEFAULT NULL,
  `AVG_COUNT_RESET` double DEFAULT NULL,
  `TIME_ENABLED` datetime DEFAULT NULL,
  `TIME_DISABLED` datetime DEFAULT NULL,
  `TIME_ELAPSED` bigint(21) DEFAULT NULL,
  `TIME_RESET` datetime DEFAULT NULL,
  `STATUS` varchar(193) NOT NULL DEFAULT '',
  `TYPE` varchar(193) NOT NULL DEFAULT '',
  `COMMENT` varchar(193) NOT NULL DEFAULT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_MUTEXES
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_MUTEXES` (
  `NAME` varchar(4000) NOT NULL DEFAULT '',
  `CREATE_FILE` varchar(4000) NOT NULL DEFAULT '',
  `CREATE_LINE` int(11) unsigned NOT NULL DEFAULT 0,
  `OS_WAITS` bigint(21) unsigned NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_SYS_COLUMNS
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_SYS_COLUMNS` (
  `TABLE_ID` bigint(21) unsigned NOT NULL DEFAULT 0,
  `NAME` varchar(193) NOT NULL DEFAULT '',
  `POS` bigint(21) unsigned NOT NULL DEFAULT 0,
  `MTYPE` int(11) NOT NULL DEFAULT 0,
  `PRTYPE` int(11) NOT NULL DEFAULT 0,
  `LEN` int(11) NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_SYS_DATAFILES
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_SYS_DATAFILES` (
  `SPACE` int(11) unsigned NOT NULL DEFAULT 0,
  `PATH` varchar(4000) NOT NULL DEFAULT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_SYS_FIELDS
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_SYS_FIELDS` (
  `INDEX_ID` bigint(21) unsigned NOT NULL DEFAULT 0,
  `NAME` varchar(193) NOT NULL DEFAULT '',
  `POS` int(11) unsigned NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_SYS_FOREIGN
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_SYS_FOREIGN` (
  `ID` varchar(193) NOT NULL DEFAULT '',
  `FOR_NAME` varchar(193) NOT NULL DEFAULT '',
  `REF_NAME` varchar(193) NOT NULL DEFAULT '',
  `N_COLS` int(11) unsigned NOT NULL DEFAULT 0,
  `TYPE` int(11) unsigned NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_SYS_FOREIGN_COLS
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_SYS_FOREIGN_COLS` (
  `ID` varchar(193) NOT NULL DEFAULT '',
  `FOR_COL_NAME` varchar(193) NOT NULL DEFAULT '',
  `REF_COL_NAME` varchar(193) NOT NULL DEFAULT '',
  `POS` int(11) unsigned NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_SYS_INDEXES
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_SYS_INDEXES` (
  `INDEX_ID` bigint(21) unsigned NOT NULL DEFAULT 0,
  `NAME` varchar(193) NOT NULL DEFAULT '',
  `TABLE_ID` bigint(21) unsigned NOT NULL DEFAULT 0,
  `TYPE` int(11) NOT NULL DEFAULT 0,
  `N_FIELDS` int(11) NOT NULL DEFAULT 0,
  `PAGE_NO` int(11) NOT NULL DEFAULT 0,
  `SPACE` int(11) NOT NULL DEFAULT 0,
  `MERGE_THRESHOLD` int(11) NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_SYS_SEMAPHORE_WAITS
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_SYS_SEMAPHORE_WAITS` (
  `THREAD_ID` bigint(21) unsigned NOT NULL DEFAULT 0,
  `OBJECT_NAME` varchar(4000) DEFAULT NULL,
  `FILE` varchar(4000) DEFAULT NULL,
  `LINE` int(11) unsigned NOT NULL DEFAULT 0,
  `WAIT_TIME` bigint(21) unsigned NOT NULL DEFAULT 0,
  `WAIT_OBJECT` bigint(21) unsigned NOT NULL DEFAULT 0,
  `WAIT_TYPE` varchar(16) DEFAULT NULL,
  `HOLDER_THREAD_ID` bigint(21) unsigned NOT NULL DEFAULT 0,
  `HOLDER_FILE` varchar(4000) DEFAULT NULL,
  `HOLDER_LINE` int(11) unsigned NOT NULL DEFAULT 0,
  `CREATED_FILE` varchar(4000) DEFAULT NULL,
  `CREATED_LINE` int(11) unsigned NOT NULL DEFAULT 0,
  `WRITER_THREAD` bigint(21) unsigned NOT NULL DEFAULT 0,
  `RESERVATION_MODE` varchar(16) DEFAULT NULL,
  `READERS` int(11) unsigned NOT NULL DEFAULT 0,
  `WAITERS_FLAG` bigint(21) unsigned NOT NULL DEFAULT 0,
  `LOCK_WORD` bigint(21) unsigned NOT NULL DEFAULT 0,
  `LAST_READER_FILE` varchar(4000) DEFAULT NULL,
  `LAST_READER_LINE` int(11) unsigned NOT NULL DEFAULT 0,
  `LAST_WRITER_FILE` varchar(4000) DEFAULT NULL,
  `LAST_WRITER_LINE` int(11) unsigned NOT NULL DEFAULT 0,
  `OS_WAIT_COUNT` int(11) unsigned NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_SYS_TABLES
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_SYS_TABLES` (
  `TABLE_ID` bigint(21) unsigned NOT NULL DEFAULT 0,
  `NAME` varchar(655) NOT NULL DEFAULT '',
  `FLAG` int(11) NOT NULL DEFAULT 0,
  `N_COLS` int(11) NOT NULL DEFAULT 0,
  `SPACE` int(11) NOT NULL DEFAULT 0,
  `FILE_FORMAT` varchar(10) DEFAULT NULL,
  `ROW_FORMAT` varchar(12) DEFAULT NULL,
  `ZIP_PAGE_SIZE` int(11) unsigned NOT NULL DEFAULT 0,
  `SPACE_TYPE` varchar(10) DEFAULT NULL
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_SYS_TABLESPACES
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_SYS_TABLESPACES` (
  `SPACE` int(11) unsigned NOT NULL DEFAULT 0,
  `NAME` varchar(655) NOT NULL DEFAULT '',
  `FLAG` int(11) unsigned NOT NULL DEFAULT 0,
  `FILE_FORMAT` varchar(10) DEFAULT NULL,
  `ROW_FORMAT` varchar(22) DEFAULT NULL,
  `PAGE_SIZE` int(11) unsigned NOT NULL DEFAULT 0,
  `ZIP_PAGE_SIZE` int(11) unsigned NOT NULL DEFAULT 0,
  `SPACE_TYPE` varchar(10) DEFAULT NULL,
  `FS_BLOCK_SIZE` int(11) unsigned NOT NULL DEFAULT 0,
  `FILE_SIZE` bigint(21) unsigned NOT NULL DEFAULT 0,
  `ALLOCATED_SIZE` bigint(21) unsigned NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_SYS_TABLESTATS
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_SYS_TABLESTATS` (
  `TABLE_ID` bigint(21) unsigned NOT NULL DEFAULT 0,
  `NAME` varchar(193) NOT NULL DEFAULT '',
  `STATS_INITIALIZED` varchar(193) NOT NULL DEFAULT '',
  `NUM_ROWS` bigint(21) unsigned NOT NULL DEFAULT 0,
  `CLUST_INDEX_SIZE` bigint(21) unsigned NOT NULL DEFAULT 0,
  `OTHER_INDEX_SIZE` bigint(21) unsigned NOT NULL DEFAULT 0,
  `MODIFIED_COUNTER` bigint(21) unsigned NOT NULL DEFAULT 0,
  `AUTOINC` bigint(21) unsigned NOT NULL DEFAULT 0,
  `REF_COUNT` int(11) NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_SYS_VIRTUAL
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_SYS_VIRTUAL` (
  `TABLE_ID` bigint(21) unsigned NOT NULL DEFAULT 0,
  `POS` int(11) unsigned NOT NULL DEFAULT 0,
  `BASE_POS` int(11) unsigned NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_TABLESPACES_ENCRYPTION
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_TABLESPACES_ENCRYPTION` (
  `SPACE` int(11) unsigned NOT NULL DEFAULT 0,
  `NAME` varchar(655) DEFAULT NULL,
  `ENCRYPTION_SCHEME` int(11) unsigned NOT NULL DEFAULT 0,
  `KEYSERVER_REQUESTS` int(11) unsigned NOT NULL DEFAULT 0,
  `MIN_KEY_VERSION` int(11) unsigned NOT NULL DEFAULT 0,
  `CURRENT_KEY_VERSION` int(11) unsigned NOT NULL DEFAULT 0,
  `KEY_ROTATION_PAGE_NUMBER` bigint(21) unsigned DEFAULT NULL,
  `KEY_ROTATION_MAX_PAGE_NUMBER` bigint(21) unsigned DEFAULT NULL,
  `CURRENT_KEY_ID` int(11) unsigned NOT NULL DEFAULT 0,
  `ROTATING_OR_FLUSHING` int(1) unsigned NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_TABLESPACES_SCRUBBING
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_TABLESPACES_SCRUBBING` (
  `SPACE` bigint(21) unsigned NOT NULL DEFAULT 0,
  `NAME` varchar(655) DEFAULT NULL,
  `COMPRESSED` int(11) unsigned NOT NULL DEFAULT 0,
  `LAST_SCRUB_COMPLETED` datetime DEFAULT NULL,
  `CURRENT_SCRUB_STARTED` datetime DEFAULT NULL,
  `CURRENT_SCRUB_ACTIVE_THREADS` int(11) unsigned DEFAULT NULL,
  `CURRENT_SCRUB_PAGE_NUMBER` bigint(21) unsigned NOT NULL DEFAULT 0,
  `CURRENT_SCRUB_MAX_PAGE_NUMBER` bigint(21) unsigned NOT NULL DEFAULT 0,
  `ROTATING_OR_FLUSHING` int(11) unsigned NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.INNODB_TRX
CREATE TEMPORARY TABLE IF NOT EXISTS `INNODB_TRX` (
  `trx_id` varchar(18) NOT NULL DEFAULT '',
  `trx_state` varchar(13) NOT NULL DEFAULT '',
  `trx_started` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `trx_requested_lock_id` varchar(81) DEFAULT NULL,
  `trx_wait_started` datetime DEFAULT NULL,
  `trx_weight` bigint(21) unsigned NOT NULL DEFAULT 0,
  `trx_mysql_thread_id` bigint(21) unsigned NOT NULL DEFAULT 0,
  `trx_query` varchar(1024) DEFAULT NULL,
  `trx_operation_state` varchar(64) DEFAULT NULL,
  `trx_tables_in_use` bigint(21) unsigned NOT NULL DEFAULT 0,
  `trx_tables_locked` bigint(21) unsigned NOT NULL DEFAULT 0,
  `trx_lock_structs` bigint(21) unsigned NOT NULL DEFAULT 0,
  `trx_lock_memory_bytes` bigint(21) unsigned NOT NULL DEFAULT 0,
  `trx_rows_locked` bigint(21) unsigned NOT NULL DEFAULT 0,
  `trx_rows_modified` bigint(21) unsigned NOT NULL DEFAULT 0,
  `trx_concurrency_tickets` bigint(21) unsigned NOT NULL DEFAULT 0,
  `trx_isolation_level` varchar(16) NOT NULL DEFAULT '',
  `trx_unique_checks` int(1) NOT NULL DEFAULT 0,
  `trx_foreign_key_checks` int(1) NOT NULL DEFAULT 0,
  `trx_last_foreign_key_error` varchar(256) DEFAULT NULL,
  `trx_adaptive_hash_latched` int(1) NOT NULL DEFAULT 0,
  `trx_is_read_only` int(1) NOT NULL DEFAULT 0,
  `trx_autocommit_non_locking` int(1) NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.KEY_CACHES
CREATE TEMPORARY TABLE IF NOT EXISTS `KEY_CACHES` (
  `KEY_CACHE_NAME` varchar(192) NOT NULL DEFAULT '',
  `SEGMENTS` int(3) unsigned DEFAULT NULL,
  `SEGMENT_NUMBER` int(3) unsigned DEFAULT NULL,
  `FULL_SIZE` bigint(21) unsigned NOT NULL DEFAULT 0,
  `BLOCK_SIZE` bigint(21) unsigned NOT NULL DEFAULT 0,
  `USED_BLOCKS` bigint(21) unsigned NOT NULL DEFAULT 0,
  `UNUSED_BLOCKS` bigint(21) unsigned NOT NULL DEFAULT 0,
  `DIRTY_BLOCKS` bigint(21) unsigned NOT NULL DEFAULT 0,
  `READ_REQUESTS` bigint(21) unsigned NOT NULL DEFAULT 0,
  `READS` bigint(21) unsigned NOT NULL DEFAULT 0,
  `WRITE_REQUESTS` bigint(21) unsigned NOT NULL DEFAULT 0,
  `WRITES` bigint(21) unsigned NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.KEY_COLUMN_USAGE
CREATE TEMPORARY TABLE IF NOT EXISTS `KEY_COLUMN_USAGE` (
  `CONSTRAINT_CATALOG` varchar(512) NOT NULL DEFAULT '',
  `CONSTRAINT_SCHEMA` varchar(64) NOT NULL DEFAULT '',
  `CONSTRAINT_NAME` varchar(64) NOT NULL DEFAULT '',
  `TABLE_CATALOG` varchar(512) NOT NULL DEFAULT '',
  `TABLE_SCHEMA` varchar(64) NOT NULL DEFAULT '',
  `TABLE_NAME` varchar(64) NOT NULL DEFAULT '',
  `COLUMN_NAME` varchar(64) NOT NULL DEFAULT '',
  `ORDINAL_POSITION` bigint(10) NOT NULL DEFAULT 0,
  `POSITION_IN_UNIQUE_CONSTRAINT` bigint(10) DEFAULT NULL,
  `REFERENCED_TABLE_SCHEMA` varchar(64) DEFAULT NULL,
  `REFERENCED_TABLE_NAME` varchar(64) DEFAULT NULL,
  `REFERENCED_COLUMN_NAME` varchar(64) DEFAULT NULL
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.PARAMETERS
CREATE TEMPORARY TABLE IF NOT EXISTS `PARAMETERS` (
  `SPECIFIC_CATALOG` varchar(512) NOT NULL DEFAULT '',
  `SPECIFIC_SCHEMA` varchar(64) NOT NULL DEFAULT '',
  `SPECIFIC_NAME` varchar(64) NOT NULL DEFAULT '',
  `ORDINAL_POSITION` int(21) NOT NULL DEFAULT 0,
  `PARAMETER_MODE` varchar(5) DEFAULT NULL,
  `PARAMETER_NAME` varchar(64) DEFAULT NULL,
  `DATA_TYPE` varchar(64) NOT NULL DEFAULT '',
  `CHARACTER_MAXIMUM_LENGTH` int(21) DEFAULT NULL,
  `CHARACTER_OCTET_LENGTH` int(21) DEFAULT NULL,
  `NUMERIC_PRECISION` int(21) DEFAULT NULL,
  `NUMERIC_SCALE` int(21) DEFAULT NULL,
  `DATETIME_PRECISION` bigint(21) unsigned DEFAULT NULL,
  `CHARACTER_SET_NAME` varchar(64) DEFAULT NULL,
  `COLLATION_NAME` varchar(64) DEFAULT NULL,
  `DTD_IDENTIFIER` longtext NOT NULL DEFAULT '',
  `ROUTINE_TYPE` varchar(9) NOT NULL DEFAULT ''
) ENGINE=Aria DEFAULT CHARSET=utf8 PAGE_CHECKSUM=0;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.PARTITIONS
CREATE TEMPORARY TABLE IF NOT EXISTS `PARTITIONS` (
  `TABLE_CATALOG` varchar(512) NOT NULL DEFAULT '',
  `TABLE_SCHEMA` varchar(64) NOT NULL DEFAULT '',
  `TABLE_NAME` varchar(64) NOT NULL DEFAULT '',
  `PARTITION_NAME` varchar(64) DEFAULT NULL,
  `SUBPARTITION_NAME` varchar(64) DEFAULT NULL,
  `PARTITION_ORDINAL_POSITION` bigint(21) unsigned DEFAULT NULL,
  `SUBPARTITION_ORDINAL_POSITION` bigint(21) unsigned DEFAULT NULL,
  `PARTITION_METHOD` varchar(18) DEFAULT NULL,
  `SUBPARTITION_METHOD` varchar(12) DEFAULT NULL,
  `PARTITION_EXPRESSION` longtext DEFAULT NULL,
  `SUBPARTITION_EXPRESSION` longtext DEFAULT NULL,
  `PARTITION_DESCRIPTION` longtext DEFAULT NULL,
  `TABLE_ROWS` bigint(21) unsigned NOT NULL DEFAULT 0,
  `AVG_ROW_LENGTH` bigint(21) unsigned NOT NULL DEFAULT 0,
  `DATA_LENGTH` bigint(21) unsigned NOT NULL DEFAULT 0,
  `MAX_DATA_LENGTH` bigint(21) unsigned DEFAULT NULL,
  `INDEX_LENGTH` bigint(21) unsigned NOT NULL DEFAULT 0,
  `DATA_FREE` bigint(21) unsigned NOT NULL DEFAULT 0,
  `CREATE_TIME` datetime DEFAULT NULL,
  `UPDATE_TIME` datetime DEFAULT NULL,
  `CHECK_TIME` datetime DEFAULT NULL,
  `CHECKSUM` bigint(21) unsigned DEFAULT NULL,
  `PARTITION_COMMENT` varchar(80) NOT NULL DEFAULT '',
  `NODEGROUP` varchar(12) NOT NULL DEFAULT '',
  `TABLESPACE_NAME` varchar(64) DEFAULT NULL
) ENGINE=Aria DEFAULT CHARSET=utf8 PAGE_CHECKSUM=0;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.PLUGINS
CREATE TEMPORARY TABLE IF NOT EXISTS `PLUGINS` (
  `PLUGIN_NAME` varchar(64) NOT NULL DEFAULT '',
  `PLUGIN_VERSION` varchar(20) NOT NULL DEFAULT '',
  `PLUGIN_STATUS` varchar(16) NOT NULL DEFAULT '',
  `PLUGIN_TYPE` varchar(80) NOT NULL DEFAULT '',
  `PLUGIN_TYPE_VERSION` varchar(20) NOT NULL DEFAULT '',
  `PLUGIN_LIBRARY` varchar(64) DEFAULT NULL,
  `PLUGIN_LIBRARY_VERSION` varchar(20) DEFAULT NULL,
  `PLUGIN_AUTHOR` varchar(64) DEFAULT NULL,
  `PLUGIN_DESCRIPTION` longtext DEFAULT NULL,
  `PLUGIN_LICENSE` varchar(80) NOT NULL DEFAULT '',
  `LOAD_OPTION` varchar(64) NOT NULL DEFAULT '',
  `PLUGIN_MATURITY` varchar(12) NOT NULL DEFAULT '',
  `PLUGIN_AUTH_VERSION` varchar(80) DEFAULT NULL
) ENGINE=Aria DEFAULT CHARSET=utf8 PAGE_CHECKSUM=0;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.PROCESSLIST
CREATE TEMPORARY TABLE IF NOT EXISTS `PROCESSLIST` (
  `ID` bigint(4) NOT NULL DEFAULT 0,
  `USER` varchar(128) NOT NULL DEFAULT '',
  `HOST` varchar(64) NOT NULL DEFAULT '',
  `DB` varchar(64) DEFAULT NULL,
  `COMMAND` varchar(16) NOT NULL DEFAULT '',
  `TIME` int(7) NOT NULL DEFAULT 0,
  `STATE` varchar(64) DEFAULT NULL,
  `INFO` longtext DEFAULT NULL,
  `TIME_MS` decimal(22,3) NOT NULL DEFAULT 0.000,
  `STAGE` tinyint(2) NOT NULL DEFAULT 0,
  `MAX_STAGE` tinyint(2) NOT NULL DEFAULT 0,
  `PROGRESS` decimal(7,3) NOT NULL DEFAULT 0.000,
  `MEMORY_USED` bigint(7) NOT NULL DEFAULT 0,
  `EXAMINED_ROWS` int(7) NOT NULL DEFAULT 0,
  `QUERY_ID` bigint(4) NOT NULL DEFAULT 0,
  `INFO_BINARY` blob DEFAULT NULL,
  `TID` bigint(4) NOT NULL DEFAULT 0
) ENGINE=Aria DEFAULT CHARSET=utf8 PAGE_CHECKSUM=0;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.PROFILING
CREATE TEMPORARY TABLE IF NOT EXISTS `PROFILING` (
  `QUERY_ID` int(20) NOT NULL DEFAULT 0,
  `SEQ` int(20) NOT NULL DEFAULT 0,
  `STATE` varchar(30) NOT NULL DEFAULT '',
  `DURATION` decimal(9,6) NOT NULL DEFAULT 0.000000,
  `CPU_USER` decimal(9,6) DEFAULT NULL,
  `CPU_SYSTEM` decimal(9,6) DEFAULT NULL,
  `CONTEXT_VOLUNTARY` int(20) DEFAULT NULL,
  `CONTEXT_INVOLUNTARY` int(20) DEFAULT NULL,
  `BLOCK_OPS_IN` int(20) DEFAULT NULL,
  `BLOCK_OPS_OUT` int(20) DEFAULT NULL,
  `MESSAGES_SENT` int(20) DEFAULT NULL,
  `MESSAGES_RECEIVED` int(20) DEFAULT NULL,
  `PAGE_FAULTS_MAJOR` int(20) DEFAULT NULL,
  `PAGE_FAULTS_MINOR` int(20) DEFAULT NULL,
  `SWAPS` int(20) DEFAULT NULL,
  `SOURCE_FUNCTION` varchar(30) DEFAULT NULL,
  `SOURCE_FILE` varchar(20) DEFAULT NULL,
  `SOURCE_LINE` int(20) DEFAULT NULL
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.REFERENTIAL_CONSTRAINTS
CREATE TEMPORARY TABLE IF NOT EXISTS `REFERENTIAL_CONSTRAINTS` (
  `CONSTRAINT_CATALOG` varchar(512) NOT NULL DEFAULT '',
  `CONSTRAINT_SCHEMA` varchar(64) NOT NULL DEFAULT '',
  `CONSTRAINT_NAME` varchar(64) NOT NULL DEFAULT '',
  `UNIQUE_CONSTRAINT_CATALOG` varchar(512) NOT NULL DEFAULT '',
  `UNIQUE_CONSTRAINT_SCHEMA` varchar(64) NOT NULL DEFAULT '',
  `UNIQUE_CONSTRAINT_NAME` varchar(64) DEFAULT NULL,
  `MATCH_OPTION` varchar(64) NOT NULL DEFAULT '',
  `UPDATE_RULE` varchar(64) NOT NULL DEFAULT '',
  `DELETE_RULE` varchar(64) NOT NULL DEFAULT '',
  `TABLE_NAME` varchar(64) NOT NULL DEFAULT '',
  `REFERENCED_TABLE_NAME` varchar(64) NOT NULL DEFAULT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.ROUTINES
CREATE TEMPORARY TABLE IF NOT EXISTS `ROUTINES` (
  `SPECIFIC_NAME` varchar(64) NOT NULL DEFAULT '',
  `ROUTINE_CATALOG` varchar(512) NOT NULL DEFAULT '',
  `ROUTINE_SCHEMA` varchar(64) NOT NULL DEFAULT '',
  `ROUTINE_NAME` varchar(64) NOT NULL DEFAULT '',
  `ROUTINE_TYPE` varchar(9) NOT NULL DEFAULT '',
  `DATA_TYPE` varchar(64) NOT NULL DEFAULT '',
  `CHARACTER_MAXIMUM_LENGTH` int(21) DEFAULT NULL,
  `CHARACTER_OCTET_LENGTH` int(21) DEFAULT NULL,
  `NUMERIC_PRECISION` int(21) DEFAULT NULL,
  `NUMERIC_SCALE` int(21) DEFAULT NULL,
  `DATETIME_PRECISION` bigint(21) unsigned DEFAULT NULL,
  `CHARACTER_SET_NAME` varchar(64) DEFAULT NULL,
  `COLLATION_NAME` varchar(64) DEFAULT NULL,
  `DTD_IDENTIFIER` longtext DEFAULT NULL,
  `ROUTINE_BODY` varchar(8) NOT NULL DEFAULT '',
  `ROUTINE_DEFINITION` longtext DEFAULT NULL,
  `EXTERNAL_NAME` varchar(64) DEFAULT NULL,
  `EXTERNAL_LANGUAGE` varchar(64) DEFAULT NULL,
  `PARAMETER_STYLE` varchar(8) NOT NULL DEFAULT '',
  `IS_DETERMINISTIC` varchar(3) NOT NULL DEFAULT '',
  `SQL_DATA_ACCESS` varchar(64) NOT NULL DEFAULT '',
  `SQL_PATH` varchar(64) DEFAULT NULL,
  `SECURITY_TYPE` varchar(7) NOT NULL DEFAULT '',
  `CREATED` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `LAST_ALTERED` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `SQL_MODE` varchar(8192) NOT NULL DEFAULT '',
  `ROUTINE_COMMENT` longtext NOT NULL DEFAULT '',
  `DEFINER` varchar(189) NOT NULL DEFAULT '',
  `CHARACTER_SET_CLIENT` varchar(32) NOT NULL DEFAULT '',
  `COLLATION_CONNECTION` varchar(32) NOT NULL DEFAULT '',
  `DATABASE_COLLATION` varchar(32) NOT NULL DEFAULT ''
) ENGINE=Aria DEFAULT CHARSET=utf8 PAGE_CHECKSUM=0;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.SCHEMATA
CREATE TEMPORARY TABLE IF NOT EXISTS `SCHEMATA` (
  `CATALOG_NAME` varchar(512) NOT NULL DEFAULT '',
  `SCHEMA_NAME` varchar(64) NOT NULL DEFAULT '',
  `DEFAULT_CHARACTER_SET_NAME` varchar(32) NOT NULL DEFAULT '',
  `DEFAULT_COLLATION_NAME` varchar(32) NOT NULL DEFAULT '',
  `SQL_PATH` varchar(512) DEFAULT NULL
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.SCHEMA_PRIVILEGES
CREATE TEMPORARY TABLE IF NOT EXISTS `SCHEMA_PRIVILEGES` (
  `GRANTEE` varchar(190) NOT NULL DEFAULT '',
  `TABLE_CATALOG` varchar(512) NOT NULL DEFAULT '',
  `TABLE_SCHEMA` varchar(64) NOT NULL DEFAULT '',
  `PRIVILEGE_TYPE` varchar(64) NOT NULL DEFAULT '',
  `IS_GRANTABLE` varchar(3) NOT NULL DEFAULT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.SESSION_STATUS
CREATE TEMPORARY TABLE IF NOT EXISTS `SESSION_STATUS` (
  `VARIABLE_NAME` varchar(64) NOT NULL DEFAULT '',
  `VARIABLE_VALUE` varchar(2048) NOT NULL DEFAULT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.SESSION_VARIABLES
CREATE TEMPORARY TABLE IF NOT EXISTS `SESSION_VARIABLES` (
  `VARIABLE_NAME` varchar(64) NOT NULL DEFAULT '',
  `VARIABLE_VALUE` varchar(2048) NOT NULL DEFAULT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.SPATIAL_REF_SYS
CREATE TEMPORARY TABLE IF NOT EXISTS `SPATIAL_REF_SYS` (
  `SRID` smallint(5) NOT NULL DEFAULT 0,
  `AUTH_NAME` varchar(512) NOT NULL DEFAULT '',
  `AUTH_SRID` int(5) NOT NULL DEFAULT 0,
  `SRTEXT` varchar(2048) NOT NULL DEFAULT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.STATISTICS
CREATE TEMPORARY TABLE IF NOT EXISTS `STATISTICS` (
  `TABLE_CATALOG` varchar(512) NOT NULL DEFAULT '',
  `TABLE_SCHEMA` varchar(64) NOT NULL DEFAULT '',
  `TABLE_NAME` varchar(64) NOT NULL DEFAULT '',
  `NON_UNIQUE` bigint(1) NOT NULL DEFAULT 0,
  `INDEX_SCHEMA` varchar(64) NOT NULL DEFAULT '',
  `INDEX_NAME` varchar(64) NOT NULL DEFAULT '',
  `SEQ_IN_INDEX` bigint(2) NOT NULL DEFAULT 0,
  `COLUMN_NAME` varchar(64) NOT NULL DEFAULT '',
  `COLLATION` varchar(1) DEFAULT NULL,
  `CARDINALITY` bigint(21) DEFAULT NULL,
  `SUB_PART` bigint(3) DEFAULT NULL,
  `PACKED` varchar(10) DEFAULT NULL,
  `NULLABLE` varchar(3) NOT NULL DEFAULT '',
  `INDEX_TYPE` varchar(16) NOT NULL DEFAULT '',
  `COMMENT` varchar(16) DEFAULT NULL,
  `INDEX_COMMENT` varchar(1024) NOT NULL DEFAULT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.SYSTEM_VARIABLES
CREATE TEMPORARY TABLE IF NOT EXISTS `SYSTEM_VARIABLES` (
  `VARIABLE_NAME` varchar(64) NOT NULL DEFAULT '',
  `SESSION_VALUE` varchar(2048) DEFAULT NULL,
  `GLOBAL_VALUE` varchar(2048) DEFAULT NULL,
  `GLOBAL_VALUE_ORIGIN` varchar(64) NOT NULL DEFAULT '',
  `DEFAULT_VALUE` varchar(2048) DEFAULT NULL,
  `VARIABLE_SCOPE` varchar(64) NOT NULL DEFAULT '',
  `VARIABLE_TYPE` varchar(64) NOT NULL DEFAULT '',
  `VARIABLE_COMMENT` varchar(2048) NOT NULL DEFAULT '',
  `NUMERIC_MIN_VALUE` varchar(21) DEFAULT NULL,
  `NUMERIC_MAX_VALUE` varchar(21) DEFAULT NULL,
  `NUMERIC_BLOCK_SIZE` varchar(21) DEFAULT NULL,
  `ENUM_VALUE_LIST` longtext DEFAULT NULL,
  `READ_ONLY` varchar(3) NOT NULL DEFAULT '',
  `COMMAND_LINE_ARGUMENT` varchar(64) DEFAULT NULL
) ENGINE=Aria DEFAULT CHARSET=utf8 PAGE_CHECKSUM=0;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.TABLES
CREATE TEMPORARY TABLE IF NOT EXISTS `TABLES` (
  `TABLE_CATALOG` varchar(512) NOT NULL DEFAULT '',
  `TABLE_SCHEMA` varchar(64) NOT NULL DEFAULT '',
  `TABLE_NAME` varchar(64) NOT NULL DEFAULT '',
  `TABLE_TYPE` varchar(64) NOT NULL DEFAULT '',
  `ENGINE` varchar(64) DEFAULT NULL,
  `VERSION` bigint(21) unsigned DEFAULT NULL,
  `ROW_FORMAT` varchar(10) DEFAULT NULL,
  `TABLE_ROWS` bigint(21) unsigned DEFAULT NULL,
  `AVG_ROW_LENGTH` bigint(21) unsigned DEFAULT NULL,
  `DATA_LENGTH` bigint(21) unsigned DEFAULT NULL,
  `MAX_DATA_LENGTH` bigint(21) unsigned DEFAULT NULL,
  `INDEX_LENGTH` bigint(21) unsigned DEFAULT NULL,
  `DATA_FREE` bigint(21) unsigned DEFAULT NULL,
  `AUTO_INCREMENT` bigint(21) unsigned DEFAULT NULL,
  `CREATE_TIME` datetime DEFAULT NULL,
  `UPDATE_TIME` datetime DEFAULT NULL,
  `CHECK_TIME` datetime DEFAULT NULL,
  `TABLE_COLLATION` varchar(32) DEFAULT NULL,
  `CHECKSUM` bigint(21) unsigned DEFAULT NULL,
  `CREATE_OPTIONS` varchar(2048) DEFAULT NULL,
  `TABLE_COMMENT` varchar(2048) NOT NULL DEFAULT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.TABLESPACES
CREATE TEMPORARY TABLE IF NOT EXISTS `TABLESPACES` (
  `TABLESPACE_NAME` varchar(64) NOT NULL DEFAULT '',
  `ENGINE` varchar(64) NOT NULL DEFAULT '',
  `TABLESPACE_TYPE` varchar(64) DEFAULT NULL,
  `LOGFILE_GROUP_NAME` varchar(64) DEFAULT NULL,
  `EXTENT_SIZE` bigint(21) unsigned DEFAULT NULL,
  `AUTOEXTEND_SIZE` bigint(21) unsigned DEFAULT NULL,
  `MAXIMUM_SIZE` bigint(21) unsigned DEFAULT NULL,
  `NODEGROUP_ID` bigint(21) unsigned DEFAULT NULL,
  `TABLESPACE_COMMENT` varchar(2048) DEFAULT NULL
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.TABLE_CONSTRAINTS
CREATE TEMPORARY TABLE IF NOT EXISTS `TABLE_CONSTRAINTS` (
  `CONSTRAINT_CATALOG` varchar(512) NOT NULL DEFAULT '',
  `CONSTRAINT_SCHEMA` varchar(64) NOT NULL DEFAULT '',
  `CONSTRAINT_NAME` varchar(64) NOT NULL DEFAULT '',
  `TABLE_SCHEMA` varchar(64) NOT NULL DEFAULT '',
  `TABLE_NAME` varchar(64) NOT NULL DEFAULT '',
  `CONSTRAINT_TYPE` varchar(64) NOT NULL DEFAULT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.TABLE_PRIVILEGES
CREATE TEMPORARY TABLE IF NOT EXISTS `TABLE_PRIVILEGES` (
  `GRANTEE` varchar(190) NOT NULL DEFAULT '',
  `TABLE_CATALOG` varchar(512) NOT NULL DEFAULT '',
  `TABLE_SCHEMA` varchar(64) NOT NULL DEFAULT '',
  `TABLE_NAME` varchar(64) NOT NULL DEFAULT '',
  `PRIVILEGE_TYPE` varchar(64) NOT NULL DEFAULT '',
  `IS_GRANTABLE` varchar(3) NOT NULL DEFAULT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.TABLE_STATISTICS
CREATE TEMPORARY TABLE IF NOT EXISTS `TABLE_STATISTICS` (
  `TABLE_SCHEMA` varchar(192) NOT NULL DEFAULT '',
  `TABLE_NAME` varchar(192) NOT NULL DEFAULT '',
  `ROWS_READ` bigint(21) NOT NULL DEFAULT 0,
  `ROWS_CHANGED` bigint(21) NOT NULL DEFAULT 0,
  `ROWS_CHANGED_X_INDEXES` bigint(21) NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.TRIGGERS
CREATE TEMPORARY TABLE IF NOT EXISTS `TRIGGERS` (
  `TRIGGER_CATALOG` varchar(512) NOT NULL DEFAULT '',
  `TRIGGER_SCHEMA` varchar(64) NOT NULL DEFAULT '',
  `TRIGGER_NAME` varchar(64) NOT NULL DEFAULT '',
  `EVENT_MANIPULATION` varchar(6) NOT NULL DEFAULT '',
  `EVENT_OBJECT_CATALOG` varchar(512) NOT NULL DEFAULT '',
  `EVENT_OBJECT_SCHEMA` varchar(64) NOT NULL DEFAULT '',
  `EVENT_OBJECT_TABLE` varchar(64) NOT NULL DEFAULT '',
  `ACTION_ORDER` bigint(4) NOT NULL DEFAULT 0,
  `ACTION_CONDITION` longtext DEFAULT NULL,
  `ACTION_STATEMENT` longtext NOT NULL DEFAULT '',
  `ACTION_ORIENTATION` varchar(9) NOT NULL DEFAULT '',
  `ACTION_TIMING` varchar(6) NOT NULL DEFAULT '',
  `ACTION_REFERENCE_OLD_TABLE` varchar(64) DEFAULT NULL,
  `ACTION_REFERENCE_NEW_TABLE` varchar(64) DEFAULT NULL,
  `ACTION_REFERENCE_OLD_ROW` varchar(3) NOT NULL DEFAULT '',
  `ACTION_REFERENCE_NEW_ROW` varchar(3) NOT NULL DEFAULT '',
  `CREATED` datetime(2) DEFAULT NULL,
  `SQL_MODE` varchar(8192) NOT NULL DEFAULT '',
  `DEFINER` varchar(189) NOT NULL DEFAULT '',
  `CHARACTER_SET_CLIENT` varchar(32) NOT NULL DEFAULT '',
  `COLLATION_CONNECTION` varchar(32) NOT NULL DEFAULT '',
  `DATABASE_COLLATION` varchar(32) NOT NULL DEFAULT ''
) ENGINE=Aria DEFAULT CHARSET=utf8 PAGE_CHECKSUM=0;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.USER_PRIVILEGES
CREATE TEMPORARY TABLE IF NOT EXISTS `USER_PRIVILEGES` (
  `GRANTEE` varchar(190) NOT NULL DEFAULT '',
  `TABLE_CATALOG` varchar(512) NOT NULL DEFAULT '',
  `PRIVILEGE_TYPE` varchar(64) NOT NULL DEFAULT '',
  `IS_GRANTABLE` varchar(3) NOT NULL DEFAULT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.USER_STATISTICS
CREATE TEMPORARY TABLE IF NOT EXISTS `USER_STATISTICS` (
  `USER` varchar(128) NOT NULL DEFAULT '',
  `TOTAL_CONNECTIONS` int(11) NOT NULL DEFAULT 0,
  `CONCURRENT_CONNECTIONS` int(11) NOT NULL DEFAULT 0,
  `CONNECTED_TIME` int(11) NOT NULL DEFAULT 0,
  `BUSY_TIME` double NOT NULL DEFAULT 0,
  `CPU_TIME` double NOT NULL DEFAULT 0,
  `BYTES_RECEIVED` bigint(21) NOT NULL DEFAULT 0,
  `BYTES_SENT` bigint(21) NOT NULL DEFAULT 0,
  `BINLOG_BYTES_WRITTEN` bigint(21) NOT NULL DEFAULT 0,
  `ROWS_READ` bigint(21) NOT NULL DEFAULT 0,
  `ROWS_SENT` bigint(21) NOT NULL DEFAULT 0,
  `ROWS_DELETED` bigint(21) NOT NULL DEFAULT 0,
  `ROWS_INSERTED` bigint(21) NOT NULL DEFAULT 0,
  `ROWS_UPDATED` bigint(21) NOT NULL DEFAULT 0,
  `SELECT_COMMANDS` bigint(21) NOT NULL DEFAULT 0,
  `UPDATE_COMMANDS` bigint(21) NOT NULL DEFAULT 0,
  `OTHER_COMMANDS` bigint(21) NOT NULL DEFAULT 0,
  `COMMIT_TRANSACTIONS` bigint(21) NOT NULL DEFAULT 0,
  `ROLLBACK_TRANSACTIONS` bigint(21) NOT NULL DEFAULT 0,
  `DENIED_CONNECTIONS` bigint(21) NOT NULL DEFAULT 0,
  `LOST_CONNECTIONS` bigint(21) NOT NULL DEFAULT 0,
  `ACCESS_DENIED` bigint(21) NOT NULL DEFAULT 0,
  `EMPTY_QUERIES` bigint(21) NOT NULL DEFAULT 0,
  `TOTAL_SSL_CONNECTIONS` bigint(21) unsigned NOT NULL DEFAULT 0,
  `MAX_STATEMENT_TIME_EXCEEDED` bigint(21) NOT NULL DEFAULT 0
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.user_variables
CREATE TEMPORARY TABLE IF NOT EXISTS `user_variables` (
  `VARIABLE_NAME` varchar(64) NOT NULL DEFAULT '',
  `VARIABLE_VALUE` varchar(2048) DEFAULT NULL,
  `VARIABLE_TYPE` varchar(64) NOT NULL DEFAULT '',
  `CHARACTER_SET_NAME` varchar(32) DEFAULT NULL
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for table information_schema.VIEWS
CREATE TEMPORARY TABLE IF NOT EXISTS `VIEWS` (
  `TABLE_CATALOG` varchar(512) NOT NULL DEFAULT '',
  `TABLE_SCHEMA` varchar(64) NOT NULL DEFAULT '',
  `TABLE_NAME` varchar(64) NOT NULL DEFAULT '',
  `VIEW_DEFINITION` longtext NOT NULL DEFAULT '',
  `CHECK_OPTION` varchar(8) NOT NULL DEFAULT '',
  `IS_UPDATABLE` varchar(3) NOT NULL DEFAULT '',
  `DEFINER` varchar(189) NOT NULL DEFAULT '',
  `SECURITY_TYPE` varchar(7) NOT NULL DEFAULT '',
  `CHARACTER_SET_CLIENT` varchar(32) NOT NULL DEFAULT '',
  `COLLATION_CONNECTION` varchar(32) NOT NULL DEFAULT '',
  `ALGORITHM` varchar(10) NOT NULL DEFAULT ''
) ENGINE=Aria DEFAULT CHARSET=utf8 PAGE_CHECKSUM=0;

-- Data exporting was unselected.
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
