/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Advisory System

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
stock CBroadCast(color,const string[],level)
{
	foreach(new i: Player)
	{
		if (PlayerInfo[i][pHelper] >= level)
		{
			SendClientMessageEx(i, color, string);
			//printf("%s", string);
		}
	}
	return 1;
}

stock ShowNMuteFine(playerid)
{
	new playername[MAX_PLAYER_NAME];
	GetPlayerName(playerid, playername, sizeof(playername));

	new totalwealth = PlayerInfo[playerid][pAccount] + GetPlayerCash(playerid);
	if(PlayerInfo[playerid][pPhousekey] != INVALID_HOUSE_ID && HouseInfo[PlayerInfo[playerid][pPhousekey]][hOwnerID] == GetPlayerSQLId(playerid)) totalwealth += HouseInfo[PlayerInfo[playerid][pPhousekey]][hSafeMoney];
	if(PlayerInfo[playerid][pPhousekey2] != INVALID_HOUSE_ID && HouseInfo[PlayerInfo[playerid][pPhousekey2]][hOwnerID] == GetPlayerSQLId(playerid)) totalwealth += HouseInfo[PlayerInfo[playerid][pPhousekey2]][hSafeMoney];
	if(PlayerInfo[playerid][pPhousekey3] != INVALID_HOUSE_ID && HouseInfo[PlayerInfo[playerid][pPhousekey3]][hOwnerID] == GetPlayerSQLId(playerid)) totalwealth += HouseInfo[PlayerInfo[playerid][pPhousekey3]][hSafeMoney];

    new fine = 10*totalwealth/100;
	if(PlayerInfo[playerid][pNMuteTotal] < 4)
	{
		new string[64];
		format(string,sizeof(string),"Giam %d phut\nPhat tien ($%d)",PlayerInfo[playerid][pNMuteTotal] * 15, fine);
		ShowPlayerDialogEx(playerid,NMUTE,DIALOG_STYLE_LIST,"Mo cam Newbie Chat - Chon hinh phat:",string,"Chon","Huy");
	}
	else if(PlayerInfo[playerid][pNMuteTotal] == 4) ShowPlayerDialogEx(playerid,NMUTE,DIALOG_STYLE_LIST,"Mo cam Newbie Chat - Chon hinh phat:","Giam 1 gio","Chon","Huy");
	else if(PlayerInfo[playerid][pNMuteTotal] == 5) ShowPlayerDialogEx(playerid,NMUTE,DIALOG_STYLE_LIST,"Mo cam Newbie Chat - Chon hinh phat:","Giam 1 gio 15 phut","Chon","Huy");
	else if(PlayerInfo[playerid][pNMuteTotal] == 6) ShowPlayerDialogEx(playerid,NMUTE,DIALOG_STYLE_LIST,"Mo cam Newbie Chat - Chon hinh phat:","Giam 1 gio 30 phut","Chon","Huy");
}

stock SendAdvisorMessage(color, const string[])
{
	foreach(new i: Player)
	{
		if(PlayerInfo[i][pAdmin] >= 1 || PlayerInfo[i][pHelper] >= 2 || PlayerInfo[i][pVIPMod] || PlayerInfo[i][pWatchdog] >= 1)
		{
			ChatTrafficProcess(i, color, string, CHAT_STAFF);
		}
	}
}

stock SendDutyAdvisorMessage(color, const string[])
{
	foreach(new i: Player)
	{
		if(PlayerInfo[i][pHelper] >= 2 && GetPVarInt(i, "AdvisorDuty") == 1)
		{
			SendClientMessageEx(i, color, string);
		}
	}
}

CMD:advisors(playerid, params[])
{
    new string[128];
    if(PlayerInfo[playerid][pHelper] >= 1)
    {
        SendClientMessageEx(playerid, COLOR_GRAD1, "Advisor dang online:");
        foreach(new i: Player)
		{
			new tdate[11], thour[9], i_timestamp[3];
			getdate(i_timestamp[0], i_timestamp[1], i_timestamp[2]);
			format(tdate, sizeof(tdate), "%d-%02d-%02d", i_timestamp[0], i_timestamp[1], i_timestamp[2]);
			format(thour, sizeof(thour), "%02d:00:00", gServerHour);

			if(PlayerInfo[i][pHelper] != 0 && PlayerInfo[i][pHelper] <= PlayerInfo[playerid][pHelper])
			{
				if(PlayerInfo[i][pHelper] == 1 && PlayerInfo[i][pAdmin] < 2) {
					format(string, sizeof(string), "** JA: %s	(Yeu cau gio nay: %d | Hom nay: %d)", GetPlayerNameEx(i), ReportHourCount[i], ReportCount[i]);
				}
				if(PlayerInfo[i][pHelper] == 2&&PlayerInfo[i][pAdmin]<2) {
					format(string, sizeof(string), "** GA: %s	(Yeu cau gio nay: %d | Hom nay: %d)", GetPlayerNameEx(i), ReportHourCount[i], ReportCount[i]);
				}
				if(PlayerInfo[i][pHelper] == 3&&PlayerInfo[i][pAdmin]<2) {
					format(string, sizeof(string), "** SA: %s	(Yeu cau gio nay: %d | Hom nay: %d)", GetPlayerNameEx(i), ReportHourCount[i], ReportCount[i]);
				}
				if(PlayerInfo[i][pHelper] >= 4&&PlayerInfo[i][pAdmin]<2) {
					format(string, sizeof(string), "** CA: %s	(Yeu cau gio nay: %d | Hom nay: %d)", GetPlayerNameEx(i), ReportHourCount[i], ReportCount[i]);
				}
				SendClientMessageEx(playerid, COLOR_GRAD2, string);
			}
		}
    }
    else if(PlayerInfo[playerid][pAdmin] >= 2) {
        SendClientMessageEx(playerid, COLOR_GRAD1, "Advisor dang online:");
        foreach(new i: Player)
        {
			if(PlayerInfo[i][pHelper] >= 1) {
				new tdate[11], thour[9], i_timestamp[3];
				getdate(i_timestamp[0], i_timestamp[1], i_timestamp[2]);
				format(tdate, sizeof(tdate), "%d-%02d-%02d", i_timestamp[0], i_timestamp[1], i_timestamp[2]);
				format(thour, sizeof(thour), "%02d:00:00", gServerHour);

				if(PlayerInfo[i][pHelper] == 1&&PlayerInfo[i][pAdmin]<2) {
					format(string, sizeof(string), "** Helper: %s	(Yeu cau gio nay: %d | Hom nay: %d)", GetPlayerNameEx(i), ReportHourCount[i], ReportCount[i]);
				}
				if(PlayerInfo[i][pHelper] == 2&&PlayerInfo[i][pAdmin]<2) {
					if(GetPVarInt(i, "AdvisorDuty") == 1) {
						format(string, sizeof(string), "** Community Advisor: %s (Truc)	(Yeu cau gio nay: %d | Hom nay: %d)", GetPlayerNameEx(i), ReportHourCount[i], ReportCount[i]);
					}
					else {
						format(string, sizeof(string), "** Community Advisor: %s	(Yeu cau gio nay: %d | Hom nay: %d)", GetPlayerNameEx(i), ReportHourCount[i], ReportCount[i]);
					}
				}
				if(PlayerInfo[i][pHelper] == 3&&PlayerInfo[i][pAdmin]<2) {
					if(GetPVarInt(i, "AdvisorDuty") == 1) {
						format(string, sizeof(string), "** Senior Advisor: %s (Truc)	(Yeu cau gio nay: %d | Hom nay: %d)", GetPlayerNameEx(i), ReportHourCount[i], ReportCount[i]);
					}
					else {
						format(string, sizeof(string), "** Senior Advisor: %s	(Yeu cau gio nay: %d | Hom nay: %d)", GetPlayerNameEx(i), ReportHourCount[i], ReportCount[i]);
					}
				}
				if(PlayerInfo[i][pHelper] >= 4&&PlayerInfo[i][pAdmin]<2) {
					if(GetPVarInt(i, "AdvisorDuty") == 1) {
						format(string, sizeof(string), "** Chief Advisor: %s (Truc)	(Yeu cau gio nay: %d | Hom nay: %d)", GetPlayerNameEx(i), ReportHourCount[i], ReportCount[i]);
					}
					else {
						format(string, sizeof(string), "** Chief Advisor: %s	(Yeu cau gio nay: %d | Hom nay: %d)", GetPlayerNameEx(i), ReportHourCount[i], ReportCount[i]);
					}
				}
				SendClientMessageEx(playerid, COLOR_GRAD2, string);
			}
        }
    }
    else {
        SendClientMessageEx(playerid, COLOR_GRAD1, "Can hoi ve cach choi hoac may chu, hay dung /newb.");
        SendClientMessageEx(playerid, COLOR_GRAD1, "Phat hien nguoi choi hoac hoat dong dang ngo, dung /report [id] [reason].");
    }
    return 1;
}

CMD:caduty(playerid, params[])
{
    if(PlayerInfo[playerid][pHelper] >= 2)
	{
        if(GetPVarInt(playerid, "AdvisorDuty") == 1)
		{
            SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da ngung truc Advisor va se khong nhan yeu cau nua.");
            DeletePVar(playerid, "AdvisorDuty");
            Advisors -= 1;
        }
        else
		{
            SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da bat dau truc Advisor va se nhan yeu cau ho tro.");
            SetPVarInt(playerid, "AdvisorDuty", 1);
            Advisors += 1;
        }
    }
    else
	{
        SendClientMessageEx(playerid, COLOR_GRAD1, "   Ban khong phai Advisor!");
    }
    return 1;
}

CMD:nonewbie(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 3 || PlayerInfo[playerid][pHelper] >= 4)
	{
		if (!nonewbie)
		{
			nonewbie = 1;
			SendClientMessageToAllEx(COLOR_GRAD2, "Admin/Advisor da tat kenh Newbie chat!");
		}
		else
		{
			nonewbie = 0;
			SendClientMessageToAllEx(COLOR_GRAD2, "Admin/Advisor da bat kenh Newbie chat!");
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:checkrequestcount(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pHelper] >= 3 || PlayerInfo[playerid][pPR] > 0)
	{
		new string[128], adminname[MAX_PLAYER_NAME], tdate[11];
		if(sscanf(params, "s[24]s[11]", adminname, tdate)) return SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /checkrequestcount [advisor name] [date (YYYY-MM-DD)]");
		new giveplayerid = ReturnUser(adminname);
		if(IsPlayerConnected(giveplayerid))
		{
			mysql_format(MainPipeline, string, sizeof(string), "SELECT SUM(count) FROM `tokens_request` WHERE `playerid` = %d AND `date` = '%s'", GetPlayerSQLId(giveplayerid), tdate);
			mysql_tquery(MainPipeline, string, "QueryCheckCountFinish", "issi", playerid, GetPlayerNameEx(giveplayerid), tdate, 2);
			mysql_format(MainPipeline, string, sizeof(string), "SELECT `count`, `hour` FROM `tokens_request` WHERE `playerid` = %d AND `date` = '%s' ORDER BY `hour` ASC", GetPlayerSQLId(giveplayerid), tdate);
			mysql_tquery(MainPipeline, string, "QueryCheckCountFinish", "issi", playerid, GetPlayerNameEx(giveplayerid), tdate, 3);
		}
		else
		{
			new tmpName[MAX_PLAYER_NAME];
			mysql_escape_string(adminname, tmpName);
			mysql_format(MainPipeline, string, sizeof(string), "SELECT `id`, `Username` FROM `accounts` WHERE `Username` = '%s'", tmpName);
			mysql_tquery(MainPipeline, string, "QueryUsernameCheck", "isi", playerid, tdate, 1);
		}
    }
    return 1;
}

/*CMD:hlban(playerid, params[])
{
	if(IsPlayerConnected(playerid))
	{
		if(PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[playerid][pHelper] >= 1)
		{
			new string[128], giveplayerid;
			if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /hlban [player]");

			if(IsPlayerConnected(giveplayerid))
			{
				if(PlayerInfo[giveplayerid][pHelper] >= 1 || PlayerInfo[giveplayerid][pAdmin] >= 1)
				{
					SendClientMessageEx(playerid, COLOR_GREY, "You can not ban admins/advisors/helpers from the helper channel!");
					return 1;
				}
				if(PlayerInfo[giveplayerid][pHelpMute] == 0)
				{
					PlayerInfo[giveplayerid][pHelpMute] = 1;

					foreach(new n: Player)
					{
						if(PlayerInfo[n][pToggledChats][CHAT_NEWBIE] == 0)
						{
							format(string, sizeof(string), "* %s has been banned from the helper channel by %s.", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid));
							SendClientMessageEx(n, COLOR_JOINHELPERCHAT, string);
						}
					}
					if(PlayerInfo[playerid][pToggledChats][CHAT_NEWBIE] != 0)
					{
						format(string, sizeof(string), "* %s has been banned from the helper channel by %s.", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid));
						SendClientMessageEx(playerid, COLOR_JOINHELPERCHAT, string);
					}
                    PlayerInfo[giveplayerid][pToggledChats][CHAT_NEWBIE] = 1;

					format(string, sizeof(string), "You have been banned from helper channel by %s.", GetPlayerNameEx(playerid));
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, string);
					format(string, sizeof(string), "AdmCmd: %s(%d) was banned from /hl by %s(%d)", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid));
					Log("logs/mute.log", string);
				}
				else
				{
					PlayerInfo[giveplayerid][pHelpMute] = 0;

					foreach(new n: Player)
					{
						if (PlayerInfo[n][pToggledChats][CHAT_NEWBIE] == 0)
						{
							format(string, sizeof(string), "* %s has been unbanned from the helper channel by %s.", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid));
							SendClientMessageEx(n, COLOR_JOINHELPERCHAT, string);
						}
					}
					if(PlayerInfo[playerid][pToggledChats][CHAT_NEWBIE] != 0)
					{
						format(string, sizeof(string), "* %s has been unbanned from the helper channel by %s.", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid));
						SendClientMessageEx(playerid, COLOR_JOINHELPERCHAT, string);
					}

					format(string, sizeof(string), "You have been unbanned from helper channel by %s.", GetPlayerNameEx(playerid));
					SendClientMessageEx(giveplayerid, COLOR_GRAD2, string);
					format(string, sizeof(string), "AdmCmd: %s(%d) was unbanned from /hl by %s(%d)", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid));
					Log("logs/mute.log", string);
				}

			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GRAD1, "You are not authorized to use that command.");
		}
	}
	return 1;
}

CMD:hl(playerid, params[])
{
	if(gPlayerLogged{playerid} == 0) return SendClientMessageEx(playerid, COLOR_GREY, "You're not logged in.");
	if(PlayerInfo[playerid][pTut] == 0) return SendClientMessageEx(playerid, COLOR_GREY, "You can't do that at this time.");
	if((nonewbie) && PlayerInfo[playerid][pAdmin] < 2) return SendClientMessageEx(playerid, COLOR_GRAD2, "The newbie chat channel has been disabled by an administrator!");
	if(PlayerInfo[playerid][pNMute] == 1) return SendClientMessageEx(playerid, COLOR_GREY, "You are muted from the newbie chat channel.");
	if(PlayerInfo[playerid][pToggledChats][CHAT_NEWBIE]) return SendClientMessageEx(playerid, COLOR_GREY, "You have the channel toggled, /tog newbie to re-enable!");

	new string[128];
	if(gettime() < NewbieTimer[playerid])
	{
		format(string, sizeof(string), "You must wait %d seconds before speaking again in this channel.", NewbieTimer[playerid]-gettime());
		SendClientMessageEx(playerid, COLOR_GREY, string);
		return 1;
	}

	if(isnull(params)) return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: (/newb)ie [text]");

	if(PlayerInfo[playerid][pHelper] < 1 && PlayerInfo[playerid][pAdmin] < 1)
	{
		NewbieTimer[playerid] = gettime()+60;
		format(string, sizeof(string), "** Newbie %s: %s", GetPlayerNameEx(playerid), params);
	}
	if(PlayerInfo[playerid][pWatchdog] >= 1)
	{
		NewbieTimer[playerid] = gettime()+30;
		format(string, sizeof(string), "** Watchdog %s: %s", GetPlayerNameEx(playerid), params);
	}
	if(PlayerInfo[playerid][pHelper] == 1 && PlayerInfo[playerid][pAdmin] < 2)
	{
		NewbieTimer[playerid] = gettime()+30;
		format(string, sizeof(string), "** Helper %s: %s", GetPlayerNameEx(playerid), params);
		ReportCount[playerid]++;
		ReportHourCount[playerid]++;
		AddCAReportToken(playerid); // Advisor Tokens
	}
	if(PlayerInfo[playerid][pAdmin] == 1)
	{
		NewbieTimer[playerid] = gettime()+30;
		if(PlayerInfo[playerid][pSMod] == 1) format(string, sizeof(string), "** Senior Moderator %s: %s", GetPlayerNameEx(playerid), params);
		else format(string, sizeof(string), "** Moderator %s: %s", GetPlayerNameEx(playerid), params);
	}
	if(PlayerInfo[playerid][pHelper] == 2 && PlayerInfo[playerid][pAdmin] < 2)
	{
		NewbieTimer[playerid] = gettime()+10;
		format(string, sizeof(string), "** Advisor %s: %s", GetPlayerNameEx(playerid), params);
	}
	if(PlayerInfo[playerid][pHelper] == 3 && PlayerInfo[playerid][pAdmin] < 2)
	{
		NewbieTimer[playerid] = gettime()+10;
		format(string, sizeof(string), "** Senior Advisor %s: %s", GetPlayerNameEx(playerid), params);
	}
	if(PlayerInfo[playerid][pHelper] >= 4 && PlayerInfo[playerid][pAdmin] < 2)
	{
		NewbieTimer[playerid] = gettime()+10;
		format(string, sizeof(string), "** Chief Advisor %s: %s", GetPlayerNameEx(playerid), params);
	}
	if(PlayerInfo[playerid][pAdmin] >= 2) format(string, sizeof(string), "** %s %s: %s", GetAdminRankName(PlayerInfo[playerid][pAdmin]), GetPlayerNameEx(playerid), params);
	foreach(new n: Player)
	{
		ChatTrafficProcess(n, COLOR_HELPERCHAT, string, CHAT_NEWBIE);
	}
	return 1;
}

CMD:joinhelp(playerid, params[])
{
	if(PlayerInfo[playerid][pToggledChats][CHAT_NEWBIE] == 0)
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "You are already in the helper channel!");
		return 1;
	}
	if(gettime() < HlKickTimer[playerid])
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "You have just been kicked, you can not rejoin yet!");
		return 1;
	}
	if(PlayerInfo[playerid][pHelpMute] == 1)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "You are banned from the helper channel.");
		return 1;
	}
	SendClientMessageEx(playerid, COLOR_YELLOW, "You have joined the helper chat, type /hl to ask your question or /leavehelp to leave!");

	foreach(new n : Player)
	{
		if(PlayerInfo[n][pToggledChats][CHAT_NEWBIE] == 0)
		{
			format(szMiscArray, sizeof(szMiscArray), "* %s has joined the helper channel.", GetPlayerNameEx(playerid));
			SendClientMessageEx(n, COLOR_JOINHELPERCHAT, szMiscArray);
		}
	}
	PlayerInfo[playerid][pToggledChats][CHAT_NEWBIE] = 0;
	return 1;
}

CMD:leavehelp(playerid, params[])
{
	if(PlayerInfo[playerid][pToggledChats][CHAT_NEWBIE] == 1)
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "You are not in the helper channel!");
		return 1;
	}

	format(szMiscArray, sizeof(szMiscArray), "* %s has left the helper channel.", GetPlayerNameEx(playerid));
	foreach(new n: Player) ChatTrafficProcess(n, COLOR_JOINHELPERCHAT, szMiscArray, CHAT_NEWBIE);
	PlayerInfo[playerid][pToggledChats][CHAT_NEWBIE] = 1;
	return 1;
}

CMD:hlkick(playerid, params[])
{
	if (PlayerInfo[playerid][pHelper] >= 1 || PlayerInfo[playerid][pAdmin] >= 1){
		new giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /hlkick [player]");
		if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Invalid player specified.");
		if(PlayerInfo[giveplayerid][pToggledChats][CHAT_NEWBIE] == 1) return SendClientMessageEx(playerid, COLOR_WHITE, "That person is not in the helper channel!");
		if(PlayerInfo[giveplayerid][pHelper] >= 1 || PlayerInfo[giveplayerid][pAdmin] >= 2) return SendClientMessageEx(playerid, COLOR_GREY, "You can not kick admins/advisors from the helper channel!");
		new string[128];
		HlKickTimer[giveplayerid] = gettime()+120;
		format(string, sizeof(string), "* %s has been kicked from the helper channel by %s.", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid));
		foreach(new n: Player)
		{
			if(PlayerInfo[playerid][pToggledChats][CHAT_NEWBIE] == 0) {
				SendClientMessageEx(n, COLOR_JOINHELPERCHAT, string);
			}
		}
		PlayerInfo[giveplayerid][pToggledChats][CHAT_NEWBIE] = 1;
	}
	else {
		SendClientMessageEx(playerid, COLOR_GRAD1, "You are not authorized to use that command.");
	}
	return 1;
}*/

CMD:nunmute(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[playerid][pWatchdog] >= 2)
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /nunmute [player]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pNMute] == 1)
			{
				format(string, sizeof(string), "AdmCmd: %s(%d) was unmuted from speaking in /newb by %s.", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid));
				Log("logs/admin.log", string);
				format(string, sizeof(string), "AdmCmd: %s da duoc %s go cam chat /newb.", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid));
				ABroadCast(COLOR_LIGHTRED,string,2);
				PlayerInfo[giveplayerid][pNMute] = 0;
				PlayerInfo[giveplayerid][pNMuteTotal]--;
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_LIGHTRED,"Nguoi do khong bi cam chat /newb!");
			}

		}
	}
	return 1;
}

CMD:nmute(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 2 || PlayerInfo[playerid][pHelper] >= 2 || PlayerInfo[playerid][pSMod] == 1 || PlayerInfo[playerid][pWatchdog] >= 2)
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /nmute [player]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pAdmin] >= 1)
			{
				return SendClientMessageEx(playerid, COLOR_LIGHTRED, "Khong the /nmute Admin");
			}
			if(PlayerInfo[giveplayerid][pNMute] == 0)
			{
			    SetPVarInt(giveplayerid, "UnmuteTime", gettime());
				PlayerInfo[giveplayerid][pNMute] = 1;
				PlayerInfo[giveplayerid][pNMuteTotal] += 1;
				format(string, sizeof(string), "AdmCmd: %s(%d) was muted from speaking in /newb by %s(%d).", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid));
				Log("logs/admin.log", string);
				format(string, sizeof(string), "AdmCmd: %s da bi %s cam chat /newb.", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid));
				ABroadCast(COLOR_LIGHTRED,string,2);
				if(PlayerInfo[giveplayerid][pNMuteTotal] > 6)
				{
					PlayerInfo[giveplayerid][pNMuteTotal] = 0;
					CreateBan(playerid, PlayerInfo[giveplayerid][pId], giveplayerid, PlayerInfo[giveplayerid][pIP], "Excessive Newb Mutes", 10);
				}

				if(PlayerInfo[playerid][pAdmin] == 1)
				{
					format(string, sizeof(string), "AdmCmd: %s da bi Admin cam chat /newb.", GetPlayerNameEx(giveplayerid));
					SendDutyAdvisorMessage(TEAM_AZTECAS_COLOR, string);
					SendClientMessageEx(giveplayerid, COLOR_LIGHTRED, "Ban vua bi Admin cam chat Newbie Chat [/newb].");
				}
				else
				{
					format(string, sizeof(string), "AdmCmd: %s da bi %s cam chat /newb.", GetPlayerNameEx(giveplayerid), GetPlayerNameEx(playerid));
					SendDutyAdvisorMessage(TEAM_AZTECAS_COLOR, string);
					SendClientMessageEx(giveplayerid, COLOR_LIGHTRED, "Ban bi %s cam chat tren kenh nguoi moi (/newb).", GetPlayerNameEx(playerid));
				}

				SendClientMessageEx(giveplayerid, COLOR_LIGHTRED, "Kenh nguoi moi chi ho tro cau hoi ve tinh nang va may chu. Khong dung vao muc dich khac, tru khi Admin cho phep.");
				SendClientMessageEx(giveplayerid, COLOR_LIGHTRED, "Muon go cam chat, ban phai nop phat hoac ngoi tu. Tai pham se bi phat nang hon. Neu bi xu ly nham, hay lien he Senior Admin.");

				SendClientMessageToAllEx(COLOR_LIGHTRED, "AdmCmd: %s vua bi cam Newbie Chat [/newb] vi lam dung.", GetPlayerNameEx(giveplayerid));
			}
			else
			{
				if(PlayerInfo[playerid][pAdmin] >= 2)
				{
					ShowNMuteFine(giveplayerid);
					SendClientMessageEx(playerid, COLOR_LIGHTRED, "Ban da de nghi go cam /newb cho %s.", GetPlayerNameEx(giveplayerid));
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi do dang bi cam chat. Advisor khong duoc go cam chat kenh nguoi moi.");
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

CMD:makeadvisor(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 1337 || PlayerInfo[playerid][pPR] > 0 || PlayerInfo[playerid][pHelper] >= 3)
	{
		new string[128], giveplayerid, level;
		if(sscanf(params, "ud", giveplayerid, level)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /makeadvisor [player] [level(1-4)]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pAdmin] > 1)
			{
				SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the bo nhiem Admin lam Advisor!");
				return 1;
			}
			if(PlayerInfo[playerid][pHelper] == 3 && level > 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chi duoc bo nhiem den Helper!");
			if(PlayerInfo[playerid][pHelper] == 4 && level > 2) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chi duoc bo nhiem den Helper/Community Advisor!");

			if(PlayerInfo[giveplayerid][pHelper] < level && PlayerInfo[giveplayerid][pHelper] >= PlayerInfo[playerid][pHelper] > 2) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the doi chuc vu cua nguoi ngang cap voi ban!");

			if(IsStaffBanned(giveplayerid)) 
				return SendClientMessage(playerid, COLOR_WHITE, "Nguoi do dang bi cam lam staff.");

			PlayerInfo[giveplayerid][pHelper] = level;
			switch(level)
			{
				case 1:
				{
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "Ban duoc %s bo nhiem lam Helper", GetPlayerNameEx(playerid));
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cap Helper cho %s", GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "%s(%d) has been made a Helper by %s(%d)", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid));
					Log("logs/admin.log", string);
				}
				case 2:
				{
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "Ban duoc %s bo nhiem lam Community Advisor", GetPlayerNameEx(playerid));
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da cap Community Advisor cho %s", GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "%s(%d) has been made a Community Advisor by %s(%d)", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid));
					Log("logs/admin.log", string);
				}
				case 3:
				{
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "Ban duoc %s thang chuc Senior Advisor", GetPlayerNameEx(playerid));
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da thang chuc %s len Senior Advisor", GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "%s(%d) has been made a Senior Advisor by %s(%d)", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid));
					Log("logs/admin.log", string);
				}
				case 4:
				{
					SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "Ban duoc %s thang chuc Chief Advisor", GetPlayerNameEx(playerid));
					SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da thang chuc %s len Chief Advisor", GetPlayerNameEx(giveplayerid));
					format(string, sizeof(string), "%s(%d) has been made a Chief Advisor by %s(%d)", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid));
					Log("logs/admin.log", string);
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

CMD:takeadvisor(playerid, params[])
{
	if (PlayerInfo[playerid][pAdmin] >= 1337 || PlayerInfo[playerid][pHelper] >= 3 || PlayerInfo[playerid][pPR] > 0)
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /takeadvisor [player]");

		if(IsPlayerConnected(giveplayerid))
		{
		    if(PlayerInfo[playerid][pHelper] == 3 && PlayerInfo[giveplayerid][pHelper] != 1) {
		        SendClientMessageEx(playerid, COLOR_GREY, "Ban chi duoc bai nhiem Helper.");
		        return 1;
		    }
			if(PlayerInfo[giveplayerid][pHelper] != 0)
			{
				if(GetPVarType(playerid, "AdvisorDuty"))
				{
					DeletePVar(playerid, "AdvisorDuty");
					Advisors -= 1;
				}
				PlayerInfo[giveplayerid][pHelper] = 0;
				SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "%s da loai ban khoi doi ngu Advisor.", GetPlayerNameEx(playerid));
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Da go Advisor cua %s.", GetPlayerNameEx(giveplayerid));
				format(string, sizeof(string), "%s(%d) has had their advisor removed by %s(%d)", GetPlayerNameEx(giveplayerid), PlayerInfo[giveplayerid][pId], GetPlayerNameEx(playerid), PlayerInfo[playerid][pId]);
				Log("logs/admin.log", string);

			}

		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:requesthelp(playerid, params[])
{
	if(Advisors < 1)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "   Chua co Advisor dang truc, hay thu lai sau!");
		return 1;
	}
	if(isnull(params))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /requesthelp [reason]");
		return 1;
	}

	new string[128];
	if(PlayerInfo[playerid][pRHMutes] >= 4 || PlayerInfo[playerid][pRHMuteTime] > 0)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Ban dang bi cam gui yeu cau ho tro.");
		return 1;
	}
	if(JustReported[playerid] > 0)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Hay cho 10 giay truoc khi gui yeu cau tiep!");
		return 1;
	}
	JustReported[playerid]=10;
	format(string, sizeof(string), "** %s (%i) can ho tro, ly do: %s. (dung /accepthelp %i)", GetPlayerNameEx(playerid), playerid, params, playerid);
	SendDutyAdvisorMessage(TEAM_AZTECAS_COLOR, string);
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da gui yeu cau den Advisor, hay cho phan hoi.");
	SetPVarInt( playerid, "COMMUNITY_ADVISOR_REQUEST", 1 );
	SetPVarInt( playerid, "HelpTime", 5);
	SetPVarString( playerid, "HelpReason", params);
	SetTimerEx( "HelpTimer", 60000, false, "d", playerid);
	return 1;
}

CMD:showrequests(playerid, params[])
{
	if(PlayerInfo[playerid][pHelper] >= 2 || PlayerInfo[playerid][pPR] || PlayerInfo[playerid][pAdmin] >= 2)
	{
		new reason[64];
		SendClientMessageEx(playerid, COLOR_GREEN, "____________________ YEU CAU HO TRO _____________________");
		foreach(new i: Player)
		{
			if(GetPVarInt(i, "COMMUNITY_ADVISOR_REQUEST"))
			{
				GetPVarString(i, "HelpReason", reason, 64);
				SendClientMessageEx(playerid, COLOR_REPORT, "%s  | ID: %i | Ly do: %s | Het han sau: %i phut.", GetPlayerNameEx(i), i, reason, GetPVarInt(i, "HelpTime"));
			}
		}
		SendClientMessageEx(playerid, COLOR_GREEN, "_________________________________________________________");
	}
	return 1;
}

CMD:rhmute(playerid, params[])
{
	if (PlayerInfo[playerid][pHelper] >= 2)
	{
		new string[128], giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /rhmute [player]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pRHMuteTime] == 0)
			{
			    if(PlayerInfo[giveplayerid][pRHMutes] == 0)
			    {
  					PlayerInfo[giveplayerid][pRHMutes] = 1;
					format(string, sizeof(string), "*** %s da canh bao %s lan dau vi lam dung yeu cau ho tro", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					SendAdvisorMessage(COLOR_COMBINEDCHAT, string);

					ShowPlayerDialogEx(giveplayerid, 7954, DIALOG_STYLE_MSGBOX, "Canh bao lam dung ho tro", "Advisor canh bao ban khong duoc lam dung /requesthelp.\n\nTai pham voi /requesthelp co the bi tam cam /requesthelp hoac mat han quyen nay.", "Tiep", "");

					format(string, sizeof(string), "AdmCmd: %s(%d) has given %s(%d) their first warning about help request abuse", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid));
					Log("logs/mute.log", string);

			    }
			    else if(PlayerInfo[giveplayerid][pRHMutes] == 1)
			    {
  					PlayerInfo[giveplayerid][pRHMutes] = 2;
					PlayerInfo[giveplayerid][pRHMuteTime] = 30*60;
					format(string, sizeof(string), "*** %s da tam cam %s dung /requesthelp", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					SendAdvisorMessage(COLOR_COMBINEDCHAT, string);

					ShowPlayerDialogEx(giveplayerid, 7954, DIALOG_STYLE_MSGBOX, "Tam cam /requesthelp", "Ban bi tam cam /requesthelp\n\nDay la lan dau bi cam yeu cau ho tro, ban khong the dung /requesthelp trong 30 phut.\n\nBi cam them hai lan se mat han quyen dung lenh.", "Tiep", "");

					format(string, sizeof(string), "AdmCmd: %s(d) was temporarily blocked from /requesthelp by %s(%d)", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid));
					Log("logs/mute.log", string);
			    }
			    else if(PlayerInfo[giveplayerid][pRHMutes] == 2)
			    {
  					PlayerInfo[giveplayerid][pRHMutes] = 3;
					PlayerInfo[giveplayerid][pRHMuteTime] = 90*60;
					format(string, sizeof(string), "*** %s da tam cam %s dung /requesthelp", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					SendAdvisorMessage(COLOR_COMBINEDCHAT, string);

					ShowPlayerDialogEx(giveplayerid, 7954, DIALOG_STYLE_MSGBOX, "Tam cam /requesthelp", "Ban bi tam cam /requesthelp\n\nDay la lan thu hai bi cam yeu cau ho tro, ban khong the dung /requesthelp trong 1 gio 30 phut.\n\nBi cam them mot lan se mat han quyen dung lenh.", "Tiep", "");

					format(string, sizeof(string), "AdmCmd: %s(%d) was temporarily blocked from /requesthelp by %s(%d)", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid));
					Log("logs/mute.log", string);
			    }
				else if(PlayerInfo[giveplayerid][pRHMutes] == 3)
			    {
  					PlayerInfo[giveplayerid][pRHMutes] = 4;
					format(string, sizeof(string), "*** %s da cam vinh vien %s dung /requesthelp", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
					SendAdvisorMessage(COLOR_COMBINEDCHAT, string);

					ShowPlayerDialogEx(giveplayerid,7954,DIALOG_STYLE_MSGBOX, "Cam vinh vien /requesthelp", "Ban bi cam vinh vien /requesthelp.\n\nDung /report de lien he Admin neu muon khieu nai.", "Tiep", "");

					format(string, sizeof(string), "AdmCmd: %s(%d) was permanently blocked from /requesthelp by %s(%d)", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid));
					Log("logs/mute.log", string);
			    }
				DeletePVar(giveplayerid, "COMMUNITY_ADVISOR_REQUEST");
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do da bi cam /requesthelp.");
			}
		}
		else return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:rhmutereset(playerid, params[])
{
	if (PlayerInfo[playerid][pHelper] >= 2)
	{
		new string[128], giveplayerid, reason[64];
		if(sscanf(params, "us[64]", giveplayerid, reason)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /rhmutereset [player] [reason]");

		if(IsPlayerConnected(giveplayerid))
		{
			if(PlayerInfo[giveplayerid][pRHMutes] >= 2)
			{
				PlayerInfo[giveplayerid][pRHMutes]--;
				PlayerInfo[giveplayerid][pRHMuteTime] = 0;
				format(string, sizeof(string), "*** %s da go cam yeu cau ho tro cho %s, ly do: %s", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), reason);
				SendAdvisorMessage(COLOR_COMBINEDCHAT, string);
				SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Ban da duoc go cam yeu cau ho tro va co the su dung lai he thong.");
				SendClientMessageEx(giveplayerid, COLOR_GRAD2, "Chung toi xin loi ve sai sot va bat tien da gay ra.");
				format(string, sizeof(string), "AdmCmd: %s(%d) was unblocked from /requesthelp by %s(%d), reason: %s", GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), reason);
				Log("logs/mute.log", string);
			}
			else
			{
			    SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi do khong bi cam gui yeu cau ho tro!");
			}

		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	}
	return 1;
}

CMD:findnewb(playerid, params[]) {

	if(PlayerInfo[playerid][pHelper] < 2) {
        SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai Advisor.");
	}
	else if(GetPVarInt(playerid, "AdvisorDuty") == 0) {
	    SendClientMessageEx(playerid, COLOR_GREY, "Ban chua truc Advisor.");
	}
	else {
	    new Float: Pos[3][2], i[2], vw[2];
	    if(!GetPVarType(playerid, "HelpingSomeone")) {
     		foreach(new x: Player) {

				if(PlayerInfo[x][pLevel] == 1 && PlayerInfo[x][pHelpedBefore] == 0 && PlayerInfo[x][pAdmin] == 0 && PlayerInfo[x][pId] != PlayerInfo[playerid][pId]) {
					GetPlayerPos(x, Pos[0][0], Pos[1][0], Pos[2][0]);
					GetPlayerPos(playerid, Pos[0][1], Pos[1][1], Pos[2][1]);
					vw[0] = GetPlayerVirtualWorld(x);
					i[0] = GetPlayerInterior(x);
					vw[1] = GetPlayerVirtualWorld(playerid);
					i[1] = GetPlayerInterior(playerid);

					SetPVarFloat(playerid, "AdvisorLastx", Pos[0][1]);
					SetPVarFloat(playerid, "AdvisorLasty", Pos[1][1]);
					SetPVarFloat(playerid, "AdvisorLastz", Pos[2][1]);
					SetPVarInt(playerid, "AdvisorLastInt", i[1]);
					SetPVarInt(playerid, "AdvisorLastVW", vw[1]);

					SetPlayerVirtualWorld(playerid, vw[0]);
					SetPlayerInterior(playerid, i[0]);
					SetPlayerPos(playerid, Pos[0][0], Pos[1][0]+2, Pos[2][0]);
					PlayerInfo[x][pHelpedBefore] = 1;
					SetPVarInt(playerid, "HelpingSomeone", 1);
					SetPlayerHealth(playerid, 999999);
					ShowPlayerDialogEx(x, 0, DIALOG_STYLE_MSGBOX, "Thong bao Advisor", "Mot Advisor vua dich chuyen den ban. Hay hoi ho nhung dieu ban can ho tro ve Next Generation Gaming.", "Dong", "");
					if(i[0] > 0 || vw[0] > 0) Player_StreamPrep(playerid, Pos[0][0], Pos[1][0], Pos[2][0], FREEZE_TIME);
					SendClientMessageEx(playerid, COLOR_WHITE, "Ban da den cho nguoi moi %s, dung lai lenh de quay ve.", GetPlayerNameEx(x));
					break;
				}
			}
		}
		else
		{
		    DeletePVar(playerid, "HelpingSomeone");
			SetHealth(playerid, 100);
			SetPlayerPos(playerid, GetPVarFloat(playerid, "AdvisorLastx"), GetPVarFloat(playerid, "AdvisorLasty"), GetPVarFloat(playerid, "AdvisorLastz"));
			SetPlayerVirtualWorld(playerid, GetPVarInt(playerid, "AdvisorLastVW"));
			SetPlayerInterior(playerid, GetPVarInt(playerid, "AdvisorLastInt"));
			if(GetPVarInt(playerid, "AdvisorLastInt") > 0 || GetPVarInt(playerid, "AdvisorLastVW") > 0) Player_StreamPrep(playerid, GetPVarFloat(playerid, "AdvisorLastx"), GetPVarFloat(playerid, "AdvisorLasty"), GetPVarFloat(playerid, "AdvisorLastz"), FREEZE_TIME);
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da quay ve vi tri truoc do.");
		}
	}
	return 1;
}

CMD:accepthelp(playerid, params[])
{
    if(PlayerInfo[playerid][pHelper] < 2) {
        SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai Advisor.");
	}
	else if(HelpingNewbie[playerid] != INVALID_PLAYER_ID) {
	    SendClientMessageEx(playerid, COLOR_GREY, "Ban dang ho tro nguoi khac.");
	}
	else if(GetPVarInt(playerid, "AdvisorDuty") == 0) {
	    SendClientMessageEx(playerid, COLOR_GREY, "Ban chua truc Advisor.");
	}
	else {

		new Player, string[128], Float:health, Float:armor;

		if(sscanf(params, "u", Player)) {
			SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /accepthelp [PlayerID]");
		}
		else if(Player == playerid) {
		    SendClientMessageEx(playerid, COLOR_GREY, "Khong the nhan yeu cau ho tro cua chinh minh.");
		}
		else if(!IsPlayerConnected(Player)) {
			SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
		}
		else if(GetPVarInt(Player, "COMMUNITY_ADVISOR_REQUEST") == 0) {
			SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong can ho tro.");
		}
		else {

		    format(string, sizeof(string), "* %s da nhan yeu cau ho tro cua %s.",GetPlayerNameEx(playerid), GetPlayerNameEx(Player));
			SendDutyAdvisorMessage(TEAM_AZTECAS_COLOR, string);
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Da nhan yeu cau cua %s. Ho tro xong, dung /finishhelp de quay ve.",GetPlayerNameEx(Player));
			SendClientMessageEx(Player, COLOR_LIGHTBLUE, "* Advisor %s da nhan yeu cau ho tro cua ban.",GetPlayerNameEx(playerid));
			PlayerInfo[playerid][pAcceptedHelp]++;
			ReportCount[playerid]++;
			ReportHourCount[playerid]++;
			new Float: x, Float: y, Float: z, Float: r, i, vw;
			vw = GetPlayerVirtualWorld(playerid);
			i = GetPlayerInterior(playerid);
			GetPlayerPos(playerid, x, y, z);
			GetPlayerFacingAngle(playerid, r);
			SetPVarFloat(playerid, "AdvisorLastx", x);
			SetPVarFloat(playerid, "AdvisorLasty", y);
			SetPVarFloat(playerid, "AdvisorLastz", z);
			SetPVarFloat(playerid, "AdvisorLastr", r);
			SetPVarInt(playerid, "AdvisorLastInt", i);
			SetPVarInt(playerid, "AdvisorLastVW", vw);
			GetPlayerPos(Player, x, y, z);
			vw = GetPlayerVirtualWorld(Player);
			i = GetPlayerInterior(Player);
			SetPlayerPos(playerid, x, y+2, z+0.75);
			SetPlayerVirtualWorld(playerid, vw);
			SetPlayerInterior(playerid, i);
			GetHealth(playerid,health);
			SetPVarFloat(playerid, "pPreGodHealth", health);
			GetArmour(playerid,armor);
			SetPVarFloat(playerid, "pPreGodArmor", armor);
			SetHealth(playerid, 0x7FB00000);
		    SetArmour(playerid, 0x7FB00000);
		    SetPVarInt(playerid, "pGodMode", 1);
			if(i > 0 || vw > 0) Player_StreamPrep(playerid, x, y, z, 6000);
			HelpingNewbie[playerid] = Player;
			AddCAReportToken(playerid); // Advisor Tokens
			DeletePVar(Player, "COMMUNITY_ADVISOR_REQUEST");
			DeletePVar(Player, "HelpTime");
			return 1;

		}
	}
	return 1;
}

CMD:finishhelp(playerid, params[])
{
	if(HelpingNewbie[playerid] != INVALID_PLAYER_ID)
	{
		new string[128], Float:health, Float:armor;
		format(string, sizeof(string), "* %s da hoan tat ho tro %s.",GetPlayerNameEx(playerid), GetPlayerNameEx(HelpingNewbie[playerid]));
		SendDutyAdvisorMessage(TEAM_AZTECAS_COLOR, string);
		SetPlayerPos(playerid, GetPVarFloat(playerid, "AdvisorLastx"), GetPVarFloat(playerid, "AdvisorLasty"), GetPVarFloat(playerid, "AdvisorLastz"));
		SetPlayerVirtualWorld(playerid, GetPVarInt(playerid, "AdvisorLastVW"));
		SetPlayerInterior(playerid, GetPVarInt(playerid, "AdvisorLastInt"));
		DeletePVar(playerid, "pGodMode");
		health = GetPVarFloat(playerid, "pPreGodHealth");
		SetHealth(playerid,health);
		armor = GetPVarFloat(playerid, "pPreGodArmor");
		if(armor > 0) {
			SetArmour(playerid,armor);
		}
		else
		{
			RemoveArmor(playerid);
		}
		DeletePVar(playerid, "pPreGodHealth");
		DeletePVar(playerid, "pPreGodArmor");
		if(GetPVarType(playerid, "BusinessesID")) DeletePVar(playerid, "BusinessesID");
		if(GetPVarInt(playerid, "AdvisorLastInt") > 0 || GetPVarInt(playerid, "AdvisorLastVW") > 0) Player_StreamPrep(playerid, GetPVarFloat(playerid, "AdvisorLastx"), GetPVarFloat(playerid, "AdvisorLasty"), GetPVarFloat(playerid, "AdvisorLastz"), FREEZE_TIME);
		HelpingNewbie[playerid] = INVALID_PLAYER_ID;
		return 1;
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GREY, "   Ban khong dang ho tro ai!");
		return 1;
	}
}

CMD:togca(playerid, params[])
{
	return ToggleAccountSetting(playerid, CHAT_ADVISOR);
}

CMD:ca(playerid, params[])
{
	if(PlayerInfo[playerid][pJailTime] && strfind(PlayerInfo[playerid][pPrisonReason], "[OOC]", true) != -1) return SendClientMessageEx(playerid, COLOR_GREY, "Tu nhan OOC chi duoc noi trong /b");
	if(PlayerInfo[playerid][pHelper] < 1 && PlayerInfo[playerid][pAdmin] < 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay!");
	if(PlayerInfo[playerid][pToggledChats][CHAT_ADVISOR] == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban da tat chat Advisor, dung /tog advisor hoac /settings de bat lai.");
	if(isnull(params)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /ca [text]");
	if(strlen(params) >= 128)  return SendClientMessageEx(playerid, COLOR_GREY, "Noi dung qua dai.");
	szMiscArray[0] = 0;

	format(szMiscArray, sizeof(szMiscArray), "- %s %s: %s", GetStaffRank(playerid), GetPlayerNameEx(playerid), params);
	foreach(new i : Player)
	{
		if((PlayerInfo[i][pHelper] >= 1 || PlayerInfo[i][pAdmin] >= 2))
		{
			ChatTrafficProcess(i, 0x5288f3FF, szMiscArray, CHAT_ADVISOR);
		}
	}
	return 1;
}
