/* shop.inc
 *
 * ShopPlugin
 *
 * 02.06.2011; KillerSpieler
 * http://steamcommunity.com/groups/ZPSBallerbude
 * -----------------------------------------------
 *
 * BEGIN TRANSACTION;
 *
 * CREATE TABLE players (
 *   id INTEGER PRIMARY KEY AUTOINCREMENT,
 *   steamid TEXT NOT NULL DEFAULT '',
 *   money INTEGER NOT NULL DEFAULT 0,
 *   savedate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
 * );
 *
 * CREATE TRIGGER players_t AFTER UPDATE ON players
 * BEGIN
 *   UPDATE players SET savedate = CURRENT_TIMESTAMP WHERE ROWID = NEW.ROWID;
 * END;
 *
 * CREATE TABLE weapons (
 *   id INTEGER PRIMARY KEY AUTOINCREMENT,
 *   weapon TEXT
 * );
 * 
 * CREATE TABLE player_weapons (
 *    playerid INTEGER REFERENCES players,
 *   weaponid INTEGER REFERENCES weapons,
 * );
 *
 * COMMIT;
 *
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#pragma semicolon 1
#pragma tabsize 4

#if defined _shop_included
#endinput
#endif
#define _shop_included

#include <sourcemod>

#if !defined SQLSIZE
#define SQLSIZE 255
#endif

#define LOCK(%1) SQL_LockDatabase(%1)
#define UNLOCK(%1) SQL_UnlockDatabase(%1)

#define Client_FastQuery(%1,%2) \
    SQL_LockDatabase(%1); \
    if (!SQL_FastQuery(%1, %2)) \
        LogError("[SHOP] Unable to execute Client_FastQuery()"); \
    SQL_UnlockDatabase(%1)

// Standard Database API

stock Handle:db_Connect()
{
    // connect to database

    decl String:error[SQLSIZE];
    new Handle:db = INVALID_HANDLE;

    if (SQL_CheckConfig("shop"))
        db = SQL_Connect("shop", true, error, SQLSIZE);

    if (db == INVALID_HANDLE)
        LogError("[SHOP] Error on db_Connect: %s", error);

    return db;
}

stock db_Query(Handle:db, const String:query[])
{
    new Handle:hQuery = INVALID_HANDLE;
    new db_integer = -1;

    LOCK(db);

    if ((hQuery = SQL_Query(db, query)) == INVALID_HANDLE)
    {
        LogError("[SHOP] Unable to execute db_Query()");
        UNLOCK(db);
        return db_integer;
    }

    UNLOCK(db);

    if (SQL_FetchRow(hQuery))
        db_integer = SQL_FetchInt(hQuery, 0);

    CloseHandle(hQuery);
    return db_integer;
}

// Plugin API

stock AddMoney(Handle:db, clientID, playerMoney)
{
    new const String:command[] = "UPDATE players SET money = money + %d WHERE id = %d";
    decl String:query[SQLSIZE];
    
    Format(query, SQLSIZE, command, clientID, playerMoney);
    Client_FastQuery(db, query);
}

stock RemoveMoney(Handle:db, clientID, playerMoney)
{
    new const String:command[] = "UPDATE players SET money = money - %d WHERE id = %d";
    decl String:query[SQLSIZE];
    
    Format(query, SQLSIZE, command, clientID, playerMoney);
    Client_FastQuery(db, query);
}

// Gibt den Kontostand des Spielers an
stock GetMoney(Handle:db, clientID)
{
    new const String:command[] = "SELECT money FROM players WHERE id = %d";
    decl String:query[SQLSIZE];
    
    Format(query, SQLSIZE, command, clientID);
    return db_Query(db, query);
}

stock GetWeaponID(Handle:db, const String:name[])
{
    new const String:command[] = "SELECT id FROM weapons WHERE weapon = '%s'";
    decl String:query[SQLSIZE];
    
    Format(query, SQLSIZE, command, name);
    return db_Query(db, query);
}

stock AddWeapon(Handle:db, clientID, weaponID)
{
    new const String:command[] = "INSERT INTO player_weapons (playerid, weaponid) VALUES (%d, %d)";
    decl String:query[SQLSIZE];
    
    Format(query, SQLSIZE, command, clientID, weaponID);
    Client_FastQuery(db, query);
}

stock GetClientFromDB(Handle:db, const String:steamid[])
{
    new const String:command[] = "SELECT id FROM players WHERE steamid = '%s'";
    decl String:query[SQLSIZE];
    
    Format(query, SQLSIZE, command, steamid);
    return db_Query(db, query);
}

stock AddPlayer(Handle:db, const String:steamID[])
{
    new const String:command[] = "INSERT INTO players (steamid) VALUES ('%s')";
    decl String:query[SQLSIZE];
    
    Format(query, SQLSIZE, command, steamID);
    Client_FastQuery(db, query);
}

stock Handle:GetPlayerWeapons(Handle:db, clientID)
{
    new const String:command[] = "SELECT weapons.weapon FROM weapons JOIN player_weapons ON player_weapons.playerid = %d AND weapons.id = player_weapons.weaponid ORDER BY weapons.weapon ASC";
    decl String:query[SQLSIZE];
    
    Format(query, SQLSIZE, command, clientID);
    
    new Handle:hQuery = INVALID_HANDLE;

    LOCK(db);

    if ((hQuery = SQL_Query(db, query)) == INVALID_HANDLE)
    {
        LogError("[SHOP] Unable to execute GetPlayerWeapons()");
    }

    UNLOCK(db);
    
    return hQuery;
}
