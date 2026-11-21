/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

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

	---- NOTES ----

	Since there is no "Official DMV" leaders can access their storage it'll work the same way as a player owned vehicle
	but vehicles that contain crates CANNOT be de-spawned, also vehicle health is also saved along with fuel to prevent abuse.

	If the vehicle has been impounded the payments can be made from the storage. (Nation will be taken into account for which GOV gets the payment).
	Price will be determined down to the playing hours of said player and not level.
*/
#include <YSI_Coding\y_hooks>

new CrateVehTotal = 0;

new VehDelivering[MAX_CRATE_VEHCILES];

hook OnGameModeInit() {
	for(new i = 0; i < MAX_CRATE_VEHCILES; ++i) {
		VehDelivering[i] = 0;
		CrateVehicle[i][cvForkObject] = -1;
		CrateVehicle[i][cvSpawnID] = INVALID_VEHICLE_ID;
		CrateVehicle[i][cvId] = -1;
		CrateVehicle[i][cvModel] = 0;
		CrateVehicle[i][cvColor][0] = 0;
		CrateVehicle[i][cvColor][1] = 0;
		CrateVehicle[i][cvGroupID] = -1;
		CrateVehicle[i][cvRank] = -1;
		CrateVehicle[i][cvSpawned] = 0;
		CrateVehicle[i][cvDisabled] = 0;
		CrateVehicle[i][cvImpound] = 0;
		CrateVehicle[i][cvTickets] = 0;
		CrateVehicle[i][cvMaxHealth] = 1000;
		CrateVehicle[i][cvHealth] = 1000;
		CrateVehicle[i][cvFuel] = 100;
		CrateVehicle[i][cvType] = 0;
		for(new p = 0; p < 4; p++) CrateVehicle[i][cvPos][p] = 0.0;
		CrateVehicle[i][cvInt] = 0;
		CrateVehicle[i][cvVw] = 0;
		CrateVehicle[i][cvCrateMax] = 0;
		CrateVehicle[i][cvCrate] = -1;
		CrateVehicle[i][cvCrateLoad] = 0;
	}
	return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate) {
	new carid;
	if(newstate == PLAYER_STATE_DRIVER) {
		if((carid = IsDynamicCrateVehicle(GetPlayerVehicleID(playerid))) != -1) {
			if(PlayerInfo[playerid][pAdmin] > 3 || PlayerInfo[playerid][pASM] > 0 || PlayerInfo[playerid][pFactionModerator] > 0) {
				if(ValidGroup(CrateVehicle[carid][cvGroupID])) {
					SendClientMessageEx(playerid, COLOR_YELLOW, "Xe cho thung nay thuoc ve %s", arrGroupData[CrateVehicle[carid][cvGroupID]][g_szGroupName]);
				}
			} else {
				if(ValidGroup(CrateVehicle[carid][cvGroupID])) {
					if(PlayerInfo[playerid][pMember] != CrateVehicle[carid][cvGroupID]) {
						SendClientMessageEx(playerid, COLOR_GREY, "Ban phai thuoc %s de lai xe nay!", arrGroupData[CrateVehicle[carid][cvGroupID]][g_szGroupName]);
						return RemovePlayerFromVehicle(playerid);
					}
					if(0 <= CrateVehicle[carid][cvRank] < MAX_GROUP_RANKS && (PlayerInfo[playerid][pRank] < CrateVehicle[carid][cvRank])) {
						SendClientMessageEx(playerid, COLOR_GREY, "Ban can hang %s (%d) tro len de lai xe nay!", arrGroupRanks[CrateVehicle[carid][cvGroupID]][CrateVehicle[carid][cvRank]], CrateVehicle[carid][cvRank]);
						return RemovePlayerFromVehicle(playerid);
					}
				}
				if(!ValidGroup(CrateVehicle[carid][cvGroupID]) && !ValidGroup(PlayerInfo[playerid][pMember])) {
					SendClientMessageEx(playerid, COLOR_GREY, "Ban phai thuoc mot to chuc de dung xe nay.");
					return RemovePlayerFromVehicle(playerid);
				}
			}
			if(CreateCount(carid) > 0) SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Co %d thung trong xe nay.", CreateCount(carid));
		}
	}
	return 1;
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) {
	new carid;
	if(!ispassenger) {
		if((carid = IsDynamicCrateVehicle(vehicleid)) != -1) {
			new Float:pos[3];
			if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1 && PlayerInfo[playerid][pFactionModerator] < 5) {
				if(ValidGroup(CrateVehicle[carid][cvGroupID])) {
					if(PlayerInfo[playerid][pMember] != CrateVehicle[carid][cvGroupID]) {
						GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
						SetPlayerPos(playerid, pos[0], pos[1], pos[2]+1.3);
						PlayerPlaySound(playerid, 1130, pos[0], pos[1], pos[2]+1.3);
						SendClientMessageEx(playerid, COLOR_GREY, "Ban phai thuoc %s de dung xe nay!", arrGroupData[CrateVehicle[carid][cvGroupID]][g_szGroupName]);
						return 1;
					}
				}
				if(!ValidGroup(CrateVehicle[carid][cvGroupID]) && !ValidGroup(PlayerInfo[playerid][pMember])) {
					GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
					SetPlayerPos(playerid, pos[0], pos[1], pos[2]+1.3);
					PlayerPlaySound(playerid, 1130, pos[0], pos[1], pos[2]+1.3);
					SendClientMessageEx(playerid, COLOR_GREY, "Ban phai thuoc mot to chuc de dung xe nay.");
					return 1;
				}
			}
		}
	}
	return 1;
}

hook OnVehicleDeath(vehicleid, killerid) {
	new carid;
	if((carid = IsDynamicCrateVehicle(vehicleid)) != -1) {
		CancelCrateVehicleActions(carid);
		if(CreateCount(carid) > 0) AnnounceRespawn(CrateVehicle[carid][cvGroupID], "pha huy", carid, CreateCount(carid)), DestroyCratesInVeh(carid);
		if(CrateVehicle[carid][cvCrate] != -1) DestroyCrate(CrateVehicle[carid][cvCrate]);
	}
	return 1;
}

hook OnVehicleSpawn(vehicleid) {
	new carid;
	if((carid = IsDynamicCrateVehicle(vehicleid)) != -1) {
		CancelCrateVehicleActions(carid);
		if(CreateCount(carid) > 0) AnnounceRespawn(CrateVehicle[carid][cvGroupID], "tao lai", carid, CreateCount(carid)), DestroyCratesInVeh(carid);
		if(CrateVehicle[carid][cvCrate] != -1) DestroyCrate(CrateVehicle[carid][cvCrate]);
		SpawnCrateVeh(carid);
	}
	return 1;
}

forward AnnounceRespawn(group, const type[], veh, amount);
public AnnounceRespawn(group, const type[], veh, amount) {
	if(ValidGroup(group)) {
		new vehicleName[18];
		new string[128];
		strunpack(vehicleName, VehicleName[CrateVehicle[veh][cvModel] - 400], sizeof(vehicleName));
		format(string, sizeof(string), "** Xe %s da bi %s, %d thung bi pha huy. **", vehicleName, type, amount);
		foreach(new i: Player) {
			if(PlayerInfo[i][pMember] == group) {
				ChatTrafficProcess(i, arrGroupData[group][g_hOOCColor] * 256 + 255, string, CHAT_GROUP_OOC);
			}
		}
	}
	return 1;
}

forward LoadDynamicCrateVehicles();
public LoadDynamicCrateVehicles()
{
	printf("[LoadDynamicCrateVehicles] Loading data from database...");
    mysql_tquery(MainPipeline, "SELECT * FROM `crate_vehicles`", "OnLoadDynamicCrateVehciles", "");
    return 1;
}

forward OnLoadDynamicCrateVehciles();
public OnLoadDynamicCrateVehciles() {
	szMiscArray[0] = 0;
	new i, rows, sqlid;
	cache_get_row_count(rows);
	while(i < rows)
	{
		cache_get_value_name_int(i, "id", sqlid);
		if(i < MAX_CRATE_VEHCILES) {
			CrateVehicle[i][cvId] = sqlid;
			cache_get_value_name_int(i, "vModel", CrateVehicle[i][cvModel]);
			cache_get_value_name_int(i, "vColor1", CrateVehicle[i][cvColor][0]);
			cache_get_value_name_int(i, "vColor2", CrateVehicle[i][cvColor][1]);
			cache_get_value_name_int(i, "vGroup", CrateVehicle[i][cvGroupID]);
			cache_get_value_name_int(i, "vRank", CrateVehicle[i][cvRank]);
			cache_get_value_name_int(i, "vSpawned", CrateVehicle[i][cvSpawned]);
			cache_get_value_name_int(i, "vDisabled", CrateVehicle[i][cvDisabled]);
			cache_get_value_name_int(i, "vImpound", CrateVehicle[i][cvImpound]);
			cache_get_value_name_int(i, "vTickets", CrateVehicle[i][cvTickets]);
			cache_get_value_name_float(i, "vMaxHealth", CrateVehicle[i][cvMaxHealth]);
			cache_get_value_name_float(i, "vHealth", CrateVehicle[i][cvHealth]);
			cache_get_value_name_float(i, "vFuel", CrateVehicle[i][cvFuel]);
			cache_get_value_name_int(i, "vType", CrateVehicle[i][cvType]);
			cache_get_value_name_float(i, "vPosX", CrateVehicle[i][cvPos][0]);
			cache_get_value_name_float(i, "vPosY", CrateVehicle[i][cvPos][1]);
			cache_get_value_name_float(i, "vPosZ", CrateVehicle[i][cvPos][2]);
			cache_get_value_name_float(i, "vRotZ", CrateVehicle[i][cvPos][3]);
			cache_get_value_name_int(i, "vInt", CrateVehicle[i][cvInt]);
			cache_get_value_name_int(i, "vVw", CrateVehicle[i][cvVw]);
			cache_get_value_name_int(i, "vCrateMax", CrateVehicle[i][cvCrateMax]);
			cache_get_value_name_int(i, "vCrate", CrateVehicle[i][cvCrate]);
			cache_get_value_name_int(i, "FirstDrop", CrateVehicle[i][cvCrateLoad]);
			if(400 <= CrateVehicle[i][cvModel] < 612) {
				if(!IsWeaponizedVehicle(CrateVehicle[i][cvModel])) {
					SpawnCrateVeh(i);
				}
			}
			++CrateVehTotal;
		} else {
			mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "DELETE FROM `crate_vehicles` WHERE `id` = %d", sqlid);
			mysql_tquery(MainPipeline, szMiscArray, "OnQueryFinish", "i", SENDDATA_THREAD);
			printf("SQL ID %d exceeds Max Dynamic Crate Vehicles", sqlid);
		}
		i++;
	}
	if(CrateVehTotal > 0) printf("[LoadDynamicCrateVehicles] %d dynamic crate vehicles have been loaded.", i);
	else printf("[LoadDynamicCrateVehicles] No dynamic crate vehicles have been loaded.");
	return 1;
}

stock SaveCrateVehicle(id) {
	new query[2048];

	if(CrateVehicle[id][cvSpawnID] != INVALID_VEHICLE_ID) {
		GetVehicleHealth(CrateVehicle[id][cvSpawnID], CrateVehicle[id][cvHealth]);
		if(CrateVehicle[id][cvHealth] < 350) CrateVehicle[id][cvHealth] = 350;
		CrateVehicle[id][cvFuel] = VehicleFuel[CrateVehicle[id][cvSpawnID]];
	}
	format(query, 2048, "UPDATE `crate_vehicles` SET ");
	SaveInteger(query, "crate_vehicles", id+1, "vModel", CrateVehicle[id][cvModel]);
	SaveInteger(query, "crate_vehicles", id+1, "vColor1", CrateVehicle[id][cvColor][0]);
	SaveInteger(query, "crate_vehicles", id+1, "vColor2", CrateVehicle[id][cvColor][1]);
	SaveInteger(query, "crate_vehicles", id+1, "vGroup", CrateVehicle[id][cvGroupID]);
	SaveInteger(query, "crate_vehicles", id+1, "vRank", CrateVehicle[id][cvRank]);
	SaveInteger(query, "crate_vehicles", id+1, "vSpawned", CrateVehicle[id][cvSpawned]);
	SaveInteger(query, "crate_vehicles", id+1, "vDisabled", CrateVehicle[id][cvDisabled]);
	SaveInteger(query, "crate_vehicles", id+1, "vImpound", CrateVehicle[id][cvImpound]);
	SaveInteger(query, "crate_vehicles", id+1, "vTickets", CrateVehicle[id][cvTickets]);
	SaveFloat(query, "crate_vehicles", id+1, "vMaxHealth", CrateVehicle[id][cvMaxHealth]);
	SaveFloat(query, "crate_vehicles", id+1, "vHealth", CrateVehicle[id][cvHealth]);
	SaveFloat(query, "crate_vehicles", id+1, "vFuel", CrateVehicle[id][cvFuel]);
	SaveFloat(query, "crate_vehicles", id+1, "vPosX", CrateVehicle[id][cvPos][0]);
	SaveFloat(query, "crate_vehicles", id+1, "vPosY", CrateVehicle[id][cvPos][1]);
	SaveFloat(query, "crate_vehicles", id+1, "vPosZ", CrateVehicle[id][cvPos][2]);
	SaveFloat(query, "crate_vehicles", id+1, "vRotZ", CrateVehicle[id][cvPos][3]);
	SaveInteger(query, "crate_vehicles", id+1, "vInt", CrateVehicle[id][cvInt]);
	SaveInteger(query, "crate_vehicles", id+1, "vVw", CrateVehicle[id][cvVw]);
	SaveInteger(query, "crate_vehicles", id+1, "vCrateMax", CrateVehicle[id][cvCrateMax]);
	SaveInteger(query, "crate_vehicles", id+1, "vCrate", CrateVehicle[id][cvCrate]);
	SaveInteger(query, "crate_vehicles", id+1, "FirstDrop", CrateVehicle[id][cvCrateLoad]);
	SQLUpdateFinish(query, "crate_vehicles", id+1);
	return 1;
}

forward SpawnCrateVeh(vehid);
public SpawnCrateVeh(vehid) {
	szMiscArray[0] = 0;
	if(!(0 <= vehid < MAX_CRATE_VEHCILES)) return 1;
	CancelCrateVehicleActions(vehid);
    if(!(400 <= CrateVehicle[vehid][cvModel] < 612)) return 1;

	if(CrateVehicle[vehid][cvSpawnID] != INVALID_VEHICLE_ID) {
		DestroyVehicle(CrateVehicle[vehid][cvSpawnID]);
		CrateVehicle[vehid][cvSpawnID] = INVALID_VEHICLE_ID;
	}
	
	if(!CrateVehicle[vehid][cvSpawned] || CrateVehicle[vehid][cvDisabled] || CrateVehicle[vehid][cvImpound]) 
		return CrateVehCheck(vehid);
	
	CrateVehicle[vehid][cvSpawnID] = CreateVehicle(CrateVehicle[vehid][cvModel], CrateVehicle[vehid][cvPos][0], CrateVehicle[vehid][cvPos][1], CrateVehicle[vehid][cvPos][2], CrateVehicle[vehid][cvPos][3], CrateVehicle[vehid][cvColor][0], CrateVehicle[vehid][cvColor][1], -1, 0);
	if(CrateVehicle[vehid][cvHealth] > CrateVehicle[vehid][cvMaxHealth]) CrateVehicle[vehid][cvHealth] = CrateVehicle[vehid][cvMaxHealth];
	if(CrateVehicle[vehid][cvHealth] < 350) CrateVehicle[vehid][cvHealth] = 350;
	SetVehicleHealth(CrateVehicle[vehid][cvSpawnID], CrateVehicle[vehid][cvHealth]);
	SetVehicleVirtualWorld(CrateVehicle[vehid][cvSpawnID], CrateVehicle[vehid][cvVw]);
	LinkVehicleToInterior(CrateVehicle[vehid][cvSpawnID], CrateVehicle[vehid][cvInt]);
	if(CrateVehicle[vehid][cvFuel] > 100) CrateVehicle[vehid][cvFuel] = 100;
	VehicleFuel[CrateVehicle[vehid][cvSpawnID]] = CrateVehicle[vehid][cvFuel];
	SetVehicleNumberPlate(CrateVehicle[vehid][cvSpawnID], "Crates v2.0");
	CrateVehCheck(vehid);
	return 1;
}

forward CrateVehCheck(vehid);
public CrateVehCheck(vehid) {
	new box;
	if(IsValidDynamicObject(CrateVehicle[vehid][cvForkObject])) DestroyDynamicObject(CrateVehicle[vehid][cvForkObject]), CrateVehicle[vehid][cvForkObject] = -1;
	CheckCrateInVeh(vehid);
	if((box = CrateVehicle[vehid][cvCrate]) == -1) return 1;

	if(!IsValidCrate(box)) {
		CrateVehicle[vehid][cvCrate] = -1;
		return 1;
	}
	if(CrateBox[box][cbOnVeh] != vehid) {
		CrateVehicle[vehid][cvCrate] = -1;
		DestroyCrate(box);
		SaveCrateVehicle(vehid);
		return 1;
	}
	if(!CrateVehicle[vehid][cvSpawned] || CrateVehicle[vehid][cvImpound] || CrateVehicle[vehid][cvDisabled]) {
		return DestroyCrate(CrateVehicle[vehid][cvCrate]);
	}
	CrateVehicle[vehid][cvForkObject] = CreateDynamicObject(964,-1077.59997559,4274.39990234,3.40000010,0.00000000,0.00000000,0.00000000);
	AttachDynamicObjectToVehicle(CrateVehicle[vehid][cvForkObject], CrateVehicle[vehid][cvSpawnID], 0, 0.9, -0.2, 0, 0, 0);
	return 1;
}

forward CheckCrateInVeh(veh);
public CheckCrateInVeh(veh) {
	for(new b = 0; b < MAX_CRATES; b++) {
		if(CrateBox[b][cbInVeh] == veh) {
			if(!CrateVehicle[veh][cvSpawned] || CrateVehicle[veh][cvImpound] || CrateVehicle[veh][cvDisabled]) {
				DestroyCrate(b);
			}
		}
	}
	return 1;
}

forward DestroyCratesInVeh(veh);
public DestroyCratesInVeh(veh) {
	for(new b = 0; b < MAX_CRATES; b++) {
		if(CrateBox[b][cbInVeh] == veh) {
			DestroyCrate(b);
		}
	}
	return 1;
}

forward IsDynamicCrateVehicle(vehicleid);
public IsDynamicCrateVehicle(vehicleid) {
    for(new v = 0; v < MAX_CRATE_VEHCILES; v++)
    {
        if(CrateVehicle[v][cvSpawnID] == vehicleid)
        {
            return v;
        }
    }
    return -1;
}

CMD:cvcreate(playerid, params[]) {
	szMiscArray[0] = 0;
	new iVehicle, iColors[2], Float:vpos[4];
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pFactionModerator] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay!");
	if(CrateVehTotal >= MAX_CRATE_VEHCILES) return SendClientMessageEx(playerid, COLOR_GREY, "Da dat gioi han xe cho thung, khong the tao them! (Toi da: %d)", MAX_CRATE_VEHCILES);
	if(sscanf(params, "dD(0)D(0)", iVehicle, iColors[0], iColors[1])) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /cvcreate [model ID] [color 1] [color 2]");
	if(!(400 <= iVehicle < 612)) return SendClientMessageEx(playerid, COLOR_GREY, "Model xe khong hop le!");
	if(IsATrain(iVehicle)) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the tao tau khi may chu dang chay.");
	if(IsWeaponizedVehicle(iVehicle)) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung xe vu trang lam xe cho thung!");
	if(!(0 <= iColors[0] <= 255 && 0 <= iColors[1] <= 255)) return SendClientMessageEx(playerid, COLOR_GREY, "Mau khong hop le (ID tu 0 den 255).");

	GetPlayerPos(playerid, vpos[0], vpos[1], vpos[2]);
	GetPlayerFacingAngle(playerid, vpos[3]);
	for(new i = 0; i < MAX_CRATE_VEHCILES; i++) {
		if(CrateVehicle[i][cvModel] == 0) {
	        mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "INSERT INTO `crate_vehicles` (`vModel`, `vColor1`, `vColor2`, `vPosX`, `vPosY`, `vPosZ`, `vRotZ`) VALUES (%d, %d, %d, %0.5f, %0.5f, %0.5f, %0.5f)", iVehicle, iColors[0], iColors[1], vpos[0], vpos[1], vpos[2], vpos[3]);
			//mysql_tquery(MainPipeline, szMiscArray, false, "OnQueryFinish", "i", SENDDATA_THREAD);
			mysql_tquery(MainPipeline, szMiscArray, "OnCrateVehicle", "iiiffffii", playerid, i, iVehicle, vpos[0], vpos[1], vpos[2], vpos[3], iColors[0], iColors[1]);
			/*CrateVehicle[i][cvModel] = iVehicle;
			CrateVehicle[i][cvPos][0] = vpos[0];
			CrateVehicle[i][cvPos][1] = vpos[1];
			CrateVehicle[i][cvPos][2] = vpos[2];
			CrateVehicle[i][cvPos][3] = vpos[3];
			CrateVehicle[i][cvVw] = GetPlayerVirtualWorld(playerid);
			CrateVehicle[i][cvInt] = GetPlayerInterior(playerid);
			CrateVehicle[i][cvColor][0] = iColors[0];
			CrateVehicle[i][cvColor][1] = iColors[1];
			CrateVehicle[i][cvSpawned] = 1;
			SaveCrateVehicle(i);
			SpawnCrateVeh(i);
			++CrateVehTotal;*/
			break;
		}
	}
	return 1;
}

forward OnCrateVehicle(playerid, i, veh, Float:pos1, Float:pos2, Float:pos3, Float:pos4, color1, color2);
public OnCrateVehicle(playerid, i, veh, Float:pos1, Float:pos2, Float:pos3, Float:pos4, color1, color2) {
	new vehicleName[18];
	CrateVehicle[i][cvId] = cache_insert_id();
	CrateVehicle[i][cvModel] = veh;
	CrateVehicle[i][cvPos][0] = pos1;
	CrateVehicle[i][cvPos][1] = pos2;
	CrateVehicle[i][cvPos][2] = pos3;
	CrateVehicle[i][cvPos][3] = pos4;
	CrateVehicle[i][cvVw] = GetPlayerVirtualWorld(playerid);
	CrateVehicle[i][cvInt] = GetPlayerInterior(playerid);
	CrateVehicle[i][cvColor][0] = color1;
	CrateVehicle[i][cvColor][1] = color2;
	CrateVehicle[i][cvSpawned] = 1;
	SaveCrateVehicle(i);
	SpawnCrateVeh(i);
	++CrateVehTotal;
	strunpack(vehicleName, VehicleName[veh - 400], sizeof(vehicleName));
	SendClientMessageEx(playerid, COLOR_WHITE, "Ban da tao %s lam xe cho thung dynamic. (Con %d o)", vehicleName, (MAX_CRATE_VEHCILES - CrateVehTotal));
	format(szMiscArray, sizeof(szMiscArray), "%s has created a dynamic crate vehicle (Name: %s | Model: %d)", GetPlayerNameEx(playerid), vehicleName, veh);
	Log("logs/cvspawn.log", szMiscArray);
	return 1;
}

CMD:cvstorage(playerid, params[])
{
	szMiscArray[0] = 0;
	if(PlayerInfo[playerid][pAdmin] > 3 || PlayerInfo[playerid][pASM] > 0 || PlayerInfo[playerid][pFactionModerator] > 0) {
		new group;
		if(sscanf(params, "i", group)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /cvstorage [groupid]");
		if(group != -1) {
			if(!ValidGroup(group)) return SendClientMessageEx(playerid, COLOR_GREY, "ID to chuc khong hop le (0 - 39) | -1 de xem xe chua co chu!");
		}
		ListVehicles(playerid, group);
	}
	else {
		if(!IsGroupLeader(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai la lanh dao to chuc de dung lenh nay!");
		if(!IsPlayerInRangeOfPoint(playerid, 100.0, arrGroupData[PlayerInfo[playerid][pMember]][g_fGaragePos][0], arrGroupData[PlayerInfo[playerid][pMember]][g_fGaragePos][1], arrGroupData[PlayerInfo[playerid][pMember]][g_fGaragePos][2])) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan garage cua minh!"); 
		ListVehicles(playerid, PlayerInfo[playerid][pMember]);
	}
	return 1;
}

stock ListVehicles(playerid, group) {
	szMiscArray[0] = 0;
	new title[64];
	SetPVarInt(playerid, "CarGroup", group);
	if(group != -1) format(title, sizeof(title), "Xe cho thung: {%s}%s", Group_NumToDialogHex(arrGroupData[group][g_hDutyColour]), arrGroupData[group][g_szGroupName]);
	else format(title, sizeof(title), "Xe cho thung: Chua co chu");
	format(szMiscArray, sizeof(szMiscArray), "Xe\tTrang thai\tID xe\tTien phat\n");
	for(new i; i < MAX_CRATE_VEHCILES; i++)
	{
		new iModelID = CrateVehicle[i][cvModel];
		if(400 <= iModelID < 612 && CrateVehicle[i][cvGroupID] == group)
		{
			new vehicleName[18];
			if(CrateVehicle[i][cvDisabled]) {
				strunpack(vehicleName, VehicleName[iModelID - 400], sizeof(vehicleName));
				format(szMiscArray, sizeof(szMiscArray), "%s(%d) %s\tBi tat\t--\t$%s\n", szMiscArray, i, vehicleName, number_format(CrateVehicle[i][cvTickets]));
			}
			else if(CrateVehicle[i][cvImpound]) {
				strunpack(vehicleName, VehicleName[iModelID - 400], sizeof(vehicleName));
				format(szMiscArray, sizeof(szMiscArray), "%s(%d) %s\tTam giu\t--\t$%s\n", szMiscArray, i, vehicleName, number_format(CrateVehicle[i][cvTickets]));
			}
			else if(CrateVehicle[i][cvSpawnID] != INVALID_VEHICLE_ID) {
				strunpack(vehicleName, VehicleName[iModelID - 400], sizeof(vehicleName));
				format(szMiscArray, sizeof(szMiscArray), "%s(%d) %s\tDa lay\t%d\t$%s\n", szMiscArray, i, vehicleName, CrateVehicle[i][cvSpawnID], number_format(CrateVehicle[i][cvTickets]));
			}
			else if(CrateVehicle[i][cvSpawnID] == INVALID_VEHICLE_ID) {
				strunpack(vehicleName, VehicleName[iModelID - 400], sizeof(vehicleName));
				format(szMiscArray, sizeof(szMiscArray), "%s(%d) %s\tDa cat\t--\t$%s\n", szMiscArray, i, vehicleName, number_format(CrateVehicle[i][cvTickets]));
			}
		}
	}
	if(strlen(szMiscArray) == 34) {
		new dialogInfo[] = "To chuc nay khong so huu xe nao!";
		Dialog_Show(playerid, -1, DIALOG_STYLE_LIST, title, dialogInfo, "Dong", "");
	}
	else {
		Dialog_Show(playerid, cvstorage, DIALOG_STYLE_TABLIST_HEADERS, title, szMiscArray, "Quan ly", "Dong");
	}
	return 1;
}


Dialog:cvstorage(playerid, response, listitem, inputtext[]) {
	if(response) {
		new stpos = strfind(inputtext, "(");
	    new fpos = strfind(inputtext, ")");
	    new caridstr[6], carid;
	    strmid(caridstr, inputtext, stpos+1, fpos);
	    carid = strval(caridstr);
	    SetPVarInt(playerid, "CvStorageID", carid);
	    CarOptions(playerid);
	} else {
		DeletePVar(playerid, "CarGroup");
	}
	return 1;
}

stock CarOptions(playerid) {
	new vehicleName[18];
	szMiscArray[0] = 0;
	new title[64];
	if(!GetPVarType(playerid, "CvStorageID") && !GetPVarType(playerid, "CarGroup")) return 1;
	strunpack(vehicleName, VehicleName[CrateVehicle[GetPVarInt(playerid, "CvStorageID")][cvModel] - 400], sizeof(vehicleName));
	format(title, sizeof(title), "Xe: %s", vehicleName);
    if(PlayerInfo[playerid][pAdmin] > 3 || PlayerInfo[playerid][pASM] > 0 || PlayerInfo[playerid][pFactionModerator] > 0) {
    	format(szMiscArray, sizeof(szMiscArray),
    		"%s xe\n\
    		Xoa tien phat ($%s)\n\
    		%s xe\n\
    		%s xe\n\
    		Do xang\n\
    		Xoa xe",
    		(CrateVehicle[GetPVarInt(playerid, "CvStorageID")][cvSpawned]) ? ("Cat") : ("Lay"),
    		number_format(CrateVehicle[GetPVarInt(playerid, "CvStorageID")][cvTickets]),
    		(CrateVehicle[GetPVarInt(playerid, "CvStorageID")][cvImpound]) ? ("Chuoc") : ("Tam giu"),
    		(CrateVehicle[GetPVarInt(playerid, "CvStorageID")][cvDisabled]) ? ("Cho phep dung") : ("Vo hieu hoa")
    	);
    	Dialog_Show(playerid, veh_options, DIALOG_STYLE_LIST, title, szMiscArray, "Chon", "Quay lai");
    } else {
    	if(!IsGroupLeader(playerid)) return SendClientMessageEx(playerid, COLOR_RED, "LOI: Ban khong phai lanh dao to chuc!");
    	new price[28], tickets[28];

    	if(CrateVehicle[GetPVarInt(playerid, "CvStorageID")][cvImpound]) {
    		format(tickets, sizeof(tickets), "--");
    		format(price, sizeof(price), "Phi: $%s", number_format(200000 + CrateVehicle[GetPVarInt(playerid, "CvStorageID")][cvTickets]));
		} else {
			format(tickets, sizeof(tickets), "$%s", number_format(CrateVehicle[GetPVarInt(playerid, "CvStorageID")][cvTickets]));
			format(price, sizeof(price), "--");
		}
    	format(szMiscArray, sizeof(szMiscArray),
    		"%s xe\n\
    		Nop phat (%s)\n\
    		Chuoc xe (%s)",
    		(CrateVehicle[GetPVarInt(playerid, "CvStorageID")][cvSpawned]) ? ("Cat") : ("Lay"),
    		tickets,
    		price
    	);
    	Dialog_Show(playerid, veh_options, DIALOG_STYLE_LIST, title, szMiscArray, "Chon", "Quay lai");
    }
	return 1;
}

Dialog:veh_options(playerid, response, listitem, inputtext[]) {
	szMiscArray[0] = 0;
	if(!GetPVarType(playerid, "CvStorageID") && !GetPVarType(playerid, "CarGroup")) return 1;
	if(response) {
		new vehicleName[18];
		new veh, carid = GetPVarInt(playerid, "CvStorageID"), Float:vHealth;
		switch(listitem) {
			case 0: {
				if((veh = CrateVehicle[carid][cvSpawnID]) != INVALID_VEHICLE_ID) {
                    if((!IsVehicleSeatOccupied(veh) || IsPlayerInVehicle(playerid, veh)) && !IsVehicleInTow(veh)) {
						if(CreateCount(carid) > 0) {
							strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
							return SendClientMessageEx(playerid, COLOR_GREY, "Khong the cat %s (Veh id: %d) vi dang cho thung.", vehicleName, veh);
						}
			    		GetVehicleHealth(veh, vHealth);
						if(vHealth < 800) return SendClientMessageEx(playerid, COLOR_GREY, "Xe hong qua nang de cat.");
						CrateVehicle[carid][cvHealth] = vHealth;
						CrateVehicle[carid][cvFuel] = VehicleFuel[veh];
						CancelCrateVehicleActions(carid);
						DestroyVehicle(veh);
						CrateVehicle[carid][cvSpawned] = 0;
						CrateVehicle[carid][cvSpawnID] = INVALID_VEHICLE_ID;
						CrateVehCheck(carid);
						SaveCrateVehicle(carid);
						strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
						SendClientMessageEx(playerid, COLOR_WHITE, "Ban da cat xe cho thung cua to chuc (%s)", vehicleName);
					} else {
						strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
						SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the cat %s (Veh id: %d) vi dang co nguoi ngoi.", vehicleName, veh);
					}
				} else {
	    			if(CrateVehicle[carid][cvDisabled]) return SendClientMessageEx(playerid, COLOR_GRAD1, "Admin da vo hieu hoa xe nay, ban khong the lay xe ra."), CarOptions(playerid);
	    			if(CrateVehicle[carid][cvImpound]) return SendClientMessageEx(playerid, COLOR_GRAD1, "Xe da bi tam giu, ban can chuoc truoc khi lay ra."), CarOptions(playerid);
				 	CrateVehicle[carid][cvSpawned] = 1;
				 	SpawnCrateVeh(carid);
				 	SaveCrateVehicle(carid);
					strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
					SendClientMessageEx(playerid, COLOR_WHITE, "Ban da lay xe cho thung cua to chuc (%s)", vehicleName);
				}
				return CarOptions(playerid);
			}
			case 1: {
				if(PlayerInfo[playerid][pAdmin] > 3 || PlayerInfo[playerid][pASM] > 0 || PlayerInfo[playerid][pFactionModerator] > 0) {
					if(!ValidGroup(CrateVehicle[carid][cvGroupID])) return SendClientMessageEx(playerid, COLOR_GRAD2, "Xe chua co chu khong the bi phat, khong co gi de xoa."), CarOptions(playerid);
					if(!CrateVehicle[carid][cvTickets]) return SendClientMessageEx(playerid, COLOR_GRAD2, "Xe khong co tien phat de xoa."), CarOptions(playerid);
					strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
					format(szMiscArray, sizeof(szMiscArray), "%s removed all outstanding tickets ($%s) on vehicle %s (Veh id: %d | Group Owner: %s)", GetPlayerNameEx(playerid), number_format(CrateVehicle[carid][cvTickets]), vehicleName, CrateVehicle[carid][cvModel], arrGroupData[CrateVehicle[carid][cvGroupID]][g_szGroupName]);
					Log("logs/cratevehicle.log", szMiscArray);
					CrateVehicle[carid][cvTickets] = 0;
					SaveCrateVehicle(carid);
					strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
					format(szMiscArray, sizeof(szMiscArray), "* Tien phat cua %s da duoc admin xoa.", vehicleName);
					foreach(new i: Player) {
						if(PlayerInfo[i][pLeader] == CrateVehicle[carid][cvGroupID]) {
							ChatTrafficProcess(i, arrGroupData[CrateVehicle[carid][cvGroupID]][g_hRadioColour] * 256 + 255, szMiscArray, CHAT_GROUP_RADIO);
						}
					}
					SendClientMessageEx(playerid, COLOR_YELLOW, "Ban da xoa tat ca tien phat cua xe.");
					return CarOptions(playerid);
				} else {
					if(!CrateVehicle[carid][cvTickets]) return SendClientMessageEx(playerid, COLOR_GRAD2, "Xe khong co tien phat chua nop."), CarOptions(playerid);
					if(GetGroupBudget(GetPVarInt(playerid, "CarGroup")) < CrateVehicle[carid][cvTickets]) return SendClientMessageEx(playerid, COLOR_GRAD2, "To chuc cua ban can $%s de nop phat.", number_format(CrateVehicle[carid][cvTickets])), CarOptions(playerid);
					SetGroupBudget(GetPVarInt(playerid, "CarGroup"), -CrateVehicle[carid][cvTickets]);
					SaveGroup(GetPVarInt(playerid, "CarGroup"));
					strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
					format(szMiscArray, sizeof(szMiscArray), "%s has paid total of $%s for all outstanding vehicle tickets on the %s", GetPlayerNameEx(playerid), number_format(CrateVehicle[carid][cvTickets]), vehicleName);
					GroupPayLog(GetPVarInt(playerid, "CarGroup"), szMiscArray);
					CrateVehicle[carid][cvTickets] = 0;
					SaveCrateVehicle(carid);
					foreach(new i: Player) {
						if(PlayerInfo[i][pLeader] == CrateVehicle[carid][cvGroupID]) {
							ChatTrafficProcess(i, arrGroupData[CrateVehicle[carid][cvGroupID]][g_hRadioColour] * 256 + 255, szMiscArray, CHAT_GROUP_RADIO);
						}
					}
					return CarOptions(playerid);
				}
			}
			case 2: {
				if(PlayerInfo[playerid][pAdmin] > 3 || PlayerInfo[playerid][pASM] > 0 || PlayerInfo[playerid][pFactionModerator] > 0) {
					if(!ValidGroup(CrateVehicle[carid][cvGroupID])) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the tam giu/chuoc xe khong thuoc to chuc nao!"), CarOptions(playerid);
					if(!CrateVehicle[carid][cvImpound]) {
						if(CrateVehicle[carid][cvSpawnID] != INVALID_VEHICLE_ID) {
							GetVehicleHealth(CrateVehicle[carid][cvSpawnID], vHealth);
							CrateVehicle[carid][cvHealth] = vHealth;
							CrateVehicle[carid][cvFuel] = VehicleFuel[CrateVehicle[carid][cvSpawnID]];
							if(CreateCount(carid) > 0) AnnounceRespawn(CrateVehicle[carid][cvGroupID], "tam giu boi admin", carid, CreateCount(carid));
							CancelCrateVehicleActions(carid);
							DestroyVehicle(CrateVehicle[carid][cvSpawnID]);
							CrateVehicle[carid][cvSpawned] = 0;
							CrateVehicle[carid][cvSpawnID] = INVALID_VEHICLE_ID;
						}
						CrateVehicle[carid][cvImpound] = 1;
						CrateVehCheck(carid);
						SaveCrateVehicle(carid);
						strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
						format(szMiscArray, sizeof(szMiscArray), "* Xe %s cua ban bi admin tam giu, ban co the chuoc tai garage. (( /cvstorage ))", vehicleName);
						foreach(new i: Player) {
							if(PlayerInfo[i][pLeader] == CrateVehicle[carid][cvGroupID]) {
								ChatTrafficProcess(i, arrGroupData[CrateVehicle[carid][cvGroupID]][g_hRadioColour] * 256 + 255, szMiscArray, CHAT_GROUP_RADIO);
							}
						}
						strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da tam giu xe cua %s: %s.", arrGroupData[CrateVehicle[carid][cvGroupID]][g_szGroupName], vehicleName);
						format(szMiscArray, sizeof(szMiscArray), "%s has impounded %s. (Veh id: %d | Owner: %s)", GetPlayerNameEx(playerid), vehicleName, CrateVehicle[carid][cvModel], arrGroupData[CrateVehicle[carid][cvGroupID]][g_szGroupName]);
						Log("logs/cratevehicle.log", szMiscArray);
						return CarOptions(playerid);
					} else {
						CrateVehicle[carid][cvImpound] = 0;
						CrateVehicle[carid][cvTickets] = 0;
				 		CrateVehicle[carid][cvSpawned] = 1;
				 		SpawnCrateVeh(carid);
				 		SaveCrateVehicle(carid);
						strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
						format(szMiscArray, sizeof(szMiscArray), "* Xe %s cua ban da duoc admin tra lai va do tai vi tri cu.", vehicleName);
						foreach(new i: Player) {
							if(PlayerInfo[i][pLeader] == CrateVehicle[carid][cvGroupID]) {
								ChatTrafficProcess(i, arrGroupData[CrateVehicle[carid][cvGroupID]][g_hRadioColour] * 256 + 255, szMiscArray, CHAT_GROUP_RADIO);
							}
						}
						strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
						SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da tra lai xe cua %s: %s.", arrGroupData[CrateVehicle[carid][cvGroupID]][g_szGroupName], vehicleName);
						format(szMiscArray, sizeof(szMiscArray), "%s has released vehicle %s. (Veh id: %d | Owner: %s)", GetPlayerNameEx(playerid), vehicleName, CrateVehicle[carid][cvModel], arrGroupData[CrateVehicle[carid][cvGroupID]][g_szGroupName]);
						Log("logs/cratevehicle.log", szMiscArray);
						return CarOptions(playerid);
					}
				}
				else {
					if(!CrateVehicle[carid][cvImpound]) {
						strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
						return SendClientMessageEx(playerid, COLOR_GRAD2, "Xe %s cua ban khong bi tam giu!", vehicleName), CarOptions(playerid);
					}
					new cost = (200000 + CrateVehicle[GetPVarInt(playerid, "CvStorageID")][cvTickets]);
					if(GetGroupBudget(GetPVarInt(playerid, "CarGroup")) < cost) return SendClientMessageEx(playerid, COLOR_GRAD2, "To chuc cua ban khong du $%s de chuoc xe nay.", number_format(cost)), CarOptions(playerid);
					SetGroupBudget(GetPVarInt(playerid, "CarGroup"), -cost);
					SaveGroup(GetPVarInt(playerid, "CarGroup"));
					strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
					format(szMiscArray, sizeof(szMiscArray), "%s has paid $%s to release vehicle %s from the impound.", GetPlayerNameEx(playerid), number_format(cost), vehicleName);
					GroupPayLog(GetPVarInt(playerid, "CarGroup"), szMiscArray);
					CrateVehicle[carid][cvImpound] = 0;
					CrateVehicle[carid][cvTickets] = 0;
			 		CrateVehicle[carid][cvSpawned] = 1;
			 		SpawnCrateVeh(carid);
			 		SaveCrateVehicle(carid);
					strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
					format(szMiscArray, sizeof(szMiscArray), "* Xe %s cua ban da duoc %s chuoc va do tai vi tri cu.", vehicleName, GetPlayerNameEx(playerid));
					foreach(new i: Player) {
						if(PlayerInfo[i][pLeader] == CrateVehicle[carid][cvGroupID]) {
							ChatTrafficProcess(i, arrGroupData[CrateVehicle[carid][cvGroupID]][g_hRadioColour] * 256 + 255, szMiscArray, CHAT_GROUP_RADIO);
						}
					}
					return CarOptions(playerid);
				}
			}
			case 3: {
				if(PlayerInfo[playerid][pAdmin] > 3 || PlayerInfo[playerid][pASM] > 0 || PlayerInfo[playerid][pFactionModerator] > 0) {
					if(!CrateVehicle[carid][cvDisabled]) {
						if(CrateVehicle[carid][cvSpawnID] != INVALID_VEHICLE_ID) {
							GetVehicleHealth(CrateVehicle[carid][cvSpawnID], vHealth);
							CrateVehicle[carid][cvHealth] = vHealth;
							CrateVehicle[carid][cvFuel] = VehicleFuel[CrateVehicle[carid][cvSpawnID]];
							if(CreateCount(carid) > 0) AnnounceRespawn(CrateVehicle[carid][cvGroupID], "vo hieu hoa boi admin", carid, CreateCount(carid));
							CancelCrateVehicleActions(carid);
							DestroyVehicle(CrateVehicle[carid][cvSpawnID]);
							CrateVehicle[carid][cvSpawned] = 0;
							CrateVehicle[carid][cvSpawnID] = INVALID_VEHICLE_ID;
						}
						CrateVehicle[carid][cvDisabled] = 1;
						CrateVehCheck(carid);
						SaveCrateVehicle(carid);
						if(ValidGroup(CrateVehicle[carid][cvGroupID])) {
							strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
							format(szMiscArray, sizeof(szMiscArray), "* Xe %s cua ban da bi admin vo hieu hoa, ban khong the dung xe.", vehicleName);
							foreach(new i: Player) {
								if(PlayerInfo[i][pLeader] == CrateVehicle[carid][cvGroupID]) {
									ChatTrafficProcess(i, arrGroupData[CrateVehicle[carid][cvGroupID]][g_hRadioColour] * 256 + 255, szMiscArray, CHAT_GROUP_RADIO);
								}
							}
							strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
							SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da vo hieu hoa xe cua %s: %s.", arrGroupData[CrateVehicle[carid][cvGroupID]][g_szGroupName], vehicleName);
							format(szMiscArray, sizeof(szMiscArray), "%s has disabled vehicle %s (Veh id: %d | Owner: %s)", GetPlayerNameEx(playerid), vehicleName, CrateVehicle[carid][cvModel], arrGroupData[CrateVehicle[carid][cvGroupID]][g_szGroupName]);
						}
						else {
							strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
							SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da vo hieu hoa %s. (Chua thuoc to chuc nao).", vehicleName), format(szMiscArray, sizeof(szMiscArray), "%s has re-enabled vehicle %s (Veh id: %d | Owner: N/A)", GetPlayerNameEx(playerid), vehicleName, CrateVehicle[carid][cvModel]);
						}
						Log("logs/cratevehicle.log", szMiscArray);
						return CarOptions(playerid);
					} else {
						CrateVehicle[carid][cvDisabled] = 0;
				 		CrateVehicle[carid][cvSpawned] = 1;
				 		SpawnCrateVeh(carid);
				 		SaveCrateVehicle(carid);
						if(ValidGroup(CrateVehicle[carid][cvGroupID])) {
							strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
							format(szMiscArray, sizeof(szMiscArray), "* Xe %s cua ban da duoc admin cho phep dung lai va do tai vi tri cu.", vehicleName);
							foreach(new i: Player) {
								if(PlayerInfo[i][pLeader] == CrateVehicle[carid][cvGroupID]) {
									ChatTrafficProcess(i, arrGroupData[CrateVehicle[carid][cvGroupID]][g_hRadioColour] * 256 + 255, szMiscArray, CHAT_GROUP_RADIO);
								}
							}
							strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
							SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da cho phep dung lai xe cua %s: %s, xe da duoc lay ra tai vi tri cu.", arrGroupData[CrateVehicle[carid][cvGroupID]][g_szGroupName], vehicleName);
							format(szMiscArray, sizeof(szMiscArray), "%s has re-enabled vehicle %s (Veh id: %d | Owner: %s)", GetPlayerNameEx(playerid), vehicleName, CrateVehicle[carid][cvModel], arrGroupData[CrateVehicle[carid][cvGroupID]][g_szGroupName]);
						}
						else {
							strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
							SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da cho phep dung lai %s, xe da duoc lay ra tai vi tri cu. (Chua thuoc to chuc nao).", vehicleName), format(szMiscArray, sizeof(szMiscArray), "%s has re-enabled vehicle %s (Veh id: %d | Owner: N/A)", GetPlayerNameEx(playerid), vehicleName, CrateVehicle[carid][cvModel]);
						}
						Log("logs/cratevehicle.log", szMiscArray);
						return CarOptions(playerid);
					}
				}
			}
			case 4: {
				if(PlayerInfo[playerid][pAdmin] > 3 || PlayerInfo[playerid][pASM] > 0 || PlayerInfo[playerid][pFactionModerator] > 0) {
					if(CrateVehicle[carid][cvSpawnID] == INVALID_VEHICLE_ID) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the do xang khi xe chua duoc lay ra!"), CarOptions(playerid);
					if(VehicleFuel[CrateVehicle[carid][cvSpawnID]] >= 100) return SendClientMessageEx(playerid, COLOR_GRAD2, "Xe da day xang, khong the do them."), CarOptions(playerid);
					VehicleFuel[CrateVehicle[carid][cvSpawnID]] = 100;
					strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
					SendClientMessageEx(playerid, COLOR_YELLOW, "Ban da nap lai nhien lieu cho %s ve 100.", vehicleName);
					if(ValidGroup(CrateVehicle[carid][cvGroupID])) {
						strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
						format(szMiscArray, sizeof(szMiscArray), "%s has refuled vehicle %s (Veh id: %d | Owner: %s)", GetPlayerNameEx(playerid), vehicleName, CrateVehicle[carid][cvModel], arrGroupData[CrateVehicle[carid][cvGroupID]][g_szGroupName]);
					}
					else {
						strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
						format(szMiscArray, sizeof(szMiscArray), "%s has refuled vehicle %s (Veh id: %d | Owner: %s)", GetPlayerNameEx(playerid), vehicleName, CrateVehicle[carid][cvModel]);
					}
					Log("logs/cratevehicle.log", szMiscArray);
					return CarOptions(playerid);
				}
			}
			case 5: {
				if(PlayerInfo[playerid][pAdmin] > 3 || PlayerInfo[playerid][pASM] > 0 || PlayerInfo[playerid][pFactionModerator] > 0) {
					strunpack(vehicleName, VehicleName[CrateVehicle[carid][cvModel] - 400], sizeof(vehicleName));
					format(szMiscArray, sizeof(szMiscArray), "Ban chac chan muon xoa %s?", vehicleName);
					Dialog_Show(playerid, confirm_delete_veh, DIALOG_STYLE_MSGBOX, "Ban chac chan?", szMiscArray, "Co", "Khong");
				}
			}
		}
	} else {
		DeletePVar(playerid, "CvStorageID");
		ListVehicles(playerid, GetPVarInt(playerid, "CarGroup"));
	}
	return 1;
}

Dialog:confirm_delete_veh(playerid, response, listitem, inputtext[]) {
	if(!GetPVarType(playerid, "CvStorageID") && !GetPVarType(playerid, "CarGroup")) return 1;
	if(response) {
		if(PlayerInfo[playerid][pAdmin] > 3 || PlayerInfo[playerid][pASM] > 0 || PlayerInfo[playerid][pFactionModerator] > 0) {
			DeleteCrateVehicle(playerid, GetPVarInt(playerid, "CvStorageID"));
			DeletePVar(playerid, "CvStorageID");
			ListVehicles(playerid, GetPVarInt(playerid, "CarGroup"));
		}
	} else {
		CarOptions(playerid);
	}
	return 1;
}

stock DeleteCrateVehicle(playerid, veh) {
	new vehicleName[18];
	szMiscArray[0] = 0;
	if(CrateVehicle[veh][cvSpawnID] != INVALID_VEHICLE_ID) {
		if(CreateCount(veh) > 0) AnnounceRespawn(CrateVehicle[veh][cvGroupID], "xoa boi admin", veh, CreateCount(veh));
		CancelCrateVehicleActions(veh);
		DestroyVehicle(CrateVehicle[veh][cvSpawnID]);
		CrateVehicle[veh][cvSpawned] = 0;
		CrateVehicle[veh][cvSpawnID] = INVALID_VEHICLE_ID;
	}
	CrateVehCheck(veh);
	if(ValidGroup(CrateVehicle[veh][cvGroupID])) {
		strunpack(vehicleName, VehicleName[CrateVehicle[veh][cvModel] - 400], sizeof(vehicleName));
		format(szMiscArray, sizeof(szMiscArray), "* Xe %s cua ban da bi admin xoa.", vehicleName);
		foreach(new i: Player) {
			if(PlayerInfo[i][pLeader] == CrateVehicle[veh][cvGroupID]) {
				ChatTrafficProcess(i, arrGroupData[CrateVehicle[veh][cvGroupID]][g_hRadioColour] * 256 + 255, szMiscArray, CHAT_GROUP_RADIO);
			}
		}
		strunpack(vehicleName, VehicleName[CrateVehicle[veh][cvModel] - 400], sizeof(vehicleName));
		SendClientMessageEx(playerid, COLOR_YELLOW, "Ban da xoa xe %s. (Chu so huu: %s)", vehicleName, arrGroupData[CrateVehicle[veh][cvGroupID]][g_szGroupName]);
		format(szMiscArray, sizeof(szMiscArray), "%s has deleted vehicle %s (Veh id: %d | Owner: %s)", GetPlayerNameEx(playerid), vehicleName, CrateVehicle[veh][cvModel], arrGroupData[CrateVehicle[veh][cvGroupID]][g_szGroupName]);
	}
	else {
		strunpack(vehicleName, VehicleName[CrateVehicle[veh][cvModel] - 400], sizeof(vehicleName));
		SendClientMessageEx(playerid, COLOR_YELLOW, "Ban da xoa xe %s. (Chua co chu)", vehicleName), format(szMiscArray, sizeof(szMiscArray), "%s has deleted vehicle %s (Veh id: %d | Owner: N/A)", GetPlayerNameEx(playerid), vehicleName, CrateVehicle[veh][cvModel]);
	}
	Log("logs/cratevehicle.log", szMiscArray);

    mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "DELETE FROM `crate_vehicles` WHERE `id` = %d", CrateVehicle[veh][cvId]);
	mysql_tquery(MainPipeline, szMiscArray, "OnQueryFinish", "i", SENDDATA_THREAD);

	VehDelivering[veh] = 0;
	CrateVehicle[veh][cvForkObject] = -1;
	CrateVehicle[veh][cvSpawnID] = INVALID_VEHICLE_ID;
	CrateVehicle[veh][cvId] = -1;
	CrateVehicle[veh][cvModel] = 0;
	CrateVehicle[veh][cvColor][0] = 0;
	CrateVehicle[veh][cvColor][1] = 0;
	CrateVehicle[veh][cvGroupID] = -1;
	CrateVehicle[veh][cvRank] = -1;
	CrateVehicle[veh][cvSpawned] = 0;
	CrateVehicle[veh][cvDisabled] = 0;
	CrateVehicle[veh][cvImpound] = 0;
	CrateVehicle[veh][cvTickets] = 0;
	CrateVehicle[veh][cvMaxHealth] = 1000;
	CrateVehicle[veh][cvHealth] = 1000;
	CrateVehicle[veh][cvFuel] = 100;
	CrateVehicle[veh][cvType] = 0;
	for(new p = 0; p < 4; p++) CrateVehicle[veh][cvPos][p] = 0.0;
	CrateVehicle[veh][cvInt] = 0;
	CrateVehicle[veh][cvVw] = 0;
	CrateVehicle[veh][cvCrateMax] = 0;
	CrateVehicle[veh][cvCrate] = -1;
	CrateVehicle[veh][cvCrateLoad] = 0;
	--CrateVehTotal;
	return 1;
}

CMD:cvedit(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] > 3 || PlayerInfo[playerid][pASM] > 0 || PlayerInfo[playerid][pFactionModerator] > 0) {
		new vehicleName[18];
		szMiscArray[0] = 0;
		new choice[32], vehid, value, cveh;
		if(sscanf(params, "is[32]D(-1)", vehid, choice, value))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /crate [vehid] [name] [value]");
			SendClientMessageEx(playerid, COLOR_GREY, "Tuy chon: model, col1, col2, groupid, rank, maxhealth, loadmax, disable, delete");
			SendClientMessageEx(playerid, COLOR_GREY, "Tuy chon: refuel");
			SendClientMessageEx(playerid, COLOR_GREY, "LUU Y: Dat groupid thanh -1 de cho phep moi to chuc dung xe.");
			return 1;
		}
		if((cveh = IsDynamicCrateVehicle(vehid)) == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Xe da chon khong phai xe cho thung!");
		if(strcmp(choice, "model", true) == 0) {
			if(!(400 <= value < 612)) return SendClientMessageEx(playerid, COLOR_GREY, "Model xe khong hop le!");
			CrateVehicle[cveh][cvModel] = value;
			SaveCrateVehicle(cveh);
			SpawnCrateVeh(cveh);
			strunpack(vehicleName, VehicleName[value - 400], sizeof(vehicleName));
			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi xe thanh %s", vehicleName);
		}
		else if(strcmp(choice, "col1", true) == 0) {
			if(!(0 <= value <= 255)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Mau khong hop le (ID tu 0 den 255).");
			CrateVehicle[cveh][cvColor][0] = value;
			SaveCrateVehicle(cveh);
			SpawnCrateVeh(cveh);
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da doi mau (1) cua xe cho thung.");
		}
		else if(strcmp(choice, "col2", true) == 0) {
			if(!(0 <= value <= 255)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Mau khong hop le (ID tu 0 den 255).");
			CrateVehicle[cveh][cvColor][1] = value;
			SaveCrateVehicle(cveh);
			SpawnCrateVeh(cveh);
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da doi mau (2) cua xe cho thung.");
		}
		else if(strcmp(choice, "groupid", true) == 0) {
			if(value != -1 && !ValidGroup(value)) return SendClientMessageEx(playerid, COLOR_GREY, "ID to chuc khong hop le! (0 - 39) | Khong thuoc to chuc = -1");
			CrateVehicle[cveh][cvGroupID] = value;
			if(value == -1) CrateVehicle[cveh][cvRank] = -1;
			SaveCrateVehicle(cveh);
			if(value != -1) {
				SendClientMessageEx(playerid, COLOR_WHITE, "Ban da giao xe cho %s.", arrGroupData[value][g_szGroupName]);
			} else {
				SendClientMessageEx(playerid, COLOR_WHITE, "Ban da cho phep moi thanh vien to chuc dung xe!");
			}
		}
		else if(strcmp(choice, "rank", true) == 0) {
			if(value != -1 && !(0 <= value < 10)) return SendClientMessageEx(playerid, COLOR_GREY, "ID hang khong hop le! (0 - 9) | Khong gioi han hang = -1");
			CrateVehicle[cveh][cvRank] = value;
			SaveCrateVehicle(cveh);
			if(value != -1) {
				SendClientMessageEx(playerid, COLOR_WHITE, "Ban da gioi han xe cho hang %d tro len.", value);
			} else {
				SendClientMessageEx(playerid, COLOR_WHITE, "Ban da bo gioi han hang cho xe nay!");
			}
		}
		else if(strcmp(choice, "maxhealth", true) == 0) {
			if(value < 1000) return SendClientMessageEx(playerid, COLOR_GREY, "Do ben toi da cua xe khong duoc duoi 1,000!");
			CrateVehicle[cveh][cvMaxHealth] = value;
			SaveCrateVehicle(cveh);
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da dat do ben toi da cua xe thanh %s", number_format(value));
		}
		else if(strcmp(choice, "loadmax", true) == 0) {
			if(value < 0) return SendClientMessageEx(playerid, COLOR_GREY, "So thung toi da khong duoc duoi 0, dat 0 de vo hieu hoa!");
			CrateVehicle[cveh][cvCrateMax] = value;
			SaveCrateVehicle(cveh);
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da dat so thung toi da cua xe thanh %d", value);
		}
		else if(strcmp(choice, "disable", true) == 0) {
			new Float:vHealth;
			if(!CrateVehicle[cveh][cvDisabled]) {
				if(CrateVehicle[cveh][cvSpawnID] != INVALID_VEHICLE_ID) {
					GetVehicleHealth(CrateVehicle[cveh][cvSpawnID], vHealth);
					CrateVehicle[cveh][cvHealth] = vHealth;
					CrateVehicle[cveh][cvFuel] = VehicleFuel[CrateVehicle[cveh][cvSpawnID]];
					if(CreateCount(cveh) > 0) AnnounceRespawn(CrateVehicle[cveh][cvGroupID], "vo hieu hoa boi admin", cveh, CreateCount(cveh));
					CancelCrateVehicleActions(cveh);
					DestroyVehicle(CrateVehicle[cveh][cvSpawnID]);
					CrateVehicle[cveh][cvSpawned] = 0;
					CrateVehicle[cveh][cvSpawnID] = INVALID_VEHICLE_ID;
				}
				CrateVehicle[cveh][cvDisabled] = 1;
				CrateVehCheck(cveh);
				SaveCrateVehicle(cveh);
				if(ValidGroup(CrateVehicle[cveh][cvGroupID])) {
					strunpack(vehicleName, VehicleName[CrateVehicle[cveh][cvModel] - 400], sizeof(vehicleName));
					format(szMiscArray, sizeof(szMiscArray), "* Xe %s cua ban da bi admin vo hieu hoa, ban khong the dung xe.", vehicleName);
					foreach(new i: Player) {
						if(PlayerInfo[i][pLeader] == CrateVehicle[cveh][cvGroupID]) {
							ChatTrafficProcess(i, arrGroupData[CrateVehicle[cveh][cvGroupID]][g_hRadioColour] * 256 + 255, szMiscArray, CHAT_GROUP_RADIO);
						}
					}
					strunpack(vehicleName, VehicleName[CrateVehicle[cveh][cvModel] - 400], sizeof(vehicleName));
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da tam giu xe cua %s: %s.", arrGroupData[CrateVehicle[cveh][cvGroupID]][g_szGroupName], vehicleName);
					format(szMiscArray, sizeof(szMiscArray), "%s has disabled vehicle %s (Veh id: %d | Owner: %s)", GetPlayerNameEx(playerid), vehicleName, CrateVehicle[cveh][cvModel], arrGroupData[CrateVehicle[cveh][cvGroupID]][g_szGroupName]);
				}
				else {
					strunpack(vehicleName, VehicleName[CrateVehicle[cveh][cvModel] - 400], sizeof(vehicleName));
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da vo hieu hoa %s. (Chua thuoc to chuc nao).", vehicleName), format(szMiscArray, sizeof(szMiscArray), "%s has re-enabled vehicle %s (Veh id: %d | Owner: N/A)", GetPlayerNameEx(playerid), vehicleName, CrateVehicle[cveh][cvModel]);
				}
				Log("logs/cratevehicle.log", szMiscArray);
			}
			else SendClientMessageEx(playerid, COLOR_GRAD2, "Xe nay khong the bi vo hieu hoa!");
		}
		else if(strcmp(choice, "delete", true) == 0) {
			DeleteCrateVehicle(playerid, cveh);
		}
		else SendClientMessageEx(playerid, COLOR_GREY, "Lua chon khong hop le!");
	} else {
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay!");
	}
	return 1;
}

CMD:cvpark(playerid, params[]) {
	new veh, string[128];
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban phai ngoi trong xe muon do!");
	if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessageEx(playerid, COLOR_RED, "Ban khong ngoi ghe lai!");
	if((veh = IsDynamicCrateVehicle(GetPlayerVehicleID(playerid))) == -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong the do xe nay!");
	if(PlayerInfo[playerid][pAdmin] > 3 || PlayerInfo[playerid][pASM] > 0 || PlayerInfo[playerid][pFactionModerator] > 0 || IsGroupLeader(playerid) && PlayerInfo[playerid][pMember] == CrateVehicle[veh][cvGroupID]) {
		new vehicleName[18];
		GetVehiclePos(GetPlayerVehicleID(playerid), CrateVehicle[veh][cvPos][0], CrateVehicle[veh][cvPos][1], CrateVehicle[veh][cvPos][2]);
		GetVehicleZAngle(GetPlayerVehicleID(playerid), CrateVehicle[veh][cvPos][3]);
		CrateVehicle[veh][cvVw] = GetPlayerVirtualWorld(playerid);
		CrateVehicle[veh][cvInt] = GetPlayerInterior(playerid);
		strunpack(vehicleName, VehicleName[CrateVehicle[veh][cvModel] - 400], sizeof(vehicleName));
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban da do %s tai vi tri moi.", vehicleName);
		SaveCrateVehicle(veh);
		SurfingCheck(GetPlayerVehicleID(playerid));
		SpawnCrateVeh(veh);
		IsPlayerEntering{playerid} = true;
		PutPlayerInVehicle(playerid, GetPlayerVehicleID(playerid), 0);
		SetPlayerArmedWeapon(playerid, 0);
		strunpack(vehicleName, VehicleName[CrateVehicle[veh][cvModel] - 400], sizeof(vehicleName));
		format(string, sizeof(string), "* %s da do %s.", GetPlayerNameEx(playerid), vehicleName);
		ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	}
	else SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the do xe khong thuoc to chuc cua ban!");
	return 1;
}

CMD:cvcheck(playerid, params[]) {
	if(ValidGroup(PlayerInfo[playerid][pMember]) || PlayerInfo[playerid][pAdmin] > 1) {
		new Float:vPos[3], VehFound = -1;
		for(new i = 0; i < MAX_CRATE_VEHCILES; i++) {
			if(CrateVehicle[i][cvSpawnID] != INVALID_VEHICLE_ID) {
				GetPosBehindVehicle(CrateVehicle[i][cvSpawnID], vPos[0], vPos[1], vPos[2], (IsAPlane(CrateVehicle[i][cvSpawnID]) ? -8 : 0));
				if(IsPlayerInRangeOfPoint(playerid, (IsAPlane(CrateVehicle[i][cvSpawnID]) ? 6 : 2), vPos[0], vPos[1], vPos[2])) {
					VehFound = i; // Do not use the vehicle ID as we store the array ID for the validation since vehicles do not store "spawn id".
					break;
				}
			}
		}
		if(VehFound == -1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong o gan xe co the cho thung.");
		if(CrateVehicle[VehFound][cvCrateMax] < 1) {
			return SendClientMessageEx(playerid, COLOR_GRAD3, "Xe \"%s\" khong the cho thung.", GetVehicleName(CrateVehicle[VehFound][cvSpawnID]));
		}
		if(VehDelivering[VehFound]) return SendClientMessageEx(playerid, COLOR_GRAD3, "Xe dang do thung hang, vui long cho!");
		if(!CreateCount(VehFound)) {
			return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Khong co thung nao trong %s", GetVehicleName(CrateVehicle[VehFound][cvSpawnID]));
		}
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Xe %s hien dang cho %d thung.", GetVehicleName(CrateVehicle[VehFound][cvSpawnID]), CreateCount(VehFound));
	}
	else SendClientMessageEx(playerid, COLOR_GRAD2, "Ban phai thuoc mot to chuc de dung lenh nay!"); 
	return 1;
}

CMD:cvstatus(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] > 3 || PlayerInfo[playerid][pASM] > 0 || PlayerInfo[playerid][pFactionModerator] > 0) {
		new vehicleid, veh;
		if(sscanf(params, "i", vehicleid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /cvstatus [vehicleid]");
		if((veh = IsDynamicCrateVehicle(vehicleid)) != -1) {
			new string[128], Float:vHealth;
			GetVehicleHealth(vehicleid, vHealth);
			SendClientMessageEx(playerid, COLOR_GREEN, "|___________ Trang thai xe cho thung (ID: %d | Slot ID: %d) ___________|", vehicleid, veh);
			SendClientMessageEx(playerid, COLOR_WHITE, "X: %f | Y: %f | Z: %f | VW: %d | Int: %d | Model: %d  Ben max: %.1f", CrateVehicle[veh][cvPos][0], CrateVehicle[veh][cvPos][1], CrateVehicle[veh][cvPos][2], CrateVehicle[veh][cvVw], CrateVehicle[veh][cvInt], CrateVehicle[veh][cvModel], CrateVehicle[veh][cvMaxHealth]);
			if(ValidGroup(CrateVehicle[veh][cvGroupID])) {
				format(string, sizeof(string), "To chuc: %s (%d) | Hang: %d | Phat: $%s | Thung max: %d", arrGroupData[CrateVehicle[veh][cvGroupID]][g_szGroupName], CrateVehicle[veh][cvGroupID], CrateVehicle[veh][cvRank], number_format(CrateVehicle[veh][cvTickets]), CrateVehicle[veh][cvCrateMax]);
			} else {
				format(string, sizeof(string), "To chuc: -- | Hang: -- | Tien phat: -- | So thung toi da: %d", CrateVehicle[veh][cvCrateMax]);
			}
			SendClientMessageEx(playerid, COLOR_WHITE, string);
			SendClientMessageEx(playerid, COLOR_WHITE, "Thung: %d | Do ben: %.1f | Nhien lieu: %.1f percent", CreateCount(veh), vHealth, VehicleFuel[vehicleid]);
		}
		else {
			SendClientMessageEx(playerid, COLOR_GREY, "Xe da chon khong phai xe cho thung!");
		}
	} else {
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay!");
	}
	return 1;
}

CMD:cvrespawn(playerid, params[]) {
	szMiscArray[0] = 0;
	if(PlayerInfo[playerid][pAdmin] > 3 || PlayerInfo[playerid][pASM] > 0 || PlayerInfo[playerid][pFactionModerator] > 0) {
		if(isnull(params)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /cvrespawn [Group/All]");
		if(strcmp(params, "all", true) == 0) {
			for(new v = 0; v < MAX_CRATE_VEHCILES; v++) {
				if(CrateVehicle[v][cvSpawnID] != INVALID_VEHICLE_ID) {
					if(!IsVehicleSeatOccupied(CrateVehicle[v][cvSpawnID]) && !CreateCount(v)) {
						SpawnCrateVeh(v);
					}
				}
			}
			format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s da tao lai tat ca xe cho thung dynamic tren may chu.", GetPlayerNameEx(playerid));
			ABroadCast(COLOR_YELLOW, szMiscArray, 2);
			format(szMiscArray, sizeof(szMiscArray), "Administrator %s has respawned all dynamic crate vehicles loaded on the server.", GetPlayerNameEx(playerid));
			Log("logs/admin.log", szMiscArray);
		} else {
			if(strval(params) != -1) {
				if(!IsNumericString(params)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Du lieu khong hop le, vui long nhap so!");
				if(!ValidGroup(strval(params))) return SendClientMessageEx(playerid, COLOR_GRAD2, "ID to chuc khong hop le (chi tu 0 - %d)", MAX_GROUPS);
				format(szMiscArray, sizeof(szMiscArray), "** Dang tao lai tat ca xe cho thung dynamic cua to chuc...");
				foreach(new i: Player) {
					if(PlayerInfo[i][pMember] == strval(params)) {
						SendClientMessageEx(i, arrGroupData[strval(params)][g_hRadioColour] * 256 + 255, szMiscArray);
					}
				}
			}
			for(new v = 0; v < MAX_CRATE_VEHCILES; v++) {
				if(CrateVehicle[v][cvSpawnID] != INVALID_VEHICLE_ID && CrateVehicle[v][cvGroupID] == strval(params)) {
					if(!IsVehicleSeatOccupied(CrateVehicle[v][cvSpawnID]) && !CreateCount(v)) {
						SpawnCrateVeh(v);
					}
				}
			}
			if(strval(params) != -1) {
				format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s da tao lai xe cho thung dynamic cua %s.", GetPlayerNameEx(playerid), arrGroupData[strval(params)][g_szGroupName]);
				ABroadCast(COLOR_YELLOW, szMiscArray, 2);
				format(szMiscArray, sizeof(szMiscArray), "Administrator %s has respawned %s's (%d) dynamic crate vehicles.", GetPlayerNameEx(playerid), arrGroupData[strval(params)][g_szGroupName], strval(params));
				Log("logs/admin.log", szMiscArray);
			}
			else {
				format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s da tao lai xe cho thung dynamic chua co chu.", GetPlayerNameEx(playerid));
				ABroadCast(COLOR_YELLOW, szMiscArray, 2);
				format(szMiscArray, sizeof(szMiscArray), "Administrator %s has respawned unowned (-1) dynamic crate vehicles.", GetPlayerNameEx(playerid));
				Log("logs/admin.log", szMiscArray);
			}
		}

	}
	return 1;
}
