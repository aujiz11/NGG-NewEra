/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Towing Group Type

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

stock Towing_GetReward(price, tickets) {
	if(price < 0 || tickets < 0 || tickets > cellmax - price / 20) return -1;
	return ((price / 20 + tickets) / 100) * 30;
}

CMD:impound(playerid, params[]) {
	if(!IsACop(playerid) && !IsATowman(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "You are not authorized to impound vehicles.");
	
	new 
		group = PlayerInfo[playerid][pMember], 
		truck = GetPlayerVehicleID(playerid);
	
	if(!ValidGroup(group) || PlayerBusy(playerid) || PlayerTied[playerid] || PlayerInfo[playerid][pJailTime]) 
		return SendClientMessageEx(playerid, COLOR_GREY, "You cannot impound a vehicle right now.");
	
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER || !(0 < truck < MAX_VEHICLES) || !IsValidVehicle(truck)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "You must be driving the vehicle that is towing the suspect vehicle.");
	
	if(!IsAtImpoundingPoint(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "You are not near an impound point.");
	
	if(!IsTrailerAttachedToVehicle(truck)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "You are not towing a vehicle.");
	
	new target = GetVehicleTrailer(truck);
	if(!(0 < target < MAX_VEHICLES) || target == truck || !IsValidVehicle(target)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "The vehicle in tow is no longer available.");
	
	if(GetVehicleVirtualWorld(target) != GetPlayerVirtualWorld(playerid) || GetVehicleInterior(target) != GetPlayerInterior(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "The towed vehicle is not in your world and interior.");
	
	foreach(new i : Player) {
		if(GetPlayerVehicleID(i) == target) return SendClientMessageEx(playerid, COLOR_GREY, "You cannot impound an occupied vehicle.");
	}

	new owner = INVALID_PLAYER_ID, slot = -1, crate = -1, price, tickets, vehicleName[18], ownerName[GROUP_MAX_NAME_LEN];
	foreach(new i : Player) {
		if((slot = GetPlayerVehicle(i, target)) != -1) {
			owner = i;
			break;
		}
	}
	if(owner != INVALID_PLAYER_ID) {
		if(!gPlayerLogged{owner} || GetPVarInt(owner, "PropertySaleUncertain") || PlayerVehicleInfo[owner][slot][pvImpounded] || !PlayerVehicleInfo[owner][slot][pvSpawned] || PlayerVehicleInfo[owner][slot][pvModelId] != GetVehicleModel(target)) 
		{
			return SendClientMessageEx(playerid, COLOR_GREY, "This vehicle's registration is not available for impounding.");
		}
		
		price = PlayerVehicleInfo[owner][slot][pvPrice];
		tickets = PlayerVehicleInfo[owner][slot][pvTicket];
		format(ownerName, sizeof ownerName, "%s", GetPlayerNameEx(owner));
	}
	else if((crate = IsDynamicCrateVehicle(target)) != -1) {
		if(!(0 <= crate < MAX_CRATE_VEHCILES) || !ValidGroup(CrateVehicle[crate][cvGroupID]) || !CrateVehicle[crate][cvSpawned] || CrateVehicle[crate][cvImpound] || CrateVehicle[crate][cvModel] != GetVehicleModel(target)) 
		{
			return SendClientMessageEx(playerid, COLOR_GREY, "This crate vehicle's registration is not available for impounding.");
		}
		
		if(group == CrateVehicle[crate][cvGroupID]) 
			return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Your group owns this vehicle. You cannot impound it.");
		
		price = 2000000;
		tickets = CrateVehicle[crate][cvTickets];
		format(ownerName, sizeof ownerName, "%s", arrGroupData[CrateVehicle[crate][cvGroupID]][g_szGroupName]);
	}
	else {
		foreach(new i : Player) if(arr_Towing[i] == target) arr_Towing[i] = INVALID_VEHICLE_ID;
		arr_Towing[playerid] = INVALID_VEHICLE_ID;
		DetachTrailerFromVehicle(truck);
		SetVehicleToRespawn(target);
		return SendClientMessageEx(playerid, COLOR_GRAD1, "The impound administration could not find a registration and has returned the vehicle.");
	}

	new reward = Towing_GetReward(price, tickets);
	if(reward < 0 || arrGroupData[group][g_iBudget] > cellmax - reward) 
		return SendClientMessageEx(playerid, COLOR_GREY, "The impound reward cannot be credited safely. No vehicle was impounded.");
	
	vehicleName = GetVehicleName(target);
	foreach(new i : Player) if(arr_Towing[i] == target) arr_Towing[i] = INVALID_VEHICLE_ID;
	arr_Towing[playerid] = INVALID_VEHICLE_ID;
	DetachTrailerFromVehicle(truck);

	if(owner != INVALID_PLAYER_ID) {
		PlayerVehicleInfo[owner][slot][pvImpounded] = 1;
		PlayerVehicleInfo[owner][slot][pvSpawned] = 0;
		PlayerVehicleInfo[owner][slot][pvFuel] = VehicleFuel[target];
		GetVehicleHealth(target, PlayerVehicleInfo[owner][slot][pvHealth]);
		if(IsValidDynamicArea(iVehEnterAreaID[target])) DestroyDynamicArea(iVehEnterAreaID[target]);
		iVehEnterAreaID[target] = INVALID_STREAMER_ID;
		DestroyVehicle(target);
		PlayerVehicleInfo[owner][slot][pvId] = INVALID_PLAYER_VEHICLE_ID;
		if(PlayerCars > 0) --PlayerCars;
		if(VehicleSpawned[owner] > 0) --VehicleSpawned[owner];
		g_mysql_SaveVehicle(owner, slot);
		SendClientMessageEx(owner, COLOR_LIGHTBLUE, "Your %s has been impounded. You may release it at the DMV in Dillimore.", vehicleName);
	}
	else {
		GetVehicleHealth(target, CrateVehicle[crate][cvHealth]);
		CrateVehicle[crate][cvFuel] = VehicleFuel[target];
		CrateVehicle[crate][cvImpound] = 1;
		CancelCrateVehicleActions(crate);
		new count = CreateCount(crate);
		if(count > 0) AnnounceRespawn(CrateVehicle[crate][cvGroupID], "impounded", crate, count);
		DestroyVehicle(target);
		CrateVehicle[crate][cvSpawned] = 0;
		CrateVehicle[crate][cvSpawnID] = INVALID_VEHICLE_ID;
		CrateVehCheck(crate);
		SaveCrateVehicle(crate);
		foreach(new i : Player) {
			if(PlayerInfo[i][pLeader] == CrateVehicle[crate][cvGroupID]) ChatTrafficProcess(i, arrGroupData[CrateVehicle[crate][cvGroupID]][g_hRadioColour] * 256 + 255, "Your group vehicle has been impounded. Recover it with /cvstorage.", CHAT_GROUP_RADIO);
		}
	}
	SetGroupBudget(group, reward);
	SaveGroup(group);
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have impounded %s's %s.", ownerName, vehicleName);
	new message[160];
	format(message, sizeof message, "HQ: %s has impounded %s's %s ($%s unpaid tickets).", GetPlayerNameEx(playerid), ownerName, vehicleName, number_format(tickets));
	SendGroupMessage(arrGroupData[group][g_iGroupType], RADIO, message);
	format(message, sizeof message, "IMPOUND: %s has impounded %s's %s and gained $%s.", GetPlayerNameEx(playerid), ownerName, vehicleName, number_format(reward));
	GroupLog(group, message);
	return 1;
}