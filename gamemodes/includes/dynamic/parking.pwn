#include <YSI_Coding\y_hooks>

LoadParkingMeters()
{
	print("[LoadParkingMeters] Loading data from database...");
	mysql_tquery(MainPipeline, "SELECT * FROM parking_meters", "OnLoadParkingMeters", "");
	return 1;
}

RebuildParkingMeter(meterid)
{
	new string[256];
	if(IsValidDynamicObject(ParkingMeterInformation[meterid][ParkingMeterObject])) DestroyDynamicObject(ParkingMeterInformation[meterid][ParkingMeterObject]);
	if(IsValidDynamic3DTextLabel(ParkingMeterInformation[meterid][ParkingMeterText])) DestroyDynamic3DTextLabel(ParkingMeterInformation[meterid][ParkingMeterText]);
	if(ParkingMeterInformation[meterid][MeterActive] == 1)
	{
		format(string, sizeof(string), "{FFFFFF}Dong ho do xe {AFAFAF}(ID: %d)\n{FFFFFF}Gia thue: {AFAFAF}$%s Moi 5 Phut\n{FFFFFF}Xe hien tai: {AFAFAF}Trong\n{FFFFFF}Con lai: {AFAFAF}N/A", meterid, number_format(ParkingMeterInformation[meterid][MeterRate]));
		ParkingMeterInformation[meterid][ParkingMeterObject] = CreateDynamicObject(1270, ParkingMeterInformation[meterid][MeterPosition][0], ParkingMeterInformation[meterid][MeterPosition][1], ParkingMeterInformation[meterid][MeterPosition][2], ParkingMeterInformation[meterid][MeterPosition][3], ParkingMeterInformation[meterid][MeterPosition][4], ParkingMeterInformation[meterid][MeterPosition][5], 0, 0);
		ParkingMeterInformation[meterid][ParkingMeterText] = CreateDynamic3DTextLabel(string, COLOR_WHITE, ParkingMeterInformation[meterid][MeterPosition][0], ParkingMeterInformation[meterid][MeterPosition][1], ParkingMeterInformation[meterid][MeterPosition][2] + 0.5, 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
	}
	return 1;
}

RemoveVehicleFromMeter(vehicleid)
{
	for(new i = 1; i < sizeof(ParkingMeterInformation); i ++) if(ParkingMeterInformation[i][MeterActive] == 1 && ParkingMeterInformation[i][AssignedVehicle] == vehicleid) ParkingMeterInformation[i][PaymentExpiry] = 0;
	return 1;
}

SaveParkingMeter(meterid)
{
	new string[1500];
	mysql_format(MainPipeline, string, sizeof(string), "UPDATE `parking_meters` SET `MeterActive`=%d, `MeterRate`=%d, `MeterRange`=%f, \
	`MeterPosition0`=%f, `MeterPosition1`=%f, `MeterPosition2`=%f, `MeterPosition3`=%f, `MeterPosition4`=%f, `MeterPosition5`=%f, \
	`ParkedPosition0`=%f, `ParkedPosition1`=%f, `ParkedPosition2`=%f, `ParkedPosition3`=%f WHERE `MeterID`=%d",
	ParkingMeterInformation[meterid][MeterActive], ParkingMeterInformation[meterid][MeterRate], ParkingMeterInformation[meterid][MeterRange],
	ParkingMeterInformation[meterid][MeterPosition][0], ParkingMeterInformation[meterid][MeterPosition][1], ParkingMeterInformation[meterid][MeterPosition][2],
	ParkingMeterInformation[meterid][MeterPosition][3], ParkingMeterInformation[meterid][MeterPosition][4], ParkingMeterInformation[meterid][MeterPosition][5],
	ParkingMeterInformation[meterid][ParkedPosition][0], ParkingMeterInformation[meterid][ParkedPosition][1],
	ParkingMeterInformation[meterid][ParkedPosition][2], ParkingMeterInformation[meterid][ParkedPosition][3], meterid+1);
	mysql_tquery(MainPipeline, string, "OnQueryFinish", "i", SENDDATA_THREAD);
	return 1;
}

GetNearestParkingMeter(playerid)
{
	if(GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) return -1;
	new meterid, Float:distance[2];
	meterid = -1;
	distance[0] = 1000000.0;
	for(new i = 0; i < sizeof(ParkingMeterInformation); i ++) 
	{
		if(ParkingMeterInformation[i][MeterActive] == 1 && IsPlayerInRangeOfPoint(playerid, ParkingMeterInformation[i][MeterRange], ParkingMeterInformation[i][MeterPosition][0], ParkingMeterInformation[i][MeterPosition][1], ParkingMeterInformation[i][MeterPosition][2]))
		{
			distance[1] = GetPlayerDistanceFromPoint(playerid, ParkingMeterInformation[i][MeterPosition][0], ParkingMeterInformation[i][MeterPosition][1], ParkingMeterInformation[i][MeterPosition][2]);
			if(distance[1] < distance[0])
			{
				distance[0] = distance[1];
				meterid = i;
			}
		}
	}
	return meterid;
}

strmatch(const string1[], const string2[], bool:casesensitive = false)
{
	if((strcmp(string1, string2, casesensitive, strlen(string2)) == 0) && (strlen(string2) == strlen(string1))) return true;
	return false;
}

hook OnPlayerConnect(playerid)
{
	EditingMeterID[playerid] = 0;
	return 1;
}

hook OnVehicleDeath(vehicleid)
{
	RemoveVehicleFromMeter(vehicleid);
	return 1;
}

hook OnVehicleSpawn(vehicleid)
{
	RemoveVehicleFromMeter(vehicleid);
	return 1;
}

hook OnGameModeInit()
{
	for(new i = 1; i < sizeof(ParkingMeterInformation); i ++)
	{
		ParkingMeterInformation[i][AssignedVehicle] = INVALID_VEHICLE_ID;
		ParkingMeterInformation[i][PaymentExpiry] = 0;
	}
	return 1;
}

task ParkingMeters[30000]()
{
	new time, string[256];
	for(new i = 1; i < sizeof(ParkingMeterInformation); i ++)
	{
		if(ParkingMeterInformation[i][MeterActive] == 1 && ParkingMeterInformation[i][AssignedVehicle] != INVALID_VEHICLE_ID)
		{
			if(!IsValidVehicle(ParkingMeterInformation[i][AssignedVehicle]) || gettime() >= ParkingMeterInformation[i][PaymentExpiry])
			{
				ParkingMeterInformation[i][AssignedVehicle] = INVALID_VEHICLE_ID;
				ParkingMeterInformation[i][PaymentExpiry] = 0;
				RebuildParkingMeter(i);
			}
			else if(IsValidVehicle(ParkingMeterInformation[i][AssignedVehicle]) && gettime() < ParkingMeterInformation[i][PaymentExpiry])
			{
				time = ParkingMeterInformation[i][PaymentExpiry] - gettime();
				if(time < 60) format(string, sizeof(string), "Duoi 1 phut");
				else if(time >= 60) format(string, sizeof(string), "%s phut", number_format(time / 60));
				format(string, sizeof(string), "{FFFFFF}Dong ho do xe {AFAFAF}(ID: %d)\n{FFFFFF}Gia thue: {AFAFAF}$%s Moi 5 Phut\n{FFFFFF}Xe hien tai: {AFAFAF}%s\n{FFFFFF}Con lai: {AFAFAF}%s", i, number_format(ParkingMeterInformation[i][MeterRate]), GetVehicleName(ParkingMeterInformation[i][AssignedVehicle]), string);
				UpdateDynamic3DTextLabelText(ParkingMeterInformation[i][ParkingMeterText], COLOR_WHITE, string);
				if(GetVehicleDistanceFromPoint(ParkingMeterInformation[i][AssignedVehicle], ParkingMeterInformation[i][ParkedPosition][0], ParkingMeterInformation[i][ParkedPosition][1], ParkingMeterInformation[i][ParkedPosition][2]) > 5.0)
				{
					SetVehiclePos(ParkingMeterInformation[i][AssignedVehicle], ParkingMeterInformation[i][ParkedPosition][0], ParkingMeterInformation[i][ParkedPosition][1], ParkingMeterInformation[i][ParkedPosition][2]);
					SetVehicleZAngle(ParkingMeterInformation[i][AssignedVehicle], ParkingMeterInformation[i][ParkedPosition][3]);
				}
			}
		}
	}
	return 1;
}

forward OnLoadParkingMeters();
public OnLoadParkingMeters()
{
	new rows, index, string[32];
	cache_get_row_count(rows);
	while(index < rows)
	{
		cache_get_value_name_int(index, "MeterActive", ParkingMeterInformation[index][MeterActive]);
		cache_get_value_name_int(index, "MeterRate", ParkingMeterInformation[index][MeterRate]); 
		cache_get_value_name_float(index, "MeterRange", ParkingMeterInformation[index][MeterRange]); 
		for(new i = 0; i < 6; i ++)
		{
			format(string, sizeof(string), "MeterPosition%d", i);
			cache_get_value_name_float(index, string, ParkingMeterInformation[index][MeterPosition][i]);
			if(i < 4)
			{
				format(string, sizeof(string), "ParkedPosition%d", i);
				cache_get_value_name_float(index, string, ParkingMeterInformation[index][ParkedPosition][i]);
			}
		}
		if(ParkingMeterInformation[index][MeterActive] == 1) RebuildParkingMeter(index);
		index ++;
	}
	switch(index)
	{
		case 0: print("[Parking Meters] No parking meters loaded.");
		default: printf("[Parking Meters] Loaded %d parking meters.", index);
	}
	return 1;
}

alias:parkingmeterhelp("meterhelp")
CMD:parkingmeterhelp(playerid, params[])
{
	SendClientMessageEx(playerid, COLOR_WHITE, "** LENH DONG HO DO XE **");
	SendClientMessageEx(playerid, COLOR_GREY, "/rentmeter - Thue dong ho do xe gan nhat.");
	SendClientMessageEx(playerid, COLOR_GREY, "/renewmeter - Gia han dong ho do xe gan nhat.");
	SendClientMessageEx(playerid, COLOR_GREY, "/meterstatus - Xem trang thai dong ho do xe gan nhat.");
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "** Lenh Admin **");
		SendClientMessageEx(playerid, COLOR_GREY, "* /createmeter [Rate] [Range] - Tao dong ho do xe tai vi tri hien tai.");
		SendClientMessageEx(playerid, COLOR_GREY, "* /setmeterrate [Meter ID] [Rate] - Doi gia thue dong ho do xe.");
		SendClientMessageEx(playerid, COLOR_GREY, "* /setmeterrange [Meter ID] [Range] - Doi pham vi dong ho do xe.");
		SendClientMessageEx(playerid, COLOR_GREY, "* /gotometer [Meter ID] - Dich chuyen den dong ho do xe.");
		SendClientMessageEx(playerid, COLOR_GREY, "* /editmeterposition [Meter ID] [Type] - Sua vi tri dong ho hoac vi tri do xe.");
		SendClientMessageEx(playerid, COLOR_GREY, "* /deletemeter [Meter ID] - Xoa dong ho do xe.");
		SendClientMessageEx(playerid, COLOR_GREY, "* /reloadmeters - Tai lai toan bo dong ho do xe.");
	}
	return 1;
}



CMD:meterstatus(playerid, params[])
{
	new meterid;
	meterid = GetNearestParkingMeter(playerid);
	if(meterid == -1 || !IsPlayerInRangeOfPoint(playerid, 2.0, ParkingMeterInformation[meterid][MeterPosition][0], ParkingMeterInformation[meterid][MeterPosition][1], ParkingMeterInformation[meterid][MeterPosition][2])) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan dong ho do xe.");
	SendClientMessageEx(playerid, COLOR_WHITE, "** TRANG THAI DONG HO DO XE - ID %d: **", meterid);
	SendClientMessageEx(playerid, COLOR_GREY, "* Gia moi nam phut: $%s.", number_format(ParkingMeterInformation[meterid][MeterRate]));
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "* Pham vi: %0.3f met.", ParkingMeterInformation[meterid][MeterRange]);
	}
	switch(ParkingMeterInformation[meterid][AssignedVehicle])
	{
		case INVALID_VEHICLE_ID: return SendClientMessageEx(playerid, COLOR_GREY, "* Xe hien tai: Trong, chua co xe.");
		default:
		{
			SendClientMessageEx(playerid, COLOR_GREY, "* Xe hien tai: %s (ID: %d).", GetVehicleName(ParkingMeterInformation[meterid][AssignedVehicle]), ParkingMeterInformation[meterid][AssignedVehicle]);
			return 1;
		}
	}
	return 1;
}

CMD:rentmeter(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai lai xe de thue dong ho do xe.");
	new vehicleid, engine, lights, alarm, doors, bonnet, boot, objective, meterid, string[128];
	meterid = GetNearestParkingMeter(playerid);
	if(meterid == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan dong ho do xe.");
	if(ParkingMeterInformation[meterid][AssignedVehicle] != INVALID_VEHICLE_ID) return SendClientMessageEx(playerid, COLOR_GREY, "Dong ho do xe nay da co xe. Dung (/renewmeter) de gia han.");
	if(IsTrailerAttachedToVehicle(vehicleid)) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the thue khi xe dang keo theo ro-mooc.");
	vehicleid = GetPlayerVehicleID(playerid);
	switch(GetVehicleModel(vehicleid)) 
	{ 
		case 403, 406, 407, 408, 409, 414, 416, 417, 423, 425, 427, 428, 430, 431, 432, 433, 435, 437, 443, 444, 446, 447, 449, 450, 452, 453, 454, 455, 456, 460, 464, 465, 469, 
		472, 473, 476, 484, 486, 487, 488, 493, 497, 498, 499, 501, 511, 512, 513, 514, 515, 519, 520, 524, 532, 537, 538, 544, 548, 553, 556, 557, 563, 564, 569, 570, 577, 578, 
		584, 588, 590, 591, 592, 593, 594, 595, 606, 607, 608, 609, 610, 611: return SendClientMessageEx(playerid, COLOR_GREY, "Khong the thue dong ho do xe bang xe nay."); 
	}
	if(GetPlayerCash(playerid) < ParkingMeterInformation[meterid][MeterRate])
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien thue ban dau cho dong ho nay ($%s).", number_format(ParkingMeterInformation[meterid][MeterRate]));
		return 1;
	}
	ParkingMeterInformation[meterid][AssignedVehicle] = vehicleid;
	ParkingMeterInformation[meterid][PaymentExpiry] = gettime() + 300;
	GivePlayerCash(playerid, -ParkingMeterInformation[meterid][MeterRate]);
	Tax += ParkingMeterInformation[meterid][MeterRate];
	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
	if(engine == VEHICLE_PARAMS_ON)
	{
		SetVehicleEngine(vehicleid, playerid);
		format(string, sizeof(string), "{FF8000}** {C2A2DA}%s van chia khoa va tat dong co.", GetPlayerNameEx(playerid));
		ProxDetector(30.0, playerid, string, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE);
	}
	SendClientMessageEx(playerid, COLOR_WHITE, "Ban da thue dong ho do xe voi gia $%s trong nam phut.", number_format(ParkingMeterInformation[meterid][MeterRate]));
	SendClientMessageEx(playerid, COLOR_WHITE, "Dung (/renewmeter) de gia han. Gia thue: $%s moi nam phut.", number_format(ParkingMeterInformation[meterid][MeterRate]));
	ParkingMeters();
	return 1;
}

CMD:renewmeter(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai di bo de gia han dong ho do xe.");
	new meterid, string[128];
	meterid = GetNearestParkingMeter(playerid);
	if(meterid == -1 || !IsPlayerInRangeOfPoint(playerid, 2.0, ParkingMeterInformation[meterid][MeterPosition][0], ParkingMeterInformation[meterid][MeterPosition][1], ParkingMeterInformation[meterid][MeterPosition][2])) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o gan dong ho do xe.");
	if(ParkingMeterInformation[meterid][AssignedVehicle] == INVALID_VEHICLE_ID) return SendClientMessageEx(playerid, COLOR_GREY, "Dong ho do xe nay chua co xe.");
	if(GetPlayerCash(playerid) < ParkingMeterInformation[meterid][MeterRate])
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien gia han dong ho nay ($%s).", number_format(ParkingMeterInformation[meterid][MeterRate]));
		return 1;
	}
	if(ParkingMeterInformation[meterid][PaymentExpiry] - gettime() >= 1800) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the gia han luc nay (vuot thoi gian toi da).");
	ParkingMeterInformation[meterid][PaymentExpiry] += 300;
	GivePlayerCash(playerid, -ParkingMeterInformation[meterid][MeterRate]);
	Tax += ParkingMeterInformation[meterid][MeterRate];
	SendClientMessageEx(playerid, COLOR_WHITE, "Ban da gia han dong ho do xe them nam phut voi gia $%s.", number_format(ParkingMeterInformation[meterid][MeterRate]));
	format(string, sizeof(string), "{FF8000}** {C2A2DA}%s lay tien ra va bo vao dong ho do xe.", GetPlayerNameEx(playerid));
	ProxDetector(30.0, playerid, string, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE, COLOR_PURPLE);
	ParkingMeters();
	return 1;
}

CMD:editmeterposition(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	if(GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung lenh nay trong interior hoac virtual world.");
	new meterid, vehicleid, Float:position[4], name[10], string[128];
	if(sscanf(params, "ds[10]", meterid, name)) return SendClientMessageEx(playerid, COLOR_GREY, "[USAGE]: /editmeterposition [Meter ID] [Type (Meter, Parked, ToMe)]");
	if(meterid <= 0 || meterid >= MAX_PARKING_METERS)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "ID dong ho do xe phai tu 1 den %s.", number_format(MAX_PARKING_METERS - 1));
		return 1;
	}
	if(ParkingMeterInformation[meterid][MeterActive] == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Dong ho do xe nay chua hoat dong.");
	if(strlen(name) < 4 || strlen(name) > 6) return SendClientMessageEx(playerid, COLOR_GREY, "Loai dong ho khong hop le. Cac loai: Meter, Parked, ToMe.");
	if(!strmatch(name, "Meter", true) && !strmatch(name, "Parked", true)&& !strmatch(name, "ToMe", true)) return SendClientMessageEx(playerid, COLOR_GREY, "Loai dong ho khong hop le. Cac loai: Meter, Parked, ToMe.");
	if(strmatch(name, "Meter", true))
	{
		EditingMeterID[playerid] = meterid;
		EditDynamicObject(playerid, ParkingMeterInformation[meterid][ParkingMeterObject]);
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban dang sua vi tri dong ho do xe ID %d.", meterid);
		return 1;
	}
	switch(GetPlayerState(playerid))
	{
		case PLAYER_STATE_ONFOOT:
		{
			GetPlayerPos(playerid, position[0], position[1], position[2]);
			GetPlayerFacingAngle(playerid, position[3]);
		}
		case PLAYER_STATE_DRIVER, PLAYER_STATE_PASSENGER:
		{
			vehicleid = GetPlayerVehicleID(playerid);
			GetVehiclePos(vehicleid, position[0], position[1], position[2]);
			GetVehicleZAngle(vehicleid, position[3]);
		}
	}
	if(strmatch(name, "Parked", true))
	{
		for(new i = 0; i < 4; i ++) ParkingMeterInformation[meterid][ParkedPosition][i] = position[i];
		SaveParkingMeter(meterid);
		RebuildParkingMeter(meterid);
		SendClientMessageEx(playerid, COLOR_YELLOW, "Da doi vi tri do xe cua dong ho ID %d.", meterid);
		format(string, sizeof(string), "%s updated the parked position of parking meter ID %d to %0.3f, %0.3f, %0.3f, %0.3f.", GetPlayerNameEx(playerid), meterid, position[0], position[1], position[2], position[3]);
		Log("logs/admin.log", string);
		return 1;
	}
	if(strmatch(name, "ToMe", true))
	{
		for(new i = 0; i < 3; i ++) ParkingMeterInformation[meterid][MeterPosition][i] = position[i];
		ParkingMeterInformation[meterid][MeterPosition][3] = 0.0;
		ParkingMeterInformation[meterid][MeterPosition][4] = 0.0;
		ParkingMeterInformation[meterid][MeterPosition][5] = position[3];
		SaveParkingMeter(meterid);
		RebuildParkingMeter(meterid);
		SendClientMessageEx(playerid, COLOR_YELLOW, "Da doi vi tri dong ho do xe ID %d.", meterid);
		format(string, sizeof(string), "%s updated the position of parking meter ID %d to %0.3f, %0.3f, %0.3f, %0.3f, %0.3f, %0.3f.", GetPlayerNameEx(playerid), meterid, position[0], position[1], position[2], 0.0, 0.0, position[3]);
		Log("logs/admin.log", string);
		return 1;
	}
	return 1;
}

CMD:createmeter(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	if(GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung lenh nay trong interior hoac virtual world.");
	new rate, meterid, Float:range, Float:position[4], string[128];
	if(sscanf(params, "df", rate, range)) return SendClientMessageEx(playerid, COLOR_GREY, "[USAGE]: /createmeter [Rate] [Range]");
	if(rate < 1 || rate > 250000) return SendClientMessageEx(playerid, COLOR_GREY, "Gia thue khong duoc duoi $1 hoac tren $250,000.");
	if(range < 3.5 || range > 25.0) return SendClientMessageEx(playerid, COLOR_GREY, "Pham vi khong duoc duoi 3.5 met hoac tren 25 met.");
	meterid = -1;
	for(new i = 1; i < sizeof(ParkingMeterInformation); i ++)
	{
		if(ParkingMeterInformation[i][MeterActive] == 0)
		{
			meterid = i;
			break;
		}
	}
	if(meterid == -1)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Da dat gioi han dong ho do xe (%s).", number_format(MAX_PARKING_METERS));
		return 1;
	}
	GetPlayerPos(playerid, position[0], position[1], position[2]);
	GetPlayerFacingAngle(playerid, position[3]);
	ParkingMeterInformation[meterid][MeterActive] = 1;
	ParkingMeterInformation[meterid][MeterRate] = rate;
	ParkingMeterInformation[meterid][MeterRange] = range;
	for(new i = 0; i < 3; i ++)
	{
		ParkingMeterInformation[meterid][MeterPosition][i] = position[i];
		ParkingMeterInformation[meterid][ParkedPosition][i] = position[i];
	}
	ParkingMeterInformation[meterid][MeterPosition][3] = 0.0;
	ParkingMeterInformation[meterid][MeterPosition][4] = 0.0;
	ParkingMeterInformation[meterid][MeterPosition][5] = position[3];
	ParkingMeterInformation[meterid][ParkedPosition][3] = position[3];
	SaveParkingMeter(meterid);
	RebuildParkingMeter(meterid);
	SendClientMessageEx(playerid, COLOR_CYAN, "Da tao dong ho do xe ID %d, gia $%s, pham vi %0.3f met.", meterid, number_format(rate), range);
	format(string, sizeof(string), "%s created parking meter ID %d with a rate of $%s and a range of %0.3f meters.", GetPlayerNameEx(playerid), meterid, number_format(rate), range);
	Log("logs/admin.log", string);
	return 1;
}

CMD:setmeterrange(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	new meterid, Float:range, string[128];
	if(sscanf(params, "df", meterid, range)) return SendClientMessageEx(playerid, COLOR_GREY, "[USAGE]: /setmeterrange [Meter ID] [Range]");
	if(meterid <= 0 || meterid >= MAX_PARKING_METERS)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "ID dong ho do xe phai tu 1 den %s.", number_format(MAX_PARKING_METERS - 1));
		return 1;
	}
	if(ParkingMeterInformation[meterid][MeterActive] == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Dong ho do xe nay chua hoat dong.");
	if(range < 3.5 || range > 25.0) return SendClientMessageEx(playerid, COLOR_GREY, "Pham vi khong duoc duoi 3.5 met hoac tren 25 met.");
	if(ParkingMeterInformation[meterid][MeterRange] == range)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Pham vi dong ho nay da la %0.3f met.", range);
		return 1;
	}
	ParkingMeterInformation[meterid][MeterRange] = range;
	SaveParkingMeter(meterid);
	SendClientMessageEx(playerid, COLOR_YELLOW, "Da dat pham vi dong ho do xe ID %d la %0.3f met.", meterid, range);
	format(string, sizeof(string), "%s set parking meter ID %d's range to %0.3f meters.", meterid, range);
	Log("logs/admin.log", string);
	return 1;
}

CMD:setmeterrate(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	new meterid, rate, string[128];
	if(sscanf(params, "dd", meterid, rate)) return SendClientMessageEx(playerid, COLOR_GREY, "[USAGE]: /setmeterrate [Meter ID] [Rate]");
	if(meterid <= 0 || meterid >= MAX_PARKING_METERS)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "ID dong ho do xe phai tu 1 den %s.", number_format(MAX_PARKING_METERS - 1));
		return 1;
	}
	if(ParkingMeterInformation[meterid][MeterActive] == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Dong ho do xe nay chua hoat dong.");
	if(rate < 1 || rate > 250000) return SendClientMessageEx(playerid, COLOR_GREY, "Gia thue khong duoc duoi $1 hoac tren $250,000.");
	if(ParkingMeterInformation[meterid][MeterRate] == rate)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Gia thue dong ho nay da la $%s.", number_format(rate));
		return 1;
	}
	ParkingMeterInformation[meterid][MeterRate] = rate;
	SaveParkingMeter(meterid);
	SendClientMessageEx(playerid, COLOR_YELLOW, "Da dat gia thue dong ho do xe ID %d la $%s.", meterid, number_format(rate));
	format(string, sizeof(string), "%s set parking meter ID %d's rate to $%s.", meterid, number_format(rate));
	Log("logs/admin.log", string);
	RebuildParkingMeter(meterid);
	return 1;
}

CMD:deletemeter(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	new meterid, string[128];
	if(sscanf(params, "d", meterid)) return SendClientMessageEx(playerid, COLOR_GREY, "[USAGE]: /deletemeter [Meter ID]");
	if(meterid <= 0 || meterid >= MAX_PARKING_METERS)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "ID dong ho do xe phai tu 1 den %s.", number_format(MAX_PARKING_METERS - 1));
		return 1;
	}
	if(ParkingMeterInformation[meterid][MeterActive] == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Dong ho do xe nay chua hoat dong.");
	ParkingMeterInformation[meterid][MeterActive] = 0;
	ParkingMeterInformation[meterid][MeterRate] = 0;
	ParkingMeterInformation[meterid][MeterRange] = 0;
	for(new i = 0; i < 6; i ++)
	{
		if(i < 4) ParkingMeterInformation[meterid][ParkedPosition][i] = 0.0;
		ParkingMeterInformation[meterid][MeterPosition][i] = 0.0;
	}
	if(IsValidDynamicObject(ParkingMeterInformation[meterid][ParkingMeterObject])) DestroyDynamicObject(ParkingMeterInformation[meterid][ParkingMeterObject]);
	if(IsValidDynamic3DTextLabel(ParkingMeterInformation[meterid][ParkingMeterText])) DestroyDynamic3DTextLabel(ParkingMeterInformation[meterid][ParkingMeterText]);
	SaveParkingMeter(meterid);
	SendClientMessageEx(playerid, COLOR_GREY, "Da xoa dong ho do xe ID %d.", meterid);
	format(string, sizeof(string), "%s deleted parking meter ID %d.", GetPlayerNameEx(playerid), meterid);
	Log("logs/admin.log", string);
	return 1;
}

CMD:gotometer(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	new meterid, string[128];
	if(sscanf(params, "d", meterid)) return SendClientMessageEx(playerid, COLOR_GREY, "[USAGE]: /gotometer [Meter ID]");
	if(meterid <= 0 || meterid >= MAX_PARKING_METERS)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "ID dong ho do xe phai tu 1 den %s.", number_format(MAX_PARKING_METERS - 1));
		return 1;
	}
	if(ParkingMeterInformation[meterid][MeterActive] == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Dong ho do xe nay chua hoat dong.");
	SetPlayerInterior(playerid, 0);
	PlayerInfo[playerid][pInt] = 0;
	SetPlayerVirtualWorld(playerid, 0);
	PlayerInfo[playerid][pVW] = 0;
	SetPlayerPos(playerid, ParkingMeterInformation[meterid][MeterPosition][0], ParkingMeterInformation[meterid][MeterPosition][1], ParkingMeterInformation[meterid][MeterPosition][2]);
	SetPlayerFacingAngle(playerid, ParkingMeterInformation[meterid][MeterPosition][5]);
	SendClientMessageEx(playerid, COLOR_YELLOW, "Da dich chuyen den dong ho do xe ID %d.", meterid);
	format(string, sizeof(string), "%s teleported to parking meter ID %d.", GetPlayerNameEx(playerid), meterid);
	Log("logs/admin.log", string);
	return 1;
}

CMD:reloadmeters(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	new string[128], count;
	for(new i = 1; i < sizeof(ParkingMeterInformation); i ++)
	{
		RebuildParkingMeter(i);
		if(ParkingMeterInformation[i][MeterActive] == 1) count ++;
	}
	SendClientMessageEx(playerid, COLOR_YELLOW, "Da tai lai toan bo dong ho do xe (%s duoc tao lai).", number_format(count));
	format(string, sizeof(string), "%s reloaded all parking meters (%s rebuilt).", GetPlayerNameEx(playerid), number_format(count));
	Log("logs/admin.log", string);
	return 1;
}