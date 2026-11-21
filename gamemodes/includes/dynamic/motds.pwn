/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

					Dynamic MOTD System

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

CMD:motd(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 1337)
    {
		if(isnull(params)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /motd [message]");
		new string[128];
    	format(string, sizeof(string), "AdmCmd: %s da doi MOTD chung thanh: %s.", GetPlayerNameEx(playerid), params);
		ABroadCast( COLOR_LIGHTRED, string, 4);
		format(GlobalMOTD, sizeof(GlobalMOTD), "%s", params);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da doi MOTD chung.");
		g_mysql_SaveMOTD();
	}
	return 1;
}

CMD:amotd(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 1337)
    {
		if(isnull(params)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /amotd [message]");
		new string[128];
		format(AdminMOTD, sizeof(AdminMOTD), "%s", params);
		format(string, sizeof(string), "AdmCmd: %s da doi MOTD Admin thanh: %s.", GetPlayerNameEx(playerid), params);
		ABroadCast( COLOR_LIGHTRED, string, 4);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da doi MOTD Admin.");
		g_mysql_SaveMOTD();
		//IRC_SetChannelTopic(BotID[0], IRC_CHANNEL_ADMIN, AdminMOTD);
	}
	return 1;
}

CMD:vipmotd(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 1337)
    {
		if(isnull(params)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /vipmotd [message]");
		new string[128];
		format(VIPMOTD, sizeof(VIPMOTD), "%s", params);
		format(string, sizeof(string), "AdmCmd: %s da doi MOTD VIP thanh: %s.", GetPlayerNameEx(playerid), params);
		ABroadCast( COLOR_LIGHTRED, string, 4);
		SendClientMessageEx(playerid, COLOR_WHITE, "Da doi MOTD VIP.");
		g_mysql_SaveMOTD();
	}
	return 1;
}

CMD:advisormotd(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pHelper] >= 4 || PlayerInfo[playerid][pPR] > 0)
    {
		if(isnull(params)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /advisormotd [message]");
		new string[128];
		format(CAMOTD, sizeof(CAMOTD), "%s", params);
		if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pPR] > 0)
		{
			format(string, sizeof(string), "AdmCmd: %s da doi MOTD Advisor thanh: %s.", GetPlayerNameEx(playerid), params);
			ABroadCast( COLOR_LIGHTRED, string, 4);
		}
		else if(PlayerInfo[playerid][pHelper] >= 4)
		{
		    format(string, sizeof(string), "CACmd: %s da doi MOTD Advisor thanh: %s.", GetPlayerNameEx(playerid), params);
			CBroadCast( COLOR_YELLOW, string, 2);
		}
		SendClientMessageEx(playerid, COLOR_WHITE, "Da doi MOTD Advisor.");
		g_mysql_SaveMOTD();
	}
	return 1;
}

CMD:pmotd(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] >= 99999 || PlayerInfo[playerid][pShopTech] >= 3 || PlayerInfo[playerid][pPR] >= 2)
    {
		if(isnull(params)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /pmotd [message/off]");
		new string[128];
		if(strcmp(params, "off", true) == 0)
		{
		    format(pMOTD, sizeof(pMOTD), "");
		    format(string, sizeof(string), "AdmCmd: %s da tat MOTD chung", GetPlayerNameEx(playerid));
			ABroadCast( COLOR_LIGHTRED, string, 4);

			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi pMOTD.");
			g_mysql_SaveMOTD();
			return 1;
		}
		format(pMOTD, sizeof(pMOTD), "%s", params);

		format(string, sizeof(string), "AdmCmd: %s da doi MOTD chung thanh: %s.", GetPlayerNameEx(playerid), params);
		ABroadCast( COLOR_LIGHTRED, string, 4);

		SendClientMessageEx(playerid, COLOR_WHITE, "Da doi pMOTD.");
		g_mysql_SaveMOTD();
	}
	return 1;
}

CMD:gmotd(playerid, params[])
{
	new 
		iGroupID = PlayerInfo[playerid][pLeader],
		string[128],
		iSlot;

	if (0 <= iGroupID < MAX_GROUPS) {
		if(sscanf(params, "ds[128]", iSlot, string)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /gmotd [motd slot] [message]");
		if(strlen(string) > 128) return SendClientMessageEx( playerid, COLOR_GRAD1, "MOTD qua dai, khong duoc vuot qua 128 ky tu." );
		if (1 <= iSlot <= 3) {
		    strmid(gMOTD[iGroupID][iSlot-1], string, 0, strlen(string), 128);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi MOTD to chuc.");
			SaveGroup(iGroupID);
			format(string,sizeof(string),"%s (%d) has changed MOTD for %s to: %s in slot %i", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), gMOTD[iGroupID][iSlot-1], string, iSlot);
			GroupLog(iGroupID, string);
		} else SendClientMessageEx(playerid, COLOR_GREY, "O duoc chon khong hop le.");
	} else SendClientMessageEx(playerid, COLOR_GREY, "Chi lanh dao to chuc duoc dung lenh nay.");
	return 1;
}

CMD:prisonermotd(playerid, params[])
{
	new 
		iGroupID = PlayerInfo[playerid][pLeader],
		string[128],
		iSlot;

	if(!IsADocGuard(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban can la DOC Guard de dung lenh nay.");

	if (0 <= iGroupID < MAX_GROUPS) {
		if(sscanf(params, "ds[128]", iSlot, string)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /prisonermotd [motd slot] [message]");
		if(strlen(string) > 128) return SendClientMessageEx( playerid, COLOR_GRAD1, "MOTD qua dai, khong duoc vuot qua 128 ky tu." );
		if (1 <= iSlot <= 3) {
		    strmid(prisonerMOTD[iSlot-1], string, 0, strlen(string), 128);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da doi MOTD tu nhan.");
			g_mysql_SaveMOTD();
			format(string,sizeof(string),"%s (%d) has changed the prisoner MOTD to: %s in slot %i", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), string, iSlot);
			GroupLog(iGroupID, string);
		} else SendClientMessageEx(playerid, COLOR_GREY, "O duoc chon khong hop le.");
	} else SendClientMessageEx(playerid, COLOR_GREY, "Chi lanh dao to chuc duoc dung lenh nay.");
	return 1;
}

CMD:viewmotd(playerid, params[])
{
	new string[128], option[16];
	if(sscanf(params, "s[16]", option)) 
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /viewmotd [option]");
		strcat(string, "Tuy chon: global, player");
		if(PlayerInfo[playerid][pDonateRank] >= 1) strcat(string, ", vip");
		if(PlayerInfo[playerid][pMember] != INVALID_GROUP_ID) strcat(string, ", group");
		if(PlayerInfo[playerid][pHelper] >= 1) strcat(string, ", advisor");
		if(PlayerInfo[playerid][pAdmin] > 1) strcat(string, ", admin");
		if(strfind(PlayerInfo[playerid][pPrisonReason], "[IC]", true) != -1 || IsADocGuard(playerid)) strcat(string, ", prisoner");
		return SendClientMessageEx(playerid, COLOR_WHITE, string);
	}
	if(strcmp(option, "global", true) == 0) return SendClientMessageEx(playerid, COLOR_YELLOW, GlobalMOTD);
	if(strcmp(option, "player", true) == 0) return SendClientMessageEx(playerid, COLOR_YELLOW, pMOTD);
	if(strcmp(option, "vip", true) == 0 && PlayerInfo[playerid][pDonateRank] >= 1) return SendClientMessageEx(playerid, COLOR_VIP, VIPMOTD);
	if(strcmp(option, "group", true) == 0 && PlayerInfo[playerid][pMember] != INVALID_GROUP_ID)
	{
		for(new i = 0; i < 3; i++)
		{
			SendClientMessageEx(playerid, arrGroupData[PlayerInfo[playerid][pMember]][g_hDutyColour] * 256 + 255, gMOTD[PlayerInfo[playerid][pMember]][i]);
		}
	}
	if(strcmp(option, "advisor", true) == 0 && PlayerInfo[playerid][pHelper] >= 1) return SendClientMessageEx(playerid, TEAM_AZTECAS_COLOR, CAMOTD);
	if(strcmp(option, "admin", true) == 0 && PlayerInfo[playerid][pAdmin] > 1) return SendClientMessageEx(playerid, COLOR_YELLOW, AdminMOTD);
	if(strcmp(option, "prisoner", true) == 0 && strfind(PlayerInfo[playerid][pPrisonReason], "[IC]", true) != -1 || strcmp(option, "prisoner", true) == 0 && IsADocGuard(playerid))
	{
		for(new i = 0; i < 3; i++)
		{
			SendClientMessageEx(playerid, COLOR_ORANGE, prisonerMOTD[i]);
		}
	}
	return 1;
}
