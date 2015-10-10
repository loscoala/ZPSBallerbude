/* commandRankMe.sp
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

public Action:Command_RankMe(client, args)
{
    // public command
    // !rankme

    new Handle:db = db_Connect();
    new bool:tmpRank = player[client][rank];

    if (tmpRank)
    {
        // Client is known and ranked

        new playedtime = Client_GetIntId(db, commands[gettime], steamid[client]);
        playedtime += (GetTime() - player[client][newplaytime]);

        new frags = Client_GetIntId(db, commands[getfrags], steamid[client]);
        frags += GetClientFrags(client) - player[client][newkills];

        // new const Float:playtime_in_hours = (float(playedtime) / float(3600));
        // new const Float:kills_per_hour = (float(frags) / playtime_in_hours);
        
        new const Float:playtime_in_hours = FloatDiv(float(playedtime), float(3600));
        new const Float:kills_per_hour = FloatDiv(float(frags), playtime_in_hours);

        ReplyToCommand(client, "\x04[BOT]\x01 Player \x04%s\x01 has \x04%d\x01 kills in \x04%f\x01 hours playtime.",
            nickname[client],
            frags,
            playtime_in_hours);
        ReplyToCommand(client, "\x04[BOT]\x01 Kills per hour (kph): \x04%f\x01", kills_per_hour);
    }
    else
    {
        // Save SteamID and nickname

        Client_GetBool(db, commands[savesteamid], steamid[client]);
        Client_SaveNickname(db, client);

        ReplyToCommand(client, "\x04[BOT]\x01 You are not ranked yet. I've saved your SteamID.\nTo delete your entry, enter \"/reset\" into the chat.");
        player[client][rank] = true;
        player[client][oldplaytime] = 0;
        player[client][newplaytime] = GetTime();
    }

    CloseHandle(db);
    return Plugin_Handled;
}

