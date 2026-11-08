-- Reconstructed from gamemodes/includes/furniture.pwn::OnLoadFurnitureList.
-- Import into the database used by MainPipeline. Existing tables are not replaced.
-- This is a new source-derived schema, not a recovered NGG database dump.
-- fc_szName[32] allows 31 Pawn string bytes plus the terminator; check multibyte names.
-- Keep at most MAX_CATALOG (1000) rows; the current loader has no row-count guard.
-- No catalog/pricing/VIP data is invented here. Populate reviewed entries separately.

CREATE TABLE IF NOT EXISTS `furniturecatalog` (
  `modelid` int(11) NOT NULL,
  `type` int(11) NOT NULL DEFAULT 0,
  `name` varchar(31) NOT NULL,
  `price` int(11) NOT NULL DEFAULT 0,
  `vip` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`modelid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
