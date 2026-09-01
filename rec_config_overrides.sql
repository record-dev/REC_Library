-- Config values the REC_* admin panels changed at runtime.
-- config/sv_config.lua stays the shipped default and a row here wins over it, so a
-- setting edited from a panel survives a restart. Only the paths a resource declares
-- through WebSettingConfigBuilder can be written, and the resource column keys them
-- the same way rec_web_audit does: one table for every panel.
CREATE TABLE IF NOT EXISTS `rec_config_overrides` (
  `resource` varchar(64) NOT NULL,
  `path` varchar(128) NOT NULL,
  `value` longtext NOT NULL,
  `updatedBy` varchar(64) DEFAULT NULL,
  `updatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`resource`,`path`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
