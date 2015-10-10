/* eventPlayerDeath.sp
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

public Action:Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroatcast)
{
    // slay, kick, ban all team killers
    // if tkkicker = OFF
    if (!tkkicker)
        return Plugin_Continue;

    // test, that tk_MaxSlayWarnings is less than tk_MaxKickWarnings
#if SKIP_SLAY
    if (tk_MaxKickWarnings == 0)
#else
    if (!(tk_MaxSlayWarnings < tk_MaxKickWarnings))
#endif
        return Plugin_Continue;

    // The player, which has been killed
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    // The attacker
    new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

    if ((client == 0) || (attacker == 0))
        return Plugin_Continue;

    new UserTeam:client_team = UserTeam:GetClientTeam(client);
    new UserTeam:attacker_team = UserTeam:GetClientTeam(attacker);

    if ((client_team == attacker_team) && !StrEqual(nickname[client], nickname[attacker]))
    {
        tk_warnings[attacker] += 1;
        new tmp_warn = tk_warnings[attacker];

#if !SKIP_SLAY
        if (tmp_warn == tk_MaxSlayWarnings)
        {
            ClientCommand(attacker, "kill");
            PrintToChatAll("\x04[BOT]\x01 Player \x04%s\x01 was slayed for team killing \x04%s", nickname[attacker], nickname[client]);
        }
        else
#endif
        if (tmp_warn >= tk_MaxKickWarnings)
        {
            ServerCommand("sm_kick #%d", attacker);
            tk_warnings[attacker] = 0;
            PrintToChatAll("\x04[BOT]\x01 Player \x04%s\x01 has been kicked for team killing.", nickname[attacker]);
        }
        else
            PrintToChatAll("\x04[BOT] TEAMKILLER!\x01 Player \x04%s\x01 killed a member of his team!", nickname[attacker]);
    }

    return Plugin_Continue;
}

