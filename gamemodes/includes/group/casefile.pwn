/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Casefile System
							Winterfield

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

CMD:casefile(playerid, params[])
{
	if(arrGroupData[PlayerInfo[playerid][pMember]][gLEOArrest] != INVALID_RANK && PlayerInfo[playerid][pRank] > arrGroupData[PlayerInfo[playerid][pMember]][gLEOArrest])
	{
		ShowCasefileDialog(playerid);
	}
	return 1;
}

CMD:casefiles(playerid, params[])
{
	if(arrGroupData[PlayerInfo[playerid][pMember]][gLEOArrest] != INVALID_RANK && PlayerInfo[playerid][pRank] > arrGroupData[PlayerInfo[playerid][pMember]][gLEOArrest])
	{
		ListCasefiles(playerid, PlayerInfo[playerid][pMember]);
	}
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_CASEFILE:
		{
			if(!response) return ShowPlayerDialog(playerid, DIALOG_CASEFILE_QUIT, DIALOG_STYLE_MSGBOX, "Ho so vu an - Huy", "Ban muon thoat tao ho so vu an?\n(Luu y: Moi noi dung dang soan se bi xoa)", "Co", "Khong");
			switch(listitem)
			{
				case 0: return ShowPlayerDialog(playerid, DIALOG_CASEFILE_NAME, DIALOG_STYLE_INPUT, "Ho so vu an - Ten", "Nhap ten nghi pham. (( Firstname_Lastname ))", "Chon", "Huy");
				case 1: return ShowPlayerDialog(playerid, DIALOG_CASEFILE_INFO, DIALOG_STYLE_INPUT, "Ho so vu an - Thong tin", "Nhap mo ta ho so vu an. (( Toi da 256 ky tu. ))", "Chon", "Huy");
				case 2:
				{
					if(!GetPVarType(playerid, "CasefileName")) return ShowPlayerDialog(playerid, DIALOG_CASEFILE_NAME, DIALOG_STYLE_INPUT, "Ho so vu an - Ten", "Nhap ten nghi pham. (( Firstname_Lastname ))", "Chon", "Huy");
					else if(!GetPVarType(playerid, "CasefileInfo")) return ShowPlayerDialog(playerid, DIALOG_CASEFILE_INFO, DIALOG_STYLE_INPUT, "Ho so vu an - Thong tin", "Nhap mo ta ho so vu an. (( Toi da 256 ky tu. ))", "Chon", "Huy");
					else
					{
						new CasefileName[MAX_PLAYER_NAME], CasefileInfo[256];
						szMiscArray[0] = 0;

						GetPVarString(playerid, "CasefileName", CasefileName, sizeof(CasefileName));
						GetPVarString(playerid, "CasefileInfo", CasefileInfo, sizeof(CasefileInfo));

						mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "INSERT INTO `casefiles` (`suspect`, `issuer`, `information`, `group`, `active`) VALUES (`%s`, `%s`, `%s`, `%d`, `1`)", CasefileName, GetPlayerNameEx(playerid), CasefileInfo, PlayerInfo[playerid][pMember]);
						mysql_tquery(MainPipeline, szMiscArray, "OnQueryFinish", "ii", SENDDATA_THREAD, playerid);
					}	
				}
			}
		}
		case DIALOG_CASEFILE_NAME:
		{
			if(!response) return ShowCasefileDialog(playerid);
			else
			{
				if(strlen(inputtext) == 0)
				{
					SendClientMessage(playerid, -1, "Da xoa ten trong ho so vu an.");
					DeletePVar(playerid, "CasefileName");
				}
				szMiscArray[0] = 0;

				new escapeName[MAX_PLAYER_NAME];
				mysql_escape_string(inputtext, escapeName);
				SetPVarString(playerid, "CasefileName", escapeName);

				mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "SELECT `Username` FROM `accounts` WHERE `Username` = '%e'", inputtext);
				mysql_tquery(MainPipeline, szMiscArray, "OnCasefileName", "i", playerid);
			}
		}
		case DIALOG_CASEFILE_INFO:
		{
			if(!response) return ShowCasefileDialog(playerid);
			else
			{
				if(strlen(inputtext) == 0)
				{
					DeletePVar(playerid, "CasefileInfo");
					return SendClientMessage(playerid, -1, "Da xoa thong tin ho so vu an.");
				}
				else if(strlen(inputtext) < 257)
				{
					new escapeName[MAX_PLAYER_NAME];
					mysql_escape_string(inputtext, escapeName);
					SetPVarString(playerid, "CasefileInfo", escapeName);
					ShowCasefileDialog(playerid);
				}
			}
		}
		case DIALOG_CASEFILE_QUIT:
		{
			if(!response) ShowCasefileDialog(playerid);
			else
			{
				DeletePVar(playerid, "CasefileName");
				DeletePVar(playerid, "CasefileInfo");
			}
		}
	}
	return 1;
}

ShowCasefileDialog(playerid)
{
	new string[156], CasefileName[MAX_PLAYER_NAME];
	szMiscArray[0] = 0;

	if(!GetPVarType(playerid, "CasefileName")) format(CasefileName, sizeof(CasefileName), "Nobody");
	else GetPVarString(playerid, "CasefileName", CasefileName, sizeof(CasefileName));

	format(string, 156, "%s - Ho so vu an", arrGroupData[PlayerInfo[playerid][pMember]][g_szGroupName]);
	format(szMiscArray, sizeof(szMiscArray), "Ten: %s\n\
		Thong tin\n\
		Gui", CasefileName);

	return ShowPlayerDialog(playerid, DIALOG_CASEFILE, DIALOG_STYLE_LIST, string, szMiscArray, "Chon", "Huy");
}

ListCasefiles(playerid, group)
{
	szMiscArray[0] = 0;

	mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "SELECT * FROM `casefiles` WHERE `active` = 1 AND `group` = '%d'", group);
	mysql_tquery(MainPipeline, szMiscArray, "OnCasefileList", "i", playerid);
	return 1;
}

forward OnCasefileName(playerid);
public OnCasefileName(playerid)
{
	if(IsPlayerConnected(playerid))
	{
		new rows;
		cache_get_row_count(rows);
		if(rows) return ShowCasefileDialog(playerid);
		else 
		{
			DeletePVar(playerid, "CasefileName");
			return SendClientMessageEx(playerid, COLOR_WHITE, "Ten nay khong ton tai.");
		}
	}
	else DeletePVar(playerid, "CasefileName");
	return 1;
}

forward OnCasefileList(playerid);
public OnCasefileList(playerid)
{
	if(IsPlayerConnected(playerid))
	{
		new rows;
		cache_get_row_count(rows);
		if(rows) 
		{
			new PlayerName[MAX_PLAYER_NAME], suspect[MAX_PLAYER_NAME], issuer[MAX_PLAYER_NAME], information[256];
			for(new i; i < rows; i++)
			{
				cache_get_value_name(i, "suspect", suspect);
				cache_get_value_name(i, "issuer", issuer);
				cache_get_value_name(i, "information", information);

				foreach(new d: Player)
				{
					GetPlayerName(d, PlayerName, sizeof(PlayerName));
					if(strfind(PlayerName, suspect, true) != -1)
					{ 
						SendClientMessageEx(playerid, COLOR_GREEN, "%s (ID: %d) | Nguoi lap: %s | Noi dung: %s", GetPlayerNameEx(d), d, issuer, information);
					}
				}
			}
			for(new i; i < rows; i++)
			{
				cache_get_value_name(i, "suspect", suspect);
				cache_get_value_name(i, "issuer", issuer);
				cache_get_value_name(i, "information", information);

				SendClientMessageEx(playerid, COLOR_GREY, "%s | Nguoi lap: %s | Noi dung: %s",suspect, issuer, information);
			}
		}
		else return SendClientMessageEx(playerid, COLOR_WHITE, "To chuc cua ban khong co ho so vu an.");
	}
	return 1;
}