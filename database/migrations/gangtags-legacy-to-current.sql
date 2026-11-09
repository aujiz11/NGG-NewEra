-- Offline, one-time conversion of the legacy gangtags definition in ngrp.sql /
-- samp_main.sql. Back up first. Do not run while a server or another writer uses it.
-- Keeps every legacy column and row, including IDs outside the active 0..99 range.
-- Never infer gangid from family: these are different identity namespaces.
-- Requires CREATE ROUTINE, CREATE, ALTER, INSERT, SELECT, UPDATE and RENAME rights.
DELIMITER //
CREATE PROCEDURE ngg_migrate_gangtags_legacy()
BEGIN
  DECLARE n INT DEFAULT 0;
  SELECT COUNT(*) INTO n FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'gangtags'
      AND column_name IN ('id','posx','posy','posz','posrx','posry','posrz',
                          'objectid','vw','interior','family','used','time');
  IF n <> 13 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Expected legacy gangtags columns; inspect schema first';
  END IF;
  SELECT COUNT(*) INTO n FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = 'gangtags'
      AND column_name IN ('x','y','z','rx','ry','rz','text','fontid','color','gangid','pdbid','pname');
  IF n <> 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Current or mixed gangtags schema already exists; migration refused';
  END IF;
  SELECT COUNT(*) INTO n FROM information_schema.tables
    WHERE table_schema = DATABASE()
      AND table_name IN ('gangtags_migration_stage','gangtags_legacy_backup');
  IF n <> 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Migration stage/backup exists; inspect before retrying';
  END IF;
  SELECT COUNT(*) INTO n FROM information_schema.key_column_usage
    WHERE referenced_table_schema = DATABASE() AND referenced_table_name = 'gangtags';
  IF n <> 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Incoming foreign keys require a separate reviewed migration';
  END IF;
  SELECT COUNT(*) INTO n FROM information_schema.triggers
    WHERE event_object_schema = DATABASE() AND event_object_table = 'gangtags';
  IF n <> 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Gangtags triggers require a separate reviewed migration';
  END IF;

  CREATE TABLE gangtags_migration_stage LIKE gangtags;
  ALTER TABLE gangtags_migration_stage MODIFY COLUMN id INT(11) NOT NULL;
  INSERT INTO gangtags_migration_stage SELECT * FROM gangtags;
  ALTER TABLE gangtags_migration_stage
    ADD COLUMN x FLOAT NOT NULL DEFAULT 0,
    ADD COLUMN y FLOAT NOT NULL DEFAULT 0,
    ADD COLUMN z FLOAT NOT NULL DEFAULT 0,
    ADD COLUMN rx FLOAT NOT NULL DEFAULT 0,
    ADD COLUMN ry FLOAT NOT NULL DEFAULT 0,
    ADD COLUMN rz FLOAT NOT NULL DEFAULT 0,
    ADD COLUMN text VARCHAR(47) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '/SETUP/',
    ADD COLUMN fontid INT(11) NOT NULL DEFAULT 0,
    ADD COLUMN color INT(11) NOT NULL DEFAULT 0,
    ADD COLUMN gangid INT(11) NOT NULL DEFAULT -1,
    ADD COLUMN pdbid INT(11) NOT NULL DEFAULT 0,
    ADD COLUMN pname VARCHAR(24) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '';
  UPDATE gangtags_migration_stage SET x=posx, y=posy, z=posz, rx=posrx, ry=posry, rz=posrz;
  RENAME TABLE gangtags TO gangtags_legacy_backup, gangtags_migration_stage TO gangtags;
END//
CALL ngg_migrate_gangtags_legacy()//
DROP PROCEDURE ngg_migrate_gangtags_legacy//
DELIMITER ;
-- Review retained IDs that this version intentionally does not load:
SELECT id FROM gangtags WHERE id < 0 OR id >= 100 ORDER BY id;
