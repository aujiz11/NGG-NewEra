#include <YSI_Coding\y_hooks>

#define VEHICLE_PARAMS_TOG	10030

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {

	new vehicleid = GetPlayerVehicleID(playerid);

	szMiscArray[0] = 0;

	if((newkeys & KEY_YES) && vehicleid != INVALID_VEHICLE_ID && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
		//if(!AC_KeySpamCheck(playerid)) return 1;
		new engine,lights,alarm,doors,bonnet,boot,objective;
		if(GetVehicleModel(vehicleid) == 481 || GetVehicleModel(vehicleid) == 509 || GetVehicleModel(vehicleid) == 510 || DynVeh[vehicleid] != -1 && DynVehicleInfo[DynVeh[vehicleid]][gv_iType] == 1 && GetVehicleModel(vehicleid) == 592) return SendClientMessageEx(playerid,COLOR_WHITE,"Khong the dung lenh nay trong xe nay.");
		if(WheelClamp{vehicleid}) return SendClientMessageEx(playerid,COLOR_WHITE,"(( Lop truoc cua xe nay dang bi khoa banh, ban khong the lai xe di. ))");

		GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
		if(engine == VEHICLE_PARAMS_ON)
		{
			SetVehicleEngine(vehicleid, playerid);
			format(szMiscArray, sizeof(szMiscArray), "{FF8000}** {C2A2DA}%s van chia khoa va tat dong co.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
		else if((engine == VEHICLE_PARAMS_OFF || engine == VEHICLE_PARAMS_UNSET))
		{
			if (GetPVarInt(playerid, "Refueling")) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong the lam vay khi dang do xang.");
			// if(!Vehicle_LockCheck(playerid, vehicleid)) return 1;
			format(szMiscArray, sizeof(szMiscArray), "{FF8000}** {C2A2DA}%s van chia khoa va khoi dong co.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			SendClientMessageEx(playerid, COLOR_WHITE, "Dong co dang khoi dong, vui long cho...");
			SetTimerEx("SetVehicleEngine", 1000, false, "dd",  vehicleid, playerid);
			RemoveVehicleFromMeter(vehicleid);
		}
		
	}
	if((newkeys & KEY_LOOK_BEHIND) && vehicleid != INVALID_VEHICLE_ID && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
		
		if(!IsAPlane(vehicleid)) {
			ShowVehicleMenu(playerid, vehicleid);
		}
		
	}
	return 1;
}

stock Vehicle_LockCheck(playerid, iVehID) {

	new v;
	foreach(new i: Player) {
		v = GetPlayerVehicle(i, iVehID);
		if(v != -1) {
			if(IsABike(iVehID)) {
				if(PlayerVehicleInfo[i][v][pvLocked] == 1 && PlayerVehicleInfo[i][v][pvLock] > 0 && PlayerVehicleInfo[i][v][pvLocksLeft] > 0) {
					SendClientMessageEx(playerid, COLOR_WHITE, "Xe may nay dang bi khoa.");
					return 0;
				}
			}
		}
	}
	return 1;	
}

ShowVehicleMenu(playerid, vehicleid) {
	
	szMiscArray[0] = 0;

	new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

	format(szMiscArray, sizeof(szMiscArray), "Muc\tTrang thai\n\
		Day an toan hoac mu bao hiem\t%s\n\
		Den xe\t%s\n\
		Nap capo\t%s\n\
		Cop xe\t%s",
		((Seatbelt[playerid] == 0) ? ("Tat") : ("Bat")),
		((lights == VEHICLE_PARAMS_OFF) ? ("Tat") : ("Bat")),
		((bonnet == VEHICLE_PARAMS_OFF) ? ("Dong") : ("Mo")),
		((boot == VEHICLE_PARAMS_OFF) ? ("Dong") : ("Mo"))
	);

	ShowPlayerDialogEx(playerid, VEHICLE_PARAMS_TOG, DIALOG_STYLE_TABLIST_HEADERS, "Tuy chon xe", szMiscArray, "Chon", "Huy");
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;

	switch(dialogid) {

		case VEHICLE_PARAMS_TOG: {

			if(!response) return 1;

			new vehicleid = GetPlayerVehicleID(playerid);

			switch(listitem) {
				case 0: {
					if(IsABike(vehicleid)) {
						pc_cmd_helmet(playerid, "");
					}
					else pc_cmd_seatbelt(playerid, "");
				}
				case 1: SetVehicleLights(vehicleid, playerid);// lights
				case 2: SetVehicleHood(vehicleid, playerid);// bonnet
				case 3: SetVehicleTrunk(vehicleid, playerid);// boot
			}	
		}
	}
	return 0;
}