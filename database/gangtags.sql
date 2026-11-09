-- Current gangtags.pwn contract. IDs are explicit runtime slots 0..99.
-- Existing tables are not altered. Use the reviewed legacy migration separately.
-- No positions, owners, names or spray text are seeded.

CREATE TABLE IF NOT EXISTS `gangtags` (
  `id` int(11) NOT NULL,
  `x` float NOT NULL DEFAULT 0,
  `y` float NOT NULL DEFAULT 0,
  `z` float NOT NULL DEFAULT 0,
  `rx` float NOT NULL DEFAULT 0,
  `ry` float NOT NULL DEFAULT 0,
  `rz` float NOT NULL DEFAULT 0,
  `text` varchar(47) NOT NULL DEFAULT '/SETUP/',
  `fontid` int(11) NOT NULL DEFAULT 0,
  `color` int(11) NOT NULL DEFAULT 0,
  `gangid` int(11) NOT NULL DEFAULT -1,
  `pdbid` int(11) NOT NULL DEFAULT 0,
  `pname` varchar(24) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
