/*
				 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
				| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
				| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
				| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
				| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
				| $$\  $$$| $$  \ $$        | $$  \ $$| $$
				| $$ \  $$|  $$$$$$/        | $$  | $$| $$
				|__/  \__/ \______/         |__/  |__/|__/

//-------------------------[OnDialogResponse.PWN]--------------------------------


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

// This is the first hooked OnDialogResponse. It's used to check dialog spoofing.
hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
	if(dialogid != iLastDialogID[playerid]) {
		if(dialogid != DIALOG_FS_ELEVATOR1 && dialogid != DIALOG_FS_ELEVATOR2) { // For dialogs called from filterscripts.
			if(PlayerInfo[playerid][pAdmin] == 99999 || dialogid == 32700) return 1;
	    	SendClientMessageEx(playerid, COLOR_LIGHTRED, "[SYSTEM] Hay xoa CLEO hop thoai cua ban.");
            SetTimerEx("KickEx", 1000, false, "i", playerid);
	    }
	}
    iLastDialogID[playerid] = -1;
    return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
	new vehicleName[18], boneName[16], copToyName[24], toyName[24], legacyToyName[24], microItemName[36], restaurantItemName[13], storeItemName[19], drinkName[9];
#if defined SHOPAUTOMATED
	new shopVehicleName[24];
#endif

	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	if(dialogid == DIALOG_DISABLED) return ShowPlayerDialogEx(playerid, DIALOG_DISABLED, DIALOG_STYLE_MSGBOX, "Tai khoan bi vo hieu hoa - Vao http://www.ng-gaming.net/forums", "Tai khoan bi vo hieu hoa vi khong hoat dong hon sau thang.\nHay gui Administrative Request tren dien dan de yeu cau kich hoat lai.", "Dong y", "");
	new sendername[MAX_PLAYER_NAME];
	new string[256];
	szMiscArray[0] = 0;

	// Crash Bug Fix
	if(strfind(inputtext, "%", true) != -1)
	{
		if(dialogid == MAINMENU) ShowMainMenuDialog(playerid, 1);
		if(dialogid == MAINMENU2) ShowMainMenuDialog(playerid, 2);
		if(dialogid == DIALOG_CHANGEPASS2) ShowLoginDialogs(playerid, 0);
		SendClientMessage(playerid, COLOR_GREY, "Ky tu khong hop le, hay thu lai.");
		return 1;
	}
	if(strfind(inputtext, "UPDATE", true) != -1 || strfind(inputtext, "SELECT", true) != -1 || strfind(inputtext, "DROP", true) != -1 || strfind(inputtext, "INSERT", true) != -1 || strfind(inputtext, "SLEEP", true) != -1)
	{
		new logstirng[400];
		format(logstirng, sizeof(logstirng), "%s | Dialog ID: %d | SQL ID: %d", inputtext, dialogid, PlayerInfo[playerid][pId]);
		Log("logs/fquery.log", logstirng);
	}
	if(RegistrationStep[playerid] != 0)
	{
		if(dialogid == REGISTERSEX)
		{
			if(response)
			{
				if(listitem == 0)
				{
					PlayerInfo[playerid][pSex] = 1;
					SendClientMessageEx(playerid, COLOR_YELLOW2, "Da chon nhan vat nam.");
					ShowPlayerDialogEx(playerid, REGISTERMONTH, DIALOG_STYLE_LIST, "{FF0000}Nhan vat sinh thang nao?", "Thang Mot\nThang Hai\nThang Ba\nThang Tu\nThang Nam\nThang Sau\nThang Bay\nThang Tam\nThang Chin\nThang Muoi\nThang Muoi Mot\nThang Muoi Hai", "Gui", "");
					RegistrationStep[playerid] = 2;
				}
				else
				{
					PlayerInfo[playerid][pSex] = 2;
					SendClientMessageEx(playerid, COLOR_YELLOW2, "Da chon nhan vat nu.");
					ShowPlayerDialogEx(playerid, REGISTERMONTH, DIALOG_STYLE_LIST, "{FF0000}Nhan vat sinh thang nao?", "Thang Mot\nThang Hai\nThang Ba\nThang Tu\nThang Nam\nThang Sau\nThang Bay\nThang Tam\nThang Chin\nThang Muoi\nThang Muoi Mot\nThang Muoi Hai", "Gui", "");
					RegistrationStep[playerid] = 2;
				}
			}
			else ShowPlayerDialogEx(playerid, REGISTERSEX, DIALOG_STYLE_LIST, "{FF0000}Nhan vat cua ban la nam hay nu?", "Nam\nNu", "Gui", "");
		}
	}
	if(RegistrationStep[playerid] != 0 || strcmp(PlayerInfo[playerid][pBirthDate], "0000-00-00", true) == 0)
	{
		if(dialogid == REGISTERMONTH)
		{
			if(response)
			{
				new month = listitem+1;
				SetPVarInt(playerid, "RegisterMonth", month);

				new lastdate, stringdiag[410];
				if(listitem == 0 || listitem == 2 || listitem == 4 || listitem == 6 || listitem == 7 || listitem == 9 || listitem == 11) lastdate = 32;
				else if(listitem == 3 || listitem == 5 || listitem == 8 || listitem == 10) lastdate = 31;
				else lastdate = 29;
				for(new x = 1; x < lastdate; x++)
				{
					format(stringdiag, sizeof(stringdiag), "%s%d\n", stringdiag, x);
				}
				ShowPlayerDialogEx(playerid, REGISTERDAY, DIALOG_STYLE_LIST, "{FF0000}Nhan vat cua ban sinh vao ngay nao?", stringdiag, "Gui", "");
			}
			else ShowPlayerDialogEx(playerid, REGISTERMONTH, DIALOG_STYLE_LIST, "{FF0000}Nhan vat sinh thang nao?", "Thang Mot\nThang Hai\nThang Ba\nThang Tu\nThang Nam\nThang Sau\nThang Bay\nThang Tam\nThang Chin\nThang Muoi\nThang Muoi Mot\nThang Muoi Hai", "Gui", "");
		}
		else if(dialogid == REGISTERDAY)
		{
			if(response)
			{
				new setday = listitem+1;
				SetPVarInt(playerid, "RegisterDay", setday);

				new month, day, year, stringdiag[600];
				getdate(year,month,day);
				new startyear = year-100;
				for(new x = startyear; x < year; x++)
				{
					format(stringdiag, sizeof(stringdiag), "%s%d\n", stringdiag, x);
				}
				ShowPlayerDialogEx(playerid, REGISTERYEAR, DIALOG_STYLE_LIST, "{FF0000}Nhan vat sinh nam nao?", stringdiag, "Gui", "");
			}
			else ShowPlayerDialogEx(playerid, REGISTERMONTH, DIALOG_STYLE_LIST, "{FF0000}Nhan vat sinh thang nao?", "Thang Mot\nThang Hai\nThang Ba\nThang Tu\nThang Nam\nThang Sau\nThang Bay\nThang Tam\nThang Chin\nThang Muoi\nThang Muoi Mot\nThang Muoi Hai", "Gui", "");
		}
		else if(dialogid == REGISTERYEAR)
		{
			new month, day, year, stringdiag[600];
			getdate(year,month,day);
			new startyear = year-100;
			if(response)
			{
				new setyear = listitem+startyear;
				format(PlayerInfo[playerid][pBirthDate], 11, "%d-%02d-%02d", setyear, GetPVarInt(playerid, "RegisterMonth"), GetPVarInt(playerid, "RegisterDay"));
				DeletePVar(playerid, "RegisterMonth");
				DeletePVar(playerid, "RegisterDay");
				if(RegistrationStep[playerid] != 0)
				{
					ShowPlayerDialogEx(playerid, REGISTERREF, DIALOG_STYLE_INPUT, "{FF0000}He thong gioi thieu Next Generation Roleplay", "Ban duoc nguoi choi nao gioi thieu den may chu?\nNeu co, hay nhap ten nguoi do ben duoi.\n\nNeu khong ai gioi thieu, ban co the nhan nut bo qua.\n\n{FF0000}Luu y: Ten phai co dau gach duoi (Vi du: FirstName_LastName)", "Nhap", "Bo qua");
				}
				else return SendClientMessageEx(playerid, COLOR_LIGHTRED, "Da dat ngay sinh cua ban.");
			}
			else
			{
				for(new x = startyear; x < year; x++)
				{
					format(stringdiag, sizeof(stringdiag), "%s%d\n", stringdiag, x);
				}
				ShowPlayerDialogEx(playerid, REGISTERYEAR, DIALOG_STYLE_LIST, "{FF0000}Nhan vat sinh nam nao?", stringdiag, "Gui", "");
			}
		}
		else if(dialogid == REGISTERREF)
		{
			if(response)
			{
				if(IsNumericString(inputtext))
				{
					ShowPlayerDialogEx(playerid, REGISTERREF, DIALOG_STYLE_INPUT, "{FF0000}Loi - Ten Roleplay khong hop le", "Ten nay khong dung chuan roleplay\nHay nhap ten roleplay hop le.\n\nVi du: FirstName_LastName", "Nhap", "Bo qua");
					return 1;
				}
				if(strfind(inputtext, "_", true) == -1)
				{
					ShowPlayerDialogEx(playerid, REGISTERREF, DIALOG_STYLE_INPUT, "{FF0000}Loi - Ten Roleplay khong hop le", "Ten nay khong dung chuan roleplay\nHay nhap ten roleplay hop le.\n\nVi du: FirstName_LastName", "Nhap", "Bo qua");
					return 1;
				}
				if(strlen(inputtext) > 20)
				{
					ShowPlayerDialogEx(playerid, REGISTERREF, DIALOG_STYLE_INPUT, "{FF0000}Loi - Ten Roleplay khong hop le", "Ten qua dai\nHay rut ngan ten.\n\nVi du: FirstName_LastName (Toi da 20 ky tu)", "Nhap", "Bo qua");
					return 1;
				}
				if(strcmp(inputtext, GetPlayerNameExt(playerid), true) == 0)
				{
					ShowPlayerDialogEx(playerid, REGISTERREF, DIALOG_STYLE_INPUT, "{FF0000}Loi", "Khong the tu gioi thieu minh.\nNhap ten nguoi gioi thieu hoac nhan 'Bo qua'.\n\nVi du: FirstName_LastName (Toi da 20 ky tu)", "Nhap", "Bo qua");
					return 1;
				}
				for(new sz = 0; sz < strlen(inputtext); sz++)
				{
					if(inputtext[sz] == ' ')
					{
						ShowPlayerDialogEx(playerid, REGISTERREF, DIALOG_STYLE_INPUT, "{FF0000}Loi - Ten Roleplay khong hop le", "Ten nay khong dung chuan roleplay\nHay nhap ten roleplay hop le.\n\nVi du: FirstName_LastName", "Nhap", "Bo qua");
						return 1;
					}
				}

				new
					szQuery[128], szEscape[MAX_PLAYER_NAME];

				mysql_escape_string(inputtext, szEscape);

				format(PlayerInfo[playerid][pReferredBy], MAX_PLAYER_NAME, "%s", szEscape);

				mysql_format(MainPipeline, szQuery, sizeof(szQuery), "SELECT `Username` FROM `accounts` WHERE `Username` = '%s'", szEscape);
				mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "iii", MAIN_REFERRAL_THREAD, playerid, g_arrQueryHandle[playerid]);
			}
			else {
				PlayerInfo[playerid][pTut]++;
				AdvanceTutorial(playerid);
				format(string, sizeof(string), "Nobody");
				strmid(PlayerInfo[playerid][pReferredBy], string, 0, strlen(string), MAX_PLAYER_NAME);
				SendClientMessageEx(playerid, COLOR_LIGHTRED, "Cam on ban da dien du thong tin, bay gio co the bat dau huong dan!");
				RegistrationStep[playerid] = 3;
				SetPlayerVirtualWorld(playerid, 0);
				ClearChatbox(playerid);
				Streamer_UpdateEx(playerid, 1607.0160,-1510.8218,207.4438);
				SetPlayerPos(playerid, 1607.0160,-1510.8218,-10.0);
				SetPlayerCameraPos(playerid, 1850.1813,-1765.7552,81.9271);
				SetPlayerCameraLookAt(playerid, 1607.0160,-1510.8218,207.4438);
			}
		}
	}
	switch(dialogid)
	{
		case DIALOG_911PICKLOCK: if(response)
		{
			new Float: carPos[3];
			if(PlayerVehicleInfo[playerid][listitem][pvId] > INVALID_PLAYER_VEHICLE_ID) {
				if(PlayerVehicleInfo[playerid][listitem][pvAlarmTriggered]) {
					GetVehiclePos(PlayerVehicleInfo[playerid][listitem][pvId], carPos[0], carPos[1], carPos[2]);
					new zone[MAX_ZONE_NAME], mainzone[MAX_ZONE_NAME];
					Get3DZone(carPos[0], carPos[1], carPos[2], zone, sizeof(zone));
					Get2DMainZone(carPos[0], carPos[1], mainzone, sizeof(mainzone));
					SendClientMessageEx(playerid, COLOR_YELLOW, "Xe cua ban nam tai %s(%s).", zone, mainzone);
					format(string, sizeof(string), "Nghi ngo trom xe, %s(%d)", GetVehicleName(PlayerVehicleInfo[playerid][listitem][pvId]), PlayerVehicleInfo[playerid][listitem][pvId]);
					SendCallToQueue(playerid, string, zone, mainzone, 4, PlayerVehicleInfo[playerid][listitem][pvId]);
					SetPVarInt(playerid, "Has911Call", 1);
					SendClientMessageEx(playerid, TEAM_CYAN_COLOR, "Dispatch: Da bao cho cac don vi trong khu vuc.");
					SendClientMessageEx(playerid, TEAM_CYAN_COLOR, "Cam on ban da bao vu viec nay");
				}
				else {
					SetPVarInt(playerid, "ConfirmReport", listitem);
					ShowPlayerDialogEx(playerid, DIALOG_911PICKLOCK2, DIALOG_STYLE_MSGBOX, "{FFFB00}Canh bao - Can xac nhan", "Ban chac chan muon bao cao vu trom xe nay?\nBao dong cua xe chua duoc kich hoat.\nLuu y day la vu trom xe {FF8400}Dang dien ra", "Xac nhan", "Huy");
				}
			}
			else if(PlayerVehicleInfo[playerid][listitem][pvImpounded]) SendClientMessageEx(playerid, COLOR_WHITE, "Khong the bao cao xe bi tam giu. Hay den DMV tai Dillimore de chuoc xe.");
			else if(PlayerVehicleInfo[playerid][listitem][pvDisabled] == 1) SendClientMessageEx(playerid, COLOR_WHITE, "Khong the dung xe bi khoa do cap VIP cua ban (han che xe).");
			else if(PlayerVehicleInfo[playerid][listitem][pvSpawned] == 0) SendClientMessageEx(playerid, COLOR_WHITE, "Khong the bao cao xe da cat. Dung /vstorage de lay xe ra.");
			else SendClientMessageEx(playerid, COLOR_WHITE, "Khong the theo doi xe khong ton tai.");
		}
		case DIALOG_911PICKLOCK2: {
			if(response) {
				new Float: carPos[3];
				GetVehiclePos(PlayerVehicleInfo[playerid][listitem][pvId], carPos[0], carPos[1], carPos[2]);
				new zone[MAX_ZONE_NAME], mainzone[MAX_ZONE_NAME];
				Get3DZone(carPos[0], carPos[1], carPos[2], zone, sizeof(zone));
				Get2DMainZone(carPos[0], carPos[1], mainzone, sizeof(mainzone));
				SendClientMessageEx(playerid, COLOR_YELLOW, "Xe cua ban nam tai %s(%s).", zone, mainzone);
				format(string, sizeof(string), "Nghi ngo trom xe, %s(%d)", GetVehicleName(PlayerVehicleInfo[playerid][listitem][pvId]), PlayerVehicleInfo[playerid][listitem][pvId]);
				SendCallToQueue(playerid, string, zone, mainzone, 4, PlayerVehicleInfo[playerid][listitem][pvId]);
				SetPVarInt(playerid, "Has911Call", 1);
				SendClientMessageEx(playerid, TEAM_CYAN_COLOR, "Dispatch: Da bao cho cac don vi trong khu vuc.");
				SendClientMessageEx(playerid, TEAM_CYAN_COLOR, "Cam on ban da bao vu viec nay");
			}
			DeletePVar(playerid, "ConfirmReport");
		}

		case DIALOG_NATION_CHECK:
		{
			if(response) {
				PlayerInfo[playerid][pNation] = listitem;
				switch(listitem) {
					case 0: SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da la cong dan San Andreas.");
					case 1: SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da la cong dan New Robada.");
				}
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GRAD1, "Ban chua tra loi, dang chon quoc gia ngau nhien...");
				new rand = random(2);
				PlayerInfo[playerid][pNation] = rand;
				switch(rand) {
					case 0: SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da la cong dan San Andreas.");
					case 1: SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da la cong dan New Robada.");
				}
			}
		}

		case BIGEARS3:
		{
			if(response) {
				new group = ListItemTrackId[playerid][listitem];
				if (arrGroupData[group][g_iGroupType] == GROUP_TYPE_CONTRACT && PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1)
				{
					SendClientMessage(playerid, COLOR_WHITE, "Chi Senior Admins+ duoc su dung tinh nang nay.");
					return 1;
				}
				SetPVarInt(playerid, "BigEar", 5);
				SetPVarInt(playerid, "BigEarOOCGroup", group);
			}
			else ShowPlayerDialogEx(playerid, BIGEARS, DIALOG_STYLE_LIST, "Hay chon vat pham de tiep tuc", "Chat toan may chu\nOOC Chat\nIC Chat\nChat to chuc\nNhom OOC\nNguoi choi\nTin nhan rieng\nTat Bigears", "Chon", "Huy");
		}
		case BIGEARS: if(response) switch(listitem) {
			case 0: {
				SetPVarInt(playerid, "BigEar", 1);
				SendClientMessage(playerid, COLOR_WHITE, "Da chon chat toan may chu, ban se thay tat ca tin nhan.");
			}
			case 1: {
				SetPVarInt(playerid, "BigEar", 2);
				SendClientMessage(playerid, COLOR_WHITE, "Da chon OOC Chat, ban se thay moi tin nhan OOC(/b) tren may chu.");
			}
			case 2: {
				SetPVarInt(playerid, "BigEar", 3);
				SendClientMessage(playerid, COLOR_WHITE, "Da chon IC Chat, ban se thay moi tin nhan IC (gom /me's va /do's) tren may chu.");
			}
			case 3: {
				Group_ListGroups(playerid, BIGEARS2);
			}
			case 4: {
				Group_ListGroups(playerid, BIGEARS3);
			}
			case 5: {
				ShowPlayerDialogEx(playerid, BIGEARS4, DIALOG_STYLE_INPUT, "{3399FF}Big Ears Nguoi choi", "Nhap ten hoac ID nguoi choi muon theo doi bang Big Ears", "Chon", "Quay lai");
			}
			case 6: {
				ShowPlayerDialogEx(playerid, BIGEARS5, DIALOG_STYLE_INPUT, "{3399FF}Big Ears | Tin nhan rieng", "Nhap ten hoac ID nguoi choi muon theo doi bang Big Ears", "Chon", "Quay lai");
			}
			case 7: {
				DeletePVar(playerid, "BigEar");
				DeletePVar(playerid, "BigEarGroup");
				DeletePVar(playerid, "BigEarPlayer");
				DeletePVar(playerid, "BigEarOOCGroup");
				DeletePVar(playerid, "BigEarPM");
				DeletePVar(playerid, "BigEarPlayerPM");
				rBigEarT[playerid] = 0;
				SendClientMessage(playerid, COLOR_WHITE, "Da tat Bigears, ban se khong con thay tin nhan theo doi.");
			}
		}
		case BIGEARS4: {
			if(response) {
				new giveplayerid;
				if(sscanf(inputtext, "u", giveplayerid) || PlayerInfo[giveplayerid][pAdmin] > PlayerInfo[playerid][pAdmin]) {
					ShowPlayerDialogEx(playerid, BIGEARS4, DIALOG_STYLE_INPUT, "{3399FF}Big Ears Nguoi choi", "Loi - Nhap ten hoac ID nguoi choi muon theo doi bang Big Ears", "Chon", "Quay lai");
					return 1;
				}
				SetPVarInt(playerid, "BigEar", 6);
				SetPVarInt(playerid, "BigEarPlayer", giveplayerid);
				SendClientMessageEx(playerid, COLOR_WHITE, "Ban se thay tat ca tin nhan cua nguoi choi nay.");
			}
			else ShowPlayerDialogEx(playerid, BIGEARS, DIALOG_STYLE_LIST, "Hay chon vat pham de tiep tuc", "Chat toan may chu\nOOC Chat\nIC Chat\nChat to chuc\nNhom OOC\nNguoi choi\nTin nhan rieng\nTat Bigears", "Chon", "Huy");
		}
		case BIGEARS5: {
			if(response) {
				new giveplayerid;
				if(sscanf(inputtext, "u", giveplayerid) || PlayerInfo[giveplayerid][pAdmin] > PlayerInfo[playerid][pAdmin]) {
					ShowPlayerDialogEx(playerid, BIGEARS5, DIALOG_STYLE_INPUT, "{3399FF}Big Ears | Tin nhan rieng", "Loi - Nhap ten hoac ID nguoi choi muon theo doi bang Big Ears", "Chon", "Quay lai");
					return 1;
				}
				SetPVarInt(playerid, "BigEarPM", 1);
				SetPVarInt(playerid, "BigEarPlayerPM", giveplayerid);
				SendClientMessageEx(playerid, COLOR_WHITE, "Ban se nhan moi tin nhan rieng cua %s", GetPlayerNameEx(giveplayerid));
			}
			else ShowPlayerDialogEx(playerid, BIGEARS, DIALOG_STYLE_LIST, "Hay chon vat pham de tiep tuc", "Chat toan may chu\nOOC Chat\nIC Chat\nChat to chuc\nNhom OOC\nNguoi choi\nTin nhan rieng\nTat Bigears", "Chon", "Huy");
		}
		case BIGEARS2: {
			if(response) {
				new group = ListItemTrackId[playerid][listitem];
				if (arrGroupData[group][g_iGroupType] == GROUP_TYPE_CONTRACT && PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1)
				{
					SendClientMessage(playerid, COLOR_WHITE, "Chi Senior Admins+ duoc su dung tinh nang nay.");
					return 1;
				}
				SetPVarInt(playerid, "BigEar", 4);
				SetPVarInt(playerid, "BigEarGroup", group);
			}
			else ShowPlayerDialogEx(playerid, BIGEARS, DIALOG_STYLE_LIST, "Hay chon vat pham de tiep tuc", "Chat toan may chu\nOOC Chat\nIC Chat\nChat to chuc\nNhom OOC\nNguoi choi\nTin nhan rieng\nTat Bigears", "Chon", "Huy");
		}
		case DIALOG_DELETECAR:
		{
			if(response)
			{
				if(GetPVarType(playerid, "vDel")) {

					new
						i = GetPVarInt(playerid, "vDel");

					if(PlayerVehicleInfo[playerid][i][pvId] != INVALID_PLAYER_VEHICLE_ID && !PlayerVehicleInfo[playerid][i][pvImpounded] && PlayerVehicleInfo[playerid][i][pvSpawned]) {

						switch(PlayerVehicleInfo[playerid][i][pvModelId]) {
							case 519, 553, 508: {
								if(IsValidDynamicArea(iVehEnterAreaID[PlayerVehicleInfo[playerid][i][pvId]])) DestroyDynamicArea(iVehEnterAreaID[PlayerVehicleInfo[playerid][i][pvId]]);
							}
						}

						DestroyVehicle(PlayerVehicleInfo[playerid][i][pvId]);
						--PlayerCars;
						VehicleSpawned[playerid]--;
					}
					if(PlayerVehicleInfo[playerid][i][pvTicket] != 0)
					{
						GivePlayerCash(playerid, -PlayerVehicleInfo[playerid][i][pvTicket]);
						OnPlayerStatsUpdate(playerid);
						SendClientMessageEx(playerid, COLOR_WHITE, "Xe cua ban con tien phat chua nop. Ban da bi thu so tien phat ($%s).", number_format(PlayerVehicleInfo[playerid][i][pvTicket]));
					}

					strunpack(vehicleName, VehicleName[PlayerVehicleInfo[playerid][i][pvModelId] - 400], sizeof(vehicleName));
					format(szMiscArray, sizeof(szMiscArray), "[DELETECAR] %s (IP: %s) (SQLID: %d) has deleted their %s (%d) (SQLID: %d).", GetPlayerNameEx(playerid), GetPlayerIpEx(playerid), GetPlayerSQLId(playerid), vehicleName, PlayerVehicleInfo[playerid][i][pvModelId], PlayerVehicleInfo[playerid][i][pvSlotId]);
					Log("logs/playervehicle.log", szMiscArray);

					PlayerVehicleInfo[playerid][i][pvId] = 0;
					PlayerVehicleInfo[playerid][i][pvModelId] = 0;
					PlayerVehicleInfo[playerid][i][pvPosX] = 0.0;
					PlayerVehicleInfo[playerid][i][pvPosY] = 0.0;
					PlayerVehicleInfo[playerid][i][pvPosZ] = 0.0;
					PlayerVehicleInfo[playerid][i][pvPosAngle] = 0.0;
					PlayerVehicleInfo[playerid][i][pvLock] = 0;
					PlayerVehicleInfo[playerid][i][pvLocksLeft] = 0;
					PlayerVehicleInfo[playerid][i][pvLocked] = 0;
					PlayerVehicleInfo[playerid][i][pvPaintJob] = -1;
					PlayerVehicleInfo[playerid][i][pvColor1] = 0;
					PlayerVehicleInfo[playerid][i][pvColor2] = 0;
					PlayerVehicleInfo[playerid][i][pvPrice] = 0;
					PlayerVehicleInfo[playerid][i][pvTicket] = 0;
					for(new j = 0; j < 3; j++)
					{
						PlayerVehicleInfo[playerid][i][pvWeapons][j] = 0;
					}
					PlayerVehicleInfo[playerid][i][pvImpounded] = 0;
					PlayerVehicleInfo[playerid][i][pvSpawned] = 0;
					PlayerVehicleInfo[playerid][i][pvVW] = 0;
					PlayerVehicleInfo[playerid][i][pvInt] = 0;
					PlayerVehicleInfo[playerid][i][pvAlarm] = 0;
					PlayerVehicleInfo[playerid][i][pvAlarmTriggered] = 0;
					PlayerVehicleInfo[playerid][i][pvBeingPickLocked] = 0;
					if(PlayerVehicleInfo[playerid][i][pvAllowedPlayerId] != INVALID_PLAYER_ID)
					{
						PlayerInfo[PlayerVehicleInfo[playerid][i][pvAllowedPlayerId]][pVehicleKeys] = INVALID_PLAYER_VEHICLE_ID;
						PlayerInfo[PlayerVehicleInfo[playerid][i][pvAllowedPlayerId]][pVehicleKeysFrom] = INVALID_PLAYER_ID;
						PlayerVehicleInfo[playerid][i][pvAllowedPlayerId] = INVALID_PLAYER_ID;
					}
					GiveKeysTo[playerid] = INVALID_PLAYER_ID;
					DeletePVar(playerid, "vDel");

					new query[128];
					mysql_format(MainPipeline, query, sizeof(query), "DELETE FROM `vehicles` WHERE `id` = '%d'", PlayerVehicleInfo[playerid][i][pvSlotId]);
					mysql_tquery(MainPipeline, query, "OnQueryFinish", "ii", SENDDATA_THREAD, playerid);

					PlayerVehicleInfo[playerid][i][pvSlotId] = 0;

					return SendClientMessageEx(playerid, COLOR_WHITE, "Xe cua ban da bi xoa vinh vien.");
				}

				new
					szDialogStr[256];

				SetPVarInt(playerid, "vDel", listitem);
				if(PlayerVehicleInfo[playerid][listitem][pvTicket] != 0) {
					strunpack(vehicleName, VehicleName[PlayerVehicleInfo[playerid][listitem][pvModelId] - 400], sizeof(vehicleName));
					format(szDialogStr, sizeof(szDialogStr), "{FFFFFF}Xe {FF0000}%s{FFFFFF} cua ban se bi {FF0000}xoa vinh vien{FFFFFF}.\n\n{FF0000}Xe nay con tien phat chua nop.\n{FFFFFF}Ban se bi thu {FF0000}$%s{FFFFFF} khi xoa xe.\n\nBan co the xac nhan hoac huy xoa.", vehicleName, number_format(PlayerVehicleInfo[playerid][listitem][pvTicket]));
				}
				else {
					strunpack(vehicleName, VehicleName[PlayerVehicleInfo[playerid][listitem][pvModelId] - 400], sizeof(vehicleName));
					format(szDialogStr, sizeof(szDialogStr), "{FFFFFF}Xe {FF0000}%s{FFFFFF} cua ban se bi {FF0000}xoa vinh vien{FFFFFF}.\n\nBan co the xac nhan hoac huy xoa.", vehicleName);
				}
				return ShowPlayerDialogEx(playerid, DIALOG_DELETECAR, DIALOG_STYLE_MSGBOX, "Xoa xe", szDialogStr, "Xoa", "Huy");
			}
			else return DeletePVar(playerid, "vDel");
		}
	}
	if(dialogid == RCPINTRO)
	{
		if (response)
		{
			new msgstring[218];
			format(msgstring,sizeof(msgstring),"\tCac buoc tao checkpoint,\n1.- Chon vi tri checkpoint.\n2.- Xac nhan vi tri checkpoint.\n3.- Dat kich thuoc checkpoint.\n4.- Dat loai checkpoint.");
			ShowPlayerDialogEx(playerid,RCPINTRO2,DIALOG_STYLE_MSGBOX,"Huong dan checkpoint dua",msgstring,"Bat dau","Huy");
		}
		else
		{
			format(string,sizeof(string),"Tao checkpoint...\nSua checkpoint da co\nTat xem truoc checkpoint");
			ShowPlayerDialogEx(playerid,RCPCHOOSE,DIALOG_STYLE_LIST,"Cau hinh checkpoint dua",string,"Dong y","Da xong!");
			ConfigEventCPId[playerid] = 0;
			ConfigEventCPs[playerid][1] = 0;
		}
	}
	if(dialogid == RCPINTRO2)
	{
		if (response)
		{
			format(string,sizeof(string),"Tao checkpoint...\nSua checkpoint da co\nTat xem truoc checkpoint");
			ShowPlayerDialogEx(playerid,RCPCHOOSE,DIALOG_STYLE_LIST,"Cau hinh checkpoint dua",string,"Dong y","Da xong!");
			ConfigEventCPId[playerid] = 0;
			ConfigEventCPs[playerid][1] = 0;
		}
	}
	if(dialogid == RCPCHOOSE)
	{
		if (response && ConfigEventCPs[playerid][0] == 1)
		{
			if(listitem == 0) // Create a checkpoint
			{
				if(ConfigEventCPs[playerid][1] != 0) return SendClientMessageEx(playerid, COLOR_RED, "LOI: Khong the tao checkpoint moi khi dang sua checkpoint khac.");
				if(ConfigEventCPId[playerid] >= 20) {
					ConfigEventCPs[playerid][0] = 0;
					ConfigEventCPs[playerid][1] = 0;
					ConfigEventCPId[playerid] = 0;
					return SendClientMessageEx(playerid, COLOR_RED, "LOI: Da dat gioi han checkpoint(20), khong the tao them.");
				}
				new i;
				for(i = 0; i < 20; i++)
				{
					if(EventRCPU[i] == 0) break;
				}
				if(i >= 20) {
					ConfigEventCPs[playerid][0] = 0;
					ConfigEventCPs[playerid][1] = 0;
					ConfigEventCPId[playerid] = 0;
					return SendClientMessageEx(playerid, COLOR_RED, "LOI: Da dat gioi han checkpoint(20), khong the tao them.");
				}
				ConfigEventCPId[playerid] = i;
				ConfigEventCPs[playerid][1] = 1;
				ConfigEventCPs[playerid][2] = 1;
				SendClientMessageEx(playerid, COLOR_WHITE, "Ban dang tao checkpoint moi, hay chon vi tri cho checkpoint.");
				SendClientMessageEx(playerid, COLOR_YELLOW, "LUU Y: Khi chon dung vi tri, hay nhan nut ban de luu.");
				SendClientMessageEx(playerid, COLOR_YELLOW, "LUU Y: Nhan nut ngam de huy thao tac.");
			}
			else if(listitem == 1) // Edit an existing checkpoint IN PROCESS
			{
				if(ConfigEventCPs[playerid][1] != 0) return SendClientMessageEx(playerid, COLOR_RED, "LOI: Khong the sua checkpoint khi dang sua checkpoint khac.");
				new bigstring[798], totalrcps;
				for(new i = 0; i < 20; i++)
				{
					if(EventRCPU[i] > 0) {
						switch(EventRCPT[i]) {
							case 1:
							{
								format(bigstring, sizeof(bigstring), "%s(RCPID:%i) Checkpoint dau", bigstring, i+1);
								format(bigstring, sizeof(bigstring), "%s\n", bigstring);
							}
							case 2:
							{
								format(bigstring, sizeof(bigstring), "%s(RCPID:%i) Checkpoint thuong", bigstring, i+1);
								format(bigstring, sizeof(bigstring), "%s\n", bigstring);
							}
							case 3:
							{
								format(bigstring, sizeof(bigstring), "%s(RCPID:%i) Checkpoint tiep nuoc", bigstring, i+1);
								format(bigstring, sizeof(bigstring), "%s\n", bigstring);
							}
							case 4:
							{
								format(bigstring, sizeof(bigstring), "%s(RCPID:%i) Checkpoint cuoi", bigstring, i+1);
								format(bigstring, sizeof(bigstring), "%s\n", bigstring);
							}
							default:
							{
								format(bigstring, sizeof(bigstring), "%s(RCPID:%i) CP chua ro loai", bigstring, i+1);
								format(bigstring, sizeof(bigstring), "%s\n", bigstring);
							}
						}
						ListItemRCPId[playerid][totalrcps] = i;
						totalrcps++;
					}
				}
				if(totalrcps == 0) return SendClientMessageEx(playerid, COLOR_RED, "LOI: Chua tao checkpoint nao.");
				ShowPlayerDialogEx(playerid, RCPEDITMENU, DIALOG_STYLE_LIST,"Chon checkpoint can sua:", bigstring, "Sua", "Huy");
			}
			else if(listitem == 2) // Remove view of checkpoint
			{
				DisablePlayerCheckpoint(playerid);
				SendClientMessageEx(playerid, COLOR_WHITE, "Da tat checkpoint dua cua ban.");
			}
		}
	}
	if(dialogid == RCPEDITMENU)
	{
		ConfigEventCPs[playerid][2] = 0;
		ConfigEventCPId[playerid] = ListItemRCPId[playerid][listitem];
		ConfigEventCPs[playerid][1] = 0;
		DisablePlayerCheckpoint(playerid);
		if(EventRCPT[ConfigEventCPId[playerid]] == 1) {
			SetPlayerCheckpoint(playerid, EventRCPX[ConfigEventCPId[playerid]], EventRCPY[ConfigEventCPId[playerid]], EventRCPZ[ConfigEventCPId[playerid]], EventRCPS[ConfigEventCPId[playerid]]);
		}
		else if(EventRCPT[ConfigEventCPId[playerid]] == 4) {
			SetPlayerCheckpoint(playerid, EventRCPX[ConfigEventCPId[playerid]], EventRCPY[ConfigEventCPId[playerid]], EventRCPZ[ConfigEventCPId[playerid]], EventRCPS[ConfigEventCPId[playerid]]);
		}
		else {
			SetPlayerCheckpoint(playerid, EventRCPX[ConfigEventCPId[playerid]], EventRCPY[ConfigEventCPId[playerid]], EventRCPZ[ConfigEventCPId[playerid]], EventRCPS[ConfigEventCPId[playerid]]);
		}
		format(string,sizeof(string),"Sua checkpoint(ID:%d)", ConfigEventCPId[playerid]);
		ShowPlayerDialogEx(playerid,RCPEDITMENU2,DIALOG_STYLE_LIST,string,"Sua vi tri\nSua kich thuoc\nSua loai\nXem checkpoint","Dong y","Da xong!");
	}
	if(dialogid == RCPEDITMENU2)
	{
		if (response)
		{
			if(listitem == 0) // Edit position
			{
				ConfigEventCPs[playerid][1] = 1;
				SendClientMessageEx(playerid, COLOR_WHITE, "Ban dang sua vi tri checkpoint, hay chon vi tri moi cho checkpoint.");
				SendClientMessageEx(playerid, COLOR_WHITE, "LUU Y: Nhan nut FIRE de luu vi tri. Nhan nut AIM de huy.");
			}
			else if(listitem == 1) // edit size
			{
				ConfigEventCPs[playerid][1] = 3;
				format(string,sizeof(string),"Kich co checkpoint %d", ConfigEventCPId[playerid]);
				ShowPlayerDialogEx(playerid,RCPSIZE,DIALOG_STYLE_INPUT,string,"Chon kich thuoc checkpoint.\nDe xuat: 5.0","Dong y","Huy");
			}
			else if(listitem == 2) // edit type
			{
				ConfigEventCPs[playerid][1] = 4;
				ShowPlayerDialogEx(playerid,RCPTYPE,DIALOG_STYLE_LIST,"Danh sach loai checkpoint dua","1.- Checkpoint xuat phat\n2.- Checkpoint thuong\n3.- Tram tiep nuoc\n4.- Checkpoint ve dich","Dong y","Huy");
			}
			else if(listitem == 3) // view checkpoint
			{
				if(EventRCPT[ConfigEventCPId[playerid]] == 1) {
					SetPlayerCheckpoint(playerid, EventRCPX[ConfigEventCPId[playerid]], EventRCPY[ConfigEventCPId[playerid]], EventRCPZ[ConfigEventCPId[playerid]], EventRCPS[ConfigEventCPId[playerid]]);
				}
				else if(EventRCPT[ConfigEventCPId[playerid]] == 4) {
					SetPlayerCheckpoint(playerid, EventRCPX[ConfigEventCPId[playerid]], EventRCPY[ConfigEventCPId[playerid]], EventRCPZ[ConfigEventCPId[playerid]], EventRCPS[ConfigEventCPId[playerid]]);
				}
				else {
					SetPlayerCheckpoint(playerid, EventRCPX[ConfigEventCPId[playerid]], EventRCPY[ConfigEventCPId[playerid]], EventRCPZ[ConfigEventCPId[playerid]], EventRCPS[ConfigEventCPId[playerid]]);
				}
				SetPlayerPos(playerid, EventRCPX[ConfigEventCPId[playerid]], EventRCPY[ConfigEventCPId[playerid]], EventRCPZ[ConfigEventCPId[playerid]]);
				SendClientMessageEx(playerid, COLOR_WHITE, "Da bat xem truoc checkpoint, hay buoc ra ngoai de xem ro.");
			}
		}
	}
	if(dialogid == RCPTYPE)
	{
		if (response && ConfigEventCPs[playerid][0] == 1)
		{
			if(listitem == 0) // Start checkpoint
			{
				EventRCPT[ConfigEventCPId[playerid]] = 1;
				DisablePlayerCheckpoint(playerid);
				ConfigEventCPs[playerid][1] = 0;
				ConfigEventCPs[playerid][0] = 0;
				SetPlayerCheckpoint(playerid, EventRCPX[ConfigEventCPId[playerid]], EventRCPY[ConfigEventCPId[playerid]], EventRCPZ[ConfigEventCPId[playerid]], EventRCPS[ConfigEventCPId[playerid]]);
			}
			else if(listitem == 1) // Normal Checkpoint
			{
				EventRCPT[ConfigEventCPId[playerid]] = 2;
				DisablePlayerCheckpoint(playerid);
				ConfigEventCPs[playerid][1] = 0;
				ConfigEventCPs[playerid][0] = 0;
				SetPlayerCheckpoint(playerid, EventRCPX[ConfigEventCPId[playerid]], EventRCPY[ConfigEventCPId[playerid]], EventRCPZ[ConfigEventCPId[playerid]], EventRCPS[ConfigEventCPId[playerid]]);
			}
			else if(listitem == 2) // Watering Checkpoint
			{
				EventRCPT[ConfigEventCPId[playerid]] = 3;
				DisablePlayerCheckpoint(playerid);
				ConfigEventCPs[playerid][1] = 0;
				ConfigEventCPs[playerid][0] = 0;
				SetPlayerCheckpoint(playerid, EventRCPX[ConfigEventCPId[playerid]], EventRCPY[ConfigEventCPId[playerid]], EventRCPZ[ConfigEventCPId[playerid]], EventRCPS[ConfigEventCPId[playerid]]);
			}
			else if(listitem == 3) // Finish Checkpoint
			{
				EventRCPT[ConfigEventCPId[playerid]] = 4;
				DisablePlayerCheckpoint(playerid);
				ConfigEventCPs[playerid][1] = 0;
				ConfigEventCPs[playerid][0] = 0;
				SetPlayerCheckpoint(playerid, EventRCPX[ConfigEventCPId[playerid]], EventRCPY[ConfigEventCPId[playerid]], EventRCPZ[ConfigEventCPId[playerid]], EventRCPS[ConfigEventCPId[playerid]]);
			}
		}
	}
	if(dialogid == RCPSIZE)
	{
		if(response && ConfigEventCPs[playerid][0] == 1)
		{
			if(strlen(inputtext) < 1)
			{
				format(string,sizeof(string),"Kich co checkpoint %d", ConfigEventCPId[playerid]);
				ShowPlayerDialogEx(playerid,RCPSIZE,DIALOG_STYLE_INPUT,string,"Nhap kich thuoc checkpoint bang so","Dong y","Huy");
				return 1;
			}
			new Float: rcpsize;
			rcpsize = floatstr(inputtext);
			if(rcpsize < 1.0 && rcpsize > 15.0) return 1;
			EventRCPS[ConfigEventCPId[playerid]] = rcpsize;
			SendClientMessage(playerid, COLOR_WHITE, "Da doi kich thuoc, dang cap nhat xem truoc...");
			/*if(EventRCPT[ConfigEventCPId[playerid]] == 1) {
				DisablePlayerCheckpoint(playerid);
				SetPlayerCheckpoint(playerid, EventRCPX[ConfigEventCPId[playerid]], EventRCPY[ConfigEventCPId[playerid]], EventRCPZ[ConfigEventCPId[playerid]], EventRCPS[ConfigEventCPId[playerid]]);
			}
			else if(EventRCPT[ConfigEventCPId[playerid]] == 4) {
				DisablePlayerCheckpoint(playerid);
				SetPlayerCheckpoint(playerid, EventRCPX[ConfigEventCPId[playerid]], EventRCPY[ConfigEventCPId[playerid]], EventRCPZ[ConfigEventCPId[playerid]], EventRCPS[ConfigEventCPId[playerid]]);
			}*/
			DisablePlayerCheckpoint(playerid);
			if(ConfigEventCPs[playerid][2] == 1) {
				ConfigEventCPs[playerid][1] = 4;
				ShowPlayerDialogEx(playerid,RCPTYPE,DIALOG_STYLE_LIST,"Danh sach loai checkpoint dua","1.- Checkpoint xuat phat\n2.- Checkpoint thuong\n3.- Tram tiep nuoc\n4.- Checkpoint ve dich","Dong y","Huy");
			}
			else
			{
				 SetTimerEx("RFLCheckpointu", 1000, false, "i", playerid);
				//SetPlayerCheckpoint(playerid, EventRCPX[ConfigEventCPId[playerid]], EventRCPY[ConfigEventCPId[playerid]], EventRCPZ[ConfigEventCPId[playerid]], EventRCPS[ConfigEventCPId[playerid]]);
			}
		}
	}
	if(dialogid == UNMODCARMENU)
	{
		if (response)
		{
			new count = GetPVarInt(playerid, "modCount");
			new d;
			for(new z = 0 ; z < MAX_PLAYERVEHICLES; z++)
			{
				if(IsPlayerInVehicle(playerid, PlayerVehicleInfo[playerid][z][pvId]))
				{
					d = z;
					break;
				}
			}
			for (new i = 0; i < count; i++)
			{
				if(listitem == i)
				{
					format(string, sizeof(string), "partList%i", i);
					new partID = GetPVarInt(playerid, string);
					if (partID == 999)
					{
						for(new f = 0 ; f < MAX_MODS; f++)
						{
							SetPVarInt(playerid, "unMod", 1);
							RemoveVehicleComponent(PlayerVehicleInfo[playerid][d][pvId], GetVehicleComponentInSlot(PlayerVehicleInfo[playerid][d][pvId], f));
							PlayerVehicleInfo[playerid][d][pvMods][f] = 0;
						}
						SendClientMessageEx(playerid, COLOR_WHITE, "Da thao tat ca phu tung do khoi xe cua ban.");
						return 1;
					}
					SetPVarInt(playerid, "unMod", 1);
					RemoveVehicleComponent(GetPlayerVehicleID(playerid), partID);
					if(GetVehicleComponentType(partID) == 3) {
						PlayerVehicleInfo[playerid][d][pvMods][14] = 0;
					}
					PlayerVehicleInfo[playerid][d][pvMods][GetVehicleComponentType(partID)] = 0;
					SendClientMessageEx(playerid, COLOR_WHITE, "Da thao phu tung do ban chon.");
					return 1;
				}
			}
		}
	}

	if(dialogid == 7954) // Report tips
	{
		ShowPlayerDialogEx(playerid,7955,DIALOG_STYLE_MSGBOX,"Huong dan bao cao","Luu y khi bao cao:\n- Neu viec can ho tro, khong chi dinh nguoi ho tro.\n- Trinh bay cu the, chinh xac yeu cau.\n- Khong bao cao sai su that.\n- Khong xuc pham admin.\n- Chi bao cao viec trong game.\n- Dung /shoporder cho don shop","Dong", "");
	}
	#if defined SHOPAUTOMATED
	if(dialogid == DIALOG_SHOPORDER)
	{
		if(response)
		{
			if(strlen(inputtext) < 1 || strlen(inputtext) > 6)
			{
				ShowPlayerDialogEx(playerid, DIALOG_SHOPERROR, DIALOG_STYLE_MSGBOX, "Shop Order","ERROR: The shop order ID must be no longer than 6 characters and no lower than 1 character.", "Retry", "Cancel");
				return 1;
			}
			if(!IsNumericString(inputtext))
			{
				ShowPlayerDialogEx(playerid, DIALOG_SHOPERROR, DIALOG_STYLE_MSGBOX, "Shop Order","ERROR: The shop order ID must be a numerical value.", "Retry", "Cancel");
				return 1;
			}
			new orderid = strval(inputtext);
			if(orderid == 0)
			{
				ShowPlayerDialogEx(playerid, DIALOG_SHOPERROR, DIALOG_STYLE_MSGBOX, "Shop Order","ERROR: The shop order ID can not be 0.", "Retry", "Cancel");
				return 1;
			}
			ShowNoticeGUIFrame(playerid, 6);
			PlayerInfo[playerid][pOrder] = orderid;

			new query[384];
			format(query, sizeof(query), "\
			SELECT p.order_product_id, p.order_id, p.name, p.quantity, h.order_status_id, o.email, o.ip \
			FROM betazorder_product p \
			LEFT JOIN betazorder_history h ON h.order_id = p.order_id AND h.order_history_id = (SELECT max(order_history_id) FROM betazorder_history WHERE p.order_id = order_id) \
			LEFT JOIN betazorder o ON o.order_id = p.order_id \
			WHERE p.order_id = %d", orderid);
			mysql_tquery(ShopPipeline, query, true, "OnShopOrder", "i", playerid);

			SetPVarInt(playerid, "ShopOrderTimer", 60); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_SHOPORDERTIMER);
		}
	}

	if(dialogid == DIALOG_SHOPORDEREMAIL)
	{
		if(response)
		{
			new email[256];
			GetPVarString(playerid, "ShopEmailVerify", email, sizeof(email));
			if(!isnull(inputtext) && strcmp(inputtext, email, true) == 0)
			{
				ShowNoticeGUIFrame(playerid, 6);
				new query[384];
				format(query, sizeof(query), "\
				SELECT p.order_product_id, p.order_id, p.name, p.quantity, p.delivered, h.order_status_id \
				FROM betazorder_product p \
				LEFT JOIN betazorder_history h ON h.order_id = p.order_id AND h.order_history_id = (SELECT max(order_history_id) FROM betazorder_history WHERE p.order_id = order_id) \
				LEFT JOIN betazorder o ON o.order_id = p.order_id \
				WHERE p.order_id = %d", PlayerInfo[playerid][pOrder]);
				mysql_tquery(ShopPipeline, query, true, "OnShopOrderEmailVer", "i", playerid);
			}
			else
			{
				//ERROR ASK FURTHER HELP
				ShowPlayerDialogEx(playerid, 0, DIALOG_STYLE_MSGBOX, "Shop Order Error", "We were unable to verify that e-mail to that order, would you like further assistance from a shop technician?", "Yes", "No");
			}
		}
	}

	if(dialogid == DIALOG_SHOPORDER2)
	{
		if(response)
		{
			ShowNoticeGUIFrame(playerid, 6);
			new query[256];
			format(query, sizeof(query), "SELECT * FROM `shop` WHERE `order_id`=%d", PlayerInfo[playerid][pOrder]);
			mysql_tquery(ShopPipeline, query, true, "OnShopOrder2", "ii", playerid, listitem);
		}
	}

	if(dialogid == DIALOG_SHOPDELIVER)
	{
		if(response)
		{
			switch(GetPVarInt(playerid, "DShop_product_id"))
			{
				case 69: //Custom car
				{
					new carstring[5012];
					for(new x;x<sizeof(VehicleNameShop);x++)
					{
						strunpack(shopVehicleName, VehicleNameShop[x][svehiclename], sizeof(shopVehicleName));
						format(carstring, sizeof(carstring), "%s%d - %s\n", carstring, VehicleNameShop[x][svehicleid], shopVehicleName);
					}
					ShowPlayerDialogEx(playerid, DIALOG_SHOPDELIVERCAR, DIALOG_STYLE_LIST, "Shop Car Delivery", carstring, "Select Car", "Cancel");
				}
			}
		}
	}

	if(dialogid == DIALOG_SHOPDELIVERCAR)
	{
		if(response)
		{
			new dialogstring[256], name[64];
			GetPVarString(playerid, "DShop_name", name, sizeof(name));
			SetPVarInt(playerid, "DShop_listitem", listitem);
			strunpack(shopVehicleName, VehicleNameShop[listitem][svehiclename], sizeof(shopVehicleName));
			format(dialogstring, sizeof(dialogstring), "You are about to redeem: %s\nOrder ID: %d\nWith vehicle: %s (ID %d)\n\nAre you sure?", name, GetPVarInt(playerid, "DShop_order_id"), VehicleNameShop[listitem][svehicleid], shopVehicleName);
			ShowPlayerDialogEx(playerid, DIALOG_SHOPDELIVERCAR2, DIALOG_STYLE_MSGBOX, "Shop Car Delivery", dialogstring, "Reedem", "Cancel");
		}
	}

	if(dialogid == DIALOG_SHOPDELIVERCAR2)
	{
		if(response)
		{
			if(!vehicleCountCheck(playerid))
			{
				ShowPlayerDialogEx(playerid, 0, DIALOG_STYLE_MSGBOX, "Error", "You can't have any more vehicles, you own too many!", "OK", "");
			}
			else if(!vehicleSpawnCountCheck(playerid))
			{
				ShowPlayerDialogEx(playerid, 0, DIALOG_STYLE_MSGBOX, "Error", "You have too many vehicles spawned, you must store one first.", "OK", "");
			}
			else
			{
				new Float: arr_fPlayerPos[4];
				listitem = GetPVarInt(playerid, "DShop_listitem");

				GetPlayerPos(playerid, arr_fPlayerPos[0], arr_fPlayerPos[1], arr_fPlayerPos[2]);
				GetPlayerFacingAngle(playerid, arr_fPlayerPos[3]);
				CreatePlayerVehicle(playerid, GetPlayerFreeVehicleId(playerid), VehicleNameShop[listitem][svehicleid], arr_fPlayerPos[0], arr_fPlayerPos[1], arr_fPlayerPos[2], arr_fPlayerPos[3], 0, 0, 2000000, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));

				format(string, sizeof(string), "[shoporder] created a %s (%d) for %s(%d) (invoice %s).", GetVehicleName(VehicleNameShop[listitem][svehicleid]), VehicleNameShop[listitem][svehicleid], GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPVarInt(playerid, "DShop_order_id"));
				Log("logs/shoplog.log", string);
			}
		}
	}
	#else
	if(dialogid == DIALOG_SHOPORDER)
	{
		if(response)
		{
			if(strlen(inputtext) < 1 || strlen(inputtext) > 6)
			{
				ShowPlayerDialogEx(playerid, DIALOG_SHOPERROR, DIALOG_STYLE_MSGBOX, "Don hang cua hang","LOI: ID don shop phai dai tu 6 ky tu tro xuong va tu 1 ky tu tro len.", "Thu lai", "Huy");
				return 1;
			}
			if(!IsNumericString(inputtext))
			{
				ShowPlayerDialogEx(playerid, DIALOG_SHOPERROR, DIALOG_STYLE_MSGBOX, "Don hang cua hang","LOI: ID don shop phai la so.", "Thu lai", "Huy");
				return 1;
			}
			new orderid = strval(inputtext);
			if(orderid == 0)
			{
				ShowPlayerDialogEx(playerid, DIALOG_SHOPERROR, DIALOG_STYLE_MSGBOX, "Don hang cua hang","LOI: ID don shop khong duoc la 0.", "Thu lai", "Huy");
				return 1;
			}
			PlayerInfo[playerid][pOrder] = orderid;

			SetPVarInt(playerid, "ShopOrderTimer", 60); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_SHOPORDERTIMER);

			format(string, sizeof(string), "shop.ng-gaming.net/idcheck.php?id=%d", orderid);
			HTTP(playerid, HTTP_GET, string, "", "HttpCallback_ShopIDCheck");
		}
	}
	#endif
	if(dialogid == DIALOG_SHOPERROR)
	{
		if(response)
		{
			ShowPlayerDialogEx(playerid, DIALOG_SHOPORDER, DIALOG_STYLE_INPUT, "Don hang cua hang", "Danh cho don hang tu http://shop.ng-gaming.net\n\nNeu khong co don hang, hay huy hop thoai nay.\n\nCanh bao: Lam dung co the bi cam dung lenh vo thoi han.\n\nNhap ID don shop (neu khong biet, nhap 1):", "Gui", "Huy" );
		}
	}
	if(dialogid == DIALOG_SHOPERROR2)
	{
		if(response)
		{
			ShowPlayerDialogEx(playerid, DIALOG_SHOPSENT, DIALOG_STYLE_INPUT, "Don hang cua hang", "", "Gui", "Huy" );
		}
	}
	if(dialogid == PMOTDNOTICE && 1 <= PlayerInfo[playerid][pDonateRank] <= 3 && (PlayerInfo[playerid][pVIPExpire] - 86400 < gettime()))
	{
		ShowPlayerDialogEx(playerid, VIP_EXPIRES, DIALOG_STYLE_MSGBOX, "VIP sap het han!", "VIP cua ban het han trong chua day mot ngay, gia han tai shop.ng-gaming.net!", "Dong y", "");
	}
	else if(dialogid == PMOTDNOTICE || dialogid == VIP_EXPIRES)
	{
		SetPVarInt(playerid, "ViewedPMOTD", 1);
		if(PlayerInfo[playerid][pReceivedCredits] != 0) ShowLoginDialogs(playerid, 5);
	}
	if(dialogid == DIALOG_LOADTRUCK)
	{
		if(!Shipment_CanLoad(playerid) || !response) return CancelTruckDelivery(playerid, false);
		new count = GetPVarInt(playerid, "ShipmentOrderCount"), next = GetPVarInt(playerid, "ShipmentOrderNext");
		if(listitem == count && next > 0) return DisplayOrders(playerid, next);
		if(!(0 <= listitem < count) || listitem >= sizeof(ListItemTrackId[])) return CancelTruckDelivery(playerid, false);
		new business = ListItemTrackId[playerid][listitem], vehicleid = TruckUsed[playerid];
		if(!(0 <= business < MAX_BUSINESSES)) return CancelTruckDelivery(playerid, false);
		if(Businesses[business][bOrderState] != 1 || Businesses[business][bType] <= 0 || !Shipment_OrderFits(GetVehicleModel(vehicleid), Businesses[business][bType]))
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Don hang do khong con kha dung. Hay chon don khac.");
			return DisplayOrders(playerid);
		}
		Businesses[business][bOrderState] = 2;
		TruckDeliveringTo[vehicleid] = business;
		SaveBusiness(business);
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Vui long cho xe duoc chat %s len...", GetInventoryType(business));
		Shipment_BeginLoading(playerid, vehicleid, "LoadTruck");
		return 1;
	}
	if((dialogid == BUYTOYSCOP) && response)
	{
		szMiscArray[0] = 0;
		new icount = GetPlayerToySlots(playerid);
		for(new x;x<icount;x++)
		{
			new name[24] = "None";

			for(new i;i<sizeof(HoldingObjectsAll);i++)
			{
				if(HoldingObjectsAll[i][holdingmodelid] == PlayerToyInfo[playerid][x][ptModelID])
				{
					strunpack(name, HoldingObjectsAll[i][holdingmodelname], sizeof(name));
				}
			}
			if(PlayerToyInfo[playerid][x][ptModelID] != 0 && (strcmp(name, "None", true) == 0))
			{
				format(name, sizeof(name), "ID: %d", PlayerToyInfo[playerid][x][ptModelID]);
			}
			strunpack(boneName, HoldingBones[PlayerToyInfo[playerid][x][ptBone]], sizeof(boneName));
			format(szMiscArray, sizeof(szMiscArray), "%s(%d) %s (Gan: %s)\n", szMiscArray, x, name, boneName);
		}
		ShowPlayerDialogEx(playerid, BUYTOYSCOP2, DIALOG_STYLE_LIST, "Chon mot Slot", szMiscArray, "Chon", "Huy");
	}

	if((dialogid == BUYTOYSCOP2) && response)
	{
		/*
		if(listitem >= 5 && PlayerInfo[playerid][pDonateRank] < 1 || listitem >= 5 && PlayerInfo[playerid][pBuddyInvited] == 1) return SendClientMessageEx(playerid, COLOR_WHITE, "* You must be a Bronze VIP + to use that slot!");
		if(listitem >= 8 && PlayerInfo[playerid][pDonateRank] < 2) return SendClientMessageEx(playerid, COLOR_WHITE, "* You must be a Silver VIP + to use that slot!");
		if(listitem >= 9 && PlayerInfo[playerid][pDonateRank] < 3) return SendClientMessageEx(playerid, COLOR_WHITE, "* You must be a Gold VIP + to use that slot!");
		if(listitem >= 10 && PlayerInfo[playerid][pDonateRank] < 4) return SendClientMessageEx(playerid, COLOR_WHITE, "* You must be a Platinum VIP + to use that slot!");
		*/

		if(!toyCountCheck(playerid)) return SendClientMessageEx(playerid, COLOR_YELLOW, "* Ban khong the giu them toy.");

		if(PlayerToyInfo[playerid][listitem][ptModelID] != 0) return SendClientMessageEx(playerid, COLOR_YELLOW, "* O nay da co do. Dung /toys de xoa");

		SetPVarInt(playerid, "ToySlot", listitem);

		new stringg[1024];
		for(new x;x<sizeof(HoldingObjectsCop);x++)
		{
			strunpack(copToyName, HoldingObjectsCop[x][holdingmodelname], sizeof(copToyName));
			format(stringg, sizeof(stringg), "%s%s ($%d)\n", stringg, copToyName, HoldingObjectsCop[x][holdingprice]);
		}
		ShowPlayerDialogEx(playerid, BUYTOYSCOP3, DIALOG_STYLE_LIST, "Chon vat pham", stringg, "Mua", "Huy");
	}
	if((dialogid == BUYTOYSCOP3) && response)
	{
		if(GetPlayerCash(playerid) < HoldingObjectsCop[listitem][holdingprice])
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "* Ban khong du tien!");
		}
		else
		{
			GivePlayerCash(playerid, -HoldingObjectsCop[listitem][holdingprice]);
			PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptModelID] = HoldingObjectsCop[listitem][holdingmodelid];

			new modelid = PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptModelID];
			if((modelid >= 19006 && modelid <= 19035) || (modelid >= 19138 && modelid <= 19140))
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 2;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.9;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.35;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 90.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 90.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 0.0;
			}
			else if(modelid >= 18891 && modelid <= 18910)
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 2;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.15;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 90.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 180.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 90.0;
			}
			else if(modelid >= 18926 && modelid <= 18935)
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 2;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.1;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 0.0;
			}
			else if(modelid >= 18911 && modelid <= 18920)
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 2;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.1;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.035;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 90.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 180.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 90.0;
			}
			else if(modelid == 19078 || modelid == 19078)
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 16;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 180.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 180.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 0.0;
			}
			else if((modelid >= 18641 && modelid <= 18644) || (modelid >= 19080 && modelid <= 19084) || modelid == 18890)
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 6;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 0.0;
			}
			else
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 2;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 0.0;
			}
			PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptScaleX] = 1.0;
			PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptScaleY] = 1.0;
			PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptScaleZ] = 1.0;
			PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptTradable] = 0;

			g_mysql_NewToy(playerid, GetPVarInt(playerid, "ToySlot"));

			strunpack(copToyName, HoldingObjectsCop[listitem][holdingmodelname], sizeof(copToyName));
			format(string, sizeof(string), "* Ban da mua %s voi gia $%d (O: %d)", copToyName, HoldingObjectsCop[listitem][holdingprice], GetPVarInt(playerid, "ToySlot"));
			SendClientMessageEx(playerid, COLOR_RED, string);
			SendClientMessageEx(playerid, COLOR_WHITE, "GOI Y: Dung /toys de deo/sua vat nay");
		}
	}
	if((dialogid == BUYTOYSGOLD) && response)
	{
		if(PlayerInfo[playerid][pDonateRank] < 3) return SendClientMessageEx(playerid, COLOR_WHITE, "* Ban phai la Gold VIP +");
		new icount = GetPlayerToySlots(playerid);
		for(new x;x<icount;x++)
		{
			new name[24] = "None";

			for(new i;i<sizeof(HoldingObjectsAll);i++)
			{
				if(HoldingObjectsAll[i][holdingmodelid] == PlayerToyInfo[playerid][x][ptModelID])
				{
					strunpack(name, HoldingObjectsAll[i][holdingmodelname], sizeof(name));
				}
			}
			if(PlayerToyInfo[playerid][x][ptModelID] != 0 && (strcmp(name, "None", true) == 0))
			{
				format(name, sizeof(name), "ID: %d", PlayerToyInfo[playerid][x][ptModelID]);
			}
			strunpack(boneName, HoldingBones[PlayerToyInfo[playerid][x][ptBone]], sizeof(boneName));
			format(szMiscArray, sizeof(szMiscArray), "%s(%d) %s (Gan: %s)\n", szMiscArray, x, name, boneName);
		}
		ShowPlayerDialogEx(playerid, BUYTOYSGOLD2, DIALOG_STYLE_LIST, "Chon mot Slot", szMiscArray, "Chon", "Huy");
	}

	if((dialogid == BUYTOYSGOLD2) && response)
	{
		if(PlayerInfo[playerid][pDonateRank] < 3) return SendClientMessageEx(playerid, COLOR_WHITE, "* Ban phai la Gold VIP +");

		if(!toyCountCheck(playerid)) return SendClientMessageEx(playerid, COLOR_YELLOW, "* Ban khong the giu them toy.");

		if(PlayerToyInfo[playerid][listitem][ptModelID] != 0) return SendClientMessageEx(playerid, COLOR_YELLOW, "* O nay da co do. Dung /toys de xoa");

		SetPVarInt(playerid, "ToySlot", listitem);

		for(new x;x<sizeof(HoldingObjectsAll);x++)
		{
			strunpack(toyName, HoldingObjectsAll[x][holdingmodelname], sizeof(toyName));
			format(szMiscArray, sizeof(szMiscArray), "%s%s ($%d)\n", szMiscArray, toyName, HoldingObjectsAll[x][holdingprice]);
		}
		ShowPlayerDialogEx(playerid, BUYTOYSGOLD3, DIALOG_STYLE_LIST, "Chon vat pham", szMiscArray, "Mua", "Huy");
	}
	if((dialogid == BUYTOYSGOLD3) && response)
	{
		if(PlayerInfo[playerid][pDonateRank] < 3) return SendClientMessageEx(playerid, COLOR_WHITE, "* Ban phai la Gold VIP +");

		if(GetPlayerCash(playerid) < HoldingObjectsAll[listitem][holdingprice])
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "* Ban khong du tien!");
		}
		else
		{
			GivePlayerCash(playerid, -HoldingObjectsAll[listitem][holdingprice]);
			PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptModelID] = HoldingObjectsAll[listitem][holdingmodelid];

			new modelid = PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptModelID];
			if((modelid >= 19006 && modelid <= 19035) || (modelid >= 19138 && modelid <= 19140))
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 2;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.9;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.35;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 90.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 90.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 0.0;
			}
			else if(modelid >= 18891 && modelid <= 18910)
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 2;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.15;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 90.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 180.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 90.0;
			}
			else if(modelid >= 18926 && modelid <= 18935)
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 2;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.1;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 0.0;
			}
			else if(modelid >= 18911 && modelid <= 18920)
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 2;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.1;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.035;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 90.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 180.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 90.0;
			}
			else if(modelid == 19078 || modelid == 19078)
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 16;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 180.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 180.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 0.0;
			}
			else if((modelid >= 18641 && modelid <= 18644) || (modelid >= 19080 && modelid <= 19084) || modelid == 18890)
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 6;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 0.0;
			}
			else
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 2;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 0.0;
			}
			PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptScaleX] = 1.0;
			PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptScaleY] = 1.0;
			PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptScaleZ] = 1.0;
			PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptTradable] = 0;

			g_mysql_NewToy(playerid, GetPVarInt(playerid, "ToySlot"));

			strunpack(toyName, HoldingObjectsAll[listitem][holdingmodelname], sizeof(toyName));
			format(string, sizeof(string), "* Ban da mua %s voi gia $%d (O: %d)", toyName, HoldingObjectsAll[listitem][holdingprice], GetPVarInt(playerid, "ToySlot"));
			SendClientMessageEx(playerid, COLOR_RED, string);
			SendClientMessageEx(playerid, COLOR_WHITE, "GOI Y: Dung /toys de deo/sua vat nay");

		}
	}
	if((dialogid == BUYTOYS) && response)
	{
		szMiscArray[0] = 0;
		new icount = GetPlayerToySlots(playerid);
		for(new x;x<icount;x++)
		{
			new name[24];
			format(name, sizeof(name), "None");

			for(new i;i<sizeof(HoldingObjectsAll);i++)
			{
				if(HoldingObjectsAll[i][holdingmodelid] == PlayerToyInfo[playerid][x][ptModelID])
				{
					strunpack(name, HoldingObjectsAll[i][holdingmodelname], sizeof(name));
				}
			}
			if(PlayerToyInfo[playerid][x][ptModelID] != 0 && (strcmp(name, "None", true) == 0))
			{
				format(name, sizeof(name), "ID: %d", PlayerToyInfo[playerid][x][ptModelID]);
			}
			strunpack(boneName, HoldingBones[PlayerToyInfo[playerid][x][ptBone]], sizeof(boneName));
			format(szMiscArray, sizeof(szMiscArray), "%s(%d) %s (Gan: %s)\n", szMiscArray, x, name, boneName);
		}
		ShowPlayerDialogEx(playerid, BUYTOYS2, DIALOG_STYLE_LIST, "Chon mot Slot", szMiscArray, "Chon", "Huy");
	}
	if((dialogid == BUYTOYS2) && response)
	{
		/*
		if(listitem >= 5 + PlayerInfo[playerid][pToySlot] && PlayerInfo[playerid][pDonateRank] < 1 || listitem >= 5 + PlayerInfo[playerid][pToySlot] && PlayerInfo[playerid][pBuddyInvited] == 1) return SendClientMessageEx(playerid, COLOR_WHITE, "* You must be a Bronze VIP + to use that slot!");
		if(listitem >= 8 + PlayerInfo[playerid][pToySlot] && PlayerInfo[playerid][pDonateRank] < 2) return SendClientMessageEx(playerid, COLOR_WHITE, "* You must be a Silver VIP + to use that slot!");
		if(listitem >= 9 + PlayerInfo[playerid][pToySlot] && PlayerInfo[playerid][pDonateRank] < 3) return SendClientMessageEx(playerid, COLOR_WHITE, "* You must be a Gold VIP + to use that slot!");
		if(listitem >= 10 + PlayerInfo[playerid][pToySlot] && PlayerInfo[playerid][pDonateRank] < 4) return SendClientMessageEx(playerid, COLOR_WHITE, "* You must be a Platinum VIP + to use that slot!");
		*/

		if(!toyCountCheck(playerid)) return SendClientMessageEx(playerid, COLOR_YELLOW, "* Ban khong the giu them toy.");

		if(PlayerToyInfo[playerid][listitem][ptModelID] != 0) return SendClientMessageEx(playerid, COLOR_YELLOW, "* O nay da co do. Dung /toys de xoa");

		SetPVarInt(playerid, "ToySlot", listitem);

		new stringg[5000];
		for(new x;x<sizeof(HoldingObjects);x++)
		{
			strunpack(legacyToyName, HoldingObjects[x][holdingmodelname], sizeof(legacyToyName));
			format(stringg, sizeof(stringg), "%s%s ($%d)\n", stringg, legacyToyName, HoldingObjects[x][holdingprice]);
		}
		ShowPlayerDialogEx(playerid, BUYTOYS3, DIALOG_STYLE_LIST, "Chon vat pham", stringg, "Mua", "Huy");
	}
	if((dialogid == BUYTOYS3) && response)
	{
		if(GetPlayerCash(playerid) < HoldingObjects[listitem][holdingprice])
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "* Ban khong du tien!");
		}
		else
		{
			GivePlayerCash(playerid, -HoldingObjects[listitem][holdingprice]);
			PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptModelID] = HoldingObjects[listitem][holdingmodelid];

			new modelid = PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptModelID];
			if((modelid >= 19006 && modelid <= 19035) || (modelid >= 19138 && modelid <= 19140))
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 2;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.9;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.35;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 90.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 90.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 0.0;
			}
			else if(modelid >= 18891 && modelid <= 18910)
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 2;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.15;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 90.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 180.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 90.0;
			}
			else if(modelid >= 18926 && modelid <= 18935)
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 2;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.1;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 0.0;
			}
			else if(modelid >= 18911 && modelid <= 18920)
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 2;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.1;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.035;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 90.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 180.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 90.0;
			}
			else if(modelid == 19078 || modelid == 19078)
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 16;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 180.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 180.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 0.0;
			}
			else if((modelid >= 18641 && modelid <= 18644) || (modelid >= 19080 && modelid <= 19084) || modelid == 18890)
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 6;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 0.0;
			}
			else
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 2;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 0.0;
			}
			PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptScaleX] = 1.0;
			PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptScaleY] = 1.0;
			PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptScaleZ] = 1.0;
			PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptTradable] = 1;

			g_mysql_NewToy(playerid, GetPVarInt(playerid, "ToySlot"));

			strunpack(legacyToyName, HoldingObjects[listitem][holdingmodelname], sizeof(legacyToyName));
			format(string, sizeof(string), "* Ban da mua %s voi gia $%d (O: %d)", legacyToyName, HoldingObjects[listitem][holdingprice], GetPVarInt(playerid, "ToySlot"));
			SendClientMessageEx(playerid, COLOR_RED, string);
			SendClientMessageEx(playerid, COLOR_WHITE, "GOI Y: Dung /toys de deo/sua vat nay");
		}
	}
	if((dialogid == TOYS) && response)
	{
		szMiscArray[0] = 0;
		new icount = GetPlayerToySlots(playerid);
		for(new x;x<icount;x++)
		{
			new name[24];
			format(name, sizeof(name), "None");

			for(new i;i<sizeof(HoldingObjectsAll);i++)
			{
				if(HoldingObjectsAll[i][holdingmodelid] == PlayerToyInfo[playerid][x][ptModelID])
				{
					strunpack(name, HoldingObjectsAll[i][holdingmodelname], sizeof(name));
				}
			}
			if(PlayerToyInfo[playerid][x][ptModelID] != 0 && (strcmp(name, "None", true) == 0))
			{
				format(name, sizeof(name), "ID: %d", PlayerToyInfo[playerid][x][ptModelID]);
			}
			strunpack(boneName, HoldingBones[PlayerToyInfo[playerid][x][ptBone]], sizeof(boneName));
			format(szMiscArray, sizeof(szMiscArray), "%s(%d) %s (Gan: %s)\n", szMiscArray, x+1, name, boneName); // x+1 Since the toys list starts of from 1( As players see it )
		}
		format(szMiscArray, sizeof(szMiscArray), "%s\n{40FFFF}Additional Toy Slot {FFD700}(Credits: %s){A9C4E4}", szMiscArray, number_format(ShopItems[28][sItemPrice]));
		switch(listitem) {
			case 0:
				ShowPlayerDialogEx(playerid, WEARTOY, DIALOG_STYLE_LIST, "Chon Toy", szMiscArray, "Chon", "Huy");
			case 1:
				ShowPlayerDialogEx(playerid, EDITTOYS, DIALOG_STYLE_LIST, "Chon Toy", szMiscArray, "Chon", "Huy");
			case 2:
				ShowPlayerDialogEx(playerid, DELETETOY, DIALOG_STYLE_LIST, "Chon Toy", szMiscArray, "Xoa", "Huy");
		}
	}

	if((dialogid == EDITTOYS) && response)
	{
		/*new toycount = GetFreeToySlot(playerid);
		if(toycount >= 10) return SendClientMessageEx(playerid, COLOR_GRAD1, "You currently have 10 objects attached, please deattach an object.");*/
		if(listitem >= GetPlayerToySlots(playerid))
		{
			new szstring[128];
			SetPVarInt(playerid, "MiscShop", 8);
			format(szstring, sizeof(szstring), "Additional Toy Slot\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[28][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[28][sItemPrice]));
			return ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Additional Toy Slot", szstring, "Mua", "Huy");
		}
		else if(PlayerToyInfo[playerid][listitem][ptModelID] == 0 && listitem < GetPlayerToySlots(playerid))
		{
			ShowPlayerDialogEx(playerid, 0, DIALOG_STYLE_MSGBOX, "Sua toy cua ban", "O nay khong co toy de sua.", "Dong y", "");
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "{AA3333}GOI Y:{FFFF00} Doi goc camera de de quan sat khi chinh sua.");
			SetPVarInt(playerid, "ToySlot", listitem);
			ShowEditMenu(playerid);
		}
	}
	if((dialogid == EDITTOYS2)) {
		if(response) switch(listitem) {
			case 0: ShowPlayerDialogEx(playerid, EDITTOYSBONE, DIALOG_STYLE_LIST, "Chon xuong", "Song lung\nDau\nBap tay trai\nBap tay phai\nBan tay trai\nBan tay phai\nDui trai\nDui phai\nBan chan trai\nBan chan phai\nBap chan phai\nBap chan trai\nCang tay trai\nCang tay phai\nXuong don trai\nXuong don phai\nCo\nHam", "Chon", "Huy");
			case 1:
			{
				for(new i; i < 10; i++)
				{
					if(PlayerHoldingObject[playerid][i] == GetPVarInt(playerid, "ToySlot"))
					{
						EditAttachedObject(playerid, i);
						break;
					}
				}
				SendClientMessage(playerid, COLOR_WHITE, "GOI Y: Giu {8000FF}~k~~PED_SPRINT~ {FFFFAA}de di chuyen camera, nhan escape de huy");
			}
			case 2:
			{
				new szstring[128];
				if(PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptAutoAttach] == -2) format(szstring, sizeof(szstring), "Chon cach tu dong gan (Dang tat)");
				else if(PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptAutoAttach] == -1) format(szstring, sizeof(szstring), "Chon cach tu dong gan (Hien tai: Moi skin)");
				else format(szstring, sizeof(szstring), "Chon cach tu dong gan (Hien tai: Skin %d)", GetPlayerSkin(playerid));
				ShowPlayerDialogEx(playerid, EDITTOYSAUTOATTACH, DIALOG_STYLE_LIST, szstring, "Gan voi moi skin\nGan voi skin hien tai\nTat tu dong gan", "Chon", "Huy");
			}
		}
		else
		{
			szMiscArray[0] = 0;
			new icount = GetPlayerToySlots(playerid);
			if(PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptSpecial] == 2) for(new i; i < 10; i++) {
				if(PlayerHoldingObject[playerid][i] == GetPVarInt(playerid, "ToySlot")) {
					PlayerHoldingObject[playerid][i] = 0;
					RemovePlayerAttachedObject(playerid, i);
					SendClientMessageEx(playerid, COLOR_GRAD1, "Chi duoc deo toy nay bang /helmet.");
					break;
				}
			}
			for(new x;x<icount;x++)
			{
				new name[24];
				format(name, sizeof(name), "None");

				for(new i;i<sizeof(HoldingObjectsAll);i++)
				{
					if(HoldingObjectsAll[i][holdingmodelid] == PlayerToyInfo[playerid][x][ptModelID])
					{
						strunpack(name, HoldingObjectsAll[i][holdingmodelname], sizeof(name));
					}
				}
				if(PlayerToyInfo[playerid][x][ptModelID] != 0 && (strcmp(name, "None", true) == 0))
				{
					format(name, sizeof(name), "ID: %d", PlayerToyInfo[playerid][x][ptModelID]);
				}
				strunpack(boneName, HoldingBones[PlayerToyInfo[playerid][x][ptBone]], sizeof(boneName));
				format(szMiscArray, sizeof(szMiscArray), "%s(%d) %s (Gan: %s)\n", szMiscArray, x+1, name, boneName); // x+1 since toys list starts off from 1 (From players view)
			}
			format(szMiscArray, sizeof(szMiscArray), "%s\n{40FFFF}Additional Toy Slot {FFD700}(Credits: %s){A9C4E4}", szMiscArray, number_format(ShopItems[28][sItemPrice]));
			ShowPlayerDialogEx(playerid, EDITTOYS, DIALOG_STYLE_LIST, "Chon Toy", szMiscArray, "Chon", "Huy");
		}
	}
	if(dialogid == EDITTOYSBONE)
	{
		if(response)
		{
			if(PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptSpecial] == 2)
				SendClientMessageEx(playerid, COLOR_GRAD2, "Toy nay chi duoc gan vao dau.");
			else {
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = listitem+1;
				g_mysql_SaveToys(playerid,GetPVarInt(playerid, "ToySlot"));
			}
		}
		ShowEditMenu(playerid);
	}
	if(dialogid == EDITTOYSAUTOATTACH)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptAutoAttach] = -1;
					g_mysql_SaveToys(playerid,GetPVarInt(playerid, "ToySlot"));
				}
				case 1:
				{
					PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptAutoAttach] = GetPlayerSkin(playerid);
					g_mysql_SaveToys(playerid,GetPVarInt(playerid, "ToySlot"));
				}
				case 2:
				{
					PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptAutoAttach] = -2;
					g_mysql_SaveToys(playerid,GetPVarInt(playerid, "ToySlot"));
				}
			}
		}
		ShowEditMenu(playerid);
	}
	if(dialogid == SELLTOY)
	{
		if(response)
		{
			new buyerid = GetPVarInt(playerid, "ttBuyer"),
				cost = GetPVarInt(playerid, "ttCost");
			if(PlayerToyInfo[playerid][listitem][ptModelID] == 0) {
				DeletePVar(buyerid, "ttSeller");
				DeletePVar(playerid, "ttCost");
				DeletePVar(playerid, "ttBuyer");
				ShowPlayerDialogEx(playerid, 0, DIALOG_STYLE_MSGBOX, "Ban toy cua ban", "O nay khong co toy de ban.", "Dong y", "");
			}
			if(PlayerToyInfo[playerid][listitem][ptTradable] == 0) {
				SendClientMessageEx(playerid, COLOR_GREY, "Toy nay khong the giao dich.");
				DeletePVar(buyerid, "ttSeller");
				DeletePVar(playerid, "ttCost");
				return DeletePVar(playerid, "ttBuyer");
			}
			if(!IsPlayerAttachedObjectSlotUsed(playerid, listitem))
			{
				new name[24],
					toyid = PlayerToyInfo[playerid][listitem][ptModelID];
				format(name, sizeof(name), "None");
				for(new i;i<sizeof(HoldingObjectsAll);i++)
				{
					if(HoldingObjectsAll[i][holdingmodelid] == toyid)
					{
						strunpack(toyName, HoldingObjectsAll[i][holdingmodelname], sizeof(toyName));
						format(name, sizeof(name), "(%s)", toyName);
					}
				}
				if(PlayerToyInfo[playerid][listitem][ptModelID] != 0 && (strcmp(name, "None", true) == 0))
				{
					format(name, sizeof(name), "(ID: %d)", toyid);
				}
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban chao %s mua toy cua ban. %s", GetPlayerNameEx(buyerid), name);
				SetPVarInt(playerid, "ttToy", toyid);
				SetPVarInt(playerid, "ttToySlot", listitem);
				PrepTradeToysGUI(buyerid, playerid, cost, toyid);
			}
			else {
				SendClientMessageEx(playerid, COLOR_GREY, "Ban dang deo toy nay, hay thao ra roi thu lai.");
				DeletePVar(buyerid, "ttSeller");
				DeletePVar(playerid, "ttCost");
				DeletePVar(playerid, "ttSeller");
			}
		}
		else
		{
			SetPVarInt(playerid, "ttSeller", INVALID_PLAYER_ID);
			SetPVarInt(playerid, "ttCost", 0);
			SetPVarInt(playerid, "ttSeller", INVALID_PLAYER_ID);
		}
	}
	if(dialogid == CONFIRMSELLTOY)
	{
		if(response) {
			CompleteToyTrade(playerid);
		}
		else {

			format(szMiscArray, sizeof(szMiscArray), "%s da tu choi de nghi toy.", GetPlayerNameEx(playerid));
			SendClientMessageEx(GetPVarInt(playerid, "ttSeller"), COLOR_GREY, szMiscArray);
			SendClientMessageEx(playerid, COLOR_GREY, "Ban da tu choi de nghi toy.");
			DeletePVar(GetPVarInt(playerid, "ttSeller"), "ttBuyer");
			DeletePVar(GetPVarInt(playerid, "ttSeller"), "ttCost");
			DeletePVar(playerid, "ttSeller");

			HideTradeToysGUI(playerid);
		}
	}
	if((dialogid == WEARTOY) && response)
	{
		//if(PlayerToyInfo[playerid][listitem][ptModelID] == 0)
		if(listitem >= GetPlayerToySlots(playerid))
		{
			SetPVarInt(playerid, "MiscShop", 8);
			format(szMiscArray, sizeof(szMiscArray), "Additional Toy Slot\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[28][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[28][sItemPrice]));
			return ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Additional Toy Slot", szMiscArray, "Mua", "Huy");
		}
		else if(PlayerToyInfo[playerid][listitem][ptModelID] == 0 && listitem < GetPlayerToySlots(playerid))
		{
			ShowPlayerDialogEx(playerid, 0, DIALOG_STYLE_MSGBOX, "Deo toy cua ban", "O nay khong co toy de deo.", "Dong y", "");
		}
		else if(PlayerToyInfo[playerid][listitem][ptSpecial] == 2)
		{
			ShowPlayerDialogEx(playerid, 0, DIALOG_STYLE_MSGBOX, "Deo toy cua ban", "Chi duoc deo toy nay bang /helmet.", "Dong y", "");
		}
		else
		{
			new toys = 99999;
			for(new i; i < 10; i++)
			{
				if(PlayerHoldingObject[playerid][i] == listitem)
				{
					toys = i;
					break;
				}
			}
			if(IsPlayerAttachedObjectSlotUsed(playerid, toys))
			{
				new name[24];
				format(name, sizeof(name), "None");

				for(new i;i<sizeof(HoldingObjectsAll);i++)
				{
					if(HoldingObjectsAll[i][holdingmodelid] == PlayerToyInfo[playerid][listitem][ptModelID])
					{
						strunpack(name, HoldingObjectsAll[i][holdingmodelname], sizeof(name));
					}
				}
				strunpack(boneName, HoldingBones[PlayerToyInfo[playerid][listitem][ptBone]], sizeof(boneName));
				format(string, sizeof(string), "Da thao %s (Xuong: %s) (O: %d)", name, boneName, listitem);
				SendClientMessageEx(playerid, COLOR_RED, string);
				RemovePlayerAttachedObject(playerid, toys);
				for(new i; i < 10; i++)
				{
					if(PlayerHoldingObject[playerid][i] == listitem)
					{
						PlayerHoldingObject[playerid][i] = 0;
						break;
					}
				}
			}
			else AttachToy(playerid, listitem);
		}
	}

	if((dialogid == DELETETOY) && response)
	{
		new toys = 99999;
		for(new i; i < 10; i++)
		{
			if(PlayerHoldingObject[playerid][i] == listitem)
			{
				toys = i;
				if(IsPlayerAttachedObjectSlotUsed(playerid, toys))
				{
					PlayerHoldingObject[playerid][i] = 0;
					RemovePlayerAttachedObject(playerid, toys);
				}
				break;
			}
		}

		new szQuery[128];
		mysql_format(MainPipeline, szQuery, sizeof(szQuery), "DELETE FROM `toys` WHERE `id` = '%d'", PlayerToyInfo[playerid][listitem][ptID]);
		mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "ii", SENDDATA_THREAD, playerid);
		PlayerToyInfo[playerid][listitem][ptID] = 0;
		PlayerToyInfo[playerid][listitem][ptModelID] = 0;
		PlayerToyInfo[playerid][listitem][ptBone] = 0;
		if(PlayerToyInfo[playerid][listitem][ptSpecial] != 0)
		{
			PlayerToyInfo[playerid][listitem][ptSpecial] = 0;
		}

		format(string, sizeof(string), "Ban da xoa toy tai o %d.", listitem);
		ShowPlayerDialogEx(playerid, 0, DIALOG_STYLE_MSGBOX, "Menu Toy", string, "Dong y", "");
	}

	if((dialogid == LAELEVATORPASS) && response)
	{
		listitem = GetPVarInt(playerid, "ElevatorFloorPick");
		if(FloorRequestedBy[listitem] != INVALID_PLAYER_ID || IsFloorInQueue(listitem))
			GameTextForPlayer(playerid, "~r~Tang da trong hang doi", 3500, 4);
		else if(DidPlayerRequestElevator(playerid))
			GameTextForPlayer(playerid, "~r~Ban da goi thang may", 3500, 4);
		else
		{
			if(strfind(inputtext, "hats", true) == 0 && IsAHitman(playerid))
			{
				CallElevator(playerid, 20);
			}
			else if(strfind(inputtext, LAElevatorFloorData[1][listitem], true) == 0)
			{
				CallElevator(playerid, listitem);
			}
			else
			{
				GameTextForPlayer(playerid, "~r~Sai mat khau", 3500, 4);
			}
		}
	}
	if((dialogid == LAELEVATOR) && response)
	{
		if(FloorRequestedBy[listitem] != INVALID_PLAYER_ID || IsFloorInQueue(listitem))
			GameTextForPlayer(playerid, "~r~Tang da trong hang doi", 3500, 4);
		else if(DidPlayerRequestElevator(playerid))
			GameTextForPlayer(playerid, "~r~Ban da goi thang may", 3500, 4);
		else
		{
			if(strlen(LAElevatorFloorData[1][listitem]) > 0)
			{
				SetPVarInt(playerid, "ElevatorFloorPick", listitem);
				ShowPlayerDialogEx(playerid, LAELEVATORPASS, DIALOG_STYLE_INPUT, "Elevator", "Nhap mat khau cho cap nay", "Nhap", "Huy");
			}
			else
			{
				CallElevator(playerid, listitem);
			}
		}
		return 1;
	}
	if((dialogid == AUDIO_URL) && response) // /audiourl
	{
		if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
		{
			new range = GetPVarInt(playerid, "aURLrange");
			new Float:aX, Float:aY, Float:aZ;
			GetPlayerPos(playerid, aX, aY, aZ);
			//SendAudioURLToRange(inputtext,aX,aY,aZ,range);
			format(audiourlurl, sizeof(audiourlurl), "%s", inputtext);
			SetGVarInt("MusicArea", CreateDynamicSphere(aX, aY, aZ, range, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid)));


			if(range > 100)
			{
				format(string,sizeof(string),"{AA3333}AdmWarning{FFFF00}: %s da dat url %s - Pham vi: %d.",GetPlayerNameEx(playerid),inputtext,range);
				ABroadCast(COLOR_YELLOW, string, 4);
				format(string, sizeof(string),"Dung /audiostopurl de dung phat");
				SendClientMessage(playerid, COLOR_YELLOW, string);
			}
			else
			{
				format(string,sizeof(string),"Ban da dat url %s - Pham vi: %d",inputtext,range);
				SendClientMessage(playerid, COLOR_YELLOW, string);
				format(string, sizeof(string),"Dung /audiostopurl de dung phat");
				SendClientMessage(playerid, COLOR_YELLOW, string);
			}
		}
	}

	/*if(dialogid == DIALOG_NUMBER_PLATE_CHOSEN) {
		if(response == 1) {
			for(new i = 0; i < MAX_PLAYERVEHICLES; i++) {
				if(listitem == i) {
					if(PlayerInfo[playerid][pDonateRank] > 0) {
						new
							tmpSz_NumPlate[32];

						GetPVarString(playerid, "szNumPS", tmpSz_NumPlate, sizeof(tmpSz_NumPlate));
						RegisterVehicleNumberPlate(PlayerVehicleInfo[playerid][i][pvId], tmpSz_NumPlate);
						SetPVarInt(playerid, "Cash", PlayerInfo[playerid][pCash]-80000);
						strcpy(PlayerVehicleInfo[playerid][i][pvNumberPlate], tmpSz_NumPlate, 32);
						SendClientMessageEx(playerid, COLOR_WHITE, "Your registration plate has successfully been configured.");
					}
					else {
						new
							tmpSz_NumPlate[32];

						GetPVarString(playerid, "szNumPS", tmpSz_NumPlate, sizeof(tmpSz_NumPlate));
						RegisterVehicleNumberPlate(PlayerVehicleInfo[playerid][i][pvId], tmpSz_NumPlate);
						strcpy(PlayerVehicleInfo[playerid][i][pvNumberPlate], tmpSz_NumPlate, 32);
						SetPVarInt(playerid, "Cash", PlayerInfo[playerid][pCash]-100000);
						SendClientMessageEx(playerid, COLOR_WHITE, "Your registration plate has successfully been configured.");
					}

					return 1;
				}
			}
		}
	}*/

	if(dialogid == DIALOG_NUMBER_PLATE) {
		if(response) {
			if(strlen(inputtext) < 1 || strlen(inputtext) > 8) {
				SendClientMessageEx(playerid, COLOR_WHITE, "{AA3333}LOI:{FFFF00} Bien so chi duoc dai 1-8 ky tu.");
			}
			else {
				if(strfind("XMT", inputtext, true) != -1) {
					SendClientMessageEx(playerid, COLOR_WHITE, "{AA3333}LOI:{FFFF00} Khong duoc dung \"XMT\" trong bien so.");
					return 1;
				}

				SetPVarString(playerid, "szNumPS", inputtext);

				new
					vstring[1024]; // ew, another 4096 bytes of memory down the drain

				for(new i = 0; i < MAX_PLAYERVEHICLES; i++)
				{
					if(PlayerVehicleInfo[playerid][i][pvId] != INVALID_PLAYER_VEHICLE_ID)
					{
						format(vstring, sizeof(vstring), "%s\n%s", vstring, GetVehicleName(PlayerVehicleInfo[playerid][i][pvId]));
					}
					else
					{
						format(vstring, sizeof(vstring), "%s\nTrong", vstring);
					}
				}

				ShowPlayerDialogEx(playerid, DIALOG_NUMBER_PLATE_CHOSEN, DIALOG_STYLE_LIST, "Chon bien so xe", vstring, "Chon", "Huy");
			}
		}

		/*if(PlayerInfo[playerid][pDonateRank] > 0) {
			PlayerInfo[playerid][pMoney] -= 80000;
			SendClientMessageEx(playerid, COLOR_WHITE, "Your new number plate has been configured!");
			RegisterVehicleNumberPlate();
		}
		else {
			PlayerInfo[playerid][pMoney] -= 100000;
			SendClientMessageEx(playerid, COLOR_WHITE, "Your new number plate has been configured!");
			RegisterVehicleNumberPlate();
		}*/
	}
	if(dialogid == NMUTE)
	{
		if(response == 1)
		{
			switch(listitem)
			{
				case 0: // Jailtime
				{
					if(PlayerInfo[playerid][pNMuteTotal] < 4)
					{
						if(GetPVarType(playerid, "IsInArena"))
						{
							LeavePaintballArena(playerid, GetPVarInt(playerid, "IsInArena"));
						}
						PlayerInfo[playerid][pNMute] = 0;
						ResetPlayerWeaponsEx(playerid);
						PlayerInfo[playerid][pJailTime] += PlayerInfo[playerid][pNMuteTotal]*15*60;
						strcpy(PlayerInfo[playerid][pPrisonReason], "[OOC] NMute Prison", 128);
						PhoneOnline[playerid] = 1;
						SetPlayerInterior(playerid, 1);
						PlayerInfo[playerid][pInt] = 1;
						new rand = random(sizeof(OOCPrisonSpawns));
						Streamer_UpdateEx(playerid, OOCPrisonSpawns[rand][0], OOCPrisonSpawns[rand][1], OOCPrisonSpawns[rand][2]);
						SetPlayerPos(playerid, OOCPrisonSpawns[rand][0], OOCPrisonSpawns[rand][1], OOCPrisonSpawns[rand][2]);
						SetPlayerSkin(playerid, 50);
						SetPlayerColor(playerid, TEAM_APRISON_COLOR);
						Player_StreamPrep(playerid, OOCPrisonSpawns[rand][0], OOCPrisonSpawns[rand][1], OOCPrisonSpawns[rand][2], FREEZE_TIME);
					}
					else if(PlayerInfo[playerid][pNMuteTotal] >= 4 || PlayerInfo[playerid][pNMuteTotal] < 7)
					{
						if(GetPVarType(playerid, "IsInArena"))
						{
							LeavePaintballArena(playerid, GetPVarInt(playerid, "IsInArena"));
						}
						PlayerInfo[playerid][pNMute] = 0;
						GameTextForPlayer(playerid, "~w~Chao mung den ~n~~r~Fort DeMorgan", 5000, 3);
						ResetPlayerWeaponsEx(playerid);
						PlayerInfo[playerid][pJailTime] += PlayerInfo[playerid][pNMuteTotal]*15*60;
						PhoneOnline[playerid] = 1;
						SetPlayerInterior(playerid, 1);
						PlayerInfo[playerid][pInt] = 1;
						new rand = random(sizeof(OOCPrisonSpawns));
						Streamer_UpdateEx(playerid, OOCPrisonSpawns[rand][0], OOCPrisonSpawns[rand][1], OOCPrisonSpawns[rand][2]);
						SetPlayerPos(playerid, OOCPrisonSpawns[rand][0], OOCPrisonSpawns[rand][1], OOCPrisonSpawns[rand][2]);
						SetPlayerSkin(playerid, 50);
						SetPlayerColor(playerid, TEAM_APRISON_COLOR);
						Player_StreamPrep(playerid, OOCPrisonSpawns[rand][0], OOCPrisonSpawns[rand][1], OOCPrisonSpawns[rand][2], FREEZE_TIME);
					}
					strcpy(PlayerInfo[playerid][pPrisonReason], "[OOC][NEWB-UNMUTE]", 128);
					format(string,sizeof(string),"{AA3333}AdmWarning{FFFF00}: %s dang chiu %d phut giam de go cam Newbie.",GetPlayerNameEx(playerid),PlayerInfo[playerid][pNMuteTotal]*15);
					ABroadCast(COLOR_YELLOW,string,2);
				}
				case 1: // Fine
				{
					new playername[MAX_PLAYER_NAME];
					GetPlayerName(playerid, playername, sizeof(playername));

					new totalwealth = PlayerInfo[playerid][pAccount] + GetPlayerCash(playerid);
					if(PlayerInfo[playerid][pPhousekey] != INVALID_HOUSE_ID && HouseInfo[PlayerInfo[playerid][pPhousekey]][hOwnerID] == GetPlayerSQLId(playerid)) totalwealth += HouseInfo[PlayerInfo[playerid][pPhousekey]][hSafeMoney];
					if(PlayerInfo[playerid][pPhousekey2] != INVALID_HOUSE_ID && HouseInfo[PlayerInfo[playerid][pPhousekey2]][hOwnerID] == GetPlayerSQLId(playerid)) totalwealth += HouseInfo[PlayerInfo[playerid][pPhousekey2]][hSafeMoney];
					if(PlayerInfo[playerid][pPhousekey3] != INVALID_HOUSE_ID && HouseInfo[PlayerInfo[playerid][pPhousekey3]][hOwnerID] == GetPlayerSQLId(playerid)) totalwealth += HouseInfo[PlayerInfo[playerid][pPhousekey3]][hSafeMoney];

					new fine = 10 * totalwealth / 100;
					if(GetPlayerCash(playerid) < fine || totalwealth < 0)
					{
						format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s da tu choi go cam Newbie (Khong du tien).", GetPlayerNameEx(playerid));
						ABroadCast(COLOR_YELLOW, string, 2);
						return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong du tien de go cam chat!");
					}

					format(string,sizeof(string),"{AA3333}AdmWarning{FFFF00}: %s da nop phat $%d de go cam Newbie Chat.",GetPlayerNameEx(playerid),fine);
					GivePlayerCash(playerid,-fine);
					ABroadCast(COLOR_YELLOW,string,2);
					PlayerInfo[playerid][pNMute] = 0;
				}
			}
		}
		else
		{
			format(string,sizeof(string),"{AA3333}AdmWarning{FFFF00}: %s da huy hinh phat go cam Newbie Chat.",GetPlayerNameEx(playerid));
			ABroadCast(COLOR_YELLOW,string,2);
		}
	}
	if(dialogid == ADMUTE)
	{
		if(response == 1)
		{
			switch(listitem)
			{
				case 0: // Jailtime
				{
					if(PlayerInfo[playerid][pADMuteTotal] < 4)
					{
						if(GetPVarType(playerid, "IsInArena"))
						{
							LeavePaintballArena(playerid, GetPVarInt(playerid, "IsInArena"));
						}
						PlayerInfo[playerid][pADMute] = 0;
						ResetPlayerWeaponsEx(playerid);
						PlayerInfo[playerid][pJailTime] += PlayerInfo[playerid][pADMuteTotal]*15*60;
						PhoneOnline[playerid] = 1;
						SetPlayerInterior(playerid, 1);
						PlayerInfo[playerid][pInt] = 1;
						new rand = random(sizeof(OOCPrisonSpawns));
						Streamer_UpdateEx(playerid, OOCPrisonSpawns[rand][0], OOCPrisonSpawns[rand][1], OOCPrisonSpawns[rand][2]);
						SetPlayerPos(playerid, OOCPrisonSpawns[rand][0], OOCPrisonSpawns[rand][1], OOCPrisonSpawns[rand][2]);
						SetPlayerSkin(playerid, 50);
						SetPlayerColor(playerid, TEAM_APRISON_COLOR);
						Player_StreamPrep(playerid, OOCPrisonSpawns[rand][0], OOCPrisonSpawns[rand][1], OOCPrisonSpawns[rand][2], FREEZE_TIME);
					}
					else if(PlayerInfo[playerid][pADMuteTotal] >= 4 || PlayerInfo[playerid][pADMuteTotal] < 7)
					{
						if(GetPVarType(playerid, "IsInArena"))
						{
							LeavePaintballArena(playerid, GetPVarInt(playerid, "IsInArena"));
						}
						PlayerInfo[playerid][pADMute] = 0;
						GameTextForPlayer(playerid, "~w~Chao mung den ~n~~r~Fort DeMorgan", 5000, 3);
						ResetPlayerWeaponsEx(playerid);
						PlayerInfo[playerid][pJailTime] += PlayerInfo[playerid][pADMuteTotal]*15*60;
						PhoneOnline[playerid] = 1;
						SetPlayerInterior(playerid, 1);
						PlayerInfo[playerid][pInt] = 1;
						new rand = random(sizeof(OOCPrisonSpawns));
						Streamer_UpdateEx(playerid, OOCPrisonSpawns[rand][0], OOCPrisonSpawns[rand][1], OOCPrisonSpawns[rand][2]);
						SetPlayerPos(playerid, OOCPrisonSpawns[rand][0], OOCPrisonSpawns[rand][1], OOCPrisonSpawns[rand][2]);
						SetPlayerSkin(playerid, 50);
						SetPlayerColor(playerid, TEAM_APRISON_COLOR);
						Player_StreamPrep(playerid, OOCPrisonSpawns[rand][0], OOCPrisonSpawns[rand][1], OOCPrisonSpawns[rand][2], FREEZE_TIME);
					}
					strcpy(PlayerInfo[playerid][pPrisonReason], "[OOC][AD-UNMUTE]", 128);
					format(string,sizeof(string),"{AA3333}AdmWarning{FFFF00}: %s bi giam %d phut de mo cam quang cao.",GetPlayerNameEx(playerid),PlayerInfo[playerid][pADMuteTotal]*15);
					ABroadCast(COLOR_YELLOW,string,2);
				}
				case 1: // Fine
				{
					new playername[MAX_PLAYER_NAME];
					GetPlayerName(playerid, playername, sizeof(playername));

					new totalwealth = PlayerInfo[playerid][pAccount] + GetPlayerCash(playerid);
					if(PlayerInfo[playerid][pPhousekey] != INVALID_HOUSE_ID && HouseInfo[PlayerInfo[playerid][pPhousekey]][hOwnerID] == GetPlayerSQLId(playerid)) totalwealth += HouseInfo[PlayerInfo[playerid][pPhousekey]][hSafeMoney];
					if(PlayerInfo[playerid][pPhousekey2] != INVALID_HOUSE_ID && HouseInfo[PlayerInfo[playerid][pPhousekey2]][hOwnerID] == GetPlayerSQLId(playerid)) totalwealth += HouseInfo[PlayerInfo[playerid][pPhousekey2]][hSafeMoney];
					if(PlayerInfo[playerid][pPhousekey3] != INVALID_HOUSE_ID && HouseInfo[PlayerInfo[playerid][pPhousekey3]][hOwnerID] == GetPlayerSQLId(playerid)) totalwealth += HouseInfo[PlayerInfo[playerid][pPhousekey3]][hSafeMoney];

					new fine = 10 * totalwealth / 100;
					if(GetPlayerCash(playerid) < fine)
					{
						format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s tu choi mo cam quang cao (Khong du tien).", GetPlayerNameEx(playerid));
						ABroadCast(COLOR_YELLOW, string, 2);
						return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong du tien mo cam!");
					}

					PlayerInfo[playerid][pADMute] = 0;
					format(string,sizeof(string),"{AA3333}AdmWarning{FFFF00}: %s tra phat $%d de mo cam quang cao.",GetPlayerNameEx(playerid),fine);
					GivePlayerCash(playerid,-fine);
					ABroadCast(COLOR_YELLOW,string,2);
				}
			}
		}
		else
		{
			format(string,sizeof(string),"{AA3333}AdmWarning{FFFF00}: %s huy hinh phat mo cam quang cao.",GetPlayerNameEx(playerid));
			ABroadCast(COLOR_YELLOW,string,2);
		}
	}
	if(dialogid == RTONEMENU) // Ringtone Menu
	{
		if(response == 1)
		{
			switch(listitem)
			{
				case 0:
				{
					PlayerInfo[playerid][pRingtone] = 1;
					//SendAudioToPlayer(playerid, 51, 100);
				}
				case 1:
				{
					PlayerInfo[playerid][pRingtone] = 2;
					//SendAudioToPlayer(playerid, 52, 100);
				}
				case 2:
				{
					PlayerInfo[playerid][pRingtone] = 3;
					//SendAudioToPlayer(playerid, 53, 100);
				}
				case 3:
				{
					PlayerInfo[playerid][pRingtone] = 4;
					//SendAudioToPlayer(playerid, 54, 100);
				}
				case 4:
				{
					PlayerInfo[playerid][pRingtone] = 5;
					//SendAudioToPlayer(playerid, 55, 100);
				}
				case 5:
				{
					PlayerInfo[playerid][pRingtone] = 6;
					//SendAudioToPlayer(playerid, 56, 100);
				}
				case 6:
				{
					PlayerInfo[playerid][pRingtone] = 7;
					//SendAudioToPlayer(playerid, 57, 100);
				}
				case 7:
				{
					PlayerInfo[playerid][pRingtone] = 8;
					//SendAudioToPlayer(playerid, 58, 100);
				}
				case 8:
				{
					PlayerInfo[playerid][pRingtone] = 9;
					//SendAudioToPlayer(playerid, 59, 100);
				}
				case 9:
				{
					PlayerInfo[playerid][pRingtone] = 0;
				}
			}
			RemovePlayerAttachedObject(playerid, 8);
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
		}
	}
	if(dialogid == MAINMENU || dialogid == MAINMENU2)
	{
		if(response == 0)
		{
			SendClientMessage(playerid, COLOR_RED, "MAY CHU: Ban da bi tu dong kick.");
			SetTimerEx("KickEx", 1000, false, "i", playerid);
		}
		else if(dialogid == MAINMENU)
		{
			if(!isnull(inputtext) && strlen(inputtext) <= 64 && gPlayerLogged{playerid} == 0)
			{
				g_mysql_AccountLoginCheck(playerid, inputtext);
			}
			else
			{
				ShowMainMenuDialog(playerid, 1);
			}
		}
		else if(dialogid == MAINMENU2)
		{
			if(PassComplexCheck && CheckPasswordComplexity(inputtext) != 1) return ShowMainMenuDialog(playerid, 2);
			if(!isnull(inputtext) && strlen(inputtext) <= 64)
			{
				g_mysql_CreateAccount(playerid, inputtext);
			}
			else ShowMainMenuDialog(playerid, 2);
		}
		return 1;
	}
	if(dialogid == MAINMENU3)
	{
		Kick(playerid);
	}
	if (dialogid == ELEVATOR3 && response)
	{
		if (listitem == 0)
		{
			SetPlayerPos(playerid, 1564.8, -1666.2, 28.3);
			SetPlayerInterior(playerid, 0);
			PlayerInfo[playerid][pVW] = 0;
			SetPlayerVirtualWorld(playerid, 0);
		}
		else
		{
			SetPlayerPos(playerid, 1568.6676, -1689.9708, 6.2188);
			SetPlayerInterior(playerid, 0);
			PlayerInfo[playerid][pVW] = 0;
			SetPlayerVirtualWorld(playerid, 0);
		}
	}
	if (dialogid == ELEVATOR && response)
	{
		if (listitem == 0)
		{
			SetPlayerPos(playerid, 276.0980, 122.1232, 1004.6172);
			SetPlayerInterior(playerid, 10);
			PlayerInfo[playerid][pVW] = 133337;
			SetPlayerVirtualWorld(playerid, 133337);
		}
		else
		{
			SetPlayerPos(playerid, 1568.6676, -1689.9708, 6.2188);
			SetPlayerInterior(playerid, 0);
			PlayerInfo[playerid][pVW] = 0;
			SetPlayerVirtualWorld(playerid, 0);
		}
	}
	if (dialogid == ELEVATOR2 && response)
	{
		if (listitem == 0)
		{
			SetPlayerPos(playerid, 1564.8, -1666.2, 28.3);
			SetPlayerInterior(playerid, 0);
			PlayerInfo[playerid][pVW] = 0;
			SetPlayerVirtualWorld(playerid, 0);
		}
		else
		{
			SetPlayerPos(playerid, 276.0980, 122.1232, 1004.6172);
			SetPlayerInterior(playerid, 10);
			PlayerInfo[playerid][pVW] = 133337;
			SetPlayerVirtualWorld(playerid, 133337);
		}
	}
	if(dialogid == VIPNUMMENU)
	{
		if(response)
		{
			new numberstr = -abs(strval(inputtext));
			if(!(1 < strlen(inputtext) < 9) || strval(inputtext) == 0) { return ShowPlayerDialogEx(playerid, VIPNUMMENU, DIALOG_STYLE_INPUT, "Loi", "So dien thoai phai dai tu 2 den 8 chu so. Hay nhap so moi ben duoi", "Gui", "Huy"); }

			new query[128];
			new numb[16];
			format(numb, sizeof(numb), "%d", numberstr);
			new checkmon = GetPlayerCash(playerid);
			if(PlayerInfo[playerid][pPnumber] == numberstr)
			{
				SendClientMessageEx(playerid,COLOR_GREY," Khong the doi sang so dang dung");
				return 1;
			}
			if(strlen(numb) == 2) return ShowPlayerDialogEx(playerid, VIPNUMMENU, DIALOG_STYLE_INPUT, "Loi", "So dien thoai phai dai tu 2 den 10 chu so. Hay nhap so moi ben duoi", "Gui", "Huy");
			if(strlen(numb) == 3)
			{
				new iCheck = abs(checkmon * 30/100);
				if(GetPlayerCash(playerid) <= iCheck)
			   	{
			   		SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong du tien mua so dien thoai!");
			   		return 1;
			   	}
				if(GetPlayerCash(playerid) >= 1000000)
				{
					SetPVarInt(playerid, "WantedPh", numberstr);
					SetPVarInt(playerid, "CurrentPh", PlayerInfo[playerid][pPnumber]);
					SetPVarInt(playerid, "PhChangeCost", iCheck);
					mysql_format(MainPipeline, query, sizeof(query), "SELECT `Username` FROM `accounts` WHERE `PhoneNr` = '%d'", numberstr);
					mysql_tquery(MainPipeline, query, "OnPhoneNumberCheck", "ii", playerid, 1);
					return 1;
				}
				else if(GetPlayerCash(playerid) >= 300000 && GetPlayerCash(playerid) < 1000000)
				{
					SetPVarInt(playerid, "WantedPh", numberstr);
					SetPVarInt(playerid, "CurrentPh", PlayerInfo[playerid][pPnumber]);
					SetPVarInt(playerid, "PhChangeCost", 300000);
					mysql_format(MainPipeline, query, sizeof(query), "SELECT `Username` FROM `accounts` WHERE `PhoneNr` = '%d'",numberstr);
					mysql_tquery(MainPipeline, query, "OnPhoneNumberCheck", "ii", playerid, 1);
					return 1;
				}
				else
				{
					SendClientMessageEx(playerid,COLOR_GREY," Ban khong du tien mua so am 2 chu so, hay thu lai.");
					return 1;
				}
			}
			else if(strlen(numb) == 4)
			{
				new iCheck = abs(checkmon * 20/100);
				if(GetPlayerCash(playerid) <= iCheck)
			   	{
			   		SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong du tien mua so dien thoai!");
			   		return 1;
			   	}
				if(GetPlayerCash(playerid) >= 1000000)
				{
					SetPVarInt(playerid, "WantedPh", numberstr);
					SetPVarInt(playerid, "CurrentPh", PlayerInfo[playerid][pPnumber]);
					SetPVarInt(playerid, "PhChangeCost", iCheck);
					mysql_format(MainPipeline, query, sizeof(query), "SELECT `Username` FROM `accounts` WHERE `PhoneNr` = '%d'",numberstr);
					mysql_tquery(MainPipeline, query, "OnPhoneNumberCheck", "ii", playerid, 1);
					return 1;
				}
				else if(GetPlayerCash(playerid) >= 200000 && GetPlayerCash(playerid) < 1000000)
				{
					SetPVarInt(playerid, "WantedPh", numberstr);
					SetPVarInt(playerid, "CurrentPh", PlayerInfo[playerid][pPnumber]);
					SetPVarInt(playerid, "PhChangeCost", 200000);
					mysql_format(MainPipeline, query, sizeof(query), "SELECT `Username` FROM `accounts` WHERE `PhoneNr` = '%d'",numberstr);
					mysql_tquery(MainPipeline, query, "OnPhoneNumberCheck", "ii", playerid, 1);
					return 1;
				}
				else
				{
					SendClientMessageEx(playerid,COLOR_GREY," Ban khong du tien mua so am 3 chu so, hay thu lai.");
					return 1;
				}
			}
			else if(strlen(numb) >= 5 && strlen(numb) <= 9)
			{
				new iCheck = abs(checkmon * 10/100);
				if(GetPlayerCash(playerid) <= iCheck)
			   	{
			   		SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong du tien mua so dien thoai!");
			   		return 1;
			   	}
				if(GetPlayerCash(playerid) >= 500000)
				{
					SetPVarInt(playerid, "WantedPh", numberstr);
					SetPVarInt(playerid, "CurrentPh", PlayerInfo[playerid][pPnumber]);
					SetPVarInt(playerid, "PhChangeCost", iCheck);
					mysql_format(MainPipeline, query, sizeof(query), "SELECT `Username` FROM `accounts` WHERE `PhoneNr` = '%d'",numberstr);
					mysql_tquery(MainPipeline, query, "OnPhoneNumberCheck", "ii", playerid, 1);
					return 1;
				}
				else if(GetPlayerCash(playerid) >= 50000 && GetPlayerCash(playerid) < 500000)
				{
					SetPVarInt(playerid, "WantedPh", numberstr);
					SetPVarInt(playerid, "CurrentPh", PlayerInfo[playerid][pPnumber]);
					SetPVarInt(playerid, "PhChangeCost", 50000);
					mysql_format(MainPipeline, query, sizeof(query), "SELECT `Username` FROM `accounts` WHERE `PhoneNr` = '%d'",numberstr);
					mysql_tquery(MainPipeline, query, "OnPhoneNumberCheck", "ii", playerid, 1);
					return 1;
				}
				else
				{
					SendClientMessageEx(playerid,COLOR_GREY," Ban khong du tien mua so am 2 chu so, hay thu lai.");
					return 1;
				}
			}
			else return SendClientMessageEx(playerid,COLOR_GREY," Khong the doi so dien thoai!");
		}
		else
		{
			SendClientMessageEx(playerid,COLOR_GREY," Ban da chon khong doi so.");
		}

	}
	if(dialogid == VIPNUMMENU2)
	{
		if(response)
		{
			SendClientMessageEx(playerid, COLOR_GREEN, "________________________________________________");
			SendClientMessageEx(playerid, COLOR_YELLOW, "So dien thoai chua duoc dung, dang cap nhat so cua ban.");
			format(string,sizeof(string),"Ban da doi so tu %d sang %d voi gia $%s", GetPVarInt(playerid, "CurrentPh"), GetPVarInt(playerid, "WantedPh"), number_format(GetPVarInt(playerid, "PhChangeCost")));
			SendClientMessageEx(playerid,COLOR_GREY,string);
			PlayerInfo[playerid][pPnumber] = GetPVarInt(playerid, "WantedPh");
			new iCost = abs(GetPVarInt(playerid, "PhChangeCost"));
			GivePlayerCash(playerid, -iCost);
			mysql_format(MainPipeline, string, sizeof(string), "UPDATE `accounts` SET `PhoneNr` = %d WHERE `id` = '%d'", PlayerInfo[playerid][pPnumber], GetPlayerSQLId(playerid));
			mysql_tquery(MainPipeline, string, "OnQueryFinish", "ii", SENDDATA_THREAD, playerid);
			DeletePVar(playerid, "PhChangerId");
			DeletePVar(playerid, "WantedPh");
			DeletePVar(playerid, "PhChangeCost");
			DeletePVar(playerid, "CurrentPh");
		}
		else
		{
			SendClientMessageEx(playerid,COLOR_GREY," Ban da chon khong doi so.");
			DeletePVar(playerid, "PhChangerId");
			DeletePVar(playerid, "WantedPh");
			DeletePVar(playerid, "PhChangeCost");
			DeletePVar(playerid, "CurrentPh");
		}
	}
	/*if(dialogid == RENTMENU)
	{
		if(response)
			{
				switch(listitem)
					{
					case 0://15 Minutes
						{
							if(GetPlayerCash(playerid) < 1000)
								{
									SendClientMessageEx(playerid, COLOR_GRAD1, "You don't have enough money!");
									RemovePlayerFromVehicle(playerid);
									new Float:slx, Float:sly, Float:slz;
									GetPlayerPos(playerid, slx, sly, slz);
									SetPlayerPos(playerid, slx, sly, slz+1.2);
									TogglePlayerControllable(playerid,1);
								}
							else
								{
									GivePlayerCash(playerid,-1000);
									gBike[playerid] = 3;
									gBikeRenting[playerid] = 1;
									TogglePlayerControllable(playerid, 1);
									SendClientMessageEx(playerid,COLOR_GREY," You have rented a bike for 15 minutes, enjoy!");
									SetPVarInt(playerid, "RentTime", SetTimerEx("RentTimer", (1000*60)*15, true, "d", playerid));
								}
						}
					case 1: // 30 minutes
						{
						   if(GetPlayerCash(playerid) < 2000)
								{
									SendClientMessageEx(playerid, COLOR_GRAD1, "You don't have enough money!");
									RemovePlayerFromVehicle(playerid);
									new Float:slx, Float:sly, Float:slz;
									GetPlayerPos(playerid, slx, sly, slz);
									SetPlayerPos(playerid, slx, sly, slz+1.2);
									TogglePlayerControllable(playerid,1);
								}
							else
							{
								GivePlayerCash(playerid,-2000);
								gBike[playerid] = 6;
								gBikeRenting[playerid] = 1;
								TogglePlayerControllable(playerid, 1);
								SendClientMessageEx(playerid,COLOR_GREY," You have rented a bike for 30 minutes, enjoy!");
								SetPVarInt(playerid, "RentTime", SetTimerEx("RentTimer", (1000*60)*30, true, "d", playerid));
							}
						}
					case 2: // 1 hour
						{
							if(GetPlayerCash(playerid) < 4000)
								{
									SendClientMessageEx(playerid, COLOR_GRAD1, "You don't have enough money!");
									RemovePlayerFromVehicle(playerid);
									new Float:slx, Float:sly, Float:slz;
									GetPlayerPos(playerid, slx, sly, slz);
									SetPlayerPos(playerid, slx, sly, slz+1.2);
									TogglePlayerControllable(playerid,1);
								}
							else
							{
								GivePlayerCash(playerid,-4000);
								gBike[playerid] = 12;
								gBikeRenting[playerid] = 1;
								TogglePlayerControllable(playerid, 1);
								SendClientMessageEx(playerid,COLOR_GREY," You have rented a bike for an hour, enjoy!");
								SetPVarInt(playerid, "RentTime", SetTimerEx("RentTimer", (1000*60)*60, true, "d", playerid));
							}
						}
					}
			}
		if(!response)
		{
			RemovePlayerFromVehicle(playerid);
			new Float:slx, Float:sly, Float:slz;
			GetPlayerPos(playerid, slx, sly, slz);
			SetPlayerPos(playerid, slx, sly, slz+1.2);
			TogglePlayerControllable(playerid,1);
			SendClientMessageEx(playerid,COLOR_GREY," You may only use these bikes if you rent one.");
		}

	}*/

	if(dialogid == 1348)
	{
		if(response)
		{
			new
				Float: carPosF[3],
				miscid = GetPVarInt(playerid, "playeraffectedcarTP"),
				v = ListItemTrackId[playerid][listitem];
			GetVehiclePos(PlayerVehicleInfo[miscid][v][pvId], carPosF[0], carPosF[1], carPosF[2]);
			SetPlayerVirtualWorld(playerid,GetVehicleVirtualWorld(PlayerVehicleInfo[miscid][v][pvId]));
			SetPlayerPos(playerid, carPosF[0], carPosF[1], carPosF[2]);
		}
	}
	if(dialogid == GOTOPLAYERCAR)
	{
		if(response == 1)
		{
			for(new i = 0; i < MAX_PLAYERVEHICLES; i++)
			{
				if(listitem == i)
				{
					new Float: carPos[3], id = GetPVarInt(playerid, "playeraffectedcarTP");
					if(PlayerVehicleInfo[id][i][pvId] > INVALID_PLAYER_VEHICLE_ID)
					{
						GetVehiclePos(PlayerVehicleInfo[id][i][pvId], carPos[0], carPos[1], carPos[2]);
						SetPlayerVirtualWorld(playerid,GetVehicleVirtualWorld(PlayerVehicleInfo[id][i][pvId]));
						SetPlayerInterior(playerid,0);
						SetPlayerPos(playerid, carPos[0], carPos[1], carPos[2]);
					}
					else
					{
						SendClientMessageEx(playerid, COLOR_WHITE, "Khong the den o xe trong, bi vo hieu hoac bi tam giu.");
					}
				}
			}
		}
	}
	if(dialogid == VEHICLESTORAGE && response) {

		//if(!(400 <= PlayerVehicleInfo[playerid][listitem][pvModelId] <= 611))
		//printf("DEBUG: listitem: %d, Vehicle Slots: %d", listitem, GetPlayerVehicleSlots(playerid));
		if(listitem == GetPlayerVehicleSlots(playerid)) {
			new szstring[128];
			SetPVarInt(playerid, "MiscShop", 7);
			format(szstring, sizeof(szstring), "Additional Vehicle Slot\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[23][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[23][sItemPrice]));
			return ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Mua them o xe", szstring, "Mua", "Huy");
		}

		if(PlayerVehicleInfo[playerid][listitem][pvSpawned]) {

			new
				iVehicleID = PlayerVehicleInfo[playerid][listitem][pvId];

			if((!IsVehicleSeatOccupied(iVehicleID) || IsPlayerInVehicle(playerid, iVehicleID)) && !IsVehicleInTow(iVehicleID) && !PlayerVehicleInfo[playerid][listitem][pvBeingPickLocked]) {

				new
					Float: vehiclehealth;

				GetVehicleHealth(iVehicleID, vehiclehealth);

				if(vehiclehealth < 800) {
					SendClientMessageEx(playerid, COLOR_WHITE, "Xe hong qua nang de cat.");
				}
				else if (GetPVarInt(playerid, "Refueling") == PlayerVehicleInfo[playerid][listitem][pvId])
					SendClientMessageEx(playerid, COLOR_WHITE, "Khong the cat xe khi dang do xang.");
				else if (WheelClamp{PlayerVehicleInfo[playerid][listitem][pvId]})
					SendClientMessageEx(playerid, COLOR_WHITE, "Hien khong the cat xe nay.");
				else {
					--PlayerCars;
					VehicleSpawned[playerid]--;
					PlayerVehicleInfo[playerid][listitem][pvSpawned] = 0;
					PlayerVehicleInfo[playerid][listitem][pvFuel] = VehicleFuel[iVehicleID];
					GetVehicleHealth(PlayerVehicleInfo[playerid][listitem][pvId], PlayerVehicleInfo[playerid][listitem][pvHealth]);
					DestroyVehicle(iVehicleID);
					if(IsValidDynamicArea(iVehEnterAreaID[iVehicleID])) DestroyDynamicArea(iVehEnterAreaID[iVehicleID]);
					PlayerVehicleInfo[playerid][listitem][pvId] = INVALID_PLAYER_VEHICLE_ID;
					g_mysql_SaveVehicle(playerid, listitem);

					strunpack(vehicleName, VehicleName[PlayerVehicleInfo[playerid][listitem][pvModelId] - 400], sizeof(vehicleName));
					SendClientMessageEx(playerid, COLOR_WHITE, "Ban da cat %s. Xe da bien mat.", vehicleName);
					CheckPlayerVehiclesForDesync(playerid);
				}
			}
			else SendClientMessageEx(playerid, COLOR_WHITE, "Xe dang co nguoi ngoi, chua the cat luc nay.");
		}
		else if(PlayerVehicleInfo[playerid][listitem][pvImpounded]) {
			SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lay xe bi tam giu ra. Hay den DMV tai Dillimore de chuoc xe.");
		}
		else if(PlayerVehicleInfo[playerid][listitem][pvDisabled]) {
			SendClientMessageEx(playerid, COLOR_WHITE, "Khong the dung xe bi khoa do cap VIP cua ban (han che xe).");
		}
		else if((PlayerInfo[playerid][pRVehRestricted] > gettime() || PlayerVehicleInfo[playerid][listitem][pvRestricted] > gettime()) && IsRestrictedVehicle(PlayerVehicleInfo[playerid][listitem][pvModelId]))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen lay xe gioi han nay ra.");
		}
		else if(!PlayerVehicleInfo[playerid][listitem][pvSpawned]) {
			if(PlayerInfo[playerid][pDonateRank] == 0 && VehicleSpawned[playerid] >= 2) {
				SendClientMessageEx(playerid, COLOR_GREY, "Non-VIP chi duoc tao 2 xe. Hay cat xe de tao xe khac.");
			}
			else if(PlayerInfo[playerid][pDonateRank] == 1 && VehicleSpawned[playerid] >= 2) {
				SendClientMessageEx(playerid, COLOR_GREY, "Bronze VIP chi duoc tao 2 xe. Hay cat xe de tao xe khac.");
			}
			else if(PlayerInfo[playerid][pDonateRank] == 2 && VehicleSpawned[playerid] >= 2) {
				SendClientMessageEx(playerid, COLOR_GREY, "Silver VIP chi duoc tao 2 xe. Hay cat xe de tao xe khac.");
			}
			else if(PlayerInfo[playerid][pDonateRank] == 3 && VehicleSpawned[playerid] >= 3) {
				SendClientMessageEx(playerid, COLOR_GREY, "Gold VIP chi duoc tao 3 xe. Hay cat xe de tao xe khac.");
			}
			else if(PlayerInfo[playerid][pDonateRank] == 4 && VehicleSpawned[playerid] >= 5) {
				SendClientMessageEx(playerid, COLOR_GREY, "Platinum VIP chi duoc tao 5 xe. Hay cat xe de tao xe khac.");
			}
			else if(!(0 <= PlayerInfo[playerid][pDonateRank] <= 4)) {
				SendClientMessageEx(playerid, COLOR_GREY, "Cap VIP cua ban khong hop le.");
			}
			else if((PlayerVehicleInfo[playerid][listitem][pvModelId]) < 400) {
				SendClientMessageEx(playerid, COLOR_GREY, "O xe nay trong.");
			}
			else {

				new
					iVeh = CreateVehicle(PlayerVehicleInfo[playerid][listitem][pvModelId], PlayerVehicleInfo[playerid][listitem][pvPosX], PlayerVehicleInfo[playerid][listitem][pvPosY], (PlayerVehicleInfo[playerid][listitem][pvModelId] == 460) ? PlayerVehicleInfo[playerid][listitem][pvPosZ]+5 : PlayerVehicleInfo[playerid][listitem][pvPosZ], PlayerVehicleInfo[playerid][listitem][pvPosAngle],PlayerVehicleInfo[playerid][listitem][pvColor1], PlayerVehicleInfo[playerid][listitem][pvColor2], -1);

				SetVehicleVirtualWorld(iVeh, PlayerVehicleInfo[playerid][listitem][pvVW]);
				LinkVehicleToInterior(iVeh, PlayerVehicleInfo[playerid][listitem][pvInt]);

				switch(GetVehicleModel(iVeh)) {
					case 519, 553, 508: {
						iVehEnterAreaID[iVeh] = CreateDynamicSphere(PlayerVehicleInfo[playerid][listitem][pvPosX]+2, PlayerVehicleInfo[playerid][listitem][pvPosY], PlayerVehicleInfo[playerid][listitem][pvPosZ], 4, GetVehicleVirtualWorld(iVeh));
						AttachDynamicAreaToVehicle(iVehEnterAreaID[iVeh], iVeh);
						// Streamer_SetIntData(STREAMER_TYPE_AREA, iVehEnterAreaID[iVeh], E_STREAMER_EXTRA_ID, iVeh);
					}
				}

				++PlayerCars;
				VehicleSpawned[playerid]++;
				PlayerVehicleInfo[playerid][listitem][pvSpawned] = 1;
				PlayerVehicleInfo[playerid][listitem][pvId] = iVeh;
				if(PlayerVehicleInfo[playerid][listitem][pvLocked] == 1) LockPlayerVehicle(playerid, iVeh, PlayerVehicleInfo[playerid][listitem][pvLock]);
				LoadPlayerVehicleMods(playerid, listitem);
				g_mysql_SaveVehicle(playerid, listitem);

				strunpack(vehicleName, VehicleName[PlayerVehicleInfo[playerid][listitem][pvModelId] - 400], sizeof(vehicleName));
				SendClientMessageEx(playerid, COLOR_WHITE, "Ban da lay %s ra khoi kho.", vehicleName);
				CheckPlayerVehiclesForDesync(playerid);
				Vehicle_ResetData(iVeh);
				VehicleFuel[iVeh] = PlayerVehicleInfo[playerid][listitem][pvFuel];
				new zyear, zmonth, zday;
				getdate(zyear, zmonth, zday);
				if(zombieevent || (zmonth == 10 && zday == 31) || (zmonth == 11 && zday == 1)) SetVehicleHealth(iVeh, PlayerVehicleInfo[playerid][listitem][pvHealth]);
				if (VehicleFuel[iVeh] > 100.0) VehicleFuel[iVeh] = 100.0;

				if(PlayerVehicleInfo[playerid][listitem][pvCrashFlag] == 1 && PlayerVehicleInfo[playerid][listitem][pvCrashX] != 0.0)
				{
					SetVehiclePos(iVeh, PlayerVehicleInfo[playerid][listitem][pvCrashX], PlayerVehicleInfo[playerid][listitem][pvCrashY], PlayerVehicleInfo[playerid][listitem][pvCrashZ]);
					SetVehicleZAngle(iVeh, PlayerVehicleInfo[playerid][listitem][pvCrashAngle]);
					SetVehicleVirtualWorld(iVeh, PlayerVehicleInfo[playerid][listitem][pvCrashVW]);
					PlayerVehicleInfo[playerid][listitem][pvCrashFlag] = 0;
					PlayerVehicleInfo[playerid][listitem][pvCrashVW] = 0;
					PlayerVehicleInfo[playerid][listitem][pvCrashX] = 0.0;
					PlayerVehicleInfo[playerid][listitem][pvCrashY] = 0.0;
					PlayerVehicleInfo[playerid][listitem][pvCrashZ] = 0.0;
					PlayerVehicleInfo[playerid][listitem][pvCrashAngle] = 0.0;
					SendClientMessageEx(playerid, COLOR_WHITE, "Xe cua ban da duoc dua ve vi tri gan nhat truoc khi mat ket noi.");
				}
			}
		}
		else SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lay xe khong ton tai ra.");
	}
	if(dialogid == ADMIN_VEHCHECK && response) {
		if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) { return SendClientMessage(playerid, COLOR_GRAD2, "Ban khong co quyen");  }
		new giveplayerid = GetPVarInt(playerid, "vehcheck_giveplayerid");
		if(!IsPlayerConnected(giveplayerid)) { return SendClientMessage(playerid, COLOR_GRAD2, "Nguoi choi da ngat ket noi"); }
		new	iVehicleID = PlayerVehicleInfo[giveplayerid][listitem][pvId];
		new model;
		model = PlayerVehicleInfo[giveplayerid][listitem][pvModelId];
		PlayerVehicleInfo[giveplayerid][listitem][pvId] = 0;
		PlayerVehicleInfo[giveplayerid][listitem][pvModelId] = 0;
		PlayerVehicleInfo[giveplayerid][listitem][pvPosX] = 0.0;
		PlayerVehicleInfo[giveplayerid][listitem][pvPosY] = 0.0;
		PlayerVehicleInfo[giveplayerid][listitem][pvPosZ] = 0.0;
		PlayerVehicleInfo[giveplayerid][listitem][pvPosAngle] = 0.0;
		PlayerVehicleInfo[giveplayerid][listitem][pvLock] = 0;
		PlayerVehicleInfo[giveplayerid][listitem][pvLocksLeft] = 0;
		PlayerVehicleInfo[giveplayerid][listitem][pvLocked] = 0;
		PlayerVehicleInfo[giveplayerid][listitem][pvPaintJob] = -1;
		PlayerVehicleInfo[giveplayerid][listitem][pvColor1] = 0;
		PlayerVehicleInfo[giveplayerid][listitem][pvImpounded] = 0;
		PlayerVehicleInfo[giveplayerid][listitem][pvColor2] = 0;
		PlayerVehicleInfo[giveplayerid][listitem][pvAllowedPlayerId] = INVALID_PLAYER_ID;
		PlayerVehicleInfo[giveplayerid][listitem][pvPark] = 0;
		PlayerVehicleInfo[giveplayerid][listitem][pvVW] = 0;
		PlayerVehicleInfo[giveplayerid][listitem][pvInt] = 0;
		PlayerVehicleInfo[giveplayerid][listitem][pvAlarm] = 0;
		PlayerVehicleInfo[giveplayerid][listitem][pvAlarmTriggered] = 0;
		PlayerVehicleInfo[giveplayerid][listitem][pvBeingPickLocked] = 0;
		PlayerVehicleInfo[giveplayerid][listitem][pvBeingPickLockedBy] = INVALID_PLAYER_ID;
		PlayerVehicleInfo[giveplayerid][listitem][pvLastLockPickedBy] = 0;
		if(PlayerVehicleInfo[giveplayerid][listitem][pvSpawned])
		{
			PlayerVehicleInfo[giveplayerid][iVehicleID][pvSpawned] = 0;
			DestroyVehicle(iVehicleID);
			PlayerVehicleInfo[playerid][listitem][pvId] = INVALID_PLAYER_VEHICLE_ID;
			VehicleSpawned[giveplayerid]--;

		}
		DestroyPlayerVehicle(giveplayerid, listitem);
		for(new m = 0; m < MAX_MODS; m++)
		{
			PlayerVehicleInfo[giveplayerid][listitem][pvMods][m] = 0;
		}
		format(string, sizeof(string), "AdmCmd: Admin %s has deleted one of %s's(%d) vehicles (VehModel:%d)", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), model);
		Log("logs/admin.log", string);
		format(string, sizeof(string), "AdmCmd: Admin %s da xoa mot xe cua %s (VehModel:%d)", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), model);
		ABroadCast(COLOR_YELLOW, string, 4);

		SendClientMessageEx(giveplayerid, COLOR_YELLOW, "* Admin %s da xoa mot xe cua ban.", GetPlayerNameEx(playerid));

		format(string, sizeof(string), "* Ban da xoa mot xe cua %s.", GetPlayerNameEx(giveplayerid));
		SendClientMessageEx(playerid, COLOR_YELLOW, string);

	}
	if(dialogid == TRACKCAR2)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new Float: carPos[3];
					GetVehiclePos(GetPVarInt(playerid, "RentedVehicle"), carPos[0], carPos[1], carPos[2]);
					if(CheckPointCheck(playerid))
					{
						SendClientMessageEx(playerid, COLOR_WHITE, "Hay huy checkpoint hien tai truoc (ban dang giu goi vat lieu hoac co checkpoint khac).");
					}
					else
					{
						SetPVarInt(playerid, "TrackCar", 1);
						new zone[MAX_ZONE_NAME];
						Get3DZone(carPos[0], carPos[1], carPos[2], zone, sizeof(zone));
						format(string, sizeof(string), "Xe cua ban nam tai %s.", zone);
						SendClientMessageEx(playerid, COLOR_YELLOW, string);
						SetPlayerCheckpoint(playerid, carPos[0], carPos[1], carPos[2], 15.0);
						SendClientMessageEx(playerid, COLOR_WHITE, "Goi y: Hay den checkpoint de tim xe cua ban!");
					}
				}
				case 1:
				{
					new vstring[1024];
					new szCarLocation[MAX_ZONE_NAME];
					for(new i, iModelID; i < MAX_PLAYERVEHICLES; i++)
					{
						if((iModelID = PlayerVehicleInfo[playerid][i][pvModelId] - 400) >= 0)
						{
							Get3DZone(PlayerVehicleInfo[playerid][i][pvPosX], PlayerVehicleInfo[playerid][i][pvPosY], PlayerVehicleInfo[playerid][i][pvPosZ], szCarLocation, sizeof(szCarLocation));
							if(PlayerVehicleInfo[playerid][i][pvImpounded]) {
								strunpack(vehicleName, VehicleName[iModelID], sizeof(vehicleName));
								format(vstring, sizeof(vstring), "%s\n%s (tam giu) | Vi tri: DMV", vstring, vehicleName);
							}
							else if(PlayerVehicleInfo[playerid][i][pvDisabled]) {
								strunpack(vehicleName, VehicleName[iModelID], sizeof(vehicleName));
								format(vstring, sizeof(vstring), "%s\n%s (bi tat) | Vi tri: Chua ro", vstring, vehicleName);
							}
							else if(!PlayerVehicleInfo[playerid][i][pvSpawned]) {
								strunpack(vehicleName, VehicleName[iModelID], sizeof(vehicleName));
								format(vstring, sizeof(vstring), "%s\n%s (da cat)", vstring, vehicleName);
							}
							else {
								strunpack(vehicleName, VehicleName[iModelID], sizeof(vehicleName));
								format(vstring, sizeof(vstring), "%s\n%s | Vi tri: %s", vstring, vehicleName, szCarLocation);
							}
						}
						else strcat(vstring, "\nTrong");
					}
					ShowPlayerDialogEx(playerid, TRACKCAR, DIALOG_STYLE_LIST, "Theo doi GPS xe", vstring, "Theo doi", "Huy");
				}
			}
		}
	}
	if(dialogid == TRACKCAR && response) {
		new Float: carPos[3];
		if(PlayerVehicleInfo[playerid][listitem][pvId] > INVALID_PLAYER_VEHICLE_ID)
		{
			GetVehiclePos(PlayerVehicleInfo[playerid][listitem][pvId], carPos[0], carPos[1], carPos[2]);
			if(CheckPointCheck(playerid))
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "Hay huy checkpoint hien tai truoc (ban dang giu goi vat lieu hoac co checkpoint khac).");
			}
			else
			{
				SetPVarInt(playerid, "TrackCar", 1);
				new zone[MAX_ZONE_NAME];
				Get3DZone(carPos[0], carPos[1], carPos[2], zone, sizeof(zone));
				format(string, sizeof(string), "Xe cua ban nam tai %s.", zone);
				SendClientMessageEx(playerid, COLOR_YELLOW, string);
				SetPlayerCheckpoint(playerid, carPos[0], carPos[1], carPos[2], 15.0);
				SendClientMessageEx(playerid, COLOR_WHITE, "Goi y: Hay den checkpoint de tim xe cua ban!");
			}
		}
		else if(PlayerVehicleInfo[playerid][listitem][pvImpounded]) SendClientMessageEx(playerid, COLOR_WHITE, "Khong the theo doi xe bi tam giu. Hay den DMV tai Dillimore de chuoc xe.");
		else if(PlayerVehicleInfo[playerid][listitem][pvDisabled] == 1) SendClientMessageEx(playerid, COLOR_WHITE, "Khong the theo doi xe bi khoa do cap VIP cua ban (han che xe).");
		else if(PlayerVehicleInfo[playerid][listitem][pvSpawned] == 0) SendClientMessageEx(playerid, COLOR_WHITE, "Khong the theo doi xe da cat. Dung /vstorage de lay xe ra.");
		else SendClientMessageEx(playerid, COLOR_WHITE, "Khong the theo doi xe khong ton tai.");
	}
	if(dialogid == DV_STORAGE && response) {
		new stpos = strfind(inputtext, "(");
		new fpos = strfind(inputtext, ")");
		new caridstr[6], carid;
		strmid(caridstr, inputtext, stpos+1, fpos);
		carid = strval(caridstr);
		if(DynVehicleInfo[carid][gv_iSpawnedID] != INVALID_VEHICLE_ID && !DynVehicleInfo[carid][gv_iDisabled])
		{
			if((!IsVehicleSeatOccupied(DynVehicleInfo[carid][gv_iSpawnedID]) || IsPlayerInVehicle(playerid, DynVehicleInfo[carid][gv_iSpawnedID])) && !IsVehicleInTow(DynVehicleInfo[carid][gv_iSpawnedID]))
			{
				new Float: vHealth;
				GetVehicleHealth(DynVehicleInfo[carid][gv_iSpawnedID], vHealth);

				if(vHealth < 800)
					return SendClientMessageEx(playerid, COLOR_GRAD1, "Xe hong qua nang de cat.");

				if(!IsPlayerInRangeOfVehicle(playerid, DynVehicleInfo[carid][gv_iSpawnedID], 9.0) && !IsWeaponizedVehicle(DynVehicleInfo[carid][gv_iModel]))
					return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong o gan xe.");

				DestroyVehicle(DynVehicleInfo[carid][gv_iSpawnedID]);
				DynVeh[DynVehicleInfo[carid][gv_iSpawnedID]] = -1;
				DynVehicleInfo[carid][gv_iDisabled] = 2;
				DynVehicleInfo[carid][gv_iSpawnedID] = INVALID_VEHICLE_ID;
				for(new i = 0; i != MAX_DV_OBJECTS; i++)
				{
					if(DynVehicleObjInfo[carid][i][gv_iAttachedObjectID] != INVALID_OBJECT_ID)
					{
						DestroyDynamicObject(DynVehicleObjInfo[carid][i][gv_iAttachedObjectID]);
						DynVehicleObjInfo[carid][i][gv_iAttachedObjectID] = INVALID_OBJECT_ID;
					}
				}
				strunpack(vehicleName, VehicleName[DynVehicleInfo[carid][gv_iModel] - 400], sizeof(vehicleName));
				SendClientMessageEx(playerid, COLOR_WHITE, "Ban da cat xe dynamic cua to chuc (%s)", vehicleName);
			}
			else
				return SendClientMessageEx(playerid, COLOR_GRAD1, "Xe nay dang co nguoi ngoi.");
		}
		else if(DynVehicleInfo[carid][gv_iDisabled] == 1) SendClientMessageEx(playerid, COLOR_WHITE, "Khong the lay xe bi tich thu ra. Dung /grepocars de mua lai.");
		else {
			DynVehicleInfo[carid][gv_iDisabled] = 0;
			DynVeh_Spawn(carid);
			strunpack(vehicleName, VehicleName[DynVehicleInfo[carid][gv_iModel] - 400], sizeof(vehicleName));
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da lay xe dynamic cua to chuc ra (%s)", vehicleName);
		}
	}
	if(dialogid == DV_TRACKCAR && response) {
		new stpos = strfind(inputtext, "(");
		new fpos = strfind(inputtext, ")");
		new caridstr[6], carid;
		strmid(caridstr, inputtext, stpos+1, fpos);
		carid = strval(caridstr);
		new Float: carPos[3];
		GetVehiclePos(DynVehicleInfo[carid][gv_iSpawnedID], carPos[0], carPos[1], carPos[2]);
		if(DynVehicleInfo[carid][gv_iSpawnedID] != INVALID_VEHICLE_ID)
		{
			if(CheckPointCheck(playerid))
			{
				SendClientMessageEx(playerid, COLOR_WHITE, "Hay huy checkpoint hien tai truoc (ban dang giu goi vat lieu hoac co checkpoint khac).");
			}
			else
			{
				SetPVarInt(playerid, "DV_TrackCar", 1);
				new zone[MAX_ZONE_NAME];
				Get3DZone(carPos[0], carPos[1], carPos[2], zone, sizeof(zone));
				format(string, sizeof(string), "Xe cua ban nam tai %s.", zone);
				SendClientMessageEx(playerid, COLOR_YELLOW, string);
				SetPlayerCheckpoint(playerid, carPos[0], carPos[1], carPos[2], 15.0);
				SendClientMessageEx(playerid, COLOR_WHITE, "Goi y: Hay den checkpoint de tim xe cua ban!");
				if(carPos[2] > 500.0)
				{
					SendClientMessageEx(playerid, COLOR_WHITE, "Luu y: Xe co the dang do trong garage hoac interior!");
				}
			}
		}
		else if(DynVehicleInfo[carid][gv_iDisabled] == 1) SendClientMessageEx(playerid, COLOR_WHITE, "Khong the theo doi xe bi tich thu. Dung /grepocars de mua lai.");
		else if(DynVehicleInfo[carid][gv_iDisabled] == 2) SendClientMessageEx(playerid, COLOR_WHITE, "Khong the theo doi xe da cat. Dung /dvstorage de lay lai.");
		else SendClientMessageEx(playerid, COLOR_WHITE, "Khong the theo doi xe khong ton tai.");
	}
	// --------------------------------------------------------------------------------------------------
	if(dialogid == VIPWEPSMENU)
	{
		if(!response) return 1;
		if(PlayerInfo[playerid][pDonateRank] < 3 && PlayerInfo[playerid][pTokens] == 0)
		{
			SendClientMessageEx(playerid, COLOR_YELLOW, "VIP: Ban khong co tokens!");
			return 1;
		}
		if(PlayerInfo[playerid][pConnectHours] < 2 || PlayerInfo[playerid][pWRestricted] > 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the dung vi ban dang bi cam so huu vu khi!");
		//if(!CanGetVIPWeapon(playerid) && (listitem < 4 || listitem == 8)) return SendClientMessageEx(playerid, COLOR_WHITE, "You can no longer withdraw anymore VIP weapons today, wait until tomorrow!");
		switch( listitem )
		{
			case 0:
			{

				if(PlayerInfo[playerid][pDonateRank] < 3)
				{
					if(PlayerInfo[playerid][pTokens] < 3)
					{
						SendClientMessageEx(playerid, COLOR_YELLOW, "VIP: Ban khong du tokens.");
						return 1;
					}
					PlayerInfo[playerid][pTokens] -= 3;
					format(string, sizeof(string), "VIP: Da doi 3 tokens lay Desert Eagle, con %d token(s).", PlayerInfo[playerid][pTokens]);
					SendClientMessageEx(playerid, COLOR_YELLOW, string);
				}
				GivePlayerValidWeapon(playerid, 24);
				PlayerInfo[playerid][pVIPGuncount]++;
			}
			case 1:
			{

				if(PlayerInfo[playerid][pDonateRank] < 3)
				{
					if(PlayerInfo[playerid][pTokens] < 2)
					{
						SendClientMessageEx(playerid, COLOR_YELLOW, "VIP: Ban khong du tokens.");
						return 1;
					}
					PlayerInfo[playerid][pTokens] -= 2;
					format(string, sizeof(string), "VIP: Da doi 2 tokens lay shotgun, con %d token(s).", PlayerInfo[playerid][pTokens]);
					SendClientMessageEx(playerid, COLOR_YELLOW, string);
				}
				GivePlayerValidWeapon(playerid, 25);
				PlayerInfo[playerid][pVIPGuncount]++;
			}
			case 2:
			{
				if(PlayerInfo[playerid][pDonateRank] < 3)
				{
					if(PlayerInfo[playerid][pTokens] < 3)
					{
						SendClientMessageEx(playerid, COLOR_YELLOW, "VIP: Ban khong du tokens.");
						return 1;
					}
					PlayerInfo[playerid][pTokens] -= 3;
					format(string, sizeof(string), "VIP: Da doi 3 tokens lay MP5, con %d token(s).", PlayerInfo[playerid][pTokens]);
					SendClientMessageEx(playerid, COLOR_YELLOW, string);
				}
				GivePlayerValidWeapon(playerid, 29);
				PlayerInfo[playerid][pVIPGuncount]++;
			}
			case 3:
			{
				if(PlayerInfo[playerid][pDonateRank] < 3)
				{
					if(PlayerInfo[playerid][pTokens] > 1)
					{
						PlayerInfo[playerid][pTokens] -= 2;
						format(string, sizeof(string), "VIP: Da doi 2 tokens lay silenced pistol, con %d token(s).", PlayerInfo[playerid][pTokens]);
						SendClientMessageEx(playerid, COLOR_YELLOW, string);
					}
					else
					{
						SendClientMessageEx(playerid, COLOR_YELLOW, "VIP: Ban khong du tokens.");
						return 1;
					}
				}
				GivePlayerValidWeapon(playerid, 23);
				PlayerInfo[playerid][pVIPGuncount]++;
			}
			case 4:
			{
				if(PlayerInfo[playerid][pDonateRank] < 3)
				{
					if(PlayerInfo[playerid][pTokens] > 0)
					{
						PlayerInfo[playerid][pTokens] -= 1;
						format(string, sizeof(string), "VIP: Da doi mot token lay golf club, con %d token(s).", PlayerInfo[playerid][pTokens]);
						SendClientMessageEx(playerid, COLOR_YELLOW, string);
					}
					else
					{
						SendClientMessageEx(playerid, COLOR_YELLOW, "VIP: Ban khong du tokens.");
						return 1;
					}
				}
				GivePlayerValidWeapon(playerid, 2);
				PlayerInfo[playerid][pVIPGuncount]++;
			}
			case 5:
			{
				if(PlayerInfo[playerid][pDonateRank] < 3)
				{
					if(PlayerInfo[playerid][pTokens] > 0)
					{
						PlayerInfo[playerid][pTokens] -= 1;
						format(string, sizeof(string), "VIP: Da doi mot token lay baseball bat, con %d token(s).", PlayerInfo[playerid][pTokens]);
						SendClientMessageEx(playerid, COLOR_YELLOW, string);
					}
					else
					{
						SendClientMessageEx(playerid, COLOR_YELLOW, "VIP: Ban khong du tokens.");
						return 1;
					}
				}
				GivePlayerValidWeapon(playerid, 5);
			}
			case 6:
			{
				if(PlayerInfo[playerid][pDonateRank] < 3)
				{
					if(PlayerInfo[playerid][pTokens] > 0)
					{
						PlayerInfo[playerid][pTokens] -= 1;
						format(string, sizeof(string), "VIP: Da doi mot token lay dildo, con %d token(s).", PlayerInfo[playerid][pTokens]);
						SendClientMessageEx(playerid, COLOR_YELLOW, string);
					}
					else
					{
						SendClientMessageEx(playerid, COLOR_YELLOW, "VIP: Ban khong du tokens.");
						return 1;
					}
				}
				GivePlayerValidWeapon(playerid, 10);
				PlayerInfo[playerid][pVIPGuncount]++;
			}
			case 7:
			{
				if(PlayerInfo[playerid][pDonateRank] < 3)
				{
					if(PlayerInfo[playerid][pTokens] > 0)
					{
						PlayerInfo[playerid][pTokens] -= 1;
						format(string, sizeof(string), "VIP: Da doi mot token lay sword, con %d token(s).", PlayerInfo[playerid][pTokens]);
						SendClientMessageEx(playerid, COLOR_YELLOW, string);
					}
					else
					{
						SendClientMessageEx(playerid, COLOR_YELLOW, "VIP: Ban khong du tokens.");
						return 1;
					}
				}
				GivePlayerValidWeapon(playerid, 8);
			}
			case 8:
			{
				if(PlayerInfo[playerid][pDonateRank] < 3)
				{
					if(PlayerInfo[playerid][pTokens] > 1)
					{
						PlayerInfo[playerid][pTokens] -= 2;
						format(string, sizeof(string), "VIP: Da doi 2 tokens lay 9mm, con %d token(s).", PlayerInfo[playerid][pTokens]);
						SendClientMessageEx(playerid, COLOR_YELLOW, string);
					}
					else
					{
						SendClientMessageEx(playerid, COLOR_YELLOW, "VIP: Ban khong du tokens.");
						return 1;
					}
				}
				GivePlayerValidWeapon(playerid, 22);
				PlayerInfo[playerid][pVIPGuncount]++;
			}
		}
	}
	if( dialogid == 3497) //famed change skin
	{
		new skinid = strval(inputtext);
		if(response)
		{
			if(skinid < 1 || skinid > 299)
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Skin ID khong hop le, pham vi skin kha dung la 1-299 !");
				ShowPlayerDialogEx( playerid, 3497, DIALOG_STYLE_INPUT, "Chon skin","Hay nhap Skin ID hop le!", "Wear", "Huy" );
				return 1;
			}
			if(PlayerInfo[playerid][pFamed] == 1)
			{
				if(GetPlayerCash(playerid) < 3000)
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co $3,000.");
					ShowPlayerDialogEx(playerid, 3497, DIALOG_STYLE_INPUT, "Chon skin Famed","Hay nhap Skin ID!\n\n{FF0000}Luu y: Doi skin ton $3,000 voi Old School.", "Doi", "Huy" );
					return 1;
				}
				GivePlayerCash(playerid, -3000);
			}
			if(PlayerInfo[playerid][pFamed] == 2)
			{
				if(GetPlayerCash(playerid) < 1500)
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co $1,500.");
					ShowPlayerDialogEx(playerid, 3497, DIALOG_STYLE_INPUT, "Chon skin Famed","Hay nhap Skin ID!\n\n{FF0000}Luu y: Doi skin ton $1,500 voi Chartered Old School.", "Doi", "Huy" );
					return 1;
				}
				GivePlayerCash(playerid, -1500);
			}
			SendClientMessageEx(playerid, COLOR_YELLOW, "Famed Locker: Ban da doi quan ao.");
			PlayerInfo[playerid][pModel] = skinid;
			SetPlayerSkin(playerid, skinid);
		}
		else return 0;
		return 1;
	}
	if(dialogid == 3498) //Famed Weapon Locker
	{
		if(!response) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da roi Famed Locker.");
		if(PlayerInfo[playerid][pConnectHours] < 2 || PlayerInfo[playerid][pWRestricted] > 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the dung vi ban dang bi cam so huu vu khi!");

		switch(listitem)
		{
			case 0: //Deagle
			{
				GivePlayerValidWeapon(playerid, 24);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Famed Locker] Ban da lay Desert Eagle tu famed locker.");
			}
			case 1: //MP5
			{
				GivePlayerValidWeapon(playerid, 29);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Famed Locker] Ban da lay Semi-Automatic MP5 tu famed locker.");
			}
			case 2: //Shotgun
			{
				GivePlayerValidWeapon(playerid, 25);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Famed Locker] Ban da lay Pump Shotgun tu famed locker.");
			}
			case 3: //Rifle
			{
				GivePlayerValidWeapon(playerid, 33);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Famed Locker] Ban da lay County Rifle tu famed locker.");
			}
			case 4: //SD Pistol
			{
				GivePlayerValidWeapon(playerid, 23);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Famed Locker] Ban da lay Silenced Pistol tu famed locker.");
			}
			case 5: //Katana
			{
				GivePlayerValidWeapon(playerid, 8);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Famed Locker] Ban da lay Japanese Katana tu famed locker.");
			}
			case 6: //Purple Dildo
			{
				GivePlayerValidWeapon(playerid, 10);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Famed Locker] Ban da lay Purple Dildo tu famed locker.");
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Famed Locker] Chuc vui ve...");
			}
			case 7: //White Dildo
			{
				GivePlayerValidWeapon(playerid, 11);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Famed Locker] Ban da lay White Dildo tu famed locker.");
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Famed Locker] Chuc vui ve...");
			}
			case 8: //Big Vibrator
			{
				GivePlayerValidWeapon(playerid, 12);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Famed Locker] Ban da lay Big Vibrator tu famed locker.");
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Famed Locker] Chuc vui ve...");
			}
			case 9: //Silver Vibrator
			{
				GivePlayerValidWeapon(playerid, 13);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Famed Locker] Ban da lay Silver Vibrator tu famed locker.");
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Famed Locker] Chuc vui ve...");
			}
		}
	}
	else if(dialogid == DIALOG_CHANGEPASS2)
	{
		if(!response || strlen(inputtext) == 0) return ShowLoginDialogs(playerid, 0);
		if(response)
		{
			if(PassComplexCheck && CheckPasswordComplexity(inputtext) != 1) return ShowLoginDialogs(playerid, 0);
			if(strlen(inputtext) > 64) return ShowLoginDialogs(playerid, 0), SendClientMessageEx(playerid, COLOR_GREY, "Mat khau khong duoc vuot 64 ky tu.");
			StartPasswordChange(playerid, inputtext);

		}
	}
	else if( dialogid == DIALOG_CHANGEPASS )
	{
		if(!response || strlen(inputtext) == 0) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban da huy doi mat khau." );
		if(response)
		{
			if(PassComplexCheck && CheckPasswordComplexity(inputtext) != 1) return ShowPlayerDialogEx(playerid, DIALOG_CHANGEPASS, DIALOG_STYLE_INPUT, "Doi mat khau", "Nhap mat khau moi cho tai khoan.\n\n\
				- Mat khau phai tu 8 den 64 ky tu\n\
				- Mat khau phai co chu, so va ky tu dac biet.\n\
				- Ky tu khong hop le: %", "Doi", "Thoat" );
			if(strlen(inputtext) > 64) return SendClientMessageEx(playerid, COLOR_WHITE, "Mat khau khong duoc dai qua 64 ky tu.");
			StartPasswordChange(playerid, inputtext);
		}
	}
	else if(dialogid == DIALOG_NAMECHANGE)
	{
		if(!response || strlen(inputtext) == 0) return SendClientMessageEx(playerid, COLOR_WHITE, "Ban da huy doi ten." );
		if(strlen(inputtext) > 20)
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Ten khong duoc vuot 20 ky tu.");
		}
		else
		{
			if(strlen(inputtext) >= 1)
			{
				if(!response)
				{
					SendClientMessageEx(playerid, COLOR_WHITE, "Ban da huy doi ten." );
				}
				else
				{
					if(!IsValidName(inputtext)) return SendClientMessageEx(playerid, COLOR_WHITE, "Ten bi tu choi. Hay dung dung dinh dang: Firstname_Lastname.");


					/*new namechangecost;
					namechangecost = (PlayerInfo[playerid][pLevel]) * 15000;

					if(PlayerInfo[playerid][pDonateRank] >= 3)
					{
						namechangecost = 90*namechangecost/100;
					}*/
					DeletePVar(playerid, "marriagelastname");
					new tmpName[MAX_PLAYER_NAME];
					mysql_escape_string(inputtext, tmpName);
					if(strcmp(inputtext, tmpName, false) != 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ten chua ky tu khong hop le, hay thu lai");
					if((0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS) && (PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[playerid][pMember]][g_iFreeNameChange] && (PlayerInfo[playerid][pDivision] == arrGroupData[PlayerInfo[playerid][pMember]][g_iFreeNameChangeDiv] || arrGroupData[PlayerInfo[playerid][pMember]][g_iFreeNameChangeDiv] == INVALID_DIVISION)))
					{
						if(GetPVarType(playerid, "HasReport")) {
							SendClientMessageEx(playerid, COLOR_GREY, "Chi duoc gui 1 bao cao cung luc. (/cancelreport)");
							return 1;
						}
						SetPVarInt(playerid, "RequestingNameChange", 1);
						SetPVarString(playerid, "NewNameRequest", inputtext);
						SetPVarInt(playerid, "NameChangeCost", 0);
						new playername[MAX_PLAYER_NAME];
						GetPlayerName(playerid, playername, sizeof(playername));
						SendClientMessageEx( playerid, COLOR_YELLOW, "Da yeu cau doi ten tu %s thanh %s mien phi, hay cho Admin duyet.", playername, inputtext );
						SendReportToQue(playerid, "Yeu cau doi ten", 2, 4);
						return 1;
					}
					if(PlayerInfo[playerid][pAdmin] == 1 && PlayerInfo[playerid][pSMod] > 0)
					{
						if(GetPVarType(playerid, "HasReport")) {
							SendClientMessageEx(playerid, COLOR_GREY, "Chi duoc gui 1 bao cao cung luc. (/cancelreport)");
							return 1;
						}
						SetPVarInt(playerid, "RequestingNameChange", 1);
						SetPVarString(playerid, "NewNameRequest", inputtext);
						new playername[MAX_PLAYER_NAME];
						GetPlayerName(playerid, playername, sizeof(playername));
						SendClientMessageEx( playerid, COLOR_YELLOW, "Da yeu cau doi ten tu %s thanh %s mien phi (Senior Mod), hay cho Admin duyet.", playername, inputtext );
						SendReportToQue(playerid, "Yeu cau doi ten", 2, 4);
						return 1;
					}
					if(gettime() >= PlayerInfo[playerid][pNextNameChange])
					{
						if(GetPVarType(playerid, "HasReport")) return SendClientMessageEx(playerid, COLOR_GREY, "Chi duoc gui 1 bao cao cung luc. (/cancelreport)");
						SetPVarInt(playerid, "RequestingNameChange", 1);
						SetPVarString(playerid, "NewNameRequest", inputtext);
						SetPVarInt(playerid, "NameChangeCost", 1);
						new playername[MAX_PLAYER_NAME];
						GetPlayerName(playerid, playername, sizeof(playername));
						SendClientMessageEx( playerid, COLOR_YELLOW, "Da yeu cau doi ten tu %s thanh %s mien phi, hay cho Admin duyet.", playername, inputtext );
						SendReportToQue(playerid, "Yeu cau doi ten", 2, 4);
						return 1;
					}
					/*
					if(PlayerInfo[playerid][pCredits] >= ShopItems[40][sItemPrice])
					{
						if(GetPVarType(playerid, "HasReport")) return SendClientMessageEx(playerid, COLOR_GREY, "You can only have 1 active report at a time. (/cancelreport)");
						new String[128];
						SetPVarInt(playerid, "RequestingNameChange", 1);
						SetPVarString(playerid, "NewNameRequest", inputtext);
						SetPVarInt(playerid, "NameChangeCost", 2);
						new playername[MAX_PLAYER_NAME];
						GetPlayerName(playerid, playername, sizeof(playername));
						format( String, sizeof( String ), "You have requested a namechange from %s to %s for %s credits, please wait until a General Admin approves it.", playername, inputtext, number_format(ShopItems[40][sItemPrice]));
						SendClientMessageEx( playerid, COLOR_YELLOW, String );
						SendReportToQue(playerid, "Name Change Request (Credits)", 2, 4);
						return 1;
					}

					else
					{
						SendClientMessageEx(playerid, COLOR_GRAD2, "You don't have enough credits to purchase this item. Visit shop.ng-gaming.net to purchase credits.");
					}
					*/
					new namechangecost;
					switch(PlayerInfo[playerid][pLevel])
					{
						case 1: namechangecost = 10000;
						case 2: namechangecost = 15000;
						case 3: namechangecost = 20000;
						default: namechangecost = (PlayerInfo[playerid][pLevel]-3)*50000;
					}
					if(PlayerInfo[playerid][pCash] >= namechangecost)
					{
						if(GetPVarType(playerid, "HasReport")) return SendClientMessageEx(playerid, COLOR_GREY, "Chi duoc gui 1 bao cao cung luc. (/cancelreport)");
						SetPVarInt(playerid, "RequestingNameChange", 1);
						SetPVarString(playerid, "NewNameRequest", inputtext);
						SetPVarInt(playerid, "NameChangeCost", namechangecost);
						SendClientMessageEx(playerid, COLOR_YELLOW, "Da yeu cau doi ten tu %s thanh %s gia $%s, hay cho Admin duyet.", GetPlayerNameExt(playerid), inputtext, number_format(namechangecost));
						SendReportToQue(playerid, "Yeu cau doi ten (Tien mat)", 2, 4);
						return 1;
					}

					else
					{
						SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong du tien doi ten.");
					}
				}
			}
			else
			{
				SendClientMessageEx( playerid, COLOR_WHITE, "Ten phai dai hon 1 ky tu." );
			}
		}
	}
	else if( dialogid == DIALOG_NAMECHANGE2 )
	{
		if(!response || strlen(inputtext) == 0) return Kick(playerid);
		if(strlen(inputtext) >= 20)
		{
			SendClientMessageEx( playerid, COLOR_WHITE, "Ten khong duoc dai qua 20 ky tu." );
			ShowPlayerDialogEx( playerid, DIALOG_NAMECHANGE2, DIALOG_STYLE_INPUT, "Doi ten mien phi","May chu roleplay yeu cau ten theo dang: Firstname_Lastname.\nVi du: John_Smith hoac Jimmy_Johnson\n\nAdmin cho phep ban doi ten dung dinh dang mien phi. Nhap ten mong muon ben duoi.\n\nLuu y: Nhan huy se bi ngat ket noi khoi may chu.", "Doi", "Huy" );
		}
		else
		{
			if( strlen(inputtext) >= 1 )
			{
				if(!response)
				{
					ShowPlayerDialogEx( playerid, DIALOG_NAMECHANGE2, DIALOG_STYLE_INPUT, "Doi ten mien phi","May chu roleplay yeu cau ten theo dang: Firstname_Lastname.\nVi du: John_Smith hoac Jimmy_Johnson\n\nAdmin cho phep ban doi ten dung dinh dang mien phi. Nhap ten mong muon ben duoi.\n\nLuu y: Nhan huy se bi ngat ket noi khoi may chu.", "Doi", "Huy" );
				}
				else
				{
					for(new i = 0; i < strlen( inputtext ); i++)
					{
						if (inputtext[i] == ' ')
						{
							SendClientMessageEx(playerid, COLOR_WHITE, "Hay dung '_' (gach duoi) thay cho ' ' (dau cach)");
							ShowPlayerDialogEx( playerid, DIALOG_NAMECHANGE2, DIALOG_STYLE_INPUT, "Doi ten mien phi","May chu roleplay yeu cau ten theo dang: Firstname_Lastname.\nVi du: John_Smith hoac Jimmy_Johnson\n\nAdmin cho phep ban doi ten dung dinh dang mien phi. Nhap ten mong muon ben duoi.\n\nLuu y: Nhan huy se bi ngat ket noi khoi may chu.", "Doi", "Huy" );
							return 1;
						}
					}
					if( strfind( inputtext, "_", true) == -1 )
					{
						SendClientMessageEx( playerid, COLOR_WHITE, "Doi ten bi tu choi. Hay chon ten dung dinh dang: Firstname_Lastname." );
						ShowPlayerDialogEx( playerid, DIALOG_NAMECHANGE2, DIALOG_STYLE_INPUT, "Doi ten mien phi","May chu roleplay yeu cau ten theo dang: Firstname_Lastname.\nVi du: John_Smith hoac Jimmy_Johnson\n\nAdmin cho phep ban doi ten dung dinh dang mien phi. Nhap ten mong muon ben duoi.\n\nLuu y: Nhan huy se bi ngat ket noi khoi may chu.", "Doi", "Huy" );
						return 1;
					}
					else
					{
						if(GetPVarType(playerid, "HasReport")) {
							SendClientMessageEx(playerid, COLOR_GREY, "Chi duoc gui 1 bao cao cung luc. (/cancelreport)");
							return 1;
						}
						DeletePVar(playerid, "marriagelastname");
						SetPVarInt(playerid, "RequestingNameChange", 1);
						SetPVarString(playerid, "NewNameRequest", inputtext);
						SetPVarInt(playerid, "NameChangeCost", 0);
						new playername[MAX_PLAYER_NAME];
						GetPlayerName(playerid, playername, sizeof(playername));
						SendClientMessageEx( playerid, COLOR_YELLOW, "Ban yeu cau doi ten tu %s thanh %s, hay cho Admin phe duyet.", playername, inputtext );
						// format( String, sizeof( String ), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) requested a name change to %s for free (non-RP name) - /approvename %d (accept), or /denyname %d (deny).", playername, playerid, inputtext, playerid, playerid);
						// ABroadCast( COLOR_YELLOW, String, 3 );
						SendReportToQue(playerid, "Yeu cau doi ten", 2, 4);
						return 1;
					}
				}
			}
			else
			{
				SendClientMessageEx( playerid, COLOR_WHITE, "Ten phai dai hon 1 ky tu." );
				ShowPlayerDialogEx( playerid, DIALOG_NAMECHANGE2, DIALOG_STYLE_INPUT, "Doi ten mien phi","May chu roleplay yeu cau ten theo dang: Firstname_Lastname.\nVi du: John_Smith hoac Jimmy_Johnson\n\nAdmin cho phep ban doi ten dung dinh dang mien phi. Nhap ten mong muon ben duoi.\n\nLuu y: Nhan huy se bi ngat ket noi khoi may chu.", "Doi", "Huy" );
			}
		}
	}
	if(dialogid == DIALOG_CDLOCKMENU)
	{
		if(response)
		{
			if(GetPVarInt(playerid, "lockmenu") == 1)
			{
				new pvid;
				if (IsNumericString(inputtext))
				{
					pvid = strval(inputtext)-1;
					if(PlayerVehicleInfo[playerid][pvid][pvId] == INVALID_PLAYER_VEHICLE_ID)
					{
						SendClientMessageEx(playerid, COLOR_GRAD4, "LOI: Ban khong co xe trong o nay.");
						DeletePVar(playerid, "lockmenu");
						return 1;
					}
					if(PlayerVehicleInfo[playerid][pvid][pvAlarm] == 1)
					{
						SendClientMessageEx(playerid, COLOR_GRAD4, "LOI: Vat pham nay da duoc lap tren xe.");
						DeletePVar(playerid, "lockmenu");
						return 1;
					}
					SendClientMessageEx(playerid, COLOR_GRAD4, "	Da mua Standard Car Alarm!");
					SendClientMessageEx(playerid, COLOR_YELLOW, "GOI Y: Bao dong se bat va bao cho ban khi co nguoi tim cach trom xe.");
					PlayerVehicleInfo[playerid][pvid][pvAlarm] = 1;
					g_mysql_SaveVehicle(playerid, pvid);
					DeletePVar(playerid, "lockmenu");
					new iBusiness = GetPVarInt(playerid, "businessid");
					new cost = GetPVarInt(playerid, "lockcost");
					new iItem = GetPVarInt(playerid, "item")-1;
					Businesses[iBusiness][bInventory]-= StoreItemCost[iItem][ItemValue];
					Businesses[iBusiness][bTotalSales]++;
					Businesses[iBusiness][bSafeBalance] += TaxSale(cost);
					//if(penalty) Businesses[iBusiness][bSafeBalance] -= floatround(cost * BIZ_PENALTY);
					GivePlayerCash(playerid, -cost);
					if (PlayerInfo[playerid][pBusiness] != InBusiness(playerid)) Businesses[iBusiness][bLevelProgress]++;
					SaveBusiness(iBusiness);
					PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
					/*if (PlayerInfo[playerid][pDonateRank] >= 1)
					{
						format(string,sizeof(string),"VIP: You have received 20 percent off this product. Instead of paying $%s, you paid $%s.", number_format(Businesses[iBusiness][bItemPrices][iItem]), number_format(cost));
						SendClientMessageEx(playerid, COLOR_YELLOW, string);
					}*/
					format(string,sizeof(string),"%s(%d) (IP: %s) has bought a Standard Car Alarm in %s (%d) for $%s.",GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), Businesses[iBusiness][bName], iBusiness, number_format(cost));
					Log("logs/business.log", string);
					format(string,sizeof(string),"* Da mua Standard Car Alarm tai %s voi gia $%s.", Businesses[iBusiness][bName], number_format(cost));
					SendClientMessage(playerid, COLOR_GRAD2, string);
					new playersold = GetPVarInt(playerid, "playersold");
					if(playersold)
					{
						DeletePVar(playerid, "Business_ItemType");
						DeletePVar(playerid, "Business_ItemPrice");
						DeletePVar(playerid, "Business_ItemOfferer");
						DeletePVar(playerid, "Business_ItemOffererSQLId");
					}
				}
			}
			else if(GetPVarInt(playerid, "lockmenu") == 4)
			{
				new pvid;
				if (IsNumericString(inputtext))
				{
					pvid = strval(inputtext)-1;
					if(PlayerVehicleInfo[playerid][pvid][pvId] == INVALID_PLAYER_VEHICLE_ID)
					{
						SendClientMessageEx(playerid, COLOR_GRAD4, "LOI: Ban khong co xe trong o nay.");
						DeletePVar(playerid, "lockmenu");
						return 1;
					}
					if(PlayerVehicleInfo[playerid][pvid][pvAlarm] == 2)
					{
						SendClientMessageEx(playerid, COLOR_GRAD4, "LOI: Vat pham nay da duoc lap va hoat dong tren xe.");
						DeletePVar(playerid, "lockmenu");
						return 1;
					}
					PlayerVehicleInfo[playerid][pvid][pvAlarm] = 2;
					g_mysql_SaveVehicle(playerid, pvid);
					DeletePVar(playerid, "lockmenu");
					GivePlayerCredits(playerid, -ShopItems[39][sItemPrice], 1);
					printf("Price39: %d", ShopItems[39][sItemPrice]);

					AmountSold[39]++;
					AmountMade[39] += ShopItems[39][sItemPrice];

					new szQuery[128];
					mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold39` = '%d', `AmountMade39` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[39], AmountMade[39]);
					mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

					SendClientMessageEx(playerid, COLOR_CYAN, "Da mua Deluxe Car Alarm voi gia %s credits.", number_format(ShopItems[39][sItemPrice]));
					SendClientMessageEx(playerid, COLOR_YELLOW, "GOI Y: Bao dong se bat va bao cho ban khi co nguoi tim cach trom xe.");

					format(string, sizeof(string), "[Deluxe Car Alarm] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[39][sItemPrice]));
					Log("logs/credits.log", string), print(string);
				}
			}
			else if(GetPVarInt(playerid, "lockmenu") == 2)
			{
				new pvid;
				if (IsNumericString(inputtext))
				{
					pvid = strval(inputtext)-1;
					if(PlayerVehicleInfo[playerid][pvid][pvId] == INVALID_PLAYER_VEHICLE_ID)
					{
						SendClientMessageEx(playerid, COLOR_GRAD4, "LOI: Ban khong co xe trong o nay.");
						SetPVarInt(playerid, "lockmenu", 0);
						return 1;
					}
					if(PlayerVehicleInfo[playerid][pvid][pvLocksLeft] > 0 && PlayerVehicleInfo[playerid][pvid][pvLock] == 2)
					{
						SendClientMessageEx(playerid, COLOR_GRAD4, "LOI: Vat pham nay da duoc lap va hoat dong tren xe.");
						DeletePVar(playerid, "lockmenu");
						return 1;
					}
					SendClientMessageEx(playerid, COLOR_GRAD4, "Da mua khoa dien tu!");
					SendClientMessageEx(playerid, COLOR_YELLOW, "GOI Y: Dung /pvlock de khoa xe.");
					UnLockPlayerVehicle(playerid, PlayerVehicleInfo[playerid][pvid][pvId], PlayerVehicleInfo[playerid][pvid][pvLock]);
					PlayerVehicleInfo[playerid][pvid][pvLock] = 2;
					PlayerVehicleInfo[playerid][pvid][pvLocksLeft] = 5;
					g_mysql_SaveVehicle(playerid, pvid);
					DeletePVar(playerid, "lockmenu");
					new iBusiness = GetPVarInt(playerid, "businessid");
					new cost = GetPVarInt(playerid, "lockcost");
					new iItem = GetPVarInt(playerid, "item")-1;
					Businesses[iBusiness][bInventory]-= StoreItemCost[iItem][ItemValue];
					Businesses[iBusiness][bTotalSales]++;
					Businesses[iBusiness][bSafeBalance] += TaxSale(cost);
					//if(penalty) Businesses[iBusiness][bSafeBalance] -= floatround(cost * BIZ_PENALTY);
					GivePlayerCash(playerid, -cost);
					if (PlayerInfo[playerid][pBusiness] != InBusiness(playerid)) Businesses[iBusiness][bLevelProgress]++;
					SaveBusiness(iBusiness);
					PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
					/*if (PlayerInfo[playerid][pDonateRank] >= 1)
					{
						format(string,sizeof(string),"VIP: You have received 20 percent off this product. Instead of paying $%s, you paid $%s.", number_format(Businesses[iBusiness][bItemPrices][iItem]), number_format(cost));
						SendClientMessageEx(playerid, COLOR_YELLOW, string);
					}*/
					format(string,sizeof(string),"%s(%d) (IP: %s) has bought a Electronic Lock in %s (%d) for $%s.",GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), Businesses[iBusiness][bName], iBusiness, number_format(cost));
					Log("logs/business.log", string);
					format(string,sizeof(string),"* Da mua Electronic Lock tai %s voi gia $%s.", Businesses[iBusiness][bName], number_format(cost));
					SendClientMessage(playerid, COLOR_GRAD2, string);
					new playersold = GetPVarInt(playerid, "playersold");
					if(playersold)
					{
						DeletePVar(playerid, "Business_ItemType");
						DeletePVar(playerid, "Business_ItemPrice");
						DeletePVar(playerid, "Business_ItemOfferer");
						DeletePVar(playerid, "Business_ItemOffererSQLId");
					}
				}
			}
			else if(GetPVarInt(playerid, "lockmenu") == 3)
			{
				new pvid;
				if (IsNumericString(inputtext))
				{
					pvid = strval(inputtext)-1;
					if(PlayerVehicleInfo[playerid][pvid][pvId] == INVALID_PLAYER_VEHICLE_ID)
					{
						SendClientMessageEx(playerid, COLOR_GRAD4, "LOI: Ban khong co xe trong o nay.");
						SetPVarInt(playerid, "lockmenu", 0);
						return 1;
					}
					if(PlayerVehicleInfo[playerid][pvid][pvLocksLeft] > 0 && PlayerVehicleInfo[playerid][pvid][pvLock] == 3)
					{
						SendClientMessageEx(playerid, COLOR_GRAD4, "LOI: Vat pham nay da duoc lap va hoat dong tren xe.");
						DeletePVar(playerid, "lockmenu");
						return 1;
					}
					SendClientMessageEx(playerid, COLOR_GRAD4, "Da mua khoa cong nghiep!");
					SendClientMessageEx(playerid, COLOR_YELLOW, "GOI Y: Dung /pvlock de khoa xe.");
					PlayerVehicleInfo[playerid][pvid][pvLock] = 3;
					PlayerVehicleInfo[playerid][pvid][pvLocksLeft] = 5;
					g_mysql_SaveVehicle(playerid, pvid);
					DeletePVar(playerid, "lockmenu");
					new iBusiness = GetPVarInt(playerid, "businessid");
					new cost = GetPVarInt(playerid, "lockcost");
					new iItem = GetPVarInt(playerid, "item")-1;
					Businesses[iBusiness][bInventory]-= StoreItemCost[iItem][ItemValue];
					Businesses[iBusiness][bTotalSales]++;
					Businesses[iBusiness][bSafeBalance] += TaxSale(cost);
					//if(penalty) Businesses[iBusiness][bSafeBalance] -= floatround(cost * BIZ_PENALTY);
					GivePlayerCash(playerid, -cost);
					if (PlayerInfo[playerid][pBusiness] != InBusiness(playerid)) Businesses[iBusiness][bLevelProgress]++;
					SaveBusiness(iBusiness);
					PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
					/*if (PlayerInfo[playerid][pDonateRank] >= 1)
					{
						format(string,sizeof(string),"VIP: You have received 20 percent off this product. Instead of paying $%s, you paid $%s.", number_format(Businesses[iBusiness][bItemPrices][iItem]), number_format(cost));
						SendClientMessageEx(playerid, COLOR_YELLOW, string);
					}*/
					format(string,sizeof(string),"%s(%d) (IP: %s) has bought a Industrial Lock in %s (%d) for $%s.",GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), Businesses[iBusiness][bName], iBusiness, number_format(cost));
					Log("logs/business.log", string);
					format(string,sizeof(string),"* Da mua Industrial Lock tai %s voi gia $%s.",Businesses[iBusiness][bName], number_format(cost));
					SendClientMessage(playerid, COLOR_GRAD2, string);
					new playersold = GetPVarInt(playerid, "playersold");
					if(playersold)
					{
						DeletePVar(playerid, "Business_ItemType");
						DeletePVar(playerid, "Business_ItemPrice");
						DeletePVar(playerid, "Business_ItemOfferer");
						DeletePVar(playerid, "Business_ItemOffererSQLId");
					}
				}
			}
		}
	}
	if(dialogid == DIALOG_LOCKER_OS)
	{
		if(!response) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da roi tu do.");

		if(listitem == 0)
		{
			new Float:health;
			GetHealth(playerid, health);
			new hpint = floatround( health, floatround_round );
			if( hpint >= 100 )
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Ban da day mau.");
				return 1;
			}
			else {
				SetHealth(playerid, 100);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Famed Locker] Ban da dung bo so cuu, hien co 100.0 HP.");
			}
		}
		if(listitem == 1)
		{
			new Float:armour;
			GetArmour(playerid, armour);
			if(armour >= 100)
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Ban da day giap.");
				return 1;
			}
			else if(GetPlayerCash(playerid) < 10000)
			{
				SendClientMessageEx(playerid, COLOR_GREY,"Ban khong co $10000");
				return 1;
			}
			else {
				GivePlayerCash(playerid, -10000);
				SetArmour(playerid, 100);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Famed Locker] Ban tra $10000 cho kevlar vest.");
			}
		}
		if(listitem == 2)
		{
			ShowPlayerDialogEx(playerid, 3497, DIALOG_STYLE_INPUT, "Chon skin Famed","Nhap Skin ID!\n\nChu y: Thanh vien Famed duoc doi skin mien phi.", "Doi", "Huy" );
		}
		if(listitem == 3)
		{
			Job_ShowMenu(playerid);
		}
	}
	if(dialogid == DIALOG_LOCKER_COS)
	{
		if(!response) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da roi tu do.");

		if(listitem == 0)
		{
			new Float:health;
			GetHealth(playerid, health);
			new hpint = floatround( health, floatround_round );
			if( hpint >= 100 )
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Ban da day mau.");
				return 1;
			}
			else {
				SetHealth(playerid, 100);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Famed Locker] Ban da dung bo so cuu, hien co 100.0 HP.");
			}
		}
		if(listitem == 1)
		{
			new Float:armour;
			GetArmour(playerid, armour);
			if(armour >= 100)
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Ban da day giap.");
				return 1;
			}
			else if(GetPlayerCash(playerid) < 5000)
			{
				SendClientMessageEx(playerid, COLOR_GREY,"Ban khong co $5000");
				return 1;
			}
			else {
				GivePlayerCash(playerid, -5000);
				SetArmour(playerid, 100);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Famed Locker] Ban tra $5000 cho kevlar vest.");
			}
		}
		if(listitem == 2)
		{
			ShowPlayerDialogEx(playerid, 3497, DIALOG_STYLE_INPUT, "Chon skin Famed","Nhap Skin ID!\n\nChu y: Thanh vien Famed duoc doi skin mien phi.", "Doi", "Huy" );
		}
		if(listitem == 3)
		{
			Job_ShowMenu(playerid);
		}
	}
	if(dialogid == DIALOG_LOCKER_FAMED)
	{
		if(!response) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da roi tu do.");

		if(listitem == 0)
		{
			new Float:health;
			GetHealth(playerid, health);
			new hpint = floatround(health, floatround_round);
			if(hpint >= 100)
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Ban da day mau.");
				return 1;
			}
			else {
				SetHealth(playerid, 100);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Famed Locker] Ban da dung bo so cuu, hien co 100.0 HP.");
			}
		}
		if(listitem == 1)
		{
			new Float:armour;
			GetArmour(playerid, armour);
			if(armour >= 100)
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Ban da day giap.");
				return 1;
			}
			else {
				SetArmour(playerid, 100);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Famed Locker] Ban nhan Kevlar Vest mien phi.");
			}
		}
		if(listitem == 2)
		{
			if(PlayerInfo[playerid][pAccountRestricted] != 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Tai khoan cua ban bi han che!");
			ShowPlayerDialogEx(playerid, 3498, DIALOG_STYLE_LIST, "Kho vu khi Famed", "Desert Eagle (Mien phi)\nSemi-Automatic MP5 (Mien phi)\nPump Shotgun (Mien phi)\nCounty Rifle (Mien phi)\nSilenced Pistol (Mien phi)\nJapanese Katana (Mien phi)\nPurple Dildo (Mien phi)\nWhite Dildo (Mien phi)\nBig Vibrator (Mien phi)\nSilver Vibrator (Mien phi)\n", "Lay", "Huy");
		}
		if(listitem == 3)
		{
			ShowPlayerDialogEx(playerid, 3497, DIALOG_STYLE_INPUT, "Chon skin Famed", "Nhap Skin ID!\n\nChu y: Thanh vien Famed duoc doi skin mien phi.", "Doi", "Huy" );
		}
		if(listitem == 4)
		{
			Job_ShowMenu(playerid);
		}
		if(listitem == 5)
		{
			if(!response) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da roi Famed Locker.");

			if(PlayerInfo[playerid][pWantedLevel] >= 6)
				return SendClientMessageEx(playerid, COLOR_YELLOW, "Khong the dung khi la Most Wanted!");

			if(PlayerInfo[playerid][pJailTime] > 0)
			{
				SendClientMessageEx(playerid, COLOR_YELLOW, "Ban chua the lam viec nay.");
				format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s thu doi mau ten sang famed khi o jail/prison.", GetPlayerNameEx(playerid));
				ABroadCast(COLOR_YELLOW, string, 2);
				return 1;
			}

			if(GetPVarInt(playerid, "famedTag") == 0)
			{
				SetPlayerColor(playerid, COLOR_FAMED);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Famed Locker] Mau ten cua ban se hien theo famed.");
				SetPVarInt(playerid, "famedTag", 1);
				return 1;
			}
			else {
				SetPlayerToTeamColor(playerid);
				SendClientMessageEx(playerid, COLOR_YELLOW, "[Famed Locker] Mau ten cua ban se hien binh thuong.");
				SetPVarInt(playerid, "famedTag", 0);
			}
		}
	}
	if(dialogid == 7483) // VIP Locker /viplocker
	{
		if(response)
		{
			if(!IsPlayerInRangeOfPoint(playerid, 7.0, 2555.747314, 1404.106079, 7699.584472) && !IsPlayerInRangeOfPoint(playerid, 7.0, 1832.0533, 1380.7281, 1464.3822) && !IsPlayerInRangeOfPoint(playerid, 7.0, 772.4844, 1715.7213, 1938.0391) && !IsPlayerInRangeOfPoint(playerid, 7.0, 1378.0017, 1747.4668, 927.3564)) SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong o tai VIP Locker.");
			if(listitem == 0)
			{
				new Float:health;
				GetHealth(playerid, health);
				new hpint = floatround( health, floatround_round );
				if( hpint >= 100 )
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Ban da day mau.");
					return 1;
				}

				SetHealth(playerid, 100);
				SendClientMessageEx(playerid, COLOR_YELLOW, "VIP: Ban da dung bo so cuu, hien co 100.0 HP.");
			}
			if(listitem == 1)
			{
				new Float:armour;
				GetArmour(playerid, armour);
				if(armour >= 100)
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Ban da day giap.");
					return 1;
				}
				if(PlayerInfo[playerid][pDonateRank] == 1)
				{
					if(GetPlayerCash(playerid) < 15000)
					{
						SendClientMessageEx(playerid, COLOR_GREY,"Ban khong du $15000!");
						return 1;
					}
					GivePlayerCash(playerid, -15000);
					SetArmour(playerid, 100);
					SendClientMessageEx(playerid, COLOR_YELLOW, "VIP: Ban tra $15000 cho kevlar vest.");
				}
				else if(PlayerInfo[playerid][pDonateRank] == 2)
				{
					if(GetPlayerCash(playerid) < 10000)
					{
						SendClientMessageEx(playerid, COLOR_GREY,"Ban khong du $10000!");
						return 1;
					}
					GivePlayerCash(playerid, -10000);
					SetArmour(playerid, 100);
					SendClientMessageEx(playerid, COLOR_YELLOW, "VIP: Ban tra $10000 cho kevlar vest.");
				}
				if(PlayerInfo[playerid][pDonateRank] >= 3)
				{
					SetArmour(playerid, 100);
					SetPVarInt(playerid, "Armor", 1);
				}
			}
			if(listitem == 2)
			{
				if(PlayerInfo[playerid][pAccountRestricted] != 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Tai khoan cua ban bi han che!");
				if(PlayerInfo[playerid][pDonateRank] >= 1)
				{
					switch(PlayerInfo[playerid][pDonateRank])
					{
						case 1, 2: ShowPlayerDialogEx(playerid, VIPWEPSMENU, DIALOG_STYLE_LIST, "VIP Weapons", "Desert Eagle (3)\nShotgun (2)\nMP5 (3)\nSilenced Pistol (2)\nGolf Club (1)\nBat (1)\nDildo (1)\nSword (1)\n9mm (2)", "Chon", "Huy");
						default: ShowPlayerDialogEx(playerid, VIPWEPSMENU, DIALOG_STYLE_LIST, "VIP Weapons", "Desert Eagle\nShotgun\nMP5\nSilenced Pistol\nGolf Club\nBat\nDildo\nSword\n9mm", "Chon", "Huy");
					}
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_YELLOW, "VIP: Phai la thanh vien VIP de dung tu sung.");
				}
			}
			if(listitem == 3)
			{
				if(PlayerInfo[playerid][pDonateRank] >= 2)
				{
					ShowModelSelectionMenu(playerid, SkinList, "Doi quan ao.");
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_YELLOW, "VIP: Can it nhat Silver VIP de dung goc quan ao va chon BAT KY skin nao.");
				}
			}
			if(listitem == 4)
			{
				if(PlayerInfo[playerid][pDonateRank] >= 2)
				{
					Job_ShowMenu(playerid);
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_YELLOW, "VIP: Can it nhat Silver VIP de dung trung tam viec lam.");
				}
			}
			if(listitem == 5)
			{
				ShowPlayerDialogEx(playerid, 7486, DIALOG_STYLE_LIST, "VIP: Mau VIP", "Bat\nTat", "Tiep tuc", "Huy");
			}
		}
	}
	if(dialogid == 7484)
	{
		if(!response) return DeletePVar(playerid, "m_Item");
		new bool:boost = GetPVarType(playerid, "m_Item") != 0 && GetPVarInt(playerid, "m_Item") == 1;
		new job = Job_GetMenuType(listitem, boost);
		if(job == JOB_NONE || !gPlayerLogged{playerid}) return 1;
		SetPVarInt(playerid, "jobSelection", job);
		if(boost)
		{
			if(GetJobLevel(playerid, job) == 5) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ky nang cong viec nay da dat cap cao nhat.");
			strunpack(microItemName, mItemName[1], sizeof(microItemName));
			format(string, sizeof(string), "Vat pham: %s - %s\nCredits cua ban: %s\nGia: {FFD700}%s{A9C4E4}\nCredits con: %s", microItemName, GetJobName(job), number_format(PlayerInfo[playerid][pCredits]), number_format(MicroItems[1]), number_format(PlayerInfo[playerid][pCredits]-MicroItems[1]));
			return ShowPlayerDialogEx(playerid, DIALOG_MICROSHOP3, DIALOG_STYLE_MSGBOX, "Micro Shop", string, "Mua", "Huy");
		}
		string[0] = EOS;
		for(new slot = 1; slot <= 3; ++slot)
		{
			if(!Job_CanUseSlot(playerid, slot)) continue;
			new line[20];
			format(line, sizeof(line), "%sO cong viec %d", slot > 1 ? "\n" : "", slot);
			strcat(string, line, sizeof(string));
		}
		return ShowPlayerDialogEx(playerid, 7485, DIALOG_STYLE_LIST, "Chon o cong viec", string, "Tiep tuc", "Huy");
	}
	if(dialogid == 7485)
	{
		if(!response) return DeletePVar(playerid, "m_Item");
		if(!gPlayerLogged{playerid} || !GetPVarType(playerid, "jobSelection") || !(0 <= listitem < 3)) return 1;
		new job = GetPVarInt(playerid, "jobSelection"), slot = listitem + 1;
		if(!Job_CanSetSlot(playerid, slot, job) || Job_GetSlot(playerid, slot) == job)
			return SendClientMessageEx(playerid, COLOR_GREY, "Cong viec hoac o khong kha dung. Kiem tra cong viec hien tai va dieu kien cua o.");
		if(GetPVarType(playerid, "m_Item") && GetPVarInt(playerid, "m_Item") == 0)
		{
			SetPVarInt(playerid, "m_Response", listitem);
			strunpack(microItemName, mItemName[0], sizeof(microItemName));
			format(string, sizeof(string), "Vat pham: %s - %s\nCredits cua ban: %s\nGia: {FFD700}%s{A9C4E4}\nCredits con: %s", microItemName, GetJobName(job), number_format(PlayerInfo[playerid][pCredits]), number_format(MicroItems[0]), number_format(PlayerInfo[playerid][pCredits]-MicroItems[0]));
			return ShowPlayerDialogEx(playerid, DIALOG_MICROSHOP3, DIALOG_STYLE_MSGBOX, "Micro Shop", string, "Mua", "Huy");
		}
		if(PlayerInfo[playerid][pDonateRank] < 2 && PlayerInfo[playerid][pFamed] <= 0)
			return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong con quyen dung trung tam viec lam.");
		if(Job_SetPlayerSlot(playerid, slot, job)) SendClientMessageEx(playerid, COLOR_YELLOW, "Cong viec trong o %d da doi thanh %s.", slot, GetJobName(job));
		DeletePVar(playerid, "jobSelection");
		return 1;
	}
	if(dialogid == 7486)
	{
		if(!response) return 1;

		if(PlayerInfo[playerid][pWantedLevel] >= 6)
		{
			SendClientMessageEx(playerid, COLOR_YELLOW, "Khong the dung khi la Most Wanted!");
			return 1;
		}
		if(PlayerInfo[playerid][pJailTime] > 0)
		{
			SendClientMessageEx(playerid, COLOR_YELLOW, "Ban chua the lam viec nay.");
			format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s thu doi sang mau VIP khi o tu.", GetPlayerNameEx(playerid));
			ABroadCast(COLOR_YELLOW, string, 2);
			return 1;
		}
		switch(listitem)
		{
			case 0:
			{
				SetPlayerColor(playerid, COLOR_VIP);
				SendClientMessageEx(playerid, COLOR_YELLOW, "Ban da bat VIP Name Color!");
			}
			case 1:
			{
				SetPlayerToTeamColor(playerid);
				SendClientMessageEx(playerid, COLOR_YELLOW, "Ban da tat VIP Name Color!");
			}
		}
	}
	if(dialogid == RESTAURANTMENU)
	{
		new pvar[25];
		if (response)
		{
			new iBusiness = InBusiness(playerid);

			format(pvar, sizeof(pvar), "Business_MenuItemPrice%d", listitem);
			new iPrice = GetPVarInt(playerid, pvar);
			format(pvar, sizeof(pvar), "Business_MenuItem%d", listitem);
			new iItem = GetPVarInt(playerid, pvar);
			new cost = (PlayerInfo[playerid][pDonateRank] >= 1) ? (floatround(iPrice * 0.8)) : (iPrice);

			if (!iPrice) {
				SendClientMessageEx(playerid, COLOR_GRAD4, "Vat pham khong con duoc ban.");
			}
			else if (Businesses[iBusiness][bInventory] < 1) {
				SendClientMessageEx(playerid, COLOR_GRAD2, "Cua hang da het vat pham!");
			}
			else if (iPrice != Businesses[iBusiness][bItemPrices][iItem]) {
				SendClientMessageEx(playerid, COLOR_GRAD4, "Khong the mua vi gia vat pham da doi.");
			}
			else if (GetPlayerCash(playerid) < cost) {
				SendClientMessageEx(playerid, COLOR_GRAD4, "Ban khong du tien mua vat pham nay!");
			}
			else {
				format(pvar, sizeof(pvar), "Business_MenuItem%d", listitem);
				Businesses[iBusiness][bInventory]--;
				Businesses[iBusiness][bTotalSales]++;
				Businesses[iBusiness][bSafeBalance] += TaxSale(cost);
				//Businesses[iBusiness][bSafeBalance] -= floatround(cost * BIZ_PENALTY);
				GivePlayerCash(playerid, -cost);
				if (PlayerInfo[playerid][pBusiness] != InBusiness(playerid)) Businesses[iBusiness][bLevelProgress]++;
				SaveBusiness(iBusiness);
				PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
				if (PlayerInfo[playerid][pDonateRank] >= 1)
				{
					SendClientMessageEx(playerid, COLOR_YELLOW, "VIP: Ban duoc giam 20 phan tram. Thay vi $%s, ban chi tra $%s.", number_format(Businesses[iBusiness][bItemPrices][listitem]), number_format(cost));
				}
				strunpack(restaurantItemName, RestaurantItems[iItem], sizeof(restaurantItemName));
				format(string,sizeof(string),"%s(%d) (IP: %s) has bought a %s in %s (%d) for $%d.",GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid),restaurantItemName, Businesses[iBusiness][bName], iBusiness, cost);
				Log("logs/business.log", string);
				format(string,sizeof(string),"* Ban da mua %s tai %s voi gia $%d.",restaurantItemName,Businesses[iBusiness][bName], cost);
				SendClientMessage(playerid, COLOR_GRAD2, string);

				printf("%s\n%i", restaurantItemName, iItem);
				if (strcmp("Starter Meal", restaurantItemName) == 0) // starter
				{
					if (PlayerInfo[playerid][pFitness] >= 3)
						PlayerInfo[playerid][pFitness] -= 3;
					else
						PlayerInfo[playerid][pFitness] = 0;
				}
				strunpack(restaurantItemName, RestaurantItems[iItem], sizeof(restaurantItemName));
				if (strcmp("Full Meal", restaurantItemName) == 0) // full meal
				{
					switch(PlayerInfo[playerid][pBackpack]) {
						case 1: if(PlayerInfo[playerid][pBItems][0] < 1 && PlayerInfo[playerid][pBEquipped]) {
							ShowPlayerDialogEx(playerid, DIALOG_BMEALSTORE, DIALOG_STYLE_MSGBOX, "An hoac cat", "Ban co the cat Full Meal vao ba lo hoac an ngay", "Cat", "An");
							return 1;
						}
						case 2: if(PlayerInfo[playerid][pBItems][0] < 4 && PlayerInfo[playerid][pBEquipped]) {
							ShowPlayerDialogEx(playerid, DIALOG_BMEALSTORE, DIALOG_STYLE_MSGBOX, "An hoac cat", "Ban co the cat Full Meal vao ba lo hoac an ngay", "Cat", "An");
							return 1;
						}
						case 3: if(PlayerInfo[playerid][pBItems][0] < 5 && PlayerInfo[playerid][pBEquipped]) {
							ShowPlayerDialogEx(playerid, DIALOG_BMEALSTORE, DIALOG_STYLE_MSGBOX, "An hoac cat", "Ban co the cat Full Meal vao ba lo hoac an ngay", "Cat", "An");
							return 1;
						}
					}
				}

				SetHealth(playerid, 100.0);
			}
		}
		for (new i; i <= 13; i++)
		{
			format(pvar,sizeof(pvar),"Business_MenuItem%d", i);
			DeletePVar(playerid, pvar);
			format(pvar,sizeof(pvar),"Business_MenuItemPrice%d", i);
			DeletePVar(playerid, pvar);
		}
	}
	if (dialogid == RESTAURANTMENU2)
	{
		if (response)
		{
			new business = InBusiness(playerid);
			if (GetPlayerCash(playerid) < Businesses[business][bItemPrices][listitem])
			{
				return SendClientMessageEx(playerid, COLOR_GRAD4, "Ban khong du tien mua vat pham nay!");
			}
			GivePlayerCash(playerid, -Businesses[business][bItemPrices][listitem]);
			Businesses[business][bSafeBalance] += TaxSale(Businesses[business][bItemPrices][listitem]);
			Businesses[business][bTotalSales]++;
			Businesses[business][bTotalProfits] += Businesses[business][bItemPrices][listitem];

			strunpack(restaurantItemName, RestaurantItems[listitem], sizeof(restaurantItemName));
			SendClientMessageEx(playerid, COLOR_GRAD4, "Ban da mua '%s'.", restaurantItemName);
		}

		return 1;
	}
	if(dialogid == STOREMENU)
	{
		new pvar[25];
		if (response)
		{
			new iBusiness = InBusiness(playerid);

			format(pvar, sizeof(pvar), "Business_MenuItemPrice%d", listitem);
			new iPrice = GetPVarInt(playerid, pvar);
			format(pvar, sizeof(pvar), "Business_MenuItem%d", listitem);
			new iItem = GetPVarInt(playerid, pvar);
			new cost = (PlayerInfo[playerid][pDonateRank] >= 1) ? (floatround(iPrice * 0.8)) : (iPrice);

			if (!iPrice) {
				SendClientMessageEx(playerid, COLOR_GRAD4, "Vat pham khong con duoc ban.");
			}
			else if (Businesses[iBusiness][bInventory] < 1) {
				SendClientMessageEx(playerid, COLOR_GRAD2, "Cua hang da het vat pham!");
			}
			else if (iPrice != Businesses[iBusiness][bItemPrices][iItem-1]) {
				SendClientMessageEx(playerid, COLOR_GRAD4, "Khong the mua vi gia vat pham da doi.");
			}
			else if (GetPlayerCash(playerid) < cost) {
				SendClientMessageEx(playerid, COLOR_GRAD4, "Ban khong du tien mua vat pham nay!");
			}
			else {
				format(pvar, sizeof(pvar), "Business_MenuItem%d", listitem);
				if(iItem == ITEM_ILOCK || iItem == ITEM_SCALARM || iItem == ITEM_ELOCK)
				{
					if(Businesses[iBusiness][bInventory] >= StoreItemCost[iItem-1][ItemValue])
					{
						SetPVarInt(playerid, "lockcost", cost);
						SetPVarInt(playerid, "businessid", iBusiness);
						SetPVarInt(playerid, "item", iItem);
						SetPVarInt(playerid, "penalty", 1);
						GivePlayerStoreItem(playerid, 0, iBusiness, iItem, cost);
					}
					else return SendClientMessageEx(playerid, COLOR_GRAD2, "Cua hang khong du hang ton de ban vat pham nay!");
				}
				else
				{
					GivePlayerStoreItem(playerid, 0, iBusiness, iItem, cost);
				}
			}
		}
		for (new i; i < sizeof(StoreItems); i++)
		{
			format(pvar,sizeof(pvar),"Business_MenuItem%d", i);
			DeletePVar(playerid, pvar);
			format(pvar,sizeof(pvar),"Business_MenuItemPrice%d", i);
			DeletePVar(playerid, pvar);
		}
	}
	if(dialogid == SHOPMENU)
	{
		if(response)
		{
			new biz = InBusiness(playerid);
			if (GetPlayerCash(playerid) < Businesses[biz][bItemPrices][listitem])
			{
				return SendClientMessageEx(playerid, COLOR_GRAD4, "Ban khong du tien mua vat pham nay!");
			}
			Businesses[biz][bTotalSales]++;
			Businesses[biz][bSafeBalance] += TaxSale(Businesses[biz][bItemPrices][listitem]);
			GivePlayerCash(playerid, -Businesses[biz][bItemPrices][listitem]);

			switch (listitem)
			{
				case 0:
				{
					GivePlayerValidWeapon(playerid, WEAPON_DILDO);
					SendClientMessageEx(playerid, COLOR_GRAD4, "Da mua Purple Dildo, ban co the tu giai toa.");
				}
				case 1:
				{
					GivePlayerValidWeapon(playerid, WEAPON_VIBRATOR);
					SendClientMessageEx(playerid, COLOR_GRAD4, "Da mua Short Vibrator, ban co the tu giai toa.");
				}
				case 2:
				{
					GivePlayerValidWeapon(playerid, WEAPON_VIBRATOR2);
					SendClientMessageEx(playerid, COLOR_GRAD4, "Da mua Long Vibrator, ban co the tu giai toa.");
				}
				case 3:
				{
					GivePlayerValidWeapon(playerid, WEAPON_DILDO2);
					SendClientMessageEx(playerid, COLOR_GRAD4, "Da mua White Dildo, ban co the tu giai toa.");
				}
			}
		}
		return 1;
	}
	if(dialogid == GIVEKEYS)
	{
		if(response)
		{
			if(PlayerVehicleInfo[playerid][listitem][pvId] == INVALID_PLAYER_VEHICLE_ID) {
				SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the giao chia khoa xe khong ton tai, bi tam giu hoac da cat.");
				GiveKeysTo[playerid] = INVALID_PLAYER_ID;
				return 1;
			}
			if(PlayerVehicleInfo[playerid][listitem][pvAllowedPlayerId] != INVALID_PLAYER_ID)
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da giao chia khoa xe nay cho nguoi khac.");
				GiveKeysTo[playerid] = INVALID_PLAYER_ID;
				return 1;
			}
			if(PlayerInfo[GiveKeysTo[playerid]][pVehicleKeysFrom] != INVALID_PLAYER_ID)
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do da co chia khoa cua xe khac.");
				GiveKeysTo[playerid] = INVALID_PLAYER_ID;
				return 1;
			}
			PlayerVehicleInfo[playerid][listitem][pvAllowedPlayerId] = GiveKeysTo[playerid];
			PlayerInfo[GiveKeysTo[playerid]][pVehicleKeys] = listitem;
			PlayerInfo[GiveKeysTo[playerid]][pVehicleKeysFrom] = playerid;
			SendClientMessageEx(GiveKeysTo[playerid], COLOR_GRAD2, "%s da giao ban chia khoa xe %s cua ho.", GetPlayerNameEx(playerid), GetVehicleName(PlayerVehicleInfo[playerid][listitem][pvId]));
			format(string, sizeof(string), "Ban da giao cho %s chia khoa xe %s cua minh.", GetPlayerNameEx(GiveKeysTo[playerid]), GetVehicleName(PlayerVehicleInfo[playerid][listitem][pvId]));
			SendClientMessageEx(playerid, COLOR_GRAD2, string);
			GiveKeysTo[playerid] = INVALID_PLAYER_ID;
		}
	}
	if(dialogid == REMOVEKEYS)
	{
		if(response)
		{
			if(PlayerVehicleInfo[playerid][listitem][pvId] == INVALID_PLAYER_VEHICLE_ID) {
				SendClientMessageEx(playerid, COLOR_GRAD2, "Khong the thu hoi chia khoa xe khong ton tai, bi tam giu hoac da cat.");
				return 1;
			}
			if(PlayerVehicleInfo[playerid][listitem][pvAllowedPlayerId] != PlayerVehicleInfo[playerid][listitem][pvAllowedPlayerId])
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi nay khong co chia khoa xe nay.");
				return 1;
			}
			if(PlayerVehicleInfo[playerid][listitem][pvAllowedPlayerId] == INVALID_PLAYER_ID)
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "Ban chua giao chia khoa xe nay cho ai.");
				return 1;
			}
			if (ProxDetectorS(4.0, playerid, PlayerVehicleInfo[playerid][listitem][pvAllowedPlayerId])) {
				PlayerInfo[PlayerVehicleInfo[playerid][listitem][pvAllowedPlayerId]][pVehicleKeys] = INVALID_PLAYER_VEHICLE_ID;
				PlayerInfo[PlayerVehicleInfo[playerid][listitem][pvAllowedPlayerId]][pVehicleKeysFrom] = INVALID_PLAYER_ID;
				SendClientMessageEx(PlayerVehicleInfo[playerid][listitem][pvAllowedPlayerId], COLOR_GRAD2, "%s da thu hoi chia khoa xe %s cua ho.", GetPlayerNameEx(playerid), GetVehicleName(PlayerVehicleInfo[playerid][listitem][pvId]));
				format(string, sizeof(string), "Ban da lay lai chia khoa xe %s cua minh tu %s.", GetVehicleName(PlayerVehicleInfo[playerid][listitem][pvId]),GetPlayerNameEx(PlayerVehicleInfo[playerid][listitem][pvAllowedPlayerId]));
				SendClientMessageEx(playerid, COLOR_GRAD2, string);
				PlayerVehicleInfo[playerid][listitem][pvAllowedPlayerId] = INVALID_PLAYER_ID;
			}
			else
				return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong o du gan nguoi choi do.");
		}
	}
	if(dialogid == MPSPAYTICKETSCOP)
	{
		if(response)
		{
			new
				szMessage[128],
				iTargetID = GetPVarInt(playerid, "vRel");

			if(PlayerVehicleInfo[iTargetID][listitem][pvTicket]) {
				strunpack(vehicleName, VehicleName[PlayerVehicleInfo[iTargetID][listitem][pvModelId] - 400], sizeof(vehicleName));
				SendClientMessageEx(playerid, COLOR_GRAD2, "Da tra $%s phat cho xe cua %s: %s.", number_format(PlayerVehicleInfo[iTargetID][listitem][pvTicket]), GetPlayerNameEx(iTargetID), vehicleName);

				SendClientMessageEx(iTargetID, COLOR_LIGHTBLUE, "%s da tra het phat cho %s cua ban (%i).", GetPlayerNameEx(playerid), vehicleName, PlayerVehicleInfo[iTargetID][listitem][pvTicket]);
				PlayerVehicleInfo[iTargetID][listitem][pvTicket] = 0;
				g_mysql_SaveVehicle(iTargetID, listitem);
			}
			else if(PlayerVehicleInfo[iTargetID][listitem][pvImpounded])
			{
				strunpack(vehicleName, VehicleName[PlayerVehicleInfo[iTargetID][listitem][pvModelId] - 400], sizeof(vehicleName));
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da tra xe cua %s: %s.", GetPlayerNameEx(iTargetID), vehicleName);

				SendClientMessageEx(iTargetID, COLOR_LIGHTBLUE, "%s da lay %s cua ban khoi bai tam giu. (/vstorage de tao xe)", GetPlayerNameEx(playerid), vehicleName);

				format(szMessage, sizeof(szMessage), "HQ: %s da lay xe cua %s: %s khoi bai tam giu.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID), vehicleName);
				SendGroupMessage(GROUP_TYPE_LEA, RADIO, szMessage);
				SendGroupMessage(GROUP_TYPE_TOWING, RADIO, szMessage);

				new rand = random(sizeof(DMVRelease));
				PlayerVehicleInfo[iTargetID][listitem][pvImpounded] = 0;
				PlayerVehicleInfo[iTargetID][listitem][pvSpawned] = 0;
				PlayerVehicleInfo[iTargetID][listitem][pvPosX] = DMVRelease[rand][0];
				PlayerVehicleInfo[iTargetID][listitem][pvPosY] = DMVRelease[rand][1];
				PlayerVehicleInfo[iTargetID][listitem][pvPosZ] = DMVRelease[rand][2];
				PlayerVehicleInfo[iTargetID][listitem][pvPosAngle] = 180.000;
				PlayerVehicleInfo[iTargetID][listitem][pvTicket] = 0;
				g_mysql_SaveVehicle(iTargetID, listitem);
			}
			else SendClientMessageEx(playerid, COLOR_GRAD2, "Xe khong ton tai hoac khong can tra phi/phat de lay lai.");
		}
		return 1;
	}
	if(dialogid == MPSPAYTICKETS)
	{
		if(response)
		{
			new
				szMessage[128];

			if(PlayerInfo[playerid][pWantedLevel] != 0)
			{
				format(szMessage, sizeof(szMessage), "%s da thu tra phi/lay xe khi co %i lenh truy na.", GetPlayerNameEx(playerid), PlayerInfo[playerid][pWantedLevel]);
				SendGroupMessage(GROUP_TYPE_LEA, DEPTRADIO, szMessage);
				return SendClientMessageEx(playerid, COLOR_YELLOW, "Canh sat da duoc bao ban dang bi truy na va dang den.");
			}
			if(PlayerVehicleInfo[playerid][listitem][pvTicket] && PlayerVehicleInfo[playerid][listitem][pvImpounded] == 0) {
				if(GetPlayerCash(playerid) < PlayerVehicleInfo[playerid][listitem][pvTicket]) {
					return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong du tien mat de tra phat.");
				}
				GivePlayerCash(playerid, -PlayerVehicleInfo[playerid][listitem][pvTicket]);
				Tax += PlayerVehicleInfo[playerid][listitem][pvTicket];
				SpeedingTickets += PlayerVehicleInfo[playerid][listitem][pvTicket];
				for(new z; z < MAX_GROUPS; z++)
				{
					if(arrGroupData[z][g_iAllegiance] == 1)
					{
						if(arrGroupData[z][g_iGroupType] == GROUP_TYPE_GOV)
						{
							new str[128];
							format(str, sizeof(str), "%s has paid some vehicle tickets adding $%s to the vault.", GetPlayerNameEx(playerid), number_format((PlayerVehicleInfo[playerid][listitem][pvTicket] / 100) * 30));
							GroupPayLog(z, str);
							break;
						}
					}
				}
				Misc_Save();
				strunpack(vehicleName, VehicleName[PlayerVehicleInfo[playerid][listitem][pvModelId] - 400], sizeof(vehicleName));
				SendClientMessageEx(playerid, COLOR_GRAD2, "Da tra $%s phat cho xe %s cua ban.", number_format(PlayerVehicleInfo[playerid][listitem][pvTicket]), vehicleName);
				PlayerVehicleInfo[playerid][listitem][pvTicket] = 0;
				g_mysql_SaveVehicle(playerid, listitem);
			}
			else if(PlayerVehicleInfo[playerid][listitem][pvImpounded]) {

				new
					iCost = (PlayerVehicleInfo[playerid][listitem][pvPrice] / 20) + PlayerVehicleInfo[playerid][listitem][pvTicket] + (PlayerInfo[playerid][pLevel] * 3000);

				if(GetPlayerCash(playerid) < iCost) {
					return SendClientMessage(playerid, COLOR_GRAD2, "Ban khong du tien mat.");
				}


				strunpack(vehicleName, VehicleName[PlayerVehicleInfo[playerid][listitem][pvModelId] - 400], sizeof(vehicleName));
				format(szMessage, sizeof(szMessage), "Ban da lay lai %s voi gia $%i.", vehicleName, iCost);
				SendClientMessage(playerid, COLOR_LIGHTBLUE, szMessage);
				GivePlayerCash(playerid, -iCost);
				Tax += iCost;
				SpeedingTickets += iCost;

				for(new z; z < MAX_GROUPS; z++)
				{
					if(arrGroupData[z][g_iAllegiance] == 0 || arrGroupData[z][g_iAllegiance] == 1)
					{
						if(arrGroupData[z][g_iGroupType] == GROUP_TYPE_GOV)
						{
							new str[128];
							format(str, sizeof(str), "%s has paid some vehicle tickets adding $%s to the vault.", GetPlayerNameEx(playerid), number_format((iCost / 100) * 30));
							GroupPayLog(z, str);
							break;
						}
					}
				}

				Misc_Save();

				new rand = random(sizeof(DMVRelease));
				PlayerVehicleInfo[playerid][listitem][pvPosX] = DMVRelease[rand][0];
				PlayerVehicleInfo[playerid][listitem][pvPosY] = DMVRelease[rand][1];
				PlayerVehicleInfo[playerid][listitem][pvPosZ] = DMVRelease[rand][2];

				PlayerVehicleInfo[playerid][listitem][pvImpounded] = 0;
				PlayerVehicleInfo[playerid][listitem][pvSpawned] = 0;
				PlayerVehicleInfo[playerid][listitem][pvPosAngle] = 180.000;
				PlayerVehicleInfo[playerid][listitem][pvTicket] = 0;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da tra xe, dung /vstorage de tao xe.");
				g_mysql_SaveVehicle(playerid, listitem);
			}
			else SendClientMessage(playerid, COLOR_GRAD2, "Xe khong ton tai hoac khong can tra phi/phat de lay lai.");
		}
		return 1;
	}
	if(dialogid == REPORTSMENU)
	{
		if(response)
		{
			if(CancelReport[playerid] == listitem) return 1;
			new reportid = ListItemReportId[playerid][listitem];
			if(Reports[reportid][BeingUsed] == 0)
			{
				SendClientMessageEx(playerid, COLOR_GREY, "   ID bao cao do khong ton tai!");
				return 1;
			}
			if(!IsPlayerConnected(Reports[reportid][ReportFrom]))
			{
				SendClientMessageEx(playerid, COLOR_GREY, "   Nguoi bao cao da thoat !");
				Reports[reportid][ReportFrom] = INVALID_PLAYER_ID;
				Reports[reportid][BeingUsed] = 0;
				return 1;
			}
			format(string, sizeof(string), "AdmCmd: %s da nhan bao cao cua %s (ID: %i RID: %i).", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]), Reports[reportid][ReportFrom], reportid);
			ABroadCast(COLOR_ORANGE, string, 2);
			AddReportToken(playerid); // Report Tokens
			if(PlayerInfo[playerid][pAdmin] == 1)
			{
				SendClientMessageEx(Reports[reportid][ReportFrom], COLOR_WHITE, "Admin da nhan va dang xem bao cao cua ban, dung /reply de gui tin cho admin dang xu ly.");
			}
			else
			{
				format(string, sizeof(string), "%s da nhan va dang xem bao cao cua ban, dung /reply de gui tin cho admin dang xu ly.", GetPlayerNameEx(playerid));
				SendClientMessageEx(Reports[reportid][ReportFrom], COLOR_WHITE, string);
			}
			PlayerInfo[playerid][pAcceptReport]++;
			ReportCount[playerid]++;
			ReportHourCount[playerid]++;
			Reports[reportid][ReplyTimerr] = SetTimerEx("ReplyTimer", 30000, false, "d", reportid);
			Reports[reportid][CheckingReport] = playerid;
			//Reports[reportid][ReportFrom] = INVALID_PLAYER_ID;
			Reports[reportid][BeingUsed] = 0;
			Reports[reportid][TimeToExpire] = 0;
			//strmid(Reports[reportid][Report], "None", 0, 4, 4);
		}
		else
		{
			if(CancelReport[playerid] == listitem) return 1;
			new reportid = ListItemReportId[playerid][listitem];
			if(Reports[reportid][BeingUsed] == 0)
			{
				SendClientMessageEx(playerid, COLOR_GREY, "   ID bao cao do khong ton tai!");
				return 1;
			}
			if(!IsPlayerConnected(Reports[reportid][ReportFrom]))
			{
				SendClientMessageEx(playerid, COLOR_GREY, "   Nguoi bao cao da thoat !");
				Reports[reportid][ReportFrom] = INVALID_PLAYER_ID;
				Reports[reportid][BeingUsed] = 0;
				return 1;
			}
			format(string, sizeof(string), "AdmCmd: %s da loai bao cao cua %s (RID: %i).", GetPlayerNameEx(playerid), GetPlayerNameEx(Reports[reportid][ReportFrom]), reportid);
			ABroadCast(COLOR_ORANGE, string, 2);
			if(PlayerInfo[playerid][pAdmin] == 1)
			{
				SendClientMessageEx(Reports[reportid][ReportFrom], COLOR_WHITE, "Admin da danh dau bao cao khong hop le. Bao cao se khong duoc xu ly.");
			}
			else
			{
				format(string, sizeof(string), "%s da danh dau bao cao khong hop le. Bao cao se khong duoc xu ly.", GetPlayerNameEx(playerid));
				SendClientMessageEx(Reports[reportid][ReportFrom], COLOR_WHITE, string);
			}
			PlayerInfo[playerid][pTrashReport]++;
			Reports[reportid][ReportFrom] = INVALID_PLAYER_ID;
			Reports[reportid][BeingUsed] = 0;
			Reports[reportid][TimeToExpire] = 0;
			new reportdialog[2048], itemid = 0;
			for(new i = 0; i < MAX_REPORTS; i++)
			{
				if(Reports[i][BeingUsed] == 1 && itemid < 40)
				{
					ListItemReportId[playerid][itemid] = i;
					itemid++;
					if(strlen((Reports[i][Report])) > 92)
					{
						new firstline[128], secondline[128];
						strmid(firstline, Reports[i][Report], 0, 88);
						strmid(secondline, Reports[i][Report], 88, 128);
						format(reportdialog, sizeof(reportdialog), "%s%s(ID:%i) | Report: %s", reportdialog, GetPlayerNameEx(Reports[i][ReportFrom]), Reports[i][ReportFrom], i, firstline);
						format(reportdialog, sizeof(reportdialog), "%s%s", reportdialog, secondline);
						ListItemReportId[playerid][itemid] = i;
						itemid++;
					}
					else format(reportdialog, sizeof(reportdialog), "%s%s(ID:%i) | Report: %s", reportdialog, GetPlayerNameEx(Reports[i][ReportFrom]), Reports[i][ReportFrom], i, (Reports[i][Report]));

					format(reportdialog, sizeof(reportdialog), "%s\n", reportdialog);
				}
			}
			CancelReport[playerid] = itemid;
			format(reportdialog, sizeof(reportdialog), "%s\n", reportdialog);
			format(reportdialog, sizeof(reportdialog), "%sHuy bao cao", reportdialog);
			//SendClientMessageEx(playerid, COLOR_GREEN, "___________________________________________________");
			ShowPlayerDialogEx(playerid, REPORTSMENU, DIALOG_STYLE_LIST, "Reports", reportdialog, "Dong y", "Bo");
			//strmid(Reports[reportid][Report], "None", 0, 4, 4);
		}
	}

	if(dialogid == COLORMENU)
	{
		if(response)
		{
			if(listitem == 0)
			{
				SetPlayerColor(playerid,COLOR_DBLUE);
				SendClientMessageEx(playerid, COLOR_DBLUE, "Da doi mau cua ban thanh Xanh duong!");
			}
			if(listitem == 1)
			{
				SetPlayerColor(playerid,COLOR_BLACK);
				SendClientMessageEx(playerid, COLOR_BLACK, "Da doi mau cua ban thanh Den!");
			}
			if(listitem == 2)
			{
				SetPlayerColor(playerid,COLOR_RED);
				SendClientMessageEx(playerid, COLOR_RED, "Da doi mau cua ban thanh Do!");
			}
			if(listitem == 3)
			{
				SetPlayerColor(playerid,TEAM_ORANGE_COLOR);
				SendClientMessageEx(playerid, TEAM_ORANGE_COLOR, "Da doi mau cua ban thanh Cam!");
			}
			if(listitem == 4)
			{
				SetPlayerColor(playerid,COLOR_PINK);
				SendClientMessageEx(playerid, COLOR_PINK, "Da doi mau cua ban thanh Hong!");
			}
			if(listitem == 5)
			{
				SetPlayerColor(playerid,COLOR_PURPLE);
				SendClientMessageEx(playerid, COLOR_PURPLE, "Da doi mau cua ban thanh Tim!");
			}
			if(listitem == 6)
			{
				SetPlayerColor(playerid,COLOR_GREEN);
				SendClientMessageEx(playerid, COLOR_GREEN, "Da doi mau cua ban thanh Xanh la!");
			}
			if(listitem == 7)
			{
				SetPlayerColor(playerid,COLOR_YELLOW);
				SendClientMessageEx(playerid, COLOR_YELLOW, "Da doi mau cua ban thanh Vang!");
			}
			if(listitem == 8)
			{
				SetPlayerColor(playerid,COLOR_WHITE);
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi mau cua ban thanh Trang!");
			}
			if(listitem == 9)
			{
				SetPlayerColor(playerid,TEAM_APRISON_COLOR);
				SendClientMessageEx(playerid, COLOR_WHITE, "Da doi mau cua ban thanh Cam tu nhan OOC!");
			}
		}
	}

	if(dialogid == FIGHTMENU)
	{
		if(response) Boxing_LearnStyle(playerid, listitem);
		return 1;
	}
	if(dialogid == DIALOG_LICENSE_BUY && response) // LICENSE BUY DIALOG ~Brian
	{
		switch (listitem)
		{
			/*case 0:
			{
				if(PlayerInfo[playerid][pCarLic] == 0)
				{
					if(GetPlayerCash(playerid) < 5000)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "You can not afford to buy a driver's license.");
						return 1;
					}
					GivePlayerCash(playerid,-5000);
					PlayerInfo[playerid][pCarLic] = 1;
					SendClientMessageEx(playerid, COLOR_GREY, "You have successfully acquired a driver's license.");
				}
				else SendClientMessageEx(playerid, COLOR_GREY, "You already have a driver's license.");
			}*/
			case 0:
			{
				if(PlayerInfo[playerid][pBoatLic] == 0)
				{
					if(GetPlayerCash(playerid) < 5000)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien mua bang lai thuyen.");
						return 1;
					}
					GivePlayerCash(playerid,-5000);
					PlayerInfo[playerid][pBoatLic] = 1;
					SendClientMessageEx(playerid, COLOR_GREY, "Ban da nhan duoc bang lai thuyen.");
				}
				else SendClientMessageEx(playerid, COLOR_GREY, "Ban da co bang lai thuyen.");
			}
			case 1:
			{
				if(PlayerInfo[playerid][pFlyLic] == 0)
				{
					if(PlayerInfo[playerid][pLevel] >=2)
					{
						if(GetPlayerCash(playerid) < 25000)
						{
							SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien mua bang lai may bay.");
							return 1;
						}
						GivePlayerCash(playerid,-25000);
						PlayerInfo[playerid][pFlyLic] = 1;
						SendClientMessageEx(playerid, COLOR_GREY, "Da nhan bang lai may bay, ban co the dieu khien may bay.");
					}
					else SendClientMessageEx(playerid, COLOR_GREY, "Can level 2 tro len de mua bang lai may bay.");
				}
				else SendClientMessageEx(playerid, COLOR_GREY, "Ban da co bang lai may bay.");
			}
			case 2:
			{
				if(PlayerInfo[playerid][pTaxiLicense] == 0)
				{
					if(GetPlayerCash(playerid) < 35000)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien mua bang lai taxi.");
						return 1;
					}
					GivePlayerCash(playerid,-35000);
					PlayerInfo[playerid][pTaxiLicense] = 1;
					SendClientMessageEx(playerid, COLOR_GREY, "Da nhan bang lai taxi, co the dung /fare tren moi xe va nhan cuoc goi taxi.");
				}
				else SendClientMessageEx(playerid, COLOR_GREY, "Ban da co bang lai taxi.");
			}
		}
	}
	if(dialogid == MDC_MAIN && response)
	{
		if(!IsMDCPermitted(playerid)) return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, " Dang nhap loi. Ban khong co quyen dung MDC!");
		switch( listitem )
		{
			case 0:
			{
				ShowPlayerDialogEx(playerid, MDC_CIVILIANS, DIALOG_STYLE_LIST, "MDC - Da dang nhap | Cong dan", "*Tra cuu ho so\n*Bao cao bat giu\n*Giay phep\n*Lenh truy na\n*Lap lenh truy na\n*BOLO\n*Lap BOLO\n*Xoa", "Dong y", "Huy");
			}
			case 1: ShowPlayerDialogEx(playerid, MDC_SUSPECT, DIALOG_STYLE_INPUT, "MDC - Truy na nghi pham", "Nhap (mot phan) ten nghi pham de truy na.", "Dong y", "Huy");
			case 2: ShowPlayerDialogEx(playerid, G_LOCKER_CLEARSUSPECT, DIALOG_STYLE_INPUT, arrGroupData[PlayerInfo[playerid][pMember]][g_szGroupName]," Ban muon xoa truy na cho ai?","Xoa","Quay lai");
			case 3:	ShowPlayerDialogEx(playerid, MDC_VEHICLE, DIALOG_STYLE_INPUT, "MDC - Dang ky xe", "Nhap (mot phan) ten de tra cuu dang ky xe cua nguoi do.", "Dong y", "Huy");
			case 4:
			{
				ShowPlayerDialogEx(playerid, MDC_FIND, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | GPS LEO", "Nhap ten hoac ID nhan vien hanh phap.", "Nhap", "Huy");
			}
			case 5:
			{
				new groups[1024], item;
				for (new i; i < MAX_GROUPS; i++)
				{
					if (arrGroupData[i][g_szGroupName][0] && arrGroupData[i][g_iGroupType] == GROUP_TYPE_LEA && arrGroupData[i][g_iAllegiance] == arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance])
					{
						format(groups, sizeof(groups), "%s*%s\n", groups, arrGroupData[i][g_szGroupName]);
						ListItemTrackId[playerid][item++] = i;
					}
					ShowPlayerDialogEx(playerid, MDC_MEMBERS, DIALOG_STYLE_LIST, "MDC - Da dang nhap | Co quan", groups, "Dong y", "Huy");
				}
			}
			case 6: ShowPlayerDialogEx(playerid, MDC_MESSAGE, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | Tin MDC", "Nhap ten hoac ID nguoi nhan.", "Dong y", "Huy");
			case 7: ShowPlayerDialogEx(playerid, MDC_SMS, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | SMS", "Nhap so dien thoai nguoi nhan.", "Dong y", "Huy");
		}
	}
	if(dialogid == MDC_SUSPECT) return pc_cmd_su(playerid, inputtext);
	if(dialogid == MDC_VEHICLE) return pc_cmd_vmdc(playerid, inputtext);
	if(dialogid == MDC_VLOOKUP) return pc_cmd_vlookup(playerid, inputtext);
	if(dialogid == MDC_FIND && response)
	{
		new giveplayerid;
		if(!IsMDCPermitted(playerid)) return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, " Dang nhap loi. Ban khong co quyen dung MDC!");
		if(sscanf(inputtext, "u", giveplayerid))
		{
			ShowPlayerDialogEx(playerid, MDC_FIND, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | GPS LEO", "Nhap ten hoac ID nhan vien hanh phap.", "Nhap", "Huy");
			return 1;
		}

		if(IsPlayerConnected(giveplayerid))
		{
			if(giveplayerid != INVALID_PLAYER_ID)
			{
				if(giveplayerid == playerid)
				{
					ShowPlayerDialogEx(playerid, MDC_FIND, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | LOI", "LOI: Khong the tu tim minh.\nNhap ten hoac ID nhan vien hanh phap.", "Nhap", "Huy");

					return 1;
				}
				if(IsACop(giveplayerid) && arrGroupData[PlayerInfo[giveplayerid][pMember]][g_iAllegiance] == arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance])
				{
					SetPlayerMarkerForPlayer(playerid,giveplayerid,FIND_COLOR);
					FindingPlayer[playerid] = giveplayerid;
					FindTime[playerid] = 1;
					FindTimePoints[playerid] = 30;
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, " Chi duoc theo doi canh sat khac!");
				}
			}
		}
	}
	if(dialogid == MDC_CIVILIANS && response)
	{ //"*Check Record\n*View Arrest Reports\n*Licenses\n*Warrants\n*Issue Warrant\n*BOLO\n*Create BOLO\n*Delete"
		new WarrantString[512];
		if(!IsMDCPermitted(playerid)) return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, " Dang nhap loi. Ban khong co quyen dung MDC!");
		if(News[hTaken6] == 1)
		{
			format(string, sizeof(string), "%s :: Officer: %s\n", News[hAdd6], News[hContact6]);
			strcat(WarrantString, string, sizeof(WarrantString));
		}
		if(News[hTaken7] == 1)
		{
			format(string, sizeof(string), "%s :: Officer: %s\n", News[hAdd7], News[hContact7]);
			strcat(WarrantString, string, sizeof(WarrantString));
		}
		if(News[hTaken8] == 1)
		{
			format(string, sizeof(string), "%s :: Officer: %s\n", News[hAdd8], News[hContact8]);
			strcat(WarrantString, string, sizeof(WarrantString));
		}
		if(News[hTaken9] == 1)
		{
			format(string, sizeof(string), "%s :: Officer: %s\n", News[hAdd9], News[hContact9]);
			strcat(WarrantString, string, sizeof(WarrantString));
		}
		if(News[hTaken10] == 1)
		{
			format(string, sizeof(string), "%s :: Officer: %s\n", News[hAdd10], News[hContact10]);
			strcat(WarrantString, string, sizeof(WarrantString));
		}
		if(News[hTaken11] == 1)
		{
			format(string, sizeof(string), "%s :: Officer: %s\n", News[hAdd11], News[hContact11]);
			strcat(WarrantString, string, sizeof(WarrantString));
		}
		if(News[hTaken12] == 1)
		{
			format(string, sizeof(string), "%s :: Officer: %s\n", News[hAdd12], News[hContact12]);
			strcat(WarrantString, string, sizeof(WarrantString));
		}
		if(News[hTaken13] == 1)
		{
			format(string, sizeof(string), "%s :: Officer: %s\n", News[hAdd13], News[hContact13]);
			strcat(WarrantString, string, sizeof(WarrantString));
		}
		if(strlen(WarrantString) == 0)
		{
			strcat(WarrantString, "Chua co lenh truy na.", sizeof(WarrantString));
		}
		switch(listitem)
		{
			case 0: ShowPlayerDialogEx(playerid, MDC_CHECK, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | Ho so", "Nhap ten hoac ID nguoi do.", "Nhap", "Huy");
			case 1: ShowPlayerDialogEx(playerid, MDC_REPORTS, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | Bao cao", "Nhap ten hoac ID nguoi do.", "Nhap", "Huy");
			case 2: ShowPlayerDialogEx(playerid, MDC_LICENSES, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | Giay phep", "Nhap ten hoac ID nguoi do.", "Nhap", "Huy");
			case 3: ShowPlayerDialogEx(playerid, MDC_WARRANTS, DIALOG_STYLE_LIST, "MDC - Da dang nhap | Lenh truy na", WarrantString, "Chon", "Huy");
			case 4: ShowPlayerDialogEx(playerid, MDC_ISSUE_SLOT, DIALOG_STYLE_LIST, "MDC - Da dang nhap | Chon o su dung", "1\n2\n3\n4\n5\n6\n7\n8", "Chon", "Huy");
			case 5:
			{
				new BOLOString[512];
				if(News[hTaken14] == 1)
				{
					format(string, sizeof(string), "%s :: Officer: %s\n", News[hAdd14], News[hContact14]);
					strcat(BOLOString, string, sizeof(BOLOString));
				}
				if(News[hTaken15] == 1)
				{
					format(string, sizeof(string), "%s :: Officer: %s\n", News[hAdd15], News[hContact15]);
					strcat(BOLOString, string, sizeof(BOLOString));
				}
				if(News[hTaken16] == 1)
				{
					format(string, sizeof(string), "%s :: Officer: %s\n", News[hAdd16], News[hContact16]);
					strcat(BOLOString, string, sizeof(BOLOString));
				}
				if(News[hTaken17] == 1)
				{
					format(string, sizeof(string), "%s :: Officer: %s\n", News[hAdd17], News[hContact17]);
					strcat(BOLOString, string, sizeof(BOLOString));
				}
				if(News[hTaken18] == 1)
				{
					format(string, sizeof(string), "%s :: Officer: %s\n", News[hAdd18], News[hContact18]);
					strcat(BOLOString, string, sizeof(BOLOString));
				}
				if(News[hTaken19] == 1)
				{
					format(string, sizeof(string), "%s :: Officer: %s\n", News[hAdd19], News[hContact19]);
					strcat(BOLOString, string, sizeof(BOLOString));
				}
				if(News[hTaken20] == 1)
				{
					format(string, sizeof(string), "%s :: Officer: %s\n", News[hAdd20], News[hContact20]);
					strcat(BOLOString, string, sizeof(BOLOString));
				}
				if(News[hTaken21] == 1)
				{
					format(string, sizeof(string), "%s :: Officer: %s\n", News[hAdd21], News[hContact21]);
					strcat(BOLOString, string, sizeof(BOLOString));
				}
				if(strlen(BOLOString) == 0)
				{
					strcat(BOLOString, "Chua co BOLO.", sizeof(BOLOString));
				}
				ShowPlayerDialogEx(playerid, MDC_BOLOLIST, DIALOG_STYLE_LIST, "MDC - Da dang nhap | BOLO", BOLOString, "Dong y", "Huy");
			}
			case 6:
			{
				ShowPlayerDialogEx(playerid, MDC_BOLO_SLOT, DIALOG_STYLE_LIST, "MDC - Da dang nhap | Chon o su dung", "1\n2\n3\n4\n5\n6\n7\n8", "Chon", "Huy");
			}
			case 7:
			{
				ShowPlayerDialogEx(playerid, MDC_DELETE, DIALOG_STYLE_LIST, "MDC - Da dang nhap | Xoa", "*BOLO\n*Lenh truy na", "Dong y", "Huy");
			}
		}

	}
	if(dialogid == MDC_MEMBERS && response)
	{
		if(!IsMDCPermitted(playerid)) return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, " Dang nhap loi. Ban khong co quyen dung MDC!");
		new MemberString[1024], giveplayer[MAX_PLAYER_NAME], badge[11];
		new rank[GROUP_MAX_RANK_LEN], division[GROUP_MAX_DIV_LEN], employer[GROUP_MAX_NAME_LEN];
		new group = ListItemTrackId[playerid][listitem];
		foreach(new i: Player)
		{
			if(PlayerInfo[i][pMember] == group)
			{
				if(strcmp(PlayerInfo[i][pBadge], "None", true) != 0) format(badge, sizeof(badge), "[%s] ", PlayerInfo[i][pBadge]);
				GetPlayerGroupInfo(i, rank, division, employer);
				giveplayer = GetPlayerNameEx(i);
				format(string, sizeof(string), "* %s%s (%s) %s Ph: %d\n", badge, rank, division,  giveplayer, PlayerInfo[i][pPnumber]);
				strcat(MemberString, string, sizeof(MemberString));
			}
		}
		if(strlen(MemberString) == 0)
		{
			strcat(MemberString, "Chua co thanh vien online.", sizeof(MemberString));
		}
		format(string, sizeof(string), "MDC - Thanh vien %s", arrGroupData[group][g_szGroupName]);
		ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_LIST, string, MemberString, "Chon", "Huy");
	}
	if(dialogid == MDC_WARRANTS && response)
	{
		if(!IsMDCPermitted(playerid)) return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, " Dang nhap loi. Ban khong co quyen dung MDC!");
		ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Truy na", inputtext, "Dong y", "Quay lai");
	}
	if(dialogid == MDC_BOLOLIST && response)
	{
		if(!IsMDCPermitted(playerid)) return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, " Dang nhap loi. Ban khong co quyen dung MDC!");
		ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Chi tiet BOLO", inputtext, "Dong y", "Quay lai");
	}
/*	if(dialogid == MDC_CHECK && response)
	{
		if(!IsMDCPermitted(playerid)) return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, " Login Failed. You are not permitted to use the MDC!");
		new giveplayerid = ReturnUser(inputtext);
		new HistoryString[1024];
		new giveplayer[MAX_PLAYER_NAME];
		giveplayer = GetPlayerNameEx(giveplayerid);
		if(giveplayerid != INVALID_PLAYER_ID)
		{
			format(string, sizeof(string), "Name : %s\n", GetPlayerNameEx(giveplayerid));
			strcat(HistoryString, string, sizeof(HistoryString));
			format(string, sizeof(string), "Crime : %s\n", PlayerCrime[giveplayerid][pAccusedof]);
			strcat(HistoryString, string, sizeof(HistoryString));
			format(string, sizeof(string), "Claimant : %s\n", PlayerCrime[giveplayerid][pVictim]);
			strcat(HistoryString, string, sizeof(HistoryString));
			format(string, sizeof(string), "Reported : %s\n", PlayerCrime[giveplayerid][pAccusing]);
			strcat(HistoryString, string, sizeof(HistoryString));
			format(string, sizeof(string), "Accused : %s\n", PlayerCrime[giveplayerid][pBplayer]);
			strcat(HistoryString, string, sizeof(HistoryString));
			if(PlayerInfo[giveplayerid][pProbationTime] != 0)
			{
				format(string, sizeof(string), "Probation : %d minutes left\n", PlayerInfo[giveplayerid][pProbationTime]);
				strcat(HistoryString, string, sizeof(HistoryString));
			}
			for(new i=0; i<MAX_PLAYERVEHICLES; i++)
			{
				if(PlayerVehicleInfo[giveplayerid][i][pvTicket] != 0)
				{
					format(string, sizeof(string), "Vehicle registration: %d | Vehicle Name: %s | Ticket: $%d.\n",PlayerVehicleInfo[giveplayerid][i][pvId],GetVehicleName(PlayerVehicleInfo[giveplayerid][i][pvId]),PlayerVehicleInfo[giveplayerid][i][pvTicket]);
					strcat(HistoryString, string, sizeof(HistoryString));
				}
			}
			ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_LIST, "MDC - Logged in | Criminal History", HistoryString, "OK", "Cancel");
			format(string, sizeof(string), "** DISPATCH: %s has run a check for warrants on %s **", GetPlayerNameEx(playerid), giveplayer);
			SendRadioMessage(1, COLOR_DBLUE, string);
			SendRadioMessage(2, COLOR_DBLUE, string);
			SendRadioMessage(3, COLOR_DBLUE, string);
			return 1;
		}
		else
		{
			ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Logged in | ERROR ", "There is no record of that person.", "OK", "Cancel");
			return 1;
		}
	}*/
	if(dialogid == MDC_REPORTS && response)
	{
		if(!IsMDCPermitted(playerid)) return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, " Dang nhap loi. Ban khong co quyen dung MDC!");
		new giveplayerid = ReturnUser(inputtext);
		if(giveplayerid != INVALID_PLAYER_ID)
		{
			DisplayReports(playerid, giveplayerid);
			format(string, sizeof(string), "* %s da tra cuu bao cao bat giu cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
			foreach(new i: Player)
			{
				if(PlayerInfo[playerid][pToggledChats][12] == 0)
				{
					if(PlayerInfo[i][pMember] == PlayerInfo[playerid][pMember] && PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[i][pMember]][g_iRadioAccess]) {
						ChatTrafficProcess(i, arrGroupData[PlayerInfo[i][pMember]][g_hRadioColour] * 256 + 255, string, 12);
					}
				}
			}
			//SendGroupMessage(GROUP_TYPE_LEA, COLOR_DBLUE, string);
			return 1;
		}
		else
		{
			ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | LOI ", "Khong co ho so nguoi do.", "Dong y", "Huy");
			return 1;
		}
	}
	if(dialogid == MDC_SHOWREPORTS && response)
	{
		new stpos = strfind(inputtext, "(");
		new fpos = strfind(inputtext, ")");
		new reportidstr[6], repid;
		strmid(reportidstr, inputtext, stpos+1, fpos);
		repid = strval(reportidstr);
		return DisplayReport(playerid, repid);
	}
	if(dialogid == DIALOG_JFINECONFIRM)
	{
		if(response)
		{
			SetPVarInt(playerid, "jGroup", listitem);
			format(string, sizeof(string), "Ban chac muon gui mot phan tien phat cho %s?", arrGroupData[listitem][g_szGroupName]);
			ShowPlayerDialogEx(playerid, DIALOG_JFINE, DIALOG_STYLE_MSGBOX, "Judge Fine - Xac nhan", string, "Xac nhan", "Huy");
		}
		else {
			DeletePVar(playerid, "jGroup");
			DeletePVar(playerid, "jfined");
			DeletePVar(playerid, "judgefine");
			DeletePVar(playerid, "jreason");
			SendClientMessageEx(playerid, COLOR_GRAD2, "Da huy phat, nhap lai lenh phat cua Judge de bat dau lai.");
		}
	}
	if(dialogid == DIALOG_JFINE)
	{
		if(response)
		{
			new iGroupID = GetPVarInt(playerid, "jGroup");
			new giveplayerid = GetPVarInt(playerid, "jfined");
			new judgefine = GetPVarInt(playerid, "judgefine");
			new reason[64];
			GetPVarString(playerid, "jreason", reason, 64);
			new Judicial, Group, Gov;
			GivePlayerCash(giveplayerid, -judgefine);
			Judicial = floatround( judgefine * 0.10 ); // Judicials cut - 10%
			Group = floatround ( judgefine * 0.6);  // Arresting Groups Cut - 60%
			Gov = floatround ( judgefine * 0.10);  //  Government cut = 10%
			// 20% Deleted from economy
			Tax += Gov;
			arrGroupData[PlayerInfo[playerid][pMember]][g_iBudget] += Judicial;
			arrGroupData[iGroupID][g_iBudget] += Group;
			new str[128];
			format(str, sizeof(str), "%s has been fined by $%s by Judge %s.  $%s has been sent to the %s Vault.",GetPlayerNameEx(giveplayerid), number_format(judgefine), GetPlayerNameEx(playerid), number_format(Judicial), arrGroupData[PlayerInfo[playerid][pMember]][g_szGroupName]);
			GroupPayLog(PlayerInfo[playerid][pMember], str);
			format(str, sizeof(str), "%s has been fined by $%s by Judge %s.  $%s has been sent to the %s Vault.",GetPlayerNameEx(giveplayerid), number_format(judgefine), GetPlayerNameEx(playerid), number_format(Group), arrGroupData[iGroupID][g_szGroupName]);
			GroupPayLog(iGroupID, str);
			for(new z; z < MAX_GROUPS; z++)
			{
				if(arrGroupData[z][g_iAllegiance] == 1)
				{
					if(arrGroupData[z][g_iGroupType] == GROUP_TYPE_GOV)
					{
						format(str, sizeof(str), "%s has been fined by $%s by Judge %s.  $%s has been sent to the SA Government Vault.",GetPlayerNameEx(giveplayerid), number_format(judgefine), GetPlayerNameEx(playerid), number_format(Gov));
						GroupPayLog(z, str);
						break;
					}
				}
			}
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da phat %s $%s, ly do: %s", GetPlayerNameEx(giveplayerid), number_format(judgefine), reason);
			SendClientMessageEx(giveplayerid, COLOR_WHITE, "Ban bi phat $%s boi %s, ly do: %s", number_format(judgefine), GetPlayerNameEx(playerid), reason);
			format(string, sizeof(string), "%s bi phat $%s boi Judge %s. Hoa hong da duoc gui den %s.", GetPlayerNameEx(giveplayerid), number_format(judgefine), GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_szGroupName]);
			ABroadCast( COLOR_YELLOW, string, 2);
			format(string, sizeof(string), "%s(%d) has been fined $%s by Judge %s(%d).  Commission has been sent to %s.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), number_format(judgefine), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), arrGroupData[iGroupID][g_szGroupName]);
			Log("logs/rpspecial.log", string);
		}
	}
	if(dialogid == DIALOG_ARRESTREPORT)
	{
		if(response)
		{
			new moneys = GetPVarInt(playerid, "Arrest_Price"), time = GetPVarInt(playerid, "Arrest_Time"),
				bail = GetPVarInt(playerid, "Arrest_Bail"), bailprice = 15000000, // STATIC BAIL. GetPVarInt(playerid, "Arrest_BailPrice"),
				suspect = GetPVarInt(playerid, "Arrest_Suspect"), arresttype = GetPVarInt(playerid, "Arrest_Type");
			if(strlen(inputtext) < 30 || strlen(inputtext) > 128)
			{
				format(szMiscArray, sizeof(szMiscArray), "Viet bao cao ngan ve hanh vi cua %s khi bi bat.\n\nBao cao phai dai tu 30 den 128 ky tu.", GetPlayerNameEx(suspect));
				return ShowPlayerDialogEx(playerid, DIALOG_ARRESTREPORT, DIALOG_STYLE_INPUT, "Bao cao bat giu", szMiscArray, "Gui", "");
			}
			switch(arresttype)
			{
				case 0, 1: { //arrest
					if(bail && bailprice > 0)
					{
						SendClientMessageEx(suspect, COLOR_RED, "Ban duoc phep bao lanh voi gia $%s. (/bail)", number_format(bailprice));
						PlayerInfo[suspect][pBailPrice] = bailprice;
					}
					format(string, sizeof(string), "* Ban da dua %s den Local PD Jail.", GetPlayerNameEx(suspect));
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, string);
					GivePlayerCash(suspect, -moneys);
					new money = floatround(moneys / 3), iGroupID = PlayerInfo[playerid][pMember];
					arrGroupData[iGroupID][g_iBudget] += money;
					new str[164];
					format(str, sizeof(str), "%s has been arrested by %s for %d minutes and fined $%d. $%d has been sent to %s's budget fund.",GetPlayerNameEx(suspect), GetPlayerNameEx(playerid),time, moneys, money, arrGroupData[iGroupID][g_szGroupName]);
					GroupPayLog(iGroupID, str);
					for(new z; z < MAX_GROUPS; z++)
					{
						if(arrGroupData[iGroupID][g_iAllegiance] == 1)
						{
							if(arrGroupData[z][g_iAllegiance] == 1)
							{
								if(arrGroupData[z][g_iGroupType] == GROUP_TYPE_GOV)
								{
									Tax += money;
									format(str, sizeof(str), "%s has been arrested by %s and fined $%d. $%d has been sent to the SA Government Vault.",GetPlayerNameEx(suspect), GetPlayerNameEx(playerid), moneys, money);
									GroupPayLog(z, str);
									break;
								}
							}
						}
						else if(arrGroupData[z][g_iAllegiance] == 2)
						{
							if(arrGroupData[z][g_iAllegiance] == 2)
							{
								if(arrGroupData[z][g_iGroupType] == GROUP_TYPE_GOV)
								{
									TRTax += money;
									format(str, sizeof(str), "%s has been arrested by %s and fined $%d. $%d has been sent to the NE Government Vault.",GetPlayerNameEx(suspect), GetPlayerNameEx(playerid), moneys, money);
									GroupPayLog(z, str);
									break;
								}
							}
						}
					}
					ResetPlayerWeaponsEx(suspect);
					SetPlayerInterior(suspect, ArrestPoints[GetArrestPointID(playerid)][jailInt]);
					//new rand = random(sizeof(LSPDJailSpawns));
					//SetPlayerFacingAngle(suspect, LSPDJailSpawns[rand][3]);
					//SetPlayerPos(suspect, LSPDJailSpawns[rand][0], LSPDJailSpawns[rand][1], LSPDJailSpawns[rand][2]);
					switch(random(2)) {
						case 0: {
							SetPlayerPos(suspect, ArrestPoints[GetArrestPointID(playerid)][JailPos1][0], ArrestPoints[GetArrestPointID(playerid)][JailPos1][1], ArrestPoints[GetArrestPointID(playerid)][JailPos1][2]);
							Player_StreamPrep(suspect, ArrestPoints[GetArrestPointID(playerid)][JailPos1][0], ArrestPoints[GetArrestPointID(playerid)][JailPos1][1], ArrestPoints[GetArrestPointID(playerid)][JailPos1][2], FREEZE_TIME);
						}
						case 1: {
							SetPlayerPos(suspect, ArrestPoints[GetArrestPointID(playerid)][JailPos2][0], ArrestPoints[GetArrestPointID(playerid)][JailPos2][1], ArrestPoints[GetArrestPointID(playerid)][JailPos2][2]);
							Player_StreamPrep(suspect, ArrestPoints[GetArrestPointID(playerid)][JailPos2][0], ArrestPoints[GetArrestPointID(playerid)][JailPos2][1], ArrestPoints[GetArrestPointID(playerid)][JailPos2][2], FREEZE_TIME);
						}
					}
					SetPVarInt(suspect, "ArrestPoint", (GetArrestPointID(playerid) + 1));
					if(PlayerInfo[suspect][pDonateRank] >= 2)
					{
						PlayerInfo[suspect][pJailTime] = ((time*60)*75)/100;
					}
					else
					{
						PlayerInfo[suspect][pJailTime] = time * 60;
					}
					if(PlayerInfo[suspect][pJailTime] > 7200) PlayerInfo[suspect][pJailTime] = 7200;
					DeletePVar(suspect, "IsFrozen");
					PhoneOnline[suspect] = 1;
					PlayerInfo[suspect][pArrested] += 1;
					SetPlayerFree(suspect,playerid, "was arrested");
					PlayerInfo[suspect][pWantedLevel] = 0;
					SetPlayerToTeamColor(suspect);
					SetPlayerWantedLevel(suspect, 0);
					WantLawyer[suspect] = 1;
					TogglePlayerControllable(suspect, true);
					ClearAnimationsEx(suspect);
					SetPlayerSpecialAction(suspect, SPECIAL_ACTION_NONE);
					PlayerCuffed[suspect] = 0;
					DeletePVar(suspect, "PlayerCuffed");
					PlayerCuffedTime[suspect] = 0;
					SetPlayerInterior(suspect, ArrestPoints[GetArrestPointID(playerid)][jailInt]);
					PlayerInfo[suspect][pInt] = ArrestPoints[GetArrestPointID(playerid)][jailVW];
					PlayerInfo[suspect][pVW] = ArrestPoints[GetArrestPointID(playerid)][jailVW];
					SetPlayerVirtualWorld(suspect, ArrestPoints[GetArrestPointID(playerid)][jailVW]);
					strcpy(PlayerInfo[suspect][pPrisonedBy], GetPlayerNameEx(playerid), MAX_PLAYER_NAME);
					strcpy(PlayerInfo[suspect][pPrisonReason], "[IC] EBCF", 128);
					SetPlayerToTeamColor(suspect);
					SetHealth(suspect, 100);
				}
				case 2: { // /docarrest
					format(string, sizeof(string), "* Ban da dua %s den DoC.", GetPlayerNameEx(suspect));
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, string);
					GivePlayerCash(suspect, -moneys);
					new money = floatround(moneys / 3), iGroupID = PlayerInfo[playerid][pMember];
					arrGroupData[iGroupID][g_iBudget] += money;
					new str[164];
					format(str, sizeof(str), "%s has been arrested by %s for %d minutes and fined $%d. $%d has been sent to %s's budget fund.",GetPlayerNameEx(suspect), GetPlayerNameEx(playerid),time, moneys, money, arrGroupData[iGroupID][g_szGroupName]);
					GroupPayLog(iGroupID, str);
					for(new z; z < MAX_GROUPS; z++)
					{
						if(arrGroupData[iGroupID][g_iAllegiance] == 1)
						{
							if(arrGroupData[z][g_iAllegiance] == 1)
							{
								if(arrGroupData[z][g_iGroupType] == GROUP_TYPE_GOV)
								{
									Tax += money;
									format(str, sizeof(str), "%s has been arrested by %s and fined $%d. $%d has been sent to the SA Government Vault.",GetPlayerNameEx(suspect), GetPlayerNameEx(playerid), moneys, money);
									GroupPayLog(z, str);
									break;
								}
							}
						}
						else if(arrGroupData[z][g_iAllegiance] == 2)
						{
							if(arrGroupData[z][g_iAllegiance] == 2)
							{
								if(arrGroupData[z][g_iGroupType] == GROUP_TYPE_GOV)
								{
									TRTax += money;
									format(str, sizeof(str), "%s has been arrested by %s and fined $%d. $%d has been sent to the NE Government Vault.",GetPlayerNameEx(suspect), GetPlayerNameEx(playerid), moneys, money);
									GroupPayLog(z, str);
									break;
								}
							}
						}
					}
					ResetPlayerWeaponsEx(suspect);
					SetPlayerInterior(suspect, 1);
					PlayerInfo[suspect][pInt] = 1;
					SetPlayerFacingAngle(suspect, 0);
					if(PlayerInfo[suspect][pDonateRank] >= 2)
					{
						PlayerInfo[suspect][pJailTime] = ((time*60)*75)/100;
					}
					else
					{
						PlayerInfo[suspect][pJailTime] = time * 60;
					}
					if(PlayerInfo[suspect][pJailTime] > 7200) PlayerInfo[suspect][pJailTime] = 7200;
					DeletePVar(suspect, "IsFrozen");
					PhoneOnline[suspect] = 1;
					PlayerInfo[suspect][pArrested] += 1;
					SetPlayerFree(suspect,playerid, "was arrested");
					PlayerInfo[suspect][pWantedLevel] = 0;
					SetPlayerToTeamColor(suspect);
					SetPlayerWantedLevel(suspect, 0);
					WantLawyer[suspect] = 1;
					TogglePlayerControllable(suspect, true);
					ClearAnimationsEx(suspect);
					SetPlayerSpecialAction(suspect, SPECIAL_ACTION_NONE);
					PlayerCuffed[suspect] = 0;
					DeletePVar(suspect, "PlayerCuffed");
					PlayerCuffedTime[suspect] = 0;
					PlayerInfo[suspect][pVW] = 0;
					SetPlayerVirtualWorld(suspect, 0);
					SetHealth(suspect, 100);
					strcpy(PlayerInfo[suspect][pPrisonedBy], GetPlayerNameEx(playerid), MAX_PLAYER_NAME);
					strcpy(PlayerInfo[suspect][pPrisonReason], "[IC] DMCF Arrest", 128);
					SetPlayerToTeamColor(suspect);
					SetHealth(suspect, 100);
					new randcell = random(29);
					PlayerInfo[suspect][pPrisonCell] = randcell;
					SpawnPlayerInPrisonCell(suspect, randcell);
				}
				case 3: // doc judge arrest
				{
					format(string, sizeof(string), "* Ban da tuyen an %s tai toa DoC.", GetPlayerNameEx(suspect));
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, string);
					GivePlayerCash(suspect, -moneys);
					new money = floatround(moneys / 3), iGroupID = PlayerInfo[playerid][pMember];
					arrGroupData[iGroupID][g_iBudget] += money;
					new str[164];
					format(str, sizeof(str), "%s has been arrested by %s for %d minutes and fined $%d. $%d has been sent to %s's budget fund.",GetPlayerNameEx(suspect), GetPlayerNameEx(playerid),time, moneys, money, arrGroupData[iGroupID][g_szGroupName]);
					GroupPayLog(iGroupID, str);
					for(new z; z < MAX_GROUPS; z++)
					{
						if(arrGroupData[iGroupID][g_iAllegiance] == 1)
						{
							if(arrGroupData[z][g_iAllegiance] == 1)
							{
								if(arrGroupData[z][g_iGroupType] == GROUP_TYPE_GOV)
								{
									Tax += money;
									format(str, sizeof(str), "%s has been arrested by %s and fined $%d. $%d has been sent to the SA Government Vault.",GetPlayerNameEx(suspect), GetPlayerNameEx(playerid), moneys, money);
									GroupPayLog(z, str);
									break;
								}
							}
						}
						else if(arrGroupData[z][g_iAllegiance] == 2)
						{
							if(arrGroupData[z][g_iAllegiance] == 2)
							{
								if(arrGroupData[z][g_iGroupType] == GROUP_TYPE_GOV)
								{
									TRTax += money;
									format(str, sizeof(str), "%s has been arrested by %s and fined $%d. $%d has been sent to the NE Government Vault.",GetPlayerNameEx(suspect), GetPlayerNameEx(playerid), moneys, money);
									GroupPayLog(z, str);
									break;
								}
							}
						}
					}
					if(PlayerInfo[suspect][pDonateRank] >= 2)
					{
						PlayerInfo[suspect][pJailTime] = ((time*60)*75)/100;
					}
					else
					{
						PlayerInfo[suspect][pJailTime] = time * 60;
					}
					PhoneOnline[suspect] = 1;
					PlayerInfo[suspect][pArrested] += 1;
					SetPlayerFree(suspect,playerid, "was arrested");
					PlayerInfo[suspect][pWantedLevel] = 0;
					SetPlayerToTeamColor(suspect);
					SetPlayerWantedLevel(suspect, 0);
					SetPVarInt(playerid, "pTut", 0);
					strcpy(PlayerInfo[suspect][pPrisonedBy], GetPlayerNameEx(playerid), MAX_PLAYER_NAME);
					strcpy(PlayerInfo[suspect][pPrisonReason], "[IC][JUDGE] EBCF Arrest", 128);
					SetPlayerToTeamColor(suspect);
				}
			}
			new iAllegiance;
			if((0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS))
			{
				iAllegiance = arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance];
			}
			else iAllegiance = 1;
			mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "INSERT INTO `arrestreports` (`copid`, `suspectid`, `shortreport`, `origin`) VALUES ('%d', '%d', '%e', '%d')", GetPlayerSQLId(playerid), GetPlayerSQLId(suspect), inputtext, iAllegiance);
			mysql_tquery(MainPipeline, szMiscArray, "OnQueryFinish", "i", SENDDATA_THREAD);
			format(szMiscArray, sizeof(szMiscArray), "Ban da bat %s trong %d phut voi tien phat $%s", GetPlayerNameEx(suspect), time, number_format(moneys));
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, szMiscArray);
			PlayerInfo[suspect][pWantedJailFine] = 0;
			PlayerInfo[suspect][pWantedJailTime] = 0;
			Prison_SetPlayerSkin(suspect);
			for(new x;x<MAX_PLAYERTOYS;x++) {
				if(IsPlayerAttachedObjectSlotUsed(suspect, x))
				{
					if(x == 9 && PlayerInfo[suspect][pBEquipped])
						break;
					RemovePlayerAttachedObject(suspect, x);
				}
			}
			for(new i; i < 10; i++) {
				PlayerHoldingObject[suspect][i] = 0;
			}
			DeletePVar(suspect, "jailcuffs");
			DeletePVar(playerid, "Arrest_Price");
			DeletePVar(playerid, "Arrest_Time");
			DeletePVar(playerid, "Arrest_Bail");
			DeletePVar(playerid, "Arrest_BailPrice");
			DeletePVar(playerid, "Arrest_Suspect");
		}
	}
	if(dialogid == MDC_CHECK && response)
	{
		if(!IsMDCPermitted(playerid)) return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, " Dang nhap loi. Ban khong co quyen dung MDC!");
		new giveplayerid = ReturnUser(inputtext);
		if(giveplayerid != INVALID_PLAYER_ID)
		{
			DisplayCrimes(playerid, giveplayerid);
			format(string, sizeof(string), "* %s da tra cuu lenh truy na cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
			foreach(new i: Player)
			{
				if(PlayerInfo[playerid][pToggledChats][12] == 0)
				{
					if(PlayerInfo[i][pMember] == PlayerInfo[playerid][pMember] && PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[i][pMember]][g_iRadioAccess]) {
						ChatTrafficProcess(i, arrGroupData[PlayerInfo[i][pMember]][g_hRadioColour] * 256 + 255, string, 12);
					}
				}
			}
			//SendGroupMessage(GROUP_TYPE_LEA, COLOR_DBLUE, string);
			return 1;
		}
		else
		{
			ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | LOI ", "Khong co ho so nguoi do.", "Dong y", "Huy");
			return 1;
		}
	}
	if(dialogid == MDC_LICENSES && response)
	{
		if(!IsMDCPermitted(playerid)) return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, " Dang nhap loi. Ban khong co quyen dung MDC!");
		new giveplayerid;
		if(sscanf(inputtext, "u", giveplayerid))
		{
			ShowPlayerDialogEx(playerid, MDC_LICENSES, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | Giay phep", "Nhap ten hoac ID nguoi do.", "Nhap", "Huy");
			return 1;
		}
		if(IsPlayerConnected(giveplayerid))
		{
			if(giveplayerid != INVALID_PLAYER_ID)
			{
				new LicenseString[256], giveplayer[MAX_PLAYER_NAME];
				GetPlayerName(playerid, sendername, sizeof(sendername));
				GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
				format(string, sizeof(string), "   Ten: %s\n", giveplayer);
				strcat(LicenseString, string, sizeof(LicenseString));
				format(string, sizeof(string), "-Bang lai xe: %s%s.\n", !PlayerInfo[giveplayerid][pCarLic] ? ("Chua dat"):("Het han: "), !PlayerInfo[giveplayerid][pCarLic] ? (""):date(PlayerInfo[giveplayerid][pCarLic], 1));
				strcat(LicenseString, string, sizeof(LicenseString));
				format(string, sizeof(string), "-Bang lai bay: %s.\n", PlayerInfo[giveplayerid][pFlyLic] ? ("Da dat"):("Chua dat"));
				strcat(LicenseString, string, sizeof(LicenseString));
				format(string, sizeof(string), "-Bang lai thuyen: %s.\n", PlayerInfo[giveplayerid][pBoatLic] ? ("Da dat"):("Chua dat"));
				strcat(LicenseString, string, sizeof(LicenseString));
				format(string, sizeof(string), "-Giay phep sung: %s.\n", PlayerInfo[giveplayerid][pGunLic] > gettime() ? ("Hop le"):("Het han hoac chua co"));
				strcat(LicenseString, string, sizeof(LicenseString));
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_LIST, "MDC - Da dang nhap | Tien an", LicenseString, "Dong y", "Huy");
				format(string, sizeof(string), "* %s da kiem tra giay phep cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				foreach(new i: Player)
				{
					if(PlayerInfo[playerid][pToggledChats][12] == 0)
					{
						if(PlayerInfo[i][pMember] == PlayerInfo[playerid][pMember] && PlayerInfo[playerid][pRank] >= arrGroupData[PlayerInfo[i][pMember]][g_iRadioAccess]) {
							ChatTrafficProcess(i, arrGroupData[PlayerInfo[i][pMember]][g_hRadioColour] * 256 + 255, string, 12);
						}
					}
				}
				return 1;
			}
			else return ShowPlayerDialogEx(playerid, MDC_LICENSES, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | Loi!", "LOI: Ten hoac ID sai.\nNhap ten hoac ID nguoi do.", "Nhap", "Huy");
		}
		else return ShowPlayerDialogEx(playerid, MDC_LICENSES, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | Loi!", "LOI: Ten hoac ID sai.\nNhap ten hoac ID nguoi do.", "Nhap", "Huy");
	}
	if(dialogid == MDC_MESSAGE && response)
	{
		if(!IsMDCPermitted(playerid)) return SendClientMessageEx(playerid, COLOR_LIGHTBLUE, " Dang nhap loi. Ban khong co quyen dung MDC!");
		new giveplayerid;
		if(sscanf(inputtext, "u", giveplayerid))
		{
			return ShowPlayerDialogEx(playerid, MDC_MESSAGE, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | Loi!", "LOI: Nguoi nhan sai.\nNhap ten hoac ID nguoi nhan.", "Dong y", "Huy");
		}
		if (IsPlayerConnected(giveplayerid))
		{
			if(giveplayerid != INVALID_PLAYER_ID)
			{
				format(string, sizeof(string), " Nhap tin nhan gui %s ", GetPlayerNameEx(giveplayerid));
				ShowPlayerDialogEx(playerid, MDC_MESSAGE_2, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | Tin MDC", string, "Dong y", "Huy");
				SetPVarInt(playerid, "MDCMessageRecipient", giveplayerid);
			}
			else  return ShowPlayerDialogEx(playerid, MDC_MESSAGE, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | Loi!", "LOI: Nguoi nhan sai.\nNhap ten hoac ID nguoi nhan.", "Dong y", "Huy");
		}
		else return ShowPlayerDialogEx(playerid, MDC_MESSAGE, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | Loi!", "LOI: Nguoi nhan sai.\nNhap ten hoac ID nguoi nhan.", "Dong y", "Huy");
	}
	if(dialogid == MDC_SMS && response)
	{
		if(isnull(inputtext) || strval(inputtext) == 0)
		{
			return ShowPlayerDialogEx(playerid, MDC_SMS, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | Loi!", "LOI: So dien thoai sai\nNhap so dien thoai nguoi nhan", "Dong y", "Huy");
		}
		new phonenumb = strval(inputtext);
		format(string, sizeof(string), " Nhap tin nhan gui %d ", phonenumb);
		ShowPlayerDialogEx(playerid, MDC_SMS_2, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | Tin SMS", string, "Dong y", "Huy");
		SetPVarInt(playerid, "SMSMessageRecipient", phonenumb);
	}
	if(dialogid == MDC_MESSAGE_2 && response)
	{
		new giveplayerid = GetPVarInt(playerid, "MDCMessageRecipient");
		if(giveplayerid == INVALID_PLAYER_ID) return ShowPlayerDialogEx(playerid, MDC_MESSAGE, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | Loi!", "LOI: Nguoi nhan sai.\nNhap ten hoac ID nguoi nhan.", "Dong y", "Huy");
		if(giveplayerid == playerid)
		{
			ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | LOI ", "Khong the tu gui tin nhan!", "Dong y", "Huy");
			return 1;
		}
		if(ConnectedToPC[giveplayerid] == 1337 || IsPlayerInAnyVehicle(giveplayerid))
		{
			if(!IsMDCPermitted(giveplayerid))
			{
				return ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | LOI ", "Nguoi do chua dang nhap MDC.", "Dong y", "Huy");
			}
			if(!strlen(inputtext))
			{
				return ShowPlayerDialogEx(playerid, MDC_MESSAGE_2, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | Loi!", "LOI: Phai nhap tin nhan!\nNhap ten hoac ID nguoi nhan.", "Dong y", "Huy");
			}
			format(string, sizeof(string), "Tin MDC gui %s:\n%s", GetPlayerNameEx(giveplayerid), inputtext);
			ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Da gui! ", string, "Dong y", "Huy");
			if(ConnectedToPC[giveplayerid] == 1337)
			{
				format(string, sizeof(string), "Tin MDC tu %s:\n%s", GetPlayerNameEx(playerid), inputtext);
				ShowPlayerDialogEx(giveplayerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Tin moi!", string, "Dong y", "Huy");
				SendClientMessageEx(giveplayerid, COLOR_YELLOW, "Tin MDC tu %s: %s", GetPlayerNameEx(playerid), inputtext);
			}
			else
			{
				format(string, sizeof(string), "Tin MDC tu %s:\n%s", GetPlayerNameEx(playerid), inputtext);
				ShowPlayerDialogEx(giveplayerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Tin moi! ", string, "Dong y", "Huy");
			}
		}
		else
		{
			ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | LOI ", "Officer do chua dang nhap MDC.", "Dong y", "Huy");
			return 1;
		}
		return 1;
	}
	if(dialogid == MDC_SMS_2 && response)
	{
		new phonenumb = GetPVarInt(playerid, "SMSMessageRecipient");
		if(!strlen(inputtext))
		{
			return ShowPlayerDialogEx(playerid, MDC_SMS_2, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | Loi!", "LOI: Phai nhap tin nhan!\nNhap so dien thoai nguoi nhan", "Dong y", "Huy");
		}
		if(phonenumb == 555)
		{
			if(strcmp("yes", inputtext, true) == 0) {
				SendClientMessageEx(playerid, COLOR_WHITE, "Da gui tin nhan.");
				SendClientMessageEx(playerid, COLOR_YELLOW, "SMS: Toi khong hieu ban dang noi gi, Nguoi gui: MOLE (555)");
				//SendAudioToPlayer(playerid, 47, 100);
				RingTone[playerid] = 20;
				return 0;
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_YELLOW, "SMS: Chi can noi 'yes' la du, Nguoi gui: MOLE (555)");
				//SendAudioToPlayer(playerid, 47, 100);
				RingTone[playerid] = 20;
				//ChatLog(string);
				return 0;
			}
		}
		foreach(new i: Player)
		{
			if(PlayerInfo[i][pPnumber] == phonenumb && phonenumb != 0)
			{
				if(PhoneOnline[i] > 0)
				{
					SendClientMessageEx(playerid, COLOR_GREY, "Dien thoai nguoi do dang tat.");
					return 1;
				}
				format(string, sizeof(string), "SMS: %s, Gui: %s (SDT: %d)", inputtext, GetPlayerNameEx(playerid),PlayerInfo[playerid][pPnumber]);
				GetPlayerName(i, sendername, sizeof(sendername));
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Da gui! ", string, "Dong y", "Huy");
				SendClientMessageEx(i, COLOR_YELLOW, string);
				return 1;
			}
		}
		ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Gui that bai! ", "Gui tin that bai. Hay thu lai", "Dong y", "Huy");
	}
	if(dialogid == MDC_BOLO && response)
	{
		new x_nr = GetPVarInt(playerid, "BOLOISSUESLOT");
		if(x_nr == 1)
		{
			if(News[hTaken14] == 0)
			{
				GetPlayerName(playerid, sendername, sizeof(sendername));
				if(strlen(inputtext) < 9) { ShowPlayerDialogEx(playerid, MDC_BOLO, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | LOI", "LOI: Can 9+ ky tu\nNhap thong tin BOLO", "Nhap", "Huy"); return 1; }
				format(string, sizeof(string), "%s",inputtext); strmid(News[hAdd14], string, 0, strlen(string), 255);
				format(string, sizeof(string), "%s",sendername); strmid(News[hContact14], string, 0, strlen(string), 255);
				News[hTaken14] = 1;
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Thanh cong! ","* Da them thong tin BOLO vao MDC -BOLO\nChon BOLO sau khi dang nhap mdc de xem danh sach", "Dong y", "Quay lai");
				SendGroupMessage(GROUP_TYPE_LEA, COLOR_LIGHTBLUE, "** MDC: Da cap nhat thong tin BOLO.");
				return 1;
			}
			else
			{
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Loi! ", "O 1 da duoc dung!", "Dong y", "Quay lai");
				return 1;
			}
		}
		if(x_nr == 2)
		{
			if(News[hTaken15] == 0)
			{
				GetPlayerName(playerid, sendername, sizeof(sendername));
				if(strlen(inputtext) < 9) { ShowPlayerDialogEx(playerid, MDC_BOLO, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | LOI", "LOI: Can 9+ ky tu\nNhap thong tin BOLO", "Nhap", "Huy"); return 1; }
				format(string, sizeof(string), "%s",inputtext); strmid(News[hAdd15], string, 0, strlen(string), 255);
				format(string, sizeof(string), "%s",sendername); strmid(News[hContact15], string, 0, strlen(string), 255);
				News[hTaken15] = 1;
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Thanh cong! ","* Da them thong tin BOLO vao MDC -BOLO\nChon BOLO sau khi dang nhap mdc de xem danh sach", "Dong y", "Quay lai");
				SendGroupMessage(GROUP_TYPE_LEA, COLOR_LIGHTBLUE, "** MDC: Da cap nhat thong tin BOLO.");
				return 1;
			}
			else
			{
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Loi! ", "O 2 da duoc dung!", "Dong y", "Quay lai");
				return 1;
			}
		}
		if(x_nr == 3)
		{
			if(News[hTaken16] == 0)
			{
				GetPlayerName(playerid, sendername, sizeof(sendername));
				if(strlen(inputtext) < 9) { ShowPlayerDialogEx(playerid, MDC_BOLO, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | LOI", "LOI: Can 9+ ky tu\nNhap thong tin BOLO", "Nhap", "Huy"); return 1; }
				format(string, sizeof(string), "%s",inputtext); strmid(News[hAdd16], string, 0, strlen(string), 255);
				format(string, sizeof(string), "%s",sendername); strmid(News[hContact16], string, 0, strlen(string), 255);
				News[hTaken16] = 1;
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Thanh cong! ","* Da them thong tin BOLO vao MDC -BOLO\nChon BOLO sau khi dang nhap mdc de xem danh sach", "Dong y", "Quay lai");
				SendGroupMessage(GROUP_TYPE_LEA, COLOR_LIGHTBLUE, "** MDC: Da cap nhat thong tin BOLO.");
				return 1;
			}
			else
			{
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Loi! ", "O 3 da duoc dung!", "Dong y", "Quay lai");
				return 1;
			}
		}
		if(x_nr == 4)
		{
			if(News[hTaken17] == 0)
			{
				GetPlayerName(playerid, sendername, sizeof(sendername));
				if(strlen(inputtext) < 9) { ShowPlayerDialogEx(playerid, MDC_BOLO, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | LOI", "LOI: Can 9+ ky tu\nNhap thong tin BOLO", "Nhap", "Huy"); return 1; }
				format(string, sizeof(string), "%s",inputtext); strmid(News[hAdd17], string, 0, strlen(string), 255);
				format(string, sizeof(string), "%s",sendername); strmid(News[hContact17], string, 0, strlen(string), 255);
				News[hTaken17] = 1;
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Thanh cong! ","* Da them thong tin BOLO vao MDC -BOLO\nChon BOLO sau khi dang nhap mdc de xem danh sach", "Dong y", "Quay lai");
				SendGroupMessage(GROUP_TYPE_LEA, COLOR_LIGHTBLUE, "** MDC: Da cap nhat thong tin BOLO.");
				return 1;
			}
			else
			{
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Loi! ", "O 4 da duoc dung!", "Dong y", "Quay lai");
				return 1;
			}
		}
		if(x_nr == 5)
		{
			if(News[hTaken18] == 0)
			{
				GetPlayerName(playerid, sendername, sizeof(sendername));
				if(strlen(inputtext) < 9) { ShowPlayerDialogEx(playerid, MDC_BOLO, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | LOI", "LOI: Can 9+ ky tu\nNhap thong tin BOLO", "Nhap", "Huy"); return 1; }
				format(string, sizeof(string), "%s",inputtext); strmid(News[hAdd18], string, 0, strlen(string), 255);
				format(string, sizeof(string), "%s",sendername); strmid(News[hContact18], string, 0, strlen(string), 255);
				News[hTaken18] = 1;
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Thanh cong! ","* Da them thong tin BOLO vao MDC -BOLO\nChon BOLO sau khi dang nhap mdc de xem danh sach", "Dong y", "Quay lai");
				SendGroupMessage(GROUP_TYPE_LEA, COLOR_LIGHTBLUE, "** MDC: Da cap nhat thong tin BOLO.");
				return 1;
			}
			else
			{
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Loi! ", "O 5 da duoc dung!", "Dong y", "Quay lai");
				return 1;
			}
		}
		if(x_nr == 6)
		{
			if(News[hTaken19] == 0)
			{
				GetPlayerName(playerid, sendername, sizeof(sendername));
				if(strlen(inputtext) < 9) { ShowPlayerDialogEx(playerid, MDC_BOLO, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | LOI", "LOI: Can 9+ ky tu\nNhap thong tin BOLO", "Nhap", "Huy"); return 1; }
				format(string, sizeof(string), "%s",inputtext); strmid(News[hAdd19], string, 0, strlen(string), 255);
				format(string, sizeof(string), "%s",sendername); strmid(News[hContact19], string, 0, strlen(string), 255);
				News[hTaken19] = 1;
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Thanh cong! ","* Da them thong tin BOLO vao MDC -BOLO\nChon BOLO sau khi dang nhap mdc de xem danh sach", "Dong y", "Quay lai");
				SendGroupMessage(GROUP_TYPE_LEA, COLOR_LIGHTBLUE, "** MDC: Da cap nhat thong tin BOLO.");
				return 1;
			}
			else
			{
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Loi! ", "O 6 da duoc dung!", "Dong y", "Quay lai");
				return 1;
			}
		}
		if(x_nr == 7)
		{
			if(News[hTaken20] == 0)
			{
				GetPlayerName(playerid, sendername, sizeof(sendername));
				if(strlen(inputtext) < 9) { ShowPlayerDialogEx(playerid, MDC_BOLO, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | LOI", "LOI: Can 9+ ky tu\nNhap thong tin BOLO", "Nhap", "Huy"); return 1; }
				format(string, sizeof(string), "%s",inputtext); strmid(News[hAdd20], string, 0, strlen(string), 255);
				format(string, sizeof(string), "%s",sendername); strmid(News[hContact20], string, 0, strlen(string), 255);
				News[hTaken20] = 1;
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Thanh cong! ","* Da them thong tin BOLO vao MDC -BOLO\nChon BOLO sau khi dang nhap mdc de xem danh sach", "Dong y", "Quay lai");
				SendGroupMessage(GROUP_TYPE_LEA, COLOR_LIGHTBLUE, "** MDC: Da cap nhat thong tin BOLO.");
				return 1;
			}
			else
			{
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Loi! ", "O 7 da duoc dung!", "Dong y", "Quay lai");
				return 1;
			}
		}
		if(x_nr == 8)
		{
			if(News[hTaken21] == 0)
			{
				GetPlayerName(playerid, sendername, sizeof(sendername));
				if(strlen(inputtext) < 9) { ShowPlayerDialogEx(playerid, MDC_BOLO, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | LOI", "LOI: Can 9+ ky tu\nNhap thong tin BOLO", "Nhap", "Huy"); return 1; }
				format(string, sizeof(string), "%s",inputtext); strmid(News[hAdd21], string, 0, strlen(string), 255);
				format(string, sizeof(string), "%s",sendername); strmid(News[hContact21], string, 0, strlen(string), 255);
				News[hTaken21] = 1;
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Thanh cong! ","* Da them thong tin BOLO vao MDC -BOLO\nChon BOLO sau khi dang nhap mdc de xem danh sach", "Dong y", "Quay lai");
				SendGroupMessage(GROUP_TYPE_LEA, COLOR_LIGHTBLUE, "** MDC: Da cap nhat thong tin BOLO.");
				return 1;
			}
			else
			{
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Loi! ", "O 8 da duoc dung!", "Dong y", "Quay lai");
				return 1;
			}
		}
	}
	if(dialogid == MDC_BOLO_SLOT && response)
	{
		SetPVarInt(playerid, "BOLOISSUESLOT", listitem + 1);
		ShowPlayerDialogEx(playerid, MDC_BOLO, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | Lap truy na", "Nhap thong tin BOLO", "Nhap", "Huy");
	}
	if(dialogid == MDC_ISSUE_SLOT && response)
	{
		SetPVarInt(playerid, "ISSUESLOT", listitem + 1);
		ShowPlayerDialogEx(playerid, MDC_ISSUE, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | Lap truy na", "Nhap thong tin lenh bat giu", "Nhap", "Huy");
	}
	if(dialogid == MDC_END_ID && response)
	{
		ShowPlayerDialogEx(playerid, MDC_MAIN, DIALOG_STYLE_LIST, "MDC - Da dang nhap", "*Thong tin cong dan\n*Truy na nghi pham\n*Xoa truy na\n*Dang ky xe\n*Tim LEO\n*Co quan hanh phap\n*Tin nhan MDC\n*SMS", "Dong y", "Huy");
	}
	if(dialogid == MDC_ISSUE && response)
	{
		new x_nr = GetPVarInt(playerid, "ISSUESLOT");
		if(x_nr == 1)
		{
			if(News[hTaken6] == 0)
			{
				GetPlayerName(playerid, sendername, sizeof(sendername));
				if(strlen(inputtext) < 9) { ShowPlayerDialogEx(playerid, MDC_ISSUE, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | LOI", "LOI: Can 9+ ky tu\nNhap thong tin lenh bat giu", "Nhap", "Huy"); return 1; }
				format(string, sizeof(string), "%s",inputtext); strmid(News[hAdd6], string, 0, strlen(string), 255);
				format(string, sizeof(string), "%s",sendername); strmid(News[hContact6], string, 0, strlen(string), 255);
				News[hTaken6] = 1;
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Thanh cong! ","* Da them thong tin lenh bat giu vao MDC -Warrants\nChon lenh truy na sau khi dang nhap mdc de xem danh sach", "Dong y", "Quay lai");
				SendGroupMessage(GROUP_TYPE_LEA, COLOR_LIGHTBLUE, "** MDC: Da cap nhat thong tin lenh bat giu.");
				return 1;
			}
			else
			{
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Loi! ", "O 1 da duoc dung!", "Dong y", "Quay lai");
				return 1;
			}
		}
		if(x_nr == 2)
		{
			if(News[hTaken7] == 0)
			{
				GetPlayerName(playerid, sendername, sizeof(sendername));
				if(strlen(inputtext) < 9) { ShowPlayerDialogEx(playerid, MDC_ISSUE, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | LOI", "LOI: Can 9+ ky tu\nNhap thong tin lenh bat giu", "Nhap", "Huy"); return 1; }
				format(string, sizeof(string), "%s",inputtext); strmid(News[hAdd7], string, 0, strlen(string), 255);
				format(string, sizeof(string), "%s",sendername); strmid(News[hContact7], string, 0, strlen(string), 255);
				News[hTaken7] = 1;
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Thanh cong! ","* Da them thong tin lenh bat giu vao MDC -Warrants\nChon lenh truy na sau khi dang nhap mdc de xem danh sach", "Dong y", "Quay lai");
				SendGroupMessage(GROUP_TYPE_LEA, COLOR_LIGHTBLUE, "** MDC: Da cap nhat thong tin lenh bat giu.");
				return 1;
			}
			else
			{
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Loi! ", "O 2 da duoc dung!", "Dong y", "Quay lai");
				return 1;
			}
		}
		if(x_nr == 3)
		{
			if(News[hTaken8] == 0)
			{
				GetPlayerName(playerid, sendername, sizeof(sendername));
				if(strlen(inputtext) < 9) { ShowPlayerDialogEx(playerid, MDC_ISSUE, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | LOI", "LOI: Can 9+ ky tu\nNhap thong tin lenh bat giu", "Nhap", "Huy"); return 1; }
				format(string, sizeof(string), "%s",inputtext); strmid(News[hAdd8], string, 0, strlen(string), 255);
				format(string, sizeof(string), "%s",sendername); strmid(News[hContact8], string, 0, strlen(string), 255);
				News[hTaken8] = 1;
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Thanh cong! ","* Da them thong tin lenh bat giu vao MDC -Warrants\nChon lenh truy na sau khi dang nhap mdc de xem danh sach", "Dong y", "Quay lai");
				SendGroupMessage(GROUP_TYPE_LEA, COLOR_LIGHTBLUE, "** MDC: Da cap nhat thong tin lenh bat giu.");
				return 1;
			}
			else
			{
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Loi! ", "O 3 da duoc dung!", "Dong y", "Quay lai");
				return 1;
			}
		}
		if(x_nr == 4)
		{
			if(News[hTaken9] == 0)
			{
				GetPlayerName(playerid, sendername, sizeof(sendername));
				if(strlen(inputtext) < 9) { ShowPlayerDialogEx(playerid, MDC_ISSUE, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | LOI", "LOI: Can 9+ ky tu\nNhap thong tin lenh bat giu", "Nhap", "Huy"); return 1; }
				format(string, sizeof(string), "%s",inputtext); strmid(News[hAdd9], string, 0, strlen(string), 255);
				format(string, sizeof(string), "%s",sendername); strmid(News[hContact9], string, 0, strlen(string), 255);
				News[hTaken9] = 1;
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Thanh cong! ","* Da them thong tin lenh bat giu vao MDC -Warrants\nChon lenh truy na sau khi dang nhap mdc de xem danh sach", "Dong y", "Quay lai");
				SendGroupMessage(GROUP_TYPE_LEA, COLOR_LIGHTBLUE, "** MDC: Da cap nhat thong tin lenh bat giu.");
				return 1;
			}
			else
			{
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Loi! ", "O 4 da duoc dung!", "Dong y", "Quay lai");
				return 1;
			}
		}
		if(x_nr == 5)
		{
			if(News[hTaken10] == 0)
			{
				GetPlayerName(playerid, sendername, sizeof(sendername));
				if(strlen(inputtext) < 9) { ShowPlayerDialogEx(playerid, MDC_ISSUE, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | LOI", "LOI: Can 9+ ky tu\nNhap thong tin lenh bat giu", "Nhap", "Huy"); return 1; }
				format(string, sizeof(string), "%s",inputtext); strmid(News[hAdd10], string, 0, strlen(string), 255);
				format(string, sizeof(string), "%s",sendername); strmid(News[hContact10], string, 0, strlen(string), 255);
				News[hTaken10] = 1;
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Thanh cong! ","* Da them thong tin lenh bat giu vao MDC -Warrants\nChon lenh truy na sau khi dang nhap mdc de xem danh sach", "Dong y", "Quay lai");
				SendGroupMessage(GROUP_TYPE_LEA, COLOR_LIGHTBLUE, "** MDC: Da cap nhat thong tin lenh bat giu.");
				return 1;
			}
			else
			{
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Loi! ", "O 5 da duoc dung!", "Dong y", "Quay lai");
				return 1;
			}
		}
		if(x_nr == 6)
		{
			if(News[hTaken11] == 0)
			{
				GetPlayerName(playerid, sendername, sizeof(sendername));
				if(strlen(inputtext) < 9) { ShowPlayerDialogEx(playerid, MDC_ISSUE, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | LOI", "LOI: Can 9+ ky tu\nNhap thong tin lenh bat giu", "Nhap", "Huy"); return 1; }
				format(string, sizeof(string), "%s",inputtext); strmid(News[hAdd11], string, 0, strlen(string), 255);
				format(string, sizeof(string), "%s",sendername); strmid(News[hContact11], string, 0, strlen(string), 255);
				News[hTaken11] = 1;
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Thanh cong! ","* Da them thong tin lenh bat giu vao MDC -Warrants\nChon lenh truy na sau khi dang nhap mdc de xem danh sach", "Dong y", "Quay lai");
				SendGroupMessage(GROUP_TYPE_LEA, COLOR_LIGHTBLUE, "** MDC: Da cap nhat thong tin lenh bat giu.");
				return 1;
			}
			else
			{
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Loi! ", "O 6 da duoc dung!", "Dong y", "Quay lai");
				return 1;
			}
		}
		if(x_nr == 7)
		{
			if(News[hTaken12] == 0)
			{
				GetPlayerName(playerid, sendername, sizeof(sendername));
				if(strlen(inputtext) < 9) { ShowPlayerDialogEx(playerid, MDC_ISSUE, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | LOI", "LOI: Can 9+ ky tu\nNhap thong tin lenh bat giu", "Nhap", "Huy"); return 1; }
				format(string, sizeof(string), "%s",inputtext); strmid(News[hAdd12], string, 0, strlen(string), 255);
				format(string, sizeof(string), "%s",sendername); strmid(News[hContact12], string, 0, strlen(string), 255);
				News[hTaken12] = 1;
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Thanh cong! ","* Da them thong tin lenh bat giu vao MDC -Warrants\nChon lenh truy na sau khi dang nhap mdc de xem danh sach", "Dong y", "Quay lai");
				SendGroupMessage(GROUP_TYPE_LEA, COLOR_LIGHTBLUE, "** MDC: Da cap nhat thong tin lenh bat giu.");
				return 1;
			}
			else
			{
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Loi! ", "O 7 da duoc dung!", "Dong y", "Quay lai");
				return 1;
			}
		}
		if(x_nr == 8)
		{
			if(News[hTaken13] == 0)
			{
				GetPlayerName(playerid, sendername, sizeof(sendername));
				if(strlen(inputtext) < 9) { ShowPlayerDialogEx(playerid, MDC_ISSUE, DIALOG_STYLE_INPUT, "MDC - Da dang nhap | LOI", "LOI: Can 9+ ky tu\nNhap thong tin lenh bat giu", "Nhap", "Huy"); return 1; }
				format(string, sizeof(string), "%s",inputtext); strmid(News[hAdd13], string, 0, strlen(string), 255);
				format(string, sizeof(string), "%s",sendername); strmid(News[hContact13], string, 0, strlen(string), 255);
				News[hTaken13] = 1;
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Thanh cong! ","* Da them thong tin lenh bat giu vao MDC -Warrants\nChon lenh truy na sau khi dang nhap mdc de xem danh sach", "Dong y", "Quay lai");
				SendGroupMessage(GROUP_TYPE_LEA, COLOR_LIGHTBLUE, "** MDC: Da cap nhat thong tin lenh bat giu.");
				return 1;
			}
			else
			{
				ShowPlayerDialogEx(playerid, MDC_END_ID, DIALOG_STYLE_MSGBOX, "MDC - Da dang nhap | Loi! ", "O 8 da duoc dung!", "Dong y", "Quay lai");
				return 1;
			}
		}
	}
	if(dialogid == MDC_DELETE && response)
	{
		if(listitem == 0)
		{
			ShowPlayerDialogEx(playerid, MDC_DEL_BOLO, DIALOG_STYLE_LIST, "MDC - Da dang nhap | Chon o BOLO can xoa", "1\n2\n3\n4\n5\n6\n7\n8\nALL", "Chon", "Huy");
		}
		if(listitem == 1)
		{
			ShowPlayerDialogEx(playerid, MDC_DEL_WARRANT, DIALOG_STYLE_LIST, "MDC - Da dang nhap | Chon o truy na can xoa", "1\n2\n3\n4\n5\n6\n7\n8\nALL", "Chon", "Huy");
		}
	}
	if(dialogid == MDC_DEL_BOLO && response)
	{
		new string1[MAX_PLAYER_NAME];
		if(isnull(inputtext))
		{
			ShowPlayerDialogEx(playerid, MDC_DEL_WARRANT, DIALOG_STYLE_LIST, "MDC - Da dang nhap | Chon o truy na can xoa", "1\n2\n3\n4\n5\n6\n7\n8\nALL", "Chon", "Huy");
			return 1;
		}
		if(strcmp(inputtext, "1") == 0)
		{
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd14], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact14], string1, 0, strlen(string1), 255);
			News[hTaken14] = 0;
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da xoa thong tin BOLO (1) tren MDC -BOLO.");
			return 1;
		}
		else if(strcmp(inputtext, "2") == 0)
		{
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd15], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact15], string1, 0, strlen(string1), 255);
			News[hTaken15] = 0;
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da xoa thong tin BOLO (2) tren MDC -BOLO.");
			return 1;
		}
		else if(strcmp(inputtext, "3") == 0)
		{
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd16], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact16], string1, 0, strlen(string1), 255);
			News[hTaken16] = 0;
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da xoa thong tin BOLO (3) tren MDC -BOLO.");
			return 1;
		}
		else if(strcmp(inputtext, "4") == 0)
		{
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd17], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact17], string1, 0, strlen(string1), 255);
			News[hTaken17] = 0;
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da xoa thong tin BOLO (4) tren MDC -BOLO.");
			return 1;
		}
		else if(strcmp(inputtext, "5") == 0)
		{
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd18], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact18], string1, 0, strlen(string1), 255);
			News[hTaken18] = 0;
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da xoa thong tin BOLO (5) tren MDC -BOLO.");
			return 1;
		}
		else if(strcmp(inputtext, "6") == 0)
		{
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd19], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact19], string1, 0, strlen(string1), 255);
			News[hTaken19] = 0;
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da xoa thong tin BOLO (6) tren MDC -BOLO.");
			return 1;
		}
		else if(strcmp(inputtext, "7") == 0)
		{
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd20], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact20], string1, 0, strlen(string1), 255);
			News[hTaken20] = 0;
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da xoa thong tin BOLO (7) tren MDC -BOLO.");
			return 1;
		}
		else if(strcmp(inputtext, "8") == 0)
		{
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd21], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact21], string1, 0, strlen(string1), 255);
			News[hTaken21] = 0;
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da xoa thong tin BOLO (8) tren MDC -BOLO.");
			return 1;
		}
		else if(strcmp(inputtext,"all",true) == 0)
		{
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd14], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact14], string1, 0, strlen(string1), 255);
			News[hTaken14] = 0;
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd15], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact15], string1, 0, strlen(string1), 255);
			News[hTaken15] = 0;
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd16], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact16], string1, 0, strlen(string1), 255);
			News[hTaken16] = 0;
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd17], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact17], string1, 0, strlen(string1), 255);
			News[hTaken17] = 0;
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd18], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact18], string1, 0, strlen(string1), 255);
			News[hTaken18] = 0;
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd19], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact19], string1, 0, strlen(string1), 255);
			News[hTaken19] = 0;
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd20], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact20], string1, 0, strlen(string1), 255);
			News[hTaken20] = 0;
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd21], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact21], string1, 0, strlen(string1), 255);
			News[hTaken21] = 0;
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da xoa toan bo thong tin BOLO tren MDC -BOLO.");
			return 1;
		}
	}
	if(dialogid == MDC_DEL_WARRANT && response)
	{
		new string1[MAX_PLAYER_NAME];
		if(isnull(inputtext))
		{
			ShowPlayerDialogEx(playerid, MDC_DEL_WARRANT, DIALOG_STYLE_LIST, "MDC - Da dang nhap | Chon o truy na can xoa", "1\n2\n3\n4\n5\n6\n7\n8\nALL", "Chon", "Huy");
			return 1;
		}
		if(strcmp(inputtext,"1",true) == 0)
		{
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd6], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact6], string1, 0, strlen(string1), 255);
			News[hTaken6] = 0;
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da xoa lenh bat giu (1) tren MDC -Warrants.");
			return 1;
		}
		else if(strcmp(inputtext,"2",true) == 0)
		{
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd7], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact7], string1, 0, strlen(string1), 255);
			News[hTaken7] = 0;
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da xoa lenh bat giu (2) tren MDC -Warrants.");
			return 1;
		}
		else if(strcmp(inputtext,"3",true) == 0)
		{
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd8], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact8], string1, 0, strlen(string1), 255);
			News[hTaken8] = 0;
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da xoa lenh bat giu (3) tren MDC -Warrants.");
			return 1;
		}
		else if(strcmp(inputtext,"4",true) == 0)
		{
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd9], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact9], string1, 0, strlen(string1), 255);
			News[hTaken9] = 0;
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da xoa lenh bat giu (4) tren MDC -Warrants.");
			return 1;
		}
		else if(strcmp(inputtext,"5",true) == 0)
		{
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd10], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact10], string1, 0, strlen(string1), 255);
			News[hTaken10] = 0;
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da xoa lenh bat giu (5) tren MDC -Warrants.");
			return 1;
		}
		else if(strcmp(inputtext,"6",true) == 0)
		{
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd11], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact11], string1, 0, strlen(string1), 255);
			News[hTaken11] = 0;
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da xoa lenh bat giu (6) tren MDC -Warrants.");
			return 1;
		}
		else if(strcmp(inputtext,"7",true) == 0)
		{
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd12], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact12], string1, 0, strlen(string1), 255);
			News[hTaken12] = 0;
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da xoa lenh bat giu (7) tren MDC -Warrants.");
			return 1;
		}
		else if(strcmp(inputtext,"8",true) == 0)
		{
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd13], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact13], string1, 0, strlen(string1), 255);
			News[hTaken13] = 0;
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da xoa lenh bat giu (8) tren MDC -Warrants.");
			return 1;
		}
		else if(strcmp(inputtext,"all",true) == 0)
		{
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd6], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact6], string1, 0, strlen(string1), 255);
			News[hTaken6] = 0;
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd7], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact7], string1, 0, strlen(string1), 255);
			News[hTaken7] = 0;
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd8], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact8], string1, 0, strlen(string1), 255);
			News[hTaken8] = 0;
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd9], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact9], string1, 0, strlen(string1), 255);
			News[hTaken9] = 0;
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd10], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact10], string1, 0, strlen(string1), 255);
			News[hTaken10] = 0;
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd11], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact11], string1, 0, strlen(string1), 255);
			News[hTaken11] = 0;
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd12], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact12], string1, 0, strlen(string1), 255);
			News[hTaken12] = 0;
			format(string, sizeof(string), "Nothing"); strmid(News[hAdd13], string, 0, strlen(string), 255);
			format(string1, sizeof(string1), "No-one");	strmid(News[hContact13], string1, 0, strlen(string1), 255);
			News[hTaken13] = 0;
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da xoa toan bo lenh bat giu tren MDC -Warrants.");
			return 1;
		}
	}
	if(dialogid == MDC_LOGOUT && response)
	{
	}
	if(dialogid == MDC_CREATE && response)
	{
	}
	if( (dialogid >= MDC_START_ID && dialogid <= MDC_END_ID) && !response)
	{
		if(dialogid == MDC_MAIN)
		{
			ConnectedToPC[playerid] = 0;
		}
		else
		{
			ShowPlayerDialogEx(playerid, MDC_MAIN, DIALOG_STYLE_LIST, "MDC - Da dang nhap", "*Thong tin cong dan\n*Truy na nghi pham\n*Xoa truy na\n*Dang ky xe\n*Tim LEO\n*Co quan hanh phap\n*Tin nhan MDC\n*SMS", "Dong y", "Huy");
		}
	}
	if((dialogid == SELLVIP))
	{
		new
			iTargetID = GetPVarInt(playerid, "VIPSell"),
			iPrice = GetPVarInt(playerid, "VIPCost"),
			logstring[156];

		if(response)
		{

			if(!IsPlayerConnected(iTargetID)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi kia da ngat ket noi.");
			new iTargetName[MAX_PLAYER_NAME];
			GetPVarString(playerid, "VIPSeller", iTargetName, sizeof(iTargetName));
			if(strcmp(iTargetName, GetPlayerNameEx(iTargetID)) != 0) {
				return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi kia da ngat ket noi.");
			}
			new	viptype[7];
			if(GetPlayerCash(playerid) >= iPrice)
			{
				if(PlayerInfo[iTargetID][pDonateRank] == 3)
				{
					PlayerInfo[iTargetID][pGVip] = 0;
					PlayerInfo[playerid][pGVip] = 1;
				}
				//Player buying the VIP
				GivePlayerCash(playerid, -GetPVarInt(playerid, "VIPCost"));
				PlayerInfo[playerid][pDonateRank] = PlayerInfo[iTargetID][pDonateRank];
				PlayerInfo[playerid][pVIPExpire] = PlayerInfo[iTargetID][pVIPExpire];
				PlayerInfo[playerid][pTempVIP] = 0;
				PlayerInfo[playerid][pBuddyInvited] = 0;
				PlayerInfo[playerid][pVIPSellable] = 0;

				LoadPlayerDisabledVehicles(iTargetID);

				if(PlayerInfo[playerid][pVIPM] != 0)
				{
					PlayerInfo[playerid][pVIPMO] = PlayerInfo[playerid][pVIPM];
				}
				PlayerInfo[playerid][pVIPM] = PlayerInfo[iTargetID][pVIPM];

				// person selling the vip
				GivePlayerCash(iTargetID, GetPVarInt(playerid, "VIPCost"));
				PlayerInfo[iTargetID][pDonateRank] = 0;
				PlayerInfo[iTargetID][pVIPExpire] = 0;
				PlayerInfo[iTargetID][pVIPMO] = PlayerInfo[iTargetID][pVIPM];
				PlayerInfo[iTargetID][pVIPM] = 0;
				switch(PlayerInfo[playerid][pDonateRank])
				{
					case 1: viptype = "Bronze";
					case 2: viptype = "Silver";
					case 3: viptype = "Gold";
					default: viptype = "Loi";
				}
				format(string, sizeof(string), "Da mua %s VIP tu %s gia $%d, het han ngay %s.", viptype, GetPlayerNameEx(iTargetID), iPrice, date(PlayerInfo[playerid][pVIPExpire], 2));
				SendClientMessage(playerid, COLOR_WHITE, string);
				format(string, sizeof(string), "Ban da ban %s VIP cho %s gia $%d.", viptype, GetPlayerNameEx(playerid), iPrice);
				SendClientMessage(iTargetID, COLOR_WHITE, string);
				new iYear, iMonth, iDay, szIP[16], szIP2[16];
				getdate(iYear, iMonth, iDay);
				GetPlayerIp(iTargetID, szIP, sizeof(szIP));
				GetPlayerIp(playerid, szIP2, sizeof(szIP2));
				format(logstring, sizeof(logstring), "[SELLVIP] %s(%d) (IP:%s) has sold %s VIP to %s(%d) (IP:%s) for $%d. (VIPM: %d) - (%d/%d/%d)", GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID), szIP, viptype, GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), szIP2, iPrice, PlayerInfo[playerid][pVIPM], iMonth,iDay,iYear);
				Log("logs/shoplog.log", logstring);

				PlayerInfo[playerid][pVIPSold] = gettime() + 7200;
				PlayerInfo[iTargetID][pVIPSold] = gettime() + 7200;
			}
			else
			{
				SendClientMessage(playerid, COLOR_GREY, "Ban khong du tien mat de mua!");
				SendClientMessage(iTargetID, COLOR_GREY, "Nguoi do khong du tien mat de mua!");
			}
			DeletePVar(playerid, "VIPSell");
			DeletePVar(playerid, "VIPCost");
		}
		else
		{
			format(string, sizeof(string), "Ban da tu choi mua VIP tu %s.", GetPlayerNameEx(iTargetID));
			SendClientMessage(playerid, COLOR_WHITE, string);
			format(string, sizeof(string), "%s da tu choi mua VIP.", GetPlayerNameEx(playerid));
			SendClientMessage(iTargetID, COLOR_WHITE, string);
			DeletePVar(playerid, "VIPSell");
			DeletePVar(playerid, "VIPCost");
		}
		return 1;
	}
	if((dialogid == DRINKDIALOG))
	{
		if(!Offer_IsCurrent(playerid, DrinkOffer[playerid], "DrinkOfferSession") || !Job_HasJob(DrinkOffer[playerid], JOB_BARTENDER))
		{
			DrinkOffer[playerid] = INVALID_PLAYER_ID;
			return SendClientMessageEx(playerid, COLOR_GREY, "Dich vu Bartender khong con kha dung.");
		}
		if(response)
		{
			ShowPlayerDialogEx(playerid, TIPDIALOG, DIALOG_STYLE_INPUT, "Tip cho Bartender", "Ban muon tip bao nhieu cho dich vu cua Bartender?", "Dong y", "Huy");
		}
		else
		{
			DrinkOffer[playerid] = INVALID_PLAYER_ID;
		}
	}
	if((dialogid == TIPDIALOG))
	{
		if(!Offer_IsCurrent(playerid, DrinkOffer[playerid], "DrinkOfferSession") || !Job_HasJob(DrinkOffer[playerid], JOB_BARTENDER))
		{
			DrinkOffer[playerid] = INVALID_PLAYER_ID;
			return SendClientMessageEx(playerid, COLOR_GREY, "Dich vu Bartender khong con kha dung.");
		}
		if(response)
		{
			if(GetPlayerCash(playerid) >= strval(inputtext))
			{
				if(strval(inputtext) < 0 || strval(inputtext) > 10000)
				{
					return ShowPlayerDialogEx(playerid, TIPDIALOG, DIALOG_STYLE_INPUT, "Tip cho Bartender", "Phai tren $0 hoac duoi $10,000.\nBan muon tip bao nhieu cho dich vu cua Bartender?", "Dong y", "Huy");
				}
				format(string, sizeof(string), "** %s dua tien tip cho dich vu cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(DrinkOffer[playerid]));
				ProxDetector(15.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				format(string, sizeof(string), "* %s da tip ban $%d cho dich vu.", GetPlayerNameEx(playerid), strval(inputtext));
				SendClientMessageEx(DrinkOffer[playerid], COLOR_LIGHTBLUE, string);
				GivePlayerCash(DrinkOffer[playerid], strval(inputtext));
				GivePlayerCash(playerid, -strval(inputtext));

				new ip[32], ipex[32];
				GetPlayerIp(playerid, ip, sizeof(ip));
				GetPlayerIp(DrinkOffer[playerid], ipex, sizeof(ipex));

				if(strval(inputtext) >= 25000 && (PlayerInfo[DrinkOffer[playerid]][pLevel] <= 3 || PlayerInfo[playerid][pLevel] <= 3 ))
				{
					format(string, sizeof(string), "%s(%d) (IP:%s) has tipped %s(%d) (IP:%s) $%s in this session.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), ip, GetPlayerNameEx(DrinkOffer[playerid]), GetPlayerSQLId(DrinkOffer[playerid]), ipex, number_format(strval(inputtext)));
					Log("logs/pay.log", string);
					format(string, sizeof(string), "%s (IP:%s) has tipped %s (IP:%s) $%s in this session.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(DrinkOffer[playerid]), ipex, number_format(strval(inputtext)));
					ABroadCast(COLOR_YELLOW, string, 2);
				}

				DrinkOffer[playerid] = INVALID_PLAYER_ID;
			}
		}
		else
		{
			DrinkOffer[playerid] = INVALID_PLAYER_ID;
		}
	}
	else if(dialogid == INTERACTMAIN)
	{
		if(response)
		{
			new name[MAX_PLAYER_NAME+8];
			GetPVarString(playerid, "pInteractName", name, sizeof(name));
			if(listitem == 0)
			{
				ShowPlayerDialogEx(playerid, INTERACTPAY, DIALOG_STYLE_INPUT, name, "Nhap so tien can tra", "Tra", "Huy");
			}
			else if(listitem == 1)
			{
				ShowPlayerDialogEx(playerid, INTERACTGIVE, DIALOG_STYLE_LIST, name, "Cannabis\nCrack\nMaterials\nFirework\nHeroin\nRawOpium\nSyringes\nOpiumSeeds\nSprunk", "Chon", "Huy");
			}
		}
		else
		{
			DeletePVar(playerid, "pInteractName");
			DeletePVar(playerid, "pInteractID");
		}
	}
	else if(dialogid == INTERACTPAY)
	{
		if(response)
		{
			new params[24];
			format(params, sizeof(params), "%d %d", GetPVarInt(playerid, "pInteractID"), strval(inputtext));
			DeletePVar(playerid, "pInteractName");
			DeletePVar(playerid, "pInteractID");
			return pc_cmd_pay(playerid, params);
		}
		else
		{
			DeletePVar(playerid, "pInteractName");
			DeletePVar(playerid, "pInteractID");
		}
	}
	else if(dialogid == INTERACTGIVE)
	{
		if(response)
		{
			new name[MAX_PLAYER_NAME+8];
			SetPVarInt(playerid, "pInteractGiveType", listitem);
			GetPVarString(playerid, "pInteractName", name, sizeof(name));
			ShowPlayerDialogEx(playerid, INTERACTGIVE2, DIALOG_STYLE_INPUT, name, "Nhap so luong muon cho", "Cho", "Huy");
		}
		else
		{
			DeletePVar(playerid, "pInteractName");
			DeletePVar(playerid, "pInteractID");
		}
	}
	/*else if(dialogid == INTERACTGIVE2)
	{
		if(response)
		{
			new params[24];
			switch(GetPVarInt(playerid, "pInteractGiveType"))
			{
				case 0: format(params, sizeof(params), "%d pot %d", GetPVarInt(playerid, "pInteractID"), strval(inputtext));
				case 1: format(params, sizeof(params), "%d crack %d", GetPVarInt(playerid, "pInteractID"), strval(inputtext));
				case 2: format(params, sizeof(params), "%d materials %d", GetPVarInt(playerid, "pInteractID"), strval(inputtext));
				case 3: format(params, sizeof(params), "%d firework %d", GetPVarInt(playerid, "pInteractID"), strval(inputtext));
				case 4: format(params, sizeof(params), "%d heroin %d", GetPVarInt(playerid, "pInteractID"), strval(inputtext));
				case 5: format(params, sizeof(params), "%d rawopium %d", GetPVarInt(playerid, "pInteractID"), strval(inputtext));
				case 6: format(params, sizeof(params), "%d syringes %d", GetPVarInt(playerid, "pInteractID"), strval(inputtext));
				case 7: format(params, sizeof(params), "%d opiumseeds %d", GetPVarInt(playerid, "pInteractID"), strval(inputtext));
				case 8: format(params, sizeof(params), "%d sprunk %d", GetPVarInt(playerid, "pInteractID"), strval(inputtext));
				case 9: format(params, sizeof(params), "%d ammo1 %d", GetPVarInt(playerid, "pInteractID"), strval(inputtext));
				case 10: format(params, sizeof(params), "%d ammo2 %d", GetPVarInt(playerid, "pInteractID"), strval(inputtext));
				case 11: format(params, sizeof(params), "%d ammo3 %d", GetPVarInt(playerid, "pInteractID"), strval(inputtext));
				case 12: format(params, sizeof(params), "%d ammo4 %d", GetPVarInt(playerid, "pInteractID"), strval(inputtext));
				case 13: format(params, sizeof(params), "%d ammo5 %d", GetPVarInt(playerid, "pInteractID"), strval(inputtext));
			}
			DeletePVar(playerid, "pInteractName");
			DeletePVar(playerid, "pInteractID");
			DeletePVar(playerid, "pInteractGive");
			return pc_cmd_give(playerid, params);
		}
		else
		{
			DeletePVar(playerid, "pInteractName");
			DeletePVar(playerid, "pInteractID");
			DeletePVar(playerid, "pInteractGive");
		}
	}*/
	else if(dialogid == DMRCONFIRM)
	{
		if(response)
		{
			new giveplayerid = GetPVarInt(playerid, "pDMReport");
			SetPVarInt(playerid, "_rAutoM", 5);
			SetPVarInt(playerid, "_rRepID", giveplayerid);			format(string, sizeof(string), "Ban da bao cao %s.", GetPlayerNameEx(giveplayerid));
			SendClientMessage(playerid, COLOR_WHITE, string);

			if(PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[playerid][pSMod] == 1) mysql_format(MainPipeline, string, sizeof(string), "INSERT INTO dm_watchdog (id,reporter,timestamp,superwatch) VALUES (%d,%d,%d,1)", GetPlayerSQLId(giveplayerid), GetPlayerSQLId(playerid), gettime());
			else mysql_format(MainPipeline, string, sizeof(string), "INSERT INTO dm_watchdog (id,reporter,timestamp) VALUES (%d,%d,%d)", GetPlayerSQLId(giveplayerid), GetPlayerSQLId(playerid), gettime());
			mysql_tquery(MainPipeline, string, "OnQueryFinish", "ii", SENDDATA_THREAD, playerid);

			format(string, sizeof(string), "%s(%i) DM (bi ban lan cuoi cach day %i giay)", GetPlayerNameEx(giveplayerid), giveplayerid, gettime() - ShotPlayer[giveplayerid][playerid]);
			SendReportToQue(playerid, string, 2, 1);

			ShotPlayer[giveplayerid][playerid] = 0;

			SetPVarInt(playerid, "AlertedThisPlayer", giveplayerid);
			SetPVarInt(playerid, "AlertType", 1);
			AlertTime[playerid] = 300;
		}
		else
		{
			SendClientMessage(playerid, COLOR_GRAD2, "Da huy bao cao DM");
		}
		DeletePVar(playerid, "pDMReport");
	}
	else if(dialogid == SHOPOBJECT_ORDERID)
	{
		if(response)
		{
			SetPVarString(playerid, "shopobject_orderid", inputtext);
			ShowPlayerDialogEx(playerid, SHOPOBJECT_GIVEPLAYER, DIALOG_STYLE_INPUT, "Shop Objects - ID nguoi choi", "Hay nhap ID nguoi choi", "Dong y", "Huy");
		}
	}
	else if(dialogid == SHOPOBJECT_GIVEPLAYER)
	{
		if(response)
		{
			SetPVarString(playerid, "shopobject_giveplayerid", inputtext);
			new stringg[1024];
			for(new x;x<sizeof(HoldingObjectsShop);x++)
			{
				new shopToyName[24];
				strunpack(shopToyName, HoldingObjectsShop[x][holdingmodelname], sizeof(shopToyName));
				format(stringg, sizeof(stringg), "%s%s\n", stringg, shopToyName);
			}
			ShowPlayerDialogEx(playerid, SHOPOBJECT_OBJECTID, DIALOG_STYLE_LIST, "Shop Objects - Object ID", stringg, "Chon", "Huy");
		}
	}
	else if(dialogid == SHOPOBJECT_OBJECTID)
	{
		if(response)
		{
			new giveplayerid;
			new str[MAX_PLAYER_NAME];
			GetPVarString(playerid, "shopobject_giveplayerid", str, MAX_PLAYER_NAME);
			sscanf(str, "u", giveplayerid);
			new stringg[512], icount = GetPlayerToySlots(giveplayerid);
			if(!IsPlayerConnected(giveplayerid) || giveplayerid == INVALID_PLAYER_ID)
			{
				ShowPlayerDialogEx(playerid, SHOPOBJECT_GIVEPLAYER, DIALOG_STYLE_INPUT, "Shop Objects - ID nguoi choi", "LOI: Nguoi do chua ket noi \nHay nhap lai ID nguoi choi", "Dong y", "Huy");
				return 1;
			}
			SetPVarInt(playerid, "shopobject_objectid", listitem);
			for(new x;x<icount;x++)
			{
				new name[24] = "None";

				for(new i;i<sizeof(HoldingObjectsAll);i++)
				{
					if(HoldingObjectsAll[i][holdingmodelid] == PlayerToyInfo[giveplayerid][x][ptModelID])
					{
						strunpack(name, HoldingObjectsAll[i][holdingmodelname], sizeof(name));
					}
				}

				strunpack(boneName, HoldingBones[PlayerToyInfo[giveplayerid][x][ptBone]], sizeof(boneName));
				format(stringg, sizeof(stringg), "%s(%d) %s (Gan: %s)\n", stringg, x, name, boneName);
			}
			ShowPlayerDialogEx(playerid, SHOPOBJECT_TOYSLOT, DIALOG_STYLE_LIST, "Shop Objects - Chon o", stringg, "Chon", "Huy");
		}
	}
	else if(dialogid == SHOPOBJECT_TOYSLOT)
	{
		if(response)
		{
			new stringg[128];
			new giveplayerid;
			new str[MAX_PLAYER_NAME];
			GetPVarString(playerid, "shopobject_giveplayerid", str, MAX_PLAYER_NAME);
			sscanf(str, "u", giveplayerid);
			new object = HoldingObjectsShop[GetPVarInt(playerid, "shopobject_objectid")][holdingmodelid];
			new slot = listitem;
			new invoice[64];
			GetPVarString(playerid, "shopobject_orderid", invoice, sizeof(invoice));
			if(!IsPlayerConnected(giveplayerid) || giveplayerid == INVALID_PLAYER_ID)
			{
				ShowPlayerDialogEx(playerid, SHOPOBJECT_GIVEPLAYER, DIALOG_STYLE_INPUT, "Shop Objects - ID nguoi choi", "LOI: Nguoi do chua ket noi \nVui long nhap lai ID nguoi choi", "Dong y", "Huy");
				return 1;
			}
			if(!toyCountCheck(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi choi nay khong du o trong");

			format(stringg, sizeof(stringg), "Ban da cap cho %s object %d vao o %d", GetPlayerNameEx(giveplayerid), object, slot);
			ShowPlayerDialogEx(playerid, SHOPOBJECT_SUCCESS, DIALOG_STYLE_MSGBOX, "Shop Objects - Thanh cong", stringg, "Dong y", "");
			SendClientMessageEx(giveplayerid, COLOR_WHITE, "Ban nhan mot /toys moi tu shop!");
			format(string, sizeof(string), "[SHOPOBJECTS] %s gave %s(%d) object %d in slot %d - Invoice %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), object, slot, invoice);
			PlayerToyInfo[giveplayerid][slot][ptModelID] = object;
			PlayerToyInfo[giveplayerid][slot][ptBone] = 1;
			PlayerToyInfo[giveplayerid][slot][ptTradable] = 1;
			g_mysql_NewToy(giveplayerid, slot);
			Log("logs/shoplog.log", string);
		}
	}
	else if(dialogid == LISTTOYS_DELETETOY)
	{
		if(response)
		{
			if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1)
			{
				return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen lam viec nay");
			}
			new giveplayerid = GetPVarInt(playerid, "listtoys_giveplayerid");
			SetPVarInt(playerid, "listitem_toyslot", listitem);
			format(string, sizeof(string), "Ban chac muon xoa toy cua %s (Model ID: %d) tai o %d?", GetPlayerNameEx(giveplayerid), PlayerToyInfo[giveplayerid][listitem][ptModelID], listitem+1);
			ShowPlayerDialogEx(playerid, LISTTOYS_DELETETOYCONFIRM, DIALOG_STYLE_MSGBOX, "Xoa toy - Ban chac chu?", string, "Co", "Khong");
		}
	}
	else if(dialogid == LISTTOYS_DELETETOYCONFIRM)
	{
		if(response)
		{
			new stringg[128], szQuery[128], giveplayerid = GetPVarInt(playerid, "listtoys_giveplayerid"), slot = GetPVarInt(playerid, "listitem_toyslot");
			new object =  PlayerToyInfo[giveplayerid][slot][ptModelID];
			if(!IsPlayerConnected(giveplayerid) || giveplayerid == INVALID_PLAYER_ID)
			{
				ShowPlayerDialogEx(playerid, SHOPOBJECT_GIVEPLAYER, DIALOG_STYLE_MSGBOX, "Xoa Toy - ID nguoi choi", "LOI: Nguoi choi do chua ket noi", "Dong y", "");
				return 1;
			}
			new toys = 99999;
			for(new i; i < 10; i++)
			{
				if(PlayerHoldingObject[giveplayerid][i] == slot)
				{
					toys = i;
					if(IsPlayerAttachedObjectSlotUsed(giveplayerid, toys))
					{
						PlayerHoldingObject[giveplayerid][i] = 0;
						RemovePlayerAttachedObject(giveplayerid, toys);
					}
					break;
				}
			}
			format(stringg, sizeof(stringg), "Ban da xoa cua %s object %d tai o %d", GetPlayerNameEx(giveplayerid), object, slot+1);
			ShowPlayerDialogEx(playerid, SHOPOBJECT_SUCCESS, DIALOG_STYLE_MSGBOX, "Xoa Toy - Thanh cong", stringg, "Dong y", "");
			SendClientMessageEx(giveplayerid, COLOR_WHITE, "Admin %s da xoa toy cua ban (model obj: %d) tai o %d.", GetPlayerNameEx(playerid), object, slot);
			format(string, sizeof(string), "[TOYDELETE] %s deleted %s's(%d) object %d in slot %d", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), object, slot);
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "DELETE FROM `toys` WHERE `id` = %d", PlayerToyInfo[giveplayerid][slot][ptID]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "ii", SENDDATA_THREAD, giveplayerid);
			PlayerToyInfo[giveplayerid][slot][ptModelID] = 0;
			PlayerToyInfo[giveplayerid][slot][ptBone] = 0;
			PlayerToyInfo[giveplayerid][slot][ptSpecial] = 0;
			Log("logs/toydelete.log", string);
		}
	}
	else if(dialogid == MDC_SHOWCRIMES)
	{
		if(response)
		{
			ShowPlayerDialogEx(playerid, MDC_CIVILIANS, DIALOG_STYLE_LIST, "MDC - Da dang nhap | Cong dan", "*Tra cuu ho so\n*Bao cao bat giu\n*Giay phep\n*Lenh truy na\n*Lap lenh truy na\n*BOLO\n*Lap BOLO\n*Xoa", "Dong y", "Huy");
		}
	}
	else if(dialogid == FLAG_LIST)
	{
		if(response)
		{
			if(!IsPlayerConnected(GetPVarInt(playerid, "viewingflags"))) return SendClientMessage(playerid, -1, "Nguoi choi ban dang quan ly flag da ngat ket noi!");
			if(!GetPVarType(playerid, "ManageFlagID"))
			{
				new stpos = strfind(inputtext, "(");
				new fpos = strfind(inputtext, ")");
				new fid[11];
				strmid(fid, inputtext, stpos+5, fpos);
				SetPVarInt(playerid, "ManageFlagID", strval(fid));
				format(string, sizeof(string), "Quan ly FlagID: %d", GetPVarInt(playerid, "ManageFlagID"));
				return ShowPlayerDialogEx(playerid, FLAG_LIST, DIALOG_STYLE_LIST, string, "Xem\nChuyen\nXoa", "Chon", "Dong");
			}
			else
			{
				if(listitem == -1)
				{
					new target;
					if(sscanf(inputtext, "u", target)) return ShowPlayerDialogEx(playerid, FLAG_LIST, DIALOG_STYLE_INPUT, "CHUYEN FLAG", "Nhap nguoi choi nhan flag.", "Chon", "Huy");
					if(GetPVarInt(playerid, "viewingflags") == target) return SendClientMessageEx(playerid, COLOR_GRAD2, "LOI: Khong the chuyen cho cung mot nguoi!");
					if(!IsPlayerConnected(target)) return ShowPlayerDialogEx(playerid, FLAG_LIST, DIALOG_STYLE_INPUT, "CHUYEN FLAG - LOI", "Nguoi choi da ngat ket noi!\nNhap nguoi choi nhan flag.", "Chon", "Huy");
					mysql_format(MainPipeline, string, sizeof(string), "SELECT id, flag, issuer, time, type FROM `flags` WHERE `fid` = %i", GetPVarInt(playerid, "ManageFlagID"));
					mysql_tquery(MainPipeline, string, "OnRequestTransferFlag", "iiii", playerid, GetPVarInt(playerid, "ManageFlagID"), target, GetPVarInt(playerid, "viewingflags"));
				}
				if(listitem == 0)
				{
					mysql_format(MainPipeline, string, sizeof(string), "SELECT fid, issuer, flag, time FROM `flags` WHERE fid = %d", GetPVarInt(playerid, "ManageFlagID"));
					mysql_tquery(MainPipeline, string, "FlagQueryFinish", "iii", playerid, GetPVarInt(playerid, "viewingflags"), 0);
				}
				if(listitem == 1)
				{
					ShowPlayerDialogEx(playerid, FLAG_LIST, DIALOG_STYLE_INPUT, "CHUYEN FLAG", "Nhap nguoi choi nhan flag.", "Chon", "Huy");
				}
				if(listitem == 2)
				{
					mysql_format(MainPipeline, string, sizeof(string), "SELECT flag, issuer, time, type FROM `flags` WHERE `fid` = %i", GetPVarInt(playerid, "ManageFlagID"));
					mysql_tquery(MainPipeline, string, "OnRequestDeleteFlag", "ii", playerid, GetPVarInt(playerid, "ManageFlagID"));
				}
			}
		}
	}
	else if(dialogid == FLAG_DELETE)
	{
		if(response)
		{
			new flagid;
			if(sscanf(inputtext, "d", flagid)) return ShowPlayerDialogEx(playerid, FLAG_DELETE, DIALOG_STYLE_INPUT, "XOA FLAG", "Nhap ID flag can xoa.", "Xoa Flag", "Dong");
			new query[128];
			mysql_format(MainPipeline, query, sizeof(query), "SELECT flag, issuer, time, type FROM `flags` WHERE `fid` = %i", flagid);
			mysql_tquery(MainPipeline, query, "OnRequestDeleteFlag", "ii", playerid, flagid);
		}
	}
	else if(dialogid == FLAG_DELETE2)
	{
		if(response)
		{
			new flagid = GetPVarInt(playerid, "Flag_Delete_ID");
			DeleteFlag(flagid, playerid);
			SendClientMessageEx(playerid, COLOR_YELLOW, " Da xoa flag thanh cong ");
		}
	}
	else if(dialogid == SKIN_LIST)
	{
		if(response)
		{
			new query[128];
			SetPVarInt(playerid, "closetchoiceid", listitem);
			mysql_format(MainPipeline, query, sizeof(query), "SELECT `skinid` FROM `house_closet` WHERE playerid = %d ORDER BY `skinid` ASC", GetPlayerSQLId(playerid));
			mysql_tquery(MainPipeline, query, "SkinQueryFinish", "ii", playerid, Skin_Query_ID);
		}
	}
	else if(dialogid == SKIN_CONFIRM)
	{
		if(response)
		{
			PlayerInfo[playerid][pModel] = GetPVarInt(playerid, "closetskinid");
			DeletePVar(playerid, "closetchoiceid");
			DeletePVar(playerid, "closetskinid");
		}
		else
		{
			SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]);
			DeletePVar(playerid, "closetchoiceid");
			DeletePVar(playerid, "closetskinid");
			DisplaySkins(playerid);
		}
	}
	else if(dialogid == SKIN_DELETE)
	{
		if(response)
		{
			new query[128];
			SetPVarInt(playerid, "closetchoiceid", listitem);
			mysql_format(MainPipeline, query, sizeof(query), "SELECT `id`, `skinid` FROM `house_closet` WHERE playerid = %d ORDER BY `skinid` ASC", GetPlayerSQLId(playerid));
			mysql_tquery(MainPipeline, query, "SkinQueryFinish", "ii", playerid, Skin_Query_Delete_ID);
		}
	}
	else if(dialogid == SKIN_DELETE2)
	{
		if(response)
		{
			DeleteSkin(GetPVarInt(playerid, "closetskinid"));
			DeletePVar(playerid, "closetchoiceid");
			DeletePVar(playerid, "closetskinid");
			SendClientMessageEx(playerid, COLOR_WHITE, "Da thao quan ao!");
		}
		else
		{
			DeletePVar(playerid, "closetchoiceid");
			DeletePVar(playerid, "closetskinid");
			DisplaySkins(playerid);
		}
	}
	else if(dialogid == NATION_APP_LIST)
	{
		if(response)
		{
			ShowPlayerDialogEx(playerid, NATION_APP_CHOOSE, DIALOG_STYLE_MSGBOX, "Don xin quoc tich", "Ban muon lam gi voi don nay?", "Dong y", "Tu choi");
			SetPVarInt(playerid, "Nation_App_ID", listitem);
		}
	}
	else if(dialogid == NATION_APP_CHOOSE)
	{
		if(response)
		{
			switch(arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance])
			{
				case 1: mysql_tquery(MainPipeline, "SELECT `id`, `playerid`, `name` FROM `nation_queue` WHERE `nation` = 0 AND `status` = 1 ORDER BY `id` ASC", "NationAppFinish", "ii", playerid, AcceptApp);
				case 2: mysql_tquery(MainPipeline, "SELECT `id`, `playerid`, `name` FROM `nation_queue` WHERE `nation` = 1 AND `status` = 1 ORDER BY `id` ASC", "NationAppFinish", "ii", playerid, AcceptApp);
			}
		}
		else
		{
			switch(arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance])
			{
				case 1: mysql_tquery(MainPipeline, "SELECT `id`, `playerid`, `name` FROM `nation_queue` WHERE `nation` = 0 AND `status` = 1 ORDER BY `id` ASC", "NationAppFinish", "ii", playerid, DenyApp);
				case 2: mysql_tquery(MainPipeline, "SELECT `id`, `playerid`, `name` FROM `nation_queue` WHERE `nation` = 1 AND `status` = 1 ORDER BY `id` ASC", "NationAppFinish", "ii", playerid, DenyApp);
			}
		}
	}
	else if(dialogid == DIALOG_911MENU)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0: ShowPlayerDialogEx(playerid, DIALOG_911EMERGENCY, DIALOG_STYLE_INPUT, "Dich vu khan cap 911", "Hay mo ta tinh huong khan cap.", "Nhap", "Gac may");
				case 1: ShowPlayerDialogEx(playerid, DIALOG_911MEDICAL, DIALOG_STYLE_INPUT, "Dich vu khan cap 911", "Hay mo ta tinh huong cap cuu y te.", "Nhap", "Gac may");
				case 2: ShowPlayerDialogEx(playerid, DIALOG_911POLICE, DIALOG_STYLE_INPUT, "Dich vu khan cap 911", "Hay mo ta ly do can canh sat ho tro.", "Nhap", "Gac may");
				case 3: ShowPlayerDialogEx(playerid, DIALOG_911TOWING, DIALOG_STYLE_INPUT, "Dich vu khan cap 911", "Hay mo ta ly do can cuu ho xe.", "Nhap", "Gac may");
				case 4: {
					szMiscArray[0] = 0;
					new icount = GetPlayerVehicleSlots(playerid);
					new szCarLocation[MAX_ZONE_NAME];
					for(new i, iModelID; i < icount; i++)
					{
						if((iModelID = PlayerVehicleInfo[playerid][i][pvModelId] - 400) >= 0)
						{
							Get3DZone(PlayerVehicleInfo[playerid][i][pvPosX], PlayerVehicleInfo[playerid][i][pvPosY], PlayerVehicleInfo[playerid][i][pvPosZ], szCarLocation, sizeof(szCarLocation));
							if(PlayerVehicleInfo[playerid][i][pvImpounded]) {
								strunpack(vehicleName, VehicleName[iModelID], sizeof(vehicleName));
								format(szMiscArray, sizeof(szMiscArray), "%s\n%s (bi giam) | Vi tri: DMV", szMiscArray, vehicleName);
							}
							else if(PlayerVehicleInfo[playerid][i][pvDisabled]) {
								strunpack(vehicleName, VehicleName[iModelID], sizeof(vehicleName));
								format(szMiscArray, sizeof(szMiscArray), "%s\n%s (vo hieu) | Vi tri: Khong ro", szMiscArray, vehicleName);
							}
							else if(!PlayerVehicleInfo[playerid][i][pvSpawned]) {
								strunpack(vehicleName, VehicleName[iModelID], sizeof(vehicleName));
								format(szMiscArray, sizeof(szMiscArray), "%s\n%s (da cat) | Vi tri: %s", szMiscArray, vehicleName, szCarLocation);
							}
							else {
								if(PlayerVehicleInfo[playerid][i][pvAlarmTriggered]) {
									strunpack(vehicleName, VehicleName[iModelID], sizeof(vehicleName));
									format(szMiscArray, sizeof(szMiscArray), "%s\n%s (bao dong) | Vi tri: %s", szMiscArray, vehicleName, szCarLocation);
								}
								else {
									strunpack(vehicleName, VehicleName[iModelID], sizeof(vehicleName));
									format(szMiscArray, sizeof(szMiscArray), "%s\n%s | Vi tri: %s", szMiscArray, vehicleName, szCarLocation);
								}
							}
						}
					}
					ShowPlayerDialogEx(playerid, DIALOG_911PICKLOCK, DIALOG_STYLE_LIST, "Bao cao trom xe", szMiscArray, "Theo doi", "Huy");
				}
				case 5: ShowPlayerDialogEx(playerid, DIALOG_911FIRE, DIALOG_STYLE_INPUT, "Dich vu khan cap 911", "Hay mo ta ly do can cuu hoa ho tro.", "Nhap", "Gac may");
			}
		}
	}
	else if(dialogid == DIALOG_911EMERGENCY)
	{
		if(response)
		{
			new zone[MAX_ZONE_NAME], mainzone[MAX_ZONE_NAME];
			if(strlen(inputtext) < 4) return ShowPlayerDialogEx(playerid, DIALOG_911EMERGENCY, DIALOG_STYLE_INPUT, "Dich vu khan cap 911", "Chua ro thong tin. Ban dang gap tinh huong khan cap gi?", "Nhap", "Gac may");
			else
			{
				GetPlayer2DZone(playerid, zone, MAX_ZONE_NAME);
				GetPlayerMainZone(playerid, mainzone, MAX_ZONE_NAME);
				SendCallToQueue(playerid, inputtext, zone, mainzone, 0);
				SetPVarInt(playerid, "Has911Call", 1);
				SendClientMessageEx(playerid, TEAM_CYAN_COLOR, "Dispatch: Da bao cho cac don vi trong khu vuc.");
				SendClientMessageEx(playerid, TEAM_CYAN_COLOR, "Cam on ban da bao vu viec nay");
			}
		}
	}
	else if(dialogid == DIALOG_911MEDICAL)
	{
		if(response)
		{
			new zone[MAX_ZONE_NAME], mainzone[MAX_ZONE_NAME];
			if(strlen(inputtext) < 4) return ShowPlayerDialogEx(playerid, DIALOG_911MEDICAL, DIALOG_STYLE_INPUT, "Dich vu khan cap 911", "Chua ro thong tin. Ban dang gap van de cap cuu y te gi?", "Nhap", "Gac may");
			else
			{
				GetPlayer2DZone(playerid, zone, MAX_ZONE_NAME);
				GetPlayerMainZone(playerid, mainzone, MAX_ZONE_NAME);
				SendCallToQueue(playerid, inputtext, zone, mainzone, 1);
				SetPVarInt(playerid, "Has911Call", 1);
				SendClientMessageEx(playerid, TEAM_CYAN_COLOR, "Dispatch: Da bao cho cac don vi trong khu vuc.");
				SendClientMessageEx(playerid, TEAM_CYAN_COLOR, "Cam on ban da bao vu viec nay");
			}
		}
	}
	else if(dialogid == DIALOG_911POLICE)
	{
		if(response)
		{
			new zone[MAX_ZONE_NAME], mainzone[MAX_ZONE_NAME];
			if(strlen(inputtext) < 4) return ShowPlayerDialogEx(playerid, DIALOG_911POLICE, DIALOG_STYLE_INPUT, "Dich vu khan cap 911", "Chua ro thong tin. Vi sao ban can canh sat ho tro?", "Nhap", "Gac may");
			else
			{
				GetPlayer2DZone(playerid, zone, MAX_ZONE_NAME);
				GetPlayerMainZone(playerid, mainzone, MAX_ZONE_NAME);
				SendCallToQueue(playerid, inputtext, zone, mainzone, 2);
				SetPVarInt(playerid, "Has911Call", 1);
				SendClientMessageEx(playerid, TEAM_CYAN_COLOR, "Dispatch: Da bao cho cac don vi trong khu vuc.");
				SendClientMessageEx(playerid, TEAM_CYAN_COLOR, "Cam on ban da bao vu viec nay");
			}
		}
	}
	else if(dialogid == DIALOG_911TOWING)
	{
		if(response)
		{
			new zone[MAX_ZONE_NAME], mainzone[MAX_ZONE_NAME];
			if(strlen(inputtext) < 4) return ShowPlayerDialogEx(playerid, DIALOG_911TOWING, DIALOG_STYLE_INPUT, "Dich vu khan cap 911", "Chua ro thong tin. Vi sao ban can cuu ho xe?", "Nhap", "Gac may");
			else
			{
				GetPlayer2DZone(playerid, zone, MAX_ZONE_NAME);
				GetPlayerMainZone(playerid, mainzone, MAX_ZONE_NAME);
				SendCallToQueue(playerid, inputtext, zone, mainzone, 3);
				SetPVarInt(playerid, "Has911Call", 1);
				SendClientMessageEx(playerid, TEAM_CYAN_COLOR, "Dispatch: Da bao cho cac don vi trong khu vuc.");
				SendClientMessageEx(playerid, TEAM_CYAN_COLOR, "Cam on ban da bao vu viec nay");
			}
		}
	}
	else if(dialogid == DIALOG_911FIRE)
	{
		if(response)
		{
			new zone[MAX_ZONE_NAME], mainzone[MAX_ZONE_NAME];
			if(strlen(inputtext) < 4) return ShowPlayerDialogEx(playerid, DIALOG_911FIRE, DIALOG_STYLE_INPUT, "Dich vu khan cap 911", "Chua ro thong tin. Vi sao ban can ho tro?", "Nhap", "Gac may");
			else
			{
				GetPlayer2DZone(playerid, zone, MAX_ZONE_NAME);
				GetPlayerMainZone(playerid, mainzone, MAX_ZONE_NAME);
				SendCallToQueue(playerid, inputtext, zone, mainzone, 5);
				SetPVarInt(playerid, "Has911Call", 1);
				SendClientMessageEx(playerid, TEAM_CYAN_COLOR, "Dispatch: Da bao cho cac don vi trong khu vuc.");
				SendClientMessageEx(playerid, TEAM_CYAN_COLOR, "Cam on ban da bao vu viec nay");
			}
		}
	}
	else if(dialogid == DIALOG_HOTLINE)
	{
		if(response)
		{
			new zone[MAX_ZONE_NAME], mainzone[MAX_ZONE_NAME];

			if(strlen(inputtext) < 4) {

				if(GetPVarType(playerid, "BUSICALL")) {

					new i = GetPVarInt(playerid, "BUSICALL");
					format(szMiscArray, sizeof(szMiscArray), "DT ban: %s | %d", Businesses[i][bName], Businesses[i][bPhoneNr]);
				}
				else {

					new i = GetPVarInt(playerid, "GRPCALL");
					format(szMiscArray, sizeof(szMiscArray), "{%s}Duong day nong cua %s", Group_NumToDialogHex(arrGroupData[i][g_hDutyColour]), arrGroupData[i][g_szGroupName]);
				}
				return ShowPlayerDialogEx(playerid, DIALOG_HOTLINE, DIALOG_STYLE_INPUT, szMiscArray, "Ban co the cung cap them thong tin khong?", "Nhap", "Gac may");
			}
			else
			{
				GetPlayer2DZone(playerid, zone, MAX_ZONE_NAME);
				GetPlayerMainZone(playerid, mainzone, MAX_ZONE_NAME);
				if(GetPVarType(playerid, "GRPCALL")) SendCallToQueue(playerid, inputtext, zone, mainzone, 6);
				if(GetPVarType(playerid, "BUSICALL")) SendCallToQueue(playerid, inputtext, zone, mainzone, 7);
				SetPVarInt(playerid, "Has911Call", 1);
				SendClientMessageEx(playerid, TEAM_CYAN_COLOR, "Tra loi tu dong: Cam on ban da goi dien thoai ban.");
				SendClientMessageEx(playerid, TEAM_CYAN_COLOR, "Chung toi se som ho tro ban.");
			}
		}
	}
	else if(dialogid == DIALOG_SUSPECTMENU)
	{
		if(response)
		{
			if(strcmp(inputtext, "Other (Not Listed)", true) == 0)
			{
				return ShowPlayerDialogEx(playerid, DIALOG_SUSPECTMENU, DIALOG_STYLE_INPUT, "Nhap toi danh", "Hay chon toi danh", "Gui", "Huy");
			}
			if(strlen(inputtext) <= 3)
			{
				return ShowPlayerCrimeDialog(playerid);
			}
			if(inputtext[0] == '-')
			{
				return ShowPlayerCrimeDialog(playerid);
			}
			new iTargetID = GetPVarInt(playerid, "suspect_TargetID");
			++PlayerInfo[iTargetID][pCrimes];
			new crimeid = -1;
			for(new i; i < sizeof(SuspectCrimes); i++)
			{
				new crimeName[41];
				strunpack(crimeName, SuspectCrimes[i], sizeof(crimeName));
				if(strcmp(inputtext, crimeName) == 0)
				{
					crimeid = i;
					break;
				}
			}
			if(crimeid != -1)
			{
				PlayerInfo[iTargetID][pWantedLevel] += SuspectCrimeInfo[crimeid][1];
			}
			else PlayerInfo[iTargetID][pWantedLevel] += 1;
			if(PlayerInfo[iTargetID][pWantedLevel] > 6)
			{
				PlayerInfo[iTargetID][pWantedLevel] = 6;
			}
			SetPlayerWantedLevel(iTargetID, PlayerInfo[iTargetID][pWantedLevel]);
			if(PlayerInfo[iTargetID][pConnectHours] < 32)
			{
				PlayerInfo[iTargetID][pWantedJailTime] += SuspectCrimeInfo[crimeid][2]/10;
				PlayerInfo[iTargetID][pWantedJailFine] += SuspectCrimeInfo[crimeid][3]/10;
			}
			else
			{
				PlayerInfo[iTargetID][pWantedJailTime] += SuspectCrimeInfo[crimeid][2];
				PlayerInfo[iTargetID][pWantedJailFine] += SuspectCrimeInfo[crimeid][3];
			}
			new szCountry[10], szCrime[128];
			if(arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance] == 1)
			{
				format(szCountry, sizeof(szCountry), "[SA] ");
			}
			else if(arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance] == 2)
			{
				format(szCountry, sizeof(szCountry), "[NE] ");
			}
			strcat(szCrime, szCountry);
			strcat(szCrime, inputtext);
			AddCrime(playerid, iTargetID, szCrime);

			SendClientMessageEx(iTargetID, COLOR_LIGHTRED, "Ban da pham toi ( %s ). Nguoi bao: %s.", szCrime, GetPlayerNameEx(playerid));

			SendClientMessageEx(iTargetID, COLOR_YELLOW, "Muc truy na hien tai: %d", PlayerInfo[iTargetID][pWantedLevel]);

			foreach(new i: Player)
			{
				if(IsACop(i) && arrGroupData[PlayerInfo[playerid][pMember]][g_iAllegiance] == arrGroupData[PlayerInfo[i][pMember]][g_iAllegiance]) {
					SendClientMessageEx(i, TEAM_BLUE_COLOR, "HQ: APB den tat ca don vi (nguoi bao: %s)",GetPlayerNameEx(playerid));
					SendClientMessageEx(i, TEAM_BLUE_COLOR, "HQ: Toi danh: %s, nghi pham: %s", szCrime, GetPlayerNameEx(iTargetID));
				}
			}
			PlayerInfo[iTargetID][pDefendTime] = 60;
		}
	}
	else if(dialogid == DIALOG_REPORTMENU)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0: //Deathmatch
				{
					if(PlayerInfo[playerid][pJailTime] > 0) {
						SendClientMessage(playerid, COLOR_GREY, "Khong the bao cao khi dang bi giam.");
					}
					else {
						ShowPlayerDialogEx(playerid, DIALOG_REPORTDM, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Deathmatch", "Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
					}
				}
				case 1: //Falling
				{
					if(gettime() - LastShot[playerid] < 20)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Ban bi thuong trong 20 giay qua, lam dung he thong nay se bi cam tam thoi.");
					}
					else
					{
						new
							Message[128];

						TogglePlayerControllable(playerid, false);
						SetPVarInt(playerid, "IsFrozen", 1);
						SetPVarInt(playerid, "_rAutoM", 5);
						SetPVarInt(playerid, "_rRepID", playerid);
						format(Message, sizeof(Message), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) da bi dong bang. (Bao cao bi roi)", GetPlayerNameEx(playerid), playerid);
						ABroadCast(COLOR_YELLOW, Message, 2);
						SendReportToQue(playerid, "Bi roi (Da dong bang nguoi choi)", 2, GetPlayerPriority(playerid));
						SendClientMessageEx(playerid, COLOR_WHITE, "Da gui bao cao den Admin, ban da bi dong bang.");
					}
				}
				case 2: //Hacking
				{
					ShowPlayerDialogEx(playerid, DIALOG_REPORTHACK, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Gian lan", "Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				}
				case 3: //Chicken Running
				{
					ShowPlayerDialogEx(playerid, DIALOG_REPORTCR, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Chicken Running", "Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				}
				case 4: //Car Ramming
				{
					ShowPlayerDialogEx(playerid, DIALOG_REPORTCARRAM, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Dam xe", "Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				}
				case 5: //Power Gaming
				{
					ShowPlayerDialogEx(playerid, DIALOG_REPORTPG, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Power Gaming", "Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				}
				case 6: //Meta Gaming
				{
					ShowPlayerDialogEx(playerid, DIALOG_REPORTMG, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Meta Gaming", "Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				}
				case 7: //Gun Discharge Exploits
				{
					ShowPlayerDialogEx(playerid, DIALOG_REPORTGDE, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Loi ban sung", "Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				}
				case 8: //Spamming
				{
					ShowPlayerDialogEx(playerid, DIALOG_REPORTSPAM, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Spam", "Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				}
				case 9: //Money Farming
				{
					ShowPlayerDialogEx(playerid, DIALOG_REPORTMF, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Money Farming", "Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				}
				case 10: //Ban Evader
				{
					ShowPlayerDialogEx(playerid, DIALOG_REPORTBANEVADE, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Ne lenh cam", "Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				}
				case 11: //General Exploits
				{
					ShowPlayerDialogEx(playerid, DIALOG_REPORTGE, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Loi co the loi dung", "Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				}
				case 12: //Releasing Hitman Names
				{
					ShowPlayerDialogEx(playerid, DIALOG_REPORTRHN, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Tiet lo ten Hitman", "Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				}
				case 13: //Running/Swimming Man Exploit
				{
					ShowPlayerDialogEx(playerid, DIALOG_REPORTRSE, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Loi Running/Swimming Man", "Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				}
				case 14: //Car Surfing
				{
					ShowPlayerDialogEx(playerid, DIALOG_REPORTCARSURF, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Dung tren xe", "Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				}
				case 15: //NonRp Behavior
				{
					ShowPlayerDialogEx(playerid, DIALOG_REPORTNRPB, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Hanh vi NonRP", "Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				}
				case 16: //Next Page
				{
					ShowPlayerDialogEx(playerid, DIALOG_REPORTMENU2, DIALOG_STYLE_LIST, "Menu bao cao [2/2]", "Giet tra thu\nOOC Hit\nQuang cao may chu\nTen NonRP\nKhac/Tu nhap (Chi PVIP)\nChuyen nha\nKhieu nai Admin\nNhan thuong\nVan de shop\nKhong co trong danh sach\nYeu cau CA\nYeu cau go cam chat\nTrang truoc","Chon", "Thoat");
				}
			}
		}
	}
	else if(dialogid == DIALOG_REPORTMENU2)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0: //Revenge Killing
				{
					ShowPlayerDialogEx(playerid, DIALOG_REPORTRK, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Giet tra thu", "Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				}
				case 1: //OOC Hit
				{
					ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, "OOC Hit", "{FFFFFF}OOC Hit can duoc xu ly tren dien dan. (Khieu nai nguoi choi)\n\n                 ng-gaming.net/forums", "Dong", "");
				}
				case 2: //Server Advertising
				{
					ShowPlayerDialogEx(playerid, DIALOG_REPORTSA, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Quang cao may chu", "Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				}
				case 3: //Non RP Name
				{
					ShowPlayerDialogEx(playerid, DIALOG_REPORTNRPN, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Ten Non-RP", "Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				}
				case 4: //Other/Freetext (PVip Only!!)
				{
					if(PlayerInfo[playerid][pDonateRank] >= 4) {
						ShowPlayerDialogEx(playerid, DIALOG_REPORTFREE, DIALOG_STYLE_INPUT,"Khac / Tu nhap","Nhap noi dung muon gui den doi ngu Admin.","Gui","Huy");
					}
					else {
						SendClientMessageEx(playerid, COLOR_GREY, "Tinh nang nay chi danh cho Platinum VIP.");
					}
				}
				case 5: //House Move
				{
					SendReportToQue(playerid, "Chuyen nha", 4, GetPlayerPriority(playerid));
					SendClientMessageEx(playerid, COLOR_WHITE, "Da gui yeu cau chuyen nha den Admin dang online.");
				}
				case 6: //Appeal Admin Action
				{
					if(gettime() < GetPVarInt(playerid, "_rAppeal")) return SendClientMessageEx(playerid, COLOR_GREY, "Can cho it nhat 60 giay truoc khi khieu nai xu ly cua Admin.");
					SendReportToQue(playerid,"Khieu nai xu ly cua Admin", 4, GetPlayerPriority(playerid));
					SendClientMessageEx(playerid, COLOR_WHITE, "Da gui khieu nai xu ly cua Admin den Admin dang online.");
				}
				case 7: //Prize Claim
				{
					if(PlayerInfo[playerid][pFlagged] == 0) {
						SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co phan thuong dang cho nhan. (Khong co Flag)");
						return 1;
					}
					else
					{
						SendReportToQue(playerid, "Nhan thuong", 4, 5);
						SendClientMessageEx(playerid, COLOR_WHITE, "Da gui yeu cau nhan thuong den Admin dang online.");
					}
				}
				case 8: //Shop Issue
				{
					ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, "Van de shop", "{FFFFFF}Dung /shophelp de xem them thong tin.", "Dong", "");
				}
				case 9: //Not Listed Here
				{
					ShowPlayerDialogEx(playerid, DIALOG_REPORTNOTLIST, DIALOG_STYLE_INPUT,"Khong co trong danh sach","Muc nay se duoc Admin phan hoi cham hon. Hay chon muc phu hop nhat de duoc xu ly som.","Gui","Huy");
				}
				case 10: // Request CA
				{
					if(PlayerInfo[playerid][pRHMutes] >= 4 || PlayerInfo[playerid][pRHMuteTime] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban dang bi cam gui yeu cau ho tro.");
					if(JustReported[playerid] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Hay cho 10 giay truoc khi gui yeu cau tiep!");
					JustReported[playerid]=10;
					format(string, sizeof(string), "** %s(%i) can ho tro, ly do: Menu bao cao. (dung /accepthelp %i)", GetPlayerNameEx(playerid), playerid, playerid);
					SendDutyAdvisorMessage(TEAM_AZTECAS_COLOR, string);
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da gui yeu cau den Advisor, hay cho phan hoi.");
					SetPVarInt( playerid, "COMMUNITY_ADVISOR_REQUEST", 1 );
					SetPVarInt( playerid, "HelpTime", 5);
					SetPVarString( playerid, "HelpReason", "Menu bao cao");
					SetTimerEx( "HelpTimer", 60000, false, "d", playerid);
				}
				case 11: //Request Unmute
				{
					if(gettime()-GetPVarInt(playerid, "UnmuteTime") < 300) {
						SendClientMessageEx(playerid, COLOR_GREY, "Phai cho it nhat 5 phut truoc khi yeu cau go cam chat.");
						return 1;
					}
					ShowPlayerDialogEx(playerid, DIALOG_UNMUTE, DIALOG_STYLE_LIST, "Yeu cau go cam chat", "Go cam quang cao\nGo cam Newbie", "Chon", "Thoat");
				}
				case 12: //Previous Page
				{
					ShowPlayerDialogEx(playerid, DIALOG_REPORTMENU, DIALOG_STYLE_LIST, "Menu bao cao [1/2]", "Deathmatch\nGian lan\nGiet tra thu\nChicken Running\nDam xe\nPower Gaming\nMeta Gaming\nLoi ban sung (QS/CS)\nSpam\nMoney Farming\nNe lenh cam\nLoi co the loi dung\nTiet lo ten Hitman\nLoi Running Man\nDung tren xe\nHanh vi NonRP\nTrang tiep","Chon", "Thoat");
				}
			}
		}
	}
	else if(dialogid == DIALOG_UNMUTE)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					if(PlayerInfo[playerid][pADMute] == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong bi cam /ads.");
					SetPVarInt(playerid, "_rAutoM", 1);
					SendReportToQue(playerid, "Go cam quang cao", 2, GetPlayerPriority(playerid));
					SendClientMessageEx(playerid, COLOR_WHITE, "Da gui bao cao den Admin dang online.");
				}
				case 1:
				{
					if(PlayerInfo[playerid][pNMute] == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong bi cam /newb.");
					SetPVarInt(playerid, "_rAutoM", 2);
					SendReportToQue(playerid, "Go cam Newbie", 2, GetPlayerPriority(playerid));
					SendClientMessageEx(playerid, COLOR_WHITE, "Da gui bao cao den Admin dang online.");
				}
			}
		}
	}
	else if(dialogid == DIALOG_REPORTDM)
	{
		if(response)
		{
			new
				Player;

			if(sscanf(inputtext, "u", Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTDM, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Deathmatch", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				return 1;
			}
			if(!IsPlayerConnected(Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTDM, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Deathmatch", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
			}
			if(PlayerInfo[playerid][pDMRMuted] != 0) return SendClientMessage(playerid, COLOR_GRAD2, "Ban dang bi cam gui bao cao DM.");
			//if(PlayerInfo[playerid][pLevel] < 2) return SendClientMessage(playerid, COLOR_GRAD2, "You must be level 2 to use this command.");
			if(playerid == Player) return SendClientMessage(playerid, COLOR_GREY, "Khong the dung lenh nay cho chinh minh!");

			if(PlayerInfo[Player][pAdmin] >= 2 && PlayerInfo[Player][pTogReports] != 1) return SendClientMessage(playerid, COLOR_GREY, "Khong the dung lenh nay voi Admin!");
			if(gettime() - ShotPlayer[Player][playerid] < 300)
			{
				SetPVarInt(playerid, "pDMReport", Player);
				ShowPlayerDialogEx(playerid, DMRCONFIRM, DIALOG_STYLE_MSGBOX, "Bao cao DM", "Ban xac nhan da tan mat thay nguoi nay DM trong 60 giay qua. Lam dung lenh co the bi cam tam thoi.", "Xac nhan", "Huy");
			}
			else
			{
				SendClientMessage(playerid, COLOR_WHITE, "Nguoi do chua ban ban hoac ban da bao cao ho trong 5 phut qua.");
				SendClientMessage(playerid, COLOR_WHITE, "Luu y, lam dung he thong nay co the bi xu ly den muc cam tam thoi.");
			}
		}
	}
	else if(dialogid == DIALOG_REPORTRK)
	{
		if(response)
		{
			new
				Player,
				Message[128];

			if(sscanf(inputtext, "u", Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTRK, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Giet tra thu", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				return 1;
			}
			else if(!IsPlayerConnected(Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTRK, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Giet tra thu", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
			}
			else if(Player == playerid) {
				SendClientMessage(playerid, COLOR_GREY, "Ban khong the bao cao chinh minh.");
			}
			else {
				SetPVarInt(playerid, "_rAutoM", 4);
				SetPVarInt(playerid, "_rRepID", Player);
				format(Message, sizeof(Message), "%s(%i) Giet tra thu", GetPlayerNameEx(Player), Player);
				SendReportToQue(playerid, Message, 2, GetPlayerPriority(playerid));
				SendClientMessageEx(playerid, COLOR_WHITE, "Da bao cao %s vi Giet tra thu. Da gui den Admin dang online.", GetPlayerNameEx(Player));
				SetPVarInt(playerid, "AlertedThisPlayer", Player);
				SetPVarInt(playerid, "AlertType", 2);
				AlertTime[playerid] = 300;
			}
		}
	}
	else if(dialogid == DIALOG_REPORTCR)
	{
		if(response)
		{
			new
				Player,
				Message[128];

			if(sscanf(inputtext, "u", Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTCR, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Chicken Running", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				return 1;
			}
			else if(!IsPlayerConnected(Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTCR, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Chicken Running", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
			}
			else if(Player == playerid) {
				SendClientMessage(playerid, COLOR_GREY, "Ban khong the bao cao chinh minh.");
			}
			else {
				SetPVarInt(playerid, "_rAutoM", 5);
				SetPVarInt(playerid, "_rRepID", Player);
				format(Message, sizeof(Message), "%s(%i) Chicken Running", GetPlayerNameEx(Player), Player);
				SendReportToQue(playerid,Message, 2, GetPlayerPriority(playerid));
				SendClientMessageEx(playerid, COLOR_WHITE, "Da bao cao %s vi Chicken Running. Da gui den Admin dang online.", GetPlayerNameEx(Player));
			}
		}
	}
	else if(dialogid == DIALOG_REPORTCARRAM)
	{
		if(response)
		{
			new
				Player,
				Message[128];

			if(sscanf(inputtext, "u", Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTCARRAM, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Dam xe", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				return 1;
			}
			else if(!IsPlayerConnected(Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTCARRAM, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Dam xe", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
			}
			else if(Player == playerid) {
				SendClientMessage(playerid, COLOR_GREY, "Ban khong the bao cao chinh minh.");
			}
			else {
				SetPVarInt(playerid, "_rAutoM", 5);
				SetPVarInt(playerid, "_rRepID", Player);
				format(Message, sizeof(Message), "%s(%i) Dam xe", GetPlayerNameEx(Player), Player);
				SendReportToQue(playerid,Message, 2, GetPlayerPriority(playerid));
				SendClientMessageEx(playerid, COLOR_WHITE, "Da bao cao %s vi Dam xe. Da gui den Admin dang online.", GetPlayerNameEx(Player));
				SetPVarInt(playerid, "AlertedThisPlayer", Player);
				SetPVarInt(playerid, "AlertType", 4);
				AlertTime[playerid] = 300;
			}
		}
	}
	else if(dialogid == DIALOG_REPORTPG)
	{
		if(response)
		{
			new
				Player,
				Message[128];

			if(sscanf(inputtext, "u", Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTPG, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Power Gaming", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				return 1;
			}
			else if(!IsPlayerConnected(Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTPG, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Power Gaming", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
			}
			else if(Player == playerid) {
				SendClientMessage(playerid, COLOR_GREY, "Ban khong the bao cao chinh minh.");
			}
			else {
				SetPVarInt(playerid, "_rAutoM", 5);
				SetPVarInt(playerid, "_rRepID", Player);
				format(Message, sizeof(Message), "%s(%i) Power Gaming", GetPlayerNameEx(Player), Player);
				SendReportToQue(playerid,Message, 2, GetPlayerPriority(playerid));
				SendClientMessageEx(playerid, COLOR_WHITE, "Da bao cao %s vi Power Gaming. Da gui den Admin dang online.", GetPlayerNameEx(Player));
			}
		}
	}
	else if(dialogid == DIALOG_REPORTMG)
	{
		if(response)
		{
			new
				Player,
				Message[128];

			if(sscanf(inputtext, "u", Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTMG, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Meta Gaming", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				return 1;
			}
			else if(!IsPlayerConnected(Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTMG, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Meta Gaming", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
			}
			else if(Player == playerid) {
				SendClientMessage(playerid, COLOR_GREY, "Ban khong the bao cao chinh minh.");
			}
			else {
				SetPVarInt(playerid, "_rAutoM", 6);
				SetPVarInt(playerid, "_rRepID", Player);
				format(Message, sizeof(Message), "%s(%i) Meta Gaming", GetPlayerNameEx(Player), Player);
				SendReportToQue(playerid,Message, 2, GetPlayerPriority(playerid));
				SendClientMessageEx(playerid, COLOR_WHITE, "Da bao cao %s vi Meta Gaming. Da gui den Admin dang online.", GetPlayerNameEx(Player));
			}
		}
	}
	else if(dialogid == DIALOG_REPORTSPAM)
	{
		if(response && !GetPVarType(playerid, "HasReport"))
		{
			new
				Player,
				Message[128];

			if(sscanf(inputtext, "u", Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTSPAM, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Spam", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				return 1;
			}
			else if(!IsPlayerConnected(Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTSPAM, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Spam", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
			}
			else if(Player == playerid) {
				SendClientMessage(playerid, COLOR_GREY, "Ban khong the bao cao chinh minh.");
			}
			else {
				SetPVarInt(playerid, "_rAutoM", 6);
				SetPVarInt(playerid, "_rRepID", Player);
				format(Message, sizeof(Message), "%s(%i) Spam", GetPlayerNameEx(Player), Player);
				SendReportToQue(playerid,Message, 2, GetPlayerPriority(playerid));
				SendClientMessageEx(playerid, COLOR_WHITE, "Da bao cao %s vi Spam. Da gui den Admin dang online.", GetPlayerNameEx(Player));
				SetPVarInt(playerid, "AlertedThisPlayer", Player);
				SetPVarInt(playerid, "AlertType", 6);
				AlertTime[playerid] = 300;
			}
		}
	}
	else if(dialogid == DIALOG_REPORTGDE)
	{
		if(response && !GetPVarType(playerid, "HasReport"))
		{
			new
				Player,
				Message[128];

			if(sscanf(inputtext, "u", Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTGDE, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Loi ban sung", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				return 1;
			}
			else if(!IsPlayerConnected(Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTGDE, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Loi ban sung", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
			}
			else if(Player == playerid) {
				SendClientMessage(playerid, COLOR_GREY, "Ban khong the bao cao chinh minh.");
			}
			else {
				SetPVarInt(playerid, "_rAutoM", 5);
				SetPVarInt(playerid, "_rRepID", Player);
				format(Message, sizeof(Message), "%s(%i) Loi ban sung", GetPlayerNameEx(Player), Player);
				SendReportToQue(playerid,Message, 2, GetPlayerPriority(playerid));
				SendClientMessageEx(playerid, COLOR_WHITE, "Da bao cao %s vi Loi ban sung. Da gui den Admin dang online.", GetPlayerNameEx(Player));
				SetPVarInt(playerid, "AlertedThisPlayer", Player);
				SetPVarInt(playerid, "AlertType", 7);
				AlertTime[playerid] = 300;
			}
		}
	}
	else if(dialogid == DIALOG_REPORTHACK)
	{
		if(response && !GetPVarType(playerid, "HasReport"))
		{
			new
				Player,
				Message[128];

			if(sscanf(inputtext, "u", Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTHACK, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Gian lan", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				return 1;
			}
			else if(!IsPlayerConnected(Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTHACK, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Gian lan", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
			}
			else if(Player == playerid) {
				SendClientMessage(playerid, COLOR_GREY, "Ban khong the bao cao chinh minh.");
			}
			else {
				SetPVarInt(playerid, "_rAutoM", 5);
				SetPVarInt(playerid, "_rRepID", Player);
				format(Message, sizeof(Message), "%s(%i) Gian lan", GetPlayerNameEx(Player), Player);
				SendReportToQue(playerid,Message, 2, 2);
				SendClientMessageEx(playerid, COLOR_WHITE, "Da bao cao %s vi Gian lan. Da gui den Admin dang online.", GetPlayerNameEx(Player));
			}
		}
	}
	else if(dialogid == DIALOG_REPORTMF)
	{
		if(response && !GetPVarType(playerid, "HasReport"))
		{
			new
				Player,
				Message[128];

			if(sscanf(inputtext, "u", Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTMF, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Money Farming", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				return 1;
			}
			else if(!IsPlayerConnected(Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTMF, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Money Farming", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
			}
			else if(Player == playerid) {
				SendClientMessage(playerid, COLOR_GREY, "Ban khong the bao cao chinh minh.");
			}
			else {
				format(Message, sizeof(Message), "%s(%i) Money Farming", GetPlayerNameEx(Player), Player);
				SendReportToQue(playerid,Message, 2, GetPlayerPriority(playerid));
				SendClientMessageEx(playerid, COLOR_WHITE, "Da bao cao %s vi Money Farming. Da gui den Admin dang online.", GetPlayerNameEx(Player));
			}
		}
	}
	else if(dialogid == DIALOG_REPORTSA)
	{
		if(response && !GetPVarType(playerid, "HasReport"))
		{
			new
				Player,
				Message[128];

			if(sscanf(inputtext, "u", Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTSA, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Quang cao may chu", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				return 1;
			}
			else if(!IsPlayerConnected(Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTSA, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Quang cao may chu", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
			}
			else if(Player == playerid) {
				SendClientMessage(playerid, COLOR_GREY, "Ban khong the bao cao chinh minh.");
			}
			else {
				SetPVarInt(playerid, "_rAutoM", 6);
				SetPVarInt(playerid, "_rRepID", Player);
				format(Message, sizeof(Message), "%s(%i) Quang cao may chu", GetPlayerNameEx(Player), Player);
				SendReportToQue(playerid,Message, 2, 2);
				SendClientMessageEx(playerid, COLOR_WHITE, "Da bao cao %s vi Quang cao may chu. Da gui den Admin dang online.", GetPlayerNameEx(Player));
			}
		}
	}
	else if(dialogid == DIALOG_REPORTNRPN)
	{
		if(response && !GetPVarType(playerid, "HasReport"))
		{
			new
				Player,
				Message[128];

			if(sscanf(inputtext, "u", Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTNRPN, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Ten NonRP", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				return 1;
			}
			else if(!IsPlayerConnected(Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTNRPN, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Ten NonRP", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
			}
			else if(Player == playerid) {
				SendClientMessage(playerid, COLOR_GREY, "Ban khong the bao cao chinh minh.");
			}
			else {
				SetPVarInt(playerid, "_rAutoM", 3);
				SetPVarInt(playerid, "_rRepID", Player);
				format(Message, sizeof(Message), "%s(%i) Ten NonRP", GetPlayerNameEx(Player), Player);
				SendReportToQue(playerid,Message, 2, GetPlayerPriority(playerid));
				SendClientMessageEx(playerid, COLOR_WHITE, "Da bao cao %s vi Ten NonRP. Da gui den Admin dang online.", GetPlayerNameEx(Player));
				SetPVarInt(playerid, "AlertedThisPlayer", Player);
				SetPVarInt(playerid, "AlertType", 8);
				AlertTime[playerid] = 300;
			}
		}
	}
	else if(dialogid == DIALOG_REPORTBANEVADE)
	{
		if(response && !GetPVarType(playerid, "HasReport"))
		{
			new
				Player,
				Message[128];

			if(sscanf(inputtext, "u", Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTBANEVADE, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Ne lenh cam", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				return 1;
			}
			else if(!IsPlayerConnected(Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTBANEVADE, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Ne lenh cam", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
			}
			else if(Player == playerid) {
				SendClientMessage(playerid, COLOR_GREY, "Ban khong the bao cao chinh minh.");
			}
			else {
				format(Message, sizeof(Message), "%s(%i) Ne lenh cam", GetPlayerNameEx(Player), Player);
				SendReportToQue(playerid,Message, 2, GetPlayerPriority(playerid));
				SendClientMessageEx(playerid, COLOR_WHITE, "Da bao cao %s vi Ne lenh cam. Da gui den Admin dang online.", GetPlayerNameEx(Player));
			}
		}
	}
	else if(dialogid == DIALOG_REPORTGE)
	{
		if(response && !GetPVarType(playerid, "HasReport"))
		{
			new
				Player,
				Message[128];

			if(sscanf(inputtext, "u", Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTGE, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Loi co the loi dung", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				return 1;
			}
			else if(!IsPlayerConnected(Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTGE, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Loi co the loi dung", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
			}
			else if(Player == playerid) {
				SendClientMessage(playerid, COLOR_GREY, "Ban khong the bao cao chinh minh.");
			}
			else {
				SetPVarInt(playerid, "_rAutoM", 5);
				SetPVarInt(playerid, "_rRepID", Player);
				format(Message, sizeof(Message), "%s(%i) Loi co the loi dung", GetPlayerNameEx(Player), Player);
				SendReportToQue(playerid,Message, 2, GetPlayerPriority(playerid));
				SendClientMessageEx(playerid, COLOR_WHITE, "Da bao cao %s vi Loi co the loi dung. Da gui den Admin dang online.", GetPlayerNameEx(Player));
			}
		}
	}
	else if(dialogid == DIALOG_REPORTRHN)
	{
		if(response && !GetPVarType(playerid, "HasReport"))
		{
			new
				Player,
				Message[128];

			if(sscanf(inputtext, "u", Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTRHN, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Tiet lo ten Hitman", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				return 1;
			}
			else if(!IsPlayerConnected(Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTRHN, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Tiet lo ten Hitman", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
			}
			else if(Player == playerid) {
				SendClientMessage(playerid, COLOR_GREY, "Ban khong the bao cao chinh minh.");
			}
			else {
				format(Message, sizeof(Message), "%s(%i) Tiet lo ten Hitman", GetPlayerNameEx(Player), Player);
				SendReportToQue(playerid,Message, 2, GetPlayerPriority(playerid));
				SendClientMessageEx(playerid, COLOR_WHITE, "Da bao cao %s vi Tiet lo ten Hitman. Da gui den Admin dang online.", GetPlayerNameEx(Player));
			}
		}
	}
	else if(dialogid == DIALOG_REPORTRSE)
	{
		if(response && !GetPVarType(playerid, "HasReport"))
		{
			new
				Player,
				Message[128];

			if(sscanf(inputtext, "u", Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTRSE, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Loi Running/Swimming Man", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				return 1;
			}
			else if(!IsPlayerConnected(Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTRSE, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Loi Running/Swimming Man", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
			}
			else if(Player == playerid) {
				SendClientMessage(playerid, COLOR_GREY, "Ban khong the bao cao chinh minh.");
			}
			else {
				SetPVarInt(playerid, "_rAutoM", 5);
				SetPVarInt(playerid, "_rRepID", Player);
				format(Message, sizeof(Message), "%s(%i) Loi Running/Swimming Man", GetPlayerNameEx(Player), Player);
				SendReportToQue(playerid,Message, 2, GetPlayerPriority(playerid));
				SendClientMessageEx(playerid, COLOR_WHITE, "Da bao cao %s vi Loi Running/Swimming Man. Da gui den Admin dang online.", GetPlayerNameEx(Player));
			}
		}
	}
	else if(dialogid == DIALOG_REPORTCARSURF)
	{
		if(response && !GetPVarType(playerid, "HasReport"))
		{
			new
				Player,
				Message[128];

			if(sscanf(inputtext, "u", Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTCARSURF, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Dung tren xe", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				return 1;
			}
			else if(!IsPlayerConnected(Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTCARSURF, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Dung tren xe", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
			}
			else if(Player == playerid) {
				SendClientMessage(playerid, COLOR_GREY, "Ban khong the bao cao chinh minh.");
			}
			else {
				SetPVarInt(playerid, "_rAutoM", 5);
				SetPVarInt(playerid, "_rRepID", Player);
				format(Message, sizeof(Message), "%s(%i) Dung tren xe", GetPlayerNameEx(Player), Player);
				SendReportToQue(playerid,Message, 2, GetPlayerPriority(playerid));
				SendClientMessageEx(playerid, COLOR_WHITE, "Da bao cao %s vi Dung tren xe. Da gui den Admin dang online.", GetPlayerNameEx(Player));
				SetPVarInt(playerid, "AlertedThisPlayer", Player);
				SetPVarInt(playerid, "AlertType", 10);
				AlertTime[playerid] = 300;
			}
		}
	}
	else if(dialogid == DIALOG_REPORTNRPB)
	{
		if(response && !GetPVarType(playerid, "HasReport"))
		{
			new
				Player;

			if(sscanf(inputtext, "u", Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTNRPB, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Hanh vi NonRP", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
				return 1;
			}
			else if(!IsPlayerConnected(Player)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTNRPB, DIALOG_STYLE_INPUT, "Bao cao nguoi choi - Hanh vi NonRP", "(Loi - Nguoi choi khong hop le) Nhap ten hoac ID nguoi choi.", "Nhap", "Huy");
			}
			else if(Player == playerid) {
				SendClientMessage(playerid, COLOR_GREY, "Ban khong the bao cao chinh minh.");
			}
			else {
				SetPVarInt(playerid, "NRPB", Player);
				ShowPlayerDialogEx(playerid, DIALOG_REPORTNRPB2, DIALOG_STYLE_INPUT,"Bao cao nguoi choi - Hanh vi NonRP","Mo ta hanh vi cua nguoi do.","Gui","Huy");
			}
		}
	}
	else if(dialogid == DIALOG_REPORTNRPB2)
	{
		if(response == 1 && !GetPVarType(playerid, "HasReport"))
		{
			if(isnull(inputtext)) return ShowPlayerDialogEx(playerid, DIALOG_REPORTNRPB2, DIALOG_STYLE_INPUT,"Bao cao nguoi choi - Hanh vi NonRP","Mo ta hanh vi cua nguoi do.","Gui","Huy");

			new
				Message[128],
				Player;

			Player = GetPVarInt(playerid, "NRPB");
			SetPVarInt(playerid, "_rAutoM", 5);
			SetPVarInt(playerid, "_rRepID", Player);
			format(Message, sizeof(Message), "%s(%i), %s (hanh vi nonrp)", GetPlayerNameEx(Player), Player, inputtext);
			SendReportToQue(playerid, Message, 2, GetPlayerPriority(playerid));
			SendClientMessageEx(playerid, COLOR_WHITE, "Da bao cao %s vi Hanh vi NonRP. Da gui den Admin dang online.", GetPlayerNameEx(Player));
			DeletePVar(playerid, "NRPB");
			SetPVarInt(playerid, "AlertedThisPlayer", Player);
			SetPVarInt(playerid, "AlertType", 11);
			AlertTime[playerid] = 300;
		}
		else {
			DeletePVar(playerid, "NRPB");
		}
	}
	else if(dialogid == DIALOG_REPORTFREE)
	{
		if(response == 1 && !GetPVarType(playerid, "HasReport"))
		{
			if(isnull(inputtext)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTFREE, DIALOG_STYLE_INPUT,"Khac / Tu nhap","(Loi - Chua nhap noi dung) Nhap noi dung muon gui den doi ngu Admin.","Gui","Huy");
			}

			SendReportToQue(playerid, inputtext, 2, GetPlayerPriority(playerid));
			SendClientMessageEx(playerid, COLOR_WHITE, "Da gui tin nhan den doi ngu Admin.");
		}
	}
	else if(dialogid == DIALOG_REPORTNOTLIST)
	{
		if(response == 1 && !GetPVarType(playerid, "HasReport"))
		{
			if(isnull(inputtext)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTNOTLIST, DIALOG_STYLE_INPUT,"Khong co trong danh sach","(Loi - Chua nhap noi dung) Muc nay se duoc Admin phan hoi cham hon. Hay chon muc phu hop nhat de duoc xu ly som","Gui","Huy");
			}

			SetPVarString(playerid, "ReportNotList", inputtext);

			ShowPlayerDialogEx(playerid, DIALOG_REPORTNOTLIST2, DIALOG_STYLE_MSGBOX, "Khong co trong danh sach", "Ban chac bao cao khong thuoc bat ky muc nao khac?", "Co", "Khong");
		}
	}
	else if(dialogid == DIALOG_REPORTNOTLIST2)
	{
		if(response == 1 && !GetPVarType(playerid, "HasReport"))
		{
			new Message[128];

			GetPVarString(playerid, "ReportNotList", Message, sizeof(Message));
			SendReportToQue(playerid, Message, 2, 5);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da gui tin nhan den doi ngu Admin.");
		}
	}
	else if(dialogid == DIALOG_SPEAKTOADMIN)
	{
		if(response == 1)
		{
			if(isnull(inputtext)) {
				ShowPlayerDialogEx(playerid, DIALOG_REPORTNOTLIST, DIALOG_STYLE_INPUT,"Khac / Tu nhap","(Loi - Khong co noi dung) Muc nay se duoc admin tra loi cham hon, hay chon muc phu hop nhat de duoc ho tro nhanh hon","Gui","Huy");
			}

			SetPVarString(playerid, "ReportNotList", inputtext);

			ShowPlayerDialogEx(playerid, DIALOG_REPORTNOTLIST2, DIALOG_STYLE_MSGBOX, "Khac / Tu nhap", "Ban chac chan can lien he admin?", "Co", "Khong");
		}
	}
	else if(dialogid == DIALOG_REPORTNAME)
	{
		new
			Player;

		Player = GetPVarInt(playerid, "NameChange");

		if(GetPVarInt(Player, "RequestingNameChange") == 0)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong co yeu cau doi ten!");
			return 1;
		}
		if(response == 1)
		{
			new newname[MAX_PLAYER_NAME], tmpName[24];
			GetPVarString(Player, "NewNameRequest", newname, MAX_PLAYER_NAME);
			mysql_escape_string(newname, tmpName);
			SetPVarString(Player, "NewNameRequest", tmpName);

			mysql_format(MainPipeline, string, sizeof(string), "SELECT `Username` FROM `accounts` WHERE `Username`='%s'", tmpName);
			mysql_tquery(MainPipeline, string, "OnApproveName", "ii", playerid, Player);

		}
		else
		{
			SendClientMessageEx(Player,COLOR_YELLOW," Yeu cau doi ten cua ban da bi tu choi.");
			SendClientMessageEx(playerid,COLOR_YELLOW," Ban da tu choi yeu cau doi ten cua %s.", GetPlayerNameEx(Player));
			format(string, sizeof(string), "%s da tu choi yeu cau doi ten cua %s",GetPlayerNameEx(playerid),GetPlayerNameEx(Player));
			ABroadCast(COLOR_YELLOW, string, 3);
			SetPVarInt(Player, "LastNameChange", gettime());
			DeletePVar(Player, "RequestingNameChange");
		}
	}
	else if(dialogid == DIALOG_REPORTTEAMNAME)
	{
		new
			Player;

		Player = GetPVarInt(playerid, "RFLNameChange");

		if(GetPVarInt(Player, "RFLNameRequest") == 0)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong co yeu cau doi ten!");
			return 1;
		}
		if(response == 1)
		{
			new newname[25], tmpName[25], query[128];
			GetPVarString(Player, "NewRFLName", newname, MAX_PLAYER_NAME);
			mysql_escape_string(newname, tmpName);
			SetPVarString(Player, "NewRFLName", tmpName);
			mysql_format(MainPipeline, query, sizeof(query), "SELECT `name` FROM `rflteams` WHERE `name` = '%s'", tmpName);
			mysql_tquery(MainPipeline, query, "OnCheckRFLName", "ii", playerid, Player);
		}
		else
		{
			SendClientMessageEx(Player,COLOR_YELLOW," Yeu cau doi ten doi cua ban da bi tu choi.");
			SendClientMessageEx(playerid,COLOR_YELLOW," Ban da tu choi yeu cau doi ten doi cua %s.", GetPlayerNameEx(Player));
			format(string, sizeof(string), "%s da tu choi yeu cau doi ten doi cua %s",GetPlayerNameEx(playerid),GetPlayerNameEx(Player));
			ABroadCast(COLOR_YELLOW, string, 3);
			DeletePVar(Player, "RFLNameRequest");
			DeletePVar(playerid, "RFLNameChange");
			DeletePVar(Player, "NewRFLName");
		}
	}
	else if(dialogid == DIALOG_DEDICATEDPLAYER)
	{
		if(response)
		{
			new
				szName[MAX_PLAYER_NAME],
				szDialogStr[260],
				szFileStr[32],
				iPos,
				iCount = 0,
				iTime = gettime() - 5184000,
				File: fDedicated = fopen("RewardDedicated.cfg", io_read);

			GetPVarString(playerid, "DedicatedPlayer", szName, sizeof(szName));

			while(fread(fDedicated, szFileStr)) {
				iPos = strfind(szFileStr, "|");

				if(strval(szFileStr[iPos + 1]) > iTime && iCount == 0 && strcmp(szFileStr, szName, false, strlen(szName))==0 ) {
					szFileStr[iPos] = 0;
					strcat(szDialogStr, szFileStr);
					iCount++;

					strcat(szDialogStr, "\n");
				}
				else if(iCount > 0)
				{
					szFileStr[iPos] = 0;
					strcat(szDialogStr, szFileStr);
					iCount++;
					if(iCount == 10) {
						SetPVarString(playerid, "DedicatedPlayer", szFileStr);
						printf("%s - Dedicated Player", szFileStr);
						break;
					}
					strcat(szDialogStr, "\n");
				}
			}
			fclose(fDedicated);
			//szDialogStr[strlen(szDialogStr) - 1] = 0;
			if(iCount == 10)
			{
				ShowPlayerDialogEx(playerid, DIALOG_DEDICATEDPLAYER, DIALOG_STYLE_LIST, "Dedicated Players (tren 150 Reward Hours)", szDialogStr, "Tiep", "Thoat");
			}
			else
			{
				ShowPlayerDialogEx(playerid, 0, DIALOG_STYLE_LIST, "Dedicated Players (tren 150 Reward Hours)", szDialogStr, "Thoat", "");
			}
			return 1;
		}
	}

	else if (dialogid == DIALOG_POSTAMP && response)
	{

		switch (listitem) {
			case REGULAR_MAIL: {
				SetPVarInt(playerid, "LetterTime", 240);
				SetPVarInt(playerid, "LetterCost", 100);
			}
			case PRIORITY_MAIL: {
				SetPVarInt(playerid, "LetterTime", 120);
				SetPVarInt(playerid, "LetterCost", 250);
			}
			case PREMIUM_MAIL: {
				if (PlayerInfo[playerid][pDonateRank] < 3) {
					return SendClientMessageEx(playerid, COLOR_GREY, "Can tu Gold VIP tro len de gui thu cao cap.");
				}
				else {
					SetPVarInt(playerid, "LetterCost", 500);
					SetPVarInt(playerid, "LetterNotify", 1);
				}
			}
			case GOVERNMENT_MAIL:  {
				if (!IsAGovernment(playerid) && !IsACop(playerid) && !IsAJudge(playerid)) {
					return SendClientMessageEx(playerid, COLOR_GREY, "Chi co quan Government duoc gui thu cong vu!");
				}
				if (PlayerInfo[playerid][pRank] < 4) {
					return SendClientMessageEx(playerid, COLOR_GREY, "Can cap bac tu 4 tro len.");
				}
				SetPVarInt(playerid, "LetterTime", 60);
				SetPVarInt(playerid, "LetterCost", 500);
				SetPVarInt(playerid, "LetterNotify", 1);
				SetPVarInt(playerid, "LetterGov", 1);
			}
			default:
				return 1;
		}

		if (listitem != GOVERNMENT_MAIL && GetPlayerCash(playerid) < GetPVarInt(playerid, "LetterCost")) {
			DeletePVar(playerid, "LetterTime");
			DeletePVar(playerid, "LetterCost");
			return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien mua tem.");
		}

		ShowPlayerDialogEx(playerid, DIALOG_PORECEIVER, DIALOG_STYLE_INPUT, "Nguoi nhan", "{FFFFFF}Nhap ten nguoi nhan (online hoac offline)", "Tiep", "Huy");

		return 1;

	}

	else if (dialogid == DIALOG_PORECEIVER && response)
	{

		if (!strlen(inputtext)) {
			ShowPlayerDialogEx(playerid, DIALOG_PORECEIVER, DIALOG_STYLE_INPUT, "Nguoi nhan", "{FF3333}Loi: {FFFFFF}Chua nhap ten nguoi nhan!\n\nNhap ten nguoi nhan (online hoac offline)", "Tiep", "Huy");
			return 1;
		}

		if (strlen(inputtext) > 20) {
			ShowPlayerDialogEx(playerid, DIALOG_PORECEIVER, DIALOG_STYLE_INPUT, "Nguoi nhan", "{FF3333}Loi: {FFFFFF}Ten nguoi nhan qua dai!\n\nNhap ten nguoi nhan (online hoac offline)", "Tiep", "Huy");
			return 1;
		}

		if (strcmp(inputtext, GetPlayerNameExt(playerid), true) == 0) {
			ShowPlayerDialogEx(playerid, DIALOG_PORECEIVER, DIALOG_STYLE_INPUT, "Nguoi nhan", "{FF3333}Loi: {FFFFFF}Khong the gui thu cho chinh minh!\n\nNhap ten nguoi nhan (online hoac offline)", "Tiep", "Huy");
			return 1;
		}

		SetPVarString(playerid, "LetterRecipientName", inputtext);

		new giveplayer = ReturnUser(inputtext);
		if(giveplayer == INVALID_PLAYER_ID)
		{
			new szQuery[256];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "SELECT `id`, `AdminLevel`, `TogReports` FROM `accounts` WHERE `Username` = '%e'", inputtext);
			mysql_tquery(MainPipeline, szQuery, "RecipientLookupFinish", "i", playerid);
		}
		else
		{
			if(PlayerInfo[giveplayer][pAdmin] >= 2 && PlayerInfo[giveplayer][pTogReports] != 1)
			{
				ShowPlayerDialogEx(playerid, DIALOG_PORECEIVER, DIALOG_STYLE_INPUT, "Nguoi nhan", "{FF3333}Loi: {FFFFFF}Khong the gui thu cho Admin!\n\nNhap ten nguoi nhan (online hoac offline)", "Tiep", "Huy");
			}
			else
			{
				SetPVarInt(playerid, "LetterRecipient", GetPlayerSQLId(giveplayer));
				ShowPlayerDialogEx(playerid, DIALOG_POMESSAGE, DIALOG_STYLE_INPUT, "Gui thu", "{FFFFFF}Hay nhap noi dung thu.", "Gui", "Huy");
			}
		}
		return 1;
	}

	else if (dialogid == DIALOG_POMESSAGE && response)
	{

		if (PlayerInfo[playerid][pAdmin] < 2 && CheckServerAd(inputtext)) {
			format(string,sizeof(string),"Canh bao: %s co the quang cao may chu qua thu: '%s'.", GetPlayerNameEx(playerid),inputtext);
			ABroadCast(COLOR_RED, string, 2);
			format(string,sizeof(string),"Warning: %s(%d) may be server advertising via mail: '%s'.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), inputtext);
			Log("logs/hack.log", string);
			return 1;
		}

		new query[512], rec[MAX_PLAYER_NAME];

		if (strlen(inputtext) == 0) {
			ShowPlayerDialogEx(playerid, DIALOG_POMESSAGE, DIALOG_STYLE_INPUT, "Gui thu", "{FF3333}Loi: {FFFFFF}Chua nhap noi dung thu!\n\nHay nhap noi dung thu.", "Gui", "Huy");
			return 1;
		}
		if (strlen(inputtext) > 128) return 1; // Apparently not possible, but just in case

		if (!GetPVarType(playerid, "LetterGov")) {
			if (GetPlayerCash(playerid) < GetPVarInt(playerid, "LetterCost")) {
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien mua tem.");
			}
			GivePlayerCash(playerid, -GetPVarInt(playerid, "LetterCost"));
		}
		else {
			DeletePVar(playerid, "LetterGov");
			if (Tax < 500) return SendClientMessageEx(playerid, COLOR_WHITE, "Quy chinh phu khong du tien mua tem.");
			Tax -= 500;
			Misc_Save();
		}

		mysql_format(MainPipeline, query,sizeof(query),	"INSERT INTO `letters` (`Sender_Id`, `Receiver_Id`, `Date`, `Message`, `Delivery_Min`, `Notify`) VALUES (%d, %d, NOW(), '%e', %d, %d)", GetPlayerSQLId(playerid), GetPVarInt(playerid, "LetterRecipient"), inputtext, GetPVarInt(playerid, "LetterTime"), GetPVarInt(playerid, "LetterNotify"));
		mysql_tquery(MainPipeline, query, "OnQueryFinish", "ii", SENDDATA_THREAD, playerid);

		GetPVarString(playerid, "LetterRecipientName", rec, MAX_PLAYER_NAME);
		if (GetPVarInt(playerid, "LetterTime") == 0)
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Da gui thu. Thu se duoc giao ngay.");
			new xid=ReturnUser(rec);
			if (xid != INVALID_PLAYER_ID)
			{
				if (PlayerInfo[xid][pDonateRank] >= 4 && HasMailbox(xid))
				{
					SendClientMessageEx(xid, COLOR_YELLOW, "Vua co thu duoc giao den hop thu cua ban.");
					SetPVarInt(xid, "UnreadMails", 1);
				}
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Da gui thu. Thu se den sau %d gio.", GetPVarInt(playerid, "LetterTime") / 60);
		}

		PlayerInfo[playerid][pPaper]--;
		DeletePVar(playerid, "LetterCost");
		DeletePVar(playerid, "LetterTime");
		DeletePVar(playerid, "LetterRecipient");
		DeletePVar(playerid, "LetterNotify");
		SetPVarInt(playerid, "MailTime", 30);

		new szLog[256];
		format(szLog, sizeof(szLog), "%s(%d) has sent mail to %s: %s", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), rec, inputtext);
		Log("logs/mail.log", szLog);

		return 1;

	}

	else if (dialogid == DIALOG_POMAILS && response)
	{
		SetPVarInt(playerid, "ReadingMail", ListItemTrackId[playerid][listitem]);
		DisplayMailDetails(playerid, ListItemTrackId[playerid][listitem]);
	}

	else if (dialogid == DIALOG_PODETAIL)
	{

		if (response) // Back
		{
			DisplayMails(playerid);
		}
		else // Trash
		{
			new query[64];
			mysql_format(MainPipeline, query, sizeof(query), "DELETE FROM `letters` WHERE `ID` = %i", GetPVarInt(playerid, "ReadingMail"));
			mysql_tquery(MainPipeline, query, "OnQueryFinish", "i", SENDDATA_THREAD);
			ShowPlayerDialogEx(playerid, DIALOG_POTRASHED, DIALOG_STYLE_MSGBOX, "Thong tin", "Ban da bo thu vao thung rac.", "Quay lai", "Dong");
		}
		DeletePVar(playerid, "ReadingMail");
		return 1;
	}

	else if (dialogid == DIALOG_POTRASHED && response)
	{

		DisplayMails(playerid);
		return 1;

	}

	else if (dialogid == DIALOG_STOREPRICES)
	{
		if (!response || (GetPVarInt(playerid, "EditingBusiness") != PlayerInfo[playerid][pBusiness]) || (GetPVarInt(playerid, "EditingBusiness") != InBusiness(playerid)) || PlayerInfo[playerid][pBusinessRank] != 5) {
			DeletePVar(playerid, "EditingBusiness");
		}
		else {
			strunpack(storeItemName, StoreItems[listitem], sizeof(storeItemName));
			format(string, sizeof(string), "{FFFFFF}Nhap gia ban moi cho %s\n(Vat pham gia $0 se khong duoc ban)", storeItemName);
			ShowPlayerDialogEx(playerid, DIALOG_STOREITEMPRICE, DIALOG_STYLE_INPUT, "Sua gia", string, "Dong y", "Huy");
			SetPVarInt(playerid, "EditingStoreItem", listitem);
		}
		return 1;
	}

	else if (dialogid == DIALOG_BARPRICE)
	{
		if (!response || (GetPVarInt(playerid, "EditingBusiness") != PlayerInfo[playerid][pBusiness]) || (GetPVarInt(playerid, "EditingBusiness") != InBusiness(playerid)) || PlayerInfo[playerid][pBusinessRank] != 5) {
			DeletePVar(playerid, "EditingBusiness");
		}
		else {
			strunpack(drinkName, Drinks[listitem], sizeof(drinkName));
			format(string, sizeof(string), "{FFFFFF}Nhap gia ban moi cho %s\n(Vat pham gia $0 se khong duoc ban)", drinkName);
			ShowPlayerDialogEx(playerid, DIALOG_BARPRICE2, DIALOG_STYLE_INPUT, "Sua gia", string, "Dong y", "Huy");
			SetPVarInt(playerid, "EditingStoreItem", listitem);
		}
		return 1;
	}
	else if(dialogid == DIALOG_SEXSHOP)
	{
		if (!response || (GetPVarInt(playerid, "EditingBusiness") != PlayerInfo[playerid][pBusiness]) || (GetPVarInt(playerid, "EditingBusiness") != InBusiness(playerid)) || PlayerInfo[playerid][pBusinessRank] != 5) {
			DeletePVar(playerid, "EditingBusiness");
		}
		else {
			strunpack(drinkName, Drinks[listitem], sizeof(drinkName));
			format(string, sizeof(string), "{FFFFFF}Nhap gia ban moi cho %s\n(Vat pham gia $0 se khong duoc ban)", drinkName);
			ShowPlayerDialogEx(playerid, DIALOG_SEXSHOP2, DIALOG_STYLE_INPUT, "Sua gia", string, "Dong y", "Huy");
			SetPVarInt(playerid, "EditingStoreItem", listitem);
		}
		return 1;
	}
	else if (dialogid == DIALOG_RESTAURANT)
	{
		if (!response || (GetPVarInt(playerid, "EditingBusiness") != PlayerInfo[playerid][pBusiness]) || (GetPVarInt(playerid, "EditingBusiness") != InBusiness(playerid)) || PlayerInfo[playerid][pBusinessRank] != 5)
		{
			DeletePVar(playerid, "EditingBusiness");
		}
		else
		{
			strunpack(restaurantItemName, RestaurantItems[listitem], sizeof(restaurantItemName));
			format(string, sizeof(string), "{FFFFFF}Nhap gia ban moi cho %s\n(Vat pham gia $0 se khong duoc ban)", restaurantItemName);
			ShowPlayerDialogEx(playerid, DIALOG_RESTAURANT2, DIALOG_STYLE_INPUT, "Sua gia", string, "Dong y", "Huy");
			SetPVarInt(playerid, "EditingStoreItem", listitem);
		}
	}
	else if (dialogid == DIALOG_SEXSHOP2)
	{

		if (PlayerInfo[playerid][pBusiness] != GetPVarInt(playerid, "EditingBusiness") || (GetPVarInt(playerid, "EditingBusiness") != InBusiness(playerid)) || PlayerInfo[playerid][pBusinessRank] != 5) {
			DeletePVar(playerid, "EditingStoreItem");
			DeletePVar(playerid, "EditingBusiness");
			return 1;
		}

		new iBusiness = PlayerInfo[playerid][pBusiness];

		if (response) {
			new sexItemName[15];
			new iPrice = strval(inputtext), item = GetPVarInt(playerid, "EditingStoreItem");

			if (iPrice < 0 || iPrice > 500000) {
				strunpack(drinkName, Drinks[item], sizeof(drinkName));
				format(string, sizeof(string), "{FF0000}Loi: {DDDDDD}Gia vuot gioi han{FFFFFF}\n\nNhap gia ban moi cho %s", drinkName);
				ShowPlayerDialogEx(playerid, DIALOG_STOREITEMPRICE, DIALOG_STYLE_INPUT, "Sua gia", string, "Dong y", "Huy");
				return 1;
			}

			strunpack(sexItemName, SexItems[item], sizeof(sexItemName));
			format(string,sizeof(string), "Da dat gia %s la $%s!", sexItemName, number_format(iPrice));
			Businesses[iBusiness][bItemPrices][item] = iPrice;
			SaveBusiness(iBusiness);
			SendClientMessageEx(playerid, COLOR_WHITE, string);
			strunpack(sexItemName, SexItems[item], sizeof(sexItemName));
			format(string, sizeof(string), "%s %s(%d) (IP: %s) has set the %s price to %s in %s ($%d)", GetBusinessRankName(PlayerInfo[playerid][pBusinessRank]), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), sexItemName, number_format(iPrice), Businesses[iBusiness][bName], iBusiness);
			new szDialog[302];
			for (new i = 0; i < sizeof(SexItems); i++) {
				strunpack(sexItemName, SexItems[i], sizeof(sexItemName));
				format(szDialog, sizeof(szDialog), "%s%s  ($%s)\n", szDialog, sexItemName, number_format(Businesses[iBusiness][bItemPrices][i]));
			}
			ShowPlayerDialogEx(playerid, DIALOG_BARPRICE, DIALOG_STYLE_LIST, "Sua gia doanh nghiep", szDialog, "Dong y", "Huy");
			Log("logs/business.log", string);
		}
		DeletePVar(playerid, "EditingStoreItem");
		return 1;
	}
	else if (dialogid == DIALOG_RESTAURANT2)
	{
		if (PlayerInfo[playerid][pBusiness] != GetPVarInt(playerid, "EditingBusiness") || (GetPVarInt(playerid, "EditingBusiness") != InBusiness(playerid)) || PlayerInfo[playerid][pBusinessRank] != 5)
		{
			DeletePVar(playerid, "EditingStoreItem");
			DeletePVar(playerid, "EditingBusiness");
			return 1;
		}

		new business = PlayerInfo[playerid][pBusiness];

		if (response)
		{
			new price = strval(inputtext), item = GetPVarInt(playerid, "EditingStoreItem");

			if (price < 0 || price > 500000)
			{
				strunpack(restaurantItemName, RestaurantItems[item], sizeof(restaurantItemName));
				format(string, sizeof(string), "{FF0000}Loi: {DDDDDD}Gia vuot gioi han{FFFFFF}\n\nNhap gia ban moi cho %s", restaurantItemName);
				ShowPlayerDialogEx(playerid, DIALOG_RESTAURANT2, DIALOG_STYLE_INPUT, "Sua gia", string, "Dong y", "Huy");
				return 1;
			}

			strunpack(restaurantItemName, RestaurantItems[item], sizeof(restaurantItemName));
			format(string,sizeof(string), "Da dat gia %s la $%s!", restaurantItemName, number_format(price));
			Businesses[business][bItemPrices][item] = price;
			SaveBusiness(business);
			SendClientMessageEx(playerid, COLOR_WHITE, string);
			strunpack(restaurantItemName, RestaurantItems[item], sizeof(restaurantItemName));
			format(string, sizeof(string), "%s %s(%d) (IP: %s) has set the %s price to %s in %s ($%d)", GetBusinessRankName(PlayerInfo[playerid][pBusinessRank]), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), restaurantItemName, number_format(price), Businesses[business][bName], business);
			new szDialog[302];
			for (new i = 0; i < sizeof(RestaurantItems); i++) {
				strunpack(restaurantItemName, RestaurantItems[i], sizeof(restaurantItemName));
				format(szDialog, sizeof(szDialog), "%s%s  ($%s)\n", szDialog, restaurantItemName, number_format(Businesses[business][bItemPrices][i]));
			}
			ShowPlayerDialogEx(playerid, DIALOG_RESTAURANT, DIALOG_STYLE_LIST, "Sua gia doanh nghiep", szDialog, "Dong y", "Huy");
			Log("logs/business.log", string);
		}

		DeletePVar(playerid, "EditingStoreItem");
		return 1;
	}
	else if (dialogid == DIALOG_BARPRICE2)
	{

		if (PlayerInfo[playerid][pBusiness] != GetPVarInt(playerid, "EditingBusiness") || (GetPVarInt(playerid, "EditingBusiness") != InBusiness(playerid)) || PlayerInfo[playerid][pBusinessRank] != 5) {
			DeletePVar(playerid, "EditingStoreItem");
			DeletePVar(playerid, "EditingBusiness");
			return 1;
		}

		new iBusiness = PlayerInfo[playerid][pBusiness];

		if (response) {
			new iPrice = strval(inputtext), item = GetPVarInt(playerid, "EditingStoreItem");

			if (iPrice < 0 || iPrice > 500000) {
				strunpack(drinkName, Drinks[item], sizeof(drinkName));
				format(string, sizeof(string), "{FF0000}Loi: {DDDDDD}Gia vuot gioi han{FFFFFF}\n\nNhap gia ban moi cho %s", drinkName);
				ShowPlayerDialogEx(playerid, DIALOG_STOREITEMPRICE, DIALOG_STYLE_INPUT, "Sua gia", string, "Dong y", "Huy");
				return 1;
			}

			strunpack(drinkName, Drinks[item], sizeof(drinkName));
			format(string,sizeof(string), "Da dat gia %s la $%s!", drinkName, number_format(iPrice));
			Businesses[iBusiness][bItemPrices][item] = iPrice;
			SaveBusiness(iBusiness);
			SendClientMessageEx(playerid, COLOR_WHITE, string);
			strunpack(drinkName, Drinks[item], sizeof(drinkName));
			format(string, sizeof(string), "%s %s(%d) (IP: %s) has set the %s price to $%s in %s (%d)", GetBusinessRankName(PlayerInfo[playerid][pBusinessRank]), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), drinkName, number_format(iPrice), Businesses[iBusiness][bName], iBusiness);
			new szDialog[302];
			for (new i = 0; i < sizeof(Drinks); i++) {
				strunpack(drinkName, Drinks[i], sizeof(drinkName));
				format(szDialog, sizeof(szDialog), "%s%s  ($%s)\n", szDialog, drinkName, number_format(Businesses[iBusiness][bItemPrices][i]));
			}
			ShowPlayerDialogEx(playerid, DIALOG_BARPRICE, DIALOG_STYLE_LIST, "Sua gia doanh nghiep", szDialog, "Dong y", "Huy");
			Log("logs/business.log", string);
		}
		DeletePVar(playerid, "EditingStoreItem");
		return 1;
	}
	else if (dialogid == DIALOG_STOREITEMPRICE)
	{

		if (PlayerInfo[playerid][pBusiness] != GetPVarInt(playerid, "EditingBusiness") || (GetPVarInt(playerid, "EditingBusiness") != InBusiness(playerid)) || PlayerInfo[playerid][pBusinessRank] != 5) {
			DeletePVar(playerid, "EditingStoreItem");
			DeletePVar(playerid, "EditingBusiness");
			return 1;
		}

		new iBusiness = PlayerInfo[playerid][pBusiness];

		if (response) {
			new iPrice = strval(inputtext), item = GetPVarInt(playerid, "EditingStoreItem");

			if (iPrice < 0 || iPrice > 500000) {
				strunpack(storeItemName, StoreItems[item], sizeof(storeItemName));
				format(string, sizeof(string), "{FF0000}Loi: {DDDDDD}Gia vuot gioi han{FFFFFF}\n\nNhap gia ban moi cho %s", storeItemName);
				ShowPlayerDialogEx(playerid, DIALOG_STOREITEMPRICE, DIALOG_STYLE_INPUT, "Sua gia", string, "Dong y", "Huy");
				return 1;
			}

			strunpack(storeItemName, StoreItems[item], sizeof(storeItemName));
			format(string,sizeof(string), "Da dat gia %s la $%s!", storeItemName, number_format(iPrice));
			Businesses[iBusiness][bItemPrices][item] = iPrice;
			SaveBusiness(iBusiness);
			SendClientMessageEx(playerid, COLOR_WHITE, string);
			strunpack(storeItemName, StoreItems[item], sizeof(storeItemName));
			format(string, sizeof(string), "%s %s(%d) (IP: %s) has set the %s price to $%s in %s (%d)", GetBusinessRankName(PlayerInfo[playerid][pBusinessRank]), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), storeItemName, number_format(iPrice), Businesses[iBusiness][bName], iBusiness);
			new szDialog[912];
			for (new i = 0; i < sizeof(StoreItems); i++) {
				strunpack(storeItemName, StoreItems[i], sizeof(storeItemName));
				format(szDialog, sizeof(szDialog), "%s%s  ($%s) (Gia von: $%s)\n", szDialog, storeItemName, number_format(Businesses[iBusiness][bItemPrices][i]), number_format(floatround(StoreItemCost[i][ItemValue] * BUSINESS_ITEMS_COST)));
			}
			ShowPlayerDialogEx(playerid, DIALOG_STOREPRICES, DIALOG_STYLE_LIST, "Sua gia 24/7", szDialog, "Dong y", "Huy");
			Log("logs/business.log", string);
		}
		DeletePVar(playerid, "EditingStoreItem");
		return 1;
	}
	else if(dialogid == DIALOG_STORECLOTHINGPRICE)
	{
		new iBusiness = PlayerInfo[playerid][pBusiness];

		if (PlayerInfo[playerid][pBusiness] != GetPVarInt(playerid, "EditingBusiness") || (GetPVarInt(playerid, "EditingBusiness") != InBusiness(playerid)) || PlayerInfo[playerid][pBusinessRank] != 5) {
			DeletePVar(playerid, "EditingStoreItem");
			DeletePVar(playerid, "EditingBusiness");
			return 1;
		}

		if (response) {
			new iPrice = strval(inputtext);

			if (iPrice < 0 || iPrice > 500000) {
				ShowPlayerDialogEx(playerid, DIALOG_STORECLOTHINGPRICE, DIALOG_STYLE_INPUT, "Sua gia", "{FF0000}Loi: {DDDDDD}Gia vuot gioi han{FFFFFF}\n\nNhap gia ban quan ao moi", "Dong y", "Huy");
				return 1;
			}

			format(string,sizeof(string), "Da dat gia quan ao la $%s!", number_format(iPrice));
			Businesses[iBusiness][bItemPrices][0] = iPrice;
			SaveBusiness(iBusiness);
			SendClientMessageEx(playerid, COLOR_WHITE, string);
			format(string, sizeof(string), "%s %s(%d) (IP: %s) has set the %s price to $%s in %s (%d)", GetBusinessRankName(PlayerInfo[playerid][pBusinessRank]), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), "clothing", number_format(iPrice), Businesses[iBusiness][bName], iBusiness);
			Log("logs/business.log", string);
		}

		DeletePVar(playerid, "EditingStoreItem");
	}
	else if (dialogid == DIALOG_GUNPRICES)
	{
		if (!response || (GetPVarInt(playerid, "EditingBusiness") != PlayerInfo[playerid][pBusiness]) || (GetPVarInt(playerid, "EditingBusiness") != InBusiness(playerid)) || PlayerInfo[playerid][pBusinessRank] != 5) {
			DeletePVar(playerid, "EditingBusiness");
		}
		else {
			format(string, sizeof(string), "{FFFFFF}Nhap gia ban moi cho %s\n(Vat pham gia $0 se khong duoc ban)", GetWeaponNameEx(Weapons[listitem][WeaponId]));
			ShowPlayerDialogEx(playerid, DIALOG_GUNSHOPPRICE, DIALOG_STYLE_INPUT, "Sua gia", string, "Dong y", "Huy");
			SetPVarInt(playerid, "EditingStoreItem", listitem);
		}
		return 1;
	}
	else if(dialogid == DIALOG_GUNSHOPPRICE)
	{
		if (PlayerInfo[playerid][pBusiness] != GetPVarInt(playerid, "EditingBusiness") || (GetPVarInt(playerid, "EditingBusiness") != InBusiness(playerid)) || PlayerInfo[playerid][pBusinessRank] != 5) {
			DeletePVar(playerid, "EditingStoreItem");
			DeletePVar(playerid, "EditingBusiness");
			return 1;
		}

		new iBusiness = PlayerInfo[playerid][pBusiness];

		if (response) {
			new iPrice = strval(inputtext), item = GetPVarInt(playerid, "EditingStoreItem");

			if (iPrice < 0 || iPrice > 500000) {
				strunpack(storeItemName, StoreItems[item], sizeof(storeItemName));
				format(string, sizeof(string), "{FF0000}Loi: {DDDDDD}Gia vuot gioi han{FFFFFF}\n\nNhap gia ban moi cho %s", storeItemName);
				ShowPlayerDialogEx(playerid, DIALOG_GUNSHOPPRICE, DIALOG_STYLE_INPUT, "Sua gia", string, "Dong y", "Huy");
				return 1;
			}

			format(string,sizeof(string), "Da dat gia %s la $%s!", GetWeaponNameEx(Weapons[item][WeaponId]), number_format(iPrice));
			Businesses[iBusiness][bItemPrices][item] = iPrice;
			SaveBusiness(iBusiness);
			SendClientMessageEx(playerid, COLOR_WHITE, string);
			format(string, sizeof(string), "%s %s(%d) (IP: %s) has set the %s price to $%s in %s (%d)", GetBusinessRankName(PlayerInfo[playerid][pBusinessRank]), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), GetWeaponParam(item, WeaponId), number_format(iPrice), Businesses[iBusiness][bName], iBusiness);
			new szDialog[512];
			for (new i = 0; i < sizeof(Weapons); i++) format(szDialog, sizeof(szDialog), "%s%s  ($%s)\n", szDialog, GetWeaponNameEx(Weapons[i][WeaponId]), number_format(Businesses[iBusiness][bItemPrices][i]));
			ShowPlayerDialogEx(playerid, DIALOG_GUNPRICES, DIALOG_STYLE_LIST, "Sua gia cua hang sung", szDialog, "Dong y", "Huy");
			Log("logs/business.log", string);
		}
		DeletePVar(playerid, "EditingStoreItem");
		return 1;
	}
	else if (dialogid == DIALOG_GASPRICE)
	{
		if (!response || (GetPVarInt(playerid, "EditingBusiness") != PlayerInfo[playerid][pBusiness]) || PlayerInfo[playerid][pBusinessRank] != 5) {
		}
		else {
			new szSaleText[148], Float:price = floatstr(inputtext);
			if (price < 1 || price > 5000) return SendClientMessageEx(playerid, COLOR_WHITE, "Gia phai tu $1 den $5,000");
			Businesses[PlayerInfo[playerid][pBusiness]][bGasPrice] = price;
			for (new i; i < MAX_BUSINESS_GAS_PUMPS; i++)
			{
				format(szSaleText,sizeof(szSaleText),"Gia/gallon: $%.2f\nThanh tien: $%.2f\nSo gallon: %.3f\nCon lai: %.2f/%.2f gallon", price, Businesses[PlayerInfo[playerid][pBusiness]][GasPumpSalePrice][i], Businesses[PlayerInfo[playerid][pBusiness]][GasPumpSaleGallons][i], Businesses[PlayerInfo[playerid][pBusiness]][GasPumpGallons][i], Businesses[PlayerInfo[playerid][pBusiness]][GasPumpCapacity][i]);
				UpdateDynamic3DTextLabelText(Businesses[PlayerInfo[playerid][pBusiness]][GasPumpSaleTextID][i], COLOR_YELLOW, szSaleText);
			}
			SaveBusiness(PlayerInfo[playerid][pBusiness]);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da dat gia moi gallon la %.2f!", price);
			format(string, sizeof(string), "%s(%d) (IP: %s) has set the gas price to %f in %s", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), price, Businesses[PlayerInfo[playerid][pBusiness]][bName]);
			Log("logs/business.log", string);
		}
		DeletePVar(playerid, "EditingBusiness");
		return 1;
	}

	else if (dialogid == DIALOG_SWITCHGROUP && response)
	{

		if (!(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pFactionModerator] >= 1)) return 1;

		new
			iGroupID = listitem;

		if(arrGroupData[iGroupID][g_iGroupType] == GROUP_TYPE_CONTRACT) {
			return SendClientMessage(playerid, COLOR_WHITE, "Khong the dung lenh nay de doi sang Contract Agency.");
		}

		format(string, sizeof(string), "Ban da chuyen sang to chuc ID %d (%s).", iGroupID+1, arrGroupData[iGroupID][g_szGroupName]);
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, string);
		PlayerInfo[playerid][pMember] = iGroupID;
		PlayerInfo[playerid][pRank] = Group_GetMaxRank(iGroupID);
		PlayerInfo[playerid][pLeader] = -1;
	}

	else if (dialogid == DIALOG_MAKELEADER && response)
	{
		if (PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pFactionModerator] >= 2)
		{
			new
				iGroupID = listitem,
				iTargetID = GetPVarInt(playerid, "MakingLeader");

			if(!arrGroupData[iGroupID][g_szGroupName][0]) { return SendClientMessageEx(playerid, COLOR_GREY, "To chuc nay chua duoc thiet lap dung."); }

			PlayerInfo[iTargetID][pLeader] = iGroupID;
			PlayerInfo[iTargetID][pMember] = iGroupID;
			PlayerInfo[iTargetID][pRank] = Group_GetMaxRank(iGroupID);
			PlayerInfo[iTargetID][pDivision] = -1;
			SendClientMessageEx(iTargetID, COLOR_LIGHTBLUE, "Ban la lanh dao cua %s, do Administrator %s bo nhiem.", arrGroupData[iGroupID][g_szGroupName], GetPlayerNameEx(playerid));
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban da bo nhiem %s lam lanh dao %s.", GetPlayerNameEx(iTargetID), arrGroupData[iGroupID][g_szGroupName]);
			format(string, sizeof(string), "%s (%d) has made %s (%d) the leader of the %s.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID), arrGroupData[iGroupID][g_szGroupName]);
			GroupLog(iGroupID, string);
		}
		else SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen truy cap.");
	}
	else if (dialogid == DIALOG_HBADGE && response)
	{

		if (!IsAHitman(playerid)) return 1;

		new	iGroupID = listitem;

		if(!arrGroupData[iGroupID][g_szGroupName][0]) { return SendClientMessageEx(playerid, COLOR_GREY, "To chuc nay chua duoc thiet lap dung."); }

		switch(listitem)
		{
			case 0..20: {
				format(string, sizeof(string), "Ban da doi phu hieu thanh %s", arrGroupData[iGroupID][g_szGroupName]);
				SendClientMessageEx(playerid, COLOR_WHITE, string);
				SetPlayerColor(playerid, arrGroupData[iGroupID][g_hDutyColour] * 256);
				SetPVarInt(playerid, "HitmanBadgeColour", arrGroupData[iGroupID][g_hDutyColour] * 256);
			}
			default: {
				SendClientMessageEx(playerid, COLOR_GREY, "To chuc khong hop le.");
			}
		}
	}
	else if(dialogid == DIALOG_CDBUY)
	{
		// Account Eating Bug Fix
		if(!IsPlayerInAnyVehicle(playerid))
		{
			TogglePlayerControllable(playerid, true);
			SendClientMessageEx(playerid,COLOR_GRAD2,"Can o trong xe ban muon mua.");
			return 1;
		}

		new vehicleid = GetPlayerVehicleID(playerid);
		new playervehicleid = GetPlayerFreeVehicleId(playerid);
		new v = GetBusinessCarSlot(vehicleid);
		new d = GetCarBusiness(vehicleid);
		if(response)
		{
			if(!vehicleCountCheck(playerid))
			{
				TogglePlayerControllable(playerid, true);
 				RemovePlayerFromVehicle(playerid);
 				new Float:slx, Float:sly, Float:slz;
 				GetPlayerPos(playerid, slx, sly, slz);
 				SetPlayerPos(playerid, slx, sly, slz+1.2);
				return SendClientMessageEx(playerid, COLOR_GREY, "LOI: Khong the so huu them xe. Co the mua them o chua xe qua /vstorage.");
			}

			if(Businesses[d][bPurchaseX] == 0.0 && Businesses[d][bPurchaseY] == 0.0 && Businesses[d][bPurchaseZ] == 0.0)
			{
				SendClientMessageEx(playerid, COLOR_GRAD1, "LOI: Chu dai ly chua dat vi tri xuat hien xe sau khi mua.");
				RemovePlayerFromVehicle(playerid);
				new Float:slx, Float:sly, Float:slz;
				GetPlayerPos(playerid, slx, sly, slz);
				SetPlayerPos(playerid, slx, sly, slz+1.2);
				TogglePlayerControllable(playerid, true);
				return 1;
			}

			new randcolor1 = random(126);
			new randcolor2 = random(126);
			SetPlayerPos(playerid, Businesses[d][bParkPosX][v], Businesses[d][bParkPosY][v], Businesses[d][bParkPosZ][v]+2);
			TogglePlayerControllable(playerid, true);
			new cost;
			if(PlayerInfo[playerid][pDonateRank] < 1)
			{
				cost = Businesses[d][bPrice][v];
				if(PlayerInfo[playerid][pCash] < cost)
				{
					SendClientMessageEx(playerid, COLOR_GRAD1, "LOI: Ban khong du tien mua xe nay.");
					RemovePlayerFromVehicle(playerid);
					new Float:slx, Float:sly, Float:slz;
					GetPlayerPos(playerid, slx, sly, slz);
					SetPlayerPos(playerid, slx, sly, slz+1.2);
					return 1;
				}

				SendClientMessageEx(playerid, COLOR_GRAD1, " Cam on ban da mua tai %s.", Businesses[d][bName]);
				PlayerInfo[playerid][pCash] -= cost;
				cost = Businesses[d][bPrice][v] / 100 * 15;
				Businesses[d][bSafeBalance] += TaxSale( cost );
			}
			else
			{
				cost = Businesses[d][bPrice][v];
				if(PlayerInfo[playerid][pCash] < cost)
				{
					SendClientMessageEx(playerid, COLOR_GRAD1, "LOI: Ban khong du tien mua xe nay.");
					RemovePlayerFromVehicle(playerid);
					new Float:slx, Float:sly, Float:slz;
					GetPlayerPos(playerid, slx, sly, slz);
					SetPlayerPos(playerid, slx, sly, slz+1.2);
					return 1;
				}

				SendClientMessageEx(playerid, COLOR_GRAD1, " Cam on ban da mua tai %s.",Businesses[d][bName]);
				PlayerInfo[playerid][pCash] -= cost;
				cost = Businesses[d][bPrice][v] / 100 * 15;
				Businesses[d][bSafeBalance] += TaxSale( cost );
			}
			if(PlayerInfo[playerid][pTut] == 15)
			{
				PlayerInfo[playerid][pCarLic] = gettime() + (86400); // temp 1 day license
				PlayerInfo[playerid][pTut]++;
				AdvanceTutorial(playerid);
			}
			Businesses[d][bInventory]--;
			Businesses[d][bTotalSales]++;
			IsPlayerEntering{playerid} = true;
			new car = CreatePlayerVehicle(playerid, playervehicleid, Businesses[d][bModel][v], Businesses[d][bPurchaseX], Businesses[d][bPurchaseY], Businesses[d][bPurchaseZ], Businesses[d][bPurchaseAngle], randcolor1, randcolor2, cost, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
			PutPlayerInVehicle(playerid, car, 0);
			SaveBusiness(d);
			strunpack(vehicleName, VehicleName[Businesses[d][bModel][v] - 400], sizeof(vehicleName));
			format(string, sizeof(string), "%s(%d) has purchased a %s(%d) from %s for $%s", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), vehicleName, Businesses[d][bModel][v], Businesses[d][bName], number_format(Businesses[d][bPrice][v]));
			Log("logs/dealership.log", string);
		}
		else
		{
			RemovePlayerFromVehicle(playerid);
			new Float:slx, Float:sly, Float:slz;
			GetPlayerPos(playerid, slx, sly, slz);
			SetPlayerPos(playerid, slx, sly, slz+1.2);
			TogglePlayerControllable(playerid, true);
			return 1;
		}
	}
	else if(dialogid == DIALOG_LOADTRUCKOLD) // TRUCKER JOB LOAD TRUCK
	{
		if(!Shipment_CanLoad(playerid)) return CancelTruckDelivery(playerid, false);
		if(response && !(0 <= listitem < 2)) return CancelTruckDelivery(playerid, false);
		if(response)
		{
			if(listitem == 0) // Legal goods
			{

				ShowPlayerDialogEx(playerid, DIALOG_LOADTRUCKL, DIALOG_STYLE_LIST, "Ban muon van chuyen gi?","{00F70C}Thuc pham va do uong\n{00F70C}Quan ao\n{00F70C}Vat lieu\n{00F70C}Hang 24/7", "Chon", "Huy");
			}
			if(listitem == 1) // Illegal goods
			{
				new level = PlayerInfo[playerid][pTruckSkill];
				if(level >= 0 && level <= 50)
				{
					ShowPlayerDialogEx(playerid, DIALOG_LOADTRUCKI, DIALOG_STYLE_LIST, "Ban muon van chuyen gi?","{FF0606}Vu khi 		{FFFFFF}(Thuong cap 1: Mien phi 9mm)\n{FF0606}Ma tuy 			{FFFFFF}(Thuong cap 1: Mien phi 2 Cannabis, 1 crack)\n{FF0606}Vat lieu trai phep  	{FFFFFF}(Thuong cap 1: Mien phi 100 vat lieu)", "Chon", "Huy");
				}
				else if(level >= 51 && level <= 100)
				{
					ShowPlayerDialogEx(playerid, DIALOG_LOADTRUCKI, DIALOG_STYLE_LIST, "Ban muon van chuyen gi?","{FF0606}Vu khi 		{FFFFFF}(Thuong cap 2: Mien phi Shotgun)\n{FF0606}Ma tuy 			{FFFFFF}(Thuong cap 2: Mien phi 4 Cannabis, 2 crack)\n{FF0606}Vat lieu trai phep  	{FFFFFF}(Thuong cap 2: Mien phi 200 vat lieu)", "Chon", "Huy");
				}
				else if(level >= 101 && level <= 200)
				{
					ShowPlayerDialogEx(playerid, DIALOG_LOADTRUCKI, DIALOG_STYLE_LIST, "Ban muon van chuyen gi?","{FF0606}Vu khi 		{FFFFFF}(Thuong cap 3: Mien phi MP5)\n{FF0606}Ma tuy 			{FFFFFF}(Thuong cap 3: Mien phi 6 Cannabis, 3 crack)\n{FF0606}Vat lieu trai phep  	{FFFFFF}(Thuong cap 3: Mien phi 400 vat lieu)", "Chon", "Huy");
				}
				else if(level >= 201 && level <= 400)
				{
					ShowPlayerDialogEx(playerid, DIALOG_LOADTRUCKI, DIALOG_STYLE_LIST, "Ban muon van chuyen gi?","{FF0606}Vu khi 		{FFFFFF}(Thuong cap 4: Mien phi Deagle)\n{FF0606}Ma tuy 			{FFFFFF}(Thuong cap 4: Mien phi 8 Cannabis, 4 crack)\n{FF0606}Vat lieu trai phep  	{FFFFFF}(Thuong cap 4: Mien phi 600 vat lieu)", "Chon", "Huy");
				}
				else if(level >= 401)
				{
					ShowPlayerDialogEx(playerid, DIALOG_LOADTRUCKI, DIALOG_STYLE_LIST, "Ban muon van chuyen gi?","{FF0606}Vu khi 		{FFFFFF}(Thuong cap 5: Mien phi AK-47)\n{FF0606}Ma tuy 			{FFFFFF}(Thuong cap 5: Mien phi 10 Cannabis, 5 crack)\n{FF0606}Vat lieu trai phep  	{FFFFFF}(Thuong cap 5: Mien phi 1000 vat lieu)", "Chon", "Huy");
				}
			}
		}
		else
		{
			CancelTruckDelivery(playerid, false);
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da huy boc hang, dung /loadshipment de thu lai.");
		}
	}

	else if(dialogid == DIALOG_LOADTRUCKL) // TRUCKER JOB LEGAL GOODS
	{
		if(!Shipment_CanLoad(playerid)) return CancelTruckDelivery(playerid, false);
		if(response && !(0 <= listitem < 4)) return CancelTruckDelivery(playerid, false);
		if(response)
		{

			if(listitem == 0) // Food & beverages
			{
				SetPVarInt(playerid, "TruckDeliver", 1);
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Vui long cho boc thuc pham va do uong len xe....");
			}
			if(listitem == 1) // Clothing
			{
				SetPVarInt(playerid, "TruckDeliver", 2);
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Vui long cho boc quan ao len xe....");
			}
			if(listitem == 2) // Materials
			{
				SetPVarInt(playerid, "TruckDeliver", 3);
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Vui long cho boc vat lieu len xe....");
			}
			if(listitem == 3) // 24/7 Items
			{
				SetPVarInt(playerid, "TruckDeliver", 4);
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Vui long cho boc hang 24/7 len xe....");
			}
			Shipment_BeginLoading(playerid, TruckUsed[playerid], "LoadTruckOld");
		}
		else
		{
			CancelTruckDelivery(playerid, false);
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da huy boc hang, dung /loadshipment de thu lai.");
		}
	}

	else if(dialogid == DIALOG_LOADTRUCKI) // TRUCKER JOB ILLEGAL GOODS
	{
		if(!Shipment_CanLoad(playerid)) return CancelTruckDelivery(playerid, false);
		if(response && !(0 <= listitem < 3)) return CancelTruckDelivery(playerid, false);
		if(response)
		{
			// 1 = food and bev
			// 2 = clothing
			// 3 = legal mats
			// 4 = 24/7 items
			// 5 = weapons
			// 6 = illegal drugs
			// 7 = illegal materials
			//new level = PlayerInfo[playerid][pTruckSkill];
			if(listitem == 0) // Weapons
			{
				SetPVarInt(playerid, "TruckDeliver", 5);
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Vui long cho boc vu khi len xe....");
			}
			if(listitem == 1) // Drugs
			{
				SetPVarInt(playerid, "TruckDeliver", 6);
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Vui long cho boc ma tuy len xe....");
			}
			if(listitem == 2) // Illegal materials
			{
				SetPVarInt(playerid, "TruckDeliver", 7);
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Vui long cho boc vat lieu trai phep len xe....");
			}
			Shipment_BeginLoading(playerid, TruckUsed[playerid], "LoadTruckOld");
		}
		else
		{
			CancelTruckDelivery(playerid, false);
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da huy boc hang, dung /loadshipment de thu lai.");
		}
	}
	else if(dialogid == DIALOG_ADMINAUCTIONS)
	{
		if(response) {
			SetPVarInt(playerid, "AuctionItem", listitem);
			ShowPlayerDialogEx(playerid, DIALOG_ADMINAUCTIONS2, DIALOG_STYLE_LIST, "Sua dau gia", "Bat dau gia\nMo ta vat pham\nHan dau gia\nGia khoi diem\nBuoc gia", "Chon", "Thoat");
		}
	}
	else if(dialogid == DIALOG_ADMINAUCTIONS2)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					ShowPlayerDialogEx(playerid, DIALOG_ADMINAUCTIONS3, DIALOG_STYLE_LIST, "Bat/tat dau gia", "Bat\nTat", "Chon", "Thoat");
				}
				case 1:
				{
					ShowPlayerDialogEx(playerid, DIALOG_ADMINAUCTIONS4, DIALOG_STYLE_INPUT, "Sua mo ta vat pham dau gia", "Nhap mo ta vat pham dau gia ben duoi.","Doi","Thoat");
				}
				case 2:
				{
					ShowPlayerDialogEx(playerid, DIALOG_ADMINAUCTIONS5, DIALOG_STYLE_INPUT, "Sua han dau gia", "Nhap thoi luong dau gia tinh bang phut.","Doi","Thoat");
				}
				case 3:
				{
					ShowPlayerDialogEx(playerid, DIALOG_ADMINAUCTIONS6, DIALOG_STYLE_INPUT, "Sua gia khoi diem", "Nhap gia khoi diem.","Doi","Thoat");
				}
				case 4:
				{
					ShowPlayerDialogEx(playerid, DIALOG_ADMINAUCTIONS7, DIALOG_STYLE_INPUT, "Sua buoc gia", "Nhap muc tang gia moi lan.","Doi","Thoat");
				}
			}
		}
	}
	else if(dialogid == DIALOG_ADMINAUCTIONS3)
	{
		if(response) {

			new
				AuctionItem = GetPVarInt(playerid, "AuctionItem"),
				szMessage[128];

			if(listitem == 0)
			{
				if(Auctions[AuctionItem][Expires] == 0) {
					SendClientMessageEx(playerid, COLOR_GREY, "Phai dat thoi gian ket thuc truoc khi bat dau dau gia.");
					return 1;
				}
				format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has edited auction %i enabled to 1 (Enabled)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), AuctionItem);
				Log("logs/adminauction.log", szMessage);
				Auctions[AuctionItem][InProgress] = 1;
				Auctions[AuctionItem][Timer] = SetTimerEx("EndAuction", 60000, true, "i", AuctionItem);
				SendClientMessageEx(playerid, COLOR_WHITE, "Da bat dau gia, nguoi choi co the tra gia.");
			}
			else
			{
				KillTimer(Auctions[AuctionItem][Timer]);
				format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has edited auction %i enabled to 0 (disabled)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), AuctionItem);
				Log("logs/adminauction.log", szMessage);
				Auctions[AuctionItem][InProgress] = 0;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da tat dau gia.");
			}
			SaveAuction(AuctionItem);
			DeletePVar(playerid, "AuctionItem");
		}
	}
	else if(dialogid == DIALOG_ADMINAUCTIONS4)
	{
		if(response)
		{
			new
				AuctionItem = GetPVarInt(playerid, "AuctionItem"),
				szMessage[128];

			if(isnull(inputtext))
			{
				ShowPlayerDialogEx(playerid, DIALOG_ADMINAUCTIONS4, DIALOG_STYLE_INPUT, "Sua mo ta vat pham dau gia", "Nhap mo ta vat pham dau gia ben duoi.","Doi","Thoat");
				return 1;
			}
			if(strlen(inputtext) > 64)
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Mo ta vat pham khong duoc dai qua 64 ky tu.");
				ShowPlayerDialogEx(playerid, DIALOG_ADMINAUCTIONS4, DIALOG_STYLE_INPUT, "Sua mo ta vat pham dau gia", "Nhap mo ta vat pham dau gia ben duoi.","Doi","Thoat");
				return 1;
			}
			format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has edited auction %i item description to %s", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), AuctionItem, inputtext);
			Log("logs/adminauction.log", szMessage);
			format(Auctions[AuctionItem][BiddingFor], 64, inputtext);
			SaveAuction(AuctionItem);
			DeletePVar(playerid, "AuctionItem");
			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi mo ta vat pham dau gia.");
		}
	}
	else if(dialogid == DIALOG_ADMINAUCTIONS5)
	{
		if(response) {
			new
				Time = strval(inputtext),
				AuctionItem = GetPVarInt(playerid, "AuctionItem"),
				szMessage[128];

			if(Time < 0) {
				ShowPlayerDialogEx(playerid, DIALOG_ADMINAUCTIONS5, DIALOG_STYLE_INPUT, "Sua han dau gia", "Nhap thoi luong dau gia tinh bang phut.","Doi","Thoat");
				SendClientMessageEx(playerid, COLOR_GREY, "Thoi gian khong duoc nho hon 0.");
				return 1;
			}
			format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has edited auction %i expire time to %i", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), AuctionItem, Time);
			Log("logs/adminauction.log", szMessage);
			Auctions[AuctionItem][Expires] = Time;
			SaveAuction(AuctionItem);
			DeletePVar(playerid, "AuctionItem");
			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi thoi gian ket thuc dau gia.");
		}
	}
	else if(dialogid == DIALOG_ADMINAUCTIONS6)
	{
		if(response) {
			new
				Time = strval(inputtext),
				AuctionItem = GetPVarInt(playerid, "AuctionItem"),
				szMessage[128];

			if(Time < 0) {
				ShowPlayerDialogEx(playerid, DIALOG_ADMINAUCTIONS6, DIALOG_STYLE_INPUT, "Sua gia khoi diem", "Nhap gia khoi diem.","Doi","Thoat");
				SendClientMessageEx(playerid, COLOR_GREY, "Gia khoi diem khong duoc nho hon 0.");
				return 1;
			}
			format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has edited auction %i starting bid to %i", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), AuctionItem, Time );
			Log("logs/adminauction.log", szMessage);
			Auctions[AuctionItem][Bid] = Time;
			SaveAuction(AuctionItem);
			DeletePVar(playerid, "AuctionItem");
			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi gia khoi diem.");
		}
	}
	else if(dialogid == DIALOG_ADMINAUCTIONS7)
	{
		if(response) {
			new
				Time = strval(inputtext),
				AuctionItem = GetPVarInt(playerid, "AuctionItem"),
				szMessage[128];

			if(Time < 0) {
				ShowPlayerDialogEx(playerid, DIALOG_ADMINAUCTIONS7, DIALOG_STYLE_INPUT, "Sua buoc gia", "Nhap muc tang gia moi lan.","Doi","Thoat");
				SendClientMessageEx(playerid, COLOR_GREY, "Buoc gia khong duoc nho hon 0.");
				return 1;
			}
			format(szMessage, sizeof(szMessage), "%s(%d) (IP:%s) has edited auction %i increment to %i", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), AuctionItem, Time );
			Log("logs/adminauction.log", szMessage);

			Auctions[AuctionItem][Increment] = Time;
			SaveAuction(AuctionItem);
			DeletePVar(playerid, "AuctionItem");
			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi buoc gia.");
		}
	}
	else if(dialogid == DIALOG_AUCTIONS)
	{
		if(response) {

			if(Auctions[listitem][InProgress] == 1) {

				new
					szInfo[200];

				format(szInfo, sizeof(szInfo), "{00BFFF}Hang: {FFFFFF}%s\n\n{00BFFF}Gia: {FFFFFF}$%i\n\n{00BFFF}Nguoi tra: {FFFFFF}%s\n\n{00BFFF}Het han: {FFFFFF}%s", Auctions[listitem][BiddingFor], Auctions[listitem][Bid], Auctions[listitem][Wining], Auctions[listitem][Expires]);
				ShowPlayerDialogEx(playerid, DIALOG_AUCTIONS2, DIALOG_STYLE_MSGBOX, "{00BFFF}Thong tin dau gia", szInfo, "Tra gia", "Thoat");
				SetPVarInt(playerid, "AuctionItem", listitem);
			}
			else SendClientMessageEx(playerid, COLOR_GREY, "Phien dau gia nay hien khong hoat dong.");
		}
	}
	else if(dialogid == DIALOG_AUCTIONS2)
	{
		if(response) {

			new
				AuctionItem = GetPVarInt(playerid, "AuctionItem");
			if(Auctions[AuctionItem][InProgress] == 1) {

				new
					szInfo[128];

				format(szInfo, sizeof(szInfo), "Ban dang dau gia %s. Gia hien tai la $%i, phai tra cao hon muc nay.", Auctions[AuctionItem][BiddingFor], Auctions[AuctionItem][Bid]);
				ShowPlayerDialogEx(playerid, DIALOG_AUCTIONS3, DIALOG_STYLE_INPUT, "Dau gia - Tra gia",szInfo,"Tra gia","Thoat");
			}
			else {

				SendClientMessageEx(playerid, COLOR_GREY, "Phien dau gia nay hien khong hoat dong.");
				DeletePVar(playerid, "AuctionItem");
			}
		}
	}
	else if(dialogid == DIALOG_AUCTIONS3)
	{
		if(response) {

			new
				BidPlaced = strval(inputtext),
				AuctionItem = GetPVarInt(playerid, "AuctionItem");

			if(GetPlayerCash(playerid) < BidPlaced) {
				SendClientMessageEx(playerid, COLOR_GREY, "Khong the tra gia vuot so tien ban co.");
				return 1;
			}
			if(BidPlaced < 1) {
				SendClientMessageEx(playerid, COLOR_GREY, "Khong the tra gia duoi $1.");
				return 1;
			}
			if(BidPlaced < Auctions[AuctionItem][Bid]+Auctions[AuctionItem][Increment]) {
				SendClientMessageEx(playerid, COLOR_GREY, "Phai tra it nhat %i cao hon gia hien tai %i.", Auctions[AuctionItem][Increment], Auctions[AuctionItem][Bid]);
				return 1;
			}

			if(Auctions[AuctionItem][InProgress] == 1) {
				if(BidPlaced > Auctions[AuctionItem][Bid]) {
					SetPVarInt(playerid, "BidPlaced", BidPlaced);
					HigherBid(playerid);
				}
				else SendClientMessageEx(playerid, COLOR_GREY, "Gia qua thap, can tang gia de tham gia dau gia.");
			}
			else SendClientMessageEx(playerid, COLOR_GREY, "Phien dau gia nay hien khong hoat dong.");
		}
	}
	if(dialogid == DIALOG_CGAMESADMINMENU)
	{
		if(response) {
			switch(listitem)
			{
				case 0:
				{
					ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSELECTPOKER);
				}
				case 1:
				{
				}
				case 2:
				{
					ShowCasinoGamesMenu(playerid, DIALOG_CGAMESCREDITS);
				}
			}
		}
	}
	if(dialogid == DIALOG_CGAMESSELECTPOKER)
	{
		if(response) {
			SetPVarInt(playerid, "tmpEditPokerTableID", listitem+1);
			ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPOKER);
		} else {
			ShowCasinoGamesMenu(playerid, DIALOG_CGAMESADMINMENU);
		}
	}
	if(dialogid == DIALOG_CGAMESSETUPPOKER)
	{
		if(response) {
			new tableid = GetPVarInt(playerid, "tmpEditPokerTableID")-1;

			if(PokerTable[tableid][pkrPlaced] == 0) {
				switch(listitem)
				{
					case 0: // Place Poker Table
					{
						new szString[128];
						format(szString, sizeof(szString), "Nhan '{3399FF}~k~~PED_SPRINT~{FFFFFF}' de dat ban Poker.");
						SendClientMessage(playerid, COLOR_WHITE, szString);

						SetPVarInt(playerid, "tmpPlacePokerTable", 1);
					}
				}
			} else {
				switch(listitem)
				{
					case 0: // Edit Poker Table
					{
						SetPVarFloat(playerid, "tmpPkrX", PokerTable[tableid][pkrX]);
						SetPVarFloat(playerid, "tmpPkrY", PokerTable[tableid][pkrY]);
						SetPVarFloat(playerid, "tmpPkrZ", PokerTable[tableid][pkrZ]);
						SetPVarFloat(playerid, "tmpPkrRX", PokerTable[tableid][pkrRX]);
						SetPVarFloat(playerid, "tmpPkrRY", PokerTable[tableid][pkrRY]);
						SetPVarFloat(playerid, "tmpPkrRZ", PokerTable[tableid][pkrRZ]);

						EditObject(playerid, PokerTable[tableid][pkrObjectID]);

						new szString[128];
						format(szString, sizeof(szString), "Da chon ban Poker %d, ban co the doi vi tri/goc xoay.", tableid);
						SendClientMessage(playerid, COLOR_WHITE, szString);
					}
					case 1: // Destroy Poker Table
					{
						DestroyPokerTable(tableid);

						new szString[64];
						format(szString, sizeof(szString), "Da xoa ban Poker %d.", tableid);
						SendClientMessage(playerid, COLOR_WHITE, szString);

						ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSELECTPOKER);
					}
				}
			}
		} else {
			ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSELECTPOKER);
		}
	}
	if(dialogid == DIALOG_CGAMESCREDITS)
	{
		ShowCasinoGamesMenu(playerid, DIALOG_CGAMESADMINMENU);
	}
	if(dialogid == DIALOG_CGAMESSETUPPGAME || dialogid == DIALOG_CGAMESSETUPPGAME2 || dialogid == DIALOG_CGAMESSETUPPGAME3
		|| dialogid == DIALOG_CGAMESSETUPPGAME4 || dialogid == DIALOG_CGAMESSETUPPGAME5 || dialogid == DIALOG_CGAMESSETUPPGAME6 || dialogid == DIALOG_CGAMESSETUPPGAME7) {
		new tableid = GetPVarInt(playerid, "pkrTableID")-1, slot = GetPVarInt(playerid, "pkrSlot");
		if(tableid < 0 || tableid >= MAX_POKERTABLES || slot < 0 || slot >= 6 || PokerTable[tableid][pkrSlot][slot] != playerid
			|| !GetPVarInt(playerid, "pkrRoomLeader") || PokerTable[tableid][pkrActive] != 1) return 1;
	}
	if(dialogid == DIALOG_CGAMESSETUPPGAME)
	{
		if(response) {
			switch(listitem)
			{
				case 0: // Buy-In Max
				{
					ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME2);
				}
				case 1: // Buy-In Min
				{
					ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME3);
				}
				case 2: // Blind
				{
					ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME4);
				}
				case 3: // Limit
				{
					ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME5);
				}
				case 4: // Password
				{
					ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME6);
				}
				case 5: // Round Delay
				{
					ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME7);
				}
				case 6: // Start Game
				{
					ShowCasinoGamesMenu(playerid, DIALOG_CGAMESBUYINPOKER);
				}
			}
		} else {
			LeavePokerTable(playerid);
		}
	}
	if(dialogid == DIALOG_CGAMESSETUPPGAME2)
	{
		if(response) {
			if(strval(inputtext) < 1 || strval(inputtext) > 10000) {
				return ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME2);
			}

			if(strval(inputtext) <= PokerTable[GetPVarInt(playerid, "pkrTableID")-1][pkrBuyInMin]) {
				return ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME2);
			}

			PokerTable[GetPVarInt(playerid, "pkrTableID")-1][pkrBuyInMax] = strval(inputtext);
			return ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME);
		} else {
			return ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME);
		}
	}
	if(dialogid == DIALOG_CGAMESSETUPPGAME3)
	{
		if(response) {
			if(strval(inputtext) < 1 || strval(inputtext) > 10000) {
				return ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME3);
			}

			if(strval(inputtext) >= PokerTable[GetPVarInt(playerid, "pkrTableID")-1][pkrBuyInMax]) {
				return ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME3);
			}

			PokerTable[GetPVarInt(playerid, "pkrTableID")-1][pkrBuyInMin] = strval(inputtext);
			return ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME);
		} else {
			return ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME);
		}
	}
	if(dialogid == DIALOG_CGAMESSETUPPGAME4)
	{
		if(response) {
			if(strval(inputtext) < 2 || strval(inputtext) > 10000) {
				return ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME4);
			}

			PokerTable[GetPVarInt(playerid, "pkrTableID")-1][pkrBlind] = strval(inputtext);
			return ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME);
		} else {
			return ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME);
		}
	}
	if(dialogid == DIALOG_CGAMESSETUPPGAME5)
	{
		if(response) {
			if(strval(inputtext) < 2 || strval(inputtext) > 6) {
				return ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME5);
			}

			PokerTable[GetPVarInt(playerid, "pkrTableID")-1][pkrLimit] = strval(inputtext);
			return ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME);
		} else {
			return ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME);
		}
	}
	if(dialogid == DIALOG_CGAMESSETUPPGAME6)
	{
		if(response) {
			new tableid = GetPVarInt(playerid, "pkrTableID")-1;
			strmid(PokerTable[tableid][pkrPass], inputtext, 0, strlen(inputtext), 32);
			return ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME);
		} else {
			ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME);
		}
	}
	if(dialogid == DIALOG_CGAMESSETUPPGAME7)
	{
		if(response) {
			if(strval(inputtext) < 15 || strval(inputtext) > 120) {
				return ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME7);
			}

			PokerTable[GetPVarInt(playerid, "pkrTableID")-1][pkrSetDelay] = strval(inputtext);
			return ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME);
		} else {
			return ShowCasinoGamesMenu(playerid, DIALOG_CGAMESSETUPPGAME);
		}
	}
	if(dialogid == DIALOG_CGAMESBUYINPOKER)
	{
		new tableid = GetPVarInt(playerid, "pkrTableID")-1, slot = GetPVarInt(playerid, "pkrSlot");
		if(tableid < 0 || tableid >= MAX_POKERTABLES || slot < 0 || slot >= 6 || PokerTable[tableid][pkrSlot][slot] != playerid || !gPlayerLogged{playerid}) return 1;
		if(!response) return LeavePokerTable(playerid);
		if(PokerTable[tableid][pkrRound] || PokerTable[tableid][pkrActive] == 4) return SendClientMessageEx(playerid, COLOR_GREY, "Hay cho het van truoc khi mua chips.");
		new amount, chips = GetPVarInt(playerid, "pkrChips");
		if(!ParseBankTransferAmount(inputtext, amount) || amount < PokerTable[tableid][pkrBuyInMin]
			|| amount > PokerTable[tableid][pkrBuyInMax] || chips > PokerTable[tableid][pkrBuyInMax]-amount
			|| amount > GetPlayerCash(playerid)) return ShowCasinoGamesMenu(playerid, DIALOG_CGAMESBUYINPOKER);
		new total = PokerTable[tableid][pkrPot];
		for(new i; i < 6; ++i) {
			new pid = PokerFindPlayerOrder(tableid, i);
			if(pid == -1) continue;
			new held = GetPVarInt(pid, "pkrChips");
			if(held < 0 || total > cellmax-held) return 1;
			total += held;
		}
		if(total > cellmax-amount) return SendClientMessageEx(playerid, COLOR_GREY, "Ban nay khong the chua them chips.");
		SetPVarInt(playerid, "pkrChips", chips+amount);
		SetPVarInt(playerid, "pkrStatus", 1);
		GivePlayerCashEx(playerid, TYPE_ONHAND, -amount);
		format(string, sizeof(string), "%s(%d) (IP:%s) has bought in with the amount of $%s (%d)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(amount), tableid);
		Log("logs/poker.log", string);
		if(PokerTable[tableid][pkrActive] == 1 && GetPVarInt(playerid, "pkrRoomLeader")) PokerTable[tableid][pkrActive] = 2;
		SelectTextDraw(playerid, COLOR_YELLOW);
		return 1;
	}
	if(dialogid == DIALOG_CGAMESCALLPOKER)
	{
		if(!PokerCanAct(playerid) || !GetPVarType(playerid, "pkrActionChoice")) return 1;
		DeletePVar(playerid, "pkrActionChoice");
		if(response) {
			new tableid = GetPVarInt(playerid, "pkrTableID")-1, slot = GetPVarInt(playerid, "pkrSlot");
			new current = GetPVarInt(playerid, "pkrCurrentBet"), needed = PokerTable[tableid][pkrActiveBet]-current;
			if(needed <= 0) return 1;
			new paid = min(needed, GetPVarInt(playerid, "pkrChips"));
			PokerTable[tableid][pkrPot] += paid;
			PokerTable[tableid][pkrCommitted][slot] += paid;
			PokerTable[tableid][pkrActedBet][slot] = PokerTable[tableid][pkrActiveBet];
			SetPVarInt(playerid, "pkrCurrentBet", current+paid);
			SetPVarInt(playerid, "pkrChips", GetPVarInt(playerid, "pkrChips")-paid);
			SetPVarString(playerid, "pkrStatusString", paid < needed ? "All-In" : "Call");
			ApplyAnimation(playerid, "CASINO", "cards_raise", 4.1, false, true, true, true, 1, 1);
			PokerRotateActivePlayer(tableid);
		}
		return 1;
	}
	if(dialogid == DIALOG_CGAMESRAISEPOKER)
	{
		if(!PokerCanAct(playerid) || !GetPVarType(playerid, "pkrActionChoice")) return 1;
		DeletePVar(playerid, "pkrActionChoice");
		if(response) {
			new tableid = GetPVarInt(playerid, "pkrTableID")-1, slot = GetPVarInt(playerid, "pkrSlot"), amount;
			new current = GetPVarInt(playerid, "pkrCurrentBet"), active = PokerTable[tableid][pkrActiveBet];
			new maximum = current+GetPVarInt(playerid, "pkrChips"), acted = PokerTable[tableid][pkrActedBet][slot];
			if(acted >= 0 && active-acted < PokerTable[tableid][pkrMinRaise] && !(acted == 0 && active > 0)) return SendClientMessageEx(playerid, COLOR_GREY, "All-in nho nay chua mo lai quyen Raise cho ban.");
			if(!ParseBankTransferAmount(inputtext, amount) || amount <= active || amount > maximum
				|| (amount-active < PokerTable[tableid][pkrMinRaise] && amount != maximum)) return ShowCasinoGamesMenu(playerid, DIALOG_CGAMESRAISEPOKER);
			new paid = amount-current;
			PokerTable[tableid][pkrPot] += paid;
			PokerTable[tableid][pkrCommitted][slot] += paid;
			if(amount-active >= PokerTable[tableid][pkrMinRaise]) PokerTable[tableid][pkrMinRaise] = amount-active;
			PokerTable[tableid][pkrActiveBet] = amount;
			PokerTable[tableid][pkrActedBet][slot] = amount;
			SetPVarInt(playerid, "pkrCurrentBet", amount);
			SetPVarInt(playerid, "pkrChips", maximum-amount);
			SetPVarString(playerid, "pkrStatusString", amount == maximum ? "All-In" : "Raise");
			ApplyAnimation(playerid, "CASINO", "cards_raise", 4.1, false, true, true, true, 1, 1);
			PokerRotateActivePlayer(tableid);
		}
		return 1;
	}
	if(dialogid == DIALOG_CHARGEPLAYER)
	{
		if(response)
		{
			if(PlayerInfo[playerid][pCredits] < GetPVarInt(playerid, "FineAmount"))
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de nop phat.");

			new reason[60];
			GetPVarString(playerid, "FineReason", reason, 60);
			format(string, sizeof(string), "AdmCmd: %s(%d) was fined %s credits by %s, reason: %s", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), number_format(GetPVarInt(playerid, "FineAmount")), GetPlayerNameEx(GetPVarInt(playerid, "FineBy")), reason);
			Log("logs/admin.log", string);

			format(string, sizeof(string), "[CHARGEPLAYER] [User: %s(%i)] [IP: %s] [Credits: %s] [Charged: %s]", GetPlayerNameEx(playerid), PlayerInfo[playerid][pId], GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]),  number_format(GetPVarInt(playerid, "FineAmount")));
			Log("logs/credits.log", string);

			GivePlayerCredits(playerid, -GetPVarInt(playerid, "FineAmount"), 1);

			SendClientMessageEx(playerid, COLOR_CYAN, "Ban bi thu %s credits cho %s boi %s.", number_format(GetPVarInt(playerid, "FineAmount")), reason, GetPlayerNameEx(GetPVarInt(playerid, "FineBy")));

			format(string, sizeof(string), "Ban da thu cua %s %s credits cho %s.", GetPlayerNameEx(playerid), number_format(GetPVarInt(playerid, "FineAmount")), reason);
			SendClientMessageEx(GetPVarInt(playerid, "FineBy"), COLOR_CYAN, string);
		}
		else
		{
			SendClientMessageEx(GetPVarInt(playerid, "FineBy"), COLOR_CYAN, "Nguoi choi da tu choi khoan thu.");
		}
		DeletePVar(playerid, "FineAmount");
		DeletePVar(playerid, "FineBy");
		DeletePVar(playerid, "FineReason");
	}
	if(dialogid == DIALOG_EDITSHOPMENU)
	{
		if(response)
		{
			if(listitem == 0)
			{
				new shopstring[4500];
				format(shopstring, sizeof(shopstring),
				"Gold VIP (Credits: %s)\n\
				Gold VIP Renewal (Credits: %s)\n\
				Silver VIP (Credits: %s)\n\
				Bronze VIP (Credits: %s)\n\
				Toys (Credits: %s)\n\
				Vehicles (Credits: %s)\n\
				Poker Table (Credits: %s)\n\
				Boombox (Credits: %s)", number_format(ShopItems[0][sItemPrice]), number_format(ShopItems[1][sItemPrice]), number_format(ShopItems[2][sItemPrice]), number_format(ShopItems[3][sItemPrice]), number_format(ShopItems[4][sItemPrice]),
				 number_format(ShopItems[5][sItemPrice]), number_format(ShopItems[6][sItemPrice]), number_format(ShopItems[7][sItemPrice]));

				format(shopstring, sizeof(shopstring), "%s\n\
				Paintball Tokens (Credits %s)\n\
				EXP Token (Credits: %s)\n\
				Fireworks x5 (Credits: %s)\n\
				Renewal Regular (Credits: %s)\n\
				Renewal Standard (Credits: %s)\n\
				Renewal Premium (Credits: %s)\n\
				House (Credits: %s)\n\
				House Interior Change (Credits: %s)\n\
				House Move (Credits: %s)\n\
				(Micro) Reset Gift Timer (Credits: %s)",shopstring, number_format(ShopItems[8][sItemPrice]), number_format(ShopItems[9][sItemPrice]), number_format(ShopItems[10][sItemPrice]),
				number_format(ShopItems[11][sItemPrice]), number_format(ShopItems[12][sItemPrice]), number_format(ShopItems[13][sItemPrice]), number_format(ShopItems[14][sItemPrice]),
				 number_format(ShopItems[15][sItemPrice]), number_format(ShopItems[16][sItemPrice]), number_format(ShopItems[17][sItemPrice]));
				format(shopstring, sizeof(shopstring),
				"%s\n(Micro) Advanced Healthcare (Credits: %s)\n\
				(Micro) Super Advanced Healthcare (Credits: %s)\n\
				(Micro) Rent a Car (Credits: %s)\n\
				Platinum VIP (Credits: %s)\n\
				Custom License Plate (Credits: %s)\n\
				Additional Vehicle Slot (Credits: %s)", shopstring, number_format(ShopItems[18][sItemPrice]), number_format(ShopItems[19][sItemPrice]), number_format(ShopItems[20][sItemPrice]),
				 number_format(ShopItems[21][sItemPrice]), number_format(ShopItems[22][sItemPrice]), number_format(ShopItems[23][sItemPrice]));
				format(shopstring, sizeof(shopstring),
				"%s\nGarage - Small (Credits: %s)\n\
				Garage - Medium (Credits: %s)\n\
				Garage - Large (Credits: %s)\n\
				Garage - Extra Large (Credits: %s)\n\
				Additional Toy Slot (Credits: %s)\n\
				Hunger Voucher (Credits: %s)\n\
				Spawn at Gold VIP+ room (Credits: %s)", shopstring, number_format(ShopItems[24][sItemPrice]), number_format(ShopItems[25][sItemPrice]), number_format(ShopItems[26][sItemPrice]),
				number_format(ShopItems[27][sItemPrice]), number_format(ShopItems[28][sItemPrice]), number_format(ShopItems[29][sItemPrice]), number_format(ShopItems[30][sItemPrice]));
				format(shopstring, sizeof(shopstring),
				"%s\n\
				Restricted Last Name (NEW) (Credits: %s)\n\
				Restricted Last Name (CHANGE) (Credits: %s)\n\
				Custom User Title (NEW) (Credits: %s)\n\
				Custom User Title (CHANGE) (Credits: %s)\n\
				Teamspeak User Channel (Credits: %s)\n\
				Small Backpack (Credits: %s)\n\
				Medium Backpack (Credits: %s)\n\
				Large Backpack (Credits: %s)\n\
				Deluxe Car Alarm (Credits: %s)\n\
				Name Changes (Credits: %s)\n\
				Furniture Pack - Bronze (Credits: %s)\n\
				Furniture Pack - Silver (Credits: %s)\n\
				Furniture Pack - Gold (Credits: %s)",
				shopstring, number_format(ShopItems[31][sItemPrice]), number_format(ShopItems[32][sItemPrice]), number_format(ShopItems[33][sItemPrice]), number_format(ShopItems[34][sItemPrice]),
				number_format(ShopItems[35][sItemPrice]),number_format(ShopItems[36][sItemPrice]),number_format(ShopItems[37][sItemPrice]),number_format(ShopItems[38][sItemPrice]),number_format(ShopItems[39][sItemPrice]), number_format(ShopItems[40][sItemPrice]),
				number_format(ShopItems[41][sItemPrice]), number_format(ShopItems[42][sItemPrice]), number_format(ShopItems[43][sItemPrice]));
				ShowPlayerDialogEx(playerid, DIALOG_EDITSHOP, DIALOG_STYLE_LIST, "Edit Shop Prices", shopstring, "Sua", "Thoat");
			}
			if(listitem == 1)
			{
				ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS, DIALOG_STYLE_LIST, "Sua cua hang doanh nghiep", "Add Business\nEdit Business\nView Businesses Sold", "Chon", "Thoat");
			}
			if(listitem == 2)
			{
				for(new i; i < MAX_MICROITEMS; i++)
				{
					strunpack(microItemName, mItemName[i], sizeof(microItemName));
					format(szMiscArray, sizeof(szMiscArray), "%s\n%s (Credits: %s)", szMiscArray, microItemName, number_format(MicroItems[i]));
				}
				ShowPlayerDialogEx(playerid, DIALOG_EDITMICROSHOP, DIALOG_STYLE_LIST, "Edit Micro Shop Prices", szMiscArray, "Sua", "Thoat");
			}
		}
	}
	if(dialogid == DIALOG_EDITSHOP)
	{
		if(response) {
			new item[30];
			SetPVarInt(playerid, "EditingPrice", listitem);
			switch(listitem)
			{
				case 0: item = "Gold VIP";
				case 1: item = "Gold VIP Renewal";
				case 2: item = "Silver VIP";
				case 3: item = "Bronze VIP";
				case 4: item = "Toys";
				case 5: item = "Vehicles";
				case 6: item = "Poker Table";
				case 7: item = "Boombox";
				case 8: item = "Paintball Tokens";
				case 9: item = "EXP Token";
				case 10: item = "Fireworks x5";
				case 11: item = "Renewal Regular";
				case 12: item = "Renewal Standard";
				case 13: item = "Renewal Premium";
				case 14: item = "House";
				case 15: item = "House Interior Change";
				case 16: item = "House Move";
				case 17: item = "(Micro) Reset Gift Timer";
				case 18: item = "(Micro) Advanced Health Care";
				case 19: item = "(Micro) Super Health Care";
				case 20: item = "(Micro) Rent a Car";
				case 21: item = "Platinum VIP";
				case 22: item = "License Plate";
				case 23: item = "Additional Vehicle Slot";
				case 24: item = "Garage - Small";
				case 25: item = "Garage - Medium";
				case 26: item = "Garage - Large";
				case 27: item = "Garage - Extra Large";
				case 28: item = "Additional Toy Slot";
				case 29: item = "Hunger Voucher";
				case 30: item = "Spawn at Gold VIP+ room";
				case 31: item = "Restricted Last Name (NEW)";
				case 32: item = "Restricted Last Name (CHANGE)";
				case 33: item = "Custom User Title (NEW)";
				case 34: item = "Custom User Title (CHANGE)";
				case 35: item = "Teamspeak User Channel";
				case 36: item = "Small Backpack";
				case 37: item = "Medium Backpack";
				case 38: item = "Large Backpack";
				case 39: item = "Deluxe Car Alarm";
				case 40: item = "Name Changes";
				case 41: item = "Furniture Slots Pack - Bronze";
				case 42: item = "Furniture Slots Pack - Silver";
				case 43: item = "Furniture Slots Pack - Gold";
			}
			format(string, sizeof(string), "Ban dang doi gia %s. Gia hien tai la %d credits.", item, ShopItems[listitem][sItemPrice]);
			ShowPlayerDialogEx(playerid, DIALOG_EDITSHOP2, DIALOG_STYLE_INPUT, "Editing Price", string, "Doi", "Quay lai");
		}
	}
	if(dialogid == DIALOG_EDITSHOP2)
	{
		if(response) {

			new
				Prices = strval(inputtext),
				item[30];

			switch(GetPVarInt(playerid, "EditingPrice"))
			{
				case 0: item = "Gold VIP";
				case 1: item = "Gold VIP Renewal";
				case 2: item = "Silver VIP";
				case 3: item = "Bronze VIP";
				case 4: item = "Toys";
				case 5: item = "Vehicles";
				case 6: item = "Poker Table";
				case 7: item = "Boombox";
				case 8: item = "Paintball Tokens";
				case 9: item = "EXP Token";
				case 10: item = "Fireworks x5";
				case 11: item = "Renewal Regular";
				case 12: item = "Renewal Standard";
				case 13: item = "Renewal Premium";
				case 14: item = "House";
				case 15: item = "House Interior Change";
				case 16: item = "House Move";
				case 17: item = "(Micro) Reset Gift Timer";
				case 18: item = "(Micro) Advanced Health Care";
				case 19: item = "(Micro) Super Health Care";
				case 20: item = "(Micro) Rent a Car";
				case 21: item = "Platinum VIP";
				case 22: item = "License Plate";
				case 23: item = "Additional Vehicle Slot";
				case 24: item = "Garage - Small";
				case 25: item = "Garage - Medium";
				case 26: item = "Garage - Large";
				case 27: item = "Garage - Extra Large";
				case 28: item = "Additional Toy Slot";
				case 29: item = "Hunger Voucher";
				case 30: item = "Spawn at Gold VIP+ room";
				case 31: item = "Restricted Last Name (NEW)";
				case 32: item = "Restricted Last Name (CHANGE)";
				case 33: item = "Custom User Title (NEW)";
				case 34: item = "Custom User Title (CHANGE)";
				case 35: item = "Teamspeak User Channel";
				case 36: item = "Small Backpack";
				case 37: item = "Medium Backpack";
				case 38: item = "Large Backpack";
				case 39: item = "Deluxe Car Alarm";
				case 40: item = "Name Changes";
				case 41: item = "Furniture Slots Pack - Bronze";
				case 42: item = "Furniture Slots Pack - Silver";
				case 43: item = "Furniture Slots Pack - Gold";
			}

			if(isnull(inputtext) || Prices <= 0) {
				format(string, sizeof(string), "Gia khong duoc duoi 0.\n\nBan dang doi gia %s. Gia hien tai la %d credits.", item, ShopItems[GetPVarInt(playerid, "EditingPrice")][sItemPrice]);
				ShowPlayerDialogEx(playerid, DIALOG_EDITSHOP2, DIALOG_STYLE_INPUT, "Editing Price", string, "Doi", "Quay lai");
			}
			else
			{
				SetPVarInt(playerid, "EditingPriceValue", Prices);

				format(string,sizeof(string),"Ban chac chan muon doi gia %s?\n\nGia cu: %d\nGia moi: %d", item, ShopItems[GetPVarInt(playerid, "EditingPrice")][sItemPrice], Prices);
				ShowPlayerDialogEx(playerid, DIALOG_EDITSHOP3, DIALOG_STYLE_MSGBOX, "Confirmation", string, "Xac nhan", "Huy");
				return 1;
			}
		}
		format(szMiscArray, sizeof(szMiscArray),
		"Gold VIP (Credits: %s)\n\
		Gold VIP Renewal (Credits: %s)\n\
		Silver VIP (Credits: %s)\n\
		Bronze VIP (Credits: %s)\n\
		Toys (Credits: %s)\n\
		Vehicles (Credits: %s)\n\
		Poker Table (Credits: %s)\n\
		Boombox (Credits: %s)", number_format(ShopItems[0][sItemPrice]), number_format(ShopItems[1][sItemPrice]), number_format(ShopItems[2][sItemPrice]), number_format(ShopItems[3][sItemPrice]), number_format(ShopItems[4][sItemPrice]),
		 number_format(ShopItems[5][sItemPrice]), number_format(ShopItems[6][sItemPrice]), number_format(ShopItems[7][sItemPrice]));

		format(szMiscArray, sizeof(szMiscArray), "%s\n\
		Paintball Tokens (Credits %s)\n\
		EXP Token (Credits: %s)\n\
		Fireworks x5 (Credits: %s)\n\
		Renewal Regular (Credits: %s)\n\
		Renewal Standard (Credits: %s)\n\
		Renewal Premium (Credits: %s)\n\
		House (Credits: %s)\n\
		House Interior Change (Credits: %s)\n\
		House Move (Credits: %s)\n\
		(Micro) Reset Gift Timer (Credits: %s)", szMiscArray, number_format(ShopItems[8][sItemPrice]), number_format(ShopItems[9][sItemPrice]), number_format(ShopItems[10][sItemPrice]),
		number_format(ShopItems[11][sItemPrice]), number_format(ShopItems[12][sItemPrice]), number_format(ShopItems[13][sItemPrice]), number_format(ShopItems[14][sItemPrice]), number_format(ShopItems[15][sItemPrice]),
		number_format(ShopItems[16][sItemPrice]), number_format(ShopItems[17][sItemPrice]));
		format(szMiscArray, sizeof(szMiscArray),
		"%s\n(Micro) Advanced Healthcare (Credits: %s)\n\
		(Micro) Super Advanced Healthcare (Credits: %s)\n\
		(Micro) Rent a Car (Credits: %s)\n\
		Platinum VIP (Credits: %s)\n\
		Custom License Plate (Credits: %s)\n\
		Additional Vehicle Slot (Credits: %s)", szMiscArray, number_format(ShopItems[18][sItemPrice]), number_format(ShopItems[19][sItemPrice]), number_format(ShopItems[20][sItemPrice]), number_format(ShopItems[21][sItemPrice]),
		 number_format(ShopItems[22][sItemPrice]), number_format(ShopItems[23][sItemPrice]));
		format(szMiscArray, sizeof(szMiscArray),
		"%s\nGarage - Small (Credits: %s)\n\
		Garage - Medium (Credits: %s)\n\
		Garage - Large (Credits: %s)\n\
		Garage - Extra Large (Credits: %s)\n\
		Additional Toy Slot (Credits: %s)\n\
		Hunger Voucher (Credits: %s)\n\
		Spawn at Gold VIP+ room (Credits: %s)", szMiscArray, number_format(ShopItems[24][sItemPrice]), number_format(ShopItems[25][sItemPrice]), number_format(ShopItems[26][sItemPrice]),
		number_format(ShopItems[27][sItemPrice]), number_format(ShopItems[28][sItemPrice]), number_format(ShopItems[29][sItemPrice]), number_format(ShopItems[30][sItemPrice]));
		format(szMiscArray, sizeof(szMiscArray),
		"%s\n\
		Restricted Last Name (NEW) (Credits: %s)\n\
		Restricted Last Name (CHANGE) (Credits: %s)\n\
		Custom User Title (NEW) (Credits: %s)\n\
		Custom User Title (CHANGE) (Credits: %s)\n\
		Teamspeak User Channel (Credits: %s)\n\
		Small Backpack (Credits: %s)\n\
		Medium Backpack (Credits: %s)\n\
		Large Backpack (Credits: %s)\n\
		Deluxe Car Alarm (Credits: %s)\n\
		Name Changes (Credits: %s)\n\
		Furniture Pack - Bronze (Credits: %s)\n\
		Furniture Pack - Silver (Credits: %s)\n\
		Furniture Pack - Gold (Credits: %s)",
		szMiscArray, number_format(ShopItems[31][sItemPrice]), number_format(ShopItems[32][sItemPrice]), number_format(ShopItems[33][sItemPrice]), number_format(ShopItems[34][sItemPrice]),
		number_format(ShopItems[35][sItemPrice]),number_format(ShopItems[36][sItemPrice]),number_format(ShopItems[37][sItemPrice]),number_format(ShopItems[38][sItemPrice]),number_format(ShopItems[39][sItemPrice]), number_format(ShopItems[40][sItemPrice]),
		number_format(ShopItems[41][sItemPrice]), number_format(ShopItems[42][sItemPrice]), number_format(ShopItems[43][sItemPrice]));
		ShowPlayerDialogEx(playerid, DIALOG_EDITSHOP, DIALOG_STYLE_LIST, "Edit Shop Prices", szMiscArray, "Sua", "Thoat");
	}
	if(dialogid == DIALOG_EDITSHOP3)
	{
		if(response)
		{
			new item[30];
			switch(GetPVarInt(playerid, "EditingPrice"))
			{
				case 0: item = "Gold VIP";
				case 1: item = "Gold VIP Renewal";
				case 2: item = "Silver VIP";
				case 3: item = "Bronze VIP";
				case 4: item = "Toys";
				case 5: item = "Vehicles";
				case 6: item = "Poker Table";
				case 7: item = "Boombox";
				case 8: item = "Paintball Tokens";
				case 9: item = "EXP Token";
				case 10: item = "Fireworks x5";
				case 11: item = "Renewal Regular";
				case 12: item = "Renewal Standard";
				case 13: item = "Renewal Premium";
				case 14: item = "House";
				case 15: item = "House Interior Change";
				case 16: item = "House Move";
				case 17: item = "(Micro) Reset Gift Timer";
				case 18: item = "(Micro) Advanced Health Care";
				case 19: item = "(Micro) Super Health Care";
				case 20: item = "(Micro) Rent a Car";
				case 21: item = "Platinum VIP";
				case 22: item = "License Plate";
				case 23: item = "Additional Vehicle Slot";
				case 24: item = "Garage - Small";
				case 25: item = "Garage - Medium";
				case 26: item = "Garage - Large";
				case 27: item = "Garage - Extra Large";
				case 28: item = "Additional Toy Slot";
				case 29: item = "Hunger Voucher";
				case 30: item = "Spawn at Gold VIP+ room";
				case 31: item = "Restricted Last Name (NEW)";
				case 32: item = "Restricted Last Name (CHANGE)";
				case 33: item = "Custom User Title (NEW)";
				case 34: item = "Custom User Title (CHANGE)";
				case 35: item = "Teamspeak User Channel";
				case 36: item = "Small Backpack";
				case 37: item = "Medium Backpack";
				case 38: item = "Large Backpack";
				case 39: item = "Deluxe Car Alarm";
				case 40: item = "Name Changes";
				case 41: item = "Furniture Slots Pack - Bronze";
				case 42: item = "Furniture Slots Pack - Silver";
				case 43: item = "Furniture Slots Pack - Gold";
			}
			if(GetPVarInt(playerid, "EditingPriceValue") == 0)
				SetPVarInt(playerid, "EditingPriceValue", 999999);

			Price[GetPVarInt(playerid, "EditingPrice")] = GetPVarInt(playerid, "EditingPriceValue");
			ShopItems[GetPVarInt(playerid, "EditingPrice")][sItemPrice] = GetPVarInt(playerid, "EditingPriceValue");
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da doi gia %s thanh %d.", item, GetPVarInt(playerid, "EditingPriceValue"));
			format(string, sizeof(string), "[EDITSHOPPRICES] [User: %s(%i)] [IP: %s] [%s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), item, number_format(ShopItems[GetPVarInt(playerid, "EditingPrice")][sItemPrice]));
			Log("logs/editshop.log", string), print(string);
			g_mysql_SavePrices();
			return 1;
		}
		DeletePVar(playerid, "EditingPrice");
		DeletePVar(playerid, "EditingPriceValue");
		SendClientMessageEx(playerid, COLOR_GREY, "Ban da huy doi gia.");
	}
	if(dialogid == DIALOG_ENTERPIN)
	{
		if(response)
		{
			if(isnull(inputtext) || strlen(inputtext) > 4 || !IsNumericString(inputtext))
			{
				ShowPlayerDialogEx(playerid, DIALOG_ENTERPIN, DIALOG_STYLE_INPUT, "Ma PIN", "Nhap PIN de vao cua hang credits.", "Xac nhan", "Thoat");
				return 1;
			}

			if(!gPlayerLogged{playerid}) return 0;
			new request = Password_Begin(playerid);
			if(!request) return 0;
			SetPVarString(playerid, "PinNumber", inputtext);
			mysql_format(MainPipeline, string, sizeof(string), "SELECT `Pin` FROM `accounts` WHERE `id`=%d", GetPlayerSQLId(playerid));
			mysql_tquery(MainPipeline, string, "OnPinCheck2", "iiii", playerid, g_arrQueryHandle[playerid], request, GetPlayerSQLId(playerid));

		}
	}
	if(dialogid == DIALOG_CREATEPIN)
	{
		if(response)
		{

			if(strlen(inputtext) > 4 || !IsNumericString(inputtext))
				return ShowPlayerDialogEx(playerid, DIALOG_CREATEPIN, DIALOG_STYLE_INPUT, "Ma PIN", "Loi: PIN chi duoc gom chu so, it nhat 4 chu so. \nTao PIN de bao ve credits tai khoan.", "Tao", "Thoat");

			if(GetPVarType(playerid, "ChangePin"))
			{
				if(isnull(inputtext))
					return ShowPlayerDialogEx(playerid, DIALOG_CREATEPIN, DIALOG_STYLE_INPUT, "Doi ma PIN", "Nhap PIN moi de thay PIN hien tai.", "Doi", "Huy");
			}
			else
			{
				if(isnull(inputtext))
					return ShowPlayerDialogEx(playerid, DIALOG_CREATEPIN, DIALOG_STYLE_INPUT, "Ma PIN", "Tao PIN de bao ve credits tai khoan.", "Tao", "Thoat");
			}

			SetPVarString(playerid, "PinConfirm", inputtext);
			ShowPlayerDialogEx(playerid, DIALOG_CREATEPIN2, DIALOG_STYLE_INPUT, "Ma PIN", "Nhap lai PIN de xac nhan.", "Tao", "Thoat");
		}
		else if(GetPVarType(playerid, "ChangePin")) DeletePVar(playerid, "ChangePin");
	}
	if(dialogid == DIALOG_VIEWSALE)
	{
		if(response)
		{
			mysql_format(MainPipeline, string, sizeof(string), "SELECT * FROM `sales` WHERE `id` = '%d'", Selected[playerid][listitem]);
			SetPVarInt(playerid, "checkingsale", Selected[playerid][listitem]);
			mysql_tquery(MainPipeline, string, "CheckSales2", "i", playerid);
		}
	}
	if(dialogid == DIALOG_VIEWSALE2)
	{
		if(response)
		{
			mysql_format(MainPipeline, string, sizeof(string), "SELECT * FROM `sales` WHERE `id` = '%d'", GetPVarInt(playerid, "checkingsale"));
			mysql_tquery(MainPipeline, string, "CheckSales3", "i", playerid);
		}
	}
	if(dialogid == DIALOG_CREATEPIN2)
	{
		if(response)
		{
			if(isnull(inputtext))
				return ShowPlayerDialogEx(playerid, DIALOG_CREATEPIN2, DIALOG_STYLE_INPUT, "Ma PIN", "Nhap lai PIN de xac nhan.", "Tao", "Thoat");

			new confirm[128];
			GetPVarString(playerid, "PinConfirm", confirm, 128);
			if(strcmp(inputtext, confirm, true) != 0)
			{
				if(GetPVarType(playerid, "ChangePin"))
				{
					ShowPlayerDialogEx(playerid, DIALOG_CREATEPIN, DIALOG_STYLE_INPUT, "Ma PIN", "Nhap PIN moi de thay PIN hien tai.", "Doi", "Huy");
				}
				else
				{
					ShowPlayerDialogEx(playerid, DIALOG_CREATEPIN, DIALOG_STYLE_INPUT, "Ma PIN", "Loi: Hai PIN khong trung nhau.\n\nTao PIN de bao ve credits tai khoan.", "Tao", "Thoat");
				}
				DeletePVar(playerid, "PinConfirm");
			}
			else
			{
				if(!gPlayerLogged{playerid} || isnull(inputtext) || strlen(inputtext) > 4 || !IsNumericString(inputtext)) return 0;
				new request = Password_Begin(playerid);
				if(!request) return 0;
				if(!bcrypt_hash(playerid, "OnPlayerPinHashed", inputtext, BCRYPT_COST, "iii", g_arrQueryHandle[playerid], request, GetPlayerSQLId(playerid))) {
					gPasswordPending[playerid] = false;
					return SendClientMessageEx(playerid, COLOR_RED, "Khong the xu ly doi PIN."), 0;
				}
				DeletePVar(playerid, "PinConfirm");
			}
		}
		else {
			DeletePVar(playerid, "PinConfirm");
			DeletePVar(playerid, "ChangePin");
		}
	}
	if(dialogid == DIALOG_MISCSHOP && response)
	{
		SetPVarInt(playerid, "MiscShop", listitem+1);
		switch(listitem)
		{
			case 0:
			{
				format(string, sizeof(string), "Vat pham: Poker Table\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[6][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[6][sItemPrice]));
				ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Misc Shop", string, "Mua", "Huy");
			}
			case 1:
			{
				format(string, sizeof(string), "Vat pham: Boombox\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[7][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[7][sItemPrice]));
				ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Misc Shop", string, "Mua", "Huy");
			}
			case 2:
			{
				format(string, sizeof(string), "Vat pham: 100 Paintball Tokens\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]),number_format(ShopItems[8][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[8][sItemPrice]));
				ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Misc Shop", string, "Mua", "Huy");
			}
			case 3:
			{
				format(string, sizeof(string), "Vat pham: EXP Token\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]),number_format(ShopItems[9][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[9][sItemPrice]));
				ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Misc Shop", string, "Mua", "Huy");
			}
			case 4:
			{
				format(string, sizeof(string), "Vat pham: Fireworks x5\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]),number_format(ShopItems[10][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[10][sItemPrice]));
				ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Misc Shop", string, "Mua", "Huy");
			}
			case 5:
			{
				format(string, sizeof(string), "Vat pham: Custom License Plate\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]),number_format(ShopItems[22][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[22][sItemPrice]));
				ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Misc Shop", string, "Mua", "Huy");
			}
			case 6:
			{
				SetPVarInt(playerid, "MiscShop", 10);
				format(string, sizeof(string), "Vat pham: Restricted Last Name (NEW)\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]),number_format(ShopItems[31][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[31][sItemPrice]));
				ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Misc Shop", string, "Mua", "Huy");
			}
			case 7:
			{
				SetPVarInt(playerid, "MiscShop", 11);
				format(string, sizeof(string), "Vat pham: Restricted Last Name (CHANGE)\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]),number_format(ShopItems[32][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[32][sItemPrice]));
				ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Misc Shop", string, "Mua", "Huy");
			}
			case 8:
			{
				SetPVarInt(playerid, "MiscShop", 12);
				format(string, sizeof(string), "Vat pham: Custom User Title (NEW)\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]),number_format(ShopItems[33][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[33][sItemPrice]));
				ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Misc Shop", string, "Mua", "Huy");
			}
			case 9:
			{
				SetPVarInt(playerid, "MiscShop", 13);
				format(string, sizeof(string), "Vat pham: Custom User Title (CHANGE)\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]),number_format(ShopItems[34][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[34][sItemPrice]));
				ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Misc Shop", string, "Mua", "Huy");
			}
			case 10:
			{
				SetPVarInt(playerid, "MiscShop", 14);
				format(string, sizeof(string), "Vat pham: Teamspeak User Channel\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]),number_format(ShopItems[35][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[35][sItemPrice]));
				ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Misc Shop", string, "Mua", "Huy");
			}
			case 11:
			{
				new bdialog[145];
				format(bdialog, sizeof(bdialog), "Small Backpack (Credits: {FFD700}%s{A9C4E4})\nMedium Backpack (Credits: {FFD700}%s{A9C4E4})\nLarge Backpack (Credits: {FFD700}%s{A9C4E4})",
				number_format(ShopItems[36][sItemPrice]), number_format(ShopItems[37][sItemPrice]), number_format(ShopItems[38][sItemPrice]));
				ShowPlayerDialogEx(playerid, DIALOG_BACKPACKS, DIALOG_STYLE_LIST, "Misc Shop", bdialog, "Chon", "Huy");
			}
			case 12:
			{
				SetPVarInt(playerid, "MiscShop", 18);
				format(string, sizeof(string), "Vat pham: Deluxe Car Alarm\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]),number_format(ShopItems[39][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[39][sItemPrice]));
				ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Misc Shop", string, "Mua", "Huy");
			}
		}
	}
	if(dialogid == DIALOG_BACKPACKS && response)
	{
		new bdialog[170];
		switch(listitem)
		{
			case 0:
			{
				SetPVarInt(playerid, "MiscShop", 15); // small backpack
				format(bdialog, sizeof(bdialog), "Vat pham: Small Backpack\nThuc an: 1 Suat\nMa tuy: 30 Gram\nVu khi: 1 Khau\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]),number_format(ShopItems[36][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[36][sItemPrice]));
				ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Misc Shop", bdialog, "Mua", "Huy");
			}
			case 1:
			{
				SetPVarInt(playerid, "MiscShop", 16); // med backpack
				format(bdialog, sizeof(bdialog), "Vat pham: Medium Backpack\nThuc an: 3 Suat\nMa tuy: 50 Gram\nVu khi: 2 Khau\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]),number_format(ShopItems[37][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[37][sItemPrice]));
				ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Misc Shop", bdialog, "Mua", "Huy");
			}
			case 2:
			{
				SetPVarInt(playerid, "MiscShop", 17); // large backpack
				format(bdialog, sizeof(bdialog), "Vat pham: Large Backpack\nThuc an: 5 Suat\nMa tuy: 80 Gram\nVu khi: 4 Khau\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]),number_format(ShopItems[38][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[38][sItemPrice]));
				ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Misc Shop", bdialog, "Mua", "Huy");
			}
		}
	}
	if(dialogid == DIALOG_MISCSHOP2 && response)
	{
		if(GetPVarInt(playerid, "MiscShop") == 1)
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[6][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			else if(PlayerInfo[playerid][pTable] == 1)
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban da co ban Poker.");

			else
			{
				AmountSold[6]++;
				AmountMade[6] += ShopItems[6][sItemPrice];
				//ShopItems[6][sSold]++;
				//ShopItems[6][sMade] += ShopItems[6][sItemPrice];
				new szQuery[128];
				mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold6` = '%d', `AmountMade6` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[6], AmountMade[6]);
				mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

				GivePlayerCredits(playerid, -ShopItems[6][sItemPrice], 1);
				printf("Price6: %d", 250);
				PlayerInfo[playerid][pTable] = 1;

				format(string, sizeof(string), "[SHOPMISC] [User: %s(%i)] [IP: %s] [Credits: %s] [Pokertable] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[6][sItemPrice]));
				Log("logs/credits.log", string), print(string);

				format(string, sizeof(string), "Ban da mua Poker Table gia %s credits.", number_format(ShopItems[6][sItemPrice]));
				SendClientMessageEx(playerid, COLOR_CYAN, string);
				DeletePVar(playerid, "MiscShop");
			}
		}
		else if(GetPVarInt(playerid, "MiscShop") == 2)
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[7][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			else if(PlayerInfo[playerid][pBoombox] == 1)
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban da co boombox.");

			else
			{
				AmountSold[7]++;
				AmountMade[7] += ShopItems[7][sItemPrice];
				//ShopItems[7][sSold]++;
				//ShopItems[7][sMade] += ShopItems[7][sItemPrice];
				new szQuery[128];
				mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold7` = '%d', `AmountMade7` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[7], AmountMade[7]);
				mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

				GivePlayerCredits(playerid, -ShopItems[7][sItemPrice], 1);
				printf("Price7: %d", ShopItems[7][sItemPrice]);
				PlayerInfo[playerid][pBoombox] = 1;

				format(string, sizeof(string), "[SHOPMISC] [User: %s(%i)] [IP: %s] [Credits: %s] [Boombox] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[7][sItemPrice]));
				Log("logs/credits.log", string), print(string);

				format(string, sizeof(string), "Ban da mua boombox gia %s credits.", number_format(ShopItems[7][sItemPrice]));
				SendClientMessageEx(playerid, COLOR_CYAN, string);
				DeletePVar(playerid, "MiscShop");
			}
		}
		else if(GetPVarInt(playerid, "MiscShop") == 3)
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[8][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			AmountSold[8]++;
			AmountMade[8] += ShopItems[8][sItemPrice];
			//ShopItems[8][sSold]++;
			//ShopItems[8][sMade] += ShopItems[8][sItemPrice];
			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold8` = '%d', `AmountMade8` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[8], AmountMade[8]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			GivePlayerCredits(playerid, -ShopItems[8][sItemPrice], 1);
			printf("Price8: %d", ShopItems[8][sItemPrice]);
			PlayerInfo[playerid][pPaintTokens] += 100;

			format(string, sizeof(string), "[SHOPMISC] [User: %s(%i)] [IP: %s] [Credits: %s] [100 Paintball Tokens] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[8][sItemPrice]));
			Log("logs/credits.log", string), print(string);

			format(string, sizeof(string), "Ban da mua 100 paintball tokens gia %s credits.", number_format(ShopItems[8][sItemPrice]));
			SendClientMessageEx(playerid, COLOR_CYAN, string);
			DeletePVar(playerid, "MiscShop");
		}
		else if(GetPVarInt(playerid, "MiscShop") == 4)
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[9][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			AmountSold[9]++;
			AmountMade[9] += ShopItems[9][sItemPrice];
			//ShopItems[9][sSold]++;
			//ShopItems[9][sMade] += ShopItems[9][sItemPrice];
			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold9` = '%d', `AmountMade9` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[9], AmountMade[9]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			GivePlayerCredits(playerid, -ShopItems[9][sItemPrice], 1);
			printf("Price9: %d", ShopItems[9][sItemPrice]);
			PlayerInfo[playerid][pEXPToken] += 1;

			format(string, sizeof(string), "[SHOPMISC] [User: %s(%i)] [IP: %s] [Credits: %s] [EXP Token] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[9][sItemPrice]));
			Log("logs/credits.log", string), print(string);

			format(string, sizeof(string), "Ban da mua EXP Token gia %s credits.", number_format(ShopItems[9][sItemPrice]));
			SendClientMessageEx(playerid, COLOR_CYAN, string);
			DeletePVar(playerid, "MiscShop");
		}
		else if(GetPVarInt(playerid, "MiscShop") == 5)
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[10][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			AmountSold[10]++;
			AmountMade[10] += ShopItems[10][sItemPrice];
			//ShopItems[10][sSold]++;
			//ShopItems[10][sMade] += ShopItems[10][sItemPrice];
			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold10` = '%d', `AmountMade10` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[10], AmountMade[10]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			GivePlayerCredits(playerid, -ShopItems[10][sItemPrice], 1);
			printf("Price10: %d", ShopItems[10][sItemPrice]);
			PlayerInfo[playerid][pFirework] += 5;

			format(string, sizeof(string), "[SHOPMISC] [User: %s(%i)] [IP: %s] [Credits: %s] [Firework X5] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[10][sItemPrice]));
			Log("logs/credits.log", string), print(string);

			format(string, sizeof(string), "Ban da mua 5 fireworks gia %s credits.", number_format(ShopItems[10][sItemPrice]));
			SendClientMessageEx(playerid, COLOR_CYAN, string);
			DeletePVar(playerid, "MiscShop");
		}
		else if(GetPVarInt(playerid, "MiscShop") == 6)
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[22][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			GivePlayerCredits(playerid, -ShopItems[22][sItemPrice], 1);
			printf("Price22: %d", ShopItems[22][sItemPrice]);

			AmountSold[22]++;
			AmountMade[22] += ShopItems[22][sItemPrice];
			//ShopItems[22][sSold]++;
			//ShopItems[22][sMade] += ShopItems[22][sItemPrice];
			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold22` = '%d', `AmountMade22` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[22], AmountMade[22]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			AddFlag(playerid, INVALID_PLAYER_ID, "Purchased Custom License Plate (Credits)");
			SendReportToQue(playerid, "Custom License Plate (Credits)", 2, 2);
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua Custom License Plate gia %s credits.", number_format(ShopItems[22][sItemPrice]));
			SendClientMessageEx(playerid, COLOR_CYAN, "Hay lien he senior admin de duoc cap Custom License Plate.");

			format(string, sizeof(string), "[Custom License Plate] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[22][sItemPrice]));
			Log("logs/credits.log", string), print(string);
		}
		else if(GetPVarInt(playerid, "MiscShop") == 7) // Vehicle Slots
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[23][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			GivePlayerCredits(playerid, -ShopItems[23][sItemPrice], 1);
			printf("Price23: %d", ShopItems[23][sItemPrice]);

			AmountSold[23]++;
			AmountMade[23] += ShopItems[23][sItemPrice];


			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold23` = '%d', `AmountMade23` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[23], AmountMade[23]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua Additional Vehicle Slot gia %s credits.", number_format(ShopItems[23][sItemPrice]));
			PlayerInfo[playerid][pVehicleSlot] += 1;
			LoadPlayerDisabledVehicles(playerid);

			format(string, sizeof(string), "[Additional Vehicle Slot] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[23][sItemPrice]));
			Log("logs/credits.log", string), print(string);
		}
		else if(GetPVarInt(playerid, "MiscShop") == 8) // Toy Slots
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[28][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			GivePlayerCredits(playerid, -ShopItems[28][sItemPrice], 1);
			printf("Price28: %d", ShopItems[28][sItemPrice]);

			AmountSold[28]++;
			AmountMade[28] += ShopItems[28][sItemPrice];


			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold28` = '%d', `AmountMade28` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[28], AmountMade[28]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua Additional Toy Slot gia %s credits.", number_format(ShopItems[28][sItemPrice]));
			PlayerInfo[playerid][pToySlot] += 1;
			LoadPlayerDisabledVehicles(playerid);

			format(string, sizeof(string), "[Additional Toy Slot] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[28][sItemPrice]));
			Log("logs/credits.log", string), print(string);
		}
		else if(GetPVarInt(playerid, "MiscShop") == 9) // Spawn at Gold VIP+ room
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[30][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			GivePlayerCredits(playerid, -ShopItems[30][sItemPrice], 1);
			printf("Price30: %d", ShopItems[30][sItemPrice]);

			AmountSold[30]++;
			AmountMade[30] += ShopItems[30][sItemPrice];


			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold30` = '%d', `AmountMade30` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[30], AmountMade[30]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua luot hoi sinh tai phong Gold VIP+, dung sau lan chet tiep theo.", number_format(ShopItems[30][sItemPrice]));

			PlayerInfo[playerid][pVIPSpawn] = 1;
			OnPlayerStatsUpdate(playerid);

			format(string, sizeof(string), "[Spawn at Gold VIP+ room] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[30][sItemPrice]));
			Log("logs/credits.log", string), print(string);
		}
		else if(GetPVarInt(playerid, "MiscShop") == 10) // Restricted Last Name (NEW)
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[31][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			GivePlayerCredits(playerid, -ShopItems[31][sItemPrice], 1);
			printf("Price31: %d", ShopItems[31][sItemPrice]);

			AmountSold[31]++;
			AmountMade[31] += ShopItems[31][sItemPrice];

			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold31` = '%d', `AmountMade31` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[31], AmountMade[31]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			AddFlag(playerid, INVALID_PLAYER_ID, "Purchased Restricted Last Name (NEW) (Credits)");
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua Restricted Last Name (NEW) gia %s credits.", number_format(ShopItems[31][sItemPrice]));
			SendClientMessageEx(playerid, COLOR_GREY, "Hay lien he thanh vien Customer Relations de duoc cap Restricted Last Name (NEW).");

			format(string, sizeof(string), "[Restricted Last Name (NEW)] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[31][sItemPrice]));
			Log("logs/credits.log", string), print(string);
		}
		else if(GetPVarInt(playerid, "MiscShop") == 11) // Restricted Last Name (CHANGE)
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[32][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			GivePlayerCredits(playerid, -ShopItems[32][sItemPrice], 1);
			printf("Price32: %d", ShopItems[32][sItemPrice]);

			AmountSold[32]++;
			AmountMade[32] += ShopItems[32][sItemPrice];

			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold32` = '%d', `AmountMade32` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[32], AmountMade[32]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			AddFlag(playerid, INVALID_PLAYER_ID, "Purchased Restricted Last Name (CHANGE) (Credits)");
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua Restricted Last Name (CHANGE) gia %s credits.", number_format(ShopItems[32][sItemPrice]));
			SendClientMessageEx(playerid, COLOR_GREY, "Hay lien he thanh vien Customer Relations de duoc cap Restricted Last Name (CHANGED).");

			format(string, sizeof(string), "[Restricted Last Name (CHANGE)] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[32][sItemPrice]));
			Log("logs/credits.log", string), print(string);
		}
		else if(GetPVarInt(playerid, "MiscShop") == 12) // Custom User Title (NEW)
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[33][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			GivePlayerCredits(playerid, -ShopItems[33][sItemPrice], 1);
			printf("Price33: %d", ShopItems[33][sItemPrice]);

			AmountSold[33]++;
			AmountMade[33] += ShopItems[33][sItemPrice];

			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold33` = '%d', `AmountMade33` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[33], AmountMade[33]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			AddFlag(playerid, INVALID_PLAYER_ID, "Purchased Custom User Title (NEW) (Credits)");
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua Custom User Title (NEW) gia %s credits.", number_format(ShopItems[33][sItemPrice]));
			SendClientMessageEx(playerid, COLOR_GREY, "Hay lien he thanh vien Customer Relations de duoc cap Custom User Title (NEW).");

			format(string, sizeof(string), "[Custom User Title (NEW)] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[33][sItemPrice]));
			Log("logs/credits.log", string), print(string);
		}
		else if(GetPVarInt(playerid, "MiscShop") == 13) // Custom User Title (CHANGE)
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[34][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			GivePlayerCredits(playerid, -ShopItems[34][sItemPrice], 1);
			printf("Price34: %d", ShopItems[34][sItemPrice]);

			AmountSold[34]++;
			AmountMade[34] += ShopItems[34][sItemPrice];

			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold34` = '%d', `AmountMade34` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[34], AmountMade[34]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			AddFlag(playerid, INVALID_PLAYER_ID, "Purchased Custom User Title (CHANGE) (Credits)");
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua Restricted Custom User Title (CHANGE) gia %s credits.", number_format(ShopItems[34][sItemPrice]));
			SendClientMessageEx(playerid, COLOR_GREY, "Hay lien he thanh vien Customer Relations de duoc cap Custom User Title (CHANGE).");

			format(string, sizeof(string), "[Custom User Title (CHANGE)] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[34][sItemPrice]));
			Log("logs/credits.log", string), print(string);
		}
		else if(GetPVarInt(playerid, "MiscShop") == 14) // Teamspeak User Channel
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[35][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			GivePlayerCredits(playerid, -ShopItems[35][sItemPrice], 1);
			printf("Price35: %d", ShopItems[35][sItemPrice]);

			AmountSold[35]++;
			AmountMade[35] += ShopItems[35][sItemPrice];

			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold35` = '%d', `AmountMade35` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[35], AmountMade[35]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			AddFlag(playerid, INVALID_PLAYER_ID, "Purchased Teamspeak User Channel (Credits)");
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua Teamspeak User Channel gia %s credits.", number_format(ShopItems[35][sItemPrice]));
			SendClientMessageEx(playerid, COLOR_GREY, "Hay lien he thanh vien Customer Relations de duoc cap Teamspeak User Channel.");

			format(string, sizeof(string), "[Teamspeak User Channel] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[35][sItemPrice]));
			Log("logs/credits.log", string), print(string);
		}
		else if(GetPVarInt(playerid, "MiscShop") == 15) // Small Backpack
		{
			if(PlayerInfo[playerid][pBackpack] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Chi duoc co mot ba lo, dung /sellbackpack.");
			if(PlayerInfo[playerid][pCredits] < ShopItems[36][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			GivePlayerCredits(playerid, -ShopItems[36][sItemPrice], 1);
			printf("Price35: %d", ShopItems[36][sItemPrice]);

			AmountSold[36]++;
			AmountMade[36] += ShopItems[36][sItemPrice];

			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold36` = '%d', `AmountMade36` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[36], AmountMade[36]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);
			if(PlayerHoldingObject[playerid][9] != 0 || IsPlayerAttachedObjectSlotUsed(playerid, 9))
				RemovePlayerAttachedObject(playerid, 9), PlayerHoldingObject[playerid][9] = 0;
			SetPlayerAttachedObject(playerid, 9, 371, 1, -0.002, -0.140999, -0.01, 8.69999, 88.8, -8.79993, 1.11, 0.963);

			PlayerInfo[playerid][pBEquipped] = 1;
			PlayerInfo[playerid][pBStoredV] = INVALID_PLAYER_VEHICLE_ID;
			PlayerInfo[playerid][pBStoredH] = INVALID_HOUSE_ID;

			PlayerInfo[playerid][pBackpack] = 1;
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua Small Backpack gia %s credits.", number_format(ShopItems[36][sItemPrice]));
			SendClientMessageEx(playerid, COLOR_GREY, "Dung /backpackhelp de xem danh sach lenh.");

			format(string, sizeof(string), "[Small Backpack] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[36][sItemPrice]));
			Log("logs/credits.log", string), print(string);
		}
		else if(GetPVarInt(playerid, "MiscShop") == 16) // Medium Backpack
		{
			if(PlayerInfo[playerid][pBackpack] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Chi duoc co mot ba lo, dung /sellbackpack.");
			if(PlayerInfo[playerid][pCredits] < ShopItems[37][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			GivePlayerCredits(playerid, -ShopItems[37][sItemPrice], 1);
			printf("Price35: %d", ShopItems[37][sItemPrice]);

			AmountSold[37]++;
			AmountMade[37] += ShopItems[37][sItemPrice];

			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold37` = '%d', `AmountMade37` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[37], AmountMade[37]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);
			if(PlayerHoldingObject[playerid][9] != 0 || IsPlayerAttachedObjectSlotUsed(playerid, 9))
				RemovePlayerAttachedObject(playerid, 9), PlayerHoldingObject[playerid][9] = 0;
			SetPlayerAttachedObject(playerid, 9, 371, 1, -0.002, -0.140999, -0.01, 8.69999, 88.8, -8.79993, 1.11, 0.963);

			PlayerInfo[playerid][pBEquipped] = 1;
			PlayerInfo[playerid][pBStoredV] = INVALID_PLAYER_VEHICLE_ID;
			PlayerInfo[playerid][pBStoredH] = INVALID_HOUSE_ID;

			PlayerInfo[playerid][pBackpack] = 2;
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua Medium Backpack gia %s credits.", number_format(ShopItems[37][sItemPrice]));
			SendClientMessageEx(playerid, COLOR_GREY, "Dung /backpackhelp de xem danh sach lenh.");

			format(string, sizeof(string), "[Medium Backpack] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[37][sItemPrice]));
			Log("logs/credits.log", string), print(string);
		}
		else if(GetPVarInt(playerid, "MiscShop") == 17) // Large Backpack
		{
			if(PlayerInfo[playerid][pBackpack] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Chi duoc co mot ba lo, dung /sellbackpack.");
			if(PlayerInfo[playerid][pCredits] < ShopItems[38][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			GivePlayerCredits(playerid, -ShopItems[38][sItemPrice], 1);
			printf("Price35: %d", ShopItems[38][sItemPrice]);

			AmountSold[38]++;
			AmountMade[38] += ShopItems[38][sItemPrice];

			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold38` = '%d', `AmountMade38` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[38], AmountMade[38]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);
			if(PlayerHoldingObject[playerid][9] != 0 || IsPlayerAttachedObjectSlotUsed(playerid, 9))
				RemovePlayerAttachedObject(playerid, 9), PlayerHoldingObject[playerid][9] = 0;
			SetPlayerAttachedObject(playerid, 9, 3026, 1, -0.254999, -0.109, -0.022999, 10.6, -1.20002, 3.4, 1.265, 1.242, 1.062);

			PlayerInfo[playerid][pBEquipped] = 1;
			PlayerInfo[playerid][pBStoredV] = INVALID_PLAYER_VEHICLE_ID;
			PlayerInfo[playerid][pBStoredH] = INVALID_HOUSE_ID;

			PlayerInfo[playerid][pBackpack] = 3;
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua Large Backpack gia %s credits.", number_format(ShopItems[38][sItemPrice]));
			SendClientMessageEx(playerid, COLOR_GREY, "Dung /backpackhelp de xem danh sach lenh.");

			format(string, sizeof(string), "[Large Backpack] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[38][sItemPrice]));
			Log("logs/credits.log", string), print(string);
		}
		else if(GetPVarInt(playerid, "MiscShop") == 18) // Deluxe Car Alarm
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[39][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			if(GetPlayerVehicleCount(playerid) != 0)
			{
				SetPVarInt(playerid, "lockmenu", 4);
				for(new i=0; i<MAX_PLAYERVEHICLES; i++)
				{
					if(PlayerVehicleInfo[playerid][i][pvId] != INVALID_PLAYER_VEHICLE_ID)
					{
						SendClientMessageEx(playerid, COLOR_WHITE, "Xe %d | Ten: %s.",i+1,GetVehicleName(PlayerVehicleInfo[playerid][i][pvId]));
					}
				}
				return ShowPlayerDialogEx(playerid, DIALOG_CDLOCKMENU, DIALOG_STYLE_INPUT, "24-7","Chon xe de lap vat pham nay:", "Chon", "Huy");
			}
			else return SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong co xe de lap vat pham nay!");
		}
		else if(GetPVarInt(playerid, "MiscShop") == 19) // Furniture Bronze
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[41][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			if(PlayerInfo[playerid][pFurnitureSlots] >= MAX_FURNITURE_SLOTS) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong the mua them o noi that.");
			PlayerInfo[playerid][pFurnitureSlots] += 25;
			if(PlayerInfo[playerid][pFurnitureSlots] > MAX_FURNITURE_SLOTS) {
				PlayerInfo[playerid][pFurnitureSlots] = MAX_FURNITURE_SLOTS;
				SendClientMessageEx(playerid, COLOR_GRAD1, "So o noi that cua ban da dat toi da.");
			}
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua Furniture Pack - Bronze gia %s credits.", number_format(ShopItems[41][sItemPrice]));
			SendClientMessageEx(playerid, COLOR_GREY, "Dung /furniturehelp de xem danh sach lenh.");

			format(szMiscArray, sizeof(szMiscArray), "[Furniture Pack - Bronze] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[41][sItemPrice]));
			Log("logs/credits.log", szMiscArray), print(szMiscArray);

			GivePlayerCredits(playerid, -ShopItems[41][sItemPrice], 1);
			printf("Price43: %d", ShopItems[41][sItemPrice]);

			AmountSold[41]++;
			AmountMade[41] += ShopItems[41][sItemPrice];

			mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "UPDATE `sales` SET `TotalSold41` = '%d', `AmountMade41` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[41], AmountMade[41]);
			mysql_tquery(MainPipeline, szMiscArray, "OnQueryFinish", "i", SENDDATA_THREAD);
		}
		else if(GetPVarInt(playerid, "MiscShop") == 20) // Furniture Bronze
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[42][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			if(PlayerInfo[playerid][pFurnitureSlots] >= MAX_FURNITURE_SLOTS) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong the mua them o noi that.");
			PlayerInfo[playerid][pFurnitureSlots] += 40;
			if(PlayerInfo[playerid][pFurnitureSlots] > MAX_FURNITURE_SLOTS) {
				PlayerInfo[playerid][pFurnitureSlots] = MAX_FURNITURE_SLOTS;
				SendClientMessageEx(playerid, COLOR_GRAD1, "So o noi that cua ban da dat toi da.");
			}
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua Furniture Pack - Silver gia %s credits.", number_format(ShopItems[42][sItemPrice]));
			SendClientMessageEx(playerid, COLOR_GREY, "Dung /furniturehelp de xem danh sach lenh.");

			format(szMiscArray, sizeof(szMiscArray), "[Furniture Pack - Silver] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[42][sItemPrice]));
			Log("logs/credits.log", szMiscArray), print(szMiscArray);

			GivePlayerCredits(playerid, -ShopItems[42][sItemPrice], 1);
			printf("Price43: %d", ShopItems[42][sItemPrice]);

			AmountSold[42]++;
			AmountMade[42] += ShopItems[42][sItemPrice];

			mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "UPDATE `sales` SET `TotalSold42` = '%d', `AmountMade42` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[42], AmountMade[42]);
			mysql_tquery(MainPipeline, szMiscArray, "OnQueryFinish", "i", SENDDATA_THREAD);
		}
		else if(GetPVarInt(playerid, "MiscShop") == 21) // Furniture Gold
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[43][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			if(PlayerInfo[playerid][pFurnitureSlots] >= MAX_FURNITURE_SLOTS) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong the mua them o noi that.");
			PlayerInfo[playerid][pFurnitureSlots] += 50;
			if(PlayerInfo[playerid][pFurnitureSlots] > MAX_FURNITURE_SLOTS) {
				PlayerInfo[playerid][pFurnitureSlots] = MAX_FURNITURE_SLOTS;
				SendClientMessageEx(playerid, COLOR_GRAD1, "So o noi that cua ban da dat toi da.");
			}
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua Furniture Pack - Gold gia %s credits.", number_format(ShopItems[43][sItemPrice]));
			SendClientMessageEx(playerid, COLOR_GREY, "Dung /furniturehelp de xem danh sach lenh.");

			format(szMiscArray, sizeof(szMiscArray), "[Furniture Pack] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[43][sItemPrice]));
			Log("logs/credits.log", szMiscArray), print(szMiscArray);

			GivePlayerCredits(playerid, -ShopItems[43][sItemPrice], 1);
			printf("Price43: %d", ShopItems[43][sItemPrice]);

			AmountSold[43]++;
			AmountMade[43] += ShopItems[43][sItemPrice];

			mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "UPDATE `sales` SET `TotalSold43` = '%d', `AmountMade43` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[43], AmountMade[43]);
			mysql_tquery(MainPipeline, szMiscArray, "OnQueryFinish", "i", SENDDATA_THREAD);
		}
	    DeletePVar(playerid, "MiscShop");
	}
	if(dialogid == DIALOG_SHOPHELPMENU)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0: //VIP Shop
				{
					SetPVarInt(playerid, "ShopCheckpoint", listitem+1);
					ShowPlayerDialogEx(playerid, DIALOG_SHOPHELPMENU8, DIALOG_STYLE_MSGBOX, "VIP Shop", "Mua Bronze VIP, Silver VIP hoac Gold VIP bang /vipshop tai diem VIP ngoai moi VIP Club.\n Gia han Gold VIP bang /vipshop, nhung can co Gold VIP duoc phep gia han.\n Xem quyen loi VIP tren Shop Control Panel hoac trong /vipshop.", "Checkpoint", "Thoat");
				}
				case 1:
				{
					ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, "House Shop", "Dung /houseshop o bat ky dau de mua nha, doi noi that hoac mua luot chuyen nha. \nXem them thong tin nha tren Shop Control Panel.", "Thoat", "");
				}
				case 2:
				{
					ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, "Business Shop", "Dung /businessshop de mua Business hoac gia han Business hien tai.\n Hay doc luat Business tren dien dan va thong tin tren Shop Control Panel. Chu y: Purchase Business liet ke doanh nghiep dang rao ban.", "Thoat", "");
				}
				case 3:
				{
					ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, "Toy Shop", "Dung /toyshop tai cua hang quan ao de mua toy. Xem danh muc va nhan vao toy de mua!\n Toy mua xong duoc cat vao o toy.", "Thoat", "");
				}
				case 4:
				{
					ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, "Miscellaneous Shop", "De mua do nhu Poker Table va EXP tokens, den 24/7 va dung /miscshop.\n Danh sach san pham se hien ra. Hay theo doi cac mat hang moi!", "Thoat", "");
				}
				case 5:
				{
					ShowPlayerDialogEx(playerid, DIALOG_SHOPHELPMENU2, DIALOG_STYLE_MSGBOX, "Car Shop", "De mua xe tuy chon, dung /carshop tai ben cang va cac dia diem khac.\n Dung /carshop de xem xe dang ban va nhan vao xe de mua!\n Xe se duoc them vao o xe cua ban sau khi mua.", "Checkpoint", "Thoat");
				}
				case 6:
				{
					ShowPlayerDialogEx(playerid, DIALOG_SHOPHELPMENU3, DIALOG_STYLE_MSGBOX, "Plane Shop", "De mua xe tuy chon, dung /carshop tai ben cang va cac dia diem khac.\n Dung /carshop de xem xe dang ban va nhan vao xe de mua!\n Xe se duoc them vao o xe cua ban sau khi mua.", "Checkpoint", "Thoat");
				}
				case 7:
				{
					ShowPlayerDialogEx(playerid, DIALOG_SHOPHELPMENU5, DIALOG_STYLE_MSGBOX, "Boat Shop", "De mua xe tuy chon, dung /carshop tai ben cang va cac dia diem khac.\n Dung /carshop de xem xe dang ban va nhan vao xe de mua!\n Xe se duoc them vao o xe cua ban sau khi mua.", "Checkpoint", "Thoat");
				}
			}
		}
	}
	if(dialogid == DIALOG_SHOPHELPMENU8)
	{
		if(response)
		{
			 ShowPlayerDialogEx(playerid, DIALOG_SHOPHELPMENU9, DIALOG_STYLE_LIST, "Tim Boat Shop", "Los Santos\nSan Fierro\nLas Venturas", "Tim vi tri", "Huy");
		}
	}
	if(dialogid == DIALOG_SHOPHELPMENU9)
	{
		if(response)
		{
			if(CheckPointCheck(playerid))
				return SendClientMessageEx(playerid, COLOR_WHITE, "Hay huy checkpoint hien tai truoc (ban dang giu goi vat lieu hoac co checkpoint khac).");

			SetPVarInt(playerid, "ShopCheckpoint", 1);
			switch(listitem)
			{
				case 0: SetPlayerCheckpoint(playerid, 1811.3344, -1569.4244, 13.4811, 5.0);
				case 1: SetPlayerCheckpoint(playerid, -2443.6013, 499.7480, 30.0906, 5.0);
				case 2: SetPlayerCheckpoint(playerid,  1934.1083, 1364.5004, 9.2578, 5.0);
			}
		}
	}
	if(dialogid == DIALOG_SHOPHELPMENU5)
	{
		if(response)
		{
			 ShowPlayerDialogEx(playerid, DIALOG_SHOPHELPMENU6, DIALOG_STYLE_LIST, "Tim Boat Shop", "Los Santos\nSan Fierro\nBayside", "Tim vi tri", "Huy");
		}
	}
	if(dialogid == DIALOG_SHOPHELPMENU6)
	{
		if(response)
		{
			if(CheckPointCheck(playerid))
				return SendClientMessageEx(playerid, COLOR_WHITE, "Hay huy checkpoint hien tai truoc (ban dang giu goi vat lieu hoac co checkpoint khac).");

			SetPVarInt(playerid, "ShopCheckpoint", 1);
			switch(listitem)
			{
				case 0: SetPlayerCheckpoint(playerid, 723.1553, -1494.4547, 1.9343, 5.0);
				case 1: SetPlayerCheckpoint(playerid, -2975.8950, 505.1325, 2.4297, 5.0);
				case 2: SetPlayerCheckpoint(playerid, -2214.1636, 2422.4763, 2.496, 5.0);
			}
		}
	}
	if(dialogid == DIALOG_SHOPHELPMENU3)
	{
		if(response)
		{
			 ShowPlayerDialogEx(playerid, DIALOG_SHOPHELPMENU4, DIALOG_STYLE_LIST, "Tim Plane Shop", "Los Santos Airport\nLas Venturas Airport", "Tim vi tri", "Huy");
		}
	}
	if(dialogid == DIALOG_SHOPHELPMENU4)
	{
		if(response)
		{
			if(CheckPointCheck(playerid))
				return SendClientMessageEx(playerid, COLOR_WHITE, "Hay huy checkpoint hien tai truoc (ban dang giu goi vat lieu hoac co checkpoint khac).");

			SetPVarInt(playerid, "ShopCheckpoint", 1);
			switch(listitem)
			{
				case 0: SetPlayerCheckpoint(playerid, 1891.9105, -2279.6174, 13.5469, 5.0);
				case 1: SetPlayerCheckpoint(playerid, 1632.0836, 1551.7365, 10.8061, 5.0);
			}
		}
	}
	if(dialogid == DIALOG_SHOPHELPMENU2)
	{
		if(response)
		{
			ShowPlayerDialogEx(playerid, DIALOG_SHOPHELPMENU7, DIALOG_STYLE_LIST, "Tim Car Shop", "Los Santos\nSan Fierro\nLas Venturas", "Tim vi tri", "Huy");
		}
	}
	if(dialogid == DIALOG_SHOPHELPMENU7)
	{
		if(response)
		{
			if(CheckPointCheck(playerid))
				return SendClientMessageEx(playerid, COLOR_WHITE, "Hay huy checkpoint hien tai truoc (ban dang giu goi vat lieu hoac co checkpoint khac).");

			SetPVarInt(playerid, "ShopCheckpoint", 1);
			switch(listitem)
			{
				case 0: SetPlayerCheckpoint(playerid, 2280.5720, -2325.2490, 13.5469, 5.0);
				case 1: SetPlayerCheckpoint(playerid, -1731.1923, 127.4794, 3.2976, 5.0);
				case 2: SetPlayerCheckpoint(playerid, 1663.9569, 1628.5106, 10.8203, 5.0);
			}
		}
	}
	if(dialogid == DIALOG_RENTACAR)
	{
		if(response)
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[20][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			new
				szQuery[215];

			AmountSold[20]++;
			AmountMade[20] += ShopItems[20][sItemPrice];

			//ShopItems[20][sSold]++;
			//ShopItems[20][sMade] += ShopItems[20][sItemPrice];

			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold20` = '%d', `AmountMade20` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[20], AmountMade[20]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			if(IsPlayerInRangeOfPoint(playerid, 4, 1102.8999, -1440.1669, 15.7969))
			{
				mysql_format(MainPipeline, szQuery, sizeof(szQuery), "INSERT INTO `rentedcars` (`sqlid`, `modelid`, `posx`, `posy`, `posz`, `posa`, `spawned`, `hours`) VALUES ('%d', '%d', '%f', '%f', '%f', '%f', '1', '180')", GetPlayerSQLId(playerid), GetPVarInt(playerid, "VehicleID"), 1060.4927,-1474.9323,13.1905,345.2816);
				mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

				SetPVarInt(playerid, "RentedVehicle", CreateVehicle(GetPVarInt(playerid, "VehicleID"), 1060.4927, -1474.9323, 13.1905, 345.2816, random(128), random(128), 2000000));
			}
			else if(IsPlayerInRangeOfPoint(playerid, 4, 1796.0620, -1588.5571, 13.4951))
			{
				mysql_format(MainPipeline, szQuery, sizeof(szQuery), "INSERT INTO `rentedcars` (`sqlid`, `modelid`, `posx`, `posy`, `posz`, `posa`, `spawned`, `hours`) VALUES ('%d', '%d', '%f', '%f', '%f', '%f', '1', '180')", GetPlayerSQLId(playerid), GetPVarInt(playerid, "VehicleID"), 1787.6924, -1605.8617,13.1750, 76.7439);
				mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

				SetPVarInt(playerid, "RentedVehicle", CreateVehicle(GetPVarInt(playerid, "VehicleID"), 1787.6924, -1605.8617, 13.1750, 76.7439, random(128), random(128), 2000000));
			}

			GivePlayerCredits(playerid, -ShopItems[20][sItemPrice], 1);
			printf("Price20: %d", ShopItems[20][sItemPrice]);
			IsPlayerEntering{playerid} = true;
			PutPlayerInVehicle(playerid, GetPVarInt(playerid, "RentedVehicle"), 0);

			format(szQuery, sizeof(szQuery), "[RentaCar] [User: %s(%i)] [IP: %s] [Model: %d] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), GetPVarInt(playerid, "VehicleID"), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[20][sItemPrice]));
			Log("logs/credits.log", szQuery), print(szQuery);

			strunpack(vehicleName, VehicleName[GetPVarInt(playerid, "VehicleID") - 400], sizeof(vehicleName));
			SendClientMessageEx(playerid, COLOR_CYAN, "[Rent a Car] Da thue %s gia %s credits, xe dung duoc 3 gio.", vehicleName, number_format(ShopItems[20][sItemPrice]));
			SendClientMessageEx(playerid, COLOR_CYAN, "Cac lenh kha dung: /park, /stoprentacar, /trackcar");

			SetPVarInt(playerid, "RentedHours", 180);
			VehicleFuel[GetPVarInt(playerid, "RentedVehicle")] = 100;
		}
		DeletePVar(playerid, "VehicleID");
	}
	if(dialogid == DIALOG_CARSHOP)
	{
		if(response)
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[5][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			else if(!vehicleCountCheck(playerid))
				return ShowPlayerDialogEx(playerid, 0, DIALOG_STYLE_MSGBOX, "Loi", "Ban da so huu toi da so xe!", "Dong y", "");

			else if(!vehicleSpawnCountCheck(playerid))
				return ShowPlayerDialogEx(playerid, 0, DIALOG_STYLE_MSGBOX, "Loi", "Ban da lay ra toi da so xe, hay cat bot truoc.", "Dong y", "");

			else
			{
				if(GetPVarType(playerid, "BoatShop"))
				{
					new createdcar;
					if(IsPlayerInRangeOfPoint(playerid, 4, -2214.1636, 2422.4763, 2.4961))
					{
						createdcar = CreatePlayerVehicle(playerid, GetPlayerFreeVehicleId(playerid), GetPVarInt(playerid, "VehicleID"), -2218.4795, 2424.9880, -0.3707, 314.4837, 0, 0, 2000000, 0, 0);
					}
					else if(IsPlayerInRangeOfPoint(playerid, 4, -2975.8950, 505.1325, 2.4297))
					{
						createdcar = CreatePlayerVehicle(playerid, GetPlayerFreeVehicleId(playerid), GetPVarInt(playerid, "VehicleID"), -2975.4841, 509.6216, -0.4241, 89.7179, 0, 0, 2000000, 0, 0);
					}
					else if(IsPlayerInRangeOfPoint(playerid, 4, 723.1553, -1494.4547, 1.9343))
					{
						createdcar = CreatePlayerVehicle(playerid, GetPlayerFreeVehicleId(playerid), GetPVarInt(playerid, "VehicleID"), 723.4292, -1505.4899, -0.4145, 180.4212, 0, 0, 2000000, 0, 0);
					}
					else if(IsPlayerInRangeOfPoint(playerid, 4, 2974.7520, -1462.9265, 2.8184))
					{
						createdcar = CreatePlayerVehicle(playerid, GetPlayerFreeVehicleId(playerid), GetPVarInt(playerid, "VehicleID"), 2996.4255, -1467.3026, 2.8184, 0, 0, 0, 2000000, 0, 0);
						DeletePVar(playerid, "ShopTP");
					}

					GivePlayerCredits(playerid, -ShopItems[5][sItemPrice], 1);
					printf("Price5: %d", ShopItems[5][sItemPrice]);
					IsPlayerEntering{playerid} = true;
					SetPlayerVirtualWorld(playerid, 0);
					PutPlayerInVehicle(playerid, createdcar, 0);
					AmountSold[5]++;
					AmountMade[5] += ShopItems[5][sItemPrice];
					//ShopItems[5][sSold]++;
					//ShopItems[5][sMade] += ShopItems[5][sItemPrice];
					new szQuery[128];
					mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold5` = '%d', `AmountMade5` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[5], AmountMade[5]);
					mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

					new Float: arr_fPlayerPos[4];

					GetPlayerPos(playerid, arr_fPlayerPos[0], arr_fPlayerPos[1], arr_fPlayerPos[2]);
					GetPlayerFacingAngle(playerid, arr_fPlayerPos[3]);

					strunpack(vehicleName, VehicleName[GetPVarInt(playerid, "VehicleID") - 400], sizeof(vehicleName));
					format(string, sizeof(string), "[CAR %i] [User: %s(%i)] [IP: %s] [Credits: %s] [Vehicle: %s] [Price: %s]", AmountSold[5], GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), vehicleName, number_format(ShopItems[5][sItemPrice]));
					Log("logs/credits.log", string), print(string);

					strunpack(vehicleName, VehicleName[GetPVarInt(playerid, "VehicleID") - 400], sizeof(vehicleName));
					format(string, sizeof(string), "[Car Shop] Da mua %s gia %s credits.", vehicleName, number_format(ShopItems[5][sItemPrice]));
					SendClientMessageEx(playerid, COLOR_CYAN, string);
					DeletePVar(playerid, "BoatShop");
				}
				else
				{
					GivePlayerCredits(playerid, -ShopItems[5][sItemPrice], 1);
					printf("Price5: %d", ShopItems[5][sItemPrice]);

					AmountSold[5]++;
					AmountMade[5] += ShopItems[5][sItemPrice];
					//ShopItems[5][sSold]++;
					//ShopItems[5][sMade] += ShopItems[5][sItemPrice];

					new szQuery[128];
					mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold5` = '%d', `AmountMade5` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[5], AmountMade[5]);
					mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

					new Float: arr_fPlayerPos[4], createdcar;

					GetPlayerPos(playerid, arr_fPlayerPos[0], arr_fPlayerPos[1], arr_fPlayerPos[2]);
					GetPlayerFacingAngle(playerid, arr_fPlayerPos[3]);
					if(IsPlayerInDynamicArea(playerid, NGGShop))
					{
						arr_fPlayerPos[0] = 2923.3220;
						arr_fPlayerPos[1] = -1276.6011;
						arr_fPlayerPos[2] = 10.9809;
						arr_fPlayerPos[3] = 11.4626;
						if(IsAPlane(GetPVarInt(playerid, "VehicleID"), 1))
						{
							arr_fPlayerPos[0] = 1937.1254;
							arr_fPlayerPos[1] = -2494.1057;
							arr_fPlayerPos[2] = 14.4581;
							arr_fPlayerPos[3] = 90.2559;
						}
						DeletePVar(playerid, "ShopTP");
					}
					createdcar = CreatePlayerVehicle(playerid, GetPlayerFreeVehicleId(playerid), GetPVarInt(playerid, "VehicleID"), arr_fPlayerPos[0], arr_fPlayerPos[1], arr_fPlayerPos[2], arr_fPlayerPos[3], 0, 0, 2000000, 0, 0);
					strunpack(vehicleName, VehicleName[GetPVarInt(playerid, "VehicleID") - 400], sizeof(vehicleName));
					format(string, sizeof(string), "[CAR %i] [User: %s(%i)] [IP: %s] [Credits: %s] [Vehicle: %s] [Price: %s]", AmountSold[5], GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), vehicleName, number_format(ShopItems[5][sItemPrice]));
					Log("logs/credits.log", string), print(string);
					IsPlayerEntering{playerid} = true;
					SetPlayerVirtualWorld(playerid, 0);
					PutPlayerInVehicle(playerid, createdcar, 0);
					strunpack(vehicleName, VehicleName[GetPVarInt(playerid, "VehicleID") - 400], sizeof(vehicleName));
					format(string, sizeof(string), "[Car Shop] Da mua %s gia %s credits.", vehicleName, number_format(ShopItems[5][sItemPrice]));
					SendClientMessageEx(playerid, COLOR_CYAN, string);
				}
			}
		}
		DeletePVar(playerid, "VehicleID");
	}
	if(dialogid == DIALOG_CARSHOP2)
	{
		if(response)
		{
			if(PlayerInfo[playerid][pCarVoucher] == 0)
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co Restricted Vehicle Voucher. ");

			else if(!vehicleCountCheck(playerid))
				return ShowPlayerDialogEx(playerid, 0, DIALOG_STYLE_MSGBOX, "Loi", "Ban da so huu toi da so xe!", "Dong y", "");

			else if(!vehicleSpawnCountCheck(playerid))
				return ShowPlayerDialogEx(playerid, 0, DIALOG_STYLE_MSGBOX, "Loi", "Ban da lay ra toi da so xe, hay cat bot truoc.", "Dong y", "");

			else
			{
				PlayerInfo[playerid][pCarVoucher]--;
				new Float: arr_fPlayerPos[4], createdcar;
				GetPlayerPos(playerid, arr_fPlayerPos[0], arr_fPlayerPos[1], arr_fPlayerPos[2]);
				GetPlayerFacingAngle(playerid, arr_fPlayerPos[3]);
				createdcar = CreatePlayerVehicle(playerid, GetPlayerFreeVehicleId(playerid), GetPVarInt(playerid, "VehicleID"), arr_fPlayerPos[0], arr_fPlayerPos[1], arr_fPlayerPos[2], arr_fPlayerPos[3], 0, 0, 2000000, 0, 0);
				strunpack(vehicleName, VehicleName[GetPVarInt(playerid, "VehicleID") - 400], sizeof(vehicleName));
				format(string, sizeof(string), "[CAR %i] [User: %s(%i)] [IP: %s] [Credits: %s] [Vehicle: %s] [Price: %s]", AmountSold[5], GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), vehicleName, number_format(ShopItems[5][sItemPrice]));
				Log("logs/carvoucher.log", string), print(string);
				IsPlayerEntering{playerid} = true;
				SetPlayerVirtualWorld(playerid, 0);
				PutPlayerInVehicle(playerid, createdcar, 0);
				strunpack(vehicleName, VehicleName[GetPVarInt(playerid, "VehicleID") - 400], sizeof(vehicleName));
				format(string, sizeof(string), "[Car Shop] Da mua %s bang 1 restricted car voucher.", vehicleName);
				SendClientMessageEx(playerid, COLOR_CYAN, string);
			}
		}
		DeletePVar(playerid, "VehicleID");
	}
	if(dialogid == DIALOG_EDITSHOPBUSINESS)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0: // Add Business
				{
					for (new i; i < sizeof(BusinessSales); i++)
					{
						if(BusinessSales[i][bAvailable] == 0)
						{
							SetPVarInt(playerid, "EditingSale", i);
							break;
						}
					}
					ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS2, DIALOG_STYLE_INPUT, "Them doanh nghiep [1/4]","Nhap ID doanh nghiep muon ban.", "Tiep", "Huy");
				}
				case 1: // Edit Business
				{
					new Count, szDialog[500];
					for (new i; i < sizeof(BusinessSales); i++)
					{
						if(BusinessSales[i][bAvailable] == 1 || BusinessSales[i][bAvailable] == 3)
						{
							format(szDialog, sizeof(szDialog), "%s\n(%d) %s | Loai: %d | Credits: %s", szDialog, BusinessSales[i][bBusinessID], BusinessSales[i][bText],BusinessSales[i][bType], number_format(BusinessSales[i][bPrice]));
							Selected[playerid][Count] = i;
							Count++;
						}
					}
					ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS8, DIALOG_STYLE_LIST, "Chon doanh nghiep can sua.", szDialog, "Chon", "Thoat");
				}
				case 2: // View Businesses Sold
				{
					new Count, szDialog[500];
					for (new i; i < sizeof(BusinessSales); i++)
					{
						if(BusinessSales[i][bAvailable] == 2)
						{
							format(szDialog, sizeof(szDialog), "%s\n(Business ID: %d)%s | (Credits: %s) | Nguoi mua: %d", szDialog, BusinessSales[i][bBusinessID], BusinessSales[i][bText], number_format(BusinessSales[i][bPrice]), BusinessSales[i][bPurchased]);
							Selected[playerid][Count] = i;
							Count++;
						}
					}
					ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS7, DIALOG_STYLE_LIST, "Doanh nghiep da mua", szDialog, "Dat lai", "Thoat");
				}
			}
		}
	}
	if(dialogid == DIALOG_EDITSHOPBUSINESS8)
	{
		if(response)
		{
			new szDialog[128];
			SetPVarInt(playerid, "BusinessList", listitem);
			format(szDialog, sizeof(szDialog), "Business ID: %d\nMo ta: %s\nLoai: %d\nCredits: %s\nDang ban: %d", BusinessSales[Selected[playerid][listitem]][bBusinessID], BusinessSales[Selected[playerid][listitem]][bText],BusinessSales[Selected[playerid][listitem]][bType],
			number_format(BusinessSales[Selected[playerid][listitem]][bPrice]), BusinessSales[Selected[playerid][listitem]][bAvailable]);
			ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS9, DIALOG_STYLE_LIST, "Chon doanh nghiep can sua.", szDialog, "Dat lai", "Thoat");
		}
	}
	if(dialogid == DIALOG_EDITSHOPBUSINESS9)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0: // Business ID
				{
					ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS10, DIALOG_STYLE_INPUT, "Sua doanh nghiep","Nhap ID doanh nghiep muon ban.", "Gui", "Quay lai");
				}
				case 1: // Text
				{
					ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS11, DIALOG_STYLE_INPUT, "Sua doanh nghiep","Nhap mo ta doanh nghiep.", "Gui", "Quay lai");
				}
				case 2: // Type
				{
					ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS12, DIALOG_STYLE_INPUT, "Sua doanh nghiep","Nhap loai doanh nghiep. (1-3)", "Gui", "Quay lai");
				}
				case 3: // Credits
				{
					ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS13, DIALOG_STYLE_INPUT, "Sua doanh nghiep","Nhap so credits can de mua doanh nghiep.", "Gui", "Quay lai");
				}
				case 4: // Available
				{
					if(BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bAvailable] == 1)
					{
						BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bAvailable] = 3;
						SendClientMessageEx(playerid, COLOR_CYAN, "Doanh nghiep do da duoc ngung ban.");
					}
					else
					{
						BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bAvailable] = 1;
						SendClientMessageEx(playerid, COLOR_CYAN, "Doanh nghiep do da duoc mo ban.");
					}
					new szDialog[128];
					format(szDialog, sizeof(szDialog), "Business ID: %d\nMo ta: %s\nLoai: %d\nCredits: %s\nDang ban: %d", BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bBusinessID], BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bText],BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bType],
					number_format(BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bPrice]), BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bAvailable]);
					ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS9, DIALOG_STYLE_LIST, "Chon doanh nghiep can sua.", szDialog, "Chon", "Thoat");
				}
			}
		}
		else
		{
			SaveBusinessSale(Selected[playerid][GetPVarInt(playerid, "BusinessList")]);
			DeletePVar(playerid, "BusinessList");
		}
	}
	if(dialogid == DIALOG_EDITSHOPBUSINESS13)
	{
		if(response)
		{
			new BusinessID;
			if (sscanf(inputtext, "d", BusinessID))
				return ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS13, DIALOG_STYLE_INPUT, "Sua doanh nghiep","Nhap so credits can de mua doanh nghiep.", "Gui", "Quay lai");

			if(BusinessID < 0)
				return ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS13, DIALOG_STYLE_INPUT, "Sua doanh nghiep","Nhap so credits can de mua doanh nghiep.", "Gui", "Quay lai");

			new szDialog[128];
			BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bPrice] = BusinessID;
			format(szDialog, sizeof(szDialog), "Business ID: %d\nMo ta: %s\nLoai: %d\nCredits: %s\nDang ban: %d", BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bBusinessID], BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bText],BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bType],
			number_format(BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bPrice]), BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bAvailable]);
			ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS9, DIALOG_STYLE_LIST, "Chon doanh nghiep can sua.", szDialog, "Chon", "Thoat");
		}
		else
		{
			new szDialog[128];
			format(szDialog, sizeof(szDialog), "Business ID: %d\nMo ta: %s\nLoai: %d\nCredits: %s\nDang ban: %d", BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bBusinessID], BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bText],BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bType],
			number_format(BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bPrice]), BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bAvailable]);
			ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS9, DIALOG_STYLE_LIST, "Chon doanh nghiep can sua.", szDialog, "Chon", "Thoat");
		}
	}
	if(dialogid == DIALOG_EDITSHOPBUSINESS12)
	{
		if(response)
		{
			new BusinessID;
			if (sscanf(inputtext, "d", BusinessID))
				return ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS12, DIALOG_STYLE_INPUT, "Sua doanh nghiep","Nhap loai doanh nghiep. (1-3)", "Gui", "Quay lai");

			if(BusinessID < 1 || BusinessID > 3)
				return ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS12, DIALOG_STYLE_INPUT, "Sua doanh nghiep","Nhap loai doanh nghiep. (1-3)", "Gui", "Quay lai");

			new szDialog[128];
			BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bType] = BusinessID;
			format(szDialog, sizeof(szDialog), "Business ID: %d\nMo ta: %s\nLoai: %d\nCredits: %s\nDang ban: %d", BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bBusinessID], BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bText],BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bType],
			number_format(BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bPrice]), BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bAvailable]);
			ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS9, DIALOG_STYLE_LIST, "Chon doanh nghiep can sua.", szDialog, "Chon", "Thoat");
		}
		else
		{
			new szDialog[128];
			format(szDialog, sizeof(szDialog), "Business ID: %d\nMo ta: %s\nLoai: %d\nCredits: %s\nDang ban: %d", BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bBusinessID], BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bText],BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bType],
			number_format(BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bPrice]), BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bAvailable]);
			ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS9, DIALOG_STYLE_LIST, "Chon doanh nghiep can sua.", szDialog, "Chon", "Thoat");
		}
	}
	if(dialogid == DIALOG_EDITSHOPBUSINESS11)
	{
		if(response)
		{
			if(isnull(inputtext))
				return ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS11, DIALOG_STYLE_INPUT, "Sua doanh nghiep","Nhap mo ta doanh nghiep.", "Gui", "Quay lai");

			if(strlen(inputtext) > 128)
				return ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS11, DIALOG_STYLE_INPUT, "Sua doanh nghiep","Nhap mo ta doanh nghiep.", "Gui", "Quay lai");

			new szDialog[128];
			strcpy(BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bText], inputtext, 128);
			format(szDialog, sizeof(szDialog), "Business ID: %d\nMo ta: %s\nLoai: %d\nCredits: %s\nDang ban: %d", BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bBusinessID], BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bText],BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bType],
			number_format(BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bPrice]), BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bAvailable]);
			ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS9, DIALOG_STYLE_LIST, "Chon doanh nghiep can sua.", szDialog, "Chon", "Thoat");
		}
		else
		{
			new szDialog[128];
			format(szDialog, sizeof(szDialog), "Business ID: %d\nMo ta: %s\nLoai: %d\nCredits: %s\nDang ban: %d", BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bBusinessID], BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bText],BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bType],
			number_format(BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bPrice]), BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bAvailable]);
			ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS9, DIALOG_STYLE_LIST, "Chon doanh nghiep can sua.", szDialog, "Chon", "Thoat");
		}
	}
	if(dialogid == DIALOG_EDITSHOPBUSINESS10)
	{
		if(response)
		{
			new BusinessID;
			if (sscanf(inputtext, "d", BusinessID))
				return ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS10, DIALOG_STYLE_INPUT, "Sua doanh nghiep","Nhap ID doanh nghiep muon ban.", "Gui", "Quay lai");

			if(!IsValidBusinessID(BusinessID))
				return ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS10, DIALOG_STYLE_INPUT, "Sua doanh nghiep","Nhap ID doanh nghiep muon ban.", "Gui", "Quay lai");

			new szDialog[128];
			BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bBusinessID] = BusinessID;
			format(szDialog, sizeof(szDialog), "Business ID: %d\nMo ta: %s\nLoai: %d\nCredits: %s\nDang ban: %d", BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bBusinessID], BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bText],BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bType],
			number_format(BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bPrice]), BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bAvailable]);
			ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS9, DIALOG_STYLE_LIST, "Chon doanh nghiep can sua.", szDialog, "Chon", "Thoat");
		}
		else
		{
			new szDialog[128];
			format(szDialog, sizeof(szDialog), "Business ID: %d\nMo ta: %s\nLoai: %d\nCredits: %s\nDang ban: %d", BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bBusinessID], BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bText],BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bType],
			number_format(BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bPrice]), BusinessSales[Selected[playerid][GetPVarInt(playerid, "BusinessList")]][bAvailable]);
			ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS9, DIALOG_STYLE_LIST, "Chon doanh nghiep can sua.", szDialog, "Chon", "Thoat");
		}
	}
	if(dialogid == DIALOG_EDITSHOPBUSINESS7)
	{
		if(response)
		{
			if(BusinessSales[Selected[playerid][listitem]][bAvailable] == 2) {
				strcpy(BusinessSales[Selected[playerid][listitem]][bText], "None", 128);
				BusinessSales[Selected[playerid][listitem]][bBusinessID] = -1;
				BusinessSales[Selected[playerid][listitem]][bType] = 0;
				BusinessSales[Selected[playerid][listitem]][bAvailable] = 0;
				BusinessSales[Selected[playerid][listitem]][bPrice] = 0;
				SendClientMessageEx(playerid, COLOR_CYAN, "Ban da dat lai viec ban doanh nghiep.");
			}
		}
	}
	if(dialogid == DIALOG_EDITSHOPBUSINESS2)
	{
		if(response)
		{
			new BusinessID;
			if (sscanf(inputtext, "d", BusinessID))
				return ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS2, DIALOG_STYLE_INPUT, "Them doanh nghiep [1/4]","Nhap ID doanh nghiep muon ban.", "Tiep", "Huy");

			if(!IsValidBusinessID(BusinessID))
				return ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS2, DIALOG_STYLE_INPUT, "Them doanh nghiep [1/4]","Nhap ID doanh nghiep muon ban.", "Tiep", "Huy");

			for (new i; i < sizeof(BusinessSales); i++)
			{
				if(BusinessSales[i][bBusinessID] == BusinessID)
				{
					SendClientMessageEx(playerid, COLOR_GREY, "ID doanh nghiep do da duoc su dung.");
					return ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS2, DIALOG_STYLE_INPUT, "Them doanh nghiep [1/4]","Nhap ID doanh nghiep muon ban.", "Tiep", "Huy");
				}
			}
			BusinessSales[GetPVarInt(playerid, "EditingSale")][bBusinessID] = BusinessID;
			ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS3, DIALOG_STYLE_INPUT, "Them doanh nghiep [2/4]", "Nhap mo ta cho doanh nghiep.", "Tiep", "Huy");
		}
		else
		{
			ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS, DIALOG_STYLE_LIST, "Sua cua hang doanh nghiep", "Them doanh nghiep\nSua doanh nghiep\nXem doanh nghiep da ban", "Chon", "Thoat");
		}
	}
	if(dialogid == DIALOG_EDITSHOPBUSINESS3)
	{
		if(response)
		{
			if(isnull(inputtext))
				return ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS3, DIALOG_STYLE_INPUT, "Them doanh nghiep [2/4]", "Nhap mo ta cho doanh nghiep.", "Tiep", "Huy");

			if(strlen(inputtext) > 128)
				return ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS3, DIALOG_STYLE_INPUT, "Them doanh nghiep [2/4]", "Nhap mo ta cho doanh nghiep.", "Tiep", "Huy");

			strcpy(BusinessSales[GetPVarInt(playerid, "EditingSale")][bText], inputtext, 128);
			ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS4, DIALOG_STYLE_INPUT, "Them doanh nghiep [3/4]", "Nhap loai doanh nghiep (1-3).", "Tiep", "Huy");
		}
		else
		{
			ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS, DIALOG_STYLE_LIST, "Sua cua hang doanh nghiep", "Them doanh nghiep\nSua doanh nghiep\nXem doanh nghiep da ban", "Chon", "Thoat");
		}
	}
	if(dialogid == DIALOG_EDITSHOPBUSINESS4)
	{
		if(response)
		{
			new BusinessID;
			if (sscanf(inputtext, "d", BusinessID))
				return ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS4, DIALOG_STYLE_INPUT, "Them doanh nghiep [3/4]", "Nhap loai doanh nghiep (1-3).", "Tiep", "Huy");

			if(BusinessID < 1 || BusinessID > 3)
				return ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS4, DIALOG_STYLE_INPUT, "Them doanh nghiep [3/4]", "Nhap loai doanh nghiep (1-3).", "Tiep", "Huy");

			BusinessSales[GetPVarInt(playerid, "EditingSale")][bType] = BusinessID;
			ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS5, DIALOG_STYLE_INPUT, "Them doanh nghiep [4/4]", "Nhap so credits can de mua doanh nghiep nay.", "Tiep", "Huy");
		}
		else
		{
			ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS, DIALOG_STYLE_LIST, "Sua cua hang doanh nghiep", "Them doanh nghiep\nSua doanh nghiep\nXem doanh nghiep da ban", "Chon", "Thoat");
		}
	}
	if(dialogid == DIALOG_EDITSHOPBUSINESS5)
	{
		if(response)
		{
			new BusinessID;
			if (sscanf(inputtext, "d", BusinessID))
				return ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS5, DIALOG_STYLE_INPUT, "Them doanh nghiep [4/4]", "Nhap so credits can de mua doanh nghiep nay.", "Tiep", "Huy");

			if(BusinessID < 0)
				return ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS5, DIALOG_STYLE_INPUT, "Them doanh nghiep [4/4]", "Nhap so credits can de mua doanh nghiep nay.", "Tiep", "Huy");

			BusinessSales[GetPVarInt(playerid, "EditingSale")][bPrice] = BusinessID;
			format(string, sizeof(string), "Business ID: %d\nMo ta: %s\nLoai: %d\nGia: %d", BusinessSales[GetPVarInt(playerid, "EditingSale")][bBusinessID], BusinessSales[GetPVarInt(playerid, "EditingSale")][bText], BusinessSales[GetPVarInt(playerid, "EditingSale")][bType], BusinessSales[GetPVarInt(playerid, "EditingSale")][bPrice]);
			ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS6, DIALOG_STYLE_MSGBOX, "Hoan tat ban doanh nghiep", string, "Gui doanh nghiep", "Huy");
		}
		else
		{
			ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS, DIALOG_STYLE_LIST, "Sua cua hang doanh nghiep", "Them doanh nghiep\nSua doanh nghiep\nXem doanh nghiep da ban", "Chon", "Thoat");
		}
	}
	if(dialogid == DIALOG_EDITSHOPBUSINESS6)
	{
		if(response)
		{
			format(string, sizeof(string), "[EDITBUSINESSSHOP] [User: %s(%i)] [IP: %s] [BusinessID: %d] [Description: %s] [Type: %d] [Price: %d]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), BusinessSales[GetPVarInt(playerid, "EditingSale")][bBusinessID], BusinessSales[GetPVarInt(playerid, "EditingSale")][bText], BusinessSales[GetPVarInt(playerid, "EditingSale")][bType], BusinessSales[GetPVarInt(playerid, "EditingSale")][bPrice]);
			Log("logs/editshop.log", string), print(string);

			ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS, DIALOG_STYLE_LIST, "Sua cua hang doanh nghiep", "Them doanh nghiep\nSua doanh nghiep\nXem doanh nghiep da ban", "Chon", "Thoat");
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da gui doanh nghiep de ban.");
			BusinessSales[GetPVarInt(playerid, "EditingSale")][bAvailable] = 1;
			SaveBusinessSale(GetPVarInt(playerid, "EditingSale"));
			DeletePVar(playerid, "EditingSale");
		}
		else
		{
			ShowPlayerDialogEx(playerid, DIALOG_EDITSHOPBUSINESS, DIALOG_STYLE_LIST, "Sua cua hang doanh nghiep", "Them doanh nghiep\nSua doanh nghiep\nXem doanh nghiep da ban", "Chon", "Thoat");
		}
	}
	if(dialogid == DIALOG_SHOPBUSINESS)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new szDialog[500], Count;
					for (new i; i < sizeof(BusinessSales); i++)
					{
						if(BusinessSales[i][bAvailable] == 1)
						{
							format(szDialog, sizeof(szDialog), "%s\n%s (Credits: %s)", szDialog, BusinessSales[i][bText], number_format(BusinessSales[i][bPrice]));
							Selected[playerid][Count] = i;
							Count++;
						}
					}
					if(Count != 0)
						ShowPlayerDialogEx(playerid, DIALOG_SHOPBUSINESS2, DIALOG_STYLE_LIST, "Businesses Shop", szDialog, "Xem them", "Thoat");
					else
						SendClientMessageEx(playerid, COLOR_GREY, "Hien khong co doanh nghiep nao dang ban.");
				}
				case 1:
				{
					if(PlayerInfo[playerid][pBusiness] == INVALID_BUSINESS_ID || PlayerInfo[playerid][pBusinessRank] < 5)
						return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua so huu doanh nghiep.");

					if(Businesses[PlayerInfo[playerid][pBusiness]][bGrade] == 0)
						return SendClientMessageEx(playerid, COLOR_GREY, "Da xay ra loi, vui long lien he Director of Customer Relations.");

					ShowPlayerDialogEx(playerid, DIALOG_SHOPBUSINESS4, DIALOG_STYLE_LIST, "Chon so thang muon gia han.", "1 Thang\n2 Thang\n3 Thang\n4 Thang\n5 Thang\n6 Thang\n7 Thang\n8 Thang\n9 Thang\n10 Thang\n11 Thang\n1 Nam", "Chon", "Huy");
				}
			}
		}
	}
	if(dialogid == DIALOG_SHOPBUSINESS4)
	{
		if(response)
		{
			new Prices;
			SetPVarInt(playerid, "BusinessMonths", listitem+1);
			switch (Businesses[PlayerInfo[playerid][pBusiness]][bGrade])
			{
				case 1: Prices = ShopItems[11][sItemPrice];
				case 2: Prices = ShopItems[12][sItemPrice];
				case 3: Prices = ShopItems[13][sItemPrice];
			}
			SetPVarInt(playerid, "BusinessPrice", (listitem+1)*Prices);
			format(string, sizeof(string),"Gia han Business\nHang: %d\nHet han: %d Thang\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", Businesses[PlayerInfo[playerid][pBusiness]][bGrade],listitem+1, number_format(PlayerInfo[playerid][pCredits]), number_format(GetPVarInt(playerid, "BusinessPrice")), number_format(PlayerInfo[playerid][pCredits]-GetPVarInt(playerid, "BusinessPrice")));
			ShowPlayerDialogEx(playerid, DIALOG_SHOPBUSINESS5, DIALOG_STYLE_MSGBOX, "Mua gia han doanh nghiep", string, "Mua", "Huy");
		}
	}
	if(dialogid == DIALOG_SHOPBUSINESS5)
	{
		if(response)
		{
			if(PlayerInfo[playerid][pBusiness] == INVALID_BUSINESS_ID || PlayerInfo[playerid][pBusinessRank] < 5)
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua so huu doanh nghiep.");

			new Prices;
			Prices = GetPVarInt(playerid, "BusinessPrice");

			if(PlayerInfo[playerid][pCredits] < Prices)
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			if(!GetPVarType(playerid, "BusinessMonths"))
				return SendClientMessageEx(playerid, COLOR_GREY, "Da xay ra loi, vui long thu lai.");

			new szQuery[128];
			switch (Businesses[PlayerInfo[playerid][pBusiness]][bGrade])
			{
				case 1:
				{
					AmountSold[11]++;
					AmountMade[11] += Prices;
					//ShopItems[11][sSold]++;
					//ShopItems[11][sMade] += Prices;
					mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold11` = '%d', `AmountMade11` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[11], AmountMade[11]);
				}
				case 2:
				{
					AmountSold[12]++;
					AmountMade[12] += Prices;
					//ShopItems[12][sSold]++;
					//ShopItems[12][sMade] += Prices;
					mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold12` = '%d', `AmountMade12` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[12], AmountMade[12]);
				}
				case 3:
				{
					AmountSold[13]++;
					AmountMade[13] += Prices;
					//ShopItems[13][sSold]++;
					//ShopItems[13][sMade] += Prices;
					mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold13` = '%d', `AmountMade13` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[13], AmountMade[13]);
				}
			}

			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			new Months = GetPVarInt(playerid, "BusinessMonths");
			GivePlayerCredits(playerid, -Prices, 1);
			new stamp = Businesses[PlayerInfo[playerid][pBusiness]][bMonths];
			if(stamp-gettime() < 0)
			{
				Businesses[PlayerInfo[playerid][pBusiness]][bMonths] = (2592000*Months)+gettime()+259200;
			}
			else Businesses[PlayerInfo[playerid][pBusiness]][bMonths] = ((2592000*Months)+gettime()+259200)+stamp-gettime();

			format(string, sizeof(string), "[Business Renewal(%i)] [Months: %d] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s] -- %d | %d",PlayerInfo[playerid][pBusiness], Months, GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(Prices), stamp, Businesses[PlayerInfo[playerid][pBusiness]][bMonths]);
			Log("logs/credits.log", string), print(string);

			format(string, sizeof(string), "Da tra %s credits de gia han doanh nghiep %d thang.", number_format(Prices), Months);
			SendClientMessageEx(playerid, COLOR_CYAN, string);
		}
		DeletePVar(playerid, "BusinessMonths");
	}
	if(dialogid == DIALOG_SHOPBUSINESS2)
	{
		if(response)
		{
			format(string, sizeof(string),"Doanh nghiep: %s\nLoai: %d\nHet han: 1 Thang\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", BusinessSales[Selected[playerid][listitem]][bText], BusinessSales[Selected[playerid][listitem]][bType], number_format(PlayerInfo[playerid][pCredits]), number_format(BusinessSales[Selected[playerid][listitem]][bPrice]), number_format(PlayerInfo[playerid][pCredits]-BusinessSales[Selected[playerid][listitem]][bPrice]));
			ShowPlayerDialogEx(playerid, DIALOG_SHOPBUSINESS3, DIALOG_STYLE_MSGBOX, "Mua doanh nghiep", string, "Mua", "Huy");
			SetPVarInt(playerid, "BusinessSaleID", BusinessSales[Selected[playerid][listitem]][bBusinessID]), SetPVarInt(playerid, "BusinessSale", Selected[playerid][listitem]);
		}
	}
	if(dialogid == DIALOG_SHOPBUSINESS3)
	{
		if(response)
		{
			if(PlayerInfo[playerid][pCredits] < BusinessSales[GetPVarInt(playerid, "BusinessSale")][bPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			if (PlayerInfo[playerid][pBusiness] != INVALID_BUSINESS_ID)
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban da so huu doanh nghiep.");

			if(BusinessSales[GetPVarInt(playerid, "BusinessSale")][bAvailable] != 1)
				return SendClientMessageEx(playerid, COLOR_GREY, "Doanh nghiep nay khong con duoc ban.");

			if (!IsValidBusinessID(GetPVarInt(playerid, "BusinessSaleID")))
				return SendClientMessageEx(playerid, COLOR_GRAD2, "Da xay ra loi.");

			BusinessSales[GetPVarInt(playerid, "BusinessSale")][bAvailable] = 2;
			GivePlayerCredits(playerid, -BusinessSales[GetPVarInt(playerid, "BusinessSale")][bPrice], 1);
			BusinessSales[GetPVarInt(playerid, "BusinessSale")][bPurchased] = GetPlayerSQLId(playerid);

			Businesses[GetPVarInt(playerid, "BusinessSaleID")][bOwner] = GetPlayerSQLId(playerid);
			strcpy(Businesses[GetPVarInt(playerid, "BusinessSaleID")][bOwnerName], GetPlayerNameEx(playerid), MAX_PLAYER_NAME);
			PlayerInfo[playerid][pBusiness] = GetPVarInt(playerid, "BusinessSaleID");
			PlayerInfo[playerid][pBusinessRank] = 5;
			Businesses[GetPVarInt(playerid, "BusinessSaleID")][bMonths] = (2592000*1)+gettime()+259200;

			SendClientMessageEx(playerid, COLOR_CYAN, "Da mua doanh nghiep %s (1 Thang) gia %s credits.", BusinessSales[GetPVarInt(playerid, "BusinessSale")][bText], number_format(BusinessSales[GetPVarInt(playerid, "BusinessSale")][bPrice]));
			SendClientMessageEx(playerid, COLOR_WHITE, "Dung /help de xem muc huong dan doanh nghiep!");
			SaveBusiness(GetPVarInt(playerid, "BusinessSaleID"));
			OnPlayerStatsUpdate(playerid);
			RefreshBusinessPickup(GetPVarInt(playerid, "BusinessSaleID"));

			format(string,sizeof(string),"%s(%d) (IP: %s) has bought business ID %d for %d.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), GetPVarInt(playerid, "BusinessSale"), BusinessSales[GetPVarInt(playerid, "BusinessSale")][bPrice]);
			Log("logs/business.log", string);

			SaveBusinessSale(GetPVarInt(playerid, "BusinessSale"));

			format(string, sizeof(string), "[Business %i] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]",GetPVarInt(playerid, "BusinessSale"), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(BusinessSales[GetPVarInt(playerid, "BusinessSale")][bPrice]));
			Log("logs/credits.log", string), print(string);

			for(new i = 0; i < MAX_BUSINESSSALES; i++) {
			   Selected[playerid][i] = 0;
			}
		}
		DeletePVar(playerid, "BusinessSaleID");
		DeletePVar(playerid, "BusinessSale");
	}
	if(dialogid == DIALOG_HOUSESHOP)
	{
		if(response)
		{
			new szDialog[180];
			switch(listitem)
			{
				case 0: // Purchase House
				{
					format(szDialog, sizeof(szDialog),"*Hay lien he senior admin de duoc cap.\n\n\nVat pham: House\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[14][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[14][sItemPrice]));
					ShowPlayerDialogEx( playerid, DIALOG_HOUSESHOP2, DIALOG_STYLE_MSGBOX, "House Shop", szDialog, "Mua", "Huy" );
				}
				case 1: // House Interior Change
				{
					format(szDialog, sizeof(szDialog),"*Hay lien he senior admin de duoc cap.\n\n\nVat pham: House Interior Change\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[15][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[15][sItemPrice]));
					ShowPlayerDialogEx( playerid, DIALOG_HOUSESHOP3, DIALOG_STYLE_MSGBOX, "House Shop", szDialog, "Mua", "Huy" );
				}
				case 2: // House Move
				{
					format(szDialog, sizeof(szDialog),"*Hay lien he senior admin de duoc cap.\n\n\nVat pham: House Move\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[16][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[16][sItemPrice]));
					ShowPlayerDialogEx( playerid, DIALOG_HOUSESHOP4, DIALOG_STYLE_MSGBOX, "House Shop", szDialog, "Mua", "Huy" );
				}
				case 3: // Small Garage
				{
					format(szDialog, sizeof(szDialog),"*Hay lien he senior admin de duoc cap.\n\n\nVat pham: Garage - Small\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[24][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[24][sItemPrice]));
					ShowPlayerDialogEx( playerid, DIALOG_HOUSESHOP5, DIALOG_STYLE_MSGBOX, "House Shop", szDialog, "Mua", "Huy" );
				}
				case 4: // Medium Garage
				{
					format(szDialog, sizeof(szDialog),"*Hay lien he senior admin de duoc cap.\n\n\nVat pham: Garage - Medium\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[25][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[25][sItemPrice]));
					ShowPlayerDialogEx( playerid, DIALOG_HOUSESHOP6, DIALOG_STYLE_MSGBOX, "House Shop", szDialog, "Mua", "Huy" );
				}
				case 5: // Large Garage
				{
					format(szDialog, sizeof(szDialog),"*Hay lien he senior admin de duoc cap.\n\n\nVat pham: Garage - Large\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[26][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[26][sItemPrice]));
					ShowPlayerDialogEx( playerid, DIALOG_HOUSESHOP7, DIALOG_STYLE_MSGBOX, "House Shop", szDialog, "Mua", "Huy" );
				}
				case 6: // Large Garage
				{
					format(szDialog, sizeof(szDialog),"*Hay lien he senior admin de duoc cap.\n\n\nVat pham: Garage - Extra Large\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[27][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[27][sItemPrice]));
					ShowPlayerDialogEx( playerid, DIALOG_HOUSESHOP8, DIALOG_STYLE_MSGBOX, "House Shop", szDialog, "Mua", "Huy" );
				}
			}
		}
	}
	if(dialogid == DIALOG_HOUSESHOP2)
	{
		if(response)
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[14][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			GivePlayerCredits(playerid, -ShopItems[14][sItemPrice], 1);
			printf("Price14: %d", ShopItems[14][sItemPrice]);
			AmountSold[14]++;
			AmountMade[14] += ShopItems[14][sItemPrice];
			//ShopItems[14][sSold]++;
			//ShopItems[14][sMade] += ShopItems[14][sItemPrice];
			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold14` = '%d', `AmountMade14` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[14], AmountMade[14]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			AddFlag(playerid, INVALID_PLAYER_ID, "Purchased House (Credits)");
			SendReportToQue(playerid, "House (Credits)", 2, 2);
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua House gia %s credits.", number_format(ShopItems[14][sItemPrice]));
			SendClientMessageEx(playerid, COLOR_CYAN, "Hay lien he senior admin de duoc cap nha.");

			format(string, sizeof(string), "[House] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[14][sItemPrice]));
			Log("logs/credits.log", string), print(string);
		}
	}
	if(dialogid == DIALOG_HOUSESHOP3)
	{
		if(response)
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[15][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			GivePlayerCredits(playerid, -ShopItems[15][sItemPrice], 1);
			printf("Price15: %d", ShopItems[15][sItemPrice]);
			AmountSold[15]++;
			AmountMade[15] += ShopItems[15][sItemPrice];
			//ShopItems[15][sSold]++;
			//ShopItems[15][sMade] += ShopItems[15][sItemPrice];
			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold15` = '%d', `AmountMade15` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[15], AmountMade[15]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			AddFlag(playerid, INVALID_PLAYER_ID, "Purchased House Interior Change (Credits)");
			SendReportToQue(playerid, "House Interior Change (Credits)", 2, 2);
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua House Interior Change gia %s credits.", number_format(ShopItems[15][sItemPrice]));
			SendClientMessageEx(playerid, COLOR_CYAN, "Hay lien he senior admin de duoc doi noi that nha.");

			format(string, sizeof(string), "[House Interior Change] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[15][sItemPrice]));
			Log("logs/credits.log", string), print(string);
		}
	}
	if(dialogid == DIALOG_HOUSESHOP4)
	{
		if(response)
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[16][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			GivePlayerCredits(playerid, -ShopItems[16][sItemPrice], 1);
			printf("Price16: %d", ShopItems[16][sItemPrice]);
			AmountSold[16]++;
			AmountMade[16] += ShopItems[16][sItemPrice];
			//ShopItems[16][sSold]++;
			//ShopItems[16][sMade] += ShopItems[16][sItemPrice];
			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold16` = '%d', `AmountMade16` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[16], AmountMade[16]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			AddFlag(playerid, INVALID_PLAYER_ID, "Purchased House Move (Credits)");
			SendReportToQue(playerid, "House Move (Credits)", 2, 2);
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua House Move gia %s credits.", number_format(ShopItems[16][sItemPrice]));
			SendClientMessageEx(playerid, COLOR_CYAN, "Hay lien he senior admin de duoc di chuyen nha.");

			format(string, sizeof(string), "[House Move] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[16][sItemPrice]));
			Log("logs/credits.log", string), print(string);
		}
	}
	if(dialogid == DIALOG_HOUSESHOP5)
	{
		if(response)
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[24][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			GivePlayerCredits(playerid, -ShopItems[24][sItemPrice], 1);
			printf("Price24: %d", ShopItems[24][sItemPrice]);
			AmountSold[24]++;
			AmountMade[24] += ShopItems[24][sItemPrice];

			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold24` = '%d', `AmountMade24` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[24], AmountMade[24]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			GarageVW++;
			g_mysql_SaveMOTD();
			format(szQuery, sizeof(szQuery), "Garage - Small (VW: %d)", GarageVW);
			AddFlag(playerid, INVALID_PLAYER_ID, szQuery);

			SendReportToQue(playerid, szQuery, 2, 2);
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua Garage - Small gia %s credits.", number_format(ShopItems[24][sItemPrice]));
			SendClientMessageEx(playerid, COLOR_CYAN, "Hay lien he senior admin de duoc cap small garage.");

			format(string, sizeof(string), "[Garage - Small] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[24][sItemPrice]));
			Log("logs/credits.log", string), print(string);
		}
	}
	if(dialogid == DIALOG_HOUSESHOP6)
	{
		if(response)
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[25][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			GivePlayerCredits(playerid, -ShopItems[25][sItemPrice], 1);
			printf("Price25: %d", ShopItems[25][sItemPrice]);
			AmountSold[25]++;
			AmountMade[25] += ShopItems[25][sItemPrice];

			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold25` = '%d', `AmountMade25` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[25], AmountMade[25]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			GarageVW++;
			g_mysql_SaveMOTD();
			format(szQuery, sizeof(szQuery), "Garage - Medium (VW: %d)", GarageVW);
			AddFlag(playerid, INVALID_PLAYER_ID, szQuery);

			SendReportToQue(playerid, szQuery, 2, 2);
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua Garage - Medium gia %s credits.", number_format(ShopItems[25][sItemPrice]));
			SendClientMessageEx(playerid, COLOR_CYAN, "Hay lien he senior admin de duoc cap medium garage.");

			format(string, sizeof(string), "[Garage - Medium] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[25][sItemPrice]));
			Log("logs/credits.log", string), print(string);
		}
	}
	if(dialogid == DIALOG_HOUSESHOP7)
	{
		if(response)
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[26][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			GivePlayerCredits(playerid, -ShopItems[26][sItemPrice], 1);
			printf("Price26: %d", ShopItems[26][sItemPrice]);
			AmountSold[26]++;
			AmountMade[26] += ShopItems[26][sItemPrice];

			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold26` = '%d', `AmountMade26` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[26], AmountMade[26]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			GarageVW++;
			g_mysql_SaveMOTD();
			format(szQuery, sizeof(szQuery), "Garage - Large (VW: %d)", GarageVW);
			AddFlag(playerid, INVALID_PLAYER_ID, szQuery);

			SendReportToQue(playerid, szQuery, 2, 2);
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua Garage - Large gia %s credits.", number_format(ShopItems[26][sItemPrice]));
			SendClientMessageEx(playerid, COLOR_CYAN, "Hay lien he senior admin de duoc cap large garage.");

			format(string, sizeof(string), "[Garage - Large] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[26][sItemPrice]));
			Log("logs/credits.log", string), print(string);
		}
	}
	if(dialogid == DIALOG_HOUSESHOP8)
	{
		if(response)
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[27][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			GivePlayerCredits(playerid, -ShopItems[27][sItemPrice], 1);
			printf("Price27: %d", ShopItems[27][sItemPrice]);
			AmountSold[27]++;
			AmountMade[27] += ShopItems[27][sItemPrice];

			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold27` = '%d', `AmountMade27` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[27], AmountMade[27]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			GarageVW++;
			g_mysql_SaveMOTD();
			format(szQuery, sizeof(szQuery), "Garage - Extra Large (VW: %d)", GarageVW);
			AddFlag(playerid, INVALID_PLAYER_ID, szQuery);

			SendReportToQue(playerid, szQuery, 2, 2);
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua Garage - Extra Large gia %s credits.", number_format(ShopItems[27][sItemPrice]));
			SendClientMessageEx(playerid, COLOR_CYAN, "Hay lien he senior admin de duoc cap extra large garage.");

			format(string, sizeof(string), "[Garage - Extra Large] [User: %s(%i)] [IP: %s] [Credits: %s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[27][sItemPrice]));
			Log("logs/credits.log", string), print(string);
		}
	}
	if(dialogid == DIALOG_HEALTHCARE)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new szDialog[160];
					format(szDialog, sizeof(szDialog), "Khi roi benh vien, ban se day mau va duoc phuc vu mot bua an day du.\n\nPhi moi lan vao vien: {FFD700}%s{A9C4E4}", number_format(ShopItems[18][sItemPrice]));
					ShowPlayerDialogEx(playerid, DIALOG_HEALTHCARE2, DIALOG_STYLE_MSGBOX, "Advanced Health Care" , szDialog, "Bat", "Thoat");
				}
				case 1:
				{
					new szDialog[160];
					SetPVarInt(playerid, "HealthCare", 1);
					format(szDialog, sizeof(szDialog), "Khi roi benh vien, ban hoi sinh nhanh hon 80%%, day mau va duoc phuc vu mot bua an day du.\n\nPhi moi lan vao vien: {FFD700}%s{A9C4E4}", number_format(ShopItems[19][sItemPrice]));
					ShowPlayerDialogEx(playerid, DIALOG_HEALTHCARE2, DIALOG_STYLE_MSGBOX, "Super Advanced Health Care" , szDialog, "Bat", "Thoat");
				}
			}
		}
	}
	if(dialogid == DIALOG_HEALTHCARE2)
	{
		if(response)
		{
			if(!GetPVarType(playerid, "HealthCare")) // Advanced
			{
				PlayerInfo[playerid][pHealthCare] = 1;
				SendClientMessageEx(playerid, COLOR_CYAN, "Da bat Advanced Health Care, dung /togglehealthcare de tat.");
			}
			else // Super Advanced
			{
				PlayerInfo[playerid][pHealthCare] = 2;
				SendClientMessageEx(playerid, COLOR_CYAN, "Da bat Super Advanced Health Care, dung /togglehealthcare de tat.");
			}
		}
		DeletePVar(playerid, "HealthCare");
	}
	if(dialogid == DIALOG_VIPSHOP && response)
	{
		if(listitem == 0)
		{
			ShowPlayerDialogEx(playerid, DIALOG_VIPSHOP2, DIALOG_STYLE_LIST, "Chon goi VIP muon mua.", "Bronze\nSilver\nGold", "Chon", "Huy");
		}
		else
		{
			if(PlayerInfo[playerid][pGVip] == 0) {
				SendClientMessageEx(playerid, COLOR_GREY, "Ban chua tung mua Gold VIP nen khong the gia han.");
			}
			else
			{
				ShowPlayerDialogEx(playerid, DIALOG_VIPSHOP3, DIALOG_STYLE_LIST, "Chon so thang muon gia han.", "1 Thang\n2 Thang\n3 Thang\n4 Thang\n5 Thang\n6 Thang\n7 Thang\n8 Thang\n9 Thang\n10 Thang\n11 Thang\n1 Nam", "Chon", "Huy");
			}
		}
	}
	if(dialogid == DIALOG_VIPSHOP3 && response)
	{
		new Months = listitem+1;
		SetPVarInt(playerid, "VIPType", 3), SetPVarInt(playerid, "VIPPrice", ShopItems[1][sItemPrice]*Months), SetPVarInt(playerid, "VIPMonths", Months), SetPVarInt(playerid, "GoldRenewal", 1);
		format(string, sizeof(string),"Loai: Gold VIP\nHet han: %d Thang\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", listitem+1, number_format(PlayerInfo[playerid][pCredits]), number_format(GetPVarInt(playerid, "VIPPrice")), number_format(PlayerInfo[playerid][pCredits]-GetPVarInt(playerid, "VIPPrice")));
		ShowPlayerDialogEx( playerid, DIALOG_PURCHASEVIP, DIALOG_STYLE_MSGBOX, "Gold VIP Renew", string, "Mua", "Huy" );
	}
	if(dialogid == DIALOG_VIPSHOP2 && response)
	{
		switch(listitem)
		{
			case 0:
			{
				new Message[520];
				Message = "Ten VIP mau tim tren dien dan.\n\
				VIP Forums - Quyen truy cap\nVIP Chat\nVIP Garage voi cac xe tuyen chon tren ban do.\nVIP Lounge\nFirst Aid Station [HP Refills]\nGun Locker \nLay Cannabis va Crack qua cong viec ma khong can cho bo sung tai Drug House.";
				strcat(Message, "\nUu dai gia xe tai Dealership [20% off]\n24/7 VIP - Gia uu dai [20% Off]\nDung ATM mien phi \nTai khoan thanh toan mien phi \nLoi moi den tiec rieng cho VIP\nTang lai suat toi da moi gio: $100k moi paycheck");
				ShowPlayerDialogEx(playerid, DIALOG_VIPBRONZE, DIALOG_STYLE_MSGBOX, "Quyen loi Bronze VIP" , Message, "Tiep tuc", "Huy" );
			}
			case 1:
			{
				new Message[850];
				Message = "Ten VIP mau tim tren dien dan. \n\
				VIP Forums - Quyen truy cap \n\
				VIP Chat \n\
				VIP Garage voi cac xe tuyen chon tren ban do. \n\
				VIP Lounge\n\
				First Aid Station [HP Refills] \n\
				Gun Locker \n\
				Lay Cannabis va Crack qua cong viec ma khong can cho bo sung tai Drug House. \n\
				Uu dai gia xe tai Dealership [20% off] \n\
				24/7 VIP - Gia uu dai [20% Off]";

				strcat(Message, "\nDung ATM mien phi \n\
				Tai khoan thanh toan mien phi \n\
				Loi moi den tiec rieng cho VIP \n\
				Hien thi so nguoi goi \n\
				Co the lam 2 cong viec. \n\
				So huu them 3 xe. \n\
				Su dung tat ca skin \n\
				Tang lai suat \n\
				Co the mua so dien thoai am. \n\
				Co the mua luot hoi sinh tai phong Gold VIP+. \n\
				Tu dong tra loi tin nhan \n\
				Gia quang cao uu tien $125,000 \n\
				Loi moi VIP Buddy hang tuan* [moi ban be dung VIP Bronze Features trong 3 gio]");

				ShowPlayerDialogEx(playerid, DIALOG_VIPSILVER, DIALOG_STYLE_MSGBOX, "Quyen loi Silver VIP" , Message, "Tiep tuc", "Huy" );
			}
			case 2:
			{
				new Message[1000];
				Message = "Ten VIP mau tim tren dien dan. \n\
				VIP Forums - Quyen truy cap \n\
				Gold VIP Tag tren TS. \n\
				VIP Chat \n\
				VIP Garage voi cac xe tuyen chon tren ban do. \n\
				VIP Lounge\n\
				First Aid Station [HP Refills] \n\
				Gun Locker \n\
				Lay Cannabis va Crack qua cong viec ma khong can cho bo sung tai Drug House. \n\
				Uu dai gia xe tai Dealership [20% off] \n\
				Day mau va no bung sau khi chet \n\
				24/7 VIP - Gia uu dai [20% Off]";

				strcat(Message, "\nDung ATM mien phi \n\
				Tai khoan thanh toan mien phi \n\
				Loi moi den tiec rieng cho VIP \n\
				Hien thi so nguoi goi \n\
				Co the lam 3 cong viec. \n\
				So huu them 3 xe. \n\
				Su dung tat ca skin \n\
				Tang lai suat \n\
				Co the mua so dien thoai am. \n\
				Gia quang cao uu tien $100,000 \n\
				Giam 10 percent cho NameChanges \n\
				Tu dong tra loi tin nhan \n\
				Loi moi VIP Buddy hang ngay* [moi ban be dung VIP Bronze Features trong 3 gio]");

				strcat(Message, "\nx2 Paycheck vao sinh nhat \n\
				Mot Gift ngau nhien vao sinh nhat \n\
				Giam 5 Percent phi di chuyen House/Gate/Door \n\
				Tuy chon WAR tai Paintball");

				ShowPlayerDialogEx(playerid, DIALOG_VIPGOLD, DIALOG_STYLE_MSGBOX, "Quyen loi Gold VIP" , Message, "Tiep tuc", "Huy" );
			}
		}
	}
	if(dialogid == DIALOG_VIPBRONZE && response)
	{
		ShowPlayerDialogEx(playerid, DIALOG_VIPBRONZE2, DIALOG_STYLE_LIST, "Chon so thang muon gia han.", "1 Thang\n2 Thang\n3 Thang\n4 Thang\n5 Thang\n6 Thang\n7 Thang\n8 Thang\n9 Thang\n10 Thang\n11 Thang\n1 Nam", "Chon", "Huy");
	}
	if(dialogid == DIALOG_VIPBRONZE2 && response)
	{
		new Months = listitem+1;
		SetPVarInt(playerid, "VIPType", 1), SetPVarInt(playerid, "VIPPrice", ShopItems[3][sItemPrice]*Months), SetPVarInt(playerid, "VIPMonths", Months);
		format(string, sizeof(string),"Loai: Bronze VIP\nHet han: %d Thang\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", listitem+1, number_format(PlayerInfo[playerid][pCredits]), number_format(GetPVarInt(playerid, "VIPPrice")), number_format(PlayerInfo[playerid][pCredits]-GetPVarInt(playerid, "VIPPrice")));
		ShowPlayerDialogEx( playerid, DIALOG_PURCHASEVIP, DIALOG_STYLE_MSGBOX, "Bronze VIP", string, "Mua", "Huy" );
	}
	if(dialogid == DIALOG_VIPSILVER && response)
	{
		ShowPlayerDialogEx(playerid, DIALOG_VIPSILVER2, DIALOG_STYLE_LIST, "Chon so thang muon gia han.", "1 Thang\n2 Thang\n3 Thang\n4 Thang\n5 Thang\n6 Thang\n7 Thang\n8 Thang\n9 Thang\n10 Thang\n11 Thang\n1 Nam", "Chon", "Huy");
	}
	if(dialogid == DIALOG_VIPSILVER2 && response)
	{
		new Months = listitem+1;
		SetPVarInt(playerid, "VIPType", 2), SetPVarInt(playerid, "VIPPrice", ShopItems[2][sItemPrice]*Months), SetPVarInt(playerid, "VIPMonths", Months);
		format(string, sizeof(string),"Loai: Silver VIP\nHet han: %d Thang\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", listitem+1, number_format(PlayerInfo[playerid][pCredits]), number_format(GetPVarInt(playerid, "VIPPrice")), number_format(PlayerInfo[playerid][pCredits]-GetPVarInt(playerid, "VIPPrice")));
		ShowPlayerDialogEx( playerid, DIALOG_PURCHASEVIP, DIALOG_STYLE_MSGBOX, "Silver VIP", string, "Mua", "Huy" );
	}
	if(dialogid == DIALOG_VIPGOLD && response)
	{
		SetPVarInt(playerid, "VIPMonths", 1), SetPVarInt(playerid, "VIPType", 3), SetPVarInt(playerid, "VIPPrice", ShopItems[0][sItemPrice]);
		format(string, sizeof(string),"Loai: Gold VIP\nHet han: 1 Thang\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(GetPVarInt(playerid, "VIPPrice")), number_format(PlayerInfo[playerid][pCredits]-GetPVarInt(playerid, "VIPPrice")));
		ShowPlayerDialogEx( playerid, DIALOG_PURCHASEVIP, DIALOG_STYLE_MSGBOX, "Gold VIP", string, "Mua", "Huy" );
	}
	if(dialogid == DIALOG_PURCHASEVIP)
	{
		if(response)
		{
			if(PlayerInfo[playerid][pCredits] < GetPVarInt(playerid, "VIPPrice"))
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			if(PlayerInfo[playerid][pDonateRank] != 0)
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban da co VIP, hay cho het han.");

			if(GetPVarType(playerid, "VIPType") != 1)
				return SendClientMessageEx(playerid, COLOR_GREY, "Da xay ra loi, vui long thu lai.");


			PlayerInfo[playerid][pDonateRank] = GetPVarInt(playerid, "VIPType");
			PlayerInfo[playerid][pTempVIP] = 0;
			PlayerInfo[playerid][pBuddyInvited] = 0;
			PlayerInfo[playerid][pVIPSellable] = 0;

			if(PlayerInfo[playerid][pVIPM] == 0)
			{
				PlayerInfo[playerid][pVIPM] = VIPM;
				VIPM++;
			}

			if(GetPVarType(playerid, "VIPMonths"))
			{
				PlayerInfo[playerid][pVIPExpire] = (2592000*GetPVarInt(playerid, "VIPMonths"))+gettime();
			}
			else
			{
				PlayerInfo[playerid][pVIPExpire] = 2592000+gettime();
			}

			GivePlayerCredits(playerid, -GetPVarInt(playerid, "VIPPrice"), 1);

			if(GetPVarInt(playerid, "VIPType") == 3)
				PlayerInfo[playerid][pGVip] = 1;

			new VIPType[7];
			new szQuery[128];
			if(GetPVarType(playerid, "GoldRenewal"))
			{
				AmountSold[1]++;
				AmountMade[1] += GetPVarInt(playerid, "VIPPrice");
				VIPType = "Gold";
				//ShopItems[1][sMade] += GetPVarInt(playerid, "VIPPrice");
				mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold1` = '%d', `AmountMade1` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[1], AmountMade[1]);
				DeletePVar(playerid, "GoldRenewal");
			}
			else
			{
				switch(GetPVarInt(playerid, "VIPType")) {
					case 1:
					{
						VIPType = "Bronze";
						AmountSold[3]++;
						AmountMade[3] += GetPVarInt(playerid, "VIPPrice");
						//ShopItems[3][sSold]++;
						//ShopItems[3][sMade] += GetPVarInt(playerid, "VIPPrice");
						mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold3` = '%d', `AmountMade3` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[3], AmountMade[3]);
					}
					case 2:
					{
						VIPType = "Silver";
						AmountSold[2]++;
						AmountMade[2] += GetPVarInt(playerid, "VIPPrice");
						//ShopItems[2][sSold]++;
						//ShopItems[2][sMade] += GetPVarInt(playerid, "VIPPrice");
						mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold2` = '%d', `AmountMade2` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[2], AmountMade[2]);
					}
					case 3:
					{
						VIPType = "Gold";
						AmountSold[0]++;
						AmountMade[0] += GetPVarInt(playerid, "VIPPrice");
						//ShopItems[0][sSold]++;
						//ShopItems[0][sMade] += GetPVarInt(playerid, "VIPPrice");
						mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold0` = '%d', `AmountMade0` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[0], AmountMade[0]);
					}
				}
			}

			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua %s VIP (%d Thang) gia %s credits.", VIPType,GetPVarInt(playerid, "VIPMonths"), number_format(GetPVarInt(playerid, "VIPPrice")));

			format(string, sizeof(string), "[VIP %i] [User: %s(%i)] [IP: %s] [Credits: %s] [VIP: %s(%d)] [Price: %s]", PlayerInfo[playerid][pVIPM], GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), VIPType,GetPVarInt(playerid, "VIPMonths"), number_format(GetPVarInt(playerid, "VIPPrice")));
			Log("logs/credits.log", string), Log("logs/setvip.log", string), print(string);
		}
		DeletePVar(playerid, "VIPPrice");
		DeletePVar(playerid, "VIPMonths");
		DeletePVar(playerid, "VIPType");
	}
	if(dialogid == DIALOG_SHOPGIFTRESET)
	{
		if(response)
		{
			if(PlayerInfo[playerid][pCredits] < ShopItems[17][sItemPrice])
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			PlayerInfo[playerid][pGiftTime] = 0;

			GivePlayerCredits(playerid, -ShopItems[17][sItemPrice], 1);
			printf("Price18: %d", ShopItems[17][sItemPrice]);
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua dat lai thoi gian qua voi %s Credit.", number_format(ShopItems[17][sItemPrice]));

			AmountSold[17]++;
			AmountMade[17] += ShopItems[17][sItemPrice];
			//ShopItems[17][sSold]++;
			//ShopItems[17][sMade] += ShopItems[17][sItemPrice];
			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold17` = '%d', `AmountMade17` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[17], AmountMade[17]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			format(string, sizeof(string), "[GIFTTIMERRESET] [User: %s(%i)] [IP: %s] [Credits: %s] [Gift Timer Reset] [Price: %s]",GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[17][sItemPrice]));
			Log("logs/credits.log", string), print(string);
		}
	}
	if(dialogid == DIALOG_SHOPTOTRESET)
	{
		if(response)
		{
			if(PlayerInfo[playerid][pCredits] < 20)
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			PlayerInfo[playerid][pTrickortreat] = 0;

			GivePlayerCredits(playerid, -20, 1);
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua Holiday timer reset voi gia %s credits.", number_format(20));


			format(string, sizeof(string), "[GIFTTIMERRESET] [User: %s(%i)] [IP: %s] [Credits: %s] [Special Holiday Timer Reset] [Price: %s]",GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(20));
			Log("logs/zombiecure.log", string), print(string);
		}
	}
	if(dialogid == DIALOG_HALLOWEENSHOP)
	{
		if(response)
		{
			if(listitem == 0)
			{
				format(string, sizeof(string),"Vat pham: Limited Edition Straw Hat\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(150), number_format(PlayerInfo[playerid][pCredits]-150));
				ShowPlayerDialogEx( playerid, DIALOG_HALLOWEENSHOP1, DIALOG_STYLE_MSGBOX, "Thanksgiving Shop", string, "Mua", "Thoat" );
			}
			else
			{
				format(string, sizeof(string),"Vat pham: Limited Edition Cluckin Bell Hat\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(150), number_format(PlayerInfo[playerid][pCredits]-150));
				ShowPlayerDialogEx( playerid, DIALOG_HALLOWEENSHOP2, DIALOG_STYLE_MSGBOX, "Thanksgiving Shop", string, "Mua", "Thoat" );
			}
		}
	}
	if(dialogid == DIALOG_HALLOWEENSHOP1)
	{
		if(response)
		{
			if(PumpkinStock <= 0)
				return SendClientMessageEx(playerid, COLOR_GREY, "Vat pham gioi han nay da ban het!");
			if(PlayerInfo[playerid][pCredits] < 150)
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			GivePlayerCredits(playerid, -150, 1);
			PumpkinStock--;
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua toy Straw Hat gia %s credits.", number_format(150));

			g_mysql_SaveAccount(playerid);
			g_mysql_SaveMOTD();

			format(string, sizeof(string), "[TOYSALE] [User: %s(%i)] [IP: %s] [Credits: %s] [Straw Hat] [Price: %s]",GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(150));
			Log("logs/zombiecure.log", string), print(string);

			new icount = GetPlayerToySlots(playerid);
			for(new v = 0; v < icount; v++)
			{
				if(PlayerToyInfo[playerid][v][ptModelID] == 0)
				{
					PlayerToyInfo[playerid][v][ptModelID] = 19553;
					PlayerToyInfo[playerid][v][ptBone] = 6;
					PlayerToyInfo[playerid][v][ptPosX] = 0.0;
					PlayerToyInfo[playerid][v][ptPosY] = 0.0;
					PlayerToyInfo[playerid][v][ptPosZ] = 0.0;
					PlayerToyInfo[playerid][v][ptRotX] = 0.0;
					PlayerToyInfo[playerid][v][ptRotY] = 0.0;
					PlayerToyInfo[playerid][v][ptRotZ] = 0.0;
					PlayerToyInfo[playerid][v][ptScaleX] = 1.0;
					PlayerToyInfo[playerid][v][ptScaleY] = 1.0;
					PlayerToyInfo[playerid][v][ptScaleZ] = 1.0;
					PlayerToyInfo[playerid][v][ptTradable] = 1;

					g_mysql_NewToy(playerid, v);
					return 1;
				}
			}

			for(new i = 0; i < MAX_PLAYERTOYS; i++)
			{
				if(PlayerToyInfo[playerid][i][ptModelID] == 0)
				{
					PlayerToyInfo[playerid][i][ptModelID] = 19553;
					PlayerToyInfo[playerid][i][ptBone] = 6;
					PlayerToyInfo[playerid][i][ptPosX] = 0.0;
					PlayerToyInfo[playerid][i][ptPosY] = 0.0;
					PlayerToyInfo[playerid][i][ptPosZ] = 0.0;
					PlayerToyInfo[playerid][i][ptRotX] = 0.0;
					PlayerToyInfo[playerid][i][ptRotY] = 0.0;
					PlayerToyInfo[playerid][i][ptRotZ] = 0.0;
					PlayerToyInfo[playerid][i][ptScaleX] = 1.0;
					PlayerToyInfo[playerid][i][ptScaleY] = 1.0;
					PlayerToyInfo[playerid][i][ptScaleZ] = 1.0;
					PlayerToyInfo[playerid][i][ptTradable] = 1;
					PlayerToyInfo[playerid][i][ptSpecial] = 1;

					g_mysql_NewToy(playerid, i);

					SendClientMessageEx(playerid, COLOR_GRAD1, "Vi het o trong, ban duoc cap them o tam de dung/ban/trao doi toy.");
					SendClientMessageEx(playerid, COLOR_RED, "Chu y: O toy tam se bi go sau khi ban toy.");
					break;
				}
			}

		}
	}
	if(dialogid == DIALOG_HALLOWEENSHOP2)
	{
		if(response)
		{
			if(PlayerInfo[playerid][pCredits] < 150)
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			GivePlayerCredits(playerid, -150, 1);
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua toy Cluckin Bell Hat gia %s credits.", number_format(150));

			g_mysql_SaveAccount(playerid);
			g_mysql_SaveMOTD();

			format(string, sizeof(string), "[TOYSALE] [User: %s(%i)] [IP: %s] [Credits: %s] [Cluckin Bell Hat] [Price: %s]",GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), number_format(60));
			Log("logs/zombiecure.log", string), print(string);

			new icount = GetPlayerToySlots(playerid);
			for(new v = 0; v < icount; v++)
			{
				if(PlayerToyInfo[playerid][v][ptModelID] == 0)
				{
					PlayerToyInfo[playerid][v][ptModelID] = 19137;
					PlayerToyInfo[playerid][v][ptBone] = 5;
					PlayerToyInfo[playerid][v][ptPosX] = 0.0;
					PlayerToyInfo[playerid][v][ptPosY] = 0.0;
					PlayerToyInfo[playerid][v][ptPosZ] = 0.0;
					PlayerToyInfo[playerid][v][ptRotX] = 0.0;
					PlayerToyInfo[playerid][v][ptRotY] = 0.0;
					PlayerToyInfo[playerid][v][ptRotZ] = 0.0;
					PlayerToyInfo[playerid][v][ptScaleX] = 1.0;
					PlayerToyInfo[playerid][v][ptScaleY] = 1.0;
					PlayerToyInfo[playerid][v][ptScaleZ] = 1.0;
					PlayerToyInfo[playerid][v][ptTradable] = 1;

					g_mysql_NewToy(playerid, v);
					return 1;
				}
			}

			for(new i = 0; i < MAX_PLAYERTOYS; i++)
			{
				if(PlayerToyInfo[playerid][i][ptModelID] == 0)
				{
					PlayerToyInfo[playerid][i][ptModelID] =  19137;
					PlayerToyInfo[playerid][i][ptBone] = 5;
					PlayerToyInfo[playerid][i][ptPosX] = 0.0;
					PlayerToyInfo[playerid][i][ptPosY] = 0.0;
					PlayerToyInfo[playerid][i][ptPosZ] = 0.0;
					PlayerToyInfo[playerid][i][ptRotX] = 0.0;
					PlayerToyInfo[playerid][i][ptRotY] = 0.0;
					PlayerToyInfo[playerid][i][ptRotZ] = 0.0;
					PlayerToyInfo[playerid][i][ptScaleX] = 1.0;
					PlayerToyInfo[playerid][i][ptScaleY] = 1.0;
					PlayerToyInfo[playerid][i][ptScaleZ] = 1.0;
					PlayerToyInfo[playerid][i][ptTradable] = 1;
					PlayerToyInfo[playerid][i][ptSpecial] = 1;

					g_mysql_NewToy(playerid, i);

					SendClientMessageEx(playerid, COLOR_GRAD1, "Vi het o trong, ban duoc cap them o tam de dung/ban/trao doi toy.");
					SendClientMessageEx(playerid, COLOR_RED, "Chu y: O toy tam se bi go sau khi ban toy.");
					break;
				}
			}

		}
	}
	if(dialogid == DIALOG_SHOPNEON && response)
	{
		switch(listitem)
		{
			case 0: SetPVarInt(playerid, "ToyID", 18647);
			case 1: SetPVarInt(playerid, "ToyID", 18648);
			case 2: SetPVarInt(playerid, "ToyID", 18649);
			case 3: SetPVarInt(playerid, "ToyID", 18650);
			case 4: SetPVarInt(playerid, "ToyID", 18651);
			case 5: SetPVarInt(playerid, "ToyID", 18652);
		}
		new stringg[512], icount = GetPlayerToySlots(playerid);
		for(new z;z<icount;z++)
		{
			new name[24];
			format(name, sizeof(name), "None");

			for(new i;i<sizeof(HoldingObjectsAll);i++)
			{
				if(HoldingObjectsAll[i][holdingmodelid] == PlayerToyInfo[playerid][z][ptModelID])
				{
					strunpack(name, HoldingObjectsAll[i][holdingmodelname], sizeof(name));
				}
			}

			strunpack(boneName, HoldingBones[PlayerToyInfo[playerid][z][ptBone]], sizeof(boneName));
			format(stringg, sizeof(stringg), "%s(%d) %s (Gan: %s)\n", stringg, z, name, boneName);
		}
		ShowPlayerDialogEx(playerid, DIALOG_SHOPBUYTOYS, DIALOG_STYLE_LIST, "Chon mot Slot", stringg, "Chon", "Huy");
	}
	if(dialogid == DIALOG_SHOPBUYTOYS && response)
	{
		new name[24];
		for(new i;i<sizeof(HoldingObjectsShop);i++)
		{
			if(HoldingObjectsShop[i][holdingmodelid] == GetPVarInt(playerid, "ToyID"))
			{
				strunpack(name, HoldingObjectsShop[i][holdingmodelname], sizeof(name));
			}
		}
		format(string, sizeof(string), "Vat pham: %s\n\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", name, number_format(PlayerInfo[playerid][pCredits]),number_format(ShopItems[4][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[4][sItemPrice]));
		ShowPlayerDialogEx(playerid, DIALOG_SHOPBUYTOYS2, DIALOG_STYLE_MSGBOX, "Toy Shop", string, "Mua", "Huy");
		SetPVarInt(playerid, "ToySlot", listitem);
	}
	if((dialogid == DIALOG_SHOPBUYTOYS2) && response)
	{
		if(PlayerInfo[playerid][pCredits] < ShopItems[4][sItemPrice])
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits cho vat pham do. Mua credits tai shop.ng-gaming.net");
		}
		else
		{
			if(!toyCountCheck(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong du o toy, co the mua them bang /toys");

			if(PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptModelID] != 0) return SendClientMessageEx(playerid, COLOR_YELLOW, "* O nay da co do. Dung /toys de xoa");

			new name[24];
			for(new i;i<sizeof(HoldingObjectsShop);i++)
			{
				if(HoldingObjectsShop[i][holdingmodelid] == GetPVarInt(playerid, "ToyID"))
				{
					strunpack(name, HoldingObjectsShop[i][holdingmodelname], sizeof(name));
				}
			}

			GivePlayerCredits(playerid, -ShopItems[4][sItemPrice], 1);
			printf("Price4: %d", ShopItems[4][sItemPrice]);
			AmountSold[4]++;
			AmountMade[4] += ShopItems[4][sItemPrice];
			//ShopItems[4][sSold]++;
			//ShopItems[4][sMade] += ShopItems[4][sItemPrice];
			new szQuery[1024];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSold4` = '%d', `AmountMade4` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[4], AmountMade[4]);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			format(string, sizeof(string), "[TOY %i] [User: %s(%i)] [IP: %s] [Credits: %s] [Toy: %s] [Price: %s]", AmountSold[4], GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), name, number_format(ShopItems[4][sItemPrice]));
			Log("logs/credits.log", string), print(string);

			PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptModelID] = GetPVarInt(playerid, "ToyID");

			new modelid = GetPVarInt(playerid, "ToyID");
			if((modelid >= 19006 && modelid <= 19035) || (modelid >= 19138 && modelid <= 19140))
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 2;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.9;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.35;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 90.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 90.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 0.0;
			}
			else if(modelid >= 18891 && modelid <= 18910)
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 2;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.15;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 90.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 180.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 90.0;
			}
			else if(modelid >= 18926 && modelid <= 18935)
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 2;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.1;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 0.0;
			}
			else if(modelid >= 18911 && modelid <= 18920)
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 2;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.1;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.035;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 90.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 180.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 90.0;
			}
			else if(modelid == 19078 || modelid == 19078)
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 16;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 180.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 180.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 0.0;
			}
			else if((modelid >= 18641 && modelid <= 18644) || (modelid >= 19080 && modelid <= 19084) || modelid == 18890)
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 6;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 0.0;
			}
			else
			{
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptBone] = 2;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosX] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptPosZ] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotX] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotY] = 0.0;
				PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptRotZ] = 0.0;
			}
			PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptScaleX] = 1.0;
			PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptScaleY] = 1.0;
			PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptScaleZ] = 1.0;
			PlayerToyInfo[playerid][GetPVarInt(playerid, "ToySlot")][ptTradable] = 1;

			g_mysql_NewToy(playerid, GetPVarInt(playerid, "ToySlot"));

			format(string, sizeof(string), "Ban da mua %s gia %s credits. (O: %d)", name, number_format(ShopItems[4][sItemPrice]), GetPVarInt(playerid, "ToySlot"));
			SendClientMessageEx(playerid, COLOR_CYAN, string);
			SendClientMessageEx(playerid, COLOR_WHITE, "GOI Y: Dung /toys de deo/sua vat nay");
			DeletePVar(playerid, "ToyID"), DeletePVar(playerid, "ToySlot");
		}
	}
	if(dialogid == DIALOG_SELLCREDITS)
	{
		if(response)
		{
			if(GetPVarInt(GetPVarInt(playerid, "CreditsSeller"), "CreditsSeller") != playerid)
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi kia da ngat ket noi, vui long thu lai.");
				DeletePVar(playerid, "CreditsOffer");
				DeletePVar(playerid, "CreditsAmount");
				DeletePVar(playerid, "CreditsSeller");
				DeletePVar(playerid, "CreditsFirstAmount");
				return 1;
			}
			if(PlayerInfo[GetPVarInt(playerid, "CreditsSeller")][pCredits] < GetPVarInt(playerid, "CreditsAmount"))
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Nguoi ban khong du credits.");
				SendClientMessageEx(GetPVarInt(playerid, "CreditsSeller"), COLOR_GREY, "Ban khong du credits.");
				DeletePVar(playerid, "CreditsOffer");
				DeletePVar(playerid, "CreditsAmount");
				DeletePVar(playerid, "CreditsSeller");
				DeletePVar(playerid, "CreditsFirstAmount");
				return 1;
			}
			if(GetPlayerCash(playerid) < GetPVarInt(playerid, "CreditsOffer"))
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien de chap nhan de nghi.");
				SendClientMessageEx(GetPVarInt(playerid, "CreditsSeller"), COLOR_GREY, "Nguoi choi do khong du tien de chap nhan de nghi cua ban.");
				DeletePVar(playerid, "CreditsOffer");
				DeletePVar(playerid, "CreditsAmount");
				DeletePVar(playerid, "CreditsSeller");
				DeletePVar(playerid, "CreditsFirstAmount");
				return 1;
			}
			new szMessage[156];

			GivePlayerCash(playerid, -GetPVarInt(playerid, "CreditsOffer"));
			GivePlayerCash(GetPVarInt(playerid, "CreditsSeller"), GetPVarInt(playerid, "CreditsOffer"));

			GivePlayerCredits(playerid, GetPVarInt(playerid, "CreditsAmount"), 0);
			GivePlayerCredits(GetPVarInt(playerid, "CreditsSeller"), -GetPVarInt(playerid, "CreditsFirstAmount"), 0);

			AmountSold[21]++;
			AmountMade[21] += GetPVarInt(playerid, "CreditsFirstAmount")-GetPVarInt(playerid, "CreditsAmount");
			//ShopItems[21][sSold]++;
			//ShopItems[21][sMade] += GetPVarInt(playerid, "CreditsFirstAmount")-GetPVarInt(playerid, "CreditsAmount");

			mysql_format(MainPipeline, szMessage, sizeof(szMessage), "UPDATE `sales` SET `TotalSold21` = '%d', `AmountMade21` = '%d' WHERE `Month` > NOW() - INTERVAL 1 MONTH", AmountSold[21], AmountMade[21]);
			mysql_tquery(MainPipeline, szMessage, "OnQueryFinish", "i", SENDDATA_THREAD);
			print(szMessage);

			SendClientMessageEx(playerid, COLOR_CYAN, "Ban nhan de nghi %s credits gia $%s tu %s.", number_format(GetPVarInt(playerid, "CreditsAmount")), number_format(GetPVarInt(playerid, "CreditsOffer")), GetPlayerNameEx(GetPVarInt(playerid, "CreditsSeller")));

			SendClientMessageEx(GetPVarInt(playerid, "CreditsSeller"), COLOR_CYAN, "%s da nhan de nghi %s credits gia $%s cua ban.", GetPlayerNameEx(playerid), number_format(GetPVarInt(playerid, "CreditsAmount")), number_format(GetPVarInt(playerid, "CreditsOffer")));

			format(szMessage, sizeof(szMessage), "[S %s(%d)][IP %s][B %s(%d)][IP %s][C %s][P $%s]", GetPlayerNameEx(GetPVarInt(playerid, "CreditsSeller")),GetPlayerSQLId(GetPVarInt(playerid, "CreditsSeller")), GetPlayerIpEx(GetPVarInt(playerid, "CreditsSeller")),
			GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(GetPVarInt(playerid, "CreditsAmount")), number_format(GetPVarInt(playerid, "CreditsOffer")));
			Log("logs/sellcredits.log", szMessage), print(szMessage);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban da tu choi de nghi credits.");
			SendClientMessageEx(GetPVarInt(playerid, "CreditsSeller"), COLOR_GREY, "De nghi credits cua ban da bi tu choi.");
		}
		DeletePVar(playerid, "CreditsOffer");
		DeletePVar(playerid, "CreditsAmount");
		DeletePVar(playerid, "CreditsSeller");
		DeletePVar(playerid, "CreditsFirstAmount");
	}
	if(dialogid == DIALOG_TACKLED)
	{
		if(response) // complying
		{
			SetPVarInt(playerid, "TackledResisting", 1);
		}
		else // resisting
		{
			SetPVarInt(playerid, "TackledResisting", 2);
			format(string, sizeof(string), "** %s vat lon voi %s de tim cach thoat.", GetPlayerNameEx(playerid), GetPlayerNameEx(GetPVarInt(playerid, "IsTackled")));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		}
	}
	if(dialogid == DIALOG_RIMMOD)
	{
		if(response)
		{
			new szRims[24];
			switch(listitem)
			{
				case 0: SetPVarInt(playerid, "RimMod", 1025), szRims = "Offroad";
				case 1: SetPVarInt(playerid, "RimMod", 1073), szRims = "Shadow";
				case 2: SetPVarInt(playerid, "RimMod", 1074), szRims = "Mega";
				case 3: SetPVarInt(playerid, "RimMod", 1075), szRims = "Rimshine";
				case 4: SetPVarInt(playerid, "RimMod", 1076), szRims = "Wires";
				case 5: SetPVarInt(playerid, "RimMod", 1077), szRims = "Classic";
				case 6: SetPVarInt(playerid, "RimMod", 1078), szRims = "Twist";
				case 7: SetPVarInt(playerid, "RimMod", 1079), szRims = "Cutter";
				case 8: SetPVarInt(playerid, "RimMod", 1080), szRims = "Switch";
				case 9: SetPVarInt(playerid, "RimMod", 1081), szRims = "Grove";
				case 10: SetPVarInt(playerid, "RimMod", 1082), szRims = "Import";
				case 11: SetPVarInt(playerid, "RimMod", 1083), szRims = "Dollar";
				case 12: SetPVarInt(playerid, "RimMod", 1084), szRims = "Trance";
				case 13: SetPVarInt(playerid, "RimMod", 1085), szRims = "Atomic";
				case 14: SetPVarInt(playerid, "RimMod", 1096), szRims = "Ahab";
				case 15: SetPVarInt(playerid, "RimMod", 1097), szRims = "Virtual";
				case 16: SetPVarInt(playerid, "RimMod", 1098), szRims = "Access";
			}
			new szMessage[128];
			format(szMessage, 128, "Ban sap lap mam %s cho xe nay.", szRims);
			ShowPlayerDialogEx(playerid, DIALOG_RIMMOD2, DIALOG_STYLE_MSGBOX, "Xac nhan mam xe", szMessage, "Xac nhan", "Tu choi");
		}
	}
	if(dialogid == DIALOG_RIMMOD2)
	{
		if(response)
		{
			if(PlayerInfo[playerid][pRimMod] == 0)
				return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co bo do mam xe.");

			if(IsRestrictedVehicle(GetVehicleModel(GetPlayerVehicleID(playerid)))) return SendClientMessageEx(playerid, COLOR_GREY, "Xe nay khong the lap mam");

			if(InvalidModCheck(GetVehicleModel(GetPlayerVehicleID(playerid)), 1025))
			{
				for(new d = 0 ; d < MAX_PLAYERVEHICLES; d++)
				{
					if(IsPlayerInVehicle(playerid, PlayerVehicleInfo[playerid][d][pvId]))
					{
						new szLog[128];
						format(szLog, sizeof(szLog), "%s(%d) has modded his vehicle with rims %d", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPVarInt(playerid, "RimMod"));
						Log("logs/rimkit.log", szLog);
						SendClientMessageEx(playerid, COLOR_GREEN, "Da lap mam xe.");
						PlayerInfo[playerid][pRimMod]--;

						AddVehicleComponent(GetPlayerVehicleID(playerid), GetPVarInt(playerid, "RimMod"));
						DeletePVar(playerid, "RimMod");
						UpdatePlayerVehicleMods(playerid, d);
						return 1;
					}
				}
				SendClientMessageEx(playerid, COLOR_GREY, "Ban can o trong xe cua minh.");
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "Xe do khong the do mam.");
			}
		}
	}
	if(dialogid == DIALOG_PVIPVOUCHER)
	{
		if(response)
		{
			PlayerInfo[playerid][pPVIPVoucher]--;
			PlayerInfo[playerid][pTotalCredits] = ShopItems[21][sItemPrice];

			PlayerInfo[playerid][pDonateRank] = 4;
			PlayerInfo[playerid][pVIPExpire] = gettime()+2592000*1;
			PlayerInfo[playerid][pTempVIP] = 0;
			PlayerInfo[playerid][pBuddyInvited] = 0;
			PlayerInfo[playerid][pVIPSellable] = 1;

			LoadPlayerDisabledVehicles(playerid);

			if(PlayerInfo[playerid][pVIPM] == 0)
			{
				PlayerInfo[playerid][pVIPM] = VIPM;
				VIPM++;
			}
			format(string, sizeof(string), "%s(%d) (IP: %s) has used a 1 month PVIP Voucher.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid));
			Log("logs/credits.log", string);
			format(string, sizeof(string), "AdmCmd: VIP %s duoc server dat thanh Platinum (4) (1 thang)(voucher).", GetPlayerNameEx(playerid));

			ABroadCast(COLOR_LIGHTRED, string, 2);
			format(string, sizeof(string), "AdmCmd: %s's(%d) VIP level to Platinum (4) by the server (1 Month)(voucher).", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid));
			Log("logs/setvip.log", string), Log("logs/vouchers.log", string);

			format(string, sizeof(string), "Da cap Platinum VIP, ban con %d PVIP Voucher.", PlayerInfo[playerid][pPVIPVoucher]);
			SendClientMessageEx(playerid, COLOR_CYAN, string);
			SendClientMessageEx(playerid, COLOR_CYAN, "** PVIP Voucher 1 thang se het han sau 1 thang.");
			PlayerInfo[playerid][pArmsSkill] = 1200;

			new szQuery[128];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `accounts` SET `TotalCredits`=%d WHERE `id` = %d", PlayerInfo[playerid][pTotalCredits], GetPlayerSQLId(playerid));
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "ii", SENDDATA_THREAD, playerid);
		}
	}
	if(dialogid == GIVETOY)
	{
		if(response)
		{
			new giveplayerid = GetPVarInt(playerid, "giveplayeridtoy"),
				toyid = GetPVarInt(playerid, "toyid"),
				stringg[128];
			if(!toyCountCheck(giveplayerid)) return SendClientMessageEx(playerid, COLOR_YELLOW, "* Nguoi choi nay khong the nhan them toy!");
			if(PlayerToyInfo[giveplayerid][listitem][ptModelID] != 0) return SendClientMessageEx(playerid, COLOR_YELLOW, "* Nguoi choi nay da co toy trong o da chon!");

			PlayerToyInfo[giveplayerid][listitem][ptModelID] = toyid;
			PlayerToyInfo[giveplayerid][listitem][ptBone] = 1;
			PlayerToyInfo[giveplayerid][listitem][ptTradable] = 1;
			PlayerToyInfo[giveplayerid][listitem][ptSpecial] = 0;
			SendClientMessageEx(playerid, COLOR_YELLOW, "Ban da cap cho %s object %d", GetPlayerNameEx(giveplayerid), toyid);
			SendClientMessageEx(giveplayerid, COLOR_WHITE, "Ban nhan toy moi tu quan tri vien!");
			format(stringg, sizeof(stringg), "%s has given %s(%d) object %d", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), toyid);
			Log("logs/toys.log", stringg);
			DeletePVar(playerid, "giveplayeridtoy");
			DeletePVar(playerid, "toyid");
			new v = listitem; // lazy
			g_mysql_NewToy(giveplayerid, v);
		}
	}
	if(dialogid == PBFORCE)
	{
		new giveplayerid = GetPVarInt(playerid, "tempPBP");
		DeletePVar(playerid, "tempPSP");
		if(response)
		{
			if(PlayerInfo[playerid][pAdmin] >= 2)
			{
				if(IsPlayerConnected(giveplayerid))
				{
					if(GetPVarType(giveplayerid, "IsInArena"))
					{
						LeavePaintballArena(giveplayerid, GetPVarInt(giveplayerid, "IsInArena"));
						SendClientMessageEx(playerid, COLOR_WHITE, "Da dua %s ra khoi Paintball. Gio co the dich chuyen nguoi nay.", GetPlayerNameEx(giveplayerid));
						format(string, sizeof(string), "Ban da bi %s dua ra khoi Paintball.", GetPlayerNameEx(playerid));
						SendClientMessageEx(giveplayerid, COLOR_WHITE, string);
					}
					else
					{
						SendClientMessageEx(playerid, COLOR_WHITE, "Nguoi choi khong dang choi Paintball.");
					}
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi choi da thoat.");
				}
			}
		}
		else
		{
			if(PlayerInfo[playerid][pAdmin] >= 2)
			{
				if(IsPlayerConnected(giveplayerid))
				{
					format(string, sizeof(string), "%s se tiep tuc tran Paintball.", GetPlayerNameEx(giveplayerid));
					SendClientMessageEx(playerid, COLOR_WHITE, string);
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi choi da thoat.");
				}
			}
		}
	}
	if(dialogid == DISPLAY_STATS)
	{
		new targetid = GetPVarInt(playerid, "ShowStats");
		if(IsPlayerConnected(targetid))
		{
			if(response)
			{
				new resultline[1024], header[64], pvtstring[256], adminstring[128], advisorstring[128];

				if (PlayerInfo[playerid][pAdmin] >= 2)
				{
					format(pvtstring, sizeof(pvtstring), "Nha: %d\nNha 2: %d\nNha 3: %d\nThue: %d\nInt: %d\nVW: %d\nVW thuc: %d\nTu: %d sec\nWJail: %d sec\nVIPM: %i\nGVIP: %i\nReward Hours: %.2f\n", PlayerInfo[targetid][pPhousekey], PlayerInfo[targetid][pPhousekey2], PlayerInfo[targetid][pPhousekey3], PlayerInfo[targetid][pRenting],
					GetPlayerInterior(targetid), PlayerInfo[targetid][pVW], GetPlayerVirtualWorld(targetid), PlayerInfo[targetid][pJailTime], PlayerInfo[targetid][pBeingSentenced], PlayerInfo[targetid][pVIPM], PlayerInfo[targetid][pGVip], PlayerInfo[targetid][pRewardHours]);
				}
				if(PlayerInfo[playerid][pAdmin] >= 4 && PlayerInfo[targetid][pAdmin] >= 2) format(adminstring, sizeof(adminstring), "Bao cao da nhan: %s\nBao cao da bo: %s\n", number_format(PlayerInfo[targetid][pAcceptReport]), number_format(PlayerInfo[targetid][pTrashReport]));
				if((PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pPR] >= 1 || PlayerInfo[playerid][pASM] >= 1) && PlayerInfo[targetid][pHelper] >= 2) format(advisorstring, sizeof(advisorstring), "Gio truc: %s\nYeu cau ho tro da nhan: %s\n", number_format(PlayerInfo[targetid][pDutyHours]), number_format(PlayerInfo[targetid][pAcceptedHelp]));

				format(header, sizeof(header), "Thong tin cua %s", GetPlayerNameEx(targetid));
				format(resultline, sizeof(resultline),"{FFFFFF}Muc truy na: %d\n\
					Toi pham: %s\n\
					Bi bat: %s\n\
					Gioi thieu: %s\n\
					Canh cao: %s\n\
					Cam vu khi: %s gio\n\
					Canh cao gang: %s\n\
					Cam Newbie Chat: %s\n\
					Cam quang cao: %s\n\
					Cam bao cao: %s\n\
					%s\
					%s\
					%s",
					PlayerInfo[targetid][pWantedLevel],
					number_format(PlayerInfo[targetid][pCrimes]),
					number_format(PlayerInfo[targetid][pArrested]),
					number_format(PlayerInfo[targetid][pRefers]),
					number_format(PlayerInfo[targetid][pWarns]),
					number_format(PlayerInfo[targetid][pWRestricted]),
					number_format(PlayerInfo[targetid][pGangWarn]),
					number_format(PlayerInfo[targetid][pNMuteTotal]),
					number_format(PlayerInfo[targetid][pADMuteTotal]),
					number_format(PlayerInfo[targetid][pRMutedTotal]),
					pvtstring,
					advisorstring,
					adminstring);
				ShowPlayerDialogEx(playerid, DISPLAY_STATS2, DIALOG_STYLE_MSGBOX, header, resultline, "Trang dau", "Dong");
			}
			else DeletePVar(playerid, "ShowStats");
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi dang duoc kiem tra da dang xuat.");
			DeletePVar(playerid, "ShowStats");
			return 1;
		}
	}
	if(dialogid == DISPLAY_STATS2)
	{
		new targetid = GetPVarInt(playerid, "ShowStats");
		if(IsPlayerConnected(targetid))
		{
			if(response)
			{
				ShowStats(playerid, targetid);
			}
			else DeletePVar(playerid, "ShowStats");
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi dang duoc kiem tra da dang xuat.");
			DeletePVar(playerid, "ShowStats");
			return 1;
		}
	}
	#if defined event_chancegambler
	if(dialogid == DIALOG_ROLL)
	{
		if(response)
		{
			if(FIFEnabled == 1)
			{
				new iNumber = Random(1, 11);
				if(iNumber > 4)
				{
					new szMessage[128];
					SendClientMessageEx(playerid, COLOR_CYAN, "Ban do duoc %d va nhan doi luot!", iNumber);
					format(szMessage, sizeof(szMessage), "* %s do duoc %d va nhan doi luot!", GetPlayerNameEx(playerid), iNumber);
					ProxDetector(30.0, playerid, szMessage, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
					FIFInfo[playerid][FIFChances] *= 2;
					format(szMessage, sizeof(szMessage), "%s (IP:%s) has doubled their chances. (Chances: %d)", GetPlayerNameEx(playerid), GetPlayerIpEx(playerid), FIFInfo[playerid][FIFChances]);
					Log("logs/gamblechances.log", szMessage);
				}
				else
				{
					new szMessage[128];
					format(szMessage, sizeof(szMessage), "* %s do duoc %d va mat het luot!", GetPlayerNameEx(playerid), iNumber);
					ProxDetector(30.0, playerid, szMessage, COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
					SendClientMessageEx(playerid, COLOR_CYAN, "Ban do duoc %d va mat het luot!", iNumber);
					FIFInfo[playerid][FIFChances] = 0;
					format(szMessage, sizeof(szMessage), "%s (IP:%s) has lost it all. (Chances: %d)", GetPlayerNameEx(playerid), GetPlayerIpEx(playerid), FIFInfo[playerid][FIFChances]);
					Log("logs/gamblechances.log", szMessage);
				}
			}
		}
	}
	if(dialogid == DIALOG_HUNGERGAMES)
	{
		if(response)
		{
			if(PlayerInfo[playerid][pHungerVoucher] == 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co Hunger Games Vouchers.");
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da dung Hunger Games Voucher, nhan 100 HP thay vi 50 trong su kien va mot MP5 mien phi.");
			PlayerInfo[playerid][pHungerVoucher]--;

			SetPVarInt(playerid, "HungerVoucher", 1);
		}
	}
	#endif
	if(dialogid == DIALOG_NRNCONFIRM)
	{
		if(response)
		{
			new playersz[5];
			GetPVarString(playerid, "nrn", playersz, 5);
			DeletePVar(playerid, "nrn");
			pc_cmd_nrn(playerid, playersz);
		}
		else
		{
			DeletePVar(playerid, "nrn");
		}
	}
	if(dialogid == DIALOG_CONFIRMADP)
	{
		if(response)
		{
			new advert[256], reportid = GetPVarInt(playerid, "ReporterID");
			new shared;
			GetPVarString(reportid, "PriorityAdText", advert, 128);
			if(isnull(advert) || !IsPlayerConnected(reportid))
			{
				DeletePVar(playerid, "ReporterID");
				DeletePVar(reportid, "PriorityAdText");
				DeletePVar(reportid, "RequestingAdP");
				DeletePVar(reportid, "AdvertVoucher");
				return SendClientMessageEx(playerid, -1, "Quang cao co loi, noi dung trong hoac nguoi choi da thoat.");
			}
			// Do not comment this out! This is needed to re-format the ad with the proper format - Nathan
			format(advert, sizeof(advert), "Quang cao: %s - lien he: %s (%d)", advert, GetPlayerNameEx(reportid), PlayerInfo[reportid][pPnumber]);
			SendClientMessageEx(reportid, -1, "Quang cao uu tien cua ban da duoc duyet va dang.");
			if(GetPVarInt(reportid, "AdvertVoucher") > 0)
			{
				SendClientMessageEx(reportid, COLOR_CYAN, "Ban da dung 1 Priority Advertisement.");
				PlayerInfo[reportid][pAdvertVoucher]--;
			}
			else if(PlayerInfo[reportid][pFreeAdsLeft] > 0 && PlayerInfo[reportid][pDonateRank] >= 4)
			{
				PlayerInfo[reportid][pFreeAdsLeft]--;
				SendClientMessageEx(reportid, COLOR_YELLOW, "Platinum VIP: Da dung mot luot quang cao mien phi, hom nay con %d luot.", PlayerInfo[reportid][pFreeAdsLeft]);
			}
			else if(PlayerInfo[reportid][pDonateRank] == 2)
			{
				GivePlayerCash(reportid, -125000);
				shared = 125000 / 3;
				SendClientMessageEx(reportid, COLOR_YELLOW, "Uu dai VIP: Ban tra $125,000 vi la Silver VIP.");
			}
			else if(PlayerInfo[reportid][pDonateRank] == 3)
			{
				GivePlayerCash(reportid, -100000);
				shared = 100000 / 3;
				SendClientMessageEx(reportid, COLOR_YELLOW, "Uu dai VIP: Ban tra $100,000 vi la Gold VIP.");
			}
			else if(PlayerInfo[reportid][pDonateRank] >= 4)
			{
				GivePlayerCash(reportid, -50000);
				shared = 50000 / 3;
				SendClientMessageEx(reportid, COLOR_YELLOW, "Uu dai VIP: Ban tra $50,000 vi la Platinum VIP.");
			}
			else
			{
				GivePlayerCash(reportid, -150000);
				shared = 150000 / 3;
			}
			iAdverTimer = gettime()+30;

			if(shared > 0)
			{
				for(new x; x < MAX_GROUPS; x++)
				{
					if(arrGroupData[x][g_iGroupType] == GROUP_TYPE_NEWS)
					{
						arrGroupData[x][g_iBudget] += shared;
					}
				}
			}

			foreach(new i: Player)
			{
				if(PlayerInfo[i][pToggledChats][CHAT_NEWS] == 0 && InsideMainMenu{i} != 1 && ActiveChatbox[i] != 0) SendClientMessage(i, TEAM_GROVE_COLOR, advert);
			}
			format(advert, sizeof(advert), "%s -- (SQLID: %d) | Accepted by: %s -- (SQLID: %d)", advert, GetPlayerSQLId(reportid), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid));
			Log("logs/pads.log", advert);

			/*if(Homes[reportid] > 0 && AdvertType[reportid] == 1 && !PlayerInfo[playerid][pShopNotice])
			{
				PlayerTextDrawSetString(reportid, MicroNotice[reportid], ShopMsg[6]);
				PlayerTextDrawShow(reportid, MicroNotice[reportid]);
				SetTimerEx("HidePlayerTextDraw", 10000, false, "ii", reportid, _:MicroNotice[reportid]);
			}*/

			DeletePVar(reportid, "PriorityAdText");
			DeletePVar(playerid, "ReporterID");
			DeletePVar(reportid, "RequestingAdP");
			DeletePVar(reportid, "AdvertVoucher");
		}
		else
		{
			SendClientMessageEx(GetPVarInt(playerid, "ReporterID"), -1, "Quang cao uu tien cua ban da bi tu choi.");
			szAdvert[GetPVarInt(playerid, "ReporterID")][0] = 0;
			DeletePVar(GetPVarInt(playerid, "ReporterID"), "PriorityAdText");
			DeletePVar(GetPVarInt(playerid, "ReporterID"), "AdvertVoucher");
			DeletePVar(GetPVarInt(playerid, "ReporterID"), "RequestingAdP");
			DeletePVar(playerid, "ReporterID");
		}
	}
	if(dialogid == DIALOG_GIFTBOX_INFO)
	{
		if(response)
		{
			return ShowPlayerDynamicGiftBox(playerid);
		}
	}
	if(dialogid == DIALOG_GIFTBOX_VIEW)
	{
		if(response)
		{
			if(PlayerInfo[playerid][pAdmin] < 99999 && PlayerInfo[playerid][pShopTech] < 3) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
			switch(listitem)
			{
				case 1:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgMoney][0], dgVar[dgMoney][1], dgVar[dgMoney][2], GetDynamicGiftBoxType(dgVar[dgMoney][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Tien", string, "Quay lai", "");
				}
				case 2:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgRimKit][0], dgVar[dgRimKit][1], dgVar[dgRimKit][2], GetDynamicGiftBoxType(dgVar[dgRimKit][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Bo do mam", string, "Quay lai", "");
				}
				case 3:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgFirework][0], dgVar[dgFirework][1], dgVar[dgFirework][2], GetDynamicGiftBoxType(dgVar[dgFirework][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Phao hoa", string, "Quay lai", "");
				}
				case 4:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgGVIP][0], dgVar[dgGVIP][1], dgVar[dgGVIP][2], GetDynamicGiftBoxType(dgVar[dgGVIP][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - GVIP 7 ngay", string, "Quay lai", "");
				}
				case 5:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgGVIPEx][0], dgVar[dgGVIPEx][1], dgVar[dgGVIPEx][2], GetDynamicGiftBoxType(dgVar[dgGVIPEx][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - GVIP 1 thang", string, "Quay lai", "");
				}
				case 6:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgSVIP][0], dgVar[dgSVIP][1], dgVar[dgSVIP][2], GetDynamicGiftBoxType(dgVar[dgSVIP][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - SVIP 7 ngay", string, "Quay lai", "");
				}
				case 7:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgSVIPEx][0], dgVar[dgSVIPEx][1], dgVar[dgSVIPEx][2], GetDynamicGiftBoxType(dgVar[dgSVIPEx][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - SVIP 1 thang", string, "Quay lai", "");
				}
				case 8:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgCarSlot][0], dgVar[dgCarSlot][1], dgVar[dgCarSlot][2], GetDynamicGiftBoxType(dgVar[dgCarSlot][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - O chua xe", string, "Quay lai", "");
				}
				case 9:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgToySlot][0], dgVar[dgToySlot][1], dgVar[dgToySlot][2], GetDynamicGiftBoxType(dgVar[dgToySlot][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - O chua toy", string, "Quay lai", "");
				}
				case 10:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgArmor][0], dgVar[dgArmor][1], dgVar[dgArmor][2], GetDynamicGiftBoxType(dgVar[dgArmor][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Giap", string, "Quay lai", "");
				}
				case 11:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgFirstaid][0], dgVar[dgFirstaid][1], dgVar[dgFirstaid][2], GetDynamicGiftBoxType(dgVar[dgFirstaid][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Bo so cuu", string, "Quay lai", "");
				}
				case 12:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgDDFlag][0], dgVar[dgDDFlag][1], dgVar[dgDDFlag][2], GetDynamicGiftBoxType(dgVar[dgDDFlag][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Flag Dynamic Door", string, "Quay lai", "");
				}
				case 13:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgGateFlag][0], dgVar[dgGateFlag][1], dgVar[dgGateFlag][2], GetDynamicGiftBoxType(dgVar[dgGateFlag][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Flag Dynamic Gate", string, "Quay lai", "");
				}
				case 14:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgCredits][0], dgVar[dgCredits][1], dgVar[dgCredits][2], GetDynamicGiftBoxType(dgVar[dgCredits][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Credit", string, "Quay lai", "");
				}
				case 15:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgPriorityAd][0], dgVar[dgPriorityAd][1], dgVar[dgPriorityAd][2], GetDynamicGiftBoxType(dgVar[dgPriorityAd][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Quang cao uu tien", string, "Quay lai", "");
				}
				case 16:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgHealthNArmor][0], dgVar[dgHealthNArmor][1], dgVar[dgHealthNArmor][2], GetDynamicGiftBoxType(dgVar[dgHealthNArmor][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Mau va giap", string, "Quay lai", "");
				}
				case 17:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgGiftReset][0], dgVar[dgGiftReset][1], dgVar[dgGiftReset][2], GetDynamicGiftBoxType(dgVar[dgGiftReset][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Dat lai qua", string, "Quay lai", "");
				}
				case 18:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgMaterial][0], dgVar[dgMaterial][1], dgVar[dgMaterial][2], GetDynamicGiftBoxType(dgVar[dgMaterial][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Vat lieu", string, "Quay lai", "");
				}
				case 19:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgWarning][0], dgVar[dgWarning][1], dgVar[dgWarning][2], GetDynamicGiftBoxType(dgVar[dgWarning][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Canh bao", string, "Quay lai", "");
				}
				case 20:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgPot][0], dgVar[dgPot][1], dgVar[dgPot][2], GetDynamicGiftBoxType(dgVar[dgPot][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Can sa", string, "Quay lai", "");
				}
				case 21:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgCrack][0], dgVar[dgCrack][1], dgVar[dgCrack][2], GetDynamicGiftBoxType(dgVar[dgCrack][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Crack", string, "Quay lai", "");
				}
				case 22:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgPaintballToken][0], dgVar[dgPaintballToken][1], dgVar[dgPaintballToken][2], GetDynamicGiftBoxType(dgVar[dgPaintballToken][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Paintball Token", string, "Quay lai", "");
				}
				case 23:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgVIPToken][0], dgVar[dgVIPToken][1], dgVar[dgVIPToken][2], GetDynamicGiftBoxType(dgVar[dgVIPToken][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - VIP Token", string, "Quay lai", "");
				}
				case 24:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgRespectPoint][0], dgVar[dgRespectPoint][1], dgVar[dgRespectPoint][2], GetDynamicGiftBoxType(dgVar[dgRespectPoint][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Diem kinh nghiem", string, "Quay lai", "");
				}
				case 25:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgCarVoucher][0], dgVar[dgCarVoucher][1], dgVar[dgCarVoucher][2], GetDynamicGiftBoxType(dgVar[dgCarVoucher][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Car Voucher", string, "Quay lai", "");
				}
				case 26:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgBuddyInvite][0], dgVar[dgBuddyInvite][1], dgVar[dgBuddyInvite][2], GetDynamicGiftBoxType(dgVar[dgBuddyInvite][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Buddy Invite", string, "Quay lai", "");
				}
				case 27:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgLaser][0], dgVar[dgLaser][1], dgVar[dgLaser][2], GetDynamicGiftBoxType(dgVar[dgLaser][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Laser", string, "Quay lai", "");
				}
				case 28:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nToy ID: %d\nDo hiem: %s", dgVar[dgCustomToy][0], dgVar[dgCustomToy][1], dgVar[dgCustomToy][2], GetDynamicGiftBoxType(dgVar[dgCustomToy][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Custom Toy", string, "Quay lai", "");
				}
				case 29:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgAdmuteReset][0], dgVar[dgAdmuteReset][1], dgVar[dgAdmuteReset][2], GetDynamicGiftBoxType(dgVar[dgAdmuteReset][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Go cam quang cao", string, "Quay lai", "");
				}
				case 30:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgNewbieMuteReset][0], dgVar[dgNewbieMuteReset][1], dgVar[dgNewbieMuteReset][2], GetDynamicGiftBoxType(dgVar[dgNewbieMuteReset][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Go cam Newbie", string, "Quay lai", "");
				}
				case 31:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgRestrictedCarVoucher][0], dgVar[dgRestrictedCarVoucher][1], dgVar[dgRestrictedCarVoucher][2], GetDynamicGiftBoxType(dgVar[dgRestrictedCarVoucher][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - Restricted Car Voucher", string, "Quay lai", "");
				}
				case 32:
				{
					format(string, sizeof(string), "Bat: %d\nCon lai: %d\nSo luong trao: %d\nDo hiem: %s", dgVar[dgPlatinumVIPVoucher][0], dgVar[dgPlatinumVIPVoucher][1], dgVar[dgPlatinumVIPVoucher][2], GetDynamicGiftBoxType(dgVar[dgPlatinumVIPVoucher][3]));
					ShowPlayerDialogEx(playerid, DIALOG_GIFTBOX_INFO, DIALOG_STYLE_MSGBOX, "Hop qua dong - PVIP Voucher 1 thang", string, "Quay lai", "");
				}
				default: return true;
			}
		}
	}
	if(dialogid == DIALOG_VIPSPAWN)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					SetPVarInt(playerid, "VIPSpawn", 1);
					SendClientMessageEx(playerid, COLOR_CYAN, "Da dung luot hoi sinh mien phi tai phong Gold VIP+, ban se den Los Santos VIP sau 60 giay.");
				}
				case 1:
				{
					SetPVarInt(playerid, "VIPSpawn", 2);
					SendClientMessageEx(playerid, COLOR_CYAN, "Da dung luot hoi sinh mien phi tai phong Gold VIP+, ban se den San Fierro VIP sau 60 giay.");
				}
				case 2:
				{
					SetPVarInt(playerid, "VIPSpawn", 3);
					SendClientMessageEx(playerid, COLOR_CYAN, "Da dung luot hoi sinh mien phi tai phong Gold VIP+, ban se den Las Ventures VIP sau 60 giay.");
				}
				case 3:
				{
					SetPVarInt(playerid, "VIPSpawn", 4);
					SendClientMessageEx(playerid, COLOR_GREY, "Lan nay ban khong dung luot hoi sinh mien phi tai phong Gold VIP+.");
				}
			}
			SetPlayerSpawn(playerid);
		}
		else
		{
			SetPVarInt(playerid, "VIPSpawn", 4);
			SendClientMessageEx(playerid, COLOR_GREY, "Lan nay ban khong dung luot hoi sinh mien phi tai phong Gold VIP+.");
			SetPlayerSpawn(playerid);
		}
	}
	if(dialogid == DIALOG_NONRPACTION)
	{
		if(response)
		{
			ResetPlayerWeaponsEx(GetPVarInt(playerid, "PendingAction4"));
			PlayerInfo[GetPVarInt(playerid, "PendingAction4")][pAccountRestricted] = 1;
			SendClientMessageEx(playerid, COLOR_RED, "Ban da han che tai khoan nguoi choi nay.");
			PlayerTextDrawShow(GetPVarInt(playerid, "PendingAction4"), AccountRestriction[GetPVarInt(playerid, "PendingAction4")]);
			PlayerTextDrawShow(GetPVarInt(playerid, "PendingAction4"), AccountRestrictionEx[GetPVarInt(playerid, "PendingAction4")]);
			format(string, sizeof(string), "%s has restricted %s(%d) account", GetPlayerNameEx(playerid), GetPlayerNameEx(GetPVarInt(playerid, "PendingAction4")), GetPlayerSQLId(GetPVarInt(playerid, "PendingAction4")));
			Log("logs/restrictaccount.log", string);
			return DeletePVar(playerid, "PendingAction4");
		}
		else
		{
			DeletePVar(playerid, "PendingAction4");
			return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da chon khong han che tai khoan nguoi choi nay.");
		}
	}
	if(dialogid == DIALOG_VIPJOB)
	{
		if(response && PlayerInfo[playerid][pDonateRank] >= 4 && PlayerInfo[playerid][pVIPJob] > 0)
		{
			switch(listitem)
			{
				case 0:
				{
					if(PlayerInfo[playerid][pDetSkill] >= 400)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Ky nang cong viec nay da dat cap cao nhat.");
						return 1;
					}
					PlayerInfo[playerid][pDetSkill] = 400;
					SendClientMessageEx(playerid, COLOR_YELLOW, "Ky nang Detective cua ban da dat cap 5.");
				}
				case 1:
				{
					if(PlayerInfo[playerid][pLawSkill] >= 400)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Ky nang cong viec nay da dat cap cao nhat.");
						return 1;
					}
					PlayerInfo[playerid][pLawSkill] = 400;
					SendClientMessageEx(playerid, COLOR_YELLOW, "Ky nang Lawyer cua ban da dat cap 5.");
				}
				case 2:
				{
					if(PlayerInfo[playerid][pSexSkill] >= 400)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Ky nang cong viec nay da dat cap cao nhat.");
						return 1;
					}
					PlayerInfo[playerid][pSexSkill] = 400;
					SendClientMessageEx(playerid, COLOR_YELLOW, "Ky nang Whore cua ban da dat cap 5.");
				}
				case 3:
				{
					return 1;
				}
				case 4:
				{
					if(PlayerInfo[playerid][pDrugSmuggler] >= 200)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Ky nang cong viec nay da dat cap cao nhat.");
						return 1;
					}
					PlayerInfo[playerid][pDrugSmuggler] = 200;
					SendClientMessageEx(playerid, COLOR_YELLOW, "Ky nang Drugs Smuggling cua ban da dat cap 5.");
				}
				case 5:
				{
					if(PlayerInfo[playerid][pArmsSkill] >= 1200)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Ky nang cong viec nay da dat cap cao nhat.");
						return 1;
					}
					PlayerInfo[playerid][pArmsSkill] = 1200;
					SendClientMessageEx(playerid, COLOR_YELLOW, "Ky nang Arms Dealer cua ban da dat cap 5.");
				}
				case 6:
				{
					if(PlayerInfo[playerid][pMechSkill] >= 400)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Ky nang cong viec nay da dat cap cao nhat.");
						return 1;
					}
					PlayerInfo[playerid][pMechSkill] = 400;
					SendClientMessageEx(playerid, COLOR_YELLOW, "Ky nang Car Mechanic cua ban da dat cap 5.");
				}
				case 7:
				{
					if(PlayerInfo[playerid][pBoxSkill] >= 400)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Ky nang cong viec nay da dat cap cao nhat.");
						return 1;
					}
					PlayerInfo[playerid][pBoxSkill] = 400;
					SendClientMessageEx(playerid, COLOR_YELLOW, "Ky nang Boxer cua ban da dat cap 5.");
				}
				case 8:
				{
					if(PlayerInfo[playerid][pFishingSkill] >= 400)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Ky nang cong viec nay da dat cap cao nhat.");
						return 1;
					}
					PlayerInfo[playerid][pFishingSkill] = 400;
					SendClientMessageEx(playerid, COLOR_YELLOW, "Ky nang Fishing cua ban da dat cap 5.");
				}
				case 9:
				{
					if(PlayerInfo[playerid][pTruckSkill] >= 401)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Ky nang cong viec nay da dat cap cao nhat.");
						return 1;
					}
					PlayerInfo[playerid][pTruckSkill] = 401;
					SendClientMessageEx(playerid, COLOR_YELLOW, "Ky nang Shipment Contractor cua ban da dat cap 5.");
				}
				/* case 10:
				{
					if(PlayerInfo[playerid][pTreasureSkill] >= 600)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Your skill level of this job is already the highest one.");
						return 1;
					}
					PlayerInfo[playerid][pTreasureSkill] = 600;
					SendClientMessageEx(playerid, COLOR_YELLOW, "Your Treasure Hunter skill level has been set to 5.");
				} */
				case 10:
				{
					if(PlayerInfo[playerid][pCarLockPickSkill] >= 350)
						return SendClientMessageEx(playerid, COLOR_GREY, "Ky nang cong viec nay da dat cap cao nhat.");
					PlayerInfo[playerid][pCarLockPickSkill] = 350;
					SendClientMessageEx(playerid, COLOR_YELLOW, "Lock Picking skill cua ban da duoc dat len cap 5.");
				}
			}
			PlayerInfo[playerid][pVIPJob] = 0;
			OnPlayerStatsUpdate(playerid);
		}
	}
	if(dialogid == DIALOG_WDREPORT)
	{
		if(!response || strlen(inputtext) < 30)
		{
			format(string, sizeof(string), "Mo ta ngan gon hanh vi ban da thay %s thuc hien.\n * It nhat 30 ky tu", GetPlayerNameEx(GetPVarInt(playerid, "SpectatingWatch")));
			return ShowPlayerDialogEx(playerid, DIALOG_WDREPORT, DIALOG_STYLE_INPUT, "Bao cao su viec", string, "Gui", "");
		}
		new szQuery[256];
		mysql_format(MainPipeline, szQuery, sizeof(szQuery), "INSERT INTO `watchdog_reports` (reporter, report, reported, type, time) VALUES ('%d', '%e', '%d', '%d', UNIX_TIMESTAMP())", GetPlayerSQLId(playerid), inputtext, GetPlayerSQLId(GetPVarInt(playerid, "SpectatingWatch")), GetPVarInt(playerid, "WDReport"));
		mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "ii", SENDDATA_THREAD, playerid);
		SendClientMessageEx(playerid, COLOR_GRAD4, inputtext);
		SendClientMessageEx(playerid, COLOR_GRAD1, "Da gui bao cao su viec.");
	}
	if(dialogid == DIALOG_DGRAUTORESET)
	{
		if(!response && GetPVarType(playerid, "dgInputSel")) return pc_cmd_dgedit(playerid, "autoreset");
		if(response)
		{
			if(listitem == 0)
			{
				SetPVarInt(playerid, "dgInputSel", 1);
				return ShowPlayerDialogEx(playerid, DIALOG_DGRAUTORESET, DIALOG_STYLE_INPUT, "Tu dat lai hop qua - Thoi gian", "Nhap khoang thoi gian tu dong dat lai hop qua, tinh bang phut.", "Gui", "Dong");
			}
			if(listitem == 1)
			{
				SetPVarInt(playerid, "dgInputSel", 2);
				return ShowPlayerDialogEx(playerid, DIALOG_DGRAUTORESET, DIALOG_STYLE_INPUT, "Tu dat lai hop qua - So luong", "Nhap so luong them vao vat pham het hang khi tu dat lai hop qua.", "Gui", "Dong");
			}
			if(listitem == 2)
			{
				if(dgTimer != -1)
				{
					KillTimer(dgTimer);
					dgTimer = -1;
					SendClientMessage(playerid, -1, "Da tat tinh nang tu dat lai.");
				}
				else
				{
					if(!dynamicgift) return SendClientMessageEx(playerid, -1, "Chua dat hop qua!");
					if(IsDynamicGiftBoxEnabled == false) return SendClientMessageEx(playerid, -1, "Hop qua dong dang tat! Dung /togdynamicgift de bat.");
					if(dgTimerTime <= 0 || dgAmount <= 0) return SendClientMessageEx(playerid, -1, "Cai dat khong hop le!");
					dgTimer = SetTimer("DG_AutoReset", dgTimerTime*60000, true);
					SendClientMessageEx(playerid, -1, "Da bat tu dat lai. Cai dat: Thoi gian: %d phut | So luong: %d", dgTimerTime, dgAmount);
				}
			}
			if(GetPVarInt(playerid, "dgInputSel") == 1)
			{
				new _time;
				if(sscanf(inputtext, "d", _time) || _time <= 0) return ShowPlayerDialogEx(playerid, DIALOG_DGRAUTORESET, DIALOG_STYLE_INPUT, "Tu dat lai hop qua - Thoi gian", "Nhap khoang thoi gian tu dong dat lai hop qua, tinh bang phut.", "Gui", "Dong");
				dgTimerTime = _time;
				SendClientMessageEx(playerid, -1, "Da dat thoi gian tu dat lai: %d phut.", dgTimerTime);
			}
			if(GetPVarInt(playerid, "dgInputSel") == 2)
			{
				new _amount;
				if(sscanf(inputtext, "d", _amount) || _amount <= 0) return ShowPlayerDialogEx(playerid, DIALOG_DGRAUTORESET, DIALOG_STYLE_INPUT, "Tu dat lai hop qua - So luong", "Nhap so luong them vao vat pham het hang khi tu dat lai hop qua.", "Gui", "Dong");
				dgAmount = _amount;
				SendClientMessageEx(playerid, -1, "Da dat so luong tu dat lai: %d.", dgAmount);
			}
			return pc_cmd_dgedit(playerid, "autoreset");
		}
	}
	if(dialogid == DIALOG_MARRIAGE)
	{
		if(response)
		{
			SetPVarInt(playerid, "marriagelastname", 1);
			SendClientMessageEx(playerid, -1, "Ban da chon giu ho cua minh.");
		}
		else
		{
			SetPVarInt(playerid, "marriagelastname", 2);
			SendClientMessageEx(playerid, -1, "Ban da chon lay ho ban doi.");
		}
	}
	if(dialogid == FLAG_TRANSFER)
	{
		if(response)
		{
			GetPVarString(playerid, "FlagText", string, sizeof(string));
			DeleteFlag(GetPVarInt(playerid, "Flag_Transfer_ID"), playerid);
			format(string, sizeof(string), "%s [Transfered from: %s]", string, GetPlayerNameEx(GetPVarInt(playerid, "Flag_Transfer_From")));
			AddFlag(GetPVarInt(playerid, "Flag_Transfer_To"), playerid, string);
			SendClientMessageEx(playerid, -1, "Da chuyen FlagID: %d Den: %s Tu: %s", GetPVarInt(playerid, "Flag_Transfer_ID"), GetPlayerNameEx(GetPVarInt(playerid, "Flag_Transfer_To")), GetPlayerNameEx(GetPVarInt(playerid, "Flag_Transfer_From")));
			format(string, sizeof(string), "[TRANSFER] %s has transferred FlagID: %d To: %s(%d) From: %s(%d)", GetPlayerNameEx(playerid), GetPVarInt(playerid, "Flag_Transfer_ID"), GetPlayerNameEx(GetPVarInt(playerid, "Flag_Transfer_To")), GetPlayerSQLId(GetPVarInt(playerid, "Flag_Transfer_To")), GetPlayerNameEx(GetPVarInt(playerid, "Flag_Transfer_From")), GetPlayerSQLId(GetPVarInt(playerid, "Flag_Transfer_From")));
			Log("logs/flags.log", string);
			DeletePVar(playerid, "Flag_Transfer_ID");
			DeletePVar(playerid, "Flag_Transfer_To");
			DeletePVar(playerid, "Flag_Transfer_From");
			DeletePVar(playerid, "FlagText");
		}
		else
		{
			DeletePVar(playerid, "Flag_Transfer_ID");
			DeletePVar(playerid, "Flag_Transfer_To");
			DeletePVar(playerid, "Flag_Transfer_From");
			DeletePVar(playerid, "FlagText");
			SendClientMessageEx(playerid, -1, "Ban da huy chuyen flag!");
		}
	}
	if(dialogid == DIALOG_SETEXAMINE)
	{
		if(response)
		{
			if(isnull(inputtext)) return ShowPlayerDialogEx(playerid, DIALOG_SETEXAMINE, DIALOG_STYLE_INPUT, "Mo ta ngoai hinh", "Nhap mo ta ve ban.\nVi du: nam da trang, cao 6' 3 ..v.v.", "Dat", "Huy");
			format(PlayerInfo[playerid][pExamineDesc], 128, "%s", inputtext);
		}
		else
		{
			SendClientMessageEx(playerid, -1, "Ban da huy dat mo ta ngoai hinh.");
		}
	}
	if(dialogid == DIALOG_HOLSTER && response)
	{
		if(listitem == 0)
		{
			GameTextForPlayer(playerid, "cat vu khi", 1000, 6);
		}
		else
		{
			GameTextForPlayer(playerid, "rut vu khi", 1000, 6);
		}

		SetTimerEx("UnholsterWeapon", 1000, false, "ii", playerid, listitem);
	}
	if((dialogid == DIALOG_MICROSHOP || dialogid == DIALOG_MICROSHOP2 || dialogid == DIALOG_MICROSHOP3 || dialogid == DIALOG_MICROPHONE) &&
		(!gPlayerLogged{playerid} || !GetPVarInt(playerid, "PinConfirmed"))) return 1;
	if(dialogid == DIALOG_MICROSHOP)
	{
		if(response)
		{
			new microItemName2[36], microItemName3[36], microItemName4[36];
			new stringg[768];
			if(listitem == 0)
			{
				strunpack(microItemName, mItemName[0], sizeof(microItemName));
				strunpack(microItemName2, mItemName[1], sizeof(microItemName2));
				format(stringg, sizeof(stringg), "%s (Credits: {FFD700}%s{FFFFFF})\n%s (Credits: {FFD700}%s{FFFFFF})\nDouble EXP Tokens (Credits: {FFD700}%s{FFFFFF})", microItemName, number_format(MicroItems[0]), microItemName2, number_format(MicroItems[1]), number_format(ShopItems[9][sItemPrice]));
				ShowPlayerDialogEx(playerid, DIALOG_MICROSHOP2, DIALOG_STYLE_LIST, "Microtransaction Shop - Cong viec & Kinh nghiem", stringg, "Chon", "Thoat");
			}
			if(listitem == 1)
			{
				strunpack(microItemName, mItemName[2], sizeof(microItemName));
				strunpack(microItemName2, mItemName[3], sizeof(microItemName2));
				format(stringg, sizeof(stringg), "%s (Credits: {FFD700}%s{FFFFFF})\n%s (Credits: {FFD700}%s{FFFFFF})", microItemName, number_format(MicroItems[2]), microItemName2, number_format(MicroItems[3]));
				ShowPlayerDialogEx(playerid, DIALOG_MICROSHOP2, DIALOG_STYLE_LIST, "Microtransaction Shop - VIP", stringg, "Chon", "Thoat");
			}
			if(listitem == 2)
			{
				strunpack(microItemName, mItemName[4], sizeof(microItemName));
				format(stringg, sizeof(stringg), "%s (Credits: {FFD700}%s{FFFFFF})", microItemName, number_format(MicroItems[4]));
				ShowPlayerDialogEx(playerid, DIALOG_MICROSHOP2, DIALOG_STYLE_LIST, "Microtransaction Shop - Thuc an", stringg, "Chon", "Thoat");
			}
			if(listitem == 3)
			{
				strunpack(microItemName, mItemName[6], sizeof(microItemName));
				format(szMiscArray, sizeof(szMiscArray), "%s (Credits: {FFD700}%s{FFFFFF})\nHouse Move (Credits: {FFD700}%s{FFFFFF})\nHouse Interior Change (Credits: {FFD700}%s{FFFFFF})",
					microItemName, number_format(MicroItems[6]), number_format(ShopItems[16][sItemPrice]), number_format(ShopItems[15][sItemPrice]));

				format(szMiscArray, sizeof(szMiscArray), "%s\nFurniture Slots - Bronze Pack (25 slots) (Credits: {FFD700}%s{FFFFFF})\nFurniture Slots - Silver Pack (40 slots) (Credits: {FFD700}%s{FFFFFF})\n\
					Furniture Slots - Gold Pack (50 slots) (Credits: {FFD700}%s{FFFFFF})", szMiscArray, number_format(ShopItems[41][sItemPrice]), number_format(ShopItems[42][sItemPrice]), number_format(ShopItems[43][sItemPrice]));

				ShowPlayerDialogEx(playerid, DIALOG_MICROSHOP2, DIALOG_STYLE_LIST, "Microtransaction Shop - Nha", szMiscArray, "Chon", "Thoat");
			}
			if(listitem == 4)
			{
				strunpack(microItemName, mItemName[7], sizeof(microItemName));
				strunpack(microItemName2, mItemName[8], sizeof(microItemName2));
				strunpack(microItemName3, mItemName[9], sizeof(microItemName3));
				format(stringg, sizeof(stringg), "%s (Credits: {FFD700}%s{FFFFFF})\n%s (Credits: {FFD700}%s{FFFFFF})\n%s (Credits: {FFD700}%s{FFFFFF})\nDeluxe Car Alarm (Credits: {FFD700}%s{FFFFFF})\nAdditional Vehicle Slots (Credits: {FFD700}%s{FFFFFF})",
				microItemName, number_format(MicroItems[7]), microItemName2, number_format(MicroItems[8]), microItemName3, number_format(MicroItems[9]), number_format(ShopItems[39][sItemPrice]), number_format(ShopItems[23][sItemPrice]));
				ShowPlayerDialogEx(playerid, DIALOG_MICROSHOP2, DIALOG_STYLE_LIST, "Microtransaction Shop - Phuong tien", stringg, "Chon", "Thoat");
			}
			if(listitem == 5)
			{
				new microItemName5[36], microItemName6[36], microItemName7[36];
				strunpack(microItemName, mItemName[10], sizeof(microItemName));
				strunpack(microItemName2, mItemName[12], sizeof(microItemName2));
				strunpack(microItemName3, mItemName[13], sizeof(microItemName3));
				strunpack(microItemName4, mItemName[5], sizeof(microItemName4));
				strunpack(microItemName5, mItemName[14], sizeof(microItemName5));
				strunpack(microItemName6, mItemName[15], sizeof(microItemName6));
				strunpack(microItemName7, mItemName[11], sizeof(microItemName7));
				format(stringg, sizeof(stringg), "%s (Credits: {FFD700}%s{FFFFFF})\n%s (Credits: {FFD700}%s{FFFFFF})\n%s (Credits: {FFD700}%s{FFFFFF})\n%s (Credits: {FFD700}%s{FFFFFF})\
				\nFireworks x5 (Credits: {FFD700}%s{FFFFFF})\n100 Paintball Tokens (Credits: {FFD700}%s{FFFFFF})\nAdditional Toy Slots (Credits: {FFD700}%s{FFFFFF})\n%s (Credits: {FFD700}%s{FFFFFF})\n%s (Credits: {FFD700}%s{FFFFFF})\n%s (Credits: {FFD700}%s{FFFFFF})",
				microItemName, number_format(MicroItems[10]), microItemName2, number_format(MicroItems[12]), microItemName3, number_format(MicroItems[13]), microItemName4, number_format(MicroItems[5]), number_format(ShopItems[10][sItemPrice]),
				number_format(ShopItems[8][sItemPrice]), number_format(ShopItems[28][sItemPrice]), microItemName5, number_format(MicroItems[14]), microItemName6, number_format(MicroItems[15]), microItemName7, number_format(MicroItems[11]));
				ShowPlayerDialogEx(playerid, DIALOG_MICROSHOP2, DIALOG_STYLE_LIST, "Microtransaction Shop - Khac", stringg, "Chon", "Thoat");
			}
			if(listitem == 6)
			{
				if(prezombie || zombieevent)
				{
					strunpack(microItemName, mItemName[16], sizeof(microItemName));
					strunpack(microItemName2, mItemName[17], sizeof(microItemName2));
					strunpack(microItemName3, mItemName[18], sizeof(microItemName3));
					strunpack(microItemName4, mItemName[19], sizeof(microItemName4));
					format(stringg, sizeof(stringg), "%s (Credits: {FFD700}%s{FFFFFF})\n%s (Credits: {FFD700}%s{FFFFFF})\n%s (Credits: {FFD700}%s{FFFFFF})\n%s (Credits: {FFD700}%s{FFFFFF})",
					microItemName, number_format(MicroItems[16]), microItemName2, number_format(MicroItems[17]), microItemName3, number_format(MicroItems[18]), microItemName4, number_format(MicroItems[19]));
					ShowPlayerDialogEx(playerid, DIALOG_MICROSHOP2, DIALOG_STYLE_LIST, "Microtransaction Shop - Su kien", stringg, "Chon", "Thoat");
				}
				if(!strlen(stringg)) ShowPlayerDialogEx(playerid, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, "Microtransaction Shop - Su kien", "Hien khong co vat pham nao de mua!", "Dong y", "");
			}
			SetPVarInt(playerid, "m_listitem", listitem+1);
		}
	}
	if(dialogid == DIALOG_MICROSHOP2)
	{
		if(!response) return pc_cmd_microshop(playerid, "");
		if(response)
		{
			new item = -1;
			switch(GetPVarInt(playerid, "m_listitem")-1)
			{
				case 0://Job & Experience
				{
					if(listitem == 0) item = 0;
					if(listitem == 1) item = 1;
					if(listitem == 2) item = 100;//EXP Token
				}
				case 1://VIP
				{
					if(listitem == 0) item = 2;
					if(listitem == 1) item = 3;
				}
				case 2://Food
				{
					if(listitem == 0) item = 4;
				}
				case 3://House
				{
					if(listitem == 0) item = 6;
					if(listitem == 1) item = 101;//House Move
					if(listitem == 2) item = 102;//House Interior Change
					if(listitem == 3) item = 108;//Furniture Bronze Pack
					if(listitem == 4) item = 109;//Furniture Silver Pack
					if(listitem == 5) item = 110;//Furniture Gold Pack
				}
				case 4://Vehicle
				{
					if(listitem == 0) item = 7;
					if(listitem == 1) item = 8;
					if(listitem == 2) item = 9;
					if(listitem == 3) item = 103;//Deluxe Car Alarm
					if(listitem == 4) item = 104;//Additional Vehicle Slot
				}
				case 5://Misc
				{
					if(listitem == 0) item = 10;
					if(listitem == 1) item = 12;
					if(listitem == 2) item = 13;
					if(listitem == 3) item = 5;
					if(listitem == 4) item = 105;//Fireworks x5
					if(listitem == 5) item = 106;//100 Paintball Tokens
					if(listitem == 6) item = 107;//Additional Toy Slot
					if(listitem == 7) item = 14;
					if(listitem == 8) item = 15;
					if(listitem == 9) item = 11;
				}
				case 6://Event
				{
					if(listitem == 0) item = 16;
					if(listitem == 1) item = 17;
					if(listitem == 2) item = 18;
					if(listitem == 3) item = 19;
				}
			}
			if(item == -1) return 1;
			if(item == 100)//EXP Token
			{
				SetPVarInt(playerid, "MiscShop", 4);
				format(string, sizeof(string), "Vat pham: Double EXP Token\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[9][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[9][sItemPrice]));
				return ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Micro Shop", string, "Mua", "Huy");
			}
			if(item == 101)//House Move
			{
				format(string, sizeof(string),"Vat pham: House Move\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[16][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[16][sItemPrice]));
				return ShowPlayerDialogEx(playerid, DIALOG_HOUSESHOP4, DIALOG_STYLE_MSGBOX, "Micro Shop", string, "Mua", "Huy");
			}
			if(item == 102)//House Interior Change
			{
				format(string, sizeof(string),"Vat pham: House Interior Change\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[15][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[15][sItemPrice]));
				return ShowPlayerDialogEx(playerid, DIALOG_HOUSESHOP3, DIALOG_STYLE_MSGBOX, "Micro Shop", string, "Mua", "Huy");
			}
			if(item == 103)//Deluxe Car Alarm
			{
				SetPVarInt(playerid, "MiscShop", 18);
				format(string, sizeof(string), "Vat pham: Deluxe Car Alarm\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[39][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[39][sItemPrice]));
				return ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Micro Shop", string, "Mua", "Huy");
			}
			if(item == 104)//Additional Vehicle Slot
			{
				SetPVarInt(playerid, "MiscShop", 7);
				format(string, sizeof(string), "Vat pham: Additional Vehicle Slot\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[23][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[23][sItemPrice]));
				return ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Micro Shop", string, "Mua", "Huy");
			}
			if(item == 105)//Fireworks x5
			{
				SetPVarInt(playerid, "MiscShop", 5);
				format(string, sizeof(string), "Vat pham: Fireworks x5\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[10][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[10][sItemPrice]));
				return ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Micro Shop", string, "Mua", "Huy");
			}
			if(item == 106)//100 Paintball Tokens
			{
				SetPVarInt(playerid, "MiscShop", 3);
				format(string, sizeof(string), "Vat pham: 100 Paintball Tokens\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[8][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[8][sItemPrice]));
				return ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Micro Shop", string, "Mua", "Huy");
			}
			if(item == 107)//Additional Toy Slot
			{
				SetPVarInt(playerid, "MiscShop", 8);
				format(string, sizeof(string), "Additional Toy Slot\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[28][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[28][sItemPrice]));
				return ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Micro Shop", string, "Mua", "Huy");
			}
			if(item == 108)//Furniture Bronze
			{
				SetPVarInt(playerid, "MiscShop", 19);
				format(string, sizeof(string), "Furniture Pack - Bronze (25 slots)\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[41][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[41][sItemPrice]));
				return ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Micro Shop", string, "Mua", "Huy");
			}
			if(item == 109)//Furniture Silver
			{
				SetPVarInt(playerid, "MiscShop", 20);
				format(string, sizeof(string), "Furniture Pack - Silver (40 slots)\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[42][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[42][sItemPrice]));
				return ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Micro Shop", string, "Mua", "Huy");
			}
			if(item == 110)//Furniture Gold
			{
				SetPVarInt(playerid, "MiscShop", 21);
				format(string, sizeof(string), "Furniture Pack - Bronze (50 slots)\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", number_format(PlayerInfo[playerid][pCredits]), number_format(ShopItems[43][sItemPrice]), number_format(PlayerInfo[playerid][pCredits]-ShopItems[43][sItemPrice]));
				return ShowPlayerDialogEx(playerid, DIALOG_MISCSHOP2, DIALOG_STYLE_MSGBOX, "Micro Shop", string, "Mua", "Huy");
			}
			SetPVarInt(playerid, "m_Item", item);
			if(item == 11)
			{
				if(PlayerInfo[playerid][pPnumber] == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai co dien thoai truoc khi doi so.");
				return ShowPlayerDialogEx(playerid, DIALOG_MICROPHONE, DIALOG_STYLE_INPUT, "Micro Shop - Doi so", "Nhap so dien thoai moi sau chu so (100000-999999). Chi tru credits khi xac nhan mua.", "Tiep tuc", "Huy");
			}
			if(item == 0)//Change a Job
			{
				if(gettime() < PlayerInfo[playerid][mCooldown][item])
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da mua vat pham nay 3 lan trong 24 gio qua, hay cho %s de mua lai.", ConvertTimeS(PlayerInfo[playerid][mCooldown][item]-gettime()));
					return pc_cmd_microshop(playerid, "");
				}
				PlayerInfo[playerid][mCooldown][item] = 0;
				return Job_ShowMenu(playerid, true);
			}
			if(item == 1)//Job Boost
			{
				if(PlayerInfo[playerid][mPurchaseCount][item])
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Job Boost dang hoat dong, hay cho het han sau %d phut de mua lai.", PlayerInfo[playerid][mCooldown][item]);
					return pc_cmd_microshop(playerid, "");
				}
				return Job_ShowMenu(playerid, true, true);
			}
			if(item == 2)//Buddy Invites Reset
			{
				if(PlayerInfo[playerid][pDonateRank] < 2) return SendClientMessageEx(playerid, COLOR_GRAD2, "Can Silver VIP+ de mua vat pham nay.");
				if(PlayerInfo[playerid][pBuddyInvites]) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban dang co Buddy Invites, hay dung het truoc khi mua vat pham nay.");
				if(gettime() < PlayerInfo[playerid][mCooldown][item])
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da mua vat pham nay trong 24 gio qua, hay cho %s de mua lai.", ConvertTimeS(PlayerInfo[playerid][mCooldown][item]-gettime()));
					return pc_cmd_microshop(playerid, "");
				}
				PlayerInfo[playerid][mCooldown][item] = 0;
			}
			if(item == 3)//Buddy Invite Extension
			{
				if(!PlayerInfo[playerid][pBuddyInvited]) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban phai dang dung Buddy Invite de mua vat pham nay.");
				if(gettime() < PlayerInfo[playerid][mCooldown][item])
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da mua vat pham nay 3 lan trong 24 gio qua, hay cho %s de mua lai.", ConvertTimeS(PlayerInfo[playerid][mCooldown][item]-gettime()));
					return pc_cmd_microshop(playerid, "");
				}
				PlayerInfo[playerid][mCooldown][item] = 0;
			}
			if(item == 4)//Energy Bars
			{
				if(1 <= PlayerInfo[playerid][mInventory][4] <= 4)
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Ban dang cam %d Energy Bars, moi lan ban 4 thanh va day cung la gioi han cam tren tay.", PlayerInfo[playerid][mInventory][4]);
					if(!PlayerInfo[playerid][pBackpack]) SendClientMessageEx(playerid, COLOR_GRAD2, "De mang them, mua ba lo bang /miscshop");
					else SendClientMessageEx(playerid, COLOR_GRAD2, "Ban co ba lo, hay cat Energy Bars dang mang roi thu lai.");
					return 1;
				}
			}
			if(item == 6 && PlayerInfo[playerid][mInventory][item]) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban dang co House Sale Sign trong tui, hay dung truoc khi mua them.");  //House Sale Sign
			if(item == 10)//Priority Ads
			{
				if(gettime() < PlayerInfo[playerid][mCooldown][item])
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da mua vat pham nay 2 lan trong 24 gio qua, hay cho %s de mua lai.", ConvertTimeS(PlayerInfo[playerid][mCooldown][item]-gettime()));
					return pc_cmd_microshop(playerid, "");
				}
				PlayerInfo[playerid][mCooldown][item] = 0;
			}
			if(item == 12)//Quick Bank Access
			{
				if(PlayerInfo[playerid][mPurchaseCount][item])
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Quick Bank Access dang co hieu luc, hay cho het han sau %d phut de mua lai.", PlayerInfo[playerid][mCooldown][item]);
					return pc_cmd_microshop(playerid, "");
				}
			}
			if(item == 13)//Restricted Skin
			{
				if(gettime() < PlayerInfo[playerid][mCooldown][item])
				{
					SendClientMessageEx(playerid, COLOR_GRAD2, "Ban da mua vat pham nay 3 lan trong 24 gio qua, hay cho %s de mua lai.", ConvertTimeS(PlayerInfo[playerid][mCooldown][item]-gettime()));
					return pc_cmd_microshop(playerid, "");
				}
				PlayerInfo[playerid][mCooldown][item] = 0;
			}
			strunpack(microItemName, mItemName[item], sizeof(microItemName));
			format(string, sizeof(string), "Vat pham: %s\nCredits: %s\nGia: {FFD700}%s{A9C4E4}\nCon lai: %s", microItemName, number_format(PlayerInfo[playerid][pCredits]), number_format(MicroItems[item]), number_format(PlayerInfo[playerid][pCredits]-MicroItems[item]));
			ShowPlayerDialogEx(playerid, DIALOG_MICROSHOP3, DIALOG_STYLE_MSGBOX, "Micro Shop", string, "Mua", "Huy");
		}
	}
	if(dialogid == DIALOG_MICROPHONE)
	{
		if(!response) return pc_cmd_microshop(playerid, "");
		if(!GetPVarType(playerid, "m_Item") || GetPVarInt(playerid, "m_Item") != 11) return 1;
		if(strlen(inputtext) != 6 || !IsNumericString(inputtext) || !(100000 <= strval(inputtext) <= 999999))
			return ShowPlayerDialogEx(playerid, DIALOG_MICROPHONE, DIALOG_STYLE_INPUT, "Micro Shop - Doi so", "Nhap dung sau chu so, tu 100000 den 999999.", "Tiep tuc", "Huy");
		new number = strval(inputtext), price = MicroItems[11];
		if(number == PlayerInfo[playerid][pPnumber]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban da dung so dien thoai do.");
		if(price <= 0 || PlayerInfo[playerid][pCredits] < price) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien de mua.");
		SetPVarInt(playerid, "m_PhoneNumber", number);
		SetPVarInt(playerid, "m_PhonePrice", price);
		SetPVarInt(playerid, "m_PhoneOld", PlayerInfo[playerid][pPnumber]);
		format(string, sizeof(string), "Doi so: %d -> %d\nCredits: %s\nGia: %s\nCon lai: %s", PlayerInfo[playerid][pPnumber], number, number_format(PlayerInfo[playerid][pCredits]), number_format(price), number_format(PlayerInfo[playerid][pCredits] - price));
		return ShowPlayerDialogEx(playerid, DIALOG_MICROSHOP3, DIALOG_STYLE_MSGBOX, "Micro Shop - Doi so", string, "Mua", "Huy");
	}
	if(dialogid == DIALOG_MICROSHOP3)
	{
		if(!response) return pc_cmd_microshop(playerid, "");
		if(response)
		{
			if(!GetPVarType(playerid, "m_Item")) return 1;
			new item = GetPVarInt(playerid, "m_Item");
			if(!(0 <= item < MAX_MICROITEMS) || MicroItems[item] <= 0 || AmountSoldMicro[item] < 0 || AmountSoldMicro[item] == cellmax ||
				AmountMadeMicro[item] < 0 || AmountMadeMicro[item] > cellmax - MicroItems[item]) return 1;
			if(PlayerInfo[playerid][pCredits] < MicroItems[item]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du credits de mua vat pham nay. Vao shop.ng-gaming.net de mua credits.");

			if(item == 0)
			{
				new slot = GetPVarInt(playerid, "m_Response") + 1, job = GetPVarInt(playerid, "jobSelection");
				if(!GetPVarType(playerid, "m_Response") || !GetPVarType(playerid, "jobSelection")
					|| !Job_CanSetSlot(playerid, slot, job) || job == JOB_NONE || Job_GetSlot(playerid, slot) == job)
					return SendClientMessageEx(playerid, COLOR_GREY, "Doi cong viec khong con kha dung. Chua tru credits.");
			}
			if(item == 1)
			{
				new job = GetPVarInt(playerid, "jobSelection");
				if(!Job_IsAvailable(job) || !JobDefinitions[job][jobBoostable] || PlayerInfo[playerid][mPurchaseCount][1] || GetJobLevel(playerid, job) == 5)
					return SendClientMessageEx(playerid, COLOR_GREY, "Job Boost khong con kha dung. Chua tru credits.");
			}
			DeletePVar(playerid, "m_Item");
			if(item == 11)
			{
				new number = GetPVarInt(playerid, "m_PhoneNumber"), price = GetPVarInt(playerid, "m_PhonePrice"), oldnumber = GetPVarInt(playerid, "m_PhoneOld");
				DeletePVar(playerid, "m_PhoneNumber");
				DeletePVar(playerid, "m_PhonePrice");
				DeletePVar(playerid, "m_PhoneOld");
				if(!Microshop_ChangePhoneNumber(playerid, number, price, oldnumber)) return 1;
			}
			else GivePlayerCredits(playerid, -MicroItems[item], 1);

			AmountSoldMicro[item]++;
			AmountMadeMicro[item] += MicroItems[item];
			new asString[MAX_MICROITEMS * 12], amString[MAX_MICROITEMS * 12];
			for(new m; m < MAX_MICROITEMS; m++)
			{
				format(asString, sizeof(asString), "%s%d", asString, AmountSoldMicro[m]);
				format(amString, sizeof(amString), "%s%d", amString, AmountMadeMicro[m]);
				if(m != MAX_MICROITEMS-1) strcat(asString, "|"), strcat(amString, "|");
			}
			new szQuery[MAX_MICROITEMS * 24 + 160];
			mysql_format(MainPipeline, szQuery, sizeof(szQuery), "UPDATE `sales` SET `TotalSoldMicro` = '%s', `AmountMadeMicro` = '%s' WHERE `Month` > NOW() - INTERVAL 1 MONTH", asString, amString);
			mysql_tquery(MainPipeline, szQuery, "OnQueryFinish", "i", SENDDATA_THREAD);

			printf("MicroPrice%d: %d", item, MicroItems[item]);

			strunpack(microItemName, mItemName[item], sizeof(microItemName));
			format(string, sizeof(string), "[MICROSHOP] [User: %s(%i)] [IP: %s] [Credits: %s] [%s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), number_format(PlayerInfo[playerid][pCredits]), microItemName, number_format(MicroItems[item]));
			Log("logs/micro.log", string), print(string);
			strunpack(microItemName, mItemName[item], sizeof(microItemName));
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da mua \"%s\" gia %s credits.", microItemName, number_format(MicroItems[item]));
			if(item == 0)
			{
				new slot = GetPVarInt(playerid, "m_Response") + 1, job = GetPVarInt(playerid, "jobSelection");
				Job_SetPlayerSlot(playerid, slot, job);
				DeletePVar(playerid, "m_Response");
				DeletePVar(playerid, "jobSelection");
				SendClientMessageEx(playerid, COLOR_YELLOW, "Cong viec trong o %d da doi thanh %s.", slot, GetJobName(job));
				PlayerInfo[playerid][mInventory][item]++;
				if(++PlayerInfo[playerid][mPurchaseCount][item] == 3) PlayerInfo[playerid][mCooldown][item] = gettime()+86400, PlayerInfo[playerid][mPurchaseCount][item] = 0;
			}
			if(item == 1)
			{
				new job = GetPVarInt(playerid, "jobSelection"), skill = Job_GetSkill(job);
				PlayerInfo[playerid][mBoost][0] = job;
				PlayerInfo[playerid][mBoost][1] = PlayerInfo[playerid][JobSkills[skill][jobSkillField]];
				PlayerInfo[playerid][JobSkills[skill][jobSkillField]] = JobSkills[skill][jobSkillThreshold][3];
				PlayerInfo[playerid][mPurchaseCount][item] = 1;
				PlayerInfo[playerid][mCooldown][item] = 120;
				format(string, sizeof(string), "[JOBBOOST] %s(%d) Job: %s (%d) Skill: %d (%d)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetJobName(job), job, PlayerInfo[playerid][mBoost][1], GetJobLevel(playerid, job));
				Log("logs/micro.log", string);
				SendClientMessageEx(playerid, -1, "Job Boost cho %s co hieu luc %d phut.", GetJobName(job), PlayerInfo[playerid][mCooldown][item]);
				DeletePVar(playerid, "jobSelection");
			}
			if(item == 2)//Buddy Invites Reset
			{
				PlayerInfo[playerid][pVIPInviteDay] = 0;
				PlayerInfo[playerid][pBuddyInvites] += 3;
				PlayerInfo[playerid][mCooldown][item] = gettime()+86400;
			}
			if(item == 3)//Buddy Invite Extension
			{
				PlayerInfo[playerid][pTempVIP] += 180;
				if(++PlayerInfo[playerid][mPurchaseCount][item] == 3) PlayerInfo[playerid][mCooldown][item] = gettime()+86400, PlayerInfo[playerid][mPurchaseCount][item] = 0;
			}
			if(item == 4)//Energy Bars
			{
				PlayerInfo[playerid][mInventory][item] += 4;
				SendClientMessageEx(playerid, -1, "Dung /eatbar de an Energy Bar");
			}
			if(item == 5)//Gift Reset Voucher
			{
				PlayerInfo[playerid][pGiftVoucher]++;
				SendClientMessageEx(playerid, -1, "Dung /myvouchers de xem phieu dat lai thoi gian qua.");
			}
			if(item == 6)//House Sale Sign
			{
				PlayerInfo[playerid][mInventory][item] = 1;
				SendClientMessageEx(playerid, -1, "Dung /placesign de dat bien, dung /editsign de sua bien");
			}
			if(item == 7)//Fuel Canister
			{
				PlayerInfo[playerid][mInventory][item]++;
				SendClientMessageEx(playerid, -1, "Den gan xe va dung /fuelcan de dung binh nhien lieu");
			}
			if(item == 8)//Jump Start
			{
				PlayerInfo[playerid][mInventory][item]++;
				SendClientMessageEx(playerid, -1, "Dung /jumpstart de kich no xe");
			}
			if(item == 9) //Restricted Car Colors
			{
				PlayerInfo[playerid][mInventory][item]++;
				SendClientMessageEx(playerid, -1, "Dung /rcarcolor de son xe bang mau gioi han");
			}
			if(item == 10)//Priority Ads
			{
				PlayerInfo[playerid][pAdvertVoucher] += 3;
				if(++PlayerInfo[playerid][mPurchaseCount][item] == 2) PlayerInfo[playerid][mCooldown][item] = gettime()+86400;
				SendClientMessageEx(playerid, -1, "Da them 3 phieu Advertisement vao tai khoan cua ban.");
			}
			if(item == 12)//Quick Bank Access
			{
				PlayerInfo[playerid][mPurchaseCount][item] = 1;
				PlayerInfo[playerid][mCooldown][item] = 15;
				SendClientMessageEx(playerid, -1, "Ban co the dung /balance /withdraw /deposit /wiretransfer o moi noi trong 15 phut.");
			}
			if(item == 13)//Restricted Skin
			{
				PlayerInfo[playerid][mInventory][item]++;
				if(++PlayerInfo[playerid][mPurchaseCount][item] == 3) PlayerInfo[playerid][mCooldown][item] = gettime()+86400;
				SendClientMessageEx(playerid, -1, "Den cua hang quan ao va chon skin gioi han.");
			}
			if(item == 14) AddFlag(playerid, INVALID_PLAYER_ID, "Dynamic Door Move (Credits)"), SendReportToQue(playerid, "Dynamic Door Move (Credits)", 2, 2), SendClientMessageEx(playerid, COLOR_CYAN, "Hay lien he senior admin de duoc cap Dynamic Door Move.");
			if(item == 15) AddFlag(playerid, INVALID_PLAYER_ID, "Dynamic Door Interior Change (Credits)"), SendReportToQue(playerid, "Dynamic Door Interior Change (Credits)", 2, 2), SendClientMessageEx(playerid, COLOR_CYAN, "Hay lien he senior admin de duoc cap Dynamic Door Interior Change.");
			if(item == 16)
			{
				SendClientMessageEx(playerid, -1, "Dung /zscrapmetal de tang do ben xe them 500 HP!");
				PlayerInfo[playerid][mInventory][item]++;
			}
			if(item == 17)
			{
				SendClientMessageEx(playerid, -1, "Dung /z50cal de su dung dan .50 caliber. Dung lai lenh de bat/tat dan .50 caliber. Chi dung cho Rifles & Sniper Rifles");
				PlayerInfo[playerid][mInventory][item] += 15;
			}
			if(item == 18)
			{
				SendClientMessageEx(playerid, -1, "Dung /zinject de su dung thuoc khang sinh.");
				PlayerInfo[playerid][mPurchaseCount][item] += 3;
			}
			if(item == 19)
			{
				SendClientMessageEx(playerid, -1, "Dung /zopenkit de mo kit va xem loai Survivor kit ban nhan duoc.");
				PlayerInfo[playerid][mInventory][item]++;
			}
			DeletePVar(playerid, "m_listitem");
			DeletePVar(playerid, "m_Item");
			DeletePVar(playerid, "m_Response");
		}
	}
	if(dialogid == DIALOG_EDITMICROSHOP)
	{
		if(response)
		{
			if(!GetPVarType(playerid, "mEditingPrice"))
			{
				SetPVarInt(playerid, "mEditingPrice", listitem);
				strunpack(microItemName, mItemName[listitem], sizeof(microItemName));
				format(string, sizeof(string), "Ban dang doi gia %s. Gia hien tai la %s credits.", microItemName, number_format(MicroItems[listitem]));
				return ShowPlayerDialogEx(playerid, DIALOG_EDITMICROSHOP, DIALOG_STYLE_INPUT, "Doi gia", string, "Doi", "Quay lai");
			}
			else
			{
				if(!GetPVarType(playerid, "mEditingPriceValue"))
				{
					new price;
					if(sscanf(inputtext, "d", price) || price <= 0)
					{
						strunpack(microItemName, mItemName[GetPVarInt(playerid, "mEditingPrice")], sizeof(microItemName));
						format(string, sizeof(string), "Gia khong duoc duoi 1.\n\nBan dang doi gia %s. Gia hien tai la %s credits.", microItemName, number_format(MicroItems[GetPVarInt(playerid, "mEditingPrice")]));
						return ShowPlayerDialogEx(playerid, DIALOG_EDITMICROSHOP, DIALOG_STYLE_INPUT, "Doi gia - Loi", string, "Doi", "Quay lai");
					}
					else
					{
						SetPVarInt(playerid, "mEditingPriceValue", price);
						strunpack(microItemName, mItemName[GetPVarInt(playerid, "mEditingPrice")], sizeof(microItemName));
						format(string,sizeof(string),"Ban chac chan muon doi gia %s?\n\nGia cu: %s\nGia moi: %s", microItemName, number_format(MicroItems[GetPVarInt(playerid, "mEditingPrice")]), number_format(price));
						return ShowPlayerDialogEx(playerid, DIALOG_EDITMICROSHOP, DIALOG_STYLE_MSGBOX, "Confirmation", string, "Xac nhan", "Huy");
					}
				}
				else
				{
					if(GetPVarInt(playerid, "mEditingPriceValue") == 0) SetPVarInt(playerid, "mEditingPriceValue", 999999);
					MicroItems[GetPVarInt(playerid, "mEditingPrice")] = GetPVarInt(playerid, "mEditingPriceValue");
					strunpack(microItemName, mItemName[GetPVarInt(playerid, "mEditingPrice")], sizeof(microItemName));
					SendClientMessageEx(playerid, COLOR_WHITE, "Ban da doi gia %s thanh %s.", microItemName, number_format(GetPVarInt(playerid, "mEditingPriceValue")));
					format(string, sizeof(string), "[EDITMICROSHOPPRICES] [User: %s(%i)] [IP: %s] [%s] [Price: %s]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), microItemName, number_format(MicroItems[GetPVarInt(playerid, "mEditingPrice")]));
					Log("logs/editshop.log", string), print(string);
					g_mysql_SavePrices();
					DeletePVar(playerid, "mEditingPrice");
					DeletePVar(playerid, "mEditingPriceValue");
				}
			}
		}
		else
		{
			if(GetPVarType(playerid, "mEditingPriceValue")) SendClientMessageEx(playerid, COLOR_GREY, "Ban da huy doi gia.");
			DeletePVar(playerid, "mEditingPrice");
			DeletePVar(playerid, "mEditingPriceValue");
		}
	}
	if(dialogid == DIALOG_WEPVEHSALE)
	{
		if(response)
		{
			new alarmstring[9], lockstring[11], worklockstring[10];
			new giveplayerid = GetPVarInt(playerid, "WepVehSalePlayer");
			new price = GetPVarInt(playerid, "WepVehSalePrice");
			new d = GetPVarInt(playerid, "WepVehSaleVehicle");
			new fine = GetPVarInt(playerid, "WepVehSaleFine");
            if(!GetPVarType(playerid, "WepVehSalePlayer") || !Offer_IsCurrent(playerid, giveplayerid, "WepVehSaleSession")
                || !(0 <= d < MAX_PLAYERVEHICLES)) return SendClientMessageEx(playerid, COLOR_GREY, "De nghi ban xe da het han.");
            if(PlayerVehicleInfo[playerid][d][pvSlotId] != GetPVarInt(playerid, "WepVehSaleSQLId")
                || !IsPlayerInVehicle(playerid, PlayerVehicleInfo[playerid][d][pvId])) return SendClientMessageEx(playerid, COLOR_GREY, "Xe duoc chao ban da thay doi.");

			SetPVarInt(playerid, "LastTransaction", gettime());
            VehicleOffer[giveplayerid] = playerid;
            SetPVarInt(giveplayerid, "VehicleOfferSession", g_arrQueryHandle[playerid]);
            SetPVarInt(giveplayerid, "VehicleOfferSQLId", PlayerVehicleInfo[playerid][d][pvSlotId]);
            VehicleId[giveplayerid] = d;
            VehiclePrice[giveplayerid] = price;

			switch(PlayerVehicleInfo[playerid][d][pvAlarm]) {
				case 1: alarmstring = "Standard";
				case 2: alarmstring = "Deluxe";
				default: alarmstring = "khong";
			}
			switch(PlayerVehicleInfo[playerid][d][pvLock]) {
				case 2: lockstring = "Electronic";
				case 3: lockstring = "Industrial";
				default: lockstring = "khong";
			}

			if(PlayerVehicleInfo[playerid][d][pvLocksLeft] < 1) worklockstring = "(Hong)";
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* [WEPVEHICLE] Ban chao ban cho %s xe %s nay voi bao dong %s & khoa %s%s gia $%s va tien phat %s.", GetPlayerNameEx(giveplayerid), GetVehicleName(PlayerVehicleInfo[playerid][d][pvId]), alarmstring, worklockstring, lockstring, number_format(price), number_format(fine));
			SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* [WEPVEHICLE] %s chao ban xe %s (VID: %d) voi bao dong %s & khoa %s%s gia $%s, (go /accept car) de mua.", GetPlayerNameEx(playerid), GetVehicleName(PlayerVehicleInfo[playerid][d][pvId]), PlayerVehicleInfo[playerid][d][pvId], alarmstring, worklockstring, lockstring, number_format(price));
			DeletePVar(playerid, "confirmvehsell");
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Ban da huy ban xe vu trang. Ban se khong bi phat.");
			DeletePVar(playerid, "WepVehSalePlayer");
			DeletePVar(playerid, "WepVehSaleVehicle");
			DeletePVar(playerid, "WepVehSalePrice");
			DeletePVar(playerid, "WepVehSaleFine");
		}
	}
	if(dialogid == DIALOG_REPORT_HSIGN)
	{
		new Player = GetPVarInt(playerid, "hSignTextChange");
		if(!GetPVarType(Player, "hSignRequest")) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong co yeu cau doi ten!");
		if(response)
		{
			new desc[64], escapeDesc[66];
			GetPVarString(Player, "hSignRequestText", desc, 64);
			mysql_escape_string(desc, escapeDesc);
			format(HouseInfo[GetPVarInt(Player, "hSignRequest")][hSignDesc], 64, "%s", escapeDesc);
			SaveHouse(GetPVarInt(Player, "hSignRequest"));
			SendClientMessageEx(Player, COLOR_YELLOW, "Da duyet noi dung bien ban nha cua ban.");
			SendClientMessageEx(playerid, COLOR_YELLOW, " Da duyet yeu cau doi noi dung bien ban nha cua %s tai Nha ID: %d", GetPlayerNameEx(Player), GetPVarInt(Player, "hSignRequest"));
			format(string, sizeof(string), "%s changed House ID: %d sale sign text to \"%s\", owned by: %s(%d)", GetPlayerNameEx(playerid), GetPVarInt(Player, "hSignRequest"), desc, GetPlayerNameEx(Player), GetPlayerSQLId(Player));
			Log("logs/house.log", string);
			format(string, sizeof(string), "%s da duyet doi noi dung bien ban nha cua %s tai Nha ID: %d", GetPlayerNameEx(playerid), GetPlayerNameEx(Player), GetPVarInt(Player, "hSignRequest"));
			ABroadCast(COLOR_YELLOW, string, 2);
		}
		else
		{
			SendClientMessageEx(Player, COLOR_YELLOW, "Yeu cau doi noi dung bien ban nha cua ban da bi tu choi.");
			SendClientMessageEx(playerid,COLOR_YELLOW," Da tu choi yeu cau doi noi dung bien ban nha cua %s.", GetPlayerNameEx(Player));
			format(string, sizeof(string), "%s da tu choi yeu cau doi noi dung bien ban nha cua %s", GetPlayerNameEx(playerid), GetPlayerNameEx(Player));
			ABroadCast(COLOR_YELLOW, string, 2);
		}
		DeletePVar(Player, "hSignRequest");
		DeletePVar(Player, "hSignTextChange");
	}
	if(dialogid == DIALOG_ENERGYBARS)
	{
		if(response)
		{
			if(!IsBackpackAvailable(playerid)) {
				DeletePVar(playerid, "BackpackOpen"), DeletePVar(playerid, "BackpackProt"), SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the dung ba lo luc nay.");
				return 1;
			}
			if(!GetPVarType(playerid, "bnwd"))
			{
				SetPVarInt(playerid, "bnwd", listitem);
				return ShowBackpackMenu(playerid, DIALOG_ENERGYBARS*2, "");
			}
			new str[148];
			if(GetPVarInt(playerid, "bnwd"))//Deposit
			{
				new amount, maxbars;
				switch(PlayerInfo[playerid][pBackpack])
				{
					case 1: maxbars = 8;
					case 2: maxbars = 12;
					case 3: maxbars = 16;
				}
				if(sscanf(inputtext, "d", amount)) return ShowBackpackMenu(playerid, DIALOG_ENERGYBARS*2, "{B20400}Du lieu sai{A9C4E4}");
				if(amount < 1) return ShowBackpackMenu(playerid, DIALOG_ENERGYBARS*2, "{B20400}Du lieu sai{A9C4E4}\nSo luong phai tu 1 tro len");
				if(amount > maxbars-PlayerInfo[playerid][pBItems][11])
				{
					format(str, sizeof(str), "{B20400}Du lieu sai, chi chua duoc %d Energy Bars{A9C4E4}\nCon cho chua {FFF600}%d{A9C4E4} Energy Bars", maxbars, maxbars-PlayerInfo[playerid][pBItems][11]);
					return ShowBackpackMenu(playerid, DIALOG_ENERGYBARS*2, str);
				}
				if(PlayerInfo[playerid][mInventory][4] >= amount) PlayerInfo[playerid][mInventory][4] -= amount;
				else return ShowBackpackMenu(playerid, DIALOG_ENERGYBARS*2, "{B20400}Du lieu sai{A9C4E4}\nBan khong co du Energy Bars");
				PlayerInfo[playerid][pBItems][11] += amount;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da cat %d Energy Bars vao ba lo.", amount);
				format(string, sizeof(string), "[EBARS] %s(%d) (IP:%s) deposited %d energy bars (%d bars Total) [BACKPACK %d]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), amount, PlayerInfo[playerid][pBItems][11], PlayerInfo[playerid][pBackpack]);
				Log("logs/backpack.log", string);
			}
			else//Withdraw
			{
				new amount;
				if(sscanf(inputtext, "d", amount)) return ShowBackpackMenu(playerid, DIALOG_ENERGYBARS*2, "{B20400}Du lieu sai{A9C4E4}");
				if(amount < 1) return ShowBackpackMenu(playerid, DIALOG_ENERGYBARS*2, "{B20400}Du lieu sai{A9C4E4}\nSo luong phai tu 1 tro len");
				if(amount > PlayerInfo[playerid][pBItems][11])
				{
					format(str, sizeof(str), "{B20400}Du lieu sai, chi co %d Energy Bars{A9C4E4}\nDang rut {FFF600}%d{A9C4E4} Energy Bars", PlayerInfo[playerid][pBItems][11], amount);
					return ShowBackpackMenu(playerid, DIALOG_ENERGYBARS*2, str);
				}
				PlayerInfo[playerid][pBItems][11] -= amount;
				PlayerInfo[playerid][mInventory][4] += amount;
				SendClientMessageEx(playerid, COLOR_WHITE, "Da lay %d Energy Bars tu ba lo.", amount);
				format(string, sizeof(string), "[EBARS] %s(%d) (IP:%s) withdrawn %d energy bars (%d bars Total) [BACKPACK %d]", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), amount, PlayerInfo[playerid][pBItems][11], PlayerInfo[playerid][pBackpack]);
				Log("logs/backpack.log", string);
			}
			ShowBackpackMenu(playerid, DIALOG_ENERGYBARS, "- {02B0F5}Energy Bars");
		}
		else
		{
			if(GetPVarType(playerid, "bnwd")) ShowBackpackMenu(playerid, DIALOG_ENERGYBARS, "- {02B0F5}Energy Bars");
			else ShowBackpackMenu(playerid, DIALOG_OBACKPACK, "");
		}
	}
	if(dialogid == DIALOG_MANAGECREDITS)
	{
		if(!response) return 1;
		SetPVarInt(playerid, "ManageCreditsDiag", listitem);
		switch(listitem) {
			case 0: {
				if(SellClosed)
					ShowPlayerDialogEx(playerid, DIALOG_MANAGECREDITS2, DIALOG_STYLE_MSGBOX, "Ban Credits", "Ban muon BAT ban credits?", "Dong y", "Huy");
				else
					ShowPlayerDialogEx(playerid, DIALOG_MANAGECREDITS2, DIALOG_STYLE_MSGBOX, "Ban Credits", "Ban muon TAT ban credits?", "Dong y", "Huy");
			}
			case 1: {
				if(!freeweekend)
					ShowPlayerDialogEx(playerid, DIALOG_MANAGECREDITS2, DIALOG_STYLE_MSGBOX, "Ban Credits", "Ban muon BAT Free Weekend?", "Dong y", "Huy");
				else
					ShowPlayerDialogEx(playerid, DIALOG_MANAGECREDITS2, DIALOG_STYLE_MSGBOX, "Ban Credits", "Ban muon TAT Free Weekend?", "Dong y", "Huy");
			}
			case 2: {
				if(!nonvipcredits)
					ShowPlayerDialogEx(playerid, DIALOG_MANAGECREDITS2, DIALOG_STYLE_MSGBOX, "Ban Credits", "Ban muon BAT ban credits cho NON-VIPs?", "Dong y", "Huy");
				else
					ShowPlayerDialogEx(playerid, DIALOG_MANAGECREDITS2, DIALOG_STYLE_MSGBOX, "Ban Credits", "Ban muon TAT ban credits cho NON-VIPs?", "Dong y", "Huy");
			}
		}
	}
	if(dialogid == DIALOG_MANAGECREDITS2)
	{
		if(!response) return 1;
		switch(GetPVarInt(playerid, "ManageCreditsDiag")) {
			case 0: {
				if(!SellClosed) SellClosed = 1, SendClientMessageEx(playerid, COLOR_WHITE, "Da tat ban credits.");
				else SellClosed = 0, SendClientMessageEx(playerid, COLOR_WHITE, "Da bat ban credits.");
			}
			case 1: {
				if(!freeweekend) freeweekend = 1, SendClientMessageEx(playerid, COLOR_WHITE, "Da bat Free Weekend.");
				else freeweekend = 0, SendClientMessageEx(playerid, COLOR_WHITE, "Da tat Free Weekend.");
			}
			case 2: {
				if(!nonvipcredits) nonvipcredits = 1, SendClientMessageEx(playerid, COLOR_WHITE, "Da bat ban credits cho Non-VIP.");
				else nonvipcredits = 0, SendClientMessageEx(playerid, COLOR_WHITE, "Da tat ban credits cho Non-VIP.");
			}
		}
	}
	if(dialogid == DIALOG_MEDIC_LIST) {
		if(response && 0 <= listitem < GetPVarInt(playerid, "EMSListCount") && listitem < sizeof(ListItemTrackId[])) {
			new target = ListItemTrackId[playerid][listitem], key[32], params[12];
			format(key, sizeof(key), "EMSListSession%d", listitem);
			if(!IsPlayerConnected(target) || GetPVarInt(playerid, key) != g_arrQueryHandle[target]) return SendClientMessageEx(playerid, COLOR_GREY, "Cuoc goi khong con kha dung. Hay mo lai /emslist.");
			format(params, sizeof(params), "%d", target);
			Medic_GetPatient(playerid, params);
		}
	}
	return 0;
}
