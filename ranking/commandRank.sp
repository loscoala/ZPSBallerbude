/* commandRank.sp
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

public Action:Command_Rank(client, args)
{
    // public command
    // !rank

    if (player[client][rank])
    {
        new Handle:db = db_Connect();
        new const frags = Client_GetIntId(db, commands[getfrags], steamid[client]);

        if (frags >= RANKLIMIT)
        {
            // no noob status

            new const t_rank = Client_GetIntId(db, commands[getrank], steamid[client]);
            new const amount = Client_GetInt(db, commands[getcount]);

            PrintToChatAll("\x04[BOT]\x01 Player \x04%s\x01 is on rank \x04%d\x01/\x04%d\x01.", nickname[client], t_rank, amount);
        }
        else
        {
            // noob status

            new const noobrank = Client_GetIntId(db, commands[getnoobrank], steamid[client]);
            new const noobcount = Client_GetInt(db, commands[getnoobcount]);

            PrintToChatAll("\x04[BOT]\x01 Player \x04%s\x01 has \x04noob status\x01.\nRank: \x04%d\x01/\x04%d\x01. (< %d kills)",
                nickname[client],
                noobrank,
                noobcount,
                RANKLIMIT);
        }

        CloseHandle(db);
    }
    else
        ReplyToCommand(client, "\x04[BOT]\x01 You are not ranked yet. Try !rankme to start the ranking-system");

    return Plugin_Handled;
}

