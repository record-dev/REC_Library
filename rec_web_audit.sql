-- Every write a REC_* admin panel let through, and every write it refused.
-- One table for all of them, keyed by resource the same way rec_config_overrides is:
-- a panel that gains an audit page reads its own rows out of here rather than
-- growing a table of its own.
CREATE TABLE IF NOT EXISTS `rec_web_audit` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `resource` varchar(64) NOT NULL,
  `action` varchar(64) NOT NULL,
  `scope` varchar(64) DEFAULT NULL,
  -- the token label for a browser request, "in-game:<grant>" for the NUI
  `actor` varchar(64) NOT NULL,
  -- the player name in game, the calling address over the browser route
  `actorIdentifier` varchar(64) DEFAULT NULL,
  `allowed` tinyint(1) NOT NULL DEFAULT 1,
  `detail` varchar(255) DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `resource_createdAt` (`resource`,`createdAt`),
  KEY `action` (`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
