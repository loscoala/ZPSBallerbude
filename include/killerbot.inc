/* killerbot.inc - header
 * 
 * 02.06.2011; KillerSpieler
 * http://steamcommunity.com/groups/ZPSBallerbude
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
 *
 */

#pragma semicolon 1
#pragma tabsize 4

#if defined _killerbot_included
#endinput
#endif
#define _killerbot_included

#include <sourcemod>

#define VERSION "5.1.0"
#define BBTEAM "KillerSpieler, Walki"

// ------ server configuration -----

#define SLOTS 24

// Currently supported games:
#define ZPS 1

// Please EDIT
#define GAME ZPS

// ----- END server configuration -----

// Some important constants; do not edit
#define LINE_LENGTH 64
#define ARGLEN 32
#define QUERY 255
#define BIGQUERY 512
#define IP_LEN 16 // "255.255.255.255" = 15 + 1 stopbit
#define SQLSIZE 256
#define SQLSIZE_SMALL 10

// if you have less KILLS than RANKLIMIT -> You are a noob
#define RANKLIMIT 500
#define RANKLIMIT_STR "500"

// Preprocessor functions
#define LOCK(%1) SQL_LockDatabase(%1)
#define UNLOCK(%1) SQL_UnlockDatabase(%1)

#define FORLOOP(%1) \
    for (new i = 1; i <= %1; i++)

#define Client_FastQuery(%1,%2) \
    SQL_LockDatabase(%1); \
    if (!SQL_FastQuery(%1, %2)) \
        LogError("[BOT] Unable to execute Client_FastQuery()"); \
    SQL_UnlockDatabase(%1)

// You need a boolean destination to save the return value
// if you are using this function.
// first argument: Handle:db, second: String:command,
// third: String: name of the destination variable
#define Client_FastQueryBool(%1,%2,%3) \
    SQL_LockDatabase(%1); \
    %3 = SQL_FastQuery(%1, %2); \
    if (!%3) \
        LogError("[BOT] Unable to execute Client_FastQueryBool()"); \
    SQL_UnlockDatabase(%1)

#include <utils>

enum SQL
{
    String:dbname[SQLSIZE_SMALL],
    String:testplayer[SQLSIZE],
    String:savesteamid[SQLSIZE],
    String:gettime[SQLSIZE],
    String:savetime[SQLSIZE],
    String:getfrags[SQLSIZE],
    String:savefrags[SQLSIZE],
    String:savenickname[SQLSIZE],
    String:gettopten[SQLSIZE],
    String:getnoobcount[SQLSIZE],
    String:getcount[SQLSIZE],
    String:resetrank[SQLSIZE],
    String:gettopnoobs[SQLSIZE],
    String:getrank[SQLSIZE],
    String:getnoobrank[SQLSIZE],
    String:getkph[SQLSIZE]
};

enum USERS
{
    oldplaytime,
    newplaytime,
    oldkills,
    newkills,
    bool:rank
};

enum UserTeam
{
#if GAME == ZPS
    SPECTATOR = 1,
    SURVIVORS = 2,
    UNDEAD = 3,
    NO_TEAM = 4
#else
#error "Your game is currently not supported!"
#endif
};

stock String:nickname[SLOTS+1][MAX_NAME_LENGTH];
stock String:steamid[SLOTS+1][LINE_LENGTH];
stock commands[SQL];
stock player[SLOTS+1][USERS];

// ---------------------------------- FUNCTIONS ---------------------------

stock Handle:db_Connect()
{
    // connect to database

    decl String:error[QUERY];
    new Handle:db = INVALID_HANDLE;

    if (SQL_CheckConfig(commands[dbname]))
        db = SQL_Connect(commands[dbname], true, error, QUERY);

    if (db == INVALID_HANDLE)
        LogError("[BOT] Error on db_Connect: %s", error);

    return db;
}

/* This function is now a preprocessor macro.
 *
 * stock Client_FastQuery(Handle:db, const String:command[])
 * {
 *     // Fast execution of a command
 * 
 *     LOCK(db);
 *
 *     if (!SQL_FastQuery(db, command))
 *         LogError("[BOT] Unable to execute Client_FastQuery()");
 *
 *     UNLOCK(db);
 * }
 */

/* This function is now a preprocessor macro.
 * New parameters: bool:Client_FastQueryBool(Handle:db, const String:command[], String:destinationVariable)
 * return: Nothing
 *
 * How to use:
 * ~~~~~~~~~~~
 * new Handle:db = db_Connect();
 * new bool:tmp;
 * Client_FastQueryBool(db, "SELECT ... etc.", tmp);
 * if (!tmp)
 *     // ExecutionError
 * CloseHandle(db);
 * 
 * stock bool:Client_FastQueryBool(Handle:db, const String:command[])
 * {
 *     // Fast execution of a command, return BOOL
 *
 *     LOCK(db);
 *
 *     if (!SQL_FastQuery(db, command))
 *     {
 *         LogError("[BOT] Unable to execute Client_FastQueryBool()");
 *         UNLOCK(db);
 *         return false;
 *     }
 *
 *     UNLOCK(db);
 *     return true;
 * }
 */

stock SaveClient(const any:client)
{
    new Handle:db = db_Connect();
    new playedtime = GetTime() - player[client][newplaytime];
    new kills = player[client][newkills];
    new difference = kills - player[client][oldkills];

    if (difference != 0)
        Client_SaveInt(db, steamid[client], commands[savefrags], difference);
    else
    {
        new new_kills = GetClientFrags(client) - kills;
        Client_SaveInt(db, steamid[client], commands[savefrags], new_kills);   
    }

    Client_SaveInt(db, steamid[client], commands[savetime], playedtime);
    Client_SaveNickname(db, client);
    player[client][rank] = false;
    CloseHandle(db);
}

stock SaveAllStats()
{
    new Handle:db = db_Connect();
    new playedtime;
    new difference;
    new bool:ranked;

    FORLOOP(SLOTS)
    {
        ranked = player[i][rank] && !IsFakeClient(i);

        if (ranked)
        {
            // Calculate the difference
            player[i][oldkills] = player[i][newkills];
            player[i][newkills] = GetClientFrags(i);

            player[i][oldplaytime] = player[i][newplaytime];
            player[i][newplaytime] = GetTime();

            playedtime = player[i][newplaytime] - player[i][oldplaytime];
            difference = player[i][newkills] - player[i][oldkills];

            // Save data
            Client_SaveInt(db, steamid[i], commands[savefrags], difference);
            Client_SaveInt(db, steamid[i], commands[savetime], playedtime);
        }
    }

    CloseHandle(db);
}

// number: The integer which you want to save
stock Client_SaveInt(Handle:db, const String:id[], const String:command[], const number)
{
    decl String:query[QUERY];
    Format(query, QUERY, command, number, id);
    new bool:fastQuery;
    Client_FastQueryBool(db, query, fastQuery);

    if (!fastQuery)
        LogError("[BOT] Unable to save integer in Client_SaveInt()");
}

stock Client_GetIntId(Handle:db, const String:command[], const String:id[], row=0)
{
    // Function with steamid

    decl String:query[QUERY];
    new Handle:hQuery;
    new db_integer = -1;

    Format(query, QUERY, command, id);
    LOCK(db);

    if ((hQuery = SQL_Query(db, query)) == INVALID_HANDLE)
    {
        LogError("[BOT] Unable to execute GetIntId()");
        UNLOCK(db);
        return db_integer;
    }

    UNLOCK(db);

    if (SQL_FetchRow(hQuery))
        db_integer = SQL_FetchInt(hQuery, row);
    else
        db_integer = 0;

    CloseHandle(hQuery);
    return db_integer;
}

stock Client_GetInt(Handle:db, const String:command[], row=0)
{
    // Function without steamid

    new Handle:hQuery;
    new reply = 0;
    LOCK(db);

    if ((hQuery = SQL_Query(db, command)) == INVALID_HANDLE)
    {
        LogError("[BOT] Error in Client_GetInt()");
        UNLOCK(db);
        return reply;
    }

    UNLOCK(db);

    if (SQL_FetchRow(hQuery))
        reply = SQL_FetchInt(hQuery, row);

    CloseHandle(hQuery);
    return reply;
}

stock bool:Client_GetBool(Handle:db, const String:command[], const String:id[])
{
    decl String:query[QUERY];
    Format(query, QUERY, command, id);
    new bool:fastQuery;
    Client_FastQueryBool(db, query, fastQuery);

    if (!fastQuery)
        LogError("[BOT] Unable to execute Client_GetBool()");

    return fastQuery;
}

stock Client_SaveNickname(Handle:db, const any:client)
{
    decl String:query[QUERY];
    Format(query, QUERY, commands[savenickname], nickname[client], steamid[client]);
    Client_FastQuery(db, query);
}

stock bool:Client_Ranked(Handle:db, const any:client)
{
    decl String:query[QUERY];
    new Handle:hQuery = INVALID_HANDLE;

    Format(query, QUERY, commands[testplayer], steamid[client]);
    LOCK(db);

    if ((hQuery = SQL_Query(db, query)) == INVALID_HANDLE)
    {
        LogError("[BOT] Unable to exec query in Client_Ranked()");
        UNLOCK(db);
        return false;
    }

    UNLOCK(db);

    if (!SQL_FetchRow(hQuery))
    {
        CloseHandle(hQuery);
        return false;
    }

    CloseHandle(hQuery);
    return true;
}

stock GetClientNames()
{
    new Handle:db = db_Connect();
    decl String:query[QUERY];
    new bool:name;
    new bool:auth;

    FORLOOP(SLOTS)
    {
        if (IsClientConnected(i))
        {
            name = GetClientName(i, nickname[i], MAX_NAME_LENGTH);
            auth = GetClientAuthString(i, steamid[i], LINE_LENGTH);
            
            if (name && auth)
            {
                player[i][rank] = Client_Ranked(db, i);

                if (player[i][rank])
                {
                    Format(query, QUERY, commands[savenickname], nickname[i], steamid[i]);
                    Client_FastQuery(db, query);
                }

                player[i][newplaytime] = GetTime();
            }
        }
        else
        {
            strcopy(nickname[i], MAX_NAME_LENGTH, "");
            strcopy(steamid[i], LINE_LENGTH, "");
            player[i][newkills] = 0;
            player[i][oldkills] = 0;
            player[i][newplaytime] = 0;
            player[i][oldplaytime] = 0;
            player[i][rank] = false;
        }
    }

    CloseHandle(db);
}

