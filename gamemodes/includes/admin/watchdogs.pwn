/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Watchdog System

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

CMD:nextwatch(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "Hay dung /spec de tranh loi.");
	if(PlayerInfo[playerid][pWatchdog] >= 1)
	{
		if(GetPVarInt(playerid, "StartedWatching") == 0) return pc_cmd_startwatch(playerid, params);
		
		if(gettime() >= GetPVarInt(playerid, "NextWatch")) return mysql_tquery(MainPipeline, "SELECT * FROM `nonrppoints` WHERE `active` = '1' ORDER BY `point` DESC", "WatchWatchlist", "i", playerid);
		else if(PlayerInfo[playerid][pWatchdog] >= 2) return mysql_tquery(MainPipeline, "SELECT * FROM `nonrppoints` WHERE `active` = '1' ORDER BY `point` DESC", "WatchWatchlist", "i", playerid);
		else
		{
			return SendClientMessageEx(playerid, COLOR_GRAD1, "Chua the bo qua nguoi choi, hay cho %d giay!", GetPVarInt(playerid, "NextWatch")-gettime());
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	}
	return true;
}

CMD:watchspec(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "Hay dung /spec de tranh loi.");
	if(PlayerInfo[playerid][pWatchdog] >= 2)
	{
		new giveplayerid;
		if(GetPVarInt(playerid, "StartedWatching") == 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "WATCHDOG: Ban da bat dau theo doi.");
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "CACH DUNG: /watchspec [player]");
		if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the theo doi chinh minh!");
		if(PlayerInfo[giveplayerid][pWatchlist] == 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong nam trong danh sach theo doi!");
		
		SpectatePlayer(playerid, giveplayerid);
		SendClientMessageEx(playerid, -1, "WATCHDOG: Ban da bat dau theo doi.");
		SetPVarInt(playerid, "SpectatingWatch", giveplayerid);
		SetPVarInt(playerid, "StartedWatching", 1);
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	}
	return true;
}		

CMD:startwatch(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "Hay dung /spec de tranh loi.");
	if(PlayerInfo[playerid][pWatchdog] >= 1)
	{
		if(GetPVarInt(playerid, "StartedWatching") == 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "WATCHDOG: Ban da bat dau theo doi.");
		if(gettime() >= GetPVarInt(playerid, "NextWatch")) return mysql_tquery(MainPipeline, "SELECT * FROM `nonrppoints` WHERE `active` = '1' ORDER BY `point` DESC", "WatchWatchlist", "i", playerid);
		else if(PlayerInfo[playerid][pWatchdog] >= 2) return mysql_tquery(MainPipeline, "SELECT * FROM `nonrppoints` WHERE `active` = '1' ORDER BY `point` DESC", "WatchWatchlist", "i", playerid);
		else
		{
			return SendClientMessageEx(playerid, COLOR_GRAD1, "Chua the bo qua nguoi choi, hay cho %d giay!", GetPVarInt(playerid, "NextWatch")-gettime());
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	}
	return true;
}

CMD:stopwatch(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "Hay dung /spec de tranh loi.");
	if(PlayerInfo[playerid][pWatchdog] >= 1)
	{
		if(GetPVarInt(playerid, "StartedWatching") == 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "WATCHDOG: Ban khong dang theo doi ai.");
		
		SetPVarInt(playerid, "StartedWatching", 0);
		if(Spectating[playerid] > 0)
		{
			SetPVarInt(GetPVarInt(playerid, "SpectatingWatch"), "BeingSpectated", 0);
			GettingSpectated[Spectate[playerid]] = INVALID_PLAYER_ID;
			Spectating[playerid] = 0;
			SpecTime[playerid] = 0;
			Spectate[playerid] = INVALID_PLAYER_ID;
			SetPVarInt(playerid, "SpecOff", 1 );
			TogglePlayerSpectating(playerid, false);
			SetCameraBehindPlayer(playerid);
			DeletePVar(playerid, "SpectatingWatch");
			SendClientMessageEx(playerid, -1, "WATCHDOG: Ban da dung theo doi.");
		}
		else return SendClientMessageEx(playerid, COLOR_GRAD1, "WATCHDOG: Ban khong dang theo doi ai.");
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	}
	return true;
}

CMD:dmrmute(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 3)
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /dmrmute [player]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pDMRMuted] == 0)
			{
			    PlayerInfo[giveplayerid][pDMRMuted] = 1;
				format(string, sizeof(string), "AdmCmd: %s da cam vo thoi han %s gui bao cao DM.",GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ABroadCast(COLOR_LIGHTRED,string,2);
				SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Ban bi %s cam gui /dmreports.", GetPlayerNameEx(playerid));
				format(string, sizeof(string), "AdmCmd: %s(%d) was blocked from /dmreport by %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid));
				Log("logs/mute.log", string);
			}
			else
			{
			    if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Chi Senior Admin duoc go cam gui bao cao DM");
				PlayerInfo[giveplayerid][pDMRMuted] = 0;
				format(string, sizeof(string), "AdmCmd: %s da duoc %s cho phep gui bao cao DM tro lai",GetPlayerNameEx(giveplayerid),GetPlayerNameEx(playerid));
				ABroadCast(COLOR_LIGHTRED,string,2);
				SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Ban duoc %s cho phep gui /dmreports tro lai.", GetPlayerNameEx(playerid));
				format(string, sizeof(string), "AdmCmd: %s(%d) was unblocked from /dmreport by %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid));
				Log("logs/mute.log", string);
			}
  }
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:dmreport(playerid, params[])
{
	if(PlayerInfo[playerid][pDMRMuted] != 0) return SendClientMessage(playerid, COLOR_GRAD2, "Ban dang bi cam gui bao cao DM.");
	new giveplayerid;
	if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_WHITE,"CACH DUNG: /dmreport [playerid]");
	if(IsPlayerConnected(giveplayerid))
	{
		if(playerid == giveplayerid) return SendClientMessage(playerid, COLOR_WHITE, "Khong the dung lenh nay cho chinh minh!");
		if(PlayerInfo[giveplayerid][pAdmin] >= 2 && PlayerInfo[giveplayerid][pTogReports] != 1) return SendClientMessage(playerid, COLOR_WHITE, "Khong the dung lenh nay voi Admin!");
		if(gettime() - ShotPlayer[giveplayerid][playerid] < 300)
	    {
			SetPVarInt(playerid, "pDMReport", giveplayerid);
			ShowPlayerDialogEx(playerid, DMRCONFIRM, DIALOG_STYLE_MSGBOX, "Bao cao DM", "Ban xac nhan da tan mat thay nguoi nay DM trong 60 giay qua. Lam dung lenh co the bi cam tam thoi.", "Xac nhan", "Huy");
		}
		else
		{
		    SendClientMessage(playerid, COLOR_WHITE, "Nguoi do chua ban ban hoac ban da bao cao ho trong 5 phut qua.");
			SendClientMessage(playerid, COLOR_WHITE, "As a reminder, abuse of this system could lead to punishment up to a temporary ban.");
		}
	}
	return 1;
}


CMD:dmalert(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2 && PlayerInfo[playerid][pAdmin] < 1338) return SendClientMessageEx(playerid, COLOR_GRAD2, "Admin khong duoc gui bao cao.");
	if(PlayerInfo[playerid][pWatchdog] < 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay!");
	if(!GetPVarType(playerid, "SpectatingWatch")) return SendClientMessageEx(playerid, COLOR_GRAD2, "Chi dung duoc lenh nay khi dang theo doi nguoi choi!");
	if(PlayerInfo[playerid][pRMuted] != 0) return ShowPlayerDialogEx(playerid,7955,DIALOG_STYLE_MSGBOX,"Da chan bao cao","Ban dang bi cam gui bao cao!\n\nLuu y khi bao cao:\n- Neu ro viec can ho tro, khong yeu cau ten Admin.\n- Mo ta cu the van de.\n- Khong bao cao sai su that.\n- Khong xuc pham Admin.\n- Chi bao cao van de trong game.\n- Don hang shop dung lenh /shoporder","Dong", "");
	if(GetPVarType(playerid, "HasReport")) return SendClientMessageEx(playerid, COLOR_GREY, "Moi luc chi duoc co 1 bao cao dang cho.");
	JustReported[playerid]=25;
	new giveplayerid = GetPVarInt(playerid, "SpectatingWatch");
	new string[128];
	format(string, sizeof(string), "{FF0000}(Canh bao DM) %s (ID %d) dang DM.{FFFF91}", GetPlayerNameEx(giveplayerid), giveplayerid);
	SendReportToQue(playerid, string, 2, 1);
	SetPVarInt(playerid, "AlertedThisPlayer", giveplayerid);
	SetPVarInt(playerid, "AlertType", 1);
	AlertTime[playerid] = 300;
	foreach(new i : Player) if(PlayerInfo[i][pWatchdog] >= 1) SendClientMessageEx(i, COLOR_LIGHTBLUE, string);
	SendClientMessageEx(playerid, COLOR_YELLOW, "Da gui bao cao DM den Admin va Watchdog.");
	SetPVarInt(playerid, "WDReport", 1);
	format(string, sizeof(string), "Mo ta ngan gon hanh vi ban da thay %s thuc hien.\n * It nhat 30 ky tu", GetPlayerNameEx(giveplayerid));
	return ShowPlayerDialogEx(playerid, DIALOG_WDREPORT, DIALOG_STYLE_INPUT, "Bao cao su viec - Canh bao DM", string, "Gui", "");
}

CMD:watchlistadd(playerid, params[])
{
	if(PlayerInfo[playerid][pWatchdog] >= 4 || PlayerInfo[playerid][pAdmin] >= 1337)
	{
		new points = 0, days, giveplayerid, string[128];
		if(sscanf(params, "ddI(0)", giveplayerid, days, points)) return SendClientMessageEx(playerid, COLOR_GRAD1, "CACH DUNG: /watchlistadd [playerid] [days] [points (optional)]");
		
		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pAdmin] >= 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dua Admin vao danh sach theo doi!");
			if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dua chinh minh vao danh sach theo doi!");
			if(days < 1 || days > 365) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nhap so ngay (1 den 365 ngay).");
			if(points < 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "So diem khong hop le!");
			if(PlayerInfo[giveplayerid][pWatchlist] == 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi da nam trong danh sach theo doi!");
			
			if(points > 0) AddNonRPPoint(giveplayerid, points, gettime()+2592000, "Manually Added", playerid, 1);
			PlayerInfo[giveplayerid][pWatchlist] = 1;
			PlayerInfo[giveplayerid][pNonRPMeter] += points;
			PlayerInfo[giveplayerid][pWatchlistTime] = gettime() + 86400 / days;
			
			SendClientMessageEx(playerid, COLOR_CYAN, "Ban da them %s vao danh sach theo doi trong %d ngay", GetPlayerNameEx(giveplayerid), days);
			
			format(string, sizeof(string), "%s has added %s(%d) to the watchlist", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
			Log("logs/watchlist.log", string);
		}
		else return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le!");
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	return true;
}

CMD:watchlistremove(playerid, params[])
{
	if(PlayerInfo[playerid][pWatchdog] >= 4 || PlayerInfo[playerid][pAdmin] >= 1337)
	{
		new giveplayerid, string[128];
		if(sscanf(params, "d", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "CACH DUNG: /watchlistremove [playerid]");
		
		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pAdmin] >= 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung lenh nay voi Admin!");
			if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung lenh nay voi chinh minh!");
			if(PlayerInfo[giveplayerid][pWatchlist] == 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong nam trong danh sach theo doi!");
			
			PlayerInfo[giveplayerid][pWatchlist] = 0;
			PlayerInfo[giveplayerid][pWatchlistTime] = 0;
			
			SendClientMessageEx(playerid, COLOR_CYAN, "Da go %s khoi danh sach theo doi.", GetPlayerNameEx(giveplayerid));
			
			format(string, sizeof(string), "%s has removed %s(%d) from the watchlist", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
			Log("logs/watchlist.log", string);
		}
		else return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le!");
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	return true;
}

CMD:restrictaccount(playerid, params[])
{
	if(PlayerInfo[playerid][pWatchdog] >= 3 || PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		new giveplayerid, reason[64], string[128];
		if(sscanf(params, "ds[64]", giveplayerid, reason)) return SendClientMessageEx(playerid, COLOR_GRAD1, "CACH DUNG: /restrictaccount [playerid] [reason]");
		
		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pAccountRestricted] == 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Tai khoan nay da bi han che!");
			if(PlayerInfo[giveplayerid][pAdmin] >= 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the han che tai khoan Admin!");
			if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the han che tai khoan cua chinh minh!");
			
			PlayerInfo[giveplayerid][pAccountRestricted] = 1;
			ResetPlayerWeaponsEx(giveplayerid);
			SendClientMessageEx(playerid, COLOR_CYAN, "Da han che tai khoan %s.", GetPlayerNameEx(giveplayerid));
			SendClientMessageEx(giveplayerid, COLOR_CYAN, "Tai khoan bi %s han che. Ban khong the lai xe, gay hoac nhan sat thuong, hay so huu vu khi", GetPlayerNameEx(playerid));
			SendClientMessageEx(giveplayerid, COLOR_RED, "Luu y: Lien he thanh vien RP Improvement Team de go han che.");
			
			PlayerTextDrawShow(giveplayerid, AccountRestriction[giveplayerid]);
			PlayerTextDrawShow(giveplayerid, AccountRestrictionEx[giveplayerid]);
			
			format(string, sizeof(string), "AdmCmd: %s da han che tai khoan %s, ly do: %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), reason);
			ABroadCast(COLOR_LIGHTRED, string, 2);
			
			format(string, sizeof(string), "%s has restricted %s(%d) account, reason: %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), reason);
			Log("logs/restrictaccount.log", string);
		}
		else return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	return true;
}

CMD:unrestrictaccount(playerid, params[])
{
	if(PlayerInfo[playerid][pWatchdog] >= 3 || PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		new giveplayerid, string[128];
		if(sscanf(params, "d", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "CACH DUNG: /unrestrictaccount [playerid]");
		
		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pAccountRestricted] == 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Tai khoan nay khong bi han che!");
			if(PlayerInfo[giveplayerid][pAdmin] >= 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the go han che tai khoan Admin!");
			if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the go han che tai khoan cua chinh minh!");
			
			PlayerInfo[giveplayerid][pAccountRestricted] = 0;
			PlayerInfo[giveplayerid][pNonRPMeter] = 0; //fix for bug where non-rp points would remain after being unrestricted.
			
			SendClientMessageEx(playerid, COLOR_CYAN, "Da go han che tai khoan %s.", GetPlayerNameEx(giveplayerid));
			SendClientMessageEx(giveplayerid, COLOR_CYAN, "Tai khoan cua ban duoc %s go han che.", GetPlayerNameEx(playerid));
			
			format(string, sizeof(string), "AdmCmd: %s da go han che tai khoan %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
			ABroadCast(COLOR_LIGHTRED, string, 2);
			
			PlayerTextDrawHide(giveplayerid, AccountRestriction[giveplayerid]);
			PlayerTextDrawHide(giveplayerid, AccountRestrictionEx[giveplayerid]);
			
			format(string, sizeof(string), "%s has unrestricted %s(%d) account", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
			Log("logs/restrictaccount.log", string);
		}
		else return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	return true;
}

CMD:watchdogs(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[playerid][pWatchdog] >= 1)
	{
		new string[128];
		SendClientMessageEx(playerid, COLOR_GRAD1, "Watchdog dang online:");
		foreach(new i : Player)
		{	
			if(PlayerInfo[i][pWatchdog] > 0)
			{
				if(PlayerInfo[i][pWatchdog] == 1) format(string, sizeof(string), "Watchdog %s (ID %i)", GetPlayerNameEx(i), i);
				else if(PlayerInfo[i][pWatchdog] == 2) format(string, sizeof(string), "Senior Watchdog %s (ID %i)", GetPlayerNameEx(i), i);
				else if(PlayerInfo[i][pWatchdog] == 3) format(string, sizeof(string), "RP Specialist %s (ID %i)", GetPlayerNameEx(i), i);
				else if(PlayerInfo[i][pWatchdog] == 4) format(string, sizeof(string), "Director of RP Improvement %s (ID %i)", GetPlayerNameEx(i), i);
				if((i == playerid || PlayerInfo[playerid][pWatchdog] >= 3) && PlayerInfo[i][pAdmin] < 2) format(string, sizeof(string), "%s (Gio nay: %d | Hom nay: %d)", string, WDReportHourCount[i], WDReportCount[i]);
				if(PlayerInfo[playerid][pToggledChats][CHAT_WATCHDOG]) strcat(string, " (Da tat chat WD)");
				SendClientMessageEx(playerid, COLOR_GRAD2, string);
			}
		}
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	return true;
}

CMD:togwd(playerid, params[])
{
	return ToggleAccountSetting(playerid, CHAT_WATCHDOG);
}
		
CMD:wd(playerid, params[]) 
{
	if(PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[playerid][pWatchdog] >= 1) 
	{
		if(PlayerInfo[playerid][pAdmin] < 2 && PlayerInfo[playerid][pWatchdog] < 3) PlayerInfo[playerid][pToggledChats][CHAT_WATCHDOG] = 0;
		if(PlayerInfo[playerid][pToggledChats][CHAT_WATCHDOG]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban da tat chat Watchdog, dung /togwd de bat lai.");
		if(!isnull(params)) 
		{
			szMiscArray[0] = 0;
			
			if(PlayerInfo[playerid][pAdmin] == 2) format(szMiscArray, sizeof(szMiscArray), "- Junior Admin %s: %s", GetPlayerNameEx(playerid), params);
			else if(PlayerInfo[playerid][pAdmin] == 3) format(szMiscArray, sizeof(szMiscArray), "- General Admin %s: %s", GetPlayerNameEx(playerid), params);
			else if(PlayerInfo[playerid][pAdmin] == 4) format(szMiscArray, sizeof(szMiscArray), "- Senior Admin %s: %s", GetPlayerNameEx(playerid), params);
			else if(PlayerInfo[playerid][pAdmin] == 1337) format(szMiscArray, sizeof(szMiscArray), "- Head Admin %s: %s", GetPlayerNameEx(playerid), params);
			else if(PlayerInfo[playerid][pAdmin] == 99999) format(szMiscArray, sizeof(szMiscArray), "- Executive Admin %s: %s", GetPlayerNameEx(playerid), params);
			else if(PlayerInfo[playerid][pWatchdog] == 1) format(szMiscArray, sizeof(szMiscArray), "** Watchdog %s: %s", GetPlayerNameEx(playerid), params);
			else if(PlayerInfo[playerid][pWatchdog] == 2) format(szMiscArray, sizeof(szMiscArray), "** Senior Watchdog %s: %s", GetPlayerNameEx(playerid), params);
			else if(PlayerInfo[playerid][pWatchdog] == 3) format(szMiscArray, sizeof(szMiscArray), "** RP Specialist %s: %s", GetPlayerNameEx(playerid), params);
			else if(PlayerInfo[playerid][pWatchdog] == 4) format(szMiscArray, sizeof(szMiscArray), "** Director of RP Improvement %s: %s", GetPlayerNameEx(playerid), params);
			else format(szMiscArray, sizeof(szMiscArray), "- Undefined Rank %s: %s", GetPlayerNameEx(playerid), params);

			foreach(new i : Player)
			{
				if((PlayerInfo[i][pAdmin] >= 2 || PlayerInfo[i][pWatchdog] >= 1) && PlayerInfo[playerid][pToggledChats][CHAT_WATCHDOG] == 0)
				{
					ChatTrafficProcess(i, 0x2267F0FF, szMiscArray, CHAT_WATCHDOG);
				}
			}
		}
		else return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /wd [watchdog chat]");
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	return true;
}

CMD:refer(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 2 && PlayerInfo[playerid][pAdmin] < 1338) return SendClientMessageEx(playerid, COLOR_GRAD2, "Admin khong duoc gui bao cao.");
	new reason[100];
	if(PlayerInfo[playerid][pWatchdog] < 1) return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban khong co quyen dung lenh nay!");
	if(!GetPVarType(playerid, "SpectatingWatch")) return SendClientMessageEx(playerid, COLOR_GRAD2, "Chi dung duoc lenh nay khi dang theo doi nguoi choi!");
	if(sscanf(params, "s[100]", reason)) return SendClientMessageEx(playerid, COLOR_GRAD1, "CACH DUNG: /refer [details]");
	if(PlayerInfo[playerid][pRMuted] != 0) return ShowPlayerDialogEx(playerid,7955,DIALOG_STYLE_MSGBOX,"Da chan bao cao","Ban dang bi cam gui bao cao!\n\nLuu y khi bao cao:\n- Neu ro viec can ho tro, khong yeu cau ten Admin.\n- Mo ta cu the van de.\n- Khong bao cao sai su that.\n- Khong xuc pham Admin.\n- Chi bao cao van de trong game.\n- Don hang shop dung lenh /shoporder","Dong", "");
 	if(GetPVarType(playerid, "HasReport")) return SendClientMessageEx(playerid, COLOR_GREY, "Moi luc chi duoc co 1 bao cao dang cho.");
	JustReported[playerid] = 25;
	new giveplayerid = GetPVarInt(playerid, "SpectatingWatch");
	new string[128];
	format(string, sizeof(string), "{FF0000}(Watchdog) %s (ID %d) | Chi tiet: %s{FFFF91}", GetPlayerNameEx(giveplayerid), giveplayerid, reason);
	SendReportToQue(playerid, string, 2, 1);
	SetPVarInt(giveplayerid, "BeenAlerted", 1);
	SetPVarInt(playerid, "AlertedThisPlayer", giveplayerid);
	foreach(new i : Player) if(PlayerInfo[i][pWatchdog] >= 1) SendClientMessageEx(i, COLOR_LIGHTBLUE, string);
	SendClientMessageEx(playerid, COLOR_YELLOW, "Da gui canh bao Watchdog den Admin va Watchdog.");
	SetPVarInt(playerid, "WDReport", 2);
	format(string, sizeof(string), "Mo ta ngan gon hanh vi ban da thay %s thuc hien.\n * It nhat 30 ky tu", GetPlayerNameEx(giveplayerid));
	return ShowPlayerDialogEx(playerid, DIALOG_WDREPORT, DIALOG_STYLE_INPUT, "Bao cao su viec - Chuyen tiep", string, "Gui", "");
}

CMD:wdwhitelist(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pWatchdog] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		new query[256], giveplayer[MAX_PLAYER_NAME], ip[16];
		if(sscanf(params, "s[24]s[16]", giveplayer, ip))
		{
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /wdwhitelist [watchdog name] [IP]");
			return 1;
		}

		new tmpName[24], tmpIP[16];
		mysql_escape_string(giveplayer, tmpName);
		mysql_escape_string(ip, tmpIP);
		SetPVarString(playerid, "OnWDWhitelist", tmpName);

		mysql_format(MainPipeline, query, sizeof(query), "UPDATE `accounts` SET `SecureIP`='%s' WHERE `Username`='%s' AND `Watchdog` <= %d", tmpIP, tmpName, PlayerInfo[playerid][pWatchdog]);
		mysql_tquery(MainPipeline, query, "OnWDWhitelist", "i", playerid);

		SendClientMessageEx(playerid, COLOR_YELLOW, "Dang cho phep IP %s vao tai khoan %s...", tmpIP, tmpName);
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	return true;
}

CMD:watchlist(playerid, params[])
{
	if(PlayerInfo[playerid][pWatchdog] >= 1 || PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[playerid][pSMod] == 1)
	{
		if(FetchingWatchlist == 1) return SendClientMessageEx(playerid, COLOR_RED, "Co nguoi dang tai danh sach theo doi, hay thu lai sau.");
		PublicSQLString = "";
		mysql_tquery(MainPipeline, "SELECT * FROM `nonrppoints` WHERE `active` = '1' AND `manual` = '1' ORDER BY `point` DESC", "FetchWatchlist", "i", playerid);
		
		SendClientMessageEx(playerid, COLOR_CYAN, "Dang tai danh sach theo doi...");
		FetchingWatchlist = 1;
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	return true;
}

CMD:makewatchdog(playerid, params[])  {
	if(PlayerInfo[playerid][pAdmin] < 1337 && PlayerInfo[playerid][pWatchdog] < 3) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	new ivalue, iTargetID;
	if(sscanf(params, "ui", iTargetID, ivalue)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /makewatchdog [player] [level]");
	if(!IsPlayerConnected(iTargetID)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi choi khong hop le.");
	if(ivalue > 0 && IsStaffBanned(iTargetID)) return SendClientMessageEx(playerid, COLOR_WHITE, "Nguoi do dang bi cam lam staff.");
	if(PlayerInfo[iTargetID][pHelper] >= 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the bo nhiem Advisor lam Watchdog!");
	if(PlayerInfo[iTargetID][pWatchdog] == ivalue) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do da co cap Watchdog nay.");
	if(PlayerInfo[playerid][pWatchdog] == 3 && ivalue >= 4) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the thang chuc nguoi choi len Watchdog cap 4+.");
	new szRank[128];
	switch(ivalue) {
		case 0: format(szRank, sizeof(szRank), "AdmCmd: %s da go chuc vu Watchdog cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
		case 1: format(szRank, sizeof(szRank), "AdmCmd: %s bo nhiem %s: Watchdog.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
		case 2: format(szRank, sizeof(szRank), "AdmCmd: %s bo nhiem %s: Senior Watchdog.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
		case 3: format(szRank, sizeof(szRank), "AdmCmd: %s bo nhiem %s: RP Specialist.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
		case 4: format(szRank, sizeof(szRank), "AdmCmd: %s bo nhiem %s: Director of RP Improvement.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
		default: format(szRank, sizeof(szRank), "AdmCmd: %s bo nhiem %s: Watchdog cap chua xac dinh.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
	}
	ABroadCast(COLOR_LIGHTRED, szRank, 2);
	switch(ivalue)
	{
		case 0: format(szRank, sizeof(szRank), "AdmCmd: %s(%d) has removed %s's(%d) watchdog rank.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID));
		case 1: format(szRank, sizeof(szRank), "AdmCmd: %s(%d) has made %s(%d) a Watchdog.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID));
		case 2: format(szRank, sizeof(szRank), "AdmCmd: %s(%d) has made %s(%d) a Senior Watchdog.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID));
		case 3: format(szRank, sizeof(szRank), "AdmCmd: %s(%d) has made %s(%d) a RP Specialist.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID));
		case 4: format(szRank, sizeof(szRank), "AdmCmd: %s(%d) has made %s(%d) the Director of RP Improvement.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID));
		default: format(szRank, sizeof(szRank), "AdmCmd: %s(%d) has made %s(%d) an undefined level(%d) watchdog.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID), ivalue);
	}

	PlayerInfo[iTargetID][pWatchdog] = ivalue;
	Log("logs/makewatchdog.log", szRank);

	switch(ivalue) {
		case 0: format(szRank, sizeof(szRank), "Chuc vu Watchdog cua ban da bi %s go bo.", GetPlayerNameEx(playerid));
		case 1: format(szRank, sizeof(szRank), "Ban duoc %s bo nhiem lam Watchdog.", GetPlayerNameEx(playerid));
		case 2: format(szRank, sizeof(szRank), "Ban duoc %s bo nhiem lam Senior Watchdog.", GetPlayerNameEx(playerid));
		case 3: format(szRank, sizeof(szRank), "Ban duoc %s bo nhiem lam RP Specialist.", GetPlayerNameEx(playerid));
		case 4: format(szRank, sizeof(szRank), "Ban duoc %s bo nhiem lam Director of RP Improvement.", GetPlayerNameEx(playerid));
		default: format(szRank, sizeof(szRank), "Ban duoc %s bo nhiem lam Watchdog cap chua xac dinh.", GetPlayerNameEx(playerid));
	}
	SendClientMessageEx(iTargetID, COLOR_LIGHTBLUE, szRank);

	switch(ivalue) {
		case 0: format(szRank, sizeof(szRank), "Ban da go chuc vu Watchdog cua %s.", GetPlayerNameEx(iTargetID));
		case 1: format(szRank, sizeof(szRank), "Da bo nhiem %s lam Watchdog.", GetPlayerNameEx(iTargetID));
		case 2: format(szRank, sizeof(szRank), "Da bo nhiem %s lam Senior Watchdog.", GetPlayerNameEx(iTargetID));
		case 3: format(szRank, sizeof(szRank), "Da bo nhiem %s lam RP Specialist.", GetPlayerNameEx(iTargetID));
		case 4: format(szRank, sizeof(szRank), "Da bo nhiem %s lam Director of RP Improvement.", GetPlayerNameEx(iTargetID));
		default: format(szRank, sizeof(szRank), "Da bo nhiem %s lam Watchdog cap chua xac dinh.", GetPlayerNameEx(iTargetID));
	}
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, szRank);
	return 1;
}
