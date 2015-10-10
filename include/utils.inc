/* utils.inc
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

#if defined _utils_included
#endinput
#endif

#define _utils_included

#if !defined _sourcemod_included
#include <sourcemod>
#endif

#if !defined QUERY
#define QUERY 255
#endif

stock bool:GetLocalServerConVar(const String:cvar[])
{
    // returns a ConsoleConVar as boolean

    new Handle:var = FindConVar(cvar);
    new bool:b_var = false;

    if (var != INVALID_HANDLE)
    {
        b_var = GetConVarBool(var);
        CloseHandle(var);
    }

    return b_var;
}

stock GetLocalServerInt(const String:cvar[])
{
    // returns a ConsoleConVar as Integer

    new Handle:var = FindConVar(cvar);
    new i_var = 0;
    
    if (var != INVALID_HANDLE)
    {
        i_var = GetConVarInt(var);
        CloseHandle(var);
    }
    
    return i_var;
}

stock Float:GetLocalServerFloat(const String:cvar[])
{
    // return a ConsoleConVar as Float

    new Handle:var = FindConVar(cvar);
    new Float:f_var = 0.0;

    if (var != INVALID_HANDLE)
    {
        f_var = GetConVarFloat(var);
        CloseHandle(var);
    }

    return f_var;
}

stock String:GetLocalServerString(const String:cvar[])
{
    // return a ConsoleConVar as String

    new Handle:var = FindConVar(cvar);
    new String:s_var[QUERY];

    if (var != INVALID_HANDLE)
    {
        GetConVarString(var, s_var, sizeof(s_var));
        CloseHandle(var);
    }

    return s_var;
}

