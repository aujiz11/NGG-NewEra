/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

					Staff Ban System
					   Winterfield,
					   Westen

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

#define STAFFBAN_INDEFINITE (2147483640)

stock IsStaffBanned(playerid)
{
	if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || !gPlayerLogged{playerid}) return 1;
	if(!PlayerInfo[playerid][pStaffBanned]) return 0;
	if(!gAccountsInnoDB || !gStaffBansInnoDB || restarting || mysql_unprocessed_queries(MainPipeline)) return 1;

	new query[384];
	mysql_format(MainPipeline, query, sizeof(query), "UPDATE `accounts` a JOIN `staffbans` b ON b.`playerid`=a.`id` SET a.`StaffBanned`=0,b.`status`=3 WHERE a.`id`=%d AND b.`status`=1 AND b.`expiredate`<=%d AND b.`expiredate`<>%d", GetPlayerSQLId(playerid), gettime(), STAFFBAN_INDEFINITE);
	new Cache:result = mysql_query(MainPipeline, query);
	if(!cache_is_valid(result)) return 1;
	new affected = cache_affected_rows();
	cache_delete(result);
	if(affected > 0) {
		PlayerInfo[playerid][pStaffBanned] = 0;
		SendClientMessage(playerid, COLOR_GRAD1, "Your staff ban has expired. Previous staff ranks have not been restored.");
	}
	return PlayerInfo[playerid][pStaffBanned];
}

ptask StaffBanExpiry[60000](playerid)
{
	if(gPlayerLogged{playerid} && PlayerInfo[playerid][pStaffBanned]) IsStaffBanned(playerid);
}

StaffBan_ParseReason(const text[], reason[], &days)
{
	new end = strlen(text), reasonEnd;
	while(end > 0 && text[end - 1] <= ' ') --end;
	reasonEnd = end;
	while(reasonEnd > 0 && text[reasonEnd - 1] > ' ') --reasonEnd;
	if(reasonEnd == 0 || end - reasonEnd > 5) return 0;
	days = 0;
	for(new i = reasonEnd; i < end; ++i) {
		if(text[i] < '0' || text[i] > '9') return 0;
		days = days * 10 + text[i] - '0';
	}
	while(reasonEnd > 0 && text[reasonEnd - 1] <= ' ') --reasonEnd;
	if(reasonEnd == 0 || reasonEnd >= 128) return 0;
	strmid(reason, text, 0, reasonEnd, 128);
	return 1;
}

StaffBan_Change(playerid, targetid, const accountName[], const reason[], days, bool:ban)
{
	if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || !gPlayerLogged{playerid} || GetPlayerSQLId(playerid) <= 0
		|| (PlayerInfo[playerid][pAdmin] < 1337 && PlayerInfo[playerid][pHR] <= 0))
		return SendClientMessage(playerid, COLOR_GRAD2, "You're not authorised to use this command.");
	if(!gAccountsInnoDB || !gStaffBansInnoDB || restarting || mysql_unprocessed_queries(MainPipeline))
		return SendClientMessage(playerid, COLOR_GRAD2, "Staff-ban storage is unavailable or busy. Please try again.");
	if((targetid == INVALID_PLAYER_ID && !accountName[0])
		|| (targetid != INVALID_PLAYER_ID && (targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !gPlayerLogged{targetid})))
		return SendClientMessage(playerid, COLOR_GRAD2, "That player is not logged in.");

	new created = gettime(), expires = STAFFBAN_INDEFINITE;
	if(created < 0) return SendClientMessage(playerid, COLOR_GRAD2, "The server time is outside the supported staff-ban range.");
	new maxDays = (cellmax - created) / 86400;
	if(days < 0 || days > maxDays) return SendClientMessageEx(playerid, COLOR_GRAD2, "Days must be between 0 and %d.", maxDays);
	if(days > 0) expires = created + days * 86400;

	new query[1024], sqlid, admin, banned, previousExpiry, name[MAX_PLAYER_NAME + 1];
	mysql_query(MainPipeline, "START TRANSACTION", false);
	if(mysql_errno(MainPipeline)) return SendClientMessage(playerid, COLOR_GRAD2, "The staff-ban change was not confirmed.");
	if(targetid == INVALID_PLAYER_ID)
		mysql_format(MainPipeline, query, sizeof(query), "SELECT a.`id`,a.`Username`,a.`AdminLevel`,a.`StaffBanned`,b.`expiredate` FROM `accounts` a LEFT JOIN `staffbans` b ON b.`playerid`=a.`id` AND b.`status`=1 WHERE a.`Username`='%e' FOR UPDATE", accountName);
	else
		mysql_format(MainPipeline, query, sizeof(query), "SELECT a.`id`,a.`Username`,a.`AdminLevel`,a.`StaffBanned`,b.`expiredate` FROM `accounts` a LEFT JOIN `staffbans` b ON b.`playerid`=a.`id` AND b.`status`=1 WHERE a.`id`=%d FOR UPDATE", GetPlayerSQLId(targetid));
	new Cache:result = mysql_query(MainPipeline, query);
	new rows;
	if(cache_is_valid(result)) {
		cache_get_row_count(rows);
		if(rows == 1) {
			cache_get_value_name_int(0, "id", sqlid);
			cache_get_value_name(0, "Username", name, sizeof(name));
			cache_get_value_name_int(0, "AdminLevel", admin);
			cache_get_value_name_int(0, "StaffBanned", banned);
			new bool:missingExpiry;
			cache_is_value_name_null(0, "expiredate", missingExpiry);
			if(!missingExpiry) cache_get_value_name_int(0, "expiredate", previousExpiry);
		}
		cache_delete(result);
	}
	new error[128];
	if(rows != 1 || sqlid <= 0) format(error, sizeof(error), "Account not found, or staff-ban storage could not be read consistently.");
	else if(targetid == INVALID_PLAYER_ID) {
		foreach(new i : Player) {
			new connectedName[MAX_PLAYER_NAME + 1];
			GetPlayerName(i, connectedName, sizeof(connectedName));
			if((gPlayerLogged{i} && GetPlayerSQLId(i) == sqlid) || !strcmp(connectedName, name, true)) {
				format(error, sizeof(error), "That player is connected. Use the online staff-ban command.");
				break;
			}
		}
	}
	if(!error[0] && ban) {
		if(PlayerInfo[playerid][pAdmin] != 99999 && ((admin > 0 && admin >= PlayerInfo[playerid][pAdmin])
			|| (targetid != INVALID_PLAYER_ID && PlayerInfo[targetid][pAdmin] > 0 && PlayerInfo[targetid][pAdmin] >= PlayerInfo[playerid][pAdmin])))
			format(error, sizeof(error), "You cannot perform this action on an equal or higher level administrator.");
		else if(banned && !(previousExpiry > 0 && previousExpiry <= created && previousExpiry != STAFFBAN_INDEFINITE))
			format(error, sizeof(error), "That account is already staff banned.");
	}
	else if(!error[0] && !banned) format(error, sizeof(error), "That account is not staff banned.");
	if(error[0]) {
		mysql_query(MainPipeline, "ROLLBACK", false);
		return SendClientMessage(playerid, COLOR_GRAD2, error);
	}

	mysql_format(MainPipeline, query, sizeof(query), "UPDATE `staffbans` SET `status`=%d WHERE `playerid`=%d AND `status`=1", ban ? 3 : 2, sqlid);
	mysql_query(MainPipeline, query, false);
	new failed = mysql_errno(MainPipeline);
	if(!failed && ban) {
		mysql_format(MainPipeline, query, sizeof(query), "INSERT INTO `staffbans` (`details`,`issuer`,`playerid`,`expiredate`,`created`) VALUES ('%e',%d,%d,%d,%d)", reason, GetPlayerSQLId(playerid), sqlid, expires, created);
		mysql_query(MainPipeline, query, false);
		failed = mysql_errno(MainPipeline);
	}
	if(!failed) {
		if(ban)
			mysql_format(MainPipeline, query, sizeof(query), "UPDATE `accounts` SET `AdminLevel`=0,`SeniorModerator`=0,`Helper`=0,`pVIPMod`=0,`Watchdog`=0,`HR`=0,`AP`=0,`Security`=0,`ShopTech`=0,`FactionModerator`=0,`GangModerator`=0,`Undercover`=0,`BanAppealer`=0,`PR`=0,`BM`=0,`ASM`=0,`SecureIP`='0.0.0.0',`StaffBanned`=1 WHERE `id`=%d", sqlid);
		else
			mysql_format(MainPipeline, query, sizeof(query), "UPDATE `accounts` SET `StaffBanned`=0 WHERE `id`=%d", sqlid);
		mysql_query(MainPipeline, query, false);
		failed = mysql_errno(MainPipeline);
	}
	if(failed) {
		mysql_query(MainPipeline, "ROLLBACK", false);
		return SendClientMessage(playerid, COLOR_GRAD2, "The staff-ban change was not confirmed. Please try again.");
	}
	mysql_query(MainPipeline, "COMMIT", false);
	if(mysql_errno(MainPipeline)) {
		mysql_query(MainPipeline, "ROLLBACK", false);
		return SendClientMessage(playerid, COLOR_GRAD2, "The staff-ban change was not confirmed. Please check its status before retrying.");
	}

	if(targetid != INVALID_PLAYER_ID) {
		if(ban) {
			new modeParams[4];
			if(HelpingNewbie[targetid] != INVALID_PLAYER_ID) pc_cmd_finishhelp(targetid, modeParams);
			if(GetPVarType(targetid, "pGodMode")) {
				SetHealth(targetid, GetPVarFloat(targetid, "pPreGodHealth"));
				SetArmour(targetid, GetPVarFloat(targetid, "pPreGodArmor"));
				DeletePVar(targetid, "pGodMode");
				DeletePVar(targetid, "pPreGodHealth");
				DeletePVar(targetid, "pPreGodArmor");
			}
			if(GetPVarInt(targetid, "StartedWatching")) pc_cmd_stopwatch(targetid, modeParams);
			if(Spectating[targetid] > 0) {
				format(modeParams, sizeof(modeParams), "off");
				pc_cmd_spec(targetid, modeParams);
			}
			DeletePVar(targetid, "BigEar");
			DeletePVar(targetid, "BigEarGroup");
			DeletePVar(targetid, "BigEarPlayer");
			DeletePVar(targetid, "BigEarOOCGroup");
			DeletePVar(targetid, "BigEarPM");
			DeletePVar(targetid, "BigEarPlayerPM");
			rBigEarT[targetid] = 0;
			if(GetPVarInt(targetid, "AdvisorDuty") == 1) {
				DeletePVar(targetid, "AdvisorDuty");
				--Advisors;
			}
			PlayerInfo[targetid][pAdmin] = 0;
			PlayerInfo[targetid][pSMod] = 0;
			PlayerInfo[targetid][pVIPMod] = 0;
			PlayerInfo[targetid][pHelper] = 0;
			PlayerInfo[targetid][pWatchdog] = 0;
			PlayerInfo[targetid][pFactionModerator] = 0;
			PlayerInfo[targetid][pGangModerator] = 0;
			PlayerInfo[targetid][pUndercover] = 0;
			PlayerInfo[targetid][pBanAppealer] = 0;
			PlayerInfo[targetid][pShopTech] = 0;
			PlayerInfo[targetid][pPR] = 0;
			PlayerInfo[targetid][pHR] = 0;
			PlayerInfo[targetid][pAP] = 0;
			PlayerInfo[targetid][pSecurity] = 0;
			PlayerInfo[targetid][pBM] = 0;
			PlayerInfo[targetid][pASM] = 0;
			format(PlayerInfo[targetid][pSecureIP], 16, "0.0.0.0");
		}
		PlayerInfo[targetid][pStaffBanned] = ban;
		SendClientMessageEx(targetid, COLOR_LIGHTRED, "Your staff ban was %s by %s. Reason: %s", ban ? ("issued") : ("removed"), GetPlayerNameEx(playerid), reason);
	}
	new expiryText[32] = "indefinite", message[512];
	if(days > 0) format(expiryText, sizeof(expiryText), "%s", date(expires, 1));
	format(message, sizeof(message), "{AA3333}AdmWarning{FFFF00}: %s's staff ban was %s by %s. Reason: %s", name, ban ? ("issued") : ("removed"), GetPlayerNameEx(playerid), reason);
	ABroadCast(COLOR_YELLOW, message, 4);
	SendClientMessageEx(playerid, COLOR_GRAD1, "Staff ban %s for %s. Reason: %s", ban ? ("issued") : ("removed"), name, reason);
	if(ban) {
		SendClientMessageEx(playerid, COLOR_GRAD1, "Staff-ban expiry: %s", expiryText);
		if(targetid != INVALID_PLAYER_ID) SendClientMessageEx(targetid, COLOR_LIGHTRED, "Staff-ban expiry: %s", expiryText);
	}
	format(message, sizeof(message), "%s (%d): staff ban %s by %s (%d), reason: %s", name, sqlid, ban ? ("issued") : ("removed"), GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), reason);
	Log("logs/staffban.log", message);
	if(ban) {
		format(message, sizeof(message), "%s (%d): duration %d days; expiry %s", name, sqlid, days, expiryText);
		Log("logs/staffban.log", message);
	}
	return 1;
}

CMD:staffban(playerid, params[])
{
	new targetid, text[160], reason[128], days;
	if(sscanf(params, "ds[160]", targetid, text) || !StaffBan_ParseReason(text, reason, days))
		return SendClientMessage(playerid, COLOR_GREY, "USAGE: /staffban [playerid] [reason] [days; 0 = indefinite]");
	return StaffBan_Change(playerid, targetid, "", reason, days, true);
}

CMD:unstaffban(playerid, params[])
{
	new targetid, reason[128];
	if(sscanf(params, "ds[128]", targetid, reason)) return SendClientMessage(playerid, COLOR_GREY, "USAGE: /unstaffban [playerid] [reason]");
	return StaffBan_Change(playerid, targetid, "", reason, 0, false);
}

CMD:ostaffban(playerid, params[])
{
	new name[MAX_PLAYER_NAME + 1], text[160], reason[128], days;
	if(sscanf(params, "s[25]s[160]", name, text) || !StaffBan_ParseReason(text, reason, days))
		return SendClientMessage(playerid, COLOR_GREY, "USAGE: /ostaffban [account name] [reason] [days; 0 = indefinite]");
	return StaffBan_Change(playerid, INVALID_PLAYER_ID, name, reason, days, true);
}

CMD:ounstaffban(playerid, params[])
{
	new name[MAX_PLAYER_NAME + 1];
	if(sscanf(params, "s[25]", name)) return SendClientMessage(playerid, COLOR_GREY, "USAGE: /ounstaffban [account name]");
	return StaffBan_Change(playerid, INVALID_PLAYER_ID, name, "Offline removal", 0, false);
}

CMD:staffbans(playerid, params[])
{
	if(!gPlayerLogged{playerid} || (PlayerInfo[playerid][pAdmin] < 1337 && PlayerInfo[playerid][pHR] <= 0))
		return SendClientMessage(playerid, COLOR_GRAD2, "You're not authorised to use this command.");
	if(!gStaffBansInnoDB) return SendClientMessage(playerid, COLOR_GRAD2, "Staff-ban storage is unavailable.");
	new query[512];
	mysql_format(MainPipeline, query, sizeof(query), "SELECT b.`playerid`,b.`issuer`,b.`details`,b.`expiredate`,i.`Username` FROM `staffbans` b JOIN `accounts` a ON a.`id`=b.`playerid` LEFT JOIN `accounts` i ON i.`id`=b.`issuer` WHERE b.`status`=1 AND a.`StaffBanned`=1 AND (b.`expiredate`>%d OR b.`expiredate`=%d) ORDER BY b.`id`", gettime(), STAFFBAN_INDEFINITE);
	new Cache:result = mysql_query(MainPipeline, query);
	if(!cache_is_valid(result)) return SendClientMessage(playerid, COLOR_GRAD2, "Staff bans could not be read.");
	new rows, displayed;
	cache_get_row_count(rows);
	SendClientMessage(playerid, COLOR_GREEN, "_______________________________________");
	SendClientMessage(playerid, COLOR_GRAD3, "List of online staff bans:");
	for(new row; row < rows; ++row) {
		new sqlid, issuer, expires, reason[128], issuerName[MAX_PLAYER_NAME + 1], expiryText[32] = "indefinite";
		cache_get_value_name_int(row, "playerid", sqlid);
		cache_get_value_name_int(row, "issuer", issuer);
		cache_get_value_name_int(row, "expiredate", expires);
		cache_get_value_name(row, "details", reason, sizeof(reason));
		new bool:missingIssuer;
		cache_is_value_name_null(row, "Username", missingIssuer);
		if(missingIssuer) format(issuerName, sizeof(issuerName), "Account #%d", issuer);
		else cache_get_value_name(row, "Username", issuerName, sizeof(issuerName));
		if(expires != STAFFBAN_INDEFINITE) format(expiryText, sizeof(expiryText), "%s", date(expires, 1));
		foreach(new i : Player) {
			if(gPlayerLogged{i} && GetPlayerSQLId(i) == sqlid) {
				SendClientMessageEx(playerid, COLOR_GRAD1, "%s (ID: %d) - issuer: %s - expires: %s", GetPlayerNameEx(i), i, issuerName, expiryText);
				SendClientMessageEx(playerid, COLOR_GRAD1, "Reason: %s", reason);
				++displayed;
				break;
			}
		}
	}
	cache_delete(result);
	if(!displayed) SendClientMessage(playerid, COLOR_GRAD1, "No active online staff bans were found.");
	SendClientMessage(playerid, COLOR_GREEN, "_______________________________________");
	return 1;
}
