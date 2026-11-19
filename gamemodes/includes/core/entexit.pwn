/*
	Author: Jingles
	Modified: Le Tuan Kiet (aujiz11)
	
	Originally, there were two functions responsible for handling property entry and exit. 
	However, the original implementation still relied on iterating through all properties 
	to check the player's position against their entrance and exit coordinates.

	Jingles introduced a new approach using Dynamic Areas instead of loops to detect player 
	proximity. However, this implementation was incomplete and was never officially adopted.

	I have since fixed the issues with the property area system, improved its reliability, 
	and ensured that the entry/exit mechanism operates more smoothly and efficiently.

*/

#include <YSI_Coding\y_hooks>

#define 		ENTRANCE_SHORTCUT		KEY_NO

new DoorTimer[MAX_PLAYERS];

hook OnPlayerConnect(playerid) {
	DoorTimer[playerid] = gettime();
	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {

	if(newkeys & ENTRANCE_SHORTCUT) {
		EntExit_GetID(playerid);
	}
	return 1;
}

stock EntExit_GetID(playerid)
{
	new areas[128], data[2];
	Streamer_Update(playerid, STREAMER_TYPE_AREA);
	new count = GetPlayerNumberDynamicAreas(playerid);
	if(count > sizeof(areas))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Entrance unavailable. Please contact an administrator.");
		return 1;
	}
	count = GetPlayerDynamicAreas(playerid, areas, sizeof(areas));

	new selectedType, selectedID = -1, selectedPriority = 4;
	new bool:selectedExit;
	for(new n; n < count; n++)
	{
		if(Streamer_GetArrayDataLength(STREAMER_TYPE_AREA, areas[n], E_STREAMER_EXTRA_ID) != sizeof(data)) 
		{
			continue;
		}
		
		Streamer_GetArrayData(STREAMER_TYPE_AREA, areas[n], E_STREAMER_EXTRA_ID, data, sizeof(data));
		new id = data[1], priority, bool:exiting;
		switch(data[0])
		{
			case STREAMER_AREATYPE_DOOR:
			{
				if(id < 0 || id >= MAX_DDOORS) continue;
				if(areas[n] == DDoorsInfo[id][ddAreaID]) exiting = false;
				else if(areas[n] == DDoorsInfo[id][ddAreaID_int]) exiting = true;
				else continue;
				priority = 0;
			}
			case STREAMER_AREATYPE_HOUSE:
			{
				if(id < 0 || id >= MAX_HOUSES) continue;
				if(areas[n] == HouseInfo[id][hAreaID][0]) exiting = false;
				else if(areas[n] == HouseInfo[id][hAreaID][1]) exiting = true;
				else continue;
				priority = 1;
			}
			case STREAMER_AREATYPE_GARAGE:
			{
				if(id < 0 || id >= MAX_GARAGES) continue;
				if(areas[n] == GarageInfo[id][gar_AreaID]) exiting = false;
				else if(areas[n] == GarageInfo[id][gar_AreaID_int]) exiting = true;
				else continue;
				priority = 2;
			}
			case STREAMER_AREATYPE_BUSINESS:
			{
				if(id < 0 || id >= MAX_BUSINESSES) continue;
				if(areas[n] == Businesses[id][bAreaID][0]) exiting = false;
				else if(areas[n] == Businesses[id][bAreaID][1]) exiting = true;
				else continue;
				priority = 3;
			}
			default: continue;
		}
		if(priority > selectedPriority) continue;
		if(priority == selectedPriority && (id > selectedID || (id == selectedID && exiting))) continue;
		selectedType = data[0];
		selectedID = id;
		selectedPriority = priority;
		selectedExit = exiting;
	}

	if(selectedID != -1)
	{
		switch(selectedType)
		{
			case STREAMER_AREATYPE_DOOR:
			{
				if(selectedExit) return DDoor_Exit(playerid, selectedID);
				return DDoor_Enter(playerid, selectedID);
			}
			case STREAMER_AREATYPE_HOUSE:
			{
				if(selectedExit) return House_Exit(playerid, selectedID);
				return House_Enter(playerid, selectedID);
			}
			case STREAMER_AREATYPE_GARAGE:
			{
				if(selectedExit) return Garage_Exit(playerid, selectedID);
				return Garage_Enter(playerid, selectedID);
			}
			case STREAMER_AREATYPE_BUSINESS:
			{
				if(selectedExit) return Business_Exit(playerid, selectedID);
				return Business_Enter(playerid, selectedID);
			}
		}
	}

	if(!IsPlayerInAnyVehicle(playerid))
	{
		if(InsidePlane[playerid] != INVALID_VEHICLE_ID) return Vehicle_Exit(playerid);
		for(new i = 1; i < MAX_VEHICLES; i++)
		{
			new model = GetVehicleModel(i);
			if((model == 508 || model == 519 || model == 553 || model == 570) && IsPlayerInRangeOfVehicle(playerid, i, 5.0)) return Vehicle_Enter(playerid, i);
		}
	}
	return 1;
}

CMD:enter(playerid)
{
	return EntExit_GetID(playerid);
}

CMD:exit(playerid)
{
	return EntExit_GetID(playerid);
}

hook OnPlayerStateChange(playerid, newstate, oldstate) {

	if(newstate == PLAYER_STATE_PASSENGER) {
		new iVehID = GetPlayerVehicleID(playerid);
		if(iVehID == 570) Vehicle_Enter(playerid, iVehID);
	}
}

stock Vehicle_Enter(playerid, i) {

	if(CarryCrate[playerid] != -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "You can't take crates into this type of interior!");
	ClearAnimationsEx(playerid);

	switch(GetVehicleModel(i)) {

		case 508: { // Journey
			SetPlayerPos(playerid, 2820.2109,1527.8270,-48.9141+2500);
			Player_StreamPrep(playerid,2820.2109,1527.8270,-48.9141+2500, FREEZE_TIME);
			SetPlayerFacingAngle(playerid, 270.0);
			PlayerInfo[playerid][pInt] = 1;
			SetPlayerInterior(playerid, 1);
		}
		case 519: { // Shamal
			SetPlayerPos(playerid, 2.509036, 23.118730, 1199.593750);
			SetPlayerFacingAngle(playerid, 82.14);
			PlayerInfo[playerid][pInt] = 1;
			SetPlayerInterior(playerid, 1);
		}
		case 553: { // Nevada
			SetPlayerPos(playerid, 315.9396, 973.2628, 1961.5985);
			SetPlayerFacingAngle(playerid, 2.7);
			PlayerInfo[playerid][pInt] = 9;
			SetPlayerInterior(playerid, 9);
		}
		case 570: {
			Player_StreamPrep(playerid, 2022.0273, 2235.2402, 2103.9536+2500, FREEZE_TIME);
            SetPlayerFacingAngle(playerid, 0);
            SetCameraBehindPlayer(playerid);
            SetPlayerInterior(playerid, 15);
		}
		
	}

	SetCameraBehindPlayer(playerid);
	PlayerInfo[playerid][pVW] = i;
	SetPlayerVirtualWorld(playerid, i);
	InsidePlane[playerid] = i;
	SetPVarInt(playerid, "InsideCar", 1);
	return 1;
}

stock Vehicle_Exit(playerid) {
 	
 	if(!IsAPlane(InsidePlane[playerid]) && !GetPVarType(playerid, "InsideCar")) {
	    PlayerInfo[playerid][pAGuns][GetLoadoutWeaponSlot(46)] = 46;
	    GivePlayerValidWeapon(playerid, 46);
	    SetPlayerPos(playerid, 0.000000, 0.000000, 420.000000); // lol nick
	}
	else {

	    new Float:X, Float:Y, Float:Z;
	    GetVehiclePos(InsidePlane[playerid], X, Y, Z);
	    
		if(!IsAPlane(PlayerInfo[playerid][pVW]) || !GetPVarInt(playerid, "air_Mode"))
		{
			SetPlayerPos(playerid, X-1.00, Y+3.00, Z);
			Player_StreamPrep(playerid, X-1.00, Y+3.00,Z, FREEZE_TIME);
		}
		else
		{
			SetPlayerPos(playerid, X-2.7912, Y+3.2304, Z);
			Player_StreamPrep(playerid, X-2.7912,Y+3.2304,Z, FREEZE_TIME);
			if(Z > 50.0) {
				PlayerInfo[playerid][pAGuns][GetLoadoutWeaponSlot(46)] = 46;
				GivePlayerValidWeapon(playerid, 46);
			}
		}
	}
	new iTemp = Streamer_GetIntData(STREAMER_TYPE_AREA, iVehEnterAreaID[PlayerInfo[playerid][pVW]], E_STREAMER_WORLD_ID);
	DeletePVar(playerid, "InsideCar");
	PlayerInfo[playerid][pVW] = iTemp;
	SetPlayerVirtualWorld(playerid, iTemp);
	PlayerInfo[playerid][pInt] = 0;
	SetPlayerInterior(playerid, 0);
	InsidePlane[playerid] = INVALID_VEHICLE_ID;
	return 1;
}

DDoor_Enter(playerid, i)
{
	if(!IsDynamicDoorActive(i)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "This door is no longer available.");
	
	if(DDoorsInfo[i][ddInteriorX] == 0.0 && DDoorsInfo[i][ddInteriorY] == 0.0 && DDoorsInfo[i][ddInteriorZ] == 0.0)
		return SendClientMessageEx(playerid, COLOR_GREY, "The interior of this door has not been configured.");
	
	if(GetPVarType(playerid, "StreamPrep")) 
		return SendClientMessageEx(playerid, COLOR_WHITE, "You can't do this right now. Wait for streaming to finish.");
	
	if(gettime() < DoorTimer[playerid]) 
		return SendClientMessageEx(playerid, COLOR_GREY, "You must wait %d seconds before being able to enter this door.", DoorTimer[playerid]-gettime());
	
	if(DDoorsInfo[i][ddVIP] > 0 && PlayerInfo[playerid][pDonateRank] < DDoorsInfo[i][ddVIP]) 
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "You can not enter, you are not a high enough VIP level.");
		return 1;
	}
	
	if(DDoorsInfo[i][ddFamed] > 0 && PlayerInfo[playerid][pFamed] < DDoorsInfo[i][ddFamed]) {
		SendClientMessageEx(playerid, COLOR_GRAD2, "You can not enter, you're not a high enough famed level.");
		return 1;
	}

	if(DDoorsInfo[i][ddDPC] > 0 && PlayerInfo[playerid][pDedicatedPlayer] < 2) {
		SendClientMessageEx(playerid, COLOR_GRAD2, "You can not enter, you are not a high enough Dedicated Player.");
		return 1;
	}

	if(DDoorsInfo[i][ddAllegiance] > 0) {
		if(!(0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) || arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance] != DDoorsInfo[i][ddAllegiance]) return SendClientMessageEx(playerid, COLOR_GRAD2, "You can not enter, this door is nation restricted.");
		else if(PlayerInfo[playerid][pRank] < DDoorsInfo[i][ddRank]) return SendClientMessageEx(playerid, COLOR_GRAD2, "You are not high enough rank to enter this door.");
	}

	if(DDoorsInfo[i][ddGroupType] > 0) {
		if(!(0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) || arrGroupData[PlayerInfo[playerid][pMember]][g_iGroupType] != DDoorsInfo[i][ddGroupType]) {
			return SendClientMessageEx(playerid, COLOR_GRAD2, "You can not enter, this door is faction restricted.");
		}
		else if(PlayerInfo[playerid][pRank] < DDoorsInfo[i][ddRank]) return SendClientMessageEx(playerid, COLOR_GRAD2, "You are not high enough rank to enter this door.");
	}

	if(DDoorsInfo[i][ddFaction] != INVALID_GROUP_ID) {
		if(PlayerInfo[playerid][pMember] != DDoorsInfo[i][ddFaction]) return SendClientMessageEx(playerid, COLOR_GRAD2, "You can not enter, this door is faction restricted.");
		else if(PlayerInfo[playerid][pRank] < DDoorsInfo[i][ddRank]) return SendClientMessageEx(playerid, COLOR_GRAD2, "You are not high enough rank to enter this door.");
	}

	if(DDoorsInfo[i][ddAdmin] > 0 && PlayerInfo[playerid][pAdmin] < DDoorsInfo[i][ddAdmin]) {
		SendClientMessageEx(playerid, COLOR_GRAD2, "You can not enter, you are not a high enough admin level.");
		return 1;
	}

	if(DDoorsInfo[i][ddWanted] > 0 && PlayerInfo[playerid][pWantedLevel] != 0) {
		SendClientMessageEx(playerid, COLOR_GRAD2, "You can not enter, this door restricts those with wanted levels.");
		return 1;
	}

	if(DDoorsInfo[i][ddLocked] == 1) {
		return SendClientMessageEx(playerid, COLOR_GRAD2, "This door is currently locked.");
	}

	PlayerInfo[playerid][pInt] = DDoorsInfo[i][ddInteriorInt];
	SetPlayerInterior(playerid,DDoorsInfo[i][ddInteriorInt]);
	PlayerInfo[playerid][pVW] = DDoorsInfo[i][ddInteriorVW];
	SetPlayerVirtualWorld(playerid, DDoorsInfo[i][ddInteriorVW]);
	
	if(DDoorsInfo[i][ddVehicleAble] > 0 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {

		new iVeh = GetPlayerVehicleID(playerid);
		SetVehiclePos(iVeh, DDoorsInfo[i][ddInteriorX],DDoorsInfo[i][ddInteriorY],DDoorsInfo[i][ddInteriorZ]);
		SetVehicleZAngle(iVeh, DDoorsInfo[i][ddInteriorA]);
		SetVehicleVirtualWorld(iVeh, DDoorsInfo[i][ddInteriorVW]);
		LinkVehicleToInterior(iVeh, DDoorsInfo[i][ddInteriorInt]);
		/*
		if(IsValidDynamicArea(iVehEnterAreaID[iVeh])) {
			Streamer_SetIntData(STREAMER_TYPE_AREA, iVehEnterAreaID[iVeh], E_STREAMER_WORLD_ID, iVeh);
		}
		*/
		if(GetPVarInt(playerid, "tpForkliftTimer") > 0)
		{
			SetPVarInt(playerid, "tpJustEntered", 1);
			new Float: pX, Float: pY, Float: pZ;
			GetPlayerPos(playerid, pX, pY, pZ);
			SetPVarFloat(playerid, "tpForkliftX", pX);
			SetPVarFloat(playerid, "tpForkliftY", pY);
			SetPVarFloat(playerid, "tpForkliftZ", pZ);
		}
		if(DynVeh[GetPlayerVehicleID(playerid)] != -1)
		{
			new vw[1];
			vw[0] = GetVehicleVirtualWorld(GetPlayerVehicleID(playerid));
			if(DynVehicleObjInfo[DynVeh[GetPlayerVehicleID(playerid)]][0][gv_iAttachedObjectModel] != INVALID_OBJECT_ID)
			{
				Streamer_SetArrayData(STREAMER_TYPE_OBJECT, DynVehicleObjInfo[DynVeh[GetPlayerVehicleID(playerid)]][0][gv_iAttachedObjectID], E_STREAMER_WORLD_ID, vw[0]);

			}
			if(DynVehicleObjInfo[DynVeh[GetPlayerVehicleID(playerid)]][1][gv_iAttachedObjectModel] != INVALID_OBJECT_ID)
			{
				Streamer_SetArrayData(STREAMER_TYPE_OBJECT, DynVehicleObjInfo[DynVeh[GetPlayerVehicleID(playerid)]][1][gv_iAttachedObjectID], E_STREAMER_WORLD_ID, vw[0]);

			}
		}
		foreach(new passenger : Player)
		{
			if(passenger != playerid)
			{
				if(IsPlayerInVehicle(passenger, GetPlayerVehicleID(playerid)))
				{
					SetPlayerInterior(passenger,DDoorsInfo[i][ddInteriorInt]);
					PlayerInfo[passenger][pInt] = DDoorsInfo[i][ddInteriorInt];
					PlayerInfo[passenger][pVW] = DDoorsInfo[i][ddInteriorVW];
					SetPlayerVirtualWorld(passenger, DDoorsInfo[i][ddInteriorVW]);
				}
			}
		}
	}
	else {
		SetPlayerPos(playerid,DDoorsInfo[i][ddInteriorX],DDoorsInfo[i][ddInteriorY],DDoorsInfo[i][ddInteriorZ]);
		SetPlayerFacingAngle(playerid,DDoorsInfo[i][ddInteriorA]);
		SetCameraBehindPlayer(playerid);
	}
	if(DDoorsInfo[i][ddCustomInterior]) Player_StreamPrep(playerid, DDoorsInfo[i][ddInteriorX],DDoorsInfo[i][ddInteriorY],DDoorsInfo[i][ddInteriorZ], FREEZE_TIME);
	DoorTimer[playerid] = gettime()+2;
	return 1;
}

DDoor_Exit(playerid, i)
{
	if(!IsDynamicDoorActive(i)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "This door is no longer available.");
	
	if(GetPVarType(playerid, "StreamPrep")) 
		return SendClientMessageEx(playerid, COLOR_WHITE, "You can't do this right now. Wait for streaming to finish.");
	
	if(gettime() < DoorTimer[playerid]) 
		return SendClientMessageEx(playerid, COLOR_GREY, "You must wait %d seconds before being able to exit this door.", DoorTimer[playerid]-gettime());
	
	if(DDoorsInfo[i][ddVIP] > 0 && PlayerInfo[playerid][pDonateRank] < DDoorsInfo[i][ddVIP]) 
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "You can not enter, you are not a high enough VIP level.");
		return 1;
	}
	
	if(DDoorsInfo[i][ddFamed] > 0 && PlayerInfo[playerid][pFamed] < DDoorsInfo[i][ddFamed]) {
		SendClientMessageEx(playerid, COLOR_GRAD2, "You can not enter, you're not a high enough famed level.");
		return 1;
	}

	if(DDoorsInfo[i][ddDPC] > 0 && PlayerInfo[playerid][pDedicatedPlayer] < 2) {
		SendClientMessageEx(playerid, COLOR_GRAD2, "You can not enter, you are not a Dedicated Player.");
		return 1;
	}

	if(DDoorsInfo[i][ddAllegiance] > 0) {
		if(!(0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) || arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance] != DDoorsInfo[i][ddAllegiance]) return SendClientMessageEx(playerid, COLOR_GRAD2, "You can not enter, this door is nation restricted.");
		else if(PlayerInfo[playerid][pRank] < DDoorsInfo[i][ddRank]) return SendClientMessageEx(playerid, COLOR_GRAD2, "You are not high enough rank to enter this door.");
	}

	if(DDoorsInfo[i][ddGroupType] > 0) {
		if(!(0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) || arrGroupData[PlayerInfo[playerid][pMember]][g_iGroupType] != DDoorsInfo[i][ddGroupType]) {
			return SendClientMessageEx(playerid, COLOR_GRAD2, "You can not enter, this door is faction restricted.");
		}
		else if(PlayerInfo[playerid][pRank] < DDoorsInfo[i][ddRank]) return SendClientMessageEx(playerid, COLOR_GRAD2, "You are not high enough rank to enter this door.");
	}

	if(DDoorsInfo[i][ddFaction] != INVALID_GROUP_ID) {
		if(PlayerInfo[playerid][pMember] != DDoorsInfo[i][ddFaction]) return SendClientMessageEx(playerid, COLOR_GRAD2, "You can not enter, this door is faction restricted.");
		else if(PlayerInfo[playerid][pRank] < DDoorsInfo[i][ddRank]) return SendClientMessageEx(playerid, COLOR_GRAD2, "You are not high enough rank to enter this door.");
	}

	if(DDoorsInfo[i][ddAdmin] > 0 && PlayerInfo[playerid][pAdmin] < DDoorsInfo[i][ddAdmin]) {
		SendClientMessageEx(playerid, COLOR_GRAD2, "You can not enter, you are not a high enough admin level.");
		return 1;
	}

	if(DDoorsInfo[i][ddWanted] > 0 && PlayerInfo[playerid][pWantedLevel] != 0) {
		SendClientMessageEx(playerid, COLOR_GRAD2, "You can not enter, this door restricts those with wanted levels.");
		return 1;
	}

	if(DDoorsInfo[i][ddLocked] == 1) {
		return SendClientMessageEx(playerid, COLOR_GRAD2, "This door is currently locked.");
	}


	SetPlayerInterior(playerid,DDoorsInfo[i][ddExteriorInt]);
	PlayerInfo[playerid][pInt] = DDoorsInfo[i][ddExteriorInt];
	SetPlayerVirtualWorld(playerid, DDoorsInfo[i][ddExteriorVW]);
	PlayerInfo[playerid][pVW] = DDoorsInfo[i][ddExteriorVW];
//	SetPlayerToTeamColor(playerid);
	if(DDoorsInfo[i][ddVehicleAble] > 0 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
		SetVehiclePos(GetPlayerVehicleID(playerid), DDoorsInfo[i][ddExteriorX],DDoorsInfo[i][ddExteriorY],DDoorsInfo[i][ddExteriorZ]);
		SetVehicleZAngle(GetPlayerVehicleID(playerid), DDoorsInfo[i][ddExteriorA]);
		SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), DDoorsInfo[i][ddExteriorVW]);
		LinkVehicleToInterior(GetPlayerVehicleID(playerid), DDoorsInfo[i][ddExteriorInt]);
		if(GetPVarInt(playerid, "tpForkliftTimer") > 0)
		{
			SetPVarInt(playerid, "tpJustEntered", 1);
			new Float: pX, Float: pY, Float: pZ;
			GetPlayerPos(playerid, pX, pY, pZ);
			SetPVarFloat(playerid, "tpForkliftX", pX);
			SetPVarFloat(playerid, "tpForkliftY", pY);
			SetPVarFloat(playerid, "tpForkliftZ", pZ);
		}
		if(DynVeh[GetPlayerVehicleID(playerid)] != -1)
		{
			new vw[1];
			vw[0] = GetVehicleVirtualWorld(GetPlayerVehicleID(playerid));
			if(DynVehicleObjInfo[DynVeh[GetPlayerVehicleID(playerid)]][0][gv_iAttachedObjectModel] != INVALID_OBJECT_ID)
			{
				Streamer_SetArrayData(STREAMER_TYPE_OBJECT, DynVehicleObjInfo[DynVeh[GetPlayerVehicleID(playerid)]][0][gv_iAttachedObjectID], E_STREAMER_WORLD_ID, vw[0]);

			}
			if(DynVehicleObjInfo[DynVeh[GetPlayerVehicleID(playerid)]][1][gv_iAttachedObjectModel] != INVALID_OBJECT_ID)
			{
				Streamer_SetArrayData(STREAMER_TYPE_OBJECT, DynVehicleObjInfo[DynVeh[GetPlayerVehicleID(playerid)]][1][gv_iAttachedObjectID], E_STREAMER_WORLD_ID, vw[0]);

			}
		}
		foreach(new passenger: Player)
		{
			if(passenger != playerid)
			{
				if(IsPlayerInVehicle(passenger, GetPlayerVehicleID(playerid)))
				{
					SetPlayerInterior(passenger,DDoorsInfo[i][ddExteriorInt]);
					PlayerInfo[passenger][pInt] = DDoorsInfo[i][ddExteriorInt];
					PlayerInfo[passenger][pVW] = DDoorsInfo[i][ddExteriorVW];
					SetPlayerVirtualWorld(passenger, DDoorsInfo[i][ddExteriorVW]);
				}
			}
		}
	}
	else {
		SetPlayerPos(playerid,DDoorsInfo[i][ddExteriorX],DDoorsInfo[i][ddExteriorY],DDoorsInfo[i][ddExteriorZ]);
		SetPlayerFacingAngle(playerid, DDoorsInfo[i][ddExteriorA]);
		SetCameraBehindPlayer(playerid);
	}
	if(DDoorsInfo[i][ddCustomExterior]) Player_StreamPrep(playerid, DDoorsInfo[i][ddExteriorX],DDoorsInfo[i][ddExteriorY],DDoorsInfo[i][ddExteriorZ], FREEZE_TIME);
	if(GetPVarType(playerid, "BusinessesID")) DeletePVar(playerid, "BusinessesID");
	DoorTimer[playerid] = gettime()+2;
	return 1;
}

House_Enter(playerid, i) {

	if(PlayerInfo[playerid][pPhousekey] == i || PlayerInfo[playerid][pPhousekey2] == i || HouseInfo[i][hLock] == 0 || PlayerInfo[playerid][pRenting] == i) {
		if(gettime() < DoorTimer[playerid]) return SendClientMessageEx(playerid, COLOR_GREY, "You must wait %d seconds before being able to enter this door.", DoorTimer[playerid]-gettime());
		if(GetPVarType(playerid, "StreamPrep")) return SendClientMessageEx(playerid, COLOR_WHITE, "You can't do this right now. Wait for streaming to finish.");
		House_VistorCheck(i);
		SetPlayerInterior(playerid,HouseInfo[i][hIntIW]);
		PlayerInfo[playerid][pInt] = HouseInfo[i][hIntIW];
		PlayerInfo[playerid][pVW] = HouseInfo[i][hIntVW];
		SetPlayerVirtualWorld(playerid,HouseInfo[i][hIntVW]);
		SetPlayerPos(playerid,HouseInfo[i][hInteriorX],HouseInfo[i][hInteriorY],HouseInfo[i][hInteriorZ]);
		SetPlayerFacingAngle(playerid,HouseInfo[i][hInteriorA]);
		SetCameraBehindPlayer(playerid);
		GameTextForPlayer(playerid, "~w~Welcome Home", 5000, 1);
		if(HouseInfo[i][h_iLights] == 1) TextDrawShowForPlayer(playerid, g_tHouseLights);
		if(HouseInfo[i][hCustomInterior] == 1) Player_StreamPrep(playerid, HouseInfo[i][hInteriorX],HouseInfo[i][hInteriorY],HouseInfo[i][hInteriorZ], FREEZE_TIME);
		DoorTimer[playerid] = gettime()+2;
	}
	else GameTextForPlayer(playerid, "~r~Locked", 5000, 1);
	return 1;
}

House_Exit(playerid, i) {

	if(GetPVarType(playerid, "StreamPrep")) return SendClientMessageEx(playerid, COLOR_WHITE, "You can't do this right now. Wait for streaming to finish.");
	if(gettime() < DoorTimer[playerid]) return SendClientMessageEx(playerid, COLOR_GREY, "You must wait %d seconds before being able to exit this door.", DoorTimer[playerid]-gettime());
	if(GetPVarType(playerid, PVAR_FURNITURE)) pc_cmd_furniture(playerid, "");
	House_VistorCheck(i);
	SetPlayerInterior(playerid,0);
	PlayerInfo[playerid][pInt] = 0;
	SetPlayerPos(playerid,HouseInfo[i][hExteriorX],HouseInfo[i][hExteriorY],HouseInfo[i][hExteriorZ]);
	SetPlayerFacingAngle(playerid, HouseInfo[i][hExteriorA]);
	SetCameraBehindPlayer(playerid);
	SetPlayerVirtualWorld(playerid, HouseInfo[i][hExtVW]);
	PlayerInfo[playerid][pVW] = HouseInfo[i][hExtVW];
	PlayerInfo[playerid][pInt] = HouseInfo[i][hExtIW];
	SetPlayerInterior(playerid, HouseInfo[i][hExtIW]);
	TextDrawHideForPlayer(playerid, g_tHouseLights);
	if(HouseInfo[i][hCustomExterior]) Player_StreamPrep(playerid, HouseInfo[i][hExteriorX],HouseInfo[i][hExteriorY],HouseInfo[i][hExteriorZ], FREEZE_TIME);
	DoorTimer[playerid] = gettime()+2;
	return 1;	
}

Business_Enter(playerid, i)
{
	if(PlayerInfo[playerid][pLevel] < 3 && Businesses[i][bType] == BUSINESS_TYPE_CASINO) return SendClientMessage(playerid, COLOR_LIGHTBLUE, "Sadly, you can't enter the Casino");
	if(Businesses[i][bExtPos][1] == 0.0) return SendClientMessageEx(playerid, COLOR_WHITE, "You cannot enter this business.");
	if(Businesses[i][bStatus]) {
		if(GetPVarType(playerid, "StreamPrep")) return SendClientMessageEx(playerid, COLOR_WHITE, "You can't do this right now. Wait for streaming to finish.");
		if(gettime() < DoorTimer[playerid]) return SendClientMessageEx(playerid, COLOR_GREY, "You must wait %d seconds before being able to exit this door.", DoorTimer[playerid]-gettime());
		if (Businesses[i][bType] == BUSINESS_TYPE_GYM)
		{
			if (Businesses[i][bGymEntryFee] > 0 && PlayerInfo[playerid][pCash] < Businesses[i][bGymEntryFee])
			{
				GameTextForPlayer(playerid, "~r~You need more money to enter this gym", 5000, 1);
				return 1;
			}
		}
		SetPVarInt(playerid, "BusinessesID", i);

		if(Businesses[i][bVW] == 0) SetPlayerVirtualWorld(playerid, BUSINESS_BASE_VW + i), PlayerInfo[playerid][pVW] = BUSINESS_BASE_VW + i;
		else SetPlayerVirtualWorld(playerid, Businesses[i][bVW]), PlayerInfo[playerid][pVW] = Businesses[i][bVW];


		SetPlayerInterior(playerid,Businesses[i][bInt]);
		SetPlayerPos(playerid,Businesses[i][bIntPos][0],Businesses[i][bIntPos][1],Businesses[i][bIntPos][2]);
		SetPlayerFacingAngle(playerid, Businesses[i][bIntPos][3]);
		SetCameraBehindPlayer(playerid);
		PlayerInfo[playerid][pInt] = Businesses[i][bInt];
		if(Businesses[i][bCustomInterior]) Player_StreamPrep(playerid, Businesses[i][bIntPos][0], Businesses[i][bIntPos][1], Businesses[i][bIntPos][2], FREEZE_TIME);

		if (Businesses[i][bType] == BUSINESS_TYPE_GYM)
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "You entered a gym and were charged $%i.", Businesses[i][bGymEntryFee]);
			GivePlayerCash(playerid, -Businesses[i][bGymEntryFee]);
			Businesses[i][bSafeBalance] += Businesses[i][bGymEntryFee];

			if (Businesses[i][bGymType] == 1)
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "Type /beginswimming to start using the swimming pool.");
				SendClientMessageEx(playerid, COLOR_WHITE, "Type /joinboxing to join the boxing queue.");
			}
			else if (Businesses[i][bGymType] == 2)
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "Type /beginparkour to begin the bike parkour track.");
			}
		}
		DoorTimer[playerid] = gettime()+2;
	}
	else GameTextForPlayer(playerid, "~r~Closed", 5000, 1);
	return 1;
}

Business_Exit(playerid, i)
{
	if(GetPVarType(playerid, "StreamPrep")) return SendClientMessageEx(playerid, COLOR_WHITE, "You can't do this right now. Wait for streaming to finish.");
	if(gettime() < DoorTimer[playerid]) return SendClientMessageEx(playerid, COLOR_GREY, "You must wait %d seconds before being able to exit this door.", DoorTimer[playerid]-gettime());
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerPos(playerid,Businesses[i][bExtPos][0],Businesses[i][bExtPos][1],Businesses[i][bExtPos][2]);
	SetPlayerFacingAngle(playerid, Businesses[i][bExtPos][3]);
	SetCameraBehindPlayer(playerid);
	PlayerInfo[playerid][pInt] = 0;
	PlayerInfo[playerid][pVW] = 0;
	DeletePVar(playerid, "BusinessesID");
	if(Businesses[i][bCustomExterior]) Player_StreamPrep(playerid, Businesses[i][bExtPos][0], Businesses[i][bExtPos][1], Businesses[i][bExtPos][2], FREEZE_TIME);
	DoorTimer[playerid] = gettime()+2;
	return 1;
}

Garage_Enter(playerid, i) {

	if(GarageInfo[i][gar_Locked] == 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "This garage is currently locked.");
	if(GetPVarType(playerid, "StreamPrep")) return SendClientMessageEx(playerid, COLOR_WHITE, "You can't do this right now. Wait for streaming to finish.");
	if(gettime() < DoorTimer[playerid]) return SendClientMessageEx(playerid, COLOR_GREY, "You must wait %d seconds before being able to enter this door.", DoorTimer[playerid]-gettime());
	PlayerInfo[playerid][pVW] = GarageInfo[i][gar_InteriorVW];
	SetPlayerVirtualWorld(playerid, GarageInfo[i][gar_InteriorVW]);
	SetPlayerInterior(playerid, 1);
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		SetVehiclePos(GetPlayerVehicleID(playerid), GarageInfo[i][gar_InteriorX], GarageInfo[i][gar_InteriorY], GarageInfo[i][gar_InteriorZ]);
		SetVehicleZAngle(GetPlayerVehicleID(playerid), GarageInfo[i][gar_InteriorA]);
		SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), GarageInfo[i][gar_InteriorVW]);
		LinkVehicleToInterior(GetPlayerVehicleID(playerid), 1);
		if(GetPVarInt(playerid, "tpForkliftTimer") > 0)
		{
			SetPVarInt(playerid, "tpJustEntered", 1);
			new Float: pX, Float: pY, Float: pZ;
			GetPlayerPos(playerid, pX, pY, pZ);
			SetPVarFloat(playerid, "tpForkliftX", pX);
			SetPVarFloat(playerid, "tpForkliftY", pY);
			SetPVarFloat(playerid, "tpForkliftZ", pZ);
		}
		if(GetPVarInt(playerid, "tpDeliverVehTimer") > 0) SetPVarInt(playerid, "tpJustEntered", 1);
		if(DynVeh[GetPlayerVehicleID(playerid)] != -1)
		{
			new vw[1];
			vw[0] = GetVehicleVirtualWorld(GetPlayerVehicleID(playerid));
			if(DynVehicleObjInfo[DynVeh[GetPlayerVehicleID(playerid)]][0][gv_iAttachedObjectModel] != INVALID_OBJECT_ID)
			{
				Streamer_SetArrayData(STREAMER_TYPE_OBJECT, DynVehicleObjInfo[DynVeh[GetPlayerVehicleID(playerid)]][0][gv_iAttachedObjectID], E_STREAMER_WORLD_ID, vw[0]);
			}
			if(DynVehicleObjInfo[DynVeh[GetPlayerVehicleID(playerid)]][1][gv_iAttachedObjectModel] != INVALID_OBJECT_ID)
			{
				Streamer_SetArrayData(STREAMER_TYPE_OBJECT, DynVehicleObjInfo[DynVeh[GetPlayerVehicleID(playerid)]][1][gv_iAttachedObjectID], E_STREAMER_WORLD_ID, vw[0]);
			}
		}
		foreach(new passenger : Player)
		{
			if(passenger != playerid)
			{
				if(IsPlayerInVehicle(passenger, GetPlayerVehicleID(playerid)))
				{
					SetPlayerInterior(passenger, 1);
					PlayerInfo[passenger][pInt] = 1;
					PlayerInfo[passenger][pVW] = GarageInfo[i][gar_InteriorVW];
					SetPlayerVirtualWorld(passenger, GarageInfo[i][gar_InteriorVW]);
				}
			}
		}
	}
	else
	{
		SetPlayerPos(playerid, GarageInfo[i][gar_InteriorX], GarageInfo[i][gar_InteriorY], GarageInfo[i][gar_InteriorZ]);
		SetPlayerFacingAngle(playerid, GarageInfo[i][gar_InteriorA]);
		SetCameraBehindPlayer(playerid);
	}
	Player_StreamPrep(playerid, GarageInfo[i][gar_InteriorX], GarageInfo[i][gar_InteriorY], GarageInfo[i][gar_InteriorZ], FREEZE_TIME);
	DoorTimer[playerid] = gettime()+2;
	return 1;
}

Garage_Exit(playerid, i) {
	if(GetPVarType(playerid, "StreamPrep")) return SendClientMessageEx(playerid, COLOR_WHITE, "You can't do this right now. Wait for streaming to finish.");
	if(gettime() < DoorTimer[playerid]) return SendClientMessageEx(playerid, COLOR_GREY, "You must wait %d seconds before being able to exit this door.", DoorTimer[playerid]-gettime());
	SetPlayerInterior(playerid, GarageInfo[i][gar_ExteriorInt]);
	PlayerInfo[playerid][pInt] = GarageInfo[i][gar_ExteriorInt];
	SetPlayerVirtualWorld(playerid, GarageInfo[i][gar_ExteriorVW]);
	PlayerInfo[playerid][pVW] = GarageInfo[i][gar_ExteriorVW];
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		SetVehiclePos(GetPlayerVehicleID(playerid), GarageInfo[i][gar_ExteriorX], GarageInfo[i][gar_ExteriorY], GarageInfo[i][gar_ExteriorZ]);
		SetVehicleZAngle(GetPlayerVehicleID(playerid), GarageInfo[i][gar_ExteriorA]);
		SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), GarageInfo[i][gar_ExteriorVW]);
		LinkVehicleToInterior(GetPlayerVehicleID(playerid), GarageInfo[i][gar_ExteriorInt]);
		if(GetPVarInt(playerid, "tpForkliftTimer") > 0)
		{
			SetPVarInt(playerid, "tpJustEntered", 1);
			new Float: pX, Float: pY, Float: pZ;
			GetPlayerPos(playerid, pX, pY, pZ);
			SetPVarFloat(playerid, "tpForkliftX", pX);
			SetPVarFloat(playerid, "tpForkliftY", pY);
			SetPVarFloat(playerid, "tpForkliftZ", pZ);
		}
		if(DynVeh[GetPlayerVehicleID(playerid)] != -1)
		{
			new vw[1];
			vw[0] = GetVehicleVirtualWorld(GetPlayerVehicleID(playerid));
			if(DynVehicleObjInfo[DynVeh[GetPlayerVehicleID(playerid)]][0][gv_iAttachedObjectModel] != INVALID_OBJECT_ID)
			{
				Streamer_SetArrayData(STREAMER_TYPE_OBJECT, DynVehicleObjInfo[DynVeh[GetPlayerVehicleID(playerid)]][0][gv_iAttachedObjectID], E_STREAMER_WORLD_ID, vw[0]);
			}
			if(DynVehicleObjInfo[DynVeh[GetPlayerVehicleID(playerid)]][1][gv_iAttachedObjectModel] != INVALID_OBJECT_ID)
			{
				Streamer_SetArrayData(STREAMER_TYPE_OBJECT, DynVehicleObjInfo[DynVeh[GetPlayerVehicleID(playerid)]][1][gv_iAttachedObjectID], E_STREAMER_WORLD_ID, vw[0]);
			}
		}
		foreach(new passenger : Player)
		{
			if(passenger != playerid)
			{
				if(IsPlayerInVehicle(passenger, GetPlayerVehicleID(playerid)))
				{
					SetPlayerInterior(passenger,GarageInfo[i][gar_ExteriorInt]);
					PlayerInfo[passenger][pInt] = GarageInfo[i][gar_ExteriorInt];
					PlayerInfo[passenger][pVW] = GarageInfo[i][gar_ExteriorVW];
					SetPlayerVirtualWorld(passenger, GarageInfo[i][gar_ExteriorVW]);
				}
			}
		}
	}
	else 
	{
		SetPlayerPos(playerid, GarageInfo[i][gar_ExteriorX], GarageInfo[i][gar_ExteriorY], GarageInfo[i][gar_ExteriorZ]);
		SetPlayerFacingAngle(playerid, GarageInfo[i][gar_ExteriorA]);
		SetCameraBehindPlayer(playerid);
	}
	if(GarageInfo[i][gar_CustomExterior]) Player_StreamPrep(playerid, GarageInfo[i][gar_ExteriorX], GarageInfo[i][gar_ExteriorY], GarageInfo[i][gar_ExteriorZ], FREEZE_TIME);
	DoorTimer[playerid] = gettime()+2;
	return 1;
}