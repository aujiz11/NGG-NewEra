#include <YSI_Coding\y_hooks>

#define GUN_LICENSE_PRICE (100000)
#define GUN_LICENSE_DURATION (86400 * 30)

stock GunLicense_CanApply(playerid) {
	if(!(0 <= playerid < MAX_PLAYERS) || !IsPlayerConnected(playerid) || !gPlayerLogged{playerid}) return 0;
	if(PlayerBusy(playerid) || PlayerTied[playerid] || PlayerInfo[playerid][pJailTime]) {
		SendClientMessageEx(playerid, COLOR_GRAD2, "You cannot apply for a gun license right now.");
		return 0;
	}
	if(GetPlayerVirtualWorld(playerid) != 0 || GetPlayerInterior(playerid) != 0
		|| !IsPlayerInRangeOfPoint(playerid, 5.0, 1464.3099, -1747.5853, 15.6267)) {
		SendClientMessageEx(playerid, COLOR_GRAD1, "You aren't at the government arms point at City Hall in Los Santos.");
		return 0;
	}
	if(PlayerInfo[playerid][pGunLic] > gettime()) {
		SendClientMessageEx(playerid, COLOR_GRAD2, "You already have a valid gun license.");
		return 0;
	}
	if(GetPlayerCash(playerid) < GUN_LICENSE_PRICE) {
		SendClientMessageEx(playerid, COLOR_WHITE, "You do not have enough money.");
		return 0;
	}
	return 1;
}

alias:issuegunlicense("issuegl")
CMD:issuegunlicense(playerid, params[])
{
	if((0 <= PlayerInfo[playerid][pLeader] < MAX_GROUPS) && arrGroupData[PlayerInfo[playerid][pLeader]][g_iGroupType] == GROUP_TYPE_GOV)
	{
		new iTargetID;
		if(sscanf(params, "u", iTargetID)) return SendClientMessageEx(playerid, COLOR_GRAD2, "USAGE: /issuegunlicense [playerid]");
		if(!(0 <= iTargetID < MAX_PLAYERS) || !IsPlayerConnected(iTargetID) || !gPlayerLogged{iTargetID}) return SendClientMessageEx(playerid, COLOR_GRAD2, "Invalid player specified.");

		++GunLicenseRequest[iTargetID];
		PlayerInfo[iTargetID][pGunLic] = gettime() + GUN_LICENSE_DURATION;
		SendClientMessageEx(iTargetID, COLOR_WHITE, "%s has issued you a gun license valid for 30 days.", GetPlayerNameEx(playerid));

		new message[256];
		format(message, sizeof(message), "%s has renewed %s's gun license.", GetPlayerNameEx(playerid), GetPlayerNameEx(iTargetID));
		foreach(new i : Player)
			if((0 <= PlayerInfo[i][pMember] < MAX_GROUPS) && arrGroupData[PlayerInfo[i][pMember]][g_iGroupType] == GROUP_TYPE_GOV)
				SendClientMessageEx(i, COLOR_RED, message);

		format(message, sizeof(message), "%s(%d) (%s) has issued %s(%d) (%s) a gun license.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), GetPlayerIpEx(playerid), GetPlayerNameEx(iTargetID), GetPlayerSQLId(iTargetID), GetPlayerIpEx(iTargetID));
		Log("logs/licenses.log", message);
	}
	else SendClientMessageEx(playerid, COLOR_WHITE, "You are not authorized to use this command!");
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	if(dialogid == APPLY_GUN_LIC) {
		if(!response) return SendClientMessageEx(playerid, COLOR_WHITE, "You have chosen not to apply for a gun license!");
		SubmitGunLicApp(playerid);
	}
	return 0;
}

SubmitGunLicApp(iPlayerID) {
	if(!GunLicense_CanApply(iPlayerID)) return 0;
	new query[160], request = ++GunLicenseRequest[iPlayerID];
	mysql_format(MainPipeline, query, sizeof(query), "SELECT 1 FROM `mdc` WHERE `id` = %d AND `time` > DATE_SUB(NOW(), INTERVAL 21 DAY) LIMIT 1", GetPlayerSQLId(iPlayerID));
	if(!mysql_tquery(MainPipeline, query, "OnSubmitGunLicApp", "iii", iPlayerID, g_arrQueryHandle[iPlayerID], request)) {
		SendClientMessageEx(iPlayerID, COLOR_WHITE, "Unable to submit your gun license application. Please try again.");
		return 0;
	}
	return 1;
}

forward OnSubmitGunLicApp(iPlayerID, session, request);
public OnSubmitGunLicApp(iPlayerID, session, request) {
	if(!(0 <= iPlayerID < MAX_PLAYERS) || !IsPlayerConnected(iPlayerID) || g_arrQueryHandle[iPlayerID] != session || GunLicenseRequest[iPlayerID] != request) 
	{
		return 1;
	}
	++GunLicenseRequest[iPlayerID];
	if(!GunLicense_CanApply(iPlayerID)) return 1;

	new rows;
	cache_get_row_count(rows);
	if(rows > 0) {
		ShowPlayerDialogEx(iPlayerID, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, "Gun License Application - Denied",
			"Your background check found a criminal history within the past 21 days.\nPlease reapply once 21 days have passed since your last crime.", "Close", "");
		return 1;
	}
	if(Tax > cellmax - GUN_LICENSE_PRICE) return SendClientMessageEx(iPlayerID, COLOR_WHITE, "The government cannot accept your payment right now. Please try again later.");

	GivePlayerCash(iPlayerID, -GUN_LICENSE_PRICE);
	Tax += GUN_LICENSE_PRICE;
	PlayerInfo[iPlayerID][pGunLic] = gettime() + GUN_LICENSE_DURATION;
	ShowPlayerDialogEx(iPlayerID, DIALOG_NOTHING, DIALOG_STYLE_MSGBOX, "Gun License Application - Approved", "Your gun license is now valid for 30 days.\nHave a good day!", "Close", "");
	new message[128];
	format(message, sizeof(message), "%s has renewed their gun license for $100,000.", GetPlayerNameEx(iPlayerID));
	Log("logs/licenses.log", message);
	return 1;
}
