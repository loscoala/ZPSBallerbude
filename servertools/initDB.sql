-- * * * * * * * * * * * * * * * * * * * * * * * * * *
-- * (c) 2009 KillerSpieler                          *
-- * http://steamcommunity.com/groups/ZPSBallerbude  *
-- * License: GPLv3+                                 *
-- * * * * * * * * * * * * * * * * * * * * * * * * * *

BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS ranking (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nickname TEXT NOT NULL DEFAULT 'NONAME',
  steamid TEXT NOT NULL DEFAULT '',
  kills INTEGER NOT NULL DEFAULT 0,
  playtime INTEGER NOT NULL DEFAULT 0,
  kph INTEGER NOT NULL DEFAULT 0,
  savedate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

/*
 * CREATE TABLE IF NOT EXISTS sounds (
 *   id INTEGER PRIMARY KEY AUTOINCREMENT,
 *   shortname TEXT NOT NULL DEFAULT 'NONAME',
 *   path TEXT NOT NULL DEFAULT 'sounds/default.wav',
 *   savedate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
 * );
 */

DELETE FROM sqlite_sequence;

CREATE TRIGGER IF NOT EXISTS setranktime AFTER UPDATE ON ranking
BEGIN
  UPDATE ranking SET savedate = CURRENT_TIMESTAMP WHERE ROWID = NEW.ROWID;
  UPDATE ranking SET kph = (ranking.kills * 3600) / ranking.playtime WHERE ROWID = NEW.ROWID;
END;

CREATE TRIGGER IF NOT EXISTS administrate_sounds AFTER UPDATE ON sounds
BEGIN
  UPDATE sounds SET savedate = CURRENT_TIMESTAMP WHERE ROWID = NEW.ROWID;
END;

COMMIT;

