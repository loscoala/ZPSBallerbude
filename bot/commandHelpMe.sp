/* commandHelpMe.sp
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

public Action:Command_HelpMe(client, args)
{
    // public command
    // !helpme

    decl String:arg1[ARGLEN];
    GetCmdArg(1, arg1, ARGLEN);

    if (StrEqual(arg1, "!mapchange") || StrEqual(arg1, "mapchange"))
    {
        ReplyToCommand(client, "\x04[BOT]\x01 Don't like this map? Write \x04nominate\x01 into chat to");
        ReplyToCommand(client, "\x04[BOT]\x01 see all available maps. Pick one and then write \x04rtv\x01 into chat.");
    }
    else if (StrEqual(arg1, "!rates") || StrEqual(arg1, "!rates"))
    {
        ReplyToCommand(client, "\x04[BOT]\x01 Want to fix your rates? But you has forgot how to open the console?");
        ReplyToCommand(client, "\x04[BOT]\x01 No Problem! Simple write \x04!rates\x01 into chat to find the best rates for you.");
    }
    else if (StrEqual(arg1, "!bot") || StrEqual(arg1, "!bot"))
    {
        ReplyToCommand(client, "\x04[BOT]\x01 You asking me what I am? I'm the wonderful BallerbudeBOT!");
        ReplyToCommand(client, "\x04[BOT]\x01 I was made by %s. If you got questions ask me!", BBTEAM);
        ReplyToCommand(client, "\x04[BOT]\x01 Something about me: I'm working 24/7 on this server and I note everyone");
        ReplyToCommand(client, "\x04[BOT]\x01 who is joining it. So Beware! I'm everywhere!");
    }
    else if (StrEqual(arg1, "!vote") || StrEqual(arg1, "vote"))
    {
        ReplyToCommand(client, "\x04[BOT]\x01 You can use \x04!votemute\x01 if a player has a bad behavior.");
    }
    else if (StrEqual(arg1, "!rank") || StrEqual(arg1, "rank")
        || StrEqual(arg1, "!reset") || StrEqual(arg1, "reset")
        || StrEqual(arg1, "!rankme") || StrEqual(arg1, "rankme")
        || StrEqual(arg1, "!top10") || StrEqual(arg1, "top10")
        || StrEqual(arg1, "!topnoobs") || StrEqual(arg1, "topnoobs"))
    {
        ReplyToCommand(client, "\x04[BOT]\x01 This is the ranking-system. If you want to get ranked or");
        ReplyToCommand(client, "\x04[BOT]\x01 get some information type \x04!rankme\x01 into the chat.");
        ReplyToCommand(client, "\x04[BOT]\x01 You can delete your database entry with \x04!reset\x01.");
        ReplyToCommand(client, "\x04[BOT]\x01 The \x04!rank\x01 command shows your rank compared with");
        ReplyToCommand(client, "\x04[BOT]\x01 others in public.\x04!top10\x01 and \x04!topnoobs\x01 shows the top-ten ranking list.");
    }
    else
        ReplyToCommand(client, "\x04[BOT]\x01 Usage: !helpme [!rank !rankme !reset !mapchange\n\x04[BOT]\x01 !vote !rates !bot !top10 !topnoobs]");

    return Plugin_Handled;
}

