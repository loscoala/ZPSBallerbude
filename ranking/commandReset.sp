/* commandReset.sp
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

public Action:Command_Reset(client, args)
{
    // public command
    // !reset

    new bool:tmpRank = player[client][rank];

    if (tmpRank)
    {
        new Handle:db = db_Connect();

        if (db == INVALID_HANDLE)
        {
            ReplyToCommand(client, "[BOT] Ranking is temporary unavailable");
            return Plugin_Handled;
        }

        new bool:reset = Client_GetBool(db, commands[resetrank], steamid[client]);
        CloseHandle(db);

        if (reset)
        {
            player[client][newkills] = 0;
            player[client][oldkills] = 0;
            player[client][oldplaytime] = 0;
            player[client][newplaytime] = 0;
            player[client][rank] = false;
            ReplyToCommand(client, "\x04[BOT]\x01 Your stats has been successfully deleted.");
        }
        else
            ReplyToCommand(client, "\x04[BOT]\x01 Internal server error, please contact an administrator");
    }
    else
        ReplyToCommand(client, "\x04[BOT]\x01 Cannot delete your entry, because you are not ranked yet.");

    return Plugin_Handled;
}

