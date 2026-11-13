#include <YSI_Coding\y_hooks>

new DB:db_iHandle;
static const DBLogTables[][] = {
	"Admin", 
	"AdminIPCheck", 
	"AdminMole", 
	"IPCheck", 
	"ItemTransfer", 
	"Kick", 
	"Pay_Log", 
	"PlayerVehicle", 
	"StaffChat"
};

hook OnGameModeInit() {
	db_iHandle = db_open("logs.db");
	if(!db_iHandle) return print("[SQLite] Unable to open logs.db. SQLite logging is unavailable."), 1;

	for(new i; i < sizeof(DBLogTables); ++i) {
		new DBResult:result = DB_ExecuteQuery(db_iHandle, "CREATE TABLE IF NOT EXISTS `%s` (`Timestamp` INTEGER NOT NULL, `PlayerID` INTEGER NOT NULL, `TargetID` INTEGER NOT NULL DEFAULT 0, `LogText` TEXT NOT NULL, `PlayerIP` TEXT NOT NULL, `TargetIP` TEXT NOT NULL DEFAULT '')", DBLogTables[i]);
		if(!result) {
			printf("[SQLite] Unable to initialize logs.db table %s; SQLite logging is unavailable.", DBLogTables[i]);
			db_close(db_iHandle);
			db_iHandle = DB:0;
			return 1;
		}
		db_free_result(result);
	}

	new DBResult:result = DB_ExecuteQuery(db_iHandle, "CREATE TABLE IF NOT EXISTS `Connections` (`Timestamp` INTEGER NOT NULL, `PlayerID` INTEGER NOT NULL, `PlayerIP` TEXT NOT NULL)");
	if(!result) {
		print("[SQLite] Unable to initialize logs.db table Connections. SQLite logging is unavailable.");
		db_close(db_iHandle);
		db_iHandle = DB:0;
		return 1;
	}
	db_free_result(result);

	return 1;
}

hook OnGameModeExit() {
	if(db_iHandle) db_close(db_iHandle);
	db_iHandle = DB:0;
	return 1;
}

/*
	This can be used for:
		-Admin
		-Admin Aution
		-Admin Give
		-Admin Pay
		-Auction
		-Ban
		-Backpack
		-Business Edit
		-Business
		-CLEO
		-Contracts
		-Credits
		-Crime
		-Dynamic Door Edit
		-Dealership
		-Dynamic Map Icon Edit
		-Dynamic Vehicle
		-Dynamic Vehicle Spawn
		-Edit Group
		-Faction 
		-Flag Move
		-Flags
		-Garage Edit
		-Gate Edit
		-Gifts
		-Government
		-Group
		-Hack
		-House Edit
		-House Safe
		-Kick
		-Licenses
		-Login Credits
		-Mail
		-Micro
		-Moderator
		-Mute
		-Priority Ad
		-Password
		-Pay
		-Plant
		-Player Vehicle
		-Pay N' Spray
		-Poker
		-Rapid Fire
		-RP Special
		-Sell Credits
		-Set VIP
		-Shpo Confirmed Orders
		-Shop
		-Shop Orders
		-s0biet
		-Speedcam
		-Stats
		-Text Label Edit
		-Toys
		-Toy Edit
		-Toy Delete
		-Undercover
		-VIP Name-changes
		-VIP Remove
		-Voucher

*/		
DBLog_TableAllowed(const table[]) {
	for(new i; i < sizeof(DBLogTables); ++i) if(!strcmp(table, DBLogTables[i])) return 1;
	return 0;
}

DBLog_WriteEntry(const table[], actorid, targetid, const text[], const actorip[], const targetip[], bool:withTarget) {
	new length = strlen(text), bool:longEntry = length > 2048;
	if(!db_iHandle || length >= sizeof(szMiscArray) || !DBLog_TableAllowed(table)) return 0;
	new DBResult:result, chunk[2049];
	if(longEntry) {
		result = DB_ExecuteQuery(db_iHandle, "BEGIN IMMEDIATE");
		if(!result) return 0;
		db_free_result(result);
	}
	strmid(chunk, text, 0, 2048, sizeof(chunk));
	if(withTarget) result = DB_ExecuteQuery(db_iHandle, "INSERT INTO `%s` (`Timestamp`,`PlayerID`,`TargetID`,`LogText`,`PlayerIP`,`TargetIP`) VALUES (%d,%d,%d,'%q','%q','%q')", table, gettime(), actorid, targetid, chunk, actorip, targetip);
	else result = DB_ExecuteQuery(db_iHandle, "INSERT INTO `%s` (`Timestamp`,`PlayerID`,`LogText`,`PlayerIP`) VALUES (%d,%d,'%q','%q')", table, gettime(), actorid, chunk, actorip);
	if(result && longEntry) {
		db_free_result(result);
		strmid(chunk, text, 2048, length, sizeof(chunk));
		result = DB_ExecuteQuery(db_iHandle, "UPDATE `%s` SET `LogText`=`LogText`||'%q' WHERE rowid=last_insert_rowid()", table, chunk);
	}
	new bool:success = result != DBResult:0;
	if(result) db_free_result(result);
	if(longEntry) {
		result = DB_ExecuteQuery(db_iHandle, success ? ("COMMIT") : ("ROLLBACK"));
		if(!result) {
			result = DB_ExecuteQuery(db_iHandle, "ROLLBACK");
			success = false;
		}
		if(result) db_free_result(result);
	}
	return success;
}

DBLog(iPlayerID, iTargetID = INVALID_PLAYER_ID, const szLogTable[], const szLogText[]) {
    if(iPlayerID < 0 || iPlayerID >= MAX_PLAYERS || !IsPlayerConnected(iPlayerID)) return 0;
    if(!DBLog_TableAllowed(szLogTable) || strlen(szLogText) >= sizeof(szMiscArray)) return 0;
    new targetid, targetip[46];
    if(0 <= iTargetID < MAX_PLAYERS && IsPlayerConnected(iTargetID)) {
        targetid = PlayerInfo[iTargetID][pId];
        format(targetip, sizeof(targetip), "%s", PlayerInfo[iTargetID][pIP]);
    }
    if(!DBLog_WriteEntry(szLogTable, PlayerInfo[iPlayerID][pId], targetid, szLogText, PlayerInfo[iPlayerID][pIP], targetip, true))
        return print("[SQLite] Audit log write failed."), 0;
	return 1;
}

ChatDBLog(iPlayerID, const szLogTable[], const szLogText[]) {
    if(iPlayerID < 0 || iPlayerID >= MAX_PLAYERS || !IsPlayerConnected(iPlayerID)) return 0;
    if(!DBLog_TableAllowed(szLogTable) || strlen(szLogText) >= sizeof(szMiscArray)) return 0;
    if(!DBLog_WriteEntry(szLogTable, PlayerInfo[iPlayerID][pId], 0, szLogText, PlayerInfo[iPlayerID][pIP], "", false))
        return print("[SQLite] Chat log write failed."), 0;
	return 1;
}

CasinoDBLog(iPlayerID, const game[], amount, prize, num1, num2, num3) {

	mysql_format(MainPipeline, szMiscArray, sizeof(szMiscArray), "INSERT INTO `cp_casino_log` (`Timestamp`, `PlayerID`, `game`, `amount`,`prize`,`num1`,`num2`,`num3`,`PlayerIP`) VALUES ('%d','%d','%s','%d','%d','%d','%d','%d','%s')", gettime(), PlayerInfo[iPlayerID][pId], game, amount, prize, num1, num2, num3, PlayerInfo[iPlayerID][pIP]);
	mysql_tquery(MainPipeline, szMiscArray, "OnQueryFinish", "i", SENDDATA_THREAD);
	//db_free_result(db_query(db_iHandle, szMiscArray));
	printf("%s",szMiscArray);

	return 1;
}

/*
PropertyDBLog(iPlayerID, iTargetID = INVALID_PLAYER_ID, PropertyID, szLogTable[], szLogText[]) {

	format(szMiscArray, sizeof(szMiscArray), "INSERT INTO `%s` (`Timestamp`,`PlayerID`,`PropertyID`,`LogText`,`PlayerIP`) VALUES ('%d','%d','%d','%s','%s')", szLogTable, gettime(), PlayerInfo[iPlayerID][pId], PropertyID, szLogText, PlayerInfo[iPlayerID][pIP]);
	db_free_result(db_query(db_iHandle, szMiscArray));
	printf("%s",szMiscArray);

	return 1;
}
*/

/*
	Function: GroupDBLog
	Parameters: 
		-iPlayerID - The player who's executing the item to be logged.
		-iTargetID - The player who's affected by the item being executed.
		-iGroupID  - The GroupID that will be affected (please note this can be a group, business, etc - use table specf.)
		-szLogTable - The name of the table you wish to log to (this is case sensitive).
		-szLogText - The text you wish to log.
		
		
*/
		/*
GroupDBLog(iPlayerID, iGroupID, szLogText) {

	format(szMiscArray, sizeof(szMiscArray),  "INSERT INTO `cp_log_group` (`Timestamp`,`GroupID`,`PlayerID`,`LogText`,`PlayerIP`) VALUES ('%d','%d','%d','%s','%s')", gettime(), iGroupID, PlayerInfo[iPlayerID][pId], szLogText, PlayerInfo[iPlayerID][pIP]);
	db_free_result(db_query(db_iHandle, szMiscArray));
	printf("%s",szMiscArray);

	return 1;
}
*/

/* 
	Function: ConectionDBLog
	Parameters: 
		-iPlayerID - The player who's connection you wish to log.

*/
ConnectionDBLog(iPlayerID) {
	if(!db_iHandle || iPlayerID < 0 || iPlayerID >= MAX_PLAYERS || !IsPlayerConnected(iPlayerID)) return 0;
	new query[256];
	format(query, sizeof(query), "INSERT INTO `Connections` (`Timestamp`,`PlayerID`,`PlayerIP`) VALUES (%d,%d,'%q')", gettime(), PlayerInfo[iPlayerID][pId], PlayerInfo[iPlayerID][pIP]);
	new DBResult:result = DB_ExecuteQuery(db_iHandle, "%s", query);
	if(!result) return print("[SQLite] Connection log write failed."), 0;
	db_free_result(result);
	return 1;
}
