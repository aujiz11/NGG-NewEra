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

	Developers:
		(***) Austin
		(***) Connor
		(***) Jingles

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

#define		DIALOG_GPS_ONE				9800
#define		DIALOG_GPS_TWO				9801
#define		DIALOG_GPS_GEN				9802
#define		DIALOG_GPS_THREE			9984
#define		DIALOG_GPS_BCATS			9986
#define		DIALOG_GPS_BSELECT			9987
#define		DIALOG_GPS_BIZCONF			9988
#define		DIALOG_GPS_FAVS				9809
#define		DIALOG_GPS_SETFAV			9808
#define		DIALOG_GPS_SETFAVNAME		9708

#define 	DIALOG_MAP_BUSINESSES 		9709
#define 	DIALOG_MAP_BUSINESSES2 		9710
#define 	DIALOG_MAP_JOBS				9711

#define 	CHECKPOINT_GEN_LOCATION 	4500
#define 	CHECKPOINT_BUSINESS 		4501
#define 	CHECKPOINT_JOB 				4502
#define 	CHECKPOINT_DOOR				4503
#define 	CHECKPOINT_HOUSE			4504

#define		MAX_GPSFAV					(5)
#define		MAP_BUSINESS_PAGE_SIZE 		(20)

/*
enum gpsFavs
{
	FavName[128],
	Float:FavPos[3]
}
new GPSFav[MAX_PLAYERS][MAX_GPSFAV][gpsFavs];
*/

new Float:gpsZones[][4] = {
	{1555.1693, -1675.6151, 16.1953}, // LSPD
	{626.9811,-571.8036,17.9207,110.9859}, // SASD
	{-1605.7848,710.9673,13.8672,175.0478}, // SFPD
	{327.9552,-1512.2510,36.0325,88.4196}, // FBI
	{-1944.2158,457.2660,35.1719,224.4054}, // FBI SF
	{-2028.5834,-100.6595,35.1641,235.1625}, // DOC
	{1295.7305,-2526.1033,13.9679,189.1324}, //FDSA HQ
	{648.2982,-1357.5068,13.5716,331.5677}, // SA News HQ
	{-54.6465,-1152.5557,2.1316,64.1502}, // RCTR // Dialog 1 END -- (8)
	{-1580.5352,903.4696,7.6953,149.5203}, // SF Bank
	{1456.8411,-1011.4421,26.8438,57.0505}, // Mullholand Bank
	{2462.5857,2244.9272,10.8203,310.6805}, // LV Bank
	{595.3816,-1249.2163,18.2463,136.4379}, // Rodeo Bank
	{648.4630,-519.8029,16.5537,347.8049}, // Dillimore Bank -- Dialog 2 End -- (13)
	{-2455.3552,503.7207,30.0781,81.6989}, // SF Vip
	{1797.4575,-1578.9565,14.0856,120.4249}, // LSVIP
	{1930.8643,1345.4410,9.9688,145.0573}, // LV Vip
	{2017.6354,-1311.6549,23.9861,332.9441}, // Glen Park VIP
	{1022.0172,-1122.0380,23.8709,297.9781}, // Famed Lounge -- Dialog 3 End -- (18)
	{-2653.6384,638.8214,14.4531,43.3566}, // SF Hospital
	{2034.3092,-1402.3984,17.2961,339.7592}, // County Hospital
	{1172.1243,-1323.2010,15.4027,99.1248}, // All Saints
	{1241.3552,326.6962,19.7555,154.6608}, // Montgomery Hospital -- Dialog 4 End -- (22)
	{-560.008483, -1020.256652, 24.084102}, // Flint Hospital
	{-2413.4434,2251.3003,4.8138,267.8773}, // Bayside Appts.
	{-2436.0908,2305.2141,4.9844,132.8512}, // Bayside VIP 
	{-2544.1807,2346.4771,4.9844,44.3360}, // TR Capitol Building
	{-2630.0063,2272.8008,8.3225,111.7500}, // TRES HQ 
	{-1390.6035,2638.3354,55.9844,282.1874}, // TRAF HQ Elque
	{-1439.2744,2591.3591,55.8359,342.5681}, // TRES Recruitment office
	{-1514.5067,2520.9653,55.8705,164.9699}, // Elquebrado's Hospital
	{-827.9031,1504.0640,19.8300,322.0778}, // Las Barancas Bank
	{-319.8820,1049.0958,20.3403,142.6894}, // Fort Carson Hospital -- Dialog 5 End -- (33)
	{1481.0574,-1772.0535,18.7958,178.1923}, // LS City Hall 
	{-2765.8823,375.7053,6.3347,74.5302}, // SF City Hall
	{-1750.6162,964.0596,24.8906,4.3083}, // SF Appts.
	{288.1022,-1600.4684,32.7701,203.7112}, // NG Recuruitment Office
	{-2056.9709,228.3147,35.3800,265.4275}, // Donahue Family Condo's SF
	{2025.7943,-1296.6964,23.9861,195.1668}, // Glen Park Community Center
	{2634.0679,-1384.9991,30.4456,281.2836}, // Los Flores Hotel
	{2752.2041,-1962.6484,13.5469,124.7719}, // Seville Appts.
	{2248.1704,-1795.4705,13.5469,138.6487}, // Ganton Appts.
	{1863.7871,-1599.4569,13.9770,298.1175}, // Idlewood Appts.
	{487.3402,-1640.4919,23.7031,10.7028}, // Trump Industries
	{607.6238,-1458.9736,14.3879,94.2657}, // Fuente's Rodeo Appts
	{1117.4316,-1380.5221,15.3364,49.8436}, // Mall Appts.
	{994.3275,-1211.3960,16.9375,355.9103}, // Market Appts.
	{1241.7294,-1259.3480,13.5300,7.8954}, // Donahue Family Condos, Market
	{1420.0615,-1623.9930,13.5469,333.2560}, // Commerce Appts.
	{1498.6129,-1584.3176,13.5469,7.0856} // Pershing Square Appts. -- Dialog 6 End --
};

new gpsZoneName[50][] = {
	"LSPD",
	"SASD",
	"SFPD",
	"FBI",
	"FBI SF",
	"DoC",
	"FDSA",
	"SANews",
	"RCTR",
	"SF Bank",
	"Mullholand Bank",
	"LV Bank",
	"Rodeo Bank",
	"Dillimore Bank",
	"SF VIP",
	"LS VIP",
	"LV VIP",
	"Glen Park VIP",
	"Famed Lounge",
	"SF Hospital",
	"County Hospital",
	"All Saints Hospital",
	"Montgomery Hospital",
	"Flint Hospital",
	"Bayside Apartments",
	"Bayside VIP",
	"TR Capitol",
	"TRES",
	"TRAF El Quebrados",
	"TRES Recruitment",
	"El Quebrados Hospital",
	"Los Barrancas Bank",
	"Fort Carson Hospital",
	"City Hall",
	"SF City Hall",
	"SF Apartments",
	"Nation Guard Recruitment",
	"Donahue Condos - SF",
	"Glen Park Community Center",
	"Los Flores Hotel",
	"Seville Apartments",
	"Ganton Apartments",
	"Idlewood Apartments",
	"Rodeo Apartments",
	"Fuente's Rodeo Apartments",
	"Mall Apartments",
	"Market Apartments",
	"Donahue Condos - Market",
	"Commerce Apartments",
	"Pershing Square Apartments"
};

new const MapBusinessTypes[] = {
	BUSINESS_TYPE_STORE, 
	BUSINESS_TYPE_CLOTHING, 
	BUSINESS_TYPE_RESTAURANT, 
	BUSINESS_TYPE_BAR,
	BUSINESS_TYPE_GUNSHOP, 
	BUSINESS_TYPE_GASSTATION, 
	BUSINESS_TYPE_NEWCARDEALERSHIP, 
	BUSINESS_TYPE_CLUB
};

new const MapLocationStarts[] = {0, 9, 14, 19, 24, 33, sizeof(gpsZones)};

GetEntity3DZone(entityID, type, zone[], len, Float:x2 = 0.0, Float:y2 = 0.0, Float:z2 = 0.0) //Credits to Cueball, Betamaster, Mabako, and Simon.
{
	new Float:x, Float:y, Float:z;
	format(zone, len, "Khong ro");
	switch(type) {
		case 0: {
			x = Businesses[entityID][bExtPos][0];
			y = Businesses[entityID][bExtPos][1];
			z = Businesses[entityID][bExtPos][2];
		}
		case 1: {
			x = HouseInfo[entityID][hExteriorX];
			y = HouseInfo[entityID][hExteriorY];
			z = HouseInfo[entityID][hExteriorZ];
		}
		case 2: {
			x = DDoorsInfo[entityID][ddExteriorX];
			y = DDoorsInfo[entityID][ddExteriorY];
			z = DDoorsInfo[entityID][ddExteriorZ];
		}
		case 3: {
			x = x2;
			y = y2;
			z = z2;
		}
	}

	for(new i = 0; i != sizeof(gSAZones); i++) {
		if(x >= gSAZones[i][SAZONE_AREA][0]
				&& x <= gSAZones[i][SAZONE_AREA][3]
				&& y >= gSAZones[i][SAZONE_AREA][1]
				&& y <= gSAZones[i][SAZONE_AREA][4]
				&& z >= gSAZones[i][SAZONE_AREA][2]
				&& z <= gSAZones[i][SAZONE_AREA][5]) {
			return strunpack(zone, gSAZones[i][SAZONE_NAME], len);
		}
	}
	return 0;
}

/*
CMD:gpsfaves(playerid,params[])
{
	new string[128];
	for(new i = 0; i < MAX_GPSFAV; i++)
	{
		format(string,sizeof(string), "%s\n%s", string, GPSFav[playerid][i][FavName]);
	}
	ShowPlayerDialogEx(playerid, DIALOG_GPS_SETFAV, DIALOG_STYLE_LIST, "Delux GPS - Save Favorite", string, "Save Favorite", "Cancel");
	return 1;
}
*/

CMD:map(playerid, params[])
{
	return Phone_Map(playerid);
}

CMD:mygps(playerid, const params[])
{
	if(CheckPointCheck(playerid) || IsPlayerCheckpointActive(playerid)) return SendClientMessageEx(playerid, COLOR_WHITE, "Hay xoa checkpoint hien tai truoc khi dung ban do.");
	return ShowPlayerDialogEx(playerid, DIALOG_GPS_ONE, DIALOG_STYLE_TABLIST_HEADERS, "Doodle Maps | Diem den",
		"Danh muc\tTim diem den\nDoanh nghiep\tCua hang va dich vu\nCong viec\tDiem tuyen dung gan nhat\nDia diem chung\tDia danh va dich vu cong\nDia chi doanh nghiep\tTim theo ID doanh nghiep\nDia chi nha\tTim theo ID nha\nDia chi cua\tTim theo ID cua", "Mo", "Dong");
}

Map_ShowBusinessTypes(playerid)
{
	return ShowPlayerDialogEx(playerid, DIALOG_MAP_BUSINESSES, DIALOG_STYLE_LIST, "Doodle Maps | Loai doanh nghiep",
		"24/7\nCua hang quan ao\nNha hang\nQuan bar\nCua hang sung\nTram xang\nDai ly xe\nClub", "Mo", "Quay lai");
}

Map_ShowLocationTypes(playerid)
{
	SetPVarInt(playerid, "gpsUsingID", 0);
	return ShowPlayerDialogEx(playerid, DIALOG_GPS_TWO, DIALOG_STYLE_LIST, "Doodle Maps | Danh muc dia diem",
		"Tru so to chuc\nNgan hang\nKhu VIP\nBenh vien\nNew Robada\nKhac", "Mo", "Quay lai");
}

Map_GetDestination(type, id, name[], len, &Float:x, &Float:y, &Float:z)
{
	switch(type)
	{
		case CHECKPOINT_BUSINESS:
		{
			if(!IsValidBusinessID(id) || Businesses[id][bType] == 0) return 0;
			format(name, len, "%s", Businesses[id][bName]);
			x = Businesses[id][bExtPos][0];
			y = Businesses[id][bExtPos][1];
			z = Businesses[id][bExtPos][2];
		}
		case CHECKPOINT_HOUSE:
		{
			if(!(0 <= id < MAX_HOUSES) || !HouseInfo[id][hOwned]) return 0;
			format(name, len, "Nha #%d", id);
			x = HouseInfo[id][hExteriorX];
			y = HouseInfo[id][hExteriorY];
			z = HouseInfo[id][hExteriorZ];
		}
		case CHECKPOINT_DOOR:
		{
			if(!(0 <= id < MAX_DDOORS) || !DDoorsInfo[id][ddDescription][0]) return 0;
			format(name, len, "Cua #%d (%s)", id, DDoorsInfo[id][ddDescription]);
			x = DDoorsInfo[id][ddExteriorX];
			y = DDoorsInfo[id][ddExteriorY];
			z = DDoorsInfo[id][ddExteriorZ];
		}
		case CHECKPOINT_JOB:
		{
			if(!(0 <= id < MAX_JOBPOINTS) || JobData[id][jId] != id + 1
				|| !Job_IsAvailable(JobData[id][jType]) || !IsValidDynamicArea(JobData[id][jAreaID])) return 0;
			format(name, len, "%s", GetJobName(JobData[id][jType]));
			x = JobData[id][jPos][0];
			y = JobData[id][jPos][1];
			z = JobData[id][jPos][2];
		}
		case CHECKPOINT_GEN_LOCATION:
		{
			if(!(0 <= id < sizeof(gpsZones))) return 0;
			format(name, len, "%s", gpsZoneName[id]);
			x = gpsZones[id][0];
			y = gpsZones[id][1];
			z = gpsZones[id][2];
		}
		default: return 0;
	}
	return x != 0.0 || y != 0.0 || z != 0.0;
}

Map_SetDestination(playerid, type, id)
{
	if(CheckPointCheck(playerid) || IsPlayerCheckpointActive(playerid)) return SendClientMessageEx(playerid, COLOR_WHITE, "Hay xoa checkpoint hien tai truoc khi dung ban do.");
	new name[160], area[32], Float:x, Float:y, Float:z;
	if(!Map_GetDestination(type, id, name, sizeof(name), x, y, z))
		return SendClientMessageEx(playerid, COLOR_GREY, "Diem den khong con kha dung.");
	if(type == CHECKPOINT_JOB && (JobData[id][jVw] != GetPlayerVirtualWorld(playerid) || JobData[id][jInt] != GetPlayerInterior(playerid)))
		return SendClientMessageEx(playerid, COLOR_GREY, "Diem cong viec o world hoac interior khac. Hay mo lai ban do.");

	GetEntity3DZone(0, 3, area, sizeof(area), x, y, z);
	DisablePlayerCheckpoint(playerid);
	SetPlayerCheckpoint(playerid, x, y, z, type == CHECKPOINT_JOB ? 5.0 : 15.0);
	gPlayerCheckpointStatus[playerid] = type;
	SetPVarString(playerid, "gpsName", name);
	DeletePVar(playerid, "gpsAddressID");
	SendClientMessageEx(playerid, COLOR_WHITE, "Diem GPS: {33CCFF}%s{FFFFFF} tai %s (%.0f meters).", name, area, GetPlayerDistanceFromPoint(playerid, x, y, z));
	return 1;
}

hook OnPlayerEnterCheckpoint(playerid)
{
	switch(gPlayerCheckpointStatus[playerid])
	{
		case CHECKPOINT_GEN_LOCATION, CHECKPOINT_BUSINESS, CHECKPOINT_JOB, CHECKPOINT_HOUSE, CHECKPOINT_DOOR:
		{
			new name[160];
			GetPVarString(playerid, "gpsName", name, sizeof(name));
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da den {33CCFF}%s{FFFFFF}.", name);
			DeletePVar(playerid, "gpsName");
			DisablePlayerCheckpoint(playerid);
			gPlayerCheckpointStatus[playerid] = CHECKPOINT_NONE;
		}
	}
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	switch(dialogid)
	{
		case DIALOG_GPS_ONE:
		{
			if(!response) return 1;
			switch(listitem)
			{
				case 0: return Map_ShowBusinessTypes(playerid);
				case 1: return Map_ShowJobs(playerid);
				case 2: return Map_ShowLocationTypes(playerid);
				case 3, 4, 5:
				{
					SetPVarInt(playerid, "gpsUsingID", listitem - 2);
					return ShowPlayerDialogEx(playerid, DIALOG_GPS_TWO, DIALOG_STYLE_INPUT, "Doodle Maps | Tim dia chi",
						"Nhap ID so cua diem den.", "Tim", "Quay lai");
				}
			}
			return 1;
		}
		case DIALOG_MAP_BUSINESSES:
		{
			if(!response) return pc_cmd_mygps(playerid, "");
			return Map_ShowBusinesses(playerid, listitem);
		}
		case DIALOG_MAP_BUSINESSES2:
		{
			if(!response) return Map_ShowBusinessTypes(playerid);
			if(!(0 <= listitem < GetPVarInt(playerid, "gpsMapRows"))) return 1;
			new id = ListItemTrackId[playerid][listitem];
			if(id == -1) return Map_ShowBusinesses(playerid, GetPVarInt(playerid, "gpsBusinessType"), GetPVarInt(playerid, "gpsBusinessPage") + 1);
			if(id == -2) return Map_ShowBusinesses(playerid, GetPVarInt(playerid, "gpsBusinessType"), GetPVarInt(playerid, "gpsBusinessPage") - 1);
			return Map_SetDestination(playerid, CHECKPOINT_BUSINESS, id);
		}
		case DIALOG_MAP_JOBS:
		{
			if(!response) return pc_cmd_mygps(playerid, "");
			if(!(0 <= listitem < GetPVarInt(playerid, "gpsMapRows"))) return 1;
			return Map_SetDestination(playerid, CHECKPOINT_JOB, ListItemTrackId[playerid][listitem]);
		}
		case DIALOG_GPS_TWO:
		{
			if(!response) return pc_cmd_mygps(playerid, "");
			new mode = GetPVarInt(playerid, "gpsUsingID");
			if(mode == 0) return Map_ShowLocations(playerid, listitem);
			if(!inputtext[0] || strlen(inputtext) > 5 || !IsNumericString(inputtext))
				return SendClientMessageEx(playerid, COLOR_GREY, "Nhap ID diem den hop le.");

			new id = strval(inputtext), type, name[160], area[32], Float:x, Float:y, Float:z;
			switch(mode)
			{
				case 1: type = CHECKPOINT_BUSINESS;
				case 2: type = CHECKPOINT_HOUSE;
				case 3: type = CHECKPOINT_DOOR;
				default: return 1;
			}
			if(!Map_GetDestination(type, id, name, sizeof(name), x, y, z))
				return SendClientMessageEx(playerid, COLOR_GREY, "Dia chi diem den khong hop le hoac chua duoc cau hinh.");
			GetEntity3DZone(0, 3, area, sizeof(area), x, y, z);
			format(szMiscArray, sizeof(szMiscArray), "{FFFFFF}Dat diem GPS den:\n\n{33CCFF}%s{FFFFFF}\nKhu vuc: %s\nKhoang cach: %.0f meters", name, area, GetPlayerDistanceFromPoint(playerid, x, y, z));
			SetPVarInt(playerid, "gpsAddressID", id);
			return ShowPlayerDialogEx(playerid, DIALOG_GPS_THREE, DIALOG_STYLE_MSGBOX, "Doodle Maps | Xac nhan diem den", szMiscArray, "Dan duong", "Quay lai");
		}
		case DIALOG_GPS_GEN:
		{
			if(!response) return Map_ShowLocationTypes(playerid);
			new category = GetPVarInt(playerid, "gpsUsingID");
			if(!(0 <= category < sizeof(MapLocationStarts) - 1)) return 1;
			if(!(0 <= listitem < MapLocationStarts[category + 1] - MapLocationStarts[category])) return 1;
			return Map_SetDestination(playerid, CHECKPOINT_GEN_LOCATION, MapLocationStarts[category] + listitem);
		}
		case DIALOG_GPS_THREE:
		{
			if(!response) return pc_cmd_mygps(playerid, "");
			switch(GetPVarInt(playerid, "gpsUsingID"))
			{
				case 1: return Map_SetDestination(playerid, CHECKPOINT_BUSINESS, GetPVarInt(playerid, "gpsAddressID"));
				case 2: return Map_SetDestination(playerid, CHECKPOINT_HOUSE, GetPVarInt(playerid, "gpsAddressID"));
				case 3: return Map_SetDestination(playerid, CHECKPOINT_DOOR, GetPVarInt(playerid, "gpsAddressID"));
			}
			return 1;
		}
		/*
		case DIALOG_GPS_FAVS:
		{
			if(!response) return 1;
			if(!strcmp(inputtext, "None", true)) return SendClientMessageEx(playerid, COLOR_WHITE, "You don't have a favorite stored in that slot.");
			GetEntity3DZone(listitem, 3, szMiscArray, sizeof(szMiscArray), GPSFav[playerid][listitem][FavPos][0], GPSFav[playerid][listitem][FavPos][1], GPSFav[playerid][listitem][FavPos][2]);
			format(szMiscArray, sizeof(szMiscArray), "Your GPS Destination has been set to {33CCFF}%s{FFFFFF} in the area of {FF0000}%s{FFFFFF}.", GPSFav[playerid][listitem][FavName], szMiscArray);
			SendClientMessageEx(playerid, COLOR_WHITE, szMiscArray);
			gPlayerCheckpointStatus[playerid] = CHECKPOINT_FAVORITES;
			SetPVarInt(playerid, "gpsFav", listitem);
			SetPlayerCheckpoint(playerid, GPSFav[playerid][listitem][FavPos][0],GPSFav[playerid][listitem][FavPos][1],GPSFav[playerid][listitem][FavPos][2], 15.0);
		}
		case DIALOG_GPS_SETFAV:
		{
			if(!response) return 1;
			SetPVarInt(playerid, "sFav", listitem);
			ShowPlayerDialogEx(playerid, DIALOG_GPS_SETFAVNAME, DIALOG_STYLE_INPUT, "Enter Favorite Name", "Please enter a name for your favorite.\n\nIt will be saved in the slot you have selected.", "Submit", "Cancel"); 
		}
		case DIALOG_GPS_SETFAVNAME:
		{
			if(!response) return 1;
			new sFav = GetPVarInt(playerid, "sFav");
			strcpy(GPSFav[playerid][sFav][FavName], inputtext, 128);
			GetPlayerPos(playerid, GPSFav[playerid][sFav][FavPos][0],GPSFav[playerid][sFav][FavPos][1],GPSFav[playerid][sFav][FavPos][2]);
			SendClientMessage(playerid,COLOR_WHITE, "GPS Location Saved!");
			new szQuery[256];
			format(szQuery, sizeof(szQuery), "UPDATE `GPSFavs` SET `Fav%i` = '%s|%f|%f|%f' WHERE `SQLid` = %d", sFav+1, GPSFav[playerid][sFav][FavName], GPSFav[playerid][sFav][FavPos][0],GPSFav[playerid][sFav][FavPos][1],GPSFav[playerid][sFav][FavPos][2], GetPlayerSQLId(playerid)); 
			mysql_tquery(MainPipeline, szQuery, false, "OnQueryFinish", "ii", SENDDATA_THREAD, playerid);
		}
		*/
	}
	return 0;
}

Map_ShowBusinesses(playerid, btype, page = 0)
{
	if(!(0 <= btype < sizeof(MapBusinessTypes)) || !(0 <= page < (MAX_BUSINESSES + MAP_BUSINESS_PAGE_SIZE - 1) / MAP_BUSINESS_PAGE_SIZE)) return 1;
	new row[192], area[32], count, rows;
	format(szMiscArray, sizeof(szMiscArray), "Doanh nghiep\tKhu vuc\tTrang thai\tKhoang cach (m)\n");
	for(new i; i < MAX_BUSINESSES; ++i)
	{
		if(Businesses[i][bType] != MapBusinessTypes[btype]) continue;
		if(Businesses[i][bExtPos][0] == 0.0 && Businesses[i][bExtPos][1] == 0.0 && Businesses[i][bExtPos][2] == 0.0) continue;
		if(count++ < page * MAP_BUSINESS_PAGE_SIZE || rows >= MAP_BUSINESS_PAGE_SIZE) continue;
		GetEntity3DZone(i, 0, area, sizeof(area));
		format(row, sizeof(row), "%s [#%d]\t%s\t%s\t%.0f m\n", Businesses[i][bName], i, area,
			Businesses[i][bStatus] ? ("{00CC66}Mo") : ("{FF6666}Dong"),
			GetPlayerDistanceFromPoint(playerid, Businesses[i][bExtPos][0], Businesses[i][bExtPos][1], Businesses[i][bExtPos][2]));
		strcat(szMiscArray, row, sizeof(szMiscArray));
		ListItemTrackId[playerid][rows++] = i;
	}
	if(!rows)
	{
		if(page > 0) return Map_ShowBusinesses(playerid, btype, 0);
		SendClientMessageEx(playerid, COLOR_GREY, "Khong co doanh nghiep duoc cau hinh trong muc nay.");
		return Map_ShowBusinessTypes(playerid);
	}
	if(page > 0)
	{
		strcat(szMiscArray, "{33CCFF}<< Trang truoc\t\t\t\n", sizeof(szMiscArray));
		ListItemTrackId[playerid][rows++] = -2;
	}
	if(count > (page + 1) * MAP_BUSINESS_PAGE_SIZE)
	{
		strcat(szMiscArray, "{33CCFF}Trang sau >>\t\t\t\n", sizeof(szMiscArray));
		ListItemTrackId[playerid][rows++] = -1;
	}
	new title[64];
	format(title, sizeof(title), "Doodle Maps | Doanh nghiep | %d/%d", page + 1, (count + MAP_BUSINESS_PAGE_SIZE - 1) / MAP_BUSINESS_PAGE_SIZE);
	SetPVarInt(playerid, "gpsBusinessType", btype);
	SetPVarInt(playerid, "gpsBusinessPage", page);
	SetPVarInt(playerid, "gpsMapRows", rows);
	return ShowPlayerDialogEx(playerid, DIALOG_MAP_BUSINESSES2, DIALOG_STYLE_TABLIST_HEADERS, title, szMiscArray, "Dan duong", "Quay lai");
}

Map_ShowJobs(playerid)
{
	new nearest[MAX_JOBTYPES], Float:distances[MAX_JOBTYPES], Float:x, Float:y, Float:z;
	new world = GetPlayerVirtualWorld(playerid), interior = GetPlayerInterior(playerid);
	for(new type; type < MAX_JOBTYPES; ++type) nearest[type] = -1;
	GetPlayerPos(playerid, x, y, z);
	for(new i; i < MAX_JOBPOINTS; ++i)
	{
		if(JobData[i][jId] != i + 1 || !Job_IsAvailable(JobData[i][jType]) || !IsValidDynamicArea(JobData[i][jAreaID])) continue;
		if(JobData[i][jVw] != world || JobData[i][jInt] != interior) continue;
		new type = JobData[i][jType];
		new Float:distance = VectorSize(JobData[i][jPos][0] - x, JobData[i][jPos][1] - y, JobData[i][jPos][2] - z);
		if(nearest[type] == -1 || distance < distances[type])
		{
			nearest[type] = i;
			distances[type] = distance;
		}
	}
	new row[192], area[32], rows;
	format(szMiscArray, sizeof(szMiscArray), "Cong viec\tKhu vuc\tCap\tKhoang cach (m)\n");
	for(new type = 1; type < MAX_JOBTYPES; ++type)
	{
		new point = nearest[type];
		if(point == -1) continue;
		GetEntity3DZone(0, 3, area, sizeof(area), JobData[point][jPos][0], JobData[point][jPos][1], JobData[point][jPos][2]);
		format(row, sizeof(row), "%s\t%s\t%d\t%.0f m\n", GetJobName(type), area, JobData[point][jLevel], distances[type]);
		strcat(szMiscArray, row, sizeof(szMiscArray));
		ListItemTrackId[playerid][rows++] = point;
	}
	if(!rows)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Khong co diem tuyen dung nao hoat dong trong world va interior hien tai.");
		return pc_cmd_mygps(playerid, "");
	}
	SetPVarInt(playerid, "gpsMapRows", rows);
	return ShowPlayerDialogEx(playerid, DIALOG_MAP_JOBS, DIALOG_STYLE_TABLIST_HEADERS, "Doodle Maps | Diem cong viec gan nhat", szMiscArray, "Dan duong", "Quay lai");
}

Map_ShowLocations(playerid, category)
{
	if(!(0 <= category < sizeof(MapLocationStarts) - 1)) return 1;
	new row[160], area[32];
	format(szMiscArray, sizeof(szMiscArray), "Dia diem\tKhu vuc\tKhoang cach (m)\n");
	for(new i = MapLocationStarts[category]; i < MapLocationStarts[category + 1]; ++i)
	{
		GetEntity3DZone(0, 3, area, sizeof(area), gpsZones[i][0], gpsZones[i][1], gpsZones[i][2]);
		format(row, sizeof(row), "%s\t%s\t%.0f m\n", gpsZoneName[i], area, GetPlayerDistanceFromPoint(playerid, gpsZones[i][0], gpsZones[i][1], gpsZones[i][2]));
		strcat(szMiscArray, row, sizeof(szMiscArray));
	}
	SetPVarInt(playerid, "gpsUsingID", category);
	return ShowPlayerDialogEx(playerid, DIALOG_GPS_GEN, DIALOG_STYLE_TABLIST_HEADERS, "Doodle Maps | Dia diem chung", szMiscArray, "Dan duong", "Quay lai");
}
