/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Election System
							Jingles

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

#define MAX_ELECTION_CANDIDATES (128)

new ElectionGeneration, ElectionRound[37];

hook OnGameModeInit() {
	LoadElections();
	return 1;
}

hook OnGameModeExit() {
	UnloadElections();
	return 1;
}

LoadElections() {
	DeleteGVar("ElectionActive");
	DeleteGVar("ElectionCounting");
	ElectionRound[0] = EOS;
	++ElectionGeneration;
	SetGVarInt("ElectionArea", CreateDynamicSphere(366.54, 159.09, 1008.38, 100.0));
	return 1;
}

UnloadElections() {
	if(IsValidDynamicArea(GetGVarInt("ElectionArea"))) {
		DestroyDynamicArea(GetGVarInt("ElectionArea"));
	}
	DeleteGVar("ElectionArea");
	DeleteGVar("ElectionActive");
	DeleteGVar("ElectionCounting");
	ElectionRound[0] = EOS;
	++ElectionGeneration;
	return 1;
}

hook OnPlayerEnterDynamicArea(playerid, areaid) {
	if(areaid == GetGVarInt("ElectionArea") && GetGVarInt("ElectionActive") && gPlayerLogged{playerid}) 
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban da vao khu bau cu. Nhan Y de bo phieu.");
	}
	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if((newkeys & KEY_YES) && !(oldkeys & KEY_YES) && IsPlayerInDynamicArea(playerid, GetGVarInt("ElectionArea"))) 
	{
		ShowElectionMenu(playerid);
	}
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	if(dialogid != ELECTIONS && dialogid != ELECTIONS_ADD && dialogid != ELECTIONS_REMOVE) return 0;
	if(!gPlayerLogged{playerid}) return 1;
	if(!response) return 1;
	if(!GetPVarType(playerid, "ElectionMenuGeneration") || GetPVarInt(playerid, "ElectionMenuGeneration") != ElectionGeneration || GetGVarInt("ElectionCounting")) return SendClientMessageEx(playerid, COLOR_GREY, "Menu bau cu da doi. Hay mo lai.");

	new count = GetGVarInt("CandidateCount");
	if(!(0 <= count <= MAX_ELECTION_CANDIDATES)) return 1;
	if(dialogid == ELECTIONS) {
		if(GetPVarInt(playerid, "ElectionMenuOpen") != GetGVarInt("ElectionActive")) 
			return SendClientMessageEx(playerid, COLOR_GREY, "Trang thai bau cu da doi. Hay mo lai menu.");
		
		if(0 <= listitem < count) {
			DeletePVar(playerid, "ElectionMenuGeneration");
			return CastVote(playerid, listitem);
		}
		if(PlayerInfo[playerid][pAdmin] < 1337) 
			return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen quan ly bau cu.");
		
		if(GetGVarInt("ElectionActive")) {
			if(listitem == count) return CountVotes(playerid);
			return 1;
		}
		switch(listitem - count) {
			case 0: return ShowPlayerDialogEx(playerid, ELECTIONS_ADD, DIALOG_STYLE_INPUT, "Them ung vien", "Nhap ten ung vien, toi da 24 ky tu.", "Them", "Huy");
			case 1: {
				if(!count) 
					return SendClientMessageEx(playerid, COLOR_GREY, "Khong co ung vien de xoa.");
				
				szMiscArray[0] = EOS;
				new name[MAX_PLAYER_NAME + 1];
				for(new i; i < count; ++i) {
					GetGVarString("CandidateName", name, sizeof name, i);
					format(szMiscArray, sizeof szMiscArray, "%s%s%s", szMiscArray, i ? ("\n") : (""), name);
				}
				return ShowPlayerDialogEx(playerid, ELECTIONS_REMOVE, DIALOG_STYLE_LIST, "Xoa ung vien", szMiscArray, "Bo", "Huy");
			}
			case 2: return StartElections(playerid);
		}
		return 1;
	}
	if(PlayerInfo[playerid][pAdmin] < 1337 || GetGVarInt("ElectionActive")) return SendClientMessageEx(playerid, COLOR_GREY, "Chi Admin duoc sua ung vien khi bau cu dang dong.");
	new name[MAX_PLAYER_NAME + 1], message[128];
	if(dialogid == ELECTIONS_ADD) {
		if(count >= MAX_ELECTION_CANDIDATES) 
			return SendClientMessageEx(playerid, COLOR_GREY, "Danh sach ung vien da day.");
		
		if(isnull(inputtext) || strlen(inputtext) > MAX_PLAYER_NAME || IsNumericString(inputtext)) 
			return SendClientMessageEx(playerid, COLOR_GREY, "Nhap ten ung vien hop le, toi da 24 ky tu.");
		
		for(new i; inputtext[i]; ++i) {
			if(inputtext[i] < 32 || inputtext[i] == '{' || inputtext[i] == '}') {
				return SendClientMessageEx(playerid, COLOR_GREY, "Ten ung vien khong duoc co ky tu dieu khien hoac ma mau.");
			}
		}

		for(new i; i < count; ++i) {
			GetGVarString("CandidateName", name, sizeof name, i);
			if(!strcmp(name, inputtext, true)) return SendClientMessageEx(playerid, COLOR_GREY, "Ung vien do da co trong danh sach.");
		}
		SetGVarString("CandidateName", inputtext, count);
		SetGVarInt("CandidateCount", count + 1);
		++ElectionGeneration;
		SendClientMessageEx(playerid, COLOR_YELLOW, "Da them %s lam ung vien so %d.", inputtext, count + 1);
		format(message, sizeof message, "%s added %s as election candidate no. %d.", GetPlayerNameExt(playerid), inputtext, count + 1);
	}
	else {
		if(!(0 <= listitem < count)) return 1;
		GetGVarString("CandidateName", name, sizeof name, listitem);
		format(message, sizeof message, "%s removed %s as election candidate no. %d.", GetPlayerNameExt(playerid), name, listitem + 1);
		SendClientMessageEx(playerid, COLOR_YELLOW, "Da xoa %s khoi ung vien so %d.", name, listitem + 1);
		for(new i = listitem; i < count - 1; ++i) {
			GetGVarString("CandidateName", name, sizeof name, i + 1);
			SetGVarString("CandidateName", name, i);
		}
		DeleteGVar("CandidateName", count - 1);
		SetGVarInt("CandidateCount", count - 1);
		++ElectionGeneration;
	}
	Log("logs/elections.log", message);
	return ShowElectionMenu(playerid);
}

StartElections(playerid) {
	if(!gPlayerLogged{playerid} || PlayerInfo[playerid][pAdmin] < 1337) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen quan ly bau cu.");
	
	if(GetGVarInt("ElectionActive") || GetGVarInt("ElectionCounting")) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Dang co bau cu hoac kiem phieu.");
	
	if(!(0 < GetGVarInt("CandidateCount") <= MAX_ELECTION_CANDIDATES)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Them ung vien truoc khi mo bau cu.");
	
	new Cache:result = mysql_query(MainPipeline, "SELECT UUID() AS roundid,GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS key_columns FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='electionresults' AND NON_UNIQUE=0 GROUP BY INDEX_NAME");
	if(!cache_is_valid(result)) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Khong the khoi tao bau cu. Kiem tra ket noi co so du lieu.");
	
	new rows, key[64], bool:accountKey, bool:ipKey;
	cache_get_row_count(rows);
	for(new i; i < rows; ++i) {
		cache_get_value_name(i, "key_columns", key, sizeof key);
		if(!strcmp(key, "electionid,accountid", true)) accountKey = true;
		if(!strcmp(key, "electionid,ip", true)) ipKey = true;
	}
	if(!accountKey || !ipKey) {
		cache_delete(result);
		return SendClientMessageEx(playerid, COLOR_GREY, "Luu tru bau cu khong kha dung. Import database/electionresults.sql truoc khi bat dau.");
	}
	cache_get_value_name(0, "roundid", ElectionRound, sizeof ElectionRound);
	cache_delete(result);
	++ElectionGeneration;
	SetGVarInt("ElectionActive", 1);
	SendClientMessageToAll(COLOR_WHITE, "[ELECTION NEWS] Bau cu da bat dau.");
	SendClientMessageToAll(COLOR_WHITE, "[ELECTION NEWS] Den City Hall de bo phieu.");
	return 1;
}

CastVote(playerid, iOptionID) {
	if(!gPlayerLogged{playerid} || !GetGVarInt("ElectionActive") || !ElectionRound[0]) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Hien khong co bau cu.");
	
	if(!(0 <= iOptionID < GetGVarInt("CandidateCount"))) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ung vien duoc chon khong hop le.");
	
	if(PlayerInfo[playerid][pNation] != 0) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai cong dan San Andreas.");
	
	if(PlayerInfo[playerid][pConnectHours] < 32 && PlayerInfo[playerid][pAdmin] < 1337) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua choi du lau de bo phieu.");
	
	if(!IsPlayerInDynamicArea(playerid, GetGVarInt("ElectionArea"))) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai o City Hall de bo phieu.");
	
	if(GetPlayerSQLId(playerid) <= 0) return 1;
	new query[384], candidate[MAX_PLAYER_NAME + 1], ip[16];
	GetGVarString("CandidateName", candidate, sizeof candidate, iOptionID);
	if(!candidate[0]) return SendClientMessageEx(playerid, COLOR_GREY, "Ung vien do khong con kha dung.");
	GetPlayerIp(playerid, ip, sizeof ip);
	mysql_format(MainPipeline, query, sizeof query, "INSERT IGNORE INTO `electionresults` (`electionid`,`accountid`,`optionid`,`candidate_name`,`ip`) VALUES ('%e',%d,%d,'%e','%e')", ElectionRound, GetPlayerSQLId(playerid), iOptionID, candidate, ip);
	if(!mysql_tquery(MainPipeline, query, "OnFinaliseVote", "iii", playerid, g_arrQueryHandle[playerid], ElectionGeneration)) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the gui phieu bau. Hay thu lai.");
	return 1;
}

forward OnFinaliseVote(playerid, session, generation);
public OnFinaliseVote(playerid, session, generation) {
	if(!IsPlayerConnected(playerid) || !gPlayerLogged{playerid} || g_arrQueryHandle[playerid] != session || generation != ElectionGeneration) return 1;
	if(cache_affected_rows() == 1) {
		SendClientMessageEx(playerid, COLOR_WHITE, "Ban da bo phieu.");
	}
	else {
		SendClientMessageEx(playerid, COLOR_WHITE, "Tai khoan hoac dia chi IP cua ban da bo phieu trong dot nay.");
	}
	return 1;
}

CountVotes(playerid) {
	if(!gPlayerLogged{playerid} || PlayerInfo[playerid][pAdmin] < 1337) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen quan ly bau cu.");
	
	if(!GetGVarInt("ElectionActive") || GetGVarInt("ElectionCounting")) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Khong co bau cu de ket thuc.");
	
	DeleteGVar("ElectionActive");
	SetGVarInt("ElectionCounting", 1);
	new query[192];
	mysql_format(MainPipeline, query, sizeof query, "SELECT `optionid`,COUNT(*) AS votes FROM `electionresults` WHERE `electionid`='%e' GROUP BY `optionid`", ElectionRound);
	if(!mysql_tquery(MainPipeline, query, "OnCountVotes", "i", ElectionGeneration)) {
		DeleteGVar("ElectionCounting");
		return SendClientMessageEx(playerid, COLOR_GREY, "Khong the kiem phieu. Bo phieu da dong, cac phieu da luu duoc giu nguyen.");
	}
	return 1;
}

forward OnCountVotes(generation);
public OnCountVotes(generation) {
	if(generation != ElectionGeneration || !GetGVarInt("ElectionCounting")) return 1;
	new 
		rows, option, votes, results[MAX_ELECTION_CANDIDATES], 
		count = GetGVarInt("CandidateCount"), name[MAX_PLAYER_NAME + 1];

	cache_get_row_count(rows);
	for(new i; i < rows; ++i) {
		cache_get_value_name_int(i, "optionid", option);
		cache_get_value_name_int(i, "votes", votes);
		if(0 <= option < count && option < MAX_ELECTION_CANDIDATES) results[option] = votes;
	}
	SendClientMessageToAll(COLOR_WHITE, "[ELECTION NEWS] Bau cu da ket thuc. Ket qua:");
	for(new i; i < count && i < MAX_ELECTION_CANDIDATES; ++i) {
		GetGVarString("CandidateName", name, sizeof name, i);
		SendClientMessageToAllEx(COLOR_WHITE, "%s - %d phieu.", name, results[i]);
	}
	DeleteGVar("ElectionCounting");
	return 1;
}

ShowElectionMenu(playerid) {
	if(!gPlayerLogged{playerid}) return 1;
	if(GetGVarInt("ElectionCounting")) 
		return SendClientMessageEx(playerid, COLOR_GREY, "Dang kiem phieu bau cu. Vui long cho.");
	
	if(PlayerInfo[playerid][pAdmin] < 1337) {
		if(!GetGVarInt("ElectionActive")) 
			return SendClientMessageEx(playerid, COLOR_GREY, "Hien khong co bau cu.");
		
		if(PlayerInfo[playerid][pNation] != 0) 
			return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong phai cong dan San Andreas.");
		
		if(PlayerInfo[playerid][pConnectHours] < 32) 
			return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua choi du lau de bo phieu.");
		
		if(!IsPlayerInDynamicArea(playerid, GetGVarInt("ElectionArea"))) 
			return SendClientMessageEx(playerid, COLOR_GREY, "Ban phai o City Hall de bo phieu.");
	}

	new name[MAX_PLAYER_NAME + 1], count = GetGVarInt("CandidateCount");
	if(!(0 <= count <= MAX_ELECTION_CANDIDATES)) return 1;
	szMiscArray[0] = EOS;
	for(new i; i < count; ++i) {
		GetGVarString("CandidateName", name, sizeof name, i);
		format(szMiscArray, sizeof szMiscArray, "%s%s%s", szMiscArray, i ? ("\n") : (""), name);
	}
	if(PlayerInfo[playerid][pAdmin] >= 1337) {
		if(count) strcat(szMiscArray, "\n");
		if(GetGVarInt("ElectionActive")) strcat(szMiscArray, "Ket thuc bau cu");
		else strcat(szMiscArray, "Them ung vien\nXoa ung vien\nMo bau cu");
	}
	SetPVarInt(playerid, "ElectionMenuGeneration", ElectionGeneration);
	SetPVarInt(playerid, "ElectionMenuOpen", GetGVarInt("ElectionActive"));
	return ShowPlayerDialogEx(playerid, ELECTIONS, DIALOG_STYLE_LIST, "Bau cu chinh phu", szMiscArray, "Chon", "Dong");
}

CMD:elections(playerid, params[]) {
	if(GetGVarInt("ElectionActive")) return CountVotes(playerid);
	return StartElections(playerid);
}