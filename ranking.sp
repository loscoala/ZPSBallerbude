/* ranking.sp
 *
 * =============================================================================
 * SourceMod KillerSpieler-[BOT] Plugin
 * Player greeting, ranking-system
 *
 * How it works:
 * ~~~~~~~~~~~~~
 *
 * This plugin counts every second and every kill while a player is connected to
 * the server. The result is a "kph" number, called "kills per hour".
 *
 * kph = (kills * 60^2) / played_seconds
 *
 * The development time is more than 1 year. So i hope it works just fine!
 *
 * Commands: !rank !rankme !top10 !topnoobs !reset
 * =============================================================================
 *
 * SQLite3 Configuration:
 * ~~~~~~~~~~~~~~~~~~~~~~
 *
 * Create a databasefile in "addons/soucemod/data/sqlite/ranking-sqlite.sq3"
 * with "sqlite3 ranking-sqlite.sq3" then execute this statement:
 *
 * -- SQLite3 INITSCRIPT by KillerSpieler 21.07.2009 --
 *
 * BEGIN TRANSACTION;
 *
 * CREATE TABLE IF NOT EXISTS ranking (
 *   id INTEGER PRIMARY KEY AUTOINCREMENT,
 *   nickname TEXT NOT NULL DEFAULT 'NONAME',
 *   steamid TEXT NOT NULL DEFAULT '',
 *   kills INTEGER NOT NULL DEFAULT 0,
 *   playtime INTEGER NOT NULL DEFAULT 0,
 *   kph INTEGER NOT NULL DEFAULT 0,
 *   savedate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
 * );
 *
 * DELETE FROM sqlite_sequence;
 * 
 * CREATE TRIGGER IF NOT EXISTS setranktime AFTER UPDATE ON ranking
 * BEGIN
 *   UPDATE ranking SET savedate = CURRENT_TIMESTAMP WHERE ROWID = NEW.ROWID;
 *   UPDATE ranking SET kph = (ranking.kills * 3600) / ranking.playtime WHERE ROWID = NEW.ROWID;
 * END;
 *
 * COMMIT;
 *
 * --------- END SCRIPT ---------------------------
 *
 * or save this statements into "initDB.sql" and
 * execute "sqlite3 ranking-sqlite3.sq3 < initDB.sql"
 *
 * as next write ".exit", then edit "addons/sourcemod/configs/databases.cfg"
 * and append into "Databases":
 *
 * "Databases"
 * {
 *      "ranking"
 *     {
 *             "driver"        "sqlite"
 *             "database"      "ranking-sqlite"
 *     }
 * }
 *
 * 14.03.2008 - 23.10.2009; KillerSpieler
 * http://steamcommunity.com/groups/ZPSBallerbude
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
 *
 */

#pragma semicolon 1
#pragma tabsize 4

#include <killerbot>

public Plugin:myinfo =
{
    name = "The Ballerbude ranking plugin",
    author = "KillerSpieler",
    description = "ranking plugin",
    version = VERSION,
    url = "http://steamcommunity.com/groups/ZPSBallerbude"
};

static InitVars(const String:range[])
{
    // Set default values
    new const String:keyword[] = "RANGE";
    new String:get_topten[] = "SELECT nickname, kph FROM ranking WHERE ranking.kills >= RANGE ORDER BY ranking.kph DESC LIMIT 10";
    new String:get_noobcount[] = "SELECT COUNT(steamid) FROM ranking WHERE ranking.kills < RANGE";
    new String:get_topnoobs[] = "SELECT nickname, kph FROM ranking WHERE ranking.kills < RANGE ORDER BY ranking.kph DESC LIMIT 10";
    new String:get_rank[] = "SELECT COUNT(kph) + 1 FROM ranking WHERE ranking.kills >= RANGE AND ranking.kph > (SELECT kph FROM ranking WHERE ranking.steamid = \"%s\")";
    new String:get_noobrank[] = "SELECT COUNT(kph) + 1 FROM ranking WHERE ranking.kills < RANGE AND ranking.kph > (SELECT kph FROM ranking WHERE ranking.steamid = \"%s\")";

    strcopy(commands[dbname], SQLSIZE_SMALL, "ranking");
    strcopy(commands[testplayer], SQLSIZE, "SELECT steamid FROM ranking WHERE steamid = \"%s\"");
    strcopy(commands[savesteamid], SQLSIZE, "INSERT INTO ranking (steamid) VALUES (\"%s\")");
    strcopy(commands[gettime], SQLSIZE, "SELECT playtime FROM ranking WHERE steamid = \"%s\"");
    strcopy(commands[savetime], SQLSIZE, "UPDATE ranking SET playtime = ranking.playtime + %d WHERE steamid = \"%s\"");
    strcopy(commands[getfrags], SQLSIZE, "SELECT kills from ranking WHERE steamid = \"%s\"");
    strcopy(commands[savefrags], SQLSIZE, "UPDATE ranking SET kills = ranking.kills + %d WHERE steamid = \"%s\"");
    strcopy(commands[savenickname], SQLSIZE, "UPDATE ranking SET nickname = \"%s\" WHERE ranking.steamid = \"%s\"");

    ReplaceString(get_topten, sizeof(get_topten), keyword, range);
    strcopy(commands[gettopten], SQLSIZE, get_topten);

    ReplaceString(get_noobcount, sizeof(get_noobcount), keyword, range);
    strcopy(commands[getnoobcount], SQLSIZE, get_noobcount);

    strcopy(commands[getcount], SQLSIZE, "SELECT seq FROM sqlite_sequence WHERE sqlite_sequence.name = \"ranking\"");
    strcopy(commands[resetrank], SQLSIZE, "DELETE FROM ranking WHERE ranking.steamid = \"%s\"");

    ReplaceString(get_topnoobs, sizeof(get_topnoobs), keyword, range);
    strcopy(commands[gettopnoobs], SQLSIZE, get_topnoobs);

    ReplaceString(get_rank, sizeof(get_rank), keyword, range);
    strcopy(commands[getrank], SQLSIZE, get_rank);

    ReplaceString(get_noobrank, sizeof(get_noobrank), keyword, range);
    strcopy(commands[getnoobrank], SQLSIZE, get_noobrank);
    strcopy(commands[getkph], SQLSIZE, "SELECT kph FROM ranking WHERE steamid = \"%s\"");
    
    // Read name, steamid
    GetClientNames();
}

public OnPluginStart()
{
    LoadTranslations("common.phrases");

    RegConsoleCmd("sm_rankme", Command_RankMe, "Show the rank in private");
    RegConsoleCmd("sm_rank", Command_Rank, "Show the rank in public");
    RegConsoleCmd("sm_top10", Command_TopTen, "Show the top10 list");
    RegConsoleCmd("sm_topnoobs", Command_TopNoobs, "Show the top10 of the noobs");
    RegConsoleCmd("sm_reset", Command_Reset, "Delete all entrys of one player");
#if GAME == ZPS
    HookEvent("game_round_restart", Event_RoundEnd, EventHookMode_Pre);
#else
#error "Your game is currently not supported!"
#endif
    HookEvent("player_connect", Event_PlayerConnect, EventHookMode_Pre);
    HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);

    InitVars(RANKLIMIT_STR);
}

// --- BUILTIN FUNCTIONS ---

public OnMapStart()
{
    // Wird einmalig aufgerufen, wenn Map geladen wurde

    GetClientNames();
}

public OnPluginEnd()
{
    // Plugin wurde entladen

    SaveAllStats();
}

public OnClientPostAdminCheck(client)
{
    // Called after OnClientAuthorized()
    // Get the "isRanked" information and save the playtime

    if (!IsFakeClient(client) && (strlen(nickname[client]) > 1))
    {
        new Handle:db = db_Connect();
        player[client][rank] = Client_Ranked(db, client);

        if (player[client][rank])
            Client_SaveNickname(db, client);

        player[client][newplaytime] = GetTime();
        CloseHandle(db);

        PrintToChatAll("\x04[BOT]\x01 - \x04%s\x01 (%s) connecting", nickname[client], steamid[client]);
    }
}

public OnClientAuthorized(client, const String:id[])
{
    // Called before OnClientPostAdminCheck()
    // Save steamid and nickname

    if (!IsFakeClient(client))
    {
        strcopy(steamid[client], LINE_LENGTH, id);
        GetClientName(client, nickname[client], MAX_NAME_LENGTH);
    }
}

public OnClientDisconnect(client)
{
    // Called after Event_PlayerDisconnect()

    if (!IsFakeClient(client))
    {
        if (strlen(nickname[client]) > 1)
            PrintToChatAll("\x04[BOT]\x01 - \x04%s\x01 (%s) left the game", nickname[client], steamid[client]);

        strcopy(nickname[client], MAX_NAME_LENGTH, "");
        strcopy(steamid[client], LINE_LENGTH, "");
        player[client][newkills] = 0;
        player[client][oldkills] = 0;
        player[client][oldplaytime] = 0;
        player[client][newplaytime] = 0;
    }
}

// --- ACTIONS ---

#include "ranking/commandRank.sp"
#include "ranking/commandRankMe.sp"
#include "ranking/commandReset.sp"
#include "ranking/commandTopNoobs.sp"
#include "ranking/commandTopTen.sp"

// --- EVENTS ---

public Action:Event_PlayerConnect(Handle:event, const String:name[], bool:dontBroatcast)
{
    // To avoid the "Player connect" text

    return Plugin_Handled;
}

public Action:Event_PlayerDisconnect(Handle:event, const String:name[], bool:dontBroatcast)
{
    // Save kills and playtime into the database

    new const client = GetClientOfUserId(GetEventInt(event, "userid"));

    if (player[client][rank])
        SaveClient(client);

    return Plugin_Handled;
}

public Action:Event_RoundEnd(Handle:event, const String:name[], bool:dontBroatcast)
{
    // Save all stats

    SaveAllStats();

    return Plugin_Continue;
}

