Any time you make a change to the schema files, remember to increment the database schema version. Generally increment the minor number, major should be reserved for significant changes to the schema. Both values go up to 255.

The latest database version is 2.0; The query to update the schema revision table is:

```sql
INSERT INTO `schema_revision` (`major`, `minor`) VALUES (2, 5);
or
```
```sql
INSERT INTO `SS13_schema_revision` (`major`, `minor`) VALUES (2, 5);
```
In any query remember to add a prefix to the table names if you use one.

----------------------------------------------------
Version 2.5, 24 February 2025, by TiviPlus
Added discord_links table for discord-ckey verification
```sql
DROP TABLE IF EXISTS `discord_links`;
CREATE TABLE `discord_links` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`ckey` VARCHAR(32) NOT NULL,
	`discord_id` BIGINT(20) DEFAULT NULL,
	`timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`one_time_token` VARCHAR(100) NOT NULL,
	`valid` BOOLEAN NOT NULL DEFAULT FALSE,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB;
```

----------------------------------------------------
Version 2.3, 04 February 2025, by TiviPlus
Fixed admin rank table flags being capped at 16 in the DB instead of 24 (byond max)
Fixed staminaloss in dead table being unsigned

```sql
ALTER TABLE `admin_ranks`
	MODIFY COLUMN `flags` mediumint(5) unsigned NOT NULL,
	MODIFY COLUMN `exclude_flags` mediumint(5) unsigned NOT NULL,
	MODIFY COLUMN `can_edit_flags` mediumint(5) unsigned NOT NULL;

ALTER TABLE `death`
	MODIFY COLUMN `staminaloss` smallint(5) signed NOT NULL;
```
----------------------------------------------------
Version 2.2, 04 April 2024, by TiviPlus
Added `tutorial_completions` to mark what ckeys have completed contextual tutorials.

```sql
CREATE TABLE `tutorial_completions` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `ckey` VARCHAR(32) NOT NULL,
  `tutorial_key` VARCHAR(64) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `ckey_tutorial_unique` (`ckey`, `tutorial_key`));
```
----------------------------------------------------

Version 2.1, 2 February 2021, by TiviPlus - adds playtime tracking to notes
Modified table `messages`, adding column `playtime` to show the user's playtime when the note was created
```sql
ALTER TABLE `messages` ADD `playtime` INT(11) NULL DEFAULT(NULL) AFTER `severity`
```
----------------------------------------------------

Version 2.0 13 November 2020, by TiviPlus - Fixed various stickyban ban queries and update with /tg/station style datumized poll handling:

Updates and improvements to poll handling.
Added the `deleted` column to tables 'poll_option', 'poll_textreply' and 'poll_vote' and the columns `created_datetime`, `subtitle`, `allow_revoting` and `deleted` to 'poll_question'.
Changes table 'poll_question' column `createdby_ckey` to be NOT NULL and index `idx_pquest_time_admin` to be `idx_pquest_time_deleted_id` and 'poll_textreply' column `adminrank` to have no default.
Added procedure `set_poll_deleted` that's called when deleting a poll to set deleted to true on each poll table where rows matching a poll_id argument.

Created missing stickyban tables `stickyban_matched_cid` and `stickyban_matched_ip`, added columm `last_matched` to `stickyban_matched_ckey` and added column `deleted_ckey` to `messages` . These missing was causing queries to fail.

```sql
ALTER TABLE `stickyban_matched_ckey`
	ADD COLUMN `last_matched` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER `first_matched`;

CREATE TABLE `stickyban_matched_ip` (
	`stickyban` VARCHAR(32) NOT NULL,
	`matched_ip` INT UNSIGNED NOT NULL,
	`first_matched` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`last_matched` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`stickyban`, `matched_ip`)
) ENGINE=InnoDB;

CREATE TABLE `stickyban_matched_cid` (
	`stickyban` VARCHAR(32) NOT NULL,
	`matched_cid` VARCHAR(32) NOT NULL,
	`first_matched` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`last_matched` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`stickyban`, `matched_cid`)
) ENGINE=InnoDB;

ALTER TABLE `messages`
	ADD COLUMN `deleted_ckey` VARCHAR(32) NULL DEFAULT NULL AFTER `deleted`;

ALTER TABLE `poll_option`
	ADD COLUMN `deleted` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `default_percentage_calc`;

ALTER TABLE `poll_question`
	CHANGE COLUMN `createdby_ckey` `createdby_ckey` VARCHAR(32) NOT NULL AFTER `multiplechoiceoptions`,
	ADD COLUMN `created_datetime` datetime NOT NULL AFTER `polltype`,
	ADD COLUMN `subtitle` VARCHAR(255) NULL DEFAULT NULL AFTER `question`,
	ADD COLUMN `allow_revoting` TINYINT(1) UNSIGNED NOT NULL AFTER `dontshow`,
	ADD COLUMN `deleted` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `allow_revoting`,
	DROP INDEX `idx_pquest_time_admin`,
	ADD INDEX `idx_pquest_time_deleted_id` (`starttime`, `endtime`, `deleted`, `id`);

ALTER TABLE `poll_textreply`
	CHANGE COLUMN `adminrank` `adminrank` varchar(32) NOT NULL AFTER `replytext`,
	ADD COLUMN `deleted` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `adminrank`;

ALTER TABLE `poll_vote`
	ADD COLUMN `deleted` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `rating`;

DELIMITER $$
CREATE PROCEDURE `set_poll_deleted`(
	IN `poll_id` INT
)
SQL SECURITY INVOKER
BEGIN
UPDATE `poll_question` SET deleted = 1 WHERE id = poll_id;
UPDATE `poll_option` SET deleted = 1 WHERE pollid = poll_id;
UPDATE `poll_vote` SET deleted = 1 WHERE pollid = poll_id;
UPDATE `poll_textreply` SET deleted = 1 WHERE pollid = poll_id;
END
$$
DELIMITER ;
```
----------------------------------------------------

Version 1.0, 28 February 2018, by LaKiller8 - initial release, inspired by /tg/station schema

-----------------------------------------------------
