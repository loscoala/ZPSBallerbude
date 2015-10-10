/* eventPlayerDisconnect.sp
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

public Action:Event_PlayerDisconnect(Handle:event, const String:name[], bool:dontBroatcast)
{
    new const client = GetClientOfUserId(GetEventInt(event, "userid"));
    new const UserTeam:team = UserTeam:GetClientTeam(client);
#if GAME == ZPS
    new const teamcount = GetTeamClientCount(UNDEAD);

    if ((team == UNDEAD) && (teamcount == 1))
#else
#error "Your game is currently not supported!"
#endif
    {
        if (cTimer != INVALID_HANDLE)
        {
            KillTimer(cTimer);
            cTimer = INVALID_HANDLE;
        }

        GetClientIP(client, LastIPBuffer, IP_LEN, true);
        IPBlockTimer = true;
        cTimer = CreateTimer(REJOIN_TIMER, Timer_LoginBlocker);
    }

    return Plugin_Handled;
}
