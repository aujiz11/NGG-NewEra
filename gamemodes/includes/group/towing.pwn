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
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen tam giu xe.");
	
	new 
		group = PlayerInfo[playerid][pMember], 
		truck = GetPlayerVehicleID(playerid);
	
	if(!ValidGroup(group) || PlayerBusy(playerid) || PlayerTied[playerid] || PlayerInfo[playerid][pJailTime]) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the tam giu xe luc nay.");
	
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER || !(0 < truck < MAX_VEHICLES) || !IsValidVehicle(truck)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai lai xe dang keo xe cua nghi pham.");
	
	if(!IsAtImpoundingPoint(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan diem tam giu xe.");
	
	if(!IsTrailerAttachedToVehicle(truck)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong keo xe nao.");
	
	new target = GetVehicleTrailer(truck);
	if(!(0 < target < MAX_VEHICLES) || target == truck || !IsValidVehicle(target)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Xe dang keo khong con ton tai.");
	
	if(GetVehicleVirtualWorld(target) != GetPlayerVirtualWorld(playerid) || GetVehicleInterior(target) != GetPlayerInterior(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Xe dang keo khong o cung world va interior voi ban.");
	
	foreach(new i : Player) {
		if(GetPlayerVehicleID(i) == target) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the tam giu xe dang co nguoi.");
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
			return SendClientMessageEx(playerid, COLOR_GREY, "Dang ky xe nay khong kha dung de tam giu.");
		}
		
		price = PlayerVehicleInfo[owner][slot][pvPrice];
		tickets = PlayerVehicleInfo[owner][slot][pvTicket];
		format(ownerName, sizeof ownerName, "%s", GetPlayerNameEx(owner));
	}
	else if((crate = IsDynamicCrateVehicle(target)) != -1) {
		if(!(0 <= crate < MAX_CRATE_VEHCILES) || !ValidGroup(CrateVehicle[crate][cvGroupID]) || !CrateVehicle[crate][cvSpawned] || CrateVehicle[crate][cvImpound] || CrateVehicle[crate][cvModel] != GetVehicleModel(target)) 
		{
			return SendClientMessageEx(playerid, COLOR_GREY, "Dang ky xe crate nay khong kha dung de tam giu.");
		}
		
		if(group == CrateVehicle[crate][cvGroupID]) 
			return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Day la xe cua to chuc ban, khong the tam giu.");
		
		price = 2000000;
		tickets = CrateVehicle[crate][cvTickets];
		format(ownerName, sizeof ownerName, "%s", arrGroupData[CrateVehicle[crate][cvGroupID]][g_szGroupName]);
	}
	else {
		foreach(new i : Player) if(arr_Towing[i] == target) arr_Towing[i] = INVALID_VEHICLE_ID;
		arr_Towing[playerid] = INVALID_VEHICLE_ID;
		DetachTrailerFromVehicle(truck);
		SetVehicleToRespawn(target);
		return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban quan ly bai giu xe khong tim thay dang ky va da tra xe.");
	}

	new reward = Towing_GetReward(price, tickets);
	if(reward < 0 || arrGroupData[group][g_iBudget] > cellmax - reward) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Khong the cong tien thuong an toan. Chua tam giu xe nao.");
	
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
		SendClientMessageEx(owner, COLOR_LIGHTBLUE, "Xe %s cua ban bi tam giu. Den DMV tai Dillimore de lay xe.", vehicleName);
	}
	else {
		GetVehicleHealth(target, CrateVehicle[crate][cvHealth]);
		CrateVehicle[crate][cvFuel] = VehicleFuel[target];
		CrateVehicle[crate][cvImpound] = 1;
		CancelCrateVehicleActions(crate);
		new count = CreateCount(crate);
		if(count > 0) AnnounceRespawn(CrateVehicle[crate][cvGroupID], "tam giu", crate, count);
		DestroyVehicle(target);
		CrateVehicle[crate][cvSpawned] = 0;
		CrateVehicle[crate][cvSpawnID] = INVALID_VEHICLE_ID;
		CrateVehCheck(crate);
		SaveCrateVehicle(crate);
		foreach(new i : Player) {
			if(PlayerInfo[i][pLeader] == CrateVehicle[crate][cvGroupID]) ChatTrafficProcess(i, arrGroupData[CrateVehicle[crate][cvGroupID]][g_hRadioColour] * 256 + 255, "Xe to chuc cua ban bi tam giu. Dung /cvstorage de lay xe.", CHAT_GROUP_RADIO);
		}
	}
	SetGroupBudget(group, reward);
	SaveGroup(group);
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da tam giu xe cua %s: %s.", ownerName, vehicleName);
	new message[160];
	format(message, sizeof message, "HQ: %s tam giu xe cua %s: %s ($%s phat chua tra).", GetPlayerNameEx(playerid), ownerName, vehicleName, number_format(tickets));
	SendGroupMessage(arrGroupData[group][g_iGroupType], RADIO, message);
	format(message, sizeof message, "IMPOUND: %s has impounded %s's %s and gained $%s.", GetPlayerNameEx(playerid), ownerName, vehicleName, number_format(reward));
	GroupLog(group, message);
	return 1;
}