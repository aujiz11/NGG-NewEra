/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

					Dynamic Door System

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
new DynamicDoorRevision[MAX_DDOORS];
new DynamicDoorLoadRequest;

stock bool:IsDynamicDoorLoaded(doorid)
{
	return 0 <= doorid < MAX_DDOORS && DDoorsInfo[doorid][ddSQLId] == doorid + 1;
}

stock bool:IsDynamicDoorActive(doorid)
{
	return IsDynamicDoorLoaded(doorid) && (DDoorsInfo[doorid][ddExteriorX] != 0.0
		|| DDoorsInfo[doorid][ddExteriorY] != 0.0 || DDoorsInfo[doorid][ddExteriorZ] != 0.0);
}

stock Float:GetPlayerDynamicDoorDistance(playerid, doorid)
{
	if(!IsDynamicDoorActive(doorid)) return -1.0;
	new 
		world = GetPlayerVirtualWorld(playerid), 
		interior = GetPlayerInterior(playerid),
		Float:distance = -1.0;

	if(world == DDoorsInfo[doorid][ddExteriorVW] && interior == DDoorsInfo[doorid][ddExteriorInt])
	{
		distance = GetPlayerDistanceFromPoint(playerid, DDoorsInfo[doorid][ddExteriorX], DDoorsInfo[doorid][ddExteriorY], DDoorsInfo[doorid][ddExteriorZ]);
	}
	
	if(world == DDoorsInfo[doorid][ddInteriorVW] && interior == DDoorsInfo[doorid][ddInteriorInt]
		&& (DDoorsInfo[doorid][ddInteriorX] != 0.0 || DDoorsInfo[doorid][ddInteriorY] != 0.0 || DDoorsInfo[doorid][ddInteriorZ] != 0.0))
	{
		new Float:inside = GetPlayerDistanceFromPoint(playerid, DDoorsInfo[doorid][ddInteriorX], DDoorsInfo[doorid][ddInteriorY], DDoorsInfo[doorid][ddInteriorZ]);
		if(distance < 0.0 || inside < distance) distance = inside;
	}
	return distance;
}

stock bool:CalculatePropertyMoveFine(playerid, percent, minimum, &fine)
{
	fine = 0;
	if(!(0 <= percent <= 100) || minimum < 0) return false;
	if(percent == 0) return true;

	new parts[5];
	parts[0] = PlayerInfo[playerid][pAccount];
	parts[1] = GetPlayerCash(playerid);

	new houses[3];
	houses[0] = PlayerInfo[playerid][pPhousekey];
	houses[1] = PlayerInfo[playerid][pPhousekey2];
	houses[2] = PlayerInfo[playerid][pPhousekey3];

	for(new i; i < sizeof(houses); ++i)
	{
		if(0 <= houses[i] < MAX_HOUSES && HouseInfo[houses[i]][hOwnerID] == GetPlayerSQLId(playerid))
		{
			parts[i + 2] = HouseInfo[houses[i]][hSafeMoney];
		}
	}

	new quotient, remainder;
	for(new i; i < sizeof(parts); ++i)
	{
		quotient += parts[i] / 10000;
		remainder += parts[i] % 10000;
	}
	
	quotient += remainder / 10000;
	remainder %= 10000;
	if(remainder < 0)
	{
		--quotient;
		remainder += 10000;
	}
	if(quotient >= 0)
	{
		new discount = 100;
		if(PlayerInfo[playerid][pDonateRank] == 3) discount = 95;
		else if(PlayerInfo[playerid][pDonateRank] >= 4) discount = 85;
		new rate = percent * discount, tail = remainder * rate / 10000;
		if(quotient > (cellmax - tail) / rate) return false;
		fine = quotient * rate + tail;
	}
	if(fine < minimum) fine = minimum;
	return GetPlayerCash(playerid) >= cellmin + fine;
}

stock GetClosestDynamicDoor(playerid)
{
	new areas[128], data[2], Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	new count = Streamer_GetNearbyItems(x, y, z, STREAMER_TYPE_AREA, areas, sizeof(areas), 3.0, GetPlayerVirtualWorld(playerid));
	if(count > sizeof(areas)) count = sizeof(areas);

	new closest = -1, Float:nearest = 3.0;
	for(new n; n < count; ++n)
	{
		if(Streamer_GetArrayDataLength(STREAMER_TYPE_AREA, areas[n], E_STREAMER_EXTRA_ID) != sizeof(data)) continue;
		Streamer_GetArrayData(STREAMER_TYPE_AREA, areas[n], E_STREAMER_EXTRA_ID, data, sizeof(data));
		if(data[0] != STREAMER_AREATYPE_DOOR || !IsDynamicDoorActive(data[1])) continue;
		new doorid = data[1];
		if(areas[n] != DDoorsInfo[doorid][ddAreaID] && areas[n] != DDoorsInfo[doorid][ddAreaID_int]) continue;
		new Float:distance = GetPlayerDynamicDoorDistance(playerid, doorid);
		if(distance < 0.0 || distance > nearest) continue;
		if(distance == nearest && closest != -1 && doorid > closest) continue;
		closest = doorid;
		nearest = distance;
	}
	return closest;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	if(dialogid != DOORLOCK) return 0;
	
	new doorid = GetPVarInt(playerid, "Door"), revision = GetPVarInt(playerid, "DoorRevision");
	DeletePVar(playerid, "Door");
	DeletePVar(playerid, "DoorRevision");
	
	if(!response) return 1;
	if(!gPlayerLogged{playerid} || !IsDynamicDoorActive(doorid) || revision != DynamicDoorRevision[doorid])
		return SendClientMessageEx(playerid, COLOR_GREY, "Cua nay da thay doi. Hay dung lai /doorpass.");
	
	new Float:distance = GetPlayerDynamicDoorDistance(playerid, doorid);
	if(!(0.0 <= distance <= 3.0)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai o trong ban kinh 3 met tu cua nay.");
	if(isnull(inputtext) || strlen(inputtext) > 23) return SendClientMessageEx(playerid, COLOR_GREY, "Nhap mat khau tu 1 den 23 ky tu.");
	if(!DDoorsInfo[doorid][ddPass][0] || !strcmp(DDoorsInfo[doorid][ddPass], "None", true)
		|| strcmp(inputtext, DDoorsInfo[doorid][ddPass], true))
		return SendClientMessageEx(playerid, COLOR_WHITE, "Mat khau sai.");
	
	DDoorsInfo[doorid][ddLocked] = !DDoorsInfo[doorid][ddLocked];
	SaveDynamicDoor(doorid);
	SendClientMessageEx(playerid, COLOR_WHITE, "Mat khau dung, cua %s.", DDoorsInfo[doorid][ddLocked] ? ("da khoa") : ("da mo khoa"));
	return 1;
}

stock CreateDynamicDoor(doorid)
{
	if(!(0 <= doorid < MAX_DDOORS)) return 0;
	++DynamicDoorRevision[doorid];
	if(IsValidDynamicPickup(DDoorsInfo[doorid][ddPickupID])) DestroyDynamicPickup(DDoorsInfo[doorid][ddPickupID]);
	if(IsValidDynamicPickup(DDoorsInfo[doorid][ddPickupID_int])) DestroyDynamicPickup(DDoorsInfo[doorid][ddPickupID_int]);
	if(IsValidDynamic3DTextLabel(DDoorsInfo[doorid][ddTextID])) DestroyDynamic3DTextLabel(DDoorsInfo[doorid][ddTextID]);

	if(IsValidDynamicArea(DDoorsInfo[doorid][ddAreaID])) DestroyDynamicArea(DDoorsInfo[doorid][ddAreaID]);
	if(IsValidDynamicArea(DDoorsInfo[doorid][ddAreaID_int])) DestroyDynamicArea(DDoorsInfo[doorid][ddAreaID_int]);
	DDoorsInfo[doorid][ddPickupID] = INVALID_STREAMER_ID;
	DDoorsInfo[doorid][ddPickupID_int] = INVALID_STREAMER_ID;
	DDoorsInfo[doorid][ddTextID] = Text3D:INVALID_STREAMER_ID;
	DDoorsInfo[doorid][ddAreaID] = INVALID_STREAMER_ID;
	DDoorsInfo[doorid][ddAreaID_int] = INVALID_STREAMER_ID;
	if(!IsDynamicDoorActive(doorid)) return 1;
	new string[192];
	if(DDoorsInfo[doorid][ddType] != 0) format(string, sizeof(string), "%s | Chu: %s\nID: %d", DDoorsInfo[doorid][ddDescription], StripUnderscore(DDoorsInfo[doorid][ddOwnerName]), doorid);
	else format(string, sizeof(string), "%s\nID: %d", DDoorsInfo[doorid][ddDescription], doorid);
	new const colors[] = {COLOR_YELLOW, COLOR_TWWHITE, COLOR_TWPINK, COLOR_TWRED, COLOR_TWBROWN, COLOR_TWGRAY, COLOR_TWOLIVE, COLOR_TWPURPLE, COLOR_TWORANGE, COLOR_TWAZURE, COLOR_TWGREEN, COLOR_TWBLUE, COLOR_TWBLACK};
	if(DDoorsInfo[doorid][ddColor] != -1)
	{
		new color = DDoorsInfo[doorid][ddColor];
		if(!(0 <= color < sizeof(colors))) color = 0;
		DDoorsInfo[doorid][ddTextID] = CreateDynamic3DTextLabel(string, colors[color], DDoorsInfo[doorid][ddExteriorX], DDoorsInfo[doorid][ddExteriorY], DDoorsInfo[doorid][ddExteriorZ] + 1.0,
			10.0, .testlos = true, .worldid = DDoorsInfo[doorid][ddExteriorVW], .interiorid = DDoorsInfo[doorid][ddExteriorInt]);
	}
	new const models[] = {1318, 1210, 1212, 1239, 1240, 1241, 1242, 1247, 1248, 1252, 1253, 1254, 1313, 1272, 1273, 1274, 1275, 1276, 1277, 1279, 1314, 1316, 1317, 1559, 1582, 2894};
	if(DDoorsInfo[doorid][ddPickupModel] != -1)
	{
		new model = DDoorsInfo[doorid][ddPickupModel];
		if(!(0 <= model < sizeof(models))) model = 0;
		DDoorsInfo[doorid][ddPickupID] = CreateDynamicPickup(models[model], 23, DDoorsInfo[doorid][ddExteriorX], DDoorsInfo[doorid][ddExteriorY], DDoorsInfo[doorid][ddExteriorZ],
			DDoorsInfo[doorid][ddExteriorVW], DDoorsInfo[doorid][ddExteriorInt]);
	}
	DDoorsInfo[doorid][ddAreaID] = CreateDynamicSphere(DDoorsInfo[doorid][ddExteriorX], DDoorsInfo[doorid][ddExteriorY], DDoorsInfo[doorid][ddExteriorZ], 2.0,
		.worldid = DDoorsInfo[doorid][ddExteriorVW], .interiorid = DDoorsInfo[doorid][ddExteriorInt]);
	if(DDoorsInfo[doorid][ddInteriorX] != 0.0 || DDoorsInfo[doorid][ddInteriorY] != 0.0 || DDoorsInfo[doorid][ddInteriorZ] != 0.0)
	{
		DDoorsInfo[doorid][ddPickupID_int] = CreateDynamicPickup(1559, 23, DDoorsInfo[doorid][ddInteriorX], DDoorsInfo[doorid][ddInteriorY], DDoorsInfo[doorid][ddInteriorZ],
			DDoorsInfo[doorid][ddInteriorVW], DDoorsInfo[doorid][ddInteriorInt]);
		DDoorsInfo[doorid][ddAreaID_int] = CreateDynamicSphere(DDoorsInfo[doorid][ddInteriorX], DDoorsInfo[doorid][ddInteriorY], DDoorsInfo[doorid][ddInteriorZ], 2.0,
			.worldid = DDoorsInfo[doorid][ddInteriorVW], .interiorid = DDoorsInfo[doorid][ddInteriorInt]);
	}
	new areaData[2];
	areaData[0] = STREAMER_AREATYPE_DOOR;
	areaData[1] = doorid;
	Streamer_SetArrayData(STREAMER_TYPE_AREA, DDoorsInfo[doorid][ddAreaID], E_STREAMER_EXTRA_ID, areaData, sizeof(areaData));
	if(IsValidDynamicArea(DDoorsInfo[doorid][ddAreaID_int]))
		Streamer_SetArrayData(STREAMER_TYPE_AREA, DDoorsInfo[doorid][ddAreaID_int], E_STREAMER_EXTRA_ID, areaData, sizeof(areaData));
	return 1;
}

stock SaveDynamicDoor(doorid)
{
	if(!IsDynamicDoorLoaded(doorid)) return 0;
	new string[2048];

	mysql_format(MainPipeline, string, sizeof(string), "UPDATE `ddoors` SET \
		`Description`='%e', \
		`Owner`=%d, \
		`OwnerName`='%e', \
		`CustomInterior`=%d, \
		`ExteriorVW`=%d, \
		`ExteriorInt`=%d, \
		`InteriorVW`=%d, \
		`InteriorInt`=%d, \
		`ExteriorX`=%f, \
		`ExteriorY`=%f, \
		`ExteriorZ`=%f, \
		`ExteriorA`=%f, \
		`InteriorX`=%f, \
		`InteriorY`=%f, \
		`InteriorZ`=%f, \
		`InteriorA`=%f,",
		DDoorsInfo[doorid][ddDescription],
		DDoorsInfo[doorid][ddOwner],
		DDoorsInfo[doorid][ddOwnerName],
		DDoorsInfo[doorid][ddCustomInterior],
		DDoorsInfo[doorid][ddExteriorVW],
		DDoorsInfo[doorid][ddExteriorInt],
		DDoorsInfo[doorid][ddInteriorVW],
		DDoorsInfo[doorid][ddInteriorInt],
		DDoorsInfo[doorid][ddExteriorX],
		DDoorsInfo[doorid][ddExteriorY],
		DDoorsInfo[doorid][ddExteriorZ],
		DDoorsInfo[doorid][ddExteriorA],
		DDoorsInfo[doorid][ddInteriorX],
		DDoorsInfo[doorid][ddInteriorY],
		DDoorsInfo[doorid][ddInteriorZ],
		DDoorsInfo[doorid][ddInteriorA]
	);

	mysql_format(MainPipeline, string, sizeof(string), "%s \
		`CustomExterior`=%d, \
		`Type`=%d, \
		`Rank`=%d, \
		`VIP`=%d, \
		`Famed`=%d, \
		`DPC`=%d, \
		`Allegiance`=%d, \
		`GroupType`=%d, \
		`Faction`=%d, \
		`Admin`=%d, \
		`Wanted`=%d, \
		`VehicleAble`=%d, \
		`Color`=%d, \
		`PickupModel`=%d, \
		`Pass`='%e', \
		`Locked`=%d, \
		`LastLogin`=%d, \
		`Expire`=%d, \
		`Inactive`=%d, \
		`Ignore`=%d, \
		`Counter`=%d \
		WHERE `id`=%d",
		string,
		DDoorsInfo[doorid][ddCustomExterior],
		DDoorsInfo[doorid][ddType],
		DDoorsInfo[doorid][ddRank],
		DDoorsInfo[doorid][ddVIP],
		DDoorsInfo[doorid][ddFamed],
		DDoorsInfo[doorid][ddDPC],
		DDoorsInfo[doorid][ddAllegiance],
		DDoorsInfo[doorid][ddGroupType],
		DDoorsInfo[doorid][ddFaction],
		DDoorsInfo[doorid][ddAdmin],
		DDoorsInfo[doorid][ddWanted],
		DDoorsInfo[doorid][ddVehicleAble],
		DDoorsInfo[doorid][ddColor],
		DDoorsInfo[doorid][ddPickupModel],
		DDoorsInfo[doorid][ddPass],
		DDoorsInfo[doorid][ddLocked],
		DDoorsInfo[doorid][ddLastLogin],
		DDoorsInfo[doorid][ddExpire],
		DDoorsInfo[doorid][ddInactive],
		DDoorsInfo[doorid][ddIgnore],
		DDoorsInfo[doorid][ddCounter],
		doorid+1
	); // Array starts from zero, MySQL starts at 1 (this is why we are adding one).

	return mysql_tquery(MainPipeline, string, "OnQueryFinish", "i", SENDDATA_THREAD);
}

stock LoadDynamicDoor(doorid)
{
	if(!(0 <= doorid < MAX_DDOORS)) return 0;
	DDoorsInfo[doorid][ddSQLId] = -1;
	new revision = ++DynamicDoorRevision[doorid], query[96];
	mysql_format(MainPipeline, query, sizeof(query), "SELECT * FROM `ddoors` WHERE `id`=%d", doorid + 1);
	return mysql_tquery(MainPipeline, query, "OnLoadDynamicDoor", "ii", doorid, revision);
}

stock LoadDynamicDoors()
{
	for(new i; i < MAX_DDOORS; ++i)
	{
		DDoorsInfo[i][ddSQLId] = -1;
		++DynamicDoorRevision[i];
	}
	return mysql_tquery(MainPipeline, "SELECT * FROM `ddoors`", "OnLoadDynamicDoors", "i", ++DynamicDoorLoadRequest);
}

stock LoadDynamicDoorData(row, index)
{
	cache_get_value_name_int(row, "id", DDoorsInfo[index][ddSQLId]);
	cache_get_value_name(row, "Description", DDoorsInfo[index][ddDescription], 128);
	cache_get_value_name_int(row, "Owner", DDoorsInfo[index][ddOwner]);
	cache_get_value_name(row, "OwnerName", DDoorsInfo[index][ddOwnerName], 42);
	cache_get_value_name_int(row, "CustomExterior", DDoorsInfo[index][ddCustomExterior]);
	cache_get_value_name_int(row, "CustomInterior", DDoorsInfo[index][ddCustomInterior]);
	cache_get_value_name_int(row, "ExteriorVW", DDoorsInfo[index][ddExteriorVW]);
	cache_get_value_name_int(row, "ExteriorInt", DDoorsInfo[index][ddExteriorInt]);
	cache_get_value_name_int(row, "InteriorVW", DDoorsInfo[index][ddInteriorVW]);
	cache_get_value_name_int(row, "InteriorInt", DDoorsInfo[index][ddInteriorInt]);
	cache_get_value_name_float(row, "ExteriorX", DDoorsInfo[index][ddExteriorX]);
	cache_get_value_name_float(row, "ExteriorY", DDoorsInfo[index][ddExteriorY]);
	cache_get_value_name_float(row, "ExteriorZ", DDoorsInfo[index][ddExteriorZ]);
	cache_get_value_name_float(row, "ExteriorA", DDoorsInfo[index][ddExteriorA]);
	cache_get_value_name_float(row, "InteriorX", DDoorsInfo[index][ddInteriorX]);
	cache_get_value_name_float(row, "InteriorY", DDoorsInfo[index][ddInteriorY]);
	cache_get_value_name_float(row, "InteriorZ", DDoorsInfo[index][ddInteriorZ]);
	cache_get_value_name_float(row, "InteriorA", DDoorsInfo[index][ddInteriorA]);
	cache_get_value_name_int(row, "Type", DDoorsInfo[index][ddType]);
	cache_get_value_name_int(row, "Rank", DDoorsInfo[index][ddRank]);
	cache_get_value_name_int(row, "VIP", DDoorsInfo[index][ddVIP]);
	cache_get_value_name_int(row, "Famed", DDoorsInfo[index][ddFamed]);
	cache_get_value_name_int(row, "DPC", DDoorsInfo[index][ddDPC]);
	cache_get_value_name_int(row, "Allegiance", DDoorsInfo[index][ddAllegiance]);
	cache_get_value_name_int(row, "GroupType", DDoorsInfo[index][ddGroupType]);
	cache_get_value_name_int(row, "Faction", DDoorsInfo[index][ddFaction]);
	cache_get_value_name_int(row, "Admin", DDoorsInfo[index][ddAdmin]);
	cache_get_value_name_int(row, "Wanted", DDoorsInfo[index][ddWanted]);
	cache_get_value_name_int(row, "VehicleAble", DDoorsInfo[index][ddVehicleAble]);
	cache_get_value_name_int(row, "Color", DDoorsInfo[index][ddColor]);
	cache_get_value_name_int(row, "PickupModel", DDoorsInfo[index][ddPickupModel]);
	cache_get_value_name(row, "Pass", DDoorsInfo[index][ddPass], 24);
	cache_get_value_name_int(row, "Locked", DDoorsInfo[index][ddLocked]);
	cache_get_value_name_int(row, "LastLogin", DDoorsInfo[index][ddLastLogin]);
	cache_get_value_name_int(row, "Expire", DDoorsInfo[index][ddExpire]);
	cache_get_value_name_int(row, "Inactive", DDoorsInfo[index][ddInactive]);
	cache_get_value_name_int(row, "Ignore", DDoorsInfo[index][ddIgnore]);
	cache_get_value_name_int(row, "Counter", DDoorsInfo[index][ddCounter]);
	CreateDynamicDoor(index);
	return 1;
}

forward OnLoadDynamicDoor(index, revision);
public OnLoadDynamicDoor(index, revision)
{
	if(!(0 <= index < MAX_DDOORS) || DynamicDoorRevision[index] != revision) return 1;
	new rows, id;
	cache_get_row_count(rows);
	if(rows)
	{
		cache_get_value_name_int(0, "id", id);
		if(id == index + 1) return LoadDynamicDoorData(0, index);
	}
	CreateDynamicDoor(index);
	return 1;
}

forward OnLoadDynamicDoors(request);
public OnLoadDynamicDoors(request)
{
	if(request != DynamicDoorLoadRequest) return 1;
	new rows, loaded;
	cache_get_row_count(rows);
	for(new row; row < rows; ++row)
	{
		new id;
		cache_get_value_name_int(row, "id", id);
		if(!(1 <= id <= MAX_DDOORS)) continue;
		LoadDynamicDoorData(row, id - 1);
		++loaded;
	}
	for(new i; i < MAX_DDOORS; ++i)
		if(!IsDynamicDoorLoaded(i)) CreateDynamicDoor(i);
	printf("[LoadDynamicDoors] Loaded %d backing rows from one query.", loaded);
	return 1;
}

stock SaveDynamicDoors()
{
	for(new i; i < MAX_DDOORS; ++i) SaveDynamicDoor(i);
	return 1;
}

stock RehashDynamicDoor(doorid)
{
	return LoadDynamicDoor(doorid);
}

stock RehashDynamicDoors()
{
	return LoadDynamicDoors();
}

forward OnSetDDOwner(playerid, session, doorid, revision, owner);
public OnSetDDOwner(playerid, session, doorid, revision, owner)
{
	if(!(0 <= playerid < MAX_PLAYERS) || !IsPlayerConnected(playerid) || !gPlayerLogged{playerid} || g_arrQueryHandle[playerid] != session) 
	{
		return 1;
	}

	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1 && PlayerInfo[playerid][pFactionModerator] < 2 && PlayerInfo[playerid][pShopTech] < 1) 
	{
		return 1;
	}
	if(!IsDynamicDoorActive(doorid) || DDoorsInfo[doorid][ddType] != 1 || DynamicDoorRevision[doorid] != revision || DDoorsInfo[doorid][ddOwner] != owner)
		return SendClientMessageEx(playerid, COLOR_GREY, "Cua nay da thay doi. Hay dung lai /ddowner.");
	
	new rows, account, level, admin, name[MAX_PLAYER_NAME], message[160];
	cache_get_row_count(rows);
	if(!rows) {
		return SendClientMessageEx(playerid, COLOR_GREY, "Tai khoan do khong ton tai.");
	}
	
	cache_get_value_name_int(0, "id", account);
	cache_get_value_name_int(0, "Level", level);
	cache_get_value_name_int(0, "AdminLevel", admin);
	cache_get_value_name(0, "Username", name, sizeof(name));
	if(level == 1 && admin < 2) {
		return SendClientMessageEx(playerid, COLOR_RED, "Khong the dung /ddowner voi nguoi choi cap 1.");
	}

	DDoorsInfo[doorid][ddOwner] = account;
	format(DDoorsInfo[doorid][ddOwnerName], 42, "%s", name);
	CreateDynamicDoor(doorid);
	SaveDynamicDoor(doorid);
	SendClientMessageEx(playerid, COLOR_WHITE, "Da dat chu so huu la %s.", name);
	format(message, sizeof(message), "%s has edited door ID %d's owner to %s (SQL ID: %d).", GetPlayerNameEx(playerid), doorid, name, account);
	Log("logs/ddedit.log", message);
	return 1;
}

CMD:changedoorpass(playerid, params[])
{
	new doorid = GetClosestDynamicDoor(playerid), password[24];
	if(doorid == -1) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan cua dong.");
	
	if(!((DDoorsInfo[doorid][ddType] == 2 && 0 <= DDoorsInfo[doorid][ddFaction] < MAX_GROUPS && PlayerInfo[playerid][pLeader] == DDoorsInfo[doorid][ddFaction])
		|| (DDoorsInfo[doorid][ddType] == 1 && DDoorsInfo[doorid][ddOwner] == GetPlayerSQLId(playerid))))
	{
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong the doi mat khau o khoa nay.");
	}

	if(strlen(params) > 23 || sscanf(params, "s[24]", password))
		return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /changedoorpass [1-23 characters, or none to remove]");
	
	if(!strcmp(password, "none", true)) password[0] = 0;
	format(DDoorsInfo[doorid][ddPass], 24, "%s", password);
	++DynamicDoorRevision[doorid];
	SaveDynamicDoor(doorid);
	return SendClientMessageEx(playerid, COLOR_WHITE, "Da doi mat khau cua nay.");
}

CMD:lockdoor(playerid, params[])
{
	new doorid = GetClosestDynamicDoor(playerid);
	if(doorid == -1) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan cua dong.");
	
	if(!((DDoorsInfo[doorid][ddType] == 2 && 0 <= DDoorsInfo[doorid][ddFaction] < MAX_GROUPS && PlayerInfo[playerid][pLeader] == DDoorsInfo[doorid][ddFaction])
		|| (DDoorsInfo[doorid][ddType] == 1 && DDoorsInfo[doorid][ddOwner] == GetPlayerSQLId(playerid))))
	{
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong the khoa cua nay.");
	}

	DDoorsInfo[doorid][ddLocked] = !DDoorsInfo[doorid][ddLocked];
	SaveDynamicDoor(doorid);
	return SendClientMessageEx(playerid, COLOR_WHITE, "Cua nay %s.", DDoorsInfo[doorid][ddLocked] ? ("da khoa") : ("da mo khoa"));
}

CMD:doorpass(playerid, params[])
{
	new doorid = GetClosestDynamicDoor(playerid);
	if(doorid == -1) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan cua dong.");
	
	if(!DDoorsInfo[doorid][ddPass][0] || !strcmp(DDoorsInfo[doorid][ddPass], "None", true))
		return SendClientMessageEx(playerid, COLOR_GREY, "Cua nay khong co khoa mat khau.");
	
	SetPVarInt(playerid, "Door", doorid);
	SetPVarInt(playerid, "DoorRevision", DynamicDoorRevision[doorid]);
	return ShowPlayerDialogEx(playerid, DOORLOCK, DIALOG_STYLE_PASSWORD, "Bao mat cua", "Nhap mat khau cua nay.", "Xac nhan", "Huy");
}

CMD:goindoor(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pShopTech] >= 1)
	{
		new doornum;
		if(sscanf(params, "d", doornum)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /goindoor [doornumber]");

		if(doornum < 0 || doornum >= MAX_DDOORS)
		{
			return SendClientMessageEx(playerid, COLOR_GREY, "ID cua phai tu 0 den %d.", MAX_DDOORS - 1);
		}

		if(!IsDynamicDoorActive(doornum)) 
			return SendClientMessageEx(playerid, COLOR_GREY, "Cua do chua duoc cau hinh.");

		SetPlayerInterior(playerid,DDoorsInfo[doornum][ddInteriorInt]);
		SetPlayerPos(playerid,DDoorsInfo[doornum][ddInteriorX],DDoorsInfo[doornum][ddInteriorY],DDoorsInfo[doornum][ddInteriorZ]);
		SetPlayerFacingAngle(playerid,DDoorsInfo[doornum][ddInteriorA]);
		PlayerInfo[playerid][pInt] = DDoorsInfo[doornum][ddInteriorInt];
		PlayerInfo[playerid][pVW] = DDoorsInfo[doornum][ddInteriorVW];
		SetPlayerVirtualWorld(playerid, DDoorsInfo[doornum][ddInteriorVW]);
		if(DDoorsInfo[doornum][ddCustomInterior]) Player_StreamPrep(playerid, DDoorsInfo[doornum][ddInteriorX],DDoorsInfo[doornum][ddInteriorY],DDoorsInfo[doornum][ddInteriorZ], FREEZE_TIME);
	}
	return 1;
}

CMD:gotodoor(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pShopTech] >= 1)
	{
		new doornum;
		if(sscanf(params, "d", doornum)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /gotodoor [doornumber]");

		if(doornum < 0 || doornum >= MAX_DDOORS)
		{
			return SendClientMessageEx(playerid, COLOR_GREY, "ID cua phai tu 0 den %d.", MAX_DDOORS - 1);
		}

		if(!IsDynamicDoorActive(doornum)) 
			return SendClientMessageEx(playerid, COLOR_GREY, "Cua do chua duoc cau hinh.");

		SetPlayerInterior(playerid,DDoorsInfo[doornum][ddExteriorInt]);
		SetPlayerPos(playerid,DDoorsInfo[doornum][ddExteriorX],DDoorsInfo[doornum][ddExteriorY],DDoorsInfo[doornum][ddExteriorZ]);
		SetPlayerFacingAngle(playerid,DDoorsInfo[doornum][ddExteriorA]);
		PlayerInfo[playerid][pInt] = DDoorsInfo[doornum][ddExteriorInt];
		SetPlayerVirtualWorld(playerid, DDoorsInfo[doornum][ddExteriorVW]);
		PlayerInfo[playerid][pVW] = DDoorsInfo[doornum][ddExteriorVW];
		if(DDoorsInfo[doornum][ddCustomExterior]) Player_StreamPrep(playerid, DDoorsInfo[doornum][ddExteriorX],DDoorsInfo[doornum][ddExteriorY],DDoorsInfo[doornum][ddExteriorZ], FREEZE_TIME);
	}
	return 1;
}

CMD:ddstatus(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1 && PlayerInfo[playerid][pShopTech] < 1)
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	
	new doorid;
	if(sscanf(params, "d", doorid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /ddstatus [doorid]");
	
	if(!IsDynamicDoorLoaded(doorid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "ID cua khong hop le hoac chua tai.");
	
	SendClientMessageEx(playerid, COLOR_GREEN, "Cua #%d: %.90s", doorid, DDoorsInfo[doorid][ddDescription]);
	SendClientMessageEx(playerid, COLOR_WHITE, "Ngoai: %.2f, %.2f, %.2f | VW: %d | Interior: %d", DDoorsInfo[doorid][ddExteriorX], DDoorsInfo[doorid][ddExteriorY], DDoorsInfo[doorid][ddExteriorZ], DDoorsInfo[doorid][ddExteriorVW], DDoorsInfo[doorid][ddExteriorInt]);
	SendClientMessageEx(playerid, COLOR_WHITE, "Trong: %.2f, %.2f, %.2f | VW: %d | Interior: %d", DDoorsInfo[doorid][ddInteriorX], DDoorsInfo[doorid][ddInteriorY], DDoorsInfo[doorid][ddInteriorZ], DDoorsInfo[doorid][ddInteriorVW], DDoorsInfo[doorid][ddInteriorInt]);
	SendClientMessageEx(playerid, COLOR_WHITE, "Chu: %s | ID tai khoan: %d | Loai: %d | Hang: %d", DDoorsInfo[doorid][ddOwnerName], DDoorsInfo[doorid][ddOwner], DDoorsInfo[doorid][ddType], DDoorsInfo[doorid][ddRank]);
	SendClientMessageEx(playerid, COLOR_WHITE, "VIP: %d | Famed: %d | DPC: %d | Phe: %d | Loai to chuc: %d | To chuc: %d", DDoorsInfo[doorid][ddVIP], DDoorsInfo[doorid][ddFamed], DDoorsInfo[doorid][ddDPC], DDoorsInfo[doorid][ddAllegiance], DDoorsInfo[doorid][ddGroupType], DDoorsInfo[doorid][ddFaction]);
	SendClientMessageEx(playerid, COLOR_WHITE, "Admin: %d | Truy na: %d | Xe: %d | Khoa: %d | Mat khau: %s", DDoorsInfo[doorid][ddAdmin], DDoorsInfo[doorid][ddWanted], DDoorsInfo[doorid][ddVehicleAble], DDoorsInfo[doorid][ddLocked], DDoorsInfo[doorid][ddPass][0] && strcmp(DDoorsInfo[doorid][ddPass], "None", true) ? ("Da dat") : ("Chua dat"));
	SendClientMessageEx(playerid, COLOR_WHITE, "Pickup: %d | Mau: %d | Noi that tu tao: %d | Ben ngoai tu tao: %d", DDoorsInfo[doorid][ddPickupModel], DDoorsInfo[doorid][ddColor], DDoorsInfo[doorid][ddCustomInterior], DDoorsInfo[doorid][ddCustomExterior]);
	return 1;
}

CMD:ddnear(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1 && PlayerInfo[playerid][pShopTech] < 1)
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	
	new world = GetPlayerVirtualWorld(playerid), interior = GetPlayerInterior(playerid), count;
	if(params[0] && sscanf(params, "d", world)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /ddnear [world, -1 for all worlds]");
	
	if(world < -1) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Virtual world khong hop le.");
	
	SendClientMessageEx(playerid, COLOR_RED, "Cua dong trong 30 m, world %d (-1 = moi world), interior %d:", world, interior);
	for(new i; i < MAX_DDOORS; ++i)
	{
		if(!IsDynamicDoorActive(i)) continue;
		if((world == -1 || DDoorsInfo[i][ddInteriorVW] == world) && DDoorsInfo[i][ddInteriorInt] == interior)
		{
			new Float:distance = GetPlayerDistanceFromPoint(playerid, DDoorsInfo[i][ddInteriorX], DDoorsInfo[i][ddInteriorY], DDoorsInfo[i][ddInteriorZ]);
			if(distance <= 30.0)
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "Ben trong | Cua #%d | %.1f m | VW: %d | Interior: %d", i, distance, DDoorsInfo[i][ddInteriorVW], DDoorsInfo[i][ddInteriorInt]);
				++count;
			}
		}
		if((world == -1 || DDoorsInfo[i][ddExteriorVW] == world) && DDoorsInfo[i][ddExteriorInt] == interior)
		{
			new Float:distance = GetPlayerDistanceFromPoint(playerid, DDoorsInfo[i][ddExteriorX], DDoorsInfo[i][ddExteriorY], DDoorsInfo[i][ddExteriorZ]);
			if(distance <= 30.0)
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "Ben ngoai | Cua #%d | %.1f m | VW: %d | Interior: %d", i, distance, DDoorsInfo[i][ddExteriorVW], DDoorsInfo[i][ddExteriorInt]);
				++count;
			}
		}
	}
	if(!count) SendClientMessageEx(playerid, COLOR_GREY, "Khong tim thay cua gan day.");
	return 1;
}

CMD:ddnext(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pShopTech] >= 1)
	{
		SendClientMessageEx(playerid, COLOR_RED, "* Dang tim cua dong trong tiep theo...");
		for(new x;x<MAX_DDOORS;x++)
		{
		    if(IsDynamicDoorLoaded(x) && !IsDynamicDoorActive(x))
		    {
		        SendClientMessageEx(playerid, COLOR_WHITE, "%d co the su dung.", x);
		        return 1;
			}
		}
		SendClientMessageEx(playerid, COLOR_GREY, "Khong con o cua trong da tai.");
	}
	else
	{
	    SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
		return 1;
	}
	return 1;
}

CMD:ddname(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pShopTech] >= 1)
	{
		new
			szName[129],
			message[224],
			iDoorID;

		if(sscanf(params, "ds[129]", iDoorID, szName)) {
			return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /ddname [doorid] [name]");
		}
		else if(strlen(szName) > 127) return SendClientMessageEx(playerid, COLOR_GREY, "Ten cua chi duoc toi da 127 ky tu.");
		else if(!IsDynamicDoorLoaded(iDoorID)) {
			return SendClientMessageEx(playerid, COLOR_GREY, "Cua duoc chon khong hop le.");
		}
		else if(strfind(szName, "\r") != -1 || strfind(szName, "\n") != -1) {
			return SendClientMessageEx(playerid, COLOR_GREY, "Khong duoc dung ky tu xuong dong.");
		}

		strcat((DDoorsInfo[iDoorID][ddDescription][0] = 0, DDoorsInfo[iDoorID][ddDescription]), szName, 128);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da doi ten cua nay.");

		CreateDynamicDoor(iDoorID);
		SaveDynamicDoor(iDoorID);

		format(message, sizeof(message), "%s has edited door ID %d's name to %s.", GetPlayerNameEx(playerid), iDoorID, DDoorsInfo[iDoorID][ddDescription]);
		Log("logs/ddedit.log", message);
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:ddowner(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pFactionModerator] >= 2 || PlayerInfo[playerid][pShopTech] >= 1)
	{
		new playername[MAX_PLAYER_NAME], doorid, szName[128];
		if(sscanf(params, "ds[24]", doorid, playername)) return SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /ddowner [door] [player name]");

		if(!IsDynamicDoorActive(doorid)) return SendClientMessageEx(playerid, COLOR_GREY, "ID cua khong hop le hoac chua cau hinh.");
		if(DDoorsInfo[doorid][ddType] != 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Cua nay khong thuoc nguoi choi!");
		new giveplayerid = ReturnUser(playername);
		if(IsPlayerConnected(giveplayerid))
		{
			if(!gPlayerLogged{giveplayerid}) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi do chua dang nhap.");
			if(PlayerInfo[giveplayerid][pLevel] == 1 && PlayerInfo[giveplayerid][pAdmin] < 2) return SendClientMessageEx(playerid, COLOR_RED, "Khong the dung /ddowner voi nguoi choi cap 1");
			strcat((DDoorsInfo[doorid][ddOwnerName][0] = 0, DDoorsInfo[doorid][ddOwnerName]), GetPlayerNameEx(giveplayerid), 24);
			DDoorsInfo[doorid][ddOwner] = GetPlayerSQLId(giveplayerid);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi chu so huu cua nay.");

			CreateDynamicDoor(doorid);
			SaveDynamicDoor(doorid);
			
			format(szName, sizeof(szName), "%s has edited door ID %d's owner to %s (SQL ID: %d).", GetPlayerNameEx(playerid), doorid, GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
			Log("logs/ddedit.log", szName);
		}
		else
		{
			new query[192];
			mysql_format(MainPipeline, query, sizeof(query), "SELECT `id`, `Username`, `Level`, `AdminLevel` FROM `accounts` WHERE `Username`='%e'", playername);
			mysql_tquery(MainPipeline, query, "OnSetDDOwner", "iiiii", playerid, g_arrQueryHandle[playerid], doorid, DynamicDoorRevision[doorid], DDoorsInfo[doorid][ddOwner]);
		}
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	return 1;
}

CMD:ddpass(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1 && PlayerInfo[playerid][pShopTech] < 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");

	new string[128],
		doorid,
		doorpass[25];

	if(sscanf(params, "ds[25]", doorid, doorpass)) { 
		SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /ddpass [doorid] [pass]"); 
		SendClientMessageEx(playerid, COLOR_WHITE, "De xoa mat khau cua, dat mat khau la 'none'"); 
		return 1; 
	}

	if(strlen(doorpass) > 23) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Mat khau cua chi duoc toi da 23 ky tu.");
	
	if(!IsDynamicDoorLoaded(doorid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "ID cua khong hop le hoac chua tai.");
	
	if(!strcmp(doorpass, "none", true)) doorpass[0] = 0;
	
	++DynamicDoorRevision[doorid];
	format(DDoorsInfo[doorid][ddPass], 24, "%s", doorpass);
	SendClientMessageEx(playerid, COLOR_WHITE, "Da doi mat khau cua do.");
	SaveDynamicDoor(doorid);
	format(string, sizeof(string), "%s has edited DoorID %d's password.", GetPlayerNameEx(playerid), doorid);
	Log("logs/ddedit.log", string);
	return 1;
}

CMD:ddedit(playerid, params[])
{
 	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pShopTech] >= 1)
	{
		new string[128], choice[32], doorid, amount;
		if(sscanf(params, "s[32]dD(0)", choice, doorid, amount))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /ddedit [name] [doorid] [amount]");
			SendClientMessageEx(playerid, COLOR_GREY, "Tuy chon: Exterior, Interior, CustomInterior, CustomExterior, Type, Rank, VIP, Famed");
			SendClientMessageEx(playerid, COLOR_GREY, "Allegiance, GroupType, Faction, Wanted, Admin, VehicleAble, Color, PickupModel, Delete");
			return 1;
		}

		if(!IsDynamicDoorLoaded(doorid))
		{
			SendClientMessageEx( playerid, COLOR_WHITE, "ID cua khong hop le!");
			return 1;
		}

		if(strcmp(choice, "interior", true) && strcmp(choice, "exterior", true) && strcmp(choice, "custominterior", true)
			&& strcmp(choice, "customexterior", true) && strcmp(choice, "dpc", true) && strcmp(choice, "delete", true))
		{
			if(sscanf(params, "{s[32]d}d", amount)) return SendClientMessageEx(playerid, COLOR_GREY, "Tuy chon nay can gia tri so.");
			if((!strcmp(choice, "type", true) && !(0 <= amount <= 2))
				|| (!strcmp(choice, "rank", true) && !(-1 <= amount < MAX_GROUP_RANKS))
				|| (!strcmp(choice, "faction", true) && !(0 <= amount <= MAX_GROUPS))
				|| (!strcmp(choice, "grouptype", true) && !(0 <= amount < MAX_GROUP_TYPES))
				|| (!strcmp(choice, "allegiance", true) && !(0 <= amount < MAX_GROUP_ALLEGIANCES))
				|| ((!strcmp(choice, "vehicleable", true) || !strcmp(choice, "wanted", true)) && !(0 <= amount <= 1))
				|| (!strcmp(choice, "color", true) && !(-1 <= amount <= 12))
				|| (!strcmp(choice, "pickupmodel", true) && !(-1 <= amount <= 25))
				|| ((!strcmp(choice, "vip", true) || !strcmp(choice, "famed", true) || !strcmp(choice, "admin", true)) && amount < 0))
			{
				return SendClientMessageEx(playerid, COLOR_GREY, "Gia tri vuot gioi han cho phep cua tuy chon nay.");
			}
		}

		if(strcmp(choice, "interior", true) == 0)
		{
			new Float:pos[3];
			GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
			format(szMiscArray, sizeof(szMiscArray), "%s has edited DoorID %d's Interior (B: %f, %f, %f | A: %f, %f, %f)", GetPlayerNameEx(playerid), doorid, DDoorsInfo[doorid][ddInteriorX], DDoorsInfo[doorid][ddInteriorY], DDoorsInfo[doorid][ddInteriorZ], pos[0], pos[1], pos[2]);
			Log("logs/ddedit.log", szMiscArray);
			GetPlayerPos(playerid, DDoorsInfo[doorid][ddInteriorX], DDoorsInfo[doorid][ddInteriorY], DDoorsInfo[doorid][ddInteriorZ]);
			GetPlayerFacingAngle(playerid, DDoorsInfo[doorid][ddInteriorA]);
			DDoorsInfo[doorid][ddInteriorInt] = GetPlayerInterior(playerid);
			DDoorsInfo[doorid][ddInteriorVW] = GetPlayerVirtualWorld(playerid);
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da doi noi that!");
			SaveDynamicDoor(doorid);
			CreateDynamicDoor(doorid);
			return 1;
		}
		else if(strcmp(choice, "custominterior", true) == 0)
		{
			if(DDoorsInfo[doorid][ddCustomInterior] == 0)
			{
				DDoorsInfo[doorid][ddCustomInterior] = 1;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da dat cua dung noi that tu tao!");
			}
			else
			{
				DDoorsInfo[doorid][ddCustomInterior] = 0;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da dat cua dung noi that thuong!");
			}
			SaveDynamicDoor(doorid);
			format(string, sizeof(string), "%s has edited DoorID %d's CustomInterior.", GetPlayerNameEx(playerid), doorid);
			Log("logs/ddedit.log", string);
			return 1;
		}
		else if(strcmp(choice, "customexterior", true) == 0)
		{
			if(DDoorsInfo[doorid][ddCustomExterior] == 0)
			{
				DDoorsInfo[doorid][ddCustomExterior] = 1;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da dat cua dung ben ngoai tu tao!");
			}
			else
			{
				DDoorsInfo[doorid][ddCustomExterior] = 0;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da dat cua dung ben ngoai thuong!");
			}
			SaveDynamicDoor(doorid);
			CreateDynamicDoor(doorid);
			format(string, sizeof(string), "%s has edited DoorID %d's CustomExterior.", GetPlayerNameEx(playerid), doorid);
			Log("logs/ddedit.log", string);
			return 1;
		}
		else if(strcmp(choice, "exterior", true) == 0)
		{
			new Float:pos[3];
			GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
			format(szMiscArray, sizeof(szMiscArray), "%s has edited DoorID %d's Exterior (B: %f, %f, %f | A: %f, %f, %f)", GetPlayerNameEx(playerid), doorid, DDoorsInfo[doorid][ddExteriorX], DDoorsInfo[doorid][ddExteriorY], DDoorsInfo[doorid][ddExteriorZ], pos[0], pos[1], pos[2]);
			Log("logs/ddedit.log", szMiscArray);
			GetPlayerPos(playerid, DDoorsInfo[doorid][ddExteriorX], DDoorsInfo[doorid][ddExteriorY], DDoorsInfo[doorid][ddExteriorZ]);
			GetPlayerFacingAngle(playerid, DDoorsInfo[doorid][ddExteriorA]);
			DDoorsInfo[doorid][ddExteriorVW] = GetPlayerVirtualWorld(playerid);
			DDoorsInfo[doorid][ddExteriorInt] = GetPlayerInterior(playerid);
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da doi vi tri ben ngoai!");

			SaveDynamicDoor(doorid);
			CreateDynamicDoor(doorid);
		}
		else if(strcmp(choice, "type", true) == 0)
		{
			DDoorsInfo[doorid][ddType] = amount;

			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi loai thanh %d.", amount);
			switch(DDoorsInfo[doorid][ddType])
			{
				case 1:
				{
					if(DDoorsInfo[doorid][ddOwner] == -1)
					{
						format(DDoorsInfo[doorid][ddOwnerName], 42, "Nobody");
						SendClientMessageEx(playerid, COLOR_GREY, "Dung /ddowner de dat chu so huu cua nay.");
					}
				}
				case 2:
				{
					DDoorsInfo[doorid][ddOwner] = -1;
					if(0 <= DDoorsInfo[doorid][ddFaction] < MAX_GROUPS)
						format(DDoorsInfo[doorid][ddOwnerName], 42, "%s", arrGroupData[DDoorsInfo[doorid][ddFaction]][g_szGroupName]);
					else
					{
						format(DDoorsInfo[doorid][ddOwnerName], 42, "Nobody");
						SendClientMessageEx(playerid, COLOR_GREY, "Dung /ddedit faction de dat to chuc cho cua nay.");
					}
				}
				default:
				{
					DDoorsInfo[doorid][ddOwner] = -1;
					format(DDoorsInfo[doorid][ddOwnerName], 42, "Nobody");
				}
			}
			SaveDynamicDoor(doorid);
			CreateDynamicDoor(doorid);

			format(string, sizeof(string), "%s has edited DoorID %d's type.", GetPlayerNameEx(playerid), doorid);
			Log("logs/ddedit.log", string);
			return 1;
		}
		else if(strcmp(choice, "rank", true) == 0)
		{
			DDoorsInfo[doorid][ddRank] = amount;

			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi hang thanh %d.", amount);

			SaveDynamicDoor(doorid);
			format(string, sizeof(string), "%s has edited DoorID %d's rank.", GetPlayerNameEx(playerid), doorid);
			Log("logs/ddedit.log", string);
			return 1;
		}
		else if(strcmp(choice, "vip", true) == 0)
		{
			DDoorsInfo[doorid][ddVIP] = amount;

			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi cap VIP thanh %d.", amount);

			SaveDynamicDoor(doorid);
			format(string, sizeof(string), "%s has edited DoorID %d's VIP Level.", GetPlayerNameEx(playerid), doorid);
			Log("logs/ddedit.log", string);
			return 1;
		}
		else if(strcmp(choice, "famed", true) == 0)
		{
			DDoorsInfo[doorid][ddFamed] = amount;

			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi cap Famed thanh %d.", amount);

			SaveDynamicDoor(doorid);
			format(string, sizeof(string), "%s has edited DoorID %d's Famed Level.", GetPlayerNameEx(playerid), doorid);
			Log("logs/ddedit.log", string);
			return 1;
		}
		else if(strcmp(choice, "dpc", true) == 0)
		{
			if(DDoorsInfo[doorid][ddDPC] == 0)
			{
				DDoorsInfo[doorid][ddDPC] = 1;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da dat cua thanh DPC!");
			}
			else
			{
				DDoorsInfo[doorid][ddDPC] = 0;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da dat cua thanh thuong (khong con DPC)!");
			}
			SaveDynamicDoor(doorid);
			format(string, sizeof(string), "%s has set DoorID %d's DPC value.", GetPlayerNameEx(playerid), doorid);
			Log("logs/ddedit.log", string);
			return 1;
		}
		else if(strcmp(choice, "allegiance", true) == 0)
		{
			DDoorsInfo[doorid][ddAllegiance] = amount;

			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi phe thanh %d.", amount);

			SaveDynamicDoor(doorid);
			format(string, sizeof(string), "%s has edited DoorID %d's Allegiance to %d.", GetPlayerNameEx(playerid), doorid, amount);
			Log("logs/ddedit.log", string);
			return 1;
		}
		else if(strcmp(choice, "grouptype", true) == 0)
		{
			DDoorsInfo[doorid][ddGroupType] = amount;

			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi loai to chuc thanh %d.", amount);

			SaveDynamicDoor(doorid);
			format(string, sizeof(string), "%s has edited DoorID %d's Group Type to %d.", GetPlayerNameEx(playerid), doorid, amount);
			Log("logs/ddedit.log", string);
			return 1;
		}
		else if(strcmp(choice, "faction", true) == 0)
		{
			DDoorsInfo[doorid][ddFaction] = amount-1;

			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi to chuc thanh %d.", amount);

			if(DDoorsInfo[doorid][ddType] == 2)
			{
				DDoorsInfo[doorid][ddOwner] = -1;
				if(DDoorsInfo[doorid][ddFaction] == INVALID_GROUP_ID) {
					format(DDoorsInfo[doorid][ddOwnerName], 42, "Nobody");
				}
				else {
					strcat((DDoorsInfo[doorid][ddOwnerName][0] = 0, DDoorsInfo[doorid][ddOwnerName]), arrGroupData[DDoorsInfo[doorid][ddFaction]][g_szGroupName], 42);
				}

				CreateDynamicDoor(doorid);
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Dung '/ddedit type %d 2' de cap nhat chu so huu cua nay.", doorid);
			}

			SaveDynamicDoor(doorid);
			format(string, sizeof(string), "%s has edited DoorID %d's Faction.", GetPlayerNameEx(playerid), doorid);
			Log("logs/ddedit.log", string);
			return 1;
		}
		else if(strcmp(choice, "admin", true) == 0)
		{
			DDoorsInfo[doorid][ddAdmin] = amount;

			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi cap Admin thanh %d.", amount);

			SaveDynamicDoor(doorid);
			format(string, sizeof(string), "%s has edited DoorID %d's Admin Level.", GetPlayerNameEx(playerid), doorid);
			Log("logs/ddedit.log", string);
			return 1;
		}
		else if(strcmp(choice, "wanted", true) == 0)
		{
			DDoorsInfo[doorid][ddWanted] = amount;

			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi muc truy na thanh %d.", amount);

			SaveDynamicDoor(doorid);
			format(string, sizeof(string), "%s has edited DoorID %d's Wanted.", GetPlayerNameEx(playerid), doorid);
			Log("logs/ddedit.log", string);
			return 1;
		}
		else if(strcmp(choice, "vehicleable", true) == 0)
		{
			DDoorsInfo[doorid][ddVehicleAble] = amount;

			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi VehicleAble thanh %d.", amount);

			SaveDynamicDoor(doorid);
			format(string, sizeof(string), "%s has edited DoorID %d's VehicleAble.", GetPlayerNameEx(playerid), doorid);
			Log("logs/ddedit.log", string);
			return 1;
		}
		else if(strcmp(choice, "color", true) == 0)
		{
			DDoorsInfo[doorid][ddColor] = amount;

			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi mau thanh %d.", amount);

			SaveDynamicDoor(doorid);
			CreateDynamicDoor(doorid);
			format(string, sizeof(string), "%s has edited DoorID %d's Color.", GetPlayerNameEx(playerid), doorid);
			Log("logs/ddedit.log", string);
			return 1;
		}
		else if(strcmp(choice, "pickupmodel", true) == 0)
		{
			DDoorsInfo[doorid][ddPickupModel] = amount;

			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi model pickup thanh %d.", amount);

			SaveDynamicDoor(doorid);
			CreateDynamicDoor(doorid);
			format(string, sizeof(string), "%s has edited DoorID %d's PickupModel.", GetPlayerNameEx(playerid), doorid);
			Log("logs/ddedit.log", string);
			return 1;
		}
		else if(strcmp(choice, "delete", true) == 0)
		{
			if(!IsDynamicDoorActive(doorid)) return SendClientMessageEx(playerid, COLOR_GREY, "Cua do da trong.");
			DeleteDynamicDoor(doorid, playerid);
			return SendClientMessageEx(playerid, COLOR_WHITE, "Da xoa cua ID %d.", doorid);
		}
		else return SendClientMessageEx(playerid, COLOR_GREY, "Tuy chon cua khong ro. Dung /ddedit de xem tuy chon.");
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:ddmove(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1)
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	
	new doorid, target, percent, minimum, fine, choice[16];
	if(sscanf(params, "s[16]dudd", choice, doorid, target, percent, minimum))
		return SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /ddmove [interior/exterior] [doorid] [playerid] [fine percent 0-100, 0 = free] [minimum fine]");
	
	if(!IsDynamicDoorActive(doorid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "ID cua khong hop le hoac chua cau hinh.");
	
	if(!(0 <= target < MAX_PLAYERS) || !IsPlayerConnected(target) || !gPlayerLogged{target})
		return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi do chua dang nhap.");
	
	if(strcmp(choice, "interior", true) && strcmp(choice, "exterior", true))
		return SendClientMessageEx(playerid, COLOR_GREY, "Chon interior hoac exterior.");
	
	if(GetPVarInt(target, "FurniturePurchaseUncertain"))
		return SendClientMessageEx(playerid, COLOR_GREY, "Tai khoan do dang cho ket qua mua noi that.");
	
	if(!CalculatePropertyMoveFine(target, percent, minimum, fine))
		return SendClientMessageEx(playerid, COLOR_GREY, "Phi khong hop le hoac tien phat vuot gioi han ho tro.");
	
	if(!strcmp(choice, "interior", true))
	{
		GetPlayerPos(playerid, DDoorsInfo[doorid][ddInteriorX], DDoorsInfo[doorid][ddInteriorY], DDoorsInfo[doorid][ddInteriorZ]);
		GetPlayerFacingAngle(playerid, DDoorsInfo[doorid][ddInteriorA]);
		DDoorsInfo[doorid][ddInteriorInt] = GetPlayerInterior(playerid);
		DDoorsInfo[doorid][ddInteriorVW] = GetPlayerVirtualWorld(playerid);
	}
	else
	{
		GetPlayerPos(playerid, DDoorsInfo[doorid][ddExteriorX], DDoorsInfo[doorid][ddExteriorY], DDoorsInfo[doorid][ddExteriorZ]);
		GetPlayerFacingAngle(playerid, DDoorsInfo[doorid][ddExteriorA]);
		DDoorsInfo[doorid][ddExteriorVW] = GetPlayerVirtualWorld(playerid);
		DDoorsInfo[doorid][ddExteriorInt] = GetPlayerInterior(playerid);
	}
	
	CreateDynamicDoor(doorid);
	SaveDynamicDoor(doorid);
	new message[192];
	format(message, sizeof(message), "%s has edited DoorID %d's %s.", GetPlayerNameEx(playerid), doorid, choice);
	Log("logs/ddedit.log", message);
	SendClientMessageEx(playerid, COLOR_WHITE, "Da doi %s cua cua.", choice);
	if(fine > 0)
	{
		GivePlayerCashEx(target, TYPE_ONHAND, -fine);
		format(message, sizeof(message), "AdmCmd: %s(%d) was fined $%s by %s, reason: Dynamic Door Move", GetPlayerNameEx(target), GetPlayerSQLId(target), number_format(fine), GetPlayerNameEx(playerid));
		Log("logs/admin.log", message);
		SendClientMessageToAllEx(COLOR_LIGHTRED, "AdmCmd: %s bi phat $%s boi %s, ly do: Doi vi tri cua dong", GetPlayerNameEx(target), number_format(fine), GetPlayerNameEx(playerid));
	}
	return 1;
}

forward DeleteDynamicDoor(doorid, adminid);
public DeleteDynamicDoor(doorid, adminid)
{
	if(!IsDynamicDoorLoaded(doorid)) return 0;
	format(DDoorsInfo[doorid][ddDescription], 128, "None");
	DDoorsInfo[doorid][ddOwner] = -1;
	format(DDoorsInfo[doorid][ddOwnerName], 42, "Nobody");
	DDoorsInfo[doorid][ddCustomInterior] = 0;
	DDoorsInfo[doorid][ddExteriorVW] = 0;
	DDoorsInfo[doorid][ddExteriorInt] = 0;
	DDoorsInfo[doorid][ddInteriorVW] = 0;
	DDoorsInfo[doorid][ddInteriorInt] = 0;
	DDoorsInfo[doorid][ddExteriorX] = 0.0;
	DDoorsInfo[doorid][ddExteriorY] = 0.0;
	DDoorsInfo[doorid][ddExteriorZ] = 0.0;
	DDoorsInfo[doorid][ddExteriorA] = 0.0;
	DDoorsInfo[doorid][ddInteriorX] = 0.0;
	DDoorsInfo[doorid][ddInteriorY] = 0.0;
	DDoorsInfo[doorid][ddInteriorZ] = 0.0;
	DDoorsInfo[doorid][ddInteriorA] = 0.0;
	DDoorsInfo[doorid][ddCustomExterior] = 0;
	DDoorsInfo[doorid][ddType] = 0;
	DDoorsInfo[doorid][ddRank] = 0;
	DDoorsInfo[doorid][ddVIP] = 0;
	DDoorsInfo[doorid][ddFamed] = 0;
	DDoorsInfo[doorid][ddDPC] = 0;
	DDoorsInfo[doorid][ddAllegiance] = 0;
	DDoorsInfo[doorid][ddGroupType] = 0;
	DDoorsInfo[doorid][ddFaction] = INVALID_GROUP_ID;
	DDoorsInfo[doorid][ddAdmin] = 0;
	DDoorsInfo[doorid][ddWanted] = 0;
	DDoorsInfo[doorid][ddVehicleAble] = 0;
	DDoorsInfo[doorid][ddColor] = 0;
	DDoorsInfo[doorid][ddPickupModel] = 0;
	DDoorsInfo[doorid][ddPass][0] = 0;
	DDoorsInfo[doorid][ddLocked] = 0;
	DDoorsInfo[doorid][ddLastLogin] = 0;
	DDoorsInfo[doorid][ddExpire] = 0;
	DDoorsInfo[doorid][ddInactive] = 0;
	DDoorsInfo[doorid][ddIgnore] = 0;
	DDoorsInfo[doorid][ddCounter] = 0;
	CreateDynamicDoor(doorid);
	SaveDynamicDoor(doorid);
	szMiscArray[0] = 0;
	format(szMiscArray, sizeof(szMiscArray), "%s has deleted door id %d", adminid != INVALID_PLAYER_ID ? GetPlayerNameEx(adminid) : ("(Inactive Player Resource System)"), doorid);
	Log("logs/ddedit.log", szMiscArray);
	return 1;
}