/* shop.sp 
 *
 * 2009; KillerSpieler
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

#include <sourcemod>
#include <sdktools>
#include <shop>

#pragma semicolon 1
#pragma tabsize 4

#define BBTEAM "Killerspieler, Walki"
#define VERSION "0.1a"
#define SLOTS 20
#define SIZE 50

new const pricem4 = 250;
new const priceak47 = 250;
new const pricemp5 = 200;
new const price870 = 200;
new const pricemagnum = 300;

stock players[SLOTS + 1];
stock money[SLOTS + 1];
// Timer fuer die ersten 30s fehlt noch

enum UserTeam
{
    SPECTATOR = 1,
    SURVIVORS = 2,
    UNDEAD = 3,
    NO_TEAM = 4
};

public Plugin:myinfo = 
{
    name = "Shop",
    author = BBTEAM,
    description = "Shop Plugin",
    version = VERSION,
    url = "http://steamcommunity.com/groups/ZPSBallerbude"
};

public OnPluginStart()
{
    RegConsoleCmd("sm_shop", Command_Shop, "Shop Plugin");
    RegConsoleCmd("sm_items", Command_Items, "Bought Weapons");

    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
    HookEvent("round_end", Event_RoundEnd, EventHookMode_Pre);
}

public OnClientDisconnect(client)
{
    if (IsClientInGame(client))
    {
        new Handle:db = db_Connect();
        
        if (db == INVALID_HANDLE)
        {
            return;
        }
        
        AddMoney(db, players[client], money[client]);
        CloseHandle(db);
    }
}

public OnClientAuthorized(client, const String:steamid[])
{
    if(!IsFakeClient(client))
    {
        new Handle:db = db_Connect();
        
        if (db == INVALID_HANDLE)
        {
            return;
        }
        
        new clientID = GetClientFromDB(db, steamid);

        if (clientID == -1)
        {
            //Add player to Database
            AddPlayer(db, steamid);
            clientID = GetClientFromDB(db, steamid);
        }
        
        CloseHandle(db);

        // Hier ins Array eintragen
        players[client] = clientID;
        money[client] = 0;
    }
}

public ShopHandle(Handle:menu, MenuAction:action, param1, param2)
{
    if (action == MenuAction_Select)
    {
        new Handle:db = db_Connect();
        
        if (db == INVALID_HANDLE)
        {
            return;
        }

        new const playerMoney = GetMoney(db, players[param1]);

        if (param2 == 1 && playerMoney > pricem4)
        {
            //Bought M4
            //GivePlayerItem(param1, weapon_m4, 0);
            RemoveMoney(db, players[param1], pricem4);
            new weaponID = GetWeaponID(db, "weapon_m4");
            
            if (weaponID > -1)
            {
                AddWeapon(db, players[param1], weaponID);
                PrintToChat(param1, "You bought a M4 assaultrifle. Type !items to use it.");
            }
        }
        else if (param2 == 2 && playerMoney > priceak47)
        {
            //Bought AK-47
            //GivePlayerItem(param1, weapon_ak47, 0);
            RemoveMoney(db, players[param1], priceak47);
            new weaponID = GetWeaponID(db, "weapon_ak47");
            
            if (weaponID > -1)
            {
                AddWeapon(db, players[param1], weaponID);
                PrintToChat(param1, "You bought a AK-47 assaultrifle. Type !items to use it.");
            }
        }
        else if (param2 == 3 && playerMoney > pricemp5)
        {
            //Bought MP5
            //GivePlayerItem(param1, weapon_mp5, 0);
            RemoveMoney(db, players[param1], pricemp5);
            new weaponID = GetWeaponID(db, "weapon_mp5");
            
            if (weaponID > -1)
            {
                AddWeapon(db, players[param1], weaponID);
                PrintToChat(param1, "You bought a MP5 machinepistol. Type !items to use it.");
            }
        }
        else if (param2 == 4 && playerMoney > price870)
        {
            //Bought shotgun
            //GivePlayerItem(param1, weapon_870, 0);
            RemoveMoney(db, players[param1], price870);
            new weaponID = GetWeaponID(db, "weapon_870");
            
            if (weaponID > -1)
            {
                AddWeapon(db, players[param1], weaponID);
                PrintToChat(param1, "You bought a 870 shotgun. Type !items to use it.");
            }
        }
        else if (param2 == 5 && playerMoney > pricemagnum)
        {
            //Bought magnum
            //GivePlayerItem(param1, weapon_revolver, 0);
            RemoveMoney(db, players[param1], pricemagnum);
            new weaponID = GetWeaponID(db, "weapon_revolver");
            
            if (weaponID > -1)
            {
                AddWeapon(db, players[param1], weaponID);
                PrintToChat(param1, "You bought a revolver. Type !items to use it.");
            }
        }
        else if (1 <= param2 <= 5)
        {
            PrintCenterText(param1, "Not enough money!");
        }
        CloseHandle(db);
    }
}

public Action:Command_Shop(client, args)
{
    new bankaccountbalance = 0;
    new Handle:db = db_Connect();

    if (db == INVALID_HANDLE)
    {
        return Plugin_Handled;
    }

    bankaccountbalance = GetMoney(db, players[client]);
    CloseHandle(db);

	new Handle:menu = CreateMenu(ShopHandle);
	SetMenuTitle(menu, "Welcome to the shop! Which weapon do you want to buy?");
	AddMenuItem(menu, "m4 assaultrifle (250$)", "M4 assaultrifle (250$)");
	AddMenuItem(menu, "ak-47 assaultrifle (250$)", "Ak-47 assaultrifle (250$)");
	AddMenuItem(menu, "mp5 machinepistol (200$)", "MP5 machinepistol (200$)");
	AddMenuItem(menu, "870 shotgun (200$)", "870 shotgun (200$)");
	AddMenuItem(menu, "Magnum revolover (300$)", "Magnum revolver (300$)");
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
    PrintToChat(client, "Your current bank account balance: %d$", bankaccountbalance);

    CloseHandle(menu);
    return Plugin_Handled;
}

// client = param1
// choosed option = param2
public ItemsHandle(Handle:menu, MenuAction:action, param1, param2)
{
    if (action == MenuAction_Select)
    {
        decl String:query[SQLSIZE];
        new Handle:db = db_Connect();
        new Handle:weapons = GetPlayerWeapons(db, players[param1]);
        new const endIndex = param2 - 1;
        
        for (new i = 0; i < param2; ++i)
        {
            if (!SQL_FetchRow(weapons))
            {
                CloseHandle(weapons);
                CloseHandle(db);
                PrintToChat(param1, "\x04[BOT]\x01 Unable to find selected weapon");
                return;
            }
        
            if (i == endIndex)
            {
                SQL_FetchString(weapons, 0, query, SQLSIZE);
                GivePlayerItem(param1, query);
            }
        }
        
        PrintToChat(param1, "\x04[BOT]\x01 Weapon %s has been successful spawned", query);
        CloseHandle(weapons);
        CloseHandle(db);
    }
}

public Action:Command_Items(client, args)
{
    decl String:query[SQLSIZE];
    new Handle:db = db_Connect();
    
    if (db == INVALID_HANDLE)
    {
        return Plugin_Handled;
    }
    
    new Handle:menu = CreateMenu(ItemsHandle);
    SetMenuTitle(menu, "Your inventory");
    new Handle:weapons = GetPlayerWeapons(db, players[client]);
    
    if (weapons == INVALID_HANDLE)
    {
        CloseHandle(db);
        CloseHandle(menu);
        return Plugin_Handled;
    }
    
    while (SQL_FetchRow(weapons))
    {
        SQL_FetchString(weapons, 0, query, SQLSIZE);
        AddMenuItem(menu, query, query);
    }
    
    CloseHandle(weapons);
    CloseHandle(db);
    SetMenuExitButton(menu, true);
    DisplayMenu(menu, client, MENU_TIME_FOREVER);
    CloseHandle(menu);
    return Plugin_Handled;
}

public Action:Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
    //Get killed player, attacker & the player's team.
    new const killedPlayer = GetClientOfUserId(GetEventInt(event, "userid"));
    new const assistant = GetClientOfUserId(GetEventInt(event, "assistant"));
    new const attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    new const UserTeam:killedPlayerteam = UserTeam:GetClientTeam(killedPlayer);

    //Get the weapon
    decl String:weapon[SIZE];
    GetEventString(event, "weapon", weapon, SIZE);

    if (GetClientTeam(assistant) != GetClientTeam(killedPlayer))
    {
        if (killedPlayerteam == UNDEAD)
        {
            if (StrEqual(weapon, "weapon_870") || StrEqual(weapon, "weapon_ak47")
                || StrEqual(weapon, "weapon_glock") || StrEqual(weapon, "weapon_glock18c")
                || StrEqual(weapon, "weapon_m4") || StrEqual(weapon, "weapon_mp5")
                || StrEqual(weapon, "weapon_ppk") || StrEqual(weapon, "weapon_revolver")
                || StrEqual(weapon, "weapon_supershorty") || StrEqual(weapon, "weapon_usp")
                || StrEqual(weapon, "weapon_winchester"))
            {
                //Firearmkill = 2$
                money[attacker] += 2;
                money[assistant]++;
                PrintCenterText(attacker, "+2$");
                PrintCenterText(assistant, "+1$");
            }
            else
            {
                //Knife, Grenade & IED kills = 3$
                money[attacker] += 3;
                money[assistant]++;
                PrintCenterText(attacker, "+3$");
                PrintCenterText(assistant, "+1$");
            }
        }
        else if (killedPlayerteam == SURVIVORS)
        {
            //Zombie killed Human
            money[attacker] += 4;
            money[assistant] += 2;
            PrintCenterText(attacker, "+4$");
            PrintCenterText(assistant, "+2$");
        }
    }
    
    return Plugin_Handled;
}

public Action:Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
    new const UserTeam:winnerTeam = UserTeam:GetEventInt(event, "winner");
    new Handle:db = INVALID_HANDLE;

    if (!(winnerTeam == SURVIVORS))
    {
        return Plugin_Handled;
    }
    
    db = db_Connect();
    
    if (db == INVALID_HANDLE)
    {
        return Plugin_Handled;
    }
    
    for (new i = 1; i <= SLOTS; ++i)
    {
        if (IsClientConnected(i))
        {
            new const UserTeam:playerTeam = UserTeam:GetClientTeam(i);

            if (playerTeam == SURVIVORS)
            {
                money[i] += 10;
            }
            
            AddMoney(db, players[i], money[i]);
        }
        
        money[i] = 0;
    }
    
    CloseHandle(db);

    return Plugin_Handled;
}
