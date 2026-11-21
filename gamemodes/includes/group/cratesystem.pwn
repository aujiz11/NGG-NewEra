/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

    	    		  Crate System (Re-done)
    			        by Shane Roberts

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

new 
	CrateBeingProcessed[MAX_CRATE_FACILITY],
	CrateBeingDelivered[MAX_GROUPS],
	CrateFacilityRaid[MAX_CRATE_FACILITY];

enum E_CRATE_ACTION {
	caTimer,
	caToken,
	caFacility,
	caBox,
	caVehicle,
	caPoint
};

new CrateAction[MAX_PLAYERS][E_CRATE_ACTION], CrateGeneration[MAX_CRATES];

stock CancelCrateAction(playerid) {
	if(CrateAction[playerid][caTimer]) KillTimer(CrateAction[playerid][caTimer]);
	CrateAction[playerid][caTimer] = 0;
	++CrateAction[playerid][caToken];
	new facility = CrateAction[playerid][caFacility], box = CrateAction[playerid][caBox];
	new point = CrateAction[playerid][caPoint], vehicle = CrateAction[playerid][caVehicle];
	if(0 <= facility < MAX_CRATE_FACILITY && CrateBeingProcessed[facility] == playerid + 1) {
		CrateBeingProcessed[facility] = 0;
		if(IsValidCrate(box) && !CrateBox[box][cbActive] && CrateBox[box][cbFacility] == facility) 
		{
			CrateBox[box][cbFacility] = -1;
		}
	}
	if(ValidGroup(point) && CrateBeingDelivered[point] == playerid + 1) {
		CrateBeingDelivered[point] = 0;
		if(0 <= vehicle < MAX_CRATE_VEHCILES) VehDelivering[vehicle] = 0;
	}
	if(GetPVarType(playerid, "LoadForkliftTime") || GetPVarType(playerid, "DeliverCrateTime")) {
		DeletePVar(playerid, "LoadForkliftTime");
		DeletePVar(playerid, "DeliverCrateTime");
		if(IsPlayerConnected(playerid)) TogglePlayerControllable(playerid, true);
	}
	CrateAction[playerid][caFacility] = -1;
	CrateAction[playerid][caBox] = -1;
	CrateAction[playerid][caVehicle] = -1;
	CrateAction[playerid][caPoint] = -1;
	return 1;
}

stock CancelCrateVehicleActions(vehicle) {
	foreach(new playerid : Player) {
		if(CrateAction[playerid][caTimer] && CrateAction[playerid][caVehicle] == vehicle) {
			CancelCrateAction(playerid);
		}
	}
	return 1;
}

stock QueueCrateMove(playerid, box, vehicle, action, delay) {
	if(CrateAction[playerid][caTimer]) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Hay xong thao tac thung hang hien tai truoc.");
	
	CancelCrateAction(playerid);
	CrateAction[playerid][caBox] = box;
	CrateAction[playerid][caVehicle] = vehicle;
	CrateAction[playerid][caTimer] = SetTimerEx("FinishCrateMove", delay, false, "iiii", playerid, g_arrQueryHandle[playerid], CrateAction[playerid][caToken], action);
	return 1;
}

forward FinishCrateMove(playerid, session, token, action);
public FinishCrateMove(playerid, session, token, action) {
	if(!IsPlayerConnected(playerid) || g_arrQueryHandle[playerid] != session || CrateAction[playerid][caToken] != token) return 1;
	new box = CrateAction[playerid][caBox], vehicle = CrateAction[playerid][caVehicle];
	CancelCrateAction(playerid);
	if(!IsValidCrate(box) || !CrateBox[box][cbActive] || PlayerBusy(playerid) || IsPlayerInAnyVehicle(playerid)) return 1;
	if(action == 0) {
		if(CarryCrate[playerid] != -1 || BeingMoved[box] != INVALID_PLAYER_ID || CrateBox[box][cbInVeh] != -1 || CrateBox[box][cbOnVeh] != -1) 
			return 1;
		
		if(GetPlayerVirtualWorld(playerid) != CrateBox[box][cbVw] || GetPlayerInterior(playerid) != CrateBox[box][cbInt]) 
			return 1;
		
		if(!IsPlayerInRangeOfPoint(playerid, 2.0, CrateBox[box][cbPos][0], CrateBox[box][cbPos][1], CrateBox[box][cbPos][2])) 
			return 1;
	}
	else if(action == 1 || action == 3) {
		if(CarryCrate[playerid] != box || BeingMoved[box] != playerid) return 1;
	}
	if(action == 2 || action == 3) {
		if(!(0 <= vehicle < MAX_CRATE_VEHCILES) || !IsValidVehicle(CrateVehicle[vehicle][cvSpawnID]) || VehDelivering[vehicle]) 
			return 1;
		
		if(GetPlayerVirtualWorld(playerid) != GetVehicleVirtualWorld(CrateVehicle[vehicle][cvSpawnID]) || GetPlayerInterior(playerid) != CrateVehicle[vehicle][cvInt]) 
			return 1;
		
		new Float:pos[3], engine, lights, alarm, doors, bonnet, boot, objective;
		GetPosBehindVehicle(CrateVehicle[vehicle][cvSpawnID], pos[0], pos[1], pos[2], 0.0);
		if(!IsPlayerInRangeOfPoint(playerid, 2.0, pos[0], pos[1], pos[2]) || IsAPlane(CrateVehicle[vehicle][cvSpawnID])) return 1;
		GetVehicleParamsEx(CrateVehicle[vehicle][cvSpawnID], engine, lights, alarm, doors, bonnet, boot, objective);
		if(boot != VEHICLE_PARAMS_ON) return 1;
		if(action == 2 && (CarryCrate[playerid] != -1 || BeingMoved[box] != INVALID_PLAYER_ID || CrateBox[box][cbInVeh] != vehicle)) return 1;
		if(action == 3 && (CrateVehicle[vehicle][cvCrateMax] < 1 || CreateCount(vehicle) >= CrateVehicle[vehicle][cvCrateMax])) return 1;
	}
	return PlayerCarryCrate(playerid, box, vehicle, action);
}

hook OnGameModeInit() {
	for(new i = 0; i < MAX_CRATE_FACILITY; i++) {
		AdminOpened[i] = 0; // Disable by default.
		CrateBeingProcessed[i] = 0;
		CrateFacility[i][cfTextID] = Text3D: -1;
		CrateFacility[i][cfPickupID] = -1;
		CrateFacility[i][cfMapIcon] = -1;
		CrateFacilityRaid[i] = 0;
	}
	for(new g = 0; g < MAX_GROUPS; g++) CrateOrder[g][coFacility] = -1;
	for(new f = 0; f < MAX_CRATE_FACILITY; f++) CrateFacility[f][cfGroup] = -1;
	for(new c = 0; c < MAX_CRATES; c++) {
		CrateBox[c][cbFacility] = -1;
		CrateBox[c][cbGroup] = -1;
		CrateBox[c][cbInVeh] = -1;
		CrateBox[c][cbOnVeh] = -1;
		BeingMoved[c] = INVALID_PLAYER_ID;
		CrateBox[c][cbObject] = -1;
		CrateBox[c][cbTextID] = Text3D: -1;
	}
	return 1;
}

hook OnPlayerConnect(playerid) {
	CarryCrate[playerid] = -1;
	CrateAction[playerid][caFacility] = -1;
	CrateAction[playerid][caBox] = -1;
	CrateAction[playerid][caVehicle] = -1;
	CrateAction[playerid][caPoint] = -1;
	return 1;
}

hook OnPlayerDisconnect(playerid, reason) {
	CancelCrateAction(playerid);
	if(CarryCrate[playerid] != -1) {
		PlayerCarryCrate(playerid, CarryCrate[playerid], -1, 1);
	}
	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(IsKeyJustDown(KEY_FIRE, newkeys, oldkeys)) {
		if(CarryCrate[playerid] >= 0 && !CrateAction[playerid][caTimer]) {
			ApplyAnimation(playerid, "CARRY", "putdwn", 4.1, false, false, false, false, 0, 1);
			QueueCrateMove(playerid, CarryCrate[playerid], -1, 1, 1000);
		}
	}
	return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate) 
{
	if(CrateAction[playerid][caTimer] && CrateAction[playerid][caVehicle] != -1 && oldstate == PLAYER_STATE_DRIVER && newstate != PLAYER_STATE_DRIVER) 
	{
		CancelCrateAction(playerid);
	}

	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER) 
	{
		if(CarryCrate[playerid] >= 0) 
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Khong the ngoi trong xe khi mang thung hang!");
			return RemovePlayerFromVehicle(playerid);
		}
	}
	return 1;
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) {
	if(CarryCrate[playerid] >= 0) {
		new Float:pos[3];
		GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		SetPlayerPos(playerid, pos[0], pos[1], pos[2]+1.3);
		PlayerPlaySound(playerid, 1130, pos[0], pos[1], pos[2]+1.3);
		SendClientMessageEx(playerid, COLOR_GREY, "Khong the len xe khi mang thung hang!");
		return 1;
	}
	return 1;
}

stock LoadCrateOrders() {
	mysql_tquery(MainPipeline, "SELECT * FROM `crate_orders`", "OnLoadCrateOrders", "");
}

forward OnLoadCrateOrders();
public OnLoadCrateOrders()
{
	new i, rows;
	cache_get_row_count(rows);

	for(new row = 0; row < rows; row++)
	{
		cache_get_value_name_int(row, "id", i);
		if(!(1 <= i <= MAX_GROUPS)) continue;
		--i;
		cache_get_value_name_int(row, "id", CrateOrder[i][coGroup]);
		cache_get_value_name_int(row, "Facility", CrateOrder[i][coFacility]);
		cache_get_value_name_int(row, "Crates", CrateOrder[i][coCrates]);
		cache_get_value_name_int(row, "PerCrate", CrateOrder[i][coPerCrate]);
		cache_get_value_name(row,  "OrderBy", CrateOrder[i][coOrderBy], MAX_PLAYER_NAME);
		cache_get_value_name_int(row, "Delivered", CrateOrder[i][coDelivered]);
		cache_get_value_name_int(row, "Status", CrateOrder[i][coStatus]);
		cache_get_value_name_int(row, "Time", CrateOrder[i][coTime]);
	}
	return 1;
}

stock SaveOrder(i) {
	if(!ValidGroup(i)) return 0;
	new query[2048];

	format(query, 2048, "UPDATE `crate_orders` SET ");
	SaveInteger(query, "crate_orders", i+1, "Facility", CrateOrder[i][coFacility]);
	SaveInteger(query, "crate_orders", i+1, "Crates", CrateOrder[i][coCrates]);
	SaveInteger(query, "crate_orders", i+1, "PerCrate", CrateOrder[i][coPerCrate]);
	SaveString(query, "crate_orders", i+1, "OrderBy", CrateOrder[i][coOrderBy]);
	SaveInteger(query, "crate_orders", i+1, "Delivered", CrateOrder[i][coDelivered]);
	SaveInteger(query, "crate_orders", i+1, "Status", CrateOrder[i][coStatus]);
	SaveInteger(query, "crate_orders", i+1, "Time", CrateOrder[i][coTime]);
	SQLUpdateFinish(query, "crate_orders", i+1);
	return 1;
}

stock LoadCrateBoxes()
{
	printf("[Dynamic Crate Boxes] Loading Dynamic Crate Boxes from the database, please wait...");
	mysql_tquery(MainPipeline, "SELECT * FROM `crates`", "OnLoadCrateBoxes", "");
}

forward OnLoadCrateBoxes();
public OnLoadCrateBoxes()
{
	new i, rows, loaded, number[16];
	cache_get_row_count(rows);

	for(new row = 0; row < rows; row++)
	{
		cache_get_value_name_int(row, "id", i);
		if(!(1 <= i <= MAX_CRATES)) continue;
		--i;
		cache_get_value_name_int(row, "Facility", CrateBox[i][cbFacility]);
		cache_get_value_name_int(row, "Group", CrateBox[i][cbGroup]);
		cache_get_value_name_float(row, "CrateX", CrateBox[i][cbPos][0]);
		cache_get_value_name_float(row, "CrateY", CrateBox[i][cbPos][1]);
		cache_get_value_name_float(row, "CrateZ", CrateBox[i][cbPos][2]);
		cache_get_value_name_int(row, "Int", CrateBox[i][cbInt]);
		cache_get_value_name_int(row, "InVehicle", CrateBox[i][cbInVeh]);
		cache_get_value_name_int(row, "OnVehicle", CrateBox[i][cbOnVeh]);
		cache_get_value_name_int(row, "VW", CrateBox[i][cbVw]);
		cache_get_value_name_int(row, "Materials", CrateBox[i][cbMats]);
		for(new w = 0; w < 16; w++) {
			format(number, sizeof(number), "Gun%d", w+1);
			cache_get_value_name_int(row, number, CrateBox[i][cbWep][w]);
			format(number, sizeof(number), "GunAmount%d", w+1);
			cache_get_value_name_int(row, number, CrateBox[i][cbWepAmount][w]);
		}
		cache_get_value_name(row,  "PlacedBy", CrateBox[i][cbPlacedBy], MAX_PLAYER_NAME);
		cache_get_value_name_int(row, "Lifespan", CrateBox[i][cbLifespan]);
		cache_get_value_name_int(row, "Transfer", CrateBox[i][cbTransfer]);
		cache_get_value_name_int(row, "DoorID", CrateBox[i][cbDoor]);
		cache_get_value_name_int(row, "DoorType", CrateBox[i][cbDoorType]);
		cache_get_value_name_int(row, "Price", CrateBox[i][cbPrice]);
		cache_get_value_name_int(row, "Paid", CrateBox[i][cbPaid]);
		cache_get_value_name_int(row, "Active", CrateBox[i][cbActive]);
		UpdateCrateBox(i);
		++loaded;
	}
	if(loaded > 0) printf("[Dynamic Crate Boxes] %d dynamic Crate Boxes have been loaded.", loaded);
	else printf("[Dynamic Crate Boxes] There are no dynamic crate boxes to load.");
	return 1;
}

stock UpdateCrateBox(id)
{
	if(!IsValidCrate(id)) return 0;
	new string[256];
	if(IsValidDynamicObject(CrateBox[id][cbObject])) DestroyDynamicObject(CrateBox[id][cbObject]), CrateBox[id][cbObject] = -1;
	if(IsValidDynamic3DTextLabel(CrateBox[id][cbTextID])) DestroyDynamic3DTextLabel(CrateBox[id][cbTextID]), CrateBox[id][cbTextID] = Text3D: -1;

	if(!CrateBox[id][cbActive] || CrateBox[id][cbInVeh] != -1) return 1;

	if(BeingMoved[id] != INVALID_PLAYER_ID || CrateBox[id][cbOnVeh] != -1) return 1;

	if(CrateBox[id][cbGroup] != -1 && !ValidGroup(CrateBox[id][cbGroup])) return DestroyCrate(id);

	if(CrateBox[id][cbGroup] == -1) {
		format(string, sizeof(string), "{FFFF00}---- ID: {FF8000}%d\n{FFFF00}Con lai: {FF8000}00:00:00\n{FFFF00}Nguoi dat: {FF8000}%s", id, CrateBox[id][cbPlacedBy]);
	} else {
		format(string, sizeof(string), "{FFFF00}ID: {FF8000}%d\n{FFFF00}Chu thung: {FF8000}%s\n{FFFF00}Nguoi dat: {FF8000}%s", id, arrGroupData[CrateBox[id][cbGroup]][g_szGroupName], CrateBox[id][cbPlacedBy]);
	}
	CrateBox[id][cbTextID] = CreateDynamic3DTextLabel(string, COLOR_YELLOW, CrateBox[id][cbPos][0], CrateBox[id][cbPos][1], CrateBox[id][cbPos][2]+1.5, 20.0, .testlos = 1, .worldid = CrateBox[id][cbVw], .interiorid = CrateBox[id][cbInt], .streamdistance = 20.0);
	CrateBox[id][cbObject] = CreateDynamicObject(964, CrateBox[id][cbPos][0], CrateBox[id][cbPos][1], CrateBox[id][cbPos][2], 0.00000000, 0.00000000, 0.00000000, CrateBox[id][cbVw], CrateBox[id][cbInt]);
	
	return 1;
}

stock SaveCrate(i) {
	if(!IsValidCrate(i)) return 0;
	new query[2048], wep[16];

	format(query, 2048, "UPDATE `crates` SET ");
	SaveInteger(query, "crates", i+1, "Facility", CrateBox[i][cbFacility]);
	SaveInteger(query, "crates", i+1, "Group", CrateBox[i][cbGroup]);
	SaveFloat(query, "crates", i+1, "CrateX", CrateBox[i][cbPos][0]);
	SaveFloat(query, "crates", i+1, "CrateY", CrateBox[i][cbPos][1]);
	SaveFloat(query, "crates", i+1, "CrateZ", CrateBox[i][cbPos][2]);
	SaveInteger(query, "crates", i+1, "Int", CrateBox[i][cbInt]);
	SaveInteger(query, "crates", i+1, "InVehicle", CrateBox[i][cbInVeh]);
	SaveInteger(query, "crates", i+1, "OnVehicle", CrateBox[i][cbOnVeh]);
	SaveInteger(query, "crates", i+1, "VW", CrateBox[i][cbVw]);
	SaveInteger(query, "crates", i+1, "Materials", CrateBox[i][cbMats]);
	for(new w = 0; w < 16; w++) {
		format(wep, sizeof(wep), "Gun%d", w+1);
		SaveInteger(query, "crates", i+1, wep, CrateBox[i][cbWep][w]);
		format(wep, sizeof(wep), "GunAmount%d", w+1);
		SaveInteger(query, "crates", i+1, wep, CrateBox[i][cbWepAmount][w]);
	}
	SaveString(query, "crates", i+1, "PlacedBy", CrateBox[i][cbPlacedBy]);
	SaveInteger(query, "crates", i+1, "Lifespan", CrateBox[i][cbLifespan]);
	SaveInteger(query, "crates", i+1, "Transfer", CrateBox[i][cbTransfer]);
	SaveInteger(query, "crates", i+1, "DoorID", CrateBox[i][cbDoor]);
	SaveInteger(query, "crates", i+1, "DoorType", CrateBox[i][cbDoorType]);
	SaveInteger(query, "crates", i+1, "Price", CrateBox[i][cbPrice]);
	SaveInteger(query, "crates", i+1, "Paid", CrateBox[i][cbPaid]);
	SaveInteger(query, "crates", i+1, "Active", CrateBox[i][cbActive]);
	SQLUpdateFinish(query, "crates", i+1);
	return 1;
}

stock LoadCrateFacilities()
{
	printf("[Dynamic Crate Facility] Loading Dynamic Crate Facilities from the database, please wait...");
	mysql_tquery(MainPipeline, "SELECT * FROM `crate_facility`", "OnLoadCrateFacilities", "");
}

forward OnLoadCrateFacilities();
public OnLoadCrateFacilities()
{
	new i, rows, loaded;
	cache_get_row_count(rows);

	for(new row = 0; row < rows; row++)
	{
		cache_get_value_name_int(row, "id", i);
		if(!(1 <= i <= MAX_CRATE_FACILITY)) continue;
		--i;
		cache_get_value_name_int(row, "id", CrateFacility[i][cfId]);
		cache_get_value_name(row, "Name", CrateFacility[i][cfName], 32);
		cache_get_value_name_int(row, "Group", CrateFacility[i][cfGroup]);
		cache_get_value_name_float(row, "Posx", CrateFacility[i][cfPos][0]);
		cache_get_value_name_float(row, "Posy", CrateFacility[i][cfPos][1]);
		cache_get_value_name_float(row, "Posz", CrateFacility[i][cfPos][2]);
		cache_get_value_name_float(row, "Posr", CrateFacility[i][cfPos][3]);
		cache_get_value_name_int(row, "Int", CrateFacility[i][cfInt]);
		cache_get_value_name_int(row, "Vw", CrateFacility[i][cfVw]);
		cache_get_value_name_int(row, "Prodmax", CrateFacility[i][cfProdMax]);
		cache_get_value_name_int(row, "ProdPrep", CrateFacility[i][cfProdPrep]);
		cache_get_value_name_int(row, "ProdReady", CrateFacility[i][cfProdReady]);
		cache_get_value_name_int(row, "ProdTimer", CrateFacility[i][cfProdTimer]);
		cache_get_value_name_int(row, "ProdStatus", CrateFacility[i][cfProdStatus]);
		cache_get_value_name_int(row, "ProdCost", CrateFacility[i][cfProdCost]);
		cache_get_value_name_int(row, "ProdMulti", CrateFacility[i][cfProdMulti]);
		cache_get_value_name_int(row, "RaidTimer", CrateFacility[i][cfRaidTimer]);
		cache_get_value_name_int(row, "Cooldown", CrateFacility[i][cfCooldown]);
		cache_get_value_name_int(row, "Raidable", CrateFacility[i][cfRaidable]);
		cache_get_value_name_int(row, "Active", CrateFacility[i][cfActive]);
		cache_get_value_name_int(row, "Timer", CrateFacility[i][cfTimer]);
		UpdateFacility(i);
		if(CrateFacility[i][cfRaidTimer] > 0) TriggerGates(i);
		++loaded;
	}
	if(loaded > 0) printf("[Dynamic Crate Facility] %d dynamic Crate Facilities have been loaded.", loaded);
	else printf("[Dynamic Crate Facility] No dynamic Crate Facilities have been loaded.");
	return 1;
}

stock UpdateFacility(id)
{
	if(!(0 <= id < MAX_CRATE_FACILITY)) return 0;
	new string[256];
	//964 box | 11 - Map Icon
	if(IsValidDynamicObject(CrateFacility[id][cfPickupID])) DestroyDynamicObject(CrateFacility[id][cfPickupID]), CrateFacility[id][cfPickupID] = -1;
	if(IsValidDynamic3DTextLabel(CrateFacility[id][cfTextID])) DestroyDynamic3DTextLabel(CrateFacility[id][cfTextID]), CrateFacility[id][cfTextID] = Text3D: -1;
	if(IsValidDynamicMapIcon(CrateFacility[id][cfMapIcon])) DestroyDynamicMapIcon(CrateFacility[id][cfMapIcon]), CrateFacility[id][cfMapIcon] = -1;

	if(CrateFacility[id][cfPos][0] == 0.0) return 1;

	CrateFacility[id][cfMapIcon] = CreateDynamicMapIcon(CrateFacility[id][cfPos][0], CrateFacility[id][cfPos][1], CrateFacility[id][cfPos][2], 11, 0, CrateFacility[id][cfVw], CrateFacility[id][cfInt], .streamdistance = 1000.0, .style = MAPICON_GLOBAL);
	// Box Object.
	CrateFacility[id][cfPickupID] = CreateDynamicObject(964, CrateFacility[id][cfPos][0], CrateFacility[id][cfPos][1], CrateFacility[id][cfPos][2], 0.00000000, 0.00000000, CrateFacility[id][cfPos][3], CrateFacility[id][cfVw], CrateFacility[id][cfInt]);
	format(string, sizeof(string), "{FFFF00}%s (ID: {1FBDFF}%d{FFFF00})\n{FFFF00}So thung: {1FBDFF}%d/%d", CrateFacility[id][cfName], id, CrateFacility[id][cfProdReady], CrateFacility[id][cfProdMax]);
	CrateFacility[id][cfTextID] = CreateDynamic3DTextLabel(string, COLOR_YELLOW, CrateFacility[id][cfPos][0], CrateFacility[id][cfPos][1], CrateFacility[id][cfPos][2]+1.5, 20.0, .testlos = 1, .worldid = CrateFacility[id][cfVw], .interiorid = CrateFacility[id][cfInt], .streamdistance = 20.0);
	FacilityBoxUpdate(id);
	return 1;
}

stock SaveFacility(i) {
	if(!(0 <= i < MAX_CRATE_FACILITY)) return 0;
	FacilityBoxUpdate(i);
	new query[2048];
	format(query, 2048, "UPDATE `crate_facility` SET ");
	SaveInteger(query, "crate_facility", i+1, "Group", CrateFacility[i][cfGroup]);
	SaveString(query, "crate_facility", i+1, "Name", CrateFacility[i][cfName]);
	SaveFloat(query, "crate_facility", i+1, "Posx", CrateFacility[i][cfPos][0]);
	SaveFloat(query, "crate_facility", i+1, "Posy", CrateFacility[i][cfPos][1]);
	SaveFloat(query, "crate_facility", i+1, "Posz", CrateFacility[i][cfPos][2]);
	SaveFloat(query, "crate_facility", i+1, "Posr", CrateFacility[i][cfPos][3]);
	SaveInteger(query, "crate_facility", i+1, "Int", CrateFacility[i][cfInt]);
	SaveInteger(query, "crate_facility", i+1, "Vw", CrateFacility[i][cfVw]);
	SaveInteger(query, "crate_facility", i+1, "Prodmax", CrateFacility[i][cfProdMax]);
	SaveInteger(query, "crate_facility", i+1, "ProdPrep", CrateFacility[i][cfProdPrep]);
	SaveInteger(query, "crate_facility", i+1, "ProdReady", CrateFacility[i][cfProdReady]);
	SaveInteger(query, "crate_facility", i+1, "ProdTimer", CrateFacility[i][cfProdTimer]);
	SaveInteger(query, "crate_facility", i+1, "ProdStatus", CrateFacility[i][cfProdStatus]);
	SaveInteger(query, "crate_facility", i+1, "ProdCost", CrateFacility[i][cfProdCost]);
	SaveInteger(query, "crate_facility", i+1, "ProdMulti", CrateFacility[i][cfProdMulti]);
	SaveInteger(query, "crate_facility", i+1, "RaidTimer", CrateFacility[i][cfRaidTimer]);
	SaveInteger(query, "crate_facility", i+1, "Cooldown", CrateFacility[i][cfCooldown]);
	SaveInteger(query, "crate_facility", i+1, "Raidable", CrateFacility[i][cfRaidable]);
	SaveInteger(query, "crate_facility", i+1, "Active", CrateFacility[i][cfActive]);
	SaveInteger(query, "crate_facility", i+1, "Timer", CrateFacility[i][cfTimer]);
	SQLUpdateFinish(query, "crate_facility", i+1);
	return 1;
}


task UpdateFacilityCrates[1000]()
{
	for(new i = 0; i < MAX_CRATE_FACILITY; i++)
	{
		new 
			previousTimer = CrateFacility[i][cfTimer], 
			previousReady = CrateFacility[i][cfProdReady], 
			previousPrep = CrateFacility[i][cfProdPrep];
		
		if(CrateFacility[i][cfId] > 0 && CrateFacility[i][cfActive] == 1) {
			if(CrateFacility[i][cfProdPrep] > 0 && CrateFacility[i][cfProdStatus] == 1 && CrateFacility[i][cfProdTimer] > 0) {
				if(CrateFacility[i][cfTimer] > 0) CrateFacility[i][cfTimer]--;
				if(!CrateFacility[i][cfTimer]) {
					if(CrateFacility[i][cfProdReady] < CrateFacility[i][cfProdMax]) {
						++CrateFacility[i][cfProdReady];
						--CrateFacility[i][cfProdPrep];
						CrateFacility[i][cfTimer] = CrateFacility[i][cfProdTimer];
					}
				}
			}
			if(CrateFacility[i][cfRaidable]) {
				if((CrateFacility[i][cfCooldown] - 300) == gettime() && CrateFacility[i][cfRaidTimer] == 0) {
					CrateFacilityRaid[i] = 1;
					foreach(new g: Player) {
						if(PlayerInfo[g][pMember] == CrateFacility[i][cfGroup]) {
							SendClientMessageEx(g, COLOR_LIGHTRED, "%s: Chung toi sap san xuat, hay chu y.", CrateFacility[i][cfName]);
							SendClientMessageEx(g, COLOR_YELLOW, "** Ban co 5 phut de chuan bi dot kich co so. **");
						}
					}
				}
				if(CrateFacility[i][cfCooldown] < gettime() && CrateFacility[i][cfRaidTimer] == 0) {
					CrateFacility[i][cfRaidTimer] = gettime()+5400; // 1 hour 30 minutes
					CrateFacilityRaid[i] = 1; // Just incase an admin sets the raid time lower than 5 min interval
					SaveFacility(i);
					TriggerGates(i);
					foreach(new g: Player) {
						if(IsACriminal(g)) {
							SendClientMessageEx(g, COLOR_YELLOW, "SMS: Nghe don co so %s dang xu ly thung hang!, Nguoi gui: Unknown.", CrateFacility[i][cfName]);
							SendClientMessageEx(g, COLOR_YELLOW, "** Ban co 1 gio 30 phut de dot kich truoc khi co so tam nghi. **");
						}
						if(PlayerInfo[g][pMember] == CrateFacility[i][cfGroup]) {
							SendClientMessageEx(g, COLOR_LIGHTRED, "%s: Dang xu ly thung hang!", CrateFacility[i][cfName]);
							SendClientMessageEx(g, COLOR_YELLOW, "** Ban co 1 gio 30 phut de bao ve co so truoc khi tam nghi. **");
						}
					}
				}
				if((CrateFacility[i][cfRaidTimer] - 300) == gettime() && CrateFacility[i][cfRaidTimer] != 0) {
					foreach(new g: Player) {
						if(IsACriminal(g)) {
							SendClientMessageEx(g, COLOR_YELLOW, "** Con 5 phut truoc khi tat ca cong dong lai! **", CrateFacility[i][cfName]);
						}
						if(PlayerInfo[g][pMember] == CrateFacility[i][cfGroup]) {
							SendClientMessageEx(g, COLOR_LIGHTRED, "%s: San xuat thung hang sap hoan tat!", CrateFacility[i][cfName]);
							SendClientMessageEx(g, COLOR_YELLOW, "** Con 5 phut bao ve truoc khi co so phong toa. **");
						}
					}
				}
				if(CrateFacility[i][cfRaidTimer] < gettime() && CrateFacility[i][cfRaidTimer] != 0) {
					CrateFacility[i][cfCooldown] = gettime()+10800; // 3 hours
					CrateFacility[i][cfRaidTimer] = 0;
					CrateFacilityRaid[i] = 0;
					SaveFacility(i);
					TriggerGates(i, 0);
					foreach(new g: Player) {
						if(IsACriminal(g)) {
							SendClientMessageEx(g, COLOR_YELLOW, "SMS: Co so %s da phong toa. (( Thoi gian cho )), Nguoi gui: Unknown.", CrateFacility[i][cfName]);
							SendClientMessageEx(g, COLOR_YELLOW, "** Khong the dot kich nua, co so se tam nghi trong thoi gian ngau nhien. **", CrateFacility[i][cfName]);
						}
						if(PlayerInfo[g][pMember] == CrateFacility[i][cfGroup]) {
							SendClientMessageEx(g, COLOR_LIGHTRED, "%s: Co so da san xuat xong thung hang!", CrateFacility[i][cfName]);
							SendClientMessageEx(g, COLOR_YELLOW, "** Khong the dot kich co so nua, thoi gian tam nghi duoc chon ngau nhien. **");
						}
					}
				}
			}
		}
		if((CrateFacility[i][cfProdReady] >= CrateFacility[i][cfProdMax]) && CrateFacility[i][cfProdPrep] > 0) {
			CrateFacility[i][cfProdPrep] = 0;
		}
		if(previousReady != CrateFacility[i][cfProdReady] || previousPrep != CrateFacility[i][cfProdPrep]) SaveFacility(i);
		else if(previousTimer != CrateFacility[i][cfTimer]) FacilityBoxUpdate(i);
	}
	for(new c = 0; c < MAX_CRATES; c++)
	{
		if(CrateBox[c][cbActive] == 1 && CrateBox[c][cbFacility] != -1 && CrateBox[c][cbGroup] == -1) {
			if(CrateBox[c][cbLifespan] > 0) CrateBox[c][cbLifespan]--;
			if(!CrateBox[c][cbLifespan]) {
				DestroyCrate(c);
			}
			else CrateBoxUpdate(c);
		}
	}
	foreach(new p: Player) {
		if(CarryCrate[p] >= 0) {
			if(!IsPlayerAttachedObjectSlotUsed(p, 8)) SetPlayerAttachedObject(p, 8, 964, 1, -0.071, 0.536, -0.026999, -2.19999, 87.1999, 0.699999, 0.479999, 0.538999, 0.419999);
			if(GetPlayerSpecialAction(p) != SPECIAL_ACTION_CARRY) SetPlayerSpecialAction(p, SPECIAL_ACTION_CARRY);
		}
		if(CarryCrate[p] >= 0) {
			if(PlayerInfo[p][pHospital] > 0 || PlayerInfo[p][pJailTime] > 0 || GetPVarType(p, "IsInArena") || GetPVarInt(p, "EventToken") != 0) {
				PlayerCarryCrate(p, CarryCrate[p], -1, 4);
			}
			else if(PlayerCuffed[p] != 0 || GetPVarInt(p, "Injured") != 0) {
				PlayerCarryCrate(p, CarryCrate[p], -1, 5);
			}
		}
	}
}

forward CrateBoxUpdate(id);
public CrateBoxUpdate(id) {
	if(!IsValidCrate(id) || !(0 <= CrateBox[id][cbFacility] < MAX_CRATE_FACILITY)) return 0;
	new string[256];
	if(IsValidDynamic3DTextLabel(CrateBox[id][cbTextID])) {
		format(string, sizeof(string), "{FFFF00}%s (ID: {FF8000}%d{FFFF00})\n{FFFF00}Con lai: {FF8000}%s\n{FFFF00}Nguoi dat: {FF8000}%s\n{FFFF00}Vat lieu: {FF8000}%d/50", CrateFacility[CrateBox[id][cbFacility]][cfName], id, TimeConvert(CrateBox[id][cbLifespan]), CrateBox[id][cbPlacedBy], CrateBox[id][cbMats]);
		//format(string, sizeof(string), "{FFFF00}ID: {FF8000}%d\n{FFFF00}Time Remaining: {FF8000}%s\n{FFFF00}Placed By: {FF8000}%s", id, TimeConvert(CrateBox[id][cbLifespan]), CrateBox[id][cbPlacedBy]);
		UpdateDynamic3DTextLabelText(CrateBox[id][cbTextID], COLOR_ORANGE, string);
	}
	return 1;
}

forward FacilityBoxUpdate(id);
public FacilityBoxUpdate(id) {
	if(!(0 <= id < MAX_CRATE_FACILITY) || !IsValidDynamic3DTextLabel(CrateFacility[id][cfTextID])) return 0;
	new string[256];
	if(CrateFacility[id][cfActive] == 1) {
		if(CrateFacility[id][cfProdStatus] == 1 && CrateFacility[id][cfProdTimer] > 0) {
			if(CrateFacility[id][cfProdReady] < CrateFacility[id][cfProdMax] && CrateFacility[id][cfProdPrep] > 0) {
				format(string, sizeof(string), "{FFFF00}%s (ID: {FF8000}%d{FFFF00})\n{FFFF00}So thung: {FF8000}%d/%d\n{FFFF00}Dot san xuat sau: {FF8000}%s", CrateFacility[id][cfName], id, CrateFacility[id][cfProdReady], CrateFacility[id][cfProdMax], STimeConvert(CrateFacility[id][cfTimer]));
			}
			else if(CrateFacility[id][cfProdReady] < CrateFacility[id][cfProdMax] && CrateFacility[id][cfProdPrep] == 0) {
				format(string, sizeof(string), "{FFFF00}%s (ID: {FF8000}%d{FFFF00})\n{FFFF00}So thung: {FF8000}%d/%d\n{FFFF00}Da dung san xuat, tat ca thung\nda duoc xuat di.", CrateFacility[id][cfName], id, CrateFacility[id][cfProdReady], CrateFacility[id][cfProdMax]);
			}
			else format(string, sizeof(string), "{FFFF00}%s (ID: {FF8000}%d{FFFF00})\n{FFFF00}So thung: {FF8000}%d/%d", CrateFacility[id][cfName], id, CrateFacility[id][cfProdReady], CrateFacility[id][cfProdMax]);
		}
		else format(string, sizeof(string), "{FFFF00}%s (ID: {FF8000}%d{FFFF00})\n{FFFF00}So thung: {FF8000}%d/%d\n{FFFF00}Dang tam dung san xuat\nkhong tao them thung hang.", CrateFacility[id][cfName], id, CrateFacility[id][cfProdReady], CrateFacility[id][cfProdMax]);
	} else {
		format(string, sizeof(string), "{FFFF00}%s (ID: {FF8000}%d{FFFF00})\n{FFFF00}Da dung san xuat.\nCo so hien dong cua.", CrateFacility[id][cfName], id);
	}
	UpdateDynamic3DTextLabelText(CrateFacility[id][cfTextID], COLOR_YELLOW, string);
	return 1;
}

stock FetchFacility(playerid, &facility, Float:range)
{
	facility = -1;
    for(new f = 0; f < MAX_CRATE_FACILITY; f++)
    {
		if(CrateFacility[f][cfId] > 0 && CrateFacility[f][cfPos][0] != 0.0 && IsPlayerInRangeOfPoint(playerid,range,CrateFacility[f][cfPos][0], CrateFacility[f][cfPos][1], CrateFacility[f][cfPos][2]))
		{
			if(GetPlayerVirtualWorld(playerid) == CrateFacility[f][cfVw] && GetPlayerInterior(playerid) == CrateFacility[f][cfInt]) {
				facility = f;
				break;
			}
	    }
 	}
}

stock GetCrateBox(playerid, &box, Float:range)
{
	box = -1;
    for(new b = 0; b < MAX_CRATES; b++)
    {
    	if(BeingMoved[b] == INVALID_PLAYER_ID && CrateBox[b][cbOnVeh] == -1 && CrateBox[b][cbInVeh] == -1 && CrateBox[b][cbActive]) {
	 	    if(IsPlayerInRangeOfPoint(playerid,range,CrateBox[b][cbPos][0], CrateBox[b][cbPos][1], CrateBox[b][cbPos][2]))
			{
				if(GetPlayerVirtualWorld(playerid) == CrateBox[b][cbVw] && GetPlayerInterior(playerid) == CrateBox[b][cbInt]) {
					box = b;
					break;
				}
		    }
		}
 	}
}

// Used for tracking / transferring weapons from and to the locker
stock GetGroupCrate(playerid, &box) {
	box = -1;
    for(new b = 0; b < MAX_CRATES; b++)
    {
		if(CrateBox[b][cbActive] && ValidGroup(PlayerInfo[playerid][pMember]) && PlayerInfo[playerid][pMember] == CrateBox[b][cbGroup])
		{
			box = b;
			break;
	    }
 	}
}

forward LoadForklift(playerid, session, token);
public LoadForklift(playerid, session, token) {
	if(!IsPlayerConnected(playerid) || g_arrQueryHandle[playerid] != session || CrateAction[playerid][caToken] != token) return 1;
	new facility = CrateAction[playerid][caFacility], boxid = CrateAction[playerid][caBox], vehicle = CrateAction[playerid][caVehicle];
	if(!(0 <= facility < MAX_CRATE_FACILITY) || !IsValidCrate(boxid) || !(0 <= vehicle < MAX_CRATE_VEHCILES)) return CancelCrateAction(playerid);
	if(CrateBeingProcessed[facility] != playerid + 1 || CrateBox[boxid][cbActive] || CrateBox[boxid][cbFacility] != facility) return CancelCrateAction(playerid);
    szMiscArray[0] = 0;
	new string[128];
	SetPVarInt(playerid, "LoadForkliftTime", GetPVarInt(playerid, "LoadForkliftTime")-1);
	format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~w~Con %d giay", GetPVarInt(playerid, "LoadForkliftTime"));
	GameTextForPlayer(playerid, string, 1100, 3);

	if(GetPVarInt(playerid, "LoadForkliftTime") > 0) {
		CrateAction[playerid][caTimer] = SetTimerEx("LoadForklift", 1000, false, "iii", playerid, session, token);
		return 1;
	}

	if(GetPVarInt(playerid, "LoadForkliftTime") <= 0)
	{
		CancelCrateAction(playerid);
		if(!CrateFacility[facility][cfActive] || CrateFacility[facility][cfProdReady] < 1 || CrateFacility[facility][cfProdCost] < 0) return SendClientMessageEx(playerid, COLOR_GREY, "Co so khong con kha dung.");
		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER || !IsValidVehicle(CrateVehicle[vehicle][cvSpawnID]) || GetPlayerVehicleID(playerid) != CrateVehicle[vehicle][cvSpawnID] || GetVehicleModel(CrateVehicle[vehicle][cvSpawnID]) != 530 || CrateVehicle[vehicle][cvCrate] != -1) return SendClientMessageEx(playerid, COLOR_GREY, "Phai o tren cung xe nang rong.");
		if(PlayerBusy(playerid)) return 1;
		if(IsACriminal(playerid) && (!CrateFacility[facility][cfRaidable] || (!AdminOpened[facility] && CrateFacility[facility][cfRaidTimer] <= gettime()))) return SendClientMessageEx(playerid, COLOR_GREY, "Chua the dot kich co so nay.");
		if(!ValidGroup(PlayerInfo[playerid][pMember])) {
			SendClientMessageEx(playerid, COLOR_GRAD2, "Tai thung that bai. Ban khong con trong to chuc!");
			return 1;
		}
 	    if(!IsPlayerInRangeOfPoint(playerid, 3.0, CrateFacility[facility][cfPos][0], CrateFacility[facility][cfPos][1], CrateFacility[facility][cfPos][2])) {
			SendClientMessageEx(playerid, COLOR_GRAD2, "Tai thung that bai. Ban da roi pham vi co so!");
			return 1;
	    }
	    if(GetPlayerVirtualWorld(playerid) != CrateFacility[facility][cfVw] || GetPlayerInterior(playerid) != CrateFacility[facility][cfInt]) {
	    	SendClientMessageEx(playerid, COLOR_GRAD2, "Tai thung that bai. Ban da doi virtual world/interior.");
	    	return 1;
	    }
	    if(playerTabbed[playerid] != 0) {
	    	SendClientMessageEx(playerid, COLOR_GRAD2, "Tai thung that bai. Ban da alt-tab.");
	    	return 1;
	    }
		new owner = CrateFacility[facility][cfGroup], cost = CrateFacility[facility][cfProdCost], group = PlayerInfo[playerid][pMember];
		if(owner != -1 && !ValidGroup(owner)) 
			return SendClientMessageEx(playerid, COLOR_GREY, "Chu co so khong hop le.");
		
		if(!IsACriminal(playerid) && owner != group && cost > 0) {
			if(GetGroupBudget(group) < cost) 
				return SendClientMessageEx(playerid, COLOR_GREY, "To chuc khong du tien mua thung.");
			
			new balance = ValidGroup(owner) ? GetGroupBudget(owner) : (arrGroupData[group][g_iAllegiance] == 2 ? TRTax : Tax);
			if(balance > cellmax - cost) 
				return SendClientMessageEx(playerid, COLOR_GREY, "So du ben nhan khong the nhan khoan nay.");
		}
		new object = CreateDynamicObject(964, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
		if(!IsValidDynamicObject(object)) return SendClientMessageEx(playerid, COLOR_GREY, "Khong tao duoc object thung hang.");
		if(!AttachDynamicObjectToVehicle(object, CrateVehicle[vehicle][cvSpawnID], 0.0, 0.9, -0.2, 0.0, 0.0, 0.0)) {
			DestroyDynamicObject(object);
			return SendClientMessageEx(playerid, COLOR_GREY, "Khong tai duoc object thung hang.");
		}
		CrateBox[boxid][cbPaid] = IsACriminal(playerid) || cost == 0;
		if(!IsACriminal(playerid)) {
			if(CrateFacility[facility][cfProdCost] > 0) {
				if(PlayerInfo[playerid][pMember] != CrateFacility[facility][cfGroup]) {
					if(GetGroupBudget(PlayerInfo[playerid][pMember]) < CrateFacility[facility][cfProdCost]) return SendClientMessageEx(playerid, COLOR_GRAD1, "To chuc khong co $%s de mua thung nay!", number_format(CrateFacility[facility][cfProdCost]));
					SetGroupBudget(PlayerInfo[playerid][pMember], -CrateFacility[facility][cfProdCost]);
					CrateBox[boxid][cbPaid] = 1;
					format(string, sizeof(string), "%s has purchased a crate from the %s facility costing %s.", GetPlayerNameEx(playerid), CrateFacility[facility][cfName], number_format(CrateFacility[facility][cfProdCost]));
					GroupPayLog(PlayerInfo[playerid][pMember], string);
					if(CrateFacility[facility][cfGroup] == -1) {
						if(arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance] == 2) {
							TRTax += CrateFacility[facility][cfProdCost];
							format(string, sizeof(string), "%s has purchased a crate from an unowned facility in your nation adding $%s", arrGroupData[PlayerInfo[playerid][pMember]][g_szGroupName], number_format(CrateFacility[facility][cfProdCost]));
							GroupPayLog(8, string);
						} else {
							Tax += CrateFacility[facility][cfProdCost];
							format(string, sizeof(string), "%s has purchased a crate from an unowned facility in your nation adding $%s", arrGroupData[PlayerInfo[playerid][pMember]][g_szGroupName], number_format(CrateFacility[facility][cfProdCost]));
							GroupPayLog(5, string);
						}
					} else {
						SetGroupBudget(CrateFacility[facility][cfGroup], CrateFacility[facility][cfProdCost]);
						SaveGroup(CrateFacility[facility][cfGroup]);
						format(string, sizeof(string), "%s has purchased a crate from your facility adding $%s", arrGroupData[PlayerInfo[playerid][pMember]][g_szGroupName], number_format(CrateFacility[facility][cfProdCost]));
						GroupPayLog(CrateFacility[facility][cfGroup], string);
					}
					SendClientMessageEx(playerid, COLOR_YELLOW, "To chuc da bi tru %s cho thung nay!", number_format(CrateFacility[facility][cfProdCost]));
				}
				else {
					SendClientMessageEx(playerid, COLOR_YELLOW, "To chuc chua bi thu phi, nhung can tra tien neu cat thung vao tu!");
				}
			}
			SaveGroup(PlayerInfo[playerid][pMember]);
        	format(string, sizeof(string), "%s %s has manufactured a crate at %s facility.", arrGroupRanks[PlayerInfo[playerid][pMember]][PlayerInfo[playerid][pRank]], GetPlayerNameEx(playerid), CrateFacility[facility][cfName]);
          	GroupLog(PlayerInfo[playerid][pMember], string);
        	format(string, sizeof(string), "%s %s da san xuat thung hang tai co so %s.", arrGroupRanks[PlayerInfo[playerid][pMember]][PlayerInfo[playerid][pRank]], GetPlayerNameEx(playerid), CrateFacility[facility][cfName]);
          	ABroadCast(COLOR_LIGHTRED, string, 2);
          	if(ValidGroup(CrateFacility[facility][cfGroup])) {
          		foreach(new i: Player) {
          			if(PlayerInfo[i][pMember] == CrateFacility[facility][cfGroup]) {
          				SendClientMessageEx(i, COLOR_LIGHTRED, "Mot thung hang da duoc san xuat tai co so %s.", CrateFacility[facility][cfName]);
          			}
          		}
          	}
		}
		CrateBox[boxid][cbLifespan] = 7200;
		CrateBox[boxid][cbFacility] = facility;
		CrateBox[boxid][cbGroup] = -1;
		CrateBox[boxid][cbTransfer] = 1;
		CrateBox[boxid][cbOnVeh] = vehicle;
		CrateBox[boxid][cbPrice] = CrateFacility[facility][cfProdCost];
		CrateBox[boxid][cbMats] = 50;
		CrateBox[boxid][cbActive] = 1;
		CrateVehicle[vehicle][cvForkObject] = object;
		CrateVehicle[vehicle][cvCrate] = boxid;
		--CrateFacility[facility][cfProdReady];
		SaveCrate(boxid);
		SaveFacility(facility);
		SaveCrateVehicle(vehicle);
		Streamer_Update(playerid);
	}
	return 1;
}

forward PlayerCarryCrate(playerid, boxid, vehid, action);
public PlayerCarryCrate(playerid, boxid, vehid, action) {
	if(!IsValidCrate(boxid) || !CrateBox[boxid][cbActive]) return 0;
	if(action != 0 && action != 2 && (CarryCrate[playerid] != boxid || BeingMoved[boxid] != playerid)) return 0;
	if(action == 4 || action == 5) CancelCrateAction(playerid);
	/*
	--- Action ---
	0 - Pickup from floor
	1 - Put on floor
	2 - Take from vehicle
	3 - Put in vehicle
	4-5 - Player went to busy mode (Events, Prison, Death etc..)
	*/
	if(action == 0) {
		SendClientMessageEx(playerid, COLOR_GRAD2, "Nhan nut '{FFFF00}FIRE{BFC0C2}' de dat thung xuong dat");
		SendClientMessageEx(playerid, COLOR_GRAD2, "hoac dung '{FFFF00}/crate store{BFC0C2}' de cat vao xe phu hop.");
		if(PlayerHoldingObject[playerid][8] != 0 || IsPlayerAttachedObjectSlotUsed(playerid, 8))
			RemovePlayerAttachedObject(playerid, 8), PlayerHoldingObject[playerid][8] = 0;
		SetPlayerAttachedObject(playerid, 8, 964, 1, -0.071, 0.536, -0.026999, -2.19999, 87.1999, 0.699999, 0.479999, 0.538999, 0.419999);
		if(GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_CARRY) SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
		CarryCrate[playerid] = boxid;
		BeingMoved[boxid] = playerid;
	}
	if(action == 1) {
		new Float: pcbPos[3];
		GetPlayerPos(playerid, pcbPos[0], pcbPos[1], pcbPos[2]);
		GetXYInFrontOfPlayer(playerid, pcbPos[0], pcbPos[1], 1);
		CrateBox[boxid][cbPos][0] = pcbPos[0];
		CrateBox[boxid][cbPos][1] = pcbPos[1];
		CrateBox[boxid][cbPos][2] = pcbPos[2]-1.0;
		CrateBox[boxid][cbInt] = GetPlayerInterior(playerid);
		CrateBox[boxid][cbVw] = GetPlayerVirtualWorld(playerid);
		CrateBox[boxid][cbPlacedBy] = GetPlayerNameEx(playerid);
		RemovePlayerAttachedObject(playerid, 8);
		PlayerHoldingObject[playerid][8] = 0;
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
		CarryCrate[playerid] = -1;
		BeingMoved[boxid] = INVALID_PLAYER_ID;
		SaveCrate(boxid);
	}
	if(action == 2) {
		SendClientMessageEx(playerid, COLOR_GRAD2, "Nhan nut '{FFFF00}FIRE{BFC0C2}' de dat thung xuong dat");
		SendClientMessageEx(playerid, COLOR_GRAD2, "hoac dung '{FFFF00}/crate store{BFC0C2}' de cat vao xe phu hop.");
		if(PlayerHoldingObject[playerid][8] != 0 || IsPlayerAttachedObjectSlotUsed(playerid, 8))
			RemovePlayerAttachedObject(playerid, 8), PlayerHoldingObject[playerid][8] = 0;
		SetPlayerAttachedObject(playerid, 8, 964, 1, -0.071, 0.536, -0.026999, -2.19999, 87.1999, 0.699999, 0.479999, 0.538999, 0.419999);
		if(GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_CARRY) SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
		CrateBox[boxid][cbInVeh] = -1;
		CarryCrate[playerid] = boxid;
		BeingMoved[boxid] = playerid;
		SaveCrate(boxid);
		format(szMiscArray, sizeof(szMiscArray), "* %s da do thung hang khoi %s.", GetPlayerNameEx(playerid), GetVehicleName(CrateVehicle[vehid][cvSpawnID]));
		ProxDetector(25.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	}
	if(action == 3) {
		CrateBox[boxid][cbInVeh] = vehid;
		RemovePlayerAttachedObject(playerid, 8);
		PlayerHoldingObject[playerid][8] = 0;
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
		CarryCrate[playerid] = -1;
		BeingMoved[boxid] = INVALID_PLAYER_ID;
		SaveCrate(boxid);
		format(szMiscArray, sizeof(szMiscArray), "* %s da cat thung hang vao %s.", GetPlayerNameEx(playerid), GetVehicleName(CrateVehicle[vehid][cvSpawnID]));
		ProxDetector(25.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	}
	if(action == 4 || action == 5) {
		if(action == 4) SendClientMessageEx(playerid, COLOR_YELLOW, "SMS: Dang lam gi vay?! Ta se lay lai thung vi nguoi qua ban de xong viec!, Nguoi gui: Unknown");
		if(action == 5) {
			SendClientMessageEx(playerid, COLOR_YELLOW, "SMS: Ban khong the mang thung, thung da duoc dat xuong!, Nguoi gui: Unknown");
			new Float: pcbPos[3];
			GetPlayerPos(playerid, pcbPos[0], pcbPos[1], pcbPos[2]);
			GetXYInFrontOfPlayer(playerid, pcbPos[0], pcbPos[1], 1);
			CrateBox[boxid][cbPos][0] = pcbPos[0];
			CrateBox[boxid][cbPos][1] = pcbPos[1];
			CrateBox[boxid][cbPos][2] = pcbPos[2]-1.0;
			CrateBox[boxid][cbInt] = GetPlayerInterior(playerid);
			CrateBox[boxid][cbVw] = GetPlayerVirtualWorld(playerid);
			CrateBox[boxid][cbPlacedBy] = GetPlayerNameEx(playerid);
			SaveCrate(boxid);
		}
		RemovePlayerAttachedObject(playerid, 8);
		PlayerHoldingObject[playerid][8] = 0;
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
		CarryCrate[playerid] = -1;
		BeingMoved[boxid] = INVALID_PLAYER_ID;
	}
	UpdateCrateBox(boxid);
	Streamer_Update(playerid);
	return 1;
}

stock DestroyCrate(box, bool:saveFacility = true) {
	if(!IsValidCrate(box)) return 0;
	++CrateGeneration[box];
	foreach(new playerid : Player) {
		if(CrateAction[playerid][caTimer] && CrateAction[playerid][caBox] == box) CancelCrateAction(playerid);
	}
	// Is the box on a fork lift?
	if(0 <= CrateBox[box][cbOnVeh] < MAX_CRATE_VEHCILES && CrateVehicle[CrateBox[box][cbOnVeh]][cvCrate] == box) {
		if(IsValidDynamicObject(CrateVehicle[CrateBox[box][cbOnVeh]][cvForkObject])) DestroyDynamicObject(CrateVehicle[CrateBox[box][cbOnVeh]][cvForkObject]);
		CrateVehicle[CrateBox[box][cbOnVeh]][cvForkObject] = -1;
		CrateVehicle[CrateBox[box][cbOnVeh]][cvCrate] = -1;
		CrateVehicle[CrateBox[box][cbOnVeh]][cvCrateLoad] = 0;
		SaveCrateVehicle(CrateBox[box][cbOnVeh]);
		CrateBox[box][cbOnVeh] = -1;
	}
	if(0 <= BeingMoved[box] < MAX_PLAYERS && CarryCrate[BeingMoved[box]] == box) {
		RemovePlayerAttachedObject(BeingMoved[box], 8);
		PlayerHoldingObject[BeingMoved[box]][8] = 0;
		SetPlayerSpecialAction(BeingMoved[box], SPECIAL_ACTION_NONE);
		CarryCrate[BeingMoved[box]] = -1;
		BeingMoved[box] = INVALID_PLAYER_ID;
	}
	if(CrateBox[box][cbActive] && 0 <= CrateBox[box][cbFacility] < MAX_CRATE_FACILITY) {
		new facility = CrateBox[box][cbFacility];
		if(CrateFacility[facility][cfProdPrep] < CrateFacility[facility][cfProdMax]) ++CrateFacility[facility][cfProdPrep];
		if(saveFacility) SaveFacility(facility);
	}
	BeingMoved[box] = INVALID_PLAYER_ID;
	CrateBox[box][cbFacility] = -1;
	CrateBox[box][cbGroup] = -1;
	CrateBox[box][cbPos][0] = 0.00000;
	CrateBox[box][cbPos][1] = 0.00000;
	CrateBox[box][cbPos][2] = 0.00000;
	CrateBox[box][cbInt] = 0;
	CrateBox[box][cbInVeh] = -1;
	CrateBox[box][cbOnVeh] = -1;
	CrateBox[box][cbVw] = 0;
	CrateBox[box][cbMats] = 0;
	for(new w = 0; w < 16; w++) {
		CrateBox[box][cbWep][w] = 0;
		CrateBox[box][cbWepAmount][w] = 0;
	}
	format(CrateBox[box][cbPlacedBy], MAX_PLAYER_NAME, "Unknown");
	CrateBox[box][cbLifespan] = 0;
	CrateBox[box][cbTransfer] = 0;
	CrateBox[box][cbDoor] = -1;
	CrateBox[box][cbDoorType] = -1;
	CrateBox[box][cbPrice] = 0;
	CrateBox[box][cbPaid] = 0;
	CrateBox[box][cbActive] = 0;
	SaveCrate(box);
	UpdateCrateBox(box);
	return 1;
}

stock IsValidCrate(box) {
	if((0 <= box < MAX_CRATES)) return 1;
	else return 0;
}

CMD:facility(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] > 3 || PlayerInfo[playerid][pASM] > 0 || PlayerInfo[playerid][pFactionModerator] > 0) {
		szMiscArray[0] = 0;
		new choice[32], fac, value;
		if(sscanf(params, "s[32]iD(-1)", choice, fac, value))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /facility [name] [id]");
			SendClientMessageEx(playerid, COLOR_GREY, "Ten: sync goto, raidable, info");
			SendClientMessageEx(playerid, COLOR_GREY, "THEM: Dung /cfedit neu muon sua co so.");
			return 1;
		}
		if(!(0 <= fac < MAX_CRATE_FACILITY)) return SendClientMessageEx(playerid, COLOR_GREY, "ID co so sai. (0 - %d)", MAX_CRATE_FACILITY-1);
		if(strcmp(choice, "sync", true) == 0) {
			if(!CrateFacility[fac][cfActive]) return SendClientMessageEx(playerid, COLOR_GREY, "Co so thung hang chua hoat dong!");
			SyncFacility(fac);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da dong bo co so %s, thung bi thieu se duoc san xuat bu.", CrateFacility[fac][cfName]);
			return 1;
		}
		else if(strcmp(choice, "goto", true) == 0) {
			if(CrateFacility[fac][cfPos][0] == 0.0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the den co so vi chua duoc su dung!");
			SetPlayerInterior(playerid, CrateFacility[fac][cfInt]);
			SetPlayerPos(playerid, CrateFacility[fac][cfPos][0], CrateFacility[fac][cfPos][1], CrateFacility[fac][cfPos][2]+1.0);
			PlayerInfo[playerid][pInt] = CrateFacility[fac][cfInt];
			SetPlayerVirtualWorld(playerid, CrateFacility[fac][cfVw]);
			PlayerInfo[playerid][pVW] = CrateFacility[fac][cfVw];
			if(CrateFacility[fac][cfInt] > 0) Player_StreamPrep(playerid, CrateFacility[fac][cfPos][0], CrateFacility[fac][cfPos][1], CrateFacility[fac][cfPos][2]+1.0, FREEZE_TIME);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da dich chuyen den co so thung hang %d.", fac);
			return 1;
		}
		else if(strcmp(choice, "raidable", true) == 0) {
			if(!CrateFacility[fac][cfActive]) return SendClientMessageEx(playerid, COLOR_GREY, "Co so thung hang chua hoat dong!");
			if(AdminOpened[fac]) {
				if(CrateFacility[fac][cfRaidTimer] == 0) TriggerGates(fac, 0);
	    		format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s da cam dot kich tu do co so %s. (ID: %d)", GetPlayerNameEx(playerid), CrateFacility[fac][cfName], fac);
				SendClientMessageEx(playerid, COLOR_WHITE, "Ban da cam dot kich tu do co so %s.", CrateFacility[fac][cfName]);
				ABroadCast(COLOR_YELLOW, szMiscArray, 2);
				AdminOpened[fac] = 0;
			} else {
				TriggerGates(fac);
	    		format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s da cho dot kich tu do co so %s. (ID: %d)", GetPlayerNameEx(playerid), CrateFacility[fac][cfName], fac);
				SendClientMessageEx(playerid, COLOR_WHITE, "Ban da cho dot kich tu do co so %s.", CrateFacility[fac][cfName]);
				ABroadCast(COLOR_YELLOW, szMiscArray, 2);
				AdminOpened[fac] = 1;
			}
			return 1;
		}
		else if(strcmp(choice, "info", true) == 0) {
			new crates = 0, group[32];
			for(new c = 0; c < MAX_CRATES; c++) {
				if(CrateBox[c][cbFacility] == fac) {
					++crates;
				}
			}

			if(CrateFacility[fac][cfGroup] != -1 && ValidGroup(CrateFacility[fac][cfGroup])) {
				format(group, sizeof(group), "%s", arrGroupData[CrateFacility[fac][cfGroup]][g_szGroupName]);
			} else {
				format(group, sizeof(group), "--");
			}
			SendClientMessageEx(playerid, COLOR_GREEN, "|___________ Co so (ID: %d) ___________|", fac);
			SendClientMessageEx(playerid, COLOR_WHITE, "X: %f | Y: %f | Z: %f | Int: %d | VW: %d | Bat: %s", CrateFacility[fac][cfPos][0], CrateFacility[fac][cfPos][1], CrateFacility[fac][cfPos][2], CrateFacility[fac][cfInt], CrateFacility[fac][cfVw], (CrateFacility[fac][cfActive]) ? ("Co") : ("Khong"));
			SendClientMessageEx(playerid, COLOR_WHITE, "Dot kich sau: %s | Tien do: %s | Cho dot kich: %s", date(CrateFacility[fac][cfCooldown], 1), (CrateFacilityRaid[fac]) ? ("Bat") : ("Chua san sang"), (CrateFacility[fac][cfRaidable]) ? ("Bat") : ("Tat"));
			SendClientMessageEx(playerid, COLOR_WHITE, "Thung san sang: %d | Dang tao: %d | Dang dung: %d | Toi da: %d", CrateFacility[fac][cfProdReady], CrateFacility[fac][cfProdPrep], crates, CrateFacility[fac][cfProdMax]);
			SendClientMessageEx(playerid, COLOR_WHITE, "Gia moi thung: %s | San xuat: %s", number_format(CrateFacility[fac][cfProdCost]), (CrateFacility[fac][cfProdStatus]) ? ("Bat") : ("Tam dung"));
			SendClientMessageEx(playerid, COLOR_WHITE, "Chu: %s | He so giao: %d", group, CrateFacility[fac][cfProdMulti]);
			return 1;
		}
		else SendClientMessageEx(playerid, COLOR_GREY, "Ten da chon khong hop le!");
	} else {
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay!");
	}
	return 1;
}

stock SyncFacility(id) {
	if(!(0 <= id < MAX_CRATE_FACILITY)) return 0;
	new total;
	for(new c = 0; c < MAX_CRATES; c++) {
		if(CrateBox[c][cbActive] && CrateBox[c][cbFacility] == id) ++total;
	}
	CrateFacility[id][cfProdPrep] = max(0, CrateFacility[id][cfProdMax] - CrateFacility[id][cfProdReady] - total);
	SaveFacility(id);
	return 1;
}

CMD:crate(playerid, params[]) {
	if(CrateAction[playerid][caTimer]) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Hay xong thao tac thung hang hien tai truoc.");
	
	szMiscArray[0] = 0;
	new string[128], choice[32], box, crate;
	if(sscanf(params, "s[32]D(-1)", choice, crate))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /crate [name]");
		SendClientMessageEx(playerid, COLOR_GREY, "(Di bo): Carry, Take, Contents, Seize");
		SendClientMessageEx(playerid, COLOR_GREY, "(Xe nang): Load, Drop, Store");
		if(PlayerInfo[playerid][pAdmin] > 3) SendClientMessageEx(playerid, COLOR_GREY, "Administrator: Destroy, Spawn");
		return 1;
	}
	if(PlayerBusy(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chua the lam vay.");
	if(strcmp(choice, "carry", true) == 0) {
		GetCrateBox(playerid, box, 2.0);
		if(box == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan thung hang de nhat!");
		if(CarryCrate[playerid] != -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban dang mang thung, hay cat hoac dat xuong truoc!");
		ApplyAnimation(playerid, "CARRY", "liftup", 4.1, false, false, false, false, 0, 1);
		QueueCrateMove(playerid, box, -1, 0, 1000);
		return 1;
	}
	else if(strcmp(choice, "contents", true) == 0) {
		new weaponname[32], title[24];
		GetCrateBox(playerid, box, 2.0);
		if(box == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan thung hang!");
		if(CrateBox[box][cbGroup] == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Day khong phai thung chuyen, hay dung /cgun!");
		format(title, sizeof(title), "Trong thung (ID: %d)", box);
		format(szMiscArray, sizeof(szMiscArray), "Vu khi\tSo luong\n");
		for(new w = 0; w < 16; w++) {
			if(CrateBox[box][cbWep][w] > 0) {
				GetWeaponName(CrateBox[box][cbWep][w], weaponname, sizeof(weaponname));
				format(szMiscArray, sizeof(szMiscArray), "%s%s\t%s\n", szMiscArray, weaponname, number_format(CrateBox[box][cbWepAmount][w]));
			}
		}
		if(strlen(szMiscArray) == 16) format(szMiscArray, sizeof(szMiscArray), "%sThung khong co vu khi.", szMiscArray);
		Dialog_Show(playerid, -1, DIALOG_STYLE_TABLIST_HEADERS, title, szMiscArray, "Dong", "");
		return 1;
	}
	else if(strcmp(choice, "load", true) == 0) {
		new facility, vehicleid = GetPlayerVehicleID(playerid), veh;
		FetchFacility(playerid, facility, 3.0);
		GetCrateBox(playerid, box, 3.0);
		if(!ValidGroup(PlayerInfo[playerid][pMember])) return SendClientMessage(playerid, COLOR_GRAD2, "Ban phai thuoc mot to chuc de dung lenh nay!");
		if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban can o trong xe de lam vay!");
		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai lai xe nang.");
		if(GetVehicleModel(vehicleid) != 530) return SendClientMessageEx(playerid, COLOR_GRAD2, "Can dung xe nang de tai thung hang!");
		if((veh = IsDynamicCrateVehicle(vehicleid)) == -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o tren xe chi dinh cho thao tac nay!");
		if(CrateVehicle[veh][cvCrate] != -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Xe nang da co thung hang!");
		if(facility != -1) {
			if(!CrateFacility[facility][cfActive]) return SendClientMessageEx(playerid, COLOR_GRAD1, "Co so chua hoat dong!");
			if(CrateFacility[facility][cfProdReady] < 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Co so khong con thung de tai!");
			if(CrateBeingProcessed[facility] > 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Vui long cho xu ly thung hang!");
			if(PlayerInfo[playerid][pConnectHours] < 25)
		    {
				format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s da thu tai thung khi moi choi %d gio.", GetPlayerNameEx(playerid), PlayerInfo[playerid][pConnectHours]);
				ABroadCast(COLOR_YELLOW, string, 4);
		        return SendClientMessageEx(playerid, COLOR_GRAD2, " Ban chua du gio choi de tai thung hang!");
		    }
			if(IsACriminal(playerid)) {
				if(!CrateFacility[facility][cfRaidable]) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dot kich co so nay!");
				if(!AdminOpened[facility] && !CrateFacility[facility][cfRaidTimer]) return SendClientMessageEx(playerid, COLOR_GRAD1, "Co so dang trong thoi gian cho giua cac dot kich.");
			}
			for(new c = 0; c < MAX_CRATES; c++) {
				if(!CrateBox[c][cbActive] && CrateBox[c][cbFacility] == -1 && CrateBox[c][cbGroup] == -1) {
					CancelCrateAction(playerid);
					CrateBeingProcessed[facility] = playerid + 1;
					CrateBox[c][cbFacility] = facility;
					CrateAction[playerid][caFacility] = facility;
					CrateAction[playerid][caBox] = c;
					CrateAction[playerid][caVehicle] = veh;
					SetPVarInt(playerid, "LoadForkliftTime", 5);
					CrateAction[playerid][caTimer] = SetTimerEx("LoadForklift", 1000, false, "iii", playerid, g_arrQueryHandle[playerid], CrateAction[playerid][caToken]);
					GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~w~Con 5 giay", 1100, 3);
					TogglePlayerControllable(playerid, false);
					break;
				}
			}
		}
		else if(box != -1) {
			CrateBox[box][cbOnVeh] = veh;
			CrateVehicle[veh][cvCrate] = box;
			format(string, sizeof(string), "* %s da tai thung hang len xe nang.", GetPlayerNameEx(playerid));
			ProxDetector(25.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SaveCrateVehicle(veh);
			SaveCrate(box);
			UpdateCrateBox(box);
			CrateVehCheck(veh);
		}
		else SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o gan thung de tai len xe nang!");
		return 1;
	}
	else if(strcmp(choice, "store", true) == 0) {
		szMiscArray[0] = 0;
		new Float:vPos[3], inveh = GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet ,boot, objective, VehFound = -1, boxid;
		
		for(new i = 0; i < MAX_CRATE_VEHCILES; i++) {
			if(IsValidVehicle(CrateVehicle[i][cvSpawnID]) && GetPlayerVirtualWorld(playerid) == GetVehicleVirtualWorld(CrateVehicle[i][cvSpawnID]) && GetPlayerInterior(playerid) == CrateVehicle[i][cvInt]) {
				GetPosBehindVehicle(CrateVehicle[i][cvSpawnID], vPos[0], vPos[1], vPos[2], (IsAPlane(CrateVehicle[i][cvSpawnID]) ? -8 : 0));
				if(IsPlayerInRangeOfPoint(playerid, (IsAPlane(CrateVehicle[i][cvSpawnID]) ? 6 : 2), vPos[0], vPos[1], vPos[2])) {
					if(CrateVehicle[i][cvSpawnID] != inveh) {
						VehFound = i; // Do not use the vehicle ID as we store the array ID for the validation since vehicles do not store "spawn id".
						break;
					}
				}
			}
		}
		if(VehFound == -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o gan xe co the chua thung hang.");
		if(CrateVehicle[VehFound][cvCrateMax] < 1) return SendClientMessageEx(playerid, COLOR_GRAD3, "Khong the cat thung hang vao xe nay!");
		if(CreateCount(VehFound) >= CrateVehicle[VehFound][cvCrateMax]) return SendClientMessageEx(playerid, COLOR_GRAD3, "Xe da day, khong the cat them thung hang!");
		if(VehDelivering[VehFound]) return SendClientMessageEx(playerid, COLOR_GRAD3, "Xe dang do thung hang, vui long cho!");
		GetVehicleParamsEx(CrateVehicle[VehFound][cvSpawnID], engine, lights, alarm, doors, bonnet, boot, objective);
		if(inveh > 0 && GetVehicleModel(inveh) == 530 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) { // Forklift -> Vehicle
			if(IsDynamicCrateVehicle(inveh) == -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o tren xe nang chi dinh!");
			if((boxid = CrateVehicle[IsDynamicCrateVehicle(inveh)][cvCrate]) == -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong co thung hang tren xe nang!");
			if(GetVehicleModel(CrateVehicle[VehFound][cvSpawnID]) != 592 && GetVehicleModel(CrateVehicle[VehFound][cvSpawnID]) != 553 && IsAPlane(CrateVehicle[VehFound][cvSpawnID])) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the cat thung hang vao xe nay!");
			if(!IsAPlane(CrateVehicle[VehFound][cvSpawnID])) {
				if((boot == VEHICLE_PARAMS_OFF || boot == VEHICLE_PARAMS_UNSET)) return SendClientMessageEx(playerid, COLOR_GRAD3, "Phai mo cop de tai thung hang! - Dung '/car trunk' de mo.");
			}
			CrateBox[boxid][cbInVeh] = VehFound;
			CrateBox[boxid][cbOnVeh] = -1;
			CrateBox[boxid][cbTransfer] = 0;
			CrateVehicle[IsDynamicCrateVehicle(inveh)][cvCrate] = -1;
			SaveCrateVehicle(IsDynamicCrateVehicle(inveh));
			SaveCrate(boxid);
			CrateVehCheck(IsDynamicCrateVehicle(inveh));
			UpdateCrateBox(boxid);
			Streamer_Update(playerid);
			format(szMiscArray, sizeof(szMiscArray), "* %s da cat thung hang vao %s.", GetPlayerNameEx(playerid), GetVehicleName(CrateVehicle[VehFound][cvSpawnID]));
			ProxDetector(25.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
		else if((boxid = CarryCrate[playerid]) != -1) { // Player -> Vehicle
			if(IsAPlane(CrateVehicle[VehFound][cvSpawnID])) return SendClientMessageEx(playerid, COLOR_GRAD2, "Can xe nang de tai thung len may bay!");
			if((boot == VEHICLE_PARAMS_OFF || boot == VEHICLE_PARAMS_UNSET)) return SendClientMessageEx(playerid, COLOR_GRAD3, "Phai mo cop de tai thung hang! - Dung '/car trunk' de mo.");
			ApplyAnimation(playerid, "CARRY", "putdwn105", 4.1, false, false, false, false, 0, 1);
			QueueCrateMove(playerid, boxid, VehFound, 3, 700);
		}
		else SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong mang thung nao de cat!");
		return 1;
	}
	else if(strcmp(choice, "take", true) == 0) {
		szMiscArray[0] = 0;
		new Float:vPos[3], inveh = GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet ,boot, objective, VehFound = -1;
		
		for(new i = 0; i < MAX_CRATE_VEHCILES; i++) {
			if(IsValidVehicle(CrateVehicle[i][cvSpawnID]) && GetPlayerVirtualWorld(playerid) == GetVehicleVirtualWorld(CrateVehicle[i][cvSpawnID]) && GetPlayerInterior(playerid) == CrateVehicle[i][cvInt]) {
				GetPosBehindVehicle(CrateVehicle[i][cvSpawnID], vPos[0], vPos[1], vPos[2], (IsAPlane(CrateVehicle[i][cvSpawnID]) ? -8 : 0));
				if(IsPlayerInRangeOfPoint(playerid, (IsAPlane(CrateVehicle[i][cvSpawnID]) ? 6 : 2), vPos[0], vPos[1], vPos[2])) {
					if(CrateVehicle[i][cvSpawnID] != inveh) {
						VehFound = i; // Do not use the vehicle ID as we store the array ID for the validation since vehicles do not store "spawn id".
						break;
					}
				}
			}
		}
		if(VehFound == -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o gan xe van chuyen thung hang!");
		if(!CreateCount(VehFound)) return SendClientMessageEx(playerid, COLOR_GRAD3, "Khong con thung hang trong xe de lay!");
		if(VehDelivering[VehFound]) return SendClientMessageEx(playerid, COLOR_GRAD3, "Xe dang do thung hang, vui long cho!");
		GetVehicleParamsEx(CrateVehicle[VehFound][cvSpawnID], engine, lights, alarm, doors, bonnet, boot, objective);
		if(inveh > 0 && GetVehicleModel(inveh) == 530 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) { // Vehicle -> Forklift
			if(IsDynamicCrateVehicle(inveh) == -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o tren xe nang chi dinh de do thung!");
			if(CrateVehicle[IsDynamicCrateVehicle(inveh)][cvCrate] != -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Xe nang da co thung hang!");
			if(!IsAPlane(CrateVehicle[VehFound][cvSpawnID])) {
				if((boot == VEHICLE_PARAMS_OFF || boot == VEHICLE_PARAMS_UNSET)) return SendClientMessageEx(playerid, COLOR_GRAD3, "Phai mo cop de do thung hang! - Dung '/car trunk' de mo.");
			}
			for(new b = 0; b < MAX_CRATES; b++) {
				if(CrateBox[b][cbActive] && CrateBox[b][cbInVeh] == VehFound) {
					CrateBox[b][cbInVeh] = -1;
					CrateBox[b][cbOnVeh] = IsDynamicCrateVehicle(inveh);
					CrateVehicle[IsDynamicCrateVehicle(inveh)][cvCrate] = b;
					SaveCrateVehicle(IsDynamicCrateVehicle(inveh));
					SaveCrate(b);
					CrateVehCheck(IsDynamicCrateVehicle(inveh));
					UpdateCrateBox(b);
					Streamer_Update(playerid);
					format(szMiscArray, sizeof(szMiscArray), "* %s da do thung hang khoi %s.", GetPlayerNameEx(playerid), GetVehicleName(CrateVehicle[VehFound][cvSpawnID]));
					ProxDetector(25.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					break;
				}
			}
		}
		else if(CarryCrate[playerid] == -1) { // Player -> Vehicle
			if(IsAPlane(CrateVehicle[VehFound][cvSpawnID])) return SendClientMessageEx(playerid, COLOR_GRAD2, "Can xe nang de do thung khoi may bay!");
			if((boot == VEHICLE_PARAMS_OFF || boot == VEHICLE_PARAMS_UNSET)) return SendClientMessageEx(playerid, COLOR_GRAD3, "Phai mo cop de do thung hang! - Dung '/car trunk' de mo.");
			for(new b = 0; b < MAX_CRATES; b++) {
				if(CrateBox[b][cbActive] && CrateBox[b][cbInVeh] == VehFound) {
					ApplyAnimation(playerid, "CARRY", "liftup105", 4.1, false, false, false, false, 0, 1);
					QueueCrateMove(playerid, b, VehFound, 2, 700);
					break;
				}
			}
		}
		else SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da mang mot thung hang!");
		return 1;
	}
	else if(strcmp(choice, "drop", true) == 0) {
		new vehicleid = GetPlayerVehicleID(playerid), veh, boxid, area;
		FetchFacility(playerid, area, 50.0);
		if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban can o trong xe de lam vay!");
		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai lai xe nang.");
		if(GetVehicleModel(vehicleid) != 530) return SendClientMessageEx(playerid, COLOR_GRAD2, "Can xe nang de dat thung xuong!");
		if((veh = IsDynamicCrateVehicle(vehicleid)) == -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o tren xe chi dinh cho thao tac nay!");
		if((boxid = CrateVehicle[veh][cvCrate]) == -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Xe nang khong mang thung nao!");
		if(CrateBox[boxid][cbTransfer]) return SendClientMessageEx(playerid, COLOR_GRAD2, "Phai tai thung vao xe truoc khi dat xuong!");
		if(area != -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the do thung gan co so san xuat!");

	    new Float: vPos[3];
	    GetVehiclePos(vehicleid, vPos[0], vPos[1], vPos[2]);
	    GetXYInFrontOfPlayer(playerid, vPos[0], vPos[1], 2);
		CrateBox[boxid][cbOnVeh] = -1;
		CrateVehicle[veh][cvCrate] = -1;
		CrateBox[boxid][cbPos][0] = vPos[0];
		CrateBox[boxid][cbPos][1] = vPos[1];
		CrateBox[boxid][cbPos][2] = vPos[2]-0.8;
		CrateBox[boxid][cbInt] = GetPlayerInterior(playerid);
		CrateBox[boxid][cbVw] = GetPlayerVirtualWorld(playerid);
		CrateBox[boxid][cbPlacedBy] = GetPlayerNameEx(playerid);
		format(string, sizeof(string), "* %s da do thung hang khoi xe nang.", GetPlayerNameEx(playerid));
		ProxDetector(25.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		SaveCrateVehicle(veh);
		SaveCrate(boxid);
		CrateVehCheck(veh);
		UpdateCrateBox(boxid);
		Streamer_Update(playerid);
		return 1;
	}
	else if(strcmp(choice, "destroy", true) == 0 && PlayerInfo[playerid][pAdmin] > 3) {
		if(crate == -1) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /crate destroy [id]");
		if(0 <= crate < MAX_CRATES) {
			if(!CrateBox[crate][cbActive]) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the huy thung khong hoat dong!");
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da huy thung ID: %d", crate);
			DestroyCrate(crate);
		}
		else SendClientMessageEx(playerid, COLOR_YELLOW, "ID thung sai, khong duoc duoi 0 hoac tren %d.", MAX_CRATES-1);
		return 1;
	}
	else if(strcmp(choice, "spawn", true) == 0 && PlayerInfo[playerid][pAdmin] > 3) {
		if(crate == -1) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /crate spawn [id]"), SendClientMessageEx(playerid, COLOR_GREY, "CHU Y: ID phai la ID co so, khong phai ID thung!");
		if(0 <= crate < MAX_CRATE_FACILITY) {
			new Float: pcbPos[3];
			GetPlayerPos(playerid, pcbPos[0], pcbPos[1], pcbPos[2]);
			GetXYInFrontOfPlayer(playerid, pcbPos[0], pcbPos[1], 1);
			if(CrateFacility[crate][cfPos][0] != 0.0 && CrateFacility[crate][cfActive]) {
				if(CrateFacility[crate][cfProdReady] > 0) {
					for(new c = 0; c < MAX_CRATES; c++) {
						if(!CrateBox[c][cbActive] && CrateBox[c][cbFacility] == -1 && CrateBox[c][cbGroup] == -1) {
							CrateBox[c][cbLifespan] = 7200;
							CrateBox[c][cbFacility] = crate;
							CrateBox[c][cbGroup] = -1;
							CrateBox[c][cbTransfer] = 0;
							CrateBox[c][cbPrice] = 0;
							CrateBox[c][cbMats] = 50;
							CrateBox[c][cbActive] = 1;
							--CrateFacility[crate][cfProdReady];
							CrateBox[c][cbPos][0] = pcbPos[0];
							CrateBox[c][cbPos][1] = pcbPos[1];
							CrateBox[c][cbPos][2] = pcbPos[2]-1.0;
							CrateBox[c][cbInt] = GetPlayerInterior(playerid);
							CrateBox[c][cbVw] = GetPlayerVirtualWorld(playerid);
							CrateBox[c][cbPlacedBy] = GetPlayerNameEx(playerid);
							CrateBox[c][cbPaid] = 1;
							SaveCrate(c);
							SaveFacility(crate);
							UpdateCrateBox(c);
							Streamer_Update(playerid);
							SendClientMessageEx(playerid, COLOR_WHITE, "Da tao thung hang tai vi tri cua ban!");
							return 1;
						}
					}
					return SendClientMessageEx(playerid, COLOR_GRAD2, "LOI: Het cho trong de tao thung!");
				} else {
					SendClientMessageEx(playerid, COLOR_GRAD2, "Loi: Co so da chon van con thung kha dung!");
				}
			} else {
				SendClientMessageEx(playerid, COLOR_GRAD2, "Loi: Co so da chon chua duoc dung hoac khong hoat dong!");
			}
		}
		else SendClientMessageEx(playerid, COLOR_YELLOW, "ID co so sai, khong duoc duoi 0 hoac tren %d.", MAX_CRATE_FACILITY-1);
		return 1;
	}
	else if(strcmp(choice, "orders", true) == 0) {
		new fac;
		if(!ValidGroup(PlayerInfo[playerid][pMember])) return SendClientMessage(playerid, COLOR_GRAD2, "Ban phai thuoc mot to chuc de dung lenh nay!");
		GetFacility(PlayerInfo[playerid][pMember], fac);
		if(fac == -1) return SendClientMessage(playerid, COLOR_GRAD2, "To chuc khong so huu co so nao!");
		format(szMiscArray, sizeof(szMiscArray), "To chuc\tSo thung (Tong gia)\tDa giao (Thu nhap)\n");
		for(new o = 0; o < MAX_GROUPS; o++) {
			if(CrateOrder[o][coFacility] == fac && CrateOrder[o][coStatus] > 0) {
				format(szMiscArray, sizeof(szMiscArray), "%s%s\t%d ($%s)\t%d ($%s)\n", szMiscArray, arrGroupData[o][g_szGroupName], CrateOrder[o][coCrates], number_format((CrateOrder[o][coCrates] * CrateOrder[o][coPerCrate])), CrateOrder[o][coDelivered], number_format((CrateOrder[o][coDelivered] * CrateOrder[o][coPerCrate])));
			}
		}
		if(strlen(szMiscArray) == 51) return SendClientMessageEx(playerid, COLOR_LIGHTRED, "%s: Khong co don dat thung cho xu ly!", CrateFacility[fac][cfName]);
		Dialog_Show(playerid, -1, DIALOG_STYLE_TABLIST_HEADERS, "Don dat thung", szMiscArray, "Dong", "");
	}
	else if(strcmp(choice, "seize", true) == 0) {
		new fac;
		GetCrateBox(playerid, box, 2.0);
		GetFacility(PlayerInfo[playerid][pMember], fac);
		if(fac == -1) return SendClientMessage(playerid, COLOR_GRAD2, "To chuc khong so huu co so nao!");
		if(CrateFacilityRaid[fac]) return SendClientMessage(playerid, COLOR_GRAD2, "Loi: Khong the dung lenh nay trong dot kich.");
		if(box == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan thung de thu giu!");
		if(CrateBox[box][cbFacility] != fac) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the thu giu thung ngoai co so cua ban!");
		DestroyCrate(box);
		format(szMiscArray, sizeof(szMiscArray), "* %s thu giu thung hang!", GetPlayerNameEx(playerid));
		ProxDetector(25.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	}
	else SendClientMessageEx(playerid, COLOR_GRAD2, "Lua chon khong hop le!");
	return 1;
}

stock CreateCount(veh) {
	if(!(0 <= veh < MAX_CRATE_VEHCILES)) return 0;
	new amount = 0;
	for(new c = 0; c < MAX_CRATES; c++) {
		if(CrateBox[c][cbActive] && CrateBox[c][cbInVeh] == veh) {
			++amount;
		}
	}
	return amount;
}

CMD:cfnext(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] > 3 || PlayerInfo[playerid][pASM] > 0 || PlayerInfo[playerid][pFactionModerator] > 0) {
		for(new f = 0; f < MAX_CRATE_FACILITY; f++) {
			if(CrateFacility[f][cfPos][0] == 0.0) {
				SendClientMessageEx(playerid, COLOR_YELLOW, "Co so thung hang trong tiep theo: %d", f);
				break;
			}
		}
	}
	return 1;
}

CMD:gotocrate(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] > 3 || PlayerInfo[playerid][pASM] > 0 || PlayerInfo[playerid][pFactionModerator] > 0) {
		new id, Float:pos[3];
		if(sscanf(params, "i", id)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /gotocrate [id]");
		if(!(0 <= id < MAX_CRATES)) return SendClientMessageEx(playerid, COLOR_GREY, "ID thung sai. (0 - %d)", MAX_CRATES-1);
		if(!CrateBox[id][cbActive]) return SendClientMessageEx(playerid, COLOR_GREY, "LOI: Thung khong hoat dong.");
		/*
		foreach(new i: Player) {
			if(CarryCrate[i] == id) {
				GetPlayerPos(i, pos[0], pos[1], pos[2]);
				SetPlayerPos(playerid, pos[0], pos[1], pos[2]+1.0);
				SetPlayerInterior(playerid, GetPlayerInterior(i));
				PlayerInfo[playerid][pInt] = GetPlayerInterior(i);
				SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(i));
				PlayerInfo[playerid][pVW] = GetPlayerVirtualWorld(i);
				if(GetPlayerInterior(i) > 0) Player_StreamPrep(playerid, pos[0], pos[1], pos[2]+1.0, FREEZE_TIME);
				SendClientMessageEx(playerid, COLOR_WHITE, "You have teleported to crate %d.", id);
				return 1;
			}
		}*/
		if(BeingMoved[id] != INVALID_PLAYER_ID) {
			GetPlayerPos(BeingMoved[id], pos[0], pos[1], pos[2]);
			SetPlayerPos(playerid, pos[0], pos[1], pos[2]+1.0);
			SetPlayerInterior(playerid, GetPlayerInterior(BeingMoved[id]));
			PlayerInfo[playerid][pInt] = GetPlayerInterior(BeingMoved[id]);
			SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(BeingMoved[id]));
			PlayerInfo[playerid][pVW] = GetPlayerVirtualWorld(BeingMoved[id]);
			if(GetPlayerInterior(BeingMoved[id]) > 0) Player_StreamPrep(playerid, pos[0], pos[1], pos[2]+1.0, FREEZE_TIME);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da den thung %d. (Dang duoc %s mang)", id, GetPlayerNameEx(BeingMoved[id]));
			return 1;
		}
		if(CrateBox[id][cbInVeh] != -1) {
			GetVehiclePos(CrateVehicle[CrateBox[id][cbInVeh]][cvSpawnID], pos[0], pos[1], pos[2]);
			SetPlayerPos(playerid, pos[0], pos[1], pos[2]+1.0);
			SetPlayerInterior(playerid, CrateVehicle[CrateBox[id][cbInVeh]][cvInt]);
			PlayerInfo[playerid][pInt] =CrateVehicle[CrateBox[id][cbInVeh]][cvInt];
			SetPlayerVirtualWorld(playerid, CrateVehicle[CrateBox[id][cbInVeh]][cvVw]);
			PlayerInfo[playerid][pVW] = CrateVehicle[CrateBox[id][cbInVeh]][cvVw];	
			if(CrateVehicle[CrateBox[id][cbInVeh]][cvInt] > 0) Player_StreamPrep(playerid, pos[0], pos[1], pos[2]+1.0, FREEZE_TIME);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da dich chuyen den thung %d.", id);
			return 1;
		}
		if(CrateBox[id][cbOnVeh] != -1) {
			GetVehiclePos(CrateVehicle[CrateBox[id][cbOnVeh]][cvSpawnID], pos[0], pos[1], pos[2]);
			SetPlayerPos(playerid, pos[0], pos[1], pos[2]+1.0);
			SetPlayerInterior(playerid, CrateVehicle[CrateBox[id][cbOnVeh]][cvInt]);
			PlayerInfo[playerid][pInt] =CrateVehicle[CrateBox[id][cbOnVeh]][cvInt];
			SetPlayerVirtualWorld(playerid, CrateVehicle[id][cvVw]);
			PlayerInfo[playerid][pVW] = CrateVehicle[CrateBox[id][cbOnVeh]][cvVw];	
			if(CrateVehicle[CrateBox[id][cbOnVeh]][cvInt] > 0) Player_StreamPrep(playerid, pos[0], pos[1], pos[2]+1.0, FREEZE_TIME);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da dich chuyen den thung %d.", id);
			return 1;
		}
		SetPlayerPos(playerid, CrateBox[id][cbPos][0], CrateBox[id][cbPos][1], CrateBox[id][cbPos][2]+1.0);
		SetPlayerInterior(playerid, CrateBox[id][cbInt]);
		PlayerInfo[playerid][pInt] = CrateBox[id][cbInt];
		SetPlayerVirtualWorld(playerid, CrateBox[id][cbVw]);
		PlayerInfo[playerid][pVW] = CrateBox[id][cbVw];	
		if(CrateBox[id][cbInt] > 0) Player_StreamPrep(playerid, CrateBox[id][cbPos][0], CrateBox[id][cbPos][1], CrateBox[id][cbPos][2]+1.0, FREEZE_TIME);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da dich chuyen den thung %d.", id);
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay!");
	return 1;
}

CMD:cfname(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] > 3 || PlayerInfo[playerid][pASM] > 0 || PlayerInfo[playerid][pFactionModerator] > 0) {
		new id, name[50];
		if(sscanf(params, "is[50]", id, name)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /cfname [facility] [name]");
		if(!(0 <= id < MAX_CRATE_FACILITY)) return SendClientMessageEx(playerid, COLOR_GREY, "ID co so khong hop le.");
		foreach(new p : Player) {
			if(CrateAction[p][caTimer] && CrateAction[p][caFacility] == id) {
				CancelCrateAction(p);
			}
		}
		if(!(0 < strlen(name) < 50)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ten phai dai tu 1 - 50 ky tu!");
		format(szMiscArray, sizeof(szMiscArray), "%s has set %d facility name from %s to %s.", GetPlayerNameEx(playerid), id, CrateFacility[id][cfName], name);
		strcpy(CrateFacility[id][cfName], name, 50);
		Log("logs/cfedit.log", szMiscArray);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da dat ten co so thanh %s.", name);
		SaveFacility(id);
		UpdateFacility(id);
	}
	else SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay!");
	return 1;
}

CMD:cfedit(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] > 3 || PlayerInfo[playerid][pASM] > 0 || PlayerInfo[playerid][pFactionModerator] > 0) {
		new id, name[32], value;
		if(sscanf(params, "s[32]iD(-1)", name, id, value)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /cfedit [name] [id] [value]");
			SendClientMessageEx(playerid, COLOR_GREY, "Ten: pos, crates, timer, prodstatus, cost, active");
			SendClientMessageEx(playerid, COLOR_GREY, "Ten: owner, raidable, multiplier, delete");
			return 1;
		}
		if(!(0 <= id < MAX_CRATE_FACILITY)) return SendClientMessageEx(playerid, COLOR_GREY, "ID co so khong hop le.");
		if(strcmp(name, "pos", true) == 0) {
			new Float:pos[3];
			GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
			format(szMiscArray, sizeof(szMiscArray), "%s has moved %d crate facility (B: %f, %f, %f Int: %d, VW: %d | A: %f, %f, %f Int: %d, VW: %d)", GetPlayerNameEx(playerid), id, CrateFacility[id][cfPos][0], CrateFacility[id][cfPos][1], CrateFacility[id][cfPos][2], CrateFacility[id][cfInt], CrateFacility[id][cfVw], pos[0], pos[1], pos[2], GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid));
			Log("logs/cfedit.log", szMiscArray);
			CrateFacility[id][cfPos][0] = pos[0];
			CrateFacility[id][cfPos][1] = pos[1];
			CrateFacility[id][cfPos][2] = pos[2]-1.0;
			CrateFacility[id][cfInt] = GetPlayerInterior(playerid);
			CrateFacility[id][cfVw] = GetPlayerVirtualWorld(playerid);
			if(CrateFacility[id][cfCooldown] == 0) {
				CrateFacility[id][cfCooldown] = gettime()+10800;
			}
			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi vi tri co so %d den cho ban!", id);
			SaveFacility(id);
			UpdateFacility(id);
			return 1;
		}
		else if(strcmp(name, "crates", true) == 0) {
			if(value < 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "San luong toi da khong duoc duoi 1!");
			if(value > GetMaxProduction() + CrateFacility[id][cfProdMax]) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the dat san luong %d vi chi con %d cho trong!", id, GetMaxProduction());
			format(szMiscArray, sizeof(szMiscArray), "%s has set %d facility max production from %d to %d.", GetPlayerNameEx(playerid), id, CrateFacility[id][cfProdMax], value);
			Log("logs/cfedit.log", szMiscArray);
			CrateFacility[id][cfProdMax] = value;
			if(CrateFacility[id][cfProdReady] > CrateFacility[id][cfProdMax]) {
				CrateFacility[id][cfProdReady] = value;
			}
			UpdateFacility(id);
			SaveFacility(id);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da dat san luong toi da co so %d thanh %d", id, value);
			return 1;
		}
		else if(strcmp(name, "timer", true) == 0) {
			if(value == -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Nhap so giay can de tao mot thung hang.");
			if(value < 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Thoi gian san xuat toi da khong duoc duoi 1!");
			format(szMiscArray, sizeof(szMiscArray), "%s has set %d facility production timer from %d to %d seconds.", GetPlayerNameEx(playerid), id, CrateFacility[id][cfProdTimer], value);
			Log("logs/cfedit.log", szMiscArray);
			CrateFacility[id][cfProdTimer] = value;
			SaveFacility(id);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da dat thoi gian san xuat co so %d thanh %d giay.", id, value);
			return 1;
		}
		else if(strcmp(name, "prodstatus", true) == 0) {
			if(value == -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "0 - Tat | 1 - Bat");
			if(!(0 <= value < 2)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Chi duoc chon: 0 - Tat | 1 - Bat");
			format(szMiscArray, sizeof(szMiscArray), "%s has set %d facility production status from %s to %s.", GetPlayerNameEx(playerid), id, (CrateFacility[id][cfProdStatus]) ? ("Active") : ("Paused"), (value) ? ("Active") : ("Disabled"));
			Log("logs/cfedit.log", szMiscArray);
			CrateFacility[id][cfProdStatus] = value;
			SaveFacility(id);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da dat san xuat co so %d thanh %s.", id, (value) ? ("Bat") : ("Tam dung"));
			return 1;
		}
		else if(strcmp(name, "cost", true) == 0) {
			if(value < 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Gia thung khong duoc duoi 0!");
			format(szMiscArray, sizeof(szMiscArray), "%s has set %d facility production cost per crate from $%s to $%s.", GetPlayerNameEx(playerid), id, number_format(CrateFacility[id][cfProdCost]), number_format(value));
			Log("logs/cfedit.log", szMiscArray);
			CrateFacility[id][cfProdCost] = value;
			SaveFacility(id);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da dat gia co so %d thanh $%s moi thung.", id, number_format(value));
			return 1;
		}
		else if(strcmp(name, "active", true) == 0) {
			if(value == -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "0 - Tat | 1 - Bat");
			if(!(0 <= value < 2)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Chi duoc chon: 0 - Tat | 1 - Bat");
			format(szMiscArray, sizeof(szMiscArray), "%s has set %d facility status from %s to %s.", GetPlayerNameEx(playerid), id, (CrateFacility[id][cfActive]) ? ("Active") : ("Disabled"), (value) ? ("Active") : ("Disabled"));
			Log("logs/cfedit.log", szMiscArray);
			CrateFacility[id][cfActive] = value;
			SaveFacility(id);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da dat trang thai co so %d thanh %s.", id, (value) ? ("Bat") : ("Tat"));
			return 1;
		}
		else if(strcmp(name, "cooldown", true) == 0) {
			if(CrateFacility[id][cfRaidTimer] != 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "LOI: Dang co dot kich, thu lai sau %s.", date(CrateFacility[id][cfRaidTimer], 1));
			if(value < 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Thoi gian cho khong duoc duoi 1 giay!");
			CrateFacility[id][cfCooldown] = gettime()+value;
			SaveFacility(id);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da dat thoi gian cho co so %d thanh %d.", id, value);
			return 1;
		}
		else if(strcmp(name, "raid", true) == 0) {
			if(CrateFacility[id][cfRaidTimer] == 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong co dot kich nao.");
			if(value < 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Thoi gian dot kich khong duoc duoi 1 giay!");
			CrateFacility[id][cfRaidTimer] = gettime()+value;
			SaveFacility(id);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da dat thoi gian dot kich co so %d thanh %d.", id, value);
			return 1;
		}
		else if(strcmp(name, "multiplier", true) == 0) {
			if(value < 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "He so thung hang khong duoc duoi 1!");
			format(szMiscArray, sizeof(szMiscArray), "%s has set %d facility crate delivery multiplier from %d to %d.", GetPlayerNameEx(playerid), id, CrateFacility[id][cfProdMulti], value);
			Log("logs/cfedit.log", szMiscArray);
			CrateFacility[id][cfProdMulti] = value;
			SaveFacility(id);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da dat he so giao hang co so %d thanh %d.", id, value);
			return 1;
		}
		else if(strcmp(name, "raidable", true) == 0) {
			if(!(0 <= value < 2)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Chi duoc chon: 0 - Tat | 1 - Bat");
			if(CrateFacility[id][cfRaidTimer] != 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "LOI: Dang co dot kich, thu lai sau %s.", date(CrateFacility[id][cfRaidTimer], 1));
			if(value && !CrateFacility[id][cfRaidable]) CrateFacility[id][cfCooldown] = gettime()+10800;
			format(szMiscArray, sizeof(szMiscArray), "%s has set %d facility raidable status from %s to %s.", GetPlayerNameEx(playerid), id, (CrateFacility[id][cfRaidable]) ? ("Active") : ("Disabled"), (value) ? ("Active") : ("Disabled"));
			Log("logs/cfedit.log", szMiscArray);
			CrateFacility[id][cfRaidable] = value;
			SaveFacility(id);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da dat cho phep dot kich co so %d thanh %s.", id, (value) ? ("Bat") : ("Tat"));
			return 1;
		}
		else if(strcmp(name, "owner", true) == 0) {
			new fac;
			GetFacility(value, fac);
			if(value == -1) {
				if(CrateFacility[id][cfGroup] == -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Chua co to chuc duoc gan cho co so!");
				format(szMiscArray, sizeof(szMiscArray), "%s has removed %s's ownership over %s facility (ID: %d).", GetPlayerNameEx(playerid), arrGroupData[CrateFacility[id][cfGroup]][g_szGroupName], CrateFacility[id][cfName], id);
				Log("logs/cfedit.log", szMiscArray);
				SendClientMessageEx(playerid, COLOR_YELLOW, "Da go quyen so huu cua %s tai co so %s (ID: %d).", arrGroupData[CrateFacility[id][cfGroup]][g_szGroupName], CrateFacility[id][cfName], id);
				if(!DeleteOrder(id, "The crate facility ownership was removed.")) return SendClientMessageEx(playerid, COLOR_RED, "Khong the quyet toan don dat thung con lai.");
				CrateFacility[id][cfGroup] = -1;
			} else {
				if(!(0 <= value < MAX_GROUPS)) return SendClientMessageEx(playerid, COLOR_GRAD2, "ID to chuc sai. (0 - %d)", MAX_GROUPS);
				if(CrateFacility[id][cfPos][0] == 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the gan to chuc cho co so %d vi chua duoc dung.", id);
				if(fac != -1) {
					format(szMiscArray, sizeof(szMiscArray), "%s was removed from %s facility (ID: %d) to prevent duplicate ownership.", arrGroupData[CrateFacility[fac][cfGroup]][g_szGroupName], CrateFacility[fac][cfName], fac);
					Log("logs/cfedit.log", szMiscArray);
					SendClientMessageEx(playerid, COLOR_YELLOW, "Da go quyen cua %s tai co so %s (ID: %d) vi chi duoc so huu 1 co so!", arrGroupData[CrateFacility[fac][cfGroup]][g_szGroupName], CrateFacility[fac][cfName], fac);
					if(!DeleteOrder(fac, "The crate facility ownership was removed.")) return SendClientMessageEx(playerid, COLOR_RED, "Khong the quyet toan don dat thung con lai.");
					CrateFacility[fac][cfGroup] = -1;
					SaveFacility(fac);
				}
				if(CrateFacility[id][cfGroup] != value && !DeleteOrder(id, "Crate facility ownership has changed.")) return SendClientMessageEx(playerid, COLOR_RED, "Khong the quyet toan don dat thung con lai.");
				CrateFacility[id][cfGroup] = value;
				format(szMiscArray, sizeof(szMiscArray), "%s has assigned %s's ownership over %s facility (ID: %d).", GetPlayerNameEx(playerid), arrGroupData[value][g_szGroupName], CrateFacility[id][cfName], id);
				Log("logs/cfedit.log", szMiscArray);
				SendClientMessageEx(playerid, COLOR_YELLOW, "Da gan quyen so huu cua %s tai co so %s (ID: %d).", arrGroupData[value][g_szGroupName], CrateFacility[id][cfName], id);
			}
			SaveFacility(id);
			return 1;
		}
		else if(strcmp(name, "delete", true) == 0) {
			if(CrateFacility[id][cfPos][0] == 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the xoa co so khong hoat dong!");
			if(!DeleteOrder(id, "Crate facility has been deleted.")) return SendClientMessageEx(playerid, COLOR_RED, "Khong the quyet toan don dat thung con lai.");
			for(new c = 0; c < MAX_CRATES; c++) {
				if(CrateBox[c][cbFacility] == id) {
					DestroyCrate(c);
				}
			}
			for(new g = 0; g < MAX_GATES; g++) {
				if(GateInfo[g][gFacility] == id) {
					GateInfo[g][gFacility] = -1;
					CreateGate(g);
					SaveGate(g);
				}
			}
			AdminOpened[id] = 0; // Disable by default.
			CrateBeingProcessed[id] = 0;
			format(CrateFacility[id][cfName], 4, "----");
			CrateFacility[id][cfGroup] = -1;
			CrateFacility[id][cfPos][0] = 0.00000;
			CrateFacility[id][cfPos][1] = 0.00000;
			CrateFacility[id][cfPos][2] = 0.00000;
			CrateFacility[id][cfPos][3] = 0.00000;
			CrateFacility[id][cfInt] = 0;
			CrateFacility[id][cfVw] = 0;
			CrateFacility[id][cfProdMax] = 0;
			CrateFacility[id][cfProdPrep] = 0;
			CrateFacility[id][cfProdReady] = 0;
			CrateFacility[id][cfProdTimer] = 0;
			CrateFacility[id][cfProdStatus] = 0;
			CrateFacility[id][cfProdCost] = 0;
			CrateFacility[id][cfProdMulti] = 1;
			CrateFacility[id][cfRaidTimer] = 0;
			CrateFacility[id][cfCooldown] = 0;
			CrateFacility[id][cfRaidable] = 1;
			CrateFacility[id][cfActive] = 0;
			CrateFacility[id][cfTimer] = 0;
			CrateFacilityRaid[id] = 0;
			UpdateFacility(id);
			SaveFacility(id);
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da xoa co so thung hang %d", id);
			format(szMiscArray, sizeof(szMiscArray), "%s has deleted facility id %d.", GetPlayerNameEx(playerid), id);
			Log("logs/cfedit.log", szMiscArray);
			return 1;
		}
		else SendClientMessageEx(playerid, COLOR_GREY, "Ten khong hop le.");
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay!");
	return 1;
}

stock DeleteOrder(facility, const reason[]) {
	new displayReason[64];
	if(!strcmp(reason, "The crate facility ownership was removed.")) displayReason = "Da go quyen so huu co so thung hang.";
	else if(!strcmp(reason, "Crate facility ownership has changed.")) displayReason = "Quyen so huu co so da thay doi.";
	else if(!strcmp(reason, "Crate facility has been deleted.")) displayReason = "Da xoa co so thung hang.";
	else format(displayReason, sizeof displayReason, "%s", reason);
	if(!(0 <= facility < MAX_CRATE_FACILITY)) return 0;
	foreach(new playerid : Player) {
		if(CrateAction[playerid][caTimer] && CrateAction[playerid][caFacility] == facility) CancelCrateAction(playerid);
	}
	szMiscArray[0] = 0;
	for(new g = 0; g < MAX_GROUPS; g++) {
		if(CrateOrder[g][coFacility] == facility) {
			if(!CrateOrder[g][coStatus]) {
				ResetOrder(g);
				continue;
			}
			if(!(1 <= CrateOrder[g][coCrates] <= 50) || !(0 <= CrateOrder[g][coDelivered] <= CrateOrder[g][coCrates]) || CrateOrder[g][coPerCrate] < 1 || CrateOrder[g][coPerCrate] > cellmax / CrateOrder[g][coCrates]) return 0;
			new refund = ((CrateOrder[g][coCrates] - CrateOrder[g][coDelivered]) * CrateOrder[g][coPerCrate]);
			new payee = CrateFacility[facility][cfGroup], earnings = CrateOrder[g][coDelivered] * CrateOrder[g][coPerCrate];
			if(payee == g) payee = arrGroupData[g][g_iAllegiance] == 2 ? 8 : 5;
			if(!ValidGroup(payee) || GetGroupBudget(g) > cellmax - refund || GetGroupBudget(payee) > cellmax - earnings) return 0;
			if(payee == g && GetGroupBudget(g) > cellmax - refund - earnings) return 0;
			foreach(new p: Player) {
				if(PlayerInfo[p][pMember] == CrateFacility[CrateOrder[g][coFacility]][cfGroup]) {
					SendClientMessageEx(p, COLOR_LIGHTRED, "Don cua %s tu huy, %d/%d thung da giao, thu: $%s.", arrGroupData[g][g_szGroupName], CrateOrder[g][coDelivered], CrateOrder[g][coCrates], number_format(CrateOrder[g][coDelivered] * CrateOrder[g][coPerCrate]));
					SendClientMessageEx(p, COLOR_LIGHTRED, "Ly do: %s", displayReason);
				}
				if(PlayerInfo[p][pLeader] == g) {
					SendClientMessageEx(p, COLOR_LIGHTRED, "* Don tu huy, %d/%d thung da giao, gia: $%s", CrateOrder[g][coDelivered], CrateOrder[g][coCrates], number_format(CrateOrder[g][coDelivered] * CrateOrder[g][coPerCrate]));
					SendClientMessageEx(p, COLOR_LIGHTRED, "* Da hoan $%s vao quy cho so thung chua giao.", number_format(refund));
					SendClientMessageEx(p, COLOR_LIGHTRED, "* Ly do: %s", displayReason);
				}
			}
			format(szMiscArray, sizeof(szMiscArray), "Your crate order was auto canceled, %d/%d crates were delivered costing: $%s ($%s was refunded)", CrateOrder[g][coDelivered], CrateOrder[g][coCrates], number_format(CrateOrder[g][coDelivered] * CrateOrder[g][coPerCrate]), number_format(refund));
			format(szMiscArray, sizeof(szMiscArray), "%sReason: %s", szMiscArray, reason);
			GroupPayLog(g, szMiscArray);
			SetGroupBudget(g, refund);
			format(szMiscArray, sizeof(szMiscArray), "%s order was auto canceled, %d/%d crates were delivered adding: $%s.", arrGroupData[g][g_szGroupName], CrateOrder[g][coDelivered], CrateOrder[g][coCrates], number_format(CrateOrder[g][coDelivered] * CrateOrder[g][coPerCrate]), number_format(refund));
			format(szMiscArray, sizeof(szMiscArray), "%sReason: %s", szMiscArray, reason);
			GroupPayLog(payee, szMiscArray);
			SetGroupBudget(payee, earnings);
			SaveGroup(payee);
			ResetOrder(g);
			SaveGroup(g);
		}
	}
	return 1;
}

stock GetMaxProduction() {
	new total = 0;
	for(new f = 0; f < MAX_CRATE_FACILITY; f++) {
		total += CrateFacility[f][cfProdMax];
	}
	return (MAX_CRATES - total);
}

CMD:ordercrates(playerid, params[]) {
	new group = PlayerInfo[playerid][pMember];
	if(ValidGroup(group)) {
		if(!IsGroupLeader(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban phai la lanh dao to chuc de dat thung!");
		if(IsACriminal(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the dat thung tu bat ky co so nao.");
		//if(CrateOrder[group][coFacility] != -1 && CrateOrder[group][coStatus] > 1 && CrateOrder[group][coTime] > gettime()) return SendClientMessageEx(playerid, COLOR_GRAD2, "Your order is currently being processed, You can cancel it after %s", date(CrateOrder[group][coTime], 1));
		if(!CrateOrder[group][coStatus]) {
			PrepOrder(playerid, group);
		} else {
			CancelOrder(playerid);
		}
	}
	else SendClientMessageEx(playerid, COLOR_GRAD2, "Ban phai thuoc to chuc de dung lenh nay!");
	return 1;
}

stock CancelOrder(playerid) {
	szMiscArray[0] = 0;
	if(!IsGroupLeader(playerid)) return 1;
	new group = PlayerInfo[playerid][pMember];
	if(!ValidGroup(group) || !(0 <= CrateOrder[group][coFacility] < MAX_CRATE_FACILITY)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Don dat thung khong co co so hop le.");
	
	if(!(1 <= CrateOrder[group][coCrates] <= 50) || !(0 <= CrateOrder[group][coDelivered] <= CrateOrder[group][coCrates]) || CrateOrder[group][coPerCrate] < 1 || CrateOrder[group][coPerCrate] > cellmax / CrateOrder[group][coCrates]) 
	{
		return 0;
	}

	new refund = ((CrateOrder[group][coCrates] - CrateOrder[group][coDelivered]) * CrateOrder[group][coPerCrate]);
	format(szMiscArray, sizeof(szMiscArray), "Ban chac muon huy don da dat tai %s?\n", CrateFacility[CrateOrder[group][coFacility]][cfName]);
	format(szMiscArray, sizeof(szMiscArray), "%sXem thong tin giao dich ben duoi:\n\n", szMiscArray);
	format(szMiscArray, sizeof(szMiscArray), "%sThung da dat: %d\nTong gia: $%s\nThung da giao: %d\nDa chi: $%s\nNguoi dat: %s\nHoan tra: $%s.\n\n", szMiscArray, CrateOrder[group][coCrates], number_format((CrateOrder[group][coCrates] * CrateOrder[group][coPerCrate])), CrateOrder[group][coDelivered], number_format((CrateOrder[group][coDelivered] * CrateOrder[group][coPerCrate])), CrateOrder[group][coOrderBy], number_format(refund));
	format(szMiscArray, sizeof(szMiscArray), "%sNhan 'Xac nhan' de huy giao so thung con lai.", szMiscArray, number_format(refund));
	return Dialog_Show(playerid, order_refund, DIALOG_STYLE_MSGBOX, "Huy don?", szMiscArray, "Xac nhan", "Thoat");
}

Dialog:order_refund(playerid, response, listitem, inputtext[]) {
	if(!IsGroupLeader(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban phai la lanh dao to chuc de dat thung!");
	new group = PlayerInfo[playerid][pMember];
	if(response) {
		if(!ValidGroup(group) || !(0 <= CrateOrder[group][coFacility] < MAX_CRATE_FACILITY)) return 1;
		if(!CrateOrder[group][coStatus]) return SendClientMessageEx(playerid, COLOR_RED, "LOI: Ban khong co don dat thung nao cho xu ly!");
		if(!(1 <= CrateOrder[group][coCrates] <= 50) || !(0 <= CrateOrder[group][coDelivered] <= CrateOrder[group][coCrates]) || CrateOrder[group][coPerCrate] < 1 || CrateOrder[group][coPerCrate] > cellmax / CrateOrder[group][coCrates]) return 0;
		new refund = ((CrateOrder[group][coCrates] - CrateOrder[group][coDelivered]) * CrateOrder[group][coPerCrate]), type = (arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance] == 2) ? 8 : 5;
		new payee = CrateFacility[CrateOrder[group][coFacility]][cfGroup], earnings = CrateOrder[group][coDelivered] * CrateOrder[group][coPerCrate];
		if(payee == group) payee = type;
		if(!ValidGroup(payee) || GetGroupBudget(group) > cellmax - refund || GetGroupBudget(payee) > cellmax - earnings) return SendClientMessageEx(playerid, COLOR_RED, "So du to chuc khong the quyet toan khoan nay.");
		if(payee == group && GetGroupBudget(group) > cellmax - refund - earnings) return SendClientMessageEx(playerid, COLOR_RED, "Ngan sach to chuc khong the quyet toan khoan nay.");
		if(CrateFacility[CrateOrder[group][coFacility]][cfGroup] == PlayerInfo[playerid][pMember]) {
			foreach(new p: Player) {
				if(PlayerInfo[p][pMember] == type) {
					SendClientMessageEx(p, COLOR_LIGHTRED, "Don cua %s da huy, %d/%d thung da giao, thu: $%s.", arrGroupData[group][g_szGroupName], CrateOrder[group][coDelivered], CrateOrder[group][coCrates], number_format(CrateOrder[group][coDelivered] * CrateOrder[group][coPerCrate]));
				}
				if(PlayerInfo[p][pLeader] == group) {
					SendClientMessageEx(p, COLOR_LIGHTRED, "* %s %s da huy don, %d/%d thung da giao, gia: $%s", arrGroupRanks[group][PlayerInfo[playerid][pRank]], GetPlayerNameEx(playerid), CrateOrder[group][coDelivered], CrateOrder[group][coCrates], number_format(CrateOrder[group][coDelivered] * CrateOrder[group][coPerCrate]));
					SendClientMessageEx(p, COLOR_LIGHTRED, "* Da hoan $%s vao quy cho so thung chua giao.", number_format(refund));
				}
			}
			format(szMiscArray, sizeof(szMiscArray), "%s %s has canceled the crate order, %d/%d crates were delivered costing: $%s ($%s was refunded)", arrGroupRanks[group][PlayerInfo[playerid][pRank]], GetPlayerNameEx(playerid), CrateOrder[group][coDelivered], CrateOrder[group][coCrates], number_format(CrateOrder[group][coDelivered] * CrateOrder[group][coPerCrate]), number_format(refund));
			GroupPayLog(group, szMiscArray);
			SetGroupBudget(group, refund);
			format(szMiscArray, sizeof(szMiscArray), "%s has canceled their crate order, %d/%d crates were delivered adding: $%s.", arrGroupData[group][g_szGroupName], CrateOrder[group][coDelivered], CrateOrder[group][coCrates], number_format(CrateOrder[group][coDelivered] * CrateOrder[group][coPerCrate]), number_format(refund));
			GroupPayLog(type, szMiscArray);
			SetGroupBudget(type, (CrateOrder[group][coDelivered] * CrateOrder[group][coPerCrate]));
		} else {
			foreach(new p: Player) {
				if(PlayerInfo[p][pMember] == CrateFacility[CrateOrder[group][coFacility]][cfGroup]) {
					SendClientMessageEx(p, COLOR_LIGHTRED, "Don cua %s da huy, %d/%d thung da giao, thu: $%s.", arrGroupData[group][g_szGroupName], CrateOrder[group][coDelivered], CrateOrder[group][coCrates], number_format(CrateOrder[group][coDelivered] * CrateOrder[group][coPerCrate]));
				}
				if(PlayerInfo[p][pLeader] == group) {
					SendClientMessageEx(p, COLOR_LIGHTRED, "* %s %s da huy don, %d/%d thung da giao, gia: $%s", arrGroupRanks[group][PlayerInfo[playerid][pRank]], GetPlayerNameEx(playerid), CrateOrder[group][coDelivered], CrateOrder[group][coCrates], number_format(CrateOrder[group][coDelivered] * CrateOrder[group][coPerCrate]));
					SendClientMessageEx(p, COLOR_LIGHTRED, "* Da hoan $%s vao quy cho so thung chua giao.", number_format(refund));
				}
			}
			format(szMiscArray, sizeof(szMiscArray), "%s %s has canceled the crate order, %d/%d crates were delivered costing: $%s ($%s was refunded)", arrGroupRanks[group][PlayerInfo[playerid][pRank]], GetPlayerNameEx(playerid), CrateOrder[group][coDelivered], CrateOrder[group][coCrates], number_format(CrateOrder[group][coDelivered] * CrateOrder[group][coPerCrate]), number_format(refund));
			GroupPayLog(group, szMiscArray);
			SetGroupBudget(group, refund);
			format(szMiscArray, sizeof(szMiscArray), "%s has canceled their crate order, %d/%d crates were delivered adding: $%s.", arrGroupData[group][g_szGroupName], CrateOrder[group][coDelivered], CrateOrder[group][coCrates], number_format(CrateOrder[group][coDelivered] * CrateOrder[group][coPerCrate]), number_format(refund));
			GroupPayLog(CrateFacility[CrateOrder[group][coFacility]][cfGroup], szMiscArray);
			SetGroupBudget(CrateFacility[CrateOrder[group][coFacility]][cfGroup], (CrateOrder[group][coDelivered] * CrateOrder[group][coPerCrate]));
		}
		SaveGroup(CrateFacility[CrateOrder[group][coFacility]][cfGroup] == group ? type : CrateFacility[CrateOrder[group][coFacility]][cfGroup]);
		ResetOrder(group);
		SaveGroup(group);
	}
	return 1;
}

stock PrepOrder(playerid, group) {
	if(!IsGroupLeader(playerid)) return 1;
	new fname[32];
	szMiscArray[0] = 0;
	if(0 <= CrateOrder[group][coFacility] < MAX_CRATE_FACILITY) {
		format(fname, sizeof(fname), "%s", CrateFacility[CrateOrder[group][coFacility]][cfName]);
	} else {
		format(fname, sizeof(fname), "Chua chon");
	}

	format(szMiscArray, sizeof(szMiscArray),
		"{BBBBBB}Chon co so?:\t{FFFFFF}%s\n\
		{BBBBBB}Bao nhieu thung?:\t{FFFFFF}%s ($%s)\n\
		{40FFFF}Cach hoat dong\n\
		{FFD700}Xac nhan don",
		fname,
		number_format(CrateOrder[group][coCrates]), number_format((CrateOrder[group][coCrates] * CrateOrder[group][coPerCrate]))
	);
	return Dialog_Show(playerid, place_order, DIALOG_STYLE_TABLIST, "Dat thung", szMiscArray, "Chon", "Huy");
}

Dialog:place_order(playerid, response, listitem, inputtext[]) {
	if(!IsGroupLeader(playerid)) return 1;
	if(CrateOrder[PlayerInfo[playerid][pMember]][coStatus]) return SendClientMessageEx(playerid, COLOR_GREY, "To chuc da co mot don dat thung dang xu ly.");
	if(response) {
		szMiscArray[0] = 0;
		new group = PlayerInfo[playerid][pMember];
		switch(listitem) {
			case 0: {
				ListFacility(playerid);
			}
			case 1: {
				if(!(0 <= CrateOrder[group][coFacility] < MAX_CRATE_FACILITY)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Phai chon co so de dat thung hang!"), PrepOrder(playerid, group);
				format(szMiscArray, sizeof(szMiscArray), "Nhap so thung muon dat.\n\nGia moi thung: $%s", number_format(CrateFacility[CrateOrder[group][coFacility]][cfProdCost]));
				Dialog_Show(playerid, crate_total, DIALOG_STYLE_INPUT, "Ban muon bao nhieu thung?", szMiscArray, "Dong y", "Quay lai");
			}
			case 2: {
				szMiscArray = "{FFFFFF}_______________________________________________________________________________________________________________________________________________________\n\n";
				strcat(szMiscArray, "{40FFFF}Huong dan dat thung hang{FFFFFF}\n\n");
				strcat(szMiscArray, "Khi dat thung hang, ban se thay danh sach 'Facility' va gia moi thung.\n");
				strcat(szMiscArray, "Chon co so roi nhap so 'Crates' can dat (toi da 50 thung moi don)\n\n");
				strcat(szMiscArray, "Tong gia hien trong ngoac. Khi xac nhan, tien duoc tru tu quy de tra\n");
				strcat(szMiscArray, "cho moi thung duoc giao. Gia moi thung duoc chot tai thoi diem dat don,\n");
				strcat(szMiscArray, "nen khong doi neu chu co so dieu chinh gia! (De tranh lam dung)\n\n");
				strcat(szMiscArray, "Ban co the huy don bat ky luc nao bang /ordercrates. Khi huy, ban se thay so thung da giao\n");
				strcat(szMiscArray, "va so tien duoc hoan tra vao quy.\n\n");
				strcat(szMiscArray, "{FFFFFF}_______________________________________________________________________________________________________________________________________________________");
				Dialog_Show(playerid, how_crates_work, DIALOG_STYLE_MSGBOX, "Huong dan dat thung", szMiscArray, "Quay lai", "");
			}
			case 3: {
				if(!(0 <= CrateOrder[group][coFacility] < MAX_CRATE_FACILITY)) return SendClientMessageEx(playerid, COLOR_GRAD2, "LOI: Phai chon co so!"), PrepOrder(playerid, group);
				if(CrateOrder[group][coCrates] < 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "LOI: Phai chon so thung muon dat!"), PrepOrder(playerid, group);
				if(!CrateFacility[CrateOrder[group][coFacility]][cfActive] || CrateFacility[CrateOrder[group][coFacility]][cfGroup] == -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Co so da chon khong nhan don dat hang!"), PrepOrder(playerid, group);
				if(CrateFacility[CrateOrder[group][coFacility]][cfProdCost] < 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Co so da chon chua thiet lap gia san xuat!"), PrepOrder(playerid, group);
				//if(CrateFacility[CrateOrder[group][coFacility]][cfGroup] == group) return SendClientMessageEx(playerid, COLOR_GRAD2, "You can't order from your own facility, You can deliver them manually."), PrepOrder(playerid, group);
				if(!(1 <= CrateOrder[group][coCrates] <= 50) || CrateOrder[group][coPerCrate] < 1 || CrateOrder[group][coPerCrate] > cellmax / CrateOrder[group][coCrates]) return SendClientMessageEx(playerid, COLOR_RED, "So thung dat khong hop le.");
				new cost = (CrateOrder[group][coCrates] * CrateOrder[group][coPerCrate]);
				if(GetGroupBudget(group) < cost) return SendClientMessageEx(playerid, COLOR_RED, "LOI: To chuc khong du tien dat tung ay thung!"), PrepOrder(playerid, group);
				if(ValidGroup(CrateOrder[group][coFacility])) {
					foreach(new p: Player) {
						if(PlayerInfo[p][pMember] == CrateFacility[CrateOrder[group][coFacility]][cfGroup]) {
							SendClientMessageEx(p, COLOR_LIGHTRED, "%s da dat %d thung hang! (( /crate orders ))", arrGroupData[group][g_szGroupName], CrateOrder[group][coCrates]);
						}
						if(PlayerInfo[p][pLeader] == group) {
							SendClientMessageEx(p, COLOR_LIGHTRED, "%s %s da dat %d thung tai %s.", arrGroupRanks[group][PlayerInfo[playerid][pRank]], GetPlayerNameEx(playerid), CrateOrder[group][coCrates], CrateFacility[CrateOrder[group][coFacility]][cfName]);
						}
					}
				}
				CrateOrder[group][coOrderBy] = GetPlayerNameEx(playerid);
				CrateOrder[group][coStatus] = 1;
				SaveOrder(group);
				SetGroupBudget(group, -cost);
				SaveGroup(group);
				SendClientMessageEx(playerid, COLOR_WHITE, "Da dat %d thung tai %s voi gia $%s", CrateOrder[group][coCrates], CrateFacility[CrateOrder[group][coFacility]][cfName], number_format(cost));
				SendClientMessageEx(playerid, COLOR_WHITE, "Da tru $%s tu quy to chuc de chuan bi don hang.", number_format(cost));
				SendClientMessageEx(playerid, COLOR_YELLOW, "CHU Y: Dung lai /ordercrates de quan ly don hang.");
				format(szMiscArray, sizeof(szMiscArray), "%s %s has placed order for %d crates at %s costing $%s", arrGroupRanks[group][PlayerInfo[playerid][pRank]], GetPlayerNameEx(playerid), CrateOrder[group][coCrates], CrateFacility[CrateOrder[group][coFacility]][cfName], number_format(cost));
				GroupPayLog(group, szMiscArray);
			}
		}
	}
	return 1;
}

stock ListFacility(playerid) {
	if(!IsGroupLeader(playerid)) return 1;
	szMiscArray[0] = 0;
	format(szMiscArray, sizeof(szMiscArray), "Co so\tGia moi thung\tHoat dong\n");
	for(new f = 0; f < MAX_CRATE_FACILITY; f++) {
		format(szMiscArray, sizeof(szMiscArray), "%s%s\t$%s\t%s\n", szMiscArray, CrateFacility[f][cfName], number_format(CrateFacility[f][cfProdCost]), (CrateFacility[f][cfActive]) ? ("Co") : ("Khong"));
	}
	return Dialog_Show(playerid, select_facility, DIALOG_STYLE_TABLIST_HEADERS, "Chon co so nao?", szMiscArray, "Chon", "Quay lai");
}

Dialog:select_facility(playerid, response, listitem, inputtext[]) {
	if(!IsGroupLeader(playerid)) return 1;
	if(CrateOrder[PlayerInfo[playerid][pMember]][coStatus]) return SendClientMessageEx(playerid, COLOR_GREY, "To chuc da co mot don dat thung dang xu ly.");
	new group = PlayerInfo[playerid][pMember];
	if(response) {
		if(!(0 <= listitem < MAX_CRATE_FACILITY)) return SendClientMessageEx(playerid, COLOR_RED, "LOI - Da xay ra loi, hay thu lai!"), ListFacility(playerid);
		if(!CrateFacility[listitem][cfActive] || CrateFacility[listitem][cfGroup] == -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Co so da chon khong nhan don dat hang!"), ListFacility(playerid);
		if(CrateFacility[listitem][cfProdCost] < 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Co so da chon chua thiet lap gia san xuat!"), ListFacility(playerid);
		//if(CrateFacility[listitem][cfGroup] == group) return SendClientMessageEx(playerid, COLOR_GRAD2, "You can't order from your own facility, You can deliver them manually."), ListFacility(playerid);
		CrateOrder[group][coFacility] = listitem;
		CrateOrder[group][coCrates] = 0;
		CrateOrder[group][coPerCrate] = 0;
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban da chon dat thung tu %s.", CrateFacility[listitem][cfName]);
		SaveOrder(group);
		PrepOrder(playerid, group);
	} else {
		PrepOrder(playerid, group);
	}
	return 1;
}

Dialog:crate_total(playerid, response, listitem, inputtext[]) {
	if(!IsGroupLeader(playerid)) return 1;
	if(CrateOrder[PlayerInfo[playerid][pMember]][coStatus]) return SendClientMessageEx(playerid, COLOR_GREY, "To chuc da co mot don dat thung dang xu ly.");
	new group = PlayerInfo[playerid][pMember];
	if(!(0 <= CrateOrder[group][coFacility] < MAX_CRATE_FACILITY)) return PrepOrder(playerid, group);
	szMiscArray[0] = 0;
	if(response) {
		new total = strval(inputtext);
		if(!(0 < total < 51)) {
			format(szMiscArray, sizeof(szMiscArray), "{FFFFFF}Nhap so thung muon dat.\n\nGia moi thung: $%s\n\n{FF0000}LOI: Chi duoc dat tu 1 den 50 thung moi don!", number_format(CrateFacility[CrateOrder[group][coFacility]][cfProdCost]));
			Dialog_Show(playerid, crate_total, DIALOG_STYLE_INPUT, "Ban muon bao nhieu thung?", szMiscArray, "Dong y", "Quay lai");
			return 1;
		}
		if(CrateFacility[CrateOrder[group][coFacility]][cfProdCost] < 1 || CrateFacility[CrateOrder[group][coFacility]][cfProdCost] > cellmax / total) return SendClientMessageEx(playerid, COLOR_RED, "Gia thung khong hop le.");
		if(GetGroupBudget(group) < (CrateFacility[CrateOrder[group][coFacility]][cfProdCost] * total)) {
			format(szMiscArray, sizeof(szMiscArray), "{FFFFFF}Nhap so thung muon dat.\n\nGia moi thung: $%s\n\n{FF0000}LOI: To chuc khong du tien mua %s thung!\n{FFFFFF}Ngan sach: $%s | Chi phi: $%s", number_format(CrateFacility[CrateOrder[group][coFacility]][cfProdCost]), number_format(total), number_format(GetGroupBudget(group)), number_format(CrateFacility[CrateOrder[group][coFacility]][cfProdCost] * total));
			Dialog_Show(playerid, crate_total, DIALOG_STYLE_INPUT, "Ban muon bao nhieu thung?", szMiscArray, "Dong y", "Quay lai");
			return 1;
		}
		CrateOrder[group][coCrates] = total;
		CrateOrder[group][coPerCrate] = CrateFacility[CrateOrder[group][coFacility]][cfProdCost];
		SaveOrder(group);
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban da chon dat %d thung tu %s.", total, CrateFacility[CrateOrder[group][coFacility]][cfName]);
		PrepOrder(playerid, group);
	} else {
		PrepOrder(playerid, group);
	}
	return 1;
}

Dialog:how_crates_work(playerid, response, listitem, inputtext[]) {
	if(!IsGroupLeader(playerid)) return 1;
	return PrepOrder(playerid, PlayerInfo[playerid][pMember]);
}

stock GetFacility(group, &fac) {
	fac = -1;
    for(new f = 0; f < MAX_CRATE_FACILITY; f++)
    {
		if(ValidGroup(group) && CrateFacility[f][cfId] > 0 && group == CrateFacility[f][cfGroup])
		{
			fac = f;
			break;
	    }
 	}
}

stock ResetOrder(group) {
	if(!ValidGroup(group)) return 1;
	foreach(new playerid : Player) {
		if(CrateAction[playerid][caTimer] && CrateAction[playerid][caPoint] == group) CancelCrateAction(playerid);
	}
	CrateOrder[group][coFacility] = -1;
	CrateOrder[group][coCrates] = 0;
	CrateOrder[group][coPerCrate] = 0;
	CrateOrder[group][coDelivered] = 0;
	CrateOrder[group][coStatus] = 0;
	CrateOrder[group][coTime] = 0;
	SaveOrder(group);
	return 1;
}

stock GetDeliverPoint(playerid, &point, Float:range)
{
	point = -1;
    for(new d = 0; d < MAX_GROUPS; d++)
    {
 	    if(IsPlayerInRangeOfPoint(playerid, range, arrGroupData[d][g_fCratePos][0], arrGroupData[d][g_fCratePos][1], arrGroupData[d][g_fCratePos][2]))
		{
			point = d;
			break;
	    }
 	}
}

CMD:delivercrate(playerid, params[]) {
	if(CrateAction[playerid][caTimer]) return SendClientMessageEx(playerid, COLOR_GREY, "Hay xong thao tac thung hang hien tai truoc.");
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER || PlayerBusy(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai lai xe giao hang.");
	new fac, veh, crates, point;
	if(!ValidGroup(PlayerInfo[playerid][pMember])) return SendClientMessage(playerid, COLOR_GRAD2, "Ban phai thuoc mot to chuc de dung lenh nay!");
	GetDeliverPoint(playerid, point, 6);
	GetFacility(PlayerInfo[playerid][pMember], fac);
	if(fac == -1) return SendClientMessage(playerid, COLOR_GRAD2, "To chuc khong co co so thung hang, khong the xu ly don!");
	if((veh = IsDynamicCrateVehicle(GetPlayerVehicleID(playerid))) == -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o tren xe chi dinh cho thao tac nay!");
	if(point == -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o gan diem giao thung hang!");
	if(VehDelivering[veh]) return SendClientMessageEx(playerid, COLOR_GREY, "Xe dang do thung hang.");
	if(CrateBeingDelivered[point]) return SendClientMessageEx(playerid, COLOR_GRAD2, "Co nguoi khac dang giao thung hang, vui long cho.");
	if(!CrateOrder[point][coStatus] || CrateOrder[point][coFacility] != fac) return SendClientMessageEx(playerid, COLOR_GRAD2, "%s chua dat thung hang tai co so cua ban.", arrGroupData[point][g_szGroupName]);
	for(new c = 0; c < MAX_CRATES; c++) {
		if(CrateBox[c][cbActive]) {
			if(CrateBox[c][cbFacility] == fac && CrateBox[c][cbInVeh] == veh) {
				++crates;
			}
		}
	}
	if(!crates) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong co thung thuoc co so cua ban trong xe de giao!");
	CancelCrateAction(playerid);
	CrateBeingDelivered[point] = playerid + 1;
	VehDelivering[veh] = 1;
	CrateAction[playerid][caFacility] = fac;
	CrateAction[playerid][caVehicle] = veh;
	CrateAction[playerid][caPoint] = point;
	SetPVarInt(playerid, "DeliverCrateTime", 8);
	CrateAction[playerid][caTimer] = SetTimerEx("DeliverCrate", 1000, false, "iii", playerid, g_arrQueryHandle[playerid], CrateAction[playerid][caToken]);
	GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~w~Con 8 giay", 1100, 3);
	TogglePlayerControllable(playerid, false);
	return 1;
}

forward DeliverCrate(playerid, session, token);
public DeliverCrate(playerid, session, token) {
	if(!IsPlayerConnected(playerid) || g_arrQueryHandle[playerid] != session || CrateAction[playerid][caToken] != token) return 1;
	new fac = CrateAction[playerid][caFacility], veh = CrateAction[playerid][caVehicle], point = CrateAction[playerid][caPoint];
	if(!(0 <= fac < MAX_CRATE_FACILITY) || !(0 <= veh < MAX_CRATE_VEHCILES) || !ValidGroup(point)) return CancelCrateAction(playerid);
	if(CrateBeingDelivered[point] != playerid + 1 || !VehDelivering[veh]) return CancelCrateAction(playerid);
    szMiscArray[0] = 0;
	new string[128];
	SetPVarInt(playerid, "DeliverCrateTime", GetPVarInt(playerid, "DeliverCrateTime")-1);
	format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~w~Con %d giay", GetPVarInt(playerid, "DeliverCrateTime"));
	GameTextForPlayer(playerid, string, 1100, 3);

	if(GetPVarInt(playerid, "DeliverCrateTime") > 0) {
		CrateAction[playerid][caTimer] = SetTimerEx("DeliverCrate", 1000, false, "iii", playerid, session, token);
		return 1;
	}

	if(GetPVarInt(playerid, "DeliverCrateTime") < 1) {
		CancelCrateAction(playerid);
		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER || PlayerBusy(playerid)) return 1;
		if(!ValidGroup(PlayerInfo[playerid][pMember])) {
			SendClientMessageEx(playerid, COLOR_GRAD2, "Giao thung that bai. Ban khong con trong to chuc!");
			return 1;
		}
		if(IsDynamicCrateVehicle(GetPlayerVehicleID(playerid)) != veh) {
			SendClientMessageEx(playerid, COLOR_GRAD2, "Giao thung that bai, ban da roi xe dang giao hang!");
			return 1;
		}
		if(PlayerInfo[playerid][pMember] != CrateFacility[fac][cfGroup]) {
			SendClientMessageEx(playerid, COLOR_GRAD2, "Giao thung that bai, to chuc khong con so huu co so!");
			return 1;
		}
 	    if(!IsPlayerInRangeOfPoint(playerid, 6.0, arrGroupData[point][g_fCratePos][0], arrGroupData[point][g_fCratePos][1], arrGroupData[point][g_fCratePos][2])) {
			SendClientMessageEx(playerid, COLOR_GRAD2, "Giao thung that bai, ban da roi diem giao hang!");
			return 1;
	    }
	    if(playerTabbed[playerid] != 0) {
	    	SendClientMessageEx(playerid, COLOR_GRAD2, "Giao thung that bai, ban da alt-tab.");
	    	return 1;
	    }
	    if(!CrateOrder[point][coStatus] || CrateOrder[point][coFacility] != fac) {
	    	SendClientMessageEx(playerid, COLOR_GRAD2, "Giao thung that bai, %s da huy don.", arrGroupData[point][g_szGroupName]);
	    	return 1;
	    }
		new remaining = CrateOrder[point][coCrates] - CrateOrder[point][coDelivered], crates, materials;
		new multiplier = CrateFacility[fac][cfProdMulti], payee = CrateFacility[fac][cfGroup];
		if(!(1 <= CrateOrder[point][coCrates] <= 50) || !(0 <= CrateOrder[point][coDelivered] < CrateOrder[point][coCrates]) || remaining < 1 || CrateOrder[point][coPerCrate] < 1 || CrateOrder[point][coCrates] > cellmax / CrateOrder[point][coPerCrate] || multiplier < 1) 
			return SendClientMessageEx(playerid, COLOR_RED, "Thiet lap don dat thung khong hop le.");

		for(new c = 0; c < MAX_CRATES && crates < remaining; c++) {
			if(!CrateBox[c][cbActive] || CrateBox[c][cbFacility] != fac || CrateBox[c][cbInVeh] != veh) 
				continue;
			
			if(CrateBox[c][cbMats] < 0 || CrateBox[c][cbMats] > (cellmax - materials) / multiplier) 
				return SendClientMessageEx(playerid, COLOR_RED, "So vat lieu trong thung qua lon.");
			
			materials += CrateBox[c][cbMats] * multiplier;
			++crates;
		}
		if(!crates) return SendClientMessageEx(playerid, COLOR_GREY, "Khong con thung phu hop de giao.");
		if(arrGroupData[point][g_iLockerStock] < 0 || arrGroupData[point][g_iLockerStock] > cellmax - materials) 
			return SendClientMessageEx(playerid, COLOR_RED, "Tu khong nhan duoc vat lieu nay.");
		
		if(point == payee) payee = arrGroupData[payee][g_iAllegiance] == 2 ? 8 : 5;
		new payment = CrateOrder[point][coCrates] * CrateOrder[point][coPerCrate];
		if(crates == remaining && GetGroupBudget(payee) > cellmax - payment) 
			return SendClientMessageEx(playerid, COLOR_RED, "Ngan sach co so khong the nhan khoan nay.");
		
		arrGroupData[point][g_iLockerStock] += materials;
		CrateOrder[point][coDelivered] += crates;
		new consumed;
		for(new c = 0; c < MAX_CRATES && consumed < crates; c++) {
			if(CrateBox[c][cbActive] && CrateBox[c][cbFacility] == fac && CrateBox[c][cbInVeh] == veh) {
				DestroyCrate(c, false);
				++consumed;
			}
		}
		SaveFacility(fac);
		SaveGroup(point);
		if(CrateOrder[point][coDelivered] >= CrateOrder[point][coCrates]) {
			if(point == PlayerInfo[playerid][pMember]) {
				new type = (arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance] == 2) ? 8 : 5; 
				foreach(new p: Player) {
					if(PlayerInfo[p][pMember] == type) {
						SendClientMessageEx(p, COLOR_LIGHTRED, "* Don cua %s da xong, %d thung da giao, thu: $%s.", arrGroupData[point][g_szGroupName], CrateOrder[point][coCrates], number_format(CrateOrder[point][coCrates] * CrateOrder[point][coPerCrate]));
					}
					if(PlayerInfo[p][pLeader] == point) {
						SendClientMessageEx(p, COLOR_LIGHTRED, "* Co so %s da giao xong don, ban co the dat don moi.", CrateFacility[fac][cfName]);
					}
				}
				SetGroupBudget(type, (CrateOrder[point][coCrates] * CrateOrder[point][coPerCrate]));
				format(szMiscArray, sizeof(szMiscArray), "%s's own crate order was sucesfully completed %d crates were delivered adding: $%s.", arrGroupData[point][g_szGroupName], CrateOrder[point][coCrates], number_format(CrateOrder[point][coCrates] * CrateOrder[point][coPerCrate]));
				GroupPayLog(type, szMiscArray);
				format(szMiscArray, sizeof(szMiscArray), "%s facility has successfully delivered all %d crates to your locker.", CrateFacility[fac][cfName], CrateOrder[point][coCrates]);
				CrateLog(point, szMiscArray);
			} else {
				foreach(new p: Player) {
					if(PlayerInfo[p][pMember] == CrateFacility[CrateOrder[point][coFacility]][cfGroup]) {
						SendClientMessageEx(p, COLOR_LIGHTRED, "* Don cua %s da xong, %d thung da giao, thu: $%s.", arrGroupData[point][g_szGroupName], CrateOrder[point][coCrates], number_format(CrateOrder[point][coCrates] * CrateOrder[point][coPerCrate]));
					}
					if(PlayerInfo[p][pLeader] == point) {
						SendClientMessageEx(p, COLOR_LIGHTRED, "* Co so %s da giao xong don, ban co the dat don moi.", CrateFacility[fac][cfName]);
					}
				}
				SetGroupBudget(CrateFacility[CrateOrder[point][coFacility]][cfGroup], (CrateOrder[point][coCrates] * CrateOrder[point][coPerCrate]));
				format(szMiscArray, sizeof(szMiscArray), "%s's crate order was sucesfully completed %d crates were delivered adding: $%s.", arrGroupData[point][g_szGroupName], CrateOrder[point][coCrates], number_format(CrateOrder[point][coCrates] * CrateOrder[point][coPerCrate]));
				GroupPayLog(CrateFacility[CrateOrder[point][coFacility]][cfGroup], szMiscArray);
				format(szMiscArray, sizeof(szMiscArray), "%s facility has successfully delivered all %d crates to your locker.", CrateFacility[fac][cfName], CrateOrder[point][coCrates]);
				CrateLog(point, szMiscArray);
			}
			SaveGroup(payee);
			ResetOrder(point);
		} else {
			format(szMiscArray, sizeof(szMiscArray), "%s has delivered %d crates to %s (Total delivered: %d/%d)", GetPlayerNameEx(playerid), crates, arrGroupData[point][g_szGroupName], CrateOrder[point][coDelivered], CrateOrder[point][coCrates]);
			CrateLog(CrateFacility[CrateOrder[point][coFacility]][cfGroup], szMiscArray);
			SendClientMessageEx(playerid, COLOR_LIGHTRED, "* Da giao %d thung cho %s, tong da giao: %d/%d", crates, arrGroupData[point][g_szGroupName], CrateOrder[point][coDelivered], CrateOrder[point][coCrates]);
		}
		if(CrateOrder[point][coStatus]) SaveOrder(point);
		new left = CreateCount(veh);
		if(left > 0) SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban con %d thung khong duoc dung cho dot giao nay.", left);
	}
	return 1;
}

CMD:cgun(playerid, params[]) {
	szMiscArray[0] = 0;
	new box, title[32];
	if(!ValidGroup(PlayerInfo[playerid][pMember])) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban phai thuoc mot to chuc de dung lenh nay!");
	if(PlayerInfo[playerid][pAccountRestricted] != 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Tai khoan cua ban bi han che!");
	if(PlayerInfo[playerid][pWRestricted] > 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban dang bi han che vu khi, khong the lay vu khi!");
	if(PlayerBusy(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chua the lam vay.");
	GetCrateBox(playerid, box, 2.0);
	if(box == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan thung hang.");
	if(CrateBox[box][cbGroup] != -1) return SendClientMessageEx(playerid, COLOR_GREY, "Day la thung chuyen, hay dung \"/crate contents\"!");
	if(!(0 <= CrateBox[box][cbFacility] < MAX_CRATE_FACILITY)) return SendClientMessageEx(playerid, COLOR_GREY, "Thung khong co co so nguon hop le.");
	if(IsInRangeOfPoint(CrateFacility[CrateBox[box][cbFacility]][cfPos][0], CrateFacility[CrateBox[box][cbFacility]][cfPos][1], CrateFacility[CrateBox[box][cbFacility]][cfPos][2], CrateBox[box][cbPos][0], CrateBox[box][cbPos][1], CrateBox[box][cbPos][2], 500.0))
		return SendClientMessageEx(playerid, COLOR_GRAD2, "LOI: He thong an ninh Crate Island da niem phong thung nay!");
	SetPVarInt(playerid, "Cgunbox", box);
	SetPVarInt(playerid, "CgunGeneration", CrateGeneration[box]);
	SetPVarInt(playerid, "CgunGroup", PlayerInfo[playerid][pMember]);
	format(title, sizeof(title), "Rut tu thung - Vat lieu: %d", CrateBox[box][cbMats]);
	format(szMiscArray, sizeof(szMiscArray), "Vu khi\tGia");
	for(new i = 0; i != MAX_GROUP_WEAPONS; ++i) {
		if(arrGroupData[PlayerInfo[playerid][pMember]][g_iLockerGuns][i]) {
			format(szMiscArray, sizeof szMiscArray, "%s\n%s\t%d", szMiscArray, Weapon_ReturnName(arrGroupData[PlayerInfo[playerid][pMember]][g_iLockerGuns][i]), arrGroupData[PlayerInfo[playerid][pMember]][g_iLockerCost][i]);
		}
		else strcat(szMiscArray, "\nTrong\t--");
	}
	Dialog_Show(playerid, cgun_take, DIALOG_STYLE_TABLIST_HEADERS, title, szMiscArray, "Chon", "Quay lai");
	return 1;
}

Dialog:cgun_take(playerid, response, listitem, inputtext[]) {
	szMiscArray[0] = 0;
	if(!ValidGroup(PlayerInfo[playerid][pMember])) return 1;
	if(!GetPVarType(playerid, "Cgunbox")) return 1;
	new group = PlayerInfo[playerid][pMember], box;
	if(response) {
		if(!(0 <= listitem < MAX_GROUP_WEAPONS) || PlayerInfo[playerid][pAccountRestricted] || PlayerInfo[playerid][pWRestricted] || PlayerBusy(playerid)) return 1;
		GetCrateBox(playerid, box, 2.0);
		if(box == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Thung da ngoai tam voi, hay dung gan thung.");
		if(box != GetPVarInt(playerid, "Cgunbox")) return SendClientMessageEx(playerid, COLOR_RED, "LOI: ID thung khac thung da mo, hay thu lai.");
		if(CrateGeneration[box] != GetPVarInt(playerid, "CgunGeneration") || group != GetPVarInt(playerid, "CgunGroup") || CrateBox[box][cbGroup] != -1) return 1;
		new facility = CrateBox[box][cbFacility];
		if(!(0 <= facility < MAX_CRATE_FACILITY)) return 1;
		if(IsInRangeOfPoint(CrateFacility[facility][cfPos][0], CrateFacility[facility][cfPos][1], CrateFacility[facility][cfPos][2], CrateBox[box][cbPos][0], CrateBox[box][cbPos][1], CrateBox[box][cbPos][2], 500.0)) return SendClientMessageEx(playerid, COLOR_GREY, "Thung bi niem phong gan co so nguon.");
		new GunID = arrGroupData[group][g_iLockerGuns][listitem];
		new slot = GetLoadoutWeaponSlot(GunID), cost = arrGroupData[group][g_iLockerCost][listitem];
		if(!(0 <= slot < 12) || cost < 0) return 1;
		if(!GunID) return SendClientMessageEx(playerid, COLOR_WHITE, "O nay chua co vu khi!");
		if(CrateBox[box][cbMats] < arrGroupData[group][g_iLockerCost][listitem]) return SendClientMessageEx(playerid, COLOR_GRAD2, "Thung khong du vat lieu cho vu khi nay!");
		if(PlayerInfo[playerid][pGuns][slot] != GunID) {
			GivePlayerValidWeapon(playerid, GunID);
			CrateBox[box][cbMats] -= arrGroupData[group][g_iLockerCost][listitem];
			format(szMiscArray, sizeof(szMiscArray), "* %s lay tu thung vu khi ra mot %s.", GetPlayerNameEx(playerid), Weapon_ReturnName(GunID));
			ProxDetector(25.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			if(CrateBox[box][cbMats] < 1) DestroyCrate(box);
			else {
				SaveCrate(box);
				CrateBoxUpdate(box);
			}
		} else {
			SendClientMessageEx(playerid, COLOR_RED, "Ban da mang %s roi!", Weapon_ReturnName(GunID));
		}
	}
	DeletePVar(playerid, "Cgunbox");
	DeletePVar(playerid, "CgunGeneration");
	DeletePVar(playerid, "CgunGroup");
	return 1;
}

stock TriggerGates(fac, status = 1)
{
	if(!(0 <= fac < MAX_CRATE_FACILITY)) return 0;
	foreach(new gateid : ActiveGates)
	{
		if(GateInfo[gateid][gFacility] != fac) continue;
		if(GateEditor[gateid]) CreateGate(gateid);
		SetGateOpen(gateid, status != 0, true);
	}
	return 1;
}
