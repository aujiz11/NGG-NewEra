/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$f
	|__/  \__/ \______/         |__/  |__/|__/

						Judicial Group Type

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
stock JudgeOnlineCheck()
{
	foreach(new i: Player)
	{
		if(IsAJudge(i))	return 1;
	}	
	return 0;
}

/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

					Offline Warranting

				Next Generation Gaming, LLC
	(created by Next Generation Gaming Development Team)

	* Copyright (c) 2016, Next Generation Gaming, LLC
*/

// Created by Bohemoth

#include <YSI_Coding\y_hooks>

forward OfflineWarranting(index);
public OfflineWarranting(index)
{
	new string[128], name[24], reason[64];
	GetPVarString(index, "OfflineWarrant", name, 24);
	GetPVarString(index, "WarrantRes", reason, 64);

	if(cache_affected_rows()) {
		SendClientMessageEx(index, COLOR_WHITE, "Da phat lenh bat tai khoan %s.", name);

		format(string, sizeof(string), "Ban duoc lenh bat va dua %s ra toa de tra loi cac cao buoc:", name);
		SendGroupMessage(1, DEPTRADIO, string);
		format(string, sizeof(string), "%s", reason);
		SendGroupMessage(1, DEPTRADIO, string);

		//format(string, sizeof(string), "%s offline warranted %s for %s", GetPlayerNameEx(index), name, reason);
		//Log("logs/warrant.log", string);
	}
	else {
		SendClientMessageEx(index, COLOR_WHITE, "Co loi khi phat lenh bat tai khoan %s.", name);
	}

	DeletePVar(index, "OfflineWarrant");
	DeletePVar(index, "WarrantRes");
	return 1;
}

forward OfflineWarrantWD(index);
public OfflineWarrantWD(index)
{
	new name[24];
	GetPVarString(index, "OfflineWarrant", name, 24);

	if(cache_affected_rows()) {
		SendClientMessageEx(index, COLOR_WHITE, "Da thu hoi lenh bat tai khoan %s.", name);

		//format(string, sizeof(string), "%s recalled the warrant on %s's account", GetPlayerNameEx(index), name);
		//Log("logs/warrant.log", string);
	}
	else {
		SendClientMessageEx(index, COLOR_WHITE, "Co loi khi thu hoi lenh bat tai khoan %s.", name);
	}

	DeletePVar(index, "OfflineWarrant");
	return 1;
}


CMD:owarrant(playerid, params[]) {
	if(!IsAJudge(playerid)) {
  		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong thuoc Judicial System!");
  		return 1;
	}
	if(PlayerInfo[playerid][pRank] < 3) {
  		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay, can cap bac 3+.");
  		return 1;
	}

	new name[MAX_PLAYER_NAME], reason[64];
	if(sscanf(params, "s[24]s[64]", name, reason)) return SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /owarrant [player name] [crime]");

	if(!IsPlayerConnected(ReturnUser(name))) {
		new query[512];

		SetPVarString(playerid, "OfflineWarrant", name);
		SetPVarString(playerid, "WarrantRes", reason);

		SendClientMessageEx(playerid, COLOR_YELLOW, "Dang phat lenh bat tai khoan %s vi %s...", name, reason);

		mysql_format(MainPipeline, query,sizeof(query),"UPDATE `accounts` SET `Warrants` = '%e' WHERE `Warrants` = '' AND `Username` = '%e'", reason, name);
		mysql_tquery(MainPipeline, query, "OfflineWarranting", "i", playerid);
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the phat lenh bat offline voi nguoi choi dang online!");
	return 1;
}

CMD:owarrantwd(playerid, params[])
{
    if(!IsAJudge(playerid))
	{
  		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong thuoc Judicial System!");
  		return 1;
 	}
	if(PlayerInfo[playerid][pMember] < 3)
	{
  		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay, can cap bac 3+.");
  		return 1;
  	}

	new name[MAX_PLAYER_NAME];
	if(sscanf(params, "s[24]s[64]", name)) return SendClientMessageEx(playerid, COLOR_WHITE, "CACH DUNG: /owarrantwd [player name]");

	if(!IsPlayerConnected(ReturnUser(name))) {
		new query[512];

		SetPVarString(playerid, "OfflineWarrant", name);

		SendClientMessageEx(playerid, COLOR_YELLOW, "Dang thu hoi lenh bat tai khoan %s...", name);

		mysql_format(MainPipeline, query, sizeof(query), "UPDATE `accounts` SET `Warrants` = '' WHERE `Warrants` != '' AND `Username` = '%e'", name);
		mysql_tquery(MainPipeline, query, "OfflineWarrantWD", "i", playerid);
	}
	else return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the phat lenh bat offline voi nguoi choi dang online!");
	return 1;
}

CMD:present(playerid, params[])
{
  	if(IsAJudge(playerid))
	{
		new giveplayerid;
		if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /present [player]");
		if(IsPlayerConnected(giveplayerid))
		{
			if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung lenh nay cho chinh minh!");
			if(PlayerInfo[giveplayerid][pBeingSentenced] == 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi do khong dang cho tuyen an!");
			if(courtjail[giveplayerid] == 0) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi do khong o buong giam toa an!");
			if(courtjail[giveplayerid] > 0)
			{
				SetPlayerPos(giveplayerid, 1494.8669, -1552.0634, 1127.0251);
		    	SetPlayerFacingAngle(giveplayerid, 176.9777);
		    	SetPlayerVirtualWorld(giveplayerid, GetPlayerVirtualWorld(playerid));
		    	SetPlayerInterior(giveplayerid, GetPlayerInterior(playerid));
			}
			courtjail[giveplayerid] = 0;
		    SetCameraBehindPlayer(giveplayerid);
		}
	}
	else
	{
	    return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong thuoc Judicial System!");
	}
	return 1;
}

CMD:checkjudgements(playerid, params[])
{
    if(IsACop(playerid) || IsAJudge(playerid))
    {

    	if(JudgeOnlineCheck() == 0) return SendClientMessageEx(playerid, COLOR_GRAD4, "Can it nhat mot Judge online de dung lenh nay!");
		SendClientMessageEx(playerid, COLOR_YELLOW, "Danh sach cho xet xu:");

		new
			fCounter;

		foreach(new i: Player)
		{
			if(PlayerInfo[i][pJudgeJailType] == 1)
			{
				if(PlayerInfo[i][pJailTime] > 1)
				{
					SendClientMessageEx(playerid, COLOR_GRAD1, "Da tuyen: %s - jail (da giao) - thoi gian: %d.",GetPlayerNameEx(i),PlayerInfo[i][pJudgeJailTime]);
					++fCounter;
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GRAD1, "Da tuyen: %s - jail (dang giao) - thoi gian: %d.",GetPlayerNameEx(i),PlayerInfo[i][pJudgeJailTime]);
					++fCounter;
				}
			}
			else if(PlayerInfo[i][pJudgeJailType] == 2)
			{
				if(PlayerInfo[i][pJailTime] > 1)
				{
					SendClientMessageEx(playerid, COLOR_GRAD1, "Da tuyen: %s - prison (da giao) - thoi gian: %d.",GetPlayerNameEx(i),PlayerInfo[i][pJudgeJailTime]);
					++fCounter;
				}
				else
				{
					SendClientMessageEx(playerid, COLOR_GRAD1, "Da tuyen: %s - prison (dang giao) - thoi gian: %d.",GetPlayerNameEx(i),PlayerInfo[i][pJudgeJailTime]);
					++fCounter;
				}
			}
		}	
		if(fCounter == 0)
		{
  			SendClientMessageEx(playerid, COLOR_GRAD1, "Khong co ai cho xet xu.");
		}
  	}
	return 1;
}

CMD:freezeassets(playerid, params[])
{
  	if(!IsAJudge(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong thuoc Judicial System!");
	if(PlayerInfo[playerid][pRank] < 4) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong du quyen, chi rank 4+ duoc dung lenh nay.");
	new giveplayerid, houseorcar[8];
	if(sscanf(params, "us[8]", giveplayerid, houseorcar)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /freezeassets [player] [house/car/bank]");
	if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung lenh nay cho chinh minh!");
	if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
	new string[128],
		rank[GROUP_MAX_RANK_LEN],
		division[GROUP_MAX_DIV_LEN],
		employer[GROUP_MAX_NAME_LEN];

	szMiscArray[0] = 0;
    if(strcmp(houseorcar, "house", true) == 0)
	{
		if(PlayerInfo[giveplayerid][pFreezeHouse] == 0)
	    {
			PlayerInfo[giveplayerid][pFreezeHouse] = 1;
	       	GetPlayerGroupInfo(playerid, rank, division, employer);
		   	format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s %s khoa tai san nha cua %s.", rank, GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
		   	ABroadCast(COLOR_YELLOW,string, 2);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da khoa tai san nha cua %s.", GetPlayerNameEx(giveplayerid));
			SendClientMessageEx(giveplayerid, COLOR_WHITE, "Tai san nha cua ban bi %s dong bang", GetPlayerNameEx(playerid));

	   	 	format(szMiscArray, sizeof(szMiscArray), "%s %s has frozen %s house assets.", rank, GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
	    }
	    else
	    {
	        PlayerInfo[giveplayerid][pFreezeHouse] = 0;
			format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s %s mo khoa tai san nha cua %s.", rank, GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
	    	ABroadCast(COLOR_YELLOW,string, 2);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da mo khoa tai san nha cua %s.", GetPlayerNameEx(giveplayerid));
			SendClientMessageEx(giveplayerid, COLOR_WHITE, "Tai san nha cua ban duoc %s mo dong bang", GetPlayerNameEx(playerid));

	   	 	format(szMiscArray, sizeof(szMiscArray), "%s %s has unfrozen %s house assets.", rank, GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
		}
	}
	else if(strcmp(houseorcar, "car", true) == 0)
	{
	    if(PlayerInfo[giveplayerid][pFreezeCar] == 0)
		{
			PlayerInfo[giveplayerid][pFreezeCar] = 1;
	       	GetPlayerGroupInfo(playerid, rank, division, employer);
			format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s %s khoa tai san xe cua %s.", rank, GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
	    	ABroadCast(COLOR_YELLOW,string, 2);
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da dong bang tai san xe cua %s.", GetPlayerNameEx(giveplayerid));
			SendClientMessageEx(giveplayerid, COLOR_WHITE, "Tai san xe cua ban bi %s dong bang", GetPlayerNameEx(playerid));

		 	format(szMiscArray, sizeof(szMiscArray), "%s %s has frozen %s vehicle assets.", rank, GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
	    }
	    else
	    {
	        PlayerInfo[giveplayerid][pFreezeCar] = 0;
	        format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s %s mo khoa tai san xe cua %s.", rank, GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
	    	ABroadCast(COLOR_YELLOW,string, 2);
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da mo dong bang tai san xe cua %s.", GetPlayerNameEx(giveplayerid));
			SendClientMessageEx(giveplayerid, COLOR_WHITE, "Tai san xe cua ban duoc %s mo dong bang", GetPlayerNameEx(playerid));

		 	format(szMiscArray, sizeof(szMiscArray), "%s %s has unfrozen %s vehicle assets.", rank, GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
	    }
	}
	else if(strcmp(houseorcar, "bank", true) == 0)
	{
		if(PlayerInfo[giveplayerid][pFreezeBank] == 0)
    	{
        	PlayerInfo[giveplayerid][pFreezeBank] = 1;
       		GetPlayerGroupInfo(playerid, rank, division, employer);
	   		format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s %s khoa tai khoan cua %s.", rank, GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
    		ABroadCast(COLOR_YELLOW,string, 2);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da khoa tai khoan cua %s.", GetPlayerNameEx(giveplayerid));
			SendClientMessageEx(giveplayerid, COLOR_WHITE, "Tai khoan cua ban bi %s khoa", GetPlayerNameEx(playerid));

   	 		format(szMiscArray, sizeof(szMiscArray), "%s %s has frozen %s bank assets.", rank, GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
    	}
    	else
    	{
			PlayerInfo[giveplayerid][pFreezeBank] = 0;
			format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s %s mo khoa tai khoan cua %s.", rank, GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
			ABroadCast(COLOR_YELLOW,string, 2);
			SendClientMessageEx(playerid, COLOR_WHITE, "Da mo khoa tai khoan cua %s.", GetPlayerNameEx(giveplayerid));
			SendClientMessageEx(giveplayerid, COLOR_WHITE, "Tai khoan cua ban duoc %s mo khoa", GetPlayerNameEx(playerid));

   	 		format(szMiscArray, sizeof(szMiscArray), "%s %s has unfrozen %s bank assets.", rank, GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
		}
	}
	else
	{
	    return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /freezeassets [player] [house/car/bank]");
	}
	GroupLogEx(PlayerInfo[playerid][pMember], szMiscArray, 1);
	return 1;
}

CMD:reward(playerid, params[])
{

    if(!IsAJudge(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong thuoc Judicial System!");
	if(PlayerInfo[playerid][pRank] < 4) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong du quyen, chi rank 4+ duoc dung lenh nay.");

	new
		giveplayerid,
		money;

	if(sscanf(params, "ud", giveplayerid, money)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /reward [player] [money(max of $50,000)]");
	if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung lenh nay cho chinh minh!");
	if(IsPlayerConnected(giveplayerid))
	{
		new
			string[64 + (MAX_PLAYER_NAME * 2)];

  		if(money < 1 || money > 50000) return SendClientMessageEx(playerid, COLOR_GRAD5, "Tien thuong khong duoc duoi $1 hoac tren $50,000!");
    	new rank[GROUP_MAX_RANK_LEN], division[GROUP_MAX_DIV_LEN], employer[GROUP_MAX_NAME_LEN];
   		GetPlayerGroupInfo(playerid, rank, division, employer);
	    format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s %s(%d) vua thuong %s(%d) $%d.", rank, GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerNameEx(giveplayerid), GetPlayerSQLId(giveplayerid), money);
	    ABroadCast(COLOR_YELLOW,string, 2);

		format(string, sizeof(string), "AdmCmd: %s %s has just rewarded %s $%d", rank, GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), money);
		Log("logs/rpspecial.log", string);
		Tax -= money;
  		GivePlayerCash(giveplayerid, money);
	    SendClientMessageEx(playerid, COLOR_WHITE, "Ban da thuong $%d cho %s.", money, GetPlayerNameEx(giveplayerid));
		SendClientMessageEx(giveplayerid, COLOR_WHITE, "Ban nhan $%d tien thuong tu %s %s.", money, rank, GetPlayerNameEx(playerid));
	}
	return 1;
}

CMD:reversejudgement(playerid, params[])
{

    if(!IsAJudge(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong thuoc Judicial System!");
	if(PlayerInfo[playerid][pRank] < 4) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong du quyen, chi rank 4+ duoc dung lenh nay.");

	new
		giveplayerid; // For future reference - sscanf plugin is 3 times as fast as ReturnUser, even when used on only one argument

	if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /reversejudgement [player]");
	if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung lenh nay cho chinh minh!");
	if(IsPlayerConnected(giveplayerid))
	{
 		if(PlayerInfo[giveplayerid][pJudgeJailTime] != 0)
   		{
     		new rank[GROUP_MAX_RANK_LEN], division[GROUP_MAX_DIV_LEN], employer[GROUP_MAX_NAME_LEN], string[52 + (MAX_PLAYER_NAME * 2)];
       		GetPlayerGroupInfo(playerid, rank, division, employer);
			if(PlayerInfo[giveplayerid][pJailTime] != 0) PlayerInfo[giveplayerid][pJailTime] = 0;
			PlayerInfo[giveplayerid][pJudgeJailTime] = 0;
   			switch(PlayerInfo[playerid][pSex])
			{
			    case 1: format(string, sizeof(string), "%s %s da huy ban an cua %s, nguoi nay duoc tu do.", rank, GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
			    case 2: format(string, sizeof(string), "%s %s da huy ban an cua %s, nguoi nay duoc tu do.", rank, GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
			}
   			SendGroupMessage(GROUP_TYPE_LEA, DEPTRADIO, string);
   		}
	    else
   		{
        	SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi do khong co an jail/prison.");
   		}
	}
	return 1;
}

CMD:commute(playerid, params[])
{
	pc_cmd_pardon(playerid, "");
	SendClientMessageEx(playerid, COLOR_GRAD1, "Ban cung co the dung /pardon.");
	return 1;
}

CMD:pardon(playerid, const params[])
{
    if(IsAGovernment(playerid) && PlayerInfo[playerid][pRank] >= Group_GetMaxRank(PlayerInfo[playerid][pMember]))
    {
		new
			giveplayerid;

        if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /pardon [player]");
		if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung lenh nay cho chinh minh!");
		if(IsPlayerConnected(giveplayerid))
		{
		    if(PlayerInfo[giveplayerid][pJudgeJailTime] != 0)
		    {
				new string[58 + (MAX_PLAYER_NAME * 2)];
		        if(PlayerInfo[giveplayerid][pJailTime] != 0) PlayerInfo[giveplayerid][pJailTime] = 2;
		        PlayerInfo[giveplayerid][pJudgeJailTime] = 2;
		        switch(PlayerInfo[playerid][pSex])
				{
				    case 1: format(string, sizeof(string), "President %s da an xa cho %s, nguoi nay duoc tu do.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				    case 2: format(string, sizeof(string), "President %s da an xa cho %s, nguoi nay duoc tu do.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				}
			    SendGroupMessage(GROUP_TYPE_LEA, DEPTRADIO, string);
		    }
		    else
	   		{
	       		SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi do khong co an jail/prison.");
	   		}
		}
	}
 	else
  	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "Chi President duoc dung lenh nay.");
  	}
	return 1;
}

CMD:wants(playerid, params[])
{
    if(IsACop(playerid) || IsAJudge(playerid))
    {
    	if(JudgeOnlineCheck() == 0) return SendClientMessageEx(playerid, COLOR_GRAD4, "Can it nhat mot Judge online de dung lenh nay!");
		SendClientMessageEx(playerid, COLOR_YELLOW, "Danh sach lenh bat con hieu luc:");

		new
			fCounter;

		foreach(new i: Player)
		{
			if(!isnull(PlayerInfo[i][pWarrant]) || PlayerInfo[i][pWarrant] != 0)
			{
				SendClientMessageEx(playerid, COLOR_GRAD1, "%s (%d) - ly do: %s.",GetPlayerNameEx(i), i, PlayerInfo[i][pWarrant]);
				++fCounter;
			}
		}	
		if(fCounter <= 0)
		{
		    SendClientMessageEx(playerid, COLOR_GRAD1, "Khong co lenh bat nao dang cho.");
		}
  	}
	return 1;
}

CMD:mywarrants(playerid, params[])
{
    if(IsPlayerInRangeOfPoint(playerid, 3.0, 361.8299,173.7117,1008.3828))
    {
		if(!isnull(PlayerInfo[playerid][pWarrant]))
  		{
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban co lenh bat con hieu luc. Hay can nhac goi 911 de dau thu.");
   		}
     	else
      	{
       		SendClientMessageEx(playerid, COLOR_WHITE, "Ban khong co lenh bat con hieu luc.");
      	}
   	}
    else
    {
    	SendClientMessageEx(playerid, COLOR_GRAD1, "Den diem trong City Hall de kiem tra lenh bat.");
    }
	return 1;
}

CMD:jarrest(playerid, params[])
{
    if(IsAJudge(playerid))
	{
 		if(!IsAtArrestPoint(playerid, 4))
		{
  			SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o diem bat giu.");
	    	return 1;
		}
		new suspect = GetClosestPlayer(playerid);
		if(IsPlayerConnected(suspect))
		{
			if(ProxDetectorS(5.0, playerid,suspect))
			{
				if(PlayerInfo[suspect][pJudgeJailType] != 1) { return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong can thi hanh an jail."); }
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da bat %s!", GetPlayerNameEx(suspect));
				ResetPlayerWeaponsEx(suspect);
				for(new x; x < MAX_PLAYERVEHICLES; x++) if(PlayerVehicleInfo[suspect][x][pvTicket] >= 1) {
					PlayerVehicleInfo[suspect][x][pvTicket] = 0;
				}
				SetPlayerInterior(suspect, 5);
				SetPlayerPos(suspect,318.5971,312.9619,999.1484);
				PlayerInfo[suspect][pJailTime] = PlayerInfo[suspect][pJudgeJailTime];
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
				if(PlayerCuffed[suspect] == 2)
				{
					SetHealth(suspect, GetPVarFloat(suspect, "cuffhealth"));
					SetArmour(suspect, GetPVarFloat(suspect, "cuffarmor"));
					DeletePVar(suspect, "cuffhealth");
					DeletePVar(suspect, "PlayerCuffed");
				}
				PlayerCuffed[suspect] = 0;
				DeletePVar(suspect, "PlayerCuffed");
				PlayerCuffedTime[suspect] = 0;
				PlayerInfo[suspect][pVW] = 0;
				SetPlayerVirtualWorld(suspect, 0);
			}
		}
	}
	return 1;
}

CMD:deliver(playerid, params[])
{
	if(!IsPlayerInRangeOfPoint(playerid, 8.0, 1991.7953,-2321.2532,13.5469))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o Los Santos International Airport.");
		return 1;
	}
	new giveplayerid;
	if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /deliver [player]");
	if(PlayerInfo[playerid][pRank] < 1)
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "Can it nhat rank 1.");
		return 1;
	}
	if(IsPlayerConnected(giveplayerid))
	{
		if(giveplayerid == playerid) { SendClientMessageEx(playerid, COLOR_GREY, "   Khong the tu dua minh vao prison!"); return 1; }
		if(PlayerInfo[giveplayerid][pJudgeJailTime] == 0 && PlayerInfo[giveplayerid][pJudgeJailType] != 2) { SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong can vao prison!"); return 1; }
		if(ProxDetectorS(8.0, playerid, giveplayerid))
		{
  			DeletePVar(giveplayerid, "IsFrozen");
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da dua %s den Department of Corrections.", GetPlayerNameEx(giveplayerid));
			SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE, "* %s da dua ban den Department of Corrections.", GetPlayerNameEx(playerid));
			GameTextForPlayer(giveplayerid, "~w~Chao mung den ~n~~r~Department of Corrections", 5000, 3);
			ClearAnimationsEx(giveplayerid);
			PlayerCuffed[giveplayerid] = 0;
			DeletePVar(giveplayerid, "PlayerCuffed");
			format(PlayerInfo[giveplayerid][pPrisonedBy], 24, "%s", GetPlayerNameEx(playerid));
			format(PlayerInfo[giveplayerid][pPrisonReason], 128, "[IC] Judge Sentence");
			PlayerInfo[giveplayerid][pWantedLevel] = 0;
			SetPlayerToTeamColor(giveplayerid);
			SetPlayerWantedLevel(giveplayerid, 0);
			
			Prison_SetPlayerSkin(giveplayerid);
			PhoneOnline[giveplayerid] = 1;
			PlayerInfo[giveplayerid][pJailTime] = PlayerInfo[giveplayerid][pJudgeJailTime];
			SetPlayerInterior(giveplayerid, 10);
			PlayerInfo[giveplayerid][pInt] = 10;
			SetPlayerVirtualWorld(giveplayerid, 0);
			PlayerInfo[giveplayerid][pVW] = 0;
			SetPlayerColor(giveplayerid, TEAM_ORANGE_COLOR);
			new rand = random(sizeof(DocPrison));
			SetPlayerFacingAngle(giveplayerid, 0);
			SetPlayerPos(giveplayerid, DocPrison[rand][0], DocPrison[rand][1], DocPrison[rand][2]);
			ResetPlayerWeaponsEx(giveplayerid);
			Player_StreamPrep(giveplayerid, DocPrison[rand][0], DocPrison[rand][1], DocPrison[rand][2], FREEZE_TIME);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do khong o gan ban.");
			return 1;
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
		return 1;
	}
	return 1;
}


CMD:warrant(playerid, params[])
{
	if(!IsAJudge(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong thuoc Judicial System!");
 	if(PlayerInfo[playerid][pRank] < 3)
	{
  		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay, can cap bac 3+.");
  		return 1;
	}

	new string[128], crime[64], giveplayerid;
	if(sscanf(params, "us[64]", giveplayerid, crime)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /warrant [player] [crime]");

	if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the tu phat lenh bat minh!");
	if(IsPlayerConnected(giveplayerid))
	{
		if(!isnull(PlayerInfo[giveplayerid][pWarrant])) return SendClientMessageEx(playerid, COLOR_GRAD5, "Nguoi do da co lenh bat con hieu luc.");
		format(PlayerInfo[giveplayerid][pWarrant], 64, crime);
		format(string, sizeof(string), "Ban duoc lenh bat va dua %s ra toa de tra loi cac cao buoc:", GetPlayerNameEx(giveplayerid));
		SendGroupMessage(GROUP_TYPE_LEA, DEPTRADIO, string);
		format(string, sizeof(string), "%s", crime);
		SendGroupMessage(GROUP_TYPE_JUDICIAL, DEPTRADIO, string);
		format(string, sizeof(string), "%s da phat lenh bat %s de tra loi cao buoc chong lai Sovereign Republic.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
		SendGroupMessage(GROUP_TYPE_JUDICIAL, DEPTRADIO, string);
		GroupLogEx(PlayerInfo[playerid][pMember], string, 0);
		return 1;
	}
	return 1;
}

CMD:warrantwd(playerid, params[])
{
    if(!IsAJudge(playerid))
	{
  		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong thuoc Judicial System!");
  		return 1;
 	}
	if(PlayerInfo[playerid][pMember] < 3)
	{
  		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay, can cap bac 3+.");
  		return 1;
  	}

  	new string[128], giveplayerid;
  	if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /warrantwd [player]");

	if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the tu xoa lenh bat cua minh!");
	if(IsPlayerConnected(giveplayerid))
	{
 		if(strlen(PlayerInfo[giveplayerid][pWarrant]) == 0) return SendClientMessageEx(playerid, COLOR_GRAD5, "Nguoi do khong co lenh bat con hieu luc.");
		format(PlayerInfo[giveplayerid][pWarrant], 128, "");
		SendClientMessageEx(playerid, COLOR_GRAD2, "Da thu hoi lenh bat cua %s.", GetPlayerNameEx(giveplayerid));
		format(string, sizeof(string), "%s da thu hoi lenh bat cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
		SendGroupMessage(GROUP_TYPE_JUDICIAL, DEPTRADIO, string);
		GroupLogEx(PlayerInfo[playerid][pMember], string, 0);
		return 1;
	}
	return 1;
}

CMD:warrantarrest(playerid, params[])
{
    new string[256];

    if(IsACop(playerid))
	{
	    if(JudgeOnlineCheck() == 0) return SendClientMessageEx(playerid, COLOR_GRAD4, "Can it nhat mot Judge online de lam viec nay!");
        if(!IsAtArrestPoint(playerid, 3))
		{
  			SendClientMessageEx(playerid, COLOR_GREY, "Ban khong o diem bat giu theo lenh.");
	    	return 1;
		}

		new suspect = GetClosestPlayer(playerid);
		if(IsPlayerConnected(suspect))
		{
			if(ProxDetectorS(5.0, playerid,suspect))
			{
				if(strlen(PlayerInfo[suspect][pWarrant]) < 1)
				{
	   				SendClientMessageEx(playerid, COLOR_GREY, "Nguoi do phai co lenh bat con hieu luc.");
				    return 1;
				}
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "* Ban da bat %s theo lenh!", GetPlayerNameEx(suspect));
				ResetPlayerWeaponsEx(suspect);
				format(string, sizeof(string), "<< Bi cao %s da duoc %s dua den phong xu de cho xet xu >>", GetPlayerNameEx(suspect), GetPlayerNameEx(playerid));
				SendGroupMessage(GROUP_TYPE_JUDICIAL, DEPTRADIO, string);
				SetPlayerInterior(suspect, 5);
				PlayerInfo[suspect][pInt] = 1;
				SetPlayerVirtualWorld(suspect, 0);
				PlayerInfo[suspect][pVW] = 0;
				new rand = random(sizeof(WarrantJail));
				SetPlayerFacingAngle(suspect, 180);
				SetPlayerPos(suspect, WarrantJail[rand][0], WarrantJail[rand][1], WarrantJail[rand][2]);
				if(rand != 0) courtjail[suspect] = 2;
				else courtjail[suspect] = 1;
				SetCameraBehindPlayer(suspect);
				DeletePVar(suspect, "IsFrozen");
				PlayerCuffed[suspect] = 0;
				DeletePVar(suspect, "PlayerCuffed");
				PlayerCuffedTime[suspect] = 0;
				PhoneOnline[suspect] = 1;
				PlayerInfo[suspect][pArrested] += 1;
				SetPlayerFree(suspect,playerid, "was warrant arrested");
				PlayerInfo[suspect][pWantedLevel] = 0;
				SetPlayerToTeamColor(suspect);
				SetPlayerWantedLevel(suspect, 0);
				WantLawyer[suspect] = 1;
				ClearAnimationsEx(suspect);
				Lawyer_ClearAppeal(suspect);
				PlayerInfo[suspect][pBeingSentenced] = 60;
				SetPlayerColor(suspect, SHITTY_JUDICIALSHITHOTCH);
				SendClientMessageEx(suspect, COLOR_LIGHTBLUE, "Ban bi bat theo lenh, Judge se som xu ly.");
				Player_StreamPrep(suspect, WarrantJail[rand][0], WarrantJail[rand][1], WarrantJail[rand][2], FREEZE_TIME);
				
			}
		}
		else
		{
  			SendClientMessageEx(playerid, COLOR_GREY, "   Khong co ai o du gan de bat.");
	    	return 1;
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD2, "   Ban khong phai nhan vien hanh phap!");
   		return 1;
	}
	return 1;
}

CMD:adjourn(playerid, params[])
{
	new giveplayerid;

    if(!IsAJudge(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong thuoc Judicial System!");
	if(PlayerInfo[playerid][pRank] < 3) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay, can cap bac 3+.");
	if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /adjourn [player]");
	if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung lenh nay cho chinh minh!");
	if(IsPlayerConnected(giveplayerid))
	{
	    if(PlayerInfo[giveplayerid][pBeingSentenced])
	    {
			Lawyer_ClearAppeal(giveplayerid);
	    	PlayerInfo[giveplayerid][pBeingSentenced] = 0;
            TogglePlayerControllable(giveplayerid, true);
	    	DeletePVar(giveplayerid, "IsFrozen");
			PhoneOnline[giveplayerid] = 0;
			format(PlayerInfo[giveplayerid][pWarrant], 128, "");
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da tha %s khoi phong xu.", GetPlayerNameEx(giveplayerid));
			SendClientMessageEx(giveplayerid, COLOR_WHITE, "%s da tha ban khoi phong xu, ban co the roi di.", GetPlayerNameEx(playerid));
		}
		else SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do phai o phong xu va dang cho tuyen an.");
	}
	return 1;
}

CMD:sentence(playerid, params[]) {

	new giveplayerid;

    if(!IsAJudge(playerid)) {
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong thuoc Judicial System!");
	}
	else if(PlayerInfo[playerid][pRank] < 3) {
		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay, can cap bac 3+.");
	}
	else if(sscanf(params, "u", giveplayerid)) {
		SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /sentence [player]");
	}
	else if(IsPlayerConnected(giveplayerid)) {
		if(giveplayerid == playerid) {
			SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung lenh nay cho chinh minh!");
		}
 		else if(PlayerInfo[giveplayerid][pBeingSentenced]) {
			Lawyer_ClearAppeal(giveplayerid);
			PlayerInfo[giveplayerid][pBeingSentenced] = 0;
            TogglePlayerControllable(giveplayerid, false);
	    	SetPVarInt(giveplayerid, "IsFrozen", 1);
			PhoneOnline[giveplayerid] = 1;
			PlayerInfo[giveplayerid][pWarrant][0] = 0;
			SetPlayerPos(giveplayerid, 1384.0507,-1688.8254,13.5341);
			SetPlayerInterior(giveplayerid, 0);
			PlayerInfo[giveplayerid][pInt] = 0;
			SetPlayerVirtualWorld(giveplayerid, 0);
			PlayerInfo[giveplayerid][pVW] = 0;
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da tha %s khoi phong xu.", GetPlayerNameEx(giveplayerid));
			SendClientMessageEx(giveplayerid, COLOR_WHITE, "%s da tha ban khoi phong xu, ban co the roi di.", GetPlayerNameEx(playerid));
		}
		else SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do phai o phong xu va dang cho tuyen an.");
	}
	else SendClientMessageEx(playerid, COLOR_GRAD1, "Nguoi choi khong hop le.");
	return 1;
}

CMD:trial(playerid, params[])
{
	new giveplayerid;

    if(!IsAJudge(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong thuoc Judicial System!");
	if(PlayerInfo[playerid][pRank] < 3) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay, can cap bac 3+.");
	if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /trial [player]");
	if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung lenh nay cho chinh minh!");
	if(IsPlayerConnected(giveplayerid))
	{
	    if(PlayerInfo[giveplayerid][pBeingSentenced])
	    {
	    	PlayerInfo[giveplayerid][pBeingSentenced] += 10;
			SendClientMessageEx(playerid, COLOR_WHITE, "Ban da tang thoi gian o toa cua %s them 10 phut, hien tai: %d", GetPlayerNameEx(giveplayerid), PlayerInfo[giveplayerid][pBeingSentenced]);
			SendClientMessageEx(giveplayerid, COLOR_WHITE, "%s da tang thoi gian o toa cua ban them 10 phut, hien tai: %d", GetPlayerNameEx(playerid), PlayerInfo[giveplayerid][pBeingSentenced]);
		}
		else SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do phai o phong xu va dang cho tuyen an.");
	}
	return 1;
}

CMD:subpoena(playerid, params[])
{
	new dates[32], message[64], giveplayerid;

    if(!IsAJudge(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong thuoc Judicial System!");
	if(PlayerInfo[playerid][pRank] < 1) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong du quyen, chi rank 1+ duoc dung lenh nay.");
	if(sscanf(params, "us[32]s[64]", giveplayerid, dates, message)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /subpoena [player] [date] [message]");
	if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung lenh nay cho chinh minh!");
	if(IsPlayerConnected(giveplayerid))
	{
	    SendClientMessageEx(giveplayerid, COLOR_WHITE, "|___________ Thong bao quan trong tu toa an ___________|");
		SendClientMessageEx(giveplayerid, COLOR_YELLOW, "Ban duoc trieu tap ra toa vao %s vi: %s", dates, message);
		SendClientMessageEx(giveplayerid, COLOR_WHITE, "|_________________________________________________________|");
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban da trieu tap %s ra toa", GetPlayerNameEx(giveplayerid));
	}
	return 1;
}

CMD:judgejail(playerid, params[])
{
    if(!IsAJudge(playerid))
	{
  		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong thuoc Judicial System!");
  		return 1;
	}
	if(PlayerInfo[playerid][pRank] < 3)
	{
  		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay, can cap bac 3+.");
  		return 1;
	}

	new giveplayerid, jailtime, reason[64];
	if(sscanf(params, "uds[64]", giveplayerid, jailtime, reason)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /judgejail [player] [time (minutes)] [reason]");

	if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung lenh nay cho chinh minh!");
	if(IsPlayerConnected(giveplayerid))
	{
		if(!PlayerInfo[giveplayerid][pBeingSentenced]) return SendClientMessageEx(playerid, COLOR_GRAD5, "Nguoi do khong dang cho tuyen an!");
		if(jailtime < 5)
		{
			return SendClientMessageEx(playerid, COLOR_GRAD5, "Ban an phai it nhat 5 phut!");
		}
		if(jailtime > 120)
		{
			return SendClientMessageEx(playerid, COLOR_GRAD5, "Ban an toi da 2 Gio / 120 Phut");
		}
		PlayerInfo[giveplayerid][pJudgeJailType] = 1;
		PlayerInfo[giveplayerid][pJudgeJailTime] = jailtime*60;
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban da tuyen %s thi hanh %d phut jail, ly do: %s", GetPlayerNameEx(giveplayerid), jailtime, reason);
		SendClientMessageEx(giveplayerid, COLOR_WHITE, "Ban bi tuyen %d phut jail boi %s, ly do: %s", jailtime, GetPlayerNameEx(playerid), reason);
		if(IsACop(giveplayerid))
		{
		    SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE,"* Ban tu dong bi xoa khoi to chuc do bi ket an tu va tro lai lam thuong dan.");
			PlayerInfo[giveplayerid][pMember] = INVALID_GROUP_ID;
			PlayerInfo[giveplayerid][pLeader] = INVALID_GROUP_ID;
			PlayerInfo[giveplayerid][pRank] = INVALID_RANK;
			PlayerInfo[giveplayerid][pDuty] = 0;
			if(!IsValidSkin(GetPlayerSkin(giveplayerid)))
			{
			    new rand = random(sizeof(CIV));
				SetPlayerSkin(giveplayerid,CIV[rand]);
				PlayerInfo[giveplayerid][pModel] = CIV[rand];
			}
			player_remove_vip_toys(giveplayerid);
			SetPlayerToTeamColor(giveplayerid);
			pTazer{giveplayerid} = 0;
		}
	}
	return 1;
}

CMD:judgeprison(playerid, params[])
{
    if(!IsAJudge(playerid))
	{
  		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong thuoc Judicial System!");
  		return 1;
	}
	if(PlayerInfo[playerid][pRank] < 3)
	{
  		SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay, can cap bac 3+.");
  		return 1;
	}

	new giveplayerid, jailtime, reason[64];
	if(sscanf(params, "uds[64]", giveplayerid, jailtime, reason)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /judgeprison [player] [time (mins)] [reason]");

	if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung lenh nay cho chinh minh!");
	if(IsPlayerConnected(giveplayerid))
	{
	    if(!PlayerInfo[giveplayerid][pBeingSentenced]) return SendClientMessageEx(playerid, COLOR_GRAD5, "Nguoi do khong dang cho tuyen an!");
		if(jailtime < 5)
		{
			return SendClientMessageEx(playerid, COLOR_GRAD5, "Ban an phai it nhat 5 phut!");
		}
		if(jailtime > 120)
		{
			return SendClientMessageEx(playerid, COLOR_GRAD5, "Ban an toi da 2 Gio / 120 Phut");
		}
		PlayerInfo[giveplayerid][pJudgeJailType] = 2;
		PlayerInfo[giveplayerid][pJudgeJailTime] = jailtime*60;
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban da tuyen %s thi hanh %d phut prison, ly do: %s", GetPlayerNameEx(giveplayerid), jailtime, reason);
		SendClientMessageEx(giveplayerid, COLOR_WHITE, "Ban bi tuyen %d phut prison boi %s, ly do: %s", jailtime, GetPlayerNameEx(playerid), reason);
		if(IsACop(giveplayerid))
		{
		    SendClientMessageEx(giveplayerid, COLOR_LIGHTBLUE,"* Ban tu dong bi xoa khoi to chuc do bi ket an tu va tro lai lam thuong dan.");
			PlayerInfo[giveplayerid][pMember] = INVALID_GROUP_ID;
			PlayerInfo[giveplayerid][pLeader] = INVALID_GROUP_ID;
			PlayerInfo[giveplayerid][pRank] = INVALID_RANK;
			PlayerInfo[giveplayerid][pDuty] = 0;
			if(!IsValidSkin(GetPlayerSkin(giveplayerid)))
			{
			    new rand = random(sizeof(CIV));
				SetPlayerSkin(giveplayerid,CIV[rand]);
				PlayerInfo[giveplayerid][pModel] = CIV[rand];
			}
			player_remove_vip_toys(giveplayerid);
			SetPlayerToTeamColor(giveplayerid);
   			pTazer{giveplayerid} = 0;
		}
	}
	return 1;
}

CMD:judgefine(playerid, params[])
{
	if(!IsAJudge(playerid)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong thuoc Judicial System!");
	if(PlayerInfo[playerid][pRank] < 3) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay, can cap bac 3+.");

	new giveplayerid, judgefine, reason[64], totalwealth;

	if(sscanf(params, "uds[64]", giveplayerid, judgefine, reason)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /judgefine [player] [amount] [reason]");
	if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi choi khong hop le.");
	totalwealth = PlayerInfo[giveplayerid][pCash] + PlayerInfo[giveplayerid][pAccount];
	if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung lenh nay cho chinh minh!");
	if(!(1 <= judgefine <= 500000)) return SendClientMessageEx(playerid, COLOR_GREY, "Tien phat khong duoc duoi $1 hoac tren $500,000!");
	if(totalwealth < 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do da mac no, hay lien he Admin.");
	if(!PlayerInfo[giveplayerid][pBeingSentenced]) return SendClientMessageEx(playerid, COLOR_GRAD5, "Nguoi do khong dang cho tuyen an!");
	SetPVarInt(playerid, "judgefine", judgefine);
	SetPVarInt(playerid, "jfined", giveplayerid);
	SetPVarString(playerid, "jreason", reason);
	Group_ListGroups(playerid, DIALOG_JFINECONFIRM);
	return 1;
}

CMD:probation(playerid, params[])
{
    if(!IsAJudge(playerid))
	{
        SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong thuoc Judicial System!");
        return 1;
    }
    if(PlayerInfo[playerid][pRank] < 3)
	{
        SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay, can cap bac 3+.");
        return 1;
    }

	new giveplayerid, probtime, reason[64];
	if(sscanf(params, "uds[64]", giveplayerid, probtime, reason)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /probation [player] [time 1-360 Minutes] [reason and terms]");

    if(giveplayerid == playerid) return SendClientMessageEx(playerid, COLOR_GRAD1, "Khong the dung lenh nay cho chinh minh!");
    if(IsPlayerConnected(giveplayerid))
	{
        if(!PlayerInfo[giveplayerid][pBeingSentenced]) return SendClientMessageEx(playerid, COLOR_GRAD5, "Nguoi do khong dang cho tuyen an!");
        if(probtime < 1 && probtime > 360) return SendClientMessageEx(playerid, COLOR_GRAD5, "Thoi gian khong duoc duoi 1 phut hoac tren 360 phut!");
        PlayerInfo[giveplayerid][pProbationTime] = probtime;
        SendClientMessageEx(playerid, COLOR_WHITE, "Ban da dat %s quan che %d phut, ly do va dieu kien: %s", GetPlayerNameEx(giveplayerid), probtime, reason);
        SendClientMessageEx(giveplayerid, COLOR_WHITE, "Ban bi quan che %d phut boi %s, ly do va dieu kien: %s", probtime, GetPlayerNameEx(playerid), reason);
    }
    return 1;
}

CMD:viewassets(playerid, params[])
{
  	if(!IsAJudge(playerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong thuoc Judicial System!");
	if(PlayerInfo[playerid][pRank] < 5) return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong du quyen, chi rank 5+ duoc dung lenh nay.");
	
	new giveplayerid;

	if(sscanf(params, "u", giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /viewassets [player]");
	if(!IsPlayerConnected(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi khong hop le.");
	
	SendClientMessageEx(playerid, COLOR_WHITE, "Tai san %s | Trang thai xe: %d - Nha: %d - Tai khoan: %d", GetPlayerNameEx(giveplayerid), PlayerInfo[giveplayerid][pFreezeCar], PlayerInfo[giveplayerid][pFreezeHouse], PlayerInfo[giveplayerid][pFreezeBank]);
	SendClientMessageEx(playerid, COLOR_WHITE, "Tai san %s | Tien: $%s - Bank: $%s", GetPlayerNameEx(giveplayerid), number_format(PlayerInfo[giveplayerid][pCash]), number_format(PlayerInfo[giveplayerid][pAccount]));
	return true;
}

CMD:alimony(playerid, params[]) {

	if(!IsAJudge(playerid)) 
  		return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong thuoc Judicial System!");
	if(PlayerInfo[playerid][pRank] < 3) 
  		return SendClientMessageEx(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay, can cap bac 3+.");
  	new charged, recieved, amount;
  	if(sscanf(params, "iii", charged, amount, recieved)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /alimony [charging id] [percentage] [reciever id]");
  	if(charged == playerid || recieved == playerid) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the dung lenh nay voi chinh minh!");
  	
  	new totalwealth = PlayerInfo[charged][pAccount] + GetPlayerCash(charged),
  		fine = amount * totalwealth / 100;
  	if(totalwealth < 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "Nguoi do mac no, hay lien he Admin.");  	
  	if(IsPlayerConnected(charged) || IsPlayerConnected(recieved))
	{
		if(amount < 5)
			return SendClientMessageEx(playerid, COLOR_GRAD2, "Ty le toi thieu la 5");
		if(amount > 25)
			return SendClientMessageEx(playerid, COLOR_GRAD2, "Ty le toi da khong duoc qua 25");
		if(fine < 300000) {
			SendClientMessageEx(playerid, COLOR_GRAD2, "Phi la $%d nhung duoi muc toi thieu, %s chi bi thu $300,000", fine, GetPlayerNameEx(charged));
			fine = 300000;			
		}
		if(fine > 2500000) {
			SendClientMessageEx(playerid, COLOR_GRAD2, "Phi la $%d nhung tren muc toi da, %s chi bi thu $2,500,000", fine, GetPlayerNameEx(charged));
			fine = 2500000;
		}

		GivePlayerCashEx(charged, TYPE_ONHAND, -fine);
		SendClientMessageEx(charged, COLOR_WHITE, "Ban bi thu $%d cap duong cho %s boi Judge %s.", fine, GetPlayerNameEx(recieved), GetPlayerNameEx(playerid));

		GivePlayerCashEx(recieved, TYPE_ONHAND, fine);
		SendClientMessageEx(recieved, COLOR_WHITE, "Ban nhan $%d tu %s lam cap duong.", fine, GetPlayerNameEx(recieved));

		foreach(new i: Player) {
			if(PlayerInfo[i][pAdmin] >= 3) {
			    format(szMiscArray, sizeof(szMiscArray), "Judicial: %s has charged %s $%d for alimony to %s", GetPlayerNameEx(playerid), GetPlayerNameEx(charged), fine, GetPlayerNameEx(recieved));
			    SendClientMessage(i, COLOR_LIGHTRED, szMiscArray);
			}
		}
	}
	else return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi do khong online!");
	return 1;
}

