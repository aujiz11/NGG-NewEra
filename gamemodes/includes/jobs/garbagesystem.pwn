/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Garbage Job System

				Next Generation Gaming, LLC
	(created by Next Generation Gaming Development Team)

	* Copyright (c) 2014, Next Generation Gaming, LLC
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

// WINTERFIELD: VERSION .278 GARBAGE JOB

#include <YSI_Coding\y_hooks>

static const Float:GarbageRoutes[][5][3] =
{
	{
		{1864.9694,-1868.8340,13.5393},
		{1339.1879,-1772.2593,13.5432},
		{1097.3889,-1315.5203,13.7031},
		{788.5202,-1616.8534,13.9347},
		{870.7766,-1339.1848,13.1193}
	},
	{
		{2393.3289,-2011.2156,13.1266},
		{2226.3372,-1689.5676,13.5651},
		{2340.3894,-1314.6295,23.6431},
		{2567.5251,-1490.1581,23.5875},
		{2123.0171,-1724.6511,13.1059}
	},
	{
		{365.6633,-2045.8699,7.2444},
		{1032.4659,-1873.3563,12.8004},
		{2223.6206,-2669.4250,13.1041},
		{2613.2957,-2385.6138,13.1910},
		{2197.1860,-1975.7141,13.1308}
	},
	{
		{1122.9072,-1567.9572,12.9752},
		{1363.5902,-1489.5615,13.1180},
		{1212.3572,-1128.1580,23.6371},
		{1138.6549,-864.0754,42.8240},
		{694.8854,-1184.0023,15.0451}
	},
	{
		{1217.1318,-874.5201,42.4655},
		{1904.5316,-1776.6147,13.1084},
		{2127.1011,-1795.1913,13.1227},
		{2381.8950,-1937.8840,13.1190},
		{2392.3760,-1476.8688,23.3760}
	},
	{
		{2231.9036,-1415.6742,23.3977},
		{2084.4321,-1261.1422,23.5523},
		{2094.3391,-1074.8816,25.9005},
		{2598.8777,-1060.4468,69.1403},
		{2743.9485,-1944.5190,13.1191}
	},
	{
		{2194.4458,-1978.2390,13.1250},
		{1933.0288,-2036.1970,13.1260},
		{1501.1422,-1864.9788,13.1113},
		{1338.9059,-1843.0479,13.1106},
		{1420.6254,-1350.9736,13.1186}
	},
	{
		{1017.2939,-1344.6605,12.9403},
		{827.6715,-1056.1721,24.8689},
		{1427.1379,-1047.8226,23.1440},
		{2216.7776,-1373.0634,23.5690},
		{2168.1399,-1650.5302,14.6085}
	},
	{
		{2198.2585,-1499.0953,23.5222},
		{2366.4785,-1270.1448,23.3978},
		{2367.8533,-1760.7986,13.1166},
		{2821.5671,-1541.5742,10.4837},
		{2314.0564,-2307.3513,13.1077}
	}
};

new GarbageLoadSerial[MAX_PLAYERS];

hook OnGameModeInit() {

	GarbageVehicles[0] = AddStaticVehicleEx(408,2450.0818,-2117.0393,14.0948,359.3405,-1,-1,300); // Garbage 1
	GarbageVehicles[1] = AddStaticVehicleEx(408,2456.0059,-2117.0317,14.0978,359.8398,-1,-1,300); // Garbage 2
	GarbageVehicles[2] = AddStaticVehicleEx(408,2461.9404,-2116.9187,14.1033,1.3363,-1,-1,300); // Garbage 3
	GarbageVehicles[3] = AddStaticVehicleEx(408,2467.7634,-2116.7227,14.1018,0.6403,-1,-1,300); // Garbage 4
	GarbageVehicles[4] = AddStaticVehicleEx(408,2474.4385,-2116.6218,14.0943,2.2394,-1,-1,300); // Garbage 5
	GarbageVehicles[5] = AddStaticVehicleEx(408,2480.3513,-2116.6707,14.0944,359.6030,-1,-1,300); // Garbage 6
	GarbageVehicles[6] = AddStaticVehicleEx(408,2485.4556,-2116.5200,14.0988,1.4351,-1,-1,300); // Garbage 7
	GarbageVehicles[7] = AddStaticVehicleEx(408,2491.1963,-2116.4548,14.0918,0.3940,-1,-1,300); // Garbage 8
}

stock Garbage_IsDriver(playerid, vehicleid)
{
	return gPlayerLogged{playerid} && 0 < vehicleid < MAX_VEHICLES && IsValidVehicle(vehicleid) && IsInGarbageTruck(vehicleid)
		&& GetPlayerState(playerid) == PLAYER_STATE_DRIVER && GetPlayerVehicleID(playerid) == vehicleid
		&& GetPlayerVirtualWorld(playerid) == 0 && GetPlayerInterior(playerid) == 0
		&& GetVehicleVirtualWorld(vehicleid) == 0 && GetVehicleInterior(vehicleid) == 0
		&& !PlayerIsDead[playerid] && !PlayerInfo[playerid][pHospital] && !GetPVarInt(playerid, "Injured")
		&& !PlayerCuffed[playerid] && !GetPVarInt(playerid, "PlayerCuffed") && !GetPVarInt(playerid, "pBagged")
		&& !GetPVarType(playerid, "IsFrozen") && !GetPVarType(playerid, "IsTackled")
		&& (Job_HasJob(playerid, JOB_GARBAGE));
}

stock Garbage_GetDestination(playerid, &Float:x, &Float:y, &Float:z)
{
	if(!GetPVarInt(playerid, "pGarbageRun")) return 0;
	new path = GetPVarInt(playerid, "pGarbagePath"), stage = GetPVarInt(playerid, "pGarbageStage");
	if(!(0 <= path < sizeof(GarbageRoutes)) || !(0 <= stage <= 5)) return 0;
	if(stage == 5)
	{
		x = 2520.4834;
		y = -2089.1470;
		z = 13.5469;
	}
	else
	{
		x = GarbageRoutes[path][stage][0];
		y = GarbageRoutes[path][stage][1];
		z = GarbageRoutes[path][stage][2];
	}
	return 1;
}

stock Garbage_HasCheckpoint(playerid)
{
	new Float:x, Float:y, Float:z, Float:cx, Float:cy, Float:cz, Float:radius;
	return Garbage_GetDestination(playerid, x, y, z) && GetPlayerCheckpoint(playerid, cx, cy, cz, radius)
		&& x == cx && y == cy && z == cz && radius == 4.0;
}

stock Garbage_StopLoading(playerid, bool:restore = true)
{
	new timer = GetPVarInt(playerid, "GarbageLoadTimer");
	if(!timer) return 1;
	KillTimer(timer);
	DeletePVar(playerid, "GarbageLoadTimer");
	if(restore && !PlayerIsDead[playerid] && !PlayerInfo[playerid][pHospital] && !PlayerCuffed[playerid]
		&& !GetPVarInt(playerid, "PlayerCuffed") && !GetPVarInt(playerid, "pBagged") && !GetPVarInt(playerid, "Injured")
		&& !GetPVarType(playerid, "IsFrozen") && !GetPVarType(playerid, "IsTackled"))
		TogglePlayerControllable(playerid, true);
	return 1;
}

stock Garbage_CancelRun(playerid, bool:restore = true)
{
	Garbage_StopLoading(playerid, restore);
	if(Garbage_HasCheckpoint(playerid)) DisablePlayerCheckpoint(playerid);
	DeletePVar(playerid, "pGarbageRun");
	DeletePVar(playerid, "pGarbageStage");
	DeletePVar(playerid, "pGarbagePath");
	DeletePVar(playerid, "pGarbageVehicle");
	return 1;
}

stock Garbage_ClearVehicleWork(playerid, vehicleid)
{
	if(GetPVarInt(playerid, "pGarbageRun") && GetPVarInt(playerid, "pGarbageVehicle") == vehicleid)
	{
		Garbage_CancelRun(playerid);
		SendClientMessageEx(playerid, COLOR_GREY, "Chuyen rac da huy vi xe khong con hop le.");
	}
	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	Garbage_CancelRun(playerid, false);
	return 1;
}

hook OnPlayerDeath(playerid, killerid, reason)
{
	Garbage_CancelRun(playerid, false);
	return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(GetPVarType(playerid, "GarbageLoadTimer") && (newstate != PLAYER_STATE_DRIVER
		|| GetPlayerVehicleID(playerid) != GetPVarInt(playerid, "pGarbageVehicle")))
		Garbage_StopLoading(playerid, newstate != PLAYER_STATE_WASTED && newstate != PLAYER_STATE_SPECTATING);
	return 1;
}

hook OnPlayerEnterCheckpoint(playerid)
{
	if(!GetPVarInt(playerid, "pGarbageRun")) return 1;
	if(!Garbage_HasCheckpoint(playerid))
	{
		Garbage_CancelRun(playerid);
		return 1;
	}
	new Float:x, Float:y, Float:z;
	Garbage_GetDestination(playerid, x, y, z);
	if(!IsPlayerInRangeOfPoint(playerid, 4.0, x, y, z)) return 1;
	new vehicleid = GetPVarInt(playerid, "pGarbageVehicle");
	if(!Garbage_IsDriver(playerid, vehicleid))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Phai lai dung xe rac ban dau de tiep tuc.");
		return ~1;
	}
	new stage = GetPVarInt(playerid, "pGarbageStage");
	if(stage < 5)
	{
		if(GetPVarType(playerid, "GarbageLoadTimer") || !IsPlayerControllable(playerid)) return ~1;
		new timer = SetTimerEx("GarbageJobLoad", 4000, false, "iiiii", playerid, g_arrQueryHandle[playerid], ++GarbageLoadSerial[playerid], vehicleid, stage);
		if(!timer) return ~1;
		SetPVarInt(playerid, "GarbageLoadTimer", timer);
		TogglePlayerControllable(playerid, false);
		GameTextForPlayer(playerid, "~W~DANG TAI...", 4000, 4);
		return ~1;
	}
	new value = Random(10000, 20000), gained = PlayerInfo[playerid][pDoubleEXP] > 0 ? 2 : 1;
	if(GetPlayerCash(playerid) > cellmax - value)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong nhan duoc tien chuyen rac. Bot tien mat roi ve bai rac.");
		return ~1;
	}
	if(PlayerInfo[playerid][pGarbageSkill] > cellmax - gained) gained = cellmax - PlayerInfo[playerid][pGarbageSkill];
	Garbage_CancelRun(playerid);
	GivePlayerCash(playerid, value);
	PlayerInfo[playerid][pGarbageSkill] += gained;
	SetVehicleToRespawn(vehicleid);
	SendClientMessageEx(playerid, COLOR_WHITE, "Ban da xong chuyen rac va nhan $%s.", number_format(value));
	if(PlayerInfo[playerid][pDoubleEXP] > 0)
		SendClientMessageEx(playerid, COLOR_YELLOW, "Ban nhan %d diem garbage. Token Double EXP con %d gio.", gained, PlayerInfo[playerid][pDoubleEXP]);
	return ~1;
}

CMD:garbagerun(playerid, params[])
{
	if(!Job_HasJob(playerid, JOB_GARBAGE))
		return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong phai garbage man!");
	if(GetPVarInt(playerid, "pGarbageRun"))
		return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban dang trong chuyen rac!");
	new vehicleid = GetPlayerVehicleID(playerid);
	if(!Garbage_IsDriver(playerid, vehicleid) || !IsPlayerControllable(playerid))
		return SendClientMessageEx(playerid, COLOR_GRAD1, "Can lai xe rac san sang o world thuong.");
	if(CheckPointCheck(playerid) || IsPlayerCheckpointActive(playerid))
		return SendClientMessageEx(playerid, COLOR_GREY, "Xong hoac huy checkpoint truoc khi nhan chuyen rac.");
	SetPVarInt(playerid, "pGarbageRun", 1);
	SetPVarInt(playerid, "pGarbageStage", 0);
	SetPVarInt(playerid, "pGarbageVehicle", vehicleid);
	SetPVarInt(playerid, "pGarbagePath", random(sizeof(GarbageRoutes)));
	AdvanceGarbageJob(playerid);
	SendClientMessageEx(playerid, COLOR_YELLOW, "Da bat dau chuyen rac, hay den diem dau tien.");
	return 1;
}

AdvanceGarbageJob(playerid)
{
	new Float:x, Float:y, Float:z;
	if(!Garbage_GetDestination(playerid, x, y, z)) return 0;
	SetPlayerCheckpoint(playerid, x, y, z, 4.0);
	return 1;
}

forward GarbageJobLoad(playerid, session, serial, vehicleid, stage);
public GarbageJobLoad(playerid, session, serial, vehicleid, stage)
{
	if(!(0 <= playerid < MAX_PLAYERS) || !IsPlayerConnected(playerid) || g_arrQueryHandle[playerid] != session) return 1;
	if(GarbageLoadSerial[playerid] != serial || !GetPVarType(playerid, "GarbageLoadTimer")) return 1;
	new Float:x, Float:y, Float:z;
	if(!Garbage_IsDriver(playerid, vehicleid) || GetPVarInt(playerid, "pGarbageVehicle") != vehicleid
		|| GetPVarInt(playerid, "pGarbageStage") != stage || !(0 <= stage < 5) || !Garbage_HasCheckpoint(playerid)
		|| !Garbage_GetDestination(playerid, x, y, z) || !IsPlayerInRangeOfPoint(playerid, 4.0, x, y, z))
	{
		Garbage_StopLoading(playerid);
		return 1;
	}
	Garbage_StopLoading(playerid);
	SetPVarInt(playerid, "pGarbageStage", stage + 1);
	AdvanceGarbageJob(playerid);
	SendClientMessageEx(playerid, COLOR_WHITE, stage == 4
		? ("Xe rac da day, hay quay ve tru so.")
		: ("Da thu gom rac, hay den checkpoint tiep theo."));
	return 1;
}
