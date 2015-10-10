/* commandBestRates.sp
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

public Action:Command_Rates(client, args)
{
    // public command
    // !rates

    decl String:arg1[ARGLEN];
    GetCmdArg(1, arg1, ARGLEN);

    if (StrEqual(arg1, "!help") || StrEqual(arg1, "help"))
    {
        ReplyToCommand(client, "\x04[BOT]\x01 If you got DSL 1000 or lower use: !rates !low");
        ReplyToCommand(client, "\x04[BOT]\x01 If you got DSL 2000-6000 use: !rates !normal");
        ReplyToCommand(client, "\x04[BOT]\x01 If you got DSL 8000 or higher use: !rates !high");
    }
    else if (StrEqual(arg1, "!low") || StrEqual(arg1, "low"))
    {
        ClientCommand(client, "rate 6500");
        ClientCommand(client, "cl_updaterate 30");
        ClientCommand(client, "cl_cmdrate 30");
        ClientCommand(client, "cl_resend 6");
        ClientCommand(client, "cl_timeout 120");
        ClientCommand(client, "cl_lagcompensation 1");
        ClientCommand(client, "cl_smooth 1");
        ClientCommand(client, "cl_interp_ratio 1");
        PrintToChatAll("\x04[BOT] %s\x01 has now low rates!", nickname[client]);
    }
    else if (StrEqual(arg1, "!normal") || StrEqual(arg1, "normal"))
    {
        ClientCommand(client, "rate 8500");
        ClientCommand(client, "cl_updaterate 60");
        ClientCommand(client, "cl_cmdrate 60");
        ClientCommand(client, "cl_resend 6");
        ClientCommand(client, "cl_timeout 60");
        ClientCommand(client, "cl_lagcompensation 1");
        ClientCommand(client, "cl_smooth 1");
        ClientCommand(client, "cl_interp_ratio 0.1");
        PrintToChatAll("\x04[BOT] %s\x01 has now normal rates!", nickname[client]);
    }
    else if (StrEqual(arg1, "!high") || StrEqual(arg1, "high"))
    {
        ClientCommand(client, "rate 10000");
        ClientCommand(client, "cl_updaterate 100");
        ClientCommand(client, "cl_cmdrate 100");
        ClientCommand(client, "cl_resend 6");
        ClientCommand(client, "cl_timeout 30");
        ClientCommand(client, "cl_lagcompensation 1");
        ClientCommand(client, "cl_smooth 1");
        ClientCommand(client, "cl_interp_ratio 0.0000001");
        PrintToChatAll("\x04[BOT] %s\x01 has now high rates!", nickname[client]);
    }
    else
        ReplyToCommand(client, "\x04[BOT]\x01 Usage: !rates [!low, !normal, !high, !help]");

    return Plugin_Handled;
}

