/* message.sp
 *
 * =============================================================================
 * SourceMod - Ballerbuden [MESSAGE] plugin by KillerSpieler, Bratpfanne
 * This plugin displays messages.
 *
 * 10.01.2010; KillerSpieler
 * 24.01.2010; KillerSpieler
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

#pragma tabsize 4
#pragma semicolon 1

#include <killerbot>

public Plugin:myinfo =
{
    name = "Message plugin",
    author = BBTEAM,
    description = "This plugin displays messages",
    version = VERSION,
    url = "http://steamcommunity.com/groups/ZPSBallerbude"
};

// You can simply add an text into this Array, but be careful!
// Because the maximun size of a string is limited to 255!
new String:g_message[][QUERY] =
{
    "\x04[BOT]\x01 Want to be ranked? Then write !rankme into chat.",
    "\x04[BOT]\x01 If you want to see your rank write !rank into chat.",
    "\x04[BOT]\x01 Type !rules into chat to see our serverrules.",
    "\x04[BOT]\x01 If you want to fix your rates type !rates [!low, !normal, !high].",
    "\x04[BOT]\x01 Want to join our steamgroup? Then type !steam into chat.",
    "\x04[BOT]\x01 If you want to know something write !helpme into chat."
};

// Show a message every g_rate seconds.
new Float:g_rate = 30.0;
// After this time show a message every (g_rate) seconds. (Called after mapchange)
new Float:g_breaktime = 60.0;
new Handle:MessageTimer = INVALID_HANDLE;
new bool:TimerChecker = false;

public OnPluginStart()
{
    RegAdminCmd("sm_message", Command_Message, ADMFLAG_GENERIC, "Message Plugin");
    MessageLoop();
}

public OnMapStart()
{
    MessageLoop();
}

static MessageLoop()
{
    if (MessageTimer == INVALID_HANDLE)
        MessageTimer = CreateTimer(g_rate, timer_PrintMessage, INVALID_HANDLE, TIMER_REPEAT);

    TimerChecker = true;
    CreateTimer(g_breaktime, timer_EnableCheck);
}

public Action:timer_EnableCheck(Handle:timer)
{
    TimerChecker = false;
}

static GetNewPos(const position)
{
    return position % sizeof(g_message);
}

public Action:timer_PrintMessage(Handle:timer)
{
    if (TimerChecker)
        return;

    static pos = 0;
    PrintToChatAll(g_message[pos]);
    pos = GetNewPos(pos + 1);
}

public Action:Command_Message(client, args)
{
    decl String:arg1[ARGLEN];
    GetCmdArg(1, arg1, ARGLEN);

    new const size = sizeof(g_message);

    if (StrEqual(arg1, "!getMessages"))
    {
        for (new i = 0; i < size; i++)
            ReplyToCommand(client, "\x04[MESSAGE]\x01 %d: %s", i, g_message[i]);
    }
    else if (StrEqual(arg1, "!getMessageCount"))
    {
        ReplyToCommand(client, "\x04[MESSAGE]\x01 There are %d messages.", size);
    }
    else if (StrEqual(arg1, "!setMessage"))
    {
        decl String:arg2[QUERY];
        GetCmdArg(2, arg2, QUERY);
        
        decl String:arg3[5];
        GetCmdArg(3, arg3, sizeof(arg3));
        
        new bool:success = false;
        
        if (strlen(arg2) > 0 && strlen(arg3) > 0)
        {
            new const t_position = StringToInt(arg3);

            if (t_position > -1 && t_position < size)
            {
                g_message[t_position] = arg2;
                success = true;
                ReplyToCommand(client, "\x04[MESSAGE]\x01 setting \x04\"%s\"\x01 to \x04%s", arg2, arg3);
            }
            else
                ReplyToCommand(client, "\x04[MESSAGE]\x01 Sorry, your position in not in range!");
        }

        if (!success)
            ReplyToCommand(client, "\x04[MESSAGE]\x01 sm_message !setMessage <text> <position>");
    }
    else if (StrEqual(arg1, "!info"))
    {
        ReplyToCommand(client, "\x04[MESSAGE]\x01 breaktime: \x04%f\x01 rate: \x04%f", g_breaktime, g_rate);
    }
    else if (StrEqual(arg1, "!setBreak"))
    {
        decl String:arg2[ARGLEN];
        GetCmdArg(2, arg2, ARGLEN);

        if (strlen(arg2) > 0)
        {
            new const Float:t_breaktime = StringToFloat(arg2);
            
            if (FloatCompare(t_breaktime, 0.0) == 1)
            {
                g_breaktime = t_breaktime;
                ReplyToCommand(client, "\x04[MESSAGE]\x01 breaktime is now: \x04%f", g_breaktime);
            }
        }
    }
    else if (StrEqual(arg1, "!setRate"))
    {
        decl String:arg2[ARGLEN];
        GetCmdArg(2, arg2, ARGLEN);

        if (strlen(arg2) > 0)
        {
            new const Float:t_rate = StringToFloat(arg2);
            
            if (FloatCompare(t_rate, 0.0) == 1)
            {
                g_rate = t_rate;
                ReplyToCommand(client, "\x04[MESSAGE]\x01 rate is now: \x04%f", g_rate);
            }
        }
    }
    else
    {
        ReplyToCommand(client, "\x04[MESSAGE]\x01 Commands: !getMessages getMessageCount !setMessage");
        ReplyToCommand(client, "\x04[MESSAGE]\x01 !info !setBreak !setRate");
    }

    return Plugin_Handled;
}
