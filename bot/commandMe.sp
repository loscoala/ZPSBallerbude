/* commandMe.sp
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

public Action:Command_Me(client, args)
{
    // public command
    // !me

    new String:arg1[QUERY];
    new String:message[QUERY];
    new arglen, loop;
    new const String:space[] = " ";

    do {
        loop += 1;
        GetCmdArg(loop, arg1, QUERY);
        arglen = strlen(arg1);

        if (arglen > 0)
        {
            StrCat(message, QUERY, space);
            StrCat(message, QUERY, arg1);
        }

    } while (arglen > 0);

    if ((strlen(message) > 0) && (!IsFakeClient(client)))
        PrintToChatAll("\x04* \x03%s\x04%s", nickname[client], message);

    return Plugin_Handled;
}

