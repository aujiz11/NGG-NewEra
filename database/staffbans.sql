CREATE TABLE IF NOT EXISTS `staffbans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `details` varchar(128) NOT NULL,
  `issuer` int(11) NOT NULL,
  `playerid` int(11) NOT NULL,
  `expiredate` int(11) NOT NULL,
  `created` int(11) NOT NULL,
  `status` tinyint(4) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `player_status` (`playerid`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
