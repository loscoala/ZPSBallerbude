/*
 * =============================================================================
 * SourceMod KillerSpieler-[BOT] Plugin
 *
 * It's a fork of msleeper's VERY BASIC HIGH PING KICKER
 * Visit http://www.msleeper.com/ for more info!
 *
 * HighPingKicker; KillerSpieler
 * http://steamcommunity.com/groups/ZPSBallerbude
 * =============================================================================
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

#pragma tabsize 4
#pragma semicolon 1

#include <killerbot>

public Plugin:myinfo =
{
    name = "HighPingKicker & AFK-Kicker BOT",
    author = "KillerSpieler",
    description = "HighPingKicker and AfkKicker",
    version = VERSION,
    url = "http://steamcommunity.com/groups/ZPSBallerbude"
};

new PingWarnings[SLOTS+1];
new bool:TimerCheck = false;
new Float:g_rate = 20.0;
new g_MaxPing = 300;
new g_MinTime = 60;
new g_MaxWarnings = 15;
new Handle:PingTimer = INVALID_HANDLE;
new Handle:cvar_KickMsg = INVALID_HANDLE;

new AfkWarnings[SLOTS+1];
new g_MaxAfkWarnings = 36;
new Handle:cvar_AfkMsg = INVALID_HANDLE;

public OnPluginStart()
{
    LoadTranslations("common.phrases");
    cvar_KickMsg = CreateConVar("bot_kickmsg", "You have been kicked due to excessive ping", "Kick message", FCVAR_PLUGIN);
    cvar_AfkMsg = CreateConVar("bot_afkmsg", "You have been kicked for being AFK", "AFK kick message", FCVAR_PLUGIN);
    RegAdminCmd("sm_kicker", Command_Kicker, ADMFLAG_KICK, "Killerspieler BOT");
    KickerLoop();
}

public OnClientAuthorized(client, const String:id[])
{
    if(!IsFakeClient(client))
    {
        PingWarnings[client] = 0;
        AfkWarnings[client] = 0;
    }
}

public OnMapStart()
{
    KickerLoop();
}

public Action:Command_Kicker(client, args)
{
    decl String:arg1[32];
    GetCmdArg(1, arg1, 32);

    decl String:arg2[32];
    GetCmdArg(2, arg2, 32);

    if (StrEqual(arg1, "!maxping"))
    {
        new len = strlen(arg2);

        if (len > 0)
        {
            g_MaxPing = StringToInt(arg2);
            ReplyToCommand(client, "\x04[BOT]\x01 maxping = \x04%s", arg2);
        }
        else
            ReplyToCommand(client, "\x04[BOT]\x01 Current g_MaxPing is: \x04%d\n\x01Usage: !kicker !maxping \x04<number>", g_MaxPing);
    }
    else if (StrEqual(arg1, "!warnings"))
    {
        new len = strlen(arg2);

        if (len > 0)
        {
            g_MaxWarnings = StringToInt(arg2);
            ReplyToCommand(client, "\x04[BOT]\x01 warnings = \x04%s", arg2);
        }
        else
            ReplyToCommand(client, "\x04[BOT]\x01 Current g_MaxWarnings are: \x04%d\n\x01Usage: !kicker !warnings \x04<number>", g_MaxWarnings);
    }
    else if (StrEqual(arg1, "!team"))
    {
#if GAME == ZPS
        ReplyToCommand(client, "You are in team %d, SPEC: %d, ZOMBIE: %d, SURVIVOR: %d, SPAWNED %d",
            GetClientTeam(client),
            _:SPECTATOR,
            _:UNDEAD,
            _:SURVIVORS,
            _:NO_TEAM);
#else
#error "Your game is currently not supported!"
#endif
    }
    else if (StrEqual(arg1, "!afk"))
    {
        new textlen = strlen(arg2);

        if (textlen > 0)
        {
            g_MaxAfkWarnings = StringToInt(arg2);
            ReplyToCommand(client, "\x04[BOT]\x01 MaxAfkWarnings = \x04%s", arg2);
        }
        else
            ReplyToCommand(client, "\x04[BOT]\x01 Current g_MaxAfkWarnings are: \x04%d\n\x01Usage: !kicker !afk \x04<number>", g_MaxAfkWarnings);
    }
    else
        ReplyToCommand(client, "\x04[BOT]\x01 !maxping !warnings !team !afk");

    return Plugin_Handled;
}

static KickerLoop()
{
    FORLOOP(SLOTS)
    {
        PingWarnings[i] = 0;
        AfkWarnings[i] = 0;
    }

    if (PingTimer == INVALID_HANDLE)
        PingTimer = CreateTimer(g_rate, timer_CheckPing, INVALID_HANDLE, TIMER_REPEAT);

    TimerCheck = true;
    CreateTimer(60.0, timer_EnableCheck);
}


public Action:timer_EnableCheck(Handle:timer)
{
    TimerCheck = false;
}

public Action:timer_CheckPing(Handle:timer)
{
    if (TimerCheck)
        return;

    decl String:Message[BIGQUERY];
    new Float:Ping;
    new Float:Time;
    decl String:clientnick[MAX_NAME_LENGTH];
#if GAME == ZPS
    new UserTeam:team = NO_TEAM;
#else
#error "Your game is currently not supported!"
#endif
    new flags = 0;

    FORLOOP(SLOTS)
    {
        if (IsClientConnected(i) && IsClientInGame(i))
        {
            Time = GetClientTime(i);

            if (Time < g_MinTime)
                continue;

            if (PingWarnings[i] >= g_MaxWarnings)
            {
                GetClientName(i, clientnick, MAX_NAME_LENGTH);
                GetConVarString(cvar_KickMsg, Message, BIGQUERY);
                KickClient(i, Message);
                PingWarnings[i] = 0;
                PrintToChatAll("\x04[BOT]\x01 Ping is too high, kicked \x04%s", clientnick);
                continue;
            }

            if (AfkWarnings[i] >= g_MaxAfkWarnings)
            {
                GetClientName(i, clientnick, MAX_NAME_LENGTH);
                GetConVarString(cvar_AfkMsg, Message, BIGQUERY);
                KickClient(i, Message);
                AfkWarnings[i] = 0;
                PrintToChatAll("\x04[BOT]\x01 Too long AFK, kicked \x04%s", clientnick);
                continue;
            }

            Ping = GetClientAvgLatency(i, NetFlow_Outgoing) * 1024;

            if (Ping > g_MaxPing)
            {
                flags = GetUserFlagBits(i);
                if ((flags & ADMFLAG_RESERVATION) || (flags & ADMFLAG_ROOT) || (flags & ADMFLAG_KICK))
                    continue;

                PingWarnings[i] = PingWarnings[i] + 1;
                ReplyToCommand(i, "\x04[BOT]\x01 Your ping is too high (%f), warning \x04%d\x01/\x04%d",
                    Ping, PingWarnings[i], g_MaxWarnings);
            }

            team = UserTeam:GetClientTeam(i);
#if GAME == ZPS
            if ((team == NO_TEAM) || (team == SPECTATOR))
#else
#error "Your game is currently not supported!"
#endif
            {
                flags = GetUserFlagBits(i);
                if ((flags & ADMFLAG_RESERVATION) || (flags & ADMFLAG_ROOT) || (flags & ADMFLAG_KICK))
                    continue;

                AfkWarnings[i] += 1;
                ReplyToCommand(i, "\x04[BOT]\x01 You are marked as AFK %d/%d", AfkWarnings[i], g_MaxAfkWarnings);
            }
        }
    }
}

