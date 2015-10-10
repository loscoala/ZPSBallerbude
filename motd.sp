/* motd.sp
 *
 * Message Of The Day - plugin
 * developed by Walki; 12/2009
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
 
#pragma semicolon 1
#pragma tabsize 4

#include <killerbot>

public Plugin:myinfo =
{
    name = "Rules and Modt2",
    author = BBTEAM,
    description = "Opens a second motd in zps, views the ZPS ballerbude steamgroup and opens the ballerbudeteam Website.",
    version = VERSION,
    url = "hhttp://steamcommunity.com/groups/ZPSBallerbude"
};

public OnPluginStart()
{
    RegConsoleCmd("sm_rules", CmdRules);
    RegConsoleCmd("sm_steam", CmdSteam);
    RegConsoleCmd("sm_website", CmdWebsite);
}

public OnClientPutInServer(client)
{
    ShowMOTDPanel(client,"Ballerbude Rules and Settings", "motd2/motd", MOTDPANEL_TYPE_INDEX);
}

public Action:CmdRules(client,args)
{
    ShowMOTDPanel(client,"Ballerbude Rules and Settings", "motd2/motd", MOTDPANEL_TYPE_INDEX);
    return Plugin_Handled;
}

public Action:CmdSteam(client,args)
{
    ShowMOTDPanel(client,"Ballerbude Steamgroup", "http://steamcommunity.com/groups/ZPSBallerbude", MOTDPANEL_TYPE_URL);
    return Plugin_Handled;
}

public Action:CmdWebsite(client,args)
{
    ShowMOTDPanel(client,"Ballerbude Team Website", "http://ballerbude-team.de.ms", MOTDPANEL_TYPE_URL); 
    return Plugin_Handled;
}
