/* commandBot.sp
 * 2011; KillerSpieler
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
 */

#assert defined _killerbot_included

static PrintErrorMsg(client)
{
    ReplyToCommand(client, "\x04[BOT]\x01 Try: !bot !help");
}

public Action:Command_Bot(client, args)
{
    // admin command
    // !bot

    decl String:arg1[ARGLEN];
    new firstChar = 0;
    GetCmdArg(1, arg1, ARGLEN);

    if (strlen(arg1) > 1)
    {
        firstChar = _:arg1[0];

        if (firstChar == '!')
            firstChar = _:arg1[1];
    }

    switch (firstChar)
    {
        case 'a':
        {
            if (StrEqual(arg1, "!alltalk") || StrEqual(arg1, "alltalk"))
            {
                if (GetLocalServerConVar("sv_alltalk"))
                {
                    ServerCommand("sv_alltalk 0");
                    PrintToChatAll("\x04[BOT]\x01 alltalk = \x04OFF");
                }
                else
                {
                    ServerCommand("sv_alltalk 1");
                    PrintToChatAll("\x04[BOT]\x01 alltalk = \x04ON");
                }
            }
            else
                PrintErrorMsg(client);
        }
        case 'c':
        {
            if (StrEqual(arg1, "!changemap") || StrEqual(arg1, "changemap"))
            {
                decl String:arg2[ARGLEN];
                GetCmdArg(2, arg2, ARGLEN);

                if (strlen(arg2) > 0 && IsMapValid(arg2))
                {
                    new Handle:mapchooserfile = FindPluginByFile("mapchooser.smx");

                    if (mapchooserfile != INVALID_HANDLE)
                    {
                        new PluginStatus:mapchooser = GetPluginStatus(mapchooserfile);

                        if (mapchooser == Plugin_Running)
                            ServerCommand("sm plugins unload mapchooser");

                        CloseHandle(mapchooserfile);
                    }
#if MAP_READER
#define MAX_MAP_COUNTER 5
                    /* !bot !changemap biotec
                     * found: zpo_biotec
                     * result: zpo_biotec
                     *
                     * !bot !changemap bunker 4
                     * found: zpo_thebunker_b3 zpo_thebunker_b4
                     * result: zpo_thebunker_b4
                     */

                    decl String:arg3[ARGLEN];
                    new arg3_len = GetCmdArg(3, arg3, ARGLEN);

                    new const size = GetArraySize(Maplist);
                    new count = 0;
                    decl String:map[LINE_LENGTH];
                    decl String:map_found[MAX_MAP_COUNTER][LINE_LENGTH];

                    for (new i = 0; i < size; i++)
                    {
                        GetArrayString(Maplist, i, map, LINE_LENGTH);

                        if (IsMapValid(map))
                        {
                            if ((StrContains(map, arg2, false) != -1) && (count < MAX_MAP_COUNTER))
                            {
                                strcopy(map_found[count], LINE_LENGTH, map);
                                count += 1;
                            }
                            else
                            {
                                ReplyToCommand(client, "\x04[BOT]\x01 FAILED, more than five maps found.");
                                break;
                            }
                        }
                    }

                    if (count == 1)
                    {
                        ServerCommand("sm_nextmap %s", map);
                        ServerCommand("mp_timelimit 1");
                        PrintToChatAll("\x04[BOT]\x01 Next map is: \x04%s\x01. Map change after \x04this ROUND\x01!", map);
                    }
                    else if (count > 1)
                    {
                        if (arg3_len == 0)
                        {
                            // !bot !changemap bunker
                            // => more than one result

                            for (new i = 0; i < count; i++)
                                ReplyToCommand(client, "\x04[BOT]\x01 Found: \x04%s", map_found[i]);
                        }
                        else
                        {
                            // !bot !changemap bunker 4
                            // take the map with character '4'

                            new bool:success = false;

                            for (new i = 0; i < count; i++)
                            {
                                if (FindCharInString(map_found[i], arg3[0], true) != -1)
                                {
                                    ServerCommand("sm_nextmap %s", map_found[i]);
                                    ServerCommand("mp_timelimit 1");
                                    PrintToChatAll("\x04[BOT]\x01 Next map is: \x04%s\x01. Map change after \x04this ROUND\x01!", map);
                                    success = true;
                                    break;
                                }
                            }

                            if (!success)
                                ReplyToCommand(client, "\x04[BOT]\x01 Unable to solve your request.");
                        }
                    }
                    else
                    {
                        // count equals to 0

                        ReplyToCommand(client, "\x04[BOT]\x01 No maps found.");
                    }
#undef MAX_MAP_COUNTER
#else
                    ServerCommand("sm_nextmap %s", arg2);
                    ServerCommand("mp_timelimit 1");
                    PrintToChatAll("\x04[BOT]\x01 Next map is: \x04%s\x01. Map change after \x04this ROUND\x01!", arg2);
#endif
                }
                else
                    ReplyToCommand(client, "\x04[BOT]\x01 Usage: !bot !changemap \x04<mapname>");
            }
            else if (StrEqual(arg1, "!checkautobalance") || StrEqual(arg1, "checkautobalance"))
            {
                ServerCommand("sv_zp_checkautobalance");
                PrintToChatAll("\x04[BOT]\x01 Autobalance Check done.");
            }
            else
                PrintErrorMsg(client);
        }
        case 'f':
        {
            if (StrEqual(arg1, "!ff") || StrEqual(arg1, "ff")
                || StrEqual(arg1, "!ff_on") || StrEqual(arg1, "!ff_off"))
            {
                if (GetLocalServerConVar("mp_friendlyfire"))
                {
#if AUTOTK
                    if (tkkicker)
                    {
                        tkkicker = false;
                        PrintToChatAll("\x04[BOT]\x01 TK-KICKER = \x04OFF");
                    }
#endif
                    ServerCommand("mp_friendlyfire 0");
                    PrintToChatAll("\x04[BOT]\x01 friendly fire = \x04OFF");
                }
                else
                {
#if AUTOTK
                    if (!tkkicker)
                    {
                        tkkicker = true;
                        PrintToChatAll("\x04[BOT]\x01 TK-KICKER = \x04ON");
                    }
#endif
                    ServerCommand("mp_friendlyfire 1");
                    PrintToChatAll("\x04[BOT]\x01 friendly fire = \x04ON");
                }
            }
            else
                PrintErrorMsg(client);
        }
        case 'h', 'v':
        {
            if (StrEqual(arg1, "!hardcore") || StrEqual(arg1, "hardcore"))
            {
                if (GetLocalServerConVar("sv_hardcore"))
                {
                    ServerCommand("sv_hardcore 0");
                    PrintToChatAll("\x04[BOT]\x01 HARDCORE = \x04OFF");
                }
                else
                {
                    ServerCommand("sv_hardcore 1");
                    PrintToChatAll("\x04[BOT]\x01 HARDCORE = \x04ON");
                }
            }
            else if (StrEqual(arg1, "!help") || StrEqual(arg1, "help")
                || StrEqual(arg1, "!version") || StrEqual(arg1, "version"))
            {
                PrintToChatAll("\x04[BOT]\x01 Description: \x04SourceMod [BOT] Plugin");
                PrintToChatAll("\x04[BOT]\x01 Author:  \x04%s", BBTEAM);
                PrintToChatAll("\x04[BOT]\x01 Version: \x04%s", VERSION);
            }
            else
                PrintErrorMsg(client);
        }
        case 'i':
        {
            if (StrEqual(arg1, "!infrate") || StrEqual(arg1, "infrate"))
            {
                decl String:arg2[ARGLEN];
                GetCmdArg(2, arg2, ARGLEN);

                if (strlen(arg2) > 0)
                {
                    // !bot !infrate <number>

                    new const number = StringToInt(arg2);

                    if (number != 0)
                    {
                        ServerCommand("sv_cheats 1");
                        ServerCommand("infected_chance %d", number);
                        ServerCommand("sv_cheats 0");
                        PrintToChatAll("\x04[BOT]\x01 Infection-chance is now: \x04%d\x01 percent", number);
                    }
                    else
                        ReplyToCommand(client, "\x04[BOT]\x01 Error! Wrong argument, it's not typed as Integer! \nYou didn't entered a valid number!");
                }
                else
                {
                    // !bot !infrate

                    new const current_rate = GetLocalServerInt("infected_chance");
                    ReplyToCommand(client, "\x04[BOT]\x01 Current infection-chance: \x04%d\x01 percent", current_rate);
                }
            }
            else
                PrintErrorMsg(client);
        }
        case 'n':
        {
            if (StrEqual(arg1, "!nextmap") || StrEqual(arg1, "nextmap"))
            {
                decl String:arg2[ARGLEN];
                GetCmdArg(2, arg2, ARGLEN);

                if (strlen(arg2) > 0 && IsMapValid(arg2))
                {
                    new Handle:mapchooserfile = FindPluginByFile("mapchooser.smx");

                    if (mapchooserfile != INVALID_HANDLE)
                    {
                        new PluginStatus:mapchooser = GetPluginStatus(mapchooserfile);

                        if (mapchooser == Plugin_Running)
                            ServerCommand("sm plugins unload mapchooser");

                        CloseHandle(mapchooserfile);
                    }

                    ServerCommand("sm_nextmap %s", arg2);
                    PrintToChatAll("\x04[BOT]\x01 New next map is: \x04%s. Map change after \x04timelimit\x01.", arg2);
                }
                else
                    ReplyToCommand(client, "\x04[BOT]\x01 Usage: !bot !nextmap \x04<mapname>");
            }
            else
                PrintErrorMsg(client);
        }
        case 'o':
        {
            if (StrEqual(arg1, "!oldcol") || StrEqual(arg1, "oldcol"))
            {
                if (GetLocalServerConVar("sv_zpoldcol"))
                {
                    ServerCommand("sv_zpoldcol 0");
                    PrintToChatAll("\x04[BOT]\x01 Old Collisions = \x04OFF");
                }
                else
                {
                    ServerCommand("sv_zpoldcol 1");
                    PrintToChatAll("\x04[BOT]\x01 Old Collisions = \x04ON");
                }
            }
            else
                PrintErrorMsg(client);
        }
        case 'r':
        {
            // Warning! This command will restart the server and kick all players.
            // Do not use it just for fun!

            if (StrEqual(arg1, "!restartserver") || StrEqual(arg1, "restartserver"))
            {
                // Print message on screen

                ServerCommand("sm_csay Server restart! Rejoin after a few seconds please!");

                // Print message 5 times in chat

                for (new i = 0; i < 6; i++)
                    PrintToChatAll("\x04[BOT] Server restart! Rejoin after a few seconds please!");
                ServerCommand("restart");
            }
            else if (StrEqual(arg1, "!refresh") || StrEqual(arg1, "refresh"))
            {
                // Reloads all plugins in the plugins folder

                PrintToChatAll("\x04[BOT]\x01 Reloading all sourcemod scripts.");
                ServerCommand("sm plugins refresh");
            }
            else
                PrintErrorMsg(client);
        }
        case 's':
        {
            if (StrEqual(arg1, "!slay") || StrEqual(arg1, "slay"))
            {
                // !bot !slay #player
                // This function is working on the old Sourcemod too.

                decl String:arg2[ARGLEN];
                GetCmdArg(2, arg2, ARGLEN);
                new const target = FindTarget(client, arg2);

                if (target != -1)
                {
                    ClientCommand(target, "kill");
                    PrintToChatAll("\x04[BOT]\x01 Admin \x04%s\x01 slayed \x04%s", nickname[client], nickname[target]);
                }
                else
                    ReplyToCommand(client, "\x04[BOT]\x01 Unable to solve your request.");
            }
            else
                PrintErrorMsg(client);
        }
        case 't':
        {
            if (StrEqual(arg1, "!timelimit") || StrEqual(arg1, "timelimit"))
            {
                decl String:arg2[ARGLEN];
                GetCmdArg(2, arg2, ARGLEN);

                if (strlen(arg2) > 0)
                {
                    // Set mp_timelimit

                    new const number = StringToInt(arg2);

                    if (number != 0)
                    {
                        // Valid integer

                        ServerCommand("mp_timelimit %d", number);
                        PrintToChatAll("\x04[BOT]\x01Timelimit for this map is now: \x04%d", number);
                    }
                    else
                        ReplyToCommand(client, "\x04[BOT]\x01 Error! You didn't entered a valid number!");
                }
                else
                {
                    // Get mp_timelimit and print it out

                    new const timelimit = GetLocalServerInt("mp_timelimit");
                    ReplyToCommand(client, "\x04[BOT]\x01 The current time limit is: \x04%d\x01 \nUsage: !bot !timelimit \x04<number>", timelimit);
                }
            }
            else if (StrEqual(arg1, "!tkkicker") || StrEqual(arg1, "tkkicker"))
            {
                // !bot !tkkicker

                if (tkkicker)
                {
                    // turn kicker off

                    tkkicker = false;
                    ReplyToCommand(client, "\x04[BOT]\x01 TKKICKER = \x04OFF");
                }
                else
                {
                    // turn kicker on

                    tkkicker = true;
                    ReplyToCommand(client, "\x04[BOT]\x01 TKKICKER = \x04ON");
                }
            }
            else
                PrintErrorMsg(client);
        }
        case 'z':
        {
            if (StrEqual(arg1, "!zpi") || StrEqual(arg1, "zpi"))
            {
                // zpi means "zombie panic impossible" - Mode

                if (GetLocalServerConVar("sv_zpoldcol"))
                {
                    // sv_zpoldcol = 1, set it to 0

                    ServerCommand("sv_hardcore 0");
                    ServerCommand("sv_zpoldcol 0");
                    ServerCommand("mp_friendlyfire 0");
                    tkkicker = false;
                    PrintToChatAll("\x04[BOT]\x01 Zpi = \x04OFF");
                }
                else
                {
                    // sv_zpoldcol = 0, set it to 1

                    ServerCommand("sv_hardcore 1");
                    ServerCommand("sv_zpoldcol 1");
                    ServerCommand("mp_friendlyfire 1");
                    tkkicker = true;
                    PrintToChatAll("\x04[BOT]\x01 Beware! Impossible game mode is now \x04ON\x01!");
                }
            }
            else if (StrEqual(arg1, "!zpatimelimit") || StrEqual(arg1, "zpatimelimit"))
            {
                decl String:arg2[ARGLEN];
                GetCmdArg(2, arg2, ARGLEN);

                if (strlen(arg2) > 0)
                {
                    // !bot !zpatimelimit <number>
                    // Set mp_zpatimelimit

                    new const number = StringToInt(arg2);

                    if (number != 0)
                    {
                        // Valid integer

                        ServerCommand("mp_zpatimelimit %d", number);
                        PrintToChatAll("\x04[BOT]\x01Zpa time limit for this map is now: \x04%d", number);
                    }
                    else
                        ReplyToCommand(client, "\x04[BOT]\x01 Error! You didn't entered a valid number!");
                }
                else
                {
                    // !bot !zpatimelimit
                    // Get mp_timelimit and print it out

                    new const timelimit = GetLocalServerInt("mp_zpatimelimit");
                    ReplyToCommand(client, "\x04[BOT]\x01 The current zpa time limit is: \x04%d\x01 \nUsage: !bot !zpatimelimit \x04<number>", timelimit);
                }
            }
            else if (StrEqual(arg1, "!zparespawntime") || StrEqual(arg1, "zparespawntime"))
            {
                decl String:arg2[ARGLEN];
                GetCmdArg(2, arg2, ARGLEN);

                if (strlen(arg2) > 0)
                {
                    // Set mp_zparespawndelay

                    new const number = StringToInt(arg2);

                    if (number != 0)
                    {
                        // Valid integer

                        ServerCommand("mp_zparespawndelay %d", number);
                        PrintToChatAll("\x04[BOT]\x01Zpa human respawn time: \x04%d", number);
                    }
                    else
                        ReplyToCommand(client, "\x04[BOT]\x01 Error! You didn't entered a valid number!");
                }
                else
                {
                    // Get mp_zpabalancefactor and print it out

                    new const timelimit = GetLocalServerInt("mp_zparespawndelay");
                    ReplyToCommand(client, "\x04[BOT]\x01 The current zparespawndelay is: \x04%d\x01 \nUsage: !bot !zparespawntime \x04<number>", timelimit);
                }
            }
            else if (StrEqual(arg1, "!zpabalancefactor") || StrEqual(arg1, "zpabalancefactor"))
            {
                decl String:arg2[ARGLEN];
                GetCmdArg(2, arg2, ARGLEN);

                if (strlen(arg2) > 0)
                {
                    // Set mp_zpabalancefactor

                    new const number = StringToInt(arg2);

                    if (number != 0)
                    {
                        // Valid integer

                        ServerCommand("mp_zpabalancefactor %d", number);
                        PrintToChatAll("\x04[BOT]\x01Zpa Balance Factor: \x04%d", number);
                    }
                    else
                        ReplyToCommand(client, "\x04[BOT]\x01 Error! You didn't entered a valid number!");
                }
                else
                {
                    // Get mp_zpabalancefactor and print it out

                    new const timelimit = GetLocalServerInt("mp_zpabalancefactor");
                    ReplyToCommand(client, "\x04[BOT]\x01 The current zpabalancefactor is: \x04%d\x01\nUsage: !bot !zpabalancefactor \x04<number>", timelimit);
                }
            }
            else if (StrEqual(arg1, "!zpanobalance") || StrEqual(arg1, "zpanobalance"))
            {
                if (GetLocalServerConVar("mp_zpanobalance"))
                {
                    ServerCommand("mp_zpanobalance 0");
                    PrintToChatAll("\x04[BOT]\x01 Zpa autobalance = \x04OFF");
                }
                else
                {
                    ServerCommand("mp_zpanobalance 1");
                    PrintToChatAll("\x04[BOT]\x01 Zpa autobalance = \x04ON");
                }
            }
            else
                PrintErrorMsg(client);
        }
        default:
        {
            ReplyToCommand(client, "\x04[BOT]\x01 invalid command: \"%s\" Try: !slay !alltalk !ff !hardcore !help", arg1);
            ReplyToCommand(client, "\x04[BOT]\x01 !nextmap !timelimit !infrate !tkkicker !changemap !oldcol !zpi");
            ReplyToCommand(client, "\x04[BOT]\x01 !zpanobalance !zpabalancefactor !zparespawntime !zpatimelimit");
            ReplyToCommand(client, "\x04[BOT]\x01 !checkautobalance !restartserver !refresh");
        }
    }

    return Plugin_Handled;
}


