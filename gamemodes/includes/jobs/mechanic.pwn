/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Mechanic System

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

stock bool:Mechanic_CanFix(playerid)
{
	if(PlayerInfo[playerid][pJob] == 7 || PlayerInfo[playerid][pJob2] == 7 || PlayerInfo[playerid][pJob3] == 7) return true;
	new businessid = PlayerInfo[playerid][pBusiness];
	return 0 <= businessid < MAX_BUSINESSES && Businesses[businessid][bType] == BUSINESS_TYPE_MECHANIC && InBusiness(playerid) == businessid;
}

stock bool:Mechanic_NearVehicle(playerid, vehicleid, Float:range)
{
	return 0 < vehicleid < MAX_VEHICLES && IsValidVehicle(vehicleid)
		&& GetPlayerVirtualWorld(playerid) == GetVehicleVirtualWorld(vehicleid)
		&& GetPlayerInterior(playerid) == GetVehicleInterior(vehicleid)
		&& IsPlayerInRangeOfVehicle(playerid, vehicleid, range);
}

stock Float:Mechanic_RefillAmount(skill)
{
	switch(skill)
	{
		case 0 .. 49: return 2.0;
		case 50 .. 99: return 4.0;
		case 100 .. 199: return 6.0;
		case 200 .. 399: return 8.0;
	}
	return 10.0;
}

stock Mechanic_CancelFix(playerid, bool:restore = true)
{
	if(!GetPVarType(playerid, "FixVehicleTimer")) return 0;
	KillTimer(GetPVarInt(playerid, "FixVehicleTimer"));
	DeletePVar(playerid, "FixVehicleTimer");
	DeletePVar(playerid, "FixVehicleID");
	if(restore && !PlayerIsDead[playerid]
		&& !GetPVarType(playerid, "PlayerCuffed") && !GetPVarInt(playerid, "pBagged")
		&& !GetPVarType(playerid, "Injured") && !GetPVarType(playerid, "IsFrozen"))
	{
		TogglePlayerControllable(playerid, true);
		if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
		{
			ClearAnimationsEx(playerid);
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
		}
	}
	return 1;
}

stock Mechanic_ClearVehicleWork(playerid, vehicleid)
{
	if(!(0 < vehicleid < MAX_VEHICLES)) return 0;
	if(GetPVarInt(playerid, "FixVehicleID") == vehicleid) Mechanic_CancelFix(playerid);
	if(RepairCar[playerid] == vehicleid)
	{
		RepairOffer[playerid] = INVALID_PLAYER_ID;
		RepairPrice[playerid] = 0;
		RepairCar[playerid] = 0;
		DeletePVar(playerid, "RepairOfferSession");
	}
	if(GetPVarInt(playerid, "RefillVehicle") == vehicleid)
	{
		RefillOffer[playerid] = INVALID_PLAYER_ID;
		RefillPrice[playerid] = 0;
		DeletePVar(playerid, "RefillVehicle");
		DeletePVar(playerid, "RefillOfferSession");
	}
	return 1;
}

CMD:fix(playerid, params[])
{
	if(!Mechanic_CanFix(playerid)) 
		return SendClientMessageEx(playerid, COLOR_WHITE, "You are not a Mechanic!");

	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) 
		return SendClientMessageEx(playerid, COLOR_GRAD1, "You can not repair while inside the vehicle.");
	
	if(gettime() < PlayerInfo[playerid][pMechTime]) 
		return SendClientMessageEx(playerid, COLOR_GRAD1, "You must wait %d seconds!", PlayerInfo[playerid][pMechTime]-gettime());
	
	if(GetPVarType(playerid, "IsInArena") || GetPVarInt(playerid, "EventToken"))
	 	return SendClientMessageEx(playerid, COLOR_WHITE, "You can't do this while in an arena or event.");
	
	if(PlayerIsDead[playerid] || PlayerInfo[playerid][pHospital] > 0 || GetPVarType(playerid, "PlayerCuffed") || GetPVarInt(playerid, "pBagged") >= 1 || GetPVarType(playerid, "Injured") || GetPVarType(playerid, "IsFrozen"))
		return SendClientMessageEx(playerid, COLOR_GRAD2, "You can't do that at this time!");
	
	if(GetPVarType(playerid, "FixVehicleTimer")) 
		return SendClientMessageEx(playerid, COLOR_GRAD2, "You are already fixing a vehicle!");
	
	new closestcar = INVALID_VEHICLE_ID, world = GetPlayerVirtualWorld(playerid), interior = GetPlayerInterior(playerid);
	new Float:nearest = 10.0, Float:X, Float:Y, Float:Z;
	for(new vehicleid = 1; vehicleid < MAX_VEHICLES; ++vehicleid)
	{
		if(!IsValidVehicle(vehicleid) || GetVehicleVirtualWorld(vehicleid) != world || GetVehicleInterior(vehicleid) != interior) continue;
		GetVehiclePos(vehicleid, X, Y, Z);
		new Float:distance = GetPlayerDistanceFromPoint(playerid, X, Y, Z);
		if(distance <= 10.0 && (closestcar == INVALID_VEHICLE_ID || distance < nearest))
		{
			closestcar = vehicleid;
			nearest = distance;
		}
	}
	if(closestcar == INVALID_VEHICLE_ID) return SendClientMessageEx(playerid, COLOR_GRAD1, "You are not close enough to any vehicle.");
	new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(closestcar, engine, lights, alarm, doors, bonnet, boot, objective);
	if(!IsABike(closestcar) && !IsAPlane(closestcar) && bonnet != VEHICLE_PARAMS_ON)
		return SendClientMessageEx(playerid, COLOR_GRAD1, "The vehicle hood must be opened in order to repair it.");
	new repairDelay = PlayerInfo[playerid][pMechSkill] >= 400 ? 2000 : 15000;
	SetPVarInt(playerid, "FixVehicleID", closestcar);
	SetPVarInt(playerid, "FixVehicleTimer", SetTimerEx("FixVehicle", repairDelay, false, "iii", playerid, closestcar, g_arrQueryHandle[playerid]));
	if(PlayerInfo[playerid][pMechSkill] < 400)
	{
		new string[128];
		format(string, sizeof(string), "* %s has began repairing the vehicle.", GetPlayerNameEx(playerid));
		ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		TogglePlayerControllable(playerid, false);
		ApplyAnimation(playerid, "MISC", "Plunger_01", 4.1, true, true, true, true, 1, 1);
	}
	return 1;
}

forward FixVehicle(playerid, vehicleid, session);
public FixVehicle(playerid, vehicleid, session)
{
	if(!IsPlayerConnected(playerid) || g_arrQueryHandle[playerid] != session) return 1;
	if(!GetPVarType(playerid, "FixVehicleTimer") || GetPVarInt(playerid, "FixVehicleID") != vehicleid) return 1;
	new bool:valid = Mechanic_CanFix(playerid) && Mechanic_NearVehicle(playerid, vehicleid, 10.0)
		&& GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && !PlayerIsDead[playerid] && !PlayerInfo[playerid][pHospital]
		&& !GetPVarType(playerid, "IsInArena") && !GetPVarInt(playerid, "EventToken")
		&& !GetPVarType(playerid, "PlayerCuffed") && !GetPVarInt(playerid, "pBagged") && !GetPVarType(playerid, "Injured") && !GetPVarType(playerid, "IsFrozen");
	new engine, lights, alarm, doors, bonnet, boot, objective;
	if(valid)
	{
		GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
		if(!IsABike(vehicleid) && !IsAPlane(vehicleid) && bonnet != VEHICLE_PARAMS_ON) valid = false;
	}
	Mechanic_CancelFix(playerid);
	if(!valid) return SendClientMessageEx(playerid, COLOR_GRAD1, "The repair was cancelled because you or the vehicle are no longer ready.");
	PlayerInfo[playerid][pMechTime] = gettime()+60;
	SetVehicleHealth(vehicleid, 1000.0);
	Vehicle_Armor(vehicleid);
	switch(GetVehicleModel(vehicleid))
	{
		case 481, 509, 510:
		{
			SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_ON, lights, alarm, doors, bonnet, boot, objective);
			arr_Engine{vehicleid} = 1;
		}
	}
	format(szMiscArray, sizeof(szMiscArray), "* %s has repaired the vehicle.", GetPlayerNameEx(playerid));
	ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	return 1;
}

CMD:mechduty(playerid, params[])
{
    if(PlayerInfo[playerid][pJob] == 7 || PlayerInfo[playerid][pJob2] == 7 || PlayerInfo[playerid][pJob3] == 7)
	{
        if(GetPVarInt(playerid, "MechanicDuty") == 1)
		{
            SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* You are now off duty from your Car Mechanic job and will not receive calls anymore.");
			SetPVarInt(playerid, "MechanicDuty", 0);
            Mechanics -= 1;
        }
        else if(GetPVarInt(playerid, "MechanicDuty") == 0)
		{
            if (TransportDuty[playerid] != 0) return SendClientMessageEx(playerid,COLOR_GREY,"You need to get off duty as a transport driver first.");
            SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* You are now on duty with your Car Mechanic job and will receive calls from people in need.");
			SetPVarInt(playerid, "MechanicDuty", 1);
            ++Mechanics;
        }
    }
    else
	{
        SendClientMessageEx(playerid, COLOR_GRAD1, "   You are not a mechanic!");
    }
    return 1;
}

CMD:nos(playerid, params[])
{
    if(PlayerInfo[playerid][pJob] == 7 || PlayerInfo[playerid][pJob2] == 7 || PlayerInfo[playerid][pJob3] == 7) {
        if(IsPlayerInAnyVehicle(playerid)) {
			if(GetPVarInt(playerid, "EventToken")) {
				return SendClientMessageEx(playerid, COLOR_GRAD1, "You can't use this while in an event.");
			}
			new vehicleid = GetPlayerVehicleID(playerid);
			new component = GetVehicleComponentInSlot(vehicleid, GetVehicleComponentType(1010));
			if(component != 1010 && component != 1009 && component != 1008)
   			{
            	if(!IsPlayerInInvalidNosVehicle(playerid))
				{
                	new string[128];
                	new nostogive;
					new level = PlayerInfo[playerid][pMechSkill];
					if(level < 100) nostogive = 1009;
					else if(level < 400) nostogive = 1008;
					else nostogive = 1010;
					if(!VehicleCanHaveComponent(GetVehicleModel(vehicleid), nostogive) || !AddVehicleComponent(vehicleid, nostogive))
						return SendClientMessageEx(playerid, COLOR_GREY, "Nitrous injection cannot be installed on this vehicle.");
                	PlayerPlaySound(playerid,1133,0.0,0.0,0.0);
                	format(string, sizeof(string), "* %s added nitrous injection to the vehicle.", GetPlayerNameEx(playerid));
                	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
            	}
            	else {
            	    SendClientMessageEx(playerid, COLOR_GREY, "Nitrous injection cannot be installed on this vehicle.");
            	}
			 }
			 else {
			    SendClientMessageEx(playerid, COLOR_GREY, "This vehicle already has nitrous.");
		 	}
        }
        else {
            SendClientMessageEx(playerid, COLOR_GREY, "You're not in a vehicle.");
        }
    }
    else {
        SendClientMessageEx(playerid, COLOR_GREY, "You are not a Mechanic!" );
    }
    return 1;
}

CMD:hyd(playerid, params[])
{
    if(PlayerInfo[playerid][pJob] == 7 || PlayerInfo[playerid][pJob2] == 7 || PlayerInfo[playerid][pJob3] == 7) {
        if(IsPlayerInAnyVehicle(playerid)) {
			new vehicleid = GetPlayerVehicleID(playerid), dynid = DynVeh[vehicleid];
			if(IsPlayerInInvalidNosVehicle(playerid) || !VehicleCanHaveComponent(GetVehicleModel(vehicleid), 1087)) return SendClientMessageEx(playerid, COLOR_WHITE, "Hydraulics cannot be installed in this vehicle.");
			if(dynid != -1)
			{
				if(!(0 <= dynid < sizeof(DynVehicleInfo))) return SendClientMessageEx(playerid, COLOR_WHITE, "Hydraulics cannot be installed in this vehicle.");
				new groupid = DynVehicleInfo[dynid][gv_igID];
				if(groupid != INVALID_GROUP_ID && (!(0 <= groupid < sizeof(arrGroupData)) || arrGroupData[groupid][g_iGroupType] != GROUP_TYPE_CRIMINAL))
					return SendClientMessageEx(playerid, COLOR_WHITE, "Hydraulics cannot be installed in this vehicle.");
			}
			if(gettime() < PlayerInfo[playerid][pServiceTime]) return SendClientMessage(playerid, COLOR_GREY, "You must wait 20 seconds before using this command again.");
			new string[128];
			if(!AddVehicleComponent(vehicleid, 1087)) return SendClientMessageEx(playerid, COLOR_WHITE, "Hydraulics cannot be installed in this vehicle.");
			PlayerPlaySound(playerid,1133,0.0,0.0,0.0);
			format(string, sizeof(string), "* %s added hydraulics to the vehicle.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			PlayerInfo[playerid][pServiceTime] = gettime()+20;
        }
        else return SendClientMessageEx(playerid, COLOR_WHITE, "You're not in a vehicle.");
    }
    else return SendClientMessageEx(playerid, COLOR_WHITE, "You are not a Mechanic!");
    return 1;
}