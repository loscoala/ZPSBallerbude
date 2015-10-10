/* blacksfuncommands.sp
 *
 * =============================================================================
 * 2009; Walki
 * http://steamcommunity.com/groups/ZPSBallerbude
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
 *
 */

#include <sourcemod>
#include <sdktools>

/*
AddFileToDownloadsTable("props_c17/oildrum001.mdl");
AddFileToDownloadsTable("humans/group02/female_01.mdl");
AddFileToDownloadsTable("humans/group02/male_02.mdl");
AddFileToDownloadsTable("zombies/zombie1/zombie1.mdl");
AddFileToDownloadsTable("survivors/survivor1/survivor1.mdl");
*/

public Plugin:myinfo = 
{
	name = "Black's Funcommands Plugin",
	author = "The Black One aka. Brapfanne, Walki1",
	description = "Black's Funcommands",
	version = "0.2a",
	url = "http://steamcommunity.com/groups/ZPSBallerbude"
}



public OnPluginStart()
{
    RegAdminCmd("sm_model", Command_Model, ADMFLAG_SLAY);
    RegAdminCmd("sm_ignite", Command_Ignite, ADMFLAG_SLAY);
    RegAdminCmd("sm_weapons", Command_Weapons, ADMFLAG_SLAY);
}

public OnMapStart()
{
    AddFileToDownloadsTable("zp_props/barrel/oildrum01.mdl");
    AddFileToDownloadsTable("zp_props/barrel/oildrum01.phy");
    AddFileToDownloadsTable("zp_props/barrel/oildrum01.vvd");
    AddFileToDownloadsTable("zp_props/barrel/oildrum01.dx80.vtx");
    AddFileToDownloadsTable("zp_props/barrel/oildrum01.dx90.vtx");
    AddFileToDownloadsTable("zp_props/barrel/oildrum01.sw.vtx");
    AddFileToDownloadsTable("materials/models/zp_props/barrel/oildrum01_diff1.vtf");
    AddFileToDownloadsTable("materials/models/zp_props/barrel/oildrum01_diff1.vmt");

    PrecacheModel("zp_props/barrel/oildrum01.mdl", false);
    PrecacheModel("props_c17/oildrum001.mdl", false);
    PrecacheModel("humans/group02/female_01.mdl", false);
    PrecacheModel("humans/group02/male_02.mdl", false);
    PrecacheModel("zombies/zombie1/zombie1.mdl", false);
    PrecacheModel("survivors/survivor1/survivor1.mdl", false);
}

public MenuHandle(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
        if (param2 == 0)
        {
            SetEntityModel(param1, "zp_props/barrel/oildrum01.mdl");
            PrintToChat(param1, "Your are now a barrel!");
        }
        else if (param2 == 1)
        {
            SetEntityModel(param1, "props_c17/oildrum001.mdl");
            PrintToChat(param1, "Your are now a oildrum!");
        }
        else if (param2 == 2)
        {
            SetEntityModel(param1, "humans/group02/female_01.mdl");
            PrintToChat(param1, "Your are now a female!");
        }
        else if (param2 == 3)
        {
            SetEntityModel(param1, "humans/group02/male_02.mdl");
            PrintToChat(param1, "Your are now a male!");
        }
        else if (param2 == 4)
        {
            SetEntityModel(param1, "zombies/zombie1/zombie1.mdl");
            PrintToChat(param1, "Your are now a zombie!");
        }
        else if (param2 == 5)
        {
            SetEntityModel(param1, "survivors/survivor1/survivor1.mdl");
            PrintToChat(param1, "Your are now a human!");
        }
	}
}

public Action:Command_Model(client, args)
{
    new Handle:menu = CreateMenu(MenuHandle);

    SetMenuTitle(menu, "Choose your model:");
    AddMenuItem(menu, "barrel", "Barrel");
    AddMenuItem(menu, "oildrum", "Oildrum");
    AddMenuItem(menu, "female", "Female");
    AddMenuItem(menu, "male", "Male");
    AddMenuItem(menu, "zombie", "Zombie");
    AddMenuItem(menu, "human", "Human");
    SetMenuExitButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);

    return Plugin_Handled;
}

public Action:Command_Ignite(client, args)
{
    new target = GetClientAimTarget(client, false);

    if (target > 0)
    {
        decl String:arg1[128];

        GetCmdArg(1, arg1, sizeof(arg1));

        new Float:number = StringToFloat(arg1);

        IgniteEntity(target, number, false, 0.0, false);
    }
    return Plugin_Handled;
}

public Action:Command_Weapons(client, args)
{
    GivePlayerItem(client, "weapon_ak47", 0);
    GivePlayerItem(client, "weapon_m4", 0);
    GivePlayerItem(client, "weapon_870", 0);
    GivePlayerItem(client, "weapon_ppk", 0);
    PrintToChat(client, "Gave you a lot of weapons");
}