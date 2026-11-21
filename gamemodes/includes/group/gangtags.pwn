/* Gangtag System by Jingles */
#include <YSI_Coding\y_hooks>

#define GANGTAG_WRITE_CREATE (1)
#define GANGTAG_WRITE_TEXT (2)
#define GANGTAG_WRITE_POSITION (3)
#define GANGTAG_WRITE_DELETE (4)

hook OnPlayerConnect(playerid)
{
	++gGangTagSession[playerid];
	gGangTagListCount[playerid] = 0;
	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	GangTag_Cancel(playerid);
	++gGangTagSession[playerid];
	gGangTagListCount[playerid] = 0;
	return 1;
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	GangTag_Cancel(playerid);
	return 1;
}

GangTag_Cancel(playerid)
{
	++gGangTagAction[playerid];
	if(gGangTagTimer[playerid]) KillTimer(gGangTagTimer[playerid]);
	gGangTagTimer[playerid] = 0;
	if(GetPVarType(playerid, PVAR_GANGTAGID) && IsPlayerConnected(playerid))
	{
		ClearAnimationsEx(playerid);
		TogglePlayerControllable(playerid, true);
	}
	DeletePVar(playerid, PVAR_GANGTAGID);
	DeletePVar(playerid, PVAR_GANGTAGTEXT);
	return 1;
}

bool:GangTag_Valid(i)
{
	if(i < 0 || i >= MAX_GANGTAGS) return false;
	return Iter_Contains(GangTags, i) && IsValidDynamicObject(arrGangTags[i][gt_iObjectID]);
}

bool:GangTag_Near(playerid, i)
{
	if(!GangTag_Valid(i)) return false;
	new Float:pos[3];
	GetDynamicObjectPos(arrGangTags[i][gt_iObjectID], pos[0], pos[1], pos[2]);
	return IsPlayerInRangeOfPoint(playerid, 5.0, pos[0], pos[1], pos[2]);
}

GangTag_Clear(i)
{
	if(IsValidDynamicObject(arrGangTags[i][gt_iObjectID])) DestroyDynamicObject(arrGangTags[i][gt_iObjectID]);
	if(IsValidDynamic3DTextLabel(arrGangTags[i][gt_iTextID])) DestroyDynamic3DTextLabel(arrGangTags[i][gt_iTextID]);
	arrGangTags[i][gt_iObjectID] = INVALID_STREAMER_ID;
	arrGangTags[i][gt_iTextID] = Text3D:INVALID_STREAMER_ID;
	arrGangTags[i][gt_bStored] = false;
	Iter_Remove(GangTags, i);
	++arrGangTags[i][gt_iRevision];
}

bool:GangTag_Requester(i)
{
	new playerid = arrGangTags[i][gt_iRequester];
	return IsPlayerConnected(playerid) && gGangTagSession[playerid] == arrGangTags[i][gt_iSession]
		&& GetPlayerSQLId(playerid) == arrGangTags[i][gt_iAccount];
}

bool:GangTag_WriteMatches(i, revision)
{
	return 0 <= i < MAX_GANGTAGS && arrGangTags[i][gt_iWrite] != 0 && arrGangTags[i][gt_iRevision] == revision;
}

GangTag_BeginWrite(playerid, i, operation)
{
	if(i < 0 || i >= MAX_GANGTAGS || !IsPlayerConnected(playerid)) return 0;
	if(gGangTagsLoading || arrGangTags[i][gt_iWrite])
		return SendClientMessage(playerid, COLOR_GRAD1, "Gang Tags dang ban. Hay thu lai sau."), 0;
	arrGangTags[i][gt_iWrite] = operation;
	arrGangTags[i][gt_iRequester] = playerid;
	arrGangTags[i][gt_iSession] = gGangTagSession[playerid];
	arrGangTags[i][gt_iAccount] = GetPlayerSQLId(playerid);
	++arrGangTags[i][gt_iRevision];
	return 1;
}

GangTag_FailWrite(i, revision)
{
	if(!GangTag_WriteMatches(i, revision)) return 0;
	if(GangTag_Requester(i)) SendClientMessage(arrGangTags[i][gt_iRequester], COLOR_GRAD1, "Luu Gang Tag that bai. Nho Admin rehash truoc khi thu lai.");
	arrGangTags[i][gt_iWrite] = 0;
	printf("[Gang Tags] Write/read failed for ID %d; committed world state retained. Rehash may be required.", i);
	return 1;
}

GangTag_QueryFailed(const callback[], const query[])
{
	if(!strcmp(callback, "GangTag_OnLoad")) gGangTagsLoading = false;
	if(strfind(query, "/*gangtags ") != 0) return 0;
	new i, revision;
	if(sscanf(query[11], "ii", i, revision)) return 0;
	return GangTag_FailWrite(i, revision);
}

GangTag_Load()
{
	if(gGangTagsLoading) return 0;
	for(new i; i < MAX_GANGTAGS; ++i) if(arrGangTags[i][gt_iWrite]) return 0;
	gGangTagsLoading = true;
	if(!mysql_tquery(MainPipeline, "SELECT *, OCTET_LENGTH(`text`) AS `textbytes` FROM `gangtags` WHERE `id` BETWEEN 0 AND 99 ORDER BY `id`", "GangTag_OnLoad"))
	{
		gGangTagsLoading = false;
		return 0;
	}
	return 1;
}

forward GangTag_OnLoad();
public GangTag_OnLoad()
{
	for(new i; i < MAX_GANGTAGS; ++i) GangTag_Clear(i);
	new rows, loaded;
	cache_get_row_count(rows);
	for(new row; row < rows; ++row) loaded += GangTag_ReadRow(row);
	gGangTagsLoading = false;
	printf("[Gang Tags] Loaded %d of %d in-range rows.", loaded, rows);
	return 1;
}

GangTag_ReadRow(row)
{
	new i, fontid, color, groupid, bytes, text[MAX_GANGTAGS_LEN], Float:pos[6];
	if(!cache_get_value_name_int(row, "id", i) || i < 0 || i >= MAX_GANGTAGS) return 0;
	arrGangTags[i][gt_bStored] = true;
	if(!cache_get_value_name_int(row, "textbytes", bytes) || bytes < 1 || bytes >= MAX_GANGTAGS_LEN
		|| !cache_get_value_name_int(row, "fontid", fontid) || fontid < 0 || fontid >= sizeof(szFonts))
	{
		printf("[Gang Tags] Skipped invalid text/font at ID %d.", i);
		return 0;
	}
	if(!cache_get_value_name(row, "text", text, sizeof(text))
		|| !cache_get_value_name_int(row, "color", color)
		|| !cache_get_value_name_int(row, "gangid", groupid)
		|| !cache_get_value_name_float(row, "x", pos[0])
		|| !cache_get_value_name_float(row, "y", pos[1])
		|| !cache_get_value_name_float(row, "z", pos[2])
		|| !cache_get_value_name_float(row, "rx", pos[3])
		|| !cache_get_value_name_float(row, "ry", pos[4])
		|| !cache_get_value_name_float(row, "rz", pos[5])) return 0;
	for(new j; text[j]; ++j) if(text[j] < 32) return 0;
	if(!GangTag_AdmProcess(i, pos[0], pos[1], pos[2], pos[3], pos[4], pos[5], text, fontid, color)) return 0;
	arrGangTags[i][gt_iGroup] = groupid;
	return 1;
}

GangTag_AdmProcess(i, Float:X, Float:Y, Float:Z, Float:RX, Float:RY, Float:RZ, const text[], fontid, color)
{
	new fontName[19];
	if(i < 0 || i >= MAX_GANGTAGS || fontid < 0 || fontid >= sizeof(szFonts) || !strlen(text) || strlen(text) >= MAX_GANGTAGS_LEN) return 0;
	new objectid = CreateDynamicObject(GANGTAGS_OBJECTID, X, Y, Z, RX, RY, RZ), label[48];
	format(label, sizeof(label), "Diem Gang Tag (ID %d)", i);
	new Text3D:textid = CreateDynamic3DTextLabel(label, COLOR_YELLOW, X, Y, Z+2.75, 4.0);
	if(!IsValidDynamicObject(objectid) || !IsValidDynamic3DTextLabel(textid))
	{
		if(IsValidDynamicObject(objectid)) DestroyDynamicObject(objectid);
		if(IsValidDynamic3DTextLabel(textid)) DestroyDynamic3DTextLabel(textid);
		return 0;
	}
	if(IsValidDynamicObject(arrGangTags[i][gt_iObjectID])) DestroyDynamicObject(arrGangTags[i][gt_iObjectID]);
	if(IsValidDynamic3DTextLabel(arrGangTags[i][gt_iTextID])) DestroyDynamic3DTextLabel(arrGangTags[i][gt_iTextID]);
	arrGangTags[i][gt_iObjectID] = objectid;
	arrGangTags[i][gt_iTextID] = textid;
	strunpack(fontName, szFonts[fontid], sizeof(fontName));
	SetDynamicObjectMaterialText(arrGangTags[i][gt_iObjectID], 0, text, OBJECT_MATERIAL_SIZE_512x512, fontName, 1000 / strlen(text), 1, GangTag_IntColor(color), 0, 1);
	arrGangTags[i][gt_iFont] = fontid;
	arrGangTags[i][gt_iColor] = color;
	format(arrGangTags[i][gt_szText], MAX_GANGTAGS_LEN, "%s", text);
	Iter_Add(GangTags, i);
	return 1;
}

GangTag_Create(playerid)
{
	for(new i; i < MAX_GANGTAGS; ++i)
	{
		if(arrGangTags[i][gt_bStored] || GangTag_Valid(i) || arrGangTags[i][gt_iWrite]) continue;
		if(!GangTag_BeginWrite(playerid, i, GANGTAG_WRITE_CREATE)) return 0;
		new Float:pos[3], color = GANGTAGS_DEFAULTCOL, groupid = PlayerInfo[playerid][pMember];
		GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		if(0 <= groupid < MAX_GROUPS) color = arrGroupData[groupid][g_hDutyColour];
		new query[512];
		mysql_format(MainPipeline, query, sizeof(query), "/*gangtags %d %d */ INSERT INTO `gangtags` (`id`,`x`,`y`,`z`,`color`) VALUES (%d,%f,%f,%f,%d)",
			i, arrGangTags[i][gt_iRevision], i, pos[0], pos[1], pos[2], color);
		if(!mysql_tquery(MainPipeline, query, "GangTag_OnWrite", "ii", i, arrGangTags[i][gt_iRevision])) GangTag_FailWrite(i, arrGangTags[i][gt_iRevision]);
		return 1;
	}
	return SendClientMessage(playerid, COLOR_GRAD1, "Khong the tao them Gang Tag.");
}

GangTag_Save(playerid, i, const text[], fontid)
{
	if(!GangTag_Valid(i)) return SendClientMessage(playerid, COLOR_GRAD1, "ID Gang Tag khong hop le.");
	if(!strlen(text) || strlen(text) >= MAX_GANGTAGS_LEN || fontid < 0 || fontid >= sizeof(szFonts)) return 0;
	if(!GangTag_BeginWrite(playerid, i, GANGTAG_WRITE_TEXT)) return 0;
	new groupid = PlayerInfo[playerid][pMember], color = GANGTAGS_DEFAULTCOL, query[768];
	if(0 <= groupid < MAX_GROUPS) color = arrGroupData[groupid][g_hDutyColour];
	else groupid = -1;
	mysql_format(MainPipeline, query, sizeof(query), "/*gangtags %d %d */ UPDATE `gangtags` SET `gangid`=%d,`text`='%e',`fontid`=%d,`pdbid`=%d,`pname`='%e',`color`=%d WHERE `id`=%d",
		i, arrGangTags[i][gt_iRevision], groupid, text, fontid, GetPlayerSQLId(playerid), GetPlayerNameExt(playerid), color, i);
	if(!mysql_tquery(MainPipeline, query, "GangTag_OnWrite", "ii", i, arrGangTags[i][gt_iRevision])) GangTag_FailWrite(i, arrGangTags[i][gt_iRevision]);
	return 1;
}

GangTag_AdmSave(playerid, i, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	if(!GangTag_Valid(i) || !GangTag_BeginWrite(playerid, i, GANGTAG_WRITE_POSITION)) return 0;
	new query[512];
	mysql_format(MainPipeline, query, sizeof(query), "/*gangtags %d %d */ UPDATE `gangtags` SET `x`=%f,`y`=%f,`z`=%f,`rx`=%f,`ry`=%f,`rz`=%f WHERE `id`=%d",
		i, arrGangTags[i][gt_iRevision], x, y, z, rx, ry, rz, i);
	if(!mysql_tquery(MainPipeline, query, "GangTag_OnWrite", "ii", i, arrGangTags[i][gt_iRevision])) GangTag_FailWrite(i, arrGangTags[i][gt_iRevision]);
	return 1;
}

GangTag_Delete(playerid, i)
{
	if(!GangTag_Valid(i)) return SendClientMessage(playerid, COLOR_GRAD1, "ID Gang Tag khong hop le.");
	if(!GangTag_BeginWrite(playerid, i, GANGTAG_WRITE_DELETE)) return 0;
	new query[128];
	mysql_format(MainPipeline, query, sizeof(query), "/*gangtags %d %d */ DELETE FROM `gangtags` WHERE `id`=%d", i, arrGangTags[i][gt_iRevision], i);
	if(!mysql_tquery(MainPipeline, query, "GangTag_OnWrite", "ii", i, arrGangTags[i][gt_iRevision])) GangTag_FailWrite(i, arrGangTags[i][gt_iRevision]);
	return 1;
}

forward GangTag_OnWrite(i, revision);
public GangTag_OnWrite(i, revision)
{
	if(!GangTag_WriteMatches(i, revision)) return 0;
	if(arrGangTags[i][gt_iWrite] == GANGTAG_WRITE_DELETE)
	{
		GangTag_Clear(i);
		GangTag_CompleteWrite(i);
		return 1;
	}
	if(arrGangTags[i][gt_iWrite] == GANGTAG_WRITE_CREATE && cache_affected_rows() != 1) return GangTag_FailWrite(i, revision);
	new query[192];
	mysql_format(MainPipeline, query, sizeof(query), "/*gangtags %d %d */ SELECT *, OCTET_LENGTH(`text`) AS `textbytes` FROM `gangtags` WHERE `id`=%d", i, revision, i);
	if(!mysql_tquery(MainPipeline, query, "GangTag_OnWriteRead", "ii", i, revision)) return GangTag_FailWrite(i, revision);
	return 1;
}

forward GangTag_OnWriteRead(i, revision);
public GangTag_OnWriteRead(i, revision)
{
	if(!GangTag_WriteMatches(i, revision)) return 0;
	new rows, rowid;
	cache_get_row_count(rows);
	if(rows != 1 || !cache_get_value_name_int(0, "id", rowid) || rowid != i || !GangTag_ReadRow(0)) return GangTag_FailWrite(i, revision);
	GangTag_CompleteWrite(i);
	return 1;
}

GangTag_CompleteWrite(i)
{
	if(GangTag_Requester(i))
	{
		new message[96];
		format(message, sizeof(message), "Da luu Gang Tag ID %d.", i);
		SendClientMessage(arrGangTags[i][gt_iRequester], COLOR_YELLOW, message);
	}
	if(arrGangTags[i][gt_iWrite] == GANGTAG_WRITE_TEXT)
	{
		new message[128];
		format(message, sizeof(message), "Account %d has tagged Spray Tag Point %d (%s)", arrGangTags[i][gt_iAccount], i, arrGangTags[i][gt_szText]);
		Log("logs/gangtags.log", message);
	}
	arrGangTags[i][gt_iWrite] = 0;
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(arrAntiCheat[playerid][ac_iFlags][AC_DIALOGSPOOFING] > 0) return 1;
	switch(dialogid)
	{
		case DIALOG_GANGTAGS_INPUT:
		{
			new fontName[19];
			if(!GetPVarType(playerid, PVAR_GANGTAGID)) return 1;
			if(GetPVarType(playerid, PVAR_GANGTAGTEXT)) return 1;
			if(!response || !strlen(inputtext) || strlen(inputtext) >= MAX_GANGTAGS_LEN)
			{
				GangTag_Cancel(playerid);
				return SendClientMessage(playerid, COLOR_GRAD1, "Noi dung tag phai tu 1 den 47 byte.");
			}
			for(new j; inputtext[j]; ++j) if(inputtext[j] < 32) return GangTag_Cancel(playerid);
			format(szMiscArray, sizeof(szMiscArray), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) (T:%d) da xit %s", GetPlayerNameEx(playerid), playerid, GetPVarInt(playerid, PVAR_GANGTAGID), inputtext);
			ABroadCast(COLOR_YELLOW, szMiscArray, 2);
			SetPVarString(playerid, PVAR_GANGTAGTEXT, inputtext);
			szMiscArray[0] = 0;
			for(new j; j < sizeof(szFonts); ++j) {
				strunpack(fontName, szFonts[j], sizeof(fontName));
				format(szMiscArray, sizeof(szMiscArray), "%s%s\n", szMiscArray, fontName);
			}
			ShowPlayerDialogEx(playerid, DIALOG_GANGTAGS_FONT, DIALOG_STYLE_LIST, "Gang Tags | Phong chu", szMiscArray, "Chon", "");
			return 1;
		}
		case DIALOG_GANGTAGS_FONT:
		{
			if(gGangTagTimer[playerid]) return 1;
			if(!response || !GetPVarType(playerid, PVAR_GANGTAGTEXT) || listitem < 0 || listitem >= sizeof(szFonts)) return GangTag_Cancel(playerid);
			new i = GetPVarInt(playerid, PVAR_GANGTAGID);
			if(!GangTag_Valid(i) || gGangTagActionRevision[playerid] != arrGangTags[i][gt_iRevision]) return GangTag_Cancel(playerid);
			SendClientMessage(playerid, COLOR_GREEN, "[Gang Tags] {DDDDDD}Dang xit... Dung /tag lan nua de dung.");
			GangTag_Tick(playerid, gGangTagSession[playerid], GetPlayerSQLId(playerid), gGangTagAction[playerid], i, arrGangTags[i][gt_iRevision], GANGTAG_TIME, listitem, 0);
			return 1;
		}
		case DIALOG_GANGTAGS_LIST:
		{
			new count = gGangTagListCount[playerid];
			gGangTagListCount[playerid] = 0;
			if(!response || listitem < 0 || listitem >= count || !(PlayerInfo[playerid][pAdmin] > 1 || PlayerInfo[playerid][pGangModerator] > 0)) return 1;
			new i = gGangTagList[playerid][listitem], Float:pos[3];
			if(!GangTag_Valid(i)) return 1;
			GetDynamicObjectPos(arrGangTags[i][gt_iObjectID], pos[0], pos[1], pos[2]);
			SetPlayerPos(playerid, pos[0]+1.0, pos[1]+1.0, pos[2]+0.5);
			return 1;
		}
	}
	return 0;
}

forward GangTag_Tick(playerid, session, account, action, i, revision, time, fontid, cleaning);
public GangTag_Tick(playerid, session, account, action, i, revision, time, fontid, cleaning)
{
	if(!IsPlayerConnected(playerid) || session != gGangTagSession[playerid] || account != GetPlayerSQLId(playerid) || action != gGangTagAction[playerid]) return 0;
	gGangTagTimer[playerid] = 0;
	if(!GetPVarType(playerid, PVAR_GANGTAGID) || GetPVarInt(playerid, PVAR_GANGTAGID) != i || !GangTag_Near(playerid, i)) return GangTag_Cancel(playerid);
	if(revision != arrGangTags[i][gt_iRevision] || arrGangTags[i][gt_iWrite] || gGangTagsLoading || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return GangTag_Cancel(playerid);
	if(cleaning)
	{
		if(!(IsAStreetSweeper(playerid) || strfind(PlayerInfo[playerid][pPrisonReason], "[IC]", true) != -1)) return GangTag_Cancel(playerid);
		GangTag_Save(playerid, i, "-", 0);
		return GangTag_Cancel(playerid);
	}
	if(!IsACriminal(playerid) || PlayerInfo[playerid][pRank] <= 0 || GetPlayerWeapon(playerid) != 41 || !GetPVarType(playerid, PVAR_GANGTAGTEXT)) return GangTag_Cancel(playerid);
	if(time <= 0)
	{
		new text[MAX_GANGTAGS_LEN];
		GetPVarString(playerid, PVAR_GANGTAGTEXT, text, sizeof(text));
		GangTag_Save(playerid, i, text, fontid);
		return GangTag_Cancel(playerid);
	}
	new message[64];
	format(message, sizeof(message), "~g~ Dang xit... ~w~ %d", time / 1000);
	GameTextForPlayer(playerid, message, 4000, 3);
	gGangTagTimer[playerid] = SetTimerEx("GangTag_Tick", 1000, false, "iiiiiiiii", playerid, session, account, action, i, revision, time-1000, fontid, cleaning);
	return 1;
}

stock GetGangTags(playerid)
{
	new line[160];
	szMiscArray = "Ten to chuc(ID)\tNoi dung\n";
	gGangTagListCount[playerid] = 0;
	foreach(new i : GangTags)
	{
		new groupid = arrGangTags[i][gt_iGroup];
		if(0 <= groupid < MAX_GROUPS) format(line, sizeof(line), "(%d) %s (%d)\t%s\n", i, arrGroupData[groupid][g_szGroupName], groupid, arrGangTags[i][gt_szText]);
		else format(line, sizeof(line), "(%d) Chua gan\t%s\n", i, arrGangTags[i][gt_szText]);
		for(new j; line[j]; ++j) if(line[j] == '\r') line[j] = ' ';
		if(strlen(szMiscArray) + strlen(line) >= sizeof(szMiscArray)) break;
		strcat(szMiscArray, line, sizeof(szMiscArray));
		gGangTagList[playerid][gGangTagListCount[playerid]++] = i;
	}
	if(!gGangTagListCount[playerid]) return SendClientMessage(playerid, COLOR_GRAD1, "Chua tai Gang Tag nao.");
	return ShowPlayerDialogEx(playerid, DIALOG_GANGTAGS_LIST, DIALOG_STYLE_TABLIST_HEADERS, "Gang Tags | Danh sach", szMiscArray, "Chon", "");
}

CMD:gangtaghelp(playerid, params[])
{
	SendClientMessage(playerid, COLOR_GREEN, "______________________________");
	SendClientMessage(playerid, COLOR_GRAD1, "Gang Tags | Lenh");
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pGangModerator] > 0) SendClientMessage(playerid, COLOR_LIGHTRED, "[ADM] /createtagpoint | /edittagpoint | /deletetagpoint | /rehashgangtags");
	SendClientMessage(playerid, COLOR_GRAD1, "/tag | /cleantag");
	SendClientMessage(playerid, COLOR_GREEN, "______________________________");
	return 1;
}

IsAStreetSweeper(playerid) {

	if(Job_HasJob(playerid, JOB_STREET_SWEEPER) || (0 <= PlayerInfo[playerid][pMember] < MAX_GROUPS && arrGroupData[PlayerInfo[playerid][pMember]][g_iGroupType] == 8)) return 1;
	return 0;
}

CMD:cleantag(playerid)
{
	if(GetPVarType(playerid, PVAR_GANGTAGID)) return GangTag_Cancel(playerid);
	if(IsAStreetSweeper(playerid) || strfind(PlayerInfo[playerid][pPrisonReason], "[IC]", true) != -1) {
		new Float:gtPos[3];
		foreach(new i : GangTags)
		{
			if(!GangTag_Valid(i) || arrGangTags[i][gt_iWrite] || gGangTagsLoading) continue;
			GetDynamicObjectPos(arrGangTags[i][gt_iObjectID], gtPos[0], gtPos[1], gtPos[2]);
			if(IsPlayerInRangeOfPoint(playerid, 5.0, gtPos[0], gtPos[1], gtPos[2]))
			{
				TogglePlayerControllable(playerid, false);
				ApplyAnimation(playerid, "SPRAYCAN", "spraycan_fire", 4.1, true, true, true, true, 0, 0);
				GameTextForPlayer(playerid, "~y~Dang don...", 5000, 3);
				++gGangTagAction[playerid];
				SetPVarInt(playerid, PVAR_GANGTAGID, i);
				gGangTagTimer[playerid] = SetTimerEx("GangTag_Tick", 15000, false, "iiiiiiiii", playerid, gGangTagSession[playerid], GetPlayerSQLId(playerid), gGangTagAction[playerid], i, arrGangTags[i][gt_iRevision], 0, 0, 1);
				return 1;
			}
		}
		return SendClientMessage(playerid, COLOR_GRAD1, "Ban phai o gan tuong da xit de lau.");
	}
	else SendClientMessage(playerid, COLOR_GRAD1, "Ban phai thuoc Street Sweeper hoac cong ty ve sinh khac de dung lenh nay.");
	return 1;
}

CMD:tag(playerid, params[])
{
	if(GetPVarType(playerid, PVAR_GANGTAGID))
	{
		GangTag_Cancel(playerid);
		GameTextForPlayer(playerid, "~r~Da huy!", 5000, 3);
		return 1;
	}
	if(!IsACriminal(playerid)) return SendClientMessage(playerid, COLOR_GRAD1, "Ban phai o trong gang de dung lenh nay.");
	if(PlayerInfo[playerid][pRank] == 0) return SendClientMessage(playerid, COLOR_GRAD1, "Can it nhat rank 1 de xit tag.");
	if(GetPlayerWeapon(playerid) != 41) return SendClientMessage(playerid, COLOR_GRAD1, "Can binh son de xit len tuong.");
	new Float:gtPos[3];
	foreach(new i : GangTags)
	{
		if(!GangTag_Valid(i) || arrGangTags[i][gt_iWrite] || gGangTagsLoading) continue;
		GetDynamicObjectPos(arrGangTags[i][gt_iObjectID], gtPos[0], gtPos[1], gtPos[2]);
		if(IsPlayerInRangeOfPoint(playerid, 5.0, gtPos[0], gtPos[1], gtPos[2]))
		{
			++gGangTagAction[playerid];
			SetPVarInt(playerid, PVAR_GANGTAGID, i);
			gGangTagActionRevision[playerid] = arrGangTags[i][gt_iRevision];
			TogglePlayerControllable(playerid, false);
			ApplyAnimation(playerid, "SPRAYCAN", "spraycan_fire", 4.1, true, true, true, true, 0, 0);
			ShowPlayerDialogEx(playerid, DIALOG_GANGTAGS_INPUT, DIALOG_STYLE_INPUT, "Diem Gang Tag | Nhap noi dung", "Nhap noi dung ban muon xit len tuong", "Xit", "");
			return 1;
		}
	}
	SendClientMessage(playerid, COLOR_GRAD1, "Ban khong o gan diem tag.");
	return 1;
}

CMD:gangtags(playerid)
{
	if(PlayerInfo[playerid][pAdmin] > 1 || PlayerInfo[playerid][pGangModerator] > 0) GetGangTags(playerid);
	else SendClientMessage(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:rehashgangtags(playerid)
{
	if(PlayerInfo[playerid][pAdmin] >= 1337 || PlayerInfo[playerid][pGangModerator] > 0)
	{
		if(!GangTag_Load()) SendClientMessage(playerid, COLOR_GRAD1, "Gang Tags dang ban. Hay thu lai sau.");
	}
	else SendClientMessage(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:createtagpoint(playerid)
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pGangModerator] > 0)
	{
		if(Iter_Count(GangTags) == MAX_GANGTAGS) return SendClientMessage(playerid, COLOR_GRAD1, "Khong the tao them diem Gang Tag.");
		GangTag_Create(playerid);
	}
	else SendClientMessage(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:edittagpoint(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 1337 || PlayerInfo[playerid][pGangModerator] == 2)
	{
		new i;
		if(sscanf(params, "d", i)) return SendClientMessage(playerid, COLOR_GRAD1, "DUNG: /edittag [ID]");
		if(!GangTag_Valid(i)) return SendClientMessage(playerid, COLOR_GRAD1, "ID Gang Tag khong hop le.");
		if(gGangTagsLoading || arrGangTags[i][gt_iWrite]) return SendClientMessage(playerid, COLOR_GRAD1, "Gang Tags dang ban. Hay thu lai sau.");
		gGangTagEditRevision[playerid] = arrGangTags[i][gt_iRevision];
		SetPVarInt(playerid, PVAR_GANGTAGEDITING, i);
		EditDynamicObject(playerid, arrGangTags[i][gt_iObjectID]);
	}
	else SendClientMessage(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:deletetagpoint(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 1337 || PlayerInfo[playerid][pGangModerator] == 2)
	{
		new i;
		if(sscanf(params, "d", i)) return SendClientMessage(playerid, COLOR_GRAD1, "DUNG: /deletetag [ID]");
		GangTag_Delete(playerid, i);
	}
	else SendClientMessage(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

CMD:erasetag(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] >= 4 || PlayerInfo[playerid][pASM] >= 1 || PlayerInfo[playerid][pGangModerator] == 2)
	{
		new i;
		if(sscanf(params, "d", i)) return SendClientMessage(playerid, COLOR_GRAD1, "DUNG: /erasetag [ID]");
		GangTag_Save(playerid, i, "Cheeky Nandos", 0);
		return 1;
	}
	else SendClientMessage(playerid, COLOR_GRAD1, "Ban khong co quyen dung lenh nay.");
	return 1;
}

stock GangTag_IntColor(color)
{
	if(color == 0) return color;
	new rgba = 0xFF + (color * 256);
	return rgba >>> 8 | rgba << 24;
}
