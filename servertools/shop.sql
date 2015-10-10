-- * * * * * * * * * * * * * * * * * * * * * * * * * *
-- * (c) 2009 KillerSpieler                          *
-- * http://steamcommunity.com/groups/ZPSBallerbude  *
-- * License: GPLv3+                                 *
-- * * * * * * * * * * * * * * * * * * * * * * * * * *
BEGIN TRANSACTION;

CREATE TABLE players (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    steamid TEXT NOT NULL DEFAULT '',
    money INTEGER NOT NULL DEFAULT 0,
    savedate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER players_t AFTER UPDATE ON players
BEGIN
    UPDATE players SET savedate = CURRENT_TIMESTAMP WHERE ROWID = NEW.ROWID;
END;

CREATE TABLE weapons (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    weapon TEXT
);

CREATE TABLE player_weapons (
    playerid INTEGER REFERENCES players,
    weaponid INTEGER REFERENCES weapons
);

INSERT INTO weapons (weapon) VALUES ('weapon_870');
INSERT INTO weapons (weapon) VALUES ('weapon_ak47');
INSERT INTO weapons (weapon) VALUES ('weapon_axe');
INSERT INTO weapons (weapon) VALUES ('weapon_barricade');
INSERT INTO weapons (weapon) VALUES ('weapon_chair');
INSERT INTO weapons (weapon) VALUES ('weapon_crowbar');
INSERT INTO weapons (weapon) VALUES ('weapon_frag');
INSERT INTO weapons (weapon) VALUES ('weapon_fryingpan');
INSERT INTO weapons (weapon) VALUES ('weapon_glock');
INSERT INTO weapons (weapon) VALUES ('weapon_glock18c');
INSERT INTO weapons (weapon) VALUES ('weapon_golf');
INSERT INTO weapons (weapon) VALUES ('weapon_hammer');
INSERT INTO weapons (weapon) VALUES ('weapon_ied');
INSERT INTO weapons (weapon) VALUES ('weapon_keyboard');
INSERT INTO weapons (weapon) VALUES ('weapon_m4');
INSERT INTO weapons (weapon) VALUES ('weapon_machete');
INSERT INTO weapons (weapon) VALUES ('weapon_mp5');
INSERT INTO weapons (weapon) VALUES ('weapon_pipe');
INSERT INTO weapons (weapon) VALUES ('weapon_plank');
INSERT INTO weapons (weapon) VALUES ('weapon_pot');
INSERT INTO weapons (weapon) VALUES ('weapon_ppk');
INSERT INTO weapons (weapon) VALUES ('weapon_revolver');
INSERT INTO weapons (weapon) VALUES ('weapon_shovel');
INSERT INTO weapons (weapon) VALUES ('weapon_sledgehammer');
INSERT INTO weapons (weapon) VALUES ('weapon_spanner');
INSERT INTO weapons (weapon) VALUES ('weapon_supershorty');
INSERT INTO weapons (weapon) VALUES ('weapon_tireiron');
INSERT INTO weapons (weapon) VALUES ('weapon_usp');
INSERT INTO weapons (weapon) VALUES ('weapon_winchester');
INSERT INTO weapons (weapon) VALUES ('item_ammo_357');
INSERT INTO weapons (weapon) VALUES ('item_ammo_pistol');
INSERT INTO weapons (weapon) VALUES ('item_ammo_smg1');
INSERT INTO weapons (weapon) VALUES ('item_box_buckshot');
INSERT INTO weapons (weapon) VALUES ('item_battery');
INSERT INTO weapons (weapon) VALUES ('item_healthkit');
INSERT INTO weapons (weapon) VALUES ('item_healthvial');

COMMIT;
