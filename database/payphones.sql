-- Reconstructed from gamemodes/includes/core/payphones.pwn.
-- Import into the database used by MainPipeline. Existing tables are not replaced.
-- Persistent IDs 1..100 correspond to runtime slots 0..99 (MAX_PAYPHONES = 100).
-- /createphone UPDATEs an existing slot; /destroyphone clears it instead of deleting.
-- Do not delete or renumber slot rows. No real phone locations/numbers are seeded.
-- Loader, bounds and scoped-write repairs are documented in
-- .agents/engineering/integrity-fixes-2026-11-09.md. Client acceptance remains separate.

CREATE TABLE IF NOT EXISTS `payphones` (
  `id` int(11) NOT NULL,
  `number` int(11) NOT NULL DEFAULT -1,
  `posx` float NOT NULL DEFAULT 0,
  `posy` float NOT NULL DEFAULT 0,
  `posz` float NOT NULL DEFAULT 0,
  `rotz` float NOT NULL DEFAULT 0,
  `vw` int(11) NOT NULL DEFAULT 0,
  `int` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add only missing inactive slots. Re-importing preserves configured phones.
-- Signed number storage is required because the inactive sentinel is -1.
INSERT INTO `payphones` (`id`)
SELECT 1 + units.n + 10 * tens.n
FROM (
  SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
  UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
  UNION ALL SELECT 8 UNION ALL SELECT 9
) AS units
CROSS JOIN (
  SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
  UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
  UNION ALL SELECT 8 UNION ALL SELECT 9
) AS tens
LEFT JOIN `payphones` AS existing ON existing.`id` = 1 + units.n + 10 * tens.n
WHERE existing.`id` IS NULL
ORDER BY 1;
