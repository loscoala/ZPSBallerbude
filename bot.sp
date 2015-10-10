/* bot.sp
 *
 * =============================================================================
 * SourceMod - Ballerbuden [BOT] Plugin by KillerSpieler, Bratpfanne
 * This plugin contains all [BOT] interactive commands.
 *
 * 10.09.2009; KillerSpieler
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

// we're coding at the highest stage
#pragma semicolon 1
#pragma tabsize 4

// include killerbot.inc, this file contains constants like SLOTS etc...
#include <killerbot>

#define AUTOTK 0        // if 1, tkkicker will be activated if BOT command equals !ff
#define MAP_READER 0    // if 1, the bot is able to compare your choosen map with all existing maps
#define ANTI_REJOIN 0   // Avoid that players leave and rejoin
#define BLOCKER 1       // It´s not possible to change the sv_gravity convar

#if ANTI_REJOIN
#define REJOIN_TIMER 30.0
#endif

#define SKIP_SLAY 1     // Skip "slay" Command and kick teamkillers immediately

// --- PUBLIC VARIABLES ---

public Plugin:myinfo =
{
    name = "The Ballerbude [BOT] plugin",
    author = BBTEAM,
    description = "All-in-one [BOT] plugin",
    version = VERSION,
    url = "http://steamcommunity.com/groups/ZPSBallerbude"
};

#if ANTI_REJOIN
// OnClientDisconnect -> Save IP -> if client immediately reconnect -> disallow client
new String:LastIPBuffer[IP_LEN];
new bool:IPBlockTimer = false;
new Handle:cTimer = INVALID_HANDLE;
#endif
new bool:tkkicker = false;
new tk_warnings[SLOTS+1];
#if !SKIP_SLAY
new tk_MaxSlayWarnings = 2;
#endif
new tk_MaxKickWarnings = 4;
#if MAP_READER
new Handle:Maplist = INVALID_HANDLE;
new mapFileSerial = -1;
#endif

static InitVars()
{
    FORLOOP(SLOTS)
    {
        if (IsClientConnected(i) && IsClientInGame(i))
        {
            GetClientName(i, nickname[i], MAX_NAME_LENGTH);
            GetClientAuthString(i, steamid[i], LINE_LENGTH);
        }
        
        tk_warnings[i] = 0;
    }
}

// --- BUILTIN FUNCTIONS ---

public OnPluginStart()
{
    LoadTranslations("common.phrases");
#if MAP_READER
    new arraySize = ByteCountToCells(LINE_LENGTH+1);
    Maplist = CreateArray(arraySize);
#endif
    RegAdminCmd("sm_bot", Command_Bot, ADMFLAG_GENERIC, "The wonderful <Ballerbude [BOT]> plugin");
    RegConsoleCmd("sm_me", Command_Me, "It's the /me command like in common IRC-clients");
    RegConsoleCmd("sm_rates", Command_Rates, "This command is fixing your rates to the optimal.");
    RegConsoleCmd("sm_helpme", Command_HelpMe, "Shows some informations about the server functions.");
    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
#if ANTI_REJOIN
    HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
#endif
    InitVars();
}

#if MAP_READER
public OnConfigsExecuted()
{
    if (ReadMapList(Maplist,
                    mapFileSerial,
                    "mapchooser",
                    MAPLIST_FLAG_CLEARARRAY|MAPLIST_FLAG_MAPSFOLDER)
            != INVALID_HANDLE)
    {
        if (mapFileSerial == -1)
            LogError("Unable to create a valid map list.");
    }
}
#endif

#if ANTI_REJOIN
// --- LoginBlocker ---

public OnMapEnd()
{
    if (cTimer != INVALID_HANDLE)
    {
        KillTimer(cTimer);
        cTimer = INVALID_HANDLE;
    }

    IPBlockTimer = false;
}

public bool:OnClientConnect(client, String:rejectmsg[], maxlen)
{
    // RETURN: true -> allow client; false -> reject client

    decl String:LoginIP[IP_LEN];
    GetClientIP(client, LoginIP, IP_LEN, true);

    new const count = GetClientCount();

    if (count > 2)
    {
        new const bool:equal = StrEqual(LoginIP, LastIPBuffer);

        if (equal && IPBlockTimer)
        {
            strcopy(rejectmsg, maxlen, "[BLOCKED] Sorry, you have to wait!");
            return false;
        }
    }

    return true;
}
#endif

public OnClientAuthorized(client, const String:id[])
{
    // Called before OnClientPostAdminCheck()
    // Save steamid and nickname

    if (!IsFakeClient(client))
    {
        Format(steamid[client], LINE_LENGTH, id);
        GetClientName(client, nickname[client], MAX_NAME_LENGTH);
        tk_warnings[client] = 0;
    }
}

public OnClientDisconnect(client)
{
    if (!IsFakeClient(client))
    {
        strcopy(nickname[client], MAX_NAME_LENGTH, "");
        strcopy(steamid[client], LINE_LENGTH, "");
        tk_warnings[client] = 0;
    }
}

// --- EVENTS ---

#if ANTI_REJOIN
#include "bot/eventPlayerDisconnect.sp"
#endif

#include "bot/eventPlayerDeath.sp"

// --- ACTIONS ---

#if ANTI_REJOIN
public Action:Timer_LoginBlocker(Handle:timer)
{
    IPBlockTimer = false;
    cTimer = INVALID_HANDLE;
    return Plugin_Stop;
}
#endif

// --- Commands ---

#include "bot/commandRates.sp"
#include "bot/commandMe.sp"
#include "bot/commandBot.sp"
#include "bot/commandHelpMe.sp"

#if BLOCKER && (GAME == ZPS)
public ConVarChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
    decl String:name[ARGLEN];
    GetConVarName(convar, name, ARGLEN);
    
    if (StrEqual(name, "sv_gravity"))
        ServerCommand("sv_gravity 600");
}
#endif

