/* commandTopNoobs.sp
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

public Action:Command_TopNoobs(client, args)
{
    // public command
    // !topnoobs

    new Handle:db = db_Connect();
    new Handle:hQuery;
    new String:nick[MAX_NAME_LENGTH];
    new kph = 0;
    new number = 1;

    LOCK(db);

    if ((hQuery = SQL_Query(db, commands[gettopnoobs])) == INVALID_HANDLE)
    {
        LogError("[BOT] Unable to execute TopNoobs()");
        return Plugin_Handled;
    }

    UNLOCK(db);
    ReplyToCommand(client, "\x04[BOT]\x01 TOP NOOBS:");

    while (SQL_FetchRow(hQuery))
    {
        SQL_FetchString(hQuery, 0, nick, MAX_NAME_LENGTH);
        kph = SQL_FetchInt(hQuery, 1);
        ReplyToCommand(client, "\x04[BOT]\x01 %d. %s | kph: %d", number, nick, kph);
        number += 1;
    }

    CloseHandle(hQuery);
    CloseHandle(db);
    return Plugin_Handled;
}

