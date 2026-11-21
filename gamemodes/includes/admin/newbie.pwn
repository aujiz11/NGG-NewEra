#include <YSI_Coding\y_hooks>

CMD:newb(playerid, params[]) {

	szMiscArray[0] = 0;

	if(PlayerInfo[playerid][pNMute] == 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban da bi cam chat tren kenh ho tro nguoi moi.");
	if(PlayerInfo[playerid][pToggledChats][0]) return SendClientMessageEx(playerid, COLOR_GREY, "Ban da tat kenh nay, dung /tog newbie de bat lai!");
	if(PlayerInfo[playerid][pTut] == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua the lam viec nay.");
	if(nonewbie) return SendClientMessageEx(playerid, COLOR_GRAD2, "Admin da tat kenh ho tro nguoi moi!");

	if(GetPVarType(playerid, "HasNewbQues")) {
		SendClientMessageEx(playerid, COLOR_GREY, "Ban da co cau hoi dang cho tra loi.");
		return SendClientMessageEx(playerid, COLOR_GREY, "Dung /cancelnewbie de huy va gui cau hoi moi!");
	}

	ShowPlayerDialogEx(playerid, SEND_NEWBIE, DIALOG_STYLE_INPUT, "Gui cau hoi Newbie", "Nhap cau hoi cua ban\nKenh nay chi ho tro cau hoi ve tinh nang va may chu.", "Gui", "Huy");

	return 1;
}

CMD:cancelnewbie(playerid, params[]) {

	SendClientMessageEx(playerid, COLOR_WHITE, "Ban da huy cau hoi.");
	ClearNewbVars(playerid);
	return 1;
}

CMD:newbquestions(playerid, params[]) {

	if(PlayerInfo[playerid][pAdmin] >= 1 || PlayerInfo[playerid][pHelper] > 0) {
		GetNewbieQuestions(playerid);
	}

	return 1;
}

CMD:an(playerid, params[]) { 
	
	szMiscArray[0] = 0;

	new id;

	if(sscanf(params, "u", id)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /an [playerid]");
	if(!IsPlayerConnected(id)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi do da ngat ket noi!");
	if(!GetPVarType(id, "HasNewbQues")) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi do chua gui cau hoi!");
	if(GetPVarType(id, "NewbBeingAnswered")) return SendClientMessageEx(playerid, COLOR_GREY, "Mot Helper khac dang tra loi cau hoi nay!");

	if(PlayerInfo[playerid][pAdmin] >= 1 || PlayerInfo[playerid][pHelper] > 0) {

		SetPVarInt(playerid, "AnsweringNewb", id);
		SetPVarInt(id, "NewbBeingAnswered", playerid);
		GetPVarString(id, "HasNewbQues", szMiscArray, 128);
		format(szMiscArray, sizeof(szMiscArray), "%s (ID:%d) Hoi: %s\nNhap cau tra loi ben duoi!", GetPlayerNameEx(id), id, szMiscArray);
		ShowPlayerDialogEx(playerid, ACCEPT_NEWBIE, DIALOG_STYLE_INPUT, "Tra loi Newbie", szMiscArray, "Tra loi", "");
	}

	return 1;
}

CMD:tn(playerid, params[]) {
	
	szMiscArray[0] = 0;

	new id;

	if(sscanf(params, "u", id)) return SendClientMessageEx(playerid, COLOR_GREY, "CACH DUNG: /tn [playerid]");
	if(!IsPlayerConnected(id)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi do da ngat ket noi!");
	if(!GetPVarType(id, "HasNewbQues")) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi do chua gui cau hoi!");
	if(GetPVarType(id, "NewbBeingAnswered")) return SendClientMessageEx(playerid, COLOR_GREY, "Mot Helper khac dang tra loi cau hoi nay!");


	if(PlayerInfo[playerid][pAdmin] >= 1 || PlayerInfo[playerid][pHelper] > 0) {

		SetPVarInt(playerid, "AnsweringNewb", id);
		SetPVarInt(id, "NewbBeingAnswered", playerid);
		GetPVarString(id, "HasNewbQues", szMiscArray, 128);
		
		ShowPlayerDialogEx(playerid, DENY_NEWBIE, DIALOG_STYLE_LIST, "Ly do tu choi cau hoi", "Khong phai cau hoi\nVan de IC\nSpam", "Chon","");
	}

	return 1;
}

SendNewbQuestionToQueue(iPlayerID, szQuestion[]) {

	szMiscArray[0] = 0;

	SetPVarString(iPlayerID, "HasNewbQues", szQuestion);

	format(szMiscArray, sizeof(szMiscArray), "Newb: %s (ID:%d) H: %s", GetPlayerNameEx(iPlayerID), iPlayerID, szQuestion);

	foreach(new i : Player) {
		if((PlayerInfo[i][pAdmin] >= 1 || PlayerInfo[i][pHelper] > 0))
			
			ChatTrafficProcess(i, COLOR_NEWBIE, szMiscArray, 0);
	}

	SendClientMessageEx(iPlayerID, COLOR_WHITE, "Da gui cau hoi cua ban.");

	return 1;
}

ClearNewbVars(iPlayerID) {
	
	DeletePVar(iPlayerID, "HasNewbQues");
	DeletePVar(GetPVarInt(iPlayerID, "NewbBeingAnswered"), "AnsweringNewb");
	DeletePVar(iPlayerID, "NewbBeingAnswered");

	return 1;
}

AnswerNewbie(iPlayerID, iNewbieID, szAnswer[]) {

	szMiscArray[0] = 0;

	if(!GetPVarType(iNewbieID, "HasNewbQues")) return SendClientMessageEx(iPlayerID, COLOR_GREY, "Nguoi choi do khong co cau hoi dang cho!");

	GetPVarString(iNewbieID, "HasNewbQues", szMiscArray, 128);

	format(szMiscArray, sizeof(szMiscArray), "Q: (%s): %s", GetPlayerNameEx(iNewbieID), szMiscArray);
	SendGlobalNewbMsg(szMiscArray);
	Log("logs/newbiechat.log", szMiscArray);

	szMiscArray[0] = 0;

	format(szMiscArray, sizeof(szMiscArray), "A: (%s): %s", GetPlayerNameEx(iPlayerID), szAnswer);
	SendGlobalNewbMsg(szMiscArray);
	Log("logs/newbiechat.log", szMiscArray);

	if(PlayerInfo[iPlayerID][pHelper] == 1 && PlayerInfo[iPlayerID][pAdmin] < 1) {
		ReportCount[iPlayerID]++;
		ReportHourCount[iPlayerID]++;
		AddCAReportToken(iPlayerID); // Advisor Tokens
	}

	SendClientMessageEx(iNewbieID, COLOR_NEWBIE, "Cau hoi da duoc tra loi! Can ho tro them, dung [/requesthelp].");

	ClearNewbVars(iNewbieID);

	return 1;
}

SendGlobalNewbMsg(const szMessage[]) {
	
	foreach(new i : Player) {
		if(PlayerInfo[i][pToggledChats][0] == 0) {
			SendClientMessageEx(i, COLOR_NEWBIE, szMessage);
		}
	}
	return 1;
}

GetNewbieQuestions(iPlayerID) {
	
	szMiscArray[0] = 0;

	SendClientMessageEx(iPlayerID, COLOR_GREEN,"_______________________________________");
	foreach(new i : Player) {
		if(GetPVarType(i, "HasNewbQues")) {
			GetPVarString(i, "HasNewbQues", szMiscArray, 128);
			format(szMiscArray, sizeof(szMiscArray), "Newb: %s (ID:%d) H: %s", GetPlayerNameEx(i), i, szMiscArray);
			SendClientMessageEx(iPlayerID, COLOR_NEWBIE, szMiscArray);
		}
	}
	SendClientMessageEx(iPlayerID, COLOR_GREEN,"_______________________________________");
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	switch(dialogid) {
		
		case SEND_NEWBIE: {

			if(response) {
				
				if(isnull(inputtext)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Noi dung khong duoc de trong!");
				if(strlen(inputtext) > 110) return SendClientMessageEx(playerid, COLOR_GRAD2, "Noi dung qua dai!");

				SendNewbQuestionToQueue(playerid, inputtext);
			}
		}

		case ACCEPT_NEWBIE: {

			if(response) {
				if(isnull(inputtext)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Noi dung khong duoc de trong!");
				if(strlen(inputtext) > 110) {
					DeletePVar(GetPVarInt(playerid, "AnsweringNewb"), "NewbBeingAnswered");
					DeletePVar(playerid, "AnsweringNewb");
					return SendClientMessageEx(playerid, COLOR_GRAD2, "Noi dung qua dai!");
				}

				AnswerNewbie(playerid, GetPVarInt(playerid, "AnsweringNewb"), inputtext);
			}
			else {
				
				DeletePVar(GetPVarInt(playerid, "AnsweringNewb"), "NewbBeingAnswered");
				DeletePVar(playerid, "AnsweringNewb");
			}
		}

		case DENY_NEWBIE: {

			if(response) {	
				new id = GetPVarInt(playerid, "AnsweringNewb");

				switch(listitem) {
				
					case 0: {
						SendClientMessageEx(id, COLOR_WHITE, "Tin nhan bi tu choi vi khong phai cau hoi.");
					}

					case 1: {
						SendClientMessageEx(id, COLOR_WHITE, "Cau hoi bi tu choi vi lien quan den van de IC.");
						SendClientMessageEx(id, COLOR_WHITE, "Kenh /newb chi ho tro cau hoi ve tinh nang va may chu.");
					}

					case 2: {
						SendClientMessageEx(id, COLOR_WHITE, "Tin nhan bi tu choi vi bi xem la spam.");
						SendClientMessageEx(id, COLOR_WHITE, "Tiep tuc lam dung se bi cam chat hoac xu ly them.");
					}

				}

				ClearNewbVars(id);	
			}
			else {
				
				DeletePVar(GetPVarInt(playerid, "AnsweringNewb"), "NewbBeingAnswered");
				DeletePVar(playerid, "AnsweringNewb");
			}
			
		}
	}
	return 0;
}

hook OnPlayerDisconnect(playerid, reason) {

	// cancel newbie report if they have one
	ClearNewbVars(playerid);

	return 1;
}