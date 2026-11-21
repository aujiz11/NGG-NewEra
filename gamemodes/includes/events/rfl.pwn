/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

					Relay For Life Event

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

stock CountRFLTeams()
{
	new var;
	for(new i = 0; i < MAX_RFLTEAMS; i++)
	{
		if(RFLInfo[i][RFLused] != 0)
		{
			var++;
		}
	}
	return var;
}

forward RFLCheckpointu(playerid);
public RFLCheckpointu(playerid)
{
	SetPlayerCheckpoint(playerid, EventRCPX[ConfigEventCPId[playerid]], EventRCPY[ConfigEventCPId[playerid]], EventRCPZ[ConfigEventCPId[playerid]], EventRCPS[ConfigEventCPId[playerid]]);
}

forward WateringStation(playerid);
public WateringStation(playerid)
{
    if(GetPVarInt(playerid, "EventToken") == 1 && GetPVarInt(playerid, "InWaterStationRCP") == 1)
	{
	    if(PlayerInfo[playerid][pHydration] < 100) {
	    	PlayerInfo[playerid][pHydration] += 4;
		} else {
			KillTimer(GetPVarInt(playerid, "WSRCPTimerId"));
	    	SetPVarInt(playerid, "WSRCPTimerId", 0);
     		SetPVarInt(playerid, "InWaterStationRCP", 0);
     		RCPIdCurrent[playerid]++;
     		if(EventRCPT[RCPIdCurrent[playerid]] == 1) {
	    	    DisablePlayerCheckpoint(playerid);
				SetPlayerCheckpoint(playerid, EventRCPX[RCPIdCurrent[playerid]], EventRCPY[RCPIdCurrent[playerid]], EventRCPZ[RCPIdCurrent[playerid]], EventRCPS[RCPIdCurrent[playerid]]);
			}
			else if(EventRCPT[RCPIdCurrent[playerid]] == 4) {
		   		DisablePlayerCheckpoint(playerid);
		    	SetPlayerCheckpoint(playerid, EventRCPX[RCPIdCurrent[playerid]], EventRCPY[RCPIdCurrent[playerid]], EventRCPZ[RCPIdCurrent[playerid]], EventRCPS[RCPIdCurrent[playerid]]);
			} else {
			    DisablePlayerCheckpoint(playerid);
			    SetPlayerCheckpoint(playerid, EventRCPX[RCPIdCurrent[playerid]], EventRCPY[RCPIdCurrent[playerid]], EventRCPZ[RCPIdCurrent[playerid]], EventRCPS[RCPIdCurrent[playerid]]);
			}
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da uong du nuoc, co the tiep tuc den checkpoint ke tiep.");
		}
	} else {
        KillTimer(GetPVarInt(playerid, "WSRCPTimerId"));
	}
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;	
	szMiscArray[0] = 0;
	switch(dialogid)
	{
		case DIALOG_RFL_SEL:
		{
			if(response)
			{
				if(listitem == 0) {
					mysql_tquery(MainPipeline, "SELECT * FROM `rflteams` WHERE `used` > 0 ORDER BY `laps` DESC LIMIT 15;", "OnRFLPScore", "ii", playerid, 1);
				}
				else if(listitem == 1) {
					mysql_tquery(MainPipeline, "SELECT `Username`, `RacePlayerLaps` FROM `accounts` WHERE `RacePlayerLaps` > 0 ORDER BY `RacePlayerLaps` DESC LIMIT 25;", "OnRFLPScore", "ii", playerid, 2);
				}
			}
			return 1;
		}
		case DIALOG_RFL_PLAYERS:
		{
			if(response)
			{
				return 1;
			}
			else
			{
				return 1;
			}
		}
		case DIALOG_RFL_TEAMS:
		{
			new temp = GetPVarInt(playerid, "rflTemp");
			if(response)
			{
				if(temp > 0) {
					mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "SELECT * FROM `rflteams` WHERE `used` > 0 ORDER BY `laps` DESC LIMIT %d , 15;", temp);
					mysql_tquery(MainPipeline, szMiscArray, "OnRFLPScore", "ii", playerid, 1);
				}
			}
			else
			{
				DeletePVar(playerid, "rflTemp");
				return 1;
			}	

		}
	}
	return 0;
}

// Relay For Life
CMD:setlapcount(playerid, params[]) 
{
    if(PlayerInfo[playerid][pAdmin] < 1337) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	new totallaps;
	if(sscanf(params, "i", totallaps)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /setlapcount [totallaps]");
   	RaceTotalLaps = totallaps;
	SendClientMessageEx(playerid, COLOR_WHITE, "Da doi tong so vong hoan thanh thanh: %d", RaceTotalLaps);
	return 1;
}

CMD:eventstats(playerid, params[]) 
{
    if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	SendClientMessageEx(playerid, COLOR_WHITE, "Vong hoan thanh: %d | Nguoi choi: %d", RaceTotalLaps, TotalJoinsRace);
	return 1;
}

CMD:rfltoggle(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1337) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	if(rflstatus > 0) {
		rflstatus = 0;
		SendClientMessageEx(playerid, COLOR_GREY, "Da tat Relay For Life.");
		Misc_Save();
	}
	else {
		rflstatus = 1;
		SendClientMessageEx(playerid, COLOR_GREY, "Da bat Relay For Life.");
		Misc_Save();
	}	
	return 1;
}

CMD:toglapcount(playerid, params[]) {
    if(PlayerInfo[playerid][pAdmin] < 1337) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	if(toglapcount == 0) {
   		toglapcount = 1;
		SendClientMessageEx(playerid, COLOR_WHITE, "Da tat dem vong, cac vong moi se khong duoc tinh.");
	} else {
	    toglapcount = 0;
		SendClientMessageEx(playerid, COLOR_WHITE, "Da bat dem vong, cac vong moi se duoc tinh.");
	}
	return 1;
}

CMD:rflscore(playerid, params[])
{
	ShowPlayerDialogEx(playerid, DIALOG_RFL_SEL, DIALOG_STYLE_LIST, "Bang diem Relay For Life", "Diem doi\nTop 25 nguoi choi", "Chon", "Dong");
	return 1;
}

CMD:buyrflteam(playerid, params[])
{
	if(rflstatus < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Relay For Life hien chua bat.");
	if(PlayerInfo[playerid][pRFLTeam] != -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban da thuoc mot doi.");
	if(GetPlayerCash(playerid) < 100000) return SendClientMessageEx(playerid, COLOR_GREY, "Ban can $100000 de mua doi.");
	for(new i = 0; i < MAX_RFLTEAMS; i++) {
		if(RFLInfo[i][RFLmembers] < 1) {
			format(RFLInfo[i][RFLname], 25, "Doi %s", GetPlayerNameEx(playerid));
			format(RFLInfo[i][RFLleader], 25, "%s", GetPlayerNameEx(playerid));
			RFLInfo[i][RFLused] = 1;
			RFLInfo[i][RFLmembers] = 1;
			RFLInfo[i][RFLlaps] = 0;
			PlayerInfo[playerid][pRFLTeam] = i;
			PlayerInfo[playerid][pRFLTeamL] = i;
			GivePlayerCash(playerid, -100000);
			SendClientMessageEx(playerid, COLOR_GREY, "Ban da mua doi voi gia $100000. Dung /rflhelp de xem huong dan.");
			if( GetPVarInt( playerid, "EventToken" ) == 1 ) {
				if( EventKernel[ EventStatus ] == 1 || EventKernel[ EventStatus ] == 2 ) {
					if(EventKernel[EventType] == 3) {
						new Float:X, Float:Y, Float:Z, string[64];
						GetPlayerPos( playerid, X, Y, Z );
						format(string, sizeof(string), "Doi: %s", RFLInfo[i][RFLname]);
						RFLTeamN3D[playerid] = CreateDynamic3DTextLabel(string,0x008080FF,X,Y,Z,10.0,.attachedplayer = playerid, .worldid = GetPlayerVirtualWorld(playerid));
					}
				}
			}
			SaveRelayForLifeTeam(i);
			OnPlayerStatsUpdate(i);
			return 1;
		}
	}
	SendClientMessageEx(playerid, COLOR_GREY, "Da het o doi trong.");
	return 1;
}

CMD:leaverflteam(playerid, params[])
{
	if(rflstatus < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Relay For Life hien chua bat.");
	if(PlayerInfo[playerid][pRFLTeam] == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua thuoc doi nao.");
	new team = PlayerInfo[playerid][pRFLTeam];
	if(PlayerInfo[playerid][pRFLTeamL] == team)
	{
		new string[128];
		format(RFLInfo[team][RFLname], 25, "Unused");
		format(RFLInfo[team][RFLleader], 25, "None");
		RFLInfo[team][RFLlaps] = 0;
		RFLInfo[team][RFLmembers] = 0;
		RFLInfo[team][RFLused] = 0;
		PlayerInfo[playerid][pRFLTeam] = -1;
		PlayerInfo[playerid][pRFLTeamL] = -1;
		if(IsValidDynamic3DTextLabel(RFLTeamN3D[playerid])) {
			DestroyDynamic3DTextLabel(RFLTeamN3D[playerid]);
			RFLTeamN3D[playerid] = Text3D:-1;
		}
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Doi bi xoa vi ban la doi truong.");
		foreach(new i: Player)
		{
			if(PlayerInfo[i][pRFLTeam] == team) {
				PlayerInfo[i][pRFLTeam] = -1;
				PlayerInfo[i][pRFLTeamL] = -1;
				if(IsValidDynamic3DTextLabel(RFLTeamN3D[i])) {
					DestroyDynamic3DTextLabel(RFLTeamN3D[i]);
					RFLTeamN3D[playerid] = Text3D:-1;
				}
				SendClientMessageEx(i, COLOR_LIGHTBLUE, "Ban da roi doi vi doi bi xoa.");
				OnPlayerStatsUpdate(i);
			}
		}	
		OnPlayerStatsUpdate(playerid);
		mysql_format(MainPipeline, string, sizeof(string), "UPDATE `accounts` SET `RFLTeam` = -1, `RFLTeamL` = -1 WHERE `RFLTeam` = %d", team);
		mysql_tquery(MainPipeline, string, "OnQueryFinish", "i", SENDDATA_THREAD);		
	}
	else
	{
		RFLInfo[team][RFLmembers] -= 1;
		PlayerInfo[playerid][pRFLTeam] = -1;
		PlayerInfo[playerid][pRFLTeamL] = -1;
		SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "Ban da roi doi.");
		OnPlayerStatsUpdate(playerid);
	}
	SaveRelayForLifeTeam(team);
	return 1;
}

CMD:rflinvite(playerid, params[])
{
	if(rflstatus < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Relay For Life hien chua bat.");
	if(PlayerInfo[playerid][pRFLTeam] == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua thuoc doi nao.");
	if(PlayerInfo[playerid][pRFLTeamL] == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai doi truong.");
	if(RFLInfo[PlayerInfo[playerid][pRFLTeam]][RFLmembers] >= 20) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the moi qua 19 thanh vien.");
	new giveplayerid;
	if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /rflinvite [playerid/PlayerName]");
	if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
	if(PlayerInfo[giveplayerid][pRFLTeam] != -1) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi nay da thuoc mot doi.");
	SetPVarInt(giveplayerid, "RFLTeam_Invite", 1);
	SetPVarInt(giveplayerid, "RFLTeam_Team", PlayerInfo[playerid][pRFLTeam]);
	SetPVarInt(giveplayerid, "RFLTeam_Inviter", playerid);
	SetPVarInt(giveplayerid, "RFLInviteSession", g_arrQueryHandle[playerid]);
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da moi %s vao doi.", GetPlayerNameEx(giveplayerid));
	SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* %s moi ban vao doi. Dung /accept rflteam de dong y.", GetPlayerNameEx(playerid));
	return 1;
}

CMD:rflkick(playerid, params[])
{
	if(rflstatus < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Relay For Life hien chua bat.");
	if(PlayerInfo[playerid][pRFLTeam] == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua thuoc doi nao.");
	if(PlayerInfo[playerid][pRFLTeamL] == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai doi truong.");
	new giveplayerid;
	if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /rflkick [playerid/PlayerName]");
	if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
	if(PlayerInfo[giveplayerid][pRFLTeam] != PlayerInfo[playerid][pRFLTeam]) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi nay khong thuoc doi ban.");
	new team = PlayerInfo[playerid][pRFLTeam];
	PlayerInfo[giveplayerid][pRFLTeam] = -1;
	PlayerInfo[giveplayerid][pRFLTeamL] = -1;
	RFLInfo[team][RFLmembers] -=1;
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da duoi %s khoi doi.", GetPlayerNameEx(giveplayerid));
	SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* %s da duoi ban khoi doi.", GetPlayerNameEx(playerid));
	if(IsValidDynamic3DTextLabel(RFLTeamN3D[giveplayerid])) {
		DestroyDynamic3DTextLabel(RFLTeamN3D[giveplayerid]);
	}	
	OnPlayerStatsUpdate(giveplayerid);
	SaveRelayForLifeTeam(team);
	return 1;
}

CMD:rflmembers(playerid, params[])
{
	if(rflstatus < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Relay For Life hien chua bat.");
	if(PlayerInfo[playerid][pRFLTeam] == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua thuoc doi nao.");
	SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Cac thanh vien dang online:");
	foreach(new i: Player)
	{
		if(PlayerInfo[i][pRFLTeam] == PlayerInfo[playerid][pRFLTeam]) {
			if(PlayerInfo[i][pRFLTeamL] != -1) {
				SendClientMessageEx(playerid, COLOR_GREY, "%s - Leader", GetPlayerNameEx(i));
			}
			else {
				SendClientMessageEx(playerid, COLOR_GREY, GetPlayerNameEx(i));
			}
		}
	}
	return 1;
}

CMD:rflchangename(playerid, params[])
{
	if(rflstatus < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Relay For Life hien chua bat.");
	if(PlayerInfo[playerid][pRFLTeam] == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua thuoc doi nao.");
	if(PlayerInfo[playerid][pRFLTeamL] == -1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai doi truong.");
	new name[25];
	if(sscanf(params, "s[25]", name)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /rflchangename <teamname>");
	if(GetPVarType(playerid, "HasReport")) {
		SendClientMessageEx(playerid, COLOR_GREY, "Chi duoc gui 1 bao cao cung luc. (/cancelreport)");
		return 1;
	}
	if(strfind(name, "'", true) != -1) {
		SendClientMessageEx(playerid, COLOR_GREY, "Khong duoc dung ' trong ten doi.");
		return 1;
	}	
	SetPVarInt(playerid, "RFLNameRequest", 1);
	SetPVarString(playerid, "NewRFLName", name);
	SendClientMessageEx( playerid, COLOR_YELLOW, "Ban de nghi doi ten doi thanh %s, hay cho Admin duyet.", name );
	SendReportToQue(playerid, "Yeu cau doi ten doi", 2, 4);
	return 1;
}


CMD:rflhelp(playerid, params[])
{
	if(rflstatus < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Relay For Life hien chua bat.");
	SendClientMessageEx(playerid, COLOR_WHITE, "Lenh Relay For Life");
	SendClientMessageEx(playerid, COLOR_GREEN, "_____________________________________________________________________________________________________");
	SendClientMessageEx(playerid, COLOR_GREY, "CHUNG: /rflscore /buyrflteam(100k) /leaverflteam");
	if(PlayerInfo[playerid][pRFLTeam] != -1)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "THANH VIEN: /rflmembers");
	}
	if(PlayerInfo[playerid][pRFLTeamL] != -1)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "CHU DOI: /rflinvite (Toi da 20 thanh vien) /rflkick /rflchangename");
	}
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "ADMIN: /toglapcount /rfltoggle /setlapcount /eventstats /seteventtype race /editevent checkpoints");
	}
	SendClientMessageEx(playerid, COLOR_GREEN, "_____________________________________________________________________________________________________");
	return 1;
}

