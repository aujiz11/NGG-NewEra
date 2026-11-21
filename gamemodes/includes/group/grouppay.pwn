#include <YSI_Coding\y_hooks>

GovEditGroupBudget(playerid)
{
	if(!gPlayerLogged{playerid} || !IsGroupLeader(playerid) || !IsAGovernment(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban phai lanh dao chinh phu de dung lenh nay.");
	
	new group = PlayerInfo[playerid][pLeader], szTitle[GROUP_MAX_NAME_LEN + 40];
	SetPVarInt(playerid, "GovPay_Source", group);
	DeletePVar(playerid, "GovPay_Target");
	szMiscArray[0] = 0;
	for(new i; i < MAX_GROUPS; ++i) {
		if(arrGroupData[group][g_iAllegiance] != arrGroupData[i][g_iAllegiance]) {
			format(szMiscArray, sizeof szMiscArray, "%s----\t{FFFFFF}----\n", szMiscArray);
		}
		else format(szMiscArray, sizeof szMiscArray, "%s{%s}%s\t{FFFFFF}$%s\n", szMiscArray, Group_NumToDialogHex(arrGroupData[i][g_hDutyColour]), arrGroupData[i][g_szGroupName], number_format(arrGroupData[i][g_iBudgetPayment]));
	}
	format(szTitle, sizeof szTitle, "{%s}%s {FFFFFF}| Tong quan ngan sach", Group_NumToDialogHex(arrGroupData[group][g_hDutyColour]), arrGroupData[group][g_szGroupName]);
	return ShowPlayerDialogEx(playerid, DIALOG_GROUP_GOVLISTPAY, DIALOG_STYLE_TABLIST, szTitle, szMiscArray, "Sua", "Huy");
}

PlayerEditGroupPay(playerid)
{
	if(!gPlayerLogged{playerid} || !IsGroupLeader(playerid)) 
		return SendClientMessageEx(playerid, COLOR_GRAD2, "Ban phai la lanh dao to chuc de dung lenh nay.");
	
	new iGroupID = PlayerInfo[playerid][pLeader], szTitle[32 + GROUP_MAX_NAME_LEN];
	SetPVarInt(playerid, "GroupPay_Group", iGroupID);
	DeletePVar(playerid, "GroupPay_Rank");
	szMiscArray[0] = 0;
	for(new i; i < MAX_GROUP_RANKS; ++i) {
		format(szMiscArray, sizeof szMiscArray, "%s(%i) %s\t$%s\n", szMiscArray, i, arrGroupRanks[iGroupID][i], number_format(arrGroupData[iGroupID][g_iPaycheck][i]));
	}
	format(szTitle, sizeof szTitle, "{%s}(%s) {FFFFFF}| Sua luong", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
	return ShowPlayerDialogEx(playerid, DIALOG_GROUP_PLISTPAY, DIALOG_STYLE_TABLIST, szTitle, szMiscArray, "Sua", "Huy");
}

PayGroupMember(i)
{
	if(!(0 <= i < MAX_PLAYERS) || !IsPlayerConnected(i) || !gPlayerLogged{i} || GetPVarInt(i, "FurniturePurchaseUncertain")) 
		return 0;
	
	new iGroupID = PlayerInfo[i][pMember], iRank = PlayerInfo[i][pRank];
	if(!ValidGroup(iGroupID) || !(0 <= iRank < MAX_GROUP_RANKS)) return 0;
	new amount = arrGroupData[iGroupID][g_iPaycheck][iRank];
	if(amount <= 0) return 0;
	if(arrGroupData[iGroupID][g_iBudget] < amount) return SendClientMessageEx(i, COLOR_RED, "To chuc khong du tien tra luong cho ban.");
	if(PlayerInfo[i][pAccount] > cellmax - amount) return SendClientMessageEx(i, COLOR_RED, "So du ngan hang khong the nhan luong nay.");
	if(GetPlayerSQLId(i) <= 0) return 0;

	new 
		budget = arrGroupData[iGroupID][g_iBudget] - amount, 
		bank = PlayerInfo[i][pAccount] + amount, 
		query[256];

	mysql_format(MainPipeline, query, sizeof query, "UPDATE `groups` g JOIN `accounts` a ON a.`id`=%d SET g.`Budget`=%d,a.`Bank`=%d WHERE g.`id`=%d", GetPlayerSQLId(i), budget, bank, iGroupID + 1);
	if(!mysql_tquery(MainPipeline, query, "OnQueryFinish", "i", SENDDATA_THREAD)) return SendClientMessageEx(i, COLOR_RED, "Khong the gui lenh tra luong to chuc. Chua chuyen tien.");
	arrGroupData[iGroupID][g_iBudget] = budget;
	PlayerInfo[i][pAccount] = bank;
	SendClientMessageEx(i, COLOR_GRAD2, " {%s}%s {FFFFFF}luong: $%s", Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName], number_format(amount));
	new message[160];
	format(message, sizeof message, "%s has been paid $%s from %s's budget.", GetPlayerNameEx(i), number_format(amount), arrGroupData[iGroupID][g_szGroupName]);
	GroupPayLog(iGroupID, message);
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	switch(dialogid) {
		case DIALOG_GROUP_PLISTPAY, DIALOG_GROUP_PEDITPAY: {
			new iGroupID = PlayerInfo[playerid][pLeader];
			if(!gPlayerLogged{playerid} || !IsGroupLeader(playerid) || !GetPVarType(playerid, "GroupPay_Group") || iGroupID != GetPVarInt(playerid, "GroupPay_Group")) {
				DeletePVar(playerid, "GroupPay_Group");
				DeletePVar(playerid, "GroupPay_Rank");
				return SendClientMessageEx(playerid, COLOR_GRAD2, "Quyen lanh dao to chuc da doi. Hay mo lai menu luong.");
			}
			if(dialogid == DIALOG_GROUP_PLISTPAY) {
				if(!response) {
					DeletePVar(playerid, "GroupPay_Group");
					DeletePVar(playerid, "GroupPay_Rank");
					return 1;
				}
				if(!(0 <= listitem < MAX_GROUP_RANKS)) return 1;
				new szTitle[40 + GROUP_MAX_NAME_LEN];
				SetPVarInt(playerid, "GroupPay_Rank", listitem);
				format(szTitle, sizeof szTitle, "Sua luong Rank (%i) {%s}(%s)", listitem, Group_NumToDialogHex(arrGroupData[iGroupID][g_hDutyColour]), arrGroupData[iGroupID][g_szGroupName]);
				return ShowPlayerDialogEx(playerid, DIALOG_GROUP_PEDITPAY, DIALOG_STYLE_INPUT, szTitle, "Nhap muc luong cho rank nay.", "Dat", "Huy");
			}
			new iRankID = GetPVarInt(playerid, "GroupPay_Rank");
			if(!GetPVarType(playerid, "GroupPay_Rank") || !(0 <= iRankID < MAX_GROUP_RANKS)) return 1;
			if(!response) return PlayerEditGroupPay(playerid);
			if(isnull(inputtext) || !IsNumericString(inputtext) || strlen(inputtext) > 10 || (strlen(inputtext) == 10 && strcmp(inputtext, "2147483647") > 0)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nhap so nguyen tu $0 den $2,147,483,647.");
			new amount = strval(inputtext), message[256];
			DeletePVar(playerid, "GroupPay_Rank");
			arrGroupData[iGroupID][g_iPaycheck][iRankID] = amount;
			format(message, sizeof message, "%s has changed the paycheck for rank %d (%s) to $%d in %s (%d)", GetPlayerNameEx(playerid), iRankID, arrGroupRanks[iGroupID][iRankID], amount, arrGroupData[iGroupID][g_szGroupName], iGroupID + 1);
			Log("logs/group.log", message);
			Log("logs/editgroup.log", message);
			SaveGroup(iGroupID);
			return PlayerEditGroupPay(playerid);
		}
		case DIALOG_GROUP_GOVLISTPAY, DIALOG_GROUP_GOVEDITPAY: {
			new source = PlayerInfo[playerid][pLeader];
			if(!gPlayerLogged{playerid} || !IsGroupLeader(playerid) || !IsAGovernment(playerid) || !GetPVarType(playerid, "GovPay_Source") || source != GetPVarInt(playerid, "GovPay_Source")) {
				DeletePVar(playerid, "GovPay_Source");
				DeletePVar(playerid, "GovPay_Target");
				return SendClientMessageEx(playerid, COLOR_GRAD2, "Quyen lanh dao chinh phu da doi. Hay mo lai menu ngan sach.");
			}
			if(dialogid == DIALOG_GROUP_GOVLISTPAY) {
				if(!response) {
					DeletePVar(playerid, "GovPay_Source");
					DeletePVar(playerid, "GovPay_Target");
					return 1;
				}
				if(!ValidGroup(listitem)) return 1;
				if(arrGroupData[source][g_iAllegiance] != arrGroupData[listitem][g_iAllegiance]) return SendClientMessageEx(playerid, COLOR_GRAD1, "To chuc nay khong thuoc quoc gia cua ban.");
				SetPVarInt(playerid, "GovPay_Target", listitem);
				format(szMiscArray, sizeof szMiscArray, "Sua ngan sach | {%s}%s {FFFFFF}(ID: %i)", Group_NumToDialogHex(arrGroupData[listitem][g_hDutyColour]), arrGroupData[listitem][g_szGroupName], listitem);
				return ShowPlayerDialogEx(playerid, DIALOG_GROUP_GOVEDITPAY, DIALOG_STYLE_INPUT, szMiscArray, "Nhap khoan ngan sach moi gio cho to chuc nay.", "Dat", "Huy");
			}
			new iGroupID = GetPVarInt(playerid, "GovPay_Target");
			if(!GetPVarType(playerid, "GovPay_Target") || !ValidGroup(iGroupID)) return 1;
			if(!response) return GovEditGroupBudget(playerid);
			if(arrGroupData[source][g_iAllegiance] != arrGroupData[iGroupID][g_iAllegiance]) {
				DeletePVar(playerid, "GovPay_Target");
				return SendClientMessageEx(playerid, COLOR_GRAD1, "To chuc nay khong con thuoc quoc gia cua ban.");
			}
			if(isnull(inputtext) || !IsNumericString(inputtext) || strlen(inputtext) > 10 || (strlen(inputtext) == 10 && strcmp(inputtext, "2147483647") > 0)) return SendClientMessageEx(playerid, COLOR_GRAD1, "Nhap so nguyen tu $0 den $2,147,483,647.");
			new amount = strval(inputtext), message[160];
			DeletePVar(playerid, "GovPay_Target");
			arrGroupData[iGroupID][g_iBudgetPayment] = amount;
			format(message, sizeof message, "%s has changed the budget payment for %s to $%s", GetPlayerNameEx(playerid), arrGroupData[iGroupID][g_szGroupName], number_format(amount));
			Log("logs/group.log", message);
			Log("logs/editgroup.log", message);
			SaveGroup(iGroupID);
			return GovEditGroupBudget(playerid);
		}
	}
	return 0;
}

CMD:editbudgets(playerid, params[])
{
	return GovEditGroupBudget(playerid);
}

CMD:editpaychecks(playerid, params[])
{
	return PlayerEditGroupPay(playerid);
}
