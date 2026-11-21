/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Admin System

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

#define 		ADMIN_JUNIOR 		2
#define 		ADMIN_GENERAL		3
#define 		ADMIN_SENIOR 		4
#define 		ADMIN_HEAD			1337
#define 		ADMIN_EXECUTIVE 	99999

stock IsAdminLevel(playerid, level, warning = 1) {

	if(PlayerInfo[playerid][pAdmin] >= level) return 1;
	if(warning) SendClientMessage(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 0;
}

stock ABroadCastText(hColor, const szMessage[], iLevel, bool:bUndercover = false, bool:Discord = true)
{
	new message[sizeof(szMiscArray)];
	format(message, sizeof(message), "%s", szMessage);
	return ABroadCast(hColor, message, iLevel, bUndercover, Discord);
}

stock ABroadCast(hColor, szMessage[], iLevel, bool: bUndercover = false, bool: Discord = true)
{
	foreach(new i: Player) {
		if(PlayerInfo[i][pAdmin] >= iLevel && (bUndercover || !PlayerInfo[i][pTogReports])) {
			SendClientMessageEx(i, hColor, szMessage);
		}
	}
	if(!Discord && iLevel <= 2) SendDiscordMessage(0, szMessage);
	if(strfind(szMessage, "AdmWarning", false) != -1)
	{
		StripColorEmbedding(szMessage);
		SendDiscordMessage(1, szMessage); // Route AdmWarnings to Discord
	}
	return 1;
}

stock ShopTechBroadCast(color,const string[])
{
	foreach(new i: Player)
	{
		if ((PlayerInfo[i][pShopTech] >= 1 || PlayerInfo[i][pAdmin] >= 1338) && PlayerInfo[i][pTogReports] == 0)
		{
			SendClientMessageEx(i, color, string);
		}
	}
	return 1;
}

stock Player_KillCheckPoint(playerid) {
	if(PlayerInfo[playerid][pTut] != -1) {
		SendClientMessageEx(playerid, COLOR_GREY, "-----------------------------");
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban da huy huong dan muc tieu. Chao mung den Next Generation Gaming!");
		SendClientMessageEx(playerid, COLOR_GREY, "-----------------------------");
		PlayerInfo[playerid][pTut] = -1;
	}
	gPlayerCheckpointStatus[playerid] = CHECKPOINT_NOTHING;
	ClearCheckpoint(playerid);
	DisablePlayerCheckpoint(playerid);
	SendClientMessageEx(playerid,COLOR_WHITE, "Da dat lai moi checkpoint, theo doi va cuoc xe da nhan.");
}


stock GetAdminRankName(i)
{
	switch(i)
	{
		case 2: format(szMiscArray, sizeof(szMiscArray), "Junior Administrator");
		case 3: format(szMiscArray, sizeof(szMiscArray), "General Administrator");
		case 4: format(szMiscArray, sizeof(szMiscArray), "Senior Administrator");
		case 1337: format(szMiscArray, sizeof(szMiscArray), "Head Administrator");
		case 99999: format(szMiscArray, sizeof(szMiscArray), "Executive Administrator");
		default: format(szMiscArray, sizeof(szMiscArray), "Undefined Administrator (%i)", i);
	}
	return szMiscArray;
}

stock StaffAccountCheck(playerid, ip[])
{
	mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "SELECT NULL FROM `accounts` WHERE (`IP` = '%s' OR `SecureIP` = '%s') AND `AdminLevel` > 0", ip, ip);
	mysql_tquery(MainPipeline, szMiscArray, "OnStaffAccountCheck", "i", playerid);
}

stock GetStaffRank(playerid)
{
	if(PlayerInfo[playerid][pSEC] > 0)
	{
		switch(PlayerInfo[playerid][pSEC])
		{
			case 1: szMiscArray = "{00FA9A}Regular Coordinator{FFFFFF}";
			case 2: szMiscArray = "{00FA9A}Senior Coordinator{FFFFFF}";
			case 3: szMiscArray = "{00FA9A}Assistant Chairman{FFFFFF}";
			case 4: szMiscArray = "{00FA9A}Deputy Chairman{FFFFFF}";
			case 5: szMiscArray = "{00FA9A}Chairman{FFFFFF}";
		}
	}
	if(PlayerInfo[playerid][pWatchdog] > 0)
	{
		switch(PlayerInfo[playerid][pWatchdog])
		{
			case 1: szMiscArray = "{2267F0}Watchdog{FFFFFF}";
			case 2: szMiscArray = "{2267F0}Senior Watchdog{FFFFFF}";
			case 3: szMiscArray = "{2267F0}RP Specialist{FFFFFF}";
			case 4: szMiscArray = "{2267F0}Director of RP Improvement{FFFFFF}";
		}
	}

	if(PlayerInfo[playerid][pHelper] > 0)
	{
		switch(PlayerInfo[playerid][pHelper])
		{
			case 1: szMiscArray = "{6495ED}Helper{FFFFFF}";
			case 2: szMiscArray = "{00FFFF}Community Advisor{FFFFFF}";
			case 3: szMiscArray = "{00FFFF}Senior Advisor{FFFFFF}";
			case 4: szMiscArray = "{00FFFF}Chief Advisor{FFFFFF}";
		}
	}

	if(PlayerInfo[playerid][pAdmin] == 1)
	{
		switch(PlayerInfo[playerid][pSMod])
		{
			case 0: szMiscArray = "{FFFF00}Server Moderator{FFFFFF}";
			case 1: szMiscArray = "{FFFF00}Senior Server Moderator{FFFFFF}";
		}
	}
	if(PlayerInfo[playerid][pAdmin] > 1)
	{
		switch(PlayerInfo[playerid][pAdmin])
		{
			case 2: szMiscArray = "{00FF00}Junior Administrator{FFFFFF}";
			case 3: szMiscArray = "{00FF00}General Administrator{FFFFFF}";
			case 4: szMiscArray = "{F4A460}Senior Administrator{FFFFFF}";
			case 1337: szMiscArray = "{FF0000}Head Administrator{FFFFFF}";
			case 99999: szMiscArray = "{298EFF}Executive Administrator{FFFFFF}";
			default: format(szMiscArray, sizeof(szMiscArray), "Undefined Administrator (%d)", PlayerInfo[playerid][pAdmin]);
		}
	}
	return szMiscArray;
}

CMD:resetvw(playerid, params[])
{
	if(GetPVarType(playerid, "IsInArena")) return 1;
	SetPlayerVirtualWorld(playerid, PlayerInfo[playerid][pVW]);
	SetPlayerInterior(playerid, PlayerInfo[playerid][pInt]);
	SendClientMessageEx(playerid, COLOR_WHITE, "Da dong bo VW va noi that voi may chu. Neu van mat dong bo, hay dang nhap lai.");
	return 1;
}

CMD:id(playerid, params[]) {
	if(isnull(params)) {
		return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /id [player name]");
	}

	new
		szMessage[128],
		szPlayerName[MAX_PLAYER_NAME],
		iTargetID = strval(params);

	if(IsNumericString(params) && IsPlayerConnected(strval(params)))
	{
	    if(PlayerInfo[playerid][pAdmin] >= 2) format(szMessage, sizeof szMessage, "%s (ID: %d . Gio: %s . Ping: %d . FPS: %d . Mat goi tin: %.2f)", GetPlayerNameEx(iTargetID), iTargetID, number_format(PlayerInfo[iTargetID][pConnectHours]), GetPlayerPing(iTargetID), GetPlayerFPS(iTargetID), GetPlayerPacketLoss(iTargetID));
		else format(szMessage, sizeof szMessage, "%s (ID: %d . Cap: %d . Ping: %d)", GetPlayerNameEx(iTargetID), iTargetID, GetPlayerScore(iTargetID), GetPlayerPing(iTargetID));
		return SendClientMessageEx(playerid, COLOR_WHITE, szMessage);
	}
	else if(strlen(params) < 3) {
		return SendClientMessageEx(playerid, COLOR_GREY, "Nhap it nhat 3 ky tu de tim.");
	}
	else foreach(new i: Player)
	{
		GetPlayerName(i, szPlayerName, sizeof szPlayerName);
		if(strfind(szPlayerName, params, true) != -1) {
			if(PlayerInfo[playerid][pAdmin] >= 2) format(szMessage, sizeof szMessage, "%s (ID: %d . Gio: %s . Ping: %d . FPS: %d . Mat goi tin: %.2f)", GetPlayerNameEx(i), i, number_format(PlayerInfo[i][pConnectHours]), GetPlayerPing(i), GetPlayerFPS(i), GetPlayerPacketLoss(i));
			else format(szMessage, sizeof szMessage, "%s (ID: %d . Cap: %d . Ping: %d)", GetPlayerNameEx(i), i, GetPlayerScore(i), GetPlayerPing(i));
			SendClientMessageEx(playerid, COLOR_WHITE, szMessage);
		}
	}
	return 1;
}

CMD:near(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2)
	{
		new radius;
		if(sscanf(params, "d", radius)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /near [radius]");
		if(radius < 1 || radius > 100) return SendClientMessageEx(playerid, COLOR_GREY, "Ban kinh phai lon hon 0 va nho hon 100!");

		SendClientMessageEx(playerid, COLOR_GRAD5, "Nguoi trong ban kinh %d khu nha", radius);
        foreach(new i: Player)
		{
			if(i != playerid && ProxDetectorS(radius, playerid, i))
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "%s (ID: %d - Gio: %s)", GetPlayerNameEx(i), i, number_format(PlayerInfo[i][pConnectHours]));
			}
		}
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:givegun(playerid, params[])
{
    if (PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1) {
        new playa, gun;

        if(sscanf(params, "ud", playa, gun)) {
            SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /givegun [player] [weaponid]");
            SendClientMessageEx(playerid, COLOR_GREEN, "_______________________________________");
            SendClientMessageEx(playerid, COLOR_GRAD4, "(1)Brass Knuckles (2)Golf Club (3)Nite Stick (4)Knife (5)Baseball Bat (6)Shovel (7)Pool Cue (8)Katana (9)Chainsaw");
            SendClientMessageEx(playerid, COLOR_GRAD4, "(10)Purple Dildo (11)Small White Vibrator (12)Large White Vibrator (13)Silver Vibrator (14)Flowers (15)Cane (16)Frag Grenade");
            SendClientMessageEx(playerid, COLOR_GRAD3, "(17)Tear Gas (18)Molotov Cocktail (21)Jetpack (22)9mm (23)Silenced 9mm (24)Desert Eagle (25)Shotgun (26)Sawnoff Shotgun");
            SendClientMessageEx(playerid, COLOR_GRAD4, "(27)Combat Shotgun (28)Micro SMG (Mac 10) (29)SMG (MP5) (30)AK-47 (31)M4 (32)Tec9 (33)Rifle (34)Sniper Rifle");
            SendClientMessageEx(playerid, COLOR_GRAD4, "(35)Rocket Launcher (36)HS Rocket Launcher (37)Flamethrower (38)Minigun (39)Satchel Charge (40)Detonator");
            SendClientMessageEx(playerid, COLOR_GRAD4, "(41)Spraycan (42)Fire Extinguisher (43)Camera (44)Nightvision Goggles (45)Infared Goggles (46)Parachute");
            SendClientMessageEx(playerid, COLOR_GREEN, "_______________________________________");
            return 1;
        }

        format(szMiscArray, sizeof(szMiscArray), "Da tang %s vu khi ID %d!", GetPlayerNameEx(playa), gun);
        if(gun < 1||gun > 47)
            { SendClientMessageEx(playerid, COLOR_GRAD1, "ID vu khi khong hop le!"); return 1; }
        if(IsPlayerConnected(playa))
		{
            if((PlayerInfo[playa][pConnectHours] < 2 || PlayerInfo[playa][pWRestricted] > 0) && gun != 46 && gun != 43) return SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do dang bi han che mang vu khi");
			if(PlayerInfo[playa][pAccountRestricted] != 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the thao tac voi tai khoan dang bi han che!");
		    if(playa != INVALID_PLAYER_ID && gun <= 20 || gun >= 22) {
                PlayerInfo[playa][pGuns][GetLoadoutWeaponSlot(gun)] = gun;
                GivePlayerValidWeapon(playa, gun);
                SendClientMessageEx(playerid, COLOR_GRAD1, szMiscArray);
            }
            else if(playa != INVALID_PLAYER_ID && gun == 21) {
                JetPack[playa] = 1;
                SetPlayerSpecialAction(playa, SPECIAL_ACTION_USEJETPACK);
                SendClientMessageEx(playerid, COLOR_GRAD1, szMiscArray);
            }
			format(szMiscArray, sizeof(szMiscArray), "%s(%s) has given %s(%d) (%s) a %s(%d)", GetPlayerNameEx(playerid), GetPlayerIpEx(playerid), GetPlayerNameEx(playa), GetPlayerSQLId(playa), GetPlayerIpEx(playa), GetWeaponNameEx(gun), gun);
			Log("logs/admingive.log", szMiscArray);
        }
    }
    else {
        SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
    }
    return 1;
}

CMD:givedrug(playerid, params[])
{
    if (PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
    {
        new id, drugstring[16], amount;

        if(sscanf(params, "us[16]d", id, drugstring, amount))
        {
            SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /givedrug [player] [drug] [amount]");
            ListDrugs(playerid);
            return 1;
        }

        new drug = GetDrugID(drugstring);
        if(drug == -1)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /givedrug [player] [drug] [amount]");
			ListDrugs(playerid);
			return 1;
		}

		if(IsPlayerConnected(id))
		{
			PlayerInfo[id][pDrugs][drug] += amount;
			SendClientMessageEx(playerid, COLOR_GRAD1, "Da tang %s chat %s (%dg)!", GetPlayerNameEx(id), GetDrugName(drug), amount);

			format(szMiscArray, sizeof(szMiscArray), "%s(%s) has given %s(%d) (%s) some %s(%dg)", GetPlayerNameEx(playerid), GetPlayerIpEx(playerid), GetPlayerNameEx(id), GetPlayerSQLId(id), GetPlayerIpEx(id), GetDrugName(drug), amount);
			Log("logs/admingive.log", szMiscArray);
		}
		else return SendClientMessage(playerid, COLOR_GRAD1, "Nguoi do chua ket noi.");
    }
    else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
    return 1;
}

CMD:jetpack(playerid, params[])
{
	new plo;
	if((PlayerInfo[playerid][pAdmin] >= 2) && sscanf(params, "u", plo)) {
        JetPack[playerid] = 1;
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
        return 1;
    }
	else if(PlayerInfo[playerid][pAdmin] >= 4 && !sscanf(params, "u", plo) || PlayerInfo[playerid][pASM] >= 1 && !sscanf(params, "u", plo))
	{
		if (IsPlayerConnected(plo))
		{
			if(plo != INVALID_PLAYER_ID)
			{
				SendClientMessageEx(plo, COLOR_GRAD1, "Chuc ban vui voi jetpack moi!");
				JetPack[plo] = 1;
				SetPlayerSpecialAction(plo, SPECIAL_ACTION_USEJETPACK);
				SendClientMessageToAllEx(COLOR_LIGHTRED, "AdmCmd: %s da nhan jetpack tu %s", GetPlayerNameEx(plo), GetPlayerNameEx(playerid));
				format(szMiscArray, sizeof(szMiscArray), "[Admin] %s (IP:%s) has given %s(%d) (IP:%s) a Jetpack.", GetPlayerNameEx(playerid), GetPlayerIpEx(playerid), GetPlayerNameEx(plo), GetPlayerSQLId(plo), GetPlayerIpEx(plo));
				Log("logs/admingive.log", szMiscArray);
			}
		}
		else return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
    return 1;
}

CMD:sethp(playerid, params[])
{
	new playa, health;
	if(sscanf(params, "ud", playa, health)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /sethp [player] [health]");
	if(PlayerInfo[playa][pJailTime] >= 1 && strfind(PlayerInfo[playerid][pPrisonReason], "[OOC]", true) != -1) return SendClientMessage(playerid, COLOR_WHITE, "Khong the dat mau cho tu nhan OOC!");
	if((PlayerInfo[playa][pAdmin] >= PlayerInfo[playerid][pAdmin]) && playa != playerid) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung lenh voi Admin ngang hoac cao cap hon!");
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1) {
		if(IsPlayerConnected(playa)) {
			if(playa != INVALID_PLAYER_ID)
			{
				SetHealth(playa, health);
				SendClientMessageEx(playerid, COLOR_WHITE, "Da dat mau cua %s thanh %d.", GetPlayerNameEx(playa), health);
			}
		}
		else return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:setmyhp(playerid, params[])
{
    new health;
    if(sscanf(params, "d", health)) {
        SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /setmyhp [health]");
        return 1;
    }
    if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pUndercover] >= 1 || PlayerInfo[playerid][pASM] >= 1) {
        SetHealth(playerid, health);
        SendClientMessageEx(playerid, COLOR_WHITE, "Da dat mau cua ban thanh %d.", health);
    }
    else {
        SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
    }
    return 1;
}

CMD:setarmor(playerid, params[])
{
    new playa, health;
    if(sscanf(params, "ud", playa, health))
	{
        SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /setarmor [player] [armor]");
        return 1;
    }
    if (PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
        if(IsPlayerConnected(playa))
		{
            if(playa != INVALID_PLAYER_ID)
			{
                SetArmour(playa, health);
                SendClientMessageEx(playerid, COLOR_WHITE, "Da dat giap cua %s thanh %d.", GetPlayerNameEx(playa), health);
            }
        }
    }
    else
	{
        SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
    }
    return 1;
}

CMD:setmyarmor(playerid, params[])
{
    new armor;
    if(sscanf(params, "d", armor))
	{
        SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /setmyarmor [amount]");
        return 1;
    }
    if (PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pUndercover] >= 1 || PlayerInfo[playerid][pASM] >= 1)
	{
        SetArmour(playerid, armor);
        SendClientMessageEx(playerid, COLOR_WHITE, "Da dat giap cua ban thanh %d.", armor);
    }
    else
	{
        SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
    }
    return 1;
}

CMD:setarmorall(playerid, params[])
{
    new armor;
    if(sscanf(params, "d", armor)) {
        SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /setarmorall [armor]");
        return 1;
    }

    if (PlayerInfo[playerid][pAdmin] >= 1337) {
        foreach(new i: Player)
		{
			SetArmour(i, armor);
		}
    }

    else {
        SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
    }
    return 1;
}

CMD:loadcfgs(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 1337) {
        SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
        return 1;
    }
    SendClientMessageEx(playerid, COLOR_WHITE, "* Dang tai lai file CFG..");
    g_mysql_LoadMOTD();
	// Local Configs
	Misc_Load();
    SendClientMessageEx(playerid, COLOR_WHITE, "* Hoan tat");
    return 1;
}

CMD:admins(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 2) {
        SendClientMessageEx(playerid, COLOR_GRAD1, "Admin dang online:");
        foreach(new i: Player)
		{
			if(PlayerInfo[i][pAdmin] >= 2 && PlayerInfo[i][pAdmin] <= PlayerInfo[playerid][pAdmin]) {
				new tdate[11], thour[9], i_timestamp[3];
				getdate(i_timestamp[0], i_timestamp[1], i_timestamp[2]);
				format(tdate, sizeof(tdate), "%d-%02d-%02d", i_timestamp[0], i_timestamp[1], i_timestamp[2]);
				format(thour, sizeof(thour), "%02d:00:00", gServerHour);

				if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
				{
					if(PlayerInfo[i][pAdmin] == 2) format(szMiscArray, sizeof(szMiscArray), "%s{BFC0C2}: %s (RTH: %d | RT: %d)", GetStaffRank(i), GetPlayerNameEx(i), ReportHourCount[i], ReportCount[i]);
					else if(PlayerInfo[i][pAdmin] == 3) format(szMiscArray, sizeof(szMiscArray), "%s{BFC0C2}: %s (RTH: %d | RT: %d)", GetStaffRank(i), GetPlayerNameEx(i), ReportHourCount[i], ReportCount[i]);
					else if(PlayerInfo[i][pAdmin] == 4) format(szMiscArray, sizeof(szMiscArray), "%s{BFC0C2}: %s (RTH: %d | RT: %d)", GetStaffRank(i), GetPlayerNameEx(i), ReportHourCount[i], ReportCount[i]);
					else if(PlayerInfo[i][pAdmin] == 1337) format(szMiscArray, sizeof(szMiscArray), "%s{BFC0C2}: %s (RTH: %d | RT: %d)", GetStaffRank(i), GetPlayerNameEx(i), ReportHourCount[i], ReportCount[i]);
					else if(PlayerInfo[i][pAdmin] == 1338) format(szMiscArray, sizeof(szMiscArray), "%s{BFC0C2}: %s (RTH: %d | RT: %d)", GetStaffRank(i), GetPlayerNameEx(i), ReportHourCount[i], ReportCount[i]);
					else if(PlayerInfo[i][pAdmin] == 99999) format(szMiscArray, sizeof(szMiscArray), "%s{BFC0C2}: %s (RTH: %d | RT: %d)", GetStaffRank(i), GetPlayerNameEx(i), ReportHourCount[i], ReportCount[i]);
					else format(szMiscArray, sizeof(szMiscArray), "%s{BFC0C2}: %s", GetStaffRank(i), PlayerInfo[i][pAdmin], GetPlayerNameEx(i));
				}
				else
				{
					if(PlayerInfo[i][pAdmin] == 2) format(szMiscArray, sizeof(szMiscArray), "%s{BFC0C2}: %s", GetStaffRank(i), GetPlayerNameEx(i));
					else if(PlayerInfo[i][pAdmin] == 3) format(szMiscArray, sizeof(szMiscArray), "%s{BFC0C2}: %s", GetStaffRank(i), GetPlayerNameEx(i));
					else if(PlayerInfo[i][pAdmin] == 4) format(szMiscArray, sizeof(szMiscArray), "%s{BFC0C2}: %s", GetStaffRank(i), GetPlayerNameEx(i));
					else if(PlayerInfo[i][pAdmin] == 1337) format(szMiscArray, sizeof(szMiscArray), "%s{BFC0C2}: %s", GetStaffRank(i), GetPlayerNameEx(i));
					else if(PlayerInfo[i][pAdmin] == 1338) format(szMiscArray, sizeof(szMiscArray), "%s{BFC0C2}: %s", GetStaffRank(i), GetPlayerNameEx(i));
					else if(PlayerInfo[i][pAdmin] == 99999) format(szMiscArray, sizeof(szMiscArray), "%s{BFC0C2}: %s", GetStaffRank(i), GetPlayerNameEx(i));
					else format(szMiscArray, sizeof(szMiscArray), "%s{BFC0C2}: %s", PlayerInfo[i][pAdmin], GetPlayerNameEx(i));
				}

				if(PlayerInfo[i][pBanAppealer] == 1) strcat(szMiscArray, " [BA]");
				if(PlayerInfo[i][pBanAppealer] == 2) strcat(szMiscArray, " [DOCI]");
				if(PlayerInfo[i][pShopTech] == 1) strcat(szMiscArray, " [ST]");
				if(PlayerInfo[i][pShopTech] == 2) strcat(szMiscArray, " [SST]");
				if(PlayerInfo[i][pShopTech] == 3) strcat(szMiscArray, " [DOCR]");
				if(PlayerInfo[i][pUndercover] == 1) strcat(szMiscArray, " [UC]");
				if(PlayerInfo[i][pUndercover] == 2) strcat(szMiscArray, " [DOSO]");
				if(PlayerInfo[i][pFactionModerator] == 1) strcat(szMiscArray, " [FMOD]");
				if(PlayerInfo[i][pFactionModerator] == 2) strcat(szMiscArray, " [DOFM]");
				if(PlayerInfo[i][pGangModerator] == 1) strcat(szMiscArray, " [GMOD]");
				if(PlayerInfo[i][pGangModerator] == 2) strcat(szMiscArray, " [DOGM]");
				if(PlayerInfo[i][pTogReports]) strcat(szMiscArray, " [SPEC MODE]");
				if(PlayerInfo[i][pPR] == 1) strcat(szMiscArray, " [PR]");
				if(PlayerInfo[i][pPR] == 2) strcat(szMiscArray, " [DOPR]");
				if(PlayerInfo[i][pHR] >= 1) strcat(szMiscArray, " [HR]");
				if(PlayerInfo[i][pAP] >= 1) strcat(szMiscArray, " [AP]");
				if(PlayerInfo[i][pWatchdog] == 4) strcat(szMiscArray, " [DoRPI]");
				if(PlayerInfo[i][pSecurity] >= 1) strcat(szMiscArray, " [Sec]");
				if(PlayerInfo[i][pBM] == 1) strcat(szMiscArray, " [BM]");
				if(PlayerInfo[i][pBM] == 2) strcat(szMiscArray, " [DOBM]");
				if(PlayerInfo[i][pASM] == 1) strcat(szMiscArray, " [ASM]");
				SendClientMessageEx(playerid, COLOR_GRAD2, szMiscArray);
			}
		}
    }
    else {
        SendClientMessageEx(playerid, COLOR_GRAD1, "Can hoi ve cach choi hoac may chu, dung /requesthelp hoac /newb");
        SendClientMessageEx(playerid, COLOR_GRAD1, "Phat hien vi pham hoac can Admin ho tro, dung /report");
    }
    return 1;
}

CMD:dn(playerid, params[])
{
    if (PlayerInfo[playerid][pAdmin] >= 2)
	{
        new Float:slx, Float:sly, Float:slz;
		GetPlayerPos(playerid, slx, sly, slz);
		if (GetPlayerState(playerid) == 2)
		{
			new tmpcar = GetPlayerVehicleID(playerid);
			SetVehiclePos(tmpcar, slx, sly, slz-2);
			fVehSpeed[playerid] = 0.0;
		}
		else
		{
			SetPlayerPos(playerid, slx, sly, slz-2);
		}
        return 1;
    }
    else
	{
        SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
    }
    return 1;
}

CMD:up(playerid, params[])
{
    if (PlayerInfo[playerid][pAdmin] >= 2)
	{
        new Float:slx, Float:sly, Float:slz;
        GetPlayerPos(playerid, slx, sly, slz);
		if (GetPlayerState(playerid) == 2)
		{
			new tmpcar = GetPlayerVehicleID(playerid);
			SetVehiclePos(tmpcar, slx, sly, slz+5);
			fVehSpeed[playerid] = 0.0;
		}
		else
		{
			SetPlayerPos(playerid, slx, sly, slz+5);
		}
        return 1;
    }
    else
	{
        SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
    }
    return 1;
}

CMD:fly(playerid, params[])
{
    if (PlayerInfo[playerid][pAdmin] >= 2) {
        new Float:px, Float:py, Float:pz, Float:pa;
        GetPlayerFacingAngle(playerid,pa);
        if(pa >= 0.0 && pa <= 22.5) {             //n1
            GetPlayerPos(playerid, px, py, pz);
			if (GetPlayerState(playerid) == 2)
			{
				new tmpcar = GetPlayerVehicleID(playerid);
				SetVehiclePos(tmpcar, px, py+30, pz+5);
				fVehSpeed[playerid] = 0.0;
			}
			else
			{
				SetPlayerPos(playerid, px, py+30, pz+5);
			}
        }
        if(pa >= 332.5 && pa < 0.0) {             //n2
            GetPlayerPos(playerid, px, py, pz);
			if (GetPlayerState(playerid) == 2)
			{
				new tmpcar = GetPlayerVehicleID(playerid);
				SetVehiclePos(tmpcar, px, py+30, pz+5);
				fVehSpeed[playerid] = 0.0;
			}
			else
			{
				SetPlayerPos(playerid, px, py+30, pz+5);
			}
        }
        if(pa >= 22.5 && pa <= 67.5) {            //nw
            GetPlayerPos(playerid, px, py, pz);
			if (GetPlayerState(playerid) == 2)
			{
				new tmpcar = GetPlayerVehicleID(playerid);
				SetVehiclePos(tmpcar, px-15, py+15, pz+5);
				fVehSpeed[playerid] = 0.0;
			}
			else
			{
				SetPlayerPos(playerid, px-15, py+15, pz+5);
			}
        }
        if(pa >= 67.5 && pa <= 112.5) {           //w
            GetPlayerPos(playerid, px, py, pz);
			if (GetPlayerState(playerid) == 2)
			{
				new tmpcar = GetPlayerVehicleID(playerid);
				SetVehiclePos(tmpcar, px-30, py, pz+5);
				fVehSpeed[playerid] = 0.0;
			}
			else
			{
				SetPlayerPos(playerid, px-30, py, pz+5);
			}
        }
        if(pa >= 112.5 && pa <= 157.5) {          //sw
            GetPlayerPos(playerid, px, py, pz);
			if (GetPlayerState(playerid) == 2)
			{
				new tmpcar = GetPlayerVehicleID(playerid);
				SetVehiclePos(tmpcar, px-15, py-15, pz+5);
				fVehSpeed[playerid] = 0.0;
			}
			else
			{
				SetPlayerPos(playerid, px-15, py-15, pz+5);
			}
        }
        if(pa >= 157.5 && pa <= 202.5) {          //s
            GetPlayerPos(playerid, px, py, pz);
			if (GetPlayerState(playerid) == 2)
			{
				new tmpcar = GetPlayerVehicleID(playerid);
				SetVehiclePos(tmpcar, px, py-30, pz+5);
				fVehSpeed[playerid] = 0.0;
			}
			else
			{
				SetPlayerPos(playerid, px, py-30, pz+5);
			}
        }
        if(pa >= 202.5 && pa <= 247.5) {          //se
            GetPlayerPos(playerid, px, py, pz);
			if (GetPlayerState(playerid) == 2)
			{
				new tmpcar = GetPlayerVehicleID(playerid);
				SetVehiclePos(tmpcar, px+15, py-15, pz+5);
				fVehSpeed[playerid] = 0.0;
			}
			else
			{
				SetPlayerPos(playerid, px+15, py-15, pz+5);
			}
        }
        if(pa >= 247.5 && pa <= 292.5) {          //e
            GetPlayerPos(playerid, px, py, pz);
			if (GetPlayerState(playerid) == 2)
			{
				new tmpcar = GetPlayerVehicleID(playerid);
				SetVehiclePos(tmpcar, px+30, py, pz+5);
				fVehSpeed[playerid] = 0.0;
			}
			else
			{
				SetPlayerPos(playerid, px+30, py, pz+5);
			}
        }
        if(pa >= 292.5 && pa <= 332.5) {          //e
            GetPlayerPos(playerid, px, py, pz);
			if (GetPlayerState(playerid) == 2)
			{
				new tmpcar = GetPlayerVehicleID(playerid);
				SetVehiclePos(tmpcar, px+15, py+15, pz+5);
				fVehSpeed[playerid] = 0.0;
			}
			else
			{
				SetPlayerPos(playerid, px+15, py+15, pz+5);
			}
        }
    }
    else {
        SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
    }
    return 1;
}

CMD:lt(playerid, params[])
{
    if (PlayerInfo[playerid][pAdmin] >= 2)
	{
        new Float:slx, Float:sly, Float:slz;
        GetPlayerPos(playerid, slx, sly, slz);
		if (GetPlayerState(playerid) == 2)
		{
			new tmpcar = GetPlayerVehicleID(playerid);
			SetVehiclePos(tmpcar, slx-2, sly, slz);
			fVehSpeed[playerid] = 0.0;
		}
		else
		{
			SetPlayerPos(playerid, slx-2, sly, slz);
		}
        return 1;
    }
    else
	{
        SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
    }
    return 1;
}

CMD:rt(playerid, params[])
{
    if (PlayerInfo[playerid][pAdmin] >= 2)
	{
        new Float:slx, Float:sly, Float:slz;
        GetPlayerPos(playerid, slx, sly, slz);
		if (GetPlayerState(playerid) == 2)
		{
			new tmpcar = GetPlayerVehicleID(playerid);
			SetVehiclePos(tmpcar, slx+2, sly, slz);
			fVehSpeed[playerid] = 0.0;
		}
		else
		{
			SetPlayerPos(playerid, slx+2, sly, slz);
		}
        return 1;
    }
    else
	{
        SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
    }
    return 1;
}

CMD:fd(playerid, params[])
{
    if (PlayerInfo[playerid][pAdmin] >= 2)
	{
        new Float:slx, Float:sly, Float:slz;
        GetPlayerPos(playerid, slx, sly, slz);
		if (GetPlayerState(playerid) == 2)
		{
			new tmpcar = GetPlayerVehicleID(playerid);
			SetVehiclePos(tmpcar, slx, sly+2, slz);
			fVehSpeed[playerid] = 0.0;
		}
		else
		{
			SetPlayerPos(playerid, slx, sly+2, slz);
		}
        return 1;
    }
    else
	{
        SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
    }
    return 1;
}

CMD:bk(playerid, params[])
{
    if (PlayerInfo[playerid][pAdmin] >= 2)
	{
        new Float:slx, Float:sly, Float:slz;
        GetPlayerPos(playerid, slx, sly, slz);
		if (GetPlayerState(playerid) == 2)
		{
			new tmpcar = GetPlayerVehicleID(playerid);
			SetVehiclePos(tmpcar, slx, sly-2, slz);
			fVehSpeed[playerid] = 0.0;
		}
		else
		{
			SetPlayerPos(playerid, slx, sly-2, slz);
		}
        return 1;
    }
    else
	{
        SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
    }
    return 1;
}

CMD:mjail(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] == 1 || PlayerInfo[playerid][pHelper] >= 2) {

		new
			iTargetID,
			szReason[64];

		if(sscanf(params, "us[64]", iTargetID, szReason)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /mjail [player] [reason]");
		}
		else if(IsPlayerConnected(iTargetID)) {
			if(PlayerInfo[iTargetID][pAdmin] == 1) {
				return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the thao tac voi Moderator.");
			}
			if(PlayerInfo[iTargetID][pAdmin] > PlayerInfo[playerid][pAdmin]) {
				return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the thao tac voi Admin.");
			}
			if(PlayerInfo[iTargetID][pHelper] >= 2) {
				return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the thao tac voi Advisor.");
			}
            if(PlayerInfo[iTargetID][pJailTime] > 0) {
			    return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do da bi giam, khong the thao tac.");
			}
			if(PrisonPlayer(playerid, iTargetID, szReason, .time=20, .custom=1) == 0) return 1;
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
		}
	}
	return 1;
}

CMD:prisoners(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2)
 	{
  		new Count;

		SendClientMessageEx(playerid, COLOR_WHITE, "----------------------------------------");
  		SendClientMessageEx(playerid, COLOR_WHITE, "Ten | Nguoi giam | Con lai | Ly do");

		foreach(new i: Player)
		{
			if(PlayerInfo[i][pJailTime] >= 1)
			{
				if(strlen(PlayerInfo[i][pPrisonReason]) >= 1 && strlen(PlayerInfo[i][pPrisonedBy]) >= 1)
				{
						Count++;
						SendClientMessageEx(playerid, COLOR_GREY, "%s (%d) | %s | %s | %s", GetPlayerNameEx(i), i, PlayerInfo[i][pPrisonedBy], TimeConvert(PlayerInfo[i][pJailTime]), PlayerInfo[i][pPrisonReason]);
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GREY, "%s (%d) | Khong ro | %s | Khong ro", GetPlayerNameEx(i), i, TimeConvert(PlayerInfo[i][pJailTime]));
				}
			}
      	}
      	SendClientMessageEx(playerid, COLOR_WHITE, "----------------------------------------");
	}
	return 1;
}

CMD:noooc(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 3)
	{
		if (!noooc)
		{
			noooc = 1;
			SendClientMessageToAllEx(COLOR_GRAD2, "   Admin da tat kenh chat OOC!");
		}
		else
		{
			noooc = 0;
			SendClientMessageToAllEx(COLOR_GRAD2, "   Admin da bat kenh chat OOC!");
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:vehname(playerid, params[]) {

	if(PlayerInfo[playerid][pAdmin] >= 2) {

		SendClientMessageEx(playerid, COLOR_YELLOW, "--------------------------------------------------------------------------------------------------------------------------------");
		SendClientMessageEx(playerid, COLOR_WHITE, "Tim xe:");

		if(isnull(params)) return SendClientMessageEx(playerid, COLOR_GREY, "Chua nhap tu khoa.");
		if(!params[2]) return SendClientMessageEx(playerid, COLOR_GREY, "Tu khoa qua ngan.");
		szMiscArray[0] = 0;
		for(new v; v < sizeof(VehicleName); v++) {
			new vehicleName[18];
			strunpack(vehicleName, VehicleName[v], sizeof(vehicleName));
			if(strfind(vehicleName, params, true) != -1) {

				if(isnull(szMiscArray)) format(szMiscArray, sizeof(szMiscArray), "%s (ID %d)", vehicleName, v+400);
				else format(szMiscArray, sizeof(szMiscArray), "%s | %s (ID %d)", szMiscArray, vehicleName, v+400);
			}
		}

		if(!szMiscArray[0]) SendClientMessageEx(playerid, COLOR_GREY, "Khong tim thay ket qua.");
		//else if(szMiscArray[127]) SendClientMessageEx(playerid, COLOR_GREY, "Too many results found.");
		else SendClientMessageEx(playerid, COLOR_WHITE, szMiscArray);

		SendClientMessageEx(playerid, COLOR_YELLOW, "--------------------------------------------------------------------------------------------------------------------------------");
	}
	return 1;
}

CMD:mstats(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) {
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
		return 1;
	}
	else {
	    new stats[256];
		mysql_stat(stats, sizeof(stats), MainPipeline);
		SendClientMessageEx(playerid, COLOR_GREEN,"___________________________________________________________________________________________________");
		SendClientMessageEx(playerid, COLOR_GREY, stats);
		SendClientMessageEx(playerid, COLOR_GREEN,"___________________________________________________________________________________________________");
		#if defined SHOPAUTOMATED
		mysql_stat(stats, sizeof(stats), ShopPipeline);
		SendClientMessageEx(playerid, COLOR_GREEN,"___________________________________________________________________________________________________");
		SendClientMessageEx(playerid, COLOR_GREY, stats);
		SendClientMessageEx(playerid, COLOR_GREEN,"___________________________________________________________________________________________________");
		#endif
	}
	return 1;
}

CMD:netstats(playerid, params[]) {
	if(gPlayerLogged{playerid} != 0) {
		new strStats[401], szTitle[64];
		GetPlayerNetworkStats(playerid, strStats, sizeof(strStats));
		format(szTitle, sizeof(szTitle), "Thong ke mang (ID: %d) - %s", playerid, GetPlayerNameEx(playerid));
		ShowPlayerDialogEx(playerid, 0, DIALOG_STYLE_MSGBOX, szTitle, strStats, "Dong", "");
	}
	return 1;
}

CMD:anetstats(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] < 2) {
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
		return 1;
	}

	new giveplayerid, strStats[401], szTitle[64];
	if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /anetstats [player]");

	if(gPlayerLogged{giveplayerid} != 0) {
		GetPlayerNetworkStats(giveplayerid, strStats, sizeof(strStats));
		format(szTitle, sizeof(szTitle), "Thong ke mang (ID: %d) - %s", giveplayerid, GetPlayerNameEx(giveplayerid));
		ShowPlayerDialogEx(playerid, 0, DIALOG_STYLE_MSGBOX, szTitle, strStats, "Dong", "");
	}
	return 1;
}

// Testing Commands
CMD:playsound(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1337) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay!");

	new id, soundid;

	if(sscanf(params, "ud", id, soundid))
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /playsound [player] [soundid]");
        return 1;
	}
	else
	{
		PlayerPlaySound(id, soundid, 0, 0, 0);
	}
	return 1;
}

CMD:aobject(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1337) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay!");

	new id, objectid, bone, Float:offsetx, Float:offsety, Float:offsetz, Float:rotx, Float:roty, Float:rotz, Float:scalex, Float:scaley, Float:scalez;

	if(sscanf(params, "uddfffffffff", id, objectid, bone, offsetx, offsety, offsetz, rotx, roty, rotz, scalex, scaley, scalez))
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /aobject [player] [objectid] [bone] [offx] [offy] [offz] [rotx] [roty] [rotz] [scax] [scay] [scaz]");
        return 1;
	}
	else
	{
		if(IsPlayerAttachedObjectSlotUsed(id, 8)) RemovePlayerAttachedObject(id, 8);
		SetPlayerAttachedObject(id, 8, objectid, bone, offsetx, offsety, offsetz, rotx, roty, rotz, scalex, scaley, scalez);

		format(szMiscArray, sizeof(szMiscArray), "%s has given %s(%d) object ID %d with /aobject", GetPlayerNameEx(playerid), GetPlayerNameEx(id), GetPlayerSQLId(id), objectid);
		Log("logs/toys.log", szMiscArray);
	}
	return 1;
}

CMD:robject(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1337) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay!");

	new id;
	if(sscanf(params, "u", id))
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /robject [player]");
        return 1;
	}
	else
	{
		if(IsPlayerAttachedObjectSlotUsed(id, 9)) RemovePlayerAttachedObject(id, 9);
	}
	return 1;
}

CMD:wepreset(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 3)
	{
	    new giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /wepreset [player]");
		if(IsPlayerConnected(giveplayerid))
		{
		    if(PlayerInfo[giveplayerid][pWRestricted] > 0)
		    {
		        PlayerInfo[giveplayerid][pWRestricted] = 0;
		        format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s da dat lai thoi gian cam vu khi cua %s (ID:%d).", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), giveplayerid);
		        ABroadCast(COLOR_YELLOW, szMiscArray, 2);
		    }
		    else
		    {
		        SendClientMessageEx(playerid, COLOR_WHITE, "Vu khi cua nguoi do khong bi han che!");
			}
		}
		else
		{
		    SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi choi khong hop le.");
		}
	}
	return 1;
}

CMD:bigears(playerid, params[])
{
    if( PlayerInfo[playerid][pAdmin] >= 2) {
        ShowPlayerDialogEx(playerid, BIGEARS, DIALOG_STYLE_LIST, "Hay chon vat pham de tiep tuc", "Chat toan may chu\nOOC Chat\nIC Chat\nNhom OOC\nChat gia dinh\nNguoi choi\nTin nhan rieng\nTat Bigears", "Chon", "Huy");
    }
    return 1;
}

CMD:clearall(playerid, params[])
{
    if (PlayerInfo[playerid][pAdmin] >= 1337) {
        foreach(new i: Player)
        {
			PlayerInfo[i][pWantedLevel] = 0;
			SetPlayerToTeamColor(i);
			SetPlayerWantedLevel(i, 0);
			ClearCrimes(i);
		}
        SendClientMessageEx(playerid,COLOR_GRAD1, "Da xoa muc truy na cua moi nguoi.");
    }
    else {
        SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
    }
    return 1;
}

CMD:savechars(playerid, params[])
{
    if (PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1) {
        SaveEventPoints();
        //mysql_SaveCrates();
        SendClientMessageEx(playerid, COLOR_YELLOW, "Da luu tat ca crate.");
        SaveAllAccountsUpdate();
		//g_mysql_DumpAccounts();
        SendClientMessageEx(playerid, COLOR_YELLOW, "Da bat dau luu, hay cho xac nhan luu tai khoan hoan tat.");
        SaveHouses();
        SendClientMessageEx(playerid, COLOR_YELLOW, "Da bat dau luu nha.");
    }
    else {
        SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
    }
    return 1;
}

CMD:setcolor(playerid, params[])
{
    if (PlayerInfo[playerid][pAdmin] >= 1337)
	{
        ShowPlayerDialogEx(playerid, COLORMENU, DIALOG_STYLE_LIST, "Bang mau", "Xanh duong\nDen\nDo\nCam\nHong\nTim\nXanh la\nVang\nTrang\nCam tu nhan OOC", "Chon", "Huy");
    }
    else
	{
        SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
    }
    return 1;
}

CMD:mark(playerid, params[])
{
    if (PlayerInfo[playerid][pAdmin] >= 2) {

		new
			Float: f_PlayerPos[3];

		GetPlayerPos(playerid, f_PlayerPos[0], f_PlayerPos[1], f_PlayerPos[2]);
		SetPVarFloat(playerid, "tpPosX1", f_PlayerPos[0]);
		SetPVarFloat(playerid, "tpPosY1", f_PlayerPos[1]);
		SetPVarFloat(playerid, "tpPosZ1", f_PlayerPos[2]);

		SetPVarInt(playerid, "tpInt1", GetPlayerInterior(playerid));
        SendClientMessageEx(playerid, COLOR_GRAD1, "Da dat dich den dich chuyen!");
    }
    else {
        SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
    }
    return 1;
}

CMD:mark2(playerid, params[])
{
    if (PlayerInfo[playerid][pAdmin] >= 2) {

		new
			Float: f_PlayerPos[3];

		GetPlayerPos(playerid, f_PlayerPos[0], f_PlayerPos[1], f_PlayerPos[2]);
		SetPVarFloat(playerid, "tpPosX2", f_PlayerPos[0]);
		SetPVarFloat(playerid, "tpPosY2", f_PlayerPos[1]);
		SetPVarFloat(playerid, "tpPosZ2", f_PlayerPos[2]);

		SetPVarInt(playerid, "tpInt2", GetPlayerInterior(playerid));
        SendClientMessageEx(playerid, COLOR_GRAD1, "Da dat dich den dich chuyen!");
    }
    else {
        SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
    }
    return 1;
}

CMD:gotojet(playerid, params[])
{
    if (PlayerInfo[playerid][pAdmin] >= 3) {
        if (GetPlayerState(playerid) == 2) {
            new tmpcar = GetPlayerVehicleID(playerid);
            SetVehiclePos(tmpcar, 1.71875, 30.4062, 1200.34);
        }
        else {
            SetPlayerPos(playerid, 1.71875, 30.4062, 1200.34);
        }
        SetPlayerInterior(playerid,1);
        SendClientMessageEx(playerid, COLOR_GRAD1, "   Ban da duoc dich chuyen!");
    }
    else {
        SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
    }
    return 1;
}

CMD:god(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2 && PlayerInfo[playerid][pWatchdog] < 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	{
		new Float:health, Float:armor;
	    if(GetPVarType(playerid, "pGodMode"))
	    {
			health = GetPVarFloat(playerid, "pPreGodHealth");
			SetHealth(playerid,health);
			armor = GetPVarFloat(playerid, "pPreGodArmor");
			SetArmour(playerid, armor);
			DeletePVar(playerid, "pGodMode");
			DeletePVar(playerid, "pPreGodHealth");
			DeletePVar(playerid, "pPreGodArmor");
			SendClientMessage(playerid, COLOR_WHITE, "Da tat che do bat tu");
		}
		else
		{
			GetHealth(playerid,health);
			SetPVarFloat(playerid, "pPreGodHealth", health);
			GetArmour(playerid,armor);
			SetPVarFloat(playerid, "pPreGodArmor", armor);
		    SetHealth(playerid, 0x7FB00000);
		    SetArmour(playerid, 0x7FB00000);
		    SetPVarInt(playerid, "pGodMode", 1);
		    SendClientMessage(playerid, COLOR_WHITE, "Da bat che do bat tu");
		}
    }
	return 1;
}

CMD:damagecheck(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	if(GetPVarType(playerid, "_dCheck")) {
		DeletePVar(playerid, "_dCheck");
		SendClientMessageEx(playerid, COLOR_WHITE, "Da dung theo doi sat thuong.");
		return 1;
	}
	new pID;
	if(sscanf(params, "u", pID)) return SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /damagecheck [playerid]");
	if(!IsPlayerConnected(pID)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");

	SetPVarInt(playerid, "_dCheck", pID);
	SendClientMessageEx(playerid, COLOR_WHITE, "Ban se thay moi sat thuong %s nhan hoac gay ra.", GetPlayerNameEx(pID));
	if(GetPVarInt(pID, "usingfirstaid") == 1) SendClientMessageEx(playerid, COLOR_ORANGE, "Luu y{ffffff}: Nguoi choi dang dung bo so cuu.");
	return 1;
}

CMD:lastshot(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	new pID;
	if(sscanf(params, "u", pID)) return SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /lastshot [playerid]");
	if(!IsPlayerConnected(pID)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
	if(aLastShot[pID] == INVALID_PLAYER_ID) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi chua bi ban.");

	SendClientMessageEx(playerid, COLOR_YELLOW, "%s bi %s (ID: %d) ban gan nhat.",GetPlayerNameEx(pID), GetPlayerNameEx(aLastShot[pID]), aLastShot[pID]);
	return 1;
}

CMD:healnear(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1) {
		new radius, count;
		if(sscanf(params, "d", radius)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /healnear [radius]");
		if(radius < 1 || radius > 100)
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban kinh phai lon hon 0 va nho hon 100!");
			return 1;
		}
		foreach(new i: Player)
		{
			if(ProxDetectorS(radius, playerid, i)) {
				SetHealth(i, 100);
				count++;
			}
		}
        SendClientMessageEx(playerid, COLOR_WHITE, "Da hoi mau cho moi nguoi (%d) o gan.", count);
    }
    return 1;
}

CMD:armornear(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1) {
		new radius, count;
		if(sscanf(params, "d", radius)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /armornear [radius]");
		if(radius < 1 || radius > 100)
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban kinh phai lon hon 0 va nho hon 100!");
			return 1;
		}
        foreach(new i: Player)
		{
			if(ProxDetectorS(radius, playerid, i)) {
				SetArmour(i, 100);
				count++;
			}
        }
        SendClientMessageEx(playerid, COLOR_WHITE, "Da cap giap cho moi nguoi (%d) o gan.", count);
    }
    return 1;
}

CMD:fixveh(playerid, params[])
{
    if(IsPlayerConnected(playerid)) {
        if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) {
            SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
            return 1;
        }
        if(IsPlayerInAnyVehicle(playerid)) {
            new Float:vrot;
            GetVehicleZAngle(GetPlayerVehicleID(playerid), vrot);
            SetVehicleZAngle(GetPlayerVehicleID(playerid), vrot);
            RepairVehicle(GetPlayerVehicleID(playerid));
			Vehicle_Armor(GetPlayerVehicleID(playerid));
            SendClientMessageEx(playerid, COLOR_GREY, "   Da sua xe!");
        }
    }
    return 1;
}


CMD:fixvehall(playerid, params[])
{
    if(IsPlayerConnected(playerid)) {
        if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) {
            SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
            return 1;
        }
        for(new v = 0; v < MAX_VEHICLES; v++) {
            RepairVehicle(v);
			Vehicle_Armor(v);
        }
        SendClientMessageEx(playerid, COLOR_GREY, "   Da sua tat ca xe!");
    }
    return 1;
}


CMD:destroycars(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) {
        SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
        return 1;
    }
    for(new i = 0; i < sizeof(CreatedCars); i++) {
        if(CreatedCars[i] != INVALID_VEHICLE_ID) {
            DestroyVehicle(CreatedCars[i]);
            CreatedCars[i] = INVALID_VEHICLE_ID;
        }
    }
    SendClientMessageEx(playerid, COLOR_GREY, "   Da xoa cac xe duoc tao!");
    return 1;
}

/*
CMD:announcem(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 1337) {
        SendClientMessageEx(playerid, COLOR_GRAD2, "You are not authorized to use this command.");
        return 1;
    }
	restarting = 1;
    SetTimer( "Maintenance", 30000, false );
    SendClientMessageToAllEx(COLOR_LIGHTBLUE, "* The server will be going down in 30 seconds for Scheduled Maintenance.");
    foreach(new i: Player)
    {
		GameTextForPlayer(i, "~y~Scheduled Maintenance Alert", 5000, 6);
    }
    return 1;
}*/

CMD:rehashall(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1337)
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
		return 1;
	}

	RehashHouses();
	RehashDynamicDoors();
	RehashDynamicMapIcons();
	return 1;
}

CMD:levelones(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] >= 2)
	{
		new zone[MAX_ZONE_NAME], search[MAX_ZONE_NAME], hours;
		SendClientMessageEx(playerid, COLOR_WHITE, "Dang liet ke nguoi choi cap mot...");
		if(!sscanf(params, "d", hours))
		{
			foreach(new i: Player)
			{
				if(gPlayerLogged{playerid} > 0 && PlayerInfo[i][pLevel] == 1 && PlayerInfo[i][pConnectHours] == hours && PlayerInfo[i][pAdmin] == 0)
				{
					GetPlayer3DZone(i, zone, sizeof(zone));
					SendClientMessageEx(playerid, COLOR_WHITE, "* %s (ID %i) (Gio %i) - Vi tri: %s", GetPlayerNameEx(i), i, PlayerInfo[i][pConnectHours], zone);
				}
			}
		}
		else if(!sscanf(params, "s[28]", search))
		{
			foreach(new i: Player)
			{
				if(gPlayerLogged{playerid} > 0 && PlayerInfo[i][pLevel] == 1 && PlayerInfo[i][pAdmin] == 0)
				{
					GetPlayer3DZone(i, zone, sizeof(zone));
					if(strcmp(search, zone, true) == 0 && !isnull(zone)) // null check, as strcmp returns 0 if empty.
					{
						SendClientMessageEx(playerid, COLOR_WHITE, "* %s (ID %i) (Gio %i) - Vi tri: %s", GetPlayerNameEx(i), i, PlayerInfo[i][pConnectHours], zone);
					}
				}
			}
		}
		else
		{
			foreach(new i: Player)
			{
				if(gPlayerLogged{playerid} > 0 && PlayerInfo[i][pLevel] == 1 && PlayerInfo[i][pAdmin] == 0)
				{
					GetPlayer3DZone(i, zone, sizeof(zone));
					SendClientMessageEx(playerid, COLOR_WHITE, "* %s (ID %i) (Gio %i) - Vi tri: %s", GetPlayerNameEx(i), i, PlayerInfo[i][pConnectHours], zone);
				}
			}
		}
	}
	return 1;
}

CMD:paused(playerid, params[]) {
    if(PlayerInfo[playerid][pAdmin] >= 2) {

    	new
			szMessage[42 + MAX_PLAYER_NAME];

	    SendClientMessageEx(playerid,COLOR_WHITE,"Dang liet ke nguoi tam dung game...");
	    foreach(new i: Player)
	    {
			if(playerTabbed[i] != 0) {

				if(playerTabbed[i] > 60) format(szMessage, sizeof(szMessage), "* %s (ID %d), da tab %d phut.", GetPlayerNameEx(i), i, playerTabbed[i] / 60);
				else format(szMessage, sizeof(szMessage), "* %s (ID %d), da tab %d giay.", GetPlayerNameEx(i), i, playerTabbed[i]);

				if(PlayerInfo[i][pAdmin] >= 2) SendClientMessageEx(playerid,COLOR_RED, szMessage);
				else SendClientMessageEx(playerid,COLOR_GREY, szMessage);
			}
		}
   	}
    else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:afk(playerid, params[]) {
    if(PlayerInfo[playerid][pAdmin] >= 2) {

    	new
			szMessage[36 + MAX_PLAYER_NAME];

	    SendClientMessageEx(playerid,COLOR_WHITE,"Dang liet ke nguoi AFK...");
	    foreach(new i: Player)
	    {
			if(playerAFK[i] != 0 && playerAFK[i] > 60) {
				format(szMessage,sizeof(szMessage),"* %s (ID %d), da AFK %d phut.", GetPlayerNameEx(i), i, playerAFK[i] / 60);
				if(PlayerInfo[i][pAdmin] >= 2) SendClientMessageEx(playerid,COLOR_RED,szMessage);
				else SendClientMessageEx(playerid,COLOR_GREY,szMessage);
			}
  		}
   	}
    else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:destroypvehicle(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		new string[128], giveplayerid, vehicleid;
		if(sscanf(params, "ud", giveplayerid, vehicleid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /destroypvehicle [player] [vehicleid]");
		if(!(400 <= GetVehicleModel(vehicleid) <= 612)) return SendClientMessageEx(playerid, COLOR_GREY, "Xe khong hop le.");
		new playervehicleid = GetPlayerVehicle(giveplayerid, vehicleid);
		if(playervehicleid == -1) return SendClientMessageEx(playerid, COLOR_GREY, "LOI: Nguoi do khong so huu xe nay.");

		SendClientMessageEx(playerid, COLOR_WHITE, "Da xoa xe cua %s, mau %s (ID xe %d).", GetPlayerNameEx(giveplayerid), GetVehicleName(vehicleid), vehicleid);
		SendClientMessageEx(giveplayerid, COLOR_GREY, "Admin da xoa xe %s cua ban.", GetVehicleName(vehicleid));
		format(string, sizeof(string), "%s has destroyed %s's(%d) %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetVehicleName(vehicleid));
		Log("logs/playervehicle.log", string);
		DestroyPlayerVehicle(giveplayerid, playervehicleid);
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "Ban khong duoc dung lenh nay.");
	return 1;
}

CMD:setsec(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 1337 || PlayerInfo[playerid][pHR] >= 2 || PlayerInfo[playerid][pAP] >= 2 || PlayerInfo[playerid][pSecurity] >= 2)
	{
	    new giveplayerid, task[8], string[128];
	    if(sscanf(params, "us[8]", giveplayerid, task))
		{
			SendClientMessage(playerid, COLOR_GREY, "CACH DUNG: /setsec [playerid] [secondary task]");
			SendClientMessage(playerid, COLOR_GRAD6, "Nhiem vu phu: FMod, GMod, SO, BA, ST, PR, HR, Sec, BM, ASM");
			return 1;
		}
		if(giveplayerid != INVALID_PLAYER_ID)
		{
			if(IsStaffBanned(giveplayerid)) 
				return SendClientMessage(playerid, COLOR_WHITE, "Nguoi do dang bi cam lam staff.");
			
			if(PlayerInfo[giveplayerid][pAdmin] > 2)
			{
				if(strcmp(task, "fmod", true) == 0)
				{
					if(PlayerInfo[giveplayerid][pFactionModerator] == 0)
					{
						PlayerInfo[giveplayerid][pFactionModerator] = 1;
						SendClientMessage(playerid, COLOR_WHITE, "Da bo nhiem nguoi do lam Faction Moderator");
						SendClientMessage(giveplayerid, COLOR_WHITE, "Ban da duoc bo nhiem lam Faction Moderator");
						format(string, sizeof(string), "%s has given Faction Moderator to %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						Log("logs/admin.log", string);
						DBLog(playerid, giveplayerid, "Admin", "issued faction moderator");
					}
					else
					{
						PlayerInfo[giveplayerid][pFactionModerator] = 0;
						SendClientMessageEx(playerid, COLOR_GREY, "Ban da go quyen Faction Moderator cua nguoi do");
						SendClientMessage(giveplayerid, COLOR_GREY, "Quyen Faction Moderator cua ban da bi go bo");
						format(string, sizeof(string), "%s has taken Faction Moderator from %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						Log("logs/admin.log", string);
						DBLog(playerid, giveplayerid, "Admin", "removed from faction moderator");
					}
				}
				else if(strcmp(task, "gmod", true) == 0)
				{
					if(PlayerInfo[giveplayerid][pGangModerator] == 0)
					{
						PlayerInfo[giveplayerid][pGangModerator] = 1;
						SendClientMessage(playerid, COLOR_WHITE, "Da bo nhiem nguoi do lam Gang Moderator");
						SendClientMessage(giveplayerid, COLOR_WHITE, "Ban da duoc bo nhiem lam Gang Moderator");
						format(string, sizeof(string), "%s has given Gang Moderator to %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						Log("logs/admin.log", string);
						DBLog(playerid, giveplayerid, "Admin", "issued gang moderator");
					}
					else
					{
						PlayerInfo[giveplayerid][pGangModerator] = 0;
						SendClientMessageEx(playerid, COLOR_GREY, "Ban da go quyen Gang Moderator cua nguoi do");
						SendClientMessage(giveplayerid, COLOR_GREY, "Quyen Gang Moderator cua ban da bi go bo");
						format(string, sizeof(string), "%s has taken Gang Moderator from %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						Log("logs/admin.log", string);
						DBLog(playerid, giveplayerid, "Admin", "removed from gang moderator");
					}
				}
				else if(strcmp(task, "so", true) == 0)
				{
					if(PlayerInfo[giveplayerid][pUndercover] == 0)
					{
						PlayerInfo[giveplayerid][pUndercover] = 1;
						SendClientMessage(playerid, COLOR_WHITE, "Da bo nhiem nguoi do lam Special Operative");
						SendClientMessage(giveplayerid, COLOR_WHITE, "Ban da duoc bo nhiem lam Special Operative");
						format(string, sizeof(string), "%s has given Special Operative to %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						Log("logs/admin.log", string);
						DBLog(playerid, giveplayerid, "Admin", "issued special ops");
					}
					else
					{
						PlayerInfo[giveplayerid][pUndercover] = 0;
						SendClientMessageEx(playerid, COLOR_GREY, "Ban da go quyen Special Operative cua nguoi do");
						SendClientMessage(giveplayerid, COLOR_GREY, "Quyen Special Operative cua ban da bi go bo");
						format(string, sizeof(string), "%s has taken Special Operative permissions from %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						Log("logs/admin.log", string);
						DBLog(playerid, giveplayerid, "Admin", "removed from special ops");
					}
				}
				else if(strcmp(task, "ba", true) == 0)
				{
					if(PlayerInfo[giveplayerid][pBanAppealer] == 0)
					{
						PlayerInfo[giveplayerid][pBanAppealer] = 1;
						SendClientMessage(playerid, COLOR_WHITE, "Da bo nhiem nguoi do lam Ban Appealer");
						SendClientMessage(giveplayerid, COLOR_WHITE, "Ban da duoc bo nhiem lam Ban Appealer");
						format(string, sizeof(string), "%s has given Ban Appealer to %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						Log("logs/admin.log", string);
						DBLog(playerid, giveplayerid, "Admin", "issued ban appealer");
					}
					else
					{
						PlayerInfo[giveplayerid][pBanAppealer] = 0;
						SendClientMessageEx(playerid, COLOR_GREY, "Ban da go quyen Ban Appealer cua nguoi do");
						SendClientMessage(giveplayerid, COLOR_GREY, "Quyen Ban Appealer cua ban da bi go bo");
						format(string, sizeof(string), "%s has taken Ban Appealer from %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						Log("logs/admin.log", string);
						DBLog(playerid, giveplayerid, "Admin", "removed from ban appealer");
					}
				}
				else if(strcmp(task, "st", true) == 0)
				{
					if(PlayerInfo[giveplayerid][pShopTech] == 0)
					{
						PlayerInfo[giveplayerid][pShopTech] = 1;
						SendClientMessage(playerid, COLOR_WHITE, "Da bo nhiem nguoi do lam Shop Technician");
						SendClientMessage(giveplayerid, COLOR_WHITE, "Ban da duoc bo nhiem lam Shop Technician");
						format(string, sizeof(string), "%s has given Shop Technician to %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						Log("logs/admin.log", string);
						DBLog(playerid, giveplayerid, "Admin", "issued shop tech");
					}
					else
					{
						PlayerInfo[giveplayerid][pShopTech] = 0;
						SendClientMessageEx(playerid, COLOR_GREY, "Ban da go quyen Shop Technician cua nguoi do");
						SendClientMessage(giveplayerid, COLOR_GREY, "Quyen Shop Technician cua ban da bi go bo");
						format(string, sizeof(string), "%s has taken Shop Technician from %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						Log("logs/admin.log", string);
						DBLog(playerid, giveplayerid, "Admin", "removed from shop tech");
					}
				}
				else if(strcmp(task, "pr", true) == 0)
				{
					if(PlayerInfo[giveplayerid][pPR] == 0)
					{
						PlayerInfo[giveplayerid][pPR] = 1;
						SendClientMessage(playerid, COLOR_WHITE, "Ban da them nguoi do vao Public Relations");
						SendClientMessage(giveplayerid, COLOR_WHITE, "Ban da duoc them vao Public Relations");
						format(string, sizeof(string), "%s has given Public Relations permissions to %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						Log("logs/admin.log", string);
						DBLog(playerid, giveplayerid, "Admin", "issued public relations");
					}
					else
					{
						PlayerInfo[giveplayerid][pPR] = 0;
						SendClientMessageEx(playerid, COLOR_GREY, "Ban da go quyen Public Relations cua nguoi do");
						SendClientMessage(giveplayerid, COLOR_GREY, "Quyen Public Relations cua ban da bi go bo");
						format(string, sizeof(string), "%s has taken Public Relations permissions from %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						Log("logs/admin.log", string);
						DBLog(playerid, giveplayerid, "Admin", "removed from public relations");
					}
				}
				else if(strcmp(task, "hr", true) == 0)
				{
					if(PlayerInfo[giveplayerid][pHR] == 0)
					{
						PlayerInfo[giveplayerid][pHR] = 1;
						SendClientMessage(playerid, COLOR_WHITE, "Ban da them nguoi do vao Human Resources");
						SendClientMessage(giveplayerid, COLOR_WHITE, "Ban da duoc them vao Human Resources");
						format(string, sizeof(string), "%s has given Human Resources permissions to %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						Log("logs/admin.log", string);
						DBLog(playerid, giveplayerid, "Admin", "issued human resources");
					}
					else
					{
						PlayerInfo[giveplayerid][pHR] = 0;
						SendClientMessageEx(playerid, COLOR_GREY, "Ban da go quyen Human Resources cua nguoi do");
						SendClientMessage(giveplayerid, COLOR_GREY, "Quyen Human Resources cua ban da bi go bo");
						format(string, sizeof(string), "%s has taken Human Resources permissions from %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						Log("logs/admin.log", string);
						DBLog(playerid, giveplayerid, "Admin", "removed from human resources");
					}
				}
				else if(strcmp(task, "dosm", true) == 0)
				{
					if(PlayerInfo[giveplayerid][pHR] == 0)
					{
						PlayerInfo[giveplayerid][pHR] = 2;
						SendClientMessage(playerid, COLOR_WHITE, "Da cap quyen Human Resources cap 2 cho nguoi do");
						SendClientMessage(giveplayerid, COLOR_WHITE, "Ban da duoc cap quyen Human Resources cap 2");
						format(string, sizeof(string), "%s has given level 2 Human Resources permissions to %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						Log("logs/admin.log", string);
						DBLog(playerid, giveplayerid, "Admin", "issued human resources");
					}
					else
					{
						PlayerInfo[giveplayerid][pHR] = 0;
						SendClientMessageEx(playerid, COLOR_GREY, "Ban da go quyen Human Resources cua nguoi do");
						SendClientMessage(giveplayerid, COLOR_GREY, "Quyen Human Resources cua ban da bi go bo");
						format(string, sizeof(string), "%s has taken Human Resources permissions from %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						Log("logs/admin.log", string);
						DBLog(playerid, giveplayerid, "Admin", "removed from human resources");
					}
				}
				else if(strcmp(task, "sec", true) == 0)
				{
					if(PlayerInfo[giveplayerid][pSecurity] == 0)
					{
						PlayerInfo[giveplayerid][pSecurity] = 1;
						SendClientMessage(playerid, COLOR_WHITE, "Ban da them nguoi do vao Security");
						SendClientMessage(giveplayerid, COLOR_WHITE, "Ban da duoc them vao Security");
						format(string, sizeof(string), "%s has given Security permissions to %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						Log("logs/admin.log", string);
						DBLog(playerid, giveplayerid, "Admin", "issued security");
					}
					else
					{
						PlayerInfo[giveplayerid][pSecurity] = 0;
						SendClientMessageEx(playerid, COLOR_GREY, "Ban da go quyen Security cua nguoi do");
						SendClientMessage(giveplayerid, COLOR_GREY, "Quyen Security cua ban da bi go bo");
						format(string, sizeof(string), "%s has taken Security permissions from %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						Log("logs/admin.log", string);
						DBLog(playerid, giveplayerid, "Admin", "removed from security");
					}
				}
				else if(strcmp(task, "bm", true) == 0)
				{
					if(PlayerInfo[giveplayerid][pBM] == 0)
					{
						PlayerInfo[giveplayerid][pBM] = 1;
						SendClientMessage(playerid, COLOR_WHITE, "Da bo nhiem nguoi do lam Business Moderator");
						SendClientMessage(giveplayerid, COLOR_WHITE, "Ban da duoc bo nhiem lam Business Moderator");
						format(string, sizeof(string), "%s has given Business Moderator permissions to %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						Log("logs/admin.log", string);
						DBLog(playerid, giveplayerid, "Admin", "issued business moderator");
					}
					else
					{
						PlayerInfo[giveplayerid][pBM] = 0;
						SendClientMessageEx(playerid, COLOR_GREY, "Ban da go quyen Business Moderator cua nguoi do");
						SendClientMessage(giveplayerid, COLOR_GREY, "Quyen Business Moderator cua ban da bi go bo");
						format(string, sizeof(string), "%s has taken Business Moderator permissions from %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						Log("logs/admin.log", string);
						DBLog(playerid, giveplayerid, "Admin", "removed from business moderator");
					}
				}
				else if(strcmp(task, "asm", true) == 0)
				{
					if(PlayerInfo[giveplayerid][pASM] == 0)
					{
						PlayerInfo[giveplayerid][pASM] = 1;
						SendClientMessage(playerid, COLOR_WHITE, "Da bo nhiem nguoi do lam Assistant Shift Manager");
						SendClientMessage(giveplayerid, COLOR_WHITE, "Ban da duoc bo nhiem lam Assistant Shift Manager");
						format(string, sizeof(string), "%s has given Assistant Shift Manager permissions to %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						Log("logs/admin.log", string);
						DBLog(playerid, giveplayerid, "Admin", "issued Assistant Shift Manager");
					}
					else
					{
						PlayerInfo[giveplayerid][pASM] = 0;
						SendClientMessageEx(playerid, COLOR_GREY, "Ban da go quyen Assistant Shift Manager cua nguoi do");
						SendClientMessage(giveplayerid, COLOR_GREY, "Quyen Assistant Shift Manager cua ban da bi go bo");
						format(string, sizeof(string), "%s has taken Assistant Shift Manager permissions from %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
						Log("logs/admin.log", string);
						DBLog(playerid, giveplayerid, "Admin", "removed from Assistant Shift Manager");
					}
				}
			}
			else SendClientMessage(playerid, COLOR_GRAD2, "Nguoi do khong phai Admin!");
		}
		else SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do chua ket noi.");
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:removepvehicle(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		new giveplayerid;
		if(sscanf(params, "u", giveplayerid)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /removepvehicle [player]");
			return 1;
		}

		szMiscArray[0] = 0;

		for(new i, iModelID; i < GetPlayerVehicleSlots(giveplayerid); i++) {
			if((iModelID = PlayerVehicleInfo[giveplayerid][i][pvModelId] - 400) >= 0) {
				new vehicleName[18];
				strunpack(vehicleName, VehicleName[iModelID], sizeof(vehicleName));
				if(PlayerVehicleInfo[giveplayerid][i][pvImpounded]) {
					format(szMiscArray, sizeof(szMiscArray), "%s\n%s (tam giu)", szMiscArray, vehicleName);
				}
				else if(PlayerVehicleInfo[giveplayerid][i][pvDisabled]) {
					format(szMiscArray, sizeof(szMiscArray), "%s\n%s (vo hieu)", szMiscArray, vehicleName);
				}
				else if(!PlayerVehicleInfo[giveplayerid][i][pvSpawned]) {
					format(szMiscArray, sizeof(szMiscArray), "%s\n%s (da cat)", szMiscArray, vehicleName);
				}
				else {
					format(szMiscArray, sizeof(szMiscArray), "%s\n%s (lay ra)", szMiscArray, vehicleName);
				}
			}
			else strcat(szMiscArray, "\nTrong");
		}
		new string[64];
		SetPVarInt(playerid, "vehcheck_giveplayerid", giveplayerid);
		format(string, sizeof(string), "Danh sach xe: %s", GetPlayerNameEx(giveplayerid));
		ShowPlayerDialogEx(playerid, ADMIN_VEHCHECK, DIALOG_STYLE_LIST, string, szMiscArray, "Xoa xe", "Huy");
	}
	return 1;
}

CMD:makeadmin(playerid, params[])  {

	if(PlayerInfo[playerid][pAdmin] >= 1337 || PlayerInfo[playerid][pAP] >= 2 || PlayerInfo[playerid][pHR] >= 3) {

		new
			iAdminValue,
			iTargetID;

		if(sscanf(params, "ui", iTargetID, iAdminValue)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /makeadmin [player] [level]");
		}
		else if(IsPlayerConnected(iTargetID)) {
			if(PlayerInfo[iTargetID][pHelper] >= 1) {
				SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the bo nhiem Advisor lam Admin!");
			}
			if(PlayerInfo[iTargetID][pAdmin] == iAdminValue) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do da co cap Admin nay.");
			else {

				if(IsStaffBanned(iTargetID)) 
					return SendClientMessage(playerid, COLOR_WHITE, "Nguoi do dang bi cam lam staff.");

				/*new
					szMessage[47 + (MAX_PLAYER_NAME * 2)];*/

                PriorityReport[iTargetID] = TextDrawCreate(261.000000, 373.000000, "Bao cao moi");
				TextDrawBackgroundColor(PriorityReport[iTargetID], 255);
				TextDrawFont(PriorityReport[iTargetID], 2);
				TextDrawLetterSize(PriorityReport[iTargetID], 0.460000, 1.800000);
				TextDrawColor(PriorityReport[iTargetID], -65281);
				TextDrawSetOutline(PriorityReport[iTargetID], 0);
				TextDrawSetProportional(PriorityReport[iTargetID], true);
				TextDrawSetShadow(PriorityReport[iTargetID], 1);


				new szRank[128];
				switch(iAdminValue) {
					case 0: format(szRank, sizeof(szRank), "AdmCmd: %s da go chuc vu Admin cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
					case 1: format(szRank, sizeof(szRank), "AdmCmd: %s bo nhiem %s: Server Moderator.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
					case 2: format(szRank, sizeof(szRank), "AdmCmd: %s bo nhiem %s: Junior Administrator.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
					case 3: format(szRank, sizeof(szRank), "AdmCmd: %s bo nhiem %s: General Administrator.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
					case 4: format(szRank, sizeof(szRank), "AdmCmd: %s bo nhiem %s: Senior Administrator.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
					case 1337: format(szRank, sizeof(szRank), "AdmCmd: %s bo nhiem %s: Head Administrator.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
					case 99999: format(szRank, sizeof(szRank), "AdmCmd: %s bo nhiem %s: Executive Administrator.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
					default: format(szRank, sizeof(szRank), "AdmCmd: %s bo nhiem %s: Admin cap chua xac dinh.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
				}

				PlayerInfo[iTargetID][pAdmin] = iAdminValue;
				ABroadCast(COLOR_LIGHTRED, szRank, 2);
				switch(iAdminValue) {
					case 0: format(szRank, sizeof(szRank), "AdmCmd: %s has removed %s's administrator rank.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
					case 1: format(szRank, sizeof(szRank), "AdmCmd: %s has made %s a Server Moderator.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
					case 2: format(szRank, sizeof(szRank), "AdmCmd: %s has made %s a Junior Administrator.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
					case 3: format(szRank, sizeof(szRank), "AdmCmd: %s has made %s a General Administrator.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
					case 4: format(szRank, sizeof(szRank), "AdmCmd: %s has made %s a Senior Administrator.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
					case 1337: format(szRank, sizeof(szRank), "AdmCmd: %s has made %s a Head Administrator.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
					case 99999: format(szRank, sizeof(szRank), "AdmCmd: %s has made %s an Executive Administrator.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
					default: format(szRank, sizeof(szRank), "AdmCmd: %s has made %s an undefined level administrator.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
				}
				Log("logs/admin.log", szRank);

				switch(iAdminValue) {
					case 0: format(szRank, sizeof(szRank), "Chuc vu Admin cua ban da bi %s go bo.", GetPlayerNameEx(playerid));
					case 1: format(szRank, sizeof(szRank), "Ban duoc %s bo nhiem lam Server Moderator.", GetPlayerNameEx(playerid));
					case 2: format(szRank, sizeof(szRank), "Ban duoc %s bo nhiem lam Junior Administrator.", GetPlayerNameEx(playerid));
					case 3: format(szRank, sizeof(szRank), "Ban duoc %s bo nhiem lam General Administrator.", GetPlayerNameEx(playerid));
					case 4: format(szRank, sizeof(szRank), "Ban duoc %s bo nhiem lam Senior Administrator.", GetPlayerNameEx(playerid));
					case 1337: format(szRank, sizeof(szRank), "Ban duoc %s bo nhiem lam Head Administrator.", GetPlayerNameEx(playerid));
					case 99999: format(szRank, sizeof(szRank), "Ban duoc %s bo nhiem lam Executive Administrator.", GetPlayerNameEx(playerid));
					default: format(szRank, sizeof(szRank), "Ban duoc %s bo nhiem lam Admin cap chua xac dinh.", GetPlayerNameEx(playerid));
				}
				SendClientMessageEx(iTargetID, COLOR_LIGHTBLUE, szRank);

				switch(iAdminValue) {
					case 0: format(szRank, sizeof(szRank), "Ban da go chuc vu Admin cua %s.", GetPlayerNameEx(iTargetID));
					case 1: format(szRank, sizeof(szRank), "Da bo nhiem %s lam Server Moderator.", GetPlayerNameEx(iTargetID));
					case 2: format(szRank, sizeof(szRank), "Da bo nhiem %s lam Junior Administrator.", GetPlayerNameEx(iTargetID));
					case 3: format(szRank, sizeof(szRank), "Da bo nhiem %s lam General Administrator.", GetPlayerNameEx(iTargetID));
					case 4: format(szRank, sizeof(szRank), "Da bo nhiem %s lam Senior Administrator.", GetPlayerNameEx(iTargetID));
					case 1337: format(szRank, sizeof(szRank), "Da bo nhiem %s lam Head Administrator.", GetPlayerNameEx(iTargetID));
					case 99999: format(szRank, sizeof(szRank), "Da bo nhiem %s lam Executive Administrator.", GetPlayerNameEx(iTargetID));
					default: format(szRank, sizeof(szRank), "Da bo nhiem %s lam Admin cap chua xac dinh.", GetPlayerNameEx(iTargetID));
				}
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, szRank);

				format(szMiscArray, sizeof(szMiscArray), "was made a %s (%d)", GetAdminRankName(iAdminValue), iAdminValue);
				DBLog(playerid, iTargetID, "Admin", szMiscArray);

			}
		}
		else SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi choi khong hop le.");
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:apark(playerid, params[]) {
    if (PlayerInfo[playerid][pAdmin] >= 3)
	{
        foreach(new ownerid: Player)
		{
			for(new d = 0 ; d < MAX_PLAYERVEHICLES; d++)
			{
				if(IsPlayerInVehicle(playerid, PlayerVehicleInfo[ownerid][d][pvId]))
				{
					new vehicleName[18];
					if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai ngoi ghe lai.");
					new Float:x, Float:y, Float:z, Float:angle, Float:health;
					if(PlayerInfo[playerid][pLockCar] == GetPlayerVehicleID(playerid)) PlayerInfo[playerid][pLockCar] = INVALID_VEHICLE_ID;
					if(IsARC(GetPlayerVehicleID(playerid))) // RC Vehicles
					{
						new Float:vehPos[3];
						GetVehiclePos(GetPlayerVehicleID(playerid),vehPos[0], vehPos[1], vehPos[2]);
						SetPlayerPos(playerid,vehPos[0], vehPos[1]+0.5, vehPos[2]+0.5);
					}
					GetVehicleHealth(PlayerVehicleInfo[ownerid][d][pvId], health);
					GetVehiclePos(PlayerVehicleInfo[ownerid][d][pvId], x, y, z);
					GetVehicleZAngle(PlayerVehicleInfo[ownerid][d][pvId], angle);
					SurfingCheck(GetPlayerVehicleID(playerid));
					UpdatePlayerVehicleParkPosition(ownerid, d, x, y, z, angle, health, GetPlayerVirtualWorld(ownerid), GetPlayerInterior(ownerid));
					IsPlayerEntering{playerid} = true;
					PutPlayerInVehicle(playerid, GetPlayerVehicleID(playerid), 0);
					SetPlayerArmedWeapon(playerid, 0);


					strunpack(vehicleName, VehicleName[PlayerVehicleInfo[ownerid][d][pvModelId] - 400], sizeof(vehicleName));
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da do xe cua %s: %s.",GetPlayerNameEx(ownerid), vehicleName);

					SendClientMessageEx(ownerid, COLOR_LIGHTBLUE, "Admin da do xe %s cua ban o noi khac. Dung /trackcar de tim.", vehicleName);
					return 1;
				}
			}
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}



alias:admin("a")
CMD:admin(playerid, params[])  {
	if(PlayerInfo[playerid][pAdmin] >= 2) {
		if(!isnull(params)) {

			new
				szMessage[128];

			format(szMessage, sizeof(szMessage), "* %s %s: %s", GetAdminRankName(PlayerInfo[playerid][pAdmin]), GetPlayerNameEx(playerid), params);
			foreach(new i: Player)
			{
				if(PlayerInfo[i][pAdmin] >= 2)
				{
					SendClientMessage(i, COLOR_YELLOW, szMessage);
				}
			}

			format(szMessage, sizeof(szMessage), "%s %s: %s", GetAdminRankName(PlayerInfo[playerid][pAdmin]), GetPlayerNameEx(playerid), params);
			SendDiscordMessage(0, szMessage);
		}
		else SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: (/a)dmin [admin chat]");
	}
	return 1;
}



alias:headadmin("ha")
CMD:headadmin(playerid, params[])  {
	if(PlayerInfo[playerid][pAdmin] >= 1337) {
		if(!isnull(params)) {

			new
				szMessage[128];

			format(szMessage, sizeof(szMessage), "(RIENG) %s %s: %s", GetAdminRankName(PlayerInfo[playerid][pAdmin]), GetPlayerNameEx(playerid), params);
			foreach(new i: Player)
			{
				if(PlayerInfo[i][pAdmin] >= 1337)
				{
					SendClientMessage(i, COLOR_GREEN, szMessage);
				}
			}

			format(szMessage, sizeof(szMessage), "%s %s: %s", GetAdminRankName(PlayerInfo[playerid][pAdmin]), GetPlayerNameEx(playerid), params);
			SendDiscordMessage(2, szMessage);
		}
		else SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: (/ha)eadmin [Head admin+ chat]");
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:staff(playerid, params[]) {
	if((PlayerInfo[playerid][pHelper] >= 2 || PlayerInfo[playerid][pAdmin] >= 1 || PlayerInfo[playerid][pVIPMod] || PlayerInfo[playerid][pWatchdog] >= 1) && PlayerInfo[playerid][pToggledChats][15] == 0) {
		if(PlayerInfo[playerid][pJailTime] && strfind(PlayerInfo[playerid][pPrisonReason], "[OOC]", true) != -1) return SendClientMessageEx(playerid, COLOR_GREY, "Tu nhan OOC chi duoc noi trong /b");
		if(!isnull(params)) {

			szMiscArray[0] = 0;

			if(PlayerInfo[playerid][pAdmin] == 2) format(szMiscArray, sizeof(szMiscArray), "** Junior Admin %s: %s", GetPlayerNameEx(playerid), params);
			else if(PlayerInfo[playerid][pAdmin] == 3) format(szMiscArray, sizeof(szMiscArray), "** General Admin %s: %s", GetPlayerNameEx(playerid), params);
			else if(PlayerInfo[playerid][pAdmin] == 4) format(szMiscArray, sizeof(szMiscArray), "** Senior Admin %s: %s", GetPlayerNameEx(playerid), params);
			else if(PlayerInfo[playerid][pAdmin] == 1337) format(szMiscArray, sizeof(szMiscArray), "** Head Admin %s: %s", GetPlayerNameEx(playerid), params);
			else if(PlayerInfo[playerid][pAdmin] == 99999) format(szMiscArray, sizeof(szMiscArray), "** Executive Admin %s: %s", GetPlayerNameEx(playerid), params);
			else if(PlayerInfo[playerid][pHelper] == 2) format(szMiscArray, sizeof(szMiscArray), "** Advisor %s: %s", GetPlayerNameEx(playerid), params);
			else if(PlayerInfo[playerid][pHelper] == 3) format(szMiscArray, sizeof(szMiscArray), "** Senior Advisor %s: %s", GetPlayerNameEx(playerid), params);
			else if(PlayerInfo[playerid][pHelper] >= 4) format(szMiscArray, sizeof(szMiscArray), "** Chief Advisor %s: %s", GetPlayerNameEx(playerid), params);
			else if(PlayerInfo[playerid][pAdmin] == 1)
			{
				if(PlayerInfo[playerid][pSMod] != 0) format(szMiscArray, sizeof(szMiscArray), "** Senior Moderator %s: %s", GetPlayerNameEx(playerid), params);
				else format(szMiscArray, sizeof(szMiscArray), "** Server Moderator %s: %s", GetPlayerNameEx(playerid), params);
			}
			else if(PlayerInfo[playerid][pVIPMod] == 1) format(szMiscArray, sizeof(szMiscArray), "** VIP Moderator %s: %s", GetPlayerNameEx(playerid), params);
			else if(PlayerInfo[playerid][pVIPMod] == 2) format(szMiscArray, sizeof(szMiscArray), "** Senior VIP Moderator %s: %s", GetPlayerNameEx(playerid), params);
			else if(PlayerInfo[playerid][pWatchdog] == 1) format(szMiscArray, sizeof(szMiscArray), "** Watchdog %s: %s", GetPlayerNameEx(playerid), params);
			else if(PlayerInfo[playerid][pWatchdog] == 2) format(szMiscArray, sizeof(szMiscArray), "** Senior Watchdog %s: %s", GetPlayerNameEx(playerid), params);
			else if(PlayerInfo[playerid][pWatchdog] == 3) format(szMiscArray, sizeof(szMiscArray), "** RP Specialist %s: %s", GetPlayerNameEx(playerid), params);
			else if(PlayerInfo[playerid][pWatchdog] == 4) format(szMiscArray, sizeof(szMiscArray), "** Director of RP Improvement %s: %s", GetPlayerNameEx(playerid), params);
			else format(szMiscArray, sizeof(szMiscArray), "** Undefined Admin (%d) %s: %s", PlayerInfo[playerid][pAdmin], GetPlayerNameEx(playerid), params);

			SendAdvisorMessage(COLOR_COMBINEDCHAT, szMiscArray);
			Log("logs/staffchat.log", szMiscArray);
			ChatDBLog(playerid, "StaffChat", szMiscArray);
		}
		else SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /staff [chat]");
	}
	return 1;
}

CMD:cnn(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1) {
		if(!isnull(params)) {

			format(szMiscArray, sizeof(szMiscArray), "~b~%s: ~w~%s",GetPlayerNameEx(playerid), params);
			foreach(new i: Player)
			{
				GameTextForPlayer(i, szMiscArray, 5000, 6);
			}
		}
		else SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /cnn [message]. ~n~ = new line, ~r~ = red, ~g~ = green, ~b~ = blue, ~w~ = white, ~y~ = yellow.");
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:veh(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1) {

		new
			iVehicle,
			iColors[2];

		if(sscanf(params, "iD(0)D(0)", iVehicle, iColors[0], iColors[1])) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /veh [model ID] [color 1] [color 2]");
		}
		else if(!(400 <= iVehicle <= 611)) {
			SendClientMessageEx(playerid, COLOR_GRAD2, "Model khong hop le (ID tu 400 den 611).");
		}
		else if(IsATrain(iVehicle)) {
			SendClientMessageEx(playerid, COLOR_GREY, "Khong the tao tau khi may chu dang chay.");
		}
		else if(!(0 <= iColors[0] <= 255 && 0 <= iColors[1] <= 255)) {
			SendClientMessageEx(playerid, COLOR_GRAD2, "Mau khong hop le (ID tu 0 den 255).");
		}
		else for(new iIterator; iIterator < sizeof(CreatedCars); iIterator++) if(iIterator >= 49) {
			return SendClientMessageEx(playerid, COLOR_GRAD1, "Da dat gioi han 50 xe duoc tao.");
		}
		else if(CreatedCars[iIterator] == INVALID_VEHICLE_ID) {

			new
				Float: fVehPos[4];

			new fVW = GetPlayerVirtualWorld(playerid);
			GetPlayerPos(playerid, fVehPos[0], fVehPos[1], fVehPos[2]);
			GetPlayerFacingAngle(playerid, fVehPos[3]);
			CreatedCars[iIterator] = CreateVehicle(iVehicle, fVehPos[0], fVehPos[1], fVehPos[2], fVehPos[3], iColors[0], iColors[1], -1);
			VehicleFuel[CreatedCars[iIterator]] = 100.0;
			Vehicle_ResetData(CreatedCars[iIterator]);
			LinkVehicleToInterior(CreatedCars[iIterator], GetPlayerInterior(playerid));
			SetVehicleVirtualWorld(CreatedCars[iIterator], fVW);
			return SendClientMessageEx(playerid, COLOR_GREY, "Da tao xe!");
		}
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:cnnn(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] >= 1337) {

		new
			iTextID,
			szMessage[128];

		if(sscanf(params, "is[128]", iTextID, szMessage)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /cnnn [type 1-6] [message]. ~n~ = new line, ~r~ = red, ~g~ = green, ~b~ = blue, ~w~ = white, ~y~ = yellow.");
		}
		else if(!(0 <= iTextID <= 6 && iTextID != 2)) {
			SendClientMessageEx(playerid, COLOR_GRAD2, "Text ID phai tu 0 den 6, tru 2 (do loi SA:MP).");
		}
		else GameTextForAll(szMessage, 5000, iTextID);
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:gotopveh(playerid, params[]) {
    if(PlayerInfo[playerid][pAdmin] >= 2) {

        new iTargetID;

        if(sscanf(params, "u", iTargetID)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /gotopveh [player]");
		}
		else if(IsPlayerConnected(iTargetID)) {

			new szVehString[8024], icount = GetPlayerVehicleSlots(iTargetID);
			if(!GetPlayerVehicleCount(iTargetID)) return SendClientMessageEx(playerid, COLOR_GREY, "LOI: Nguoi choi khong so huu xe nao.");
			new szCarLocation[MAX_ZONE_NAME];
			for(new i, iModelID; i < icount; i++)
			{
				Get3DZone(PlayerVehicleInfo[iTargetID][i][pvPosX], PlayerVehicleInfo[iTargetID][i][pvPosY], PlayerVehicleInfo[iTargetID][i][pvPosZ], szCarLocation, sizeof(szCarLocation));
				if((iModelID = PlayerVehicleInfo[iTargetID][i][pvModelId] - 400) >= 0)
				{
					new vehicleName[18];
					strunpack(vehicleName, VehicleName[iModelID], sizeof(vehicleName));
					if(PlayerVehicleInfo[iTargetID][i][pvImpounded]) {
						format(szVehString, sizeof(szVehString), "%s\n%s (bi tam giu) | Vi tri: DMV", szVehString, vehicleName);
					}
					else if(PlayerVehicleInfo[iTargetID][i][pvDisabled]) {
						format(szVehString, sizeof(szVehString), "%s\n%s (bi vo hieu) | Vi tri: Unknown", szVehString, vehicleName);
					}
					else if(!PlayerVehicleInfo[iTargetID][i][pvSpawned]) {
						format(szVehString, sizeof(szVehString), "%s\n%s (da cat)", szVehString, vehicleName);
					}
					else {
						format(szVehString, sizeof(szVehString), "%s\n%s (ID %i) | Vi tri: %s", szVehString, vehicleName, PlayerVehicleInfo[iTargetID][i][pvId], szCarLocation);
					}
				}
			}
		    ShowPlayerDialogEx(playerid, GOTOPLAYERCAR, DIALOG_STYLE_LIST, "Dich chuyen xe", szVehString, "Dich chuyen", "Huy");
       		SetPVarInt(playerid, "playeraffectedcarTP", iTargetID);
		}
		else SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
		{

		}
  	}
	return 1;
}

alias:reloadpvehicles("reloadpveh")
CMD:reloadpvehicles(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] < 3)
	{
        SendClientMessageEx(playerid, COLOR_GREY, " Ban khong co quyen dung lenh nay.");
        return 1;
    }

	new giveplayerid;
	if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /reloadpvehicles [player]");

	if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi choi khong hop le!");
	UnloadPlayerVehicles(giveplayerid);
	LoadPlayerVehicles(giveplayerid);

	SendClientMessageEx(playerid, COLOR_GREY, " Da tai lai xe cua %s.", GetPlayerNameEx(giveplayerid));

	return 1;
}



CMD:unloadpvehicles(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1337) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay!");

	foreach(new p: Player)
	{
		UnloadPlayerVehicles(p);
	}
	SendClientMessageEx(playerid, COLOR_GREY, "Da go tat ca xe khoi the gioi.");
	return 1;
}

CMD:loadpvehicles(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1337) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay!");

	foreach(new p: Player)
	{
		LoadPlayerVehicles(p);
	}
	SendClientMessageEx(playerid, COLOR_GREY, "Da tai tat ca xe.");
	return 1;
}

CMD:createpvehicle(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		new iColors[2], iTargetID, iModelID;

		if(sscanf(params, "uiD(0)D(0)", iTargetID, iModelID, iColors[0], iColors[1])) SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /createpvehicle [player] [model] [color 1] [color 2]");
		else if(!(400 <= iModelID <= 611)) SendClientMessageEx(playerid, COLOR_GRAD2, "Model khong hop le (ID tu 400 den 611).");
		else if(IsATrain(iModelID)) SendClientMessageEx(playerid, COLOR_GREY, "Khong the tao tau khi may chu dang chay.");
		else if(!(0 <= iColors[0] <= 255 && 0 <= iColors[1] <= 255)) SendClientMessageEx(playerid, COLOR_GRAD2, "Mau khong hop le (ID tu 0 den 255).");
		else if(!vehicleCountCheck(iTargetID)) SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do da so huu qua nhieu xe, khong the them.");
		else if(!vehicleSpawnCountCheck(iTargetID)) SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do da lay qua nhieu xe ra ngoai, can cat bot mot xe truoc.");
		else if(PlayerInfo[iTargetID][pLevel] == 1 && PlayerInfo[iTargetID][pAdmin] < 2) return SendClientMessageEx(playerid, COLOR_RED, "Khong the dung /givemoney voi nguoi cap 1");
		else
		{
			new vehicleName[18];
			new Float: arr_fPlayerPos[4], szMessage[84];

			GetPlayerPos(iTargetID, arr_fPlayerPos[0], arr_fPlayerPos[1], arr_fPlayerPos[2]);
			GetPlayerFacingAngle(iTargetID, arr_fPlayerPos[3]);
			CreatePlayerVehicle(iTargetID, GetPlayerFreeVehicleId(iTargetID), iModelID, arr_fPlayerPos[0], arr_fPlayerPos[1], arr_fPlayerPos[2], arr_fPlayerPos[3], iColors[0], iColors[1], 2000000, GetPlayerVirtualWorld(iTargetID), GetPlayerInterior(iTargetID));

			strunpack(vehicleName, VehicleName[iModelID - 400], sizeof(vehicleName));
			SendClientMessageEx(playerid, COLOR_WHITE, "Da tao xe %s cho %s.", vehicleName, GetPlayerNameEx(iTargetID));
			format(szMessage, sizeof(szMessage), "%s created a %s (%i) for %s(%d)", GetPlayerNameEx(playerid), vehicleName, iModelID, GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID));
			Log("logs/playervehicle.log", szMessage);
			format(szMiscArray, sizeof(szMiscArray), "created a %s (%d)", vehicleName, iModelID);
			DBLog(playerid, iTargetID, "PlayerVehicle", szMiscArray);
		}
	}
	else SendClientMessageEx(playerid, COLOR_GREY, " Ban khong co quyen dung lenh nay.");
    return 1;
}

CMD:ip(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2)
	{
		if(isnull(params)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /ip [ip]");

		new string[128], IP[32];

		foreach(new i: Player)
		{
			GetPlayerIp(i, IP, sizeof(IP));
			if(strfind(IP, params, true) != -1 && PlayerInfo[i][pAdmin] <= PlayerInfo[playerid][pAdmin])
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "Ten: %s (ID: %d) (Cap: %d) | IP: %s", GetPlayerNameEx(i), i, PlayerInfo[i][pLevel],  IP);
				format(string, sizeof(string), "%s has IP Checked %s(%d)", GetPlayerNameEx(playerid), GetPlayerNameEx(i), GetPlayerSQLId(i));
				if(PlayerInfo[i][pAdmin] >= 2) {
					Log("logs/adminipcheck.log", string);
					DBLog(playerid, i, "AdminIPCheck", "performed an IP check");
				}
				else {
					Log("logs/ipcheck.log", string);
					DBLog(playerid, i, "IPCheck", "performed an IP check");
				}
			}
		}
	}

	return 1;
}

CMD:unlockveh(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 3)
	{
		new vehicleid;
		if(sscanf(params, "d", vehicleid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /unlockveh [vehicle id]");

		if(IsValidVehicleID(vehicleid))
		{
			vehicle_unlock_doors(vehicleid);
			GameTextForPlayer(playerid, "~g~da mo khoa", 1000, 6);
			PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GRAD1, "ID xe khong hop le");
		}
	}
	return 1;
}

CMD:ounsuspend(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 1337 || PlayerInfo[playerid][pAP] >= 2 || PlayerInfo[playerid][pHR] >= 3)
	{
		new query[512], tmpName[24];
		if(isnull(params)) return SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /ounsuspend [player name]");

		mysql_escape_string(params, tmpName);
		SetPVarString(playerid, "OnSetSuspended", tmpName);
		mysql_format(MainPipeline, query,sizeof(query),"UPDATE `accounts` SET `Disabled` = 0 WHERE `Username` = '%s' AND `AdminLevel` < 1338 AND `AdminLevel` > 1", tmpName);
		mysql_tquery(MainPipeline, query, "OnSetSuspended", "ii", playerid, false);

		SendClientMessageEx(playerid,COLOR_YELLOW,"Dang go dinh chi tai khoan %s...",tmpName);
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:osetrmutes(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] >= 1337 || PlayerInfo[playerid][pAP] >= 2 || PlayerInfo[playerid][pHR] >= 3) {

		new
			szPlayerName[MAX_PLAYER_NAME],
			iMuteCount;

		if(sscanf(params, "s[24]i", szPlayerName, iMuteCount)) {
			return SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /osetrmutes [player name] [mutes]");
		}
		else if(iMuteCount >= 0) {

			new
				szQuery[128];

			mysql_escape_string(szPlayerName, szPlayerName);
			mysql_format(MainPipeline, szQuery, sizeof szQuery, "UPDATE `accounts` SET `ReportMutedTotal` = %i, `ReportMuted` = 0, `ReportMutedTime` = 0 WHERE `Username` = '%s'", iMuteCount, szPlayerName);
			mysql_tquery(MainPipeline, szQuery, "Query_OnExecution", "ii", playerid);
			SetPVarString(playerid, "QueryEx_Name", szPlayerName);
		}
		else SendClientMessageEx(playerid, COLOR_GRAD1, "So lan cam chat khong duoc nho hon khong.");
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	return 1;
}

CMD:destroycar(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
			for(new i = 0; i < sizeof(CreatedCars); ++i) if(CreatedCars[i] == GetPlayerVehicleID(playerid)) {
				DestroyVehicle(CreatedCars[i]);
				CreatedCars[i] = INVALID_VEHICLE_ID;
				return SendClientMessageEx(playerid, COLOR_GREY, "Da xoa xe nay khoi the gioi.");
			}
			SendClientMessageEx(playerid, COLOR_GRAD1, "Xe nay khong phai do Admin tao.");
		}
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong o trong xe nao.");
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:setfightstyle(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		new giveplayerid, fightstyle;
		if(sscanf(params, "ud", giveplayerid, fightstyle))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /setfightstyle [player] [fightstyle]");
			SendClientMessageEx(playerid, COLOR_GRAD2, "Kieu chien dau hop le: 4, 5, 6, 7, 15, 26.");
			return 1;
		}

		if(fightstyle > 3 && fightstyle < 8 || fightstyle == 15 || fightstyle == 26)
		{
			SendClientMessageEx(giveplayerid,COLOR_YELLOW," Da doi kieu chien dau cua ban thanh %d.", fightstyle);
			SendClientMessageEx(playerid,COLOR_YELLOW," Da doi kieu chien dau cua %s thanh %d.", GetPlayerNameEx(giveplayerid), fightstyle);
			SetPlayerFightingStyle(giveplayerid, fightstyle);
			PlayerInfo[playerid][pFightStyle] = fightstyle;
			return 1;
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:setmyname(playerid, params[])
{
	new query[128];
	if(isnull(params)) return SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /setmyname [newname]");

	if (PlayerInfo[playerid][pUndercover] >= 1 || PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pFactionModerator] >= 4)
	{
		if(GetPVarInt(playerid, "TempName") == 0)
		{
		    if(strlen(params) > MAX_PLAYER_NAME)
			{
				return SendClientMessageEx(playerid, COLOR_WHITE, "Ten khong duoc dai qua %d ky tu.", MAX_PLAYER_NAME);
			}
			new tmpName[24];
			mysql_escape_string(params, tmpName);

			mysql_format(MainPipeline, query, sizeof(query), "SELECT `Username` FROM `accounts` WHERE `Username`='%s'", tmpName);
			SetPVarString(playerid, "OnSetMyName", tmpName);
			mysql_tquery(MainPipeline, query, "OnSetMyName", "i", playerid);
		}
		else
		{
			new name[MAX_PLAYER_NAME];
			GetPVarString(playerid, "TempNameName", name, sizeof(name));
			if(strlen(name) > 0)
			{
				SetPlayerName(playerid, name);
				SetPVarInt(playerid, "TempName", 0);
				SendClientMessageEx(playerid, COLOR_YELLOW, "Da doi lai ten cua ban thanh %s.", name);
				SendClientMessageEx(playerid, COLOR_GRAD2, "LUU Y: Du lieu cua ban se duoc luu tro lai.");
			}
		}
	}
	return 1;
}

CMD:setname(playerid, params[])
{
	new giveplayerid, name[MAX_PLAYER_NAME];
	if(sscanf(params, "us[24]", giveplayerid, name)) return SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /setname [playerid] [newname]");

	if(IsPlayerConnected(giveplayerid))
	{
		if (PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
		{
		    if(strlen(name) > MAX_PLAYER_NAME)
			{
				return SendClientMessageEx(playerid, COLOR_WHITE, "Ten khong duoc dai qua %d ky tu.", MAX_PLAYER_NAME);
			}
			new query[128], tmpName[MAX_PLAYER_NAME];
			mysql_escape_string(name, tmpName);
			if(strcmp(name, tmpName, false) == 0)
			{
	   			SetPVarString(playerid, "OnSetName", tmpName);

				mysql_format(MainPipeline, query, sizeof(query), "SELECT `Username` FROM `accounts` WHERE `Username`='%s'", tmpName);
				mysql_tquery(MainPipeline, query, "OnSetName", "ii", playerid, giveplayerid);
			}
			else return SendClientMessageEx(playerid, COLOR_GRAD2, "Ky tu khong hop le!");
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay.");
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Khong co nguoi choi nay");
	}
	return 1;
}

CMD:blowup(playerid, params[])
{
	new string[128], giveplayerid;
	if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /blowup [player]");
	if((PlayerInfo[giveplayerid][pAdmin] >= PlayerInfo[playerid][pAdmin]) && giveplayerid != playerid) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung lenh voi Admin ngang hoac cao cap hon!");
	if(IsPlayerConnected(giveplayerid))
	{
		if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
		{
			if(IsPlayerConnected(giveplayerid))
			{
				SendClientMessageEx(playerid,COLOR_GRAD2,"Da lam no %s (ID: %d).",GetPlayerNameEx(giveplayerid),giveplayerid);
				new Float:boomx, Float:boomy, Float:boomz;
				GetPlayerPos(giveplayerid,boomx, boomy, boomz);
				CreateExplosion(boomx, boomy , boomz, 7, 1);
				format(string, sizeof(string), "AdmCmd: %s has exploded %s(%d)", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
				Log("logs/admin.log", string);
				DBLog(playerid, giveplayerid, "Admin", "exploded");
			}
			else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
		}
	}
	return 1;
}

CMD:givenos(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /givenos [player]");

		if(giveplayerid == INVALID_PLAYER_ID) return 1;
		if(!IsPlayerConnected(giveplayerid)) return 1;
		if(IsPlayerInAnyVehicle(giveplayerid))
		{
			new VehicleID = GetPlayerVehicleID(giveplayerid), Model = GetVehicleModel(VehicleID);
			switch(Model)
			{
			case 448,461,462,463,468,471,509,510,521,522,523,581,586,449: return
				SendClientMessageEx(playerid,COLOR_GRAD1,"LOI: Khong the do xe nay!");
			}
			AddVehicleComponent(VehicleID, 1010); PlayerPlaySound(giveplayerid,1133,0.0,0.0,0.0);//NOS
			SendClientMessageEx(playerid,COLOR_GRAD1," Da them NOS vao xe cua %s.", GetPlayerNameEx(giveplayerid));
			format(string, sizeof(string), "AdmCmd: %s has given nos to %s(%d)", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
			Log("logs/admin.log", string);
			DBLog(playerid, giveplayerid, "Admin", "gave nos");
		}
		else
		{
			SendClientMessageEx(playerid,COLOR_GRAD1,"LOI: Nguoi do phai o trong xe.");
		}
	}
	else
	{
		SendClientMessageEx(playerid,COLOR_GRAD1,"Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:countdown(playerid, params[])
{
	if(IsARacer(playerid) && PlayerInfo[playerid][pTogReports] == 1 && PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pTogReports] == 1 && PlayerInfo[playerid][pASM] >= 1) {
	    if(CountDown == 0) {
        	SetTimerEx("Countdown", 100, false, "i", playerid); //Keep this at 100milliseconds
        } else {
            SendClientMessageEx(playerid, COLOR_WHITE, "Da co dem nguoc dang chay.");
        }
    }
    else if(IsARacer(playerid)) {
        if(CountDown == 0) {
        	SetTimerEx("Countdown", 100, false, "i", playerid); //Keep this at 100milliseconds
        } else {
            SendClientMessageEx(playerid, COLOR_WHITE, "Da co dem nguoc dang chay.");
        }
    }
    else if(PlayerInfo[playerid][pAdmin] >= 3 && PlayerInfo[playerid][pTogReports] == 0) {
        if(CountDown == 0) {
        	SetTimerEx("Countdown", 100, false, "i", playerid); //Keep this at 100milliseconds
        } else {
            SendClientMessageEx(playerid, COLOR_WHITE, "Da co dem nguoc dang chay.");
        }
    }
    return 1;
}

CMD:ipwhitelist(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		new query[256], giveplayer[MAX_PLAYER_NAME], ip[16];
		if(sscanf(params, "s[24]s[16]", giveplayer, ip))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /ipwhitelist [admin name] [IP]");
			return 1;
		}

		new tmpName[24], tmpIP[16];
		mysql_escape_string(giveplayer, tmpName);
		mysql_escape_string(ip, tmpIP);
		SetPVarString(playerid, "OnIPWhitelist", tmpName);

		mysql_format(MainPipeline, query, sizeof(query), "UPDATE `accounts` SET `SecureIP`='%s' WHERE `Username`='%s' AND `AdminLevel` <= %d", tmpIP, tmpName, PlayerInfo[playerid][pAdmin]);
		mysql_tquery(MainPipeline, query, "OnIPWhitelist", "i", playerid);

		SendClientMessageEx(playerid, COLOR_YELLOW, "Dang cho phep IP %s vao tai khoan %s...", tmpIP, tmpName);
	}
	return 1;
}



alias:hospital("hosp")
CMD:hospital(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2)
	{
		new giveplayerid;
		if(sscanf(params, "u", giveplayerid))
		{
			if(PlayerInfo[playerid][pHospital] > 0)
			{
				ClearAnimationsEx(playerid);
				SetPVarInt(playerid, "_SpawningAtHospital", 2);
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban da tu xuat vien.");
			}
			else return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /hospital [player]");
		}
		else
		{
			if(IsPlayerConnected(giveplayerid))
			{
				if(PlayerInfo[giveplayerid][pHospital] > 0)
				{
					SendClientMessageEx(playerid, COLOR_WHITE, " Da buoc %s xuat vien.", GetPlayerNameEx(giveplayerid));
					SendClientMessageEx(giveplayerid, COLOR_WHITE, "Admin da buoc ban xuat vien.");
					ClearAnimationsEx(giveplayerid);
					SetPVarInt(giveplayerid, "_SpawningAtHospital", 2);
				}
				else SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do khong o benh vien!");
			}
			else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
		}
	}
	return 1;
}

CMD:revive(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2)
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /revive [player]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(GetPVarInt(giveplayerid, "Injured") == 1)
			{
				SendClientMessageEx(playerid, COLOR_WHITE, " Da hoi sinh %s.", GetPlayerNameEx(giveplayerid));
				SendClientMessageEx(giveplayerid, COLOR_WHITE, "Ban da duoc Admin hoi sinh.");
				format(string, sizeof(string), "AdmCmd: %s(%d) has been revived by %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid));
				Log("logs/admin.log", string);
				DBLog(playerid, giveplayerid, "Admin", "revived");

				KillEMSQueue(giveplayerid);
   				ClearAnimationsEx(giveplayerid);
   				SetHealth(giveplayerid, 100);
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do khong bi thuong!");
			}
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:revivenear(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2)
	{
		new string[128], radius, count;
		if(sscanf(params, "d", radius)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /revivenear [radius]");

		if(radius < 1 || radius > 100)
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban kinh phai lon hon 0 va nho hon 100!");
			return 1;
		}
        foreach(new i: Player)
        {
        	if(ProxDetectorS(radius, playerid, i))
			{
				if(GetPVarInt(i, "Injured") == 1)
				{

					SetHealth(i, 100);
					count++;
					SendClientMessageEx(i, COLOR_WHITE, "Ban da duoc Admin hoi sinh.");
					KillEMSQueue(i);
					ClearAnimationsEx(i);
					SetHealth(i, 100);
					format(string, sizeof(string), "AdmCmd: %s(%d) has been revived by %s", GetPlayerNameEx(i), GetPlayerSQLId(i), GetPlayerNameEx(playerid));
					Log("logs/admin.log", string);
					DBLog(playerid, i, "Admin", "revived (/revivenear)");
				}
			}
        }
		SendClientMessageEx(playerid, COLOR_WHITE, "Da hoi sinh moi nguoi (%d) o gan.", count);
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:forcedeath(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 3)
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /forcedeath [player]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(GetPVarInt(giveplayerid, "Injured") == 1)
			{
				SendClientMessageEx(playerid, COLOR_WHITE, " Da buoc %s tu vong.", GetPlayerNameEx(giveplayerid));
				SendClientMessageEx(giveplayerid, COLOR_WHITE, "Admin da buoc ban tu vong.");
				KillEMSQueue(giveplayerid);
				ResetPlayerWeaponsEx(giveplayerid);
				SpawnPlayer(giveplayerid);
				format(string, sizeof(string), "AdmCmd: %s has forced death %s(%d)", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
				Log("logs/admin.log", string);
				DBLog(playerid, giveplayerid, "Admin", "forced death");
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do khong bi thuong!");
			}
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:ipcheck(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2)
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /ipcheck [player]");

		if(giveplayerid == INVALID_PLAYER_ID) return 1;
		if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");

		if(PlayerInfo[giveplayerid][pAdmin] <= 1 || (PlayerInfo[giveplayerid][pAdmin] <= PlayerInfo[playerid][pAdmin] && PlayerInfo[playerid][pAdmin] >= 1337))
		{
			new playerip[32];
			GetPlayerIp(giveplayerid, playerip, sizeof(playerip));
			SendClientMessageEx(playerid, COLOR_WHITE, "(ID: %d) - (Ten: %s) - (IP: %s)", giveplayerid, GetPlayerNameEx(giveplayerid), playerip);
			format(string, sizeof(string), "%s has IP Checked %s(%d)", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
			if(PlayerInfo[giveplayerid][pAdmin] >= 2) {
				Log("logs/adminipcheck.log", string);
				DBLog(playerid, giveplayerid, "AdminIPCheck", "performed an IP check");
			}
			else {
				Log("logs/ipcheck.log", string);
				DBLog(playerid, giveplayerid, "IPCheck", "performed an IP check");
			}
			return 1;
		}
		if(PlayerInfo[giveplayerid][pAdmin] >= 2)
		{
			if(PlayerInfo[giveplayerid][pAdmin] > PlayerInfo[playerid][pAdmin])
			{
				format(string, sizeof(string), "%s da thu xem IP cua Admin cap cao hon\nHay bao ngay cho SIU/OED hoac EA", GetPlayerNameEx(playerid));
				foreach(new i : Player)
				{
					if(PlayerInfo[i][pAdmin] >= 4) ShowPlayerDialogEx(i, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, "{FFFF00}AdminWarning - {FF0000}Bao cao ngay", string, "Dong", "");
				}
			}
			format(string, sizeof(string), "%s tried to IP check %s(%d)", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
			Log("logs/adminipcheck.log", string);
			DBLog(playerid, giveplayerid, "AdminIPCheck", "tried to IP check a higher admin");
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:pfine(playerid, params[])
{
	new string[128], giveplayerid, percentage, minimum, reason[64];
	if(sscanf(params, "udds[64]", giveplayerid, percentage, minimum, reason)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /pfine [player] [percentage] [minimum] [reason]");

	if (PlayerInfo[playerid][pAdmin] >= 3)
	{
		if(IsPlayerConnected(giveplayerid))
		{
			new totalwealth = PlayerInfo[giveplayerid][pAccount] + GetPlayerCash(giveplayerid);
			if(PlayerInfo[giveplayerid][pPhousekey] != INVALID_HOUSE_ID && HouseInfo[PlayerInfo[giveplayerid][pPhousekey]][hOwnerID] == GetPlayerSQLId(giveplayerid)) totalwealth += HouseInfo[PlayerInfo[giveplayerid][pPhousekey]][hSafeMoney];
			if(PlayerInfo[giveplayerid][pPhousekey2] != INVALID_HOUSE_ID && HouseInfo[PlayerInfo[giveplayerid][pPhousekey2]][hOwnerID] == GetPlayerSQLId(giveplayerid)) totalwealth += HouseInfo[PlayerInfo[giveplayerid][pPhousekey2]][hSafeMoney];
			if(PlayerInfo[giveplayerid][pPhousekey3] != INVALID_HOUSE_ID && HouseInfo[PlayerInfo[giveplayerid][pPhousekey3]][hOwnerID] == GetPlayerSQLId(giveplayerid)) totalwealth += HouseInfo[PlayerInfo[giveplayerid][pPhousekey3]][hSafeMoney];
			if(totalwealth < 1) return SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Nguoi do khong co tien!");

			new fine = percentage * totalwealth / 100;
			if(percentage < 1 || percentage > 100) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ty le phai lon hon 0 va nho hon 100.");
			else if(minimum < 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Muc toi thieu phai lon hon 0.");

			if(minimum > fine)
			{
				//GivePlayerCash(giveplayerid, -minimum);
				GivePlayerCashEx(giveplayerid, TYPE_ONHAND, -minimum);
				format(string, sizeof(string), "AdmCmd: %s(%d) was fined $%s by %s, reason: %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), number_format(minimum), GetPlayerNameEx(playerid), reason);
				Log("logs/admin.log", string);
				format(szMiscArray, sizeof(szMiscArray), "was fined $%s (%s)", number_format(minimum), reason);
				DBLog(playerid, giveplayerid, "Admin", szMiscArray);
				format(string, sizeof(string), "AdmCmd: %s bi phat $%s boi %s, ly do: %s", GetPlayerNameEx(giveplayerid), number_format(minimum), GetPlayerNameEx(playerid), reason);
			}
			else
			{
				//GivePlayerCash(giveplayerid, -fine);
				GivePlayerCashEx(giveplayerid, TYPE_ONHAND, -fine);
				format(string, sizeof(string), "AdmCmd: %s(%d) was fined $%s by %s, reason: %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), number_format(fine), GetPlayerNameEx(playerid), reason);
				Log("logs/admin.log", string);
				format(szMiscArray, sizeof(szMiscArray), "was fined $%s (%s)", number_format(fine), reason);
				DBLog(playerid, giveplayerid, "Admin", szMiscArray);
				format(string, sizeof(string), "AdmCmd: %s bi phat $%s boi %s, ly do: %s", GetPlayerNameEx(giveplayerid), number_format(fine), GetPlayerNameEx(playerid), reason);
			}

			SendClientMessageToAllEx(COLOR_LIGHTRED, string);
			//OnPlayerStatsUpdate(giveplayerid);
			return 1;
		}
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:fine(playerid, params[])
{
	new string[128], giveplayerid, amount, reason[64];
	if(sscanf(params, "uds[64]", giveplayerid, amount, reason)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /fine [player] [amount] [reason]");

	if (PlayerInfo[playerid][pAdmin] >= 3)
	{
		if(strcmp(GetPlayerIpEx(playerid), PlayerInfo[playerid][pSecureIP], false, 16) != 0)
		{
			format(string, sizeof(string), "[/FINE] %s bi vo hieu tai khoan vi IP khong duoc phep, hay lien he Security.", GetPlayerNameEx(playerid));
			ABroadCast(COLOR_YELLOW, string, 4);
			Log("logs/admin.log", string);
			DBLog(playerid, INVALID_PLAYER_ID, "Admin", "Account auto-disabled (whitelist fail)");
			PlayerInfo[playerid][pDisabled] = 1;
			Kick(playerid);
			return 1;
		}
		if(IsPlayerConnected(giveplayerid))
		{
			if (amount < 1)
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "So luong phai lon hon 0");
				return 1;
			}
			format(string, sizeof(string), "AdmCmd: %s(%d) was fined $%s by %s, reason: %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), number_format(amount), GetPlayerNameEx(playerid), reason);
			Log("logs/admin.log", string);
			format(szMiscArray, sizeof(szMiscArray), "fined $%s (%s)", number_format(amount), reason);
			DBLog(playerid, giveplayerid, "Admin", szMiscArray);
			SendClientMessageToAllEx(COLOR_LIGHTRED, "AdmCmd: %s bi phat $%s boi %s, ly do: %s", GetPlayerNameEx(giveplayerid), number_format(amount), GetPlayerNameEx(playerid), reason);
			StaffAccountCheck(giveplayerid, GetPlayerIpEx(giveplayerid));
			GivePlayerCash(giveplayerid, -amount);
			OnPlayerStatsUpdate(giveplayerid);
			return 1;
		}
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong phai Admin cap ba.");
	}
	return 1;
}

CMD:sfine(playerid, params[])
{
	new string[128], giveplayerid, amount, reason[64];
	if(sscanf(params, "uds[64]", giveplayerid, amount, reason)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /sfine [player] [amount] [reason]");

	if (PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		if(strcmp(GetPlayerIpEx(playerid), PlayerInfo[playerid][pSecureIP], false, 16) != 0)
		{
			format(string, sizeof(string), "[/SFINE] %s bi vo hieu tai khoan vi IP khong duoc phep, hay lien he Security.", GetPlayerNameEx(playerid));
			ABroadCast(COLOR_YELLOW, string, 4);
			Log("logs/admin.log", string);
			DBLog(playerid, INVALID_PLAYER_ID, "Admin", "Account auto-disabled (whitelist fail)");
			PlayerInfo[playerid][pDisabled] = 1;
			Kick(playerid);
			return 1;
		}
		if(IsPlayerConnected(giveplayerid))
		{
			if (amount < 1)
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "So luong phai lon hon 0");
				return 1;
			}
			format(string, sizeof(string), "AdmCmd: %s(%d) was silent fined $%s by %s, reason: %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), number_format(amount), GetPlayerNameEx(playerid), reason);
			Log("logs/admin.log", string);
			format(szMiscArray, sizeof(szMiscArray), "silent fined $%s (%s)", number_format(amount), reason);
			DBLog(playerid, giveplayerid, "Admin", szMiscArray);
			format(string, sizeof(string), "AdmCmd: %s bi phat an $%s boi %s, ly do: %s", GetPlayerNameEx(giveplayerid), number_format(amount), GetPlayerNameEx(playerid), reason);
			ABroadCast(COLOR_LIGHTRED, string, 2);
			SendClientMessageEx(giveplayerid, COLOR_LIGHTRED, "Ban bi phat an $%s boi %s, ly do: %s", number_format(amount), GetPlayerNameEx(playerid), reason);
			GivePlayerCash(giveplayerid, -amount);
			OnPlayerStatsUpdate(giveplayerid);
			return 1;
		}
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong phai Admin cap ba.");
	}
	return 1;
}

CMD:listguns(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2)
	{
		new giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /listguns [player]");

		if(IsPlayerConnected(giveplayerid))
		{
			new weapons[13][2], weaponname[50];
			if(GetPVarInt(giveplayerid, "EventToken") != 0 || GetPVarType(giveplayerid, "IsInArena"))
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do dang o su kien/Paintball nen vu khi co the hien thi la ngoai he thong.");
			}
			SendClientMessageEx(playerid, COLOR_GREEN,"_______________________________________");
			SendClientMessageEx(playerid, COLOR_WHITE, "Vu khi cua %s:", GetPlayerNameEx(giveplayerid));
			for (new i = 0; i < 13; i++)
			{
				GetPlayerWeaponData(giveplayerid, i, weapons[i][0], weapons[i][1]);
				if(weapons[i][0] > 0)
				{
					if(PlayerInfo[giveplayerid][pGuns][i] == weapons[i][0])
					{
						GetWeaponName(weapons[i][0], weaponname, sizeof(weaponname));
						SendClientMessageEx(playerid, COLOR_GRAD1, "%s (%d).", weaponname, weapons[i][0]);
					}
					else
					{
						GetWeaponName(weapons[i][0], weaponname, sizeof(weaponname));
						SendClientMessageEx(playerid, COLOR_GRAD1, "%s (%d) (ngoai he thong).", weaponname, weapons[i][0]);
					}
				}
			}
			SendClientMessageEx(playerid, COLOR_GREEN,"_______________________________________");
		}
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:oipcheck(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3)
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
		return 1;
	}

	new query[128], name[MAX_PLAYER_NAME];
	if(sscanf(params, "s[24]", name)) return SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /oipcheck [name]");

	new tmpName[24];
	mysql_escape_string(name, tmpName);

	mysql_format(MainPipeline, query, sizeof(query), "SELECT `AdminLevel`, `Username`, `IP` FROM `accounts` WHERE `Username` = '%s'", tmpName);
	mysql_tquery(MainPipeline, query, "OnIPCheck", "i", playerid);
	return 1;
}

CMD:serverstats(playerid, params[])
{
	new
		iVehCount,
		x;

	while(x < MAX_VEHICLES) if(GetVehicleModel(++x)) ++iVehCount;

	SendClientMessageEx(playerid, COLOR_WHITE, "Thong ke may chu - Phien ban %s (ghi nhan tu ngay 20 thang Tam nam 2010).",SERVER_GM_TEXT);
	SendClientMessageEx(playerid, COLOR_GREY, "* Vat the: %d | Pickup: %d | Icon ban do: %d | Nhan 3D: %d | TextDraw: %d | Nha da tai: %d",CountDynamicObjects(),CountDynamicPickups(),CountDynamicMapIcons(),CountDynamic3DTextLabels(),textdrawscount,MAX_HOUSES);
	SendClientMessageEx(playerid, COLOR_GREY, "* Dang nhap: %d | Ket noi: %d | Dang ky: %d | Tu dong cam hack: %d | Hoat dong: %d gio",TotalLogin, TotalConnect, TotalRegister, TotalAutoBan, TotalUptime);
	SendClientMessageEx(playerid, COLOR_GREY, "* Dang online: %d | Dong nhat: %d (%d/%d/%d) | Xe nguoi choi da tai: %d | Tong xe: %i",Iter_Count(Player),MaxPlayersConnected,MPDay,MPMonth,MPYear,PlayerCars, iVehCount);
	return 1;
}

CMD:payday(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 1337) {
	    PlayerInfo[playerid][pConnectSeconds] = 3600;
		PayDay(playerid);
	}
	return 1;
}

CMD:ofine(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 3)
	{

		new string[128], query[256], name[MAX_PLAYER_NAME], amount, reason[64];
		if(sscanf(params, "s[24]ds[64]", name, amount, reason)) return SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /ofine [name] [amount] [reason]");
        new giveplayerid = ReturnUser(name);
		if(IsPlayerConnected(giveplayerid))
		{
            if (amount < 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "So luong phai lon hon 0");
			format(string, sizeof(string), "AdmCmd: %s(%d) was fined $%s by %s, reason: %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), number_format(amount), GetPlayerNameEx(playerid), reason);
			Log("logs/admin.log", string);
			format(szMiscArray, sizeof(szMiscArray), "fined $%s (%s)", number_format(amount), reason);
			DBLog(playerid, giveplayerid, "Admin", szMiscArray);
			SendClientMessageToAllEx(COLOR_LIGHTRED, "AdmCmd: %s bi phat $%s boi %s, ly do: %s", GetPlayerNameEx(giveplayerid), number_format(amount), GetPlayerNameEx(playerid), reason);
			GivePlayerCash(giveplayerid, -amount);
			StaffAccountCheck(giveplayerid, GetPlayerIpEx(giveplayerid));
		}
		else
		{
			new tmpName[24];
			mysql_escape_string(name, tmpName);
			SetPVarString(playerid, "OnFine", tmpName);
			SetPVarInt(playerid, "OnFineAmount", amount);
			SetPVarString(playerid, "OnFineReason", reason);


			mysql_format(MainPipeline, query, sizeof(query), "UPDATE `accounts` SET `Money` = `Money` - %d WHERE `PermBand` < 3 AND `Band` = 0 AND `AdminLevel` < 2 AND `Username`='%s'", amount, tmpName);
			mysql_tquery(MainPipeline, query, "OnFine", "i", playerid);

			SendClientMessageEx(playerid, COLOR_YELLOW, "Dang phat $%s tu tai khoan %s...", number_format(amount), tmpName);
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong phai Admin cap ba.");
	}
	return 1;
}

CMD:check(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 2)
	{
		new giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /check [player]");
		if(IsPlayerConnected(giveplayerid)) ShowStats(playerid, giveplayerid);
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:checkinv(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 2)
	{
		new giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /checkinv [player]");
		if(IsPlayerConnected(giveplayerid)) ShowInventory(playerid, giveplayerid);
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:mole(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 3)
	{
		new string[128], log[128];
		if(isnull(params)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /mole [mole text]");

		format(string, sizeof(string), "SMS: %s, Tu: MOLE (555)", params);
		foreach(new i: Player)
		{
			SendClientMessageEx(i, COLOR_YELLOW, string);
			//SendAudioToPlayer(i, 47, 100);
		}
		format(log, sizeof(log), "[MOLE] %s sent: %s", GetPlayerNameEx(playerid), params);
		Log("logs/admin.log", log);
		ChatDBLog(playerid, "AdminMole", params);
	}
	else SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	return 1;
}

// Both below were adjusted to Head Admin because of them now being able to roleplay on their admin account. - Winterfield

CMD:togspec(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 1337)
	{
	    if(GetPVarType(playerid, "EASpecable"))
	    {
	        SendClientMessage(playerid, COLOR_WHITE, "Khong ai co the theo doi ban nua");
	        DeletePVar(playerid, "EASpecable");
	    }
	    else
	    {
	        SendClientMessage(playerid, COLOR_WHITE, "Nguoi khac da co the theo doi ban tro lai");
	        SetPVarInt(playerid, "EASpecable", 1);
	    }
	}
	return 1;
}

CMD:togtp(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 1337)
	{
	    if(GetPVarType(playerid, "EATeleportable"))
	    {
	        SendClientMessage(playerid, COLOR_WHITE, "Khong ai co the dich chuyen den ban nua");
	        DeletePVar(playerid, "EATeleportable");
	    }
	    else
	    {
	        SendClientMessage(playerid, COLOR_WHITE, "Nguoi khac da co the dich chuyen den ban tro lai");
	        SetPVarInt(playerid, "EATeleportable", 1);
	    }
	}
	return 1;
}

CMD:spec(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2 && PlayerInfo[playerid][pHelper] < 1)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
		return 1;
	}
	if(GetPVarInt(playerid, "Injured") == 1 && PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, COLOR_GREY, "Ban dang bi thuong.");
	if(strcmp(params, "off", true) == 0)
	{
		if(Spectating[playerid] > 0 && PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[playerid][pHelper] >= 1 && Spectating[playerid] > 0)
		{
			GettingSpectated[Spectate[playerid]] = INVALID_PLAYER_ID;
			Spectating[playerid] = 0;
			Spectate[playerid] = INVALID_PLAYER_ID;
			SpecTime[playerid] = 0;
			SetPVarInt(playerid, "SpecOff", 1 );
			TogglePlayerSpectating(playerid, false);
			SetCameraBehindPlayer(playerid);
			return 1;
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban khong dang theo doi ai.");
			return 1;
		}
	}

	new giveplayerid;

	if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /spec (playerid/off)");
	if(giveplayerid != INVALID_PLAYER_ID)
	{
		if(PlayerInfo[playerid][pHelper] < PlayerInfo[giveplayerid][pHelper] && PlayerInfo[playerid][pAdmin] < 2) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the theo doi Helper cap cao hon.");
		if(PlayerInfo[playerid][pHelper] > 0 && PlayerInfo[giveplayerid][pAdmin] > 1) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the theo doi Admin");
		if(PlayerInfo[playerid][pHelper] > 0) {
			switch(PlayerInfo[playerid][pHelper]) {
				case 1, 2: if(!(1 <= PlayerInfo[giveplayerid][pLevel] <= 5)) return SendClientMessageEx(playerid, COLOR_GREY, "JPA/GPA chi duoc dung voi nguoi cap 1 - 5!");
				case 3, 4: if(!(1 <= PlayerInfo[giveplayerid][pLevel] <= 10)) return SendClientMessageEx(playerid, COLOR_GREY, "SPA/CPA chi duoc dung voi nguoi cap 1 - 10!");
			}
		}
		if(PlayerInfo[giveplayerid][pAdmin] > 1337 && !GetPVarType(giveplayerid, "EASpecable")) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the theo doi nguoi nay.");
		if(PlayerInfo[playerid][pAdmin] >= 4 && Spectate[giveplayerid] != INVALID_PLAYER_ID && Spectating[giveplayerid] == 1)
		{
			new string[128];
			format(string, sizeof(string), "Admin %s theo doi %s", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(Spectate[giveplayerid]));
			if(PlayerInfo[playerid][pAdmin] >= 1337 && SpecTime[giveplayerid])
			{
				new seconds = gettime()-SpecTime[giveplayerid];
				new minutes = seconds/60;
				format(string, sizeof(string), "%s (%d ph %d giay)", string, minutes, seconds-60*minutes);
			}
			SendClientMessageEx(playerid, COLOR_GREEN, string);
			return 1;
		}
		SpectatePlayer(playerid, giveplayerid);
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "Muc tieu khong san sang.");
	}
	return 1;
}

CMD:rcreset(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] >= 1337) {

		new
			iTargetID;

		if(sscanf(params, "u", iTargetID)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /rcreset [player]");
		}
		else if(!IsPlayerConnected(iTargetID)) {
			SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
		}
		else {

			new
				i = 0,
				szMessage[96];

			format(szMessage, sizeof szMessage, "AdmCmd: %s da dat lai canh bao xe han che cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
			ABroadCast(COLOR_LIGHTRED, szMessage, 2);

			SendClientMessageEx(iTargetID, COLOR_WHITE, "%s da dat lai canh bao xe han che cua ban.", GetPlayerNameEx(playerid));

			DBLog(playerid, iTargetID, "Admin", "Reset Restricted Veh Warns");

			PlayerInfo[iTargetID][pRVehWarns] = 0;
			PlayerInfo[iTargetID][pLastRVehWarn] = 0;
			PlayerInfo[iTargetID][pRVehRestricted] = 0;

			while(i != MAX_PLAYERVEHICLES) {
				if(PlayerVehicleInfo[iTargetID][i][pvRestricted] != 0) {
					PlayerVehicleInfo[iTargetID][i][pvRestricted] = 0;
				}
				++i;
			}
		}
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:rcabuse(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1) {

		new
			iTargetID;

		if(sscanf(params, "u", iTargetID)) SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /rcabuse [player]");
		else if(!IsPlayerConnected(iTargetID)) SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
		else if(GetPlayerState(iTargetID) == PLAYER_STATE_DRIVER && IsRestrictedVehicle(GetVehicleModel(GetPlayerVehicleID(iTargetID))))
		{
			new
				iVehicleID = GetPlayerVehicleID(iTargetID),
				iVehIndex = GetPlayerVehicle(iTargetID, iVehicleID),
				Float: fPlayerPos[3],
				szMessage[256]; // Dialog string - don't kill me!!!!!1

			if(iVehIndex != -1) { // Owned by player
				switch(++PlayerInfo[iTargetID][pRVehWarns]) {
					case 1: {

						PlayerVehicleInfo[iTargetID][iVehIndex][pvRestricted] = gettime() + 28800;

						--PlayerCars;
						VehicleSpawned[iTargetID]--;

						PlayerVehicleInfo[iTargetID][iVehIndex][pvSpawned] = 0;
						PlayerVehicleInfo[iTargetID][iVehIndex][pvFuel] = VehicleFuel[iVehicleID];

						DestroyVehicle(iVehicleID);
						PlayerVehicleInfo[iTargetID][iVehIndex][pvId] = INVALID_PLAYER_VEHICLE_ID;
						g_mysql_SaveVehicle(iTargetID, iVehIndex);
						CheckPlayerVehiclesForDesync(iTargetID);

						GetPlayerPos(iTargetID, fPlayerPos[0], fPlayerPos[1], fPlayerPos[2]);
						SetPlayerPosFindZ(iTargetID, fPlayerPos[0], fPlayerPos[1], fPlayerPos[2]);

						format(szMessage, sizeof szMessage, "%s canh bao ban vi lam dung xe %s.\n\nDay la lan dau, xe se bi han che su dung trong 8 gio.", GetPlayerNameEx(playerid), GetVehicleName(iVehicleID));
						ShowPlayerDialogEx(iTargetID, 0, DIALOG_STYLE_MSGBOX, "Canh bao xe bi han che", szMessage, "Thoat", "");
						SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da canh cao nguoi nay vi lam dung xe bi han che.");

					}
					case 2: {

						PlayerInfo[iTargetID][pRVehRestricted] = gettime() + 172800;

						--PlayerCars;
						VehicleSpawned[iTargetID]--;

						PlayerVehicleInfo[iTargetID][iVehIndex][pvSpawned] = 0;
						PlayerVehicleInfo[iTargetID][iVehIndex][pvFuel] = VehicleFuel[iVehicleID];

						DestroyVehicle(iVehicleID);
						PlayerVehicleInfo[iTargetID][iVehIndex][pvId] = INVALID_PLAYER_VEHICLE_ID;
						g_mysql_SaveVehicle(iTargetID, iVehIndex);
						CheckPlayerVehiclesForDesync(iTargetID);

						GetPlayerPos(iTargetID, fPlayerPos[0], fPlayerPos[1], fPlayerPos[2]);
						SetPlayerPosFindZ(iTargetID, fPlayerPos[0], fPlayerPos[1], fPlayerPos[2]);

						format(szMessage, sizeof szMessage, "%s canh bao ban vi lam dung xe %s.\n\nDay la lan thu hai, ban khong the dung xe han che trong hai ngay.", GetPlayerNameEx(playerid), GetVehicleName(iVehicleID));
						ShowPlayerDialogEx(iTargetID, 0, DIALOG_STYLE_MSGBOX, "Canh bao xe bi han che", szMessage, "Thoat", "");
						SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da canh cao nguoi nay vi lam dung xe bi han che.");
					}
					case 3: {

						PlayerInfo[iTargetID][pRVehRestricted] = gettime() + 604800;
						PlayerInfo[iTargetID][pRVehWarns] = 0;
						DestroyPlayerVehicle(iTargetID, iVehIndex);

						GetPlayerPos(iTargetID, fPlayerPos[0], fPlayerPos[1], fPlayerPos[2]);
						SetPlayerPosFindZ(iTargetID, fPlayerPos[0], fPlayerPos[1], fPlayerPos[2]);

						format(szMessage, sizeof szMessage, "%s canh bao ban vi lam dung xe %s.\n\nDay la lan thu ba, ban khong the dung xe han che trong mot tuan va xe vi pham da bi thu hoi.", GetPlayerNameEx(playerid), GetVehicleName(iVehicleID));
						ShowPlayerDialogEx(iTargetID, 0, DIALOG_STYLE_MSGBOX, "Canh bao xe bi han che", szMessage, "Thoat", "");
						SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da canh cao nguoi nay vi lam dung xe bi han che.");
					}
				}
			}
			else foreach(new i: Player)
			{
				if((iVehIndex = GetPlayerVehicle(i, iVehicleID)) != -1) { // Owned by another player
					switch(++PlayerInfo[iTargetID][pRVehWarns]) {
						case 1: {

							SetVehicleToRespawn(iVehicleID);
							CheckPlayerVehiclesForDesync(i);

							GetPlayerPos(iTargetID, fPlayerPos[0], fPlayerPos[1], fPlayerPos[2]);
							SetPlayerPosFindZ(iTargetID, fPlayerPos[0], fPlayerPos[1], fPlayerPos[2]);

							format(szMessage, sizeof szMessage, "%s canh bao ban vi lam dung xe cua %s, mau xe %s.\n\nDay la lan dau, mot xe han che cua ban (neu co) se bi khoa trong hai ngay.", GetPlayerNameEx(playerid), GetPlayerNameEx(i), GetVehicleName(iVehicleID));
							ShowPlayerDialogEx(iTargetID, 0, DIALOG_STYLE_MSGBOX, "Canh bao xe bi han che", szMessage, "Thoat", "");
							SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da canh cao nguoi nay vi lam dung xe bi han che.");

							for(new x = 0; x != MAX_PLAYERVEHICLES; ++x) if(IsRestrictedVehicle(PlayerVehicleInfo[iTargetID][iVehIndex][pvModelId])) {
								PlayerVehicleInfo[iTargetID][iVehIndex][pvRestricted] = gettime() + 28800;
								break;
							}
						}
						case 2: {

							PlayerInfo[iTargetID][pRVehRestricted] = gettime() + 172800;

							SetVehicleToRespawn(iVehicleID);
							CheckPlayerVehiclesForDesync(i);

							GetPlayerPos(iTargetID, fPlayerPos[0], fPlayerPos[1], fPlayerPos[2]);
							SetPlayerPosFindZ(iTargetID, fPlayerPos[0], fPlayerPos[1], fPlayerPos[2]);

							format(szMessage, sizeof szMessage, "%s canh bao ban vi lam dung xe cua %s, mau xe %s.\n\nDay la lan thu hai, ban khong the dung xe han che trong hai ngay.", GetPlayerNameEx(playerid), GetPlayerNameEx(i), GetVehicleName(iVehicleID));
							ShowPlayerDialogEx(iTargetID, 0, DIALOG_STYLE_MSGBOX, "Canh bao xe bi han che", szMessage, "Thoat", "");
							SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da canh cao nguoi nay vi lam dung xe bi han che.");
						}
						case 3: {

							PlayerInfo[iTargetID][pRVehRestricted] = gettime() + 604800;
							PlayerInfo[iTargetID][pRVehWarns] = 0;

							GetPlayerPos(iTargetID, fPlayerPos[0], fPlayerPos[1], fPlayerPos[2]);
							SetPlayerPosFindZ(iTargetID, fPlayerPos[0], fPlayerPos[1], fPlayerPos[2]);

							format(szMessage, sizeof szMessage, "%s canh bao ban vi lam dung xe cua %s, mau xe %s.\n\nDay la lan thu ba, ban khong the dung xe han che trong mot tuan.", GetPlayerNameEx(playerid), GetPlayerNameEx(i), GetVehicleName(iVehicleID));
							ShowPlayerDialogEx(iTargetID, 0, DIALOG_STYLE_MSGBOX, "Canh bao xe bi han che", szMessage, "Thoat", "");
							SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da canh cao nguoi nay vi lam dung xe bi han che.");
						}
					}
					format(szMessage, sizeof szMessage, "%s da canh bao %s vi lam dung xe %s cua ban.\n\nXe vi pham da duoc tao lai. Hay quan ly xe han che cua ban can than.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID), GetVehicleName(iVehicleID));
					ShowPlayerDialogEx(i, 0, DIALOG_STYLE_MSGBOX, "Canh bao xe bi han che", szMessage, "Thoat", "");
					SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da canh cao nguoi nay vi lam dung xe bi han che.");
					break;
				}
			}
			if(iVehIndex == -1 && IsACop(iTargetID)) { // Not person owned
				SetVehicleToRespawn(iVehicleID);
				switch(++PlayerInfo[iTargetID][pRVehWarns]) {
					case 1: {
						GetPlayerPos(iTargetID, fPlayerPos[0], fPlayerPos[1], fPlayerPos[2]);
						SetPlayerPosFindZ(iTargetID, fPlayerPos[0], fPlayerPos[1], fPlayerPos[2]);
						format(szMessage, sizeof szMessage, "%s canh bao ban vi lam dung xe %s cua to chuc.\n\nDay la lan dau, ban chua bi phat.", GetPlayerNameEx(playerid), GetVehicleName(iVehicleID));
						ShowPlayerDialogEx(iTargetID, 0, DIALOG_STYLE_MSGBOX, "Canh bao xe bi han che", szMessage, "Thoat", "");
						SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da canh cao nguoi nay vi lam dung xe bi han che.");
					}
					case 2: {

						PlayerInfo[iTargetID][pRVehRestricted] = gettime() + 1209600;

						GetPlayerPos(iTargetID, fPlayerPos[0], fPlayerPos[1], fPlayerPos[2]);
						SetPlayerPosFindZ(iTargetID, fPlayerPos[0], fPlayerPos[1], fPlayerPos[2]);
						format(szMessage, sizeof szMessage, "%s canh bao ban vi lam dung xe %s cua to chuc.\n\nDay la lan thu hai, ban khong the dung xe han che trong hai tuan va bi giam hai gio.", GetPlayerNameEx(playerid), GetVehicleName(iVehicleID));
						ShowPlayerDialogEx(iTargetID, 0, DIALOG_STYLE_MSGBOX, "Canh bao xe bi han che", szMessage, "Thoat", "");
						SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da canh cao nguoi nay vi lam dung xe bi han che.");

						GameTextForPlayer(iTargetID, "~w~Chao mung den ~n~~r~Fort DeMorgan", 5000, 3);
						ResetPlayerWeaponsEx(iTargetID);
						format(szMessage, sizeof(szMessage), "AdmCmd: %s(%d) has been prisoned by %s, reason: Abuse of faction vehicles.", GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID), GetPlayerNameEx(playerid));
						Log("logs/admin.log", szMessage);
						DBLog(playerid, iTargetID, "Admin", "[Prisoned] Restricted Vehicle Abuse");
						SendClientMessageToAllEx(COLOR_LIGHTRED, "AdmCmd: %s da bi %s giam, ly do: Lam dung xe to chuc.", GetPlayerNameEx(iTargetID), GetPlayerNameEx(playerid));
						PlayerInfo[iTargetID][pJailTime] = 120 * 60;
						strcpy(PlayerInfo[iTargetID][pPrisonReason], "[OOC][PRISON] Lam dung xe to chuc", 128);
						strcpy(PlayerInfo[iTargetID][pPrisonedBy], GetPlayerNameEx(playerid), MAX_PLAYER_NAME);
						PhoneOnline[iTargetID] = 1;
						SetPlayerInterior(iTargetID, 1);
						PlayerInfo[iTargetID][pInt] = 1;
						new rand = random(sizeof(OOCPrisonSpawns));
						Streamer_UpdateEx(iTargetID, OOCPrisonSpawns[rand][0], OOCPrisonSpawns[rand][1], OOCPrisonSpawns[rand][2]);
						SetPlayerPos(iTargetID, OOCPrisonSpawns[rand][0], OOCPrisonSpawns[rand][1], OOCPrisonSpawns[rand][2]);
						SetPlayerSkin(iTargetID, 50);
						SetPlayerColor(iTargetID, TEAM_APRISON_COLOR);
						Player_StreamPrep(iTargetID, OOCPrisonSpawns[rand][0], OOCPrisonSpawns[rand][1], OOCPrisonSpawns[rand][2], FREEZE_TIME);
					}
					case 3: {

						PlayerInfo[iTargetID][pRVehRestricted] = gettime() + 1814400;
						PlayerInfo[iTargetID][pRVehWarns] = 0;

						GetPlayerPos(iTargetID, fPlayerPos[0], fPlayerPos[1], fPlayerPos[2]);
						SetPlayerPosFindZ(iTargetID, fPlayerPos[0], fPlayerPos[1], fPlayerPos[2]);
						format(szMessage, sizeof szMessage, "%s canh bao ban vi lam dung xe %s cua to chuc.\n\nDay la lan thu ba, ban khong the dung xe han che trong ba tuan, bi loai khoi to chuc va cam hai ngay.", GetPlayerNameEx(playerid), GetVehicleName(iVehicleID));
						ShowPlayerDialogEx(iTargetID, 0, DIALOG_STYLE_MSGBOX, "Canh bao xe bi han che", szMessage, "Thoat", "");
						SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da canh cao nguoi nay vi lam dung xe bi han che.");

						new playerip[32];
						GetPlayerIp(iTargetID, playerip, sizeof(playerip));
						format(szMessage, sizeof(szMessage), "AdmCmd: %s(%d) (IP:%s) was banned by %s, reason: Abuse of faction vehicles", GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID), playerip, GetPlayerNameEx(playerid));
						Log("logs/ban.log", szMessage);
						SendClientMessageToAllEx(COLOR_LIGHTRED, "AdmCmd: %s da bi %s cam, ly do: Lam dung xe to chuc", GetPlayerNameEx(iTargetID), GetPlayerNameEx(playerid));
						PlayerInfo[iTargetID][pBanned] = 1;
						AddBan(playerid, iTargetID, "Lam dung xe to chuc.");
						SetTimerEx("KickEx", 1000, false, "i", iTargetID);
					}
				}
			}
			PlayerInfo[iTargetID][pLastRVehWarn] = gettime();
		}
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi do khong su dung xe han che.");
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}



alias:calculate("calc")
CMD:calculate(playerid, params[])
{
	new method[20], value1, value2;
	if(sscanf(params, "ds[20]d", value1, method, value2))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /calculate [value] [operation] [value].");
		SendClientMessageEx(playerid, COLOR_GRAD2, "Phep tinh: Add, Subtract, Multiply, Divide.");
		return 1;
	}

	if(strcmp(method,"multiply",true) == 0 || strcmp(method,"*",true) == 0)
	{
		new sum = value1*value2;
		SendClientMessageEx(playerid,COLOR_WHITE,"%s * %s = %s.", number_format(value1), number_format(value2), number_format(sum));
	}
	if(strcmp(method,"divide",true) == 0 || strcmp(method,"/",true) == 0)
	{
		if(value2 == 0)
		{
			SendClientMessageEx(playerid,COLOR_WHITE,"The gioi se no tung sau 10 giay, ban vua chia cho khong!");
			return 1;
		}
		new sum = value1/value2;
		SendClientMessageEx(playerid,COLOR_WHITE,"%s / %s = %s.", number_format(value1), number_format(value2), number_format(sum));
	}
	if(strcmp(method,"add",true) == 0 || strcmp(method,"+",true) == 0)
	{
		new sum = value1+value2;
		SendClientMessageEx(playerid,COLOR_WHITE,"%s + %s = %s.", number_format(value1), number_format(value2), number_format(sum));
	}
	if(strcmp(method,"subtract",true) == 0 || strcmp(method,"-",true) == 0)
	{
		new sum = value1-value2;
		SendClientMessageEx(playerid,COLOR_WHITE,"%s - %s = %s.", number_format(value1), number_format(value2), number_format(sum));
	}
	return 1;
}

CMD:suspend(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 1337 || PlayerInfo[playerid][pAP] >= 2 || PlayerInfo[playerid][pHR] >= 3 || PlayerInfo[playerid][pSecurity] >= 2)
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /suspend [player]");

		if(IsPlayerConnected(giveplayerid))
		{
			format(string, sizeof(string), "AdmCmd: %s(%d) has been suspended by %s.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid));
			Log("logs/admin.log", string);
			DBLog(playerid, giveplayerid, "Admin", "account suspended");
			format(string, sizeof(string), "AdmCmd: %s da bi %s dinh chi.", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid));
			ABroadCast(COLOR_LIGHTRED, string, 2);
			PlayerInfo[giveplayerid][pAdmin] = 0;
			PlayerInfo[giveplayerid][pHR] = 0;
			PlayerInfo[giveplayerid][pAP] = 0;
			PlayerInfo[giveplayerid][pPR] = 0;
			PlayerInfo[giveplayerid][pSecurity] = 0;
			PlayerInfo[giveplayerid][pShopTech] = 0;
			PlayerInfo[giveplayerid][pFactionModerator] = 0;
			PlayerInfo[giveplayerid][pGangModerator] = 0;
			PlayerInfo[giveplayerid][pUndercover] = 0;
			PlayerInfo[giveplayerid][pBanAppealer] = 0;
			PlayerInfo[giveplayerid][pLeader] = 0;
			PlayerInfo[giveplayerid][pMember] = 0;
			PlayerInfo[giveplayerid][pSecureIP][0] = 0;
			PlayerInfo[giveplayerid][pSMod] = 0;
			PlayerInfo[giveplayerid][pDonateRank] = 0;
			PlayerInfo[giveplayerid][pBanAppealer] = 0;
			PlayerInfo[giveplayerid][pShopTech] = 0;
			PlayerInfo[giveplayerid][pDisabled] = 1;
			Kick(giveplayerid);
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:osuspend(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 1337 || PlayerInfo[playerid][pAP] >= 2 || PlayerInfo[playerid][pHR] >= 3 || PlayerInfo[playerid][pSecurity] >= 2)
	{
		new query[512], tmpName[MAX_PLAYER_NAME];
		if(isnull(params)) return SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /osuspend [player name]");

		mysql_escape_string(params, tmpName);
		SetPVarString(playerid, "OnSetSuspended", tmpName);

		mysql_format(MainPipeline, query,sizeof(query),"UPDATE `accounts` SET `Disabled` = 1, `AdminLevel` = 0, `HR` = 0, `AP` = 0, `Security` = 0, `ShopTech` = 0, `FactionModerator` = 0, `GangModerator` = 0, \
		`Undercover` = 0, `BanAppealer` = 0, `Leader` = 0, `Member` = 0, `SecureIP` = '0.0.0.0', `SeniorModerator` = 0, `BanAppealer` = 0, `ShopTech` = 0 WHERE `Username`= '%s' AND `AdminLevel` < 1338 AND `AdminLevel` > 1", tmpName);
		mysql_tquery(MainPipeline, query, "OnSetSuspended", "ii", playerid, true);

		SendClientMessageEx(playerid, COLOR_YELLOW, "Dang dinh chi tai khoan %s.", tmpName);
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:prisonaccount(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 3)
	{
		new name[MAX_PLAYER_NAME], minutes, reason[64];
		if(sscanf(params, "s[24]ds[64]", name, minutes, reason)) return SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /prisonaccount [player name] [time (minutes)] [reason]");

        new giveplayerid = ReturnUser(name);
        if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pAdmin] >= PlayerInfo[playerid][pAdmin])
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay voi Admin ngang hoac cao cap hon.");
				return 1;
			}
			//if(strlen(reason) >= 25) return SendClientMessageEx(playerid, COLOR_WHITE, "Please provide a shorter reason. The maximum length for a prison reason is 25.");
		}
		else
		{
			new tmpName[24], tmpPrisonedBy[24], tmpPrisonReason[64], query[512];
			format(tmpPrisonReason, 64, "[OOC][PRISONACC] %s", reason);
			format(tmpPrisonedBy, 24, "%s", GetPlayerNameEx(playerid));
			mysql_escape_string(name, tmpName);
			mysql_escape_string(tmpPrisonReason, tmpPrisonReason);

			SetPVarString(playerid, "OnPrisonAccount", tmpName);
			SetPVarString(playerid, "OnPrisonAccountReason", tmpPrisonReason);

			SendClientMessageEx(playerid, COLOR_YELLOW, "Dang giam tai khoan %s trong %d phut...", tmpName, minutes);

			mysql_format(MainPipeline, query,sizeof(query),"UPDATE `accounts` SET `PrisonReason` = '%s', `PrisonedBy` = '%s', `JailTime` = %d WHERE `PermBand` < 3 AND `Band` < 1 AND `AdminLevel` < %d AND `Username` = '%s'", tmpPrisonReason, tmpPrisonedBy, minutes*60, PlayerInfo[playerid][pAdmin], tmpName);
			mysql_tquery(MainPipeline, query, "OnPrisonAccount", "i", playerid);
		}
	}
	return 1;
}

CMD:jailaccount(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 3)
	{
		new name[MAX_PLAYER_NAME], minutes, reason[64];
		if(sscanf(params, "s[24]ds[64]", name, minutes, reason)) return SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /jailaccount [player name] [time (minutes)] [reason]");

		new tmpName[24], tmpPrisonedBy[24], tmpPrisonReason[64], query[512];
		format(tmpPrisonReason, 64, "[OOC][JAILACC] %s", reason);
		format(tmpPrisonedBy, 24, "%s", GetPlayerNameEx(playerid));
		mysql_escape_string(name, tmpName);
		mysql_escape_string(tmpPrisonReason, tmpPrisonReason);

		SetPVarString(playerid, "OnJailAccount", tmpName);
		SetPVarString(playerid, "OnJailAccountReason", tmpPrisonReason);

		SendClientMessageEx(playerid, COLOR_YELLOW, "Dang giam tai khoan %s trong %d phut...", tmpName, minutes);

		mysql_format(MainPipeline, query,sizeof(query),"UPDATE `accounts` SET `PrisonReason` = '%s', `PrisonedBy` = '%s', `JailTime` = %d WHERE `PermBand` < 3 AND `Band` < 1 AND `AdminLevel` < %d AND `Username` = '%s'", tmpPrisonReason, tmpPrisonedBy, minutes*60, PlayerInfo[playerid][pAdmin], tmpName);
		mysql_tquery(MainPipeline, query, "OnJailAccount", "i", playerid);
	}
	return 1;
}

CMD:release(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 3 || PlayerInfo[playerid][pASM] >= 1)
	{
		new string[128], giveplayerid, reason[64];
		if(sscanf(params, "us[64]", giveplayerid, reason)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /release [player] [reason]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pJailTime] == 0)
			{
				SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi hien khong bi giam!");
			}
			else
			{
				format(string, sizeof(string), "AdmCmd: %s(%d) has been released from prison by %s, reason: %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), reason);
				Log("logs/admin.log", string);
				DBLog(playerid, giveplayerid, "Admin", "released from prison");
				SendClientMessageToAllEx(COLOR_LIGHTRED, "AdmCmd: %s da duoc %s tha tu, ly do: %s", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid), reason);
				PhoneOnline[giveplayerid] = 0;
				PlayerInfo[giveplayerid][pWantedLevel] = 0;
				Lawyer_ClearAppeal(giveplayerid);
				PlayerInfo[giveplayerid][pBeingSentenced] = 0;
				SetPlayerToTeamColor(giveplayerid);
				SetHealth(giveplayerid, 100);
				SetPlayerWantedLevel(giveplayerid, 0);
				PlayerInfo[giveplayerid][pJailTime] = 0;
				SetPlayerPos(giveplayerid, 1529.6,-1691.2,13.3);
				SetPlayerInterior(giveplayerid,0);
				PlayerInfo[giveplayerid][pInt] = 0;
				SetPlayerVirtualWorld(giveplayerid, 0);
				PlayerInfo[giveplayerid][pVW] = 0;
				strcpy(PlayerInfo[giveplayerid][pPrisonReason], "None", 128);
				SetPlayerToTeamColor(giveplayerid);
			}
		}
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:sprison(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pUndercover] >= 1 || PlayerInfo[playerid][pASM] >= 1)
	{
		new giveplayerid, minutes, reason[64];
		if(sscanf(params, "uds[64]", giveplayerid, minutes, reason)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /sprison [player] [minutes] [reason]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pAdmin] >= PlayerInfo[playerid][pAdmin]) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay voi Admin ngang hoac cao cap hon.");
			//if(strlen(reason) >= 25) return SendClientMessageEx(playerid, COLOR_WHITE, "Please provide a shorter reason. The maximum length for a prison reason is 25.");
			if(PrisonPlayer(playerid, giveplayerid, reason, minutes, .silent=1, .custom=1) == 0) return 1;
		}
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:jail(playerid, params[])
{
	new giveplayerid, minutes, reason[64];
	if(sscanf(params, "uds[64]", giveplayerid, minutes, reason)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /jail [player] [minutes] [reason]");

	if(minutes < 15 || minutes > 45) return SendClientMessageEx(playerid, COLOR_WHITE, "Thoi gian giam phai tu 15 den 45 phut.");
	if (PlayerInfo[playerid][pAdmin] >= 1)
	{
		if(PlayerInfo[playerid][pSMod] < 1 && PlayerInfo[playerid][pAdmin] == 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
		if(IsPlayerConnected(giveplayerid))
		{
			if((PlayerInfo[giveplayerid][pAdmin] >= PlayerInfo[playerid][pAdmin]) || (PlayerInfo[playerid][pAdmin] == 1 && (PlayerInfo[giveplayerid][pHelper] >= 2 || PlayerInfo[giveplayerid][pWatchdog] >= 2))) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay voi Admin ngang hoac cao cap hon.");
			if(PrisonPlayer(playerid, giveplayerid, reason, .time=minutes, .custom=1) == 0) return 1;
		}
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:setstat(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{

		new string[128], giveplayerid, statcode, amount;
		if(sscanf(params, "udd", giveplayerid, statcode, amount))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /setstat [player] [statcode] [amount]");
			SendClientMessageEx(playerid, COLOR_GRAD4, "|1 Level |2 ArmorUpgrade |3 UpgradePoints |4 Model |5 BankAccount |6 PhoneNumber |7 RespectPoints |8 House1 |9 House2 |10 House3");
			SendClientMessageEx(playerid, COLOR_GRAD2, "|11 Not Used |12 Det |13 Lawyer |14 Fixer |17 Drug |18 Sex |19 Box |20 Arms |21 Materials |22 Pot |23 Crack");
			SendClientMessageEx(playerid, COLOR_GRAD2, "|24 Fishing |25 Job |26 Rank |27 Packages |28 Crates |29 Smuggler |30 Insurance |31 Warnings |32 Screwdriver");
			SendClientMessageEx(playerid, COLOR_GRAD1, "|33 Age |34 Gender |35 NMute |36 AdMute |37 Faction |38 Restricted Weapon Time |39 Gang Warns |40 RMute |41 Reward Hours");
			SendClientMessageEx(playerid, COLOR_GRAD1, "|42 Playing Hours |43 Gold Box Tokens |44 Computer Drawings |45 Papers |46 Business |47 BusinessRank | 48 Spraycan");
			SendClientMessageEx(playerid, COLOR_GRAD1, "|49 Heroin |50 RawOpium |51 Syringes |52 Hunger |53 Fitness |54 Event Tokens |55 Modkit");
			SendClientMessageEx(playerid, COLOR_GRAD2, "|56 Car Jack Skill |57 Lock Pick Vehicle Count |58 Lock Pick Vehicle Time |59 Tool Box |60 Crowbar");
			return 1;
		}
		if(PlayerInfo[giveplayerid][pLevel] == 1 && PlayerInfo[giveplayerid][pAdmin] < 2) return SendClientMessageEx(playerid, COLOR_RED, "Khong the dung /setstat voi nguoi cap 1");
		if(IsPlayerConnected(giveplayerid))
		{
			switch (statcode)
			{
				case 1:
				{
					PlayerInfo[giveplayerid][pLevel] = amount;
					format(string, sizeof(string), "   %s(%d): Cap = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
					SetPlayerScore(giveplayerid, PlayerInfo[giveplayerid][pLevel]);
				}
				case 2:
				{
					PlayerInfo[giveplayerid][pSHealth] = amount;
					format(string, sizeof(string), "   %s(%d): Nang cap giap = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 3:
				{
					PlayerInfo[giveplayerid][gPupgrade] = amount;
					format(string, sizeof(string), "   %s(%d): Diem nang cap = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 4:
				{
					PlayerInfo[giveplayerid][pModel] = amount;
					format(string, sizeof(string), "   %s(%d): Model = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 5:
				{
					PlayerInfo[giveplayerid][pAccount] = amount;
					format(string, sizeof(string), "   %s(%d): Ngan hang = $%d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 6:
				{
					if(amount == 0)
					{
						PlayerInfo[giveplayerid][pPnumber] = amount;
						format(string, sizeof(string), "   Da thu dien thoai cua %s", GetPlayerNameEx(giveplayerid));
					}
					else
					{
						new query[128];
						SetPVarInt(giveplayerid, "WantedPh", amount);
						SetPVarInt(giveplayerid, "CurrentPh", PlayerInfo[giveplayerid][pPnumber]);
						SetPVarInt(giveplayerid, "PhChangeCost", 50000);
						SetPVarInt(giveplayerid, "PhChangerId", playerid);
						mysql_format(MainPipeline, query, sizeof(query), "SELECT `Username` FROM `accounts` WHERE `PhoneNr` = '%d'",amount);
						mysql_tquery(MainPipeline, query, "OnPhoneNumberCheck", "ii", giveplayerid, 4);
						return 1;
					}
				}
				case 7:
				{
					PlayerInfo[giveplayerid][pExp] = amount;
					format(string, sizeof(string), "   %s(%d): Diem kinh nghiem = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 8:
				{
					PlayerInfo[giveplayerid][pPhousekey] = amount;
					format(string, sizeof(string), "   %s(%d): Nha 1 = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 9:
				{
					PlayerInfo[giveplayerid][pPhousekey2] = amount;
					format(string, sizeof(string), "   %s(%d): Nha 2 = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 10:
				{
					PlayerInfo[giveplayerid][pPhousekey3] = amount;
					format(string, sizeof(string), "   %s(%d): Nha 3 = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 11:
				{
					return SendClientMessageEx(playerid, COLOR_WHITE, "He thong gia dinh da duoc gop vao he thong to chuc!");
				}
				case 12:
				{
					PlayerInfo[giveplayerid][pDetSkill] = amount;
					format(string, sizeof(string), "   %s(%d): Ky nang Detective = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 13:
				{
					PlayerInfo[giveplayerid][pLawSkill] = amount;
					format(string, sizeof(string), "   %s(%d): Ky nang Lawyer = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 14:
				{
					PlayerInfo[giveplayerid][pMechSkill] = amount;
					format(string, sizeof(string), "   %s(%d): Ky nang Car Mechanic = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 17:
				{
					return 1;
				}
				case 18:
				{
					PlayerInfo[giveplayerid][pSexSkill] = amount;
					format(string, sizeof(string), "   %s(%d): Ky nang tinh duc = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 19:
				{
					PlayerInfo[giveplayerid][pBoxSkill] = amount;
					format(string, sizeof(string), "   %s(%d): Ky nang Boxing = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 20:
				{
					PlayerInfo[giveplayerid][pArmsSkill] = amount;
					format(string, sizeof(string), "   %s(%d): Ky nang vu khi = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 21:
				{
					PlayerInfo[giveplayerid][pMats] = amount;
					format(string, sizeof(string), "   %s(%d): Vat lieu = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 22:
				{
					PlayerInfo[giveplayerid][pDrugs][0] = amount;
					format(string, sizeof(string), "   %s(%d): Can sa = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 23:
				{
					PlayerInfo[giveplayerid][pDrugs][1] = amount;
					format(string, sizeof(string), "   %s(%d): Crack = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 24:
				{
					PlayerInfo[playerid][pFishingSkill] = amount;
					format(string, sizeof(string), "   %s(%d): Ky nang Fishing = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 25:
				{
					if(!Job_SetPlayerSlot(giveplayerid, 1, amount)) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the doi cong viec nay. Kiem tra loai cong viec, o cong viec hien co va cuoc xe chua thanh toan.");
					format(string, sizeof(string), "   %s(%d): Cong viec = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 26:
				{
					PlayerInfo[giveplayerid][pRank] = amount;
					format(string, sizeof(string), "   %s(%d): Cap bac = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 27:
				{
					SetPVarInt(giveplayerid, "Packages", amount);
					format(string, sizeof(string), "   %s(%d): Goi vat lieu = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 28:
				{
					PlayerInfo[giveplayerid][pCrates] = amount;
					format(string, sizeof(string), "   %s(%d): Thung hang cam = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 29:
				{
					PlayerInfo[giveplayerid][pDrugSmuggler] = amount;
					format(string, sizeof(string), "   %s(%d): Ky nang Smuggler = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 30:
				{
					PlayerInfo[giveplayerid][pInsurance] = amount;
					format(string, sizeof(string), "   %s(%d): Bao hiem = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 31:
				{
					PlayerInfo[giveplayerid][pWarns] = amount;
					format(string, sizeof(string), "   %s(%d): Canh bao = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 32:
				{
					PlayerInfo[giveplayerid][pScrewdriver] = amount;
					format(string, sizeof(string), "   %s(%d): Tua vit = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				/*case 33:
				{
					PlayerInfo[giveplayerid][pBirthDate] = amount;
					format(string, sizeof(string), "   %s's(%d) Age has been set to %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}*/
				case 34:
				{
					PlayerInfo[giveplayerid][pSex] = amount;
					format(string, sizeof(string), "   %s(%d): Gioi tinh = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 35:
				{
					PlayerInfo[giveplayerid][pNMuteTotal] = amount;
					format(string, sizeof(string), "   %s(%d): Tong lan cam chat Newbie = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 36:
				{
					PlayerInfo[giveplayerid][pADMuteTotal] = amount;
					format(string, sizeof(string), "   %s(%d): Tong lan cam quang cao = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 37:
				{
					PlayerInfo[giveplayerid][pMember] = amount;
					format(string, sizeof(string), "   %s(%d): To chuc = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 38:
				{
					if(PlayerInfo[giveplayerid][pConnectHours] >= 2) {
						PlayerInfo[giveplayerid][pWRestricted] = amount;
						if(amount) ResetPlayerWeaponsEx(giveplayerid);
						format(string, sizeof(string), "   %s(%d): Thoi gian cam vu khi = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
					}
					else {
						return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dat cho nguoi choi duoi 2 gio choi.");
					}
				}
				case 39:
				{
					PlayerInfo[giveplayerid][pGangWarn] = amount;
					format(string, sizeof(string), "   %s(%d): Canh bao bang dang = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 40:
				{
					PlayerInfo[giveplayerid][pRMutedTotal] = amount;
					format(string, sizeof(string), "   %s(%d): Cam gui bao cao = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 41:
				{
					PlayerInfo[giveplayerid][pRewardHours] = amount;
					format(string, sizeof(string), "   %s(%d): Gio choi nhan thuong = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 42:
				{
					PlayerInfo[giveplayerid][pConnectHours] = amount;
					format(string, sizeof(string), "   %s(%d): Gio choi = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 43:
				{
					PlayerInfo[giveplayerid][pGoldBoxTokens] = amount;
					format(string, sizeof(string), "   %s(%d): Box Token = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 44:
				{
					PlayerInfo[giveplayerid][pRewardDrawChance] = amount;
					format(string, sizeof(string), "   %s(%d): Ban ve may tinh = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 45:
				{
					PlayerInfo[giveplayerid][pPaper] = amount;
					format(string, sizeof(string), "   %s(%d): Giay = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 46:
				{
				    if (amount < 0 || amount >= MAX_BUSINESSES) return 1;
					PlayerInfo[giveplayerid][pBusiness] = amount;
					format(string, sizeof(string), "   %s(%d): Business = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 47:
				{
				    if (amount < 0 || amount > 5) return 1;
					PlayerInfo[giveplayerid][pBusinessRank] = amount;
					format(string, sizeof(string), "   %s(%d): Cap bac Business = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 48:
				{
                	PlayerInfo[giveplayerid][pSpraycan] = amount;
					format(string, sizeof(string), "   %s(%d): Binh son = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 49:
			    {
			        PlayerInfo[giveplayerid][pHeroin] = amount;
			        format(string, sizeof(string), "   %s(%d): Heroin = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
			    }
				case 50:
				{
                	PlayerInfo[giveplayerid][pRawOpium] = amount;
					format(string, sizeof(string), "   %s(%d): Thuoc phien tho = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 51:
				{
                	PlayerInfo[giveplayerid][pSyringes] = amount;
					format(string, sizeof(string), "   %s(%d): Ong tiem = %d.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}

				case 52:
				{
					return 1;
				}

				case 53:
				{
					return 1;
				}

				case 54:
				{
					PlayerInfo[giveplayerid][pEventTokens] = amount;
					format(string, sizeof(string), "   %s(%d): Event Token = %i.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 55:
				{
					PlayerInfo[giveplayerid][pRimMod] = amount;
					format(string, sizeof(string), "   %s(%d): Bo do mam = %i.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 56:
				{
					PlayerInfo[giveplayerid][pCarLockPickSkill] = amount;
					format(string, sizeof(string), "   %s(%d): Ky nang pha khoa xe = %i.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 57:
				{
					PlayerInfo[giveplayerid][pLockPickVehCount] = amount;
					format(string, sizeof(string), "   %s(%d): So lan pha khoa xe = %i.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 58:
				{
					PlayerInfo[giveplayerid][pLockPickTime] = amount;
					format(string, sizeof(string), "   %s(%d): Thoi gian pha khoa xe = %i.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 59:
				{
					PlayerInfo[giveplayerid][pToolBox] = amount;
					format(string, sizeof(string), "   %s(%d): Luot dung hop dung cu = %i.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}
				case 60:
				{
					PlayerInfo[giveplayerid][pCrowBar] = amount;
					format(string, sizeof(string), "   %s(%d): Luot dung xa beng = %i.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), amount);
				}

				default:
				{
					format(string, sizeof(string), "   Ma chi so khong hop le.", amount);
				}
			}
			format(string, sizeof(string), "%s by %s", string, GetPlayerNameEx(playerid));
			Log("logs/stats.log", string);
			SendClientMessageEx(playerid, COLOR_GRAD1, string);
		}
		else return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
	}
	return 1;
}

CMD:setmystat(playerid, params[])
{
	if(PlayerInfo[playerid][pUndercover] >= 1 || PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		new string[128], statcode, amount;
		if(sscanf(params, "dd", statcode, amount))
		{

			if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1) {
				SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /setmystat [statcode] [amount]");
				SendClientMessageEx(playerid, COLOR_GRAD4, "|1 Level |2 ArmorUpgrade |3 UpgradePoints |4 Model |5 BankAccount |6 PhoneNumber |7 RespectPoints |8 House1 |9 House2 |10 House3");
				SendClientMessageEx(playerid, COLOR_GRAD2, "|11 Not Used |12 Det |13 Lawyer |14 Fixer |17 Drug |18 Sex |19 Box |20 Arms |21 Materials |22 Cannabis |23 Crack");
				SendClientMessageEx(playerid, COLOR_GRAD2, "|24 Fishing |25 Job |26 Rank |27 Packages |28 Crates |29 Smuggler |30 Insurance |31 Warnings |32 Screwdriver");
				SendClientMessageEx(playerid, COLOR_GRAD1, "|33 Age |34 Gender |35 NMute |36 AdMute |37 Faction |38 Restricted Weapon Time |39 Gang Warns |40 RMute |41 Reward Hours");
				SendClientMessageEx(playerid, COLOR_GRAD1, "|42 Playing Hours |43 Gold Box Tokens |44 Computer Drawings |45 Papers |46 Business |47 BusinessRank | 48 Spraycan");
				SendClientMessageEx(playerid, COLOR_GRAD1, "|49 Heroin |50 RawOpium |51 Syringes |52 Hunger |53 Fitness |54 Event Tokens |55 Modkit");
				SendClientMessageEx(playerid, COLOR_GRAD2, "|56 Car Lock Pick Skill |57 Lock Pick Vehicle Count |58 Lock Pick Vehicle Time");
				return 1;
			}
			else if (PlayerInfo[playerid][pUndercover] >= 1) {
				SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /setmystat [statcode] [amount]");
				SendClientMessageEx(playerid, COLOR_GRAD4, "|1 Level |6 PhoneNumber |26 Rank |33 Age |34 Gender |37 Faction ");
				return 1;
			}

		}

		if((PlayerInfo[playerid][pUndercover] >= 1 && PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) && statcode != 1 && statcode != 6 && statcode != 26 && statcode != 33
				&& statcode != 34 && statcode != 37 && statcode != 52) return 1;

		switch (statcode)
		{
		case 1:
			{
				PlayerInfo[playerid][pLevel] = amount;
				format(string, sizeof(string), "   %s: Cap = %d.", GetPlayerNameEx(playerid), amount);
				SetPlayerScore(playerid, PlayerInfo[playerid][pLevel]);
			}
		case 2:
			{
				PlayerInfo[playerid][pSHealth] = amount;
				format(string, sizeof(string), "   %s: Nang cap giap = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 3:
			{
				PlayerInfo[playerid][gPupgrade] = amount;
				format(string, sizeof(string), "   %s: Diem nang cap = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 4:
			{
				PlayerInfo[playerid][pModel] = amount;
				format(string, sizeof(string), "   %s: Model = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 5:
			{
				PlayerInfo[playerid][pAccount] = amount;
				format(string, sizeof(string), "   %s: Ngan hang = $%d.", GetPlayerNameEx(playerid), amount);
			}
		case 6:
			{
				if(amount == 0)
				{
					PlayerInfo[playerid][pPnumber] = amount;
					format(string, sizeof(string), "   Da thu dien thoai cua %s", GetPlayerNameEx(playerid));
				}
				else
				{
					new query[128];
					SetPVarInt(playerid, "WantedPh", amount);
					SetPVarInt(playerid, "CurrentPh", PlayerInfo[playerid][pPnumber]);
					SetPVarInt(playerid, "PhChangeCost", 50000);
					SetPVarInt(playerid, "PhChangerId", playerid);
					mysql_format(MainPipeline, query, sizeof(query), "SELECT `Username` FROM `accounts` WHERE `PhoneNr` = '%d'",amount);
					mysql_tquery(MainPipeline, query, "OnPhoneNumberCheck", "ii", playerid, 4);
					return 1;
				}
			}
		case 7:
			{
				PlayerInfo[playerid][pExp] = amount;
				format(string, sizeof(string), "   %s: Diem kinh nghiem = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 8:
			{
				PlayerInfo[playerid][pPhousekey] = amount;
				format(string, sizeof(string), "   %s: Nha 1 = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 9:
			{
				PlayerInfo[playerid][pPhousekey2] = amount;
				format(string, sizeof(string), "   %s: Nha 2 = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 10:
			{
				PlayerInfo[playerid][pPhousekey3] = amount;
				format(string, sizeof(string), "   %s: Nha 3 = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 11:
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "He thong gia dinh da duoc gop vao he thong to chuc!");
			}
		case 12:
			{
				PlayerInfo[playerid][pDetSkill] = amount;
				format(string, sizeof(string), "   %s: Ky nang Detective = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 13:
			{
				PlayerInfo[playerid][pLawSkill] = amount;
				format(string, sizeof(string), "   %s: Ky nang Lawyer = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 14:
			{
				PlayerInfo[playerid][pMechSkill] = amount;
				format(string, sizeof(string), "   %s: Ky nang Car Mechanic = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 17:
			{
				PlayerInfo[playerid][pDrugSmuggler] = amount;
				format(string, sizeof(string), "   %s: Ky nang Drug Smuggler = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 18:
			{
				PlayerInfo[playerid][pSexSkill] = amount;
				format(string, sizeof(string), "   %s: Ky nang tinh duc = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 19:
			{
				PlayerInfo[playerid][pBoxSkill] = amount;
				format(string, sizeof(string), "   %s: Ky nang Boxing = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 20:
			{
				PlayerInfo[playerid][pArmsSkill] = amount;
				format(string, sizeof(string), "   %s: Ky nang vu khi = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 21:
			{
				PlayerInfo[playerid][pMats] = amount;
				format(string, sizeof(string), "   %s: Vat lieu = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 22:
			{
				PlayerInfo[playerid][pDrugs][0] = amount;
				format(string, sizeof(string), "   %s: Can sa = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 23:
			{
				PlayerInfo[playerid][pDrugs][1] = amount;
				format(string, sizeof(string), "   %s: Crack = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 24:
			{
				PlayerInfo[playerid][pFishingSkill] = amount;
				format(string, sizeof(string), "   %s: Ky nang Fishing = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 25:
			{
				if(!Job_SetPlayerSlot(playerid, 1, amount)) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the doi cong viec nay. Kiem tra loai cong viec, o cong viec hien co va cuoc xe chua thanh toan.");
				format(string, sizeof(string), "   %s: Cong viec = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 26:
			{
				PlayerInfo[playerid][pRank] = amount;
				format(string, sizeof(string), "   %s: Cap bac = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 27:
			{
				SetPVarInt(playerid, "Packages", amount);
				format(string, sizeof(string), "   %s: Goi vat lieu = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 28:
			{
				PlayerInfo[playerid][pCrates] = amount;
				format(string, sizeof(string), "   %s: Thung hang cam = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 29:
			{
				PlayerInfo[playerid][pDrugSmuggler] = amount;
				format(string, sizeof(string), "   %s: Ky nang Smuggler = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 30:
			{
				PlayerInfo[playerid][pInsurance] = amount;
				format(string, sizeof(string), "   %s: Bao hiem = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 31:
			{
				PlayerInfo[playerid][pWarns] = amount;
				format(string, sizeof(string), "   %s: Canh bao = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 32:
			{
				PlayerInfo[playerid][pScrewdriver] = amount;
				format(string, sizeof(string), "   %s: Tua vit = %d.", GetPlayerNameEx(playerid), amount);
			}
		/*case 33:
			{
				PlayerInfo[playerid][pBirthDate] = amount;
				format(string, sizeof(string), "   %s's Age has been set to %d.", GetPlayerNameEx(playerid), amount);
			}*/
		case 34:
			{
				PlayerInfo[playerid][pSex] = amount;
				format(string, sizeof(string), "   %s: Gioi tinh = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 35:
			{
				PlayerInfo[playerid][pNMuteTotal] = amount;
				format(string, sizeof(string), "   %s: Tong lan cam chat Newbie = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 36:
			{
				PlayerInfo[playerid][pADMuteTotal] = amount;
				format(string, sizeof(string), "   %s: Tong lan cam quang cao = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 37:
			{
				PlayerInfo[playerid][pMember] = amount;
				format(string, sizeof(string), "   %s: To chuc = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 38:
			{
				if(PlayerInfo[playerid][pConnectHours] >= 2) {
					PlayerInfo[playerid][pWRestricted] = amount;
					format(string, sizeof(string), "   %s: Thoi gian cam vu khi = %d.", GetPlayerNameEx(playerid), amount);
				}
				else {
					return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dat cho nguoi choi duoi 2 gio choi.");
				}
			}
		case 39:
			{
				PlayerInfo[playerid][pGangWarn] = amount;
				format(string, sizeof(string), "   %s: Canh bao bang dang = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 40:
			{
				PlayerInfo[playerid][pRMutedTotal] = amount;
				format(string, sizeof(string), "   %s: Cam gui bao cao = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 41:
			{
				PlayerInfo[playerid][pRewardHours] = amount;
				format(string, sizeof(string), "   %s: Gio choi nhan thuong = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 42:
			{
				PlayerInfo[playerid][pConnectHours] = amount;
				format(string, sizeof(string), "   %s: Gio choi = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 43:
			{
				PlayerInfo[playerid][pGoldBoxTokens] = amount;
				format(string, sizeof(string), "   %s: Box Token = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 44:
			{
				PlayerInfo[playerid][pRewardDrawChance] = amount;
				format(string, sizeof(string), "   %s: Ban ve may tinh = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 45:
			{
				PlayerInfo[playerid][pPaper] = amount;
				format(string, sizeof(string), "   %s: Giay = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 46:
			{
				if (amount < 0 || amount >= MAX_BUSINESSES) return 1;
				PlayerInfo[playerid][pBusiness] = amount;
				format(string, sizeof(string), "   %s: Business = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 47:
			{
				if (amount < 0 || amount > 5) return 1;
				PlayerInfo[playerid][pBusinessRank] = amount;
				format(string, sizeof(string), "   %s: Cap bac Business = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 48:
			{
				PlayerInfo[playerid][pSpraycan] = amount;
				format(string, sizeof(string), "   %s: Binh son = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 49:
			{
				PlayerInfo[playerid][pHeroin] = amount;
				format(string, sizeof(string), "   %s: Heroin = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 50:
			{
				PlayerInfo[playerid][pRawOpium] = amount;
				format(string, sizeof(string), "   %s: Thuoc phien tho = %d.", GetPlayerNameEx(playerid), amount);
			}
		case 51:
			{
				PlayerInfo[playerid][pSyringes] = amount;
				format(string, sizeof(string), "   %s: Ong tiem = %d.", GetPlayerNameEx(playerid), amount);
			}

		case 52:
			{
				return 1;
			}

		case 53:
			{
				return 1;
			}

		case 54:
			{
				PlayerInfo[playerid][pEventTokens] = amount;
				format(string, sizeof(string), "   %s: Event Token = %i.", GetPlayerNameEx(playerid), amount);
			}
		case 55:
			{
				PlayerInfo[playerid][pRimMod] = amount;
				format(string, sizeof(string), "   %s: Bo do mam = %i.", GetPlayerNameEx(playerid), amount);
			}
		case 56:
			{
				PlayerInfo[playerid][pCarLockPickSkill] = amount;
				format(string, sizeof(string), "   %s: Ky nang pha khoa xe = %i.", GetPlayerNameEx(playerid), amount);
			}
		case 57:
			{
				PlayerInfo[playerid][pLockPickVehCount] = amount;
				format(string, sizeof(string), "   %s: So lan pha khoa xe = %i.", GetPlayerNameEx(playerid), amount);
			}
		case 58:
			{
				PlayerInfo[playerid][pLockPickTime] = amount;
				format(string, sizeof(string), "   %s: Thoi gian pha khoa xe = %i.", GetPlayerNameEx(playerid), amount);
			}
		case 59:
			{
				PlayerInfo[playerid][pToolBox] = amount;
				format(string, sizeof(string), "   %s: Luot dung hop dung cu = %i.", GetPlayerNameEx(playerid), amount);
			}
		case 60:
			{
				PlayerInfo[playerid][pCrowBar] = amount;
				format(string, sizeof(string), "   %s: Luot dung xa beng = %i.", GetPlayerNameEx(playerid), amount);
			}

		default:
			{
				format(string, sizeof(string), "   Ma chi so khong hop le.", amount);
			}
		}

		format(string, sizeof(string), "%s by %s", string, GetPlayerNameEx(playerid));
		Log("logs/undercover.log", string);
		SendClientMessageEx(playerid, COLOR_GRAD1, string);
	}
	return 1;
}

CMD:setvw(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	new giveplayerid, vw;
	if(sscanf(params, "ud", giveplayerid, vw)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /setvw [player] [virtual world]");
	if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
	new string[128];
	if(GetPVarType(giveplayerid, "IsInArena"))
	{
		SetPVarInt(playerid, "tempPBP", giveplayerid);
		format(string, sizeof(string), "%s (ID: %d) dang choi Paintball.\n\nBan muon dua nguoi nay ra ngoai khong?", GetPlayerNameEx(giveplayerid), giveplayerid);
		ShowPlayerDialogEx(playerid, PBFORCE, DIALOG_STYLE_MSGBOX, "Paintball", string, "Co", "Khong");
		return 1;
	}
	PlayerInfo[giveplayerid][pVW] =  vw;
	SetPlayerVirtualWorld(giveplayerid,  vw);
	SendClientMessageEx(playerid, COLOR_GRAD2, "Da dat VW cua %s thanh %d.", GetPlayerNameEx(giveplayerid),  vw);
	return 1;
}

CMD:setint(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] < 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	new giveplayerid, int;
	if(sscanf(params, "ud", giveplayerid, int)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /setint [player] [interiorid]");
	if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
	PlayerInfo[giveplayerid][pInt] = int;
	SetPlayerInterior(giveplayerid, int);
	SendClientMessageEx(playerid, COLOR_GRAD2, "Da dat noi that cua %s thanh %d.", GetPlayerNameEx(giveplayerid), int);
	return 1;
}

CMD:setskin(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 3)
	{
		new giveplayerid, skinid;
		if(sscanf(params, "ud", giveplayerid, skinid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /setskin [player] [skinid]");

		if(IsPlayerConnected(giveplayerid))
		{
			if((PlayerInfo[giveplayerid][pAdmin] >= PlayerInfo[playerid][pAdmin]) && giveplayerid != playerid) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung lenh voi Admin ngang hoac cao cap hon!");
			if(!IsInvalidSkin(skinid))
			{
				if(GetPlayerSkin(giveplayerid) == skinid)
				{
					SendClientMessageEx( playerid, COLOR_WHITE, "Nguoi choi da dung skin ban muon dat." );
				}
				else
				{
					PlayerInfo[giveplayerid][pModel] = skinid;
					SendClientMessageEx(giveplayerid, COLOR_WHITE, "Skin cua ban duoc doi thanh ID %d boi Admin %s.", skinid, GetPlayerNameEx(playerid));
					SendClientMessageEx(playerid, COLOR_WHITE, "Da cap cho %s skin ID %d.", GetPlayerNameEx(giveplayerid), skinid);
					SetPlayerSkin(giveplayerid, PlayerInfo[giveplayerid][pModel]);
					format(szMiscArray, sizeof(szMiscArray), "Skin changed %d", skinid);
					DBLog(playerid, giveplayerid, "Admin", szMiscArray);
				}
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "ID skin khong hop le!");
			}
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:entercar(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 3)
	{
		new carid, seatid;
		if(sscanf(params, "ii", carid, seatid))	return SendClientMessage(playerid, COLOR_WHITE, "CACH DUNG: /entercar [carid] [seatid]");
		if(!(1 <= carid <= MAX_VEHICLES)) return SendClientMessageEx(playerid, COLOR_GREY, "ID xe hop le tu 1 den 2000.");
		if(seatid < 0 || seatid > 3) return SendClientMessageEx(playerid, COLOR_GREY, "ID ghe khong hop le!");
		else if(!IsVehicleSeatOccupied(carid, seatid)) IsPlayerEntering{playerid} = true, PutPlayerInVehicle(playerid, carid, seatid), SendClientMessageEx(playerid, COLOR_GRAD1, "   Ban da duoc dich chuyen!");
		else SendClientMessageEx(playerid, COLOR_GREY, "Ghe da co nguoi ngoi.");
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:gotocar(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 2)
	{
		new carid;
		if(sscanf(params, "d", carid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /gotocar [carid]");

		new Float:cwx2,Float:cwy2,Float:cwz2;
		GetVehiclePos(carid, cwx2, cwy2, cwz2);
		if (GetPlayerState(playerid) == 2)
		{
			new tmpcar = GetPlayerVehicleID(playerid);
			SetVehiclePos(tmpcar, cwx2, cwy2, cwz2);
			fVehSpeed[playerid] = 0.0;
		}
		else
		{
			SetPlayerPos(playerid, cwx2, cwy2, cwz2);
		}
		
		SendClientMessageEx(playerid, COLOR_GRAD1, "   Da dich chuyen den xe ID %d (%s)", carid, GetVehicleName(carid));
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, GetVehicleVirtualWorld(carid));
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:gotoid(playerid, params[])
{
	new giveplayerid;
	if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /gotoid [player]");

	new Float:plocx,Float:plocy,Float:plocz;
	if (IsPlayerConnected(giveplayerid))
	{
		if (PlayerInfo[playerid][pAdmin] >= 2)
		{
			if(GetPlayerState(giveplayerid) == PLAYER_STATE_SPECTATING)
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do dang theo doi nguoi khac.");
				return 1;
			}
			if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the lam vay khi dang theo doi.");
				return 1;
			}
			if(PlayerInfo[giveplayerid][pAdmin] >= 1337 && !GetPVarType(giveplayerid, "EATeleportable")) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the dich chuyen den nguoi do");
			GetPlayerPos(giveplayerid, plocx, plocy, plocz);
			SetPlayerVirtualWorld(playerid, PlayerInfo[giveplayerid][pVW]);
			Streamer_UpdateEx(playerid, plocx, plocy, plocz);

			if (GetPlayerState(playerid) == 2)
			{
				new tmpcar = GetPlayerVehicleID(playerid);
				SetVehiclePos(tmpcar, plocx, plocy+4, plocz);
				fVehSpeed[playerid] = 0.0;
			}
			else
			{
				SetPlayerPos(playerid,plocx,plocy+2, plocz);
				SetPlayerInterior(playerid, GetPlayerInterior(giveplayerid));
				SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(giveplayerid));
			}

			SendClientMessageEx(playerid, COLOR_GRAD1, "   Ban da duoc dich chuyen!");
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
		}

	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	return 1;
}

CMD:sendtoid(playerid, params[])
{
	new string[128];
	new giveplayerid;
	new targetplayerid;
	if(sscanf(params, "uu", giveplayerid, targetplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /sendtoid [player] [target player]");

	new Float:plocx,Float:plocy,Float:plocz;

	if(IsPlayerConnected(giveplayerid) && IsPlayerConnected(targetplayerid))
	{
		if (PlayerInfo[playerid][pAdmin] >= 2)
		{
			if(GetPlayerState(giveplayerid) == PLAYER_STATE_SPECTATING || GetPlayerState(targetplayerid) == PLAYER_STATE_SPECTATING)
			{
				return SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do dang theo doi nguoi khac.");
			}
			if(giveplayerid == playerid)
			{
				return SendClientMessageEx(playerid, COLOR_GRAD2, "Hay dung /gotoid de dich chuyen!");
			}
			if(targetplayerid == playerid)
			{
				return SendClientMessageEx(playerid, COLOR_GRAD2, "Hay dung /gethere de dich chuyen!");
			}
			if(PlayerInfo[targetplayerid][pAdmin] >= PlayerInfo[playerid][pAdmin])
			{
				return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the dung lenh voi Admin ngang hoac cao cap hon.");
			}
			if(GetPVarType(giveplayerid, "IsInArena"))
			{
			    SetPVarInt(playerid, "tempPBP", giveplayerid);
			    format(string, sizeof(string), "%s (ID: %d) dang choi Paintball.\n\nBan muon dua nguoi nay ra ngoai khong?", GetPlayerNameEx(giveplayerid), giveplayerid);
			    return ShowPlayerDialogEx(playerid, PBFORCE, DIALOG_STYLE_MSGBOX, "Paintball", string, "Co", "Khong");
			}
			if(PlayerInfo[giveplayerid][pAdmin] == 99999 && !GetPVarType(giveplayerid, "EATeleportable")) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the dich chuyen nguoi do");
			if(PlayerInfo[targetplayerid][pAdmin] == 99999 && !GetPVarType(targetplayerid, "EATeleportable")) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the dich chuyen den nguoi do");
			GetPlayerPos(targetplayerid, plocx, plocy, plocz);
			SetPlayerVirtualWorld(giveplayerid, PlayerInfo[targetplayerid][pVW]);
			Streamer_UpdateEx(giveplayerid, plocx, plocy, plocz);
			DeletePVar(giveplayerid, "BusinessesID");
			if (GetPlayerState(giveplayerid) == 2)
			{
				new tmpcar = GetPlayerVehicleID(giveplayerid);
				SetVehiclePos(tmpcar, plocx, plocy+4, plocz);
				fVehSpeed[giveplayerid] = 0.0;
			}
			else
			{
				SetPlayerPos(giveplayerid,plocx,plocy+2, plocz);
				SetPlayerInterior(giveplayerid, GetPlayerInterior(targetplayerid));
				SetPlayerVirtualWorld(giveplayerid, GetPlayerVirtualWorld(targetplayerid));
			}

			SendClientMessageEx(giveplayerid, COLOR_GRAD1, "Ban da duoc dich chuyen den %s", GetPlayerNameEx(targetplayerid));
			SendClientMessageEx(playerid, COLOR_GRAD1, "Da dich chuyen %s den %s", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(targetplayerid));
		}
		else
		{
			return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
		}

	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	return 1;
}

CMD:gethere(playerid, params[])
{
	new giveplayerid;
	if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /gethere [player]");

	new Float:plocx,Float:plocy,Float:plocz;
	if (IsPlayerConnected(giveplayerid))
	{
		if (PlayerInfo[playerid][pAdmin] >= 2)
		{
			if(PlayerInfo[giveplayerid][pAdmin] >= PlayerInfo[playerid][pAdmin])
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay voi Admin ngang hoac cao cap hon.");
				return 1;
			}
			if(GetPlayerState(giveplayerid) == PLAYER_STATE_SPECTATING)
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do dang theo doi nguoi khac.");
				return 1;
			}
			if(GetPVarType(giveplayerid, "IsInArena"))
			{
			    new string[128];
			    SetPVarInt(playerid, "tempPBP", giveplayerid);
			    format(string, sizeof(string), "%s (ID: %d) dang choi Paintball.\n\nBan muon dua nguoi nay ra ngoai khong?", GetPlayerNameEx(giveplayerid), giveplayerid);
			    ShowPlayerDialogEx(playerid, PBFORCE, DIALOG_STYLE_MSGBOX, "Paintball", string, "Co", "Khong");
			    return 1;
			}
			Furniture_ResetPVars(playerid);
			GetPlayerPos(playerid, plocx, plocy, plocz);
			SetPlayerVirtualWorld(giveplayerid, PlayerInfo[playerid][pVW]);
			Streamer_UpdateEx(giveplayerid, plocx, plocy, plocz);
			DeletePVar(giveplayerid, "BusinessesID");
			if (GetPlayerState(giveplayerid) == 2)
			{
				fVehSpeed[giveplayerid] = 0.0;
				new tmpcar = GetPlayerVehicleID(giveplayerid);
				SetVehiclePos(tmpcar, plocx, plocy+4, plocz);
				LinkVehicleToInterior(GetPlayerVehicleID(giveplayerid), GetPlayerInterior(playerid));
				SetPlayerInterior(giveplayerid, GetPlayerInterior(playerid));
				SetVehicleVirtualWorld(GetPlayerVehicleID(giveplayerid), GetPlayerVirtualWorld(playerid));
				SetPlayerVirtualWorld(giveplayerid, GetPlayerVirtualWorld(playerid));
				if(IsValidDynamicArea(iVehEnterAreaID[tmpcar])) {
					// Streamer_SetIntData(STREAMER_TYPE_AREA, iVehEnterAreaID[tmpcar], E_STREAMER_WORLD_ID, tmpcar);
				}
			}
			else
			{
				SetPlayerPos(giveplayerid,plocx,plocy+2, plocz);
				SetPlayerInterior(giveplayerid, GetPlayerInterior(playerid));
				SetPlayerVirtualWorld(giveplayerid, GetPlayerVirtualWorld(playerid));
			}

			SendClientMessageEx(giveplayerid, COLOR_GRAD1, "   Ban da duoc dich chuyen!");
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
		}

	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	return 1;
}

CMD:getcar(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 2)
	{
		new carid;
		if(sscanf(params, "d", carid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /getcar [carid]");
		new Float:plocx,Float:plocy,Float:plocz;

		GetPlayerPos(playerid, plocx, plocy, plocz);
		SetVehiclePos(carid,plocx,plocy+4, plocz);
		SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid));
		LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
		if(IsValidDynamicArea(iVehEnterAreaID[carid])) {
			// Streamer_SetIntData(STREAMER_TYPE_AREA, iVehEnterAreaID[carid], E_STREAMER_WORLD_ID, carid);
		}

	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:respawncars(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 3)
	{
		new radius;
		if(sscanf(params, "d", radius)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /respawncars [radius]");

		if(radius < 1 || radius > 40)
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban kinh phai lon hon 0 va nho hon 41!");
			return 1;
		}
		RespawnNearbyVehicles(playerid, radius);
		SendClientMessageEx(playerid, COLOR_GREY, "Da tao lai tat ca xe trong ban kinh %d.", radius);
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:respawncar(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 2)
	{
		new carid;
		if(sscanf(params, "d", carid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /respawncar [carid]");

		SetVehicleToRespawn(carid);
		SendClientMessageEx(playerid, COLOR_GREY, "Da tao lai xe ID %d.", carid);
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:takeadminweapons(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 3)
	{
		new giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /takeadminweapons [player]");

		if(IsPlayerConnected(giveplayerid))
		{
			for(new s = 0; s < 12; s++)
			{
				if(PlayerInfo[giveplayerid][pAGuns][s] != 0)
				{
					RemovePlayerLoadoutWeapon(giveplayerid, PlayerInfo[giveplayerid][pAGuns][s]);
				}
			}
			SendClientMessageEx(playerid, COLOR_WHITE, "Da thu hoi vu khi do Admin cap cho %s.", GetPlayerNameEx(giveplayerid));
		}
	}
	return 1;
}

CMD:gotoco(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 3)
	{
		new Float: pos[3], int, vw;
		if(sscanf(params, "p<,>fffD(0)D(0)", pos[0], pos[1], pos[2], int, vw)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /gotoco [x coordinate] [y coordinate] [z coordinate] [interior] [vw]");

		SendClientMessageEx(playerid, COLOR_GRAD2, "Da dich chuyen den toa do chi dinh.");
		SetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		SetPlayerInterior(playerid, int);
		SetPlayerVirtualWorld(playerid, vw);
	}
	return 1;
}

CMD:setweather(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1)
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
		return 1;
	}

	new weather;
	if(sscanf(params, "d", weather)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /setweather [weatherid]");

	if(weather < 0||weather > 45) { SendClientMessageEx(playerid, COLOR_GREY, "   ID thoi tiet phai tu 0 den 45!"); return 1; }
	SetWeather(weather);
	gWeather = weather;
	SendClientMessageEx(playerid, COLOR_GREY, "Da dat thoi tiet cho moi nguoi!");
	return 1;
}

CMD:setmoney(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		new string[128], giveplayerid, money;
		if(sscanf(params, "ud", giveplayerid, money)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /setmoney [player] [money]");
		if(PlayerInfo[giveplayerid][pLevel] == 1 && PlayerInfo[giveplayerid][pAdmin] < 2) return SendClientMessageEx(playerid, COLOR_RED, "Khong the dung /setmoney voi nguoi cap 1");
		if(IsPlayerConnected(giveplayerid))
		{
			ResetPlayerCash(giveplayerid);
			GivePlayerCash(giveplayerid, money);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da dat tien cua %s thanh $%d !",GetPlayerNameEx(giveplayerid),money);
			format(string, sizeof(string), "%s has set %s's(%d) to $%d (/setmoney)", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), money);
			Log("logs/stats.log", string);
			format(szMiscArray, sizeof(szMiscArray), "Money set to $%s", number_format(money));
			DBLog(playerid, giveplayerid, "Admin", szMiscArray);
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:givemoney(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		new string[128], giveplayerid, money;
		if(sscanf(params, "ud", giveplayerid, money)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /givemoney [player] [money]");
		if(PlayerInfo[giveplayerid][pLevel] == 1 && PlayerInfo[giveplayerid][pAdmin] < 2) return SendClientMessageEx(playerid, COLOR_RED, "Khong the dung /givemoney voi nguoi cap 1");
		if(money < 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the tang it hon $1!");
		if(IsPlayerConnected(giveplayerid))
		{
			GivePlayerCash(giveplayerid, money);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da tang %s $%s !",GetPlayerNameEx(giveplayerid), number_format(money));
			format(string, sizeof(string), "%s has given %s(%d) $%s (/givemoney)", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), number_format(money));
			Log("logs/stats.log", string);
			format(szMiscArray, sizeof(szMiscArray), "Money given $%s", number_format(money));
			DBLog(playerid, giveplayerid, "Admin", szMiscArray);
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:slap(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[playerid][pWatchdog] == 2)
	{
	    new szString[128], giveplayerid, Float:posx, Float:posy, Float:posz, Float:shealth;
	    if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /slap [player]");
	    if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
	    if((PlayerInfo[giveplayerid][pAdmin] && PlayerInfo[giveplayerid][pAdmin] >= PlayerInfo[playerid][pAdmin]) && giveplayerid != playerid) {
			SendClientMessageEx(giveplayerid, COLOR_YELLOW, "AdmCmd: %s vua thu tat ban!", GetPlayerNameEx(playerid));
			SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung lenh voi Admin ngang hoac cao cap hon!");
			PlayerPlaySound(giveplayerid, 1130, posx, posy, posz);
			return 1;
		}
		else {
		    GetHealth(giveplayerid, shealth);
			SetHealth(giveplayerid, shealth-5);
			GetPlayerPos(giveplayerid, posx, posy, posz);
			SetPlayerPos(giveplayerid, posx, posy, posz+5);
			PlayerPlaySound(giveplayerid, 1130, posx, posy, posz+5);
			if(giveplayerid != playerid) {
				format(szString, sizeof(szString), "AdmCmd: %s da bi %s tat.", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid));
				ABroadCast(COLOR_LIGHTRED, szString, 2);
			}
		}
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	return 1;
}

CMD:kills(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[playerid][pWatchdog] >= 2)
	{
		new giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /kills [player]");

		if(IsPlayerConnected(giveplayerid))
		{
			SendClientMessageEx(playerid, COLOR_GREEN, "________________________________________________");
			SendClientMessageEx(playerid, COLOR_YELLOW, "<< 10 lan giet/chet moi cua %s >>", GetPlayerNameEx(giveplayerid));
			GetLatestKills(playerid, giveplayerid);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:okills(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 3)
	{
		if(isnull(params)) return SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /okills [name]");

		new query[256], giveplayerid;
		giveplayerid = ReturnUser(params);
		if(giveplayerid != INVALID_PLAYER_ID) return SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do dang online, hay dung /kills.");

		new tmpName[24];
		mysql_escape_string(params, tmpName);

		mysql_format(MainPipeline, query, sizeof(query), "SELECT `id` FROM `accounts` WHERE `Username` = '%s'", tmpName);
		mysql_tquery(MainPipeline, query, "OnGetOKills", "is", playerid, tmpName);
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	return 1;
}

CMD:mute(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 1337)
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /mute [player]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(giveplayerid == playerid)
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the dung lenh nay voi chinh minh!");
				return 1;
			}

			if(PlayerInfo[giveplayerid][pMuted] == 0)
			{
				if(PlayerInfo[giveplayerid][pAdmin] >= PlayerInfo[playerid][pAdmin])
				{
					SendClientMessageEx(giveplayerid, COLOR_YELLOW, "%s vua thu /mute ban.",GetPlayerNameEx(playerid));
					SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay voi Admin ngang hoac cao cap hon.");
					return 1;
				}
				PlayerInfo[giveplayerid][pMuted] = 1;
				format(string, sizeof(string), "AdmCmd: %s da bi %s cam chat.",GetPlayerNameEx(giveplayerid),GetPlayerNameEx(playerid));
				ABroadCast(COLOR_LIGHTRED,string,2);
				DBLog(playerid, giveplayerid, "Admin", "Was silenced (/mute)");
			}
			else
			{
				PlayerInfo[giveplayerid][pMuted] = 0;
				format(string, sizeof(string), "AdmCmd: %s duoc %s go cam chat.",GetPlayerNameEx(giveplayerid),GetPlayerNameEx(playerid));
				ABroadCast(COLOR_LIGHTRED,string,2);
				DBLog(playerid, giveplayerid, "Admin", "Was unsilenced (/mute)");
			}
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:kick(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 1 || PlayerInfo[playerid][pHelper] >= 2 || PlayerInfo[playerid][pWatchdog] >= 2)
	{
		new string[128], giveplayerid, reason[64];
		if(sscanf(params, "us[64]", giveplayerid, reason)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /kick [player] [reason]");

		if(giveplayerid != INVALID_PLAYER_ID)
		{
			if(playerid == giveplayerid) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the tu kick, hay dung /q de thoat!"); 
			if(PlayerInfo[playerid][pAdmin] == 1 && (PlayerInfo[giveplayerid][pHelper] >= 2 || PlayerInfo[giveplayerid][pWatchdog] >= 2)) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay voi Admin ngang hoac cao cap hon.");
			if(PlayerInfo[giveplayerid][pAdmin] >= PlayerInfo[playerid][pAdmin] && (PlayerInfo[giveplayerid][pHelper] >= 2 || PlayerInfo[giveplayerid][pAdmin] > 0) && playerid != giveplayerid && PlayerInfo[giveplayerid][pWatchdog] >= PlayerInfo[playerid][pWatchdog]) return SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lam vay voi Admin ngang hoac cao cap hon.");
			else
			{
				new playerip[32];
				GetPlayerIp(giveplayerid, playerip, sizeof(playerip));
				format(string, sizeof(string), "AdmCmd: %s(%d) (IP:%s) was kicked by %s, reason: %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), playerip, GetPlayerNameEx(playerid), reason);
				Log("logs/kick.log", string);
				if(PlayerInfo[playerid][pAdmin] == 1) Log("logs/moderator.log", string);
				SendClientMessageToAllEx(COLOR_LIGHTRED, "AdmCmd: %s da bi %s kick, ly do: %s", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid), reason);
				DBLog(playerid, giveplayerid, "Kick", reason);
				StaffAccountCheck(giveplayerid, GetPlayerIpEx(giveplayerid));
				SetTimerEx("KickEx", 1000, false, "i", giveplayerid);
				if(GetPVarType(giveplayerid, "RepFam_TL")) Rivalry_Toggle(giveplayerid, false);
			}
			return 1;
		}
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:kickres(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] < 99999)
	{
		return 1;
	}

	new level, amount;
	if(sscanf(params, "dd", level, amount)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /kickres [level] [amount]");

	if(level < 0 || level > 5) { SendClientMessageEx(playerid, COLOR_GREY, "   Kick lay cho chi ap dung voi cap 0 den 5!"); return 1; }
	if(amount < 1 || amount > 10) { SendClientMessageEx(playerid, COLOR_GREY, "   Moi lan kick lay cho toi da 10 nguoi!"); return 1; }
	foreach(new i: Player)
	{
		if(PlayerInfo[i][pLevel] == level && PlayerInfo[i][pAdmin] < 1 && PlayerInfo[i][pDonateRank] < 1 && amount > 0)
		{
			DBLog(playerid, i, "Kick", "Reserve slot kicked (/kickres)");
			amount -= 1;
			Kick(i);
		}
	}
	return 1;
}

CMD:warn(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[playerid][pWatchdog] >= 2)
	{
		new string[128], giveplayerid, reason[64];
		if(sscanf(params, "us[64]", giveplayerid, reason)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /warn [player] [reason]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pAdmin] >= 2) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the canh bao Admin!");
			PlayerInfo[giveplayerid][pWarns] += 1;
			if(PlayerInfo[giveplayerid][pWarns] >= 3)
			{
				PlayerInfo[giveplayerid][pWarns] = 0;
				CreateBan(playerid, PlayerInfo[giveplayerid][pId], giveplayerid, PlayerInfo[giveplayerid][pIP], "3 Warnings", 14);
				return 1;
			}
			format(string, sizeof(string), "AdmCmd: %s da bi %s canh bao, ly do: %s", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid), reason);
			ABroadCast(COLOR_LIGHTRED, string, 2);
			if(PlayerInfo[playerid][pWatchdog] >= 2)
			{
				foreach(new i: Player) if(PlayerInfo[i][pWatchdog] >= 1 && PlayerInfo[i][pAdmin] < 2) SendClientMessageEx(i, COLOR_LIGHTRED, string);
			}
			format(string, sizeof(string), "AdmCmd: %s(%d) was warned by %s, reason: %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), reason);
			Log("logs/admin.log", string);
			format(szMiscArray, sizeof(szMiscArray), "Was warned (%s)", reason);
			DBLog(playerid, giveplayerid, "Admin", szMiscArray);
			StaffAccountCheck(giveplayerid, GetPlayerIpEx(giveplayerid));
			SendClientMessageEx(giveplayerid, COLOR_LIGHTRED, "Ban bi %s canh bao, ly do: %s", GetPlayerNameEx(playerid), reason);
			return 1;

		}
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	return 1;
}

CMD:swarn(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 1337 || PlayerInfo[playerid][pUndercover] >= 1)
	{
		new string[128], giveplayerid, reason[64];
		if(sscanf(params, "us[64]", giveplayerid, reason)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /swarn [player] [reason]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pAdmin] >= 2) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the canh bao Admin!");
			PlayerInfo[giveplayerid][pWarns] += 1;
			if(PlayerInfo[giveplayerid][pWarns] >= 3)
			{
			 	PlayerInfo[giveplayerid][pWarns] = 0;
			 	CreateBan(playerid, PlayerInfo[giveplayerid][pId], giveplayerid, PlayerInfo[giveplayerid][pIP], "3 Warnings", 14);
				return 1;
			}
			format(string, sizeof(string), "AdmCmd: %s da bi %s canh bao an, ly do: %s", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid), reason);
			ABroadCast(COLOR_LIGHTRED, string, 2);
			format(string, sizeof(string), "AdmCmd: %s(%d) was silent warned by %s, reason: %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), reason);
			Log("logs/admin.log", string);
			format(szMiscArray, sizeof(szMiscArray), "Was warned (%s)", reason);
			DBLog(playerid, giveplayerid, "Admin", szMiscArray);
			StaffAccountCheck(giveplayerid, GetPlayerIpEx(giveplayerid));
			SendClientMessageEx(giveplayerid, COLOR_LIGHTRED, "Ban bi Admin canh bao, ly do: %s", reason);
			return 1;

		}
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	return 1;
}

CMD:owarn(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3)
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
		return 1;
	}

	new query[512], name[MAX_PLAYER_NAME], reason[64];
	if(sscanf(params, "s[24]s[64]", name, reason)) return SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /owarn [name] [reason]");

	new giveplayerid = ReturnUser(name);
	if(giveplayerid != INVALID_PLAYER_ID)
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do dang online, hay dung /warn.");
		return 1;
	}

	new tmpName[24];
	mysql_escape_string(name,tmpName);
	SetPVarString(playerid, "OnWarnPlayer", tmpName);
	SetPVarString(playerid, "OnWarnPlayerReason", reason);

	mysql_format(MainPipeline, query, sizeof(query), "UPDATE `accounts` SET `Warnings`=`Warnings`+1 WHERE `Username`='%s' AND `PermBand` < 3 AND `Band` < 1 AND `AdminLevel` < 2",tmpName);
	mysql_tquery(MainPipeline, query, "OnWarnPlayer", "i", playerid);

	SendClientMessageEx(playerid, COLOR_YELLOW, "Dang canh bao %s...", tmpName);

	return 1;
}

CMD:skick(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[playerid][pWatchdog] >= 2)
	{
		new string[128], giveplayerid, reason[64];
		if(sscanf(params, "us[64]", giveplayerid, reason)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /skick [player] [reason]");

		if(giveplayerid != INVALID_PLAYER_ID)
		{
			if(PlayerInfo[giveplayerid][pAdmin] > PlayerInfo[playerid][pAdmin])
			{
				format(string, sizeof(string), "AdmCmd: %s bi tu dong kick, ly do: Thu /skick Admin cap cao hon.", GetPlayerNameEx(playerid));
				ABroadCast(COLOR_YELLOW,string,2);
				SetTimerEx("KickEx", 1000, false, "i", playerid);
				return 1;
			}
			else
			{
				new playerip[32];
				GetPlayerIp(giveplayerid, playerip, sizeof(playerip));
				format(string, sizeof(string), "AdmCmd: %s(%d) (IP:%s) was silent kicked by %s, reason: %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), playerip, GetPlayerNameEx(playerid), reason);
				Log("logs/kick.log", string);
				format(string, sizeof(string), "AdmCmd: %s da bi %s kick an, ly do: %s", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid), reason);
				ABroadCast(COLOR_LIGHTRED,string,2);

				StaffAccountCheck(giveplayerid, GetPlayerIpEx(giveplayerid));
				SetTimerEx("KickEx", 1000, false, "i", giveplayerid);
			}
			return 1;

		}
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	return 1;
}

CMD:freeze(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 2)
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /freeze [player]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pAdmin] > PlayerInfo[playerid][pAdmin])
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the dong bang Admin cap cao hon.");
				return 1;
			}

			TogglePlayerControllable(giveplayerid, false);
			SetPVarInt(giveplayerid, "IsFrozen", 1);
			format(string, sizeof(string), "AdmCmd: %s bi %s dong bang",GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid));
			ABroadCast(COLOR_LIGHTRED,string, 2);
			DBLog(playerid, giveplayerid, "Admin", "Was frozen");
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:unfreeze(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 2)
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /unfreeze [player]");


		if(IsPlayerConnected(giveplayerid))
		{
			DeletePVar(giveplayerid, "IsFrozen");
			DeletePVar(giveplayerid, "PlayerCuffed");
			PlayerCuffed[giveplayerid] = 0;
			PlayerTied[giveplayerid] = 0;
			TogglePlayerControllable(giveplayerid, true);
			format(string, sizeof(string), "AdmCmd: %s duoc %s go dong bang.",GetPlayerNameEx(giveplayerid),GetPlayerNameEx(playerid));
			ABroadCast(COLOR_LIGHTRED,string,2);
			DBLog(playerid, giveplayerid, "Admin", "Was un-frozen");
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Nguoi choi khong hop le.");
		}

	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:makemoderator(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 1337 || PlayerInfo[playerid][pAP] >= 2 || PlayerInfo[playerid][pHR] >= 3)
	{
		new string[128], giveplayerid, level;
		if(sscanf(params, "ui", giveplayerid, level)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /makemoderator [player] [level 1-2]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pAdmin] >= 2)
			{
				SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the thao tac voi Admin hien tai!");
				return 1;
			}
			if(IsStaffBanned(giveplayerid)) 
				return SendClientMessage(playerid, COLOR_WHITE, "Nguoi do dang bi cam lam staff.");
			
			PlayerInfo[giveplayerid][pAdmin] = 1;
			if(level == 1) {
				PlayerInfo[giveplayerid][pSMod] = 0;
				SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "Ban duoc %s bo nhiem lam Moderator", GetPlayerNameEx(playerid));
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da bo nhiem %s lam Moderator.", GetPlayerNameEx(giveplayerid));
				format(string, sizeof(string), "%s(%d) has been made a moderator by %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid));
				Log("logs/moderator.log", string);
			}
			else if(level == 2) {
				PlayerInfo[giveplayerid][pSMod] = 1;
				SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "Ban duoc %s bo nhiem lam Senior Moderator", GetPlayerNameEx(playerid));
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da bo nhiem %s lam Senior Moderator.", GetPlayerNameEx(giveplayerid));
				format(string, sizeof(string), "%s(%d) has been made a senior moderator by %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid));
				Log("logs/moderator.log", string);
			}
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:removemoderator(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 1337)
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /removemoderator [player]");

		if(IsPlayerConnected(giveplayerid))
		{

			if(PlayerInfo[giveplayerid][pAdmin] == 1)
			{
				if(GetPVarInt(playerid, "AdvisorDuty") == 1)
				{
					DeletePVar(playerid, "AdvisorDuty");
					Advisors -= 1;
				}
				PlayerInfo[giveplayerid][pAdmin] = 0;
				PlayerInfo[giveplayerid][pSMod] = 0;
				SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "%s da loai ban khoi doi ngu Moderator.", GetPlayerNameEx(playerid));
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da go Moderator cua %s.", GetPlayerNameEx(giveplayerid));
				format(string, sizeof(string), "%s(%d) moderator has been removed by %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid));
				Log("logs/moderator.log", string);
			}

		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}



alias:ah("ahelp")
CMD:ah(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] >= 1) Help_ListCat(playerid, DIALOG_HELPCATADMIN);
	return 1;
}



alias:oah("oahelp")
CMD:oah(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 1 || PlayerInfo[playerid][pHelper] >= 1) SendClientMessageEx(playerid, COLOR_GREEN,"_______________________________________");
	if (PlayerInfo[playerid][pAdmin] >= 1)
	{
		if(PlayerInfo[playerid][pSMod] > 0) SendClientMessageEx(playerid, COLOR_GRAD1, "*** {FFFF00}SENIOR SERVER MODERATOR{B4B5B7} --* /jail /kick /staff /togstaff /changename");
		else SendClientMessageEx(playerid, COLOR_GRAD1, "--* {FFFF00}SERVER MODERATOR{B4B5B7} --* /mjail /kick /staff /togstaff");
	}
	if (PlayerInfo[playerid][pWatchdog] >= 3)
	{
		SendClientMessageEx(playerid, COLOR_GRAD2,"--* RP SPECIALIST --* /watchdogs /restrictaccount /unrestrictaccount /togwd /makewatchdog");
	}
	if (PlayerInfo[playerid][pWatchdog] >= 4)
	{
		SendClientMessageEx(playerid, COLOR_GRAD2,"--* Director of RP Improvement --* /watchlistadd /watchlistremove /wdwhitelist");
	}
	if (PlayerInfo[playerid][pAdmin] >= 2)
	{
		SendClientMessageEx(playerid, COLOR_GRAD2,"--* BAO CAO --* /reports /ar /tr /sta /nao /st /post /dmr /ts --* DI CHUYEN --* /up /dn /fd /bk /lt /rt /fly");
		SendClientMessageEx(playerid, COLOR_GRAD2,"--* {00FF00}JUNIOR ADMIN{BFC0C2} --* /kick /ban /prison /freeze /unfreeze /slap /warn /admins /spec /levelones /sendtoid");
		SendClientMessageEx(playerid, COLOR_GRAD2,"--* {00FF00}JUNIOR ADMIN{BFC0C2} --* /sendto /gotopveh /gotocar /jetpack /god /check /anetstats /ipcheck /ip /nrn /listguns");
		SendClientMessageEx(playerid, COLOR_GRAD2,"--* {00FF00}JUNIOR ADMIN{BFC0C2} --* /setvw /setint /vehname /gethere /gotoid /hospital /goto /revive /bigears /skick /damagecheck");
		SendClientMessageEx(playerid, COLOR_GRAD2,"--* {00FF00}JUNIOR ADMIN{BFC0C2} --* /requestevent /watch /dmwatchlist /mark(2) /n(un)mute /ad(un)mute /checkinv /lastshot");
		SendClientMessageEx(playerid, COLOR_GRAD2,"--* {00FF00}JUNIOR ADMIN{BFC0C2} --* /respawncar /watchlist /watchdogs /flag /viewflag /aflag /aviewflag /transferflag /deleteflag");
	}
	if (PlayerInfo[playerid][pAdmin] >= 3)
	{
		SendClientMessageEx(playerid, COLOR_GRAD3,"--* {00FF00}GENERAL ADMIN{CBCCCE} --* /noooc /nonewbie /fine /pfine /takeadminweapons /prisonaccount /entercar /getcar");
		SendClientMessageEx(playerid, COLOR_GRAD3,"--* {00FF00}GENERAL ADMIN{CBCCCE} --* /mole /setskin /countdown /release /forcedeath /rto(reset) /adviorce /metaldetector");
		SendClientMessageEx(playerid, COLOR_GRAD3,"--* {00FF00}GENERAL ADMIN{CBCCCE} --* /gotoco /leaders /wepreset /owarn /ofine /okills /respawncars /resetvw /aviewrivals");
		SendClientMessageEx(playerid, COLOR_GRAD3,"--* {00FF00}GENERAL ADMIN{CBCCCE} --* /reloadpvehicles /apark /aimpound /dmrmute /dmrlookup /dmtokens /createmetaldetector /metdets");
	}
	if (PlayerInfo[playerid][pAdmin] >= 4)
	{
		SendClientMessageEx(playerid, COLOR_GRAD4,"--* {EE9A4D}SENIOR ADMIN{D8D8D8} --* /asellbiz /fixvehall /givenos /blowup /setname /savechars /dmstrikereset /cnn /respawnvipcars");
		SendClientMessageEx(playerid, COLOR_GRAD4,"--* {EE9A4D}SENIOR ADMIN{D8D8D8} --* /veh /fixveh /sethp /setarmor /givegun /givemoney /setmoney /setstat /setfightstyle /switchgroup /switchfam");
		SendClientMessageEx(playerid, COLOR_GRAD4,"--* {EE9A4D}SENIOR ADMIN{D8D8D8} --* /fcreate /fdelete /adivorce /destroycar /destroycars /eventhelp /contracts /sprison /banip /unbanip");
		SendClientMessageEx(playerid, COLOR_GRAD4,"--* {EE9A4D}SENIOR ADMIN{D8D8D8} --* /groupban /deletehit /setinsurance /cmotd /givelicense /adestroyplant /tl(edit/text/status/next)");
		SendClientMessageEx(playerid, COLOR_GRAD4,"--* {EE9A4D}SENIOR ADMIN{D8D8D8} --* /gotolabel /createpvehicle /destroypvehicle /vto /vtoreset /admingatepw /gotogate /dedit /fedit");
		SendClientMessageEx(playerid, COLOR_GRAD4,"--* {EE9A4D}SENIOR ADMIN{D8D8D8} --* /hnext /dmpnext /g(status/near/next/edit) /(goto/goin)door /(goto/goin)house /(create/delete/goto)point");
		SendClientMessageEx(playerid, COLOR_GRAD4,"--* {EE9A4D}SENIOR ADMIN{D8D8D8} --* /hedit /dd(edit/next/name/pass) /dmpedit /dmpnear /gotomapicon /gangwarn /gangunban /setcapping /banaccount");
		SendClientMessageEx(playerid, COLOR_GRAD4,"--* {EE9A4D}SENIOR ADMIN{D8D8D8} --* /removepvehicle /rcabuse /createmailbox /adestroymailbox /b(edit/next/name) /adestroycrate /gotocrate /srelease");
		SendClientMessageEx(playerid, COLOR_GRAD4,"--* {EE9A4D}SENIOR ADMIN{D8D8D8} --* /(create/edit/delete)gaspump /(goto/goin)biz /dvcreate /dvstatus /dvrespawn /dvedit /dveditslot /dvplate /checkvouchers");
		SendClientMessageEx(playerid, COLOR_GRAD4,"--* {EE9A4D}SENIOR ADMIN{D8D8D8} --* /checkvouchers /srelease /ovmute /ovunmute /restrictaccount /unrestrictaccount /wdwhitelist /resetexamine");
		SendClientMessageEx(playerid, COLOR_GRAD4,"--* {EE9A4D}SENIOR ADMIN{D8D8D8} --* /makeleader /groupunban /groupcsfunban /eventreset /asellhouse /editgrouptoy /amanagerivals /gotodpoint");
	}
	if (PlayerInfo[playerid][pAdmin] >= 1337)
	{
		SendClientMessageEx(playerid, COLOR_GRAD5,"--* {FF0000}HEAD ADMIN{E3E3E3} --* /ha /setweather /pedit /giftall /removemoderator /vipgifts /buddyinvite /rewardplay /setarmorall /dynamicgift");
		SendClientMessageEx(playerid, COLOR_GRAD5,"--* {FF0000}HEAD ADMIN{E3E3E3} --* /permaban /setcolor /payday /clearallreports /amotd /motd /vipmotd /givetoken /giftgvip /dvrespawnall");
		SendClientMessageEx(playerid, COLOR_GRAD5,"--* {FF0000}HEAD ADMIN{E3E3E3} --* /vmute /vsuspend /togfireworks /togshopnotices /spg /snonrp /smg /skos /undercover /makewatchdog /watchlistadd");
		SendClientMessageEx(playerid, COLOR_GRAD5,"--* {FF0000}HEAD ADMIN{E3E3E3} --* /gifts /rcreset /audiourl /audiostopurl /editgrouptoy  /setsec /suspend /osuspend /ounsuspend");
		SendClientMessageEx(playerid, COLOR_GRAD5,"--* {FF0000}HEAD ADMIN{E3E3E3} --* /osetrmutes /rmute /clearall /specreset /pausespec /random /vrandom /giftreset /searchvipm /editpoint");
	}
	if (PlayerInfo[playerid][pAdmin] >= 99999)
	{
		SendClientMessageEx(playerid, COLOR_GRAD6,"--* {298EFF}EXECUTIVE ADMIN{F0F0F0} --* /togspec /togtp /kickres /givecredits /setcredits /settotalcredits /setstpay /resetstpay /pmotd");
		SendClientMessageEx(playerid, COLOR_GRAD6,"--* {298EFF}EXECUTIVE ADMIN{F0F0F0} --* /setcode /togdynamicgift /dgedit /viewgiftbox /togpasscomplexity");
	}
	if (PlayerInfo[playerid][pHR] >= 2)
	{
		SendClientMessageEx(playerid, COLOR_GRAD5, "--* Dac biet - Human Resources --* /givesprize /setsec");
	}
	if(PlayerInfo[playerid][pAP] >= 2 || PlayerInfo[playerid][pHR] >= 3)
	{
		SendClientMessageEx(playerid, COLOR_GRAD5, "--* Dac biet - AP/HR --* /makemoderator /makeadmin /rmute /suspend /osuspend /ounsuspend /osetrmutes");
	}
	if (PlayerInfo[playerid][pBanAppealer] >= 1) SendClientMessageEx(playerid, COLOR_GRAD5, "--* Dac biet - Ban Appealer --* /unbanip /unban");
	if (PlayerInfo[playerid][pUndercover] >= 1)
	{
		SendClientMessageEx(playerid, COLOR_GRAD5, "--* Dac biet - Spec Ops --* /setmystat /setmyname /setmyhp /setmyarmour /sprison /sdm /swarn");
		SendClientMessageEx(playerid, COLOR_GRAD5, "--* Dac biet - Spec Ops --* /spg /snonrp /smg /skos");
	}
	if (PlayerInfo[playerid][pGangModerator] >= 1)
	{
		SendClientMessageEx(playerid, COLOR_GRAD5, "--* Dac biet - Gang Mod --* /switchfam /fedit /feditcolor /gangwarn /gangban /gangunban /fcreate /fdelete /twmenu /dvrespawn");
		SendClientMessageEx(playerid, COLOR_GRAD5, "--* Dac biet - Gang Mod --* /gtedit /gtstatus /gtnear /tagperm /tagedit /fires /destroyfire /destroyfires /gotofire /setfstrength");
	}
	if (PlayerInfo[playerid][pGangModerator] >= 2) SendClientMessageEx(playerid, COLOR_GRAD5, "--* Dac biet - DoGM --* /dvcreate /dvedit /dveditslot /dvplate");
	if (PlayerInfo[playerid][pShopTech] >= 1)
	{
		SendClientMessageEx(playerid, COLOR_GRAD5, "--* Dac biet - Shop Tech --* /orders /adjustoid /shop(car(del)/house/tokens/exp/plate/laser/vest/firework/viptokens/boombox/object) /gedit /gnear");
		SendClientMessageEx(playerid, COLOR_GRAD5, "--* Dac biet - Shop Tech --* /g(status/next) /hnext /goto(gate/door) /goinhouse /setvip /searchvipm /newgvip /renewgvip" );
		SendClientMessageEx(playerid, COLOR_GRAD5, "--* Dac biet - Shop Tech --* /shopbusiness /shopbusinessname /brenewal");
	}
	if (PlayerInfo[playerid][pShopTech] >= 2)
	{
		SendClientMessageEx(playerid, COLOR_GRAD5, "--* Dac biet - Senior Shop Tech --* /shopcredits");
	}

	if(PlayerInfo[playerid][pBM] >= 1)
	{
		SendClientMessageEx(playerid, COLOR_GRAD3, "--* Dac biet - Biz Mod --* /bedit /bname /bnext /bnear /gotobiz /goinbiz /creategaspump /editgaspump /deletegaspump /switchbiz");
		if(PlayerInfo[playerid][pBM] >= 2) SendClientMessageEx(playerid, COLOR_GRAD3, "--* Dac biet - DoBM --* /asellbiz");
	}
	if (PlayerInfo[playerid][pShopTech] >= 3) SendClientMessageEx(playerid, COLOR_GRAD5, "--* Dac biet - DoCR --* /pmotd /ovmute /ovunmute /vipm /togdynamicgift /dgedit /viewgiftbox /freeweekend");
	if (PlayerInfo[playerid][pFactionModerator] >= 1) SendClientMessageEx(playerid, COLOR_GRAD5, "--* Dac biet - Faction Mod --* /switchgroup /groupcsfban /groupban /groupkick /leaders /dvrespawn"), SendClientMessageEx(playerid, COLOR_GRAD5, "--* Dac biet - Faction Mod --* /fires /destroyfire /destroyfires /gotofire /setfstrength");
	if (PlayerInfo[playerid][pFactionModerator] >= 2) SendClientMessageEx(playerid, COLOR_GRAD5, "--* Dac biet - DoFM --* /dvcreate /dvedit /dveditslot /dvplate /editpoint");
	if (PlayerInfo[playerid][pPR] >= 1) SendClientMessageEx(playerid, COLOR_GRAD5, "--* Dac biet - Public Relations --* /catokens /cmotd /makeadvisor /takeadvisor");
	if (PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] >= 1) // If they're not a senior admin and they're ASM level is 1 or higher.
	{
		SendClientMessageEx(playerid, COLOR_GRAD5,"--* Dac biet - ASM --* /asellbiz /fixvehall /givenos /blowup /setname /savechars /dmstrikereset /cnn /respawnvipcars");
		SendClientMessageEx(playerid, COLOR_GRAD5,"--* Dac biet - ASM --* /veh /fixveh /sethp /setarmor /givegun /givemoney /setmoney /setstat /setfightstyle /switchgroup /switchfam");
		SendClientMessageEx(playerid, COLOR_GRAD5,"--* Dac biet - ASM --* /fcreate /fdelete /adivorce /destroycar /destroycars /eventhelp /contracts /sprison /banip /unbanip");
		SendClientMessageEx(playerid, COLOR_GRAD5,"--* Dac biet - ASM --* /groupban /deletehit /setinsurance /cmotd /givelicense /adestroyplant /tl(edit/text/status/next)");
		SendClientMessageEx(playerid, COLOR_GRAD5,"--* Dac biet - ASM --* /gotolabel /createpvehicle /destroypvehicle /vto /vtoreset /admingatepw /gotogate /dedit /fedit");
		SendClientMessageEx(playerid, COLOR_GRAD5,"--* Dac biet - ASM --* /hnext /dmpnext /g(status/near/next/edit) /(goto/goin)door /(goto/goin)house /(create/delete/goto)point");
		SendClientMessageEx(playerid, COLOR_GRAD5,"--* Dac biet - ASM --* /hedit /dd(edit/next/name/pass) /dmpedit /dmpnear /gotomapicon /gangwarn /gangunban /setcapping /banaccount");
		SendClientMessageEx(playerid, COLOR_GRAD5,"--* Dac biet - ASM --* /removepvehicle /rcabuse /createmailbox /adestroymailbox /b(edit/next/name) /adestroycrate /gotocrate /srelease");
		SendClientMessageEx(playerid, COLOR_GRAD5,"--* Dac biet - ASM --* /(create/edit/delete)gaspump /(goto/goin)biz /dvcreate /dvstatus /dvrespawn /dvedit /dveditslot /dvplate /checkvouchers");
		SendClientMessageEx(playerid, COLOR_GRAD5,"--* Dac biet - ASM --* /checkvouchers /srelease /ovmute /ovunmute /restrictaccount /unrestrictaccount /wdwhitelist /resetexamine");
	}

	if (PlayerInfo[playerid][pHelper] >= 1) SendClientMessageEx(playerid, COLOR_GRAD5, "--* Helper Advisor --* /advisors /ca /newbquestions /an /tn /spec");
	if ( PlayerInfo[playerid][pHelper] >= 2) SendClientMessageEx(playerid, COLOR_GRAD5, "--* Community Advisor --* /caduty /showrequests /accepthelp /finishhelp /findnewb /staff /kick /mjail /rhmute /nmute");
	if ( PlayerInfo[playerid][pHelper] >= 3) SendClientMessageEx(playerid, COLOR_GRAD5, "--* Senior Advisor --* /makeadvisor /takeadvisor /requestevent /newbspec");
	if ( PlayerInfo[playerid][pHelper] == 4) SendClientMessageEx(playerid, COLOR_GRAD5, "--* Chief Advisor --* /advisormotd /nonewbie /newbspec");

	if ( PlayerInfo[playerid][pAdmin] >= 1 || PlayerInfo[playerid][pHelper] >= 1) SendClientMessageEx(playerid, COLOR_GREEN,"_______________________________________");
	return 1;
}

CMD:nrn(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[playerid][pSMod] == 1)
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /nrn [player]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pAdmin] >= 2)return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the dung lenh nay voi Admin!");
			// Can't believe this isn't fixed, happened to me like 2321231321 times - Akatony
			if((PlayerInfo[playerid][pSMod] == 1 || PlayerInfo[playerid][pWatchdog] >= 2) && (PlayerInfo[giveplayerid][pSMod] == 1 || PlayerInfo[giveplayerid][pWatchdog] >= 2)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the dung lenh nay cho nguoi nay!");

			format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s da de nghi cho %s doi ten mien phi vi ten khong dung RP.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
			format(szMiscArray, sizeof(szMiscArray), "%s (SQL ID: %d) has offered %s (SQL ID: %d) a free name change because their name is non-RP.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
			Log("logs/nrnlog.log", szMiscArray);
			foreach(new i: Player)
			{
				if(PlayerInfo[i][pSMod] == 1 || PlayerInfo[i][pWatchdog] >= 2)
				{
					SendClientMessageEx(i, COLOR_YELLOW, string);
				}
			}
			ABroadCast( COLOR_YELLOW, string, 2);
			ShowPlayerDialogEx(giveplayerid, DIALOG_NAMECHANGE2, DIALOG_STYLE_INPUT, "Doi ten mien phi","May chu roleplay yeu cau ten theo dang: Firstname_Lastname.\nVi du: John_Smith hoac Jimmy_Johnson\n\nAdmin cho phep ban doi ten dung dinh dang mien phi. Nhap ten mong muon ben duoi.\n\nLuu y: Nhan huy se bi ngat ket noi khoi may chu.", "Doi", "Huy" );
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:reloadlist(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 1337)
	{
	    ToyList2 = NGRP_LoadModelSelectionMenu("ToyList.txt");
		CarList2 = NGRP_LoadModelSelectionMenu("CarList.txt");
		PlaneList = NGRP_LoadModelSelectionMenu("PlaneList.txt");
		BoatList = NGRP_LoadModelSelectionMenu("BoatList.txt");
		SendClientMessageEx(playerid, COLOR_CYAN, "Da tai lai cac danh sach.");
	}
	return 1;
}

CMD:mods(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2)
	{
		new string[3024]; // This is what happens when there is 100 moderators online
		foreach(new i : Player)
		{
			if(PlayerInfo[i][pAdmin] == 1)
			{
				format(string, sizeof(string), "%s\nModerator %s (ID %i)", string, GetPlayerNameEx(i), i);
			}
		}
		ShowPlayerDialogEx(playerid, 0, DIALOG_STYLE_LIST, "Moderator dang online", string, "Dong", "");
	}
	else
		return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	return 1;
}

CMD:givesprize(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1338 && PlayerInfo[playerid][pHR] < 2) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	new PName[MAX_PLAYER_NAME], choice[16], amount;
	if(sscanf(params, "s[24]s[16]d", PName, choice, amount))
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /givesprize [playerid/PlayerName] [Choice] [Amount]");
		SendClientMessageEx(playerid, COLOR_GREY, "Lua chon: CarSlot | ToySlot | CarVoucher | GiftVoucher");
		SendClientMessageEx(playerid, COLOR_GREY, "Luu y: Lenh dung duoc ca offline va online.");
		return 1;
	}
	if(amount < 1) return SendClientMessage(playerid, COLOR_GREY, "So luong khong duoc nho hon 1");
	new string[128];
	new pID = ReturnUser(PName);
	if(IsPlayerConnected(pID))
	{
		if(strcmp(choice, "carslot", true) == 0)
		{
			PlayerInfo[pID][pVehicleSlot] += amount;
			LoadPlayerDisabledVehicles(pID);
			format(string, sizeof(string), "AdmCmd: %s da tang %s %d o chua xe mien phi.", GetPlayerNameEx(playerid), GetPlayerNameEx(pID), amount);
			ABroadCast(COLOR_LIGHTRED, string, 2);
			SendClientMessageEx(pID, COLOR_LIGHTBLUE, "Ban nhan %d o xe mien phi tu %s.",amount, GetPlayerNameEx(playerid));
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da tang %s %d o chua xe.", GetPlayerNameEx(pID), amount);
			format(string, sizeof(string), "[Admin] %s(%d)(IP:%s) has given %s(%d)(IP:%s) %d free car slot(s).", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), GetPlayerNameEx(pID), GetPlayerSQLId(pID), GetPlayerIpEx(pID), amount);
			Log("logs/adminrewards.log", string);
		}
		else if(strcmp(choice, "toyslot", true) == 0)
		{
			PlayerInfo[pID][pToySlot] += amount;
			format(string, sizeof(string), "AdmCmd: %s tang %s %d o toy mien phi.", GetPlayerNameEx(playerid), GetPlayerNameEx(pID), amount);
			ABroadCast(COLOR_LIGHTRED, string, 2);
			SendClientMessageEx(pID, COLOR_LIGHTBLUE, "Ban nhan %d o toy mien phi tu %s.",amount, GetPlayerNameEx(playerid));
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da tang %s %d o chua toy.", GetPlayerNameEx(pID), amount);
			format(string, sizeof(string), "[Admin] %s(%d)(IP:%s) has given %s(%d)(IP:%s) %d free toy slot(s).", GetPlayerNameEx(playerid), GetPlayerIpEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(pID), GetPlayerSQLId(pID), GetPlayerIpEx(pID), amount);
			Log("logs/adminrewards.log", string);
		}
		else if(strcmp(choice, "carvoucher", true) == 0)
		{
			PlayerInfo[pID][pVehVoucher] += amount;
			format(string, sizeof(string), "AdmCmd: %s da tang %s %d Car Voucher mien phi.", GetPlayerNameEx(playerid), GetPlayerNameEx(pID), amount);
			ABroadCast(COLOR_LIGHTRED, string, 2);
			SendClientMessageEx(pID, COLOR_LIGHTBLUE, "Ban nhan duoc %d Car Voucher mien phi tu %s.",amount, GetPlayerNameEx(playerid));
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da tang %s %d Car Voucher.", GetPlayerNameEx(pID), amount);
			format(string, sizeof(string), "[Admin] %s(%d)(IP:%s) has given %s(%d)(IP:%s) %d free car voucher(s).", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), GetPlayerNameEx(pID), GetPlayerSQLId(pID), GetPlayerIpEx(pID), amount);
			Log("logs/adminrewards.log", string);
		}
		else if(strcmp(choice, "giftvoucher", true) == 0)
		{
			PlayerInfo[pID][pGiftVoucher] += amount;
			format(string, sizeof(string), "AdmCmd: %s da tang %s %d Gift Reset Voucher mien phi.", GetPlayerNameEx(playerid), GetPlayerNameEx(pID), amount);
			ABroadCast(COLOR_LIGHTRED, string, 2);
			SendClientMessageEx(pID, COLOR_LIGHTBLUE, "Ban nhan duoc %d Gift Reset Voucher mien phi tu %s.",amount, GetPlayerNameEx(playerid));
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da tang %s %d Gift Reset Voucher.", GetPlayerNameEx(pID), amount);
			format(string, sizeof(string), "[Admin] %s(%d)(IP:%s) has given %s(%d)(IP:%s) %d free gift reset voucher(s).", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), GetPlayerNameEx(pID),  GetPlayerSQLId(pID), GetPlayerIpEx(pID), amount);
			Log("logs/adminrewards.log", string);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Lua chon khong hop le.");
		}
	}
	else
	{
		new tmpName[24];
		if(strcmp(choice, "carslot", true) == 0)
		{
			mysql_escape_string(PName, tmpName);
			mysql_format(MainPipeline, string, sizeof(string), "UPDATE `accounts` SET `VehicleSlot` = `VehicleSlot`+%d WHERE `Username`='%s'",amount, tmpName);
			mysql_tquery(MainPipeline, string, "OnStaffPrize", "i", playerid);
			SendClientMessageEx(playerid, COLOR_YELLOW, "Dang tang %s %d o chua xe..", tmpName, amount);
			SetPVarString(playerid, "OnSPrizeType", "Car Slot(s)");
			SetPVarString(playerid, "OnSPrizeName", tmpName);
			SetPVarInt(playerid, "OnSPrizeAmount", amount);
		}
		else if(strcmp(choice, "toyslot", true) == 0)
		{
			mysql_escape_string(PName, tmpName);
			mysql_format(MainPipeline, string, sizeof(string), "UPDATE `accounts` SET `ToySlot` = `ToySlot`+%d WHERE `Username`='%s'",amount, tmpName);
			mysql_tquery(MainPipeline, string, "OnStaffPrize", "i", playerid);
			SendClientMessageEx(playerid, COLOR_YELLOW, "Dang tang %s %d o chua toy..", tmpName, amount);
			SetPVarString(playerid, "OnSPrizeType", "Toy Slot(s)");
			SetPVarString(playerid, "OnSPrizeName", tmpName);
			SetPVarInt(playerid, "OnSPrizeAmount", amount);
		}
		else if(strcmp(choice, "carvoucher", true) == 0)
		{
			mysql_escape_string(PName, tmpName);
			mysql_format(MainPipeline, string, sizeof(string), "UPDATE `accounts` SET `VehVoucher` = `VehVoucher`+%d WHERE `Username`='%s'",amount, tmpName);
			mysql_tquery(MainPipeline, string, "OnStaffPrize", "i", playerid);
			SendClientMessageEx(playerid, COLOR_YELLOW, "Dang tang %s %d Car Voucher..", tmpName, amount);
			SetPVarString(playerid, "OnSPrizeType", "Car Voucher(s)");
			SetPVarString(playerid, "OnSPrizeName", tmpName);
			SetPVarInt(playerid, "OnSPrizeAmount", amount);
		}
		else if(strcmp(choice, "giftvoucher", true) == 0)
		{
			mysql_escape_string(PName, tmpName);
			mysql_format(MainPipeline, string, sizeof(string), "UPDATE `accounts` SET `GiftVoucher` = `GiftVoucher`+%d WHERE `Username`='%s'",amount, tmpName);
			mysql_tquery(MainPipeline, string, "OnStaffPrize", "i", playerid);
			SendClientMessageEx(playerid, COLOR_YELLOW, "Dang tang %s %d Gift Reset Voucher..", tmpName, amount);
			SetPVarString(playerid, "OnSPrizeType", "Gift Reset Voucher(s)");
			SetPVarString(playerid, "OnSPrizeName", tmpName);
			SetPVarInt(playerid, "OnSPrizeAmount", amount);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Lua chon khong hop le.");
		}
	}
	return 1;
}

CMD:srelease(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		new string[128], giveplayerid, reason[64];
		if(sscanf(params, "us[64]", giveplayerid, reason)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /srelease [player] [reason]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pJailTime] == 0)
			{
				SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi hien khong bi giam!");
			}
			else
			{
				format(string, sizeof(string), "AdmCmd: %s(%d) has been silent released from prison by %s, reason: %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), reason);
				Log("logs/admin.log", string);
				format(string, sizeof(string), "AdmCmd: %s da duoc %s tha tu an, ly do: %s", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid), reason);
				ABroadCast(COLOR_LIGHTRED, string, 2);
				PhoneOnline[giveplayerid] = 0;
				PlayerInfo[giveplayerid][pWantedLevel] = 0;
				Lawyer_ClearAppeal(giveplayerid);
				PlayerInfo[giveplayerid][pBeingSentenced] = 0;
				SetPlayerToTeamColor(giveplayerid);
				SetHealth(giveplayerid, 100);
				SetPlayerWantedLevel(giveplayerid, 0);
				PlayerInfo[giveplayerid][pJailTime] = 0;
				SetPlayerPos(giveplayerid, 1529.6,-1691.2,13.3);
				SetPlayerInterior(giveplayerid,0);
				PlayerInfo[giveplayerid][pInt] = 0;
				SetPlayerVirtualWorld(giveplayerid, 0);
				PlayerInfo[giveplayerid][pVW] = 0;
				strcpy(PlayerInfo[giveplayerid][pPrisonReason], "None", 128);
				SetPlayerToTeamColor(giveplayerid);
			}
		}
		else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:undercover(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 1337)
	{
		if(!GetPVarType(playerid, "Undercover"))
		{
			SetPVarInt(playerid, "Undercover", 1);
			SendClientMessageEx(playerid, COLOR_WHITE, "** Da bat che do an danh, chuc vu Admin se khong hien trong /v hoac /fc.");
		}
		else
		{
			DeletePVar(playerid, "Undercover");
			SendClientMessageEx(playerid, COLOR_WHITE, "** Da tat che do an danh, chuc vu Admin se hien trong /v hoac /fc.");
		}
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	return true;
}




alias:quickstats("qs")
CMD:quickstats(playerid, params[])
{
	new Float: health, Float: armor;
	GetHealth(playerid, health);
	GetArmour(playerid, armor);

	SendClientMessageEx(playerid, COLOR_GREEN, "---===== ** Chi so %s ** =====---", GetPlayerNameEx(playerid));
	SendClientMessageEx(playerid, COLOR_GRAD1, "** Cap: %d | Bank: %s | Tien: %s | Radio: %dkhz | Canh bao: %d", PlayerInfo[playerid][pLevel],
	number_format(PlayerInfo[playerid][pAccount]), number_format(PlayerInfo[playerid][pCash]), PlayerInfo[playerid][pRadioFreq], PlayerInfo[playerid][pWarns]);
	SendClientMessageEx(playerid, COLOR_GRAD1, "** Mau: %d | Giap: %d", floatround(health), floatround(armor));
	SendClientMessageEx(playerid, COLOR_GREEN, "--------------------------------------------------------------------------------------------------------------------");
	return 1;
}

CMD:fps(playerid, params[])
{
	if(!Bit_State(arrPlayerBits[playerid], bitFPS))
	{
		ShowFPSCounter(playerid);
		Bit_On(arrPlayerBits[playerid], bitFPS);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da bat bo dem FPS.");
	}
	else
	{
		HideFPSCounter(playerid);
		Bit_Off(arrPlayerBits[playerid], bitFPS);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da tat bo dem FPS.");
	}
	return true;
}

CMD:akick(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	new giveplayerid, reason[64];
	if(sscanf(params, "us[64]", giveplayerid, reason)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /akick [player] [reason]");
	if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	new string[128];
	if(PlayerInfo[giveplayerid][pAdmin] > PlayerInfo[playerid][pAdmin])
	{
		format(string, sizeof(string), "AdmCmd: %s bi tu dong kick, ly do: Thu /akick Admin cap cao hon.", GetPlayerNameEx(playerid));
		ABroadCast(COLOR_YELLOW,string,2);
		SetTimerEx("KickEx", 1000, false, "i", playerid);
		return 1;
	}
	format(string, sizeof(string), "AdmCmd: %s(%d) (IP:%s) was admin kicked by %s, reason: %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerIpEx(giveplayerid), GetPlayerNameEx(playerid), reason);
	Log("logs/kick.log", string);
	format(string, sizeof(string), "AdmCmd: %s da bi %s kick, ly do: %s", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid), reason);
	ABroadCast(COLOR_LIGHTRED, string, 2);
	StaffAccountCheck(giveplayerid, GetPlayerIpEx(giveplayerid));
	SendClientMessageEx(giveplayerid, COLOR_LIGHTRED, "AdmCmd: %s da bi Admin kick, ly do: %s", GetPlayerNameEx(giveplayerid), reason);
	SetTimerEx("KickEx", 1000, false, "i", giveplayerid);
	return 1;
}

CMD:togpasscomplexity(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 99999) return 1;
	new string[128];
	if(PassComplexCheck)
	{
		PassComplexCheck = 0;
		format(string, sizeof(string), "AdmCmd: %s da tat kiem tra do phuc tap mat khau.", GetPlayerNameEx(playerid));
		ABroadCast(COLOR_LIGHTRED, string, 2);
		SendClientMessageEx(playerid, COLOR_GRAD2, "Da tat kiem tra do phuc tap mat khau.");
	}
	else
	{
		PassComplexCheck = 1;
		format(string, sizeof(string), "AdmCmd: %s da bat kiem tra do phuc tap mat khau.", GetPlayerNameEx(playerid));
		ABroadCast(COLOR_LIGHTRED, string, 2);
		SendClientMessageEx(playerid, COLOR_GRAD2, "Da bat kiem tra do phuc tap mat khau.");
	}
	Misc_Save();
	return 1;
}

CMD:coordinators(playerid, params[])
{
	if(PlayerInfo[playerid][pSEC] < 1 && PlayerInfo[playerid][pAdmin] < 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	new string[128];
	SendClientMessageEx(playerid, COLOR_GRAD1, "Coordinator dang online:");
	foreach(new i : Player)
	{
		if(PlayerInfo[i][pSEC] > 0)
		{
			if(PlayerInfo[i][pSEC] == 1) format(string, sizeof(string), "Regular Coordinator %s (ID %i)", GetPlayerNameEx(i), i);
			else if(PlayerInfo[i][pSEC] == 2) format(string, sizeof(string), "Senior Coordinator %s (ID %i)", GetPlayerNameEx(i), i);
			else if(PlayerInfo[i][pSEC] == 3) format(string, sizeof(string), "Assistant Chairman %s (ID %i)", GetPlayerNameEx(i), i);
			else if(PlayerInfo[i][pSEC] == 4) format(string, sizeof(string), "Deputy Chairman %s (ID %i)", GetPlayerNameEx(i), i);
			else if(PlayerInfo[i][pSEC] == 5) format(string, sizeof(string), "Chairman %s (ID %i)", GetPlayerNameEx(i), i);
			else format(string, sizeof(string), "Chua ro cap %s (ID %i)", GetPlayerNameEx(i), i);
			SendClientMessageEx(playerid, COLOR_GRAD2, string);
		}
	}
	return 1;
}

CMD:makesec(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pPR] < 1 && PlayerInfo[playerid][pSEC] < 3 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	new ivalue, iTargetID;
	if(sscanf(params, "ui", iTargetID, ivalue)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /makesec [player] [level]");
	if(!IsPlayerConnected(iTargetID)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi choi khong hop le.");
	if(PlayerInfo[iTargetID][pSEC] == ivalue) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do da co cap SEC Coordinator nay.");
	new szRank[128];
	switch(ivalue) {
		case 0: format(szRank, sizeof(szRank), "AdmCmd: %s(%d) has removed %s's(%d) coordinator rank.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID));
		case 1: format(szRank, sizeof(szRank), "AdmCmd: %s(%d) has made %s(%d) a Regular Coordinator.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID));
		case 2: format(szRank, sizeof(szRank), "AdmCmd: %s(%d) has made %s(%d) a Senior Coordinator.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID));
		case 3: format(szRank, sizeof(szRank), "AdmCmd: %s(%d) has made %s(%d) a Assistant Chairman.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID));
		case 4: format(szRank, sizeof(szRank), "AdmCmd: %s(%d) has made %s(%d) a Deputy Chairman.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID));
		case 5: format(szRank, sizeof(szRank), "AdmCmd: %s(%d) has made %s(%d) the Chairman.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID));
		default: format(szRank, sizeof(szRank), "AdmCmd: %s(%d) has made %s(%d) an undefined level(%d) SEC coordinator.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID), ivalue);
	}
	PlayerInfo[iTargetID][pSEC] = ivalue;
	Log("logs/makesec.log", szRank);

	switch(ivalue) {
		case 0: format(szRank, sizeof(szRank), "Chuc vu Coordinator cua ban da bi %s go bo.", GetPlayerNameEx(playerid));
		case 1: format(szRank, sizeof(szRank), "Ban duoc %s bo nhiem lam Regular Coordinator.", GetPlayerNameEx(playerid));
		case 2: format(szRank, sizeof(szRank), "Ban duoc %s bo nhiem lam Senior Coordinator.", GetPlayerNameEx(playerid));
		case 3: format(szRank, sizeof(szRank), "Ban duoc %s bo nhiem lam Assistant Chairman.", GetPlayerNameEx(playerid));
		case 4: format(szRank, sizeof(szRank), "Ban duoc %s bo nhiem lam Deputy Chairman.", GetPlayerNameEx(playerid));
		case 5: format(szRank, sizeof(szRank), "Ban duoc %s bo nhiem lam Chairman.", GetPlayerNameEx(playerid));
		default: format(szRank, sizeof(szRank), "Ban duoc %s bo nhiem lam SEC Coordinator cap chua xac dinh.", GetPlayerNameEx(playerid));
	}
	SendClientMessageEx(iTargetID, COLOR_LIGHTBLUE, szRank);

	switch(ivalue) {
		case 0: format(szRank, sizeof(szRank), "Ban da go chuc vu Coordinator cua %s.", GetPlayerNameEx(iTargetID));
		case 1: format(szRank, sizeof(szRank), "Da bo nhiem %s lam Regular Coordinator.", GetPlayerNameEx(iTargetID));
		case 2: format(szRank, sizeof(szRank), "Da bo nhiem %s lam Senior Coordinator.", GetPlayerNameEx(iTargetID));
		case 3: format(szRank, sizeof(szRank), "Da bo nhiem %s lam Assistant Chairman.", GetPlayerNameEx(iTargetID));
		case 4: format(szRank, sizeof(szRank), "Da bo nhiem %s lam Deputy Chairman.", GetPlayerNameEx(iTargetID));
		case 5: format(szRank, sizeof(szRank), "Da bo nhiem %s lam Chairman.", GetPlayerNameEx(iTargetID));
		default: format(szRank, sizeof(szRank), "Da bo nhiem %s lam Coordinator cap chua xac dinh.", GetPlayerNameEx(iTargetID));
	}
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, szRank);
	return 1;
}

CMD:sechelp(playerid, params[])
{
	if(PlayerInfo[playerid][pSEC] >= 1)
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "--* SEC --* /eventstaff /sec /togsec /coordinators");
		if(PlayerInfo[playerid][pSEC] >= 2) SendClientMessageEx(playerid, COLOR_GRAD2, "--* SEC --* /requestevent /eventhelp");
		if(PlayerInfo[playerid][pSEC] >= 3) SendClientMessageEx(playerid, COLOR_GRAD2, "--* SEC --* /makesec");
	}
	return 1;
}

CMD:togsec(playerid, params[])
{
	if(PlayerInfo[playerid][pSEC] < 1 && PlayerInfo[playerid][pAdmin] < 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	if(GetPVarInt(playerid, "SECChat") == 1)
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "** Ban da tat chat SEC.");
		return SetPVarInt(playerid, "SECChat", 0);
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "** Ban da bat chat SEC.");
		return SetPVarInt(playerid, "SECChat", 1);
	}
}

CMD:sec(playerid, params[])
{
	if(PlayerInfo[playerid][pJailTime] && strfind(PlayerInfo[playerid][pPrisonReason], "[OOC]", true) != -1) return SendClientMessageEx(playerid, COLOR_GREY, "Tu nhan OOC chi duoc noi trong /b");
	if(PlayerInfo[playerid][pSEC] < 1 && PlayerInfo[playerid][pAdmin] < 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	if(GetPVarInt(playerid, "SECChat") == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban da tat chat SEC, dung /togsec de bat lai.");
	if(isnull(params)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /sec [text]");
	new szMessage[128];
	if(PlayerInfo[playerid][pSEC] == 1) format(szMessage, sizeof(szMessage), "* Regular Coordinator %s: %s", GetPlayerNameEx(playerid), params);
	else if(PlayerInfo[playerid][pSEC] == 2) format(szMessage, sizeof(szMessage), "* Senior Coordinator %s: %s", GetPlayerNameEx(playerid), params);
	else if(PlayerInfo[playerid][pSEC] == 3) format(szMessage, sizeof(szMessage), "* Assistant Chairman %s: %s", GetPlayerNameEx(playerid), params);
	else if(PlayerInfo[playerid][pSEC] == 4) format(szMessage, sizeof(szMessage), "* Deputy Chairman %s: %s", GetPlayerNameEx(playerid), params);
	else if(PlayerInfo[playerid][pSEC] >= 5) format(szMessage, sizeof(szMessage), "* Chairman %s: %s", GetPlayerNameEx(playerid), params);
	else if(PlayerInfo[playerid][pAdmin] >= 2) format(szMessage, sizeof(szMessage), "* %s %s: %s", GetAdminRankName(PlayerInfo[playerid][pAdmin]), GetPlayerNameEx(playerid), params);
	else format(szMessage, sizeof(szMessage), "* Chua ro cap %s: %s", GetPlayerNameEx(playerid), params);
	foreach(new i : Player)
	{
		if((PlayerInfo[i][pSEC] >= 1 || PlayerInfo[i][pAdmin] >= 2) && GetPVarInt(i, "SECChat") == 1)
		{
			SendClientMessageEx(i, 0x00FA9AFF, szMessage);
		}
	}
	return 1;
}

CMD:specreset(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 1337)
    {
		SendClientMessageEx(playerid, COLOR_GRAD2, "Phai dat lai thoi gian dac biet qua FTP, xoa cac file trong thu muc /stokens/");
	}
	return 1;
}

CMD:pausespec(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 1337)
    {
    	if(SpecTimer == 1)
     	{
     		SpecTimer = 0;
      		new sString[41 + MAX_PLAYER_NAME];
			format( sString, sizeof( sString ), "AdmCmd: %s da tam dung bo dem dac biet.", GetPlayerNameEx(playerid));
			ABroadCast( COLOR_LIGHTRED, sString, 1338 );
		}
		else
		{
  			SpecTimer = 1;
	    	new sString[41 + MAX_PLAYER_NAME];
    		format( sString, sizeof( sString ), "AdmCmd: %s da bat bo dem dac biet.", GetPlayerNameEx(playerid));
			ABroadCast( COLOR_LIGHTRED, sString, 1338);
		}
	}
	return 1;
}

CMD:checkwdcount(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pWatchdog] >= 3)
	{
		new string[128], adminname[MAX_PLAYER_NAME], tdate[11];
		if(sscanf(params, "s[24]s[11]", adminname, tdate)) return SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /checkwdcount [watchdog name] [date (YYYY-MM-DD)]");
		new giveplayerid = ReturnUser(adminname);
		if(IsPlayerConnected(giveplayerid) && PlayerInfo[giveplayerid][pWatchdog] >= 1)
		{
			mysql_format(MainPipeline, string, sizeof(string), "SELECT SUM(count) FROM `tokens_wd` WHERE `playerid` = %d AND `date` = '%s'", GetPlayerSQLId(giveplayerid), tdate);
			mysql_tquery(MainPipeline, string, "QueryCheckCountFinish", "issi", playerid, GetPlayerNameEx(giveplayerid), tdate, 4);
			mysql_format(MainPipeline, string, sizeof(string), "SELECT `count`, `hour` FROM `tokens_wd` WHERE `playerid` = %d AND `date` = '%s' ORDER BY `hour` ASC", GetPlayerSQLId(giveplayerid), tdate);
			mysql_tquery(MainPipeline, string, "QueryCheckCountFinish", "issi", playerid, GetPlayerNameEx(giveplayerid), tdate, 5);
		}
		else
		{
			new tmpName[MAX_PLAYER_NAME];
			mysql_escape_string(adminname, tmpName);
			mysql_format(MainPipeline, string, sizeof(string), "SELECT `id`, `Username` FROM `accounts` WHERE `Username` = '%s'", tmpName);
			mysql_tquery(MainPipeline, string, "QueryUsernameCheck", "isi", playerid, tdate, 2);
		}
    }
    return 1;
}

/*CMD:edit(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4)
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "You are not authorized to use that command.");
		return 1;
	}

	new string[128], choice[32], amount;
	if(sscanf(params, "s[32]d", choice, amount))
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "|__________________ Edit __________________|");
		SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /edit [name] [amount]");
		SendClientMessageEx(playerid, COLOR_GREY, "Available names: Level, Price");
		SendClientMessageEx(playerid, COLOR_WHITE, "|____________________________________________|");
		return 1;
	}

	for(new i = 0; i < sizeof(HouseInfo); i++)
	{
		if (IsPlayerInRangeOfPoint(playerid,3,HouseInfo[i][hExteriorX], HouseInfo[i][hExteriorY], HouseInfo[i][hExteriorZ]) && GetPlayerInterior(playerid) == HouseInfo[i][hExtIW] && GetPlayerVirtualWorld(playerid) == HouseInfo[i][hExtVW])
		{
			format(string, sizeof(string), "House: %d", i);
			SendClientMessageEx(playerid, COLOR_GRAD2, string);
			if(amount > 0)
			{
				if(strcmp(choice,"level",true) == 0)
				{
					HouseInfo[i][hLevel] = amount;
				}
				else if(strcmp(choice,"price",true) == 0)
				{
					HouseInfo[i][hValue] = amount;
				}
			}
			ReloadHouseText(i);
		}
	}
	return 1;
}*/

CMD:aimpound(playerid, params[]) {
	if(PlayerInfo[playerid][pAdmin] >= 3) {
		new vehicleName[18];
		new iVehTowed, szMessage[128], veh = -1;
		if(sscanf(params, "d", iVehTowed)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /aimpound [carid]");
		if(!GetVehicleModel(iVehTowed)) return SendClientMessageEx(playerid, COLOR_GREY, "Xe bi mat dong bo nen khong the tam giu.");
		foreach(new i: Player) {
			if((veh = GetPlayerVehicle(i, iVehTowed)) != -1) {
				--PlayerCars;
				VehicleSpawned[i]--;
				PlayerVehicleInfo[i][veh][pvImpounded] = 1;
				PlayerVehicleInfo[i][veh][pvSpawned] = 0;
				PlayerVehicleInfo[i][veh][pvFuel] = VehicleFuel[iVehTowed];
				GetVehicleHealth(PlayerVehicleInfo[i][veh][pvId], PlayerVehicleInfo[i][veh][pvHealth]);
				DetachTrailerFromVehicle(iVehTowed);
				DestroyVehicle(iVehTowed);
				if(IsValidDynamicArea(iVehEnterAreaID[iVehTowed])) DestroyDynamicArea(iVehEnterAreaID[iVehTowed]);
				PlayerVehicleInfo[i][veh][pvId] = INVALID_PLAYER_VEHICLE_ID;
				g_mysql_SaveVehicle(playerid, veh);

				strunpack(vehicleName, VehicleName[PlayerVehicleInfo[i][veh][pvModelId] - 400], sizeof(vehicleName));
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da tam giu xe cua %s: %s.", GetPlayerNameEx(i), vehicleName);

				SendClientMessageEx(i, COLOR_LIGHTBLUE, "Xe %s cua ban bi Admin tam giu. Co the chuoc tai DMV o Dillimore.", vehicleName);
				break;
			}
		}
		if((veh = IsDynamicCrateVehicle(iVehTowed)) != -1) {
			if(ValidGroup(CrateVehicle[veh][cvGroupID])) {
				new Float:vHealth;
				GetVehicleHealth(CrateVehicle[veh][cvSpawnID], vHealth);
				CrateVehicle[veh][cvHealth] = vHealth;
				CrateVehicle[veh][cvFuel] = VehicleFuel[CrateVehicle[veh][cvSpawnID]];
				CrateVehicle[veh][cvImpound] = 1;
				DetachTrailerFromVehicle(iVehTowed);
				if(CreateCount(veh) > 0) AnnounceRespawn(CrateVehicle[veh][cvGroupID], "tam giu boi admin", veh, CreateCount(veh));
				DestroyVehicle(CrateVehicle[veh][cvSpawnID]);
				CrateVehicle[veh][cvSpawned] = 0;
				CrateVehicle[veh][cvSpawnID] = INVALID_VEHICLE_ID;
				CrateVehCheck(veh); // Ensure we check for crates!
				SaveCrateVehicle(veh);

				strunpack(vehicleName, VehicleName[CrateVehicle[veh][cvModel] - 400], sizeof(vehicleName));
				format(szMessage, sizeof(szMessage), "* Xe %s cua ban bi Admin tam giu, co the lay lai tu garage. (( /cvstorage ))", vehicleName);
				foreach(new i: Player) {
					if(PlayerInfo[i][pLeader] == CrateVehicle[veh][cvGroupID]) {
						ChatTrafficProcess(i, arrGroupData[CrateVehicle[veh][cvGroupID]][g_hRadioColour] * 256 + 255, szMessage, 12);
					}
				}
				strunpack(vehicleName, VehicleName[CrateVehicle[veh][cvModel] - 400], sizeof(vehicleName));
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da tam giu xe cua %s: %s.", arrGroupData[CrateVehicle[veh][cvGroupID]][g_szGroupName], vehicleName);
			}
			else veh = -1;
		}
		if(veh == -1) {
			SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the tam giu xe nay, da tao lai xe.");
			SetVehicleToRespawn(iVehTowed);
		}
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:stats(playerid, params[]) {
	if(gPlayerLogged{playerid} != 0) ShowStats(playerid, playerid);
	return 1;
}

CMD:changepass(playerid, params[])
{
	if (gPlayerLogged{playerid})
	{
		ShowPlayerDialogEx(playerid, DIALOG_CHANGEPASS, DIALOG_STYLE_INPUT, "Doi mat khau", "Vui long nhap mat khau moi!", "Doi", "Thoat" );
	}
	return 1;
}

CMD:myangle(playerid, params[])
{
    new Float:a;
    GetPlayerFacingAngle(playerid, a);

    SendClientMessageEx(playerid, 0xFFFFFFFF, "Goc cua ban: %0.2f", a);

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    SendClientMessageEx(playerid, 0xFFFFFFFF, "Toa do cua ban: %f, %f, %f", x, y, z);
    return 1;
}



alias:killcheckpoint("kcp")
CMD:killcheckpoint(playerid, params[]) {

	Player_KillCheckPoint(playerid);
	return 1;
}

CMD:flipcoin(playerid, params[]) {

    new
		szMessage[124];

    switch(random(200)) {
        case 0 .. 98: format(szMessage, sizeof(szMessage), "* %s tung dong xu va ra mat ngua.", GetPlayerNameEx(playerid));
		case 100 .. 198: format(szMessage, sizeof(szMessage), "* %s tung dong xu va ra mat sap.", GetPlayerNameEx(playerid));
		default: pc_cmd_flipcoin(playerid, params);
    }
    return ProxDetector(5.0, playerid, szMessage, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
}

CMD:dice(playerid, params[])
{
    new string[84];
    if (PlayerInfo[playerid][pDice])
	{
        new rand = Random(1, 7); 
		format(string, sizeof(string), "{FF8000}** {C2A2DA}%s tung xuc xac va ra %d.", GetPlayerNameEx(playerid), rand);
        ProxDetector(9.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
    }
    else
	{
        SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co xuc xac.");
        return 1;
    }
    return 1;
}

alias:randomnumber("randnum")
CMD:randomnumber(playerid, params[])
{
	new iLower, iUpper;
	if(sscanf(params, "dd", iLower, iUpper)) return SendClientMessage(playerid, COLOR_GRAD2, "CACH DUNG: /randomnumber [minimum] [maximum]");

	if(iLower < 2 || iUpper > 999999) return SendClientMessage(playerid, COLOR_GRAD2, "Gia tri toi thieu phai tu 2 tro len va khong qua 999,999.");

	if((iUpper - iLower) < 2) return SendClientMessage(playerid, COLOR_GRAD2, "Gia tri min va max phai chenh nhau it nhat 2.");

	new val = randomEx(iLower, iUpper + 1);

	format(szMiscArray, sizeof(szMiscArray), "{FF8000}** {C2A2DA}%s chon so ngau nhien - %s.", GetPlayerNameEx(playerid), number_format(val));
    ProxDetector(9.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	return 1;
}



CMD:card(playerid, params[]) {

    new iDeck = random(3),
        iNumber = random(12),
    	szTemp[6],
    	szTemp2[10];

 	szMiscArray[0] = 0;

    switch(iDeck) {
    	case 0: szTemp2 = "co";
		case 1: szTemp2 = "tep";
		case 2: szTemp2 = "bich";
		case 3: szTemp2 = "ro";
	}

	switch(iNumber) {
		case 0: szTemp = "At";
		case 1 .. 9: {
			valstr(szTemp, iNumber+1);
			strcat(szMiscArray, szTemp);
		}
		case 10: szTemp = "Boi";
		case 11: szTemp = "Dam";
		case 12: szTemp = "Gia";
	}

	format(szMiscArray, sizeof(szMiscArray), "* %s rut la bai %s chat %s.", GetPlayerNameEx(playerid), szTemp, szTemp2);
	ProxDetector(5.0, playerid, szMiscArray, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE, 1);

	return 1;
}

CMD:giveeventtokens(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pPR])
	{
		new giveplayerid, amount;

		if (sscanf(params, "ui", giveplayerid, amount)) return SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /giveeventtokens [player] [amount]");
		if (amount == 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "  So luong khong duoc la 0!");
		szMiscArray[0] = 0;
		if (amount < 0)
		{
			if(-amount > PlayerInfo[giveplayerid][pEventTokens]) return SendClientMessageEx(playerid, -1, "So luong can lay vuot qua so token nguoi do co.");
			format(szMiscArray, sizeof(szMiscArray), "Ban da lay %i token cua %s.", -amount, GetPlayerNameEx(giveplayerid));
		}
		else
		{
			format(szMiscArray, sizeof(szMiscArray), "Ban da tang %s %i token.", GetPlayerNameEx(giveplayerid), amount);
		}
		SendClientMessageEx(playerid, COLOR_WHITE, szMiscArray);
		PlayerInfo[giveplayerid][pEventTokens] += amount;
	}
	return 1;
}

CMD:reloadmapping(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 1337)
	{
		SendClientMessageToAllEx(COLOR_LIGHTBLUE, "* Dang tai lai cac filterscript ban do!");
		for(new i, Float: fPlayerPos[3]; i < MAX_PLAYERS; i++)
		{
			GetPlayerPos(i, fPlayerPos[0], fPlayerPos[1], fPlayerPos[2]);
			Player_StreamPrep(i, fPlayerPos[0], fPlayerPos[1], fPlayerPos[2], FREEZE_TIME);
		}
		SendRconCommand("reloadfs mapping/Gang");
		SendRconCommand("reloadfs mapping/PlayerExteriors");
		SendRconCommand("reloadfs mapping/PlayerInteriors");
		SendRconCommand("reloadfs mapping/Server");
	}
	return 1;
}

CMD:resetpgifts(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1337) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay!");

	new query[256];
    format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s da dat qua da nhan cua moi nguoi ve 0. (Qua dang nhap)", GetPlayerNameEx(playerid));
    ABroadCast(COLOR_YELLOW, szMiscArray, 2);

	foreach(new i: Player) {
		PlayerInfo[i][pReceivedPrize] = 0;
	}
	mysql_format(MainPipeline, query, sizeof(query), "UPDATE `accounts` SET `ReceivedPrize` = 0 WHERE `ReceivedPrize` != 0");
	mysql_tquery(MainPipeline, query, "OnQueryFinish", "i", SENDDATA_THREAD);
	SendClientMessageEx(playerid, COLOR_CYAN, "Da dat lai qua da nhan, moi nguoi co the nhan qua khi dang nhap.");
	format(szMiscArray, sizeof(szMiscArray), "%s has reset everyones received gift to 0. (Login Event Gifts)", GetPlayerNameEx(playerid));
	Log("logs/admin.log", szMiscArray);
	return 1;
}
