/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

					Advertisements System

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

#include <YSI_Coding\y_hooks>

stock ShowAdMuteFine(playerid)
{
	new string[128];
	new playername[MAX_PLAYER_NAME];
	GetPlayerName(playerid, playername, sizeof(playername));

	new totalwealth = PlayerInfo[playerid][pAccount] + GetPlayerCash(playerid);
	if(PlayerInfo[playerid][pPhousekey] != INVALID_HOUSE_ID && HouseInfo[PlayerInfo[playerid][pPhousekey]][hOwnerID] == GetPlayerSQLId(playerid)) totalwealth += HouseInfo[PlayerInfo[playerid][pPhousekey]][hSafeMoney];
	if(PlayerInfo[playerid][pPhousekey2] != INVALID_HOUSE_ID && HouseInfo[PlayerInfo[playerid][pPhousekey2]][hOwnerID] == GetPlayerSQLId(playerid)) totalwealth += HouseInfo[PlayerInfo[playerid][pPhousekey2]][hSafeMoney];
	if(PlayerInfo[playerid][pPhousekey3] != INVALID_HOUSE_ID && HouseInfo[PlayerInfo[playerid][pPhousekey3]][hOwnerID] == GetPlayerSQLId(playerid)) totalwealth += HouseInfo[PlayerInfo[playerid][pPhousekey3]][hSafeMoney];

    new fine = 10*totalwealth/100;
	if(PlayerInfo[playerid][pADMuteTotal] < 4)
	{
		format(string,sizeof(string),"Giam %d phut\nPhat tien ($%d)",PlayerInfo[playerid][pADMuteTotal]*15,fine);
	}
	if(PlayerInfo[playerid][pADMuteTotal] == 4)
	{
	    format(string,sizeof(string),"Tu 1 gio");
	}
	if(PlayerInfo[playerid][pADMuteTotal] == 5)
	{
	    format(string,sizeof(string),"Tu 1 gio 15 phut)");
	}
	if(PlayerInfo[playerid][pADMuteTotal] == 6)
	{
	    format(string,sizeof(string),"Tu 1 gio 30 phut");
	}
	ShowPlayerDialogEx(playerid,ADMUTE,DIALOG_STYLE_LIST,"Mo cam quang cao - Chon hinh phat:",string,"Chon","Huy");
}


hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	if(strfind(inputtext, "%", true) != -1)
	{
		SendClientMessage(playerid, COLOR_GREY, "Ky tu khong hop le, hay thu lai.");
		return 1;
	}
	switch(dialogid)
	{
		case DIALOG_ADCATEGORY:
		{
			if(!response) return 1;
			szMiscArray[0] = 0;
			new szBuffer[32],
				arrAdverts[MAX_PLAYERS] = INVALID_PLAYER_ID,
				iDialogCount,
				iCount,
				iBreak,
				iRand;
			for(new x; x < 50; ++x) ListItemTrackId[playerid][x] = -1;
			foreach(new i: Player) if(!isnull(szAdvert[i])) arrAdverts[iCount++] = i;

			while(iDialogCount < 50 && iBreak < 500) {
				iRand = random(iCount);
				if(iCount && arrAdverts[iRand] != INVALID_PLAYER_ID) {
					if(AdvertType[arrAdverts[iRand]] == listitem+1)
					{
						strcpy(szBuffer, szAdvert[arrAdverts[iRand]], sizeof(szBuffer));
						if(PlayerInfo[playerid][pAdmin] <= 1) format(szMiscArray, sizeof(szMiscArray), "%s%s... (%i)\r\n", szMiscArray, szBuffer, PlayerInfo[arrAdverts[iRand]][pPnumber]);
						else format(szMiscArray, sizeof(szMiscArray), "%s%s... (%s)\r\n", szMiscArray, szBuffer, GetPlayerNameEx(arrAdverts[iRand]));
						ListItemTrackId[playerid][iDialogCount++] = arrAdverts[iRand];
						arrAdverts[iRand] = INVALID_PLAYER_ID;
					}
				}
				++iBreak;
			}
			if(!isnull(szMiscArray)) return ShowPlayerDialogEx(playerid, DIALOG_ADLIST, DIALOG_STYLE_LIST, "Danh sach quang cao", szMiscArray, "Chon", "Quay lai");
			ShowPlayerDialogEx(playerid, DIALOG_ADCATEGORY, DIALOG_STYLE_LIST, "Danh muc quang cao", "Bat dong san\nXe co\nCan mua\nCan ban\nKhac", "Chon", "Huy");
			SendClientMessage(playerid, COLOR_GREY, "Chua co quang cao nao.");
		}
		case DIALOG_ADMAIN: if(response) switch(listitem) {
			case 0: ShowPlayerDialogEx(playerid, DIALOG_ADCATEGORY, DIALOG_STYLE_LIST, "Danh muc quang cao", "Bat dong san\nXe co\nCan mua\nCan ban\nKhac", "Chon", "Huy");
			case 1: ShowPlayerDialogEx(playerid, DIALOG_ADSEARCH, DIALOG_STYLE_INPUT, "Quang cao - Tim kiem", "Nhap noi dung tim kiem.", "Tim", "Quay lai");
			case 2: {
				if(PlayerInfo[playerid][pADMute] == 1) {
					SendClientMessageEx(playerid, COLOR_GREY, "Ban bi cam dang quang cao.");
				}
				else if(PlayerInfo[playerid][pPnumber] == 0) {
					SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co dien thoai.");
				}
				else ShowPlayerDialogEx(playerid, DIALOG_ADCATEGORYPLACE, DIALOG_STYLE_LIST, "Chon danh muc", "Bat dong san\nXe co\nCan mua\nCan ban\nKhac", "Chon", "Huy");
			}
			case 3: {
				if(PlayerInfo[playerid][pADMute] == 1) {
					SendClientMessageEx(playerid, COLOR_GREY, "Ban bi cam dang quang cao.");
				}
				else if(PlayerInfo[playerid][pPnumber] == 0) {
					SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co dien thoai.");
				}
				else if(gettime() < GetPVarInt(playerid, "adT")) {
					ShowMainAdvertMenu(playerid);
					return SendClientMessageEx(playerid, COLOR_GREY, "Chi duoc dang quang cao uu tien moi hai phut.");
				}	
				else if(gettime() < iAdverTimer) {
					ShowMainAdvertMenu(playerid);
					return SendClientMessageEx(playerid, COLOR_GREY, "Chi duoc dang mot quang cao uu tien moi 30 giay.");
				}
				else
				{
					if(PlayerInfo[playerid][pAdvertVoucher] != 0)
					{
						ShowPlayerDialogEx(playerid, DIALOG_ADVERTVOUCHER, DIALOG_STYLE_MSGBOX, "Priority Advertisement Voucher", "Ban co Priority Advertisement Voucher, ban muon dung khong?\n\n{FF0000}Luu y: Ban se mat 1 voucher neu chon Co.{FFFFFF}", "Co", "Khong");
					}
					else if(PlayerInfo[playerid][pAdvertVoucher] == 0)
						return ShowPlayerDialogEx(playerid, DIALOG_ADCATEGORYPLACEP, DIALOG_STYLE_LIST, "Chon danh muc", "Bat dong san\nXe co\nCan mua\nCan ban\nKhac", "Chon", "Huy");
				}
			}
			case 4: pc_cmd_houselistings(playerid, "");
		}
		case DIALOG_ADCATEGORYPLACE: {
			if(response) switch(listitem) {
				case 0: {
					AdvertType[playerid] = 1;
					ShowPlayerDialogEx(playerid, DIALOG_ADPLACE, DIALOG_STYLE_INPUT, "Quang cao",
					"Nhap quang cao bat dong san, duoi 128 ky tu.", "Gui", "Quay lai");
				}
				case 1: {
					AdvertType[playerid] = 2;
					ShowPlayerDialogEx(playerid, DIALOG_ADPLACE, DIALOG_STYLE_INPUT, "Quang cao",
					"Nhap quang cao xe co, duoi 128 ky tu.", "Gui", "Quay lai");
				}	
				case 2: {
					AdvertType[playerid] = 3;
					ShowPlayerDialogEx(playerid, DIALOG_ADPLACE, DIALOG_STYLE_INPUT, "Quang cao",
					"Nhap quang cao can mua, duoi 128 ky tu.", "Gui", "Quay lai");
				}
				case 3: {
					AdvertType[playerid] = 4;
					ShowPlayerDialogEx(playerid, DIALOG_ADPLACE, DIALOG_STYLE_INPUT, "Quang cao",
					"Nhap quang cao can ban, duoi 128 ky tu.", "Gui", "Quay lai");
				}
				case 4: {
					AdvertType[playerid] = 5;
					ShowPlayerDialogEx(playerid, DIALOG_ADPLACE, DIALOG_STYLE_INPUT, "Quang cao",
					"Nhap quang cao khac, duoi 128 ky tu.", "Gui", "Quay lai");
				}
			}
		}	
		case DIALOG_ADCATEGORYPLACEP: {
			if(response) switch(listitem) {
				case 0: {
					AdvertType[playerid] = 1;
					ShowPlayerDialogEx(playerid, DIALOG_ADPLACEP, DIALOG_STYLE_INPUT, "Quang cao - Quang cao uu tien",
					"Nhap quang cao uu tien ve bat dong san, duoi 128 ky tu.\nQuang cao uu tien se duoc phat toan may chu, phi $150,000.", "Gui", "Quay lai");
				}
				case 1: {
					AdvertType[playerid] = 2;
					ShowPlayerDialogEx(playerid, DIALOG_ADPLACEP, DIALOG_STYLE_INPUT, "Quang cao - Quang cao uu tien",
					"Nhap quang cao uu tien ve xe co, duoi 128 ky tu.\nQuang cao uu tien se duoc phat toan may chu, phi $150,000.", "Gui", "Quay lai");
				}	
				case 2: {
					AdvertType[playerid] = 3;
					ShowPlayerDialogEx(playerid, DIALOG_ADPLACEP, DIALOG_STYLE_INPUT, "Quang cao - Quang cao uu tien",
					"Nhap quang cao uu tien can mua, duoi 128 ky tu.\nQuang cao uu tien se duoc phat toan may chu, phi $150,000.", "Gui", "Quay lai");
				}
				case 3: {
					AdvertType[playerid] = 4;
					ShowPlayerDialogEx(playerid, DIALOG_ADPLACEP, DIALOG_STYLE_INPUT, "Quang cao - Quang cao uu tien",
					"Nhap quang cao uu tien can ban, duoi 128 ky tu.\nQuang cao uu tien se duoc phat toan may chu, phi $150,000.", "Gui", "Quay lai");
				}
				case 4: {
					AdvertType[playerid] = 5;
					ShowPlayerDialogEx(playerid, DIALOG_ADPLACEP, DIALOG_STYLE_INPUT, "Quang cao - Quang cao uu tien",
					"Nhap quang cao uu tien khac, duoi 128 ky tu.\nQuang cao uu tien se duoc phat toan may chu, phi $150,000.", "Gui", "Quay lai");
				}
			}
		}		
		case DIALOG_ADPLACE: {
			if(response) {

				new iLength = strlen(inputtext);
				
				if(GetPVarInt(playerid, "RequestingAdP") == 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da co quang cao uu tien cho xu ly.");

				if(!(2 <= iLength <= 127)) {
					ShowMainAdvertMenu(playerid);
					return SendClientMessageEx(playerid, COLOR_GREY, "Noi dung qua dai hoac qua ngan.");
				}

				iLength *= 50;
				if(GetPlayerCash(playerid) < iLength) {
					ShowMainAdvertMenu(playerid);
					return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien mat.");
				}
				/*if(Homes[playerid] > 0 && AdvertType[playerid] == 1 && !PlayerInfo[playerid][pShopNotice])
				{
					PlayerTextDrawSetString(playerid, MicroNotice[playerid], ShopMsg[6]);
					PlayerTextDrawShow(playerid, MicroNotice[playerid]);
					SetTimerEx("HidePlayerTextDraw", 10000, false, "ii", playerid, _:MicroNotice[playerid]);
				}*/
				strcpy(szAdvert[playerid], inputtext, 128);
				StripColorEmbedding(szAdvert[playerid]);
				GivePlayerCash(playerid, -iLength);
				SendClientMessageEx(playerid, COLOR_WHITE, "Chuc mung, quang cao cua ban da duoc dang!");
			}
			else ShowMainAdvertMenu(playerid);
		}
		case DIALOG_ADPLACEP: {
			if(response) {
				if(GetPVarInt(playerid, "RequestingAdP") == 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban da co quang cao uu tien cho xu ly.");
			
				if(gettime() < iAdverTimer) {
					SendClientMessageEx(playerid, COLOR_GREY, "Chi duoc dang mot quang cao uu tien moi 30 giay.");
					return ShowPlayerDialogEx(playerid, DIALOG_ADPLACEP, DIALOG_STYLE_INPUT, "Quang cao - Quang cao uu tien",
					"Nhap quang cao mong muon, duoi 128 ky tu.\nQuang cao uu tien se duoc phat toan may chu, phi $150,000.", "Gui", "Quay lai");
				}
				if(!(2 <= strlen(inputtext) <= 79)) {
					ShowMainAdvertMenu(playerid);
					return SendClientMessageEx(playerid, COLOR_GREY, "Noi dung qua dai hoac qua ngan.");
				}				
				if(GetPVarInt(playerid, "AdvertVoucher") > 0)
				{
				}
				else if(PlayerInfo[playerid][pFreeAdsLeft] > 0)
				{
				}
				else if(PlayerInfo[playerid][pDonateRank] == 2 && GetPlayerCash(playerid) < 125000) {
					ShowMainAdvertMenu(playerid);
					return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien mat.");
				}
				else if(PlayerInfo[playerid][pDonateRank] == 3 && GetPlayerCash(playerid) < 100000) {
					ShowMainAdvertMenu(playerid);
					return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien mat.");
				}
				else if(PlayerInfo[playerid][pDonateRank] >= 4 && GetPlayerCash(playerid) < 50000) {
					ShowMainAdvertMenu(playerid);
					return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien mat.");
				}
				else if(PlayerInfo[playerid][pDonateRank] <= 1 && GetPlayerCash(playerid) < 150000) {
					ShowMainAdvertMenu(playerid);
					return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien mat.");
				}
				SetPVarInt(playerid, "adT", gettime()+120);
				strcpy(szAdvert[playerid], inputtext, 128);
				StripColorEmbedding(szAdvert[playerid]);
					
				SetPVarInt(playerid, "RequestingAdP", 1);
				SetPVarString(playerid, "PriorityAdText", szAdvert[playerid]);
				new playername[MAX_PLAYER_NAME];
				GetPlayerName(playerid, playername, sizeof(playername));
				SendReportToQue(playerid, "Quang cao uu tien", 2, 4);	
					
				return SendClientMessageEx(playerid, COLOR_WHITE, "Da gui quang cao uu tien, hay cho Admin duyet hoac tu choi.");
			}
			else ShowMainAdvertMenu(playerid);
		}
		case DIALOG_ADSEARCH: {
			if(response) {

				if(!(4 <= strlen(inputtext) <= 80)) {
					return ShowPlayerDialogEx(playerid, DIALOG_ADSEARCH, DIALOG_STYLE_INPUT, "Quang cao - Tim kiem", "Tu khoa phai tu 4\n den 80 ky tu.\n\nNhap noi dung tim kiem.", "Tim", "Quay lai");
				}
				else for(new x; x < 50; ++x) ListItemTrackId[playerid][x] = -1;

				new
					szDialog[2256],
					szSearch[80],
					szBuffer[32],
					iCount;

				strcat(szSearch, inputtext, sizeof(szSearch)); // strfind is a piece of shit when it comes to non-indexed arrays, maybe this'll help.
				foreach(new i: Player)
				{
					if(!isnull(szAdvert[i])) {
						// printf("[ads] [NAME: %s] [ID: %i] [AD: %s] [SEARCH: %s]", GetPlayerNameEx(i), i, szAdvert[i], szSearch);
						if(strfind(szAdvert[i], szSearch, true) != -1 && iCount < 50) {
							// printf("[ads - MATCH] [NAME: %s] [ID: %i] [AD: %s] [SEARCH: %s] [COUNT: %i] [DIALOG LENGTH: %i] [FINDPOS: %i]", GetPlayerNameEx(i), i, szAdvert[i], szSearch, iCount, strlen(szDialog), strfind(szAdvert[i], szSearch, true));
							strcpy(szBuffer, szAdvert[i], sizeof(szBuffer));
							if(PlayerInfo[playerid][pAdmin] <= 1) format(szDialog, sizeof(szDialog), "%s%s... (%i)\r\n", szDialog, szBuffer, PlayerInfo[i][pPnumber]);
							else format(szDialog, sizeof(szDialog), "%s%s... (%s)\r\n", szDialog, szBuffer, GetPlayerNameEx(i));
							ListItemTrackId[playerid][iCount++] = i;
						}
					}
				}	
				if(!isnull(szDialog)) ShowPlayerDialogEx(playerid, DIALOG_ADSEARCHLIST, DIALOG_STYLE_LIST, "Quang cao - Ket qua tim kiem", szDialog, "Chon", "Quay lai");
				else ShowPlayerDialogEx(playerid, DIALOG_ADSEARCH, DIALOG_STYLE_INPUT, "Quang cao - Tim kiem", "Khong co ket qua.\n\nNhap noi dung tim kiem.", "Tim", "Quay lai");

			}
			else ShowMainAdvertMenu(playerid);
		}
		case DIALOG_ADSEARCHLIST: if(response) {

			new
				i = ListItemTrackId[playerid][listitem],
				szDialog[164];

			if(IsPlayerConnected(i) && !isnull(szAdvert[i])) {
				SetPVarInt(playerid, "advertContact", PlayerInfo[i][pPnumber]);
				format(szDialog, sizeof(szDialog), "%s\r\nLien he: %i", szAdvert[i], PlayerInfo[i][pPnumber]);
				ShowPlayerDialogEx(playerid, DIALOG_ADFINAL, DIALOG_STYLE_MSGBOX, "Quang cao - Ket qua tim kiem", szDialog, "Goi", "Thoat");
			}
			else SendClientMessage(playerid, COLOR_GREY, "Nguoi nay da ngat ket noi hoac go quang cao.");
		}
		case DIALOG_ADFINAL: {
			if(response) {
				new params[32];
				format(params, sizeof(params), "%d", GetPVarInt(playerid, "advertContact"));
				DeletePVar(playerid, "adverContact");
				return pc_cmd_call(playerid, params);
			}
		}		
		case DIALOG_ADLIST: {
			if(response) {

				new
					i = ListItemTrackId[playerid][listitem],
					szDialog[164];

				if(IsPlayerConnected(i) && !isnull(szAdvert[i])) {
					SetPVarInt(playerid, "advertContact", PlayerInfo[i][pPnumber]);
					format(szDialog, sizeof(szDialog), "%s\r\nLien he: %i", szAdvert[i], PlayerInfo[i][pPnumber]);
					return ShowPlayerDialogEx(playerid, DIALOG_ADFINAL, DIALOG_STYLE_MSGBOX, "Quang cao - Ket qua tim kiem", szDialog, "Goi", "Thoat");
				}
				else SendClientMessage(playerid, COLOR_GREY, "Nguoi nay da ngat ket noi hoac go quang cao.");
			}
			else ShowMainAdvertMenu(playerid);
		}
		case DIALOG_ADVERTVOUCHER:
		{
			if(response) // Clicked Yes
			{
				SetPVarInt(playerid, "AdvertVoucher", 1);
				ShowPlayerDialogEx(playerid, DIALOG_ADCATEGORYPLACEP, DIALOG_STYLE_LIST, "Chon danh muc", "Bat dong san\nXe co\nCan mua\nCan ban\nKhac", "Chon", "Huy");
			}
			else // Clicked No
			{
				ShowPlayerDialogEx(playerid, DIALOG_ADCATEGORYPLACEP, DIALOG_STYLE_LIST, "Chon danh muc", "Bat dong san\nXe co\nCan mua\nCan ban\nKhac", "Chon", "Huy");
			}
		}
	}
	return 0;
}



alias:advertisements("ads")
CMD:advertisements(playerid, const params[]) {
	if(gPlayerLogged{playerid} == 0) {
		SendClientMessageEx(playerid, COLOR_GREY, "Ban chua dang nhap.");
	}
	else if(GetPVarType(playerid, "Injured")) {
		SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung quang cao khi bi thuong.");
	}
	else if(PlayerCuffed[playerid] != 0) {
		SendClientMessageEx(playerid, COLOR_GREY, "Luc nay khong the dung quang cao.");
	}
	else if(PlayerInfo[playerid][pJailTime] > 0) {
		SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung quang cao khi o tu.");
	}
	else ShowMainAdvertMenu(playerid);
	return 1;
}

CMD:adunmute(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[playerid][pWatchdog] >= 2)
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /adunmute [player]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pADMute] == 1)
			{
				if(PlayerInfo[giveplayerid][pJailTime] != 0)
				{
					SendClientMessageEx(playerid, COLOR_LIGHTRED, "Khong the de nghi mo cam cho nguoi trong tu!");
					SendClientMessageEx(giveplayerid, COLOR_LIGHTRED, "Khong the duoc mo cam /ad khi dang o tu.");
					return 1;
				}
				format(string, sizeof(string), "AdmCmd: %s(%d) was unmuted from /ad by %s.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid));
				Log("logs/admin.log", string);
				format(string, sizeof(string), "AdmCmd: %s duoc %s mo cam /ad.", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid));
				ABroadCast(COLOR_LIGHTRED,string,2);
				PlayerInfo[giveplayerid][pADMute] = 0;
				PlayerInfo[giveplayerid][pADMuteTotal]--;
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_LIGHTRED,"Nguoi do khong bi cam /newb!");
			}

		}
	}
	return 1;
}

CMD:admute(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[playerid][pSMod] == 1)
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /admute [player]");

		if(IsPlayerConnected(giveplayerid))
		{
				if(PlayerInfo[giveplayerid][pAdmin] >= 2) return SendClientMessageEx(playerid, COLOR_LIGHTRED, "Khong the /admute Admin");
				if(PlayerInfo[giveplayerid][pADMute] == 0)
				{
				    SetPVarInt(giveplayerid, "UnmuteTime", gettime());
					PlayerInfo[giveplayerid][pADMute] = 1;
					PlayerInfo[giveplayerid][pADMuteTotal] += 1;
					format(string, sizeof(string), "AdmCmd: %s(%d) was muted from placing /ad's by %s(%d).", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid));
					Log("logs/admin.log", string);
					format(string, sizeof(string), "AdmCmd: %s bi %s cam dang /ad.", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid));
					ABroadCast(COLOR_LIGHTRED,string,2);

					if(PlayerInfo[giveplayerid][pADMuteTotal] > 6)
					{
						PlayerInfo[giveplayerid][pADMuteTotal] = 0; 
						CreateBan(playerid, PlayerInfo[giveplayerid][pId], giveplayerid, PlayerInfo[giveplayerid][pIP], "Excessive Ad-mutes", 14);
					}

					if(PlayerInfo[playerid][pAdmin] == 1)
					{
						format(string, sizeof(string), "AdmCmd: %s bi Admin cam dang /ad.", GetPlayerNameEx(giveplayerid));
						SendDutyAdvisorMessage(TEAM_AZTECAS_COLOR, string);
						SendClientMessageEx(giveplayerid, COLOR_LIGHTRED, "Ban vua bi Admin cam dung Quang cao [/ads].");
					}
					else
					{
						format(string, sizeof(string), "AdmCmd: %s bi %s cam dang /ad.", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid));
						SendDutyAdvisorMessage(TEAM_AZTECAS_COLOR, string);
						SendClientMessageEx(giveplayerid, COLOR_LIGHTRED, "Ban vua bi %s cam dung Quang cao (/ads).", GetPlayerNameEx(playerid));
					}

					SendClientMessageEx(giveplayerid, COLOR_LIGHTRED, "Chi duoc dung quang cao cho muc dich IC, tru khi Admin cho phep khac.");
					SendClientMessageEx(giveplayerid, COLOR_LIGHTRED, "De duoc mo cam, ban se bi phat tien hoac giam giu. Tai pham se bi phat nang hon. Lien he Admin cap cao neu co nham lan.");

					SendClientMessageToAllEx(COLOR_LIGHTRED, "AdmCmd: %s bi cam dung Quang cao [/ads] do lam dung.", GetPlayerNameEx(giveplayerid));
				}
				else
				{
					if(PlayerInfo[playerid][pAdmin] >= 2)
					{
						ShowAdMuteFine(giveplayerid);
						SendClientMessageEx(playerid, COLOR_LIGHTRED, "Ban de nghi mo cam /ads cho %s.", GetPlayerNameEx(giveplayerid));
					}
					else
					{
						SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi do dang bi cam. Advisor khong duoc mo cam quang cao.");
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

CMD:freeads(playerid, params[])
{
	if(PlayerInfo[playerid][pDonateRank] < 4) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai Platinum VIP+");
	new days;
	ConvertTime(gettime() - PlayerInfo[playerid][pFreeAdsDay], .ctd=days);
	if(days >= 1)
	{
		PlayerInfo[playerid][pFreeAdsDay] = gettime();
		PlayerInfo[playerid][pFreeAdsLeft] = 3;
		SendClientMessageEx(playerid, COLOR_YELLOW, "* Hom nay ban con 3 quang cao mien phi.");
	}	
	else if(PlayerInfo[playerid][pFreeAdsLeft] > 0)
	{
		SendClientMessageEx(playerid, COLOR_YELLOW, "* Hom nay ban con %d quang cao mien phi.", PlayerInfo[playerid][pFreeAdsLeft]);
	}
	else
	{
		new datestring[32];
		datestring = date(PlayerInfo[playerid][pFreeAdsDay]+86400, 3);
		SendClientMessageEx(playerid, COLOR_YELLOW, "* Da het quang cao mien phi, hay cho den %s.", datestring);
	}
	return 1;
}

ShowMainAdvertMenu(playerid)
	return ShowPlayerDialogEx(playerid, DIALOG_ADMAIN, DIALOG_STYLE_LIST, "Quang cao", "Danh sach quang cao\nTim quang cao\nDang quang cao\nDang quang cao uu tien\nNha dang ban", "Chon", "Huy");