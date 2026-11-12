/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

    	   			Pay Phones System
    			        by Jingles

				Next Generation Gaming, LLC
	(created by Next Generation Gaming Development Team)
					
	* Copyright (c) 2016, Next Generation Gaming, LLC
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

new gPayPhoneListCount[MAX_PLAYERS];

PayPhone_Valid(i) {
	return 0 <= i < MAX_PAYPHONES && IsValidDynamicArea(arrPayPhoneData[i][pp_iAreaID]);
}

PayPhone_Clear(i) {
	if(IsValidDynamicObject(arrPayPhoneData[i][pp_iObjectID])) DestroyDynamicObject(arrPayPhoneData[i][pp_iObjectID]);
	if(IsValidDynamicArea(arrPayPhoneData[i][pp_iAreaID])) DestroyDynamicArea(arrPayPhoneData[i][pp_iAreaID]);
	if(IsValidDynamic3DTextLabel(arrPayPhoneData[i][pp_iTextID])) DestroyDynamic3DTextLabel(arrPayPhoneData[i][pp_iTextID]);
	arrPayPhoneData[i][pp_iObjectID] = 0;
	arrPayPhoneData[i][pp_iAreaID] = 0;
	arrPayPhoneData[i][pp_iTextID] = Text3D:0;
	arrPayPhoneData[i][pp_iCallerID] = INVALID_PLAYER_ID;
	arrPayPhoneData[i][pp_iUserID] = INVALID_PLAYER_ID;
	++arrPayPhoneData[i][pp_iRevision];
}

PayPhone_Requester(i) {
	new playerid = arrPayPhoneData[i][pp_iRequester];
	return 0 <= playerid < MAX_PLAYERS && IsPlayerConnected(playerid)
		&& g_arrQueryHandle[playerid] == arrPayPhoneData[i][pp_iSession]
		&& GetPlayerSQLId(playerid) == arrPayPhoneData[i][pp_iAccount];
}

PayPhone_WriteMatches(i, revision) {
	return 0 <= i < MAX_PAYPHONES && arrPayPhoneData[i][pp_bPending] && arrPayPhoneData[i][pp_iRevision] == revision;
}

PayPhone_Fail(i, revision) {
	if(!PayPhone_WriteMatches(i, revision)) return 0;
	if(PayPhone_Requester(i)) SendClientMessageEx(arrPayPhoneData[i][pp_iRequester], COLOR_GRAD1, "Pay phone save failed. Review and reload before retrying.");
	arrPayPhoneData[i][pp_bPending] = false;
	printf("[Pay Phones] Write/read failed for slot %d; world unchanged. Reload may be required.", i);
	return 1;
}

PayPhone_QueryFailed(const callback[], const query[]) {
	if(!strcmp(callback, "OnLoadPayPhones")) gPayPhonesLoading = false;
	if(strfind(query, "/*payphone ") != 0) return 0;
	new i, revision;
	if(sscanf(query[11], "ii", i, revision)) return 0;
	return PayPhone_Fail(i, revision);
}

GetPhoneZone(id, zone[], len) {

	if(id < 0 || id >= MAX_PAYPHONES) return 0;
	zone[0] = 0;
	new Float:x, Float:y, Float:z;
	GetDynamicObjectPos(arrPayPhoneData[id][pp_iObjectID], x, y, z);

	for(new i = 0; i != sizeof(gMainZones); i++) {

		if(x >= gMainZones[i][SAZONE_AREA][0]
				&& x <= gMainZones[i][SAZONE_AREA][3]
				&& y >= gMainZones[i][SAZONE_AREA][1]
				&& y <= gMainZones[i][SAZONE_AREA][4]
				&& z >= gMainZones[i][SAZONE_AREA][2]
				&& z <= gMainZones[i][SAZONE_AREA][5]) {
			format(zone, len, "%s", gMainZones[i][SAZONE_NAME]);
		}
	}
	
	for(new i = 0; i != sizeof(gSAZones); i++) {

		if(x >= gSAZones[i][SAZONE_AREA][0]
				&& x <= gSAZones[i][SAZONE_AREA][3]
				&& y >= gSAZones[i][SAZONE_AREA][1]
				&& y <= gSAZones[i][SAZONE_AREA][4]
				&& z >= gSAZones[i][SAZONE_AREA][2]
				&& z <= gSAZones[i][SAZONE_AREA][5]) {
			return format(zone, len, "%s", gSAZones[i][SAZONE_NAME]);
		}
	}
	return 0;
}

GetPhoneAreaCode(i) {

	new iAreaCode, zone[MAX_ZONE_NAME];
	GetPhoneZone(i, zone, sizeof(zone));
	if(strcmp(zone, "DOC", true) == 0) iAreaCode = 420;
	if(strcmp(zone, "Los Santos", true) == 0) iAreaCode = 500;
	if(strcmp(zone, "Red County", true) == 0) iAreaCode = 300;
	if(strcmp(zone, "Flint County", true) == 0) iAreaCode = 400;
	if(strcmp(zone, "San Fierro", true) == 0) iAreaCode = 600;
	if(strcmp(zone, "Las Venturas", true) == 0) iAreaCode = 700;
	if(strcmp(zone, "Bone County", true) == 0) iAreaCode = 666;
	if(strcmp(zone, "Tiera Robada", true) == 0) iAreaCode = 999;
	if(strcmp(zone, "Downtown Los Santos", true) == 0) iAreaCode = 502;
	if(strcmp(zone, "Pershing Square", true) == 0) iAreaCode = 503;
	if(strcmp(zone, "Temple", true) == 0) iAreaCode = 504;
	if(strcmp(zone, "Market", true) == 0) iAreaCode = 505;
	if(strcmp(zone, "Rodeo", true) == 0) iAreaCode = 540;
	if(strcmp(zone, "Idlewood", true) == 0) iAreaCode = 569;
	if(strcmp(zone, "Glen Park", true) == 0) iAreaCode = 570;
	if(strcmp(zone, "Jefferson", true) == 0) iAreaCode = 572;
	if(strcmp(zone, "East Los Santos", true) == 0) iAreaCode = 580;
	if(strcmp(zone, "Blueberry", true) == 0) iAreaCode = 444;
	if(strcmp(zone, "Angel Pine", true) == 0) iAreaCode = 838;
	return iAreaCode;
}

PayPhone_EndCall(playerid) {
	new peer = Mobile[playerid];
	new bool:ownsPhone = GetPVarType(playerid, "PayPhone") != 0 || GetPVarType(playerid, "CallingPayPhone") != 0;
	if(!ownsPhone && (peer < 0 || peer >= MAX_PLAYERS || !IsPlayerConnected(peer) || (!GetPVarType(peer, "PayPhone") && !GetPVarType(peer, "CallingPayPhone")))) 
	{
		peer = INVALID_PLAYER_ID;
		for(new i; i < MAX_PLAYERS; ++i) {
			if(i != playerid && IsPlayerConnected(i) && Mobile[i] == playerid && GetPVarType(i, "PayPhone")) {
				peer = i;
				break;
			}
		}
		if(peer == INVALID_PLAYER_ID) return 0;
	}
	new bool:linked = 0 <= peer < MAX_PLAYERS && IsPlayerConnected(peer) && Mobile[peer] == playerid;
	if(linked) Phone_HangupCall(playerid, peer);
	if(!linked && 0 <= peer < MAX_PLAYERS && IsPlayerConnected(peer) && Mobile[peer] == INVALID_PLAYER_ID) RingTone[peer] = 0;
	for(new n; n < 2; ++n) {
		if(n == 1 && !linked) break;
		new actor = n == 0 ? playerid : peer;
		if(GetPVarType(actor, "PayPhone")) {
			new i = GetPVarInt(actor, "PayPhone");
			if(0 <= i < MAX_PAYPHONES && arrPayPhoneData[i][pp_iUserID] == actor) {
				arrPayPhoneData[i][pp_iUserID] = INVALID_PLAYER_ID;
				arrPayPhoneData[i][pp_iCallerID] = INVALID_PLAYER_ID;
				PayPhone_UpdateTextLabel(i, 0);
				TogglePlayerControllable(actor, true);
			}
			DeletePVar(actor, "PayPhone");
		}
		if(GetPVarType(actor, "CallingPayPhone")) {
			new i = GetPVarInt(actor, "CallingPayPhone");
			if(0 <= i < MAX_PAYPHONES && arrPayPhoneData[i][pp_iCallerID] == actor) {
				arrPayPhoneData[i][pp_iCallerID] = INVALID_PLAYER_ID;
				PayPhone_UpdateTextLabel(i, 0);
			}
			DeletePVar(actor, "CallingPayPhone");
		}
		Mobile[actor] = INVALID_PLAYER_ID;
		CellTime[actor] = 0;
		RingTone[actor] = 0;
		DeletePVar(actor, "GRPCALL");
		DeletePVar(actor, "BUSICALL");
		RemovePlayerAttachedObject(actor, 8);
		SetPlayerSpecialAction(actor, SPECIAL_ACTION_STOPUSECELLPHONE);
		if(n == 1) SendClientMessageEx(actor, COLOR_GRAD2, "They hung up.");
	}
	return 1;
}

hook OnPlayerDisconnect(playerid, reason) {
	PayPhone_EndCall(playerid);
	for(new i; i < MAX_PLAYERS; ++i) {
		if(i != playerid && IsPlayerConnected(i) && Mobile[i] == playerid && GetPVarType(i, "PayPhone")) PayPhone_EndCall(i);
	}
	gPayPhoneListCount[playerid] = 0;
}

hook OnPlayerDeath(playerid, killerid, reason) {
	PayPhone_EndCall(playerid);
	for(new i; i < MAX_PLAYERS; ++i) {
		if(i != playerid && IsPlayerConnected(i) && Mobile[i] == playerid && GetPVarType(i, "PayPhone")) PayPhone_EndCall(i);
	}
}

hook OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA:areaid) {
	if(!GetPVarType(playerid, "PayPhone")) return 1;
	new i = GetPVarInt(playerid, "PayPhone");
	if(PayPhone_Valid(i) && arrPayPhoneData[i][pp_iAreaID] == areaid && arrPayPhoneData[i][pp_iUserID] == playerid) PayPhone_EndCall(playerid);
	return 1;
}

PayPhone_Directory(playerid) {
	gPayPhoneListCount[playerid] = 0;
	format(szMiscArray, sizeof(szMiscArray), "Area Code\tNumber\tZone\n");
	new zone[MAX_ZONE_NAME], line[160];
	for(new i; i < MAX_PAYPHONES; ++i) {
		if(!PayPhone_Valid(i)) continue;
		GetPhoneZone(i, zone, sizeof(zone));
		format(line, sizeof(line), "Area: %d\t%d\t%s\n", GetPhoneAreaCode(i), arrPayPhoneData[i][pp_iNumber], zone);
		if(strlen(szMiscArray)+strlen(line) >= sizeof(szMiscArray) || gPayPhoneListCount[playerid] >= sizeof(ListItemTrackId[])) break;
		strcat(szMiscArray, line, sizeof(szMiscArray));
		ListItemTrackId[playerid][gPayPhoneListCount[playerid]++] = i;
	}
	if(!gPayPhoneListCount[playerid]) return SendClientMessageEx(playerid, COLOR_GRAD1, "There are no pay phones.");
	return ShowPlayerDialogEx(playerid, DIALOG_PHONE_PAYPHONES, DIALOG_STYLE_TABLIST_HEADERS, "Pay Phones", szMiscArray, "Call", "Cancel");
}

PayPhone_Menu(playerid, i) {
	if(!PayPhone_Valid(i) || gPayPhonesLoading || arrPayPhoneData[i][pp_bPending]
		|| arrPayPhoneData[i][pp_iUserID] != INVALID_PLAYER_ID || arrPayPhoneData[i][pp_iCallerID] != INVALID_PLAYER_ID) return 0;
	new zone[MAX_ZONE_NAME];
	GetPhoneZone(i, zone, sizeof(zone));
	SetPVarInt(playerid, "PayPhone", i);
	arrPayPhoneData[i][pp_iUserID] = playerid;
	format(szMiscArray, sizeof(szMiscArray), "Number: %d\nArea Code: %d | {FFFF00}%s\n\n{FFFFFF}Please enter the number you would like to dial.", arrPayPhoneData[i][pp_iNumber], GetPhoneAreaCode(i), zone);
	return ShowPlayerDialogEx(playerid, DIALOG_PAYPHONE, DIALOG_STYLE_INPUT, "Pay Phone", szMiscArray, "Dial", "<<");
}

LoadPayPhones() {
	if(gPayPhonesLoading) return 0;
	for(new i; i < MAX_PAYPHONES; ++i) {
		if(arrPayPhoneData[i][pp_bPending] || (PayPhone_Valid(i) && (arrPayPhoneData[i][pp_iUserID] != INVALID_PLAYER_ID || arrPayPhoneData[i][pp_iCallerID] != INVALID_PLAYER_ID))) return 0;
	}
	gPayPhonesLoading = true;
	new query[128];
	mysql_format(MainPipeline, query, sizeof(query), "SELECT * FROM `payphones` WHERE `id` BETWEEN 1 AND %d ORDER BY `id`", MAX_PAYPHONES);
	if(!mysql_tquery(MainPipeline, query, "OnLoadPayPhones")) return gPayPhonesLoading = false, 0;
	return 1;
}

forward OnLoadPayPhones();
public OnLoadPayPhones() {
	new rows, loaded;
	cache_get_row_count(rows);
	for(new i; i < MAX_PAYPHONES; ++i) {
		PayPhone_Clear(i);
		arrPayPhoneData[i][pp_iNumber] = -1;
	}
	for(new row; row < rows; ++row) if(PayPhone_ReadRow(row) != -1) ++loaded;
	gPayPhonesLoading = false;
	printf("[Pay Phones] Loaded %d valid slot rows.", loaded);
	return 1;
}

PayPhone_ReadRow(row) {
	new id, number, vw, interior, Float:pos[4];
	if(!cache_get_value_name_int(row, "id", id) || id < 1 || id > MAX_PAYPHONES
		|| !cache_get_value_name_int(row, "number", number)
		|| !cache_get_value_name_int(row, "vw", vw)
		|| !cache_get_value_name_int(row, "int", interior)
		|| !cache_get_value_name_float(row, "posx", pos[0])
		|| !cache_get_value_name_float(row, "posy", pos[1])
		|| !cache_get_value_name_float(row, "posz", pos[2])
		|| !cache_get_value_name_float(row, "rotz", pos[3])) return -1;
	new i = id - 1;
	arrPayPhoneData[i][pp_iNumber] = number;
	ProcessPayPhone(i, pos[0], pos[1], pos[2], pos[3], vw, interior);
	return i;
}

ProcessPayPhone(i, Float:X, Float:Y, Float:Z, Float:RZ, iVW, iINT) {
	if(i < 0 || i >= MAX_PAYPHONES) return 0;
	PayPhone_Clear(i);
	if(arrPayPhoneData[i][pp_iNumber] <= 0 || (X == 0.0 && Y == 0.0 && Z == 0.0)) return 1;
	arrPayPhoneData[i][pp_iObjectID] = CreateDynamicObject(1216, X, Y, Z - 0.3, 0.0, 0.0, RZ + 180.0, .worldid = iVW, .interiorid = iINT);
	format(szMiscArray, sizeof(szMiscArray), "Pay Phone {DDDDDD}(ID: %d)\n{FFFF00} Number: %d\n\n{DDDDDD}Press ~k~~CONVERSATION_YES~ to dial.", i, arrPayPhoneData[i][pp_iNumber]);
	arrPayPhoneData[i][pp_iTextID] = CreateDynamic3DTextLabel(szMiscArray, COLOR_YELLOW, X, Y, Z + 1.0, 5.0, .worldid = iVW, .interiorid = iINT);
	arrPayPhoneData[i][pp_iAreaID] = CreateDynamicSphere(X, Y, Z, 3.0, iVW, iINT);
	return 1;
}

PayPhone_UpdateTextLabel(i, choice) {
    if(!PayPhone_Valid(i)) return 0;
    if(choice == 2) 
		return UpdateDynamic3DTextLabelText(arrPayPhoneData[i][pp_iTextID], COLOR_PURPLE, "** The pay phone is in use **");
    
	if(choice == 1) 
		return UpdateDynamic3DTextLabelText(arrPayPhoneData[i][pp_iTextID], COLOR_PURPLE, "** The pay phone is ringing **\nPress ~k~~CONVERSATION_YES~ to answer.");
    
	format(szMiscArray, sizeof(szMiscArray), "Pay Phone {DDDDDD}(ID: %d)\n{FFFF00} Number: %d\n\n{DDDDDD}Press ~k~~CONVERSATION_YES~ to dial.", i, arrPayPhoneData[i][pp_iNumber]);
    return UpdateDynamic3DTextLabelText(arrPayPhoneData[i][pp_iTextID], COLOR_YELLOW, szMiscArray);
}

PayPhone_QueueEdit(i, number, Float:X, Float:Y, Float:Z, Float:RZ, iVW, iINT, playerid) {
	if(i < 0 || i >= MAX_PAYPHONES || gPayPhonesLoading || arrPayPhoneData[i][pp_bPending]) return 0;
	if(PayPhone_Valid(i) && (arrPayPhoneData[i][pp_iUserID] != INVALID_PLAYER_ID || arrPayPhoneData[i][pp_iCallerID] != INVALID_PLAYER_ID)) return 0;
	if(playerid != INVALID_PLAYER_ID && (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid))) return 0;
	arrPayPhoneData[i][pp_bPending] = true;
	new revision = ++arrPayPhoneData[i][pp_iRevision];
	arrPayPhoneData[i][pp_iRequester] = playerid;
	if(playerid != INVALID_PLAYER_ID) {
		arrPayPhoneData[i][pp_iSession] = g_arrQueryHandle[playerid];
		arrPayPhoneData[i][pp_iAccount] = GetPlayerSQLId(playerid);
	}
	new query[512];
	mysql_format(MainPipeline, query, sizeof(query), "/*payphone %d %d */ UPDATE `payphones` SET `number`=%d,`posx`=%f,`posy`=%f,`posz`=%f,`rotz`=%f,`vw`=%d,`int`=%d WHERE `id`=%d",
		i, revision, number, X, Y, Z, RZ, iVW, iINT, i+1);
	if(!mysql_tquery(MainPipeline, query, "OnPayPhoneWrite", "ii", i, revision)) return PayPhone_Fail(i, revision), 0;
	return 1;
}

PayPhone_Save(i, Float:X, Float:Y, Float:Z, Float:RZ, iVW, iINT, playerid = INVALID_PLAYER_ID) {
	if(!PayPhone_Valid(i)) return 0;
	return PayPhone_QueueEdit(i, arrPayPhoneData[i][pp_iNumber], X, Y, Z, RZ, iVW, iINT, playerid);
}

forward OnPayPhoneWrite(i, revision);
public OnPayPhoneWrite(i, revision) {
	if(!PayPhone_WriteMatches(i, revision)) return 0;
	new query[128];
	mysql_format(MainPipeline, query, sizeof(query), "/*payphone %d %d */ SELECT * FROM `payphones` WHERE `id`=%d", i, revision, i+1);
	if(!mysql_tquery(MainPipeline, query, "OnPayPhoneRead", "ii", i, revision)) return PayPhone_Fail(i, revision);
	return 1;
}

forward OnPayPhoneRead(i, revision);
public OnPayPhoneRead(i, revision) {
	if(!PayPhone_WriteMatches(i, revision)) return 0;
	new rows, id;
	cache_get_row_count(rows);
	if(rows != 1 || !cache_get_value_name_int(0, "id", id) || id != i+1) return PayPhone_Fail(i, revision);
	if(PayPhone_ReadRow(0) != i) return PayPhone_Fail(i, revision);
	if(PayPhone_Requester(i)) SendClientMessageEx(arrPayPhoneData[i][pp_iRequester], COLOR_YELLOW, "Pay phone changes saved successfully.");
	arrPayPhoneData[i][pp_bPending] = false;
	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(!(newkeys & KEY_YES) || IsPlayerInAnyVehicle(playerid)) return 1;
	if(Mobile[playerid] != INVALID_PLAYER_ID || GetPVarType(playerid, "CallingPayPhone")) return 1;
	DeletePVar(playerid, "AtPayPhone");
	for(new i; i < MAX_PAYPHONES; ++i) {
		if(!PayPhone_Valid(i) || gPayPhonesLoading || arrPayPhoneData[i][pp_bPending] || !IsPlayerInDynamicArea(playerid, arrPayPhoneData[i][pp_iAreaID])) continue;
		if(arrPayPhoneData[i][pp_iUserID] != INVALID_PLAYER_ID) return SendClientMessageEx(playerid, COLOR_GRAD1, "This pay phone is already in use.");
		if(GetPVarType(playerid, "PayPhone")) return SendClientMessageEx(playerid, COLOR_GRAD1, "You are already communicating with a pay phone.");
		if(arrPayPhoneData[i][pp_iCallerID] != INVALID_PLAYER_ID) {
			SetPVarInt(playerid, "PayPhone", i);
			return pc_cmd_pickup(playerid, "");
		}
		PayPhone_Menu(playerid, i);
		break;
	}
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	if(dialogid == DIALOG_PHONE_PAYPHONES) {
		new count = gPayPhoneListCount[playerid];
		gPayPhoneListCount[playerid] = 0;
		if(!response || listitem < 0 || listitem >= count) return 1;
		new i = ListItemTrackId[playerid][listitem], number[16];
		if(!PayPhone_Valid(i) || gPayPhonesLoading || arrPayPhoneData[i][pp_bPending]) return SendClientMessageEx(playerid, COLOR_GRAD1, "This pay phone is unavailable. Open the directory again.");
		format(number, sizeof(number), "%d", arrPayPhoneData[i][pp_iNumber]);
		return pc_cmd_call(playerid, number);
	}
	if(dialogid == DIALOG_PAYPHONE) {
		if(!GetPVarType(playerid, "PayPhone")) return 1;
		if(Mobile[playerid] != INVALID_PLAYER_ID || GetPVarType(playerid, "CallingPayPhone")) return 1;
		if(!response || isnull(inputtext)) return PayPhone_EndCall(playerid), 1;
		new i = GetPVarInt(playerid, "PayPhone");
		if(!PayPhone_Valid(i) || gPayPhonesLoading || arrPayPhoneData[i][pp_bPending] || arrPayPhoneData[i][pp_iUserID] != playerid || !IsPlayerInDynamicArea(playerid, arrPayPhoneData[i][pp_iAreaID])) return PayPhone_EndCall(playerid), 1;
		if(strval(inputtext) <= 0) return PayPhone_EndCall(playerid), 1;
		pc_cmd_call(playerid, inputtext);
		return 1;
	}
	if(dialogid == DIALOG_PAYPHONE_ADMIN) {
		new count = gPayPhoneListCount[playerid];
		gPayPhoneListCount[playerid] = 0;
		if(!response || listitem < 0 || listitem >= count || !IsAdminLevel(playerid, ADMIN_GENERAL)) return 1;
		new i = ListItemTrackId[playerid][listitem], Float:pos[3];
		if(!PayPhone_Valid(i)) return 1;
		GetDynamicObjectPos(arrPayPhoneData[i][pp_iObjectID], pos[0], pos[1], pos[2]);
		Player_StreamPrep(playerid, pos[0], pos[1], pos[2], FREEZE_TIME);
		SetPlayerVirtualWorld(playerid, Streamer_GetIntData(STREAMER_TYPE_OBJECT, arrPayPhoneData[i][pp_iObjectID], E_STREAMER_WORLD_ID));
		SetPlayerInterior(playerid, Streamer_GetIntData(STREAMER_TYPE_OBJECT, arrPayPhoneData[i][pp_iObjectID], E_STREAMER_INTERIOR_ID));
		return 1;
	}
	return 0;
}

CMD:phones(playerid, params[]) {
	if(!IsAdminLevel(playerid, ADMIN_GENERAL)) return 1;
	szMiscArray[0] = 0;
	gPayPhoneListCount[playerid] = 0;
	new zone[MAX_ZONE_NAME], line[160];
	for(new i; i < MAX_PAYPHONES; ++i) {
		if(!PayPhone_Valid(i)) continue;
		GetPhoneZone(i, zone, sizeof(zone));
		format(line, sizeof(line), "%d - Number: %d - Location: %s\n", i, arrPayPhoneData[i][pp_iNumber], zone);
		if(strlen(szMiscArray) + strlen(line) >= sizeof(szMiscArray) || gPayPhoneListCount[playerid] >= sizeof(ListItemTrackId[])) break;
		strcat(szMiscArray, line, sizeof(szMiscArray));
		ListItemTrackId[playerid][gPayPhoneListCount[playerid]++] = i;
	}
	if(!gPayPhoneListCount[playerid]) return SendClientMessageEx(playerid, COLOR_GRAD1, "There are no pay phones.");
	return ShowPlayerDialogEx(playerid, DIALOG_PAYPHONE_ADMIN, DIALOG_STYLE_LIST, "Pay Phones", szMiscArray, "Teleport", "Cancel");
}

CMD:createphone(playerid, params[]) {
	if(!IsAdminLevel(playerid, ADMIN_SENIOR)) return 1;
	for(new i; i < MAX_PAYPHONES; ++i) {
		if(PayPhone_Valid(i) || arrPayPhoneData[i][pp_bPending]) continue;
		new Float:pos[4], vw = GetPlayerVirtualWorld(playerid), interior = GetPlayerInterior(playerid);
		GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		GetPlayerFacingAngle(playerid, pos[3]);
		new oldobject = arrPayPhoneData[i][pp_iObjectID];
		arrPayPhoneData[i][pp_iObjectID] = CreateDynamicObject(1216, pos[0], pos[1], pos[2], 0.0, 0.0, 0.0);
		new area = GetPhoneAreaCode(i), numbertext[20];
		DestroyDynamicObject(arrPayPhoneData[i][pp_iObjectID]);
		arrPayPhoneData[i][pp_iObjectID] = oldobject;
		format(numbertext, sizeof(numbertext), "024%d%d", area, Random(100, 999));
		new number = strval(numbertext);
		for(new x; x < MAX_PAYPHONES; ++x) if(arrPayPhoneData[x][pp_iNumber] == number) return SendClientMessageEx(playerid, COLOR_GRAD1, "Generated number already exists. Try again.");
		if(!PayPhone_QueueEdit(i, number, pos[0], pos[1], pos[2], pos[3], vw, interior, playerid)) SendClientMessageEx(playerid, COLOR_GRAD1, "Pay phones are busy. Try again later.");
		return 1;
	}
	return SendClientMessageEx(playerid, COLOR_GRAD1, "There are no more pay phone slots available.");
}

CMD:destroyphone(playerid, params[]) {
	if(!IsAdminLevel(playerid, ADMIN_SENIOR)) return 1;
	new i;
	if(sscanf(params, "i", i)) return SendClientMessageEx(playerid, COLOR_GRAD1, "/destroyphone [phoneid]");
	if(!PayPhone_Valid(i)) return SendClientMessageEx(playerid, COLOR_GRAD1, "The specified pay phone ID has not been used.");
	if(arrPayPhoneData[i][pp_iCallerID] != INVALID_PLAYER_ID || arrPayPhoneData[i][pp_iUserID] != INVALID_PLAYER_ID) return SendClientMessageEx(playerid, COLOR_GRAD1, "The phone is in use.");
	if(!PayPhone_QueueEdit(i, -1, 0.0, 0.0, 0.0, 0.0, 0, 0, playerid)) SendClientMessageEx(playerid, COLOR_GRAD1, "Pay phones are busy. Try again later.");
	return 1;
}

CMD:editphone(playerid, params[]) {
	if(!IsAdminLevel(playerid, ADMIN_SENIOR)) return 1;
	new i, Float:pos[4];
	if(sscanf(params, "i", i)) return SendClientMessageEx(playerid, COLOR_GRAD1, "/editphone [id]");
	if(!PayPhone_Valid(i)) return SendClientMessageEx(playerid, COLOR_GRAD1, "The specified pay phone ID has not been used.");
	if(arrPayPhoneData[i][pp_iCallerID] != INVALID_PLAYER_ID || arrPayPhoneData[i][pp_iUserID] != INVALID_PLAYER_ID) return SendClientMessageEx(playerid, COLOR_GRAD1, "The phone is in use.");
	GetDynamicObjectPos(arrPayPhoneData[i][pp_iObjectID], pos[0], pos[1], pos[2]);
	if(!IsPlayerInRangeOfPoint(playerid, 50.0, pos[0], pos[1], pos[2])) return SendClientMessageEx(playerid, COLOR_GRAD1, "You need to be near the pay phone.");
	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	GetPlayerFacingAngle(playerid, pos[3]);
	if(!PayPhone_Save(i, pos[0], pos[1], pos[2], pos[3], GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), playerid)) SendClientMessageEx(playerid, COLOR_GRAD1, "Pay phones are busy. Try again later.");
	return 1;
}
