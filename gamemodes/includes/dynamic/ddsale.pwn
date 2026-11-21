#include <YSI_Coding\y_hooks>

ClearDoorSaleVariables(playerid)
{
	stop DDSaleTimer[playerid];
	DDSalePendingAdmin[playerid] = false;
	DDSalePendingPlayer[playerid] = false;
	DDSaleTarget[playerid] = INVALID_PLAYER_ID;
	DDSalePrice[playerid] = 0;
	DDSaleTracking[playerid] = 0;
	for(new i = 0; i < sizeof(DDSaleDoors[]); i ++) DDSaleDoors[playerid][i] = 0;
	return 1;
}

CalculatePercentage(source, percentage, minimum)
{
	new amount;
	amount = percentage * source / 100;
	if(amount < minimum) amount = minimum;
	return amount;
}

ReturnDoorLineDetails(playerid, doorid)
{
	new string[32];
	string = "N/A";
	if(doorid != 0 && GetPlayerSQLId(playerid) == DDoorsInfo[doorid][ddOwner]) format(string, sizeof(string), "%d (%s)", doorid, DDoorsInfo[doorid][ddDescription]);
	return string;
}

ShowDynamicDoorDialog(playerid)
{
	if(!IsPlayerConnected(DDSaleTarget[playerid]) || DDSaleTarget[playerid] == INVALID_PLAYER_ID)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "Nguoi mua da thoat.");
		ClearDoorSaleVariables(playerid);
		return 1;
	}
	if(DDSalePendingPlayer[playerid] == true) return SendClientMessageEx(playerid, COLOR_GREY, "Giao dich cua dong dang cho nguoi mua chap nhan.");
	if(DDSalePendingAdmin[playerid] == true) return SendClientMessageEx(playerid, COLOR_GREY, "Giao dich cua dong dang cho Admin duyet.");
	szMiscArray[0] = 0;
	format(szMiscArray, sizeof(szMiscArray), "Cai dat\tGia tri\nNguoi mua\t%s\nGia\t$%s\nPhi nguoi ban\t$%s\nCua dong 1\t%s\nCua dong 2\t%s\nCua dong 3\t%s\nCua dong 4\t%s\nCua dong 5\t%s\nGarage 1\t%s\nGarage 2\t%s\nHoan tat va gui", 
	GetPlayerNameEx(DDSaleTarget[playerid]), number_format(DDSalePrice[playerid]), number_format(CalculatePercentage(DDSalePrice[playerid], 10, 1000000)),
	ReturnDoorLineDetails(playerid, DDSaleDoors[playerid][0]), ReturnDoorLineDetails(playerid, DDSaleDoors[playerid][1]), ReturnDoorLineDetails(playerid, DDSaleDoors[playerid][2]), 
	ReturnDoorLineDetails(playerid, DDSaleDoors[playerid][3]), ReturnDoorLineDetails(playerid, DDSaleDoors[playerid][4]), ReturnGarageLineDetails(playerid, DDSaleDoors[playerid][5]), ReturnGarageLineDetails(playerid, DDSaleDoors[playerid][6]));
	ShowPlayerDialogEx(playerid, DIALOG_DDSALEMAIN, DIALOG_STYLE_TABLIST_HEADERS, "Ban cua dong", szMiscArray, "Dong y", "Huy");
	return 1;
}

task DynamicDoorSellRequests[60000]()
{
	new bool:notification;
	foreach(new i : Player)
	{
		if(gPlayerLogged{i} == 1 && DDSalePendingAdmin[i] == true)
		{
			notification = true;
			break;
		}
	}
	if(notification == true)
	{
		ABroadCastText(COLOR_LIGHTRED, "Co yeu cau ban cua dong dang cho duyet.", 4, true);
		return 1;
	}
	return 1;
}

timer DDSaleTimerEx[30000](playerid)
{
	if(IsPlayerConnected(playerid) && !IsPlayerNPC(playerid) && playerid != INVALID_PLAYER_ID)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "De nghi ban cua (nguoi mua: %s) da het han.", GetPlayerNameEx(DDSaleTarget[playerid]));
		SendClientMessageEx(DDSaleTarget[playerid], COLOR_GREY, "De nghi ban cua dong tu %s da het han.", GetPlayerNameEx(playerid));
		ClearDoorSaleVariables(playerid);
		return 1;
	}
	return 1;
}




CMD:doorsalehelp(playerid, params[])
{
	SendClientMessageEx(playerid, COLOR_WHITE, "** LENH BAN CUA DONG **");
	SendClientMessageEx(playerid, COLOR_GREY, "* /selldoors [Part Of Name/ ID] - Ban cua dong cho nguoi choi voi gia chi dinh.");
	SendClientMessageEx(playerid, COLOR_GREY, "* /cancel door - Huy yeu cau ban cua dong dang cho Admin duyet.");
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "* {EE9A4D}SENIOR ADMIN{D8D8D8} /doorrequests - Xem yeu cau ban cua dong dang cho duyet.");
		SendClientMessageEx(playerid, COLOR_GREY, "* {EE9A4D}SENIOR ADMIN{D8D8D8} /doorsaleinfo - Xem chi tiet yeu cau ban cua dong.");
		SendClientMessageEx(playerid, COLOR_GREY, "* {EE9A4D}SENIOR ADMIN{D8D8D8} /(a)pprove(d)oorsale [Part Of Name/ ID] - Duyet giao dich ban cua dong.");
		SendClientMessageEx(playerid, COLOR_GREY, "* {EE9A4D}SENIOR ADMIN{D8D8D8} /(d)enydoor(s)ale [Part Of Name/ ID] - Tu choi giao dich ban cua dong.");
		return 1;
	}
	return 1;
}

CMD:selldoors(playerid, params[])
{
	if(gPlayerLogged{playerid} == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Ban chua dang nhap tai khoan.");
	if(GetPVarType(playerid, "Injured")) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the ban cua dong khi bi thuong.");
	if(PlayerCuffed[playerid] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the ban cua dong khi bi cong tay.");
	if(PlayerInfo[playerid][pJailTime] > 0) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the ban cua dong khi o tu.");
	new target;
	if(sscanf(params, "u", target)) return SendClientMessageEx(playerid, COLOR_GREY, "[USAGE]: /selldoors [Part Of Name/ ID]");
	if(!IsPlayerConnected(target)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi do khong ket noi.");
	if(target == playerid) return SendClientMessageEx(playerid, COLOR_GREY, "Khong the ban cua dong cho chinh minh.");
	if(GetPlayerCash(playerid) < 1000000) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien tra phi chuyen nhuong toi thieu $1,000,000.");
	if(gPlayerLogged{target} == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi do chua dang nhap tai khoan.");
	if(DDSalePendingPlayer[playerid] == true || DDSalePendingAdmin[playerid] == true) return SendClientMessageEx(playerid, COLOR_GREY, "Ban da co de nghi ban cua dong, dung (/cancel door) de huy.");
	foreach(new i : Player) if(DDSaleTarget[i] == target) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi khac da gui de nghi ban cua dong cho nguoi choi nay.");
	ClearDoorSaleVariables(playerid);
	DDSaleTarget[playerid] = target;
	ShowDynamicDoorDialog(playerid);
	return 1;
}

CMD:doorrequests(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	new count;
	SendClientMessageEx(playerid, COLOR_WHITE, "** YEU CAU BAN CUA DONG CHO DUYET: **");
	foreach(new i : Player)
	{
		if(gPlayerLogged{i} == 1 && DDSalePendingAdmin[i] == true)
		{
			SendClientMessageEx(playerid, COLOR_GREY, "(ID: %d) %s", i, GetPlayerNameEx(i));
			count ++;
		}
	}
	if(count == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Hien khong co yeu cau ban cua dong cho duyet.");
	return 1;
}

CMD:doorsaleinfo(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	new target;
	if(sscanf(params, "u", target)) return SendClientMessageEx(playerid, COLOR_GREY, "[USAGE]: /doorsaleinfo [Part Of Name/ ID]");
	if(!IsPlayerConnected(target)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi do khong ket noi.");
	if(gPlayerLogged{target} == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi do chua dang nhap tai khoan.");
	if(DDSalePendingAdmin[target] == false) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi do khong co yeu cau ban cua dong dang cho duyet.");
	szMiscArray[0] = 0;
	format(szMiscArray, sizeof(szMiscArray), "Thong tin chung:\n\n  * Nguoi ban: %s\n  * Nguoi mua: %s\n  * Gia: $%s\n  * Phi: $%s\n\nCua dong:\n\n", GetPlayerNameEx(target), GetPlayerNameEx(DDSaleTarget[target]), number_format(DDSalePrice[target]), CalculatePercentage(DDSalePrice[target], 10, 1000000));
	for(new i = 0; i < sizeof(DDSaleDoors[]); i ++) if(DDSaleDoors[target][i] != 0 && GetPlayerSQLId(target) == DDoorsInfo[DDSaleDoors[target][i]][ddOwner]) format(szMiscArray, sizeof(szMiscArray), "%s\n  * ID cua: %d (%s)", szMiscArray, DDSaleDoors[target][i], DDoorsInfo[DDSaleDoors[target][i]][ddDescription]);
	ShowPlayerDialogEx(playerid, DIALOG_DDSALEINFO, DIALOG_STYLE_MSGBOX, "Chi tiet ban cua dong", szMiscArray, "Dong y", "Huy");
	return 1;
}

alias:approvedoorsale("ad")
CMD:approvedoorsale(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	new target, fine, count[2], timex[3], string[128];
	if(sscanf(params, "u", target)) return SendClientMessageEx(playerid, COLOR_GREY, "[USAGE]: /approvedoorsale [Part Of Name/ ID]");
	if(!IsPlayerConnected(target)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi do khong ket noi.");
	if(gPlayerLogged{target} == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi do chua dang nhap tai khoan.");
	if(DDSalePendingAdmin[target] == false) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi do khong co yeu cau ban cua dong dang cho duyet.");
	fine = CalculatePercentage(DDSalePrice[target], 10, 1000000);
	if(GetPlayerCash(DDSaleTarget[target]) < DDSalePrice[target])
	{
		SendClientMessageEx(playerid, COLOR_YELLOW, "Ban da duyet yeu cau ban cua dong cua %s.", GetPlayerNameEx(target));
		SendClientMessageEx(playerid, COLOR_GREY, "Giao dich chua thuc hien vi %s khong du tien ($%s).", GetPlayerNameEx(DDSaleTarget[target]), number_format(DDSalePrice[target]));
		SendClientMessageEx(target, COLOR_GREEN, "%s da duyet yeu cau ban cua dong cua ban.", GetPlayerNameEx(playerid));
		SendClientMessageEx(target, COLOR_GREY, "Giao dich chua thuc hien vi %s khong du tien ($%s).", GetPlayerNameEx(DDSaleTarget[target]), number_format(DDSalePrice[target]));
		SendClientMessageEx(DDSaleTarget[target], COLOR_GREEN, "%s da duyet yeu cau ban cua dong cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(target));
		SendClientMessageEx(DDSaleTarget[target], COLOR_GREY, "Giao dich chua thuc hien vi ban khong du tien ($%s).", number_format(DDSalePrice[target]));
		ClearDoorSaleVariables(target);
		PlayerInfo[playerid][pAcceptReport] ++;
		ReportCount[playerid] ++;
		ReportHourCount[playerid] ++;
		format(string, sizeof(string), "AdmCmd: %s duyet yeu cau ban cua dong cua %s (that bai).", GetPlayerNameEx(playerid), GetPlayerNameEx(target));
		ABroadCast(COLOR_LIGHTRED, string, 4);
		format(string, sizeof(string), "AdmCmd: %s approved %s's dynamic door sale request (sale failed).", GetPlayerNameEx(playerid), GetPlayerNameEx(target));
		Log("logs/admin.log", string);
		return 1;
	}
	else if(GetPlayerCash(target) < fine)
	{
		SendClientMessageEx(playerid, COLOR_YELLOW, "Ban da duyet yeu cau ban cua dong cua %s.", GetPlayerNameEx(target));
		SendClientMessageEx(playerid, COLOR_GREY, "Giao dich chua thuc hien vi %s khong du tien tra phi ($%s).", GetPlayerNameEx(target), number_format(fine));
		SendClientMessageEx(target, COLOR_GREEN, "%s da duyet yeu cau ban cua dong cua ban.", GetPlayerNameEx(playerid));
		SendClientMessageEx(target, COLOR_GREY, "Giao dich chua thuc hien vi ban khong du tien tra phi ($%s).", number_format(fine));
		SendClientMessageEx(DDSaleTarget[target], COLOR_GREEN, "%s da duyet yeu cau ban cua dong cua %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(target));
		SendClientMessageEx(DDSaleTarget[target], COLOR_GREY, "Giao dich chua thuc hien vi %s khong du tien tra phi ($%s).", GetPlayerNameEx(target), number_format(fine));
		PlayerInfo[playerid][pAcceptReport] ++;
		ReportCount[playerid] ++;
		ReportHourCount[playerid] ++;
		format(string, sizeof(string), "AdmCmd: %s duyet yeu cau ban cua dong cua %s (that bai).", GetPlayerNameEx(playerid), GetPlayerNameEx(target));
		ABroadCast(COLOR_LIGHTRED, string, 4);
		format(string, sizeof(string), "AdmCmd: %s approved %s's dynamic door sale request (sale failed).", GetPlayerNameEx(playerid), GetPlayerNameEx(target));
		Log("logs/admin.log", string);
		ClearDoorSaleVariables(target);
		return 1;
	}
	else if(GetPlayerCash(DDSaleTarget[target]) >= DDSalePrice[target])
	{
		szMiscArray[0] = 0;
		gettime(timex[0], timex[1], timex[2]);
		SendClientMessageEx(playerid, COLOR_YELLOW, "Ban da duyet yeu cau ban cua dong cua %s.", GetPlayerNameEx(target));
		SendClientMessageEx(target, COLOR_GREEN, "%s da duyet yeu cau ban cua dong cua ban ($%s).", GetPlayerNameEx(playerid), number_format(DDSalePrice[target]));
		SendClientMessageEx(DDSaleTarget[target], COLOR_GREEN, "%s da duyet yeu cau ban cua dong cua %s ($%s).", GetPlayerNameEx(playerid), GetPlayerNameEx(target), number_format(DDSalePrice[target]));
		GivePlayerCashEx(target, TYPE_ONHAND, DDSalePrice[target]);
		GivePlayerCashEx(target, TYPE_ONHAND, -fine);
		GivePlayerCashEx(DDSaleTarget[target], TYPE_ONHAND, -DDSalePrice[target]);
		format(szMiscArray, sizeof(szMiscArray), "Thong tin giao dich:\n\n  * Nguoi ban: %s\n  * Nguoi mua: %s\n  * Gia: $%s\n  * Phi nguoi ban: $%s\n  * Ngay: %s (%02d:%02d:%02d)\n\nCua dong:\n", 
		GetPlayerNameEx(target), GetPlayerNameEx(DDSaleTarget[target]), number_format(DDSalePrice[target]), number_format(fine), date(gettime(), 4), timex[0], timex[1], timex[2]);
		for(new i = 0; i < sizeof(DDSaleDoors[]) - 2; i ++) 
		{
			if(DDSaleDoors[target][i] != 0 && GetPlayerSQLId(target) == DDoorsInfo[DDSaleDoors[target][i]][ddOwner])
			{
				format(szMiscArray, sizeof(szMiscArray), "%s\n  * ID cua: %d (%s)", szMiscArray, DDSaleDoors[target][i], DDoorsInfo[DDSaleDoors[target][i]][ddDescription]);
				strcpy(DDoorsInfo[DDSaleDoors[target][i]][ddOwnerName], GetPlayerNameEx(DDSaleTarget[target]), MAX_PLAYER_NAME);
				DDoorsInfo[DDSaleDoors[target][i]][ddOwner] = GetPlayerSQLId(DDSaleTarget[target]);
				DestroyDynamicPickup(DDoorsInfo[DDSaleDoors[target][i]][ddPickupID]);
				if(IsValidDynamic3DTextLabel(DDoorsInfo[DDSaleDoors[target][i]][ddTextID])) DestroyDynamic3DTextLabel(DDoorsInfo[DDSaleDoors[target][i]][ddTextID]);
				CreateDynamicDoor(DDSaleDoors[target][i]);
				SaveDynamicDoor(DDSaleDoors[target][i]);
				count[0] ++;
			}
		}
		if(count[0] == 0) strcat(szMiscArray, "\n  * Khong co");
		strcat(szMiscArray, "\n\nGarage:\n");
		for(new i = sizeof(DDSaleDoors[]) - 2; i < sizeof(DDSaleDoors[]); i ++)
		{
			if(DDSaleDoors[target][i] != 0 && GetPlayerSQLId(target) == GarageInfo[DDSaleDoors[target][i]][gar_Owner])
			{
				format(szMiscArray, sizeof(szMiscArray), "%s\n  * ID garage: %d", szMiscArray, DDSaleDoors[target][i]);
				strcpy(GarageInfo[DDSaleDoors[target][i]][gar_OwnerName], GetPlayerNameEx(DDSaleTarget[target]), MAX_PLAYER_NAME);
				GarageInfo[DDSaleDoors[target][i]][gar_Owner] = GetPlayerSQLId(DDSaleTarget[target]);
				CreateGarage(DDSaleDoors[target][i]);
				SaveGarage(DDSaleDoors[target][i]);
				count[1] ++;
			}
		}
		if(count[1] == 0) strcat(szMiscArray, "\n  * Khong co");
		strcat(szMiscArray, "\n\nNhan (F8) de chup bien nhan nay de doi chieu sau.");
		ShowPlayerDialogEx(target, DIALOG_DDSALERECIEPT, DIALOG_STYLE_MSGBOX, "Bien nhan ban cua dong", szMiscArray, "Dong y", "Huy");
		ShowPlayerDialogEx(DDSaleTarget[target], DIALOG_DDSALERECIEPT, DIALOG_STYLE_MSGBOX, "Bien nhan ban cua dong", szMiscArray, "Dong y", "Huy");
		PlayerInfo[playerid][pAcceptReport] ++;
		ReportCount[playerid] ++;
		ReportHourCount[playerid] ++;
		format(string, sizeof(string), "AdmCmd: DDSale: Duyet: %s (Ban:%s) (DD:%d) (Phi:$%s) (Gia:$%s) (Den: (%s)).", GetPlayerNameEx(playerid), GetPlayerNameEx(target), DDSaleTracking[target], number_format(fine), number_format(DDSalePrice[target]), GetPlayerNameEx(DDSaleTarget[target]));
		ABroadCast(COLOR_LIGHTRED, string, 4);
		format(string, sizeof(string), "AdmCmd: DDSale: Auth: %s DD sale (Seller:%s) (DD:%d) (F:$%s) (P:$%s) (TO: (%s)).", GetPlayerNameEx(playerid), GetPlayerNameEx(target), DDSaleTracking[target], number_format(fine), number_format(DDSalePrice[target]), GetPlayerNameEx(DDSaleTarget[target]));
		Log("logs/admin.log", string);
		ClearDoorSaleVariables(target);
		return 1;
	}
	return 1;
}

alias:denydoorsale("ds")
CMD:denydoorsale(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4 && PlayerInfo[playerid][pASM] < 1) return SendClientMessageEx(playerid, COLOR_GREY, "Ban khong co quyen dung lenh nay.");
	new target, reason[64], string[128];
	if(sscanf(params, "us[64]", target, reason)) return SendClientMessageEx(playerid, COLOR_GREY, "[USAGE]: /denydoorsale [Part Of Name/ ID] [Reason]");
	if(!IsPlayerConnected(target)) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi do khong ket noi.");
	if(gPlayerLogged{target} == 0) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi do chua dang nhap tai khoan.");
	if(DDSalePendingAdmin[target] == false) return SendClientMessageEx(playerid, COLOR_GREY, "Nguoi choi do khong co yeu cau ban cua dong dang cho duyet.");
	if(strlen(reason) < 3 || strlen(reason) > 60) return SendClientMessageEx(playerid, COLOR_GREY, "Ly do khong duoc duoi 3 ky tu hoac qua 60 ky tu.");
	ClearDoorSaleVariables(target);
	SendClientMessageEx(playerid, COLOR_YELLOW, "Ban da tu choi yeu cau ban cua dong cua %s, ly do: %s.", GetPlayerNameEx(target), reason);
	SendClientMessageEx(target, COLOR_LIGHTRED, "%s da tu choi yeu cau ban cua dong cua ban, ly do: %s.", GetPlayerNameEx(playerid), reason);
	PlayerInfo[playerid][pTrashReport] ++;
	format(string, sizeof(string), "AdmCmd: %s tu choi yeu cau ban cua dong cua %s, ly do: %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(target), reason);
	ABroadCast(COLOR_LIGHTRED, string, 4);
	format(string, sizeof(string), "AdmCmd: %s denied %s's dynamic door sale request, reason: %s.", GetPlayerNameEx(playerid), GetPlayerNameEx(target), reason);
	Log("logs/admin.log", string);
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {

	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	switch(dialogid)
	{
		case DIALOG_DDSALEMAIN:
		{
			switch(response)
			{
				case false: return ClearDoorSaleVariables(playerid);
				case true:
				{
					if(!IsPlayerConnected(DDSaleTarget[playerid]) || DDSaleTarget[playerid] == INVALID_PLAYER_ID)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Nguoi mua da thoat.");
						ClearDoorSaleVariables(playerid);
						return 1;
					}
					if(DDSalePendingPlayer[playerid] == true) return SendClientMessageEx(playerid, COLOR_GREY, "Giao dich cua dong dang cho nguoi mua chap nhan.");
					if(DDSalePendingAdmin[playerid] == true) return SendClientMessageEx(playerid, COLOR_GREY, "Giao dich cua dong dang cho Admin duyet.");
					switch(listitem)
					{
						case 0:
						{
							ShowDynamicDoorDialog(playerid);
							SendClientMessageEx(playerid, COLOR_GREY, "De doi nguoi mua cua dong, thoat hop thoai va dung lai lenh.");
							return 1;
						}
						case 1: return ShowPlayerDialogEx(playerid, DIALOG_DDSALEPRICE, DIALOG_STYLE_INPUT, "Ban cua dong", "Nhap tong gia tri giao dich ben duoi.", "Dong y", "Huy");
						case 2: 
						{
							SendClientMessageEx(playerid, COLOR_GREY, "Phi nguoi ban tu tinh theo tong gia ban, khong the thay doi.");
							ShowDynamicDoorDialog(playerid);
							return 1;
						}
						case 3..7:
						{
							DDSaleTracking[playerid] = (listitem - 3);
							ShowPlayerDialogEx(playerid, DIALOG_DDSALELINK, DIALOG_STYLE_INPUT, "Ban cua dong", "Nhap ID cua dong can lien ket voi giao dich. Nhap \"0\" de go cua dong.", "Dong y", "Huy");
							return 1;
						}
						case 8, 9:
						{
							DDSaleTracking[playerid] = (listitem - 8);
							ShowPlayerDialogEx(playerid, DIALOG_GARAGESALELINK, DIALOG_STYLE_INPUT, "Ban cua dong", "Nhap ID garage can lien ket voi giao dich. Nhap \"0\" de go garage.", "Dong y", "Huy");
							return 1;
						}
						case 10:
						{
							if(DDSalePrice[playerid] < 1 || DDSalePrice[playerid] > 1000000000)
							{
								SendClientMessageEx(playerid, COLOR_GREY, "Gia phai tu $1 den $1,000,000,000.");
								ShowDynamicDoorDialog(playerid);
								return 1;
							}
							new fine, bool:linked;
							for(new i = 0; i < sizeof(DDSaleDoors[]); i ++)
							{
								if(DDSaleDoors[playerid][i] != 0)
								{
									if(GetPlayerSQLId(playerid) == DDoorsInfo[DDSaleDoors[playerid][i]][ddOwner] && linked == false) linked = true;
									else if(GetPlayerSQLId(playerid) != DDoorsInfo[DDSaleDoors[playerid][i]][ddOwner]) DDSaleDoors[playerid][i] = 0;
								}
							}
							if(linked == false)
							{
								SendClientMessageEx(playerid, COLOR_GREY, "Ban phai lien ket it nhat mot cua dong voi giao dich.");
								ShowDynamicDoorDialog(playerid);
								return 1;
							}
							fine = CalculatePercentage(DDSalePrice[playerid], 10, 1000000);
							if(GetPlayerCash(playerid) < fine)
							{
								SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien tra phi chuyen nhuong ($%s).", number_format(fine));
								return 1;
							}
							SendClientMessageEx(playerid, COLOR_CYAN, "Ban da gui de nghi ban cua dong cho %s voi gia $%s.", GetPlayerNameEx(DDSaleTarget[playerid]), number_format(DDSalePrice[playerid]));
							SendClientMessageEx(playerid, COLOR_GREY, "Dung (/cancel door) de huy de nghi ban cua dong.");
							SendClientMessageEx(DDSaleTarget[playerid], COLOR_CYAN, "** DE NGHI BAN CUA DONG MOI TU %s: **", GetPlayerNameEx(playerid));
							SendClientMessageEx(DDSaleTarget[playerid], COLOR_WHITE, "* (Gia): $%s", number_format(DDSalePrice[playerid]));
							for(new i = 0; i < sizeof(DDSaleDoors[]); i ++)
							{
								if(DDSaleDoors[playerid][i] != 0 && GetPlayerSQLId(playerid) == DDoorsInfo[DDSaleDoors[playerid][i]][ddOwner])
								{
									SendClientMessageEx(DDSaleTarget[playerid], COLOR_WHITE, "* (ID cua %d): %s", DDSaleDoors[playerid][i], DDoorsInfo[DDSaleDoors[playerid][i]][ddDescription]);
								}
							}
							SendClientMessageEx(DDSaleTarget[playerid], COLOR_CYAN, "Dung (/accept door) de chap nhan de nghi ban cua dong.");
							DDSalePendingPlayer[playerid] = true;
							DDSaleTimer[playerid] = defer DDSaleTimerEx(playerid);
							return 1;
						}
					}
					return 1;
				}
			}
			return 1;
		}
		case DIALOG_DDSALEPRICE:
		{
			switch(response)
			{
				case false: return ShowDynamicDoorDialog(playerid);
				case true:
				{
					if(!IsPlayerConnected(DDSaleTarget[playerid]) || DDSaleTarget[playerid] == INVALID_PLAYER_ID)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Nguoi mua da thoat.");
						ClearDoorSaleVariables(playerid);
						return 1;
					}
					if(DDSalePendingPlayer[playerid] == true) return SendClientMessageEx(playerid, COLOR_GREY, "Giao dich cua dong dang cho nguoi mua chap nhan.");
					if(DDSalePendingAdmin[playerid] == true) return SendClientMessageEx(playerid, COLOR_GREY, "Giao dich cua dong dang cho Admin duyet.");
					new price, fine;
					if(sscanf(inputtext, "d", price))
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Gia ban cua dong phai la so.");
						ShowPlayerDialogEx(playerid, DIALOG_DDSALEPRICE, DIALOG_STYLE_INPUT, "Ban cua dong", "Nhap tong gia tri giao dich ben duoi.", "Dong y", "Huy");
						return 1;
					}
					if(price < 1 || price > 1000000000)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Gia ban cua dong khong duoc duoi $1 hoac tren $1,000,000,000.");
						ShowPlayerDialogEx(playerid, DIALOG_DDSALEPRICE, DIALOG_STYLE_INPUT, "Ban cua dong", "Nhap tong gia tri giao dich ben duoi.", "Dong y", "Huy");
						return 1;
					}
					if(GetPlayerCash(DDSaleTarget[playerid]) < price)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "%s khong du tien cho giao dich ($%s).", GetPlayerNameEx(DDSaleTarget[playerid]), number_format(price));
						ShowPlayerDialogEx(playerid, DIALOG_DDSALEPRICE, DIALOG_STYLE_INPUT, "Ban cua dong", "Nhap tong gia tri giao dich ben duoi.", "Dong y", "Huy");
						return 1;
					}
					fine = CalculatePercentage(price, 10, 1000000);
					if(GetPlayerCash(playerid) < fine)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Ban khong du tien tra phi chuyen nhuong ($%s).", number_format(fine));
						ShowPlayerDialogEx(playerid, DIALOG_DDSALEPRICE, DIALOG_STYLE_INPUT, "Ban cua dong", "Nhap tong gia tri giao dich ben duoi.", "Dong y", "Huy");
						return 1;
					}
					DDSalePrice[playerid] = price;
					SendClientMessageEx(playerid, COLOR_GREEN, "Da doi gia ban cua dong.");
					ShowDynamicDoorDialog(playerid);
					return 1;
				}
			}
			return 1;
		}
		case DIALOG_DDSALELINK:
		{
			switch(response)
			{
				case false: return ShowDynamicDoorDialog(playerid);
				case true:
				{
					if(!IsPlayerConnected(DDSaleTarget[playerid]) || DDSaleTarget[playerid] == INVALID_PLAYER_ID)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Nguoi mua da thoat.");
						ClearDoorSaleVariables(playerid);
						return 1;
					}
					if(DDSalePendingPlayer[playerid] == true) return SendClientMessageEx(playerid, COLOR_GREY, "Giao dich cua dong dang cho nguoi mua chap nhan.");
					if(DDSalePendingAdmin[playerid] == true) return SendClientMessageEx(playerid, COLOR_GREY, "Giao dich cua dong dang cho Admin duyet.");
					new doorid;
					if(sscanf(inputtext, "d", doorid))
					{
						SendClientMessageEx(playerid, COLOR_GREY, "ID cua phai la so.");
						ShowPlayerDialogEx(playerid, DIALOG_DDSALELINK, DIALOG_STYLE_INPUT, "Ban cua dong", "Nhap ID cua dong can lien ket voi giao dich. Nhap \"0\" de go cua dong.", "Dong y", "Huy");
						return 1;
					}
					if(doorid < 0 || doorid >= MAX_DDOORS)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "ID cua khong hop le.");
						ShowPlayerDialogEx(playerid, DIALOG_DDSALELINK, DIALOG_STYLE_INPUT, "Ban cua dong", "Nhap ID cua dong can lien ket voi giao dich. Nhap \"0\" de go cua dong.", "Dong y", "Huy");
						return 1;
					}
					for(new i = 0; i < sizeof(DDSaleDoors[]); i ++)
					{
						if(DDSaleDoors[playerid][i] == doorid && doorid != 0)
						{
							SendClientMessageEx(playerid, COLOR_GREY, "Cua dong nay da lien ket voi giao dich.");
							ShowPlayerDialogEx(playerid, DIALOG_DDSALELINK, DIALOG_STYLE_INPUT, "Ban cua dong", "Nhap ID cua dong can lien ket voi giao dich. Nhap \"0\" de go cua dong.", "Dong y", "Huy");
							return 1;
						}
					}
					switch(doorid)
					{
						case 0:
						{
							if(DDSaleDoors[playerid][DDSaleTracking[playerid]] == 0)
							{
								SendClientMessageEx(playerid, COLOR_GREY, "O nay chua co cua dong lien ket.");
								ShowPlayerDialogEx(playerid, DIALOG_DDSALELINK, DIALOG_STYLE_INPUT, "Ban cua dong", "Nhap ID cua dong can lien ket voi giao dich. Nhap \"0\" de go cua dong.", "Dong y", "Huy");
								return 1;
							}
							DDSaleDoors[playerid][DDSaleTracking[playerid]] = 0;
							SendClientMessageEx(playerid, COLOR_GREEN, "Da cap nhat/go cua dong lien ket voi giao dich.");
							ShowDynamicDoorDialog(playerid);
							return 1;
						}
						default:
						{
							if(DDoorsInfo[doorid][ddOwner] != GetPlayerSQLId(playerid))
							{
								SendClientMessageEx(playerid, COLOR_GREY, "Ban khong so huu cua dong nay.");
								ShowPlayerDialogEx(playerid, DIALOG_DDSALELINK, DIALOG_STYLE_INPUT, "Ban cua dong", "Nhap ID cua dong can lien ket voi giao dich. Nhap \"0\" de go cua dong.", "Dong y", "Huy");
								return 1;
							}
							DDSaleDoors[playerid][DDSaleTracking[playerid]] = doorid;
							SendClientMessageEx(playerid, COLOR_GREEN, "Da cap nhat cua dong lien ket voi giao dich.");
							ShowDynamicDoorDialog(playerid);
							return 1;
						}
					}
					return 1;
				}
			}
			return 1;
		}
		case DIALOG_GARAGESALELINK:
		{
			switch(response)
			{
				case false: return ShowDynamicDoorDialog(playerid);
				case true:
				{
					if(!IsPlayerConnected(DDSaleTarget[playerid]) || DDSaleTarget[playerid] == INVALID_PLAYER_ID)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "Nguoi mua da thoat.");
						ClearDoorSaleVariables(playerid);
						return 1;
					}
					if(DDSalePendingPlayer[playerid] == true) return SendClientMessageEx(playerid, COLOR_GREY, "Giao dich cua dong dang cho nguoi mua chap nhan.");
					if(DDSalePendingAdmin[playerid] == true) return SendClientMessageEx(playerid, COLOR_GREY, "Giao dich cua dong dang cho Admin duyet.");
					new garageid;
					if(sscanf(inputtext, "d", garageid))
					{
						SendClientMessageEx(playerid, COLOR_GREY, "ID garage phai la so.");
						ShowPlayerDialogEx(playerid, DIALOG_GARAGESALELINK, DIALOG_STYLE_INPUT, "Ban cua dong", "Nhap ID garage can lien ket voi giao dich. Nhap \"0\" de go garage.", "Dong y", "Huy");
						return 1;
					}
					if(garageid < 0 || garageid >= MAX_GARAGES)
					{
						SendClientMessageEx(playerid, COLOR_GREY, "ID garage khong hop le.");
						ShowPlayerDialogEx(playerid, DIALOG_GARAGESALELINK, DIALOG_STYLE_INPUT, "Ban cua dong", "Nhap ID garage can lien ket voi giao dich. Nhap \"0\" de go garage.", "Dong y", "Huy");
						return 1;
					}
					if(garageid == 0)
					{
						DDSaleDoors[playerid][DDSaleTracking[playerid]] = 0;
						ShowDynamicDoorDialog(playerid);
						return 1;
					}
					for(new i = 0; i < sizeof(DDSaleDoors[]); i ++)
					{
						if(DDSaleDoors[playerid][i] == garageid && garageid != 0)
						{
							SendClientMessageEx(playerid, COLOR_GREY, "Garage nay da lien ket voi giao dich.");
							ShowPlayerDialogEx(playerid, DIALOG_GARAGESALELINK, DIALOG_STYLE_INPUT, "Ban cua dong", "Nhap ID garage can lien ket voi giao dich. Nhap \"0\" de go garage.", "Dong y", "Huy");
							return 1;
						}
					}
					switch(garageid)
					{
						case 0:
						{
							if(DDSaleDoors[playerid][DDSaleTracking[playerid]] == 0)
							{
								SendClientMessageEx(playerid, COLOR_GREY, "O nay chua co garage lien ket.");
								ShowPlayerDialogEx(playerid, DIALOG_GARAGESALELINK, DIALOG_STYLE_INPUT, "Ban cua dong", "Nhap ID garage can lien ket voi giao dich. Nhap \"0\" de go garage.", "Dong y", "Huy");
								return 1;
							}
							DDSaleDoors[playerid][DDSaleTracking[playerid]] = 0;
							SendClientMessageEx(playerid, COLOR_GREEN, "Da cap nhat/go garage lien ket voi giao dich.");
							ShowDynamicDoorDialog(playerid);
							return 1;
						}
						default:
						{
							if(GarageInfo[garageid][gar_Owner] != GetPlayerSQLId(playerid))
							{
								SendClientMessageEx(playerid, COLOR_GREY, "Ban khong so huu garage nay.");
								ShowPlayerDialogEx(playerid, DIALOG_GARAGESALELINK, DIALOG_STYLE_INPUT, "Ban cua dong", "Nhap ID garage can lien ket voi giao dich. Nhap \"0\" de go garage.", "Dong y", "Huy");
								return 1;
							}
							DDSaleDoors[playerid][DDSaleTracking[playerid]] = garageid;
							SendClientMessageEx(playerid, COLOR_GREEN, "Da cap nhat garage lien ket voi giao dich.");
							ShowDynamicDoorDialog(playerid);
							return 1;
						}
					}
					return 1;
				}
			}
			return 1;
		}
	}
	return 0;
}