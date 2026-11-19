/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

					Turfs System

				Next Generation Gaming, LLC
	(created by Next Generation Gaming Development Team)
					
	* Copyright (c) 2014, Next Generation Gaming, LLC
	*
	* All rights reserved.
	*
	* Redistribution and use in source and binary forms, with or without modification,
	* are not permitted in any case.
	*
	*
	* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	* "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	* LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
	* A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
	* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
	* EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
	* PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
	* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
	* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
	* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include <YSI_Coding\y_hooks>

SaveTurfWar(turfid)
{
	if(!(0 <= turfid < MAX_TURFS) || !TurfWars[turfid][twLoaded]) return 0;
	new data[512], query[1024];
	format(data, sizeof(data), "%s|%d|%d|%d|%d|%f|%f|%f|%f",
		TurfWars[turfid][twName], TurfWars[turfid][twOwnerId],
		TurfWars[turfid][twLocked], TurfWars[turfid][twSpecial], TurfWars[turfid][twVulnerable],
		TurfWars[turfid][twMinX], TurfWars[turfid][twMinY],
		TurfWars[turfid][twMaxX], TurfWars[turfid][twMaxY]);
		
	if(strlen(data) > 255) {
		printf("[Turf Wars] Cannot save turf row %d, data exceeds 255 characters.", turfid + 1);
		return 0;
	}
	mysql_format(MainPipeline, query, sizeof(query), "UPDATE `turfs` SET `data`='%e' WHERE `id`=%d", data, turfid + 1);
	mysql_tquery(MainPipeline, query, "OnQueryFinish", "i", SENDDATA_THREAD);
	return 1;
}

SaveTurfWars()
{
	for(new i; i < MAX_TURFS; i++) {
		if(TurfWars[i][twLoaded]) SaveTurfWar(i);
	}
}

forward OnLoadTurfWars();
public OnLoadTurfWars()
{
	new rows, loaded, id, tmp[256];
	cache_get_row_count(rows);
	for(new row; row < rows; ++row) {
		cache_get_value_name_int(row, "id", id);
		if(!(1 <= id <= MAX_TURFS)) {
			continue;
		}
		
		cache_get_value_name(row, "data", tmp, sizeof(tmp));
		new data[TurfWarsEnum], fields;
		for(new j; tmp[j]; ++j) if(tmp[j] == '|') ++fields;
		if(fields != 8 || sscanf(tmp, "p<|>s[64]iiiiffff", data[twName], data[twOwnerId], data[twLocked], data[twSpecial], data[twVulnerable], data[twMinX], data[twMinY], data[twMaxX], data[twMaxY])) {
			continue;
		}

		new bool:empty = data[twMinX] == 0.0 && data[twMinY] == 0.0 && data[twMaxX] == 0.0 && data[twMaxY] == 0.0;
		if(!(-2 <= data[twOwnerId] < MAX_GROUPS) || !(0 <= data[twLocked] <= 1) || !(0 <= data[twSpecial] <= 2) || data[twVulnerable] < 0 || (!empty && !(data[twMinX] < data[twMaxX] && data[twMinY] < data[twMaxY]))) {
			continue;
		}

		new slot = id - 1;
		data[twLoaded] = true;
		data[twAttemptId] = -1;
		data[twGangZoneId] = -1;
		data[twAreaId] = -1;
		data[twFlash] = -1;
		TurfWars[slot] = data;
		if(!CreateTurfWarsZone(0, slot)) {
			printf("[Turf Wars] Could not create the area for turf row %d.", id);
		}
		++loaded;
	}
	printf("[LoadTurfWars] %d turf rows loaded.", loaded);
	return 1;
}

stock LoadTurfWars()
{
	printf("[Turf Wars] Loading turfs from the database, please wait...");
	mysql_tquery(MainPipeline, "SELECT `id`, `data` FROM `turfs` ORDER BY `id`", "OnLoadTurfWars");
}

InitTurfWars()
{
	for(new i; i < MAX_TURFS; ++i) {
		TurfWars[i][twLoaded] = false;
		TurfWars[i][twOwnerId] = -1;
		TurfWars[i][twActive] = 0;
		TurfWars[i][twLocked] = 0;
		TurfWars[i][twSpecial] = 0;
		TurfWars[i][twTimeLeft] = 0;
		TurfWars[i][twVulnerable] = 12;
		TurfWars[i][twAttemptId] = -1;
		TurfWars[i][twGangZoneId] = -1;
		TurfWars[i][twAreaId] = -1;
		TurfWars[i][twFlash] = -1;
		TurfWars[i][twFlashColor] = 0;
	}
	return 1;
}

CreateTurfWarsZone(forcesync, zone)
{
	if(!(0 <= zone < MAX_TURFS) || !TurfWars[zone][twLoaded]) return 0;
	if(TurfWars[zone][twMinX] == 0.0 && TurfWars[zone][twMinY] == 0.0 && TurfWars[zone][twMaxX] == 0.0 && TurfWars[zone][twMaxY] == 0.0)
	{
		return 1;
	}
	if(!(TurfWars[zone][twMinX] < TurfWars[zone][twMaxX] && TurfWars[zone][twMinY] < TurfWars[zone][twMaxY])) 
	{
		return 0;
	}
	new gangzone = GangZoneCreate(TurfWars[zone][twMinX], TurfWars[zone][twMinY], TurfWars[zone][twMaxX], TurfWars[zone][twMaxY]);
	if(gangzone == -1) return 0;
	new area = CreateDynamicRectangle(TurfWars[zone][twMinX], TurfWars[zone][twMinY], TurfWars[zone][twMaxX], TurfWars[zone][twMaxY], -1, -1, -1);
	if(!IsValidDynamicArea(area)) {
		GangZoneDestroy(gangzone);
		return 0;
	}
	if(IsValidGangZone(TurfWars[zone][twGangZoneId])) GangZoneDestroy(TurfWars[zone][twGangZoneId]);
	if(IsValidDynamicArea(TurfWars[zone][twAreaId])) DestroyDynamicArea(TurfWars[zone][twAreaId]);
	TurfWars[zone][twGangZoneId] = gangzone;
	TurfWars[zone][twAreaId] = area;
	if(forcesync) SyncTurfWarsRadarToAll(zone);
	return 1;
}

ResetTurfWarsZone(forcesync, zone)
{
	if(!(0 <= zone < MAX_TURFS) || !TurfWars[zone][twLoaded]) return 0;
	TurfWars[zone][twActive] = 0;
	TurfWars[zone][twFlash] = -1;
	TurfWars[zone][twFlashColor] = 0;
	TurfWars[zone][twTimeLeft] = 0;
	TurfWars[zone][twAttemptId] = -1;

	if(forcesync) {
	    SyncTurfWarsRadarToAll(zone);
	}

	SaveTurfWar(zone);
	return 1;
}

SetOwnerTurfWarsZone(forcesync, zone, ownerid)
{
	if(!(0 <= zone < MAX_TURFS) || !TurfWars[zone][twLoaded] || !(-2 <= ownerid < MAX_GROUPS)) return 0;
	TurfWars[zone][twOwnerId] = ownerid;

	if(forcesync) {
	    SyncTurfWarsRadarToAll(zone);
	}

	SaveTurfWar(zone);
	return 1;
}

DestroyTurfWarsZone(zone)
{
	if(!(0 <= zone < MAX_TURFS) || !TurfWars[zone][twLoaded]) return 0;
	TurfWars[zone][twActive] = 0;

	if(TurfWars[zone][twGangZoneId] != -1) {
	    GangZoneDestroy(TurfWars[zone][twGangZoneId]);
	}

	if(TurfWars[zone][twAreaId] != -1) {
	    if(IsValidDynamicArea(TurfWars[zone][twAreaId])) DestroyDynamicArea(TurfWars[zone][twAreaId]);
	}

	TurfWars[zone][twMinX] = 0;
	TurfWars[zone][twMinY] = 0;
	TurfWars[zone][twMaxX] = 0;
	TurfWars[zone][twMaxY] = 0;
 	TurfWars[zone][twOwnerId] = -1;
	TurfWars[zone][twGangZoneId] = -1;
	TurfWars[zone][twAreaId] = -1;
	TurfWars[zone][twFlash] = -1;
	TurfWars[zone][twFlashColor] = 0;
	TurfWars[zone][twActive] = 0;
 	TurfWars[zone][twLocked] = 0;
 	TurfWars[zone][twSpecial] = 0;
 	TurfWars[zone][twTimeLeft] = 0;
 	TurfWars[zone][twAttemptId] = -1;
	TurfWars[zone][twVulnerable] = 12;

	SyncTurfWarsRadarToAll(zone);
	SaveTurfWar(zone);

	return 1;
}

GetPlayerTurfWarsZone(playerid)
{
	for(new i = 0; i < MAX_TURFS; i++) {
		if(TurfWars[i][twLoaded] && TurfWars[i][twAreaId] != -1 && IsPlayerInDynamicArea(playerid, TurfWars[i][twAreaId])) {
			return i;
		}
	}
	return -1;
}

ShutdownTurfWarsZone(zone)
{
	if(!(0 <= zone < MAX_TURFS) || !TurfWars[zone][twLoaded]) return 0;
	foreach(new i: Player)
	{
		if(IsPlayerInDynamicArea(i, TurfWars[zone][twAreaId])) {
			SendClientMessageEx(i,COLOR_YELLOW,"Law Enforcement has attempted to shutdown this turf!");
		}
	}	

	TurfWars[zone][twActive] = 1;
	if(TurfWars[zone][twSpecial] != 2) {
		TurfWars[zone][twTimeLeft] = 300;
	} else {
		TurfWars[zone][twTimeLeft] = 600;
	}
	TurfWars[zone][twVulnerable] = 0;
	TurfWars[zone][twAttemptId] = -2;
	TurfWars[zone][twFlash] = 1;
	TurfWars[zone][twFlashColor] = 0;

	SyncTurfWarsRadarToAll(zone);

	SaveTurfWar(zone);
	return 1;
}

TakeoverTurfWarsZone(iGroupID, zone)
{
	if(!(0 <= zone < MAX_TURFS) || !TurfWars[zone][twLoaded] || !ValidGroup(iGroupID)) return 0;
	foreach(new i: Player)
	{
		if(IsPlayerInDynamicArea(i, TurfWars[zone][twAreaId])) {
			SendClientMessageEx(i,COLOR_YELLOW,"%s has attempted to takeover this turf for their own!",arrGroupData[iGroupID][g_szGroupName]);
		}
	}	

	TurfWars[zone][twActive] = 1;
	if(TurfWars[zone][twSpecial] != 2) {
		TurfWars[zone][twTimeLeft] = 300;
	} else {
		TurfWars[zone][twTimeLeft] = 600;
	}
	TurfWars[zone][twVulnerable] = 0;
	TurfWars[zone][twAttemptId] = iGroupID;
	TurfWars[zone][twFlash] = 1;
	TurfWars[zone][twFlashColor] = arrGroupData[iGroupID][g_hDutyColour];

	SyncTurfWarsRadarToAll(zone);
	return 1;
}

CaptureTurfWarsZone(iGroupID, zone)
{
	if(!(0 <= zone < MAX_TURFS) || !TurfWars[zone][twLoaded] || (iGroupID != -2 && !ValidGroup(iGroupID))) 
	{
		return 0;
	}

	foreach(new i: Player)
	{
	    if(turfWarsMiniMap[i] == 1)
		{
			turfWarsMiniMap[i] = 0;
			SetPlayerToTeamColor(i);
		}
		if(IsPlayerInDynamicArea(i, TurfWars[zone][twAreaId])) {
		    if((0 <= iGroupID < MAX_GROUPS)) {
				SendClientMessageEx(i,COLOR_RED,"%s has successfully claimed this turf for their own!",arrGroupData[iGroupID][g_szGroupName]);
				//SendAudioToPlayer(i, 62, 100);
			}
			else {
				SendClientMessageEx(i,COLOR_RED,"Law Enforcement has successfully shut down this turf!");
			}
		}
		if(PlayerInfo[i][pGangModerator] >= 1) {
		    if((0 <= iGroupID < MAX_GROUPS)) {
				SendClientMessageEx(i,COLOR_RED,"%s has successfully claimed turf %d",arrGroupData[iGroupID][g_szGroupName], zone);
			}
			else {
				SendClientMessageEx(i,COLOR_RED,"Law Enforcement has successfully shut down turf %d", zone);
			}
		}	
	}
	if(TurfWars[zone][twOwnerId] != -2) {
		if((0 <= iGroupID < MAX_GROUPS)) {
			TurfWars[zone][twOwnerId] = iGroupID;
		} else {
			TurfWars[zone][twOwnerId] = -1;
		}
	}
	return 1;
}

ExtortionTurfsWarsZone(playerid, type, money)
{
	if(GetPlayerInterior(playerid) != 0 || money <= 0) return 1;
	new tw = GetPlayerTurfWarsZone(playerid);
	if(tw == -1) return 1;
	new ownerid = TurfWars[tw][twOwnerId], tax = money / 4;
	if(!ValidGroup(ownerid) || PlayerInfo[playerid][pMember] == ownerid || tax == 0) return 1;
	if(GetPlayerCash(playerid) < tax || arrGroupData[ownerid][g_iBudget] > cellmax - tax) return 0;
	new szItemName[32];
	switch(type) {
		case 1: szItemName = "drugs";
		case 2: szItemName = "vests";
		case 3: szItemName = "weapons";
		case 4: szItemName = "yourself";
		case 5: szItemName = "fireworks";
		case 6: szItemName = "sex";
		case 7: szItemName = "items";
		default: return 0;
	}
	arrGroupData[ownerid][g_iBudget] += tax;
	GivePlayerCash(playerid, -tax);
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* You have been taxed $%d for selling %s on %s's turf.", tax, szItemName, arrGroupData[ownerid][g_szGroupName]);
	return 1;
}

ShowTurfWarsRadar(playerid)
{
	if(turfWarsRadar[playerid] == 1) { return 1; }
	turfWarsRadar[playerid] = 1;
	SyncTurfWarsRadar(playerid);
    return 1;
}

HideTurfWarsRadar(playerid)
{
	if(turfWarsRadar[playerid] == 0) { return 1; }
	for(new i = 0; i < MAX_TURFS; i++) {
	    if(TurfWars[i][twGangZoneId] != -1) {
	    	GangZoneHideForPlayer(playerid,TurfWars[i][twGangZoneId]);
		}
	}
	turfWarsRadar[playerid] = 0;
	return 1;
}

SyncTurfWarsRadarToAll(zone = -1)
{
	foreach(new i: Player) SyncTurfWarsRadar(i, zone);
}

SyncTurfWarsRadar(playerid, zone = -1)
{
	if(turfWarsRadar[playerid] == 0 || zone < -1 || zone >= MAX_TURFS) return 1;
	new first = zone == -1 ? 0 : zone, last = zone == -1 ? MAX_TURFS : zone + 1;
	for(new i = first; i < last; ++i) {
		if(!TurfWars[i][twLoaded] || TurfWars[i][twGangZoneId] == -1) continue;
		new ownerid = TurfWars[i][twOwnerId];
		if(ValidGroup(ownerid)) 
		{
			GangZoneShowForPlayer(playerid, TurfWars[i][twGangZoneId], arrGroupData[ownerid][g_hDutyColour] * 256 + 170);
		}
		else 
		{
			GangZoneShowForPlayer(playerid, TurfWars[i][twGangZoneId], COLOR_BLACK);
		}

		if(TurfWars[i][twFlash] == 1) 
		{
			GangZoneFlashForPlayer(playerid, TurfWars[i][twGangZoneId], TurfWars[i][twFlashColor] * 256 + 170);
		}
		else 
		{
			GangZoneStopFlashForPlayer(playerid, TurfWars[i][twGangZoneId]);
		}
	}
	return 1;
}

TurfWarsEditTurfsSelection(playerid)
{
	szMiscArray[0] = 0;
	for(new i = 0; i < MAX_TURFS; i++)
	{
		if(!TurfWars[i][twLoaded]) {
			format(szMiscArray, sizeof(szMiscArray), "%s%d) (Unavailable row)\n", szMiscArray, i);
		}
		else if(TurfWars[i][twOwnerId] == -2) {
			format(szMiscArray, sizeof(szMiscArray), "%s%d) (Law Enforcement)\n", szMiscArray, i);
		}
		else if(TurfWars[i][twOwnerId] != -1)
		{
			if(TurfWars[i][twOwnerId] < 0 || TurfWars[i][twOwnerId] >= MAX_GROUPS)
			{
				format(szMiscArray,sizeof(szMiscArray),"%s%d) (Invalid Group)\n",szMiscArray,i/*,TurfWars[i][twName]*/);
			}
			else
			{
				format(szMiscArray,sizeof(szMiscArray),"%s%d) (%s)\n",szMiscArray,i,/*TurfWars[i][twName],*/arrGroupData[TurfWars[i][twOwnerId]][g_szGroupName]);
			}
		}
		else
		{
			format(szMiscArray,sizeof(szMiscArray),"%s%d) (%s)\n",szMiscArray,i,/*TurfWars[i][twName],*/"Vacant");
		}
	}
	ShowPlayerDialogEx(playerid,TWEDITTURFSSELECTION,DIALOG_STYLE_LIST,"Turf Wars - Edit Turfs Selection Menu:",szMiscArray,"Select","Back");
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	switch(dialogid) 
	{
		case TWADMINMENU, TWEDITTURFSSELECTION, TWEDITTURFSMENU, TWEDITTURFSOWNER, TWEDITTURFSLOCKED, TWEDITTURFSVUL, TWEDITTURFSPERKS: 
		{
			if(PlayerInfo[playerid][pAdmin] <= 3 && PlayerInfo[playerid][pGangModerator] < 1) return 1;
			if(dialogid != TWADMINMENU && dialogid != TWEDITTURFSSELECTION) 
			{
				new tw = GetPVarInt(playerid, "EditingTurfs");
				if(!GetPVarType(playerid, "EditingTurfs") || !(0 <= tw < MAX_TURFS) || !TurfWars[tw][twLoaded]) return 1;
			}
		}
	}

	szMiscArray[0] = 0;
	switch(dialogid)
	{
		case TWADMINMENU: // Turf Wars System
		{
			if(response == 1)
			{
				switch(listitem)
				{
					case 0:
					{
						TurfWarsEditTurfsSelection(playerid);
					}
					/*case 1:
					{
						TurfWarsEditFColorsSelection(playerid);
					}*/
				}
			}
		}
		case TWEDITTURFSSELECTION:
		{
			if(!response) return 1;
			if(!(0 <= listitem < MAX_TURFS) || !TurfWars[listitem][twLoaded])
				return SendClientMessageEx(playerid, COLOR_GRAD2, "This turf row is unavailable. Check the database and loading log.");
			
			DeletePVar(playerid, "EditingTurfsStage");
			SetPVarInt(playerid, "EditingTurfs", listitem);
			ShowPlayerDialogEx(playerid,TWEDITTURFSMENU,DIALOG_STYLE_LIST,"Turf Wars - Edit Turfs Menu:","Edit Dimensions...\nEdit Owners...\nEdit Vulnerable Time...\nEdit Locked...\nEdit Perks...\nReset War...\nDestroy Turf","Select","Back");
		}
		case TWEDITTURFSMENU:
		{
			if(response == 1)
			{
				new tw = GetPVarInt(playerid, "EditingTurfs");
				switch(listitem)
				{
					case 0: // Edit Dim
					{
						SetPVarInt(playerid, "EditingTurfsStage", 1);
						SendClientMessageEx(playerid, COLOR_WHITE, "Goto a location and type (/savetwpos) to edit the West Wall.");
					}
					case 1: // Edit Owner
					{
						ShowPlayerDialogEx(playerid,TWEDITTURFSOWNER,DIALOG_STYLE_INPUT,"Turf Wars - Edit Turfs Owner Menu:","Please enter a group ID that you wish to assign to this turf:\n\nHint: Enter -1 if you wish to vacant the turf.","Change","Back");
					}
					case 2: // Edit Vulnerablity
					{
						ShowPlayerDialogEx(playerid,TWEDITTURFSVUL,DIALOG_STYLE_INPUT,"Turf Wars - Edit Turfs Vulnerable Menu:","Please enter a Vulnerable countdown time for the turf:","Change","Back");
					}
					case 3: // Edit Locks
					{
						ShowPlayerDialogEx(playerid,TWEDITTURFSLOCKED,DIALOG_STYLE_LIST,"Turf Wars - Edit Turfs Locked Menu:","Lock\nUnlock","Change","Back");
					}
					case 4: // Edit Perks
					{
						ShowPlayerDialogEx(playerid,TWEDITTURFSPERKS,DIALOG_STYLE_LIST,"Turf Wars - Edit Turfs Perks Menu:","None\nExtortion\nDrugs","Change","Back");
					}
					case 5: // Reset War
					{
						ResetTurfWarsZone(1, tw);
						TurfWarsEditTurfsSelection(playerid);
					}
					case 6: // Destroy Turf
					{
						DestroyTurfWarsZone(tw);
						TurfWarsEditTurfsSelection(playerid);
					}
				}
			}
			else
			{
				TurfWarsEditTurfsSelection(playerid);
			}
		}
		case TWEDITTURFSOWNER:
		{
			if(response == 1)
			{
				new tw = GetPVarInt(playerid, "EditingTurfs");
				if(isnull(inputtext))
				{
					ShowPlayerDialogEx(playerid,TWEDITTURFSOWNER,DIALOG_STYLE_INPUT,"Turf Wars - Edit Turfs Owner Menu:","Please enter a group ID that you wish to assign to this turf:\n\nHint: Enter -1 if you wish to vacant the turf.","Change","Back");
					return 1;
				}
				if((strcmp(inputtext, "-1") != 0 && !IsNumericString(inputtext)) || strlen(inputtext) > 2 || strval(inputtext) < -1 || strval(inputtext) >= MAX_GROUPS)
				{
					ShowPlayerDialogEx(playerid,TWEDITTURFSOWNER,DIALOG_STYLE_INPUT,"Turf Wars - Edit Turfs Owner Menu:","Please enter a group ID that you wish to assign to this turf:\n\nHint: Enter -1 if you wish to vacant the turf.","Change","Back");
					return 1;
				}
				SetOwnerTurfWarsZone(1, tw, strval(inputtext));
				ShowPlayerDialogEx(playerid,TWEDITTURFSMENU,DIALOG_STYLE_LIST,"Turf Wars - Edit Turfs Menu:","Edit Dimensions...\nEdit Owners...\nEdit Vulnerable Time...\nEdit Locked...\nEdit Perks...\nReset War...\nDestroy Turf","Select","Back");
			}
			else
			{
				ShowPlayerDialogEx(playerid,TWEDITTURFSMENU,DIALOG_STYLE_LIST,"Turf Wars - Edit Turfs Menu:","Edit Dimensions...\nEdit Owners...\nEdit Vulnerable Time...\nEdit Locked...\nEdit Perks...\nReset War...\nDestroy Turf","Select","Back");
			}
		}
		case TWEDITTURFSVUL:
		{
			if(response == 1)
			{
				new tw = GetPVarInt(playerid, "EditingTurfs");
				if(isnull(inputtext))
				{
					ShowPlayerDialogEx(playerid,TWEDITTURFSVUL,DIALOG_STYLE_INPUT,"Turf Wars - Edit Turfs Vulnerable Menu:","Please enter a Vulnerable countdown time for the turf:","Change","Back");
					return 1;
				}
				if(!IsNumericString(inputtext) || strlen(inputtext) > 10 || (strlen(inputtext) == 10 && strcmp(inputtext, "2147483647") > 0))
				{
					ShowPlayerDialogEx(playerid,TWEDITTURFSVUL,DIALOG_STYLE_INPUT,"Turf Wars - Edit Turfs Vulnerable Menu:","Please enter a Vulnerable countdown time for the turf:","Change","Back");
					return 1;
				}
				TurfWars[tw][twVulnerable] = strval(inputtext);
				SaveTurfWar(tw);
				ShowPlayerDialogEx(playerid,TWEDITTURFSMENU,DIALOG_STYLE_LIST,"Turf Wars - Edit Turfs Menu:","Edit Dimensions...\nEdit Owners...\nEdit Vulnerable Time...\nEdit Locked...\nEdit Perks...\nReset War...\nDestroy Turf","Select","Back");
			}
			else
			{
				ShowPlayerDialogEx(playerid,TWEDITTURFSMENU,DIALOG_STYLE_LIST,"Turf Wars - Edit Turfs Menu:","Edit Dimensions...\nEdit Owners...\nEdit Vulnerable Time...\nEdit Locked...\nEdit Perks...\nReset War...\nDestroy Turf","Select","Back");
			}
		}
		case TWEDITTURFSLOCKED:
		{
			if(response == 1)
			{
				new tw = GetPVarInt(playerid, "EditingTurfs");
				switch(listitem)
				{
					case 0: // Lock
					{
						TurfWars[tw][twLocked] = 1;
						SaveTurfWar(tw);
						ShowPlayerDialogEx(playerid,TWEDITTURFSMENU,DIALOG_STYLE_LIST,"Turf Wars - Edit Turfs Menu:","Edit Dimensions...\nEdit Owners...\nEdit Vulnerable Time...\nEdit Locked...\nEdit Perks...\nReset War...\nDestroy Turf","Select","Back");
					}
					case 1: // Unlock
					{
						TurfWars[tw][twLocked] = 0;
						SaveTurfWar(tw);
						ShowPlayerDialogEx(playerid,TWEDITTURFSMENU,DIALOG_STYLE_LIST,"Turf Wars - Edit Turfs Menu:","Edit Dimensions...\nEdit Owners...\nEdit Vulnerable Time...\nEdit Locked...\nEdit Perks...\nReset War...\nDestroy Turf","Select","Back");
					}
				}
			}
			else
			{
				ShowPlayerDialogEx(playerid,TWEDITTURFSMENU,DIALOG_STYLE_LIST,"Turf Wars - Edit Turfs Menu:","Edit Dimensions...\nEdit Owners...\nEdit Vulnerable Time...\nEdit Locked...\nEdit Perks...\nReset War...\nDestroy Turf","Select","Back");
			}
		}
		case TWEDITTURFSPERKS:
		{
			if(response == 1)
			{
				new tw = GetPVarInt(playerid, "EditingTurfs");
				if(!(0 <= listitem <= 2)) return 1;
				TurfWars[tw][twSpecial] = listitem;
				SaveTurfWar(tw);
				ShowPlayerDialogEx(playerid,TWEDITTURFSMENU,DIALOG_STYLE_LIST,"Turf Wars - Edit Turfs Menu:","Edit Dimensions...\nEdit Owners...\nEdit Vulnerable Time...\nEdit Locked...\nEdit Perks...\nReset War...\nDestroy Turf","Select","Back");
			}
			else
			{
				ShowPlayerDialogEx(playerid,TWEDITTURFSMENU,DIALOG_STYLE_LIST,"Turf Wars - Edit Turfs Menu:","Edit Dimensions...\nEdit Owners...\nEdit Vulnerable Time...\nEdit Locked...\nEdit Perks...\nReset War...\nDestroy Turf","Select","Back");
			}
		}
	}
	return 0;
}

CMD:turfinfo(playerid, params[])
{
    new tw = GetPlayerTurfWarsZone(playerid);
    if(tw != -1) {
        new string[128];
        SendClientMessageEx(playerid, COLOR_GREEN, "|___________ (ID: %d) %s ___________|",tw,TurfWars[tw][twName]);
        if(TurfWars[tw][twOwnerId] == -1) {
            format(string,sizeof(string),"Owner: Vacant.");
        }
        else if(TurfWars[tw][twOwnerId] == -2) {
            format(string,sizeof(string),"Owner: Law Enforcement.");
        }
        else if(ValidGroup(TurfWars[tw][twOwnerId])) {
            format(string,sizeof(string),"Owner: %s.",arrGroupData[TurfWars[tw][twOwnerId]][g_szGroupName]);
        }
        SendClientMessageEx(playerid, COLOR_WHITE, string);
        SendClientMessageEx(playerid, COLOR_WHITE, "Vulnerable: %d Hours.",TurfWars[tw][twVulnerable]);
        SendClientMessageEx(playerid, COLOR_WHITE, "Locked: %d.",TurfWars[tw][twLocked]);
        SendClientMessageEx(playerid, COLOR_WHITE, "Active: %d.",TurfWars[tw][twActive]);
        if(TurfWars[tw][twActive] != 0) {
            SendClientMessageEx(playerid, COLOR_WHITE, "Time Left: %d Secs.",TurfWars[tw][twTimeLeft]);
            if(TurfWars[tw][twAttemptId] == -2) {
                SendClientMessageEx(playerid, COLOR_WHITE, "Takeover Faction: Law Enforcement.");
            }
            else if(ValidGroup(TurfWars[tw][twAttemptId])) {
                SendClientMessageEx(playerid, COLOR_WHITE, "Takeover Family: %s.",arrGroupData[TurfWars[tw][twAttemptId]][g_szGroupName]);
            }
        }
        switch(TurfWars[tw][twSpecial]) {
            case 1:
            {
                format(string,sizeof(string),"Special Perks: Extortion.");
            }
            case 2:
            {
            	format(string,sizeof(string),"Special Perks: Drugs.");
            }
            default:
            {
                format(string,sizeof(string),"Special Perks: None.");
            }
        }
        SendClientMessageEx(playerid, COLOR_WHITE, string);
    }
    else {
        SendClientMessageEx(playerid, COLOR_WHITE, "You are not in a turf!");
    }
    return 1;
}

CMD:savetwpos(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] > 3 || PlayerInfo[playerid][pGangModerator] >= 1) {
        new string[128];
        new tw = GetPVarInt(playerid, "EditingTurfs");
        new stage = GetPVarInt(playerid, "EditingTurfsStage");
        new Float:x, Float: y, Float: z;
        new Float:tminx, Float: tminy, Float: tmaxx, Float: tmaxy;
        GetPlayerPos(playerid, x, y, z);
        if(!GetPVarType(playerid, "EditingTurfs") || !(0 <= tw < MAX_TURFS) || !TurfWars[tw][twLoaded] || !(1 <= stage <= 4)) {
            SendClientMessageEx(playerid, COLOR_GRAD2, "You are not editing any Turf Dimensions right now!");
            return 1;
        }
        else {
            switch(stage) {
                case 1:
                {
                    SetPVarFloat(playerid, "EditingTurfsMinX", x);
                    format(string,sizeof(string),"X=%f, Y=%f, Z=%f",x,y,z);
                    SendClientMessageEx(playerid, COLOR_WHITE, "You have successfully edited Turf West Wall.");
                    SendClientMessageEx(playerid, COLOR_GRAD2, string);
                    SendClientMessageEx(playerid, COLOR_WHITE, "Goto a location and type (/savetwpos) to edit the South Wall.");
                    SetPVarInt(playerid, "EditingTurfsStage", 2);
                }
                case 2:
                {
                    SetPVarFloat(playerid, "EditingTurfsMinY", y);
                    format(string,sizeof(string),"X=%f, Y=%f, Z=%f",x,y,z);
                    SendClientMessageEx(playerid, COLOR_WHITE, "You have successfully edited Turf South Wall.");
                    SendClientMessageEx(playerid, COLOR_GRAD2, string);
                    SendClientMessageEx(playerid, COLOR_WHITE, "Goto a location and type (/savetwpos) to edit the East Wall.");
                    SetPVarInt(playerid, "EditingTurfsStage", 3);
                }
                case 3:
                {
                    SetPVarFloat(playerid, "EditingTurfsMaxX", x);
                    format(string,sizeof(string),"X=%f, Y=%f, Z=%f",x,y,z);
                    SendClientMessageEx(playerid, COLOR_WHITE, "You have successfully edited Turf East Wall.");
                    SendClientMessageEx(playerid, COLOR_GRAD2, string);
                    SendClientMessageEx(playerid, COLOR_WHITE, "Goto a location and type (/savetwpos) to edit the North Wall.");
                    SetPVarInt(playerid, "EditingTurfsStage", 4);
                }
                case 4:
                {
                    SetPVarFloat(playerid, "EditingTurfsMaxY", y);
                    tminx = GetPVarFloat(playerid, "EditingTurfsMinX");
                    tminy = GetPVarFloat(playerid, "EditingTurfsMinY");
                    tmaxx = GetPVarFloat(playerid, "EditingTurfsMaxX");
                    tmaxy = GetPVarFloat(playerid, "EditingTurfsMaxY");
                    if(!(tminx < tmaxx && tminy < tmaxy))
                        return SendClientMessageEx(playerid, COLOR_GRAD2, "The west wall must be west of the east wall, and the south wall south of the north wall. Restart dimension editing.");
                    
					new Float:oldPos[4];
                    oldPos[0] = TurfWars[tw][twMinX];
                    oldPos[1] = TurfWars[tw][twMinY];
                    oldPos[2] = TurfWars[tw][twMaxX];
                    oldPos[3] = TurfWars[tw][twMaxY];
                    TurfWars[tw][twMinX] = tminx;
                    TurfWars[tw][twMinY] = tminy;
                    TurfWars[tw][twMaxX] = tmaxx;
                    TurfWars[tw][twMaxY] = tmaxy;
                    if(!CreateTurfWarsZone(1, tw)) {
                        TurfWars[tw][twMinX] = oldPos[0];
                        TurfWars[tw][twMinY] = oldPos[1];
                        TurfWars[tw][twMaxX] = oldPos[2];
                        TurfWars[tw][twMaxY] = oldPos[3];
                        return SendClientMessageEx(playerid, COLOR_GRAD2, "Unable to create the turf area. The existing turf was preserved.");
                    }
                    SaveTurfWar(tw);
                    DeletePVar(playerid, "EditingTurfsStage");
                    DeletePVar(playerid, "EditingTurfsMinX");
                    DeletePVar(playerid, "EditingTurfsMinY");
                    DeletePVar(playerid, "EditingTurfsMaxX");
                    DeletePVar(playerid, "EditingTurfsMaxY");
                    SendClientMessageEx(playerid, COLOR_WHITE, "You have successfully re-created turf %d, %s.", tw, TurfWars[tw][twName]);
                    ShowPlayerDialogEx(playerid,TWEDITTURFSMENU,DIALOG_STYLE_LIST,"Turf Wars - Edit Turfs Menu:","Edit Dimensions...\nEdit Owners...\nEdit Vulnerable Time...\nEdit Locked...\nEdit Perks...\nReset War...\nDestroy Turf","Select","Back");
                }
            }
        }
    }
    else {
        SendClientMessageEx(playerid, COLOR_GRAD2, "You are not authorized to use this command!");
    }
    return 1;
}

CMD:twmenu(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] > 3 || PlayerInfo[playerid][pGangModerator] >= 1)
	{
        ShowPlayerDialogEx(playerid,TWADMINMENU,DIALOG_STYLE_LIST,"Turf Wars - Admin Menu:","Edit Turfs...","Select","Exit");
    }
    else
	{
        SendClientMessageEx(playerid, COLOR_GRAD2, "You are not authorized to use this command!");
    }
    return 1;
}

CMD:turfs(playerid, params[])
{
    if(turfWarsRadar[playerid] == 0) {
        SendClientMessageEx(playerid, COLOR_WHITE, "You have enabled the Turf Minimap Radar.");
        ShowTurfWarsRadar(playerid);
    }
    else {
        SendClientMessageEx(playerid, COLOR_WHITE, "You have disabled the Turf Minimap Radar.");
        HideTurfWarsRadar(playerid);
    }
    return 1;
}

CMD:shutdown(playerid, params[])
{
    if(IsACop(playerid)) {
        new tw = GetPlayerTurfWarsZone(playerid);
        new rank = PlayerInfo[playerid][pRank];
        if(rank < arrGroupData[PlayerInfo[playerid][pMember]][g_iTurfCapRank]) {
            SendClientMessageEx(playerid, COLOR_GRAD2, "You cannot shutdown turfs because of your rank!");
            return 1;
        }
        if(tw != -1) {
            if(TurfWars[tw][twLocked] == 1) {
                SendClientMessageEx(playerid, COLOR_GRAD2, "The turf is currently locked by a admin, you can not shutdown the turf!");
                return 1;
            }
            if(TurfWars[tw][twVulnerable] == 0) {
                if(TurfWars[tw][twActive] == 0) {
                    SendClientMessageEx(playerid, COLOR_GRAD2, "The turf isn't in a active turf war, you have no reason to shutdown the turf!");
                }
                else {
                    new count = 0; 
                    if(TurfWars[tw][twAttemptId] == -2) {
                        SendClientMessageEx(playerid, COLOR_GRAD2, "The LEO Factions are already attempting to shutdown the turf war!");
                        return 1;
                    }

                    foreach(new i: Player)
					{
						if(TurfWars[tw][twAttemptId] == PlayerInfo[i][pMember]) {
							if(GetPlayerTurfWarsZone(i) == tw && GetPVarInt(i, "Injured") != 1) {
								count++;
							}
						}
					}	
                    if(count != 0) {
                        SendClientMessageEx(playerid, COLOR_GRAD2, "There is still %d Attacking Members on the Turf, you must get rid of them before shuting down!",count);
                    }
                    else {
                        ShutdownTurfWarsZone(tw);
                    }
                }
            }
            else {
                SendClientMessageEx(playerid, COLOR_GRAD2, "This turf is currently not vulnerable, you are unable to shutdown!");
                SendClientMessageEx(playerid, COLOR_GRAD1, "If you are in FBI, You must contact a admin to lock down the turf with a IC Casefile.");
            }
        }
        else {
            SendClientMessageEx(playerid, COLOR_GRAD2, "You have to be in a turf to be able to shutdown turfs!");
        }
    }
    else {
        SendClientMessageEx(playerid, COLOR_GRAD2, "You are not in a LEO Faction, you can not shutdown turfs!");
    }
	return 1;
}

CMD:claim(playerid, params[])
{
	SendClientMessageEx(playerid, COLOR_GRAD2, "Command has been changed to /claimturf");
	return 1;
}

CMD:claimturf(playerid, params[])
{
	if(servernumber == 2)
	{
	    SendClientMessage(playerid, COLOR_WHITE, "This command is disabled!");
	    return 1;
	}
    new tw = GetPlayerTurfWarsZone(playerid);
    new family = PlayerInfo[playerid][pMember];
    new rank = PlayerInfo[playerid][pRank];
    if(family == INVALID_GROUP_ID || !IsACriminal(playerid)) {
        SendClientMessageEx(playerid, COLOR_GRAD2, "You are not in a family/gang, you can not claim turfs!");
        return 1;
    }
    if(rank < arrGroupData[family][g_iTurfCapRank]) {
    	SendClientMessageEx(playerid, COLOR_GRAD2, "You cannot claim turfs due to your rank!");
        return 1;
    }
    if(tw != -1) {
        if(TurfWars[tw][twLocked] == 1) {
            SendClientMessageEx(playerid, COLOR_GRAD2, "The turf is currently locked by a admin, you can not claim it!");
            return 1;
        }
        if(TurfWars[tw][twVulnerable] == 0) {
            if(TurfWars[tw][twActive] == 0) {
                if(TurfWars[tw][twOwnerId] == family) {
                    SendClientMessageEx(playerid, COLOR_GRAD2, "Your family/gang already owns this turf, you are unable to claim it!");
                    return 1;
                }
                new count = 0;
                foreach(new i: Player)
				{
					if(family == PlayerInfo[i][pMember] && PlayerInfo[i][pAccountRestricted] != 1) {
						if(GetPlayerTurfWarsZone(i) == tw && GetPVarInt(i, "Injured") != 1) {
							count++;
						}
					}
                }

                if(count > 2) {
                    TakeoverTurfWarsZone(family, tw);
                }
                else {
                    SendClientMessageEx(playerid, COLOR_GRAD2, "You need at least 3 of your family/gang members on the turf, to be able to claim it!");
                }
            }
            else {
                new count = 0;
                new leocount = 0;
                if(TurfWars[tw][twAttemptId] == family) {
                    SendClientMessageEx(playerid, COLOR_GRAD2, "You are already attempting to capture this turf!");
                    return 1;
                }

                foreach(new i: Player)
				{
					if(TurfWars[tw][twAttemptId] == PlayerInfo[i][pMember]) {
						if(GetPlayerTurfWarsZone(i) == tw && GetPVarInt(i, "Injured") != 1) {
							count++;
						}
					}
					if(TurfWars[tw][twAttemptId] == -2) {
						if(IsACop(i)) {
							if(GetPlayerTurfWarsZone(i) == tw && GetPVarInt(i, "Injured") != 1) {
								leocount++;
							}
						}
					}
				}	

                if(count == 0 && leocount == 0) {
                    if(family != TurfWars[tw][twOwnerId]) {
                    }
                    foreach(new i: Player)
					{
						if(PlayerInfo[i][pGangModerator] >= 1) {
							SendClientMessageEx(i,COLOR_YELLOW,"%s has attempted to takeover turf %d for family %s",GetPlayerNameEx(playerid),tw,arrGroupData[family][g_szGroupName]);
						}	
                    }
                    TakeoverTurfWarsZone(family, tw);
                }
                else {
                    if(leocount == 0) {
                        SendClientMessageEx(playerid, COLOR_GRAD2, "There is still %d Attacking Members on the Turf, you must get rid of them before reclaiming!",count);
                    }
                    else {
                        SendClientMessageEx(playerid, COLOR_GRAD2, "There is still %d Officers on the Turf, you must get rid of them before reclaiming!",leocount);
                    }
                }
            }
        }
        else {
            SendClientMessageEx(playerid, COLOR_GRAD2, "This turf is currently not vulnerable, you are unable to claim it!");
        }
    }
    else {
        SendClientMessageEx(playerid, COLOR_GRAD2, "You have to be in a turf to be able to claim turfs!");
    }

    if(turfWarsRadar[playerid] == 0) {
        ShowTurfWarsRadar(playerid);
    }
    return 1;
}